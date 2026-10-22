//! Instruction words to machine code (design/vm.md, "Encoding").
//!
//! Every instruction becomes its canonical sequence ([`super::x86`]): the handler call with
//! the operands in their registers, then its shape's control flow, or for the common
//! instructions a native sequence (`super::inline`). Branches within the
//! function start short (`rel8`) and grow to `rel32` where they don't reach, until nothing
//! changes. With [`Mode::align_loops`], the targets of backward branches are padded to 16
//! bytes.

use alloc::collections::BTreeMap;
use alloc::vec;
use alloc::vec::Vec;

use super::x86::{ARGS, Cond, Item, Reg, island_args, padding};
use super::{Layout, Loc, Mode, layout};
use crate::image::{CATCH, CONTINUE, CleanupEntry};
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
    /// The landing pad catches every exception, rather than being a cleanup
    /// ([`crate::image::CATCH`]).
    pub catch: bool,
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

/// An instruction operand, by kind. Branch targets are `T`: word offsets from the function
/// start when read from instruction words ([`operands`]), [`Label`]s for [`Asm`].
///
/// For [`Asm`], `Slot`, the pointer slot of `Mem` and every element of `Words` are raw slot
/// values that [`Asm::finish`] turns into frame offsets.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Opnd<T = u32> {
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
    Target(T),
    Neg(bool),
    Targets(Vec<T>),
    Words(Vec<u32>),
    /// Values and targets.
    Cases(Vec<u128>, Vec<T>),
}

impl<T> Opnd<T> {
    /// The same operand with its targets mapped by `f`.
    pub fn map_targets<U, E>(self, mut f: impl FnMut(T) -> Result<U, E>) -> Result<Opnd<U>, E> {
        Ok(match self {
            Opnd::Slot(s) => Opnd::Slot(s),
            Opnd::Mem(p, k) => Opnd::Mem(p, k),
            Opnd::Imm(v) => Opnd::Imm(v),
            Opnd::Imm128(v) => Opnd::Imm128(v),
            Opnd::Const(k) => Opnd::Const(k),
            Opnd::Data(d) => Opnd::Data(d),
            Opnd::Sym(s) => Opnd::Sym(s),
            Opnd::Site(s) => Opnd::Site(s),
            Opnd::Func(x) => Opnd::Func(x),
            Opnd::Target(t) => Opnd::Target(f(t)?),
            Opnd::Neg(n) => Opnd::Neg(n),
            Opnd::Targets(ts) => Opnd::Targets(ts.into_iter().map(&mut f).collect::<Result<_, _>>()?),
            Opnd::Words(w) => Opnd::Words(w),
            Opnd::Cases(v, ts) => Opnd::Cases(v, ts.into_iter().map(&mut f).collect::<Result<_, _>>()?),
        })
    }
}

/// The operands of the instruction at word `at` of `code`, by kind.
pub fn operands(code: &[u32], at: usize) -> Vec<Opnd> {
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

/// The instruction-word length of `op` with operands `ops`.
pub fn word_len<T>(op: Opcode, ops: &[Opnd<T>]) -> usize {
    1 + op
        .info()
        .operands
        .iter()
        .zip(ops)
        .map(|(o, v)| match (o.kind, v) {
            (OperandKind::List(e), Opnd::Targets(t)) => 1 + t.len() * e.words(),
            (OperandKind::List(e), Opnd::Words(t)) => 1 + t.len() * e.words(),
            (OperandKind::List(e), Opnd::Cases(_, t)) => 1 + t.len() * e.words(),
            (k, _) => k.words().unwrap(),
        })
        .sum::<usize>()
}

/// Appends the instruction words of `op` with operands `ops`, targets relative to the
/// instruction.
pub fn push_words(op: Opcode, ops: &[Opnd], words: &mut Vec<u32>) {
    words.push(op as u32);
    for (o, info) in ops.iter().zip(op.info().operands) {
        match o {
            Opnd::Slot(s) => words.push(*s as u32),
            Opnd::Mem(a, k) => words.extend([*a as u32, *k as u32]),
            Opnd::Imm(v) => match info.kind {
                OperandKind::U64 | OperandKind::I64 => words.extend([*v as u32, (*v >> 32) as u32]),
                _ => words.push(*v as u32),
            },
            Opnd::Imm128(v) => words.extend((0..4).map(|k| (*v >> (32 * k)) as u32)),
            Opnd::Const(k) => words.push(k.0),
            Opnd::Data(d) => words.push(d.0 | crate::insn::ABS_DATA),
            Opnd::Sym(s) => words.push(s.0),
            Opnd::Site(s) => words.push(s.0),
            Opnd::Func(f) => words.push(f.0),
            Opnd::Target(t) => words.push(*t),
            Opnd::Neg(n) => words.push(*n as u32),
            Opnd::Targets(ts) => {
                words.push(ts.len() as u32);
                words.extend_from_slice(ts);
            }
            Opnd::Words(ws) => {
                words.push(ws.len() as u32);
                words.extend_from_slice(ws);
            }
            Opnd::Cases(vals, ts) => {
                let OperandKind::List(e) = info.kind else { unreachable!() };
                words.push(ts.len() as u32);
                for (v, t) in vals.iter().zip(ts) {
                    for k in 0..e.words() - 1 {
                        words.push((*v >> (32 * k)) as u32);
                    }
                    words.push(*t);
                }
            }
        }
    }
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

/// A branch target of [`Asm`]: a position in the code, bound with [`Asm::bind`].
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Label(pub u32);

/// An instruction emitted by [`Asm::insn`], in emission order.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct InsnId(pub u32);

/// Where unwinding out of an instruction goes ([`Asm::set_unwind`]).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Unwind {
    /// Out of the frame, to the caller.
    Continue,
    /// To the landing pad (an `lpad`) at the label; `catch` if it catches every exception
    /// ([`crate::image::CATCH`]).
    Pad { pad: Label, catch: bool },
}

/// An element of a function's code before [`Asm::finish`].
#[derive(Clone, Debug)]
enum Piece {
    /// A fixed item; a call site if `site`'s instruction may unwind.
    Fixed { item: Item, site: Option<InsnId> },
    /// A native item of an inline sequence, its frame displacements raw slots.
    Native(Item),
    /// `reg = v`, where the 32-bit halves flagged in `slots` (bit 0: low, bit 1: high) are raw
    /// slots that become frame offsets.
    SetReg { reg: Reg, v: u64, slots: u8 },
    /// The call marker of the raw result slot.
    Marker(u32),
    /// `lea reg, [rip + x]` of the code constant [`Asm::ro`]`[i]`.
    LeaRo { reg: Reg, ro: u32 },
    /// A branch to the label.
    Branch { cond: Cond, to: Label },
    /// A short forward branch over the next `skip` bytes (inside a call sequence).
    Skip { cond: Cond, skip: u32 },
    /// `lea rcx, [rip + T]` of the instruction's jump table.
    LeaTable,
    /// The jump table: `int3`s up to a multiple of 4, then the entries.
    Table(Vec<Label>),
}

/// An element of a function's code at layout: targets are element indices.
#[derive(Clone, Debug)]
enum Laid {
    /// A fixed item; a call site with its landing pad (element index) and catch flag.
    Fixed { item: Item, site: Option<(Option<usize>, bool)> },
    Branch { cond: Cond, to: usize, long: bool },
    Skip { cond: Cond, skip: u32 },
    LeaTable,
    Table(Vec<usize>),
    /// Padding up to a multiple of 16 (a loop head).
    Align,
}

/// A word of a code constant operand array.
#[derive(Clone, Copy, Debug)]
enum RoWord {
    /// The outgoing argument block's frame offset, `-F`.
    ArgBlock,
    /// A raw slot.
    Slot(u32),
}

/// A code constant, built once the frame size is known.
#[derive(Clone, Debug)]
enum RoReq {
    Bytes(Vec<u8>, usize),
    /// An operand array: the count, then the words.
    Ops(Vec<RoWord>),
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

/// Encodes one function from its instruction words, frame size `F` and cleanup entries:
/// decodes the words and feeds them to an [`Asm`] (slots are already frame offsets).
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

    // Unwind actions, by instruction.
    let mut action: Vec<Option<Unwind>> = vec![None; starts.len()];
    for e in cleanup {
        let i = idx(e.offset).map_err(|_| EncodeError::BadCleanup(e.offset))?;
        let op = Opcode::from_u16(code[starts[i]] as u16).unwrap();
        if !crate::image::op_may_unwind(op) || action[i].is_some() {
            return Err(EncodeError::BadCleanup(e.offset));
        }
        action[i] = Some(if e.target == CONTINUE {
            Unwind::Continue
        } else {
            let p = idx(e.target & !CATCH).map_err(|_| EncodeError::BadCleanup(e.offset))?;
            if Opcode::from_u16(code[starts[p]] as u16) != Some(Opcode::Lpad) {
                return Err(EncodeError::BadCleanup(e.offset));
            }
            Unwind::Pad { pad: Label(p as u32), catch: e.target & CATCH != 0 }
        });
    }

    let mut asm = Asm::new(mode);
    for _ in 0..starts.len() {
        asm.label();
    }
    for (i, &at) in starts.iter().enumerate() {
        asm.bind(Label(i as u32));
        let op = Opcode::from_u16(code[at] as u16).unwrap();
        let ops = operands(code, at)
            .into_iter()
            .map(|o| o.map_targets(|t| idx(t).map(|i| Label(i as u32))))
            .collect::<Result<Vec<_>, _>>()?;
        let id = asm.insn(op, &ops);
        if let Some(a) = action[i] {
            asm.set_unwind(id, a);
        }
    }
    Ok(asm.finish(frame_size, |s| s))
}

/// One function's machine code being built: instructions go in as opcodes and operands
/// ([`Asm::insn`]), each becoming its canonical sequence; [`Asm::finish`] resolves what
/// depends on the frame size, lays out the code (relaxing branches) and writes it.
pub struct Asm {
    mode: Mode,
    pieces: Vec<Piece>,
    /// The piece index each label is bound at (`usize::MAX` while unbound).
    labels: Vec<usize>,
    ro: Vec<RoReq>,
    /// Unwind actions by instruction, for the ones that have one.
    unwind: Vec<Option<Unwind>>,
    /// `Target` operands: (label, the piece index of the instruction's start). The ones bound
    /// at or before their instruction are loop heads.
    targets: Vec<(Label, usize)>,
}

/// The register an operand register value goes in: a constant, or the address of a [`Ref`].
#[derive(Clone, Copy)]
pub(super) enum RegVal {
    Imm(u64),
    Addr(Ref),
}

/// A handler argument register's value for [`Asm`]: a constant with raw slots in the halves
/// `slots` flags, a [`Ref`]'s address, or a code constant's.
#[derive(Clone, Copy)]
enum ArgVal {
    Imm(u64, u8),
    Addr(Ref),
    Ro(u32),
}

impl Asm {
    pub fn new(mode: Mode) -> Asm {
        Asm { mode, pieces: Vec::new(), labels: Vec::new(), ro: Vec::new(), unwind: Vec::new(), targets: Vec::new() }
    }

    /// A new, unbound label.
    pub fn label(&mut self) -> Label {
        self.labels.push(usize::MAX);
        Label(self.labels.len() as u32 - 1)
    }

    /// Binds `l` to the current position.
    pub fn bind(&mut self, l: Label) {
        debug_assert_eq!(self.labels[l.0 as usize], usize::MAX, "label bound twice");
        self.labels[l.0 as usize] = self.pieces.len();
    }

    /// Sets where unwinding out of instruction `id` goes (once; only for instructions that
    /// may unwind). Instructions without an action can't unwind.
    pub fn set_unwind(&mut self, id: InsnId, to: Unwind) {
        let a = &mut self.unwind[id.0 as usize];
        debug_assert!(a.is_none(), "two unwind actions");
        *a = Some(to);
    }

    fn fixed(&mut self, item: Item) {
        self.pieces.push(Piece::Fixed { item, site: None });
    }

    fn maybe_site(&mut self, item: Item, site: Option<InsnId>) {
        self.pieces.push(Piece::Fixed { item, site });
    }

    fn ro(&mut self, r: RoReq) -> u32 {
        self.ro.push(r);
        self.ro.len() as u32 - 1
    }

    /// Sets the argument registers of `op`'s handler from `ops` and calls it.
    fn handler_call(&mut self, op: Opcode, ops: &[Opnd<Label>], site: Option<InsnId>) {
        let l = layouts(self.mode.fp_arg)[op as usize];
        if self.mode.fp_arg {
            self.fixed(Item::Mov(ARGS[0], Reg::Rbp));
        }
        if op.info().shape == Shape::Lpad {
            // The exception object, in `rax` at a landing pad.
            self.fixed(Item::Mov(ARGS[l.first as usize - 1], Reg::Rax));
        }
        for (reg, v) in arg_values(op, &l, ops, self).into_iter().take(l.regs as usize).enumerate() {
            match v {
                Some(ArgVal::Imm(v, 0)) => self.fixed(Item::SetReg(ARGS[reg], v)),
                Some(ArgVal::Imm(v, slots)) => self.pieces.push(Piece::SetReg { reg: ARGS[reg], v, slots }),
                Some(ArgVal::Addr(r)) => self.fixed(Item::Lea(ARGS[reg], r)),
                Some(ArgVal::Ro(ro)) => self.pieces.push(Piece::LeaRo { reg: ARGS[reg], ro }),
                None => {}
            }
        }
        self.maybe_site(Item::Call(Ref::Handler(op)), site);
    }

    /// The direct island call `island(fp, ops)` through the symbol slot `isl`, `ops` the
    /// operand array [`Asm::ro`]`[ro]` (PE: with 32 bytes of shadow space).
    fn island_call(&mut self, isl: Sym, ro: u32, site: Option<InsnId>) {
        let [fp, ops] = island_args(self.mode.pe);
        self.fixed(Item::Mov(fp, Reg::Rbp));
        self.pieces.push(Piece::LeaRo { reg: ops, ro });
        if self.mode.pe {
            self.fixed(Item::SubRsp(32));
        }
        self.maybe_site(Item::CallMem(Ref::Sym(isl)), site);
        if self.mode.pe {
            self.fixed(Item::AddRsp(32));
        }
    }

    fn island_len(&self) -> u32 {
        if self.mode.pe { 3 + 7 + 4 + 6 + 4 } else { 3 + 7 + 6 }
    }

    /// The jump-table sequence on the index in `rax`, with `targets`.
    fn table(&mut self, targets: Vec<Label>) {
        self.pieces.push(Piece::LeaTable);
        self.fixed(Item::LoadTableEntry);
        self.fixed(Item::AddRaxRcx);
        self.fixed(Item::JmpRax);
        self.pieces.push(Piece::Table(targets));
    }

    /// Emits instruction `op` with operands `ops` (in the opcode's operand order).
    pub fn insn(&mut self, op: Opcode, ops: &[Opnd<Label>]) -> InsnId {
        let id = InsnId(self.unwind.len() as u32);
        self.unwind.push(None);
        let site = Some(id);
        let info = op.info();
        for o in ops {
            if let Opnd::Target(t) = o {
                self.targets.push((*t, self.pieces.len()));
            }
        }
        if let Some((items, br)) = super::inline::sequence(op, ops) {
            self.pieces.extend(items.into_iter().map(Piece::Native));
            if let Some(cond) = br {
                let Some(Opnd::Target(t)) = ops.last() else { unreachable!("a branch's target is last") };
                self.pieces.push(Piece::Branch { cond, to: *t });
            }
            return id;
        }
        let named = |name: &str| &ops[info.operand_index(name).expect("operand")];
        let slot = |name: &str| match named(name) {
            Opnd::Slot(s) => *s as u32,
            _ => unreachable!(),
        };
        let sym = |name: &str| match named(name) {
            Opnd::Sym(s) => *s,
            _ => unreachable!(),
        };
        let target = |name: &str| match named(name) {
            Opnd::Target(t) => *t,
            _ => unreachable!(),
        };
        match info.shape {
            Shape::Op | Shape::Lpad => self.handler_call(op, ops, None),
            Shape::Br => {
                self.handler_call(op, ops, None);
                self.fixed(Item::TestAl);
                let Opnd::Neg(neg) = named("neg") else { unreachable!() };
                let cond = if *neg { Cond::Z } else { Cond::Nz };
                self.pieces.push(Piece::Branch { cond, to: target("t") });
            }
            Shape::Switch => {
                self.handler_call(op, ops, None);
                let mut ts = Vec::new();
                for o in ops {
                    if let Opnd::Targets(t) | Opnd::Cases(_, t) = o {
                        ts.extend_from_slice(t);
                    }
                }
                ts.push(target("default"));
                self.table(ts);
            }
            Shape::Trap => {
                self.handler_call(op, ops, site);
                self.fixed(Item::Ud2);
            }
            Shape::Ret => {
                self.handler_call(op, ops, None);
                self.fixed(Item::Leave);
                self.fixed(Item::Ret);
            }
            Shape::Jmp => self.pieces.push(Piece::Branch { cond: Cond::Always, to: target("t") }),
            Shape::Call => {
                let Opnd::Func(f) = named("f") else { unreachable!() };
                self.maybe_site(Item::Call(Ref::Func(*f)), site);
                self.pieces.push(Piece::Marker(slot("d")));
            }
            Shape::CallExt | Shape::CallInd => {
                self.handler_call(op, ops, None);
                // `rax`: the VM entry, or 0 for the native path through the island.
                let fnp = if info.shape == Shape::CallExt { slot("f") } else { slot("p") };
                let d = slot("d");
                let ro = self.ro(RoReq::Ops(vec![RoWord::ArgBlock, RoWord::Slot(d), RoWord::Slot(fnp)]));
                self.fixed(Item::TestRax);
                self.pieces.push(Piece::Skip { cond: Cond::Z, skip: 2 + 7 + 2 });
                self.maybe_site(Item::CallRax, site);
                self.pieces.push(Piece::Marker(d));
                self.pieces.push(Piece::Skip { cond: Cond::Always, skip: self.island_len() });
                self.island_call(sym("isl"), ro, site);
            }
            Shape::TailCall => {
                self.handler_call(op, ops, None);
                self.fixed(Item::Leave);
                let Opnd::Func(f) = named("f") else { unreachable!() };
                self.fixed(Item::Jmp(Ref::Func(*f)));
            }
            Shape::TailCallInd => {
                self.handler_call(op, ops, None);
                let s = slot("s");
                let ro = self.ro(RoReq::Ops(vec![RoWord::ArgBlock, RoWord::Slot(s), RoWord::Slot(slot("p"))]));
                self.fixed(Item::TestRax);
                self.pieces.push(Piece::Skip { cond: Cond::Z, skip: 1 + 2 });
                self.fixed(Item::Leave);
                self.fixed(Item::JmpRax);
                self.island_call(sym("isl"), ro, site);
                // Then `ret s, len`.
                let ret = [Opnd::Slot(s as i32), named("len").clone()];
                self.handler_call(Opcode::Ret, &ret, None);
                self.fixed(Item::Leave);
                self.fixed(Item::Ret);
            }
            Shape::Island => {
                let Opnd::Words(w) = named("ops") else { unreachable!() };
                let ro = self.ro(RoReq::Ops(w.iter().map(|&w| RoWord::Slot(w)).collect()));
                self.island_call(sym("isl"), ro, site);
            }
        }
        id
    }

    /// Finishes the function in a frame of size `frame_size`: `fix` turns a raw slot into
    /// its frame offset. Every label a branch uses must be bound.
    pub fn finish(self, frame_size: u32, fix: impl Fn(u32) -> u32) -> Encoded {
        let Asm { mode, pieces, labels, ro, unwind, targets } = self;
        // Code constants, in emission order (so deduplication matches the word encoder's).
        let mut rodata = Rodata::default();
        let argblk = (frame_size as i32).wrapping_neg() as u32;
        let ro_off: Vec<u32> = ro
            .into_iter()
            .map(|r| match r {
                RoReq::Bytes(b, align) => rodata.add(b, align),
                RoReq::Ops(ws) => {
                    let w: Vec<u32> = ws
                        .iter()
                        .map(|w| match *w {
                            RoWord::ArgBlock => argblk,
                            RoWord::Slot(s) => fix(s),
                        })
                        .collect();
                    rodata.ops(&w)
                }
            })
            .collect();

        // Loop heads: labels bound before a branch to them.
        let mut head = vec![false; pieces.len() + 1];
        if mode.align_loops {
            for (to, k) in targets {
                let at = labels[to.0 as usize];
                debug_assert_ne!(at, usize::MAX, "unbound label");
                if at <= k {
                    head[at] = true;
                }
            }
        }

        // The prologue, then the pieces with alignment padding, frame offsets and code
        // constants resolved. `remap[k]` is the element of piece `k` (after its padding).
        let mut out: Vec<Laid> = Vec::with_capacity(pieces.len() + 8);
        let fixed = |out: &mut Vec<Laid>, item| out.push(Laid::Fixed { item, site: None });
        // `push rbp; mov rbp, rsp`, then for `F > 0` (with a stack probe from 4096 bytes)
        // `sub rsp, F`.
        fixed(&mut out, Item::PushRbp);
        fixed(&mut out, Item::Mov(Reg::Rbp, Reg::Rsp));
        if frame_size >= PROBE_FROM {
            fixed(&mut out, Item::SetReg(Reg::Rax, frame_size as u64));
            fixed(&mut out, Item::Call(Ref::Probe));
        }
        if frame_size != 0 {
            fixed(&mut out, Item::SubRsp(frame_size));
        }
        let mut remap = Vec::with_capacity(pieces.len() + 1);
        let lab = |l: &Label| labels[l.0 as usize];
        let mut tables = Vec::new();
        let mut branches = Vec::new();
        let mut sites = Vec::new();
        for (k, p) in pieces.into_iter().enumerate() {
            if head[k] {
                out.push(Laid::Align);
            }
            remap.push(out.len());
            out.push(match p {
                Piece::Fixed { item, site } => {
                    let a = site.and_then(|id| unwind[id.0 as usize]);
                    if let Some(Unwind::Pad { pad, .. }) = a {
                        sites.push((out.len(), lab(&pad)));
                    }
                    Laid::Fixed {
                        item,
                        site: a.map(|a| match a {
                            Unwind::Continue => (None, false),
                            Unwind::Pad { catch, .. } => (Some(usize::MAX), catch),
                        }),
                    }
                }
                Piece::Marker(d) => Laid::Fixed { item: Item::Marker(fix(d) as i32), site: None },
                Piece::Native(item) => Laid::Fixed { item: item.map_frame(|s| fix(s as u32) as i32), site: None },
                Piece::SetReg { reg, v, slots } => {
                    let mut v = v;
                    if slots & 1 != 0 {
                        v = v & !0xffff_ffff | fix(v as u32) as u64;
                    }
                    if slots & 2 != 0 {
                        v = v & 0xffff_ffff | (fix((v >> 32) as u32) as u64) << 32;
                    }
                    Laid::Fixed { item: Item::SetReg(reg, v), site: None }
                }
                Piece::LeaRo { reg, ro } => Laid::Fixed { item: Item::Lea(reg, Ref::Ro(ro_off[ro as usize])), site: None },
                Piece::Branch { cond, to } => {
                    branches.push(out.len());
                    Laid::Branch { cond, to: lab(&to), long: false }
                }
                Piece::Skip { cond, skip } => Laid::Skip { cond, skip },
                Piece::LeaTable => Laid::LeaTable,
                Piece::Table(ts) => {
                    tables.push(out.len());
                    Laid::Table(ts.iter().map(lab).collect())
                }
            });
        }
        if head.last() == Some(&true) {
            out.push(Laid::Align);
        }
        remap.push(out.len());
        // Piece indices to element indices.
        for &b in &branches {
            if let Laid::Branch { to, .. } = &mut out[b] {
                *to = remap[*to];
            }
        }
        for &t in &tables {
            if let Laid::Table(ts) = &mut out[t] {
                for x in ts {
                    *x = remap[*x];
                }
            }
        }
        for (e, pad) in sites {
            if let Laid::Fixed { site: Some((p, _)), .. } = &mut out[e] {
                *p = Some(remap[pad]);
            }
        }
        let mut e = layout_code(out);
        e.rodata = rodata.bytes;
        e
    }
}

/// Every opcode's handler register layout, without and with `fp-arg`, computed at compile
/// time.
fn layouts(fp_arg: bool) -> &'static [Layout] {
    const fn all(fp_arg: bool) -> [Layout; crate::insn::ALL_OPCODES.len()] {
        let mode = Mode { fp_arg, align_loops: false, pe: false };
        let mut out = [layout(Opcode::Jmp, mode); crate::insn::ALL_OPCODES.len()];
        let mut i = 0;
        while i < out.len() {
            out[i] = layout(crate::insn::ALL_OPCODES[i], mode);
            i += 1;
        }
        out
    }
    static NO_FP: [Layout; crate::insn::ALL_OPCODES.len()] = all(false);
    static FP: [Layout; crate::insn::ALL_OPCODES.len()] = all(true);
    if fp_arg { &FP } else { &NO_FP }
}

/// Lays out the elements (relaxing branches) and writes the code.
fn layout_code(mut pieces: Vec<Laid>) -> Encoded {
    const VAR: u32 = u32::MAX;
    let n = pieces.len();
    // Lengths that don't depend on the position (`VAR` for the others), and the short
    // branches, which may grow.
    let mut lens: Vec<u32> = Vec::with_capacity(n);
    let mut short = Vec::new();
    for (k, piece) in pieces.iter().enumerate() {
        lens.push(match piece {
            Laid::Fixed { item, .. } => item.len(),
            Laid::Branch { cond, long, .. } => {
                if !long {
                    short.push(k);
                }
                Item::Branch { cond: *cond, target: 0, long: *long }.len()
            }
            Laid::Skip { .. } => 2,
            Laid::LeaTable => 7,
            Laid::Table(_) | Laid::Align => VAR,
        });
    }
    let mut pos = vec![0u32; n + 1];
    loop {
        let mut p = 0u32;
        for (k, &len) in lens.iter().enumerate() {
            pos[k] = p;
            p += if len != VAR {
                len
            } else {
                match &pieces[k] {
                    Laid::Table(t) => p.next_multiple_of(4) - p + 4 * t.len() as u32,
                    _ => p.next_multiple_of(16) - p,
                }
            };
        }
        pos[n] = p;
        let mut changed = false;
        short.retain(|&k| {
            let Laid::Branch { to, cond, long } = &mut pieces[k] else { unreachable!() };
            let d = pos[*to] as i64 - (pos[k] as i64 + 2);
            if i8::try_from(d).is_ok() {
                return true;
            }
            *long = true;
            lens[k] = Item::Branch { cond: *cond, target: 0, long: true }.len();
            changed = true;
            false
        });
        if !changed {
            break;
        }
    }
    let mut out = Encoded { code: Vec::with_capacity(pos[n] as usize), ..Default::default() };
    let mut items = Vec::new();
    for (k, piece) in pieces.iter().enumerate() {
        let p = pos[k];
        items.clear();
        let mut site = None;
        match piece {
            Laid::Fixed { item, site: s } => {
                items.push(*item);
                site = *s;
            }
            Laid::Branch { cond, to, long } => items.push(Item::Branch { cond: *cond, target: pos[*to], long: *long }),
            Laid::Skip { cond, skip } => items.push(Item::Branch { cond: *cond, target: p + 2 + skip, long: false }),
            Laid::LeaTable => {
                // The table follows the rest of the sequence: `movsxd`, `add`, `jmp rax`.
                let t = (p + 7 + 4 + 3 + 2).next_multiple_of(4);
                items.push(Item::LeaTable(t));
            }
            Laid::Table(targets) => {
                for _ in p..p.next_multiple_of(4) {
                    items.push(Item::Int3);
                }
                let base = p.next_multiple_of(4);
                for &t in targets {
                    items.push(Item::TableEntry { base, target: pos[t] });
                }
            }
            Laid::Align => padding(p.next_multiple_of(16) - p, &mut items),
        }
        let mut q = p;
        for it in &items {
            if let Some((pad, catch)) = site {
                out.call_sites.push(CallSite { start: q, len: it.len(), pad: pad.map(|e| pos[e]), catch });
            }
            it.write(q, &mut out.code, &mut out.relocs);
            q += it.len();
        }
    }
    debug_assert_eq!(out.code.len(), pos[n] as usize);
    out
}

/// Functions with frames of at least this size probe the stack in the prologue.
pub const PROBE_FROM: u32 = 4096;

/// The values of `op`'s handler argument registers for operands `ops` (`None` for the
/// registers set otherwise: `fp`, the exception object). Adds case value arrays to `asm`'s
/// code constants.
fn arg_values(op: Opcode, l: &Layout, ops: &[Opnd<Label>], asm: &mut Asm) -> [Option<ArgVal>; super::ARG_REGS] {
    let info = op.info();
    let mut regs = [None; super::ARG_REGS];
    // `slot`: the value is a raw slot.
    let mut set = |loc: Loc, part: u8, v: ArgVal, slot: bool| {
        let r = &mut regs[(loc.reg + part) as usize];
        let half = |shift: u8| if slot { 1u8 << (shift / 32) } else { 0 };
        *r = Some(match (v, *r) {
            (ArgVal::Imm(v, _), Some(ArgVal::Imm(lo, m))) if loc.shared => ArgVal::Imm(lo | v << loc.shift, m | half(loc.shift)),
            (ArgVal::Imm(v, _), None) if loc.shared => ArgVal::Imm(v << loc.shift, half(loc.shift)),
            (ArgVal::Imm(v, _), _) => ArgVal::Imm(v, half(0)),
            (v, _) => v,
        });
    };
    for (i, o) in ops.iter().enumerate() {
        let loc = l.locs[i];
        if loc.count == 0 {
            continue;
        }
        let imm = |v: u64| ArgVal::Imm(v, 0);
        match o {
            Opnd::Slot(s) => set(loc, 0, imm(*s as u32 as u64), true),
            Opnd::Mem(p, k) => {
                set(loc, 0, imm(*p as u32 as u64), true);
                set(loc, 1, imm(*k as u32 as u64), false);
            }
            Opnd::Imm(v) => set(loc, 0, imm(*v), false),
            Opnd::Imm128(v) => {
                set(loc, 0, imm(*v as u64), false);
                set(loc, 1, imm((*v >> 64) as u64), false);
            }
            Opnd::Const(k) => set(loc, 0, ArgVal::Addr(Ref::Const(*k)), false),
            Opnd::Data(d) => set(loc, 0, ArgVal::Addr(Ref::Data(*d)), false),
            Opnd::Sym(s) => set(loc, 0, ArgVal::Addr(Ref::Sym(*s)), false),
            Opnd::Site(s) => set(loc, 0, ArgVal::Addr(Ref::Site(*s)), false),
            Opnd::Targets(t) => set(loc, 0, imm(t.len() as u64), false),
            Opnd::Cases(vals, _) => {
                let OperandKind::List(e) = info.operands[i].kind else { unreachable!() };
                let size = case_size(e);
                let mut b = Vec::with_capacity(vals.len() * size);
                for v in vals {
                    b.extend_from_slice(&v.to_le_bytes()[..size]);
                }
                let ro = asm.ro(RoReq::Bytes(b, size.max(4)));
                set(loc, 0, ArgVal::Ro(ro), false);
                set(loc, 1, imm(vals.len() as u64), false);
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
