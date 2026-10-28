//! The inline sequences against the handlers: every opcode with an inline form, in random
//! one-instruction functions run through the VM, and its handler called directly on a frame
//! holding the same arguments and memory. The handlers are checked against a model in
//! `full_ops.rs`.

#![cfg(all(target_arch = "x86_64", any(target_os = "linux", target_vendor = "apple")))]

mod common;
use common::*;

use ryo_bytecode::asm::{self as rasm, has_inline, layout};
use ryo_rt::vm::{FP_ARG, MODE, handler};

/// Calls `f(a0..a5)` with `rbp = fp`, returning `rax`.
#[cfg(not(windows))]
#[unsafe(naked)]
extern "sysv64" fn call_with_fp(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, fp: *mut u8, f: *const ()) -> u64 {
    core::arch::naked_asm!("push rbp", "mov rbp, [rsp + 16]", "call qword ptr [rsp + 24]", "pop rbp", "ret");
}

/// Calls the Win64 handler `f(a0..a5)` with `rbp = fp`, returning `rax`: `a4` and `a5` again
/// past the callee's shadow space.
#[cfg(windows)]
#[unsafe(naked)]
extern "win64" fn call_with_fp(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, fp: *mut u8, f: *const ()) -> u64 {
    core::arch::naked_asm!(
        "push rbp",
        "mov rbp, [rsp + 64]",
        "sub rsp, 48",
        "mov rax, [rsp + 96]",
        "mov [rsp + 32], rax",
        "mov rax, [rsp + 104]",
        "mov [rsp + 40], rax",
        "call qword ptr [rsp + 120]",
        "add rsp, 48",
        "pop rbp",
        "ret"
    );
}

/// Calls `op`'s handler with `vals` (one per operand, in operand order) on frame `fp`, as
/// `full_ops.rs` does.
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
/// Slot `s` moved down so an operand of `op` there stays inside the result area, which ends
/// at the frame's top: the slots are drawn for 8-byte operands.
fn in_res(op: Opcode, s: u128) -> u128 {
    let s = s as u32 as i32;
    let top = if op == Opcode::MovW128 { RES + 16 } else { RES + 24 };
    (if (RES..0).contains(&s) { s.min(top) } else { s }) as u32 as u128
}

/// An overflow op's flag moved to an argument slot if it overlaps the result: the lowering
/// never overlaps them, and the inline form stores the flag first, the handler last.
fn flag_apart(op: Opcode, vals: &mut [u128], rng: &mut Rng) {
    let info = op.info();
    if let (Some(d), Some(o)) = (info.operand_index("d"), info.operand_index("o")) {
        let (d, f) = (vals[d] as u32 as i32, vals[o] as u32 as i32);
        if (d..d + 8).contains(&f) {
            vals[o] = ARGS[rng.below(7) as usize] as u32 as u128;
        }
    }
}

/// What `addr.sym` reads through its slot, and what `addr.sym.ind`'s import slot points to.
static REF_VAL: u64 = 0x1122_3344_5566_7788;
struct SyncPtr(#[allow(dead_code)] *const ());
unsafe impl Sync for SyncPtr {}
/// Plays an `__imp_` import slot.
static REF_IMP: SyncPtr = SyncPtr((&raw const REF_VAL).cast());

/// The operands of `addr.const`, `addr.sym` and `addr.sym.ind`: a constant, a data area
/// allocation, a symbol and an indirect one.
struct Refs {
    k: Const,
    d: Data,
    s: Sym,
    si: Sym,
}

impl Refs {
    fn new(w: &mut ImageWriter) -> Refs {
        Refs {
            k: w.add_const(&0x0102_0304_0506_0708u64.to_le_bytes(), 8, &[]),
            d: w.add_data(&[0x5a; 16], 8, &[], &[]),
            s: w.symbol("inline_ref_val", 0),
            si: w.symbol("inline_ref_imp", SYM_INDIRECT),
        }
    }

    /// The symbols to link the image with.
    fn syms() -> [(&'static str, usize); 2] {
        [("inline_ref_val", addr(&raw const REF_VAL)), ("inline_ref_imp", addr(&raw const REF_IMP))]
    }

    /// A random operand of kind `k` (`Abs` or `Sym`) of `op`.
    fn val(&self, op: Opcode, k: OperandKind, rng: &mut Rng) -> u128 {
        match k {
            OperandKind::Abs if rng.below(2) == 0 => self.k.0 as u128,
            OperandKind::Abs => (self.d.0 | ABS_DATA) as u128,
            OperandKind::Sym if op == Opcode::AddrSymInd => self.si.0 as u128,
            OperandKind::Sym => self.s.0 as u128,
            k => panic!("{}: operand {k:?}", op.mnemonic()),
        }
    }
}

/// `vals` of `op` as its handler takes them: `Abs` and `Sym` operands as the addresses of
/// the allocation and the slot in `img`.
fn resolve(op: Opcode, vals: &[u128], img: &Linked) -> Vec<u128> {
    let im = unsafe { Image::from_header(img.header) }.unwrap();
    op.info()
        .operands
        .iter()
        .zip(vals)
        .map(|(o, &v)| match o.kind {
            OperandKind::Abs => match Abs::from_word(v as u32) {
                Abs::Const(k) => im.consts().as_ptr() as u128 + k.0 as u128,
                Abs::Data(d) => im.data_ptr() as u128 + d.0 as u128,
            },
            OperandKind::Sym => (unsafe { im.symbols_ptr().add(v as usize) }) as u128,
            _ => v,
        })
        .collect()
}

/// The width in bits of `op` (its last mnemonic part).
fn bits(op: Opcode) -> u32 {
    match op.mnemonic().rsplit('.').next().unwrap() {
        "w8" => 8,
        "w16" => 16,
        "w32" => 32,
        "w128" => 128,
        _ => 64,
    }
}

/// Whether `op` is a division or remainder.
fn is_div(op: Opcode) -> bool {
    op.mnemonic().starts_with("div.") || op.mnemonic().starts_with("rem.")
}

/// For a division (whose operands are argument slots), the arguments changed so it is
/// defined: a zero divisor made 1, and a signed `MIN / -1`'s dividend made `MIN + 1`. A
/// divisor of -1 and a dividend of `MIN` stay likely otherwise.
fn div_defined(op: Opcode, vals: &[u128], args: &mut [u64; 8]) {
    if !is_div(op) {
        return;
    }
    let info = op.info();
    let arg = |name: &str| ((vals[info.operand_index(name).unwrap()] as u32 as i32 - ARGS[0]) / 8) as usize;
    let (a, b) = (arg("a"), arg("b"));
    let n = bits(op);
    let mask = if n == 64 { u64::MAX } else { (1 << n) - 1 };
    if args[b] & mask == 0 {
        args[b] |= 1;
    }
    let min = 1 << (n - 1);
    if op.mnemonic().starts_with("div.s") || op.mnemonic().starts_with("rem.s") {
        if args[b] & mask == mask && args[a] & mask == min {
            args[a] += 1;
        }
    }
}

/// For a division in a run, the instructions before it that make its divisor positive and
/// odd: never 0 or -1.
fn div_guards(op: Opcode, vals: &[u128]) -> Vec<(Opcode, Vec<u128>)> {
    if !is_div(op) {
        return Vec::new();
    }
    let b = vals[op.info().operand_index("b").unwrap()];
    let n = bits(op);
    let (and, or) = match n {
        8 => (Opcode::AndImmW8, Opcode::OrImmW8),
        16 => (Opcode::AndImmW16, Opcode::OrImmW16),
        32 => (Opcode::AndImmW32, Opcode::OrImmW32),
        _ => (Opcode::AndImmW64, Opcode::OrImmW64),
    };
    vec![(and, vec![b, b, (u64::MAX >> (65 - n)) as u128]), (or, vec![b, b, 1])]
}

/// The sret pointer's slot.
const SRET: i32 = -48;

/// An instruction of `op` on random operands, followed by `ret` (branches: setting the
/// result to 1 or 2, by the path taken), and the operand values.
fn function(op: Opcode, rng: &mut Rng, args: &[u64; 8], refs: &Refs) -> (Vec<u32>, Vec<u128>) {
    let mut a = Asm::new();
    a.sret(Slot(SRET));
    a.i(Insn::Zero { d: Slot(RES), len: 32 });
    let mut vals = Vec::new();
    let info = op.info();
    for o in info.operands {
        vals.push(match o.kind {
            // An overflow op's flag in the result area too, after its result.
            OperandKind::Slot if o.name == "d" && info.operand_index("o").is_some() => (RES + rng.below(16) as i32) as u32 as u128,
            OperandKind::Slot if o.name == "o" => (RES + 24 + rng.below(8) as i32) as u32 as u128,
            OperandKind::Slot if o.name == "d" => in_res(op, (RES + rng.below(24) as i32) as u32 as u128),
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
            k => refs.val(op, k, rng),
        });
    }
    let at = a.raw(op, &vals);
    if info.operand_index("t").is_some() {
        a.i(Insn::ImmW8 { d: Slot(RES), imm: 1 });
        a.ret(Slot(RES), 32);
        let l = a.pos();
        a.patch(at, "t", l);
        a.i(Insn::ImmW8 { d: Slot(RES), imm: 2 });
    }
    a.ret(Slot(RES), 32);
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
        let mut w = ImageWriter::new(unique_scid());
        let refs = Refs::new(&mut w);
        for _ in 0..32 {
            let mut args: [u64; 8] = std::array::from_fn(|_| rng.value());
            if rng.below(3) == 0 {
                args[1] = args[0];
            }
            let (c, vals) = function(op, &mut rng, &args, &refs);
            div_defined(op, &vals, &mut args);
            code.push(c);
            operands.push(vals);
            inputs.push(args);
        }
        let fs: Vec<Func> = code.iter().map(|c| w.add_function(func(c.clone(), 48, 64, 32))).collect();
        let img = link(w.finish(ENC).expect("image"), &Refs::syms());
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
            let r_off = by_handler(op, &resolve(op, &operands[i], &img), &args);
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
    let refs = Refs::new(&mut w);
    let mut fs = Vec::new();
    for _ in 0..20000 {
        let mut a = Asm::new();
        a.sret(Slot(SRET));
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
                    OperandKind::Slot if o.name == "d" => {
                        (match (last_d, rng.below(3)) {
                            (Some(d), 0) => d,
                            (Some(d), 1) => (d + [-4, -2, -1, 1, 2, 4][rng.below(6) as usize]).clamp(RES, RES + 24),
                            _ => RES + rng.below(24) as i32,
                        }) as u32 as u128
                    }
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
                    k => refs.val(op, k, &mut rng),
                });
            }
            for (o, v) in op.info().operands.iter().zip(&mut vals) {
                if o.kind == OperandKind::Slot {
                    *v = in_res(op, *v);
                }
            }
            flag_apart(op, &mut vals, &mut rng);
            for (g, gv) in div_guards(op, &vals) {
                a.raw(g, &gv);
                run.push((g, gv));
            }
            a.raw(op, &vals);
            run.push((op, vals));
        }
        a.ret(Slot(RES), 32);
        let code = a.done();
        fs.push(w.add_function(func(code.clone(), 48, 64, 32)));
        runs.push((code, run));
    }
    let img = link(w.finish(ENC).expect("image"), &Refs::syms());
    register(&[&img]);
    for (i, (code, run)) in runs.iter().enumerate() {
        let mut args: [u64; 8] = std::array::from_fn(|_| rng.value());
        args[7] = buf as u64;
        let fresh: [u8; 64] = std::array::from_fn(|j| (rng.next() >> (j % 8)) as u8);
        unsafe { buf.write(fresh) };
        let r_vm: [u8; 32] = ok(img.id(fs[i]), args);
        let m_vm = unsafe { buf.read() };
        unsafe { buf.write(fresh) };
        let run: Vec<(Opcode, Vec<u128>)> = run.iter().map(|(op, v)| (*op, resolve(*op, v, &img))).collect();
        let (r_h, m_h) = by_handlers(&run, &args, buf);
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

/// Scratch slots below the result area: written and read by the runs, not returned.
const SCR: i32 = -64;

/// The frame bytes an inline instruction of `op` with operand values `vals` reads and
/// writes, as offsets from `fp` (reads over-approximated, writes exact).
fn frame_effects(op: Opcode, vals: &[u128]) -> (Vec<i32>, Vec<i32>) {
    let m = op.mnemonic();
    let w = |m: &str| match m.rsplit('.').next().unwrap() {
        "w8" => 1,
        "w16" => 2,
        "w32" => 4,
        "w128" => 16,
        _ => 8,
    };
    let bytes = |s: i32, n: i32| (s..s + n).collect::<Vec<_>>();
    let (mut r, mut wr) = (Vec::new(), Vec::new());
    let ptr = m.starts_with("ptr.") || m == "addr";
    let cmp = ["eq", "ne", "lt", "le", "gt", "ge"].iter().any(|c| m.starts_with(c));
    for (o, &v) in op.info().operands.iter().zip(vals) {
        let s = v as u32 as i32;
        match o.kind {
            OperandKind::Slot if o.name == "d" => wr.extend(bytes(
                s,
                if ptr {
                    8
                } else if cmp || m.starts_with("cmp3") {
                    1
                } else if m.starts_with("ctlz") || m.starts_with("cttz") {
                    // The count, a `u32`.
                    4
                } else {
                    w(m)
                },
            )),
            // A rotate's amount is a `u32`.
            OperandKind::Slot if o.name == "b" && m.starts_with("rot") => r.extend(bytes(s, w(m).max(4))),
            OperandKind::Slot => r.extend(bytes(s, if ptr { 8 } else { w(m) })),
            OperandKind::Mem => r.extend(bytes(s, 8)),
            _ => {}
        }
    }
    (r, wr)
}

/// Runs of inline instructions with dead-slot hints (`Asm::dead`) where scratch bytes are
/// dead, so the encoder drops stores, against their handlers.
#[test]
fn dead_stores_match_handlers() {
    let mut rng = Rng(0xdead_5107);
    let buf: *mut [u8; 64] = Box::into_raw(Box::new([0u8; 64]));
    let ops: Vec<Opcode> =
        ALL_OPCODES.iter().copied().filter(|&op| has_inline(op) && op != Opcode::Addr && op.info().operand_index("t").is_none()).collect();
    let mut w = ImageWriter::new(unique_scid());
    let refs = Refs::new(&mut w);
    w.prepare(ENC);
    let (mut runs, mut encoded, mut fs) = (Vec::new(), Vec::new(), Vec::new());
    let mut dropped = 0;
    let mut hints = 0;
    for _ in 0..5000 {
        let mut run: Vec<(Opcode, Vec<u128>)> = Vec::new();
        let mut recent: Vec<i32> = Vec::new();
        for _ in 0..2 + rng.below(12) {
            let op = ops[rng.below(ops.len() as u64) as usize];
            let mut vals = Vec::new();
            for o in op.info().operands {
                vals.push(match o.kind {
                    // Mostly scratch, where things die.
                    OperandKind::Slot if o.name == "d" => {
                        let base = if rng.below(4) == 0 { RES } else { SCR };
                        (base + rng.below(3) as i32 * 8) as u32 as u128
                    }
                    OperandKind::Slot if !recent.is_empty() && rng.below(3) != 0 => recent[rng.below(recent.len() as u64) as usize] as u32 as u128,
                    OperandKind::Slot => ARGS[rng.below(7) as usize] as u32 as u128,
                    OperandKind::Mem => (PTR as u32 as u128) | (rng.below(57) as u128) << 32,
                    OperandKind::U8 => rng.below(8) as u128,
                    OperandKind::U16 | OperandKind::U32 => rng.below(16) as u128,
                    OperandKind::U64 | OperandKind::I64 => rng.value() as u128,
                    k => refs.val(op, k, &mut rng),
                });
            }
            flag_apart(op, &mut vals, &mut rng);
            if let Some(d) = op.info().operand_index("d") {
                recent.push(vals[d] as u32 as i32);
            }
            run.extend(div_guards(op, &vals));
            run.push((op, vals));
        }
        // Scratch bytes dead after each instruction: not read again before written. The
        // result area is read by the `ret`.
        let mut live: std::collections::BTreeSet<i32> = (RES..RES + 32).collect();
        let mut dead_after = vec![Vec::new(); run.len()];
        for (i, (op, vals)) in run.iter().enumerate().rev() {
            let mut start = None;
            for b in SCR..=SCR + 24 {
                match (b < SCR + 24 && !live.contains(&b), start) {
                    (true, None) => start = Some(b),
                    (false, Some(s)) => {
                        dead_after[i].push((s, (b - s) as u32));
                        start = None;
                    }
                    _ => {}
                }
            }
            let (r, wr) = frame_effects(*op, vals);
            wr.iter().for_each(|b| _ = live.remove(b));
            live.extend(r);
        }
        let mut a = rasm::Asm::new(ENC);
        let sret = rasm::Opnd::Slot(-80);
        a.insn(Opcode::Arg, &[sret.clone(), rasm::Opnd::Imm(ryo_bytecode::asm::ArgReg { xmm: false, size: 8, index: 0 }.word() as u64)]);
        // Scratch and results start zeroed, as on the handlers' frame.
        a.insn(Opcode::Zero, &[rasm::Opnd::Slot(SCR), rasm::Opnd::Imm(64)]);
        for (i, (op, vals)) in run.iter().enumerate() {
            let mut words = vec![*op as u32];
            for (o, &v) in op.info().operands.iter().zip(vals) {
                match o.kind {
                    OperandKind::Mem | OperandKind::U64 | OperandKind::I64 => words.extend([v as u32, (v >> 32) as u32]),
                    _ => words.push(v as u32),
                }
            }
            let opnds: Vec<rasm::Opnd<rasm::Label>> =
                rasm::operands(&words, 0).into_iter().map(|o| o.map_targets(|_| Err::<rasm::Label, ()>(())).unwrap()).collect();
            a.insn(*op, &opnds);
            for &(lo, len) in &dead_after[i] {
                a.dead(lo as u32, len);
            }
        }
        // The 32-byte result goes through the sret pointer.
        a.insn(Opcode::StoreCopy, &[rasm::Opnd::Mem(-80, 0), rasm::Opnd::Slot(RES), rasm::Opnd::Imm(32)]);
        a.insn(Opcode::Ret, &[sret, rasm::Opnd::Imm(8)]);
        let enc = a.finish(80, |s| s);
        dropped += enc.dropped.len();
        hints += enc.hints.len();
        // Read back to the reduced set, it re-encodes exactly, dropped stores included.
        let d = rasm::decode_reduced(&enc, ENC).expect("decodes");
        let re = rasm::encode_reduced(&d.words, d.frame_size, &d.cleanup, &d.scopes, &d.dropped, &enc.rodata, ENC).expect("re-encodes");
        assert_eq!(re, enc);
        // The same in one pass, with the instruction list.
        let l = rasm::decode_reduced_indexed(&enc, ENC).expect("decodes indexed");
        assert_eq!(l, d);
        encoded.push(enc);
        fs.push(w.add_function(func(Vec::new(), 80, 64, 32)));
        runs.push(run);
    }
    assert!(dropped > 1000, "{dropped} stores dropped");
    assert!(hints > 1000, "{hints} instruction entries");
    let img = link(w.finish_encoded(encoded).expect("image"), &Refs::syms());
    register(&[&img]);
    for (i, run) in runs.iter().enumerate() {
        let mut args: [u64; 8] = std::array::from_fn(|_| rng.value());
        args[7] = buf as u64;
        let fresh: [u8; 64] = std::array::from_fn(|j| (rng.next() >> (j % 8)) as u8);
        unsafe { buf.write(fresh) };
        let r_vm: [u8; 32] = ok(img.id(fs[i]), args);
        let m_vm = unsafe { buf.read() };
        unsafe { buf.write(fresh) };
        let run: Vec<(Opcode, Vec<u128>)> = run.iter().map(|(op, v)| (*op, resolve(*op, v, &img))).collect();
        let (r_h, m_h) = by_handlers(&run, &args, buf);
        let what = || run.iter().map(|(op, v)| format!("{} {v:x?}", op.mnemonic())).collect::<Vec<_>>().join("\n");
        assert_eq!(r_vm, r_h, "result:\n{}\nargs {args:x?}", what());
        assert_eq!(m_vm, m_h, "memory:\n{}", what());
    }
}
