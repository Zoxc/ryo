//! Milestone 4: integer, bool, char and float arithmetic, casts and overflow checks in the VM.
use std::hint::black_box;

fn ops32(a: i32, b: i32) -> [i32; 10] {
    [a + b, a - b, a * b, a / b, a % b, a & b, a | b, a ^ b, a << (b & 31), a >> (b & 31)]
}

fn ops_u8(a: u8, b: u8) -> (u8, u8, bool, bool, bool) {
    (a.wrapping_add(b), a.wrapping_mul(b), a < b, a >= b, a != b)
}

fn wide(a: u128, b: i128) -> (u128, i128, bool, u128) {
    (a + 1, b - 1, a > b as u128, a >> 3 | a << 7)
}

fn casts(x: i64) -> (u8, i16, u32, i128, f64, f32, char, bool) {
    (x as u8, x as i16, x as u32, x as i128, x as f64, x as f32, (x as u8 % 26 + b'a') as char, x != 0)
}

fn float_casts(f: f64) -> (i32, u8, i64, f32, u64) {
    (f as i32, f as u8, f as i64, f as f32, (f * 2.0) as u64)
}

fn floats(a: f64, b: f32) -> (f64, f64, f32, bool, bool) {
    (a * a - a / 3.0, -a % 7.0, b * 2.5 + 1.0, a < b as f64, a == a)
}

fn checked(a: u32, b: u32) -> u32 {
    // Overflow checks (debug): `Assert` with an overflow message.
    a * b + 1
}

fn chars(c: char) -> (u32, bool, char) {
    (c as u32, c.is_ascii_lowercase(), char::from_u32(c as u32 + 1).unwrap_or('?'))
}

fn bits(x: u64) -> (u32, u32, u32, u64, u64) {
    (x.count_ones(), x.leading_zeros(), x.trailing_zeros(), x.rotate_left(13), x.swap_bytes())
}

fn neg(x: i16, b: bool) -> (i16, i16, bool) {
    (-x, !x, !b)
}

fn cmp(a: i8, b: i8) -> std::cmp::Ordering {
    a.cmp(&b)
}

fn main() {
    println!("{:?}", ops32(black_box(-17), black_box(5)));
    println!("{:?}", ops_u8(black_box(200), black_box(100)));
    println!("{:?}", wide(black_box(0x3333_3333_3333_3333_3333_3333_3333_3333), black_box(i128::MIN + 7)));
    println!("{:?}", casts(black_box(-300)));
    println!("{:?}", casts(black_box(1 << 40)));
    println!("{:?}", float_casts(black_box(-1.5e10)));
    println!("{:?}", float_casts(black_box(f64::NAN)));
    println!("{:?}", float_casts(black_box(300.75)));
    println!("{:?}", floats(black_box(2.5), black_box(-0.25)));
    println!("{}", checked(black_box(1000), black_box(1000)));
    println!("{:?} {:?}", chars(black_box('q')), chars(black_box('Z')));
    println!("{:?}", bits(black_box(0xdead_beef_0000_1234)));
    println!("{:?}", neg(black_box(-32768 + 1), black_box(true)));
    println!("{:?} {:?} {:?}", cmp(black_box(-1), black_box(1)), cmp(1, 1), cmp(black_box(5), 2));
    // Division by zero panics at every opt-level (overflow checks are off at -O).
    let r = std::panic::catch_unwind(|| ops32(black_box(1), black_box(0)));
    println!("division by zero caught: {}", r.is_err());
}
