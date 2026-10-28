// A ryo cdylib, loaded with `dlopen` by `host.rs`: an instance of its own (its own std), whose
// registration no other module can capture (`ryo_vm_register` is internal).
fn work(n: u64) -> u64 {
    (0..n).fold(1u64, |s, i| s.wrapping_mul(31).wrapping_add(i))
}

#[unsafe(no_mangle)]
pub extern "C" fn plugin_run(n: u64) -> u64 {
    work(n)
}
