//! With the `jit` feature, bundles the sealed JIT (`libryo_jit.a`, or `ryo_jit.lib` on
//! msvc) from `RYO_JIT_LIB_DIR` into the rlib (design/build.md#build, design/jit.md#packaging):
//! `y build` builds and seals it first. Without `RYO_JIT_LIB_DIR` (`vm/`'s own tests) the
//! `ryo_jit` crate must be linked as an rlib instead, for its `ryo_jit_start_<tag>`.
//!
//! Also passes the ABI tag (`RYO_ABI`, `dev` without it; design/build.md#the-abi-tag) on to the
//! crate as `RYO_ABI`, for the suffix of its symbols (`tagged!`), as `ryo_bytecode::ABI_TAG`
//! reads it.

use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-env-changed=RYO_JIT_LIB_DIR");
    println!("cargo:rerun-if-env-changed=RYO_ABI");
    println!("cargo:rustc-env=RYO_ABI={}", std::env::var("RYO_ABI").unwrap_or_else(|_| "dev".to_owned()));
    if std::env::var_os("CARGO_FEATURE_JIT").is_none() {
        return;
    }
    let Some(dir) = std::env::var_os("RYO_JIT_LIB_DIR").map(PathBuf::from) else { return };
    let msvc = std::env::var("CARGO_CFG_TARGET_ENV").is_ok_and(|e| e == "msvc");
    println!("cargo:rerun-if-changed={}", dir.join(if msvc { "ryo_jit.lib" } else { "libryo_jit.a" }).display());
    println!("cargo:rustc-link-search=native={}", dir.display());
    println!("cargo:rustc-link-lib=static=ryo_jit");
}
