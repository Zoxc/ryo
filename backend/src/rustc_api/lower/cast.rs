//! Casts and pointer coercions (design/lowering.md#casts). Unsizing mirrors cg_ssa's
//! `unsize_ptr` / `unsized_info` (`rustc_codegen_ssa/src/base.rs`).

use rustc_middle::mir::{CastKind, Operand};
use rustc_middle::ty::adjustment::PointerCoercion;
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, FloatTy, Instance, Ty, TypingEnv};
use ryo_bytecode::insn::Opcode;

use super::emit::{FloatWidth, Width, opcode};
use super::place::PlaceVal;
use super::{CodeReloc, FnCx, NeedsNative, native};

/// The VM's view of a scalar type.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ScalarKind {
    Int { w: Width, signed: bool },
    Float(FloatWidth),
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Classifies a scalar type: integers, `bool`, `char` and thin pointers are integers.
    pub fn scalar_kind(&self, layout: TyAndLayout<'tcx>) -> Result<ScalarKind, NeedsNative> {
        match layout.ty.kind() {
            ty::Float(FloatTy::F32) => Ok(ScalarKind::Float(FloatWidth::F32)),
            ty::Float(FloatTy::F64) => Ok(ScalarKind::Float(FloatWidth::F64)),
            ty::Float(FloatTy::F16 | FloatTy::F128) => native("f16/f128 operation"),
            _ => {
                let Some(w) = Width::of_size(layout.size.bytes()) else { return native("non-scalar operand") };
                Ok(ScalarKind::Int { w, signed: layout.ty.is_signed() })
            }
        }
    }

    /// `d = s as <to>` between integer widths.
    pub fn int_cast(&mut self, d: u32, s: u32, from: Width, to: Width, signed: bool) {
        if from == to {
            self.mov(d, s, from.bytes());
        } else if to.bits() < from.bits() {
            self.op(opcode(&format!("Trunc{}{}", from.suffix(), to.suffix())), &[d, s]);
        } else {
            let ext = if signed { "Sext" } else { "Zext" };
            self.op(opcode(&format!("{ext}{}{}", from.suffix(), to.suffix())), &[d, s]);
        }
    }

    pub fn cast(&mut self, dst: PlaceVal<'tcx>, kind: CastKind, op: &Operand<'tcx>, to: Ty<'tcx>) -> Result<(), NeedsNative> {
        let src = self.operand_layout(op)?;
        let to_layout = self.layout_of(to)?;
        match kind {
            CastKind::IntToInt | CastKind::FloatToInt | CastKind::IntToFloat | CastKind::FloatToFloat => {
                let from = self.scalar_kind(src)?;
                let into = self.scalar_kind(to_layout)?;
                let (s, _) = self.operand_slot(op)?;
                self.with_place_slot(dst, |fx, d| {
                    match (from, into) {
                        (ScalarKind::Int { w: a, signed }, ScalarKind::Int { w: b, .. }) => fx.int_cast(d, s, a, b, signed),
                        (ScalarKind::Float(f), ScalarKind::Int { w, signed }) => {
                            let su = if signed { "S" } else { "U" };
                            fx.op(opcode(&format!("CvtF2iSat{su}{}{}", f.suffix(), w.suffix())), &[d, s]);
                        }
                        (ScalarKind::Int { w, signed }, ScalarKind::Float(f)) => {
                            let su = if signed { "S" } else { "U" };
                            fx.op(opcode(&format!("CvtI2f{su}{}{}", w.suffix(), f.suffix())), &[d, s]);
                        }
                        (ScalarKind::Float(a), ScalarKind::Float(b)) if a == b => fx.mov(d, s, to_layout.size.bytes() as u32),
                        (ScalarKind::Float(a), ScalarKind::Float(b)) => {
                            fx.op(opcode(&format!("CvtF2f{}{}", a.suffix(), b.suffix())), &[d, s]);
                        }
                    }
                    Ok(())
                })
            }
            CastKind::PtrToPtr => {
                let (from, to) = (src.size.bytes(), to_layout.size.bytes());
                if from == to {
                    return self.operand_into(op, dst.loc);
                }
                if from == 16 && to == 8 {
                    // Wide to thin: drop the metadata.
                    let (s, _) = self.operand_slot(op)?;
                    self.with_place_slot(dst, |fx, d| {
                        fx.mov(d, s, 8);
                        Ok(())
                    })
                } else {
                    native("PtrToPtr between unexpected sizes")
                }
            }
            CastKind::FnPtrToPtr
            | CastKind::Transmute
            | CastKind::Subtype
            | CastKind::BoxDerefTransmute
            | CastKind::PointerExposeProvenance
            | CastKind::PointerWithExposedProvenance => {
                if src.size != to_layout.size {
                    return native("bit-preserving cast between different sizes");
                }
                self.operand_into(op, dst.loc)
            }
            CastKind::PointerCoercion(c, _) => match c {
                PointerCoercion::ReifyFnPointer(_) => {
                    let ty::FnDef(def_id, args) = *src.ty.kind() else { return native("reify of a non-FnDef") };
                    let args = args.no_bound_vars().expect("monomorphic fn item");
                    let instance =
                        Instance::resolve_for_fn_ptr(self.tcx, TypingEnv::fully_monomorphized(), def_id, args)
                            .ok_or_else(|| NeedsNative("unresolvable fn pointer".into()))?;
                    self.fn_addr_into(dst, instance)
                }
                PointerCoercion::ClosureFnPointer(_) => {
                    let ty::Closure(def_id, args) = *src.ty.kind() else { return native("closure coercion of a non-closure") };
                    let instance = Instance::resolve_closure(self.tcx, def_id, args, ty::ClosureKind::FnOnce);
                    self.fn_addr_into(dst, instance)
                }
                PointerCoercion::UnsafeFnPointer | PointerCoercion::MutToConstPointer | PointerCoercion::ArrayToPointer => {
                    self.operand_into(op, dst.loc)
                }
                PointerCoercion::Unsize => self.unsize(dst, op, src),
            },
        }
    }

    /// `addr.sym` of `instance` (its portal if it is a VM function).
    fn fn_addr_into(&mut self, dst: PlaceVal<'tcx>, instance: Instance<'tcx>) -> Result<(), NeedsNative> {
        self.with_place_slot(dst, |fx, d| {
            let at = fx.op(Opcode::AddrSym, &[d, 0]);
            fx.relocs.push(CodeReloc::Symbol { at: at + 2, target: instance });
            Ok(())
        })
    }

    /// `PointerCoercion::Unsize`: the data pointer, plus the new metadata.
    fn unsize(&mut self, dst: PlaceVal<'tcx>, op: &Operand<'tcx>, src: TyAndLayout<'tcx>) -> Result<(), NeedsNative> {
        let (a, b) = self.unsize_pointees(src.ty, dst.layout.ty)?;
        let src_wide = match src.size.bytes() {
            8 => false,
            16 => true,
            _ => return native("unsize of an unexpected layout"),
        };
        if dst.layout.size.bytes() != 16 {
            return native("unsize to an unexpected layout");
        }
        let (s, _) = self.operand_slot(op)?;
        let tcx = self.tcx;
        let (sa, sb) = tcx.struct_lockstep_tails_for_codegen(a, b, TypingEnv::fully_monomorphized());
        self.with_place_slot(dst, |fx, d| {
            fx.mov(d, s, 8);
            match (sa.kind(), sb.kind()) {
                (ty::Array(_, len), ty::Slice(_)) => {
                    let len = len.try_to_target_usize(tcx).expect("monomorphic array length");
                    fx.imm(Width::W64, d + 8, u128::from(len));
                }
                (ty::Dynamic(da, _), ty::Dynamic(db, _)) => {
                    if !src_wide {
                        return native("dyn upcast of a thin pointer");
                    }
                    let same = da.principal_def_id() == db.principal_def_id() || db.principal_def_id().is_none();
                    match (same, tcx.supertrait_vtable_slot((sa, sb))) {
                        (false, Some(idx)) => {
                            fx.op(opcode("LoadW64"), &[d + 8, s + 8, (idx * 8) as u32]);
                        }
                        _ => fx.mov(d + 8, s + 8, 8),
                    }
                }
                (_, ty::Dynamic(preds, _)) => {
                    let vtable = super::constant::vtable_alloc(tcx, sa, preds);
                    fx.check_alloc(vtable)?;
                    let at = fx.op(Opcode::AddrK, &[d + 8, 0]);
                    fx.relocs.push(CodeReloc::Const { at: at + 2, alloc: vtable, offset: 0 });
                }
                _ => return native("unsupported unsizing"),
            }
            Ok(())
        })
    }

    /// The pointee types of an unsizing coercion between pointers or pointer-wrapping structs
    /// (`Box`, `Rc`, … through their one non-1-ZST field).
    fn unsize_pointees(&self, src: Ty<'tcx>, dst: Ty<'tcx>) -> Result<(Ty<'tcx>, Ty<'tcx>), NeedsNative> {
        match (src.kind(), dst.kind()) {
            (ty::Pat(a, _), ty::Pat(b, _)) => self.unsize_pointees(*a, *b),
            (ty::Ref(_, a, _), ty::Ref(_, b, _) | ty::RawPtr(b, _)) | (ty::RawPtr(a, _), ty::RawPtr(b, _)) => Ok((*a, *b)),
            (ty::Adt(da, _), ty::Adt(db, _)) if da == db => {
                let sl = self.layout_of(src)?;
                let dl = self.layout_of(dst)?;
                for i in 0..sl.fields.count() {
                    let sf = sl.field(&self.lcx(), i);
                    if sf.is_1zst() {
                        continue;
                    }
                    let df = dl.field(&self.lcx(), i);
                    return self.unsize_pointees(sf.ty, df.ty);
                }
                native("unsize of a struct without a pointer field")
            }
            _ => native("unsize between unexpected types"),
        }
    }
}
