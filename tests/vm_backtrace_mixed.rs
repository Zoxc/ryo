//! Backtraces through stacks that mix VM, native and C frames (design/vm.md#source-locations):
//! each case captures a backtrace (after a `== bt` line) at the bottom of a stack that
//! crosses a boundary: an island (`catch_unwind`), C (`qsort`'s comparator), a function the
//! backend keeps native (`#[link_section]`), and a frame that entered its JIT code by OSR
//! before the call. `argv[1]` picks the case.
use std::backtrace::Backtrace;
use std::hint::black_box;

#[inline(never)]
fn inner() {
    eprintln!("== bt\n{}", Backtrace::force_capture()); // @inner
}

#[inline(never)]
fn through_island() {
    let _ = std::panic::catch_unwind(|| inner()); // @island
}

unsafe extern "C" {
    fn qsort(base: *mut u32, n: usize, size: usize, cmp: extern "C" fn(*const u32, *const u32) -> i32);
}

static mut CAPTURED: bool = false;

extern "C" fn cmp(a: *const u32, b: *const u32) -> i32 {
    unsafe {
        if !CAPTURED {
            CAPTURED = true;
            inner(); // @cmp
        }
        (*a).cmp(&*b) as i32
    }
}

#[inline(never)]
fn through_c() {
    let mut v = [3u32, 1, 2];
    unsafe { qsort(v.as_mut_ptr(), v.len(), 4, cmp) }; // @c
}

/// Native: the backend doesn't lower functions with a `#[link_section]`.
#[unsafe(link_section = ".text.vm_backtrace_mixed")]
#[inline(never)]
fn native(f: fn()) {
    f(); // @native
}

#[inline(never)]
fn mid() {
    inner(); // @mid
}

/// A hot loop (OSR with the JIT on), then the call.
#[inline(never)]
fn osr(n: u64) -> u64 {
    let mut s = 0u64;
    for i in 0..n {
        s = s.wrapping_add(black_box(i));
    }
    mid(); // @osr
    s
}

fn main() {
    let case = std::env::args().nth(1).unwrap_or_default();
    match case.as_str() {
        "island" => through_island(),
        "c" => through_c(),
        "native" => native(mid),
        _ => {
            black_box(osr(black_box(1_000_000)));
        }
    }
    println!("done");
}
