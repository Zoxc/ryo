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

/// The length of the code the JIT installed for the record at `rec`, 0 if none (tests).
#[cfg(target_arch = "x86_64")]
#[doc(hidden)]
pub fn code_len(rec: *const ryo_bytecode::image::JitRecord) -> usize {
    install::installed_len(rec)
}

/// Without a JIT for this target: fails, so the runtime acts as the no-op JIT.
#[cfg(not(target_arch = "x86_64"))]
#[unsafe(export_name = concat!("ryo_jit_start_", env!("RYO_ABI")))]
pub extern "C" fn ryo_jit_start(rt: &'static RtApi) -> Option<extern "C" fn()> {
    let _ = rt;
    None
}
