//! An rlib linked into a Rust dylib: its image refers to a foreign function, a static and
//! a thread local, none of which the dylib may export.
#![feature(thread_local)]

use std::cell::Cell;

unsafe extern "C" {
    safe fn abs(x: i32) -> i32;
}

pub static S: u32 = 3;

#[thread_local]
static TL: Cell<i32> = Cell::new(1);

thread_local! {
    static NAME: String = String::from("tls");
}

#[inline(never)]
pub fn f(x: i32) -> i32 {
    TL.set(TL.get() + 1);
    abs(x) + S as i32 + TL.get() + NAME.with(|n| n.len() as i32)
}
