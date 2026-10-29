//! `rustc-clif`: runs the pinned rustc with cg_clif (built by `y build-clif`) and the `dist/`
//! sysroot, which has the toolchain's prebuilt LLVM std (design/build.md#build-clif).
//!
//! Like `rustc-ryo`, without `force:ryo_rt` and `--sysroot ryo`.

#[path = "wrapper_common.rs"]
mod common;

use std::ffi::OsString;
use std::path::Path;

#[cfg(not(test))]
fn main() {
    // cg_clif links against this exact `rustc_driver`, like the ryo backend.
    common::check_driver("rustc-clif", "`./y.sh build` and `./y.sh build-clif`");
    let dist = common::dist_dir();
    let mut cmd = common::toolchain_command("rustc");
    cmd.args(clif_args(&dist, std::env::args_os().skip(1).collect()));
    common::exec(cmd, "rustc")
}

/// The full rustc command line for the user's `passed` arguments.
pub fn clif_args(dist: &Path, passed: Vec<OsString>) -> Vec<OsString> {
    if passed.is_empty() {
        // Show rustc's help, like plain `rustc` does.
        return passed;
    }
    let user_sysroot = passed.iter().any(|a| a == "--sysroot" || a.to_str().is_some_and(|s| s.starts_with("--sysroot=")));
    let mut args = common::base_args(dist, "rustc_codegen_cranelift", user_sysroot);
    args.extend(passed);
    args
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
