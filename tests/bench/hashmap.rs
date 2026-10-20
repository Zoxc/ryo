//! `y bench`: HashMap inserts, lookups and removals. The results don't depend on iteration
//! order, so the random hasher seed doesn't change the output.

use std::collections::HashMap;

fn main() {
    let n: u64 = std::hint::black_box(500_000);
    let mut map: HashMap<u64, u64> = HashMap::new();
    let mut x = 1u64;
    for i in 0..n {
        x = x.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        *map.entry(x >> 44).or_insert(0) += i;
    }
    let mut hits = 0u64;
    let mut sum = 0u64;
    for k in 0..(1u64 << 20) {
        if let Some(v) = map.get(&k) {
            hits += 1;
            sum = sum.wrapping_add(*v);
        }
    }
    let keys = map.len();
    map.retain(|k, _| k % 3 != 0);
    let total: u64 = map.values().fold(0, |a, &v| a.wrapping_add(v));
    let mut words: HashMap<String, usize> = HashMap::new();
    for i in 0..200_000u32 {
        *words.entry(format!("w{}", i % 5003)).or_default() += 1;
    }
    println!("{keys} keys, {hits} hits, sum {sum}, {} left with total {total}, {} words", map.len(), words.len());
}
