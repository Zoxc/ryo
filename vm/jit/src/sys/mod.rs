//! What the JIT needs of the OS beyond `vmem` and std: registering unwind information for
//! installed code, a raw stderr write, the perf map's path. One module per OS (`linux`,
//! `windows`, `macos`); [`SUPPORTED`] says whether the JIT runs there (else `ryo_jit_start`
//! fails, and the runtime acts as the no-op JIT).
//!
//! The exit-time rule is common: unwinders' registries may be torn down at exit (libgcc frees
//! its b-tree in a destructor without locks), so registrations hold [`FRAMES_OPEN`], and an
//! `atexit` handler closes it, after which nothing is registered and the code isn't
//! published. Windows has no such teardown (`RtlAddFunctionTable`'s list lives as long as
//! the process), and there the handler could hang: `ExitProcess` kills the JIT thread
//! wherever it is, perhaps holding the lock, before it runs the DLLs' detach code, which
//! may run `atexit` handlers. So there is none: registrations take the lock, but nothing
//! closes it.

#[cfg_attr(target_os = "linux", path = "linux.rs")]
#[cfg_attr(windows, path = "windows.rs")]
#[cfg_attr(target_vendor = "apple", path = "macos.rs")]
#[cfg_attr(not(any(target_os = "linux", windows, target_vendor = "apple")), path = "none.rs")]
mod imp;

// The macOS module's FDE handling, tested where the tests run.
#[cfg(all(test, target_os = "linux"))]
#[allow(dead_code)]
#[path = "macos.rs"]
mod macos;

pub(crate) use imp::{SUPPORTED, perfmap_path, write_stderr};

/// The unwind information of one installed function, in the region's read-write memory,
/// which lives forever. Each OS handles one variant and refuses the other.
// Each OS reads only its own variant's fields.
#[allow(dead_code)]
pub(crate) enum Unwind<'a> {
    /// ELF and Mach-O code: its `.eh_frame` (a CIE, then the FDEs, terminated by a zero word)
    /// and the offsets in it of its FDEs (the body's, the OSR code's).
    Eh { eh: *const u8, fdes: &'a [usize] },
    /// PE code at `base`: its function table, `count` `RUNTIME_FUNCTION`s (`begin`, `end`,
    /// `UNWIND_INFO`, each a `u32` offset from `base`).
    Pe { base: usize, table: *const u8, count: u32 },
}

/// Whether unwind information may still be registered: false once the process is exiting.
static FRAMES_OPEN: std::sync::Mutex<bool> = std::sync::Mutex::new(true);

#[cfg(not(windows))]
unsafe extern "C" {
    fn atexit(f: extern "C" fn()) -> core::ffi::c_int;
}

/// Arranges for [`close_frame_registry`] to run at exit, before the unwinder's teardown:
/// `atexit` handlers registered after startup run before the shared objects' destructors.
/// Not on Windows (see above).
pub(crate) fn close_frame_registry_at_exit() {
    // SAFETY: a plain function with no arguments.
    #[cfg(not(windows))]
    unsafe {
        atexit(close_frame_registry)
    };
}

/// Ends unwind registrations: waits for the one in progress, if any.
#[cfg_attr(windows, allow(dead_code))]
pub(crate) extern "C" fn close_frame_registry() {
    *FRAMES_OPEN.lock().unwrap_or_else(|e| e.into_inner()) = false;
}

/// Registers `u` with the unwinder, unless the process is exiting. False if it wasn't
/// registered: the code must not run then.
///
/// # Safety
/// `u` describes installed code, and its memory lives forever.
pub(crate) unsafe fn register_unwind(u: &Unwind<'_>) -> bool {
    let open = FRAMES_OPEN.lock().unwrap_or_else(|e| e.into_inner());
    // SAFETY: as the caller promises; the registry isn't being torn down while `open`.
    *open && unsafe { imp::register(u) }
}

#[cfg(test)]
pub(crate) fn reopen_frame_registry() {
    *FRAMES_OPEN.lock().unwrap() = true;
}
