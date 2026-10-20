//! `y bench crates` workload for hashbrown: insert, look up, update and remove with the default
//! hasher, and a set of strings.
use hashbrown::{HashMap, HashSet};

fn main() {
    let key = |i: u64| i.wrapping_mul(0x9e3779b97f4a7c15);
    let mut map: HashMap<u64, u64> = HashMap::new();
    for i in 0..200_000u64 {
        map.insert(key(i), i);
    }
    let mut hits = 0u64;
    for i in 0..400_000u64 {
        if let Some(v) = map.get(&key(i)) {
            hits += v;
        }
    }
    for i in (0..200_000u64).step_by(3) {
        map.remove(&key(i));
    }
    for v in map.values_mut() {
        *v += 1;
    }
    let mut set = HashSet::new();
    for i in 0..50_000u32 {
        set.insert(format!("key-{}", i % 30_000));
    }
    let present = (0..60_000u32).filter(|i| set.contains(&format!("key-{i}"))).count();
    println!("hits {hits}, len {}, sum {}, set {} {present}", map.len(), map.values().sum::<u64>(), set.len());
}
