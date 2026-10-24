//! A small x86-64 machine-code encoder for the SSA tier's back end: the forms register
//! allocation and instruction selection need, each in its shortest standard encoding.
//!
//! Widths `w` are operand sizes in bytes (1, 2, 4 or 8). Byte forms take a REX prefix whenever
//! a byte register is spl/bpl/sil/dil, so they never mean ah/ch/dh/bh.

use alloc::vec::Vec;

use crate::asm::{Ref, Reloc};

/// A general-purpose register by its x86 number (rax 0 … r15 15).
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
#[repr(u8)]
pub enum R {
    Rax = 0,
    Rcx,
    Rdx,
    Rbx,
    Rsp,
    Rbp,
    Rsi,
    Rdi,
    R8,
    R9,
    R10,
    R11,
    R12,
    R13,
    R14,
    R15,
}

impl R {
    const ALL: [R; 16] =
        [R::Rax, R::Rcx, R::Rdx, R::Rbx, R::Rsp, R::Rbp, R::Rsi, R::Rdi, R::R8, R::R9, R::R10, R::R11, R::R12, R::R13, R::R14, R::R15];

    pub fn from_num(n: u8) -> R {
        R::ALL[n as usize]
    }

    pub fn num(self) -> u8 {
        self as u8
    }
}

/// A memory operand.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Mem {
    /// `[base + index*scale + disp]`, scale 1, 2, 4 or 8; index never rsp.
    Base { base: R, index: Option<(R, u8)>, disp: i32 },
    /// `[rip + target]`: a 4-byte PC-relative field resolved through a relocation.
    Rip(Ref),
    /// `[rip + label]`: a PC-relative field to a label of the function's own code, resolved
    /// by the caller (see [`X86::label_fixups`]).
    RipLabel(u32),
}

impl Mem {
    pub fn base(base: R, disp: i32) -> Mem {
        Mem::Base { base, index: None, disp }
    }
}

/// A register or memory operand.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Rm {
    R(R),
    M(Mem),
}

/// The classic group-1 ops.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Alu {
    Add,
    Or,
    And,
    Sub,
    Xor,
    Cmp,
}

impl Alu {
    /// The ModRM `/digit` (and `8 * digit` is the base of the `op r/m, r` opcodes).
    fn digit(self) -> u8 {
        match self {
            Alu::Add => 0,
            Alu::Or => 1,
            Alu::And => 4,
            Alu::Sub => 5,
            Alu::Xor => 6,
            Alu::Cmp => 7,
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Shift {
    Shl,
    Shr,
    Sar,
}

/// Condition codes (the low nibble of jcc/setcc).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(u8)]
pub enum Cc {
    O = 0,
    No,
    B,
    Ae,
    E,
    Ne,
    Be,
    A,
    S,
    Ns,
    P,
    Np,
    L,
    Ge,
    Le,
    G,
}

impl Cc {
    pub const ALL: [Cc; 16] =
        [Cc::O, Cc::No, Cc::B, Cc::Ae, Cc::E, Cc::Ne, Cc::Be, Cc::A, Cc::S, Cc::Ns, Cc::P, Cc::Np, Cc::L, Cc::Ge, Cc::Le, Cc::G];

    pub fn negate(self) -> Cc {
        Cc::ALL[(self as u8 ^ 1) as usize]
    }
}

/// Machine code being written.
#[derive(Default, Clone, Debug)]
pub struct X86 {
    pub code: Vec<u8>,
    /// Fields of [`Mem::Rip`] and of the call/jmp forms that take a [`Ref`]: `at` is the
    /// 4-byte field's offset in `code`; the field holds 0 until linked (the linker writes
    /// `target - (field + 4)`). Every such field ends its instruction: forms with an
    /// immediate after the displacement reject rip-relative operands.
    pub relocs: Vec<Reloc>,
    /// Fields of [`Mem::RipLabel`], as (field offset, label): the caller writes
    /// `label_pos - (field + 4)`.
    pub label_fixups: Vec<(u32, u32)>,
}

/// Whether `w` byte operations on `rm` need a REX prefix to name spl/bpl/sil/dil.
fn byte_rex(w: u8, r: u8) -> bool {
    w == 1 && (4..8).contains(&r)
}

fn imm_bytes(w: u8, imm: i64) -> ([u8; 8], usize) {
    (imm.to_le_bytes(), w.min(4) as usize)
}

impl X86 {
    pub fn pos(&self) -> u32 {
        self.code.len() as u32
    }

    pub fn bytes(&mut self, b: &[u8]) {
        self.code.extend_from_slice(b);
    }

    /// One instruction: `[66] [REX] opc modrm [sib] [disp] [imm]`. `reg` is the ModRM reg
    /// field (a register number or a `/digit`); `force_rex` asks for a REX prefix even when
    /// no bit is set (byte registers 4–7).
    #[allow(clippy::too_many_arguments)]
    fn insn(&mut self, p66: bool, w: bool, force_rex: bool, opc: &[u8], reg: u8, rm: Rm, imm: &[u8]) {
        let (b, x, force) = match rm {
            Rm::R(r) => (r.num() >> 3, 0, false),
            Rm::M(Mem::Base { base, index, .. }) => (base.num() >> 3, index.map_or(0, |(i, _)| i.num() >> 3), false),
            Rm::M(_) => (0, 0, false),
        };
        let rex = 0x40 | (w as u8) << 3 | (reg >> 3) << 2 | x << 1 | b;
        if p66 {
            self.code.push(0x66);
        }
        if rex != 0x40 || force_rex || force {
            self.code.push(rex);
        }
        self.code.extend_from_slice(opc);
        let reg = (reg & 7) << 3;
        match rm {
            Rm::R(r) => self.code.push(0xc0 | reg | (r.num() & 7)),
            Rm::M(Mem::Base { base, index, disp }) => {
                let bl = base.num() & 7;
                let md = if disp == 0 && bl != 5 {
                    0
                } else if disp as i8 as i32 == disp {
                    0x40
                } else {
                    0x80
                };
                match index {
                    None if bl != 4 => self.code.push(md | reg | bl),
                    _ => {
                        let (i, s) = match index {
                            Some((i, s)) => {
                                assert!(i != R::Rsp, "rsp can't be an index");
                                let s = match s {
                                    1 => 0,
                                    2 => 1,
                                    4 => 2,
                                    8 => 3,
                                    _ => panic!("bad scale {s}"),
                                };
                                (i.num() & 7, s)
                            }
                            None => (4, 0),
                        };
                        self.code.push(md | reg | 4);
                        self.code.push(s << 6 | i << 3 | bl);
                    }
                }
                match md {
                    0x40 => self.code.push(disp as u8),
                    0x80 => self.code.extend_from_slice(&disp.to_le_bytes()),
                    _ => {}
                }
            }
            Rm::M(m) => {
                assert!(imm.is_empty(), "rip-relative operand with a trailing immediate");
                self.code.push(reg | 5);
                let at = self.pos();
                match m {
                    Mem::Rip(to) => self.relocs.push(Reloc { at, to }),
                    Mem::RipLabel(l) => self.label_fixups.push((at, l)),
                    Mem::Base { .. } => unreachable!(),
                }
                self.code.extend_from_slice(&[0; 4]);
            }
        }
        self.code.extend_from_slice(imm);
    }

    /// A sized form whose byte variant is `opc8` and other widths `opc8 + 1`.
    fn sized(&mut self, w: u8, opc8: u8, reg: u8, reg_is_gpr: bool, rm: Rm, imm: &[u8]) {
        assert!(matches!(w, 1 | 2 | 4 | 8), "bad width {w}");
        let force = w == 1 && ((reg_is_gpr && byte_rex(w, reg)) || matches!(rm, Rm::R(r) if byte_rex(w, r.num())));
        let opc = if w == 1 { opc8 } else { opc8 + 1 };
        self.insn(w == 2, w == 8, force, &[opc], reg, rm, imm);
    }

    pub fn mov(&mut self, w: u8, dst: Rm, src: Rm) {
        match (dst, src) {
            (_, Rm::R(s)) => self.sized(w, 0x88, s.num(), true, dst, &[]),
            (Rm::R(d), Rm::M(_)) => self.sized(w, 0x8a, d.num(), true, src, &[]),
            (Rm::M(_), Rm::M(_)) => panic!("mov mem, mem"),
        }
    }

    pub fn mov_imm(&mut self, w: u8, dst: Rm, imm: u64) {
        match dst {
            Rm::R(r) => {
                if w == 8 && imm > u32::MAX as u64 && imm as i64 as i32 as i64 == imm as i64 {
                    return self.sized(8, 0xc6, 0, false, dst, &(imm as u32).to_le_bytes());
                }
                let (w, n) = if w == 8 && imm > u32::MAX as u64 { (8, 8) } else { (w.min(4), w.min(4) as usize) };
                if w == 2 {
                    self.code.push(0x66);
                }
                let rex = 0x40 | ((w == 8) as u8) << 3 | r.num() >> 3;
                if rex != 0x40 || byte_rex(w, r.num()) {
                    self.code.push(rex);
                }
                self.code.push(if w == 1 { 0xb0 } else { 0xb8 } | (r.num() & 7));
                self.code.extend_from_slice(&imm.to_le_bytes()[..n]);
            }
            Rm::M(_) => {
                debug_assert!(w != 8 || imm as i64 as i32 as i64 == imm as i64, "mov qword [m], imm doesn't fit i32");
                let (b, n) = imm_bytes(w, imm as i64);
                self.sized(w, 0xc6, 0, false, dst, &b[..n]);
            }
        }
    }

    pub fn movzx(&mut self, dst: R, from: u8, src: Rm) {
        match from {
            1 | 2 => {
                let force = from == 1 && matches!(src, Rm::R(r) if byte_rex(1, r.num()));
                self.insn(false, false, force, &[0x0f, 0xb5 + from], dst.num(), src, &[]);
            }
            4 | 8 => self.mov(from, Rm::R(dst), src),
            _ => panic!("bad width {from}"),
        }
    }

    pub fn movsx(&mut self, dst: R, from: u8, src: Rm) {
        match from {
            1 | 2 => self.insn(false, true, false, &[0x0f, 0xbd + from], dst.num(), src, &[]),
            4 => self.insn(false, true, false, &[0x63], dst.num(), src, &[]),
            8 => self.mov(8, Rm::R(dst), src),
            _ => panic!("bad width {from}"),
        }
    }

    pub fn alu(&mut self, op: Alu, w: u8, dst: Rm, src: Rm) {
        let base = op.digit() << 3;
        match (dst, src) {
            (_, Rm::R(s)) => self.sized(w, base, s.num(), true, dst, &[]),
            (Rm::R(d), Rm::M(_)) => self.sized(w, base + 2, d.num(), true, src, &[]),
            (Rm::M(_), Rm::M(_)) => panic!("alu mem, mem"),
        }
    }

    pub fn alu_imm(&mut self, op: Alu, w: u8, dst: Rm, imm: i64) {
        debug_assert!(w != 8 || imm as i32 as i64 == imm, "64-bit alu immediate doesn't fit i32");
        if w == 1 {
            return self.sized(1, 0x80, op.digit(), false, dst, &[imm as u8]);
        }
        if imm as i8 as i64 == imm {
            self.insn(w == 2, w == 8, false, &[0x83], op.digit(), dst, &[imm as u8]);
        } else {
            let (b, n) = imm_bytes(w, imm);
            self.sized(w, 0x80, op.digit(), false, dst, &b[..n]);
        }
    }

    pub fn test(&mut self, w: u8, a: Rm, b: R) {
        self.sized(w, 0x84, b.num(), true, a, &[]);
    }

    pub fn test_imm(&mut self, w: u8, a: Rm, imm: i32) {
        let (b, n) = imm_bytes(w, imm as i64);
        self.sized(w, 0xf6, 0, false, a, &b[..n]);
    }

    pub fn imul(&mut self, w: u8, dst: R, src: Rm) {
        assert!(matches!(w, 2 | 4 | 8), "bad imul width {w}");
        self.insn(w == 2, w == 8, false, &[0x0f, 0xaf], dst.num(), src, &[]);
    }

    pub fn imul_imm(&mut self, w: u8, dst: R, src: Rm, imm: i32) {
        assert!(matches!(w, 2 | 4 | 8), "bad imul width {w}");
        if imm as i8 as i32 == imm {
            self.insn(w == 2, w == 8, false, &[0x6b], dst.num(), src, &[imm as u8]);
        } else {
            let (b, n) = imm_bytes(w, imm as i64);
            self.insn(w == 2, w == 8, false, &[0x69], dst.num(), src, &b[..n]);
        }
    }

    pub fn shift_imm(&mut self, op: Shift, w: u8, dst: Rm, amt: u8) {
        let d = match op {
            Shift::Shl => 4,
            Shift::Shr => 5,
            Shift::Sar => 7,
        };
        self.sized(w, 0xc0, d, false, dst, &[amt]);
    }

    pub fn neg(&mut self, w: u8, dst: Rm) {
        self.sized(w, 0xf6, 3, false, dst, &[]);
    }

    pub fn not(&mut self, w: u8, dst: Rm) {
        self.sized(w, 0xf6, 2, false, dst, &[]);
    }

    pub fn setcc(&mut self, cc: Cc, dst: Rm) {
        let force = matches!(dst, Rm::R(r) if byte_rex(1, r.num()));
        self.insn(false, false, force, &[0x0f, 0x90 | cc as u8], 0, dst, &[]);
    }

    pub fn lea(&mut self, dst: R, m: Mem) {
        self.insn(false, true, false, &[0x8d], dst.num(), Rm::M(m), &[]);
    }

    pub fn movq_to_xmm(&mut self, x: u8, src: Rm, w: u8) {
        debug_assert!(matches!(w, 2 | 4 | 8) && x < 16);
        self.insn(true, w == 8, false, &[0x0f, 0x6e], x, src, &[]);
    }

    pub fn movq_from_xmm(&mut self, dst: Rm, x: u8, w: u8) {
        debug_assert!(matches!(w, 2 | 4 | 8) && x < 16);
        self.insn(true, w == 8, false, &[0x0f, 0x7e], x, dst, &[]);
    }

    fn rel32(&mut self, opc: u8, to: Ref) {
        self.code.push(opc);
        let at = self.pos();
        self.relocs.push(Reloc { at, to });
        self.code.extend_from_slice(&[0; 4]);
    }

    pub fn call(&mut self, to: Ref) {
        self.rel32(0xe8, to);
    }

    pub fn jmp(&mut self, to: Ref) {
        self.rel32(0xe9, to);
    }

    pub fn call_mem(&mut self, m: Mem) {
        self.insn(false, false, false, &[0xff], 2, Rm::M(m), &[]);
    }

    pub fn call_r(&mut self, r: R) {
        self.insn(false, false, false, &[0xff], 2, Rm::R(r), &[]);
    }

    pub fn jmp_r(&mut self, r: R) {
        self.insn(false, false, false, &[0xff], 4, Rm::R(r), &[]);
    }

    pub fn jmp_mem(&mut self, m: Mem) {
        self.insn(false, false, false, &[0xff], 4, Rm::M(m), &[]);
    }

    pub fn ret(&mut self) {
        self.code.push(0xc3);
    }

    pub fn ud2(&mut self) {
        self.code.extend_from_slice(&[0x0f, 0x0b]);
    }

    pub fn int3(&mut self) {
        self.code.push(0xcc);
    }

    pub fn push(&mut self, r: R) {
        if r.num() >= 8 {
            self.code.push(0x41);
        }
        self.code.push(0x50 | (r.num() & 7));
    }

    pub fn pop(&mut self, r: R) {
        if r.num() >= 8 {
            self.code.push(0x41);
        }
        self.code.push(0x58 | (r.num() & 7));
    }

    pub fn xchg(&mut self, a: R, b: R) {
        self.insn(false, true, false, &[0x87], b.num(), Rm::R(a), &[]);
    }

    pub fn jcc_len(long: bool) -> u32 {
        if long { 6 } else { 2 }
    }

    pub fn jmp_len(long: bool) -> u32 {
        if long { 5 } else { 2 }
    }

    /// A conditional (or, for `None`, unconditional) jump by `rel` from its end.
    pub fn jcc(&mut self, cc: Option<Cc>, rel: i32, long: bool) {
        if !long {
            debug_assert!(rel as i8 as i32 == rel, "short jump out of range");
            self.code.push(cc.map_or(0xeb, |c| 0x70 | c as u8));
            self.code.push(rel as u8);
        } else {
            match cc {
                Some(c) => self.code.extend_from_slice(&[0x0f, 0x80 | c as u8]),
                None => self.code.push(0xe9),
            }
            self.code.extend_from_slice(&rel.to_le_bytes());
        }
    }

    /// `movsxd dst, dword [base + index*4]`.
    pub fn movsxd_table(&mut self, dst: R, base: R, index: R) {
        self.movsx(dst, 4, Rm::M(Mem::Base { base, index: Some((index, 4)), disp: 0 }));
    }
}
