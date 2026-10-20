//! Per-thread VM state: the VM stack and the chain of entry records.

use core::ffi::c_void;
use core::ptr;

use super::registry::ImageRt;
use super::sys;
use crate::unwind::RawPayload;

/// Size of each thread's VM stack mapping, guard page included. Like a native main-thread
/// stack. The mapping is `MAP_NORESERVE`, so untouched pages cost nothing.
pub const STACK_SIZE: usize = 8 << 20;
/// Inaccessible bytes at the top of the stack mapping. The explicit stack check never lets
/// frames reach them; they catch only VM bugs.
pub const GUARD: usize = sys::PAGE;

/// The per-thread VM state (design/vm.md, "Execution state").
///
/// Only ever reached through the raw pointer from [`current`], never as a `&mut`:
/// re-entrant `vm::enter` calls on the same thread would otherwise create aliasing mutable
/// references. It is `!Send`/`!Sync` (raw pointer fields) and lives in `#[thread_local]`
/// storage without a destructor.
pub struct VmThread {
    /// Base of the stack mapping (page-aligned), or null before the first `enter`.
    pub stack_base: *mut u8,
    /// End of the usable stack: frames, including each function's `max_outgoing` area, must
    /// end at or below it.
    pub limit: *mut u8,
    /// End of the current frame (`fp + frame_size` of the innermost running function), or
    /// the stack base when no VM code runs. Outgoing argument blocks and the next `enter`'s
    /// frame start here.
    pub top: *mut u8,
    /// The innermost entry record, or null.
    pub entry: *mut Entry,
    /// Image context: the current image and its code bounds (for `ret`'s cross-image check).
    pub img: *const ImageRt,
    pub code_lo: *const u32,
    pub code_hi: *const u32,
}

/// One active `vm::enter`. Lives in `enter`'s native stack frame and is linked into
/// [`VmThread::entry`] while that call runs.
pub struct Entry {
    pub prev: *mut Entry,
    /// `VmThread::top` and the image context at the time of the call, restored on return.
    pub saved_top: *mut u8,
    pub saved_img: *const ImageRt,
    /// Where `ret` from the entry frame writes the return value (the portal's `ret`).
    pub ret: *mut u8,
    /// The payload of a panic unwinding through this entry. [`RawPayload::NONE`] otherwise.
    /// `call_catching` writes it without dropping the previous value.
    pub payload: RawPayload,
}

#[thread_local]
static mut VM: VmThread = VmThread {
    stack_base: ptr::null_mut(),
    limit: ptr::null_mut(),
    top: ptr::null_mut(),
    entry: ptr::null_mut(),
    img: ptr::null(),
    code_lo: ptr::null(),
    code_hi: ptr::null(),
};

/// The current thread's VM state, with its stack set up.
#[inline]
pub fn current() -> *mut VmThread {
    let vm = &raw mut VM;
    // SAFETY: `vm` points at this thread's VmThread; reading a field through the raw pointer
    // creates no reference.
    if unsafe { (*vm).stack_base.is_null() } {
        init_stack(vm);
    }
    vm
}

#[cold]
#[inline(never)]
fn init_stack(vm: *mut VmThread) {
    let base = sys::map(STACK_SIZE, GUARD);
    // SAFETY: `vm` is this thread's state, and no VM code runs on this thread yet (the stack
    // didn't exist), so nothing else accesses it.
    unsafe {
        (*vm).stack_base = base;
        (*vm).limit = base.add(STACK_SIZE - GUARD);
        (*vm).top = base;
    }
    sys::on_thread_exit(base.cast());
}

/// Thread-exit hook: frees the VM stack. Native code still running thread-exit destructors
/// may re-enter the VM afterwards; [`current`] then maps a fresh stack (and registers the
/// hook again, so the pthread/FLS destructor loop frees it too).
///
/// # Safety
/// Called on the exiting thread, with the value registered by [`init_stack`].
pub unsafe fn thread_exit(base: *mut c_void) {
    let vm = &raw mut VM;
    // SAFETY: this thread's state; destructors run outside any VM activation unless the
    // thread exits from inside VM code (`pthread_exit`), in which case `entry` is non-null and
    // the stack is leaked rather than unmapped under live frames.
    unsafe {
        if (*vm).stack_base.cast() != base || !(*vm).entry.is_null() {
            return;
        }
        (*vm).stack_base = ptr::null_mut();
        (*vm).limit = ptr::null_mut();
        (*vm).top = ptr::null_mut();
        sys::unmap(base.cast(), STACK_SIZE);
        STACKS_FREED.fetch_add(1, core::sync::atomic::Ordering::Relaxed);
    }
}

/// The current thread's VM stack base, or null if it has none (yet, or any more).
pub fn stack_base() -> *const u8 {
    // SAFETY: reads one field of this thread's state through the raw pointer.
    unsafe { (*(&raw const VM)).stack_base }
}

/// Number of VM stacks unmapped at thread exit so far (for tests).
pub static STACKS_FREED: core::sync::atomic::AtomicUsize = core::sync::atomic::AtomicUsize::new(0);
