//! Island templates (VM → native). See design/stubs.md (Islands).
//!
//! Every island has the signature `unsafe fn(fp: *mut u8, ops: *const u32) -> u32` (Rust ABI).
//! `ops[i]` is a signed frame offset: operand `i` is the slot at `fp + ops[i]`. VM code calls
//! islands directly and ignores the return value (0). Operand conventions (also in design/stubs.md, "Operand conventions"):
//!
//! | Template | `ops[0]` | `ops[1]` | `ops[2]` |
//! |---|---|---|---|
//! | `call` | argument block (`Args`) | destination (`R`) | |
//! | `call_cN` | argument block (`(A0, …)`) | destination (`R`) | fn pointer |
//! | `drop_in_place` | `*mut T` (wide if `T: !Sized`) | | |
//! | intrinsic wrappers | inputs, in order, then the destination | | |

use core::intrinsics;
use core::marker::Tuple;

/// The frame slot of operand `i`: `fp + ops[i]` (`ops[i]` is a signed offset), as a `*mut T`.
///
/// # Safety
/// `ops` must have at least `i + 1` words, and `fp + ops[i]` must be in the frame and aligned
/// for `T`. VM frames are 16-aligned and every slot is aligned to its type relative to `fp`,
/// so this holds for every `T` with `align_of::<T>() <= 16`; functions with more-aligned
/// locals or arguments stay native (design/stubs.md, "Template gaps").
#[inline(always)]
pub unsafe fn slot<T>(fp: *mut u8, ops: *const u32, i: usize) -> *mut T {
    unsafe { fp.offset(*ops.add(i) as i32 as isize).cast::<T>() }
}

/// Direct call of a safe Rust fn or closure type `F` that is a ZST (a `FnDef`, or a closure
/// without captures). `ops`: `[args: Args, dest: R]`.
///
/// Only for callees that implement `FnOnce` and aren't `#[track_caller]` (through `call`,
/// `Location::caller()` would point into `ryo_rt`).
///
/// # Safety
/// The operands must hold an initialized `Args` and room for an `R`.
#[rustc_diagnostic_item = "ryo_island_call"]
pub unsafe fn call<F: FnOnce<Args, Output = R>, Args: Tuple, R>(fp: *mut u8, ops: *const u32) -> u32 {
    const { assert!(size_of::<F>() == 0) };
    // SAFETY: `F` is a ZST and inhabited (a `FnDef` or a capture-less closure), so its one
    // value needs no bytes and `zeroed` produces it.
    let f: F = unsafe { core::mem::zeroed() };
    unsafe {
        let args = slot::<Args>(fp, ops, 0).read();
        slot::<R>(fp, ops, 1).write(f.call_once(args));
    }
    0
}

macro_rules! call_c_families {
    ($($n:literal: $c:ident $c_diag:literal ($($T:ident $a:ident),*);)*) => {$(
        #[doc = concat!("Call of an `unsafe extern \"C\" fn` with ", stringify!($n), " arguments.")]
        /// `ops`: `[args: (A0, …), dest: R, fn pointer]`.
        ///
        /// # Safety
        /// The operands must hold an initialized argument block, room for an `R`, and a fn
        /// pointer that is safe to call with these arguments.
        #[rustc_diagnostic_item = $c_diag]
        pub unsafe fn $c<$($T,)* R>(fp: *mut u8, ops: *const u32) -> u32 {
            unsafe {
                let f = slot::<unsafe extern "C" fn($($T),*) -> R>(fp, ops, 2).read();
                let ($($a,)*) = slot::<($($T,)*)>(fp, ops, 0).read();
                slot::<R>(fp, ops, 1).write(f($($a),*));
            }
            0
        }
    )*};
}

call_c_families! {
    0: call_c0 "ryo_island_call_c0" ();
    1: call_c1 "ryo_island_call_c1" (A0 a0);
    2: call_c2 "ryo_island_call_c2" (A0 a0, A1 a1);
    3: call_c3 "ryo_island_call_c3" (A0 a0, A1 a1, A2 a2);
    4: call_c4 "ryo_island_call_c4" (A0 a0, A1 a1, A2 a2, A3 a3);
    5: call_c5 "ryo_island_call_c5" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4);
    6: call_c6 "ryo_island_call_c6" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5);
    7: call_c7 "ryo_island_call_c7" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6);
    8: call_c8 "ryo_island_call_c8" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7);
    9: call_c9 "ryo_island_call_c9" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8);
    10: call_c10 "ryo_island_call_c10" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9);
    11: call_c11 "ryo_island_call_c11" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10);
    12: call_c12 "ryo_island_call_c12" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11);
    13: call_c13 "ryo_island_call_c13" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11, A12 a12);
    14: call_c14 "ryo_island_call_c14" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11, A12 a12, A13 a13);
    15: call_c15 "ryo_island_call_c15" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11, A12 a12, A13 a13, A14 a14);
    16: call_c16 "ryo_island_call_c16" (A0 a0, A1 a1, A2 a2, A3 a3, A4 a4, A5 a5, A6 a6, A7 a7, A8 a8, A9 a9, A10 a10, A11 a11, A12 a12, A13 a13, A14 a14, A15 a15);
}

/// Drop glue. `ops`: `[ptr: *mut T]`, a wide pointer if `T` is unsized.
///
/// # Safety
/// As for `core::ptr::drop_in_place` on the pointer in the slot.
#[rustc_diagnostic_item = "ryo_island_drop_in_place"]
pub unsafe fn drop_in_place<T: ?Sized>(fp: *mut u8, ops: *const u32) -> u32 {
    unsafe { core::ptr::drop_in_place(slot::<*mut T>(fp, ops, 0).read()) };
    0
}

/// Island for `intrinsics::catch_unwind`. `ops`: `[try_fn, data, catch_fn, dest]`. The fn
/// pointers of VM functions are their portals, so a panic in the VM leaves the portal
/// natively and is caught here (design/lowering.md#unwinding).
///
/// # Safety
/// As for `intrinsics::catch_unwind`, with the operands initialized.
#[rustc_diagnostic_item = "ryo_island_catch_unwind"]
pub unsafe fn catch_unwind<Data>(fp: *mut u8, ops: *const u32) -> u32 {
    unsafe {
        let try_fn = slot::<unsafe fn(*mut Data)>(fp, ops, 0).read();
        let data = slot::<*mut Data>(fp, ops, 1).read();
        let catch_fn = slot::<unsafe fn(*mut Data, *mut u8)>(fp, ops, 2).read();
        let r = intrinsics::catch_unwind(try_fn, data, catch_fn);
        core::ptr::write(slot(fp, ops, 3), r);
    }
    0
}

macro_rules! intrinsic_wrappers {
    ($($name:ident $diag:literal [$($g:ident),*] ($($T:ty),*) -> $R:ty = $f:path;)*) => {$(
        #[doc = concat!("Island for `", stringify!($f), "`. `ops`: the inputs in order, then the destination.")]
        ///
        /// # Safety
        /// The operands must hold initialized inputs and room for the result, and the
        /// intrinsic's own preconditions must hold.
        #[rustc_diagnostic_item = $diag]
        #[allow(unused_assignments)]
        pub unsafe fn $name<$($g),*>(fp: *mut u8, ops: *const u32) -> u32 {
            let mut i = 0;
            let r: $R = unsafe { $f($({ let v = slot::<$T>(fp, ops, i).read(); i += 1; v }),*) };
            unsafe { slot::<$R>(fp, ops, i).write(r) };
            0
        }
    )*};
}

intrinsic_wrappers! {
    sqrtf32 "ryo_island_sqrtf32" [] (f32) -> f32 = intrinsics::sqrtf32;
    sqrtf64 "ryo_island_sqrtf64" [] (f64) -> f64 = intrinsics::sqrtf64;
    powif32 "ryo_island_powif32" [] (f32, i32) -> f32 = intrinsics::powif32;
    powif64 "ryo_island_powif64" [] (f64, i32) -> f64 = intrinsics::powif64;
    fmaf32 "ryo_island_fmaf32" [] (f32, f32, f32) -> f32 = intrinsics::fmaf32;
    fmaf64 "ryo_island_fmaf64" [] (f64, f64, f64) -> f64 = intrinsics::fmaf64;
    compare_bytes "ryo_island_compare_bytes" [] (*const u8, *const u8, usize) -> i32 = intrinsics::compare_bytes;
    raw_eq "ryo_island_raw_eq" [T] (&T, &T) -> bool = intrinsics::raw_eq;
}

// SIMD wrappers: generic exactly like the intrinsic (same generic params, in order), so the
// lowering passes the intrinsic's generic args unchanged. The backend's
// `island::templates::simd` lists the same names with their arities.
intrinsic_wrappers! {
    simd_add "ryo_island_simd_add" [T] (T, T) -> T = intrinsics::simd::simd_add;
    simd_sub "ryo_island_simd_sub" [T] (T, T) -> T = intrinsics::simd::simd_sub;
    simd_mul "ryo_island_simd_mul" [T] (T, T) -> T = intrinsics::simd::simd_mul;
    simd_div "ryo_island_simd_div" [T] (T, T) -> T = intrinsics::simd::simd_div;
    simd_rem "ryo_island_simd_rem" [T] (T, T) -> T = intrinsics::simd::simd_rem;
    simd_shl "ryo_island_simd_shl" [T] (T, T) -> T = intrinsics::simd::simd_shl;
    simd_shr "ryo_island_simd_shr" [T] (T, T) -> T = intrinsics::simd::simd_shr;
    simd_and "ryo_island_simd_and" [T] (T, T) -> T = intrinsics::simd::simd_and;
    simd_or "ryo_island_simd_or" [T] (T, T) -> T = intrinsics::simd::simd_or;
    simd_xor "ryo_island_simd_xor" [T] (T, T) -> T = intrinsics::simd::simd_xor;
    simd_saturating_add "ryo_island_simd_saturating_add" [T] (T, T) -> T = intrinsics::simd::simd_saturating_add;
    simd_saturating_sub "ryo_island_simd_saturating_sub" [T] (T, T) -> T = intrinsics::simd::simd_saturating_sub;
    simd_minimum_number_nsz "ryo_island_simd_minimum_number_nsz" [T] (T, T) -> T = intrinsics::simd::simd_minimum_number_nsz;
    simd_maximum_number_nsz "ryo_island_simd_maximum_number_nsz" [T] (T, T) -> T = intrinsics::simd::simd_maximum_number_nsz;
    simd_neg "ryo_island_simd_neg" [T] (T) -> T = intrinsics::simd::simd_neg;
    simd_fabs "ryo_island_simd_fabs" [T] (T) -> T = intrinsics::simd::simd_fabs;
    simd_bswap "ryo_island_simd_bswap" [T] (T) -> T = intrinsics::simd::simd_bswap;
    simd_bitreverse "ryo_island_simd_bitreverse" [T] (T) -> T = intrinsics::simd::simd_bitreverse;
    simd_ctlz "ryo_island_simd_ctlz" [T] (T) -> T = intrinsics::simd::simd_ctlz;
    simd_ctpop "ryo_island_simd_ctpop" [T] (T) -> T = intrinsics::simd::simd_ctpop;
    simd_cttz "ryo_island_simd_cttz" [T] (T) -> T = intrinsics::simd::simd_cttz;
    simd_ceil "ryo_island_simd_ceil" [T] (T) -> T = intrinsics::simd::simd_ceil;
    simd_floor "ryo_island_simd_floor" [T] (T) -> T = intrinsics::simd::simd_floor;
    simd_round "ryo_island_simd_round" [T] (T) -> T = intrinsics::simd::simd_round;
    simd_round_ties_even "ryo_island_simd_round_ties_even" [T] (T) -> T = intrinsics::simd::simd_round_ties_even;
    simd_trunc "ryo_island_simd_trunc" [T] (T) -> T = intrinsics::simd::simd_trunc;
    simd_fsqrt "ryo_island_simd_fsqrt" [T] (T) -> T = intrinsics::simd::simd_fsqrt;
    simd_fma "ryo_island_simd_fma" [T] (T, T, T) -> T = intrinsics::simd::simd_fma;
    simd_relaxed_fma "ryo_island_simd_relaxed_fma" [T] (T, T, T) -> T = intrinsics::simd::simd_relaxed_fma;
    simd_funnel_shl "ryo_island_simd_funnel_shl" [T] (T, T, T) -> T = intrinsics::simd::simd_funnel_shl;
    simd_funnel_shr "ryo_island_simd_funnel_shr" [T] (T, T, T) -> T = intrinsics::simd::simd_funnel_shr;
    simd_eq "ryo_island_simd_eq" [T, U] (T, T) -> U = intrinsics::simd::simd_eq;
    simd_ne "ryo_island_simd_ne" [T, U] (T, T) -> U = intrinsics::simd::simd_ne;
    simd_lt "ryo_island_simd_lt" [T, U] (T, T) -> U = intrinsics::simd::simd_lt;
    simd_le "ryo_island_simd_le" [T, U] (T, T) -> U = intrinsics::simd::simd_le;
    simd_gt "ryo_island_simd_gt" [T, U] (T, T) -> U = intrinsics::simd::simd_gt;
    simd_ge "ryo_island_simd_ge" [T, U] (T, T) -> U = intrinsics::simd::simd_ge;
    simd_splat "ryo_island_simd_splat" [T, U] (U) -> T = intrinsics::simd::simd_splat;
    simd_cast "ryo_island_simd_cast" [T, U] (T) -> U = intrinsics::simd::simd_cast;
    simd_as "ryo_island_simd_as" [T, U] (T) -> U = intrinsics::simd::simd_as;
    simd_bitmask "ryo_island_simd_bitmask" [T, U] (T) -> U = intrinsics::simd::simd_bitmask;
    simd_reduce_add_unordered "ryo_island_simd_reduce_add_unordered" [T, U] (T) -> U = intrinsics::simd::simd_reduce_add_unordered;
    simd_reduce_mul_unordered "ryo_island_simd_reduce_mul_unordered" [T, U] (T) -> U = intrinsics::simd::simd_reduce_mul_unordered;
    simd_reduce_add_ordered "ryo_island_simd_reduce_add_ordered" [T, U] (T, U) -> U = intrinsics::simd::simd_reduce_add_ordered;
    simd_reduce_mul_ordered "ryo_island_simd_reduce_mul_ordered" [T, U] (T, U) -> U = intrinsics::simd::simd_reduce_mul_ordered;
    simd_reduce_max "ryo_island_simd_reduce_max" [T, U] (T) -> U = intrinsics::simd::simd_reduce_max;
    simd_reduce_min "ryo_island_simd_reduce_min" [T, U] (T) -> U = intrinsics::simd::simd_reduce_min;
    simd_reduce_and "ryo_island_simd_reduce_and" [T, U] (T) -> U = intrinsics::simd::simd_reduce_and;
    simd_reduce_or "ryo_island_simd_reduce_or" [T, U] (T) -> U = intrinsics::simd::simd_reduce_or;
    simd_reduce_xor "ryo_island_simd_reduce_xor" [T, U] (T) -> U = intrinsics::simd::simd_reduce_xor;
    simd_reduce_all "ryo_island_simd_reduce_all" [T] (T) -> bool = intrinsics::simd::simd_reduce_all;
    simd_reduce_any "ryo_island_simd_reduce_any" [T] (T) -> bool = intrinsics::simd::simd_reduce_any;
    simd_select "ryo_island_simd_select" [M, T] (M, T, T) -> T = intrinsics::simd::simd_select;
    simd_select_bitmask "ryo_island_simd_select_bitmask" [M, T] (M, T, T) -> T = intrinsics::simd::simd_select_bitmask;
    simd_arith_offset "ryo_island_simd_arith_offset" [T, U] (T, U) -> T = intrinsics::simd::simd_arith_offset;
    simd_cast_ptr "ryo_island_simd_cast_ptr" [T, U] (T) -> U = intrinsics::simd::simd_cast_ptr;
    simd_expose_provenance "ryo_island_simd_expose_provenance" [T, U] (T) -> U = intrinsics::simd::simd_expose_provenance;
    simd_with_exposed_provenance "ryo_island_simd_with_exposed_provenance" [T, U] (T) -> U = intrinsics::simd::simd_with_exposed_provenance;
}

// 128-bit `mul`, `div`, `rem` and `mul.ovf`: the VM has no such instructions
// (design/vm.md, "Integer arithmetic"), so they are islands, which compile to
// compiler-builtins' `__multi3`, `__udivti3`, … MIR guarantees non-zero divisors and no
// `MIN / -1` (design/lowering.md#binary-operations), hence the unchecked forms.

fn mul128(a: u128, b: u128) -> u128 {
    a.wrapping_mul(b)
}
unsafe fn udiv128(a: u128, b: u128) -> u128 {
    unsafe { intrinsics::unchecked_div(a, b) }
}
unsafe fn sdiv128(a: i128, b: i128) -> i128 {
    unsafe { intrinsics::unchecked_div(a, b) }
}
unsafe fn urem128(a: u128, b: u128) -> u128 {
    unsafe { intrinsics::unchecked_rem(a, b) }
}
unsafe fn srem128(a: i128, b: i128) -> i128 {
    unsafe { intrinsics::unchecked_rem(a, b) }
}
fn umulo128(a: u128, b: u128) -> (u128, bool) {
    a.overflowing_mul(b)
}
fn smulo128(a: i128, b: i128) -> (i128, bool) {
    a.overflowing_mul(b)
}

intrinsic_wrappers! {
    mul_w128 "ryo_island_mul_w128" [] (u128, u128) -> u128 = mul128;
    div_u_w128 "ryo_island_div_u_w128" [] (u128, u128) -> u128 = udiv128;
    div_s_w128 "ryo_island_div_s_w128" [] (i128, i128) -> i128 = sdiv128;
    rem_u_w128 "ryo_island_rem_u_w128" [] (u128, u128) -> u128 = urem128;
    rem_s_w128 "ryo_island_rem_s_w128" [] (i128, i128) -> i128 = srem128;
    mul_ovf_u_w128 "ryo_island_mul_ovf_u_w128" [] (u128, u128) -> (u128, bool) = umulo128;
    mul_ovf_s_w128 "ryo_island_mul_ovf_s_w128" [] (i128, i128) -> (i128, bool) = smulo128;
}

/// A numeric `as` cast the VM has no instruction for (`f16` and `f128`).
pub trait AsCast<T> {
    fn as_cast(self) -> T;
}

macro_rules! as_cast {
    ($($from:ty => $($to:ty),*;)*) => {$($(
        impl AsCast<$to> for $from {
            #[inline(always)]
            fn as_cast(self) -> $to {
                self as $to
            }
        }
    )*)*};
}

as_cast! {
    f16 => i8, i16, i32, i64, i128, u8, u16, u32, u64, u128, isize, usize, f16, f32, f64, f128;
    f128 => i8, i16, i32, i64, i128, u8, u16, u32, u64, u128, isize, usize, f16, f32, f64, f128;
    i8 => f16, f128; i16 => f16, f128; i32 => f16, f128; i64 => f16, f128; i128 => f16, f128;
    u8 => f16, f128; u16 => f16, f128; u32 => f16, f128; u64 => f16, f128; u128 => f16, f128; isize => f16, f128; usize => f16, f128;
    f32 => f16, f128; f64 => f16, f128;
}

/// Island for a numeric `as` cast from `A` to `B` (`f16`/`f128` casts). `ops`: `[src: A, dest: B]`.
///
/// # Safety
/// The operands must hold an initialized `A` and room for a `B`.
#[rustc_diagnostic_item = "ryo_island_as_cast"]
pub unsafe fn as_cast<A: AsCast<B>, B>(fp: *mut u8, ops: *const u32) -> u32 {
    unsafe { slot::<B>(fp, ops, 1).write(slot::<A>(fp, ops, 0).read().as_cast()) };
    0
}
