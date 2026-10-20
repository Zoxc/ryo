//! OS services for the VM: page mappings, fatal errors, the runtime lock, and a bump allocator.
//!
//! Everything here uses `core` and direct OS calls only (libc on ELF, kernel32 on PE). Under
//! `--sysroot ryo`, std's allocator, `Mutex` and I/O may be VM functions, so the runtime must
//! not call them while it sets up or switches VM state (design/vm.md, "No re-entry into the
//! VM from the runtime").

use core::ffi::c_void;
use core::ptr;
use core::sync::atomic::{AtomicBool, AtomicU8, AtomicUsize, Ordering};

/// Page size assumed for guard pages and mapping granularity (x86_64 ELF and PE).
pub const PAGE: usize = 4096;

#[cfg(unix)]
mod os {
    use core::ffi::{c_int, c_void};

    pub const PROT_NONE: c_int = 0;
    pub const PROT_READ: c_int = 1;
    pub const PROT_WRITE: c_int = 2;
    pub const MAP_PRIVATE: c_int = 0x02;
    pub const MAP_ANONYMOUS: c_int = 0x20;
    pub const MAP_NORESERVE: c_int = 0x4000;
    pub const MAP_FAILED: *mut c_void = !0usize as *mut c_void;

    unsafe extern "C" {
        pub fn mmap(addr: *mut c_void, len: usize, prot: c_int, flags: c_int, fd: c_int, off: i64) -> *mut c_void;
        pub fn munmap(addr: *mut c_void, len: usize) -> c_int;
        pub fn mprotect(addr: *mut c_void, len: usize, prot: c_int) -> c_int;
        pub fn write(fd: c_int, buf: *const c_void, n: usize) -> isize;
        pub fn abort() -> !;
        pub fn getenv(name: *const core::ffi::c_char) -> *const core::ffi::c_char;
        pub fn pthread_key_create(key: *mut u32, dtor: Option<unsafe extern "C" fn(*mut c_void)>) -> c_int;
        pub fn pthread_setspecific(key: u32, value: *const c_void) -> c_int;
    }
}

#[cfg(windows)]
mod os {
    use core::ffi::c_void;

    pub const MEM_COMMIT: u32 = 0x1000;
    pub const MEM_RESERVE: u32 = 0x2000;
    pub const MEM_RELEASE: u32 = 0x8000;
    pub const PAGE_NOACCESS: u32 = 0x01;
    pub const PAGE_READWRITE: u32 = 0x04;
    pub const STD_ERROR_HANDLE: u32 = -12i32 as u32;
    pub const FLS_OUT_OF_INDEXES: u32 = u32::MAX;

    #[link(name = "kernel32")]
    unsafe extern "system" {
        pub fn VirtualAlloc(addr: *mut c_void, size: usize, ty: u32, protect: u32) -> *mut c_void;
        pub fn VirtualFree(addr: *mut c_void, size: usize, ty: u32) -> i32;
        pub fn VirtualProtect(addr: *mut c_void, size: usize, protect: u32, old: *mut u32) -> i32;
        pub fn GetStdHandle(which: u32) -> *mut c_void;
        pub fn WriteFile(h: *mut c_void, buf: *const u8, n: u32, written: *mut u32, ov: *mut c_void) -> i32;
        pub fn FlsAlloc(cb: Option<unsafe extern "system" fn(*const c_void)>) -> u32;
        pub fn FlsSetValue(index: u32, value: *const c_void) -> i32;
        pub fn GetEnvironmentVariableA(name: *const u8, buf: *mut u8, size: u32) -> u32;
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

/// Whether `RYO_VM_TRACE` is set (to anything): then [`trace_enter`] reports every
/// `vm::enter` on stderr, which lets tests check that code really ran in the VM. Read once.
#[inline]
pub fn trace_enabled() -> bool {
    // 0: not read yet, 1: off, 2: on.
    static TRACE: AtomicU8 = AtomicU8::new(0);
    match TRACE.load(Ordering::Relaxed) {
        0 => {
            let on = env_set(c"RYO_VM_TRACE");
            TRACE.store(if on { 2 } else { 1 }, Ordering::Relaxed);
            on
        }
        v => v == 2,
    }
}

#[cold]
fn env_set(name: &core::ffi::CStr) -> bool {
    #[cfg(unix)]
    // SAFETY: `name` is NUL-terminated; the result is only compared with null.
    unsafe {
        !os::getenv(name.as_ptr()).is_null()
    }
    #[cfg(windows)]
    // SAFETY: as above; a zero-sized buffer only queries the length (0: not set).
    unsafe {
        os::GetEnvironmentVariableA(name.as_ptr().cast(), ptr::null_mut(), 0) != 0
    }
}

/// Writes `ryo-vm: enter <crate hash>:<function index>` to stderr.
#[cold]
#[inline(never)]
pub fn trace_enter(id: u64) {
    let mut buf = *b"ryo-vm: enter 00000000:00000000\n";
    for i in 0..8 {
        let hex = |v: u64| b"0123456789abcdef"[(v & 15) as usize];
        buf[14 + i] = hex(id >> (60 - 4 * i));
        buf[23 + i] = hex(id >> (28 - 4 * i));
    }
    // SAFETY: the buffer is ASCII.
    write_stderr(unsafe { core::str::from_utf8_unchecked(&buf) });
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
    #[cfg(unix)]
    // SAFETY: an anonymous private mapping at a kernel-chosen address touches no existing
    // memory. `mprotect` only covers the end of the new mapping.
    unsafe {
        let p = os::mmap(
            ptr::null_mut(),
            len,
            os::PROT_READ | os::PROT_WRITE,
            os::MAP_PRIVATE | os::MAP_ANONYMOUS | os::MAP_NORESERVE,
            -1,
            0,
        );
        if p == os::MAP_FAILED {
            fatal("out of memory mapping VM memory");
        }
        if guard != 0 && os::mprotect(p.cast::<u8>().add(len - guard).cast(), guard, os::PROT_NONE) != 0 {
            fatal("mprotect failed");
        }
        p.cast()
    }
    #[cfg(windows)]
    // SAFETY: a fresh allocation at a system-chosen address; `VirtualProtect` only covers its
    // end.
    unsafe {
        let p = os::VirtualAlloc(ptr::null_mut(), len, os::MEM_RESERVE | os::MEM_COMMIT, os::PAGE_READWRITE);
        if p.is_null() {
            fatal("out of memory mapping VM memory");
        }
        let mut old = 0;
        if guard != 0
            && os::VirtualProtect(p.cast::<u8>().add(len - guard).cast(), guard, os::PAGE_NOACCESS, &mut old) == 0
        {
            fatal("VirtualProtect failed");
        }
        p.cast()
    }
}

/// Unmaps memory returned by [`map`].
///
/// # Safety
/// `p`/`len` must be exactly one earlier [`map`] result, and nothing may use it afterwards.
pub unsafe fn unmap(p: *mut u8, len: usize) {
    #[cfg(unix)]
    // SAFETY: per the caller.
    unsafe {
        os::munmap(p.cast(), len);
    }
    #[cfg(windows)]
    // SAFETY: per the caller. MEM_RELEASE requires size 0.
    unsafe {
        let _ = len;
        os::VirtualFree(p.cast(), 0, os::MEM_RELEASE);
    }
}

/// Arranges for [`super::thread::thread_exit`] to run with `value` when the current thread
/// exits (a pthread key / FLS destructor). `value` must be non-null. Aborts if no key can be
/// created.
pub fn on_thread_exit(value: *mut c_void) {
    // One key for the whole process, created under the lock on first use; stored plus 1, so
    // 0 means "not created yet".
    static KEY: AtomicUsize = AtomicUsize::new(0);
    let mut key = KEY.load(Ordering::Acquire);
    if key == 0 {
        let _g = lock();
        key = KEY.load(Ordering::Relaxed);
        if key == 0 {
            key = create_key();
            KEY.store(key, Ordering::Release);
        }
    }
    let key = (key - 1) as u32;
    #[cfg(unix)]
    // SAFETY: `key` came from `pthread_key_create`.
    unsafe {
        os::pthread_setspecific(key, value);
    }
    #[cfg(windows)]
    // SAFETY: `key` came from `FlsAlloc`.
    unsafe {
        os::FlsSetValue(key, value);
    }

    fn create_key() -> usize {
        #[cfg(unix)]
        {
            unsafe extern "C" fn dtor(v: *mut c_void) {
                // SAFETY: runs on the exiting thread, with the value it registered.
                unsafe { super::thread::thread_exit(v) }
            }
            let mut k = 0u32;
            // SAFETY: `k` is a valid out-pointer.
            if unsafe { os::pthread_key_create(&mut k, Some(dtor)) } != 0 {
                fatal("pthread_key_create failed");
            }
            k as usize + 1
        }
        #[cfg(windows)]
        {
            unsafe extern "system" fn dtor(v: *const c_void) {
                // SAFETY: as on unix.
                unsafe { super::thread::thread_exit(v as *mut c_void) }
            }
            // SAFETY: plain FLS allocation.
            let k = unsafe { os::FlsAlloc(Some(dtor)) };
            if k == os::FLS_OUT_OF_INDEXES {
                fatal("FlsAlloc failed");
            }
            k as usize + 1
        }
    }
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
