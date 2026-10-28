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
//! find no free page stay private instances, as does every copy under `RYO_JIT_MERGE=0`.
//!
//! The rendezvous: a page at a fixed address derived from the tag, mapped exclusively
//! (Linux `MAP_FIXED_NOREPLACE`, macOS `mach_vm_allocate` without `VM_FLAGS_ANYWHERE`), or a
//! named file mapping `Local\ryo-<pid>-<tag hash>` on Windows. A taken address is read only
//! through a call that fails on an unreadable one (`process_vm_readv`, `mach_vm_read_overwrite`)
//! and used only with this build's magic and tag.

use core::sync::atomic::Ordering::{Acquire, Release};
use core::sync::atomic::{AtomicU32, AtomicUsize};

/// A registration function: `ryo_vm_register` (`C-unwind`, but it never unwinds), called as
/// `C`: a call through a `C-unwind` pointer would make `ryo_rt` require `panic=unwind`.
pub(crate) type RegisterFn = unsafe extern "C" fn(*const *const u8, *const *const u8, *const u8);

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
const PAGE_SIZE: usize = 4096;

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
    let Some(page) = rendezvous() else { return PRIVATE };
    let (page, won) = page;
    if won {
        // SAFETY: a fresh page of ours, not yet READY, so no other copy reads the fields.
        unsafe {
            (*page).abi = ryo_bytecode::ABI;
            (*page).personality = personality;
            (*page).register = own;
            (*page).magic = MAGIC;
            (*page).state.store(READY, Release);
        }
        return PRIVATE;
    }
    // SAFETY: a mapped page with this build's magic and tag (checked by `rendezvous`).
    let page = unsafe { &*page };
    let mut spins = 0u32;
    while page.state.load(Acquire) != READY {
        spins += 1;
        if spins > 100_000_000 {
            return PRIVATE; // a winner that never finished; stay correct, unmerged
        }
        core::hint::spin_loop();
    }
    if page.personality != personality || page.register == own {
        return PRIVATE;
    }
    page.register
}

/// The probe addresses of the rendezvous page (Linux and macOS): in a high range, by the tag.
#[cfg(unix)]
fn probe(i: usize) -> usize {
    const BASE: usize = 0x7e00_0000_0000;
    const SLOTS: usize = 1 << 12;
    BASE + ((ryo_bytecode::ABI as usize ^ i.wrapping_mul(0x9e37_79b9)) % SLOTS) * (1 << 16)
}

/// Maps or finds the rendezvous page: `(page, true)` if this copy mapped it (the winner),
/// `(page, false)` for another copy's with this build's magic and tag (possibly still being
/// initialized), `None` if no probe worked.
#[cfg(target_os = "linux")]
fn rendezvous() -> Option<(*mut Page, bool)> {
    use core::ffi::{c_int, c_long, c_void};
    #[repr(C)]
    struct IoVec {
        base: *mut c_void,
        len: usize,
    }
    unsafe extern "C" {
        fn mmap(addr: *mut c_void, len: usize, prot: c_int, flags: c_int, fd: c_int, off: i64) -> *mut c_void;
        fn munmap(addr: *mut c_void, len: usize) -> c_int;
        fn process_vm_readv(pid: c_int, local: *const IoVec, ln: c_long, remote: *const IoVec, rn: c_long, flags: c_long) -> isize;
        fn getpid() -> c_int;
    }
    const PROT_RW: c_int = 0x1 | 0x2;
    const MAP_PRIVATE_ANON: c_int = 0x02 | 0x20;
    const MAP_FIXED_NOREPLACE: c_int = 0x10_0000;
    for i in 0..8 {
        let at = probe(i);
        // SAFETY: an exclusive mapping request; it never replaces an existing mapping.
        let p = unsafe { mmap(at as *mut c_void, PAGE_SIZE, PROT_RW, MAP_PRIVATE_ANON | MAP_FIXED_NOREPLACE, -1, 0) };
        if p as usize == at {
            return Some((p.cast(), true));
        }
        if p as isize != -1 {
            // A kernel before 4.17 took the address as a hint: not ours to use.
            // SAFETY: the mapping just made.
            unsafe { munmap(p, PAGE_SIZE) };
            continue;
        }
        let mut head = [0u64; 2];
        let local = IoVec { base: head.as_mut_ptr().cast(), len: 16 };
        let remote = IoVec { base: at as *mut c_void, len: 16 };
        // SAFETY: reads 16 bytes of this process, failing (not faulting) where unreadable.
        let n = unsafe { process_vm_readv(getpid(), &local, 1, &remote, 1, 0) };
        if n == 16 && is_ours(head) {
            return Some((at as *mut Page, false));
        }
    }
    None
}

#[cfg(target_vendor = "apple")]
fn rendezvous() -> Option<(*mut Page, bool)> {
    unsafe extern "C" {
        static mach_task_self_: u32;
        fn mach_vm_allocate(task: u32, addr: *mut u64, size: u64, flags: i32) -> i32;
        fn mach_vm_read_overwrite(task: u32, addr: u64, size: u64, data: u64, out: *mut u64) -> i32;
    }
    for i in 0..8 {
        let at = probe(i) as u64;
        let mut addr = at;
        // SAFETY: plain Mach calls on this task; `VM_FLAGS_FIXED` (0) fails on a taken range.
        unsafe {
            let task = mach_task_self_;
            if mach_vm_allocate(task, &mut addr, PAGE_SIZE as u64, 0) == 0 {
                return Some((at as *mut Page, true));
            }
            let mut head = [0u64; 2];
            let mut n = 0u64;
            if mach_vm_read_overwrite(task, at, 16, head.as_mut_ptr() as u64, &mut n) == 0 && n == 16 && is_ours(head) {
                return Some((at as *mut Page, false));
            }
        }
    }
    None
}

#[cfg(windows)]
fn rendezvous() -> Option<(*mut Page, bool)> {
    use core::ffi::c_void;
    #[link(name = "kernel32")]
    unsafe extern "system" {
        fn CreateFileMappingW(file: *mut c_void, attrs: *mut c_void, protect: u32, hi: u32, lo: u32, name: *const u16) -> *mut c_void;
        fn MapViewOfFile(map: *mut c_void, access: u32, hi: u32, lo: u32, len: usize) -> *mut c_void;
        fn GetLastError() -> u32;
    }
    // `Local\ryo-<pid>-<abi>`, in UTF-16.
    let mut name = [0u16; 64];
    let mut n = 0;
    let mut put = |c: u8| {
        name[n] = c as u16;
        n += 1;
    };
    b"Local\\ryo-".iter().for_each(|&c| put(c));
    let hex = |put: &mut dyn FnMut(u8), v: u64, digits: u32| {
        for d in (0..digits).rev() {
            put(b"0123456789abcdef"[(v >> (d * 4)) as usize & 15]);
        }
    };
    hex(&mut put, super::super::sys::pid() as u64, 8);
    put(b'-');
    hex(&mut put, ryo_bytecode::ABI, 16);
    // SAFETY: plain kernel32 calls; the mapping (pagefile-backed, zeroed) is never closed.
    unsafe {
        let h = CreateFileMappingW(-1isize as *mut c_void, core::ptr::null_mut(), 0x04, 0, PAGE_SIZE as u32, name.as_ptr());
        if h.is_null() {
            return None;
        }
        let created = GetLastError() != 183; // ERROR_ALREADY_EXISTS
        let p = MapViewOfFile(h, 0x0002 | 0x0004, 0, 0, PAGE_SIZE); // FILE_MAP_WRITE | FILE_MAP_READ
        if p.is_null() {
            return None;
        }
        Some((p.cast(), created))
    }
}

#[cfg(not(any(target_os = "linux", target_vendor = "apple", windows)))]
fn rendezvous() -> Option<(*mut Page, bool)> {
    None
}

/// Whether a page's first 16 bytes are this build's: our magic and tag, or zero (a winner
/// still writing them, which publishes `magic` last).
#[cfg(unix)]
fn is_ours(head: [u64; 2]) -> bool {
    (head[0] == MAGIC && head[1] == ryo_bytecode::ABI) || head == [0, 0] || (head[0] == 0 && head[1] == ryo_bytecode::ABI)
}
