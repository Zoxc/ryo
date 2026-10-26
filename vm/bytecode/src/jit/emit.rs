//! The SSA tier's back end (design/jit.md, "The SSA tier"): the JIT frame's layout,
//! instruction selection per IR instruction over the allocated locations, parallel moves on
//! edges, branch relaxation, the OSR entries, the call sites and the unwind rows.
//!
//! `r10` and `r11` are the emitter's scratch registers (never allocated): memory-to-memory
//! moves, large constants, pointers loaded from slots, and the parallel moves' cycle breaking.

use alloc::vec::Vec;

use super::Unsupported;
use super::ir::*;
use super::regalloc::{Alloc, Loc};
use super::x86::{Alu, Cc as X, Mem, R, Rm, Shift, X86};
use crate::asm::osr::{self, OsrCode};
use crate::asm::{self, CallSite, Mode, PROBE_FROM, Ref, Reloc, RetPart};
use crate::full::{ElemKind, OperandKind};
use crate::reduced::Arg;

/// The SSA tier's machine code for one function.
#[derive(Clone, Debug, Default)]
pub struct Output {
    pub code: Vec<u8>,
    pub relocs: Vec<Reloc>,
    /// Island operand arrays and switch case values ([`Ref::Ro`]), 16-aligned.
    pub rodata: Vec<u8>,
    pub call_sites: Vec<CallSite>,
    /// The body's call frame instructions, by code offset (after the CIE's `CFA = rsp + 8`).
    pub cfi: Vec<(u32, Vec<u8>)>,
    /// The OSR dispatcher and entries, placed at [`Output::osr_at`].
    pub osr: Option<OsrCode>,
    pub osr_at: u32,
    pub frame_size: u32,
    /// PE: the body's `UNWIND_INFO` ([`crate::image::pe_unwind_codes`]), which also covers the
    /// OSR code (it runs in the body's frame); [`Output::cfi`] is then empty.
    pub pe_unwind: Vec<u8>,
    /// The compilation as text (`RYO_JIT_DUMP`): the reduced code, the IR, the locations and
    /// the code.
    pub dump: Option<alloc::string::String>,
    /// How many calls through a constant pointer of the root became direct
    /// ([`super::inline::devirt`]).
    pub devirt: usize,
}

const S1: R = R::R11;
const S2: R = R::R10;
const ARGS: [R; 6] = [R::Rdi, R::Rsi, R::Rdx, R::Rcx, R::R8, R::R9];

/// The DWARF number of a register.
fn dw(r: R) -> u8 {
    match r {
        R::Rax => 0,
        R::Rdx => 1,
        R::Rcx => 2,
        R::Rbx => 3,
        R::Rsi => 4,
        R::Rdi => 5,
        R::Rbp => 6,
        R::Rsp => 7,
        r => r.num(),
    }
}

fn uleb(out: &mut Vec<u8>, v: u32) {
    asm::leb::put(out, v.into());
}

fn xcc(c: Cc) -> X {
    match c {
        Cc::Eq => X::E,
        Cc::Ne => X::Ne,
        Cc::LtS => X::L,
        Cc::LtU => X::B,
        Cc::LeS => X::Le,
        Cc::LeU => X::Be,
        Cc::GtS => X::G,
        Cc::GtU => X::A,
        Cc::GeS => X::Ge,
        Cc::GeU => X::Ae,
    }
}

fn fits32(v: i64) -> bool {
    v as i32 as i64 == v
}

/// `v`'s low `w` bytes, sign-extended.
fn sext(v: u64, w: u8) -> i64 {
    match w {
        1 => v as u8 as i8 as i64,
        2 => v as u16 as i16 as i64,
        4 => v as u32 as i32 as i64,
        _ => v as i64,
    }
}

/// An operand source.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Src {
    R(R),
    M(Mem),
    Imm(u64),
    Undef,
}

/// A piece of code being laid out.
#[derive(Clone, Debug)]
enum P {
    Code(X86),
    Br { cc: Option<X>, to: u32, long: bool },
    Bind(u32),
    Align4,
    Table(Vec<u32>),
}

/// Code with labels and relaxed branches.
#[derive(Default)]
struct Asm {
    ps: Vec<P>,
    nlabels: u32,
}

impl Asm {
    fn x(&mut self) -> &mut X86 {
        if !matches!(self.ps.last(), Some(P::Code(_))) {
            self.ps.push(P::Code(X86::default()));
        }
        let Some(P::Code(x)) = self.ps.last_mut() else { unreachable!() };
        x
    }
    /// The current position, as (piece, offset).
    fn mark(&mut self) -> (u32, u32) {
        let at = self.x().pos();
        (self.ps.len() as u32 - 1, at)
    }
    fn label(&mut self) -> u32 {
        self.nlabels += 1;
        self.nlabels - 1
    }
    fn bind(&mut self, l: u32) {
        self.ps.push(P::Bind(l));
    }
    fn br(&mut self, cc: Option<X>, to: u32) {
        self.ps.push(P::Br { cc, to, long: false });
    }

    /// Lays out the pieces: the code, its relocations, each label's position and each
    /// piece's.
    fn finish(mut self) -> (Vec<u8>, Vec<Reloc>, Vec<u32>, Vec<u32>) {
        let n = self.ps.len();
        let mut pos = alloc::vec![0u32; n + 1];
        let mut lab = alloc::vec![u32::MAX; self.nlabels as usize];
        loop {
            let mut p = 0u32;
            for (k, piece) in self.ps.iter().enumerate() {
                pos[k] = p;
                p += match piece {
                    P::Code(x) => x.pos(),
                    P::Br { cc: Some(_), long, .. } => X86::jcc_len(*long),
                    P::Br { cc: None, long, .. } => X86::jmp_len(*long),
                    P::Bind(l) => {
                        lab[*l as usize] = p;
                        0
                    }
                    P::Align4 => p.next_multiple_of(4) - p,
                    P::Table(ts) => 4 * ts.len() as u32,
                };
            }
            pos[n] = p;
            let mut changed = false;
            for k in 0..n {
                if let P::Br { cc, to, long } = &mut self.ps[k]
                    && !*long
                {
                    let len = if cc.is_some() { X86::jcc_len(false) } else { X86::jmp_len(false) };
                    let d = lab[*to as usize] as i64 - (pos[k] + len) as i64;
                    if d as i8 as i64 != d {
                        *long = true;
                        changed = true;
                    }
                }
            }
            if !changed {
                break;
            }
        }
        let mut code = Vec::with_capacity(pos[n] as usize);
        let mut relocs = Vec::new();
        for (k, piece) in self.ps.iter().enumerate() {
            match piece {
                P::Code(x) => {
                    let base = code.len();
                    code.extend_from_slice(&x.code);
                    for r in &x.relocs {
                        relocs.push(Reloc { at: r.at + base as u32, to: r.to });
                    }
                    for &(at, l) in &x.label_fixups {
                        let field = base + at as usize;
                        let d = lab[l as usize] as i64 - (field as i64 + 4);
                        code[field..field + 4].copy_from_slice(&(d as i32).to_le_bytes());
                    }
                }
                P::Br { cc, to, long } => {
                    let mut x = X86::default();
                    let len = if cc.is_some() { X86::jcc_len(*long) } else { X86::jmp_len(*long) };
                    x.jcc(*cc, (lab[*to as usize] as i64 - (pos[k] + len) as i64) as i32, *long);
                    code.extend_from_slice(&x.code);
                }
                P::Bind(_) => {}
                P::Align4 => {
                    while code.len() % 4 != 0 {
                        code.push(0xcc);
                    }
                }
                P::Table(ts) => {
                    let base = pos[k] as i64;
                    for &t in ts {
                        code.extend_from_slice(&((lab[t as usize] as i64 - base) as i32).to_le_bytes());
                    }
                }
            }
            debug_assert_eq!(code.len() as u32, pos[k + 1], "piece {k}");
        }
        (code, relocs, lab, pos)
    }
}

/// The JIT frame (offsets from `fp`).
struct Frame {
    size: u32,
    alloca: Vec<i32>,
    spill0: i32,
    scratch: i32,
    /// The callee-saved registers the code uses, each by its save's offset.
    saves: Vec<(R, i32)>,
    /// Whether the saves are pushed and popped: they sit at the frame's top (nothing pinned
    /// above them), right below `rbp`'s save or, without a frame pointer, from the slot
    /// that is the alignment padding below the return address. On PE, below the saves of
    /// `rdi` and `rsi`, which are always pushed, at `fp - 8` and `fp - 16` as in the AOT frame.
    pushed: bool,
    /// PE: where the prologue's `lea rbp, [rsp + pe_fp]` sets the frame register (the
    /// `UNWIND_INFO`'s frame offset, times 16): past the pushes, and with saves that aren't
    /// pushed, past them too, since the unwind codes address them upward from there
    /// (`u32::MAX`: no room for them).
    pe_fp: u32,
    /// No frame at all ([`layout`]): `rsp` stays where the call left it, `fp + 8`.
    frameless: bool,
}

/// Options of the back end.
#[derive(Clone, Copy, Debug, Default)]
pub struct Opts {
    /// Place moved allocas in reverse order with gaps (`RYO_JIT_SHUFFLE` for the SSA tier).
    pub stress: bool,
}

fn layout(f: &Func, al: &Alloc, mode: Mode, opts: Opts) -> Frame {
    // PE: the top 16 bytes hold `rdi` and `rsi` (the AOT code's slots for them).
    let top0 = if mode.pe { -16 } else { 0 };
    let mut top = top0;
    for a in &f.allocas {
        if a.pinned && a.kind != AllocaKind::Incoming {
            top = top.min(a.aot_off);
        }
    }
    let mut cur = top;
    let place = |cur: &mut i32, size: u32, congruent: i32| -> i32 {
        let mut o = *cur - size as i32;
        o -= (o - congruent).rem_euclid(16);
        *cur = o;
        o
    };
    // The saves, packed at the top: pushed when nothing is pinned above them. Each is
    // 8-aligned: `DW_CFA_offset` counts in 8 bytes (a pinned alloca may end `top` anywhere).
    let pushed = top == top0;
    if pushed && !mode.frame_pointer {
        cur = 8;
    }
    cur -= cur.rem_euclid(8);
    let mut saves = Vec::new();
    // PE saves that aren't pushed: the unwind codes address them upward from at most 240
    // bytes below `rbp` ([`Frame::pe_fp`]), so they go into the 8-byte slots there that no
    // pinned alloca covers, or into the home space the Win64 caller reserves above the
    // return address (`fp + 16` to `fp + 48`), if no stack argument is read there.
    let mut pe_slots = Vec::new();
    if mode.pe && !pushed {
        let home = !f.allocas.iter().any(|a| a.kind == AllocaKind::Incoming && a.aot_off < 48 && a.aot_off + a.size as i32 > 16);
        if home {
            pe_slots.extend([16, 24, 32, 40]);
        }
        let free =
            |o: i32| !f.allocas.iter().any(|a| a.pinned && a.kind != AllocaKind::Incoming && o < a.aot_off + a.size as i32 && o + 8 > a.aot_off);
        pe_slots.extend((1..=28).map(|j| -16 - 8 * j).filter(|&o| free(o)));
    }
    let mut pe_short = false;
    for (k, &r) in al.saved.iter().enumerate() {
        if mode.pe && !pushed {
            match pe_slots.get(k) {
                Some(&o) => saves.push((r, o)),
                None => pe_short = true,
            }
            continue;
        }
        cur -= 8;
        saves.push((r, cur));
    }
    // The rest of the frame below the PE saves.
    cur = saves.iter().map(|s| s.1).fold(cur, i32::min);
    cur = cur.min(0);
    let mut alloca = alloc::vec![0i32; f.allocas.len()];
    let mut order: Vec<usize> = (0..f.allocas.len()).collect();
    if opts.stress {
        order.reverse();
    }
    let mut out_size = 0;
    for &k in &order {
        let a = &f.allocas[k];
        alloca[k] = match a.kind {
            AllocaKind::Promoted => 0,
            AllocaKind::Incoming => a.aot_off,
            // Inlined callees' outgoing areas share the bottom of the frame.
            AllocaKind::Outgoing => {
                out_size = out_size.max(a.size);
                0
            }
            AllocaKind::Memory if a.pinned => a.aot_off,
            AllocaKind::Memory => {
                if opts.stress {
                    cur -= 32;
                }
                place(&mut cur, a.size, a.aot_off)
            }
        };
    }
    // A leaf (no calls, no OSR entries) without a frame pointer needs no 16-byte alignment,
    // nor the handlers' scratch area. Not on PE: its frame always saves `rdi` and `rsi`, and
    // its unwind codes assume the frame register.
    let leaf = !mode.pe
        && !mode.frame_pointer
        && f.osr.is_empty()
        && f.layout.iter().all(|b| f.blocks[b.idx()].insts.iter().all(|i| !f.insts[i.idx()].op.is_call()));
    let spill0 = if al.spills > 0 { place(&mut cur, 8 * al.spills, 0) } else { cur };
    let scratch = if leaf && f.scratch == 0 { cur } else { place(&mut cur, f.scratch.max(8), 0) };
    // PE: the callees' 32 bytes of shadow space (VM functions, natives and islands take the
    // Win64 convention; the `sysv64` handlers don't), unless the stack arguments cover it.
    if mode.pe && f.insts.iter().any(|i| matches!(i.op, Op::Call(_) | Op::Island(_))) {
        out_size = out_size.max(32);
    }
    let mut size = (-cur) as u32 + out_size;
    size = if leaf && size < PROBE_FROM { size.next_multiple_of(8) } else { size.next_multiple_of(16) };
    // Nothing in the frame: not even the alignment slot below the return address.
    let frameless = leaf && size == 0 && saves.is_empty();
    let pe_fp = if !mode.pe {
        0
    } else if pushed {
        (16 + 8 * saves.len() as u32).next_multiple_of(16)
    } else if pe_short {
        u32::MAX
    } else {
        (saves.iter().map(|&(_, o)| (-o).max(0) as u32).max().unwrap_or(0).max(16)).next_multiple_of(16)
    };
    for (k, a) in f.allocas.iter().enumerate() {
        if a.kind == AllocaKind::Outgoing {
            alloca[k] = -(size as i32);
        }
    }
    Frame { size, alloca, spill0, scratch, saves, pushed, pe_fp, frameless }
}

struct E<'a> {
    f: &'a Func,
    al: &'a Alloc,
    mode: Mode,
    fr: Frame,
    a: Asm,
    rodata: Vec<u8>,
    code_consts: &'a [u8],
    /// Call sites: (mark of the call, its length, the pad's label, catch).
    sites: Vec<((u32, u32), u32, Option<u32>, bool)>,
    /// Unwind rows: (mark, instructions).
    cfi: Vec<((u32, u32), Vec<u8>)>,
    uses: Vec<u32>,
    /// The condition the flags hold an overflow in after the last [`Op::Ovf`].
    ovf_cc: Option<X>,
    /// The move stubs of edges into cold blocks: emitted after the last block.
    cold_stubs: Vec<(u32, Edge)>,
    /// PE: the prologue's operations, by their end in the code, and its length.
    pe_ops: Vec<(u32, crate::image::PeUnwindOp)>,
    pe_prologue: u32,
}

impl<'a> E<'a> {
    fn fp_mem(&self, off: i32) -> Mem {
        if self.mode.frame_pointer { Mem::base(R::Rbp, off) } else { Mem::base(R::Rsp, self.sp_to_fp() + off) }
    }

    /// `fp - rsp` in the body, without a frame pointer.
    fn sp_to_fp(&self) -> i32 {
        if self.fr.frameless { -8 } else { self.fr.size as i32 }
    }

    fn src(&self, v: Value) -> Src {
        match self.f.def(v) {
            ValueDef::Const(c) => return Src::Imm(c),
            ValueDef::Undef => return Src::Undef,
            _ => {}
        }
        match self.al.loc[v.idx()] {
            Loc::Reg(r) => Src::R(r),
            Loc::Spill(n) => Src::M(self.fp_mem(self.fr.spill0 + 8 * n as i32)),
            Loc::None => Src::Undef,
        }
    }

    /// Where the value goes: a register or memory (`None`: nowhere, unused).
    fn dst(&self, v: Value) -> Option<Rm> {
        match self.al.loc[v.idx()] {
            Loc::Reg(r) => Some(Rm::R(r)),
            Loc::Spill(n) => Some(Rm::M(self.fp_mem(self.fr.spill0 + 8 * n as i32))),
            Loc::None => None,
        }
    }

    /// Loads `v` (8 bytes) into `r`.
    fn load(&mut self, r: R, v: Value) {
        let s = self.src(v);
        self.load_src(r, s);
    }

    fn load_src(&mut self, r: R, s: Src) {
        match s {
            Src::R(x) if x == r => {}
            Src::R(x) => self.a.x().mov(8, Rm::R(r), Rm::R(x)),
            Src::M(m) => self.a.x().mov(8, Rm::R(r), Rm::M(m)),
            Src::Imm(c) => self.a.x().mov_imm(8, Rm::R(r), c),
            Src::Undef => {}
        }
    }

    /// `v` in a register: its own, or loaded into `scratch`.
    fn reg(&mut self, v: Value, scratch: R) -> R {
        match self.src(v) {
            Src::R(r) => r,
            s => {
                self.load_src(scratch, s);
                scratch
            }
        }
    }

    /// Stores `r` (8 bytes) to `v`'s location.
    fn put(&mut self, v: Value, r: R) {
        match self.dst(v) {
            Some(Rm::R(d)) if d == r => {}
            Some(d) => self.a.x().mov(8, d, Rm::R(r)),
            None => {}
        }
    }

    /// The register to compute `v` in: its own if it isn't one of `avoid`'s, else `S1`.
    fn work(&self, v: Value, avoid: &[Value]) -> R {
        match self.al.loc[v.idx()] {
            Loc::Reg(r) if !avoid.iter().any(|&a| self.src(a) == Src::R(r)) => r,
            _ => S1,
        }
    }

    /// A parallel move: every destination gets its source's old value.
    fn moves(&mut self, mut ms: Vec<(Rm, Src)>) {
        ms.retain(|(d, s)| {
            !matches!(s, Src::Undef)
                && !match (d, s) {
                    (Rm::R(a), Src::R(b)) => a == b,
                    (Rm::M(a), Src::M(b)) => a == b,
                    _ => false,
                }
        });
        let same = |d: &Rm, s: &Src| match (d, s) {
            (Rm::R(a), Src::R(b)) => a == b,
            (Rm::M(a), Src::M(b)) => a == b,
            _ => false,
        };
        while !ms.is_empty() {
            let free = (0..ms.len()).find(|&i| !ms.iter().enumerate().any(|(j, (_, s))| j != i && same(&ms[i].0, s)));
            match free {
                Some(i) => {
                    let (d, s) = ms.remove(i);
                    self.mov(d, s);
                }
                None => {
                    // A cycle: free the first destination by saving its value in `S2`.
                    let d = ms[0].0;
                    let s = match d {
                        Rm::R(r) => Src::R(r),
                        Rm::M(m) => Src::M(m),
                    };
                    self.mov(Rm::R(S2), s);
                    for m in ms.iter_mut() {
                        if same(&d, &m.1) {
                            m.1 = Src::R(S2);
                        }
                    }
                }
            }
        }
    }

    fn mov(&mut self, d: Rm, s: Src) {
        match (d, s) {
            (_, Src::Undef) => {}
            (Rm::R(r), s) => self.load_src(r, s),
            (Rm::M(m), Src::R(r)) => self.a.x().mov(8, Rm::M(m), Rm::R(r)),
            (Rm::M(m), Src::M(n)) => {
                self.a.x().mov(8, Rm::R(S1), Rm::M(n));
                self.a.x().mov(8, Rm::M(m), Rm::R(S1));
            }
            (Rm::M(m), Src::Imm(c)) if fits32(c as i64) => self.a.x().mov_imm(8, Rm::M(m), c),
            (Rm::M(m), Src::Imm(c)) => {
                self.a.x().mov_imm(8, Rm::R(S1), c);
                self.a.x().mov(8, Rm::M(m), Rm::R(S1));
            }
        }
    }

    /// The second operand of an ALU instruction at width `w`: a register, memory, or an
    /// immediate (loaded into `S2` if it doesn't fit).
    fn alu_src(&mut self, v: Value, w: u8) -> Result<Rm, i64> {
        match self.src(v) {
            Src::R(r) => Ok(Rm::R(r)),
            Src::M(m) => Ok(Rm::M(m)),
            Src::Imm(c) => {
                let i = sext(c, w);
                if fits32(i) {
                    Err(i)
                } else {
                    self.a.x().mov_imm(8, Rm::R(S2), c);
                    Ok(Rm::R(S2))
                }
            }
            Src::Undef => Err(0),
        }
    }

    fn fp_into(&mut self, r: R) {
        if self.mode.frame_pointer {
            self.a.x().mov(8, Rm::R(r), Rm::R(R::Rbp));
        } else {
            let m = Mem::base(R::Rsp, self.sp_to_fp());
            self.a.x().lea(r, m);
        }
    }

    fn slot_off(&self, s: SlotRef) -> i32 {
        match s {
            SlotRef::Alloca(a, k) => self.fr.alloca[a.idx()] + k,
            SlotRef::Scratch(k) => self.fr.scratch + k as i32,
        }
    }

    fn ro(&mut self, bytes: &[u8], align: usize) -> u32 {
        let off = self.rodata.len().next_multiple_of(align);
        self.rodata.resize(off, 0);
        self.rodata.extend_from_slice(bytes);
        off as u32
    }

    /// Registers a call site at `m` of `len` bytes.
    fn site(&mut self, m: (u32, u32), len: u32, site: Site, pad: Option<u32>) {
        match site {
            Site::None => {}
            Site::Continue => self.sites.push((m, len, None, false)),
            Site::Pad { catch } => self.sites.push((m, len, Some(pad.expect("a pad")), catch)),
        }
    }

    fn call_with_site(&mut self, site: Site, pad: Option<u32>, emit: impl FnOnce(&mut X86)) {
        let m = self.a.mark();
        emit(self.a.x());
        let len = self.a.x().pos() - m.1;
        self.site(m, len, site, pad);
    }

    /// The prologue: frame, saves, and the entry's arguments into their locations. Pushed
    /// saves ([`Frame::pushed`]) come right after the frame pointer's, before the stack
    /// probe and the `sub` of the rest of the frame.
    fn prologue(&mut self) {
        if self.mode.pe {
            return self.prologue_pe();
        }
        let size = self.fr.size;
        let fp = self.mode.frame_pointer;
        if fp {
            self.a.x().push(R::Rbp);
            let m = self.a.mark();
            self.cfi.push((m, alloc::vec![0x0e, 16, 0x86, 2]));
            self.a.x().mov(8, Rm::R(R::Rbp), Rm::R(R::Rsp));
            let m = self.a.mark();
            self.cfi.push((m, alloc::vec![0x0d, 6]));
        }
        if self.fr.frameless {
            return;
        }
        let mut alloc_ = if fp { size } else { size + 8 };
        if self.fr.pushed {
            for (k, (r, o)) in self.fr.saves.clone().into_iter().enumerate() {
                self.a.x().push(r);
                let m = self.a.mark();
                let mut v = Vec::new();
                if !fp {
                    v.push(0x0e);
                    uleb(&mut v, 16 + 8 * k as u32);
                }
                save_rule(&mut v, r, o);
                self.cfi.push((m, v));
            }
            alloc_ -= 8 * self.fr.saves.len() as u32;
        }
        if size >= PROBE_FROM {
            self.a.x().mov_imm(4, Rm::R(R::Rax), alloc_ as u64);
            let far = self.mode.far_rt;
            self.a.x().call_rt(Ref::Probe, far);
        }
        if alloc_ != 0 {
            self.a.x().alu_imm(Alu::Sub, 8, Rm::R(R::Rsp), alloc_ as i64);
        }
        if !fp && (alloc_ != 0 || !self.fr.pushed) {
            let m = self.a.mark();
            let mut v = alloc::vec![0x0e];
            uleb(&mut v, size + 16);
            self.cfi.push((m, v));
        }
        if !self.fr.pushed {
            for (r, o) in self.fr.saves.clone() {
                let m = self.fp_mem(o);
                self.a.x().mov(8, Rm::M(m), Rm::R(r));
                let mk = self.a.mark();
                let mut v = Vec::new();
                save_rule(&mut v, r, o);
                self.cfi.push((mk, v));
            }
        }
    }

    /// The PE prologue, as the AOT one (vm.md, "Frames") with the saves after `rdi`'s and
    /// `rsi`'s: `push rbp; push rdi; push rsi`, the pushed saves, `sub rsp` to
    /// [`Frame::pe_fp`] if the pushes don't reach it, `lea rbp, [rsp + pe_fp]`, the probe and
    /// the `sub` of the rest, then the saves that aren't pushed. Each operation has its
    /// unwind code; the frame register is set after the pushes, as Win64 requires, so that
    /// past it every `rsp` (OSR entries, the probe) unwinds from `rbp`.
    fn prologue_pe(&mut self) {
        use crate::image::PeUnwindOp as U;
        let (size, k) = (self.fr.size, self.fr.pe_fp);
        // The unwind codes' offsets are from the function's start: the entry block comes first.
        debug_assert!(self.a.ps.iter().all(|p| matches!(p, P::Bind(_))), "the PE prologue at the start");
        let mut ops = Vec::new();
        let mut pushed = 0;
        let pushes: Vec<R> = [R::Rbp, R::Rdi, R::Rsi].into_iter().chain(self.fr.saves.iter().map(|s| s.0).filter(|_| self.fr.pushed)).collect();
        for r in pushes {
            self.a.x().push(r);
            ops.push((self.a.x().pos(), U::Push(r.num())));
            pushed += 8;
        }
        // Below `rbp`'s save.
        pushed -= 8;
        if k > pushed {
            self.a.x().alu_imm(Alu::Sub, 8, Rm::R(R::Rsp), (k - pushed) as i64);
            ops.push((self.a.x().pos(), U::Alloc(k - pushed)));
        }
        self.a.x().lea(R::Rbp, Mem::base(R::Rsp, k as i32));
        ops.push((self.a.x().pos(), U::SetFpreg));
        let rest = size - k;
        if size >= PROBE_FROM {
            self.a.x().mov_imm(4, Rm::R(R::Rax), rest as u64);
            let far = self.mode.far_rt;
            self.a.x().call_rt(Ref::Probe, far);
        }
        if rest != 0 {
            self.a.x().alu_imm(Alu::Sub, 8, Rm::R(R::Rsp), rest as i64);
            ops.push((self.a.x().pos(), U::Alloc(rest)));
        }
        if !self.fr.pushed {
            for (r, o) in self.fr.saves.clone() {
                self.a.x().mov(8, Rm::M(Mem::base(R::Rbp, o)), Rm::R(r));
                ops.push((self.a.x().pos(), U::Save(r.num(), (o + k as i32) as u32)));
            }
        }
        self.pe_prologue = self.a.x().pos();
        self.pe_ops = ops;
    }

    /// The epilogue before `ret` or a tail jump.
    fn epilogue(&mut self) {
        if self.mode.pe {
            // `lea rsp, [rbp - 16 - 8n]` and the pops: a Win64 epilogue (after the saves'
            // loads, which are body code).
            if !self.fr.pushed {
                for (r, o) in self.fr.saves.clone() {
                    self.a.x().mov(8, Rm::R(r), Rm::M(Mem::base(R::Rbp, o)));
                }
            }
            let n = if self.fr.pushed { self.fr.saves.len() as i32 } else { 0 };
            self.a.x().lea(R::Rsp, Mem::base(R::Rbp, -16 - 8 * n));
            for (r, _) in self.fr.saves.clone().into_iter().rev().take(n as usize) {
                self.a.x().pop(r);
            }
            for r in [R::Rsi, R::Rdi, R::Rbp] {
                self.a.x().pop(r);
            }
            return;
        }
        let fp = self.mode.frame_pointer;
        if self.fr.frameless {
            return;
        }
        if !self.fr.pushed {
            for (r, o) in self.fr.saves.clone() {
                let m = self.fp_mem(o);
                self.a.x().mov(8, Rm::R(r), Rm::M(m));
            }
        }
        let n = if self.fr.pushed { self.fr.saves.len() as u32 } else { 0 };
        if fp && n == 0 {
            self.a.x().bytes(&[0xc9]);
            return;
        }
        // The frame below the pushed saves: from `rbp`, or popped by an `add`.
        let rest = if fp { self.fr.size } else { self.fr.size + 8 } - 8 * n;
        if rest != 0 {
            if fp {
                self.a.x().lea(R::Rsp, Mem::base(R::Rbp, -8 * n as i32));
            } else {
                self.a.x().alu_imm(Alu::Add, 8, Rm::R(R::Rsp), rest as i64);
            }
        }
        for (r, _) in self.fr.saves.clone().into_iter().rev().take(n as usize) {
            self.a.x().pop(r);
        }
        if fp {
            self.a.x().pop(R::Rbp);
        }
    }

    /// Moves values into the argument registers of a call: `xmm` ones first (nothing else
    /// writes them), then a parallel move of the integer ones (with the callee into `rax`).
    fn call_args(&mut self, regs: &[asm::ArgReg], args: &[Value], callee: Option<Value>) {
        for (r, &v) in regs.iter().zip(args) {
            if r.xmm {
                let s = match self.src(v) {
                    Src::R(x) => Rm::R(x),
                    Src::M(m) => Rm::M(m),
                    Src::Imm(c) => {
                        self.a.x().mov_imm(8, Rm::R(S1), c);
                        Rm::R(S1)
                    }
                    Src::Undef => continue,
                };
                self.a.x().movq_to_xmm(r.index as u8, s, if r.size == 8 { 8 } else { 4 });
            }
        }
        let mut ms = Vec::new();
        for (r, &v) in regs.iter().zip(args) {
            if !r.xmm {
                ms.push((Rm::R(int_arg(self.mode.pe, r.index)), self.src(v)));
            }
        }
        if let Some(c) = callee {
            ms.push((Rm::R(R::Rax), self.src(c)));
        }
        self.moves(ms);
        // Narrow integers zero-extended, as the AOT code loads them: native callees may rely
        // on it (`zeroext`).
        let narrow: Vec<&asm::ArgReg> =
            regs.iter().zip(args).filter(|(r, v)| !r.xmm && r.size < 8 && self.zext(**v) > r.size as u8).map(|(r, _)| r).collect();
        for r in narrow {
            let x = int_arg(self.mode.pe, r.index);
            self.a.x().movzx(x, r.size as u8, Rm::R(x));
        }
    }

    /// After a call: the results from the return registers.
    fn call_results(&mut self, parts: &[RetPart], results: &[Value]) {
        let mut ms = Vec::new();
        let mut xs = Vec::new();
        let (mut g, mut x) = (0, 0u8);
        for (p, &v) in parts.iter().zip(results) {
            if p.xmm {
                xs.push((x, v, p.size));
                x += 1;
            } else {
                if let Some(d) = self.dst(v) {
                    ms.push((d, Src::R([R::Rax, R::Rdx][g])));
                }
                g += 1;
            }
        }
        self.moves(ms);
        for (x, v, size) in xs {
            if let Some(d) = self.dst(v) {
                self.a.x().movq_from_xmm(d, x, if size == 8 { 8 } else { 4 });
            }
        }
    }

    /// Sets `r` to the handler call's argument register `k` (from `rdi`), with its slot
    /// operands' offsets patched in.
    fn hcall_arg(&mut self, h: &HCall, k: usize, r: R) -> Result<(), Unsupported> {
        let (arg, patch) = &h.regs[k];
        match *arg {
            Arg::Fp => self.fp_into(r),
            Arg::Exception => return Err(Unsupported("an exception argument")),
            Arg::Imm(mut v) => {
                for (half, p) in patch.iter().enumerate() {
                    if let Some(p) = p {
                        // A register entry ignores them: zero, for the shortest `mov`.
                        let off = if h.reg { 0 } else { self.slot_off(*p) as u32 as u64 };
                        v = if half == 0 { v & !0xffff_ffff | off } else { v & 0xffff_ffff | off << 32 };
                    }
                }
                self.a.x().mov_imm(8, Rm::R(r), v);
            }
            Arg::Const(c) => self.a.x().lea(r, Mem::Rip(Ref::Const(c))),
            Arg::Data(d) => self.a.x().lea(r, Mem::Rip(Ref::Data(d))),
            Arg::Sym(s) => self.a.x().lea(r, Mem::Rip(Ref::Sym(s))),
            Arg::Site(s) => self.a.x().lea(r, Mem::Rip(Ref::Site(s))),
            Arg::Ro(off) => {
                // A sparse switch's case values: as many as the next register says.
                let size =
                    h.h.info()
                        .operands
                        .iter()
                        .find_map(|o| match o.kind {
                            OperandKind::List(ElemKind::Case8) => Some(1),
                            OperandKind::List(ElemKind::Case16) => Some(2),
                            OperandKind::List(ElemKind::Case32) => Some(4),
                            OperandKind::List(ElemKind::Case64) => Some(8),
                            OperandKind::List(ElemKind::Case128) => Some(16),
                            _ => None,
                        })
                        .ok_or(Unsupported("a code constant argument"))?;
                let Some((Arg::Imm(n), _)) = h.regs.get(k + 1) else { return Err(Unsupported("case values")) };
                let len = (*n as usize).checked_mul(size).ok_or(Unsupported("case values"))?;
                let bytes = self.code_consts.get(off as usize..).and_then(|b| b.get(..len)).ok_or(Unsupported("case values"))?;
                let bytes = bytes.to_vec();
                let o = self.ro(&bytes, size.max(4));
                self.a.x().lea(r, Mem::Rip(Ref::Ro(o)));
            }
        }
        Ok(())
    }

    fn inst(&mut self, i: Inst, pad: Option<u32>) -> Result<(), Unsupported> {
        let id = &self.f.insts[i.idx()];
        let res: Vec<Value> = id.results().collect();
        let bd = &self.f.blocks[id.block.idx()];
        let fused = matches!(bd.term, Term::BrOvf { .. }) && bd.insts.last() == Some(&i);
        if id.op.pure() && !fused && res.iter().all(|r| self.uses[r.idx()] == 0) {
            return Ok(());
        }
        let args = id.args.clone();
        match id.op.clone() {
            Op::Bin(op @ (BinOp::DivS | BinOp::DivU | BinOp::RemS | BinOp::RemU), w) => self.divrem(op, w, args[0], args[1], res[0]),
            Op::Bin(op @ (BinOp::Shl | BinOp::ShrS | BinOp::ShrU), w) if !matches!(self.src(args[1]), Src::Imm(_)) => {
                self.shift_var(op, w, args[0], args[1], res[0])
            }
            Op::Bin(op, w) => {
                let x = res[0];
                let (mut a, mut b) = (args[0], args[1]);
                if op.commutative()
                    && self.src(b) == self.dst(x).and_then(|d| if let Rm::R(r) = d { Some(Src::R(r)) } else { None }).unwrap_or(Src::Undef)
                {
                    core::mem::swap(&mut a, &mut b);
                }
                let rd = self.work(x, &[b]);
                let ww = w.max(4);
                // Three operands: `lea` (no flags are read after a `Bin`).
                if let (BinOp::Add | BinOp::Sub, Src::R(ra)) = (op, self.src(a))
                    && ra != rd
                    && ww >= 4
                {
                    let m = match self.src(b) {
                        Src::Imm(c) if op == BinOp::Add && fits32(sext(c, ww)) => Some(Mem::base(ra, sext(c, ww) as i32)),
                        Src::Imm(c) if op == BinOp::Sub && fits32(sext(c, ww).wrapping_neg()) => {
                            Some(Mem::base(ra, sext(c, ww).wrapping_neg() as i32))
                        }
                        Src::R(rb) if op == BinOp::Add => Some(Mem::Base { base: ra, index: Some((rb, 1)), disp: 0 }),
                        _ => None,
                    };
                    if let Some(m) = m {
                        if ww == 8 {
                            self.a.x().lea(rd, m);
                        } else {
                            self.a.x().lea32(rd, m);
                        }
                        self.put(x, rd);
                        return Ok(());
                    }
                }
                match op {
                    BinOp::ShrU | BinOp::ShrS if w < 4 => {
                        let s = match self.src(a) {
                            Src::R(r) => Rm::R(r),
                            Src::M(m) => Rm::M(m),
                            Src::Imm(c) => {
                                self.a.x().mov_imm(8, Rm::R(rd), c);
                                Rm::R(rd)
                            }
                            Src::Undef => Rm::R(rd),
                        };
                        if op == BinOp::ShrU {
                            self.a.x().movzx(rd, w, s);
                        } else {
                            self.a.x().movsx(rd, w, s);
                        }
                    }
                    _ => self.load(rd, a),
                }
                match op {
                    BinOp::Add | BinOp::Sub | BinOp::And | BinOp::Or | BinOp::Xor => {
                        let alu = match op {
                            BinOp::Add => Alu::Add,
                            BinOp::Sub => Alu::Sub,
                            BinOp::And => Alu::And,
                            BinOp::Or => Alu::Or,
                            _ => Alu::Xor,
                        };
                        match self.alu_src(b, ww) {
                            Ok(s) => self.a.x().alu(alu, ww, Rm::R(rd), s),
                            Err(imm) => self.a.x().alu_imm(alu, ww, Rm::R(rd), imm),
                        }
                    }
                    BinOp::Mul => match self.alu_src(b, ww) {
                        Ok(s) => self.a.x().imul(ww, rd, s),
                        Err(imm) => self.a.x().imul_imm(ww, rd, Rm::R(rd), imm as i32),
                    },
                    BinOp::Shl | BinOp::ShrU | BinOp::ShrS => {
                        let Src::Imm(n) = self.src(b) else { unreachable!("a shift by a variable") };
                        let n = n & (8 * w as u64 - 1);
                        let sh = match op {
                            BinOp::Shl => Shift::Shl,
                            BinOp::ShrU => Shift::Shr,
                            _ => Shift::Sar,
                        };
                        let sw = if w < 4 { if op == BinOp::Shl { 4 } else { 8 } } else { w };
                        let sw = if op == BinOp::ShrU && w < 4 { 4 } else { sw };
                        self.a.x().shift_imm(sh, sw, Rm::R(rd), n as u8);
                    }
                    _ => unreachable!(),
                }
                self.put(x, rd);
            }
            Op::Ovf(op, signed, w) => {
                let cc = self.ovf(op, signed, w, &args, res[0]);
                self.ovf_cc = Some(cc);
                if let Some(d) = self.dst(res[1]) {
                    self.a.x().setcc(cc, d);
                }
            }
            Op::Ext { from, to, sx } => {
                let x = res[0];
                let rd = self.work(x, &[]);
                if to <= from || (!sx && self.zext(args[0]) <= from) {
                    self.load(rd, args[0]);
                } else {
                    self.ext_into(rd, args[0], from, sx);
                }
                self.put(x, rd);
            }
            Op::Cmp(cc, w) => {
                let x = res[0];
                self.compare(args[0], args[1], w);
                match self.dst(x) {
                    Some(d) => self.a.x().setcc(xcc(cc), d),
                    None => {}
                }
            }
            Op::PtrAdd(k) => {
                let x = res[0];
                let rd = self.work(x, &[]);
                self.load(rd, args[0]);
                if fits32(k) {
                    self.a.x().lea(rd, Mem::base(rd, k as i32));
                } else {
                    self.a.x().mov_imm(8, Rm::R(S2), k as u64);
                    self.a.x().alu(Alu::Add, 8, Rm::R(rd), Rm::R(S2));
                }
                self.put(x, rd);
            }
            Op::PtrIndex(s) => {
                let x = res[0];
                if matches!(s, 1 | 2 | 4 | 8) {
                    let rp = self.reg(args[0], S1);
                    let ri = self.reg(args[1], S2);
                    let rd = self.work(x, &[]);
                    self.a.x().lea(rd, Mem::Base { base: rp, index: Some((ri, s as u8)), disp: 0 });
                    self.put(x, rd);
                } else {
                    self.load(S1, args[1]);
                    if s <= i32::MAX as u32 {
                        self.a.x().imul_imm(8, S1, Rm::R(S1), s as i32);
                    } else {
                        self.a.x().mov_imm(8, Rm::R(S2), s as u64);
                        self.a.x().imul(8, S1, Rm::R(S2));
                    }
                    match self.alu_src(args[0], 8) {
                        Ok(p) => self.a.x().alu(Alu::Add, 8, Rm::R(S1), p),
                        Err(imm) => self.a.x().alu_imm(Alu::Add, 8, Rm::R(S1), imm),
                    }
                    self.put(x, S1);
                }
            }
            Op::RefAddr(to, ind) => {
                let x = res[0];
                let rd = self.work(x, &[]);
                match to {
                    Ref::Sym(_) => {
                        self.a.x().mov(8, Rm::R(rd), Rm::M(Mem::Rip(to)));
                        if ind {
                            self.a.x().mov(8, Rm::R(rd), Rm::M(Mem::base(rd, 0)));
                        }
                    }
                    _ => self.a.x().lea(rd, Mem::Rip(to)),
                }
                self.put(x, rd);
            }
            Op::AllocaAddr(a, k) => {
                let x = res[0];
                let rd = self.work(x, &[]);
                let m = self.fp_mem(self.fr.alloca[a.idx()] + k);
                self.a.x().lea(rd, m);
                self.put(x, rd);
            }
            Op::Load(w, k) => {
                let x = res[0];
                let rp = self.reg(args[0], S1);
                let rd = self.work(x, &[]);
                self.load_mem(rd, w, Mem::base(rp, k));
                self.put(x, rd);
            }
            Op::ALoad(a, k, w) => {
                let x = res[0];
                let rd = self.work(x, &[]);
                let m = self.fp_mem(self.fr.alloca[a.idx()] + k);
                self.load_mem(rd, w, m);
                self.put(x, rd);
            }
            Op::Store(w, k) => {
                let rp = self.reg(args[0], S1);
                self.store_mem(Mem::base(rp, k), w, args[1]);
            }
            Op::AStore(a, k, n) => {
                let m = self.fp_mem(self.fr.alloca[a.idx()] + k);
                if n.is_power_of_two() {
                    self.store_mem(m, n, args[0]);
                } else {
                    // 3, 5, 6 or 7 bytes: 4, 2, 1 pieces, shifting a copy down.
                    self.load(S2, args[0]);
                    let (mut done, mut prev) = (0u8, 0u8);
                    for c in [4u8, 2, 1] {
                        if n - done >= c {
                            if prev != 0 {
                                self.a.x().shift_imm(Shift::Shr, 8, Rm::R(S2), 8 * prev);
                            }
                            let Mem::Base { base, disp, .. } = m else { unreachable!() };
                            self.a.x().mov(c, Rm::M(Mem::base(base, disp + done as i32)), Rm::R(S2));
                            done += c;
                            prev = c;
                        }
                    }
                }
            }
            Op::OsrLoad(..) => return Err(Unsupported("an OSR load outside an OSR entry")),
            Op::LandingPad => {
                self.put(res[0], R::Rax);
            }
            Op::HCall(h) if h.reg => {
                let e = super::effects::reg_entry(h.h, self.mode).ok_or(Unsupported("a register entry"))?;
                let nin = e.nin as usize;
                // The `In` values into the first argument registers, then the data registers
                // after them (which no `In` value's source is in any more).
                let ms = args.iter().enumerate().map(|(k, &v)| (Rm::R(ARGS[k]), self.src(v))).collect();
                self.moves(ms);
                for j in 0..e.ndata as usize {
                    self.hcall_arg(&h, e.data[j] as usize, ARGS[nin + j])?;
                }
                let hh = h.h;
                let far = self.mode.far_rt;
                self.call_with_site(h.site, pad, |x| x.call_rt(Ref::RegHandler(hh), far));
                let ms = res.iter().enumerate().filter_map(|(k, &v)| Some((self.dst(v)?, Src::R([R::Rax, R::Rdx][k])))).collect();
                self.moves(ms);
            }
            Op::HCall(h) => {
                for (k, &v) in args.iter().enumerate() {
                    let m = self.fp_mem(self.fr.scratch + h.ins[k] as i32);
                    let s = self.src(v);
                    self.mov(Rm::M(m), s);
                }
                for k in 0..h.regs.len() {
                    self.hcall_arg(&h, k, ARGS[k])?;
                }
                let hh = h.h;
                let far = self.mode.far_rt;
                self.call_with_site(h.site, pad, |x| x.call_rt(Ref::Handler(hh), far));
                let nout = h.nout as usize;
                if h.ret {
                    self.put(res[nout], R::Rax);
                }
                // At their widths: a wider load of what the handler just stored narrower would
                // miss the store forwarding.
                for (k, &o) in h.outs.iter().enumerate() {
                    let m = self.fp_mem(self.fr.scratch + o as i32);
                    let w = self.f.w(res[k]);
                    match self.dst(res[k]) {
                        Some(Rm::R(r)) => self.load_mem(r, w, m),
                        Some(d) => {
                            self.load_mem(S1, w, m);
                            self.a.x().mov(8, d, Rm::R(S1));
                        }
                        None => {}
                    }
                }
            }
            Op::Call(c) => {
                let (callee, rest) = if c.target == CallTarget::Ptr { (Some(args[0]), &args[1..]) } else { (None, &args[..]) };
                self.call_args(&c.regs, rest, callee);
                match c.target {
                    CallTarget::Func(g) => self.call_with_site(c.site, pad, |x| x.call_func(g)),
                    CallTarget::Sym(s) => self.call_with_site(c.site, pad, |x| x.call_mem(Mem::Rip(Ref::Sym(s)))),
                    CallTarget::SymInd(s) => {
                        self.a.x().mov(8, Rm::R(S1), Rm::M(Mem::Rip(Ref::Sym(s))));
                        self.call_with_site(c.site, pad, |x| x.call_mem(Mem::base(S1, 0)));
                    }
                    CallTarget::Ptr => self.call_with_site(c.site, pad, |x| x.call_r(R::Rax)),
                }
                self.call_results(&c.parts, &res);
            }
            Op::Island(isl) => {
                let mut b = Vec::with_capacity(4 + 4 * isl.ops.len());
                b.extend_from_slice(&(isl.ops.len() as u32).to_le_bytes());
                for &o in &isl.ops {
                    b.extend_from_slice(&(self.slot_off(o) as u32).to_le_bytes());
                }
                let o = self.ro(&b, 4) + 4;
                // Win64 on PE (`rcx`, `rdx`), into the frame's shadow space ([`layout`]).
                let (fp, ops) = if self.mode.pe { (R::Rcx, R::Rdx) } else { (R::Rdi, R::Rsi) };
                self.fp_into(fp);
                self.a.x().lea(ops, Mem::Rip(Ref::Ro(o)));
                let s = isl.isl;
                self.call_with_site(isl.site, pad, |x| x.call_mem(Mem::Rip(Ref::Sym(s))));
            }
        }
        Ok(())
    }

    /// How many low bytes of `v`'s location can be nonzero (8: unknown): what the
    /// instruction that made it writes, a 4-byte op's result zero-extended to 64 bits, a
    /// narrow load's by `movzx` (R4 of O14).
    fn zext(&self, v: Value) -> u8 {
        let mut v = v;
        loop {
            let ValueDef::Inst(i, n) = self.f.def(v) else { return 8 };
            let id = &self.f.insts[i.idx()];
            return match id.op {
                // `sar` of a narrow value is at 64 bits.
                Op::Bin(BinOp::ShrS, w) if w < 4 => 8,
                Op::Bin(_, w) if w <= 4 => 4,
                Op::Load(w @ (1 | 2 | 4), _) | Op::ALoad(_, _, w @ (1 | 2 | 4)) => w,
                Op::Ext { from, to, sx: false } if to > from => from,
                Op::Ext { from, to, .. } if to <= from => {
                    v = id.args[0];
                    continue;
                }
                Op::Ovf(BinOp::Add | BinOp::Sub, _, 4) | Op::Ovf(BinOp::Mul, _, 1) | Op::Ovf(BinOp::Mul, true, 4) if n == 0 => 4,
                Op::Ovf(BinOp::Mul, false, 2) if n == 0 => 4,
                Op::Ovf(BinOp::Mul, true, 2) if n == 0 => 8,
                Op::HCall(ref h) if !h.reg && (n as usize) < h.outs.len() && matches!(self.f.w(v), 1 | 2 | 4) => self.f.w(v),
                _ => 8,
            };
        }
    }

    /// Loads `v`'s low `from` bytes into `r`, zero- or sign-extended (`sx`) to 64 bits.
    fn ext_into(&mut self, r: R, v: Value, from: u8, sx: bool) {
        let rm = match self.src(v) {
            Src::R(x) => Rm::R(x),
            Src::M(m) => Rm::M(m),
            Src::Imm(c) => {
                let c = if sx {
                    sext(c, from) as u64
                } else if from < 8 {
                    c & ((1 << (8 * from)) - 1)
                } else {
                    c
                };
                return self.a.x().mov_imm(8, Rm::R(r), c);
            }
            Src::Undef => return,
        };
        match (from, sx) {
            (8, _) => self.a.x().mov(8, Rm::R(r), rm),
            (4, false) => self.a.x().mov(4, Rm::R(r), rm),
            (_, false) => self.a.x().movzx(r, from, rm),
            (_, true) => self.a.x().movsx(r, from, rm),
        }
    }

    /// `x = a op b` at `w` bytes with overflow (`args`: `a`, `b`), stored to `x`'s location;
    /// the condition the flags then hold the overflow in.
    fn ovf(&mut self, op: BinOp, signed: bool, w: u8, args: &[Value], x: Value) -> X {
        let (a, b) = (args[0], args[1]);
        if op == BinOp::Mul && !signed && w == 8 {
            return self.mul_u64(a, b, x);
        }
        let rd = self.work(x, &[b]);
        let cc = match (op, signed, w) {
            (BinOp::Add | BinOp::Sub, ..) => {
                self.load(rd, a);
                let alu = if op == BinOp::Add { Alu::Add } else { Alu::Sub };
                match self.alu_src(b, w) {
                    Ok(s) => self.a.x().alu(alu, w, Rm::R(rd), s),
                    Err(imm) => self.a.x().alu_imm(alu, w, Rm::R(rd), imm),
                }
                if signed { X::O } else { X::B }
            }
            (_, true, 2 | 4 | 8) => {
                self.load(rd, a);
                let s = match self.alu_src(b, w) {
                    Ok(s) => s,
                    Err(imm) => {
                        self.a.x().mov_imm(8, Rm::R(S2), imm as u64);
                        Rm::R(S2)
                    }
                };
                self.a.x().imul(w, rd, s);
                X::O
            }
            // 8 and 16 bits: the exact product in 32 bits, out of the width's range.
            (_, _, 1 | 2) => {
                self.ext_into(rd, a, w, signed);
                self.ext_into(S2, b, w, signed);
                self.a.x().imul(4, rd, Rm::R(S2));
                let max = if w == 1 { 0xff } else { 0xffff };
                if signed {
                    self.a.x().lea(S2, Mem::base(rd, max / 2 + 1));
                    self.a.x().alu_imm(Alu::Cmp, 4, Rm::R(S2), max as i64);
                } else {
                    self.a.x().alu_imm(Alu::Cmp, 4, Rm::R(rd), max as i64);
                }
                X::A
            }
            // Unsigned 32 bits: the 64-bit product above `u32::MAX`.
            _ => {
                self.ext_into(rd, a, 4, false);
                self.ext_into(S2, b, 4, false);
                self.a.x().imul(8, rd, Rm::R(S2));
                self.a.x().mov_imm(4, Rm::R(S2), u32::MAX as u64);
                self.a.x().alu(Alu::Cmp, 8, Rm::R(rd), Rm::R(S2));
                X::A
            }
        };
        self.put(x, rd);
        cc
    }

    /// `x = a * b` (unsigned 64 bits) with `mul`, in `rax` and `rdx` (which the allocator
    /// keeps free of values live across it).
    fn mul_u64(&mut self, a: Value, b: Value, x: Value) -> X {
        let s = match self.src(b) {
            Src::R(R::Rax) => {
                self.a.x().mov(8, Rm::R(S1), Rm::R(R::Rax));
                Rm::R(S1)
            }
            Src::R(r) => Rm::R(r),
            Src::M(m) => Rm::M(m),
            Src::Imm(c) => {
                self.a.x().mov_imm(8, Rm::R(S1), c);
                Rm::R(S1)
            }
            Src::Undef => Rm::R(S1),
        };
        self.load(R::Rax, a);
        self.a.x().mul(s);
        self.put(x, R::Rax);
        X::B
    }

    /// `x = a / b` or `a % b` at `w` bytes, with `div`/`idiv` in `rax`/`rdx` (which the
    /// allocator keeps free of values live across it; `w8`/`w16` divide the extended values
    /// at 32 bits). `b` goes to `S1` if it is in `rax` or `rdx`.
    fn divrem(&mut self, op: BinOp, w: u8, a: Value, b: Value, x: Value) {
        let signed = matches!(op, BinOp::DivS | BinOp::RemS);
        let dw = w.max(4);
        let s = match self.src(b) {
            Src::R(r) if w >= 4 && r != R::Rax && r != R::Rdx => Rm::R(r),
            Src::M(m) if w >= 4 => Rm::M(m),
            _ => {
                self.ext_into(S1, b, w, signed);
                Rm::R(S1)
            }
        };
        self.ext_into(R::Rax, a, w, signed);
        if signed {
            self.a.x().cdq(dw);
        } else {
            self.a.x().alu(Alu::Xor, 4, Rm::R(R::Rdx), Rm::R(R::Rdx));
        }
        self.a.x().div(dw, signed, s);
        let r = if matches!(op, BinOp::DivS | BinOp::DivU) { R::Rax } else { R::Rdx };
        self.put(x, r);
    }

    /// `x = a << b` (or `>>`) by a variable amount, in `cl` (which the allocator keeps free of
    /// values live across it), masked to the width (`w8`/`w16` explicitly).
    fn shift_var(&mut self, op: BinOp, w: u8, a: Value, b: Value, x: Value) {
        let rd = match self.al.loc[x.idx()] {
            Loc::Reg(r) if r != R::Rcx && self.src(b) != Src::R(r) => r,
            _ => S1,
        };
        match (op, w) {
            (BinOp::ShrU, 1 | 2) => self.ext_into(rd, a, w, false),
            (BinOp::ShrS, 1 | 2) => self.ext_into(rd, a, w, true),
            _ => self.load(rd, a),
        }
        self.load(R::Rcx, b);
        if w < 4 {
            self.a.x().alu_imm(Alu::And, 4, Rm::R(R::Rcx), 8 * w as i64 - 1);
        }
        let sh = match op {
            BinOp::Shl => Shift::Shl,
            BinOp::ShrU => Shift::Shr,
            _ => Shift::Sar,
        };
        self.a.x().shift_cl(sh, w.max(4), Rm::R(rd));
        self.put(x, rd);
    }

    /// Loads `w` bytes at `m` into `r`.
    fn load_mem(&mut self, r: R, w: u8, m: Mem) {
        match w {
            1 | 2 => self.a.x().movzx(r, w, Rm::M(m)),
            4 => self.a.x().mov(4, Rm::R(r), Rm::M(m)),
            _ => self.a.x().mov(8, Rm::R(r), Rm::M(m)),
        }
    }

    /// Stores the low `w` bytes of `v` at `m` (`S1` may hold the address).
    fn store_mem(&mut self, m: Mem, w: u8, v: Value) {
        match self.src(v) {
            Src::R(r) => self.a.x().mov(w, Rm::M(m), Rm::R(r)),
            Src::Imm(c) if w < 8 || fits32(c as i64) => self.a.x().mov_imm(w, Rm::M(m), c),
            s => {
                self.load_src(S2, s);
                self.a.x().mov(w, Rm::M(m), Rm::R(S2));
            }
        }
    }

    /// `cmp a, b` at `w` bytes (`test a, a` for a register against 0: the same flags).
    fn compare(&mut self, a: Value, b: Value, w: u8) {
        let ra = match self.src(a) {
            Src::R(r) if self.src(b) == Src::Imm(0) || matches!(self.src(b), Src::Imm(c) if sext(c, w) == 0) => {
                return self.a.x().test(w, Rm::R(r), r);
            }
            Src::R(r) => r,
            s => {
                self.load_src(S1, s);
                S1
            }
        };
        match self.alu_src(b, w) {
            Ok(s) => self.a.x().alu(Alu::Cmp, w, Rm::R(ra), s),
            Err(imm) => self.a.x().alu_imm(Alu::Cmp, w, Rm::R(ra), imm),
        }
    }

    /// The moves of an edge.
    fn edge_moves(&mut self, e: &Edge) {
        let params = self.f.blocks[e.to.idx()].params.clone();
        let mut ms = Vec::new();
        for (&a, &p) in e.args.iter().zip(&params) {
            if let Some(d) = self.dst(p) {
                ms.push((d, self.src(a)));
            }
        }
        self.moves(ms);
    }

    fn edge_has_moves(&self, e: &Edge) -> bool {
        let params = &self.f.blocks[e.to.idx()].params;
        e.args.iter().zip(params).any(|(&a, &p)| {
            let (d, s) = (self.dst(p), self.src(a));
            match (d, s) {
                (None, _) | (_, Src::Undef) => false,
                (Some(Rm::R(x)), Src::R(y)) => x != y,
                (Some(Rm::M(x)), Src::M(y)) => x != y,
                _ => true,
            }
        })
    }

    /// A label to branch to for `e`: its target's, or a stub doing its moves (emitted after
    /// the block, or after the last block for a cold target).
    fn edge_label(&mut self, e: &Edge, stubs: &mut Vec<(u32, Edge)>) -> u32 {
        if self.edge_has_moves(e) {
            let l = self.a.label();
            if self.f.blocks[e.to.idx()].cold {
                self.cold_stubs.push((l, e.clone()));
            } else {
                stubs.push((l, e.clone()));
            }
            l
        } else {
            e.to.0
        }
    }

    fn block(&mut self, b: Block, next: Option<Block>) -> Result<(), Unsupported> {
        self.a.bind(b.0);
        let bd = &self.f.blocks[b.idx()];
        if bd.kind == BlockKind::Entry {
            self.prologue();
            // The arguments into their locations: integer registers in parallel, then SSE.
            let params = bd.params.clone();
            let mut ms = Vec::new();
            let mut xs = Vec::new();
            for (k, &p) in params.iter().enumerate() {
                let r = self.f.entry_regs[k];
                if let Some(d) = self.dst(p) {
                    if r.xmm {
                        xs.push((d, r.index as u8, r.size));
                    } else {
                        ms.push((d, Src::R(int_arg(self.mode.pe, r.index))));
                    }
                }
            }
            self.moves(ms);
            for (d, x, size) in xs {
                self.a.x().movq_from_xmm(d, x, if size == 8 { 8 } else { 4 });
            }
        }
        let insts = bd.insts.clone();
        let pad = match &bd.term {
            Term::Invoke { pad, .. } => Some(pad.to.0),
            _ => None,
        };
        for i in insts {
            self.inst(i, pad)?;
        }
        let term = self.f.blocks[b.idx()].term.clone();
        let mut stubs = Vec::new();
        match &term {
            Term::None => return Err(Unsupported("an unterminated block")),
            Term::Jmp(e) => {
                self.edge_moves(e);
                if Some(e.to) != next {
                    self.a.br(None, e.to.0);
                }
            }
            Term::Br { cond, t, f } => {
                let lt = self.edge_label(t, &mut stubs);
                let lf = self.edge_label(f, &mut stubs);
                match self.src(*cond) {
                    Src::R(r) => self.a.x().test(1, Rm::R(r), r),
                    Src::M(m) => self.a.x().alu_imm(Alu::Cmp, 1, Rm::M(m), 0),
                    Src::Imm(c) => {
                        self.a.br(None, if c & 0xff != 0 { lt } else { lf });
                        self.emit_stubs(stubs);
                        return Ok(());
                    }
                    Src::Undef => {
                        self.a.br(None, lf);
                        self.emit_stubs(stubs);
                        return Ok(());
                    }
                }
                let nx = if stubs.is_empty() { next } else { None };
                self.cond_br(X::Ne, lt, lf, nx);
            }
            Term::BrOvf { t, f } => {
                let lt = self.edge_label(t, &mut stubs);
                let lf = self.edge_label(f, &mut stubs);
                let cc = self.ovf_cc.take().ok_or(Unsupported("an overflow branch without its op"))?;
                let nx = if stubs.is_empty() { next } else { None };
                self.cond_br(cc, lt, lf, nx);
            }
            Term::BrCmp { cc, w, a, b: bb, t, f } => {
                let lt = self.edge_label(t, &mut stubs);
                let lf = self.edge_label(f, &mut stubs);
                self.compare(*a, *bb, *w);
                let nx = if stubs.is_empty() { next } else { None };
                self.cond_br(xcc(*cc), lt, lf, nx);
            }
            Term::Switch { idx, targets } => {
                let ls: Vec<u32> = targets.iter().map(|e| self.edge_label(e, &mut stubs)).collect();
                if ls.len() == 1 {
                    self.a.br(None, ls[0]);
                } else {
                    let ri = self.reg(*idx, S2);
                    if ri != S2 {
                        self.a.x().mov(8, Rm::R(S2), Rm::R(ri));
                    }
                    let tl = self.a.label();
                    self.a.x().lea(S1, Mem::RipLabel(tl));
                    self.a.x().movsxd_table(S2, S1, S2);
                    self.a.x().alu(Alu::Add, 8, Rm::R(S2), Rm::R(S1));
                    self.a.x().jmp_r(S2);
                    self.a.ps.push(P::Align4);
                    self.a.bind(tl);
                    self.a.ps.push(P::Table(ls));
                }
            }
            Term::Ret { k, parts } => {
                let ps: Vec<RetPart> =
                    if *k == 0 { Vec::new() } else { asm::ret_parts(*k, true).ok_or(Unsupported("return kind"))?.into_iter().flatten().collect() };
                let mut ms = Vec::new();
                let (mut g, mut x) = (0, 0u8);
                for (p, &v) in ps.iter().zip(parts) {
                    if p.xmm {
                        let s = match self.src(v) {
                            Src::R(r) => Rm::R(r),
                            Src::M(m) => Rm::M(m),
                            Src::Imm(c) => {
                                self.a.x().mov_imm(8, Rm::R(S1), c);
                                Rm::R(S1)
                            }
                            Src::Undef => {
                                x += 1;
                                continue;
                            }
                        };
                        self.a.x().movq_to_xmm(x, s, if p.size == 8 { 8 } else { 4 });
                        x += 1;
                    } else {
                        ms.push((Rm::R([R::Rax, R::Rdx][g]), self.src(v)));
                        g += 1;
                    }
                }
                self.moves(ms);
                // Narrow integer parts zero-extended, as the AOT code loads them.
                let mut g = 0;
                for (p, &v) in ps.iter().zip(parts).filter(|(p, _)| !p.xmm) {
                    let r = [R::Rax, R::Rdx][g];
                    if p.size < 8 && self.zext(v) > p.size as u8 {
                        self.a.x().movzx(r, p.size as u8, Rm::R(r));
                    }
                    g += 1;
                }
                self.epilogue();
                self.a.x().ret();
            }
            Term::TailCall { call, args } => {
                let (callee, rest) = if call.target == CallTarget::Ptr { (Some(args[0]), &args[1..]) } else { (None, &args[..]) };
                self.call_args(&call.regs, rest, callee);
                self.epilogue();
                match call.target {
                    // PE: through a register as `rex.w jmp`, which the unwinder takes for the
                    // epilogue's end (design/jit.md, "Limits").
                    CallTarget::Func(g) if self.mode.pe && g.0 & asm::FUNC_KINDS == asm::FUNC_FAR => self.a.x().jmp_abs_w(Ref::Func(g)),
                    CallTarget::Func(g) => self.a.x().jmp_func(g),
                    CallTarget::Ptr if self.mode.pe => self.a.x().jmp_r_w(R::Rax),
                    CallTarget::Ptr => self.a.x().jmp_r(R::Rax),
                    _ => return Err(Unsupported("a tail call through a symbol")),
                }
            }
            Term::Trap => self.a.x().ud2(),
            Term::Invoke { normal, .. } => match normal {
                Some(e) => {
                    if Some(e.to) != next {
                        self.a.br(None, e.to.0);
                    }
                }
                None => self.a.x().ud2(),
            },
        }
        self.emit_stubs(stubs);
        Ok(())
    }

    fn cond_br(&mut self, cc: X, lt: u32, lf: u32, next: Option<Block>) {
        if Some(lf) == next.map(|b| b.0) {
            self.a.br(Some(cc), lt);
        } else if Some(lt) == next.map(|b| b.0) {
            self.a.br(Some(cc.negate()), lf);
        } else {
            self.a.br(Some(cc), lt);
            self.a.br(None, lf);
        }
    }

    fn emit_stubs(&mut self, stubs: Vec<(u32, Edge)>) {
        for (l, e) in stubs {
            self.a.bind(l);
            self.edge_moves(&e);
            self.a.br(None, e.to.0);
        }
    }
}

/// The integer argument register `i` of VM functions and natives: `rdi rsi rdx rcx r8 r9`,
/// or on PE (Win64) `rcx rdx r8 r9` ([`check_pe`] rejects the others there).
pub(super) fn int_arg(pe: bool, i: u32) -> R {
    if pe { [R::Rcx, R::Rdx, R::R8, R::R9][i as usize] } else { ARGS[i as usize] }
}

/// What the SSA tier doesn't do on PE: arguments past the four Win64 registers (the reduced
/// code has none), handlers that clobber `xmm6`–`xmm15` (callee-saved on Win64, but
/// not in the `sysv64` handlers; the lowering never calls them on PE), and a pinned alloca in
/// the top 16 bytes, which hold `rdi` and `rsi`.
fn check_pe(f: &Func) -> Result<(), Unsupported> {
    let regs_ok = |rs: &[asm::ArgReg]| rs.iter().all(|r| r.index < 4);
    if !regs_ok(&f.entry_regs) {
        return Err(Unsupported("PE: an argument past the fourth"));
    }
    for i in &f.insts {
        match &i.op {
            Op::Call(c) if !regs_ok(&c.regs) => return Err(Unsupported("PE: an argument past the fourth")),
            Op::HCall(h) if super::effects::PE_XMM_CLOBBERS.contains(&h.h) => return Err(Unsupported("PE: a handler that clobbers xmm6-15")),
            _ => {}
        }
    }
    for b in &f.blocks {
        if let Term::TailCall { call, .. } = &b.term
            && !regs_ok(&call.regs)
        {
            return Err(Unsupported("PE: an argument past the fourth"));
        }
    }
    if f.allocas.iter().any(|a| a.pinned && a.kind != AllocaKind::Incoming && a.aot_off + a.size as i32 > -16) {
        return Err(Unsupported("PE: a pinned alloca over the rdi and rsi saves"));
    }
    Ok(())
}

/// Generates `f` with allocation `al`.
pub fn emit(f: &Func, al: &Alloc, mode: Mode, code_consts: &[u8], opts: Opts) -> Result<Output, Unsupported> {
    if mode.pe {
        check_pe(f)?;
    }
    let fr = layout(f, al, mode, opts);
    if fr.pe_fp > 240 {
        return Err(Unsupported("PE: no room for the saves within 240 bytes of the frame pointer"));
    }
    let uses = super::regalloc::use_counts(f);
    let mut e = E {
        f,
        al,
        mode,
        fr,
        a: Asm::default(),
        rodata: Vec::new(),
        code_consts,
        sites: Vec::new(),
        cfi: Vec::new(),
        uses,
        ovf_cc: None,
        cold_stubs: Vec::new(),
        pe_ops: Vec::new(),
        pe_prologue: 0,
    };
    e.a.nlabels = f.blocks.len() as u32;
    let order = &f.layout;
    for (k, &b) in order.iter().enumerate() {
        e.block(b, order.get(k + 1).copied())?;
    }
    let cold_stubs = core::mem::take(&mut e.cold_stubs);
    e.emit_stubs(cold_stubs);
    let pe_unwind = if mode.pe { crate::image::pe_unwind_codes(e.pe_prologue, e.fr.pe_fp / 16, &e.pe_ops) } else { Vec::new() };
    let E { a, rodata, sites, cfi, fr, .. } = e;
    // The marks' pieces, to positions.
    let (code, relocs, lab, pos) = a.finish();
    let at = |m: (u32, u32)| pos[m.0 as usize] + m.1;
    let mut call_sites: Vec<CallSite> =
        sites.iter().map(|&(m, len, pad, catch)| CallSite { start: at(m), len, pad: pad.map(|l| lab[l as usize]), catch }).collect();
    call_sites.sort_by_key(|c| c.start);
    let cfi = cfi.into_iter().map(|(m, v)| (at(m), v)).collect();
    let osr_at = (code.len() as u32).next_multiple_of(16);
    let osr = if !f.osr.is_empty() { Some(osr_code(f, al, mode, &fr, &lab, osr_at)?) } else { None };
    Ok(Output { code, relocs, rodata, call_sites, cfi, osr, osr_at, frame_size: fr.size, pe_unwind, dump: None, devirt: 0 })
}

/// `DW_CFA_offset r`: `r` saved at `fp + o`, which is `CFA - 16 + o`. The offset counts in
/// the CIE's data alignment, 8 bytes, so the slot must be 8-aligned.
fn save_rule(v: &mut Vec<u8>, r: R, o: i32) {
    assert!(o % 8 == 0 && o <= 0, "a save slot at fp{o:+}");
    v.push(0x80 | dw(r));
    uleb(v, ((16 - o) / 8) as u32);
}

/// The OSR dispatcher and entries: each converts the AOT frame at a head into the JIT one
/// (design/jit.md, "OSR"): everything it reads from the AOT frame into a scratch area below
/// both frames first, then the callee-saved registers' saves, the moved allocas' copies, the
/// head's parameters, and the jump to the head.
fn osr_code(f: &Func, al: &Alloc, mode: Mode, fr: &Frame, lab: &[u32], at: u32) -> Result<OsrCode, Unsupported> {
    let fp = mode.frame_pointer;
    let f_aot = f.aot_frame;
    let f_jit = fr.size;
    let mut probes = Vec::new();
    let (code, mut cfi, table) = osr::dispatcher(f.osr.len(), fp, f_aot);
    let mut x = X86 { code, ..X86::default() };
    let mem_of = |base: R, off: i32| Mem::base(base, off);
    for (n, o) in f.osr.iter().enumerate() {
        osr::entry_start(&mut x.code, &mut cfi, table, n, fp, f_aot);
        let Some(ob) = o else {
            x.ret();
            continue;
        };
        let obd = &f.blocks[ob.idx()];
        let Term::Jmp(edge) = &obd.term else { return Err(Unsupported("an OSR entry that doesn't jump")) };
        let head = edge.to;
        osr::drop_return(&mut x.code, &mut cfi, fp, f_aot);
        let base = if fp {
            R::Rbp
        } else {
            osr::fp_to_rdx(&mut x.code, &mut cfi, f_aot);
            R::Rdx
        };
        // What the entry reads: each OSR load's value, each moved alloca's bytes.
        let mut loads: Vec<(Value, i32, u8, i32)> = Vec::new();
        let mut k = 0i32;
        for &i in &obd.insts {
            let id = &f.insts[i.idx()];
            if let Op::OsrLoad(off, w) = id.op {
                loads.push((Value(id.res), off, w, k));
                k += 8;
            }
        }
        let mut copies: Vec<(i32, i32, u32, i32)> = Vec::new();
        for (a, al_) in f.allocas.iter().enumerate() {
            if matches!(al_.kind, AllocaKind::Memory | AllocaKind::Outgoing) && !al_.inlined && fr.alloca[a] != al_.aot_off {
                copies.push((al_.aot_off, fr.alloca[a], al_.size, k));
                k += al_.size.next_multiple_of(8) as i32;
            }
        }
        let low = osr::low(f_aot, f_jit, k as u32);
        osr::probe(&mut x.code, &mut probes, low - f_aot, mode.far_rt);
        x.lea(R::Rsp, mem_of(base, -(low as i32)));
        // Read from the AOT frame.
        let copy = |x: &mut X86, (fb, from): (R, i32), (tb, to): (R, i32), size: u32| {
            let mut d = 0;
            while d < size {
                let s = [8u32, 4, 2, 1].into_iter().find(|&s| s <= size - d).unwrap();
                x.mov(s as u8, Rm::R(S1), Rm::M(mem_of(fb, from + d as i32)));
                x.mov(s as u8, Rm::M(mem_of(tb, to + d as i32)), Rm::R(S1));
                d += s;
            }
        };
        for &(_, off, w, k) in &loads {
            match w {
                1 | 2 => x.movzx(S1, w, Rm::M(mem_of(base, off))),
                4 => x.mov(4, Rm::R(S1), Rm::M(mem_of(base, off))),
                _ => x.mov(8, Rm::R(S1), Rm::M(mem_of(base, off))),
            }
            x.mov(8, Rm::M(mem_of(R::Rsp, k)), Rm::R(S1));
        }
        for &(from, _, size, k) in &copies {
            copy(&mut x, (base, from), (R::Rsp, k), size);
        }
        // The callee-saved registers still hold the caller's values: save them.
        for &(r, o) in &fr.saves {
            x.mov(8, Rm::M(mem_of(base, o)), Rm::R(r));
        }
        for &(_, to, size, k) in &copies {
            copy(&mut x, (R::Rsp, k), (base, to), size);
        }
        // The head's parameters: memory ones first, then registers (`rdx`, the base, last).
        let params = &f.blocks[head.idx()].params;
        let slot_of = |v: Value| loads.iter().find(|l| l.0 == v).map(|l| l.3);
        let jit_mem = |n: u32| mem_of(base, fr.spill0 + 8 * n as i32);
        let mut regs = Vec::new();
        for (&a, &p) in edge.args.iter().zip(params) {
            let src = match f.def(a) {
                ValueDef::Const(c) => Src::Imm(c),
                ValueDef::Undef => continue,
                _ => Src::M(mem_of(R::Rsp, slot_of(a).ok_or(Unsupported("an OSR argument that isn't loaded"))?)),
            };
            match al.loc[p.idx()] {
                Loc::None => {}
                Loc::Spill(s) => match src {
                    Src::Imm(c) if fits32(c as i64) => x.mov_imm(8, Rm::M(jit_mem(s)), c),
                    Src::Imm(c) => {
                        x.mov_imm(8, Rm::R(S1), c);
                        x.mov(8, Rm::M(jit_mem(s)), Rm::R(S1));
                    }
                    Src::M(m) => {
                        x.mov(8, Rm::R(S1), Rm::M(m));
                        x.mov(8, Rm::M(jit_mem(s)), Rm::R(S1));
                    }
                    _ => unreachable!(),
                },
                Loc::Reg(r) => regs.push((r, src)),
            }
        }
        regs.sort_by_key(|&(r, _)| r == R::Rdx);
        for (r, s) in regs {
            match s {
                Src::Imm(c) => x.mov_imm(8, Rm::R(r), c),
                Src::M(m) => x.mov(8, Rm::R(r), Rm::M(m)),
                _ => unreachable!(),
            }
        }
        // `rsp = fp - F_jit`: from `rbp`, or from `rdx` unless it was just loaded.
        if fp {
            x.lea(R::Rsp, mem_of(R::Rbp, -(f_jit as i32)));
        } else {
            // `rsp` is `fp - low`.
            x.lea(R::Rsp, mem_of(R::Rsp, (low - f_jit) as i32));
        }
        osr::jmp_landing(&mut x.code, at, lab[head.idx()]);
    }
    Ok(OsrCode { code: x.code, probes, cfi })
}
