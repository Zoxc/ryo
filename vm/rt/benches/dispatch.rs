//! VM dispatch microbenches (design/build.md, `y bench`): hand-assembled fib, sieve and
//! insertion sort, run through `vm::enter` under the dispatch strategy this build uses
//! (`ryo_rt::vm::STRATEGY`, chosen by cargo features). Each program runs as assembled and
//! with superinstructions formed by `ryo_bytecode::peephole::fuse` (`+super` rows).
//!
//! Run: `cargo bench -p ryo_rt --bench dispatch [--features dispatch-…] -- [--runs N]`.
//! Prints `strategy <name>`, then one line per program: `<program> <mean ns> <stddev ns>`,
//! over `N` timed runs after one warmup (default 5). `y bench` runs it for every strategy.

#[path = "../tests/common/mod.rs"]
mod common;
use common::*;

use std::time::Instant;

use ryo_bytecode::peephole::fuse;

const FIB_N: u64 = 30;
const SIEVE_N: u64 = 4_000_000;
const SORT_N: usize = 4000;

/// Finishes a function's code, optionally forming superinstructions.
fn code(mut a: Asm, fused: bool) -> Vec<u32> {
    if fused {
        let n = fuse(&mut a.c).expect("code decodes");
        assert!(n > 0, "no superinstruction formed");
    }
    a.done()
}

/// fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2): calls and returns. Must be function 0.
/// n@16, t1@24, t2@32, frame 48; outgoing argument at 64.
fn fib(w: &mut ImageWriter, fused: bool) -> Func {
    let mut a = Asm::new();
    let b = a.i(Insn::BrCmpLtUImmW64 { a: Slot(16), imm: 2, t: Target(0) });
    a.i(Insn::SubImmW64 { d: Slot(64), a: Slot(16), imm: 1 });
    a.i(Insn::Call { d: Slot(24), f: Func(0), frame_size: 48 });
    a.i(Insn::SubImmW64 { d: Slot(64), a: Slot(16), imm: 2 });
    a.i(Insn::Call { d: Slot(32), f: Func(0), frame_size: 48 });
    a.i(Insn::AddW64 { d: Slot(24), a: Slot(24), b: Slot(32) });
    a.i(Insn::Ret { s: Slot(24), len: 8 });
    let base = a.i(Insn::Ret { s: Slot(16), len: 8 });
    a.patch(b, "t", base);
    // fib has no superinstruction pair; it measures call/ret dispatch either way.
    let _ = fused;
    w.add_function(func(a.done(), 48, 24, 8, 8))
}

/// sieve(n, p): counts the primes below `n` (n > 2) in the zeroed byte array `p`. Loops are
/// rotated, so the outer latch is `add.imm.w64` + `br.cmp.lt.u.w64`.
/// n@16, p@24, i@32, j@40, cnt@48, q@56, byte@64, one@72, frame 80.
fn sieve(w: &mut ImageWriter, fused: bool) -> Func {
    let (n, p, i, j, cnt, q, byte, one) = (16, 24, 32, 40, 48, 56, 64, 72);
    let mut a = Asm::new();
    a.i(Insn::ImmW64 { d: Slot(cnt), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(i), imm: 2 });
    a.i(Insn::ImmW8 { d: Slot(one), imm: 1 });
    let outer = a.i(Insn::PtrIndex { d: Slot(q), p: Slot(p), i: Slot(i), stride: 1 });
    a.i(Insn::LoadW8Z { d: Slot(byte), m: Deref(Slot(q)) });
    let composite = a.i(Insn::BrCmpNeImmW8 { a: Slot(byte), imm: 0, t: Target(0) });
    a.i(Insn::AddImmW64 { d: Slot(cnt), a: Slot(cnt), imm: 1 });
    a.i(Insn::MulW64 { d: Slot(j), a: Slot(i), b: Slot(i) });
    let skip = a.i(Insn::BrCmpLeUW64 { a: Slot(n), b: Slot(j), t: Target(0) });
    let inner = a.i(Insn::PtrIndex { d: Slot(q), p: Slot(p), i: Slot(j), stride: 1 });
    a.i(Insn::StoreW8Z { m: Deref(Slot(q)), s: Slot(one) });
    a.i(Insn::AddW64 { d: Slot(j), a: Slot(j), b: Slot(i) });
    let back = a.i(Insn::BrCmpLtUW64 { a: Slot(j), b: Slot(n), t: Target(0) });
    let next = a.i(Insn::AddImmW64 { d: Slot(i), a: Slot(i), imm: 1 });
    let latch = a.i(Insn::BrCmpLtUW64 { a: Slot(i), b: Slot(n), t: Target(0) });
    a.i(Insn::Ret { s: Slot(cnt), len: 8 });
    a.patch(composite, "t", next);
    a.patch(skip, "t", next);
    a.patch(back, "t", inner);
    a.patch(latch, "t", outer);
    w.add_function(func(code(a, fused), 80, 0, 16, 8))
}

/// isort(p, n): insertion sort of `n >= 2` u64s at `p`, ascending. The inner loop's test is
/// `load.w64` + `br.cmp.le.u.w64`, the outer latch `add.imm.w64` + `br.cmp.lt.u.w64`.
/// p@16, n@24, i@32, j@40, key@48, x@56, q@64, frame 80.
fn isort(w: &mut ImageWriter, fused: bool) -> Func {
    let (p, n, i, j, key, x, q) = (16, 24, 32, 40, 48, 56, 64);
    let mut a = Asm::new();
    a.i(Insn::ImmW64 { d: Slot(i), imm: 1 });
    let outer = a.i(Insn::PtrIndex { d: Slot(q), p: Slot(p), i: Slot(i), stride: 8 });
    a.i(Insn::LoadW64Z { d: Slot(key), m: Deref(Slot(q)) });
    a.i(Insn::MovW64 { d: Slot(j), s: Slot(i) });
    let inner = a.i(Insn::BrCmpEqImmW64 { a: Slot(j), imm: 0, t: Target(0) });
    a.i(Insn::PtrIndex { d: Slot(q), p: Slot(p), i: Slot(j), stride: 8 });
    a.i(Insn::LoadW64 { d: Slot(x), m: Mem { p: Slot(q), k: -8 } });
    let found = a.i(Insn::BrCmpLeUW64 { a: Slot(x), b: Slot(key), t: Target(0) });
    a.i(Insn::StoreW64Z { m: Deref(Slot(q)), s: Slot(x) });
    a.i(Insn::SubImmW64 { d: Slot(j), a: Slot(j), imm: 1 });
    let again = a.i(Insn::Jmp { t: Target(0) });
    let place = a.i(Insn::PtrIndex { d: Slot(q), p: Slot(p), i: Slot(j), stride: 8 });
    a.i(Insn::StoreW64Z { m: Deref(Slot(q)), s: Slot(key) });
    a.i(Insn::AddImmW64 { d: Slot(i), a: Slot(i), imm: 1 });
    let latch = a.i(Insn::BrCmpLtUW64 { a: Slot(i), b: Slot(n), t: Target(0) });
    a.i(Insn::Ret { s: Slot(i), len: 8 });
    a.patch(inner, "t", place);
    a.patch(found, "t", place);
    a.patch(again, "t", inner);
    a.patch(latch, "t", outer);
    w.add_function(func(code(a, fused), 80, 0, 16, 8))
}

fn sort_input() -> Vec<u64> {
    let mut x = 0x9e37_79b9_7f4a_7c15u64;
    (0..SORT_N)
        .map(|_| {
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            x
        })
        .collect()
}

/// Mean and standard deviation of `runs` timed runs of `f` after one warmup, in ns.
fn measure(runs: u32, mut f: impl FnMut()) -> (f64, f64) {
    f();
    let ts: Vec<f64> = (0..runs)
        .map(|_| {
            let t = Instant::now();
            f();
            t.elapsed().as_nanos() as f64
        })
        .collect();
    let mean = ts.iter().sum::<f64>() / ts.len() as f64;
    let var = ts.iter().map(|t| (t - mean).powi(2)).sum::<f64>() / ts.len() as f64;
    (mean, var.sqrt())
}

fn main() {
    let mut runs = 5u32;
    let mut args = std::env::args().skip(1);
    while let Some(a) = args.next() {
        match a.as_str() {
            "--runs" => runs = args.next().and_then(|n| n.parse().ok()).filter(|&n| n > 0).expect("--runs N"),
            // `cargo bench` passes `--bench`.
            "--bench" => {}
            _ => panic!("unknown argument {a}"),
        }
    }

    // Image: fib (function 0), then sieve and isort plain and fused.
    let mut w = ImageWriter::new(unique_scid());
    let f_fib = fib(&mut w, false);
    assert_eq!(f_fib, Func(0));
    let sieves = [sieve(&mut w, false), sieve(&mut w, true)];
    let sorts = [isort(&mut w, false), isort(&mut w, true)];
    let img = build(w, &[]);

    println!("strategy {}", ryo_rt::vm::STRATEGY);
    let report = |name: &str, (mean, sd): (f64, f64)| println!("{name} {mean:.0} {sd:.0}");

    report("fib", measure(runs, || assert_eq!(ok::<_, u64>(img.id(f_fib), (FIB_N,)), 832_040)));

    for (f, name) in sieves.into_iter().zip(["sieve", "sieve+super"]) {
        let mut buf = vec![0u8; SIEVE_N as usize];
        report(
            name,
            measure(runs, || {
                buf.fill(0);
                assert_eq!(ok::<_, u64>(img.id(f), (SIEVE_N, buf.as_mut_ptr())), 283_146);
            }),
        );
    }

    let input = sort_input();
    let mut want = input.clone();
    want.sort_unstable();
    for (f, name) in sorts.into_iter().zip(["sort", "sort+super"]) {
        let mut v = input.clone();
        report(
            name,
            measure(runs, || {
                v.copy_from_slice(&input);
                ok::<_, u64>(img.id(f), (v.as_mut_ptr(), SORT_N as u64));
                assert!(v == want, "{name}: not sorted");
            }),
        );
    }
}
