//! Iterator adapters and `impl Trait` returns.
include!("common/print.rs");
use std::hint::black_box;

fn evens(n: u32) -> impl Iterator<Item = u32> {
    (0..n).filter(|x| x % 2 == 0)
}

fn main() {
    let v: Vec<u32> = (1..=10).collect();
    out::u(v.iter().step_by(3).sum::<u32>() as u128);
    out::sp();
    out::u(v.windows(3).map(|w| w[0] * w[2]).max().unwrap_or(0) as u128);
    out::sp();
    out::u(v.iter().chain(evens(black_box(7)).collect::<Vec<_>>().iter()).count() as u128);
    out::sp();
    out::u(v.iter().flat_map(|&x| 0..x).filter(|&y| y == 3).count() as u128);
    out::sp();
    let mut p = v.iter().peekable();
    let mut runs = 0;
    while let Some(&x) = p.next() {
        if let Some(&&y) = p.peek() {
            if y == x + 1 {
                runs += 1;
            }
        }
    }
    out::u(runs as u128);
    out::sp();
    let (small, big): (Vec<u32>, Vec<u32>) = v.iter().partition(|&&x| x < 4);
    out::us(&[small.len() as u128, big.len() as u128]);
    let s: String = "a1b2c3".chars().filter(|c| c.is_ascii_digit()).rev().collect();
    out::str(&s);
    out::sp();
    let words = ["the", "quick", "brown", "fox"];
    let longest = words.iter().copied().max_by_key(|w| w.len()).unwrap_or("");
    out::str(longest);
    out::sp();
    out::b(v.iter().all(|&x| x > 0));
    out::sp();
    out::b(v.iter().any(|&x| x > 10));
    out::sp();
    let pos = v.iter().rposition(|&x| x % 4 == 0);
    out::u(pos.map_or(99, |p| p as u128));
    out::sp();
    let folded = v.iter().try_fold(0u32, |acc, &x| acc.checked_add(x * 1000));
    out::u(folded.unwrap_or(0) as u128);
    out::nl();
    let mut sorted: Vec<(u8, &str)> = vec![(3, "c"), (1, "a"), (2, "b"), (1, "z")];
    sorted.sort_by(|a, b| b.0.cmp(&a.0).then(a.1.cmp(b.1)));
    for (n, s) in &sorted {
        out::u(*n as u128);
        out::str(s);
        out::sp();
    }
    let mut dedup = vec![1, 1, 2, 3, 3, 3, 4];
    dedup.dedup();
    out::u(dedup.len() as u128);
    out::nl();
}
