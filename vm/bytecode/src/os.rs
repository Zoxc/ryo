//! The OS calls `ryo_rt` and the JIT both make beyond [`crate::vmem`]: a raw stderr write and
//! `atexit`. `core` and direct OS calls only (libc on unix, kernel32 on Windows), as for
//! `vmem`.

/// Writes `s` to stderr with one `write` (`WriteFile` on Windows), straight to the file
/// descriptor, ignoring errors. Nothing elsewhere.
#[inline]
pub fn write_stderr(s: &[u8]) {
    #[cfg(unix)]
    {
        unsafe extern "C" {
            fn write(fd: core::ffi::c_int, buf: *const core::ffi::c_void, n: usize) -> isize;
        }
        // SAFETY: a write of a live buffer. Errors are ignored.
        unsafe { write(2, s.as_ptr().cast(), s.len()) };
    }
    #[cfg(windows)]
    {
        use core::ffi::c_void;
        const STD_ERROR_HANDLE: u32 = -12i32 as u32;
        #[link(name = "kernel32")]
        unsafe extern "system" {
            fn GetStdHandle(which: u32) -> *mut c_void;
            fn WriteFile(h: *mut c_void, buf: *const u8, n: u32, written: *mut u32, ov: *mut c_void) -> i32;
        }
        let mut n = 0;
        // SAFETY: a write of a live buffer; a null or invalid handle makes it fail harmlessly.
        unsafe { WriteFile(GetStdHandle(STD_ERROR_HANDLE), s.as_ptr(), s.len().min(u32::MAX as usize) as u32, &mut n, core::ptr::null_mut()) };
    }
    #[cfg(not(any(unix, windows)))]
    let _ = s;
}

/// Registers `f` to run at exit (the C runtime's `atexit`, libc's or the CRT's).
#[cfg(any(unix, windows))]
#[inline]
pub fn atexit(f: extern "C" fn()) {
    unsafe extern "C" {
        fn atexit(f: extern "C" fn()) -> core::ffi::c_int;
    }
    // SAFETY: registers a plain function with no arguments, which lives for the whole process.
    unsafe { atexit(f) };
}
