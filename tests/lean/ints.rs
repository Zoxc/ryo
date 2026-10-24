//! Integer arithmetic of every width: wrapping, checked, overflowing and saturating ops,
//! division, shifts, bit operations, 128-bit integers.
include!("common/print.rs");
use std::hint::black_box;

fn widths() {
    let a: i8 = black_box(-100);
    let b: i8 = black_box(57);
    out::is(&[(a.wrapping_add(b * 2)) as i128, a.wrapping_sub(b) as i128, a.wrapping_mul(b) as i128, (a / 7) as i128, (a % 7) as i128]);
    let c: u16 = black_box(60000);
    let d: u16 = black_box(7000);
    out::us(&[c.wrapping_add(d) as u128, c.wrapping_mul(d) as u128, (c / d) as u128, (c % d) as u128]);
    let e: i32 = black_box(-17);
    let f: i32 = black_box(5);
    out::is(&[(e + f) as i128, (e - f) as i128, (e * f) as i128, (e / f) as i128, (e % f) as i128]);
    out::is(&[e.rem_euclid(f) as i128, e.div_euclid(f) as i128, e.abs() as i128, e.signum() as i128, e.pow(3) as i128]);
    let g: u64 = black_box(0xdead_beef_1234_5678);
    out::us(&[g.rotate_left(13) as u128, g.swap_bytes() as u128, g.count_ones() as u128, g.leading_zeros() as u128, g.trailing_zeros() as u128]);
    out::us(&[(g >> 7) as u128, (g << 9) as u128, (g & 0xffff) as u128, (g | 1) as u128, (g ^ !g) as u128, g.reverse_bits() as u128]);
    let h: isize = black_box(-123456789);
    let k: usize = black_box(987654321);
    out::is(&[(h * 3) as i128, (h >> 3) as i128, (k as isize + h) as i128, (k / 1000) as i128]);
}

fn helpers() {
    let m: i32 = black_box(i32::MAX);
    out::b(m.checked_add(1).is_none());
    out::sp();
    out::b(200u8.checked_mul(black_box(2)).is_none());
    out::sp();
    out::i(m.wrapping_add(black_box(1)) as i128);
    out::sp();
    out::u(250u8.saturating_add(black_box(10)) as u128);
    out::sp();
    out::i((-120i8).saturating_sub(black_box(100)) as i128);
    out::nl();
    let (v, o) = 7u32.overflowing_sub(black_box(9));
    out::u(v as u128);
    out::sp();
    out::b(o);
    out::sp();
    let (v, o) = black_box(i64::MIN).overflowing_neg();
    out::i(v as i128);
    out::sp();
    out::b(o);
    out::sp();
    match black_box(10u32).checked_div(black_box(0)) {
        Some(x) => out::u(x as u128),
        None => out::str("none"),
    }
    out::sp();
    out::u(black_box(1u32).checked_shl(black_box(40)).unwrap_or(77) as u128);
    out::sp();
    out::u(black_box(0x80u8).wrapping_shl(black_box(9)) as u128);
    out::sp();
    out::i(black_box(-1i16).wrapping_shr(black_box(17)) as i128);
    out::nl();
    out::us(&[black_box(10u32).isqrt() as u128, black_box(1000u64).ilog10() as u128, black_box(100u32).next_power_of_two() as u128]);
    out::is(&[black_box(-7i32).max(3) as i128, black_box(-7i32).min(3) as i128, black_box(17i32).clamp(0, 10) as i128]);
}

fn wide() {
    let big: u128 = black_box(u128::MAX / 3);
    let s: i128 = black_box(i128::MIN);
    out::u(big);
    out::sp();
    out::u(big.wrapping_mul(7));
    out::sp();
    out::i(s / 3);
    out::sp();
    out::i(s % 1000000007);
    out::nl();
    let x: u128 = black_box(0x0123_4567_89ab_cdef_fedc_ba98_7654_3210);
    out::hex(x.rotate_right(20));
    out::sp();
    out::hex(x.swap_bytes());
    out::sp();
    out::u(x.leading_zeros() as u128);
    out::sp();
    out::hex(x >> 67);
    out::sp();
    out::hex(x << 3);
    out::nl();
    let (p, o) = x.overflowing_mul(black_box(1 << 100));
    out::hex(p);
    out::sp();
    out::b(o);
    out::sp();
    out::i((black_box(-5i128) * black_box(1_000_000_000_000_000_000i128)) / 7);
    out::nl();
}

fn main() {
    widths();
    helpers();
    wide();
    let mut acc = 0u64;
    for i in 0..black_box(300u64) {
        acc = acc.wrapping_mul(31).wrapping_add(i ^ (i << 3));
    }
    out::u(acc as u128);
    out::nl();
}
