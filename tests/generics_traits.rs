//! Generics, trait objects, default methods, operator overloading, Drop order, Any.
use std::fmt::Display;
use std::ops::Add;

trait Animal {
    fn name(&self) -> String;
    fn speak(&self) -> String {
        format!("{} makes a sound", self.name())
    }
}

struct Dog;
struct Cat(u32);

impl Animal for Dog {
    fn name(&self) -> String {
        "dog".into()
    }
    fn speak(&self) -> String {
        "woof".into()
    }
}

impl Animal for Cat {
    fn name(&self) -> String {
        format!("cat#{}", self.0)
    }
}

#[derive(Debug, Clone, Copy)]
struct V2<T>(T, T);

impl<T: Add<Output = T>> Add for V2<T> {
    type Output = V2<T>;
    fn add(self, o: V2<T>) -> V2<T> {
        V2(self.0 + o.0, self.1 + o.1)
    }
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

fn show_all(items: &[&dyn Display]) -> String {
    items.iter().map(|i| i.to_string()).collect::<Vec<_>>().join("|")
}

struct Noisy(&'static str);

impl Drop for Noisy {
    fn drop(&mut self) {
        println!("drop {}", self.0);
    }
}

fn main() {
    let zoo: Vec<Box<dyn Animal>> = vec![Box::new(Dog), Box::new(Cat(7))];
    for a in &zoo {
        println!("{}", a.speak());
    }
    println!("{:?} {:?}", V2(1, 2) + V2(3, 4), V2(0.5, 1.5) + V2(1.0, 1.0));
    println!("{} {} {}", largest(&[3, 9, 2]), largest(&[1.5, -2.0]), largest(&['x', 'b']));
    println!("{}", show_all(&[&1, &"two", &3.5, &'c']));
    let _a = Noisy("a");
    {
        let _b = Noisy("b");
        let c = Noisy("c");
        std::mem::drop(c);
    }
    let any: Box<dyn std::any::Any> = Box::new(5u16);
    println!("{:?} {:?}", any.downcast_ref::<u16>(), any.downcast_ref::<u32>());
}
