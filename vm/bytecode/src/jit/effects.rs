//! The exact frame effects of the handlers (design/jit.md, "The SSA tier"): for each operand
//! of a handler that names a frame slot, how many bytes the handler reads or writes there.
//! `asm::frame` over-estimates them (16 bytes, never killing); the SSA tier needs them exact
//! to keep frame slots in registers across handler calls.
//!
//! The table is by family, from the mnemonic, mirroring the handler kinds of `ryo_rt`'s
//! `handlers.rs` (whose bodies read `get!(T, …)` and write `put!(…, v: T)` at `T`'s size).
//! `vm/rt/tests/ops.rs` checks it against the handlers themselves: each handler run on a
//! frame filled with a pattern writes only the bytes the table says, and depends only on the
//! bytes it says it reads.

use crate::asm::{ARG_REGS, Mode};
use crate::full::{Opcode, OperandKind, Shape, str_eq};

/// How a handler uses one of its frame operands (`Slot`, or the pointer slot of a `Mem`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Effect {
    /// Reads exactly `n` bytes at the slot.
    Read(u8),
    /// Writes exactly `n` bytes at the slot, whatever was there.
    Write(u8),
    /// May write `n` bytes at the slot, or leave them (`set_discr` of the untagged variant):
    /// a read and a write.
    Update(u8),
    /// Takes the slot's address (`addr`): the object escapes.
    Addr,
    /// Reads or writes a length the operands give (`copy`, `const`, `zero`, `fill`,
    /// `load.copy`, `store.copy`): its object can't be promoted.
    Block,
}

/// A handler's effects: per operand index, the frame effect of a frame operand (`None` for
/// the others), and whether it reads or writes memory through a pointer, or orders memory
/// accesses (loads, stores, atomics, fences).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Effects {
    pub opnds: [Option<Effect>; crate::asm::MAX_OPERANDS],
    pub memory: bool,
}

/// The bytes of a width segment of a mnemonic (`w8` … `w128`, `f32`, `f64`, and the pointer
/// atomics' `ptr`).
const fn bytes(seg: &str) -> Option<u8> {
    const W: [(&str, u8); 8] = [("ptr", 8), ("w8", 1), ("w16", 2), ("w32", 4), ("w64", 8), ("w128", 16), ("f32", 4), ("f64", 8)];
    let mut i = 0;
    while i < W.len() {
        if str_eq(W[i].0, seg) {
            return Some(W[i].1);
        }
        i += 1;
    }
    None
}

/// Whether `s` is one of `set`.
const fn any(s: &str, set: &[&str]) -> bool {
    let mut i = 0;
    while i < set.len() {
        if str_eq(s, set[i]) {
            return true;
        }
        i += 1;
    }
    false
}

/// `s[from..to]` (mnemonics are ASCII).
const fn sub(s: &str, from: usize, to: usize) -> &str {
    let (_, rest) = s.as_bytes().split_at(from);
    let (seg, _) = rest.split_at(to - from);
    match core::str::from_utf8(seg) {
        Ok(seg) => seg,
        Err(_) => "",
    }
}

/// The effects of `op`'s handler. `None` for opcodes without one. A `const fn`, so that
/// `ryo_rt` generates the register entries from it ([`reg_entry`]).
pub const fn effects(op: Opcode) -> Option<Effects> {
    if !crate::asm::has_handler(op) {
        return None;
    }
    let info = op.info();
    let m = info.mnemonic;
    let mb = m.as_bytes();
    // The first segment, and the widths in the mnemonic, in order (`zext.w8.w32`: 1, then 4).
    let mut first = "";
    let mut ws = [0u8; 2];
    let mut nw = 0;
    let (mut at, mut i) = (0, 0);
    while i <= mb.len() {
        if i == mb.len() || mb[i] == b'.' {
            let seg = sub(m, at, i);
            if at == 0 {
                first = seg;
            }
            if let Some(b) = bytes(seg)
                && nw < 2
            {
                ws[nw] = b;
                nw += 1;
            }
            at = i + 1;
        }
        i += 1;
    }
    let n = ws[0];
    let mut out = Effects { opnds: [None; crate::asm::MAX_OPERANDS], memory: false };
    let compare = any(first, &["eq", "ne", "lt", "le", "gt", "ge", "feq", "fne", "flt", "fle", "cmp3"]);
    let ext = any(first, &["zext", "sext", "trunc", "cvt"]);
    let mut k = 0;
    while k < info.operands.len() {
        let o = info.operands[k];
        k += 1;
        if !matches!(o.kind, OperandKind::Slot | OperandKind::Mem) {
            continue;
        }
        use Effect::*;
        let (f, name) = (first, o.name);
        let e = if str_eq(name, "m") {
            // `Mem`: the pointer slot.
            Read(8)
        } else if any(f, &["copy", "const", "zero", "fill", "load", "store"]) && any(name, &["d", "s"]) && nw == 0 {
            Block
        } else if str_eq(f, "addr") && str_eq(name, "s") {
            Addr
        } else if any(f, &["addr", "ptr"]) && str_eq(name, "d") {
            Write(8)
        } else if any(name, &["p", "i", "dp", "sp", "n"]) {
            Read(8)
        } else if str_eq(f, "memset") && str_eq(name, "b") {
            Read(1)
        } else if str_eq(f, "lpad") && str_eq(name, "x") {
            Write(8)
        } else if str_eq(f, "resume") && str_eq(name, "x") {
            Read(8)
        } else if str_eq(f, "br") && str_eq(name, "s") {
            Read(1)
        } else if any(f, &["ctpop", "ctlz", "cttz", "discr"]) && str_eq(name, "d") {
            Write(4)
        } else if str_eq(f, "set_discr") && str_eq(name, "d") {
            Update(n)
        } else if any(f, &["rotl", "rotr"]) && str_eq(name, "b") {
            Read(4)
        } else if ext && str_eq(name, "s") {
            Read(ws[0])
        } else if ext && str_eq(name, "d") {
            Write(ws[1])
        } else if str_eq(name, "o") {
            Write(1)
        } else if str_eq(name, "d") && compare {
            Write(1)
        } else if str_eq(name, "d") {
            Write(n)
        } else if n != 0 {
            Read(n)
        } else {
            return None;
        };
        out.opnds[k - 1] = Some(e);
    }
    out.memory = any(first, &["load", "store", "memcpy", "memmove", "memset", "atomic", "fence", "compiler_fence"]);
    Some(out)
}

/// A handler's register entry (design/jit.md, "Register entries"): the handler body with its
/// frame operands in registers instead of frame slots, for the SSA tier. Like the frame entry
/// it is `extern "sysv64-unwind" fn(a0, …, a5: u64)`, and it returns `(u64, u64)` in
/// `rax`, `rdx`. It takes, in `rdi`, `rsi`, … in this order:
/// - the values of the frame operands it reads ([`RegEntry::ins`], by operand index, in operand
///   order), each in the low bytes of its register;
/// - then whole the frame entry's argument registers that hold anything but slot offsets
///   ([`RegEntry::data`], by register index from `rdi`, the frame entry's `fp` excluded):
///   immediates, addresses, a `Mem` operand's displacement. Their slot offset halves, if any,
///   are ignored.
///
/// It returns the values of the frame operands it writes ([`RegEntry::outs`], in operand
/// order), then with [`RegEntry::ret`] the frame entry's return value (`br`, `switch`), in
/// `rax`, then `rdx`: a value's low bytes, the rest unspecified. It takes no `fp`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct RegEntry {
    pub ins: [u8; ARG_REGS],
    pub nin: u8,
    pub data: [u8; ARG_REGS],
    pub ndata: u8,
    pub outs: [u8; 2],
    pub nout: u8,
    pub ret: bool,
}

impl RegEntry {
    /// No register entry.
    pub const NONE: RegEntry = RegEntry { ins: [0; ARG_REGS], nin: 0, data: [0; ARG_REGS], ndata: 0, outs: [0; 2], nout: 0, ret: false };
}

/// `op`'s register entry in `mode` (whose register layout gives the data registers), if it
/// has one: a handler that returns (`op`, `br` and `switch` shapes; not `resume`), whose frame
/// operands are all read, written or updated at 1 to 8 bytes (no `addr`, no blocks, no
/// `w128`), whose inputs and data registers fit the six argument registers and whose outputs
/// and return value fit `rax` and `rdx`. Others keep only their frame entry.
pub const fn reg_entry(op: Opcode, mode: Mode) -> Option<RegEntry> {
    let info = op.info();
    if !matches!(info.shape, Shape::Op | Shape::Br | Shape::Switch) || matches!(op, Opcode::Resume) {
        return None;
    }
    let Some(e) = effects(op) else { return None };
    let l = crate::asm::layout(op, mode);
    let mut r = RegEntry::NONE;
    r.ret = !matches!(info.shape, Shape::Op);
    let mut data = [false; ARG_REGS];
    let mut nout = r.ret as usize;
    let mut k = 0;
    while k < info.operands.len() {
        let o = info.operands[k];
        let loc = l.locs[k];
        let (reads, writes) = match (o.kind, e.opnds[k]) {
            (OperandKind::Slot | OperandKind::Mem, Some(Effect::Read(n))) if n <= 8 => (true, false),
            (OperandKind::Slot | OperandKind::Mem, Some(Effect::Write(n))) if n <= 8 => (false, true),
            (OperandKind::Slot | OperandKind::Mem, Some(Effect::Update(n))) if n <= 8 => (true, true),
            (OperandKind::Slot | OperandKind::Mem, _) => return None,
            _ => (false, false),
        };
        if reads {
            if r.nin as usize == ARG_REGS {
                return None;
            }
            r.ins[r.nin as usize] = k as u8;
            r.nin += 1;
        }
        if writes {
            if nout == 2 {
                return None;
            }
            r.outs[r.nout as usize] = k as u8;
            r.nout += 1;
            nout += 1;
        }
        // The registers holding anything but a slot offset: a `Mem` operand's displacement
        // register, every register of the other operands.
        let mut p = 0;
        while p < loc.count {
            if !matches!(o.kind, OperandKind::Slot) && !(matches!(o.kind, OperandKind::Mem) && p == 0) {
                data[(loc.reg + p) as usize] = true;
            }
            p += 1;
        }
        k += 1;
    }
    let mut g = 0;
    while g < ARG_REGS {
        if data[g] {
            if (r.nin + r.ndata) as usize == ARG_REGS {
                return None;
            }
            r.data[r.ndata as usize] = g as u8;
            r.ndata += 1;
        }
        g += 1;
    }
    Some(r)
}
