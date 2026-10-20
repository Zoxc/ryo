//! A Rust dylib (crate `vmd`) with VM functions, registered by its own registry object.

pub fn answer() -> i32 {
    42
}

pub fn generic<T>() -> u64 {
    11
}

pub fn native_caller() -> String {
    format!("answer is {}", answer())
}
