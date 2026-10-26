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

/// The image slot flags for `target` used as `role`: on PE, a [`SymRole::Target`] symbol
/// defined outside this crate (an upstream crate's, or a foreign item) gets an indirect slot
/// ([`SYM_INDIRECT`](ryo_bytecode::image::SYM_INDIRECT)), relocated against its `__imp_`
/// import slot, and the instruction must be the `.ind` form (`addr.sym.ind`,
/// `call.ext.ind`). Islands are always direct: a direct reference to a function in another
/// DLL resolves to its import thunk, which is fine to call. The writer keys slots by name and
/// flags, so one symbol can have both.
pub(crate) fn symbol_flags<'tcx>(tcx: TyCtxt<'tcx>, target: Instance<'tcx>, role: SymRole) -> u8 {
    if is_pe(tcx) && role == SymRole::Target && !tcx.should_codegen_locally(target) { ryo_bytecode::image::SYM_INDIRECT } else { 0 }
}

/// [`symbol_flags`] for a static used as an address: on PE, statics of upstream crates and
/// foreign statics are imports.
pub(crate) fn static_symbol_flags(tcx: TyCtxt<'_>, def_id: DefId) -> u8 {
    if is_pe(tcx) && (!def_id.is_local() || tcx.is_foreign_item(def_id)) { ryo_bytecode::image::SYM_INDIRECT } else { 0 }
}

/// Whether a static with an indirect slot also needs a direct one: a foreign static from a
/// static library. Upstream Rust statics don't (rustc defines `__imp_<sym>` for the data of
/// rlibs), and data in a DLL can't be referenced directly.
pub(crate) fn static_needs_direct_slot(tcx: TyCtxt<'_>, def_id: DefId) -> bool {
    tcx.is_foreign_item(def_id) && tcx.native_library(def_id).is_some_and(|lib| matches!(lib.kind, rustc_hir::attrs::NativeLibKind::Static { .. }))
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

/// The symbol of one of `ryo_rt`'s handlers or `ryo_probe_stack` (`#[rustc_std_internal_symbol]`s).
pub fn rt_symbol(tcx: TyCtxt<'_>, name: &str) -> String {
    rustc_symbol_mangling::mangle_internal_symbol(tcx, name)
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
        && let Some(rt) = super::partition::rt_items(tcx)
        && def_id.krate == rt.krate
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
