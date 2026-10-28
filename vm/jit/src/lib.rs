//! The JIT (design/jit.md): a background thread that recompiles hot VM functions and
//! switches them over to the new code. The runtime (`ryo_rt`) starts it with the first
//! function it queues, through the one symbol this crate exports, [`ryo_jit_start`], and
//! the JIT sees the runtime only through the [`RtApi`] it gets there
//! ([`ryo_bytecode::jit_abi`]).
//!
//! - `thread`: the JIT thread: takes the queued records ([`RtApi::next_batch`]), compiles
//!   each, catching its panics, and reports it ([`RtApi::done`]).
//! - `install`: the compiler: decodes a function from its image, encodes it again without
//!   counters, builds its OSR entries, and installs the code near the image.
//!
//! - `stats`: the counters and `RYO_JIT_STATS`'s output.
//! - `sys`: what it needs of the OS beyond `vmem` and std (unwind registration).
//!
//! x86_64 only; the OS-specific parts are in `sys`. Where `sys::SUPPORTED` is false (not
//! ported yet) `ryo_jit_start` fails, so that the runtime's trips act as the no-op JIT, but
//! `y build` seals and bundles it the same way.

#![feature(alloc_error_hook)]

#[cfg(target_arch = "x86_64")]
mod install;
#[cfg(target_arch = "x86_64")]
mod stats;
#[cfg(target_arch = "x86_64")]
mod sys;
#[cfg(target_arch = "x86_64")]
mod thread;

use ryo_bytecode::jit_abi::RtApi;

/// Starts the JIT thread, which compiles what `rt` queues, and returns its exit report
/// (`RYO_JIT_STATS`'s summary), which the runtime calls at exit. `None` if the thread didn't
/// start; the runtime then acts as the no-op JIT. Called once per runtime.
#[cfg(target_arch = "x86_64")]
#[unsafe(export_name = concat!("ryo_jit_start_", env!("RYO_ABI")))]
pub extern "C" fn ryo_jit_start(rt: &'static RtApi) -> Option<extern "C" fn()> {
    (sys::SUPPORTED && thread::start(rt)).then_some(stats::report as extern "C" fn())
}

#[cfg(target_arch = "x86_64")]
#[doc(hidden)]
pub use stats::Snapshot;

/// The JIT's counters (tests).
#[cfg(target_arch = "x86_64")]
#[doc(hidden)]
pub fn stats() -> Snapshot {
    stats::STATS.load_all()
}

/// How many functions the JIT compiled, and how many it failed to (tests).
#[cfg(target_arch = "x86_64")]
#[doc(hidden)]
pub fn jit_stats() -> (usize, usize) {
    let s = stats();
    (s.compiled as usize, s.failed_total() as usize)
}

/// How many functions the SSA tier (`RYO_JIT_OPT=ssa…`) compiled, and how many it left
/// (to the re-encoding pipeline, or failed by its checkers) (tests).
#[cfg(target_arch = "x86_64")]
#[doc(hidden)]
pub fn ssa_stats() -> (usize, usize) {
    let s = stats();
    (s.ssa as usize, (s.ssa_unsupported + s.ssa_check_failed) as usize)
}

/// How many calls through a constant pointer the SSA tier made direct in its roots (tests).
#[cfg(all(any(target_os = "linux", target_vendor = "apple"), target_arch = "x86_64"))]
#[doc(hidden)]
pub fn ssa_devirt() -> usize {
    stats().devirt as usize
}

/// The length of the code the JIT installed for the record at `rec`, 0 if none (tests).
#[cfg(target_arch = "x86_64")]
#[doc(hidden)]
pub fn code_len(rec: *const ryo_bytecode::image::JitRecord) -> usize {
    // SAFETY: a live record; its JIT code, once published, starts `CODE_AT` bytes into its
    // allocation, which holds the length at `CODE_LEN_AT`.
    unsafe {
        let code = (*rec).jit_code;
        if code.is_null() {
            return 0;
        }
        code.sub(install::CODE_AT - install::CODE_LEN_AT).cast::<u32>().read_unaligned() as usize
    }
}

/// Without a JIT for this target: fails, so the runtime acts as the no-op JIT.
#[cfg(not(target_arch = "x86_64"))]
#[unsafe(export_name = concat!("ryo_jit_start_", env!("RYO_ABI")))]
pub extern "C" fn ryo_jit_start(rt: &'static RtApi) -> Option<extern "C" fn()> {
    let _ = rt;
    None
}
