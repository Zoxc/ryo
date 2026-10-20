//! Panic glue between islands, the VM and native code. See design/stubs.md (Unwinding) and
//! design/vm.md (Unwinding).
//!
//! Only `catch_unwind`/`resume_unwind` touch the payload box; nothing here enters the VM.

use std::any::Any;
use std::panic::{AssertUnwindSafe, catch_unwind, resume_unwind};

/// An opaque `Box<dyn Any + Send>` panic payload: the box's raw wide pointer, stored as is
/// (the wide-pointer layout is not relied on).
#[repr(transparent)]
#[derive(Debug, Clone, Copy)]
pub struct RawPayload(pub *mut (dyn Any + Send));

impl RawPayload {
    /// No payload: a null data pointer (with `()`'s vtable).
    pub const NONE: RawPayload = RawPayload(core::ptr::null_mut::<()>() as *mut (dyn Any + Send));

    /// Whether this is [`RawPayload::NONE`] (a null data pointer).
    pub fn is_none(self) -> bool {
        self.0.is_null()
    }
}

/// The outcome of [`call_catching`].
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct CatchResult {
    /// The island's successor index. 0 when `unwinding` is set.
    pub succ: u32,
    /// The island panicked, and the payload was stored in `*payload_out`.
    pub unwinding: bool,
}

/// Runs the island `f(fp, ops)` inside `catch_unwind`.
///
/// On a panic, the payload is written to `*payload_out` (the VM passes the current entry
/// record's payload slot) and `unwinding` is set. The previous value of `*payload_out` is
/// overwritten without being dropped, so it must be [`RawPayload::NONE`]. On success,
/// `*payload_out` is not touched.
///
/// # Safety
/// `f` must be safe to call with `fp`/`ops`, and `payload_out` must be valid for writes.
#[inline(never)]
pub unsafe fn call_catching(
    f: unsafe fn(*mut u8, *const u32) -> u32,
    fp: *mut u8,
    ops: *const u32,
    payload_out: *mut RawPayload,
) -> CatchResult {
    match catch_unwind(AssertUnwindSafe(|| unsafe { f(fp, ops) })) {
        Ok(succ) => CatchResult { succ, unwinding: false },
        Err(payload) => {
            unsafe { payload_out.write(RawPayload(Box::into_raw(payload))) };
            CatchResult { succ: 0, unwinding: true }
        }
    }
}

/// Re-raises a payload caught by [`call_catching`] natively. Called by portals after
/// `vm::enter` has popped its entry record.
///
/// # Safety
/// `payload` must have been produced by [`call_catching`], and is consumed.
#[inline(never)]
pub unsafe fn resume_unwind_from_vm(payload: RawPayload) -> ! {
    debug_assert!(!payload.is_none());
    // SAFETY: the pointer came from `Box::into_raw` in `call_catching`.
    resume_unwind(unsafe { Box::from_raw(payload.0) })
}
