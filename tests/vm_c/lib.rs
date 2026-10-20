//! A staticlib / cdylib (crate `vmc`) called from C (`main.c`). `answer` is a VM function;
//! the `extern "C"` entry point stays native and calls it through its portal.

fn answer() -> i32 {
    42
}

#[unsafe(no_mangle)]
pub extern "C" fn vmc_answer() -> i32 {
    answer()
}
