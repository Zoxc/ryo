//! An rlib (crate `vml`) with VM functions, used by `lib2.rs` and `main.rs`.

pub fn answer() -> i32 {
    42
}

/// Instantiated downstream.
pub fn generic<T>() -> u64 {
    7
}

/// Instantiates `generic::<u16>` here: with share-generics, `main` links to this copy (the
/// portal, exported under `generic::<u16>`) instead of making its own.
pub fn generic_u16() -> u64 {
    generic::<u16>()
}

/// `LocalCopy` in every crate that uses it: each copy has a crate-unique symbol.
#[inline(always)]
pub fn always() -> i32 {
    9
}

#[inline]
pub fn inl() -> i32 {
    5
}

/// A VM → VM call inside the rlib.
pub fn calls_answer() -> i32 {
    answer()
}

/// A native function of the rlib calling one of its VM functions.
pub fn native_caller() -> String {
    format!("answer is {}", answer())
}
