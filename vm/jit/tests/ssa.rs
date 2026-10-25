//! The JIT's SSA tier (the default, but for `RYO_JIT_OPT=reencode`): hand-assembled
//! functions using switches, tail calls, SSE arguments and results, catching landing pads,
//! large frames and escaped locals across OSR. Each test checks the results, that the code ran in the JIT code, and, in an SSA
//! mode, that every function it compiled went through the tier ([`ryo_jit::ssa_stats`]; a
//! separate test binary, so that the counters are this file's alone).

#![cfg(all(target_arch = "x86_64", target_os = "linux"))]

#[path = "../../rt/tests/common/mod.rs"]
mod common;
use common::*;

use ryo_bytecode::asm::{ArgReg, RetPart, Scope, ScopeKind, ret_kind};
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
    ]
}

/// Whether `addr` is in the JIT code of function `f`.
fn in_jit(img: &Linked, f: Func, addr: u64) -> bool {
    let r = unsafe { &*img.record(f) };
    let start = r.jit_code as u64;
    start != 0 && (start..start + ryo_jit::code_len(r) as u64).contains(&addr)
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
    check_stats(before, 2);
}
