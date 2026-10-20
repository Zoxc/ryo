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
    // The backend links against this exact `rustc_driver`. If the toolchain was updated after
    // `y build` (e.g. `rustup update` moved `stable`), it is gone and loading would fail.
    if let Some(driver) = option_env!("RYO_RUSTC_DRIVER") {
        if !Path::new(driver).exists() {
            eprintln!(
                "error: rustc-ryo was built for rustc {}, but the toolchain `{}` has changed \
                 ({driver} is gone); install rustc {0} as that toolchain and rerun `./y.sh build`",
                option_env!("RYO_RUSTC_RELEASE").unwrap_or("?"),
                option_env!("RYO_TOOLCHAIN").unwrap_or("?"),
            );
            std::process::exit(1);
        }
    }
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
    let exe = real_path(exe);
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
    for a in ["-Zunstable-options", "--extern", "force:ryo_rt"] {
        args.push(a.into());
    }
    let msvc = targets_msvc(&passed);
    args.extend(passed);
    // After the user's arguments, so it wins (design/backend.md#pipeline).
    args.push("-Ccodegen-units=1".into());
    if msvc {
        // Image symbol slots of upstream symbols relocate against `__imp_<sym>` even when the
        // definition is linked statically; link.exe and lld-link then resolve it locally and
        // warn (LNK4217, LNK4286). That is intended (design/platforms.md).
        for a in ["-Clink-arg=/IGNORE:4217", "-Clink-arg=/IGNORE:4286"] {
            args.push(a.into());
        }
    }
    Ok(args)
}

/// Whether the compilation targets windows-msvc: `--target` names an `-msvc` triple, or there
/// is none and the host is one.
fn targets_msvc(args: &[OsString]) -> bool {
    let mut target = None;
    let mut prev_target = false;
    for arg in args {
        let s = arg.to_str().unwrap_or("");
        if prev_target {
            target = Some(s);
        } else if let Some(t) = s.strip_prefix("--target=") {
            target = Some(t);
        }
        prev_target = s == "--target";
    }
    match target {
        Some(t) => t.ends_with("-msvc"),
        None => cfg!(target_env = "msvc"),
    }
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

    fn args(list: &[&str]) -> Vec<OsString> {
        list.iter().map(OsString::from).collect()
    }

    #[test]
    fn adds_ryo_flags_around_user_args() {
        let dist = Path::new("/d");
        let got = ryo_args(dist, args(&["foo.rs", "-Ccodegen-units=16"])).unwrap();
        // `join`, so the separator is right on Windows too.
        let backend = dist.join("lib").join(crate::utils::dll_name("rustc_codegen_ryo"));
        let backend = format!("-Zcodegen-backend={}", backend.display());
        let mut want = args(&[
            "--sysroot", "/d", &backend, "-Zunstable-options", "--extern", "force:ryo_rt",
            "foo.rs", "-Ccodegen-units=16",
            "-Ccodegen-units=1",
        ]);
        if cfg!(target_env = "msvc") {
            want.extend(args(&["-Clink-arg=/IGNORE:4217", "-Clink-arg=/IGNORE:4286"]));
        }
        assert_eq!(got, want);
    }

    #[test]
    fn silences_import_warnings_on_msvc() {
        let ignore = |list: &[&str]| {
            let got = ryo_args(Path::new("/d"), args(list)).unwrap();
            got.iter().any(|a| a == "-Clink-arg=/IGNORE:4217")
        };
        assert!(ignore(&["x.rs", "--target", "x86_64-pc-windows-msvc"]));
        assert!(ignore(&["x.rs", "--target=x86_64-pc-windows-msvc"]));
        assert!(!ignore(&["x.rs", "--target", "x86_64-unknown-linux-gnu"]));
        assert_eq!(ignore(&["x.rs"]), cfg!(target_env = "msvc"));
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
