//! For `y test`'s `cgu-ownership` check (design/backend.md#pipeline, step 4): at 16 codegen
//! units `u::pick::<u64>` (a VM function) calls `b::helper` only in a block that is
//! unreachable after monomorphization. rustc doesn't collect `helper` for it, so neither must
//! ryo (the image must not refer to it); and an item the backend adds to one codegen unit must
//! never be a second copy of a static another unit holds: `b::COUNTER` is defined once.

use std::sync::atomic::{AtomicUsize, Ordering};

mod b {
    use super::*;

    static COUNTER: AtomicUsize = AtomicUsize::new(0);

    pub(crate) fn helper() -> usize {
        COUNTER.fetch_add(1, Ordering::Relaxed) + 1
    }

    pub fn bump() -> usize {
        COUNTER.fetch_add(10, Ordering::Relaxed)
    }
}

mod u {
    #[inline(never)]
    pub fn pick<T>() -> usize {
        if const { size_of::<T>() == 0 } { crate::b::helper() } else { 1 }
    }
}

fn main() {
    println!("{} {}", u::pick::<u64>(), b::bump());
}
