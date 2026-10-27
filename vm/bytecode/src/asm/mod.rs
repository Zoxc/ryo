//! The x86-64 form of VM code (design/vm.md, "Encoding"): every instruction is a call of its
//! handler `ryo_h_<Opcode>` with its operands in argument registers, followed by the control
//! flow its [`Shape`] gives it, except that the common instructions ([`has_inline`]) are
//! native sequences.
//!
//! - [`layout`] (here, `core` only): which argument register holds which operand. The
//!   handlers in `ryo_rt` read their operands through it, and the encoder writes them through
//!   it.
//! - `x86` (`alloc`): the canonical machine-code sequences the encoder emits and the decoder
//!   accepts.
//! - [`encode`] / [`decode`] (`alloc`): instruction words to machine code and back. The
//!   decoder is the encoder's test oracle: `decode(encode(f)) == f`, frame size and unwind
//!   entries included.
//! - `inline` (`alloc`): the native sequences of the inlined instructions.
//! - [`reduce`] (`alloc`): full code to the reduced set ([`crate::reduced`]), which
//!   [`decode_reduced`] reads machine code back to, and [`decode_linked`] linked machine
//!   code, through a [`Resolver`].
//! - [`lsda`] (`alloc`): the call-site table of a function's LSDA.
//! - [`frame`] (`alloc`): frame bytes of reduced code: accesses, liveness, renaming slots.
//! - [`osr`] (`alloc`): the JIT's OSR entries from AOT loop heads into JIT code.
//!
//! # Operands and registers
//!
//! A handler takes its operands in the argument registers of the platform's C convention,
//! in operand order ([`handler_arg`]): the six of `sysv64`, `rdi, rsi, rdx, rcx, r8, r9`,
//! or on PE the four of Win64, `rcx, rdx, r8, r9`, and one 32-bit operand of its own as the
//! fifth argument, on the stack (the `atomic.cxchg` handlers). An operand takes one
//! register, except `Mem` (`p`, `k`), `U128` (low, high) and a case list (values, count),
//! which take two. The handler finds `fp` in `rbp`, or with [`Mode::fp_arg`] (not on PE) in
//! `rdi`, before the operands.
//!
//! # Frames
//!
//! `fp` is the address below the return address, so the argument block is at `fp + 16`, and
//! `rsp` is `fp - F` while the function runs. With [`Mode::frame_pointer`] the prologue
//! saves the caller's `rbp` at `fp` and sets `rbp = fp`, and frame slots are `[rbp + d]`;
//! without, the prologue is `sub rsp, F + 8`, slots are `[rsp + F + d]` and `rbp` is left
//! alone, as LLVM omits frame pointers.
//! If an opcode has more operands than registers, adjacent 32-bit operands (`Slot`, `U8`,
//! `U16`, `U32`) share one, `a | b << 32`, pairing from the last pair.

#[cfg(feature = "alloc")]
mod decode;
#[cfg(feature = "alloc")]
mod encode;
#[cfg(feature = "alloc")]
pub mod frame;
#[cfg(feature = "alloc")]
mod inline;
pub(crate) mod leb;
pub mod list;
pub mod lsda;
#[cfg(feature = "alloc")]
pub mod osr;
#[cfg(feature = "alloc")]
mod reduced;
#[cfg(feature = "alloc")]
pub(crate) mod x86;

#[cfg(feature = "alloc")]
pub use decode::{AsmError, Decoded, Resolver, decode, decode_linked, decode_reduced, decode_reduced_indexed};
#[cfg(feature = "alloc")]
pub use encode::{
    Asm, CallSite, DroppedStore, EncodeError, Encoded, InsnId, Label, Opnd, PROBE_FROM, Ref, Reloc, Scope, ScopeKind, Unwind, encode, operands,
    pe_region_start, prologue_len, push_words, word_len,
};
#[cfg(feature = "alloc")]
pub use inline::{has_inline, ssa_as_handler};
pub use list::Hint;
#[cfg(feature = "alloc")]
pub use list::InsnList;
#[cfg(feature = "alloc")]
pub use reduced::{as_handler, encode_reduced, encode_reduced_at, is_native, reduce};

use crate::full::{ElemKind, Opcode, OperandKind, Shape};
use crate::image::JIT_LOOP_CTR;

/// The argument registers handlers take: `rdi, rsi, rdx, rcx, r8, r9` (on PE, the
/// positions of [`handler_arg`]: four registers, then the stack).
pub const ARG_REGS: usize = 6;

/// PE: the argument registers of Win64 handlers, `rcx, rdx, r8, r9`. Their layouts use one
/// more position, the stack ([`handler_arg`]).
pub const PE_ARG_REGS: usize = 4;

/// Where a handler call passes the argument at position `i` of its layout ([`Layout`]).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum HandlerArg {
    /// An argument register, by its x86 number.
    Reg(u8),
    /// PE: the fifth argument, the 8 bytes at `[rsp + 32]` at the call, past the 32 bytes of
    /// shadow space. It always holds one 32-bit operand, which the call stores as a
    /// `dword`: the handler reads only its low 32 bits.
    Stack,
}

/// The place of argument position `i` of a handler call ([`layout`]): `rdi, rsi, rdx, rcx,
/// r8, r9`, or on PE (Win64 handlers) `rcx, rdx, r8, r9`, then [`HandlerArg::Stack`].
pub const fn handler_arg(pe: bool, i: u8) -> HandlerArg {
    const SYSV: [u8; ARG_REGS] = [7, 6, 2, 1, 8, 9];
    const WIN64: [u8; PE_ARG_REGS] = [1, 2, 8, 9];
    if !pe {
        HandlerArg::Reg(SYSV[i as usize])
    } else if (i as usize) < PE_ARG_REGS {
        HandlerArg::Reg(WIN64[i as usize])
    } else {
        HandlerArg::Stack
    }
}

/// The most operands an opcode has.
pub const MAX_OPERANDS: usize = 8;

/// How the machine code is generated, which the handlers must agree with.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Mode {
    /// Handlers take `fp` in `rdi` (before the operands) instead of reading `rbp`.
    pub fp_arg: bool,
    /// Functions keep `fp` in `rbp` (`push rbp; mov rbp, rsp`) and address their slots
    /// through it. Without, they address them through `rsp`, which requires `fp_arg` (the
    /// handlers can't find `fp` otherwise) and not `pe`.
    pub frame_pointer: bool,
    /// Backward branch targets are padded to 16 bytes.
    pub align_loops: bool,
    /// The target is PE/COFF: handlers and islands take the Win64 convention (`rcx`, `rdx`,
    /// `r8`, `r9`, 32 bytes of shadow space, which every frame reserves at its bottom), and
    /// handlers read `fp` from `rbp` (no `fp_arg`).
    pub pe: bool,
    /// Every function counts its calls and its loop iterations up in two counters of its JIT
    /// record, and leaves through an out-of-line stub when one isn't negative any more: the
    /// JIT's trigger (design/vm.md, "JIT records and counters"). The backend always emits
    /// them; code the JIT encodes has none.
    pub counters: bool,
    /// JIT code only (never an image's mode): the handlers and the probe are out of `rel32`
    /// reach of the code, which calls them as `mov r11, imm64; call r11` (design/jit.md,
    /// "Calls"). That is JIT code of an image far from a shared `ryo_rt`.
    pub far_rt: bool,
}

/// PE: what a VM function's pad region allocates below the trampoline's return address
/// (design/vm.md#unwinding): the 32 bytes of shadow space of the calls in its cleanup code,
/// and 8 more that keep `rsp` 16-aligned. Its entry is `sub rsp, PE_REGION_ALLOC; jmp r11`,
/// and `resume` there is `add rsp, PE_REGION_ALLOC; ret`.
pub const PE_REGION_ALLOC: u32 = 40;

/// JIT call targets (design/jit.md, "Calls"): the JIT gives a `call` or `tail_call` whose
/// callee it doesn't reach as a function of the image a function operand with one of these
/// bits, and the rest of the operand numbers the target in the JIT's list. The encoders emit
/// it through the call slot: `call [rip + slot]` or `jmp [rip + slot]`.
pub const FUNC_SLOT: u32 = 1 << 31;
/// At a known address within `rel32` reach: `call rel32` or `jmp rel32`.
pub const FUNC_NEAR: u32 = 1 << 30;
/// At a known address out of reach: `mov r11, imm64; call r11` or `jmp r11`.
pub const FUNC_FAR: u32 = 1 << 29;
/// The bits of [`FUNC_SLOT`], [`FUNC_NEAR`] and [`FUNC_FAR`].
pub const FUNC_KINDS: u32 = FUNC_SLOT | FUNC_NEAR | FUNC_FAR;

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
    /// The registers the handler call sets, `fp` and the exception object included (on PE
    /// the stack argument too: positions, [`handler_arg`]).
    pub regs: u8,
}

impl Mode {
    /// Whether the encoder supports the combination (see [`Mode::frame_pointer`] and
    /// [`Mode::pe`]).
    pub const fn valid(self) -> bool {
        if self.pe { self.frame_pointer && !self.fp_arg } else { self.frame_pointer || self.fp_arg }
    }
}

impl Layout {
    /// The location of the operand called `name`.
    pub const fn loc(&self, op: Opcode, name: &str) -> Loc {
        self.locs[crate::full::operand_index_const(op, name)]
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
        // Only the reduced `handler` has the last two, and it has no layout.
        OperandKind::Func | OperandKind::Target | OperandKind::Neg | OperandKind::Handler | OperandKind::List(ElemKind::Arg) => 0,
    }
}

/// Whether an operand of kind `k` is 32 bits, so it may share a register.
const fn shareable(k: OperandKind) -> bool {
    matches!(k, OperandKind::Slot | OperandKind::U8 | OperandKind::U16 | OperandKind::U32)
}

/// Whether instructions of `shape` call a handler with their operands. The other shapes
/// are call sequences or jumps of their own, with no handler (or none that takes operands).
const fn calls_handler(shape: Shape) -> bool {
    match shape {
        Shape::Op | Shape::Br | Shape::Switch | Shape::Trap | Shape::Lpad => true,
        Shape::Jmp | Shape::Call | Shape::TailCall | Shape::Ret | Shape::Island | Shape::Arg => false,
    }
}

/// Whether instructions of `op` call a handler. `unreachable` is a bare `ud2`.
pub const fn has_handler(op: Opcode) -> bool {
    calls_handler(op.info().shape) && !matches!(op, Opcode::Unreachable)
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
    while calls_handler(info.shape) && i < info.operands.len() {
        let o = info.operands[i];
        let k = kind_regs(o.kind);
        let mut part = 0;
        while part < k {
            units[n] = (i as u8, part, k == 1 && shareable(o.kind));
            n += 1;
            part += 1;
        }
        i += 1;
    }
    // Registers: groups of one or two units, `start[g]..start[g + 1]`. On PE, a fifth
    // position on the stack, if it holds a single 32-bit operand; else fewer groups.
    let (size, groups) = if mode.pe {
        let max = PE_ARG_REGS - first as usize;
        match pack(&units, n, max + 1) {
            Some((size, groups)) if groups <= max || size[groups - 1] == 1 && unit_of(&size, &units, groups - 1).2 => (size, groups),
            _ => match pack(&units, n, max) {
                Some(p) => p,
                None => panic!("an opcode's operands don't fit the argument registers"),
            },
        }
    } else {
        match pack(&units, n, ARG_REGS - first as usize) {
            Some(p) => p,
            None => panic!("an opcode's operands don't fit the argument registers"),
        }
    };
    let mut locs = [Loc::NONE; MAX_OPERANDS];
    let mut u = 0;
    let mut g = 0;
    while g < groups {
        let mut k = 0;
        while k < size[g] {
            let (o, part, _) = units[u];
            if part == 0 {
                locs[o as usize] =
                    Loc { reg: first + g as u8, shift: 32 * k, count: kind_regs(info.operands[o as usize].kind), shared: size[g] == 2 };
            }
            u += 1;
            k += 1;
        }
        g += 1;
    }
    Layout { locs, first, regs: first + groups as u8 }
}

/// The `n` units in at most `max` groups of one or two (the group sizes and the count):
/// adjacent shareable single units pair up, from the last pair on. `None` if they don't fit.
const fn pack(units: &[(u8, u8, bool); 2 * MAX_OPERANDS], n: usize, max: usize) -> Option<([u8; 2 * MAX_OPERANDS], usize)> {
    let mut size = [1u8; 2 * MAX_OPERANDS];
    let mut groups = n;
    while groups > max {
        // The last adjacent pair of shareable single-unit groups.
        let mut g = groups - 1;
        let mut found = false;
        while g > 0 {
            if size[g] == 1 && size[g - 1] == 1 && unit_of(&size, units, g).2 && unit_of(&size, units, g - 1).2 {
                found = true;
                break;
            }
            g -= 1;
        }
        if !found {
            return None;
        }
        size[g - 1] = 2;
        let mut j = g;
        while j + 1 < groups {
            size[j] = size[j + 1];
            j += 1;
        }
        groups -= 1;
    }
    Some((size, groups))
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

/// A return kind (the `k` of `ret` and the calls): how a value comes back.
/// 0 is nothing, [`RET_SRET`] memory the caller passes the address of (in the first integer
/// argument register; the callee returns it in `rax`; only in the function table: in code,
/// such a call is one of kind 0 with that argument, and the callee's `ret` returns the
/// address as an 8-byte part), anything else up to two register parts ([`ret_parts`]). The parts take `rax` then `rdx` (integers) and `xmm0` then `xmm1`
/// (floats) in order, as LLVM returns a first-class aggregate.
///
/// A call's kind gives each part's exact size, which it stores. `ret`'s gives the width it
/// loads: integer parts are 1, 2, 4 or 8 bytes (reading up to the next one past a 3-, 5-, 6-
/// or 7-byte value leaves garbage in the register's unused bits, as the ABI allows), and
/// an sret function returns the pointer as an 8-byte part.
pub const RET_SRET: u32 = 1 << 31;

/// A part of a value returned in registers ([`RET_SRET`]).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct RetPart {
    /// An SSE register, else a general-purpose one.
    pub xmm: bool,
    /// 1 to 8 bytes for an integer part, 2, 4, 8 or 16 for a float one.
    pub size: u32,
    /// The part's offset in the value.
    pub off: u32,
}

impl RetPart {
    /// The kind byte of the part, and its offset byte.
    const fn bits(self) -> u32 {
        self.size | (self.xmm as u32) << 5
    }
}

/// The kind of a value in the registers `parts` (none to two).
pub const fn ret_kind(parts: &[RetPart]) -> u32 {
    match parts {
        [] => 0,
        [a] => a.bits(),
        [a, b] => a.bits() | b.bits() << 8 | b.off << 16,
        _ => panic!("more than two return parts"),
    }
}

/// The register parts of the kind `k`, or `None` for [`RET_SRET`] and invalid kinds. A call
/// kind (`load` false) has exact sizes, a `ret` kind (`load`) load widths ([`RET_SRET`]).
pub fn ret_parts(k: u32, load: bool) -> Option<[Option<RetPart>; 2]> {
    if k >> 24 != 0 {
        return None;
    }
    let part = |b: u32, off: u32| -> Option<Option<RetPart>> {
        if b == 0 {
            return Some(None);
        }
        let (xmm, size) = (b & 0x20 != 0, b & 0x1f);
        let ok = if xmm {
            matches!(size, 2 | 4 | 8 | 16)
        } else if load {
            matches!(size, 1 | 2 | 4 | 8)
        } else {
            (1..=8).contains(&size)
        };
        (b & !0x3f == 0 && ok).then_some(Some(RetPart { xmm, size, off }))
    };
    let a = part(k & 0xff, 0)?;
    let b = part(k >> 8 & 0xff, k >> 16 & 0xff)?;
    match (a, b) {
        (None, Some(_)) => None,
        (None, None) if k != 0 => None,
        (Some(a), Some(b)) if b.off < a.size || b.off + b.size > 16 => None,
        (Some(_), None) if k >> 16 != 0 => None,
        _ => Some([a, b]),
    }
}

/// Whether the instruction `words` (opcode first) has operands the machine code can pass: a
/// return kind ([`RET_SRET`]), with kind 0 a `call` destination and a `ret` source of 0
/// (nothing in the machine code holds them), an `arg`'s register ([`ArgReg`]), and a call's
/// argument list ([`params_ok`]).
pub fn return_ok(words: &[u32]) -> bool {
    use crate::full::operand_word;
    let Some(op) = Opcode::from_u16(words[0] as u16) else { return true };
    let k_ok = |k: u32, load: bool| k == 0 || (k == RET_SRET && !load) || ret_parts(k, load).is_some();
    match op {
        Opcode::Ret => {
            let (s, k) = (words[operand_word(op, "s")], words[operand_word(op, "k")]);
            k_ok(k, true) && (k != 0 || s == 0)
        }
        Opcode::Arg => ArgReg::of(words[operand_word(op, "r")], true).is_some(),
        Opcode::Call | Opcode::CallSym | Opcode::CallSymInd | Opcode::CallPtr => {
            let (d, k) = (words[operand_word(op, "d")], words[operand_word(op, "k")]);
            let a = operand_word(op, "a");
            k != RET_SRET && k_ok(k, false) && (k != 0 || d == 0) && params_ok(&words[a + 1..][..words[a] as usize])
        }
        Opcode::TailCall | Opcode::TailCallPtr => {
            let a = operand_word(op, "a");
            params_ok(&words[a + 1..][..words[a] as usize])
        }
        _ => true,
    }
}

/// A call's argument list `a`: (slot, register) pairs, the register an [`ArgReg`] word with
/// load sizes, or [`ARG_ADDR`] for the slot's address in an integer register. No register
/// twice. A call of an sret function passes the destination's address as an argument (the
/// first integer register), and its kind is 0: the machine code is the same.
pub fn params_ok(a: &[u32]) -> bool {
    if a.len() % 2 != 0 {
        return false;
    }
    let mut used = 0u32;
    for p in a.chunks(2) {
        let Some(r) = param_reg(p[1]) else { return false };
        let bit = 1 << (r.index + if r.xmm { 8 } else { 0 });
        if used & bit != 0 {
            return false;
        }
        used |= bit;
    }
    true
}

/// The register of an argument list entry ([`params_ok`]), if valid: [`ARG_ADDR`] gives an
/// 8-byte integer register.
pub fn param_reg(w: u32) -> Option<ArgReg> {
    if w & ARG_ADDR != 0 {
        return ArgReg::of(w & !ARG_ADDR, false).filter(|r| !r.xmm && r.size == 8);
    }
    ArgReg::of(w, false)
}

/// In a call's argument list ([`params_ok`]): the register gets the slot's address.
pub const ARG_ADDR: u32 = 1 << 6;

/// An `arg`'s register `r`: bits 0–4 the size it stores (1 to 8 bytes of an integer register,
/// 2, 4, 8 or 16 of an SSE one; in a call's argument list ([`params_ok`]) the size it loads,
/// integers 1, 2, 4 or 8), bit 5 an SSE register, bits 8–15 the register's
/// index among the convention's argument registers of its class: `rdi rsi rdx rcx r8 r9`
/// (PE: `rcx rdx r8 r9`) and `xmm0`–`xmm7` (PE: `xmm0`–`xmm3`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ArgReg {
    pub xmm: bool,
    pub size: u32,
    pub index: u32,
}

impl ArgReg {
    pub const fn word(self) -> u32 {
        self.size | (self.xmm as u32) << 5 | self.index << 8
    }

    /// The register of the word `r`, if valid: `exact` for an `arg`'s store sizes.
    pub fn of(r: u32, exact: bool) -> Option<ArgReg> {
        let a = ArgReg { xmm: r & 0x20 != 0, size: r & 0x1f, index: r >> 8 };
        let int = if exact { (1..=8).contains(&a.size) } else { matches!(a.size, 1 | 2 | 4 | 8) };
        let ok = if a.xmm { matches!(a.size, 2 | 4 | 8 | 16) && a.index < 8 } else { int && a.index < 6 };
        (ok && r & 0xc0 == 0 && a.word() == r).then_some(a)
    }
}
