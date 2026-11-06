// A Rust dylib (`-Cprefer-dynamic`, so the host's std) loaded with `dlopen` by `shost.rs`,
// linking its own copy of `shared.rs`: its runtime copy joins the host's.
#[unsafe(no_mangle)]
pub extern "C" fn splugin_run(n: u64) -> u64 {
    shared::shared_work(n) + 1
}
