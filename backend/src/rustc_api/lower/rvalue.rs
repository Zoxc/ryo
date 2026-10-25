//! Statements and rvalues (design/lowering.md#statements, #rvalues).

use rustc_middle::mir::interpret::Scalar;
use rustc_middle::mir::{ConstValue, NonDivergingIntrinsic, Operand, Place, Rvalue, Statement, StatementKind};
use ryo_bytecode::full::Opcode;

use super::emit::{Width, opw};
use super::place::{Loc, PlaceVal};
use super::{CodeReloc, FnCx, NeedsNative, SPLIT_MAX, native};

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
                    let elem = src_layout.ty.builtin_deref(true).ok_or_else(|| NeedsNative("copy of a non-pointer".into()))?;
                    let el = self.layout_of(elem)?;
                    let size = el.size.bytes();
                    // A constant count: inline pieces.
                    if let Some(count) = self.const_int(&c.count)?
                        && let Some(n) = count.checked_mul(u128::from(size))
                        && n <= u128::from(SPLIT_MAX)
                    {
                        let copy = |fx: &mut Self| fx.mem_copy_pieces(dst, src, n as u32);
                        if count == 1 {
                            self.with_cuts(el, copy)
                        } else {
                            copy(self)
                        }
                        return Ok(());
                    }
                    let (count, _) = self.operand_slot(&c.count)?;
                    let n = self.temp8();
                    self.op(opw("MulImm", Width::W64), &[n, count, size as u32, (size >> 32) as u32]);
                    self.op(Opcode::Memcpy, &[dst, src, n]);
                    Ok(())
                }
            },
            StatementKind::StorageDead(l) => {
                self.storage_dead(*l);
                Ok(())
            }
            StatementKind::StorageLive(_)
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
            Rvalue::ThreadLocalRef(def_id) => self.thread_local_ref(dst, *def_id),
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
            fx.addr_into(d, pv.loc, pv.base)?;
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
        let total = e.checked_mul(n).ok_or_else(|| NeedsNative("Repeat size overflows".into()))?;
        if total == 0 {
            return Ok(());
        }
        // A scalar constant: `zero` or `fill` into a slot (slots are below 1 GiB, so the
        // sizes fit their u32 operands), `memset` into memory if all its bytes are equal.
        if let Operand::Constant(c) = op
            && let ConstValue::Scalar(Scalar::Int(i)) = self.eval_const(c)?
        {
            let bytes = i.to_bits(i.size()).to_le_bytes()[..e as usize].to_vec();
            match dst.loc {
                Loc::Slot(d) if bytes.iter().all(|&b| b == 0) => {
                    self.zero(d, total as u32);
                    return Ok(());
                }
                Loc::Slot(d) => {
                    let k = self.reloc(CodeReloc::Bytes { bytes, align: elem.align.abi.bytes() as u32 });
                    self.op(Opcode::Fill, &[d, k, e as u32, n as u32]);
                    return Ok(());
                }
                Loc::Mem { .. } if bytes.iter().all(|&b| b == bytes[0]) => {
                    let dp = self.place_addr(dst.loc, dst.base)?;
                    if total <= u64::from(SPLIT_MAX) {
                        self.mem_set_pieces(dp, Ok(bytes[0]), total as u32);
                        return Ok(());
                    }
                    let (b, len) = (self.frame.temp(1, 1), self.temp8());
                    self.imm(Width::W8, b, u128::from(bytes[0]));
                    self.imm(Width::W64, len, u128::from(total));
                    self.op(Opcode::Memset, &[dp, b, len]);
                    return Ok(());
                }
                Loc::Mem { .. } => {}
            }
        }
        self.operand_into(op, dst.loc)?;
        if n == 1 {
            return Ok(());
        }
        let base = self.place_addr(dst.loc, dst.base)?;
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
