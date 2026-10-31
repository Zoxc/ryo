#!/usr/bin/env python3
"""Runs the Lean constant-pool and vtable check (`ryo-lean check-pool`, lean/Ryo/Check/Image/Pool.lean,
lean/docs/aot.md §C4) over the corpus.

Each program (tests/lean/*.rs, tests/*.rs and bench/*.rs: the single-file programs; the ones that
don't build alone, or have no `main` and so no dump, are skipped) is built with
out/dist/bin/rustc-ryo, -Csave-temps (which keeps `<name>.<cgu>.ryo_image.rcgu.o`) and RYO_DUMP_LEAN
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
import os
import re

from lean_corpus import (IMAGE_GLOB, add_common_args, build_all, check_all, compile_program, finish, parse_rows, print_table, require, run,
                         variants, work_dir)
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


def fold_dump(label, m, cur, rows):
    if cur is not None:
        cur[2].update(zip(DUMP_FIELDS, map(int, m.groups()[2:])))
        cur[2]["main"] = m.group(2) != "-"
    return cur


def check(ryo_lean, label, objs, dump, verbose):
    """Runs check-pool on a program's objects: (objects' rows, report lines, skip reason)."""
    out_dir = dump.parent.parent
    code, out, err = run([ryo_lean, "check-pool", str(dump)] + [str(o) for o in objs] + (["-v"] if verbose else []))
    text = out.decode(errors="replace")
    (out_dir / "check-pool.txt").write_text(text + err.decode(errors="replace"))
    rows, report = parse_rows(text, label, "pool-check", LINE, FIELDS, [(DUMP_LINE, fold_dump)])
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
    rows, reports, failed = check_all(args.j, check, [(l, (args.ryo_lean, l, objs, dump, args.v)) for l, (objs, dump) in built])
    skipped += failed
    _, bad = print_table(rows, FIELDS + DUMP_FIELDS, 11,
                         lambda vals: vals["mismatched"] or vals["errors"] or vals.get("dump_errors", 1),
                         skipped, reports, note=lambda vals: "  main" if vals.get("main") else "")
    print(f"\n{len(rows) - bad}/{len(rows)} objects check; {len(skipped)} programs skipped")
    finish(work, args.keep, bad)


if __name__ == "__main__":
    main()
