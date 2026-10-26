//! Many modules, so rustc spreads them over several codegen units: one image each
//! (design/backend.md#pipeline). Calls, fn pointers, vtables and statics cross the units;
//! `#[inline]` functions are copied into every unit that uses them; a generic is
//! instantiated from several units; a thread local is read from another unit.

use std::cell::Cell;

mod leaf {
    /// Copied into each unit that calls it (`LocalCopy`), each image its own copy.
    #[inline]
    pub fn twice(x: u64) -> u64 {
        x * 2
    }

    #[inline(never)]
    pub fn add(a: u64, b: u64) -> u64 {
        a.wrapping_add(b)
    }

    /// Instantiated by `even` and `odd` with different types.
    #[inline(never)]
    pub fn sum<T: Copy + Into<u64>>(xs: &[T]) -> u64 {
        xs.iter().map(|&x| x.into()).fold(0, add)
    }

    thread_local! {
        pub static COUNT: std::cell::Cell<u32> = const { std::cell::Cell::new(0) };
    }
}

mod even {
    #[inline(never)]
    pub fn is_even(n: u32) -> bool {
        super::leaf::COUNT.with(|c| c.set(c.get() + 1));
        if n == 0 { true } else { super::odd::is_odd(n - 1) }
    }

    pub fn total() -> u64 {
        super::leaf::sum(&[1u8, 2, 3]) + super::leaf::twice(4)
    }
}

mod odd {
    #[inline(never)]
    pub fn is_odd(n: u32) -> bool {
        if n == 0 { false } else { super::even::is_even(n - 1) }
    }

    pub fn total() -> u64 {
        super::leaf::sum(&[10u32, 20]) + super::leaf::twice(5)
    }
}

mod shapes {
    pub trait Shape {
        fn area(&self) -> u64;
    }

    pub struct Square(pub u64);
    pub struct Rect(pub u64, pub u64);

    impl Shape for Square {
        fn area(&self) -> u64 {
            super::leaf::add(0, self.0 * self.0)
        }
    }

    impl Shape for Rect {
        fn area(&self) -> u64 {
            self.0 * self.1
        }
    }

    pub fn all() -> Vec<Box<dyn Shape>> {
        vec![Box::new(Square(3)), Box::new(Rect(2, 5))]
    }
}

mod table {
    /// Fn pointers into other units, in a static.
    pub static OPS: [fn(u64, u64) -> u64; 2] = [super::leaf::add, mul];

    fn mul(a: u64, b: u64) -> u64 {
        a * b
    }
}

mod drop_order {
    pub struct Noisy(pub &'static str);

    impl Drop for Noisy {
        fn drop(&mut self) {
            println!("drop {}", self.0);
        }
    }
}

fn main() {
    let parity: Vec<bool> = (0..6).map(even::is_even).collect();
    println!("{parity:?} {}", leaf::COUNT.with(Cell::get));
    println!("{} {}", even::total(), odd::total());
    let areas: Vec<u64> = shapes::all().iter().map(|s| s.area()).collect();
    println!("{areas:?}");
    println!("{} {}", (table::OPS[0])(3, 4), (table::OPS[1])(3, 4));
    let _a = drop_order::Noisy("a");
    let r = std::panic::catch_unwind(|| {
        let _b = drop_order::Noisy("b");
        if leaf::twice(1) == 2 {
            panic!("across units");
        }
    });
    println!("caught: {}", r.is_err());
}
