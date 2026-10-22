//! `y build-clif` (design/build.md#build-clif-the-cranelift-backend-on-stable): cg_clif, built
//! from the pinned toolchain's rustc-dev sources, installed into `dist/` with a `rustc-clif`
//! wrapper.

use std::fs;
use std::path::{Path, PathBuf};

use crate::dist::{build_wrapper, copy, copy_dir};
use crate::utils::{RustcInfo, cmd, dll_name, exe_name, root, run};

/// `dist/bin/rustc-clif`.
pub fn rustc_clif(root: &Path) -> PathBuf {
    root.join("dist").join("bin").join(exe_name("rustc-clif"))
}

/// Whether `dist/` has cg_clif and its wrapper (`y build` replaces `dist/`, removing them).
pub fn installed(root: &Path) -> bool {
    rustc_clif(root).exists() && root.join("dist").join("lib").join(dll_name(DYLIB)).exists()
}

const DYLIB: &str = "rustc_codegen_cranelift";

pub fn build() -> Result<(), String> {
    let info = RustcInfo::get()?;
    let root = root();
    let dist = root.join("dist");
    if !dist.join("bin").join(exe_name("rustc-ryo")).exists() {
        return Err("dist/ is missing; run `./y.sh build` first (cg_clif uses its std)".to_owned());
    }

    let src = info.sysroot.join("lib/rustlib/rustc-src/rust/compiler/rustc_codegen_cranelift");
    if !src.join("Cargo.toml").exists() {
        return Err(format!("{} is missing; install the `rustc-dev` component of the pinned toolchain", src.display()));
    }
    eprintln!("[y] cg_clif: copying {} to build/clif/", src.display());
    let copy_to = root.join("build").join("clif");
    if copy_to.exists() {
        fs::remove_dir_all(&copy_to).map_err(|e| format!("removing {}: {e}", copy_to.display()))?;
    }
    copy_dir(&src, &copy_to)?;

    eprintln!("[y] cg_clif: rustc_codegen_cranelift");
    // Outside build/clif/, so recopying the sources keeps the build cache.
    let target_dir = root.join("target").join("clif");
    run(cmd("cargo")
        .args(["build", "--release", "-Zembed-metadata=no", "--manifest-path"])
        .arg(copy_to.join("Cargo.toml"))
        .arg("--target-dir")
        .arg(&target_dir)
        // Without it cg_clif aborts on panic; std and the test corpus use `-Cpanic=unwind`.
        // cg_clif's own build enables it with `--panic-unwind-support`.
        .args(["--features", "unwinding"])
        // cg_clif's own `rust-toolchain.toml` names a nightly; build with ours.
        .env("RUSTUP_TOOLCHAIN", &info.toolchain))
    .map_err(|e| {
        format!(
            "{e}\nnote: building cg_clif fetches the Cranelift crates from crates.io (through its \
             Cargo.lock), so it needs network access the first time, or a vendored copy \
             configured in cargo's config"
        )
    })?;

    copy(&target_dir.join("release").join(dll_name(DYLIB)), &dist.join("lib").join(dll_name(DYLIB)))?;
    build_wrapper(&root, &dist.join("bin"), &info, "rustc-clif")?;
    eprintln!("[y] done: {}", rustc_clif(&root).display());
    Ok(())
}

/// Builds cg_clif unless `dist/` already has it.
pub fn ensure() -> Result<(), String> {
    if installed(&root()) { Ok(()) } else { build() }
}
