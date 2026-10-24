//! Statics (immutable, `static mut`, interior mutability through atomics and `Cell` in a
//! thread local), consts, const fns, promoted constants, string literals.
include!("common/print.rs");
use std::cell::Cell;
use std::hint::black_box;
use std::sync::atomic::{AtomicU32, AtomicUsize, Ordering};

static TABLE: [u16; 5] = [10, 20, 30, 40, 50];
static GREETING: &str = "static str";
static mut COUNTER: u64 = 0;
static HITS: AtomicUsize = AtomicUsize::new(0);
static FLAGS: AtomicU32 = AtomicU32::new(0b1010);
static NESTED: &[&[u8]] = &[b"ab", b"cde", b""];
static PTRS: [&u16; 2] = [&TABLE[1], &TABLE[4]];

const SQUARES: [u32; 6] = squares();

const fn squares() -> [u32; 6] {
    let mut a = [0; 6];
    let mut i = 0;
    while i < 6 {
        a[i] = (i * i) as u32;
        i += 1;
    }
    a
}

thread_local! {
    static TL: Cell<u32> = const { Cell::new(5) };
}

fn bump() -> u64 {
    HITS.fetch_add(1, Ordering::Relaxed);
    unsafe {
        COUNTER += 3;
        COUNTER
    }
}

fn main() {
    out::u(TABLE[black_box(3)] as u128);
    out::sp();
    out::str(GREETING);
    out::sp();
    bump();
    bump();
    out::u(bump() as u128);
    out::sp();
    out::u(HITS.load(Ordering::SeqCst) as u128);
    out::sp();
    FLAGS.fetch_or(1, Ordering::SeqCst);
    let prev = FLAGS.swap(7, Ordering::AcqRel);
    let cas = FLAGS.compare_exchange(7, 8, Ordering::SeqCst, Ordering::Relaxed);
    out::u(prev as u128);
    out::sp();
    out::b(cas.is_ok());
    out::sp();
    out::u(FLAGS.load(Ordering::Relaxed) as u128);
    out::nl();
    for s in NESTED {
        out::u(s.len() as u128);
        out::sp();
    }
    out::u(*PTRS[black_box(1)] as u128);
    out::sp();
    out::u(SQUARES[black_box(5)] as u128);
    out::sp();
    let promoted: &'static [i32; 3] = &[-1, -2, -3];
    out::i(promoted[black_box(2)] as i128);
    out::sp();
    TL.with(|c| c.set(c.get() * 7));
    out::u(TL.with(|c| c.get()) as u128);
    out::nl();
}
