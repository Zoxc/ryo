//! Test vectors for the Lean op view (`lean/Ryo/Vm/R/View.lean`): functions encoded with
//! `asm::encode` (every opcode with random operands, in two modes for the opcodes with a
//! handler, so both `asm::layout` variants; and runs of inline instructions), each with its
//! decoder inputs and what Rust's `asm::decode` makes of it: one line per instruction, its full
//! opcode and operands in a common text form. The Lean tests (`RyoTest/View.lean`) decode the
//! same inputs with `decodeReduced`, apply `view` to each reduced instruction and print the
//! result in the same form. Written as `lean/RyoTest/ViewVectors.lean`; with `RYO_LEAN_GEN=1`
//! the test rewrites that file, else it checks it is up to date.
//!
//! The common form of an instruction: its mnemonic, then each operand, space-separated: `s<off>`
//! a slot, `m<p>,<k>` a memory operand, `i<v>` an immediate (unsigned, `I64` as its 64-bit
//! pattern), `k<n>` / `d<n>` / `y<n>` / `t<n>` a constant, data offset, symbol or site, `f<n>` a
//! function, `@<i>` a target (an instruction index), `n0` / `n1` a polarity, `[@i,…]` a target
//! list, `w[…]` a word list, `c[v=>@i,…]` a case list.

use std::fmt::Write as _;

use ryo_bytecode::asm::{self, Mode, Opnd, Scope, ScopeKind};
use ryo_bytecode::full::*;
use ryo_bytecode::image::{CATCH, CONTINUE, CleanupEntry, op_may_unwind};

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

/// Every valid mode (as in `asm.rs` and `lean_reduced_vectors.rs`).
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

/// A function built from instructions whose targets are instruction indices.
struct Body {
    insns: Vec<Vec<u32>>,
    targets: Vec<(usize, usize, usize)>,
    unwind: Vec<(usize, Option<(usize, bool)>)>,
}

impl Body {
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

fn insn(op: Opcode, rng: &mut Rng, list_len: usize, f: &mut Body, target: &mut dyn FnMut(&mut Rng) -> usize) -> Vec<u32> {
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

fn hex(b: &[u8]) -> String {
    b.iter().map(|x| format!("{x:02x}")).collect()
}

fn ref_text(r: asm::Ref) -> String {
    use asm::Ref;
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

/// The decoder inputs as `Inputs.ofJson` reads them (`lean_reduced_vectors.rs`'s form).
fn inputs_json(enc: &asm::Encoded, mode: Mode) -> String {
    let relocs: Vec<String> = enc.relocs.iter().map(|r| format!("[{},\"{}\"]", r.at, ref_text(r.to))).collect();
    let sites: Vec<String> = enc
        .call_sites
        .iter()
        .map(|c| format!("[{},{},{},{}]", c.start, c.len, c.pad.map_or("null".to_owned(), |p| p.to_string()), c.catch))
        .collect();
    let dropped: Vec<String> = enc
        .dropped
        .iter()
        .map(|x| {
            let (off, size, reg) = x.parts();
            format!("[{},{off},{size},{reg}]", x.at)
        })
        .collect();
    let scopes: Vec<String> = enc
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
        "{{\"mode\":{},\"code\":\"{}\",\"rodata\":\"{}\",\"relocs\":[{}],\"call_sites\":[{}],\"dropped\":[{}],\"scopes\":[{}]}}",
        mode.to_header_bits(),
        hex(&enc.code),
        hex(&enc.rodata),
        relocs.join(","),
        sites.join(","),
        dropped.join(","),
        scopes.join(",")
    )
}

/// An operand in the common form, targets (absolute word positions) as instruction indices.
fn opnd_text(o: &Opnd, index: &dyn Fn(u32) -> usize) -> String {
    let ts = |ts: &[u32]| ts.iter().map(|&t| format!("@{}", index(t))).collect::<Vec<_>>().join(",");
    match o {
        Opnd::Slot(s) => format!("s{s}"),
        Opnd::Mem(p, k) => format!("m{p},{k}"),
        Opnd::Imm(v) => format!("i{v}"),
        Opnd::Imm128(v) => format!("i{v}"),
        Opnd::Const(k) => format!("k{}", k.0),
        Opnd::Data(d) => format!("d{}", d.0),
        Opnd::Sym(s) => format!("y{}", s.0),
        Opnd::Site(s) => format!("t{}", s.0),
        Opnd::Func(f) => format!("f{}", f.0),
        Opnd::Target(t) => format!("@{}", index(*t)),
        Opnd::Neg(n) => format!("n{}", *n as u8),
        Opnd::Targets(t) => format!("[{}]", ts(t)),
        Opnd::Words(w) => format!("w[{}]", w.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(",")),
        Opnd::Cases(v, t) => {
            format!("c[{}]", v.iter().zip(t).map(|(v, &t)| format!("{v}=>@{}", index(t))).collect::<Vec<_>>().join(","))
        }
    }
}

/// What `asm::decode` makes of the function: one common-form line per instruction.
fn full_lines(enc: &asm::Encoded, mode: Mode) -> Vec<String> {
    let d = asm::decode(&enc.code, &enc.relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, mode)
        .unwrap_or_else(|e| panic!("decode: {e:?}"));
    let mut starts = Vec::new();
    let mut at = 0;
    while at < d.words.len() {
        starts.push(at as u32);
        at += insn_len(&d.words[at..]).unwrap();
    }
    let index = |t: u32| starts.binary_search(&t).expect("a target is an instruction");
    starts
        .iter()
        .map(|&at| {
            let op = Opcode::from_u16(d.words[at as usize] as u16).unwrap();
            let mut s = op.mnemonic().to_owned();
            for o in asm::operands(&d.words, at as usize) {
                s.push(' ');
                s.push_str(&opnd_text(&o, &index));
            }
            s
        })
        .collect()
}

fn json_str(s: &str) -> String {
    format!("\"{}\"", s.replace('\\', "\\\\").replace('"', "\\\""))
}

struct Out {
    lines: Vec<String>,
    insns: usize,
}

impl Out {
    fn push(&mut self, f: &Body, frame_size: u32, mode: Mode) {
        let frame_size = if mode.pe { frame_size.max(16) } else { frame_size };
        let (code, cleanup) = f.words();
        let scopes: Vec<Scope> = Vec::new();
        let enc = asm::encode(&code, frame_size, &cleanup, &scopes, mode).unwrap_or_else(|e| panic!("{e:?}\n{}", Disasm(&code)));
        let lines = full_lines(&enc, mode);
        self.insns += lines.len();
        let full: Vec<String> = lines.iter().map(|l| json_str(l)).collect();
        self.lines.push(format!("{{\"in\":{},\"full\":[{}]}}", inputs_json(&enc, mode), full.join(",")));
    }
}

/// Each opcode in one function (as `lean_reduced_vectors.rs`'s `every_opcode`), and each with a
/// handler again in the other `fp_arg` mode.
fn every_opcode(rng: &mut Rng, out: &mut Out) {
    for pass in 0..2 {
        for (k, &op) in ALL_OPCODES.iter().enumerate() {
            if pass == 1 && !asm::has_handler(op) {
                continue;
            }
            let mode = MODES[(k + pass) % 8];
            let list_len = [0, 1, 3][(k / 8 + pass) % 3];
            let mut f = Body { insns: vec![vec![Opcode::Abort as u32]], targets: Vec::new(), unwind: Vec::new() };
            let last = 4;
            let mut target = |rng: &mut Rng| [0, 1, last, 2][rng.below(4) as usize];
            let w = insn(op, rng, list_len, &mut f, &mut target);
            if op == Opcode::Arg {
                f.insns[0] = w;
            } else {
                f.insns.push(w);
            }
            let pad = f.insns.len();
            f.insns.push(vec![Opcode::Lpad as u32, rng.next() as u32]);
            f.insns.push(vec![Opcode::Jmp as u32, 0]);
            f.targets.push((pad + 1, 1, 0));
            f.insns.push(vec![Opcode::Abort as u32]);
            // On PE a cleanup landing pad would start the pad region, which `jmp 0` crosses:
            // catching pads only there (`lean_reduced_vectors.rs` covers the region).
            if op_may_unwind(op) && list_len != 1 {
                f.unwind.push((1, if list_len == 0 { None } else { Some((pad, k % 2 == 0 || mode.pe)) }));
            }
            out.push(&f, FRAMES[k % FRAMES.len()], mode);
        }
    }
}

/// Runs of inline instructions and a few handler calls, on a few slots, with branches.
fn inline_runs(rng: &mut Rng, out: &mut Out) {
    let inline: Vec<Opcode> = ALL_OPCODES.iter().copied().filter(|&op| asm::has_inline(op)).collect();
    const SLOTS: [i32; 6] = [-8, -16, -24, -12, -32, 16];
    for round in 0..20 {
        let mode = MODES[round % MODES.len()];
        let n = 4 + rng.below(20) as usize;
        let mut f = Body { insns: Vec::new(), targets: Vec::new(), unwind: Vec::new() };
        for _ in 0..n {
            let op = match rng.below(8) {
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
        out.push(&f, 32, mode);
    }
}

fn vectors() -> (String, String) {
    let mut rng = Rng(0x1ea4_7e11_0000_0001);
    let mut out = Out { lines: Vec::new(), insns: 0 };
    every_opcode(&mut rng, &mut out);
    inline_runs(&mut rng, &mut out);
    let stats = format!("{} functions, {} instructions", out.lines.len(), out.insns);
    let mut s = String::new();
    s.push_str(
        "/-\nGenerated by `vm/bytecode/tests/lean_view_vectors.rs` (`RYO_LEAN_GEN=1 cargo test --test\nlean_view_vectors` in `vm/`): \
         decoder inputs and what Rust's `asm::decode` makes of them (one line per instruction, its\nfull opcode and operands), \
         which the Lean tests in `RyoTest/View.lean` check `view` against. Do not edit.\n\n",
    );
    writeln!(s, "{stats}.\n-/\n\nnamespace RyoTest.ViewVectors\n\ndef json : String := r#\"[").unwrap();
    for (k, v) in out.lines.iter().enumerate() {
        assert!(!v.contains("\"#"));
        let sep = if k + 1 == out.lines.len() { "" } else { "," };
        writeln!(s, "{v}{sep}").unwrap();
    }
    s.push_str("]\"#\n\nend RyoTest.ViewVectors\n");
    (s, stats)
}

#[test]
fn lean_view_vectors() {
    let path = concat!(env!("CARGO_MANIFEST_DIR"), "/../../lean/RyoTest/ViewVectors.lean");
    let (want, stats) = vectors();
    println!("{stats}");
    if std::env::var_os("RYO_LEAN_GEN").is_some_and(|v| v == "1") {
        std::fs::write(path, want).unwrap();
        return;
    }
    let have = std::fs::read_to_string(path).unwrap_or_default();
    assert!(have == want, "{path} is out of date: regenerate it with RYO_LEAN_GEN=1 cargo test --test lean_view_vectors");
}
