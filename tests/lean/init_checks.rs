//! `assert_inhabited`, `assert_zero_valid` and `assert_mem_uninitialized_valid` (through
//! `MaybeUninit::assume_init`, `mem::zeroed` and `mem::uninitialized`) at types whose checks
//! pass: none of them panics (`panic_nounwind` aborts natively; the runs can't compare that).
#![allow(deprecated, invalid_value)]
include!("common/print.rs");
use std::cmp::Ordering;
use std::hint::black_box;
use std::mem::{self, MaybeUninit};
use std::num::NonZeroU32;

#[derive(Clone, Copy)]
struct Pair {
    a: u32,
    b: u16,
}

#[derive(Clone, Copy)]
enum Small {
    A,
    B(u8),
}

fn tag(s: Small) -> u128 {
    match s {
        Small::A => 0,
        Small::B(x) => 100 + x as u128,
    }
}

fn main() {
    // assert_inhabited
    let x = unsafe { MaybeUninit::new(black_box(5u32)).assume_init() };
    let nz = unsafe { MaybeUninit::new(NonZeroU32::new(black_box(9)).unwrap()).assume_init() };
    let r = unsafe { MaybeUninit::new(&x).assume_init() };
    out::us(&[x as u128, nz.get() as u128, *r as u128]);
    out::nl();

    // assert_zero_valid
    let z: u32 = unsafe { mem::zeroed() };
    let p: Pair = unsafe { mem::zeroed() };
    let arr: [u8; 4] = unsafe { mem::zeroed() };
    let ptr: *const u8 = unsafe { mem::zeroed() };
    let b: bool = unsafe { mem::zeroed() };
    let c: char = unsafe { mem::zeroed() };
    let o: Option<&u8> = unsafe { mem::zeroed() };
    let ob: Option<Box<u64>> = unsafe { mem::zeroed() };
    let ord: Ordering = unsafe { mem::zeroed() };
    let s: Small = unsafe { mem::zeroed() };
    let f: Option<fn()> = unsafe { mem::zeroed() };
    out::us(&[z as u128, p.a as u128, p.b as u128, arr.iter().map(|&v| v as u128).sum(), ptr as usize as u128]);
    out::b(b);
    out::sp();
    out::us(&[c as u128, o.is_none() as u128, ob.is_none() as u128, (ord == Ordering::Equal) as u128, tag(s), f.is_none() as u128]);
    out::nl();

    // assert_mem_uninitialized_valid: `mem::uninitialized` fills with 0x01
    let u: u8 = unsafe { mem::uninitialized() };
    let ub: bool = unsafe { mem::uninitialized() };
    let ua: [bool; 3] = unsafe { mem::uninitialized() };
    let up: (u8, bool, u16) = unsafe { mem::uninitialized() };
    let uo: Option<bool> = unsafe { mem::uninitialized() };
    let uord: Ordering = unsafe { mem::uninitialized() };
    let unz: NonZeroU32 = unsafe { mem::uninitialized() };
    let uptr: *const u32 = unsafe { mem::uninitialized() };
    out::us(&[u as u128, ub as u128, ua.iter().filter(|&&v| v).count() as u128, up.0 as u128, up.1 as u128, up.2 as u128]);
    out::us(&[uo.unwrap() as u128, (uord == Ordering::Greater) as u128, unz.get() as u128, uptr as usize as u128]);
    out::nl();
}
