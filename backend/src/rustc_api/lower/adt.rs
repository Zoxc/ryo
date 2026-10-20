//! Aggregates and discriminants (design/lowering.md#rvalues): structs, tuples, closures,
//! arrays and enums, all through `tcx.layout_of`. Mirrors cg_ssa's `codegen_get_discr` and
//! `codegen_tag_value` (`rustc_codegen_ssa/src/mir/operand.rs`, `place.rs`).

use rustc_abi::{BackendRepr, TagEncoding, VariantIdx, Variants};
use rustc_index::IndexVec;
use rustc_middle::mir::{AggregateKind, Operand, Place};
use ryo_bytecode::insn::Opcode;

use super::emit::{Width, imm_words, opw};
use super::place::{Loc, PlaceVal};
use super::{FnCx, NeedsNative, native};

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
                        let v = self.frame.temp(4, 4);
                        let mut ops = vec![v, t];
                        ops.extend(imm_words(tw, niche_start));
                        ops.extend([
                            niche_variants.start.as_u32(),
                            niche_variants.last.as_u32(),
                            untagged_variant.as_u32(),
                        ]);
                        self.op(opw("DiscrNiche", tw), &ops);
                        self.with_place_slot(dst, |fx, d| {
                            fx.int_cast(d, v, Width::W32, dw, false);
                            Ok(())
                        })
                    }
                }
            }
        }
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
