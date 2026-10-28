pub fn da_work(n: u64) -> u64 { let mut s = 0u64; for i in 0..n { s = s.wrapping_add(i ^ 5); } s }
#[unsafe(no_mangle)] pub extern "C" fn da_run(n: u64) -> u64 { da_work(n) }
