//! Structs, tuples, nested aggregates, mem::swap/replace/take.
include!("common/print.rs");
use std::hint::black_box;
use std::mem;

#[derive(Clone, Copy, PartialEq)]
struct Point {
    x: i32,
    y: i32,
}

#[derive(Clone, Copy)]
struct Rect {
    a: Point,
    b: Point,
    tag: u8,
}

struct Mixed {
    small: u8,
    big: u64,
    mid: u16,
    flag: bool,
    wide: u128,
}

#[repr(C)]
struct Repr {
    a: u8,
    b: u32,
    c: u16,
}

#[repr(C, packed)]
struct Packed {
    a: u8,
    b: u32,
}

struct Unit;

fn area(r: &Rect) -> i64 {
    ((r.b.x - r.a.x) as i64) * ((r.b.y - r.a.y) as i64)
}

fn swap_pair(p: (u8, u64)) -> (u64, u8) {
    (p.1, p.0)
}

fn main() {
    let mut r = Rect { a: Point { x: black_box(1), y: 2 }, b: Point { x: 11, y: black_box(22) }, tag: 7 };
    out::is(&[area(&r) as i128, r.tag as i128]);
    let r2 = Rect { tag: 9, ..r };
    r.a.x = -5;
    out::is(&[area(&r) as i128, area(&r2) as i128, (r.a == r2.a) as i128, (r.b == r2.b) as i128]);
    let mut m = Mixed { small: 1, big: 2, mid: 3, flag: true, wide: 1 << 100 };
    m.big += black_box(40);
    m.wide >>= 90;
    out::us(&[m.small as u128, m.big as u128, m.mid as u128, m.flag as u128, m.wide]);
    let t = black_box((1u8, 0xffff_ffff_ffffu64));
    let (a, b) = swap_pair(t);
    out::us(&[a as u128, b as u128]);
    let nested = ((1u16, (2u32, 3u64)), [4u8, 5], Unit);
    out::us(&[(nested.0).0 as u128, ((nested.0).1).1 as u128, nested.1[1] as u128, mem::size_of_val(&nested) as u128]);
    let rp = Repr { a: 1, b: 2, c: 3 };
    out::us(&[rp.a as u128 + rp.b as u128 + rp.c as u128, mem::size_of::<Repr>() as u128, mem::align_of::<Repr>() as u128]);
    let mut pk = Packed { a: 1, b: black_box(0x01020304) };
    pk.b += 1;
    let pb = pk.b;
    out::us(&[pk.a as u128, pb as u128, mem::size_of::<Packed>() as u128]);
    let mut p = Point { x: 1, y: 2 };
    let mut q = Point { x: 3, y: 4 };
    mem::swap(&mut p, &mut q);
    let old = mem::replace(&mut p.x, 100);
    let taken = mem::take(&mut q.y);
    out::is(&[p.x as i128, p.y as i128, q.x as i128, q.y as i128, old as i128, taken as i128]);
    let mut arr = [Point { x: 0, y: 0 }; 3];
    for (i, pt) in arr.iter_mut().enumerate() {
        pt.x = i as i32 * 10;
        pt.y = -(i as i32);
    }
    arr.swap(0, 2);
    out::is(&[arr[0].x as i128, arr[0].y as i128, arr[2].x as i128]);
}
