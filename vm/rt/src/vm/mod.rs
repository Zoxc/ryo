//! The VM: the handlers and the registry. See
//! design/vm.md.
//!
//! - [`ryo_vm_register`]: image registration, called by the registry object's constructor.
//! - [`trip_entry`], [`trip_osr`]: where the JIT records' slots start: the JIT's trips
//!   (design/jit.md).
//!
//! VM functions are native functions of their signatures (design/vm.md, "Calls and
//! islands"): native code calls them directly, and there is no entry from portals.
//!
//! Everything reachable from these uses `core` and OS calls only (no std allocator, locks or
//! TLS), so it never re-enters the VM (design/vm.md, "No re-entry into the VM from the
//! runtime"), the JIT's side (`jit`) included; its thread, which uses std, is the sealed
//! `ryo_jit` with a std of its own (design/jit.md, "Packaging").

mod interp;
mod jit;
mod registry;
// The PE exception handler of VM code (its logic is tested on every host).
#[cfg(any(windows, test))]
mod seh;
mod sys;

#[cfg(not(any(windows, target_vendor = "apple")))]
pub use interp::{FP_MODE, fp_handler, fp_reg_handler};
pub use interp::{HANDLER_MODES, MODE, RegRet, handler, handler_for, probe_stack, reg_handler, reg_handler_for};
#[cfg(all(feature = "pe-test", not(windows)))]
pub use interp::{PE_MODE, pe_handler, pe_reg_handler};
pub use jit::{JIT_ENTRY_PREFIX, configure_jit, configure_jit_off, jit_shuffle_image};
pub use jit::{trip_entry, trip_osr};

/// A registration function: [`ryo_vm_register`] (`C-unwind`, but it never unwinds), called as
/// `C`: a call through a `C-unwind` pointer would make `ryo_rt` require `panic=unwind`.
/// `jit::forward` returns one.
pub(crate) type RegisterFn = unsafe extern "C" fn(*const *const u8, *const *const u8, *const u8);

/// Registers the images whose header addresses are the non-null entries of `[start, end)` and
/// that were linked against `anchor` (`Header::anchor`; a null `anchor` takes all). Called by
/// each link unit's registry stub constructor with the bounds of the link unit's
/// `ryo_images_<tag>` section (each image object contributes one entry, the stub a null one)
/// and its registry anchor (design/backend.md#pipeline), including for shared objects loaded
/// at run time. Images of another anchor belong to another runtime in the same link unit
/// (staticlibs combined with `ld -r` and localized), whose stub registers them. Images already
/// registered are skipped. Aborts on an invalid image, an image of another ryo build
/// (`Header::abi`), or on two images with the same crate and CGU hashes.
///
/// Its symbol is internal (`#[rustc_std_internal_symbol]`) and tagged
/// (`ryo_vm_register_<tag>`, mangled): a cdylib doesn't export it, so no other module's stub
/// can bind to it, and no other ryo build's.
///
/// # Safety
/// `[start, end)` must be readable pointer-sized entries, each null or a linked image's header
/// that stays mapped and unchanged for the rest of the process (images are never
/// unregistered).
///
/// `C-unwind`, so the compiler adds no abort-on-unwind guard, which would reference core's
/// panic path (design/vm.md, "No re-entry"); nothing in it panics (`y test`'s `rt-core-only`).
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(ryo_bytecode::rt_sym!(register)))]
pub unsafe extern "C-unwind" fn ryo_vm_register(start: *const *const u8, end: *const *const u8, anchor: *const u8) {
    // SAFETY: per the caller.
    unsafe { registry::register(start, end, anchor) }
}
