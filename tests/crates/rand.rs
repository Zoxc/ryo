//! `y bench crates` workload for rand: seeded generators, ranges, shuffles and sampling.
use rand::prelude::*;
use rand::rngs::{SmallRng, StdRng};

fn main() {
    let mut std = StdRng::seed_from_u64(42);
    let mut small = SmallRng::seed_from_u64(7);
    let mut sum = 0u64;
    for _ in 0..200_000 {
        sum = sum.wrapping_add(std.random_range(0..1000u64));
        sum = sum.wrapping_add(small.random::<u32>() as u64);
    }
    let mut v: Vec<u32> = (0..50_000).collect();
    v.shuffle(&mut std);
    let picked: u64 = v.sample(&mut small, 100).map(|&x| x as u64).sum();
    let mut f = 0.0f64;
    for _ in 0..100_000 {
        f += std.random::<f64>();
    }
    let trues = (0..100_000).filter(|_| small.random_bool(0.3)).count();
    println!("sum {sum}, first {:?}, picked {picked}, f {f:.3}, trues {trues}", &v[..4]);
}
