// An rlib that both `shost.rs` and the dylib `splugin.rs` link statically: each module has a
// copy of its images, which the merged runtime registers side by side.
#[inline(never)]
pub fn shared_work(n: u64) -> u64 {
    (0..n).fold(0u64, |s, i| s.wrapping_add(i * 3 + 1))
}
