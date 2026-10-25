//! Binary and unary operations (design/lowering.md#binary-operations).

use rustc_middle::mir::interpret::Scalar;
use rustc_middle::mir::{BinOp, ConstValue, Operand, UnOp};
use rustc_middle::ty;

use super::cast::ScalarKind;
use super::emit::{FloatWidth, imm_words, opcode, opw, try_opcode};
use super::place::PlaceVal;
use super::{FnCx, NeedsNative, native};

/// Island templates for the 128-bit operations the VM has no instruction for
/// (`vm/rt/src/island.rs`). `ops`: `[a, b, dest]`.
mod templates {
    pub const MUL_W128: &str = "ryo_island_mul_w128";
    pub const DIV_U_W128: &str = "ryo_island_div_u_w128";
    pub const DIV_S_W128: &str = "ryo_island_div_s_w128";
    pub const REM_U_W128: &str = "ryo_island_rem_u_w128";
    pub const REM_S_W128: &str = "ryo_island_rem_s_w128";
    pub const MUL_OVF_U_W128: &str = "ryo_island_mul_ovf_u_w128";
    pub const MUL_OVF_S_W128: &str = "ryo_island_mul_ovf_s_w128";
}

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
                self.with_place_slot(dst, |fx, d| {
                    fx.op(ryo_bytecode::full::Opcode::PtrIndex, &[d, p, i, stride]);
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
                let (sa, la) = self.operand_slot(a)?;
                let (sb, lb) = self.operand_slot(b)?;
                let Some(opc) = try_opcode(&format!("{family}{su}{}", w.suffix())) else {
                    // 128-bit `mul.ovf`: an island writing the whole pair.
                    let template = if signed { templates::MUL_OVF_S_W128 } else { templates::MUL_OVF_U_W128 };
                    let n = dst.layout.size.bytes() as u32;
                    return self.with_place_slot(dst, |fx, d| {
                        fx.island(template, &[], &[(sa, la.size.bytes() as u32), (sb, lb.size.bytes() as u32), (d, n)], None);
                        Ok(())
                    });
                };
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
            // 128-bit `mul`, `div`, `rem`: islands (design/lowering.md#binary-operations).
            let template = match (op, signed) {
                (BinOp::Div, false) => templates::DIV_U_W128,
                (BinOp::Div, true) => templates::DIV_S_W128,
                (BinOp::Rem, false) => templates::REM_U_W128,
                (BinOp::Rem, true) => templates::REM_S_W128,
                _ => templates::MUL_W128,
            };
            let (sa, la) = self.operand_slot(a)?;
            let (sb, lb) = self.operand_slot(b)?;
            let n = dst.layout.size.bytes() as u32;
            return self.with_place_slot(dst, |fx, d| {
                fx.island(template, &[], &[(sa, la.size.bytes() as u32), (sb, lb.size.bytes() as u32), (d, n)], None);
                Ok(())
            });
        }
        let shift = matches!(op, BinOp::Shl | BinOp::ShlUnchecked | BinOp::Shr | BinOp::ShrUnchecked);
        let (sa, _) = self.operand_slot(a)?;
        // `x / 1` and `x % 1`, signed `x / -1` and `x % -1`: a `mov`, `mul.imm` by all-ones
        // (`MIN / -1` is UB and asserted by MIR), `imm 0`.
        if matches!(op, BinOp::Div | BinOp::Rem)
            && let Some(v) = self.const_int(b)?
            && let v = w.truncate(v)
            && let minus_one = signed
            && v == w.truncate(u128::MAX)
            && (v == 1 || minus_one)
        {
            return self.with_place_slot(dst, |fx, d| {
                match (op, minus_one) {
                    (BinOp::Rem, _) => fx.imm(w, d, 0),
                    (_, false) => fx.mov(d, sa, w.bytes()),
                    (_, true) => fx.op_imm("Mul", w, d, sa, v),
                }
                Ok(())
            });
        }
        // Unsigned `x / 2^k` and `x % 2^k`: `shr.u.imm x, k` and `and.imm x, 2^k - 1`.
        if !signed
            && matches!(op, BinOp::Div | BinOp::Rem)
            && let Some(v) = self.const_int(b)?
            && w.truncate(v).is_power_of_two()
        {
            let v = w.truncate(v);
            let (fam, imm) = if op == BinOp::Div { ("ShrUImm", u128::from(v.trailing_zeros())) } else { ("AndImm", v - 1) };
            let mut ops = vec![0, sa];
            ops.extend(imm_words(w, imm));
            let opc = opw(fam, w);
            return self.with_place_slot(dst, |fx, d| {
                ops[0] = d;
                fx.op(opc, &ops);
                Ok(())
            });
        }
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

    fn float_arith(&mut self, dst: PlaceVal<'tcx>, op: BinOp, f: FloatWidth, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
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

    /// Wide pointer compares: data, then metadata (lexicographic, as cg_ssa does).
    fn compare_wide(&mut self, dst: PlaceVal<'tcx>, cmp: Cmp, a: &Operand<'tcx>, b: &Operand<'tcx>) -> Result<(), NeedsNative> {
        let (sa, _) = self.operand_slot(a)?;
        let (sb, _) = self.operand_slot(b)?;
        let t = self.frame.temp(3, 1);
        if let Cmp::Eq | Cmp::Ne = cmp {
            let (name, combine) = if let Cmp::Eq = cmp { ("EqW64", "AndW8") } else { ("NeW64", "OrW8") };
            self.op(opcode(name), &[t, sa, sb]);
            self.op(opcode(name), &[t + 1, sa + 8, sb + 8]);
            return self.with_place_slot(dst, |fx, d| {
                fx.op(opcode(combine), &[d, t, t + 1]);
                Ok(())
            });
        }
        // x < y is x.data < y.data, or equal data and x.meta < y.meta (`<=` on the metadata
        // for `<=`). `>` and `>=` swap the operands.
        let (x, y) = if let Cmp::Lt | Cmp::Le = cmp { (sa, sb) } else { (sb, sa) };
        let meta = if let Cmp::Lt | Cmp::Gt = cmp { "LtUW64" } else { "LeUW64" };
        self.op(opcode("LtUW64"), &[t, x, y]);
        self.op(opcode("EqW64"), &[t + 1, x, y]);
        self.op(opcode(meta), &[t + 2, x + 8, y + 8]);
        self.op(opcode("AndW8"), &[t + 1, t + 1, t + 2]);
        self.with_place_slot(dst, |fx, d| {
            fx.op(opcode("OrW8"), &[d, t, t + 1]);
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
            ConstValue::Scalar(Scalar::Ptr(..)) | ConstValue::ZeroSized | ConstValue::Slice { .. } | ConstValue::Indirect { .. } => None,
        })
    }
}
