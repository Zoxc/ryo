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

use crate::full::{Opcode, OperandKind};

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

/// The bytes of a width segment of a mnemonic (`w8` … `w128`, `f32`, `f64`).
fn bytes(seg: &str) -> Option<u8> {
    Some(match seg {
        "w8" => 1,
        "w16" => 2,
        "w32" => 4,
        "w64" => 8,
        "w128" => 16,
        "f32" => 4,
        "f64" => 8,
        _ => return None,
    })
}

/// The effects of `op`'s handler. `None` for opcodes without one.
pub fn effects(op: Opcode) -> Option<Effects> {
    if !crate::asm::has_handler(op) {
        return None;
    }
    let info = op.info();
    let m = info.mnemonic;
    let segs = || m.split('.');
    let first = segs().next().unwrap_or("");
    // The widths in the mnemonic, in order (`zext.w8.w32`: 1, then 4).
    let mut ws = [0u8; 2];
    let mut nw = 0;
    for s in segs() {
        if let Some(b) = bytes(s)
            && nw < 2
        {
            ws[nw] = b;
            nw += 1;
        }
    }
    let n = ws[0];
    let mut out = Effects { opnds: [None; crate::asm::MAX_OPERANDS], memory: false };
    let compare = matches!(first, "eq" | "ne" | "lt" | "le" | "gt" | "ge" | "feq" | "fne" | "flt" | "fle" | "cmp3");
    for (i, o) in info.operands.iter().enumerate() {
        if !matches!(o.kind, OperandKind::Slot | OperandKind::Mem) {
            continue;
        }
        use Effect::*;
        let e = match (first, o.name) {
            // `Mem`: the pointer slot.
            (_, "m") => Read(8),
            ("copy" | "const" | "zero" | "fill" | "load" | "store", "d" | "s") if nw == 0 => Block,
            ("addr", "s") => Addr,
            ("addr" | "ptr", "d") => Write(8),
            (_, "p" | "i" | "dp" | "sp" | "n") => Read(8),
            ("memset", "b") => Read(1),
            ("lpad", "x") => Write(8),
            ("resume", "x") => Read(8),
            ("br", "s") => Read(1),
            ("ctpop" | "ctlz" | "cttz" | "discr", "d") => Write(4),
            ("set_discr", "d") => Update(n),
            ("rotl" | "rotr", "b") => Read(4),
            ("zext" | "sext" | "trunc" | "cvt", "s") => Read(ws[0]),
            ("zext" | "sext" | "trunc" | "cvt", "d") => Write(ws[1]),
            (_, "o") => Write(1),
            (_, "d") if compare => Write(1),
            (_, "d") => Write(n),
            _ if n != 0 => Read(n),
            _ => return None,
        };
        out.opnds[i] = Some(e);
    }
    out.memory = matches!(first, "load" | "store" | "memcpy" | "memmove" | "memset" | "atomic" | "fence" | "compiler_fence");
    Some(out)
}
