//! Linux: libgcc's `__register_frame`, which takes a whole `.eh_frame`.

use core::ffi::{c_int, c_void};

use super::Unwind;

pub(crate) const SUPPORTED: bool = true;

unsafe extern "C" {
    fn write(fd: c_int, buf: *const c_void, n: usize) -> isize;
    /// Registers an `.eh_frame` (terminated by a zero word) with the unwinder.
    fn __register_frame(begin: *const u8);
}

pub(super) unsafe fn register(u: &Unwind<'_>) -> bool {
    // SAFETY: the caller's.
    unsafe { __register_frame(u.eh) };
    true
}

/// Writes `b` to stderr, straight to the file descriptor.
pub(crate) fn write_stderr(b: &[u8]) {
    // SAFETY: a write of a live buffer.
    unsafe { write(2, b.as_ptr().cast(), b.len()) };
}

/// Where `perf` looks for the process's JIT symbols.
pub(crate) fn perfmap_path() -> Option<std::string::String> {
    Some(std::format!("/tmp/perf-{}.map", std::process::id()))
}
