//! A panic through VM frames with `RUST_BACKTRACE=1`: the backtrace walks the machine code
//! of VM functions (their unwind information and symbols) into native frames.
use std::hint::black_box;

struct Guard;
impl Drop for Guard {
    fn drop(&mut self) {
        println!("guard dropped");
    }
}

#[inline(never)]
fn inner(x: u32) -> u32 {
    if black_box(x) > 2 {
        panic!("deep {x}");
    }
    x
}

#[inline(never)]
fn outer(x: u32) -> u32 {
    let _g = Guard;
    inner(x) + 1
}

fn main() {
    let r = std::panic::catch_unwind(|| outer(black_box(7)));
    println!("caught: {}", r.is_err());
}
