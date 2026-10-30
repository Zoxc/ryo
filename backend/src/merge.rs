//! The merge pass (design/backend.md#pipeline step 5's contents): builds a CGU's image from
//! its lowered VM functions, with the constant pool, and names the island instances.

use rustc_data_structures::fx::{FxHashMap, FxHashSet};
use rustc_hir::attrs::Linkage;
use rustc_middle::mir::interpret::{AllocId, GlobalAlloc};
use rustc_middle::mono::{MonoItem, Visibility};
use rustc_middle::ty::{self, Instance, TyCtxt};
use rustc_span::Symbol;
use ryo_bytecode::asm::Ref;
use ryo_bytecode::full::{Const, Data, Func, Sym};
use ryo_bytecode::image::{AllocFixup, AllocReloc, AllocTarget, FuncSymbol, FunctionDef, ImageObject, ImageWriter, SYM_INDIRECT, SymVisibility};

use super::dump;
use super::lower::{self, CodeReloc};
use super::partition::{Fresh, ImageCx, VmFn};
use super::rt::RtItems;
use super::symbols::{self, local_stable_crate_id, static_symbol};

/// Each island instance the fresh images call: its symbol and its template's name.
pub(super) fn island_names<'tcx>(tcx: TyCtxt<'tcx>, rt: RtItems, fresh: &[Fresh<'tcx>]) -> Vec<(String, String)> {
    let mut out: Vec<(String, String)> = Vec::new();
    for v in fresh.iter().flat_map(|f| f.vm.iter()) {
        for r in &v.lowered.relocs {
            let CodeReloc::Island { template, args } = *r else { continue };
            let island = island_instance(tcx, rt, template, args);
            out.push((tcx.symbol_name(island).name.to_owned(), template.to_string()));
        }
    }
    out.sort();
    out.dedup();
    out
}

/// A CGU image's parts of the `RYO_DUMP` and `RYO_DUMP_CODE` texts (empty if those are off).
#[derive(Default)]
pub(super) struct ImageDumps {
    pub vm: String,
    pub code: String,
}

/// The merge pass of a CGU's image: resolves every function's relocations, then lays out the
/// image.
pub(super) fn build_image<'tcx>(cx: ImageCx<'_, 'tcx>, cgu_name: Symbol, vm: &mut [VmFn<'tcx>]) -> (ImageObject, ImageDumps) {
    let ImageCx { tcx, rt, mode, switches, .. } = cx;
    let mut dumps = ImageDumps::default();
    let mut w = ImageWriter::new(local_stable_crate_id(tcx));
    w.set_cgu_hash(ryo_bytecode::image::cgu_hash(cgu_name.as_str().as_bytes()));
    let mut pool = Pool::default();
    w.prepare(mode);
    if symbols::is_macho(tcx.sess) {
        // As LLVM writes `__eh_frame` (design/platforms.md).
        w.set_eh_pointers(ryo_bytecode::image::EhPointers::Abs8);
    }
    let mut encoded = Vec::with_capacity(vm.len());
    if switches.dump.is_some() {
        dumps.vm = dump::vm_text(tcx, vm, mode);
    }
    let mut code_dump = switches.dump_code.as_ref().map(|_| dump::code_text(tcx, vm, mode));
    let merge_t = tcx.prof.generic_activity("ryo_merge");
    let index: FxHashMap<Instance<'tcx>, u32> = vm.iter().enumerate().map(|(i, v)| (v.instance, i as u32)).collect();
    for (i, v) in vm.iter_mut().enumerate() {
        let l = &mut v.lowered;
        // Each reference's value.
        let vals: Vec<u32> = l
            .relocs
            .iter()
            .map(|r| match *r {
                CodeReloc::Call { callee } => index[&callee],
                CodeReloc::Symbol { target } => {
                    let flags = symbols::symbol_flags(tcx, target, symbols::SymRole::Target);
                    let Sym(s) = w.symbol(tcx.symbol_name(target).name, flags);
                    s
                }
                CodeReloc::Static { def_id } => {
                    let flags = symbols::static_symbol_flags(tcx, def_id);
                    let Sym(s) = w.symbol(static_symbol(tcx, def_id).name, flags);
                    s
                }
                CodeReloc::Const { alloc, offset } => pool.intern(tcx, &mut w, alloc).0 + offset,
                CodeReloc::Bytes { ref bytes, align } => pool.bytes(&mut w, bytes, align).0,
                CodeReloc::Data { alloc, offset } => pool.data(tcx, &mut w, alloc).0 + offset,
                CodeReloc::Island { template, args } => {
                    let island = island_instance(tcx, rt, template, args);
                    let flags = symbols::symbol_flags(tcx, island, symbols::SymRole::Island);
                    w.symbol(tcx.symbol_name(island).name, flags).0
                }
            })
            .collect();
        let mut code = std::mem::take(&mut l.code);
        if let Some(out) = &mut code_dump {
            dump::image_names(out, i, v.instance, &code.relocs, &vals);
        }
        for r in &mut code.relocs {
            let v = |i: u32| vals[i as usize];
            r.to = match r.to {
                Ref::Func(Func(i)) => Ref::Func(Func(v(i))),
                Ref::Sym(Sym(i)) => Ref::Sym(Sym(v(i))),
                Ref::Const(Const(i)) => Ref::Const(Const(v(i))),
                Ref::Data(Data(i)) => Ref::Data(Data(v(i))),
                Ref::Handler(_) | Ref::Probe | Ref::Ro(_) | Ref::Rec | Ref::RecLoopCtr | Ref::RegHandler(_) => r.to,
            };
        }
        // A global symbol with the function's linkage; an internal function native code
        // calls becomes hidden (design/backend.md, Linkage).
        let symbol = v.global.then(|| {
            let weak = !matches!(v.data.linkage, Linkage::External | Linkage::Internal);
            let visibility = match (v.data.linkage, v.data.visibility) {
                (Linkage::Internal, _) | (_, Visibility::Hidden) => SymVisibility::Hidden,
                (_, Visibility::Protected) => SymVisibility::Protected,
                (_, Visibility::Default) => SymVisibility::Default,
            };
            FuncSymbol { visibility, weak }
        });
        w.add_function(FunctionDef {
            name: tcx.symbol_name(v.instance).name.to_owned(),
            code: Vec::new(),
            frame_size: l.frame_size,
            arg_size: l.arg_size,
            ret_size: l.ret_size,
            ret_kind: l.ret_kind,
            cleanup: Vec::new(),
            symbol,
            flags: symbols::func_flags(tcx, v.instance),
        });
        encoded.push(code);
    }
    drop(merge_t);
    if let Some(text) = code_dump {
        dumps.code = text;
    }
    let _t = tcx.prof.generic_activity("ryo_finish_image");
    match w.finish_encoded(encoded) {
        Ok(image) => (image, dumps),
        Err(e) => tcx.dcx().fatal(format!("ryo: invalid image: {e:?}")),
    }
}

/// The instance of `ryo_rt`'s island template `template` for `args`.
pub(super) fn island_instance<'tcx>(tcx: TyCtxt<'tcx>, rt: RtItems, template: Symbol, args: ty::GenericArgsRef<'tcx>) -> Instance<'tcx> {
    let Some(def_id) = rt.item(tcx, template) else {
        tcx.dcx().fatal(format!("ryo_rt has no island template `{template}`; rebuild with `./y.sh build`"))
    };
    Instance::new_raw(def_id, args)
}

/// The image's constant pool: allocations copied with their pointers relocated
/// (design/lowering.md#constants), and raw byte constants. Deduplicated. On PE, allocations
/// pointing directly at imports go into the writable fixup area instead, with a load-time
/// fixup per such pointer (`lower::constant::needs_fixup`).
#[derive(Default)]
struct Pool {
    allocs: FxHashMap<AllocId, AllocTarget>,
    /// By alignment, then bytes (so that a hit looks up by `&[u8]` without allocating).
    bytes: FxHashMap<u32, FxHashMap<Vec<u8>, Const>>,
}

impl Pool {
    /// The pool copy of `id`, which must not need the fixup area.
    fn intern<'tcx>(&mut self, tcx: TyCtxt<'tcx>, w: &mut ImageWriter, id: AllocId) -> Const {
        match self.target(tcx, w, id) {
            AllocTarget::Const(k) => k,
            _ => tcx.dcx().fatal("ryo: constant-pool reference to a fixup-area allocation"),
        }
    }

    /// The fixup-area copy of `id`, which must need it.
    fn data<'tcx>(&mut self, tcx: TyCtxt<'tcx>, w: &mut ImageWriter, id: AllocId) -> Data {
        match self.target(tcx, w, id) {
            AllocTarget::Data(d) => d,
            _ => tcx.dcx().fatal("ryo: fixup-area reference to a constant-pool allocation"),
        }
    }

    /// Where the copy of the memory or vtable allocation `id` is.
    fn target<'tcx>(&mut self, tcx: TyCtxt<'tcx>, w: &mut ImageWriter, id: AllocId) -> AllocTarget {
        if let Some(&t) = self.allocs.get(&id) {
            return t;
        }
        let alloc = match tcx.global_alloc(id) {
            GlobalAlloc::Memory(alloc) => alloc,
            GlobalAlloc::VTable(ty, dyn_ty) => {
                let t = self.target(tcx, w, lower::vtable_alloc(tcx, ty, dyn_ty));
                self.allocs.insert(id, t);
                return t;
            }
            GlobalAlloc::Function { .. } | GlobalAlloc::Static(_) | GlobalAlloc::TypeId { .. } => {
                tcx.dcx().fatal("ryo: constant-pool reference to a non-memory allocation")
            }
        };
        let inner = alloc.inner();
        let mut bytes = inner.inspect_with_uninit_and_ptr_outside_interpreter(0..inner.len()).to_vec();
        let mut relocs = Vec::new();
        let mut fixups = Vec::new();
        for &(offset, prov) in inner.provenance().ptrs().iter() {
            let at = offset.bytes() as usize;
            let addend = i64::from_le_bytes(bytes[at..at + 8].try_into().unwrap());
            let target_alloc = tcx.global_alloc(prov.alloc_id());
            if lower::is_import(tcx, &target_alloc) {
                // Patched at registration from the `__imp_` slot (design/platforms.md).
                let name = match target_alloc {
                    GlobalAlloc::Function { instance } => tcx.symbol_name(instance).name,
                    GlobalAlloc::Static(def_id) => static_symbol(tcx, def_id).name,
                    _ => unreachable!("only functions and statics are imports"),
                };
                bytes[at..at + 8].fill(0);
                fixups.push(AllocFixup { offset: at as u32, sym: w.symbol(name, SYM_INDIRECT), addend });
                continue;
            }
            let target = match target_alloc {
                GlobalAlloc::Memory(_) | GlobalAlloc::VTable(..) => self.target(tcx, w, prov.alloc_id()),
                GlobalAlloc::Function { instance } => AllocTarget::Symbol(w.symbol(tcx.symbol_name(instance).name, 0)),
                GlobalAlloc::Static(def_id) => AllocTarget::Symbol(w.symbol(static_symbol(tcx, def_id).name, 0)),
                // No address: the bytes (the offset) are part of the type id's hash
                // (`rustc_codegen_llvm/src/common.rs:201-205`).
                GlobalAlloc::TypeId { .. } => continue,
            };
            bytes[at..at + 8].fill(0);
            relocs.push(AllocReloc { offset: at as u32, target, addend });
        }
        let align = inner.align.bytes() as u32;
        let t = if fixups.is_empty() {
            AllocTarget::Const(w.add_const(&bytes, align, &relocs))
        } else {
            AllocTarget::Data(w.add_data(&bytes, align, &relocs, &fixups))
        };
        self.allocs.insert(id, t);
        t
    }

    fn bytes(&mut self, w: &mut ImageWriter, bytes: &[u8], align: u32) -> Const {
        let by_bytes = self.bytes.entry(align).or_default();
        if let Some(&k) = by_bytes.get(bytes) {
            return k;
        }
        let k = w.add_const(bytes, align, &[]);
        by_bytes.insert(bytes.to_vec(), k);
        k
    }
}

/// The items an allocation refers to by symbol (functions and statics), through nested
/// allocations and vtables (like the collector's `collect_alloc`,
/// `rustc_monomorphize/src/collector.rs:1285`).
pub(super) fn alloc_refs<'tcx>(tcx: TyCtxt<'tcx>, id: AllocId, seen: &mut FxHashSet<AllocId>, out: &mut Vec<MonoItem<'tcx>>) {
    if !seen.insert(id) {
        return;
    }
    match tcx.global_alloc(id) {
        GlobalAlloc::Function { instance } => out.push(MonoItem::Fn(instance)),
        GlobalAlloc::Static(def_id) => out.push(MonoItem::Static(def_id)),
        GlobalAlloc::Memory(alloc) => {
            for prov in alloc.inner().provenance().ptrs().values() {
                alloc_refs(tcx, prov.alloc_id(), seen, out);
            }
        }
        GlobalAlloc::VTable(ty, dyn_ty) => alloc_refs(tcx, lower::vtable_alloc(tcx, ty, dyn_ty), seen, out),
        GlobalAlloc::TypeId { .. } => {}
    }
}
