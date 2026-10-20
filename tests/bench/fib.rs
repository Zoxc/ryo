//! `y bench`: recursive calls.

fn fib(n: u32) -> u64 {
    if n < 2 { n as u64 } else { fib(n - 1) + fib(n - 2) }
}

fn main() {
    let n = std::hint::black_box(37);
    println!("fib({n}) = {}", fib(n));
}
