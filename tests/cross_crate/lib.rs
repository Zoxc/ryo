//! An rlib (crate `ccl`) used by `main.rs`: generics instantiated downstream, `#[inline]` fns,
//! statics, trait objects across the crate boundary.
use std::fmt::Debug;

pub static GREETING: &str = "hello from the rlib";

pub trait Describe {
    fn describe(&self) -> String;
}

#[derive(Debug, Clone)]
pub struct Stack<T> {
    items: Vec<T>,
}

impl<T: Debug + Clone> Stack<T> {
    pub fn new() -> Self {
        Stack { items: Vec::new() }
    }
    pub fn push(&mut self, t: T) -> &mut Self {
        self.items.push(t);
        self
    }
    pub fn pop(&mut self) -> Option<T> {
        self.items.pop()
    }
    pub fn len(&self) -> usize {
        self.items.len()
    }
}

impl<T: Debug> Describe for Stack<T> {
    fn describe(&self) -> String {
        format!("stack of {} {:?}", self.items.len(), self.items)
    }
}

pub fn sum_all<T: Copy + std::iter::Sum<T>>(xs: &[T]) -> T {
    xs.iter().copied().sum()
}

#[inline]
pub fn inline_square(x: i64) -> i64 {
    x * x
}

pub fn non_generic(n: u32) -> String {
    (0..n).map(|i| char::from(b'a' + (i % 26) as u8)).collect()
}

pub fn boxed_describer(n: i32) -> Box<dyn Describe> {
    let mut s = Stack::new();
    for i in 0..n {
        s.push(i);
    }
    Box::new(s)
}
