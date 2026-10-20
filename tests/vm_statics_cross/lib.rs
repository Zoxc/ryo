//! Statics, thread locals and functions that `main` reaches from its constants and VM code.
#![feature(thread_local)]

use std::cell::Cell;
use std::fmt;

pub static S: u32 = 41;
pub static mut M: u32 = 0;
pub static NAMES: &[&str] = &["one", "two"];

#[thread_local]
pub static TL: Cell<u32> = Cell::new(100);

thread_local! {
    pub static TLK: Cell<u32> = const { Cell::new(7) };
}

pub fn f() -> i32 {
    5
}

pub fn g() -> i32 {
    6
}

pub struct T(pub u8);

impl fmt::Display for T {
    fn fmt(&self, out: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(out, "T{}", self.0)
    }
}

pub trait Shape {
    fn area(&self) -> u32;
}

impl Shape for T {
    fn area(&self) -> u32 {
        self.0 as u32 * 2
    }
}

pub fn bump_tl() -> u32 {
    TL.set(TL.get() + 1);
    TL.get()
}
