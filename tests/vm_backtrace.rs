//! A panic through VM frames with `RUST_BACKTRACE=1`: the backtrace walks the machine code
//! of VM functions (their unwind information and symbols) into native frames. The guard's
//! drop, which runs in `outer`'s landing pad while the panic unwinds, captures one of its own.
//! Built with line tables against the ryo sysroot, the frames have source locations, `helper`
//! (a trait method MIR-inlined into `mid`, named by its symbol as cg_llvm's would be) and `via` (which the JIT inlines, but not the MIR inliner) as
//! frames of their own; the `@name` comments mark the lines the check expects.
#![feature(rustc_attrs)]
#![allow(internal_features)]
use std::hint::black_box;

struct Guard;
impl Drop for Guard {
    fn drop(&mut self) {
        println!("guard dropped");
        eprintln!("drop backtrace:\n{}", std::backtrace::Backtrace::force_capture());
    }
}

#[inline(never)]
fn inner(x: u32) -> u32 {
    if black_box(x) > 2 {
        panic!("deep {x}"); // @inner
    }
    x
}

#[rustc_no_mir_inline]
fn via(x: u32) -> u32 {
    inner(x) + 3 // @via
}

trait Help {
    fn helper(&self, x: u32) -> u32;
}

struct H;
impl Help for H {
    #[inline]
    fn helper(&self, x: u32) -> u32 {
        via(x) + 1 // @helper
    }
}

/// Calls `via` at a site without a landing pad, where the JIT inlines it.
#[inline(never)]
fn mid(x: u32) -> u32 {
    H.helper(x) * 2 // @mid
}

#[inline(never)]
fn outer(x: u32) -> u32 {
    let _g = Guard;
    mid(x) + 1 // @outer
}

fn main() {
    let r = std::panic::catch_unwind(|| outer(black_box(7))); // @main
    println!("caught: {}", r.is_err());
}
