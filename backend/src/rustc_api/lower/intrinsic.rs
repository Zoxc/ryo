//! Intrinsic calls (design/lowering.md#calls, `InstanceKind::Intrinsic`): the matching VM
//! instruction where one exists, else a wrapper island (`catch_unwind`, `compare_bytes`,
//! SIMD), else the generic `call` island for intrinsics that implement `FnOnce`, else the
//! fallback body as an ordinary call. Intrinsics with none of these keep the function native.
//!
//! Most intrinsics never get here: `LowerIntrinsics` turns them into MIR operations
//! (`transmute`, overflow arithmetic, `copy_nonoverlapping`, …).

use rustc_middle::mir::SourceInfo;
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, GenericArg, Instance, Ty};
use ryo_bytecode::full::Opcode;

use super::call::{ArgSrc, CallCont};
use super::cast::ScalarKind;
use super::emit::{FloatWidth, Width, imm_words, opcode, opw, try_opcode};
use super::island::templates;
use super::place::Loc;
use super::{FnCx, NeedsNative, SPLIT_MAX, native};

/// The suffix of an atomic opcode for an ordering.
fn ord_name(o: ty::AtomicOrdering) -> &'static str {
    match o {
        ty::AtomicOrdering::Relaxed => "Relaxed",
        ty::AtomicOrdering::Release => "Release",
        ty::AtomicOrdering::Acquire => "Acquire",
        ty::AtomicOrdering::AcqRel => "Acqrel",
        ty::AtomicOrdering::SeqCst => "Seqcst",
    }
}

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
                let dn = cont.dest.map_or(0, |d| d.layout.size.bytes() as u32);
                self.into_dest(&cont, |fx, d| {
                    fx.island(super::island::templates::CATCH_UNWIND, &[data_ty.into()], &[(try_fn, 8), (data, 8), (catch_fn, 8), (d, dn)], None);
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
                        // The distance is a multiple of `size` (UB otherwise).
                        fx.exact_div_const(Width::W64, signed, d, d, u128::from(size));
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
                let el = self.layout_of(callee.args.type_at(0))?;
                let size = el.size.bytes();
                let copy = name.as_str() == "copy";
                // A constant count: inline pieces.
                if let [x, y, count] = args
                    && let Some(count) = self.arg_const(count)?
                    && let Some(n) = count.checked_mul(u128::from(size))
                    && n <= u128::from(SPLIT_MAX)
                {
                    let (x, n) = (self.arg_slot(x)?, n as u32);
                    if copy {
                        let y = self.arg_slot(y)?;
                        let f = |fx: &mut Self| fx.mem_copy_pieces(y, x, n);
                        if count == 1 { self.with_cuts(el, f) } else { f(self) }
                    } else {
                        let byte = match self.arg_const(y)? {
                            Some(b) => Ok(b as u8),
                            None => Err(self.arg_slot(y)?),
                        };
                        self.mem_set_pieces(x, byte, n);
                    }
                    return self.intrinsic_next(&cont);
                }
                let [x, y, count] = self.arg_slots::<3>(args)?;
                let n = self.temp8();
                self.op(opw("MulImm", Width::W64), &[n, count, size as u32, (size >> 32) as u32]);
                if copy {
                    // copy(src, dst, count)
                    self.op(Opcode::Memmove, &[y, x, n]);
                } else {
                    // write_bytes(dst, val, count)
                    self.op(Opcode::Memset, &[x, y, n]);
                }
                true
            }
            "typed_swap_nonoverlapping" => {
                let el = self.layout_of(callee.args.type_at(0))?;
                let size = el.size.bytes();
                let [x, y] = self.arg_slots::<2>(args)?;
                let t = self.frame.temp(size, 16);
                if size <= u64::from(SPLIT_MAX) {
                    // Inline pieces: `x` into `t`, `y` into `x`, `t` into `y`.
                    let n = size as u32;
                    self.with_cuts(el, |fx| {
                        fx.load_pieces(t, x, n);
                        fx.mem_copy_pieces(x, y, n);
                        fx.store_pieces(y, t, n);
                    });
                    return self.intrinsic_next(&cont);
                }
                let n = self.temp8();
                self.imm(Width::W64, n, u128::from(size));
                self.op(Opcode::LoadCopy, &[t, x, 0, size as u32]);
                self.op(Opcode::Memcpy, &[x, y, n]);
                self.op(Opcode::StoreCopy, &[y, 0, t, size as u32]);
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
                    if family == "Bswap" && w == Width::W8 {
                        // One byte: the identity.
                        fx.mov(d, x, 1);
                    } else {
                        fx.op(opw(family, w), &[d, x]);
                    }
                    Ok(())
                })?
            }
            "rotate_left" | "rotate_right" => {
                let l = self.layout_of(callee.args.type_at(0))?;
                let ScalarKind::Int { w, .. } = self.scalar_kind(l)? else { return native("rotate of a float") };
                let left = name.as_str() == "rotate_left";
                // By a constant (taken mod N): `shl.imm`, `shr.u.imm`, `or`.
                if w != Width::W128
                    && let [x, n] = args
                    && let Some(n) = self.arg_const(n)?
                {
                    let x = self.arg_slot(x)?;
                    let bits = w.bits();
                    let c = (n as u32 % bits) as u128;
                    let c = if left { c } else { (u128::from(bits) - c) % u128::from(bits) };
                    let size = w.bytes();
                    self.into_dest(&cont, |fx, d| {
                        if c == 0 {
                            fx.mov(d, x, size);
                        } else {
                            let t = fx.frame.temp(u64::from(size), u64::from(size));
                            let u = fx.frame.temp(u64::from(size), u64::from(size));
                            fx.op_imm("Shl", w, t, x, c);
                            fx.op_imm("ShrU", w, u, x, u128::from(bits) - c);
                            fx.op(opw("Or", w), &[d, t, u]);
                        }
                        Ok(())
                    })?
                } else {
                    let [x, n] = self.arg_slots::<2>(args)?;
                    let family = if left { "Rotl" } else { "Rotr" };
                    self.into_dest(&cont, |fx, d| {
                        fx.op(opw(family, w), &[d, x, n]);
                        Ok(())
                    })?
                }
            }
            n => self.more_intrinsics(n, callee, args, &cont)?,
        };
        if !done {
            let tcx = self.tcx;
            // Intrinsics that implement `FnOnce` (safe, no `#[track_caller]`): natively,
            // through the `call` template.
            if !self.fn_once_able(fty, callee)
                && let Some(i) = tcx.intrinsic(callee.def_id())
                && !i.must_be_overridden
                // The collector skips the fallback bodies of intrinsics the backend replaces
                // (`rustc_monomorphize/src/collector.rs:1016`), so such a body has no symbol
                // unless it is one of our VM functions anyway.
                && let fallback = Instance::new_raw(callee.def_id(), callee.args)
                && (!tcx.sess.replaced_intrinsics.contains(&i.name) || self.cx.vm.contains(&fallback))
            {
                // The fallback body, as cg_ssa's `IntrinsicResult::Fallback`: an ordinary
                // instance, a VM function if the collector found it.
                let fty = Ty::new_fn_def(tcx, callee.def_id(), ty::Binder::dummy(callee.args));
                return self.direct_call(fty, fallback, args, cont, source_info);
            }
            return self.direct_call(fty, callee, args, cont, source_info);
        }
        self.intrinsic_next(&cont)
    }

    /// Continues after a lowered intrinsic: to the call's target block.
    fn intrinsic_next(&mut self, cont: &CallCont<'tcx>) -> Result<(), NeedsNative> {
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
            _ => {
                // A struct with an unsized tail (place.rs).
                let (s, a) = self.size_and_align_of_dst(layout, Some(p + 8))?;
                let v = self.dyn_slot(if size { s } else { a });
                self.into_dest(cont, |fx, d| {
                    fx.mov(d, v, 8);
                    Ok(())
                })
            }
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

    /// Intrinsics beyond the first set: VM instructions where they exist, otherwise wrapper
    /// islands. Returns whether `name` was lowered.
    fn more_intrinsics(&mut self, name: &str, callee: Instance<'tcx>, args: &[ArgSrc<'_, 'tcx>], cont: &CallCont<'tcx>) -> Result<bool, NeedsNative> {
        let ty0 = || callee.args.type_at(0);
        Ok(match name {
            "cold_path" => true,
            "black_box" | "likely" | "unlikely" => {
                let [x] = self.arg_slots::<1>(args)?;
                let size = cont.dest.map_or(0, |d| d.layout.size.bytes() as u32);
                self.into_dest(cont, |fx, d| {
                    fx.mov(d, x, size);
                    Ok(())
                })?
            }
            "volatile_load" | "unaligned_volatile_load" => {
                let size = self.layout_of(ty0())?.size.bytes() as u32;
                let [p] = self.arg_slots::<1>(args)?;
                self.into_dest(cont, |fx, d| {
                    fx.load(d, Loc::Mem { p, k: 0 }, size);
                    Ok(())
                })?
            }
            "volatile_store" | "unaligned_volatile_store" | "nontemporal_store" => {
                let size = self.layout_of(ty0())?.size.bytes() as u32;
                let [p, v] = self.arg_slots::<2>(args)?;
                self.store(Loc::Mem { p, k: 0 }, v, size);
                true
            }
            "volatile_copy_memory" | "volatile_copy_nonoverlapping_memory" | "volatile_set_memory" => {
                let size = self.layout_of(ty0())?.size.bytes();
                let [x, y, count] = self.arg_slots::<3>(args)?;
                let n = self.temp8();
                let mut ops = vec![n, count];
                ops.extend(imm_words(Width::W64, u128::from(size)));
                self.op(opw("MulImm", Width::W64), &ops);
                let op = match name {
                    "volatile_copy_memory" => Opcode::Memmove,
                    "volatile_copy_nonoverlapping_memory" => Opcode::Memcpy,
                    _ => Opcode::Memset,
                };
                self.op(op, &[x, y, n]);
                true
            }
            "exact_div" | "disjoint_bitor" => {
                let l = self.layout_of(ty0())?;
                let ScalarKind::Int { w, signed } = self.scalar_kind(l)? else { return native("float exact_div") };
                if name == "exact_div" && w == Width::W128 {
                    return native("128-bit mul/div/rem (island)");
                }
                if name == "exact_div"
                    && let [a, b] = args
                    && let Some(v) = self.arg_const(b)?
                    && w.truncate(v) != 0
                {
                    let a = self.arg_slot(a)?;
                    return self.into_dest(cont, |fx, d| {
                        fx.exact_div_const(w, signed, d, a, v);
                        Ok(())
                    });
                }
                let [a, b] = self.arg_slots::<2>(args)?;
                let family = match (name, signed) {
                    ("exact_div", true) => "DivS",
                    ("exact_div", false) => "DivU",
                    _ => "Or",
                };
                self.into_dest(cont, |fx, d| {
                    fx.op(opw(family, w), &[d, a, b]);
                    Ok(())
                })?
            }
            "ptr_guaranteed_cmp" => {
                // At run time the addresses are known: 1 if equal, 0 if not (never 2,
                // "unknown").
                let [a, b] = self.arg_slots::<2>(args)?;
                self.into_dest(cont, |fx, d| {
                    fx.op(opw("Eq", Width::W64), &[d, a, b]);
                    Ok(())
                })?
            }
            "vtable_size" | "vtable_align" => {
                let [p] = self.arg_slots::<1>(args)?;
                let idx = if name == "vtable_size" { ty::COMMON_VTABLE_ENTRIES_SIZE } else { ty::COMMON_VTABLE_ENTRIES_ALIGN };
                self.into_dest(cont, |fx, d| {
                    fx.op(opcode("LoadW64"), &[d, p, idx as u32 * 8]);
                    Ok(())
                })?
            }
            "unchecked_funnel_shl" | "unchecked_funnel_shr" => {
                let l = self.layout_of(ty0())?;
                let ScalarKind::Int { w, .. } = self.scalar_kind(l)? else { return native("funnel shift of a float") };
                let [a, b, s] = self.arg_slots::<3>(args)?;
                self.funnel_shift(name == "unchecked_funnel_shl", w, a, b, s, cont)?
            }
            "fabs"
            | "copysignf32"
            | "copysignf64"
            | "minimum_number_nsz_f32"
            | "minimum_number_nsz_f64"
            | "maximum_number_nsz_f32"
            | "maximum_number_nsz_f64" => {
                let Some(dest) = cont.dest else { return native("intrinsic without a destination") };
                // f16/f128 go through the `call` template.
                let fw = match dest.layout.ty.kind() {
                    ty::Float(ty::FloatTy::F32) => FloatWidth::F32,
                    ty::Float(ty::FloatTy::F64) => FloatWidth::F64,
                    _ => return Ok(false),
                };
                let family = match name {
                    "fabs" => "Fabs",
                    "copysignf32" | "copysignf64" => "Copysign",
                    n if n.starts_with("minimum") => "Fmin",
                    _ => "Fmax",
                };
                let op = opcode(&format!("{family}{}", fw.suffix()));
                if name == "fabs" {
                    let [x] = self.arg_slots::<1>(args)?;
                    self.into_dest(cont, |fx, d| {
                        fx.op(op, &[d, x]);
                        Ok(())
                    })?
                } else {
                    let [x, y] = self.arg_slots::<2>(args)?;
                    self.into_dest(cont, |fx, d| {
                        fx.op(op, &[d, x, y]);
                        Ok(())
                    })?
                }
            }
            n if n.starts_with("atomic_") => self.atomic(n, callee, args, cont)?,
            "compare_bytes" => {
                if args.len() != 3 {
                    return native("intrinsic argument count");
                }
                let ins = self.island_args(args)?;
                self.wrapper(templates::COMPARE_BYTES, &[], &ins, cont)?
            }
            "raw_eq" => {
                if args.len() != 2 {
                    return native("intrinsic argument count");
                }
                let ins = self.island_args(args)?;
                self.wrapper(templates::RAW_EQ, &[ty0().into()], &ins, cont)?
            }
            n if n.starts_with("simd_") => {
                let Some(arity) = templates::simd(n) else { return Ok(false) };
                let ins = self.island_args(args)?;
                if ins.len() != arity {
                    return native("intrinsic argument count");
                }
                let generics: Vec<GenericArg<'tcx>> = callee.args.iter().collect();
                if generics.iter().any(|g| g.as_type().is_none()) {
                    return Ok(false);
                }
                self.wrapper(&format!("ryo_island_{n}"), &generics, &ins, cont)?
            }
            _ => false,
        })
    }

    /// An intrinsic wrapper island: `ops` = the inputs, then the destination (each a slot and
    /// its size).
    fn wrapper(&mut self, template: &str, generics: &[GenericArg<'tcx>], ins: &[(u32, u32)], cont: &CallCont<'tcx>) -> Result<bool, NeedsNative> {
        let ins = ins.to_vec();
        let dn = cont.dest.map_or(0, |d| d.layout.size.bytes() as u32);
        self.into_dest(cont, |fx, d| {
            let mut ops = ins;
            ops.push((d, dn));
            fx.island(template, generics, &ops, None);
            Ok(())
        })
    }

    /// `unchecked_funnel_shl(a, b, s)` = `(a << s) | ((b >> 1) >> (bits - 1 - s))` and
    /// `unchecked_funnel_shr(a, b, s)` = `((a << 1) << (bits - 1 - s)) | (b >> s)`, `s < bits`
    /// (the split shift avoids a shift by `bits` when `s` is 0).
    fn funnel_shift(&mut self, left: bool, w: Width, a: u32, b: u32, s: u32, cont: &CallCont<'tcx>) -> Result<bool, NeedsNative> {
        let size = u64::from(w.bytes());
        let al = size.min(16);
        let amount = |fx: &mut Self, s32: u32| -> u32 {
            if w == Width::W32 {
                return s32;
            }
            let t = fx.frame.temp(size, al);
            fx.int_cast(t, s32, Width::W32, w, false);
            t
        };
        let s = amount(self, s);
        // r = bits - 1 - s
        let r = self.frame.temp(size, al);
        self.imm(w, r, u128::from(w.bits() - 1));
        self.op(opw("Sub", w), &[r, r, s]);
        let (x, y) = (self.frame.temp(size, al), self.frame.temp(size, al));
        let one = imm_words(w, 1);
        if left {
            self.op(opw("Shl", w), &[x, a, s]);
            let mut ops = vec![y, b];
            ops.extend(one);
            self.op(opw("ShrUImm", w), &ops);
            self.op(opw("ShrU", w), &[y, y, r]);
        } else {
            let mut ops = vec![x, a];
            ops.extend(one);
            self.op(opw("ShlImm", w), &ops);
            self.op(opw("Shl", w), &[x, x, r]);
            self.op(opw("ShrU", w), &[y, b, s]);
        }
        self.into_dest(cont, |fx, d| {
            fx.op(opw("Or", w), &[d, x, y]);
            Ok(())
        })
    }

    /// `atomic_*` intrinsics: the VM's atomic instructions. An ordering combination the VM
    /// doesn't have uses `SeqCst`, which is stronger than any other.
    fn atomic(&mut self, name: &str, callee: Instance<'tcx>, args: &[ArgSrc<'_, 'tcx>], cont: &CallCont<'tcx>) -> Result<bool, NeedsNative> {
        let ord = |i: usize| ord_name(callee.args.const_at(i).to_value().to_branch()[0].to_leaf().to_atomic_ordering());
        let pick = |base: String, ords: &[&str]| -> Result<Opcode, NeedsNative> {
            let exact = format!("{base}{}", ords.concat());
            let strong = format!("{base}{}", vec!["Seqcst"; ords.len()].concat());
            try_opcode(&exact).or_else(|| try_opcode(&strong)).ok_or_else(|| NeedsNative(format!("no opcode {exact}")))
        };
        if name == "atomic_fence" || name == "atomic_singlethreadfence" {
            let base = if name == "atomic_fence" { "Fence" } else { "CompilerFence" };
            let op = pick(base.to_owned(), &[ord(0)])?;
            self.op(op, &[]);
            return Ok(true);
        }
        let ty = callee.args.type_at(0);
        let l = self.layout_of(ty)?;
        let Some(w) = Width::of_size(l.size.bytes()).filter(|&w| w != Width::W128) else {
            return native("128-bit atomic");
        };
        // A thin raw pointer uses the `ptr` forms, whose value is a pointer, not an integer
        // (provenance kept, lean/docs/reduced.md §D.1); they have no `nand`, `min` or `max`.
        let ws = if ty.is_raw_ptr() { "Ptr" } else { w.suffix() };
        let rmw = |op: &str| match op {
            "atomic_xchg" => Some(("Xchg", 1)),
            "atomic_xadd" => Some(("Add", 2)),
            "atomic_xsub" => Some(("Sub", 2)),
            "atomic_and" => Some(("And", 2)),
            "atomic_nand" => Some(("Nand", 2)),
            "atomic_or" => Some(("Or", 2)),
            "atomic_xor" => Some(("Xor", 2)),
            "atomic_max" => Some(("Max", 1)),
            "atomic_min" => Some(("Min", 1)),
            "atomic_umax" => Some(("Umax", 1)),
            "atomic_umin" => Some(("Umin", 1)),
            _ => None,
        };
        match name {
            "atomic_load" => {
                let op = pick(format!("AtomicLoad{ws}"), &[ord(1)])?;
                let [p] = self.arg_slots::<1>(args)?;
                self.into_dest(cont, |fx, d| {
                    fx.op(op, &[d, p]);
                    Ok(())
                })
            }
            "atomic_store" => {
                let op = pick(format!("AtomicStore{ws}"), &[ord(1)])?;
                let [p, v] = self.arg_slots::<2>(args)?;
                self.op(op, &[p, v]);
                Ok(true)
            }
            "atomic_cxchg" | "atomic_cxchgweak" => {
                let weak = if name == "atomic_cxchgweak" { "Weak" } else { "" };
                let op = pick(format!("AtomicCxchg{weak}{ws}"), &[ord(1), ord(2)])?;
                let [p, old, new] = self.arg_slots::<3>(args)?;
                let Some(dest) = cont.dest else { return native("intrinsic without a destination") };
                let (o0, o1) = (dest.layout.fields.offset(0).bytes() as u32, dest.layout.fields.offset(1).bytes() as u32);
                self.into_dest(cont, |fx, d| {
                    fx.op(op, &[d + o0, d + o1, p, old, new]);
                    Ok(())
                })
            }
            n => match rmw(n) {
                Some((family, ord_at)) => {
                    let op = pick(format!("Atomic{family}{ws}"), &[ord(ord_at)])?;
                    let [p, v] = self.arg_slots::<2>(args)?;
                    self.into_dest(cont, |fx, d| {
                        fx.op(op, &[d, p, v]);
                        Ok(())
                    })
                }
                None => Ok(false),
            },
        }
    }

    /// The arguments in frame slots, any number.
    /// The arguments in frame slots, each with its size, as island operands (a slot given as
    /// one is a receiver's data pointer).
    fn island_args(&mut self, args: &[ArgSrc<'_, 'tcx>]) -> Result<Vec<(u32, u32)>, NeedsNative> {
        args.iter()
            .map(|a| match *a {
                ArgSrc::Operand(op) => self.operand_slot(op).map(|(s, l)| (s, l.size.bytes() as u32)),
                ArgSrc::Slot(s) => Ok((s, 8)),
            })
            .collect()
    }

    /// The arguments in frame slots.
    fn arg_slots<const N: usize>(&mut self, args: &[ArgSrc<'_, 'tcx>]) -> Result<[u32; N], NeedsNative> {
        if args.len() != N {
            return native("intrinsic argument count");
        }
        let mut out = [0; N];
        for (o, a) in out.iter_mut().zip(args) {
            *o = self.arg_slot(a)?;
        }
        Ok(out)
    }

    /// An argument in a frame slot.
    fn arg_slot(&mut self, a: &ArgSrc<'_, 'tcx>) -> Result<u32, NeedsNative> {
        Ok(match *a {
            ArgSrc::Operand(op) => self.operand_slot(op)?.0,
            ArgSrc::Slot(s) => s,
        })
    }

    /// The value of an argument if it is an integer constant.
    fn arg_const(&self, a: &ArgSrc<'_, 'tcx>) -> Result<Option<u128>, NeedsNative> {
        match *a {
            ArgSrc::Operand(op) => self.const_int(op),
            ArgSrc::Slot(_) => Ok(None),
        }
    }

    /// `d = a / v` for a nonzero constant `v` (w8-w64) that divides `a` exactly
    /// (`exact_div`, `ptr_offset_from`; UB otherwise): with `|v| = 2^k * m`, `m` odd, a shift
    /// by `k` and a multiply by the inverse of `m` mod 2^N (negated for a negative `v`).
    fn exact_div_const(&mut self, w: Width, signed: bool, d: u32, a: u32, v: u128) {
        let v = w.truncate(v);
        let neg = signed && v >> (w.bits() - 1) & 1 == 1;
        let mag = if neg { w.truncate(v.wrapping_neg()) } else { v };
        let k = mag.trailing_zeros();
        let m = mag >> k;
        // Newton's iteration doubles the correct low bits; `m` is its own inverse mod 8.
        let mut inv = m;
        for _ in 0..6 {
            inv = inv.wrapping_mul(2u128.wrapping_sub(m.wrapping_mul(inv)));
        }
        let c = w.truncate(if neg { inv.wrapping_neg() } else { inv });
        let mut src = a;
        if k > 0 {
            self.op_imm(if signed { "ShrS" } else { "ShrU" }, w, d, a, u128::from(k));
            src = d;
        }
        if c != 1 {
            self.op_imm("Mul", w, d, src, c);
        } else {
            self.mov(d, src, w.bytes());
        }
    }

    fn dest_width(&self, cont: &CallCont<'tcx>) -> Result<Width, NeedsNative> {
        let size = cont.dest.map_or(0, |d| d.layout.size.bytes());
        Width::of_size(size).ok_or_else(|| NeedsNative("intrinsic result width".into()))
    }

    /// Runs `f` with a slot standing for the call's destination. Returns `true` (handled).
    fn into_dest(&mut self, cont: &CallCont<'tcx>, f: impl FnOnce(&mut Self, u32) -> Result<(), NeedsNative>) -> Result<bool, NeedsNative> {
        let Some(dest) = cont.dest else { return native("intrinsic without a destination") };
        self.with_place_slot(dest, f)?;
        Ok(true)
    }
}
