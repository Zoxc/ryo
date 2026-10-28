// staticlib B: atomics, statics, generics, String/Vec/HashMap, panics caught, threads
use std::sync::atomic::{AtomicU64, Ordering};
use std::collections::HashMap;
static COUNT: AtomicU64 = AtomicU64::new(0);
fn sum<T: Copy + Into<u64>>(v: &[T]) -> u64 { v.iter().map(|&x| x.into()).sum() }
fn work_b(n: u64) -> u64 {
    let mut m = HashMap::new();
    for i in 0..n { *m.entry(i % 7).or_insert(0u64) += i; COUNT.fetch_add(1, Ordering::Relaxed); }
    let v: Vec<u32> = (0..n as u32).collect();
    let r = std::panic::catch_unwind(|| if n == 3 { panic!("x") } else { 1u64 }).unwrap_or(0);
    let t = std::thread::spawn(move || n * 2).join().unwrap();
    m.values().sum::<u64>() + sum(&v) + r + t + format!("{n}").len() as u64
}
#[unsafe(no_mangle)] pub extern "C" fn b_run(n: u64) -> u64 { work_b(n) }
#[unsafe(no_mangle)] pub extern "C" fn b_count() -> u64 { COUNT.load(Ordering::Relaxed) }
