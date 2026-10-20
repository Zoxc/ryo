//! Panic glue between islands, the VM and native code. See design/stubs.md (Unwinding) and
//! design/vm.md (Unwinding).
//!
//! Only `catch_unwind`/`resume_unwind` touch the payload box; nothing here enters the VM.

use std::any::Any;
use std::panic::{AssertUnwindSafe, catch_unwind, resume_unwind};

/// An opaque `Box<dyn Any + Send>` panic payload, as its (data, vtable) pointer pair.
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RawPayload {
    pub data: *mut (),
    pub vtable: *mut (),
}

impl RawPayload {
    /// No payload (both pointers null).
    pub const NONE: RawPayload =
        RawPayload { data: core::ptr::null_mut(), vtable: core::ptr::null_mut() };
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
/// overwritten without being dropped, so it must be [`RawPayload::NONE`].
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
            let raw: *mut (dyn Any + Send) = Box::into_raw(payload);
            // SAFETY: a `*mut dyn Trait` is a (data, vtable) pointer pair.
            let raw = unsafe { core::mem::transmute::<*mut (dyn Any + Send), RawPayload>(raw) };
            unsafe { payload_out.write(raw) };
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
    // SAFETY: the inverse of the conversion in `call_catching`.
    let raw = unsafe { core::mem::transmute::<RawPayload, *mut (dyn Any + Send)>(payload) };
    resume_unwind(unsafe { Box::from_raw(raw) })
}
