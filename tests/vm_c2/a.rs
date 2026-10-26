//! One of two staticlibs (`vma`, `vmb`) linked into one C program (`main.c`). `answer_a` is
//! a VM function, called through the native `extern "C"` entry point.

fn answer_a() -> i32 {
    40
}

#[unsafe(no_mangle)]
pub extern "C" fn vma_answer() -> i32 {
    answer_a()
}
