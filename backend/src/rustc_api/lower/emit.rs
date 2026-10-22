//! Instruction emission helpers: opcode selection by name and width, immediate operands.
//!
//! Opcodes are looked up by their `Opcode` variant name (`"AddW32"`, `"BrLtUImmW64"`), built
//! from a family name and a [`Width`]. The opcode list in `ryo_bytecode` (`ops.rs`) is the
//! single source of truth, so a missing combination is a lowering bug that shows up as a
//! panic with the name, not as a wrong encoding.

use std::sync::LazyLock;

use rustc_data_structures::fx::FxHashMap;
use ryo_bytecode::full::{ALL_OPCODES, Opcode};


/// Integer operand widths of the instruction set.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Width {
    W8,
    W16,
    W32,
    W64,
    W128,
}

impl Width {
    /// The width of a scalar of `size` bytes, if the VM has one.
    pub fn of_size(size: u64) -> Option<Width> {
        Some(match size {
            1 => Width::W8,
            2 => Width::W16,
            4 => Width::W32,
            8 => Width::W64,
            16 => Width::W128,
            _ => return None,
        })
    }

    pub fn bits(self) -> u32 {
        match self {
            Width::W8 => 8,
            Width::W16 => 16,
            Width::W32 => 32,
            Width::W64 => 64,
            Width::W128 => 128,
        }
    }

    pub fn bytes(self) -> u32 {
        self.bits() / 8
    }

    /// The opcode-name suffix: `W32`.
    pub fn suffix(self) -> &'static str {
        match self {
            Width::W8 => "W8",
            Width::W16 => "W16",
            Width::W32 => "W32",
            Width::W64 => "W64",
            Width::W128 => "W128",
        }
    }

    /// Words an immediate of this width takes (`U32` for widths up to 32).
    pub fn imm_words(self) -> usize {
        match self {
            Width::W8 | Width::W16 | Width::W32 => 1,
            Width::W64 => 2,
            Width::W128 => 4,
        }
    }

    /// `v` truncated to this width.
    pub fn truncate(self, v: u128) -> u128 {
        if self == Width::W128 { v } else { v & ((1u128 << self.bits()) - 1) }
    }
}

/// Float formats the VM implements (`f16` and `f128` are islands).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum FloatWidth {
    F32,
    F64,
}

impl FloatWidth {
    pub fn suffix(self) -> &'static str {
        match self {
            FloatWidth::F32 => "F32",
            FloatWidth::F64 => "F64",
        }
    }
}

static BY_NAME: LazyLock<FxHashMap<String, Opcode>> =
    LazyLock::new(|| ALL_OPCODES.iter().map(|&op| (format!("{op:?}"), op)).collect());

/// The opcode whose `Opcode` variant is called `name`, if there is one.
pub fn try_opcode(name: &str) -> Option<Opcode> {
    BY_NAME.get(name).copied()
}

/// The opcode whose `Opcode` variant is called `name`.
pub fn opcode(name: &str) -> Opcode {
    try_opcode(name).unwrap_or_else(|| panic!("ryo lowering: no opcode `{name}`"))
}

/// `family` at width `w`: `opw("Add", W32)` is `AddW32`.
pub fn opw(family: &str, w: Width) -> Opcode {
    // The name on the stack: this runs for most instructions.
    let mut buf = [0u8; 64];
    let (f, su) = (family.as_bytes(), w.suffix().as_bytes());
    buf[..f.len()].copy_from_slice(f);
    buf[f.len()..f.len() + su.len()].copy_from_slice(su);
    opcode(std::str::from_utf8(&buf[..f.len() + su.len()]).expect("ASCII"))
}

/// Encodes the words of an immediate of width `w`.
pub fn imm_words(w: Width, v: u128) -> Vec<u32> {
    (0..w.imm_words()).map(|i| (v >> (32 * i)) as u32).collect()
}
