#!/usr/bin/env python3
"""Runs the Lean image checks (lean/Ryo/Check/Image, lean/docs/aot.md §C4: the function table
and symbols, the relocations, the JIT records, the header, the anchor and `__ryo_main` slots,
the registry object) over the corpus, with `ryo-lean check-image`.

The programs are those of scripts/lean-decode-diff.py: tests/lean/*.rs, tests/*.rs and
bench/*.rs, compiled with dist/bin/rustc-ryo and -Csave-temps, which keeps each program's image
objects (`<name>.<cgu>.ryo_image.rcgu.o`) and its registry object
(`<name>.<name>.ryo_registry.bin.rcgu.o`); each program's objects are checked together, as one
link. With a ryo sysroot (`./y.sh build --sysroot ryo`), the image object of each of its rlibs
is checked alone (no registry object).

Usage: scripts/lean-image-check.py [names...] [--opt] [--no-sysroot] [--corpus DIR]
                                   [--keep DIR] [--ryo-lean PATH] [-j N]

    names         programs (file stems, e.g. `ints`, `fib`) or sysroot crates (`std`); default:
                  all
    --opt         also build the programs with -Copt-level=3
    --corpus DIR  don't build: check DIR/<group>/ (each group's image and registry objects
                  together), as --keep leaves them
    --keep DIR    keep the objects and `check-image` outputs in DIR (default: a temporary
                  directory)

Exits nonzero if any group has a mismatch. Run `./y.sh build` and `lake build` in lean/ first.
"""

import argparse
import concurrent.futures
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TIMEOUT = 1800


def run(cmd, cwd=None, timeout=TIMEOUT):
    try:
        p = subprocess.run(cmd, cwd=cwd or ROOT, capture_output=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None, b"", b"<timeout>"
    return p.returncode, p.stdout, p.stderr


def programs(names):
    srcs = sorted((ROOT / "tests" / "lean").glob("*.rs")) + sorted((ROOT / "tests").glob("*.rs")) + sorted((ROOT / "bench").glob("*.rs"))
    out = []
    for s in srcs:
        label = f"{s.parent.relative_to(ROOT)}/{s.stem}"
        if names and s.stem not in names and label not in names:
            continue
        out.append((label, s))
    return out


def group_objects(d):
    """A directory's image objects and its registry object (or None)."""
    images = sorted(d.glob("*.ryo_image.rcgu.o"))
    regs = sorted(d.glob("*.ryo_registry*.o"))
    return images, (regs[0] if regs else None)


def compile_program(rustc_ryo, src, flags, out_dir):
    """Builds `src` with -Csave-temps in `out_dir`: (image objects, registry object), or an error."""
    shutil.rmtree(out_dir, ignore_errors=True)
    out_dir.mkdir(parents=True)
    name = src.stem
    cmd = [str(rustc_ryo), "--edition=2024", str(src), "--crate-type", "bin", "--crate-name", name, "-o", str(out_dir / name), "-Csave-temps"] + flags
    code, _, err = run(cmd, cwd=out_dir)
    images, reg = group_objects(out_dir)
    if code != 0 and not images:
        return None, err.decode(errors="replace").strip().splitlines()[-1:] or ["build failed"]
    return (images, reg), None


def sysroot_groups(names, out_dir):
    lib = ROOT / "dist" / "sysroot-ryo" / "lib" / "rustlib"
    out = []
    for rlib in sorted(lib.glob("*/lib/*.rlib")):
        crate = re.sub(r"^lib|-[0-9a-f]+$", "", rlib.stem)
        if names and crate not in names and f"sysroot/{crate}" not in names:
            continue
        _, members, _ = run(["ar", "t", str(rlib)])
        for m in members.decode().split():
            if m.endswith(".ryo_image.rcgu.o"):
                d = out_dir / crate
                d.mkdir(parents=True, exist_ok=True)
                code, data, _ = run(["ar", "p", str(rlib), m])
                if code == 0:
                    (d / m).write_bytes(data)
                    out.append((f"sysroot/{crate}", [d / m], None))
    return out


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
    ap.add_argument("names", nargs="*")
    ap.add_argument("--ryo-lean", default=str(ROOT / "lean" / ".lake" / "build" / "bin" / "ryo-lean"))
    ap.add_argument("--opt", action="store_true")
    ap.add_argument("--no-sysroot", action="store_true", help="skip the ryo sysroot's objects")
    ap.add_argument("--corpus", help="check the groups of objects in this directory instead of building")
    ap.add_argument("--keep")
    ap.add_argument("-j", type=int, default=os.cpu_count() or 4)
    args = ap.parse_args()

    if not Path(args.ryo_lean).exists():
        sys.exit(f"{args.ryo_lean} not found; build it with `lake build` in lean/, or pass --ryo-lean")
    groups, skipped = [], []
    work = None
    if args.corpus:
        for d in sorted(Path(args.corpus).iterdir()):
            if not d.is_dir():
                continue
            subdirs = [d] + (sorted(x for x in d.iterdir() if x.is_dir()) if d.name == "sysroot" else [])
            for g in subdirs:
                images, reg = group_objects(g)
                label = g.name if g == d else f"sysroot/{g.name}"
                if images and (not args.names or g.name in args.names or label in args.names):
                    groups.append((label, images, reg))
    else:
        rustc_ryo = ROOT / "dist" / "bin" / "rustc-ryo"
        if not rustc_ryo.exists():
            sys.exit(f"{rustc_ryo} not found; run ./y.sh build")
        work = Path(args.keep) if args.keep else Path(tempfile.mkdtemp(prefix="lean-image-check-"))
        work.mkdir(parents=True, exist_ok=True)
        variants = [("", [])] + ([("-O3", ["-Copt-level=3"])] if args.opt else [])
        with concurrent.futures.ThreadPoolExecutor(args.j) as pool:
            jobs = {}
            for label, src in programs(args.names):
                for suffix, flags in variants:
                    l = label + suffix
                    jobs[pool.submit(compile_program, rustc_ryo, src, flags, work / l.replace("/", "_"))] = l
            for f in concurrent.futures.as_completed(jobs):
                found, err = f.result()
                if found:
                    groups.append((jobs[f], found[0], found[1]))
                else:
                    skipped.append((jobs[f], err))
        if not args.no_sysroot:
            groups += sysroot_groups(args.names, work / "sysroot")
    groups.sort(key=lambda g: g[0])

    rows, reports = [], []
    with concurrent.futures.ThreadPoolExecutor(args.j) as pool:
        futs = [pool.submit(check, args.ryo_lean, images, reg, images[0].parent if args.keep and not args.corpus else None)
                for _, images, reg in groups]
        for (label, images, reg), f in zip(groups, futs):
            funcs, n, bad, err = f.result()
            if err:
                st = f"ERROR: {err}"
            elif n:
                st = f"{n} MISMATCHES"
                reports.append(f"=== {label} ===\n" + "\n".join(bad))
            else:
                st = "ok"
            rows.append((label, len(images), "yes" if reg else "-", funcs, st))

    w = max([len(r[0]) for r in rows] + [5])
    print(f"{'group':<{w}}  {'objs':>4}  {'registry':>8}  {'funcs':>6}  result")
    for label, nobj, reg, funcs, st in rows:
        print(f"{label:<{w}}  {nobj:>4}  {reg:>8}  {funcs:>6}  {st}")
    for label, err in sorted(skipped):
        print(f"{label:<{w}}  {'-':>4}  {'-':>8}  {'-':>6}  skipped: {' '.join(err)}")
    for rep in reports:
        print()
        print(rep)
    bad = sum(1 for r in rows if r[4] != "ok")
    print(f"\n{len(rows) - bad}/{len(rows)} groups pass: {sum(r[1] for r in rows)} image objects, "
          f"{sum(1 for r in rows if r[2] == 'yes')} registry objects, {sum(r[3] for r in rows)} functions; {len(skipped)} programs skipped")
    if work and not args.keep:
        shutil.rmtree(work, ignore_errors=True)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
