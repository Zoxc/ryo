//! The reduced instruction set (design/vm.md, "Reduced instructions"): the subset of the full
//! set ([`crate::full`]) that runs as native code, the inline instructions and the shapes
//! without a handler, with the same operands, plus `handler` for every handler call: the
//! full opcode whose handler it calls, the values of its argument registers and the control
//! flow after the call.
//!
//! Generated from the list in `src/reduced_ops.rs` like the full set from `src/ops.rs`:
//! [`Opcode`], [`OP_INFO`], the decoded [`Insn`], its decoder, encoder and disassembly, in the
//! same word encoding. [`Opcode::full`] and [`Opcode::of_full`] map between the sets.
//! [`crate::asm::reduce`] maps full code to it, and [`crate::asm::decode_reduced`] reads
//! machine code back to it.

use core::fmt;

#[cfg(feature = "alloc")]
use alloc::vec::Vec;

use crate::full::{self, Const, Data, DecodeError, Elem, ElemKind, Operand, OperandInfo, OperandKind, Site, Sym, fixed_len, str_eq};

/// The handler a reduced `handler` calls: `ryo_h_<op>`, `op` a full opcode with a handler.
/// Displayed as its mnemonic.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Handler(pub full::Opcode);

impl<'a> Operand<'a> for Handler {
    const KIND: OperandKind = OperandKind::Handler;
    #[inline]
    fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
        let v = *w.get(*pos).ok_or(DecodeError::Truncated)?;
        *pos += 1;
        match u16::try_from(v).ok().and_then(full::Opcode::from_u16) {
            Some(op) if crate::asm::has_handler(op) => Ok(Handler(op)),
            _ => Err(DecodeError::BadOperand(v)),
        }
    }
    #[cfg(feature = "alloc")]
    fn write(&self, out: &mut Vec<u32>) {
        out.push(self.0 as u32);
    }
}

impl fmt::Display for Handler {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.0.mnemonic())
    }
}

/// A handler argument register's value. Three words: a tag, then a 64-bit value, low word
/// first.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Arg {
    /// `fp`.
    Fp,
    /// The exception object of a landing pad (`rax`).
    Exception,
    Imm(u64),
    /// The address of a constant.
    Const(Const),
    /// The address in the data area.
    Data(Data),
    /// The address of a symbol slot.
    Sym(Sym),
    /// The address of a site cache slot.
    Site(Site),
    /// The address of the code constant at this offset in the function's rodata (case
    /// values).
    Ro(u32),
}

impl Elem for Arg {
    const KIND: ElemKind = ElemKind::Arg;
    fn get(w: &[u32]) -> Self {
        let v = w[1] as u64 | (w[2] as u64) << 32;
        match w[0] {
            0 => Arg::Fp,
            1 => Arg::Exception,
            2 => Arg::Imm(v),
            3 => Arg::Const(Const(v as u32)),
            4 => Arg::Data(Data(v as u32)),
            5 => Arg::Sym(Sym(v as u32)),
            6 => Arg::Site(Site(v as u32)),
            // 7, and unknown tags (which `valid` rejects).
            _ => Arg::Ro(v as u32),
        }
    }
    #[cfg(feature = "alloc")]
    fn put(&self, out: &mut Vec<u32>) {
        out.extend(self.words());
    }
    fn fmt_elem(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Arg::Fp => f.write_str("fp"),
            Arg::Exception => f.write_str("exc"),
            Arg::Imm(v) => write!(f, "{v:#x}"),
            Arg::Const(k) => fmt::Display::fmt(k, f),
            Arg::Data(d) => fmt::Display::fmt(d, f),
            Arg::Sym(s) => fmt::Display::fmt(s, f),
            Arg::Site(s) => fmt::Display::fmt(s, f),
            Arg::Ro(o) => write!(f, "ro{o}"),
        }
    }
    fn valid(w: &[u32]) -> bool {
        // `get` maps every word triple to some `Arg`; the canonical ones (known tag, no
        // stray value bits) are those it round-trips.
        Self::get(w).words() == w[..3]
    }
}

impl Arg {
    /// The encoding `get` reads: the tag, then the value, low word first.
    fn words(&self) -> [u32; 3] {
        let (tag, v) = match *self {
            Arg::Fp => (0, 0),
            Arg::Exception => (1, 0),
            Arg::Imm(v) => (2, v),
            Arg::Const(k) => (3, k.0 as u64),
            Arg::Data(d) => (4, d.0 as u64),
            Arg::Sym(s) => (5, s.0 as u64),
            Arg::Site(s) => (6, s.0 as u64),
            Arg::Ro(o) => (7, o as u64),
        };
        [tag, v as u32, (v >> 32) as u32]
    }
}

include!("reduced_ops.rs");

impl Opcode {
    /// The full opcode of the same instruction, `None` for `handler`.
    pub const fn full(self) -> Option<full::Opcode> {
        let f = TO_FULL[self as usize];
        if f == u16::MAX { None } else { full::Opcode::from_u16(f) }
    }

    /// The reduced opcode of the full opcode `op`, if it is in the reduced set.
    pub const fn of_full(op: full::Opcode) -> Option<Opcode> {
        let r = OF_FULL[op as usize];
        if r == u16::MAX { None } else { Opcode::from_u16(r) }
    }
}

/// By reduced opcode, the full one of the same mnemonic (`u16::MAX` for none). The lists
/// are in the same order, so the search goes on from the last match.
static TO_FULL: [u16; Opcode::COUNT] = {
    let mut out = [u16::MAX; Opcode::COUNT];
    let mut i = 0;
    let mut from = 0;
    while i < Opcode::COUNT {
        let mut j = from;
        while j < full::Opcode::COUNT {
            if str_eq(OP_INFO[i].mnemonic, full::OP_INFO[j].mnemonic) {
                out[i] = j as u16;
                from = j + 1;
                break;
            }
            j += 1;
        }
        i += 1;
    }
    out
};

/// By full opcode, the reduced one of the same mnemonic (`u16::MAX` for none).
static OF_FULL: [u16; full::Opcode::COUNT] = {
    let mut out = [u16::MAX; full::Opcode::COUNT];
    let mut i = 0;
    while i < Opcode::COUNT {
        if TO_FULL[i] != u16::MAX {
            out[TO_FULL[i] as usize] = i as u16;
        }
        i += 1;
    }
    out
};
