//! Exported `#[no_mangle]` functions that VM code calls and takes the address of: the
//! cdylib (and an executable with `-Zexport-executable-symbols`) must export exactly what
//! plain rustc exports (`y test`, check `exports`).

#[unsafe(no_mangle)]
pub extern "C" fn vmc_a() -> i32 {
    42
}

#[inline(never)]
fn helper(n: i32) -> i32 {
    let f: extern "C" fn() -> i32 = vmc_a;
    let mut s = 0;
    for i in 0..n {
        s += vmc_a() + f() + i;
    }
    s
}

#[unsafe(no_mangle)]
pub extern "C" fn vmc_b(n: i32) -> i32 {
    helper(n)
}

#[allow(dead_code)]
fn main() {
    println!("{}", vmc_b(3));
}
