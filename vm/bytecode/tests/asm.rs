//! The machine-code encoder against its decoder: `decode(encode(f)) == f` for every opcode,
//! with the frame size and the unwind entries (through the LSDA), in every mode.

use ryo_bytecode::asm::{self, Mode, lsda};
use ryo_bytecode::image::{CATCH, CONTINUE, CleanupEntry, op_may_unwind};
use ryo_bytecode::insn::*;

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
    /// A value of every immediate size class: 0, small, 32-bit, negative 32-bit, 64-bit.
    fn imm(&mut self) -> u64 {
        match self.below(6) {
            0 => 0,
            1 => self.below(100) + 1,
            2 => u32::MAX as u64 - self.below(3),
            3 => (-(self.below(1000) as i64) - 1) as u64,
            4 => 1 << 32 | self.next() >> 40,
            _ => self.next(),
        }
    }
}

const MODES: [Mode; 8] = {
    let mut m = [Mode { fp_arg: false, align_loops: false, pe: false }; 8];
    let mut i = 0;
    while i < 8 {
        m[i] = Mode { fp_arg: i & 1 != 0, align_loops: i & 2 != 0, pe: i & 4 != 0 };
        i += 1;
    }
    m
};

/// A function built from instructions whose targets are instruction indices.
struct Fn {
    insns: Vec<Vec<u32>>,
    /// (instruction index of the target word, word index in the instruction, target index).
    targets: Vec<(usize, usize, usize)>,
    /// (call, landing pad index and whether it catches, or `None` for continue).
    unwind: Vec<(usize, Option<(usize, bool)>)>,
}

impl Fn {
    fn words(&self) -> (Vec<u32>, Vec<CleanupEntry>) {
        let mut starts = Vec::new();
        let mut w = 0;
        for i in &self.insns {
            starts.push(w as u32);
            w += i.len();
        }
        let mut code: Vec<Vec<u32>> = self.insns.clone();
        for &(i, k, t) in &self.targets {
            code[i][k] = starts[t].wrapping_sub(starts[i]);
        }
        let cleanup = self
            .unwind
            .iter()
            .map(|&(c, p)| CleanupEntry {
                offset: starts[c],
                target: p.map_or(CONTINUE, |(p, catch)| starts[p] | if catch { CATCH } else { 0 }),
            })
            .collect();
        (code.concat(), cleanup)
    }
}

/// An instruction of `op` with random operands; its targets point at `targets(rng)`.
fn insn(op: Opcode, rng: &mut Rng, list_len: usize, f: &mut Fn, target: &mut dyn FnMut(&mut Rng) -> usize) -> Vec<u32> {
    let i = f.insns.len();
    let mut w = vec![op as u32];
    for o in op.info().operands {
        match o.kind {
            OperandKind::Slot => w.push(rng.next() as u32),
            OperandKind::Mem => w.extend([rng.next() as u32, rng.imm() as u32]),
            OperandKind::U8 => w.push(rng.imm() as u8 as u32),
            OperandKind::U16 => w.push(rng.imm() as u16 as u32),
            OperandKind::U32 => w.push(rng.imm() as u32),
            OperandKind::U64 | OperandKind::I64 => {
                let v = rng.imm();
                w.extend([v as u32, (v >> 32) as u32]);
            }
            OperandKind::U128 => {
                let (a, b) = (rng.imm(), rng.imm());
                w.extend([a as u32, (a >> 32) as u32, b as u32, (b >> 32) as u32]);
            }
            OperandKind::Const | OperandKind::Sym | OperandKind::Site | OperandKind::Func => w.push(rng.below(1 << 20) as u32),
            OperandKind::Abs => w.push(rng.below(1 << 20) as u32 | if rng.below(2) == 0 { ABS_DATA } else { 0 }),
            OperandKind::Neg => w.push(rng.below(2) as u32),
            OperandKind::Target => {
                f.targets.push((i, w.len(), target(rng)));
                w.push(0);
            }
            OperandKind::List(e) => {
                w.push(list_len as u32);
                for _ in 0..list_len {
                    match e {
                        ElemKind::Target => {
                            f.targets.push((i, w.len(), target(rng)));
                            w.push(0);
                        }
                        ElemKind::Word => w.push(rng.next() as u32),
                        _ => {
                            let v = (rng.imm() as u128) << 64 | rng.imm() as u128;
                            let v = match e {
                                ElemKind::Case8 => v as u8 as u128,
                                ElemKind::Case16 => v as u16 as u128,
                                ElemKind::Case32 => v as u32 as u128,
                                ElemKind::Case64 => v as u64 as u128,
                                _ => v,
                            };
                            for k in 0..e.words() - 1 {
                                w.push((v >> (32 * k)) as u32);
                            }
                            f.targets.push((i, w.len(), target(rng)));
                            w.push(0);
                        }
                    }
                }
            }
        }
    }
    w
}

fn check(f: &Fn, frame_size: u32, mode: Mode, what: &str) -> asm::Encoded {
    let (code, mut cleanup) = f.words();
    let enc = asm::encode(&code, frame_size, &cleanup, mode).unwrap_or_else(|e| panic!("{what}: {e:?}\n{}", Disasm(&code)));
    let sites = lsda::parse(&lsda::write(&enc.call_sites)).expect("LSDA");
    assert_eq!(sites, enc.call_sites, "{what}");
    let dec = asm::decode(&enc.code, &enc.relocs, &enc.rodata, &sites, mode)
        .unwrap_or_else(|e| panic!("{what} {mode:?}: {e:?}\n{}\n{:02x?}", Disasm(&code), enc.code));
    if dec.words != code {
        panic!("{what} {mode:?}:\n{}\n---\n{}", Disasm(&code), Disasm(&dec.words));
    }
    assert_eq!(dec.frame_size, frame_size, "{what}");
    cleanup.sort();
    assert_eq!(dec.cleanup, cleanup, "{what}");
    enc
}

const FRAMES: [u32; 6] = [0, 16, 112, 128, 4096, 1 << 20];

#[test]
fn every_opcode_round_trips() {
    let mut rng = Rng(0x9e3779b97f4a7c15);
    for &op in ALL_OPCODES {
        for (round, mode) in MODES.iter().enumerate() {
            for list_len in [0, 1, 3] {
                // [abort], insn, filler…, lpad, jmp 0, abort.
                let mut f = Fn { insns: vec![vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
                let fillers = [0, 2, 40][(round + list_len) % 3];
                let last = 2 + fillers + 2;
                let mut target = |rng: &mut Rng| [0, 1, last, 2 + fillers][rng.below(4) as usize];
                let w = insn(op, &mut rng, list_len, &mut f, &mut target);
                f.insns.push(w);
                for k in 0..fillers {
                    let filler = insn(Opcode::AddImmW64, &mut rng, 0, &mut f, &mut |_| 0);
                    let _ = k;
                    f.insns.push(filler);
                }
                let pad = f.insns.len();
                f.insns.push(vec![Opcode::Lpad as u32, rng.next() as u32]);
                f.insns.push(vec![Opcode::Jmp as u32, 0]);
                f.targets.push((pad + 1, 1, 0));
                f.insns.push(vec![Opcode::Abort as u32]);
                if op_may_unwind(op) && list_len != 1 {
                    f.unwind.push((1, if list_len == 0 { None } else { Some((pad, round % 2 == 0)) }));
                }
                check(&f, FRAMES[(round + list_len) % FRAMES.len()], *mode, op.mnemonic());
            }
        }
    }
}

/// Branches that need `rel32`, chains of them, and loops (padded with alignment on).
#[test]
fn long_branches_and_loops() {
    let mut rng = Rng(42);
    for mode in MODES {
        for n in [1, 10, 30, 31, 32, 200] {
            let mut f = Fn { insns: Vec::new(), targets: Vec::new(), unwind: Vec::new() };
            // 0: br forward to the end, n fillers, br back to 1, jmp 0, abort.
            f.insns.push(vec![Opcode::Br as u32, 8, 0, 0]);
            for _ in 0..n {
                let w = insn(Opcode::MovW64, &mut rng, 0, &mut f, &mut |_| 0);
                f.insns.push(w);
            }
            let end = f.insns.len() + 3;
            f.targets.push((0, 3, end));
            let b = f.insns.len();
            f.insns.push(vec![Opcode::BrLtUImmW32 as u32, 8, 7, 1, 0]);
            f.targets.push((b, 4, 1));
            f.insns.push(vec![Opcode::Jmp as u32, 0]);
            f.targets.push((b + 1, 1, 0));
            f.insns.push(vec![Opcode::Abort as u32]);
            f.insns.push(vec![Opcode::Unreachable as u32]);
            let enc = check(&f, 32, mode, "long branches");
            if mode.align_loops {
                // The loop heads (instructions 0 and 1) start at multiples of 16.
                assert!(enc.code.len() > 16);
            }
        }
    }
}

/// The register cache: random runs of inline instructions on a few overlapping slots, with
/// branches into them and some handler calls, so reloads are dropped and the cache is
/// cleared at targets.
#[test]
fn register_cache_round_trips() {
    let mut rng = Rng(7);
    let inline: Vec<Opcode> = ALL_OPCODES.iter().copied().filter(|&op| asm::has_inline(op)).collect();
    // Slots at 8-byte and 4-byte offsets, so writes overlap cached slots partly.
    const SLOTS: [i32; 6] = [-8, -16, -24, -12, -32, 16];
    for round in 0..400 {
        let mode = MODES[round % MODES.len()];
        let n = 4 + rng.below(40) as usize;
        let mut f = Fn { insns: Vec::new(), targets: Vec::new(), unwind: Vec::new() };
        for _ in 0..n {
            let op = match rng.below(12) {
                0 => Opcode::DivUW32,
                _ => inline[rng.below(inline.len() as u64) as usize],
            };
            let mut w = insn(op, &mut rng, 0, &mut f, &mut |rng| rng.below(n as u64 + 1) as usize);
            // Slot operands from the pool (a memory operand's pointer slot too).
            let mut at = 1;
            for o in op.info().operands {
                if matches!(o.kind, OperandKind::Slot | OperandKind::Mem) {
                    w[at] = SLOTS[rng.below(SLOTS.len() as u64) as usize] as u32;
                }
                at += match o.kind {
                    OperandKind::Mem | OperandKind::U64 | OperandKind::I64 => 2,
                    _ => 1,
                };
            }
            f.insns.push(w);
        }
        f.insns.push(vec![Opcode::Abort as u32]);
        check(&f, 32, mode, "register cache");
    }
}

/// A reload of the value just stored is dropped, but not at a branch target.
#[test]
fn register_cache_drops_reloads() {
    let m = MODES[0];
    // mov.w64 $-16, $-8; mov.w64 $-24, $-16
    let mov = |d: i32, s: i32| vec![Opcode::MovW64 as u32, d as u32, s as u32];
    let reload = [0x48, 0x8b, 0x45, 0xf0]; // mov rax, [rbp - 16]
    let has = |code: &[u8]| code.windows(4).any(|w| w == reload);
    let f = Fn { insns: vec![mov(-16, -8), mov(-24, -16), vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
    assert!(!has(&check(&f, 32, m, "reload").code));
    // The same with a branch to the second `mov`.
    let f = Fn {
        insns: vec![mov(-16, -8), mov(-24, -16), vec![Opcode::Jmp as u32, 0]],
        targets: vec![(2, 1, 1)],
        unwind: Vec::new(),
    };
    assert!(has(&check(&f, 32, m, "reload at a target").code));
}

/// The register packing of the opcodes with more operands than registers.
#[test]
fn packed_operands() {
    let m = Mode { fp_arg: false, align_loops: false, pe: false };
    let l = asm::layout(Opcode::DiscrNicheW128, m);
    // d, s, niche_start (2), variants_start, variants_end | untagged << 32.
    assert_eq!(l.regs, 6);
    let ve = l.loc(Opcode::DiscrNicheW128, "variants_end");
    let un = l.loc(Opcode::DiscrNicheW128, "untagged");
    assert_eq!((ve.reg, ve.shift, un.reg, un.shift), (5, 0, 5, 32));
    let fp = Mode { fp_arg: true, ..m };
    let l = asm::layout(Opcode::DiscrNicheW128, fp);
    let d = l.loc(Opcode::DiscrNicheW128, "d");
    let s = l.loc(Opcode::DiscrNicheW128, "s");
    assert_eq!((l.first, l.regs, d.reg, s.reg, s.shift), (1, 6, 1, 1, 32));
    // Most opcodes need no packing.
    let l = asm::layout(Opcode::AddW32, m);
    assert_eq!((l.regs, l.loc(Opcode::AddW32, "b").reg), (3, 2));
    // `lpad` takes the exception object first.
    assert_eq!(asm::layout(Opcode::Lpad, m).loc(Opcode::Lpad, "x").reg, 1);
}

/// Machine code that isn't canonical is rejected.
#[test]
fn rejects_non_canonical_code() {
    let m = Mode { fp_arg: false, align_loops: false, pe: false };
    let f = Fn {
        // A shift by the width or more calls its handler.
        insns: vec![vec![Opcode::ShlImmW64 as u32, -8i32 as u32, -16i32 as u32, 70, 0], vec![Opcode::Ret as u32, -8i32 as u32, 8]],
        targets: Vec::new(),
        unwind: Vec::new(),
    };
    let enc = check(&f, 16, m, "shl.imm.w64");
    // `mov edx, 70` (ba 46 00 00 00) as `mov rdx, 70` (48 c7 c2 46 00 00 00): not shortest.
    let i = enc.code.windows(5).position(|w| w == [0xba, 70, 0, 0, 0]).unwrap();
    let mut code = enc.code.clone();
    code.splice(i..i + 5, [0x48, 0xc7, 0xc2, 70, 0, 0, 0]);
    let relocs: Vec<_> = enc.relocs.iter().map(|r| asm::Reloc { at: if r.at as usize > i { r.at + 2 } else { r.at }, ..*r }).collect();
    assert!(asm::decode(&code, &relocs, &enc.rodata, &enc.call_sites, m).is_err());
    // Operand registers out of order.
    let j = enc.code.windows(5).position(|w| w[0] == 0xbf).unwrap();
    let mut code = enc.code.clone();
    code[j] = 0xbe; // `mov esi` instead of `mov edi`
    assert!(asm::decode(&code, &enc.relocs, &enc.rodata, &enc.call_sites, m).is_err());
    // A call site that is no call.
    let mut sites = enc.call_sites.clone();
    sites.push(asm::CallSite { start: 4, len: 5, pad: None, catch: false });
    assert!(asm::decode(&enc.code, &enc.relocs, &enc.rodata, &sites, m).is_err());
}

/// The inline sequences with every displacement and immediate form: frame slots and memory
/// offsets of 0, 8 and 32 bits, immediates of every size class. The ones that are inlined
/// call no handler.
#[test]
fn inline_operand_forms() {
    const SLOTS: [i32; 8] = [-8, 16, -128, 127, -129, 128, 1 << 20, -(1 << 20)];
    const KS: [i32; 5] = [0, 1, -128, 300, -70000];
    let mut rng = Rng(0x1234);
    for &op in ALL_OPCODES {
        if !asm::has_inline(op) {
            continue;
        }
        for round in 0..24 {
            let mode = MODES[round % 8];
            // [abort], insn, abort, abort.
            let mut f = Fn { insns: vec![vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
            let mut w = vec![op as u32];
            for o in op.info().operands {
                let slot = SLOTS[rng.below(8) as usize] as u32;
                match o.kind {
                    OperandKind::Slot => w.push(slot),
                    OperandKind::Mem => w.extend([slot, KS[rng.below(5) as usize] as u32]),
                    OperandKind::U8 => w.push(if round % 3 == 0 { rng.below(10) } else { rng.imm() } as u8 as u32),
                    OperandKind::U16 => w.push(if round % 3 == 0 { rng.below(20) } else { rng.imm() } as u16 as u32),
                    OperandKind::U32 => w.push(if round % 3 == 0 { rng.below(40) } else { rng.imm() } as u32),
                    OperandKind::U64 | OperandKind::I64 => {
                        let v = if round % 3 == 0 { rng.below(70) } else { rng.imm() };
                        w.extend([v as u32, (v >> 32) as u32]);
                    }
                    OperandKind::Neg => w.push(rng.below(2) as u32),
                    OperandKind::Target => {
                        f.targets.push((1, w.len(), [0, 1, 2, 3][rng.below(4) as usize]));
                        w.push(0);
                    }
                    k => panic!("{}: operand kind {k:?}", op.mnemonic()),
                }
            }
            f.insns.push(w);
            f.insns.push(vec![Opcode::Abort as u32]);
            f.insns.push(vec![Opcode::Abort as u32]);
            let enc = check(&f, FRAMES[round % FRAMES.len()], mode, op.mnemonic());
            let small = !matches!(op, Opcode::PtrAdd | Opcode::PtrIndex) && !op.mnemonic().starts_with("sh");
            if small || (round % 3 == 0 && !op.mnemonic().starts_with("sh")) {
                assert!(!enc.relocs.iter().any(|r| r.to == asm::Ref::Handler(op)), "{} isn't inlined", op.mnemonic());
            }
        }
    }
}

/// A handler call of an instruction that has an inline form isn't canonical: `fadd.f32`'s
/// call (same operands as `add.w32`) retargeted to `add.w32`'s handler.
#[test]
fn rejects_handler_calls_of_inlined_ops() {
    let m = Mode { fp_arg: false, align_loops: false, pe: false };
    let f = Fn {
        insns: vec![vec![Opcode::FaddF32 as u32, -8i32 as u32, -16i32 as u32, 16], vec![Opcode::Abort as u32]],
        targets: Vec::new(),
        unwind: Vec::new(),
    };
    let enc = check(&f, 16, m, "fadd.f32");
    assert_eq!(asm::layout(Opcode::FaddF32, m).locs, asm::layout(Opcode::AddW32, m).locs);
    let relocs: Vec<_> = enc
        .relocs
        .iter()
        .map(|r| if r.to == asm::Ref::Handler(Opcode::FaddF32) { asm::Reloc { to: asm::Ref::Handler(Opcode::AddW32), ..*r } } else { *r })
        .collect();
    assert!(asm::decode(&enc.code, &relocs, &enc.rodata, &enc.call_sites, m).is_err());
}

/// Pins the canonical sequences: any change to how an opcode is encoded changes this hash.
/// When it fails, bump `FORMAT_VERSION` and update both values.
#[test]
fn templates_are_pinned_to_format_version() {
    let mut h: u64 = 0xcbf29ce484222325; // FNV-1a
    let mut eat = |b: &[u8]| {
        for &x in b {
            h = (h ^ x as u64).wrapping_mul(0x100000001b3);
        }
    };
    let mut rng = Rng(7);
    for &op in ALL_OPCODES {
        for mode in [MODES[0], MODES[1], MODES[6]] {
            let mut f = Fn { insns: vec![vec![Opcode::Lpad as u32, -8i32 as u32]], targets: Vec::new(), unwind: Vec::new() };
            let w = insn(op, &mut rng, 2, &mut f, &mut |_| 0);
            f.insns.push(w);
            f.insns.push(vec![Opcode::Abort as u32]);
            if op_may_unwind(op) {
                f.unwind.push((1, Some((0, false))));
            }
            let enc = check(&f, 4096, mode, op.mnemonic());
            eat(&enc.code);
            eat(&enc.rodata);
            for r in &enc.relocs {
                eat(format!("{:?}", r).as_bytes());
            }
            eat(&lsda::write(&enc.call_sites));
        }
    }
    assert_eq!((ryo_bytecode::FORMAT_VERSION, h), (10, 0x7d7935189c173d73), "template hash {h:#x}");
}
