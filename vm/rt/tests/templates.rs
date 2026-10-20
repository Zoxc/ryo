//! Calls the island and unwind templates directly, with fake frames and operand arrays.

#![feature(repr_simd, tuple_trait, unboxed_closures, f16, f128)]
#![allow(internal_features)]

use std::cell::Cell;
use std::panic::{AssertUnwindSafe, Location, catch_unwind};
use std::rc::Rc;

use ryo_rt::island::*;
use ryo_rt::unwind::{CatchResult, RawPayload, call_catching, resume_unwind_from_vm};

/// A fake VM frame: 16-aligned bytes.
#[repr(C, align(16))]
struct Frame([u8; 512]);

impl Frame {
    fn new() -> Box<Frame> {
        Box::new(Frame([0xAA; 512]))
    }
    fn fp(&mut self) -> *mut u8 {
        self.0.as_mut_ptr()
    }
    fn put<T>(&mut self, off: u32, v: T) {
        assert_eq!(off as usize % align_of::<T>(), 0);
        unsafe { self.fp().add(off as usize).cast::<T>().write(v) }
    }
    fn get<T>(&mut self, off: u32) -> T {
        unsafe { self.fp().add(off as usize).cast::<T>().read() }
    }
}

const ARGS: u32 = 16;
const DEST: u32 = 256;
const FNP: u32 = 320;

fn add(a: u64, b: u32) -> u64 {
    a + b as u64
}

#[test]
fn call_fndef() {
    let mut fr = Frame::new();
    fr.put(ARGS, (40_u64, 2_u32));
    let ops = [ARGS, DEST];
    fn ty<F: FnOnce(u64, u32) -> u64>(_: F) -> unsafe fn(*mut u8, *const u32) -> u32 {
        call::<F, (u64, u32), u64>
    }
    let island = ty(add);
    assert_eq!(unsafe { island(fr.fp(), ops.as_ptr()) }, 0);
    assert_eq!(fr.get::<u64>(DEST), 42);
}

#[test]
fn call_closure_and_unit() {
    fn island_of<F: FnOnce<A, Output = R>, A: std::marker::Tuple, R>(
        _: &F,
    ) -> unsafe fn(*mut u8, *const u32) -> u32 {
        call::<F, A, R>
    }
    let mut fr = Frame::new();
    let c = |s: String, n: u8| format!("{s}{n}");
    fr.put(ARGS, (String::from("x"), 7_u8));
    let ops = [ARGS, DEST];
    unsafe { island_of(&c)(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<String>(DEST), "x7");

    // No arguments, unit return.
    let hit = || HIT.set(true);
    thread_local!(static HIT: Cell<bool> = const { Cell::new(false) });
    unsafe { island_of(&hit)(fr.fp(), ops.as_ptr()) };
    assert!(HIT.get());
}

unsafe fn sub3(a: i32, b: i32, c: i32) -> i32 {
    a - b - c
}

#[test]
fn call_ptr() {
    let mut fr = Frame::new();
    fr.put(ARGS, (10_i32, 3_i32, 2_i32));
    fr.put(FNP, sub3 as unsafe fn(i32, i32, i32) -> i32);
    let ops = [ARGS, DEST, FNP];
    assert_eq!(unsafe { call_ptr3::<i32, i32, i32, i32>(fr.fp(), ops.as_ptr()) }, 0);
    assert_eq!(fr.get::<i32>(DEST), 5);

    fn seven() -> u16 {
        7
    }
    fr.put(FNP, seven as unsafe fn() -> u16);
    unsafe { call_ptr0::<u16>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<u16>(DEST), 7);
}

#[track_caller]
fn where_am_i(x: u8) -> (u8, u32, &'static str) {
    let l = Location::caller();
    (x, l.line(), l.file())
}

/// The callee's own `#[track_caller]` symbol, with its implicit location argument explicit.
/// `where_am_i as fn` would be the `ReifyShim`, which has no location argument, so the test
/// builds that signature by hand: a `#[track_caller]` fn's ABI is its signature plus a
/// trailing `&'static Location` (`rustc_ty_utils/src/abi.rs`).
fn explicit_loc(x: u8, l: &'static Location<'static>) -> (u8, u32, &'static str) {
    (x, l.line(), l.file())
}

#[test]
fn call_ptr_track_caller_location() {
    let mut fr = Frame::new();
    let loc: &'static Location<'static> = Location::caller();
    fr.put(ARGS, (9_u8, loc));
    fr.put(FNP, explicit_loc as unsafe fn(u8, &'static Location<'static>) -> (u8, u32, &'static str));
    let ops = [ARGS, DEST, FNP];
    unsafe { call_ptr2::<u8, &'static Location<'static>, (u8, u32, &'static str)>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<(u8, u32, &str)>(DEST), (9, loc.line(), file!()));
    // Sanity: what the real `#[track_caller]` fn sees when called natively.
    assert_eq!(where_am_i(9).2, file!());
}

#[test]
fn call_ptr_17_arity() {
    type T17 = (u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, &'static Location<'static>);
    #[allow(clippy::too_many_arguments)]
    fn f(
        a: u8, b: u8, c: u8, d: u8, e: u8, f: u8, g: u8, h: u8, i: u8, j: u8, k: u8, l: u8,
        m: u8, n: u8, o: u8, p: u8, loc: &'static Location<'static>,
    ) -> u32 {
        [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p].iter().map(|&x| x as u32).sum::<u32>()
            + loc.line()
    }
    let loc = Location::caller();
    let mut fr = Frame::new();
    fr.put::<T17>(ARGS, (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, loc));
    fr.put(FNP, f as unsafe fn(u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, &'static Location<'static>) -> u32);
    let ops = [ARGS, DEST, FNP];
    unsafe {
        call_ptr17::<u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, u8, &'static Location<'static>, u32>(
            fr.fp(),
            ops.as_ptr(),
        )
    };
    assert_eq!(fr.get::<u32>(DEST), 16 + loc.line());
}

extern "C" fn c_mix(a: u8, b: f64, c: *const u64) -> f64 {
    a as f64 + b + unsafe { *c } as f64
}

#[repr(C)]
#[derive(Debug, PartialEq, Clone, Copy)]
struct Big {
    a: u64,
    b: u64,
    c: u64,
}

extern "C" fn c_big(x: Big, k: u64) -> Big {
    Big { a: x.a * k, b: x.b * k, c: x.c * k }
}

#[test]
fn call_c() {
    let mut fr = Frame::new();
    let n = 100_u64;
    fr.put(ARGS, (1_u8, 0.5_f64, &raw const n));
    fr.put(FNP, c_mix as unsafe extern "C" fn(u8, f64, *const u64) -> f64);
    let ops = [ARGS, DEST, FNP];
    unsafe { call_c3::<u8, f64, *const u64, f64>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<f64>(DEST), 101.5);

    // An aggregate passed and returned indirectly.
    fr.put(ARGS, (Big { a: 1, b: 2, c: 3 }, 2_u64));
    fr.put(FNP, c_big as unsafe extern "C" fn(Big, u64) -> Big);
    unsafe { call_c2::<Big, u64, Big>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<Big>(DEST), Big { a: 2, b: 4, c: 6 });
}

#[test]
fn drop_in_place_sized_and_unsized() {
    let rc = Rc::new(());
    let mut fr = Frame::new();
    let ops = [ARGS];

    // Sized: a value living in the frame.
    fr.put(ARGS + 16, Rc::clone(&rc));
    let p = unsafe { fr.fp().add(ARGS as usize + 16) }.cast::<Rc<()>>();
    fr.put(ARGS, p);
    assert_eq!(Rc::strong_count(&rc), 2);
    unsafe { drop_in_place::<Rc<()>>(fr.fp(), ops.as_ptr()) };
    assert_eq!(Rc::strong_count(&rc), 1);

    // Unsized slice: wide pointer in the slot.
    let mut v = std::mem::ManuallyDrop::new(vec![Rc::clone(&rc), Rc::clone(&rc)]);
    let s: *mut [Rc<()>] = &raw mut v[..];
    fr.put(ARGS, s);
    unsafe { drop_in_place::<[Rc<()>]>(fr.fp(), ops.as_ptr()) };
    assert_eq!(Rc::strong_count(&rc), 1);
    unsafe { v.set_len(0) };
    unsafe { std::mem::ManuallyDrop::drop(&mut v) };

    // Unsized trait object.
    let b: Box<dyn std::any::Any> = Box::new(Rc::clone(&rc));
    let d: *mut dyn std::any::Any = Box::into_raw(b);
    fr.put(ARGS, d);
    unsafe { drop_in_place::<dyn std::any::Any>(fr.fp(), ops.as_ptr()) };
    assert_eq!(Rc::strong_count(&rc), 1);
    // Free the allocation without dropping again.
    unsafe { drop(Box::from_raw(d.cast::<std::mem::ManuallyDrop<Rc<()>>>())) };
}

#[repr(simd)]
#[derive(Clone, Copy)]
struct I32x4([i32; 4]);

#[test]
fn intrinsics() {
    let mut fr = Frame::new();
    fr.put(ARGS, 2.0_f64);
    let ops = [ARGS, DEST];
    unsafe { sqrtf64(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<f64>(DEST), 2.0_f64.sqrt());

    fr.put(ARGS, 3.0_f32);
    fr.put(ARGS + 4, 3_i32);
    let ops = [ARGS, ARGS + 4, DEST];
    unsafe { powif32(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<f32>(DEST), 27.0);

    fr.put(ARGS, 2.0_f64);
    fr.put(ARGS + 8, 3.0_f64);
    fr.put(ARGS + 16, 1.0_f64);
    let ops = [ARGS, ARGS + 8, ARGS + 16, DEST];
    unsafe { fmaf64(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<f64>(DEST), 7.0);

    fr.put(ARGS, I32x4([1, 2, 3, 4]));
    fr.put(ARGS + 16, I32x4([10, 20, 30, 40]));
    let ops = [ARGS, ARGS + 16, DEST];
    unsafe { simd_add::<I32x4>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<[i32; 4]>(DEST), [11, 22, 33, 44]);
}

unsafe fn ok_island(_: *mut u8, _: *const u32) -> u32 {
    3
}

unsafe fn panicking_island(_: *mut u8, _: *const u32) -> u32 {
    let n = std::hint::black_box(5);
    panic!("boom {n}")
}

#[test]
fn call_catching_and_resume() {
    let mut payload = RawPayload::NONE;
    let r = unsafe { call_catching(ok_island, std::ptr::null_mut(), std::ptr::null(), &mut payload) };
    assert_eq!(r, CatchResult { succ: 3, unwinding: false });
    assert!(payload.is_none());

    let r = unsafe { call_catching(panicking_island, std::ptr::null_mut(), std::ptr::null(), &mut payload) };
    assert_eq!(r, CatchResult { succ: 0, unwinding: true });
    assert!(!payload.is_none());

    // The panic is still in flight while the VM unwinds (cleanup code sees `panicking()`),
    // until a native catch ends it.
    assert!(std::thread::panicking());
    let err = catch_unwind(AssertUnwindSafe(|| unsafe { resume_unwind_from_vm(payload) })).unwrap_err();
    assert!(!std::thread::panicking());
    assert_eq!(err.downcast_ref::<String>().map(|s| &s[..]), Some("boom 5"));
}

#[test]
fn call_catching_a_call_island() {
    // A native callee that panics, through `call_ptr1` and `call_catching`.
    fn fails(x: u32) -> u32 {
        std::panic::resume_unwind(Box::new(x))
    }
    let mut fr = Frame::new();
    fr.put(ARGS, (11_u32,));
    fr.put(FNP, fails as unsafe fn(u32) -> u32);
    let ops = [ARGS, DEST, FNP];
    let mut payload = RawPayload::NONE;
    let r = unsafe { call_catching(call_ptr1::<u32, u32>, fr.fp(), ops.as_ptr(), &mut payload) };
    assert!(r.unwinding);
    let err = catch_unwind(AssertUnwindSafe(|| unsafe { resume_unwind_from_vm(payload) })).unwrap_err();
    assert_eq!(err.downcast_ref::<u32>(), Some(&11));
}

#[test]
fn abi_version() {
    assert_eq!(ryo_rt::RYO_RT_ABI, 2);
}

thread_local!(static DROPS: Cell<u32> = const { Cell::new(0) });

struct Droppy(#[allow(dead_code)] u32);
impl Drop for Droppy {
    fn drop(&mut self) {
        DROPS.set(DROPS.get() + 1);
    }
}

#[test]
fn call_ptr_drops_args_once() {
    fn consume(_d: Droppy, ok: bool) -> u8 {
        if !ok {
            std::panic::resume_unwind(Box::new("fail"));
        }
        1
    }
    for ok in [true, false] {
        DROPS.set(0);
        let mut fr = Frame::new();
        fr.put(ARGS, (Droppy(1), ok));
        fr.put(FNP, consume as unsafe fn(Droppy, bool) -> u8);
        let ops = [ARGS, DEST, FNP];
        let mut payload = RawPayload::NONE;
        let r = unsafe {
            call_catching(call_ptr2::<Droppy, bool, u8>, fr.fp(), ops.as_ptr(), &mut payload)
        };
        assert_eq!(r.unwinding, !ok);
        assert_eq!(DROPS.get(), 1, "ok = {ok}");
        if !ok {
            let err = catch_unwind(AssertUnwindSafe(|| unsafe { resume_unwind_from_vm(payload) })).unwrap_err();
            assert_eq!(err.downcast_ref::<&str>(), Some(&"fail"));
        }
    }
}

#[test]
fn drop_in_place_unwinds() {
    struct PanicDrop;
    impl Drop for PanicDrop {
        fn drop(&mut self) {
            std::panic::resume_unwind(Box::new(99_u64));
        }
    }
    DROPS.set(0);
    let mut fr = Frame::new();
    // The second field is still dropped while unwinding out of the first one's drop.
    fr.put(ARGS + 16, (PanicDrop, Droppy(0)));
    let p = unsafe { fr.fp().add(ARGS as usize + 16) }.cast::<(PanicDrop, Droppy)>();
    fr.put(ARGS, p);
    let ops = [ARGS];
    let mut payload = RawPayload::NONE;
    let r = unsafe {
        call_catching(drop_in_place::<(PanicDrop, Droppy)>, fr.fp(), ops.as_ptr(), &mut payload)
    };
    assert!(r.unwinding);
    assert_eq!(DROPS.get(), 1);
    let err = catch_unwind(AssertUnwindSafe(|| unsafe { resume_unwind_from_vm(payload) })).unwrap_err();
    assert_eq!(err.downcast_ref::<u64>(), Some(&99));
}

#[test]
fn success_leaves_payload_slot_alone() {
    let marker: Box<dyn std::any::Any + Send> = Box::new(5_u8);
    let before = RawPayload(Box::into_raw(marker));
    let mut payload = before;
    let r = unsafe { call_catching(ok_island, std::ptr::null_mut(), std::ptr::null(), &mut payload) };
    assert!(!r.unwinding);
    assert!(std::ptr::addr_eq(payload.0, before.0));
    drop(unsafe { Box::from_raw(payload.0) });
}

#[test]
fn call_ptr_zst_in_the_middle() {
    use std::marker::PhantomData;
    fn f(a: u8, _: (), b: u64, _: PhantomData<u32>) -> u64 {
        a as u64 * 1000 + b
    }
    let mut fr = Frame::new();
    fr.put::<(u8, (), u64, PhantomData<u32>)>(ARGS, (3, (), 7, PhantomData));
    fr.put(FNP, f as unsafe fn(u8, (), u64, PhantomData<u32>) -> u64);
    let ops = [ARGS, DEST, FNP];
    unsafe { call_ptr4::<u8, (), u64, PhantomData<u32>, u64>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<u64>(DEST), 3007);
}

#[test]
fn call_ptr_and_call_c_128_bit() {
    fn f(a: u128, b: i128) -> i128 {
        a as i128 - b
    }
    extern "C" fn g(a: u8, b: u128, c: i128) -> u128 {
        a as u128 + b + c as u128
    }
    let mut fr = Frame::new();
    let ops = [ARGS, DEST, FNP];
    fr.put::<(u128, i128)>(ARGS, (u128::MAX >> 2, -(1_i128 << 100)));
    fr.put(FNP, f as unsafe fn(u128, i128) -> i128);
    unsafe { call_ptr2::<u128, i128, i128>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<i128>(DEST), (u128::MAX >> 2) as i128 + (1_i128 << 100));

    fr.put::<(u8, u128, i128)>(ARGS, (1, 1 << 90, 1 << 70));
    fr.put(FNP, g as unsafe extern "C" fn(u8, u128, i128) -> u128);
    unsafe { call_c3::<u8, u128, i128, u128>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<u128>(DEST), 1 + (1 << 90) + (1 << 70));
}

#[test]
fn call_c_mixed_floats_and_ints() {
    #[allow(clippy::too_many_arguments)]
    extern "C" fn m(
        a: f32, b: i8, c: f64, d: u64, e: f32, f: i32, g: f64, h: f32, i: u16, j: f64,
    ) -> f64 {
        a as f64 + b as f64 + c + d as f64 + e as f64 + f as f64 + g + h as f64 + i as f64 + j
    }
    type F = unsafe extern "C" fn(f32, i8, f64, u64, f32, i32, f64, f32, u16, f64) -> f64;
    type A = (f32, i8, f64, u64, f32, i32, f64, f32, u16, f64);
    let mut fr = Frame::new();
    fr.put::<A>(ARGS, (0.5, -2, 0.25, 10, 1.5, -100, 1000.0, 0.125, 7, 1e6));
    fr.put(FNP, m as F);
    let ops = [ARGS, DEST, FNP];
    unsafe { call_c10::<f32, i8, f64, u64, f32, i32, f64, f32, u16, f64, f64>(fr.fp(), ops.as_ptr()) };
    let want = 0.5 - 2.0 + 0.25 + 10.0 + 1.5 - 100.0 + 1000.0 + 0.125 + 7.0 + 1e6;
    assert_eq!(fr.get::<f64>(DEST), want);
}

#[test]
fn int128_islands() {
    let mut fr = Frame::new();
    let (a, b) = (ARGS, ARGS + 16);
    let ops = [a, b, DEST];
    fr.put(a, u128::MAX / 3);
    fr.put(b, 12345_u128);
    unsafe { mul_w128(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<u128>(DEST), (u128::MAX / 3).wrapping_mul(12345));
    unsafe { div_u_w128(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<u128>(DEST), u128::MAX / 3 / 12345);
    unsafe { rem_u_w128(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<u128>(DEST), u128::MAX / 3 % 12345);
    unsafe { mul_ovf_u_w128(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<(u128, bool)>(DEST), (u128::MAX / 3).overflowing_mul(12345));

    fr.put(a, -7_i128);
    fr.put(b, 2_i128);
    unsafe { div_s_w128(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<i128>(DEST), -3);
    unsafe { rem_s_w128(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<i128>(DEST), -1);
    fr.put(a, i128::MIN);
    fr.put(b, -1_i128);
    unsafe { mul_ovf_s_w128(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<(i128, bool)>(DEST), (i128::MIN, true));
}

#[test]
fn as_cast_island() {
    let mut fr = Frame::new();
    let ops = [ARGS, DEST];
    fr.put(ARGS, 300.7_f128);
    unsafe { as_cast::<f128, u8>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<u8>(DEST), 255);
    fr.put(ARGS, -2_i32);
    unsafe { as_cast::<i32, f16>(fr.fp(), ops.as_ptr()) };
    assert_eq!(fr.get::<f16>(DEST), -2.0);
}
