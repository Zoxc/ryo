//! Backtraces through code the JIT inlines (design/vm.md#source-locations): `f1` → … → `f5`
//! are small and kept from rustc's MIR inliner (`rustc_no_mir_inline`), so with the JIT on
//! they become one physical frame, `f1`'s, whose call map must still give each of them with
//! its call's line. `argv[1]` picks the case, `argv[2]` the level that captures or panics.
//! Each backtrace follows a `== bt` line; the panic hook prints one.
#![feature(rustc_attrs)]
#![allow(internal_features)]
use std::backtrace::Backtrace;
use std::hint::black_box;

static mut KIND: u32 = 0;
static mut LEVEL: u32 = 0;

fn bt() {
    eprintln!("== bt\n{}", Backtrace::force_capture());
}

#[inline(never)]
fn native_capture() {
    bt();
}

#[rustc_no_mir_inline]
fn act(level: u32, x: u32) -> u32 {
    if level != unsafe { LEVEL } {
        return x;
    }
    match unsafe { KIND } {
        0 => panic!("explicit"),
        1 => black_box(u32::MAX) + black_box(x),
        2 => [1u32, 2][black_box(x as usize + 2)],
        _ => {
            native_capture();
            x
        }
    }
}

#[rustc_no_mir_inline]
fn f5(x: u32) -> u32 {
    act(5, x) + 1 // @f5
}
#[rustc_no_mir_inline]
fn f4(x: u32) -> u32 {
    f5(act(4, x)) + 1 // @f4
}
#[rustc_no_mir_inline]
fn f3(x: u32) -> u32 {
    f4(act(3, x)) + 1 // @f3
}
#[rustc_no_mir_inline]
fn f2(x: u32) -> u32 {
    f3(act(2, x)) + 1 // @f2
}
#[inline(never)]
fn f1(x: u32) -> u32 {
    f2(act(1, x)) + 1 // @f1
}

/// Inlined twice into `twice`, panicking from the second site.
#[rustc_no_mir_inline]
fn g(x: u32, panic: bool) -> u32 {
    if panic {
        panic!("g");
    }
    x + 1
}
#[inline(never)]
fn twice(x: u32) -> u32 {
    let a = g(x, false); // @first
    g(a, true) // @second
}

/// Inlined into a hot loop (entered by OSR), panicking on a late iteration.
#[inline(never)]
fn looping(n: u32) -> u32 {
    let mut s = 0u32;
    for i in 0..n {
        s = s.wrapping_add(g(i, i == n - 1)); // @loop
    }
    s
}

/// MIR-inlined into `jit_g`, which the JIT inlines into `mir_root`.
#[inline]
fn h(x: u32) -> u32 {
    act(1, x) + 2 // @h
}
#[rustc_no_mir_inline]
fn jit_g(x: u32) -> u32 {
    h(x) + 3 // @jit_g
}
#[inline(never)]
fn mir_root(x: u32) -> u32 {
    jit_g(x) + 4 // @mir_root
}

fn main() {
    std::panic::set_hook(Box::new(|_| bt()));
    let args: Vec<String> = std::env::args().collect();
    let level = args.get(2).and_then(|a| a.parse().ok()).unwrap_or(1);
    // Warm up with nothing to do, so that the JIT compiles (and inlines) first.
    for _ in 0..100 {
        black_box(f1(black_box(1)));
        black_box(mir_root(black_box(1)));
    }
    let kind = match args[1].as_str() {
        "panic" => 0,
        "add" => 1,
        "index" => 2,
        _ => 3,
    };
    unsafe {
        KIND = kind;
        LEVEL = level;
    }
    let r = std::panic::catch_unwind(|| match args[1].as_str() {
        "twice" => twice(black_box(1)),
        "loop" => looping(black_box(100_000)),
        "mir" => mir_root(black_box(1)),
        _ => f1(black_box(1)),
    });
    println!("done: {}", r.is_err());
}
