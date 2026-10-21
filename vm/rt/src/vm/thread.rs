//! Per-thread VM state: the chain of entry records.

use core::ptr;

/// The per-thread VM state (design/vm.md, "Execution state").
///
/// Only ever reached through the raw pointer from [`current`], never as a `&mut`:
/// re-entrant `vm::enter` calls on the same thread would otherwise create aliasing mutable
/// references. It is `!Send`/`!Sync` (raw pointer fields) and lives in `#[thread_local]`
/// storage without a destructor.
pub struct VmThread {
    /// The innermost entry record, or null.
    pub entry: *mut Entry,
}

/// One active `vm::enter`. Lives in `enter`'s native stack frame and is linked into
/// [`VmThread::entry`] while that call runs.
pub struct Entry {
    pub prev: *mut Entry,
    /// Where `ret` from the entry frame writes the return value (the portal's `ret`).
    pub ret: *mut u8,
}

#[thread_local]
static mut VM: VmThread = VmThread { entry: ptr::null_mut() };

/// The current thread's VM state.
#[inline]
pub fn current() -> *mut VmThread {
    &raw mut VM
}
