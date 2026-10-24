//! The SSA tier's optimization passes (design/jit.md, "The SSA tier"), run on the IR as
//! construction ([`super::build`]) leaves it, before register allocation.
//!
//! - `lvn`: local value numbering: constant folding, common subexpressions, redundant loads
//!   and store-to-load forwarding, per block.
//! - `fold`: the folds instruction selection relies on.
//! - `dce`: dead code elimination.
//! - `thread`: jump threading through empty blocks.

pub mod dce;
pub mod fold;
pub mod lvn;
pub mod thread;

use super::ir::Func;

/// Runs the passes on `f`, in order.
pub fn run(f: &mut Func) {
    lvn::lvn(f);
    fold::fold(f);
    dce::dce(f);
    thread::thread(f);
}
