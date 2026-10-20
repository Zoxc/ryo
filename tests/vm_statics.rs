//! Constants and statics in VM code: type ids, nested and mutable statics, statics pointing
//! at statics and functions, thread locals (`#[thread_local]` and `thread_local!`), vtables
//! only the image uses, and constants pointing into other constants.
#![feature(thread_local)]

use std::any::{Any, TypeId};
use std::cell::Cell;
use std::sync::atomic::{AtomicUsize, Ordering};

static mut COUNTER: u32 = 0;
static NESTED: &[&str] = &["a", "bc", "def"];
static TABLE: [fn(i32) -> i32; 2] = [double, negate];
static SELF_REF: &&i32 = &&7;
static POINTS_AT: &u32 = &BASE;
static BASE: u32 = 40;
static ATOMIC: AtomicUsize = AtomicUsize::new(5);
const STRS: &[&str] = &["x", "yy"];
const PAIR: (&str, Option<&u8>) = ("pair", Some(&3));

#[thread_local]
static TL: Cell<u64> = Cell::new(1);
#[thread_local]
static mut TL_MUT: [u8; 4] = [1, 2, 3, 4];

thread_local! {
    static TLK: Cell<i32> = const { Cell::new(10) };
    static TLV: std::cell::RefCell<Vec<i32>> = std::cell::RefCell::new(Vec::new());
}

fn double(x: i32) -> i32 {
    x * 2
}

fn negate(x: i32) -> i32 {
    -x
}

fn bump() -> u32 {
    unsafe {
        COUNTER += 1;
        COUNTER
    }
}

fn nested() -> usize {
    NESTED.iter().map(|s| s.len()).sum::<usize>() + STRS.len() + PAIR.0.len() + *PAIR.1.unwrap() as usize
}

fn table(x: i32) -> i32 {
    TABLE[0](x) + TABLE[1](x) + **SELF_REF + *POINTS_AT as i32
}

fn atomics() -> usize {
    ATOMIC.fetch_add(1, Ordering::Relaxed) + ATOMIC.load(Ordering::Relaxed)
}

fn type_ids() -> (bool, bool, bool) {
    const T: TypeId = TypeId::of::<u32>();
    let a = TypeId::of::<u32>();
    let b: &dyn Any = &5u32;
    (a == T, b.type_id() == T, TypeId::of::<i8>() == T)
}

fn downcast(v: &dyn Any) -> i32 {
    if let Some(x) = v.downcast_ref::<i32>() {
        *x
    } else if let Some(s) = v.downcast_ref::<&str>() {
        s.len() as i32
    } else {
        -1
    }
}

fn tls() -> u64 {
    TL.set(TL.get() * 3);
    let m = unsafe { TL_MUT[2] as u64 };
    unsafe { TL_MUT[2] += 1 };
    TL.get() + m
}

fn tls_key() -> i32 {
    TLK.with(|c| c.set(c.get() + 1));
    TLV.with(|v| v.borrow_mut().push(TLK.get()));
    TLV.with(|v| v.borrow().iter().sum())
}

fn main() {
    println!("{} {}", bump(), bump());
    println!("{}", nested());
    println!("{}", table(3));
    println!("{}", atomics());
    println!("{:?}", type_ids());
    println!("{} {} {}", downcast(&4i32), downcast(&"abc"), downcast(&1u8));
    println!("{} {}", tls(), tls());
    println!("{} {}", tls_key(), tls_key());
    let h = std::thread::spawn(|| (tls(), tls_key()));
    println!("{:?}", h.join().unwrap());
}
