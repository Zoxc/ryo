//! The instruction semantics: handler bodies (design/vm.md, "Instruction set").
//!
//! `handlers.rs` lists every opcode with the *kind* of its handler and the kind's
//! parameters (`AddW32 => bin(u32, wrapping_add);`). Each kind is a macro in this file that
//! expands to the handler body. There is no dispatcher: the bytecode dispatch loop is gone,
//! and VM code can't run until the bodies become machine-code handlers.
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
//! - Nothing in a handler may panic. Arithmetic on offsets is wrapping, indexing is
//!   unchecked, and errors go to [`fatal`] (abort).

#![allow(unused_macros)]

use super::registry::Function;
use super::sys::fatal;

/// Runs the VM function `f` with the argument block at `args`.
///
/// # Safety
/// Called by `vm::enter` only, with an entry record pushed.
pub unsafe fn run(f: &Function, args: *const u8) {
    let _ = (f, args);
    fatal("VM code can't run: this ryo_rt has no dispatcher")
}

// ---- handler bodies ----
//
// Every body macro takes `($r, $vm, $op, params…)`: the register struct, the `*mut VmThread`,
// the opcode's variant name (for operand offsets and length), then the kind's parameters.

macro_rules! next {
    ($r:ident, $op:ident) => {
        $r.pc = $r.pc.add(const { len(Opcode::$op) })
    };
}

/// The address of a memory operand: `[p + k]` (`mem`) or `[p]` (`deref`).
macro_rules! mem_addr {
    ($r:ident, $op:ident, mem) => {
        get::<*mut u8>(&$r, off::$op::m).wrapping_offset(word(&$r, off::$op::m + 1) as i32 as isize)
    };
    ($r:ident, $op:ident, deref) => {
        get::<*mut u8>(&$r, off::$op::m)
    };
}

macro_rules! mov {
    ($r:ident, $vm:ident, $op:ident, $t:ty) => {{
        put(&$r, off::$op::d, get::<MaybeUninit<$t>>(&$r, off::$op::s));
        next!($r, $op);
    }};
}
macro_rules! copy {
    ($r:ident, $vm:ident, $op:ident,) => {{
        ptr::copy(slot::<u8>(&$r, off::$op::s), slot::<u8>(&$r, off::$op::d), word(&$r, off::$op::len) as usize);
        next!($r, $op);
    }};
}
macro_rules! imm {
    ($r:ident, $vm:ident, $op:ident, $t:ty) => {{
        put(&$r, off::$op::d, imm::<$t>(&$r, off::$op::imm));
        next!($r, $op);
    }};
}
macro_rules! konst {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let k = $r.consts.add(word(&$r, off::$op::k) as usize);
        ptr::copy_nonoverlapping(k, slot::<u8>(&$r, off::$op::d), word(&$r, off::$op::len) as usize);
        next!($r, $op);
    }};
}
macro_rules! zero {
    ($r:ident, $vm:ident, $op:ident,) => {{
        ptr::write_bytes(slot::<u8>(&$r, off::$op::d), 0, word(&$r, off::$op::len) as usize);
        next!($r, $op);
    }};
}
macro_rules! load {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        let a = mem_addr!($r, $op, $m).cast::<MaybeUninit<$t>>();
        put(&$r, off::$op::d, a.read_unaligned());
        next!($r, $op);
    }};
}
macro_rules! store {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        let a = mem_addr!($r, $op, $m).cast::<MaybeUninit<$t>>();
        a.write_unaligned(get::<MaybeUninit<$t>>(&$r, off::$op::s));
        next!($r, $op);
    }};
}
macro_rules! load_copy {
    ($r:ident, $vm:ident, $op:ident, $m:ident) => {{
        let a = mem_addr!($r, $op, $m);
        ptr::copy(a, slot::<u8>(&$r, off::$op::d), word(&$r, off::$op::len) as usize);
        next!($r, $op);
    }};
}
macro_rules! store_copy {
    ($r:ident, $vm:ident, $op:ident, $m:ident) => {{
        let a = mem_addr!($r, $op, $m);
        ptr::copy(slot::<u8>(&$r, off::$op::s), a, word(&$r, off::$op::len) as usize);
        next!($r, $op);
    }};
}
macro_rules! memcpy {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let n = get::<usize>(&$r, off::$op::n);
        ptr::copy_nonoverlapping(get::<*const u8>(&$r, off::$op::sp), get::<*mut u8>(&$r, off::$op::dp), n);
        next!($r, $op);
    }};
}
macro_rules! memmove {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let n = get::<usize>(&$r, off::$op::n);
        ptr::copy(get::<*const u8>(&$r, off::$op::sp), get::<*mut u8>(&$r, off::$op::dp), n);
        next!($r, $op);
    }};
}
macro_rules! memset {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let n = get::<usize>(&$r, off::$op::n);
        ptr::write_bytes(get::<*mut u8>(&$r, off::$op::dp), get::<u8>(&$r, off::$op::b), n);
        next!($r, $op);
    }};
}
macro_rules! fill {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let k = $r.consts.add(word(&$r, off::$op::k) as usize);
        let es = word(&$r, off::$op::elem_size) as usize;
        let d = slot::<u8>(&$r, off::$op::d);
        for i in 0..word(&$r, off::$op::count) as usize {
            ptr::copy_nonoverlapping(k, d.add(i.wrapping_mul(es)), es);
        }
        next!($r, $op);
    }};
}
macro_rules! addr {
    ($r:ident, $vm:ident, $op:ident,) => {{
        put(&$r, off::$op::d, $r.fp.wrapping_add(word(&$r, off::$op::s) as usize));
        next!($r, $op);
    }};
}
macro_rules! addr_sym {
    ($r:ident, $vm:ident, $op:ident, $ind:literal) => {{
        let mut v = *$r.syms.add(word(&$r, off::$op::sym) as usize);
        if $ind {
            v = *v.cast::<*const ()>();
        }
        put(&$r, off::$op::d, v);
        next!($r, $op);
    }};
}
macro_rules! addr_k {
    ($r:ident, $vm:ident, $op:ident,) => {{
        put(&$r, off::$op::d, $r.consts.wrapping_add(word(&$r, off::$op::k) as usize));
        next!($r, $op);
    }};
}
macro_rules! addr_data {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let base = (*(*$vm).img).fixup_area;
        put(&$r, off::$op::d, base.wrapping_add(word(&$r, off::$op::off) as usize));
        next!($r, $op);
    }};
}
macro_rules! ptr_add {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let p = get::<*mut u8>(&$r, off::$op::p);
        put(&$r, off::$op::d, p.wrapping_offset(imm::<i64>(&$r, off::$op::imm) as isize));
        next!($r, $op);
    }};
}
macro_rules! ptr_index {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let p = get::<*mut u8>(&$r, off::$op::p);
        let i = get::<usize>(&$r, off::$op::i);
        put(&$r, off::$op::d, p.wrapping_add(i.wrapping_mul(word(&$r, off::$op::stride) as usize)));
        next!($r, $op);
    }};
}
macro_rules! bin {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, a.$m(b));
        next!($r, $op);
    }};
}
macro_rules! bin_fn {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $f:ident) => {{
        // MIR guarantees a non-zero divisor and no `MIN / -1` (design/vm.md).
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, core::intrinsics::$f(a, b));
        next!($r, $op);
    }};
}
macro_rules! binop {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $o:tt) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, a $o b);
        next!($r, $op);
    }};
}
macro_rules! bin_imm {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), imm::<$t>(&$r, off::$op::imm));
        put(&$r, off::$op::d, a.$m(b));
        next!($r, $op);
    }};
}
macro_rules! binop_imm {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $o:tt) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), imm::<$t>(&$r, off::$op::imm));
        put(&$r, off::$op::d, a $o b);
        next!($r, $op);
    }};
}
macro_rules! shift {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        // `wrapping_sh*` masks the amount to the width.
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, a.$m(b as u32));
        next!($r, $op);
    }};
}
macro_rules! shift_imm {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), imm::<$t>(&$r, off::$op::imm));
        put(&$r, off::$op::d, a.$m(b as u32));
        next!($r, $op);
    }};
}
macro_rules! cmp {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $o:tt) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, a $o b);
        next!($r, $op);
    }};
}
macro_rules! cmp_imm {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $o:tt) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), imm::<$t>(&$r, off::$op::imm));
        put(&$r, off::$op::d, a $o b);
        next!($r, $op);
    }};
}
macro_rules! cmp3 {
    ($r:ident, $vm:ident, $op:ident, $t:ty) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, a.cmp(&b) as i8);
        next!($r, $op);
    }};
}
macro_rules! rot {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<u32>(&$r, off::$op::b));
        put(&$r, off::$op::d, a.$m(b));
        next!($r, $op);
    }};
}
macro_rules! count {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        put::<u32>(&$r, off::$op::d, get::<$t>(&$r, off::$op::a).$m());
        next!($r, $op);
    }};
}
macro_rules! un {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        put::<$t>(&$r, off::$op::d, get::<$t>(&$r, off::$op::a).$m());
        next!($r, $op);
    }};
}
macro_rules! ovf {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        let (v, o) = a.$m(b);
        put(&$r, off::$op::d, v);
        put(&$r, off::$op::o, o);
        next!($r, $op);
    }};
}
macro_rules! fbin {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $o:tt) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, a $o b);
        next!($r, $op);
    }};
}
macro_rules! fneg {
    ($r:ident, $vm:ident, $op:ident, $t:ty) => {{
        put(&$r, off::$op::d, -get::<$t>(&$r, off::$op::a));
        next!($r, $op);
    }};
}
macro_rules! fun {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        put(&$r, off::$op::d, get::<$t>(&$r, off::$op::a).$m());
        next!($r, $op);
    }};
}
macro_rules! fmeth {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $m:ident) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, a.$m(b));
        next!($r, $op);
    }};
}
macro_rules! fcmp {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $o:tt) => {{
        let (a, b) = (get::<$t>(&$r, off::$op::a), get::<$t>(&$r, off::$op::b));
        put(&$r, off::$op::d, a $o b);
        next!($r, $op);
    }};
}
macro_rules! cvt {
    ($r:ident, $vm:ident, $op:ident, $a:ty, $b:ty) => {{
        // `as`: zero/sign extension, truncation, saturating float → int (NaN → 0), int → float
        // and float → float with Rust semantics.
        put(&$r, off::$op::d, get::<$a>(&$r, off::$op::s) as $b);
        next!($r, $op);
    }};
}
macro_rules! discr {
    ($r:ident, $vm:ident, $op:ident, $t:ty) => {{
        // As cg_ssa's niche decoding: `relative = tag - niche_start`; a niche variant iff
        // `relative <= variants_end - variants_start` (inclusive range).
        let tag = get::<$t>(&$r, off::$op::s);
        let rel = tag.wrapping_sub(imm::<$t>(&$r, off::$op::niche_start));
        let vs = word(&$r, off::$op::variants_start);
        let ve = word(&$r, off::$op::variants_end);
        let v = if rel as u128 <= ve.wrapping_sub(vs) as u128 {
            vs.wrapping_add(rel as u32)
        } else {
            word(&$r, off::$op::untagged)
        };
        put::<u32>(&$r, off::$op::d, v);
        next!($r, $op);
    }};
}
macro_rules! set_discr {
    ($r:ident, $vm:ident, $op:ident, $t:ty) => {{
        let v = word(&$r, off::$op::variant);
        if v != word(&$r, off::$op::untagged) {
            let rel = v.wrapping_sub(word(&$r, off::$op::variants_start)) as $t;
            put::<$t>(&$r, off::$op::d, rel.wrapping_add(imm::<$t>(&$r, off::$op::niche_start)));
        }
        next!($r, $op);
    }};
}
macro_rules! aload {
    ($r:ident, $vm:ident, $op:ident, $a:ident, $t:ty, $o:ident) => {{
        let p = get::<*mut $t>(&$r, off::$op::m);
        put(&$r, off::$op::d, $a::from_ptr(p).load(Ordering::$o));
        next!($r, $op);
    }};
}
macro_rules! astore {
    ($r:ident, $vm:ident, $op:ident, $a:ident, $t:ty, $o:ident) => {{
        let p = get::<*mut $t>(&$r, off::$op::m);
        $a::from_ptr(p).store(get::<$t>(&$r, off::$op::s), Ordering::$o);
        next!($r, $op);
    }};
}
macro_rules! armw {
    ($r:ident, $vm:ident, $op:ident, $a:ident, $t:ty, $m:ident, $o:ident) => {{
        let p = get::<*mut $t>(&$r, off::$op::m);
        put(&$r, off::$op::d, $a::from_ptr(p).$m(get::<$t>(&$r, off::$op::s), Ordering::$o));
        next!($r, $op);
    }};
}
macro_rules! cxchg {
    ($r:ident, $vm:ident, $op:ident, $a:ident, $t:ty, $m:ident, $os:ident, $of:ident) => {{
        let p = get::<*mut $t>(&$r, off::$op::m);
        let (old, new) = (get::<$t>(&$r, off::$op::old), get::<$t>(&$r, off::$op::new));
        let (v, ok) = match $a::from_ptr(p).$m(old, new, Ordering::$os, Ordering::$of) {
            Ok(v) => (v, true),
            Err(v) => (v, false),
        };
        put(&$r, off::$op::d, v);
        put(&$r, off::$op::o, ok);
        next!($r, $op);
    }};
}
macro_rules! fence {
    ($r:ident, $vm:ident, $op:ident, $o:ident) => {{
        core::sync::atomic::fence(Ordering::$o);
        next!($r, $op);
    }};
}
macro_rules! compiler_fence {
    ($r:ident, $vm:ident, $op:ident, $o:ident) => {{
        core::sync::atomic::compiler_fence(Ordering::$o);
        next!($r, $op);
    }};
}
macro_rules! jmp {
    ($r:ident, $vm:ident, $op:ident,) => {
        jump(&mut $r, off::$op::t)
    };
}
macro_rules! br_if {
    ($r:ident, $vm:ident, $op:ident, $when:literal) => {
        if (get::<u8>(&$r, off::$op::s) != 0) == $when {
            jump(&mut $r, off::$op::t)
        } else {
            next!($r, $op)
        }
    };
}
macro_rules! br_cmp {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $o:tt) => {
        if get::<$t>(&$r, off::$op::a) $o get::<$t>(&$r, off::$op::b) {
            jump(&mut $r, off::$op::t)
        } else {
            next!($r, $op)
        }
    };
}
macro_rules! br_cmp_imm {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $o:tt) => {
        if get::<$t>(&$r, off::$op::a) $o imm::<$t>(&$r, off::$op::imm) {
            jump(&mut $r, off::$op::t)
        } else {
            next!($r, $op)
        }
    };
}
macro_rules! switch_dense {
    ($r:ident, $vm:ident, $op:ident, $t:ty) => {{
        let i = get::<$t>(&$r, off::$op::s).wrapping_sub(imm::<$t>(&$r, off::$op::base));
        let n = word(&$r, off::$op::table);
        if (i as u128) < n as u128 {
            jump(&mut $r, off::$op::table + 1 + i as usize)
        } else {
            jump(&mut $r, off::$op::default)
        }
    }};
}
macro_rules! switch_sparse {
    ($r:ident, $vm:ident, $op:ident, $t:ty, $case:ident) => {{
        let n = word(&$r, off::$op::cases) as usize;
        let cases = $r.pc.add(off::$op::cases + 1);
        match sparse::<$t>(cases, n, get::<$t>(&$r, off::$op::s)) {
            Some(t) => $r.pc = $r.pc.offset(t as i32 as isize),
            None => jump(&mut $r, off::$op::default),
        }
    }};
}
macro_rules! trap {
    ($r:ident, $vm:ident, $op:ident,) => {
        fatal("entered unreachable code")
    };
}
macro_rules! abort_now {
    ($r:ident, $vm:ident, $op:ident,) => {
        core::intrinsics::abort()
    };
}
macro_rules! call {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let e = &*(*(*$vm).img).fentries.add(word(&$r, off::$op::f) as usize);
        let fs = word(&$r, off::$op::frame_size) as usize;
        let new_fp = (*$vm).top;
        check_stack($vm, new_fp, fs + e.max_outgoing as usize);
        push_header(new_fp, &$r);
        (*$vm).top = new_fp.add(fs);
        $r.fp = new_fp;
        $r.pc = (*$vm).code_lo.add(e.code_off as usize);
    }};
}
/// The native path of a call: on a panic, unwind (or leave `run`), else continue.
macro_rules! native {
    ($r:ident, $vm:ident, $op:ident, $target:expr, $d:expr) => {{
        if call_native($vm, &$r, $target, $d, word(&$r, off::$op::island)) {
            if !unwind($vm, &mut $r, false) {
                return 1;
            }
        } else {
            next!($r, $op);
        }
    }};
}
macro_rules! call_ext {
    ($r:ident, $vm:ident, $op:ident, $ind:literal) => {{
        let mut target = *$r.syms.add(word(&$r, off::$op::sym) as usize);
        if $ind {
            target = *target.cast::<*const ()>();
        }
        let s = site($vm, word(&$r, off::$op::site));
        let mut c = s.load(Ordering::Acquire);
        if c.is_null() {
            c = resolve_ext(target);
            s.store(c, Ordering::Release);
        }
        if c != NATIVE {
            call_function($vm, &mut $r, &*c);
        } else {
            native!($r, $vm, $op, target, word(&$r, off::$op::d));
        }
    }};
}
macro_rules! call_ind {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let target = get::<*const ()>(&$r, off::$op::p);
        match resolve_ind($vm, word(&$r, off::$op::site), target) {
            Some(f) => call_function($vm, &mut $r, f),
            None => native!($r, $vm, $op, target, word(&$r, off::$op::d)),
        }
    }};
}
macro_rules! tail_call {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let e = &*(*(*$vm).img).fentries.add(word(&$r, off::$op::f) as usize);
        let fs = word(&$r, off::$op::frame_size) as usize;
        check_stack($vm, $r.fp, fs + e.max_outgoing as usize);
        ptr::copy((*$vm).top.add(H), $r.fp.add(H), e.arg_size as usize);
        (*$vm).top = $r.fp.add(fs);
        $r.pc = (*$vm).code_lo.add(e.code_off as usize);
    }};
}
macro_rules! tail_call_ind {
    ($r:ident, $vm:ident, $op:ident,) => {{
        let target = get::<*const ()>(&$r, off::$op::p);
        match resolve_ind($vm, word(&$r, off::$op::site), target) {
            Some(f) => tail_call_function($vm, &mut $r, f),
            None => {
                // Not a true tail call: run the island with the result at `fp + H` (the
                // frame is dead, and `frame_size >= H + size_of(R)` since `_0` lives in it),
                // then return it as `ret` would.
                if call_native($vm, &$r, target, H as u32, word(&$r, off::$op::island)) {
                    if !unwind($vm, &mut $r, false) {
                        return 1;
                    }
                } else if {
                    let len = current_ret_size($vm, &$r);
                    do_ret($vm, &mut $r, H as u32, len)
                } {
                    return 0;
                }
            }
        }
    }};
}
macro_rules! ret {
    ($r:ident, $vm:ident, $op:ident,) => {
        if {
            let (s, len) = (word(&$r, off::$op::s), word(&$r, off::$op::len));
            do_ret($vm, &mut $r, s, len)
        } {
            return 0;
        }
    };
}
macro_rules! island {
    ($r:ident, $vm:ident, $op:ident, $catch:literal) => {{
        sys::count(&sys::RUN_STATS.islands);
        let f: IslandFn = core::mem::transmute(*$r.syms.add(word(&$r, off::$op::sym) as usize));
        let n = word(&$r, off::$op::ops) as usize;
        let ops = $r.pc.add(off::$op::ops + 1);
        let tl = off::$op::ops + 1 + n;
        let (succ, unwinding) = if $catch {
            let c = call_catching(f, $r.fp, ops, &raw mut (*(*$vm).entry).payload);
            (c.succ, c.unwinding)
        } else {
            (f($r.fp, ops), false)
        };
        if unwinding {
            if !unwind($vm, &mut $r, false) {
                return 1;
            }
        } else {
            let m = word(&$r, tl);
            if m == 0 {
                $r.pc = $r.pc.add(tl + 1);
            } else if succ < m {
                jump(&mut $r, tl + 1 + succ as usize);
            } else {
                fatal("island returned an out-of-range successor");
            }
        }
    }};
}
macro_rules! resume {
    ($r:ident, $vm:ident, $op:ident,) => {
        if !unwind($vm, &mut $r, true) {
            return 1;
        }
    };
}

/// A superinstruction `first+second` (design/vm.md, "Superinstructions"): `first`'s body,
/// which leaves `pc` at the next instruction, then `second`'s body there. The parts' kinds are
/// repeated here from their own entries; the assertion ties them to `SUPERINSTRUCTIONS`.
macro_rules! fused {
    ($r:ident, $vm:ident, $op:ident, $a:ident: $ka:ident ($($pa:tt)*), $b:ident: $kb:ident ($($pb:tt)*)) => {{
        const {
            assert!(matches!(Opcode::$op.fused_parts(), Some((Opcode::$a, Opcode::$b))));
        }
        $ka!($r, $vm, $a, $($pa)*);
        $kb!($r, $vm, $b, $($pb)*);
    }};
}

include!("handlers.rs");
