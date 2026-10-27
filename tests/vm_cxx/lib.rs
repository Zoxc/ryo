//! The Rust side of the C++ programs (`through.cpp`, `terminate.cpp`, `nested.cpp`), a
//! staticlib: C++ exceptions thrown by a C++ callback unwind through VM frames (`outer`,
//! `mid`, ...) and a native one (`native`) to a C++ `catch`. The `extern "C-unwind"` entry
//! points stay native and call the VM functions.
#![feature(rustc_attrs)]
#![allow(internal_features)]
use std::hint::black_box;

/// The C++ callback: throws an `Obj(n)` for `n > 0`.
pub type Cb = extern "C-unwind" fn(u32);

struct Guard(&'static str);

impl Drop for Guard {
    fn drop(&mut self) {
        println!("drop {} panicking={}", self.0, std::thread::panicking());
    }
}

/// Native: inline assembly keeps it out of the VM.
#[inline(never)]
fn native(cb: Cb, n: u32) {
    unsafe { std::arch::asm!("") };
    let _g = Guard("native");
    cb(n);
}

#[inline(never)]
fn mid(cb: Cb, n: u32) {
    let _g = Guard("mid");
    native(cb, n);
}

#[inline(never)]
fn step(n: u32) -> u32 {
    black_box(n) + 1
}

/// Two guards in nested scopes and calls between them: landing pads of their own.
#[inline(never)]
fn outer(cb: Cb, n: u32) -> u32 {
    let _a = Guard("outer a");
    let k = step(n);
    let r = {
        let _b = Guard("outer b");
        mid(cb, n);
        k + 1
    };
    r + step(k)
}

/// A drop that catches a panic of its own while the C++ exception unwinds.
struct Catcher;

impl Drop for Catcher {
    fn drop(&mut self) {
        let r = std::panic::catch_unwind(|| {
            let _g = Guard("in catch_unwind");
            if black_box(true) {
                panic!("in drop");
            }
        });
        println!("drop catcher: caught {} panicking={}", r.is_err(), std::thread::panicking());
    }
}

#[inline(never)]
fn with_catcher(cb: Cb, n: u32) {
    let _c = Catcher;
    let _g = Guard("with catcher");
    mid(cb, n);
}

/// Can't unwind: the call's `Terminate` action catches the C++ exception and aborts.
#[rustc_nounwind]
#[inline(never)]
fn nounwind(cb: Cb, n: u32) {
    let _g = Guard("nounwind");
    native(cb, n);
}

/// A drop that panics if armed, as when the C++ exception unwinds: "panic in a destructor
/// during cleanup".
struct Bomb(bool);

impl Drop for Bomb {
    fn drop(&mut self) {
        println!("drop bomb {}", self.0);
        if black_box(self.0) {
            panic!("bomb");
        }
    }
}

#[inline(never)]
fn with_bomb(cb: Cb, n: u32) {
    let _b = Bomb(n > 0);
    mid(cb, n);
}

/// A hook printing to stdout: the default one forces a backtrace for non-unwinding panics,
/// and VM frames differ.
#[unsafe(no_mangle)]
pub extern "C" fn vcx_init() {
    std::panic::set_hook(Box::new(|i| println!("hook: {}", i.payload_as_str().unwrap_or(""))));
}

#[unsafe(no_mangle)]
pub extern "C-unwind" fn vcx_through(cb: Cb, n: u32) -> u32 {
    outer(cb, n)
}

#[unsafe(no_mangle)]
pub extern "C-unwind" fn vcx_catcher(cb: Cb, n: u32) {
    with_catcher(cb, n)
}

#[unsafe(no_mangle)]
pub extern "C-unwind" fn vcx_terminate(cb: Cb, n: u32) {
    nounwind(cb, n)
}

#[unsafe(no_mangle)]
pub extern "C-unwind" fn vcx_bomb(cb: Cb, n: u32) {
    with_bomb(cb, n)
}
