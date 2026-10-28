//! The `upstream_monomorphizations` and `exported_generic_symbols` query overrides
//! (design/backend.md#query-overrides), which depend on the partitioner's results.

use rustc_data_structures::fx::FxHashSet;
use rustc_hir::def_id::{CrateNum, DefId};
use rustc_middle::middle::exported_symbols::{ExportedSymbol, SymbolExportInfo, SymbolExportKind, SymbolExportLevel};
use rustc_middle::mono::Visibility;
use rustc_middle::ty::{self, Instance, InstanceKind, Ty, TyCtxt};

use super::partition::{is_runtime_crate, results_untracked};

/// The value of `upstream_monomorphizations`: per generic item, the upstream crate whose copy
/// of each instance to link to.
pub type UpstreamMonos<'tcx> = rustc_hir::def_id::DefIdMap<rustc_data_structures::unord::UnordMap<ty::GenericArgsRef<'tcx>, CrateNum>>;

/// Our `upstream_monomorphizations` (design/backend.md#query-overrides): rustc's, without the
/// copies in the runtime crates ([`RUNTIME_CRATES`](super::partition::RUNTIME_CRATES)) of other crates' generics. rustc shares
/// `#[inline(never)]` instances even without share-generics; linking to them would turn the
/// program's own instances into the runtime's native code. A guard: the runtime used to
/// instantiate std's in its JIT, which is now a sealed object of its own (design/jit.md#packaging).
pub fn upstream_monomorphizations<'tcx>(tcx: TyCtxt<'tcx>, map: UpstreamMonos<'tcx>) -> UpstreamMonos<'tcx> {
    let runtime = |c: CrateNum| is_runtime_crate(tcx, c);
    map.into_items()
        .filter_map(|(def, args)| {
            let args: rustc_data_structures::unord::UnordMap<_, _> =
                if runtime(def.krate) { args } else { args.into_items().filter(|&(_, c)| !runtime(c)).collect() };
            (!args.is_empty()).then_some((def, args))
        })
        .collect()
}

/// Our local `exported_generic_symbols` (design/backend.md#query-overrides): rustc lists the
/// native CGU's generic items; the VM functions' symbols the image defines are added as
/// rustc would list them if they were in the CGU (`exported_generic_symbols_provider_local`:
/// generic `Item` instances and drop glue shims), and items made hidden only for the image
/// aren't listed.
pub fn exported_generic_symbols<'tcx>(
    tcx: TyCtxt<'tcx>,
    list: &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)],
) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)] {
    if !tcx.sess.opts.output_types.should_codegen() {
        return list;
    }
    let Some(r) = results_untracked(tcx) else { return list };
    let hidden: FxHashSet<Instance<'tcx>> = r.exports(tcx).hidden_for_image.iter().copied().collect();
    let mut out: Vec<_> = list
        .iter()
        .copied()
        .filter(|&(s, _)| match s {
            ExportedSymbol::Generic(def_id, args) => !hidden.contains(&Instance::new_raw(def_id, args)),
            ExportedSymbol::DropGlue(ty) => !hidden.contains(&Instance::resolve_drop_glue(tcx, ty)),
            _ => true,
        })
        .collect();
    if tcx.local_crate_exports_generics() {
        let need_visibility = tcx.sess.target.dynamic_linking && !tcx.sess.target.only_cdylib;
        let reachable = tcx.reachable_set(());
        let local_unreachable = |ty: Ty<'tcx>| {
            let root = match ty.peel_refs().kind() {
                ty::Closure(d, _) | ty::FnDef(d, _) | ty::Coroutine(d, _) | ty::CoroutineClosure(d, _) | ty::CoroutineWitness(d, _) => *d,
                _ => return false,
            };
            root.as_local().is_some_and(|d| !reachable.contains(&d))
        };
        let downstream = |def: Option<DefId>, args: ty::GenericArgsRef<'tcx>| {
            args.types().chain(def.map(|d| tcx.type_of(d).skip_binder())).all(|t| t.walk().all(|a| a.as_type().is_none_or(|t| !local_unreachable(t))))
        };
        let info = SymbolExportInfo { level: SymbolExportLevel::Rust, kind: SymbolExportKind::Text, used: false, rustc_std_internal_symbol: false };
        for &(instance, vis) in &r.exports(tcx).vm {
            if need_visibility && vis == Visibility::Hidden {
                continue;
            }
            if !tcx.sess.opts.share_generics() && tcx.codegen_fn_attrs(instance.def_id()).inline != rustc_hir::attrs::InlineAttr::Never {
                continue;
            }
            // The kinds rustc shares (`symbol_export.rs:398-484`).
            let symbol = match instance.def {
                InstanceKind::Item(def) => (instance.args.non_erasable_generics().next().is_some() && downstream(Some(def), instance.args))
                    .then_some(ExportedSymbol::Generic(def, instance.args)),
                InstanceKind::Shim(ty::ShimKind::DropGlue(_, Some(ty))) => {
                    let shared = match ty.kind() {
                        ty::Adt(_, args) | ty::Closure(_, args) => downstream(None, args),
                        _ => true,
                    };
                    shared.then_some(ExportedSymbol::DropGlue(ty))
                }
                InstanceKind::Shim(ty::ShimKind::AsyncDropGlueCtor(_, ty)) => Some(ExportedSymbol::AsyncDropGlueCtorShim(ty)),
                InstanceKind::Shim(ty::ShimKind::AsyncDropGlue(def, ty)) => Some(ExportedSymbol::AsyncDropGlue(def, ty)),
                _ => None,
            };
            out.extend(symbol.map(|s| (s, info)));
        }
    }
    out.sort_by_cached_key(|s| s.0.symbol_name_for_local_instance(tcx));
    tcx.arena.alloc_from_iter(out)
}
