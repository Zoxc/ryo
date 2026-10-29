//! Windows: `RtlAddFunctionTable` per function, with the `RUNTIME_FUNCTION` and
//! `UNWIND_INFO` the installer put in the region's read-write end (design/jit.md, "Unwinding
//! and profiling"). The table is never deleted: code is never freed. This file's imports are
//! `raw-dylib`; `ryo_bytecode`'s `vmem` links `kernel32` as usual, which the program's link
//! provides (std imports from it too).
//!
//! Untested on Windows itself: only built and link-checked from Linux.

use core::ffi::c_void;

use super::Unwind;

pub(crate) const SUPPORTED: bool = true;

#[link(name = "kernel32", kind = "raw-dylib")]
unsafe extern "system" {
    /// Adds `count` `RUNTIME_FUNCTION`s at `table`, whose addresses are offsets from `base`,
    /// to the process's dynamic function tables (kernel32 forwards it to ntdll).
    fn RtlAddFunctionTable(table: *const c_void, count: u32, base: u64) -> u8;
}

pub(super) unsafe fn register(u: &Unwind<'_>) -> bool {
    let Unwind::Pe { base, table, count } = *u else { return false };
    if table.is_null() || count == 0 {
        return false;
    }
    // SAFETY: the caller's: the table and its unwind info live forever, above `base`.
    unsafe { RtlAddFunctionTable(table.cast(), count, base as u64) != 0 }
}
