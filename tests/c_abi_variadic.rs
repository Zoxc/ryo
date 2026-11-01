//! Calls of C-variadic functions from VM code: libc's `snprintf` with integers, doubles,
//! strings and mixes (more than eight doubles: the rest on the stack; SysV's `al`, Win64's
//! doubles mirrored in integer registers), and a native Rust variadic fn (`va_list`, which
//! stays native) summing what it gets.
use std::arch::asm;
use std::ffi::{CStr, c_char, c_double, c_int, c_long};
use std::hint::black_box;

/// Keeps the function it is in native: the VM doesn't run inline asm.
macro_rules! native {
    () => {
        unsafe { asm!("", options(nomem, nostack, preserves_flags)) }
    };
}

// UCRT's `snprintf` is an inline function in its headers; this library has the symbol.
#[cfg_attr(windows, link(name = "legacy_stdio_definitions"))]
unsafe extern "C" {
    fn snprintf(buf: *mut c_char, n: usize, fmt: *const c_char, ...) -> c_int;
}

fn show(buf: &[u8; 256], n: c_int) {
    let s = CStr::from_bytes_until_nul(buf).unwrap().to_str().unwrap();
    println!("{n}: {s}");
}

#[inline(never)]
fn ints() {
    let mut buf = [0u8; 256];
    let n = unsafe { snprintf(buf.as_mut_ptr().cast(), buf.len(), c"%d %u %ld %lld".as_ptr(), black_box(-5), 7u32, -9 as c_long, 1i64 << 40) };
    show(&buf, n);
}

#[inline(never)]
fn doubles() {
    let mut buf = [0u8; 256];
    let n = unsafe { snprintf(buf.as_mut_ptr().cast(), buf.len(), c"%.2f %.3e %g".as_ptr(), black_box(1.5), 2.25e10, -0.125) };
    show(&buf, n);
}

#[inline(never)]
fn mixed() {
    let mut buf = [0u8; 256];
    let s = c"str";
    let n = unsafe {
        snprintf(buf.as_mut_ptr().cast(), buf.len(), c"%d %.1f %s %.2f %c %lld".as_ptr(), black_box(1), 2.5, s.as_ptr(), black_box(-3.75), b'x' as c_int, -4i64)
    };
    show(&buf, n);
}

/// Ten doubles: eight in `xmm0`–`xmm7` (SysV), two on the stack.
#[inline(never)]
fn many_doubles() {
    let mut buf = [0u8; 256];
    let d = black_box(0.5);
    let n = unsafe {
        snprintf(
            buf.as_mut_ptr().cast(),
            buf.len(),
            c"%g %g %g %g %g %g %g %g %g %g".as_ptr(),
            d,
            d + 1.0,
            d + 2.0,
            d + 3.0,
            d + 4.0,
            d + 5.0,
            d + 6.0,
            d + 7.0,
            d + 8.0,
            d + 9.0,
        )
    };
    show(&buf, n);
}

/// Many integers and doubles interleaved: both classes spill to the stack.
#[inline(never)]
fn many_mixed() {
    let mut buf = [0u8; 256];
    let i = black_box(10);
    let d = black_box(0.25);
    let n = unsafe {
        snprintf(
            buf.as_mut_ptr().cast(),
            buf.len(),
            c"%d %g %d %g %d %g %d %g %d %g %d %g %d %g %d %g %d %g %lld".as_ptr(),
            i,
            d,
            i + 1,
            d * 2.0,
            i + 2,
            d * 3.0,
            i + 3,
            d * 4.0,
            i + 4,
            d * 5.0,
            i + 5,
            d * 6.0,
            i + 6,
            d * 7.0,
            i + 7,
            d * 8.0,
            i + 8,
            d * 9.0,
            -1i64,
        )
    };
    show(&buf, n);
}

/// A variadic Rust fn: `n` pairs of a tag (`0` an `int`, else a `double`) and the value.
/// Defining a variadic fn stays native.
unsafe extern "C" fn sum(n: c_int, mut args: ...) -> c_double {
    let mut s = 0.0;
    for _ in 0..n {
        let tag: c_int = unsafe { args.next_arg() };
        s += if tag == 0 { f64::from(unsafe { args.next_arg::<c_int>() }) } else { unsafe { args.next_arg::<c_double>() } };
    }
    s
}

#[inline(never)]
fn rust_variadic() {
    let x = black_box(3);
    println!("sum0 {}", unsafe { sum(0) });
    println!("sum2 {}", unsafe { sum(2, 0, x, 1, 0.5) });
    let y = black_box(1.25);
    println!(
        "sum9 {}",
        unsafe { sum(9, 1, y, 0, x, 1, y * 2.0, 1, y * 3.0, 0, x * 2, 1, y * 4.0, 1, y * 5.0, 1, y * 6.0, 1, y * 7.0) }
    );
}

/// Through a fn pointer (Win64 only: SysV's `al` and the callee pointer would share `rax`).
#[inline(never)]
fn via_ptr() {
    let f: unsafe extern "C" fn(c_int, ...) -> c_double = black_box(sum);
    println!("ptr {}", unsafe { f(3, 1, 0.5, 0, 4, 1, 1.5) });
}

#[inline(never)]
fn native_caller() {
    native!();
    println!("native {}", unsafe { sum(2, 1, 2.5, 0, 4) });
}

fn main() {
    ints();
    doubles();
    mixed();
    many_doubles();
    many_mixed();
    rust_variadic();
    via_ptr();
    native_caller();
    // A hot loop, for the JIT.
    let mut t = 0.0;
    for i in 0..3000 {
        t += unsafe { sum(2, 0, i as c_int, 1, 0.5) };
    }
    println!("loop {t}");
}
