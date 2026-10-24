//! Generics and trait objects: static and dynamic dispatch, default methods, supertraits
//! and upcasting, `dyn` behind `&`, `Box` and `&mut`, drop through `dyn`.
include!("common/print.rs");
use std::hint::black_box;

trait Named {
    fn name(&self) -> &'static str;
}

trait Animal: Named {
    fn legs(&self) -> u32;
    fn speak(&self) -> u32 {
        self.legs() * 10
    }
}

struct Dog(u32);
struct Bird;

impl Named for Dog {
    fn name(&self) -> &'static str {
        "dog"
    }
}

impl Animal for Dog {
    fn legs(&self) -> u32 {
        4
    }
    fn speak(&self) -> u32 {
        self.0
    }
}

impl Named for Bird {
    fn name(&self) -> &'static str {
        "bird"
    }
}

impl Animal for Bird {
    fn legs(&self) -> u32 {
        2
    }
}

impl Drop for Dog {
    fn drop(&mut self) {
        out::str("drop dog ");
        out::u(self.0 as u128);
        out::nl();
    }
}

trait Shape {
    fn area(&self) -> f64;
}

impl Shape for (f64, f64) {
    fn area(&self) -> f64 {
        self.0 * self.1
    }
}

impl Shape for f64 {
    fn area(&self) -> f64 {
        3.0 * self * self
    }
}

fn total_area(shapes: &[&dyn Shape]) -> f64 {
    shapes.iter().map(|s| s.area()).sum()
}

fn describe<T: Animal + ?Sized>(a: &T) -> u32 {
    a.legs() + a.speak()
}

fn largest<T: PartialOrd + Copy>(xs: &[T]) -> T {
    let mut m = xs[0];
    for &x in xs {
        if x > m {
            m = x;
        }
    }
    m
}

struct Stack<T> {
    items: Vec<T>,
}

impl<T: Copy + Default> Stack<T> {
    fn push(&mut self, t: T) {
        self.items.push(t);
    }
    fn pop(&mut self) -> T {
        self.items.pop().unwrap_or_default()
    }
}

fn main() {
    let zoo: Vec<Box<dyn Animal>> = vec![Box::new(Dog(black_box(7))), Box::new(Bird), Box::new(Dog(8))];
    for a in &zoo {
        out::str(a.name());
        out::sp();
        out::u(describe(a.as_ref()) as u128);
        out::sp();
        let n: &dyn Named = a.as_ref();
        out::str(n.name());
        out::nl();
    }
    out::u(describe(&Bird) as u128);
    out::nl();
    let sq = (2.0f64, 3.5f64);
    let c = 1.5f64;
    out::hex(total_area(&[&sq, &c, &black_box(2.0f64)]).to_bits() as u128);
    out::nl();
    out::is(&[largest(&[3i32, -9, 27, 4]) as i128, largest(&[b'a', b'z', b'q']) as i128]);
    let mut s = Stack { items: Vec::new() };
    s.push(1u64);
    s.push(2);
    out::us(&[s.pop() as u128, s.pop() as u128, s.pop() as u128]);
    drop(zoo);
    out::str("after zoo\n");
    let mut boxed: Box<dyn Animal> = Box::new(Dog(9));
    out::u(boxed.legs() as u128);
    out::nl();
    boxed = Box::new(Bird);
    out::str(boxed.name());
    out::nl();
}
