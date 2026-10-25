//! The SSA tier's optimization passes (design/jit.md, "The SSA tier"), run on the IR as
//! construction ([`super::build`]) leaves it, before register allocation.
//!
//! - `lvn`: local value numbering: constant folding, common subexpressions, redundant loads
//!   and store-to-load forwarding, per block.
//! - `simplify`: global simplification: constant propagation over block parameters, branch
//!   folding, parameter aliasing and block merging.
//! - `osr`: the OSR-transparent loop facts the forward analyses share: OSR edges left out.
//! - `fold`: the folds instruction selection relies on.
//! - `checks`: check elimination: overflow checks and compares the dominating branches
//!   and value ranges decide.
//! - `dce`: dead code elimination, effect-free handler calls included.
//! - `thread`: jump threading through empty blocks.
//! - `layout`: cold blocks last, and values crossing calls in them split off.
//! - `promote`: promotion of memory allocas nothing takes the address of any more (after
//!   inlining), run between two rounds of the others.

pub mod checks;
pub mod dce;
pub mod fold;
pub mod layout;
pub mod lvn;
pub mod osr;
pub mod promote;
pub mod simplify;
pub mod thread;

use alloc::vec::Vec;

use super::ir::*;

/// Runs the passes on `f`, in order.
pub fn run(f: &mut Func) {
    lvn::lvn(f);
    simplify::simplify(f);
    fold::fold(f);
    checks::checks(f);
    dce::dce(f);
    thread::thread(f);
    layout::layout(f);
}

/// Drops the blocks not reachable from the entry and the OSR entries: they are emptied, left
/// without edges or predecessors, and dropped from the layout.
pub(super) fn prune(f: &mut Func) {
    let n = f.blocks.len();
    let mut seen = alloc::vec![false; n];
    let mut stack: Vec<usize> = (0..n).filter(|&b| matches!(f.blocks[b].kind, BlockKind::Entry | BlockKind::Osr(_))).collect();
    for &b in &stack {
        seen[b] = true;
    }
    while let Some(b) = stack.pop() {
        for e in f.blocks[b].term.edges() {
            if !seen[e.to.idx()] {
                seen[e.to.idx()] = true;
                stack.push(e.to.idx());
            }
        }
    }
    for b in 0..n {
        if !seen[b] {
            fold::set_term(f, b, Term::Trap);
            f.blocks[b].insts.clear();
            f.blocks[b].preds.clear();
        }
    }
    f.layout.retain(|b| seen[b.idx()]);
}
