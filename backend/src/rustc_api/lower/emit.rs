//! Instruction emission: opcode selection by name and width, raw encoding, and the final
//! pass over a function's code (slots to signed frame offsets).
//!
//! Opcodes are looked up by their `Opcode` variant name (`"AddW32"`, `"LoadW64Z"`), built
//! from a family name and a [`Width`]. The opcode list in `ryo_bytecode` (`ops.rs`) is the
//! single source of truth, so a missing combination is a lowering bug that shows up as a
//! panic with the name, not as a wrong encoding.

use std::sync::LazyLock;

use rustc_data_structures::fx::FxHashMap;
use ryo_bytecode::insn::{ALL_OPCODES, ElemKind, Opcode, OperandKind, insn_len};

use super::frame;

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
    pub fn suffix(self) -> String {
        format!("W{}", self.bits())
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
    opcode(&format!("{family}{}", w.suffix()))
}

/// Encodes the words of an immediate of width `w`.
pub fn imm_words(w: Width, v: u128) -> Vec<u32> {
    (0..w.imm_words()).map(|i| (v >> (32 * i)) as u32).collect()
}

/// Rewrites every slot the lowering handed out (biased, or relative to the outgoing block,
/// `frame.rs`) to its signed frame offset in a frame of size `frame_size`: slots, memory
/// operand bases and island operand words.
pub fn finish_slots(code: &mut [u32], frame_size: u32) {
    let fix = |w: &mut u32| *w = frame::frame_offset(*w, frame_size) as u32;
    let mut at = 0;
    while at < code.len() {
        let len = insn_len(&code[at..]).expect("lowered code decodes");
        let op = Opcode::from_u16(code[at] as u16).unwrap();
        let mut pos = at + 1;
        for o in op.info().operands {
            match o.kind {
                OperandKind::Slot | OperandKind::Mem => fix(&mut code[pos]),
                OperandKind::List(ElemKind::Word) => {
                    let n = code[pos] as usize;
                    for w in &mut code[pos + 1..pos + 1 + n] {
                        fix(w);
                    }
                }
                OperandKind::U8
                | OperandKind::U16
                | OperandKind::U32
                | OperandKind::U64
                | OperandKind::I64
                | OperandKind::U128
                | OperandKind::Const
                | OperandKind::Abs
                | OperandKind::Sym
                | OperandKind::Site
                | OperandKind::Func
                | OperandKind::Target
                | OperandKind::Neg
                | OperandKind::List(
                    ElemKind::Target
                    | ElemKind::Case8
                    | ElemKind::Case16
                    | ElemKind::Case32
                    | ElemKind::Case64
                    | ElemKind::Case128,
                ) => {}
            }
            pos += match o.kind {
                OperandKind::List(e) => 1 + code[pos] as usize * e.words(),
                k => k.words().unwrap(),
            };
        }
        debug_assert_eq!(pos - at, len);
        at += len;
    }
}
