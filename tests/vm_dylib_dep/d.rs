//! A Rust dylib that links the rlib `vda` statically.

pub fn g() -> i32 {
    vda::f(-4) + vda::f(5)
}
