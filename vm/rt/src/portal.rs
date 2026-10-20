//! Portal templates (native → VM). See design/stubs.md (Portals).
//!
//! `portal::<(A, B), R, ID>` has the ABI of `fn(A, B) -> R`: `rust-call` spreads the tuple, and
//! `Rust`/`RustCall` share `CanonAbi::Rust`. The args tuple is the callee's argument block. The
//! VM takes ownership of the args and writes the return value to `ret`.

use core::marker::Tuple;
use core::mem::{ManuallyDrop, MaybeUninit};
use core::panic::Location;

use crate::unwind::{RawPayload, resume_unwind_from_vm};
#[cfg(not(test))]
use crate::vm::enter;
#[cfg(test)]
use test_hook::enter;

/// Portal for a VM function with ABI arguments `Args` (flattened) and return type `R`. `ID`:
/// crate hash (high 32 bits), function index in that crate's image (low 32 bits).
#[rustc_diagnostic_item = "ryo_portal"]
#[inline(never)]
pub extern "rust-call" fn portal<Args: Tuple, R, const ID: u64>(args: Args) -> R {
    let mut ret = MaybeUninit::<R>::uninit();
    let args = ManuallyDrop::new(args);
    let mut payload = RawPayload::NONE;
    let st = unsafe {
        enter(ID, (&raw const args).cast::<u8>(), ret.as_mut_ptr().cast::<u8>(), &mut payload)
    };
    if st != 0 {
        unsafe { resume_unwind_from_vm(payload) }
    }
    unsafe { ret.assume_init() }
}

macro_rules! portal_tc_family {
    ($($name:ident $diag:literal ($($T:ident $a:ident),*);)*) => {$(
        #[doc = concat!("`#[track_caller]` portal (", stringify!($name), "). The argument block is `(A0, …, &'static Location)`.")]
        #[rustc_diagnostic_item = $diag]
        #[track_caller]
        #[inline(never)]
        pub fn $name<$($T,)* R, const ID: u64>($($a: $T),*) -> R {
            let mut ret = MaybeUninit::<R>::uninit();
            let args = ManuallyDrop::new(($($a,)* Location::caller(),));
            let mut payload = RawPayload::NONE;
            let st = unsafe {
                enter(ID, (&raw const args).cast::<u8>(), ret.as_mut_ptr().cast::<u8>(), &mut payload)
            };
            if st != 0 {
                unsafe { resume_unwind_from_vm(payload) }
            }
            unsafe { ret.assume_init() }
        }
    )*};
}

portal_tc_family! {
    portal_tc0 "ryo_portal_tc0" ();
    portal_tc1 "ryo_portal_tc1" (A0 a0);
    portal_tc2 "ryo_portal_tc2" (A0 a0, A1 a1);
    portal_tc3 "ryo_portal_tc3" (A0 a0, A1 a1, A2 a2);
    portal_tc4 "ryo_portal_tc4" (A0 a0, A1 a1, A2 a2, A3 a3);
    portal_tc5 "ryo_portal_tc5" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4);
    portal_tc6 "ryo_portal_tc6" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5);
    portal_tc7 "ryo_portal_tc7" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6);
    portal_tc8 "ryo_portal_tc8" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7);
    portal_tc9 "ryo_portal_tc9" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8);
    portal_tc10 "ryo_portal_tc10" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9);
    portal_tc11 "ryo_portal_tc11" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10);
    portal_tc12 "ryo_portal_tc12" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11);
    portal_tc13 "ryo_portal_tc13" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11, A12 a12);
    portal_tc14 "ryo_portal_tc14" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11, A12 a12, A13 a13);
    portal_tc15 "ryo_portal_tc15" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11, A12 a12, A13 a13, A14 a14);
    portal_tc16 "ryo_portal_tc16" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11, A12 a12, A13 a13, A14 a14, A15 a15);
}

/// In unit tests, portals call a per-thread hook instead of the VM.
#[cfg(test)]
mod test_hook {
    use crate::unwind::RawPayload;
    use std::cell::Cell;

    pub type Hook = unsafe fn(u64, *const u8, *mut u8, *mut RawPayload) -> u32;

    thread_local! {
        pub static HOOK: Cell<Option<Hook>> = const { Cell::new(None) };
    }

    pub unsafe fn enter(id: u64, args: *const u8, ret: *mut u8, out: *mut RawPayload) -> u32 {
        let hook = HOOK.get().expect("no portal test hook set");
        unsafe { hook(id, args, ret, out) }
    }
}

#[cfg(test)]
mod tests {
    use super::test_hook::HOOK;
    use super::*;
    use crate::unwind::call_catching;
    use std::cell::RefCell;
    use std::panic::{catch_unwind, Location};

    thread_local! {
        static SEEN: RefCell<Vec<(u64, Vec<u64>)>> = const { RefCell::new(Vec::new()) };
    }

    /// Fake VM for `ID`s whose args are `(u64, u64)`: returns their sum as a u64.
    unsafe fn add_vm(id: u64, args: *const u8, ret: *mut u8, _: *mut RawPayload) -> u32 {
        let (a, b) = unsafe { args.cast::<(u64, u64)>().read() };
        SEEN.with_borrow_mut(|s| s.push((id, vec![a, b])));
        unsafe { ret.cast::<u64>().write(a + b) };
        0
    }

    #[test]
    fn portal_enters_and_returns() {
        HOOK.set(Some(add_vm));
        assert_eq!(portal::<(u64, u64), u64, 0x1234_0000_0007>((3, 4)), 7);
        assert_eq!(SEEN.with_borrow(|s| s.last().cloned()), Some((0x1234_0000_0007, vec![3, 4])));
    }

    #[test]
    fn portal_has_the_spread_abi() {
        HOOK.set(Some(add_vm));
        let p: extern "rust-call" fn((u64, u64)) -> u64 = portal::<(u64, u64), u64, 9>;
        // `portal::<(A, B), R, ID>` must be callable as `fn(A, B) -> R`.
        let f: fn(u64, u64) -> u64 = unsafe { core::mem::transmute(p) };
        assert_eq!(f(40, 2), 42);
    }

    /// Args `(String,)`: the VM owns the args, so the portal must not drop them.
    unsafe fn take_string(_: u64, args: *const u8, ret: *mut u8, _: *mut RawPayload) -> u32 {
        let (s,) = unsafe { args.cast::<(String,)>().read() };
        unsafe { ret.cast::<String>().write(s + "!") };
        0
    }

    #[test]
    fn portal_moves_args_to_vm() {
        HOOK.set(Some(take_string));
        assert_eq!(portal::<(String,), String, 1>((String::from("hi"),)), "hi!");
    }

    unsafe fn tc_vm(_: u64, args: *const u8, ret: *mut u8, _: *mut RawPayload) -> u32 {
        let (a, loc) = unsafe { args.cast::<(u32, &'static Location<'static>)>().read() };
        unsafe { ret.cast::<(u32, u32)>().write((a, loc.line())) };
        0
    }

    #[test]
    fn portal_tc_passes_caller_location() {
        HOOK.set(Some(tc_vm));
        let line = line!() + 1;
        let (a, l) = portal_tc1::<u32, (u32, u32), 2>(5);
        assert_eq!((a, l), (5, line));
    }

    unsafe fn panicking_island(_: *mut u8, _: *const u32) -> u32 {
        std::panic::resume_unwind(Box::new(77_i32))
    }

    /// Fake VM that runs a panicking island through `call_catching` and reports unwinding.
    unsafe fn unwinding_vm(_: u64, _: *const u8, _: *mut u8, out: *mut RawPayload) -> u32 {
        let r = unsafe { call_catching(panicking_island, core::ptr::null_mut(), core::ptr::null(), out) };
        assert!(r.unwinding);
        1
    }

    #[test]
    fn portal_resumes_unwinding() {
        HOOK.set(Some(unwinding_vm));
        let err = catch_unwind(|| portal::<(), u8, 3>(())).unwrap_err();
        assert_eq!(err.downcast_ref::<i32>(), Some(&77));
        let err = catch_unwind(|| portal_tc0::<u8, 4>()).unwrap_err();
        assert_eq!(err.downcast_ref::<i32>(), Some(&77));
    }
}
