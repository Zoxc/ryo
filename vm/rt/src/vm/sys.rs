//! OS services for the VM: page mappings (through `ryo_bytecode::vmem`), fatal errors, the
//! runtime lock, and a bump allocator; for the JIT, the environment, futexes and reads of
//! possibly unmapped memory. Every OS call of the runtime is declared here or in
//! `ryo_bytecode` (`vmem`, `os`).
//!
//! Everything here uses `core` and direct OS calls only (libc on ELF, kernel32 on PE). Under
//! `--sysroot ryo`, std's allocator, `Mutex` and I/O may be VM functions, so the runtime must
//! not call them while it sets up or switches VM state (design/vm.md, "No re-entry into the
//! VM from the runtime").

use core::cell::UnsafeCell;
#[cfg(feature = "jit")]
use core::ffi::CStr;
use core::ops::{Deref, DerefMut};
use core::ptr;
use core::sync::atomic::{AtomicBool, Ordering};

use ryo_bytecode::vmem;

/// Page size for guard pages and mapping granularity ([`vmem::PAGE`]).
const PAGE: usize = vmem::PAGE;

#[cfg(unix)]
mod os {
    unsafe extern "C" {
        pub fn abort() -> !;
        #[cfg(feature = "jit")]
        pub fn getpid() -> core::ffi::c_int;
    }
}

#[cfg(windows)]
mod os {
    #[link(name = "kernel32")]
    unsafe extern "system" {
        #[cfg(feature = "jit")]
        pub fn GetCurrentProcessId() -> u32;
    }
}

/// Pins the module (executable or shared object) containing `addr` against unloading:
/// `dlclose`/`FreeLibrary` of it become no-ops. Its images, its JIT thread's code and the JIT
/// code other modules may call stay mapped (design/vm.md#several-ryo-runtimes-in-one-process).
/// Best effort: a failure leaves the module as it was.
#[cfg(feature = "jit")]
pub(crate) fn pin_module(addr: *const ()) {
    #[cfg(unix)]
    {
        use core::ffi::{c_char, c_int, c_void};
        #[repr(C)]
        struct DlInfo {
            fname: *const c_char,
            fbase: *mut c_void,
            sname: *const c_char,
            saddr: *mut c_void,
        }
        unsafe extern "C" {
            fn dladdr(addr: *const c_void, info: *mut DlInfo) -> c_int;
            fn dlopen(file: *const c_char, mode: c_int) -> *mut c_void;
        }
        #[cfg(target_vendor = "apple")]
        const MODE: c_int = 0x2 | 0x10 | 0x80; // RTLD_NOW | RTLD_NOLOAD | RTLD_NODELETE
        #[cfg(not(target_vendor = "apple"))]
        const MODE: c_int = 0x2 | 0x4 | 0x1000; // RTLD_NOW | RTLD_NOLOAD | RTLD_NODELETE
        let mut info = DlInfo { fname: core::ptr::null(), fbase: core::ptr::null_mut(), sname: core::ptr::null(), saddr: core::ptr::null_mut() };
        // SAFETY: plain libc calls; `dlopen` with `RTLD_NOLOAD` only adds a reference (never
        // released) to the already loaded module, or returns null (the main executable).
        unsafe {
            if dladdr(addr.cast(), &mut info) != 0 && !info.fname.is_null() {
                dlopen(info.fname, MODE);
            }
        }
    }
    #[cfg(windows)]
    {
        use core::ffi::c_void;
        #[link(name = "kernel32")]
        unsafe extern "system" {
            fn GetModuleHandleExW(flags: u32, name: *const u16, module: *mut *mut c_void) -> i32;
        }
        // GET_MODULE_HANDLE_EX_FLAG_PIN | GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS
        let mut m = core::ptr::null_mut();
        // SAFETY: a plain kernel32 call.
        unsafe { GetModuleHandleExW(0x1 | 0x4, addr.cast(), &mut m) };
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

pub(crate) use ryo_bytecode::os::write_stderr;

/// The process's id.
#[cfg(feature = "jit")]
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

#[cfg(feature = "jit")]
unsafe extern "C" {
    fn getenv(name: *const core::ffi::c_char) -> *const core::ffi::c_char;
}

/// The environment variable `name`'s value, if it is set.
#[cfg(feature = "jit")]
pub(crate) fn var(name: &CStr) -> Option<&'static [u8]> {
    // SAFETY: a NUL-terminated name; the value stays valid unless the program changes the
    // environment, which it may not while other threads read it (as for std's `env::var`).
    unsafe {
        let v = getenv(name.as_ptr());
        (!v.is_null()).then(|| CStr::from_ptr(v).to_bytes())
    }
}

#[cfg(all(feature = "jit", target_os = "linux"))]
mod futex {
    use core::ffi::{c_long, c_void};
    use core::ptr;
    use core::sync::atomic::AtomicU32;

    const SYS_FUTEX: c_long = 202;
    const FUTEX_WAIT_PRIVATE: i32 = 128;
    const FUTEX_WAKE_PRIVATE: i32 = 129;

    unsafe extern "C" {
        fn syscall(n: c_long, ...) -> c_long;
    }

    /// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
    pub fn wait(a: &AtomicU32, v: u32) {
        // SAFETY: a futex wait on a live atomic, without a timeout.
        unsafe { syscall(SYS_FUTEX, a.as_ptr(), FUTEX_WAIT_PRIVATE, v, ptr::null::<c_void>()) };
    }

    /// Wakes up to `n` threads waiting on `a`.
    pub fn wake(a: &AtomicU32, n: i32) {
        // SAFETY: a futex wake on a live atomic.
        unsafe { syscall(SYS_FUTEX, a.as_ptr(), FUTEX_WAKE_PRIVATE, n) };
    }
}

/// Apple: `__ulock_wait`/`__ulock_wake` (libSystem; what libc++'s and std's waits use
/// before macOS 14.4's `os_sync_wait_on_address`).
#[cfg(all(feature = "jit", target_vendor = "apple"))]
mod futex {
    use core::ffi::{c_int, c_void};
    use core::sync::atomic::AtomicU32;

    const UL_COMPARE_AND_WAIT: u32 = 1;
    const ULF_WAKE_ALL: u32 = 0x100;
    const ULF_NO_ERRNO: u32 = 0x0100_0000;

    unsafe extern "C" {
        fn __ulock_wait(op: u32, addr: *mut c_void, value: u64, timeout_us: u32) -> c_int;
        fn __ulock_wake(op: u32, addr: *mut c_void, wake_value: u64) -> c_int;
    }

    /// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
    pub fn wait(a: &AtomicU32, v: u32) {
        // SAFETY: a wait on a live atomic of 4 bytes, compared with `v`, without a timeout.
        unsafe { __ulock_wait(UL_COMPARE_AND_WAIT | ULF_NO_ERRNO, a.as_ptr().cast(), v as u64, 0) };
    }

    /// Wakes one thread waiting on `a`, or all of them.
    pub fn wake(a: &AtomicU32, n: i32) {
        let all = if n == 1 { 0 } else { ULF_WAKE_ALL };
        // SAFETY: a wake on a live atomic.
        unsafe { __ulock_wake(UL_COMPARE_AND_WAIT | ULF_NO_ERRNO | all, a.as_ptr().cast(), 0) };
    }
}

/// PE: `WaitOnAddress`, imported as std imports it (`raw-dylib`, no import library needed).
#[cfg(all(feature = "jit", windows))]
mod futex {
    use core::ffi::c_void;
    use core::sync::atomic::AtomicU32;

    #[link(name = "api-ms-win-core-synch-l1-2-0", kind = "raw-dylib")]
    unsafe extern "system" {
        fn WaitOnAddress(addr: *const c_void, compare: *const c_void, size: usize, ms: u32) -> i32;
        fn WakeByAddressSingle(addr: *const c_void);
        fn WakeByAddressAll(addr: *const c_void);
    }

    /// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
    pub fn wait(a: &AtomicU32, v: u32) {
        // SAFETY: a wait on a live atomic of 4 bytes, compared with `v`, without a timeout.
        unsafe { WaitOnAddress(a.as_ptr().cast(), (&raw const v).cast(), 4, u32::MAX) };
    }

    /// Wakes one thread waiting on `a`, or all of them.
    pub fn wake(a: &AtomicU32, n: i32) {
        // SAFETY: a wake on a live atomic.
        unsafe { if n == 1 { WakeByAddressSingle(a.as_ptr().cast()) } else { WakeByAddressAll(a.as_ptr().cast()) } }
    }
}

#[cfg(feature = "jit")]
pub(crate) use futex::{wait as futex_wait, wake as futex_wake};

/// The first 16 bytes at `at` in this process, read without faulting; `None` where
/// unreadable (the merge rendezvous, `jit/merge.rs`).
#[cfg(all(feature = "jit", target_os = "linux"))]
pub(crate) fn read_head(at: usize) -> Option<[u64; 2]> {
    use core::ffi::{c_int, c_long, c_void};
    #[repr(C)]
    struct IoVec {
        base: *mut c_void,
        len: usize,
    }
    unsafe extern "C" {
        fn process_vm_readv(pid: c_int, local: *const IoVec, ln: c_long, remote: *const IoVec, rn: c_long, flags: c_long) -> isize;
    }
    let mut head = [0u64; 2];
    let local = IoVec { base: head.as_mut_ptr().cast(), len: 16 };
    let remote = IoVec { base: at as *mut c_void, len: 16 };
    // SAFETY: reads 16 bytes of this process, failing (not faulting) where unreadable.
    let n = unsafe { process_vm_readv(pid() as c_int, &local, 1, &remote, 1, 0) };
    (n == 16).then_some(head)
}

#[cfg(all(feature = "jit", target_vendor = "apple"))]
pub(crate) fn read_head(at: usize) -> Option<[u64; 2]> {
    unsafe extern "C" {
        static mach_task_self_: u32;
        fn mach_vm_read_overwrite(task: u32, addr: u64, size: u64, data: u64, out: *mut u64) -> i32;
    }
    let mut head = [0u64; 2];
    let mut n = 0u64;
    // SAFETY: a plain Mach call on this task, failing (not faulting) where unreadable.
    let ok = unsafe { mach_vm_read_overwrite(mach_task_self_, at as u64, 16, head.as_mut_ptr() as u64, &mut n) } == 0;
    (ok && n == 16).then_some(head)
}

#[cfg(all(feature = "jit", windows))]
pub(crate) fn read_head(at: usize) -> Option<[u64; 2]> {
    use core::ffi::c_void;
    #[link(name = "kernel32")]
    unsafe extern "system" {
        fn GetCurrentProcess() -> *mut c_void;
        fn ReadProcessMemory(process: *mut c_void, base: *const c_void, buf: *mut c_void, size: usize, read: *mut usize) -> i32;
    }
    let mut head = [0u64; 2];
    let mut n = 0usize;
    // SAFETY: a plain kernel32 call on this process, failing (not faulting) where unreadable.
    let ok = unsafe { ReadProcessMemory(GetCurrentProcess(), at as *const c_void, head.as_mut_ptr().cast(), 16, &mut n) } != 0;
    (ok && n == 16).then_some(head)
}

/// Elsewhere `vmem::reserve` fails, and so does this: no merge rendezvous.
#[cfg(all(feature = "jit", not(any(target_os = "linux", target_vendor = "apple", windows))))]
pub(crate) fn read_head(_: usize) -> Option<[u64; 2]> {
    None
}

/// Aborts the process without a message, as C++'s `terminate` does.
#[cfg_attr(not(windows), allow(dead_code))]
#[cold]
#[inline(never)]
pub(crate) fn terminate() -> ! {
    abort()
}

/// Aborts as Rust's `std::process::abort`: `abort()`, or on Windows the fail-fast exception
/// (`__fastfail(FAST_FAIL_FATAL_APP_EXIT)`, exit code 0xC0000409, as MSVC's `abort`).
fn abort() -> ! {
    #[cfg(unix)]
    // SAFETY: always safe to call.
    unsafe {
        os::abort()
    }
    #[cfg(windows)]
    // SAFETY: `int 0x29` raises the non-continuable fail-fast exception; it doesn't return.
    unsafe {
        core::arch::asm!("int 0x29", in("ecx") 7, options(noreturn, nostack));
    }
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

/// Whether the process is exiting with its other threads gone: on Windows, `ExitProcess`
/// terminates every other thread (the JIT thread included) before it runs the exiting
/// thread's TLS destructors and the modules' detach callbacks, which may still run VM code.
/// Elsewhere other threads live on through `exit`'s handlers: always false.
#[cfg(feature = "jit")]
pub(crate) fn exiting() -> bool {
    #[cfg(windows)]
    {
        #[link(name = "ntdll", kind = "raw-dylib")]
        unsafe extern "system" {
            fn RtlDllShutdownInProgress() -> u8;
        }
        // SAFETY: reads the loader's shutdown flag; callable at any time.
        unsafe { RtlDllShutdownInProgress() != 0 }
    }
    #[cfg(not(windows))]
    false
}
