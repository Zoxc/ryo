//! Aggregates and discriminants (design/lowering.md#rvalues): structs, tuples, closures,
//! arrays and enums, all through `tcx.layout_of`. Mirrors cg_ssa's `codegen_get_discr` and
//! `codegen_tag_value` (`rustc_codegen_ssa/src/mir/operand.rs`, `place.rs`).

use rustc_abi::{BackendRepr, TagEncoding, VariantIdx, Variants};
use rustc_index::IndexVec;
use rustc_middle::mir::{AggregateKind, Operand, Place};
use ryo_bytecode::full::Opcode;

use super::emit::{Width, opw};
use super::place::{Loc, PlaceVal};
use super::{FnCx, NeedsNative, native};

/// A niche-encoded tag (`TagEncoding::Niche`): its slot and width, the untagged variant,
/// the niche variants `start..=end` and the tag value of `start` (truncated to `tw`).
#[derive(Clone, Copy)]
pub struct NicheTag {
    pub slot: u32,
    pub tw: Width,
    pub untagged: u32,
    pub start: u32,
    pub end: u32,
    pub niche_start: u128,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    pub fn aggregate(
        &mut self,
        dst: PlaceVal<'tcx>,
        kind: &AggregateKind<'tcx>,
        ops: &IndexVec<rustc_abi::FieldIdx, Operand<'tcx>>,
    ) -> Result<(), NeedsNative> {
        match *kind {
            AggregateKind::Array(_) => {
                let elem = dst.layout.field(&self.lcx(), 0).size.bytes();
                for (i, op) in ops.iter().enumerate() {
                    self.operand_into(op, dst.loc.offset(i as u64 * elem)?)?;
                }
                Ok(())
            }
            AggregateKind::Tuple | AggregateKind::Closure(..) => {
                for (i, op) in ops.iter_enumerated() {
                    let off = dst.layout.fields.offset(i.as_usize()).bytes();
                    self.operand_into(op, dst.loc.offset(off)?)?;
                }
                Ok(())
            }
            AggregateKind::Adt(def_id, variant, _, _, active_field) => {
                let is_enum = self.tcx.adt_def(def_id).is_enum();
                let layout = if is_enum { dst.layout.for_variant(&self.lcx(), variant) } else { dst.layout };
                for (i, op) in ops.iter_enumerated() {
                    let f = active_field.unwrap_or(i);
                    let off = layout.fields.offset(f.as_usize()).bytes();
                    self.operand_into(op, dst.loc.offset(off)?)?;
                }
                if is_enum { self.set_discriminant(dst, variant) } else { Ok(()) }
            }
            AggregateKind::RawPtr(..) => {
                // Data pointer, then the metadata (a ZST for thin pointers).
                let mut it = ops.iter();
                let (Some(data), Some(meta)) = (it.next(), it.next()) else { return native("RawPtr aggregate arity") };
                self.operand_into(data, dst.loc)?;
                match dst.layout.backend_repr {
                    BackendRepr::ScalarPair { b_offset, .. } => self.operand_into(meta, dst.loc.offset(b_offset.bytes())?),
                    BackendRepr::Scalar(_) => Ok(()),
                    BackendRepr::SimdVector { .. } | BackendRepr::SimdScalableVector { .. } | BackendRepr::Memory { .. } => {
                        native("RawPtr aggregate layout")
                    }
                }
            }
            AggregateKind::Coroutine(..) | AggregateKind::CoroutineClosure(..) => native("coroutine aggregate"),
        }
    }

    /// `Rvalue::Discriminant`: decodes the tag (cg_ssa's `codegen_get_discr`).
    pub fn discriminant(&mut self, dst: PlaceVal<'tcx>, p: Place<'tcx>) -> Result<(), NeedsNative> {
        let pv = self.place(p)?;
        let layout = pv.layout;
        let Some(dw) = Width::of_size(dst.layout.size.bytes()) else { return native("discriminant width") };
        match layout.variants {
            Variants::Empty => Ok(()),
            Variants::Single { index } => {
                let v = layout.ty.discriminant_for_variant(self.tcx, index).map_or(0, |d| d.val);
                self.imm_into(dst.loc, dw, v)
            }
            Variants::Multiple { tag, ref tag_encoding, tag_field, .. } => {
                let tag_layout = layout.field(&self.lcx(), tag_field.as_usize());
                let tag_loc = pv.loc.offset(layout.fields.offset(tag_field.as_usize()).bytes())?;
                let Some(tw) = Width::of_size(tag_layout.size.bytes()) else { return native("tag width") };
                let t = self.loc_slot(tag_loc, tag_layout)?;
                match *tag_encoding {
                    TagEncoding::Direct => {
                        let signed = match tag.primitive() {
                            rustc_abi::Primitive::Int(_, signed) => !tag.is_bool() && signed,
                            rustc_abi::Primitive::Float(_) | rustc_abi::Primitive::Pointer(_) => false,
                        };
                        self.with_place_slot(dst, |fx, d| {
                            fx.int_cast(d, t, tw, dw, signed);
                            Ok(())
                        })
                    }
                    TagEncoding::Niche { untagged_variant, ref niche_variants, niche_start } => {
                        let n = NicheTag {
                            slot: t,
                            tw,
                            untagged: untagged_variant.as_u32(),
                            start: niche_variants.start.as_u32(),
                            end: niche_variants.last.as_u32(),
                            niche_start: tw.truncate(niche_start),
                        };
                        self.with_place_slot(dst, |fx, d| {
                            fx.niche_discr(d, dw, n);
                            Ok(())
                        })
                    }
                }
            }
        }
    }

    /// The niche-encoded tag of the enum at `pv`, if its layout has one.
    pub fn niche_tag(&mut self, pv: PlaceVal<'tcx>) -> Result<Option<NicheTag>, NeedsNative> {
        let layout = pv.layout;
        let Variants::Multiple { tag_encoding: TagEncoding::Niche { untagged_variant, ref niche_variants, niche_start }, tag_field, .. } =
            layout.variants
        else {
            return Ok(None);
        };
        let tag_layout = layout.field(&self.lcx(), tag_field.as_usize());
        let tag_loc = pv.loc.offset(layout.fields.offset(tag_field.as_usize()).bytes())?;
        let Some(tw) = Width::of_size(tag_layout.size.bytes()) else { return native("tag width") };
        let slot = self.loc_slot(tag_loc, tag_layout)?;
        Ok(Some(NicheTag {
            slot,
            tw,
            untagged: untagged_variant.as_u32(),
            start: niche_variants.start.as_u32(),
            end: niche_variants.last.as_u32(),
            niche_start: tw.truncate(niche_start),
        }))
    }

    /// `d` (width `dw`) = the variant index the niche tag `n` encodes, with plain integer ops
    /// (cg_ssa's `codegen_get_discr`): `is_niche = (tag - niche_start) <=u relative_max`, the
    /// value `start + (tag - niche_start)` if so, else `untagged`.
    fn niche_discr(&mut self, d: u32, dw: Width, n: NicheTag) {
        let NicheTag { slot: t, tw, untagged, start, end, niche_start } = n;
        let (u, s) = (u128::from(untagged), u128::from(start));
        let b = self.frame.temp(1, 1);
        if start == end {
            // One niche variant: `is_niche = tag == niche_start`, the value `start`.
            let (cmp, lo) = if u == s + 1 { ("Ne", s) } else { ("Eq", u) };
            self.op_imm(cmp, tw, b, t, niche_start);
            self.int_cast(d, b, Width::W8, dw, false);
            if s.abs_diff(u) == 1 {
                // `d = lo + b`.
                if lo != 0 {
                    self.op_imm("Add", dw, d, d, lo);
                }
                return;
            }
            // `d = ((start ^ untagged) & -b) ^ untagged`.
            self.op(opw("Neg", dw), &[d, d]);
            self.op_imm("And", dw, d, d, s ^ u);
            self.op_imm("Xor", dw, d, d, u);
            return;
        }
        // `r = tag - niche_start`, `b = r <=u relative_max`, `d = start + r` blended with
        // `untagged` by `b`.
        let r = self.frame.temp(u64::from(tw.bytes()), u64::from(tw.bytes()));
        self.op_imm("Sub", tw, r, t, niche_start);
        self.op_imm("LeU", tw, b, r, u128::from(end - start));
        self.int_cast(d, r, tw, dw, false);
        if s != 0 {
            self.op_imm("Add", dw, d, d, s);
        }
        let m = self.frame.temp(u64::from(dw.bytes()), u64::from(dw.bytes()));
        self.int_cast(m, b, Width::W8, dw, false);
        self.op(opw("Neg", dw), &[m, m]);
        self.op_imm("Xor", dw, d, d, u);
        self.op(opw("And", dw), &[d, d, m]);
        self.op_imm("Xor", dw, d, d, u);
    }

    /// Writes the tag of `variant` (cg_ssa's `codegen_set_discr`).
    pub fn set_discriminant(&mut self, pv: PlaceVal<'tcx>, variant: VariantIdx) -> Result<(), NeedsNative> {
        let layout = pv.layout;
        if layout.for_variant(&self.lcx(), variant).is_uninhabited() {
            self.op(Opcode::Abort, &[]);
            return Ok(());
        }
        match layout.variants {
            Variants::Empty => {
                self.op(Opcode::Abort, &[]);
                Ok(())
            }
            Variants::Single { .. } => Ok(()),
            Variants::Multiple { ref tag_encoding, tag_field, .. } => {
                let tag_layout = layout.field(&self.lcx(), tag_field.as_usize());
                let tag_loc = pv.loc.offset(layout.fields.offset(tag_field.as_usize()).bytes())?;
                let Some(tw) = Width::of_size(tag_layout.size.bytes()) else { return native("tag width") };
                let value = match *tag_encoding {
                    TagEncoding::Direct => {
                        let d = layout.ty.discriminant_for_variant(self.tcx, variant);
                        d.ok_or_else(|| NeedsNative("discriminant of a non-enum".into()))?.val
                    }
                    TagEncoding::Niche { untagged_variant, ref niche_variants, niche_start } => {
                        if variant == untagged_variant {
                            return Ok(());
                        }
                        let rel = u128::from(variant.as_u32() - niche_variants.start.as_u32());
                        rel.wrapping_add(niche_start)
                    }
                };
                self.imm_into(tag_loc, tw, tw.truncate(value))
            }
        }
    }

    /// Writes an immediate of width `w` to `loc`.
    pub fn imm_into(&mut self, loc: Loc, w: Width, v: u128) -> Result<(), NeedsNative> {
        self.with_slot(loc, w.bytes(), |fx, d| {
            fx.imm(w, d, w.truncate(v));
            Ok(())
        })
    }
}
