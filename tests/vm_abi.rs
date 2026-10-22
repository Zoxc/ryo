//! The ABI sweep (design/build.md#test-and-bench): values of every kind of `PassMode` passed
//! and returned between VM and native code, both ways, directly and through fn pointers,
//! with enough arguments to run out of registers. Each case defines the same body as a VM
//! function and as a native one (inline asm keeps a function native), and callers between
//! them; the output is diffed against plain rustc.
#![feature(f16, f128)]
use std::arch::asm;
use std::hint::black_box;
use std::marker::PhantomData;
use std::num::NonZeroU32;
use std::panic::Location;

/// Keeps the function it is in native: the VM doesn't run inline asm.
macro_rules! native {
    () => {
        unsafe { asm!("", options(nomem, nostack, preserves_flags)) }
    };
}

/// A case: `$name::vm` and `$name::native` with the same signature and body, the four
/// direct calls between them, and calls through fn pointers from VM and native code.
macro_rules! case {
    ($name:ident ($($a:ident: $t:ty = $v:expr),* $(,)?) -> $r:ty $body:block) => {
        mod $name {
            #[allow(unused_imports)]
            use super::*;
            #[inline(never)]
            pub fn vm($($a: $t),*) -> $r $body
            #[inline(never)]
            pub fn native($($a: $t),*) -> $r {
                native!();
                $body
            }
            #[inline(never)]
            pub fn vm_to_native($($a: $t),*) -> $r {
                native($($a),*)
            }
            #[inline(never)]
            pub fn native_to_vm($($a: $t),*) -> $r {
                native!();
                vm($($a),*)
            }
            #[inline(never)]
            pub fn vm_to_vm($($a: $t),*) -> $r {
                vm($($a),*)
            }
            #[inline(never)]
            pub fn vm_ptrs() -> [$r; 2] {
                let f: fn($($t),*) -> $r = black_box(vm);
                let g: fn($($t),*) -> $r = black_box(native);
                [f($($v),*), g($($v),*)]
            }
            #[inline(never)]
            pub fn native_ptrs() -> [$r; 2] {
                native!();
                let f: fn($($t),*) -> $r = black_box(vm);
                let g: fn($($t),*) -> $r = black_box(native);
                [f($($v),*), g($($v),*)]
            }
            pub fn run() {
                let direct = [vm($($v),*), native($($v),*), vm_to_native($($v),*), native_to_vm($($v),*), vm_to_vm($($v),*)];
                println!("{}: {:?} {:?} {:?}", stringify!($name), direct, vm_ptrs(), native_ptrs());
            }
        }
    };
}

/// A hash of the words, which notices any of them in the wrong place.
fn h(xs: &[u64]) -> u64 {
    xs.iter().fold(0x9e37_79b9_7f4a_7c15, |h: u64, &x| (h ^ x).wrapping_mul(0x100_0000_01b3))
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum E {
    A,
    B(u32, f64),
    C([u8; 20]),
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct CS {
    a: u32,
    b: f32,
    c: u64,
}

case!(unit() -> () {});
case!(ints(a: u8 = 0xfe, b: i16 = -3, c: u32 = 70000, d: i64 = -5_000_000_000, e: usize = 7) -> u64 {
    h(&[a as u64, b as u64, c as u64, d as u64, e as u64])
});
case!(narrow(a: bool = true, b: char = 'λ', c: i8 = -7) -> (bool, char, i8) { (!a, b, c.wrapping_mul(2)) });
case!(wide(a: u128 = 0x0123_4567_89ab_cdef_fedc_ba98_7654_3210, b: i128 = -99) -> u128 {
    a.wrapping_add(b as u128).rotate_left(7)
});
case!(wide_late(a: u64 = 1, b: u64 = 2, c: u64 = 3, d: u64 = 4, e: u64 = 5, f: u128 = u128::MAX / 3, g: u64 = 7) -> u128 {
    f ^ (h(&[a, b, c, d, e, g]) as u128)
});
case!(floats(a: f32 = 1.5, b: f64 = -2.25, c: f32 = 3.0) -> f64 { a as f64 * 2.0 + b - c as f64 / 4.0 });
case!(float_pair(a: (f32, f32) = (1.0, 2.0)) -> (f32, f32) { (a.1, a.0 + 0.5) });
case!(mixed_pair(a: (f64, u64) = (0.5, 9), b: (u32, f32) = (3, 0.25)) -> (u64, f64) {
    (a.1 + b.0 as u64, a.0 * 4.0 + b.1 as f64)
});
case!(xmm_gpr(a: f32 = 2.5, b: u32 = 8) -> (u32, f32) { (b * 3, a / 2.0) });
case!(many_f64(a: f64 = 1.0, b: f64 = 2.0, c: f64 = 3.0, d: f64 = 4.0, e: f64 = 5.0, f: f64 = 6.0, g: f64 = 7.0, i: f64 = 8.0, j: f64 = 9.0, k: f64 = 10.0, l: f32 = 11.0) -> f64 {
    a + b * 2.0 + c * 3.0 + d * 4.0 + e * 5.0 + f * 6.0 + g * 7.0 + i * 8.0 + j * 9.0 + k * 10.0 + l as f64 * 11.0
});
case!(many_u64(a: u64 = 1, b: u64 = 2, c: u64 = 3, d: u64 = 4, e: u64 = 5, f: u64 = 6, g: u64 = 7, i: u64 = 8, j: u8 = 9, k: u16 = 10) -> u64 {
    h(&[a, b, c, d, e, f, g, i, j as u64, k as u64])
});
case!(interleaved(a: u64 = 1, b: f64 = 2.5, c: u32 = 3, d: f32 = 4.5, e: u64 = 5, f: f64 = 6.5, g: u8 = 7, i: f64 = 8.5, j: u64 = 9, k: f64 = 10.5, l: u64 = 11, m: f64 = 12.5, n: i64 = -13, o: f32 = 14.5, p: u64 = 15, q: f64 = 16.5, r: u16 = 17, s: f64 = 18.5) -> (u64, f64) {
    (h(&[a, c as u64, e, g as u64, j, l, n as u64, p, r as u64]), b + d as f64 * 2.0 + f * 3.0 + i * 4.0 + k * 5.0 + m * 6.0 + o as f64 * 7.0 + q * 8.0 + s * 9.0)
});
case!(pair_split(a: u64 = 1, b: u64 = 2, c: u64 = 3, d: u64 = 4, e: u64 = 5, p: (u64, u64) = (6, 7), q: u8 = 8) -> (u64, u64) {
    (p.1 ^ h(&[a, b, c, d, e]), p.0 + q as u64)
});
case!(slices(s: &[u8] = &[1, 2, 3, 4], t: &str = "héllo") -> (usize, u8) { (t.len() * 10 + s.len(), s[2].wrapping_add(t.as_bytes()[1])) });
case!(bytes3(a: [u8; 3] = [1, 2, 3]) -> [u8; 3] { [a[2], a[0], a[1].wrapping_add(1)] });
case!(bytes5(a: [u8; 5] = [1, 2, 3, 4, 5], b: u8 = 6) -> [u8; 5] { [a[4], a[3], a[2], a[1], a[0].wrapping_add(b)] });
case!(bytes6(a: [u16; 3] = [1, 2, 3]) -> [u16; 3] { [a[1], a[2], a[0] + 9] });
case!(bytes7(a: [u8; 7] = [1, 2, 3, 4, 5, 6, 7]) -> [u8; 7] { [a[6], a[5], a[4], a[3], a[2], a[1], a[0] + 1] });
case!(three_u32(a: (u32, u32, u32) = (1, 2, 3), b: u8 = 4) -> (u32, u32, u32) { (a.2 + b as u32, a.0, a.1) });
case!(quad_f32(a: [f32; 4] = [1.0, 2.0, 3.0, 4.0]) -> [f32; 4] { [a[3], a[2] * 2.0, a[1], a[0] - 1.0] });
case!(big(a: [u64; 6] = [1, 2, 3, 4, 5, 6], b: u8 = 7) -> [u64; 6] { [a[5], a[4], a[3], a[2], a[1], h(&a) ^ b as u64] });
case!(big_late(a: u64 = 1, b: u64 = 2, c: u64 = 3, d: u64 = 4, e: u64 = 5, f: u64 = 6, g: [u64; 3] = [7, 8, 9], i: (u32, u32, u32) = (10, 11, 12), j: f64 = 13.0) -> u64 {
    h(&[a, b, c, d, e, f, g[0], g[1], g[2], i.0 as u64, i.1 as u64, i.2 as u64, j as u64])
});
case!(opt_wide(a: Option<u128> = Some(5), b: Option<u128> = None) -> Option<u128> { a.map(|x| x + b.unwrap_or(7)) });
case!(niches(a: Option<&u64> = Some(&42), b: Option<NonZeroU32> = NonZeroU32::new(3), c: Result<u32, u8> = Err(4)) -> (u64, u32, u32) {
    (a.copied().unwrap_or(1), b.map_or(0, |x| x.get()), match c { Ok(x) => x, Err(e) => e as u32 + 100 })
});
case!(enums(a: E = E::B(3, 4.5), b: E = E::C([7; 20])) -> E {
    match (a, b) {
        (E::B(x, y), E::C(z)) => E::B(x + z[0] as u32, y * 2.0),
        _ => E::A,
    }
});
case!(zsts(a: () = (), b: u32 = 5, c: PhantomData<u8> = PhantomData, d: u64 = 9) -> (u64, (), PhantomData<u8>) { (b as u64 * d, a, c) });
case!(f16s(a: f16 = 1.5, b: f16 = 2.0, c: f32 = 3.0) -> (f16, f32) { (f16::from_bits(a.to_bits() ^ b.to_bits() >> 3), c * 2.0) });
case!(f128s(a: f128 = 1.25, b: u8 = 3) -> f128 { f128::from_bits(a.to_bits().wrapping_add(b as u128)) });

/// `#[track_caller]`: the location is an extra last argument.
#[track_caller]
#[inline(never)]
fn here_vm(x: u32) -> (u32, u32) {
    (x, Location::caller().line())
}

#[track_caller]
#[inline(never)]
fn here_native(x: u32) -> (u32, u32) {
    native!();
    (x, Location::caller().line())
}

#[inline(never)]
fn track_caller_vm() -> [(u32, u32); 2] {
    [here_vm(1), here_native(2)]
}

#[inline(never)]
fn track_caller_native() -> [(u32, u32); 2] {
    native!();
    [here_vm(3), here_native(4)]
}

/// Closures and trait objects: calls through vtables, both ways.
trait Shape {
    fn big(&self, k: u8) -> [u64; 4];
    fn small(&self, x: f32, y: (u8, u16)) -> f32;
}

struct VmShape(u64);
struct NativeShape(u64);

impl Shape for VmShape {
    fn big(&self, k: u8) -> [u64; 4] {
        [self.0, k as u64, self.0 * 2, 9]
    }
    fn small(&self, x: f32, y: (u8, u16)) -> f32 {
        x * self.0 as f32 + y.0 as f32 - y.1 as f32
    }
}

impl Shape for NativeShape {
    fn big(&self, k: u8) -> [u64; 4] {
        native!();
        [self.0, k as u64, self.0 * 2, 9]
    }
    fn small(&self, x: f32, y: (u8, u16)) -> f32 {
        native!();
        x * self.0 as f32 + y.0 as f32 - y.1 as f32
    }
}

#[inline(never)]
fn shapes_vm(s: &[&dyn Shape]) -> Vec<([u64; 4], f32)> {
    s.iter().map(|s| (s.big(3), s.small(1.5, (2, 3)))).collect()
}

#[inline(never)]
fn shapes_native(s: &[&dyn Shape]) -> Vec<([u64; 4], f32)> {
    native!();
    let mut out = Vec::new();
    for s in s {
        out.push((s.big(4), s.small(2.5, (5, 1))));
    }
    out
}

#[inline(never)]
fn closures_vm(f: &dyn Fn(u64, f64) -> (u64, f64), g: impl FnOnce([u8; 5]) -> [u8; 5]) -> ((u64, f64), [u8; 5]) {
    (f(3, 0.5), g([1, 2, 3, 4, 5]))
}

#[inline(never)]
fn closures_native(f: &dyn Fn(u64, f64) -> (u64, f64), g: impl FnOnce([u8; 5]) -> [u8; 5]) -> ((u64, f64), [u8; 5]) {
    native!();
    (f(4, 1.5), g([5, 4, 3, 2, 1]))
}

/// `extern "C"`: native (the VM only defines Rust-ABI functions), called from VM code.
#[inline(never)]
extern "C" fn c_fn(a: u8, b: f64, c: CS, d: u64) -> CS {
    CS { a: c.a + a as u32, b: c.b * 2.0 + b as f32, c: c.c ^ d }
}

#[inline(never)]
fn c_calls() -> CS {
    c_fn(1, 2.5, CS { a: 3, b: 4.5, c: 5 }, 6)
}

fn main() {
    unit::run();
    ints::run();
    narrow::run();
    wide::run();
    wide_late::run();
    floats::run();
    float_pair::run();
    mixed_pair::run();
    xmm_gpr::run();
    many_f64::run();
    many_u64::run();
    interleaved::run();
    pair_split::run();
    slices::run();
    bytes3::run();
    bytes5::run();
    bytes6::run();
    bytes7::run();
    three_u32::run();
    quad_f32::run();
    big::run();
    big_late::run();
    opt_wide::run();
    niches::run();
    enums::run();
    zsts::run();
    f16s::run();
    f128s::run();
    println!("track_caller: {:?} {:?}", track_caller_vm(), track_caller_native());
    let (v, n) = (VmShape(5), NativeShape(6));
    let s: [&dyn Shape; 2] = [&v, &n];
    println!("shapes: {:?} {:?}", shapes_vm(&s), shapes_native(&s));
    let k = black_box(10u64);
    let f = move |a: u64, b: f64| (a + k, b * k as f64);
    let fv = |a: [u8; 5]| [a[4], a[3], a[2], a[1], a[0] + k as u8];
    println!("closures: {:?} {:?}", closures_vm(&f, fv), closures_native(&f, fv));
    println!("extern C: {:?}", c_calls());
}
