#!/usr/bin/env python3
"""Runs the Lean constant-pool and vtable check (`ryo-lean check-pool`, lean/Ryo/Check/Image/Pool.lean,
lean/docs/aot.md §C4) over the corpus.

Each program (tests/lean/*.rs, tests/*.rs and bench/*.rs: the single-file programs; the ones that
don't build alone, or have no `main` and so no dump, are skipped) is built with
dist/bin/rustc-ryo, -Csave-temps (which keeps `<name>.<cgu>.ryo_image.rcgu.o`) and RYO_DUMP_LEAN
(the MIR dump, `<dir>/<name>.json`), at -O0 and with --opt also at -O3. Then `ryo-lean
check-pool <dump> <objects>` checks every pool reference of the objects' code against the
dump's const and vtable allocations, and `__ryo_main` and the function symbols against the
dump's instances (lean/Ryo/Check/Image/Dump.lean). This tabulates per object: references,
matched (of them vtables), placements reached through pool relocations, byte constants (`fill`
operands), not in the dump (no referencing function is a dumped body), mismatched and pool
errors; then functions, those whose symbol is a dumped instance's, symbol slots, those naming
a dumped instance or static, and the dump check's errors (`main`: the object has
`__ryo_main`), with each mismatch's and error's details.

Usage: scripts/lean-pool-check.py [names...] [--opt] [--codegen-units N] [--keep DIR] [--ryo-lean PATH] [-j N] [-v]

    names         programs (file stems, e.g. `ints`, `fib`, or `tests/lean/ints`); default: all
    --opt         also build with -Copt-level=3
    --codegen-units N
                  build the programs with -Ccodegen-units=N (several images per program)
    --keep DIR    keep the builds, dumps and outputs in DIR (default: a temporary directory)
    -v            also list the references not in the dump

Exits nonzero if any object has a mismatch or an object-level error. Run `./y.sh build` and
`lake build` in lean/ first.
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
    r"^pool-check (\S+): refs (\d+) matched (\d+) \(vtables (\d+)\) reached (\d+) bytes (\d+) not-in-dump (\d+) mismatched (\d+) errors (\d+)$"
)
FIELDS = ["refs", "matched", "vtables", "reached", "bytes", "not_in_dump", "mismatched", "errors"]
DUMP_LINE = re.compile(
    r"^dump-check (\S+): main (\S+) funcs (\d+) in-dump (\d+) slots (\d+) slot-instances (\d+) slot-statics (\d+) errors (\d+)$"
)
DUMP_FIELDS = ["funcs", "in_dump", "slots", "slot_instances", "slot_statics", "dump_errors"]


def build(src, flags, out_dir):
    """Builds `src` in `out_dir` with the dump: ((objects, dump), None) or (None, a skip reason)."""
    dump = out_dir / "dump" / f"{src.stem}.json"
    code, why = compile_program(src, flags, out_dir, env=dict(os.environ, RYO_DUMP_LEAN=str(dump.parent)))
    objs = sorted(out_dir.glob(IMAGE_GLOB))
    if not objs:
        return None, why if code != 0 else "no image object"
    if not dump.exists():
        return None, "no dump written"
    return (objs, dump), None


def check(ryo_lean, label, objs, dump, verbose):
    """Runs check-pool on a program's objects: (objects' rows, report lines, skip reason)."""
    out_dir = dump.parent.parent
    code, out, err = run([ryo_lean, "check-pool", str(dump)] + [str(o) for o in objs] + (["-v"] if verbose else []))
    text = out.decode(errors="replace")
    (out_dir / "check-pool.txt").write_text(text + err.decode(errors="replace"))
    rows, report, cur = [], [], None
    for line in text.splitlines():
        m = LINE.match(line)
        if m:
            vals = dict(zip(FIELDS, map(int, m.groups()[1:])))
            obj = Path(m.group(1)).name
            cur = (label, obj, vals)
            rows.append(cur)
            continue
        m = DUMP_LINE.match(line)
        if m and cur is not None:
            cur[2].update(zip(DUMP_FIELDS, map(int, m.groups()[2:])))
            cur[2]["main"] = m.group(2) != "-"
        elif line.startswith("pool-check "):
            rows.append((label, line.split(":", 1)[0].removeprefix("pool-check "), None))
            report.append(f"=== {label}: {line}")
        elif cur is not None and line.strip():
            report.append(f"{label} {cur[1]}: {line}")
    if code not in (0, 1) or not rows:
        return [], [], f"check-pool failed ({code}): {err.decode(errors='replace').strip()[-300:]}"
    return rows, report, None


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    add_common_args(ap)
    ap.add_argument("-v", action="store_true", help="also list the references not in the dump")
    args = ap.parse_args()

    require(args.ryo_lean)
    work = work_dir(args.keep, "lean-pool-check-")
    built, skipped = build_all(args.names, variants(args.opt, codegen_units=args.codegen_units), work, args.j, build)
    rows, reports = [], []
    with concurrent.futures.ThreadPoolExecutor(args.j) as pool:
        jobs = {pool.submit(check, args.ryo_lean, l, objs, dump, args.v): l for l, (objs, dump) in built}
        for f in concurrent.futures.as_completed(jobs):
            r, rep, why = f.result()
            if why:
                skipped.append((jobs[f], why))
            rows += r
            reports += rep
    rows.sort(key=lambda r: (r[0], r[1]))

    w = max([len(r[0]) for r in rows] + [7])
    cols = ["refs", "matched", "vtables", "reached", "bytes", "not_in_dump", "mismatched", "errors", "funcs", "in_dump", "slots",
            "slot_instances", "slot_statics", "dump_errors"]
    print(f"{'program':<{w}}  " + "  ".join(f"{c:>11}" for c in cols))
    tot = dict.fromkeys(cols, 0)
    bad = 0
    for label, obj, vals in rows:
        if vals is None:
            print(f"{label:<{w}}  unreadable object {obj}")
            bad += 1
            continue
        print(f"{label:<{w}}  " + "  ".join(f"{vals.get(c, '-'):>11}" for c in cols) + ("  main" if vals.get("main") else ""))
        for c in cols:
            tot[c] += vals.get(c, 0)
        if vals["mismatched"] or vals["errors"] or vals.get("dump_errors", 1):
            bad += 1
    print(f"{'total':<{w}}  " + "  ".join(f"{tot[c]:>11}" for c in cols))
    for label, why in sorted(skipped):
        print(f"{label:<{w}}  skipped: {why}")
    if reports:
        print()
        for line in reports:
            print(line)
    print(f"\n{len(rows) - bad}/{len(rows)} objects check; {len(skipped)} programs skipped")
    if not args.keep:
        shutil.rmtree(work, ignore_errors=True)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
