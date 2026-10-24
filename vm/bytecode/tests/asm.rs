//! The machine-code encoder against its decoder: `decode(encode(f)) == f` for every opcode,
//! with the frame size and the unwind entries (through the LSDA), in every mode.

use ryo_bytecode::asm::{self, Mode, Scope, ScopeKind, lsda};
use ryo_bytecode::full::*;
use ryo_bytecode::image::{CATCH, CONTINUE, CleanupEntry, op_may_unwind};
use ryo_bytecode::reduced;

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

/// Every valid mode: the eight with a frame pointer, then the two without (which need
/// `fp_arg` and not `pe`); then the same ten with counters.
const MODES: [Mode; 20] = {
    let mut m = [Mode { fp_arg: false, frame_pointer: true, align_loops: false, pe: false, counters: false }; 20];
    let mut i = 0;
    while i < 8 {
        m[i] = Mode { fp_arg: i & 1 != 0, frame_pointer: true, align_loops: i & 2 != 0, pe: i & 4 != 0, counters: false };
        i += 1;
    }
    m[8] = Mode { fp_arg: true, frame_pointer: false, align_loops: false, pe: false, counters: false };
    m[9] = Mode { fp_arg: true, frame_pointer: false, align_loops: true, pe: false, counters: false };
    i = 10;
    while i < 20 {
        m[i] = Mode { counters: true, ..m[i - 10] };
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
            .map(|&(c, p)| CleanupEntry { offset: starts[c], target: p.map_or(CONTINUE, |(p, catch)| starts[p] | if catch { CATCH } else { 0 }) })
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
            OperandKind::Handler => unreachable!("not in the full set"),
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
    canonical_return(op, &mut w, rng, list_len);
    w
}

/// Makes a call's or `ret`'s return kind one the machine code can pass, an `arg`'s
/// register valid, and a call's argument list one of `n` valid entries ([`asm::return_ok`]).
fn canonical_return(op: Opcode, w: &mut Vec<u32>, rng: &mut Rng, n: usize) {
    if op == Opcode::Arg {
        let xmm = rng.below(2) == 0;
        let size = if xmm { [2, 4, 8, 16][rng.below(4) as usize] } else { 1 + rng.below(8) as u32 };
        w[operand_word(op, "r")] = asm::ArgReg { xmm, size, index: rng.below(4) as u32 }.word();
        return;
    }
    let call = matches!(op, Opcode::Call | Opcode::CallSym | Opcode::CallSymInd | Opcode::CallPtr);
    if call || matches!(op, Opcode::TailCall | Opcode::TailCallPtr) {
        // The argument list: `n` distinct registers.
        let a = operand_word(op, "a");
        w.truncate(a);
        w.push(2 * n as u32);
        let mut regs: Vec<(bool, u32)> = (0..4).flat_map(|i| [(false, i), (true, i)]).collect();
        for _ in 0..n {
            let (xmm, index) = regs.remove(rng.below(regs.len() as u64) as usize);
            let size = if xmm { [2, 4, 8, 16][rng.below(4) as usize] } else { [1, 2, 4, 8][rng.below(4) as usize] };
            let addr = !xmm && rng.below(3) == 0;
            let r = asm::ArgReg { xmm, size: if addr { 8 } else { size }, index }.word();
            w.extend([rng.next() as u32, if addr { r | asm::ARG_ADDR } else { r }]);
        }
    }
    if call {
        let k = random_kind(rng, false);
        w[operand_word(op, "k")] = k;
        if k == 0 {
            w[operand_word(op, "d")] = 0;
        }
    } else if op == Opcode::Ret {
        let k = random_kind(rng, true);
        w[operand_word(op, "k")] = k;
        if k == 0 {
            w[operand_word(op, "s")] = 0;
        }
    }
    assert!(asm::return_ok(w), "{}", op.mnemonic());
}

/// A random return kind ([`asm::RET_SRET`]): exact sizes for a call, load widths for `ret`.
fn random_kind(rng: &mut Rng, load: bool) -> u32 {
    let part = |rng: &mut Rng, off: u32| {
        let xmm = rng.below(2) == 0;
        let size = match (xmm, load) {
            (true, _) => [2, 4, 8, 16][rng.below(4) as usize],
            (false, true) => [1, 2, 4, 8][rng.below(4) as usize],
            (false, false) => 1 + rng.below(8) as u32,
        };
        asm::RetPart { xmm, size, off }
    };
    match rng.below(3) {
        0 => 0,
        1 => asm::ret_kind(&[part(rng, 0)]),
        _ => {
            let a = part(rng, 0);
            let mut b = part(rng, 0);
            if a.size + b.size > 16 {
                return asm::ret_kind(&[a]);
            }
            b.off = a.size + rng.below((16 - a.size - b.size + 1) as u64) as u32;
            asm::ret_kind(&[a, b])
        }
    }
}

/// A few escapes, storage ends and island operands of small overlapping objects, at instruction starts and the
/// end of `code`, sorted, from a seed of the code.
fn random_scopes(code: &[u32]) -> Vec<Scope> {
    let mut rng = Rng(code.iter().fold(0x2545f4914f6cdd1d, |h, &w| (h ^ w as u64).wrapping_mul(0x100000001b3)) | 1);
    let mut starts: Vec<u32> = Decoder::new(code).map(|r| r.unwrap().0 as u32).collect();
    starts.push(code.len() as u32);
    let mut out: Vec<Scope> = (0..rng.below(5))
        .map(|_| {
            let align = 1 << rng.below(5);
            let kind = match rng.below(3) {
                0 => ScopeKind::Escape { align },
                1 => ScopeKind::End,
                _ => ScopeKind::Lend,
            };
            Scope {
                code_offset: starts[rng.below(starts.len() as u64) as usize],
                frame_offset: -(align as i32) * (1 + rng.below(4) as i32),
                size: 1 + rng.below(32) as u32,
                kind,
            }
        })
        .collect();
    out.sort_by_key(|s| s.code_offset);
    out
}

fn check(f: &Fn, frame_size: u32, mode: Mode, what: &str) -> asm::Encoded {
    // PE frames keep `rdi` and `rsi` in their top 16 bytes.
    let frame_size = if mode.pe { frame_size.max(16) } else { frame_size };
    let (code, mut cleanup) = f.words();
    let scopes = random_scopes(&code);
    let enc = asm::encode(&code, frame_size, &cleanup, &scopes, mode).unwrap_or_else(|e| panic!("{what}: {e:?}\n{}", Disasm(&code)));
    // Scopes are side data: the code is the same without them.
    let plain = asm::encode(&code, frame_size, &cleanup, &[], mode).expect("encodes");
    assert_eq!((&plain.code, &plain.dropped), (&enc.code, &enc.dropped), "{what}: scopes changed the code");
    let sites = lsda::parse(&lsda::write(&enc.call_sites)).expect("LSDA");
    assert_eq!(sites, enc.call_sites, "{what}");
    let dec = asm::decode(&enc.code, &enc.relocs, &enc.rodata, &sites, &enc.dropped, &enc.scopes, mode)
        .unwrap_or_else(|e| panic!("{what} {mode:?}: {e:?}\n{}\n{:02x?}", Disasm(&code), enc.code));
    if dec.words != code {
        panic!("{what} {mode:?}:\n{}\n---\n{}", Disasm(&code), Disasm(&dec.words));
    }
    assert_eq!(dec.frame_size, frame_size, "{what}");
    cleanup.sort();
    assert_eq!(dec.cleanup, cleanup, "{what}");
    // The scopes come back, but for the storage ends that overlap no escape.
    let escapes: Vec<_> = scopes.iter().filter(|s| matches!(s.kind, ScopeKind::Escape { .. })).collect();
    let overlap = |a: &Scope, b: &Scope| a.frame_offset < b.frame_offset + b.size as i32 && b.frame_offset < a.frame_offset + a.size as i32;
    let kept: Vec<Scope> = scopes.iter().copied().filter(|s| s.kind != ScopeKind::End || escapes.iter().any(|e| overlap(s, e))).collect();
    assert_eq!(dec.scopes, kept, "{what} {mode:?}");
    // The reduced decoder reads the same function as the full one, reduced.
    let red = asm::decode_reduced(&enc.code, &enc.relocs, &enc.rodata, &sites, &enc.dropped, &enc.scopes, mode)
        .unwrap_or_else(|e| panic!("{what} {mode:?} (reduced): {e:?}\n{}", Disasm(&code)));
    let want = asm::reduce(&dec.words, dec.frame_size, &dec.cleanup, &dec.scopes, &dec.dropped, mode).expect("reduces");
    for r in reduced::Decoder::new(&red.words) {
        r.unwrap_or_else(|e| panic!("{what} {mode:?} (reduced words): {e}"));
    }
    if red != want {
        panic!("{what} {mode:?} (reduced):\n{}\n---\n{}", reduced::Disasm(&want.words), reduced::Disasm(&red.words));
    }
    // The same from the linked code, its references recovered from the resolved fields.
    let linked = Fake::link(&enc);
    let lin = asm::decode_linked(
        &linked,
        Fake::CODE,
        mode.counters.then_some(Fake::RECORD),
        &Fake { ro: &enc.rodata },
        &sites,
        &enc.dropped,
        &enc.scopes,
        mode,
    )
    .unwrap_or_else(|e| panic!("{what} {mode:?} (linked): {e:?}\n{}", Disasm(&code)));
    if lin != red {
        panic!("{what} {mode:?} (linked):\n{}\n---\n{}", reduced::Disasm(&red.words), reduced::Disasm(&lin.words));
    }
    // With counters: a check at the entry and at each loop head, each with its stub after
    // the code, the entry's last.
    let ctrs = enc.relocs.iter().filter(|r| r.to == asm::Ref::RecCtr).count();
    let recs = enc.relocs.iter().filter(|r| r.to == asm::Ref::Rec).count();
    if mode.counters {
        assert_eq!((ctrs, recs), (red.heads.len() + 1, red.heads.len() + 1), "{what} {mode:?}");
        assert_eq!(enc.code[..3], [0x48, 0x83, 0x2d], "{what}");
        assert_eq!(enc.code[enc.entry_stub as usize..][..3], [0x4c, 0x8d, 0x1d], "{what}");
        // `lea r11`, `call [r11 + 8]`, `jmp` back (`rel8` or `rel32`).
        assert!(matches!(enc.code.len() as u32 - enc.entry_stub, 13 | 16), "{what}");
    } else {
        assert_eq!((ctrs, recs, enc.prologue, enc.entry_stub as usize), (0, 0, 0, enc.code.len()), "{what}");
    }
    assert_eq!(dec.heads.len(), red.heads.len(), "{what}");
    reencodes(&enc, mode, what);
    enc
}

/// `encode_reduced` of what `decode_reduced` and `decode_linked` read from `enc` gives `enc`
/// back exactly: code, relocations, code constants, call sites, dropped stores and scopes.
fn reencodes(enc: &asm::Encoded, mode: Mode, what: &str) {
    let red = asm::decode_reduced(&enc.code, &enc.relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, mode)
        .unwrap_or_else(|e| panic!("{what} {mode:?} (reduced): {e:?}"));
    let linked = Fake::link(enc);
    let lin = asm::decode_linked(
        &linked,
        Fake::CODE,
        mode.counters.then_some(Fake::RECORD),
        &Fake { ro: &enc.rodata },
        &enc.call_sites,
        &enc.dropped,
        &enc.scopes,
        mode,
    )
    .unwrap_or_else(|e| panic!("{what} {mode:?} (linked): {e:?}"));
    shuffles(&red, &enc.rodata, mode, what);
    for (d, how) in [(&red, "reduced"), (&lin, "linked")] {
        let re = asm::encode_reduced(&d.words, d.frame_size, &d.cleanup, &d.scopes, &d.dropped, &enc.rodata, mode)
            .unwrap_or_else(|e| panic!("{what} {mode:?} (re-encoding {how}): {e:?}\n{}", reduced::Disasm(&d.words)));
        if re != *enc {
            panic!(
                "{what} {mode:?} (re-encoding {how}):\n{}\n{:02x?}\n---\n{:02x?}\n{enc:?}\n---\n{re:?}",
                reduced::Disasm(&d.words),
                enc.code,
                re.code
            );
        }
    }
}

/// The JIT's frame renaming (`asm::frame`) on decoded code `d`: the identity changes nothing,
/// the liveness pass runs, and the shuffled layout's code (`RYO_JIT_SHUFFLE`) encodes and
/// decodes back to the renamed words, in the new frame size.
fn shuffles(d: &asm::Decoded, rodata: &[u8], mode: Mode, what: &str) {
    use asm::frame;
    let id = frame::remap_slots(&d.words, mode, &frame::SlotMap::identity(d.frame_size)).unwrap_or_else(|e| panic!("{what} {mode:?}: {e:?}"));
    assert_eq!(id, d.words, "{what} {mode:?}");
    let live = frame::head_liveness(d, mode).unwrap_or_else(|e| panic!("{what} {mode:?}: {e:?}"));
    assert_eq!(live.len(), d.heads.len());
    let Ok(map) = frame::shuffle_map(d, mode) else { return };
    let words = frame::remap_slots(&d.words, mode, &map).unwrap();
    let scopes: Vec<asm::Scope> =
        d.scopes.iter().filter_map(|sc| Some(asm::Scope { frame_offset: map.map_range(sc.frame_offset, sc.size)?, ..*sc })).collect();
    let (enc, _) = asm::encode_reduced_at(&words, map.frame_size, &d.cleanup, &scopes, &d.dropped, rodata, mode)
        .unwrap_or_else(|e| panic!("{what} {mode:?} (shuffled): {e:?}\n{}", reduced::Disasm(&words)));
    let back = asm::decode_reduced(&enc.code, &enc.relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, mode)
        .unwrap_or_else(|e| panic!("{what} {mode:?} (shuffled, decoding): {e:?}"));
    assert_eq!((back.frame_size, &back.words), (map.frame_size, &words), "{what} {mode:?} (shuffled)\n{}", reduced::Disasm(&words));
}

/// A fake address space for linking a function's code: the code at [`Fake::CODE`], and each
/// kind of reference in a range of its own below it, within `rel32` reach.
struct Fake<'a> {
    ro: &'a [u8],
}

impl Fake<'_> {
    const CODE: u64 = 0x4000_0000;
    const PROBE: u64 = 0x0f00_0000;
    const HANDLERS: u64 = 0x1000_0000;
    const FUNCS: u64 = 0x2000_0000;
    const SYMS: u64 = 0x3000_0000;
    const SITES: u64 = 0x3100_0000;
    const CONSTS: u64 = 0x3200_0000;
    const DATA: u64 = 0x3300_0000;
    const RO: u64 = 0x3400_0000;
    const RECORD: u64 = 0x3500_0000;

    fn addr(to: asm::Ref) -> u64 {
        use asm::Ref;
        match to {
            Ref::Handler(op) => Self::HANDLERS + 16 * op as u64,
            Ref::Probe => Self::PROBE,
            Ref::Func(f) => Self::FUNCS + 16 * f.0 as u64,
            Ref::Sym(s) => Self::SYMS + 8 * s.0 as u64,
            Ref::Site(s) => Self::SITES + 8 * s.0 as u64,
            Ref::Const(k) => Self::CONSTS + k.0 as u64,
            Ref::Data(d) => Self::DATA + d.0 as u64,
            Ref::Ro(o) => Self::RO + o as u64,
            Ref::Rec => Self::RECORD,
            Ref::RecCtr => Self::RECORD - 1,
        }
    }

    /// The code with its relocations applied, at [`Fake::CODE`].
    fn link(enc: &asm::Encoded) -> Vec<u8> {
        let mut code = enc.code.clone();
        for r in &enc.relocs {
            let end = Self::CODE + r.at as u64 + 4;
            let d = i32::try_from(Self::addr(r.to) as i64 - end as i64).expect("in reach");
            code[r.at as usize..][..4].copy_from_slice(&d.to_le_bytes());
        }
        code
    }
}

impl asm::Resolver for Fake<'_> {
    fn resolve(&self, a: u64) -> Option<asm::Ref> {
        use asm::Ref;
        let r = match a {
            Self::PROBE => Ref::Probe,
            _ if (Self::HANDLERS..Self::FUNCS).contains(&a) => Ref::Handler(Opcode::from_u16(((a - Self::HANDLERS) / 16) as u16)?),
            _ if (Self::FUNCS..Self::SYMS).contains(&a) => Ref::Func(Func(((a - Self::FUNCS) / 16) as u32)),
            _ if (Self::SYMS..Self::SITES).contains(&a) => Ref::Sym(Sym(((a - Self::SYMS) / 8) as u32)),
            _ if (Self::SITES..Self::CONSTS).contains(&a) => Ref::Site(Site(((a - Self::SITES) / 8) as u32)),
            _ if (Self::CONSTS..Self::DATA).contains(&a) => Ref::Const(Const((a - Self::CONSTS) as u32)),
            _ if (Self::DATA..Self::RO).contains(&a) => Ref::Data(Data((a - Self::DATA) as u32)),
            _ if (Self::RO..Self::RECORD - 1).contains(&a) => Ref::Ro((a - Self::RO) as u32),
            _ => return None,
        };
        // Only what `addr` gives: a misread field must not resolve by accident.
        (Self::addr(r) == a).then_some(r)
    }

    fn code_consts(&self) -> &[u8] {
        self.ro
    }
}

const FRAMES: [u32; 6] = [0, 16, 112, 128, 4096, 1 << 20];

#[test]
fn every_opcode_round_trips() {
    let mut rng = Rng(0x9e3779b97f4a7c15);
    for &op in ALL_OPCODES {
        for (round, mode) in MODES[..10].iter().enumerate() {
            for list_len in [0, 1, 3] {
                // With and without counters, alternately (every mode gets both).
                let mode = &Mode { counters: (op as usize + round + list_len) % 2 == 0, ..*mode };
                // [abort], insn, filler…, lpad, jmp 0, abort.
                let mut f = Fn { insns: vec![vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
                let fillers = [0, 2, 40][(round + list_len) % 3];
                let last = 2 + fillers + 2;
                let mut target = |rng: &mut Rng| [0, 1, last, 2 + fillers][rng.below(4) as usize];
                let w = insn(op, &mut rng, list_len, &mut f, &mut target);
                if op == Opcode::Arg {
                    // `arg`s come first.
                    f.insns[0] = w;
                } else {
                    f.insns.push(w);
                }
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
            // Instructions 0 and 1 are the loop heads, in order.
            let d = asm::decode(&enc.code, &enc.relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, mode).unwrap();
            assert_eq!(d.heads, [0, 4], "{mode:?}");
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
    let f = Fn { insns: vec![mov(-16, -8), mov(-24, -16), vec![Opcode::Jmp as u32, 0]], targets: vec![(2, 1, 1)], unwind: Vec::new() };
    assert!(has(&check(&f, 32, m, "reload at a target").code));
    // Values stay in other registers: `mov.w64 $-24, $-32` goes through `rdx`, as `rax`
    // holds `$-16`, so the last `add` is `add rax, rdx`.
    let add = |d: i32, a: i32, b: i32| vec![Opcode::AddW64 as u32, d as u32, a as u32, b as u32];
    let f =
        Fn { insns: vec![add(-16, -8, -8), mov(-24, -32), add(-40, -16, -24), vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
    let code = check(&f, 64, m, "two registers").code;
    assert!(code.windows(3).any(|w| w == [0x48, 0x03, 0xc2]), "{code:02x?}");
}

/// `mov.w128`, inline as two 64-bit moves, decodes apart from two `mov.w64` of its
/// halves, in either order, and from itself on overlapping slots.
#[test]
fn mov_w128_is_not_two_mov_w64() {
    let mov = |op: Opcode, d: i32, s: i32| vec![op as u32, d as u32, s as u32];
    let (m64, m128) = (Opcode::MovW64, Opcode::MovW128);
    let runs = [
        vec![mov(m64, -32, -16), mov(m64, -24, -8)],
        vec![mov(m64, -24, -8), mov(m64, -32, -16)],
        vec![mov(m128, -32, -16), mov(m64, -16, -40)],
        vec![mov(m128, -24, -32), mov(m128, -40, -24)],
    ];
    for mode in [MODES[0], MODES[1]] {
        for insns in &runs {
            let mut insns = insns.clone();
            insns.push(vec![Opcode::Abort as u32]);
            let f = Fn { insns, targets: Vec::new(), unwind: Vec::new() };
            check(&f, 48, mode, "mov.w128");
        }
    }
}

/// A label at a dead-slot hint (no code), right before a padded loop head, is the loop
/// head's position, after the padding, and so is a scope there.
#[test]
fn label_at_a_dead_hint_before_a_loop_head() {
    for counters in [false, true] {
        label_at_a_dead_hint(Mode { fp_arg: false, frame_pointer: true, align_loops: true, pe: false, counters });
    }
}

fn label_at_a_dead_hint(mode: Mode) {
    use asm::Opnd::{Imm, Neg, Slot, Target};
    let mut a = asm::Asm::new(mode);
    let (empty, head) = (a.label(), a.label());
    a.insn(Opcode::BrEqImmW64, &[Slot(-8), Imm(0), Neg(false), Target(empty)]);
    a.insn(Opcode::MovW64, &[Slot(-16), Slot(-8)]);
    a.bind(empty);
    a.dead(-16i32 as u32, 8);
    // A scope there too: it takes effect at the loop head, after the padding.
    a.escape(-16i32 as u32, 8, 8);
    a.bind(head);
    a.insn(Opcode::AddImmW64, &[Slot(-8), Slot(-8), Imm(1)]);
    a.insn(Opcode::Jmp, &[Target(head)]);
    let enc = a.finish(16, |s| s);
    asm::decode(&enc.code, &enc.relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, mode).expect("decodes");
    assert_eq!(enc.scopes[0].code_offset % 16, 0, "{:?}", enc.scopes);
    if mode.counters {
        // Before the head's counter check, which the branches to the head pass.
        assert_eq!(enc.code[enc.scopes[0].code_offset as usize..][..3], [0x48, 0x83, 0x2d]);
    }
    reencodes(&enc, mode, "dead hint before a loop head");
}

/// Random runs of inline instructions on a few overlapping slots, with branches into them,
/// handler calls, escapes and dead-slot hints (`Asm::dead`), built with `Asm` directly, so the
/// encoder drops stores the code doesn't show: they re-encode exactly.
#[test]
fn dead_stores_reencode() {
    use asm::Opnd;
    let mut rng = Rng(0xd1ed);
    let inline: Vec<Opcode> = ALL_OPCODES.iter().copied().filter(|&op| asm::has_inline(op)).collect();
    const SLOTS: [i32; 6] = [-8, -16, -24, -12, -32, 16];
    let mut dropped = 0;
    for round in 0..2000 {
        let mode = MODES[round % MODES.len()];
        let n = 4 + rng.below(30) as usize;
        let mut a = asm::Asm::new(mode);
        let labels: Vec<asm::Label> = (0..=n).map(|_| a.label()).collect();
        for (i, &l) in labels.iter().enumerate().take(n) {
            a.bind(l);
            let op = match rng.below(16) {
                0 => Opcode::DivUW32,
                1 => Opcode::Jmp,
                _ => inline[rng.below(inline.len() as u64) as usize],
            };
            let mut words = vec![op as u32];
            for o in op.info().operands {
                match o.kind {
                    OperandKind::Slot => words.push(SLOTS[rng.below(SLOTS.len() as u64) as usize] as u32),
                    OperandKind::Mem => words.extend([SLOTS[rng.below(SLOTS.len() as u64) as usize] as u32, rng.below(64) as u32]),
                    OperandKind::U8 => words.push(rng.below(8) as u32),
                    OperandKind::U16 | OperandKind::U32 => words.push(rng.below(1 << 16) as u32),
                    OperandKind::U64 | OperandKind::I64 => {
                        let v = rng.imm();
                        words.extend([v as u32, (v >> 32) as u32]);
                    }
                    OperandKind::Neg => words.push(rng.below(2) as u32),
                    OperandKind::Target => words.push(0),
                    k => panic!("{}: {k:?}", op.mnemonic()),
                }
            }
            let ops: Vec<Opnd<asm::Label>> = asm::operands(&words, 0)
                .into_iter()
                .map(|o| o.map_targets(|_| Ok::<_, ()>(labels[rng.below(n as u64 + 1) as usize])).unwrap())
                .collect();
            if rng.below(8) == 0 {
                a.escape(SLOTS[rng.below(SLOTS.len() as u64) as usize] as u32, 8, 8);
            }
            a.insn(op, &ops);
            for _ in 0..rng.below(3) {
                let lo = SLOTS[rng.below(SLOTS.len() as u64) as usize];
                a.dead(lo as u32, [4, 8, 16, 24][rng.below(4) as usize]);
            }
            if i == n - 1 || rng.below(10) == 0 {
                a.insn(Opcode::Abort, &[]);
            }
        }
        a.bind(labels[n]);
        a.insn(Opcode::Abort, &[]);
        let enc = a.finish(48, |s| s);
        dropped += enc.dropped.len();
        reencodes(&enc, mode, "dead stores");
    }
    assert!(dropped > 500, "{dropped} stores dropped");
}

/// The register packing of the opcodes with more operands than registers.
#[test]
fn packed_operands() {
    let m = Mode { fp_arg: false, frame_pointer: true, align_loops: false, pe: false, counters: false };
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

/// In linked code, a field whose target the resolver doesn't know is rejected.
#[test]
fn linked_fields_must_resolve() {
    let m = MODES[0];
    let f = Fn {
        insns: vec![vec![Opcode::DivUW32 as u32, -8i32 as u32, -8i32 as u32, -16i32 as u32], vec![Opcode::Jmp as u32, 0]],
        targets: vec![(1, 1, 0)],
        unwind: Vec::new(),
    };
    let enc = check(&f, 16, m, "div; jmp");
    let decode = |code: &[u8]| {
        asm::decode_linked(
            code,
            Fake::CODE,
            m.counters.then_some(Fake::RECORD),
            &Fake { ro: &enc.rodata },
            &enc.call_sites,
            &enc.dropped,
            &enc.scopes,
            m,
        )
    };
    let linked = Fake::link(&enc);
    assert!(decode(&linked).is_ok());
    // The handler call one byte off.
    let at = enc.relocs[0].at as usize;
    let mut code = linked.clone();
    code[at] = code[at].wrapping_add(1);
    assert!(decode(&code).is_err());
}

/// Machine code that isn't canonical is rejected.
#[test]
fn rejects_non_canonical_code() {
    let m = Mode { fp_arg: false, frame_pointer: true, align_loops: false, pe: false, counters: false };
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
    assert!(asm::decode(&code, &relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, m).is_err());
    // Operand registers out of order.
    let j = enc.code.windows(5).position(|w| w[0] == 0xbf).unwrap();
    let mut code = enc.code.clone();
    code[j] = 0xbe; // `mov esi` instead of `mov edi`
    assert!(asm::decode(&code, &enc.relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, m).is_err());
    // A call site that is no call.
    let mut sites = enc.call_sites.clone();
    sites.push(asm::CallSite { start: 4, len: 5, pad: None, catch: false });
    assert!(asm::decode(&enc.code, &enc.relocs, &enc.rodata, &sites, &enc.dropped, &enc.scopes, m).is_err());
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
        for round in 0..30 {
            let mode = MODES[round % MODES.len()];
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
    let m = Mode { fp_arg: false, frame_pointer: true, align_loops: false, pe: false, counters: false };
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
    assert!(asm::decode(&enc.code, &relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, m).is_err());
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
        for mode in [MODES[0], MODES[1], MODES[6], MODES[8], MODES[10], MODES[11], MODES[16], MODES[18]] {
            let mut f = Fn { insns: vec![vec![Opcode::Lpad as u32, -8i32 as u32]], targets: Vec::new(), unwind: Vec::new() };
            let w = insn(op, &mut rng, 2, &mut f, &mut |_| 0);
            if op == Opcode::Arg {
                f.insns.insert(0, w);
            } else {
                f.insns.push(w);
            }
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
    assert_eq!((ryo_bytecode::FORMAT_VERSION, h), (22, 0x5790b2aa31eb135e), "template hash {h:#x}");
}

/// Without a frame pointer, an SSE load or store of the slot at `rsp` has no displacement.
#[test]
fn sse_at_rsp() {
    let k = asm::ret_kind(&[asm::RetPart { xmm: true, size: 8, off: 0 }]);
    for mode in [MODES[8], MODES[9]] {
        let f = Fn { insns: vec![vec![Opcode::Ret as u32, -16i32 as u32, k]], targets: Vec::new(), unwind: Vec::new() };
        check(&f, 16, mode, "sse at rsp");
    }
}

/// Fields that made the decoders overflow (a panic in a debug build): each a mutation of a
/// function that decodes, which every decoder must reject. (The Lean vectors have them too.)
#[test]
fn rejects_overflowing_fields() {
    let find = |code: &[u8], pat: &[u8]| code.windows(pat.len()).position(|w| w == pat).expect("pattern");
    let rejects = |enc: &asm::Encoded, mode: Mode, at: usize, bytes: &[u8], what: &str| {
        let mut code = enc.code.clone();
        code[at..][..bytes.len()].copy_from_slice(bytes);
        let mut linked = Fake::link(enc);
        linked[at..][..bytes.len()].copy_from_slice(bytes);
        let (sites, d, sc) = (&enc.call_sites, &enc.dropped, &enc.scopes);
        assert!(asm::decode(&code, &enc.relocs, &enc.rodata, sites, d, sc, mode).is_err(), "{what}");
        assert!(asm::decode_reduced(&code, &enc.relocs, &enc.rodata, sites, d, sc, mode).is_err(), "{what} (reduced)");
        let rec = mode.counters.then_some(Fake::RECORD);
        assert!(asm::decode_linked(&linked, Fake::CODE, rec, &Fake { ro: &enc.rodata }, sites, d, sc, mode).is_err(), "{what} (linked)");
    };
    // PE: `sub rsp, 0xfffffff0`, whose frame size `alloc + 16` doesn't fit in 32 bits.
    let mode = MODES[4];
    let f = Fn { insns: vec![vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
    let enc = check(&f, 1 << 20, mode, "abort");
    rejects(&enc, mode, find(&enc.code, &[0x48, 0x81, 0xec]) + 3, &[0xf0, 0xff, 0xff, 0xff], "sub rsp");
    // `mov.w128` from `[rbp + i32::MAX - 3]`: its high half would be 8 bytes up.
    let mode = MODES[0];
    let s: i32 = -(1 << 20) + 64;
    let f = Fn {
        insns: vec![vec![Opcode::MovW128 as u32, -(1i32 << 20) as u32, s as u32], vec![Opcode::Abort as u32]],
        targets: Vec::new(),
        unwind: Vec::new(),
    };
    let enc = check(&f, 32, mode, "mov.w128");
    rejects(&enc, mode, find(&enc.code, &s.to_le_bytes()), &0x7fff_fffcu32.to_le_bytes(), "mov.w128");
    // A call's 7-byte result stored in pieces, the second moved below the first: its offset
    // from the first wraps.
    let k = asm::ret_kind(&[asm::RetPart { xmm: false, size: 7, off: 0 }]);
    let f =
        Fn { insns: vec![vec![Opcode::Call as u32, -16i32 as u32, 0, k, 0], vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
    let enc = check(&f, 32, mode, "call");
    rejects(&enc, mode, find(&enc.code, &[0x66, 0x89, 0x45, 0xf4]) + 3, &[0xee], "result piece");
}

/// The decoders never panic (a debug build checks for overflows) on mutations of every
/// opcode's encoding, in every mode: fields set to values at the edges of their ranges, bytes
/// changed, the code cut short, the code constants changed.
#[test]
fn decoders_survive_mutations() {
    const EDGES: [u32; 10] = [0, 1, 8, 0x7fff_fff8, 0x7fff_fffc, 0x7fff_ffff, 0x8000_0000, 0x8000_0004, 0xffff_fff0, 0xffff_ffff];
    let mut rng = Rng(0x0dec_0de5_0f_f00d);
    for (k, &op) in ALL_OPCODES.iter().enumerate() {
        let mode = MODES[k % MODES.len()];
        let list_len = [0, 1, 3][k / MODES.len() % 3];
        let mut f = Fn { insns: vec![vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
        let w = insn(op, &mut rng, list_len, &mut f, &mut |rng| rng.below(3) as usize);
        if op == Opcode::Arg {
            f.insns[0] = w;
        } else {
            f.insns.push(w);
        }
        f.insns.push(vec![Opcode::Abort as u32]);
        let frame_size = FRAMES[k % FRAMES.len()];
        let frame_size = if mode.pe { frame_size.max(16) } else { frame_size };
        let (code, cleanup) = f.words();
        let Ok(enc) = asm::encode(&code, frame_size, &cleanup, &random_scopes(&code), mode) else { continue };
        let linked = Fake::link(&enc);
        for _ in 0..200 {
            let (mut code, mut lcode, mut ro) = (enc.code.clone(), linked.clone(), enc.rodata.clone());
            match rng.below(4) {
                0 if code.len() >= 4 => {
                    let at = rng.below(code.len() as u64 - 3) as usize;
                    let v = EDGES[rng.below(EDGES.len() as u64) as usize].wrapping_sub(rng.below(3) as u32).to_le_bytes();
                    code[at..][..4].copy_from_slice(&v);
                    lcode[at..][..4].copy_from_slice(&v);
                }
                1 if !code.is_empty() => {
                    let at = rng.below(code.len() as u64) as usize;
                    let v = [0x7f, 0x80, 0xff, rng.next() as u8][rng.below(4) as usize];
                    (code[at], lcode[at]) = (v, v);
                }
                2 if ro.len() >= 4 => {
                    let at = rng.below(ro.len() as u64 - 3) as usize;
                    ro[at..][..4].copy_from_slice(&EDGES[rng.below(EDGES.len() as u64) as usize].to_le_bytes());
                }
                _ => {
                    let n = rng.below(code.len() as u64 + 1) as usize;
                    code.truncate(n);
                    lcode.truncate(n);
                }
            }
            let (sites, d, sc) = (&enc.call_sites, &enc.dropped, &enc.scopes);
            let _ = asm::decode(&code, &enc.relocs, &ro, sites, d, sc, mode);
            let _ = asm::decode_reduced(&code, &enc.relocs, &ro, sites, d, sc, mode);
            let _ = asm::decode_linked(&lcode, Fake::CODE, mode.counters.then_some(Fake::RECORD), &Fake { ro: &ro }, sites, d, sc, mode);
        }
    }
}
