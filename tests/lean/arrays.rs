//! Arrays and slices: indexing, sub-slices, iterators, sorting, searching.
include!("common/print.rs");
use std::hint::black_box;

fn sum(xs: &[u32]) -> u64 {
    let mut s = 0u64;
    for &x in xs {
        s += x as u64;
    }
    s
}

fn first_last(xs: &[i16]) -> (i16, i16) {
    match xs {
        [] => (0, 0),
        [a] => (*a, *a),
        [a, .., b] => (*a, *b),
    }
}

fn main() {
    let mut a = [5u32, 3, 9, 1, 7, 2, 8];
    let n = black_box(4);
    out::us(&[a[n] as u128, a.len() as u128, sum(&a) as u128, sum(&a[2..5]) as u128]);
    a[black_box(0)] = 42;
    a.sort_unstable();
    out::us(&a.map(|x| x as u128));
    match a.binary_search(&black_box(8)) {
        Ok(i) => out::u(i as u128),
        Err(i) => out::i(-(i as i128)),
    }
    out::sp();
    out::b(a.contains(&black_box(6)));
    out::sp();
    out::u(a.iter().position(|&x| x > 5).unwrap_or(99) as u128);
    out::sp();
    out::u(a.iter().rev().take(3).sum::<u32>() as u128);
    out::sp();
    out::u(a.iter().map(|x| x * x).filter(|x| x % 2 == 1).count() as u128);
    out::sp();
    out::u(a.iter().copied().max().unwrap_or(0) as u128);
    out::sp();
    out::u(a.iter().zip(a.iter().skip(1)).map(|(x, y)| y - x).fold(0, |m, d| if d > m { d } else { m }) as u128);
    out::nl();
    let v = [-3i16, 4, -5, 6];
    let (f, l) = first_last(&v);
    let (f1, l1) = first_last(&v[1..2]);
    let (f0, _) = first_last(&v[..0]);
    out::is(&[f as i128, l as i128, f1 as i128, l1 as i128, f0 as i128]);
    let mut grid = [[0u8; 4]; 3];
    for i in 0..3 {
        for j in 0..4 {
            grid[i][j] = (i * 4 + j) as u8;
        }
    }
    let flat: u32 = grid.iter().flatten().map(|&x| x as u32).sum();
    out::us(&[grid[2][3] as u128, flat as u128]);
    let mut buf = [0u8; 10];
    buf[2..6].copy_from_slice(&[1, 2, 3, 4]);
    buf.reverse();
    buf[..5].rotate_left(2);
    out::us(&buf.map(|x| x as u128));
    let (left, right) = buf.split_at_mut(black_box(3));
    left[0] = right[0] + 10;
    out::u(buf[0] as u128);
    out::sp();
    for chunk in [1u8, 2, 3, 4, 5, 6, 7].chunks(3) {
        out::u(chunk.iter().map(|&x| x as u128).sum());
        out::sp();
    }
    out::nl();
    let words = ["pear", "fig", "banana", "kiwi"];
    let mut sorted = words;
    sorted.sort();
    for w in sorted {
        out::str(w);
        out::sp();
    }
    out::u(words.iter().map(|w| w.len()).sum::<usize>() as u128);
    out::nl();
    let mut big = [0u64; 64];
    for i in 0..64 {
        big[i] = (i as u64).wrapping_mul(0x9e37_79b9_7f4a_7c15) >> 40;
    }
    big.sort();
    out::us(&[big[0] as u128, big[63] as u128, big[black_box(31)] as u128]);
}
