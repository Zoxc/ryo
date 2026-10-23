//! The VM: the handlers and the registry. See
//! design/vm.md.
//!
//! - [`ryo_vm_register`]: image registration, called by the registry object's constructor.
//! - [`trip_entry`], [`trip_osr`]: where the JIT records' slots start: the JIT's trips, or
//!   the no-op JIT's without the `jit` feature and on PE.
//!
//! VM functions are native functions of their signatures (design/vm.md, "Calls and
//! islands"): native code calls them directly, and there is no entry from portals.
//!
//! Everything reachable from these uses `core` and OS calls only (no std allocator, locks or
//! TLS), so it never re-enters the VM (design/vm.md, "No re-entry into the VM from the
//! runtime"), except the JIT (`jit`, with the `jit` feature), which uses the native std.

mod interp;
#[cfg_attr(all(feature = "jit", target_os = "linux"), path = "jit/mod.rs")]
#[cfg_attr(not(all(feature = "jit", target_os = "linux")), path = "jit/noop.rs")]
mod jit;
mod registry;
mod sys;

pub use interp::{FP_ARG, MODE, h, handler, probe_stack};
#[cfg(all(feature = "jit", target_os = "linux"))]
pub use jit::{JIT_ENTRY_PREFIX, REDIRECT, configure_jit, jit_shuffle_image, jit_stats};
pub use jit::{trip_entry, trip_osr};
pub use registry::ImageRt;

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
