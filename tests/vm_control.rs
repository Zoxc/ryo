//! Milestone 4: branches, loops, `match` on integers (dense and sparse switches), and enums
//! through their layouts (direct tags, niches, discriminant values) in the VM.
use std::hint::black_box;

fn collatz(mut n: u64) -> u32 {
    let mut steps = 0;
    while n != 1 {
        n = if n % 2 == 0 { n / 2 } else { 3 * n + 1 };
        steps += 1;
    }
    steps
}

fn dense(x: u8) -> &'static str {
    match x {
        0 => "zero",
        1 => "one",
        2 => "two",
        3 => "three",
        5 => "five",
        _ => "many",
    }
}

fn sparse(x: i64) -> i32 {
    match x {
        -1_000_000 => 1,
        7 => 2,
        1_099_511_627_776 => 3,
        i64::MIN => 4,
        _ => 0,
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Shape {
    Circle(f64),
    Rect { w: u32, h: u32 },
    Empty,
}

fn area(s: Shape) -> f64 {
    match s {
        Shape::Circle(r) => 3.0 * r * r,
        Shape::Rect { w, h } => (w * h) as f64,
        Shape::Empty => 0.0,
    }
}

#[derive(Debug, Clone, Copy)]
#[repr(i8)]
enum Signed {
    Low = -100,
    Mid = 0,
    High = 100,
}

fn discr(s: Signed) -> i8 {
    s as i8
}

fn niches(a: Option<&u32>, b: Option<bool>, c: Option<Option<char>>) -> (u32, u8, u32) {
    let x = match a {
        Some(v) => *v,
        None => 99,
    };
    let y = match b {
        Some(true) => 1,
        Some(false) => 2,
        None => 3,
    };
    let z = match c {
        Some(Some(c)) => c as u32,
        Some(None) => 1,
        None => 2,
    };
    (x, y, z)
}

fn make(i: u32) -> Shape {
    match i % 3 {
        0 => Shape::Circle(i as f64),
        1 => Shape::Rect { w: i, h: i + 1 },
        _ => Shape::Empty,
    }
}

fn switch128(x: u128) -> u8 {
    match x {
        0 => 1,
        1 => 2,
        0xffff_ffff_ffff_ffff_ffff => 3,
        u128::MAX => 4,
        _ => 0,
    }
}

/// Niche-encoded in the `bool`: the untagged variant `Data` sits in the middle of the
/// niche variant range `A..=D`.
#[derive(Debug, Clone, Copy)]
enum Mid {
    A,
    B,
    Data(bool),
    C,
    D,
}

fn mid(i: u8) -> Mid {
    match i {
        0 => Mid::A,
        1 => Mid::B,
        2 => Mid::Data(true),
        3 => Mid::C,
        4 => Mid::D,
        _ => Mid::Data(false),
    }
}

fn mid_index(m: Mid) -> u32 {
    match m {
        Mid::A => 10,
        Mid::B => 11,
        Mid::Data(b) => 20 + b as u32,
        Mid::C => 12,
        Mid::D => 13,
    }
}

fn labeled() -> u32 {
    let mut n = 0;
    'outer: for i in 0..10u32 {
        for j in 0..10u32 {
            if i * j > 20 {
                break 'outer;
            }
            if j > i {
                continue 'outer;
            }
            n += i + j;
        }
    }
    n
}

fn main() {
    println!("{} {}", collatz(black_box(27)), collatz(black_box(97)));
    for x in [0u8, 1, 2, 3, 4, 5, 200] {
        print!("{} ", dense(black_box(x)));
    }
    println!();
    for x in [-1_000_000, 7, 1 << 40, i64::MIN, 8] {
        print!("{} ", sparse(black_box(x)));
    }
    println!();
    for i in 0..4 {
        let s = make(black_box(i));
        println!("{s:?} {}", area(s));
    }
    println!("{} {} {}", discr(Signed::Low), discr(black_box(Signed::Mid)), discr(Signed::High));
    let v = 5u32;
    println!("{:?}", niches(Some(&v), Some(false), Some(Some('x'))));
    println!("{:?}", niches(None, None, Some(None)));
    println!("{:?}", niches(black_box(None), black_box(Some(true)), black_box(None)));
    println!("{}", labeled());
    for x in [0u128, 1, 0xffff_ffff_ffff_ffff_ffff, u128::MAX, 2] {
        print!("{} ", switch128(black_box(x)));
    }
    println!();
    println!("{}", std::mem::size_of::<Mid>());
    for i in 0..6 {
        let m = mid(black_box(i));
        print!("{m:?}={} ", mid_index(m));
    }
    println!();
}
