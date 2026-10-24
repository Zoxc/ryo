//! Loops, labeled breaks, loop values, recursion, mutual recursion, while-let.
include!("common/print.rs");
use std::hint::black_box;

fn fib(n: u32) -> u64 {
    if n < 2 { n as u64 } else { fib(n - 1) + fib(n - 2) }
}

fn ack(m: u64, n: u64) -> u64 {
    if m == 0 {
        n + 1
    } else if n == 0 {
        ack(m - 1, 1)
    } else {
        ack(m - 1, ack(m, n - 1))
    }
}

fn is_even(n: u32) -> bool {
    if n == 0 { true } else { is_odd(n - 1) }
}

fn is_odd(n: u32) -> bool {
    if n == 0 { false } else { is_even(n - 1) }
}

fn gcd(a: u64, b: u64) -> u64 {
    if b == 0 { a } else { gcd(b, a % b) }
}

fn collatz(mut n: u64) -> u32 {
    let mut steps = 0;
    while n != 1 {
        n = if n % 2 == 0 { n / 2 } else { 3 * n + 1 };
        steps += 1;
    }
    steps
}

fn main() {
    out::us(&[fib(black_box(15)) as u128, ack(2, black_box(3)) as u128, is_even(black_box(31)) as u128, gcd(black_box(1071), 462) as u128]);
    out::u(collatz(black_box(27)) as u128);
    out::sp();
    let found = 'outer: loop {
        for i in 1.. {
            for j in 1..i {
                if i * i + j * j == black_box(125) {
                    break 'outer (i, j);
                }
            }
            if i > 20 {
                break 'outer (0, 0);
            }
        }
    };
    out::u(found.0 as u128);
    out::sp();
    out::u(found.1 as u128);
    out::sp();
    let mut n = 0u32;
    let mut primes = 0;
    while n < black_box(200) {
        n += 1;
        if n < 2 {
            continue;
        }
        let mut d = 2;
        let mut prime = true;
        while d * d <= n {
            if n % d == 0 {
                prime = false;
                break;
            }
            d += 1;
        }
        if prime {
            primes += 1;
        }
    }
    out::u(primes as u128);
    out::sp();
    let mut stack = vec![1u32, 2, 3];
    let mut acc = 0;
    while let Some(top) = stack.pop() {
        acc = acc * 10 + top;
    }
    out::u(acc as u128);
    out::sp();
    let x = black_box(7u8);
    let class = match x {
        0 => 0,
        1..=5 => 1,
        6 | 7 => 2,
        _ if x % 2 == 0 => 3,
        _ => 4,
    };
    out::u(class as u128);
    out::nl();
}
