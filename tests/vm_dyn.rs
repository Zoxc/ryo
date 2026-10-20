//! Milestone 5: virtual calls (`call.ind` through the vtable) with every receiver kind,
//! `dyn Fn*`, closures, and the shims (`ClosureOnce`, `FnPtr`, `VTable`, `Reify`, `Clone`,
//! drop glue) as VM functions.
use std::fmt::Debug;
use std::hint::black_box;
use std::pin::Pin;
use std::rc::Rc;

trait Shape: Debug {
    fn area(&self) -> f64;
    fn scale(&mut self, k: f64);
    fn name(&self) -> String {
        format!("shape with area {:.2}", self.area())
    }
    // Arguments with and without niches next to the receiver: the argument block of a
    // virtual call must match the callee's.
    fn mixed(&self, r: &u64, x: u8, y: usize, z: Option<&u32>) -> u64;
    fn big(&self, seed: u32) -> [u64; 9];
    fn boxed(self: Box<Self>) -> u32;
    fn rc(self: Rc<Self>) -> usize;
    fn pinned(self: Pin<&mut Self>) -> i32;
}

#[derive(Debug, Clone)]
struct Circle {
    r: f64,
}

#[derive(Debug, Clone)]
struct Rect {
    w: f64,
    h: f64,
    tag: u8,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        3.0 * self.r * self.r
    }
    fn scale(&mut self, k: f64) {
        self.r *= k;
    }
    fn mixed(&self, r: &u64, x: u8, y: usize, z: Option<&u32>) -> u64 {
        *r + x as u64 * 3 + y as u64 * 7 + z.map_or(1000, |v| *v as u64) + self.r as u64
    }
    fn big(&self, seed: u32) -> [u64; 9] {
        let mut a = [0u64; 9];
        for (i, v) in a.iter_mut().enumerate() {
            *v = seed as u64 * i as u64 + self.r as u64;
        }
        a
    }
    fn boxed(self: Box<Self>) -> u32 {
        self.r as u32 + 1
    }
    fn rc(self: Rc<Self>) -> usize {
        Rc::strong_count(&self)
    }
    fn pinned(self: Pin<&mut Self>) -> i32 {
        let s = self.get_mut();
        s.r += 1.0;
        s.r as i32
    }
}

impl Shape for Rect {
    fn area(&self) -> f64 {
        self.w * self.h
    }
    fn scale(&mut self, k: f64) {
        self.w *= k;
        self.h *= k;
    }
    fn name(&self) -> String {
        format!("rect {}x{} #{}", self.w, self.h, self.tag)
    }
    fn mixed(&self, r: &u64, x: u8, y: usize, z: Option<&u32>) -> u64 {
        *r * 2 + x as u64 + y as u64 + z.map_or(5, |v| *v as u64 * 2) + self.tag as u64
    }
    fn big(&self, seed: u32) -> [u64; 9] {
        [seed as u64; 9]
    }
    fn boxed(self: Box<Self>) -> u32 {
        self.tag as u32 * 100
    }
    fn rc(self: Rc<Self>) -> usize {
        Rc::strong_count(&self) + 100
    }
    fn pinned(self: Pin<&mut Self>) -> i32 {
        -(self.tag as i32)
    }
}

impl Drop for Rect {
    fn drop(&mut self) {
        println!("drop rect {}", self.tag);
    }
}

trait Animal {
    fn speak(&self) -> &'static str;
    fn legs(&self) -> u32 {
        4
    }
}
trait Pet: Animal {
    fn owner(&self) -> &str;
}
struct Dog(String);
impl Animal for Dog {
    fn speak(&self) -> &'static str {
        "woof"
    }
}
impl Pet for Dog {
    fn owner(&self) -> &str {
        &self.0
    }
}

fn shapes() {
    let mut shapes: Vec<Box<dyn Shape>> = vec![Box::new(Circle { r: 2.0 }), Box::new(Rect { w: 2.0, h: 3.5, tag: 7 })];
    for s in shapes.iter_mut() {
        s.scale(2.0);
        println!("{} / {:?}", s.name(), s);
        let r = 40u64;
        let v = 9u32;
        println!("mixed {} {}", s.mixed(&r, 3, 11, Some(&v)), s.mixed(&r, 255, usize::MAX / 64, None));
        println!("big {:?}", s.big(13));
    }
    for s in shapes {
        println!("boxed {}", s.boxed());
    }
    let rc: Rc<dyn Shape> = Rc::new(Circle { r: 1.0 });
    let rc2 = rc.clone();
    println!("rc {} {}", rc.rc(), rc2.area());
    let mut c = Circle { r: 4.0 };
    let p: Pin<&mut dyn Shape> = Pin::new(&mut c) as Pin<&mut Circle>;
    println!("pinned {}", p.pinned());
}

fn upcast() {
    let pets: Vec<Box<dyn Pet>> = vec![Box::new(Dog("ann".into())), Box::new(Dog("bob".into()))];
    for p in &pets {
        let a: &dyn Animal = p.as_ref();
        println!("{} says {} on {} legs", p.owner(), a.speak(), a.legs());
    }
}

fn apply(f: &dyn Fn(i32) -> i32, x: i32) -> i32 {
    f(x) + f(x + 1)
}

fn apply_mut(f: &mut dyn FnMut(u8, &str) -> usize) -> usize {
    f(1, "ab") + f(2, "cde")
}

fn apply_once(f: Box<dyn FnOnce(String) -> String>) -> String {
    f("once".to_string())
}

fn call_once<F: FnOnce(u32) -> u32>(f: F, x: u32) -> u32 {
    f(x)
}

fn call_mut<F: FnMut(u32) -> u32>(mut f: F, x: u32) -> u32 {
    f(x) + f(x)
}

fn plain(x: u32) -> u32 {
    x * 3
}

trait Step {
    fn step(&self, n: u32) -> u32;
}
struct S(u32);
impl Step for S {
    fn step(&self, n: u32) -> u32 {
        n + self.0
    }
}

fn closures() {
    let k = 10;
    println!("apply {}", apply(&|x| x * k, 4));
    let mut count = 0usize;
    let mut f = |a: u8, s: &str| {
        count += a as usize * s.len();
        count
    };
    println!("apply_mut {}", apply_mut(&mut f));
    let suffix = String::from("-suffix");
    println!("{}", apply_once(Box::new(move |s| s + &suffix)));
    let mut once: Vec<Box<dyn FnOnce() -> u32>> = Vec::new();
    for i in 0..3u32 {
        let v = vec![i; i as usize];
        once.push(Box::new(move || v.iter().sum::<u32>() + i));
    }
    for f in once {
        print!("{} ", f());
    }
    println!();
}

fn shims() {
    // Clone shims (tuples, closures), FnPtr shims, ClosureOnce shims, Reify shims.
    let t = (Circle { r: 1.5 }, 5u64, String::from("x"));
    println!("{:?}", t.clone());
    let s = String::from("captured");
    let cl = move |x: u32| s.len() as u32 + x;
    let cl2 = cl.clone();
    println!("{} {}", cl(1), cl2(2));
    let fp: fn(u32) -> u32 = black_box(plain);
    println!("{} {}", call_once(fp, 2), call_mut(fp, 3));
    let k = 7;
    let c = move |x: u32| x + k;
    println!("{} {}", call_once(c, 1), call_mut(c, 2));
    let m: fn(&S, u32) -> u32 = <S as Step>::step;
    println!("{}", m(&S(2), 3));
    let d: fn(&'static dyn Step, u32) -> u32 = <dyn Step>::step;
    println!("{}", d(&S(10), 1));
}

fn main() {
    shapes();
    upcast();
    closures();
    shims();
}
