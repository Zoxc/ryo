//! The C ABI sweep: VM code calling `extern "C"` functions (native callees, the inline asm
//! keeps them so), directly and through fn pointers, and native callers of the same callees
//! for comparison. SysV covers integer extension (`zeroext`/`signext`, in registers and on the
//! stack), floats, `i128`, aggregates classified per eightbyte (INTEGER, SSE, mixed, a short
//! tail), `byval` aggregates, returns in mixed registers and sret, and the all-or-nothing rule
//! for aggregates that don't fit in the registers left. On Win64 the same calls go through the
//! `call_cN` island; the output is diffed against plain rustc either way.
#![feature(f16)]
use std::arch::asm;
use std::hint::black_box;

/// Keeps the function it is in native: the VM doesn't run inline asm.
macro_rules! native {
    () => {
        unsafe { asm!("", options(nomem, nostack, preserves_flags)) }
    };
}

/// A case: the native `extern "C"` callee `$name::callee`, VM callers `direct` and `ptr`
/// (through a fn pointer), and a native caller.
macro_rules! case {
    ($name:ident ($($a:ident: $t:ty = $v:expr),* $(,)?) -> $r:ty $body:block) => {
        mod $name {
            #[allow(unused_imports)]
            use super::*;
            #[inline(never)]
            pub extern "C" fn callee($($a: $t),*) -> $r {
                native!();
                $body
            }
            #[inline(never)]
            pub fn direct() -> $r {
                callee($(black_box($v)),*)
            }
            #[inline(never)]
            pub fn ptr() -> $r {
                let f: extern "C" fn($($t),*) -> $r = black_box(callee);
                f($(black_box($v)),*)
            }
            #[inline(never)]
            pub fn native_caller() -> $r {
                native!();
                callee($(black_box($v)),*)
            }
            pub fn run() {
                println!("{}: {:?} {:?} {:?}", stringify!($name), direct(), ptr(), native_caller());
            }
        }
    };
}

/// A hash of the words, which notices any of them in the wrong place.
fn h(xs: &[u64]) -> u64 {
    xs.iter().fold(0x9e37_79b9_7f4a_7c15, |h: u64, &x| (h ^ x).wrapping_mul(0x100_0000_01b3))
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct F2 {
    a: f32,
    b: f32,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct DI {
    a: f64,
    b: i64,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct IFD {
    a: i32,
    b: f32,
    c: f64,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct S12 {
    a: u32,
    b: u32,
    c: u32,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct F3 {
    a: f32,
    b: f32,
    c: f32,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct S16 {
    a: u64,
    b: u64,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct D2 {
    a: f64,
    b: f64,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct S24 {
    a: u64,
    b: u64,
    c: u64,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct S32 {
    a: f64,
    b: f64,
    c: f64,
    d: f64,
}

#[repr(C, align(16))]
#[derive(Debug, Clone, Copy)]
struct A16 {
    a: u64,
    b: u64,
    c: u64,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct Bytes {
    a: [u8; 7],
    b: i16,
}


#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct H1 {
    a: f16,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct H3 {
    a: [f16; 3],
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct H5 {
    a: f32,
    b: f32,
    c: f16,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct B11 {
    a: [u8; 11],
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct S10 {
    a: u32,
    b: u32,
    c: u16,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct B3 {
    a: [u8; 3],
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct S64 {
    a: [u64; 8],
}

/// A returned value with neighbours that an oversized store would clobber.
#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct Around<T> {
    v: T,
    tail: [u8; 7],
}

case!(ext(a: u8 = 0xfe, b: i8 = -7, c: u16 = 0xfffe, d: i16 = -300, e: bool = true) -> i64 {
    a as i64 + b as i64 * 3 + c as i64 * 5 + d as i64 * 7 + e as i64 * 11
});
case!(ext_wide(a: i8 = -1, b: i16 = -2) -> (u64, u64) { (a as i32 as u32 as u64, b as i64 as u64) });
case!(ret_i8(a: i8 = -5) -> i8 { a.wrapping_mul(3) });
case!(ret_u16(a: u16 = 40000) -> u16 { a.wrapping_add(30000) });
case!(ret_bool(a: u32 = 7) -> bool { a % 2 == 1 });
case!(floats(a: f32 = 1.5, b: f64 = -2.25, c: f32 = 0.125) -> f32 { a * 2.0 + b as f32 - c });
case!(ret_f64(a: f32 = 3.5, b: u8 = 2) -> f64 { a as f64 * b as f64 });
case!(wide(a: i128 = -0x0123_4567_89ab_cdef_0011, b: u128 = u128::MAX / 7) -> i128 { a.wrapping_mul(3) ^ b as i128 });
case!(f2(a: F2 = F2 { a: 1.0, b: 2.5 }, b: f32 = 4.0) -> F2 { F2 { a: a.b * b, b: a.a - b } });
case!(di(a: DI = DI { a: 0.5, b: -9 }, b: u8 = 3) -> DI { DI { a: a.a * 4.0, b: a.b * b as i64 } });
case!(ifd(a: IFD = IFD { a: -3, b: 1.25, c: 6.5 }) -> IFD { IFD { a: a.a * 2, b: a.b + 1.0, c: a.c / 2.0 } });
case!(s12(a: S12 = S12 { a: 1, b: 2, c: 3 }, b: S12 = S12 { a: 4, b: 5, c: 6 }) -> S12 {
    S12 { a: a.c + b.a, b: a.b * b.b, c: a.a ^ b.c }
});
case!(f3(a: F3 = F3 { a: 1.0, b: 2.0, c: 3.0 }) -> F3 { F3 { a: a.c, b: a.a + a.b, c: a.b * 0.5 } });
case!(s16(a: S16 = S16 { a: 10, b: 20 }, b: u32 = 3) -> S16 { S16 { a: a.b * b as u64, b: a.a + 1 } });
case!(d2(a: D2 = D2 { a: 1.5, b: 2.5 }) -> D2 { D2 { a: a.b * 2.0, b: a.a - 1.0 } });
case!(bytes(a: Bytes = Bytes { a: [1, 2, 3, 4, 5, 6, 7], b: -2 }) -> Bytes {
    Bytes { a: [a.a[6], a.a[5], a.a[4], a.a[3], a.a[2], a.a[1], a.a[0]], b: a.b * 3 }
});
case!(s24(a: S24 = S24 { a: 1, b: 2, c: 3 }, b: u8 = 4) -> S24 { S24 { a: a.c + b as u64, b: a.a, c: a.b * 2 } });
case!(s32(a: S32 = S32 { a: 1.0, b: 2.0, c: 3.0, d: 4.0 }, b: f64 = 0.5) -> S32 {
    S32 { a: a.d * b, b: a.c, c: a.b + b, d: a.a }
});
case!(byval_mix(a: u64 = 1, b: S24 = S24 { a: 2, b: 3, c: 4 }, c: S12 = S12 { a: 5, b: 6, c: 7 }, d: S32 = S32 { a: 8.0, b: 9.0, c: 10.0, d: 11.0 }, e: f64 = 12.0) -> u64 {
    h(&[a, b.a, b.b, b.c, c.a as u64, c.b as u64, c.c as u64, d.a as u64, d.b as u64, d.c as u64, d.d as u64, e as u64])
});
case!(byval_align(a: u64 = 1, b: u64 = 2, c: u64 = 3, d: u64 = 4, e: u64 = 5, f: u64 = 6, g: u64 = 7, i: A16 = A16 { a: 8, b: 9, c: 10 }, j: u64 = 11) -> u64 {
    h(&[a, b, c, d, e, f, g, i.a, i.b, i.c, j])
});
case!(spill(a: f64 = 1.0, b: f64 = 2.0, c: f64 = 3.0, d: f64 = 4.0, e: f64 = 5.0, f: f64 = 6.0, g: f64 = 7.0, i: f64 = 8.0, j: f32 = 9.0, k: f64 = 10.0,
        l: u64 = 11, m: u64 = 12, n: u64 = 13, o: u64 = 14, p: u64 = 15, q: u64 = 16, r: i8 = -17, s: u16 = 18, t: i16 = -19, u: bool = true, v: u8 = 200) -> f64 {
    a + b * 2.0 + c * 3.0 + d * 4.0 + e * 5.0 + f * 6.0 + g * 7.0 + i * 8.0 + j as f64 * 9.0 + k * 10.0
        + h(&[l, m, n, o, p, q]) as u32 as f64 + r as f64 * 100.0 + s as f64 * 1000.0 + t as f64 * 3.0 + u as u8 as f64 + v as f64 * 7.0
});
case!(all_or_nothing_int(a: u64 = 1, b: u64 = 2, c: u64 = 3, d: u64 = 4, e: u64 = 5, f: S16 = S16 { a: 6, b: 7 }, g: u64 = 8) -> u64 {
    h(&[a, b, c, d, e, f.a, f.b, g])
});
case!(all_or_nothing_sse(a: f64 = 1.0, b: f64 = 2.0, c: f64 = 3.0, d: f64 = 4.0, e: f64 = 5.0, f: f64 = 6.0, g: f64 = 7.0, i: D2 = D2 { a: 8.0, b: 9.0 }, j: f64 = 10.0) -> f64 {
    a + b * 2.0 + c * 3.0 + d * 4.0 + e * 5.0 + f * 6.0 + g * 7.0 + i.a * 8.0 + i.b * 9.0 + j * 10.0
});
case!(all_or_nothing_mixed(a: u64 = 1, b: u64 = 2, c: u64 = 3, d: u64 = 4, e: u64 = 5, f: DI = DI { a: 6.5, b: 7 }, g: IFD = IFD { a: 8, b: 9.5, c: 10.5 }) -> f64 {
    h(&[a, b, c, d, e]) as u32 as f64 + f.a + f.b as f64 * 2.0 + g.a as f64 * 3.0 + g.b as f64 * 4.0 + g.c * 5.0
});
case!(wide_late(a: u64 = 1, b: u64 = 2, c: u64 = 3, d: u64 = 4, e: u64 = 5, f: i128 = -6, g: u64 = 7) -> i128 {
    f.wrapping_mul(h(&[a, b, c, d, e, g]) as i128)
});
case!(unit_ret(a: u32 = 1) -> () {
    black_box(a);
});

case!(h1(a: H1 = H1 { a: 1.5 }, b: f16 = 2.0) -> H1 { H1 { a: a.a * b } });
case!(h1_ret(a: f32 = 1.5) -> H1 { H1 { a: a as f16 } });
case!(h3(a: H3 = H3 { a: [1.0, 2.0, 3.0] }) -> f32 { a.a[0] as f32 + a.a[1] as f32 * 2.0 + a.a[2] as f32 * 3.0 });
case!(h3_ret(a: f32 = 1.5) -> H3 { H3 { a: [a as f16, 2.0, 3.0] } });
case!(h5_ret(a: f32 = 1.5) -> H5 { H5 { a, b: 2.0, c: 3.0 } });
case!(b11(a: B11 = B11 { a: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] }) -> B11 { let mut b = a; b.a.reverse(); b });
case!(s10(a: S10 = S10 { a: 1, b: 2, c: 3 }) -> S10 { S10 { a: a.c as u32, b: a.a, c: a.b as u16 } });
case!(b3(a: B3 = B3 { a: [1, 2, 3] }) -> B3 { B3 { a: [a.a[2], a.a[0], a.a[1]] } });
case!(s64(a: u8 = 1, b: S64 = S64 { a: [1, 2, 3, 4, 5, 6, 7, 8] }, c: i16 = -3) -> u64 { h(&b.a) ^ a as u64 ^ c as u64 });

/// Returns stored into a field directly: only the value's bytes may change.
#[inline(never)]
fn around() -> (Around<H1>, Around<H3>, Around<B3>, Around<S10>) {
    let tail = [1, 2, 3, 4, 5, 6, 7];
    let mut a = Around { v: H1 { a: 0.0 }, tail };
    a.v = h1_ret::callee(black_box(2.5));
    let mut b = Around { v: H3 { a: [0.0; 3] }, tail };
    b.v = h3_ret::callee(black_box(2.5));
    let mut c = Around { v: B3 { a: [0; 3] }, tail };
    c.v = b3::callee(black_box(B3 { a: [4, 5, 6] }));
    let mut d = Around { v: S10 { a: 0, b: 0, c: 0 }, tail };
    d.v = s10::callee(black_box(S10 { a: 4, b: 5, c: 6 }));
    (a, b, c, d)
}

/// Calls of libc functions (`extern "C"` callees from another library).
#[inline(never)]
fn libc_calls() -> (i32, usize, i32) {
    unsafe extern "C" {
        fn abs(x: i32) -> i32;
        fn strlen(s: *const u8) -> usize;
        fn memcmp(a: *const u8, b: *const u8, n: usize) -> i32;
    }
    let s = black_box(b"hello\0");
    unsafe { (abs(black_box(-42)), strlen(s.as_ptr()), memcmp(s.as_ptr(), b"help".as_ptr(), 4).signum()) }
}

fn main() {
    ext::run();
    ext_wide::run();
    ret_i8::run();
    ret_u16::run();
    ret_bool::run();
    floats::run();
    ret_f64::run();
    wide::run();
    f2::run();
    di::run();
    ifd::run();
    s12::run();
    f3::run();
    s16::run();
    d2::run();
    bytes::run();
    s24::run();
    s32::run();
    byval_mix::run();
    byval_align::run();
    spill::run();
    all_or_nothing_int::run();
    all_or_nothing_sse::run();
    all_or_nothing_mixed::run();
    wide_late::run();
    unit_ret::run();
    for f in [h1::run, h1_ret::run, h3::run, h3_ret::run, h5_ret::run, b11::run, s10::run, b3::run, s64::run] {
        f();
    }
    println!("around: {:?}", around());
    println!("libc: {:?}", libc_calls());
}
