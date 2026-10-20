//! `rustc_codegen_ryo`: the ryo codegen backend.
//!
//! For now this is a stub that forwards everything to cg_llvm. All compiler API use lives in
//! [`rustc_api`], so a toolchain bump only touches that module.
#![feature(rustc_private)]

mod rustc_api;

/// The entry point rustc looks up in a `-Zcodegen-backend=<path>` dylib.
#[unsafe(no_mangle)]
pub fn __rustc_codegen_backend() -> rustc_api::BoxedBackend {
    rustc_api::RyoBackend::new()
}
