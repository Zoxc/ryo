//! A Rust dylib for `pe_imports.rs`; only its metadata is built.
#[inline(never)]
pub fn dy_fn(x: i32) -> i32 {
    x * 3
}
