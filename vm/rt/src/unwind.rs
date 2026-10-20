//! Panic glue between islands, the VM and native code. See design/stubs.md (Unwinding) and
//! design/vm.md (Unwinding).
//!
//! A panic stays "in flight" while the VM unwinds its frames, as it does natively: it is
//! caught with the bare `catch_unwind` intrinsic and the panic runtime's
//! `__rust_panic_cleanup`, and re-raised with `__rust_start_panic`, the two halves of
//! `std::panic::catch_unwind`/`resume_unwind` that don't touch std's panic count. So
//! `std::thread::panicking()` is true in VM cleanup code (drops during unwinding, `Mutex`
//! poisoning), and the count is decremented once, by whoever finally catches the panic.
//! Nothing here enters the VM.

use core::panic::PanicPayload;
use core::any::Any;
use core::fmt;

#[allow(improper_ctypes)] // declared as std declares it; only Rust code defines it
unsafe extern "C" {
    /// The panic runtime's: the payload of a caught Rust panic exception (aborts on a foreign
    /// exception). What std's `catch_unwind` calls, minus its panic-count decrement.
    #[rustc_std_internal_symbol]
    fn __rust_panic_cleanup(exception: *mut u8) -> *mut (dyn Any + Send + 'static);
}

unsafe extern "Rust" {
    /// The panic runtime's: raises `payload`. What std's `resume_unwind` ends in, minus its
    /// panic-count increment.
    #[rustc_std_internal_symbol]
    fn __rust_start_panic(payload: &mut dyn PanicPayload) -> u32;
}

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

/// Runs the island `f(fp, ops)`, catching a panic that unwinds out of it.
///
/// On a panic, the payload is written to `*payload_out` (the VM passes the current entry
/// record's payload slot) and `unwinding` is set. The panic stays counted by std (see the
/// module docs). The previous value of `*payload_out` is overwritten without being dropped,
/// so it must be [`RawPayload::NONE`]. On success, `*payload_out` is not touched.
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
    struct Data {
        f: unsafe fn(*mut u8, *const u32) -> u32,
        fp: *mut u8,
        ops: *const u32,
        succ: u32,
        payload_out: *mut RawPayload,
    }
    unsafe fn do_call(d: *mut u8) {
        let d = d.cast::<Data>();
        unsafe { (*d).succ = ((*d).f)((*d).fp, (*d).ops) };
    }
    unsafe fn do_catch(d: *mut u8, exception: *mut u8) {
        let d = d.cast::<Data>();
        unsafe { (*d).payload_out.write(RawPayload(__rust_panic_cleanup(exception))) };
    }
    let mut data = Data { f, fp, ops, succ: 0, payload_out };
    let unwinding = unsafe { core::intrinsics::catch_unwind(do_call, (&raw mut data).cast::<u8>(), do_catch) };
    if unwinding { CatchResult { succ: 0, unwinding: true } } else { CatchResult { succ: data.succ, unwinding: false } }
}

/// Re-raises a payload caught by [`call_catching`] natively, as the same (still counted)
/// panic. Called by portals after `vm::enter` has popped its entry record.
///
/// # Safety
/// `payload` must have been produced by [`call_catching`], and is consumed.
#[inline(never)]
pub unsafe fn resume_unwind_from_vm(payload: RawPayload) -> ! {
    /// Hands the payload box to the panic runtime, as std's `resume_unwind` does.
    struct Rewrap(RawPayload);
    unsafe impl PanicPayload for Rewrap {
        fn take_box(&mut self) -> *mut (dyn Any + Send) {
            core::mem::replace(&mut self.0, RawPayload::NONE).0
        }
        fn get(&mut self) -> &(dyn Any + Send) {
            // SAFETY: a live box until `take_box`. The panic runtime calls `get` only before
            // `take_box` (as for std's `RewrapBox`); afterwards the pointer is null and `get`
            // must not be called.
            unsafe { &*self.0.0 }
        }
    }
    impl fmt::Display for Rewrap {
        fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            f.write_str("Box<dyn Any>")
        }
    }
    debug_assert!(!payload.is_none());
    let code = unsafe { __rust_start_panic(&mut Rewrap(payload)) };
    // Only reached if the panic runtime can't unwind (as std's `rust_panic`).
    let _ = code;
    core::intrinsics::abort()
}
