//! The allocator shim (design/backend.md, Allocator shim): the `__rust_alloc` … forwarders
//! cg_ssa asks cg_llvm for in every final artifact that links std statically
//! (`rustc_codegen_ssa::base::codegen_crate`), written by [`objfile::write_allocator_shim`]
//! instead, so that cg_llvm needn't build an LLVM module for a handful of jumps.
//!
//! cg_ssa decides with `allocator_kind_for_codegen`, which reads the `allocator_kind` query:
//! our override answers `None` for cg_ssa where this module writes the shim. The query's one
//! other user is the export list of crate types that export Rust symbols (`dylib`,
//! `proc-macro`: `exported_symbols_for_non_proc_macro`, `rustc_codegen_ssa/src/back/linker.rs`),
//! which lists the shim's symbols; for those cg_llvm keeps writing it.

use rustc_ast::expand::allocator::{AllocatorKind, NO_ALLOC_SHIM_IS_UNSTABLE, default_fn_name, global_fn_name};
use rustc_codegen_ssa::CompiledModule;
use rustc_codegen_ssa::ModuleKind;
use rustc_hir::def_id::LOCAL_CRATE;
use rustc_middle::mono::CodegenUnitNameBuilder;
use rustc_middle::ty::TyCtxt;
use rustc_session::config::{CrateType, OutputType};
use rustc_symbol_mangling::mangle_internal_symbol;
use ryo_bytecode::image::SymVisibility;

use super::objfile::{self, ShimFn};

/// Whether the backend writes the shim itself rather than cg_llvm: no crate type exports
/// Rust-level symbols.
pub fn ours(tcx: TyCtxt<'_>) -> bool {
    !tcx.crate_types().iter().any(|t| matches!(t, CrateType::Dylib | CrateType::ProcMacro | CrateType::Sdylib))
}

/// Our `allocator_kind`: `None` where [`ours`], so cg_ssa doesn't ask cg_llvm for the shim.
pub fn allocator_kind(tcx: TyCtxt<'_>, original: Option<AllocatorKind>) -> Option<AllocatorKind> {
    if ours(tcx) { None } else { original }
}

/// Writes the shim object if cg_ssa would have asked for one (`allocator_kind_for_codegen`,
/// with the real allocator kind), as an allocator module for `join_codegen` to add.
pub fn write(tcx: TyCtxt<'_>, real_kind: Option<AllocatorKind>) -> Option<CompiledModule> {
    if !ours(tcx) {
        return None;
    }
    let all_dynamic = tcx.dependency_formats(()).iter().all(|(_, list)| {
        use rustc_middle::middle::dependency_format::Linkage;
        list.iter().any(|&l| l == Linkage::Dynamic)
    });
    let kind = real_kind.filter(|_| !all_dynamic)?;
    let _t = tcx.prof.generic_activity("ryo_write_allocator_shim");
    let mangle = |name: &str| mangle_internal_symbol(tcx, name);
    let fns: Vec<ShimFn> = rustc_codegen_ssa::base::allocator_shim_contents(tcx, kind)
        .iter()
        .map(|m| ShimFn { name: mangle(&global_fn_name(m.name)), target: Some(mangle(&default_fn_name(m.name))) })
        .chain([ShimFn { name: mangle(NO_ALLOC_SHIM_IS_UNSTABLE), target: None }])
        .collect();
    // As cg_llvm declares them (`create_wrapper_function`).
    let visibility = match tcx.sess.default_visibility() {
        rustc_target::spec::SymbolVisibility::Hidden => SymVisibility::Hidden,
        rustc_target::spec::SymbolVisibility::Protected => SymVisibility::Protected,
        rustc_target::spec::SymbolVisibility::Interposable => SymVisibility::Default,
    };
    let bytes = objfile::write_allocator_shim(&*super::object_format(tcx.sess), &fns, visibility).unwrap_or_else(|e| tcx.dcx().fatal(e));
    let name = CodegenUnitNameBuilder::new(tcx).build_cgu_name(LOCAL_CRATE, &["crate"], Some("allocator")).to_string();
    let path = tcx.output_filenames(()).temp_path_for_cgu(OutputType::Object, &name);
    let _ = std::fs::remove_file(&path);
    super::link::write_or_fatal(tcx.sess, &path, &bytes);
    let mut module = super::link::object_module(name, path);
    module.kind = ModuleKind::Allocator;
    Some(module)
}
