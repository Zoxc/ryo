#!/usr/bin/env python3
"""Runs the Lean check of the lowering certificate (`ryo-lean check-cert`,
lean/Ryo/Check/Lower/CertCheck.lean, lean/docs/aot.md §C1) over the corpus.

Each program (tests/lean/*.rs, tests/*.rs and bench/*.rs: the single-file programs; the ones that
don't build alone, or have no `main` and so no dump, are skipped) is built with
dist/bin/rustc-ryo, -Csave-temps (which keeps `<name>.<cgu>.ryo_image.rcgu.o`) and RYO_DUMP_LEAN
(the MIR dump `<dir>/<name>.json` and the certificate `<dir>/<name>.cert.json`), at -O0 and with
--opt also at -O3. Then `ryo-lean check-cert <dump> <cert> <objects>` checks the certificate
against the objects' decoded code and the dump: the image map (with several images, one per
CGU, each object against the certificate's image of its CGU, so an `#[inline]` function's
copy in each image against its own entry), the function map, each function's own signature,
its instruction ranges, its calls and their plans, its islands, the escape coverage of the
frame addresses it takes. This tabulates per object: functions, those with a certificate,
those whose symbol is a dumped body, functions not decoded, functions whose own plan the
dump's ABI confirmed, blocks, blocks the dumper truncated, calls and how their plans
were verified (by the callee's `FuncEntry`, by the dump's ABI, neither), islands, the frame
addresses taken (`addr`s and by-address call arguments) and how each is covered (inside an
object escaped on every path, at such an object's end, a zero-sized local; `addr_args` of them
are call arguments), errors, and the dead-store check with the certificate's facts (dropped
stores, those not shown dead); then the totals and each error.

Usage: scripts/lean-cert-check.py [names...] [--opt] [--codegen-units N] [--corpus DIR] [--keep DIR]
                                  [--ryo-lean PATH] [-j N] [-v]

    names         programs (file stems, e.g. `ints`, `fib`, or `tests/lean/ints`); default: all
    --opt         also build with -Copt-level=3
    --codegen-units N
                  build the programs with -Ccodegen-units=N (several images per program)
    --corpus DIR  don't build: check DIR/<program>/ (its image objects and dump/), as --keep
                  (here or in scripts/lean-pool-check.py) leaves them
    --keep DIR    keep the builds, dumps and outputs in DIR (default: a temporary directory)
    -v            print every error (default: the first 50 per object)

Exits nonzero if any object has an error. Run `./y.sh build` and `lake build` in lean/ first.
"""

import argparse
import concurrent.futures
import os
import re
import shutil
import sys
from pathlib import Path

from lean_corpus import IMAGE_GLOB, add_common_args, build_all, compile_program, require, run, variants, work_dir
LINE = re.compile(
    r"^cert-check (\S+): funcs (\d+) certs (\d+) in-dump (\d+) undecoded (\d+) sig-abi (\d+) blocks (\d+) truncated (\d+) "
    r"calls (\d+) by-entry (\d+) by-abi (\d+) unverified (\d+) islands (\d+) "
    r"addrs (\d+) by-escape (\d+) at-end (\d+) zero-sized (\d+) addr-args (\d+) errors (\d+)$"
)
FIELDS = ["funcs", "certs", "in_dump", "undecoded", "sig_abi", "blocks", "truncated", "calls", "by_entry", "by_abi", "unverified",
          "islands", "addrs", "by_escape", "at_end", "zero_sized", "addr_args", "errors"]
DEAD_LINE = re.compile(r"^dead-check (\S+): dropped (\d+) not-shown-dead (\d+) \(without facts (\d+)\)$")
DEAD_FIELDS = ["dropped", "not_dead", "not_dead_plain"]
MAP_LINE = re.compile(r"^cert-map: images (\d+) certificates (\d+) unmatched (\d+)$")


def build(src, flags, out_dir):
    """Builds `src` in `out_dir` with the dump: (`out_dir`, None) or (None, a skip reason)."""
    code, why = compile_program(src, flags, out_dir, env=dict(os.environ, RYO_DUMP_LEAN=str(out_dir / "dump")))
    if not list(out_dir.glob(IMAGE_GLOB)):
        return None, why if code != 0 else "no image object"
    return out_dir, None


def check(ryo_lean, label, out_dir, verbose):
    """Runs check-cert on the program in `out_dir`: (objects' rows, report lines, skip reason)."""
    objs = sorted(out_dir.glob(IMAGE_GLOB))
    certs = sorted((out_dir / "dump").glob("*.cert.json"))
    if not objs:
        return [], [], "no image object"
    if not certs:
        return [], [], "no certificate written"
    cert = certs[0]
    dump = cert.with_name(cert.name.removesuffix(".cert.json") + ".json")
    if not dump.exists():
        return [], [], "no dump written"
    code, out, err = run([ryo_lean, "check-cert", str(dump), str(cert)] + [str(o) for o in objs] + (["-v"] if verbose else []))
    text = out.decode(errors="replace")
    (out_dir / "check-cert.txt").write_text(text + err.decode(errors="replace"))
    rows, report, cur = [], [], None
    for line in text.splitlines():
        m = LINE.match(line)
        if m:
            cur = (label, Path(m.group(1)).name, dict(zip(FIELDS, map(int, m.groups()[1:]))))
            rows.append(cur)
            continue
        m = DEAD_LINE.match(line)
        if m and cur is not None:
            cur[2].update(zip(DEAD_FIELDS, map(int, m.groups()[1:])))
            continue
        m = MAP_LINE.match(line)
        if m:
            if int(m.group(3)) and rows:
                rows[-1][2]["errors"] += int(m.group(3))
            cur = (label, "cert-map", {})
        elif line.startswith("cert-check "):
            rows.append((label, line.split(":", 1)[0].removeprefix("cert-check "), None))
            report.append(f"=== {label}: {line}")
        elif cur is not None and line.strip():
            report.append(f"{label} {cur[1]}: {line}")
    if code not in (0, 1) or not rows:
        return [], [], f"check-cert failed ({code}): {err.decode(errors='replace').strip()[-300:]}"
    return rows, report, None


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    add_common_args(ap)
    ap.add_argument("--corpus", help="check the programs built in this directory instead of building")
    ap.add_argument("-v", action="store_true", help="print every error")
    args = ap.parse_args()

    require(args.ryo_lean, rustc_ryo=not args.corpus)
    rows, reports, skipped = [], [], []
    work = None
    if args.corpus:
        dirs = [(d.name, d) for d in sorted(Path(args.corpus).iterdir())
                if d.is_dir() and (not args.names or d.name in args.names or d.name.removesuffix("-O3").split("_", 1)[-1] in args.names)]
    else:
        work = work_dir(args.keep, "lean-cert-check-")
        dirs, skipped = build_all(args.names, variants(args.opt, codegen_units=args.codegen_units), work, args.j, build)
    with concurrent.futures.ThreadPoolExecutor(args.j) as pool:
        jobs = {pool.submit(check, args.ryo_lean, label, d, args.v): label for label, d in dirs}
        for f in concurrent.futures.as_completed(jobs):
            r, rep, why = f.result()
            if why:
                skipped.append((jobs[f], why))
            rows += r
            reports += rep
    rows.sort(key=lambda r: (r[0], r[1]))

    w = max([len(r[0]) for r in rows] + [7])
    cols = FIELDS + DEAD_FIELDS
    print(f"{'program':<{w}}  " + "  ".join(f"{c:>10}" for c in cols))
    tot = dict.fromkeys(cols, 0)
    bad = 0
    for label, obj, vals in rows:
        if vals is None:
            print(f"{label:<{w}}  unreadable object {obj}")
            bad += 1
            continue
        print(f"{label:<{w}}  " + "  ".join(f"{vals.get(c, '-'):>10}" for c in cols))
        for c in cols:
            tot[c] += vals.get(c, 0)
        if vals["errors"]:
            bad += 1
    print(f"{'total':<{w}}  " + "  ".join(f"{tot[c]:>10}" for c in cols))
    for label, why in sorted(skipped):
        print(f"{label:<{w}}  skipped: {why}")
    if reports:
        print()
        for line in reports:
            print(line)
    print(f"\n{len(rows) - bad}/{len(rows)} objects check; {tot['calls']} calls: {tot['by_entry']} verified by the callee's entry, "
          f"{tot['by_abi']} by the dump's ABI, {tot['unverified']} neither; {tot['addrs']} frame addresses taken: "
          f"{tot['by_escape']} in an escaped object, {tot['at_end']} at one's end, {tot['zero_sized']} zero-sized; "
          f"{len(skipped)} programs skipped")
    if work and not args.keep:
        shutil.rmtree(work, ignore_errors=True)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
