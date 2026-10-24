#!/usr/bin/env python3
"""Runs the Lean check of the lowering certificate (`ryo-lean check-cert`,
lean/Ryo/Check/Lower/CertCheck.lean, lean/docs/aot.md §C1) over the corpus.

Each program (tests/lean/*.rs, tests/*.rs and bench/*.rs: the single-file programs; the ones that
don't build alone, or have no `main` and so no dump, are skipped) is built with
dist/bin/rustc-ryo, -Csave-temps (which keeps `<name>.<cgu>.ryo_image.rcgu.o`) and RYO_DUMP_LEAN
(the MIR dump `<dir>/<name>.json` and the certificate `<dir>/<name>.cert.json`), at -O0 and with
--opt also at -O3. Then `ryo-lean check-cert <dump> <cert> <objects>` checks the certificate
against the objects' decoded code and the dump: the function map, each function's own
signature, its instruction ranges, its calls and their plans, its islands. This tabulates per
object: functions, those with a certificate, those whose symbol is a dumped body, functions
not decoded, functions whose own plan the dump's ABI confirmed, blocks, blocks the dumper
truncated, calls and how their plans were verified (by the callee's `FuncEntry`, by the dump's
ABI, neither), islands, errors, and the dead-store check with the certificate's facts (dropped
stores, those not shown dead); then the totals and each error.

Usage: scripts/lean-cert-check.py [names...] [--opt] [--corpus DIR] [--keep DIR] [--ryo-lean PATH] [-j N] [-v]

    names         programs (file stems, e.g. `ints`, `fib`, or `tests/lean/ints`); default: all
    --opt         also build with -Copt-level=3
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
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TIMEOUT = 1800
LINE = re.compile(
    r"^cert-check (\S+): funcs (\d+) certs (\d+) in-dump (\d+) undecoded (\d+) sig-abi (\d+) blocks (\d+) truncated (\d+) "
    r"calls (\d+) by-entry (\d+) by-abi (\d+) unverified (\d+) islands (\d+) errors (\d+)$"
)
FIELDS = ["funcs", "certs", "in_dump", "undecoded", "sig_abi", "blocks", "truncated", "calls", "by_entry", "by_abi", "unverified",
          "islands", "errors"]
DEAD_LINE = re.compile(r"^dead-check (\S+): dropped (\d+) not-shown-dead (\d+) \(without facts (\d+)\)$")
DEAD_FIELDS = ["dropped", "not_dead", "not_dead_plain"]
MAP_LINE = re.compile(r"^cert-map: certificates (\d+) unmatched (\d+)$")


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


def build(rustc_ryo, src, flags, out_dir):
    """Builds `src` in `out_dir` with the dump: a skip reason, or None."""
    shutil.rmtree(out_dir, ignore_errors=True)
    out_dir.mkdir(parents=True)
    name = src.stem
    env = dict(os.environ, RYO_DUMP_LEAN=str(out_dir / "dump"))
    cmd = [str(rustc_ryo), "--edition=2024", str(src), "--crate-type", "bin", "--crate-name", name, "-o", str(out_dir / name), "-Csave-temps"]
    code, _, err = run(cmd + flags, cwd=out_dir, env=env)
    if not list(out_dir.glob("*.ryo_image.rcgu.o")):
        why = err.decode(errors="replace").strip().splitlines()[-1:] if code != 0 else ["no image object"]
        return " ".join(why) or "build failed"
    return None


def check(ryo_lean, label, out_dir, verbose):
    """Runs check-cert on the program in `out_dir`: (objects' rows, report lines, skip reason)."""
    objs = sorted(out_dir.glob("*.ryo_image.rcgu.o"))
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
            if int(m.group(2)) and rows:
                rows[-1][2]["errors"] += int(m.group(2))
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
    ap.add_argument("names", nargs="*")
    ap.add_argument("--ryo-lean", default=str(ROOT / "lean" / ".lake" / "build" / "bin" / "ryo-lean"))
    ap.add_argument("--opt", action="store_true")
    ap.add_argument("--corpus", help="check the programs built in this directory instead of building")
    ap.add_argument("--keep")
    ap.add_argument("-j", type=int, default=os.cpu_count() or 4)
    ap.add_argument("-v", action="store_true", help="print every error")
    args = ap.parse_args()

    if not Path(args.ryo_lean).exists():
        sys.exit(f"{args.ryo_lean} not found; build it with `lake build` in lean/, or pass --ryo-lean")
    rows, reports, skipped = [], [], []
    work = None
    if args.corpus:
        dirs = [(d.name, d) for d in sorted(Path(args.corpus).iterdir())
                if d.is_dir() and (not args.names or d.name in args.names or d.name.removesuffix("-O3").split("_", 1)[-1] in args.names)]
    else:
        rustc_ryo = ROOT / "dist" / "bin" / "rustc-ryo"
        if not rustc_ryo.exists():
            sys.exit(f"{rustc_ryo} not found; run ./y.sh build")
        work = Path(args.keep) if args.keep else Path(tempfile.mkdtemp(prefix="lean-cert-check-"))
        work.mkdir(parents=True, exist_ok=True)
        variants = [("", [])] + ([("-O3", ["-Copt-level=3"])] if args.opt else [])
        dirs = []
        with concurrent.futures.ThreadPoolExecutor(args.j) as pool:
            jobs = {}
            for label, src in programs(args.names):
                for suffix, flags in variants:
                    l = label + suffix
                    d = work / l.replace("/", "_")
                    jobs[pool.submit(build, rustc_ryo, src, flags, d)] = (l, d)
            for f in concurrent.futures.as_completed(jobs):
                why = f.result()
                if why:
                    skipped.append((jobs[f][0], why))
                else:
                    dirs.append(jobs[f])
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
          f"{tot['by_abi']} by the dump's ABI, {tot['unverified']} neither; {len(skipped)} programs skipped")
    if work and not args.keep:
        shutil.rmtree(work, ignore_errors=True)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
