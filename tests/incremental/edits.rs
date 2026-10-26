//! The rebuild-after-edit program for `y test incremental`: built with `-Cincremental` once
//! per revision `--cfg rev1` .. `--cfg rev9` in order, in one incremental directory, each
//! revision an edit of the previous one (see each `cfg`). Every build's output must equal
//! plain rustc's for that revision, and its executable a clean incremental build's.
//!
//! With `--cfg reuse -Zquery-dep-graph` (crates without VM code, at several codegen units),
//! rustc also checks which codegen units each revision reuses. Each check is under its
//! revision's `cfg_attr`: rustc stops checking at the first one whose `cfg` doesn't match.

#![cfg_attr(reuse, feature(rustc_attrs), allow(internal_features))]
#![cfg_attr(all(reuse, rev2), rustc_partition_reused(module = "edits", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev2), rustc_partition_codegened(module = "edits-a", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev2), rustc_partition_reused(module = "edits-b", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev3), rustc_partition_reused(module = "edits", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev3), rustc_partition_codegened(module = "edits-a", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev3), rustc_partition_reused(module = "edits-b", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev4), rustc_partition_reused(module = "edits", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev4), rustc_partition_codegened(module = "edits-a", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev4), rustc_partition_codegened(module = "edits-b", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev5), rustc_partition_reused(module = "edits", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev5), rustc_partition_codegened(module = "edits-a", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev5), rustc_partition_codegened(module = "edits-b", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev6), rustc_partition_reused(module = "edits", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev6), rustc_partition_codegened(module = "edits-a", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev6), rustc_partition_codegened(module = "edits-b", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev7), rustc_partition_reused(module = "edits", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev7), rustc_partition_codegened(module = "edits-a", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev7), rustc_partition_reused(module = "edits-b", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev8), rustc_partition_reused(module = "edits", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev8), rustc_partition_codegened(module = "edits-a", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev9), rustc_partition_reused(module = "edits", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev9), rustc_partition_codegened(module = "edits-a", cfg = "reuse"))]
#![cfg_attr(all(reuse, rev9), rustc_partition_codegened(module = "edits-b", cfg = "reuse"))]

mod a {
    // rev2: one function body changes.
    #[cfg(not(any(rev2, rev3, rev4, rev5, rev6, rev7, rev8, rev9)))]
    pub fn body(x: u64) -> u64 {
        x * 3 + 1
    }
    #[cfg(any(rev2, rev3, rev4, rev5, rev6, rev7, rev8, rev9))]
    pub fn body(x: u64) -> u64 {
        x * 5 + 2
    }

    // rev3 adds a function, rev5 removes it again.
    #[cfg(any(rev3, rev4))]
    pub fn added(x: u64) -> u64 {
        x.rotate_left(7) ^ 0x5a
    }

    // rev4 moves `moved` from `a` to `b`, rev6 moves it back.
    #[cfg(not(any(rev4, rev5)))]
    pub fn moved(x: u64) -> u64 {
        x.wrapping_mul(0x9e37_79b9)
    }

    // Before rev5 only `a` calls it; from rev5 `b` calls it too.
    pub fn shared(x: u64) -> u64 {
        x.count_ones() as u64 + 10
    }

    // rev6 gives it inline assembly (native-only), rev7 takes it out again.
    #[cfg(not(rev6))]
    pub fn sometimes_native(x: u64) -> u64 {
        x + 100
    }
    #[cfg(rev6)]
    pub fn sometimes_native(mut x: u64) -> u64 {
        unsafe { core::arch::asm!("add {0}, 100", inout(reg) x) };
        x
    }

    // rev7 changes the constant and the static VM code reads.
    #[cfg(not(any(rev7, rev8, rev9)))]
    pub const SCALE: u64 = 7;
    #[cfg(any(rev7, rev8, rev9))]
    pub const SCALE: u64 = 11;
    #[cfg(not(any(rev7, rev8, rev9)))]
    pub static TABLE: [u64; 3] = [1, 2, 3];
    #[cfg(any(rev7, rev8, rev9))]
    pub static TABLE: [u64; 3] = [4, 5, 6];

    // rev8 makes it `#[inline]`, rev9 takes that away.
    #[cfg_attr(rev8, inline)]
    pub fn flip_inline(x: u64) -> u64 {
        x ^ (x >> 3)
    }

    // A generic whose instantiations change: `u64` always, `u32` from rev9.
    pub fn generic<T: Copy + Into<u64>>(xs: &[T]) -> u64 {
        xs.iter().map(|&x| x.into()).sum()
    }

    pub fn run(x: u64) -> u64 {
        let mut r = body(x) + shared(x) + sometimes_native(x) + SCALE * TABLE[x as usize % 3];
        #[cfg(any(rev3, rev4))]
        {
            r += added(x);
        }
        #[cfg(not(any(rev4, rev5)))]
        {
            r += moved(x);
        }
        r += flip_inline(x);
        r + generic(&[x, 1, 2])
    }
}

mod b {
    #[cfg(any(rev4, rev5))]
    pub fn moved(x: u64) -> u64 {
        x.wrapping_mul(0x9e37_79b9)
    }

    pub fn run(x: u64) -> u64 {
        #[allow(unused_mut)]
        let mut r = x + 1;
        #[cfg(any(rev4, rev5))]
        {
            r += moved(x);
        }
        // rev5: the first call from `b` into `a::shared`.
        #[cfg(any(rev5, rev6, rev7, rev8, rev9))]
        {
            r += crate::a::shared(x);
        }
        r += crate::a::flip_inline(x);
        #[cfg(rev9)]
        {
            r += crate::a::generic(&[x as u32, 3]);
        }
        r
    }
}

fn main() {
    let mut total = 0u64;
    for x in 0..20 {
        total = total.wrapping_add(a::run(x)).wrapping_add(b::run(x));
    }
    println!("{total}");
}
