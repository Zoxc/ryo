// staticlib A: plain arithmetic loop
fn work_a(n: u64) -> u64 { let mut s = 0u64; for i in 0..n { s = s.wrapping_add(i * 3 + 1); } s }
#[unsafe(no_mangle)] pub extern "C" fn a_run(n: u64) -> u64 { work_a(n) }
