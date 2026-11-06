//! An rlib (crate `vmu`) whose `main` is the binary's entry fn (`main.rs`).

/// Instantiated (and lowered) in the binary, which gets its C `main` from cg_ssa, not the
/// backend's entry wrapper: one `main` symbol, not two.
#[inline]
pub fn main() {
    println!("main from vmu");
}
