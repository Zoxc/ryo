//! The inline form of the common VM instructions (design/vm.md, "Inline instructions"):
//! moves, immediates, address arithmetic, loads and stores, integer add/sub/logic/multiply,
//! shifts by an immediate, compares and compare-branches, at widths up to 64 bits. They
//! are short native sequences on `rax` and `rcx` instead of handler calls.
//!
//! Every sequence ends in its one write (to the frame or to memory), or in a conditional
//! branch, and no other element of a sequence writes anything, so the decoder knows where a
//! sequence ends. Each opcode has one sequence per operand pattern, and no two opcodes share
//! one: the decoder recovers the opcode and operands by matching against [`sequence`].

use alloc::vec::Vec;

use super::encode::Opnd;
use super::x86::{Alu, Cond, Item, M, Reg, Rm, Sh, W};
use crate::insn::{ALL_OPCODES, OperandKind, Opcode};

/// The inline sequence kinds, by the opcode's operation and width.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Class {
    Mov(W),
    Imm(W),
    Addr,
    PtrAdd,
    PtrIndex,
    Load(W),
    Store(W),
    Bin(Alu, W),
    BinImm(Alu, W),
    Mul(W),
    MulImm(W),
    ShiftImm(Sh, W),
    /// A compare to a `bool`, the condition for true.
    Cmp(Cond, W),
    CmpImm(Cond, W),
    Br,
    /// A compare-branch, the condition to branch on without `neg`.
    BrCmp(Cond, W),
    BrCmpImm(Cond, W),
}

#[rustfmt::skip]
fn class(op: Opcode) -> Option<Class> {
    use Class::{Bin, BinImm, BrCmp, BrCmpImm, Cmp, CmpImm, Imm, Load, Mov, Mul, MulImm, ShiftImm, Store};
    use Opcode::*;
    Some(match op {
        MovW8 => Mov(W::B), MovW16 => Mov(W::W), MovW32 => Mov(W::D), MovW64 => Mov(W::Q),
        ImmW8 => Imm(W::B), ImmW16 => Imm(W::W), ImmW32 => Imm(W::D), ImmW64 => Imm(W::Q),
        LoadW8 => Load(W::B), LoadW16 => Load(W::W), LoadW32 => Load(W::D), LoadW64 => Load(W::Q),
        StoreW8 => Store(W::B), StoreW16 => Store(W::W), StoreW32 => Store(W::D), StoreW64 => Store(W::Q),
        Addr => Class::Addr,
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
        _ => return None,
    })
}

/// Whether instructions of `op` are inlined, for some operands at least: `ptr.add` only with a 32-bit offset, `ptr.index` with a stride
/// below 2^31, shifts by less than the width.
pub fn has_inline(op: Opcode) -> bool {
    class(op).is_some()
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
        Class::Imm(w) => {
            let x = imm(1);
            if w != W::Q || fits(x) {
                v.push(Item::StImm { w, m: slot(0), imm: w.sext(x) as i32 });
            } else {
                v.extend([Item::SetReg(R, x), st(W::Q, slot(0))]);
            }
        }
        Class::Addr => v.extend([Item::LeaM { dst: R, m: slot(1) }, st(W::Q, slot(0))]),
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
                W::B | W::W => v.extend([
                    ld(w, slot(1)),
                    Item::Ld { w, sx: false, dst: C, m: slot(2) },
                    Item::Imul { w: W::D, reg: R, rm: Rm::Reg(C) },
                ]),
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
        Class::Cmp(c, w) => v.extend([
            ld(w, slot(1)),
            Item::Alu { op: Alu::Cmp, w, reg: R, rm: Rm::Mem(slot(2)) },
            Item::Setcc { cond: c, m: slot(0) },
        ]),
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
        ([Ld { w, .. }, St { m, .. }], _) if frame(m) => Class::Mov(*w),
        ([LeaM { .. }, St { .. }], _) => Class::Addr,
        ([Ld { .. }, LeaM { .. }, St { .. }], _) => Class::PtrAdd,
        ([Ld { .. }, ImulImm { .. }, Alu { .. }, St { .. }], _) => Class::PtrIndex,
        ([Ld { .. }, Ld { .. }, St { w, m, .. }], _) if !frame(m) => Class::Store(*w),
        ([Ld { .. }, Ld { m, .. }, St { w, .. }], _) if !frame(m) => Class::Load(*w),
        ([Ld { .. }, Alu { op, rm: Rm::Mem(_), .. }, St { w, .. }], _) => Class::Bin(*op, *w),
        ([Ld { .. }, AluImm { op, .. }, St { w, .. }], _) | ([Ld { .. }, SetReg(..), Alu { op, .. }, St { w, .. }], _) => {
            Class::BinImm(*op, *w)
        }
        ([Ld { .. }, Imul { rm: Rm::Mem(_), .. }, St { w, .. }], _) | ([Ld { .. }, Ld { .. }, Imul { .. }, St { w, .. }], _) => {
            Class::Mul(*w)
        }
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
/// or `ptr.add`'s), and the immediate; the result must re-encode to the same sequence.
pub(super) fn decode(items: &[Item], branch: Option<(Cond, u32)>) -> Option<(Opcode, Vec<Opnd>)> {
    let key = classify(items, branch.is_some())?;
    let frame: Vec<i32> = items.iter().filter_map(Item::mem).filter(|m| m.base == Reg::Rbp).map(|m| m.disp).collect();
    let rax = items.iter().filter_map(Item::mem).find(|m| m.base == Reg::Rax).map(|m| m.disp);
    let imm = items.iter().find_map(Item::imm).or(rax.map(|k| k as i64 as u64)).unwrap_or(0);
    for &op in ALL_OPCODES {
        if class(op).map(Class::key) != Some(key) {
            continue;
        }
        let info = op.info();
        let mut f = frame.iter().copied();
        let mut ops = Vec::with_capacity(info.operands.len());
        for o in info.operands {
            ops.push(match o.kind {
                OperandKind::Slot if o.name == "d" => Opnd::Slot(*frame.last()?),
                OperandKind::Slot => Opnd::Slot(f.next()?),
                OperandKind::Mem => Opnd::Mem(f.next()?, rax?),
                OperandKind::U8 => Opnd::Imm(imm as u8 as u64),
                OperandKind::U16 => Opnd::Imm(imm as u16 as u64),
                OperandKind::U32 => Opnd::Imm(imm as u32 as u64),
                OperandKind::U64 | OperandKind::I64 => Opnd::Imm(imm),
                OperandKind::Neg => Opnd::Neg(false),
                OperandKind::Target => Opnd::Target(branch?.1),
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
