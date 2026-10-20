//! Statements and rvalues (design/lowering.md#statements, #rvalues).

use rustc_middle::mir::interpret::Scalar;
use rustc_middle::mir::{ConstValue, NonDivergingIntrinsic, Operand, Place, Rvalue, Statement, StatementKind};
use ryo_bytecode::insn::Opcode;

use super::emit::{Width, opw};
use super::place::{Loc, PlaceVal};
use super::{CodeReloc, FnCx, NeedsNative, native};

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    pub fn statement(&mut self, stmt: &Statement<'tcx>) -> Result<(), NeedsNative> {
        match &stmt.kind {
            StatementKind::Assign(b) => {
                let (place, rvalue) = &**b;
                self.assign(*place, rvalue)
            }
            StatementKind::SetDiscriminant { place, variant_index } => {
                let pv = self.place(**place)?;
                self.set_discriminant(pv, *variant_index)
            }
            StatementKind::Intrinsic(i) => match &**i {
                NonDivergingIntrinsic::Assume(_) => Ok(()),
                NonDivergingIntrinsic::CopyNonOverlapping(c) => {
                    let (src, src_layout) = self.operand_slot(&c.src)?;
                    let (dst, _) = self.operand_slot(&c.dst)?;
                    let (count, _) = self.operand_slot(&c.count)?;
                    let elem = src_layout.ty.builtin_deref(true).ok_or_else(|| NeedsNative("copy of a non-pointer".into()))?;
                    let size = self.layout_of(elem)?.size.bytes();
                    let n = self.temp8();
                    self.op(opw("MulImm", Width::W64), &[n, count, size as u32, (size >> 32) as u32]);
                    self.op(Opcode::Memcpy, &[dst, src, n]);
                    Ok(())
                }
            },
            StatementKind::StorageLive(_)
            | StatementKind::StorageDead(_)
            | StatementKind::FakeRead(_)
            | StatementKind::PlaceMention(_)
            | StatementKind::AscribeUserType(..)
            | StatementKind::Coverage(_)
            | StatementKind::ConstEvalCounter
            | StatementKind::Nop
            | StatementKind::BackwardIncompatibleDropHint { .. } => Ok(()),
        }
    }

    fn assign(&mut self, place: Place<'tcx>, rvalue: &Rvalue<'tcx>) -> Result<(), NeedsNative> {
        let dst = self.place(place)?;
        if dst.meta.is_some() {
            return native("assignment to an unsized place");
        }
        match rvalue {
            Rvalue::Use(op, _) | Rvalue::WrapUnsafeBinder(op, _) => self.operand_into(op, dst.loc),
            Rvalue::CopyForDeref(p) | Rvalue::Reborrow(_, _, p) => self.operand_into(&Operand::Copy(*p), dst.loc),
            Rvalue::Repeat(op, count) => {
                let n = self.mono(*count).try_to_target_usize(self.tcx).ok_or_else(|| NeedsNative("Repeat count".into()))?;
                self.repeat(dst, op, n)
            }
            Rvalue::Ref(_, _, p) | Rvalue::RawPtr(_, p) => self.address_of(dst, *p),
            Rvalue::ThreadLocalRef(_) => native("ThreadLocalRef"),
            Rvalue::Cast(kind, op, ty) => self.cast(dst, *kind, op, self.mono(*ty)),
            Rvalue::BinaryOp(op, b) => self.binary_op(dst, *op, &b.0, &b.1),
            Rvalue::UnaryOp(op, a) => self.unary_op(dst, *op, a),
            Rvalue::Discriminant(p) => self.discriminant(dst, *p),
            Rvalue::Aggregate(kind, ops) => self.aggregate(dst, kind, ops),
        }
    }

    /// `&place` / `&raw place`: the address, plus the metadata for unsized places.
    fn address_of(&mut self, dst: PlaceVal<'tcx>, p: Place<'tcx>) -> Result<(), NeedsNative> {
        let pv = self.place(p)?;
        let size = dst.layout.size.bytes();
        if pv.meta.is_some() != (size == 16) {
            return native("reference with unexpected metadata");
        }
        self.with_place_slot(dst, |fx, d| {
            fx.addr_into(d, pv.loc);
            if let Some(m) = pv.meta {
                fx.mov(d + 8, m, 8);
            }
            Ok(())
        })
    }

    /// `[op; n]`: the element at index 0, then doubling copies.
    fn repeat(&mut self, dst: PlaceVal<'tcx>, op: &Operand<'tcx>, n: u64) -> Result<(), NeedsNative> {
        let elem = self.operand_layout(op)?;
        let e = elem.size.bytes();
        let total = e * n;
        if total == 0 {
            return Ok(());
        }
        // A constant that is all zeroes: `zero`.
        if let (Operand::Constant(c), Loc::Slot(d)) = (op, dst.loc) {
            let zero = match self.eval_const(c)? {
                ConstValue::Scalar(Scalar::Int(i)) => i.to_bits(i.size()) == 0,
                ConstValue::ZeroSized => true,
                ConstValue::Scalar(Scalar::Ptr(..)) | ConstValue::Slice { .. } | ConstValue::Indirect { .. } => false,
            };
            if zero {
                self.op(Opcode::Zero, &[d, total as u32]);
                return Ok(());
            }
            if let ConstValue::Scalar(Scalar::Int(i)) = self.eval_const(c)? {
                let bytes = i.to_bits(i.size()).to_le_bytes()[..e as usize].to_vec();
                let at = self.op(Opcode::Fill, &[d, 0, e as u32, n as u32]);
                self.relocs.push(CodeReloc::Bytes { at: at + 2, bytes, align: elem.align.abi.bytes() as u32 });
                return Ok(());
            }
        }
        self.operand_into(op, dst.loc)?;
        if n == 1 {
            return Ok(());
        }
        let base = self.place_addr(dst.loc)?;
        let dp = self.temp8();
        let len = self.temp8();
        let mut done = 1;
        while done < n {
            let k = done.min(n - done);
            self.ptr_add(dp, base, (done * e) as i64);
            self.imm(Width::W64, len, u128::from(k * e));
            self.op(Opcode::Memcpy, &[dp, base, len]);
            done += k;
        }
        Ok(())
    }
}
