//! Casts and pointer coercions (design/lowering.md#casts). Unsizing mirrors cg_ssa's
//! `unsize_ptr` / `unsized_info` (`rustc_codegen_ssa/src/base.rs`).

use rustc_middle::mir::{CastKind, Operand};
use rustc_middle::ty::adjustment::PointerCoercion;
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, FloatTy, Instance, Ty, TyCtxt, TypingEnv};

use super::emit::{FloatWidth, Width};
use super::place::{Loc, META, PTR, PlaceVal, is_wide_ptr};
use super::{CodeReloc, FnCx, NeedsNative, native};
use ryo_bytecode::full::{Opcode, cvt_f2f, cvt_f2i, cvt_i2f, int_cast_op};

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
        } else {
            self.op(int_cast_op(from, to, signed).expect("distinct widths"), &[d, s]);
        }
    }

    pub fn cast(&mut self, dst: PlaceVal<'tcx>, kind: CastKind, op: &Operand<'tcx>, to: Ty<'tcx>) -> Result<(), NeedsNative> {
        let src = self.operand_layout(op)?;
        let to_layout = self.layout_of(to)?;
        match kind {
            CastKind::IntToInt | CastKind::FloatToInt | CastKind::IntToFloat | CastKind::FloatToFloat => {
                let half_or_quad = |t: Ty<'_>| matches!(t.kind(), ty::Float(FloatTy::F16 | FloatTy::F128));
                if half_or_quad(src.ty) || half_or_quad(to) {
                    // No VM instructions for `f16`/`f128`: the `as_cast` island.
                    let (s, _) = self.operand_slot(op)?;
                    let (sn, dn) = (src.size.bytes() as u32, to_layout.size.bytes() as u32);
                    return self.into_place(dst, |fx, d| {
                        fx.island(super::island::templates::AS_CAST, &[src.ty.into(), to.into()], &[(s, sn), (d, dn)], None);
                    });
                }
                let from = self.scalar_kind(src)?;
                let into = self.scalar_kind(to_layout)?;
                let (s, _) = self.operand_slot(op)?;
                self.into_place(dst, |fx, d| match (from, into) {
                    (ScalarKind::Int { w: a, signed }, ScalarKind::Int { w: b, .. }) => fx.int_cast(d, s, a, b, signed),
                    (ScalarKind::Float(f), ScalarKind::Int { w, signed }) => {
                        fx.op(cvt_f2i(f, w, signed), &[d, s]);
                    }
                    (ScalarKind::Int { w, signed }, ScalarKind::Float(f)) => {
                        fx.op(cvt_i2f(w, f, signed), &[d, s]);
                    }
                    (ScalarKind::Float(a), ScalarKind::Float(b)) if a == b => fx.mov(d, s, to_layout.size.bytes() as u32),
                    (ScalarKind::Float(a), ScalarKind::Float(b)) => {
                        fx.op(cvt_f2f(a, b).expect("distinct formats"), &[d, s]);
                    }
                })
            }
            CastKind::PtrToPtr => {
                if src.size == to_layout.size {
                    return self.operand_into(op, dst.loc);
                }
                if is_wide_ptr(src) && to_layout.size.bytes() == u64::from(PTR) {
                    // Wide to thin: drop the metadata.
                    let (s, _) = self.operand_slot(op)?;
                    self.into_place(dst, |fx, d| {
                        fx.mov(d, s, PTR);
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
                    let instance = Instance::resolve_for_fn_ptr(self.tcx, TypingEnv::fully_monomorphized(), def_id, args)
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
        self.into_place(dst, |fx, d| {
            fx.addr_sym(d, CodeReloc::Symbol { target: instance });
        })
    }

    /// `PointerCoercion::Unsize`, as cg_ssa's `coerce_unsized_into`: a (wide) pointer, or a
    /// struct coerced field by field (`Rc<T>`, `Ref<'_, T>`, `Pin<Box<T>>`, …).
    fn unsize(&mut self, dst: PlaceVal<'tcx>, op: &Operand<'tcx>, src: TyAndLayout<'tcx>) -> Result<(), NeedsNative> {
        let src_loc = match op {
            Operand::Copy(p) | Operand::Move(p) => {
                let pv = self.place(*p)?;
                if pv.meta.is_some() {
                    return native("unsized operand");
                }
                pv.loc
            }
            Operand::Constant(_) | Operand::RuntimeChecks(_) => {
                let t = self.temp_for(src);
                self.operand_into(op, Loc::Slot(t))?;
                Loc::Slot(t)
            }
        };
        self.coerce_unsized_into(dst.loc, dst.layout, src_loc, src)
    }

    fn coerce_unsized_into(&mut self, dst: Loc, dl: TyAndLayout<'tcx>, src: Loc, sl: TyAndLayout<'tcx>) -> Result<(), NeedsNative> {
        match (sl.ty.kind(), dl.ty.kind()) {
            (ty::Pat(s, _), ty::Pat(d, _)) => {
                let (sl, dl) = (self.layout_of(*s)?, self.layout_of(*d)?);
                self.coerce_unsized_into(dst, dl, src, sl)
            }
            (ty::Ref(_, a, _), ty::Ref(_, b, _) | ty::RawPtr(b, _)) | (ty::RawPtr(a, _), ty::RawPtr(b, _)) => {
                let (a, b) = (*a, *b);
                let src_wide = is_wide_ptr(sl);
                if !src_wide && sl.size.bytes() != u64::from(PTR) {
                    return native("unsize of an unexpected layout");
                }
                if !is_wide_ptr(dl) {
                    return native("unsize to an unexpected layout");
                }
                let s = self.loc_slot(src, sl)?;
                self.with_slot(dst, 2 * PTR, |fx, d| {
                    fx.mov(d, s, PTR);
                    fx.unsized_info(d + META, a, b, src_wide.then_some(s + META))
                })
            }
            (ty::Adt(da, _), ty::Adt(db, _)) if da == db && da.is_struct() => {
                for i in 0..dl.fields.count() {
                    let (sf, df) = (sl.field(&self.lcx(), i), dl.field(&self.lcx(), i));
                    if df.is_zst() {
                        continue;
                    }
                    let fs = src.offset(sl.fields.offset(i).bytes())?;
                    let fd = dst.offset(dl.fields.offset(i).bytes())?;
                    if sf.ty == df.ty {
                        self.with_cuts(sf, |fx| fx.copy_val(fd, fs, sf.size.bytes() as u32))?;
                    } else {
                        self.coerce_unsized_into(fd, df, fs, sf)?;
                    }
                }
                Ok(())
            }
            _ => native("unsize between unexpected types"),
        }
    }

    /// Writes the metadata of an unsizing from pointee `a` to pointee `b` to slot `d`
    /// (cg_ssa's `unsized_info`). `old` is the source's metadata slot, if it is wide.
    fn unsized_info(&mut self, d: u32, a: Ty<'tcx>, b: Ty<'tcx>, old: Option<u32>) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let (sa, sb) = tcx.struct_lockstep_tails_for_codegen(a, b, TypingEnv::fully_monomorphized());
        match (sa.kind(), sb.kind()) {
            (ty::Array(_, len), ty::Slice(_)) => {
                let len = len.try_to_target_usize(tcx).expect("monomorphic array length");
                self.imm(Width::W64, d, u128::from(len));
            }
            (ty::Dynamic(..), ty::Dynamic(..)) => {
                let Some(old) = old else { return native("dyn upcast of a thin pointer") };
                match upcast_entry(tcx, sa, sb) {
                    Some(idx) => {
                        self.op(Opcode::LoadW64, &[d, old, (idx * 8) as u32]);
                    }
                    None => self.mov(d, old, 8),
                }
            }
            (_, ty::Dynamic(preds, _)) => {
                let vtable = super::constant::vtable_alloc(tcx, sa, preds);
                self.alloc_addr_into(d, vtable, 0)?;
            }
            _ => return native("unsupported unsizing"),
        }
        Ok(())
    }
}

/// The vtable entry holding the supertrait vtable for a `dyn` upcast from `sa` to `sb`, or
/// `None` when the vtable pointer is reused (same principal, or none in `sb`).
pub fn upcast_entry<'tcx>(tcx: TyCtxt<'tcx>, sa: Ty<'tcx>, sb: Ty<'tcx>) -> Option<usize> {
    let (ty::Dynamic(da, _), ty::Dynamic(db, _)) = (sa.kind(), sb.kind()) else { return None };
    let same = da.principal_def_id() == db.principal_def_id() || db.principal_def_id().is_none();
    if same { None } else { tcx.supertrait_vtable_slot((sa, sb)) }
}
