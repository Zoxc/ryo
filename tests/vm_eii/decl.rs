//! Externally implementable items (`extern_item_impls`): declarations with and without a
//! default, called from VM code in the declaring crate.
#![feature(extern_item_impls)]
#![allow(incomplete_features)]

/// Overridden by `main`.
#[eii(greet)]
pub fn greet_default(x: u64) -> u64 {
    x + 100
}

/// Not overridden: the default is the implementation.
#[eii(other)]
pub fn other_default(x: u64) -> u64 {
    x + 200
}

/// No default: `main` implements it.
#[eii(need)]
pub fn need(x: u64) -> u64;

pub fn calls(x: u64) -> u64 {
    greet_default(x) * 1000000 + other_default(x) * 1000 + need(x)
}
