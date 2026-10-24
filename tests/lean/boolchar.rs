//! bool and char.
include!("common/print.rs");
use std::hint::black_box;

fn main() {
    let t = black_box(true);
    let f = black_box(false);
    out::b(t & f);
    out::sp();
    out::b(t | f);
    out::sp();
    out::b(t ^ t);
    out::sp();
    out::b(!f);
    out::sp();
    out::b(t > f);
    out::sp();
    out::u(t.cmp(&f) as i8 as u128);
    out::nl();
    let c = black_box('ß');
    out::u(c as u128);
    out::sp();
    out::u(c.len_utf8() as u128);
    out::sp();
    let mut buf = [0u8; 4];
    let s = black_box('€').encode_utf8(&mut buf);
    out::str(s);
    out::sp();
    out::u(s.len() as u128);
    out::sp();
    match char::from_u32(black_box(0xd800)) {
        Some(_) => out::str("some"),
        None => out::str("none"),
    }
    out::sp();
    match char::from_u32(black_box(0x41)) {
        Some(c) => out::u(c as u128),
        None => out::str("none"),
    }
    out::sp();
    out::u(black_box('7').to_digit(10).unwrap_or(99) as u128);
    out::sp();
    out::u(black_box('z').to_digit(36).unwrap_or(99) as u128);
    out::sp();
    out::b(black_box('a').is_ascii_lowercase());
    out::sp();
    out::u(black_box('q').to_ascii_uppercase() as u128);
    out::nl();
    let word = "héllo wörld";
    let mut n = 0;
    let mut sum = 0u32;
    for ch in word.chars() {
        n += 1;
        sum += ch as u32;
    }
    out::us(&[n, sum as u128, word.len() as u128]);
    let mut up = [0u8; 16];
    for (i, b) in b"mixed Case 42".iter().enumerate() {
        up[i] = b.to_ascii_uppercase();
    }
    out::bytes(&up[..13]);
    out::nl();
}
