//! Places (design/lowering.md#places-and-operands): every place becomes a frame slot or a
//! memory operand `[p + k]`, with constant offsets folded at lowering time.

use rustc_abi::FieldIdx;
use rustc_middle::mir::{Local, Place, PlaceTy, ProjectionElem};
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, Ty};

use super::emit::{Width, opw};
use super::{FnCx, NeedsNative, native};
use ryo_bytecode::full::Opcode;

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
            Loc::Mem { p, k } => Loc::Mem { p, k: k.checked_add_unsigned(d32).ok_or_else(|| NeedsNative("offset above 2 GiB".into()))? },
        })
    }
}

/// A `usize` known at lowering time, or computed at run time into a slot.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum DynVal {
    Const(u64),
    Slot(u32),
}

/// A lowered place: its location, layout, and for unsized places, the slot holding the
/// pointer metadata (length or vtable).
#[derive(Clone, Copy, Debug)]
pub struct PlaceVal<'tcx> {
    pub loc: Loc,
    pub layout: TyAndLayout<'tcx>,
    pub meta: Option<u32>,
    /// The local a frame place (`Loc::Slot`) is part of: the object its address escapes as
    /// ([`FnCx::escape`]). `None` for memory and for places not rooted in a local.
    pub base: Option<Local>,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Lowers a place.
    pub fn place(&mut self, place: Place<'tcx>) -> Result<PlaceVal<'tcx>, NeedsNative> {
        let local = self.frame.locals[place.local];
        let mut pv = PlaceVal { loc: Loc::Slot(local.off), layout: local.layout, meta: None, base: Some(place.local) };
        if place.projection.is_empty() {
            // The local's layout is already monomorphic: nothing to substitute.
            return Ok(pv);
        }
        let place = self.mono(place);
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
            ProjectionElem::OpaqueCast(_) | ProjectionElem::UnwrapUnsafeBinder(_) => Ok(PlaceVal { layout: next_layout(self)?, ..pv }),
            ProjectionElem::Index(i) => {
                let idx = self.frame.locals[i].off;
                self.index(pv, idx, next_layout(self)?)
            }
            ProjectionElem::ConstantIndex { offset, min_length: _, from_end } => {
                let elem = next_layout(self)?;
                if !from_end {
                    return Ok(PlaceVal { loc: pv.loc.offset(offset * elem.size.bytes())?, layout: elem, meta: None, ..pv });
                }
                match (pv.layout.ty.kind(), pv.meta) {
                    (ty::Array(_, len), _) => {
                        let len = len.try_to_target_usize(self.tcx).expect("monomorphic array length");
                        let i = len - offset;
                        Ok(PlaceVal { loc: pv.loc.offset(i * elem.size.bytes())?, layout: elem, meta: None, ..pv })
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
                    return Ok(PlaceVal { loc: pv.loc.offset(from * stride)?, layout, meta: None, ..pv });
                }
                let Some(meta) = pv.meta else { return native("Subslice from the end of an array") };
                let base = self.place_addr(pv.loc, pv.base)?;
                let p = self.temp8();
                self.ptr_add(p, base, (from * stride) as i64);
                let len = self.temp8();
                let cut = from + to;
                self.op(opw("SubImm", Width::W64), &[len, meta, cut as u32, (cut >> 32) as u32]);
                Ok(PlaceVal { loc: Loc::Mem { p, k: 0 }, layout, meta: Some(len), base: None })
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
        Ok(PlaceVal { loc: Loc::Mem { p, k: 0 }, layout: pointee, meta, base: None })
    }

    fn field(&mut self, pv: PlaceVal<'tcx>, f: FieldIdx, layout: TyAndLayout<'tcx>) -> Result<PlaceVal<'tcx>, NeedsNative> {
        let off = pv.layout.fields.offset(f.as_usize()).bytes();
        if layout.is_sized() {
            return Ok(PlaceVal { loc: pv.loc.offset(off)?, layout, meta: None, ..pv });
        }
        // An unsized tail (cg_ssa's `project_field`): `[T]` and `str` have a static
        // alignment, and at offset 0 rounding changes nothing. Otherwise the offset is
        // rounded up to the tail's dynamic alignment (from the vtable).
        if matches!(layout.ty.kind(), ty::Slice(..) | ty::Str) || off == 0 {
            return Ok(PlaceVal { loc: pv.loc.offset(off)?, layout, ..pv });
        }
        let (_, mut align) = self.size_and_align_of_dst(layout, pv.meta)?;
        if let ty::Adt(def, _) = pv.layout.ty.kind()
            && let Some(pack) = def.repr().pack
        {
            align = self.dyn_umin(align, DynVal::Const(pack.bytes()));
        }
        let off = self.dyn_align_up(DynVal::Const(off), align);
        let loc = match off {
            DynVal::Const(c) => pv.loc.offset(c)?,
            DynVal::Slot(o) => {
                let base = self.place_addr(pv.loc, pv.base)?;
                let p = self.temp8();
                self.op(opw("Add", Width::W64), &[p, base, o]);
                Loc::Mem { p, k: 0 }
            }
        };
        let base = if matches!(loc, Loc::Slot(_)) { pv.base } else { None };
        Ok(PlaceVal { loc, layout, meta: pv.meta, base })
    }

    /// Size and alignment of a value of `layout`, with metadata in slot `meta` if it is
    /// unsized (cg_ssa's `size_and_align_of_dst`).
    pub fn size_and_align_of_dst(&mut self, layout: TyAndLayout<'tcx>, meta: Option<u32>) -> Result<(DynVal, DynVal), NeedsNative> {
        if layout.is_sized() {
            return Ok((DynVal::Const(layout.size.bytes()), DynVal::Const(layout.align.abi.bytes())));
        }
        let Some(meta) = meta else { return native("unsized value without metadata") };
        match layout.ty.kind() {
            ty::Dynamic(..) => {
                // vtable entries 1 and 2: size, align.
                let (s, a) = (self.temp8(), self.temp8());
                let size = ty::COMMON_VTABLE_ENTRIES_SIZE as u32 * 8;
                let align = ty::COMMON_VTABLE_ENTRIES_ALIGN as u32 * 8;
                self.op(opw("Load", Width::W64), &[s, meta, size]);
                self.op(opw("Load", Width::W64), &[a, meta, align]);
                Ok((DynVal::Slot(s), DynVal::Slot(a)))
            }
            ty::Slice(_) | ty::Str => {
                let unit = layout.field(&self.lcx(), 0);
                let size = match unit.size.bytes() {
                    1 => DynVal::Slot(meta),
                    n => {
                        let s = self.temp8();
                        self.op(opw("MulImm", Width::W64), &[s, meta, n as u32, (n >> 32) as u32]);
                        DynVal::Slot(s)
                    }
                };
                Ok((size, DynVal::Const(unit.align.abi.bytes())))
            }
            ty::Adt(..) | ty::Tuple(..) => {
                let i = layout.fields.count() - 1;
                let unsized_off = layout.fields.offset(i).bytes();
                let sized_align = layout.align.abi.bytes();
                let field = layout.field(&self.lcx(), i);
                let (size, mut align) = self.size_and_align_of_dst(field, Some(meta))?;
                if let ty::Adt(def, _) = layout.ty.kind()
                    && let Some(pack) = def.repr().pack
                {
                    align = self.dyn_umin(align, DynVal::Const(pack.bytes()));
                }
                let full_align = self.dyn_umax(DynVal::Const(sized_align), align);
                // `unsized_size` is a multiple of its alignment, so one rounding at the end
                // suffices (as in cg_ssa).
                let full_size = match size {
                    DynVal::Const(c) => DynVal::Const(unsized_off + c),
                    DynVal::Slot(s) => {
                        let t = self.temp8();
                        self.op(opw("AddImm", Width::W64), &[t, s, unsized_off as u32, (unsized_off >> 32) as u32]);
                        DynVal::Slot(t)
                    }
                };
                let full_size = self.dyn_align_up(full_size, full_align);
                Ok((full_size, full_align))
            }
            _ => native("size of an extern type or other unsized type"),
        }
    }

    /// A [`DynVal`] in a slot.
    pub fn dyn_slot(&mut self, v: DynVal) -> u32 {
        match v {
            DynVal::Slot(s) => s,
            DynVal::Const(c) => {
                let t = self.temp8();
                self.imm(Width::W64, t, u128::from(c));
                t
            }
        }
    }

    /// `v` rounded up to `align`, a power of two: `(v + align - 1) & -align`.
    pub fn dyn_align_up(&mut self, v: DynVal, align: DynVal) -> DynVal {
        match (v, align) {
            (DynVal::Const(v), DynVal::Const(a)) => DynVal::Const(v.next_multiple_of(a)),
            (_, DynVal::Const(1)) => v,
            (v, DynVal::Const(a)) => {
                let s = self.dyn_slot(v);
                let t = self.temp8();
                let m = a - 1;
                self.op(opw("AddImm", Width::W64), &[t, s, m as u32, (m >> 32) as u32]);
                let m = !m;
                self.op(opw("AndImm", Width::W64), &[t, t, m as u32, (m >> 32) as u32]);
                DynVal::Slot(t)
            }
            (v, DynVal::Slot(a)) => {
                let s = self.dyn_slot(v);
                let (t, n) = (self.temp8(), self.temp8());
                self.op(opw("SubImm", Width::W64), &[t, a, 1, 0]);
                self.op(opw("Add", Width::W64), &[t, t, s]);
                self.op(opw("Neg", Width::W64), &[n, a]);
                self.op(opw("And", Width::W64), &[t, t, n]);
                DynVal::Slot(t)
            }
        }
    }

    /// The larger of two unsigned values.
    pub fn dyn_umax(&mut self, a: DynVal, b: DynVal) -> DynVal {
        match (a, b) {
            (DynVal::Const(x), DynVal::Const(y)) => DynVal::Const(x.max(y)),
            (DynVal::Const(0), v) | (v, DynVal::Const(0)) => v,
            _ => self.dyn_minmax(a, b, true),
        }
    }

    /// The smaller of two unsigned values.
    pub fn dyn_umin(&mut self, a: DynVal, b: DynVal) -> DynVal {
        match (a, b) {
            (DynVal::Const(x), DynVal::Const(y)) => DynVal::Const(x.min(y)),
            _ => self.dyn_minmax(a, b, false),
        }
    }

    /// `max(a, b)` or `min(a, b)` without branches: `a ^ ((a ^ b) & -c)`, where `c` says
    /// whether `b` is the result (`a < b` for max, `b < a` for min).
    fn dyn_minmax(&mut self, a: DynVal, b: DynVal, max: bool) -> DynVal {
        let (a, b) = (self.dyn_slot(a), self.dyn_slot(b));
        let (c, m, t) = (self.frame.temp(1, 1), self.temp8(), self.temp8());
        let (x, y) = if max { (a, b) } else { (b, a) };
        self.op(opw("LtU", Width::W64), &[c, x, y]);
        self.int_cast(m, c, Width::W8, Width::W64, false);
        self.op(opw("Neg", Width::W64), &[m, m]);
        self.op(opw("Xor", Width::W64), &[t, a, b]);
        self.op(opw("And", Width::W64), &[t, t, m]);
        self.op(opw("Xor", Width::W64), &[t, t, a]);
        DynVal::Slot(t)
    }

    /// Element `idx` (a `usize` in slot `idx`) of the array or slice at `pv`.
    fn index(&mut self, pv: PlaceVal<'tcx>, idx: u32, elem: TyAndLayout<'tcx>) -> Result<PlaceVal<'tcx>, NeedsNative> {
        let stride = u32::try_from(elem.size.bytes()).map_err(|_| NeedsNative("element above 4 GiB".into()))?;
        let t = self.temp8();
        let (p, k) = match pv.loc {
            Loc::Slot(_) => {
                self.addr_into(t, pv.loc, pv.base)?;
                (t, 0)
            }
            Loc::Mem { p, k } => (p, k),
        };
        self.op(Opcode::PtrIndex, &[t, p, idx, stride]);
        Ok(PlaceVal { loc: Loc::Mem { p: t, k }, layout: elem, meta: None, base: None })
    }

    /// The address of `loc` in a slot (which may be the pointer slot itself). A frame place
    /// escapes as part of `base` ([`FnCx::escape`]).
    pub fn place_addr(&mut self, loc: Loc, base: Option<Local>) -> Result<u32, NeedsNative> {
        if let Loc::Mem { p, k: 0 } = loc {
            return Ok(p);
        }
        let t = self.temp8();
        self.addr_into(t, loc, base)?;
        Ok(t)
    }

    /// Writes the address of `loc` to slot `d`. A frame place escapes as part of `base`
    /// ([`FnCx::escape`]).
    pub fn addr_into(&mut self, d: u32, loc: Loc, base: Option<Local>) -> Result<(), NeedsNative> {
        match loc {
            Loc::Slot(s) => {
                self.escape(s, base)?;
                self.op(Opcode::Addr, &[d, s]);
            }
            Loc::Mem { p, k: 0 } => self.mov(d, p, 8),
            Loc::Mem { p, k } => self.ptr_add(d, p, i64::from(k)),
        }
        Ok(())
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
