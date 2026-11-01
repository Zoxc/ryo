//! The allocator shim (design/backend.md, Allocator shim): what cg_ssa asks cg_llvm for in
//! every final artifact that links std statically (`rustc_codegen_ssa::base::codegen_crate`,
//! `rustc_codegen_llvm/src/allocator.rs`), written by [`objfile::write_allocator_shim`]
//! instead, so that cg_llvm needn't build an LLVM module for a handful of jumps: the same
//! functions (`allocator_shim_contents`, plus `__rust_no_alloc_shim_is_unstable_v2`), names,
//! linkage and visibility.
//!
//! cg_ssa decides with `allocator_kind_for_codegen`, which reads the `allocator_kind` query:
//! our override answers `None`, and [`write`] decides as cg_ssa would with rustc's answer. The
//! query's one other user (LTO aside, which is rejected) adds the shim's symbols to the export
//! list of a crate type exporting Rust-level symbols (`exported_symbols_for_non_proc_macro`,
//! `rustc_codegen_ssa/src/back/linker.rs`); [`exports`] gives `link` the same symbols.

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

/// Our `allocator_kind`: always `None`, so cg_ssa never asks cg_llvm for the shim.
pub fn allocator_kind(_tcx: TyCtxt<'_>, _original: Option<AllocatorKind>) -> Option<AllocatorKind> {
    None
}

/// The shim's symbols, as rustc names them.
fn shim_fns(tcx: TyCtxt<'_>, kind: AllocatorKind) -> Vec<ShimFn> {
    let mangle = |name: &str| mangle_internal_symbol(tcx, name);
    rustc_codegen_ssa::base::allocator_shim_contents(tcx, kind)
        .iter()
        .map(|m| ShimFn { name: mangle(&global_fn_name(m.name)), target: Some(mangle(&default_fn_name(m.name))) })
        .chain([ShimFn { name: mangle(NO_ALLOC_SHIM_IS_UNSTABLE), target: None }])
        .collect()
}

/// The symbols the linker branch of `exported_symbols_for_non_proc_macro` would add, per crate
/// type: the shim's, for a crate type at the `Rust` export level that links the shim
/// (`needs_allocator_shim_for_linking`), with rustc's allocator kind `real_kind`.
pub fn exports(tcx: TyCtxt<'_>, real_kind: Option<AllocatorKind>) -> Vec<(CrateType, Vec<String>)> {
    use rustc_middle::middle::dependency_format::Linkage;
    let Some(kind) = real_kind else { return Vec::new() };
    let formats = tcx.dependency_formats(());
    tcx.crate_types()
        .iter()
        .filter(|&&t| {
            rustc_codegen_ssa::back::symbol_export::crates_export_threshold(&[t]) == rustc_middle::middle::exported_symbols::SymbolExportLevel::Rust
        })
        .filter(|t| formats.get(*t).is_some_and(|list| !list.iter().any(|&l| l == Linkage::Dynamic)))
        .map(|&t| (t, shim_fns(tcx, kind).into_iter().map(|f| f.name).collect()))
        .collect()
}

/// Writes the shim object if cg_ssa would have asked for one (`allocator_kind_for_codegen`,
/// with the real allocator kind), as an allocator module for `join_codegen` to add.
pub fn write(tcx: TyCtxt<'_>, real_kind: Option<AllocatorKind>) -> Option<CompiledModule> {
    let all_dynamic = tcx.dependency_formats(()).iter().all(|(_, list)| {
        use rustc_middle::middle::dependency_format::Linkage;
        list.iter().any(|&l| l == Linkage::Dynamic)
    });
    let kind = real_kind.filter(|_| !all_dynamic)?;
    let _t = tcx.prof.generic_activity("ryo_write_allocator_shim");
    let fns = shim_fns(tcx, kind);
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
