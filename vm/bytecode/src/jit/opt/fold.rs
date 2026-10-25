//! The folds instruction selection relies on (design/jit.md, "The SSA tier"), after value
//! numbering ([`super::lvn`]): compare- and overflow-branches, branches on negated booleans
//! and on constants, and frame and constant-offset addresses.

use alloc::vec::Vec;

use crate::jit::ir::*;

/// The folds instruction selection relies on, done on the IR (design/jit.md, "The SSA
/// tier"): a compare used only by the branch right after it becomes a compare-branch;
/// loads and stores through a frame address become accesses of the alloca, and through a
/// pointer plus a constant take the constant into their offset.
pub fn fold(f: &mut Func) {
    fold_not(f);
    let uses = use_counts(f);
    let def_op = |f: &Func, v: Value| -> Option<(Inst, Op, Vec<Value>)> {
        match f.def(v) {
            ValueDef::Inst(i, 0) => Some((i, f.insts[i.idx()].op.clone(), f.insts[i.idx()].args.clone())),
            _ => None,
        }
    };
    for b in 0..f.blocks.len() {
        // Compare, then branch on it.
        if let Term::Br { cond, t, f: e } = f.blocks[b].term.clone()
            && uses[cond.idx()] == 1
            && let Some((i, Op::Cmp(cc, w), args)) = def_op(f, cond)
            && f.blocks[b].insts.last() == Some(&i)
        {
            f.blocks[b].insts.pop();
            f.blocks[b].term = Term::BrCmp { cc, w, a: args[0], b: args[1], t, f: e };
        }
        // An overflow op, then a branch on its flag.
        if let Term::Br { cond, t, f: e } = f.blocks[b].term.clone()
            && uses[cond.idx()] == 1
            && let ValueDef::Inst(i, 1) = f.def(cond)
            && matches!(f.insts[i.idx()].op, Op::Ovf(..))
            && f.blocks[b].insts.last() == Some(&i)
        {
            f.blocks[b].term = Term::BrOvf { t, f: e };
        }
        for k in 0..f.blocks[b].insts.len() {
            let i = f.blocks[b].insts[k];
            fold_addr(f, i);
        }
    }
    fold_const_branches(f);
}

/// Replaces the terminator of `b` by `t`, keeping its successors' predecessor lists right.
pub(super) fn set_term(f: &mut Func, b: usize, t: Term) {
    let blk = Block(b as u32);
    for e in f.blocks[b].term.edges().map(|e| e.to).collect::<Vec<_>>() {
        f.blocks[e.idx()].preds.retain(|&(p, _)| p != blk);
    }
    f.blocks[b].term = Term::None;
    f.terminate(blk, t);
}

/// A branch on `x ^ c` (the low byte of it) is a branch on `x != c`; when `x` is a boolean
/// (a compare or an overflow flag) and `c` is 1, it is a branch on `x` with the targets
/// swapped, which the compare-branch fold then takes. The `xor` goes when the branch was its
/// only use.
fn fold_not(f: &mut Func) {
    let uses = use_counts(f);
    for b in 0..f.blocks.len() {
        let Term::Br { cond, t, f: e } = f.blocks[b].term.clone() else { continue };
        let ValueDef::Inst(i, 0) = f.def(cond) else { continue };
        let Op::Bin(BinOp::Xor, _) = f.insts[i.idx()].op else { continue };
        let args = f.insts[i.idx()].args.clone();
        let (x, c) = match (f.def(args[0]), f.def(args[1])) {
            (_, ValueDef::Const(c)) => (args[0], c & 0xff),
            (ValueDef::Const(c), _) => (args[1], c & 0xff),
            _ => continue,
        };
        let boolean = match f.def(x) {
            ValueDef::Inst(j, 0) => matches!(f.insts[j.idx()].op, Op::Cmp(..)),
            ValueDef::Inst(j, 1) => matches!(f.insts[j.idx()].op, Op::Ovf(..)),
            _ => false,
        };
        let t2 = if boolean && c == 1 {
            Term::Br { cond: x, t: e, f: t }
        } else {
            let k = f.konst(c, 1);
            Term::BrCmp { cc: Cc::Ne, w: 1, a: x, b: k, t, f: e }
        };
        set_term(f, b, t2);
        if uses[cond.idx()] == 1 {
            let ib = f.insts[i.idx()].block.idx();
            f.blocks[ib].insts.retain(|&j| j != i);
        }
    }
}

/// A branch whose outcome is known (on a constant or undef, or a compare of constants)
/// becomes a jump, and the blocks no longer reachable from the entries go: they are emptied,
/// left without predecessors, and dropped from the layout.
fn fold_const_branches(f: &mut Func) {
    let mut changed = false;
    for b in 0..f.blocks.len() {
        let e = match f.blocks[b].term.clone() {
            Term::Br { cond, t, f: e } => match f.def(cond) {
                ValueDef::Const(c) => Some(if c & 0xff != 0 { t } else { e }),
                ValueDef::Undef => Some(e),
                _ => None,
            },
            Term::BrCmp { cc, w, a, b: bb, t, f: e } => match (f.def(a), f.def(bb)) {
                (ValueDef::Const(x), ValueDef::Const(y)) => Some(if cc.holds(w, x, y) { t } else { e }),
                _ => None,
            },
            _ => None,
        };
        if let Some(e) = e {
            set_term(f, b, Term::Jmp(e));
            changed = true;
        }
    }
    if changed {
        super::prune(f);
    }
}

/// A load or store through an `AllocaAddr` of a memory alloca becomes an access of the
/// alloca, and one through a `PtrAdd` takes its constant into its offset.
pub fn fold_addr(f: &mut Func, i: Inst) {
    let (op, args) = (f.insts[i.idx()].op.clone(), f.insts[i.idx()].args.clone());
    let (Op::Load(w, off) | Op::Store(w, off)) = op else { return };
    let ValueDef::Inst(d, 0) = f.def(args[0]) else { return };
    match f.insts[d.idx()].op {
        Op::AllocaAddr(a, k2) if f.allocas[a.idx()].kind != AllocaKind::Promoted => {
            let Some(o) = off.checked_add(k2) else { return };
            let id = &mut f.insts[i.idx()];
            if matches!(op, Op::Load(..)) {
                id.op = Op::ALoad(a, o, w);
                id.args.clear();
            } else {
                id.op = Op::AStore(a, o, w);
                id.args.remove(0);
            }
        }
        Op::PtrAdd(c) if i32::try_from(off as i64 + c).is_ok() => {
            let pa = f.insts[d.idx()].args[0];
            let id = &mut f.insts[i.idx()];
            id.args[0] = pa;
            id.op = if matches!(op, Op::Load(..)) { Op::Load(w, off + c as i32) } else { Op::Store(w, off + c as i32) };
        }
        _ => {}
    }
}
