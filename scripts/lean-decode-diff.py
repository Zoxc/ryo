#!/usr/bin/env python3
"""Cross-checks the Lean object readers (lean/Ryo/Obj, milestone M2) against Rust on real image
objects, and the Lean ELF reader against readelf.

The image objects are those of the corpus, compiled with dist/bin/rustc-ryo and
-Csave-temps (which keeps `<name>.<cgu>.ryo_image.rcgu.o`): tests/lean/*.rs, tests/*.rs and
bench/*.rs (the single-file programs; the ones that don't build alone are skipped), and, with
a ryo sysroot (`./y.sh build --sysroot ryo`), the `*.ryo_image.rcgu.o` members of each of its
rlibs (std and its dependencies; one per CGU with VM code). Each object is compared alone.

For each object it compares
  - `ryo-lean obj <obj>` with `lean-decode-ref summary <obj>` (scripts/lean-decode-ref, the
    Rust reference: `object` + `ryo_bytecode::image`): header, validation, symbol slots,
    functions with their table sizes and their code's relocations, by `asm::Ref`;
  - with --decode: `ryo-lean decode <obj>` with `lean-decode-ref decode <obj>`, each VM
    function decoded to the reduced set (Rust: `ImageResolver::decode`; Lean:
    `Ryo.Vm.decodeReduced` on `Ryo.Obj.funcInputs`, lean/Ryo/Vm/DecodeObj.lean);
  - with --readelf: `ryo-lean elf <obj>` with `readelf -W -S -s -r <obj>`: sections, symbols
    and relocations;
  - with --unwind: `ryo-lean ehframe <obj>` with `readelf -W --debug-dump=frames` and
    `--debug-dump=frames-interp <obj>` (CIE and FDE fields, augmentation data with the
    relocated pointers, and each FDE's row table), and `ryo-lean lsda <obj>` with
    `lean-decode-ref lsda <obj>` (each function's FDE and LSDA, parsed by `asm::lsda::parse`,
    and whether it is the image's call-site table).

Usage: scripts/lean-decode-diff.py [names...] [--opt] [--frame-pointer] [--codegen-units N]
                                   [--no-sysroot] [--decode] [--readelf] [--unwind]
                                   [--keep DIR] [--ryo-lean PATH] [-j N]

    names         programs (file stems, e.g. `ints`, `fib`) or sysroot crates (`std`); default:
                  all
    --opt         also build the programs with -Copt-level=3
    --codegen-units N
                  build the programs with -Ccodegen-units=N (several images per program)
    --frame-pointer
                  also build them with -Cforce-frame-pointers=yes (the frame-pointer mode)
    --keep DIR    keep the objects and outputs in DIR (default: a temporary directory)

Exits nonzero if any comparison differs. Run `./y.sh build` (with `--sysroot ryo` for the
sysroot's objects) and `lake build` in lean/ first.
"""

import argparse
import concurrent.futures
import difflib
import re
import shutil
import sys

from lean_corpus import IMAGE_GLOB, ROOT, add_common_args, build_all, compile_program, require, run, sysroot_images, variants, work_dir

REF_DIR = ROOT / "scripts" / "lean-decode-ref"

# The per-function decode comparison: `ryo-lean decode <obj>` prints, for each VM function, what
# `lean-decode-ref decode <obj>` prints (see scripts/lean-decode-ref/src/main.rs).
LEAN_DECODE = ["decode"]


def build(src, flags, out_dir):
    """Builds `src` in `out_dir`: (the image objects it leaves, None) or (None, an error)."""
    code, why = compile_program(src, flags, out_dir)
    objs = sorted(out_dir.glob(IMAGE_GLOB))
    if code != 0 and not objs:
        return None, why
    return objs, None


# --- readelf ---------------------------------------------------------------------------------

SHT = {"NULL": 0, "PROGBITS": 1, "SYMTAB": 2, "STRTAB": 3, "RELA": 4, "HASH": 5, "DYNAMIC": 6, "NOTE": 7, "NOBITS": 8, "REL": 9,
       "INIT_ARRAY": 14, "FINI_ARRAY": 15, "PREINIT_ARRAY": 16, "GROUP": 17, "X86_64_UNWIND": 0x70000001}
SHF = [("W", 0x1), ("A", 0x2), ("X", 0x4), ("M", 0x10), ("S", 0x20), ("I", 0x40), ("L", 0x80), ("O", 0x100), ("G", 0x200), ("T", 0x400),
       ("C", 0x800), ("o", 0x0FF00000), ("E", 0x80000000)]  # `o`: OS-specific, e.g. SHF_GNU_RETAIN (`ryo_images`)
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


# --- .eh_frame ------------------------------------------------------------------------------

# DWARF register numbers of x86-64 by readelf's names; `ra` is the return address column.
DWARF_REGS = {n: i for i, n in enumerate(["rax", "rdx", "rcx", "rbx", "rsi", "rdi", "rbp", "rsp"] + [f"r{i}" for i in range(8, 16)] + ["rip"])}
ENTRY = re.compile(r"^([0-9a-f]{8}) ([0-9a-f]{16}) ([0-9a-f]{8}) (CIE|FDE)(.*)$")


def readelf_unwind_lines(frames, interp):
    """`readelf --debug-dump=frames` and `frames-interp` in the common form of `lean_unwind_lines`:

        cie <off> len <length> version <v> aug <aug> cf <c> df <d> ra <r> augdata <hex bytes>
          row 0 cfa r<reg>+<off> r<reg>=c<off>...
        fde <off> len <length> cie <cie off> pc <start>..<end> augdata <hex bytes>
          row <absolute loc> ...

    (header fields and augmentation data from `frames`, rows from `frames-interp`; register
    rules readelf shows as `u`, undefined, dropped)."""
    heads, order = {}, []
    cur = None
    for line in frames.splitlines():
        m = ENTRY.match(line)
        if m:
            off, length, _, kind, rest = m.groups()
            cur = {"kind": kind, "off": int(off, 16), "len": int(length, 16), "augdata": ""}
            if kind == "FDE":
                f = re.search(r"cie=([0-9a-f]+) pc=([0-9a-f]+)\.\.([0-9a-f]+)", rest)
                cur["cie"], cur["pc"] = int(f.group(1), 16), (int(f.group(2), 16), int(f.group(3), 16))
            heads[cur["off"]] = cur
            order.append(cur["off"])
            continue
        if cur is None:
            continue
        m = re.match(r"^\s+(Version|Augmentation|Code alignment factor|Data alignment factor|Return address column|Augmentation data):\s*(.*)$", line)
        if m:
            cur[m.group(1)] = m.group(2).strip().strip('"')
    rows = {}
    cur, cols = None, []
    for line in interp.splitlines():
        m = ENTRY.match(line)
        if m:
            cur = int(m.group(1), 16)
            rows[cur] = []
            continue
        m = re.match(r"^\s+LOC\s+CFA\s*(.*)$", line)
        if m:
            cols = m.group(1).split()
            continue
        m = re.match(r"^([0-9a-f]{16}) (\S+)\s*(.*)$", line)
        if m and cur is not None:
            loc, cfa, cells = m.groups()
            c = re.fullmatch(r"([a-z0-9]+)([+-]\d+)", cfa)
            cfa = f"r{DWARF_REGS.get(c.group(1), c.group(1))}{'+' if int(c.group(2)) >= 0 else ''}{int(c.group(2))}" if c else cfa
            regs = []
            for name, cell in zip(cols, cells.split()):
                if cell == "u":
                    continue
                r = heads[cur].get("Return address column", "16") if name == "ra" else DWARF_REGS.get(name, name)
                regs.append((int(r), cell))
            rows[cur].append(f"  row {int(loc, 16)} cfa {cfa}" + "".join(f" r{r}={v}" for r, v in sorted(regs)))
    out = []
    for off in order:
        h = heads[off]
        if h["kind"] == "CIE":
            out.append(f"cie {off} len {h['len']} version {h.get('Version')} aug {h.get('Augmentation')} cf {h.get('Code alignment factor')} df {h.get('Data alignment factor')} ra {h.get('Return address column')} augdata {h['Augmentation data']}")
        else:
            out.append(f"fde {off} len {h['len']} cie {h['cie']} pc {h['pc'][0]}..{h['pc'][1]} augdata {h['Augmentation data']}")
        out += rows.get(off, [])
    return out


def lean_unwind_lines(text):
    """`ryo-lean ehframe`'s output in the common form (see `readelf_unwind_lines`): the pointer
    fields as readelf shows them in an object whose sections are all at address 0 (the
    relocation's `S + A`, and in the augmentation data `S + A - P`), rows at absolute
    locations."""
    def le32(v):
        return " ".join(f"{b:02x}" for b in (v % 2**32).to_bytes(4, "little"))

    def ptr(toks, i):
        """(value, field position) of the pointer at toks[i:]: `<target> <off> @<pos>` or `none @<pos>`."""
        if toks[i] == "none":
            return None, int(toks[i + 1][1:]), i + 2
        return int(toks[i + 1]), int(toks[i + 2][1:]), i + 3

    out, base = [], 0
    for line in text.splitlines():
        toks = line.split()
        if toks and toks[0] == "cie":
            f = dict(zip(toks[2:14:2], toks[3:15:2]))
            data = {}
            i = toks.index("personality") if "personality" in toks else None
            if i is not None:
                v, pos, _ = ptr(toks, i + 2)
                data["P"] = f"{int(toks[i + 1]):02x} " + le32((v or 0) - pos if v is not None else 0)
            if "lsda_enc" in toks:
                data["L"] = f"{int(toks[toks.index('lsda_enc') + 1]):02x}"
            data["R"] = f"{int(toks[toks.index('fde_enc') + 1]):02x}"
            aug = " ".join(data[c] for c in f["aug"][1:])
            out.append(f"cie {toks[1]} len {f['len']} version {f['version']} aug {f['aug']} cf {f['cf']} df {f['df']} ra {f['ra']} augdata {aug}")
            base = 0
        elif toks and toks[0] == "fde":
            pc, _, j = ptr(toks, toks.index("pc") + 1)
            rng = int(toks[j + 1])
            aug = ""
            if "lsda" in toks:
                v, pos, _ = ptr(toks, toks.index("lsda") + 1)
                aug = le32(v - pos if v is not None else 0)
            base = pc or 0
            out.append(f"fde {toks[1]} len {toks[3]} cie {toks[5]} pc {base}..{base + rng} augdata {aug}")
        elif toks and toks[0] == "row":
            out.append(f"  row {int(toks[1]) + base} " + " ".join(toks[2:]))
        else:
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
        _, rd, _ = run([str(ref), "decode", str(obj)])
        # (An image without functions: the Rust reference prints an empty line, Lean nothing.)
        results["decode"] = compare(ld.decode(errors="replace").strip().splitlines(), rd.decode(errors="replace").strip().splitlines(),
                                    "ryo-lean decode", "lean-decode-ref decode")
    if args.readelf:
        _, le, _ = run([args.ryo_lean, "elf", str(obj)])
        _, re_, _ = run(["readelf", "-W", "-S", "-s", "-r", str(obj)])
        results["readelf"] = compare(lean_elf_lines(le.decode(errors="replace")), readelf_lines(re_.decode(errors="replace")), "ryo-lean elf", "readelf")
    if args.unwind:
        _, le, _ = run([args.ryo_lean, "ehframe", str(obj)])
        _, fr, _ = run(["readelf", "-W", "--debug-dump=frames", str(obj)])
        _, fi, _ = run(["readelf", "-W", "--debug-dump=frames-interp", str(obj)])
        dec = lambda b: b.decode(errors="replace")
        results["ehframe"] = compare(lean_unwind_lines(dec(le)), readelf_unwind_lines(dec(fr), dec(fi)), "ryo-lean ehframe", "readelf")
        _, ll, _ = run([args.ryo_lean, "lsda", str(obj)])
        _, rl, _ = run([str(ref), "lsda", str(obj)])
        ll, rl = dec(ll).splitlines(), dec(rl).splitlines()
        results["lsda"] = compare(ll, rl, "ryo-lean lsda", "lean-decode-ref lsda")
        # Both readers agreeing isn't enough: every function needs an LSDA equal to its image
        # call-site table, and an FDE covering exactly its code.
        def wrong(l):
            m = re.search(r" range (\d+) len (\d+) ", l)
            return l.strip() in ("image differs", "lsda error") or " error: " in l or (m and m.group(1) != m.group(2))
        if results["lsda"] is None and any(wrong(l) for l in ll):
            results["lsda"] = [l for l in ll if wrong(l)][:12]
        if args.keep:
            (obj.parent / (obj.name + ".ehframe.txt")).write_text(dec(le))
            (obj.parent / (obj.name + ".lsda.txt")).write_text("\n".join(ll) + "\n")
    return funcs, results


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    add_common_args(ap)
    ap.add_argument("--no-sysroot", action="store_true", help="skip the ryo sysroot's objects")
    ap.add_argument("--decode", action="store_true", help="also compare the per-function decode (ryo-lean decode)")
    ap.add_argument("--readelf", action="store_true", help="also compare ryo-lean elf with readelf")
    ap.add_argument("--unwind", action="store_true", help="also compare ryo-lean ehframe with readelf and ryo-lean lsda with lean-decode-ref lsda")
    ap.add_argument("--frame-pointer", action="store_true", help="also build the programs with -Cforce-frame-pointers=yes")
    args = ap.parse_args()

    require(args.ryo_lean)
    code, _, err = run(["cargo", "build", "--release", "--quiet", "--manifest-path", str(REF_DIR / "Cargo.toml")])
    if code != 0:
        sys.exit("building scripts/lean-decode-ref failed:\n" + err.decode(errors="replace"))
    ref = REF_DIR / "target" / "release" / "lean-decode-ref"

    work = work_dir(args.keep, "lean-decode-diff-")
    built, skipped = build_all(args.names, variants(args.opt, args.frame_pointer, args.codegen_units), work, args.j, build)
    objs = [(label, o) for label, found in built for o in found]
    if not args.no_sysroot:
        objs += sysroot_images(args.names, work / "sysroot")
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
        print(f"{label:<{w}}  {'-':>6}  skipped: {err}")
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
