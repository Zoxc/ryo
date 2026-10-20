//! `rustc-ryo`: runs the pinned rustc with the ryo backend and the `dist/` sysroot.
//!
//! Built by `y build` with plain rustc into `dist/bin/`. `RYO_TOOLCHAIN` is baked in at build
//! time (design/build.md#the-y-build-tool).

use std::env;
use std::ffi::OsString;
#[cfg(unix)]
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::Command;

#[allow(dead_code)]
fn main() {
    let sysroot = dist_dir();
    let passed: Vec<OsString> = env::args_os().skip(1).collect();
    let args = match ryo_args(&sysroot, passed) {
        Ok(args) => args,
        Err(msg) => {
            eprintln!("error: {msg}");
            std::process::exit(1);
        }
    };

    let mut cmd = Command::new("rustc");
    cmd.args(args).env("RUSTC_BOOTSTRAP", "1");
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

/// `dist/`, found from the location of this executable (`dist/bin/rustc-ryo`).
#[allow(dead_code)]
fn dist_dir() -> PathBuf {
    let exe = env::current_exe().expect("current_exe");
    let exe = exe.canonicalize().unwrap_or(exe);
    let mut dir = exe.parent().expect("exe has a parent").to_path_buf();
    if dir.file_name().is_some_and(|n| n == "bin") {
        dir.pop();
    }
    dir
}

/// The full rustc command line for the user's `passed` arguments.
pub fn ryo_args(dist: &Path, passed: Vec<OsString>) -> Result<Vec<OsString>, String> {
    if passed.is_empty() {
        // Show rustc's help, like plain `rustc` does.
        return Ok(passed);
    }
    if let Some(flag) = randomize_layout_flag(&passed) {
        return Err(format!(
            "`{flag}` is not supported by rustc-ryo: argument block layouts must agree between crates"
        ));
    }

    let mut backend = OsString::from("-Zcodegen-backend=");
    backend.push(dist.join("lib").join(format!(
        "{}rustc_codegen_ryo{}",
        env::consts::DLL_PREFIX,
        env::consts::DLL_SUFFIX
    )));

    let mut args: Vec<OsString> = Vec::new();
    let user_sysroot = passed
        .iter()
        .any(|a| a == "--sysroot" || a.to_str().is_some_and(|s| s.starts_with("--sysroot=")));
    if !user_sysroot {
        args.push("--sysroot".into());
        args.push(dist.into());
    }
    args.push(backend);
    for a in ["-Zunstable-options", "--extern", "force:ryo_rt", "-Zmir-opt-level=2", "-Zinline-mir=yes"] {
        args.push(a.into());
    }
    args.extend(passed);
    // After the user's arguments, so it wins (design/backend.md#pipeline).
    args.push("-Ccodegen-units=1".into());
    Ok(args)
}

/// Finds an enabling `-Zrandomize-layout` (`-Zrandomize-layout[=v]` or `-Z randomize-layout[=v]`).
fn randomize_layout_flag(args: &[OsString]) -> Option<String> {
    let mut prev_z = false;
    for arg in args {
        let Some(s) = arg.to_str() else {
            prev_z = false;
            continue;
        };
        let opt = if prev_z { Some(s) } else { s.strip_prefix("-Z") };
        prev_z = s == "-Z";
        let Some(opt) = opt else { continue };
        let (name, value) = match opt.split_once('=') {
            Some((n, v)) => (n, Some(v)),
            None => (opt, None),
        };
        if name.replace('_', "-") == "randomize-layout"
            && !matches!(value, Some("no" | "n" | "off" | "false"))
        {
            return Some(format!("-Z{opt}"));
        }
    }
    None
}

// Run by `cargo test` in `build/`, which includes this file as a module.
#[cfg(test)]
mod tests {
    use super::*;

    fn args(list: &[&str]) -> Vec<OsString> {
        list.iter().map(OsString::from).collect()
    }

    #[test]
    fn adds_ryo_flags_around_user_args() {
        let dist = Path::new("/d");
        let got = ryo_args(dist, args(&["foo.rs", "-Ccodegen-units=16"])).unwrap();
        let backend = format!("-Zcodegen-backend=/d/lib/{}", crate::utils::dll_name("rustc_codegen_ryo"));
        let want = args(&[
            "--sysroot", "/d", &backend, "-Zunstable-options", "--extern", "force:ryo_rt",
            "-Zmir-opt-level=2", "-Zinline-mir=yes", "foo.rs", "-Ccodegen-units=16",
            "-Ccodegen-units=1",
        ]);
        assert_eq!(got, want);
    }

    #[test]
    fn keeps_user_sysroot_and_empty_args() {
        let got = ryo_args(Path::new("/d"), args(&["--sysroot=/s", "x.rs"])).unwrap();
        assert!(!got.iter().any(|a| a == "/d"));
        assert!(ryo_args(Path::new("/d"), vec![]).unwrap().is_empty());
    }

    #[test]
    fn rejects_randomize_layout() {
        for bad in [&["-Zrandomize-layout"][..], &["-Z", "randomize-layout"], &["-Zrandomize_layout=yes"]] {
            assert!(ryo_args(Path::new("/d"), args(bad)).is_err(), "{bad:?}");
        }
        for ok in [&["-Zrandomize-layout=no"][..], &["-Z", "mir-opt-level=1"], &["randomize-layout"]] {
            assert!(ryo_args(Path::new("/d"), args(ok)).is_ok(), "{ok:?}");
        }
    }
}
