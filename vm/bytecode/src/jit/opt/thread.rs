//! Jump threading (O6): an edge into an empty block that only jumps on goes straight to that
//! jump's target, with the block's parameters replaced by the edge's arguments. A branch whose
//! two edges then agree becomes a jump. A conditional edge is threaded only as far as it has
//! no arguments. The blocks nothing reaches any more leave the layout.
//! Blocks that start at an AOT loop head stay: their OSR entries land on them. Jumps to the
//! next block in layout and branches whose false (or true) target is next are left to the
//! emitter, which falls through.
//!
//! An empty block's jump arguments are its parameters or values that dominate it, and those
//! dominate each of its predecessors too, so the threaded edge is well formed. Its parameters
//! must have no other uses.

use crate::jit::ir::*;
use alloc::vec::Vec;

/// The forwarding target of `b`, if it's an empty block that only jumps on and whose
/// parameters (`uses` counts their uses) are used only by that jump: the blocks it dominates
/// may use them too, and threading would leave those uses without a definition.
fn forward<'a>(f: &'a Func, uses: &[u32], b: Block) -> Option<&'a Edge> {
    let bd = &f.blocks[b.idx()];
    match &bd.term {
        Term::Jmp(e)
            if bd.kind == BlockKind::Body
                && bd.head.is_none()
                && bd.insts.is_empty()
                && e.to != b
                && bd.params.iter().all(|p| uses[p.idx()] as usize == e.args.iter().filter(|&a| a == p).count()) =>
        {
            Some(e)
        }
        _ => None,
    }
}

/// Follows `e` through forwarding blocks to its final target, or only as long as it has no
/// arguments if `bare`.
fn resolve(f: &Func, uses: &[u32], mut e: Edge, bare: bool) -> Edge {
    for _ in 0..f.blocks.len() {
        let Some(n) = forward(f, uses, e.to) else { break };
        let params = &f.blocks[e.to.idx()].params;
        let args: Vec<Value> = n.args.iter().map(|&a| params.iter().position(|&p| p == a).map_or(a, |k| e.args[k])).collect();
        if bare && !args.is_empty() {
            break;
        }
        e = Edge { to: n.to, args };
    }
    e
}

/// Threads jumps through empty blocks in `f` and drops the blocks left unreachable.
pub fn thread(f: &mut Func) {
    // Threading copies arguments around but never adds a use of a forwarding block's
    // parameter, so the counts stay good enough for `forward`.
    let uses = use_counts(f);
    for b in 0..f.blocks.len() {
        let mut t = core::mem::replace(&mut f.blocks[b].term, Term::None);
        // A landing pad's normal return doesn't move edge arguments: leave it.
        // A conditional edge with arguments needs a stub for its moves, which costs the jump
        // it saves: thread those only as far as the edge has no arguments.
        let jmp = matches!(t, Term::Jmp(_));
        if !matches!(t, Term::Invoke { .. }) {
            for e in t.edges_mut() {
                *e = resolve(f, &uses, e.clone(), !jmp);
            }
        }
        t = match t {
            Term::Br { t, f, .. } | Term::BrCmp { t, f, .. } if t == f => Term::Jmp(t),
            t => t,
        };
        f.blocks[b].term = t;
    }
    // The predecessors again, and what's still reachable.
    for bd in &mut f.blocks {
        bd.preds.clear();
    }
    let n = f.blocks.len();
    let mut live = alloc::vec![false; n];
    let mut stack: Vec<usize> = (0..n).filter(|&b| matches!(f.blocks[b].kind, BlockKind::Entry | BlockKind::Osr(_))).collect();
    // Landing pad stubs are reached through their invokes; keep any without one too.
    stack.extend((0..n).filter(|&b| f.blocks[b].kind == BlockKind::Stub || f.blocks[b].head.is_some()));
    while let Some(b) = stack.pop() {
        if core::mem::replace(&mut live[b], true) {
            continue;
        }
        stack.extend(f.blocks[b].term.edges().iter().map(|e| e.to.idx()));
    }
    for b in 0..n {
        if !live[b] {
            // Unreachable: no edges, so it neither roots nor feeds anything.
            f.blocks[b].term = Term::Trap;
            f.blocks[b].insts.clear();
            f.blocks[b].params.clear();
            continue;
        }
        let tos: Vec<usize> = f.blocks[b].term.edges().iter().map(|e| e.to.idx()).collect();
        for (k, to) in tos.into_iter().enumerate() {
            f.blocks[to].preds.push((Block(b as u32), k as u16));
        }
    }
    f.layout.retain(|b| live[b.idx()]);
}
