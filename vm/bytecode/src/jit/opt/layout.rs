//! Cold paths out of the way (design/jit.md, "The SSA pipeline"): a block is cold when it is a
//! landing pad stub, ends in a trap (after a call or handler that doesn't return), has
//! successors that are all cold, or has predecessors that are all cold. The layout becomes
//! the hot blocks in chains (a block followed by a hot successor whose hot predecessors are
//! all laid out, [`chain`]), then the cold ones in their previous order, so the hot paths
//! fall through and the linear scan's intervals of hot values stop at the hot code's end.
//!
//! Pure values used only in cold blocks are computed there ([`sink`]). Then a value live into
//! a cold block that ends the path (no successors) and live across a call there is passed to
//! it as a new parameter instead: the register allocator then keeps the call crossing to that
//! parameter, defined in cold code, which it spills, and the hot value needs no callee-saved
//! register (whose save and restore would be on the hot path). Only blocks whose predecessors all end in jumps, branches or switches (whose edges move
//! arguments) and that aren't AOT loop heads (whose OSR entries set the parameters) get one.

use alloc::vec::Vec;

use crate::jit::ir::*;

/// Marks the cold blocks, splits the values crossing calls in cold blocks, and lays the cold
/// blocks out last.
pub fn layout(f: &mut Func) {
    let nb = f.blocks.len();
    let mut preds: Vec<Vec<Block>> = alloc::vec![Vec::new(); nb];
    for &b in &f.layout {
        for e in f.blocks[b.idx()].term.edges() {
            preds[e.to.idx()].push(b);
        }
    }
    let mut cold = alloc::vec![false; nb];
    let mut changed = true;
    while changed {
        changed = false;
        for &b in &f.layout {
            if cold[b.idx()] {
                continue;
            }
            let bd = &f.blocks[b.idx()];
            let edges = bd.term.edges();
            let c = match bd.kind {
                BlockKind::Entry | BlockKind::Osr(_) => false,
                BlockKind::Stub => true,
                BlockKind::Body => {
                    matches!(bd.term, Term::Trap | Term::Invoke { normal: None, .. })
                        || (!edges.is_empty() && edges.clone().all(|e| cold[e.to.idx()]))
                        // OSR entries (not in the layout) count as hot predecessors.
                        || (bd.head.is_none() && !preds[b.idx()].is_empty() && preds[b.idx()].iter().all(|p| cold[p.idx()]))
                }
            };
            if c {
                cold[b.idx()] = true;
                changed = true;
            }
        }
    }
    if !cold.iter().any(|&c| c) {
        return;
    }
    for &b in &f.layout {
        f.blocks[b.idx()].cold = cold[b.idx()];
    }
    sink(f, &cold);
    for b in f.layout.clone() {
        if cold[b.idx()] {
            split(f, b, &preds[b.idx()]);
        }
    }
    let (hot, cold_blocks): (Vec<Block>, Vec<Block>) = f.layout.iter().partition(|b| !cold[b.idx()]);
    f.layout = chain(f, &hot, &preds, &cold);
    f.layout.extend(cold_blocks);
}

/// The hot blocks `hot` in chains: each block is followed by a successor not yet laid out
/// whose (hot) predecessors all are, the first of them in `hot`'s order, so a branch's hot
/// side falls through rather than needing a `jmp`; a block no chain reaches starts one, in
/// `hot`'s order. A loop head waits for its latch, so it is still laid out by the order and
/// its body after it.
fn chain(f: &Func, hot: &[Block], preds: &[Vec<Block>], cold: &[bool]) -> Vec<Block> {
    let mut at = alloc::vec![usize::MAX; f.blocks.len()];
    for (k, &b) in hot.iter().enumerate() {
        at[b.idx()] = k;
    }
    let mut placed = alloc::vec![false; f.blocks.len()];
    let mut out = Vec::with_capacity(hot.len());
    for &b in hot {
        let mut c = b;
        while !placed[c.idx()] {
            placed[c.idx()] = true;
            out.push(c);
            let succ = match f.blocks[c.idx()].term {
                Term::Switch { .. } => None,
                ref t => t
                    .edges()
                    .map(|e| e.to)
                    .filter(|s| at[s.idx()] != usize::MAX && !placed[s.idx()])
                    .filter(|s| preds[s.idx()].iter().all(|p| placed[p.idx()] || cold[p.idx()]))
                    .min_by_key(|s| at[s.idx()]),
            };
            match succ {
                Some(s) => c = s,
                None => break,
            }
        }
    }
    out
}

/// Sinks the pure values all of whose uses are in cold blocks (the panic locations and
/// arguments of failed checks) into those blocks, a copy before the first use in each, so
/// the hot path doesn't compute them and they hold no register across it. Their operands
/// follow when that leaves them used only there. An instruction of a cold block or an
/// edge out of one is a use there; anything else (an OSR entry's too) keeps the value.
fn sink(f: &mut Func, cold: &[bool]) {
    // Each value's using blocks, once per use.
    let mut at: Vec<Vec<Block>> = alloc::vec![Vec::new(); f.values.len()];
    for (b, bd) in f.blocks.iter().enumerate() {
        let b = Block(b as u32);
        for &i in &bd.insts {
            for &a in &f.insts[i.idx()].args {
                at[a.idx()].push(b);
            }
        }
        for u in bd.term.uses() {
            at[u.idx()].push(b);
        }
        for e in bd.term.edges() {
            for &a in &e.args {
                at[a.idx()].push(b);
            }
        }
    }
    let cold_at = |b: Block| cold.get(b.idx()).copied().unwrap_or(false);
    let mut changed = true;
    while changed {
        changed = false;
        for b in 0..f.blocks.len() {
            if cold[b] {
                continue;
            }
            let mut k = f.blocks[b].insts.len();
            while k > 0 {
                k -= 1;
                let i = f.blocks[b].insts[k];
                let id = &f.insts[i.idx()];
                if !id.op.pure() || matches!(id.op, Op::Ovf(..) | Op::OsrLoad(..)) || id.nres != 1 {
                    continue;
                }
                let v = f.result(i);
                if at[v.idx()].is_empty() || !at[v.idx()].iter().all(|&u| cold_at(u)) {
                    continue;
                }
                let mut to: Vec<Block> = at[v.idx()].clone();
                to.sort_unstable_by_key(|b| b.0);
                to.dedup();
                let (op, args, w) = (id.op.clone(), id.args.clone(), f.w(v));
                for &u in &to {
                    let c = f.new_inst(u, op.clone(), args.clone(), &[w]);
                    let cv = f.result(c);
                    let ub = &mut f.blocks[u.idx()];
                    let pos = match ub.insts.iter().position(|&j| f.insts[j.idx()].args.contains(&v)) {
                        Some(p) => p,
                        // The fused overflow op and an invoke's call stay last.
                        None if matches!(ub.term, Term::BrOvf { .. } | Term::Invoke { .. }) => ub.insts.len() - 1,
                        None => ub.insts.len(),
                    };
                    ub.insts.insert(pos, c);
                    for &j in &ub.insts {
                        for a in f.insts[j.idx()].args.iter_mut().filter(|a| **a == v) {
                            *a = cv;
                        }
                    }
                    let ub = &mut f.blocks[u.idx()];
                    for a in ub.term.uses_mut().filter(|a| **a == v) {
                        *a = cv;
                    }
                    for e in ub.term.edges_mut() {
                        for a in e.args.iter_mut().filter(|a| **a == v) {
                            *a = cv;
                        }
                    }
                    for &a in &args {
                        at[a.idx()].push(u);
                    }
                    at.resize(f.values.len(), Vec::new());
                }
                // The operands' uses here go.
                for &a in &args {
                    let p = at[a.idx()].iter().position(|&x| x.idx() == b).unwrap();
                    at[a.idx()].swap_remove(p);
                }
                at[v.idx()].clear();
                f.blocks[b].insts.remove(k);
                changed = true;
            }
        }
    }
}

/// Passes the values live across a call in `b` (a cold block) but defined elsewhere to `b`
/// as new parameters, if `b` ends the path and its predecessors `preds` can move them.
fn split(f: &mut Func, b: Block, preds: &[Block]) {
    let bd = &f.blocks[b.idx()];
    if bd.kind != BlockKind::Body
        || bd.head.is_some()
        || !bd.term.edges().is_empty()
        || preds.is_empty()
        || !preds
            .iter()
            .all(|p| matches!(f.blocks[p.idx()].term, Term::Jmp(_) | Term::Br { .. } | Term::BrCmp { .. } | Term::BrOvf { .. } | Term::Switch { .. }))
    {
        return;
    }
    let tracked = |v: Value| matches!(f.values[v.idx()].def, ValueDef::Inst(..) | ValueDef::Param(..));
    let local = |v: Value| match f.values[v.idx()].def {
        ValueDef::Inst(i, _) => f.insts[i.idx()].block == b,
        ValueDef::Param(p, _) => p == b,
        _ => true,
    };
    // Backward: the values used later, and those of them live across a call.
    let mut later: Vec<Value> = bd.term.uses().filter(|&v| tracked(v) && !local(v)).collect();
    let mut cross: Vec<Value> = Vec::new();
    for &i in bd.insts.iter().rev() {
        let id = &f.insts[i.idx()];
        if id.op.is_call() {
            for &v in &later {
                if !cross.contains(&v) {
                    cross.push(v);
                }
            }
        }
        for &a in &id.args {
            if tracked(a) && !local(a) && !later.contains(&a) {
                later.push(a);
            }
        }
    }
    if cross.is_empty() {
        return;
    }
    let ps: Vec<Value> = cross.iter().map(|&v| f.param(b, f.w(v))).collect();
    let rename = |x: &mut Value| {
        if let Some(k) = cross.iter().position(|v| v == x) {
            *x = ps[k];
        }
    };
    for &i in &f.blocks[b.idx()].insts {
        f.insts[i.idx()].args.iter_mut().for_each(rename);
    }
    // Not its edges' arguments: `cross` comes from the terminator's uses and the insts only.
    f.blocks[b.idx()].term.uses_mut().for_each(rename);
    let mut done: Vec<Block> = Vec::new();
    for &p in preds {
        if done.contains(&p) {
            continue;
        }
        done.push(p);
        for e in f.blocks[p.idx()].term.edges_mut() {
            if e.to == b {
                e.args.extend(&cross);
            }
        }
    }
}
