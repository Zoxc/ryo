//! Milestone 4: VM → VM calls, references, structs and tuples, constants, and islands: calls
//! of native and upstream functions, trait objects, fn pointers, drops and unwinding through
//! VM frames.
use std::hint::black_box;

#[derive(Debug, Clone, Copy, PartialEq)]
struct P {
    x: i32,
    y: i32,
}

fn add(a: P, b: P) -> P {
    P { x: a.x + b.x, y: a.y + b.y }
}

fn swap(t: (u8, u64, i16)) -> (i16, u64, u8) {
    (t.2, t.1, t.0)
}

fn bump(p: &mut P, by: &i32) {
    p.x += *by;
    p.y -= *by;
}

fn sum(xs: &[u32]) -> u32 {
    let mut s = 0;
    for x in xs {
        s += x;
    }
    s
}

fn fib(n: u32) -> u64 {
    if n < 2 { n as u64 } else { fib(n - 1) + fib(n - 2) }
}

trait Speak {
    fn speak(&self) -> String;
}

struct Dog(u8);

impl Speak for Dog {
    fn speak(&self) -> String {
        format!("woof x{}", self.0)
    }
}

fn talk(s: &dyn Speak) -> String {
    s.speak()
}

const TABLE: [u16; 4] = [1, 10, 100, 1000];
static GREETING: &str = "hello";

fn constants(i: usize) -> (u16, &'static str, usize) {
    (TABLE[i], GREETING, GREETING.len())
}

fn apply(f: fn(u32) -> u32, x: u32) -> u32 {
    f(x)
}

fn double(x: u32) -> u32 {
    x * 2
}

fn closures(k: u32) -> u32 {
    let add_k = |x: u32| x + k;
    let v: Vec<u32> = (1..=4).map(add_k).collect();
    v.iter().sum::<u32>() + apply(double, k)
}

struct Noisy(&'static str);

impl Drop for Noisy {
    fn drop(&mut self) {
        println!("drop {}", self.0);
    }
}

fn may_panic(fail: bool) -> u32 {
    let _a = Noisy("a");
    let v = vec![1u32, 2, 3];
    let i = if fail { 10 } else { 1 };
    v[i]
}

fn main() {
    println!("{:?}", add(P { x: 1, y: 2 }, black_box(P { x: 10, y: 20 })));
    println!("{:?}", swap(black_box((1, 2, -3))));
    let mut p = P { x: 0, y: 0 };
    bump(&mut p, &black_box(5));
    println!("{p:?} {}", sum(&[1, 2, 3, black_box(4)]));
    println!("{}", fib(black_box(20)));
    println!("{}", talk(&Dog(black_box(3))));
    let boxed: Box<dyn Speak> = Box::new(Dog(7));
    println!("{}", boxed.speak());
    println!("{:?}", constants(black_box(2)));
    println!("{}", closures(black_box(10)));
    println!("{}", may_panic(false));
    let r = std::panic::catch_unwind(|| may_panic(black_box(true)));
    println!("caught: {}", r.is_err());
    let s = String::from("abc") + &"def".repeat(2);
    println!("{s} {}", s.len());
}
