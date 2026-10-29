//! Linux: libgcc's `__register_frame`, which takes a whole `.eh_frame`.

use super::Unwind;

pub(crate) const SUPPORTED: bool = true;

unsafe extern "C" {
    /// Registers an `.eh_frame` (terminated by a zero word) with the unwinder.
    fn __register_frame(begin: *const u8);
}

pub(super) unsafe fn register(u: &Unwind<'_>) -> bool {
    let Unwind::Eh { eh, .. } = *u else { return false };
    // SAFETY: the caller's.
    unsafe { __register_frame(eh) };
    true
}
