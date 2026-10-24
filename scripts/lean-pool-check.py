#!/usr/bin/env python3
"""Runs the Lean constant-pool and vtable check (`ryo-lean check-pool`, lean/Ryo/Check/Image/Pool.lean,
lean/docs/aot.md §C4) over the corpus.

Each program (tests/lean/*.rs, tests/*.rs and bench/*.rs: the single-file programs; the ones that
don't build alone, or have no `main` and so no dump, are skipped) is built with
dist/bin/rustc-ryo, -Csave-temps (which keeps `<name>.<cgu>.ryo_image.rcgu.o`) and RYO_DUMP_LEAN
(the MIR dump, `<dir>/<name>.json`), at -O0 and with --opt also at -O3. Then `ryo-lean
check-pool <dump> <objects>` checks every pool reference of the objects' code against the
dump's const and vtable allocations, and this tabulates per object: references, matched (of
them vtables), placements reached through pool relocations, byte constants (`fill` operands),
not in the dump (no referencing function is a dumped body) and mismatched, with each
mismatch's details.

Usage: scripts/lean-pool-check.py [names...] [--opt] [--keep DIR] [--ryo-lean PATH] [-j N] [-v]

    names         programs (file stems, e.g. `ints`, `fib`, or `tests/lean/ints`); default: all
    --opt         also build with -Copt-level=3
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
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TIMEOUT = 600
LINE = re.compile(
    r"^pool-check (\S+): refs (\d+) matched (\d+) \(vtables (\d+)\) reached (\d+) bytes (\d+) not-in-dump (\d+) mismatched (\d+) errors (\d+)$"
)
FIELDS = ["refs", "matched", "vtables", "reached", "bytes", "not_in_dump", "mismatched", "errors"]


def run(cmd, cwd=None, env=None, timeout=TIMEOUT):
    try:
        p = subprocess.run(cmd, cwd=cwd or ROOT, env=env, capture_output=True, timeout=timeout)
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


def build_and_check(rustc_ryo, ryo_lean, label, src, flags, out_dir, verbose):
    """Builds `src` in `out_dir` and runs check-pool: (objects' rows, report lines, skip reason)."""
    shutil.rmtree(out_dir, ignore_errors=True)
    out_dir.mkdir(parents=True)
    name = src.stem
    dump_dir = out_dir / "dump"
    env = dict(os.environ, RYO_DUMP_LEAN=str(dump_dir))
    cmd = [str(rustc_ryo), "--edition=2024", str(src), "--crate-type", "bin", "--crate-name", name, "-o", str(out_dir / name), "-Csave-temps"]
    code, _, err = run(cmd + flags, cwd=out_dir, env=env)
    objs = sorted(out_dir.glob("*.ryo_image.rcgu.o"))
    dump = dump_dir / f"{name}.json"
    if not objs:
        why = err.decode(errors="replace").strip().splitlines()[-1:] if code != 0 else ["no image object"]
        return [], [], " ".join(why) or "build failed"
    if not dump.exists():
        return [], [], "no dump written"
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
    ap.add_argument("names", nargs="*")
    ap.add_argument("--ryo-lean", default=str(ROOT / "lean" / ".lake" / "build" / "bin" / "ryo-lean"))
    ap.add_argument("--opt", action="store_true")
    ap.add_argument("--keep")
    ap.add_argument("-j", type=int, default=os.cpu_count() or 4)
    ap.add_argument("-v", action="store_true", help="also list the references not in the dump")
    args = ap.parse_args()

    rustc_ryo = ROOT / "dist" / "bin" / "rustc-ryo"
    if not rustc_ryo.exists():
        sys.exit(f"{rustc_ryo} not found; run ./y.sh build")
    if not Path(args.ryo_lean).exists():
        sys.exit(f"{args.ryo_lean} not found; build it with `lake build` in lean/, or pass --ryo-lean")

    work = Path(args.keep) if args.keep else Path(tempfile.mkdtemp(prefix="lean-pool-check-"))
    work.mkdir(parents=True, exist_ok=True)
    variants = [("", [])] + ([("-O3", ["-Copt-level=3"])] if args.opt else [])
    rows, reports, skipped = [], [], []
    with concurrent.futures.ThreadPoolExecutor(args.j) as pool:
        jobs = {}
        for label, src in programs(args.names):
            for suffix, flags in variants:
                l = label + suffix
                jobs[pool.submit(build_and_check, rustc_ryo, args.ryo_lean, l, src, flags, work / l.replace("/", "_"), args.v)] = l
        for f in concurrent.futures.as_completed(jobs):
            r, rep, why = f.result()
            if why:
                skipped.append((jobs[f], why))
            rows += r
            reports += rep
    rows.sort(key=lambda r: (r[0], r[1]))

    w = max([len(r[0]) for r in rows] + [7])
    cols = ["refs", "matched", "vtables", "reached", "bytes", "not_in_dump", "mismatched", "errors"]
    print(f"{'program':<{w}}  " + "  ".join(f"{c:>11}" for c in cols))
    tot = dict.fromkeys(cols, 0)
    bad = 0
    for label, obj, vals in rows:
        if vals is None:
            print(f"{label:<{w}}  unreadable object {obj}")
            bad += 1
            continue
        print(f"{label:<{w}}  " + "  ".join(f"{vals[c]:>11}" for c in cols))
        for c in cols:
            tot[c] += vals[c]
        if vals["mismatched"] or vals["errors"]:
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
