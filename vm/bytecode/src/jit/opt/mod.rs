//! The SSA tier's optimization passes (design/jit.md, "The SSA tier"), run on the IR as
//! construction ([`super::build`]) leaves it, before register allocation.
//!
//! - `lvn`: value numbering: constant folding, common subexpressions over the dominator
//!   tree, redundant loads and store-to-load forwarding over extended basic blocks.
//! - `mem`: the memory-effect model: which bytes an instruction may write.
//! - `dse`: dead stores to allocas no pointer reaches, per block.
//! - `simplify`: global simplification: constant propagation over block parameters, branch
//!   folding, parameter aliasing and block merging.
//! - `copies`: `memcpy`, `memmove` and `memset` calls of small constant lengths as loads
//!   and stores (value numbered again).
//! - `osr`: the OSR-transparent loop facts the forward analyses share: OSR edges left out.
//! - `fold`: the folds instruction selection relies on.
//! - `checks`: check elimination: overflow checks and compares the dominating branches
//!   and value ranges decide.
//! - `hoist`: loop-invariant code motion, to preheaders and the OSR entries' landings.
//! - `dce`: dead code elimination, effect-free handler calls included.
//! - `thread`: jump threading through empty blocks.
//! - `layout`: cold blocks last, and values crossing calls in them split off.
//! - `rotate`: loop rotation, run once after the others ([`super::compile`]).
//! - `promote`: promotion of memory allocas nothing takes the address of any more (after
//!   inlining), run between two rounds of the others.

pub mod checks;
pub mod copies;
pub mod dce;
pub mod dse;
pub mod fold;
pub mod hoist;
pub mod layout;
pub mod lvn;
pub mod mem;
pub mod osr;
pub mod promote;
pub mod rotate;
pub mod simplify;
pub mod thread;

use alloc::vec::Vec;

use super::ir::*;

/// A step of [`DomWalk`].
pub enum Dom {
    /// Entering a block, after its dominator's entry.
    Enter(Block),
    /// Leaving the block entered last that wasn't left yet.
    Leave,
}

/// A preorder walk over a dominator tree, children in reverse postorder, with the way back
/// up marked so scoped state can be undone.
pub struct DomWalk {
    kids: Vec<Vec<Block>>,
    stack: Vec<Option<Block>>,
}

impl DomWalk {
    /// The walk over the tree of `idom`, given the reverse postorder `rpo` it was computed
    /// over; blocks with no dominator are roots.
    pub fn new(idom: &[Option<Block>], rpo: &[Block]) -> DomWalk {
        let mut kids: Vec<Vec<Block>> = alloc::vec![Vec::new(); idom.len()];
        let mut roots = Vec::new();
        for &b in rpo {
            match idom[b.idx()] {
                Some(d) => kids[d.idx()].push(b),
                None => roots.push(b),
            }
        }
        DomWalk { kids, stack: roots.into_iter().rev().map(Some).collect() }
    }
}

impl Iterator for DomWalk {
    type Item = Dom;

    fn next(&mut self) -> Option<Dom> {
        let Some(b) = self.stack.pop()? else { return Some(Dom::Leave) };
        self.stack.push(None);
        self.stack.extend(self.kids[b.idx()].iter().rev().map(|&k| Some(k)));
        Some(Dom::Enter(b))
    }
}
pub use crate::image::PoolRead;

/// A constant address the IR names: an offset in the constant pool of the IR's image (its
/// `RefAddr(Const)` plus an offset), or an absolute address (another image's, after
/// [`super::inline::rebase`]).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ConstAt {
    Root(u32),
    Abs(u64),
}

/// The memory fixed before VM code runs that loads may be folded from (design/provenance.md,
/// rule 5): the constant pools of the registered images.
pub trait ConstMem {
    /// `w` (1, 2, 4, 8) bytes at `a`, if `[a, a + w)` lies in a registered image's constant
    /// pool and reads no relocated field partly: plain bits, or a relocated field read whole
    /// ([`crate::image::Image::read_pool`]). Only a `Root` read gives `Const` or `Data`; an
    /// absolute one gives the field's bits (every image part is an exposed allocation).
    fn read(&self, a: ConstAt, w: u8) -> Option<PoolRead>;
    /// The pool offsets of the relocated fields of the IR's image that overlap `[k, k +
    /// len)`, in order, passed to `f` (no allocation per query).
    fn relocs(&self, k: u32, len: u32, f: &mut dyn FnMut(u32));
}

/// The one value the operands `ops` of parameter `p` pass but `p` itself (the trivial-phi
/// rule, Braun et al.): `Ok(None)` if they all pass `p`, `Err(())` at a second value.
pub(crate) fn unique_operand(p: Value, ops: impl IntoIterator<Item = Value>) -> Result<Option<Value>, ()> {
    let mut same = None;
    for o in ops {
        if o == p || Some(o) == same {
            continue;
        }
        if same.is_some() {
            return Err(());
        }
        same = Some(o);
    }
    Ok(same)
}

/// Runs the passes on `f`, in order, folding loads from `mem`.
pub fn run(f: &mut Func, mem: Option<&dyn ConstMem>) {
    lvn::lvn(f, mem);
    dse::dse(f);
    simplify::simplify(f);
    // `simplify` may have aliased the parameter a load's base was to a constant address.
    if copies::copies(f) || mem.is_some_and(|_| lvn::const_loads(f)) {
        lvn::lvn(f, mem);
    }
    fold::fold(f);
    checks::checks(f);
    hoist::hoist(f);
    dce::dce(f);
    thread::thread(f);
    layout::layout(f);
}
