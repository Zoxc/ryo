//! OS services for the VM: page mappings (through `ryo_bytecode::vmem`), fatal errors, the
//! runtime lock, and a bump allocator.
//!
//! Everything here uses `core` and direct OS calls only (libc on ELF, kernel32 on PE). Under
//! `--sysroot ryo`, std's allocator, `Mutex` and I/O may be VM functions, so the runtime must
//! not call them while it sets up or switches VM state (design/vm.md, "No re-entry into the
//! VM from the runtime").

use core::cell::UnsafeCell;
use core::ops::{Deref, DerefMut};
use core::ptr;
use core::sync::atomic::{AtomicBool, Ordering};

use ryo_bytecode::vmem;

/// Page size for guard pages and mapping granularity ([`vmem::PAGE`]).
const PAGE: usize = vmem::PAGE;

#[cfg(unix)]
mod os {
    use core::ffi::{c_int, c_void};

    unsafe extern "C" {
        pub fn write(fd: c_int, buf: *const c_void, n: usize) -> isize;
        pub fn abort() -> !;
        pub fn getpid() -> c_int;
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
        pub fn GetCurrentProcessId() -> u32;
    }
}

/// Writes `ryo: <msg>` to stderr and aborts the process. For conditions native Rust also
/// aborts on (stack overflow, panic in a no-unwind function) and for corrupt images.
#[cold]
#[inline(never)]
pub fn fatal(msg: &str) -> ! {
    write_stderr(b"ryo: ");
    write_stderr(msg.as_bytes());
    write_stderr(b"\n");
    abort()
}

/// Writes `s` to stderr with one `write`, ignoring errors.
pub(crate) fn write_stderr(s: &[u8]) {
    #[cfg(unix)]
    // SAFETY: `s` is valid for `s.len()` bytes. Errors are ignored.
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

/// The process's id.
pub(crate) fn pid() -> u32 {
    #[cfg(unix)]
    // SAFETY: always safe to call.
    unsafe {
        os::getpid() as u32
    }
    #[cfg(windows)]
    // SAFETY: always safe to call.
    unsafe {
        os::GetCurrentProcessId()
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
fn map(len: usize, guard: usize) -> *mut u8 {
    debug_assert!(len % PAGE == 0 && guard % PAGE == 0 && guard < len);
    let Some(p) = vmem::reserve(0, len) else { fatal("out of memory mapping VM memory") };
    // SAFETY: the guard covers only the end of the new mapping, which nothing uses yet.
    if guard != 0 && !unsafe { vmem::guard(p.add(len - guard), guard) } {
        fatal("protecting a guard page failed");
    }
    p
}

/// The runtime's lock: a spin lock on one `AtomicBool` that owns the state it guards. It is
/// only taken on cold paths (registration, lazy table builds, first-use setup) and never held
/// while running bytecode or native code, so contention is short.
struct SpinLock<T> {
    locked: AtomicBool,
    data: UnsafeCell<T>,
}

// SAFETY: `data` is only reached through a `LockGuard`, and at most one exists at a time.
unsafe impl<T: Send> Sync for SpinLock<T> {}

static RT: SpinLock<Bump> = SpinLock { locked: AtomicBool::new(false), data: UnsafeCell::new(Bump::EMPTY) };

/// Holds the runtime lock until dropped; derefs to the state it guards.
pub struct LockGuard<'a>(&'a SpinLock<Bump>);

/// Takes the runtime lock until the guard is dropped. Not re-entrant.
pub fn lock() -> LockGuard<'static> {
    while RT.locked.compare_exchange_weak(false, true, Ordering::Acquire, Ordering::Relaxed).is_err() {
        while RT.locked.load(Ordering::Relaxed) {
            core::hint::spin_loop();
        }
    }
    LockGuard(&RT)
}

impl Deref for LockGuard<'_> {
    type Target = Bump;
    fn deref(&self) -> &Bump {
        // SAFETY: the guard holds the lock, so nothing else accesses `data`.
        unsafe { &*self.0.data.get() }
    }
}

impl DerefMut for LockGuard<'_> {
    fn deref_mut(&mut self) -> &mut Bump {
        // SAFETY: as for `deref`; `&mut self` makes this the only borrow through the guard.
        unsafe { &mut *self.0.data.get() }
    }
}

impl Drop for LockGuard<'_> {
    fn drop(&mut self) {
        self.0.locked.store(false, Ordering::Release);
    }
}

/// Bump allocator state: the current chunk's free range. Owned by the runtime lock.
pub struct Bump {
    cur: *mut u8,
    end: *mut u8,
}

// SAFETY: the pointers are to process-lifetime mappings, usable from any thread.
unsafe impl Send for Bump {}

const CHUNK: usize = 64 * 1024;

impl Bump {
    const EMPTY: Bump = Bump { cur: ptr::null_mut(), end: ptr::null_mut() };

    /// Allocates `size` bytes aligned to `align` (≤ [`PAGE`]) that are never freed. The
    /// memory is zeroed. For registry snapshots and tables, which live for the rest of the
    /// process.
    pub fn alloc_forever(&mut self, size: usize, align: usize) -> *mut u8 {
        debug_assert!(align.is_power_of_two() && align <= PAGE);
        loop {
            let start = (self.cur as usize + align - 1) & !(align - 1);
            if !self.cur.is_null() && start + size <= self.end as usize {
                let p = self.cur.wrapping_add(start - self.cur as usize);
                self.cur = p.wrapping_add(size);
                return p;
            }
            let len = size.next_multiple_of(PAGE);
            if len > CHUNK / 2 {
                // Large requests get their own mapping (page-aligned).
                return map(len + PAGE, PAGE);
            }
            let c = map(CHUNK, 0);
            self.cur = c;
            self.end = c.wrapping_add(CHUNK);
        }
    }
}
