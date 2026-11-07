//! The image registry (design/vm.md, "Image format": Registry).
//!
//! Registered images are kept in immutable snapshots, published through one atomic pointer.
//! Readers load the pointer and never block. The writer, registration, takes
//! the runtime lock. Snapshots and their section indexes are allocated with
//! [`sys::Bump::alloc_forever`] and never freed, so `&'static` references to them stay valid.

use core::ptr;
use core::sync::atomic::{AtomicPtr, Ordering};

use ryo_bytecode::image::Image;
use ryo_bytecode::jit_abi::RtCode;

use super::sys::{Bump, fatal, lock};

struct Snapshot {
    /// The registered images, sorted by crate hash (then CGU hash).
    images: &'static [Image<'static>],
    /// The images' non-empty text and read-only sections, sorted by start address: for
    /// [`image_at`] and [`code_of`].
    sections: &'static [Section],
}

/// A section of a registered image: `[start, start + len)`, in the image with header `header`,
/// whose code calls the handlers of `code` (null: this copy's; [`code_of`]).
#[derive(Clone, Copy)]
struct Section {
    start: usize,
    len: usize,
    header: *const u8,
    code: *const RtCode,
}

static SNAPSHOT: AtomicPtr<Snapshot> = AtomicPtr::new(ptr::null_mut());

fn snapshot() -> Option<&'static Snapshot> {
    // SAFETY: published snapshots are fully initialized before the Release store (paired with
    // this Acquire load), and never freed or mutated except through their atomics.
    unsafe { SNAPSHOT.load(Ordering::Acquire).as_ref() }
}

/// Registers the images whose headers are the non-null entries of `[start, end)`, whose code
/// calls the handlers of `code` (null: this copy's). See [`super::register_from`].
///
/// # Safety
/// As for `register_from`.
pub unsafe fn register(start: *const *const u8, end: *const *const u8, anchor: *const u8, code: *const RtCode) {
    // A copy merged into another registers there (design/vm.md#several-ryo-runtimes-in-one-process),
    // passing the handlers its images call.
    if let Some(winner) = super::jit::forward() {
        let code = if code.is_null() { super::jit::code() as *const RtCode } else { code };
        // SAFETY: per the caller; the winner's `register_from` has the same contract, and
        // `code` is this copy's tables (static) or the caller's.
        return unsafe { winner(start, end, anchor, code) };
    }
    let n = (end as usize).saturating_sub(start as usize) / size_of::<*const u8>();
    let mut g = lock();
    let old = snapshot().map_or(&[][..], |s| s.images);
    let cap = old.len() + n;
    let by_hash = g.alloc_forever(cap * size_of::<Image<'static>>(), align_of::<Image<'static>>()).cast::<Image<'static>>();
    // SAFETY: fresh, suitably sized and aligned allocation.
    unsafe { ptr::copy_nonoverlapping(old.as_ptr(), by_hash, old.len()) };
    let mut len = old.len();
    for i in 0..n {
        // SAFETY: the caller passes `n` readable header pointers.
        let h = unsafe { *start.add(i) };
        // SAFETY: the first `len` entries are initialized, and nothing writes them while this
        // view lives.
        let existing = unsafe { core::slice::from_raw_parts(by_hash, len) };
        // SAFETY: per the caller.
        let Some(view) = (unsafe { admit(h, anchor, existing) }) else { continue };
        super::jit::registered(&view);
        // SAFETY: `by_hash` has room for `cap > len` entries.
        unsafe { by_hash.add(len).write(view) };
        len += 1;
    }
    if len == old.len() {
        return;
    }
    let old_sections = snapshot().map_or(&[][..], |s| s.sections);
    // SAFETY: entries `old.len()..len` are the new images, initialized; not `&images[..]`,
    // whose bounds check reaches core's panic path.
    let new = unsafe { core::slice::from_raw_parts(by_hash.add(old.len()), len - old.len()) };
    let sections = build_sections(&mut g, old_sections, new, code);
    // SAFETY: the first `len` entries are initialized, and nothing else views them (`new` is
    // dead). They are allocated forever and not mutated after sorting, so the list is
    // `&'static`.
    let images: &'static mut [Image<'static>] = unsafe { core::slice::from_raw_parts_mut(by_hash, len) };
    sort_by_key(images, |im| (im.crate_hash(), im.header().cgu_hash));
    publish(&mut g, Snapshot { images, sections });
}

/// The by-address index of the sections `old` and the non-empty text and read-only sections
/// of `new`, images whose code calls `code`'s handlers, sorted by start address.
fn build_sections(g: &mut Bump, old: &[Section], new: &[Image<'static>], code: *const RtCode) -> &'static [Section] {
    let by_addr = g.alloc_forever((old.len() + 2 * new.len()) * size_of::<Section>(), align_of::<Section>()).cast::<Section>();
    // SAFETY: fresh, suitably sized and aligned allocation.
    unsafe { ptr::copy_nonoverlapping(old.as_ptr(), by_addr, old.len()) };
    let mut n = old.len();
    for im in new {
        let header = (im.header() as *const ryo_bytecode::image::Header).cast::<u8>();
        let ro = im.bytes();
        for (start, len) in [(im.text_ptr() as usize, im.header().text_size as usize), (ro.as_ptr() as usize, ro.len())] {
            if len != 0 {
                // SAFETY: `by_addr` has room for two entries per new image.
                unsafe { by_addr.add(n).write(Section { start, len, header, code }) };
                n += 1;
            }
        }
    }
    // SAFETY: the first `n` entries are initialized, and nothing else views them. They are
    // allocated forever and not mutated after sorting.
    let sections = unsafe { core::slice::from_raw_parts_mut(by_addr, n) };
    sort_by_key(sections, |s| s.start);
    sections
}

/// Publishes `snap` as the current snapshot, for lock-free readers.
fn publish(g: &mut Bump, snap: Snapshot) {
    let p = g.alloc_forever(size_of::<Snapshot>(), align_of::<Snapshot>()).cast::<Snapshot>();
    // SAFETY: fresh, suitably sized and aligned allocation; fully written before it is
    // published.
    unsafe { p.write(snap) };
    SNAPSHOT.store(p, Ordering::Release);
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
pub unsafe fn ensure(h: *const u8) {
    if snapshot().is_some_and(|s| s.images.iter().any(|im| ptr::eq(im.header(), h.cast()))) {
        return;
    }
    let entry = [h];
    // SAFETY: per the caller; `register` skips the image if another thread just registered it.
    // No anchor: the image's own trip reached this runtime, so it is this runtime's.
    unsafe { register(entry.as_ptr(), entry.as_ptr().wrapping_add(1), ptr::null(), ptr::null()) }
}

/// The admission checks for header `h` against the images already registered (`existing`):
/// `None` to skip it (a null entry, an image registered before, or one linked against another
/// anchor than a non-null `anchor`); aborts on an image of another ryo build, an invalid or
/// unlinked image, or a duplicate in its link unit. Applies the image's fixups.
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
    // Only within a link unit (one anchor): a merged runtime also registers other modules'
    // images, and a module may statically link a crate the host links too, a copy of its own
    // (design/vm.md#several-ryo-runtimes-in-one-process). Nothing looks images up by hash.
    let same =
        |im: &&Image<'static>| im.header().anchor == hdr.anchor && im.crate_hash() == view.crate_hash() && im.header().cgu_hash == hdr.cgu_hash;
    if let Some(o) = existing.iter().find(same) {
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
pub fn image_at(addr: usize) -> *const u8 {
    section_at(addr).map_or(ptr::null(), |s| s.header)
}

/// The handlers the code of the registered image with header `h` calls: its runtime copy's
/// tables, null for this copy's own (or no such image) ([`RtApi::code_of`]).
///
/// [`RtApi::code_of`]: ryo_bytecode::jit_abi::RtApi::code_of
pub fn code_of(h: *const u8) -> *const RtCode {
    // The header starts the image's read-only section.
    section_at(h as usize).filter(|s| s.header == h).map_or(ptr::null(), |s| s.code)
}

/// The registered section that holds `addr`.
fn section_at(addr: usize) -> Option<&'static Section> {
    let s = snapshot()?;
    let secs = s.sections;
    // Binary search for the number of sections starting at or below `addr`; sections don't
    // overlap, so only the last of them can hold it.
    let (mut lo, mut hi) = (0, secs.len());
    while lo < hi {
        let mid = lo + (hi - lo) / 2;
        // SAFETY: `mid < hi <= secs.len()`.
        if unsafe { secs.get_unchecked(mid) }.start <= addr {
            lo = mid + 1;
        } else {
            hi = mid;
        }
    }
    if lo == 0 {
        return None;
    }
    // SAFETY: `0 < lo <= secs.len()`.
    let sec = unsafe { secs.get_unchecked(lo - 1) };
    (addr.wrapping_sub(sec.start) < sec.len).then_some(sec)
}

/// The registered image whose header is at `h`.
pub fn image(h: usize) -> Option<&'static Image<'static>> {
    snapshot()?.images.iter().find(|i| i.bytes().as_ptr() as usize == h)
}

/// The registered image whose text holds `addr`, the function there and the offset in it.
pub fn text_at(addr: usize) -> Option<(&'static Image<'static>, u32, u32)> {
    let h = image_at(addr);
    if h.is_null() {
        return None;
    }
    let img = image(h as usize)?;
    let off = addr.wrapping_sub(img.text_ptr() as usize);
    if off >= img.header().text_size as usize {
        return None;
    }
    let (func, at) = img.function_at(off as u32)?;
    Some((img, func, at))
}

/// A heapsort: core's sorts reference its panic path (`panic_on_ord_violation`), which the
/// runtime must not reach (design/vm.md, "No re-entry"). O(n log n) whatever the input order:
/// every registration sorts the section index again, the new sections after the old ones.
fn sort_by_key<T, K: Ord>(list: &mut [T], key: impl Fn(&T) -> K) {
    let p = list.as_mut_ptr();
    let n = list.len();
    // Moves the entry at `i` down the max-heap of the first `end` entries.
    let sift = |mut i: usize, end: usize| loop {
        let mut c = 2 * i + 1;
        if c >= end {
            break;
        }
        // SAFETY: `i < c < end <= n`, and `c + 1 < end` where read.
        unsafe {
            if c + 1 < end && key(&*p.add(c)) < key(&*p.add(c + 1)) {
                c += 1;
            }
            if key(&*p.add(i)) >= key(&*p.add(c)) {
                break;
            }
            ptr::swap(p.add(i), p.add(c));
        }
        i = c;
    };
    for i in (0..n / 2).rev() {
        sift(i, n);
    }
    for end in (1..n).rev() {
        // SAFETY: `end < n`.
        unsafe { ptr::swap(p, p.add(end)) };
        sift(0, end);
    }
}
