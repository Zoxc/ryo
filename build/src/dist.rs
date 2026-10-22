//! `y build` and `y clean`: the `dist/` sysroot (design/build.md#build).

use std::fs;
use std::path::{Path, PathBuf};

use crate::utils::{RustcInfo, cmd, dll_name, exe_name, output, root, run};

/// Unstable features the backend may use, even though `RUSTC_BOOTSTRAP` allows all.
const BACKEND_FEATURES: &str = "rustc_private";

/// `targets`: extra targets to install std and `ryo_rt` for, for cross-compiling with
/// `rustc-ryo --target` (their rust-std component must be installed).
/// With `ryo_std`, also builds std with the ryo backend into `dist/sysroot-ryo`
/// (`--sysroot ryo`).
pub fn build(targets: &[String], ryo_std: bool) -> Result<(), String> {
    let info = RustcInfo::get()?;
    let root = root();
    let dist = root.join("dist");
    let target = root.join("target");

    let backend = build_backend(&root, &target, &info)?;

    eprintln!("[y] sysroot: dist/");
    if dist.exists() {
        fs::remove_dir_all(&dist).map_err(|e| format!("removing {}: {e}", dist.display()))?;
    }
    let dist_lib = dist.join("lib");
    let dist_bin = dist.join("bin");
    for dir in [&dist_lib, &dist_bin] {
        fs::create_dir_all(dir).map_err(|e| format!("creating {}: {e}", dir.display()))?;
    }
    copy(&backend, &dist_lib.join(dll_name("rustc_codegen_ryo")))?;
    let mut all = vec![info.host.clone()];
    all.extend(targets.iter().filter(|t| **t != info.host).cloned());
    for triple in &all {
        let target_lib = dist_lib.join("rustlib").join(triple).join("lib");
        fs::create_dir_all(&target_lib).map_err(|e| format!("creating {}: {e}", target_lib.display()))?;
        install_llvm_sysroot(&info, &dist, triple)?;
        let cross = (*triple != info.host).then_some(triple.as_str());
        for (krate, rlib) in build_runtime(&root, &target, &dist, cross)? {
            copy(&rlib, &target_lib.join(format!("lib{krate}.rlib")))?;
        }
    }

    build_wrappers(&root, &dist_bin, &info)?;
    if ryo_std {
        crate::sysroot::build(&info, &dist)?;
    }
    eprintln!("[y] done: {}", dist.display());
    Ok(())
}

pub fn clean() -> Result<(), String> {
    let root = root();
    for dir in [root.join("dist"), root.join("target")] {
        if dir.exists() {
            eprintln!("[y] removing {}", dir.display());
            fs::remove_dir_all(&dir).map_err(|e| format!("removing {}: {e}", dir.display()))?;
        }
    }
    Ok(())
}

/// Builds `backend/` and returns the path of the dylib.
fn build_backend(root: &Path, target: &Path, info: &RustcInfo) -> Result<PathBuf, String> {
    eprintln!("[y] backend: rustc_codegen_ryo");
    let target_dir = target.join("backend");
    let mut rustflags = std::env::var("RUSTFLAGS").unwrap_or_default();
    if !rustflags.is_empty() {
        rustflags.push(' ');
    }
    rustflags.push_str(&format!("-Zallow-features={BACKEND_FEATURES}"));
    run(cmd("cargo")
        .args(["build", "--release", "-Zembed-metadata=no", "--manifest-path"])
        .arg(root.join("backend").join("Cargo.toml"))
        .arg("--target-dir")
        .arg(&target_dir)
        .env("RUSTFLAGS", rustflags)
        // Full optimization, independent of user settings: one codegen unit and fat LTO over
        // the backend's own crates (librustc_driver stays a dynamic dependency).
        .env("CARGO_PROFILE_RELEASE_CODEGEN_UNITS", "1")
        .env("CARGO_PROFILE_RELEASE_LTO", "fat")
        .env("RUSTUP_TOOLCHAIN", &info.toolchain))?;
    Ok(target_dir.join("release").join(dll_name("rustc_codegen_ryo")))
}

/// Copies the toolchain's prebuilt std for `triple` into `dist/`, skipping the rustc-dev and
/// LLVM libraries, as cg_clif does. Also copies the target's `bin/` (the self-contained linker).
fn install_llvm_sysroot(info: &RustcInfo, dist: &Path, triple: &str) -> Result<(), String> {
    let rel = Path::new("lib").join("rustlib").join(triple);
    let src_lib = info.sysroot.join(&rel).join("lib");
    if !src_lib.is_dir() {
        return Err(format!("no std for {triple} in the toolchain; run `rustup target add {triple}`"));
    }
    let dst_lib = dist.join(&rel).join("lib");
    for entry in fs::read_dir(&src_lib).map_err(|e| format!("{}: {e}", src_lib.display()))? {
        let entry = entry.map_err(|e| e.to_string())?;
        if entry.file_type().map_err(|e| e.to_string())?.is_dir() {
            continue;
        }
        let name = entry.file_name();
        if is_std_lib(&name.to_string_lossy()) {
            copy(&entry.path(), &dst_lib.join(&name))?;
        }
    }
    let src_bin = info.sysroot.join(&rel).join("bin");
    if src_bin.is_dir() {
        copy_dir(&src_bin, &dist.join(&rel).join("bin"))?;
    }
    Ok(())
}

/// Whether to copy a file from the toolchain's `lib/rustlib/<target>/lib`. This is the same
/// coarse filter as cg_clif's `build_llvm_sysroot_for_triple`: it skips the `rustc_*` and LLVM
/// libraries, but still lets through the `.rmeta`s and proc-macro dylibs of rustc-dev's
/// third-party dependencies (unused, but harmless).
fn is_std_lib(file_name: &str) -> bool {
    let rustc_dev = file_name.contains("rustc_")
        && !file_name.contains("rustc_std_workspace_")
        && !file_name.contains("rustc_demangle")
        && !file_name.contains("rustc_literal_escaper");
    !rustc_dev && !file_name.contains("LLVM")
}

/// Builds `ryo_rt` (and `ryo_bytecode`) with the stock LLVM backend against `dist/`'s std, for
/// the host or the `cross` target, and returns their crate names and rlibs.
fn build_runtime(
    root: &Path,
    target: &Path,
    dist: &Path,
    cross: Option<&str>,
) -> Result<Vec<(&'static str, PathBuf)>, String> {
    eprintln!("[y] runtime: ryo_rt{}", cross.map(|t| format!(" for {t}")).unwrap_or_default());
    let mut sysroot_flag = String::from("--sysroot=");
    sysroot_flag.push_str(dist.to_str().ok_or("dist/ path is not UTF-8")?);
    // `-Cembed-bitcode=yes` (after cargo's `=no`, so it wins): like std, a sysroot rlib must
    // carry bitcode for `-Clto` builds against it.
    let rustflags = [&sysroot_flag, "-Ccodegen-units=1", "-Cpanic=unwind", "-Cembed-bitcode=yes"];
    let mut cargo = cmd("cargo");
    // `registry-anchor`: `vm::enter` references the registry objects the backend generates
    // (design/backend.md#pipeline step 6). `RYO_RT_FEATURES` adds others, such as `fp-rbp`
    // for measurements (design/build.md#test-and-bench).
    let mut features = String::from("registry-anchor");
    if let Some(extra) = std::env::var("RYO_RT_FEATURES").ok().filter(|f| !f.is_empty()) {
        features.push(',');
        features.push_str(&extra);
    }
    cargo.args(["build", "--release", "-p", "ryo_rt", "--features", &features]);
    if let Some(t) = cross {
        cargo.args(["--target", t]);
    }
    let out = output(
        cargo
            .arg("--message-format=json-render-diagnostics")
            .arg("--manifest-path")
            .arg(root.join("vm").join("Cargo.toml"))
            .arg("--target-dir")
            .arg(target.join("vm"))
            // Independent of the user's profile settings and RUSTFLAGS.
            .env("CARGO_PROFILE_RELEASE_OPT_LEVEL", "3")
            .env("CARGO_PROFILE_RELEASE_CODEGEN_UNITS", "1")
            .env("CARGO_PROFILE_RELEASE_PANIC", "unwind")
            .env_remove("RUSTFLAGS")
            .env("CARGO_ENCODED_RUSTFLAGS", rustflags.join("\x1f")),
    )?;
    let rlibs = artifact_rlibs(&out);
    ["ryo_rt", "ryo_bytecode"]
        .into_iter()
        .map(|krate| match rlibs.iter().find(|p| rlib_crate(p) == Some(krate)) {
            Some(rlib) => Ok((krate, rlib.clone())),
            None => Err(format!("cargo did not report an rlib for {krate}")),
        })
        .collect()
}

/// The `.rlib` paths in the `compiler-artifact` messages of cargo's JSON output. A minimal
/// scan, not a JSON parser (`y` has no dependencies): paths containing `,`, `]` or escaped
/// quotes are not supported.
fn artifact_rlibs(json: &str) -> Vec<PathBuf> {
    let mut rlibs = Vec::new();
    for line in json.lines().filter(|l| l.contains(r#""reason":"compiler-artifact""#)) {
        let Some(start) = line.find(r#""filenames":["#) else { continue };
        let rest = &line[start + r#""filenames":["#.len()..];
        let list = &rest[..rest.find(']').unwrap_or(rest.len())];
        for item in list.split(',') {
            let path = item.trim().trim_matches('"').replace(r"\\", r"\");
            if path.ends_with(".rlib") {
                rlibs.push(PathBuf::from(path));
            }
        }
    }
    rlibs
}

/// `libfoo-<hash>.rlib` or `libfoo.rlib` -> `foo`.
fn rlib_crate(path: &Path) -> Option<&str> {
    let stem = path.file_stem()?.to_str()?.strip_prefix("lib")?;
    Some(stem.split_once('-').map_or(stem, |(name, _)| name))
}

fn build_wrappers(root: &Path, dist_bin: &Path, info: &RustcInfo) -> Result<(), String> {
    for name in ["rustc-ryo", "cargo-ryo"] {
        build_wrapper(root, dist_bin, info, name)?;
    }
    Ok(())
}

/// Compiles `scripts/<name>.rs` into `dist/bin/<name>` with plain rustc.
pub fn build_wrapper(root: &Path, dist_bin: &Path, info: &RustcInfo, name: &str) -> Result<(), String> {
    eprintln!("[y] wrapper: {name}");
    run(cmd("rustc")
        .args(["--edition=2024", "-Copt-level=1", "-o"])
        .arg(dist_bin.join(exe_name(name)))
        .arg(root.join("scripts").join(format!("{name}.rs")))
        .env("RYO_TOOLCHAIN", &info.toolchain)
        .env("RYO_RUSTC_DRIVER", &info.driver)
        .env("RYO_RUSTC_RELEASE", crate::utils::PINNED_VERSION))
}

pub fn copy(from: &Path, to: &Path) -> Result<(), String> {
    fs::copy(from, to).map(drop).map_err(|e| format!("copying {} to {}: {e}", from.display(), to.display()))
}

pub fn copy_dir(from: &Path, to: &Path) -> Result<(), String> {
    fs::create_dir_all(to).map_err(|e| format!("creating {}: {e}", to.display()))?;
    for entry in fs::read_dir(from).map_err(|e| format!("{}: {e}", from.display()))? {
        let entry = entry.map_err(|e| e.to_string())?;
        let dst = to.join(entry.file_name());
        if entry.file_type().map_err(|e| e.to_string())?.is_dir() {
            copy_dir(&entry.path(), &dst)?;
        } else {
            copy(&entry.path(), &dst)?;
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn std_lib_filter() {
        assert!(is_std_lib("libstd-0123abcd.rlib"));
        assert!(is_std_lib("libstd-0123abcd.so"));
        assert!(is_std_lib("librustc_std_workspace_core-01.rlib"));
        assert!(is_std_lib("librustc_demangle-01.rlib"));
        assert!(is_std_lib("librustc_literal_escaper-01.rlib"));
        assert!(!is_std_lib("librustc_driver-01.so"));
        assert!(!is_std_lib("librustc_middle-01.rmeta"));
        assert!(!is_std_lib("libLLVM.so.21.1-rust-1.99.1-stable"));
    }

    #[test]
    fn rlibs_from_cargo_json() {
        let json = concat!(
            r#"{"reason":"compiler-artifact","target":{"name":"ryo_bytecode"},"filenames":["/t/release/deps/libryo_bytecode-ab12.rlib","/t/release/deps/libryo_bytecode-ab12.rmeta"],"fresh":true}"#,
            "\n",
            r#"{"reason":"compiler-artifact","filenames":["C:\\t\\release\\libryo_rt.rlib"]}"#,
            "\n",
            r#"{"reason":"build-finished","success":true}"#,
        );
        let rlibs = artifact_rlibs(json);
        assert_eq!(
            rlibs,
            [PathBuf::from("/t/release/deps/libryo_bytecode-ab12.rlib"), PathBuf::from(r"C:\t\release\libryo_rt.rlib")]
        );
        assert_eq!(rlib_crate(&rlibs[0]), Some("ryo_bytecode"));
        assert_eq!(rlib_crate(Path::new("libryo_rt.rlib")), Some("ryo_rt"));
    }
}
