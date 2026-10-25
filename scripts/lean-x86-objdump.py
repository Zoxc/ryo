#!/usr/bin/env python3
"""Cross-checks the x86 encoding vectors of the Lean model against objdump.

lean/RyoTest/X86Vectors.lean (written by vm/bytecode/tests/lean_x86_vectors.rs) holds the bytes
the Rust encoder gives a broad set of items, which the Lean tests check `Ryo.X86.Item.encode`
and `decodeItem` against. This script checks the same bytes against an independent
disassembler: it renders each item as the Intel-syntax text objdump should print for it (from
the item alone, not from its bytes), disassembles all the vectors' bytes with
`objdump -D -b binary -m i386:x86-64 -M intel`, and compares instruction by instruction. It also
checks that the OSR vectors' code (outside the dispatcher's table) disassembles to the forms of
asm/osr.rs only, and the bytes of the JIT entry prefix and the registry constructors.

Usage: scripts/lean-x86-objdump.py [--objdump PATH] [--verbose]

Exits nonzero on any disagreement, printing each.
"""

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VECTORS = ROOT / "lean" / "RyoTest" / "X86Vectors.lean"

REGS = {
    "rax": 0, "rcx": 1, "rdx": 2, "rsp": 4, "rbp": 5, "rsi": 6, "rdi": 7,
    "r8": 8, "r9": 9, "r10": 10, "r11": 11,
}
NAMES = {
    8: ["al", "cl", "dl", "bl", "spl", "bpl", "sil", "dil"] + [f"r{i}b" for i in range(8, 16)],
    16: ["ax", "cx", "dx", "bx", "sp", "bp", "si", "di"] + [f"r{i}w" for i in range(8, 16)],
    32: ["eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi"] + [f"r{i}d" for i in range(8, 16)],
    64: ["rax", "rcx", "rdx", "rbx", "rsp", "rbp", "rsi", "rdi"] + [f"r{i}" for i in range(8, 16)],
}
BITS = {"b": 8, "w": 16, "d": 32, "q": 64}
PTR = {8: "BYTE", 16: "WORD", 32: "DWORD", 64: "QWORD", 128: "XMMWORD"}
CC = {
    "z": "e", "nz": "ne", "l": "l", "ge": "ge", "le": "le", "g": "g",
    "b": "b", "ae": "ae", "be": "be", "a": "a", "s": "s", "ns": "ns", "o": "o", "no": "no",
}
NOPS = {
    1: "nop", 2: "xchg ax,ax", 3: "nop DWORD PTR [rax]", 4: "nop DWORD PTR [rax+0x0]",
    5: "nop DWORD PTR [rax+rax*1+0x0]", 6: "nop WORD PTR [rax+rax*1+0x0]",
    7: "nop DWORD PTR [rax+0x0]", 8: "nop DWORD PTR [rax+rax*1+0x0]",
    9: "nop WORD PTR [rax+rax*1+0x0]",
}


def sx(v, bits):
    v &= (1 << bits) - 1
    return v - (1 << bits) if v >> (bits - 1) else v


def reg(name, bits=64):
    return NAMES[bits][REGS[name]]


def disp(d):
    d = sx(d, 32)
    return f"+{d:#x}" if d >= 0 else f"-{-d:#x}"


def mem(m, bits=None):
    base, d = m["base"], sx(m["disp"], 32)
    inner = f"[{base}]" if d == 0 and base != "rbp" else f"[{base}{disp(d)}]"
    return f"{PTR[bits]} PTR {inner}" if bits else inner


def rm(r, bits):
    return reg(r["reg"]["r"], bits) if "reg" in r else mem(r["mem"]["m"], bits)


def imm(v, bits):
    """An immediate as objdump prints it: the field's value at the operand width."""
    return f"{sx(v, 32) & ((1 << bits) - 1):#x}"


def set_form(v):
    if v == 0:
        return 0
    if v < 1 << 32:
        return 1
    return 2 if sx(v, 64) == sx(v & 0xFFFFFFFF, 32) else 3


def render(item, pos, off, length, sp):
    """The instructions objdump should print for `item` at blob offset `off` (its position in
    the function is `pos`, its encoded length `length`)."""
    if isinstance(item, str):
        name, f = item, {}
    else:
        (name, f), = item.items()
    if sp is not None and "m" in f and f["m"]["base"] == "rbp":
        f = dict(f, m={"base": "rsp", "disp": (f["m"]["disp"] + sp) & 0xFFFFFFFF})
    if sp is not None and "rm" in f and "mem" in f["rm"] and f["rm"]["mem"]["m"]["base"] == "rbp":
        m = f["rm"]["mem"]["m"]
        f = dict(f, rm={"mem": {"m": {"base": "rsp", "disp": (m["disp"] + sp) & 0xFFFFFFFF}}})

    def here(target):
        # A position in the function, at its blob address.
        return f"{(off + sx(target - pos, 32)) & ((1 << 64) - 1):#x}"

    simple = {
        "pushRbp": ["push rbp"],
        "winPrologue": ["push rbp", "push rdi", "push rsi", "lea rbp,[rsp+0x10]"],
        "winEpilogue": ["lea rsp,[rbp-0x10]", "pop rsi", "pop rdi", "pop rbp"],
        "callRax": ["call rax"], "callMemRax": ["call QWORD PTR [rax]"], "jmpRax": ["jmp rax"],
        "testAl": ["test al,al"], "testRax": ["test rax,rax"], "leave": ["leave"],
        "ret": ["ret"], "ud2": ["ud2"], "int3": ["int3"],
        "loadTableEntry": ["movsxd rax,DWORD PTR [rcx+rax*4]"], "addRaxRcx": ["add rax,rcx"],
    }
    if name in simple:
        return simple[name]
    if name in ("subRsp", "addRsp"):
        return [f"{name[:3]} rsp,{imm(f['v'], 64)}"]
    if name == "setReg":
        r, v = f["r"], f["v"]
        return [[f"xor {reg(r, 32)},{reg(r, 32)}", f"mov {reg(r, 32)},{v:#x}",
                 f"mov {reg(r)},{v:#x}", f"movabs {reg(r)},{v:#x}"][set_form(v)]]
    if name == "lea":
        return [f"lea {reg(f['r'])},[rip+0x0]"]
    if name == "leaTable":
        # objdump prints a negative `rip` displacement as a 64-bit two's complement.
        return [f"lea rcx,[rip+{sx(f['t'] - (pos + 7), 32) & ((1 << 64) - 1):#x}]"]
    if name == "mov":
        return [f"mov {reg(f['dst'])},{reg(f['src'])}"]
    if name in ("call", "jmp"):
        return [f"{name} {off + 5:#x}"]
    if name == "callMem":
        return ["call QWORD PTR [rip+0x0]"]
    if name == "ctrInc":
        return ["inc QWORD PTR [rip+0x0]"]
    if name == "callR11":
        return [f"call QWORD PTR [r11{disp(sx(f['d'], 8))}]"]
    if name == "loadRip":
        return [f"mov {reg(f['dst'])},QWORD PTR [rip+0x0]"]
    if name == "branch":
        op = "jmp" if f["cond"] == "always" else "j" + CC[f["cond"]]
        return [f"{op} {here(f['target'])}"]
    if name == "nop":
        return [NOPS[f["n"]]]
    if name == "ld":
        b = BITS[f["w"]]
        if b <= 16:
            return [f"{'movsx' if f['sx'] else 'movzx'} {reg(f['dst'], 32)},{mem(f['m'], b)}"]
        return [f"mov {reg(f['dst'], b)},{mem(f['m'], b)}"]
    if name == "st":
        b = BITS[f["w"]]
        return [f"mov {mem(f['m'], b)},{reg(f['src'], b)}"]
    if name == "stImm":
        b = BITS[f["w"]]
        return [f"mov {mem(f['m'], b)},{imm(f['imm'], b)}"]
    if name == "leaM":
        return [f"lea {reg(f['dst'])},{mem(f['m'])}"]
    if name == "alu":
        b = BITS[f["w"]]
        return [f"{f['op']} {reg(f['reg'], b)},{rm(f['rm'], b)}"]
    if name == "aluImm":
        b = BITS[f["w"]]
        return [f"{f['op']} {rm(f['rm'], b)},{imm(f['imm'], b)}"]
    if name == "imul":
        b = BITS[f["w"]]
        return [f"imul {reg(f['reg'], b)},{rm(f['rm'], b)}"]
    if name == "imulImm":
        b = BITS[f["w"]]
        return [f"imul {reg(f['reg'], b)},{rm(f['rm'], b)},{imm(f['imm'], b)}"]
    if name == "shift":
        b = BITS[f["w"]]
        return [f"{f['op']} {reg(f['reg'], b)},{f['amt']:#x}"]
    if name == "setcc":
        return [f"set{CC[f['cond']]} {mem(f['m'], 8)}"]
    if name == "setccCl":
        return [f"set{CC[f['cond']]} cl"]
    if name == "mulQ":
        return [f"mul {rm(f['rm'], 64)}"]
    if name == "testM8":
        return [f"test {mem(f['m'], 8)},0xff"]
    if name == "sse":
        op, b = {4: ("movss", 32), 8: ("movsd", 64), 16: ("movups", 128)}[f["size"]]
        x, m = f"xmm{f['x']}", mem(f["m"], b)
        return [f"{op} {m},{x}" if f["st"] else f"{op} {x},{m}"]
    if name == "movd":
        x, r = f"xmm{f['x']}", reg(f["r"], 32)
        return [f"movd {x},{r}" if f["toXmm"] else f"movd {r},{x}"]
    raise ValueError(f"no rendering for {name}")


def normalize(text):
    text = text.split("#")[0].strip()
    return re.sub(r"\s+", " ", text).replace(" ,", ",")


def objdump(tool, blob):
    with tempfile.NamedTemporaryFile(suffix=".bin") as f:
        f.write(blob)
        f.flush()
        out = subprocess.run([tool, "-D", "-b", "binary", "-m", "i386:x86-64", "-M", "intel",
                              "--no-show-raw-insn", f.name], check=True, capture_output=True,
                             text=True).stdout
    lines = {}
    for line in out.splitlines():
        m = re.match(r"^\s*([0-9a-f]+):\t(.*)$", line)
        if m:
            lines[int(m.group(1), 16)] = normalize(m.group(2))
    return lines


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--objdump", default="objdump")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()

    src = VECTORS.read_text()
    vectors = json.loads(src[src.index('r#"') + 3:src.rindex('"#')])
    encs = [v for v in vectors if v["k"] == "enc" and not (isinstance(v["item"], dict) and "tableEntry" in v["item"])]

    # All the vectors in one blob, 16-aligned, separated by `int3`s.
    blob, placed = bytearray(), []
    for v in encs:
        b = bytes.fromhex(v["bytes"])
        placed.append((len(blob), len(b), v))
        blob += b
        blob += b"\xcc" * (16 - len(blob) % 16 + 16)
    lines = objdump(args.objdump, bytes(blob))

    bad = 0
    for off, n, v in placed:
        got, at = [], off
        while at < off + n and at in lines:
            got.append(lines[at])
            at = min((a for a in lines if a > at), default=off + n)
        if at != off + n:
            got.append(f"<instruction boundary at {at:#x}, item ends at {off + n:#x}>")
        want = [normalize(x) for x in render(v["item"], v["pos"], off, n, v["sp"])]
        if got != want:
            bad += 1
            print(f"MISMATCH {json.dumps(v['item'])} sp={v['sp']} bytes={v['bytes']}\n"
                  f"  objdump: {got}\n  item:    {want}")
        elif args.verbose:
            print(f"ok {want}")

    # The OSR code: outside the table, only the forms of osr.rs.
    allowed = re.compile(
        r"^(lea r11,\[rip\+0x[0-9a-f]+\]|movsxd rax,DWORD PTR \[r11\+rax\*4\]|add rax,r11|jmp rax"
        r"|int3|ret|pop rcx|lea (rsp|rdx),\[(rbp|rdx|rsp)[+-]0x[0-9a-f]+\]"
        r"|mov (al|ax|eax|rax),(BYTE|WORD|DWORD|QWORD) PTR \[(rbp|rdx|rsp)[+-]0x[0-9a-f]+\]"
        r"|mov (BYTE|WORD|DWORD|QWORD) PTR \[(rbp|rdx|rsp)[+-]0x[0-9a-f]+\],(al|ax|eax|rax)"
        r"|mov eax,0x[0-9a-f]+|call 0x[0-9a-f]+|jmp 0x[0-9a-f]+"
        r"|movabs r11,0x0|call r11)$")
    osr = [v for v in vectors if v["k"] == "osr"]
    for v in osr:
        code = bytes.fromhex(v["code"])
        table, n = 16, len(v["entries"])
        for lo, hi in [(0, table), (table + 4 * n, len(code))]:
            if lo >= hi:
                continue
            got = objdump(args.objdump, code[lo:hi]).values()
            wrong = [g for g in got if not allowed.match(g)]
            if wrong:
                bad += 1
                print(f"OSR MISMATCH at {v['at']}: {wrong}")

    # The JIT entry prefix and the registry constructors (install.rs, objfile.rs).
    fixed = [
        ("4c8d1d050000004c891c24c3", ["lea r11,[rip+0x5]", "mov QWORD PTR [rsp],r11", "ret"]),
        ("488d3d00000000be03000000e900000000", ["lea rdi,[rip+0x0]", "mov esi,0x3", "jmp 0x11"]),
        ("488d0d00000000ba00000000e900000000", ["lea rcx,[rip+0x0]", "mov edx,0x0", "jmp 0x11"]),
        ("488d0d00000000ba70110100ff2500000000",
         ["lea rcx,[rip+0x0]", "mov edx,0x11170", "jmp QWORD PTR [rip+0x0]"]),
    ]
    for hx, want in fixed:
        got = list(objdump(args.objdump, bytes.fromhex(hx)).values())
        if got != want:
            bad += 1
            print(f"MISMATCH {hx}\n  objdump: {got}\n  want:    {want}")

    print(f"{len(placed)} item vectors, {len(osr)} OSR vectors, {len(fixed)} fixed vectors: "
          f"{bad} mismatches")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
