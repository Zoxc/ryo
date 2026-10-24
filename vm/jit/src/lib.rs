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
//! Linux on x86_64 only. Elsewhere (windows-msvc, until the JIT is ported) `ryo_jit_start`
//! fails, so that the runtime's trips act as the no-op JIT, but `y build` seals and bundles
//! it the same way.

#[cfg(all(target_os = "linux", target_arch = "x86_64"))]
mod install;
#[cfg(all(target_os = "linux", target_arch = "x86_64"))]
mod thread;

use ryo_bytecode::jit_abi::RtApi;

/// Starts the JIT thread, which compiles what `rt` queues. False if `rt` isn't of this JIT's
/// version ([`RtApi::compatible`]), or the thread didn't start; the runtime then acts as the
/// no-op JIT. Called once per runtime.
#[cfg(all(target_os = "linux", target_arch = "x86_64"))]
#[unsafe(no_mangle)]
pub extern "C" fn ryo_jit_start(rt: &'static RtApi) -> bool {
    thread::start(rt)
}

/// Without a JIT for this target: fails, so the runtime acts as the no-op JIT.
#[cfg(not(all(target_os = "linux", target_arch = "x86_64")))]
#[unsafe(no_mangle)]
pub extern "C" fn ryo_jit_start(rt: &'static RtApi) -> bool {
    let _ = rt;
    false
}
