//! Operands and value moves (design/lowering.md#places-and-operands, "Aggregate copies").
//!
//! `Copy` and `Move` are lowered the same way. Copies between frame slots use `mov`/`copy`
//! (distinct slots never overlap); a side in memory uses loads and stores, which have
//! `memmove` semantics.

use rustc_middle::mir::Operand;
use rustc_middle::ty::layout::TyAndLayout;
use ryo_bytecode::full::Opcode;

use super::emit::{IntOp, Width, opw};
use super::place::{Loc, PlaceVal};
use super::{FnCx, LayoutCx, NeedsNative, native};

/// Copies above this size between two memory places go through `memmove` instead of a
/// temporary slot.
const MAX_TEMP_COPY: u32 = 256;

/// See [`FnCx::split`].
enum Split {
    One(Width),
    Pieces(Vec<(u32, Width)>),
    Block,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Copies `size` bytes from `src` to `dst`.
    pub fn copy_val(&mut self, dst: Loc, src: Loc, size: u32) -> Result<(), NeedsNative> {
        if size == 0 || dst == src {
            return Ok(());
        }
        match (dst, src) {
            (Loc::Slot(d), Loc::Slot(s)) => self.mov(d, s, size),
            (Loc::Slot(d), Loc::Mem { .. }) => self.load(d, src, size),
            (Loc::Mem { .. }, Loc::Slot(s)) => self.store(dst, s, size),
            (Loc::Mem { .. }, Loc::Mem { .. }) if size <= MAX_TEMP_COPY => {
                let t = self.frame.temp(u64::from(size), 16);
                self.load(t, src, size);
                self.store(dst, t, size);
            }
            (Loc::Mem { .. }, Loc::Mem { .. }) => {
                let dp = self.place_addr(dst, None)?;
                let sp = self.place_addr(src, None)?;
                let n = self.temp8();
                self.imm(Width::W64, n, u128::from(size));
                self.op(Opcode::Memmove, &[dp, sp, n]);
            }
        }
        Ok(())
    }

    /// Loads `size` bytes at `src` into slot `d`.
    pub fn load(&mut self, d: u32, src: Loc, size: u32) {
        match src {
            Loc::Slot(s) => self.mov(d, s, size),
            Loc::Mem { p, k } => {
                if size == 0 {
                    return;
                }
                // Split unless a piece would overwrite the pointer `p`.
                match self.split(size, Width::W64, p + 8 <= d || p >= d + size) {
                    Split::One(w) => {
                        self.op(opw(IntOp::Load, w), &[d, p, k as u32]);
                    }
                    Split::Pieces(ps) => {
                        for (o, w) in ps {
                            self.op(opw(IntOp::Load, w), &[d + o, p, (k + o as i32) as u32]);
                        }
                    }
                    Split::Block => {
                        self.op(Opcode::LoadCopy, &[d, p, k as u32, size]);
                    }
                }
            }
        }
    }

    /// Stores `size` bytes of slot `s` at `dst`.
    pub fn store(&mut self, dst: Loc, s: u32, size: u32) {
        match dst {
            Loc::Slot(d) => self.mov(d, s, size),
            Loc::Mem { p, k } => {
                if size == 0 {
                    return;
                }
                match self.split(size, Width::W64, true) {
                    Split::One(w) => {
                        self.op(opw(IntOp::Store, w), &[p, k as u32, s]);
                    }
                    Split::Pieces(ps) => {
                        for (o, w) in ps {
                            self.op(opw(IntOp::Store, w), &[p, (k + o as i32) as u32, s + o]);
                        }
                    }
                    Split::Block => {
                        self.op(Opcode::StoreCopy, &[p, k as u32, s, size]);
                    }
                }
            }
        }
    }

    /// How a `size`-byte copy is emitted: one access if `size` is a width, else (if
    /// `may_split`, the pieces not clobbering an operand) pieces up to `max` cut at
    /// [`FnCx::cuts`] when at most [`SPLIT_MAX`] bytes, else the block handler.
    fn split(&self, size: u32, max: Width, may_split: bool) -> Split {
        match Width::of_size(u64::from(size)) {
            Some(w) => Split::One(w),
            None if size <= SPLIT_MAX && may_split => Split::Pieces(pieces(size, max, &self.cuts)),
            None => Split::Block,
        }
    }

    /// Copies `size` bytes between two frame slots.
    pub fn mov(&mut self, d: u32, s: u32, size: u32) {
        if size == 0 || d == s {
            return;
        }
        match self.split(size, Width::W128, d + size <= s || s + size <= d) {
            Split::One(w) => {
                self.op(opw(IntOp::Mov, w), &[d, s]);
            }
            Split::Pieces(ps) => {
                for (o, w) in ps {
                    self.op(opw(IntOp::Mov, w), &[d + o, s + o]);
                }
            }
            Split::Block => {
                self.op(Opcode::Copy, &[d, s, size]);
            }
        }
    }

    /// Zeroes `size` bytes of slots at `d`: `imm 0` pieces up to [`SPLIT_MAX`] bytes, else
    /// `zero`.
    pub fn zero(&mut self, d: u32, size: u32) {
        if size > SPLIT_MAX {
            self.op(Opcode::Zero, &[d, size]);
            return;
        }
        for (o, w) in pieces(size, Width::W64, &self.cuts) {
            self.imm(w, d + o, 0);
        }
    }

    /// Runs `f` (a copy of a value of `layout`) with [`FnCx::cuts`] at the layout's field
    /// offsets.
    pub fn with_cuts<R>(&mut self, layout: TyAndLayout<'tcx>, f: impl FnOnce(&mut Self) -> R) -> R {
        let mut cuts = Vec::new();
        if layout.size.bytes() <= u64::from(SPLIT_MAX) {
            field_cuts(&self.lcx(), layout, 0, SPLIT_MAX, &mut cuts);
        }
        let old = std::mem::replace(&mut self.cuts, cuts);
        let r = f(self);
        self.cuts = old;
        r
    }

    /// Copies `n` bytes (a constant number of elements of `el`, from [`FnCx::small_block`])
    /// as pieces, cut at `el`'s fields when it is one element.
    pub fn mem_copy_elems(&mut self, dst: u32, src: u32, el: TyAndLayout<'tcx>, n: u32) {
        if u64::from(n) == el.size.bytes() { self.with_cuts(el, |fx| fx.mem_copy_pieces(dst, src, n)) } else { self.mem_copy_pieces(dst, src, n) }
    }

    /// The bytes of `count` elements of `el` when `count` is a constant small enough for
    /// [`FnCx::mem_copy_elems`] / [`FnCx::mem_set_pieces`].
    pub fn small_block(el: TyAndLayout<'tcx>, count: Option<u128>) -> Option<u32> {
        let n = count?.checked_mul(u128::from(el.size.bytes()))?;
        (n <= u128::from(SPLIT_MAX)).then_some(n as u32)
    }

    /// The bytes of `count` (a slot) elements of `el`, in a new temporary: the length of a
    /// `memcpy`/`memmove`/`memset` handler call.
    pub fn block_bytes(&mut self, count: u32, el: TyAndLayout<'tcx>) -> u32 {
        let n = self.temp8();
        self.op_imm(IntOp::Mul, Width::W64, n, count, u128::from(el.size.bytes()));
        n
    }

    /// Copies `n <= SPLIT_MAX` bytes from the memory at `src` to the memory at `dst` as
    /// `load`/`store` pieces (cut at [`FnCx::cuts`]) through a temporary: every piece is loaded
    /// before the first store, so overlapping ranges copy as `memmove` does.
    pub fn mem_copy_pieces(&mut self, dst: u32, src: u32, n: u32) {
        debug_assert!(n <= SPLIT_MAX);
        if n == 0 {
            return;
        }
        let t = self.frame.temp(u64::from(n), 16);
        self.load_pieces(t, src, n);
        self.store_pieces(dst, t, n);
    }

    /// `load.wK d+i, [p+i]` pieces (`K` <= 64) for `n` bytes.
    pub fn load_pieces(&mut self, d: u32, p: u32, n: u32) {
        for (o, w) in pieces(n, Width::W64, &self.cuts) {
            self.op(opw(IntOp::Load, w), &[d + o, p, o]);
        }
    }

    /// `store.wK [p+i], s+i` pieces (`K` <= 64) for `n` bytes.
    pub fn store_pieces(&mut self, p: u32, s: u32, n: u32) {
        for (o, w) in pieces(n, Width::W64, &self.cuts) {
            self.op(opw(IntOp::Store, w), &[p, o, s + o]);
        }
    }

    /// Sets `n <= SPLIT_MAX` bytes of the memory at `dst` to a byte (a constant, or the `u8`
    /// in a slot) as `store` pieces of a 64-bit pattern.
    pub fn mem_set_pieces(&mut self, dst: u32, byte: Result<u8, u32>, n: u32) {
        debug_assert!(n <= SPLIT_MAX);
        if n == 0 {
            return;
        }
        let ones = 0x0101_0101_0101_0101u128;
        let t = self.temp8();
        match byte {
            Ok(b) => self.imm(Width::W64, t, u128::from(b) * ones),
            Err(s) => {
                self.int_cast(t, s, Width::W8, Width::W64, false);
                self.op_imm(IntOp::Mul, Width::W64, t, t, ones);
            }
        }
        for (o, w) in pieces(n, Width::W64, &[]) {
            self.op(opw(IntOp::Store, w), &[dst, o, t]);
        }
    }

    /// The layout of an operand's type.
    pub fn operand_layout(&self, op: &Operand<'tcx>) -> Result<TyAndLayout<'tcx>, NeedsNative> {
        let ty = self.mono(op.ty(self.body, self.tcx));
        self.layout_of(ty)
    }

    /// Writes the value of `op` to `dst`.
    pub fn operand_into(&mut self, op: &Operand<'tcx>, dst: Loc) -> Result<(), NeedsNative> {
        match op {
            Operand::Copy(place) | Operand::Move(place) => {
                let pv = self.place(*place)?;
                if pv.meta.is_some() {
                    return native("unsized operand");
                }
                self.with_cuts(pv.layout, |fx| fx.copy_val(dst, pv.loc, pv.layout.size.bytes() as u32))
            }
            Operand::Constant(c) => self.const_into(c, dst),
            Operand::RuntimeChecks(rc) => {
                // The session's setting, as cg_ssa does (design/lowering.md).
                let v = rc.value(self.tcx.sess);
                self.with_slot(dst, 1, |fx, d| {
                    fx.imm(Width::W8, d, u128::from(v));
                    Ok(())
                })
            }
        }
    }

    /// The value of `op` in a frame slot: the operand's own slot if it is a local (or a field
    /// of one), else a temporary.
    pub fn operand_slot(&mut self, op: &Operand<'tcx>) -> Result<(u32, TyAndLayout<'tcx>), NeedsNative> {
        if let Operand::Copy(place) | Operand::Move(place) = op {
            // The place's layout is the operand's (an operand never ends in a `Downcast`).
            let pv = self.place(*place)?;
            if pv.meta.is_some() {
                return native("unsized operand");
            }
            return Ok((self.loc_slot(pv.loc, pv.layout)?, pv.layout));
        }
        let layout = self.operand_layout(op)?;
        let t = self.temp_for(layout);
        self.operand_into(op, Loc::Slot(t))?;
        Ok((t, layout))
    }

    /// The value at `loc` in a frame slot (loading it into a temporary if it is in memory).
    pub fn loc_slot(&mut self, loc: Loc, layout: TyAndLayout<'tcx>) -> Result<u32, NeedsNative> {
        Ok(match loc {
            Loc::Slot(s) => s,
            Loc::Mem { .. } => {
                let t = self.temp_for(layout);
                self.with_cuts(layout, |fx| fx.load(t, loc, layout.size.bytes() as u32));
                t
            }
        })
    }

    /// Runs `f` with a frame slot to write `size` bytes to, standing for `dst`: `dst` itself
    /// if it is a slot, else a temporary that is stored to `dst` afterwards.
    pub fn with_slot(&mut self, dst: Loc, size: u32, f: impl FnOnce(&mut Self, u32) -> Result<(), NeedsNative>) -> Result<(), NeedsNative> {
        match dst {
            Loc::Slot(d) => f(self, d),
            Loc::Mem { .. } => {
                let t = self.frame.temp(u64::from(size), 16);
                f(self, t)?;
                self.store(dst, t, size);
                Ok(())
            }
        }
    }

    /// [`with_slot`](Self::with_slot) for a place.
    pub fn with_place_slot(&mut self, dst: PlaceVal<'tcx>, f: impl FnOnce(&mut Self, u32) -> Result<(), NeedsNative>) -> Result<(), NeedsNative> {
        if dst.meta.is_some() {
            return native("assignment to an unsized place");
        }
        self.with_slot(dst.loc, dst.layout.size.bytes() as u32, f)
    }

    /// [`with_place_slot`](Self::with_place_slot) for an infallible `f`.
    pub fn into_place(&mut self, dst: PlaceVal<'tcx>, f: impl FnOnce(&mut Self, u32)) -> Result<(), NeedsNative> {
        self.with_place_slot(dst, |fx, d| {
            f(fx, d);
            Ok(())
        })
    }

    /// `op d, srcs...` into the place `dst`.
    pub fn op_to(&mut self, dst: PlaceVal<'tcx>, op: Opcode, srcs: &[u32]) -> Result<(), NeedsNative> {
        self.into_place(dst, |fx, d| {
            let mut buf = [0; 8];
            if srcs.len() < buf.len() {
                buf[0] = d;
                buf[1..=srcs.len()].copy_from_slice(srcs);
                fx.op(op, &buf[..=srcs.len()]);
            } else {
                fx.op(op, &[&[d], srcs].concat());
            }
        })
    }
}

/// Block copies and zeroing of at most this many bytes are split into scalar pieces
/// (`mov`/`load`/`store`/`imm`), which are inline, instead of the `copy`, `load.copy`,
/// `store.copy` and `zero` handler calls. Valid since MIR assignments never partially overlap.
pub const SPLIT_MAX: u32 = 48;

/// The `(offset, width)` pieces of a `size`-byte block: at each offset the widest width up
/// to `max` that fits and doesn't straddle one of the field offsets `cuts`, so the pieces
/// match the accesses the rest of the code makes to the fields.
pub fn pieces(size: u32, max: Width, cuts: &[u32]) -> Vec<(u32, Width)> {
    let mut v = Vec::new();
    let mut o = 0;
    while o < size {
        let w = [Width::W128, Width::W64, Width::W32, Width::W16, Width::W8]
            .into_iter()
            .find(|w| w.bytes() <= max.bytes() && o + w.bytes() <= size && !cuts.iter().any(|&c| o < c && c < o + w.bytes()))
            .expect("w8 always fits");
        v.push((o, w));
        o += w.bytes();
    }
    v
}

/// The offsets of the scalar leaves of `layout` (of every variant), up to `limit` bytes.
fn field_cuts<'tcx>(cx: &LayoutCx<'tcx>, layout: TyAndLayout<'tcx>, base: u32, limit: u32, out: &mut Vec<u32>) {
    if layout.size.bytes() > u64::from(limit) {
        return;
    }
    out.push(base);
    if let rustc_abi::BackendRepr::ScalarPair { b_offset, .. } = layout.backend_repr {
        out.push(base + b_offset.bytes() as u32);
        return;
    }
    if let rustc_abi::Variants::Multiple { ref variants, .. } = layout.variants {
        for v in variants.indices() {
            let vl = layout.for_variant(cx, v);
            for i in 0..vl.fields.count() {
                field_cuts(cx, vl.field(cx, i), base + vl.fields.offset(i).bytes() as u32, limit, out);
            }
        }
    }
    for i in 0..layout.fields.count() {
        field_cuts(cx, layout.field(cx, i), base + layout.fields.offset(i).bytes() as u32, limit, out);
    }
}
