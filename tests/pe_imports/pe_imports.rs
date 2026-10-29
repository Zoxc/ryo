//! References on PE whose `__imp_` indirection must match plain rustc's (build/src/test/checks.rs
//! `pe_imports`): upstream Rust functions (an rlib's, a shared generic instance, a Rust dylib's)
//! and statics, an upstream EII static implemented here, and foreign statics and functions per
//! `#[link]` kind.

unsafe extern "C" {
    static S_NONE: i32;
    fn f_none() -> i32;
}
#[link(name = "pe_static", kind = "static")]
unsafe extern "C" {
    static S_STATIC: i32;
    fn f_static() -> i32;
}
#[link(name = "pe_dylib", kind = "dylib")]
unsafe extern "C" {
    static S_DYLIB: i32;
    fn f_dylib() -> i32;
}
#[link(name = "pe_unspecified")]
unsafe extern "C" {
    static S_UNSP: i32;
    fn f_unsp() -> i32;
}

#[up::eii_s]
static EII_IMPL: i32 = 7;

#[inline(never)]
pub fn go(x: i32) -> i32 {
    let f: fn(i32) -> i32 = up::up_fn;
    let g: fn(i32) -> i32 = dy::dy_fn;
    let h: unsafe extern "C" fn() -> i32 = f_dylib;
    std::hint::black_box((f, g, h, &up::UP_STATIC as *const i32, &up::EII_S as *const i32));
    let natives = unsafe { S_NONE + S_STATIC + S_DYLIB + S_UNSP + f_none() + f_static() + f_dylib() + f_unsp() };
    up::up_fn(x) + up::up_gen(x as u32) as i32 + dy::dy_fn(x) + natives + up::EII_S
}
