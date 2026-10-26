//! The other staticlib of `main.c` (see `a.rs`).

fn answer_b() -> i32 {
    2
}

#[unsafe(no_mangle)]
pub extern "C" fn vmb_answer() -> i32 {
    answer_b()
}
