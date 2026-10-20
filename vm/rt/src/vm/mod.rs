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

use core::ptr;

pub use registry::{Function, ImageRt};
pub use interp::STRATEGY;
pub use thread::{STACK_SIZE, VmThread};

use crate::unwind::RawPayload;
use thread::Entry;

/// Registers `n` images. `images[i]` is the address of an image header
/// (`__ryo_image_<StableCrateId>`). Called by each link unit's registry object constructor,
/// including for shared objects loaded at run time. Images already registered are skipped.
/// Aborts on an invalid image or a crate hash collision.
///
/// # Safety
/// `images` must point at `n` pointers to linked images that stay mapped and unchanged for the
/// rest of the process (images are never unregistered).
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ryo_vm_register(images: *const *const u8, n: usize) {
    // SAFETY: per the caller.
    unsafe { registry::register(images, n) }
}

/// Maps the address of a VM function's portal to its function record, or `None` if `addr`
/// isn't the portal of a registered VM function.
pub fn lookup_addr(addr: *const ()) -> Option<&'static Function> {
    registry::lookup_addr(addr)
}

/// The current thread's VM stack base, or null if it has none. For tests.
#[doc(hidden)]
pub fn current_stack_base() -> *const u8 {
    thread::stack_base()
}

/// Number of VM stacks unmapped at thread exit so far. For tests.
#[doc(hidden)]
pub fn stacks_freed() -> usize {
    thread::STACKS_FREED.load(core::sync::atomic::Ordering::Relaxed)
}

#[cfg(feature = "registry-anchor")]
unsafe extern "C" {
    /// Defined by the registry object of each final link (design/backend.md).
    static __ryo_registry_anchor: u8;
}

/// Pops an entry record: restores the thread's stack top and image context. Runs on the
/// normal return of `enter` and if a panic unwinds natively through it (which only a buggy
/// plain `island` can cause), so the chain never points at a dead record. The same holds for
/// forced unwinding (`pthread_exit` from native code called by an island): it runs this
/// guard like any other landing pad, so each `enter` it passes is popped in order.
struct PopEntry {
    vm: *mut VmThread,
    rec: *mut Entry,
}

impl Drop for PopEntry {
    fn drop(&mut self) {
        // SAFETY: `rec` is the innermost record of this thread's `vm`, still alive (it is a
        // local of the `enter` frame this guard belongs to).
        unsafe {
            (*self.vm).entry = (*self.rec).prev;
            (*self.vm).top = (*self.rec).saved_top;
            interp::set_image(self.vm, (*self.rec).saved_img);
        }
    }
}

/// Entry from portals: runs the VM function `id` (crate hash, function index) with the
/// argument block at `args`. Returns 0 when it returned (the value is at `ret`), or 1 when a
/// panic unwound out of it, with the payload moved to `*payload_out`.
///
/// Works re-entrantly: the new frame goes at the thread's current stack top, above any
/// suspended VM frames.
///
/// # Safety
/// `args` points at the callee's argument block, whose values the VM takes ownership of. `ret`
/// is valid for writing the return value, and `payload_out` for writing a `RawPayload`.
#[inline(never)]
pub unsafe fn enter(id: u64, args: *const u8, ret: *mut u8, payload_out: *mut RawPayload) -> u32 {
    #[cfg(feature = "registry-anchor")]
    core::hint::black_box(&raw const __ryo_registry_anchor);

    if sys::trace_enabled() {
        sys::trace_enter(id);
    }
    let vm = thread::current();
    let f = registry::resolve_id(id);
    // SAFETY: `vm` is this thread's state, reached only through the raw pointer. The frame at
    // the current top is checked against the limit before it is written. `args` holds
    // `arg_size` bytes (the portal's `Args` is the argument block), disjoint from the VM
    // stack. `rec` lives until `PopEntry` unlinks it at the end of this function.
    unsafe {
        let fp = (*vm).top;
        interp::check_stack(vm, fp, f.frame_size as usize + f.max_outgoing as usize);
        fp.cast::<*mut u8>().write(ptr::null_mut());
        fp.add(8).cast::<*const u32>().write(ptr::null());
        ptr::copy_nonoverlapping(args, fp.add(ryo_bytecode::abi::HEADER_SIZE as usize), f.arg_size as usize);

        let mut rec = Entry {
            prev: (*vm).entry,
            saved_top: (*vm).top,
            saved_img: (*vm).img,
            ret,
            payload: RawPayload::NONE,
        };
        let rec = &raw mut rec;
        (*vm).entry = rec;
        let _pop = PopEntry { vm, rec };
        (*vm).top = fp.add(f.frame_size as usize);
        interp::set_image(vm, f.img);
        let st = interp::run(vm, f.code, fp);
        if st != 0 {
            payload_out.write((*rec).payload);
            (*rec).payload = RawPayload::NONE;
        }
        st
    }
}
