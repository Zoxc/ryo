//! The exit status through `exit`, after output.
include!("common/print.rs");
use std::hint::black_box;

fn main() {
    let v: Vec<u8> = (1..=5).collect();
    out::u(v.iter().map(|&x| x as u128).sum());
    out::nl();
    if black_box(v.len()) == 5 {
        out::quit(42);
    }
    out::str("not reached\n");
}
