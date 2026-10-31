//! Constants (design/lowering.md#constants): scalars become immediates, everything else is
//! copied from the image's constant pool. The merge pass copies allocations into the pool
//! (with their pointers relocated: to other pool allocations, to functions or portals, to
//! statics), so the lowering only records which allocation an operand refers to
//! ([`CodeReloc::Const`]). On PE, allocations pointing directly at imports go into the
//! image's writable fixup area instead ([`CodeReloc::Data`], [`needs_fixup`]).
//!
//! Thread locals are reached through the `ThreadLocal` shim, called directly
//! (design/lowering.md#rvalues).

use rustc_data_structures::fx::FxHashSet;
use rustc_hir::def_id::DefId;
use rustc_middle::mir::interpret::{AllocId, GlobalAlloc, Scalar};
use rustc_middle::mir::{ConstOperand, ConstValue};
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, GenericArgs, Instance, InstanceKind, ShimKind, TyCtxt, TypingEnv};
use ryo_bytecode::full::{Abs, Data, Opcode};

use super::emit::Width;
use super::place::{Loc, PlaceVal};
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
    pub fn const_value_into(&mut self, val: ConstValue, layout: TyAndLayout<'tcx>, dst: Loc) -> Result<(), NeedsNative> {
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
                if needs_fixup(self.tcx, alloc_id) {
                    // Copied out of the fixup area through its address.
                    let p = self.temp8();
                    self.pool_addr_into(p, alloc_id, offset.bytes())?;
                    return self.copy_val(dst, Loc::Mem { p, k: 0 }, size);
                }
                self.check_alloc(alloc_id)?;
                let offset = u32::try_from(offset.bytes()).map_err(|_| NeedsNative("constant offset".into()))?;
                self.with_slot(dst, size, |fx, d| {
                    let k = fx.reloc(CodeReloc::Const { alloc: alloc_id, offset });
                    fx.op(Opcode::Const, &[d, k, size]);
                    Ok(())
                })
            }
        }
    }

    /// Writes the address `offset` bytes into the allocation `id` to slot `d`.
    pub fn alloc_addr_into(&mut self, d: u32, id: AllocId, offset: u64) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        match tcx.global_alloc(id) {
            GlobalAlloc::Memory(_) => self.pool_addr_into(d, id, offset)?,
            // The image's own copy of the vtable (design/lowering.md#constants).
            GlobalAlloc::VTable(ty, dyn_ty) => self.pool_addr_into(d, vtable_alloc(tcx, ty, dyn_ty), offset)?,
            GlobalAlloc::Function { instance } => {
                self.addr_sym(d, CodeReloc::Symbol { target: instance });
                self.ptr_add(d, d, offset as i64);
            }
            GlobalAlloc::Static(def_id) => {
                check_static(tcx, def_id)?;
                self.addr_sym(d, CodeReloc::Static { def_id });
                self.ptr_add(d, d, offset as i64);
            }
            // A type id's "pointer" has no address: base 0, and the offset is part of the hash
            // (as in `rustc_codegen_llvm/src/common.rs:201-205`). It is a pointer-sized
            // scalar, so a 64-bit immediate.
            GlobalAlloc::TypeId { .. } => self.imm(Width::W64, d, u128::from(offset)),
        }
        Ok(())
    }

    /// The address `offset` bytes into the memory allocation `id`, in the constant pool or,
    /// on PE if it points at imports, in the fixup area.
    fn pool_addr_into(&mut self, d: u32, id: AllocId, offset: u64) -> Result<(), NeedsNative> {
        self.check_alloc(id)?;
        let offset = u32::try_from(offset).map_err(|_| NeedsNative("constant offset".into()))?;
        let a = if needs_fixup(self.tcx, id) {
            Abs::Data(Data(self.reloc(CodeReloc::Data { alloc: id, offset }))).to_word()
        } else {
            self.reloc(CodeReloc::Const { alloc: id, offset })
        };
        self.op(Opcode::AddrConst, &[d, a]);
        Ok(())
    }

    /// `ThreadLocalRef(def_id)`: a call of the static's `ThreadLocal` shim, which returns its
    /// address on the current thread in `rax` (design/lowering.md#rvalues). The merge pass
    /// adds the shim where rustc doesn't (ELF).
    pub fn thread_local_ref(&mut self, dst: PlaceVal<'tcx>, def_id: DefId) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        if tcx.is_foreign_item(def_id) {
            // There is no shim for foreign thread locals (`needs_thread_local_shim`).
            return native("ThreadLocalRef of a foreign thread local");
        }
        let shim = tls_shim(def_id);
        self.outgoing(0);
        self.with_place_slot(dst, |fx, d| {
            let r = CodeReloc::Symbol { target: shim };
            let op = if fx.sym_indirect(&r) { Opcode::CallSymInd } else { Opcode::CallSym };
            let sym = fx.reloc(r);
            // The shim only takes an address: it can't unwind (no cleanup entry).
            let k = ryo_bytecode::asm::ret_kind(&[ryo_bytecode::asm::RetPart { xmm: false, size: 8, off: 0 }]);
            let at = fx.op(op, &[d, sym, k]);
            let plan = super::sig::ArgPlan { locs: Vec::new(), stack_size: 0 };
            fx.cert_call(at, super::cert::CallKind::ThreadLocal, Some(&plan), k, 8);
            Ok(())
        })
    }

    /// Checks that the merge pass can put `id` (and everything it points at) in the pool.
    pub fn check_alloc(&self, id: AllocId) -> Result<(), NeedsNative> {
        check_alloc(self.tcx, id, &mut FxHashSet::default())
    }
}

/// The vtable allocation of `ty` for the trait object with predicates `preds`.
pub fn vtable_alloc<'tcx>(tcx: TyCtxt<'tcx>, ty: ty::Ty<'tcx>, preds: &'tcx ty::List<ty::PolyExistentialPredicate<'tcx>>) -> AllocId {
    let principal = preds.principal().map(|p| tcx.instantiate_bound_regions_with_erased(p));
    tcx.vtable_allocation((ty, principal))
}

/// The `ThreadLocal` shim of the thread-local static `def_id`: returns its address.
pub fn tls_shim<'tcx>(def_id: DefId) -> Instance<'tcx> {
    Instance { def: InstanceKind::Shim(ShimKind::ThreadLocal(def_id)), args: GenericArgs::empty() }
}

/// Whether `instance` is a `ThreadLocal` shim.
pub fn is_tls_shim(instance: Instance<'_>) -> bool {
    matches!(instance.def, InstanceKind::Shim(ShimKind::ThreadLocal(_)))
}

fn check_static(tcx: TyCtxt<'_>, def_id: DefId) -> Result<(), NeedsNative> {
    // MIR reaches thread locals only through `ThreadLocalRef`, and constants can't point at
    // them (const eval rejects it), so this doesn't happen.
    if tcx.is_thread_local_static(def_id) {
        return native("pointer to a thread-local static");
    }
    // A foreign static with `#[linkage]` (std's `weak!`, `extern_weak`): cg_llvm defines a
    // private static holding the symbol's address (null if undefined,
    // `rustc_codegen_llvm/src/consts.rs`, `check_and_apply_linkage`), and the static is that
    // cell. The image can't name it, and can't refer to a weak symbol.
    if tcx.is_foreign_item(def_id) && tcx.codegen_fn_attrs(def_id).import_linkage.is_some() {
        return native("static with an import linkage");
    }
    // An Objective-C class or selector reference (`core::os::darwin::objc`): cg_llvm doesn't
    // define the static's symbol but uses a private `OBJC_*_REFERENCES_` global of its own.
    let attrs = tcx.codegen_fn_attrs(def_id);
    if attrs.objc_class.is_some() || attrs.objc_selector.is_some() {
        return native("Objective-C class or selector reference");
    }
    Ok(())
}

/// Whether a pointer to `target` inside a constant must be a load-time fixup: on PE, a
/// function or static another crate or library defines is reached through its `__imp_`
/// slot (design/platforms.md), so its address isn't a link-time constant of the image.
pub fn is_import<'tcx>(tcx: TyCtxt<'tcx>, target: &GlobalAlloc<'tcx>) -> bool {
    match target {
        GlobalAlloc::Function { instance } => crate::symbols::symbol_flags(tcx, *instance, crate::symbols::SymRole::Target) != 0,
        GlobalAlloc::Static(def_id) => crate::symbols::static_symbol_flags(tcx, *def_id) != 0,
        GlobalAlloc::Memory(_) | GlobalAlloc::VTable(..) | GlobalAlloc::TypeId { .. } => false,
    }
}

/// Whether the memory allocation `id` goes into the image's fixup area rather than the
/// constant pool: it points directly at an import (PE only, design/lowering.md#constants).
/// Allocations that only point at such allocations stay in the pool.
pub fn needs_fixup(tcx: TyCtxt<'_>, id: AllocId) -> bool {
    if !crate::symbols::is_pe(tcx) {
        return false;
    }
    let alloc = match tcx.global_alloc(id) {
        GlobalAlloc::Memory(alloc) => alloc,
        GlobalAlloc::VTable(ty, dyn_ty) => return needs_fixup(tcx, vtable_alloc(tcx, ty, dyn_ty)),
        GlobalAlloc::Function { .. } | GlobalAlloc::Static(_) | GlobalAlloc::TypeId { .. } => return false,
    };
    alloc.inner().provenance().ptrs().values().any(|prov| is_import(tcx, &tcx.global_alloc(prov.alloc_id())))
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
        GlobalAlloc::Function { .. } | GlobalAlloc::TypeId { .. } => Ok(()),
        GlobalAlloc::Static(def_id) => check_static(tcx, def_id),
    }
}
