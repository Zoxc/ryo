//! Intrinsic calls (design/lowering.md#calls, `InstanceKind::Intrinsic`): the matching VM
//! instruction where one exists, otherwise the generic `call` island for safe intrinsics.
//! Unsafe intrinsics without a VM lowering or a wrapper template keep the function native.
//!
//! Most intrinsics never get here: `LowerIntrinsics` turns them into MIR operations
//! (`transmute`, overflow arithmetic, `copy_nonoverlapping`, …).

use rustc_middle::mir::SourceInfo;
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, Instance, Ty};
use ryo_bytecode::insn::Opcode;

use super::call::{ArgSrc, CallCont};
use super::cast::ScalarKind;
use super::emit::{Width, imm_words, opcode, opw};
use super::{FnCx, NeedsNative, native};

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    pub fn intrinsic_call(
        &mut self,
        callee: Instance<'tcx>,
        fty: Ty<'tcx>,
        args: &[ArgSrc<'_, 'tcx>],
        cont: CallCont<'tcx>,
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let name = self.tcx.item_name(callee.def_id());
        let done = match name.as_str() {
            "caller_location" => self.into_dest(&cont, |fx, d| fx.caller_location_into(source_info, d))?,
            "catch_unwind" => {
                // `rustc_nounwind`: a plain island (design/lowering.md#unwinding).
                let [try_fn, data, catch_fn] = self.arg_slots::<3>(args)?;
                let data_ty = callee.args.type_at(0);
                self.into_dest(&cont, |fx, d| {
                    fx.island(super::island::templates::CATCH_UNWIND, &[data_ty.into()], &[try_fn, data, catch_fn, d], None);
                    Ok(())
                })?
            }
            "abort" => {
                self.op(Opcode::Abort, &[]);
                return Ok(());
            }
            "ptr_offset_from" | "ptr_offset_from_unsigned" => {
                let size = self.layout_of(callee.args.type_at(0))?.size.bytes();
                let [a, b] = self.arg_slots::<2>(args)?;
                let signed = name.as_str() == "ptr_offset_from";
                self.into_dest(&cont, |fx, d| {
                    fx.op(opw("Sub", Width::W64), &[d, a, b]);
                    if size > 1 {
                        let t = fx.temp8();
                        fx.imm(Width::W64, t, u128::from(size));
                        let div = if signed { "DivS" } else { "DivU" };
                        fx.op(opw(div, Width::W64), &[d, d, t]);
                    }
                    Ok(())
                })?
            }
            "arith_offset" => {
                let size = self.layout_of(callee.args.type_at(0))?.size.bytes();
                let stride = u32::try_from(size).map_err(|_| NeedsNative("stride above 4 GiB".into()))?;
                let [p, n] = self.arg_slots::<2>(args)?;
                self.into_dest(&cont, |fx, d| {
                    fx.op(Opcode::PtrIndex, &[d, p, n, stride]);
                    Ok(())
                })?
            }
            "copy" | "write_bytes" => {
                let size = self.layout_of(callee.args.type_at(0))?.size.bytes();
                let [x, y, count] = self.arg_slots::<3>(args)?;
                let n = self.temp8();
                self.op(opw("MulImm", Width::W64), &[n, count, size as u32, (size >> 32) as u32]);
                if name.as_str() == "copy" {
                    // copy(src, dst, count)
                    self.op(Opcode::Memmove, &[y, x, n]);
                } else {
                    // write_bytes(dst, val, count)
                    self.op(Opcode::Memset, &[x, y, n]);
                }
                true
            }
            "typed_swap_nonoverlapping" => {
                let size = self.layout_of(callee.args.type_at(0))?.size.bytes();
                let [x, y] = self.arg_slots::<2>(args)?;
                let t = self.frame.temp(size, 16);
                let n = self.temp8();
                self.imm(Width::W64, n, u128::from(size));
                self.op(Opcode::LoadCopyZ, &[t, x, size as u32]);
                self.op(Opcode::Memcpy, &[x, y, n]);
                self.op(Opcode::StoreCopyZ, &[y, t, size as u32]);
                true
            }
            "size_of_val" | "align_of_val" => {
                let t = callee.args.type_at(0);
                let [p] = self.arg_slots::<1>(args)?;
                let size = name.as_str() == "size_of_val";
                self.size_or_align_of_val(t, p, size, &cont)?
            }
            "ctpop" | "ctlz" | "cttz" | "ctlz_nonzero" | "cttz_nonzero" => {
                let family = match name.as_str() {
                    "ctpop" => "Ctpop",
                    "ctlz" | "ctlz_nonzero" => "Ctlz",
                    _ => "Cttz",
                };
                let l = self.layout_of(callee.args.type_at(0))?;
                let ScalarKind::Int { w, .. } = self.scalar_kind(l)? else { return native("count of a float") };
                let [x] = self.arg_slots::<1>(args)?;
                let r = self.frame.temp(4, 4);
                self.op(opw(family, w), &[r, x]);
                let dw = self.dest_width(&cont)?;
                self.into_dest(&cont, |fx, d| {
                    fx.int_cast(d, r, Width::W32, dw, false);
                    Ok(())
                })?
            }
            "bswap" | "bitreverse" => {
                let l = self.layout_of(callee.args.type_at(0))?;
                let ScalarKind::Int { w, .. } = self.scalar_kind(l)? else { return native("bswap of a float") };
                let [x] = self.arg_slots::<1>(args)?;
                let family = if name.as_str() == "bswap" { "Bswap" } else { "Bitreverse" };
                self.into_dest(&cont, |fx, d| {
                    fx.op(opw(family, w), &[d, x]);
                    Ok(())
                })?
            }
            "rotate_left" | "rotate_right" => {
                let l = self.layout_of(callee.args.type_at(0))?;
                let ScalarKind::Int { w, .. } = self.scalar_kind(l)? else { return native("rotate of a float") };
                let [x, n] = self.arg_slots::<2>(args)?;
                let family = if name.as_str() == "rotate_left" { "Rotl" } else { "Rotr" };
                self.into_dest(&cont, |fx, d| {
                    fx.op(opw(family, w), &[d, x, n]);
                    Ok(())
                })?
            }
            _ => false,
        };
        if !done {
            return self.direct_call(fty, callee, args, cont, source_info);
        }
        match cont.target {
            Some(bb) => self.jump(bb),
            None => {
                self.op(Opcode::Unreachable, &[]);
            }
        }
        Ok(())
    }

    /// `size_of_val` / `align_of_val` of the `T` behind the pointer in slot `p` (wide for
    /// unsized `T`): static for sized types, from the length for slices and `str`, from the
    /// vtable for trait objects.
    fn size_or_align_of_val(&mut self, t: Ty<'tcx>, p: u32, size: bool, cont: &CallCont<'tcx>) -> Result<bool, NeedsNative> {
        let layout = self.layout_of(t)?;
        if layout.is_sized() {
            let v = if size { layout.size.bytes() } else { layout.align.abi.bytes() };
            self.into_dest(cont, |fx, d| {
                fx.imm(Width::W64, d, u128::from(v));
                Ok(())
            })?;
            return Ok(true);
        }
        match t.kind() {
            ty::Slice(e) | ty::Array(e, _) => {
                let el = self.layout_of(*e)?;
                self.slice_size_or_align(el, p, size, cont)
            }
            ty::Str => {
                let el = self.layout_of(self.tcx.types.u8)?;
                self.slice_size_or_align(el, p, size, cont)
            }
            ty::Dynamic(..) => {
                // vtable entries 1 and 2: size, align.
                let idx: u32 = if size { 1 } else { 2 };
                self.into_dest(cont, |fx, d| {
                    fx.op(opcode("LoadW64"), &[d, p + 8, idx * 8]);
                    Ok(())
                })?;
                Ok(true)
            }
            _ => native("size_of_val of a struct with an unsized tail"),
        }
    }

    fn slice_size_or_align(&mut self, el: TyAndLayout<'tcx>, p: u32, size: bool, cont: &CallCont<'tcx>) -> Result<bool, NeedsNative> {
        let (s, a) = (el.size.bytes(), el.align.abi.bytes());
        self.into_dest(cont, |fx, d| {
            if size {
                let mut ops = vec![d, p + 8];
                ops.extend(imm_words(Width::W64, u128::from(s)));
                fx.op(opw("MulImm", Width::W64), &ops);
            } else {
                fx.imm(Width::W64, d, u128::from(a));
            }
            Ok(())
        })?;
        Ok(true)
    }

    /// The arguments in frame slots.
    fn arg_slots<const N: usize>(&mut self, args: &[ArgSrc<'_, 'tcx>]) -> Result<[u32; N], NeedsNative> {
        if args.len() != N {
            return native("intrinsic argument count");
        }
        let mut out = [0; N];
        for (o, a) in out.iter_mut().zip(args) {
            *o = match *a {
                ArgSrc::Operand(op) => self.operand_slot(op)?.0,
                ArgSrc::Slot(s) => s,
            };
        }
        Ok(out)
    }

    fn dest_width(&self, cont: &CallCont<'tcx>) -> Result<Width, NeedsNative> {
        let size = cont.dest.map_or(0, |d| d.layout.size.bytes());
        Width::of_size(size).ok_or_else(|| NeedsNative("intrinsic result width".into()))
    }

    /// Runs `f` with a slot standing for the call's destination. Returns `true` (handled).
    fn into_dest(
        &mut self,
        cont: &CallCont<'tcx>,
        f: impl FnOnce(&mut Self, u32) -> Result<(), NeedsNative>,
    ) -> Result<bool, NeedsNative> {
        let Some(dest) = cont.dest else { return native("intrinsic without a destination") };
        self.with_place_slot(dest, f)?;
        Ok(true)
    }
}
