//! OSR-transparent loop facts (design/jit.md, "OSR-transparent facts"): every cyclic head
//! has its OSR entry as an extra predecessor, whose arguments are `OsrLoad`s of the AOT
//! frame. A forward analysis may leave those edges out: what holds of a head's parameters
//! on every normal edge holds when the head is entered by OSR too, as the AOT frame holds
//! the values the same run from the entry would. The helpers here are that rule, for the
//! passes to share:
//! - [`osr_edge`]: whether an edge into a block is an OSR entry's;
//! - [`normal_preds`]: a block's other predecessors;
//! - [`invariant`]: the one value a head parameter has on every normal edge;
//! - [`same_params`]: whether two parameters agree on every normal edge;
//! - [`normal_idoms`]: dominators without the OSR edges, under which a head's normal
//!   dominators dominate it: facts established there hold at the head, through its
//!   parameters' normal arguments.
//!
//! Only facts about values both runs compute qualify: `undef` (the AOT slot holds whatever
//! bytes were there) never counts as a value here, and a head that only its OSR entry
//! reaches has no normal facts (the helpers give nothing for it).

use alloc::vec::Vec;

use crate::jit::ir::*;

/// Whether `p`'s edges are an OSR entry's.
pub fn osr_edge(f: &Func, p: Block) -> bool {
    matches!(f.blocks[p.idx()].kind, BlockKind::Osr(_))
}

/// `b`'s predecessors but its OSR entry, each with the index of its edge into `b`.
pub fn normal_preds(f: &Func, b: Block) -> impl Iterator<Item = (Block, u16)> + '_ {
    f.blocks[b.idx()].preds.iter().copied().filter(move |&(p, _)| !osr_edge(f, p))
}

/// The argument edge `k` of `p` passes for parameter `n` of its target, resolved.
pub fn edge_arg(f: &Func, p: Block, k: u16, n: usize) -> Value {
    f.resolve(f.blocks[p.idx()].term.edges().nth(k as usize).unwrap().args[n])
}

/// The value parameter `n` of `b` has on every normal edge (those passing the parameter
/// itself, around a loop, aside): with the OSR edges left out, the parameter is that value
/// also when `b` is entered by OSR. `None` if they differ, if one is `undef`, or if `b` has no
/// normal predecessor.
pub fn invariant(f: &Func, b: Block, n: usize) -> Option<Value> {
    let p = f.blocks[b.idx()].params[n];
    let mut same = None;
    for (pb, k) in normal_preds(f, b) {
        let a = edge_arg(f, pb, k, n);
        if a == p {
            continue;
        }
        match same {
            None => same = Some(a),
            Some(x) if x == a => {}
            _ => return None,
        }
    }
    same.filter(|&x| !matches!(f.def(x), ValueDef::Undef))
}

/// Whether parameters `n` and `m` of `b` (of one width) are equal on every normal edge: each
/// passes them one value (not `undef`), or each its own parameter, or each the other's. With
/// the OSR edges left out, they are equal also when `b` is entered by OSR: the AOT frame's
/// slots for them hold the same bytes there. False if `b` has no normal predecessor.
pub fn same_params(f: &Func, b: Block, n: usize, m: usize) -> bool {
    let bd = &f.blocks[b.idx()];
    let (pn, pm) = (bd.params[n], bd.params[m]);
    if f.w(pn) != f.w(pm) {
        return false;
    }
    let mut any = false;
    for (pb, k) in normal_preds(f, b) {
        any = true;
        let (an, am) = (edge_arg(f, pb, k, n), edge_arg(f, pb, k, m));
        let ok = (an == am && !matches!(f.def(an), ValueDef::Undef)) || (an, am) == (pn, pm) || (an, am) == (pm, pn);
        if !ok {
            return false;
        }
    }
    any
}

/// The immediate dominators as [`Func::idoms`] gives them, but with the OSR edges left out:
/// a head's is its dominator on the normal paths, and the OSR entries (and blocks only they
/// reach) have none.
pub fn normal_idoms(f: &Func, rpo: &[Block]) -> Vec<Option<Block>> {
    f.idoms_by(rpo, |p| !osr_edge(f, p))
}
