//! `rustc-ryo`: runs the pinned rustc with the ryo backend and a sysroot of `out/dist/`: the std
//! built with ryo (`sysroot-ryo/`) where `y build` built one, else the LLVM std (`out/dist/`
//! itself); `--sysroot ryo|llvm` or `RYO_SYSROOT=ryo|llvm` choose (design/build.md#build).
//!
//! Built by `y build` with plain rustc into `out/dist/bin/`. `RYO_TOOLCHAIN` is baked in at build
//! time (design/build.md#the-y-build-tool).

#[path = "wrapper_common.rs"]
mod common;

use std::ffi::OsString;
use std::path::{Path, PathBuf};

#[cfg(not(test))]
fn main() {
    common::check_driver("rustc-ryo", "`./y.sh build`");
    // Options in an `@argfile` count too.
    let (mut passed, argfile) = common::expand_argfiles(std::env::args_os().skip(1).collect()).unwrap_or_else(|msg| common::fail(&msg));
    let stats = take_ryo_stats(&mut passed).unwrap_or_else(|msg| common::fail(&msg));
    let verbose_version = is_verbose_version(&passed);
    let checked = common::jit_checked();
    let dist = common::dist_dir();
    let default = default_sysroot(&dist).unwrap_or_else(|msg| common::fail(&msg));
    let args = ryo_args(&dist, passed, checked, default).unwrap_or_else(|msg| common::fail(&msg));
    let mut cmd = common::toolchain_command("rustc");
    if let Some(level) = stats {
        cmd.env("RYO_STATS", level);
    }
    if verbose_version {
        // Cargo fingerprints the compiler by `rustc -vV`; tell it which ryo build this is
        // (design/build.md#the-y-build-tool).
        use std::io::Write;
        let out = cmd.args(args).output().unwrap_or_else(|err| common::fail(&format!("failed to run rustc: {err}")));
        let mut stdout = std::io::stdout().lock();
        let _ = stdout.write_all(&out.stdout);
        if out.status.success() {
            // The checked JIT is another `ryo_rt`: cargo rebuilds when it is switched.
            let _ = writeln!(stdout, "ryo-build: {}{}", option_env!("RYO_BUILD_ID").unwrap_or("unknown"), if checked { "+jit-checked" } else { "" });
            // The ABI tag (design/build.md#the-abi-tag), set in `y build`'s environment.
            let _ = writeln!(stdout, "ryo-abi: {}", option_env!("RYO_ABI").unwrap_or("unknown"));
            // Switching the default std (`RYO_SYSROOT`, a build with or without it) rebuilds too.
            let _ = writeln!(stdout, "ryo-sysroot: {}", if default.ryo { "ryo" } else { "llvm" });
        }
        let _ = stdout.flush();
        let _ = std::io::stderr().write_all(&out.stderr);
        std::process::exit(out.status.code().unwrap_or(1));
    }
    common::exec_with_args(cmd, args, argfile, "rustc")
}

/// Which sysroot a command line without `--sysroot` gets.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct DefaultSysroot {
    /// `sysroot-ryo/`, for the targets it has (the host); the LLVM std for the others.
    pub ryo: bool,
}

/// [`common::SYSROOT_VAR`] if set, else whether `dist`'s build made its ryo sysroot the default.
pub fn default_sysroot(dist: &Path) -> Result<DefaultSysroot, String> {
    match std::env::var_os(common::SYSROOT_VAR).as_ref().and_then(|v| v.to_str()) {
        None | Some("") => Ok(DefaultSysroot { ryo: dist.join(common::DEFAULT_SYSROOT_FILE).is_file() }),
        Some("ryo") => Ok(DefaultSysroot { ryo: true }),
        Some("llvm") => Ok(DefaultSysroot { ryo: false }),
        Some(other) => Err(format!("{}={other}: expected `ryo` or `llvm`", common::SYSROOT_VAR)),
    }
}

/// The full rustc command line for the user's `passed` arguments. `checked`
/// (`RYO_JIT_CHECKED=1`, design/build.md#build): for the host (no `--target`), link the
/// sysroot's `ryo_rt` with the checked JIT, from its `jit-checked/`. `default`: the sysroot
/// without `--sysroot`; `--sysroot ryo` and `--sysroot llvm` name `dist`'s two.
pub fn ryo_args(dist: &Path, passed: Vec<OsString>, checked: bool, default: DefaultSysroot) -> Result<Vec<OsString>, String> {
    if passed.is_empty() {
        // Show rustc's help, like plain `rustc` does.
        return Ok(passed);
    }
    let mut passed = normalize(passed);
    if passed.last().is_some_and(|a| a == "--sysroot") {
        return Err("`--sysroot` needs a value".to_owned());
    }
    // `--sysroot ryo` selects the std built with ryo (`y build`), `--sysroot llvm` the
    // toolchain's.
    let ryo_sysroot = dist.join("sysroot-ryo");
    let mut user_sysroot = false;
    for a in &mut passed {
        if a == "--sysroot=ryo" {
            *a = OsString::from("--sysroot=");
            a.push(&ryo_sysroot);
        } else if a == "--sysroot=llvm" {
            *a = OsString::from("--sysroot=");
            a.push(dist);
        }
        user_sysroot |= opt_value(a, "--sysroot=").is_some();
    }
    // The ryo sysroot by default, for a target it has std for (only the host: a cross target,
    // or one it was never built for, falls back to the LLVM std).
    if !user_sysroot && default.ryo {
        let target = passed.iter().filter_map(|a| opt_value(a, "--target=")).last();
        let has = match target {
            Some(t) => ryo_sysroot.join("lib").join("rustlib").join(t).join("lib").is_dir(),
            None => ryo_sysroot.is_dir(),
        };
        if has {
            let mut a = OsString::from("--sysroot=");
            a.push(&ryo_sysroot);
            passed.insert(0, a);
            user_sysroot = true;
        }
    }

    let mut rt = OsString::from("force:ryo_rt");
    if checked && !passed.iter().any(|a| opt_value(a, "--target=").is_some()) {
        let sysroot = passed.iter().filter_map(|a| opt_value(a, "--sysroot=")).last().map_or(dist.to_path_buf(), PathBuf::from);
        rt.push("=");
        rt.push(checked_rt(&sysroot)?);
    }

    let mut args = common::base_args(dist, "rustc_codegen_ryo", user_sysroot);
    for a in ["-Zunstable-options", "--extern"] {
        args.push(a.into());
    }
    args.push(rt);
    // Any number of codegen units: one image per CGU (design/backend.md#pipeline).
    args.extend(passed);
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
    let dir = sysroot.join(common::JIT_CHECKED_DIR);
    let found =
        std::fs::read_dir(&dir).ok().into_iter().flatten().flatten().map(|e| e.path()).find(|p| {
            p.extension().is_some_and(|e| e == "rlib") && p.file_name().and_then(|n| n.to_str()).is_some_and(|n| n.starts_with("libryo_rt"))
        });
    found.ok_or_else(|| format!("{}: no ryo_rt rlib in {}; run `./y.sh build`", common::JIT_CHECKED_VAR, dir.display()))
}

// Run by `cargo test` in `build/`, which includes this file as a module.
#[cfg(test)]
mod tests {
    use super::*;

    const LLVM: DefaultSysroot = DefaultSysroot { ryo: false };

    fn args(list: &[&str]) -> Vec<OsString> {
        list.iter().map(OsString::from).collect()
    }

    #[test]
    fn adds_ryo_flags_around_user_args() {
        let dist = Path::new("/d");
        let got = ryo_args(dist, args(&["foo.rs", "-Ccodegen-units=16"]), false, LLVM).unwrap();
        // `join`, so the separator is right on Windows too.
        let backend = dist.join("lib").join(crate::utils::dll_name("rustc_codegen_ryo"));
        let backend = format!("-Zcodegen-backend={}", backend.display());
        let want = args(&["--sysroot", "/d", &backend, "-Zunstable-options", "--extern", "force:ryo_rt", "foo.rs", "-Ccodegen-units=16"]);
        assert_eq!(got, want);
    }

    #[test]
    fn keeps_user_sysroot_and_empty_args() {
        let got = ryo_args(Path::new("/d"), args(&["--sysroot=/s", "x.rs"]), false, LLVM).unwrap();
        assert!(!got.iter().any(|a| a == "/d"));
        assert!(ryo_args(Path::new("/d"), vec![], false, LLVM).unwrap().is_empty());
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
            let got = ryo_args(Path::new("/d"), args(list), false, LLVM).unwrap();
            assert!(got.iter().any(|a| a.to_str() == Some(want.as_str())), "{got:?}");
            assert!(!got.iter().any(|a| a == "/d"));
        }
        let got = ryo_args(Path::new("/d"), args(&["x.rs", "--sysroot", "/s"]), false, LLVM).unwrap();
        assert!(got.iter().any(|a| a == "--sysroot=/s"));
        assert!(ryo_args(Path::new("/d"), args(&["x.rs", "--sysroot"]), false, LLVM).is_err());
        let got = ryo_args(Path::new("/d"), args(&["x.rs", "--sysroot", "llvm"]), false, LLVM).unwrap();
        assert!(got.iter().any(|a| a == "--sysroot=/d"), "{got:?}");
    }

    #[test]
    fn default_ryo_sysroot_falls_back() {
        let dir = std::env::temp_dir().join(format!("ryo-default-sysroot-{}", std::process::id()));
        let host = dir.join("sysroot-ryo").join("lib").join("rustlib").join("h").join("lib");
        std::fs::create_dir_all(&host).unwrap();
        let ryo = DefaultSysroot { ryo: true };
        let want = format!("--sysroot={}", dir.join("sysroot-ryo").display());
        for list in [&["x.rs"][..], &["x.rs", "--target", "h"]] {
            let got = ryo_args(&dir, args(list), false, ryo).unwrap();
            assert!(got.iter().any(|a| a.to_str() == Some(want.as_str())), "{got:?}");
            assert!(!got.iter().any(|a| a == &dir), "{got:?}");
        }
        // No std for `c` in the ryo sysroot: `out/dist/`'s.
        let got = ryo_args(&dir, args(&["x.rs", "--target=c"]), false, ryo).unwrap();
        assert_eq!(got[..2], args(&["--sysroot", dir.to_str().unwrap()])[..]);
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn argfile_options() {
        let file = std::env::temp_dir().join(format!("ryo-argfile-test-{}", std::process::id()));
        std::fs::write(&file, "--sysroot\nllvm\n-Zryo-stats\r\n").unwrap();
        let (mut a, any) = common::expand_argfiles(args(&["x.rs", &format!("@{}", file.display()), "@shell:f"])).unwrap();
        std::fs::remove_file(&file).unwrap();
        assert!(any);
        assert_eq!(take_ryo_stats(&mut a), Ok(Some("1".into())));
        let got = ryo_args(Path::new("/d"), a, false, LLVM).unwrap();
        assert_eq!(got.iter().filter(|a| a.to_str().is_some_and(|s| s.starts_with("--sysroot"))).count(), 1, "{got:?}");
        assert!(got.iter().any(|a| a == "--sysroot=/d") && got.ends_with(&args(&["@shell:f"])), "{got:?}");
        assert_eq!(common::expand_argfiles(args(&["x.rs"])), Ok((args(&["x.rs"]), false)));
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
}
