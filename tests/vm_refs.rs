//! VM functions that native code reaches only through data: a static fn pointer, a static
//! `&dyn` (its vtable), and a fn pointer in a `const`. Each needs a portal.

fn from_static() -> i32 {
    1
}

trait Get {
    fn get(&self) -> i32;
}

struct S;

impl Get for S {
    fn get(&self) -> i32 {
        2
    }
}

fn from_const() -> i32 {
    3
}

static FP: fn() -> i32 = from_static;
static DYN: &(dyn Get + Sync) = &S;
const CF: fn() -> i32 = from_const;

fn main() {
    println!("{} {} {}", FP(), DYN.get(), CF());
}
