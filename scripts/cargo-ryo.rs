//! `cargo-ryo`: runs the pinned cargo with `RUSTC=rustc-ryo`.
//!
//! Built by `y build` with plain rustc into `dist/bin/`. `RYO_TOOLCHAIN` is baked in at build
//! time (design/build.md#the-y-build-tool).

#[path = "wrapper_common.rs"]
mod common;

use std::env;

fn main() {
    let rustc_ryo = common::bin_dir().join(format!("rustc-ryo{}", env::consts::EXE_SUFFIX));

    // Run as `cargo ryo build`, cargo calls `cargo-ryo ryo build`: drop the `ryo`, or cargo
    // would run `cargo ryo build` again, forever.
    let mut args = env::args_os().skip(1).peekable();
    if args.peek().is_some_and(|a| a == "ryo") {
        args.next();
    }
    let mut cmd = common::toolchain_command("cargo");
    cmd.args(args).env("RUSTC", rustc_ryo);
    common::exec(cmd, "cargo")
}
