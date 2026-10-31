#!/usr/bin/env python3
"""Runs the Lean image checks (lean/Ryo/Check/Image, lean/docs/aot.md §C4: the function table
and symbols, the relocations, the JIT records, the header, the anchor and `__ryo_main` slots,
the registry object) over the corpus, with `ryo-lean check-image`.

The programs are those of scripts/lean-decode-diff.py: tests/lean/*.rs, tests/*.rs and
bench/*.rs, compiled with out/dist/bin/rustc-ryo and -Csave-temps, which keeps each program's image
objects (`<name>.<cgu>.ryo_image.rcgu.o`) and its registry object
(`<name>.<name>.ryo_registry.bin.rcgu.o`); each program's objects are checked together, as one
link. With a ryo sysroot (`./y.sh build --sysroot ryo`), the image objects of each of its rlibs
(one per CGU with VM code) are checked together, without a registry object.

Usage: scripts/lean-image-check.py [names...] [--opt] [--frame-pointer] [--codegen-units N]
                                   [--no-sysroot] [--corpus DIR] [--keep DIR] [--ryo-lean PATH] [-j N]

    names         programs (file stems, e.g. `ints`, `fib`) or sysroot crates (`std`); default:
                  all
    --opt         also build the programs with -Copt-level=3
    --codegen-units N
                  build the programs with -Ccodegen-units=N (several images per program)
    --frame-pointer
                  also build them with -Cforce-frame-pointers=yes (the frame-pointer mode)
    --corpus DIR  don't build: check DIR/<group>/ (each group's image and registry objects
                  together), as --keep leaves them
    --keep DIR    keep the objects and `check-image` outputs in DIR (default: a temporary
                  directory)

Exits nonzero if any group has a mismatch. Run `./y.sh build` and `lake build` in lean/ first.
"""

import argparse
import re
from pathlib import Path

from lean_corpus import IMAGE_GLOB, add_common_args, build_all, compile_program, corpus_dirs, finish, pool_map, print_rows, require, run, sysroot_images, variants, work_dir


def group_objects(d):
    """A directory's image objects and its registry object (or None)."""
    images = sorted(d.glob(IMAGE_GLOB))
    regs = sorted(d.glob("*.ryo_registry*.o"))
    return images, (regs[0] if regs else None)


def build(src, flags, out_dir):
    """Builds `src` in `out_dir`: ((image objects, registry object), None) or (None, an error)."""
    code, why = compile_program(src, flags, out_dir)
    images, reg = group_objects(out_dir)
    if code != 0 and not images:
        return None, why
    return (images, reg), None


SUMMARY = re.compile(r"^check-image: (\d+) image objects \((\d+) functions\).*: (\d+) mismatches$")


def check(ryo_lean, images, reg, keep_dir):
    """`ryo-lean check-image` on one group: (functions, mismatches, mismatch lines, error)."""
    cmd = [ryo_lean, "check-image"] + [str(i) for i in images] + (["--registry", str(reg)] if reg else [])
    code, out, err = run(cmd)
    text = out.decode(errors="replace")
    if keep_dir:
        (keep_dir / "check-image.txt").write_text(text)
    lines = text.splitlines()
    m = SUMMARY.match(lines[-1]) if lines else None
    if code not in (0, 1) or not m:
        return 0, 0, [], (err.decode(errors="replace").strip().splitlines() or [f"exit status {code}"])[-1]
    bad = [l for l in lines[:-1] if ": note: " not in l and not l.startswith("check-image:")]
    return int(m.group(2)), int(m.group(3)), bad, None


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    add_common_args(ap)
    ap.add_argument("--frame-pointer", action="store_true", help="also build the programs with -Cforce-frame-pointers=yes")
    ap.add_argument("--no-sysroot", action="store_true", help="skip the ryo sysroot's objects")
    ap.add_argument("--corpus", help="check the groups of objects in this directory instead of building")
    args = ap.parse_args()

    require(args.ryo_lean, rustc_ryo=not args.corpus)
    groups, skipped = [], []
    work = None
    if args.corpus:
        for label, d in corpus_dirs(args.corpus, args.names):
            images, reg = group_objects(d)
            if images:
                groups.append((label, images, reg))
        sysroot = Path(args.corpus) / "sysroot"
        for g in sorted(x for x in sysroot.iterdir() if x.is_dir()) if sysroot.is_dir() else []:
            images, reg = group_objects(g)
            label = f"sysroot/{g.name}"
            if images and (not args.names or g.name in args.names or label in args.names):
                groups.append((label, images, reg))
    else:
        work = work_dir(args.keep, "lean-image-check-")
        built, skipped = build_all(args.names, variants(args.opt, args.frame_pointer, args.codegen_units), work, args.j, build)
        groups = [(label, images, reg) for label, (images, reg) in built]
        if not args.no_sysroot:
            crates = {}
            for label, obj in sysroot_images(args.names, work / "sysroot"):
                crates.setdefault(label, []).append(obj)
            groups += [(label, objs, None) for label, objs in crates.items()]
    groups.sort(key=lambda g: g[0])

    rows, reports = [], []
    keep = args.keep and not args.corpus
    results = pool_map(args.j, check, [(args.ryo_lean, images, reg, images[0].parent if keep else None) for _, images, reg in groups])
    for (label, images, reg), (funcs, n, bad, err) in zip(groups, results):
        if err:
            st = f"ERROR: {err}"
        elif n:
            st = f"{n} MISMATCHES"
            reports.append(f"=== {label} ===\n" + "\n".join(bad))
        else:
            st = "ok"
        rows.append((label, len(images), "yes" if reg else "-", funcs, st))

    print_rows(["group", "objs", "registry", "funcs", "result"], [4, 8, 6, 0],
               [(l, str(n), r, str(f), st) for l, n, r, f, st in rows], skipped, reports)
    bad = sum(1 for r in rows if r[4] != "ok")
    print(f"\n{len(rows) - bad}/{len(rows)} groups pass: {sum(r[1] for r in rows)} image objects, "
          f"{sum(1 for r in rows if r[2] == 'yes')} registry objects, {sum(r[3] for r in rows)} functions; {len(skipped)} programs skipped")
    finish(work, args.keep, bad)


if __name__ == "__main__":
    main()
