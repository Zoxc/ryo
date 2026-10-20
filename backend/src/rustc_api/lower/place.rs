//! Places (design/lowering.md#places-and-operands): every place becomes a frame slot or a
//! memory operand `[p + k]`, with constant offsets folded at lowering time.

use rustc_abi::FieldIdx;
use rustc_middle::mir::{Place, PlaceTy, ProjectionElem};
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, Ty};

use super::emit::{Width, opw};
use super::{FnCx, NeedsNative, native};
use ryo_bytecode::insn::Opcode;

/// Where a value lives.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Loc {
    /// The frame slot at `fp + off`.
    Slot(u32),
    /// Memory at the pointer in slot `p`, plus `k`.
    Mem { p: u32, k: i32 },
}

impl Loc {
    /// The location `d` bytes further.
    pub fn offset(self, d: u64) -> Result<Loc, NeedsNative> {
        let d32 = u32::try_from(d).map_err(|_| NeedsNative("offset above 4 GiB".into()))?;
        Ok(match self {
            Loc::Slot(off) => Loc::Slot(off + d32),
            Loc::Mem { p, k } => Loc::Mem {
                p,
                k: k.checked_add_unsigned(d32).ok_or_else(|| NeedsNative("offset above 2 GiB".into()))?,
            },
        })
    }
}

/// A lowered place: its location, layout, and for unsized places, the slot holding the
/// pointer metadata (length or vtable).
#[derive(Clone, Copy, Debug)]
pub struct PlaceVal<'tcx> {
    pub loc: Loc,
    pub layout: TyAndLayout<'tcx>,
    pub meta: Option<u32>,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Lowers a place.
    pub fn place(&mut self, place: Place<'tcx>) -> Result<PlaceVal<'tcx>, NeedsNative> {
        let place = self.mono(place);
        let local = self.frame.locals[place.local];
        let mut pv = PlaceVal { loc: Loc::Slot(local.off), layout: local.layout, meta: None };
        let mut pty = PlaceTy::from_ty(local.layout.ty);
        for elem in place.projection {
            let next = pty.projection_ty(self.tcx, elem);
            pv = self.project(pv, elem, next)?;
            pty = next;
        }
        Ok(pv)
    }

    fn project(
        &mut self,
        pv: PlaceVal<'tcx>,
        elem: ProjectionElem<rustc_middle::mir::Local, Ty<'tcx>>,
        next: PlaceTy<'tcx>,
    ) -> Result<PlaceVal<'tcx>, NeedsNative> {
        let next_layout = |fx: &Self| -> Result<TyAndLayout<'tcx>, NeedsNative> {
            let l = fx.layout_of(next.ty)?;
            Ok(match next.variant_index {
                Some(v) => l.for_variant(&fx.lcx(), v),
                None => l,
            })
        };
        match elem {
            ProjectionElem::Deref => self.deref(pv, next_layout(self)?),
            ProjectionElem::Field(f, _) => self.field(pv, f, next_layout(self)?),
            ProjectionElem::Downcast(_, v) => Ok(PlaceVal { layout: pv.layout.for_variant(&self.lcx(), v), ..pv }),
            ProjectionElem::OpaqueCast(_) | ProjectionElem::UnwrapUnsafeBinder(_) => {
                Ok(PlaceVal { layout: next_layout(self)?, ..pv })
            }
            ProjectionElem::Index(i) => {
                let idx = self.frame.locals[i].off;
                self.index(pv, idx, next_layout(self)?)
            }
            ProjectionElem::ConstantIndex { offset, min_length: _, from_end } => {
                let elem = next_layout(self)?;
                if !from_end {
                    return Ok(PlaceVal { loc: pv.loc.offset(offset * elem.size.bytes())?, layout: elem, meta: None });
                }
                match (pv.layout.ty.kind(), pv.meta) {
                    (ty::Array(_, len), _) => {
                        let len = len.try_to_target_usize(self.tcx).expect("monomorphic array length");
                        let i = len - offset;
                        Ok(PlaceVal { loc: pv.loc.offset(i * elem.size.bytes())?, layout: elem, meta: None })
                    }
                    (_, Some(meta)) => {
                        // len - offset
                        let t = self.temp8();
                        self.op(opw("SubImm", Width::W64), &[t, meta, offset as u32, (offset >> 32) as u32]);
                        self.index(pv, t, elem)
                    }
                    _ => native("ConstantIndex from the end of a sized non-array"),
                }
            }
            ProjectionElem::Subslice { from, to, from_end } => {
                let layout = next_layout(self)?;
                let stride = match pv.layout.ty.kind() {
                    ty::Array(e, _) | ty::Slice(e) => self.layout_of(*e)?.size.bytes(),
                    ty::Str => 1,
                    _ => return native("Subslice of a non-array"),
                };
                if !from_end {
                    // An array: the result is an array too.
                    return Ok(PlaceVal { loc: pv.loc.offset(from * stride)?, layout, meta: None });
                }
                let Some(meta) = pv.meta else { return native("Subslice from the end of an array") };
                let base = self.place_addr(pv.loc)?;
                let p = self.temp8();
                self.ptr_add(p, base, (from * stride) as i64);
                let len = self.temp8();
                let cut = from + to;
                self.op(opw("SubImm", Width::W64), &[len, meta, cut as u32, (cut >> 32) as u32]);
                Ok(PlaceVal { loc: Loc::Mem { p, k: 0 }, layout, meta: Some(len) })
            }
        }
    }

    fn deref(&mut self, pv: PlaceVal<'tcx>, pointee: TyAndLayout<'tcx>) -> Result<PlaceVal<'tcx>, NeedsNative> {
        if pv.layout.ty.is_box() {
            return native("deref of a Box");
        }
        if !matches!(pv.layout.ty.kind(), ty::Ref(..) | ty::RawPtr(..)) {
            return native("deref of a non-pointer");
        }
        if pv.meta.is_some() {
            return native("deref of an unsized place");
        }
        let wide = pointee.is_unsized();
        let (p, meta) = match pv.loc {
            Loc::Slot(s) => (s, wide.then_some(s + 8)),
            Loc::Mem { .. } => {
                // `(*(*_n).f).g`: load the inner pointer first.
                let size = if wide { 16 } else { 8 };
                let t = self.frame.temp(size, 8);
                self.load(t, pv.loc, size as u32);
                (t, wide.then_some(t + 8))
            }
        };
        Ok(PlaceVal { loc: Loc::Mem { p, k: 0 }, layout: pointee, meta })
    }

    fn field(&mut self, pv: PlaceVal<'tcx>, f: FieldIdx, layout: TyAndLayout<'tcx>) -> Result<PlaceVal<'tcx>, NeedsNative> {
        let off = pv.layout.fields.offset(f.as_usize()).bytes();
        let meta = if layout.is_unsized() {
            // A slice or `str` tail has a static offset; a `dyn` tail's depends on the
            // vtable's alignment, unless it is at offset 0.
            let tail = self.tcx.struct_tail_for_codegen(layout.ty, ty::TypingEnv::fully_monomorphized());
            if matches!(tail.kind(), ty::Dynamic(..)) && off != 0 {
                return native("field of an unsized struct with a dynamically aligned tail");
            }
            pv.meta
        } else {
            None
        };
        Ok(PlaceVal { loc: pv.loc.offset(off)?, layout, meta })
    }

    /// Element `idx` (a `usize` in slot `idx`) of the array or slice at `pv`.
    fn index(&mut self, pv: PlaceVal<'tcx>, idx: u32, elem: TyAndLayout<'tcx>) -> Result<PlaceVal<'tcx>, NeedsNative> {
        let stride = u32::try_from(elem.size.bytes()).map_err(|_| NeedsNative("element above 4 GiB".into()))?;
        let t = self.temp8();
        let k = match pv.loc {
            Loc::Slot(s) => {
                self.op(Opcode::Addr, &[t, s]);
                self.op(Opcode::PtrIndex, &[t, t, idx, stride]);
                0
            }
            Loc::Mem { p, k } => {
                self.op(Opcode::PtrIndex, &[t, p, idx, stride]);
                k
            }
        };
        Ok(PlaceVal { loc: Loc::Mem { p: t, k }, layout: elem, meta: None })
    }

    /// The address of `loc` in a slot (which may be the pointer slot itself).
    pub fn place_addr(&mut self, loc: Loc) -> Result<u32, NeedsNative> {
        Ok(match loc {
            Loc::Slot(s) => {
                let t = self.temp8();
                self.op(Opcode::Addr, &[t, s]);
                t
            }
            Loc::Mem { p, k: 0 } => p,
            Loc::Mem { p, k } => {
                let t = self.temp8();
                self.ptr_add(t, p, i64::from(k));
                t
            }
        })
    }

    /// Writes the address of `loc` to slot `d`.
    pub fn addr_into(&mut self, d: u32, loc: Loc) {
        match loc {
            Loc::Slot(s) => {
                self.op(Opcode::Addr, &[d, s]);
            }
            Loc::Mem { p, k: 0 } => self.mov(d, p, 8),
            Loc::Mem { p, k } => self.ptr_add(d, p, i64::from(k)),
        }
    }

    /// `d = p + imm`.
    pub fn ptr_add(&mut self, d: u32, p: u32, imm: i64) {
        if imm == 0 {
            self.mov(d, p, 8);
        } else {
            self.op(Opcode::PtrAdd, &[d, p, imm as u32, (imm >> 32) as u32]);
        }
    }
}
