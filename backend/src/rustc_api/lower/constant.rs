//! Constants (design/lowering.md#constants): scalars become immediates, everything else is
//! copied from the image's constant pool. The merge pass copies allocations into the pool
//! (with their pointers relocated: to other pool allocations, to functions or portals, to
//! statics), so the lowering only records which allocation an operand refers to
//! ([`CodeReloc::Const`]).

use rustc_data_structures::fx::FxHashSet;
use rustc_middle::mir::interpret::{AllocId, GlobalAlloc, Scalar};
use rustc_middle::mir::{ConstOperand, ConstValue};
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, TyCtxt, TypingEnv};
use ryo_bytecode::insn::Opcode;

use super::emit::Width;
use super::place::Loc;
use super::{CodeReloc, FnCx, NeedsNative, native};

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Writes the constant `c` to `dst`.
    pub fn const_into(&mut self, c: &ConstOperand<'tcx>, dst: Loc) -> Result<(), NeedsNative> {
        let layout = self.layout_of(self.mono(c.ty()))?;
        let val = self.eval_const(c)?;
        self.const_value_into(val, layout, dst)
    }

    /// Evaluates a MIR constant, as cg_ssa's `eval_mir_constant` does.
    pub fn eval_const(&self, c: &ConstOperand<'tcx>) -> Result<ConstValue, NeedsNative> {
        self.mono(c.const_)
            .eval(self.tcx, TypingEnv::fully_monomorphized(), c.span)
            .map_err(|e| NeedsNative(format!("constant evaluation failed: {e:?}")))
    }

    /// Writes the constant value `val` of `layout` to `dst` (cg_ssa's `OperandRef::from_const`).
    pub fn const_value_into(
        &mut self,
        val: ConstValue,
        layout: TyAndLayout<'tcx>,
        dst: Loc,
    ) -> Result<(), NeedsNative> {
        let size = layout.size.bytes() as u32;
        match val {
            ConstValue::ZeroSized => Ok(()),
            ConstValue::Scalar(Scalar::Int(i)) => {
                let Some(w) = Width::of_size(i.size().bytes()) else { return native("odd-sized scalar constant") };
                let bits = i.to_bits(i.size());
                self.with_slot(dst, w.bytes(), |fx, d| {
                    fx.imm(w, d, bits);
                    Ok(())
                })
            }
            ConstValue::Scalar(Scalar::Ptr(ptr, _)) => {
                let (prov, off) = ptr.prov_and_relative_offset();
                self.with_slot(dst, 8, |fx, d| fx.alloc_addr_into(d, prov.alloc_id(), off.bytes()))
            }
            ConstValue::Slice { alloc_id, meta } => {
                let rustc_abi::BackendRepr::ScalarPair { b_offset, .. } = layout.backend_repr else {
                    return native("slice constant without a scalar-pair layout");
                };
                let b = b_offset.bytes() as u32;
                self.with_slot(dst, size, |fx, d| {
                    fx.alloc_addr_into(d, alloc_id, 0)?;
                    fx.imm(Width::W64, d + b, u128::from(meta));
                    Ok(())
                })
            }
            ConstValue::Indirect { alloc_id, offset } => {
                if size == 0 {
                    return Ok(());
                }
                self.check_alloc(alloc_id)?;
                let offset = u32::try_from(offset.bytes()).map_err(|_| NeedsNative("constant offset".into()))?;
                self.with_slot(dst, size, |fx, d| {
                    let at = fx.op(Opcode::Const, &[d, 0, size]);
                    fx.relocs.push(CodeReloc::Const { at: at + 2, alloc: alloc_id, offset });
                    Ok(())
                })
            }
        }
    }

    /// Writes the address `offset` bytes into the allocation `id` to slot `d`.
    pub fn alloc_addr_into(&mut self, d: u32, id: AllocId, offset: u64) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        match tcx.global_alloc(id) {
            GlobalAlloc::Memory(_) => {
                self.check_alloc(id)?;
                let offset = u32::try_from(offset).map_err(|_| NeedsNative("constant offset".into()))?;
                let at = self.op(Opcode::AddrK, &[d, 0]);
                self.relocs.push(CodeReloc::Const { at: at + 2, alloc: id, offset });
            }
            GlobalAlloc::VTable(ty, dyn_ty) => {
                let vtable = vtable_alloc(tcx, ty, dyn_ty);
                self.check_alloc(vtable)?;
                let offset = u32::try_from(offset).map_err(|_| NeedsNative("constant offset".into()))?;
                let at = self.op(Opcode::AddrK, &[d, 0]);
                self.relocs.push(CodeReloc::Const { at: at + 2, alloc: vtable, offset });
            }
            GlobalAlloc::Function { instance } => {
                let at = self.op(Opcode::AddrSym, &[d, 0]);
                self.relocs.push(CodeReloc::Symbol { at: at + 2, target: instance });
                if offset != 0 {
                    self.ptr_add(d, d, offset as i64);
                }
            }
            GlobalAlloc::Static(def_id) => {
                check_static(tcx, def_id)?;
                let at = self.op(Opcode::AddrSym, &[d, 0]);
                self.relocs.push(CodeReloc::Static { at: at + 2, def_id });
                if offset != 0 {
                    self.ptr_add(d, d, offset as i64);
                }
            }
            GlobalAlloc::TypeId { .. } => return native("pointer to a type id"),
        }
        Ok(())
    }

    /// Checks that the merge pass can put `id` (and everything it points at) in the pool.
    pub fn check_alloc(&self, id: AllocId) -> Result<(), NeedsNative> {
        check_alloc(self.tcx, id, &mut FxHashSet::default())
    }
}

/// The vtable allocation of `ty` for the trait object with predicates `preds`.
pub fn vtable_alloc<'tcx>(
    tcx: TyCtxt<'tcx>,
    ty: ty::Ty<'tcx>,
    preds: &'tcx ty::List<ty::PolyExistentialPredicate<'tcx>>,
) -> AllocId {
    let principal = preds.principal().map(|p| tcx.instantiate_bound_regions_with_erased(p));
    tcx.vtable_allocation((ty, principal))
}

fn check_static(tcx: TyCtxt<'_>, def_id: rustc_hir::def_id::DefId) -> Result<(), NeedsNative> {
    if tcx.is_thread_local_static(def_id) {
        return native("pointer to a thread-local static");
    }
    Ok(())
}

fn check_alloc(tcx: TyCtxt<'_>, id: AllocId, seen: &mut FxHashSet<AllocId>) -> Result<(), NeedsNative> {
    if !seen.insert(id) {
        return Ok(());
    }
    match tcx.global_alloc(id) {
        GlobalAlloc::Memory(alloc) => {
            for prov in alloc.inner().provenance().ptrs().values() {
                check_alloc(tcx, prov.alloc_id(), seen)?;
            }
            Ok(())
        }
        GlobalAlloc::VTable(ty, dyn_ty) => check_alloc(tcx, vtable_alloc(tcx, ty, dyn_ty), seen),
        // On PE, pointers to imports need the image's fixup area, which constants don't use
        // yet (design/platforms.md).
        GlobalAlloc::Function { instance } if super::super::is_pe(tcx) && !tcx.should_codegen_locally(instance) => {
            native("PE: constant pointing at an imported function")
        }
        GlobalAlloc::Function { .. } => Ok(()),
        GlobalAlloc::Static(def_id) if super::super::static_symbol_flags(tcx, def_id) != 0 => {
            native("PE: constant pointing at an imported static")
        }
        GlobalAlloc::Static(def_id) => check_static(tcx, def_id),
        GlobalAlloc::TypeId { .. } => native("constant with a type id pointer"),
    }
}
