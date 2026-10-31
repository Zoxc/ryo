//! The per-function use analysis of MIR locals, run once before lowering: how often each
//! local is used (compare and discriminant fusion, [`super::terminator`]), and which locals
//! are dead after the statement reading them (the register cache's dead hints), and which
//! have their address taken.

use rustc_index::IndexVec;
use rustc_middle::mir::visit::{MutatingUseContext, NonMutatingUseContext, PlaceContext, Visitor};
use rustc_middle::mir::{Body, Local, Location, Place, ProjectionElem};

/// The uses of a function's locals.
pub struct LocalUses {
    /// How often each local is used (defined, read, borrowed), not counting storage markers
    /// and debug info.
    pub count: IndexVec<Local, u32>,
    /// The locals whose value is dead after the statement that reads it, with that
    /// statement's location, sorted: locals other than `_0` and the arguments that are read
    /// once, by a statement, defined once (as a whole) earlier in the same block, and never
    /// borrowed, dropped or indexed (which the lowering does through the local's address).
    /// Every execution of the read follows the definition, so nothing reads the value after
    /// it.
    pub dead_after_read: Vec<(Location, Local)>,
    /// The locals borrowed, dropped or indexed: whose bytes code may write through a pointer.
    pub escapes: IndexVec<Local, bool>,
}

#[derive(Clone, Copy, Default)]
struct Use {
    /// Every use but `NonUse`.
    total: u32,
    reads: u32,
    read: Option<Location>,
    defs: u32,
    def: Option<Location>,
    escapes: bool,
}

fn escaping(cx: PlaceContext) -> bool {
    matches!(
        cx,
        PlaceContext::MutatingUse(
            MutatingUseContext::Borrow | MutatingUseContext::RawBorrow | MutatingUseContext::Drop | MutatingUseContext::AsmOutput,
        ) | PlaceContext::NonMutatingUse(NonMutatingUseContext::SharedBorrow | NonMutatingUseContext::FakeBorrow | NonMutatingUseContext::RawBorrow,)
    )
}

struct Uses(IndexVec<Local, Use>);

impl<'tcx> Visitor<'tcx> for Uses {
    fn visit_place(&mut self, place: &Place<'tcx>, cx: PlaceContext, loc: Location) {
        // Borrowing, dropping or indexing the local itself (not through a pointer in it)
        // takes its address. The local alone only gets a projection context.
        let direct = !place.projection.iter().any(|e| matches!(e, ProjectionElem::Deref));
        let indexed = place
            .projection
            .iter()
            .take_while(|e| !matches!(e, ProjectionElem::Deref))
            .any(|e| matches!(e, ProjectionElem::Index(_) | ProjectionElem::ConstantIndex { .. } | ProjectionElem::Subslice { .. }));
        if indexed || (direct && escaping(cx)) {
            self.0[place.local].escapes = true;
        }
        self.super_place(place, cx, loc);
    }

    fn visit_local(&mut self, local: Local, cx: PlaceContext, loc: Location) {
        let u = &mut self.0[local];
        if !matches!(cx, PlaceContext::NonUse(_)) {
            u.total += 1;
        }
        match cx {
            PlaceContext::NonUse(_) => {}
            PlaceContext::MutatingUse(MutatingUseContext::Store | MutatingUseContext::Call) => {
                u.defs += 1;
                u.def = Some(loc);
            }
            cx if escaping(cx) => u.escapes = true,
            // Reads, and partial writes (which keep the other bytes).
            _ => {
                u.reads += 1;
                u.read = Some(loc);
            }
        }
    }
}

/// The uses of `body`'s locals, in one walk of the body.
pub fn analyze(body: &Body<'_>) -> LocalUses {
    let mut v = Uses(IndexVec::from_elem(Use::default(), &body.local_decls));
    v.visit_body(body);
    let mut dead_after_read: Vec<(Location, Local)> =
        v.0.iter_enumerated()
            .filter(|&(l, u)| l.as_usize() > body.arg_count && !u.escapes && u.reads == 1 && u.defs == 1)
            .filter_map(|(l, u)| {
                let (r, d) = (u.read?, u.def?);
                let in_stmt = r.statement_index < body.basic_blocks[r.block].statements.len();
                (in_stmt && d.block == r.block && d.statement_index < r.statement_index).then_some((r, l))
            })
            .collect();
    dead_after_read.sort_unstable();
    LocalUses { count: v.0.iter().map(|u| u.total).collect(), dead_after_read, escapes: v.0.iter().map(|u| u.escapes).collect() }
}
