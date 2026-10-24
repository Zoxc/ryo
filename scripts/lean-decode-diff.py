#!/usr/bin/env python3
"""Cross-checks the Lean object readers (lean/Ryo/Obj, milestone M2) against Rust on real image
objects, and the Lean ELF reader against readelf.

The image objects are those of the corpus, compiled with dist/bin/rustc-ryo and
-Csave-temps (which keeps `<name>.<cgu>.ryo_image.rcgu.o`): tests/lean/*.rs, tests/*.rs and
bench/*.rs (the single-file programs; the ones that don't build alone are skipped), and, with
a ryo sysroot (`./y.sh build --sysroot ryo`), the `*.ryo_image.rcgu.o` member of each of its
rlibs (std and its dependencies).

For each object it compares
  - `ryo-lean obj <obj>` with `lean-decode-ref summary <obj>` (scripts/lean-decode-ref, the
    Rust reference: `object` + `ryo_bytecode::image`): header, validation, symbol slots,
    functions with their table sizes and their code's relocations, by `asm::Ref`;
  - with --decode: `ryo-lean decode <obj>` with `lean-decode-ref decode <obj>`, each VM
    function decoded to the reduced set (Rust: `ImageResolver::decode`). `ryo-lean decode`
    doesn't exist yet (it comes with Ryo/Vm/DecodeReduced.lean); until then --decode only
    reports that;
  - with --readelf: `ryo-lean elf <obj>` with `readelf -W -S -s -r <obj>`: sections, symbols
    and relocations.

Usage: scripts/lean-decode-diff.py [names...] [--opt] [--no-sysroot] [--decode] [--readelf]
                                   [--keep DIR] [--ryo-lean PATH] [-j N]

    names         programs (file stems, e.g. `ints`, `fib`) or sysroot crates (`std`); default:
                  all
    --opt         also build the programs with -Copt-level=3
    --keep DIR    keep the objects and outputs in DIR (default: a temporary directory)

Exits nonzero if any comparison differs. Run `./y.sh build` (with `--sysroot ryo` for the
sysroot's objects) and `lake build` in lean/ first.
"""

import argparse
import concurrent.futures
import difflib
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REF_DIR = ROOT / "scripts" / "lean-decode-ref"
TIMEOUT = 600

# The per-function decode comparison. `ryo-lean decode <obj>` is to print, for each VM function,
# what `lean-decode-ref decode <obj>` prints (see scripts/lean-decode-ref/src/main.rs). Until
# lean/Ryo/Vm/DecodeReduced.lean and the subcommand exist, --decode reports it as missing.
LEAN_DECODE = ["decode"]


def run(cmd, cwd=None, timeout=TIMEOUT):
    try:
        p = subprocess.run(cmd, cwd=cwd or ROOT, capture_output=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None, b"", b"<timeout>"
    return p.returncode, p.stdout, p.stderr


# --- objects ---------------------------------------------------------------------------------


def programs(names):
    srcs = sorted((ROOT / "tests" / "lean").glob("*.rs")) + sorted((ROOT / "tests").glob("*.rs")) + sorted((ROOT / "bench").glob("*.rs"))
    out = []
    for s in srcs:
        label = f"{s.parent.relative_to(ROOT)}/{s.stem}"
        if names and s.stem not in names and label not in names:
            continue
        out.append((label, s))
    return out


def compile_program(rustc_ryo, label, src, flags, out_dir):
    """Builds `src` with -Csave-temps in `out_dir`; the image objects it leaves, or an error."""
    shutil.rmtree(out_dir, ignore_errors=True)
    out_dir.mkdir(parents=True)
    name = src.stem
    cmd = [str(rustc_ryo), "--edition=2024", str(src), "--crate-type", "bin", "--crate-name", name, "-o", str(out_dir / name), "-Csave-temps"] + flags
    code, _, err = run(cmd, cwd=out_dir)
    objs = sorted(out_dir.glob("*.ryo_image.rcgu.o"))
    if code != 0 and not objs:
        return [], err.decode(errors="replace").strip().splitlines()[-1:] or ["build failed"]
    return objs, None


def sysroot_objects(names, out_dir):
    lib = ROOT / "dist" / "sysroot-ryo" / "lib" / "rustlib"
    rlibs = sorted(lib.glob("*/lib/*.rlib"))
    out = []
    for rlib in rlibs:
        crate = re.sub(r"^lib|-[0-9a-f]+$", "", rlib.stem)
        if names and crate not in names and f"sysroot/{crate}" not in names:
            continue
        code, members, _ = run(["ar", "t", str(rlib)])
        for m in members.decode().split():
            if m.endswith(".ryo_image.rcgu.o"):
                d = out_dir / crate
                d.mkdir(parents=True, exist_ok=True)
                code, data, _ = run(["ar", "p", str(rlib), m])
                if code == 0:
                    (d / m).write_bytes(data)
                    out.append((f"sysroot/{crate}", d / m))
    return out


# --- readelf ---------------------------------------------------------------------------------

SHT = {"NULL": 0, "PROGBITS": 1, "SYMTAB": 2, "STRTAB": 3, "RELA": 4, "HASH": 5, "DYNAMIC": 6, "NOTE": 7, "NOBITS": 8, "REL": 9,
       "INIT_ARRAY": 14, "FINI_ARRAY": 15, "PREINIT_ARRAY": 16, "GROUP": 17, "X86_64_UNWIND": 0x70000001}
SHF = [("W", 0x1), ("A", 0x2), ("X", 0x4), ("M", 0x10), ("S", 0x20), ("I", 0x40), ("L", 0x80), ("O", 0x100), ("G", 0x200), ("T", 0x400),
       ("C", 0x800), ("E", 0x80000000)]
STT = {"NOTYPE": 0, "OBJECT": 1, "FUNC": 2, "SECTION": 3, "FILE": 4, "COMMON": 5, "TLS": 6}
STB = {"LOCAL": 0, "GLOBAL": 1, "WEAK": 2, "UNIQUE": 10}
STV = {"DEFAULT": 0, "INTERNAL": 1, "HIDDEN": 2, "PROTECTED": 3}
SHN = {"UND": 0, "ABS": 0xFFF1, "COM": 0xFFF2}


def flag_letters(n):
    return "".join(c for c, b in SHF if n & b)


def readelf_lines(text):
    """`readelf -W -S -s -r` in `ryo-lean elf`'s form (section flags as readelf's letters, section
    symbols without names)."""
    out = []
    rela = None
    for line in text.splitlines():
        m = re.match(r"^\s*\[\s*(\d+)\]\s+(.*)$", line)
        if m and "Name" not in line:
            toks = m.group(2).split()
            al, inf, lk = toks.pop(), toks.pop(), toks.pop()
            flags = toks.pop() if re.fullmatch(r"[A-Za-z]+", toks[-1]) and not re.fullmatch(r"[0-9a-f]+", toks[-1]) else ""
            es, size, off, _addr, ty = toks.pop(), toks.pop(), toks.pop(), toks.pop(), toks.pop()
            name = toks.pop() if toks else ""
            out.append(f"section {m.group(1)} {name} type {SHT.get(ty, ty)} flags {flags} off {int(off, 16)} size {int(size, 16)} link {lk} info {inf} align {al} entsize {int(es, 16)}")
            continue
        m = re.match(r"^\s*(\d+): ([0-9a-f]+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s?(.*)$", line)
        if m:
            idx, val, size, ty, bind, vis, ndx, name = m.groups()
            name = re.sub(r"^\[[^\]]*\]\s*", "", name)
            size = int(size, 16) if size.startswith("0x") else int(size)
            ndx = SHN.get(ndx, ndx)
            ty = STT.get(ty, ty)
            if ty == STT["SECTION"]:
                name = ""
            out.append(f"symbol {idx} value {int(val, 16)} size {size} type {ty} bind {STB.get(bind, bind)} vis {STV.get(vis, vis)} shndx {ndx} {name}")
            continue
        m = re.match(r"^Relocation section '([^']*)'", line)
        if m:
            rela = m.group(1)
            continue
        m = re.match(r"^([0-9a-f]{16})\s+[0-9a-f]{16}\s+(\S+)\s+[0-9a-f]+\s+(.*?)\s*([+-])\s*([0-9a-f]+)$", line)
        if m and rela:
            off, ty, sym, sign, add = m.groups()
            out.append(f"rela {rela} {int(off, 16)} {ty} {sym} {int(add, 16) * (-1 if sign == '-' else 1)}")
    # readelf prints the relocations before the symbols.
    order = {"section": 0, "symbol": 1, "rela": 2}
    return sorted(out, key=lambda l: order[l.split(" ", 1)[0]])


def lean_elf_lines(text):
    out = []
    for line in text.splitlines():
        if line.startswith("section "):
            m = re.match(r"^(section \d+ \S* type \d+ flags )(\d+)( .*)$", line)
            line = m.group(1) + flag_letters(int(m.group(2))) + m.group(3)
        elif line.startswith("symbol ") and " type 3 " in line:
            line = re.sub(r"( shndx \d+) .*$", r"\1 ", line)
        out.append(line)
    return out


# --- comparisons -----------------------------------------------------------------------------


def compare(a, b, na, nb, limit=12):
    """None if the line lists agree, else the first differing lines."""
    if a == b:
        return None
    d = list(difflib.unified_diff(a, b, na, nb, lineterm="", n=1))
    return d[: limit + 2] + ([f"... ({len(d)} diff lines)"] if len(d) > limit + 2 else [])


def check(obj, args, ref, work):
    """Runs the comparisons on one object: (functions, {what: None | diff lines | note})."""
    results = {}
    _, lean, lerr = run([args.ryo_lean, "obj", str(obj)])
    _, rust, rerr = run([str(ref), "summary", str(obj)])
    lean_l, rust_l = lean.decode(errors="replace").splitlines(), rust.decode(errors="replace").splitlines()
    results["summary"] = compare(lean_l, rust_l, "ryo-lean obj", "lean-decode-ref summary")
    funcs = sum(1 for l in rust_l if l.startswith("func "))
    if args.keep:
        (obj.parent / (obj.name + ".lean.txt")).write_text("\n".join(lean_l) + "\n")
        (obj.parent / (obj.name + ".rust.txt")).write_text("\n".join(rust_l) + "\n")
    if args.decode:
        code, ld, lerr = run([args.ryo_lean] + LEAN_DECODE + [str(obj)])
        if code == 2 and b"usage" in lerr + ld:
            results["decode"] = "ryo-lean has no `decode` yet"
        else:
            _, rd, _ = run([str(ref), "decode", str(obj)])
            results["decode"] = compare(ld.decode(errors="replace").splitlines(), rd.decode(errors="replace").splitlines(), "ryo-lean decode",
                                        "lean-decode-ref decode")
    if args.readelf:
        _, le, _ = run([args.ryo_lean, "elf", str(obj)])
        _, re_, _ = run(["readelf", "-W", "-S", "-s", "-r", str(obj)])
        results["readelf"] = compare(lean_elf_lines(le.decode(errors="replace")), readelf_lines(re_.decode(errors="replace")), "ryo-lean elf", "readelf")
    return funcs, results


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("names", nargs="*")
    ap.add_argument("--ryo-lean", default=str(ROOT / "lean" / ".lake" / "build" / "bin" / "ryo-lean"))
    ap.add_argument("--opt", action="store_true")
    ap.add_argument("--no-sysroot", action="store_true", help="skip the ryo sysroot's objects")
    ap.add_argument("--decode", action="store_true", help="also compare the per-function decode (ryo-lean decode, to come)")
    ap.add_argument("--readelf", action="store_true", help="also compare ryo-lean elf with readelf")
    ap.add_argument("--keep")
    ap.add_argument("-j", type=int, default=os.cpu_count() or 4)
    args = ap.parse_args()

    rustc_ryo = ROOT / "dist" / "bin" / "rustc-ryo"
    if not rustc_ryo.exists():
        sys.exit(f"{rustc_ryo} not found; run ./y.sh build")
    if not Path(args.ryo_lean).exists():
        sys.exit(f"{args.ryo_lean} not found; build it with `lake build` in lean/, or pass --ryo-lean")
    code, _, err = run(["cargo", "build", "--release", "--quiet", "--manifest-path", str(REF_DIR / "Cargo.toml")])
    if code != 0:
        sys.exit("building scripts/lean-decode-ref failed:\n" + err.decode(errors="replace"))
    ref = REF_DIR / "target" / "release" / "lean-decode-ref"

    work = Path(args.keep) if args.keep else Path(tempfile.mkdtemp(prefix="lean-decode-diff-"))
    work.mkdir(parents=True, exist_ok=True)
    variants = [("", [])] + ([("-O3", ["-Copt-level=3"])] if args.opt else [])
    objs, skipped = [], []
    with concurrent.futures.ThreadPoolExecutor(args.j) as pool:
        jobs = {}
        for label, src in programs(args.names):
            for suffix, flags in variants:
                l = label + suffix
                jobs[pool.submit(compile_program, rustc_ryo, l, src, flags, work / l.replace("/", "_"))] = l
        for f in concurrent.futures.as_completed(jobs):
            found, err = f.result()
            if found:
                objs += [(jobs[f], o) for o in found]
            else:
                skipped.append((jobs[f], err))
    if not args.no_sysroot:
        objs += sysroot_objects(args.names, work / "sysroot")
    objs.sort()

    rows, reports = [], []
    with concurrent.futures.ThreadPoolExecutor(args.j) as pool:
        futs = [pool.submit(check, o, args, ref, work) for _, o in objs]
        for (label, o), f in zip(objs, futs):
            funcs, res = f.result()
            status = []
            for what, r in res.items():
                if r is None:
                    status.append(f"{what} ok")
                elif isinstance(r, str):
                    status.append(f"{what}: {r}")
                else:
                    status.append(f"{what} DIFFERS")
                    reports.append(f"=== {label}: {what} ({o.name}) ===\n" + "\n".join(r))
            rows.append((label, funcs, ", ".join(status)))

    w = max([len(r[0]) for r in rows] + [6])
    print(f"{'object':<{w}}  {'funcs':>6}  result")
    for label, funcs, st in rows:
        print(f"{label:<{w}}  {funcs:>6}  {st}")
    for label, err in sorted(skipped):
        print(f"{label:<{w}}  {'-':>6}  skipped: {' '.join(err)}")
    for rep in reports:
        print()
        print(rep)
    bad = sum(1 for r in rows if "DIFFERS" in r[2])
    print(f"\n{len(rows) - bad}/{len(rows)} objects agree, {sum(r[1] for r in rows)} functions; {len(skipped)} programs skipped")
    if not args.keep:
        shutil.rmtree(work, ignore_errors=True)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
