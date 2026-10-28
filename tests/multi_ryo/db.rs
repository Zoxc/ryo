use std::sync::atomic::{AtomicU64, Ordering};
pub static DB_COUNT: AtomicU64 = AtomicU64::new(0);
pub fn db_work(n: u64) -> u64 { let v: Vec<u64> = (0..n).collect(); DB_COUNT.fetch_add(1, Ordering::Relaxed); v.iter().sum() }
#[unsafe(no_mangle)] pub extern "C" fn db_run(n: u64) -> u64 { db_work(n) }
#[unsafe(no_mangle)] pub extern "C" fn db_count() -> u64 { DB_COUNT.load(Ordering::Relaxed) }
