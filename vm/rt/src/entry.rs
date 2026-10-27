//! The C `main` wrapper for binaries whose `main` is a VM function. See design/stubs.md
//! (Program entry).

use core::ffi::{c_char, c_int};

unsafe extern "C" {
    /// Defined by the binary crate's image: the address of the entry fn.
    static __ryo_main: *const ();
}

/// The C `main`. `S` is the `FnDef` type of the `start` lang item (std's `lang_start::<T>`),
/// `T` is `main`'s return type, and `SIGPIPE` is `EntryFnType::Main { sigpipe }`.
#[rustc_diagnostic_item = "ryo_c_main"]
pub extern "C" fn c_main<S, T, const SIGPIPE: u8>(argc: c_int, argv: *const *const c_char) -> c_int
where
    S: FnOnce(fn() -> T, isize, *const *const u8, u8) -> isize,
{
    const { assert!(size_of::<S>() == 0) };
    // SAFETY: `__ryo_main` holds the address of a function with the signature `fn() -> T`.
    let main: fn() -> T = unsafe { core::mem::transmute::<*const (), fn() -> T>(__ryo_main) };
    // SAFETY: `S` is a `FnDef` type: a ZST and inhabited, so its one value needs no bytes and
    // `zeroed` produces it.
    let start: S = unsafe { core::mem::zeroed() };
    start(main, argc as isize, argv.cast::<*const u8>(), SIGPIPE) as c_int
}
