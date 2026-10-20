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
    let exe = exe.canonicalize().unwrap_or(exe);
    let bin = exe.parent().expect("exe has a parent");
    let rustc_ryo = bin.join(format!("rustc-ryo{}", env::consts::EXE_SUFFIX));

    let mut cmd = Command::new("cargo");
    cmd.args(env::args_os().skip(1)).env("RUSTC", rustc_ryo).env("RUSTC_BOOTSTRAP", "1");
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
