//! Instruction emission helpers: opcode selection by family and width, immediate operands.
//!
//! The families ([`IntOp`], [`FloatOp`]) and their tables come from the opcode list in
//! `ryo_bytecode` (`ops.rs`); a missing combination is `None` there, and a lowering bug that
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

/// Encodes the words of an immediate of width `w`.
pub fn imm_words(w: Width, v: u128) -> Vec<u32> {
    (0..w.imm_words()).map(|i| (v >> (32 * i)) as u32).collect()
}

impl FnCx<'_, '_> {
    /// Stores an immediate of width `w` into slot `d`.
    pub fn imm(&mut self, w: Width, d: u32, v: u128) {
        let mut ops = vec![d];
        ops.extend(imm_words(w, v));
        self.op(opw(IntOp::Imm, w), &ops);
    }

    /// `family.imm.w d, a, v`, `v` truncated to the width.
    pub fn op_imm(&mut self, family: IntOp, w: Width, d: u32, a: u32, v: u128) {
        let mut ops = vec![d, a];
        ops.extend(imm_words(w, w.truncate(v)));
        self.op(family.imm_at(w).unwrap_or_else(|| panic!("ryo lowering: no opcode {}.imm.{}", family.stem(), w.mnemonic())), &ops);
    }
}
