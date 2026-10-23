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

use super::reduced::Then;
use super::x86::{ARGS, Cond, Item, M, Reg, Sh, W, island_args, padding};
use super::{ArgReg, Layout, Loc, Mode, RetPart, layout, ret_parts};
use crate::full::{Const, Data, DecodeError, ElemKind, Func, Opcode, OperandKind, Shape, Site, Sym, insn_len};
use crate::image::{CATCH, CONTINUE, CleanupEntry};
use crate::reduced::Arg;

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
    /// The function's own JIT record (`image::JitRecord`), which its counter stubs load
    /// ([`Mode::counters`]).
    Rec,
    /// The counter of the function's JIT record from the field of `sub qword [rip + x],
    /// imm8`, which the immediate follows: the field holds `record - (field + 5)`, so this
    /// target is the record's address less one.
    RecCtr,
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
    /// The stores the encoder dropped as dead ([`Asm::dead`]), sorted by position: for the
    /// decoder, which can't see them in the code.
    pub dropped: Vec<DroppedStore>,
    /// Where frame objects escape and where their storage ends ([`Asm::escape`],
    /// [`Asm::storage_end`]), sorted by position. Like `dropped`, side data for the decoder:
    /// the machine code doesn't show them.
    pub scopes: Vec<Scope>,
    /// Where the prologue starts: after the entry's counter check with
    /// [`Mode::counters`], else 0.
    pub prologue: u32,
    /// Where the out-of-line stub of the entry's counter starts, the last element of the
    /// code (its frame isn't set up yet, unlike everywhere else past the prologue); the
    /// code's length without counters.
    pub entry_stub: u32,
}

/// A change in which frame bytes may be reached through a pointer, at a code position. In
/// [`Encoded::scopes`] the position is a byte offset in the machine code, in
/// [`super::Decoded::scopes`] a word offset in the instruction words.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Scope {
    /// Where the change takes effect: before the instruction at this position (or at the end
    /// of the function). For an escape, the address-taking instruction; for an end, the
    /// first instruction after the storage is dead.
    pub code_offset: u32,
    /// Signed byte offset from `fp` of the start of the object: the whole local or
    /// temporary, not the addressed field.
    pub frame_offset: i32,
    /// Size of the object in bytes.
    pub size: u32,
    pub kind: ScopeKind,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum ScopeKind {
    /// A pointer to the object escapes here (`addr`, or a call argument passed by address).
    /// Until a later `End` covers them, any access through a pointer may read or write any
    /// of the object's bytes.
    Escape {
        /// The object's alignment in bytes (a power of two, at most 16): what an optimizer
        /// needs to move an escaped object, or to merge two into one slot.
        align: u32,
    },
    /// The object's storage ends here (`StorageDead`, or the temporaries' reset after a
    /// statement). Pointers to it dangle afterwards, so earlier escapes of these bytes stop
    /// here, and other locals may reuse them.
    End,
}

/// A store of an inline sequence the encoder dropped: the sequence ends at `at` without it.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct DroppedStore {
    pub at: u32,
    pub(super) item: Item,
}

impl DroppedStore {
    /// The store: `mov [fp + frame_offset], reg` of `size` bytes (1, 2, 4 or 8), the register
    /// by its x86 number, as an image stores it.
    pub fn parts(&self) -> (i32, u8, u8) {
        let Item::St { w, src, m } = self.item else { unreachable!("a dropped store is a register store") };
        (m.disp, (w.bits() / 8) as u8, src as u8)
    }

    /// The dropped store [`DroppedStore::parts`] describe, at `at`, if they describe one: a
    /// register the inline sequences compute in.
    pub fn from_parts(at: u32, frame_offset: i32, size: u8, reg: u8) -> Option<DroppedStore> {
        let w = match size {
            1 => W::B,
            2 => W::W,
            4 => W::D,
            8 => W::Q,
            _ => return None,
        };
        let src = Reg::from_num(reg).filter(|r| super::inline::POOL.contains(r))?;
        Some(DroppedStore { at, item: Item::St { w, src, m: M::frame(frame_offset) } })
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum EncodeError {
    Decode(DecodeError),
    /// A branch target that isn't an instruction start (word offset of the instruction).
    BadTarget(u32),
    /// A cleanup entry not at an instruction that may unwind, or whose landing pad isn't an
    /// `lpad`.
    BadCleanup(u32),
    /// A call or `ret` whose return value the machine code can't pass, or an `arg` with an
    /// invalid register ([`super::return_ok`]) (word offset of the instruction).
    BadReturn(u32),
    /// An `arg` after an instruction that isn't one (word offset).
    ArgNotFirst(u32),
    /// A dropped store at an instruction that doesn't end in a register store to the frame
    /// ([`super::encode_reduced`]; word offset).
    BadDropped(u32),
    /// A reduced `handler` whose targets don't fit its handler's shape (word offset).
    BadHandler(u32),
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
            OperandKind::Abs => match crate::full::Abs::from_word(w(0)) {
                crate::full::Abs::Const(k) => Opnd::Const(k),
                crate::full::Abs::Data(d) => Opnd::Data(d),
            },
            OperandKind::Sym => Opnd::Sym(Sym(w(0))),
            OperandKind::Site => Opnd::Site(Site(w(0))),
            OperandKind::Func => Opnd::Func(Func(w(0))),
            OperandKind::Target => Opnd::Target(target(w(0))),
            OperandKind::Neg => Opnd::Neg(w(0) != 0),
            OperandKind::Handler | OperandKind::List(ElemKind::Arg) => unreachable!("not in the full set"),
            OperandKind::List(e) => {
                let n = w(0) as usize;
                let el = |i: usize, j: usize| code[pos + 1 + i * e.words() + j];
                let o = match e {
                    ElemKind::Target => Opnd::Targets((0..n).map(|i| target(el(i, 0))).collect()),
                    ElemKind::Word => Opnd::Words((0..n).map(|i| el(i, 0)).collect()),
                    ElemKind::Arg => unreachable!("not in the full set"),
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
            Opnd::Data(d) => words.push(d.0 | crate::full::ABS_DATA),
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

/// The integer argument register `i` of the convention: `rdi rsi rdx rcx r8 r9`, on PE
/// `rcx rdx r8 r9`.
pub(super) fn int_arg(pe: bool, i: u32) -> Reg {
    const SYSV: [Reg; 6] = [Reg::Rdi, Reg::Rsi, Reg::Rdx, Reg::Rcx, Reg::R8, Reg::R9];
    const WIN64: [Reg; 4] = [Reg::Rcx, Reg::Rdx, Reg::R8, Reg::R9];
    if pe { WIN64[i as usize] } else { SYSV[i as usize] }
}

/// `f16` values move between SSE registers and memory through this register (`movd`).
const F16_TMP: Reg = Reg::R11;

/// The operand width of 1, 2, 4 or 8 bytes.
fn width(size: u32) -> W {
    match size {
        1 => W::B,
        2 => W::W,
        4 => W::D,
        _ => W::Q,
    }
}

/// The register parts of the kind `k` with their registers: `rax`, `rdx` for integers,
/// `xmm0`, `xmm1` for floats, in order.
fn part_regs(k: u32, load: bool) -> Vec<(RetPart, Reg, u8)> {
    let Some(parts) = ret_parts(k, load) else { return Vec::new() };
    let (mut g, mut x) = (0, 0);
    parts
        .into_iter()
        .flatten()
        .map(|p| {
            let r = (p, [Reg::Rax, Reg::Rdx][g], x);
            if p.xmm {
                x += 1
            } else {
                g += 1
            }
            r
        })
        .collect()
}

/// The store of `size` bytes of SSE register `x` at `m`.
fn sse_store(size: u32, x: u8, m: M, out: &mut Vec<Item>) {
    if size == 2 {
        out.extend([Item::Movd { to_xmm: false, x, r: F16_TMP }, Item::St { w: W::W, src: F16_TMP, m }]);
    } else {
        out.push(Item::Sse { st: true, size: size as u8, x, m });
    }
}

/// The store of the low `size` bytes (1 to 8) of `r` at `m`: in pieces of 4, 2 and 1 bytes,
/// shifting `r` down between them, unless it is 1, 2, 4 or 8.
fn int_store(size: u32, r: Reg, m: M, out: &mut Vec<Item>) {
    if matches!(size, 1 | 2 | 4 | 8) {
        out.push(Item::St { w: width(size), src: r, m });
        return;
    }
    let (mut done, mut prev) = (0, 0);
    for c in [4, 2, 1] {
        if size - done >= c {
            if prev != 0 {
                out.push(Item::Shift { op: Sh::Shr, w: W::Q, reg: r, amt: (8 * prev) as u8 });
            }
            out.push(Item::St { w: width(c), src: r, m: M { disp: m.disp.wrapping_add(done as i32), ..m } });
            done += c;
            prev = c;
        }
    }
}

/// `ret`'s loads of the value of kind `k` (load widths) at the raw slot `s` into the return
/// registers ([`super::RET_SRET`]).
pub(super) fn ret_loads(k: u32, s: i32) -> Vec<Item> {
    let mut out = Vec::new();
    for (p, r, x) in part_regs(k, true) {
        let m = M::frame(s.wrapping_add(p.off as i32));
        match (p.xmm, p.size) {
            (false, size) => out.push(Item::Ld { w: width(size), sx: false, dst: r, m }),
            (true, 2) => out.extend([Item::Ld { w: W::W, sx: false, dst: F16_TMP, m }, Item::Movd { to_xmm: true, x, r: F16_TMP }]),
            (true, size) => out.push(Item::Sse { st: false, size: size as u8, x, m }),
        }
    }
    out
}

/// The stores of a call's result of kind `k` (exact sizes) from the return registers into
/// the raw slot `d`: none for nothing and for sret, whose callee writes `d` itself.
pub(super) fn result_stores(k: u32, d: i32) -> Vec<Item> {
    let mut out = Vec::new();
    for (p, r, x) in part_regs(k, false) {
        let m = M::frame(d.wrapping_add(p.off as i32));
        if p.xmm { sse_store(p.size, x, m, &mut out) } else { int_store(p.size, r, m, &mut out) }
    }
    out
}

/// `arg`'s store of the argument register `a` to the raw slot `d`.
pub(super) fn arg_store(a: ArgReg, d: i32, pe: bool) -> Vec<Item> {
    let mut out = Vec::new();
    let m = M::frame(d);
    if a.xmm {
        sse_store(a.size, a.index as u8, m, &mut out);
    } else {
        int_store(a.size, int_arg(pe, a.index), m, &mut out);
    }
    out
}

/// A call argument list entry's load of the raw slot `s` into its register ([`super::params_ok`]).
pub(super) fn param_load(s: i32, w: u32, pe: bool) -> Vec<Item> {
    let a = super::param_reg(w).expect("argument register");
    let m = M::frame(s);
    if w & super::ARG_ADDR != 0 {
        return vec![Item::LeaM { dst: int_arg(pe, a.index), m }];
    }
    match (a.xmm, a.size) {
        (false, size) => vec![Item::Ld { w: width(size), sx: false, dst: int_arg(pe, a.index), m }],
        (true, 2) => vec![Item::Ld { w: W::W, sx: false, dst: F16_TMP, m }, Item::Movd { to_xmm: true, x: a.index as u8, r: F16_TMP }],
        (true, size) => vec![Item::Sse { st: false, size: size as u8, x: a.index as u8, m }],
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
        ElemKind::Target | ElemKind::Word | ElemKind::Arg => unreachable!("not a case list"),
    }
}

/// The element kind of `op`'s case list, if it has one.
pub(super) fn case_elem(op: Opcode) -> Option<ElemKind> {
    op.info().operands.iter().find_map(|o| match o.kind {
        OperandKind::List(e @ (ElemKind::Case8 | ElemKind::Case16 | ElemKind::Case32 | ElemKind::Case64 | ElemKind::Case128)) => Some(e),
        _ => None,
    })
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
    /// A fixed item whose frame displacements are raw slots: the loads of a returned value
    /// and the stores of a call's result, outside the register cache.
    Frame(Item),
    /// `lea reg, [rip + x]` of the code constant [`Asm::ro`]`[i]`.
    LeaRo { reg: Reg, ro: u32 },
    /// A branch to the label.
    Branch { cond: Cond, to: Label },
    /// `reg = fp`: `mov reg, rbp`, or without a frame pointer `lea reg, [rsp + F]`.
    Fp(Reg),
    /// The epilogue before `ret` or a tail jump: `leave`, or without a frame pointer
    /// `add rsp, F + 8`.
    Epilogue,
    /// `lea rcx, [rip + T]` of the instruction's jump table.
    LeaTable,
    /// The jump table: `int3`s up to a multiple of 4, then the entries.
    Table(Vec<Label>),
    /// A native item the register cache dropped.
    Gone,
    /// The raw slots `lo .. lo + len` are dead: nothing reads them before writing them
    /// ([`Asm::dead`]).
    Dead { lo: i32, len: u32 },
    /// A store dropped as dead.
    Dropped(Item),
    /// An escape or a storage end ([`Scope`]) here, its frame offset a raw slot: no code.
    Scope { slot: u32, size: u32, kind: ScopeKind },
}

/// Whether each piece is a branch target (one more for the end).
fn branch_targets(pieces: &[Piece], labels: &[usize]) -> Vec<bool> {
    let mut target = vec![false; pieces.len() + 1];
    for p in pieces {
        match p {
            Piece::Branch { to, .. } => target[labels[to.0 as usize]] = true,
            Piece::Table(ls) => ls.iter().for_each(|l| target[labels[l.0 as usize]] = true),
            _ => {}
        }
    }
    target
}

/// Drops the stores of inline sequences that nothing reads from the frame before the slot is
/// dead ([`Piece::Dead`]) or overwritten. A stored value that is read again is read from the
/// register the cache keeps it in, so dropping the store leaves only the frame stale, where
/// nothing reads it. A store must stay if a flush point comes first: a branch target, a
/// branch, any instruction that isn't inline (handlers read the frame), a frame read, or a
/// pointer access if a pointer may reach the slot. Pointers into the frame only come from the
/// function's `addr`s, so a dead range no `addr` points into is out of every pointer's reach.
fn drop_dead_stores(pieces: &mut [Piece], target: &[bool]) {
    struct Pending {
        k: usize,
        lo: i32,
        len: u32,
        /// A pointer was used since the store.
        ptr: bool,
    }
    let within = |lo: i32, len: u32, a: i32, n: u32| (a.wrapping_sub(lo) as u32) <= len.saturating_sub(n) && n <= len;
    let overlaps = |a: i32, n: u32, b: i32, m: u32| (b.wrapping_sub(a) as u32) < n || (a.wrapping_sub(b) as u32) < m;
    let addrs: Vec<i32> = pieces
        .iter()
        .filter_map(|p| match p {
            Piece::Native(Item::LeaM { m, .. }) if m.base == Reg::Rbp => Some(m.disp),
            _ => None,
        })
        .collect();
    let mut pending: Vec<Pending> = Vec::new();
    let mut drop = Vec::new();
    for k in 0..pieces.len() {
        if target[k] {
            pending.clear();
        }
        match pieces[k] {
            Piece::Native(it) => {
                if let Some(m) = it.mem() {
                    if m.base != Reg::Rbp {
                        pending.iter_mut().for_each(|p| p.ptr = true);
                    }
                }
                // Frame reads (and addresses) keep the stores they overlap.
                if let Some((m, n)) = it.frame_read() {
                    pending.retain(|p| !overlaps(p.lo, p.len, m.disp, n));
                }
                if let Some((m, n)) = it.frame_write() {
                    // Fully overwritten stores are dead, unless a pointer may have read them;
                    // partly overwritten ones stay.
                    pending.retain(|p| {
                        if within(m.disp, n, p.lo, p.len) && !p.ptr {
                            drop.push(p.k);
                            false
                        } else {
                            !overlaps(p.lo, p.len, m.disp, n)
                        }
                    });
                    if let Item::St { src, .. } = it
                        && src != Reg::Rcx
                    {
                        pending.push(Pending { k, lo: m.disp, len: n, ptr: false });
                    }
                }
            }
            Piece::Dead { lo, len } => pending.retain(|p| {
                let safe = !addrs.iter().any(|&a| (a.wrapping_sub(lo) as u32) < len);
                if within(lo, len, p.lo, p.len) && (safe || !p.ptr) {
                    drop.push(p.k);
                    false
                } else {
                    !overlaps(p.lo, p.len, lo, len)
                }
            }),
            Piece::Gone | Piece::Scope { .. } => {}
            _ => pending.clear(),
        }
    }
    for k in drop {
        let Piece::Native(it) = pieces[k] else { unreachable!() };
        pieces[k] = Piece::Dropped(it);
    }
}

/// Runs the register cache ([`super::inline::Cache`]) over the inline sequences: from the
/// start of the code, and cleared at every branch target and by every other instruction.
fn cache(pieces: &mut [Piece], target: &[bool]) {
    let mut c = super::inline::Cache::default();
    let mut items = Vec::new();
    let mut k = 0;
    while k < pieces.len() {
        if target[k] {
            c = Default::default();
        }
        if !matches!(pieces[k], Piece::Native(_)) {
            if !matches!(pieces[k], Piece::Dead { .. } | Piece::Scope { .. }) {
                c = Default::default();
            }
            k += 1;
            continue;
        }
        // One sequence: native items up to its write, or up to its branch.
        let start = k;
        items.clear();
        while let Some(&Piece::Native(it)) = pieces.get(k) {
            items.push(it);
            k += 1;
            if it.ends_inline() {
                break;
            }
        }
        let out = c.emit(&items);
        let dropped = items.len() - out.len();
        for (j, p) in pieces[start..k].iter_mut().enumerate() {
            *p = if j < dropped { Piece::Gone } else { Piece::Native(out[j - dropped]) };
        }
        // A compare-branch's branch keeps the cache.
        if !items.last().is_some_and(Item::ends_inline) && matches!(pieces.get(k), Some(Piece::Branch { cond, .. }) if *cond != Cond::Always) {
            k += 1;
        }
    }
}

/// An element of a function's code at layout: targets are element indices.
#[derive(Clone, Debug)]
enum Laid {
    /// A fixed item; a call site with its landing pad (element index) and catch flag.
    Fixed {
        item: Item,
        site: Option<(Option<usize>, bool)>,
    },
    Branch {
        cond: Cond,
        to: usize,
        long: bool,
    },
    LeaTable,
    Table(Vec<usize>),
    /// Padding up to a multiple of 16 (a loop head).
    Align,
    /// A store dropped as dead, at this position: no code.
    Dropped(Item),
    /// A scope change at this position: no code.
    Scope(Scope),
}

/// A word of a code constant operand array.
#[derive(Clone, Copy, Debug)]
pub(super) enum RoWord {
    /// A raw slot.
    Slot(u32),
}

/// A code constant, built once the frame size is known.
#[derive(Clone, Debug)]
pub(super) enum RoReq {
    Bytes(Vec<u8>, usize),
    /// An operand array: the count, then the words.
    Ops(Vec<RoWord>),
}

/// The rodata being built, deduplicated.
#[derive(Default)]
pub(super) struct Rodata {
    bytes: Vec<u8>,
    seen: BTreeMap<(Vec<u8>, usize), u32>,
}

impl Rodata {
    pub(super) fn add(&mut self, bytes: Vec<u8>, align: usize) -> u32 {
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
    pub(super) fn ops(&mut self, words: &[u32]) -> u32 {
        let mut b = Vec::with_capacity(4 + 4 * words.len());
        b.extend_from_slice(&(words.len() as u32).to_le_bytes());
        for w in words {
            b.extend_from_slice(&w.to_le_bytes());
        }
        self.add(b, 4) + 4
    }
}

/// Encodes one function from its instruction words, frame size `F`, cleanup entries and
/// scopes (sorted, at word offsets of instructions or the end): decodes the words and feeds
/// them to an [`Asm`] (slots are already frame offsets).
pub fn encode(code: &[u32], frame_size: u32, cleanup: &[CleanupEntry], scopes: &[Scope], mode: Mode) -> Result<Encoded, EncodeError> {
    let mut starts = Vec::new();
    let mut index = vec![usize::MAX; code.len() + 1];
    let mut at = 0;
    while at < code.len() {
        index[at] = starts.len();
        starts.push(at);
        at += insn_len(&code[at..]).map_err(EncodeError::Decode)?;
        crate::full::Insn::decode(&code[starts[starts.len() - 1]..]).map_err(EncodeError::Decode)?;
        let start = starts[starts.len() - 1];
        if !super::return_ok(&code[start..]) {
            return Err(EncodeError::BadReturn(start as u32));
        }
        if code[start] == Opcode::Arg as u32 && starts[..starts.len() - 1].iter().any(|&a| code[a] != Opcode::Arg as u32) {
            return Err(EncodeError::ArgNotFirst(start as u32));
        }
    }
    let idx = |w: u32| -> Result<usize, EncodeError> { index.get(w as usize).copied().filter(|&i| i != usize::MAX).ok_or(EncodeError::BadTarget(w)) };

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
    let mut scopes = scopes.iter().peekable();
    let mut scopes_at = |asm: &mut Asm, at: usize| -> Result<(), EncodeError> {
        while let Some(sc) = scopes.next_if(|sc| sc.code_offset as usize <= at) {
            if sc.code_offset as usize != at {
                return Err(EncodeError::BadTarget(sc.code_offset));
            }
            match sc.kind {
                ScopeKind::Escape { align } => asm.escape(sc.frame_offset as u32, sc.size, align),
                ScopeKind::End => asm.storage_end(sc.frame_offset as u32, sc.size),
            }
        }
        Ok(())
    };
    for (i, &at) in starts.iter().enumerate() {
        asm.bind(Label(i as u32));
        scopes_at(&mut asm, at)?;
        let op = Opcode::from_u16(code[at] as u16).unwrap();
        let ops = operands(code, at).into_iter().map(|o| o.map_targets(|t| idx(t).map(|i| Label(i as u32)))).collect::<Result<Vec<_>, _>>()?;
        let id = asm.insn(op, &ops);
        if let Some(a) = action[i] {
            asm.set_unwind(id, a);
        }
    }
    scopes_at(&mut asm, code.len())?;
    if scopes.next().is_some() {
        return Err(EncodeError::BadTarget(code.len() as u32));
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
    /// With [`Asm::drop_exactly`], the pieces of the stores to drop, instead of the ones
    /// dead-store dropping finds.
    drops: Option<Vec<usize>>,
}

/// The register an operand register value goes in: a constant, or the address of a [`Ref`].
#[derive(Clone, Copy)]
pub(super) enum RegVal {
    Imm(u64),
    Addr(Ref),
}

/// A handler argument register's value: `fp`, the exception object (`lpad`), a constant
/// with raw slots in the halves `slots` flags, a [`Ref`]'s address, or a code constant's.
#[derive(Clone, Copy)]
pub(super) enum ArgVal {
    Fp,
    Exception,
    Imm(u64, u8),
    Addr(Ref),
    Ro(u32),
}

impl Asm {
    pub fn new(mode: Mode) -> Asm {
        Asm { mode, pieces: Vec::new(), labels: Vec::new(), ro: Vec::new(), unwind: Vec::new(), targets: Vec::new(), drops: None }
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

    /// Marks the raw slots `slot .. slot + len` dead here: nothing reads them before writing
    /// them, so stores to them that nothing read yet may be dropped.
    pub fn dead(&mut self, slot: u32, len: u32) {
        if len != 0 {
            self.pieces.push(Piece::Dead { lo: slot as i32, len });
        }
    }

    /// Records that a pointer to the object at the raw slot `slot`, of `size` bytes and
    /// alignment `align`, escapes before the next instruction ([`ScopeKind::Escape`]).
    pub fn escape(&mut self, slot: u32, size: u32, align: u32) {
        if size != 0 {
            self.pieces.push(Piece::Scope { slot, size, kind: ScopeKind::Escape { align } });
        }
    }

    /// Records that the storage of the raw slots `slot .. slot + size` ends before the next
    /// instruction ([`ScopeKind::End`]). [`Asm::finish`] keeps only the ends that overlap an
    /// escape.
    pub fn storage_end(&mut self, slot: u32, size: u32) {
        if size != 0 {
            self.pieces.push(Piece::Scope { slot, size, kind: ScopeKind::End });
        }
    }

    /// Drops exactly the stores [`Asm::drop_store`] names, rather than the dead ones: for
    /// re-encoding decoded code, whose dead marks are gone but whose dropped stores are known.
    pub fn drop_exactly(&mut self) {
        self.drops.get_or_insert_with(Vec::new);
    }

    /// With [`Asm::drop_exactly`], drops the store that ends the last instruction, an inline
    /// sequence that writes a frame slot from a register ([`Asm::can_drop_store`]).
    pub fn drop_store(&mut self) {
        debug_assert!(self.can_drop_store(), "not a register store");
        let k = self.pieces.len() - 1;
        self.drops.as_mut().expect("drop_exactly").push(k);
    }

    /// Whether the last instruction is an inline sequence that ends in a store of a register
    /// the register cache may hold ([`Asm::drop_store`]).
    pub fn can_drop_store(&self) -> bool {
        matches!(self.pieces.last(), Some(Piece::Native(Item::St { src, m, .. })) if *src != Reg::Rcx && m.base == Reg::Rbp)
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
        for (reg, v) in handler_args(op, ops, self.mode.fp_arg, |r| self.ro(r)).into_iter().enumerate() {
            match v {
                ArgVal::Fp => self.pieces.push(Piece::Fp(ARGS[reg])),
                // The exception object, in `rax` at a landing pad.
                ArgVal::Exception => self.fixed(Item::Mov(ARGS[reg], Reg::Rax)),
                ArgVal::Imm(v, 0) => self.fixed(Item::SetReg(ARGS[reg], v)),
                ArgVal::Imm(v, slots) => self.pieces.push(Piece::SetReg { reg: ARGS[reg], v, slots }),
                ArgVal::Addr(r) => self.fixed(Item::Lea(ARGS[reg], r)),
                ArgVal::Ro(ro) => self.pieces.push(Piece::LeaRo { reg: ARGS[reg], ro }),
            }
        }
        self.maybe_site(Item::Call(Ref::Handler(op)), site);
    }

    /// The direct island call `island(fp, ops)` through the symbol slot `isl`, `ops` the
    /// operand array [`Asm::ro`]`[ro]` (PE: with 32 bytes of shadow space).
    fn island_call(&mut self, isl: Sym, ro: u32, site: Option<InsnId>) {
        let [fp, ops] = island_args(self.mode.pe);
        self.pieces.push(Piece::Fp(fp));
        self.pieces.push(Piece::LeaRo { reg: ops, ro });
        if self.mode.pe {
            self.fixed(Item::SubRsp(32));
        }
        self.maybe_site(Item::CallMem(Ref::Sym(isl)), site);
        if self.mode.pe {
            self.fixed(Item::AddRsp(32));
        }
    }

    /// The jump-table sequence on the index in `rax`, with `targets`.
    fn table(&mut self, targets: Vec<Label>) {
        self.pieces.push(Piece::LeaTable);
        self.fixed(Item::LoadTableEntry);
        self.fixed(Item::AddRaxRcx);
        self.fixed(Item::JmpRax);
        self.pieces.push(Piece::Table(targets));
    }

    /// `ret s, k`: the value into the return registers, the epilogue, `ret`.
    fn ret(&mut self, s: u32, k: u32) {
        for it in ret_loads(k, s as i32) {
            self.pieces.push(Piece::Frame(it));
        }
        self.pieces.push(Piece::Epilogue);
        self.fixed(Item::Ret);
    }

    /// A call's argument list ([`super::params_ok`]): the argument registers' loads.
    fn params(&mut self, a: &Opnd<Label>) {
        let Opnd::Words(w) = a else { unreachable!() };
        for p in w.chunks(2) {
            for it in param_load(p[0] as i32, p[1], self.mode.pe) {
                self.pieces.push(Piece::Frame(it));
            }
        }
    }

    /// After a call: the stores of its result into `d`. Returns how many.
    fn result(&mut self, k: u32, d: u32) -> u32 {
        let items = result_stores(k, d as i32);
        let n = items.len() as u32;
        self.pieces.extend(items.into_iter().map(Piece::Frame));
        n
    }

    /// Emits a reduced `handler` ([`crate::reduced`]): a call of `op`'s handler with the
    /// argument registers `args` from `rdi` on, then `then`. An [`Arg::Ro`] argument is the
    /// address of a new code constant of `case_values` (a sparse switch's values, aligned as
    /// [`super::encode`] aligns them); its offset is ignored.
    pub(super) fn handler(&mut self, op: Opcode, args: &[Arg], case_values: &[u8], then: Then<Label>) -> InsnId {
        let id = InsnId(self.unwind.len() as u32);
        self.unwind.push(None);
        // As `insn` records `t` and a switch's `default`, the operands of their own.
        match &then {
            Then::Branch { target, .. } => self.targets.push((*target, self.pieces.len())),
            Then::Table(ts) => self.targets.push((*ts.last().expect("a default"), self.pieces.len())),
            Then::Next | Then::Trap => {}
        }
        for (&a, &reg) in args.iter().zip(&ARGS) {
            match a {
                Arg::Fp => self.pieces.push(Piece::Fp(reg)),
                Arg::Exception => self.fixed(Item::Mov(reg, Reg::Rax)),
                Arg::Imm(v) => self.fixed(Item::SetReg(reg, v)),
                Arg::Const(k) => self.fixed(Item::Lea(reg, Ref::Const(k))),
                Arg::Data(d) => self.fixed(Item::Lea(reg, Ref::Data(d))),
                Arg::Sym(s) => self.fixed(Item::Lea(reg, Ref::Sym(s))),
                Arg::Site(s) => self.fixed(Item::Lea(reg, Ref::Site(s))),
                Arg::Ro(_) => {
                    let size = case_elem(op).map_or(1, case_size);
                    let ro = self.ro(RoReq::Bytes(case_values.to_vec(), size.max(4)));
                    self.pieces.push(Piece::LeaRo { reg, ro });
                }
            }
        }
        let site = matches!(then, Then::Trap).then_some(id);
        self.maybe_site(Item::Call(Ref::Handler(op)), site);
        match then {
            Then::Next => {}
            Then::Branch { neg, target } => {
                self.fixed(Item::TestAl);
                self.pieces.push(Piece::Branch { cond: if neg { Cond::Z } else { Cond::Nz }, to: target });
            }
            Then::Table(ts) => self.table(ts),
            Then::Trap => self.fixed(Item::Ud2),
        }
        id
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
        let imm = |name: &str| match named(name) {
            Opnd::Imm(v) => *v as u32,
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
            Shape::Ret => self.ret(slot("s"), imm("k")),
            Shape::Arg => {
                let a = ArgReg::of(imm("r"), true).expect("arg register");
                for it in arg_store(a, slot("d") as i32, self.mode.pe) {
                    self.pieces.push(Piece::Frame(it));
                }
            }
            Shape::Jmp => self.pieces.push(Piece::Branch { cond: Cond::Always, to: target("t") }),
            Shape::Call => {
                let (d, k) = (slot("d"), imm("k"));
                // The callee's address, where it isn't the call's own operand.
                match op {
                    Opcode::CallSymInd => self.fixed(Item::LoadRip(Ref::Sym(sym("sym")))),
                    Opcode::CallPtr => self.pieces.push(Piece::Frame(Item::Ld { w: W::Q, sx: false, dst: Reg::Rax, m: M::frame(slot("p") as i32) })),
                    _ => {}
                }
                self.params(named("a"));
                let call = match op {
                    Opcode::Call => {
                        let Opnd::Func(f) = named("f") else { unreachable!() };
                        Item::Call(Ref::Func(*f))
                    }
                    Opcode::CallSym => Item::CallMem(Ref::Sym(sym("sym"))),
                    Opcode::CallSymInd => Item::CallMemRax,
                    _ => Item::CallRax,
                };
                self.maybe_site(call, site);
                self.result(k, d);
            }
            Shape::TailCall => {
                if op == Opcode::TailCallPtr {
                    self.pieces.push(Piece::Frame(Item::Ld { w: W::Q, sx: false, dst: Reg::Rax, m: M::frame(slot("p") as i32) }));
                }
                self.params(named("a"));
                self.pieces.push(Piece::Epilogue);
                if op == Opcode::TailCall {
                    let Opnd::Func(f) = named("f") else { unreachable!() };
                    self.fixed(Item::Jmp(Ref::Func(*f)));
                } else {
                    self.fixed(Item::JmpRax);
                }
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
        self.finish_labels(frame_size, fix).0
    }

    /// [`Asm::finish`], and the position in the code of every label (in order; `u32::MAX` for
    /// unbound ones): where the instruction after it starts, after a loop head's padding (the
    /// JIT's OSR entries land there).
    pub fn finish_labels(self, frame_size: u32, fix: impl Fn(u32) -> u32) -> (Encoded, Vec<u32>) {
        let Asm { mode, mut pieces, labels, ro, unwind, targets, drops } = self;
        debug_assert!(mode.valid(), "{mode:?}");
        let target = branch_targets(&pieces, &labels);
        cache(&mut pieces, &target);
        match drops {
            // The cache drops at most a sequence's leading reload, so a store named is still
            // its last piece.
            Some(ks) => {
                for k in ks {
                    match pieces[k] {
                        Piece::Native(it @ Item::St { .. }) => pieces[k] = Piece::Dropped(it),
                        _ => unreachable!("a dropped store is a store"),
                    }
                }
            }
            None => drop_dead_stores(&mut pieces, &target),
        }
        // Storage ends matter only for the bytes of escaped objects.
        let escapes: Vec<(u32, u32)> = pieces
            .iter()
            .filter_map(|p| match *p {
                Piece::Scope { slot, size, kind: ScopeKind::Escape { .. } } => Some((slot, size)),
                _ => None,
            })
            .collect();
        for p in &mut pieces {
            if let Piece::Scope { slot, size, kind: ScopeKind::End } = *p
                && !escapes.iter().any(|&(e, n)| e.wrapping_sub(slot) < size || slot.wrapping_sub(e) < n)
            {
                *p = Piece::Gone;
            }
        }
        // Code constants, in emission order (so deduplication matches the word encoder's).
        let mut rodata = Rodata::default();
        let ro_off: Vec<u32> = ro
            .into_iter()
            .map(|r| match r {
                RoReq::Bytes(b, align) => rodata.add(b, align),
                RoReq::Ops(ws) => {
                    let w: Vec<u32> = ws
                        .iter()
                        .map(|w| match *w {
                            RoWord::Slot(s) => fix(s),
                        })
                        .collect();
                    rodata.ops(&w)
                }
            })
            .collect();

        // Loop heads: labels bound before a branch to them.
        let mut head = vec![false; pieces.len() + 1];
        if mode.align_loops || mode.counters {
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
        // The counter checks' `js`s (element indices), the entry's first, each continuing at
        // the element after it; their stubs follow the code.
        let mut checks = Vec::new();
        let check = |out: &mut Vec<Laid>, checks: &mut Vec<usize>, k: u8| {
            fixed(out, Item::CtrSub(k));
            checks.push(out.len());
            out.push(Laid::Branch { cond: Cond::S, to: usize::MAX, long: false });
        };
        if mode.counters {
            check(&mut out, &mut checks, super::ENTRY_COUNT);
        }
        let prologue_at = out.len();
        for item in prologue(frame_size, mode) {
            fixed(&mut out, item);
        }
        let epilogue = epilogue(frame_size, mode);
        // Frame slots: `[rbp + d]`, or `[rsp + F + d]`.
        let slot = |item: Item| {
            let item = item.map_frame(|s| fix(s as u32) as i32);
            if mode.frame_pointer { item } else { item.sp_frame(frame_size) }
        };
        let mut remap = Vec::with_capacity(pieces.len() + 1);
        let lab = |l: &Label| labels[l.0 as usize];
        let mut tables = Vec::new();
        let mut branches = Vec::new();
        let mut sites = Vec::new();
        // Pieces without code, which take the element after them (after its padding): a
        // label there must not land before the padding of a loop head right after. Scopes
        // too, as they take effect before the next instruction.
        let mut empty = Vec::new();
        let mut scopes = Vec::new();
        // A loop head's counter check comes before the instruction, after its padding and
        // before the scopes there take effect, so every branch to the head passes it.
        let mut head_check = false;
        for (k, p) in pieces.into_iter().enumerate() {
            if head[k] {
                if mode.align_loops {
                    out.push(Laid::Align);
                }
                head_check |= mode.counters;
            }
            if matches!(p, Piece::Gone | Piece::Dead { .. }) {
                remap.push(usize::MAX);
                empty.push(k);
                continue;
            }
            if let Piece::Scope { slot, size, kind } = p {
                remap.push(usize::MAX);
                empty.push(k);
                scopes.push(Laid::Scope(Scope { code_offset: 0, frame_offset: fix(slot) as i32, size, kind }));
                continue;
            }
            out.append(&mut scopes);
            remap.push(out.len());
            for e in empty.drain(..) {
                remap[e] = out.len();
            }
            if core::mem::take(&mut head_check) {
                check(&mut out, &mut checks, 1);
            }
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
                Piece::Frame(item) => Laid::Fixed { item: slot(item), site: None },
                Piece::Gone | Piece::Dead { .. } | Piece::Scope { .. } => unreachable!(),
                Piece::Dropped(item) => Laid::Dropped(item.map_frame(|s| fix(s as u32) as i32)),
                Piece::Native(item) => Laid::Fixed { item: slot(item), site: None },
                Piece::Fp(reg) => Laid::Fixed { item: fp_item(reg, frame_size, mode), site: None },
                Piece::Epilogue => Laid::Fixed { item: epilogue, site: None },
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
                Piece::LeaTable => Laid::LeaTable,
                Piece::Table(ts) => {
                    tables.push(out.len());
                    Laid::Table(ts.iter().map(lab).collect())
                }
            });
        }
        if head.last() == Some(&true) && mode.align_loops {
            out.push(Laid::Align);
        }
        debug_assert!(!head_check, "a loop head at the end");
        out.append(&mut scopes);
        remap.push(out.len());
        for e in empty {
            remap[e] = out.len();
        }
        // The counter stubs: the loop heads' in order, then the entry's. Each loads the
        // record into `r11` (and a head its index into `eax`), calls through the record's
        // slot, and on return jumps back after its check.
        let mut entry_stub = out.len();
        if mode.counters {
            let (entry, heads) = checks.split_first().expect("the entry's check");
            for (n, &js) in heads.iter().chain([entry]).enumerate() {
                let stub = out.len();
                let Laid::Branch { to, .. } = &mut out[js] else { unreachable!() };
                *to = stub;
                fixed(&mut out, Item::Lea(Reg::R11, Ref::Rec));
                if js == *entry {
                    entry_stub = stub;
                    fixed(&mut out, Item::CallR11(crate::image::JIT_ENTRY_SLOT));
                } else {
                    fixed(&mut out, Item::SetReg(Reg::Rax, n as u64));
                    fixed(&mut out, Item::CallR11(crate::image::JIT_OSR_SLOT));
                }
                out.push(Laid::Branch { cond: Cond::Always, to: js + 1, long: false });
            }
        }
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
        let marks: Vec<usize> = labels.iter().map(|&at| if at == usize::MAX { usize::MAX } else { remap[at] }).collect();
        let (mut e, marks) = layout_code(out, [prologue_at, entry_stub], &marks);
        e.rodata = rodata.bytes;
        (e, marks)
    }
}

/// The prologue of a function with frame size `F`: `push rbp; mov rbp, rsp`, then for
/// `F > 0` `sub rsp, F`; or without a frame pointer `sub rsp, F + 8`. On PE, the top 16 bytes
/// of the frame hold `rdi` and `rsi` ([`Item::WinPrologue`], so `F` is at least 16), and the
/// `sub` is of `F - 16`. A stack probe of the `sub`'s size comes before it for `F` from
/// [`PROBE_FROM`].
pub(super) fn prologue(frame_size: u32, mode: Mode) -> Vec<Item> {
    let mut out = Vec::with_capacity(4);
    let alloc = if mode.pe {
        debug_assert!(frame_size >= 16, "PE frames keep rdi and rsi at the top");
        out.push(Item::WinPrologue);
        frame_size - 16
    } else if mode.frame_pointer {
        out.extend([Item::PushRbp, Item::Mov(Reg::Rbp, Reg::Rsp)]);
        frame_size
    } else {
        frame_size + 8
    };
    if frame_size >= PROBE_FROM {
        out.extend([Item::SetReg(Reg::Rax, alloc as u64), Item::Call(Ref::Probe)]);
    }
    if alloc != 0 {
        out.push(Item::SubRsp(alloc));
    }
    out
}

/// The length of [`prologue`]: where the frame is set up.
pub fn prologue_len(frame_size: u32, mode: Mode) -> u32 {
    prologue(frame_size, mode).iter().map(Item::len).sum()
}

/// The epilogue before `ret` and tail jumps: `leave`, or `add rsp, F + 8`, or on PE
/// [`Item::WinEpilogue`].
pub(super) fn epilogue(frame_size: u32, mode: Mode) -> Item {
    if mode.pe {
        Item::WinEpilogue
    } else if mode.frame_pointer {
        Item::Leave
    } else {
        Item::AddRsp(frame_size + 8)
    }
}

/// `reg = fp`: `mov reg, rbp`, or `lea reg, [rsp + F]`.
pub(super) fn fp_item(reg: Reg, frame_size: u32, mode: Mode) -> Item {
    if mode.frame_pointer { Item::Mov(reg, Reg::Rbp) } else { Item::LeaM { dst: reg, m: super::x86::M { base: Reg::Rsp, disp: frame_size as i32 } } }
}

/// Every opcode's handler register layout, with `fp` in `rbp` and in `rdi`, computed at compile
/// time.
fn layouts(fp_arg: bool) -> &'static [Layout] {
    const fn all(fp_arg: bool) -> [Layout; crate::full::ALL_OPCODES.len()] {
        let mode = Mode { fp_arg, frame_pointer: true, align_loops: false, pe: false, counters: false };
        let mut out = [layout(Opcode::Jmp, mode); crate::full::ALL_OPCODES.len()];
        let mut i = 0;
        while i < out.len() {
            out[i] = layout(crate::full::ALL_OPCODES[i], mode);
            i += 1;
        }
        out
    }
    static NO_FP: [Layout; crate::full::ALL_OPCODES.len()] = all(false);
    static FP: [Layout; crate::full::ALL_OPCODES.len()] = all(true);
    if fp_arg { &FP } else { &NO_FP }
}

/// Lays out the elements (relaxing branches) and writes the code.
fn layout_code(mut pieces: Vec<Laid>, [prologue, entry_stub]: [usize; 2], marks: &[usize]) -> (Encoded, Vec<u32>) {
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
            Laid::LeaTable => 7,
            Laid::Dropped(_) | Laid::Scope(_) => 0,
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
            Laid::Dropped(item) => out.dropped.push(DroppedStore { at: p, item: *item }),
            Laid::Scope(sc) => out.scopes.push(Scope { code_offset: p, ..*sc }),
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
    out.prologue = pos[prologue];
    out.entry_stub = pos[entry_stub];
    let marks = marks.iter().map(|&m| if m == usize::MAX { u32::MAX } else { pos[m] }).collect();
    (out, marks)
}

/// Functions with frames of at least this size probe the stack in the prologue.
pub const PROBE_FROM: u32 = 4096;

/// The values of `op`'s handler argument registers for operands `ops`, from `rdi` on: `fp`
/// (with [`Mode::fp_arg`]), the exception object (`lpad`), then the operands' ([`layout`]).
/// Case value arrays become code constants through `ro`, which returns the value of their
/// [`ArgVal::Ro`].
pub(super) fn handler_args<T>(op: Opcode, ops: &[Opnd<T>], fp_arg: bool, mut ro: impl FnMut(RoReq) -> u32) -> Vec<ArgVal> {
    let l = layouts(fp_arg)[op as usize];
    let info = op.info();
    let mut regs = [None; super::ARG_REGS];
    if fp_arg {
        regs[0] = Some(ArgVal::Fp);
    }
    if info.shape == Shape::Lpad {
        regs[l.first as usize - 1] = Some(ArgVal::Exception);
    }
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
                let ro = ro(RoReq::Bytes(b, size.max(4)));
                set(loc, 0, ArgVal::Ro(ro), false);
                set(loc, 1, imm(vals.len() as u64), false);
            }
            Opnd::Func(_) | Opnd::Target(_) | Opnd::Neg(_) | Opnd::Words(_) => {
                unreachable!("not a register operand")
            }
        }
    }
    regs[..l.regs as usize].iter().map(|r| r.expect("every register set")).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn handler_count() {
        // Every opcode with a handler has a layout (const-evaluable for all of them).
        for &op in crate::full::ALL_OPCODES {
            if super::super::has_handler(op) {
                let l = layout(op, Mode { fp_arg: false, frame_pointer: true, align_loops: true, pe: false, counters: true });
                assert!(l.regs as usize <= super::super::ARG_REGS);
                let l = layout(op, Mode { fp_arg: true, frame_pointer: false, align_loops: true, pe: false, counters: true });
                assert!(l.regs as usize <= super::super::ARG_REGS);
            }
        }
    }
}
