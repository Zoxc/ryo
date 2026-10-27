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
use super::frame::Access;
use super::x86::{Alu, Cond, Item, M, Reg, Rm, Sh, W};
use crate::full::{ALL_OPCODES, Cc, Family, Opcode, OperandKind, Width};

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

/// The register width of an integer width, `None` for `w128`.
const fn reg_width(w: Width) -> Option<W> {
    Some(match w {
        Width::W8 => W::B,
        Width::W16 => W::W,
        Width::W32 => W::D,
        Width::W64 => W::Q,
        Width::W128 => return None,
    })
}

/// The condition for true of a compare family's condition.
const fn cond(cc: Cc) -> Cond {
    match cc {
        Cc::Eq => Cond::Z,
        Cc::Ne => Cond::Nz,
        Cc::LtS => Cond::L,
        Cc::LtU => Cond::B,
        Cc::LeS => Cond::Le,
        Cc::LeU => Cond::Be,
        Cc::GtS => Cond::G,
        Cc::GtU => Cond::A,
        Cc::GeS => Cond::Ge,
        Cc::GeU => Cond::Ae,
    }
}

/// [`class`] by opcode value.
static CLASSES: [Option<Class>; Opcode::COUNT] = {
    let mut t = [None; Opcode::COUNT];
    let mut i = 0;
    while i < Opcode::COUNT {
        t[i] = class_of(ALL_OPCODES[i]);
        i += 1;
    }
    t
};

fn class(op: Opcode) -> Option<Class> {
    CLASSES[op as usize]
}

/// `op`'s class: by its family and width for the families, up to 64 bits.
const fn class_of(op: Opcode) -> Option<Class> {
    use Family as F;
    if let Some(e) = op.ext() {
        return match (reg_width(e.from), reg_width(e.to)) {
            (Some(from), Some(to)) => Some(Class::Ext { from, to, sx: e.sx }),
            _ => None,
        };
    }
    match op {
        Opcode::MovW128 => return Some(Class::Mov128),
        Opcode::Addr => return Some(Class::Addr),
        Opcode::AddrConst => return Some(Class::AddrConst),
        Opcode::AddrSym => return Some(Class::AddrSym),
        Opcode::AddrSymInd => return Some(Class::AddrSymInd),
        Opcode::PtrAdd => return Some(Class::PtrAdd),
        Opcode::PtrIndex => return Some(Class::PtrIndex),
        Opcode::Br => return Some(Class::Br),
        _ => {}
    }
    let Some((f, w)) = op.fw() else { return None };
    let Some(w) = w.int() else { return None };
    let Some(w) = reg_width(w) else { return None };
    if let Some(cc) = f.cc() {
        let c = cond(cc);
        return Some(match (f.is_branch(), f.imm()) {
            (false, false) => Class::Cmp(c, w),
            (false, true) => Class::CmpImm(c, w),
            (true, false) => Class::BrCmp(c, w),
            (true, true) => Class::BrCmpImm(c, w),
        });
    }
    let signed = matches!(f.signed(), Some(true));
    let alu = match f {
        F::Add | F::AddImm | F::AddOvfS | F::AddOvfU => Some(Alu::Add),
        F::Sub | F::SubImm | F::SubOvfS | F::SubOvfU => Some(Alu::Sub),
        F::And | F::AndImm => Some(Alu::And),
        F::Or | F::OrImm => Some(Alu::Or),
        F::Xor | F::XorImm => Some(Alu::Xor),
        _ => None,
    };
    let sh = match f {
        F::Shl | F::ShlImm => Some(Sh::Shl),
        F::ShrS | F::ShrSImm => Some(Sh::Sar),
        F::ShrU | F::ShrUImm => Some(Sh::Shr),
        F::Rotl => Some(Sh::Rol),
        F::Rotr => Some(Sh::Ror),
        _ => None,
    };
    Some(match f {
        F::Mov => Class::Mov(w),
        F::Imm => Class::Imm(w),
        F::Load => Class::Load(w),
        F::Store => Class::Store(w),
        F::Mul => Class::Mul(w),
        F::MulImm => Class::MulImm(w),
        F::DivS | F::DivU | F::RemS | F::RemU => Class::Div { signed, rem: matches!(f, F::RemS | F::RemU), w },
        F::Cttz | F::Ctlz => Class::Count { lz: matches!(f, F::Ctlz), w },
        F::Cmp3S | F::Cmp3U => Class::Cmp3(signed, w),
        F::Bswap => Class::Bswap(w),
        F::MulOvfS | F::MulOvfU => Class::MulOvf(signed, w),
        _ => match (sh, alu, f.imm()) {
            (Some(sh), _, true) => Class::ShiftImm(sh, w),
            (Some(sh), _, false) => Class::ShiftVar(sh, w),
            (None, Some(a), _) if matches!(f, F::AddOvfS | F::AddOvfU | F::SubOvfS | F::SubOvfU) => Class::Ovf(a, signed, w),
            (None, Some(a), true) => Class::BinImm(a, w),
            (None, Some(a), false) => Class::Bin(a, w),
            (None, None, _) => return None,
        },
    })
}

/// How the inline opcode `op` uses its slot and memory operands, in operand order (a memory
/// operand reads its 8-byte base pointer slot), or `None` if `op` has no inline form.
pub(super) fn frame_access(op: Opcode) -> Option<Vec<Access>> {
    use Access::{Read as R, Write as Wr};
    let n = |w: W| w.bytes();
    Some(match class(op)? {
        Class::Mov(w) | Class::Bswap(w) => vec![Wr(n(w)), R(n(w))],
        Class::Mov128 => vec![Wr(16), R(16)],
        Class::Imm(w) => vec![Wr(n(w))],
        Class::Addr => vec![Wr(8), Access::Addr],
        Class::AddrConst | Class::AddrSym | Class::AddrSymInd => vec![Wr(8)],
        Class::PtrAdd => vec![Wr(8), R(8)],
        Class::PtrIndex => vec![Wr(8), R(8), R(8)],
        Class::Load(w) => vec![Wr(n(w)), R(8)],
        Class::Store(w) => vec![R(8), R(n(w))],
        Class::Bin(_, w) | Class::Mul(w) | Class::ShiftVar(_, w) | Class::Div { w, .. } => vec![Wr(n(w)), R(n(w)), R(n(w))],
        Class::BinImm(_, w) | Class::MulImm(w) | Class::ShiftImm(_, w) => vec![Wr(n(w)), R(n(w))],
        // The count is a `u32`, the three-way compare an `i8`, at any width.
        Class::Count { w, .. } => vec![Wr(4), R(n(w))],
        Class::Cmp3(_, w) => vec![Wr(1), R(n(w)), R(n(w))],
        Class::Cmp(_, w) => vec![Wr(1), R(n(w)), R(n(w))],
        Class::CmpImm(_, w) => vec![Wr(1), R(n(w))],
        Class::Br => vec![R(1)],
        Class::BrCmp(_, w) => vec![R(n(w)), R(n(w))],
        Class::BrCmpImm(_, w) => vec![R(n(w))],
        // The result, then its overflow flag.
        Class::Ovf(_, _, w) | Class::MulOvf(_, w) => vec![Wr(n(w)), Wr(1), R(n(w)), R(n(w))],
        Class::Ext { from, to, .. } => vec![Wr(n(to)), R(n(from))],
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
    let w = match op.fw() {
        Some((Family::SwitchDense, w)) => reg_width(w.int()?)?,
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
    ALL_OPCODES.iter().find_map(|&op| decode_keyed(op, key, items, branch))
}

/// [`decode`] as the instruction `op` only (an instruction list entry names it).
pub(super) fn decode_op(op: Opcode, items: &[Item], branch: Option<(Cond, u32)>) -> Option<(Opcode, Vec<Opnd>)> {
    decode_keyed(op, classify(items, branch.is_some())?, items, branch)
}

/// [`decode_as`] if `op`'s class has the key `key` ([`classify`] of the items).
fn decode_keyed(op: Opcode, key: Class, items: &[Item], branch: Option<(Cond, u32)>) -> Option<(Opcode, Vec<Opnd>)> {
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

/// `xr` and `rax` swapped, other registers kept: the computing register renamed back, so that
/// nothing else becomes `rax`.
fn swap_rax(xr: Reg) -> impl Fn(Reg) -> Reg + Copy {
    move |r| {
        if r == xr {
            R
        } else if r == R {
            xr
        } else {
            r
        }
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
        let back = swap_rax(xr);
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
    /// decoder, which checks each by emitting it again: [`Cache::invert`] of every selector
    /// that may fit them. For each register the sequence may have computed in, with the
    /// dropped reload put back or not, each register operand of that register that may have
    /// been a frame operand put back or not (earlier items' choices first, as it is before
    /// put back).
    pub(super) fn unemit(&self, items: &[Item]) -> Vec<Vec<Item>> {
        let mut out = Vec::new();
        for x in self.computing_regs(items) {
            let free = self.frame_bits(items, x);
            let n = free.len();
            for reload in 0..2u32 {
                for k in 0..1u32 << n {
                    let m = free.iter().enumerate().filter(|&(t, _)| k >> (n - 1 - t) & 1 != 0).fold(0, |m, (_, &j)| m | 1 << j);
                    out.extend(self.invert(items, x as u32 | reload << 3 | m << 4));
                }
            }
        }
        out
    }

    /// The registers (by [`POOL`] index) a sequence [`Cache::emit`] turned into `items` may
    /// have computed in.
    fn computing_regs(&self, items: &[Item]) -> Vec<usize> {
        // A `mul` or `div` computes in `rax`, which a remainder's sequence may not show.
        if items.iter().any(|it| matches!(it, Item::MulQ(_) | Item::Div { .. })) {
            return vec![0];
        }
        // The register computed in appears in the items, unless the sequence computes
        // nothing in a register, when it is the one any would get.
        let xs: Vec<usize> = (0..POOL.len())
            .filter(|&i| in_pool(self.pe, i) && items.iter().any(|it| it.map_regs(|r| if r == POOL[i] { Reg::Rbp } else { r }) != *it))
            .collect();
        if xs.is_empty() { vec![self.fresh()] } else { xs }
    }

    /// The items whose register operand is the computing register `POOL[x]` while it holds a
    /// slot: the selector bits [`Cache::invert`] leaves free (another register's operand is
    /// always its slot).
    fn frame_bits(&self, items: &[Item], x: usize) -> Vec<usize> {
        let mut c = *self;
        let mut out = Vec::new();
        for (j, it) in items.iter().enumerate() {
            if read_reg(it).and_then(pool) == Some(x) && c.regs[x].slot.is_some() {
                out.push(j);
            }
            c.update(it);
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
