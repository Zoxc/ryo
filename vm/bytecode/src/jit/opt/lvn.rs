//! Local value numbering (design/jit.md, "The SSA tier"): one forward pass per block, in
//! reverse postorder, before the folds ([`super::fold`]). Copies and constants are
//! already propagated by construction (a `mov` or an `imm` defines no value of its own); this
//! pass adds:
//! - **constant folding** of pure operations whose operands are all constants, and algebraic
//!   identities (`x + 0`, `x * 1`, `x & -1`, `x - x`, a compare of a value with itself,
//!   `p + i * s` with a constant `i`, `PtrAdd` chains, `PtrAdd` of an `AllocaAddr`), with a
//!   commutative operation's constant put second;
//! - **common subexpressions**: a pure operation with the same operands as an earlier one in
//!   the block is replaced by it;
//! - **redundant load elimination and store-to-load forwarding**: a load from the same alloca
//!   bytes, or the same pointer value and offset, as an earlier load or store in the block,
//!   with nothing in between that may write them, is replaced by the value loaded or stored
//!   (at least as wide: values are read by their low bytes).
//!
//! What may write what: a store through a pointer may write any other pointer's bytes and
//! the escaped (or pinned) allocas, never the others; a store to an alloca only its own
//! bytes; a handler the allocas its operands name and, if it touches memory, what a pointer
//! store may; a call every escaped alloca, the outgoing area and anything through a
//! pointer; an island anything. Replaced values become aliases, resolved at the end.

use alloc::collections::BTreeMap;
use alloc::vec::Vec;

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

pub(super) fn eval_bin(op: BinOp, w: u8, a: u64, b: u64) -> u64 {
    let (a, b) = (mask(a, w), mask(b, w));
    let r = match op {
        BinOp::Add => a.wrapping_add(b),
        BinOp::Sub => a.wrapping_sub(b),
        BinOp::Mul => a.wrapping_mul(b),
        BinOp::And => a & b,
        BinOp::Or => a | b,
        BinOp::Xor => a ^ b,
        BinOp::Shl => a.wrapping_shl(b as u32),
        BinOp::ShrU => a.wrapping_shr(b as u32),
        BinOp::ShrS => sext(a, w).wrapping_shr(b as u32) as u64,
    };
    mask(r, w)
}

/// A pure operation's key for common subexpressions: a tag, its immediates, its operands.
type Key = (u8, u64, u64, u32, u32);

fn key(op: &Op, args: &[Value]) -> Option<Key> {
    let a = |n: usize| args.get(n).map_or(u32::MAX, |v| v.0);
    Some(match *op {
        Op::Bin(o, w) => (0, o as u64, w as u64, a(0), a(1)),
        Op::Cmp(cc, w) => (1, cc as u64, w as u64, a(0), a(1)),
        Op::Ext { from, to, sx } => (2, from as u64 | (to as u64) << 8 | (sx as u64) << 16, 0, a(0), u32::MAX),
        Op::PtrAdd(k) => (3, k as u64, 0, a(0), u32::MAX),
        Op::PtrIndex(s) => (4, s as u64, 0, a(0), a(1)),
        Op::AllocaAddr(al, k) => (5, al.0 as u64, k as u32 as u64, u32::MAX, u32::MAX),
        Op::RefAddr(to, ind) => {
            let (kind, x) = match to {
                Ref::Const(k) => (0, k.0),
                Ref::Data(d) => (1, d.0),
                Ref::Sym(s) => (2, s.0),
                _ => return None,
            };
            (6, kind | (ind as u64) << 8, x as u64, u32::MAX, u32::MAX)
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

/// Folds or rewrites the pure instruction `i` in place.
pub(super) fn simplify(f: &mut Func, i: Inst) -> Simp {
    let konst = |f: &Func, v: Value| match f.def(v) {
        ValueDef::Const(c) => Some(c),
        _ => None,
    };
    let def_inst = |f: &Func, v: Value| match f.def(v) {
        ValueDef::Inst(d, 0) => Some((f.insts[d.idx()].op.clone(), f.insts[d.idx()].args.clone())),
        _ => None,
    };
    let op = f.insts[i.idx()].op.clone();
    let args = f.insts[i.idx()].args.clone();
    match op {
        Op::Bin(o, w) => {
            let (mut a, mut b) = (args[0], args[1]);
            if let (Some(x), Some(y)) = (konst(f, a), konst(f, b)) {
                return Simp::Const(eval_bin(o, w, x, y));
            }
            if o.commutative() && konst(f, a).is_some() {
                core::mem::swap(&mut a, &mut b);
                f.insts[i.idx()].args = alloc::vec![a, b];
            }
            let all = mask(u64::MAX, w);
            match (o, konst(f, b).map(|c| mask(c, w))) {
                (BinOp::Add | BinOp::Sub | BinOp::Or | BinOp::Xor | BinOp::Shl | BinOp::ShrS | BinOp::ShrU, Some(0)) => return Simp::Value(a),
                (BinOp::Mul, Some(1)) => return Simp::Value(a),
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
            Simp::Keep
        }
        Op::Cmp(cc, w) => {
            let (a, b) = (args[0], args[1]);
            if let (Some(x), Some(y)) = (konst(f, a), konst(f, b)) {
                return Simp::Const(cc.holds(w, x, y) as u64);
            }
            if a == b && !matches!(f.def(a), ValueDef::Undef) {
                return Simp::Const(matches!(cc, Cc::Eq | Cc::LeS | Cc::LeU | Cc::GeS | Cc::GeU) as u64);
            }
            if konst(f, a).is_some() {
                f.insts[i.idx()].op = Op::Cmp(cc.swap(), w);
                f.insts[i.idx()].args = alloc::vec![b, a];
            }
            Simp::Keep
        }
        Op::Ext { from, to, sx } => {
            if let Some(x) = konst(f, args[0]) {
                let x = mask(x, from);
                return Simp::Const(mask(if sx { sext(x, from) as u64 } else { x }, to));
            }
            if from == to {
                return Simp::Value(args[0]);
            }
            Simp::Keep
        }
        Op::PtrAdd(k) => {
            if k == 0 {
                return Simp::Value(args[0]);
            }
            if let Some(x) = konst(f, args[0]) {
                return Simp::Const(x.wrapping_add(k as u64));
            }
            match def_inst(f, args[0]) {
                Some((Op::PtrAdd(j), pa)) => {
                    let s = j.wrapping_add(k);
                    if s == 0 {
                        return Simp::Value(pa[0]);
                    }
                    f.insts[i.idx()].op = Op::PtrAdd(s);
                    f.insts[i.idx()].args = pa;
                }
                Some((Op::AllocaAddr(al, o), _)) => {
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
        Op::PtrIndex(s) => {
            match (konst(f, args[0]), konst(f, args[1])) {
                (Some(p), Some(x)) => return Simp::Const(p.wrapping_add(x.wrapping_mul(s as u64))),
                (_, Some(x)) => {
                    f.insts[i.idx()].op = Op::PtrAdd(x.wrapping_mul(s as u64) as i64);
                    f.insts[i.idx()].args.truncate(1);
                    // The new `PtrAdd` may fold further.
                    return simplify(f, i);
                }
                _ => {}
            }
            Simp::Keep
        }
        _ => Simp::Keep,
    }
}

/// Runs local value numbering on every reachable block of `f`.
pub fn lvn(f: &mut Func) {
    let aliasable: Vec<bool> = f.allocas.iter().map(|a| a.escaped || a.pinned).collect();
    let mut pure: BTreeMap<Key, Value> = BTreeMap::new();
    let mut mem: Vec<(Loc, u8, Value)> = Vec::new();
    for b in f.rpo() {
        pure.clear();
        mem.clear();
        let insts = core::mem::take(&mut f.blocks[b.idx()].insts);
        let mut kept = Vec::with_capacity(insts.len());
        for i in insts {
            for k in 0..f.insts[i.idx()].args.len() {
                f.insts[i.idx()].args[k] = f.resolve(f.insts[i.idx()].args[k]);
            }
            let res = f.insts[i.idx()].res;
            let alias = |f: &mut Func, v: Value| f.values[res as usize].def = ValueDef::Alias(v);
            let op = f.insts[i.idx()].op.clone();
            if op.pure() {
                match simplify(f, i) {
                    Simp::Value(v) => {
                        alias(f, v);
                        continue;
                    }
                    Simp::Const(c) => {
                        let w = f.w(Value(res));
                        let c = f.konst(mask(c, w), w);
                        alias(f, c);
                        continue;
                    }
                    Simp::Keep => {}
                }
                let id = &f.insts[i.idx()];
                if let Some(k) = key(&id.op, &id.args) {
                    if let Some(&v) = pure.get(&k)
                        && f.w(v) >= f.w(Value(res))
                    {
                        alias(f, v);
                        continue;
                    }
                    pure.insert(k, Value(res));
                }
                kept.push(i);
                continue;
            }
            super::fold::fold_addr(f, i);
            let op = f.insts[i.idx()].op.clone();
            let args = f.insts[i.idx()].args.clone();
            let lookup = |f: &Func, mem: &[(Loc, u8, Value)], l: Loc, w: u8| {
                mem.iter().rev().find(|e| e.0 == l && e.1 >= w).map(|e| e.2).filter(|&v| f.w(v) >= w)
            };
            let remember = |mem: &mut Vec<(Loc, u8, Value)>, l: Loc, w: u8, v: Value| {
                if mem.len() == MAX_MEM {
                    mem.remove(0);
                }
                mem.push((l, w, v));
            };
            match op {
                Op::ALoad(a, off, w) => {
                    if let Some(v) = lookup(f, &mem, Loc::A(a, off), w) {
                        alias(f, v);
                        continue;
                    }
                    remember(&mut mem, Loc::A(a, off), w, Value(res));
                }
                Op::Load(w, off) => {
                    if let Some(v) = lookup(f, &mem, Loc::P(args[0], off), w) {
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
                    let named: Vec<AllocaId> = h
                        .regs
                        .iter()
                        .flat_map(|r| r.1)
                        .flatten()
                        .filter_map(|s| if let SlotRef::Alloca(a, _) = s { Some(a) } else { None })
                        .collect();
                    mem.retain(|&(l, _, _)| match l {
                        Loc::A(b, _) => !named.contains(&b) && !(memory && aliasable[b.idx()]),
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
    }
    f.resolve_aliases();
}
