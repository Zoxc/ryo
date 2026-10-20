//! Hand-assembled bytecode through `vm::enter` and portals: data movement, addresses,
//! enums, control flow, calls, multi-image calls, site caches, re-entrancy, unwinding,
//! registration, and the fatal paths (in child processes).

#![feature(unboxed_closures)]

mod common;
use common::*;

use std::panic::{catch_unwind, resume_unwind};
use std::sync::OnceLock;

use ryo_rt::island::{call_ptr1, call_ptr2};
use ryo_rt::portal::portal;
use ryo_rt::vm::lookup_addr;

fn cp1() -> usize {
    island(call_ptr1::<u64, u64>)
}
fn cp2() -> usize {
    island(call_ptr2::<u64, u64, u64>)
}

#[test]
fn data_movement() {
    let mut w = ImageWriter::new(unique_scid());
    // mov.wN: x@16 → 48, 64, 80, 96, 112.
    let mut a = Asm::new();
    a.i(Insn::Zero { d: Slot(48), len: 80 });
    a.i(Insn::MovW8 { d: Slot(48), s: Slot(16) });
    a.i(Insn::MovW16 { d: Slot(64), s: Slot(16) });
    a.i(Insn::MovW32 { d: Slot(80), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(96), s: Slot(16) });
    a.i(Insn::MovW128 { d: Slot(112), s: Slot(16) });
    a.i(Insn::Ret { s: Slot(48), len: 80 });
    let f_mov = w.add_function(func(a.done(), 128, 0, 16, 80));

    // copy, imm.w128, const, fill, zero.
    let k16 = w.add_const(&0x0f0e0d0c0b0a09080706050403020100u128.to_le_bytes(), 16, &[]);
    let k4 = w.add_const(&0xa1b2c3d4u32.to_le_bytes(), 4, &[]);
    let mut a = Asm::new();
    a.i(Insn::Zero { d: Slot(48), len: 64 });
    a.i(Insn::Copy { d: Slot(48), s: Slot(16), len: 7 });
    a.i(Insn::ImmW128 { d: Slot(64), imm: 0x1122_3344_5566_7788_99aa_bbcc_ddee_ff00 });
    a.i(Insn::Const { d: Slot(80), k: k16, len: 16 });
    a.i(Insn::Fill { d: Slot(96), k: k4, elem_size: 4, count: 3 });
    a.i(Insn::ImmW64 { d: Slot(32), imm: u64::MAX });
    a.i(Insn::Zero { d: Slot(33), len: 2 });
    a.i(Insn::MovW64 { d: Slot(104), s: Slot(32) });
    a.i(Insn::Ret { s: Slot(48), len: 64 });
    let f_misc = w.add_function(func(a.done(), 112, 0, 16, 64));

    // Memory: p@16 points at a 64-byte buffer holding 0..64.
    let mut a = Asm::new();
    a.i(Insn::Zero { d: Slot(32), len: 96 });
    a.i(Insn::LoadW32 { d: Slot(32), m: Mem { p: Slot(16), k: 4 } });
    a.i(Insn::LoadW64Z { d: Slot(40), m: Deref(Slot(16)) });
    a.i(Insn::LoadW8 { d: Slot(120), m: Mem { p: Slot(16), k: 63 } });
    a.i(Insn::StoreW16 { m: Mem { p: Slot(16), k: 10 }, s: Slot(32) });
    a.i(Insn::StoreW8Z { m: Deref(Slot(16)), s: Slot(32) });
    a.i(Insn::LoadCopy { d: Slot(48), m: Mem { p: Slot(16), k: 16 }, len: 8 });
    a.i(Insn::StoreCopy { m: Mem { p: Slot(16), k: 32 }, s: Slot(48), len: 8 });
    a.i(Insn::LoadCopyZ { d: Slot(56), m: Deref(Slot(16)), len: 2 });
    a.i(Insn::PtrAdd { d: Slot(64), p: Slot(16), imm: 48 });
    a.i(Insn::ImmW64 { d: Slot(72), imm: 4 });
    a.i(Insn::Memcpy { dp: Slot(64), sp: Slot(16), n: Slot(72) });
    a.i(Insn::PtrAdd { d: Slot(80), p: Slot(16), imm: 56 });
    a.i(Insn::ImmW8 { d: Slot(88), imm: 0xee });
    a.i(Insn::Memset { dp: Slot(80), b: Slot(88), n: Slot(72) });
    a.i(Insn::PtrAdd { d: Slot(96), p: Slot(16), imm: 41 });
    a.i(Insn::PtrAdd { d: Slot(104), p: Slot(16), imm: 40 });
    a.i(Insn::Memmove { dp: Slot(96), sp: Slot(104), n: Slot(72) });
    a.i(Insn::PtrIndex { d: Slot(112), p: Slot(16), i: Slot(72), stride: 3 });
    a.i(Insn::StoreCopyZ { m: Deref(Slot(112)), s: Slot(88), len: 1 });
    a.i(Insn::Ret { s: Slot(32), len: 96 });
    let f_mem = w.add_function(func(a.done(), 128, 0, 8, 96));
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
    let data = w.add_data(&[0xab; 16], 8, &[], &[AllocFixup { offset: 8, sym: s_imp, addend: 4 }]);
    let mut a = Asm::new();
    a.i(Insn::AddrSym { d: Slot(16), sym: s_static });
    a.i(Insn::AddrSymInd { d: Slot(24), sym: s_imp });
    a.i(Insn::AddrK { d: Slot(32), k });
    a.i(Insn::AddrData { d: Slot(40), off: data });
    a.i(Insn::Addr { d: Slot(48), s: Slot(56) });
    a.i(Insn::ImmW64 { d: Slot(56), imm: 0x99 });
    a.i(Insn::LoadW64Z { d: Slot(64), m: Deref(Slot(48)) });
    a.i(Insn::Ret { s: Slot(16), len: 56 });
    let f = w.add_function(func(a.done(), 80, 0, 0, 56));
    let img = build(w, &[("static", addr(&raw const STATIC_VAL)), ("imp", addr(&raw const IMP_STATIC))]);

    let r: [usize; 7] = ok(img.id(f), ());
    assert_eq!(r[0], addr(&raw const STATIC_VAL));
    assert_eq!(r[1], addr(&raw const STATIC_VAL), "addr.sym.ind loads through the slot");
    assert_eq!(unsafe { *(r[2] as *const u64) }, 0x5555_6666_7777_8888);
    let d = r[3] as *const u8;
    assert_eq!(unsafe { *d }, 0xab);
    // The PE fixup was applied at registration: *imp_slot + 4.
    assert_eq!(unsafe { *(d.add(8) as *const usize) }, addr(&raw const STATIC_VAL) + 4);
    assert_eq!(r[6], 0x99);
}

#[test]
fn enums_niche() {
    // Variants 3..=5 are niche-encoded starting at `ns`; variant 1 is untagged.
    let mut w = ImageWriter::new(unique_scid());
    let mut fns = vec![];
    for (dop, sop, n) in [
        (Opcode::DiscrNicheW8, Opcode::SetDiscrNicheW8, 8u32),
        (Opcode::DiscrNicheW16, Opcode::SetDiscrNicheW16, 16),
        (Opcode::DiscrNicheW32, Opcode::SetDiscrNicheW32, 32),
        (Opcode::DiscrNicheW64, Opcode::SetDiscrNicheW64, 64),
        (Opcode::DiscrNicheW128, Opcode::SetDiscrNicheW128, 128),
    ] {
        let mask = if n == 128 { u128::MAX } else { (1u128 << n) - 1 };
        let ns = mask - 1; // wraps: niches are mask-1, mask, 0
        // discr: tag@16 → u32 variant@48. set_discr takes the variant as an immediate, so
        // there is one function per variant (the untagged one and each niche variant).
        let mut a = Asm::new();
        a.i(Insn::Zero { d: Slot(48), len: 16 });
        a.raw(dop, &[48, 16, ns, 3, 5, 1]);
        a.i(Insn::Ret { s: Slot(48), len: 4 });
        let fd = w.add_function(func(a.done(), 64, 0, 16, 4));
        let mut fs = vec![];
        for v in [1u128, 3, 4, 5] {
            let mut a = Asm::new();
            a.i(Insn::MovW128 { d: Slot(48), s: Slot(16) });
            a.raw(sop, &[48, v, ns, 3, 1]);
            a.i(Insn::Ret { s: Slot(48), len: 16 });
            fs.push(w.add_function(func(a.done(), 64, 0, 16, 16)));
        }
        fns.push((n, mask, ns, fd, fs));
    }
    let img = build(w, &[]);
    for (n, mask, ns, fd, fs) in fns {
        for tag in [ns.wrapping_sub(1) & mask, ns, ns.wrapping_add(1) & mask, ns.wrapping_add(2) & mask, 3, 1, mask >> 1]
        {
            let rel = tag.wrapping_sub(ns) & mask;
            let want = if rel <= 2 { 3 + rel as u32 } else { 1 };
            assert_eq!(ok::<_, u32>(img.id(fd), (tag,)), want, "w{n} tag {tag:#x}");
        }
        for (&v, f) in [1usize, 3, 4, 5].iter().zip(&fs) {
            let init = 0x4242u128 & mask;
            let got: u128 = ok(img.id(*f), (init,));
            let want = if v == 1 { init } else { ((v as u128).wrapping_sub(3).wrapping_add(ns)) & mask };
            assert_eq!(got, want, "w{n} set variant {v}");
        }
    }
}

#[test]
fn control_flow() {
    let mut w = ImageWriter::new(unique_scid());
    // sum(n) = 1 + … + n: n@16, s@24, i@32.
    let mut a = Asm::new();
    a.i(Insn::ImmW64 { d: Slot(24), imm: 0 });
    a.i(Insn::ImmW64 { d: Slot(32), imm: 1 });
    let top = a.i(Insn::BrCmpLtUW64 { a: Slot(16), b: Slot(32), t: Target(0) });
    a.i(Insn::AddW64 { d: Slot(24), a: Slot(24), b: Slot(32) });
    a.i(Insn::AddImmW64 { d: Slot(32), a: Slot(32), imm: 1 });
    let j = a.i(Insn::Jmp { t: Target(0) });
    a.patch(j, "t", top);
    let exit = a.i(Insn::Ret { s: Slot(24), len: 8 });
    a.patch(top, "t", exit);
    let f_sum = w.add_function(func(a.done(), 48, 0, 8, 8));

    // br.if / br.unless: b@16 → 10 + 2*b via both branches.
    let mut a = Asm::new();
    a.i(Insn::ImmW32 { d: Slot(24), imm: 10 });
    let b1 = a.i(Insn::BrUnless { s: Slot(16), t: Target(0) });
    a.i(Insn::AddImmW32 { d: Slot(24), a: Slot(24), imm: 1 });
    let l1 = a.i(Insn::BrIf { s: Slot(16), t: Target(0) });
    a.patch(b1, "t", l1);
    a.i(Insn::Ret { s: Slot(24), len: 4 });
    let l2 = a.i(Insn::AddImmW32 { d: Slot(24), a: Slot(24), imm: 1 });
    a.patch(l1, "t", l2);
    a.i(Insn::Ret { s: Slot(24), len: 4 });
    let f_br = w.add_function(func(a.done(), 32, 0, 1, 4));

    // Fused compares with immediates at 128 bits.
    let mut a = Asm::new();
    a.i(Insn::ImmW32 { d: Slot(48), imm: 0 });
    let b = a.i(Insn::BrCmpGtSImmW128 { a: Slot(16), imm: (-5i128) as u128, t: Target(0) });
    a.i(Insn::Ret { s: Slot(48), len: 4 });
    let t = a.i(Insn::ImmW32 { d: Slot(48), imm: 1 });
    a.patch(b, "t", t);
    a.i(Insn::Ret { s: Slot(48), len: 4 });
    let f_gt = w.add_function(func(a.done(), 64, 0, 16, 4));

    // switch.dense at every width: x@16 (u128); cases base..base+3 return 100+i, else 99.
    macro_rules! dense {
        ($v:ident, $base:expr) => {{
            let mut a = Asm::new();
            let tw = [0u32; 3];
            let sw = a.i(Insn::$v { s: Slot(16), base: $base, default: Target(0), table: List::from_words(&tw) });
            for i in 0..3 {
                let at = a.i(Insn::ImmW32 { d: Slot(48), imm: 100 + i as u32 });
                a.patch_list(sw, "table", i, at);
                a.i(Insn::Ret { s: Slot(48), len: 4 });
            }
            let d = a.i(Insn::ImmW32 { d: Slot(48), imm: 99 });
            a.patch(sw, "default", d);
            a.i(Insn::Ret { s: Slot(48), len: 4 });
            w.add_function(func(a.done(), 64, 0, 16, 4))
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
                targets.push(a.i(Insn::ImmW32 { d: Slot(48), imm: 100 + i as u32 }));
                a.i(Insn::Ret { s: Slot(48), len: 4 });
            }
            let d = a.i(Insn::ImmW32 { d: Slot(48), imm: 99 });
            a.patch(sw, "default", d);
            a.i(Insn::Ret { s: Slot(48), len: 4 });
            let mut code = a.done();
            // Patch case targets: each case's last word, after the count word.
            let ew = cw.len() / vals.len();
            let base = sw as usize + ryo_bytecode::insn::off::$v::cases + 1;
            for (i, t) in targets.iter().enumerate() {
                code[base + i * ew + ew - 1] = t.wrapping_sub(sw);
            }
            (vals.iter().map(|&v| v as u128).collect::<Vec<_>>(), w.add_function(func(code, 64, 0, 16, 4)))
        }};
    }
    let sparse_fns = [
        (8u32, sparse!(SwitchSparseW8, Case32, [1u32, 5, 200])),
        (32, sparse!(SwitchSparseW32, Case32, [0u32, 3, 9, 10, 11, 1000, 0xffff_fff0])),
        (64, sparse!(SwitchSparseW64, Case64, [2u64, 1 << 33, u64::MAX])),
        (128, sparse!(SwitchSparseW128, Case128, [0u128, 1, 7, 1 << 64, 1 << 100, 1 << 127, u128::MAX])),
    ];
    let img = build(w, &[]);

    assert_eq!(ok::<_, u64>(img.id(f_sum), (100u64,)), 5050);
    assert_eq!(ok::<_, u64>(img.id(f_sum), (0u64,)), 0);
    assert_eq!(ok::<_, u32>(img.id(f_br), (true,)), 12);
    assert_eq!(ok::<_, u32>(img.id(f_br), (false,)), 10);
    assert_eq!(ok::<_, u32>(img.id(f_gt), (-4i128,)), 1);
    assert_eq!(ok::<_, u32>(img.id(f_gt), (-5i128,)), 0);
    assert_eq!(ok::<_, u32>(img.id(f_gt), (i128::MIN,)), 0);
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
    // fib(n): n@16, t1@24, t2@32, frame 48; outgoing arg at 64.
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
    let fib = w.add_function(func(a.done(), 48, 24, 8, 8));
    assert_eq!(fib, Func(0));

    // countdown(n, acc) = countdown(n - 1, acc + n) by tail call: 10^6 deep, far beyond what
    // the stack would hold without frame reuse. n@16, acc@24, frame 32, outgoing at 48.
    let mut a = Asm::new();
    let b = a.i(Insn::BrCmpEqImmW64 { a: Slot(16), imm: 0, t: Target(0) });
    a.i(Insn::SubImmW64 { d: Slot(48), a: Slot(16), imm: 1 });
    a.i(Insn::AddW64 { d: Slot(56), a: Slot(24), b: Slot(16) });
    a.i(Insn::TailCall { f: Func(1), frame_size: 32 });
    let done = a.i(Insn::Ret { s: Slot(24), len: 8 });
    a.patch(b, "t", done);
    let countdown = w.add_function(func(a.done(), 32, 32, 16, 8));

    // Calls countdown(n, 0) + 1 through `call`, so the tail-called frames return into a VM
    // caller.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(48), s: Slot(16) });
    a.i(Insn::ImmW64 { d: Slot(56), imm: 0 });
    a.i(Insn::Call { d: Slot(24), f: countdown, frame_size: 32 });
    a.i(Insn::AddImmW64 { d: Slot(24), a: Slot(24), imm: 1 });
    a.i(Insn::Ret { s: Slot(24), len: 8 });
    let wrap = w.add_function(func(a.done(), 32, 32, 8, 8));
    let img = build(w, &[]);

    assert_eq!(ok::<_, u64>(img.id(fib), (20u64,)), 6765);
    let n = 1_000_000u64;
    assert_eq!(ok::<_, u64>(img.id(countdown), (n, 0u64)), n * (n + 1) / 2);
    assert_eq!(ok::<_, u64>(img.id(wrap), (n,)), n * (n + 1) / 2 + 1);
}

// ---- multi-image calls and site caches ----

const SCID_B: u64 = 0xb0b0_0000_0000_0001;
const ID_G: u64 = portal_id(crate_hash(SCID_B), 0);
const K_B: u64 = 1000;

/// Image B: g(x) = 3x + K_B (K_B from B's constant pool), with a portal.
fn image_b() -> &'static Linked {
    static B: OnceLock<Linked> = OnceLock::new();
    B.get_or_init(|| {
        let mut w = ImageWriter::new(SCID_B);
        let p = w.symbol("portal_g", 0);
        let k = w.add_const(&K_B.to_le_bytes(), 8, &[]);
        let mut a = Asm::new();
        a.i(Insn::Const { d: Slot(24), k, len: 8 });
        a.i(Insn::MulImmW64 { d: Slot(16), a: Slot(16), imm: 3 });
        a.i(Insn::AddW64 { d: Slot(16), a: Slot(16), b: Slot(24) });
        a.i(Insn::Ret { s: Slot(16), len: 8 });
        let mut f = func(a.done(), 32, 0, 8, 8);
        f.portal = Some(p);
        w.add_function(f);
        build(w, &[("portal_g", portal::<(u64,), u64, ID_G> as *const () as usize)])
    })
}

fn portal_g(x: u64) -> u64 {
    let p: extern "rust-call" fn((u64,)) -> u64 = portal::<(u64,), u64, ID_G>;
    p((x,))
}

fn native_add(a: u64, b: u64) -> u64 {
    a + b
}
fn native_double(x: u64) -> u64 {
    2 * x
}

/// Plays an `__imp_` slot holding g's portal address.
static IMP_G: SyncPtr = SyncPtr(portal::<(u64,), u64, ID_G> as *const ());

#[test]
fn multi_image_calls_and_site_caches() {
    let b = image_b();
    let pg = portal::<(u64,), u64, ID_G> as *const () as usize;
    let mut w = ImageWriter::new(unique_scid());
    let s_g = w.symbol("portal_g", 0);
    let s_add = w.symbol("native_add", 0);
    let s_imp = w.symbol("imp_g", SYM_INDIRECT);
    let i1 = w.symbol("cp1", 0);
    let i2 = w.symbol("cp2", 0);
    let k_a = w.add_const(&7u64.to_le_bytes(), 8, &[]);
    let sites: Vec<Site> = (0..5).map(|_| w.site()).collect();

    // f0(x) = g(x) + 7 via call.ext; the + 7 reads A's pool after returning from B.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(64), s: Slot(16) });
    a.i(Insn::CallExt { d: Slot(24), sym: s_g, site: sites[0], island: i1 });
    a.i(Insn::Const { d: Slot(32), k: k_a, len: 8 });
    a.i(Insn::AddW64 { d: Slot(24), a: Slot(24), b: Slot(32) });
    a.i(Insn::Ret { s: Slot(24), len: 8 });
    let f0 = w.add_function(func(a.done(), 48, 24, 8, 8));

    // f1(a, b) = native_add(a, b) via call.ext's native path.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(64), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(72), s: Slot(24) });
    a.i(Insn::CallExt { d: Slot(32), sym: s_add, site: sites[1], island: i2 });
    a.i(Insn::Ret { s: Slot(32), len: 8 });
    let f1 = w.add_function(func(a.done(), 48, 32, 16, 8));

    // f2(x) = g(x) via call.ext.ind through an import slot.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(64), s: Slot(16) });
    a.i(Insn::CallExtInd { d: Slot(24), sym: s_imp, site: sites[2], island: i1 });
    a.i(Insn::Ret { s: Slot(24), len: 8 });
    let f2 = w.add_function(func(a.done(), 48, 24, 8, 8));

    // f3(p, x) = p(x) via call.ind.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(64), s: Slot(24) });
    a.i(Insn::CallInd { d: Slot(32), p: Slot(16), site: sites[3], island: i1 });
    a.i(Insn::Ret { s: Slot(32), len: 8 });
    let f3 = w.add_function(func(a.done(), 48, 24, 16, 8));

    // f4(p, x) = become p(x).
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(48), s: Slot(24) });
    a.i(Insn::TailCallInd { p: Slot(16), site: sites[4], island: i1 });
    let f4 = w.add_function(func(a.done(), 32, 24, 16, 8));

    // f5(p, x) = f4(p, x) + 1, so f4's tail call happens in a non-entry frame.
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(64), s: Slot(16) });
    a.i(Insn::MovW64 { d: Slot(72), s: Slot(24) });
    a.i(Insn::Call { d: Slot(32), f: f4, frame_size: 32 });
    a.i(Insn::AddImmW64 { d: Slot(32), a: Slot(32), imm: 1 });
    a.i(Insn::Ret { s: Slot(32), len: 8 });
    let f5 = w.add_function(func(a.done(), 48, 32, 16, 8));

    let img = build(w, &[
        ("portal_g", pg),
        ("native_add", native_add as *const () as usize),
        ("imp_g", addr(&raw const IMP_G)),
        ("cp1", cp1()),
        ("cp2", cp2()),
    ]);

    let g = lookup_addr(pg as *const ()).expect("g's portal is registered");
    assert_eq!(g.portal as usize, pg);
    assert_eq!(unsafe { (*g.img).view.header() as *const Header as usize }, b.header as usize);
    assert!(lookup_addr(native_add as *const ()).is_none());
    assert!(lookup_addr(std::ptr::null()).is_none());
    let gp = g as *const _ as usize;

    for x in [0u64, 5, 1 << 40] {
        assert_eq!(ok::<_, u64>(img.id(f0), (x,)), 3 * x + K_B + 7);
    }
    assert_eq!(img.site(sites[0]), gp, "call.ext cached g's record");

    assert_eq!(ok::<_, u64>(img.id(f1), (40u64, 2u64)), 42);
    assert_eq!(img.site(sites[1]), 1, "call.ext cached NATIVE");
    assert_eq!(ok::<_, u64>(img.id(f1), (1u64, 2u64)), 3);

    assert_eq!(ok::<_, u64>(img.id(f2), (2u64,)), 6 + K_B);
    assert_eq!(img.site(sites[2]), gp);

    assert_eq!(img.site(sites[3]), 0);
    assert_eq!(ok::<_, u64>(img.id(f3), (pg, 4u64)), 12 + K_B, "miss → VM");
    assert_eq!(img.site(sites[3]), gp);
    assert_eq!(ok::<_, u64>(img.id(f3), (pg, 5u64)), 15 + K_B, "hit");
    assert_eq!(ok::<_, u64>(img.id(f3), (native_double as *const () as usize, 5u64)), 10, "native target");
    let nd = native_double as *const () as usize;
    assert_eq!(img.site(sites[3]), nd << 1 | 1, "native target cached, tagged");
    assert_eq!(ok::<_, u64>(img.id(f3), (nd, 6u64)), 12, "native hit");
    assert_eq!(ok::<_, u64>(img.id(f3), (pg, 1u64)), 3 + K_B, "back to VM");
    assert_eq!(img.site(sites[3]), gp);

    // tail_call.ind: VM target in the entry frame and in a called frame; native target in
    // both (the native one returns through `ret`'s logic with the function's ret_size).
    assert_eq!(ok::<_, u64>(img.id(f4), (pg, 1u64)), 3 + K_B);
    assert_eq!(ok::<_, u64>(img.id(f5), (pg, 1u64)), 4 + K_B);
    assert_eq!(ok::<_, u64>(img.id(f4), (native_double as *const () as usize, 21u64)), 42);
    assert_eq!(ok::<_, u64>(img.id(f5), (native_double as *const () as usize, 21u64)), 43);

    // The portal itself, called natively.
    assert_eq!(portal_g(10), 30 + K_B);
}

#[test]
fn registration() {
    let mk = |v: u32| {
        let mut w = ImageWriter::new(unique_scid());
        let mut a = Asm::new();
        a.i(Insn::ImmW32 { d: Slot(16), imm: v });
        a.i(Insn::Ret { s: Slot(16), len: 4 });
        w.add_function(func(a.done(), 32, 0, 0, 4));
        link(w.finish().unwrap(), &[])
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

const SCID_R: u64 = 0xeeee_0000_0000_0003;
const ID_R0: u64 = portal_id(crate_hash(SCID_R), 0);

/// Native: r0(n - 1) + n, through r0's portal (VM → island → native → portal → VM).
fn reenter(n: u64) -> u64 {
    let p: extern "rust-call" fn((u64,)) -> u64 = portal::<(u64,), u64, ID_R0>;
    p((n - 1,)) + n
}

#[test]
fn reentrancy() {
    let mut w = ImageWriter::new(SCID_R);
    let s = w.symbol("reenter", 0);
    let i1 = w.symbol("cp1", 0);
    // r0(n) = n == 0 ? 0 : reenter(n). n@16, r@24, fn pointer@32.
    let mut a = Asm::new();
    let b = a.i(Insn::BrCmpNeImmW64 { a: Slot(16), imm: 0, t: Target(0) });
    a.i(Insn::Ret { s: Slot(16), len: 8 });
    let l = a.i(Insn::AddrSym { d: Slot(32), sym: s });
    a.patch(b, "t", l);
    let ops = [16, 24, 32];
    a.i(Insn::IslandCatch { sym: i1, ops: List::from_words(&ops), targets: List::from_words(&[]) });
    a.i(Insn::Ret { s: Slot(24), len: 8 });
    w.add_function(func(a.done(), 48, 0, 8, 8));
    let img = build(w, &[("reenter", reenter as *const () as usize), ("cp1", cp1())]);
    assert_eq!(img.id(Func(0)), ID_R0);
    for n in [0u64, 1, 2, 50] {
        assert_eq!(ok::<_, u64>(ID_R0, (n,)), n * (n + 1) / 2);
    }
    // 1000 nested `enter`s: needs more native stack than a test thread has in debug builds.
    let deep = std::thread::Builder::new().stack_size(256 << 20).spawn(|| ok::<_, u64>(ID_R0, (1000u64,)));
    assert_eq!(deep.unwrap().join().unwrap(), 500500);
    // Threads have independent VM state.
    let hs: Vec<_> = (0..4u64).map(|t| std::thread::spawn(move || ok::<_, u64>(ID_R0, (100 + t,)))).collect();
    for (t, h) in hs.into_iter().enumerate() {
        let n = 100 + t as u64;
        assert_eq!(h.join().unwrap(), n * (n + 1) / 2);
    }
}

// ---- unwinding ----

const SCID_U: u64 = 0x0dd0_0000_0000_0004;
const ID_U2: u64 = portal_id(crate_hash(SCID_U), 2);
const ID_O: u64 = portal_id(crate_hash(SCID_U), 3);

#[derive(Debug, PartialEq)]
struct Boom(u64);

fn boom(x: u64) -> u64 {
    if x == 7 {
        resume_unwind(Box::new(Boom(x)))
    }
    x
}

/// Native: u2's portal + 100 (nested `enter` that may unwind).
fn via_portal(x: u64, log: u64) -> u64 {
    let p: extern "rust-call" fn((u64, u64)) -> u64 = portal::<(u64, u64), u64, ID_U2>;
    p((x, log)) + 100
}

fn image_u() -> &'static Linked {
    static U: OnceLock<Linked> = OnceLock::new();
    U.get_or_init(|| {
        let mut w = ImageWriter::new(SCID_U);
        let s_boom = w.symbol("boom", 0);
        let s_via = w.symbol("via_portal", 0);
        let i1 = w.symbol("cp1", 0);
        let i2 = w.symbol("cp2", 0);
        let none: [u32; 0] = [];
        // u1(x, log) = boom(x); cleanup: log[0] = 999. x@16, log@24, r@32, fn@40.
        let mut a = Asm::new();
        a.i(Insn::AddrSym { d: Slot(40), sym: s_boom });
        let call = a.i(Insn::IslandCatch { sym: i1, ops: List::from_words(&[16, 32, 40]), targets: List::from_words(&none) });
        a.i(Insn::Ret { s: Slot(32), len: 8 });
        let c = a.i(Insn::ImmW64 { d: Slot(32), imm: 999 });
        a.i(Insn::StoreW64Z { m: Deref(Slot(24)), s: Slot(32) });
        a.i(Insn::Resume {});
        let mut f = func(a.done(), 48, 0, 16, 8);
        f.cleanup = vec![CleanupEntry { offset: call, target: c }];
        assert_eq!(w.add_function(f), Func(0));

        // u0(x, log) = u1(x, log), then log[1] = 1. No cleanup entry: the frame is popped.
        let mut a = Asm::new();
        a.i(Insn::MovW64 { d: Slot(64), s: Slot(16) });
        a.i(Insn::MovW64 { d: Slot(72), s: Slot(24) });
        a.i(Insn::Call { d: Slot(32), f: Func(0), frame_size: 48 });
        a.i(Insn::ImmW64 { d: Slot(40), imm: 1 });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 8 }, s: Slot(40) });
        a.i(Insn::Ret { s: Slot(32), len: 8 });
        assert_eq!(w.add_function(func(a.done(), 48, 32, 16, 8)), Func(1));

        // u2(x, log) = u0(x, log); cleanup: log[2] = 555.
        let mut a = Asm::new();
        a.i(Insn::MovW64 { d: Slot(64), s: Slot(16) });
        a.i(Insn::MovW64 { d: Slot(72), s: Slot(24) });
        let call = a.i(Insn::Call { d: Slot(32), f: Func(1), frame_size: 48 });
        a.i(Insn::Ret { s: Slot(32), len: 8 });
        let c = a.i(Insn::ImmW64 { d: Slot(40), imm: 555 });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 16 }, s: Slot(40) });
        a.i(Insn::Resume {});
        let mut f = func(a.done(), 48, 32, 16, 8);
        f.cleanup = vec![CleanupEntry { offset: call, target: c }];
        assert_eq!(w.add_function(f), Func(2));

        // o(x, log) = via_portal(x, log); cleanup: log[3] = 777.
        let mut a = Asm::new();
        a.i(Insn::AddrSym { d: Slot(40), sym: s_via });
        let call = a.i(Insn::IslandCatch { sym: i2, ops: List::from_words(&[16, 32, 40]), targets: List::from_words(&none) });
        a.i(Insn::Ret { s: Slot(32), len: 8 });
        let c = a.i(Insn::ImmW64 { d: Slot(40), imm: 777 });
        a.i(Insn::StoreW64 { m: Mem { p: Slot(24), k: 24 }, s: Slot(40) });
        a.i(Insn::Resume {});
        let mut f = func(a.done(), 48, 0, 16, 8);
        f.cleanup = vec![CleanupEntry { offset: call, target: c }];
        assert_eq!(w.add_function(f), Func(3));

        // u4(x) = boom(x) through call.ext's native path, no cleanup.
        let site = w.site();
        let mut a = Asm::new();
        a.i(Insn::MovW64 { d: Slot(48), s: Slot(16) });
        a.i(Insn::CallExt { d: Slot(24), sym: s_boom, site, island: i1 });
        a.i(Insn::Ret { s: Slot(24), len: 8 });
        assert_eq!(w.add_function(func(a.done(), 32, 24, 8, 8)), Func(4));

        build(w, &[("boom", boom as *const () as usize), ("via_portal", via_portal as *const () as usize), ("cp1", cp1()), ("cp2", cp2())])
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

    // Cleanup in u1, pop u0 (no entry), cleanup in u2, then out of `enter` with the payload.
    log = [0; 4];
    let e = call::<_, u64>(u.id(Func(2)), (7u64, lp)).unwrap_err();
    assert_eq!(payload(e), Boom(7));
    assert_eq!(log, [999, 0, 555, 0]);

    // Through a nested `enter`: o → island → via_portal → portal(u2) → VM panics → the inner
    // portal re-raises → o's island.catch → o's cleanup → o's portal re-raises to us.
    log = [0; 4];
    let o: extern "rust-call" fn((u64, u64)) -> u64 = portal::<(u64, u64), u64, ID_O>;
    let e = catch_unwind(|| o((7, lp))).unwrap_err();
    assert_eq!(payload(e), Boom(7));
    assert_eq!(log, [999, 0, 555, 777]);
    assert_eq!(o((3, lp)), 103);

    // call.ext native path.
    assert_eq!(ok::<_, u64>(u.id(Func(4)), (5u64,)), 5);
    assert_eq!(payload(call::<_, u64>(u.id(Func(4)), (7u64,)).unwrap_err()), Boom(7));

    // The VM still works on this thread after all that.
    assert_eq!(ok::<_, u64>(u.id(Func(2)), (4u64, lp)), 4);
}

// ---- fatal paths, each in a child process ----

/// Runs the fatal scenario named by `RYO_FATAL_CASE`; a no-op in normal test runs.
#[test]
fn fatal_child() {
    let Ok(case) = std::env::var("RYO_FATAL_CASE") else { return };
    let mut w = ImageWriter::new(unique_scid());
    let mut a = Asm::new();
    let mut cleanup = vec![];
    let s_boom = w.symbol("boom", 0);
    let i1 = w.symbol("cp1", 0);
    match case.as_str() {
        "overflow" => {
            a.i(Insn::Call { d: Slot(16), f: Func(0), frame_size: 64 });
            a.i(Insn::Ret { s: Slot(16), len: 8 });
        }
        "unreachable" => {
            a.i(Insn::Unreachable {});
        }
        "abort" => {
            a.i(Insn::Abort {});
        }
        "terminate" => {
            a.i(Insn::ImmW64 { d: Slot(16), imm: 7 });
            a.i(Insn::AddrSym { d: Slot(32), sym: s_boom });
            let c = a.i(Insn::IslandCatch { sym: i1, ops: List::from_words(&[16, 24, 32]), targets: List::from_words(&[]) });
            cleanup.push(CleanupEntry { offset: c, target: TERMINATE });
            a.i(Insn::Ret { s: Slot(24), len: 8 });
        }
        _ => panic!("unknown case"),
    }
    let mut f = func(a.done(), 64, 24, 0, 8);
    f.cleanup = cleanup;
    w.add_function(f);
    let img = build(w, &[("boom", boom as *const () as usize), ("cp1", cp1())]);
    let _ = call::<_, u64>(img.id(Func(0)), ());
    eprintln!("RETURNED");
}

#[test]
fn fatal_paths() {
    let exe = std::env::current_exe().unwrap();
    for (case, msg) in [
        ("overflow", Some("ryo: stack overflow in VM code")),
        ("unreachable", Some("ryo: entered unreachable code")),
        ("terminate", Some("ryo: panic in a function that cannot unwind")),
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

// ---- concurrency and thread exit ----

const SCID_C: u64 = 0xc0c0_0000_0000_0005;
const ID_C: u64 = portal_id(crate_hash(SCID_C), 0);

#[test]
fn concurrent_registration_and_sites() {
    let pc = portal::<(u64,), u64, ID_C> as *const () as usize;
    // Image C: c(x) = x + 1, with a portal. Never entered before the threads start, so they
    // race on its lazy function table and on the portal map.
    let mut w = ImageWriter::new(SCID_C);
    let p = w.symbol("portal_c", 0);
    let mut a = Asm::new();
    a.i(Insn::AddImmW64 { d: Slot(16), a: Slot(16), imm: 1 });
    a.i(Insn::Ret { s: Slot(16), len: 8 });
    let mut f = func(a.done(), 32, 0, 8, 8);
    f.portal = Some(p);
    w.add_function(f);
    let c = link(w.finish().unwrap(), &[("portal_c", pc)]);

    // Image A: e(x) = c(x) via call.ext; i(p, x) = p(x) via call.ind. Shared sites.
    let mut w = ImageWriter::new(unique_scid());
    let s_c = w.symbol("portal_c", 0);
    let i1 = w.symbol("cp1", 0);
    let (s0, s1) = (w.site(), w.site());
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(64), s: Slot(16) });
    a.i(Insn::CallExt { d: Slot(24), sym: s_c, site: s0, island: i1 });
    a.i(Insn::Ret { s: Slot(24), len: 8 });
    let fe = w.add_function(func(a.done(), 48, 24, 8, 8));
    let mut a = Asm::new();
    a.i(Insn::MovW64 { d: Slot(64), s: Slot(24) });
    a.i(Insn::CallInd { d: Slot(32), p: Slot(16), site: s1, island: i1 });
    a.i(Insn::Ret { s: Slot(32), len: 8 });
    let fi = w.add_function(func(a.done(), 48, 24, 16, 8));
    let img = link(w.finish().unwrap(), &[("portal_c", pc), ("cp1", cp1())]);
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
                        a.i(Insn::ImmW64 { d: Slot(16), imm: k });
                        a.i(Insn::Ret { s: Slot(16), len: 8 });
                        w.add_function(func(a.done(), 32, 0, 0, 8));
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
    assert!(lookup_addr(pc as *const ()).is_some());
}

#[test]
fn thread_exit_unmaps_the_stack() {
    let id = image_b().id(Func(0));
    let freed = ryo_rt::vm::stacks_freed();
    let base = std::thread::spawn(move || {
        assert!(ryo_rt::vm::current_stack_base().is_null());
        assert_eq!(ok::<_, u64>(id, (1u64,)), 3 + K_B);
        ryo_rt::vm::current_stack_base() as usize
    })
    .join()
    .unwrap();
    assert_ne!(base, 0);
    // Other tests' threads may map a new stack at the same address, so count unmaps.
    assert!(ryo_rt::vm::stacks_freed() > freed, "no VM stack was unmapped at thread exit");
}
