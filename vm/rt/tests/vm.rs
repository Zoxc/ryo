//! Hand-assembled functions, encoded to machine code, linked in memory and run, called from
//! the tests and from native code: data movement, addresses, enums, control flow, calls and
//! tail calls, multi-image calls, registration, re-entrancy, unwinding, large frames, deep
//! recursion, and the fatal paths (in child processes).

#![cfg(all(target_arch = "x86_64", any(target_os = "linux", target_vendor = "apple")))]
#![feature(unboxed_closures)]

mod common;
use common::*;

use std::panic::{catch_unwind, resume_unwind};
use std::sync::OnceLock;
use std::sync::atomic::{AtomicUsize, Ordering};

const T: Neg = Neg(false);
const F: Neg = Neg(true);

/// Runs `f` on a thread with a `mb`-MiB stack.
fn big_stack<R: Send + 'static>(mb: usize, f: impl FnOnce() -> R + Send + 'static) -> R {
    std::thread::Builder::new().stack_size(mb << 20).spawn(f).unwrap().join().unwrap()
}

#[test]
fn data_movement() {
    let mut w = ImageWriter::new(unique_scid());
    // mov.wN: x@16 → -80, -64, -48, -32, -16.
    let mut a = Asm::new();
    a.sret(Slot(-96));
    a.i(Insn::Zero { d: Slot(-80), len: 80 });
    a.i(Insn::MovW8 { d: Slot(-80), s: Slot(16) });
    a.i(Insn::MovW16 { d: Slot(-64), s: Slot(16) });
    a.i(Insn::MovW32 { d: Slot(-48), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-32), s: Slot(16) });
    a.i(Insn::MovW128 { d: Slot(-16), s: Slot(16) });
    a.ret(Slot(-80), 80);
    let f_mov = w.add_function(func(a.done(), 96, 16, 80));

    // copy, imm.w128, const, fill, zero.
    let k16 = w.add_const(&0x0f0e0d0c0b0a09080706050403020100u128.to_le_bytes(), 16, &[]);
    let k4 = w.add_const(&0xa1b2c3d4u32.to_le_bytes(), 4, &[]);
    let mut a = Asm::new();
    a.sret(Slot(-96));
    a.i(Insn::Zero { d: Slot(-64), len: 64 });
    a.i(Insn::Copy { d: Slot(-64), s: Slot(16), len: 7 });
    a.i(Insn::ImmW128 { d: Slot(-48), imm: 0x1122_3344_5566_7788_99aa_bbcc_ddee_ff00 });
    a.i(Insn::Const { d: Slot(-32), k: k16, len: 16 });
    a.i(Insn::Fill { d: Slot(-16), k: k4, elem_size: 4, count: 3 });
    a.i(Insn::ImmW64 { d: Slot(-80), imm: u64::MAX });
    a.i(Insn::Zero { d: Slot(-79), len: 2 });
    a.i(Insn::MovW64 { d: Slot(-8), s: Slot(-80) });
    a.ret(Slot(-64), 64);
    let f_misc = w.add_function(func(a.done(), 96, 16, 64));

    // Memory: p@16 points at a 64-byte buffer holding 0..64. Results: 12 words at -96.
    let r = |i: i32| Slot(-96 + 8 * i);
    let p = Slot(16);
    let m = |k: i32| Mem { p, k };
    let mut a = Asm::new();
    a.sret(Slot(-112));
    a.i(Insn::Zero { d: r(0), len: 96 });
    a.i(Insn::LoadW32 { d: r(0), m: m(4) });
    a.i(Insn::LoadW64 { d: r(1), m: m(0) });
    a.i(Insn::LoadW8 { d: r(11), m: m(63) });
    a.i(Insn::StoreW16 { m: m(10), s: r(0) });
    a.i(Insn::StoreW8 { m: m(0), s: r(0) });
    a.i(Insn::LoadCopy { d: r(2), m: m(16), len: 8 });
    a.i(Insn::StoreCopy { m: m(32), s: r(2), len: 8 });
    a.i(Insn::LoadCopy { d: r(3), m: m(0), len: 2 });
    a.i(Insn::PtrAdd { d: r(4), p, imm: 48 });
    a.i(Insn::ImmW64 { d: r(5), imm: 4 });
    a.i(Insn::Memcpy { dp: r(4), sp: p, n: r(5) });
    a.i(Insn::PtrAdd { d: r(6), p, imm: 56 });
    a.i(Insn::ImmW8 { d: r(7), imm: 0xee });
    a.i(Insn::Memset { dp: r(6), b: r(7), n: r(5) });
    a.i(Insn::PtrAdd { d: r(8), p, imm: 41 });
    a.i(Insn::PtrAdd { d: r(9), p, imm: 40 });
    a.i(Insn::Memmove { dp: r(8), sp: r(9), n: r(5) });
    a.i(Insn::PtrIndex { d: r(10), p, i: r(5), stride: 3 });
    a.i(Insn::StoreCopy { m: Mem { p: r(10), k: 0 }, s: r(7), len: 1 });
    a.ret(r(0), 96);
    let f_mem = w.add_function(func(a.done(), 112, 8, 96));
    let img = build(w, &[]);

    let x = 0x8899_aabb_ccdd_eeff_0011_2233_4455_6677u128;
    let r: [u128; 5] = ok(img.id(f_mov), (x,));
    assert_eq!(r, [x & 0xff, x & 0xffff, x & 0xffff_ffff, x & u64::MAX as u128, x]);

    let r: [u128; 4] = ok(img.id(f_misc), (x,));
    assert_eq!(r[0], x & ((1 << 56) - 1));
    assert_eq!(r[1], 0x1122_3344_5566_7788_99aa_bbcc_ddee_ff00);
    assert_eq!(r[2], 0x0f0e0d0c0b0a09080706050403020100);
    assert_eq!(r[3] as u64, 0xa1b2c3d4_a1b2c3d4);
    assert_eq!((r[3] >> 64) as u64, 0xffff_ffff_ff00_00ff, "zero + mov.w64");

    let mut buf: [u8; 64] = std::array::from_fn(|i| i as u8);
    let p = buf.as_mut_ptr();
    let r: [u64; 12] = ok(img.id(f_mem), (p,));
    assert_eq!(r[0], 0x07060504);
    assert_eq!(r[1], 0x0706050403020100);
    assert_eq!(r[2], u64::from_le_bytes(std::array::from_fn(|i| 16 + i as u8)));
    assert_eq!(r[3], 0x0104, "load.copy of [p] after the stores");
    assert_eq!(r[4], p as u64 + 48);
    assert_eq!(r[10], p as u64 + 12);
    assert_eq!(r[11], 63);
    let mut want: [u8; 64] = std::array::from_fn(|i| i as u8);
    want[10] = 4;
    want[11] = 5;
    want[0] = 4;
    want[32..40].copy_from_slice(&std::array::from_fn::<u8, 8, _>(|i| 16 + i as u8));
    want[48..52].copy_from_slice(&[4, 1, 2, 3]);
    want[56..60].copy_from_slice(&[0xee; 4]);
    want[41..45].copy_from_slice(&[40, 41, 42, 43]);
    want[12] = 0xee;
    assert_eq!(buf, want);
}

static STATIC_VAL: u64 = 0x1122;
#[repr(transparent)]
struct SyncPtr(*const ());
unsafe impl Sync for SyncPtr {}
/// Plays an `__imp_` import slot: holds the address of `STATIC_VAL`.
static IMP_STATIC: SyncPtr = SyncPtr((&raw const STATIC_VAL).cast());

#[test]
fn addresses_and_fixups() {
    let mut w = ImageWriter::new(unique_scid());
    let s_static = w.symbol("static", 0);
    let s_imp = w.symbol("imp", SYM_INDIRECT);
    let k = w.add_const(&0x5555_6666_7777_8888u64.to_le_bytes(), 8, &[]);
    let kp = w.add_const(
        &[0; 16],
        8,
        &[
            AllocReloc { offset: 0, target: AllocTarget::Symbol(s_static), addend: 0 },
            AllocReloc { offset: 8, target: AllocTarget::Const(k), addend: 2 },
        ],
    );
    let data = w.add_data(
        &[0xab; 24],
        8,
        &[AllocReloc { offset: 16, target: AllocTarget::Const(k), addend: 0 }],
        &[AllocFixup { offset: 8, sym: s_imp, addend: 4 }],
    );
    let mut a = Asm::new();
    a.sret(Slot(-80));
    a.i(Insn::AddrSym { d: Slot(-64), sym: s_static });
    a.i(Insn::AddrSymInd { d: Slot(-56), sym: s_imp });
    a.i(Insn::AddrConst { d: Slot(-48), a: Abs::Const(k) });
    a.i(Insn::AddrConst { d: Slot(-40), a: Abs::Data(data) });
    a.i(Insn::Addr { d: Slot(-32), s: Slot(-24) });
    a.i(Insn::ImmW64 { d: Slot(-24), imm: 0x99 });
    a.i(Insn::LoadW64 { d: Slot(-16), m: Mem { p: Slot(-32), k: 0 } });
    a.i(Insn::AddrConst { d: Slot(-8), a: Abs::Const(kp) });
    a.ret(Slot(-64), 64);
    let f = w.add_function(func(a.done(), 80, 0, 64));
    let img = build(w, &[("static", addr(&raw const STATIC_VAL)), ("imp", addr(&raw const IMP_STATIC))]);

    let r: [usize; 8] = ok(img.id(f), ());
    let sv = addr(&raw const STATIC_VAL);
    assert_eq!(r[0], sv);
    assert_eq!(r[1], sv, "addr.sym.ind loads through the slot");
    assert_eq!(unsafe { *(r[2] as *const u64) }, 0x5555_6666_7777_8888);
    let d = r[3] as *const u8;
    assert_eq!(unsafe { *d }, 0xab);
    // The PE fixup was applied at registration: *imp_slot + 4.
    assert_eq!(unsafe { *(d.add(8) as *const usize) }, sv + 4);
    assert_eq!(unsafe { *(d.add(16) as *const usize) }, r[2], "intra-image pointer in the data area");
    assert_ne!(r[4], 0, "addr is a frame address");
    assert_eq!(r[5], 0x99);
    assert_eq!(r[6], 0x99);
    let kp = r[7] as *const usize;
    assert_eq!(unsafe { *kp }, sv, "constant pointing at a symbol");
    assert_eq!(unsafe { *kp.add(1) }, r[2] + 2, "constant pointing into the pool");
}

#[test]
fn control_flow() {
    let mut w = ImageWriter::new(unique_scid());
    // sum(n) = 1 + … + n: n@16, s@-8, i@-16. A loop: its head is a backward branch target.
    let mut a = Asm::new();
    a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 1 });
    let top = a.i(Insn::BrLtUW64 { a: Slot(16), b: Slot(-16), neg: T, t: Target(0) });
    a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(-16) });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    let j = a.i(Insn::Jmp { t: Target(0) });
    a.patch(j, "t", top);
    let exit = a.ret(Slot(-8), 8);
    a.patch(top, "t", exit);
    let f_sum = w.add_function(func(a.done(), 16, 8, 8));

    // A long loop body (rel32 branches both ways): sum of 3i for i < n, with 40 adds of i
    // and 37 subtractions per iteration.
    let mut a = Asm::new();
    a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
    let top = a.i(Insn::BrEqW64 { a: Slot(16), b: Slot(-16), neg: T, t: Target(0) });
    for k in 0..77 {
        if k < 40 {
            a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(-16) });
        } else {
            a.i(Insn::SubW64 { d: Slot(-8), a: Slot(-8), b: Slot(-16) });
        }
    }
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    let j = a.i(Insn::Jmp { t: Target(0) });
    a.patch(j, "t", top);
    let exit = a.ret(Slot(-8), 8);
    a.patch(top, "t", exit);
    let f_long = w.add_function(func(a.done(), 16, 8, 8));

    // br and br! : b@16 → 10 + 2*b via both polarities.
    let mut a = Asm::new();
    a.i(Insn::ImmW32 { d: Slot(-16), imm: 10 });
    let b1 = a.i(Insn::Br { s: Slot(16), neg: F, t: Target(0) });
    a.i(Insn::AddImmW32 { d: Slot(-16), a: Slot(-16), imm: 1 });
    let l1 = a.i(Insn::Br { s: Slot(16), neg: T, t: Target(0) });
    a.patch(b1, "t", l1);
    a.ret(Slot(-16), 4);
    let l2 = a.i(Insn::AddImmW32 { d: Slot(-16), a: Slot(-16), imm: 1 });
    a.patch(l1, "t", l2);
    a.ret(Slot(-16), 4);
    let f_br = w.add_function(func(a.done(), 16, 1, 4));

    // Fused compares: (a, b) → bit 0: a == b (br.eq!, w64), bit 1: a <s b (w8), bit 2:
    // a >u 100 (br.gt.u.imm!, w32), bit 3: a == 7 (br.eq.imm, w16), bit 4: a <u b (br.lt.u!,
    // w16).
    let mut a = Asm::new();
    a.i(Insn::ImmW32 { d: Slot(-16), imm: 0 });
    let bit = |a: &mut Asm, insn: Insn<'_>, neg: bool, v: u32| {
        // `neg`: the branch skips the `or` when the condition holds, else when it doesn't.
        let b = a.i(insn);
        if neg {
            a.i(Insn::OrImmW32 { d: Slot(-16), a: Slot(-16), imm: v });
            let n = a.pos();
            a.patch(b, "t", n);
        } else {
            let j = a.i(Insn::Jmp { t: Target(0) });
            let s = a.i(Insn::OrImmW32 { d: Slot(-16), a: Slot(-16), imm: v });
            a.patch(b, "t", s);
            let n = a.pos();
            a.patch(j, "t", n);
        }
    };
    bit(&mut a, Insn::BrEqW64 { a: Slot(16), b: Slot(24), neg: F, t: Target(0) }, true, 1);
    bit(&mut a, Insn::BrLtSW8 { a: Slot(16), b: Slot(24), neg: T, t: Target(0) }, false, 2);
    bit(&mut a, Insn::BrGtUImmW32 { a: Slot(16), imm: 100, neg: F, t: Target(0) }, true, 4);
    bit(&mut a, Insn::BrEqImmW16 { a: Slot(16), imm: 7, neg: T, t: Target(0) }, false, 8);
    bit(&mut a, Insn::BrLtUW16 { a: Slot(16), b: Slot(24), neg: F, t: Target(0) }, true, 16);
    a.ret(Slot(-16), 4);
    let f_cmp = w.add_function(func(a.done(), 16, 16, 4));

    // Fused compare with an immediate at 128 bits: x > -5 (signed).
    let mut a = Asm::new();
    a.i(Insn::ImmW32 { d: Slot(-16), imm: 0 });
    let b = a.i(Insn::BrGtSImmW128 { a: Slot(16), imm: (-5i128) as u128, neg: T, t: Target(0) });
    a.ret(Slot(-16), 4);
    let t = a.i(Insn::ImmW32 { d: Slot(-16), imm: 1 });
    a.patch(b, "t", t);
    a.ret(Slot(-16), 4);
    let f_gt = w.add_function(func(a.done(), 16, 16, 4));

    // switch.dense at every width: x@16 (u128); cases base..base+3 return 100+i, else 99.
    macro_rules! dense {
        ($v:ident, $base:expr) => {{
            let mut a = Asm::new();
            let tw = [0u32; 3];
            let sw = a.i(Insn::$v { s: Slot(16), base: $base, default: Target(0), table: List::from_words(&tw) });
            for i in 0..3 {
                let at = a.i(Insn::ImmW32 { d: Slot(-16), imm: 100 + i as u32 });
                a.patch_list(sw, "table", i, at);
                a.ret(Slot(-16), 4);
            }
            let d = a.i(Insn::ImmW32 { d: Slot(-16), imm: 99 });
            a.patch(sw, "default", d);
            a.ret(Slot(-16), 4);
            w.add_function(func(a.done(), 16, 16, 4))
        }};
    }
    let dense_fns = [
        (8u32, dense!(SwitchDenseW8, 0xfe)),
        (16, dense!(SwitchDenseW16, 0xfffe)),
        (32, dense!(SwitchDenseW32, 7)),
        (64, dense!(SwitchDenseW64, 1 << 40)),
        (128, dense!(SwitchDenseW128, u128::MAX - 1)),
    ];

    // switch.sparse with 3 (linear) and 7 (binary search) cases.
    macro_rules! sparse {
        ($v:ident, $case:ident, $vals:expr) => {{
            let vals = $vals;
            let mut a = Asm::new();
            let cw = list_words(vals.iter().map(|&v| $case { value: v, target: Target(0) }));
            let sw = a.i(Insn::$v { s: Slot(16), default: Target(0), cases: List::from_words(&cw) });
            let mut targets = vec![];
            for i in 0..vals.len() {
                targets.push(a.i(Insn::ImmW32 { d: Slot(-16), imm: 100 + i as u32 }));
                a.ret(Slot(-16), 4);
            }
            let d = a.i(Insn::ImmW32 { d: Slot(-16), imm: 99 });
            a.patch(sw, "default", d);
            a.ret(Slot(-16), 4);
            let mut code = a.done();
            // Patch case targets: each case's last word, after the count word.
            let ew = cw.len() / vals.len();
            let base = sw as usize + ryo_bytecode::full::off::$v::cases + 1;
            for (i, t) in targets.iter().enumerate() {
                code[base + i * ew + ew - 1] = t.wrapping_sub(sw);
            }
            (vals.iter().map(|&v| v as u128).collect::<Vec<_>>(), w.add_function(func(code, 16, 16, 4)))
        }};
    }
    let sparse_fns = [
        (8u32, sparse!(SwitchSparseW8, Case8, [1u8, 5, 200])),
        (16, sparse!(SwitchSparseW16, Case16, [0u16, 2, 3, 4, 9, 300, 0xfff0])),
        (32, sparse!(SwitchSparseW32, Case32, [0u32, 3, 9, 10, 11, 1000, 0xffff_fff0])),
        (64, sparse!(SwitchSparseW64, Case64, [2u64, 1 << 33, u64::MAX])),
        (128, sparse!(SwitchSparseW128, Case128, [0u128, 1, 7, 1 << 64, 1 << 100, 1 << 127, u128::MAX])),
    ];
    let img = build(w, &[]);

    assert_eq!(ok::<_, u64>(img.id(f_sum), (100u64,)), 5050);
    assert_eq!(ok::<_, u64>(img.id(f_sum), (0u64,)), 0);
    assert_eq!(ok::<_, u64>(img.id(f_long), (10u64,)), 3 * 45);
    assert_eq!(ok::<_, u64>(img.id(f_long), (0u64,)), 0);
    assert_eq!(ok::<_, u32>(img.id(f_br), (true,)), 12);
    assert_eq!(ok::<_, u32>(img.id(f_br), (false,)), 10);
    let cmp = |a: u64, b: u64| -> u32 {
        (a == b) as u32
            | (((a as i8) < (b as i8)) as u32) << 1
            | ((a as u32 > 100) as u32) << 2
            | ((a as u16 == 7) as u32) << 3
            | (((a as u16) < (b as u16)) as u32) << 4
    };
    for (x, y) in [(7u64, 7u64), (7, 8), (0xff, 1), (1, 0xff), (101, 3), (100, 100), (0x1_0007, 0x2_0000), (1 << 40, 1 << 40 | 1)] {
        assert_eq!(ok::<_, u32>(img.id(f_cmp), (x, y)), cmp(x, y), "cmp {x:#x} {y:#x}");
    }
    assert_eq!(ok::<_, u32>(img.id(f_gt), (-4i128,)), 1);
    assert_eq!(ok::<_, u32>(img.id(f_gt), (-5i128,)), 0);
    assert_eq!(ok::<_, u32>(img.id(f_gt), (i128::MIN,)), 0);
    assert_eq!(ok::<_, u32>(img.id(f_gt), (i128::MAX,)), 1);
    for (n, f) in dense_fns {
        let mask = if n == 128 { u128::MAX } else { (1u128 << n) - 1 };
        let base: u128 = match n {
            8 => 0xfe,
            16 => 0xfffe,
            32 => 7,
            64 => 1 << 40,
            _ => u128::MAX - 1,
        };
        for i in 0..6u128 {
            let x = base.wrapping_add(i) & mask;
            let want = if i < 3 { 100 + i as u32 } else { 99 };
            // High garbage above the width must be ignored.
            let arg = if n == 128 { x } else { x | (0xdead << 112) };
            assert_eq!(ok::<_, u32>(img.id(f), (arg,)), want, "dense w{n} {x:#x}");
        }
    }
    for (n, (vals, f)) in sparse_fns {
        for (i, &v) in vals.iter().enumerate() {
            assert_eq!(ok::<_, u32>(img.id(f), (v,)), 100 + i as u32, "sparse w{n} {v:#x}");
            if !vals.contains(&(v.wrapping_add(1))) && (n == 128 || v + 1 < 1 << n) {
                assert_eq!(ok::<_, u32>(img.id(f), (v.wrapping_add(1),)), 99, "sparse w{n} miss");
            }
        }
    }
}

#[test]
fn calls_and_tail_calls() {
    let mut w = ImageWriter::new(unique_scid());
    // fib(n): n@16, t1@-8, t2@-16; the outgoing argument at -32 (F = 32).
    let mut a = Asm::new();
    let b = a.i(Insn::BrLtUImmW64 { a: Slot(16), imm: 2, neg: T, t: Target(0) });
    a.i(Insn::SubImmW64 { d: Slot(-32), a: Slot(16), imm: 1 });
    a.i(Insn::Call { d: Slot(-8), f: Func(0), k: 8, a: List::from_words(&[]) });
    a.i(Insn::SubImmW64 { d: Slot(-32), a: Slot(16), imm: 2 });
    a.i(Insn::Call { d: Slot(-16), f: Func(0), k: 8, a: List::from_words(&[]) });
    a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(-16) });
    a.ret(Slot(-8), 8);
    let base = a.ret(Slot(16), 8);
    a.patch(b, "t", base);
    let fib = w.add_function(func(a.done(), 32, 8, 8));
    assert_eq!(fib, Func(0));

    // countdown(n, acc) = countdown(n - 1, acc + n) by tail call: 10^6 deep, far beyond what
    // the stack would hold without frame reuse. n@16, acc@24, the staged block at -16.
    let mut a = Asm::new();
    let b = a.i(Insn::BrEqImmW64 { a: Slot(16), imm: 0, neg: T, t: Target(0) });
    a.i(Insn::SubImmW64 { d: Slot(-16), a: Slot(16), imm: 1 });
    a.i(Insn::AddW64 { d: Slot(-8), a: Slot(24), b: Slot(16) });
    // The staged arguments over the incoming ones, then the jump.
    a.i(Insn::MovW128 { d: Slot(16), s: Slot(-16) });
    a.i(Insn::TailCall { f: Func(1), a: List::from_words(&[]) });
    let done = a.ret(Slot(24), 8);
    a.patch(b, "t", done);
    let countdown = w.add_function(func(a.done(), 16, 16, 8));

    // Calls countdown(n, 0) + 1 through `call`, so the tail-called frames return into a VM
    // caller.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-32), s: Slot(16) });
    a.i(Insn::ImmW64 { d: Slot(-24), imm: 0 });
    a.i(Insn::Call { d: Slot(-8), f: countdown, k: 8, a: List::from_words(&[]) });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    a.ret(Slot(-8), 8);
    let wrap = w.add_function(func(a.done(), 32, 8, 8));

    // A tail call to a different function with a smaller argument block: half(n, _) =
    // become fib(n / 2).
    let mut a = Asm::new();
    a.i(Insn::ShrUImmW64 { d: Slot(-16), a: Slot(16), imm: 1 });
    a.i(Insn::MovW64 { d: Slot(16), s: Slot(-16) });
    a.i(Insn::TailCall { f: fib, a: List::from_words(&[]) });
    let half = w.add_function(func(a.done(), 16, 16, 8));

    // A 24-byte return value through `call` (sret), and a caller that returns it with an offset.
    let mut a = Asm::new();
    a.sret(Slot(-48));
    a.i(Insn::MovW64 { d: Slot(-32), s: Slot(16) });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(16), imm: 1 });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(16), imm: 2 });
    a.ret(Slot(-32), 24);
    let triple = w.add_function(func(a.done(), 48, 8, 24));
    let mut a = Asm::new();
    a.sret(Slot(-72));
    a.i(Insn::ImmW64 { d: Slot(-48), imm: 0 });
    a.i(Insn::MovW64 { d: Slot(-80), s: Slot(16) });
    // An sret callee: the destination's address in `rdi`.
    let sret = [-40i32 as u32, ryo_bytecode::asm::ArgReg { xmm: false, size: 8, index: 0 }.word() | ryo_bytecode::asm::ARG_ADDR];
    a.i(Insn::Call { d: Slot(0), f: triple, k: 0, a: List::from_words(&sret) });
    a.ret(Slot(-48), 32);
    let call_triple = w.add_function(func(a.done(), 80, 8, 32));
    let img = build(w, &[]);

    assert_eq!(ok::<_, u64>(img.id(fib), (20u64,)), 6765);
    let n = 1_000_000u64;
    assert_eq!(ok::<_, u64>(img.id(countdown), (n, 0u64)), n * (n + 1) / 2);
    assert_eq!(ok::<_, u64>(img.id(wrap), (n,)), n * (n + 1) / 2 + 1);
    assert_eq!(ok::<_, u64>(img.id(half), (40u64, 0u64)), 6765);
    assert_eq!(ok::<_, [u64; 4]>(img.id(call_triple), (5u64,)), [0, 5, 6, 7]);
}

#[test]
fn deep_recursion() {
    // depth(n) = n == 0 ? 0 : depth(n - 1) + 1, 10^6 frames of 32 bytes deep.
    let mut w = ImageWriter::new(unique_scid());
    let mut a = Asm::new();
    let b = a.i(Insn::BrEqImmW64 { a: Slot(16), imm: 0, neg: T, t: Target(0) });
    a.i(Insn::SubImmW64 { d: Slot(-16), a: Slot(16), imm: 1 });
    a.i(Insn::Call { d: Slot(-8), f: Func(0), k: 8, a: List::from_words(&[]) });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    a.ret(Slot(-8), 8);
    let z = a.ret(Slot(16), 8);
    a.patch(b, "t", z);
    w.add_function(func(a.done(), 16, 8, 8));
    let id = build(w, &[]).id(Func(0));
    assert_eq!(big_stack(256, move || ok::<_, u64>(id, (1_000_000u64,))), 1_000_000);
}

#[test]
fn large_frames() {
    let mut w = ImageWriter::new(unique_scid());
    // big(n, x) = n == 0 ? x : big(n - 1, x + 1), with a 64 KiB frame (stack probe) whose
    // deepest local carries x + 1. n@16, x@24, r@-8, the outgoing block at -F.
    const FS: i32 = 65536 + 32;
    let mut a = Asm::new();
    let b = a.i(Insn::BrEqImmW64 { a: Slot(16), imm: 0, neg: T, t: Target(0) });
    a.i(Insn::MovW64 { d: Slot(-FS + 16), s: Slot(24) });
    a.i(Insn::AddImmW64 { d: Slot(-FS + 16), a: Slot(-FS + 16), imm: 1 });
    a.i(Insn::SubImmW64 { d: Slot(-FS), a: Slot(16), imm: 1 });
    a.i(Insn::MovW64 { d: Slot(-FS + 8), s: Slot(-FS + 16) });
    a.i(Insn::Call { d: Slot(-8), f: Func(0), k: 8, a: List::from_words(&[]) });
    a.ret(Slot(-8), 8);
    let base = a.ret(Slot(24), 8);
    a.patch(b, "t", base);
    let big = w.add_function(func(a.done(), FS as u32, 16, 8));

    // At the probe threshold exactly, and just below it: f(x) = x via the lowest local.
    let mut fs = vec![];
    for size in [4096u32, 4080, 1 << 20] {
        let s = -(size as i32);
        let mut a = Asm::new();
        a.i(Insn::Zero { d: Slot(s), len: size });
        a.i(Insn::MovW64 { d: Slot(s), s: Slot(16) });
        a.ret(Slot(s), 8);
        fs.push(w.add_function(func(a.done(), size, 8, 8)));
    }
    let img = build(w, &[]);
    for &f in &fs {
        assert_eq!(ok::<_, u64>(img.id(f), (77u64,)), 77);
    }
    let id = img.id(big);
    assert_eq!(big_stack(64, move || ok::<_, u64>(id, (200u64, 5u64))), 205);
}

// ---- multi-image calls ----

const K_B: u64 = 1000;

/// Image B: g(x) = 3x + K_B (K_B from B's constant pool), native-callable: x in `rdi`.
fn image_b() -> &'static Linked {
    static B: OnceLock<Linked> = OnceLock::new();
    B.get_or_init(|| {
        let mut w = ImageWriter::new(unique_scid());
        let k = w.add_const(&K_B.to_le_bytes(), 8, &[]);
        let mut a = Asm::new();
        a.i(arg(-24, 0));
        a.i(Insn::Const { d: Slot(-16), k, len: 8 });
        a.i(Insn::MulImmW64 { d: Slot(-8), a: Slot(-24), imm: 3 });
        a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(-16) });
        a.ret(Slot(-8), 8);
        w.add_function(func(a.done(), 32, 8, 8));
        build(w, &[])
    })
}

fn native_add(a: u64, b: u64) -> u64 {
    a + b
}
fn native_double(x: u64) -> u64 {
    2 * x
}

/// Plays an `__imp_` slot holding g's address.
static IMP_G: AtomicUsize = AtomicUsize::new(0);

#[test]
fn multi_image_calls() {
    let b = image_b();
    let pg = b.code(Func(0)) as usize;
    IMP_G.store(pg, Ordering::Relaxed);
    let mut w = ImageWriter::new(unique_scid());
    let s_g = w.symbol("g", 0);
    let s_add = w.symbol("native_add", 0);
    let s_imp = w.symbol("imp_g", SYM_INDIRECT);
    let k_a = w.add_const(&7u64.to_le_bytes(), 8, &[]);
    let x = regs(&[16]);
    let px = regs(&[24]);

    // f0(x) = g(x) + 7 via call.sym; the + 7 reads A's pool after returning from B.
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-8), sym: s_g, k: 8, a: List::from_words(&x) });
    a.i(Insn::Const { d: Slot(-24), k: k_a, len: 8 });
    a.i(Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(-24) });
    a.ret(Slot(-8), 8);
    let f0 = w.add_function(func(a.done(), 32, 8, 8));

    // f1(a, b) = native_add(a, b).
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-8), sym: s_add, k: 8, a: List::from_words(&regs(&[16, 24])) });
    a.ret(Slot(-8), 8);
    let f1 = w.add_function(func(a.done(), 16, 16, 8));

    // f2(x) = g(x) via call.sym.ind through an import slot.
    let mut a = Asm::new();
    a.i(Insn::CallSymInd { d: Slot(-8), sym: s_imp, k: 8, a: List::from_words(&x) });
    a.ret(Slot(-8), 8);
    let f2 = w.add_function(func(a.done(), 16, 8, 8));

    // f3(p, x) = p(x) via call.ptr.
    let mut a = Asm::new();
    a.i(Insn::CallPtr { d: Slot(-8), p: Slot(16), k: 8, a: List::from_words(&px) });
    a.ret(Slot(-8), 8);
    let f3 = w.add_function(func(a.done(), 16, 16, 8));

    // f4(p, x) = become p(x).
    let mut a = Asm::new();
    a.i(Insn::TailCallPtr { p: Slot(16), a: List::from_words(&px) });
    let f4 = w.add_function(func(a.done(), 16, 16, 8));

    // f5(p, x) = f4(p, x) + 1, so f4's tail call happens in a called frame.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(-32), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(-24), s: Slot(24) });
    a.i(Insn::Call { d: Slot(-8), f: f4, k: 8, a: List::from_words(&[]) });
    a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    a.ret(Slot(-8), 8);
    let f5 = w.add_function(func(a.done(), 32, 16, 8));

    let img = build(w, &[("g", pg), ("native_add", native_add as *const () as usize), ("imp_g", addr(&raw const IMP_G))]);

    for x in [0u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img.id(f0), (x,)), 3 * x + K_B + 7);
    }
    assert_eq!(ok::<_, u64>(img.id(f1), (40u64, 2u64)), 42);
    assert_eq!(ok::<_, u64>(img.id(f2), (2u64,)), 6 + K_B);
    let nd = native_double as *const () as usize;
    assert_eq!(ok::<_, u64>(img.id(f3), (pg, 4u64)), 12 + K_B, "VM target");
    assert_eq!(ok::<_, u64>(img.id(f3), (nd, 5u64)), 10, "native target");
    // tail_call.ptr: VM and native targets, from the test's call and from a VM caller.
    assert_eq!(ok::<_, u64>(img.id(f4), (pg, 1u64)), 3 + K_B);
    assert_eq!(ok::<_, u64>(img.id(f5), (pg, 1u64)), 4 + K_B);
    assert_eq!(ok::<_, u64>(img.id(f4), (nd, 21u64)), 42);
    assert_eq!(ok::<_, u64>(img.id(f5), (nd, 21u64)), 43);

    // g itself, called natively.
    let g: fn(u64) -> u64 = unsafe { std::mem::transmute(pg) };
    assert_eq!(g(10), 30 + K_B);
}

#[test]
fn registration() {
    let mk = |v: u32| {
        let mut w = ImageWriter::new(unique_scid());
        let mut a = Asm::new();
        a.i(Insn::ImmW32 { d: Slot(-16), imm: v });
        a.ret(Slot(-16), 4);
        w.add_function(func(a.done(), 16, 0, 4));
        assemble(w, &[])
    };
    let (x, y) = (mk(1), mk(2));
    // Registered together, one of them twice: duplicates are skipped.
    register(&[&x, &y, &x]);
    register(&[&y]);
    assert_eq!(ok::<_, u32>(x.id(Func(0)), ()), 1);
    assert_eq!(ok::<_, u32>(y.id(Func(0)), ()), 2);
    // Later registrations keep earlier images working.
    let z = mk(3);
    register(&[&z]);
    assert_eq!(ok::<_, u32>(z.id(Func(0)), ()), 3);
    assert_eq!(ok::<_, u32>(x.id(Func(0)), ()), 1);
}

// ---- re-entrancy ----

/// The address of `r0`, VM code that native code calls.
static R0: AtomicUsize = AtomicUsize::new(0);

/// Native: r0(n - 1) + n (VM → native → VM).
fn reenter(n: u64) -> u64 {
    let r0: fn(u64) -> u64 = unsafe { std::mem::transmute(R0.load(Ordering::Relaxed)) };
    r0(n - 1) + n
}

#[test]
fn reentrancy() {
    let mut w = ImageWriter::new(unique_scid());
    let s = w.symbol("reenter", 0);
    // r0(n) = n == 0 ? 0 : reenter(n). n in `rdi`, kept at -16; r@-8.
    let mut a = Asm::new();
    a.i(arg(-16, 0));
    let b = a.i(Insn::BrEqImmW64 { a: Slot(-16), imm: 0, neg: F, t: Target(0) });
    a.ret(Slot(-16), 8);
    let l = a.i(Insn::CallSym { d: Slot(-8), sym: s, k: 8, a: List::from_words(&regs(&[-16])) });
    a.patch(b, "t", l);
    a.ret(Slot(-8), 8);
    w.add_function(func(a.done(), 16, 8, 8));
    let img = build(w, &[("reenter", reenter as *const () as usize)]);
    R0.store(img.code(Func(0)) as usize, Ordering::Relaxed);
    let id = img.id(Func(0));
    for n in [0u64, 1, 2, 50] {
        assert_eq!(ok::<_, u64>(id, (n,)), n * (n + 1) / 2);
    }
    // 1000 nested calls through native code: needs more native stack than a test thread has
    // in debug builds.
    assert_eq!(big_stack(256, move || ok::<_, u64>(id, (1000u64,))), 500500);
    let hs: Vec<_> = (0..4u64).map(|t| std::thread::spawn(move || ok::<_, u64>(id, (100 + t,)))).collect();
    for (t, h) in hs.into_iter().enumerate() {
        let n = 100 + t as u64;
        assert_eq!(h.join().unwrap(), n * (n + 1) / 2);
    }
}

// ---- unwinding ----

#[derive(Debug, PartialEq)]
struct Boom(u64);

fn boom(x: u64) -> u64 {
    if x == 7 {
        resume_unwind(Box::new(Boom(x)))
    }
    x
}

/// The address of `u2`, VM code that native code calls.
static U2: AtomicUsize = AtomicUsize::new(0);

/// Native: u2(x, log) + 100 (a nested VM call that may unwind).
fn via_native(x: u64, log: u64) -> u64 {
    let u2: fn(u64, u64) -> u64 = unsafe { std::mem::transmute(U2.load(Ordering::Relaxed)) };
    u2(x, log) + 100
}

fn image_u() -> &'static Linked {
    static U: OnceLock<Linked> = OnceLock::new();
    U.get_or_init(|| {
        let mut w = ImageWriter::new(unique_scid());
        let s_boom = w.symbol("boom", 0);
        let s_via = w.symbol("via_native", 0);
        // u1(x, log) = boom(x); landing pad: log[0] = 999, resume. x@16, log@24, r@-8,
        // exception@-24, tmp@-32.
        let mut a = Asm::new();
        let call = a.i(Insn::CallSym { d: Slot(-8), sym: s_boom, k: 8, a: List::from_words(&regs(&[16])) });
        a.ret(Slot(-8), 8);
        let c = a.i(Insn::Lpad { x: Slot(-24) });
        a.i(Insn::ImmW64 { d: Slot(-32), imm: 999 });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 0 }, s: Slot(-32) });
        let r = a.i(Insn::Resume { x: Slot(-24) });
        let mut f = func(a.done(), 32, 16, 8);
        // The resume continues in the caller.
        f.cleanup = vec![CleanupEntry { offset: call, target: c }, CleanupEntry { offset: r, target: CONTINUE }];
        assert_eq!(w.add_function(f), Func(0));

        // u0(x, log) = u1(x, log), then log[1] = 1. A Continue entry: the frame is popped.
        let mut a = Asm::new();
        a.i(Insn::MovW64 { d: Slot(-32), s: Slot(16) });
        a.i(Insn::MovW64 { d: Slot(-24), s: Slot(24) });
        let call = a.i(Insn::Call { d: Slot(-8), f: Func(0), k: 8, a: List::from_words(&[]) });
        a.i(Insn::ImmW64 { d: Slot(-16), imm: 1 });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 8 }, s: Slot(-16) });
        a.ret(Slot(-8), 8);
        let mut f = func(a.done(), 32, 16, 8);
        f.cleanup = vec![CleanupEntry { offset: call, target: CONTINUE }];
        assert_eq!(w.add_function(f), Func(1));

        // u2(x, log) = u0(x, log), native-callable (x, log in `rdi`, `rsi`, kept at -56,
        // -64); landing pad `lpad; jmp` to a block that sets log[2] = 555 and resumes.
        let mut a = Asm::new();
        a.i(arg(-56, 0));
        a.i(arg(-64, 1));
        a.i(Insn::MovW64 { d: Slot(-80), s: Slot(-56) });
        a.i(Insn::MovW64 { d: Slot(-72), s: Slot(-64) });
        let call = a.i(Insn::Call { d: Slot(-8), f: Func(1), k: 8, a: List::from_words(&[]) });
        a.ret(Slot(-8), 8);
        let c = a.i(Insn::Lpad { x: Slot(-24) });
        let j = a.i(Insn::Jmp { t: Target(0) });
        a.i(Insn::Abort {});
        let l = a.i(Insn::ImmW64 { d: Slot(-16), imm: 555 });
        a.patch(j, "t", l);
        a.i(Insn::StoreW64 { m: Mem { p: Slot(-64), k: 16 }, s: Slot(-16) });
        let r = a.i(Insn::Resume { x: Slot(-24) });
        let mut f = func(a.done(), 80, 16, 8);
        f.cleanup = vec![CleanupEntry { offset: call, target: c }, CleanupEntry { offset: r, target: CONTINUE }];
        assert_eq!(w.add_function(f), Func(2));

        // o(x, log) = via_native(x, log), native-callable (x, log kept at -40, -48); landing
        // pad: log[3] = 777.
        let mut a = Asm::new();
        a.i(arg(-40, 0));
        a.i(arg(-48, 1));
        let call = a.i(Insn::CallSym { d: Slot(-8), sym: s_via, k: 8, a: List::from_words(&regs(&[-40, -48])) });
        a.ret(Slot(-8), 8);
        let c = a.i(Insn::Lpad { x: Slot(-24) });
        a.i(Insn::ImmW64 { d: Slot(-32), imm: 777 });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(-48), k: 24 }, s: Slot(-32) });
        let r = a.i(Insn::Resume { x: Slot(-24) });
        let mut f = func(a.done(), 48, 16, 8);
        f.cleanup = vec![CleanupEntry { offset: call, target: c }, CleanupEntry { offset: r, target: CONTINUE }];
        assert_eq!(w.add_function(f), Func(3));

        // u4(x) = boom(x), Continue.
        let mut a = Asm::new();
        let call = a.i(Insn::CallSym { d: Slot(-8), sym: s_boom, k: 8, a: List::from_words(&regs(&[16])) });
        a.ret(Slot(-8), 8);
        let mut f = func(a.done(), 16, 8, 8);
        f.cleanup = vec![CleanupEntry { offset: call, target: CONTINUE }];
        assert_eq!(w.add_function(f), Func(4));

        // u5(p, x) = become p(x): no frame of its own to unwind through.
        let mut a = Asm::new();
        a.i(Insn::TailCallPtr { p: Slot(16), a: List::from_words(&regs(&[24])) });
        assert_eq!(w.add_function(func(a.done(), 16, 16, 8)), Func(5));

        // u6(p, x, log) = u5(p, x) with a landing pad: log[0] = 6.
        let mut a = Asm::new();
        a.i(Insn::MovW64 { d: Slot(-48), s: Slot(16) });
        a.i(Insn::MovW64 { d: Slot(-40), s: Slot(24) });
        let call = a.i(Insn::Call { d: Slot(-8), f: Func(5), k: 8, a: List::from_words(&[]) });
        a.ret(Slot(-8), 8);
        let c = a.i(Insn::Lpad { x: Slot(-24) });
        a.i(Insn::ImmW64 { d: Slot(-16), imm: 6 });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(32), k: 0 }, s: Slot(-16) });
        let r = a.i(Insn::Resume { x: Slot(-24) });
        let mut f = func(a.done(), 48, 24, 8);
        f.cleanup = vec![CleanupEntry { offset: call, target: c }, CleanupEntry { offset: r, target: CONTINUE }];
        assert_eq!(w.add_function(f), Func(6));

        let u = build(w, &[("boom", boom as *const () as usize), ("via_native", via_native as *const () as usize)]);
        U2.store(u.code(Func(2)) as usize, Ordering::Relaxed);
        u
    })
}

fn payload(e: Box<dyn std::any::Any + Send>) -> Boom {
    *e.downcast::<Boom>().expect("Boom payload")
}

#[test]
fn unwinding() {
    let u = image_u();
    let mut log = [0u64; 4];
    let lp = log.as_mut_ptr() as u64;

    // Normal path: no cleanup runs.
    assert_eq!(ok::<_, u64>(u.id(Func(2)), (3u64, lp)), 3);
    assert_eq!(log, [0, 1, 0, 0]);

    // Cleanup in u1, pop u0 (Continue), cleanup in u2, then out of `enter` with the payload.
    log = [0; 4];
    let e = call::<_, u64>(u.id(Func(2)), (7u64, lp)).unwrap_err();
    assert_eq!(payload(e), Boom(7));
    assert_eq!(log, [999, 0, 555, 0]);

    // Through native code: o → via_native → u2 → VM panics → unwinds through the native
    // frames → o's landing pad → out to us.
    log = [0; 4];
    let o: fn(u64, u64) -> u64 = unsafe { std::mem::transmute(u.code(Func(3))) };
    let e = catch_unwind(|| o(7, lp)).unwrap_err();
    assert_eq!(payload(e), Boom(7));
    assert_eq!(log, [999, 0, 555, 777]);
    assert_eq!(o(3, lp), 103);

    // A native callee.
    assert_eq!(ok::<_, u64>(u.id(Func(4)), (5u64,)), 5);
    assert_eq!(payload(call::<_, u64>(u.id(Func(4)), (7u64,)).unwrap_err()), Boom(7));

    // A tail call to native code, from the test's call and from a VM caller.
    let pb = boom as *const () as usize;
    assert_eq!(ok::<_, u64>(u.id(Func(5)), (pb, 5u64)), 5);
    assert_eq!(payload(call::<_, u64>(u.id(Func(5)), (pb, 7u64)).unwrap_err()), Boom(7));
    log = [0; 4];
    assert_eq!(ok::<_, u64>(u.id(Func(6)), (pb, 4u64, lp)), 4);
    assert_eq!(payload(call::<_, u64>(u.id(Func(6)), (pb, 7u64, lp)).unwrap_err()), Boom(7));
    assert_eq!(log, [6, 0, 0, 0]);

    // The VM still works on this thread after all that, and on others.
    assert_eq!(ok::<_, u64>(u.id(Func(2)), (4u64, lp)), 4);
    let id = u.id(Func(2));
    let e = std::thread::spawn(move || {
        let mut log = [0u64; 4];
        let r = call::<_, u64>(id, (7u64, log.as_mut_ptr() as u64)).map_err(payload);
        (r, log)
    })
    .join()
    .unwrap();
    assert_eq!(e, (Err(Boom(7)), [999, 0, 555, 0]));
}

// ---- fatal paths, each in a child process ----

fn say_terminate(_: u64) -> u64 {
    eprintln!("CATCH PAD RAN");
    std::process::abort()
}

/// Runs the fatal scenario named by `RYO_FATAL_CASE`; a no-op in normal test runs.
#[test]
fn fatal_child() {
    let Ok(case) = std::env::var("RYO_FATAL_CASE") else { return };
    let mut w = ImageWriter::new(unique_scid());
    let mut a = Asm::new();
    let mut cleanup = vec![];
    let s_boom = w.symbol("boom", 0);
    let s_term = w.symbol("say_terminate", 0);
    let mut fs = 32;
    let boom_call = |a: &mut Asm| {
        a.i(Insn::ImmW64 { d: Slot(-32), imm: 7 });
        a.i(Insn::CallSym { d: Slot(-8), sym: s_boom, k: 8, a: List::from_words(&regs(&[-32])) })
    };
    match case.as_str() {
        "overflow" | "overflow_probe" => {
            if case == "overflow_probe" {
                fs = 1 << 16;
            }
            a.i(Insn::Call { d: Slot(-8), f: Func(0), k: 8, a: List::from_words(&[]) });
            a.ret(Slot(-8), 8);
        }
        "unreachable" => {
            a.i(Insn::Unreachable {});
        }
        "abort" => {
            a.i(Insn::Abort {});
        }
        "no_entry" => {
            // A call that unwinds without a cleanup entry terminates.
            boom_call(&mut a);
            a.ret(Slot(-8), 8);
        }
        "catch" => {
            // A catch-all landing pad (a `Terminate` action): the search phase stops at it,
            // and it runs and terminates.
            let c = boom_call(&mut a);
            a.ret(Slot(-8), 8);
            let pad = a.i(Insn::Lpad { x: Slot(-24) });
            a.i(Insn::CallSym { d: Slot(-8), sym: s_term, k: 8, a: List::from_words(&regs(&[-32])) });
            a.i(Insn::Abort {});
            cleanup.push(CleanupEntry { offset: c, target: pad | CATCH });
        }
        _ => panic!("unknown case"),
    }
    let mut f = func(a.done(), fs, 0, 8);
    f.cleanup = cleanup;
    w.add_function(f);
    let img = build(w, &[("boom", boom as *const () as usize), ("say_terminate", say_terminate as *const () as usize)]);
    let r = call::<_, u64>(img.id(Func(0)), ());
    eprintln!("RETURNED {:?}", r.map_err(payload));
}

#[test]
fn fatal_paths() {
    let exe = std::env::current_exe().unwrap();
    for (case, msg) in [
        ("overflow", Some("has overflowed its stack")),
        ("overflow_probe", Some("has overflowed its stack")),
        ("unreachable", None),
        ("no_entry", Some("failed to initiate panic")),
        ("catch", Some("CATCH PAD RAN")),
        ("abort", None),
    ] {
        let out = std::process::Command::new(&exe)
            .args(["fatal_child", "--exact", "--nocapture", "--test-threads=1"])
            .env("RYO_FATAL_CASE", case)
            .output()
            .unwrap();
        let err = String::from_utf8_lossy(&out.stderr);
        assert!(!out.status.success(), "{case}: child succeeded\n{err}");
        assert!(!err.contains("RETURNED"), "{case}: returned\n{err}");
        if let Some(msg) = msg {
            assert!(err.contains(msg), "{case}: stderr lacks {msg:?}:\n{err}");
        }
    }
}

// ---- concurrency ----

#[test]
fn concurrent_registration() {
    // Image C: c(x) = x + 1, native-callable (x in `rdi`).
    let mut w = ImageWriter::new(unique_scid());
    let mut a = Asm::new();
    a.i(arg(-24, 0));
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-24), imm: 1 });
    a.ret(Slot(-16), 8);
    w.add_function(func(a.done(), 32, 8, 8));
    let c = assemble(w, &[]);
    let pc = c.code(Func(0)) as usize;

    // Image A: e(x) = c(x) via call.sym; i(p, x) = p(x) via call.ptr.
    let mut w = ImageWriter::new(unique_scid());
    let s_c = w.symbol("c", 0);
    let mut a = Asm::new();
    a.i(Insn::CallSym { d: Slot(-8), sym: s_c, k: 8, a: List::from_words(&regs(&[16])) });
    a.ret(Slot(-8), 8);
    let fe = w.add_function(func(a.done(), 16, 8, 8));
    let mut a = Asm::new();
    a.i(Insn::CallPtr { d: Slot(-8), p: Slot(16), k: 8, a: List::from_words(&regs(&[24])) });
    a.ret(Slot(-8), 8);
    let fi = w.add_function(func(a.done(), 16, 16, 8));
    let img = assemble(w, &[("c", pc)]);
    register(&[&c, &img]);
    let (ide, idi) = (img.id(fe), img.id(fi));

    let nd = native_double as *const () as usize;
    let hs: Vec<_> = (0..8u64)
        .map(|t| {
            std::thread::spawn(move || {
                for k in 0..300u64 {
                    if k % 50 == t {
                        // Snapshot churn while others call: a fresh one-function image.
                        let mut w = ImageWriter::new(unique_scid());
                        let mut a = Asm::new();
                        a.i(Insn::ImmW64 { d: Slot(-16), imm: k });
                        a.ret(Slot(-16), 8);
                        w.add_function(func(a.done(), 16, 0, 8));
                        let n = build(w, &[]);
                        assert_eq!(ok::<_, u64>(n.id(Func(0)), ()), k);
                    }
                    assert_eq!(ok::<_, u64>(ide, (k,)), k + 1);
                    let (p, want) = if (k + t) % 2 == 0 { (pc, k + 1) } else { (nd, 2 * k) };
                    assert_eq!(ok::<_, u64>(idi, (p, k)), want);
                }
            })
        })
        .collect();
    for h in hs {
        h.join().unwrap();
    }
}

// ---- JIT counters and the no-op trip (without the `jit` feature; tests/jit.rs has the JIT) ----

/// The record [`tick`] resets.
#[cfg(not(feature = "jit"))]
static TICK: AtomicUsize = AtomicUsize::new(0);

/// Native: runs `TICK`'s loop counter out, so that the next loop head's check trips.
#[cfg(not(feature = "jit"))]
fn tick() {
    unsafe { (*(TICK.load(Ordering::Relaxed) as *mut JitRecord)).ctr_l = 0 };
}

/// Functions run through the no-op JIT's trips, at the entry and at loop heads: arguments of
/// every kind (integer and SSE registers, the stack, an sret pointer) arrive intact, loops
/// keep their state, and the counter that tripped ends at a failed record's bias
/// (`-JIT_BIAS`), plus what ran since.
#[test]
#[cfg(not(feature = "jit"))]
fn jit_trips() {
    use ryo_bytecode::asm::ArgReg;
    let mut w = ImageWriter::new(unique_scid());
    let s_tick = w.symbol("tick", 0);

    // spill(p, a1..a5, x0..x7, s0, s1) = s0 + s1, storing a1..a5, x0..x7, s0, s1 at p[0..15].
    let mut a = Asm::new();
    for i in 0..6 {
        a.i(arg(-8 - 8 * i as i32, i));
    }
    for i in 0..8 {
        a.i(Insn::Arg { d: Slot(-56 - 8 * i as i32), r: ArgReg { xmm: true, size: 8, index: i }.word() });
    }
    let mut srcs: Vec<i32> = (1..6).map(|i| -8 - 8 * i).collect();
    srcs.extend((0..8).map(|i| -56 - 8 * i));
    srcs.extend([16, 24]);
    for (k, &s) in srcs.iter().enumerate() {
        a.i(Insn::StoreW64 { m: Mem { p: Slot(-8), k: 8 * k as i32 }, s: Slot(s) });
    }
    a.i(Insn::AddW64 { d: Slot(-128), a: Slot(16), b: Slot(24) });
    a.ret(Slot(-128), 8);
    let spill = w.add_function(func(a.done(), 128, 16, 8));

    // triple(x) = [x, x + 1, x + 2], through the sret pointer.
    let mut a = Asm::new();
    a.sret(Slot(-48));
    a.i(Insn::MovW64 { d: Slot(-32), s: Slot(16) });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(16), imm: 1 });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(16), imm: 2 });
    a.ret(Slot(-32), 24);
    let triple = w.add_function(func(a.done(), 48, 8, 24));

    // nest(n, m) = n * m by two nested counting loops (two loop heads), the inner calling
    // `tick` every iteration. n@16, m@24, i@-8, j@-16, acc@-24.
    let mut a = Asm::new();
    a.i(Insn::ImmW64 { d: Slot(-24), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(-8), imm: 0 });
    let outer = a.i(Insn::BrLtUW64 { a: Slot(-8), b: Slot(16), neg: F, t: Target(0) });
    a.i(Insn::ImmW64 { d: Slot(-16), imm: 0 });
    let inner = a.i(Insn::BrLtUW64 { a: Slot(-16), b: Slot(24), neg: F, t: Target(0) });
    a.i(Insn::CallSym { d: Slot(0), sym: s_tick, k: 0, a: List::from_words(&[]) });
    a.i(Insn::AddImmW64 { d: Slot(-24), a: Slot(-24), imm: 1 });
    a.i(Insn::AddImmW64 { d: Slot(-16), a: Slot(-16), imm: 1 });
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", inner);
    let after = a.i(Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 });
    a.patch(inner, "t", after);
    let back = a.i(Insn::Jmp { t: Target(0) });
    a.patch(back, "t", outer);
    let done = a.ret(Slot(-24), 8);
    a.patch(outer, "t", done);
    let nest = w.add_function(func(a.done(), 32, 16, 8));

    let img = build(w, &[("tick", tick as *const () as usize)]);

    type Spill = extern "C" fn(*mut u64, u64, u64, u64, u64, u64, f64, f64, f64, f64, f64, f64, f64, f64, u64, u64) -> u64;
    let f: Spill = unsafe { std::mem::transmute(img.code(spill)) };
    for start in [0, -5, -JIT_ENTRY_THRESHOLD] {
        img.set_counters(spill, start, -JIT_THRESHOLD);
        let mut out = [0u64; 15];
        let xs: Vec<f64> = (0..8).map(|i| i as f64 + 0.5).collect();
        let r = f(out.as_mut_ptr(), 1, 2, 3, 4, 5, xs[0], xs[1], xs[2], xs[3], xs[4], xs[5], xs[6], xs[7], 1 << 40, 7);
        assert_eq!(r, (1 << 40) + 7);
        let mut want: Vec<u64> = (1..6).collect();
        want.extend(xs.iter().map(|x| x.to_bits()));
        want.extend([1 << 40, 7]);
        assert_eq!(out[..], want[..], "counter {start}");
        // Tripped iff the call counter stopped being negative.
        let tripped = start + 1 >= 0;
        assert_eq!(img.counters(spill), (if tripped { -JIT_BIAS } else { start + 1 }, -JIT_THRESHOLD));
    }

    img.set_counters(triple, 0, 0);
    assert_eq!(ok::<_, [u64; 3]>(img.id(triple), (5u64,)), [5, 6, 7]);
    assert_eq!(img.counters(triple), (-JIT_BIAS, 0));

    // At the entry, then (`tick`) at every inner and outer loop head.
    TICK.store(img.record(nest) as usize, Ordering::Relaxed);
    for start in [0, -2, -JIT_ENTRY_THRESHOLD] {
        img.set_counters(nest, start, -JIT_THRESHOLD);
        assert_eq!(ok::<_, u64>(img.id(nest), (3u64, 4u64)), 12);
        // The last `tick`'s trip was at the inner head; one outer check since.
        assert_eq!(img.counters(nest), (if start + 1 >= 0 { -JIT_BIAS } else { start + 1 }, -JIT_BIAS + 1));
    }
    // Without `tick`: the outer head trips at its first check; three more outer and three
    // inner checks follow.
    img.set_counters(nest, -2, -1);
    assert_eq!(ok::<_, u64>(img.id(nest), (3u64, 0u64)), 0);
    assert_eq!(img.counters(nest), (-1, -JIT_BIAS + 6));
}

/// Panics unwind through frames that tripped, at the entry and at a loop head, and their
/// landing pads run.
#[test]
#[cfg(not(feature = "jit"))]
fn jit_trips_unwind() {
    let mut w = ImageWriter::new(unique_scid());
    let s_boom = w.symbol("boom", 0);
    // ub(x, log) loops i over 0..3 calling boom(x + i); landing pad: log[0] = 42, resume.
    // x@16, log@24, i@-8, t@-16, r@-24, exception@-32, tmp@-40, the argument at -48.
    let mut a = Asm::new();
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
    let img = build(w, &[("boom", boom as *const () as usize)]);

    // A trip at the entry, then at the loop head.
    for start in [(0, -JIT_THRESHOLD), (-2, 0)] {
        let mut log = [0u64; 1];
        img.set_counters(ub, start.0, start.1);
        // boom(5), boom(6), boom(7) panics.
        let e = call::<_, u64>(img.id(ub), (5u64, log.as_mut_ptr() as u64)).unwrap_err();
        assert_eq!((payload(e), log), (Boom(7), [42]));
        let (e, l) = img.counters(ub);
        assert!([e, l].iter().any(|v| (-JIT_BIAS..-JIT_BIAS + 8).contains(v)), "counters {start:?}: {e} {l}");
        img.set_counters(ub, start.0, start.1);
        assert_eq!(ok::<_, u64>(img.id(ub), (1u64, log.as_mut_ptr() as u64)), 3);
    }
}
