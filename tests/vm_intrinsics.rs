//! Milestone 5: intrinsics as VM instructions (atomics, fences, volatile accesses, funnel
//! shifts, float ops, `size_of_val` of structs with unsized tails) and as wrapper islands
//! (`catch_unwind`, `compare_bytes`, SIMD).
#![feature(core_intrinsics, funnel_shifts, portable_simd)]
#![allow(internal_features)]
use std::hint::black_box;
use std::intrinsics;
use std::panic;
use std::simd::prelude::*;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, AtomicI8, AtomicI64, AtomicPtr, AtomicU16, AtomicU32, AtomicUsize, Ordering::*, fence, compiler_fence};

#[inline(never)]
fn atomics() {
    let a = AtomicUsize::new(5);
    println!("{} {} {}", a.fetch_add(3, Relaxed), a.fetch_sub(1, AcqRel), a.load(Acquire));
    println!("{} {}", a.swap(100, SeqCst), a.load(SeqCst));
    println!("{:?} {:?}", a.compare_exchange(100, 7, AcqRel, Acquire), a.compare_exchange(1, 2, Relaxed, Relaxed));
    let mut n = 0;
    while a.compare_exchange_weak(7, 8, Release, Relaxed).is_err() {
        n += 1;
    }
    println!("weak {} {}", a.load(Relaxed), n < 1000);
    println!("{} {} {}", a.fetch_and(0b1100, SeqCst), a.fetch_or(0b11, Release), a.fetch_xor(0xff, Acquire));
    println!("{} {}", a.fetch_nand(0xf0, SeqCst), a.load(Relaxed));
    println!("{} {} {}", a.fetch_max(1000, SeqCst), a.fetch_min(3, SeqCst), a.load(SeqCst));
    let i = AtomicI8::new(-5);
    println!("{} {} {}", i.fetch_max(-10, SeqCst), i.fetch_min(-100, Relaxed), i.load(Relaxed));
    println!("{}", i.fetch_add(-100, Relaxed));
    let u = AtomicU16::new(65535);
    println!("{} {}", u.fetch_add(2, SeqCst), u.load(SeqCst));
    let w = AtomicU32::new(1);
    w.store(0xdead_beef, Release);
    println!("{:x} {:?}", w.load(Acquire), w.fetch_update(SeqCst, SeqCst, |x| Some(x / 2)));
    let b = AtomicBool::new(false);
    println!("{} {} {}", b.fetch_or(true, SeqCst), b.fetch_and(false, SeqCst), b.swap(true, SeqCst));
    let l = AtomicI64::new(i64::MIN);
    println!("{} {}", l.fetch_sub(1, SeqCst), l.load(SeqCst));
    let mut x = 5u32;
    let mut y = 6u32;
    let p = AtomicPtr::new(&mut x);
    let old = p.swap(&mut y, SeqCst);
    unsafe { println!("ptr {} {}", *old, *p.load(SeqCst)) };
    fence(SeqCst);
    fence(Acquire);
    compiler_fence(Release);
    let arc = Arc::new(String::from("shared"));
    let arcs: Vec<_> = (0..5).map(|_| arc.clone()).collect();
    println!("arc {} {}", Arc::strong_count(&arc), arcs.len());
    drop(arcs);
    println!("arc {}", Arc::strong_count(&arc));
    let threads: Vec<_> = (0..4)
        .map(|t| {
            let c = arc.clone();
            std::thread::spawn(move || c.len() + t)
        })
        .collect();
    let s: usize = threads.into_iter().map(|t| t.join().unwrap()).sum();
    println!("threads {s} {}", Arc::strong_count(&arc));
}

#[inline(never)]
fn unwinding() {
    let r = panic::catch_unwind(|| 42);
    println!("{r:?}");
    let r = panic::catch_unwind(|| {
        if black_box(true) {
            panic!("boom {}", 7);
        }
        1
    });
    println!("{:?}", r.map_err(|e| e.downcast_ref::<String>().cloned()));
    let r = panic::catch_unwind(|| {
        let v: Vec<u8> = Vec::new();
        v[black_box(3)]
    });
    println!("{}", r.is_err());
    let nested = panic::catch_unwind(|| {
        let inner = panic::catch_unwind(|| panic::panic_any(5u8));
        println!("inner {:?}", inner.map_err(|e| *e.downcast::<u8>().unwrap()));
        panic!("outer");
    });
    println!("nested {}", nested.is_err());
    let r = panic::catch_unwind(|| {
        struct D(u32);
        impl Drop for D {
            fn drop(&mut self) {
                println!("drop D{}", self.0);
            }
        }
        let _a = D(1);
        let _b = D(2);
        panic::resume_unwind(Box::new("resumed"));
    });
    println!("{:?}", r.map_err(|e| e.downcast_ref::<&str>().copied()));
}

#[inline(never)]
fn misc() {
    unsafe {
        println!("{:x} {:x}", intrinsics::unchecked_funnel_shl(0x12u8, 0x34u8, black_box(3)), intrinsics::unchecked_funnel_shr(0x12u8, 0x34u8, black_box(3)));
        println!("{:x} {:x}", intrinsics::unchecked_funnel_shl(0x1234_5678u32, 0x9abc_def0, black_box(0)), intrinsics::unchecked_funnel_shr(0x1234_5678u32, 0x9abc_def0, black_box(0)));
        println!("{:x} {:x}", intrinsics::unchecked_funnel_shl(0x1234u64, u64::MAX, black_box(63)), intrinsics::unchecked_funnel_shr(1u64, 2, black_box(1)));
        println!("{:x}", intrinsics::unchecked_funnel_shl(1u128 << 100, 1u128 << 127, black_box(27)));
        println!("{:x}", intrinsics::unchecked_funnel_shr(1u16, 0x8000u16, black_box(15)));
    }
    println!("{}", 0x1234_5678_9abc_def0u64.rotate_left(black_box(12)));
    println!("{:?}", "hello".cmp("help"));
    println!("{}", "abc" == black_box("abc"));
    println!("{}", [1u8, 2, 3] < [1, 2, 4]);
    let mut v = 7u64;
    unsafe {
        std::ptr::write_volatile(&mut v, 9);
        println!("{}", std::ptr::read_volatile(&v));
    }
    println!("{}", intrinsics::black_box(5) + black_box(6));
    println!("{} {} {}", (-3.5f64).abs(), 2.0f32.copysign(-1.0), 1.5f64.min(f64::NAN));
    println!("{} {}", 4.0f64.max(-2.0), (-0.0f32).max(0.0));
    let s = b"abcdef";
    println!("{:?} {:?}", s.iter().position(|&c| c == b'd'), std::str::from_utf8(s).unwrap().find("de"));
    println!("{}", u32::from_be_bytes(black_box([1, 2, 3, 4])));
    println!("{}", 255u8.saturating_add(black_box(3)));
    println!("{:?}", 10u32.checked_next_power_of_two());
    let a = u32x4::from_array([1, 2, 3, 4]);
    let b = u32x4::splat(black_box(10));
    let c = a + b * a;
    println!("{:?} {:?} {}", c, a.simd_lt(u32x4::splat(3)).to_array(), c.reduce_sum());
    let f = f32x4::from_array([1.5, -2.0, 3.0, 0.25]);
    println!("{:?} {}", (f * f32x4::splat(2.0)).abs(), f.reduce_max());
    let m = a.simd_eq(u32x4::from_array([1, 0, 3, 0]));
    println!("{:?} {:?}", m.select(a, b), m.to_bitmask());
}

trait T1 {
    fn f(&self) -> usize;
}
struct Packed<U: ?Sized> {
    a: u8,
    tail: U,
}
impl T1 for u64 {
    fn f(&self) -> usize {
        *self as usize
    }
}
impl T1 for [u16; 3] {
    fn f(&self) -> usize {
        self.len()
    }
}

#[inline(never)]
fn dst() {
    let p: &Packed<dyn T1> = &Packed { a: 1, tail: 5u64 };
    println!("{} {} {}", std::mem::size_of_val(p), std::mem::align_of_val(p), p.a);
    let q: &Packed<dyn T1> = &Packed { a: 2, tail: [1u16, 2, 3] };
    println!("{} {} {}", std::mem::size_of_val(q), std::mem::align_of_val(q), q.a);
    let r: &Packed<[u32]> = &Packed { a: 3, tail: [1u32, 2, 3, 4, 5] };
    println!("{} {} {}", std::mem::size_of_val(r), std::mem::align_of_val(r), r.tail.len());
    let s: &Packed<Packed<str>> = unsafe { std::mem::transmute(&b"\x01\x02xyz"[..]) };
    println!("{} {}", std::mem::size_of_val(s), std::mem::align_of_val(s));
    let rc: std::rc::Rc<dyn T1> = std::rc::Rc::new([1u16, 2, 3]);
    let weak = std::rc::Rc::downgrade(&rc);
    println!("{} {}", weak.upgrade().map(|x| x.f()).unwrap_or(0), std::rc::Rc::weak_count(&rc));
    drop(rc);
    println!("{}", weak.upgrade().is_none());
}

fn main() {
    atomics();
    unwinding();
    misc();
    dst();
}
