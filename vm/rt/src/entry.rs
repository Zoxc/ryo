//! The C `main` wrapper for binaries whose `main` is a VM function. See design/stubs.md
//! (Program entry).

use core::ffi::{c_char, c_int};

unsafe extern "C" {
    /// Defined by the binary crate's image: the address of the entry fn's portal.
    static __ryo_main: *const ();
}

/// The C `main`. `S` is the `FnDef` type of the `start` lang item (std's `lang_start::<T>`),
/// `T` is `main`'s return type, and `SIGPIPE` is `EntryFnType::Main { sigpipe }`.
#[rustc_diagnostic_item = "ryo_c_main"]
pub extern "C" fn c_main<S, T, const SIGPIPE: u8>(argc: c_int, argv: *const *const c_char) -> c_int
where
    S: FnOnce(fn() -> T, isize, *const *const u8, u8) -> isize,
{
    // SAFETY: `__ryo_main` holds the address of a portal with the signature `fn() -> T`.
    let main: fn() -> T = unsafe { core::mem::transmute::<*const (), fn() -> T>(__ryo_main) };
    start_main::<S, T, SIGPIPE>(main, argc, argv)
}

/// The body of [`c_main`], with `main` passed in.
#[inline(always)]
pub fn start_main<S, T, const SIGPIPE: u8>(
    main: fn() -> T,
    argc: c_int,
    argv: *const *const c_char,
) -> c_int
where
    S: FnOnce(fn() -> T, isize, *const *const u8, u8) -> isize,
{
    const { assert!(size_of::<S>() == 0) };
    // SAFETY: `S` is a ZST `FnDef` type, so it has exactly one value, which needs no bytes.
    let start: S = unsafe { core::mem::zeroed() };
    start(main, argc as isize, argv.cast::<*const u8>(), SIGPIPE) as c_int
}
