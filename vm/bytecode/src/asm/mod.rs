//! The x86-64 form of VM code (design/vm.md, "Encoding"): every instruction is a call of its
//! handler `ryo_h_<Opcode>` with its operands in argument registers, followed by the control
//! flow its [`Shape`] gives it.
//!
//! - [`layout`] (here, `core` only): which argument register holds which operand. The
//!   handlers in `ryo_rt` read their operands through it, and the encoder writes them through
//!   it.
//! - `x86` (`alloc`): the canonical machine-code sequences the encoder emits and the decoder
//!   accepts.
//! - [`encode`] / [`decode`] (`alloc`): instruction words to machine code and back. The
//!   decoder is the encoder's test oracle: `decode(encode(f)) == f`, frame size and unwind
//!   entries included.
//! - [`lsda`] (`alloc`): the call-site table of a function's LSDA.
//!
//! # Operands and registers
//!
//! A handler takes up to six operand registers, `rdi, rsi, rdx, rcx, r8, r9`, in operand
//! order (the `sysv64` convention on every target). An operand takes one register, except
//! `Mem` (`p`, `k`), `U128` (low, high) and a case list (values, count), which take two.
//! The handler finds `fp` in `rbp`, or with [`Mode::fp_arg`] in `rdi`, before the operands.
//! If an opcode has more operands than registers, adjacent 32-bit operands (`Slot`, `U8`,
//! `U16`, `U32`) share one, `a | b << 32`, pairing from the last pair.

#[cfg(feature = "alloc")]
mod decode;
#[cfg(feature = "alloc")]
mod encode;
#[cfg(feature = "alloc")]
pub mod lsda;
#[cfg(feature = "alloc")]
mod x86;

#[cfg(feature = "alloc")]
pub use decode::{AsmError, Decoded, decode};
#[cfg(feature = "alloc")]
pub use encode::{Asm, CallSite, EncodeError, Encoded, InsnId, Label, Opnd, PROBE_FROM, Ref, Reloc, Unwind, encode, operands};

use crate::insn::{ElemKind, Opcode, OperandKind, Shape};

/// The argument registers handlers take: `rdi, rsi, rdx, rcx, r8, r9`.
pub const ARG_REGS: usize = 6;

/// The most operands an opcode has.
pub const MAX_OPERANDS: usize = 8;

/// How the machine code is generated, which the handlers must agree with.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Mode {
    /// Handlers take `fp` in `rdi` (before the operands) instead of reading `rbp`.
    pub fp_arg: bool,
    /// Backward branch targets are padded to 16 bytes.
    pub align_loops: bool,
    /// The target is PE/COFF: islands take the Win64 convention (`rcx`, `rdx`, 32 bytes of
    /// shadow space).
    pub pe: bool,
}

/// Where a handler finds an operand: `count` argument registers from `reg` (0 is `rdi`),
/// the first shifted right by `shift` (32 for the high half of a shared register). `count`
/// is 0 for operands handlers don't receive (branch targets, call targets, polarities).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Loc {
    pub reg: u8,
    pub shift: u8,
    pub count: u8,
    /// The register holds another operand too (a 32-bit pair).
    pub shared: bool,
}

impl Loc {
    const NONE: Loc = Loc { reg: 0, shift: 0, count: 0, shared: false };
}

/// The argument registers of an instruction's handler call.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Layout {
    /// Each operand's location, by its index in the opcode's operand list.
    pub locs: [Loc; MAX_OPERANDS],
    /// The first operand register: 1 with [`Mode::fp_arg`] (`rdi` is `fp`), one more for
    /// `lpad` (the exception object).
    pub first: u8,
    /// The registers the handler call sets, `fp` and the exception object included.
    pub regs: u8,
}

impl Layout {
    /// The location of the operand called `name`.
    pub const fn loc(&self, op: Opcode, name: &str) -> Loc {
        self.locs[crate::insn::operand_index_const(op, name)]
    }
}

/// Registers an operand of kind `k` takes.
pub const fn kind_regs(k: OperandKind) -> u8 {
    match k {
        OperandKind::Slot
        | OperandKind::U8
        | OperandKind::U16
        | OperandKind::U32
        | OperandKind::U64
        | OperandKind::I64
        | OperandKind::Const
        | OperandKind::Abs
        | OperandKind::Sym
        | OperandKind::Site
        | OperandKind::List(ElemKind::Target | ElemKind::Word) => 1,
        OperandKind::Mem
        | OperandKind::U128
        | OperandKind::List(ElemKind::Case8 | ElemKind::Case16 | ElemKind::Case32 | ElemKind::Case64 | ElemKind::Case128) => 2,
        OperandKind::Func | OperandKind::Target | OperandKind::Neg => 0,
    }
}

/// Whether an operand of kind `k` is 32 bits, so it may share a register.
const fn shareable(k: OperandKind) -> bool {
    matches!(k, OperandKind::Slot | OperandKind::U8 | OperandKind::U16 | OperandKind::U32)
}

/// Whether `shape`'s handler receives operand `name`. The call shapes pass only what the
/// handler resolves; the rest goes to the call sequence around it.
const fn passed(shape: Shape, name: &str) -> bool {
    const fn eq(a: &str, b: &str) -> bool {
        crate::insn::str_eq(a, b)
    }
    match shape {
        Shape::Op | Shape::Br | Shape::Switch | Shape::Trap | Shape::Ret | Shape::Lpad => true,
        Shape::Jmp | Shape::Call | Shape::Island => false,
        Shape::CallExt => eq(name, "sym") || eq(name, "site") || eq(name, "f"),
        Shape::CallInd => eq(name, "p") || eq(name, "site"),
        Shape::TailCall => eq(name, "n"),
        Shape::TailCallInd => eq(name, "p") || eq(name, "site") || eq(name, "n"),
    }
}

/// Whether instructions of `op` call a handler.
pub const fn has_handler(op: Opcode) -> bool {
    !matches!(op.info().shape, Shape::Jmp | Shape::Call | Shape::Island)
}

/// The register layout of `op`'s handler call (see the [module docs](self)). Fails to
/// compile, in a `const`, for an opcode whose operands don't fit.
pub const fn layout(op: Opcode, mode: Mode) -> Layout {
    let info = op.info();
    let first = mode.fp_arg as u8 + matches!(info.shape, Shape::Lpad) as u8;
    // One unit per operand register: (operand, part, shareable).
    let mut units = [(0u8, 0u8, false); 2 * MAX_OPERANDS];
    let mut n = 0;
    let mut i = 0;
    while i < info.operands.len() {
        let o = info.operands[i];
        if passed(info.shape, o.name) {
            let k = kind_regs(o.kind);
            let mut part = 0;
            while part < k {
                units[n] = (i as u8, part, k == 1 && shareable(o.kind));
                n += 1;
                part += 1;
            }
        }
        i += 1;
    }
    // Registers: groups of one or two units, `start[g]..start[g + 1]`.
    let mut size = [1u8; 2 * MAX_OPERANDS];
    let mut groups = n;
    let max = ARG_REGS - first as usize;
    while groups > max {
        // The last adjacent pair of shareable single-unit groups.
        let mut g = groups - 1;
        let mut found = false;
        while g > 0 {
            if size[g] == 1 && size[g - 1] == 1 && unit_of(&size, &units, g).2 && unit_of(&size, &units, g - 1).2 {
                found = true;
                break;
            }
            g -= 1;
        }
        if !found {
            panic!("an opcode's operands don't fit the argument registers");
        }
        size[g - 1] = 2;
        let mut j = g;
        while j + 1 < groups {
            size[j] = size[j + 1];
            j += 1;
        }
        groups -= 1;
    }
    let mut locs = [Loc::NONE; MAX_OPERANDS];
    let mut u = 0;
    let mut g = 0;
    while g < groups {
        let mut k = 0;
        while k < size[g] {
            let (o, part, _) = units[u];
            if part == 0 {
                locs[o as usize] = Loc {
                    reg: first + g as u8,
                    shift: 32 * k,
                    count: kind_regs(info.operands[o as usize].kind),
                    shared: size[g] == 2,
                };
            }
            u += 1;
            k += 1;
        }
        g += 1;
    }
    Layout { locs, first, regs: first + groups as u8 }
}

/// The first unit of group `g`.
const fn unit_of(size: &[u8; 2 * MAX_OPERANDS], units: &[(u8, u8, bool); 2 * MAX_OPERANDS], g: usize) -> (u8, u8, bool) {
    let mut u = 0;
    let mut i = 0;
    while i < g {
        u += size[i] as usize;
        i += 1;
    }
    units[u]
}

/// The value of the operand at `loc` in the handler's argument registers `args`: the
/// register (`count` 1, the 32-bit half for a shared one), or two of them (`count` 2, low
/// first).
#[inline(always)]
pub const fn read(args: &[u64; ARG_REGS], loc: Loc) -> u128 {
    let r = args[loc.reg as usize];
    match (loc.count, loc.shared) {
        (2, _) => r as u128 | (args[loc.reg as usize + 1] as u128) << 64,
        (_, true) => (r >> loc.shift) as u32 as u128,
        _ => r as u128,
    }
}

/// The byte sequence `nop dword [rcx + d]` begins with: the marker after a VM call
/// (`0F 1F 81 disp32`), which `ret` reads `d` from.
pub const CALL_MARKER: [u8; 3] = [0x0f, 0x1f, 0x81];
