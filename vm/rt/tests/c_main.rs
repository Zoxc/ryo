//! `c_main` with a fake `start` and a test-defined `__ryo_main`. In its own test binary,
//! because it defines `__ryo_main`.

use std::ffi::{c_char, c_int};
use std::sync::atomic::{AtomicU8, Ordering};

#[repr(transparent)]
struct FnAddr(#[allow(dead_code)] *const ());
unsafe impl Sync for FnAddr {}

/// Stands in for the image's slot holding the entry fn's portal.
#[unsafe(no_mangle)]
static __ryo_main: FnAddr = FnAddr(fake_main as *const ());

fn fake_main() -> u8 {
    40
}

static SIGPIPE_SEEN: AtomicU8 = AtomicU8::new(0);

/// Stands in for std's `lang_start::<u8>`.
fn fake_start(main: fn() -> u8, argc: isize, argv: *const *const u8, sigpipe: u8) -> isize {
    SIGPIPE_SEEN.store(sigpipe, Ordering::Relaxed);
    assert!(!argv.is_null());
    main() as isize + argc
}

fn c_main_of<S: FnOnce(fn() -> u8, isize, *const *const u8, u8) -> isize>(
    _: S,
) -> extern "C" fn(c_int, *const *const c_char) -> c_int {
    ryo_rt::entry::c_main::<S, u8, 2>
}

#[test]
fn c_main_calls_start_with_main() {
    let argv = [c"prog".as_ptr(), std::ptr::null()];
    assert_eq!(c_main_of(fake_start)(2, argv.as_ptr()), 42);
    assert_eq!(SIGPIPE_SEEN.load(Ordering::Relaxed), 2);
}
