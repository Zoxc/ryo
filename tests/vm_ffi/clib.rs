//! Stands in for a C static library (`y test` compiles it to an object with plain rustc and
//! archives it): a foreign static, with no Rust symbol dependencies. It has no function, so on
//! PE only the static's own reference pulls the archive member in.
#![no_std]

#[unsafe(no_mangle)]
pub static RYO_C_COUNTER: u32 = 41;

