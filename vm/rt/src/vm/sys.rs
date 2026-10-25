//! OS services for the VM: page mappings (through `ryo_bytecode::vmem`), fatal errors, the
//! runtime lock, and a bump allocator.
//!
//! Everything here uses `core` and direct OS calls only (libc on ELF, kernel32 on PE). Under
//! `--sysroot ryo`, std's allocator, `Mutex` and I/O may be VM functions, so the runtime must
//! not call them while it sets up or switches VM state (design/vm.md, "No re-entry into the
//! VM from the runtime").

use core::ptr;
use core::sync::atomic::{AtomicBool, Ordering};

use ryo_bytecode::vmem;

/// Page size for guard pages and mapping granularity ([`vmem::PAGE`]).
pub const PAGE: usize = vmem::PAGE;

#[cfg(unix)]
mod os {
    use core::ffi::{c_int, c_void};

    unsafe extern "C" {
        pub fn write(fd: c_int, buf: *const c_void, n: usize) -> isize;
        pub fn abort() -> !;
    }
}

#[cfg(windows)]
mod os {
    use core::ffi::c_void;

    pub const STD_ERROR_HANDLE: u32 = -12i32 as u32;

    #[link(name = "kernel32")]
    unsafe extern "system" {
        pub fn GetStdHandle(which: u32) -> *mut c_void;
        pub fn WriteFile(h: *mut c_void, buf: *const u8, n: u32, written: *mut u32, ov: *mut c_void) -> i32;
    }
}

/// Writes `ryo: <msg>` to stderr and aborts the process. For conditions native Rust also
/// aborts on (stack overflow, panic in a no-unwind function) and for corrupt images.
#[cold]
#[inline(never)]
pub fn fatal(msg: &str) -> ! {
    write_stderr("ryo: ");
    write_stderr(msg);
    write_stderr("\n");
    abort()
}

fn write_stderr(s: &str) {
    #[cfg(unix)]
    // SAFETY: `s` is valid for `s.len()` bytes. Errors are ignored: we are about to abort.
    unsafe {
        os::write(2, s.as_ptr().cast(), s.len());
    }
    #[cfg(windows)]
    // SAFETY: as above; a null handle makes WriteFile fail harmlessly.
    unsafe {
        let mut n = 0;
        os::WriteFile(os::GetStdHandle(os::STD_ERROR_HANDLE), s.as_ptr(), s.len() as u32, &mut n, ptr::null_mut());
    }
}

fn abort() -> ! {
    #[cfg(unix)]
    // SAFETY: always safe to call.
    unsafe {
        os::abort()
    }
    #[cfg(windows)]
    core::intrinsics::abort()
}

/// Maps `len` bytes (a multiple of [`PAGE`]) of zeroed read-write memory, page-aligned. The
/// last `guard` bytes (a multiple of [`PAGE`]) are made inaccessible. Aborts on failure.
pub fn map(len: usize, guard: usize) -> *mut u8 {
    debug_assert!(len % PAGE == 0 && guard % PAGE == 0 && guard < len);
    let Some(p) = vmem::reserve(0, len) else { fatal("out of memory mapping VM memory") };
    // SAFETY: the guard covers only the end of the new mapping, which nothing uses yet.
    if guard != 0 && !unsafe { vmem::guard(p.add(len - guard), guard) } {
        fatal("protecting a guard page failed");
    }
    p
}

/// The runtime's lock: a spin lock on one `AtomicBool`. It is only taken on cold paths
/// (registration, lazy table builds, first-use setup) and never held while running bytecode
/// or native code, so contention is short.
static LOCK: AtomicBool = AtomicBool::new(false);

pub struct LockGuard(());

/// Takes the runtime lock until the guard is dropped. Not re-entrant.
pub fn lock() -> LockGuard {
    while LOCK.compare_exchange_weak(false, true, Ordering::Acquire, Ordering::Relaxed).is_err() {
        while LOCK.load(Ordering::Relaxed) {
            core::hint::spin_loop();
        }
    }
    LockGuard(())
}

impl Drop for LockGuard {
    fn drop(&mut self) {
        LOCK.store(false, Ordering::Release);
    }
}

/// Bump allocator state: the current chunk's free range. Only touched under the lock.
struct Bump {
    cur: *mut u8,
    end: *mut u8,
}

static mut BUMP: Bump = Bump { cur: ptr::null_mut(), end: ptr::null_mut() };

const CHUNK: usize = 64 * 1024;

/// Allocates `size` bytes aligned to `align` (≤ [`PAGE`]) that are never freed. The memory is
/// zeroed. For registry snapshots and tables, which live for the rest of the process.
pub fn alloc_forever(_g: &LockGuard, size: usize, align: usize) -> *mut u8 {
    debug_assert!(align.is_power_of_two() && align <= PAGE);
    // SAFETY: BUMP is only accessed here, and the caller holds the lock (`_g`), so there is
    // no concurrent access; it is accessed through a raw pointer, never a long-lived `&mut`.
    unsafe {
        let b = &raw mut BUMP;
        let start = ((*b).cur as usize + align - 1) & !(align - 1);
        if (*b).cur.is_null() || start + size > (*b).end as usize {
            let len = (size + PAGE - 1) / PAGE * PAGE;
            if len > CHUNK / 2 {
                // Large requests get their own mapping (page-aligned).
                return map(len + PAGE, PAGE);
            }
            let c = map(CHUNK, 0);
            (*b).cur = c;
            (*b).end = c.add(CHUNK);
            return alloc_forever(_g, size, align);
        }
        let p = (*b).cur.add(start - (*b).cur as usize);
        (*b).cur = p.add(size);
        p
    }
}
