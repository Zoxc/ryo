//! The handlers' register entries (design/jit.md, "Register entries") against their frame
//! entries: every opcode with one, on random operand values, gives the same outputs, return
//! value and memory effects through both. Memory operands point into a buffer; handlers that
//! read symbols, sites or constants are left out (their addresses must be valid).

#![cfg(target_arch = "x86_64")]

use ryo_bytecode::asm::layout;
use ryo_bytecode::full::{OperandKind, Shape};
use ryo_bytecode::jit::effects::{Effect, effects, reg_entry};
use ryo_bytecode::{ALL_OPCODES, Opcode};
use ryo_rt::vm::{FP_ARG, MODE, RegRet, handler, reg_handler};

/// Calls `f(a0..a5)` with `rbp = fp`, returning `rax`.
#[unsafe(naked)]
extern "sysv64" fn call_with_fp(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, fp: *mut u8, f: *const ()) -> u64 {
    core::arch::naked_asm!("push rbp", "mov rbp, [rsp + 16]", "call qword ptr [rsp + 24]", "pop rbp", "ret");
}

#[repr(C, align(16))]
struct Buf([u8; 1024]);

struct Rng(u64);

impl Rng {
    fn next(&mut self) -> u64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        self.0
    }
    /// Mostly small or extreme values, sometimes anything.
    fn value(&mut self) -> u64 {
        match self.next() % 4 {
            0 => self.next() % 8,
            1 => (self.next() % 8).wrapping_neg(),
            2 => 1 << (self.next() % 64),
            _ => self.next(),
        }
    }
}

/// Slot `i`'s offset in the frame.
fn off(i: usize) -> i32 {
    -480 + 48 * i as i32
}

#[test]
fn register_entries_match_frame_entries() {
    let mut rng = Rng(0x9e37_79b9_7f4a_7c15);
    let mut checked = 0;
    for &op in ALL_OPCODES {
        let Some(e) = reg_entry(op, MODE) else {
            assert!(reg_handler(op).is_none(), "{}: a register entry without a description", op.mnemonic());
            continue;
        };
        let rf = reg_handler(op).unwrap_or_else(|| panic!("{}: no register entry", op.mnemonic()));
        let info = op.info();
        let mn = op.mnemonic();
        if info.operands.iter().any(|o| matches!(o.kind, OperandKind::Sym | OperandKind::Site | OperandKind::Const | OperandKind::Abs)) {
            continue;
        }
        let fx = effects(op).unwrap();
        let l = layout(op, MODE);
        let divides = ["div.", "rem."].iter().any(|p| mn.starts_with(p));
        for _ in 0..200 {
            let (mut frame, mut mem) = (Box::new(Buf([0; 1024])), Box::new(Buf([0; 1024])));
            for b in frame.0.iter_mut().chain(mem.0.iter_mut()) {
                *b = rng.next() as u8;
            }
            let mut mem2 = Box::new(Buf(mem.0));
            // The frame operands' values; pointers into `mem` (the same offset in `mem2`).
            let mut vals = [0u64; 8];
            let mut ptr_off = [None; 8];
            for (i, o) in info.operands.iter().enumerate() {
                if !matches!(o.kind, OperandKind::Slot | OperandKind::Mem) {
                    continue;
                }
                vals[i] = rng.value();
                if fx.memory && (o.name == "m" || matches!(o.name, "p" | "dp" | "sp")) {
                    // `memcpy`'s source and destination don't overlap.
                    ptr_off[i] = Some(if o.name == "sp" { 512 } else { 128 } + 16 * (rng.next() % 8) as usize);
                }
                if o.name == "n" && fx.memory {
                    vals[i] = rng.next() % 64;
                }
                if divides && o.name == "b" {
                    vals[i] = (rng.next() % 100) | 1;
                }
            }
            // Data operands: immediates, a `Mem` operand's displacement (small), a sparse
            // switch's cases (none).
            let mut data = [0u128; 8];
            for (i, o) in info.operands.iter().enumerate() {
                data[i] = match o.kind {
                    OperandKind::Slot => 0,
                    OperandKind::Mem => ((rng.next() % 8) * 8) as u128,
                    OperandKind::List(_) => 0,
                    _ => rng.value() as u128 | (rng.value() as u128) << 64,
                };
            }
            let fp = frame.0.as_mut_ptr().wrapping_add(512);
            // The frame entry.
            let mut r = [0u64; 6];
            if FP_ARG {
                r[0] = fp as u64;
            }
            for (i, o) in info.operands.iter().enumerate() {
                let loc = l.locs[i];
                let v: u128 = match o.kind {
                    OperandKind::Slot => off(i) as u32 as u128,
                    OperandKind::Mem => off(i) as u32 as u128 | data[i] << 64,
                    _ => data[i],
                };
                let x = loc.reg as usize;
                match (loc.count, loc.shared) {
                    (0, _) => {}
                    (2, _) => (r[x], r[x + 1]) = (v as u64, (v >> 64) as u64),
                    (_, true) => r[x] |= (v as u32 as u64) << loc.shift,
                    _ => r[x] = v as u64,
                }
            }
            let mut rr = [0u64; 6];
            let mut data_regs = r;
            for (i, o) in info.operands.iter().enumerate() {
                if !matches!(o.kind, OperandKind::Slot | OperandKind::Mem) {
                    continue;
                }
                let v = match ptr_off[i] {
                    Some(p) => (mem.0.as_mut_ptr() as u64 + p as u64, mem2.0.as_mut_ptr() as u64 + p as u64),
                    None => (vals[i], vals[i]),
                };
                unsafe { fp.offset(off(i) as isize).cast::<u64>().write_unaligned(v.0) };
                vals[i] = v.1;
                // The register entry ignores the slot halves: garbage there.
                let loc = l.locs[i];
                let junk = rng.next() as u32 as u64;
                if loc.shared {
                    data_regs[loc.reg as usize] ^= junk << loc.shift;
                } else {
                    data_regs[loc.reg as usize] = data_regs[loc.reg as usize] & !0xffff_ffff | junk;
                }
            }
            let ret = call_with_fp(r[0], r[1], r[2], r[3], r[4], r[5], fp, handler(op).unwrap());
            // The register entry.
            for k in 0..e.nin as usize {
                rr[k] = vals[e.ins[k] as usize];
            }
            for j in 0..e.ndata as usize {
                rr[e.nin as usize + j] = data_regs[e.data[j] as usize];
            }
            let f: unsafe extern "sysv64" fn(u64, u64, u64, u64, u64, u64) -> RegRet = unsafe { std::mem::transmute(rf) };
            // `rbp` is unused: any value.
            let RegRet(x0, x1) = unsafe { f(rr[0], rr[1], rr[2], rr[3], rr[4], rr[5]) };
            let got = [unsafe { x0.assume_init() }, unsafe { x1.assume_init() }];
            let what = || format!("{mn}: operands {vals:x?}, data {data:x?}");
            let mut n = 0;
            for k in 0..e.nout as usize {
                let i = e.outs[k] as usize;
                let w = match fx.opnds[i] {
                    Some(Effect::Write(w) | Effect::Update(w)) => w as u32,
                    x => panic!("{mn}: output {i} is {x:?}"),
                };
                let m = if w == 8 { u64::MAX } else { (1u64 << (8 * w)) - 1 };
                let want = unsafe { fp.offset(off(i) as isize).cast::<u64>().read_unaligned() };
                assert_eq!(got[n] & m, want & m, "{}: output {i}", what());
                n += 1;
            }
            if e.ret {
                let m = if info.shape == Shape::Br { 0xff } else { u64::MAX };
                assert_eq!(got[n] & m, ret & m, "{}: return value", what());
            }
            assert!(mem.0 == mem2.0, "{}: memory", what());
        }
        checked += 1;
    }
    assert!(checked > 400, "{checked} register entries checked");
}
