//! Merging same-build runtime copies in one process (design/vm.md#several-ryo-runtimes-in-one-process).
//!
//! Every final artifact links a private copy of `ryo_rt` (the backend's
//! `dylib_dependency_formats`), so an executable and its Rust dylibs each have one. Copies of
//! one ryo build (same ABI tag) whose program shares one panic personality (one std, e.g.
//! `libstd-*.so`) merge into one instance: the first copy to get here, the winner, publishes
//! its registration function in a rendezvous page; every other copy forwards its
//! registrations there ([`forward`]). The winner's registration points the images' JIT
//! records at its own trips ([`super::registered`]), so the winner's registry, queue, JIT
//! thread and code allocator serve them all, and the losers' JITs never start. Handlers keep
//! no state, so images keep calling their own copy's.
//!
//! Copies with another personality (a cdylib's own std, a localized staticlib blob) or that
//! find no free page, or a page that isn't this build's, stay private instances, as does every copy under `RYO_JIT_MERGE=0`.
//!
//! The rendezvous: a page at a fixed address derived from the tag, mapped exclusively
//! (Linux `MAP_FIXED_NOREPLACE`, macOS `mach_vm_allocate` without `VM_FLAGS_ANYWHERE`, Windows
//! `VirtualAlloc` at an address), so it is private to the process: no named object another
//! user could create first. A taken address is read only through a call that fails on an
//! unreadable one (`process_vm_readv`, `mach_vm_read_overwrite`, `ReadProcessMemory`), and
//! used only once READY with this build's magic and tag ([`join`]), after a bounded wait.
//! Both sides pin their module when they merge: the winner's registration function and
//! the joiners' images are used for the rest of the process.

use core::sync::atomic::Ordering::{Acquire, Release};
use core::sync::atomic::{AtomicU32, AtomicUsize};
use ryo_bytecode::vmem::PAGE;

use super::super::RegisterFn;

#[repr(C)]
struct Page {
    magic: u64,
    abi: u64,
    /// The winner's `rust_eh_personality`: only copies with the same one join.
    personality: usize,
    /// [`READY`] once the fields are written.
    state: AtomicU32,
    /// The winner's registration function, [`RegisterFn`].
    register: usize,
}

const MAGIC: u64 = u64::from_le_bytes(*b"RYOMERGE");
const READY: u32 = 1;

/// What this copy decided: [`UNDECIDED`], [`PRIVATE`] (this copy is its own instance: the
/// winner, or not merged), or the winner's [`RegisterFn`].
static TARGET: AtomicUsize = AtomicUsize::new(UNDECIDED);
const UNDECIDED: usize = 0;
const PRIVATE: usize = 1;

/// The winner's registration function if this copy forwards to another copy, else `None`
/// (this copy is an instance of its own). Decided once, at the first call.
pub(crate) fn forward() -> Option<RegisterFn> {
    let t = match TARGET.load(Acquire) {
        UNDECIDED => {
            let t = decide();
            // Two threads of one copy may race here; the rendezvous gives both the same answer.
            TARGET.store(t, Release);
            t
        }
        t => t,
    };
    // SAFETY: a `RegisterFn` stored by `decide`.
    (t != PRIVATE).then(|| unsafe { core::mem::transmute::<usize, RegisterFn>(t) })
}

fn decide() -> usize {
    if super::var(c"RYO_JIT_MERGE") == Some(b"0") {
        return PRIVATE;
    }
    let personality = super::rust_eh_personality as *const () as usize;
    let own = super::super::ryo_vm_register as *const () as usize;
    let Some((page, won)) = rendezvous() else { return PRIVATE };
    if won {
        // The page names this module's registration function for the rest of the process,
        // and other copies' images end up in its registry: pin it.
        super::super::sys::pin_module(own as *const ());
        // SAFETY: a fresh page of ours, not yet READY, so no other copy reads the fields.
        unsafe { publish(page, personality, own) };
        return PRIVATE;
    }
    // SAFETY: a mapped page whose head looked like this build's (checked by `rendezvous`).
    let t = join(unsafe { &*page }, personality, own, SPINS);
    if t != PRIVATE {
        // This module's images (headers, slots) now live in the winner's registry: pin it.
        super::super::sys::pin_module(own as *const ());
    }
    t
}

/// How long a joiner waits for a winner to publish (it does so right after mapping the page);
/// past that, or for a page that stays foreign, it stays private, which is always correct.
const SPINS: u32 = 1 << 20;

/// Fills in a winner's page and marks it [`READY`].
///
/// # Safety
/// `page` is a writable [`Page`] that no other copy reads before it is `READY`.
unsafe fn publish(page: *mut Page, personality: usize, own: usize) {
    // SAFETY: per the contract.
    unsafe {
        (*page).abi = ryo_bytecode::ABI;
        (*page).personality = personality;
        (*page).register = own;
        (*page).magic = MAGIC;
        (*page).state.store(READY, Release);
    }
}

/// A joiner's decision on a page another copy mapped: the winner's registration function, or
/// [`PRIVATE`] unless the page becomes READY within `spins` with this build's magic and tag
/// and the same personality. The page may be anything (a foreign zero page, another tag's
/// winner caught mid-write): nothing in it is used before that check.
fn join(page: &Page, personality: usize, own: usize, spins: u32) -> usize {
    let mut n = 0u32;
    while page.state.load(Acquire) != READY {
        n += 1;
        if n > spins {
            return PRIVATE;
        }
        core::hint::spin_loop();
    }
    // The fields were written before the Release store of READY.
    if page.magic != MAGIC || page.abi != ryo_bytecode::ABI || page.personality != personality || page.register == own || page.register == 0 {
        return PRIVATE;
    }
    page.register
}

/// The probe addresses of the rendezvous page: in a high range (64 KiB aligned, Windows'
/// allocation granularity), by the tag.
fn probe(i: usize) -> usize {
    const BASE: usize = 0x7e00_0000_0000;
    const SLOTS: usize = 1 << 12;
    BASE + ((ryo_bytecode::ABI as usize ^ i.wrapping_mul(0x9e37_79b9)) % SLOTS) * (1 << 16)
}

/// Maps or finds the rendezvous page: `(page, true)` if this copy mapped it (the winner),
/// `(page, false)` for another copy's with this build's magic and tag (possibly still being
/// initialized), `None` if no probe worked.
fn rendezvous() -> Option<(*mut Page, bool)> {
    use ryo_bytecode::vmem;
    for i in 0..8 {
        let at = probe(i);
        // An exclusive mapping at `at`: `MAP_FIXED_NOREPLACE` on Linux, `VirtualAlloc` at an
        // address on Windows, both failing on a taken range.
        if let Some(p) = vmem::reserve(at, PAGE) {
            if p as usize == at {
                return Some((p.cast(), true));
            }
            // The address was taken as a hint (Apple, or Linux before 4.17), so it is taken:
            // not ours to use, but maybe another copy's.
            // SAFETY: the mapping just made.
            unsafe { vmem::release(p, PAGE) };
        }
        if super::super::sys::read_head(at).is_some_and(is_ours) {
            return Some((at as *mut Page, false));
        }
    }
    None
}

/// Whether a page's first 16 bytes are this build's: our magic and tag, or zero (a winner
/// still writing them, which publishes `magic` last). Only a filter: [`join`] checks again.
fn is_ours(head: [u64; 2]) -> bool {
    head == [MAGIC, ryo_bytecode::ABI] || (head[0] == 0 && (head[1] == 0 || head[1] == ryo_bytecode::ABI))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn page(magic: u64, abi: u64, personality: usize, state: u32, register: usize) -> Page {
        Page { magic, abi, personality, state: AtomicU32::new(state), register }
    }

    const ABI: u64 = ryo_bytecode::ABI;

    #[test]
    fn joins_a_published_page() {
        let mut p = page(0, 0, 0, 0, 0);
        // SAFETY: a local page.
        unsafe { publish(&mut p, 7, 0x1000) };
        assert_eq!(join(&p, 7, 0x2000, 10), 0x1000);
        assert_eq!(join(&page(MAGIC, ABI, 7, READY, 0x1000), 7, 0x2000, 10), 0x1000);
    }

    #[test]
    fn stays_private_on_foreign_pages() {
        // A foreign zero page that never becomes READY: a bounded wait.
        assert_eq!(join(&page(0, 0, 0, 0, 0), 7, 0x2000, 1000), PRIVATE);
        // READY but not this build's: no magic, another tag, or another tag's winner caught
        // while its head was still zero.
        assert_eq!(join(&page(0, 0, 7, READY, 0x1000), 7, 0x2000, 10), PRIVATE);
        assert_eq!(join(&page(MAGIC, ABI ^ 1, 7, READY, 0x1000), 7, 0x2000, 10), PRIVATE);
        assert_eq!(join(&page(0, ABI, 7, READY, 0x1000), 7, 0x2000, 10), PRIVATE);
        // Another personality, this copy's own page, or no function.
        assert_eq!(join(&page(MAGIC, ABI, 8, READY, 0x1000), 7, 0x2000, 10), PRIVATE);
        assert_eq!(join(&page(MAGIC, ABI, 7, READY, 0x2000), 7, 0x2000, 10), PRIVATE);
        assert_eq!(join(&page(MAGIC, ABI, 7, READY, 0), 7, 0x2000, 10), PRIVATE);
    }

    #[test]
    fn probe_filter() {
        assert!(is_ours([MAGIC, ABI]));
        assert!(is_ours([0, 0]));
        assert!(is_ours([0, ABI]));
        assert!(!is_ours([MAGIC, ABI ^ 1]));
        assert!(!is_ours([1, 0]));
    }
}
