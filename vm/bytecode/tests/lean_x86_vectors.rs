//! Test vectors for the Lean x86 model (`lean/Ryo/X86`): the bytes the encoder gives a broad
//! set of `asm::x86::Item`s (every form, register, width, displacement and immediate size
//! class), in unlinked and linked code and in both frame modes; what the decoder makes of
//! mutations of them; and the OSR code of random entries. Written as
//! `lean/RyoTest/X86Vectors.lean`, which the Lean tests check `encode` and `decodeItem`
//! against. With `RYO_LEAN_GEN=1` the test rewrites that file, else it checks it is up to date.
//!
//! `asm::x86` is private to the crate, so the test compiles its source as a module of its own,
//! beside the crate's public `Ref`, `Reloc` and `Resolver`.

extern crate alloc;

use std::fmt::Write as _;

use ryo_bytecode::Opcode;
use ryo_bytecode::asm::{Mode, Ref, osr};
use ryo_bytecode::full::{Const, Data, Func, Site, Sym};

// What `x86.rs` takes from its parent module.
const ARG_REGS: usize = 6;
mod decode {
    pub use ryo_bytecode::asm::Resolver;
}
mod encode {
    pub use ryo_bytecode::asm::{Ref, Reloc};
}
#[allow(dead_code)]
#[path = "../src/asm/x86.rs"]
mod x86;

use ryo_bytecode::asm::{Reloc, Resolver};
use x86::{Alu, Cond, Cursor, Fields, Item, M, Reg, Rm, Sh, W};

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
    fn pick<T: Copy>(&mut self, xs: &[T]) -> T {
        xs[self.below(xs.len() as u64) as usize]
    }
    fn bool(&mut self) -> bool {
        self.next() & 1 != 0
    }
    /// A 32-bit value of every size class: 0, ±small, the `i8` and `i16` edges, large.
    fn i32(&mut self) -> i32 {
        match self.below(12) {
            0 => 0,
            1 => self.below(10) as i32 + 1,
            2 => -(self.below(10) as i32) - 1,
            3 => self.pick(&[127, -128, 128, -129]),
            4 => self.pick(&[32767, -32768, 32768, -32769]),
            5 => self.pick(&[i32::MAX, i32::MIN]),
            6 => self.below(1 << 15) as i32 - (1 << 14),
            _ => self.next() as i32,
        }
    }
    fn i8(&mut self) -> i32 {
        self.i32() as i8 as i32
    }
    fn i16(&mut self) -> i32 {
        self.i32() as i16 as i32
    }
}

const REGS: [Reg; 11] = [Reg::Rax, Reg::Rcx, Reg::Rdx, Reg::Rsp, Reg::Rbp, Reg::Rsi, Reg::Rdi, Reg::R8, Reg::R9, Reg::R10, Reg::R11];
const USABLE: [Reg; 9] = [Reg::Rax, Reg::Rcx, Reg::Rdx, Reg::Rsi, Reg::Rdi, Reg::R8, Reg::R9, Reg::R10, Reg::R11];
const CONDS: [Cond; 12] = [Cond::Z, Cond::Nz, Cond::L, Cond::Ge, Cond::Le, Cond::G, Cond::B, Cond::Ae, Cond::Be, Cond::A, Cond::S, Cond::Ns];
const WS: [W; 4] = [W::B, W::W, W::D, W::Q];
const DQ: [W; 2] = [W::D, W::Q];
const ALUS: [Alu; 6] = [Alu::Add, Alu::Or, Alu::And, Alu::Sub, Alu::Xor, Alu::Cmp];
const SHS: [Sh; 3] = [Sh::Shl, Sh::Shr, Sh::Sar];

/// Linked code: the function's address and its JIT record's.
const CODE: u64 = 0x4000_0000;
const RECORD: u64 = 0x6000_0000;

/// Where each reference lives once linked (`RyoTest/X86.lean` has the same map): disjoint
/// ranges, all within `rel32` reach of `CODE`.
fn addr_of(r: Ref) -> u64 {
    match r {
        Ref::Handler(op) => 0x1000_0000 + 16 * op as u64,
        Ref::Probe => 0x1800_0000,
        Ref::Func(Func(f)) => 0x2000_0000 + 16 * f as u64,
        Ref::Sym(Sym(s)) => 0x2800_0000 + 8 * s as u64,
        Ref::Site(Site(s)) => 0x3000_0000 + 8 * s as u64,
        Ref::Const(Const(k)) => 0x5000_0000 + k as u64,
        Ref::Data(Data(d)) => 0x5800_0000 + d as u64,
        Ref::Ro(o) => 0x6800_0000 + o as u64,
        Ref::Rec => RECORD,
        Ref::RecCtr => RECORD - 1,
    }
}

struct Link;
impl Resolver for Link {
    fn resolve(&self, a: u64) -> Option<Ref> {
        let (base, off) = (a & !0x7ff_ffff, a & 0x7ff_ffff);
        let idx = |k: u64| (off % k == 0).then(|| (off / k) as u32);
        Some(match base {
            0x1000_0000 => Ref::Handler(Opcode::from_u16(u16::try_from(idx(16)?).ok()?)?),
            0x1800_0000 if off == 0 => Ref::Probe,
            0x2000_0000 => Ref::Func(Func(idx(16)?)),
            0x2800_0000 => Ref::Sym(Sym(idx(8)?)),
            0x3000_0000 => Ref::Site(Site(idx(8)?)),
            0x5000_0000 => Ref::Const(Const(off as u32)),
            0x5800_0000 => Ref::Data(Data(off as u32)),
            0x6800_0000 => Ref::Ro(off as u32),
            _ => return None,
        })
    }
    fn code_consts(&self) -> &[u8] {
        &[]
    }
}

fn gen_ref(rng: &mut Rng) -> Ref {
    let small = |rng: &mut Rng| rng.below(1 << 12) as u32;
    match rng.below(10) {
        0 => Ref::Handler(Opcode::from_u16(rng.below(Opcode::COUNT as u64) as u16).unwrap()),
        1 => Ref::Probe,
        2 => Ref::Func(Func(small(rng))),
        3 => Ref::Sym(Sym(small(rng))),
        4 => Ref::Site(Site(small(rng))),
        5 => Ref::Const(Const(small(rng))),
        6 => Ref::Data(Data(small(rng))),
        7 => Ref::Ro(small(rng)),
        8 => Ref::Rec,
        _ => Ref::RecCtr,
    }
}

fn gen_m(rng: &mut Rng) -> M {
    let base = if rng.below(3) == 0 { Reg::Rbp } else { rng.pick(&USABLE) };
    M { base, disp: rng.i32() }
}

fn gen_rm(rng: &mut Rng) -> Rm {
    if rng.bool() { Rm::Reg(rng.pick(&USABLE)) } else { Rm::Mem(gen_m(rng)) }
}

/// An immediate that fits width `w`'s field.
fn imm_for(rng: &mut Rng, w: W) -> i32 {
    match w {
        W::B => rng.i8(),
        W::W => rng.i16(),
        _ => rng.i32(),
    }
}

fn gen_u64(rng: &mut Rng) -> u64 {
    match rng.below(7) {
        0 => 0,
        1 => rng.below(100) + 1,
        2 => u32::MAX as u64 - rng.below(3),
        3 => rng.next() as u32 as u64,
        4 => (-(rng.below(1000) as i64) - 1) as u64,
        5 => (rng.next() as i32 as i64) as u64,
        _ => rng.next(),
    }
}

/// Items of every form, at position `pos` in a function of at least `pos + 64` bytes: each
/// register in each register field, each width, the rest random.
fn gen_items(rng: &mut Rng) -> Vec<Item> {
    let mut v = Vec::new();
    let pos_target = |rng: &mut Rng| rng.below(2000) as u32 + 1;
    v.extend([
        Item::PushRbp,
        Item::WinPrologue,
        Item::WinEpilogue,
        Item::CallRax,
        Item::CallMemRax,
        Item::JmpRax,
        Item::TestAl,
        Item::TestRax,
        Item::Leave,
        Item::Ret,
        Item::Ud2,
        Item::LoadTableEntry,
        Item::AddRaxRcx,
    ]);
    for v32 in [0, 1, 127, 128, 255, 4096, 0x7fff_ffff, 0x8000_0000, u32::MAX] {
        v.push(Item::SubRsp(v32));
        v.push(Item::AddRsp(v32));
    }
    for r in REGS {
        for _ in 0..6 {
            v.push(Item::SetReg(r, gen_u64(rng)));
        }
        v.push(Item::SetReg(r, 0));
        v.push(Item::SetReg(r, i32::MIN as i64 as u64));
        v.push(Item::SetReg(r, 1 << 32));
        v.push(Item::Lea(r, gen_ref(rng)));
        for d in REGS {
            if rng.below(3) == 0 {
                v.push(Item::Mov(d, r));
            }
        }
    }
    for _ in 0..12 {
        v.push(Item::Call(gen_ref(rng)));
        v.push(Item::CallMem(gen_ref(rng)));
        v.push(Item::LoadRip(gen_ref(rng)));
        v.push(Item::Jmp(gen_ref(rng)));
        v.push(Item::LeaTable(pos_target(rng)));
    }
    for k in [0u8, 1, 16, 127, 128, 255] {
        v.push(Item::CtrSub(k));
        v.push(Item::CallR11(k));
    }
    for cond in [Cond::Always].into_iter().chain(CONDS) {
        for _ in 0..2 {
            v.push(Item::Branch { cond, target: pos_target(rng), long: true });
        }
    }
    for w in WS {
        for r in USABLE {
            let sx = matches!(w, W::B | W::W) && rng.bool();
            v.push(Item::Ld { w, sx, dst: r, m: gen_m(rng) });
            v.push(Item::St { w, src: r, m: gen_m(rng) });
            v.push(Item::Alu { op: rng.pick(&ALUS), w, reg: r, rm: gen_rm(rng) });
            v.push(Item::AluImm { op: rng.pick(&ALUS), w, rm: Rm::Reg(r), imm: imm_for(rng, w) });
            v.push(Item::AluImm { op: rng.pick(&ALUS), w, rm: Rm::Mem(M { base: r, disp: rng.i32() }), imm: imm_for(rng, w) });
            v.push(Item::Alu { op: rng.pick(&ALUS), w, reg: rng.pick(&USABLE), rm: Rm::Reg(r) });
        }
        for _ in 0..6 {
            v.push(Item::StImm { w, m: gen_m(rng), imm: imm_for(rng, w) });
        }
        for op in ALUS {
            v.push(Item::AluImm { op, w, rm: gen_rm(rng), imm: imm_for(rng, w) });
        }
    }
    for r in USABLE {
        v.push(Item::LeaM { dst: r, m: gen_m(rng) });
        v.push(Item::LeaM { dst: rng.pick(&USABLE), m: M { base: r, disp: rng.i32() } });
        for w in DQ {
            v.push(Item::Imul { w, reg: r, rm: gen_rm(rng) });
            v.push(Item::ImulImm { w, reg: r, rm: gen_rm(rng), imm: rng.i32() });
            v.push(Item::Shift { op: rng.pick(&SHS), w, reg: r, amt: rng.pick(&[0, 1, 2, 31, 32, 63, 64, 200]) });
        }
        v.push(Item::Movd { to_xmm: rng.bool(), x: rng.below(8) as u8, r });
        v.push(Item::TestM8(M { base: r, disp: rng.i32() }));
        v.push(Item::Setcc { cond: rng.pick(&CONDS), m: M { base: r, disp: rng.i32() } });
    }
    for cond in CONDS {
        v.push(Item::Setcc { cond, m: gen_m(rng) });
    }
    for _ in 0..6 {
        v.push(Item::TestM8(gen_m(rng)));
    }
    for size in [4u8, 8, 16] {
        for x in 0..8u8 {
            v.push(Item::Sse { st: rng.bool(), size, x, m: M::frame(rng.i32()) });
        }
    }
    v
}

/// The function a vector's item sits in: `len` bytes, zero but for the item at `pos`.
struct Placed {
    pos: u32,
    len: u32,
    bytes: Vec<u8>,
    relocs: Vec<Reloc>,
}

impl Placed {
    fn code(&self, bytes: &[u8]) -> Vec<u8> {
        let mut code = vec![0; self.len as usize];
        code[self.pos as usize..][..bytes.len()].copy_from_slice(bytes);
        code
    }

    /// The linked bytes of the item, at `CODE + pos`.
    fn linked(&self) -> Vec<u8> {
        let mut b = self.bytes.clone();
        for r in &self.relocs {
            let at = (r.at - self.pos) as usize;
            let d = addr_of(r.to).wrapping_sub(CODE + r.at as u64 + 4) as i32;
            b[at..at + 4].copy_from_slice(&d.to_le_bytes());
        }
        b
    }
}

fn place(item: &Item, pos: u32, len: u32) -> Placed {
    let (mut bytes, mut relocs) = (Vec::new(), Vec::new());
    item.write(pos, &mut bytes, &mut relocs);
    Placed { pos, len: len.max(pos + bytes.len() as u32 + 1), bytes, relocs }
}

/// The Rust decoder's reading of `code` at `pos`: the item and its length.
fn decode(code: &[u8], pos: u32, relocs: Option<&[Reloc]>, sp: Option<u32>) -> Option<(Item, u32)> {
    let fields = match relocs {
        Some(rs) => Fields::Relocs(rs),
        None => Fields::Linked { addr: CODE, record: Some(RECORD), resolver: &Link },
    };
    let mut c = Cursor::new(code, fields);
    c.pos = pos;
    c.sp_frame = sp;
    c.item().ok().map(|i| (i, c.pos - pos))
}

/// The item's references all resolve back from their linked addresses.
fn linkable(item: &Item) -> bool {
    !matches!(
        item,
        Item::Lea(_, Ref::RecCtr) | Item::Call(Ref::RecCtr) | Item::CallMem(Ref::RecCtr) | Item::LoadRip(Ref::RecCtr) | Item::Jmp(Ref::RecCtr)
    )
}

// JSON in the form of the Lean types' derived `ToJson`/`FromJson`.

fn reg(r: Reg) -> String {
    format!("\"{}\"", format!("{r:?}").to_lowercase())
}

fn lower_first(s: &str) -> String {
    let mut c = s.chars();
    let f = c.next().unwrap();
    f.to_lowercase().chain(c).collect()
}

fn cond(c: Cond) -> String {
    format!("\"{}\"", lower_first(&format!("{c:?}")))
}

fn w(w: W) -> String {
    format!("\"{}\"", format!("{w:?}").to_lowercase())
}

fn m(m: M) -> String {
    format!("{{\"base\":{},\"disp\":{}}}", reg(m.base), m.disp)
}

fn rm(r: Rm) -> String {
    match r {
        Rm::Reg(r) => format!("{{\"reg\":{{\"r\":{}}}}}", reg(r)),
        Rm::Mem(x) => format!("{{\"mem\":{{\"m\":{}}}}}", m(x)),
    }
}

fn rf(r: Ref) -> String {
    match r {
        Ref::Handler(op) => format!("{{\"handler\":{{\"op\":{}}}}}", op as u16),
        Ref::Probe => "\"probe\"".into(),
        Ref::Func(Func(f)) => format!("{{\"func\":{{\"f\":{f}}}}}"),
        Ref::Sym(Sym(s)) => format!("{{\"sym\":{{\"s\":{s}}}}}"),
        Ref::Site(Site(s)) => format!("{{\"site\":{{\"s\":{s}}}}}"),
        Ref::Const(Const(k)) => format!("{{\"const\":{{\"k\":{k}}}}}"),
        Ref::Data(Data(d)) => format!("{{\"data\":{{\"d\":{d}}}}}"),
        Ref::Ro(o) => format!("{{\"ro\":{{\"off\":{o}}}}}"),
        Ref::Rec => "\"record\"".into(),
        Ref::RecCtr => "\"recordCtr\"".into(),
    }
}

fn item(i: &Item) -> String {
    let c = |name: &str, fields: &[(&str, String)]| {
        let fs: Vec<String> = fields.iter().map(|(k, v)| format!("\"{k}\":{v}")).collect();
        format!("{{\"{name}\":{{{}}}}}", fs.join(","))
    };
    let alu = |a: Alu| format!("\"{}\"", format!("{a:?}").to_lowercase());
    let sh = |s: Sh| format!("\"{}\"", format!("{s:?}").to_lowercase());
    match *i {
        Item::PushRbp => "\"pushRbp\"".into(),
        Item::WinPrologue => "\"winPrologue\"".into(),
        Item::WinEpilogue => "\"winEpilogue\"".into(),
        Item::SubRsp(v) => c("subRsp", &[("v", v.to_string())]),
        Item::AddRsp(v) => c("addRsp", &[("v", v.to_string())]),
        Item::SetReg(r, v) => c("setReg", &[("r", reg(r)), ("v", v.to_string())]),
        Item::Lea(r, to) => c("lea", &[("r", reg(r)), ("to", rf(to))]),
        Item::LeaTable(t) => c("leaTable", &[("t", t.to_string())]),
        Item::Mov(d, s) => c("mov", &[("dst", reg(d)), ("src", reg(s))]),
        Item::Call(to) => c("call", &[("to", rf(to))]),
        Item::CallMem(to) => c("callMem", &[("to", rf(to))]),
        Item::CallRax => "\"callRax\"".into(),
        Item::CtrSub(k) => c("ctrSub", &[("k", k.to_string())]),
        Item::CallR11(d) => c("callR11", &[("d", d.to_string())]),
        Item::LoadRip(to) => c("loadRip", &[("to", rf(to))]),
        Item::CallMemRax => "\"callMemRax\"".into(),
        Item::JmpRax => "\"jmpRax\"".into(),
        Item::Jmp(to) => c("jmp", &[("to", rf(to))]),
        Item::Branch { cond: k, target, long } => c("branch", &[("cond", cond(k)), ("target", target.to_string()), ("long", long.to_string())]),
        Item::TestAl => "\"testAl\"".into(),
        Item::TestRax => "\"testRax\"".into(),
        Item::Leave => "\"leave\"".into(),
        Item::Ret => "\"ret\"".into(),
        Item::Ud2 => "\"ud2\"".into(),
        Item::LoadTableEntry => "\"loadTableEntry\"".into(),
        Item::AddRaxRcx => "\"addRaxRcx\"".into(),
        Item::Nop(n) => c("nop", &[("n", n.to_string())]),
        Item::Int3 => "\"int3\"".into(),
        Item::TableEntry { base, target } => c("tableEntry", &[("base", base.to_string()), ("target", target.to_string())]),
        Item::Ld { w: x, sx, dst, m: y } => c("ld", &[("w", w(x)), ("sx", sx.to_string()), ("dst", reg(dst)), ("m", m(y))]),
        Item::St { w: x, src, m: y } => c("st", &[("w", w(x)), ("src", reg(src)), ("m", m(y))]),
        Item::StImm { w: x, m: y, imm } => c("stImm", &[("w", w(x)), ("m", m(y)), ("imm", imm.to_string())]),
        Item::LeaM { dst, m: y } => c("leaM", &[("dst", reg(dst)), ("m", m(y))]),
        Item::Alu { op, w: x, reg: r, rm: y } => c("alu", &[("op", alu(op)), ("w", w(x)), ("reg", reg(r)), ("rm", rm(y))]),
        Item::AluImm { op, w: x, rm: y, imm } => c("aluImm", &[("op", alu(op)), ("w", w(x)), ("rm", rm(y)), ("imm", imm.to_string())]),
        Item::Imul { w: x, reg: r, rm: y } => c("imul", &[("w", w(x)), ("reg", reg(r)), ("rm", rm(y))]),
        Item::ImulImm { w: x, reg: r, rm: y, imm } => c("imulImm", &[("w", w(x)), ("reg", reg(r)), ("rm", rm(y)), ("imm", imm.to_string())]),
        Item::Shift { op, w: x, reg: r, amt } => c("shift", &[("op", sh(op)), ("w", w(x)), ("reg", reg(r)), ("amt", amt.to_string())]),
        Item::Setcc { cond: k, m: y } => c("setcc", &[("cond", cond(k)), ("m", m(y))]),
        Item::TestM8(y) => c("testM8", &[("m", m(y))]),
        Item::Sse { st, size, x, m: y } => c("sse", &[("st", st.to_string()), ("size", size.to_string()), ("x", x.to_string()), ("m", m(y))]),
        Item::Movd { to_xmm, x, r } => c("movd", &[("toXmm", to_xmm.to_string()), ("x", x.to_string()), ("r", reg(r))]),
    }
}

fn hex(b: &[u8]) -> String {
    b.iter().map(|x| format!("{x:02x}")).collect()
}

fn relocs(rs: &[Reloc]) -> String {
    let v: Vec<String> = rs.iter().map(|r| format!("{{\"pos\":{},\"to\":{}}}", r.at, rf(r.to))).collect();
    format!("[{}]", v.join(","))
}

fn opt_u32(v: Option<u32>) -> String {
    v.map_or("null".into(), |v| v.to_string())
}

fn result(r: Option<(Item, u32)>) -> String {
    match r {
        Some((i, n)) => format!("{{\"item\":{},\"n\":{n}}}", item(&i)),
        None => "null".into(),
    }
}

/// An encoding vector: the item at `pos`, its bytes and relocations, and its linked bytes (if
/// its references resolve back). `sp`: the item is the frame-pointer form of what is encoded
/// as `item.sp_frame(F)` and decoded with `sp_frame = Some(F)`.
fn enc_vector(out: &mut Vec<String>, i: &Item, pos: u32, len: u32, sp: Option<u32>) -> Placed {
    let enc = sp.map_or(*i, |f| i.sp_frame(f));
    let p = place(&enc, pos, len);
    let element = !matches!(i, Item::Nop(_) | Item::Int3 | Item::TableEntry { .. });
    // Linked, a branch within the function must stay inside it.
    let inside = match *i {
        Item::Branch { target, long: true, .. } | Item::LeaTable(target) => target >= 1 && target < p.len,
        _ => true,
    };
    let linked = element && linkable(i) && inside;
    if element {
        let code = p.code(&p.bytes);
        assert_eq!(decode(&code, pos, Some(&p.relocs), sp), Some((*i, p.bytes.len() as u32)), "{i:?} at {pos}");
        if linked {
            assert_eq!(decode(&p.code(&p.linked()), pos, None, sp), Some((*i, p.bytes.len() as u32)), "{i:?} at {pos} (linked)");
        }
    }
    out.push(format!(
        "{{\"k\":\"enc\",\"item\":{},\"pos\":{pos},\"len\":{},\"sp\":{},\"bytes\":\"{}\",\"relocs\":{},\"linked\":{}}}",
        item(i),
        p.len,
        opt_u32(sp),
        hex(&p.bytes),
        relocs(&p.relocs),
        if linked { format!("\"{}\"", hex(&p.linked())) } else { "null".into() }
    ));
    p
}

/// A decoding vector: what the Rust decoder makes of `bytes` at `pos` in a function of `len`
/// bytes, with the relocations `rs` (or linked, `rs` `None`).
fn dec_vector(out: &mut Vec<String>, p: &Placed, bytes: &[u8], len: u32, rs: Option<&[Reloc]>, sp: Option<u32>) {
    let mut code = vec![0; len as usize];
    let n = bytes.len().min((len - p.pos) as usize);
    code[p.pos as usize..][..n].copy_from_slice(&bytes[..n]);
    let r = decode(&code, p.pos, rs, sp);
    out.push(format!(
        "{{\"k\":\"dec\",\"pos\":{},\"len\":{len},\"sp\":{},\"bytes\":\"{}\",\"relocs\":{},\"result\":{}}}",
        p.pos,
        opt_u32(sp),
        hex(&bytes[..n]),
        rs.map_or("null".into(), relocs),
        result(r)
    ));
}

const INTERESTING: [u8; 20] =
    [0x40, 0x41, 0x44, 0x45, 0x48, 0x49, 0x4c, 0x4d, 0x42, 0x66, 0x0f, 0x24, 0x25, 0x05, 0x04, 0x84, 0x44, 0xc0, 0x00, 0xff];

/// Mutations of an encoding: a byte replaced or a bit flipped, a prefix added or dropped, the
/// code cut short, a relocation moved, dropped or added.
fn mutate(rng: &mut Rng, out: &mut Vec<String>, p: &Placed, sp: Option<u32>, linked: bool) {
    let base = if linked { p.linked() } else { p.bytes.clone() };
    for _ in 0..3 {
        let mut b = base.clone();
        let mut rs = p.relocs.clone();
        let mut len = p.len;
        match rng.below(8) {
            0 | 1 => {
                let j = rng.below(b.len() as u64) as usize;
                b[j] = rng.next() as u8;
            }
            2 => {
                let j = rng.below(b.len() as u64) as usize;
                b[j] = rng.pick(&INTERESTING);
            }
            3 => {
                let j = rng.below(b.len() as u64) as usize;
                b[j] ^= 1 << rng.below(8);
            }
            4 => {
                b.insert(0, rng.pick(&INTERESTING));
                for r in &mut rs {
                    r.at += 1;
                }
                len += 1;
            }
            5 => {
                b.remove(0);
                for r in &mut rs {
                    r.at = r.at.saturating_sub(1).max(p.pos);
                }
            }
            6 => len = p.pos + rng.below(b.len() as u64) as u32,
            _ => match rs.first_mut() {
                Some(r) if rng.bool() => r.at = r.at.wrapping_add(rng.pick(&[1, u32::MAX])),
                Some(_) => rs.clear(),
                None => rs.push(Reloc { at: p.pos + rng.below(b.len() as u64) as u32, to: gen_ref(rng) }),
            },
        }
        dec_vector(out, p, &b, len.max(p.pos), (!linked).then_some(&rs[..]), sp);
    }
}

fn osr_vectors(rng: &mut Rng, out: &mut Vec<String>) {
    for k in 0..40 {
        let n = rng.below(4) as usize + (k == 0) as usize;
        let entries: Vec<Option<osr::OsrEntry>> = (0..n)
            .map(|_| {
                (rng.below(4) != 0).then(|| osr::OsrEntry {
                    landing: rng.below(5000) as u32,
                    moves: (0..rng.below(4))
                        .map(|_| (-(rng.below(3000) as i32) - 1, -(rng.below(3000) as i32) - 1, rng.pick(&[1, 2, 3, 4, 7, 8, 15, 16, 24])))
                        .collect(),
                })
            })
            .collect();
        let f_aot = rng.pick(&[0, 16, 32, 64, 4096, 8192]) + 16 * rng.below(8) as u32;
        let f_jit = if rng.bool() { f_aot } else { rng.pick(&[0, 16, 48, 128, 6000]) + 16 * rng.below(8) as u32 };
        let fp = rng.bool();
        let mode = Mode { fp_arg: true, frame_pointer: fp, align_loops: false, pe: false, counters: false };
        let at = rng.below(10000) as u32;
        let code = osr::osr_code(&entries, f_aot, f_jit, mode, at);
        let es: Vec<String> = entries
            .iter()
            .map(|e| match e {
                None => "null".into(),
                Some(e) => {
                    let ms: Vec<String> = e.moves.iter().map(|(a, b, c)| format!("[{a},{b},{c}]")).collect();
                    format!("{{\"landing\":{},\"moves\":[{}]}}", e.landing, ms.join(","))
                }
            })
            .collect();
        let probes: Vec<String> = code.probes.iter().map(|p| p.to_string()).collect();
        out.push(format!(
            "{{\"k\":\"osr\",\"entries\":[{}],\"fAot\":{f_aot},\"fJit\":{f_jit},\"fp\":{fp},\"at\":{at},\"code\":\"{}\",\"probes\":[{}]}}",
            es.join(","),
            hex(&code.code),
            probes.join(",")
        ));
    }
}

fn vectors() -> String {
    let mut rng = Rng(0x5eed_1ea4_0086_0001);
    let mut out = Vec::new();
    for i in gen_items(&mut rng) {
        let pos = rng.below(300) as u32;
        let len = match i {
            Item::Branch { target, .. } | Item::LeaTable(target) => target + 1,
            _ => 0,
        };
        let p = enc_vector(&mut out, &i, pos, len, None);
        mutate(&mut rng, &mut out, &p, None, false);
        if linkable(&i) && rng.below(3) == 0 {
            mutate(&mut rng, &mut out, &p, None, true);
        }
        // Without a frame pointer: the frame slot as `[rsp + F + d]`.
        if i.mem().is_some_and(|m| m.base == Reg::Rbp) {
            let f = rng.pick(&[0, 8, 16, 120, 128, 4096]) + 8 * rng.below(4) as u32;
            let p = enc_vector(&mut out, &i, pos, len, Some(f));
            mutate(&mut rng, &mut out, &p, Some(f), false);
        }
    }
    // Short branches, at both ends of their reach; branches outside the function (unlinked
    // only); padding, `int3` and table entries.
    for cond in [Cond::Always].into_iter().chain(CONDS) {
        for d in [-128i32, -2, 0, 1, 127] {
            let pos = 200 + rng.below(100) as u32;
            let i = Item::Branch { cond, target: (pos + 2).wrapping_add(d as u32), long: false };
            let p = enc_vector(&mut out, &i, pos, 0, None);
            mutate(&mut rng, &mut out, &p, None, false);
        }
        let i = Item::Branch { cond, target: u32::MAX - rng.below(100) as u32, long: true };
        let mut rs = Vec::new();
        let mut b = Vec::new();
        i.write(50, &mut b, &mut rs);
        assert_eq!(decode(&place(&i, 50, 0).code(&b), 50, Some(&[]), None), Some((i, b.len() as u32)));
        enc_vector(&mut out, &i, 50, 0, None);
    }
    for n in 1..=9 {
        enc_vector(&mut out, &Item::Nop(n), rng.below(100) as u32, 0, None);
    }
    enc_vector(&mut out, &Item::Int3, 3, 0, None);
    for _ in 0..8 {
        let (base, target) = (rng.below(4000) as u32, rng.next() as u32);
        enc_vector(&mut out, &Item::TableEntry { base, target }, rng.below(100) as u32 * 4, 0, None);
    }
    osr_vectors(&mut rng, &mut out);
    let mut s = String::new();
    s.push_str("/-\nGenerated by `vm/bytecode/tests/lean_x86_vectors.rs` (`RYO_LEAN_GEN=1 cargo test --test\nlean_x86_vectors` in `vm/`): the Rust encoder's and decoder's results the Lean tests in\n`RyoTest/X86.lean` check `Ryo.X86` against. Do not edit.\n-/\n\nnamespace RyoTest.X86Vectors\n\ndef json : String := r#\"[\n");
    for (k, v) in out.iter().enumerate() {
        let sep = if k + 1 == out.len() { "" } else { "," };
        writeln!(s, "{v}{sep}").unwrap();
    }
    s.push_str("]\"#\n\nend RyoTest.X86Vectors\n");
    s
}

#[test]
fn lean_x86_vectors() {
    let path = concat!(env!("CARGO_MANIFEST_DIR"), "/../../lean/RyoTest/X86Vectors.lean");
    let want = vectors();
    if std::env::var_os("RYO_LEAN_GEN").is_some_and(|v| v == "1") {
        std::fs::write(path, want).unwrap();
        return;
    }
    let have = std::fs::read_to_string(path).unwrap_or_default();
    assert!(have == want, "{path} is out of date: regenerate it with RYO_LEAN_GEN=1 cargo test --test lean_x86_vectors");
}
