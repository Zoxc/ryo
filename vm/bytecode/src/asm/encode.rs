//! Instruction words to machine code (design/vm.md, "Encoding").
//!
//! Every instruction becomes its canonical sequence ([`super::x86`]): the handler call with
//! the operands in their registers, then its shape's control flow. Branches within the
//! function start short (`rel8`) and grow to `rel32` where they don't reach, until nothing
//! changes. With [`Mode::align_loops`], the targets of backward branches are padded to 16
//! bytes.

use alloc::collections::BTreeMap;
use alloc::vec;
use alloc::vec::Vec;

use super::x86::{ARGS, Cond, Item, Reg, island_args, padding};
use super::{Layout, Loc, Mode, layout};
use crate::image::{CONTINUE, CleanupEntry};
use crate::insn::{Const, Data, DecodeError, ElemKind, Func, Opcode, OperandKind, Shape, Site, Sym, insn_len};

/// What a relocated 4-byte field of the code refers to. Every field is PC-relative: once
/// linked, it holds `target - (field + 4)`.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Ref {
    /// The handler `ryo_h_<op>`.
    Handler(Opcode),
    /// `ryo_probe_stack`.
    Probe,
    /// A function of the image (call and tail-call targets).
    Func(Func),
    /// A symbol slot (`addr.sym`, `call.ext`'s symbol, and island calls through it).
    Sym(Sym),
    /// A site cache slot.
    Site(Site),
    /// A constant pool offset.
    Const(Const),
    /// A data area offset.
    Data(Data),
    /// An offset in the function's [`Encoded::rodata`].
    Ro(u32),
}

/// A relocated field: the 4 bytes at `at`.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Reloc {
    pub at: u32,
    pub to: Ref,
}

/// A call that may unwind: the call instruction's bytes, and its landing pad (the position
/// of an `lpad`), or `None` if unwinding continues in the caller. Calls without a call site
/// can't unwind (the unwinder aborts if they do).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct CallSite {
    pub start: u32,
    pub len: u32,
    pub pad: Option<u32>,
}

/// One function's machine code.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Encoded {
    pub code: Vec<u8>,
    /// Sorted by position.
    pub relocs: Vec<Reloc>,
    /// The constants the code refers to ([`Ref::Ro`]): island operand arrays (a `u32` count,
    /// then the words) and sparse switch values. Aligned to 16.
    pub rodata: Vec<u8>,
    /// Sorted by position.
    pub call_sites: Vec<CallSite>,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum EncodeError {
    Decode(DecodeError),
    /// A branch target that isn't an instruction start (word offset of the instruction).
    BadTarget(u32),
    /// A cleanup entry not at an instruction that may unwind, or whose landing pad isn't an
    /// `lpad`.
    BadCleanup(u32),
}

/// An operand of an instruction, read from its words by kind.
#[derive(Clone, Debug, PartialEq, Eq)]
pub(super) enum Opnd {
    Slot(i32),
    Mem(i32, i32),
    /// `U8` … `U64`, `I64`.
    Imm(u64),
    Imm128(u128),
    Const(Const),
    Data(Data),
    Sym(Sym),
    Site(Site),
    Func(Func),
    /// Word offset of the target, from the function start.
    Target(u32),
    Neg(bool),
    Targets(Vec<u32>),
    Words(Vec<u32>),
    /// Values and targets.
    Cases(Vec<u128>, Vec<u32>),
}

/// The operands of the instruction at word `at` of `code`, by kind.
pub(super) fn operands(code: &[u32], at: usize) -> Vec<Opnd> {
    let op = Opcode::from_u16(code[at] as u16).expect("decoded");
    let mut pos = at + 1;
    let mut out = Vec::new();
    let target = |w: u32| (at as u32).wrapping_add(w);
    for o in op.info().operands {
        let w = |i: usize| code[pos + i];
        let wide = |n: usize| (0..n).fold(0u128, |v, i| v | (w(i) as u128) << (32 * i));
        out.push(match o.kind {
            OperandKind::Slot => Opnd::Slot(w(0) as i32),
            OperandKind::Mem => Opnd::Mem(w(0) as i32, w(1) as i32),
            OperandKind::U8 | OperandKind::U16 | OperandKind::U32 => Opnd::Imm(w(0) as u64),
            OperandKind::U64 | OperandKind::I64 => Opnd::Imm(wide(2) as u64),
            OperandKind::U128 => Opnd::Imm128(wide(4)),
            OperandKind::Const => Opnd::Const(Const(w(0))),
            OperandKind::Abs => match crate::insn::Abs::from_word(w(0)) {
                crate::insn::Abs::Const(k) => Opnd::Const(k),
                crate::insn::Abs::Data(d) => Opnd::Data(d),
            },
            OperandKind::Sym => Opnd::Sym(Sym(w(0))),
            OperandKind::Site => Opnd::Site(Site(w(0))),
            OperandKind::Func => Opnd::Func(Func(w(0))),
            OperandKind::Target => Opnd::Target(target(w(0))),
            OperandKind::Neg => Opnd::Neg(w(0) != 0),
            OperandKind::List(e) => {
                let n = w(0) as usize;
                let el = |i: usize, j: usize| code[pos + 1 + i * e.words() + j];
                let o = match e {
                    ElemKind::Target => Opnd::Targets((0..n).map(|i| target(el(i, 0))).collect()),
                    ElemKind::Word => Opnd::Words((0..n).map(|i| el(i, 0)).collect()),
                    ElemKind::Case8 | ElemKind::Case16 | ElemKind::Case32 | ElemKind::Case64 | ElemKind::Case128 => {
                        let vw = e.words() - 1;
                        let vals = (0..n).map(|i| (0..vw).fold(0u128, |v, j| v | (el(i, j) as u128) << (32 * j))).collect();
                        Opnd::Cases(vals, (0..n).map(|i| target(el(i, vw))).collect())
                    }
                };
                pos += 1 + n * e.words();
                out.push(o);
                continue;
            }
        });
        pos += o.kind.words().unwrap();
    }
    out
}

/// The element size of a case list's value array in the rodata.
pub(super) fn case_size(e: ElemKind) -> usize {
    match e {
        ElemKind::Case8 => 1,
        ElemKind::Case16 => 2,
        ElemKind::Case32 => 4,
        ElemKind::Case64 => 8,
        ElemKind::Case128 => 16,
        ElemKind::Target | ElemKind::Word => unreachable!("not a case list"),
    }
}

/// An element of a function's code before layout.
#[derive(Clone, Debug)]
enum Piece {
    /// A fixed item, a call site if `site`.
    Fixed { item: Item, site: bool },
    /// A branch to the instruction with this index.
    Branch { cond: Cond, to: usize, long: bool },
    /// A short forward branch over the next `skip` bytes (inside a call sequence).
    Skip { cond: Cond, skip: u32 },
    /// `lea rcx, [rip + T]` of the instruction's jump table.
    LeaTable,
    /// The jump table: `int3`s up to a multiple of 4, then the entries.
    Table(Vec<usize>),
    /// Padding up to a multiple of 16 (a loop head).
    Align,
}

/// The rodata being built, deduplicated.
#[derive(Default)]
struct Rodata {
    bytes: Vec<u8>,
    seen: BTreeMap<(Vec<u8>, usize), u32>,
}

impl Rodata {
    fn add(&mut self, bytes: Vec<u8>, align: usize) -> u32 {
        if let Some(&off) = self.seen.get(&(bytes.clone(), align)) {
            return off;
        }
        let off = self.bytes.len().next_multiple_of(align);
        self.bytes.resize(off, 0);
        self.bytes.extend_from_slice(&bytes);
        self.seen.insert((bytes, align), off as u32);
        off as u32
    }

    /// An operand array: the count, then the words. Returns the offset of the words.
    fn ops(&mut self, words: &[u32]) -> u32 {
        let mut b = Vec::with_capacity(4 + 4 * words.len());
        b.extend_from_slice(&(words.len() as u32).to_le_bytes());
        for w in words {
            b.extend_from_slice(&w.to_le_bytes());
        }
        self.add(b, 4) + 4
    }
}

/// Encodes one function: its instruction words, frame size `F` and cleanup entries.
pub fn encode(code: &[u32], frame_size: u32, cleanup: &[CleanupEntry], mode: Mode) -> Result<Encoded, EncodeError> {
    let mut starts = Vec::new();
    let mut index = vec![usize::MAX; code.len() + 1];
    let mut at = 0;
    while at < code.len() {
        index[at] = starts.len();
        starts.push(at);
        at += insn_len(&code[at..]).map_err(EncodeError::Decode)?;
        crate::insn::Insn::decode(&code[starts[starts.len() - 1]..]).map_err(EncodeError::Decode)?;
    }
    let idx = |w: u32| -> Result<usize, EncodeError> {
        index.get(w as usize).copied().filter(|&i| i != usize::MAX).ok_or(EncodeError::BadTarget(w))
    };

    // Unwind actions, by instruction: `Some(None)` continues, `Some(Some(i))` lands in `i`.
    let mut action: Vec<Option<Option<usize>>> = vec![None; starts.len()];
    for e in cleanup {
        let i = idx(e.offset).map_err(|_| EncodeError::BadCleanup(e.offset))?;
        let op = Opcode::from_u16(code[starts[i]] as u16).unwrap();
        if !crate::image::op_may_unwind(op) || action[i].is_some() {
            return Err(EncodeError::BadCleanup(e.offset));
        }
        action[i] = Some(if e.target == CONTINUE {
            None
        } else {
            let p = idx(e.target).map_err(|_| EncodeError::BadCleanup(e.offset))?;
            if Opcode::from_u16(code[starts[p]] as u16) != Some(Opcode::Lpad) {
                return Err(EncodeError::BadCleanup(e.offset));
            }
            Some(p)
        });
    }

    let mut cx = Cx { mode, frame_size, ro: Rodata::default(), pieces: Vec::new() };
    // The pieces of each instruction (`first[i]..first[i + 1]`), after the prologue's.
    cx.prologue();
    let mut first = Vec::with_capacity(starts.len() + 1);
    // Backward branch targets.
    let mut loop_head = vec![false; starts.len()];
    for (i, &at) in starts.iter().enumerate() {
        for o in operands(code, at) {
            match o {
                Opnd::Target(t) => {
                    let t = idx(t)?;
                    if t <= i {
                        loop_head[t] = true;
                    }
                }
                Opnd::Targets(ts) | Opnd::Cases(_, ts) => {
                    for t in ts {
                        idx(t)?;
                    }
                }
                _ => {}
            }
        }
    }
    for (i, &at) in starts.iter().enumerate() {
        first.push(cx.pieces.len());
        if mode.align_loops && loop_head[i] {
            cx.pieces.push(Piece::Align);
        }
        let op = Opcode::from_u16(code[at] as u16).unwrap();
        cx.insn(op, &operands(code, at), action[i].is_some(), &idx)?;
    }
    first.push(cx.pieces.len());
    cx.layout(&first, &starts, &action)
}

/// The state of one function's encoding.
struct Cx {
    mode: Mode,
    frame_size: u32,
    ro: Rodata,
    pieces: Vec<Piece>,
}

/// The register an operand register value goes in: a constant, or the address of a [`Ref`].
#[derive(Clone, Copy)]
pub(super) enum RegVal {
    Imm(u64),
    Addr(Ref),
}

impl Cx {
    fn fixed(&mut self, item: Item) {
        self.pieces.push(Piece::Fixed { item, site: false });
    }

    fn site(&mut self, item: Item) {
        self.pieces.push(Piece::Fixed { item, site: true });
    }

    /// `push rbp; mov rbp, rsp`, then for `F > 0` (with a stack probe from 4096 bytes)
    /// `sub rsp, F`.
    fn prologue(&mut self) {
        self.fixed(Item::PushRbp);
        self.fixed(Item::Mov(Reg::Rbp, Reg::Rsp));
        if self.frame_size >= PROBE_FROM {
            self.fixed(Item::SetReg(Reg::Rax, self.frame_size as u64));
            self.fixed(Item::Call(Ref::Probe));
        }
        if self.frame_size != 0 {
            self.fixed(Item::SubRsp(self.frame_size));
        }
    }

    /// Sets the argument registers of `op`'s handler from `ops` and calls it.
    fn handler_call(&mut self, op: Opcode, ops: &[Opnd], site: bool) {
        let l = layout(op, self.mode);
        if self.mode.fp_arg {
            self.fixed(Item::Mov(ARGS[0], Reg::Rbp));
        }
        if op.info().shape == Shape::Lpad {
            // The exception object, in `rax` at a landing pad.
            self.fixed(Item::Mov(ARGS[l.first as usize - 1], Reg::Rax));
        }
        for (reg, v) in reg_values(op, &l, ops, &mut self.ro).into_iter().enumerate() {
            match v {
                Some(RegVal::Imm(v)) => self.fixed(Item::SetReg(ARGS[reg], v)),
                Some(RegVal::Addr(r)) => self.fixed(Item::Lea(ARGS[reg], r)),
                None => {}
            }
        }
        let call = Item::Call(Ref::Handler(op));
        if site { self.site(call) } else { self.fixed(call) }
    }

    /// The direct island call `island(fp, ops)` through the symbol slot `isl`, `ops` the
    /// operand array at `ops_ro` (PE: with 32 bytes of shadow space).
    fn island_call(&mut self, isl: Sym, ops_ro: u32, site: bool) {
        let [fp, ops] = island_args(self.mode.pe);
        self.fixed(Item::Mov(fp, Reg::Rbp));
        self.fixed(Item::Lea(ops, Ref::Ro(ops_ro)));
        if self.mode.pe {
            self.fixed(Item::SubRsp(32));
        }
        let call = Item::CallMem(Ref::Sym(isl));
        if site { self.site(call) } else { self.fixed(call) }
        if self.mode.pe {
            self.fixed(Item::AddRsp(32));
        }
    }

    fn island_len(&self) -> u32 {
        if self.mode.pe { 3 + 7 + 4 + 6 + 4 } else { 3 + 7 + 6 }
    }

    /// The jump-table sequence on the index in `rax`, with `targets`.
    fn table(&mut self, targets: Vec<usize>) {
        self.pieces.push(Piece::LeaTable);
        self.fixed(Item::LoadTableEntry);
        self.fixed(Item::AddRaxRcx);
        self.fixed(Item::JmpRax);
        self.pieces.push(Piece::Table(targets));
    }

    fn insn(
        &mut self,
        op: Opcode,
        ops: &[Opnd],
        unwinds: bool,
        idx: &dyn Fn(u32) -> Result<usize, EncodeError>,
    ) -> Result<(), EncodeError> {
        let info = op.info();
        let named = |name: &str| &ops[info.operand_index(name).expect("operand")];
        let slot = |name: &str| match named(name) {
            Opnd::Slot(s) => *s,
            _ => unreachable!(),
        };
        let sym = |name: &str| match named(name) {
            Opnd::Sym(s) => *s,
            _ => unreachable!(),
        };
        let target = |name: &str| match named(name) {
            Opnd::Target(t) => idx(*t),
            _ => unreachable!(),
        };
        let argblk = (self.frame_size as i32).wrapping_neg() as u32;
        match info.shape {
            Shape::Op | Shape::Lpad => self.handler_call(op, ops, false),
            Shape::Br => {
                self.handler_call(op, ops, false);
                self.fixed(Item::TestAl);
                let Opnd::Neg(neg) = named("neg") else { unreachable!() };
                let cond = if *neg { Cond::Z } else { Cond::Nz };
                self.pieces.push(Piece::Branch { cond, to: target("t")?, long: false });
            }
            Shape::Switch => {
                self.handler_call(op, ops, false);
                let mut ts = Vec::new();
                for o in ops {
                    if let Opnd::Targets(t) | Opnd::Cases(_, t) = o {
                        for &t in t {
                            ts.push(idx(t)?);
                        }
                    }
                }
                ts.push(target("default")?);
                self.table(ts);
            }
            Shape::Trap => {
                self.handler_call(op, ops, unwinds);
                self.fixed(Item::Ud2);
            }
            Shape::Ret => {
                self.handler_call(op, ops, false);
                self.fixed(Item::Leave);
                self.fixed(Item::Ret);
            }
            Shape::Jmp => self.pieces.push(Piece::Branch { cond: Cond::Always, to: target("t")?, long: false }),
            Shape::Call => {
                let Opnd::Func(f) = named("f") else { unreachable!() };
                if unwinds { self.site(Item::Call(Ref::Func(*f))) } else { self.fixed(Item::Call(Ref::Func(*f))) }
                self.fixed(Item::Marker(slot("d")));
            }
            Shape::CallExt | Shape::CallInd => {
                self.handler_call(op, ops, false);
                // `rax`: the VM entry, or 0 for the native path through the island.
                let fnp = if info.shape == Shape::CallExt { slot("f") } else { slot("p") };
                let d = slot("d");
                let ops_ro = self.ro.ops(&[argblk, d as u32, fnp as u32]);
                self.fixed(Item::TestRax);
                self.pieces.push(Piece::Skip { cond: Cond::Z, skip: 2 + 7 + 2 });
                if unwinds { self.site(Item::CallRax) } else { self.fixed(Item::CallRax) }
                self.fixed(Item::Marker(d));
                self.pieces.push(Piece::Skip { cond: Cond::Always, skip: self.island_len() });
                self.island_call(sym("isl"), ops_ro, unwinds);
            }
            Shape::TailCall => {
                self.handler_call(op, ops, false);
                self.fixed(Item::Leave);
                let Opnd::Func(f) = named("f") else { unreachable!() };
                self.fixed(Item::Jmp(Ref::Func(*f)));
            }
            Shape::TailCallInd => {
                self.handler_call(op, ops, false);
                let s = slot("s");
                let ops_ro = self.ro.ops(&[argblk, s as u32, slot("p") as u32]);
                self.fixed(Item::TestRax);
                self.pieces.push(Piece::Skip { cond: Cond::Z, skip: 1 + 2 });
                self.fixed(Item::Leave);
                self.fixed(Item::JmpRax);
                self.island_call(sym("isl"), ops_ro, unwinds);
                // Then `ret s, len`.
                let ret = [Opnd::Slot(s), named("len").clone()];
                self.handler_call(Opcode::Ret, &ret, false);
                self.fixed(Item::Leave);
                self.fixed(Item::Ret);
            }
            Shape::Island => {
                let Opnd::Words(w) = named("ops") else { unreachable!() };
                let ops_ro = self.ro.ops(w);
                self.island_call(sym("isl"), ops_ro, unwinds);
            }
        }
        Ok(())
    }

    /// Lays out the pieces (relaxing branches) and writes the code.
    fn layout(mut self, first: &[usize], starts: &[usize], action: &[Option<Option<usize>>]) -> Result<Encoded, EncodeError> {
        let n = self.pieces.len();
        let mut pos = vec![0u32; n + 1];
        // The position of instruction `i` (after its alignment padding).
        let insn_pos = |pos: &[u32], pieces: &[Piece], i: usize| -> u32 {
            let p = first[i];
            if matches!(pieces.get(p), Some(Piece::Align)) { pos[p + 1] } else { pos[p] }
        };
        loop {
            let mut p = 0u32;
            for (k, piece) in self.pieces.iter().enumerate() {
                pos[k] = p;
                p += match piece {
                    Piece::Fixed { item, .. } => item.len(),
                    Piece::Branch { cond, long, .. } => Item::Branch { cond: *cond, target: 0, long: *long }.len(),
                    Piece::Skip { .. } => 2,
                    Piece::LeaTable => 7,
                    Piece::Table(t) => p.next_multiple_of(4) - p + 4 * t.len() as u32,
                    Piece::Align => p.next_multiple_of(16) - p,
                };
            }
            pos[n] = p;
            let mut changed = false;
            for k in 0..n {
                if let Piece::Branch { to, long: false, .. } = self.pieces[k] {
                    let d = insn_pos(&pos, &self.pieces, to) as i64 - (pos[k] as i64 + 2);
                    if i8::try_from(d).is_err() {
                        let Piece::Branch { long, .. } = &mut self.pieces[k] else { unreachable!() };
                        *long = true;
                        changed = true;
                    }
                }
            }
            if !changed {
                break;
            }
        }
        let mut out = Encoded { code: Vec::with_capacity(pos[n] as usize), ..Default::default() };
        let mut items = Vec::new();
        for (k, piece) in self.pieces.iter().enumerate() {
            let p = pos[k];
            items.clear();
            let mut site = false;
            match piece {
                Piece::Fixed { item, site: s } => {
                    items.push(*item);
                    site = *s;
                }
                Piece::Branch { cond, to, long } => {
                    items.push(Item::Branch { cond: *cond, target: insn_pos(&pos, &self.pieces, *to), long: *long })
                }
                Piece::Skip { cond, skip } => items.push(Item::Branch { cond: *cond, target: p + 2 + skip, long: false }),
                Piece::LeaTable => {
                    // The table follows the rest of the sequence: `movsxd`, `add`, `jmp rax`.
                    let t = (p + 7 + 4 + 3 + 2).next_multiple_of(4);
                    items.push(Item::LeaTable(t));
                }
                Piece::Table(targets) => {
                    for _ in p..p.next_multiple_of(4) {
                        items.push(Item::Int3);
                    }
                    let base = p.next_multiple_of(4);
                    for &t in targets {
                        items.push(Item::TableEntry { base, target: insn_pos(&pos, &self.pieces, t) });
                    }
                }
                Piece::Align => padding(p.next_multiple_of(16) - p, &mut items),
            }
            let mut q = p;
            for it in &items {
                if site {
                    out.call_sites.push(CallSite { start: q, len: it.len(), pad: None });
                }
                it.write(q, &mut out.code, &mut out.relocs);
                q += it.len();
            }
        }
        debug_assert_eq!(out.code.len(), pos[n] as usize);
        // Landing pads of the call sites, by the instruction each is in.
        let mut sites = out.call_sites.iter_mut().peekable();
        for i in 0..starts.len() {
            let (lo, hi) = (pos[first[i]], pos[first[i + 1]]);
            while let Some(s) = sites.next_if(|s| s.start < hi) {
                debug_assert!(s.start >= lo);
                s.pad = action[i].expect("a call site has an action").map(|p| insn_pos(&pos, &self.pieces, p));
            }
        }
        out.rodata = core::mem::take(&mut self.ro.bytes);
        Ok(out)
    }
}

/// Functions with frames of at least this size probe the stack in the prologue.
pub const PROBE_FROM: u32 = 4096;

/// The values of `op`'s handler argument registers for operands `ops` (`None` for the
/// registers set otherwise: `fp`, the exception object). Adds case value arrays to `ro`.
fn reg_values(op: Opcode, l: &Layout, ops: &[Opnd], ro: &mut Rodata) -> Vec<Option<RegVal>> {
    let info = op.info();
    let mut regs: Vec<Option<RegVal>> = vec![None; l.regs as usize];
    let mut set = |loc: Loc, part: u8, v: RegVal| {
        let r = &mut regs[(loc.reg + part) as usize];
        *r = Some(match (v, *r) {
            (RegVal::Imm(v), Some(RegVal::Imm(lo))) if loc.shared => RegVal::Imm(lo | v << loc.shift),
            (RegVal::Imm(v), None) if loc.shared => RegVal::Imm(v << loc.shift),
            (v, _) => v,
        });
    };
    for (i, o) in ops.iter().enumerate() {
        let loc = l.locs[i];
        if loc.count == 0 {
            continue;
        }
        match o {
            Opnd::Slot(s) => set(loc, 0, RegVal::Imm(*s as u32 as u64)),
            Opnd::Mem(p, k) => {
                set(loc, 0, RegVal::Imm(*p as u32 as u64));
                set(loc, 1, RegVal::Imm(*k as u32 as u64));
            }
            Opnd::Imm(v) => set(loc, 0, RegVal::Imm(*v)),
            Opnd::Imm128(v) => {
                set(loc, 0, RegVal::Imm(*v as u64));
                set(loc, 1, RegVal::Imm((*v >> 64) as u64));
            }
            Opnd::Const(k) => set(loc, 0, RegVal::Addr(Ref::Const(*k))),
            Opnd::Data(d) => set(loc, 0, RegVal::Addr(Ref::Data(*d))),
            Opnd::Sym(s) => set(loc, 0, RegVal::Addr(Ref::Sym(*s))),
            Opnd::Site(s) => set(loc, 0, RegVal::Addr(Ref::Site(*s))),
            Opnd::Targets(t) => set(loc, 0, RegVal::Imm(t.len() as u64)),
            Opnd::Cases(vals, _) => {
                let OperandKind::List(e) = info.operands[i].kind else { unreachable!() };
                let size = case_size(e);
                let mut b = Vec::with_capacity(vals.len() * size);
                for v in vals {
                    b.extend_from_slice(&v.to_le_bytes()[..size]);
                }
                set(loc, 0, RegVal::Addr(Ref::Ro(ro.add(b, size.max(4)))));
                set(loc, 1, RegVal::Imm(vals.len() as u64));
            }
            Opnd::Func(_) | Opnd::Target(_) | Opnd::Neg(_) | Opnd::Words(_) => {
                unreachable!("not a register operand")
            }
        }
    }
    regs
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn handler_count() {
        // Every opcode with a handler has a layout (const-evaluable for all of them).
        for &op in crate::insn::ALL_OPCODES {
            if super::super::has_handler(op) {
                let l = layout(op, Mode { fp_arg: false, align_loops: true, pe: false });
                assert!(l.regs as usize <= super::super::ARG_REGS);
                let l = layout(op, Mode { fp_arg: true, align_loops: true, pe: false });
                assert!(l.regs as usize <= super::super::ARG_REGS);
            }
        }
    }
}
