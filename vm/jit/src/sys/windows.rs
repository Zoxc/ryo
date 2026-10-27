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

const STD_ERROR_HANDLE: u32 = -12i32 as u32;

#[link(name = "kernel32", kind = "raw-dylib")]
unsafe extern "system" {
    /// Adds `count` `RUNTIME_FUNCTION`s at `table`, whose addresses are offsets from `base`,
    /// to the process's dynamic function tables (kernel32 forwards it to ntdll).
    fn RtlAddFunctionTable(table: *const c_void, count: u32, base: u64) -> u8;
    fn GetStdHandle(which: u32) -> *mut c_void;
    fn WriteFile(h: *mut c_void, buf: *const u8, n: u32, written: *mut u32, ov: *mut c_void) -> i32;
}

pub(super) unsafe fn register(u: &Unwind<'_>) -> bool {
    let (table, count) = u.pdata;
    if table.is_null() || count == 0 {
        return false;
    }
    // SAFETY: the caller's: the table and its unwind info live forever, above `code.0`.
    unsafe { RtlAddFunctionTable(table.cast(), count, u.code.0 as u64) != 0 }
}

/// Writes `b` to stderr.
pub(crate) fn write_stderr(b: &[u8]) {
    // SAFETY: a write of a live buffer; a null or invalid handle makes it fail harmlessly.
    unsafe {
        let mut n = 0;
        WriteFile(GetStdHandle(STD_ERROR_HANDLE), b.as_ptr(), b.len().min(u32::MAX as usize) as u32, &mut n, core::ptr::null_mut());
    }
}

/// Where `perf` looks for the process's JIT symbols: nowhere (there is no perf map on
/// Windows; `RYO_JIT_PERFMAP` does nothing).
pub(crate) fn perfmap_path() -> Option<std::string::String> {
    None
}
