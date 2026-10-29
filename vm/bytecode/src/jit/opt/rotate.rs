//! Loop rotation (design/jit.md, "Loop rotation"): a loop whose head only tests whether to
//! leave (a branch out of the loop or into it, and no instructions: a copied instruction's
//! result rarely gets the register of the body's parameter for it, a move per iteration) and
//! whose one latch jumps back to it gets the head's branch copied to the end of the latch, so
//! each iteration ends in that test, branching back into the body, and runs no jump of its
//! own. The head stays as it was for the entry from the preheader and for its OSR entry,
//! which still lands there: rotation only adds a path around it.
//!
//! - **Shape**: the head `h` (no landing pad, not the entry) ends in a branch to `b`, in the
//!   loop, and to `x`, out of it; `b` has no other predecessor and starts no AOT loop head.
//!   The only latch `l` ends in a jump to `h`. No call runs in the loop but on cold paths:
//!   the parameters rotation adds would cross it (in callee-saved registers or spill slots).
//! - **Exit**: if `x` has other predecessors (or is an AOT loop head), the edge `h -> x` goes
//!   through a new block that jumps on to `x`, so the exit has a block the head and the copy
//!   both enter alone.
//! - **SSA repair**: the values `h` defines (its parameters) that blocks other than
//!   `h` use become parameters of `b` and the exit block, which `h` passes the originals and the
//!   copy their copies: a use in a block `b` dominates takes `b`'s, one the exit block
//!   dominates the exit's. A use that neither dominates (a block both reach) cancels the
//!   rotation.
//!
//! It runs once, after the other passes and before register allocation: the analyses before
//! it (LICM's preheaders, the OSR facts) see the loops in their AOT shape.

use alloc::vec::Vec;

use super::hoist::Analysis;
use crate::jit::ir::*;

/// Rotates the loops of `f` that have the shape. Whether any changed.
pub fn rotate(f: &mut Func) -> bool {
    let mut done: Vec<Block> = Vec::new();
    let mut any = false;
    let mut an = Analysis::new(f);
    loop {
        let Some(k) = an.loops.iter().position(|l| !done.contains(&l.head)) else { break };
        let l = &an.loops[k];
        done.push(l.head);
        let Some(s) = shape(f, l.head, &l.latches, &l.body) else { continue };
        if rotate_loop(f, s) {
            any = true;
            an = Analysis::new(f);
        }
    }
    any
}

/// A loop to rotate: its head, latch, the head's edges into the loop and out of it.
#[derive(Clone, Copy)]
struct Shape {
    h: Block,
    l: Block,
    kin: usize,
    kout: usize,
}

fn shape(f: &Func, h: Block, latches: &[Block], body: &[bool]) -> Option<Shape> {
    let hd = &f.blocks[h.idx()];
    let &[l] = latches else { return None };
    if hd.kind != BlockKind::Body || l == h || !hd.insts.is_empty() {
        return None;
    }
    if !matches!(&f.blocks[l.idx()].term, Term::Jmp(e) if e.to == h) || hd.preds.iter().filter(|p| p.0 == l).count() != 1 {
        return None;
    }
    if !matches!(hd.term, Term::Br { .. } | Term::BrCmp { .. }) {
        return None;
    }
    // A call in the loop (but on cold paths): the values rotation adds would cross it, in
    // callee-saved registers or spill slots.
    if body.iter().enumerate().any(|(q, &inb)| {
        let qd = &f.blocks[q];
        inb && !qd.cold && qd.insts.iter().any(|i| f.insts[i.idx()].op.is_call())
    }) {
        return None;
    }
    let tos: Vec<Block> = hd.term.edges().map(|e| e.to).collect();
    let kin = tos.iter().position(|t| body[t.idx()])?;
    let kout = 1 - kin;
    let (b, x) = (tos[kin], tos[kout]);
    if b == h || body[x.idx()] {
        return None;
    }
    let bd = &f.blocks[b.idx()];
    if bd.kind != BlockKind::Body || bd.head.is_some() || bd.preds.len() != 1 {
        return None;
    }
    Some(Shape { h, l, kin, kout })
}

/// Which side of the rotated loop a use is on.
#[derive(Clone, Copy, PartialEq, Eq)]
enum Side {
    In,
    Out,
}

fn rotate_loop(f: &mut Func, s: Shape) -> bool {
    let Shape { h, l, kin, kout } = s;
    let b = f.blocks[h.idx()].term.edge(kin).to;
    let x = f.blocks[h.idx()].term.edge(kout).to;
    let saved = f.blocks[h.idx()].term.clone();
    // The exit block: `x`, or a new one on the edge.
    let xd = &f.blocks[x.idx()];
    let nx = if xd.kind == BlockKind::Body && xd.head.is_none() && xd.preds.len() == 1 {
        None
    } else {
        let n = f.block(BlockKind::Body);
        let e = f.blocks[h.idx()].term.edge_mut(kout);
        let args = core::mem::take(&mut e.args);
        e.to = n;
        f.blocks[n.idx()].term = Term::Jmp(Edge { to: x, args });
        let at = f.layout.iter().position(|&q| q == l).unwrap() + 1;
        f.layout.insert(at, n);
        Some(n)
    };
    let xb = nx.unwrap_or(x);
    f.rebuild_preds();
    let undo = |f: &mut Func| {
        if let Some(n) = nx {
            f.blocks[h.idx()].term = saved.clone();
            f.blocks[n.idx()].term = Term::Trap;
            f.layout.retain(|&q| q != n);
            f.rebuild_preds();
        }
    };

    // The values `h` defines, by index in `defs`.
    let defs: Vec<Value> = f.blocks[h.idx()].params.clone();
    let mut slot = alloc::vec![u32::MAX; f.values.len()];
    for (k, &v) in defs.iter().enumerate() {
        slot[v.idx()] = k as u32;
    }
    let def_of = |v: Value| slot.get(v.idx()).copied().filter(|&k| k != u32::MAX).map(|k| k as usize);

    let rpo = f.rpo();
    let dom = f.idoms(&rpo);
    let blocks: Vec<Block> = f.live_blocks().into_iter().filter(|&q| q != h).collect();
    let side_of = |q: Block| {
        if dom.dominates(b, q) {
            Some(Side::In)
        } else if dom.dominates(xb, q) {
            Some(Side::Out)
        } else {
            None
        }
    };
    // By value of `defs`, whether each side uses it.
    let mut need = alloc::vec![[false; 2]; defs.len()];
    for &q in &blocks {
        let bd = &f.blocks[q.idx()];
        let mut uses: Vec<Value> = bd.insts.iter().flat_map(|i| f.insts[i.idx()].args.iter().copied()).collect();
        uses.extend(bd.term.uses());
        uses.extend(bd.term.edges().flat_map(|e| e.args.iter().copied()));
        if !uses.iter().any(|&v| def_of(v).is_some()) {
            continue;
        }
        let Some(sd) = side_of(q) else {
            undo(f);
            return false;
        };
        for v in uses {
            if let Some(k) = def_of(v) {
                need[k][sd as usize] = true;
            }
        }
    }

    // The new parameters, and the uses renamed to them.
    let mut new: Vec<[Option<Value>; 2]> = alloc::vec![[None; 2]; defs.len()];
    for (k, &v) in defs.iter().enumerate() {
        for (sd, to) in [(Side::In, b), (Side::Out, xb)] {
            if need[k][sd as usize] {
                new[k][sd as usize] = Some(f.param(to, f.w(v)));
            }
        }
    }
    for &q in &blocks {
        let Some(sd) = side_of(q) else { continue };
        let rename = |v: &mut Value| {
            if let Some(k) = def_of(*v) {
                *v = new[k][sd as usize].expect("a parameter for each use");
            }
        };
        f.rename_in_block(q, rename);
    }
    // `h` passes the originals.
    let extra = |sd: Side| -> Vec<(usize, Value)> { new.iter().enumerate().filter_map(|(k, n)| n[sd as usize].map(|_| (k, defs[k]))).collect() };
    let (ein, eout) = (extra(Side::In), extra(Side::Out));
    let ht = &mut f.blocks[h.idx()].term;
    ht.edge_mut(kin).args.extend(ein.iter().map(|e| e.1));
    ht.edge_mut(kout).args.extend(eout.iter().map(|e| e.1));
    let mut t = ht.clone();

    // The copy of `h`'s branch at the end of `l`: `h`'s parameters are the jump's arguments.
    let Term::Jmp(je) = core::mem::replace(&mut f.blocks[l.idx()].term, Term::None) else { unreachable!() };
    let map: Vec<(Value, Value)> = f.blocks[h.idx()].params.iter().copied().zip(je.args).collect();
    let sub = |v: &mut Value| {
        if let Some(m) = map.iter().find(|m| m.0 == *v) {
            *v = m.1;
        }
    };
    t.operands_mut(sub);
    f.blocks[l.idx()].term = t;
    f.rebuild_preds();
    true
}
