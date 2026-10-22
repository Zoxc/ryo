//! `rustc-clif`: runs the pinned rustc with cg_clif (built by `y build-clif`) and the `dist/`
//! sysroot, which has the toolchain's prebuilt LLVM std (design/build.md#build-clif).
//!
//! Like `rustc-ryo`, without `force:ryo_rt` and the forced `-Ccodegen-units=1`.

use std::env;
use std::ffi::OsString;
#[cfg(unix)]
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::Command;

#[allow(dead_code)]
fn main() {
    // cg_clif links against this exact `rustc_driver`; see `rustc-ryo`.
    if let Some(driver) = option_env!("RYO_RUSTC_DRIVER") {
        if !Path::new(driver).exists() {
            eprintln!(
                "error: rustc-clif was built for rustc {}, but the toolchain `{}` has changed \
                 ({driver} is gone); install rustc {0} as that toolchain and rerun \
                 `./y.sh build` and `./y.sh build-clif`",
                option_env!("RYO_RUSTC_RELEASE").unwrap_or("?"),
                option_env!("RYO_TOOLCHAIN").unwrap_or("?"),
            );
            std::process::exit(1);
        }
    }
    let exe = env::current_exe().expect("current_exe");
    let exe = real_path(exe);
    let mut dist: PathBuf = exe.parent().expect("exe has a parent").to_path_buf();
    if dist.file_name().is_some_and(|n| n == "bin") {
        dist.pop();
    }
    let mut cmd = Command::new("rustc");
    cmd.args(clif_args(&dist, env::args_os().skip(1).collect())).env("RUSTC_BOOTSTRAP", "1");
    if let Some(toolchain) = option_env!("RYO_TOOLCHAIN") {
        cmd.env("RUSTUP_TOOLCHAIN", toolchain);
    }
    #[cfg(unix)]
    {
        let err = cmd.exec();
        eprintln!("error: failed to run rustc: {err}");
        std::process::exit(1);
    }
    #[cfg(not(unix))]
    match cmd.status() {
        Ok(status) => std::process::exit(status.code().unwrap_or(1)),
        Err(err) => {
            eprintln!("error: failed to run rustc: {err}");
            std::process::exit(1);
        }
    }
}

/// The full rustc command line for the user's `passed` arguments.
pub fn clif_args(dist: &Path, passed: Vec<OsString>) -> Vec<OsString> {
    if passed.is_empty() {
        // Show rustc's help, like plain `rustc` does.
        return passed;
    }
    let mut args: Vec<OsString> = Vec::new();
    let user_sysroot = passed.iter().any(|a| a == "--sysroot" || a.to_str().is_some_and(|s| s.starts_with("--sysroot=")));
    if !user_sysroot {
        args.push("--sysroot".into());
        args.push(dist.into());
    }
    let mut backend = OsString::from("-Zcodegen-backend=");
    backend.push(dist.join("lib").join(format!("{}rustc_codegen_cranelift{}", env::consts::DLL_PREFIX, env::consts::DLL_SUFFIX)));
    args.push(backend);
    args.extend(passed);
    args
}

/// `p` canonicalized, without the `\\?\` prefix `canonicalize` adds on Windows, which some
/// tools don't accept in paths derived from it (`--sysroot`, linker search paths).
fn real_path(p: std::path::PathBuf) -> std::path::PathBuf {
    let c = p.canonicalize().unwrap_or(p);
    #[cfg(windows)]
    if let Some(rest) = c.to_str().and_then(|s| s.strip_prefix(r"\\?\"))
        && !rest.starts_with(r"UNC\")
    {
        return rest.into();
    }
    c
}

// Run by `cargo test` in `build/`, which includes this file as a module.
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn adds_backend_and_sysroot() {
        let got = clif_args(Path::new("/d"), vec!["foo.rs".into()]);
        let backend = Path::new("/d").join("lib").join(crate::utils::dll_name("rustc_codegen_cranelift"));
        let backend = format!("-Zcodegen-backend={}", backend.display());
        let want: Vec<OsString> = ["--sysroot", "/d", &backend, "foo.rs"].iter().map(OsString::from).collect();
        assert_eq!(got, want);
        let got = clif_args(Path::new("/d"), vec!["--sysroot=/s".into(), "x.rs".into()]);
        assert!(!got.iter().any(|a| a == "/d"));
        assert!(clif_args(Path::new("/d"), vec![]).is_empty());
    }
}
