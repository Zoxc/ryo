//! The JIT (design/vm.md, "JIT"): hand-assembled functions, linked in memory and registered
//! with every counter at 0 and `RYO_JIT_SYNC`'s waiting ([`ryo_rt::vm::configure_jit`]), so
//! that their first call compiles them and continues in their JIT code. Their results match
//! the AOT code's, with arguments of every kind, through recursion that switches over midway,
//! unwinding with landing pads, calls between JIT and AOT functions, and many threads.

#![cfg(all(target_arch = "x86_64", target_os = "linux", feature = "jit"))]
#![feature(unboxed_closures)]

mod common;
use common::*;

use std::panic::resume_unwind;
use std::sync::Once;

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
    vec![("ret_addr", ret_addr as *const () as usize), ("boom", boom as *const () as usize)]
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

/// A loop head trips first: the function compiles while its call stays in AOT code (no OSR
/// yet), the loop finishes there with every further head returning from the trip at once,
/// and the next call runs the JIT code.
#[test]
fn loop_head_trip() {
    init();
    let mut w = ImageWriter::new(unique_scid());
    let s_ret = w.symbol("ret_addr", 0);
    // sum(n, out) = 0 + 1 + … + (n - 1); out[0] = where it runs. n@16, out@24, i@-8,
    // acc@-16, tmp@-24.
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
    let done = a.ret(Slot(-16), 8);
    a.patch(head, "t", done);
    let sum = w.add_function(func(a.done(), 32, 16, 8));
    let img = build(w, &syms());

    // The entry's check leaves 0, the first head's trips.
    img.set_counter(sum, ryo_bytecode::asm::ENTRY_COUNT as i64);
    let mut out = [0u64; 1];
    assert_eq!(ok::<_, u64>(img.id(sum), (1000u64, out.as_mut_ptr() as u64)), 499_500);
    assert!(in_aot(&img, sum, out[0]));
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
