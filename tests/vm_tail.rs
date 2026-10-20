//! Milestone 5: `become` as `tail_call` (VM functions of this image) and `tail_call.ind` (fn
//! pointers, virtual calls, upstream and native callees). The deep recursions only fit the VM
//! stack as real tail calls.
#![feature(explicit_tail_calls)]
#![allow(incomplete_features)]
use std::hint::black_box;

#[inline(never)]
fn count(n: u64, acc: u64) -> u64 {
    if n == 0 {
        return acc;
    }
    become count(n - 1, acc.wrapping_add(n))
}

#[inline(never)]
fn even(n: u32) -> bool {
    if n == 0 { true } else { become odd(n - 1) }
}
#[inline(never)]
fn odd(n: u32) -> bool {
    if n == 0 { false } else { become even(n - 1) }
}

#[derive(Debug, Clone, Copy)]
struct Big {
    a: [u64; 6],
    b: u8,
}

#[inline(never)]
fn big(x: Big, n: u32) -> Big {
    if n == 0 {
        return x;
    }
    let mut y = x;
    y.a[(n % 6) as usize] += n as u64;
    y.b = y.b.wrapping_add(1);
    become big2(y, n - 1)
}
#[inline(never)]
fn big2(x: Big, n: u32) -> Big {
    if n % 3 == 0 {
        let f: fn(Big, u32) -> Big = black_box(big);
        become f(x, n)
    }
    become big(x, n)
}

#[inline(never)]
fn via_ptr(n: u64, acc: u64) -> u64 {
    let f: fn(u64, u64) -> u64 = black_box(count);
    become f(n, acc)
}

#[inline(never)]
fn to_upstream(s: &str) -> usize {
    become str::len(s)
}

#[inline(never)]
fn to_native(x: f64) -> f64 {
    become f64::sqrt(x)
}

trait Step {
    fn step(&self, n: u32) -> u32;
}
struct S;
impl Step for S {
    fn step(&self, n: u32) -> u32 {
        n + 1
    }
}
#[inline(never)]
fn virt(s: &dyn Step, n: u32) -> u32 {
    become s.step(n)
}

#[inline(never)]
fn panicky(n: u32) -> u32 {
    if n == 0 {
        panic!("bottom");
    }
    become panicky(n - 1)
}

fn main() {
    println!("{}", count(black_box(1_000_000), 0));
    println!("{} {}", even(black_box(100_001)), odd(black_box(77)));
    println!("{:?}", big(Big { a: [1; 6], b: 250 }, black_box(1000)));
    println!("{}", via_ptr(black_box(10), 0));
    println!("{}", to_upstream(black_box("hello")));
    println!("{}", to_native(black_box(2.0)));
    println!("{}", virt(&S, black_box(41)));
    println!("{:?}", std::panic::catch_unwind(|| panicky(black_box(100))).is_err());
}
