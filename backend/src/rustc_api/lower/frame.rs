//! Frame layout: argument block, local slots and temporaries (design/lowering.md#frame-slots).
//!
//! ```text
//! fp + 0      header (caller fp, return pc)
//! fp + H      argument block (the ABI arguments, `sig::arg_block` layout)
//! …           other locals, then the temporaries of the statement being lowered
//! fp + frame_size
//! ```
//!
//! Locals with storage markers share slots when their storage ranges never overlap
//! ([`Sharing`]). Arguments, `_0` and locals without `StorageLive` get slots of their own.

use rustc_index::IndexVec;
use rustc_index::bit_set::{BitMatrix, DenseBitSet};
use rustc_middle::mir::{BasicBlock, Body, Local, StatementKind};
use rustc_middle::ty::layout::TyAndLayout;
use ryo_bytecode::abi::{self, HEADER_SIZE};

use super::sig::AbiSig;
use super::{FnCx, NeedsNative, native};

/// A local's slot.
#[derive(Clone, Copy)]
pub struct LocalSlot<'tcx> {
    pub off: u32,
    pub layout: TyAndLayout<'tcx>,
}

pub struct Frame<'tcx> {
    pub locals: IndexVec<Local, LocalSlot<'tcx>>,
    /// End of the local slots: temporaries start here.
    locals_end: u32,
    /// Next free temporary byte.
    temp_top: u32,
    /// Highest `temp_top` reached: the end of the frame.
    high: u32,
    /// The spread `rust-call` argument (design/lowering.md#frame-slots), with the index of
    /// its first field in the argument block: the prologue assembles it.
    pub spread: Option<(Local, usize)>,
}

impl<'tcx> Frame<'tcx> {
    /// Lays out the locals of `body`, whose arguments come in the argument block of `sig`.
    pub fn new(
        body: &Body<'tcx>,
        sig: &AbiSig<'tcx>,
        layout_of_local: impl Fn(Local) -> Result<TyAndLayout<'tcx>, NeedsNative>,
    ) -> Result<Self, NeedsNative> {
        let spread = body.spread_arg;
        let n_fixed = match spread {
            Some(s) => {
                if s.as_usize() != body.arg_count {
                    return native("spread argument isn't the last argument");
                }
                body.arg_count - 1
            }
            None => body.arg_count,
        };
        // A `#[track_caller]` function's location is an extra, last ABI input that no MIR
        // local stands for (`FnCx::caller_location`).
        let n_inputs = sig.inputs.len() - usize::from(sig.caller_location);
        let mut end = HEADER_SIZE + sig.block_size;
        let mut locals = IndexVec::with_capacity(body.local_decls.len());
        let sharing = Sharing::new(body);
        // Locals that share slots, placed after the others.
        let mut shared = Vec::new();
        for local in body.local_decls.indices() {
            let layout = layout_of_local(local)?;
            if layout.is_unsized() {
                return native("unsized local");
            }
            let align = layout.align.abi.bytes() as u32;
            if align > abi::FRAME_ALIGN {
                return native("local aligned above 16");
            }
            let size = u32::try_from(layout.size.bytes()).map_err(|_| NeedsNative("local larger than 4 GiB".into()))?;
            let i = local.as_usize();
            let off = if (1..=n_fixed).contains(&i) {
                let f = sig.fields.get(i - 1).ok_or_else(|| NeedsNative("more arguments than the ABI".into()))?;
                if f.size != size {
                    return native("argument local doesn't match the ABI");
                }
                HEADER_SIZE + f.offset
            } else if size == 0 {
                end
            } else if sharing.as_ref().is_some_and(|s| s.shareable.contains(local)) {
                shared.push(local);
                0
            } else {
                let off = end.next_multiple_of(align.max(1));
                end = off.checked_add(size).ok_or_else(|| NeedsNative("frame too large".into()))?;
                off
            };
            locals.push(LocalSlot { off, layout });
        }
        if let Some(sharing) = &sharing {
            end = sharing.place(&mut locals, &shared, end)?;
        }
        let spread = spread.map(|s| (s, n_fixed));
        match spread {
            Some((s, first)) => {
                let fields = locals[s].layout.fields.count();
                if first + fields != n_inputs {
                    return native("spread argument doesn't match the ABI");
                }
            }
            None if n_fixed != n_inputs => return native("argument count doesn't match the ABI"),
            None => {}
        }
        if end > (1 << 30) {
            return native("frame too large");
        }
        Ok(Frame { locals, locals_end: end, temp_top: end, high: end, spread })
    }

    /// A temporary slot, live until [`Frame::reset_temps`].
    pub fn temp(&mut self, size: u64, align: u64) -> u32 {
        let off = self.temp_top.next_multiple_of(align.clamp(1, 16) as u32);
        self.temp_top = off + size as u32;
        self.high = self.high.max(self.temp_top);
        off
    }

    /// Frees every temporary (between statements).
    pub fn reset_temps(&mut self) {
        self.temp_top = self.locals_end;
    }

    pub fn frame_size(&self) -> u32 {
        abi::frame_size(self.high)
    }
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// A temporary of `layout`'s size and alignment.
    pub fn temp_for(&mut self, layout: TyAndLayout<'tcx>) -> u32 {
        self.frame.temp(layout.size.bytes(), layout.align.abi.bytes())
    }

    /// An 8-byte temporary (pointers, `usize`).
    pub fn temp8(&mut self) -> u32 {
        self.frame.temp(8, 8)
    }

    /// The prologue: assembles the spread `rust-call` argument from the argument block.
    pub fn prologue(&mut self, sig: &AbiSig<'tcx>) {
        let Some((local, first)) = self.frame.spread else { return };
        let slot = self.frame.locals[local];
        for i in 0..slot.layout.fields.count() {
            let f = sig.fields[first + i];
            let dst = slot.off + slot.layout.fields.offset(i).bytes() as u32;
            self.mov(dst, HEADER_SIZE + f.offset, f.size);
        }
    }
}

/// Slot sharing (design/lowering.md#frame-slots): two locals with storage markers may share
/// bytes if neither is storage-live where the other's storage starts. Storage liveness is
/// "maybe live" over every CFG edge, unwind edges included, so this over-approximates.
struct Sharing {
    /// Locals other than `_0` and the arguments that have a `StorageLive`.
    shareable: DenseBitSet<Local>,
    /// `conflicts[b]` holds `a` if `a` may be live where `b`'s storage starts.
    conflicts: BitMatrix<Local, Local>,
}

/// Above this many locals, every local keeps its own slot (the conflict matrix is quadratic).
const MAX_SHARING_LOCALS: usize = 4096;

impl Sharing {
    fn new(body: &Body<'_>) -> Option<Sharing> {
        let n = body.local_decls.len();
        if n > MAX_SHARING_LOCALS {
            return None;
        }
        let mut shareable = DenseBitSet::new_empty(n);
        for data in body.basic_blocks.iter() {
            for stmt in &data.statements {
                if let StatementKind::StorageLive(l) = stmt.kind
                    && l.as_usize() > body.arg_count
                {
                    shareable.insert(l);
                }
            }
        }
        if shareable.is_empty() {
            return None;
        }
        // Maybe-storage-live at each block's entry. Locals without `StorageLive` are always
        // live, but they have slots of their own, so only shareable locals are tracked.
        let blocks = body.basic_blocks.len();
        let mut entry: IndexVec<BasicBlock, DenseBitSet<Local>> =
            IndexVec::from_elem_n(DenseBitSet::new_empty(n), blocks);
        let mut work: Vec<BasicBlock> = body.basic_blocks.indices().rev().collect();
        let mut queued: DenseBitSet<BasicBlock> = DenseBitSet::new_filled(blocks);
        while let Some(bb) = work.pop() {
            queued.remove(bb);
            let data = &body.basic_blocks[bb];
            let mut cur = entry[bb].clone();
            storage_effects(&data.statements, &mut cur, |_, _| {});
            cur.intersect(&shareable);
            for succ in data.terminator().successors() {
                if entry[succ].union(&cur) && queued.insert(succ) {
                    work.push(succ);
                }
            }
        }
        let mut conflicts = BitMatrix::new(n, n);
        for (bb, data) in body.basic_blocks.iter_enumerated() {
            let mut cur = entry[bb].clone();
            storage_effects(&data.statements, &mut cur, |l, live| {
                if shareable.contains(l) {
                    conflicts.union_row_with(live, l);
                }
            });
        }
        Some(Sharing { shareable, conflicts })
    }

    fn conflict(&self, a: Local, b: Local) -> bool {
        self.conflicts.contains(a, b) || self.conflicts.contains(b, a)
    }

    /// Places the `shared` locals from `start` on, each at the lowest offset that doesn't
    /// overlap a conflicting local placed before it. Returns the end of the locals.
    fn place(&self, locals: &mut IndexVec<Local, LocalSlot<'_>>, shared: &[Local], start: u32) -> Result<u32, NeedsNative> {
        let mut end = start;
        let mut placed: Vec<(u32, u32, Local)> = Vec::with_capacity(shared.len());
        let mut busy: Vec<(u32, u32)> = Vec::new();
        for &l in shared {
            let size = locals[l].layout.size.bytes() as u32;
            let align = (locals[l].layout.align.abi.bytes() as u32).max(1);
            busy.clear();
            busy.extend(placed.iter().filter(|p| self.conflict(l, p.2)).map(|p| (p.0, p.1)));
            busy.sort_unstable();
            let mut off = start.next_multiple_of(align);
            for &(b, e) in &busy {
                if off.checked_add(size).is_some_and(|x| x <= b) {
                    break;
                }
                if e > off {
                    off = e.next_multiple_of(align);
                }
            }
            let e = off.checked_add(size).ok_or_else(|| NeedsNative("frame too large".into()))?;
            locals[l].off = off;
            end = end.max(e);
            placed.push((off, e, l));
        }
        Ok(end)
    }
}

/// Applies the `StorageLive`/`StorageDead` statements to `live`, calling `on_live(l, live)`
/// before each `StorageLive(l)`.
fn storage_effects(
    stmts: &[rustc_middle::mir::Statement<'_>],
    live: &mut DenseBitSet<Local>,
    mut on_live: impl FnMut(Local, &DenseBitSet<Local>),
) {
    for stmt in stmts {
        match stmt.kind {
            StatementKind::StorageLive(l) => {
                on_live(l, live);
                live.insert(l);
            }
            StatementKind::StorageDead(l) => {
                live.remove(l);
            }
            _ => {}
        }
    }
}
