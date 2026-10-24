//! Milestone 5: intrinsics as VM instructions (atomics, fences, volatile accesses, funnel
//! shifts, float ops, `size_of_val` of structs with unsized tails) and as wrapper islands
//! (`catch_unwind`, `compare_bytes`, SIMD).
#![feature(core_intrinsics, funnel_shifts, portable_simd, ptr_metadata)]
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

/// `AtomicPtr`: the `.ptr` atomics. Each result is dereferenced, so its provenance matters.
#[inline(never)]
fn atomic_ptrs() {
    let mut xs = [10u64, 11, 12, 13, 14, 15, 16, 17];
    let base = xs.as_mut_ptr();
    let p = AtomicPtr::new(base);
    unsafe {
        println!("load {}", *p.load(Acquire));
        p.store(base.add(3), Release);
        println!("store {}", *p.load(Relaxed));
        let old = p.swap(base.add(5), AcqRel);
        println!("swap {} {}", *old, *p.load(SeqCst));
        let r = p.compare_exchange(base.add(5), base.add(1), SeqCst, Acquire);
        println!("cxchg {:?} {}", r.map(|q| *q), *p.load(SeqCst));
        let r = p.compare_exchange(base, base.add(2), Relaxed, Relaxed);
        println!("cxchg {:?} {}", r.map_err(|q| *q), *p.load(SeqCst));
        let mut cur = p.load(Relaxed);
        while let Err(v) = p.compare_exchange_weak(cur, cur.add(1), Release, Relaxed) {
            cur = v;
        }
        println!("weak {}", *p.load(Acquire));
        println!("ptr_add {} {}", *p.fetch_ptr_add(3, AcqRel), *p.load(Relaxed));
        println!("ptr_sub {} {}", *p.fetch_ptr_sub(2, SeqCst), *p.load(Relaxed));
        println!("byte_add {} {}", *p.fetch_byte_add(8, Relaxed), *p.load(Relaxed));
        println!("byte_sub {} {}", *p.fetch_byte_sub(16, Release), *p.load(Relaxed));
        // A tag in the low bit, set and cleared: the pointer stays usable.
        let untagged = p.fetch_or(1, SeqCst);
        let tagged = p.load(Relaxed);
        println!("or {} {}", *untagged, tagged.addr() & 1);
        println!("and {} {}", p.fetch_and(!1, AcqRel).addr() & 1, *p.load(Acquire));
        println!("xor {}", p.fetch_xor(1, Relaxed).addr() & 1);
        println!("xor {} {}", p.fetch_xor(1, Acquire).addr() & 1, *p.load(SeqCst));
        *p.load(Relaxed) += 100;
    }
    println!("xs {xs:?}");
    // Strings behind the pointers: their heap allocations are reached through them.
    let mut a = String::from("first");
    let mut b = String::from("second");
    let s = AtomicPtr::new(&mut a);
    let prev = s.swap(&mut b, SeqCst);
    unsafe {
        (*prev).push('!');
        (*s.load(SeqCst)).push('?');
        println!("{} {}", *prev, *s.load(Relaxed));
    }
    let n: AtomicPtr<u8> = AtomicPtr::new(std::ptr::null_mut());
    println!("null {} {}", n.load(SeqCst).is_null(), n.fetch_byte_add(4, SeqCst).is_null());
    // A Treiber stack pushed to by four threads, then popped.
    struct Node {
        v: usize,
        next: *mut Node,
    }
    struct Stack(AtomicPtr<Node>);
    unsafe impl Sync for Stack {}
    let st = Arc::new(Stack(AtomicPtr::new(std::ptr::null_mut())));
    // Slots claimed by `fetch_ptr_add` and written through the claimed pointers.
    let slots: Arc<Vec<AtomicUsize>> = Arc::new((0..4 * 500).map(|_| AtomicUsize::new(0)).collect());
    let next = Arc::new(AtomicPtr::new(slots.as_ptr() as *mut AtomicUsize));
    let hs: Vec<_> = (0..4)
        .map(|t| {
            let (st, next, slots) = (st.clone(), next.clone(), slots.clone());
            std::thread::spawn(move || {
                let _keep = slots;
                for i in 0..500 {
                    let node = Box::into_raw(Box::new(Node { v: t * 1000 + i, next: std::ptr::null_mut() }));
                    let mut head = st.0.load(Relaxed);
                    loop {
                        unsafe { (*node).next = head };
                        match st.0.compare_exchange_weak(head, node, Release, Relaxed) {
                            Ok(_) => break,
                            Err(h) => head = h,
                        }
                    }
                    let slot = next.fetch_ptr_add(1, AcqRel);
                    unsafe { (*slot).store(t * 1000 + i + 1, Relaxed) };
                }
            })
        })
        .collect();
    for h in hs {
        h.join().unwrap();
    }
    let (mut count, mut sum) = (0, 0);
    let mut cur = st.0.swap(std::ptr::null_mut(), Acquire);
    while !cur.is_null() {
        let node = unsafe { Box::from_raw(cur) };
        count += 1;
        sum += node.v;
        cur = node.next;
    }
    let filled = slots.iter().filter(|s| s.load(Relaxed) != 0).count();
    let total: usize = slots.iter().map(|s| s.load(Relaxed)).sum();
    println!("stack {count} {sum} slots {filled} {total}");
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

#[inline(never)]
fn direct() {
    unsafe {
        println!("{} {}", intrinsics::exact_div(black_box(-42i32), 7), intrinsics::exact_div(black_box(84u64), 4));
        println!("{:x}", intrinsics::disjoint_bitor(black_box(0xf0u8), 0x0f));
        let (a, b) = (1u32, 2u32);
        println!(
            "{} {}",
            intrinsics::ptr_guaranteed_cmp(black_box(&a as *const u32), &a as *const u32),
            intrinsics::ptr_guaranteed_cmp(black_box(&a as *const u32), &b as *const u32)
        );
        let d: &dyn T1 = &[1u16, 2, 3];
        let vt = std::ptr::metadata(d as *const dyn T1);
        println!("{} {}", vt.size_of(), vt.align_of());
        let raw: *const () = std::mem::transmute(vt);
        println!("{} {}", intrinsics::vtable_size(raw), intrinsics::vtable_align(raw));
        let mut x = 0u64;
        intrinsics::nontemporal_store(&mut x, black_box(77));
        println!("{x}");
        let mut buf = [0u16; 6];
        intrinsics::volatile_set_memory(buf.as_mut_ptr(), 0x11, 3);
        intrinsics::volatile_copy_nonoverlapping_memory(buf.as_mut_ptr().add(3), buf.as_ptr(), 2);
        intrinsics::volatile_copy_memory(buf.as_mut_ptr().add(1), buf.as_ptr(), 4);
        println!("{buf:x?}");
        println!("{} {}", intrinsics::raw_eq(&[1u8, 2, 3], &[1, 2, 3]), intrinsics::raw_eq(&(1u32, 5u32), &(1, black_box(6))));
        let (p, q) = (b"abcd", b"abce");
        println!(
            "{} {} {}",
            intrinsics::compare_bytes(p.as_ptr(), q.as_ptr(), 4).signum(),
            intrinsics::compare_bytes(q.as_ptr(), p.as_ptr(), 4).signum(),
            intrinsics::compare_bytes(p.as_ptr(), q.as_ptr(), black_box(3))
        );
    }
    let h = AtomicU16::new(10);
    println!(
        "{} {} {} {} {} {}",
        h.fetch_sub(20, SeqCst),
        h.fetch_and(0xff0f, Relaxed),
        h.fetch_or(0x3, Acquire),
        h.fetch_xor(0xffff, Release),
        h.fetch_max(5, AcqRel),
        h.fetch_min(4, SeqCst)
    );
    println!("{}", h.load(SeqCst));
}

/// Read-modify-write atomics racing from several threads: no update is lost.
#[inline(never)]
fn contention() {
    let n = Arc::new(AtomicUsize::new(0));
    let m = Arc::new(AtomicU32::new(0));
    let hs: Vec<_> = (0..4)
        .map(|t| {
            let (n, m) = (n.clone(), m.clone());
            std::thread::spawn(move || {
                for i in 0..10_000u32 {
                    n.fetch_add(1, Relaxed);
                    let mut cur = m.load(Relaxed);
                    while let Err(v) = m.compare_exchange_weak(cur, cur + (i & 1) + t, AcqRel, Relaxed) {
                        cur = v;
                    }
                }
            })
        })
        .collect();
    for h in hs {
        h.join().unwrap();
    }
    println!("{} {}", n.load(SeqCst), m.load(SeqCst));
}

fn main() {
    atomics();
    atomic_ptrs();
    unwinding();
    misc();
    dst();
    direct();
    contention();
}
