//! `y bench`: HashMap inserts, lookups and removals. SipHash with fixed keys rather than
//! `RandomState`'s random ones: the probe sequences, and so the loop counts that decide what
//! the JIT compiles when, are the same in every run (`y bench codegen`'s dumps, cachegrind).

use std::collections::HashMap;
use std::hash::{BuildHasherDefault, DefaultHasher};

type Map<K, V> = HashMap<K, V, BuildHasherDefault<DefaultHasher>>;

fn main() {
    let n: u64 = std::hint::black_box(330_000);
    let mut map: Map<u64, u64> = Map::default();
    let mut x = 1u64;
    for i in 0..n {
        x = x.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        *map.entry(x >> 44).or_insert(0) += i;
    }
    let mut hits = 0u64;
    let mut sum = 0u64;
    for k in (0..(1u64 << 20)).step_by(2) {
        if let Some(v) = map.get(&k) {
            hits += 1;
            sum = sum.wrapping_add(*v);
        }
    }
    let keys = map.len();
    map.retain(|k, _| k % 3 != 0);
    let total: u64 = map.values().fold(0, |a, &v| a.wrapping_add(v));
    let mut words: Map<String, usize> = Map::default();
    for i in 0..130_000u32 {
        *words.entry(format!("w{}", i % 5003)).or_default() += 1;
    }
    println!("{keys} keys, {hits} hits, sum {sum}, {} left with total {total}, {} words", map.len(), words.len());
}
