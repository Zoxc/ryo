//! The image's symbol and linkage policy: what symbol a reference names, and whether its slot
//! is indirect (PE imports, design/platforms.md).

use rustc_hir::def_id::{DefId, LOCAL_CRATE};
use rustc_middle::mono::{InstantiationMode, MonoItem};
use rustc_middle::ty::{self, Instance, InstanceKind, TyCtxt};

/// How an image symbol slot is used, which decides whether it is indirect
/// (design/platforms.md, design/vm.md#image-format).
#[derive(Clone, Copy, PartialEq, Eq)]
pub(crate) enum SymRole {
    /// The `sym` of `addr.sym`/`addr.sym.ind` or `call.ext`/`call.ext.ind`: its address is
    /// observable, so on PE it must be the real one.
    Target,
    /// An `island` instruction's `sym`, or the `island` operand of a call: only ever called.
    Island,
}

/// The image slot flags for `target` used as `role`: on PE, an indirect slot
/// ([`SYM_INDIRECT`](ryo_bytecode::image::SYM_INDIRECT)), relocated against the `__imp_`
/// import slot, exactly where cg_llvm declares the function `dllimport`
/// (`rustc_codegen_llvm/src/callee.rs`): a foreign function whose library's kind is `dylib`,
/// `raw-dylib` or unspecified (`NativeLibKind::is_dllimport`). The instruction must then be
/// the `.ind` form (`addr.sym.ind`, `call.ext.ind`). Everything else is direct, as in native
/// code: upstream Rust functions (also generic instances and Rust dylibs' functions, which
/// resolve to the import thunk), and foreign functions from a `kind = "static"` library or
/// without `#[link]`. So no `__imp_` is left for the linker to synthesize (LNK4217). Islands
/// are always direct.
pub(crate) fn symbol_flags<'tcx>(tcx: TyCtxt<'tcx>, target: Instance<'tcx>, role: SymRole) -> u8 {
    let def_id = target.def_id();
    let import =
        is_pe(tcx) && role == SymRole::Target && tcx.is_foreign_item(def_id) && tcx.native_library(def_id).is_some_and(|lib| lib.kind.is_dllimport());
    if import { ryo_bytecode::image::SYM_INDIRECT } else { 0 }
}

/// [`symbol_flags`] for a static used as an address, also as cg_llvm decides `dllimport`
/// (`rustc_codegen_llvm/src/consts.rs`): on PE, statics of upstream crates are imports
/// (rustc defines `__imp_<sym>` for the data of rlibs, and a Rust dylib exports it), and
/// foreign statics are where cg_llvm declares them `dllimport`: only when their library's
/// kind is `dylib`, `raw-dylib` or unspecified (`rustc_codegen_llvm/src/consts.rs`). One from
/// a `kind = "static"` library, a `-l` library without `#[link]` or `link-arg` is direct, so
/// the reference pulls in the archive member defining it. EII statics, encoded as foreign
/// items but defined by Rust crates, follow the upstream rule. An upstream static this crate
/// defines (an upstream EII static implemented here, whose symbol cg_llvm defines as an alias
/// of the implementation) is direct, as in cg_llvm's code next to that definition
/// ([`partition::is_defined_upstream_static`]), so the linker synthesizes no
/// `__imp_` (LNK4217).
///
/// One difference remains: with `-Crelocation-model=static` or
/// `-Zdirect-access-external-data=yes`, cg_llvm treats upstream statics as `dso_local` and
/// accesses them directly (`rustc_codegen_llvm/src/mono_item.rs`, `assume_dso_local`), where
/// this still goes through `__imp_`. Both link: the rlib defines `__imp_<sym>`
/// (`create_msvc_imps`) and a Rust dylib exports it, so no warning results.
///
/// [`partition::is_defined_upstream_static`]: super::partition::is_defined_upstream_static
pub(crate) fn static_symbol_flags(tcx: TyCtxt<'_>, def_id: DefId) -> u8 {
    if !is_pe(tcx) {
        return 0;
    }
    use rustc_middle::middle::codegen_fn_attrs::CodegenFnAttrFlags;
    let eii = tcx.codegen_fn_attrs(def_id).flags.contains(CodegenFnAttrFlags::EXTERNALLY_IMPLEMENTABLE_ITEM);
    let import = if tcx.is_foreign_item(def_id) && !eii {
        tcx.native_library(def_id).is_some_and(|lib| lib.kind.is_dllimport())
    } else {
        !def_id.is_local() && !super::partition::is_defined_upstream_static(tcx, def_id)
    };
    if import { ryo_bytecode::image::SYM_INDIRECT } else { 0 }
}

/// Whether the target uses PE/COFF objects.
pub(crate) fn is_pe(tcx: TyCtxt<'_>) -> bool {
    matches!(tcx.sess.target.binary_format, rustc_target::spec::BinaryFormat::Coff)
}

/// The image's function flags for `instance` ([`FUNC_INLINE_ALWAYS`] etc., read by the JIT's
/// inliner): its `#[inline(..)]` and `#[cold]` attributes, through
/// `codegen_instance_attrs`, so shims get their item's.
///
/// [`FUNC_INLINE_ALWAYS`]: ryo_bytecode::image::FUNC_INLINE_ALWAYS
pub(crate) fn func_flags<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> u8 {
    use rustc_hir::attrs::InlineAttr;
    use rustc_middle::middle::codegen_fn_attrs::CodegenFnAttrFlags;
    use ryo_bytecode::image::*;
    let attrs = tcx.codegen_instance_attrs(instance.def);
    let inline = match attrs.inline {
        InlineAttr::Always | InlineAttr::Force { .. } => FUNC_INLINE_ALWAYS,
        InlineAttr::Never => FUNC_INLINE_NEVER,
        InlineAttr::Hint => FUNC_INLINE_HINT,
        InlineAttr::None => 0,
    };
    inline | if attrs.flags.contains(CodegenFnAttrFlags::COLD) { FUNC_COLD } else { 0 }
}

/// The symbol of one of `ryo_rt`'s entry points (`#[rustc_std_internal_symbol]`s: the
/// handlers, `ryo_probe_stack`, the trips, `ryo_vm_register` …): `name` with the ABI tag
/// (`<name>_<tag>`, design/build.md#the-abi-tag), mangled.
pub fn rt_symbol(tcx: TyCtxt<'_>, name: &str) -> String {
    rustc_symbol_mangling::mangle_internal_symbol(tcx, &format!("{name}_{}", ryo_bytecode::ABI_TAG))
}

/// The symbol of a static (its own, or the foreign item's link name).
pub(crate) fn static_symbol<'tcx>(tcx: TyCtxt<'tcx>, def_id: DefId) -> ty::SymbolName<'tcx> {
    tcx.symbol_name(Instance::mono(tcx, def_id))
}

pub fn local_stable_crate_id(tcx: TyCtxt<'_>) -> u64 {
    tcx.stable_crate_id(LOCAL_CRATE).as_u64()
}

/// Our `symbol_name` (design/backend.md#query-overrides): `c_main` is the target's entry name, and local copies of `LocalCopy` instances get
/// a crate-unique suffix (design/backend.md, Linkage).
pub fn symbol_name<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>, original: impl FnOnce() -> ty::SymbolName<'tcx>) -> ty::SymbolName<'tcx> {
    if let InstanceKind::Item(def_id) = instance.def
        && super::partition::is_rt_crate(tcx, def_id.krate)
        && let Some(rt) = super::partition::rt_items_in(tcx, def_id.krate)
    {
        if def_id == rt.c_main {
            return ty::SymbolName::new(tcx, &tcx.sess.target.entry_name);
        }
    }
    let name = original();
    if !symbol_from_attrs(tcx, instance)
        && MonoItem::Fn(instance).instantiation_mode(tcx) == InstantiationMode::LocalCopy
        && instance.upstream_monomorphization(tcx).is_none()
    {
        return ty::SymbolName::new(tcx, &format!("{}.ryo{:016x}", name.name, local_stable_crate_id(tcx)));
    }
    name
}

/// Whether `instance`'s symbol is fixed by its attributes or is a foreign item's (an LLVM
/// intrinsic's, `#[no_mangle]`, `#[rustc_std_internal_symbol]`): it must not get the
/// crate-unique suffix.
fn symbol_from_attrs<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> bool {
    rustc_symbol_mangling::symbol_name_from_attrs(tcx, instance.def).is_some()
}

/// The names under which rustc would export the runtime crates' symbols ([`RUNTIME_CRATES`]'
/// `exported_non_generic_symbols` and `exported_generic_symbols`, named as
/// `symbol_name_for_instance_in_crate` does), for a Rust dylib's export filter (link.rs):
/// exact names, so no user item that merely mentions `ryo_rt` is dropped.
///
/// [`RUNTIME_CRATES`]: super::partition::RUNTIME_CRATES
pub fn runtime_exports(tcx: TyCtxt<'_>) -> rustc_data_structures::fx::FxHashSet<String> {
    use rustc_middle::middle::exported_symbols::ExportedSymbol;
    let mut out = rustc_data_structures::fx::FxHashSet::default();
    for &cnum in tcx.crates(()) {
        if !super::partition::is_runtime_crate(tcx, cnum) {
            continue;
        }
        for &(sym, _) in tcx.exported_non_generic_symbols(cnum).iter().chain(tcx.exported_generic_symbols(cnum)) {
            let instance = match sym {
                ExportedSymbol::NonGeneric(def_id) => Instance::mono(tcx, def_id),
                ExportedSymbol::Generic(def_id, args) => Instance::new_raw(def_id, args),
                ExportedSymbol::ThreadLocalShim(def_id) => {
                    Instance { def: InstanceKind::Shim(ty::ShimKind::ThreadLocal(def_id)), args: ty::GenericArgs::empty() }
                }
                ExportedSymbol::DropGlue(ty) => Instance::resolve_drop_glue(tcx, ty),
                ExportedSymbol::AsyncDropGlueCtorShim(ty) => Instance::resolve_async_drop_in_place(tcx, ty),
                ExportedSymbol::AsyncDropGlue(def_id, ty) => Instance::resolve_async_drop_in_place_poll(tcx, def_id, ty),
                ExportedSymbol::NoDefId(name) => {
                    out.insert(name.to_string());
                    continue;
                }
            };
            out.insert(rustc_symbol_mangling::symbol_name_for_instance_in_crate(tcx, instance, cnum));
        }
    }
    out
}
