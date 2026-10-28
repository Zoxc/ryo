// Pointer-sized and 64-bit atomics, whose `ptr` and `w64` handlers LLVM's MergeFunctions folds
// into one address in an optimized `ryo_rt`: run by `y test`'s `jit-atomics` check with every
// function compiled at its first call (`RYO_JIT_THRESHOLD=0 RYO_JIT_SYNC=1`), which requires
// that none failed to compile. The JIT tells the folded handlers apart by each call's
// instruction list entry (design/vm.md, "Instruction list").

use std::sync::atomic::Ordering::{self, AcqRel, Acquire, Relaxed, Release, SeqCst};
use std::sync::atomic::{AtomicPtr, AtomicU64, AtomicUsize};

const LOADS: [Ordering; 3] = [Relaxed, Acquire, SeqCst];
const STORES: [Ordering; 3] = [Relaxed, Release, SeqCst];
const ALL: [Ordering; 5] = [Relaxed, Acquire, Release, AcqRel, SeqCst];

#[inline(never)]
fn ptrs(a: &AtomicPtr<u64>, p: *mut u64, q: *mut u64) -> u64 {
    let mut n = 0;
    for o in LOADS {
        n += unsafe { *a.load(o) };
    }
    for o in STORES {
        a.store(q, o);
        a.store(p, o);
    }
    for o in ALL {
        n += unsafe { *a.swap(q, o) };
        n += unsafe { *a.swap(p, o) };
    }
    for s in ALL {
        for f in LOADS {
            n += a.compare_exchange(p, q, s, f).is_ok() as u64;
            n += a.compare_exchange(q, p, s, f).is_ok() as u64;
            n += a.compare_exchange(q, p, s, f).is_err() as u64;
            while a.compare_exchange_weak(p, q, s, f).is_err() {}
            while a.compare_exchange_weak(q, p, s, f).is_err() {}
            n += a.compare_exchange_weak(q, p, s, f).is_err() as u64;
        }
    }
    n + unsafe { *a.load(SeqCst) }
}

#[inline(never)]
fn u64s(a: &AtomicU64) -> u64 {
    let mut n = 0;
    for o in LOADS {
        n += a.load(o);
    }
    for o in STORES {
        a.store(n, o);
    }
    for o in ALL {
        n += a.swap(n + 1, o);
    }
    for s in ALL {
        for f in LOADS {
            let v = a.load(Relaxed);
            n += a.compare_exchange(v, v + 2, s, f).unwrap();
            n += a.compare_exchange(v, v, s, f).unwrap_err();
            while a.compare_exchange_weak(v + 2, v + 3, s, f).is_err() {}
            n += a.compare_exchange_weak(v, v, s, f).is_err() as u64;
        }
    }
    n
}

#[inline(never)]
fn usizes(a: &AtomicUsize) -> usize {
    let mut n = 0;
    for o in LOADS {
        n += a.load(o);
    }
    for o in STORES {
        a.store(n + 5, o);
    }
    for o in ALL {
        n += a.swap(n % 7, o);
    }
    for s in ALL {
        for f in LOADS {
            let v = a.load(Relaxed);
            n += a.compare_exchange(v, v * 3 + 1, s, f).unwrap();
            while a.compare_exchange_weak(v * 3 + 1, v, s, f).is_err() {}
        }
    }
    n
}

fn main() {
    let (mut x, mut y) = (11u64, 31u64);
    let a = AtomicPtr::new(&mut x as *mut u64);
    let p = ptrs(&a, &mut x, &mut y);
    let u = u64s(&AtomicU64::new(7));
    let z = usizes(&AtomicUsize::new(3));
    println!("ptrs {p} u64s {u} usizes {z}");
}
