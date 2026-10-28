pub fn da_work(n: u64) -> u64 { let mut s = 0u64; for i in 0..n { s = s.wrapping_add(i ^ 5); } s }
#[unsafe(no_mangle)] pub extern "C" fn da_run(n: u64) -> u64 { da_work(n) }
// A user module named like the runtime crate: its symbols mention `6ryo_rt` but are the
// dylib's own exports (the export filter drops only the runtime crates' exact symbols).
pub mod ryo_rt { #[inline(never)] pub fn rt_work(n: u64) -> u64 { n.wrapping_mul(3) } }
