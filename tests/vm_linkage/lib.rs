//! Functions with an interposable `#[linkage]`: the final definition may come from another
//! object, so calls from VM code must go to the symbol, not to the local body.
#![feature(linkage)]

/// Overridden by `main`'s strong definition.
#[linkage = "weak"]
#[unsafe(no_mangle)]
pub fn vml_weak(x: u32) -> u32 {
    x + 1000
}

/// Not overridden.
#[linkage = "weak"]
#[unsafe(no_mangle)]
pub fn vml_weak_kept(x: u32) -> u32 {
    x + 2000
}

#[linkage = "linkonce_odr"]
#[unsafe(no_mangle)]
pub fn vml_linkonce_odr(x: u32) -> u32 {
    x + 3000
}

#[linkage = "weak_odr"]
#[unsafe(no_mangle)]
pub fn vml_weak_odr(x: u32) -> u32 {
    x + 4000
}

pub fn callers(x: u32) -> u32 {
    vml_weak(x) + vml_weak_kept(x) + vml_linkonce_odr(x) + vml_weak_odr(x)
}

pub fn pointers() -> [fn(u32) -> u32; 4] {
    [vml_weak, vml_weak_kept, vml_linkonce_odr, vml_weak_odr]
}
