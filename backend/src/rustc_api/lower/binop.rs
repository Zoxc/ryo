//! Binary and unary operations (design/lowering.md#binary-operations).

use rustc_middle::mir::interpret::Scalar;
use rustc_middle::mir::{BinOp, ConstValue, Operand, UnOp};
use rustc_middle::ty;

use super::cast::ScalarKind;
use super::emit::{FloatWidth, imm_words, opcode, opw, try_opcode};
use super::place::PlaceVal;
use super::{FnCx, NeedsNative, native};

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
    pub fn binary_op(
        &mut self,
        dst: PlaceVal<'tcx>,
        op: BinOp,
        a: &Operand<'tcx>,
        b: &Operand<'tcx>,
    ) -> Result<(), NeedsNative> {
        let la = self.operand_layout(a)?;
        match op {
            BinOp::Offset => {
                let pointee = la.ty.builtin_deref(true).ok_or_else(|| NeedsNative("Offset of a non-pointer".into()))?;
                let stride = u32::try_from(self.layout_of(pointee)?.size.bytes())
                    .map_err(|_| NeedsNative("Offset stride above 4 GiB".into()))?;
                let (p, _) = self.operand_slot(a)?;
                let (i, _) = self.operand_slot(b)?;
                self.with_place_slot(dst, |fx, d| {
                    fx.op(ryo_bytecode::insn::Opcode::PtrIndex, &[d, p, i, stride]);
                    Ok(())
                })
            }
            BinOp::AddWithOverflow | BinOp::SubWithOverflow | BinOp::MulWithOverflow => {
                let ScalarKind::Int { w, signed } = self.scalar_kind(la)? else { return native("float overflow op") };
                let family = match op {
                    BinOp::AddWithOverflow => "AddOvf",
                    BinOp::SubWithOverflow => "SubOvf",
                    _ => "MulOvf",
                };
                let su = if signed { "S" } else { "U" };
                let Some(opc) = try_opcode(&format!("{family}{su}{}", w.suffix())) else {
                    return native("128-bit mul.ovf (island)");
                };
                let (sa, _) = self.operand_slot(a)?;
                let (sb, _) = self.operand_slot(b)?;
                let (v, o) = (dst.layout.fields.offset(0).bytes() as u32, dst.layout.fields.offset(1).bytes() as u32);
                self.with_place_slot(dst, |fx, d| {
                    fx.op(opc, &[d + v, d + o, sa, sb]);
                    Ok(())
                })
            }
            BinOp::Cmp => {
                let ScalarKind::Int { w, signed } = self.scalar_kind(la)? else { return native("float Cmp") };
                let (sa, _) = self.operand_slot(a)?;
                let (sb, _) = self.operand_slot(b)?;
                let su = if signed { "S" } else { "U" };
                self.with_place_slot(dst, |fx, d| {
                    fx.op(opw(&format!("Cmp3{su}"), w), &[d, sa, sb]);
                    Ok(())
                })
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

    fn arith(&mut self, dst: PlaceVal<'tcx>, op: BinOp, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let la = self.operand_layout(a)?;
        let kind = self.scalar_kind(la)?;
        let (w, signed) = match kind {
            ScalarKind::Float(f) => return self.float_arith(dst, op, f, a, b),
            ScalarKind::Int { w, signed } => (w, signed),
        };
        let su = if signed { "S" } else { "U" };
        let family = match op {
            BinOp::Add | BinOp::AddUnchecked => "Add".to_owned(),
            BinOp::Sub | BinOp::SubUnchecked => "Sub".to_owned(),
            BinOp::Mul | BinOp::MulUnchecked => "Mul".to_owned(),
            BinOp::Div => format!("Div{su}"),
            BinOp::Rem => format!("Rem{su}"),
            BinOp::BitXor => "Xor".to_owned(),
            BinOp::BitAnd => "And".to_owned(),
            BinOp::BitOr => "Or".to_owned(),
            BinOp::Shl | BinOp::ShlUnchecked => "Shl".to_owned(),
            BinOp::Shr | BinOp::ShrUnchecked => format!("Shr{su}"),
            _ => unreachable!("not an arithmetic op"),
        };
        if try_opcode(&format!("{family}{}", w.suffix())).is_none() {
            return native("128-bit mul/div/rem (island)");
        }
        let shift = matches!(op, BinOp::Shl | BinOp::ShlUnchecked | BinOp::Shr | BinOp::ShrUnchecked);
        let (sa, _) = self.operand_slot(a)?;
        // `x op constant`: the `.imm` form.
        if let Some(v) = self.const_int(b)?
            && let Some(opc) = try_opcode(&format!("{family}Imm{}", w.suffix()))
        {
            let mut ops = vec![0, sa];
            ops.extend(imm_words(w, w.truncate(v)));
            return self.with_place_slot(dst, |fx, d| {
                ops[0] = d;
                fx.op(opc, &ops);
                Ok(())
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
        let opc = opw(&family, w);
        self.with_place_slot(dst, |fx, d| {
            fx.op(opc, &[d, sa, sb]);
            Ok(())
        })
    }

    fn float_arith(
        &mut self,
        dst: PlaceVal<'tcx>,
        op: BinOp,
        f: FloatWidth,
        a: &Operand<'tcx>,
        b: &Operand<'tcx>,
    ) -> Result<(), NeedsNative> {
        let family = match op {
            BinOp::Add => "Fadd",
            BinOp::Sub => "Fsub",
            BinOp::Mul => "Fmul",
            BinOp::Div => "Fdiv",
            BinOp::Rem => "Frem",
            _ => return native("float op"),
        };
        let (sa, _) = self.operand_slot(a)?;
        let (sb, _) = self.operand_slot(b)?;
        let opc = opcode(&format!("{family}{}", f.suffix()));
        self.with_place_slot(dst, |fx, d| {
            fx.op(opc, &[d, sa, sb]);
            Ok(())
        })
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
                Cmp::Eq => ("Feq", sa, sb),
                Cmp::Ne => ("Fne", sa, sb),
                Cmp::Lt => ("Flt", sa, sb),
                Cmp::Le => ("Fle", sa, sb),
                Cmp::Gt => ("Flt", sb, sa),
                Cmp::Ge => ("Fle", sb, sa),
            };
            let opc = opcode(&format!("{name}{}", f.suffix()));
            return self.with_place_slot(dst, |fx, d| {
                fx.op(opc, &[d, x, y]);
                Ok(())
            });
        }
        let ScalarKind::Int { w, signed } = kind else { unreachable!() };
        let su = if signed { "S" } else { "U" };
        let name = |c: Cmp| match c {
            Cmp::Eq => "Eq".to_owned(),
            Cmp::Ne => "Ne".to_owned(),
            Cmp::Lt => format!("Lt{su}"),
            Cmp::Le => format!("Le{su}"),
            Cmp::Gt => format!("Gt{su}"),
            Cmp::Ge => format!("Ge{su}"),
        };
        if let Some(v) = self.const_int(b)? {
            let opc = opcode(&format!("{}Imm{}", name(cmp), w.suffix()));
            let mut ops = vec![0, sa];
            ops.extend(imm_words(w, w.truncate(v)));
            return self.with_place_slot(dst, |fx, d| {
                ops[0] = d;
                fx.op(opc, &ops);
                Ok(())
            });
        }
        let (sb, _) = self.operand_slot(b)?;
        let (c, x, y) = match cmp {
            Cmp::Gt => (Cmp::Lt, sb, sa),
            Cmp::Ge => (Cmp::Le, sb, sa),
            c => (c, sa, sb),
        };
        let opc = opw(&name(c), w);
        self.with_place_slot(dst, |fx, d| {
            fx.op(opc, &[d, x, y]);
            Ok(())
        })
    }

    /// Wide pointer equality: data, then metadata.
    fn compare_wide(&mut self, dst: PlaceVal<'tcx>, cmp: Cmp, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let (name, combine) = match cmp {
            Cmp::Eq => ("EqW64", "AndW8"),
            Cmp::Ne => ("NeW64", "OrW8"),
            Cmp::Lt | Cmp::Le | Cmp::Gt | Cmp::Ge => return native("ordering of wide pointers"),
        };
        let (sa, _) = self.operand_slot(a)?;
        let (sb, _) = self.operand_slot(b)?;
        let t = self.frame.temp(2, 1);
        self.op(opcode(name), &[t, sa, sb]);
        self.op(opcode(name), &[t + 1, sa + 8, sb + 8]);
        self.with_place_slot(dst, |fx, d| {
            fx.op(opcode(combine), &[d, t, t + 1]);
            Ok(())
        })
    }

    pub fn unary_op(&mut self, dst: PlaceVal<'tcx>, op: UnOp, a: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let la = self.operand_layout(a)?;
        match op {
            UnOp::PtrMetadata => {
                if la.size.bytes() != 16 {
                    return Ok(()); // thin pointer: `()`
                }
                let (s, _) = self.operand_slot(a)?;
                self.with_place_slot(dst, |fx, d| {
                    fx.mov(d, s + 8, 8);
                    Ok(())
                })
            }
            UnOp::Not | UnOp::Neg => {
                let kind = self.scalar_kind(la)?;
                let (s, _) = self.operand_slot(a)?;
                self.with_place_slot(dst, |fx, d| {
                    match (op, kind) {
                        (UnOp::Not, ScalarKind::Int { .. }) if la.ty.is_bool() => {
                            fx.op(opcode("XorImmW8"), &[d, s, 1]);
                        }
                        (UnOp::Not, ScalarKind::Int { w, .. }) => {
                            fx.op(opw("Not", w), &[d, s]);
                        }
                        (UnOp::Neg, ScalarKind::Int { w, .. }) => {
                            fx.op(opw("Neg", w), &[d, s]);
                        }
                        (UnOp::Neg, ScalarKind::Float(f)) => {
                            fx.op(opcode(&format!("Fneg{}", f.suffix())), &[d, s]);
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
            ConstValue::Scalar(Scalar::Ptr(..)) | ConstValue::ZeroSized | ConstValue::Slice { .. } | ConstValue::Indirect { .. } => {
                None
            }
        })
    }
}
