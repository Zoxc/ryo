//! Enums: data-carrying variants, explicit discriminants, niche layouts (`Option<&T>`,
//! `Option<NonZero>`, nested options, `Option<bool>`, `Option<char>`), match.
include!("common/print.rs");
use std::hint::black_box;
use std::num::NonZeroU32;

#[derive(Clone, Copy)]
enum Shape {
    Circle(u32),
    Rect { w: u16, h: u16 },
    Empty,
    Tri(u8, u8, u8),
}

#[repr(i8)]
#[derive(Clone, Copy)]
enum Small {
    Neg = -3,
    Zero = 0,
    Big = 100,
}

#[derive(Clone, Copy)]
enum Wrap<'a> {
    A(&'a u64),
    B,
}

enum Deep {
    Leaf(Option<Option<bool>>),
    Pair(u8, Option<char>),
}

fn area(s: Shape) -> u64 {
    match s {
        Shape::Circle(r) => 3 * (r as u64) * (r as u64),
        Shape::Rect { w, h } => w as u64 * h as u64,
        Shape::Empty => 0,
        Shape::Tri(a, b, c) => a as u64 + b as u64 + c as u64,
    }
}

fn opt_ref(o: Option<&u32>) -> u32 {
    match o {
        Some(x) => *x,
        None => 1000,
    }
}

fn nz(o: Option<NonZeroU32>) -> u32 {
    o.map_or(0, |n| n.get())
}

fn deep(d: &Deep) -> u32 {
    match d {
        Deep::Leaf(None) => 1,
        Deep::Leaf(Some(None)) => 2,
        Deep::Leaf(Some(Some(false))) => 3,
        Deep::Leaf(Some(Some(true))) => 4,
        Deep::Pair(n, Some(c)) => *n as u32 + *c as u32,
        Deep::Pair(n, None) => *n as u32,
    }
}

fn main() {
    let shapes = [Shape::Circle(black_box(3)), Shape::Rect { w: 4, h: 5 }, Shape::Empty, Shape::Tri(1, 2, black_box(3))];
    for s in shapes {
        out::u(area(s) as u128);
        out::sp();
    }
    out::u(std::mem::size_of::<Shape>() as u128);
    out::nl();
    let smalls = [Small::Neg, Small::Zero, Small::Big];
    for s in smalls {
        out::i(s as i8 as i128);
        out::sp();
    }
    out::nl();
    let x = black_box(77u32);
    out::us(&[opt_ref(Some(&x)) as u128, opt_ref(None) as u128, std::mem::size_of::<Option<&u32>>() as u128]);
    out::us(&[nz(NonZeroU32::new(black_box(5))) as u128, nz(NonZeroU32::new(black_box(0))) as u128, std::mem::size_of::<Option<NonZeroU32>>() as u128]);
    let y = 9u64;
    for w in [Wrap::A(&y), Wrap::B] {
        match black_box(w) {
            Wrap::A(r) => out::u(*r as u128),
            Wrap::B => out::str("B"),
        }
        out::sp();
    }
    out::nl();
    let ds = [
        Deep::Leaf(None),
        Deep::Leaf(Some(None)),
        Deep::Leaf(Some(Some(false))),
        Deep::Leaf(black_box(Some(Some(true)))),
        Deep::Pair(5, Some('a')),
        Deep::Pair(6, None),
    ];
    for d in &ds {
        out::u(deep(d) as u128);
        out::sp();
    }
    out::us(&[std::mem::size_of::<Deep>() as u128, std::mem::size_of::<Option<Option<bool>>>() as u128, std::mem::size_of::<Option<char>>() as u128]);
    let r: Result<u32, i8> = if black_box(true) { Ok(3) } else { Err(-1) };
    let e: Result<u32, i8> = Err(black_box(-7));
    for v in [r, e] {
        match v {
            Ok(n) => out::u(n as u128),
            Err(c) => out::i(c as i128),
        }
        out::sp();
    }
    let ord = black_box(3).cmp(&black_box(5));
    out::i(ord as i8 as i128);
    out::sp();
    let ob: Option<Box<u16>> = Some(Box::new(black_box(12)));
    out::u(ob.map_or(0, |b| *b) as u128);
    out::nl();
    let mut st = 0u8;
    let mut trace = [0u8; 8];
    for i in 0..8 {
        st = match (st, i % 3) {
            (0, 0) => 1,
            (0, _) => 2,
            (1, 1) | (2, 2) => 0,
            (s, k) => s + k as u8,
        };
        trace[i] = st;
    }
    out::us(&trace.map(|x| x as u128));
}
