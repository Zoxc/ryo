#!/usr/bin/env python3
"""Differential runs of the Lean MIR interpreter (lean/, milestone M1b) against native code.

For each program in tests/lean/ (or the names given), this builds it twice, with plain rustc
and with dist/bin/rustc-ryo (with the same flags `y test` uses for its default variant), the
ryo build with RYO_DUMP_LEAN set so the backend writes the program's MIR, runs both
executables, runs `ryo-lean run <dump> --stdout`, and compares stdout and exit status three
ways. ryo-lean's exit status: 0 when `main` returns, c for `exit(c)`, 134 for `abort`, 3 for
UB, 4 for anything else (ill-formed, out of fuel); its details go to stderr as `ryo-lean: `
lines, which are printed for every Lean run that doesn't match.

Usage: scripts/lean-diff.py [names...] [--ryo-lean PATH] [--opt] [--keep DIR] [--fuel N]

    --opt     also build with -Copt-level=3 (MIR differs: inlining, other passes)
    --keep    keep the builds and dumps in DIR (default: a temporary directory)

Exits nonzero if any program's three runs disagree or the Lean run doesn't end like the
native ones. Run `./y.sh build` first.
"""

import argparse
import difflib
import os
import shutil
import sys

from lean_corpus import ROOT, RUSTC_RYO, RYO_LEAN, finish, print_rows, require, rustc_cmd, variants, work_dir
from lean_corpus import run as corpus_run

TESTS = ROOT / "tests" / "lean"
TIMEOUT = 600


def run(cmd, env=None):
    return corpus_run(cmd, env=env, timeout=TIMEOUT, keep_partial=True)


def build(compiler, src, out_dir, flags, env=None):
    out_dir.mkdir(parents=True, exist_ok=True)
    exe = out_dir / src.stem
    code, _, err = run(rustc_cmd(compiler, src, exe) + flags, env=env)
    if code != 0:
        return None, err.decode(errors="replace")
    return exe, None


def show(code):
    return "build failed" if code is None else str(code)


def diff(a, b, na, nb):
    la = a.decode(errors="replace").splitlines()
    lb = b.decode(errors="replace").splitlines()
    out = list(difflib.unified_diff(la, lb, na, nb, lineterm="", n=1))
    return ["  " + l for l in out[:40]]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("names", nargs="*", help="programs in tests/lean (file stems); default: all")
    ap.add_argument("--ryo-lean", default=str(RYO_LEAN))
    ap.add_argument("--opt", action="store_true", help="also build with -Copt-level=3")
    ap.add_argument("--keep", help="keep the builds and dumps in this directory")
    ap.add_argument("--fuel", help="ryo-lean's fuel (steps)")
    args = ap.parse_args()

    require(args.ryo_lean)

    names = args.names or sorted(p.stem for p in TESTS.glob("*.rs"))
    work = work_dir(args.keep, "lean-diff-")

    rows = []
    reports = []
    for name in names:
        src = TESTS / f"{name}.rs"
        if not src.exists():
            sys.exit(f"no program {src}")
        for suffix, flags in variants(args.opt):
            label = name + suffix
            d = work / label
            shutil.rmtree(d, ignore_errors=True)
            dump_dir = d / "dump"
            env = dict(os.environ, RYO_DUMP_LEAN=str(dump_dir))
            results = {}
            notes = []
            for who, compiler, e in [("rustc", "rustc", None), ("ryo", RUSTC_RYO, env)]:
                exe, err = build(compiler, src, d / who, flags, e)
                if exe is None:
                    results[who] = (None, b"")
                    notes.append(f"{who} build failed:\n{err}")
                    continue
                code, out, _ = run([str(exe)])
                results[who] = (code, out)
            dump = dump_dir / f"{name}.json"
            lean_err = b""
            if dump.exists():
                cmd = [args.ryo_lean, "run", str(dump), "--stdout"]
                if args.fuel:
                    cmd += ["--fuel", args.fuel]
                code, out, lean_err = run(cmd)
                results["lean"] = (code, out)
            else:
                results["lean"] = (None, b"")
                notes.append("no dump written")
            (rc, ro), (yc, yo), (lc, lo) = results["rustc"], results["ryo"], results["lean"]
            native = rc == yc and ro == yo and rc is not None
            lean = lc == rc and lo == ro and lc is not None
            ok = native and lean
            rows.append((label, show(rc), show(yc), show(lc), "yes" if ok else "NO"))
            if not ok:
                rep = [f"=== {label} ==="]
                rep += notes
                if not native:
                    rep.append(f"rustc vs ryo: exit {rc} vs {yc}")
                    if ro != yo:
                        rep += diff(ro, yo, "rustc", "ryo")
                if not lean and lc is not None:
                    rep.append(f"rustc vs lean: exit {rc} vs {lc}")
                    if lo != ro:
                        rep += diff(ro, lo, "rustc", "lean")
                    lines = [l for l in lean_err.decode(errors="replace").splitlines() if l.strip()]
                    rep += ["  " + l for l in lines[-6:]]
                reports.append("\n".join(rep))

    print_rows(["program", "rustc", "ryo", "lean", "match"], [6, 6, 6, 0], rows, reports=reports)
    bad = sum(1 for r in rows if r[4] != "yes")
    print(f"\n{len(rows) - bad}/{len(rows)} match")
    finish(work, args.keep, bad)


if __name__ == "__main__":
    main()
