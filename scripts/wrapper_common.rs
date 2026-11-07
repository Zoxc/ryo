//! What the `out/dist/bin/` wrappers (`rustc-ryo`, `rustc-clif`, `cargo-ryo`) and the installed
//! launchers (`launcher.rs`) share; each pulls it in with `#[path = "wrapper_common.rs"] mod
//! common;`. Values baked in by `y build`:
//! `RYO_TOOLCHAIN`, `RYO_RUSTC_DRIVER`, `RYO_RUSTC_RELEASE` (design/build.md#the-y-build-tool).

// Each wrapper uses only some of it.
#![allow(dead_code)]

use std::env;
use std::ffi::OsString;
#[cfg(unix)]
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::Command;

/// The variable that makes `rustc-ryo` link the checked JIT (design/build.md#build); `y test`
/// sets it unless the caller did.
pub const JIT_CHECKED_VAR: &str = "RYO_JIT_CHECKED";

/// The variable that picks `rustc-ryo`'s sysroot when its command line doesn't: `ryo` or `llvm`.
pub const SYSROOT_VAR: &str = "RYO_SYSROOT";

/// The file in `out/dist/` that makes its ryo sysroot (`sysroot-ryo/`) `rustc-ryo`'s default:
/// `y build` writes it once that sysroot is current, and any build without it removes it.
pub const DEFAULT_SYSROOT_FILE: &str = "sysroot-default";

/// Where a sysroot (`out/dist/`, `out/dist/sysroot-ryo/`) keeps its host `ryo_rt` with the checked JIT,
/// which `y build` installs and `rustc-ryo` links under [`JIT_CHECKED_VAR`].
pub const JIT_CHECKED_DIR: &str = "jit-checked";

/// The installed ryo `<version>` in a checkout's `install/` (`y install`, design/install.md): the
/// contents of `install/current`, if it names a directory there.
pub fn current_version(install: &Path) -> Option<String> {
    let v = std::fs::read_to_string(install.join("current")).ok()?;
    let v = v.trim();
    (!v.is_empty() && install.join(v).is_dir()).then(|| v.to_owned())
}

/// Whether a value of [`JIT_CHECKED_VAR`] asks for the checked JIT: set, non-empty, not `0`.
pub fn jit_checked_value(v: &std::ffi::OsStr) -> bool {
    !v.is_empty() && v != "0"
}

/// Whether [`JIT_CHECKED_VAR`] asks for the checked JIT.
pub fn jit_checked() -> bool {
    env::var_os(JIT_CHECKED_VAR).is_some_and(|v| jit_checked_value(&v))
}

/// The directory of this executable (`out/dist/bin/`).
pub fn bin_dir() -> PathBuf {
    let exe = real_path(env::current_exe().expect("current_exe"));
    exe.parent().expect("exe has a parent").to_path_buf()
}

/// `out/dist/`, found from the location of this executable (`out/dist/bin/<wrapper>`).
pub fn dist_dir() -> PathBuf {
    let mut dir = bin_dir();
    if dir.file_name().is_some_and(|n| n == "bin") {
        dir.pop();
    }
    dir
}

/// Exits if the `rustc_driver` the codegen backend links against is gone: the toolchain was
/// updated after `y build` (e.g. `rustup update` moved `stable`), so loading would fail.
/// `rebuild` is what to rerun.
pub fn check_driver(tool: &str, rebuild: &str) {
    if let Some(driver) = option_env!("RYO_RUSTC_DRIVER")
        && !Path::new(driver).exists()
    {
        eprintln!(
            "error: {tool} was built for rustc {}, but the toolchain `{}` has changed \
             ({driver} is gone); install rustc {0} as that toolchain and rerun {rebuild}",
            option_env!("RYO_RUSTC_RELEASE").unwrap_or("?"),
            option_env!("RYO_TOOLCHAIN").unwrap_or("?"),
        );
        std::process::exit(1);
    }
}

/// `program` (`rustc`, `cargo`) of the pinned toolchain, with `RUSTC_BOOTSTRAP=1`.
pub fn toolchain_command(program: &str) -> Command {
    let mut cmd = Command::new(program);
    cmd.env("RUSTC_BOOTSTRAP", "1");
    if let Some(toolchain) = option_env!("RYO_TOOLCHAIN") {
        cmd.env("RUSTUP_TOOLCHAIN", toolchain);
    }
    cmd
}

/// Runs `cmd` in place of this process (on Unix; elsewhere waits and exits with its code).
pub fn exec(mut cmd: Command, what: &str) -> ! {
    #[cfg(unix)]
    let err = cmd.exec();
    #[cfg(not(unix))]
    let err = match cmd.status() {
        Ok(status) => std::process::exit(status.code().unwrap_or(1)),
        Err(err) => err,
    };
    eprintln!("error: failed to run {what}: {err}");
    std::process::exit(1);
}

/// `args` with each `@path` argument replaced by the lines of `path`, as rustc expands them (not
/// recursively; `@shell:path`, which needs `-Zshell-argfiles`, is left to rustc), so a wrapper
/// sees the options in an argfile (cargo uses one when a command line is too long). Also returns
/// whether there was one.
pub fn expand_argfiles(args: Vec<OsString>) -> Result<(Vec<OsString>, bool), String> {
    let mut out = Vec::with_capacity(args.len());
    let mut any = false;
    for a in args {
        match a.to_str().and_then(|s| s.strip_prefix('@')).filter(|p| !p.starts_with("shell:")) {
            Some(path) => {
                let content = std::fs::read_to_string(path).map_err(|err| format!("failed to load argument file {path}: {err}"))?;
                out.extend(content.lines().map(OsString::from));
                any = true;
            }
            None => out.push(a),
        }
    }
    Ok((out, any))
}

/// Runs `cmd` (rustc) with `args` in place of this process, like [`exec`]. With `argfile` (the
/// user's arguments came in one, [`expand_argfiles`]), passes them in a new argfile instead, so
/// the command line stays as short, and removes it once rustc has exited.
pub fn exec_with_args(mut cmd: Command, args: Vec<OsString>, argfile: bool, what: &str) -> ! {
    if !argfile {
        cmd.args(args);
        exec(cmd, what);
    }
    let mut content = String::new();
    for a in &args {
        match a.to_str() {
            Some(s) if !s.contains('\n') => {
                content.push_str(s);
                content.push('\n');
            }
            _ => fail(&format!("argument {a:?} can't be passed in an argfile")),
        }
    }
    let file = env::temp_dir().join(format!("ryo-args-{}", std::process::id()));
    if let Err(err) = std::fs::write(&file, content) {
        fail(&format!("writing {}: {err}", file.display()));
    }
    let mut at = OsString::from("@");
    at.push(&file);
    let status = cmd.arg(at).status();
    let _ = std::fs::remove_file(&file);
    match status {
        Ok(status) => std::process::exit(status.code().unwrap_or(1)),
        Err(err) => fail(&format!("failed to run {what}: {err}")),
    }
}

/// Prints `error: <msg>` and exits.
pub fn fail(msg: &str) -> ! {
    eprintln!("error: {msg}");
    std::process::exit(1);
}

/// `-Zcodegen-backend=<dist>/lib/<dylib of crate_name>`.
pub fn backend_arg(dist: &Path, crate_name: &str) -> OsString {
    let mut arg = OsString::from("-Zcodegen-backend=");
    arg.push(dist.join("lib").join(format!("{}{crate_name}{}", env::consts::DLL_PREFIX, env::consts::DLL_SUFFIX)));
    arg
}

/// The arguments a wrapper puts before the user's: `--sysroot <dist>` unless the user gave a
/// sysroot, and the backend `crate_name` in `dist`.
pub fn base_args(dist: &Path, crate_name: &str, user_sysroot: bool) -> Vec<OsString> {
    let mut args: Vec<OsString> = Vec::new();
    if !user_sysroot {
        args.push("--sysroot".into());
        args.push(dist.into());
    }
    args.push(backend_arg(dist, crate_name));
    args
}

/// `p` canonicalized, without the `\\?\` prefix `canonicalize` adds on Windows, which some
/// tools don't accept in paths derived from it (`--sysroot`, linker search paths).
pub fn real_path(p: PathBuf) -> PathBuf {
    let c = p.canonicalize().unwrap_or(p);
    #[cfg(windows)]
    if let Some(rest) = c.to_str().and_then(|s| s.strip_prefix(r"\\?\"))
        && !rest.starts_with(r"UNC\")
    {
        return rest.into();
    }
    c
}
