//! The C `main` of binaries whose entry fn is a VM function. See design/stubs.md (Program
//! entry).

use core::ffi::{c_char, c_int};

/// The entry wrapper's template: the backend instantiates it as `c_main::<M, T, SIGPIPE>` (`M`
/// the entry fn's `FnDef` type, `T` its return type, `SIGPIPE` the `on_broken_pipe` setting),
/// names the instance `main` and lowers it as a VM function from a body it builds itself,
/// which calls `lang_start::<T>` with the entry fn (`backend/src/lower/entry.rs`). This item
/// only gives the instance its identity and C signature: its own body is never compiled.
#[rustc_diagnostic_item = "ryo_c_main"]
pub extern "C" fn c_main<M, T, const SIGPIPE: u8>(_argc: c_int, _argv: *const *const c_char) -> c_int {
    core::intrinsics::abort()
}
