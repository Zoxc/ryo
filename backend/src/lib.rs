//! `rustc_codegen_ryo`: the ryo codegen backend (design/backend.md).
//!
//! All compiler API use lives in [`rustc_api`], so a toolchain bump only touches that module.
//! [`objfile`] writes the image and registry objects without compiler types.
#![feature(rustc_private)]

// The compiler crates, for `rustc_api` (the only module that uses them).
extern crate rustc_abi;
extern crate rustc_codegen_llvm;
extern crate rustc_codegen_ssa;
extern crate rustc_data_structures;
extern crate rustc_hir;
extern crate rustc_metadata;
extern crate rustc_middle;
extern crate rustc_session;
extern crate rustc_span;
extern crate rustc_target;

// Links the compiler's own `librustc_driver` dylib, which holds all the crates above.
extern crate rustc_driver;

mod objfile;
mod rustc_api;

/// The entry point rustc looks up in a `-Zcodegen-backend=<path>` dylib.
#[unsafe(no_mangle)]
pub fn __rustc_codegen_backend() -> rustc_api::BoxedBackend {
    rustc_api::RyoBackend::new()
}
