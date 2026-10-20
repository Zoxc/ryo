//! The interpreter: handler bodies, the plain `loop { match }` dispatch, calls, returns and
//! unwinding (design/vm.md, "Instruction set", "Unwinding", "Dispatch").
//!
//! # Structure
//!
//! `handlers.rs` lists every opcode with the *kind* of its handler and the kind's
//! parameters (`AddW32 => bin(u32, wrapping_add);`). Each kind is a macro in this file that
//! expands to the handler body. A body reads its operands through the generated offsets
//! (`ryo_bytecode::insn::off::<Opcode>::<operand>`), updates the registers, and leaves `pc` at
//! the next instruction, or `return`s the result of [`run`]. `dispatch!` turns the list into
//! the dispatcher of the strategy chosen by the `ryo_rt` features (`vm/rt/build.rs`):
//! tail-call handlers (default), `#[loop_match]`, or a plain `match` inside a `loop`. They
//! share the bodies, since a body's only exits are "fall through to the next dispatch" and
//! `return`.
//!
//! # Safety model
//!
//! Images are trusted (design/vm.md): the backend's code is assumed to be well-formed
//! (operands in range, targets on instruction starts) and to follow the frame rules (slots
//! aligned to their types, in the frame, frames 16-aligned). Under that assumption:
//! - Frame slots are read and written with unaligned accesses through `fp + offset`, where
//!   `fp` points into this thread's VM stack mapping. Values that may be pointers or
//!   uninitialized (moves, loads, stores, copies) are moved as `MaybeUninit<T>` or bytes, which
//!   keeps provenance and allows uninit bytes; arithmetic reads them as integers, as the
//!   program's own semantics do.
//! - Memory operands dereference pointers the program computed. Their validity is the
//!   program's responsibility, exactly as in native code; loads and stores are unaligned
//!   (packed fields), atomics are aligned (the lowering guarantees it).
//! - Nothing in the dispatch path may panic: a panic would unwind natively through the
//!   handlers. Arithmetic on offsets is wrapping, indexing is unchecked, and errors go to
//!   [`fatal`] (abort).

use core::mem::MaybeUninit;
use core::ops::Not;
use core::ptr;
use core::sync::atomic::{
    AtomicI8, AtomicI16, AtomicI32, AtomicI64, AtomicPtr, AtomicU8, AtomicU16, AtomicU32, AtomicU64, Ordering,
};

use ryo_bytecode::abi::{CALLER_FP_OFFSET, HEADER_SIZE, RETURN_PC_OFFSET};
use ryo_bytecode::image::Cleanup;
use ryo_bytecode::insn::{Opcode, off};

use super::registry::{Function, ImageRt, image_of_pc, lookup_addr};
use super::sys::{self, fatal};
use super::thread::VmThread;
use crate::unwind::call_catching;

/// The island signature (design/stubs.md).
type IslandFn = unsafe fn(*mut u8, *const u32) -> u32;

/// Site cache value for a `call.ext` target that is native code.
pub const NATIVE: *mut Function = ptr::without_provenance_mut(1);

const H: usize = HEADER_SIZE as usize;

/// The hot registers of the dispatch loop. `syms`/`consts` are the current image's, the rest
/// of the image context (image, code bounds) is in [`VmThread`].
pub struct Regs {
    pub pc: *const u32,
    pub fp: *mut u8,
    pub syms: *const *const (),
    pub consts: *const u8,
}

/// Length of a fixed-length opcode, for `const` contexts.
const fn len(op: Opcode) -> usize {
    match op.fixed_len() {
        Some(n) => n,
        None => panic!("variable-length opcode"),
    }
}

/// An integer immediate of the type's width: 1 word up to 32 bits, 2 for 64, 4 for 128.
trait Imm: Copy {
    /// # Safety
    /// `p` must point at the immediate's words.
    unsafe fn imm(p: *const u32) -> Self;
}

macro_rules! imm_impl {
    ($($t:ty: $n:literal),*) => {$(
        impl Imm for $t {
            #[inline(always)]
            unsafe fn imm(p: *const u32) -> Self {
                // SAFETY: per the caller, `$n` words are readable.
                let w = unsafe { p.cast::<[u32; $n]>().read_unaligned() };
                let mut v = 0u128;
                let mut i = 0;
                while i < $n {
                    v |= (w[i] as u128) << (32 * i);
                    i += 1;
                }
                v as $t
            }
        }
    )*};
}
imm_impl!(u8: 1, u16: 1, u32: 1, u64: 2, u128: 4, i8: 1, i16: 1, i32: 1, i64: 2, i128: 4);

/// Operand word `i` of the instruction at `r.pc`.
#[inline(always)]
unsafe fn word(r: &Regs, i: usize) -> u32 {
    // SAFETY: trusted code: the instruction has that many words.
    unsafe { *r.pc.add(i) }
}

/// The frame slot whose offset is operand word `i`.
#[inline(always)]
unsafe fn slot<T>(r: &Regs, i: usize) -> *mut T {
    // SAFETY: trusted code: the offset is within the current frame.
    unsafe { r.fp.add(word(r, i) as usize).cast() }
}

#[inline(always)]
unsafe fn get<T>(r: &Regs, i: usize) -> T {
    // SAFETY: see the module docs.
    unsafe { slot::<T>(r, i).read_unaligned() }
}

#[inline(always)]
unsafe fn put<T>(r: &Regs, i: usize, v: T) {
    // SAFETY: see the module docs.
    unsafe { slot::<T>(r, i).write_unaligned(v) }
}

#[inline(always)]
unsafe fn imm<T: Imm>(r: &Regs, i: usize) -> T {
    // SAFETY: trusted code.
    unsafe { T::imm(r.pc.add(i)) }
}

#[inline(always)]
unsafe fn jump(r: &mut Regs, i: usize) {
    // SAFETY: trusted code: the target is an instruction in this function.
    unsafe { r.pc = r.pc.offset(word(r, i) as i32 as isize) }
}

#[cold]
#[inline(never)]
fn stack_overflow() -> ! {
    fatal("stack overflow in VM code")
}

/// Checks that a frame at `new_fp` using `need` bytes (frame size plus `max_outgoing`) fits.
#[inline(always)]
pub unsafe fn check_stack(vm: *mut VmThread, new_fp: *mut u8, need: usize) {
    // SAFETY: `vm` is this thread's state.
    if (new_fp as usize).wrapping_add(need) > unsafe { (*vm).limit } as usize {
        stack_overflow()
    }
}

/// Makes `img` the current image (VmThread side of the image context).
#[inline(always)]
pub unsafe fn set_image(vm: *mut VmThread, img: *const ImageRt) {
    // SAFETY: `vm` is this thread's state; `img` is a registered image or null.
    unsafe {
        (*vm).img = img;
        match img.as_ref() {
            Some(i) => {
                (*vm).code_lo = i.code;
                (*vm).code_hi = i.code_end;
            }
            None => {
                (*vm).code_lo = ptr::null();
                (*vm).code_hi = ptr::null();
            }
        }
    }
}

/// Switches the whole image context (VmThread and registers) to `img`.
#[cold]
#[inline(never)]
unsafe fn load_image(vm: *mut VmThread, r: &mut Regs, img: &ImageRt) {
    // SAFETY: per `set_image`.
    unsafe { set_image(vm, img) };
    r.syms = img.syms;
    r.consts = img.consts;
}

/// Pushes a frame for the VM function `f` (arguments already in the outgoing block) and
/// continues at its first instruction.
#[inline(always)]
unsafe fn call_function(vm: *mut VmThread, r: &mut Regs, f: &Function) {
    // SAFETY: `vm` is this thread's state; the new frame starts at the current top, which is
    // in the stack mapping, and `check_stack` keeps it below the limit.
    unsafe {
        let new_fp = (*vm).top;
        check_stack(vm, new_fp, f.frame_size as usize + f.max_outgoing as usize);
        push_header(new_fp, r);
        (*vm).top = new_fp.add(f.frame_size as usize);
        r.fp = new_fp;
        r.pc = f.code;
        if !ptr::eq(f.img, (*vm).img) {
            load_image(vm, r, &*f.img);
        }
    }
}

#[inline(always)]
unsafe fn push_header(new_fp: *mut u8, r: &Regs) {
    // SAFETY: the header is the first 16 bytes of a checked frame; `fp` is 16-aligned.
    unsafe {
        new_fp.add(CALLER_FP_OFFSET as usize).cast::<*mut u8>().write(r.fp);
        new_fp.add(RETURN_PC_OFFSET as usize).cast::<*const u32>().write(r.pc);
    }
}

/// Replaces the current frame with one for `f`: moves the staged arguments from the outgoing
/// block down to `fp + H` and keeps the header (design/vm.md, `tail_call`).
#[inline(always)]
unsafe fn tail_call_function(vm: *mut VmThread, r: &mut Regs, f: &Function) {
    // SAFETY: as for `call_function`; source and destination are within the stack mapping
    // (the outgoing block is covered by the caller's `max_outgoing`), and may overlap.
    unsafe {
        check_stack(vm, r.fp, f.frame_size as usize + f.max_outgoing as usize);
        ptr::copy((*vm).top.add(H), r.fp.add(H), f.arg_size as usize);
        (*vm).top = r.fp.add(f.frame_size as usize);
        r.pc = f.code;
        if !ptr::eq(f.img, (*vm).img) {
            load_image(vm, r, &*f.img);
        }
    }
}

/// Calls native code at `target` through the `call_ptrN` island `island` (a symbol index):
/// writes the fn pointer into the callee header area at the current top, and passes
/// `ops = [top + H, d, top]` (offsets from `fp`). Returns true if the callee panicked (the
/// payload is in the innermost entry record).
#[inline(never)]
unsafe fn call_native(vm: *mut VmThread, r: &Regs, target: *const (), d: u32, island: u32) -> bool {
    sys::count(&sys::RUN_STATS.native_calls);
    // SAFETY: the top is 16-aligned and the caller's `max_outgoing` covers its header area and
    // outgoing block. The island symbol is a `call_ptrN` instance. `entry` is non-null while
    // `run` runs.
    unsafe {
        let top = (*vm).top;
        let fo = (top as usize).wrapping_sub(r.fp as usize) as u32;
        top.cast::<*const ()>().write(target);
        let ops = [fo.wrapping_add(H as u32), d, fo];
        let f: IslandFn = core::mem::transmute(*r.syms.add(island as usize));
        call_catching(f, r.fp, ops.as_ptr(), &raw mut (*(*vm).entry).payload).unwinding
    }
}

/// Resolves a `call.ext` site: the symbol's address, then the registry.
#[cold]
#[inline(never)]
unsafe fn resolve_ext(target: *const ()) -> *mut Function {
    match lookup_addr(target) {
        Some(f) => (f as *const Function).cast_mut(),
        None => NATIVE,
    }
}

/// The site cache slot `site` of the current image.
#[inline(always)]
unsafe fn site(vm: *mut VmThread, site: u32) -> &'static AtomicPtr<Function> {
    // SAFETY: trusted code: `site < site_count`; the cache lives as long as the image.
    unsafe { &*(*(*vm).img).sites.add(site as usize) }
}

/// The VM function an indirect call to `target` reaches, if any, using and updating the
/// site cache (design/vm.md, "the site cache").
#[inline(always)]
unsafe fn resolve_ind(vm: *mut VmThread, site_idx: u32, target: *const ()) -> Option<&'static Function> {
    // SAFETY: a cached value is null, a tagged native address (low bit set, never
    // dereferenced), or a function record published with Release by the store below, after
    // its own publication (Acquire here makes the record's contents visible).
    unsafe {
        let s = site(vm, site_idx);
        let c = s.load(Ordering::Acquire);
        if c.addr() & 1 != 0 {
            if c == native_tag(target) {
                return None;
            }
        } else if let Some(f) = c.as_ref()
            && ptr::eq(f.portal, target)
        {
            return Some(f);
        }
        resolve_ind_slow(s, target)
    }
}

/// The `call.ind` site cache value for a native target: `addr << 1 | 1`. Function records are
/// 8-aligned, so the low bit tells the two apart; user-space addresses on x86_64 are below
/// 2^47, so the shift loses nothing.
#[inline(always)]
fn native_tag(target: *const ()) -> *mut Function {
    ptr::without_provenance_mut(target.addr() << 1 | 1)
}

#[cold]
#[inline(never)]
fn resolve_ind_slow(s: &AtomicPtr<Function>, target: *const ()) -> Option<&'static Function> {
    match lookup_addr(target) {
        Some(f) => {
            s.store((f as *const Function).cast_mut(), Ordering::Release);
            Some(f)
        }
        None => {
            s.store(native_tag(target), Ordering::Relaxed);
            None
        }
    }
}

// `do_ret` reads the destination of every call opcode at `off::Call::d`.
const _: () = assert!(
    off::Call::d == 1 && off::CallExt::d == 1 && off::CallExtInd::d == 1 && off::CallInd::d == 1
);

/// The length of the call instruction a return pc points at.
#[inline(always)]
unsafe fn call_len(pc: *const u32) -> usize {
    const CALL: u16 = Opcode::Call as u16;
    const EXT: u16 = Opcode::CallExt as u16;
    const EXT_IND: u16 = Opcode::CallExtInd as u16;
    const IND: u16 = Opcode::CallInd as u16;
    // SAFETY: a return pc points at a call instruction.
    match unsafe { *pc } as u16 {
        CALL => const { len(Opcode::Call) },
        EXT => const { len(Opcode::CallExt) },
        EXT_IND => const { len(Opcode::CallExtInd) },
        IND => const { len(Opcode::CallInd) },
        _ => fatal("return address is not a call instruction"),
    }
}

/// `ret`: copies `len` bytes at `fp + s` to the caller's destination and pops the frame.
/// Returns true if this was the entry frame (the value went to the entry record's `ret`, and
/// `run` must return 0).
#[inline(always)]
unsafe fn do_ret(vm: *mut VmThread, r: &mut Regs, s: u32, len: u32) -> bool {
    // SAFETY: the header was written by the call that pushed this frame (or by `enter`); the
    // destination slot is in the caller's frame, disjoint from ours.
    unsafe {
        let caller = r.fp.add(CALLER_FP_OFFSET as usize).cast::<*mut u8>().read();
        let src = r.fp.add(s as usize);
        if caller.is_null() {
            ptr::copy_nonoverlapping(src, (*(*vm).entry).ret, len as usize);
            return true;
        }
        let rpc = r.fp.add(RETURN_PC_OFFSET as usize).cast::<*const u32>().read();
        let d = *rpc.add(off::Call::d);
        ptr::copy_nonoverlapping(src, caller.add(d as usize), len as usize);
        (*vm).top = r.fp;
        r.fp = caller;
        if rpc < (*vm).code_lo || rpc >= (*vm).code_hi {
            load_image(vm, r, image_of_pc(rpc));
        }
        r.pc = rpc.add(call_len(rpc));
        false
    }
}

/// Unwinds from the call-like instruction at `r.pc` (or, with `pop_first`, from the current
/// frame's `resume`). Returns true to continue dispatch at `r.pc` (a cleanup block), false
/// when the entry frame was popped (`run` returns 1).
#[cold]
#[inline(never)]
unsafe fn unwind(vm: *mut VmThread, r: &mut Regs, mut pop_first: bool) -> bool {
    loop {
        if !pop_first {
            // SAFETY: the current image contains `r.pc`.
            let img = unsafe { &*(*vm).img };
            let word = (r.pc as usize).wrapping_sub(img.code as usize) / 4;
            let Some((f, at)) = img.view.function_at(word as u32) else {
                fatal("unwinding: pc outside every function")
            };
            match img.view.cleanup_at(f, at) {
                Some(Cleanup::Jump(t)) => {
                    let Some(e) = img.view.functions().get(f as usize) else { fatal("unwinding: bad function") };
                    let start = e.code_off;
                    r.pc = img.code.wrapping_add(start as usize + t as usize);
                    return true;
                }
                Some(Cleanup::Terminate) => fatal("panic in a function that cannot unwind"),
                None => {}
            }
        }
        pop_first = false;
        // SAFETY: as in `do_ret`.
        unsafe {
            let caller = r.fp.add(CALLER_FP_OFFSET as usize).cast::<*mut u8>().read();
            if caller.is_null() {
                return false;
            }
            let rpc = r.fp.add(RETURN_PC_OFFSET as usize).cast::<*const u32>().read();
            (*vm).top = r.fp;
            r.fp = caller;
            r.pc = rpc;
            if rpc < (*vm).code_lo || rpc >= (*vm).code_hi {
                load_image(vm, r, image_of_pc(rpc));
            }
        }
    }
}

/// `switch.sparse` lookup: the target of the case equal to `v`, if any. Cases are sorted by
/// value (unsigned); each is the value's words, then the target.
#[inline(always)]
unsafe fn sparse<T: Imm + Ord>(cases: *const u32, n: usize, v: T) -> Option<u32> {
    let vw = if size_of::<T>() <= 4 { 1 } else { size_of::<T>() / 4 };
    let ew = vw + 1;
    // SAFETY: trusted code: `n` cases of `ew` words follow.
    unsafe {
        let at = |i: usize| (T::imm(cases.add(i * ew)), *cases.add(i * ew + vw));
        if n <= 4 {
            for i in 0..n {
                let (c, t) = at(i);
                if c == v {
                    return Some(t);
                }
            }
            return None;
        }
        let (mut lo, mut hi) = (0, n);
        while lo < hi {
            let mid = lo + (hi - lo) / 2;
            let (c, t) = at(mid);
            match c.cmp(&v) {
                core::cmp::Ordering::Less => lo = mid + 1,
                core::cmp::Ordering::Greater => hi = mid,
                core::cmp::Ordering::Equal => return Some(t),
            }
        }
        None
    }
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

/// The return value size of the function containing `r.pc`.
#[cold]
unsafe fn current_ret_size(vm: *mut VmThread, r: &Regs) -> u32 {
    // SAFETY: the current image contains `r.pc`.
    let img = unsafe { &*(*vm).img };
    let word = (r.pc as usize).wrapping_sub(img.code as usize) / 4;
    match img.view.function_at(word as u32) {
        Some((f, _)) => match img.view.functions().get(f as usize) {
            Some(e) => e.ret_size,
            None => fatal("pc outside every function"),
        },
        None => fatal("pc outside every function"),
    }
}

/// Handler result: continue dispatching at `pc`.
#[cfg(not(ryo_dispatch_tail))]
const CONTINUE: u32 = u32::MAX;

/// The opcode at `pc`, aborting on an invalid one.
#[inline(always)]
#[cfg(not(ryo_dispatch_tail))]
unsafe fn opcode_at(pc: *const u32) -> Opcode {
    // SAFETY: trusted code: `pc` is an instruction start.
    let op = unsafe { *pc } as u16;
    if op as usize >= Opcode::COUNT {
        invalid_opcode()
    }
    // SAFETY: `Opcode` is `repr(u16)` with variants numbered 0..COUNT.
    unsafe { core::mem::transmute::<u16, Opcode>(op) }
}

/// `loop_match`'s next state. Not inlined in unoptimized builds, where each inlined copy
/// would get its own stack slots in every arm.
#[cfg(ryo_dispatch_loop_match)]
#[cfg_attr(debug_assertions, inline(never))]
#[cfg_attr(not(debug_assertions), inline(always))]
unsafe fn next_opcode(r: &Regs) -> Opcode {
    // SAFETY: per `opcode_at`.
    unsafe { opcode_at(r.pc) }
}

#[cold]
#[inline(never)]
fn invalid_opcode() -> ! {
    fatal("invalid opcode")
}

/// Generates a dispatcher from the handler list (design/vm.md, "Dispatch"). Invoked as
/// `for_each_handler!(dispatch!(strategy args))`; every strategy expands the same body macros,
/// so the instruction semantics, re-entrancy (nested `run`s through islands), entry records,
/// `call_catching` and image-context reloads are identical across strategies. A body's only
/// exits are falling through (continue at `pc`) and `return x` (`run`'s result).
///
/// - `plain r, vm, op`: `match op { … }`, to be put in a `loop`. Each arm calls its
///   handler as a local function returning [`CONTINUE`] or the result. In optimized builds
///   the handlers are `inline(always)`, so the match compiles to one function with the bodies
///   in its arms. Unoptimized builds don't share stack slots between arms, which made `run`'s
///   frame hundreds of KiB and limited native re-entrancy depth, so there they stay separate.
/// - `loop_match r, vm`: the same arms in a `#[loop_match]` loop whose state is the next
///   opcode. Every arm ends in a non-constant `break` (the next opcode is read from the code),
///   so this only differs from `plain` in how rustc lowers the loop.
/// - `tail`: one `extern "rust-preserve-none"` function per opcode with the hot state
///   `(pc, fp, vm, syms, consts)` as arguments, ending in
///   `become HANDLERS[op(pc)](pc, fp, vm, syms, consts)`, and the table `HANDLERS`. The
///   handlers are private, and only entered from [`run`] or from each other, so their
///   arguments always satisfy `run`'s contract: `pc` is an instruction of the image whose
///   `syms`/`consts` are passed and which is `vm`'s current image, and `fp` is the current
///   frame. `become` replaces the caller's native frame, so dispatch uses no native stack;
///   bodies that call native code (islands, `call_catching`, a nested `run`) do so from the
///   handler's own frame, as `run` does in the other strategies.
macro_rules! dispatch {
    (@arm $r:ident, $vm:ident, $name:ident, $kind:ident ($($a:tt)*)) => {
        #[cfg_attr(debug_assertions, inline(never))]
        #[cfg_attr(not(debug_assertions), inline(always))]
        #[allow(unreachable_code, non_snake_case, unused_mut, unused_variables, unused_unsafe)]
        unsafe fn $name(mut $r: &mut Regs, $vm: *mut VmThread) -> u32 {
            // SAFETY: as for `run`.
            unsafe { $kind!($r, $vm, $name, $($a)*) };
            CONTINUE
        }
    };
    ((plain $r:ident, $vm:ident, $opv:expr) $($name:ident => $kind:ident ($($a:tt)*);)*) => {
        match $opv {
            $(Opcode::$name => {
                dispatch!(@arm $r, $vm, $name, $kind ($($a)*));
                let x = $name(&mut $r, $vm);
                if x != CONTINUE {
                    return x;
                }
            })*
        }
    };
    ((loop_match $r:ident, $vm:ident) $($name:ident => $kind:ident ($($a:tt)*);)*) => {
        let mut op: Opcode = opcode_at($r.pc);
        #[loop_match]
        loop {
            op = 'next: {
                match op {
                    $(Opcode::$name => {
                        dispatch!(@arm $r, $vm, $name, $kind ($($a)*));
                        let x = $name(&mut $r, $vm);
                        if x != CONTINUE {
                            return x;
                        }
                        break 'next next_opcode(&$r);
                    })*
                }
            };
        }
    };
    ((tail) $($name:ident => $kind:ident ($($a:tt)*);)*) => {
        $(
            #[allow(unreachable_code, non_snake_case, unused_mut, unused_variables, unused_unsafe)]
            unsafe extern "rust-preserve-none" fn $name(
                pc: *const u32,
                fp: *mut u8,
                vm: *mut VmThread,
                syms: *const *const (),
                consts: *const u8,
            ) -> u32 {
                let mut r = Regs { pc, fp, syms, consts };
                // SAFETY: as for `run`; the arguments are the registers.
                unsafe {
                    $kind!(r, vm, $name, $($a)*);
                    let h = handler(r.pc);
                    become h(r.pc, r.fp, vm, r.syms, r.consts)
                }
            }
        )*

        /// The handler of each opcode, indexed by its value.
        static HANDLERS: [Handler; Opcode::COUNT] = {
            let mut t: [Option<Handler>; Opcode::COUNT] = [None; Opcode::COUNT];
            $(t[Opcode::$name as usize] = Some($name);)*
            // Every opcode has a handler, or this fails to compile.
            let mut out: [Handler; Opcode::COUNT] = [t[0].unwrap(); Opcode::COUNT];
            let mut i = 0;
            while i < Opcode::COUNT {
                out[i] = match t[i] {
                    Some(h) => h,
                    None => panic!("an opcode has no handler"),
                };
                i += 1;
            }
            out
        };
    };
}

include!("handlers.rs");

/// A tail-call handler. `extern "rust-preserve-none"`: no callee-saved registers, so handlers
/// have no prologue spills, and more argument registers (design/vm.md, "Dispatch").
#[cfg(ryo_dispatch_tail)]
type Handler = unsafe extern "rust-preserve-none" fn(*const u32, *mut u8, *mut VmThread, *const *const (), *const u8) -> u32;

/// The handler of the instruction at `pc`. An invalid opcode selects [`invalid_handler`]
/// instead of calling [`invalid_opcode`] here: a call, even a cold one, made LLVM align the
/// stack with a prologue push in handlers it couldn't shrink-wrap.
#[cfg(ryo_dispatch_tail)]
#[inline(always)]
unsafe fn handler(pc: *const u32) -> Handler {
    // SAFETY: trusted code: `pc` is an instruction start. The index is checked.
    unsafe {
        let op = *pc as u16 as usize;
        if op < Opcode::COUNT { *HANDLERS.get_unchecked(op) } else { invalid_handler }
    }
}

#[cfg(ryo_dispatch_tail)]
unsafe extern "rust-preserve-none" fn invalid_handler(
    _: *const u32,
    _: *mut u8,
    _: *mut VmThread,
    _: *const *const (),
    _: *const u8,
) -> u32 {
    invalid_opcode()
}

#[cfg(ryo_dispatch_tail)]
for_each_handler!(dispatch!(tail));

/// The name of the dispatch strategy this build uses (`match`, `loop_match` or `tail`).
pub const STRATEGY: &str = if cfg!(ryo_dispatch_tail) {
    "tail"
} else if cfg!(ryo_dispatch_loop_match) {
    "loop_match"
} else {
    "match"
};

/// Runs bytecode from `pc` in the frame `fp` until the entry frame returns (0) or a panic
/// unwinds out of it (1, payload in the innermost entry record).
///
/// # Safety
/// Called by `vm::enter` only: `vm` is this thread's state with a pushed entry record and
/// the image context of `pc`'s image; `fp` is the entry frame, set up as `enter` does.
#[inline(never)]
pub unsafe fn run(vm: *mut VmThread, pc: *const u32, fp: *mut u8) -> u32 {
    // SAFETY: see the module docs and the function's contract.
    unsafe {
        let img = &*(*vm).img;
        #[allow(unused_mut)]
        let mut r = Regs { pc, fp, syms: img.syms, consts: img.consts };
        #[cfg(ryo_dispatch_tail)]
        {
            handler(r.pc)(r.pc, r.fp, vm, r.syms, r.consts)
        }
        #[cfg(ryo_dispatch_loop_match)]
        {
            for_each_handler!(dispatch!(loop_match r, vm));
        }
        #[cfg(ryo_dispatch_match)]
        loop {
            let op = opcode_at(r.pc);
            for_each_handler!(dispatch!(plain r, vm, op));
        }
    }
}
