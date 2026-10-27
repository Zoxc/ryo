//! The inline form of the common VM instructions (design/vm.md, "Inline instructions"):
//! moves, immediates, addresses (of slots, constants and symbols), address arithmetic, loads and stores, integer add/sub/logic/multiply, byte swaps,
//! shifts and rotates (by an immediate or a slot), compares and compare-branches, at widths up to 64 bits (and
//! 128-bit moves, as two 64-bit halves). They
//! are short native sequences on `rax` and `rcx` instead of handler calls; the register cache
//! ([`Cache`]) renames `rax` as it emits them.
//!
//! Every sequence ends in its last write (to the frame or to memory), or in a conditional
//! branch, and the only earlier write is `mov.w128`'s store of `rcx` to the frame, so the
//! decoder knows where a sequence ends. Each opcode has one sequence per operand pattern, and no two opcodes share
//! one: the decoder recovers the opcode and operands by matching against [`sequence`].

use alloc::vec;
use alloc::vec::Vec;

use super::encode::{Opnd, Ref};
use super::x86::{Alu, Cond, Item, M, Reg, Rm, Sh, W};
use crate::full::{ALL_OPCODES, Opcode, OperandKind};

/// The inline sequence kinds, by the opcode's operation and width.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Class {
    Mov(W),
    /// A 128-bit move: both halves loaded, then the high one stored from `rcx`.
    Mov128,
    Imm(W),
    Addr,
    /// `addr.const`: `lea` of the constant (or data area) address.
    AddrConst,
    /// `addr.sym`: the symbol slot's value, loaded rip-relative.
    AddrSym,
    /// `addr.sym.ind`: the slot's value, then the import slot it points to.
    AddrSymInd,
    PtrAdd,
    PtrIndex,
    Load(W),
    Store(W),
    Bin(Alu, W),
    BinImm(Alu, W),
    Mul(W),
    MulImm(W),
    ShiftImm(Sh, W),
    /// A shift or rotate by a slot's value (`cl`): `shl`, `shr.s`, `shr.u`, `rotl`, `rotr`.
    ShiftVar(Sh, W),
    /// `div` (`rem`: the remainder), signed or not.
    Div {
        signed: bool,
        rem: bool,
        w: W,
    },
    /// `cttz` (`ctlz` if `lz`).
    Count {
        lz: bool,
        w: W,
    },
    /// `cmp3`, signed or not: -1, 0 or 1 as a byte.
    Cmp3(bool, W),
    /// `bswap.w16`-`bswap.w64`.
    Bswap(W),
    /// A compare to a `bool`, the condition for true.
    Cmp(Cond, W),
    CmpImm(Cond, W),
    Br,
    /// A compare-branch, the condition to branch on without `neg`.
    BrCmp(Cond, W),
    BrCmpImm(Cond, W),
    /// `add.ovf`/`sub.ovf`, signed or not: the result and its overflow flag.
    Ovf(Alu, bool, W),
    /// `mul.ovf`, signed or not.
    MulOvf(bool, W),
    /// A zero or sign extension (`sx`) or a truncation, from one width to another.
    Ext {
        from: W,
        to: W,
        sx: bool,
    },
}

#[rustfmt::skip]
fn class(op: Opcode) -> Option<Class> {
    use Class::{Bin, BinImm, BrCmp, BrCmpImm, Cmp, CmpImm, Ext, Imm, Load, Mov, Mul, MulImm, MulOvf, Ovf, ShiftImm, ShiftVar, Store};
    use Opcode::*;
    Some(match op {
        MovW8 => Mov(W::B), MovW16 => Mov(W::W), MovW32 => Mov(W::D), MovW64 => Mov(W::Q),
        MovW128 => Class::Mov128,
        ImmW8 => Imm(W::B), ImmW16 => Imm(W::W), ImmW32 => Imm(W::D), ImmW64 => Imm(W::Q),
        LoadW8 => Load(W::B), LoadW16 => Load(W::W), LoadW32 => Load(W::D), LoadW64 => Load(W::Q),
        StoreW8 => Store(W::B), StoreW16 => Store(W::W), StoreW32 => Store(W::D), StoreW64 => Store(W::Q),
        Addr => Class::Addr,
        AddrConst => Class::AddrConst, AddrSym => Class::AddrSym, AddrSymInd => Class::AddrSymInd,
        PtrAdd => Class::PtrAdd,
        PtrIndex => Class::PtrIndex,
        AddW8 => Bin(Alu::Add, W::B), AddW16 => Bin(Alu::Add, W::W), AddW32 => Bin(Alu::Add, W::D), AddW64 => Bin(Alu::Add, W::Q),
        SubW8 => Bin(Alu::Sub, W::B), SubW16 => Bin(Alu::Sub, W::W), SubW32 => Bin(Alu::Sub, W::D), SubW64 => Bin(Alu::Sub, W::Q),
        AndW8 => Bin(Alu::And, W::B), AndW16 => Bin(Alu::And, W::W), AndW32 => Bin(Alu::And, W::D), AndW64 => Bin(Alu::And, W::Q),
        OrW8 => Bin(Alu::Or, W::B), OrW16 => Bin(Alu::Or, W::W), OrW32 => Bin(Alu::Or, W::D), OrW64 => Bin(Alu::Or, W::Q),
        XorW8 => Bin(Alu::Xor, W::B), XorW16 => Bin(Alu::Xor, W::W), XorW32 => Bin(Alu::Xor, W::D), XorW64 => Bin(Alu::Xor, W::Q),
        MulW8 => Mul(W::B), MulW16 => Mul(W::W), MulW32 => Mul(W::D), MulW64 => Mul(W::Q),
        AddImmW8 => BinImm(Alu::Add, W::B), AddImmW16 => BinImm(Alu::Add, W::W), AddImmW32 => BinImm(Alu::Add, W::D), AddImmW64 => BinImm(Alu::Add, W::Q),
        SubImmW8 => BinImm(Alu::Sub, W::B), SubImmW16 => BinImm(Alu::Sub, W::W), SubImmW32 => BinImm(Alu::Sub, W::D), SubImmW64 => BinImm(Alu::Sub, W::Q),
        AndImmW8 => BinImm(Alu::And, W::B), AndImmW16 => BinImm(Alu::And, W::W), AndImmW32 => BinImm(Alu::And, W::D), AndImmW64 => BinImm(Alu::And, W::Q),
        OrImmW8 => BinImm(Alu::Or, W::B), OrImmW16 => BinImm(Alu::Or, W::W), OrImmW32 => BinImm(Alu::Or, W::D), OrImmW64 => BinImm(Alu::Or, W::Q),
        XorImmW8 => BinImm(Alu::Xor, W::B), XorImmW16 => BinImm(Alu::Xor, W::W), XorImmW32 => BinImm(Alu::Xor, W::D), XorImmW64 => BinImm(Alu::Xor, W::Q),
        MulImmW8 => MulImm(W::B), MulImmW16 => MulImm(W::W), MulImmW32 => MulImm(W::D), MulImmW64 => MulImm(W::Q),
        ShlImmW8 => ShiftImm(Sh::Shl, W::B), ShlImmW16 => ShiftImm(Sh::Shl, W::W), ShlImmW32 => ShiftImm(Sh::Shl, W::D), ShlImmW64 => ShiftImm(Sh::Shl, W::Q),
        ShrSImmW8 => ShiftImm(Sh::Sar, W::B), ShrSImmW16 => ShiftImm(Sh::Sar, W::W), ShrSImmW32 => ShiftImm(Sh::Sar, W::D), ShrSImmW64 => ShiftImm(Sh::Sar, W::Q),
        ShrUImmW8 => ShiftImm(Sh::Shr, W::B), ShrUImmW16 => ShiftImm(Sh::Shr, W::W), ShrUImmW32 => ShiftImm(Sh::Shr, W::D), ShrUImmW64 => ShiftImm(Sh::Shr, W::Q),
        ShlW8 => ShiftVar(Sh::Shl, W::B), ShlW16 => ShiftVar(Sh::Shl, W::W), ShlW32 => ShiftVar(Sh::Shl, W::D), ShlW64 => ShiftVar(Sh::Shl, W::Q),
        ShrSW8 => ShiftVar(Sh::Sar, W::B), ShrSW16 => ShiftVar(Sh::Sar, W::W), ShrSW32 => ShiftVar(Sh::Sar, W::D), ShrSW64 => ShiftVar(Sh::Sar, W::Q),
        ShrUW8 => ShiftVar(Sh::Shr, W::B), ShrUW16 => ShiftVar(Sh::Shr, W::W), ShrUW32 => ShiftVar(Sh::Shr, W::D), ShrUW64 => ShiftVar(Sh::Shr, W::Q),
        RotlW8 => ShiftVar(Sh::Rol, W::B), RotlW16 => ShiftVar(Sh::Rol, W::W), RotlW32 => ShiftVar(Sh::Rol, W::D), RotlW64 => ShiftVar(Sh::Rol, W::Q),
        RotrW8 => ShiftVar(Sh::Ror, W::B), RotrW16 => ShiftVar(Sh::Ror, W::W), RotrW32 => ShiftVar(Sh::Ror, W::D), RotrW64 => ShiftVar(Sh::Ror, W::Q),
        DivSW8 => Class::Div { signed: true, rem: false, w: W::B }, DivSW16 => Class::Div { signed: true, rem: false, w: W::W },
        DivSW32 => Class::Div { signed: true, rem: false, w: W::D }, DivSW64 => Class::Div { signed: true, rem: false, w: W::Q },
        DivUW8 => Class::Div { signed: false, rem: false, w: W::B }, DivUW16 => Class::Div { signed: false, rem: false, w: W::W },
        DivUW32 => Class::Div { signed: false, rem: false, w: W::D }, DivUW64 => Class::Div { signed: false, rem: false, w: W::Q },
        RemSW8 => Class::Div { signed: true, rem: true, w: W::B }, RemSW16 => Class::Div { signed: true, rem: true, w: W::W },
        RemSW32 => Class::Div { signed: true, rem: true, w: W::D }, RemSW64 => Class::Div { signed: true, rem: true, w: W::Q },
        RemUW8 => Class::Div { signed: false, rem: true, w: W::B }, RemUW16 => Class::Div { signed: false, rem: true, w: W::W },
        RemUW32 => Class::Div { signed: false, rem: true, w: W::D }, RemUW64 => Class::Div { signed: false, rem: true, w: W::Q },
        CttzW8 => Class::Count { lz: false, w: W::B }, CttzW16 => Class::Count { lz: false, w: W::W },
        CttzW32 => Class::Count { lz: false, w: W::D }, CttzW64 => Class::Count { lz: false, w: W::Q },
        CtlzW8 => Class::Count { lz: true, w: W::B }, CtlzW16 => Class::Count { lz: true, w: W::W },
        CtlzW32 => Class::Count { lz: true, w: W::D }, CtlzW64 => Class::Count { lz: true, w: W::Q },
        Cmp3SW8 => Class::Cmp3(true, W::B), Cmp3SW16 => Class::Cmp3(true, W::W), Cmp3SW32 => Class::Cmp3(true, W::D), Cmp3SW64 => Class::Cmp3(true, W::Q),
        Cmp3UW8 => Class::Cmp3(false, W::B), Cmp3UW16 => Class::Cmp3(false, W::W), Cmp3UW32 => Class::Cmp3(false, W::D), Cmp3UW64 => Class::Cmp3(false, W::Q),
        BswapW16 => Class::Bswap(W::W), BswapW32 => Class::Bswap(W::D), BswapW64 => Class::Bswap(W::Q),
        EqW8 => Cmp(Cond::Z, W::B), EqW16 => Cmp(Cond::Z, W::W), EqW32 => Cmp(Cond::Z, W::D), EqW64 => Cmp(Cond::Z, W::Q),
        NeW8 => Cmp(Cond::Nz, W::B), NeW16 => Cmp(Cond::Nz, W::W), NeW32 => Cmp(Cond::Nz, W::D), NeW64 => Cmp(Cond::Nz, W::Q),
        LtSW8 => Cmp(Cond::L, W::B), LtSW16 => Cmp(Cond::L, W::W), LtSW32 => Cmp(Cond::L, W::D), LtSW64 => Cmp(Cond::L, W::Q),
        LtUW8 => Cmp(Cond::B, W::B), LtUW16 => Cmp(Cond::B, W::W), LtUW32 => Cmp(Cond::B, W::D), LtUW64 => Cmp(Cond::B, W::Q),
        LeSW8 => Cmp(Cond::Le, W::B), LeSW16 => Cmp(Cond::Le, W::W), LeSW32 => Cmp(Cond::Le, W::D), LeSW64 => Cmp(Cond::Le, W::Q),
        LeUW8 => Cmp(Cond::Be, W::B), LeUW16 => Cmp(Cond::Be, W::W), LeUW32 => Cmp(Cond::Be, W::D), LeUW64 => Cmp(Cond::Be, W::Q),
        EqImmW8 => CmpImm(Cond::Z, W::B), EqImmW16 => CmpImm(Cond::Z, W::W), EqImmW32 => CmpImm(Cond::Z, W::D), EqImmW64 => CmpImm(Cond::Z, W::Q),
        NeImmW8 => CmpImm(Cond::Nz, W::B), NeImmW16 => CmpImm(Cond::Nz, W::W), NeImmW32 => CmpImm(Cond::Nz, W::D), NeImmW64 => CmpImm(Cond::Nz, W::Q),
        LtSImmW8 => CmpImm(Cond::L, W::B), LtSImmW16 => CmpImm(Cond::L, W::W), LtSImmW32 => CmpImm(Cond::L, W::D), LtSImmW64 => CmpImm(Cond::L, W::Q),
        LtUImmW8 => CmpImm(Cond::B, W::B), LtUImmW16 => CmpImm(Cond::B, W::W), LtUImmW32 => CmpImm(Cond::B, W::D), LtUImmW64 => CmpImm(Cond::B, W::Q),
        LeSImmW8 => CmpImm(Cond::Le, W::B), LeSImmW16 => CmpImm(Cond::Le, W::W), LeSImmW32 => CmpImm(Cond::Le, W::D), LeSImmW64 => CmpImm(Cond::Le, W::Q),
        LeUImmW8 => CmpImm(Cond::Be, W::B), LeUImmW16 => CmpImm(Cond::Be, W::W), LeUImmW32 => CmpImm(Cond::Be, W::D), LeUImmW64 => CmpImm(Cond::Be, W::Q),
        GtSImmW8 => CmpImm(Cond::G, W::B), GtSImmW16 => CmpImm(Cond::G, W::W), GtSImmW32 => CmpImm(Cond::G, W::D), GtSImmW64 => CmpImm(Cond::G, W::Q),
        GtUImmW8 => CmpImm(Cond::A, W::B), GtUImmW16 => CmpImm(Cond::A, W::W), GtUImmW32 => CmpImm(Cond::A, W::D), GtUImmW64 => CmpImm(Cond::A, W::Q),
        GeSImmW8 => CmpImm(Cond::Ge, W::B), GeSImmW16 => CmpImm(Cond::Ge, W::W), GeSImmW32 => CmpImm(Cond::Ge, W::D), GeSImmW64 => CmpImm(Cond::Ge, W::Q),
        GeUImmW8 => CmpImm(Cond::Ae, W::B), GeUImmW16 => CmpImm(Cond::Ae, W::W), GeUImmW32 => CmpImm(Cond::Ae, W::D), GeUImmW64 => CmpImm(Cond::Ae, W::Q),
        Br => Class::Br,
        BrEqW8 => BrCmp(Cond::Z, W::B), BrEqW16 => BrCmp(Cond::Z, W::W), BrEqW32 => BrCmp(Cond::Z, W::D), BrEqW64 => BrCmp(Cond::Z, W::Q),
        BrLtSW8 => BrCmp(Cond::L, W::B), BrLtSW16 => BrCmp(Cond::L, W::W), BrLtSW32 => BrCmp(Cond::L, W::D), BrLtSW64 => BrCmp(Cond::L, W::Q),
        BrLtUW8 => BrCmp(Cond::B, W::B), BrLtUW16 => BrCmp(Cond::B, W::W), BrLtUW32 => BrCmp(Cond::B, W::D), BrLtUW64 => BrCmp(Cond::B, W::Q),
        BrEqImmW8 => BrCmpImm(Cond::Z, W::B), BrEqImmW16 => BrCmpImm(Cond::Z, W::W), BrEqImmW32 => BrCmpImm(Cond::Z, W::D), BrEqImmW64 => BrCmpImm(Cond::Z, W::Q),
        BrLtSImmW8 => BrCmpImm(Cond::L, W::B), BrLtSImmW16 => BrCmpImm(Cond::L, W::W), BrLtSImmW32 => BrCmpImm(Cond::L, W::D), BrLtSImmW64 => BrCmpImm(Cond::L, W::Q),
        BrLtUImmW8 => BrCmpImm(Cond::B, W::B), BrLtUImmW16 => BrCmpImm(Cond::B, W::W), BrLtUImmW32 => BrCmpImm(Cond::B, W::D), BrLtUImmW64 => BrCmpImm(Cond::B, W::Q),
        BrGtSImmW8 => BrCmpImm(Cond::G, W::B), BrGtSImmW16 => BrCmpImm(Cond::G, W::W), BrGtSImmW32 => BrCmpImm(Cond::G, W::D), BrGtSImmW64 => BrCmpImm(Cond::G, W::Q),
        BrGtUImmW8 => BrCmpImm(Cond::A, W::B), BrGtUImmW16 => BrCmpImm(Cond::A, W::W), BrGtUImmW32 => BrCmpImm(Cond::A, W::D), BrGtUImmW64 => BrCmpImm(Cond::A, W::Q),
        AddOvfSW8 => Ovf(Alu::Add, true, W::B), AddOvfSW16 => Ovf(Alu::Add, true, W::W), AddOvfSW32 => Ovf(Alu::Add, true, W::D), AddOvfSW64 => Ovf(Alu::Add, true, W::Q),
        AddOvfUW8 => Ovf(Alu::Add, false, W::B), AddOvfUW16 => Ovf(Alu::Add, false, W::W), AddOvfUW32 => Ovf(Alu::Add, false, W::D), AddOvfUW64 => Ovf(Alu::Add, false, W::Q),
        SubOvfSW8 => Ovf(Alu::Sub, true, W::B), SubOvfSW16 => Ovf(Alu::Sub, true, W::W), SubOvfSW32 => Ovf(Alu::Sub, true, W::D), SubOvfSW64 => Ovf(Alu::Sub, true, W::Q),
        SubOvfUW8 => Ovf(Alu::Sub, false, W::B), SubOvfUW16 => Ovf(Alu::Sub, false, W::W), SubOvfUW32 => Ovf(Alu::Sub, false, W::D), SubOvfUW64 => Ovf(Alu::Sub, false, W::Q),
        MulOvfSW8 => MulOvf(true, W::B), MulOvfSW16 => MulOvf(true, W::W), MulOvfSW32 => MulOvf(true, W::D), MulOvfSW64 => MulOvf(true, W::Q),
        MulOvfUW8 => MulOvf(false, W::B), MulOvfUW16 => MulOvf(false, W::W), MulOvfUW32 => MulOvf(false, W::D), MulOvfUW64 => MulOvf(false, W::Q),
        ZextW8W16 => Ext { from: W::B, to: W::W, sx: false }, ZextW8W32 => Ext { from: W::B, to: W::D, sx: false }, ZextW8W64 => Ext { from: W::B, to: W::Q, sx: false },
        ZextW16W32 => Ext { from: W::W, to: W::D, sx: false }, ZextW16W64 => Ext { from: W::W, to: W::Q, sx: false }, ZextW32W64 => Ext { from: W::D, to: W::Q, sx: false },
        SextW8W16 => Ext { from: W::B, to: W::W, sx: true }, SextW8W32 => Ext { from: W::B, to: W::D, sx: true }, SextW8W64 => Ext { from: W::B, to: W::Q, sx: true },
        SextW16W32 => Ext { from: W::W, to: W::D, sx: true }, SextW16W64 => Ext { from: W::W, to: W::Q, sx: true }, SextW32W64 => Ext { from: W::D, to: W::Q, sx: true },
        TruncW16W8 => Ext { from: W::W, to: W::B, sx: false }, TruncW32W8 => Ext { from: W::D, to: W::B, sx: false }, TruncW32W16 => Ext { from: W::D, to: W::W, sx: false },
        TruncW64W8 => Ext { from: W::Q, to: W::B, sx: false }, TruncW64W16 => Ext { from: W::Q, to: W::W, sx: false }, TruncW64W32 => Ext { from: W::Q, to: W::D, sx: false },
        _ => return None,
    })
}

/// Whether instructions of `op` are inlined, for some operands at least: `ptr.add` only with a 32-bit offset, `ptr.index` with a stride
/// below 2^31, shifts by an immediate below the width.
pub fn has_inline(op: Opcode) -> bool {
    class(op).is_some()
}

/// Whether the JIT's SSA tier takes the inline instruction `op` as its handler call: it has
/// no decoding of its own for it (variable shifts, rotates and division then become native
/// operations from the handler, `jit::build`'s `native_bin`).
pub fn ssa_as_handler(op: Opcode) -> bool {
    matches!(class(op), Some(Class::ShiftVar(..) | Class::Div { .. }))
}

/// The index computation of `switch.dense.wN` (`N` up to 64) in place of its handler call,
/// before the jump table: `s - base` (wrapping at `N` bits) in `rax`, or the default's index
/// `n` if it isn't below `n`, the case count (below 2^31), or `None` if it doesn't apply. `s`
/// is a frame slot, read plainly (the register cache is cleared by any instruction that
/// isn't inline).
pub(super) fn dense_index(op: Opcode, s: i32, base: u64, n: u64) -> Option<Vec<Item>> {
    let w = match op {
        Opcode::SwitchDenseW8 => W::B,
        Opcode::SwitchDenseW16 => W::W,
        Opcode::SwitchDenseW32 => W::D,
        Opcode::SwitchDenseW64 => W::Q,
        _ => return None,
    };
    if n >= 1 << 31 {
        return None;
    }
    let mut v = vec![ld(w, M::frame(s))];
    // `sub al`/`sub ax` keep the zero bits above from the `movzx`.
    let sub = |imm: i32| Item::AluImm { op: Alu::Sub, w, rm: Rm::Reg(R), imm };
    match w {
        _ if w.sext(base) == 0 => {}
        W::Q if !fits(base) => v.extend([Item::SetReg(C, base), Item::Alu { op: Alu::Sub, w, reg: R, rm: Rm::Reg(C) }]),
        _ => v.push(sub(w.sext(base) as i32)),
    }
    // The index, below `n` <= 2^31 after the `cmov`, zero-extended for the table load.
    let cw = if w == W::Q { W::Q } else { W::D };
    v.extend([
        Item::SetReg(C, n),
        Item::Alu { op: Alu::Cmp, w: cw, reg: R, rm: Rm::Reg(C) },
        Item::Cmov { cond: Cond::Ae, w: W::D, reg: R, rm: Rm::Reg(C) },
    ]);
    Some(v)
}

/// Whether `v` (a 64-bit value) is a sign-extended 32-bit one.
fn fits(v: u64) -> bool {
    i32::try_from(v as i64).is_ok()
}

const R: Reg = Reg::Rax;
const C: Reg = Reg::Rcx;

fn ld(w: W, m: M) -> Item {
    Item::Ld { w, sx: false, dst: R, m }
}

fn st(w: W, m: M) -> Item {
    Item::St { w, src: R, m }
}

/// An overflow flag's store to `o`: `setcc cl; mov [o], cl`.
fn flag(v: &mut Vec<Item>, c: Cond, o: M) {
    v.extend([Item::SetccCl(c), Item::St { w: W::B, src: C, m: o }]);
}

/// `cmp [a], imm` at width `w`, through `rcx` for a 64-bit value that isn't a sign-extended
/// 32-bit one.
fn cmp_imm(v: &mut Vec<Item>, w: W, a: M, x: u64) {
    if w == W::Q && !fits(x) {
        v.extend([ld(W::Q, a), Item::SetReg(C, x), Item::Alu { op: Alu::Cmp, w, reg: R, rm: Rm::Reg(C) }]);
    } else {
        v.push(Item::AluImm { op: Alu::Cmp, w, rm: Rm::Mem(a), imm: w.sext(x) as i32 });
    }
}

/// The inline sequence of `op` with operands `ops` (frame slots as `rbp` displacements, raw
/// or resolved), and the condition of its final branch for a branch: `None` if `op` has no
/// inline form for these operands.
pub(super) fn sequence<T>(op: Opcode, ops: &[Opnd<T>]) -> Option<(Vec<Item>, Option<Cond>)> {
    let c = class(op)?;
    let slot = |i: usize| match ops[i] {
        Opnd::Slot(s) => M::frame(s),
        _ => unreachable!("not a slot"),
    };
    let imm = |i: usize| match ops[i] {
        Opnd::Imm(v) => v,
        _ => unreachable!("not an immediate"),
    };
    let cond = |i: usize, c: Cond| match ops[i] {
        Opnd::Neg(n) => Some(if n { c.not() } else { c }),
        _ => unreachable!("not a polarity"),
    };
    let mut v = Vec::with_capacity(4);
    let mut br = None;
    // Operands by position: `d` first where there is one.
    match c {
        Class::Mov(w) => v.extend([ld(w, slot(1)), st(w, slot(0))]),
        Class::Mov128 => {
            // The high halves, 8 bytes up (none at the top of the `i32` range).
            let hi = |m: M| m.disp.checked_add(8).map(M::frame);
            let (src_hi, dst_hi) = (hi(slot(1))?, hi(slot(0))?);
            v.extend([
                ld(W::Q, slot(1)),
                Item::Ld { w: W::Q, sx: false, dst: C, m: src_hi },
                Item::St { w: W::Q, src: C, m: dst_hi },
                st(W::Q, slot(0)),
            ]);
        }
        Class::Imm(w) => {
            let x = imm(1);
            if w != W::Q || fits(x) {
                v.push(Item::StImm { w, m: slot(0), imm: w.sext(x) as i32 });
            } else {
                v.extend([Item::SetReg(R, x), st(W::Q, slot(0))]);
            }
        }
        Class::Addr => v.extend([Item::LeaM { dst: R, m: slot(1) }, st(W::Q, slot(0))]),
        Class::AddrConst => {
            let to = match ops[1] {
                Opnd::Const(k) => Ref::Const(k),
                Opnd::Data(d) => Ref::Data(d),
                _ => unreachable!("not a constant address"),
            };
            v.extend([Item::Lea(R, to), st(W::Q, slot(0))]);
        }
        Class::AddrSym | Class::AddrSymInd => {
            let Opnd::Sym(s) = ops[1] else { unreachable!("not a symbol") };
            v.push(Item::LoadRip(R, Ref::Sym(s)));
            if c == Class::AddrSymInd {
                v.push(ld(W::Q, M::rax(0)));
            }
            v.push(st(W::Q, slot(0)));
        }
        Class::PtrAdd => {
            let x = imm(2);
            if !fits(x) {
                return None;
            }
            v.extend([ld(W::Q, slot(1)), Item::LeaM { dst: R, m: M::rax(x as i32) }, st(W::Q, slot(0))]);
        }
        Class::PtrIndex => {
            let s = imm(3);
            if s > i32::MAX as u64 {
                return None;
            }
            v.extend([
                ld(W::Q, slot(1)),
                Item::ImulImm { w: W::Q, reg: C, rm: Rm::Mem(slot(2)), imm: s as i32 },
                Item::Alu { op: Alu::Add, w: W::Q, reg: R, rm: Rm::Reg(C) },
                st(W::Q, slot(0)),
            ]);
        }
        Class::Load(w) => {
            let Opnd::Mem(p, k) = ops[1] else { unreachable!() };
            v.extend([ld(W::Q, M::frame(p)), ld(w, M::rax(k)), st(w, slot(0))]);
        }
        Class::Store(w) => {
            let Opnd::Mem(p, k) = ops[0] else { unreachable!() };
            v.extend([ld(W::Q, M::frame(p)), Item::Ld { w, sx: false, dst: C, m: slot(1) }, Item::St { w, src: C, m: M::rax(k) }]);
        }
        Class::Bin(op, w) => v.extend([ld(w, slot(1)), Item::Alu { op, w, reg: R, rm: Rm::Mem(slot(2)) }, st(w, slot(0))]),
        Class::BinImm(op, w) => {
            let x = imm(2);
            v.push(ld(w, slot(1)));
            match w {
                W::Q if !fits(x) => v.extend([Item::SetReg(C, x), Item::Alu { op, w, reg: R, rm: Rm::Reg(C) }]),
                W::Q | W::B => v.push(Item::AluImm { op, w, rm: Rm::Reg(R), imm: w.sext(x) as i32 }),
                // 16 bits as 32 (no length-changing `imm16`), the high half dropped by the store.
                W::W | W::D => v.push(Item::AluImm { op, w: W::D, rm: Rm::Reg(R), imm: x as u32 as i32 }),
            }
            v.push(st(w, slot(0)));
        }
        Class::Mul(w) => {
            match w {
                W::D | W::Q => v.extend([ld(w, slot(1)), Item::Imul { w, reg: R, rm: Rm::Mem(slot(2)) }]),
                // 8 and 16 bits as 32: the low bits of the product are the same.
                W::B | W::W => {
                    v.extend([ld(w, slot(1)), Item::Ld { w, sx: false, dst: C, m: slot(2) }, Item::Imul { w: W::D, reg: R, rm: Rm::Reg(C) }])
                }
            }
            v.push(st(w, slot(0)));
        }
        Class::MulImm(w) => {
            let x = imm(2);
            match w {
                W::Q if !fits(x) => v.extend([ld(w, slot(1)), Item::SetReg(C, x), Item::Imul { w, reg: R, rm: Rm::Reg(C) }]),
                W::D | W::Q => v.push(Item::ImulImm { w, reg: R, rm: Rm::Mem(slot(1)), imm: x as i32 }),
                W::B | W::W => v.extend([ld(w, slot(1)), Item::ImulImm { w: W::D, reg: R, rm: Rm::Reg(R), imm: x as i32 }]),
            }
            v.push(st(w, slot(0)));
        }
        Class::ShiftImm(sh, w) => {
            let x = imm(2);
            if x >= w.bits() as u64 {
                return None;
            }
            let sx = sh == Sh::Sar && matches!(w, W::B | W::W);
            let sw = if w == W::Q { W::Q } else { W::D };
            v.extend([Item::Ld { w, sx, dst: R, m: slot(1) }, Item::Shift { op: sh, w: sw, reg: R, amt: x as u8 }, st(w, slot(0))]);
        }
        Class::ShiftVar(sh, w) => {
            let rot = matches!(sh, Sh::Rol | Sh::Ror);
            // Shifts at 8 and 16 bits run in 32 (`sar` on the sign-extended value), the amount
            // masked to the width; rotates run at the width, which divides `cl`'s 5-bit mask.
            let narrow = matches!(w, W::B | W::W);
            v.push(Item::Ld { w, sx: sh == Sh::Sar && narrow, dst: R, m: slot(1) });
            if rot {
                v.extend([Item::Ld { w: W::D, sx: false, dst: C, m: slot(2) }, Item::ShiftCl { op: sh, w, reg: R }]);
            } else if narrow {
                v.extend([
                    Item::Ld { w, sx: false, dst: C, m: slot(2) },
                    Item::AluImm { op: Alu::And, w: W::D, rm: Rm::Reg(C), imm: w.bits() as i32 - 1 },
                    Item::ShiftCl { op: sh, w: W::D, reg: R },
                ]);
            } else {
                // `cl`'s mask at 32 and 64 bits is the width's.
                v.extend([Item::Ld { w: W::D, sx: false, dst: C, m: slot(2) }, Item::ShiftCl { op: sh, w, reg: R }]);
            }
            v.push(st(w, slot(0)));
        }
        // MIR rules out a zero divisor and `MIN / -1`, the cases that fault.
        Class::Div { signed, rem, w } => {
            let ext = if signed { Item::Cdq(if w == W::Q { W::Q } else { W::D }) } else { Item::SetReg(Reg::Rdx, 0) };
            match w {
                W::D | W::Q => v.extend([ld(w, slot(1)), ext, Item::Div { signed, w, rm: Rm::Mem(slot(2)) }]),
                // 8 and 16 bits in 32, on the extended operands.
                W::B | W::W => v.extend([
                    Item::Ld { w, sx: signed, dst: R, m: slot(1) },
                    Item::Ld { w, sx: signed, dst: C, m: slot(2) },
                    ext,
                    Item::Div { signed, w: W::D, rm: Rm::Reg(C) },
                ]),
            }
            v.push(Item::St { w, src: if rem { Reg::Rdx } else { R }, m: slot(0) });
        }
        // The count as a `u32`; `bsf`/`bsr` of zero leave the register undefined, so `cmovz`
        // gives that case's result, or a guard bit above the value makes it non-zero.
        Class::Count { lz, w } => {
            let n = w.bits();
            let bw = if w == W::Q { W::Q } else { W::D };
            v.push(ld(w, slot(1)));
            if lz {
                // `bsr` is `n - 1 - clz`, and `(2n - 1) ^ (n - 1)` is `n`.
                v.extend([
                    Item::Bsr { w: bw, reg: R, rm: Rm::Reg(R) },
                    Item::SetReg(C, 2 * n as u64 - 1),
                    Item::Cmov { cond: Cond::Z, w: W::D, reg: R, rm: Rm::Reg(C) },
                    Item::AluImm { op: Alu::Xor, w: W::D, rm: Rm::Reg(R), imm: n as i32 - 1 },
                ]);
            } else if matches!(w, W::B | W::W) {
                v.extend([Item::AluImm { op: Alu::Or, w: W::D, rm: Rm::Reg(R), imm: 1 << n }, Item::Bsf { w: W::D, reg: R, rm: Rm::Reg(R) }]);
            } else {
                v.extend([
                    Item::Bsf { w, reg: R, rm: Rm::Reg(R) },
                    Item::SetReg(C, n as u64),
                    Item::Cmov { cond: Cond::Z, w: W::D, reg: R, rm: Rm::Reg(C) },
                ]);
            }
            v.push(st(W::D, slot(0)));
        }
        // `(a > b) - (a < b)`: both flags of one `cmp`, `setcc` writing none.
        Class::Cmp3(signed, w) => {
            let (lt, gt) = if signed { (Cond::L, Cond::G) } else { (Cond::B, Cond::A) };
            v.extend([
                ld(w, slot(1)),
                Item::Alu { op: Alu::Cmp, w, reg: R, rm: Rm::Mem(slot(2)) },
                Item::SetccCl(lt),
                Item::SetccR(gt, R),
                Item::Alu { op: Alu::Sub, w: W::B, reg: R, rm: Rm::Reg(C) },
                st(W::B, slot(0)),
            ]);
        }
        Class::Bswap(w) => {
            v.push(ld(w, slot(1)));
            if w == W::W {
                // The swapped halfword in the upper half of the 32-bit swap.
                v.extend([Item::Bswap { w: W::D, reg: R }, Item::Shift { op: Sh::Shr, w: W::D, reg: R, amt: 16 }]);
            } else {
                v.push(Item::Bswap { w, reg: R });
            }
            v.push(st(w, slot(0)));
        }
        Class::Cmp(c, w) => {
            v.extend([ld(w, slot(1)), Item::Alu { op: Alu::Cmp, w, reg: R, rm: Rm::Mem(slot(2)) }, Item::Setcc { cond: c, m: slot(0) }])
        }
        Class::CmpImm(c, w) => {
            cmp_imm(&mut v, w, slot(1), imm(2));
            v.push(Item::Setcc { cond: c, m: slot(0) });
        }
        Class::Br => {
            v.push(Item::TestM8(slot(0)));
            br = cond(1, Cond::Nz);
        }
        Class::BrCmp(c, w) => {
            v.extend([ld(w, slot(0)), Item::Alu { op: Alu::Cmp, w, reg: R, rm: Rm::Mem(slot(1)) }]);
            br = cond(2, c);
        }
        Class::BrCmpImm(c, w) => {
            cmp_imm(&mut v, w, slot(0), imm(1));
            br = cond(2, c);
        }
        // `d, o, a, b`: the result in `rax`, stored first (the store leaves the flags alone),
        // then the flag through `cl`, so overlapping outputs end as the handlers leave them.
        Class::Ovf(op, signed, w) => {
            v.extend([ld(w, slot(2)), Item::Alu { op, w, reg: R, rm: Rm::Mem(slot(3)) }, st(w, slot(0))]);
            flag(&mut v, if signed { Cond::O } else { Cond::B }, slot(1));
        }
        Class::MulOvf(signed, w) => {
            let (a, b) = (slot(2), slot(3));
            let cond = match (signed, w) {
                (true, W::D | W::Q) => {
                    v.extend([ld(w, a), Item::Imul { w, reg: R, rm: Rm::Mem(b) }]);
                    Cond::O
                }
                (false, W::Q) => {
                    v.extend([ld(w, a), Item::MulQ(Rm::Mem(b))]);
                    Cond::B
                }
                (false, W::D) => {
                    // The 64-bit product of the zero-extended operands, above `u32::MAX`.
                    v.extend([
                        ld(w, a),
                        Item::Ld { w, sx: false, dst: C, m: b },
                        Item::Imul { w: W::Q, reg: R, rm: Rm::Reg(C) },
                        Item::SetReg(C, u32::MAX as u64),
                        Item::Alu { op: Alu::Cmp, w: W::Q, reg: R, rm: Rm::Reg(C) },
                    ]);
                    Cond::A
                }
                // 8 and 16 bits: the exact product in 32 bits, out of the width's range.
                (_, _) => {
                    let max = if w == W::B { 0xff } else { 0xffff };
                    v.extend([
                        Item::Ld { w, sx: signed, dst: R, m: a },
                        Item::Ld { w, sx: signed, dst: C, m: b },
                        Item::Imul { w: W::D, reg: R, rm: Rm::Reg(C) },
                    ]);
                    if signed {
                        // `p + 2^(n-1)` above `2^n - 1` (as `u32`).
                        v.extend([Item::LeaM { dst: C, m: M::rax(max / 2 + 1) }, Item::AluImm { op: Alu::Cmp, w: W::D, rm: Rm::Reg(C), imm: max }]);
                    } else {
                        v.push(Item::AluImm { op: Alu::Cmp, w: W::D, rm: Rm::Reg(R), imm: max });
                    }
                    Cond::A
                }
            };
            v.push(st(w, slot(0)));
            flag(&mut v, cond, slot(1));
        }
        Class::Ext { from, to, sx } => {
            if sx && to == W::Q {
                let n = 64 - from.bits() as u8;
                v.extend([
                    ld(from, slot(1)),
                    Item::Shift { op: Sh::Shl, w: W::Q, reg: R, amt: n },
                    Item::Shift { op: Sh::Sar, w: W::Q, reg: R, amt: n },
                ]);
            } else {
                v.push(Item::Ld { w: from, sx, dst: R, m: slot(1) });
            }
            v.push(st(to, slot(0)));
        }
    }
    Some((v, br))
}

impl Class {
    /// The class with its conditions dropped: what a sequence shows without its polarity.
    fn key(self) -> Class {
        match self {
            Class::Cmp(_, w) => Class::Cmp(Cond::Z, w),
            Class::CmpImm(_, w) => Class::CmpImm(Cond::Z, w),
            Class::BrCmp(_, w) => Class::BrCmp(Cond::Z, w),
            Class::BrCmpImm(_, w) => Class::BrCmpImm(Cond::Z, w),
            Class::Ovf(op, _, w) => Class::Ovf(op, false, w),
            Class::MulOvf(_, w) => Class::MulOvf(false, w),
            c => c,
        }
    }
}

/// The class (its [`Class::key`]) of the sequence `items`, ending in a branch if `br`: a
/// quick filter for [`decode`], which checks the rest.
fn classify(items: &[Item], br: bool) -> Option<Class> {
    use super::x86::Alu as Op;
    use Item::*;
    let z = Cond::Z;
    let frame = |m: &M| m.base == Reg::Rbp;
    // The new items first: they make the sequence one of theirs.
    if items.iter().any(|it| matches!(it, ShiftCl { .. })) {
        let (Some(ShiftCl { op, .. }), [.., St { w, .. }]) = (items.iter().find(|it| matches!(it, ShiftCl { .. })), items) else { return None };
        return (!br).then_some(Class::ShiftVar(*op, *w));
    }
    if let Some(Div { signed, .. }) = items.iter().find(|it| matches!(it, Div { .. })) {
        let [.., St { w, src, .. }] = items else { return None };
        return (!br).then_some(Class::Div { signed: *signed, rem: *src == Reg::Rdx, w: *w });
    }
    // The width from the immediate (the guard bit, or `n` or `2n - 1` in `rcx`).
    if let Some(lz) = items.iter().find_map(|it| match it {
        Bsf { .. } => Some(false),
        Bsr { .. } => Some(true),
        _ => None,
    }) {
        let n = items.iter().find_map(|it| match *it {
            AluImm { op: Op::Or, imm, .. } => Some(imm.trailing_zeros()),
            SetReg(Reg::Rcx, v) => Some(if lz { (v as u32).div_ceil(2) } else { v as u32 }),
            _ => None,
        })?;
        let w = [W::B, W::W, W::D, W::Q].into_iter().find(|w| w.bits() == n)?;
        return (!br).then_some(Class::Count { lz, w });
    }
    // Before the overflow ops, which have a `setcc cl` too.
    if let Some(SetccR(c, _)) = items.iter().find(|it| matches!(it, SetccR(..))) {
        let w = items.iter().find_map(|it| match it {
            Alu { op: Op::Cmp, w, .. } => Some(*w),
            _ => None,
        })?;
        return (!br).then_some(Class::Cmp3(*c == Cond::G, w));
    }
    if items.iter().any(|it| matches!(it, Bswap { .. })) {
        let [.., St { w, .. }] = items else { return None };
        return (!br).then_some(Class::Bswap(*w));
    }
    // An overflow op: the result's store, then its flag.
    if items.iter().any(|it| matches!(it, SetccCl(_))) {
        let [.., St { w, src: Reg::Rax, .. }, SetccCl(_), St { .. }] = items else { return None };
        return Some(if items.iter().any(|it| matches!(it, MulQ(_) | Imul { .. })) {
            Class::MulOvf(false, *w)
        } else {
            let op = items.iter().find_map(|it| match it {
                Alu { op, .. } => Some(*op),
                _ => None,
            })?;
            Class::Ovf(op, false, *w)
        });
    }
    Some(match (items, br) {
        ([TestM8(_)], true) => Class::Br,
        ([Ld { w, .. }, Alu { op: Op::Cmp, rm: Rm::Mem(_), .. }], true) => Class::BrCmp(z, *w),
        ([AluImm { op: Op::Cmp, w, .. }], true) | ([Ld { .. }, SetReg(..), Alu { op: Op::Cmp, w, .. }], true) => Class::BrCmpImm(z, *w),
        (_, true) => return None,
        ([Ld { w, .. }, Alu { op: Op::Cmp, rm: Rm::Mem(_), .. }, Setcc { .. }], _) => Class::Cmp(z, *w),
        ([AluImm { op: Op::Cmp, w, .. }, Setcc { .. }], _) | ([Ld { .. }, SetReg(..), Alu { op: Op::Cmp, w, .. }, Setcc { .. }], _) => {
            Class::CmpImm(z, *w)
        }
        ([StImm { w, .. }], _) => Class::Imm(*w),
        ([SetReg(..), St { .. }], _) => Class::Imm(W::Q),
        ([Ld { w, sx: false, .. }, St { w: t, m, .. }], _) if frame(m) && w == t => Class::Mov(*w),
        ([Ld { w, sx, .. }, St { w: to, m, .. }], _) if frame(m) => Class::Ext { from: *w, to: *to, sx: *sx },
        ([Ld { w, .. }, Shift { op: Sh::Shl, .. }, Shift { op: Sh::Sar, .. }, St { w: to, .. }], _) => Class::Ext { from: *w, to: *to, sx: true },
        ([Ld { .. }, Ld { dst: Reg::Rcx, m: a, .. }, St { src: Reg::Rcx, m: b, .. }, St { m, .. }], _) if frame(a) && frame(b) && frame(m) => {
            Class::Mov128
        }
        ([LeaM { .. }, St { .. }], _) => Class::Addr,
        ([Lea(_, Ref::Const(_) | Ref::Data(_)), St { .. }], _) => Class::AddrConst,
        ([LoadRip(_, Ref::Sym(_)), St { .. }], _) => Class::AddrSym,
        ([LoadRip(_, Ref::Sym(_)), Ld { .. }, St { .. }], _) => Class::AddrSymInd,
        ([Ld { .. }, LeaM { .. }, St { .. }], _) => Class::PtrAdd,
        ([Ld { .. }, ImulImm { .. }, Alu { .. }, St { .. }], _) => Class::PtrIndex,
        ([Ld { .. }, Ld { .. }, St { w, m, .. }], _) if !frame(m) => Class::Store(*w),
        ([Ld { .. }, Ld { m, .. }, St { w, .. }], _) if !frame(m) => Class::Load(*w),
        ([Ld { .. }, Alu { op, rm: Rm::Mem(_), .. }, St { w, .. }], _) => Class::Bin(*op, *w),
        ([Ld { .. }, AluImm { op, .. }, St { w, .. }], _) | ([Ld { .. }, SetReg(..), Alu { op, .. }, St { w, .. }], _) => Class::BinImm(*op, *w),
        ([Ld { .. }, Imul { rm: Rm::Mem(_), .. }, St { w, .. }], _) | ([Ld { .. }, Ld { .. }, Imul { .. }, St { w, .. }], _) => Class::Mul(*w),
        ([ImulImm { .. }, St { w, .. }], _)
        | ([Ld { .. }, ImulImm { .. }, St { w, .. }], _)
        | ([Ld { .. }, SetReg(..), Imul { .. }, St { w, .. }], _) => Class::MulImm(*w),
        ([Ld { .. }, Shift { op, .. }, St { w, .. }], _) => Class::ShiftImm(*op, *w),
        _ => return None,
    })
}

/// The instruction an inline sequence encodes: its items, and its final branch (condition and
/// target) for a branch. The operands come from the sequence's fields: frame displacements in
/// order (`d`, where there is one, last), the `rax` displacement (a memory operand's offset,
/// or `ptr.add`'s), the immediate, and the rip item's [`Ref`]; the result must re-encode to
/// the same sequence.
pub(super) fn decode(items: &[Item], branch: Option<(Cond, u32)>) -> Option<(Opcode, Vec<Opnd>)> {
    let key = classify(items, branch.is_some())?;
    ALL_OPCODES.iter().filter(|&&op| class(op).map(Class::key) == Some(key)).find_map(|&op| decode_as(op, items, branch))
}

/// [`decode`] as the instruction `op` only (an instruction list entry names it).
pub(super) fn decode_op(op: Opcode, items: &[Item], branch: Option<(Cond, u32)>) -> Option<(Opcode, Vec<Opnd>)> {
    let key = classify(items, branch.is_some())?;
    if class(op).map(Class::key) != Some(key) {
        return None;
    }
    decode_as(op, items, branch)
}

/// The operands of `items` (and `branch`) read as `op`, if they re-encode to the same
/// sequence.
fn decode_as(op: Opcode, items: &[Item], branch: Option<(Cond, u32)>) -> Option<(Opcode, Vec<Opnd>)> {
    let frame: Vec<i32> = items.iter().filter_map(Item::mem).filter(|m| m.base == Reg::Rbp).map(|m| m.disp).collect();
    let rax = items.iter().filter_map(Item::mem).find(|m| m.base == Reg::Rax).map(|m| m.disp);
    let imm = items.iter().find_map(Item::imm).or(rax.map(|k| k as i64 as u64)).unwrap_or(0);
    let rip = items.iter().find_map(|it| match *it {
        Item::Lea(_, to) | Item::LoadRip(_, to) => Some(to),
        _ => None,
    });
    {
        let info = op.info();
        let ovf = info.operand_index("o").is_some();
        let mut f = frame.iter().copied();
        let mut ops = Vec::with_capacity(info.operands.len());
        for o in info.operands {
            ops.push(match o.kind {
                // An overflow op's result, stored before its flag.
                OperandKind::Slot if o.name == "d" && ovf => Opnd::Slot(*frame.get(frame.len().checked_sub(2)?)?),
                OperandKind::Slot if o.name == "d" => Opnd::Slot(*frame.last()?),
                OperandKind::Slot if o.name == "o" => Opnd::Slot(*frame.last()?),
                OperandKind::Slot => Opnd::Slot(f.next()?),
                OperandKind::Mem => Opnd::Mem(f.next()?, rax?),
                OperandKind::U8 => Opnd::Imm(imm as u8 as u64),
                OperandKind::U16 => Opnd::Imm(imm as u16 as u64),
                OperandKind::U32 => Opnd::Imm(imm as u32 as u64),
                OperandKind::U64 | OperandKind::I64 => Opnd::Imm(imm),
                OperandKind::Neg => Opnd::Neg(false),
                OperandKind::Target => Opnd::Target(branch?.1),
                OperandKind::Abs => match rip? {
                    Ref::Const(k) => Opnd::Const(k),
                    Ref::Data(d) => Opnd::Data(d),
                    _ => return None,
                },
                OperandKind::Sym => match rip? {
                    Ref::Sym(s) => Opnd::Sym(s),
                    _ => return None,
                },
                _ => unreachable!("not an inline operand"),
            });
        }
        for neg in [false, true] {
            if let Some(i) = info.operand_index("neg") {
                ops[i] = Opnd::Neg(neg);
            } else if neg {
                break;
            }
            if let Some((v, b)) = sequence(op, &ops)
                && v == items
                && b == branch.map(|b| b.0)
            {
                return Some((op, ops));
            }
        }
    }
    None
}

/// The registers inline sequences compute in: the caller-saved ones but `rcx`, the sequences'
/// scratch register. Every handler call clobbers them anyway. On PE `rsi` and `rdi` are
/// callee-saved (Win64 handlers preserve them, and VM functions must), so sequences don't
/// compute in them there ([`Cache::new`]).
pub(super) const POOL: [Reg; 8] = [Reg::Rax, Reg::Rdx, Reg::Rsi, Reg::Rdi, Reg::R8, Reg::R9, Reg::R10, Reg::R11];

/// What a [`POOL`] register is known to hold.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
struct Entry {
    /// The zero-extended value of the frame slot at this displacement and width.
    slot: Option<(i32, W)>,
    /// The register is the zero-extension of its low bytes of this width.
    zx: Option<W>,
    /// When the register was last used ([`Cache::tick`]).
    used: u32,
}

/// The register cache (design/vm.md, "Register cache"): what the [`POOL`] registers hold
/// between inline sequences, frame slots by displacement (raw or resolved: the rules only
/// compare displacements). Each sequence computes in a register of its own choosing
/// ([`Cache::emit`]), so values survive the sequences after it, and frame operands held in a
/// register are read from it. Every store still happens, so the frame stays up to date.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub(super) struct Cache {
    regs: [Entry; POOL.len()],
    /// Sequences emitted.
    tick: u32,
    /// PE: `rsi` and `rdi` aren't in the pool ([`POOL`]).
    pe: bool,
}

/// Whether the `n`-byte range at `a` overlaps the `m`-byte one at `b` (wrapping: raw slots
/// are biased).
fn overlaps(a: i32, n: u32, b: i32, m: u32) -> bool {
    (b.wrapping_sub(a) as u32) < n || (a.wrapping_sub(b) as u32) < m
}

fn pool(r: Reg) -> Option<usize> {
    POOL.iter().position(|&p| p == r)
}

/// The frame slot `[rbp + d]` of an `r/m` operand that only reads it, and the width read.
fn read_operand(it: &Item) -> Option<(M, W)> {
    match *it {
        Item::Alu { w, rm: Rm::Mem(m), .. } | Item::AluImm { op: Alu::Cmp, w, rm: Rm::Mem(m), .. } => Some((m, w)),
        Item::Imul { w, rm: Rm::Mem(m), .. } | Item::ImulImm { w, rm: Rm::Mem(m), .. } => Some((m, w)),
        Item::MulQ(Rm::Mem(m)) => Some((m, W::Q)),
        Item::Div { w, rm: Rm::Mem(m), .. } => Some((m, w)),
        _ => None,
    }
    .filter(|(m, _)| m.base == Reg::Rbp)
}

/// The item with its `r/m` operand replaced.
fn with_rm(it: Item, rm: Rm) -> Item {
    match it {
        Item::Alu { op, w, reg, .. } => Item::Alu { op, w, reg, rm },
        Item::AluImm { op, w, imm, .. } => Item::AluImm { op, w, rm, imm },
        Item::Imul { w, reg, .. } => Item::Imul { w, reg, rm },
        Item::ImulImm { w, reg, imm, .. } => Item::ImulImm { w, reg, rm, imm },
        Item::MulQ(_) => Item::MulQ(rm),
        Item::Div { signed, w, .. } => Item::Div { signed, w, rm },
        it => it,
    }
}

/// The register read by an `r/m` register operand of an item that could have read the frame
/// there instead.
fn read_reg(it: &Item) -> Option<Reg> {
    match *it {
        Item::Alu { rm: Rm::Reg(r), .. } | Item::AluImm { op: Alu::Cmp, rm: Rm::Reg(r), .. } => Some(r),
        Item::Imul { rm: Rm::Reg(r), .. } | Item::ImulImm { rm: Rm::Reg(r), .. } | Item::MulQ(Rm::Reg(r)) | Item::Div { rm: Rm::Reg(r), .. } => {
            Some(r)
        }
        _ => None,
    }
}

/// Whether `POOL[i]` is in the pool on PE (`pe`) or elsewhere.
fn in_pool(pe: bool, i: usize) -> bool {
    !(pe && matches!(POOL[i], Reg::Rsi | Reg::Rdi))
}

impl Cache {
    /// An empty cache, for code of a PE target (`pe`) or another.
    pub(super) fn new(pe: bool) -> Cache {
        Cache { pe, ..Cache::default() }
    }

    /// The register holding the slot at `m` (a frame operand) at width `w` exactly, or at
    /// least `w` wide unless `exact`.
    fn find(&self, m: M, w: W, exact: bool) -> Option<usize> {
        if m.base != Reg::Rbp {
            return None;
        }
        self.regs.iter().position(|e| e.slot.is_some_and(|(s, sw)| s == m.disp && if exact { sw == w } else { sw.bytes() >= w.bytes() }))
    }

    /// The register a sequence that doesn't start by reloading a cached slot computes in: an
    /// empty one if there is one, the least recently used first.
    fn fresh(&self) -> usize {
        (0..POOL.len()).filter(|&i| in_pool(self.pe, i)).min_by_key(|&i| (self.regs[i].slot.is_some(), self.regs[i].used, i)).unwrap()
    }

    /// `items` (an inline sequence, on `rax`) as emitted with the cache, which is updated to
    /// after it. The sequence computes in the register that holds its first operand's slot,
    /// dropping the reload, or else in [`Cache::fresh`]; frame operands held in a register
    /// are read from it. Only the first item can be dropped. A `mul` or `div` (`rdx:rax`) computes in
    /// `rax`, dropping the reload only if `rax` holds it.
    pub(super) fn emit(&mut self, items: &[Item]) -> Vec<Item> {
        self.emit_sel(items).0
    }

    /// [`Cache::emit`], and the selector by which [`Cache::invert`] recovers `items` from what
    /// it emitted, or `None` if it emitted `items` unchanged (plainly): the register computed
    /// in (bits 0-2), whether its reload was dropped (bit 3), and from bit 4 on, by emitted
    /// item, the ones whose register operand, the computing register, was a frame operand.
    pub(super) fn emit_sel(&mut self, items: &[Item]) -> (Vec<Item>, Option<u32>) {
        self.tick += 1;
        let mut out = Vec::with_capacity(items.len());
        let mut rest = items;
        let pinned = items.iter().any(|it| matches!(it, Item::MulQ(_) | Item::Div { .. }));
        let x = match items.first() {
            Some(&Item::Ld { w, sx: false, dst: R, m }) if pinned => {
                if self.regs[0].slot == Some((m.disp, w)) && m.base == Reg::Rbp {
                    rest = &items[1..];
                }
                0
            }
            Some(&Item::Ld { w, sx: false, dst: R, m }) if let Some(i) = self.find(m, w, true) => {
                rest = &items[1..];
                i
            }
            _ if pinned => 0,
            _ => self.fresh(),
        };
        self.regs[x].used = self.tick;
        let xr = POOL[x];
        let mut sel = x as u32 | ((rest.len() != items.len()) as u32) << 3;
        for &it in rest {
            let mut it = it.map_regs(|r| if r == R { xr } else { r });
            if let Some((m, w)) = read_operand(&it)
                && let Some(i) = self.find(m, w, false)
            {
                it = with_rm(it, Rm::Reg(POOL[i]));
                self.regs[i].used = self.tick;
                if i == x {
                    sel |= 1 << (4 + out.len());
                }
            }
            self.update(&it);
            out.push(it);
        }
        let plain = out == items;
        (out, (!plain).then_some(sel))
    }

    /// The sequence on `rax` that [`Cache::emit`] turned into `items` with the selector `sel`
    /// ([`Cache::emit_sel`]), or `None` if `sel` doesn't fit them. The decoder checks it by
    /// emitting it again. The inverse of the one [`Cache::unemit`] candidate `sel` names.
    pub(super) fn invert(&self, items: &[Item], sel: u32) -> Option<Vec<Item>> {
        let x = (sel & 7) as usize;
        if !in_pool(self.pe, x) {
            return None;
        }
        let xr = POOL[x];
        let back = |r: Reg| {
            if r == xr {
                R
            } else if r == R {
                xr
            } else {
                r
            }
        };
        let mut c = *self;
        let mut out = Vec::with_capacity(items.len() + 1);
        if sel & 8 != 0 {
            let (s, w) = c.regs[x].slot?;
            out.push(Item::Ld { w, sx: false, dst: R, m: M::frame(s) });
        }
        for (j, &it) in items.iter().enumerate() {
            // Another register than the computing one is always a cached slot.
            let bit = sel >> (4 + j) & 1 != 0;
            let frame = match read_reg(&it).and_then(pool).map(|i| (i, c.regs[i].slot)) {
                Some((i, Some((s, _)))) if i != x || bit => Some(Rm::Mem(M::frame(s))),
                _ if bit => return None,
                _ => None,
            };
            out.push(match frame {
                Some(m) => with_rm(it, m).map_regs(back),
                None => it.map_regs(back),
            });
            c.update(&it);
        }
        (sel >> (4 + items.len()) == 0).then_some(out)
    }

    /// The sequences on `rax` that [`Cache::emit`] may have turned into `items`, for the
    /// decoder, which checks each by emitting it again: for each register the sequence may
    /// have computed in, with the register renamed back, register operands that may have
    /// been frame operands put back, and the dropped reload put back or not.
    pub(super) fn unemit(&self, items: &[Item]) -> Vec<Vec<Item>> {
        let mut out = Vec::new();
        // The register computed in appears in the items, unless the sequence computes
        // nothing in a register, when it is the one any would get.
        let mut xs: Vec<usize> = (0..POOL.len())
            .filter(|&i| in_pool(self.pe, i) && items.iter().any(|it| it.map_regs(|r| if r == POOL[i] { Reg::Rbp } else { r }) != *it))
            .collect();
        if xs.is_empty() {
            xs.push(self.fresh());
        }
        // A `mul` or `div` computes in `rax`, which a remainder's sequence may not show.
        if items.iter().any(|it| matches!(it, Item::MulQ(_) | Item::Div { .. })) {
            xs = vec![0];
        }
        for x in xs {
            let xr = POOL[x];
            // The registers swapped, so nothing else becomes `rax`.
            let back = |r: Reg| {
                if r == xr {
                    R
                } else if r == R {
                    xr
                } else {
                    r
                }
            };
            for reload in [false, true] {
                let mut c = *self;
                let mut head = Vec::new();
                if reload {
                    let Some((s, w)) = c.regs[x].slot else { continue };
                    head.push(Item::Ld { w, sx: false, dst: R, m: M::frame(s) });
                }
                // Each register operand: as it is, or the frame slot its register held.
                let mut alts: Vec<Vec<Item>> = vec![head];
                for &it in items {
                    let mut opts = vec![it.map_regs(back)];
                    if let Some(r) = read_reg(&it)
                        && let Some(i) = pool(r)
                        && let Some((s, _)) = c.regs[i].slot
                    {
                        let m = Rm::Mem(M::frame(s));
                        let o = with_rm(it, m).map_regs(back);
                        // Another register than the computing one is always a cached slot.
                        if i == x {
                            opts.push(o);
                        } else {
                            opts = vec![o];
                        }
                    }
                    c.update(&it);
                    alts = alts
                        .into_iter()
                        .flat_map(|a| {
                            opts.iter().map(move |&o| {
                                let mut a = a.clone();
                                a.push(o);
                                a
                            })
                        })
                        .collect();
                }
                out.extend(alts);
            }
        }
        out
    }

    /// Updates the cache for an emitted item of an inline sequence.
    fn update(&mut self, item: &Item) {
        // Frame writes drop the slots they overlap; stores through a pointer drop every slot
        // (it may point into the frame).
        let mut write = |m: M, n: u32| {
            for e in &mut self.regs {
                if m.base != Reg::Rbp || e.slot.is_some_and(|(s, w)| overlaps(s, w.bytes(), m.disp, n)) {
                    e.slot = None;
                }
            }
        };
        match *item {
            Item::St { w, m, .. } | Item::StImm { w, m, .. } => write(m, w.bytes()),
            Item::Setcc { m, .. } => write(m, 1),
            _ => {}
        }
        // Register writes. Ops at 32 or 64 bits leave the register zero-extended from their
        // width; at 8 or 16 bits they keep the bits above.
        let wide = |w: W| matches!(w, W::D | W::Q).then_some(w);
        let (r, slot, zx) = match *item {
            Item::Ld { w, sx, dst, m } => (dst, (!sx && m.base == Reg::Rbp).then_some((m.disp, w)), Some(if sx { W::D } else { w })),
            Item::Alu { op, w, reg, .. } if op != Alu::Cmp => (reg, None, wide(w)),
            Item::AluImm { op, w, rm: Rm::Reg(reg), .. } if op != Alu::Cmp => (reg, None, wide(w)),
            Item::Imul { w, reg, .. }
            | Item::ImulImm { w, reg, .. }
            | Item::Shift { w, reg, .. }
            | Item::ShiftCl { w, reg, .. }
            | Item::Bswap { w, reg }
            | Item::Cmov { w, reg, .. } => (reg, None, wide(w)),
            Item::LeaM { dst, .. } | Item::SetReg(dst, _) | Item::Lea(dst, _) | Item::LoadRip(dst, _) => (dst, None, Some(W::Q)),
            Item::Cdq(_) => (Reg::Rdx, None, None),
            Item::SetccR(_, reg) => (reg, None, None),
            // Undefined on zero at 64 bits (the 32-bit forms are followed by a `cmov`, or their
            // source isn't zero).
            Item::Bsf { w, reg, .. } | Item::Bsr { w, reg, .. } => (reg, None, (w == W::D).then_some(W::D)),
            Item::Div { w, .. } => {
                let d = pool(Reg::Rdx).unwrap();
                self.regs[d] = Entry { used: self.regs[d].used, zx: Some(w), ..Entry::default() };
                (Reg::Rax, None, Some(w))
            }
            Item::MulQ(_) => {
                self.regs[pool(Reg::Rdx).unwrap()] = Entry { used: self.regs[pool(Reg::Rdx).unwrap()].used, ..Entry::default() };
                (Reg::Rax, None, Some(W::Q))
            }
            Item::St { w, src, m } => {
                // The register is the zero-extension of the value stored when its known
                // extension is no wider than the store.
                if let Some(i) = pool(src)
                    && m.base == Reg::Rbp
                    && self.regs[i].zx.is_some_and(|z| z.bytes() <= w.bytes())
                {
                    self.regs[i].slot = Some((m.disp, w));
                }
                return;
            }
            _ => return,
        };
        if let Some(i) = pool(r) {
            self.regs[i].slot = slot;
            self.regs[i].zx = zx;
        }
    }
}
