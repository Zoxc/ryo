//! The folds instruction selection relies on (design/jit.md, "The SSA tier"), after value
//! numbering ([`super::lvn`]): compare- and overflow-branches, branches on negated booleans
//! and on constants, and frame and constant-offset addresses.

use crate::jit::ir::*;

/// The folds instruction selection relies on, done on the IR (design/jit.md, "The SSA
/// tier"): a compare used only by the branch right after it becomes a compare-branch;
/// loads and stores through a frame address become accesses of the alloca, and through a
/// pointer plus a constant take the constant into their offset.
pub fn fold(f: &mut Func) {
    fold_not(f);
    let uses = use_counts(f);
    for b in 0..f.blocks.len() {
        // Compare, then branch on it.
        if let Term::Br { cond, .. } = f.blocks[b].term
            && uses[cond.idx()] == 1
            && let ValueDef::Inst(i, 0) = f.def(cond)
            && let Op::Cmp(cc, w) = f.insts[i.idx()].op
            && f.blocks[b].insts.last() == Some(&i)
            && let Term::Br { t, f: e, .. } = core::mem::replace(&mut f.blocks[b].term, Term::None)
        {
            f.blocks[b].insts.pop();
            let args = &f.insts[i.idx()].args;
            f.blocks[b].term = Term::BrCmp { cc, w, a: args[0], b: args[1], t, f: e };
        }
        // An overflow op, then a branch on its flag.
        if let Term::Br { cond, .. } = f.blocks[b].term
            && uses[cond.idx()] == 1
            && let ValueDef::Inst(i, 1) = f.def(cond)
            && matches!(f.insts[i.idx()].op, Op::Ovf(..))
            && f.blocks[b].insts.last() == Some(&i)
            && let Term::Br { t, f: e, .. } = core::mem::replace(&mut f.blocks[b].term, Term::None)
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

/// A branch on `x ^ c` (the low byte of it) is a branch on `x != c`; when `x` is a boolean
/// (a compare or an overflow flag) and `c` is 1, it is a branch on `x` with the targets
/// swapped, which the compare-branch fold then takes. The `xor` goes when the branch was its
/// only use.
fn fold_not(f: &mut Func) {
    let uses = use_counts(f);
    for b in 0..f.blocks.len() {
        let Term::Br { cond, .. } = f.blocks[b].term else { continue };
        let ValueDef::Inst(i, 0) = f.def(cond) else { continue };
        let Op::Bin(BinOp::Xor, _) = f.insts[i.idx()].op else { continue };
        let args = [f.insts[i.idx()].args[0], f.insts[i.idx()].args[1]];
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
        let Term::Br { t, f: e, .. } = f.blocks[b].term.clone() else { unreachable!() };
        let t2 = if boolean && c == 1 {
            Term::Br { cond: x, t: e, f: t }
        } else {
            let k = f.konst(c, 1);
            Term::BrCmp { cc: Cc::Ne, w: 1, a: x, b: k, t, f: e }
        };
        f.set_term(Block(b as u32), t2);
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
        let k = match f.blocks[b].term {
            Term::Br { cond, .. } if matches!(f.def(cond), ValueDef::Undef) => Some(1),
            ref t => t.taken_on(|v, w| f.const_at(v, w)),
        };
        if let Some(k) = k {
            f.fold_branch(Block(b as u32), k);
            changed = true;
        }
    }
    if changed {
        f.prune(false);
    }
}

/// A load or store through an `AllocaAddr` of a memory alloca becomes an access of the
/// alloca, and one through a `PtrAdd` takes its constant into its offset.
pub fn fold_addr(f: &mut Func, i: Inst) {
    let (load, w, off) = match f.insts[i.idx()].op {
        Op::Load(w, off) => (true, w, off),
        Op::Store(w, off) => (false, w, off),
        _ => return,
    };
    let ValueDef::Inst(d, 0) = f.def(f.insts[i.idx()].args[0]) else { return };
    match f.insts[d.idx()].op {
        Op::AllocaAddr(a, k2) if f.allocas[a.idx()].kind != AllocaKind::Promoted => {
            let Some(o) = off.checked_add(k2) else { return };
            let id = &mut f.insts[i.idx()];
            if load {
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
            id.op = if load { Op::Load(w, off + c as i32) } else { Op::Store(w, off + c as i32) };
        }
        _ => {}
    }
}
