//! `cargo-ryo`: runs the pinned cargo with `RUSTC=rustc-ryo`.
//!
//! Built by `y build` with plain rustc into `dist/bin/`. `RYO_TOOLCHAIN` is baked in at build
//! time (design/build.md#the-y-build-tool).

use std::env;
#[cfg(unix)]
use std::os::unix::process::CommandExt;
use std::process::Command;

fn main() {
    let exe = env::current_exe().expect("current_exe");
    let exe = real_path(exe);
    let bin = exe.parent().expect("exe has a parent");
    let rustc_ryo = bin.join(format!("rustc-ryo{}", env::consts::EXE_SUFFIX));

    // Run as `cargo ryo build`, cargo calls `cargo-ryo ryo build`: drop the `ryo`, or cargo
    // would run `cargo ryo build` again, forever.
    let mut args = env::args_os().skip(1).peekable();
    if args.peek().is_some_and(|a| a == "ryo") {
        args.next();
    }
    let mut cmd = Command::new("cargo");
    cmd.args(args).env("RUSTC", rustc_ryo).env("RUSTC_BOOTSTRAP", "1");
    if let Some(toolchain) = option_env!("RYO_TOOLCHAIN") {
        cmd.env("RUSTUP_TOOLCHAIN", toolchain);
    }

    #[cfg(unix)]
    {
        let err = cmd.exec();
        eprintln!("error: failed to run cargo: {err}");
        std::process::exit(1);
    }
    #[cfg(not(unix))]
    match cmd.status() {
        Ok(status) => std::process::exit(status.code().unwrap_or(1)),
        Err(err) => {
            eprintln!("error: failed to run cargo: {err}");
            std::process::exit(1);
        }
    }
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
