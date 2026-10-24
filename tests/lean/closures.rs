//! Closures (by reference, by move, FnMut, FnOnce), fn pointers, closures coerced to fn
//! pointers, higher-order generics, returned closures, boxed closures.
include!("common/print.rs");
use std::hint::black_box;

fn apply<F: Fn(i64) -> i64>(f: F, x: i64) -> i64 {
    f(x)
}

fn apply_mut<F: FnMut(u32)>(mut f: F, n: u32) {
    for i in 0..n {
        f(i);
    }
}

fn consume<F: FnOnce() -> Vec<u8>>(f: F) -> usize {
    f().len()
}

fn adder(k: i64) -> impl Fn(i64) -> i64 {
    move |x| x + k
}

fn compose(f: fn(i64) -> i64, g: fn(i64) -> i64) -> impl Fn(i64) -> i64 {
    move |x| g(f(x))
}

fn inc(x: i64) -> i64 {
    x + 1
}

fn sq(x: i64) -> i64 {
    x * x
}

fn call_ptr(f: fn(i64) -> i64, x: i64) -> i64 {
    f(x)
}

fn main() {
    let k = black_box(10);
    out::i(apply(|x| x * k, 4) as i128);
    out::sp();
    let mut total = 0u32;
    apply_mut(|i| total += i * i, black_box(5));
    out::u(total as u128);
    out::sp();
    let v = vec![1u8, 2, 3];
    out::u(consume(move || v) as u128);
    out::sp();
    let add5 = adder(5);
    out::i(add5(black_box(1)) as i128);
    out::sp();
    out::i(compose(inc, sq)(black_box(3)) as i128);
    out::sp();
    let fns: [fn(i64) -> i64; 2] = [inc, sq];
    out::i(fns[black_box(1)](7) as i128);
    out::sp();
    out::i(call_ptr(inc, 41) as i128);
    out::sp();
    out::i(call_ptr(|x| x - 1, 41) as i128);
    out::nl();
    let boxed: Vec<Box<dyn Fn(i64) -> i64>> = vec![Box::new(inc), Box::new(move |x| x * k), Box::new(adder(-3))];
    for f in &boxed {
        out::i(f(black_box(6)) as i128);
        out::sp();
    }
    let mut counter = 0;
    let mut tick = || {
        counter += 2;
        counter
    };
    tick();
    let last = tick();
    out::i(last as i128);
    out::sp();
    let dynmut: &mut dyn FnMut() -> i32 = &mut tick;
    out::i(dynmut() as i128);
    out::nl();
}
