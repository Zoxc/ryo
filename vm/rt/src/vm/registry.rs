//! The image registry (design/vm.md, "Image format": Registry).
//!
//! Registered images are kept in immutable snapshots, published through one atomic pointer.
//! Readers load the pointer and never block. Writers (registration, lazy table builds) take
//! the runtime lock. Snapshots and tables are allocated with
//! [`sys::Bump::alloc_forever`] and never freed, so `&'static` references to them stay valid.

use core::ptr;
use core::sync::atomic::{AtomicPtr, Ordering};

use ryo_bytecode::image::Image;

use super::sys::{fatal, lock};

struct Snapshot {
    /// The registered images, sorted by crate hash (then CGU hash). Immutable once published.
    by_hash: *const Image<'static>,
    n: usize,
}

impl Snapshot {
    fn images(&self) -> &'static [Image<'static>] {
        // SAFETY: `by_hash` holds `n` initialized images, published and never freed.
        unsafe { core::slice::from_raw_parts(self.by_hash, self.n) }
    }
}

static SNAPSHOT: AtomicPtr<Snapshot> = AtomicPtr::new(ptr::null_mut());

fn snapshot() -> Option<&'static Snapshot> {
    // SAFETY: published snapshots are fully initialized before the Release store (paired with
    // this Acquire load), and never freed or mutated except through their atomics.
    unsafe { SNAPSHOT.load(Ordering::Acquire).as_ref() }
}

/// Registers the images whose headers are the non-null entries of `[start, end)`. See
/// [`super::ryo_vm_register`].
///
/// # Safety
/// As for `ryo_vm_register`.
pub unsafe fn register(start: *const *const u8, end: *const *const u8, anchor: *const u8) {
    // A copy merged into another registers there (design/vm.md#several-ryo-runtimes-in-one-process).
    if let Some(winner) = super::jit::forward() {
        // SAFETY: per the caller; the winner's `ryo_vm_register` has the same contract.
        return unsafe { winner(start, end, anchor) };
    }
    let n = (end as usize).saturating_sub(start as usize) / size_of::<*const u8>();
    let mut g = lock();
    let old = snapshot().map_or(&[][..], Snapshot::images);
    let cap = old.len() + n;
    let by_hash = g.alloc_forever(cap * size_of::<Image<'static>>(), align_of::<Image<'static>>()).cast::<Image<'static>>();
    // SAFETY: fresh, suitably sized and aligned allocation. Elements are written before
    // they are viewed: `done(len)` covers only the first `len`, which are initialized.
    unsafe { ptr::copy_nonoverlapping(old.as_ptr(), by_hash, old.len()) };
    let done = |len: usize| -> &[Image<'static>] { unsafe { core::slice::from_raw_parts(by_hash, len) } };
    let mut len = old.len();
    for i in 0..n {
        // SAFETY: the caller passes `n` readable header pointers.
        let h = unsafe { *start.add(i) };
        // SAFETY: per the caller.
        let Some(view) = (unsafe { admit(h, anchor, done(len)) }) else { continue };
        super::jit::registered(&view);
        // SAFETY: `by_hash` has room for `cap > len` entries.
        unsafe { by_hash.add(len).write(view) };
        len += 1;
    }
    if len == old.len() {
        return;
    }
    // SAFETY: the first `len` entries are initialized, and nothing else views them.
    let list = unsafe { core::slice::from_raw_parts_mut(by_hash, len) };
    sort_by_key(list, |im| (im.crate_hash(), im.header().cgu_hash));
    let snap = g.alloc_forever(size_of::<Snapshot>(), align_of::<Snapshot>()).cast::<Snapshot>();
    // SAFETY: fresh allocation; fully written before it is published.
    unsafe { snap.write(Snapshot { by_hash, n: len }) };
    SNAPSHOT.store(snap, Ordering::Release);
}

/// Registers the image with header `h` if it isn't yet: the lazy path of registration, for
/// VM code that runs before its link unit's registry constructor. On Mach-O, which has no
/// constructor priorities, a constructor that the linker places ahead of the registry's (a C
/// object's, a staticlib member's, a `-Wl` object's) may enter the VM (design/platforms.md).
/// Such code runs as AOT code without registration, as nothing it executes reads the registry
/// (Mach-O images have no fixups); what needs it is the JIT, so its trips call this first
/// (a cold path). The constructor still registers the rest of the link unit, skipping `h`.
///
/// # Safety
/// As for `ryo_vm_register`, for `h` (a JIT record's `header`).
#[cfg_attr(not(feature = "jit"), allow(dead_code))]
pub unsafe fn ensure(h: *const u8) {
    if snapshot().is_some_and(|s| s.images().iter().any(|im| ptr::eq(im.header(), h.cast()))) {
        return;
    }
    let entry = [h];
    // SAFETY: per the caller; `register` skips the image if another thread just registered it.
    // No anchor: the image's own trip reached this runtime, so it is this runtime's.
    unsafe { register(entry.as_ptr(), entry.as_ptr().wrapping_add(1), ptr::null()) }
}

/// The admission checks for header `h` against the images already registered (`existing`):
/// `None` to skip it (a null entry, an image registered before, or one linked against another
/// anchor than a non-null `anchor`); aborts on an image of another ryo build, an invalid,
/// duplicate or unlinked image. Applies the image's fixups.
///
/// # Safety
/// `h` is null or a linked image's header, valid forever (as for `ryo_vm_register`), and the
/// runtime lock is held.
unsafe fn admit(h: *const u8, anchor: *const u8, existing: &[Image<'static>]) -> Option<Image<'static>> {
    use ryo_bytecode::image::{Header, MAGIC};
    if h.is_null() {
        return None; // the stub's entry, or linker padding (PE incremental linking)
    }
    if existing.iter().any(|im| ptr::eq(im.header(), h.cast())) {
        return None; // registered before (e.g. a library loaded twice)
    }
    // Before parsing: another build's header may have another layout. The tagged symbols
    // keep other builds' images away from this runtime (design/build.md#the-abi-tag), so this
    // is the backstop for what bypasses them.
    // SAFETY: per the caller, `h` is a linked image's header, valid forever.
    let (magic, abi, owner) = unsafe {
        let p = h.cast::<Header>();
        ((&raw const (*p).magic).read_unaligned(), (&raw const (*p).abi).read_unaligned(), (&raw const (*p).anchor).read_unaligned())
    };
    if !anchor.is_null() && owner != 0 && owner != anchor as u64 {
        return None; // another runtime's image in this link unit (design/backend.md#pipeline)
    }
    if magic == MAGIC && abi != ryo_bytecode::ABI {
        fatal("ryo_vm_register: image built by another ryo build (ABI tag mismatch); mixing ryo builds in one runtime is unsupported");
    }
    // SAFETY: per the caller, `h` is a linked image's header, valid forever.
    let view = match unsafe { Image::from_header(h) } {
        Ok(v) => v,
        Err(_) => fatal("ryo_vm_register: invalid image"),
    };
    let hdr = view.header();
    if let Some(o) = existing.iter().find(|im| im.crate_hash() == view.crate_hash() && im.header().cgu_hash == hdr.cgu_hash) {
        if o.header().stable_crate_id == hdr.stable_crate_id {
            fatal("ryo_vm_register: an image is registered twice (two copies of one crate)");
        }
        fatal("ryo_vm_register: crate hash collision between two images");
    }
    if (view.data_ptr().is_null() && hdr.data_size != 0) || (view.text_ptr().is_null() && hdr.text_size != 0) {
        fatal("ryo_vm_register: image is not linked");
    }
    if !view.fixups().is_empty() {
        if view.validate().is_err() {
            fatal("ryo_vm_register: invalid image tables");
        }
        // SAFETY: validated; the image was just linked/loaded, its writable section is
        // not yet used by anyone (it isn't published), and its indirect symbol slots
        // point at import slots (per the caller).
        unsafe { view.apply_fixups() };
    }
    Some(view)
}

/// The header of the registered image whose text or read-only section holds `addr`, or
/// null: the JIT finds the VM function another image's code calls by its address, and the
/// constant pool a constant address points into ([`RtApi::image_at`]).
/// Lock-free, like every reader.
///
/// [`RtApi::image_at`]: ryo_bytecode::jit_abi::RtApi::image_at
#[cfg_attr(not(feature = "jit"), allow(dead_code))]
pub fn image_at(addr: usize) -> *const u8 {
    let Some(s) = snapshot() else { return ptr::null() };
    for im in s.images() {
        let text = im.text_ptr() as usize;
        let ro = im.bytes();
        if addr.wrapping_sub(text) < im.header().text_size as usize || addr.wrapping_sub(ro.as_ptr() as usize) < ro.len() {
            return (im.header() as *const ryo_bytecode::image::Header).cast();
        }
    }
    ptr::null()
}

/// An insertion sort: core's sorts reference its panic path (`panic_on_ord_violation`), which
/// the runtime must not reach (design/vm.md, "No re-entry"). Lists are short (one entry per
/// image).
fn sort_by_key<K: Ord>(list: &mut [Image<'static>], key: impl Fn(&Image<'static>) -> K) {
    let p = list.as_mut_ptr();
    for i in 1..list.len() {
        let mut j = i;
        // SAFETY: `j` and `j - 1` are below `list.len()`.
        unsafe {
            while j > 0 && key(&*p.add(j - 1)) > key(&*p.add(j)) {
                ptr::swap(p.add(j - 1), p.add(j));
                j -= 1;
            }
        }
    }
}
