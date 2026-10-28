//! Decoded reduced code ([`crate::asm::Decoded`]) as the SSA builder reads it: each
//! instruction classified ([`Kind`]) with its exact frame accesses ([`Acc`]), its unwinding
//! and its successors, then cut into blocks with their CFG, landing pad edges included, and
//! the cyclic loop heads (design/jit.md, "The SSA tier").

use alloc::vec::Vec;

use super::Unsupported;
use super::effects::{Effect, effects};
use super::ir::BinOp;
use crate::asm::{self, ARG_ADDR, ArgReg, Decoded, Mode, RET_SRET, RetPart, ScopeKind};
use crate::full::{self, Func as FuncIdx, OperandKind, Shape, Sym};
use crate::image::{CATCH, CONTINUE};
use crate::reduced::{self, Arg, Insn};

/// How an instruction touches a frame byte range.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum How {
    Read,
    Write,
    /// A read and a write (a handler's conditional write).
    Update,
    /// Its address is taken (an `addr`, an argument passed by address).
    Addr,
    /// Read or written as a block of bytes: never promoted (handlers with lengths,
    /// `mov.w128`, island operands).
    Block,
    /// Only written as a block of bytes (a block copy's destination, a `w128` result): never
    /// promoted, but not a read (the outgoing argument area is written this way).
    BlockWrite,
}

/// A frame access: `size` bytes at `fp + off`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Acc {
    pub off: i32,
    pub size: u32,
    pub how: How,
}

/// A native instruction, by what the builder makes of it. The accesses are in [`RInsn::accs`],
/// in the order given.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Kind {
    /// `d = s` (`w` up to 8): accesses `s` read, `d` write.
    Mov(u8),
    /// A small block copy (`copy`, `zero`, `load.copy`, `store.copy`, `mov.w128`,
    /// `load.w128`, `store.w128` of up to [`MAX_COPY`] bytes), done as `pieces` (offsets in
    /// the block, widths: 1 to 8, or 16 over a vector) of plain loads and stores: every piece is read before any is
    /// written, so overlap is exact. Accesses: the pointer slot (with a `Mem` side) read,
    /// then a frame source's pieces read, then a frame destination's pieces written.
    Copy {
        len: u32,
        dst: Side,
        src: Side,
        pieces: Vec<(u32, u8)>,
    },
    /// `d = imm`: `d` write.
    Imm(u8, u64),
    /// `d = [p + k]`: `p` read, `d` write.
    Load(u8, i32),
    /// `[p + k] = s`: `p` read, `s` read.
    Store(u8, i32),
    /// `d = &s`: `s` addr, `d` write.
    Addr,
    /// `d = &k` (`addr.const`) or the symbol slot's value (`addr.sym`), loaded once more
    /// with `ind`: `d` write.
    RefAddr {
        to: asm::Ref,
        ind: bool,
    },
    /// `d = p + imm`: `p`, `d`.
    PtrAdd(i64),
    /// `d = p + i * stride`: `p`, `i`, `d`.
    PtrIndex(u32),
    /// `d = a op b` (or `op imm`): `a`, [`b`], `d`.
    Bin(BinOp, u8, Option<u64>),
    /// `d = a cc b` (or `cc imm`): `a`, [`b`], `d`.
    Cmp(super::ir::Cc, u8, Option<u64>),
    /// A pure operation of the SSA IR: its operands read at the widths `ws` (accesses in
    /// order), then the result (`out` bytes) written (the last access).
    Pure {
        op: super::ir::Op,
        ws: Vec<u8>,
        out: u8,
    },
    /// `d, o = a op b` with overflow (`Add`, `Sub` or `Mul`), signed or not: `a`, `b`, `d`,
    /// `o`.
    Ovf(BinOp, bool, u8),
    /// `d = s` extended (zero or sign, `sx`) or truncated from `from` bytes to `to`: `s`, `d`.
    Ext {
        from: u8,
        to: u8,
        sx: bool,
    },
    /// To the instruction (an index, as all the targets here).
    Jmp(u32),
    /// A branch on the byte `s`, or on `a cc b` (or `cc imm`): to `t` when it holds, but
    /// with `neg`. Accesses: `s`, or `a`, [`b`].
    Br {
        cmp: Option<(super::ir::Cc, u8, Option<u64>)>,
        neg: bool,
        t: u32,
    },
    /// A call: accesses the callee pointer (for `Ptr`), the arguments (by address: addr),
    /// then the result's parts (writes).
    Call {
        target: super::ir::CallTarget,
        regs: Vec<ArgReg>,
        parts: Vec<RetPart>,
    },
    TailCall {
        target: super::ir::CallTarget,
        regs: Vec<ArgReg>,
    },
    /// `ret`: the parts' reads (load widths) at `s`.
    Ret {
        k: u32,
        parts: Vec<RetPart>,
    },
    /// `arg d, r`: `d` write.
    Arg(ArgReg),
    /// Accesses: the operands' extents (blocks), from the island's `Lend` scopes.
    Island {
        isl: Sym,
    },
    /// A handler call: its frame operands' accesses, in operand order (each with the
    /// argument register and half it is in).
    Handler {
        h: full::Opcode,
        args: Vec<Arg>,
        slots: Vec<(u8, u8)>,
        then: Then,
    },
    /// `lpad x`: `x` write (the exception object).
    Lpad,
    /// `unreachable`: a `ud2`.
    Unreachable,
}

/// One side of a [`Kind::Copy`].
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Side {
    /// The frame bytes at this offset.
    Frame(i32),
    /// Memory at the pointer slot's value plus this displacement.
    Mem(i32),
    /// Zeros (a source only).
    Zero,
    /// The constant pool from this offset (a source only: `const`).
    Pool(u32),
}

/// The longest block copy done as loads and stores; longer ones call their handler.
pub const MAX_COPY: u32 = 128;

/// The most pieces a copy is cut into along the other accesses' boundaries; past it, it is
/// cut into 8-byte pieces.
const MAX_PIECES: usize = 16;

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Then {
    Next,
    Branch { neg: bool, t: u32 },
    Table(Vec<u32>),
    Trap,
}

/// Where unwinding out of an instruction goes.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Unwind {
    /// It can't (no call site).
    None,
    Continue,
    /// To the `lpad` at this instruction index.
    Pad {
        pad: u32,
        catch: bool,
    },
}

#[derive(Clone, Debug)]
pub struct RInsn {
    pub kind: Kind,
    pub accs: Vec<Acc>,
    /// Instruction indices it may continue at (but for unwinding), the fall-through first.
    pub succ: Vec<u32>,
    pub falls: bool,
    pub unwind: Unwind,
}

impl RInsn {
    /// Whether it may unwind (calls, islands, handlers that don't return), so that it has
    /// a call site.
    pub fn may_unwind(&self) -> bool {
        matches!(self.kind, Kind::Call { .. } | Kind::Island { .. } | Kind::Handler { then: Then::Trap, .. })
    }
}

/// A scope change before instruction `at` (an index; the count for the end).
#[derive(Clone, Copy, Debug)]
pub struct ScopeAt {
    pub at: u32,
    pub off: i32,
    pub size: u32,
    pub kind: ScopeKind,
}

/// A block of instructions: `start .. end` (indices).
#[derive(Clone, Debug)]
pub struct RBlock {
    pub start: u32,
    pub end: u32,
    /// Successor blocks, the pad last (if the last instruction unwinds to one).
    pub succ: Vec<u32>,
    pub pad: Option<u32>,
    pub preds: Vec<u32>,
    /// The AOT loop head (index into [`Decoded::heads`]) it starts at.
    pub head: Option<u32>,
}

pub struct Code {
    pub insns: Vec<RInsn>,
    pub scopes: Vec<ScopeAt>,
    pub blocks: Vec<RBlock>,
    /// The block of each instruction.
    pub block_of: Vec<u32>,
    /// By loop head, whether it gets an OSR entry: it lies on a cycle, and isn't an `arg`
    /// or an `lpad`.
    pub enterable: Vec<bool>,
}

/// The IR condition of a compare family's condition.
fn ir_cc(cc: full::Cc) -> super::ir::Cc {
    use super::ir::Cc;
    match cc {
        full::Cc::Eq => Cc::Eq,
        full::Cc::Ne => Cc::Ne,
        full::Cc::LtS => Cc::LtS,
        full::Cc::LtU => Cc::LtU,
        full::Cc::LeS => Cc::LeS,
        full::Cc::LeU => Cc::LeU,
        full::Cc::GtS => Cc::GtS,
        full::Cc::GtU => Cc::GtU,
        full::Cc::GeS => Cc::GeS,
        full::Cc::GeU => Cc::GeU,
    }
}

/// Reads the immediate operand `name` of the native instruction `w` (opcode `op`).
fn imm(op: full::Opcode, w: &[u32], name: &str) -> u64 {
    let info = op.info();
    let i = info.operand_index(name).expect("operand");
    let at = info.operand_offset(i).expect("fixed");
    match info.operands[i].kind.words() {
        Some(2) => w[at] as u64 | (w[at + 1] as u64) << 32,
        _ => w[at] as u64,
    }
}

fn slot(op: full::Opcode, w: &[u32], name: &str) -> i32 {
    imm(op, w, name) as u32 as i32
}

/// Rejects a 16-byte SSE value (an argument or a result), which the SSA tier doesn't pass.
fn no_wide_sse(xmm: bool, size: u32, what: &'static str) -> Result<(), Unsupported> {
    if xmm && size > 8 { Err(Unsupported(what)) } else { Ok(()) }
}

/// The parts of a call's (or with `is_ret`, a `ret`'s) value of return kind `k` at `base`,
/// each accessed `how`.
fn ret_part_accs(k: u32, is_ret: bool, base: i32, how: How, accs: &mut Vec<Acc>) -> Result<Vec<RetPart>, Unsupported> {
    if k == 0 {
        return Ok(Vec::new());
    }
    let parts: Vec<RetPart> = asm::ret_parts(k, is_ret).ok_or(Unsupported("return kind"))?.into_iter().flatten().collect();
    for p in &parts {
        no_wide_sse(p.xmm, p.size, "a 16-byte SSE result")?;
        accs.push(Acc { off: base.wrapping_add(p.off as i32), size: p.size, how });
    }
    Ok(parts)
}

/// The call argument list `a` (slot, register pairs): accesses and registers.
fn arg_list(a: &[u32], accs: &mut Vec<Acc>, regs: &mut Vec<ArgReg>) -> Result<(), Unsupported> {
    for p in a.chunks(2) {
        let r = asm::param_reg(p[1]).ok_or(Unsupported("argument register"))?;
        no_wide_sse(r.xmm, r.size, "a 16-byte SSE argument")?;
        let how = if p[1] & ARG_ADDR != 0 { How::Addr } else { How::Read };
        accs.push(Acc { off: p[0] as i32, size: if how == How::Addr { 1 } else { r.size }, how });
        regs.push(ArgReg { size: if how == How::Addr { 8 } else { r.size }, ..r });
    }
    Ok(())
}

/// A handler call that is a small block copy: its length, destination, source and the
/// pointer slot of its `Mem` side. Frame sides must stay clear of the return address.
fn small_copy(h: full::Opcode, args: &[Arg], l: &asm::Layout, pool: bool) -> Option<(u32, Side, Side, Option<i32>)> {
    use full::Opcode as O;
    let info = h.info();
    let reg = |name: &str, part: u8| l.locs[info.operand_index(name)?].imm(args, part);
    let slot = |name: &str| Some(reg(name, 0)? as u32 as i32);
    let disp = || Some(reg("m", 1)? as u32 as i32);
    let (len, dst, src, p) = match h {
        O::Copy => (reg("len", 0)? as u32, Side::Frame(slot("d")?), Side::Frame(slot("s")?), None),
        O::Zero => (reg("len", 0)? as u32, Side::Frame(slot("d")?), Side::Zero, None),
        O::Const if pool => {
            let Arg::Const(k) = *args.get(l.locs[info.operand_index("k")?].reg as usize)? else { return None };
            (reg("len", 0)? as u32, Side::Frame(slot("d")?), Side::Pool(k.0), None)
        }
        O::LoadCopy => (reg("len", 0)? as u32, Side::Frame(slot("d")?), Side::Mem(disp()?), Some(slot("m")?)),
        O::StoreCopy => (reg("len", 0)? as u32, Side::Mem(disp()?), Side::Frame(slot("s")?), Some(slot("m")?)),
        O::LoadW128 => (16, Side::Frame(slot("d")?), Side::Mem(disp()?), Some(slot("m")?)),
        O::StoreW128 => (16, Side::Mem(disp()?), Side::Frame(slot("s")?), Some(slot("m")?)),
        _ => return None,
    };
    let clear = |s: Side| match s {
        Side::Frame(o) => !((o as i64) < 16 && o as i64 + len as i64 > 0),
        _ => true,
    };
    (len != 0 && len <= MAX_COPY && clear(dst) && clear(src)).then_some((len, dst, src, p))
}

/// The handlers that are native operations on 16-byte vectors in the SSA tier, as the IR
/// operation (`d` first, then the operands, in operand order).
pub fn vector_op(h: full::Opcode) -> Option<super::ir::Op> {
    use super::ir::{Op, VOp};
    use full::Opcode::*;
    Some(match h {
        VsplatI8x16 => Op::V(VOp::Splat),
        VeqI8x16 => Op::V(VOp::Eq),
        VltSI8x16 => Op::V(VOp::LtS),
        VmsbI8x16 => Op::V(VOp::Msb),
        AndW128 => Op::Bin(BinOp::And, 16),
        OrW128 => Op::Bin(BinOp::Or, 16),
        XorW128 => Op::Bin(BinOp::Xor, 16),
        _ => return None,
    })
}

/// Cuts the small copies into pieces and gives them their frame accesses. The cuts follow
/// the boundaries of the other scalar accesses of the same frame bytes, carried across
/// frame-to-frame copies, so that a copied aggregate's fields stay the variables the rest of
/// the code reads and writes (and promote). A 16-byte stretch between cuts that a vector
/// operation reads or writes whole on either side (also carried across the copies) is one
/// 16-byte piece: the vector moves as one value.
fn cut_copies(insns: &mut [RInsn], mem: Option<&dyn super::opt::ConstMem>) {
    use alloc::collections::BTreeSet;
    let mut cuts: BTreeSet<i32> = BTreeSet::new();
    let mut whole: BTreeSet<i32> = BTreeSet::new();
    let mut copies = Vec::new();
    for (i, ri) in insns.iter().enumerate() {
        if let Kind::Copy { .. } = ri.kind {
            copies.push(i);
            continue;
        }
        for a in &ri.accs {
            if matches!(a.how, How::Read | How::Write | How::Update) && matches!(a.size, 1 | 2 | 4 | 8 | 16) {
                cuts.insert(a.off);
                cuts.insert(a.off + a.size as i32);
                if a.size == 16 {
                    whole.insert(a.off);
                }
            }
        }
    }
    let frames = |k: &Kind| -> ([Option<i32>; 2], u32) {
        let Kind::Copy { len, dst, src, .. } = k else { unreachable!() };
        let f = |s: &Side| if let Side::Frame(o) = s { Some(*o) } else { None };
        ([f(dst), f(src)], *len)
    };
    let rel = |cuts: &BTreeSet<i32>, bases: [Option<i32>; 2], len: u32| -> BTreeSet<u32> {
        let mut r: BTreeSet<u32> = [0, len].into_iter().collect();
        for b in bases.into_iter().flatten() {
            r.extend(cuts.range(b + 1..b + len as i32).map(|&c| (c - b) as u32));
        }
        r
    };
    // Carry the cuts across frame-to-frame copies, a few rounds (chains of copies).
    for _ in 0..4 {
        let mut changed = false;
        for &i in &copies {
            let (bases, len) = frames(&insns[i].kind);
            if bases[0].is_none() || bases[1].is_none() {
                continue;
            }
            let r = rel(&cuts, bases, len);
            for b in bases.into_iter().flatten() {
                for &c in &r {
                    changed |= cuts.insert(b + c as i32);
                }
            }
        }
        if !changed {
            break;
        }
    }
    // The whole vectors, across the frame-to-frame copies (whose cuts now agree).
    if !whole.is_empty() {
        for _ in 0..4 {
            let mut changed = false;
            for &i in &copies {
                let ([Some(d), Some(s)], len) = frames(&insns[i].kind) else { continue };
                for r in rel(&cuts, [Some(d), Some(s)], len).into_iter().collect::<Vec<u32>>().windows(2) {
                    if r[1] - r[0] == 16 && (whole.contains(&(d + r[0] as i32)) || whole.contains(&(s + r[0] as i32))) {
                        changed |= whole.insert(d + r[0] as i32) | whole.insert(s + r[0] as i32);
                    }
                }
            }
            if !changed {
                break;
            }
        }
    }
    for &i in &copies {
        let (bases, len) = frames(&insns[i].kind);
        let vector = |at: u32| bases.iter().flatten().any(|&b| whole.contains(&(b + at as i32)));
        let mut r = rel(&cuts, bases, len);
        // A pool source's relocated fields are pieces of their own, which the fold makes
        // `RefAddr`s.
        if let (Kind::Copy { src: Side::Pool(k), .. }, Some(mem)) = (&insns[i].kind, mem) {
            for f in mem.relocs(*k, len) {
                let at = f as i64 - *k as i64;
                r.extend([at, at + 8].into_iter().filter(|&c| c > 0 && c < len as i64).map(|c| c as u32));
            }
        }
        let r: Vec<u32> = r.into_iter().collect();
        let split = |r: &[u32]| {
            let mut ps = Vec::new();
            for w in r.windows(2) {
                if w[1] - w[0] == 16 && vector(w[0]) {
                    ps.push((w[0], 16));
                    continue;
                }
                let mut at = w[0];
                while at < w[1] {
                    let n = (w[1] - at).min(8);
                    let n = 1 << (31 - n.leading_zeros());
                    ps.push((at, n as u8));
                    at += n;
                }
            }
            ps
        };
        let mut pieces = split(&r);
        if pieces.len() > MAX_PIECES {
            let r: Vec<u32> = (0..len).step_by(8).chain([len]).collect();
            pieces = split(&r);
        }
        let ri = &mut insns[i];
        let Kind::Copy { src, dst, pieces: ps, .. } = &mut ri.kind else { unreachable!() };
        for (s, how) in [(*src, How::Read), (*dst, How::Write)] {
            if let Side::Frame(o) = s {
                ri.accs.extend(pieces.iter().map(|&(k, n)| Acc { off: o + k as i32, size: n as u32, how }));
            }
        }
        *ps = pieces;
    }
}

/// The accesses of a [`Kind::Pure`]: the operands at `ins` (widths `ws`) read, the result
/// (`out` bytes) at `d` written.
fn pure(accs: &mut Vec<Acc>, ins: &[i32], ws: &[u8], d: i32, out: u8) {
    for (&o, &w) in ins.iter().zip(ws) {
        accs.push(Acc { off: o, size: w as u32, how: How::Read });
    }
    accs.push(Acc { off: d, size: out as u32, how: How::Write });
}

/// Classifies the instruction at word `at` of `d`.
fn insn(d: &Decoded, at: usize, lends: &[ScopeAt], mode: Mode, pool: bool) -> Result<RInsn, Unsupported> {
    let words = &d.words[at..];
    let len = reduced::insn_len(words).map_err(|_| Unsupported("reduced code"))?;
    let mut w = &words[..len];
    // A native instruction the SSA tier has no operation for: its handler call.
    let as_handler;
    if reduced::Opcode::from_u16(w[0] as u16).and_then(|op| op.full()).is_some_and(asm::ssa_as_handler) {
        as_handler = asm::as_handler(w, mode);
        w = &as_handler;
    }
    let (ri, _) = Insn::decode(w).map_err(|_| Unsupported("reduced code"))?;
    let rel = |t: i32| (at as i64 + t as i64) as u32;
    let mut accs = Vec::new();
    let mut succ = Vec::new();
    let mut falls = true;
    let op = reduced::Opcode::from_u16(w[0] as u16).expect("decoded");
    let acc = |off: i32, size: u32, how: How| Acc { off, size, how };
    let kind = match ri {
        Insn::AddrConst { d, a } => {
            accs.push(acc(d.0, 8, How::Write));
            let to = match a {
                full::Abs::Const(k) => asm::Ref::Const(k),
                full::Abs::Data(x) => asm::Ref::Data(x),
            };
            Kind::RefAddr { to, ind: false }
        }
        Insn::AddrSym { d, sym } | Insn::AddrSymInd { d, sym } => {
            accs.push(acc(d.0, 8, How::Write));
            Kind::RefAddr { to: asm::Ref::Sym(sym), ind: matches!(ri, Insn::AddrSymInd { .. }) }
        }
        Insn::Unreachable {} => {
            falls = false;
            Kind::Unreachable
        }
        Insn::Jmp { t } => {
            falls = false;
            succ.push(rel(t.0));
            Kind::Jmp(rel(t.0))
        }
        Insn::Call { .. } | Insn::CallSym { .. } | Insn::CallSymInd { .. } | Insn::CallPtr { .. } => {
            use super::ir::CallTarget as T;
            let (d_, target, k, a, p) = match ri {
                Insn::Call { d, f, k, a } => (d, T::Func(FuncIdx(f.0)), k, a, None),
                Insn::CallSym { d, sym, k, a } => (d, T::Sym(sym), k, a, None),
                Insn::CallSymInd { d, sym, k, a } => (d, T::SymInd(sym), k, a, None),
                Insn::CallPtr { d, p, k, a } => (d, T::Ptr, k, a, Some(p)),
                _ => unreachable!(),
            };
            if let Some(p) = p {
                accs.push(acc(p.0, 8, How::Read));
            }
            let mut regs = Vec::new();
            arg_list(a.words(), &mut accs, &mut regs)?;
            if k == RET_SRET {
                return Err(Unsupported("return kind"));
            }
            let parts = ret_part_accs(k, false, d_.0, How::Write, &mut accs)?;
            Kind::Call { target, regs, parts }
        }
        Insn::TailCall { .. } | Insn::TailCallPtr { .. } => {
            use super::ir::CallTarget as T;
            falls = false;
            let (target, a, p) = match ri {
                Insn::TailCall { f, a } => (T::Func(FuncIdx(f.0)), a, None),
                Insn::TailCallPtr { p, a } => (T::Ptr, a, Some(p)),
                _ => unreachable!(),
            };
            if let Some(p) = p {
                accs.push(acc(p.0, 8, How::Read));
            }
            let mut regs = Vec::new();
            arg_list(a.words(), &mut accs, &mut regs)?;
            Kind::TailCall { target, regs }
        }
        Insn::Ret { s, k } => {
            falls = false;
            let parts = ret_part_accs(k, true, s.0, How::Read, &mut accs)?;
            Kind::Ret { k, parts }
        }
        Insn::Arg { d, r } => {
            let a = ArgReg::of(r, true).ok_or(Unsupported("argument register"))?;
            no_wide_sse(a.xmm, a.size, "a 16-byte SSE argument")?;
            accs.push(acc(d.0, a.size, How::Write));
            Kind::Arg(a)
        }
        Insn::Island { isl, ops } => {
            for o in ops.iter() {
                let off = o as i32;
                // The operand's extent: its `Lend` scope (the largest, should two operands
                // share a slot).
                let size = lends.iter().filter(|l| l.off == off).map(|l| l.size).max().ok_or(Unsupported("an island operand without an extent"))?;
                accs.push(acc(off, size, How::Block));
            }
            Kind::Island { isl }
        }
        Insn::Handler { h, args, neg, t } => {
            let h = h.0;
            let info = h.info();
            let l = asm::layout(h, mode);
            let args: Vec<Arg> = args.iter().collect();
            if args.len() != l.regs as usize {
                return Err(Unsupported("handler arguments"));
            }
            let ts: Vec<u32> = t.iter().map(|t| rel(t.0)).collect();
            let then = match info.shape {
                Shape::Br => Then::Branch { neg: neg.0, t: ts[0] },
                Shape::Switch => Then::Table(ts.clone()),
                Shape::Trap => Then::Trap,
                _ => Then::Next,
            };
            succ.extend(ts.iter().copied());
            falls = matches!(info.shape, Shape::Op | Shape::Br | Shape::Lpad);
            if info.shape == Shape::Lpad {
                let x = info.operand_index("x").expect("x");
                let off = l.locs[x].imm(&args, 0).ok_or(Unsupported("handler arguments"))? as u32 as i32;
                accs.push(acc(off, 8, How::Write));
                Kind::Lpad
            } else if let Some((len, dst, src, p)) = small_copy(h, &args, &l, pool) {
                if let Some(p) = p {
                    accs.push(acc(p, 8, How::Read));
                }
                Kind::Copy { len, dst, src, pieces: Vec::new() }
            } else {
                let e = effects(h).ok_or(Unsupported("handler"))?;
                // The extent of block operands: the lengths the operands give.
                let imm_of = |name: &str| l.locs[info.operand_index(name)?].imm(&args, 0);
                let block = imm_of("len").or_else(|| Some(imm_of("elem_size")?.saturating_mul(imm_of("count")?))).unwrap_or(16);
                let block = u32::try_from(block).map_err(|_| Unsupported("a block too large"))?;
                let mut slots = Vec::new();
                for (k, o) in info.operands.iter().enumerate() {
                    let loc = l.locs[k];
                    if loc.count == 0 || !matches!(o.kind, OperandKind::Slot | OperandKind::Mem) {
                        continue;
                    }
                    let off = loc.imm(&args, 0).ok_or(Unsupported("a slot operand that isn't an immediate"))? as u32 as i32;
                    let (size, how) = match e.opnds[k] {
                        Some(Effect::Read(n)) => (n as u32, How::Read),
                        Some(Effect::Write(n)) => (n as u32, How::Write),
                        Some(Effect::Update(n)) => (n as u32, How::Update),
                        Some(Effect::Addr) => (1, How::Addr),
                        Some(Effect::Block) if o.name == "d" => (block, How::BlockWrite),
                        Some(Effect::Block) => (block, How::Block),
                        None => return Err(Unsupported("handler operand")),
                    };
                    // `w128` scalars aren't promoted: blocks. A vector operation's operands are
                    // exact: whole 16-byte fields.
                    let how = match how {
                        How::Write | How::Read if vector_op(h).is_some() => how,
                        How::Write if size > 8 => How::BlockWrite,
                        How::Read | How::Update if size > 8 => How::Block,
                        how => how,
                    };
                    accs.push(acc(off, size, how));
                    slots.push((loc.reg, loc.half()));
                }
                Kind::Handler { h, args, slots, then }
            }
        }
        _ => {
            use full::{Family as F, Opcode as O};
            let fop = op.full().expect("native");
            let fam = fop.family();
            let wd = fop.width().map_or(8, full::OpWidth::bytes);
            let has_imm = fam.is_some_and(F::imm);
            let s = |name: &str| slot(fop, w, name);
            let im = |name: &str| imm(fop, w, name);
            match (fop, fam) {
                (_, Some(F::Mov)) if wd == 16 => Kind::Copy { len: 16, dst: Side::Frame(s("d")), src: Side::Frame(s("s")), pieces: Vec::new() },
                (_, Some(F::Mov)) => {
                    accs.extend([acc(s("s"), wd as u32, How::Read), acc(s("d"), wd as u32, How::Write)]);
                    Kind::Mov(wd)
                }
                (_, Some(F::Imm)) => {
                    accs.push(acc(s("d"), wd as u32, How::Write));
                    Kind::Imm(wd, im("imm"))
                }
                (_, Some(F::Load)) => {
                    let mem = full::Mem { p: full::Slot(s("m")), k: w[fop.info().operand_offset(1).unwrap() + 1] as i32 };
                    accs.extend([acc(mem.p.0, 8, How::Read), acc(s("d"), wd as u32, How::Write)]);
                    Kind::Load(wd, mem.k)
                }
                (_, Some(F::Store)) => {
                    let at_m = fop.info().operand_offset(0).unwrap();
                    accs.extend([acc(w[at_m] as i32, 8, How::Read), acc(s("s"), wd as u32, How::Read)]);
                    Kind::Store(wd, w[at_m + 1] as i32)
                }
                (O::Addr | O::AddrSym | O::AddrSymInd | O::AddrConst, _) => {
                    accs.extend([acc(s("s"), 1, How::Addr), acc(s("d"), 8, How::Write)]);
                    Kind::Addr
                }
                (O::PtrAdd, _) => {
                    accs.extend([acc(s("p"), 8, How::Read), acc(s("d"), 8, How::Write)]);
                    Kind::PtrAdd(im("imm") as i64)
                }
                (O::PtrIndex, _) => {
                    accs.extend([acc(s("p"), 8, How::Read), acc(s("i"), 8, How::Read), acc(s("d"), 8, How::Write)]);
                    Kind::PtrIndex(im("stride") as u32)
                }
                (_, None) if fop.ext().is_some() => {
                    let e = fop.ext().unwrap();
                    let (from, to) = (e.from.bytes() as u8, e.to.bytes() as u8);
                    accs.extend([acc(s("s"), from as u32, How::Read), acc(s("d"), to as u32, How::Write)]);
                    Kind::Ext { from, to, sx: e.sx }
                }
                (_, Some(f @ (F::Cttz | F::Ctlz))) => {
                    pure(&mut accs, &[s("a")], &[wd], s("d"), 4);
                    Kind::Pure { op: super::ir::Op::Count { lz: f == F::Ctlz, w: wd }, ws: alloc::vec![wd], out: 4 }
                }
                (_, Some(f @ (F::Cmp3S | F::Cmp3U))) => {
                    pure(&mut accs, &[s("a"), s("b")], &[wd, wd], s("d"), 1);
                    Kind::Pure { op: super::ir::Op::Cmp3(f == F::Cmp3S, wd), ws: alloc::vec![wd, wd], out: 1 }
                }
                (_, Some(F::Bswap)) => {
                    pure(&mut accs, &[s("a")], &[wd], s("d"), wd);
                    Kind::Pure { op: super::ir::Op::Bswap(wd), ws: alloc::vec![wd], out: wd }
                }
                (_, Some(f @ (F::AddOvfS | F::AddOvfU | F::SubOvfS | F::SubOvfU | F::MulOvfS | F::MulOvfU))) => {
                    let bin = match f {
                        F::AddOvfS | F::AddOvfU => BinOp::Add,
                        F::SubOvfS | F::SubOvfU => BinOp::Sub,
                        _ => BinOp::Mul,
                    };
                    accs.extend([
                        acc(s("a"), wd as u32, How::Read),
                        acc(s("b"), wd as u32, How::Read),
                        acc(s("d"), wd as u32, How::Write),
                        acc(s("o"), 1, How::Write),
                    ]);
                    Kind::Ovf(bin, f.signed() == Some(true), wd)
                }
                (O::Br, _) => {
                    falls = true;
                    let t = rel(slot(fop, w, "t"));
                    succ.push(t);
                    accs.push(acc(s("s"), 1, How::Read));
                    Kind::Br { cmp: None, neg: im("neg") != 0, t }
                }
                (_, Some(f)) if f.is_branch() => {
                    falls = true;
                    let t = rel(slot(fop, w, "t"));
                    succ.push(t);
                    let neg = im("neg") != 0;
                    let cc = ir_cc(f.cc().ok_or(Unsupported("branch"))?);
                    accs.push(acc(s("a"), wd as u32, How::Read));
                    let b = if has_imm { Some(im("imm")) } else { None };
                    if b.is_none() {
                        accs.push(acc(s("b"), wd as u32, How::Read));
                    }
                    Kind::Br { cmp: Some((cc, wd, b)), neg, t }
                }
                _ => {
                    let f = fam.ok_or(Unsupported("a native instruction"))?;
                    accs.push(acc(s("a"), wd as u32, How::Read));
                    let b = if has_imm { Some(im("imm")) } else { None };
                    if b.is_none() {
                        accs.push(acc(s("b"), wd as u32, How::Read));
                    }
                    if let Some(cc) = f.cc() {
                        accs.push(acc(s("d"), 1, How::Write));
                        Kind::Cmp(ir_cc(cc), wd, b)
                    } else {
                        let bin = match f {
                            F::Add | F::AddImm => BinOp::Add,
                            F::Sub | F::SubImm => BinOp::Sub,
                            F::Mul | F::MulImm => BinOp::Mul,
                            F::And | F::AndImm => BinOp::And,
                            F::Or | F::OrImm => BinOp::Or,
                            F::Xor | F::XorImm => BinOp::Xor,
                            F::Shl | F::ShlImm => BinOp::Shl,
                            F::ShrS | F::ShrSImm => BinOp::ShrS,
                            F::ShrU | F::ShrUImm => BinOp::ShrU,
                            _ => return Err(Unsupported("a native instruction")),
                        };
                        accs.push(acc(s("d"), wd as u32, How::Write));
                        Kind::Bin(bin, wd, b)
                    }
                }
            }
        }
    };
    if let Some(fo) = op.full() {
        let mut f = w.to_vec();
        f[0] = fo as u32;
        if !asm::return_ok(&f) {
            return Err(Unsupported("return kind"));
        }
    }
    if falls {
        succ.insert(0, (at + len) as u32);
    }
    // A read past the frame's top (`ret`'s and the calls' load widths read up to the next
    // power of two past a 3, 5, 6 or 7-byte value) reads bytes that don't matter: only the
    // frame's part counts.
    for a in &mut accs {
        if a.how == How::Read && a.off < 0 && a.off as i64 + a.size as i64 > 0 {
            a.size = (-a.off) as u32;
        }
    }
    Ok(RInsn { kind, accs, succ, falls, unwind: Unwind::None })
}

/// Decodes `d` into instructions and blocks.
pub fn decode(d: &Decoded, mode: Mode, mem: Option<&dyn super::opt::ConstMem>) -> Result<Code, Unsupported> {
    let (insns, scopes, heads) = decode_insns(d, mode, mem)?;
    let (blocks, block_of) = form_blocks(&insns, &heads)?;
    let cyclic = cyclic_blocks(blocks.len(), |b| &blocks[b].succ);
    let mut enterable = alloc::vec![false; heads.len()];
    for (b, bl) in blocks.iter().enumerate() {
        let Some(h) = bl.head else { continue };
        let first = &insns[bl.start as usize].kind;
        enterable[h as usize] = cyclic[b] && !matches!(first, Kind::Arg(_) | Kind::Lpad);
    }
    Ok(Code { insns, scopes, blocks, block_of, enterable })
}

/// The instructions of `d` with their targets, unwinding and copy pieces, its scopes, and
/// its loop heads, all by instruction index.
fn decode_insns(d: &Decoded, mode: Mode, mem: Option<&dyn super::opt::ConstMem>) -> Result<(Vec<RInsn>, Vec<ScopeAt>, Vec<u32>), Unsupported> {
    // Instruction starts first, for the scopes' positions.
    let mut starts = Vec::new();
    let mut at = 0;
    while at < d.words.len() {
        starts.push(at as u32);
        at += reduced::insn_len(&d.words[at..]).map_err(|_| Unsupported("reduced code"))?;
    }
    let n = starts.len();
    let idx = |w: u32| starts.binary_search(&w).map(|i| i as u32).map_err(|_| Unsupported("a branch target"));
    let mut scopes = Vec::with_capacity(d.scopes.len());
    for s in &d.scopes {
        let at = if s.code_offset as usize == d.words.len() { n as u32 } else { idx(s.code_offset)? };
        scopes.push(ScopeAt { at, off: s.frame_offset, size: s.size, kind: s.kind });
    }
    let mut insns = Vec::with_capacity(n);
    let mut si = 0;
    for (i, &w) in starts.iter().enumerate() {
        while si < scopes.len() && (scopes[si].at as usize) < i {
            si += 1;
        }
        let lends: Vec<ScopeAt> = scopes[si..].iter().take_while(|s| s.at as usize == i).filter(|s| s.kind == ScopeKind::Lend).copied().collect();
        let mut ri = insn(d, w as usize, &lends, mode, mem.is_some())?;
        for s in ri.succ.iter_mut() {
            *s = if *s as usize == d.words.len() { return Err(Unsupported("falls off the end")) } else { idx(*s)? };
        }
        // The kinds' targets, to instruction indices too.
        match &mut ri.kind {
            Kind::Jmp(t) | Kind::Br { t, .. } | Kind::Handler { then: Then::Branch { t, .. }, .. } => *t = idx(*t)?,
            Kind::Handler { then: Then::Table(ts), .. } => {
                for t in ts.iter_mut() {
                    *t = idx(*t)?;
                }
            }
            _ => {}
        }
        insns.push(ri);
    }
    cut_copies(&mut insns, mem);
    for e in &d.cleanup {
        let i = idx(e.offset)? as usize;
        if !insns[i].may_unwind() {
            continue;
        }
        insns[i].unwind = if e.target == CONTINUE {
            Unwind::Continue
        } else {
            let p = idx(e.target & !CATCH)?;
            if insns[p as usize].kind != Kind::Lpad {
                return Err(Unsupported("a landing pad that isn't an lpad"));
            }
            Unwind::Pad { pad: p, catch: e.target & CATCH != 0 }
        };
    }
    for (i, ri) in insns.iter().enumerate() {
        if matches!(ri.kind, Kind::Arg(_)) && insns[..i].iter().any(|p| !matches!(p.kind, Kind::Arg(_))) {
            return Err(Unsupported("an arg after the start"));
        }
    }
    let heads = d.heads.iter().map(|&h| idx(h)).collect::<Result<_, _>>()?;
    Ok((insns, scopes, heads))
}

/// Cuts the instructions into blocks, with their CFG and loop heads (`heads`, instruction
/// indices): the blocks and the block of each instruction.
fn form_blocks(insns: &[RInsn], heads: &[u32]) -> Result<(Vec<RBlock>, Vec<u32>), Unsupported> {
    let n = insns.len();
    // Leaders: the start, targets, after terminators, branches, calls with a landing pad,
    // landing pads and the instruction after them, and loop heads.
    let mut leader = alloc::vec![false; n + 1];
    leader[0] = true;
    for (i, ri) in insns.iter().enumerate() {
        let ends = !ri.falls
            || ri.succ.len() > 1
            || matches!(ri.unwind, Unwind::Pad { .. })
            || matches!(ri.kind, Kind::Handler { then: Then::Table(_), .. });
        if ends {
            leader[i + 1] = true;
        }
        for &s in &ri.succ {
            if s as usize != i + 1 {
                leader[s as usize] = true;
            }
        }
        if let Unwind::Pad { pad, .. } = ri.unwind {
            leader[pad as usize] = true;
            leader[pad as usize + 1] = true;
        }
    }
    for &h in heads {
        leader[h as usize] = true;
    }
    let mut blocks: Vec<RBlock> = Vec::new();
    let mut block_of = alloc::vec![0u32; n];
    for i in 0..n {
        if leader[i] {
            blocks.push(RBlock { start: i as u32, end: i as u32, succ: Vec::new(), pad: None, preds: Vec::new(), head: None });
        }
        let b = blocks.len() - 1;
        blocks[b].end = i as u32 + 1;
        block_of[i] = b as u32;
    }
    for (k, &h) in heads.iter().enumerate() {
        let b = block_of[h as usize] as usize;
        blocks[b].head = Some(k as u32);
    }
    for b in 0..blocks.len() {
        let last = &insns[blocks[b].end as usize - 1];
        let mut succ: Vec<u32> = last.succ.iter().map(|&s| block_of[s as usize]).collect();
        if let Unwind::Pad { pad, .. } = last.unwind {
            blocks[b].pad = Some(block_of[pad as usize]);
            succ.push(block_of[pad as usize]);
        }
        for &s in &succ {
            blocks[s as usize].preds.push(b as u32);
        }
        blocks[b].succ = succ;
    }
    // An `lpad` is reached only by unwinding.
    for (b, bl) in blocks.iter().enumerate() {
        if insns[bl.start as usize].kind == Kind::Lpad && bl.preds.iter().any(|&p| blocks[p as usize].pad != Some(b as u32)) {
            return Err(Unsupported("an lpad reached without unwinding"));
        }
    }

    Ok((blocks, block_of))
}

/// By block of a CFG of `nb` blocks with successors `succ`, whether it lies on a cycle: in
/// a strongly connected component of more than one block, or with a self edge (Tarjan,
/// iteratively).
fn cyclic_blocks<'a>(nb: usize, succ: impl Fn(usize) -> &'a [u32]) -> Vec<bool> {
    let mut index = alloc::vec![u32::MAX; nb];
    let mut low = alloc::vec![0u32; nb];
    let mut on = alloc::vec![false; nb];
    let mut comp = alloc::vec![u32::MAX; nb];
    let mut comp_size: Vec<u32> = Vec::new();
    let mut stack = Vec::new();
    let mut next = 0;
    for root in 0..nb {
        if index[root] != u32::MAX {
            continue;
        }
        let mut work: Vec<(usize, usize)> = alloc::vec![(root, 0)];
        index[root] = next;
        low[root] = next;
        next += 1;
        stack.push(root);
        on[root] = true;
        while let Some(&mut (v, ref mut k)) = work.last_mut() {
            if *k < succ(v).len() {
                let w = succ(v)[*k] as usize;
                *k += 1;
                if index[w] == u32::MAX {
                    index[w] = next;
                    low[w] = next;
                    next += 1;
                    stack.push(w);
                    on[w] = true;
                    work.push((w, 0));
                } else if on[w] {
                    low[v] = low[v].min(index[w]);
                }
            } else {
                work.pop();
                if let Some(&(u, _)) = work.last() {
                    low[u] = low[u].min(low[v]);
                }
                if low[v] == index[v] {
                    let c = comp_size.len() as u32;
                    let mut size = 0;
                    loop {
                        let w = stack.pop().expect("on the stack");
                        on[w] = false;
                        comp[w] = c;
                        size += 1;
                        if w == v {
                            break;
                        }
                    }
                    comp_size.push(size);
                }
            }
        }
    }
    (0..nb).map(|b| comp_size[comp[b] as usize] > 1 || succ(b).contains(&(b as u32))).collect()
}
