//! What the `dist/bin/` wrappers (`rustc-ryo`, `rustc-clif`, `cargo-ryo`) and the installed
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

/// Where a sysroot (`dist/`, `dist/sysroot-ryo/`) keeps its host `ryo_rt` with the checked JIT,
/// which `y build` installs and `rustc-ryo` links under [`JIT_CHECKED_VAR`].
pub const JIT_CHECKED_DIR: &str = "jit-checked";

/// Whether a value of [`JIT_CHECKED_VAR`] asks for the checked JIT: set, non-empty, not `0`.
pub fn jit_checked_value(v: &std::ffi::OsStr) -> bool {
    !v.is_empty() && v != "0"
}

/// Whether [`JIT_CHECKED_VAR`] asks for the checked JIT.
pub fn jit_checked() -> bool {
    env::var_os(JIT_CHECKED_VAR).is_some_and(|v| jit_checked_value(&v))
}

/// The directory of this executable (`dist/bin/`).
pub fn bin_dir() -> PathBuf {
    let exe = real_path(env::current_exe().expect("current_exe"));
    exe.parent().expect("exe has a parent").to_path_buf()
}

/// `dist/`, found from the location of this executable (`dist/bin/<wrapper>`).
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
