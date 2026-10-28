//! The JIT's SSA tier (the default, but for `RYO_JIT_OPT=reencode`): hand-assembled
//! functions using switches, tail calls, SSE arguments and results, catching landing pads,
//! large frames and escaped locals across OSR. Each test checks the results, that the code ran in the JIT code, and, in an SSA
//! mode, that every function it compiled went through the tier ([`ryo_jit::ssa_stats`]; a
//! separate test binary, so that the counters are this file's alone).

#![cfg(all(target_arch = "x86_64", any(target_os = "linux", target_vendor = "apple")))]

#[path = "../../rt/tests/common/mod.rs"]
mod common;
use common::*;

use ryo_bytecode::asm::{ArgReg, RetPart, Scope, ScopeKind, ret_kind};
use ryo_bytecode::image::{FUNC_COLD, FUNC_INLINE_ALWAYS, FUNC_INLINE_NEVER, Image};
use std::sync::atomic::{AtomicU64, AtomicUsize, Ordering::SeqCst};
use std::sync::{Mutex, MutexGuard, Once};

const F: Neg = Neg(true);

/// Every test's first step: the JIT's settings, before the first registration reads them.
fn init() {
    static ONCE: Once = Once::new();
    ONCE.call_once(|| assert!(ryo_rt::vm::configure_jit(true, Some(0)), "the JIT's settings were read already"));
}

/// Serializes the tests, so that each one's [`ryo_jit::ssa_stats`] deltas are its own.
static LOCK: Mutex<()> = Mutex::new(());

/// The test's lock, after [`init`], and the stats before it compiles anything.
fn start() -> (MutexGuard<'static, ()>, (usize, usize)) {
    let g = LOCK.lock().unwrap_or_else(|e| e.into_inner());
    init();
    (g, ryo_jit::ssa_stats())
}

/// In an SSA mode: exactly `n` more functions compiled by the tier since `before`, none fell back.
fn check_stats(before: (usize, usize), n: usize) {
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        let now = ryo_jit::ssa_stats();
        assert_eq!(now.0 - before.0, n, "functions the SSA tier compiled ({before:?} -> {now:?})");
        assert_eq!(now.1, before.1, "fallbacks to re-encoding ({before:?} -> {now:?})");
    }
}

/// Native: its own return address, so the VM code calling it learns where it runs.
#[unsafe(naked)]
extern "C" fn ret_addr() -> u64 {
    core::arch::naked_asm!("mov rax, [rsp]", "ret")
}

/// Native: `note(obs)` records where it was called from: the first call's and the last one's.
#[unsafe(naked)]
extern "C" fn note() {
    core::arch::naked_asm!("mov rsi, [rsp]", "jmp {note}", note = sym note_rs)
}

extern "C" fn note_rs(obs: *mut Obs, ra: u64) {
    let o = unsafe { &*obs };
    if o.first.load(SeqCst) == 0 {
        o.first.store(ra, SeqCst);
    }
    o.last.store(ra, SeqCst);
}

#[derive(Default)]
#[repr(C)]
struct Obs {
    first: AtomicU64,
    last: AtomicU64,
}

fn o(a: &AtomicU64) -> u64 {
    a.load(SeqCst)
}

extern "C" fn mul3(x: u64) -> u64 {
    x.wrapping_mul(3)
}

extern "C" fn mix(x: f64, y: f32) -> f64 {
    x * 10.0 + y as f64
}

// A foreign (non-Rust) exception, so that a catching landing pad can delete it without
// touching std's panic count.
#[repr(C, align(16))]
struct Exc {
    class: u64,
    cleanup: extern "C" fn(u32, *mut Exc),
    private: [u64; 2],
}

unsafe extern "C-unwind" {
    fn _Unwind_RaiseException(e: *mut Exc) -> u32;
    fn _Unwind_DeleteException(e: *mut Exc);
}

static DELETED: AtomicUsize = AtomicUsize::new(0);

extern "C" fn exc_cleanup(_: u32, e: *mut Exc) {
    drop(unsafe { Box::from_raw(e) });
    DELETED.fetch_add(1, SeqCst);
}

/// Native: `throw(x)` raises a foreign exception for `x == 7`, else returns `x`.
extern "C-unwind" fn throw(x: u64) -> u64 {
    if x == 7 {
        let e = Box::into_raw(Box::new(Exc { class: u64::from_be_bytes(*b"TESTEXC\0"), cleanup: exc_cleanup, private: [0; 2] }));
        unsafe { _Unwind_RaiseException(e) };
        panic!("_Unwind_RaiseException returned");
    }
    x
}

static THROWN: AtomicU64 = AtomicU64::new(0);

/// Native: `throw_all(x)` records `x` and raises a foreign exception.
extern "C-unwind" fn throw_all(x: u64) -> u64 {
    THROWN.store(x, SeqCst);
    let e = Box::into_raw(Box::new(Exc { class: u64::from_be_bytes(*b"TESTEXC\0"), cleanup: exc_cleanup, private: [0; 2] }));
    unsafe { _Unwind_RaiseException(e) };
    panic!("_Unwind_RaiseException returned");
}

extern "C" fn delete_exc(e: *mut Exc) {
    unsafe { _Unwind_DeleteException(e) }
}

fn syms() -> Vec<(&'static str, usize)> {
    vec![
        ("ret_addr", ret_addr as *const () as usize),
        ("note", note as *const () as usize),
        ("mul3", mul3 as *const () as usize),
        ("mix", mix as *const () as usize),
        ("throw", throw as *const () as usize),
        ("delete_exc", delete_exc as *const () as usize),
        ("throw_all", throw_all as *const () as usize),
        ("isl", isl_mul10_add7 as *const () as usize),
    ]
}

/// Whether `addr` is in the JIT code of function `f`.
fn in_jit(img: &Linked, f: Func, addr: u64) -> bool {
    let r = unsafe { &*img.record(f) };
    let start = r.jit_code as u64;
    start != 0 && (start..start + ryo_jit::code_len(r) as u64).contains(&addr)
}

fn state(img: &Linked, f: Func) -> u32 {
    unsafe { (*img.record(f)).state.load(SeqCst) }
}

/// Whether `addr` is in the AOT code of function `f`.
fn in_aot(img: &Linked, f: Func, addr: u64) -> bool {
    let start = img.code(f) as u64;
    (start..start + img.functions[f.0 as usize].len as u64).contains(&addr)
}

/// `ret_addr()` into `tmp`, stored at `out[k]` (`out` the pointer at slot `out`).
fn where_at(a: &mut Asm, s_ret: Sym, tmp: i32, out: i32, k: i32) {
    a.i(Insn::CallSym { d: Slot(tmp), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(out), k: 8 * k }, s: Slot(tmp) });
}

fn note_call(a: &mut Asm, s_note: Sym, slot: i32) -> u32 {
    a.i(Insn::CallSym { d: Slot(0), sym: s_note, k: 0, a: List::from_words(&regs(&[slot])) })
}

/// Functions of an image being built, with their scopes (escapes), which [`ImageWriter::finish`]
/// doesn't take.
#[derive(Default)]
struct Defs(Vec<(FunctionDef, Vec<Scope>)>);

impl Defs {
    fn add(&mut self, w: &mut ImageWriter, f: FunctionDef, scopes: Vec<Scope>) -> Func {
        self.0.push((f.clone(), scopes));
        w.add_function(f)
    }

    fn build(self, mut w: ImageWriter) -> Linked {
        w.prepare(ENC);
        w.validate_functions().unwrap();
        let enc = self.0.iter().map(|(f, sc)| ryo_bytecode::asm::encode(&f.code, f.frame_size, &f.cleanup, sc, ENC).unwrap()).collect();
        let img = link(w.finish_encoded(enc).unwrap(), &syms());
        register(&[&img]);
        img
    }
}

fn escape(at: u32, off: i32, size: u32) -> Scope {
    Scope { code_offset: at, frame_offset: off, size, kind: ScopeKind::Escape { align: 8 } }
}

/// A dense switch in a loop: each case block computes a different value into one slot, and
/// the join (a loop body block with parameters in SSA) folds it into the accumulator.
#[test]
fn switch_with_edge_arguments() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // f(n, out): acc = 0; for i < n { switch i % 5 { 1 => t = i * 3, 2 => t = 1000,
    // 3 => t = i + 77, _ => t = 5 }; acc = acc * 7 + t }; out[0] = where it runs; ret acc.
    // n@16, out@24; i@-8, acc@-16, r@-24, t@-32, five@-40, tmp@-48.
    let mut a = Asm::new();
    a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-40), imm: 5 });
    let head = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
    a.i(Insn::RemUW64 { d: Slot(-24), a: Slot(-8), b: Slot(-40) });
    let sw = a.i(Insn::SwitchDenseW32 { s: Slot(-24), base: 1, default: Target(0), table: List::from_words(&[0; 3]) });
    let mut joins = vec![];
    let c1 = a.i(Insn::MulImmW64 { d: Slot(-32), a: Slot(-8), imm: 3 });
    joins.push(a.i(Insn::Jmp { t: Target(0) }));
    let c2 = a.i(Insn::ImmW64 { d: Slot(-32), imm: 1000 });
    joins.push(a.i(Insn::Jmp { t: Target(0) }));
    let c3 = a.i(Insn::AddImmW64 { d: Slot(-32), a: Slot(-8), imm: 77 });
    joins.push(a.i(Insn::Jmp { t: Target(0) }));
    let d = a.i(Insn::ImmW64 { d: Slot(-32), imm: 5 });
    let join = a.i(Insn::MulImmW64 { d: Slot(-16), a: Slot(-16), imm: 7 });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-32) });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", head);
    let done = a.pos();
    where_at(&mut a, s_ret, -48, 24, 0);
    a.ret(Slot(-16), 8);
    a.patch(head, "t", done);
    for (i, c) in [c1, c2, c3].into_iter().enumerate() {
        a.patch_list(sw, "table", i, c);
    }
    a.patch(sw, "default", d);
    for j in joins {
        a.patch(j, "t", join);
    }
    let f = w.add_function(func(a.done(), 48, 16, 8));
    let img = build(w, &syms());

    let want = |n: u64| {
        (0..n).fold(0u64, |acc, i| {
            let t = match i % 5 {
                1 => i * 3,
                2 => 1000,
                3 => i + 77,
                _ => 5,
            };
            acc.wrapping_mul(7).wrapping_add(t)
        })
    };
    for n in [0u64, 1, 2, 3, 4, 5, 23, 100] {
        let mut out = [0u64; 1];
        assert_eq!(ok::<_, u64>(img.id(f), (n, out.as_mut_ptr() as u64)), want(n), "n = {n}");
        assert!(in_jit(&img, f, out[0]), "n = {n}: ran at {:#x}", out[0]);
    }
    check_stats(before, 1);
}

/// Sparse switches of 32 and 64 bits with enough cases for a binary search, and the default.
#[test]
fn sparse_switch() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // f(x, out): out[0] = where it runs; switch x { v_i => ret 100 + i, _ => ret 99 }.
    // x@16, out@24; r@-8, tmp@-16.
    macro_rules! sparse {
        ($v:ident, $case:ident, $vals:expr) => {{
            let vals = $vals;
            let mut a = Asm::new();
            where_at(&mut a, s_ret, -16, 24, 0);
            let cw = list_words(vals.iter().map(|&v| $case { value: v, target: Target(0) }));
            let sw = a.i(Insn::$v { s: Slot(16), default: Target(0), cases: List::from_words(&cw) });
            let mut targets = vec![];
            for i in 0..vals.len() {
                targets.push(a.i(Insn::ImmW64 { d: Slot(-8), imm: 100 + i as u64 }));
                a.ret(Slot(-8), 8);
            }
            let d = a.i(Insn::ImmW64 { d: Slot(-8), imm: 99 });
            a.patch(sw, "default", d);
            a.ret(Slot(-8), 8);
            let mut code = a.done();
            let ew = cw.len() / vals.len();
            let base = sw as usize + ryo_bytecode::full::off::$v::cases + 1;
            for (i, t) in targets.iter().enumerate() {
                code[base + i * ew + ew - 1] = t.wrapping_sub(sw);
            }
            (vals.iter().map(|&v| v as u64).collect::<Vec<_>>(), w.add_function(func(code, 16, 16, 8)))
        }};
    }
    let fs = [
        (32u32, sparse!(SwitchSparseW32, Case32, [0u32, 3, 9, 10, 11, 1000, 0x7fff_ffff, 0xffff_fff0])),
        (64, sparse!(SwitchSparseW64, Case64, [2u64, 17, 1 << 33, (1 << 33) + 1, 0x1234_5678_9abc_def0, u64::MAX - 1, u64::MAX])),
    ];
    let img = build(w, &syms());

    for (n, (vals, f)) in &fs {
        let mask = if *n == 64 { u64::MAX } else { (1 << n) - 1 };
        let mut probes: Vec<u64> = vals.clone();
        probes.extend(vals.iter().map(|v| v.wrapping_add(1) & mask));
        probes.extend(vals.iter().map(|v| v.wrapping_sub(1) & mask));
        probes.extend([1u64 << 20, 5, 0x5555]);
        for x in probes {
            let want = vals.iter().position(|&v| v == x).map_or(99, |i| 100 + i as u64);
            // High garbage above a 32-bit switch's width is ignored.
            let arg = if *n == 32 { x | 0xdead << 40 } else { x };
            let mut out = [0u64; 1];
            assert_eq!(ok::<_, u64>(img.id(*f), (arg, out.as_mut_ptr() as u64)), want, "w{n} {x:#x}");
            assert!(in_jit(&img, *f, out[0]), "w{n}: ran at {:#x}", out[0]);
        }
    }
    check_stats(before, 2);
}

/// `tail_call` to a VM function with register arguments and arguments in the incoming block
/// (written over the caller's own), and `tail_call.ptr` to a native function through
/// `addr.sym`.
#[test]
fn tail_calls() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    let s_mul3 = w.symbol("mul3", 0);
    // g(r: rdi, out: rsi, s0@16, s1@24) = r * 100 + s0 + s1; out[1] = where it runs.
    // r@-8, out@-16, tmp@-24.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    where_at(&mut a, s_ret, -24, -16, 1);
    a.i(Insn::MulImmW64 { d: Slot(-8), a: Slot(-8), imm: 100 });
    a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(16) });
    a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(24) });
    a.ret(Slot(-8), 8);
    let g = w.add_function(func(a.done(), 32, 16, 8));
    // f(a, b, out): out[0] = where it runs; become g(a + 7, out, 2a, b + 1). a@16, b@24,
    // out@32; tmp@-8, r@-16.
    let mut a = Asm::new();
    where_at(&mut a, s_ret, -8, 32, 0);
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(16), imm: 7 });
    a.i(Insn::AddImmW64 { d: Slot(24), a: Slot(24), imm: 1 });
    a.i(Insn::AddW64 { d: Slot(16), a: Slot(16), b: Slot(16) });
    a.i(Insn::TailCall { f: g, a: List::from_words(&regs(&[-16, 32])) });
    let f = w.add_function(func(a.done(), 16, 24, 8));
    // h(x, out): out[0] = where it runs; become mul3(x) through a pointer. x@16, out@24;
    // tmp@-8, p@-16.
    let mut a = Asm::new();
    where_at(&mut a, s_ret, -8, 24, 0);
    a.i(Insn::AddrSym { d: Slot(-16), sym: s_mul3 });
    a.i(Insn::TailCallPtr { p: Slot(-16), a: List::from_words(&regs(&[16])) });
    let h = w.add_function(func(a.done(), 16, 16, 8));
    let img = build(w, &syms());

    for (x, y) in [(0u64, 0u64), (5, 9), (1 << 40, 3), (u64::MAX, 1)] {
        let mut out = [0u64; 2];
        let want = x.wrapping_add(7).wrapping_mul(100).wrapping_add(x.wrapping_mul(2)).wrapping_add(y + 1);
        assert_eq!(ok::<_, u64>(img.id(f), (x, y, out.as_mut_ptr() as u64)), want, "f({x}, {y})");
        assert!(in_jit(&img, f, out[0]), "f ran at {:#x}", out[0]);
        assert!(in_jit(&img, g, out[1]), "g ran at {:#x}", out[1]);
        let mut out = [0u64; 1];
        assert_eq!(ok::<_, u64>(img.id(h), (x, out.as_mut_ptr() as u64)), x.wrapping_mul(3), "h({x})");
        assert!(in_jit(&img, h, out[0]), "h ran at {:#x}", out[0]);
    }
    check_stats(before, 3);
}

#[repr(C)]
#[derive(Debug, PartialEq)]
struct F2(f64, f64);

#[repr(C)]
#[derive(Debug, PartialEq)]
struct IF(u64, f64);

/// Float arguments in `xmm` registers, handler arithmetic, a native call with `xmm` arguments
/// and result, and two-part returns in `xmm0`/`xmm1` and `rax`/`xmm0`.
#[test]
fn sse_arguments_and_results() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    let s_mix = w.symbol("mix", 0);
    let x8 = |i| ArgReg { xmm: true, size: 8, index: i }.word();
    let x4 = |i| ArgReg { xmm: true, size: 4, index: i }.word();
    let k_ff = ret_kind(&[RetPart { xmm: true, size: 8, off: 0 }, RetPart { xmm: true, size: 8, off: 8 }]);
    let k_if = ret_kind(&[RetPart { xmm: false, size: 8, off: 0 }, RetPart { xmm: true, size: 8, off: 8 }]);
    let k_f = ret_kind(&[RetPart { xmm: true, size: 8, off: 0 }]);
    // ff(x: xmm0, y: xmm1 (f32), out: rdi) = (mix(x, y * y) + x, x * x); out[0] = where it
    // runs. x@-8, y@-12, out@-24, s@-28, m@-40, res@-64 (16 bytes), tmp@-72.
    let mut a = Asm::new();
    a.i(Insn::Arg { d: Slot(-8), r: x8(0) });
    a.i(Insn::Arg { d: Slot(-12), r: x4(1) });
    a.i(arg(-24, 0));
    where_at(&mut a, s_ret, -72, -24, 0);
    a.i(Insn::FmulF32 { d: Slot(-28), a: Slot(-12), b: Slot(-12) });
    a.i(Insn::CallSym { d: Slot(-40), sym: s_mix, k: k_f, a: List::from_words(&[-8i32 as u32, x8(0), -28i32 as u32, x4(1)]) });
    a.i(Insn::FaddF64 { d: Slot(-64), a: Slot(-40), b: Slot(-8) });
    a.i(Insn::FmulF64 { d: Slot(-56), a: Slot(-8), b: Slot(-8) });
    a.i(Insn::Ret { s: Slot(-64), k: k_ff });
    let mut fd = func(a.done(), 80, 0, 0);
    (fd.ret_size, fd.ret_kind) = (16, k_ff);
    let ff = w.add_function(fd);
    // fi(x: xmm0, n: rdi, out: rsi) = (n + 1, x + x); out[0] = where it runs. x@-8, n@-16,
    // out@-24, res@-48 (16 bytes), tmp@-56.
    let mut a = Asm::new();
    a.i(Insn::Arg { d: Slot(-8), r: x8(0) });
    a.i(arg(-16, 0));
    a.i(arg(-24, 1));
    where_at(&mut a, s_ret, -56, -24, 0);
    a.i(Insn::AddImmW64 { d: Slot(-48), a: Slot(-16), imm: 1 });
    a.i(Insn::FaddF64 { d: Slot(-40), a: Slot(-8), b: Slot(-8) });
    a.i(Insn::Ret { s: Slot(-48), k: k_if });
    let mut fd = func(a.done(), 64, 0, 0);
    (fd.ret_size, fd.ret_kind) = (16, k_if);
    let fi = w.add_function(fd);
    let img = build(w, &syms());

    let ffn: extern "C" fn(f64, f32, *mut u64) -> F2 = unsafe { std::mem::transmute(img.code(ff)) };
    let fin: extern "C" fn(f64, u64, *mut u64) -> IF = unsafe { std::mem::transmute(img.code(fi)) };
    for (x, y) in [(1.5f64, 2.5f32), (-3.25, 0.125), (1e100, -7.0), (0.0, 0.0)] {
        let mut out = [0u64; 1];
        assert_eq!(ffn(x, y, out.as_mut_ptr()), F2(mix(x, y * y) + x, x * x), "ff({x}, {y})");
        assert!(in_jit(&img, ff, out[0]), "ff ran at {:#x}", out[0]);
        let mut out = [0u64; 1];
        assert_eq!(fin(x, 41, out.as_mut_ptr()), IF(42, x + x), "fi({x})");
        assert!(in_jit(&img, fi, out[0]), "fi ran at {:#x}", out[0]);
    }
    check_stats(before, 2);
}

/// A call that unwinds into a catching landing pad: the pad deletes the exception and the
/// function returns normally, with a value computed before the call that is live across it.
#[test]
fn catching_landing_pad() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    let s_throw = w.symbol("throw", 0);
    let s_del = w.symbol("delete_exc", 0);
    // f(x, out): out[0] = where it runs; v = x * 3 + 1; r = throw(x); ret v + r; catching
    // pad: delete the exception; ret v + 1000. x@16, out@24; v@-8, r@-16, exc@-24, tmp@-32.
    let mut a = Asm::new();
    where_at(&mut a, s_ret, -32, 24, 0);
    a.i(Insn::MulImmW64 { d: Slot(-8), a: Slot(16), imm: 3 });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    let site = a.i(Insn::CallSym { d: Slot(-16), sym: s_throw, k: 8, a: List::from_words(&regs(&[16])) });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-8) });
    a.ret(Slot(-16), 8);
    let pad = a.i(Insn::Lpad { x: Slot(-24) });
    a.i(Insn::CallSym { d: Slot(0), sym: s_del, k: 0, a: List::from_words(&regs(&[-24])) });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-8), imm: 1000 });
    a.ret(Slot(-16), 8);
    let mut fd = func(a.done(), 32, 16, 8);
    fd.cleanup = vec![CleanupEntry { offset: site, target: pad | CATCH }];
    let f = w.add_function(fd);
    let img = build(w, &syms());

    for round in 0..3 {
        let del = DELETED.load(SeqCst);
        let mut out = [0u64; 1];
        assert_eq!(ok::<_, u64>(img.id(f), (7u64, out.as_mut_ptr() as u64)), 22 + 1000, "round {round}");
        assert_eq!(DELETED.load(SeqCst), del + 1, "round {round}: the exception deleted");
        assert!(in_jit(&img, f, out[0]), "ran at {:#x}", out[0]);
        assert_eq!(ok::<_, u64>(img.id(f), (5u64, out.as_mut_ptr() as u64)), 16 + 5, "round {round}");
    }
    check_stats(before, 1);
}

/// `n` values `v[k] = v[k - 1] * 5 + k` from `v[0]` at slot `from` into the slots `to`,
/// `to - 8`, ..., and their sum into `sum` (all live until then).
fn chain(a: &mut Asm, from: i32, to: i32, n: i32, sum: i32) {
    for k in 0..n {
        let prev = if k == 0 { from } else { to + 8 - 8 * k };
        a.i(Insn::MulImmW64 { d: Slot(to - 8 * k), a: Slot(prev), imm: 5 });
        a.i(Insn::AddImmW64 { d: Slot(to - 8 * k), a: Slot(to - 8 * k), imm: k as u64 + 1 });
    }
    a.i(Insn::ImmW64 { d: Slot(sum), imm: 0 });
    for k in 0..n {
        a.i(Insn::AddW64 { d: Slot(sum), a: Slot(sum), b: Slot(to - 8 * k) });
    }
}

fn chain_sum(x: u64, n: u64) -> u64 {
    let mut v = x;
    (0..n)
        .map(|k| {
            v = v.wrapping_mul(5).wrapping_add(k + 1);
            v
        })
        .fold(0, u64::wrapping_add)
}

/// The callee-saved registers' saves, pushed (a callee with nothing pinned) or stored (one
/// with a 4-byte local pinned at the frame's top, which leaves the saves below an offset
/// that isn't 8-aligned), restored by `pop`/`mov` on return and by the unwinder from the
/// FDE's rules on a throw: the caller, catching it, keeps its values in the same registers
/// across the call. The callee's cleanup pad resumes, so that it isn't inlined there (and
/// so it is compiled: the stats count it).
#[test]
fn callee_saved_across_unwinding() {
    let (_g, before) = start();
    const N: i32 = 7;
    for pinned in [false, true] {
        let mut w = ImageWriter::new(unique_scid());
        let s_throw = w.symbol("throw", 0);
        let s_del = w.symbol("delete_exc", 0);
        let mut defs = Defs::default();
        // g(x): v = chain(x) (live across the call, the sum unused); [pinned: e@-4 = 1;
        // p = &e; for i < 2 { *p += 1 }]; r = throw(x); ret r + sum(v); cleanup pad:
        // resume. x@-72; v@-16.., sum@-80, r@-88, p@-96, i@-104, exc@-112, e@-4.
        let mut a = Asm::new();
        let mut scopes = Vec::new();
        a.i(arg(-72, 0));
        chain(&mut a, -72, -16, N, -80);
        if pinned {
            a.i(Insn::ImmW32 { d: Slot(-4), imm: 1 });
            let at = a.i(Insn::Addr { d: Slot(-96), s: Slot(-4) });
            a.i(Insn::ImmW64 { d: Slot(-104), imm: 0 });
            let head = a.i(Insn::BrLtUImmW64 { a: Slot(-104), imm: 2, neg: F, t: Target(0) });
            a.i(Insn::LoadW32 { d: Slot(-88), m: Mem { p: Slot(-96), k: 0 } });
            a.i(Insn::AddImmW32 { d: Slot(-88), a: Slot(-88), imm: 1 });
            a.i(Insn::StoreW32 { m: Mem { p: Slot(-96), k: 0 }, s: Slot(-88) });
            a.i(Insn::AddImmW64 { d: Slot(-104), a: Slot(-104), imm: 1 });
            let back = a.i(Insn::Jmp { t: Target(0) });
            a.patch(back, "t", head);
            let done = a.pos();
            a.patch(head, "t", done);
            scopes.push(escape(at, -4, 4));
        }
        let site = a.i(Insn::CallSym { d: Slot(-88), sym: s_throw, k: 8, a: List::from_words(&regs(&[-72])) });
        for k in 0..N {
            a.i(Insn::AddW64 { d: Slot(-88), a: Slot(-88), b: Slot(-16 - 8 * k) });
        }
        a.ret(Slot(-88), 8);
        let pad = a.i(Insn::Lpad { x: Slot(-112) });
        let resume = a.i(Insn::Resume { x: Slot(-112) });
        let mut gd = func(a.done(), 128, 0, 8);
        gd.cleanup = vec![CleanupEntry { offset: site, target: pad }, CleanupEntry { offset: resume, target: CONTINUE }];
        let g = defs.add(&mut w, gd, scopes);
        // f(x): u = chain(x + 1) (live across the call); r = g(x); ret r + sum(u); catching
        // pad: delete the exception, ret 2 sum(u) + 1000. x@16; u@-8.., sum@-72, r@-80,
        // exc@-88, t@-96.
        let mut a = Asm::new();
        a.i(Insn::AddImmW64 { d: Slot(-96), a: Slot(16), imm: 1 });
        chain(&mut a, -96, -8, N, -72);
        let site = a.i(Insn::Call { d: Slot(-80), f: g, k: 8, a: List::from_words(&regs(&[16])) });
        for k in 0..N {
            a.i(Insn::AddW64 { d: Slot(-80), a: Slot(-80), b: Slot(-8 - 8 * k) });
        }
        a.ret(Slot(-80), 8);
        let pad = a.i(Insn::Lpad { x: Slot(-88) });
        a.i(Insn::CallSym { d: Slot(0), sym: s_del, k: 0, a: List::from_words(&regs(&[-88])) });
        for k in 0..N {
            a.i(Insn::AddW64 { d: Slot(-72), a: Slot(-72), b: Slot(-8 - 8 * k) });
        }
        a.i(Insn::AddImmW64 { d: Slot(-80), a: Slot(-72), imm: 1000 });
        a.ret(Slot(-80), 8);
        let mut fd = func(a.done(), 112, 8, 8);
        fd.cleanup = vec![CleanupEntry { offset: site, target: pad | CATCH }];
        let f = defs.add(&mut w, fd, vec![]);
        let img = defs.build(w);

        for round in 0..3 {
            let what = format!("pinned {pinned}, round {round}");
            let x = 5u64;
            assert_eq!(ok::<_, u64>(img.id(f), (x,)), x + chain_sum(x, N as u64) + chain_sum(x + 1, N as u64), "{what}");
            let del = DELETED.load(SeqCst);
            // The pad adds the chain to its sum a second time.
            let u = chain_sum(8, N as u64);
            assert_eq!(ok::<_, u64>(img.id(f), (7u64,)), 2 * u + 1000, "{what}: thrown");
            assert_eq!(DELETED.load(SeqCst), del + 1, "{what}: the exception deleted");
        }
    }
    check_stats(before, 4);
}

/// A frame of 12 KiB (the prologue probes it), entered by OSR mid-loop: the OSR entry's probe
/// runs, and the loop's values, one at the frame's far end, stay right.
#[test]
fn large_frames_probe() {
    let (_g, before) = start();
    const FR: u32 = 12288;
    let far = -(FR as i32);
    let ks = [0i64, 1, 4];
    for k in ks {
        let mut w = ImageWriter::new(unique_scid());
        let s_note = w.symbol("note", 0);
        // f(n, out, obs): i = 0; a = 1; b@far = 3; for i < n { a = a * 5 + i; b = b + a };
        // out[0] = a, out[1] = b; ret i. n@16, out@24, obs@32; i@-8, a@-16, b@-FR.
        let mut a = Asm::new();
        note_call(&mut a, s_note, 32);
        a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
        a.i(Insn::ImmW64 { d: Slot(-16), imm: 1 });
        a.i(Insn::ImmW64 { d: Slot(far), imm: 3 });
        let head = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
        a.i(Insn::MulImmW64 { d: Slot(-16), a: Slot(-16), imm: 5 });
        a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-8) });
        a.i(Insn::AddW64 { d: Slot(far), a: Slot(far), b: Slot(-16) });
        a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
        let back = a.i(Insn::Jmp { t: Target(0) });
        a.patch(back, "t", head);
        let done = a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-16) });
        a.patch(head, "t", done);
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 8 }, s: Slot(far) });
        note_call(&mut a, s_note, 32);
        a.ret(Slot(-8), 8);
        let f = w.add_function(func(a.done(), FR, 24, 8));
        let img = build(w, &syms());

        let n = 40u64;
        let (mut av, mut bv) = (1u64, 3u64);
        for i in 0..n {
            av = av.wrapping_mul(5).wrapping_add(i);
            bv = bv.wrapping_add(av);
        }
        img.trip_after(f, 1, k as i64);
        let mut out = [0u64; 2];
        let obs = Obs::default();
        let what = format!("trip at head pass {}", k + 1);
        assert_eq!(ok::<_, u64>(img.id(f), (n, out.as_mut_ptr() as u64, &raw const obs as u64)), n, "{what}");
        assert_eq!(out, [av, bv], "{what}");
        assert!(in_aot(&img, f, o(&obs.first)), "{what}: started at {:#x}", o(&obs.first));
        assert!(in_jit(&img, f, o(&obs.last)), "{what}: ended at {:#x}", o(&obs.last));
        // And from the entry.
        let obs = Obs::default();
        assert_eq!(ok::<_, u64>(img.id(f), (n, out.as_mut_ptr() as u64, &raw const obs as u64)), n, "{what}");
        assert_eq!(out, [av, bv], "{what}: from the entry");
        assert!(in_jit(&img, f, o(&obs.first)), "{what}: started at {:#x}", o(&obs.first));
    }
    check_stats(before, ks.len());
}

/// A local whose address is taken before the loop, written through the pointer in it, the
/// loop entered by OSR, and the local read directly after it.
#[test]
fn pinned_escaped_at_head() {
    let (_g, before) = start();
    let ks = [0i64, 1, 3, 10];
    for k in ks {
        let mut w = ImageWriter::new(unique_scid());
        let s_note = w.symbol("note", 0);
        let mut defs = Defs::default();
        // f(n, out, obs): e = 5; p = &e; for i < n { *p = *p * 3 + i }; out[0] = e; ret i.
        // n@16, out@24, obs@32; i@-8, e@-16, p@-24, t@-32.
        let mut a = Asm::new();
        note_call(&mut a, s_note, 32);
        a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
        a.i(Insn::ImmW64 { d: Slot(-16), imm: 5 });
        let at_addr = a.i(Insn::Addr { d: Slot(-24), s: Slot(-16) });
        let head = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
        a.i(Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-24), k: 0 } });
        a.i(Insn::MulImmW64 { d: Slot(-32), a: Slot(-32), imm: 3 });
        a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-8) });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(-24), k: 0 }, s: Slot(-32) });
        a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
        let back = a.i(Insn::Jmp { t: Target(0) });
        a.patch(back, "t", head);
        let done = a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-16) });
        a.patch(head, "t", done);
        note_call(&mut a, s_note, 32);
        a.ret(Slot(-8), 8);
        let f = defs.add(&mut w, func(a.done(), 32, 24, 8), vec![escape(at_addr, -16, 8)]);
        let img = defs.build(w);

        let n = 30u64;
        let e = (0..n).fold(5u64, |e, i| e.wrapping_mul(3).wrapping_add(i));
        img.trip_after(f, 1, k as i64);
        let mut out = [0u64; 1];
        let obs = Obs::default();
        let what = format!("trip at head pass {}", k + 1);
        assert_eq!(ok::<_, u64>(img.id(f), (n, out.as_mut_ptr() as u64, &raw const obs as u64)), n, "{what}");
        assert_eq!(out[0], e, "{what}");
        assert!(in_aot(&img, f, o(&obs.first)), "{what}: started at {:#x}", o(&obs.first));
        assert!(in_jit(&img, f, o(&obs.last)), "{what}: ended at {:#x}", o(&obs.last));
    }
    check_stats(before, ks.len());
}

/// A cold block (it ends in `unreachable` after a call that unwinds) between the check and
/// the hot path, using values of the hot path after calls of its own: laid out last, with
/// those values passed to it as parameters, and the exception caught by the caller.
#[test]
fn cold_block_values_across_calls() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_mul3 = w.symbol("mul3", 0);
    let s_throw = w.symbol("throw_all", 0);
    let s_del = w.symbol("delete_exc", 0);
    // f(x, y, z): if x < y { ret x + z }; throw_all(mul3(x) + mul3(z) + y); unreachable.
    // x@-8, y@-16, z@-24, r@-32, m1@-40, m2@-48.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    a.i(arg(-24, 2));
    let br = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(-16), neg: F, t: Target(0) });
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-8), b: Slot(-24) });
    a.ret(Slot(-32), 8);
    let cold = a.i(Insn::CallSym { d: Slot(-40), sym: s_mul3, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::CallSym { d: Slot(-48), sym: s_mul3, k: 8, a: List::from_words(&regs(&[-24])) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-48) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-16) });
    let throw = a.i(Insn::CallSym { d: Slot(-48), sym: s_throw, k: 8, a: List::from_words(&regs(&[-40])) });
    a.i(Insn::Unreachable {});
    a.patch(br, "t", cold);
    let mut fd = func(a.done(), 48, 0, 8);
    fd.cleanup = vec![CleanupEntry { offset: throw, target: ryo_bytecode::image::CONTINUE }];
    let f = w.add_function(fd);
    // g(x, y, z) = f(x, y, z), or 1000 if it unwinds. x@16, y@24, z@32; r@-8, exc@-16.
    let mut a = Asm::new();
    let site = a.i(Insn::Call { d: Slot(-8), f, k: 8, a: List::from_words(&regs(&[16, 24, 32])) });
    a.ret(Slot(-8), 8);
    let pad = a.i(Insn::Lpad { x: Slot(-16) });
    a.i(Insn::CallSym { d: Slot(0), sym: s_del, k: 0, a: List::from_words(&regs(&[-16])) });
    a.i(Insn::ImmW64 { d: Slot(-8), imm: 1000 });
    a.ret(Slot(-8), 8);
    let mut fd = func(a.done(), 16, 24, 8);
    fd.cleanup = vec![CleanupEntry { offset: site, target: pad | CATCH }];
    let g = w.add_function(fd);
    let img = build(w, &syms());

    for (x, y, z) in [(1u64, 2u64, 40u64), (5, 3, 11), (7, 7, 1 << 40), (0, u64::MAX, 9)] {
        let del = DELETED.load(SeqCst);
        let r = ok::<_, u64>(img.id(g), (x, y, z));
        if x < y {
            assert_eq!(r, x.wrapping_add(z), "({x}, {y}, {z})");
        } else {
            assert_eq!(r, 1000, "({x}, {y}, {z})");
            assert_eq!(THROWN.load(SeqCst), (x * 3).wrapping_add(z.wrapping_mul(3)).wrapping_add(y), "({x}, {y}, {z})");
            assert_eq!(DELETED.load(SeqCst), del + 1, "({x}, {y}, {z})");
        }
    }
    // g, with f inlined: its cold path is g's.
    check_stats(before, 1);
}

// ---- Inlining (design/jit.md, "Inlining") ----

/// `bump(p, k)`: `*p = *p * 3 + k`, returns the old `*p`; register arguments, so that it can
/// be inlined. p@-8, k@-16, old@-24, t@-32.
fn bump() -> FunctionDef {
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    a.i(Insn::LoadW64 { d: Slot(-24), m: Mem { p: Slot(-8), k: 0 } });
    a.i(Insn::MulImmW64 { d: Slot(-32), a: Slot(-24), imm: 3 });
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-16) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-8), k: 0 }, s: Slot(-32) });
    a.ret(Slot(-24), 8);
    func(a.done(), 32, 0, 8)
}

/// A callee taking the address of the caller's local, inlined into a loop: the local's
/// address only reaches loads and stores once the call is gone (post-inline promotion), and
/// the callee isn't compiled on its own. Also entered by OSR at the loop head.
#[test]
fn inline_callee_with_caller_local() {
    let (_g, before) = start();
    for k in [None, Some(0i64), Some(3)] {
        let mut w = ImageWriter::new(unique_scid());
        let mut defs = Defs::default();
        let s_ret = w.symbol("ret_addr", 0);
        let b = defs.add(&mut w, bump(), vec![]);
        // f(n, out): e = 5; s = 0; for i < n { s += bump(&e, i) }; out[0] = e; out[1] =
        // where it runs; ret s. n@16, out@24 (copied to -8, -16); i@-24, e@-32, s@-40,
        // p@-48, r@-56, tmp@-64.
        let mut a = Asm::new();
        a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
        a.i(Insn::MovW64 { d: Slot(-16), s: Slot(24) });
        a.i(Insn::ImmW64 { d: Slot(-24), imm: 0 });
        a.i(Insn::ImmW64 { d: Slot(-32), imm: 5 });
        a.i(Insn::ImmW64 { d: Slot(-40), imm: 0 });
        let head = a.i(Insn::BrLtUW64 { a: Slot(-24), b: Slot(-8), neg: F, t: Target(0) });
        let at_addr = a.i(Insn::Addr { d: Slot(-48), s: Slot(-32) });
        a.i(Insn::Call { d: Slot(-56), f: b, k: 8, a: List::from_words(&regs(&[-48, -24])) });
        a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-56) });
        a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
        let back = a.i(Insn::Jmp { t: Target(0) });
        a.patch(back, "t", head);
        let done = a.i(Insn::StoreW64 { m: Mem { p: Slot(-16), k: 0 }, s: Slot(-32) });
        a.patch(head, "t", done);
        where_at(&mut a, s_ret, -64, -16, 1);
        a.ret(Slot(-40), 8);
        let f = defs.add(&mut w, func(a.done(), 64, 16, 8), vec![escape(at_addr, -32, 8)]);
        let img = defs.build(w);
        if let Some(k) = k {
            img.trip_after(f, 1, k);
        }
        let n = 20u64;
        let (mut e, mut s) = (5u64, 0u64);
        for i in 0..n {
            s = s.wrapping_add(e);
            e = e.wrapping_mul(3).wrapping_add(i);
        }
        for round in 0..2 {
            let mut out = [0u64; 2];
            assert_eq!(ok::<_, u64>(img.id(f), (n, out.as_mut_ptr() as u64)), s, "{k:?} round {round}");
            assert_eq!(out[0], e, "{k:?} round {round}");
            assert!(in_jit(&img, f, out[1]), "{k:?}: ran at {:#x}", out[1]);
        }
        if k != Some(3) && std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
            assert_eq!(state(&img, b), JIT_COLD, "{k:?}: bump was inlined, never called from AOT code");
        }
    }
    // f each time, and bump once, called from the AOT loop before the OSR entry.
    check_stats(before, 4);
}

/// A callee whose call of a native function may unwind, inlined at a call site with a
/// catching landing pad: the copied call unwinds to the site's pad. And a callee with a
/// cleanup pad that resumes, inlined at a site without one: the resume continues in the
/// caller's caller.
#[test]
fn inline_landing_pads_and_resume() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    let s_throw = w.symbol("throw", 0);
    let s_del = w.symbol("delete_exc", 0);
    // g(x, log): r = throw(x) + 1; ret r; cleanup pad: log[0] += 1; resume. x@-8, log@-16,
    // r@-24, exc@-32, t@-40.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    let site = a.i(Insn::CallSym { d: Slot(-24), sym: s_throw, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
    a.ret(Slot(-24), 8);
    let pad = a.i(Insn::Lpad { x: Slot(-32) });
    a.i(Insn::LoadW64 { d: Slot(-40), m: Mem { p: Slot(-16), k: 0 } });
    a.i(Insn::AddImmW64 { d: Slot(-40), a: Slot(-40), imm: 1 });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-16), k: 0 }, s: Slot(-40) });
    let r = a.i(Insn::Resume { x: Slot(-32) });
    let mut gd = func(a.done(), 48, 0, 8);
    gd.cleanup = vec![CleanupEntry { offset: site, target: pad }, CleanupEntry { offset: r, target: CONTINUE }];
    let g = w.add_function(gd);
    // h(x): ret throw(x + 1) * 2, no pad of its own. x@-8, r@-16.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    let hs = a.i(Insn::CallSym { d: Slot(-16), sym: s_throw, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-16) });
    a.ret(Slot(-16), 8);
    let mut hd = func(a.done(), 16, 0, 8);
    hd.cleanup = vec![CleanupEntry { offset: hs, target: CONTINUE }];
    let h = w.add_function(hd);
    // mid(x, log): ret g(x, log), no pad: g's resume continues to mid's caller. x@-8, log@-16, r@-24.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    let ms = a.i(Insn::Call { d: Slot(-24), f: g, k: 8, a: List::from_words(&regs(&[-8, -16])) });
    a.ret(Slot(-24), 8);
    let mut md = func(a.done(), 32, 0, 8);
    md.cleanup = vec![CleanupEntry { offset: ms, target: CONTINUE }];
    let mid = w.add_function(md);
    // f(x, log, out): out[0] = where it runs; v = h(x); w = mid(x, log); ret v + w; catching
    // pad around both: delete; ret 1000. x@-8, log@-16, out@-24, v@-32, w@-40, exc@-48,
    // tmp@-56.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-16), s: Slot(24) });
    a.i(Insn::MovW64 { d: Slot(-24), s: Slot(32) });
    where_at(&mut a, s_ret, -56, -24, 0);
    let s1 = a.i(Insn::Call { d: Slot(-32), f: h, k: 8, a: List::from_words(&regs(&[-8])) });
    let s2 = a.i(Insn::Call { d: Slot(-40), f: mid, k: 8, a: List::from_words(&regs(&[-8, -16])) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-32) });
    a.ret(Slot(-40), 8);
    let pad = a.i(Insn::Lpad { x: Slot(-48) });
    a.i(Insn::CallSym { d: Slot(0), sym: s_del, k: 0, a: List::from_words(&regs(&[-48])) });
    a.i(Insn::ImmW64 { d: Slot(-40), imm: 1000 });
    a.ret(Slot(-40), 8);
    let mut fd = func(a.done(), 64, 24, 8);
    fd.cleanup = vec![CleanupEntry { offset: s1, target: pad | CATCH }, CleanupEntry { offset: s2, target: pad | CATCH }];
    let f = w.add_function(fd);
    let img = build(w, &syms());

    // Through the catching pad: h's throw (x = 6), and g's (x = 7) after g's cleanup and
    // resume, which continue through mid's frame (inlined into f, or compiled on its own).
    for round in 0..3 {
        let mut log = [0u64; 1];
        let mut out = [0u64; 1];
        let mut run = |x: u64, log: &mut [u64; 1]| ok::<_, u64>(img.id(f), (x, log.as_mut_ptr() as u64, out.as_mut_ptr() as u64));
        let del = DELETED.load(SeqCst);
        assert_eq!(run(5, &mut log), 12 + 6, "round {round}");
        assert_eq!(run(6, &mut log), 1000, "round {round}");
        assert_eq!((log[0], DELETED.load(SeqCst)), (0, del + 1), "round {round}");
        assert_eq!(run(7, &mut log), 1000, "round {round}");
        assert_eq!((log[0], DELETED.load(SeqCst)), (1, del + 2), "round {round}");
        assert!(in_jit(&img, f, out[0]), "ran at {:#x}", out[0]);
    }
    // f, and g, which has a resume and so isn't inlined where it would unwind to f's pad.
    check_stats(before, 2);
}

/// Recursion and nested callees with allocas of their own: `rec` calls itself (never inlined
/// into itself) and `sq`, which passes its own local's address to `bump`, both inlined into
/// `rec`, so that `sq`'s alloca is promoted inside `rec`'s unit; and `rec` entered both from
/// its entry and in the middle of a recursion that started in AOT code.
#[test]
fn inline_recursion_and_callee_allocas() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let mut defs = Defs::default();
    let s_ret = w.symbol("ret_addr", 0);
    let b = defs.add(&mut w, bump(), vec![]);
    // sq(x) = { l = x; bump(&l, x); l } = x * 3 + x. x@-8, l@-16, p@-24, r@-32.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(Insn::MovW64 { d: Slot(-16), s: Slot(-8) });
    let at_addr = a.i(Insn::Addr { d: Slot(-24), s: Slot(-16) });
    a.i(Insn::Call { d: Slot(-32), f: b, k: 8, a: List::from_words(&regs(&[-24, -8])) });
    a.ret(Slot(-16), 8);
    let sq = defs.add(&mut w, func(a.done(), 32, 0, 8), vec![escape(at_addr, -16, 8)]);
    // rec(n, out) = n == 0 ? (out[0] = where it runs; 0) : sq(n) + rec(n - 1, out).
    // n@-8, out@-16, s@-24, m@-32, r@-40, tmp@-48.
    let rec_idx = Func(2);
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    let z = a.i(Insn::BrEqImmW64 { a: Slot(-8), imm: 0, neg: Neg(false), t: Target(0) });
    a.i(Insn::Call { d: Slot(-24), f: sq, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::SubImmW64 { d: Slot(-32), a: Slot(-8), imm: 1 });
    a.i(Insn::Call { d: Slot(-40), f: rec_idx, k: 8, a: List::from_words(&regs(&[-32, -16])) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-24) });
    a.ret(Slot(-40), 8);
    let base = a.pos();
    where_at(&mut a, s_ret, -48, -16, 0);
    a.i(Insn::ImmW64 { d: Slot(-40), imm: 0 });
    a.ret(Slot(-40), 8);
    a.patch(z, "t", base);
    let rec = defs.add(&mut w, func(a.done(), 48, 0, 8), vec![]);
    assert_eq!(rec, rec_idx);
    // top(n, out) = rec(n, out), with stack arguments for the harness. n@16, out@24; r@-8,
    // n'@-16, out'@-24.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-16), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-24), s: Slot(24) });
    a.i(Insn::Call { d: Slot(-8), f: rec, k: 8, a: List::from_words(&regs(&[-16, -24])) });
    a.ret(Slot(-8), 8);
    let top = defs.add(&mut w, func(a.done(), 32, 16, 8), vec![]);
    let img = defs.build(w);

    let want = |n: u64| (1..=n).map(|x| x * 4).sum::<u64>();
    // The first three calls of rec run in AOT code, the fourth trips and compiles it.
    img.trip_after(rec, 3, 0);
    for n in [10u64, 0, 1, 25] {
        let mut out = [0u64; 1];
        assert_eq!(ok::<_, u64>(img.id(top), (n, out.as_mut_ptr() as u64)), want(n), "n = {n}");
        assert!(in_jit(&img, rec, out[0]) || in_jit(&img, top, out[0]), "n = {n}: the base case ran at {:#x}", out[0]);
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img, b), JIT_COLD, "bump inlined");
    }
    // top, rec, and sq, called from rec's AOT code before rec tripped (bump inlined into
    // both).
    check_stats(before, 3);
}

/// A callee with two calls that may unwind, inlined at a site with a catching landing pad,
/// so that the pad's stub has two invokes, and a caller local written by the callee between
/// them and read in the pad: it can't become a stub parameter, so it stays in memory.
#[test]
fn inline_two_unwinding_calls_into_one_pad() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let mut defs = Defs::default();
    let s_throw = w.symbol("throw", 0);
    let s_del = w.symbol("delete_exc", 0);
    // g(p, x): *p = 1; throw(x); *p = 2; throw(x + 1); ret 0. p@-8, x@-16, one@-24, r@-32.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    a.i(Insn::ImmW64 { d: Slot(-24), imm: 1 });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-8), k: 0 }, s: Slot(-24) });
    let c1 = a.i(Insn::CallSym { d: Slot(-32), sym: s_throw, k: 8, a: List::from_words(&regs(&[-16])) });
    a.i(Insn::ImmW64 { d: Slot(-24), imm: 2 });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-8), k: 0 }, s: Slot(-24) });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    let c2 = a.i(Insn::CallSym { d: Slot(-32), sym: s_throw, k: 8, a: List::from_words(&regs(&[-16])) });
    a.i(Insn::ImmW64 { d: Slot(-32), imm: 0 });
    a.ret(Slot(-32), 8);
    let mut gd = func(a.done(), 32, 0, 8);
    gd.cleanup = vec![CleanupEntry { offset: c1, target: CONTINUE }, CleanupEntry { offset: c2, target: CONTINUE }];
    let g = defs.add(&mut w, gd, vec![]);
    // f(x): e = 0; g(&e, x); ret e; catching pad: delete; ret e + 1000. x@16; x'@-8, e@-16,
    // p@-24, r@-32, exc@-40.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
    let at_addr = a.i(Insn::Addr { d: Slot(-24), s: Slot(-16) });
    let site = a.i(Insn::Call { d: Slot(-32), f: g, k: 8, a: List::from_words(&regs(&[-24, -8])) });
    a.ret(Slot(-16), 8);
    let pad = a.i(Insn::Lpad { x: Slot(-40) });
    a.i(Insn::CallSym { d: Slot(0), sym: s_del, k: 0, a: List::from_words(&regs(&[-40])) });
    a.i(Insn::AddImmW64 { d: Slot(-32), a: Slot(-16), imm: 1000 });
    a.ret(Slot(-32), 8);
    let mut fd = func(a.done(), 48, 8, 8);
    fd.cleanup = vec![CleanupEntry { offset: site, target: pad | CATCH }];
    let f = defs.add(&mut w, fd, vec![escape(at_addr, -16, 8)]);
    let img = defs.build(w);

    for round in 0..3 {
        assert_eq!(ok::<_, u64>(img.id(f), (0u64,)), 2, "round {round}");
        assert_eq!(ok::<_, u64>(img.id(f), (7u64,)), 1001, "round {round}");
        assert_eq!(ok::<_, u64>(img.id(f), (6u64,)), 1002, "round {round}");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img, g), JIT_COLD, "g inlined");
    }
    check_stats(before, 1);
}

/// A call in code that an earlier splice made unreachable: `leaf` has no call that unwinds,
/// so inlining it at `f`'s only unwinding site drops `f`'s cleanup pad, and with it the call
/// of `bump` there, which was also selected for inlining (as `Vec::extend_with`'s
/// `SetLenOnDrop` drop in its pad). The SSA tier must compile `f`.
#[test]
fn inline_call_in_a_pruned_pad() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let mut defs = Defs::default();
    // leaf(x) = x + 1. x@-8.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    a.ret(Slot(-8), 8);
    let leaf = defs.add(&mut w, func(a.done(), 16, 0, 8), vec![]);
    // bump(p): *p += 1. p@-8, t@-16.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(Insn::LoadW64 { d: Slot(-16), m: Mem { p: Slot(-8), k: 0 } });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-8), k: 0 }, s: Slot(-16) });
    a.ret(Slot(-16), 8);
    let bump = defs.add(&mut w, func(a.done(), 16, 0, 8), vec![]);
    // f(x, log): v = leaf(x); ret v; cleanup pad: bump(log); resume. x@-8, log@-16, v@-24,
    // exc@-32, r@-40.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-16), s: Slot(24) });
    let site = a.i(Insn::Call { d: Slot(-24), f: leaf, k: 8, a: List::from_words(&regs(&[-8])) });
    a.ret(Slot(-24), 8);
    let pad = a.i(Insn::Lpad { x: Slot(-32) });
    let bs = a.i(Insn::Call { d: Slot(-40), f: bump, k: 8, a: List::from_words(&regs(&[-16])) });
    let r = a.i(Insn::Resume { x: Slot(-32) });
    let mut fd = func(a.done(), 48, 16, 8);
    fd.cleanup =
        vec![CleanupEntry { offset: site, target: pad }, CleanupEntry { offset: bs, target: CONTINUE }, CleanupEntry { offset: r, target: CONTINUE }];
    let f = defs.add(&mut w, fd, vec![]);
    let img = defs.build(w);

    for round in 0..3 {
        let mut log = [0u64; 1];
        assert_eq!(ok::<_, u64>(img.id(f), (4u64, log.as_mut_ptr() as u64)), 5, "round {round}");
        assert_eq!(log[0], 0, "round {round}");
    }
    // `f` compiled with `leaf` inlined (a panic would leave `f` in AOT code calling a
    // compiled `leaf`).
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img, leaf), JIT_COLD, "leaf inlined");
    }
    check_stats(before, 1);
}

/// Constant-specialized trials: `pick(mode, x)` branches on `mode`, which its two callers in
/// one unit pass as different constants, and a third passes unknown: each splice uses the
/// IR specialized to its constants (or the general one), and all give `pick`'s results.
#[test]
fn inline_constant_trials() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_mul3 = w.symbol("mul3", 0);
    // pick(mode, x) = mode == 0 ? x + 1 : mode == 1 ? mul3(x) : x * x. mode@-8, x@-16, r@-24.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    let b0 = a.i(Insn::BrEqImmW64 { a: Slot(-8), imm: 0, neg: Neg(false), t: Target(0) });
    let b1 = a.i(Insn::BrEqImmW64 { a: Slot(-8), imm: 1, neg: Neg(false), t: Target(0) });
    a.i(Insn::MulW64 { d: Slot(-24), a: Slot(-16), b: Slot(-16) });
    a.ret(Slot(-24), 8);
    let l0 = a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-16), imm: 1 });
    a.ret(Slot(-24), 8);
    let l1 = a.i(Insn::CallSym { d: Slot(-24), sym: s_mul3, k: 8, a: List::from_words(&regs(&[-16])) });
    a.ret(Slot(-24), 8);
    a.patch(b0, "t", l0);
    a.patch(b1, "t", l1);
    let pick = w.add_function(func(a.done(), 32, 0, 8));
    // f(x, m) = pick(0, x) + pick(1, x) + pick(m, x). x@16, m@24; x'@-8, zero@-16, one@-24,
    // m'@-32, r@-40, t@-48.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-32), s: Slot(24) });
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-24), imm: 1 });
    a.i(Insn::Call { d: Slot(-40), f: pick, k: 8, a: List::from_words(&regs(&[-16, -8])) });
    a.i(Insn::Call { d: Slot(-48), f: pick, k: 8, a: List::from_words(&regs(&[-24, -8])) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-48) });
    a.i(Insn::Call { d: Slot(-48), f: pick, k: 8, a: List::from_words(&regs(&[-32, -8])) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-48) });
    a.ret(Slot(-40), 8);
    let f = w.add_function(func(a.done(), 48, 16, 8));
    let img = build(w, &syms());

    let p = |m: u64, x: u64| match m {
        0 => x.wrapping_add(1),
        1 => x.wrapping_mul(3),
        _ => x.wrapping_mul(x),
    };
    for (x, m) in [(5u64, 0u64), (7, 1), (9, 2), (u64::MAX, 7)] {
        assert_eq!(ok::<_, u64>(img.id(f), (x, m)), p(0, x).wrapping_add(p(1, x)).wrapping_add(p(m, x)), "f({x}, {m})");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img, pick), JIT_COLD, "pick inlined");
    }
    check_stats(before, 1);
}

/// `rounds(x)`: `n` rounds of `x = x * 3 + 1` with `x` the first argument, so its IR cost
/// grows with `n`. x@-8.
fn rounds(n: usize, flags: u8) -> FunctionDef {
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    for _ in 0..n {
        a.i(Insn::MulImmW64 { d: Slot(-8), a: Slot(-8), imm: 3 });
        a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    }
    a.ret(Slot(-8), 8);
    FunctionDef { flags, ..func(a.done(), 16, 0, 8) }
}

fn rounds_value(n: usize, mut x: u64) -> u64 {
    for _ in 0..n {
        x = x.wrapping_mul(3).wrapping_add(1);
    }
    x
}

/// The source attributes ([`ryo_bytecode::image::FUNC_INLINE_ALWAYS`] etc.): `f(x)` calls
/// `g(x)` `reps` times in a loop of `iters`, and `g` is inlined or not as its flags say.
/// Returns whether `g` was inlined (it never ran its own AOT code, so never tripped).
fn inlined_with_flags(n: usize, flags: u8, iters: u64) -> bool {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let g = w.add_function(rounds(n, flags));
    // f(x, iters): s = 0; for i < iters { s += g(x + i) }; ret s. x@16, iters@24; x'@-8,
    // iters'@-16, i@-24, s@-32, t@-40, r@-48.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-16), s: Slot(24) });
    a.i(Insn::ImmW64 { d: Slot(-24), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-32), imm: 0 });
    let head = a.i(Insn::BrLtUW64 { a: Slot(-24), b: Slot(-16), neg: F, t: Target(0) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-8), b: Slot(-24) });
    a.i(Insn::Call { d: Slot(-48), f: g, k: 8, a: List::from_words(&regs(&[-40])) });
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-48) });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", head);
    let done = a.i(Insn::Ret { s: Slot(-32), k: 8 });
    a.patch(head, "t", done);
    let f = w.add_function(func(a.done(), 48, 16, 8));
    let img = build(w, &syms());
    let mut s = 0u64;
    for i in 0..iters {
        s = s.wrapping_add(rounds_value(n, 5 + i));
    }
    assert_eq!(ok::<_, u64>(img.id(f), (5u64, iters)), s, "f with g flags {flags}");
    let inlined = state(&img, g) == JIT_COLD;
    check_stats(before, if inlined { 1 } else { 2 });
    inlined
}

/// `#[inline(always)]` lifts a callee far over the ratio bar; without it, it isn't inlined.
#[test]
fn inline_always_over_the_bar() {
    if std::env::var("RYO_JIT_OPT").is_ok_and(|o| o == "reencode") {
        return;
    }
    assert!(!inlined_with_flags(150, 0, 1), "a large callee without the attribute");
    assert!(inlined_with_flags(150, FUNC_INLINE_ALWAYS, 1), "an inline(always) callee");
}

/// `#[inline(never)]` keeps even a callee small enough to always be inlined out of line.
#[test]
fn inline_never_under_the_always_cost() {
    if std::env::var("RYO_JIT_OPT").is_ok_and(|o| o == "reencode") {
        return;
    }
    assert!(inlined_with_flags(1, 0, 3), "a tiny callee");
    assert!(!inlined_with_flags(1, FUNC_INLINE_NEVER, 3), "an inline(never) callee");
}

/// A `#[cold]` callee is weighted as a cold block's call (and the profile doesn't raise it):
/// a callee inlined in a loop isn't once it is cold.
#[test]
fn inline_cold_callee_in_a_loop() {
    if std::env::var("RYO_JIT_OPT").is_ok_and(|o| o == "reencode") {
        return;
    }
    assert!(inlined_with_flags(12, 0, 50), "a medium callee in a loop");
    assert!(!inlined_with_flags(12, FUNC_COLD, 50), "a cold callee in a loop");
}

/// A call between the caller's stores of stack arguments and their call: `r` stores `h`'s
/// stack argument, then calls `g`, whose own call of `h` stores to its outgoing area. Inlined,
/// `g`'s outgoing area would be `r`'s, so `g` is not inlined there (inline.rs
/// `outgoing_pending`): `r(x)` stays `g(x) + h(x)`, `3x + 200`.
#[test]
fn inline_not_between_stack_arguments_and_their_call() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    // h(x) = x + 100, x a stack argument. r@-8.
    let mut a = Asm::new();
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(16), imm: 100 });
    a.ret(Slot(-8), 8);
    let h = w.add_function(func(a.done(), 16, 8, 8));
    // g(y) = h(2y). y@-8, h's argument@-16.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-8), b: Slot(-8) });
    a.i(Insn::Call { d: Slot(-8), f: h, k: 8, a: List::from_words(&[]) });
    a.ret(Slot(-8), 8);
    let g = w.add_function(func(a.done(), 16, 0, 8));
    // r(x) = g(x) + h(x), h's argument stored before g's call. x@16; x'@-8, g's result@-16,
    // h's@-24, h's argument@-32.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-32), s: Slot(-8) });
    a.i(Insn::Call { d: Slot(-16), f: g, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::Call { d: Slot(-24), f: h, k: 8, a: List::from_words(&[]) });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-24) });
    a.ret(Slot(-16), 8);
    let r = w.add_function(func(a.done(), 32, 8, 8));
    let img = build(w, &syms());

    for x in [1u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img.id(r), (x,)), 3 * x + 200, "r({x})");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_ne!(state(&img, g), JIT_COLD, "g not inlined into r");
    }
    let _ = h;
    check_stats(before, 3);
}

/// A callee that returns its result pointer (like an sret function) at a call site that
/// doesn't use it: the extra return part is dropped and the callee is still inlined.
#[test]
fn inline_callee_returning_unused_part() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let mut defs = Defs::default();
    // init(p, x): *p = 3x; ret p. p@-8, x@-16, t@-24.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    a.i(Insn::MulImmW64 { d: Slot(-24), a: Slot(-16), imm: 3 });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-8), k: 0 }, s: Slot(-24) });
    a.ret(Slot(-8), 8);
    let init = defs.add(&mut w, func(a.done(), 32, 0, 8), vec![]);
    // f(x): init(&e, x) with no result; ret e + 1. x@16; x'@-8, e@-16, p@-24, r@-32.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    let at_addr = a.i(Insn::Addr { d: Slot(-24), s: Slot(-16) });
    a.i(Insn::Call { d: Slot(0), f: init, k: 0, a: List::from_words(&regs(&[-24, -8])) });
    a.i(Insn::AddImmW64 { d: Slot(-32), a: Slot(-16), imm: 1 });
    a.ret(Slot(-32), 8);
    let f = defs.add(&mut w, func(a.done(), 32, 8, 8), vec![escape(at_addr, -16, 8)]);
    let img = defs.build(w);

    for x in [1u64, 5, 1 << 40, u64::MAX] {
        assert_eq!(ok::<_, u64>(img.id(f), (x,)), x.wrapping_mul(3).wrapping_add(1), "f({x})");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img, init), JIT_COLD, "init inlined");
    }
    check_stats(before, 1);
}

/// Block copies past 64 bytes (a 72-byte struct moved through temporaries, as
/// `build_hasher` does): done as loads and stores up to `MAX_COPY` (128), through the
/// handler past it. f(x, out): a[i] = x + i; b = a; [out] = b; ret b[8].
#[test]
fn large_block_copies() {
    let (_g, before) = start();
    for len in [72u32, 128, 136] {
        let mut w = ImageWriter::new(unique_scid());
        let words = len as i32 / 8;
        // x@16, out@24; x'@-8, out'@-16, a@-16-len, b@-16-2len.
        let (a_at, b_at) = (-16 - len as i32, -16 - 2 * len as i32);
        let mut a = Asm::new();
        a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
        a.i(Insn::MovW64 { d: Slot(-16), s: Slot(24) });
        for i in 0..words {
            a.i(Insn::AddImmW64 { d: Slot(a_at + 8 * i), a: Slot(-8), imm: i as _ });
        }
        a.i(Insn::Copy { d: Slot(b_at), s: Slot(a_at), len });
        a.i(Insn::StoreCopy { m: Mem { p: Slot(-16), k: 0 }, s: Slot(b_at), len });
        a.ret(Slot(b_at + 64), 8);
        let frame = (16 + 2 * len).next_multiple_of(16);
        let f = w.add_function(func(a.done(), frame, 16, 8));
        let img = build(w, &syms());
        for x in [3u64, 1 << 40] {
            let mut out = vec![0u64; words as usize];
            assert_eq!(ok::<_, u64>(img.id(f), (x, out.as_mut_ptr() as u64)), x + 8, "len {len}");
            assert_eq!(out, (0..words as u64).map(|i| x + i).collect::<Vec<_>>(), "len {len}");
        }
    }
    check_stats(before, 3);
}

/// A callee that only works on its caller's local through a pointer (like SipHash's
/// `c_rounds` on the hasher): too big for its call protocol alone, it is inlined for the
/// promotion it enables, the local's loads and stores becoming values.
/// rounds(p): four times, p[j] = p[j] * 3 + j for j < 4. p@-8, t@-16.
/// f(x): s[j] = x + j; rounds(&s); ret s[0] + s[3]. x@16; x'@-8, s@-48, p@-56.
#[test]
fn inline_for_promotion() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let mut defs = Defs::default();
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    for _ in 0..4 {
        for j in 0..4 {
            a.i(Insn::LoadW64 { d: Slot(-16), m: Mem { p: Slot(-8), k: 8 * j } });
            a.i(Insn::MulImmW64 { d: Slot(-16), a: Slot(-16), imm: 3 });
            a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: j as _ });
            a.i(Insn::StoreW64 { m: Mem { p: Slot(-8), k: 8 * j }, s: Slot(-16) });
        }
    }
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
    a.ret(Slot(-16), 8);
    let rounds = defs.add(&mut w, func(a.done(), 16, 0, 8), vec![]);
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    for j in 0..4 {
        a.i(Insn::AddImmW64 { d: Slot(-48 + 8 * j), a: Slot(-8), imm: j as _ });
    }
    let at_addr = a.i(Insn::Addr { d: Slot(-56), s: Slot(-48) });
    a.i(Insn::Call { d: Slot(0), f: rounds, k: 0, a: List::from_words(&regs(&[-56])) });
    a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-48), b: Slot(-24) });
    a.ret(Slot(-8), 8);
    let f = defs.add(&mut w, func(a.done(), 64, 8, 8), vec![escape(at_addr, -48, 32)]);
    let img = defs.build(w);

    let model = |x: u64| {
        let mut s: [u64; 4] = core::array::from_fn(|j| x.wrapping_add(j as u64));
        for _ in 0..4 {
            for (j, v) in s.iter_mut().enumerate() {
                *v = v.wrapping_mul(3).wrapping_add(j as u64);
            }
        }
        s[0].wrapping_add(s[3])
    };
    for x in [1u64, 5, 1 << 40, u64::MAX] {
        assert_eq!(ok::<_, u64>(img.id(f), (x,)), model(x), "f({x})");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img, rounds), JIT_COLD, "rounds inlined");
    }
    check_stats(before, 1);
}

static B_STATIC: AtomicU64 = AtomicU64::new(0);

/// Inlining across images: `f` of image A calls `g` of image B through a symbol slot. `g`,
/// inlined, keeps naming B's things: its data area, its constant, its symbols (a static, and
/// `mul3`) and its function `h`, all in B's terms ([`ryo_bytecode::jit::inline::rebase`]).
#[test]
fn inline_across_images() {
    let (_g, before) = start();
    // Image B. h(x) = 2x. x@-8.
    let mut w = ImageWriter::new(unique_scid());
    let s_mul3 = w.symbol("mul3", 0);
    let s_static = w.symbol("b_static", 0);
    let k = w.add_const(&1000u64.to_le_bytes(), 8, &[]);
    // A pointer to `k`, which the fold reads through (as an address, from image A).
    let kp = w.add_const(&[0; 8], 8, &[AllocReloc { offset: 0, target: AllocTarget::Const(k), addend: 0 }]);
    let data = w.add_data(&[0; 8], 8, &[], &[]);
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(-8) });
    a.ret(Slot(-8), 8);
    let h = w.add_function(func(a.done(), 16, 0, 8));
    // g(x): *data += x; *b_static += 1; ret **kp + mul3(x) + h(x) + *data. x@-8, p@-16, t@-24,
    // r@-32.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(Insn::AddrConst { d: Slot(-16), a: Abs::Data(data) });
    a.i(Insn::LoadW64 { d: Slot(-24), m: Mem { p: Slot(-16), k: 0 } });
    a.i(Insn::AddW64 { d: Slot(-24), a: Slot(-24), b: Slot(-8) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-16), k: 0 }, s: Slot(-24) });
    a.i(Insn::AddrSym { d: Slot(-16), sym: s_static });
    a.i(Insn::LoadW64 { d: Slot(-24), m: Mem { p: Slot(-16), k: 0 } });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-16), k: 0 }, s: Slot(-24) });
    a.i(Insn::AddrConst { d: Slot(-16), a: Abs::Const(kp) });
    a.i(Insn::LoadW64 { d: Slot(-16), m: Mem { p: Slot(-16), k: 0 } });
    a.i(Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-16), k: 0 } });
    a.i(Insn::CallSym { d: Slot(-24), sym: s_mul3, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-24) });
    a.i(Insn::Call { d: Slot(-24), f: h, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-24) });
    a.i(Insn::AddrConst { d: Slot(-16), a: Abs::Data(data) });
    a.i(Insn::LoadW64 { d: Slot(-24), m: Mem { p: Slot(-16), k: 0 } });
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-24) });
    a.ret(Slot(-32), 8);
    let g = w.add_function(func(a.done(), 32, 0, 8));
    let mut sy = syms();
    sy.push(("b_static", &raw const B_STATIC as usize));
    let img_b = build(w, &sy);

    // Image A. f(x) = g(x) + 1, g through a symbol. x@16; x'@-8, r@-16.
    let mut w = ImageWriter::new(unique_scid());
    let s_g = w.symbol("g", 0);
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::CallSym { d: Slot(-16), sym: s_g, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    a.ret(Slot(-16), 8);
    let f = w.add_function(func(a.done(), 16, 8, 8));
    let img_a = build(w, &[("g", img_b.code(g) as usize)]);

    let mut acc = 0u64;
    for (n, x) in [3u64, 10, 1 << 33].into_iter().enumerate() {
        acc = acc.wrapping_add(x);
        let want = 1000u64.wrapping_add(x.wrapping_mul(3)).wrapping_add(x.wrapping_mul(2)).wrapping_add(acc).wrapping_add(1);
        assert_eq!(ok::<_, u64>(img_a.id(f), (x,)), want, "f({x})");
        assert_eq!(B_STATIC.load(SeqCst), n as u64 + 1, "f({x}): b_static");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img_b, g), JIT_COLD, "g inlined into f");
        assert_eq!(state(&img_b, h), JIT_COLD, "h inlined into f");
    }
    check_stats(before, 1);
}

/// An island: `fp[ops[1]] = fp[ops[0]] * 10 + 7` (`ops` points past the count).
extern "C" fn isl_mul10_add7(fp: *mut u8, ops: *const u32) {
    unsafe {
        let at = |k: usize| fp.offset(*ops.add(k) as i32 as isize) as *mut u64;
        *at(1) = (*at(0)).wrapping_mul(10).wrapping_add(7);
    }
}

/// Inlining across images, a callee with an island: `g` of image B runs `isl_mul10_add7`
/// through its own symbol slot; inlined into `f` of image A, the island is called by its
/// address in A's code (`rebase`), with the island ABI.
#[test]
fn inline_island_across_images() {
    let (_g, before) = start();
    // Image B. g(x) = isl(x) + 1. x@-8, r@-16.
    let mut w = ImageWriter::new(unique_scid());
    let mut defs = Defs::default();
    let s_isl = w.symbol("isl", 0);
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    let at = a.i(Insn::Island { isl: s_isl, ops: List::from_words(&[-8i32 as u32, -16i32 as u32]) });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    a.ret(Slot(-16), 8);
    // The operands' extents (`Lend` scopes), as the backend gives them.
    let lend = |off| Scope { code_offset: at, frame_offset: off, size: 8, kind: ScopeKind::Lend };
    let g = defs.add(&mut w, func(a.done(), 16, 0, 8), vec![lend(-8), lend(-16)]);
    let img_b = defs.build(w);

    // Image A. f(x) = g(x) * 2, g through a symbol. x@16; x'@-8, r@-16.
    let mut w = ImageWriter::new(unique_scid());
    let s_g = w.symbol("g", 0);
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::CallSym { d: Slot(-16), sym: s_g, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-16) });
    a.ret(Slot(-16), 8);
    let f = w.add_function(func(a.done(), 16, 8, 8));
    let img_a = build(w, &[("g", img_b.code(g) as usize)]);

    for x in [0u64, 3, 1 << 40] {
        assert_eq!(ok::<_, u64>(img_a.id(f), (x,)), x.wrapping_mul(10).wrapping_add(8).wrapping_mul(2), "f({x})");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img_b, g), JIT_COLD, "g inlined into f");
    }
    check_stats(before, 1);
}

/// Inlining across images, a callee with a sparse switch: `g` of image B's case values are in
/// B's code constants; inlined into `f` of image A, the switch handler gets their address in B
/// (`rebase`).
#[test]
fn inline_sparse_switch_across_images() {
    let (_g, before) = start();
    // Image B. g(x) = switch x { v_i => 100 + i, _ => 99 }. x@-8, r@-16.
    let mut w = ImageWriter::new(unique_scid());
    let vals = [2u64, 17, 1 << 33, 0x1234_5678_9abc_def0, u64::MAX];
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    let cw = list_words(vals.iter().map(|&v| Case64 { value: v, target: Target(0) }));
    let sw = a.i(Insn::SwitchSparseW64 { s: Slot(-8), default: Target(0), cases: List::from_words(&cw) });
    let mut targets = vec![];
    for i in 0..vals.len() {
        targets.push(a.i(Insn::ImmW64 { d: Slot(-16), imm: 100 + i as u64 }));
        a.ret(Slot(-16), 8);
    }
    let d = a.i(Insn::ImmW64 { d: Slot(-16), imm: 99 });
    a.patch(sw, "default", d);
    a.ret(Slot(-16), 8);
    let mut code = a.done();
    let ew = cw.len() / vals.len();
    let base = sw as usize + ryo_bytecode::full::off::SwitchSparseW64::cases + 1;
    for (i, t) in targets.iter().enumerate() {
        code[base + i * ew + ew - 1] = t.wrapping_sub(sw);
    }
    let g = w.add_function(func(code, 16, 0, 8));
    let img_b = build(w, &syms());

    // Image A. f(x) = g(x) + 1, g through a symbol. x@16; x'@-8, r@-16.
    let mut w = ImageWriter::new(unique_scid());
    let s_g = w.symbol("g", 0);
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::CallSym { d: Slot(-16), sym: s_g, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    a.ret(Slot(-16), 8);
    let f = w.add_function(func(a.done(), 16, 8, 8));
    let img_a = build(w, &[("g", img_b.code(g) as usize)]);

    let mut probes: Vec<u64> = vals.to_vec();
    probes.extend([0, 3, 18, 1 << 32, u64::MAX - 1]);
    for x in probes {
        let want = vals.iter().position(|&v| v == x).map_or(99, |i| 100 + i as u64) + 1;
        assert_eq!(ok::<_, u64>(img_a.id(f), (x,)), want, "f({x:#x})");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img_b, g), JIT_COLD, "g inlined into f");
    }
    check_stats(before, 1);
}

/// The import slot `call.sym.ind` loads `mul3` through (as PE's `__imp_mul3`).
static MUL3_IMP: AtomicU64 = AtomicU64::new(0);

/// Inlining across images, a callee calling through a symbol's pointer (PE's `__imp_`
/// form): `g` of image B calls `mul3` through `MUL3_IMP`; inlined into `f` of image A, the
/// call loads the pointer from the slot's address and calls it (`rebase`).
#[test]
fn inline_indirect_symbol_call_across_images() {
    let (_g, before) = start();
    MUL3_IMP.store(mul3 as *const () as u64, SeqCst);
    // Image B. g(x) = mul3(x) + 1, through the slot's pointer. x@-8, r@-16.
    let mut w = ImageWriter::new(unique_scid());
    let s_imp = w.symbol("mul3_imp", ryo_bytecode::image::SYM_INDIRECT);
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(Insn::CallSymInd { d: Slot(-16), sym: s_imp, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    a.ret(Slot(-16), 8);
    let g = w.add_function(func(a.done(), 16, 0, 8));
    let mut sy = syms();
    sy.push(("mul3_imp", &raw const MUL3_IMP as usize));
    let img_b = build(w, &sy);

    // Image A. f(x) = g(x) * 2, g through a symbol. x@16; x'@-8, r@-16.
    let mut w = ImageWriter::new(unique_scid());
    let s_g = w.symbol("g", 0);
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::CallSym { d: Slot(-16), sym: s_g, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-16) });
    a.ret(Slot(-16), 8);
    let f = w.add_function(func(a.done(), 16, 8, 8));
    let img_a = build(w, &[("g", img_b.code(g) as usize)]);

    for x in [0u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img_a.id(f), (x,)), x.wrapping_mul(3).wrapping_add(1).wrapping_mul(2), "f({x})");
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img_b, g), JIT_COLD, "g inlined into f");
    }
    check_stats(before, 1);
}

// ---- PE code ----

/// An image's VM code in the PE form, which runs on Linux with Win64 natives (as `jit.rs`'s
/// `pe_code`): only the unwind information differs, which nothing registers off Windows.
const PE: ryo_bytecode::asm::Mode = ryo_bytecode::asm::Mode { pe: true, frame_pointer: true, fp_arg: false, ..ENC };

/// Native, Win64: `note(obs)` as [`note`], keeping `rdi`, `rsi` and `xmm6`–`xmm15` around
/// the SysV Rust code.
#[unsafe(naked)]
extern "C" fn note_pe() {
    core::arch::naked_asm!(
        "push rdi",
        "push rsi",
        "mov rdi, rcx",
        "mov rsi, [rsp + 16]",
        "sub rsp, 168",
        "movdqu [rsp], xmm6",
        "movdqu [rsp + 16], xmm7",
        "movdqu [rsp + 32], xmm8",
        "movdqu [rsp + 48], xmm9",
        "movdqu [rsp + 64], xmm10",
        "movdqu [rsp + 80], xmm11",
        "movdqu [rsp + 96], xmm12",
        "movdqu [rsp + 112], xmm13",
        "movdqu [rsp + 128], xmm14",
        "movdqu [rsp + 144], xmm15",
        "call {note}",
        "movdqu xmm6, [rsp]",
        "movdqu xmm7, [rsp + 16]",
        "movdqu xmm8, [rsp + 32]",
        "movdqu xmm9, [rsp + 48]",
        "movdqu xmm10, [rsp + 64]",
        "movdqu xmm11, [rsp + 80]",
        "movdqu xmm12, [rsp + 96]",
        "movdqu xmm13, [rsp + 112]",
        "movdqu xmm14, [rsp + 128]",
        "movdqu xmm15, [rsp + 144]",
        "add rsp, 168",
        "pop rsi",
        "pop rdi",
        "ret",
        note = sym note_rs,
    )
}

/// Native, Win64: `mix_pe(a, b, c, d, e) = a + 3b + 5c + 7d + 11e`, `e` on the stack past the
/// shadow space. It traps unless `rsp` is 16-aligned at the call, then writes its whole
/// shadow space and every volatile register (`rax`, `rcx`, `rdx`, `r8`–`r11`,
/// `xmm0`–`xmm5`), as a Win64 callee may.
#[unsafe(naked)]
extern "C" fn mix_pe() {
    core::arch::naked_asm!(
        "lea rax, [rsp + 8]",
        "test al, 15",
        "jnz 2f",
        "mov rax, [rsp + 40]",
        "imul rax, rax, 11",
        "imul rdx, rdx, 3",
        "add rax, rdx",
        "imul r8, r8, 5",
        "add rax, r8",
        "imul r9, r9, 7",
        "add rax, r9",
        "add rax, rcx",
        "mov rcx, -1",
        "mov [rsp + 8], rcx",
        "mov [rsp + 16], rcx",
        "mov [rsp + 24], rcx",
        "mov [rsp + 32], rcx",
        "mov rdx, rcx",
        "mov r8, rcx",
        "mov r9, rcx",
        "mov r10, rcx",
        "mov r11, rcx",
        "pcmpeqd xmm0, xmm0",
        "pcmpeqd xmm1, xmm1",
        "pcmpeqd xmm2, xmm2",
        "pcmpeqd xmm3, xmm3",
        "pcmpeqd xmm4, xmm4",
        "pcmpeqd xmm5, xmm5",
        "ret",
        "2: ud2",
    )
}

fn mix_rs(a: u64, b: u64, c: u64, d: u64, e: u64) -> u64 {
    a.wrapping_add(b.wrapping_mul(3)).wrapping_add(c.wrapping_mul(5)).wrapping_add(d.wrapping_mul(7)).wrapping_add(e.wrapping_mul(11))
}

/// Calls the VM function at `code` as a Win64 caller: 32 bytes of shadow space (filled with
/// garbage) and the stack arguments `a`, `b` after it, or with `in_home` in its first two
/// slots; every callee-saved register of Win64 (and `r12`, which holds `regs`, of SysV) set
/// to a known value, then stored in `regs`: `rbx rbp rdi rsi r13 r14 r15`, then the low
/// halves of `xmm6`–`xmm15`.
#[unsafe(naked)]
extern "sysv64" fn call_checked_pe(code: *const u8, a: u64, b: u64, regs: *mut [u64; 17], in_home: u64) -> u64 {
    core::arch::naked_asm!(
        "push rbp",
        "push rbx",
        "push r12",
        "push r13",
        "push r14",
        "push r15",
        "mov r12, rcx",
        "mov rax, rdi",
        "sub rsp, 56",
        "mov rcx, -1",
        "mov [rsp], rcx",
        "mov [rsp + 8], rcx",
        "mov [rsp + 16], rcx",
        "mov [rsp + 24], rcx",
        "test r8, r8",
        "jz 2f",
        "mov [rsp], rsi",
        "mov [rsp + 8], rdx",
        "jmp 3f",
        "2:",
        "mov [rsp + 32], rsi",
        "mov [rsp + 40], rdx",
        "3:",
        "movabs rcx, 0x0606060606060606",
        "movq xmm6, rcx",
        "movabs rcx, 0x0707070707070707",
        "movq xmm7, rcx",
        "movabs rcx, 0x0808080808080808",
        "movq xmm8, rcx",
        "movabs rcx, 0x0909090909090909",
        "movq xmm9, rcx",
        "movabs rcx, 0x0a0a0a0a0a0a0a0a",
        "movq xmm10, rcx",
        "movabs rcx, 0x0b0b0b0b0b0b0b0b",
        "movq xmm11, rcx",
        "movabs rcx, 0x0c0c0c0c0c0c0c0c",
        "movq xmm12, rcx",
        "movabs rcx, 0x0d0d0d0d0d0d0d0d",
        "movq xmm13, rcx",
        "movabs rcx, 0x0e0e0e0e0e0e0e0e",
        "movq xmm14, rcx",
        "movabs rcx, 0x0f0f0f0f0f0f0f0f",
        "movq xmm15, rcx",
        "movabs rbx, 0x1111111111111111",
        "movabs rbp, 0x2222222222222222",
        "movabs rdi, 0x3333333333333333",
        "movabs rsi, 0x4444444444444444",
        "movabs r13, 0x5555555555555555",
        "movabs r14, 0x6666666666666666",
        "movabs r15, 0x7777777777777777",
        "call rax",
        "mov [r12], rbx",
        "mov [r12 + 8], rbp",
        "mov [r12 + 16], rdi",
        "mov [r12 + 24], rsi",
        "mov [r12 + 32], r13",
        "mov [r12 + 40], r14",
        "mov [r12 + 48], r15",
        "movq [r12 + 56], xmm6",
        "movq [r12 + 64], xmm7",
        "movq [r12 + 72], xmm8",
        "movq [r12 + 80], xmm9",
        "movq [r12 + 88], xmm10",
        "movq [r12 + 96], xmm11",
        "movq [r12 + 104], xmm12",
        "movq [r12 + 112], xmm13",
        "movq [r12 + 120], xmm14",
        "movq [r12 + 128], xmm15",
        "add rsp, 56",
        "pop r15",
        "pop r14",
        "pop r13",
        "pop r12",
        "pop rbx",
        "pop rbp",
        "ret",
    )
}

/// Where a PE frame's saves go ([`pe_frames`]).
#[derive(Clone, Copy, Debug, PartialEq)]
enum PeSaves {
    /// Pushed: nothing pinned.
    Pushed,
    /// Below pinned allocas (an 8 KiB one, so the frame probes), in the caller's home space.
    Home,
    /// The same with the arguments read from the home space: in the slots below `rdi`'s and
    /// `rsi`'s that no pinned alloca covers.
    Gap,
}

/// PE code through the SSA tier: a loop with values live across a Win64 native call (five
/// arguments, the fifth on the stack past the shadow space, which the callee overwrites, as
/// it does every volatile register), entered at the entry and by OSR, with and without
/// shuffled frames, with the saves pushed, in the home space and in the slots below `rdi`'s
/// and `rsi`'s. The results are the AOT code's, the code ran in the JIT code, and every
/// callee-saved register of Win64, `xmm6`–`xmm15` included, survives.
#[test]
fn pe_frames() {
    let (_g, before) = start();
    let mut n_compiled = 0;
    for saves in [PeSaves::Pushed, PeSaves::Home, PeSaves::Gap] {
        for shuffle in [false, true] {
            for k in [None, Some(0i64), Some(3)] {
                pe_frames_at(saves, shuffle, k);
                n_compiled += 1;
            }
        }
    }
    check_stats(before, n_compiled);
}

fn pe_frames_at(saves: PeSaves, shuffle: bool, k: Option<i64>) {
    let what = format!("{saves:?}, shuffle {shuffle}, osr at {k:?}");
    let big = saves != PeSaves::Pushed;
    let mut w = ImageWriter::new(unique_scid());
    let s_note = w.symbol("note_pe", 0);
    let s_mix = w.symbol("mix_pe", 0);
    let mut defs = Defs::default();
    let (n, obs) = if saves == PeSaves::Gap { (16, 24) } else { (48, 56) };
    let frame: u32 = if big { 8192 + 64 } else { 128 };
    let stack5 = -(frame as i32) + 32;
    // f(n, obs): i, acc, v1, v2, v3 = 0, 1, 7, 11, 13; (big: e = 5, p = &e, q = &big) for i < n
    // { (big: *q = acc) r = mix(i, acc, v1, v2, v3); (big: acc = *q + *p) acc = acc * 3 + r;
    // v1 += i; v2 += 3; v3 *= 5; i += 1 }; ret acc + v1 + v2 + v3.
    // i@-24, acc@-32, v1@-40, v2@-48, v3@-56, e@-64, p@-72, q@-80, r@-88, t@-96 (big).
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(0), sym: s_note, k: 0, a: List::from_words(&regs(&[obs])) });
    a.i(Insn::ImmW64 { d: Slot(-24), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-32), imm: 1 });
    a.i(Insn::ImmW64 { d: Slot(-40), imm: 7 });
    a.i(Insn::ImmW64 { d: Slot(-48), imm: 11 });
    a.i(Insn::ImmW64 { d: Slot(-56), imm: 13 });
    let mut scopes = Vec::new();
    if big {
        a.i(Insn::ImmW64 { d: Slot(-64), imm: 5 });
        let at = a.i(Insn::Addr { d: Slot(-72), s: Slot(-64) });
        scopes.push(escape(at, -64, 8));
        let at = a.i(Insn::Addr { d: Slot(-80), s: Slot(-8192) });
        scopes.push(escape(at, -8192, 8000));
    }
    let head = a.i(Insn::BrLtUW64 { a: Slot(-24), b: Slot(n), neg: F, t: Target(0) });
    if big {
        a.i(Insn::StoreW64 { m: Mem { p: Slot(-80), k: 0 }, s: Slot(-32) });
    }
    a.i(Insn::MovW64 { d: Slot(stack5), s: Slot(-56) });
    a.i(Insn::CallSym { d: Slot(-88), sym: s_mix, k: 8, a: List::from_words(&regs(&[-24, -32, -40, -48])) });
    if big {
        a.i(Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-80), k: 0 } });
        a.i(Insn::LoadW64 { d: Slot(-96), m: Mem { p: Slot(-72), k: 0 } });
        a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-96) });
    }
    a.i(Insn::MulImmW64 { d: Slot(-32), a: Slot(-32), imm: 3 });
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-88) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-24) });
    a.i(Insn::AddImmW64 { d: Slot(-48), a: Slot(-48), imm: 3 });
    a.i(Insn::MulImmW64 { d: Slot(-56), a: Slot(-56), imm: 5 });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", head);
    let done = a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-40) });
    a.patch(head, "t", done);
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-48) });
    a.i(Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-56) });
    a.i(Insn::CallSym { d: Slot(0), sym: s_note, k: 0, a: List::from_words(&regs(&[obs])) });
    a.ret(Slot(-32), 8);
    let f = defs.add(&mut w, func(a.done(), frame, 16, 8), scopes);
    w.prepare(PE);
    w.validate_functions().unwrap();
    let enc = defs.0.iter().map(|(f, sc)| ryo_bytecode::asm::encode(&f.code, f.frame_size, &f.cleanup, sc, PE).unwrap()).collect();
    let mut obj = w.finish_encoded(enc).unwrap();
    // Off Windows nothing reads `.pdata` and `.xdata`.
    obj.relocs.retain(|r| r.kind != ryo_bytecode::image::RelocKind::Rva32);
    obj.unwind.clear();
    let img = link(obj, &[("note_pe", note_pe as *const () as usize), ("mix_pe", mix_pe as *const () as usize)]);
    if shuffle {
        ryo_rt::vm::jit_shuffle_image(img.header);
    }
    register(&[&img]);

    let nv = 20u64;
    let (mut acc, mut v1, mut v2, mut v3) = (1u64, 7u64, 11u64, 13u64);
    for i in 0..nv {
        let r = mix_rs(i, acc, v1, v2, v3);
        if big {
            acc = acc.wrapping_add(5);
        }
        acc = acc.wrapping_mul(3).wrapping_add(r);
        v1 = v1.wrapping_add(i);
        v2 = v2.wrapping_add(3);
        v3 = v3.wrapping_mul(5);
    }
    let want = acc.wrapping_add(v1).wrapping_add(v2).wrapping_add(v3);
    if let Some(k) = k {
        img.trip_after(f, 1, k);
    }
    let mut saved = [
        0x1111111111111111u64,
        0x2222222222222222,
        0x3333333333333333,
        0x4444444444444444,
        0x5555555555555555,
        0x6666666666666666,
        0x7777777777777777,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    ];
    for x in 6..16u64 {
        saved[x as usize + 1] = x * 0x0101010101010101;
    }
    for call in 0..2 {
        let o_ = Obs::default();
        let mut regs = [0u64; 17];
        let got = call_checked_pe(img.code(f), nv, &raw const o_ as u64, &mut regs, (saves == PeSaves::Gap) as u64);
        assert_eq!(got, want, "{what}, call {call}");
        // The first call's trip into the JIT is Linux code: it keeps only the SysV registers.
        let n = if call == 0 { 7 } else { 17 };
        assert_eq!(regs[..n], saved[..n], "{what}, call {call}: callee-saved registers");
        assert_eq!(state(&img, f), JIT_DONE, "{what}");
        assert!(in_jit(&img, f, o(&o_.last)), "{what}, call {call}: ended at {:#x}", o(&o_.last));
        if call == 0 && k.is_some() {
            assert!(in_aot(&img, f, o(&o_.first)), "{what}: started at {:#x}", o(&o_.first));
        } else {
            assert!(in_jit(&img, f, o(&o_.first)), "{what}, call {call}: started at {:#x}", o(&o_.first));
        }
    }
}

/// PE vectors through the SSA tier: ten vectors live around a loop, enough to take
/// `xmm6`–`xmm13` (and the scratch `xmm14`, `xmm15`), which the prologue saves for the Win64
/// caller and the OSR entries save as they find them, entered at the entry and by OSR. The
/// results are the AOT code's, and every callee-saved register of Win64 survives.
/// f(pa, n): v_i = pa[16i..] for i < 10, d = 0; for j < n { for i < 10 { d = xor(d, v_i);
/// d = or(d, veq(d, v_((i + 3) % 10))); d = xor(d, vlt.s(v_i, d)) } }; ret vmsb(d).
#[test]
fn pe_vectors() {
    let (_g, before) = start();
    let mut n_compiled = 0;
    for k in [None, Some(0i64), Some(3)] {
        pe_vectors_at(k);
        n_compiled += 1;
    }
    check_stats(before, n_compiled);
}

fn pe_vectors_at(k: Option<i64>) {
    let what = format!("osr at {k:?}");
    let mut w = ImageWriter::new(unique_scid());
    let mut defs = Defs::default();
    let v = |i: i32| Slot(-32 - 16 * i);
    let (d, t, j, m, x) = (Slot(-192), Slot(-208), Slot(-216), Slot(-224), Slot(-232));
    let mut a = Asm::new();
    for i in 0..10 {
        a.i(Insn::LoadCopy { d: v(i), m: Mem { p: Slot(48), k: 16 * i }, len: 16 });
    }
    a.i(Insn::Zero { d, len: 16 });
    a.i(Insn::ImmW64 { d: j, imm: 0 });
    let head = a.i(Insn::BrLtUW64 { a: j, b: Slot(56), neg: F, t: Target(0) });
    for i in 0..10 {
        a.i(Insn::XorW128 { d, a: d, b: v(i) });
        a.i(Insn::VeqI8x16 { d: t, a: d, b: v((i + 3) % 10) });
        a.i(Insn::OrW128 { d, a: d, b: t });
        a.i(Insn::VltSI8x16 { d: t, a: v(i), b: d });
        a.i(Insn::XorW128 { d, a: d, b: t });
    }
    a.i(Insn::AddImmW64 { d: j, a: j, imm: 1 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", head);
    let done = a.i(Insn::VmsbI8x16 { d: m, a: d });
    a.patch(head, "t", done);
    a.i(Insn::ZextW16W64 { d: x, s: m });
    a.ret(x, 8);
    let f = defs.add(&mut w, func(a.done(), 256, 16, 8), vec![]);
    w.prepare(PE);
    w.validate_functions().unwrap();
    let enc = defs.0.iter().map(|(f, sc)| ryo_bytecode::asm::encode(&f.code, f.frame_size, &f.cleanup, sc, PE).unwrap()).collect();
    let mut obj = w.finish_encoded(enc).unwrap();
    // Off Windows nothing reads `.pdata` and `.xdata`.
    obj.relocs.retain(|r| r.kind != ryo_bytecode::image::RelocKind::Rva32);
    obj.unwind.clear();
    let img = link(obj, &[]);
    register(&[&img]);

    let vs = simd_vectors();
    let buf: Vec<u8> = (0..10).flat_map(|i| vs[(3 * i + 1) % vs.len()]).collect();
    let n = 7u64;
    let mut saved = [
        0x1111111111111111u64,
        0x2222222222222222,
        0x3333333333333333,
        0x4444444444444444,
        0x5555555555555555,
        0x6666666666666666,
        0x7777777777777777,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    ];
    for x in 6..16u64 {
        saved[x as usize + 1] = x * 0x0101010101010101;
    }
    // The AOT code first: no trips.
    img.set_counters(f, -(1 << 40), -(1 << 40));
    let mut regs = [0u64; 17];
    let want = call_checked_pe(img.code(f), buf.as_ptr() as u64, n, &mut regs, 0);
    assert_eq!(regs, saved, "{what}: AOT: callee-saved registers");
    match k {
        None => img.trip_after(f, 0, 0),
        Some(k) => img.trip_after(f, 1, k),
    }
    for call in 0..2 {
        let mut regs = [0u64; 17];
        let got = call_checked_pe(img.code(f), buf.as_ptr() as u64, n, &mut regs, 0);
        assert_eq!(got, want, "{what}, call {call}");
        // The first call's trip into the JIT is Linux code: it keeps only the SysV registers.
        let nr = if call == 0 { 7 } else { 17 };
        assert_eq!(regs[..nr], saved[..nr], "{what}, call {call}: callee-saved registers");
        assert_eq!(state(&img, f), JIT_DONE, "{what}");
    }
}

/// Loads from the constant pool, which the SSA tier folds: a vtable-like constant's function
/// pointer (called through), its pointer to a string (read through), its plain field, a
/// partial read of a pointer field (which stays a load), and a 16-byte `const` copy of a
/// `(len, ptr)` pair whose second word is relocated. The data area's value, written by
/// native code between calls, is read anew each time.
/// f(x, out): out[0..2] = pair; out[2] = low half of vt.str; data[0] += 1;
/// ret mul3(x) + vt.str[0] + vt.n + data[0]. x@16, out@24; x'@-8, p@-16, q@-24, t@-32,
/// r@-40, pair@-56.
#[test]
fn constant_pool_loads() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let s_mul3 = w.symbol("mul3", 0);
    let s = w.add_const(b"hello, world!\0\0\0", 8, &[]);
    let mut vt = [0u8; 24];
    vt[16..].copy_from_slice(&77u64.to_le_bytes());
    let vt = w.add_const(
        &vt,
        8,
        &[
            AllocReloc { offset: 0, target: AllocTarget::Symbol(s_mul3), addend: 0 },
            AllocReloc { offset: 8, target: AllocTarget::Const(s), addend: 7 },
        ],
    );
    let mut pair = [0u8; 16];
    pair[..8].copy_from_slice(&5u64.to_le_bytes());
    let pair = w.add_const(&pair, 8, &[AllocReloc { offset: 8, target: AllocTarget::Const(s), addend: 0 }]);
    let data = w.add_data(&[0; 8], 8, &[], &[]);
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::Const { d: Slot(-56), k: pair, len: 16 });
    a.i(Insn::StoreCopy { m: Mem { p: Slot(24), k: 0 }, s: Slot(-56), len: 16 });
    a.i(Insn::AddrConst { d: Slot(-16), a: Abs::Const(vt) });
    a.i(Insn::LoadW32 { d: Slot(-32), m: Mem { p: Slot(-16), k: 8 } });
    a.i(Insn::ZextW32W64 { d: Slot(-32), s: Slot(-32) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 16 }, s: Slot(-32) });
    a.i(Insn::LoadW64 { d: Slot(-24), m: Mem { p: Slot(-16), k: 0 } });
    a.i(Insn::CallPtr { d: Slot(-40), p: Slot(-24), k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::LoadW64 { d: Slot(-24), m: Mem { p: Slot(-16), k: 8 } });
    a.i(Insn::LoadW8 { d: Slot(-32), m: Mem { p: Slot(-24), k: 0 } });
    a.i(Insn::ZextW8W64 { d: Slot(-32), s: Slot(-32) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-32) });
    a.i(Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-16), k: 16 } });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-32) });
    a.i(Insn::AddrConst { d: Slot(-16), a: Abs::Data(data) });
    a.i(Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-16), k: 0 } });
    a.i(Insn::AddImmW64 { d: Slot(-32), a: Slot(-32), imm: 1 });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-16), k: 0 }, s: Slot(-32) });
    a.i(Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-32) });
    a.ret(Slot(-40), 8);
    let f = w.add_function(func(a.done(), 64, 16, 8));
    let img = build(w, &syms());
    let pool = unsafe { Image::from_header(img.header) }.unwrap().consts().as_ptr() as u64;
    let s_addr = pool + s.0 as u64;
    for (n, x) in [3u64, 1 << 40, 9].into_iter().enumerate() {
        // Native code changes the data area between the calls.
        unsafe { *img.data.add(data.0 as usize).cast::<u64>() += 100 };
        let mut out = [0u64; 3];
        let r = ok::<_, u64>(img.id(f), (x, out.as_mut_ptr() as u64));
        let d = (n as u64 + 1) * 101;
        assert_eq!(r, x.wrapping_mul(3) + b'w' as u64 + 77 + d, "f({x})");
        assert_eq!(out, [5, s_addr, (s_addr + 7) as u32 as u64], "f({x})");
    }
    check_stats(before, 1);
}

/// How many calls through constant pointers the SSA tier made direct in its roots since
/// `before` (none through re-encoding).
fn devirt_since(before: usize) -> usize {
    ryo_jit::ssa_devirt() - before
}

fn ssa() -> bool {
    std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode")
}

/// A function calling `g(x)` through `p` (`p` set up by `setup`, which gets the slot):
/// f(x) = g(x) + 1. x@16 (an entry function's) or in a register; x'@-8, p@-16, r@-24.
fn call_through_by(reg: bool, setup: impl FnOnce(&mut Asm, i32)) -> FunctionDef {
    let mut a = Asm::new();
    a.i(if reg { arg(-8, 0) } else { Insn::MovW64 { d: Slot(-8), s: Slot(16) } });
    setup(&mut a, -16);
    a.i(Insn::CallPtr { d: Slot(-24), p: Slot(-16), k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
    a.ret(Slot(-24), 8);
    func(a.done(), 32, if reg { 0 } else { 8 }, 8)
}

fn call_through(setup: impl FnOnce(&mut Asm, i32)) -> FunctionDef {
    call_through_by(false, setup)
}

/// A vtable-like constant of 48 bytes whose word at `at` relocates to symbol `s` (plus
/// `addend`), the others plain.
fn vtable(w: &mut ImageWriter, s: Sym, at: u32, addend: i64) -> Const {
    let mut vt = [0u8; 48];
    vt[..8].copy_from_slice(&99u64.to_le_bytes());
    w.add_const(&vt, 8, &[AllocReloc { offset: at, target: AllocTarget::Symbol(s), addend }])
}

/// Devirtualization (`jit::inline::devirt`): a call through a symbol's value
/// (`addr.sym; call.ptr`) and through a function pointer loaded from the constant pool
/// become direct calls of the image's function `g`, and `g`, small, is inlined; a tail call
/// through a symbol's value becomes a direct one.
#[test]
fn devirt_symbol_and_pool_pointer() {
    let (_g, before) = start();
    let d0 = ryo_jit::ssa_devirt();
    let mut w = ImageWriter::new(unique_scid());
    let gd = rounds(1, 0);
    let s_g = w.symbol(&gd.name.clone(), 0);
    let g = w.add_function(gd);
    let vt = vtable(&mut w, s_g, 32, 0);
    let f1 = w.add_function(call_through(|a, p| {
        a.i(Insn::AddrSym { d: Slot(p), sym: s_g });
    }));
    let f2 = w.add_function(call_through(|a, p| {
        a.i(Insn::AddrConst { d: Slot(p), a: Abs::Const(vt) });
        a.i(Insn::LoadW64 { d: Slot(p), m: Mem { p: Slot(p), k: 32 } });
    }));
    // f3(x) = become g(x) through the symbol's value. x@16; p@-8.
    let mut a = Asm::new();
    a.i(Insn::AddrSym { d: Slot(-8), sym: s_g });
    a.i(Insn::TailCallPtr { p: Slot(-8), a: List::from_words(&regs(&[16])) });
    let f3 = w.add_function(func(a.done(), 16, 8, 8));
    let img = build(w, &syms());
    for x in [0u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img.id(f1), (x,)), rounds_value(1, x) + 1, "f1({x})");
        assert_eq!(ok::<_, u64>(img.id(f2), (x,)), rounds_value(1, x) + 1, "f2({x})");
    }
    if ssa() {
        assert_eq!(state(&img, g), JIT_COLD, "g inlined into f1 and f2");
        assert_eq!(devirt_since(d0), 2, "calls made direct");
    }
    for x in [0u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img.id(f3), (x,)), rounds_value(1, x), "f3({x})");
    }
    if ssa() {
        assert_eq!(devirt_since(d0), 3, "calls made direct");
    }
    check_stats(before, 4);
}

/// An `#[inline(never)]` target is called directly, not inlined; another image's function
/// is called by the JIT's call form and inlined (rebased); a target that isn't a VM
/// function's entry (a native, or an address inside a function's code) stays an indirect call.
#[test]
fn devirt_targets() {
    let (_g, before) = start();
    let d0 = ryo_jit::ssa_devirt();
    // Image B: g(x) = 3x + 1.
    let mut w = ImageWriter::new(unique_scid());
    let gb = w.add_function(rounds(1, 0));
    let img_b = build(w, &syms());

    let mut w = ImageWriter::new(unique_scid());
    let nd = rounds(1, FUNC_INLINE_NEVER);
    let s_n = w.symbol(&nd.name.clone(), 0);
    let n = w.add_function(nd);
    let s_gb = w.symbol("gb", 0);
    let s_mul3 = w.symbol("mul3", 0);
    let vt_n = vtable(&mut w, s_n, 8, 0);
    let vt_gb = vtable(&mut w, s_gb, 16, 0);
    let vt_mul3 = vtable(&mut w, s_mul3, 24, 0);
    let vt_inside = vtable(&mut w, s_n, 32, 1);
    let through = |vt: Const, at: i32| {
        call_through(move |a, p| {
            a.i(Insn::AddrConst { d: Slot(p), a: Abs::Const(vt) });
            a.i(Insn::LoadW64 { d: Slot(p), m: Mem { p: Slot(p), k: at } });
        })
    };
    let f_n = w.add_function(through(vt_n, 8));
    let f_gb = w.add_function(through(vt_gb, 16));
    let f_mul3 = w.add_function(through(vt_mul3, 24));
    // f_inside(x) = x == 0 ? (*vt_inside[32])(x) : x. The pointer is `n`'s entry + 1, never
    // called. x@16; p@-8, r@-16.
    let mut a = Asm::new();
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
    let br = a.i(Insn::BrEqW64 { a: Slot(16), b: Slot(-16), neg: Neg(false), t: Target(0) });
    a.ret(Slot(16), 8);
    let at = a.i(Insn::AddrConst { d: Slot(-8), a: Abs::Const(vt_inside) });
    a.patch(br, "t", at);
    a.i(Insn::LoadW64 { d: Slot(-8), m: Mem { p: Slot(-8), k: 32 } });
    a.i(Insn::CallPtr { d: Slot(-16), p: Slot(-8), k: 8, a: List::from_words(&regs(&[16])) });
    a.ret(Slot(-16), 8);
    let f_inside = w.add_function(func(a.done(), 16, 8, 8));
    let mut sy = syms();
    sy.push(("gb", img_b.code(gb) as usize));
    let img = build(w, &sy);

    for x in [1u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img.id(f_n), (x,)), rounds_value(1, x) + 1, "f_n({x})");
        assert_eq!(ok::<_, u64>(img.id(f_gb), (x,)), rounds_value(1, x) + 1, "f_gb({x})");
        assert_eq!(ok::<_, u64>(img.id(f_mul3), (x,)), x.wrapping_mul(3) + 1, "f_mul3({x})");
        assert_eq!(ok::<_, u64>(img.id(f_inside), (x,)), x, "f_inside({x})");
    }
    if ssa() {
        assert_ne!(state(&img, n), JIT_COLD, "n, inline(never), called");
        assert_eq!(state(&img_b, gb), JIT_COLD, "B's g inlined into f_gb");
        assert_eq!(devirt_since(d0), 2, "calls made direct: f_n's and f_gb's");
    }
    // f_n, f_gb, f_mul3, f_inside and n.
    check_stats(before, 5);
}

/// The same code in two images whose vtable slot relocates to an external symbol, resolved
/// to a native in one and to a VM function in the other: each image's unit calls its own
/// target. And a function of image B that calls through its own vtable, inlined into a unit
/// of image A (rebased, its copy made direct to B's function), keeps its indirect call in the
/// IR cache: B's own unit, inlining it later, gets it from there and makes it direct itself.
#[test]
fn devirt_per_image_and_cache() {
    let (_g, before) = start();
    let d0 = ryo_jit::ssa_devirt();
    // Image B: g(x) = 3x + 1; h(x) = vt[40](x) + 1 (g); k(x) = h(x) + 1.
    let mut w = ImageWriter::new(unique_scid());
    let gd = rounds(1, 0);
    let s_g = w.symbol(&gd.name.clone(), 0);
    let g = w.add_function(gd);
    let vt = vtable(&mut w, s_g, 40, 0);
    let hd = call_through_by(true, |a, p| {
        a.i(Insn::AddrConst { d: Slot(p), a: Abs::Const(vt) });
        a.i(Insn::LoadW64 { d: Slot(p), m: Mem { p: Slot(p), k: 40 } });
    });
    let h = w.add_function(hd);
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::Call { d: Slot(-16), f: h, k: 8, a: List::from_words(&regs(&[-8])) });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    a.ret(Slot(-16), 8);
    let k = w.add_function(func(a.done(), 16, 8, 8));
    let img_b = build(w, &syms());

    // Images A1 and A2: f(x) = vt[16](x) + 1 with vt[16] = `tgt`; u(x) = B's h(x) + 1.
    let image_a = |tgt: usize| {
        let mut w = ImageWriter::new(unique_scid());
        let s_t = w.symbol("tgt", 0);
        let s_h = w.symbol("h", 0);
        let vt = vtable(&mut w, s_t, 16, 0);
        let f = w.add_function(call_through(|a, p| {
            a.i(Insn::AddrConst { d: Slot(p), a: Abs::Const(vt) });
            a.i(Insn::LoadW64 { d: Slot(p), m: Mem { p: Slot(p), k: 16 } });
        }));
        let mut a = Asm::new();
        a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
        a.i(Insn::CallSym { d: Slot(-16), sym: s_h, k: 8, a: List::from_words(&regs(&[-8])) });
        a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
        a.ret(Slot(-16), 8);
        let u = w.add_function(func(a.done(), 16, 8, 8));
        let mut sy = syms();
        sy.push(("tgt", tgt));
        sy.push(("h", img_b.code(h) as usize));
        (build(w, &sy), f, u)
    };
    let (a1, f1, u1) = image_a(mul3 as *const () as usize);
    let (a2, f2, _) = image_a(img_b.code(g) as usize);
    for x in [1u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(a1.id(f1), (x,)), x.wrapping_mul(3) + 1, "A1 f({x})");
        assert_eq!(ok::<_, u64>(a2.id(f2), (x,)), rounds_value(1, x) + 1, "A2 f({x})");
    }
    if ssa() {
        assert_eq!(devirt_since(d0), 1, "only A2's call made direct");
    }
    for x in [1u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(a1.id(u1), (x,)), rounds_value(1, x) + 2, "A1 u({x})");
        assert_eq!(ok::<_, u64>(img_b.id(k), (x,)), rounds_value(1, x) + 2, "B k({x})");
    }
    if ssa() {
        assert_eq!(state(&img_b, h), JIT_COLD, "h inlined into u and k");
        assert_eq!(state(&img_b, g), JIT_COLD, "g inlined into A2's f, u and k");
    }
    // A1's f, A2's f, u, k.
    check_stats(before, 4);
}

/// `v(p, x) = (*(p + at))(p?, x) + 1`, register arguments: a callee taking the vtable as a
/// parameter (hashmap's `find_inner`), passing it on as the first argument if `pass`. p@-8,
/// x@-16, q@-24, r@-32.
fn through_param(at: i32, pass: bool) -> FunctionDef {
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    a.i(Insn::LoadW64 { d: Slot(-24), m: Mem { p: Slot(-8), k: at } });
    let args: &[i32] = if pass { &[-8, -16] } else { &[-16] };
    a.i(Insn::CallPtr { d: Slot(-32), p: Slot(-24), k: 8, a: List::from_words(&regs(args)) });
    a.i(Insn::AddImmW64 { d: Slot(-32), a: Slot(-32), imm: 1 });
    a.ret(Slot(-32), 8);
    func(a.done(), 32, 0, 8)
}

/// The second inlining round: the vtable reaches the call through it only once its callee
/// is inlined (hashmap's `find::<C>`), so the call becomes direct after the first round and
/// the second one inlines its target. A call the second round exposes becomes direct but
/// isn't inlined: there is no third round.
#[test]
fn devirt_second_round() {
    let (_g, before) = start();
    let d0 = ryo_jit::ssa_devirt();
    let mut w = ImageWriter::new(unique_scid());
    // g(x) = 3x + 1; g2(x) = (3x + 1) * 3 + 1; g3(p, x) = g2 through p[40] + 1.
    let gd = rounds(1, 0);
    let s_g = w.symbol(&gd.name.clone(), 0);
    let g = w.add_function(gd);
    let g2d = rounds(2, 0);
    let s_g2 = w.symbol(&g2d.name.clone(), 0);
    let g2 = w.add_function(g2d);
    let g3d = through_param(40, false);
    let s_g3 = w.symbol(&g3d.name.clone(), 0);
    let g3 = w.add_function(g3d);
    let sym = |s: Sym, offset: u32| AllocReloc { offset, target: AllocTarget::Symbol(s), addend: 0 };
    let vt = w.add_const(&[0; 56], 8, &[sym(s_g, 32), sym(s_g2, 40), sym(s_g3, 48)]);
    let inner = w.add_function(through_param(32, false));
    let inner3 = w.add_function(through_param(48, true));
    // f(x) = v(vt, x) + 1. x@16; p@-8, x'@-16, r@-24.
    let root = |v: Func| {
        let mut a = Asm::new();
        a.i(Insn::AddrConst { d: Slot(-8), a: Abs::Const(vt) });
        a.i(Insn::MovW64 { d: Slot(-16), s: Slot(16) });
        a.i(Insn::Call { d: Slot(-24), f: v, k: 8, a: List::from_words(&regs(&[-8, -16])) });
        a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
        a.ret(Slot(-24), 8);
        func(a.done(), 32, 8, 8)
    };
    let f = w.add_function(root(inner));
    let f3 = w.add_function(root(inner3));
    let img = build(w, &syms());
    for x in [1u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img.id(f), (x,)), rounds_value(1, x) + 2, "f({x})");
    }
    if ssa() {
        assert_eq!(state(&img, inner), JIT_COLD, "inner inlined");
        assert_eq!(state(&img, g), JIT_COLD, "g inlined in the second round");
        assert_eq!(devirt_since(d0), 1, "f's call made direct");
    }
    for x in [1u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img.id(f3), (x,)), rounds_value(2, x) + 3, "f3({x})");
    }
    if ssa() {
        assert_eq!(state(&img, g3), JIT_COLD, "g3 inlined in the second round");
        assert_ne!(state(&img, g2), JIT_COLD, "g2 called: no third round");
        assert_eq!(devirt_since(d0), 3, "f3's two calls made direct");
    }
    // f, f3, g2.
    check_stats(before, 3);
}

/// `_mm_movemask_epi8(_mm_cmpeq_epi8(load(p), _mm_set1_epi8(tag)))` as one VM function,
/// inlined into its caller: the vectors promoted, the operations native SSE2.
#[test]
fn inline_simd_handlers() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let mut defs = Defs::default();
    let s_ret = w.symbol("ret_addr", 0);
    // eqmask(p, tag): v@-48 (16), t@-64 (16), m@-72 (2), r@-80.
    let mut a = Asm::new();
    a.i(arg(-8, 0));
    a.i(arg(-16, 1));
    a.i(Insn::LoadCopy { d: Slot(-48), m: Mem { p: Slot(-8), k: 0 }, len: 16 });
    a.i(Insn::VsplatI8x16 { d: Slot(-64), s: Slot(-16) });
    a.i(Insn::VeqI8x16 { d: Slot(-64), a: Slot(-48), b: Slot(-64) });
    a.i(Insn::VmsbI8x16 { d: Slot(-72), a: Slot(-64) });
    a.i(Insn::ZextW16W64 { d: Slot(-80), s: Slot(-72) });
    a.ret(Slot(-80), 8);
    let e = defs.add(&mut w, func(a.done(), 80, 0, 8), vec![]);
    // f(p, tag, out): r = eqmask(p, tag); out[0] = where it runs; ret r. p@16, tag@24,
    // out@32 (copied to -8, -16, -24); r@-32, tmp@-40.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-16), s: Slot(24) });
    a.i(Insn::MovW64 { d: Slot(-24), s: Slot(32) });
    a.i(Insn::Call { d: Slot(-32), f: e, k: 8, a: List::from_words(&regs(&[-8, -16])) });
    where_at(&mut a, s_ret, -40, -24, 0);
    a.ret(Slot(-32), 8);
    let f = defs.add(&mut w, func(a.done(), 48, 24, 8), vec![]);
    let img = defs.build(w);
    let bytes: [u8; 16] = [7, 0x80, 7, 1, 0xff, 7, 7, 0, 3, 7, 0x7f, 7, 7, 7, 0, 7];
    for tag in [7u8, 0x80, 0, 0x55] {
        let want = bytes.iter().enumerate().filter(|&(_, &c)| c == tag).map(|(i, _)| 1u64 << i).sum::<u64>();
        let mut out = [0u64; 1];
        assert_eq!(ok::<_, u64>(img.id(f), (bytes.as_ptr() as u64, tag as u64, out.as_mut_ptr() as u64)), want, "tag {tag}");
        assert!(in_jit(&img, f, out[0]), "ran at {:#x}", out[0]);
    }
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(state(&img, e), JIT_COLD, "eqmask was inlined, never called");
    }
    check_stats(before, 1);
}

/// The SIMD test inputs: vectors of edge lanes (0x00, 0x01, 0x7f, 0x80, 0x81, 0xfe, 0xff) and
/// pseudo-random ones.
fn simd_vectors() -> Vec<[u8; 16]> {
    const EDGES: [u8; 7] = [0x00, 0x01, 0x7f, 0x80, 0x81, 0xfe, 0xff];
    let mut v = Vec::new();
    for (k, &e) in EDGES.iter().enumerate() {
        v.push([e; 16]);
        let mut x = [EDGES[(k + 2) % 7]; 16];
        x[k * 2] = e;
        x[15 - k] = e;
        v.push(x);
    }
    let mut s = 0x2545_f491_4f6c_dd1du64;
    for _ in 0..16 {
        let mut x = [0; 16];
        for c in x.chunks_mut(8) {
            s ^= s << 13;
            s ^= s >> 7;
            s ^= s << 17;
            c.copy_from_slice(&s.to_le_bytes());
        }
        v.push(x);
    }
    v
}

/// The SIMD cases: each a function `f(pa, pb, out, obs)` (pa@16, pb@24, out@32, obs@40) that
/// loads `a` (at -32) and `b` (at -48) from `pa` and `pb`, computes, and stores 16 bytes to
/// `out`. `t`@-64, `d`@-80, the mask `m`@-88, byte `s`@-96, `x`@-104, `i`@-112, `p`@-120.
#[derive(Clone, Copy, Debug, PartialEq)]
enum SimdCase {
    Splat,
    Eq,
    Lt,
    Msb,
    And,
    Or,
    Xor,
    /// `vmsb(vlt.s(a, 0))`.
    Movemask,
    /// `veq(a, vsplat(pb[0]))`.
    EqSplat,
    /// Vectors live across a call (spilled).
    AcrossCall,
    /// Operations on a constant splat.
    Constants,
    /// `d = or(xor(d, vsplat(pa[i])), veq(d, b))` for `i < 16`: a vector live around a loop.
    Loop,
}

fn simd_fn(c: SimdCase, s_note: Sym, s_mul3: Sym) -> FunctionDef {
    use SimdCase::*;
    let sl = Slot;
    let (a_, b_, t, d, m, s, x, i, p) = (sl(-32), sl(-48), sl(-64), sl(-80), sl(-88), sl(-96), sl(-104), sl(-112), sl(-120));
    let mut a = Asm::new();
    note_call(&mut a, s_note, 40);
    a.i(Insn::LoadCopy { d: a_, m: Mem { p: Slot(16), k: 0 }, len: 16 });
    a.i(Insn::LoadCopy { d: b_, m: Mem { p: Slot(24), k: 0 }, len: 16 });
    let mask = |a: &mut Asm, from: Slot| {
        a.i(Insn::VmsbI8x16 { d: m, a: from });
        a.i(Insn::ZextW16W64 { d: x, s: m });
        a.i(Insn::Zero { d, len: 16 });
        a.i(Insn::MovW64 { d, s: x });
    };
    match c {
        Splat => {
            a.i(Insn::LoadW8 { d: s, m: Mem { p: Slot(24), k: 3 } });
            a.i(Insn::VsplatI8x16 { d, s });
        }
        Eq => {
            a.i(Insn::VeqI8x16 { d, a: a_, b: b_ });
        }
        Lt => {
            a.i(Insn::VltSI8x16 { d, a: a_, b: b_ });
        }
        Msb => mask(&mut a, a_),
        And => {
            a.i(Insn::AndW128 { d, a: a_, b: b_ });
        }
        Or => {
            a.i(Insn::OrW128 { d, a: a_, b: b_ });
        }
        Xor => {
            a.i(Insn::XorW128 { d, a: a_, b: b_ });
        }
        Movemask => {
            a.i(Insn::Zero { d: t, len: 16 });
            a.i(Insn::VltSI8x16 { d: t, a: a_, b: t });
            mask(&mut a, t);
        }
        EqSplat => {
            a.i(Insn::LoadW8 { d: s, m: Mem { p: Slot(24), k: 0 } });
            a.i(Insn::VsplatI8x16 { d: t, s });
            a.i(Insn::VeqI8x16 { d, a: a_, b: t });
        }
        AcrossCall => {
            a.i(Insn::VeqI8x16 { d: t, a: a_, b: b_ });
            a.i(Insn::ImmW64 { d: i, imm: 5 });
            a.i(Insn::CallSym { d: x, sym: s_mul3, k: 8, a: List::from_words(&regs(&[-112])) });
            a.i(Insn::VltSI8x16 { d, a: t, b: a_ });
            a.i(Insn::XorW128 { d, a: d, b: b_ });
            // The call's result in the first lane.
            a.i(Insn::MovW8 { d: Slot(-80), s: x });
        }
        Constants => {
            a.i(Insn::ImmW8 { d: s, imm: 0x81 });
            a.i(Insn::VsplatI8x16 { d: t, s });
            a.i(Insn::VltSI8x16 { d, a: t, b: a_ });
            a.i(Insn::XorW128 { d, a: d, b: t });
            a.i(Insn::VmsbI8x16 { d: m, a: t });
            a.i(Insn::MovW16 { d: Slot(-80), s: m });
        }
        Loop => {
            a.i(Insn::Zero { d, len: 16 });
            a.i(Insn::MovW64 { d: p, s: Slot(16) });
            a.i(Insn::ImmW64 { d: i, imm: 0 });
            let head = a.i(Insn::BrLtUImmW64 { a: i, imm: 16, neg: F, t: Target(0) });
            a.i(Insn::LoadW8 { d: s, m: Mem { p, k: 0 } });
            a.i(Insn::VsplatI8x16 { d: t, s });
            a.i(Insn::XorW128 { d, a: d, b: t });
            a.i(Insn::VeqI8x16 { d: t, a: d, b: b_ });
            a.i(Insn::OrW128 { d, a: d, b: t });
            a.i(Insn::AddImmW64 { d: p, a: p, imm: 1 });
            a.i(Insn::AddImmW64 { d: i, a: i, imm: 1 });
            let back = a.i(Insn::Jmp { t: Target(0) });
            a.patch(back, "t", head);
            let done = a.pos();
            a.patch(head, "t", done);
        }
    }
    a.i(Insn::StoreCopy { m: Mem { p: Slot(32), k: 0 }, s: d, len: 16 });
    note_call(&mut a, s_note, 40);
    a.i(Insn::Ret { s: Slot(0), k: 0 });
    func(a.done(), 128, 32, 0)
}

/// Every SIMD instruction and fold, compiled natively by the SSA tier, against the handlers
/// the AOT code calls: each case on edge-lane and random vectors at every misalignment, the
/// loop also entered by OSR at several head passes.
#[test]
fn simd_against_handlers() {
    use SimdCase::*;
    let (_g, before) = start();
    let vs = simd_vectors();
    let mut buf = [0u8; 64];
    let mut compiled = 0;
    let cases = [Splat, Eq, Lt, Msb, And, Or, Xor, Movemask, EqSplat, AcrossCall, Constants, Loop];
    for c in cases {
        // The loop: compiled at the entry, and by OSR after 0, 3 and 15 head passes.
        let trips: &[Option<i64>] = if c == Loop { &[None, Some(0), Some(3), Some(15)] } else { &[None] };
        for &k in trips {
            let mut w = ImageWriter::new(unique_scid());
            let s_note = w.symbol("note", 0);
            let s_mul3 = w.symbol("mul3", 0);
            let mut defs = Defs::default();
            let f = defs.add(&mut w, simd_fn(c, s_note, s_mul3), vec![]);
            let img = defs.build(w);
            let run = |i: usize| -> ([u8; 16], Obs) {
                let (x, y) = (vs[i], vs[(i * 5 + 3) % vs.len()]);
                let off = i % 16;
                let mut buf = buf;
                buf[off..off + 16].copy_from_slice(&x);
                buf[32 + (15 - off)..48 + (15 - off)].copy_from_slice(&y);
                let mut out = [0u8; 16];
                let obs = Obs::default();
                let pa = buf[off..].as_ptr() as u64;
                let pb = buf[32 + (15 - off)..].as_ptr() as u64;
                ok::<_, ()>(img.id(f), (pa, pb, out.as_mut_ptr() as u64, &raw const obs as u64));
                (out, obs)
            };
            // The AOT code (its handlers) first: no trips.
            img.set_counters(f, -(1 << 40), -(1 << 40));
            let want: Vec<[u8; 16]> = (0..vs.len()).map(|i| run(i).0).collect();
            match k {
                None => img.trip_after(f, 0, 0),
                Some(k) => img.trip_after(f, 1, k),
            }
            for i in 0..vs.len() {
                let (got, obs) = run(i);
                let what = format!("{c:?} (trip {k:?}) on {:x?}, {:x?}", vs[i], vs[(i * 5 + 3) % vs.len()]);
                assert_eq!(got, want[i], "{what}");
                assert!(in_jit(&img, f, o(&obs.last)), "{what}: ended at {:#x}", o(&obs.last));
                if i == 0 && k.is_some() {
                    assert!(in_aot(&img, f, o(&obs.first)), "{what}: started at {:#x}", o(&obs.first));
                }
            }
            compiled += 1;
        }
        buf.iter_mut().for_each(|b| *b = b.wrapping_add(0x5b));
    }
    check_stats(before, compiled);
}

/// What the instruction `op` (`d, a, b` or `d, a`, up to 64 bits) leaves in a zeroed 8-byte
/// `d` on the 8-byte slots `a` and `b`, by its definition (design/instructions.md).
fn model(op: Opcode, a: u64, b: u64) -> u64 {
    let m = op.mnemonic();
    let parts: Vec<&str> = m.split('.').collect();
    let n: u32 = parts.last().unwrap()[1..].parse().unwrap();
    let mask = |x: u64| if n == 64 { x } else { x & ((1 << n) - 1) };
    let sx = |x: u64| ((x << (64 - n)) as i64) >> (64 - n);
    let (a, b) = (mask(a), mask(b));
    let k = (b % n as u64) as u32;
    // A byte, -1 to 1.
    if parts[0] == "cmp3" {
        let o = if parts[1] == "s" { sx(a).cmp(&sx(b)) } else { a.cmp(&b) };
        return o as i8 as u8 as u64;
    }
    mask(match (parts[0], parts.get(1).copied()) {
        ("shl", _) => a << k,
        ("shr", Some("u")) => a >> k,
        ("shr", _) => (sx(a) >> k) as u64,
        ("rotl", _) if k == 0 => a,
        ("rotl", _) => a << k | a >> (n - k),
        ("rotr", _) if k == 0 => a,
        ("rotr", _) => a >> k | a << (n - k),
        ("bswap", _) => a.swap_bytes() >> (64 - n),
        ("cttz", _) => (if a == 0 { n } else { a.trailing_zeros() }) as u64,
        ("ctlz", _) => (if a == 0 { n } else { a.leading_zeros() - (64 - n) }) as u64,
        // Below 32 bits in 32, so a signed `MIN / -1` wraps.
        ("div", Some("u")) => a / b,
        ("rem", Some("u")) => a % b,
        ("div", _) => sx(a).wrapping_div(sx(b)) as u64,
        ("rem", _) => sx(a).wrapping_rem(sx(b)) as u64,
        _ => panic!("no model for {m}"),
    })
}

/// Edge-case operand values: around every width's sign bit and all-ones, shift amounts
/// around every width, and a few others.
const EDGES: [u64; 24] = [
    0,
    1,
    2,
    7,
    8,
    9,
    15,
    16,
    17,
    31,
    32,
    33,
    63,
    64,
    65,
    0x80,
    0xff,
    0x8000,
    0xffff,
    0x8000_0000,
    0xffff_ffff,
    1 << 63,
    u64::MAX,
    0x0123_4567_89ab_cdef,
];

/// Each of `ops` (`d, a, b`, or `d, a` reading the first) in a function `f(a, b)` that chains six of them, each on the
/// two results before it (so values stay live across them), and returns their xor: in the
/// JIT code, it matches [`model`] on every pair of edge values.
fn chains_match_model(ops: &[Opcode]) {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let mut fs = Vec::new();
    for &op in ops {
        let mut a = Asm::new();
        let slot = |k: usize| if k < 2 { 16 + 8 * k as i32 } else { -8 * (k as i32 - 1) };
        for k in 2..8 {
            a.i(Insn::ImmW64 { d: Slot(slot(k)), imm: 0 });
            let vals = [slot(k) as u32 as u128, slot(k - 2) as u32 as u128, slot(k - 1) as u32 as u128];
            a.raw(op, &vals[..op.info().operands.len()]);
        }
        a.i(Insn::ImmW64 { d: Slot(-56), imm: 0 });
        for k in 2..8 {
            a.i(Insn::XorW64 { d: Slot(-56), a: Slot(-56), b: Slot(slot(k)) });
        }
        a.ret(Slot(-56), 8);
        fs.push(w.add_function(func(a.done(), 64, 16, 8)));
    }
    let img = build(w, &syms());
    for (&op, &f) in ops.iter().zip(&fs) {
        for &x in &EDGES {
            for &y in &EDGES {
                let mut xs = vec![x, y];
                for k in 2..8 {
                    xs.push(model(op, xs[k - 2], xs[k - 1]));
                }
                let want = xs[2..].iter().fold(0, |s, v| s ^ v);
                assert_eq!(ok::<_, u64>(img.id(f), (x, y)), want, "{} on {x:#x}, {y:#x}", op.mnemonic());
            }
        }
    }
    check_stats(before, ops.len());
}

/// Shifts and rotates by a variable amount, at every width: amounts at and past the width.
#[test]
fn variable_shifts_and_rotates() {
    use Opcode::*;
    chains_match_model(&[
        ShlW8, ShlW16, ShlW32, ShlW64, ShrSW8, ShrSW16, ShrSW32, ShrSW64, ShrUW8, ShrUW16, ShrUW32, ShrUW64, RotlW8, RotlW16, RotlW32, RotlW64,
        RotrW8, RotrW16, RotrW32, RotrW64,
    ]);
}

/// `bswap` at 16, 32 and 64 bits.
#[test]
fn byte_swaps() {
    use Opcode::*;
    chains_match_model(&[BswapW16, BswapW32, BswapW64]);
}

/// Each of `ops` (`d, a, b`) in a function `f(a, b)` with `a + b` and `a ^ b` live across
/// it, and with `b` a constant (each of `consts`) in another: in the JIT code, they match
/// [`model`] on the pairs of edge values `defined` accepts.
fn binary_matches_model(ops: &[Opcode], consts: &[u64], defined: impl Fn(Opcode, u64, u64) -> bool) {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let mut fs = Vec::new();
    for &op in ops {
        for c in [None].into_iter().chain(consts.iter().map(Some)) {
            let mut a = Asm::new();
            a.i(Insn::AddW64 { d: Slot(-16), a: Slot(16), b: Slot(24) });
            a.i(Insn::XorW64 { d: Slot(-24), a: Slot(16), b: Slot(24) });
            let b = match c {
                Some(&c) => {
                    a.i(Insn::ImmW64 { d: Slot(-32), imm: c });
                    -32
                }
                None => 24,
            };
            a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
            a.raw(op, &[-8i32 as u32 as u128, 16, b as u32 as u128]);
            a.i(Insn::XorW64 { d: Slot(-8), a: Slot(-8), b: Slot(-16) });
            a.i(Insn::XorW64 { d: Slot(-8), a: Slot(-8), b: Slot(-24) });
            a.ret(Slot(-8), 8);
            fs.push((op, c.copied(), w.add_function(func(a.done(), 32, 16, 8))));
        }
    }
    let img = build(w, &syms());
    for &(op, c, f) in &fs {
        for &x in &EDGES {
            for &y in &EDGES {
                let y = c.unwrap_or(y);
                if !defined(op, x, y) {
                    continue;
                }
                let want = model(op, x, y) ^ x.wrapping_add(y) ^ x ^ y;
                assert_eq!(ok::<_, u64>(img.id(f), (x, y)), want, "{} on {x:#x}, {y:#x}", op.mnemonic());
            }
        }
    }
    check_stats(before, fs.len());
}

/// Division and remainder at every width, signed or not, by a variable and by constants:
/// but for a zero divisor and a 32- or 64-bit signed `MIN / -1`, which fault.
#[test]
fn division() {
    use Opcode::*;
    let ops =
        [DivSW8, DivSW16, DivSW32, DivSW64, DivUW8, DivUW16, DivUW32, DivUW64, RemSW8, RemSW16, RemSW32, RemSW64, RemUW8, RemUW16, RemUW32, RemUW64];
    binary_matches_model(&ops, &[3, 7, u64::MAX, 0x8000_0001], |op, a, b| {
        let n: u32 = op.mnemonic().rsplit('.').next().unwrap()[1..].parse().unwrap();
        let mask = if n == 64 { u64::MAX } else { (1 << n) - 1 };
        let signed = op.mnemonic().split('.').nth(1) == Some("s");
        b & mask != 0 && !(signed && n >= 32 && b & mask == mask && a & mask == 1 << (n - 1))
    });
}

/// `cttz` and `ctlz` at every width, zero included.
#[test]
fn bit_counts() {
    use Opcode::*;
    chains_match_model(&[CttzW8, CttzW16, CttzW32, CttzW64, CtlzW8, CtlzW16, CtlzW32, CtlzW64]);
}

/// Dense switches at every width up to 64 bits, with bases that make the index wrap (and a
/// 64-bit one past `i32`): three cases returning `100 + i`, the default 99.
#[test]
fn dense_switch_indices() {
    let (_g, before) = start();
    let mut w = ImageWriter::new(unique_scid());
    let cases: [(u32, Opcode, u64); 6] = [
        (8, Opcode::SwitchDenseW8, 0xfe),
        (16, Opcode::SwitchDenseW16, 0xfffe),
        (32, Opcode::SwitchDenseW32, 7),
        (32, Opcode::SwitchDenseW32, 0),
        (64, Opcode::SwitchDenseW64, 1 << 40),
        (64, Opcode::SwitchDenseW64, u64::MAX - 1),
    ];
    let mut fs = Vec::new();
    for &(_, op, base) in &cases {
        let mut a = Asm::new();
        let tw = [0u32; 3];
        let sw = match op {
            Opcode::SwitchDenseW8 => a.i(Insn::SwitchDenseW8 { s: Slot(16), base: base as u8, default: Target(0), table: List::from_words(&tw) }),
            Opcode::SwitchDenseW16 => a.i(Insn::SwitchDenseW16 { s: Slot(16), base: base as u16, default: Target(0), table: List::from_words(&tw) }),
            Opcode::SwitchDenseW32 => a.i(Insn::SwitchDenseW32 { s: Slot(16), base: base as u32, default: Target(0), table: List::from_words(&tw) }),
            _ => a.i(Insn::SwitchDenseW64 { s: Slot(16), base, default: Target(0), table: List::from_words(&tw) }),
        };
        for i in 0..3 {
            let at = a.i(Insn::ImmW64 { d: Slot(-8), imm: 100 + i as u64 });
            a.patch_list(sw, "table", i, at);
            a.ret(Slot(-8), 8);
        }
        let d = a.i(Insn::ImmW64 { d: Slot(-8), imm: 99 });
        a.patch(sw, "default", d);
        a.ret(Slot(-8), 8);
        fs.push(w.add_function(func(a.done(), 16, 8, 8)));
    }
    let img = build(w, &syms());
    for (&(bits, op, base), &f) in cases.iter().zip(&fs) {
        let mask = if bits == 64 { u64::MAX } else { (1 << bits) - 1 };
        let mut xs: Vec<u64> = (0..6).map(|k| base.wrapping_add(k).wrapping_sub(1)).collect();
        xs.extend(EDGES);
        xs.extend([base | 1 << 63, base.wrapping_add(1 << bits.min(63))]);
        for x in xs {
            let i = x.wrapping_sub(base) & mask;
            let want = if i < 3 { 100 + i } else { 99 };
            assert_eq!(ok::<_, u64>(img.id(f), (x,)), want, "{} base {base:#x} on {x:#x}", op.mnemonic());
        }
    }
    check_stats(before, fs.len());
}

/// `cmp3` at every width, signed or not.
#[test]
fn three_way_compares() {
    use Opcode::*;
    let ops = [Cmp3SW8, Cmp3SW16, Cmp3SW32, Cmp3SW64, Cmp3UW8, Cmp3UW16, Cmp3UW32, Cmp3UW64];
    binary_matches_model(&ops, &[0, 1 << 63, 0x7f], |_, _, _| true);
}
