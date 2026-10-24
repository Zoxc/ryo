//! Atomics, single-threaded: integers and `AtomicPtr`, whose results are dereferenced, so
//! their provenance matters.
include!("common/print.rs");
use std::hint::black_box;
use std::sync::atomic::{AtomicI16, AtomicPtr, AtomicU64, AtomicU8, Ordering::*};

fn ints() {
    let a = AtomicU64::new(black_box(5));
    out::us(&[a.fetch_add(3, Relaxed) as u128, a.fetch_sub(1, AcqRel) as u128, a.load(Acquire) as u128]);
    out::us(&[a.swap(100, SeqCst) as u128, a.fetch_and(0b1100, SeqCst) as u128, a.fetch_or(3, Release) as u128]);
    out::us(&[a.fetch_xor(0xff, Acquire) as u128, a.fetch_nand(0xf0, SeqCst) as u128, a.load(Relaxed) as u128]);
    out::b(a.compare_exchange(1, 2, Relaxed, Relaxed).is_ok());
    out::nl();
    let b = AtomicU8::new(250);
    out::us(&[b.fetch_add(10, SeqCst) as u128, b.fetch_max(200, SeqCst) as u128, b.load(SeqCst) as u128]);
    let c = AtomicI16::new(-5);
    out::i(c.fetch_min(-100, Relaxed) as i128);
    out::sp();
    out::i(c.load(Relaxed) as i128);
    out::nl();
}

fn ptrs() {
    let mut xs = [10u64, 11, 12, 13, 14, 15, 16, 17];
    let base = xs.as_mut_ptr();
    let p = AtomicPtr::new(base);
    unsafe {
        out::u(*p.load(Acquire) as u128);
        out::nl();
        p.store(base.add(3), Release);
        out::u(*p.load(Relaxed) as u128);
        out::nl();
        let old = p.swap(base.add(5), AcqRel);
        out::us(&[*old as u128, *p.load(SeqCst) as u128]);
        let r = p.compare_exchange(base.add(5), base.add(1), SeqCst, Acquire);
        out::us(&[*r.unwrap() as u128, *p.load(SeqCst) as u128]);
        let r = p.compare_exchange(base, base.add(2), Relaxed, Relaxed);
        out::us(&[*r.unwrap_err() as u128, *p.load(SeqCst) as u128]);
        let mut cur = p.load(Relaxed);
        while let Err(v) = p.compare_exchange_weak(cur, cur.add(1), Release, Relaxed) {
            cur = v;
        }
        out::u(*p.load(Acquire) as u128);
        out::nl();
        out::us(&[*p.fetch_ptr_add(3, AcqRel) as u128, *p.load(Relaxed) as u128]);
        out::us(&[*p.fetch_ptr_sub(2, SeqCst) as u128, *p.load(Relaxed) as u128]);
        out::us(&[*p.fetch_byte_add(8, Relaxed) as u128, *p.load(Relaxed) as u128]);
        out::us(&[*p.fetch_byte_sub(16, Release) as u128, *p.load(Relaxed) as u128]);
        // A tag in the low bit, set and cleared: the pointer stays usable.
        let untagged = p.fetch_or(1, SeqCst);
        out::us(&[*untagged as u128, (p.load(Relaxed).addr() & 1) as u128]);
        out::us(&[(p.fetch_and(!1, AcqRel).addr() & 1) as u128, *p.load(Acquire) as u128]);
        out::u((p.fetch_xor(1, Relaxed).addr() & 1) as u128);
        out::nl();
        out::us(&[(p.fetch_xor(1, Acquire).addr() & 1) as u128, *p.load(SeqCst) as u128]);
        *p.load(Relaxed) += 100;
    }
    let v: Vec<u128> = xs.iter().map(|&x| x as u128).collect();
    out::us(&v);
    let n: AtomicPtr<u8> = AtomicPtr::new(std::ptr::null_mut());
    out::b(n.load(SeqCst).is_null());
    out::sp();
    out::b(n.fetch_byte_add(4, SeqCst).is_null());
    out::nl();
}

fn main() {
    ints();
    ptrs();
}
