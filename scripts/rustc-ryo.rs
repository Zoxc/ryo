//! `rustc-ryo`: runs the pinned rustc with the ryo backend and the `dist/` sysroot.
//!
//! Built by `y build` with plain rustc into `dist/bin/`. `RYO_TOOLCHAIN` is baked in at build
//! time (design/build.md#the-y-build-tool).

#[path = "wrapper_common.rs"]
mod common;

use std::env;
use std::ffi::OsString;
use std::path::{Path, PathBuf};

#[cfg(not(test))]
fn main() {
    common::check_driver("rustc-ryo", "`./y.sh build`");
    let mut passed: Vec<OsString> = env::args_os().skip(1).collect();
    let stats = take_ryo_stats(&mut passed).unwrap_or_else(|msg| common::fail(&msg));
    let verbose_version = is_verbose_version(&passed);
    let checked = env::var_os("RYO_JIT_CHECKED").is_some_and(|v| !v.is_empty() && v != "0");
    let args = ryo_args(&common::dist_dir(), passed, checked).unwrap_or_else(|msg| common::fail(&msg));
    let mut cmd = common::toolchain_command("rustc");
    cmd.args(args);
    if let Some(level) = stats {
        cmd.env("RYO_STATS", level);
    }
    if verbose_version {
        // Cargo fingerprints the compiler by `rustc -vV`; tell it which ryo build this is
        // (design/build.md#the-y-build-tool).
        use std::io::Write;
        let out = cmd.output().unwrap_or_else(|err| common::fail(&format!("failed to run rustc: {err}")));
        let mut stdout = std::io::stdout().lock();
        let _ = stdout.write_all(&out.stdout);
        if out.status.success() {
            // The checked JIT is another `ryo_rt`: cargo rebuilds when it is switched.
            let _ = writeln!(stdout, "ryo-build: {}{}", option_env!("RYO_BUILD_ID").unwrap_or("unknown"), if checked { "+jit-checked" } else { "" });
        }
        let _ = stdout.flush();
        let _ = std::io::stderr().write_all(&out.stderr);
        std::process::exit(out.status.code().unwrap_or(1));
    }
    common::exec(cmd, "rustc")
}

/// The full rustc command line for the user's `passed` arguments. `checked`
/// (`RYO_JIT_CHECKED=1`, design/build.md#build): for the host (no `--target`), link the
/// sysroot's `ryo_rt` with the checked JIT, from its `jit-checked/`.
pub fn ryo_args(dist: &Path, passed: Vec<OsString>, checked: bool) -> Result<Vec<OsString>, String> {
    if passed.is_empty() {
        // Show rustc's help, like plain `rustc` does.
        return Ok(passed);
    }
    let mut passed = normalize(passed);
    if let Some(flag) = randomize_layout_flag(&passed) {
        return Err(format!("`{flag}` is not supported by rustc-ryo: argument block layouts must agree between crates"));
    }
    if passed.last().is_some_and(|a| a == "--sysroot") {
        return Err("`--sysroot` needs a value".to_owned());
    }
    // `--sysroot ryo` selects the std built with ryo (`y build --sysroot ryo`).
    let mut user_sysroot = false;
    for a in &mut passed {
        if a == "--sysroot=ryo" {
            *a = OsString::from("--sysroot=");
            a.push(dist.join("sysroot-ryo"));
        }
        user_sysroot |= opt_value(a, "--sysroot=").is_some();
    }

    let mut rt = OsString::from("force:ryo_rt");
    if checked && !passed.iter().any(|a| opt_value(a, "--target=").is_some()) {
        let sysroot = passed.iter().filter_map(|a| opt_value(a, "--sysroot=")).last().map_or(dist.to_path_buf(), PathBuf::from);
        rt.push("=");
        rt.push(checked_rt(&sysroot)?);
    }

    let mut args: Vec<OsString> = Vec::new();
    if !user_sysroot {
        args.push("--sysroot".into());
        args.push(dist.into());
    }
    args.push(common::backend_arg(dist, "rustc_codegen_ryo"));
    for a in ["-Zunstable-options", "--extern"] {
        args.push(a.into());
    }
    args.push(rt);
    let msvc = targets_msvc(&passed);
    // Any number of codegen units: one image per CGU (design/backend.md#pipeline).
    args.extend(passed);
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

/// Whether `args` only ask for the verbose version (`-vV`, `--version --verbose`, ...), which
/// cargo hashes into its fingerprints and metadata hashes.
pub fn is_verbose_version(args: &[OsString]) -> bool {
    let (mut version, mut verbose) = (false, false);
    for a in args {
        match a.to_str() {
            Some("-vV" | "-Vv") => (version, verbose) = (true, true),
            Some("-V" | "--version") => version = true,
            Some("-v" | "--verbose") => verbose = true,
            _ => return false,
        }
    }
    version && verbose
}

/// The options rustc-ryo looks at whose value may be a separate argument (`--target T`).
const JOINED: [&str; 4] = ["--sysroot", "--target", "--crate-type", "-Z"];

/// `args` with each `JOINED` option and its separate value merged into one argument
/// (`--target=T`, `-ZV`), which rustc accepts as well, so the rest only checks one form.
fn normalize(args: Vec<OsString>) -> Vec<OsString> {
    let mut out: Vec<OsString> = Vec::with_capacity(args.len());
    let mut iter = args.into_iter();
    while let Some(a) = iter.next() {
        match JOINED.iter().find(|&&o| a == o) {
            Some(&o) => {
                let mut joined = OsString::from(if o == "-Z" { o.to_owned() } else { format!("{o}=") });
                match iter.next() {
                    Some(v) => joined.push(v),
                    None => joined = a, // a trailing option without a value: left to rustc
                }
                out.push(joined);
            }
            None => out.push(a),
        }
    }
    out
}

/// The value of a normalized `<prefix>value` argument (`prefix` is e.g. `--target=`).
fn opt_value<'a>(a: &'a OsString, prefix: &str) -> Option<&'a str> {
    a.to_str()?.strip_prefix(prefix)
}

/// A normalized `-Zname[=value]` argument: `name` with `_` as `-`, and the value.
fn z_opt(a: &OsString) -> Option<(String, Option<&str>)> {
    let opt = opt_value(a, "-Z")?;
    let (name, value) = match opt.split_once('=') {
        Some((n, v)) => (n, Some(v)),
        None => (opt, None),
    };
    Some((name.replace('_', "-"), value))
}

/// Removes `-Zryo-stats[=N]` (or `-Z ryo-stats[=N]`) from `args`, which rustc wouldn't
/// accept, and returns the level for the backend's `RYO_STATS` (design/backend.md#debugging-switches).
/// The last one wins; `-Zryo-stats` alone is level 1. Normalizes `args` (`normalize`).
pub fn take_ryo_stats(args: &mut Vec<OsString>) -> Result<Option<String>, String> {
    *args = normalize(std::mem::take(args));
    let mut level = None;
    for a in args.iter() {
        if let Some((name, value)) = z_opt(a)
            && name == "ryo-stats"
        {
            let value = value.unwrap_or("1");
            if value.parse::<u32>().is_err() {
                return Err(format!("`-Zryo-stats={value}`: expected a number"));
            }
            level = Some(value.to_owned());
        }
    }
    args.retain(|a| !z_opt(a).is_some_and(|(n, _)| n == "ryo-stats"));
    Ok(level)
}

/// The `ryo_rt` rlib with the checked JIT in `sysroot`'s `jit-checked/`.
fn checked_rt(sysroot: &Path) -> Result<PathBuf, String> {
    let dir = sysroot.join("jit-checked");
    let found =
        std::fs::read_dir(&dir).ok().into_iter().flatten().flatten().map(|e| e.path()).find(|p| {
            p.extension().is_some_and(|e| e == "rlib") && p.file_name().and_then(|n| n.to_str()).is_some_and(|n| n.starts_with("libryo_rt"))
        });
    found.ok_or_else(|| format!("RYO_JIT_CHECKED: no ryo_rt rlib in {}; run `./y.sh build`", dir.display()))
}

/// Whether the compilation targets windows-msvc: the last `--target=` of the normalized
/// `args` names an `-msvc` triple, or there is none and the host is one.
fn targets_msvc(args: &[OsString]) -> bool {
    match args.iter().filter_map(|a| opt_value(a, "--target=")).last() {
        Some(t) => t.ends_with("-msvc"),
        None => cfg!(target_env = "msvc"),
    }
}

/// Finds an enabling `-Zrandomize-layout[=v]` among the normalized `args`.
fn randomize_layout_flag(args: &[OsString]) -> Option<String> {
    args.iter().find_map(|a| match z_opt(a)? {
        (n, v) if n == "randomize-layout" && !matches!(v, Some("no" | "n" | "off" | "false")) => a.to_str().map(str::to_owned),
        _ => None,
    })
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
        let got = ryo_args(dist, args(&["foo.rs", "-Ccodegen-units=16"]), false).unwrap();
        // `join`, so the separator is right on Windows too.
        let backend = dist.join("lib").join(crate::utils::dll_name("rustc_codegen_ryo"));
        let backend = format!("-Zcodegen-backend={}", backend.display());
        let mut want = args(&["--sysroot", "/d", &backend, "-Zunstable-options", "--extern", "force:ryo_rt", "foo.rs", "-Ccodegen-units=16"]);
        if cfg!(target_env = "msvc") {
            want.extend(args(&["-Clink-arg=/IGNORE:4217", "-Clink-arg=/IGNORE:4286"]));
        }
        assert_eq!(got, want);
    }

    #[test]
    fn silences_import_warnings_on_msvc() {
        let ignore = |list: &[&str]| {
            let got = ryo_args(Path::new("/d"), args(list), false).unwrap();
            got.iter().any(|a| a == "-Clink-arg=/IGNORE:4217")
        };
        assert!(ignore(&["x.rs", "--target", "x86_64-pc-windows-msvc"]));
        assert!(ignore(&["x.rs", "--target=x86_64-pc-windows-msvc"]));
        assert!(!ignore(&["x.rs", "--target", "x86_64-unknown-linux-gnu"]));
        assert_eq!(ignore(&["x.rs"]), cfg!(target_env = "msvc"));
    }

    #[test]
    fn keeps_user_sysroot_and_empty_args() {
        let got = ryo_args(Path::new("/d"), args(&["--sysroot=/s", "x.rs"]), false).unwrap();
        assert!(!got.iter().any(|a| a == "/d"));
        assert!(ryo_args(Path::new("/d"), vec![], false).unwrap().is_empty());
    }

    #[test]
    fn ryo_stats_flag() {
        let mut a = args(&["x.rs", "-Zryo-stats", "-Z", "threads=2"]);
        assert_eq!(take_ryo_stats(&mut a), Ok(Some("1".into())));
        assert_eq!(a, args(&["x.rs", "-Zthreads=2"]));
        let mut a = args(&["-Z", "ryo-stats=2", "x.rs"]);
        assert_eq!(take_ryo_stats(&mut a), Ok(Some("2".into())));
        assert_eq!(a, args(&["x.rs"]));
        let mut a = args(&["x.rs"]);
        assert_eq!(take_ryo_stats(&mut a), Ok(None));
        assert!(take_ryo_stats(&mut args(&["-Zryo-stats=x"])).is_err());
    }

    #[test]
    fn ryo_sysroot() {
        let want = format!("--sysroot={}", Path::new("/d").join("sysroot-ryo").display());
        for list in [&["x.rs", "--sysroot", "ryo"][..], &["x.rs", "--sysroot=ryo"]] {
            let got = ryo_args(Path::new("/d"), args(list), false).unwrap();
            assert!(got.iter().any(|a| a.to_str() == Some(want.as_str())), "{got:?}");
            assert!(!got.iter().any(|a| a == "/d"));
        }
        let got = ryo_args(Path::new("/d"), args(&["x.rs", "--sysroot", "/s"]), false).unwrap();
        assert!(got.iter().any(|a| a == "--sysroot=/s"));
        assert!(ryo_args(Path::new("/d"), args(&["x.rs", "--sysroot"]), false).is_err());
    }

    #[test]
    fn verbose_version() {
        for yes in [&["-vV"][..], &["-V", "-v"], &["--version", "--verbose"], &["-Vv"]] {
            assert!(is_verbose_version(&args(yes)), "{yes:?}");
        }
        for no in [&["-V"][..], &["--version"], &[], &["-vV", "x.rs"], &["-v"]] {
            assert!(!is_verbose_version(&args(no)), "{no:?}");
        }
    }

    #[test]
    fn rejects_randomize_layout() {
        for bad in [&["-Zrandomize-layout"][..], &["-Z", "randomize-layout"], &["-Zrandomize_layout=yes"]] {
            assert!(ryo_args(Path::new("/d"), args(bad), false).is_err(), "{bad:?}");
        }
        for ok in [&["-Zrandomize-layout=no"][..], &["-Z", "mir-opt-level=1"], &["randomize-layout"]] {
            assert!(ryo_args(Path::new("/d"), args(ok), false).is_ok(), "{ok:?}");
        }
    }
}
