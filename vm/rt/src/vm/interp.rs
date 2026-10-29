//! The handlers: one `extern "C-unwind"` function `ryo_h_<Opcode>` per opcode
//! (design/vm.md, "Handlers"), which the machine code of VM functions calls: `sysv64`, or on
//! PE Win64.
//!
//! # Structure
//!
//! `handlers.rs` lists every opcode with the *kind* of its handler and the kind's
//! parameters (`AddW32 => bin(u32, wrapping_add);`). Each kind is a macro in this file that
//! expands to the handler body. `handlers!` turns each entry into a handler with the uniform
//! signature `(a0, …, a5: u64) -> R`: the six argument positions (on PE four registers and
//! the stack, of which layouts use five, [`ryo_bytecode::asm::handler_arg`]). A body reads
//! operand `name` from them through the opcode's register layout
//! ([`ryo_bytecode::asm::layout`], a constant), so an unused argument costs nothing and every
//! handler is one function body.
//!
//! The frame pointer `fp` comes in `rdi`, before the operands. With the `fp-rbp` feature, and
//! always on PE, it is `rbp` instead, which the caller (VM code) then keeps at its frame: the
//! handler reads it before anything else, and must not write `rbp` before that (`ryo_rt` is
//! built without forced frame pointers, and `tests/codegen.rs` checks every handler)
//! ([`MODE`]).
//!
//! With the `pe-test` feature (off Windows, for tests) a second set, the PE form's (Win64,
//! [`PE_MODE`]), has no symbols: [`pe_handler`], [`pe_reg_handler`].
//!
//! `resume` ends in a tail jump, so it is written in assembly.
//!
//! # Safety model
//!
//! Images are trusted (design/vm.md): the backend's code is assumed to be well-formed and to
//! follow the frame rules (slots aligned to their types, in the frame, frames 16-aligned).
//! Under that assumption:
//! - Frame slots are read and written with unaligned accesses through `fp + offset` (signed).
//!   Values that may be pointers or uninitialized (moves, loads, stores, copies) are moved as
//!   `MaybeUninit<T>` or bytes, which keeps provenance and allows uninit bytes; arithmetic
//!   reads them as integers, as the program's own semantics do.
//! - Memory operands dereference pointers the program computed. Their validity is the
//!   program's responsibility, exactly as in native code; loads and stores are unaligned
//!   (packed fields), atomics are aligned (the lowering guarantees it).
//! - Nothing in a handler may panic (they aren't expected to unwind). Arithmetic on offsets
//!   is wrapping, indexing is unchecked, and errors go to [`fatal`](super::sys::fatal) (abort).

use core::mem::MaybeUninit;
use core::ops::Not;
use core::ptr;
use core::sync::atomic::{AtomicI8, AtomicI16, AtomicI32, AtomicI64, AtomicPtr, AtomicU8, AtomicU16, AtomicU32, AtomicU64, Ordering};

use ryo_bytecode::asm::{self, ARG_REGS, Loc};
use ryo_bytecode::full::{Opcode, OperandKind};
use ryo_bytecode::jit::effects::RegEntry;

// Apple's targets keep a frame pointer in every function (`frame-pointer=all`, which
// `-Cforce-frame-pointers` can't lower): a handler's prologue would overwrite the caller's
// `rbp` before the handler reads it.
#[cfg(all(feature = "fp-rbp", target_vendor = "apple"))]
compile_error!("the `fp-rbp` feature is unsupported on Apple targets: their functions all set up a frame pointer");

/// How the machine code passes `fp`: the backend reads this (through `FP_ARG`) and encodes
/// to match. The handlers work with and without a frame pointer when they take `fp` in
/// `rdi`; tests encode without one then. On PE (Win64 handlers) `fp` is always `rbp`. The
/// other fields but `pe` don't concern the handlers.
pub const MODE: asm::Mode = asm::Mode {
    fp_arg: !cfg!(feature = "fp-rbp") && !cfg!(windows),
    frame_pointer: cfg!(feature = "fp-rbp") || cfg!(windows),
    align_loops: false,
    pe: cfg!(windows),
    counters: false,
    far_rt: false,
};

/// The mode of the PE handler set (`pe-test`): Win64 handlers that read `fp` from `rbp`.
#[cfg(all(feature = "pe-test", not(windows)))]
pub const PE_MODE: asm::Mode = asm::Mode { fp_arg: false, frame_pointer: true, align_loops: false, pe: true, counters: false, far_rt: false };

/// Whether handlers take `fp` in `rdi`; the backend checks it agrees with its encoding.
#[rustc_diagnostic_item = "ryo_rt_fp_arg"]
pub const FP_ARG: bool = MODE.fp_arg;

/// The location of operand `name` of `op` in the argument registers of `mode`'s handlers.
const fn loc(op: Opcode, name: &str, mode: asm::Mode) -> Loc {
    asm::layout(op, mode).loc(op, name)
}

/// The frame pointer of the calling VM function, for `mode`'s handlers.
#[inline(always)]
fn read_fp(a: &[u64; ARG_REGS], mode: asm::Mode) -> *mut u8 {
    if mode.fp_arg {
        a[0] as usize as *mut u8
    } else {
        let fp: *mut u8;
        // Apple's targets give every function a frame pointer (`frame-pointer=all`), so by
        // now the handler's prologue has pushed the caller's `rbp` and pointed `rbp` at it:
        // read it back from there. (`fp-rbp` is rejected there; this is for the PE handler
        // set of `pe-test`, whose Win64 handlers take `fp` in `rbp`.)
        #[cfg(target_vendor = "apple")]
        // SAFETY: `rbp` points at the saved `rbp` of this handler's frame.
        unsafe {
            core::arch::asm!("mov {}, [rbp]", out(reg) fp, options(readonly, nostack, preserves_flags))
        };
        #[cfg(not(target_vendor = "apple"))]
        // SAFETY: reads a register.
        unsafe {
            core::arch::asm!("mov {}, rbp", out(reg) fp, options(nomem, nostack, preserves_flags))
        };
        fp
    }
}

/// The operand `name` of `$op`: its register value (or the two of a wide operand). `M` is
/// the mode of the handler set being expanded (each set's module defines it).
macro_rules! v {
    ($a:ident, $op:ident, $name:ident) => {
        asm::read(&$a, const { loc(Opcode::$op, stringify!($name), M) })
    };
}

/// The frame slot `fp + off` of the `Slot` operand `name`.
macro_rules! slot {
    ($a:ident, $fp:ident, $op:ident, $name:ident) => {
        $fp.wrapping_offset(v!($a, $op, $name) as u32 as i32 as isize)
    };
}

macro_rules! get {
    ($t:ty, $a:ident, $fp:ident, $op:ident, $name:ident) => {
        slot!($a, $fp, $op, $name).cast::<$t>().read_unaligned()
    };
}

macro_rules! put {
    ($a:ident, $fp:ident, $op:ident, $name:ident, $v:expr) => {
        put_at(slot!($a, $fp, $op, $name), $v)
    };
}

/// The `U32` (or narrower) operand `name`.
macro_rules! word {
    ($a:ident, $op:ident, $name:ident) => {
        v!($a, $op, $name) as u32
    };
}

/// The immediate `name`, as `$t` (the operand has its width).
macro_rules! imm_of {
    ($t:ty, $a:ident, $op:ident, $name:ident) => {
        v!($a, $op, $name) as $t
    };
}

/// The address an address operand (`Const`, `Abs`, `Sym`) holds.
macro_rules! addr_of {
    ($a:ident, $op:ident, $name:ident) => {
        v!($a, $op, $name) as usize as *mut u8
    };
}

/// The address of the memory operand `m`: `[p + k]`.
macro_rules! mem_addr {
    ($a:ident, $fp:ident, $op:ident) => {{
        let m = v!($a, $op, m);
        $fp.wrapping_offset(m as u32 as i32 as isize).cast::<*mut u8>().read_unaligned().wrapping_offset((m >> 64) as u32 as i32 as isize)
    }};
}

// ---- handler bodies ----
//
// Every body macro takes `($a, $fp, $op, params…)`: the argument registers, the frame pointer,
// the opcode's variant name (for the register layout), then the kind's parameters. Its value
// is the handler's return value.

macro_rules! mov {
    ($a:ident, $fp:ident, $op:ident, $t:ty) => {
        put!($a, $fp, $op, d, get!(MaybeUninit<$t>, $a, $fp, $op, s))
    };
}
macro_rules! copy {
    ($a:ident, $fp:ident, $op:ident,) => {
        ptr::copy(slot!($a, $fp, $op, s), slot!($a, $fp, $op, d), word!($a, $op, len) as usize)
    };
}
macro_rules! imm {
    ($a:ident, $fp:ident, $op:ident, $t:ty) => {
        put!($a, $fp, $op, d, imm_of!($t, $a, $op, imm))
    };
}
macro_rules! konst {
    ($a:ident, $fp:ident, $op:ident,) => {
        ptr::copy_nonoverlapping(addr_of!($a, $op, k), slot!($a, $fp, $op, d), word!($a, $op, len) as usize)
    };
}
macro_rules! zero {
    ($a:ident, $fp:ident, $op:ident,) => {
        ptr::write_bytes(slot!($a, $fp, $op, d), 0, word!($a, $op, len) as usize)
    };
}
macro_rules! load {
    ($a:ident, $fp:ident, $op:ident, $t:ty) => {
        put!($a, $fp, $op, d, mem_addr!($a, $fp, $op).cast::<MaybeUninit<$t>>().read_unaligned())
    };
}
macro_rules! store {
    ($a:ident, $fp:ident, $op:ident, $t:ty) => {
        mem_addr!($a, $fp, $op).cast::<MaybeUninit<$t>>().write_unaligned(get!(MaybeUninit<$t>, $a, $fp, $op, s))
    };
}
macro_rules! load_copy {
    ($a:ident, $fp:ident, $op:ident,) => {
        ptr::copy(mem_addr!($a, $fp, $op), slot!($a, $fp, $op, d), word!($a, $op, len) as usize)
    };
}
macro_rules! store_copy {
    ($a:ident, $fp:ident, $op:ident,) => {
        ptr::copy(slot!($a, $fp, $op, s), mem_addr!($a, $fp, $op), word!($a, $op, len) as usize)
    };
}
macro_rules! memcpy {
    ($a:ident, $fp:ident, $op:ident,) => {
        ptr::copy_nonoverlapping(get!(*const u8, $a, $fp, $op, sp), get!(*mut u8, $a, $fp, $op, dp), get!(usize, $a, $fp, $op, n))
    };
}
macro_rules! memmove {
    ($a:ident, $fp:ident, $op:ident,) => {
        ptr::copy(get!(*const u8, $a, $fp, $op, sp), get!(*mut u8, $a, $fp, $op, dp), get!(usize, $a, $fp, $op, n))
    };
}
macro_rules! memset {
    ($a:ident, $fp:ident, $op:ident,) => {
        ptr::write_bytes(get!(*mut u8, $a, $fp, $op, dp), get!(u8, $a, $fp, $op, b), get!(usize, $a, $fp, $op, n))
    };
}
macro_rules! fill {
    ($a:ident, $fp:ident, $op:ident,) => {{
        let k = addr_of!($a, $op, k);
        let es = word!($a, $op, elem_size) as usize;
        let d = slot!($a, $fp, $op, d);
        let n = word!($a, $op, count) as usize;
        if es == 1 {
            ptr::write_bytes(d, k.read(), n);
        } else if n != 0 {
            // One element, then doubling: copy the filled prefix after itself (log2 calls).
            let total = n.wrapping_mul(es);
            ptr::copy_nonoverlapping(k, d, es);
            let mut done = es;
            while done < total {
                let c = total.wrapping_sub(done).min(done);
                ptr::copy_nonoverlapping(d, d.add(done), c);
                done = done.wrapping_add(c);
            }
        }
    }};
}
macro_rules! addr {
    ($a:ident, $fp:ident, $op:ident,) => {
        put!($a, $fp, $op, d, slot!($a, $fp, $op, s))
    };
}
macro_rules! addr_const {
    ($a:ident, $fp:ident, $op:ident,) => {
        put!($a, $fp, $op, d, addr_of!($a, $op, a))
    };
}
macro_rules! addr_sym {
    ($a:ident, $fp:ident, $op:ident, $ind:literal) => {{
        let mut v = *addr_of!($a, $op, sym).cast::<*const ()>();
        if $ind {
            v = *v.cast::<*const ()>();
        }
        put!($a, $fp, $op, d, v)
    }};
}
macro_rules! ptr_add {
    ($a:ident, $fp:ident, $op:ident,) => {
        put!($a, $fp, $op, d, get!(*mut u8, $a, $fp, $op, p).wrapping_offset(imm_of!(i64, $a, $op, imm) as isize))
    };
}
macro_rules! ptr_index {
    ($a:ident, $fp:ident, $op:ident,) => {{
        let p = get!(*mut u8, $a, $fp, $op, p);
        let i = get!(usize, $a, $fp, $op, i);
        put!($a, $fp, $op, d, p.wrapping_add(i.wrapping_mul(word!($a, $op, stride) as usize)))
    }};
}
macro_rules! bin {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m(get!($t, $a, $fp, $op, b)))
    };
}
macro_rules! bin_fn {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $f:ident) => {
        // MIR guarantees a non-zero divisor and no `MIN / -1` (design/instructions.md).
        put!($a, $fp, $op, d, core::intrinsics::$f(get!($t, $a, $fp, $op, a), get!($t, $a, $fp, $op, b)))
    };
}
macro_rules! binop {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $o:tt) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a) $o get!($t, $a, $fp, $op, b))
    };
}
macro_rules! bin_imm {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m(imm_of!($t, $a, $op, imm)))
    };
}
macro_rules! binop_imm {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $o:tt) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a) $o imm_of!($t, $a, $op, imm))
    };
}
macro_rules! shift {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        // `wrapping_sh*` masks the amount to the width.
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m(get!($t, $a, $fp, $op, b) as u32))
    };
}
macro_rules! shift_imm {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m(imm_of!($t, $a, $op, imm) as u32))
    };
}
macro_rules! cmp {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $o:tt) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a) $o get!($t, $a, $fp, $op, b))
    };
}
macro_rules! cmp_imm {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $o:tt) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a) $o imm_of!($t, $a, $op, imm))
    };
}
macro_rules! cmp3 {
    ($a:ident, $fp:ident, $op:ident, $t:ty) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).cmp(&get!($t, $a, $fp, $op, b)) as i8)
    };
}
macro_rules! rot {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m(get!(u32, $a, $fp, $op, b)))
    };
}
macro_rules! count {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m())
    };
}
macro_rules! un {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m())
    };
}
macro_rules! ovf {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {{
        let (v, o) = get!($t, $a, $fp, $op, a).$m(get!($t, $a, $fp, $op, b));
        put!($a, $fp, $op, d, v);
        put!($a, $fp, $op, o, o)
    }};
}
macro_rules! fbin {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $o:tt) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a) $o get!($t, $a, $fp, $op, b))
    };
}
macro_rules! fneg {
    ($a:ident, $fp:ident, $op:ident, $t:ty) => {
        put!($a, $fp, $op, d, -get!($t, $a, $fp, $op, a))
    };
}
macro_rules! fun {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m())
    };
}
macro_rules! fmeth {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $m:ident) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a).$m(get!($t, $a, $fp, $op, b)))
    };
}
macro_rules! fcmp {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $o:tt) => {
        put!($a, $fp, $op, d, get!($t, $a, $fp, $op, a) $o get!($t, $a, $fp, $op, b))
    };
}
macro_rules! vsplat {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $n:literal) => {
        put!($a, $fp, $op, d, [get!($t, $a, $fp, $op, s); $n])
    };
}
macro_rules! vcmp {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $n:literal, $o:tt) => {{
        let (x, y) = (get!([$t; $n], $a, $fp, $op, a), get!([$t; $n], $a, $fp, $op, b));
        // All ones or all zeros per lane (`0 - 1` wraps).
        put!($a, $fp, $op, d, core::array::from_fn::<$t, $n, _>(|i| (0 as $t).wrapping_sub((x[i] $o y[i]) as $t)))
    }};
}
macro_rules! vmsb {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $n:literal) => {{
        // The top bit of each lane, lane `i` at bit `i` (`pmovmskb`); `$n` ≤ 16.
        let x = get!([$t; $n], $a, $fp, $op, a);
        let mut m = 0u16;
        let mut i = 0;
        while i < $n {
            m |= ((x[i] >> (<$t>::BITS - 1)) as u16 & 1) << i;
            i += 1;
        }
        put!($a, $fp, $op, d, m)
    }};
}
macro_rules! cvt {
    ($a:ident, $fp:ident, $op:ident, $x:ty, $y:ty) => {
        // `as`: zero/sign extension, truncation, saturating float → int (NaN → 0), int → float
        // and float → float with Rust semantics.
        put!($a, $fp, $op, d, get!($x, $a, $fp, $op, s) as $y)
    };
}
macro_rules! aload {
    ($a:ident, $fp:ident, $op:ident, $at:ident, $t:ty, $o:ident) => {
        put!($a, $fp, $op, d, $at::from_ptr(get!(*mut $t, $a, $fp, $op, p)).load(Ordering::$o))
    };
}
macro_rules! astore {
    ($a:ident, $fp:ident, $op:ident, $at:ident, $t:ty, $o:ident) => {
        $at::from_ptr(get!(*mut $t, $a, $fp, $op, p)).store(get!($t, $a, $fp, $op, s), Ordering::$o)
    };
}
macro_rules! armw {
    ($a:ident, $fp:ident, $op:ident, $at:ident, $t:ty, $m:ident, $o:ident) => {
        put!($a, $fp, $op, d, $at::from_ptr(get!(*mut $t, $a, $fp, $op, p)).$m(get!($t, $a, $fp, $op, s), Ordering::$o))
    };
}
macro_rules! cxchg {
    ($a:ident, $fp:ident, $op:ident, $at:ident, $t:ty, $m:ident, $os:ident, $of:ident) => {{
        let p = get!(*mut $t, $a, $fp, $op, p);
        let (old, new) = (get!($t, $a, $fp, $op, old), get!($t, $a, $fp, $op, new));
        let (v, ok) = match $at::from_ptr(p).$m(old, new, Ordering::$os, Ordering::$of) {
            Ok(v) => (v, true),
            Err(v) => (v, false),
        };
        put!($a, $fp, $op, d, v);
        put!($a, $fp, $op, o, ok)
    }};
}
// `AtomicPtr`'s: the value is a `*mut u8`, a read-modify-write's operand a `usize`.
macro_rules! aload_ptr {
    ($a:ident, $fp:ident, $op:ident, $o:ident) => {
        put!($a, $fp, $op, d, AtomicPtr::<u8>::from_ptr(get!(*mut *mut u8, $a, $fp, $op, p)).load(Ordering::$o))
    };
}
macro_rules! astore_ptr {
    ($a:ident, $fp:ident, $op:ident, $o:ident) => {
        AtomicPtr::<u8>::from_ptr(get!(*mut *mut u8, $a, $fp, $op, p)).store(get!(*mut u8, $a, $fp, $op, s), Ordering::$o)
    };
}
macro_rules! armw_ptr {
    ($a:ident, $fp:ident, $op:ident, swap, $o:ident) => {
        put!($a, $fp, $op, d, AtomicPtr::<u8>::from_ptr(get!(*mut *mut u8, $a, $fp, $op, p)).swap(get!(*mut u8, $a, $fp, $op, s), Ordering::$o))
    };
    ($a:ident, $fp:ident, $op:ident, $m:ident, $o:ident) => {
        put!($a, $fp, $op, d, AtomicPtr::<u8>::from_ptr(get!(*mut *mut u8, $a, $fp, $op, p)).$m(get!(usize, $a, $fp, $op, s), Ordering::$o))
    };
}
macro_rules! cxchg_ptr {
    ($a:ident, $fp:ident, $op:ident, $m:ident, $os:ident, $of:ident) => {{
        let p = get!(*mut *mut u8, $a, $fp, $op, p);
        let (old, new) = (get!(*mut u8, $a, $fp, $op, old), get!(*mut u8, $a, $fp, $op, new));
        let (v, ok) = match AtomicPtr::<u8>::from_ptr(p).$m(old, new, Ordering::$os, Ordering::$of) {
            Ok(v) => (v, true),
            Err(v) => (v, false),
        };
        put!($a, $fp, $op, d, v);
        put!($a, $fp, $op, o, ok)
    }};
}
macro_rules! fence {
    ($a:ident, $fp:ident, $op:ident, $o:ident) => {
        core::sync::atomic::fence(Ordering::$o)
    };
}
macro_rules! compiler_fence {
    ($a:ident, $fp:ident, $op:ident, $o:ident) => {
        core::sync::atomic::compiler_fence(Ordering::$o)
    };
}
macro_rules! br {
    ($a:ident, $fp:ident, $op:ident,) => {
        get!(u8, $a, $fp, $op, s) != 0
    };
}
macro_rules! br_cmp {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $o:tt) => {
        get!($t, $a, $fp, $op, a) $o get!($t, $a, $fp, $op, b)
    };
}
macro_rules! br_cmp_imm {
    ($a:ident, $fp:ident, $op:ident, $t:ty, $o:tt) => {
        get!($t, $a, $fp, $op, a) $o imm_of!($t, $a, $op, imm)
    };
}
macro_rules! switch_dense {
    ($a:ident, $fp:ident, $op:ident, $t:ty) => {{
        let i = get!($t, $a, $fp, $op, s).wrapping_sub(imm_of!($t, $a, $op, base));
        let n = v!($a, $op, table) as usize;
        if (i as u128) < n as u128 { i as usize } else { n }
    }};
}
macro_rules! switch_sparse {
    ($a:ident, $fp:ident, $op:ident, $t:ty) => {{
        let c = v!($a, $op, cases);
        sparse::<$t>(c as u64 as usize as *const $t, (c >> 64) as usize, get!($t, $a, $fp, $op, s))
    }};
}
macro_rules! abort_now {
    ($a:ident, $fp:ident, $op:ident,) => {
        core::intrinsics::abort()
    };
}
macro_rules! lpad {
    ($a:ident, $fp:ident, $op:ident,) => {
        put!($a, $fp, $op, x, $a[const { asm::layout(Opcode::$op, M).first as usize - 1 }])
    };
}
/// Writes `v` to the slot at `p`.
#[inline(always)]
unsafe fn put_at<T>(p: *mut u8, v: T) {
    // SAFETY: per the caller.
    unsafe { p.cast::<T>().write_unaligned(v) }
}

/// `switch.sparse`: the index of the case equal to `v`, or `n`. Cases are sorted by value
/// (unsigned): a linear scan up to 4, binary search above.
#[inline(always)]
unsafe fn sparse<T: Copy + Ord>(vals: *const T, n: usize, v: T) -> usize {
    // SAFETY: trusted code: `n` values.
    unsafe {
        let at = |i: usize| vals.add(i).read_unaligned();
        if n <= 4 {
            for i in 0..n {
                if at(i) == v {
                    return i;
                }
            }
            return n;
        }
        let (mut lo, mut hi) = (0, n);
        while lo < hi {
            let mid = lo + (hi - lo) / 2;
            match at(mid).cmp(&v) {
                core::cmp::Ordering::Less => lo = mid + 1,
                core::cmp::Ordering::Greater => hi = mid,
                core::cmp::Ordering::Equal => return mid,
            }
        }
        n
    }
}

/// What a register entry returns: `rax`, `rdx` (`RegEntry`): what the entry doesn't return is undefined.
#[repr(C)]
pub struct RegRet(pub MaybeUninit<u64>, pub MaybeUninit<u64>);

/// The return type of a register entry of a handler set: [`RegRet`] (`sysv64`, `Sel<0>`),
/// or for Win64, which returns a 16-byte struct through memory, one value in `rax`
/// (`Sel<1>`) or two in `xmm0`, low and high (`Sel<2>`, `__m128i`).
pub trait RegRetOf {
    type T;
    fn make(a: MaybeUninit<u64>, b: MaybeUninit<u64>) -> Self::T;
}

/// The selector of [`RegRetOf`].
pub struct Sel<const N: usize>;

impl RegRetOf for Sel<0> {
    type T = RegRet;
    #[inline(always)]
    fn make(a: MaybeUninit<u64>, b: MaybeUninit<u64>) -> RegRet {
        RegRet(a, b)
    }
}

impl RegRetOf for Sel<1> {
    type T = MaybeUninit<u64>;
    #[inline(always)]
    fn make(a: MaybeUninit<u64>, _: MaybeUninit<u64>) -> MaybeUninit<u64> {
        a
    }
}

impl RegRetOf for Sel<2> {
    type T = core::arch::x86_64::__m128i;
    #[inline(always)]
    fn make(a: MaybeUninit<u64>, b: MaybeUninit<u64>) -> core::arch::x86_64::__m128i {
        // SAFETY: an entry with two results writes both. In assembly: LLVM merges the words
        // bytewise where a result is a `bool` (a constant mask and three more instructions).
        unsafe {
            let (a, b) = (a.assume_init(), b.assume_init());
            let v: core::arch::x86_64::__m128i;
            core::arch::asm!(
                "movq {v}, {a}",
                "movq {t}, {b}",
                "punpcklqdq {v}, {t}",
                a = in(reg) a,
                b = in(reg) b,
                v = out(xmm_reg) v,
                t = out(xmm_reg) _,
                options(pure, nomem, nostack, preserves_flags),
            );
            v
        }
    }
}

/// [`RegRetOf`]'s selector for `op`'s register entry in `mode`: 0 off PE, else the number
/// of values it returns (one at least).
pub const fn reg_ret_sel(op: Opcode, mode: asm::Mode) -> usize {
    if !mode.pe {
        return 0;
    }
    let e = reg_entry(op, mode);
    if e.nout as usize + e.ret as usize == 2 { 2 } else { 1 }
}

/// The register entry of `op` (`ryo_bytecode::jit::effects::RegEntry`) in `mode`, or `NONE`.
const fn reg_entry(op: Opcode, mode: asm::Mode) -> RegEntry {
    match ryo_bytecode::jit::effects::reg_entry(op, mode) {
        Some(e) => e,
        None => RegEntry::NONE,
    }
}

/// The argument registers a register entry gives the body of `op`, per register the bits
/// it keeps of the entry's data register and the bits it sets: each frame operand's slot
/// offset is its offset in the entry's buffer, `8 * index`.
const fn reg_patch(op: Opcode, mode: asm::Mode) -> [(u64, u64); ARG_REGS] {
    let info = op.info();
    let l = asm::layout(op, mode);
    let mut p = [(0u64, 0u64); ARG_REGS];
    let e = reg_entry(op, mode);
    let mut j = 0;
    while j < e.ndata as usize {
        p[e.data[j] as usize].0 = !0;
        j += 1;
    }
    let mut k = 0;
    while k < info.operands.len() {
        let loc = l.locs[k];
        if loc.count != 0 && matches!(info.operands[k].kind, OperandKind::Slot | OperandKind::Mem) {
            let r = loc.reg as usize;
            let (mask, at) = if loc.shared { (0xffff_ffffu64 << loc.shift, loc.shift) } else { (0xffff_ffff, 0) };
            p[r].0 &= !mask;
            p[r].1 |= (8 * k as u64) << at;
        }
        k += 1;
    }
    p
}

/// A register entry's return value from the body's (`()`, `bool`, `usize`).
macro_rules! reg_ret {
    ($v:ident,) => {{
        let () = $v;
        None::<u64>
    }};
    ($v:ident, $t:tt) => {
        Some($v as u64)
    };
}

/// The register entry of a handler (`RegEntry`), of ABI `$abi`: the body run on a buffer of
/// the frame operands' values, which LLVM keeps in registers. `!` handlers have none.
macro_rules! reg_handler {
    ($abi:literal, $name:ident, $kind:ident, ($($p:tt)*), !) => {};
    ($abi:literal, $name:ident, $kind:ident, ($($p:tt)*), $($ret:tt)?) => {
        // `__m128i` returns in `xmm0` (Win64's `__m128i`).
        #[allow(non_snake_case, unused_variables, unused_unsafe, unused_mut, unused_assignments, clippy::unused_unit, improper_ctypes_definitions)]
        pub unsafe extern $abi fn $name(r0: u64, r1: u64, r2: u64, r3: u64, r4: u64, r5: u64) -> <Sel<{ reg_ret_sel(Opcode::$name, M) }> as RegRetOf>::T {
            const E: RegEntry = reg_entry(Opcode::$name, M);
            const P: [(u64, u64); ARG_REGS] = reg_patch(Opcode::$name, M);
            let r = [r0, r1, r2, r3, r4, r5];
            let mut buf = [0u64; asm::MAX_OPERANDS];
            let mut k = 0;
            while k < E.nin as usize {
                buf[E.ins[k] as usize] = r[k];
                k += 1;
            }
            let mut a = [0u64; ARG_REGS];
            let mut j = 0;
            while j < E.ndata as usize {
                a[E.data[j] as usize] = r[E.nin as usize + j];
                j += 1;
            }
            let mut g = 0;
            while g < ARG_REGS {
                a[g] = a[g] & P[g].0 | P[g].1;
                g += 1;
            }
            let fp = buf.as_mut_ptr().cast::<u8>();
            // SAFETY: see the module docs; the frame operands are `buf`'s words.
            let v = unsafe { $kind!(a, fp, $name, $($p)*) };
            let v = reg_ret!(v, $($ret)?);
            let mut out = [MaybeUninit::<u64>::uninit(); 2];
            let mut n = 0;
            while n < E.nout as usize {
                out[n] = MaybeUninit::new(buf[E.outs[n] as usize]);
                n += 1;
            }
            if let Some(v) = v {
                out[n] = MaybeUninit::new(v);
            }
            <Sel<{ reg_ret_sel(Opcode::$name, M) }> as RegRetOf>::make(out[0], out[1])
        }
    };
}

/// The address of a register entry, if `op` has one.
macro_rules! reg_addr {
    ($m:ident, $hr:ident, $name:ident, !) => {
        None
    };
    ($m:ident, $hr:ident, $name:ident, $($ret:tt)?) => {
        if const { ryo_bytecode::jit::effects::reg_entry(Opcode::$name, $m).is_some() } { Some($hr::$name as *const ()) } else { None }
    };
}

/// Generates the handlers from the handler list. Every opcode with a handler in `full_ops.rs`
/// must have one entry (checked by `HANDLED`, below).
macro_rules! handlers {
    (() $($name:ident => $kind:ident ($($p:tt)*) $(-> $ret:tt)?;)*) => {
        /// The handlers, one per opcode. Others reach them by their `ryo_h_<Opcode>` symbols
        /// or through [`handler`].
        mod h {
            #[allow(unused_imports)]
            use super::*;
            const M: asm::Mode = MODE;
            $(
                #[rustc_std_internal_symbol]
                #[unsafe(export_name = tagged!(concat!(ryo_bytecode::rt_sym!(handler), stringify!($name))))]
                #[allow(non_snake_case, unused_variables, unused_unsafe, clippy::unused_unit)]
                pub unsafe extern "C-unwind" fn $name(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64) $(-> $ret)? {
                    let a = [a0, a1, a2, a3, a4, a5];
                    let fp = read_fp(&a, M);
                    // SAFETY: see the module docs.
                    unsafe { $kind!(a, fp, $name, $($p)*) }
                }
            )*
        }

        /// The register entries (`RegEntry`), for the JIT, which finds them by
        /// [`reg_handler`]'s addresses: they have no symbols (`hr::<Opcode>`; the JIT's dumps
        /// call them `ryo_hr_<Opcode>`).
        mod hr {
            #[allow(unused_imports)]
            use super::*;
            const M: asm::Mode = MODE;
            $(reg_handler!("C-unwind", $name, $kind, ($($p)*), $($ret)?);)*
        }

        /// The PE form's handlers (`pe-test`): Win64, without symbols.
        #[cfg(all(feature = "pe-test", not(windows)))]
        mod hpe {
            #[allow(unused_imports)]
            use super::*;
            const M: asm::Mode = PE_MODE;
            $(
                #[allow(non_snake_case, unused_variables, unused_unsafe, clippy::unused_unit)]
                pub unsafe extern "win64-unwind" fn $name(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64) $(-> $ret)? {
                    let a = [a0, a1, a2, a3, a4, a5];
                    let fp = read_fp(&a, M);
                    // SAFETY: see the module docs.
                    unsafe { $kind!(a, fp, $name, $($p)*) }
                }
            )*
        }

        /// The PE form's register entries (`pe-test`).
        #[cfg(all(feature = "pe-test", not(windows)))]
        mod hrpe {
            #[allow(unused_imports)]
            use super::*;
            const M: asm::Mode = PE_MODE;
            $(reg_handler!("win64-unwind", $name, $kind, ($($p)*), $($ret)?);)*
        }

        /// The PE form's handler of `op` (`pe-test`; tests run PE code off Windows with it).
        #[cfg(all(feature = "pe-test", not(windows)))]
        #[doc(hidden)]
        pub fn pe_handler(op: Opcode) -> Option<*const ()> {
            match op {
                $(Opcode::$name => Some(hpe::$name as *const ()),)*
                Opcode::Resume => Some(resume as *const ()),
                _ => None,
            }
        }

        /// The PE form's register entry of `op` (`pe-test`).
        #[cfg(all(feature = "pe-test", not(windows)))]
        #[doc(hidden)]
        pub fn pe_reg_handler(op: Opcode) -> Option<*const ()> {
            match op {
                $(Opcode::$name => reg_addr!(PE_MODE, hrpe, $name, $($ret)?),)*
                _ => None,
            }
        }

        /// Every opcode with a handler written in Rust, by value.
        const HANDLED: [bool; Opcode::COUNT] = {
            let mut t = [false; Opcode::COUNT];
            $(t[Opcode::$name as usize] = true;)*
            t
        };

        /// The address of opcode `op`'s handler (for the JIT's handler table, and for tests
        /// that call handlers directly).
        #[doc(hidden)]
        pub fn handler(op: Opcode) -> Option<*const ()> {
            match op {
                $(Opcode::$name => Some(h::$name as *const ()),)*
                Opcode::Resume => Some(resume as *const ()),
                _ => None,
            }
        }

        /// The address of opcode `op`'s register entry, if it has one (`RegEntry`).
        #[doc(hidden)]
        pub fn reg_handler(op: Opcode) -> Option<*const ()> {
            match op {
                $(Opcode::$name => reg_addr!(MODE, hr, $name, $($ret)?),)*
                _ => None,
            }
        }
    };
}

include!("handlers.rs");
for_each_handler!(handlers!());

/// The handler of `op` for code of the PE form (`pe`) or the target's: with `pe-test`, the PE
/// set's off Windows (tests that link images by hand).
#[doc(hidden)]
pub fn handler_for(op: Opcode, pe: bool) -> Option<*const ()> {
    #[cfg(all(feature = "pe-test", not(windows)))]
    if pe {
        return pe_handler(op);
    }
    let _ = pe;
    handler(op)
}

// The list has exactly the opcodes with handlers, other than the assembly ones.
const _: () = {
    let mut i = 0;
    while i < Opcode::COUNT {
        let op = ryo_bytecode::ALL_OPCODES[i];
        let asm_written = matches!(op, Opcode::Resume);
        assert!(HANDLED[i] == (asm::has_handler(op) && !asm_written), "the handler list doesn't match full_ops.rs");
        i += 1;
    }
};

/// `resume x`: continues unwinding with the exception object in slot `x`
/// (`_Unwind_Resume`). Jumps, so `_Unwind_Resume` sees the VM function as its caller.
#[cfg(not(windows))]
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(concat!(ryo_bytecode::rt_sym!(handler), "Resume")))]
pub unsafe extern "sysv64-unwind" fn resume() -> ! {
    #[cfg(feature = "fp-rbp")]
    core::arch::naked_asm!(
        ".cfi_startproc",
        "movsxd rdi, edi",
        "mov rdi, [rbp + rdi]",
        "jmp {}",
        ".cfi_endproc",
        sym _Unwind_Resume,
    );
    #[cfg(not(feature = "fp-rbp"))]
    core::arch::naked_asm!(
        ".cfi_startproc",
        "movsxd rsi, esi",
        "mov rdi, [rdi + rsi]",
        "jmp {}",
        ".cfi_endproc",
        sym _Unwind_Resume,
    );
}

#[cfg(not(windows))]
unsafe extern "C-unwind" {
    /// The unwinder's (libgcc_s / libunwind). Only reached from assembly, so `ryo_rt` makes no
    /// unwinding FFI call (which would require `panic=unwind` of every program). `C-unwind`:
    /// LLVM lowers `resume` to calls of this same symbol, and a `nounwind` declaration would
    /// leave those calls out of `ryo_rt`'s own call-site tables.
    fn _Unwind_Resume(exception: *mut u8) -> !;
}

/// `resume x` on PE outside the pad region, which only unreachable cleanup code is (in the
/// region `resume` returns to the trampoline that called the landing pad, design/vm.md#unwinding).
#[cfg(windows)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(concat!(ryo_bytecode::rt_sym!(handler), "Resume")))]
pub unsafe extern "C-unwind" fn resume() -> ! {
    super::sys::fatal("resume: VM unwinding isn't supported on this target")
}

/// The stack probe of frames of 4096 bytes or more: touches every page of the `rax` bytes
/// below the caller's stack pointer, top down, so the guard page is hit in order. Called
/// before `sub rsp, F`; preserves every register but `r11`.
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(ryo_bytecode::rt_sym!(probe)))]
pub unsafe extern "sysv64-unwind" fn probe_stack() {
    // On Windows the guard page's fault is raised here: its unwind info (`push rax` as an
    // 8-byte allocation) lets the dispatcher walk on into the caller, whose prologue is before
    // its `ALLOC` at the call.
    core::arch::naked_asm!(
        cfi!(".cfi_startproc"),
        seh!(".seh_proc {this}"),
        "push rax",
        cfi!(".cfi_adjust_cfa_offset 8"),
        seh!(".seh_stackalloc 8", ".seh_endprologue"),
        "lea r11, [rsp + 16]",
        "2:",
        "sub r11, 4096",
        "test qword ptr [r11], r11",
        "sub rax, 4096",
        "ja 2b",
        "pop rax",
        cfi!(".cfi_adjust_cfa_offset -8"),
        "ret",
        cfi!(".cfi_endproc"),
        seh!(".seh_endproc"),
        #[cfg(windows)]
        this = sym probe_stack,
    );
}
