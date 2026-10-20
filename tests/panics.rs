//! Panics caught with catch_unwind, unwinding through drops, then an uncaught panic (exit 101).
use std::panic;

struct Guard(u32);

impl Drop for Guard {
    fn drop(&mut self) {
        println!("guard {} dropped", self.0);
    }
}

fn may_panic(n: u32) -> u32 {
    let _g = Guard(n);
    if n % 2 == 1 {
        panic!("odd number {n}");
    }
    n * 10
}

fn main() {
    panic::set_hook(Box::new(|info| {
        let msg = info.payload().downcast_ref::<String>().cloned().unwrap_or_default();
        println!("hook: {msg}");
    }));
    for n in 0..4 {
        let r = panic::catch_unwind(|| may_panic(n));
        println!("{n}: {:?}", r.map_err(|e| e.downcast::<String>().map(|s| *s).ok()));
    }
    let r = panic::catch_unwind(|| {
        let v: Vec<u8> = Vec::new();
        v[std::hint::black_box(3)]
    });
    println!("index panic caught: {}", r.is_err());
    let _ = panic::take_hook();
    let _g = Guard(99);
    let opt: Option<u8> = std::hint::black_box(None);
    opt.expect("final uncaught panic");
}
