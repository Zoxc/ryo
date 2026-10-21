//! The VM: entry from portals, the interpreter, the registry and per-thread state. See
//! design/vm.md.
//!
//! - [`enter`]: entry from portals.
//! - [`ryo_vm_register`]: image registration, called by the registry object's constructor.
//! - [`lookup_addr`]: portal address → VM function.
//!
//! Everything reachable from these uses `core` and OS calls only (no std allocator, locks or
//! TLS), so it never re-enters the VM (design/vm.md, "No re-entry into the VM from the
//! runtime").

mod interp;
mod registry;
mod sys;
mod thread;

pub use registry::{Function, ImageRt};
pub use thread::VmThread;

use thread::Entry;

/// Registers `n` images. `images[i]` is the address of an image header
/// (`__ryo_image_<StableCrateId>`). Called by each link unit's registry object constructor,
/// including for shared objects loaded at run time. Images already registered are skipped.
/// Aborts on an invalid image or a crate hash collision.
///
/// # Safety
/// `images` must point at `n` pointers to linked images that stay mapped and unchanged for the
/// rest of the process (images are never unregistered).
///
/// `C-unwind`, so the compiler adds no abort-on-unwind guard, which would reference core's
/// panic path (design/vm.md, "No re-entry"); nothing in it panics (`y test`'s `rt-core-only`).
#[unsafe(no_mangle)]
pub unsafe extern "C-unwind" fn ryo_vm_register(images: *const *const u8, n: usize) {
    // SAFETY: per the caller.
    unsafe { registry::register(images, n) }
}

/// Maps the address of a VM function's portal to its function record, or `None` if `addr`
/// isn't the portal of a registered VM function.
pub fn lookup_addr(addr: *const ()) -> Option<&'static Function> {
    registry::lookup_addr(addr)
}

#[cfg(feature = "registry-anchor")]
unsafe extern "C" {
    /// Defined by the registry object of each final link (design/backend.md).
    static __ryo_registry_anchor: u8;
}

/// Pops an entry record. Runs on the normal return of `enter` and when a panic unwinds
/// through it, so the chain never points at a dead record. The same holds for forced
/// unwinding (`pthread_exit` from native code): it runs this guard like any other landing
/// pad, so each `enter` it passes is popped in order.
struct PopEntry {
    vm: *mut VmThread,
    rec: *mut Entry,
}

impl Drop for PopEntry {
    fn drop(&mut self) {
        // SAFETY: `rec` is the innermost record of this thread's `vm`, still alive (it is a
        // local of the `enter` frame this guard belongs to).
        unsafe { (*self.vm).entry = (*self.rec).prev };
    }
}

/// Entry from portals: runs the VM function `id` (crate hash, function index) with the
/// argument block at `args`, and writes its return value to `ret`. A panic unwinds out of
/// it natively.
///
/// Works re-entrantly: the new frame goes on the native stack, below the caller's.
///
/// # Safety
/// `args` points at the callee's argument block, whose values the VM takes ownership of, and
/// `ret` is valid for writing the return value.
#[inline(never)]
pub unsafe fn enter(id: u64, args: *const u8, ret: *mut u8) {
    #[cfg(feature = "registry-anchor")]
    core::hint::black_box(&raw const __ryo_registry_anchor);

    if sys::trace_enabled() {
        sys::trace_enter(id);
    }
    sys::count(&sys::RUN_STATS.enters);
    let vm = thread::current();
    let f = registry::resolve_id(id);
    // SAFETY: `vm` is this thread's state, reached only through the raw pointer. `rec` lives
    // until `PopEntry` unlinks it at the end of this function.
    unsafe {
        let mut rec = Entry { prev: (*vm).entry, ret };
        let rec = &raw mut rec;
        (*vm).entry = rec;
        let _pop = PopEntry { vm, rec };
        interp::run(f, args);
    }
}
