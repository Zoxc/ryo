//! Instruction emission helpers: opcode selection by family and width, immediate operands.
//!
//! The families ([`IntOp`], [`FloatOp`]) and their tables come from the opcode list in
//! `ryo_bytecode` (`ops.rs`); a missing combination is `None` there, and a lowering bug that
//! panics with the mnemonic here.

use ryo_bytecode::full::Opcode;
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
