//! Pointers at unaligned offsets of packed constant and static allocations: the image writer
//! relocates them wherever they sit (they used to abort it with `AllocReloc`).
use std::ptr::{addr_of, read_unaligned};

#[repr(C, packed)]
struct P {
    a: u8,
    p: &'static u8,
}

#[repr(C, packed)]
struct Q {
    a: [u8; 3],
    f: fn(u32) -> u32,
    s: &'static str,
}

static X: u8 = 5;
const C: &P = &P { a: 1, p: &X };

fn double(x: u32) -> u32 {
    x * 2
}

static S: Q = Q { a: [1, 2, 3], f: double, s: "packed" };
// An align-1 allocation after an odd-sized one, so even offset 0 can be odd in the pool.
const ODD: &[u8; 3] = &[7, 8, 9];
const D: &P = &P { a: 2, p: &ODD[1] };

fn main() {
    let p = unsafe { read_unaligned(addr_of!(C.p)) };
    println!("{} {}", unsafe { read_unaligned(addr_of!(C.a)) }, p);
    let f = unsafe { read_unaligned(addr_of!(S.f)) };
    let s = unsafe { read_unaligned(addr_of!(S.s)) };
    println!("{:?} {} {}", unsafe { read_unaligned(addr_of!(S.a)) }, f(21), s);
    println!("{} {:?}", unsafe { read_unaligned(addr_of!(D.p)) }, ODD);
}
