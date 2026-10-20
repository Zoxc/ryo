//! Built as both an rlib and a dylib; `main` links the rlib, with `-Clto` in the LTO
//! variants, so this crate's image symbols must survive LTO from its rlib metadata.

pub static S: u32 = 3;

#[inline(never)]
fn h(x: u32) -> u32 {
    x * 3 + S
}

#[inline(never)]
pub fn f(x: u32) -> u32 {
    let v: Vec<u32> = (0..x).map(h).collect();
    v.iter().sum()
}
