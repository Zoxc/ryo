//! A second rlib (crate `vml2`) with its own copy of `vml::always`, referenced by native code
//! here and in `main.rs`, so both crates' images reference a portal for it.

pub fn always_ptr() -> fn() -> i32 {
    vml::always
}

pub fn own() -> u8 {
    3
}
