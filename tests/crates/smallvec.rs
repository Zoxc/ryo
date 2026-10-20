//! `y bench crates` workload for smallvec: inline and spilled vectors, sorting and draining.
use smallvec::{SmallVec, smallvec};

fn main() {
    let mut total = 0u64;
    let mut x: u32 = 1;
    for round in 0..20_000u32 {
        let mut v: SmallVec<[u32; 8]> = smallvec![round, round + 1];
        for _ in 0..(round % 24) {
            x = x.wrapping_mul(1664525).wrapping_add(1013904223);
            v.push(x >> 8);
        }
        v.sort_unstable();
        v.dedup();
        v.insert(0, 7);
        v.retain(|e| *e % 5 != 0);
        total += v.iter().map(|&e| e as u64).sum::<u64>() + v.spilled() as u64;
        let half = v.len() / 2;
        let drained: SmallVec<[u32; 4]> = v.drain(..half).collect();
        total += drained.len() as u64;
    }
    println!("total {total}");
}
