//! Numeric and pointer casts.
include!("common/print.rs");
use std::hint::black_box;

fn main() {
    let a: i64 = black_box(-1);
    out::us(&[a as u8 as u128, a as u16 as u128, a as u32 as u128, a as u64 as u128, a as u128]);
    let b: u8 = black_box(200);
    out::is(&[b as i8 as i128, b as i32 as i128, (b as i8) as i64 as i128, -(b as i16) as i128]);
    let c: i128 = black_box(-12345678901234567890123456789);
    out::is(&[c as i64 as i128, c as i32 as i128, c as u64 as i128, c as i16 as i128]);
    // float -> int saturates, NaN -> 0
    let f: f64 = black_box(-1.9);
    let g: f32 = black_box(300.7);
    out::is(&[f as i32 as i128, f as u8 as i128, g as u8 as i128, g as i8 as i128, black_box(f64::NAN) as i32 as i128]);
    out::is(&[black_box(1e30f64) as i64 as i128, black_box(-1e30f64) as i64 as i128, black_box(f32::INFINITY) as u16 as i128]);
    out::is(&[black_box(1e40f64) as u128 as i128, black_box(-3.99f32) as i128]);
    // int -> float, float -> float
    let h: u64 = black_box(u64::MAX);
    out::hex((h as f64).to_bits() as u128);
    out::sp();
    out::hex((h as f32).to_bits() as u128);
    out::sp();
    out::hex((black_box(-7i8) as f32).to_bits() as u128);
    out::sp();
    out::hex((black_box(0.1f64) as f32).to_bits() as u128);
    out::sp();
    out::hex((black_box(0.1f32) as f64).to_bits() as u128);
    out::sp();
    out::hex((black_box(u128::MAX) as f32).to_bits() as u128);
    out::nl();
    // bool / char
    out::us(&[black_box(true) as u128, black_box(false) as u8 as u128, black_box('é') as u32 as u128, black_box(65u8) as char as u128]);
    // pointers
    let x = [1u32, 2, 3, 4];
    let p = x.as_ptr();
    let addr = p as usize;
    let q = (addr + 8) as *const u32;
    out::u(unsafe { *q } as u128);
    out::sp();
    let r = p.wrapping_add(3) as *const u8;
    out::u(unsafe { *r } as u128);
    out::sp();
    let s: *const [u32] = &x[1..];
    let t = s as *const u32;
    out::u(unsafe { *t } as u128);
    out::sp();
    out::u((p.wrapping_add(2) as usize - addr) as u128);
    out::nl();
    let fp: fn(u32) -> u32 = double;
    let fa = fp as usize;
    out::b(fa != 0);
    out::sp();
    out::u(fp(21) as u128);
    out::nl();
}

fn double(x: u32) -> u32 {
    x * 2
}
