//! Cross-checks the JIT's x86-64 encoder against GNU objdump: every instruction is encoded on
//! its own, the concatenation disassembled, and each decoded instruction compared with the
//! expected Intel-syntax text and length.

use std::process::Command;

use ryo_bytecode::asm::Ref;
use ryo_bytecode::full::Opcode;
use ryo_bytecode::jit::x86::*;

const OBJDUMP: &str = "/usr/bin/objdump";

fn reg(r: R, w: u8) -> String {
    const Q: [&str; 8] = ["rax", "rcx", "rdx", "rbx", "rsp", "rbp", "rsi", "rdi"];
    const D: [&str; 8] = ["eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi"];
    const W: [&str; 8] = ["ax", "cx", "dx", "bx", "sp", "bp", "si", "di"];
    const B: [&str; 8] = ["al", "cl", "dl", "bl", "spl", "bpl", "sil", "dil"];
    let n = r.num() as usize;
    if n < 8 {
        return [B, W, D, Q][w.trailing_zeros() as usize][n].to_string();
    }
    format!("r{n}{}", ["b", "w", "d", ""][w.trailing_zeros() as usize])
}

fn ptr(w: u8) -> &'static str {
    match w {
        1 => "BYTE PTR ",
        2 => "WORD PTR ",
        4 => "DWORD PTR ",
        8 => "QWORD PTR ",
        16 => "XMMWORD PTR ",
        _ => "",
    }
}

fn mem(m: Mem, w: u8) -> String {
    let inner = match m {
        Mem::Base { base, index, disp } => {
            let mut s = reg(base, 8);
            if let Some((i, sc)) = index {
                s += &format!("+{}*{sc}", reg(i, 8));
            }
            if disp > 0 {
                s += &format!("+{disp:#x}");
            } else if disp == 0 && base.num() & 7 == 5 {
                s += "+0x0";
            } else if disp < 0 {
                s += &format!("-{:#x}", -(disp as i64));
            }
            s
        }
        _ => "rip+0x0".to_string(),
    };
    format!("{}[{inner}]", ptr(w))
}

fn hex(v: i64, w: u8) -> String {
    let m = if w == 8 { u64::MAX } else { (1u64 << (w * 8)) - 1 };
    format!("{:#x}", v as u64 & m)
}

fn regs() -> impl Iterator<Item = R> {
    (0..16).map(R::from_num)
}

fn mems() -> Vec<Mem> {
    let mut v = vec![];
    for b in regs() {
        for d in [0, 8, -128, 127, 128, -0x1000] {
            v.push(Mem::base(b, d));
        }
    }
    for b in [R::Rax, R::Rsp, R::Rbp, R::R12, R::R13, R::R15] {
        for i in regs().filter(|&i| i != R::Rsp) {
            for (s, d) in [(1, 0), (2, 8), (4, -128), (8, 0x1000)] {
                v.push(Mem::Base { base: b, index: Some((i, s)), disp: d });
            }
        }
    }
    v.push(Mem::Rip(Ref::Handler(Opcode::from_u16(0).unwrap())));
    v
}

/// A few memory operands for the forms where the full set would be slow.
fn some_mems() -> Vec<Mem> {
    vec![
        Mem::base(R::Rsp, 8),
        Mem::base(R::Rbp, 0),
        Mem::base(R::R12, -128),
        Mem::base(R::R13, 128),
        Mem::base(R::Rdi, 0),
        Mem::Base { base: R::R9, index: Some((R::R14, 8)), disp: -0x1000 },
        Mem::Rip(Ref::Probe),
    ]
}

struct Case {
    x: X86,
    want: String,
}

#[derive(Default)]
struct Cases(Vec<Case>);

impl Cases {
    fn add(&mut self, want: String, f: impl FnOnce(&mut X86)) {
        let mut x = X86::default();
        f(&mut x);
        self.0.push(Case { x, want });
    }
}

fn norm(s: &str) -> String {
    let s = s.split('#').next().unwrap();
    s.split_whitespace().collect::<Vec<_>>().join(" ")
}

#[test]
fn encoder_matches_objdump() {
    if !std::path::Path::new(OBJDUMP).exists() {
        eprintln!("note: {OBJDUMP} not found; skipping the x86 encoder cross-check");
        return;
    }
    let mut c = Cases::default();
    let ws = [1u8, 2, 4, 8];
    let alus = [(Alu::Add, "add"), (Alu::Or, "or"), (Alu::And, "and"), (Alu::Sub, "sub"), (Alu::Xor, "xor"), (Alu::Cmp, "cmp")];
    let all_mems = mems();
    for w in ws {
        for d in regs() {
            for s in regs() {
                c.add(format!("mov {},{}", reg(d, w), reg(s, w)), |x| x.mov(w, Rm::R(d), Rm::R(s)));
            }
            for &m in &all_mems {
                c.add(format!("mov {},{}", reg(d, w), mem(m, w)), |x| x.mov(w, Rm::R(d), Rm::M(m)));
                c.add(format!("mov {},{}", mem(m, w), reg(d, w)), |x| x.mov(w, Rm::M(m), Rm::R(d)));
            }
            for (op, n) in alus {
                for s in [R::Rax, R::Rsp, R::Rdi, R::R8, R::R12, R::R15] {
                    c.add(format!("{n} {},{}", reg(d, w), reg(s, w)), |x| x.alu(op, w, Rm::R(d), Rm::R(s)));
                }
                for imm in [0i64, 1, -1, 127, -128, 128, 0x1234] {
                    let imm = if w == 1 { imm as i8 as i64 } else { imm };
                    c.add(format!("{n} {},{}", reg(d, w), hex(imm, w)), |x| x.alu_imm(op, w, Rm::R(d), imm));
                }
                for m in some_mems() {
                    c.add(format!("{n} {},{}", reg(d, w), mem(m, w)), |x| x.alu(op, w, Rm::R(d), Rm::M(m)));
                    c.add(format!("{n} {},{}", mem(m, w), reg(d, w)), |x| x.alu(op, w, Rm::M(m), Rm::R(d)));
                    if !matches!(m, Mem::Rip(_)) {
                        c.add(format!("{n} {},{}", mem(m, w), hex(-5, w)), |x| x.alu_imm(op, w, Rm::M(m), -5));
                        c.add(format!("{n} {},{}", mem(m, w), hex(300, w)), |x| x.alu_imm(op, w, Rm::M(m), 300));
                    }
                }
            }
            for imm in [0u64, 1, 0x7fff_ffff, 0x8000_0000, 0xffff_ffff, 0x1_0000_0000, u64::MAX, i64::MIN as u64, 0x1122334455667788] {
                let v = if w == 8 { imm } else { imm & ((1u64 << (w * 8)) - 1) };
                let name = if w == 8 && v > u32::MAX as u64 && v as i64 as i32 as i64 != v as i64 { "movabs" } else { "mov" };
                let shown = if w == 8 && v <= u32::MAX as u64 { hex(v as i64, 4) } else { hex(v as i64, w) };
                let dst = if w == 8 && v <= u32::MAX as u64 { reg(d, 4) } else { reg(d, w) };
                c.add(format!("{name} {dst},{shown}"), |x| x.mov_imm(w, Rm::R(d), v));
            }
            for m in some_mems().into_iter().filter(|m| !matches!(m, Mem::Rip(_))) {
                for imm in [0u64, 0x7fff_ffff, u64::MAX] {
                    let v = if w == 8 { imm } else { imm & ((1u64 << (w * 8)) - 1) };
                    c.add(format!("mov {},{}", mem(m, w), hex(v as i64, w)), |x| x.mov_imm(w, Rm::M(m), v));
                }
                c.add(format!("test {},{}", mem(m, w), hex(-2, w)), |x| x.test_imm(w, Rm::M(m), -2));
                c.add(format!("shl {},0x3", mem(m, w)), |x| x.shift_imm(Shift::Shl, w, Rm::M(m), 3));
            }
            for s in regs() {
                c.add(format!("test {},{}", reg(d, w), reg(s, w)), |x| x.test(w, Rm::R(d), s));
            }
            c.add(format!("test {},{}", reg(d, w), hex(0x40, w)), |x| x.test_imm(w, Rm::R(d), 0x40));
            for (op, n) in [(Shift::Shl, "shl"), (Shift::Shr, "shr"), (Shift::Sar, "sar")] {
                c.add(format!("{n} {},0x5", reg(d, w)), |x| x.shift_imm(op, w, Rm::R(d), 5));
            }
            c.add(format!("neg {}", reg(d, w)), |x| x.neg(w, Rm::R(d)));
            c.add(format!("not {}", reg(d, w)), |x| x.not(w, Rm::R(d)));
            if w != 1 {
                for s in regs() {
                    c.add(format!("imul {},{}", reg(d, w), reg(s, w)), |x| x.imul(w, d, Rm::R(s)));
                    c.add(format!("imul {},{},{}", reg(d, w), reg(s, w), hex(-3, w)), |x| x.imul_imm(w, d, Rm::R(s), -3));
                    c.add(format!("imul {},{},{}", reg(d, w), reg(s, w), hex(1000, w)), |x| x.imul_imm(w, d, Rm::R(s), 1000));
                }
                for m in some_mems() {
                    c.add(format!("imul {},{}", reg(d, w), mem(m, w)), |x| x.imul(w, d, Rm::M(m)));
                }
            }
        }
    }
    for d in regs() {
        for s in regs() {
            for from in [1u8, 2] {
                c.add(format!("movzx {},{}", reg(d, 4), reg(s, from)), |x| x.movzx(d, from, Rm::R(s)));
                c.add(format!("movsx {},{}", reg(d, 8), reg(s, from)), |x| x.movsx(d, from, Rm::R(s)));
            }
            c.add(format!("mov {},{}", reg(d, 4), reg(s, 4)), |x| x.movzx(d, 4, Rm::R(s)));
            c.add(format!("mov {},{}", reg(d, 8), reg(s, 8)), |x| x.movzx(d, 8, Rm::R(s)));
            c.add(format!("movsxd {},{}", reg(d, 8), reg(s, 4)), |x| x.movsx(d, 4, Rm::R(s)));
            c.add(format!("mov {},{}", reg(d, 8), reg(s, 8)), |x| x.movsx(d, 8, Rm::R(s)));
            c.add(format!("xchg {},{}", reg(d, 8), reg(s, 8)), |x| x.xchg(d, s));
            if s != R::Rsp {
                let m = Mem::Base { base: d, index: Some((s, 4)), disp: 0 };
                c.add(format!("movsxd {},{}", reg(d, 8), mem(m, 4)), |x| x.movsxd_table(d, d, s));
            }
        }
        for m in some_mems() {
            for from in [1u8, 2, 4] {
                c.add(format!("{} {},{}", if from == 4 { "mov" } else { "movzx" }, reg(d, 4), mem(m, from)), |x| x.movzx(d, from, Rm::M(m)));
                c.add(format!("{} {},{}", if from == 4 { "movsxd" } else { "movsx" }, reg(d, 8), mem(m, from)), |x| x.movsx(d, from, Rm::M(m)));
            }
        }
        for &m in &all_mems {
            c.add(format!("lea {},{}", reg(d, 8), mem(m, 0)), |x| x.lea(d, m));
        }
        for xr in 0..16u8 {
            c.add(format!("movq xmm{xr},{}", reg(d, 8)), |x| x.movq_to_xmm(xr, Rm::R(d), 8));
            c.add(format!("movd xmm{xr},{}", reg(d, 4)), |x| x.movq_to_xmm(xr, Rm::R(d), 4));
            c.add(format!("movq {},xmm{xr}", reg(d, 8)), |x| x.movq_from_xmm(Rm::R(d), xr, 8));
            c.add(format!("movd {},xmm{xr}", reg(d, 4)), |x| x.movq_from_xmm(Rm::R(d), xr, 4));
        }
        for m in some_mems() {
            c.add(format!("movq xmm9,{}", mem(m, 8)), |x| x.movq_to_xmm(9, Rm::M(m), 8));
            c.add(format!("movd xmm2,{}", mem(m, 4)), |x| x.movq_to_xmm(2, Rm::M(m), 4));
            c.add(format!("movq {},xmm9", mem(m, 8)), |x| x.movq_from_xmm(Rm::M(m), 9, 8));
            c.add(format!("movd {},xmm2", mem(m, 4)), |x| x.movq_from_xmm(Rm::M(m), 2, 4));
            c.add(format!("call {}", mem(m, 8)), |x| x.call_mem(m));
            c.add(format!("jmp {}", mem(m, 8)), |x| x.jmp_mem(m));
            c.add(format!("sete {}", mem(m, 1)), |x| x.setcc(Cc::E, Rm::M(m)));
        }
        let ccs = ["o", "no", "b", "ae", "e", "ne", "be", "a", "s", "ns", "p", "np", "l", "ge", "le", "g"];
        for (i, cc) in Cc::ALL.into_iter().enumerate() {
            assert_eq!(cc.negate().negate(), cc);
            c.add(format!("set{} {}", ccs[i], reg(d, 1)), |x| x.setcc(cc, Rm::R(d)));
        }
        c.add(format!("call {}", reg(d, 8)), |x| x.call_r(d));
        c.add(format!("jmp {}", reg(d, 8)), |x| x.jmp_r(d));
        c.add(format!("push {}", reg(d, 8)), |x| x.push(d));
        c.add(format!("pop {}", reg(d, 8)), |x| x.pop(d));
    }
    c.add("ret".into(), |x| x.ret());
    c.add("ud2".into(), |x| x.ud2());
    c.add("int3".into(), |x| x.int3());
    for i in 0..4u16 {
        let to = Ref::Handler(Opcode::from_u16(i).unwrap());
        c.add("call REL".into(), |x| x.call(to));
        c.add("jmp REL".into(), |x| x.jmp(to));
    }

    // Relocation fields: the 4 zero bytes ending the instruction.
    for case in &c.0 {
        for f in case.x.relocs.iter().map(|r| r.at).chain(case.x.label_fixups.iter().map(|l| l.0)) {
            assert_eq!(f as usize + 4, case.x.code.len(), "{}", case.want);
            assert_eq!(&case.x.code[f as usize..], &[0; 4]);
        }
        let rip = case.want.contains("rip") || case.want.ends_with("REL");
        assert_eq!(case.x.relocs.len(), rip as usize, "{}", case.want);
    }
    // jcc forms checked by hand (objdump prints absolute targets).
    let mut j = X86::default();
    j.jcc(Some(Cc::Ne), -2, false);
    j.jcc(Some(Cc::L), 0x100, true);
    j.jcc(None, 5, false);
    j.jcc(None, -0x200, true);
    assert_eq!(j.code, [0x75, 0xfe, 0x0f, 0x8c, 0, 1, 0, 0, 0xeb, 5, 0xe9, 0, 0xfe, 0xff, 0xff]);
    assert_eq!((X86::jcc_len(false), X86::jcc_len(true), X86::jmp_len(false), X86::jmp_len(true)), (2, 6, 2, 5));

    let mut bytes = vec![];
    for case in &c.0 {
        bytes.extend_from_slice(&case.x.code);
    }
    let path = std::env::temp_dir().join(format!("ryo_jit_x86_{}.bin", std::process::id()));
    std::fs::write(&path, &bytes).unwrap();
    let out = Command::new(OBJDUMP).args(["-D", "-b", "binary", "-m", "i386:x86-64", "-M", "intel"]).arg(&path).output().unwrap();
    std::fs::remove_file(&path).ok();
    assert!(out.status.success());
    let text = String::from_utf8(out.stdout).unwrap();
    // Lines are `  off:\tbytes\tinsn`; long encodings continue on lines without the insn.
    let mut got: Vec<(usize, String)> = vec![];
    for line in text.lines() {
        let parts: Vec<&str> = line.split('\t').collect();
        let Some(off) = parts[0].trim().strip_suffix(':') else { continue };
        let Ok(off) = usize::from_str_radix(off, 16) else { continue };
        if parts.len() >= 3 {
            got.push((off, norm(parts[2])));
        }
    }
    let mut at = 0;
    let mut bad = 0;
    for (i, case) in c.0.iter().enumerate() {
        let (off, ref dis) = got[i];
        assert_eq!(off, at, "boundary before {:?} ({})", case.want, i);
        let want = norm(&case.want);
        let ok = if let Some(op) = want.strip_suffix(" REL") { dis.starts_with(op) } else { *dis == want };
        if !ok {
            bad += 1;
            if bad < 60 {
                eprintln!("{i}: want {want:?}, got {dis:?} ({:02x?})", case.x.code);
            }
        }
        at += case.x.code.len();
    }
    assert_eq!(got.len(), c.0.len());
    assert_eq!(bad, 0, "{} of {} instructions differ", bad, c.0.len());
}
