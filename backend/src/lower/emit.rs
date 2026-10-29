//! Instruction emission helpers: opcode selection by family and width, immediate operands.
//!
//! The families ([`IntOp`], [`FloatOp`]) and their tables come from the opcode list in
//! `ryo_bytecode` (`full_ops.rs`); a missing combination is `None` there, and a lowering bug that
//! panics with the mnemonic here.

use ryo_bytecode::full::Opcode;

use super::FnCx;
pub use ryo_bytecode::full::{FloatOp, FloatWidth, IntOp, Width};

/// `family` at width `w`: `opw(IntOp::Add, W32)` is `AddW32`.
pub fn opw(family: IntOp, w: Width) -> Opcode {
    family.at(w).unwrap_or_else(|| panic!("ryo lowering: no opcode {}.{}", family.stem(), w.mnemonic()))
}

/// `family` at format `f`: `opf(FloatOp::Fadd, F64)` is `FaddF64`.
pub fn opf(family: FloatOp, f: FloatWidth) -> Opcode {
    family.at(f).unwrap_or_else(|| panic!("ryo lowering: no opcode {}.{}", family.stem(), f.mnemonic()))
}

/// The operands `head` (at most 2) followed by the words of an immediate `v` of width `w`, in
/// a stack buffer: `&buf[..len]`.
pub fn imm_ops(head: &[u32], w: Width, v: u128) -> ([u32; 6], usize) {
    let mut buf = [0; 6];
    buf[..head.len()].copy_from_slice(head);
    let n = w.imm_words();
    for i in 0..n {
        buf[head.len() + i] = (v >> (32 * i)) as u32;
    }
    (buf, head.len() + n)
}

impl FnCx<'_, '_> {
    /// Stores an immediate of width `w` into slot `d`.
    pub fn imm(&mut self, w: Width, d: u32, v: u128) {
        let (ops, n) = imm_ops(&[d], w, v);
        self.op(opw(IntOp::Imm, w), &ops[..n]);
    }

    /// `family.imm.w d, a, v`, `v` truncated to the width.
    pub fn op_imm(&mut self, family: IntOp, w: Width, d: u32, a: u32, v: u128) {
        let (ops, n) = imm_ops(&[d, a], w, w.truncate(v));
        self.op(family.imm_at(w).unwrap_or_else(|| panic!("ryo lowering: no opcode {}.imm.{}", family.stem(), w.mnemonic())), &ops[..n]);
    }
}
