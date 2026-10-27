//! Test vectors for the Lean reduced decoder (`lean/Ryo/Vm/DecodeReduced.lean`): functions
//! encoded with `asm::encode` and `asm::Asm` in every valid mode (the generators of `asm.rs`:
//! every opcode, long branches and loops, the register cache, dropped stores, inline operand
//! forms, `mov.w128`, a dead hint before a loop head, SSE at `rsp`, island operand scopes, and
//! shuffled frames re-encoded with `encode_reduced_at`), each with its decoder inputs and the
//! text of what `asm::decode_reduced` makes of it; and mutations of them (bytes changed, the
//! code cut short, call sites and dropped stores changed) with Rust's verdict. Written as
//! `lean/RyoTest/DecodeReducedVectors.lean`, which the Lean tests check `decodeReduced` against,
//! text for text. With `RYO_LEAN_GEN=1` the test rewrites that file, else it checks it is up to
//! date.
//!
//! The text (`text`): `frame <F>`, the code as `reduced::Disasm` prints it, then `cleanup`,
//! `scope`, `dropped` and `heads` lines (word offsets), or `error at <byte>: <what>`. The
//! decoder must not panic on any of them (a debug build checks for overflows).

use std::fmt::Write as _;
use std::panic::{AssertUnwindSafe, catch_unwind};

use ryo_bytecode::asm::{self, Mode, Ref, Scope, ScopeKind};
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

/// Every valid mode (as in `asm.rs`): the eight with a frame pointer, the two without, then
/// the same ten with counters.
const MODES: [Mode; 20] = {
    let mut m = [Mode { fp_arg: false, frame_pointer: true, align_loops: false, pe: false, counters: false, far_rt: false }; 20];
    let mut i = 0;
    while i < 8 {
        // PE has no `fp_arg` (Win64 handlers read `fp` from `rbp`).
        m[i] =
            Mode { fp_arg: i & 1 != 0 && i & 4 == 0, frame_pointer: true, align_loops: i & 2 != 0, pe: i & 4 != 0, counters: false, far_rt: false };
        i += 1;
    }
    m[8] = Mode { fp_arg: true, frame_pointer: false, align_loops: false, pe: false, counters: false, far_rt: false };
    m[9] = Mode { fp_arg: true, frame_pointer: false, align_loops: true, pe: false, counters: false, far_rt: false };
    i = 10;
    while i < 20 {
        m[i] = Mode { counters: true, ..m[i - 10] };
        i += 1;
    }
    m
};

const FRAMES: [u32; 6] = [0, 16, 112, 128, 4096, 1 << 20];

/// A function built from instructions whose targets are instruction indices (`asm.rs`).
struct Fn {
    insns: Vec<Vec<u32>>,
    targets: Vec<(usize, usize, usize)>,
    unwind: Vec<(usize, Option<(usize, bool)>)>,
}

impl Fn {
    fn new() -> Fn {
        Fn { insns: Vec::new(), targets: Vec::new(), unwind: Vec::new() }
    }

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

fn canonical_return(op: Opcode, w: &mut Vec<u32>, rng: &mut Rng, n: usize) {
    if op == Opcode::Arg {
        let xmm = rng.below(2) == 0;
        let size = if xmm { [2, 4, 8, 16][rng.below(4) as usize] } else { 1 + rng.below(8) as u32 };
        w[operand_word(op, "r")] = asm::ArgReg { xmm, size, index: rng.below(4) as u32 }.word();
        return;
    }
    let call = matches!(op, Opcode::Call | Opcode::CallSym | Opcode::CallSymInd | Opcode::CallPtr);
    if call || matches!(op, Opcode::TailCall | Opcode::TailCallPtr) {
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

fn random_scopes(code: &[u32]) -> Vec<Scope> {
    let mut rng = Rng(code.iter().fold(0x2545f4914f6cdd1d, |h, &w| (h ^ w as u64).wrapping_mul(0x100000001b3)) | 1);
    let mut starts: Vec<u32> = Decoder::new(code).map(|r| r.unwrap().0 as u32).collect();
    starts.push(code.len() as u32);
    let mut out: Vec<Scope> = (0..rng.below(5))
        .map(|_| {
            let align = 1 << rng.below(5);
            let kind = if rng.below(2) == 0 { ScopeKind::Escape { align } } else { ScopeKind::End };
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

/// One function's decoder inputs.
#[derive(Clone)]
struct Inputs {
    mode: Mode,
    code: Vec<u8>,
    relocs: Vec<asm::Reloc>,
    rodata: Vec<u8>,
    call_sites: Vec<asm::CallSite>,
    dropped: Vec<asm::DroppedStore>,
    scopes: Vec<Scope>,
}

impl Inputs {
    fn of(enc: &asm::Encoded, mode: Mode) -> Inputs {
        Inputs {
            mode,
            code: enc.code.clone(),
            relocs: enc.relocs.clone(),
            rodata: enc.rodata.clone(),
            call_sites: enc.call_sites.clone(),
            dropped: enc.dropped.clone(),
            scopes: enc.scopes.clone(),
        }
    }

    /// The inputs as the encoder's output (without targets and hints).
    fn encoded(&self) -> asm::Encoded {
        let (code, relocs, rodata) = (self.code.clone(), self.relocs.clone(), self.rodata.clone());
        let (call_sites, dropped, scopes) = (self.call_sites.clone(), self.dropped.clone(), self.scopes.clone());
        asm::Encoded { code, relocs, rodata, call_sites, dropped, scopes, ..Default::default() }
    }

    /// What `decode_reduced` makes of the inputs, as text.
    fn text(&self) -> String {
        let r = catch_unwind(AssertUnwindSafe(|| asm::decode_reduced(&self.encoded(), self.mode)));
        match r {
            Ok(Ok(d)) => text(&d),
            Ok(Err(e)) => format!("error at {}: {}\n", e.at, e.what),
            Err(_) => panic!("decode_reduced panics on {}", inputs_json(self)),
        }
    }
}

fn hex(b: &[u8]) -> String {
    b.iter().map(|x| format!("{x:02x}")).collect()
}

fn ref_text(r: Ref) -> String {
    match r {
        Ref::Handler(op) => format!("handler {op:?}"),
        Ref::RegHandler(op) => format!("reg handler {op:?}"),
        Ref::Probe => "probe".to_owned(),
        Ref::Func(f) => format!("func {}", f.0),
        Ref::Sym(s) => format!("sym {}", s.0),
        Ref::Site(s) => format!("site {}", s.0),
        Ref::Const(k) => format!("const {}", k.0),
        Ref::Data(d) => format!("data {}", d.0),
        Ref::Ro(o) => format!("ro {o}"),
        Ref::Rec => "rec".to_owned(),
        Ref::RecLoopCtr => "recloopctr".to_owned(),
    }
}

fn sites_json(s: &[asm::CallSite]) -> String {
    let v: Vec<String> =
        s.iter().map(|c| format!("[{},{},{},{}]", c.start, c.len, c.pad.map_or("null".to_owned(), |p| p.to_string()), c.catch)).collect();
    format!("[{}]", v.join(","))
}

fn dropped_json(d: &[(u32, i32, u8, u8)]) -> String {
    let v: Vec<String> = d.iter().map(|(at, off, size, reg)| format!("[{at},{off},{size},{reg}]")).collect();
    format!("[{}]", v.join(","))
}

fn dropped_parts(d: &[asm::DroppedStore]) -> Vec<(u32, i32, u8, u8)> {
    d.iter()
        .map(|x| {
            let (off, size, reg) = x.parts();
            (x.at, off, size, reg)
        })
        .collect()
}

fn inputs_json(i: &Inputs) -> String {
    let relocs: Vec<String> = i.relocs.iter().map(|r| format!("[{},\"{}\"]", r.at, ref_text(r.to))).collect();
    let scopes: Vec<String> = i
        .scopes
        .iter()
        .map(|s| {
            let a = match s.kind {
                ScopeKind::Escape { align } => align.to_string(),
                ScopeKind::End => "null".to_owned(),
                ScopeKind::Lend => "\"lend\"".to_owned(),
            };
            format!("[{},{},{},{a}]", s.code_offset, s.frame_offset, s.size)
        })
        .collect();
    format!(
        "{{\"mode\":{},\"code\":\"{}\",\"rodata\":\"{}\",\"relocs\":[{}],\"call_sites\":{},\"dropped\":{},\"scopes\":[{}]}}",
        i.mode.to_header_bits(),
        hex(&i.code),
        hex(&i.rodata),
        relocs.join(","),
        sites_json(&i.call_sites),
        dropped_json(&dropped_parts(&i.dropped)),
        scopes.join(",")
    )
}

/// The text of a decoded function (`Decoded.toText` in Lean).
fn text(d: &asm::Decoded) -> String {
    let mut s = format!("frame {}\n{}", d.frame_size, reduced::Disasm(&d.words));
    for e in &d.cleanup {
        if e.target == CONTINUE {
            writeln!(s, "cleanup {} continue", e.offset).unwrap();
        } else {
            writeln!(s, "cleanup {} -> {}{}", e.offset, e.target & !CATCH, if e.target & CATCH != 0 { " catch" } else { "" }).unwrap();
        }
    }
    for sc in &d.scopes {
        let k = match sc.kind {
            ScopeKind::Escape { align } => format!("escape {align}"),
            ScopeKind::End => "end".to_owned(),
            ScopeKind::Lend => "lend".to_owned(),
        };
        writeln!(s, "scope {} {} {} {k}", sc.code_offset, sc.frame_offset, sc.size).unwrap();
    }
    writeln!(s, "dropped {:?}", d.dropped).unwrap();
    writeln!(s, "heads {:?}", d.heads).unwrap();
    s
}

fn json_str(s: &str) -> String {
    let mut o = String::from("\"");
    for c in s.chars() {
        match c {
            '"' => o.push_str("\\\""),
            '\\' => o.push_str("\\\\"),
            '\n' => o.push_str("\\n"),
            c => o.push(c),
        }
    }
    o.push('"');
    o
}

/// The vectors being built: the base functions and their mutations.
struct Out {
    lines: Vec<String>,
    bases: Vec<Inputs>,
    ok: usize,
    rejected: usize,
}

impl Out {
    /// A function that decodes. With `sound_drops`, its dropped stores are those the encoder
    /// found overwritten (no dead-slot hints), which the Lean dead-store check must accept.
    fn base(&mut self, i: Inputs, sound_drops: bool) {
        let t = i.text();
        assert!(!t.starts_with("error"), "a base vector doesn't decode: {t}");
        let tag = if sound_drops { "\"sound_drops\":true," } else { "" };
        self.lines.push(format!("{{\"in\":{},{tag}\"out\":{}}}", inputs_json(&i), json_str(&t)));
        self.bases.push(i);
    }

    fn encoded(&mut self, enc: &asm::Encoded, mode: Mode) {
        self.base(Inputs::of(enc, mode), false);
    }

    /// Mutations of the last base vector.
    fn mutate(&mut self, rng: &mut Rng, n: usize) {
        let b = self.bases.len() - 1;
        let base = self.bases[b].clone();
        for _ in 0..n {
            let mut m = base.clone();
            let mut desc = Vec::new();
            match rng.below(10) {
                0..=5 => {
                    // One to three bytes changed.
                    let mut sets = Vec::new();
                    for _ in 0..1 + rng.below(3) {
                        if m.code.is_empty() {
                            break;
                        }
                        let p = rng.below(m.code.len() as u64) as usize;
                        let v = if rng.below(2) == 0 { m.code[p] ^ (1 << rng.below(8)) } else { rng.next() as u8 };
                        m.code[p] = v;
                        sets.push(format!("[{p},{v}]"));
                    }
                    desc.push(format!("\"code_set\":[{}]", sets.join(",")));
                }
                6 | 7 => {
                    let n = rng.below(m.code.len() as u64 + 1) as usize;
                    m.code.truncate(n);
                    desc.push(format!("\"code_len\":{n}"));
                }
                8 => {
                    // A call site removed, moved or with another landing pad.
                    if m.call_sites.is_empty() {
                        m.call_sites.push(asm::CallSite { start: rng.below(m.code.len() as u64 + 1) as u32, len: 5, pad: None, catch: false });
                    } else {
                        let k = rng.below(m.call_sites.len() as u64) as usize;
                        match rng.below(4) {
                            0 => {
                                m.call_sites.remove(k);
                            }
                            1 => m.call_sites[k].start += 1,
                            2 => m.call_sites[k].len += 1,
                            _ => m.call_sites[k].pad = m.call_sites[k].pad.map_or(Some(0), |p| Some(p.wrapping_add(rng.below(16) as u32))),
                        }
                    }
                    desc.push(format!("\"call_sites\":{}", sites_json(&m.call_sites)));
                }
                _ => {
                    // A dropped store removed, added or moved.
                    let mut d = dropped_parts(&m.dropped);
                    if d.is_empty() || rng.below(3) == 0 {
                        let at = rng.below(m.code.len() as u64 + 1) as u32;
                        let i = d.partition_point(|x| x.0 <= at);
                        d.insert(
                            i,
                            (at, -8 * (1 + rng.below(4) as i32), [1, 2, 4, 8][rng.below(4) as usize], [0, 2, 6, 7, 8, 11][rng.below(6) as usize]),
                        );
                    } else {
                        let k = rng.below(d.len() as u64) as usize;
                        if rng.below(2) == 0 {
                            d.remove(k);
                        } else {
                            d[k].0 = d[k].0.wrapping_add(rng.below(7) as u32).wrapping_sub(3);
                            d.sort_by_key(|x| x.0);
                        }
                    }
                    m.dropped = d.iter().map(|&(at, off, size, reg)| asm::DroppedStore::from_parts(at, off, size, reg).unwrap()).collect();
                    desc.push(format!("\"dropped\":{}", dropped_json(&d)));
                }
            }
            let t = m.text();
            if t.starts_with("error") {
                self.rejected += 1;
            } else {
                self.ok += 1;
            }
            self.lines.push(format!("{{\"base\":{b},{},\"out\":{}}}", desc.join(","), json_str(&t)));
        }
    }
}

fn encode_fn(f: &Fn, frame_size: u32, mode: Mode) -> asm::Encoded {
    let frame_size = if mode.pe { frame_size.max(16) } else { frame_size };
    let (code, cleanup) = f.words();
    let scopes = random_scopes(&code);
    asm::encode(&code, frame_size, &cleanup, &scopes, mode).unwrap_or_else(|e| panic!("{e:?}\n{}", Disasm(&code)))
}

fn every_opcode(rng: &mut Rng, out: &mut Out) {
    for (k, &op) in ALL_OPCODES.iter().enumerate() {
        let mode = MODES[k % MODES.len()];
        let list_len = [0, 1, 3][k / MODES.len() % 3];
        let mut f = Fn { insns: vec![vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
        let fillers = [0, 2][k % 2];
        let catch = k % 2 == 0;
        // [abort], insn, filler…, lpad, jmp 0, abort. On PE, a cleanup landing pad starts the
        // pad region, which nothing branches into or out of: [abort], insn, filler…, abort,
        // lpad, jmp, abort (as in `asm.rs`).
        let region = mode.pe && op_may_unwind(op) && list_len == 3 && !catch;
        let last = 2 + fillers + 2 + usize::from(region);
        let mut target = |rng: &mut Rng| {
            let k = rng.below(4) as usize;
            if region { [0, 1, 2 + fillers, 2 + fillers][k] } else { [0, 1, last, 2 + fillers][k] }
        };
        let w = insn(op, rng, list_len, &mut f, &mut target);
        if op == Opcode::Arg {
            f.insns[0] = w;
        } else {
            f.insns.push(w);
        }
        for _ in 0..fillers {
            let filler = insn(Opcode::AddImmW64, rng, 0, &mut f, &mut |_| 0);
            f.insns.push(filler);
        }
        if region {
            f.insns.push(vec![Opcode::Abort as u32]);
        }
        let pad = f.insns.len();
        f.insns.push(vec![Opcode::Lpad as u32, rng.next() as u32]);
        f.insns.push(vec![Opcode::Jmp as u32, 0]);
        f.targets.push((pad + 1, 1, if region { pad + 2 } else { 0 }));
        f.insns.push(vec![Opcode::Abort as u32]);
        if op_may_unwind(op) && list_len != 1 {
            f.unwind.push((1, if list_len == 0 { None } else { Some((pad, catch)) }));
        }
        let enc = encode_fn(&f, FRAMES[k % FRAMES.len()], mode);
        out.encoded(&enc, mode);
        out.mutate(rng, if k % 4 == 0 { 2 } else { 1 });
    }
}

/// PE: functions with a pad region (design/vm.md#unwinding), as in `asm.rs`'s `pe_pad_region`:
/// cleanup landing pads after the counter stubs behind the region's entry, its own calls and
/// islands, terminate pads on both sides, a loop in it, `resume`, and the `nop`s after calls
/// with landing pads that end their instruction.
fn pe_pad_region(rng: &mut Rng, out: &mut Out) {
    for (k, mode) in MODES.into_iter().filter(|m| m.pe).enumerate() {
        for round in 0..4 {
            let mut f = Fn::new();
            let x = -8i32 as u32;
            // A call storing nothing (bare), or with a random return kind.
            let call = |f: &mut Fn, rng: &mut Rng, bare: bool| {
                let mut w = insn(Opcode::Call, rng, 1, f, &mut |_| 0);
                if bare {
                    (w[1], w[3]) = (0, 0);
                }
                f.insns.push(w);
            };
            // The body: a loop head at 0, calls and an island with the cleanup pad, a call
            // with the body's terminate pad, `ret`.
            call(&mut f, rng, true);
            let island = insn(Opcode::Island, rng, 2, &mut f, &mut |_| 0);
            f.insns.push(island);
            call(&mut f, rng, round % 2 == 0);
            call(&mut f, rng, true);
            f.insns.push(vec![Opcode::Br as u32, 8, 0, 0]);
            f.targets.push((4, 3, 0));
            let ret = insn(Opcode::Ret, rng, 0, &mut f, &mut |_| 0);
            f.insns.push(ret);
            // The body's terminate pad and stub.
            let body_pad = f.insns.len();
            f.insns.push(vec![Opcode::Lpad as u32, x]);
            f.insns.push(vec![Opcode::Jmp as u32, 0]);
            f.targets.push((body_pad + 1, 1, body_pad + 2));
            call(&mut f, rng, true);
            f.insns.push(vec![Opcode::Unreachable as u32]);
            // The region: the cleanup pad, a loop of a call and an island with the region's
            // terminate pad, `resume`, then that pad and its stub.
            let pad = f.insns.len();
            f.insns.push(vec![Opcode::Lpad as u32, x]);
            f.insns.push(vec![Opcode::Jmp as u32, 0]);
            f.targets.push((pad + 1, 1, pad + 2));
            call(&mut f, rng, round < 2);
            let island = insn(Opcode::Island, rng, 1, &mut f, &mut |_| 0);
            f.insns.push(island);
            f.insns.push(vec![Opcode::Br as u32, 16, 1, 0]);
            f.targets.push((pad + 4, 3, pad + 2));
            f.insns.push(vec![Opcode::Resume as u32, x]);
            let region_pad = f.insns.len();
            f.insns.push(vec![Opcode::Lpad as u32, x]);
            f.insns.push(vec![Opcode::Jmp as u32, 0]);
            f.targets.push((region_pad + 1, 1, region_pad + 2));
            call(&mut f, rng, true);
            f.insns.push(vec![Opcode::Unreachable as u32]);
            f.unwind = vec![
                (0, Some((pad, false))),
                (1, Some((pad, false))),
                (2, Some((pad, false))),
                (3, Some((body_pad, true))),
                (body_pad + 2, None),
                (pad + 2, Some((region_pad, true))),
                (pad + 3, Some((region_pad, true))),
                (pad + 5, None),
            ];
            let enc = encode_fn(&f, [48, 4096][(round + k) % 2], mode);
            out.encoded(&enc, mode);
            out.mutate(rng, 6);
        }
    }
}

fn long_branches(rng: &mut Rng, out: &mut Out) {
    for (k, mode) in MODES.into_iter().enumerate() {
        for n in [1, 31, 32, 200] {
            if n == 200 && k % 10 != 0 {
                continue;
            }
            let mut f = Fn::new();
            f.insns.push(vec![Opcode::Br as u32, 8, 0, 0]);
            for _ in 0..n {
                let w = insn(Opcode::MovW64, rng, 0, &mut f, &mut |_| 0);
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
            let enc = encode_fn(&f, 32, mode);
            out.encoded(&enc, mode);
            out.mutate(rng, 2);
        }
    }
}

fn register_cache(rng: &mut Rng, out: &mut Out) {
    let inline: Vec<Opcode> = ALL_OPCODES.iter().copied().filter(|&op| asm::has_inline(op)).collect();
    const SLOTS: [i32; 6] = [-8, -16, -24, -12, -32, 16];
    for round in 0..80 {
        let mode = MODES[round % MODES.len()];
        let n = 4 + rng.below(30) as usize;
        let mut f = Fn::new();
        for _ in 0..n {
            let op = match rng.below(12) {
                0 => Opcode::FaddF32,
                _ => inline[rng.below(inline.len() as u64) as usize],
            };
            let mut w = insn(op, rng, 0, &mut f, &mut |rng| rng.below(n as u64 + 1) as usize);
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
        let enc = encode_fn(&f, 32, mode);
        out.encoded(&enc, mode);
        out.mutate(rng, 2);
    }
}

fn dead_stores(rng: &mut Rng, out: &mut Out) {
    use asm::Opnd;
    let inline: Vec<Opcode> = ALL_OPCODES.iter().copied().filter(|&op| asm::has_inline(op)).collect();
    const SLOTS: [i32; 6] = [-8, -16, -24, -12, -32, 16];
    let mut kept = 0;
    for round in 0..2000 {
        if kept == 170 {
            break;
        }
        let mode = MODES[round % MODES.len()];
        // A third without dead-slot hints: only overwritten stores are dropped.
        let hints = round % 3 != 0;
        let n = 4 + rng.below(30) as usize;
        let mut a = asm::Asm::new(mode);
        let labels: Vec<asm::Label> = (0..=n).map(|_| a.label()).collect();
        for (i, &l) in labels.iter().enumerate().take(n) {
            a.bind(l);
            let op = match rng.below(16) {
                0 => Opcode::FaddF32,
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
                    OperandKind::Sym => words.push(rng.below(1 << 20) as u32),
                    OperandKind::Abs => words.push(rng.below(1 << 20) as u32 | if rng.below(2) == 0 { ABS_DATA } else { 0 }),
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
                let len = [4, 8, 16, 24][rng.below(4) as usize];
                if hints {
                    a.dead(lo as u32, len);
                }
            }
            if i == n - 1 || rng.below(10) == 0 {
                a.insn(Opcode::Abort, &[]);
            }
        }
        a.bind(labels[n]);
        a.insn(Opcode::Abort, &[]);
        let enc = a.finish(48, |s| s);
        // Mostly the functions with dropped stores.
        if enc.dropped.is_empty() && round % 4 != 0 {
            continue;
        }
        kept += 1;
        out.base(Inputs::of(&enc, mode), !hints);
        out.mutate(rng, 2);
    }
}

/// Straight runs of inline instructions on three slots, without dead-slot hints: the stores
/// the encoder drops are all overwritten before anything reads them.
fn overwrites(rng: &mut Rng, out: &mut Out) {
    let inline: Vec<Opcode> =
        ALL_OPCODES.iter().copied().filter(|&op| asm::has_inline(op) && !op.info().operands.iter().any(|o| o.kind == OperandKind::Target)).collect();
    const SLOTS: [i32; 3] = [-8, -16, -24];
    let mut kept = 0;
    for round in 0..400 {
        if kept == 60 {
            break;
        }
        let mode = MODES[round % MODES.len()];
        let mut f = Fn::new();
        for _ in 0..4 + rng.below(12) {
            let op = inline[rng.below(inline.len() as u64) as usize];
            let mut w = insn(op, rng, 0, &mut f, &mut |_| 0);
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
        let (code, cleanup) = f.words();
        let enc = asm::encode(&code, 32, &cleanup, &[], mode).unwrap();
        if enc.dropped.is_empty() {
            continue;
        }
        kept += 1;
        out.base(Inputs::of(&enc, mode), true);
        out.mutate(rng, 1);
    }
}

fn inline_forms(rng: &mut Rng, out: &mut Out) {
    const SLOTS: [i32; 8] = [-8, 16, -128, 127, -129, 128, 1 << 20, -(1 << 20)];
    const KS: [i32; 5] = [0, 1, -128, 300, -70000];
    let mut k = 0;
    for &op in ALL_OPCODES {
        if !asm::has_inline(op) {
            continue;
        }
        for round in 0..2 {
            k += 1;
            let mode = MODES[k % MODES.len()];
            let mut f = Fn { insns: vec![vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
            let mut w = vec![op as u32];
            for o in op.info().operands {
                let slot = SLOTS[rng.below(8) as usize] as u32;
                match o.kind {
                    OperandKind::Slot => w.push(slot),
                    OperandKind::Mem => w.extend([slot, KS[rng.below(5) as usize] as u32]),
                    OperandKind::U8 => w.push(if round == 0 { rng.below(10) } else { rng.imm() } as u8 as u32),
                    OperandKind::U16 => w.push(if round == 0 { rng.below(20) } else { rng.imm() } as u16 as u32),
                    OperandKind::U32 => w.push(if round == 0 { rng.below(40) } else { rng.imm() } as u32),
                    OperandKind::U64 | OperandKind::I64 => {
                        let v = if round == 0 { rng.below(70) } else { rng.imm() };
                        w.extend([v as u32, (v >> 32) as u32]);
                    }
                    OperandKind::Neg => w.push(rng.below(2) as u32),
                    OperandKind::Target => {
                        f.targets.push((1, w.len(), [0, 1, 2, 3][rng.below(4) as usize]));
                        w.push(0);
                    }
                    OperandKind::Sym => w.push(rng.below(1 << 20) as u32),
                    OperandKind::Abs => w.push(rng.below(1 << 20) as u32 | if rng.below(2) == 0 { ABS_DATA } else { 0 }),
                    k => panic!("{}: operand kind {k:?}", op.mnemonic()),
                }
            }
            f.insns.push(w);
            f.insns.push(vec![Opcode::Abort as u32]);
            f.insns.push(vec![Opcode::Abort as u32]);
            let enc = encode_fn(&f, FRAMES[k % FRAMES.len()], mode);
            out.encoded(&enc, mode);
            out.mutate(rng, 1);
        }
    }
}

fn handwritten(rng: &mut Rng, out: &mut Out) {
    // `mov.w128` apart from two `mov.w64`s.
    let mov = |op: Opcode, d: i32, s: i32| vec![op as u32, d as u32, s as u32];
    let (m64, m128) = (Opcode::MovW64, Opcode::MovW128);
    let runs = [
        vec![mov(m64, -32, -16), mov(m64, -24, -8)],
        vec![mov(m64, -24, -8), mov(m64, -32, -16)],
        vec![mov(m128, -32, -16), mov(m64, -16, -40)],
        vec![mov(m128, -24, -32), mov(m128, -40, -24)],
    ];
    for mode in [MODES[0], MODES[1], MODES[8]] {
        for insns in &runs {
            let mut insns = insns.clone();
            insns.push(vec![Opcode::Abort as u32]);
            let f = Fn { insns, targets: Vec::new(), unwind: Vec::new() };
            out.encoded(&encode_fn(&f, 48, mode), mode);
            out.mutate(rng, 1);
        }
    }
    // A reload dropped, and kept at a branch target; values in other registers.
    let add = |d: i32, a: i32, b: i32| vec![Opcode::AddW64 as u32, d as u32, a as u32, b as u32];
    let fs = [
        Fn { insns: vec![mov(m64, -16, -8), mov(m64, -24, -16), vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() },
        Fn { insns: vec![mov(m64, -16, -8), mov(m64, -24, -16), vec![Opcode::Jmp as u32, 0]], targets: vec![(2, 1, 1)], unwind: Vec::new() },
        Fn {
            insns: vec![add(-16, -8, -8), mov(m64, -24, -32), add(-40, -16, -24), vec![Opcode::Abort as u32]],
            targets: Vec::new(),
            unwind: Vec::new(),
        },
    ];
    for f in &fs {
        for mode in [MODES[0], MODES[9], MODES[16]] {
            out.encoded(&encode_fn(f, 64, mode), mode);
            out.mutate(rng, 1);
        }
    }
    // A dead hint before a padded loop head, and a scope there.
    for counters in [false, true] {
        use asm::Opnd::{Imm, Neg, Slot, Target};
        let mode = Mode { fp_arg: false, frame_pointer: true, align_loops: true, pe: false, counters, far_rt: false };
        let mut a = asm::Asm::new(mode);
        let (empty, head) = (a.label(), a.label());
        a.insn(Opcode::BrEqImmW64, &[Slot(-8), Imm(0), Neg(false), Target(empty)]);
        a.insn(Opcode::MovW64, &[Slot(-16), Slot(-8)]);
        a.bind(empty);
        a.dead(-16i32 as u32, 8);
        a.escape(-16i32 as u32, 8, 8);
        a.bind(head);
        a.insn(Opcode::AddImmW64, &[Slot(-8), Slot(-8), Imm(1)]);
        a.insn(Opcode::Jmp, &[Target(head)]);
        out.encoded(&a.finish(16, |s| s), mode);
        out.mutate(rng, 2);
    }
    // SSE at `rsp`, without a frame pointer.
    let k = asm::ret_kind(&[asm::RetPart { xmm: true, size: 8, off: 0 }]);
    for mode in [MODES[8], MODES[9]] {
        let f = Fn { insns: vec![vec![Opcode::Ret as u32, -16i32 as u32, k]], targets: Vec::new(), unwind: Vec::new() };
        out.encoded(&encode_fn(&f, 16, mode), mode);
        out.mutate(rng, 1);
    }
    // An island's operands' extents (`Lend` scopes), after a store to one of them.
    for mode in [MODES[0], MODES[8]] {
        use asm::Opnd::{Slot, Words};
        let mut a = asm::Asm::new(mode);
        a.insn(Opcode::MovW64, &[Slot(-16), Slot(-8)]);
        a.lend(-16i32 as u32, 8);
        a.lend(-40i32 as u32, 24);
        a.insn(Opcode::Island, &[asm::Opnd::Sym(Sym(1)), Words(vec![-16i32 as u32, -40i32 as u32])]);
        a.insn(Opcode::Abort, &[]);
        out.encoded(&a.finish(48, |s| s), mode);
        out.mutate(rng, 1);
    }
}

/// Inputs on which the decoder once overflowed (a panic in a debug build), each a mutation of
/// a function that decodes, which it must reject.
fn overflows(out: &mut Out) {
    let find = |code: &[u8], pat: &[u8]| code.windows(pat.len()).position(|w| w == pat).expect("pattern");
    let push = |out: &mut Out, enc: &asm::Encoded, mode: Mode, at: usize, bytes: &[u8]| {
        out.encoded(enc, mode);
        let b = out.bases.len() - 1;
        let mut m = out.bases[b].clone();
        let mut sets = Vec::new();
        for (k, &v) in bytes.iter().enumerate() {
            m.code[at + k] = v;
            sets.push(format!("[{},{v}]", at + k));
        }
        let t = m.text();
        assert!(t.starts_with("error"), "an overflow decodes: {t}");
        out.rejected += 1;
        out.lines.push(format!("{{\"base\":{b},\"code_set\":[{}],\"out\":{}}}", sets.join(","), json_str(&t)));
    };
    // `mov.w128` whose source is at `i32::MAX - 3`: its high half's `disp + 8` overflows.
    let mode = MODES[0];
    let s: i32 = -(1 << 20) + 64;
    let f = Fn {
        insns: vec![vec![Opcode::MovW128 as u32, -(1i32 << 20) as u32, s as u32], vec![Opcode::Abort as u32]],
        targets: Vec::new(),
        unwind: Vec::new(),
    };
    let enc = encode_fn(&f, 32, mode);
    let at = find(&enc.code, &s.to_le_bytes());
    push(out, &enc, mode, at, &0x7fff_fffcu32.to_le_bytes());
    // A call's 7-byte result stored in three pieces, the second moved below the first: the
    // pieces' offsets `p.off + p.size` overflow in `parts_of`.
    let k = asm::ret_kind(&[asm::RetPart { xmm: false, size: 7, off: 0 }]);
    let f =
        Fn { insns: vec![vec![Opcode::Call as u32, -16i32 as u32, 0, k, 0], vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
    let enc = encode_fn(&f, 32, mode);
    let at = find(&enc.code, &[0x66, 0x89, 0x45, 0xf4]) + 3;
    push(out, &enc, mode, at, &[0xee]);
}

/// Shuffled frames (`RYO_JIT_SHUFFLE`): decoded code renamed and encoded again with
/// `encode_reduced_at`, in a frame of another size.
fn shuffled(out: &mut Out) {
    use asm::frame;
    let n = out.bases.len();
    let mut done = 0;
    for b in (0..n).step_by(7) {
        if done == 40 {
            break;
        }
        let i = out.bases[b].clone();
        let Ok(d) = asm::decode_reduced(&i.encoded(), i.mode) else { continue };
        let Ok(map) = frame::shuffle_map(&d, i.mode) else { continue };
        if map.is_identity() {
            continue;
        }
        let words = frame::remap_slots(&d.words, i.mode, &map).unwrap();
        let scopes: Vec<Scope> =
            d.scopes.iter().filter_map(|sc| Some(Scope { frame_offset: map.map_range(sc.frame_offset, sc.size)?, ..*sc })).collect();
        let Ok((enc, _)) = asm::encode_reduced_at(&words, map.frame_size, &d.cleanup, &scopes, &d.dropped, &i.rodata, i.mode) else { continue };
        out.encoded(&enc, i.mode);
        done += 1;
    }
}

fn vectors() -> (String, String) {
    let mut rng = Rng(0x1ea4_dec0_de00_0001);
    let mut out = Out { lines: Vec::new(), bases: Vec::new(), ok: 0, rejected: 0 };
    every_opcode(&mut rng, &mut out);
    pe_pad_region(&mut rng, &mut out);
    long_branches(&mut rng, &mut out);
    register_cache(&mut rng, &mut out);
    dead_stores(&mut rng, &mut out);
    overwrites(&mut rng, &mut out);
    inline_forms(&mut rng, &mut out);
    handwritten(&mut rng, &mut out);
    overflows(&mut out);
    shuffled(&mut out);
    let stats = format!("{} functions, {} mutations: {} accepted, {} rejected", out.bases.len(), out.ok + out.rejected, out.ok, out.rejected);
    let mut s = String::new();
    s.push_str(
        "/-\nGenerated by `vm/bytecode/tests/lean_reduced_vectors.rs` (`RYO_LEAN_GEN=1 cargo test --test\nlean_reduced_vectors` in `vm/`): \
         decoder inputs and the text of Rust's `asm::decode_reduced` result, which the Lean tests in\n`RyoTest/DecodeReduced.lean` check \
         `decodeReduced` against. Do not edit.\n\n",
    );
    writeln!(s, "{stats}.\n-/\n\nnamespace RyoTest.DecodeReducedVectors\n\ndef json : String := r#\"[").unwrap();
    for (k, v) in out.lines.iter().enumerate() {
        assert!(!v.contains("\"#"));
        let sep = if k + 1 == out.lines.len() { "" } else { "," };
        writeln!(s, "{v}{sep}").unwrap();
    }
    s.push_str("]\"#\n\nend RyoTest.DecodeReducedVectors\n");
    (s, stats)
}

#[test]
fn lean_reduced_vectors() {
    let path = concat!(env!("CARGO_MANIFEST_DIR"), "/../../lean/RyoTest/DecodeReducedVectors.lean");
    let (want, stats) = vectors();
    println!("{stats}");
    if std::env::var_os("RYO_LEAN_GEN").is_some_and(|v| v == "1") {
        std::fs::write(path, want).unwrap();
        return;
    }
    let have = std::fs::read_to_string(path).unwrap_or_default();
    assert!(have == want, "{path} is out of date: regenerate it with RYO_LEAN_GEN=1 cargo test --test lean_reduced_vectors");
}
