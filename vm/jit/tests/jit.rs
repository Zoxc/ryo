//! The JIT (design/jit.md): hand-assembled functions, linked in memory and registered
//! with every counter at 0 and `RYO_JIT_SYNC`'s waiting ([`ryo_rt::vm::configure_jit`]), so
//! that their first call compiles them and continues in their JIT code. Their results match
//! the AOT code's, with arguments of every kind, through recursion that switches over midway,
//! unwinding with landing pads, calls between JIT and AOT functions, and many threads.

#![cfg(all(target_arch = "x86_64", target_os = "linux"))]
#![feature(unboxed_closures)]

#[path = "../../rt/tests/common/mod.rs"]
mod common;
use common::*;

use std::panic::resume_unwind;
use std::sync::Once;
use std::sync::atomic::AtomicU64;

const T: Neg = Neg(false);
const F: Neg = Neg(true);

/// Every test's first step: the JIT's settings, before the first registration reads them.
fn init() {
    static ONCE: Once = Once::new();
    ONCE.call_once(|| assert!(ryo_rt::vm::configure_jit(true, Some(0)), "the JIT's settings were read already"));
}

/// Native: its own return address, so the VM code calling it learns where it runs.
#[unsafe(naked)]
extern "C" fn ret_addr() -> u64 {
    core::arch::naked_asm!("mov rax, [rsp]", "ret")
}

fn syms() -> Vec<(&'static str, usize)> {
    vec![("ret_addr", ret_addr as *const () as usize), ("boom", boom as *const () as usize), ("note", note as *const () as usize)]
}

/// Native: `note(obs)` records where it was called from, and the caller's `rsp`, in the
/// [`Obs`] at `obs`: the first call's and the last one's.
#[unsafe(naked)]
extern "C" fn note() {
    core::arch::naked_asm!("mov rsi, [rsp]", "lea rdx, [rsp + 8]", "jmp {note}", note = sym note_rs)
}

extern "C" fn note_rs(obs: *mut Obs, ra: u64, sp: u64) {
    let o = unsafe { &*obs };
    use std::sync::atomic::Ordering::SeqCst;
    if o.first.load(SeqCst) == 0 {
        o.first.store(ra, SeqCst);
        o.first_sp.store(sp, SeqCst);
    }
    o.last.store(ra, SeqCst);
    o.last_sp.store(sp, SeqCst);
}

/// What [`note`] records.
#[derive(Default)]
#[repr(C)]
struct Obs {
    first: AtomicU64,
    last: AtomicU64,
    first_sp: AtomicU64,
    last_sp: AtomicU64,
}

/// Whether `addr` is in the JIT code of function `f`.
fn in_jit(img: &Linked, f: Func, addr: u64) -> bool {
    let r = unsafe { &*img.record(f) };
    let start = r.jit_code as u64;
    start != 0 && (start..start + r.jit_len).contains(&addr)
}

/// Whether `addr` is in the AOT code of function `f`.
fn in_aot(img: &Linked, f: Func, addr: u64) -> bool {
    let start = img.code(f) as u64;
    (start..start + img.functions[f.0 as usize].len as u64).contains(&addr)
}

fn state(img: &Linked, f: Func) -> u32 {
    unsafe { (*img.record(f)).state.load(std::sync::atomic::Ordering::Acquire) }
}

#[derive(Debug, PartialEq)]
struct Boom(u64);

fn boom(x: u64) -> u64 {
    if x == 7 {
        resume_unwind(Box::new(Boom(x)))
    }
    x
}

/// Arguments of every kind (integer and SSE registers, the stack, an sret pointer) reach
/// the JIT code intact through the trip, and its results are the AOT code's.
#[test]
fn arguments_and_results() {
    use ryo_bytecode::asm::ArgReg;
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);

    // spill(p, a1..a5, x0..x7, s0, s1) = s0 + s1, storing a1..a5, x0..x7, s0, s1 and where
    // it runs at p[0..16].
    let mut a = Asm::new();
    for i in 0..6 {
        a.i(arg(-8 - 8 * i as i32, i));
    }
    for i in 0..8 {
        a.i(Insn::Arg { d: Slot(-56 - 8 * i as i32), r: ArgReg { xmm: true, size: 8, index: i }.word() });
    }
    a.i(Insn::CallSym { d: Slot(-136), sym: s_ret, k: 8, a: List::from_words(&[]) });
    let mut srcs: Vec<i32> = (1..6).map(|i| -8 - 8 * i).collect();
    srcs.extend((0..8).map(|i| -56 - 8 * i));
    srcs.extend([16, 24, -136]);
    for (k, &s) in srcs.iter().enumerate() {
        a.i(Insn::StoreW64 { m: Mem { p: Slot(-8), k: 8 * k as i32 }, s: Slot(s) });
    }
    a.i(Insn::AddW64 { d: Slot(-128), a: Slot(16), b: Slot(24) });
    a.ret(Slot(-128), 8);
    let spill = w.add_function(func(a.done(), 144, 16, 8));

    // triple(x) = [x, x + 1, x + 2], through the sret pointer.
    let mut a = Asm::new();
    a.sret(Slot(-48));
    a.i(Insn::MovW64 { d: Slot(-32), s: Slot(16) });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(16), imm: 1 });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(16), imm: 2 });
    a.ret(Slot(-32), 24);
    let triple = w.add_function(func(a.done(), 48, 8, 24));

    let img = build(w, &syms());
    type Spill = extern "C" fn(*mut u64, u64, u64, u64, u64, u64, f64, f64, f64, f64, f64, f64, f64, f64, u64, u64) -> u64;
    let f: Spill = unsafe { std::mem::transmute(img.code(spill)) };
    for round in 0..3 {
        let mut out = [0u64; 16];
        let xs: Vec<f64> = (0..8).map(|i| i as f64 + 0.5).collect();
        let r = f(out.as_mut_ptr(), 1, 2, 3, 4, 5, xs[0], xs[1], xs[2], xs[3], xs[4], xs[5], xs[6], xs[7], 1 << 40, 7);
        assert_eq!(r, (1 << 40) + 7);
        let mut want: Vec<u64> = (1..6).collect();
        want.extend(xs.iter().map(|x| x.to_bits()));
        want.extend([1 << 40, 7]);
        assert_eq!(out[..15], want[..], "round {round}");
        assert!(in_jit(&img, spill, out[15]), "round {round}: spill ran at {:#x}", out[15]);
        assert_eq!(state(&img, spill), JIT_DONE);
        assert!(img.counter(spill) < 0);
    }
    for _ in 0..3 {
        assert_eq!(ok::<_, [u64; 3]>(img.id(triple), (5u64,)), [5, 6, 7]);
        assert_eq!(state(&img, triple), JIT_DONE);
    }
}

/// A recursion that starts in AOT code switches over at the call that trips: the frames
/// below run JIT code (its calls of itself go straight to it), and returns go back through
/// both kinds of frames.
#[test]
fn recursion() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // depth(n) = n == 0 ? ret_addr() : depth(n - 1) + 1 - 1, so that every frame does work
    // after the call. n@16, r@-8; the outgoing argument at -32.
    let mut a = Asm::new();
    let b = a.i(Insn::BrEqImmW64 { a: Slot(16), imm: 0, neg: T, t: Target(0) });
    a.i(Insn::SubImmW64 { d: Slot(-32), a: Slot(16), imm: 1 });
    a.i(Insn::Call { d: Slot(-8), f: Func(0), k: 8, a: List::from_words(&[]) });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    a.i(Insn::SubImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    a.ret(Slot(-8), 8);
    let base = a.i(Insn::CallSym { d: Slot(-8), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.ret(Slot(-8), 8);
    a.patch(b, "t", base);
    let depth = w.add_function(func(a.done(), 32, 8, 8));
    let img = build(w, &syms());

    // The first three calls count down in AOT code, the fourth trips.
    img.set_counter(depth, 3 * ryo_bytecode::asm::ENTRY_COUNT as i64);
    let at = ok::<_, u64>(img.id(depth), (10u64,));
    assert!(in_jit(&img, depth, at), "the innermost call ran at {at:#x}");
    // Through the AOT entry, redirected.
    let at = ok::<_, u64>(img.id(depth), (0u64,));
    assert!(in_jit(&img, depth, at));
    let at = ok::<_, u64>(img.id(depth), (1000u64,));
    assert!(in_jit(&img, depth, at));
}

/// Panics unwind through JIT frames, and their landing pads run.
#[test]
fn unwinding() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_boom = w.symbol("boom", 0);
    let s_ret = w.symbol("ret_addr", 0);
    // ub(x, log): log[1] = where it runs; loops i over 0..3 calling boom(x + i); landing
    // pad: log[0] = 42, resume. x@16, log@24, i@-8, t@-16, r@-24, exception@-32, tmp@-40.
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-40), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 8 }, s: Slot(-40) });
    a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
    let head = a.i(Insn::BrLtUImmW64 { a: Slot(-8), imm: 3, neg: F, t: Target(0) });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(16), b: Slot(-8) });
    let site = a.i(Insn::CallSym { d: Slot(-24), sym: s_boom, k: 8, a: List::from_words(&regs(&[-16])) });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", head);
    let done = a.ret(Slot(-24), 8);
    a.patch(head, "t", done);
    let c = a.i(Insn::Lpad { x: Slot(-32) });
    a.i(Insn::ImmW64 { d: Slot(-40), imm: 42 });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-40) });
    let r = a.i(Insn::Resume { x: Slot(-32) });
    let mut f = func(a.done(), 48, 16, 8);
    f.cleanup = vec![CleanupEntry { offset: site, target: c }, CleanupEntry { offset: r, target: CONTINUE }];
    let ub = w.add_function(f);
    let img = build(w, &syms());

    for _ in 0..3 {
        let mut log = [0u64; 2];
        // boom(5), boom(6), boom(7) panics.
        let e = call::<_, u64>(img.id(ub), (5u64, log.as_mut_ptr() as u64)).unwrap_err();
        assert_eq!(*e.downcast::<Boom>().unwrap(), Boom(7));
        assert_eq!(log[0], 42);
        assert!(in_jit(&img, ub, log[1]), "ran at {:#x}", log[1]);
        assert_eq!(ok::<_, u64>(img.id(ub), (1u64, log.as_mut_ptr() as u64)), 3);
    }
}

/// JIT code calls compiled functions in their JIT code and others in their AOT code.
#[test]
fn calls_between_jit_and_aot() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // leaf() = where it runs.
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-16), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.ret(Slot(-16), 8);
    let leaf = w.add_function(func(a.done(), 16, 0, 8));
    // aot() = where it runs (it never trips).
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-16), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.ret(Slot(-16), 8);
    let aot = w.add_function(func(a.done(), 16, 0, 8));
    // both(out) = out[0] = leaf(), out[1] = aot(), out[2] = where it runs; out@16.
    let mut a = Asm::new();
    a.i(Insn::Call { d: Slot(-16), f: leaf, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(16), k: 0 }, s: Slot(-16) });
    a.i(Insn::Call { d: Slot(-16), f: aot, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(16), k: 8 }, s: Slot(-16) });
    a.i(Insn::CallSym { d: Slot(-16), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(16), k: 16 }, s: Slot(-16) });
    a.ret(Slot(0), 0);
    let both = w.add_function(func(a.done(), 16, 8, 0));
    let img = build(w, &syms());
    img.set_counter(aot, i64::MAX);

    // `leaf` first, so that `both`'s JIT code calls it directly.
    let at = ok::<_, u64>(img.id(leaf), ());
    assert!(in_jit(&img, leaf, at));
    for _ in 0..2 {
        let mut out = [0u64; 3];
        ok::<_, ()>(img.id(both), (out.as_mut_ptr() as u64,));
        assert!(in_jit(&img, leaf, out[0]), "leaf ran at {:#x}", out[0]);
        assert!(in_aot(&img, aot, out[1]), "aot ran at {:#x}", out[1]);
        assert!(in_jit(&img, both, out[2]), "both ran at {:#x}", out[2]);
    }
    assert_eq!(state(&img, aot), JIT_COLD);
}

/// JIT code compiled before its callee calls it through a call slot: first the callee's AOT
/// entry (which trips and compiles it), then, once it is published, its JIT code directly,
/// past its counter check.
#[test]
fn calls_of_functions_compiled_later() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // leaf() = where it runs.
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-16), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.ret(Slot(-16), 8);
    let leaf = w.add_function(func(a.done(), 16, 0, 8));
    // caller(out) = out[0] = leaf(), out[1] = where it runs; out@16.
    let mut a = Asm::new();
    a.i(Insn::Call { d: Slot(-16), f: leaf, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(16), k: 0 }, s: Slot(-16) });
    a.i(Insn::CallSym { d: Slot(-16), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(16), k: 8 }, s: Slot(-16) });
    a.ret(Slot(0), 0);
    let caller = w.add_function(func(a.done(), 16, 8, 0));
    let img = build(w, &syms());

    // `caller` compiles first; its call of `leaf` trips `leaf` at its AOT entry.
    let mut out = [0u64; 2];
    ok::<_, ()>(img.id(caller), (out.as_mut_ptr() as u64,));
    assert!(in_jit(&img, caller, out[1]));
    assert!(in_jit(&img, leaf, out[0]), "leaf ran at {:#x}", out[0]);
    let ctr = img.counter(leaf);
    assert!(ctr < 0);
    for _ in 0..3 {
        ok::<_, ()>(img.id(caller), (out.as_mut_ptr() as u64,));
        assert!(in_jit(&img, leaf, out[0]), "leaf ran at {:#x}", out[0]);
    }
    // Not through the AOT entry, whose check would have counted.
    assert_eq!(img.counter(leaf), ctr);
}

/// A loop head trips first: the function compiles, and the call that is running the loop in
/// AOT code moves to the JIT code at the next head, through the OSR dispatcher; the counter
/// stays negative, and the next call runs the JIT code from its entry.
#[test]
fn loop_head_trip() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // sum(n, out) = 0 + 1 + … + (n - 1); out[0] = where it runs before the loop, out[1] after.
    // n@16, out@24, i@-8, acc@-16, tmp@-24.
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-24), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-24) });
    a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
    let head = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-8) });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", head);
    let done = a.i(Insn::CallSym { d: Slot(-24), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 8 }, s: Slot(-24) });
    a.ret(Slot(-16), 8);
    a.patch(head, "t", done);
    let sum = w.add_function(func(a.done(), 32, 16, 8));
    let img = build(w, &syms());

    // The entry's check leaves 0, the first head's trips.
    img.set_counter(sum, ryo_bytecode::asm::ENTRY_COUNT as i64);
    let mut out = [0u64; 2];
    assert_eq!(ok::<_, u64>(img.id(sum), (1000u64, out.as_mut_ptr() as u64)), 499_500);
    assert!(in_aot(&img, sum, out[0]));
    assert!(in_jit(&img, sum, out[1]), "the loop ended at {:#x}", out[1]);
    assert_eq!(state(&img, sum), JIT_DONE);
    assert!(img.counter(sum) < 0);
    assert_eq!(ok::<_, u64>(img.id(sum), (1000u64, out.as_mut_ptr() as u64)), 499_500);
    assert!(in_jit(&img, sum, out[0]));
}

/// Many threads trip on the same functions at once: each is compiled once, and every
/// thread gets the right results, in JIT code.
#[test]
fn concurrent_trips() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    let mut fs = Vec::new();
    for k in 0..8u64 {
        // f_k(x, out) = x * k + k; out[0] = where it runs. x@16, out@24.
        let mut a = Asm::new();
        a.i(Insn::CallSym { d: Slot(-8), sym: s_ret, k: 8, a: List::from_words(&[]) });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-8) });
        a.i(Insn::ImmW64 { d: Slot(-16), imm: k });
        a.i(Insn::MulW64 { d: Slot(-8), a: Slot(16), b: Slot(-16) });
        a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(-16) });
        a.ret(Slot(-8), 8);
        fs.push(w.add_function(func(a.done(), 16, 16, 8)));
    }
    let img = std::sync::Arc::new(build(w, &syms()));
    let (before, _) = ryo_rt::vm::jit_stats();
    let threads: Vec<_> = (0..16u64)
        .map(|t| {
            let (img, fs) = (img.clone(), fs.clone());
            std::thread::spawn(move || {
                for round in 0..50u64 {
                    for (k, &f) in fs.iter().enumerate() {
                        let k = k as u64;
                        let x = t * 1000 + round;
                        let mut out = [0u64; 1];
                        assert_eq!(ok::<_, u64>(img.id(f), (x, out.as_mut_ptr() as u64)), x * k + k);
                        assert!(in_jit(&img, f, out[0]), "thread {t}: f{k} ran at {:#x}", out[0]);
                    }
                }
            })
        })
        .collect();
    for t in threads {
        t.join().unwrap();
    }
    for &f in &fs {
        assert_eq!(state(&img, f), JIT_DONE);
    }
    // Other tests compile concurrently, so only a lower bound.
    assert!(ryo_rt::vm::jit_stats().0 >= before + fs.len());
}

// ---- OSR ----

use ryo_bytecode::asm::{ENTRY_COUNT, Scope, ScopeKind};

/// Functions of an image being built, with their scopes (escapes), which [`ImageWriter::finish`]
/// doesn't take.
#[derive(Default)]
struct Defs(Vec<(FunctionDef, Vec<Scope>)>);

impl Defs {
    fn add(&mut self, w: &mut ImageWriter, f: FunctionDef, scopes: Vec<Scope>) -> Func {
        self.0.push((f.clone(), scopes));
        w.add_function(f)
    }

    /// Builds and registers the image; with `shuffle`, its JIT code gets frames of another
    /// layout than the AOT code's (`RYO_JIT_SHUFFLE`).
    fn build(self, mut w: ImageWriter, shuffle: bool) -> Linked {
        w.prepare(ENC);
        w.validate_functions().unwrap();
        let enc = self.0.iter().map(|(f, sc)| ryo_bytecode::asm::encode(&f.code, f.frame_size, &f.cleanup, sc, ENC).unwrap()).collect();
        let img = link(w.finish_encoded(enc).unwrap(), &syms());
        if shuffle {
            ryo_rt::vm::jit_shuffle_image(img.header);
        }
        register(&[&img]);
        img
    }
}

fn escape(at: u32, off: i32, size: u32) -> Scope {
    Scope { code_offset: at, frame_offset: off, size, kind: ScopeKind::Escape { align: 8 } }
}

/// `note(obs)`, `obs` the pointer at `slot`.
fn note_call(a: &mut Asm, s_note: Sym, slot: i32) -> u32 {
    a.i(Insn::CallSym { d: Slot(0), sym: s_note, k: 0, a: List::from_words(&regs(&[slot])) })
}

/// How much further down `rsp` is in the JIT code than in the AOT code of a function of frame
/// size `f` (`asm::frame::shuffle_map`).
fn jit_rsp_delta(f: u32, shuffle: bool) -> u64 {
    if shuffle { f as u64 + 64 } else { 0 }
}

/// Checks how far `rsp` moved between the AOT code's `note` (`first`) and the JIT code's
/// (`last`): by the frames' difference. The SSA tier (the default, but for
/// `RYO_JIT_OPT=reencode`) lays out frames of its own, so there only by a multiple of 16.
fn check_rsp(first: u64, last: u64, f: u32, shuffle: bool, what: &str) {
    if std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode") {
        assert_eq!(first.wrapping_sub(last) % 16, 0, "{what}: rsp");
    } else {
        assert_eq!(first - last, jit_rsp_delta(f, shuffle), "{what}: rsp");
    }
}

/// A loop moves into the JIT code at the head pass that trips, with every value live at the
/// head intact: integers of every width, floats (in handlers), a 128-bit value, and a local
/// whose address was taken before the loop, read and written through the pointer in the
/// loop and read directly after it. With shuffled frames the values move (and `rsp`), the
/// escaped local stays. A frame of 4096 bytes makes the entry probe the stack it grows by.
#[test]
fn osr_values() {
    init();
    for shuffle in [false, true] {
        for frame in [128, 4096] {
            for k in [0i64, 1, 3, 49] {
                osr_values_at(shuffle, frame, k);
            }
        }
    }
}

fn osr_values_at(shuffle: bool, frame: u32, k: i64) {
    let mut w = ImageWriter::new(unique_scid());
    let s_note = w.symbol("note", 0);
    let mut defs = Defs::default();
    // n@16, out@24, obs@32; i@-8, a64@-16, a32@-20, a16@-22, a8@-23, f64@-32, f32@-36,
    // w128@-64, one128@-80, c64@-88, c32@-92, e@-104 (escaped), p@-112, t@-120.
    let mut a = Asm::new();
    note_call(&mut a, s_note, 32);
    a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 1 });
    a.i(Insn::ImmW32 { d: Slot(-20), imm: 2 });
    a.i(Insn::ImmW16 { d: Slot(-22), imm: 3 });
    a.i(Insn::ImmW8 { d: Slot(-23), imm: 4 });
    a.i(Insn::ImmW64 { d: Slot(-32), imm: 0.5f64.to_bits() });
    a.i(Insn::ImmW32 { d: Slot(-36), imm: 0.25f32.to_bits() });
    a.i(Insn::ImmW128 { d: Slot(-64), imm: (1 << 64) + 5 });
    a.i(Insn::ImmW128 { d: Slot(-80), imm: (1 << 70) + 3 });
    a.i(Insn::ImmW64 { d: Slot(-88), imm: 1.5f64.to_bits() });
    a.i(Insn::ImmW32 { d: Slot(-92), imm: 1.5f32.to_bits() });
    a.i(Insn::ImmW64 { d: Slot(-104), imm: 5 });
    let at_addr = a.i(Insn::Addr { d: Slot(-112), s: Slot(-104) });
    let head = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
    a.i(Insn::MulImmW64 { d: Slot(-16), a: Slot(-16), imm: 3 });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-8) });
    a.i(Insn::MulImmW32 { d: Slot(-20), a: Slot(-20), imm: 5 });
    a.i(Insn::XorW32 { d: Slot(-20), a: Slot(-20), b: Slot(-8) });
    a.i(Insn::AddImmW16 { d: Slot(-22), a: Slot(-22), imm: 7 });
    a.i(Insn::MulImmW8 { d: Slot(-23), a: Slot(-23), imm: 3 });
    a.i(Insn::FmulF64 { d: Slot(-32), a: Slot(-32), b: Slot(-88) });
    a.i(Insn::FmulF32 { d: Slot(-36), a: Slot(-36), b: Slot(-92) });
    a.i(Insn::AddW128 { d: Slot(-64), a: Slot(-64), b: Slot(-80) });
    a.i(Insn::LoadW64 { d: Slot(-120), m: Mem { p: Slot(-112), k: 0 } });
    a.i(Insn::AddW64 { d: Slot(-120), a: Slot(-120), b: Slot(-8) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(-112), k: 0 }, s: Slot(-120) });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", head);
    let done = a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-16) });
    a.patch(head, "t", done);
    a.i(Insn::StoreW32 { m: Mem { p: Slot(24), k: 8 }, s: Slot(-20) });
    a.i(Insn::StoreW16 { m: Mem { p: Slot(24), k: 12 }, s: Slot(-22) });
    a.i(Insn::StoreW8 { m: Mem { p: Slot(24), k: 14 }, s: Slot(-23) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 16 }, s: Slot(-32) });
    a.i(Insn::StoreW32 { m: Mem { p: Slot(24), k: 24 }, s: Slot(-36) });
    a.i(Insn::StoreW128 { m: Mem { p: Slot(24), k: 32 }, s: Slot(-64) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 48 }, s: Slot(-104) });
    note_call(&mut a, s_note, 32);
    a.ret(Slot(-8), 8);
    let f = defs.add(&mut w, func(a.done(), frame, 24, 8), vec![escape(at_addr, -104, 8)]);
    let img = defs.build(w, shuffle);

    let n = 50u64;
    let (mut a64, mut a32, mut a16, mut a8) = (1u64, 2u32, 3u16, 4u8);
    let (mut f64_, mut f32_, mut w128, mut e) = (0.5f64, 0.25f32, (1u128 << 64) + 5, 5u64);
    for i in 0..n {
        a64 = a64.wrapping_mul(3).wrapping_add(i);
        a32 = a32.wrapping_mul(5) ^ i as u32;
        a16 = a16.wrapping_add(7);
        a8 = a8.wrapping_mul(3);
        f64_ *= 1.5;
        f32_ *= 1.5;
        w128 = w128.wrapping_add((1 << 70) + 3);
        e = e.wrapping_add(i);
    }
    img.set_counter(f, ENTRY_COUNT as i64 + k);
    let mut out = [0u64; 7];
    let obs = Obs::default();
    let what = format!("shuffle {shuffle}, frame {frame}, trip at head pass {}", k + 1);
    assert_eq!(ok::<_, u64>(img.id(f), (n, out.as_mut_ptr() as u64, &raw const obs as u64)), n, "{what}");
    let b = |i: usize, o: usize, len: usize| -> u128 {
        let bytes: &[u8] = unsafe { std::slice::from_raw_parts(out.as_ptr().cast::<u8>().add(8 * i + o), len) };
        bytes.iter().rev().fold(0, |v, &x| v << 8 | x as u128)
    };
    assert_eq!(b(0, 0, 8) as u64, a64, "{what}");
    assert_eq!(b(1, 0, 4) as u32, a32, "{what}");
    assert_eq!(b(1, 4, 2) as u16, a16, "{what}");
    assert_eq!(b(1, 6, 1) as u8, a8, "{what}");
    assert_eq!(f64::from_bits(b(2, 0, 8) as u64), f64_, "{what}");
    assert_eq!(f32::from_bits(b(3, 0, 4) as u32), f32_, "{what}");
    assert_eq!(b(4, 0, 16), w128, "{what}");
    assert_eq!(b(6, 0, 8) as u64, e, "{what}");
    let o = |a: &AtomicU64| a.load(std::sync::atomic::Ordering::SeqCst);
    assert!(in_aot(&img, f, o(&obs.first)), "{what}: started at {:#x}", o(&obs.first));
    assert!(in_jit(&img, f, o(&obs.last)), "{what}: ended at {:#x}", o(&obs.last));
    check_rsp(o(&obs.first_sp), o(&obs.last_sp), frame, shuffle, &what);
}

/// Nested loops: OSR at the outer head (its first pass) or the inner one (later passes),
/// the outer loop's values live across the inner one.
#[test]
fn osr_nested_loops() {
    init();
    for shuffle in [false, true] {
        for k in [0i64, 1, 2, 5, 6, 7, 20] {
            let mut w = ImageWriter::new(unique_scid());
            let s_note = w.symbol("note", 0);
            let mut defs = Defs::default();
            // nest(n, m, obs) = sum over i < n, j < m of i * j + 1. n@16, m@24, obs@32; i@-8,
            // j@-16, acc@-24, t@-32.
            let mut a = Asm::new();
            note_call(&mut a, s_note, 32);
            a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
            a.i(Insn::ImmW64 { d: Slot(-24), imm: 0 });
            let outer = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
            a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
            let inner = a.i(Insn::BrLtUW64 { a: Slot(-16), b: Slot(24), neg: F, t: Target(0) });
            a.i(Insn::MulW64 { d: Slot(-32), a: Slot(-8), b: Slot(-16) });
            a.i(Insn::AddW64 { d: Slot(-24), a: Slot(-24), b: Slot(-32) });
            a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
            a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
            let back = a.i(Insn::Jmp { t: Target(0) });
            a.patch(back, "t", inner);
            let next = a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
            a.patch(inner, "t", next);
            let back = a.i(Insn::Jmp { t: Target(0) });
            a.patch(back, "t", outer);
            let done = note_call(&mut a, s_note, 32);
            a.patch(outer, "t", done);
            a.ret(Slot(-24), 8);
            let f = defs.add(&mut w, func(a.done(), 32, 24, 8), vec![]);
            let img = defs.build(w, shuffle);

            let (n, m) = (4u64, 5u64);
            let want: u64 = (0..n).flat_map(|i| (0..m).map(move |j| i * j + 1)).sum();
            img.set_counter(f, ENTRY_COUNT as i64 + k);
            let obs = Obs::default();
            let what = format!("shuffle {shuffle}, trip at head pass {}", k + 1);
            assert_eq!(ok::<_, u64>(img.id(f), (n, m, &raw const obs as u64)), want, "{what}");
            let o = |a: &AtomicU64| a.load(std::sync::atomic::Ordering::SeqCst);
            assert!(in_aot(&img, f, o(&obs.first)), "{what}");
            assert!(in_jit(&img, f, o(&obs.last)), "{what}: ended at {:#x}", o(&obs.last));
            check_rsp(o(&obs.first_sp), o(&obs.last_sp), 32, shuffle, &what);
        }
    }
}

/// A panic after OSR unwinds through the JIT frame: its landing pad runs, reading a value
/// live in the loop, and resumes.
#[test]
fn osr_unwinding() {
    init();
    for shuffle in [false, true] {
        for k in [0i64, 1] {
            let mut w = ImageWriter::new(unique_scid());
            let s_boom = w.symbol("boom", 0);
            let s_note = w.symbol("note", 0);
            let mut defs = Defs::default();
            // ub(x, log, obs): for i in 0..3 { note(obs); boom(x + i) }; landing pad: log[0] =
            // i, log[1] = 42, resume. x@16, log@24, obs@32; i@-8, t@-16, r@-24, exc@-32,
            // tmp@-40.
            let mut a = Asm::new();
            a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
            let head = a.i(Insn::BrLtUImmW64 { a: Slot(-8), imm: 3, neg: F, t: Target(0) });
            note_call(&mut a, s_note, 32);
            a.i(Insn::AddW64 { d: Slot(-16), a: Slot(16), b: Slot(-8) });
            let site = a.i(Insn::CallSym { d: Slot(-24), sym: s_boom, k: 8, a: List::from_words(&regs(&[-16])) });
            a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
            let back = a.i(Insn::Jmp { t: Target(0) });
            a.patch(back, "t", head);
            let done = a.ret(Slot(-24), 8);
            a.patch(head, "t", done);
            let c = a.i(Insn::Lpad { x: Slot(-32) });
            a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-8) });
            a.i(Insn::ImmW64 { d: Slot(-40), imm: 42 });
            a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 8 }, s: Slot(-40) });
            let r = a.i(Insn::Resume { x: Slot(-32) });
            let mut fd = func(a.done(), 48, 24, 8);
            fd.cleanup = vec![CleanupEntry { offset: site, target: c }, CleanupEntry { offset: r, target: CONTINUE }];
            let f = defs.add(&mut w, fd, vec![]);
            let img = defs.build(w, shuffle);

            img.set_counter(f, ENTRY_COUNT as i64 + k);
            let mut log = [0u64; 2];
            let obs = Obs::default();
            let what = format!("shuffle {shuffle}, trip at head pass {}", k + 1);
            let e = call::<_, u64>(img.id(f), (5u64, log.as_mut_ptr() as u64, &raw const obs as u64)).unwrap_err();
            assert_eq!(*e.downcast::<Boom>().unwrap(), Boom(7), "{what}");
            assert_eq!(log, [2, 42], "{what}");
            let o = |a: &AtomicU64| a.load(std::sync::atomic::Ordering::SeqCst);
            assert!(in_jit(&img, f, o(&obs.last)), "{what}: ran at {:#x}", o(&obs.last));
            if k > 0 {
                assert!(in_aot(&img, f, o(&obs.first)), "{what}");
                check_rsp(o(&obs.first_sp), o(&obs.last_sp), 48, shuffle, &what);
            }
        }
    }
}

/// Waits until `cond` holds (for 20 s at most).
fn wait_for(what: &str, cond: impl Fn() -> bool) {
    let t = std::time::Instant::now();
    while !cond() {
        assert!(t.elapsed().as_secs() < 20, "timed out waiting for {what}");
        std::thread::yield_now();
    }
}

/// Bounded entry: a thread spinning in an AOT loop and one deep in a self-recursion, both
/// started before their function compiles, reach the JIT code without returning: the loop at
/// its next head (OSR), the recursion at its next call.
#[test]
fn running_calls_switch_over() {
    init();
    for shuffle in [false, true] {
        let mut w = ImageWriter::new(unique_scid());
        let s_note = w.symbol("note", 0);
        let mut defs = Defs::default();
        // spin(flag, obs): c = 0; loop { note(obs); c += 1; if *flag != 0 { return c } }.
        // flag@16, obs@24; c@-8, f@-16.
        let mut a = Asm::new();
        a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
        let head = note_call(&mut a, s_note, 24);
        a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
        a.i(Insn::LoadW64 { d: Slot(-16), m: Mem { p: Slot(16), k: 0 } });
        let br = a.i(Insn::BrEqImmW64 { a: Slot(-16), imm: 0, neg: T, t: Target(0) });
        a.patch(br, "t", head);
        a.ret(Slot(-8), 8);
        let spin = defs.add(&mut w, func(a.done(), 16, 16, 8), vec![]);
        // rec(n, obs) = note(obs); n == 0 ? 0 : rec(n - 1, obs) + 1. n@16, obs@24; r@-8; the
        // outgoing arguments at -32 and -24.
        let mut a = Asm::new();
        note_call(&mut a, s_note, 24);
        let b = a.i(Insn::BrEqImmW64 { a: Slot(16), imm: 0, neg: T, t: Target(0) });
        a.i(Insn::SubImmW64 { d: Slot(-32), a: Slot(16), imm: 1 });
        a.i(Insn::MovW64 { d: Slot(-24), s: Slot(24) });
        a.i(Insn::Call { d: Slot(-8), f: Func(1), k: 8, a: List::from_words(&[]) });
        a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
        a.ret(Slot(-8), 8);
        let base = a.ret(Slot(16), 8);
        a.patch(b, "t", base);
        let rec = defs.add(&mut w, func(a.done(), 32, 16, 8), vec![]);
        assert_eq!(rec, Func(1));
        let img = std::sync::Arc::new(defs.build(w, shuffle));
        let o = |a: &AtomicU64| a.load(std::sync::atomic::Ordering::SeqCst);

        // The loop: in AOT code until its counter is made to run out.
        img.set_counter(spin, i64::MAX / 2);
        let flag = std::sync::Arc::new(AtomicU64::new(0));
        let obs = std::sync::Arc::new(Obs::default());
        let t = {
            let (img, flag, obs) = (img.clone(), flag.clone(), obs.clone());
            std::thread::spawn(move || ok::<_, u64>(img.id(spin), (flag.as_ptr() as u64, &raw const *obs as u64)))
        };
        wait_for("the loop to run", || o(&obs.first) != 0);
        assert!(in_aot(&img, spin, o(&obs.first)));
        assert_eq!(state(&img, spin), JIT_COLD);
        // The loop's `sub`s race with the store (counting is lossy): again until it trips.
        wait_for("the loop to reach the JIT code", || {
            if state(&img, spin) == JIT_COLD {
                img.set_counter(spin, 0);
            }
            in_jit(&img, spin, o(&obs.last))
        });
        flag.store(1, std::sync::atomic::Ordering::SeqCst);
        assert!(t.join().unwrap() > 1);
        assert!(img.counter(spin) < 0);

        // The recursion: its 301st call trips at the entry.
        img.set_counter(rec, 300 * ENTRY_COUNT as i64);
        let obs = std::sync::Arc::new(Obs::default());
        let t = {
            let (img, obs) = (img.clone(), obs.clone());
            std::thread::Builder::new().stack_size(64 << 20).spawn(move || ok::<_, u64>(img.id(rec), (5000u64, &raw const *obs as u64))).unwrap()
        };
        assert_eq!(t.join().unwrap(), 5000);
        assert!(in_aot(&img, rec, o(&obs.first)));
        assert!(in_jit(&img, rec, o(&obs.last)), "the innermost call ran at {:#x}", o(&obs.last));
    }
}

// ---- SSA tier (the default, but for `RYO_JIT_OPT=reencode`) ----

fn o(a: &AtomicU64) -> u64 {
    a.load(std::sync::atomic::Ordering::SeqCst)
}

/// A local's address is taken only after the loop: the OSR entry mid-loop needs no escaped
/// slot, and the read through the pointer after the loop sees the loop's value.
#[test]
fn osr_escaped_after_head() {
    init();
    for k in [0i64, 1, 3, 7] {
        let mut w = ImageWriter::new(unique_scid());
        let s_note = w.symbol("note", 0);
        let mut defs = Defs::default();
        // f(n, out, obs): e = 0; for i < n { e += i * 2 }; p = &e; out[0] = *p + 1.
        // n@16, out@24, obs@32; i@-8, e@-16, p@-24, t@-32.
        let mut a = Asm::new();
        note_call(&mut a, s_note, 32);
        a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
        a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
        let head = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
        a.i(Insn::MulImmW64 { d: Slot(-32), a: Slot(-8), imm: 2 });
        a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-32) });
        a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
        let back = a.i(Insn::Jmp { t: Target(0) });
        a.patch(back, "t", head);
        let done = a.i(Insn::Addr { d: Slot(-24), s: Slot(-16) });
        a.patch(head, "t", done);
        a.i(Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-24), k: 0 } });
        a.i(Insn::AddImmW64 { d: Slot(-32), a: Slot(-32), imm: 1 });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-32) });
        note_call(&mut a, s_note, 32);
        a.ret(Slot(-8), 8);
        let f = defs.add(&mut w, func(a.done(), 32, 24, 8), vec![escape(done, -16, 8)]);
        let img = defs.build(w, false);

        let n = 20u64;
        img.set_counter(f, ENTRY_COUNT as i64 + k);
        let mut out = [0u64; 1];
        let obs = Obs::default();
        let what = format!("trip at head pass {}", k + 1);
        assert_eq!(ok::<_, u64>(img.id(f), (n, out.as_mut_ptr() as u64, &raw const obs as u64)), n, "{what}");
        assert_eq!(out[0], n * (n - 1) + 1, "{what}");
        assert!(in_aot(&img, f, o(&obs.first)), "{what}");
        assert!(in_jit(&img, f, o(&obs.last)), "{what}: ended at {:#x}", o(&obs.last));
    }
}

/// A backward jump that is no loop: its target's counter check trips. The SSA tier has no OSR
/// entry at a head on no cycle, so there the activation finishes in AOT code (the old pipeline
/// moves into the JIT code); the next call runs the JIT code.
#[test]
fn acyclic_head() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_note = w.symbol("note", 0);
    // f(x, obs): note(obs); jmp B; C: note(obs); ret x; B: x += 5; jmp C. x@16, obs@24.
    let mut a = Asm::new();
    note_call(&mut a, s_note, 24);
    let j = a.i(Insn::Jmp { t: Target(0) });
    let c = note_call(&mut a, s_note, 24);
    a.ret(Slot(16), 8);
    let b = a.i(Insn::AddImmW64 { d: Slot(16), a: Slot(16), imm: 5 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", c);
    a.patch(j, "t", b);
    let f = w.add_function(func(a.done(), 16, 16, 8));
    let img = build(w, &syms());

    // The entry's check leaves 0, the head's trips.
    img.set_counter(f, ENTRY_COUNT as i64);
    let obs = Obs::default();
    assert_eq!(ok::<_, u64>(img.id(f), (10u64, &raw const obs as u64)), 15);
    assert!(in_aot(&img, f, o(&obs.first)));
    // The old pipeline has OSR entries at every head, the SSA tier only at cyclic ones.
    let ssa = std::env::var("RYO_JIT_OPT").map_or(true, |o| o != "reencode");
    let last = o(&obs.last);
    assert!(if ssa { in_aot(&img, f, last) } else { in_jit(&img, f, last) }, "finished at {last:#x}");
    for x in [0u64, 7, 1 << 40] {
        let obs = Obs::default();
        assert_eq!(ok::<_, u64>(img.id(f), (x, &raw const obs as u64)), x + 5);
        assert!(in_jit(&img, f, o(&obs.first)), "started at {:#x}", o(&obs.first));
        assert!(in_jit(&img, f, o(&obs.last)));
    }
}

/// One slot holds a 64-bit value, then an 8-bit one, in each pass of a loop entered by OSR.
#[test]
fn slot_reuse_widths() {
    init();
    for k in [0i64, 1, 2, 9] {
        let mut w = ImageWriter::new(unique_scid());
        let s_note = w.symbol("note", 0);
        // f(n, out, obs): for i < n { s = i * 3; acc += s; s8 = 7; s8 += i8; acc8 += s8 };
        // out[0] = acc, out[1] = zext(acc8). n@16, out@24, obs@32; i@-8, s@-16, acc@-24,
        // acc8@-25, t@-32.
        let mut a = Asm::new();
        note_call(&mut a, s_note, 32);
        a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
        a.i(Insn::ImmW64 { d: Slot(-24), imm: 0 });
        a.i(Insn::ImmW8 { d: Slot(-25), imm: 0 });
        let head = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
        a.i(Insn::MulImmW64 { d: Slot(-16), a: Slot(-8), imm: 3 });
        a.i(Insn::AddW64 { d: Slot(-24), a: Slot(-24), b: Slot(-16) });
        a.i(Insn::ImmW8 { d: Slot(-16), imm: 7 });
        a.i(Insn::AddW8 { d: Slot(-16), a: Slot(-16), b: Slot(-8) });
        a.i(Insn::AddW8 { d: Slot(-25), a: Slot(-25), b: Slot(-16) });
        a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
        let back = a.i(Insn::Jmp { t: Target(0) });
        a.patch(back, "t", head);
        let done = a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-24) });
        a.patch(head, "t", done);
        a.i(Insn::ZextW8W64 { d: Slot(-32), s: Slot(-25) });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 8 }, s: Slot(-32) });
        note_call(&mut a, s_note, 32);
        a.ret(Slot(-8), 8);
        let f = w.add_function(func(a.done(), 32, 24, 8));
        let img = build(w, &syms());

        let n = 100u64;
        let acc: u64 = (0..n).map(|i| i * 3).sum();
        let acc8 = (0..n).fold(0u8, |s, i| s.wrapping_add(7u8.wrapping_add(i as u8)));
        img.set_counter(f, ENTRY_COUNT as i64 + k);
        let mut out = [0u64; 2];
        let obs = Obs::default();
        let what = format!("trip at head pass {}", k + 1);
        assert_eq!(ok::<_, u64>(img.id(f), (n, out.as_mut_ptr() as u64, &raw const obs as u64)), n, "{what}");
        assert_eq!(out, [acc, acc8 as u64], "{what}");
        assert!(in_aot(&img, f, o(&obs.first)), "{what}");
        assert!(in_jit(&img, f, o(&obs.last)), "{what}: ended at {:#x}", o(&obs.last));
    }
}

/// Handler results feed branches: an `add.ovf`'s overflow flag a `br`, a `div`'s quotient a
/// compare-branch.
#[test]
fn handler_results_feed_branches() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // f(a, b, c, d, out): s, ov = a +ovf b (32 bits); if ov { ret zext(s) + 2^50 };
    // q = c / d; if q < 10 { ret zext(s) + q } else { ret zext(s) + 2^40 }; out[0] = where
    // it runs. a@16, b@24, c@32, d@40, out@48; s@-4, ov@-8, q@-16, z@-24, t@-32.
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-32), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(48), k: 0 }, s: Slot(-32) });
    a.i(Insn::AddOvfUW32 { d: Slot(-4), o: Slot(-8), a: Slot(16), b: Slot(24) });
    a.i(Insn::ZextW32W64 { d: Slot(-24), s: Slot(-4) });
    let bo = a.i(Insn::Br { s: Slot(-8), neg: T, t: Target(0) });
    a.i(Insn::DivUW64 { d: Slot(-16), a: Slot(32), b: Slot(40) });
    let bq = a.i(Insn::BrLtUImmW64 { a: Slot(-16), imm: 10, neg: T, t: Target(0) });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 << 40 });
    a.ret(Slot(-24), 8);
    let small = a.i(Insn::AddW64 { d: Slot(-24), a: Slot(-24), b: Slot(-16) });
    a.patch(bq, "t", small);
    a.ret(Slot(-24), 8);
    let ovf = a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 << 50 });
    a.patch(bo, "t", ovf);
    a.ret(Slot(-24), 8);
    let f = w.add_function(func(a.done(), 32, 40, 8));
    let img = build(w, &syms());

    let want = |a: u32, b: u32, c: u64, d: u64| {
        let (s, ov) = a.overflowing_add(b);
        let q = c / d;
        s as u64
            + if ov {
                1 << 50
            } else if q < 10 {
                q
            } else {
                1 << 40
            }
    };
    for round in 0..2 {
        for (x, y, c, d) in [(1u32, 2u32, 50u64, 7u64), (u32::MAX, 2, 5, 1), (7, 8, 1000, 3), (u32::MAX - 1, 1, 9, 1), (0, 0, 0, 1)] {
            let mut out = [0u64; 1];
            let r = ok::<_, u64>(img.id(f), (x as u64, y as u64, c, d, out.as_mut_ptr() as u64));
            assert_eq!(r, want(x, y, c, d), "round {round}: {x} {y} {c} {d}");
            assert!(in_jit(&img, f, out[0]), "ran at {:#x}", out[0]);
        }
    }
}

/// A value computed before a call that panics is live into the landing pad, which stores it.
#[test]
fn live_across_landing_pad() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_boom = w.symbol("boom", 0);
    let s_ret = w.symbol("ret_addr", 0);
    // f(x, log): log[1] = where it runs; v = x * 3 + 1; r = boom(x); ret v + r; landing
    // pad: log[0] = v, resume. x@16, log@24; v@-8, r@-16, exc@-24, tmp@-32.
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-32), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 8 }, s: Slot(-32) });
    a.i(Insn::MulImmW64 { d: Slot(-8), a: Slot(16), imm: 3 });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    let site = a.i(Insn::CallSym { d: Slot(-16), sym: s_boom, k: 8, a: List::from_words(&regs(&[16])) });
    a.i(Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-8) });
    a.ret(Slot(-16), 8);
    let c = a.i(Insn::Lpad { x: Slot(-24) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-8) });
    let r = a.i(Insn::Resume { x: Slot(-24) });
    let mut fd = func(a.done(), 32, 16, 8);
    fd.cleanup = vec![CleanupEntry { offset: site, target: c }, CleanupEntry { offset: r, target: CONTINUE }];
    let f = w.add_function(fd);
    let img = build(w, &syms());

    for _ in 0..3 {
        let mut log = [0u64; 2];
        let e = call::<_, u64>(img.id(f), (7u64, log.as_mut_ptr() as u64)).unwrap_err();
        assert_eq!(*e.downcast::<Boom>().unwrap(), Boom(7));
        assert_eq!(log[0], 22);
        assert!(in_jit(&img, f, log[1]), "ran at {:#x}", log[1]);
        assert_eq!(ok::<_, u64>(img.id(f), (5u64, log.as_mut_ptr() as u64)), 21);
    }
}

/// Sixteen values live across a call, more than the registers it preserves.
#[test]
fn many_live_across_call() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // f(x, out): v_i = x * (i + 1) + i for i < 16; out[0] = ret_addr(); ret sum of v_i *
    // (2i + 1). x@16, out@24; v_i@-8(i+1), r@-136, t@-144, acc@-152.
    let mut a = Asm::new();
    for i in 0..16i32 {
        a.i(Insn::MulImmW64 { d: Slot(-8 * (i + 1)), a: Slot(16), imm: i as u64 + 1 });
        a.i(Insn::AddImmW64 { d: Slot(-8 * (i + 1)), a: Slot(-8 * (i + 1)), imm: i as u64 });
    }
    a.i(Insn::CallSym { d: Slot(-136), sym: s_ret, k: 8, a: List::from_words(&[]) });
    a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-136) });
    a.i(Insn::ImmW64 { d: Slot(-152), imm: 0 });
    for i in 0..16i32 {
        a.i(Insn::MulImmW64 { d: Slot(-144), a: Slot(-8 * (i + 1)), imm: 2 * i as u64 + 1 });
        a.i(Insn::AddW64 { d: Slot(-152), a: Slot(-152), b: Slot(-144) });
    }
    a.ret(Slot(-152), 8);
    let f = w.add_function(func(a.done(), 160, 16, 8));
    let img = build(w, &syms());

    for x in [0u64, 1, 12345, 1 << 50] {
        let want = (0..16u64).fold(0u64, |s, i| s.wrapping_add(x.wrapping_mul(i + 1).wrapping_add(i).wrapping_mul(2 * i + 1)));
        let mut out = [0u64; 1];
        assert_eq!(ok::<_, u64>(img.id(f), (x, out.as_mut_ptr() as u64)), want, "x = {x}");
        assert!(in_jit(&img, f, out[0]), "ran at {:#x}", out[0]);
    }
}
