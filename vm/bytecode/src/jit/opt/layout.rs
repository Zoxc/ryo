//! Cold paths out of the way (design/jit.md, "The SSA tier"): a block is cold when it is a
//! landing pad stub, ends in a trap (after a call or handler that doesn't return), has
//! successors that are all cold, or has predecessors that are all cold. The layout becomes
//! the hot blocks, then the cold ones, each in their previous order, so the hot paths fall
//! through and the linear scan's intervals of hot values stop at the hot code's end.
//!
//! Then a value live into a cold block that ends the path (no successors) and live across a
//! call there is passed to it as a new parameter instead: the register allocator then keeps
//! the call crossing to that parameter, defined in cold code, which it spills, and the hot
//! value needs no callee-saved register (whose save and restore would be on the hot path).
//! Only blocks whose predecessors all end in jumps, branches or switches (whose edges move
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
    for b in f.layout.clone() {
        f.blocks[b.idx()].cold = cold[b.idx()];
        if cold[b.idx()] {
            split(f, b, &preds[b.idx()]);
        }
    }
    let (hot, cold_blocks): (Vec<Block>, Vec<Block>) = f.layout.iter().partition(|b| !cold[b.idx()]);
    f.layout = hot;
    f.layout.extend(cold_blocks);
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
    let mut later: Vec<Value> = bd.term.uses().into_iter().filter(|&v| tracked(v) && !local(v)).collect();
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
    let insts = f.blocks[b.idx()].insts.clone();
    for i in insts {
        f.insts[i.idx()].args.iter_mut().for_each(rename);
    }
    // Not its edges' arguments: `cross` comes from the terminator's uses and the insts only.
    f.blocks[b.idx()].term.uses_mut().into_iter().for_each(rename);
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
