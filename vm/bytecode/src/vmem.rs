//! Virtual memory for the VM and the JIT: reserving address space (optionally near an
//! address), guard pages, and code memory (writable, then executable, with the instruction
//! cache flushed). `core` and direct OS calls only (libc on Linux and Apple, kernel32 on
//! Windows), so `ryo_rt` can use it without std (see `vm/rt/src/vm/sys.rs`).
//!
//! Code memory follows one protocol on every target: [`reserve_code`], write, then
//! [`make_executable`]; to write it again, [`make_writable`] first. Fresh code memory is
//! writable, except on aarch64 Apple (`MAP_JIT`), where it is write-protected per thread
//! until the writing thread calls [`make_writable`] (`pthread_jit_write_protect_np`). A
//! hardened-runtime macOS binary also needs the `com.apple.security.cs.allow-jit` (aarch64)
//! or `allow-unsigned-executable-memory` (x86_64) entitlement. x86_64 Apple, natively or
//! under Rosetta (which sees the `mprotect`s and retranslates written code), maps without
//! `MAP_JIT` and switches with `mprotect`, as Linux does; its `mmap` takes the address as a
//! hint only.
//!
//! Elsewhere (no Linux, Apple or Windows) reserving fails, and so does everything after.

/// The page size: the granularity of protections and guard pages.
#[cfg(all(target_vendor = "apple", target_arch = "aarch64"))]
pub const PAGE: usize = 16384;
/// The page size: the granularity of protections and guard pages.
#[cfg(not(all(target_vendor = "apple", target_arch = "aarch64")))]
pub const PAGE: usize = 4096;

/// Reserves `len` bytes (a multiple of [`PAGE`]) of zeroed read-write memory, page-aligned
/// and backed on first touch where the OS allows (Linux, Apple; Windows commits it). With
/// `hint` nonzero, asks for exactly `hint` and never replaces an existing mapping; Linux
/// before 4.17 and Apple may put it elsewhere instead, so callers check the address. None if
/// it failed.
pub fn reserve(hint: usize, len: usize) -> Option<*mut u8> {
    // SAFETY: a fresh anonymous mapping, never over an existing one.
    unsafe { os::reserve(hint, len, false) }
}

/// [`reserve`] for code: memory that [`make_executable`] can make executable (`MAP_JIT` on
/// aarch64 Apple, where it isn't writable until [`make_writable`]).
pub fn reserve_code(hint: usize, len: usize) -> Option<*mut u8> {
    // SAFETY: as in `reserve`.
    unsafe { os::reserve(hint, len, true) }
}

/// Releases a whole mapping that [`reserve`] or [`reserve_code`] returned.
///
/// # Safety
/// `[p, p + len)` is that mapping, and nothing uses it any more.
pub unsafe fn release(p: *mut u8, len: usize) {
    // SAFETY: the caller's.
    unsafe { os::release(p, len) }
}

/// Makes the pages `[p, p + len)` of a mapping inaccessible (guard pages). False on failure.
///
/// # Safety
/// The pages belong to a mapping from [`reserve`] and nothing accesses them any more.
pub unsafe fn guard(p: *mut u8, len: usize) -> bool {
    // SAFETY: the caller's.
    unsafe { os::guard(p, len) }
}

/// Makes the code pages `[p, p + len)` writable (on aarch64 Apple: all `MAP_JIT` memory, for
/// the calling thread). False on failure.
///
/// # Safety
/// The pages belong to a mapping from [`reserve_code`]; no thread runs code in them until
/// [`make_executable`].
pub unsafe fn make_writable(p: *mut u8, len: usize) -> bool {
    // SAFETY: the caller's.
    unsafe { os::make_writable(p, len) }
}

/// Makes the code pages `[p, p + len)` read-only and executable (on aarch64 Apple: all
/// `MAP_JIT` memory, for the calling thread), and flushes the instruction cache over them.
/// False on failure.
///
/// # Safety
/// The pages belong to a mapping from [`reserve_code`], and nothing writes them any more
/// (until [`make_writable`]).
pub unsafe fn make_executable(p: *mut u8, len: usize) -> bool {
    // SAFETY: the caller's.
    let ok = unsafe { os::make_executable(p, len) };
    if ok {
        flush_icache(p, len);
    }
    ok
}

/// Makes the instruction cache see what was written to `[p, p + len)`. Nothing to do on
/// x86-64 Unix (coherent caches; a jump to the new code serializes enough); on Windows,
/// `FlushInstructionCache`, as documented for code generators.
#[inline]
pub fn flush_icache(p: *mut u8, len: usize) {
    os::flush_icache(p, len)
}

#[cfg(any(target_os = "linux", target_vendor = "apple"))]
mod os {
    use core::ffi::{c_int, c_void};

    const PROT_NONE: c_int = 0;
    const PROT_READ: c_int = 1;
    const PROT_WRITE: c_int = 2;
    const PROT_EXEC: c_int = 4;
    const MAP_PRIVATE: c_int = 0x02;
    const MAP_FAILED: *mut c_void = !0usize as *mut c_void;

    #[cfg(target_os = "linux")]
    const MAP_ANONYMOUS: c_int = 0x20;
    #[cfg(target_os = "linux")]
    const MAP_NORESERVE: c_int = 0x4000;
    #[cfg(target_os = "linux")]
    const MAP_FIXED_NOREPLACE: c_int = 0x10_0000;

    #[cfg(target_vendor = "apple")]
    const MAP_ANONYMOUS: c_int = 0x1000;
    /// Apple: without overcommit control; `MAP_NORESERVE` is accepted but ignored.
    #[cfg(target_vendor = "apple")]
    const MAP_NORESERVE: c_int = 0;
    /// Apple: no such flag; a non-`MAP_FIXED` address is a hint, never a replacement.
    #[cfg(target_vendor = "apple")]
    const MAP_FIXED_NOREPLACE: c_int = 0;

    unsafe extern "C" {
        fn mmap(addr: *mut c_void, len: usize, prot: c_int, flags: c_int, fd: c_int, off: i64) -> *mut c_void;
        fn munmap(addr: *mut c_void, len: usize) -> c_int;
        fn mprotect(addr: *mut c_void, len: usize, prot: c_int) -> c_int;
    }

    #[cfg(all(target_vendor = "apple", target_arch = "aarch64"))]
    unsafe extern "C" {
        fn pthread_jit_write_protect_np(enabled: c_int);
        fn sys_icache_invalidate(start: *mut c_void, len: usize);
    }

    #[cfg(all(target_os = "linux", not(target_arch = "x86_64")))]
    unsafe extern "C" {
        /// compiler-rt's / libgcc's.
        fn __clear_cache(start: *mut c_void, end: *mut c_void);
    }

    pub unsafe fn reserve(hint: usize, len: usize, code: bool) -> Option<*mut u8> {
        let mut flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE;
        if hint != 0 {
            flags |= MAP_FIXED_NOREPLACE;
        }
        #[allow(unused_mut)]
        let mut prot = PROT_READ | PROT_WRITE;
        // `MAP_JIT` code memory: RWX, its write protection toggled per thread.
        #[cfg(all(target_vendor = "apple", target_arch = "aarch64"))]
        if code {
            const MAP_JIT: c_int = 0x800;
            flags |= MAP_JIT;
            prot |= PROT_EXEC;
        }
        let _ = code;
        // SAFETY: the caller's; without `MAP_FIXED` this never replaces a mapping.
        let p = unsafe { mmap(hint as *mut c_void, len, prot, flags, -1, 0) };
        (p != MAP_FAILED).then_some(p.cast())
    }

    pub unsafe fn release(p: *mut u8, len: usize) {
        // SAFETY: the caller's.
        unsafe { munmap(p.cast(), len) };
    }

    pub unsafe fn guard(p: *mut u8, len: usize) -> bool {
        // SAFETY: the caller's.
        unsafe { mprotect(p.cast(), len, PROT_NONE) == 0 }
    }

    pub unsafe fn make_writable(p: *mut u8, len: usize) -> bool {
        #[cfg(all(target_vendor = "apple", target_arch = "aarch64"))]
        {
            let _ = (p, len);
            // SAFETY: toggles this thread's view of `MAP_JIT` memory.
            unsafe { pthread_jit_write_protect_np(0) };
            true
        }
        #[cfg(not(all(target_vendor = "apple", target_arch = "aarch64")))]
        // SAFETY: the caller's.
        unsafe {
            mprotect(p.cast(), len, PROT_READ | PROT_WRITE) == 0
        }
    }

    pub unsafe fn make_executable(p: *mut u8, len: usize) -> bool {
        #[cfg(all(target_vendor = "apple", target_arch = "aarch64"))]
        {
            let _ = (p, len);
            // SAFETY: toggles this thread's view of `MAP_JIT` memory.
            unsafe { pthread_jit_write_protect_np(1) };
            true
        }
        #[cfg(not(all(target_vendor = "apple", target_arch = "aarch64")))]
        // SAFETY: the caller's.
        unsafe {
            mprotect(p.cast(), len, PROT_READ | PROT_EXEC) == 0
        }
    }

    #[inline]
    pub fn flush_icache(p: *mut u8, len: usize) {
        #[cfg(all(target_vendor = "apple", target_arch = "aarch64"))]
        // SAFETY: only invalidates cache lines.
        unsafe {
            sys_icache_invalidate(p.cast(), len)
        };
        #[cfg(all(target_os = "linux", not(target_arch = "x86_64")))]
        // SAFETY: only invalidates cache lines.
        unsafe {
            __clear_cache(p.cast(), p.wrapping_add(len).cast())
        };
        let _ = (p, len);
    }
}

#[cfg(windows)]
mod os {
    use core::ffi::c_void;

    const MEM_COMMIT: u32 = 0x1000;
    const MEM_RESERVE: u32 = 0x2000;
    const MEM_RELEASE: u32 = 0x8000;
    const PAGE_NOACCESS: u32 = 0x01;
    const PAGE_READWRITE: u32 = 0x04;
    const PAGE_EXECUTE_READ: u32 = 0x20;

    #[link(name = "kernel32")]
    unsafe extern "system" {
        fn VirtualAlloc(addr: *mut c_void, size: usize, ty: u32, protect: u32) -> *mut c_void;
        fn VirtualFree(addr: *mut c_void, size: usize, ty: u32) -> i32;
        fn VirtualProtect(addr: *mut c_void, size: usize, protect: u32, old: *mut u32) -> i32;
        fn GetCurrentProcess() -> *mut c_void;
        fn FlushInstructionCache(process: *mut c_void, addr: *const c_void, size: usize) -> i32;
    }

    /// Reserves and commits at once (commit charge, not memory: pages are zero-filled on first
    /// touch). A `hint` must be a multiple of the 64 KiB allocation granularity, else it is
    /// rounded down; an occupied range fails, like `MAP_FIXED_NOREPLACE`.
    pub unsafe fn reserve(hint: usize, len: usize, _code: bool) -> Option<*mut u8> {
        // SAFETY: the caller's; `VirtualAlloc` never replaces an allocation.
        let p = unsafe { VirtualAlloc(hint as *mut c_void, len, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE) };
        (!p.is_null()).then_some(p.cast())
    }

    pub unsafe fn release(p: *mut u8, _len: usize) {
        // SAFETY: the caller's; `MEM_RELEASE` takes the whole allocation, size 0.
        unsafe { VirtualFree(p.cast(), 0, MEM_RELEASE) };
    }

    unsafe fn protect(p: *mut u8, len: usize, prot: u32) -> bool {
        let mut old = 0;
        // SAFETY: the caller's.
        unsafe { VirtualProtect(p.cast(), len, prot, &mut old) != 0 }
    }

    pub unsafe fn guard(p: *mut u8, len: usize) -> bool {
        // SAFETY: the caller's.
        unsafe { protect(p, len, PAGE_NOACCESS) }
    }

    pub unsafe fn make_writable(p: *mut u8, len: usize) -> bool {
        // SAFETY: the caller's.
        unsafe { protect(p, len, PAGE_READWRITE) }
    }

    pub unsafe fn make_executable(p: *mut u8, len: usize) -> bool {
        // SAFETY: the caller's.
        unsafe { protect(p, len, PAGE_EXECUTE_READ) }
    }

    #[inline]
    pub fn flush_icache(p: *mut u8, len: usize) {
        // SAFETY: only flushes cache lines of this process.
        unsafe { FlushInstructionCache(GetCurrentProcess(), p.cast_const().cast(), len) };
    }
}

#[cfg(not(any(target_os = "linux", target_vendor = "apple", windows)))]
mod os {
    pub unsafe fn reserve(_hint: usize, _len: usize, _code: bool) -> Option<*mut u8> {
        None
    }
    pub unsafe fn release(_p: *mut u8, _len: usize) {}
    pub unsafe fn guard(_p: *mut u8, _len: usize) -> bool {
        false
    }
    pub unsafe fn make_writable(_p: *mut u8, _len: usize) -> bool {
        false
    }
    pub unsafe fn make_executable(_p: *mut u8, _len: usize) -> bool {
        false
    }
    pub fn flush_icache(_p: *mut u8, _len: usize) {}
}
