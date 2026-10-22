//! The inline sequences against the handlers: every opcode with an inline form, in random
//! one-instruction functions run through the VM, and its handler called directly on a frame
//! holding the same arguments and memory. The handlers are checked against a model in
//! `ops.rs`.

#![cfg(all(target_arch = "x86_64", target_os = "linux"))]

mod common;
use common::*;

use ryo_bytecode::asm::{has_inline, layout};
use ryo_rt::vm::{FP_ARG, MODE, handler};

/// Calls `f(a0..a5)` with `rbp = fp`, returning `rax`.
#[unsafe(naked)]
extern "sysv64" fn call_with_fp(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, fp: *mut u8, f: *const ()) -> u64 {
    core::arch::naked_asm!("push rbp", "mov rbp, [rsp + 16]", "call qword ptr [rsp + 24]", "pop rbp", "ret");
}

/// Calls `op`'s handler with `vals` (one per operand, in operand order) on frame `fp`, as
/// `ops.rs` does.
fn call_handler(op: Opcode, vals: &[u128], fp: *mut u8) -> u64 {
    let l = layout(op, MODE);
    // A memory operand's instruction words are slot | k << 32; its registers take k in the
    // high half.
    let vals: Vec<u128> = op
        .info()
        .operands
        .iter()
        .zip(vals)
        .map(|(o, &v)| if o.kind == OperandKind::Mem { (v as u32 as u128) | ((v >> 32) as u32 as u128) << 64 } else { v })
        .collect();
    let mut r = [0u64; 6];
    if FP_ARG {
        r[0] = fp as u64;
    }
    for (loc, &v) in l.locs.iter().zip(&vals) {
        let i = loc.reg as usize;
        match (loc.count, loc.shared) {
            (0, _) => {}
            (2, _) => (r[i], r[i + 1]) = (v as u64, (v >> 64) as u64),
            (_, true) => r[i] |= (v as u32 as u64) << loc.shift,
            _ => r[i] = v as u64,
        }
    }
    let f = handler(op).unwrap_or_else(|| panic!("{}: no handler", op.mnemonic()));
    call_with_fp(r[0], r[1], r[2], r[3], r[4], r[5], fp, f)
}

/// What the function of `vals` returns when `op`'s handler does the instruction: the result
/// area after it, on a frame with `args` at `fp + 16`.
fn by_handler(op: Opcode, vals: &[u128], args: &[u64; 8]) -> [u8; 32] {
    #[repr(C, align(16))]
    struct Frame([u8; 1024]);
    let mut frame = Box::new(Frame([0; 1024]));
    let fp = unsafe { frame.0.as_mut_ptr().add(512) };
    for (i, a) in args.iter().enumerate() {
        unsafe { fp.offset(ARGS[0] as isize + 8 * i as isize).cast::<u64>().write_unaligned(*a) };
    }
    // A branch's handler returns its condition; `!` inverts the jump on it.
    let neg = op.info().operands.iter().zip(vals).any(|(o, &v)| o.kind == OperandKind::Neg && v != 0);
    let taken = (call_handler(op, vals, fp) as u8 != 0) != neg;
    let res = unsafe { fp.offset(RES as isize) };
    if op.info().operand_index("t").is_some() {
        unsafe { res.write_bytes(0, 32) };
        unsafe { res.write(if taken { 2 } else { 1 }) };
    }
    std::array::from_fn(|i| unsafe { *res.add(i) })
}

struct Rng(u64);
impl Rng {
    fn next(&mut self) -> u64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        self.0
    }
    fn below(&mut self, n: u64) -> u64 {
        self.next() % n
    }
    /// A value with the edge cases of every width likely.
    fn value(&mut self) -> u64 {
        let v = match self.below(8) {
            0 => 0,
            1 => self.below(4),
            2 => u64::MAX - self.below(2),
            3 => 0x80 << (8 * self.below(8)),
            4 => (0x7f << (8 * self.below(8))) | (u64::MAX >> (8 * self.below(8) + 1)),
            _ => self.next(),
        };
        if self.below(4) == 0 { v.rotate_left(self.below(64) as u32) } else { v }
    }
}

/// Argument slots: eight words at `fp + 16`, the last a pointer to a 64-byte buffer.
const ARGS: [i32; 7] = [16, 24, 32, 40, 48, 56, 64];
const PTR: i32 = 72;
/// The result area, returned whole.
const RES: i32 = -32;

/// An instruction of `op` on random operands, followed by `ret` (branches: setting the
/// result to 1 or 2, by the path taken), and the operand values.
fn function(op: Opcode, rng: &mut Rng, args: &[u64; 8]) -> (Vec<u32>, Vec<u128>) {
    let mut a = Asm::new();
    a.i(Insn::Zero { d: Slot(RES), len: 32 });
    let mut vals = Vec::new();
    let info = op.info();
    for o in info.operands {
        vals.push(match o.kind {
            OperandKind::Slot if o.name == "d" => (RES + rng.below(24) as i32) as u32 as u128,
            OperandKind::Slot => ARGS[rng.below(7) as usize] as u32 as u128,
            OperandKind::Mem => (PTR as u32 as u128) | (rng.below(57) as u128) << 32,
            OperandKind::U8 | OperandKind::U16 | OperandKind::U32 | OperandKind::U64 | OperandKind::I64 => {
                // Often an argument's value, for equal compares; small for shifts and strides.
                let v = match rng.below(4) {
                    0 => args[rng.below(7) as usize],
                    1 => rng.below(70),
                    2 => (rng.below(200) as i64 - 100) as u64,
                    _ => rng.value(),
                };
                let bits = match o.kind {
                    OperandKind::U8 => 8,
                    OperandKind::U16 => 16,
                    OperandKind::U32 => 32,
                    _ => 64,
                };
                (if bits == 64 { v } else { v & ((1 << bits) - 1) }) as u128
            }
            OperandKind::Neg => rng.below(2) as u128,
            OperandKind::Target => 0,
            k => panic!("{}: operand {k:?}", op.mnemonic()),
        });
    }
    let at = a.raw(op, &vals);
    if info.operand_index("t").is_some() {
        a.i(Insn::ImmW8 { d: Slot(RES), imm: 1 });
        a.i(Insn::Ret { s: Slot(RES), len: 32 });
        let l = a.pos();
        a.patch(at, "t", l);
        a.i(Insn::ImmW8 { d: Slot(RES), imm: 2 });
    }
    a.i(Insn::Ret { s: Slot(RES), len: 32 });
    (a.done(), vals)
}

#[test]
fn inline_matches_handlers() {
    let mut rng = Rng(0xfeed_beef);
    let buf: *mut [u8; 64] = Box::into_raw(Box::new([0u8; 64]));
    let mut fresh = [0u8; 64];
    for &op in ALL_OPCODES {
        // `addr`'s result is a frame address, which isn't the same in the two frames.
        if !has_inline(op) || op == Opcode::Addr {
            continue;
        }
        let mut code = Vec::new();
        let mut operands = Vec::new();
        let mut inputs = Vec::new();
        for _ in 0..32 {
            let mut args: [u64; 8] = std::array::from_fn(|_| rng.value());
            if rng.below(3) == 0 {
                args[1] = args[0];
            }
            let (c, vals) = function(op, &mut rng, &args);
            code.push(c);
            operands.push(vals);
            inputs.push(args);
        }
        let mut w = ImageWriter::new(unique_scid());
        let fs: Vec<Func> = code.iter().map(|c| w.add_function(func(c.clone(), 32, 64, 32))).collect();
        let img = link(w.finish(ENC).expect("image"), &[]);
        register(&[&img]);
        for (i, args) in inputs.iter().enumerate() {
            for (j, a) in fresh.iter_mut().enumerate() {
                *a = (rng.next() >> (j % 8)) as u8;
            }
            let mut args = *args;
            args[7] = buf as u64;
            unsafe { buf.write(fresh) };
            let r_on: [u8; 32] = ok(img.id(fs[i]), args);
            let m_on = unsafe { buf.read() };
            unsafe { buf.write(fresh) };
            let r_off = by_handler(op, &operands[i], &args);
            let m_off = unsafe { buf.read() };
            let what = || format!("{}\n{}", op.mnemonic(), Disasm(&code[i]));
            assert_eq!(r_on, r_off, "result: {}\nargs {args:x?}", what());
            assert_eq!(m_on, m_off, "memory: {}", what());
        }
    }
}

/// Runs of inline instructions against their handlers, one after the other on one frame:
/// the instructions read the results of the ones before, so the register cache keeps and
/// drops values between them.
#[test]
fn inline_runs_match_handlers() {
    let mut rng = Rng(0x5eed_cafe);
    let buf: *mut [u8; 64] = Box::into_raw(Box::new([0u8; 64]));
    // `addr`'s result is a frame address; branches would leave the run.
    let ops: Vec<Opcode> =
        ALL_OPCODES.iter().copied().filter(|&op| has_inline(op) && op != Opcode::Addr && op.info().operand_index("t").is_none()).collect();
    let mut runs = Vec::new();
    let mut w = ImageWriter::new(unique_scid());
    let mut fs = Vec::new();
    for _ in 0..2000 {
        let mut a = Asm::new();
        a.i(Insn::Zero { d: Slot(RES), len: 32 });
        let mut run = Vec::new();
        for _ in 0..2 + rng.below(12) {
            let last: Option<&(Opcode, Vec<u128>)> = run.last();
            // Mostly at the width of the instruction before, writing where it wrote or next
            // to it, so cached values are reused and partly overwritten.
            let width = |op: Opcode| op.mnemonic().rsplit('.').next().unwrap();
            let op = loop {
                let op = ops[rng.below(ops.len() as u64) as usize];
                if last.is_none_or(|(l, _)| rng.below(4) == 0 || width(*l) == width(op)) {
                    break op;
                }
            };
            let last_d = last.and_then(|(op, v)| Some(v[op.info().operand_index("d")?] as u32 as i32));
            let mut vals = Vec::new();
            for o in op.info().operands {
                vals.push(match o.kind {
                    OperandKind::Slot if o.name == "d" => (match (last_d, rng.below(3)) {
                        (Some(d), 0) => d,
                        (Some(d), 1) => (d + [-4, -2, -1, 1, 2, 4][rng.below(6) as usize]).clamp(RES, RES + 24),
                        _ => RES + rng.below(24) as i32,
                    }) as u32 as u128,
                    // Mostly results of earlier instructions, at the offsets they were written.
                    // Mostly results of the instructions just before.
                    OperandKind::Slot if rng.below(3) != 0 => {
                        let back = run.iter().rev().take(3).filter_map(|(op, v): &(Opcode, Vec<u128>)| Some(v[op.info().operand_index("d")?]));
                        let back: Vec<u128> = back.collect();
                        match back.len() {
                            0 => (RES + rng.below(24) as i32) as u32 as u128,
                            n => back[rng.below(n as u64) as usize],
                        }
                    }
                    OperandKind::Slot => ARGS[rng.below(7) as usize] as u32 as u128,
                    OperandKind::Mem => (PTR as u32 as u128) | (rng.below(57) as u128) << 32,
                    OperandKind::U8 => rng.below(8) as u128,
                    OperandKind::U16 | OperandKind::U32 => rng.below(16) as u128,
                    OperandKind::U64 | OperandKind::I64 => match rng.below(3) {
                        0 => rng.below(16) as u128,
                        _ => rng.value() as u128,
                    },
                    k => panic!("{}: operand {k:?}", op.mnemonic()),
                });
            }
            a.raw(op, &vals);
            run.push((op, vals));
        }
        a.i(Insn::Ret { s: Slot(RES), len: 32 });
        let code = a.done();
        fs.push(w.add_function(func(code.clone(), 32, 64, 32)));
        runs.push((code, run));
    }
    let img = link(w.finish(ENC).expect("image"), &[]);
    register(&[&img]);
    for (i, (code, run)) in runs.iter().enumerate() {
        let mut args: [u64; 8] = std::array::from_fn(|_| rng.value());
        args[7] = buf as u64;
        let fresh: [u8; 64] = std::array::from_fn(|j| (rng.next() >> (j % 8)) as u8);
        unsafe { buf.write(fresh) };
        let r_vm: [u8; 32] = ok(img.id(fs[i]), args);
        let m_vm = unsafe { buf.read() };
        unsafe { buf.write(fresh) };
        let (r_h, m_h) = by_handlers(run, &args, buf);
        let what = || Disasm(code).to_string();
        assert_eq!(r_vm, r_h, "result:\n{}\nargs {args:x?}", what());
        assert_eq!(m_vm, m_h, "memory:\n{}", what());
    }
}

/// The result area and the buffer after the handlers of `run` on a frame with `args`.
fn by_handlers(run: &[(Opcode, Vec<u128>)], args: &[u64; 8], buf: *mut [u8; 64]) -> ([u8; 32], [u8; 64]) {
    #[repr(C, align(16))]
    struct Frame([u8; 1024]);
    let mut frame = Box::new(Frame([0; 1024]));
    let fp = unsafe { frame.0.as_mut_ptr().add(512) };
    for (i, a) in args.iter().enumerate() {
        unsafe { fp.offset(ARGS[0] as isize + 8 * i as isize).cast::<u64>().write_unaligned(*a) };
    }
    for (op, vals) in run {
        call_handler(*op, vals, fp);
    }
    let res = unsafe { fp.offset(RES as isize) };
    (std::array::from_fn(|i| unsafe { *res.add(i) }), unsafe { buf.read() })
}
