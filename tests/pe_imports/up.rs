//! An upstream rlib for `pe_imports.rs` (build/src/test/checks.rs `pe_imports`).
#![feature(extern_item_impls)]
#![allow(incomplete_features)]
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

/// An EII static that `pe_imports.rs` implements: there its symbol is defined (an alias of the
/// implementation), so plain rustc refers to it directly.
#[eii(eii_s)]
pub static EII_S: i32;
