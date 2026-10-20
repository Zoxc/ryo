// Milestone 4 (design/lowering.md): aggregates, unsizing, unsized tails, `Repeat`, casts,
// wide pointers, 128-bit arithmetic islands and frame slot sharing.
#![feature(f16, f128)]

use std::cell::{Ref, RefCell};
use std::hint::black_box as bb;
use std::mem::{align_of_val, size_of_val};
use std::pin::Pin;
use std::rc::Rc;

trait Shape {
    fn area(&self) -> u64;
}
#[repr(align(16))]
struct A16(u64);
struct Sq(u8);
impl Shape for A16 {
    fn area(&self) -> u64 {
        self.0 + 200
    }
}
impl Shape for Sq {
    fn area(&self) -> u64 {
        self.0 as u64 * self.0 as u64
    }
}
impl Shape for u32 {
    fn area(&self) -> u64 {
        *self as u64 * 3
    }
}

struct Tail<X: ?Sized> {
    tag: u8,
    val: X,
}
struct Outer<X: ?Sized> {
    a: u16,
    inner: Tail<X>,
}

/// A `dyn` tail at a dynamically aligned offset, and `size_of_val` of the struct.
#[inline(never)]
fn tail(w: &Tail<dyn Shape>) -> (u8, u64, usize, usize) {
    (w.tag, w.val.area(), size_of_val(w), align_of_val(w))
}

#[inline(never)]
fn nested(w: &Outer<dyn Shape>) -> (u16, u8, u64, usize) {
    (w.a, w.inner.tag, w.inner.val.area(), size_of_val(w))
}

#[inline(never)]
fn rcs(v: &[Rc<dyn Shape>]) -> u64 {
    v.iter().map(|r| r.area() + size_of_val(&**r) as u64).sum()
}

/// Field-by-field unsizing of structs that aren't just a pointer.
#[inline(never)]
fn coerce_ref(r: Ref<'_, [i32; 3]>) -> Ref<'_, [i32]> {
    r
}

#[inline(never)]
fn coerce_pin(b: Pin<Box<Sq>>) -> Pin<Box<dyn Shape>> {
    b
}

#[inline(never)]
fn coerce_tail(b: Box<Tail<A16>>) -> Box<Tail<dyn Shape>> {
    b
}

#[inline(never)]
fn repeat(v: u64, dst: &mut [u16; 6], big: &mut [u32; 9]) -> [u64; 5] {
    *dst = [0x0101; 6];
    *big = [7; 9];
    [v; 5]
}

#[inline(never)]
fn wide_cmp(a: *const [u8], b: *const [u8]) -> (bool, bool, bool, bool) {
    (a < b, a <= b, a > b, a >= b)
}

#[inline(never)]
fn arith128(a: i128, b: i128, c: u128, d: u128) -> (i128, i128, i128, u128, u128, u128) {
    (a.wrapping_mul(b), a / b, a % b, c.wrapping_mul(d), c / d, c % d)
}

#[inline(never)]
fn ovf128(a: u128, b: i128) -> (Option<u128>, Option<i128>) {
    (a.checked_mul(a), b.checked_mul(b))
}

#[inline(never)]
fn half(x: f64) -> (f16, f32, i32, f128, u64) {
    let h = x as f16;
    let q = x as f128;
    (h, h as f32, h as i32, q, q as u64)
}

/// Scoped locals whose slots can be shared.
#[inline(never)]
fn scopes(n: u32) -> u64 {
    let mut acc = 0u64;
    for i in 0..n {
        {
            let a = [i as u64; 4];
            acc += a[3];
        }
        {
            let b = [i as u16; 9];
            acc += b.iter().map(|&x| x as u64).sum::<u64>();
        }
        let s = format!("{i}");
        acc += s.len() as u64;
    }
    acc
}

fn main() {
    println!("{:?}", tail(bb(&Tail { tag: 1, val: Sq(5) })));
    println!("{:?}", tail(bb(&Tail { tag: 2, val: A16(6) })));
    println!("{:?}", tail(bb(&Tail { tag: 3, val: 7u32 })));
    println!("{:?}", nested(bb(&Outer { a: 9, inner: Tail { tag: 4, val: A16(1) } })));
    let v: Vec<Rc<dyn Shape>> = vec![Rc::new(Sq(2)), Rc::new(A16(3)), Rc::new(4u32)];
    println!("{}", rcs(bb(&v)));

    let cell = RefCell::new([1, 2, 3]);
    {
        let r = coerce_ref(bb(cell.borrow()));
        println!("{:?} {}", &*r, cell.try_borrow_mut().is_err());
    }
    println!("{}", cell.try_borrow_mut().is_ok());
    println!("{}", coerce_pin(bb(Box::pin(Sq(8)))).area());
    let t = coerce_tail(bb(Box::new(Tail { tag: 5, val: A16(9) })));
    println!("{:?}", tail(&t));

    let (mut dst, mut big) = ([0u16; 6], [0u32; 9]);
    println!("{:?}", repeat(bb(11), &mut dst, &mut big));
    println!("{dst:x?} {big:?}");

    let arr = [1u8, 2, 3, 4];
    let (a, b, c) = (&arr[..2] as *const [u8], &arr[..3] as *const [u8], &arr[1..3] as *const [u8]);
    for (x, y) in [(a, a), (a, b), (b, a), (a, c), (c, b)] {
        println!("{:?}", wide_cmp(bb(x), bb(y)));
    }

    println!("{:?}", arith128(bb(-12345678901234567890123), bb(987654321), bb(u128::MAX / 3), bb(12345)));
    println!("{:?}", ovf128(bb(1 << 63), bb(i128::MAX / 2)));
    println!("{:?}", ovf128(bb(1 << 64), bb(-5)));
    let (h, f, i, q, u) = half(bb(1234.5678));
    println!("{} {f} {i} {} {u}", h as f64, q as f64);
    println!("{}", scopes(bb(12)));
}
