//! A cdylib (crate `jitlib`) that `host.c` loads at run time, for the `jit-start` check: its
//! JIT starts in its registry constructor, under the loader lock, and its own constructor
//! (`.init_array`, `__mod_init_func`, `.CRT$XCU`) calls a VM function there, which with
//! `RYO_JIT_SYNC` waits for its compile (skipped under Windows' loader lock).

use std::sync::atomic::{AtomicU64, Ordering};

static CTOR: AtomicU64 = AtomicU64::new(0);

#[inline(never)]
fn in_ctor(x: u64) -> u64 {
    x * 6
}

#[inline(never)]
fn hot(n: u64) -> u64 {
    (0..n).fold(0u64, |a, i| a.wrapping_add(i * i))
}

extern "C" fn ctor() {
    CTOR.store(in_ctor(std::hint::black_box(7)), Ordering::Relaxed);
}

#[used]
#[cfg_attr(target_os = "linux", unsafe(link_section = ".init_array"))]
#[cfg_attr(target_vendor = "apple", unsafe(link_section = "__DATA,__mod_init_func"))]
#[cfg_attr(windows, unsafe(link_section = ".CRT$XCU"))]
static INIT: extern "C" fn() = ctor;

/// What the constructor computed.
#[unsafe(no_mangle)]
pub extern "C" fn jitlib_ctor() -> u64 {
    CTOR.load(Ordering::Relaxed)
}

#[unsafe(no_mangle)]
pub extern "C" fn jitlib_hot(n: u64) -> u64 {
    hot(n)
}
