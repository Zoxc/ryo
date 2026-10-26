//! Loop-invariant splats: a `vsplat` (five instructions) of a byte defined outside the loops
//! around it moves to right after that byte's definition, so the loop reuses the vector
//! (hashbrown's probe loop splats its tag once). The loops are [`super::super::regalloc`]'s
//! layout approximation; a splat is pure, so computing it early is always correct.
//!
//! A byte that is a loop head's parameter passed on unchanged around the loop (it stays one
//! where the head has an OSR entry, [`super::osr`]) gets a vector parameter beside it: each
//! edge that brings the byte in brings its splat (computed at the edge's source, the OSR
//! entry's from its load), each that passes the byte on passes the vector on.

use alloc::vec::Vec;

use crate::jit::ir::*;

pub fn hoist(f: &mut Func) {
    through_heads(f);
    let splats: Vec<(Block, Inst)> = f
        .layout
        .iter()
        .flat_map(|&b| f.blocks[b.idx()].insts.iter().map(move |&i| (b, i)))
        .filter(|&(_, i)| f.insts[i.idx()].op == Op::V(VOp::Splat))
        .collect();
    if splats.is_empty() {
        return;
    }
    let depth = crate::jit::regalloc::loop_depth(f);
    let in_layout = |f: &Func, b: Block| f.layout.contains(&b);
    for (b, i) in splats {
        let (d, at) = match f.def(f.insts[i.idx()].args[0]) {
            ValueDef::Inst(j, _) => {
                let d = f.insts[j.idx()].block;
                (d, f.blocks[d.idx()].insts.iter().position(|&k| k == j).map_or(usize::MAX, |p| p + 1))
            }
            ValueDef::Param(d, _) => (d, 0),
            _ => continue,
        };
        if at == usize::MAX || !in_layout(f, d) || depth[d.idx()] >= depth[b.idx()] {
            continue;
        }
        // Not between a block's last instruction and the terminator fused with it.
        let bd = &f.blocks[d.idx()];
        if at == bd.insts.len() && matches!(bd.term, Term::BrOvf { .. } | Term::Invoke { .. }) {
            continue;
        }
        f.blocks[b.idx()].insts.retain(|&k| k != i);
        f.blocks[d.idx()].insts.insert(at, i);
        f.insts[i.idx()].block = d;
    }
}

/// The splats of head parameters passed on unchanged around their loops, as parameters.
fn through_heads(f: &mut Func) {
    let mut changed = false;
    for bi in 0..f.layout.len() {
        let b = f.layout[bi];
        for i in f.blocks[b.idx()].insts.clone() {
            if f.insts[i.idx()].op != Op::V(VOp::Splat) {
                continue;
            }
            let p = f.insts[i.idx()].args[0];
            let ValueDef::Param(h, n) = f.def(p) else { continue };
            let preds = f.blocks[h.idx()].preds.clone();
            let args: Vec<Value> = preds.iter().map(|&(q, k)| f.blocks[q.idx()].term.edges().nth(k as usize).unwrap().args[n as usize]).collect();
            // Around the loop at least once, and a splat placeable at every other edge's source.
            let ok = args.contains(&p)
                && preds.iter().zip(&args).all(|(&(q, _), &a)| {
                    let bd = &f.blocks[q.idx()];
                    a == p || (q != h && !matches!(bd.term, Term::BrOvf { .. } | Term::Invoke { .. }) && bd.term.edges().len() == 1)
                });
            if !ok {
                continue;
            }
            let x = f.param(h, 16);
            for (&(q, k), &a) in preds.iter().zip(&args) {
                let v = if a == p {
                    x
                } else {
                    let s = f.inst(q, Op::V(VOp::Splat), alloc::vec![a], &[16]);
                    f.result(s)
                };
                let mut t = core::mem::replace(&mut f.blocks[q.idx()].term, Term::None);
                t.edges_mut().nth(k as usize).unwrap().args.push(v);
                f.blocks[q.idx()].term = t;
            }
            f.blocks[b.idx()].insts.retain(|&k| k != i);
            let r = f.result(i);
            f.values[r.idx()].def = ValueDef::Alias(x);
            changed = true;
        }
    }
    if changed {
        f.resolve_aliases();
    }
}
