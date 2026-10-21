//! Operands and value moves (design/lowering.md#places-and-operands, "Aggregate copies").
//!
//! `Copy` and `Move` are lowered the same way. Copies between frame slots use `mov`/`copy`
//! (distinct slots never overlap); a side in memory uses loads and stores, which have
//! `memmove` semantics.

use rustc_middle::mir::Operand;
use rustc_middle::ty::layout::TyAndLayout;
use ryo_bytecode::insn::Opcode;

use super::emit::{Width, opw};
use super::place::{Loc, PlaceVal};
use super::{FnCx, NeedsNative, native};

/// Copies above this size between two memory places go through `memmove` instead of a
/// temporary slot.
const MAX_TEMP_COPY: u32 = 256;

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
                let dp = self.place_addr(dst)?;
                let sp = self.place_addr(src)?;
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
                match Width::of_size(u64::from(size)) {
                    Some(w) => self.op(opw("Load", w), &[d, p, k as u32]),
                    None => self.op(Opcode::LoadCopy, &[d, p, k as u32, size]),
                };
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
                match Width::of_size(u64::from(size)) {
                    Some(w) => self.op(opw("Store", w), &[p, k as u32, s]),
                    None => self.op(Opcode::StoreCopy, &[p, k as u32, s, size]),
                };
            }
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
                self.copy_val(dst, pv.loc, pv.layout.size.bytes() as u32)
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
        let layout = self.operand_layout(op)?;
        if let Operand::Copy(place) | Operand::Move(place) = op {
            let pv = self.place(*place)?;
            if pv.meta.is_some() {
                return native("unsized operand");
            }
            return Ok((self.loc_slot(pv.loc, pv.layout)?, layout));
        }
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
                self.load(t, loc, layout.size.bytes() as u32);
                t
            }
        })
    }

    /// Runs `f` with a frame slot to write `size` bytes to, standing for `dst`: `dst` itself
    /// if it is a slot, else a temporary that is stored to `dst` afterwards.
    pub fn with_slot(
        &mut self,
        dst: Loc,
        size: u32,
        f: impl FnOnce(&mut Self, u32) -> Result<(), NeedsNative>,
    ) -> Result<(), NeedsNative> {
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
    pub fn with_place_slot(
        &mut self,
        dst: PlaceVal<'tcx>,
        f: impl FnOnce(&mut Self, u32) -> Result<(), NeedsNative>,
    ) -> Result<(), NeedsNative> {
        if dst.meta.is_some() {
            return native("assignment to an unsized place");
        }
        self.with_slot(dst.loc, dst.layout.size.bytes() as u32, f)
    }
}
