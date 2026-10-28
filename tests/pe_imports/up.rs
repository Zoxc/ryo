//! An upstream rlib for `pe_imports.rs` (build/src/test/checks.rs `pe_imports`).
#[inline(never)]
pub fn up_fn(x: i32) -> i32 {
    x + 1
}

#[inline(never)]
pub fn up_gen<T: Copy>(x: T) -> T {
    x
}

/// Instantiates `up_gen::<u32>` here, for share-generics.
pub fn inst(x: u32) -> u32 {
    up_gen(x)
}

pub static UP_STATIC: i32 = 5;
