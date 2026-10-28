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
    // Cargo gives a path package's executables on msvc, and its dylibs and cdylibs everywhere,
    // no metadata hash, so their directories (fingerprints, outputs) don't tell compilers apart:
    // `cargo build` and `cargo ryo build` would rebuild each other's. This variable (std's
    // build sets it too) gives them one, seeded with its value (design/build.md).
    if env::var_os("__CARGO_DEFAULT_LIB_METADATA").is_none() {
        cmd.env("__CARGO_DEFAULT_LIB_METADATA", "ryo");
    }
    common::exec(cmd, "cargo")
}
