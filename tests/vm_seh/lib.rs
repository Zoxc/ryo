//! The Rust side of `av.c` and `longjmp.c`, a staticlib: VM frames between C frames that
//! leave them by an SEH exception (an access violation caught by `__except`, windows-msvc
//! only) or by `longjmp` (over frames without drops). The `extern "C-unwind"` entry points
//! stay native.
use std::hint::black_box;

/// The C callback.
pub type Cb = extern "C-unwind" fn(u32);

/// Native (inline assembly keeps it out of the VM, which doesn't call C function pointers).
#[inline(never)]
fn call(cb: Cb, n: u32) {
    unsafe { std::arch::asm!("") };
    cb(n);
}

struct Guard(&'static str);

impl Drop for Guard {
    fn drop(&mut self) {
        println!("drop {}", self.0);
    }
}

#[inline(never)]
fn inner(cb: Cb, n: u32) -> u32 {
    let _g = Guard("inner");
    call(cb, n);
    n + 1
}

#[inline(never)]
fn guarded(cb: Cb, n: u32) -> u32 {
    let _g = Guard("guarded");
    inner(cb, n) * 2
}

/// No drops: frames `longjmp` may leave.
#[inline(never)]
fn plain_inner(cb: Cb, n: u32) -> u32 {
    call(cb, n);
    black_box(n) * 3
}

#[inline(never)]
fn plain(cb: Cb, n: u32) -> u32 {
    plain_inner(cb, n) + black_box(1)
}

#[unsafe(no_mangle)]
pub extern "C-unwind" fn vse_guarded(cb: Cb, n: u32) -> u32 {
    guarded(cb, n)
}

#[unsafe(no_mangle)]
pub extern "C-unwind" fn vse_plain(cb: Cb, n: u32) -> u32 {
    plain(cb, n)
}
