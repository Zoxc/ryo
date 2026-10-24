//! Assorted: slice patterns with sub-slices, const generics, conditional drops (drop flags),
//! `Repeat` of large arrays, 128-bit fields in aggregates, generic associated consts.
include!("common/print.rs");
use std::hint::black_box;

fn sum_rec(xs: &[u32]) -> u32 {
    match xs {
        [] => 0,
        [first, rest @ ..] => first + sum_rec(rest),
    }
}

fn middle(xs: &[u8]) -> usize {
    match xs {
        [_, mid @ .., _] => mid.len(),
        _ => 0,
    }
}

fn arr_tail(a: [u16; 3]) -> u16 {
    let [_, rest @ ..] = a;
    let [.., last] = rest;
    last
}

struct Matrix<const R: usize, const C: usize> {
    m: [[i32; C]; R],
}

impl<const R: usize, const C: usize> Matrix<R, C> {
    fn transpose(&self) -> Matrix<C, R> {
        let mut t = [[0; R]; C];
        for i in 0..R {
            for j in 0..C {
                t[j][i] = self.m[i][j];
            }
        }
        Matrix { m: t }
    }
}

trait Sized2 {
    const BYTES: usize;
}

impl Sized2 for u32 {
    const BYTES: usize = 4;
}

impl Sized2 for (u8, u64) {
    const BYTES: usize = 9;
}

fn bytes_of<T: Sized2>() -> usize {
    T::BYTES
}

struct Loud(u8);

impl Drop for Loud {
    fn drop(&mut self) {
        out::u(self.0 as u128);
    }
}

#[derive(Clone, Copy)]
struct Wide {
    a: u8,
    b: u128,
    c: bool,
}

fn main() {
    out::us(&[sum_rec(&[1, 2, 3, black_box(4)]) as u128, middle(b"abcde") as u128, middle(b"a") as u128, arr_tail([7u16, 8, 9]) as u128]);
    let m = Matrix { m: [[1, 2, 3], [4, 5, black_box(6)]] };
    let t = m.transpose();
    out::is(&[t.m[2][1] as i128, t.m[0][1] as i128, std::mem::size_of::<Matrix<2, 3>>() as i128]);
    out::us(&[bytes_of::<u32>() as u128, bytes_of::<(u8, u64)>() as u128]);
    let maybe = if black_box(true) { Some(Loud(1)) } else { None };
    let moved;
    let keep = Loud(2);
    if black_box(false) {
        moved = keep;
        drop(moved);
    }
    drop(maybe);
    out::sp();
    let big = [black_box(3u8); 4096];
    out::u(big.iter().map(|&x| x as u128).sum());
    out::sp();
    let ws = [Wide { a: 1, b: u128::MAX - 5, c: true }; 3];
    let w = ws[black_box(2)];
    out::u(w.a as u128 + (w.b >> 120) + w.c as u128);
    out::sp();
    let ow: Option<(u128, bool)> = Some((black_box(1) << 127, false));
    out::b(matches!(ow, Some((x, false)) if x > 1));
    out::sp();
    out::u(std::mem::align_of::<Wide>() as u128);
    out::nl();
}
