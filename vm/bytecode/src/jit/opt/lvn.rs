//! Value numbering (design/jit.md, "The SSA tier"): one forward pass per block, in a preorder
//! walk of the dominator tree, before the folds ([`super::fold`]). Copies and constants are
//! already propagated by construction (a `mov` or an `imm` defines no value of its own); this
//! pass adds:
//! - **constant folding** of pure operations whose operands are all constants, and algebraic
//!   identities (`x + 0`, `x * 1`, `x & -1`, `x - x`, a compare of a value with itself,
//!   `p + i * s` with a constant `i`, `PtrAdd` chains, `PtrAdd` of an `AllocaAddr`), with a
//!   commutative operation's constant put second, and of the `ctpop`/`ctlz`/`cttz` handler
//!   calls of a constant;
//! - **common subexpressions**: a pure operation with the same operands as an earlier one in
//!   the block or a dominating block is replaced by it (addresses only within a block: they
//!   are cheaper to recompute than to keep live);
//! - **redundant load elimination and store-to-load forwarding**: a load from the same alloca
//!   bytes, or the same pointer value and offset, as an earlier load or store in the block,
//!   with nothing in between that may write them, is replaced by the value loaded or stored
//!   (at least as wide: values are read by their low bytes). A block with a single
//!   predecessor starts from what that one's end knows (extended basic blocks);
//! - **constant loads**: a load from a constant pool ([`super::ConstMem`]) becomes the
//!   constant it reads, or a relocated pointer field the `RefAddr` of its target. Stores
//!   to the pool are UB, so nothing kills these.
//!
//! What may write what: a store through a pointer may write any other pointer's bytes and
//! the escaped (or pinned) allocas, never the others; a store to an alloca only its own
//! bytes; a handler the allocas its operands name and, if it touches memory, what a pointer
//! store may; a call every escaped alloca, the outgoing area and anything through a
//! pointer; an island anything. Replaced values become aliases, resolved at the end.

use alloc::collections::BTreeMap;
use alloc::vec::Vec;

use super::{ConstAt, ConstMem, PoolRead};
use crate::asm::Ref;
use crate::jit::ir::*;

/// What a block's memory is known to hold: the bytes at an alloca offset, or at a pointer
/// value plus an offset, with their width, and the value they hold.
#[derive(Clone, Copy, PartialEq, Eq)]
enum Loc {
    A(AllocaId, i32),
    P(Value, i32),
}

/// At most this many remembered memory values per block, to keep the pass linear.
const MAX_MEM: usize = 32;

/// A pure operation's key for common subexpressions: its kind, its immediates, its operands.
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
enum Key {
    Bin(BinOp, u8, Value, Value),
    Cmp(Cc, u8, Value, Value),
    Ext {
        from: u8,
        to: u8,
        sx: bool,
        x: Value,
    },
    Bswap(u8, Value),
    Count {
        lz: bool,
        w: u8,
        x: Value,
    },
    Cmp3(bool, u8, Value, Value),
    SwitchIdx {
        w: u8,
        base: u64,
        n: u32,
        x: Value,
    },
    PtrAdd(i64, Value),
    PtrIndex(u32, Value, Value),
    AllocaAddr(AllocaId, i32),
    /// The [`Ref`] kind (constant, data, symbol), its index, and whether indirect.
    RefAddr(u8, u32, bool),
    V(VOp, Value, Option<Value>),
    VConst(u128),
}

impl Key {
    /// Addresses are cheaper to recompute than to keep live across blocks.
    fn block_local(&self) -> bool {
        matches!(self, Key::AllocaAddr(..) | Key::RefAddr(..))
    }
}

fn key(op: &Op, args: &[Value]) -> Option<Key> {
    Some(match *op {
        Op::Bin(o, w) => Key::Bin(o, w, args[0], args[1]),
        Op::Cmp(cc, w) => Key::Cmp(cc, w, args[0], args[1]),
        Op::Bswap(w) => Key::Bswap(w, args[0]),
        Op::Count { lz, w } => Key::Count { lz, w, x: args[0] },
        Op::Cmp3(signed, w) => Key::Cmp3(signed, w, args[0], args[1]),
        Op::SwitchIdx { w, base, n } => Key::SwitchIdx { w, base, n, x: args[0] },
        Op::Ext { from, to, sx } => Key::Ext { from, to, sx, x: args[0] },
        Op::PtrAdd(k) => Key::PtrAdd(k, args[0]),
        Op::PtrIndex(s) => Key::PtrIndex(s, args[0], args[1]),
        Op::AllocaAddr(al, k) => Key::AllocaAddr(al, k),
        Op::V(o) => Key::V(o, args[0], args.get(1).copied()),
        Op::VConst(c) => Key::VConst(c),
        Op::RefAddr(to, ind) => {
            let (kind, x) = match to {
                Ref::Const(k) => (0, k.0),
                Ref::Data(d) => (1, d.0),
                Ref::Sym(s) => (2, s.0),
                _ => return None,
            };
            Key::RefAddr(kind, x, ind)
        }
        _ => return None,
    })
}

/// What [`simplify`] makes of an instruction.
pub(super) enum Simp {
    /// Its result is this value.
    Value(Value),
    /// Its result is this constant.
    Const(u64),
    /// It stays (maybe rewritten).
    Keep,
}

impl Simp {
    /// Applies it to `res`, the instruction's result: whether the instruction goes.
    pub(super) fn apply(self, f: &mut Func, res: Value) -> bool {
        match self {
            Simp::Value(v) => f.values[res.idx()].def = ValueDef::Alias(v),
            Simp::Const(c) => f.alias_const(res, c),
            Simp::Keep => return false,
        }
        true
    }
}

/// Folds or rewrites the pure instruction `i` in place.
pub(super) fn simplify(f: &mut Func, i: Inst) -> Simp {
    let konst = |f: &Func, v: Value| match f.def(v) {
        ValueDef::Const(c) => Some(c),
        _ => None,
    };
    // The instruction defining `v`, its only result.
    let def_inst = |f: &Func, v: Value| match f.def(v) {
        ValueDef::Inst(d, 0) => Some(d),
        _ => None,
    };
    // The first two operands (the others take no more; a missing one is never read).
    let args = f.insts[i.idx()].args2();
    if let Op::HCall(h) = &f.insts[i.idx()].op {
        // `bit_count` checks there is exactly one operand.
        return match bit_count(f, i, h).and_then(|g| Some(g(konst(f, args[0])?))) {
            Some(c) => Simp::Const(c as u64),
            None => Simp::Keep,
        };
    }
    // Not a handler call: cloning it allocates nothing.
    let op = f.insts[i.idx()].op.clone();
    let n = f.insts[i.idx()].args.len().min(2);
    let mut xs = [0; 2];
    if args[..n].iter().zip(&mut xs).all(|(&a, x)| konst(f, a).map(|c| *x = c).is_some()) {
        if let Some(c) = op.fold(&xs[..n]) {
            return Simp::Const(c);
        }
    }
    match op {
        Op::V(o) => simplify_v(f, i, o, args),
        Op::VConst(c) => match u64::try_from(c) {
            Ok(c) => Simp::Const(c),
            Err(_) => Simp::Keep,
        },
        Op::Bin(o, 16) => {
            let (a, b) = (args[0], args[1]);
            match (vconst(f, a), vconst(f, b)) {
                (Some(x), Some(y)) => {
                    let r = match o {
                        BinOp::And => x & y,
                        BinOp::Or => x | y,
                        _ => x ^ y,
                    };
                    return set_vconst(f, i, r);
                }
                (Some(c), None) | (None, Some(c)) => {
                    let other = if vconst(f, a).is_some() { b } else { a };
                    let k = if vconst(f, a).is_some() { a } else { b };
                    match (o, c) {
                        (BinOp::And, 0) => return Simp::Const(0),
                        (BinOp::Or | BinOp::Xor, 0) => return Simp::Value(other),
                        (BinOp::And, u128::MAX) => return Simp::Value(other),
                        (BinOp::Or, u128::MAX) => return Simp::Value(k),
                        _ => {}
                    }
                }
                _ => {}
            }
            if a == b && !matches!(f.def(a), ValueDef::Undef) {
                match o {
                    BinOp::Xor => return Simp::Const(0),
                    _ => return Simp::Value(a),
                }
            }
            Simp::Keep
        }
        Op::Bin(o, w) => {
            let (mut a, mut b) = (args[0], args[1]);
            if o.commutative() && konst(f, a).is_some() {
                core::mem::swap(&mut a, &mut b);
                f.insts[i.idx()].args.swap(0, 1);
            }
            let all = mask(u64::MAX, w);
            match (o, konst(f, b).map(|c| mask(c, w))) {
                (BinOp::Add | BinOp::Sub | BinOp::Or | BinOp::Xor | BinOp::Shl | BinOp::ShrS | BinOp::ShrU | BinOp::Rotl | BinOp::Rotr, Some(0)) => {
                    return Simp::Value(a);
                }
                (BinOp::Mul | BinOp::DivS | BinOp::DivU, Some(1)) => return Simp::Value(a),
                (BinOp::Mul | BinOp::And, Some(0)) => return Simp::Const(0),
                (BinOp::And, Some(c)) if c == all => return Simp::Value(a),
                (BinOp::Or, Some(c)) if c == all => return Simp::Const(all),
                _ => {}
            }
            if a == b && !matches!(f.def(a), ValueDef::Undef) {
                match o {
                    BinOp::Sub | BinOp::Xor => return Simp::Const(0),
                    BinOp::And | BinOp::Or => return Simp::Value(a),
                    _ => {}
                }
            }
            if o == BinOp::Or
                && let Some(v) = reassembled(f, Value(f.insts[i.idx()].res), w)
            {
                return Simp::Value(v);
            }
            Simp::Keep
        }
        Op::Cmp(cc, w) => {
            let (a, b) = (args[0], args[1]);
            if a == b && !matches!(f.def(a), ValueDef::Undef) {
                return Simp::Const(cc.reflexive() as u64);
            }
            if konst(f, a).is_some() {
                f.insts[i.idx()].op = Op::Cmp(cc.swap(), w);
                f.insts[i.idx()].args.swap(0, 1);
            }
            Simp::Keep
        }
        Op::Ext { from, to, .. } => {
            if from == to {
                return Simp::Value(args[0]);
            }
            // The low bytes of a zero extension back to its source's width: the source.
            if let Some(d) = def_inst(f, args[0])
                && let Op::Ext { from: f0, to: t0, sx: false } = f.insts[d.idx()].op
                && t0 > f0
                && t0 == from
                && to == f0
                && f.w(f.insts[d.idx()].args[0]) == f0
            {
                return Simp::Value(f.insts[d.idx()].args[0]);
            }
            Simp::Keep
        }
        Op::PtrAdd(k) => {
            if k == 0 {
                return Simp::Value(args[0]);
            }
            let d = def_inst(f, args[0]);
            match d.map(|d| &f.insts[d.idx()].op) {
                Some(&Op::PtrAdd(j)) => {
                    let p = f.insts[d.unwrap().idx()].args[0];
                    let s = j.wrapping_add(k);
                    if s == 0 {
                        return Simp::Value(p);
                    }
                    f.insts[i.idx()].op = Op::PtrAdd(s);
                    f.insts[i.idx()].args[0] = p;
                }
                Some(&Op::AllocaAddr(al, o)) => {
                    let size = f.allocas[al.idx()].size as i64;
                    let n = o as i64 + k;
                    if (0..=size).contains(&n) {
                        f.insts[i.idx()].op = Op::AllocaAddr(al, n as i32);
                        f.insts[i.idx()].args.clear();
                    }
                }
                _ => {}
            }
            Simp::Keep
        }
        Op::Cmp3(..) if args[0] == args[1] => Simp::Const(0),
        Op::PtrIndex(s) => {
            if let Some(x) = konst(f, args[1]) {
                f.insts[i.idx()].op = Op::PtrAdd(x.wrapping_mul(s as u64) as i64);
                f.insts[i.idx()].args.truncate(1);
                // The new `PtrAdd` may fold further.
                return simplify(f, i);
            }
            Simp::Keep
        }
        _ => Simp::Keep,
    }
}

/// A value's bits as pieces of other values' bits: (its bit, length, source, source bit); the
/// bits no piece covers are zero. Through zero extensions, constant shifts and disjoint ors.
fn pieces(f: &Func, v: Value, depth: u32, out: &mut Vec<(u32, u32, Value, u32)>) -> bool {
    let w = 8 * f.w(v) as u32;
    let leaf = |out: &mut Vec<(u32, u32, Value, u32)>| {
        out.push((0, w, v, 0));
        true
    };
    let ValueDef::Inst(d, 0) = f.def(v) else { return leaf(out) };
    if depth == 0 {
        return leaf(out);
    }
    let id = &f.insts[d.idx()];
    let cut = |ps: Vec<(u32, u32, Value, u32)>, sh: i64, bits: u32, out: &mut Vec<(u32, u32, Value, u32)>| {
        for (at, n, s, sb) in ps {
            let (mut lo, mut hi, mut sb) = (at as i64 + sh, (at + n) as i64 + sh, sb as i64);
            if lo < 0 {
                sb -= lo;
                lo = 0;
            }
            hi = hi.min(bits as i64);
            if lo < hi {
                out.push((lo as u32, (hi - lo) as u32, s, sb as u32));
            }
        }
    };
    let sub = |x: Value| -> Option<Vec<(u32, u32, Value, u32)>> {
        let mut p = Vec::new();
        pieces(f, x, depth - 1, &mut p).then_some(p)
    };
    let konst = |x: Value| if let ValueDef::Const(c) = f.def(x) { Some(c) } else { None };
    match id.op {
        Op::Ext { from, to, sx: false } if to > from => {
            let Some(p) = sub(id.args[0]) else { return false };
            cut(p, 0, 8 * from as u32, out);
            true
        }
        Op::Ext { from, to, .. } if to <= from && f.w(id.args[0]) >= to => {
            let Some(p) = sub(id.args[0]) else { return false };
            cut(p, 0, w, out);
            true
        }
        Op::Bin(o @ (BinOp::Shl | BinOp::ShrU), bw) if bw <= 8 && konst(id.args[1]).is_some() => {
            let c = konst(id.args[1]).unwrap() & (8 * bw as u64 - 1);
            let Some(p) = sub(id.args[0]) else { return false };
            let mut q = Vec::new();
            cut(p, 0, 8 * bw as u32, &mut q);
            cut(q, if o == BinOp::Shl { c as i64 } else { -(c as i64) }, w, out);
            true
        }
        Op::Bin(BinOp::Or, bw) if bw <= 8 => {
            let (Some(a), Some(b)) = (sub(id.args[0]), sub(id.args[1])) else { return false };
            let n = out.len();
            out.extend(a);
            out.extend(b);
            let mut ps = out[n..].to_vec();
            ps.sort_unstable_by_key(|p| p.0);
            ps.windows(2).all(|x| x[0].0 + x[0].1 <= x[1].0)
        }
        _ => leaf(out),
    }
}

/// An or of `w` bytes that puts the low bytes of one value back together: that value.
fn reassembled(f: &Func, v: Value, w: u8) -> Option<Value> {
    let mut ps = Vec::new();
    if !pieces(f, v, 6, &mut ps) {
        return None;
    }
    ps.sort_unstable_by_key(|p| p.0);
    let src = ps.first()?.2;
    let mut at = 0;
    for &(lo, n, s, sb) in &ps {
        if s != src || lo != at || sb != lo {
            return None;
        }
        at += n;
    }
    (at == 8 * w as u32 && f.w(src) >= w && src != v && f.w(src) != 16).then_some(src)
}

/// `v` as a 16-byte constant: a constant (zero-extended) or a [`Op::VConst`].
pub(crate) fn vconst(f: &Func, v: Value) -> Option<u128> {
    match f.def(v) {
        ValueDef::Const(c) => Some(c as u128),
        ValueDef::Inst(d, 0) => match f.insts[d.idx()].op {
            Op::VConst(c) => Some(c),
            _ => None,
        },
        _ => None,
    }
}

/// Instruction `i`'s 16-byte result is the constant `c`: a constant if it is one, else `i`
/// becomes a [`Op::VConst`].
fn set_vconst(f: &mut Func, i: Inst, c: u128) -> Simp {
    if let Ok(c) = u64::try_from(c) {
        return Simp::Const(c);
    }
    let id = &mut f.insts[i.idx()];
    id.op = Op::VConst(c);
    id.args.clear();
    Simp::Keep
}

/// The vector operation `i` folded: on constants, `x == x`, `x < x`, the top bits of a
/// `x < 0` (those of `x`: `_mm_movemask_epi8`), and a half of a pair or a pair of halves.
fn simplify_v(f: &mut Func, i: Inst, o: VOp, args: [Value; 2]) -> Simp {
    let (ws, rw) = o.widths();
    let n = ws.len();
    let mut xs = [0u128; 2];
    let consts = args[..n].iter().zip(&mut xs).all(|(&a, x)| vconst(f, a).map(|c| *x = c).is_some());
    if consts {
        let r = o.eval(&xs[..n]);
        return if rw == 16 { set_vconst(f, i, r) } else { Simp::Const(r as u64) };
    }
    let same = n == 2 && args[0] == args[1] && !matches!(f.def(args[0]), ValueDef::Undef);
    let def = |f: &Func, v: Value| match f.def(v) {
        ValueDef::Inst(d, 0) => Some(d),
        _ => None,
    };
    match o {
        VOp::Eq if same => set_vconst(f, i, u128::MAX),
        VOp::LtS if same => Simp::Const(0),
        VOp::Msb => {
            if let Some(d) = def(f, args[0])
                && f.insts[d.idx()].op == Op::V(VOp::LtS)
                && vconst(f, f.insts[d.idx()].args[1]) == Some(0)
            {
                let x = f.insts[d.idx()].args[0];
                f.insts[i.idx()].args[0] = x;
            }
            Simp::Keep
        }
        VOp::Half(h) => match def(f, args[0]) {
            Some(d) if f.insts[d.idx()].op == Op::V(VOp::Pair) => Simp::Value(f.insts[d.idx()].args[h as usize]),
            _ => Simp::Keep,
        },
        VOp::Pair => match (def(f, args[0]), def(f, args[1])) {
            (Some(x), Some(y))
                if f.insts[x.idx()].op == Op::V(VOp::Half(0))
                    && f.insts[y.idx()].op == Op::V(VOp::Half(1))
                    && f.insts[x.idx()].args[0] == f.insts[y.idx()].args[0] =>
            {
                Simp::Value(f.insts[x.idx()].args[0])
            }
            _ => Simp::Keep,
        },
        _ => Simp::Keep,
    }
}

/// For a register-entry `ctpop`, `ctlz` or `cttz` handler call (W8 to W64) with no site and
/// one operand value: its count, as the handler computes it (`ctlz`/`cttz` of 0 is the width).
fn bit_count(f: &Func, i: Inst, h: &HCall) -> Option<fn(u64) -> u32> {
    use crate::full::Opcode::*;
    if !h.reg || h.site != Site::None || h.ret || h.nout != 1 || f.insts[i.idx()].args.len() != 1 {
        return None;
    }
    Some(match h.h {
        CtpopW8 => |x| (x as u8).count_ones(),
        CtlzW8 => |x| (x as u8).leading_zeros(),
        CttzW8 => |x| (x as u8).trailing_zeros(),
        CtpopW16 => |x| (x as u16).count_ones(),
        CtlzW16 => |x| (x as u16).leading_zeros(),
        CttzW16 => |x| (x as u16).trailing_zeros(),
        CtpopW32 => |x| (x as u32).count_ones(),
        CtlzW32 => |x| (x as u32).leading_zeros(),
        CttzW32 => |x| (x as u32).trailing_zeros(),
        CtpopW64 => |x| x.count_ones(),
        CtlzW64 => |x| x.leading_zeros(),
        CttzW64 => |x| x.trailing_zeros(),
        _ => return None,
    })
}

/// The constant address a load of `p` plus `off` reads, if `p` is one.
fn const_at(f: &Func, p: Value, off: i32) -> Option<ConstAt> {
    match f.def(p) {
        ValueDef::Const(a) => Some(ConstAt::Abs(a.wrapping_add(off as i64 as u64))),
        ValueDef::Inst(d, 0) => match f.insts[d.idx()].op {
            Op::RefAddr(Ref::Const(k), false) => u32::try_from(k.0 as i64 + off as i64).ok().map(ConstAt::Root),
            _ => None,
        },
        _ => None,
    }
}

/// Whether a load of `f` reads a constant address (that value numbering may fold).
pub(super) fn const_loads(f: &Func) -> bool {
    f.layout.iter().flat_map(|b| &f.blocks[b.idx()].insts).any(|&i| {
        let id = &f.insts[i.idx()];
        matches!(id.op, Op::Load(_, off) if const_at(f, id.args[0], off).is_some())
    })
}

/// Folds the load `i` from constant memory (design/provenance.md, rule 5): into the constant
/// it reads, or for a relocated field read whole into the image's pool or data area, the
/// `RefAddr` of its target (which keeps its provenance). `Some(c)` if it became the
/// constant `c`; it may also have become a `RefAddr` (pure).
fn fold_const_load(f: &mut Func, i: Inst, mem: &dyn ConstMem) -> Option<u64> {
    let Op::Load(w, off) = f.insts[i.idx()].op else { return None };
    if w == 16 {
        // A vector: two plain 8-byte halves.
        let a = const_at(f, f.insts[i.idx()].args[0], off)?;
        let b = const_at(f, f.insts[i.idx()].args[0], off + 8)?;
        let (PoolRead::Bits(lo), PoolRead::Bits(hi)) = (mem.read(a, 8)?, mem.read(b, 8)?) else { return None };
        let c = lo as u128 | (hi as u128) << 64;
        if let Ok(c) = u64::try_from(c) {
            return Some(c);
        }
        let id = &mut f.insts[i.idx()];
        id.op = Op::VConst(c);
        id.args.clear();
        return None;
    }
    if !matches!(w, 1 | 2 | 4 | 8) {
        return None;
    }
    let a = const_at(f, f.insts[i.idx()].args[0], off)?;
    let to = match mem.read(a, w)? {
        PoolRead::Bits(b) => return Some(b),
        // Only a whole field reads as a pointer, and only from the IR's own image.
        PoolRead::Const(t) => Ref::Const(crate::full::Const(t)),
        PoolRead::Data(t) => Ref::Data(crate::full::Data(t)),
    };
    let id = &mut f.insts[i.idx()];
    id.op = Op::RefAddr(to, false);
    id.args.clear();
    None
}

/// A load of `w` bytes at `l` that the known memory `mem` holds across the vector class: a
/// 16-byte load of two known 8-byte halves is their pair, an 8-byte (or narrower) load of a
/// known vector's half is that half. The new instructions go to `kept` (of block `b`).
fn halves(f: &mut Func, kept: &mut Vec<Inst>, b: Block, mem: &[(Loc, u8, Value)], l: Loc, w: u8) -> Option<Value> {
    let shift = |l: Loc, d: i32| match l {
        Loc::A(a, o) => Loc::A(a, o + d),
        Loc::P(p, o) => Loc::P(p, o + d),
    };
    let find =
        |l: Loc, n: u8, vector: bool| mem.iter().rev().find(|e| e.0 == l && e.1 >= n && (f.w(e.2) == 16) == vector && f.w(e.2) >= n).map(|e| e.2);
    let new = |f: &mut Func, kept: &mut Vec<Inst>, op: Op, args: Vec<Value>, rw: u8| -> Value {
        let k = f.inst(b, op, args, &[rw]);
        f.blocks[b.idx()].insts.pop();
        match simplify(f, k) {
            Simp::Value(v) => v,
            Simp::Const(c) => f.konst(mask(c, rw), rw),
            Simp::Keep => {
                kept.push(k);
                f.result(k)
            }
        }
    };
    if w == 16 {
        let (lo, hi) = (find(l, 8, false)?, find(shift(l, 8), 8, false)?);
        return Some(new(f, kept, Op::V(VOp::Pair), alloc::vec![lo, hi], 16));
    }
    if w > 8 {
        return None;
    }
    let (v, h) = match find(l, 16, true) {
        Some(v) => (v, 0),
        None => (find(shift(l, -8), 16, true)?, 1),
    };
    let x = new(f, kept, Op::V(VOp::Half(h)), alloc::vec![v], 8);
    Some(if w == 8 { x } else { new(f, kept, Op::Ext { from: 8, to: w, sx: false }, alloc::vec![x], w) })
}

/// A pair of the 8-byte loads at `p + k` and `p + k + 8` of this block (`kept`), with nothing
/// between them that may write memory, is one 16-byte load where the first was; the two
/// become its halves. Whether `i`, the pair, became that load.
fn pair_load(f: &mut Func, kept: &mut Vec<Inst>, i: Inst) -> bool {
    let (x, y) = (f.insts[i.idx()].args[0], f.insts[i.idx()].args[1]);
    let load = |f: &Func, v: Value| match f.def(v) {
        ValueDef::Inst(d, 0) => match f.insts[d.idx()].op {
            Op::Load(8, k) => Some((d, f.insts[d.idx()].args[0], k)),
            _ => None,
        },
        _ => None,
    };
    let (Some((lx, px, kx)), Some((ly, py, ky))) = (load(f, x), load(f, y)) else { return false };
    if px != py || ky != kx.wrapping_add(8) {
        return false;
    }
    let (Some(ax), Some(ay)) = (kept.iter().position(|&k| k == lx), kept.iter().position(|&k| k == ly)) else { return false };
    let (lo, hi) = (ax.min(ay), ax.max(ay));
    let writes =
        kept[lo..hi].iter().any(|&k| matches!(f.insts[k.idx()].op, Op::Store(..) | Op::AStore(..) | Op::HCall(_) | Op::Call(_) | Op::Island(_)));
    if writes {
        return false;
    }
    let b = f.insts[i.idx()].block;
    let mk = |f: &mut Func, op: Op, args: Vec<Value>, w: u8| {
        let k = f.inst(b, op, args, &[w]);
        f.blocks[b.idx()].insts.pop();
        k
    };
    let l = mk(f, Op::Load(16, kx), alloc::vec![px], 16);
    let lv = f.result(l);
    let h0 = mk(f, Op::V(VOp::Half(0)), alloc::vec![lv], 8);
    let h1 = mk(f, Op::V(VOp::Half(1)), alloc::vec![lv], 8);
    kept.retain(|&k| k != lx && k != ly);
    kept.splice(lo..lo, [l, h0, h1]);
    let (r0, r1) = (f.result(h0), f.result(h1));
    f.values[x.idx()].def = ValueDef::Alias(r0);
    f.values[y.idx()].def = ValueDef::Alias(r1);
    let r = f.insts[i.idx()].res as usize;
    f.values[r].def = ValueDef::Alias(lv);
    true
}

/// Runs value numbering on every reachable block of `f`, walking the dominator tree, with
/// the loads from `mem` folded.
pub fn lvn(f: &mut Func, pools: Option<&dyn ConstMem>) {
    let aliasable: Vec<bool> = f.allocas.iter().map(|a| a.escaped || a.pinned).collect();
    let rpo = f.rpo();
    let idom = f.idoms(&rpo);
    let mut kids: Vec<Vec<Block>> = alloc::vec![Vec::new(); f.blocks.len()];
    for &b in &rpo {
        if let Some(d) = idom[b.idx()] {
            kids[d.idx()].push(b);
        }
    }
    // The pure operations of the dominating blocks, with their block, and an undo log.
    let mut pure: BTreeMap<Key, (Value, Block)> = BTreeMap::new();
    let mut undo: Vec<(Key, Option<(Value, Block)>)> = Vec::new();
    // Per block, its memory at its end, while a successor with no other predecessor may
    // start from it.
    let mut end: Vec<Option<Vec<(Loc, u8, Value)>>> = alloc::vec![None; f.blocks.len()];
    let mut mem: Vec<(Loc, u8, Value)> = Vec::new();
    // Preorder over the dominator tree: `Some(b)` enters `b`, `None` leaves the last entered.
    let mut stack: Vec<Option<Block>> = rpo.iter().rev().filter(|b| idom[b.idx()].is_none()).map(|&b| Some(b)).collect();
    let mut marks: Vec<usize> = Vec::new();
    while let Some(e) = stack.pop() {
        let Some(b) = e else {
            let m = marks.pop().expect("a mark");
            for (k, old) in undo.drain(m..).rev() {
                match old {
                    Some(o) => pure.insert(k, o),
                    None => pure.remove(&k),
                };
            }
            continue;
        };
        marks.push(undo.len());
        stack.push(None);
        stack.extend(kids[b.idx()].iter().rev().map(|&k| Some(k)));
        mem.clear();
        if let [(p, _)] = f.blocks[b.idx()].preds[..]
            && let Some(m) = &end[p.idx()]
        {
            mem.extend_from_slice(m);
        }
        let insts = core::mem::take(&mut f.blocks[b.idx()].insts);
        let mut kept = Vec::with_capacity(insts.len());
        for i in insts {
            for k in 0..f.insts[i.idx()].args.len() {
                f.insts[i.idx()].args[k] = f.resolve(f.insts[i.idx()].args[k]);
            }
            let res = f.insts[i.idx()].res;
            let alias = |f: &mut Func, v: Value| f.values[res as usize].def = ValueDef::Alias(v);
            if let Some(pools) = pools
                && matches!(f.insts[i.idx()].op, Op::Load(..))
            {
                super::fold::fold_addr(f, i);
                if let Some(c) = fold_const_load(f, i, pools) {
                    f.alias_const(Value(res), c);
                    continue;
                }
            }
            let op = &f.insts[i.idx()].op;
            let (bits, is_pure) = (matches!(op, Op::HCall(h) if bit_count(f, i, h).is_some()), op.pure());
            // A bit count of a constant folds; one of a run-time value stays a handler call.
            if bits && let Simp::Const(c) = simplify(f, i) {
                f.alias_const(Value(res), c);
                continue;
            }
            if is_pure && f.insts[i.idx()].op == Op::V(VOp::Pair) && pair_load(f, &mut kept, i) {
                continue;
            }
            if is_pure {
                if simplify(f, i).apply(f, Value(res)) {
                    continue;
                }
                let id = &f.insts[i.idx()];
                if let Some(k) = key(&id.op, &id.args) {
                    if let Some(&(v, db)) = pure.get(&k)
                        && f.w(v) >= f.w(Value(res))
                        && (db == b || !k.block_local())
                    {
                        alias(f, v);
                        continue;
                    }
                    undo.push((k, pure.insert(k, (Value(res), b))));
                }
                kept.push(i);
                continue;
            }
            super::fold::fold_addr(f, i);
            let args = f.insts[i.idx()].args2();
            let lookup = |f: &Func, mem: &[(Loc, u8, Value)], l: Loc, w: u8| {
                mem.iter().rev().find(|e| e.0 == l && e.1 >= w).map(|e| e.2).filter(|&v| f.w(v) >= w && (f.w(v) == 16) == (w == 16))
            };
            let remember = |mem: &mut Vec<(Loc, u8, Value)>, l: Loc, w: u8, v: Value| {
                if mem.len() == MAX_MEM {
                    mem.remove(0);
                }
                mem.push((l, w, v));
            };
            match f.insts[i.idx()].op {
                Op::ALoad(a, off, w) => {
                    if let Some(v) = lookup(f, &mem, Loc::A(a, off), w).or_else(|| halves(f, &mut kept, b, &mem, Loc::A(a, off), w)) {
                        alias(f, v);
                        continue;
                    }
                    remember(&mut mem, Loc::A(a, off), w, Value(res));
                }
                Op::Load(w, off) => {
                    if let Some(v) = lookup(f, &mem, Loc::P(args[0], off), w).or_else(|| halves(f, &mut kept, b, &mem, Loc::P(args[0], off), w)) {
                        alias(f, v);
                        continue;
                    }
                    remember(&mut mem, Loc::P(args[0], off), w, Value(res));
                }
                Op::AStore(a, off, n) => {
                    let (lo, hi) = (off as i64, off as i64 + n as i64);
                    let esc = aliasable[a.idx()];
                    mem.retain(|&(l, w, _)| match l {
                        Loc::A(b, o) => b != a || o as i64 + w as i64 <= lo || o as i64 >= hi,
                        Loc::P(..) => !esc,
                    });
                    if n.is_power_of_two() && f.w(args[0]) >= n {
                        remember(&mut mem, Loc::A(a, off), n, args[0]);
                    }
                }
                Op::Store(w, off) => {
                    let (p, lo, hi) = (args[0], off as i64, off as i64 + w as i64);
                    mem.retain(|&(l, lw, _)| match l {
                        Loc::A(b, _) => !aliasable[b.idx()],
                        Loc::P(q, o) => q == p && (o as i64 + lw as i64 <= lo || o as i64 >= hi),
                    });
                    remember(&mut mem, Loc::P(p, off), w, args[1]);
                }
                Op::HCall(ref h) => {
                    let memory = crate::jit::effects::effects(h.h).is_none_or(|e| e.memory);
                    mem.retain(|&(l, _, _)| match l {
                        Loc::A(b, _) => !h.allocas().any(|a| a == b) && !(memory && aliasable[b.idx()]),
                        Loc::P(..) => !memory,
                    });
                }
                Op::Call(_) => {
                    let allocas = &f.allocas;
                    mem.retain(|&(l, _, _)| match l {
                        Loc::A(b, _) => !aliasable[b.idx()] && matches!(allocas[b.idx()].kind, AllocaKind::Memory | AllocaKind::Incoming),
                        Loc::P(..) => false,
                    });
                }
                _ => mem.clear(),
            }
            kept.push(i);
        }
        f.blocks[b.idx()].insts = kept;
        if f.blocks[b.idx()].term.edges().any(|e| f.blocks[e.to.idx()].preds.len() == 1) {
            end[b.idx()] = Some(mem.clone());
        }
    }
    f.resolve_aliases();
}
