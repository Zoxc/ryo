//! Integer and float arithmetic, overflow helpers, bit ops, 128-bit integers.
use std::hint::black_box;

fn main() {
    let a: i32 = black_box(-17);
    let b: i32 = black_box(5);
    println!("{} {} {} {} {}", a + b, a - b, a * b, a / b, a % b);
    println!("{} {}", a.rem_euclid(b), a.div_euclid(b));
    println!("{:?} {:?}", i32::MAX.checked_add(black_box(1)), 200u8.checked_mul(black_box(2)));
    println!("{} {}", i32::MAX.wrapping_add(black_box(1)), 250u8.saturating_add(black_box(10)));
    println!("{:?}", 7u32.overflowing_sub(black_box(9)));
    let x: u64 = black_box(0xdead_beef_1234_5678);
    println!(
        "{:x} {:x} {} {} {}",
        x.rotate_left(13),
        x.swap_bytes(),
        x.count_ones(),
        x.leading_zeros(),
        x >> 7
    );
    let big: u128 = black_box(u128::MAX / 3);
    let s: i128 = black_box(i128::MIN);
    println!("{} {} {}", big, big.wrapping_mul(7), s / 3);
    let f: f64 = black_box(2.5);
    let g: f32 = black_box(-0.1);
    println!("{} {} {:.6} {} {}", f * f, f.sqrt(), (g as f64).sin(), f.powi(3), g.abs());
    println!("{} {} {}", f as i32, black_box(-1.9f64) as u8, black_box(300.7f32) as u8);
    println!("{} {}", f64::NAN.max(1.0), (black_box(0.1f64) + 0.2).to_bits());
    let mut acc = 0u64;
    for i in 0..black_box(1000u64) {
        acc = acc.wrapping_mul(31).wrapping_add(i ^ (i << 3));
    }
    println!("{acc}");
}
