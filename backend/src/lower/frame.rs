//! Frame layout: argument block, local slots and temporaries (design/lowering.md#frame-slots).
//!
//! Frames grow downward ([`ryo_bytecode::abi`]):
//!
//! ```text
//! fp + H      argument block (the ABI arguments, `sig::arg_block` layout), in the caller's frame
//! fp + 0      header (caller fp, return address)
//! fp - …      other locals, then the temporaries of the statement being lowered
//! fp - F      the outgoing argument block of the calls this function makes
//! ```
//!
//! Locals with storage markers share slots when their storage ranges never overlap
//! ([`Sharing`]). Arguments, `_0` and locals without `StorageLive` get slots of their own.
//!
//! Slots are handed out *biased*, as `BIAS + off` for the signed frame offset `off`, so the
//! lowering's arithmetic on them (`slot + field offset`) never wraps. Slots in the outgoing
//! block ([`FnCx::out`]) are their offset in the block, below [`OUT_END`], since `F` is only
//! known once the whole function is lowered. [`FnCx::finish`] has the assembler turn both
//! kinds into signed offsets ([`frame_offset`]) as it writes the machine code.

use rustc_index::IndexVec;
use rustc_index::bit_set::{BitMatrix, DenseBitSet};
use rustc_middle::mir::visit::{MutatingUseContext, NonMutatingUseContext, PlaceContext, Visitor};
use rustc_middle::mir::{BasicBlock, Body, Local, Location, Place, ProjectionElem, StatementKind, TerminatorKind, UnwindAction};
use rustc_middle::ty::layout::TyAndLayout;
use ryo_bytecode::abi::{self, HEADER_SIZE};
use ryo_bytecode::full::Opcode;

use super::sig::{AbiSig, ArgLoc};
use super::{FnCx, NeedsNative, native};
use ryo_bytecode::asm::ArgReg;

/// The bias of a slot handed out by the lowering: the slot of frame offset `off` is
/// `BIAS + off`.
pub const BIAS: u32 = 1 << 31;

/// Outgoing-block slots are below this, and frames and argument blocks must be smaller.
pub const OUT_END: u32 = 1 << 30;

/// The biased slot of the frame offset `off`.
pub const fn slot(off: i32) -> u32 {
    BIAS.wrapping_add(off as u32)
}

/// The signed frame offset of a slot handed out by the lowering, in a frame of size
/// `frame_size`.
pub fn frame_offset(slot: u32, frame_size: u32) -> i32 {
    if slot < OUT_END { slot as i32 - frame_size as i32 } else { slot.wrapping_sub(BIAS) as i32 }
}

/// A local's slot.
#[derive(Clone, Copy)]
pub struct LocalSlot<'tcx> {
    pub off: u32,
    pub layout: TyAndLayout<'tcx>,
}

pub struct Frame<'tcx> {
    pub locals: IndexVec<Local, LocalSlot<'tcx>>,
    /// Bytes below `fp` taken by the locals: temporaries start below.
    locals_end: u32,
    /// Bytes below `fp` taken by the locals and the live temporaries.
    temp_top: u32,
    /// Largest `temp_top` reached: the frame size without the outgoing block.
    high: u32,
    /// The live temporaries: slot, size and alignment.
    temps: Vec<(u32, u32, u32)>,
    /// Where landing pads store the exception object (`lpad x`) for the cleanup code's
    /// `resume x`: an 8-byte slot of its own, in functions with cleanup or terminate actions.
    pub exception: Option<u32>,
    /// An sret function's slot for the return value's address, which it gets in the first
    /// argument register (`arg`, [`FnCx::prologue`]).
    pub sret: Option<u32>,
    /// Each ABI input's slot ([`FnCx::prologue`]).
    pub arg_homes: Vec<u32>,
    /// Each `Indirect` input's slot for the pointer it comes as.
    pub arg_ptrs: Vec<Option<u32>>,
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
        if sig.block_size >= OUT_END {
            return native("argument block too large");
        }
        // Bytes below `fp` taken so far.
        let mut end = 0;
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
                // A slot of its own, which the prologue fills from the argument's registers
                // and stack slots.
                alloc_below(&mut end, size, align)?
            } else if size == 0 {
                slot(-(end as i32))
            } else if sharing.as_ref().is_some_and(|s| s.shareable.contains(local)) {
                shared.push(local);
                0
            } else {
                alloc_below(&mut end, size, align)?
            };
            locals.push(LocalSlot { off, layout });
        }
        let n_args = n_fixed + spread.map_or(0, |s| locals[s].layout.fields.count());
        if n_args != n_inputs {
            return native(if spread.is_some() { "spread argument doesn't match the ABI" } else { "argument count doesn't match the ABI" });
        }
        let unwinds = body.basic_blocks.iter().any(|b| {
            matches!(b.terminator().unwind(), Some(UnwindAction::Cleanup(_) | UnwindAction::Terminate(_)))
                || matches!(b.terminator().kind, TerminatorKind::UnwindResume)
        });
        let exception = if unwinds { Some(alloc_below(&mut end, 8, 8)?) } else { None };
        let sret = if sig.ret_kind == ryo_bytecode::asm::RET_SRET { Some(alloc_below(&mut end, 8, 8)?) } else { None };
        if let Some(sharing) = &sharing {
            end = sharing.place(&mut locals, &shared, end)?;
        }
        // Each input's home: its local, a field of the spread local, or for the caller
        // location an 8-byte slot. An `Indirect` input also gets a slot for its pointer.
        let mut arg_homes = Vec::with_capacity(sig.inputs.len());
        for i in 0..n_fixed.min(sig.inputs.len()) {
            arg_homes.push(locals[Local::from_usize(i + 1)].off);
        }
        if let Some(s) = spread {
            let l = locals[s];
            for j in 0..l.layout.fields.count() {
                arg_homes.push(l.off + l.layout.fields.offset(j).bytes() as u32);
            }
        }
        if sig.caller_location {
            arg_homes.push(alloc_below(&mut end, 8, 8)?);
        }
        let mut arg_ptrs = Vec::with_capacity(sig.inputs.len());
        for i in 0..sig.inputs.len() {
            let indirect =
                sig.plan.as_ref().is_some_and(|p| p.locs.get(i).is_some_and(|l| matches!(l[..], [ArgLoc::PtrReg(_) | ArgLoc::PtrStack(_)])));
            arg_ptrs.push(if indirect { Some(alloc_below(&mut end, 8, 8)?) } else { None });
        }
        if end >= OUT_END {
            return native("frame too large");
        }
        Ok(Frame { locals, locals_end: end, temp_top: end, high: end, temps: Vec::new(), exception, sret, arg_homes, arg_ptrs })
    }

    /// The exception slot. Only functions whose MIR has cleanup or terminate actions, or
    /// `UnwindResume`, have one.
    pub fn exception_slot(&self) -> u32 {
        self.exception.expect("a landing pad in a function without cleanup")
    }

    /// A temporary slot, live until [`Frame::reset_temps`].
    pub fn temp(&mut self, size: u64, align: u64) -> u32 {
        let align = align.clamp(1, 16) as u32;
        self.temp_top = (self.temp_top + size as u32).next_multiple_of(align);
        self.high = self.high.max(self.temp_top);
        let s = slot(-(self.temp_top as i32));
        self.temps.push((s, size as u32, align));
        s
    }

    /// Frees every temporary (between statements).
    pub fn reset_temps(&mut self) {
        self.temp_top = self.locals_end;
        self.temps.clear();
    }

    /// The object the slot `s` is part of, as its slot, size and alignment: the local
    /// `base`, or else the live temporary or the only local containing it. `None` if none
    /// is known, or if locals sharing the bytes make it ambiguous.
    pub fn object(&self, s: u32, base: Option<Local>) -> Option<(u32, u32, u32)> {
        let local = |l: &LocalSlot<'_>| (l.off, l.layout.size.bytes() as u32, l.layout.align.abi.bytes().min(16) as u32);
        let within = |&(o, n, _): &(u32, u32, u32)| s.wrapping_sub(o) < n.max(1);
        if let Some(b) = base {
            // Up to its end: the address of a zero-sized part there.
            return Some(local(&self.locals[b])).filter(|&(o, n, _)| s.wrapping_sub(o) <= n);
        }
        if let Some(t) = self.temps.iter().copied().find(within) {
            return Some(t);
        }
        let mut found = self.locals.iter().map(local).filter(within);
        match (found.next(), found.next()) {
            (Some(o), None) => Some(o),
            _ => None,
        }
    }

    /// Bytes below `fp` the locals take, and the locals with the most temporaries took (the
    /// frame size without the outgoing block): the certificate's frame map (`cert.rs`).
    pub fn extent(&self) -> (u32, u32) {
        (self.locals_end, self.high)
    }

    /// The temporaries in use: their first slot and their size.
    pub fn temps(&self) -> (u32, u32) {
        (slot(-(self.temp_top as i32)), self.temp_top - self.locals_end)
    }

    /// The frame size `F`, for a function whose largest outgoing argument block is
    /// `outgoing` bytes. Fails if the frame doesn't fit [`OUT_END`].
    pub fn frame_size(&self, outgoing: u32) -> Result<u32, NeedsNative> {
        let f = abi::frame_size(self.high, outgoing);
        if self.high >= OUT_END || outgoing >= OUT_END || f >= OUT_END {
            return native("frame too large");
        }
        Ok(f)
    }
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Frees every temporary, telling the assembler they are dead (the register cache drops
    /// stores nothing reads, design/vm.md#register-cache).
    pub fn reset_temps(&mut self) {
        let (lo, len) = self.frame.temps();
        self.asm.dead(lo, len);
        self.asm.storage_end(lo, len);
        self.frame.reset_temps();
    }

    /// Records that the address of the slot `s`, part of `base` (else of the object
    /// [`Frame::object`] finds), escapes: the whole object's ([`ryo_bytecode::asm::Asm::escape`]). Keeps
    /// the function native if the object isn't known.
    pub fn escape(&mut self, s: u32, base: Option<Local>) -> Result<(), NeedsNative> {
        let Some((at, size, align)) = self.frame.object(s, base) else {
            return native("address of a slot of no known object");
        };
        self.asm.escape(at, size, align);
        Ok(())
    }

    /// `StorageDead(local)`: its storage ends ([`ryo_bytecode::asm::Asm::storage_end`]).
    pub fn storage_dead(&mut self, local: Local) {
        let l = self.frame.locals[local];
        self.asm.storage_end(l.off, l.layout.size.bytes() as u32);
    }

    /// Tells the assembler that `local`'s slot is dead.
    pub fn local_dead(&mut self, local: Local) {
        let l = self.frame.locals[local];
        self.asm.dead(l.off, l.layout.size.bytes() as u32);
    }

    /// A temporary of `layout`'s size and alignment.
    pub fn temp_for(&mut self, layout: TyAndLayout<'tcx>) -> u32 {
        self.frame.temp(layout.size.bytes(), layout.align.abi.bytes())
    }

    /// An 8-byte temporary (pointers, `usize`).
    pub fn temp8(&mut self) -> u32 {
        self.frame.temp(8, 8)
    }

    /// The prologue: stores the argument registers (`arg`s come first: the first handler
    /// call clobbers them) to the inputs' homes, the sret address and `Indirect` inputs'
    /// pointers to their slots; then copies the inputs on the stack and the values behind the
    /// pointers to the homes.
    pub fn prologue(&mut self, sig: &AbiSig<'tcx>) -> Result<(), NeedsNative> {
        let Some(plan) = &sig.plan else { return native("a VM function without a calling convention") };
        let arg = |fx: &mut Self, d: u32, r: ArgReg| {
            fx.op(Opcode::Arg, &[d, r.word()]);
        };
        if let Some(p) = self.frame.sret {
            arg(self, p, ArgReg { xmm: false, size: 8, index: 0 });
        }
        for (i, locs) in plan.locs.iter().enumerate() {
            for &l in locs {
                match l {
                    ArgLoc::Reg { reg, off } => arg(self, self.frame.arg_homes[i] + off, reg),
                    ArgLoc::PtrReg(index) => arg(self, self.frame.arg_ptrs[i].unwrap(), ArgReg { xmm: false, size: 8, index }),
                    ArgLoc::Stack { .. } | ArgLoc::PtrStack(_) => {}
                }
            }
        }
        // The stack argument area is at `fp + 16`.
        let incoming = |at: u32| self::slot((HEADER_SIZE + at) as i32);
        for (i, locs) in plan.locs.iter().enumerate() {
            for &l in locs {
                match l {
                    ArgLoc::Stack { at, off, size } => self.mov(self.frame.arg_homes[i] + off, incoming(at), size),
                    ArgLoc::PtrStack(at) => self.mov(self.frame.arg_ptrs[i].unwrap(), incoming(at), 8),
                    ArgLoc::Reg { .. } | ArgLoc::PtrReg(_) => {}
                }
            }
            if let Some(p) = self.frame.arg_ptrs[i] {
                let size = sig.fields[i].size;
                self.op(Opcode::LoadCopy, &[self.frame.arg_homes[i], p, 0, size]);
            }
        }
        Ok(())
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
        let mut entry: IndexVec<BasicBlock, DenseBitSet<Local>> = IndexVec::from_elem_n(DenseBitSet::new_empty(n), blocks);
        let mut work: Vec<BasicBlock> = body.basic_blocks.indices().rev().collect();
        let mut queued: DenseBitSet<BasicBlock> = DenseBitSet::new_filled(blocks);
        // One scratch set, refilled per block (`clone_from` reuses its words).
        let mut cur = DenseBitSet::new_empty(n);
        while let Some(bb) = work.pop() {
            queued.remove(bb);
            let data = &body.basic_blocks[bb];
            cur.clone_from(&entry[bb]);
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
            cur.clone_from(&entry[bb]);
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

    /// Places the `shared` locals below the `start` bytes under `fp` already taken, each as
    /// close to `fp` as it can go without overlapping a conflicting local placed before it.
    /// Returns the bytes below `fp` the locals take.
    ///
    /// Positions are depths below `fp`: a local of `size` bytes at depth `d` takes the bytes
    /// `fp - d .. fp - d + size`, the depth range `d - size .. d`, and `d` is a multiple of
    /// its alignment.
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
            let mut d = place_below(start, size, align)?;
            for &(lo, hi) in &busy {
                if d <= lo {
                    break;
                }
                if hi > d - size {
                    d = place_below(hi, size, align)?;
                }
            }
            locals[l].off = slot(-(d as i32));
            end = end.max(d);
            placed.push((d - size, d, l));
        }
        Ok(end)
    }
}

/// The depth of a local of `size` bytes placed directly below the `taken` bytes under `fp`:
/// `taken + size`, rounded up to `align`.
fn place_below(taken: u32, size: u32, align: u32) -> Result<u32, NeedsNative> {
    match taken.checked_add(size) {
        Some(d) if d < OUT_END => Ok(d.next_multiple_of(align.max(1))),
        _ => native("frame too large"),
    }
}

/// Places an object of `size` bytes directly below the `end` bytes under `fp`
/// ([`place_below`]), moves `end` past it and returns its slot.
fn alloc_below(end: &mut u32, size: u32, align: u32) -> Result<u32, NeedsNative> {
    *end = place_below(*end, size, align)?;
    Ok(slot(-(*end as i32)))
}

/// Applies the `StorageLive`/`StorageDead` statements to `live`, calling `on_live(l, live)`
/// before each `StorageLive(l)`.
fn storage_effects(stmts: &[rustc_middle::mir::Statement<'_>], live: &mut DenseBitSet<Local>, mut on_live: impl FnMut(Local, &DenseBitSet<Local>)) {
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

/// The locals whose value is dead after the statement that reads it, with that statement's
/// location, sorted: locals other than `_0` and the arguments that are read once, by a
/// statement, defined once (as a whole) earlier in the same block, and never borrowed, dropped
/// or indexed (which the lowering does through the local's address). Every execution of the
/// read follows the definition, so nothing reads the value after it.
pub fn dead_after_read(body: &Body<'_>) -> Vec<(Location, Local)> {
    #[derive(Clone, Copy, Default)]
    struct Use {
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
            ) | PlaceContext::NonMutatingUse(
                NonMutatingUseContext::SharedBorrow | NonMutatingUseContext::FakeBorrow | NonMutatingUseContext::RawBorrow,
            )
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
    let mut v = Uses(IndexVec::from_elem(Use::default(), &body.local_decls));
    v.visit_body(body);
    let mut out: Vec<(Location, Local)> =
        v.0.iter_enumerated()
            .filter(|&(l, u)| l.as_usize() > body.arg_count && !u.escapes && u.reads == 1 && u.defs == 1)
            .filter_map(|(l, u)| {
                let (r, d) = (u.read?, u.def?);
                let in_stmt = r.statement_index < body.basic_blocks[r.block].statements.len();
                (in_stmt && d.block == r.block && d.statement_index < r.statement_index).then_some((r, l))
            })
            .collect();
    out.sort_unstable();
    out
}
