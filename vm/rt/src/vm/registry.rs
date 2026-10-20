//! The image registry (design/vm.md, "Image format": Registry, `vm::lookup_addr`).
//!
//! Registered images are kept in immutable snapshots, published through one atomic pointer.
//! Readers load the pointer and never block. Writers (registration, lazy table builds) take
//! the runtime lock. Snapshots, image records and tables are allocated with
//! [`sys::alloc_forever`] and never freed, so `&'static` references to them stay valid.

use core::ptr;
use core::sync::atomic::{AtomicPtr, Ordering};

use ryo_bytecode::image::{FuncEntry, Image, SYM_INDIRECT};

use super::sys::{LockGuard, alloc_forever, fatal, lock};

/// A VM function's run-time record: what `call.ext`/`call.ind`/`enter` need, with absolute
/// pointers. Site caches hold `*const Function`. Immutable once published.
#[repr(C)]
#[derive(Debug)]
pub struct Function {
    /// First instruction.
    pub code: *const u32,
    pub frame_size: u32,
    pub max_outgoing: u32,
    pub arg_size: u32,
    pub ret_size: u32,
    /// The function's image.
    pub img: *const ImageRt,
    /// The address of the function's portal, or null if it has none.
    pub portal: *const (),
}

/// A registered image: the reader view plus the absolute pointers the dispatch loop uses.
/// Immutable once published, except for the lazily built `funcs` table.
pub struct ImageRt {
    pub view: Image<'static>,
    /// The code array, and one past its end.
    pub code: *const u32,
    pub code_end: *const u32,
    pub syms: *const *const (),
    pub consts: *const u8,
    /// The image's function table.
    pub fentries: *const FuncEntry,
    pub nfuncs: u32,
    /// The site cache (`site_count` slots in the writable section).
    pub sites: *const AtomicPtr<Function>,
    /// Base of `data` operands.
    pub fixup_area: *mut u8,
    /// `[Function; nfuncs]`, built on first use (`funcs`), then never changed.
    funcs: AtomicPtr<Function>,
}

struct Snapshot {
    /// Images sorted by crate hash, for `enter`'s ID lookup.
    by_hash: *const *const ImageRt,
    /// The same images sorted by code address, for the pc → image map.
    by_code: *const *const ImageRt,
    n: usize,
    /// Portal address → function, built on the first `lookup_addr` against this snapshot.
    portals: AtomicPtr<PortalMap>,
}

/// An open-addressing hash table from portal address to function record.
struct PortalMap {
    mask: usize,
    /// `mask + 1` slots of (address, function); address 0 marks an empty slot.
    slots: *const (usize, *const Function),
}

static SNAPSHOT: AtomicPtr<Snapshot> = AtomicPtr::new(ptr::null_mut());

fn images(s: &Snapshot, sorted: *const *const ImageRt) -> &'static [&'static ImageRt] {
    // SAFETY: both arrays hold `n` pointers to published, never-freed ImageRts. A
    // `*const ImageRt` and a `&ImageRt` have the same layout.
    unsafe { core::slice::from_raw_parts(sorted.cast::<&'static ImageRt>(), s.n) }
}

fn snapshot() -> Option<&'static Snapshot> {
    // SAFETY: published snapshots are fully initialized before the Release store (paired with
    // this Acquire load), and never freed or mutated except through their atomics.
    unsafe { SNAPSHOT.load(Ordering::Acquire).as_ref() }
}

/// Registers `n` images whose headers are at `images[0..n]`. See [`super::ryo_vm_register`].
///
/// # Safety
/// As for `ryo_vm_register`.
pub unsafe fn register(headers: *const *const u8, n: usize) {
    let g = lock();
    let old: &[&ImageRt] = match snapshot() {
        Some(s) => images(s, s.by_hash),
        None => &[],
    };
    let cap = old.len() + n;
    let by_hash = alloc_forever(&g, cap * size_of::<*const ImageRt>(), align_of::<*const ImageRt>()).cast::<&ImageRt>();
    let by_code = alloc_forever(&g, cap * size_of::<*const ImageRt>(), align_of::<*const ImageRt>()).cast::<&ImageRt>();
    // SAFETY: fresh, suitably sized and aligned allocations. Elements are written before
    // they are viewed: `done(len)` covers only the first `len`, which are initialized.
    unsafe { ptr::copy_nonoverlapping(old.as_ptr(), by_hash, old.len()) };
    let done = |len: usize| -> &[&ImageRt] { unsafe { core::slice::from_raw_parts(by_hash, len) } };
    let mut len = old.len();
    for i in 0..n {
        // SAFETY: the caller passes `n` readable header pointers.
        let h = unsafe { *headers.add(i) };
        if done(len).iter().any(|im| ptr::eq(im.view.header(), h.cast())) {
            continue; // registered before (e.g. a library loaded twice)
        }
        // SAFETY: per the caller, `h` is a linked image's header, valid forever.
        let view = match unsafe { Image::from_header(h) } {
            Ok(v) => v,
            Err(_) => fatal("ryo_vm_register: invalid image (corrupt, or built by another ryo version)"),
        };
        let hdr = view.header();
        if let Some(o) = done(len).iter().find(|im| im.view.crate_hash() == view.crate_hash()) {
            if o.view.header().stable_crate_id == hdr.stable_crate_id {
                fatal("ryo_vm_register: a crate's image is registered twice (two copies of one crate)");
            }
            fatal("ryo_vm_register: crate hash collision between two images");
        }
        if view.data_ptr().is_null() && hdr.data_size != 0 {
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
        let code = view.code();
        let rt = ImageRt {
            view,
            code: code.as_ptr(),
            code_end: code.as_ptr_range().end,
            syms: view.symbols_ptr(),
            consts: view.consts().as_ptr(),
            fentries: view.functions().as_ptr(),
            nfuncs: view.functions().len() as u32,
            sites: view.site_cache().cast_const().cast(),
            fixup_area: view.fixup_area(),
            funcs: AtomicPtr::new(ptr::null_mut()),
        };
        let p = alloc_forever(&g, size_of::<ImageRt>(), align_of::<ImageRt>()).cast::<ImageRt>();
        // SAFETY: fresh allocation for one ImageRt; it is never freed, so `&'static` is valid.
        // `by_hash` has room for `cap > len` entries.
        unsafe {
            p.write(rt);
            by_hash.add(len).write(&*p);
        }
        len += 1;
    }
    if len == old.len() {
        return;
    }
    // SAFETY: the first `len` entries are initialized, and nothing else views them.
    let list = unsafe { core::slice::from_raw_parts_mut(by_hash, len) };
    sort_by_key(list, |im| im.view.crate_hash() as usize);
    // SAFETY: `by_code` has room for `cap >= len` entries.
    let codes = unsafe {
        ptr::copy_nonoverlapping(list.as_ptr(), by_code, len);
        core::slice::from_raw_parts_mut(by_code, len)
    };
    sort_by_key(codes, |im| im.code as usize);
    let snap = alloc_forever(&g, size_of::<Snapshot>(), align_of::<Snapshot>()).cast::<Snapshot>();
    // SAFETY: fresh allocation; fully written before it is published.
    unsafe {
        snap.write(Snapshot {
            by_hash: by_hash.cast(),
            by_code: by_code.cast(),
            n: len,
            portals: AtomicPtr::new(ptr::null_mut()),
        })
    };
    SNAPSHOT.store(snap, Ordering::Release);
}

/// The address a symbol slot designates: the slot value, or for indirect (PE `__imp_`) slots,
/// the value loaded through it.
/// An insertion sort: core's sorts reference its panic path (`panic_on_ord_violation`), which
/// the runtime must not reach (design/vm.md, "No re-entry"). Lists are short (one entry per
/// image).
fn sort_by_key(list: &mut [&ImageRt], key: impl Fn(&ImageRt) -> usize) {
    let p = list.as_mut_ptr();
    for i in 1..list.len() {
        let mut j = i;
        // SAFETY: `j` and `j - 1` are below `list.len()`.
        unsafe {
            while j > 0 && key(*p.add(j - 1)) > key(*p.add(j)) {
                ptr::swap(p.add(j - 1), p.add(j));
                j -= 1;
            }
        }
    }
}

fn sym_addr(img: &ImageRt, sym: u32) -> *const () {
    let (Some(&v), Some(&flags)) = (img.view.symbols().get(sym as usize), img.view.symbol_flags().get(sym as usize))
    else {
        fatal("symbol index out of range")
    };
    let v = v as usize as *const ();
    if flags & SYM_INDIRECT != 0 {
        // SAFETY: an indirect slot holds the address of a readable import slot.
        unsafe { *v.cast::<*const ()>() }
    } else {
        v
    }
}

impl ImageRt {
    /// The function records, building them on first use.
    pub fn funcs(&self) -> &'static [Function] {
        let mut f = self.funcs.load(Ordering::Acquire);
        if f.is_null() {
            let g = lock();
            f = self.build_funcs(&g);
        }
        // SAFETY: `f` points at `nfuncs` initialized records, published with Release.
        unsafe { core::slice::from_raw_parts(f, self.nfuncs as usize) }
    }

    fn build_funcs(&self, g: &LockGuard) -> *mut Function {
        let f = self.funcs.load(Ordering::Acquire);
        if !f.is_null() {
            return f;
        }
        let n = self.nfuncs as usize;
        let p = alloc_forever(g, n.max(1) * size_of::<Function>(), align_of::<Function>()).cast::<Function>();
        for (i, e) in self.view.functions().iter().enumerate() {
            let rec = Function {
                code: self.code.wrapping_add(e.code_off as usize),
                frame_size: e.frame_size,
                max_outgoing: e.max_outgoing,
                arg_size: e.arg_size,
                ret_size: e.ret_size,
                img: self,
                portal: e.portal().map_or(ptr::null(), |s| sym_addr(self, s)),
            };
            // SAFETY: `p` has room for `n` records.
            unsafe { p.add(i).write(rec) };
        }
        self.funcs.store(p, Ordering::Release);
        p
    }
}

/// Resolves a portal `ID` to its function record. Aborts if no registered image has that
/// crate hash or the index is out of range.
pub fn resolve_id(id: u64) -> &'static Function {
    let (hash, idx) = ryo_bytecode::image::split_portal_id(id);
    let Some(s) = snapshot() else { fatal("vm::enter: no images registered") };
    let list = images(s, s.by_hash);
    let Ok(i) = list.binary_search_by_key(&hash, |im| im.view.crate_hash()) else {
        fatal("vm::enter: the function's image is not registered")
    };
    match list[i].funcs().get(idx as usize) {
        Some(f) => f,
        None => fatal("vm::enter: function index out of range"),
    }
}

/// The image whose code contains `pc`. Aborts if there is none (a corrupt return pc).
#[cold]
pub fn image_of_pc(pc: *const u32) -> &'static ImageRt {
    if let Some(s) = snapshot() {
        let list = images(s, s.by_code);
        let i = list.partition_point(|im| im.code as usize <= pc as usize);
        if i > 0 && (pc as usize) < list[i - 1].code_end as usize {
            return list[i - 1];
        }
    }
    fatal("return address outside every registered image")
}

fn hash(addr: usize) -> usize {
    (addr.wrapping_mul(0x9E37_79B9_7F4A_7C15) >> 32) as usize
}

/// Maps a portal address to its VM function. `None` for every other address.
pub fn lookup_addr(addr: *const ()) -> Option<&'static Function> {
    let s = snapshot()?;
    let mut m = s.portals.load(Ordering::Acquire);
    if m.is_null() {
        m = build_portal_map(s);
    }
    // SAFETY: published maps are immutable and never freed.
    let m = unsafe { &*m };
    let a = addr as usize;
    if a == 0 {
        return None;
    }
    let mut i = hash(a) & m.mask;
    loop {
        // SAFETY: `i <= mask`, within the `mask + 1` slots.
        let (k, f) = unsafe { *m.slots.add(i) };
        if k == a {
            // SAFETY: entries point at published function records.
            return Some(unsafe { &*f });
        }
        if k == 0 {
            return None;
        }
        i = (i + 1) & m.mask;
    }
}

#[cold]
#[inline(never)]
fn build_portal_map(s: &Snapshot) -> *mut PortalMap {
    let g = lock();
    let m = s.portals.load(Ordering::Acquire);
    if !m.is_null() {
        return m;
    }
    let list = images(s, s.by_hash);
    let mut count = 0usize;
    for im in list {
        let fp = im.build_funcs(&g);
        // SAFETY: just built or published, `nfuncs` records.
        let fs = unsafe { core::slice::from_raw_parts(fp, im.nfuncs as usize) };
        count += fs.iter().filter(|f| !f.portal.is_null()).count();
    }
    let cap = (count * 2).next_power_of_two().max(8);
    let slots = alloc_forever(&g, cap * size_of::<(usize, *const Function)>(), align_of::<usize>())
        .cast::<(usize, *const Function)>();
    // SAFETY: the allocation is zeroed (address 0 = empty) and has `cap` slots; the function
    // tables were built above.
    unsafe {
        for im in list {
            for f in core::slice::from_raw_parts(im.funcs.load(Ordering::Relaxed), im.nfuncs as usize) {
                let a = f.portal as usize;
                if a == 0 {
                    continue;
                }
                let mut i = hash(a) & (cap - 1);
                while (*slots.add(i)).0 != 0 && (*slots.add(i)).0 != a {
                    i = (i + 1) & (cap - 1);
                }
                slots.add(i).write((a, f));
            }
        }
    }
    let p = alloc_forever(&g, size_of::<PortalMap>(), align_of::<PortalMap>()).cast::<PortalMap>();
    // SAFETY: fresh allocation, written before publication.
    unsafe { p.write(PortalMap { mask: cap - 1, slots }) };
    s.portals.store(p, Ordering::Release);
    p
}
