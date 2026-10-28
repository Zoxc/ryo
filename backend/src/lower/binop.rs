//! Binary and unary operations (design/lowering.md#binary-operations).

use rustc_middle::mir::interpret::Scalar;
use rustc_middle::mir::{BinOp, ConstValue, Operand, UnOp};
use rustc_middle::ty;

use super::cast::ScalarKind;
use super::emit::{FloatOp, FloatWidth, IntOp, Width, opf, opw};
use super::island::templates;
use super::place::PlaceVal;
use super::{FnCx, NeedsNative, native};
use ryo_bytecode::full::Opcode;

/// An integer comparison, before operand swapping.
#[derive(Clone, Copy)]
enum Cmp {
    Eq,
    Ne,
    Lt,
    Le,
    Gt,
    Ge,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    pub fn binary_op(&mut self, dst: PlaceVal<'tcx>, op: BinOp, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let la = self.operand_layout(a)?;
        match op {
            BinOp::Offset => {
                let pointee = la.ty.builtin_deref(true).ok_or_else(|| NeedsNative("Offset of a non-pointer".into()))?;
                let stride = u32::try_from(self.layout_of(pointee)?.size.bytes()).map_err(|_| NeedsNative("Offset stride above 4 GiB".into()))?;
                let (p, _) = self.operand_slot(a)?;
                let (i, _) = self.operand_slot(b)?;
                self.op_to(dst, Opcode::PtrIndex, &[p, i, stride])
            }
            BinOp::AddWithOverflow | BinOp::SubWithOverflow | BinOp::MulWithOverflow => {
                let ScalarKind::Int { w, signed } = self.scalar_kind(la)? else { return native("float overflow op") };
                let family = match (op, signed) {
                    (BinOp::AddWithOverflow, true) => IntOp::AddOvfS,
                    (BinOp::AddWithOverflow, false) => IntOp::AddOvfU,
                    (BinOp::SubWithOverflow, true) => IntOp::SubOvfS,
                    (BinOp::SubWithOverflow, false) => IntOp::SubOvfU,
                    (_, true) => IntOp::MulOvfS,
                    (_, false) => IntOp::MulOvfU,
                };
                let Some(opc) = family.at(w) else {
                    // 128-bit `mul.ovf`: an island writing the whole pair.
                    let template = if signed { templates::MUL_OVF_S_W128 } else { templates::MUL_OVF_U_W128 };
                    return self.binop_island(dst, template, a, b);
                };
                let (sa, _) = self.operand_slot(a)?;
                let (sb, _) = self.operand_slot(b)?;
                let (v, o) = (dst.layout.fields.offset(0).bytes() as u32, dst.layout.fields.offset(1).bytes() as u32);
                self.into_place(dst, |fx, d| {
                    fx.op(opc, &[d + v, d + o, sa, sb]);
                })
            }
            BinOp::Cmp => {
                let ScalarKind::Int { w, signed } = self.scalar_kind(la)? else { return native("float Cmp") };
                let (sa, _) = self.operand_slot(a)?;
                let (sb, _) = self.operand_slot(b)?;
                self.op_to(dst, opw(if signed { IntOp::Cmp3S } else { IntOp::Cmp3U }, w), &[sa, sb])
            }
            BinOp::Eq => self.compare(dst, Cmp::Eq, a, b),
            BinOp::Ne => self.compare(dst, Cmp::Ne, a, b),
            BinOp::Lt => self.compare(dst, Cmp::Lt, a, b),
            BinOp::Le => self.compare(dst, Cmp::Le, a, b),
            BinOp::Gt => self.compare(dst, Cmp::Gt, a, b),
            BinOp::Ge => self.compare(dst, Cmp::Ge, a, b),
            BinOp::Add
            | BinOp::AddUnchecked
            | BinOp::Sub
            | BinOp::SubUnchecked
            | BinOp::Mul
            | BinOp::MulUnchecked
            | BinOp::Div
            | BinOp::Rem
            | BinOp::BitXor
            | BinOp::BitAnd
            | BinOp::BitOr
            | BinOp::Shl
            | BinOp::ShlUnchecked
            | BinOp::Shr
            | BinOp::ShrUnchecked => self.arith(dst, op, a, b),
        }
    }

    /// An operation with no instruction at this width: a `[a, b, dest]` island.
    fn binop_island(&mut self, dst: PlaceVal<'tcx>, template: &str, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let (sa, la) = self.operand_slot(a)?;
        let (sb, lb) = self.operand_slot(b)?;
        let n = dst.layout.size.bytes() as u32;
        self.into_place(dst, |fx, d| {
            fx.island(template, &[], &[(sa, la.size.bytes() as u32), (sb, lb.size.bytes() as u32), (d, n)], None);
        })
    }

    fn arith(&mut self, dst: PlaceVal<'tcx>, op: BinOp, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let la = self.operand_layout(a)?;
        let kind = self.scalar_kind(la)?;
        let (w, signed) = match kind {
            ScalarKind::Float(f) => return self.float_arith(dst, op, f, a, b),
            ScalarKind::Int { w, signed } => (w, signed),
        };
        let su = |s, u| if signed { s } else { u };
        let family = match op {
            BinOp::Add | BinOp::AddUnchecked => IntOp::Add,
            BinOp::Sub | BinOp::SubUnchecked => IntOp::Sub,
            BinOp::Mul | BinOp::MulUnchecked => IntOp::Mul,
            BinOp::Div => su(IntOp::DivS, IntOp::DivU),
            BinOp::Rem => su(IntOp::RemS, IntOp::RemU),
            BinOp::BitXor => IntOp::Xor,
            BinOp::BitAnd => IntOp::And,
            BinOp::BitOr => IntOp::Or,
            BinOp::Shl | BinOp::ShlUnchecked => IntOp::Shl,
            BinOp::Shr | BinOp::ShrUnchecked => su(IntOp::ShrS, IntOp::ShrU),
            _ => unreachable!("not an arithmetic op"),
        };
        if family.at(w).is_none() {
            // 128-bit `mul`, `div`, `rem`: islands (design/lowering.md#binary-operations).
            let template = match (op, signed) {
                (BinOp::Div, false) => templates::DIV_U_W128,
                (BinOp::Div, true) => templates::DIV_S_W128,
                (BinOp::Rem, false) => templates::REM_U_W128,
                (BinOp::Rem, true) => templates::REM_S_W128,
                _ => templates::MUL_W128,
            };
            return self.binop_island(dst, template, a, b);
        }
        let shift = matches!(op, BinOp::Shl | BinOp::ShlUnchecked | BinOp::Shr | BinOp::ShrUnchecked);
        let (sa, _) = self.operand_slot(a)?;
        // `x / 1` and `x % 1`, signed `x / -1` and `x % -1`: a `mov`, `mul.imm` by all-ones
        // (`MIN / -1` is UB and asserted by MIR), `imm 0`.
        if matches!(op, BinOp::Div | BinOp::Rem)
            && let Some(v) = self.const_int(b)?
            && let v = w.truncate(v)
            && (v == 1 || (signed && v == w.truncate(u128::MAX)))
        {
            return self.into_place(dst, |fx, d| match op {
                BinOp::Rem => fx.imm(w, d, 0),
                _ if v == 1 => fx.mov(d, sa, w.bytes()),
                _ => fx.op_imm(IntOp::Mul, w, d, sa, v),
            });
        }
        // Unsigned `x / 2^k` and `x % 2^k`: `shr.u.imm x, k` and `and.imm x, 2^k - 1`.
        if !signed
            && matches!(op, BinOp::Div | BinOp::Rem)
            && let Some(v) = self.const_int(b)?
            && w.truncate(v).is_power_of_two()
        {
            let v = w.truncate(v);
            let (fam, imm) = if op == BinOp::Div { (IntOp::ShrU, u128::from(v.trailing_zeros())) } else { (IntOp::And, v - 1) };
            return self.into_place(dst, |fx, d| {
                fx.op_imm(fam, w, d, sa, imm);
            });
        }
        // Unsigned w8-w32 `x / b` and `x % b` by another constant: `q = (zext(x) * M) >> p`
        // in 64 bits, `x - q * b` for the remainder.
        if !signed
            && matches!(op, BinOp::Div | BinOp::Rem)
            && w.bits() <= 32
            && let Some(v) = self.const_int(b)?
            && let Some((m, p)) = udiv_magic(w.bits(), w.truncate(v))
        {
            let v = w.truncate(v);
            let t = self.temp8();
            self.int_cast(t, sa, w, Width::W64, false);
            self.op_imm(IntOp::Mul, Width::W64, t, t, m);
            self.op_imm(IntOp::ShrU, Width::W64, t, t, u128::from(p));
            if op == BinOp::Div {
                return self.into_place(dst, |fx, d| {
                    fx.int_cast(d, t, Width::W64, w, false);
                });
            }
            let q = self.frame.temp(u64::from(w.bytes()), u64::from(w.bytes()));
            self.int_cast(q, t, Width::W64, w, false);
            self.op_imm(IntOp::Mul, w, q, q, v);
            return self.op_to(dst, opw(IntOp::Sub, w), &[sa, q]);
        }
        // `x op constant`: the `.imm` form.
        if let Some(v) = self.const_int(b)?
            && family.imm_at(w).is_some()
        {
            return self.into_place(dst, |fx, d| {
                fx.op_imm(family, w, d, sa, v);
            });
        }
        let (mut sb, lb) = self.operand_slot(b)?;
        if shift && lb.size != la.size {
            // The VM's shift amount has the value's width; masking keeps the low bits.
            let ScalarKind::Int { w: wb, .. } = self.scalar_kind(lb)? else { return native("float shift amount") };
            let t = self.frame.temp(u64::from(w.bytes()), u64::from(w.bytes()));
            self.int_cast(t, sb, wb, w, false);
            sb = t;
        }
        let opc = opw(family, w);
        self.op_to(dst, opc, &[sa, sb])
    }

    fn float_arith(&mut self, dst: PlaceVal<'tcx>, op: BinOp, f: FloatWidth, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let family = match op {
            BinOp::Add => FloatOp::Fadd,
            BinOp::Sub => FloatOp::Fsub,
            BinOp::Mul => FloatOp::Fmul,
            BinOp::Div => FloatOp::Fdiv,
            BinOp::Rem => FloatOp::Frem,
            _ => return native("float op"),
        };
        let (sa, _) = self.operand_slot(a)?;
        let (sb, _) = self.operand_slot(b)?;
        let opc = opf(family, f);
        self.op_to(dst, opc, &[sa, sb])
    }

    fn compare(&mut self, dst: PlaceVal<'tcx>, cmp: Cmp, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let la = self.operand_layout(a)?;
        if matches!(la.ty.kind(), ty::RawPtr(..) | ty::Ref(..) | ty::FnPtr(..)) && la.size.bytes() == 16 {
            return self.compare_wide(dst, cmp, a, b);
        }
        let kind = self.scalar_kind(la)?;
        let (sa, _) = self.operand_slot(a)?;
        if let ScalarKind::Float(f) = kind {
            let (sb, _) = self.operand_slot(b)?;
            let (name, x, y) = match cmp {
                Cmp::Eq => (FloatOp::Feq, sa, sb),
                Cmp::Ne => (FloatOp::Fne, sa, sb),
                Cmp::Lt => (FloatOp::Flt, sa, sb),
                Cmp::Le => (FloatOp::Fle, sa, sb),
                Cmp::Gt => (FloatOp::Flt, sb, sa),
                Cmp::Ge => (FloatOp::Fle, sb, sa),
            };
            let opc = opf(name, f);
            return self.op_to(dst, opc, &[x, y]);
        }
        let ScalarKind::Int { w, signed } = kind else { unreachable!() };
        let su = |s, u| if signed { s } else { u };
        let name = |c: Cmp| match c {
            Cmp::Eq => IntOp::Eq,
            Cmp::Ne => IntOp::Ne,
            Cmp::Lt => su(IntOp::LtS, IntOp::LtU),
            Cmp::Le => su(IntOp::LeS, IntOp::LeU),
            Cmp::Gt => su(IntOp::GtS, IntOp::GtU),
            Cmp::Ge => su(IntOp::GeS, IntOp::GeU),
        };
        if let Some(v) = self.const_int(b)? {
            let family = name(cmp);
            return self.into_place(dst, |fx, d| {
                fx.op_imm(family, w, d, sa, v);
            });
        }
        let (sb, _) = self.operand_slot(b)?;
        let (c, x, y) = match cmp {
            Cmp::Gt => (Cmp::Lt, sb, sa),
            Cmp::Ge => (Cmp::Le, sb, sa),
            c => (c, sa, sb),
        };
        let opc = opw(name(c), w);
        self.op_to(dst, opc, &[x, y])
    }

    /// Wide pointer compares: data, then metadata (lexicographic, as cg_ssa does).
    fn compare_wide(&mut self, dst: PlaceVal<'tcx>, cmp: Cmp, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let (sa, _) = self.operand_slot(a)?;
        let (sb, _) = self.operand_slot(b)?;
        let t = self.frame.temp(3, 1);
        if let Cmp::Eq | Cmp::Ne = cmp {
            let (name, combine) = if let Cmp::Eq = cmp { (Opcode::EqW64, Opcode::AndW8) } else { (Opcode::NeW64, Opcode::OrW8) };
            self.op(name, &[t, sa, sb]);
            self.op(name, &[t + 1, sa + 8, sb + 8]);
            return self.op_to(dst, combine, &[t, t + 1]);
        }
        // x < y is x.data < y.data, or equal data and x.meta < y.meta (`<=` on the metadata
        // for `<=`). `>` and `>=` swap the operands.
        let (x, y) = if let Cmp::Lt | Cmp::Le = cmp { (sa, sb) } else { (sb, sa) };
        let meta = if let Cmp::Lt | Cmp::Gt = cmp { Opcode::LtUW64 } else { Opcode::LeUW64 };
        self.op(Opcode::LtUW64, &[t, x, y]);
        self.op(Opcode::EqW64, &[t + 1, x, y]);
        self.op(meta, &[t + 2, x + 8, y + 8]);
        self.op(Opcode::AndW8, &[t + 1, t + 1, t + 2]);
        self.op_to(dst, Opcode::OrW8, &[t, t + 1])
    }

    pub fn unary_op(&mut self, dst: PlaceVal<'tcx>, op: UnOp, a: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let la = self.operand_layout(a)?;
        match op {
            UnOp::PtrMetadata => {
                if la.size.bytes() != 16 {
                    return Ok(()); // thin pointer: `()`
                }
                let (s, _) = self.operand_slot(a)?;
                self.into_place(dst, |fx, d| {
                    fx.mov(d, s + 8, 8);
                })
            }
            UnOp::Not | UnOp::Neg => {
                let kind = self.scalar_kind(la)?;
                let (s, _) = self.operand_slot(a)?;
                self.with_place_slot(dst, |fx, d| {
                    match (op, kind) {
                        (UnOp::Not, ScalarKind::Int { .. }) if la.ty.is_bool() => {
                            fx.op(Opcode::XorImmW8, &[d, s, 1]);
                        }
                        (UnOp::Not, ScalarKind::Int { w, .. }) => {
                            fx.op(opw(IntOp::Not, w), &[d, s]);
                        }
                        (UnOp::Neg, ScalarKind::Int { w, .. }) => {
                            fx.op(opw(IntOp::Neg, w), &[d, s]);
                        }
                        (UnOp::Neg, ScalarKind::Float(f)) => {
                            fx.op(opf(FloatOp::Fneg, f), &[d, s]);
                        }
                        (UnOp::Not, ScalarKind::Float(_)) | (UnOp::PtrMetadata, _) => return native("unary op"),
                    }
                    Ok(())
                })
            }
        }
    }

    /// The value of `op` if it is an integer constant.
    pub fn const_int(&self, op: &Operand<'tcx>) -> Result<Option<u128>, NeedsNative> {
        let Operand::Constant(c) = op else { return Ok(None) };
        Ok(match self.eval_const(c)? {
            ConstValue::Scalar(Scalar::Int(i)) => Some(i.to_bits(i.size())),
            ConstValue::Scalar(Scalar::Ptr(..)) | ConstValue::ZeroSized | ConstValue::Slice { .. } | ConstValue::Indirect { .. } => None,
        })
    }
}

/// For an `n`-bit (n <= 32) unsigned division by `b` (not 0, 1 or a power of two): `(M, p)`
/// with `floor(x / b) = (x * M) >> p` for every `x < 2^n` and `x * M < 2^64`. With `M =
/// ceil(2^p / b)` and `e = M * b - 2^p`, `x * M / 2^p = x / b + x * e / (b * 2^p)`, and
/// `e <= 2^(p - n)` keeps the error term below `1 / b`, so the floor doesn't change.
fn udiv_magic(n: u32, b: u128) -> Option<(u128, u32)> {
    if b <= 1 || b.is_power_of_two() {
        return None;
    }
    (n..64).find_map(|p| {
        let m = (1u128 << p).div_ceil(b);
        let e = m * b - (1u128 << p);
        (m < 1u128 << (64 - n) && e <= 1u128 << (p - n)).then_some((m, p))
    })
}
