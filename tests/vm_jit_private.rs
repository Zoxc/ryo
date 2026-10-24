// The JIT's std is its own (design/jit.md#packaging): run by `y test`'s `jit-private-std` check with
// every function compiled at its first call (`RYO_JIT_THRESHOLD=0 RYO_JIT_SYNC=1`).
//
// The global allocator below is VM code, and calls a VM function while it holds its lock,
// which trips and waits for the JIT. If the JIT allocated through it, that would deadlock.
// Built with `-Cpanic=abort` and run with `RYO_JIT_TEST_PANIC=1`, every compile panics, which
// the JIT must catch (failing the function) instead of aborting.

use std::alloc::{GlobalAlloc, Layout, System};
use std::sync::atomic::AtomicBool;
use std::sync::atomic::Ordering::{Acquire, Relaxed, Release};

struct Locked;

static LOCK: AtomicBool = AtomicBool::new(false);

#[inline(never)]
fn under_lock(n: usize) -> usize {
    n.wrapping_mul(3) ^ 1
}

fn lock() {
    while LOCK.compare_exchange_weak(false, true, Acquire, Relaxed).is_err() {
        std::hint::spin_loop();
    }
}

unsafe impl GlobalAlloc for Locked {
    unsafe fn alloc(&self, l: Layout) -> *mut u8 {
        lock();
        std::hint::black_box(under_lock(std::hint::black_box(l.size())));
        let p = unsafe { System.alloc(l) };
        LOCK.store(false, Release);
        p
    }

    unsafe fn dealloc(&self, p: *mut u8, l: Layout) {
        lock();
        std::hint::black_box(under_lock(std::hint::black_box(l.align())));
        unsafe { System.dealloc(p, l) };
        LOCK.store(false, Release);
    }
}

#[global_allocator]
static A: Locked = Locked;

fn main() {
    let v: Vec<u64> = (0..1000).collect();
    let words: Vec<String> = v.iter().filter(|n| *n % 97 == 0).map(|n| format!("w{n}")).collect();
    let t = std::thread::spawn(move || words.join(","));
    println!("sum {} words {}", v.iter().sum::<u64>(), t.join().unwrap());
}
