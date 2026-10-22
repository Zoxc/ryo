//! Calls and drops (design/lowering.md#calls, design/stubs.md#calls-between-vm-and-native-code).
//!
//! A direct call of a resolved instance is, in order of preference:
//!
//! - `call fn`: a VM function of this image ([`LowerCx::vm`])
//! - `call.ext sym, site, call_ptrN, f`: a Rust-ABI instance from another crate (one
//!   `should_codegen_locally` says isn't codegened here); `f` is the slot the native path
//!   passes the resolved address in
//! - `island call<F, Args, R>`: a safe Rust fn item (through `FnOnce`, no symbol needed)
//! - `addr.sym` + `island call_ptrN` / `call_cN`: any other local native function
//!
//! Fn-pointer calls and virtual calls (`InstanceKind::Virtual`, the fn pointer loaded from
//! the receiver's vtable) are `call.ind` (Rust ABI) or a `call_cN` island. `become` is
//! `tail_call` / `tail_call.ind`.
//!
//! Arguments are written to the outgoing argument block just before the call. For a
//! `#[track_caller]` callee the caller location is appended (design/lowering.md#caller-location).
//!
//! [`LowerCx::vm`]: super::LowerCx::vm

use rustc_abi::{BackendRepr, ExternAbi};
use rustc_middle::mir::{BasicBlock, Operand, Place, SourceInfo, UnwindAction};
use rustc_middle::ty::{self, GenericArg, Instance, InstanceKind, Ty, TypingEnv};
use rustc_span::Spanned;
use ryo_bytecode::abi::HEADER_SIZE;
use ryo_bytecode::asm::ret_in_regs;
use ryo_bytecode::insn::Opcode;

use super::frame;
use super::island::templates;
use super::place::{Loc, PlaceVal};
use super::emit::opcode;
use super::sig::{AbiSig, CallConv, abi_sig, fn_ptr_sig, tys_sig, virtual_sig};
use super::{CodeReloc, FnCx, NeedsNative, native, no_trim};

/// Where an argument comes from.
#[derive(Clone, Copy)]
pub enum ArgSrc<'b, 'tcx> {
    Operand(&'b Operand<'tcx>),
    /// A value already in a frame slot.
    Slot(u32),
}

/// How a call reaches its callee.
#[derive(Clone, Copy)]
enum Target<'tcx> {
    /// `call fn` / `tail_call fn`: a VM function of this image.
    Vm(Instance<'tcx>),
    /// `call.ext sym`: a Rust-ABI instance from another crate.
    Ext(Instance<'tcx>),
    /// `island call<F, Args, R>`: a safe Rust fn item `F`, through `FnOnce`.
    Template(Ty<'tcx>),
    /// `addr.sym` of a local native instance, then a fn-pointer island.
    Sym(Instance<'tcx>, CallConv),
    /// The fn pointer in this slot: `call.ind` (Rust ABI) or a `call_cN` island. Fn-pointer
    /// calls and virtual calls (the pointer loaded from the vtable).
    Ptr(u32, CallConv),
}

/// What happens after a call: where the value goes and where control goes.
pub struct CallCont<'tcx> {
    pub dest: Option<PlaceVal<'tcx>>,
    pub target: Option<BasicBlock>,
    pub unwind: UnwindAction,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// `TerminatorKind::Call`.
    pub fn call_terminator(
        &mut self,
        func: &Operand<'tcx>,
        args: &[Spanned<Operand<'tcx>>],
        destination: Place<'tcx>,
        target: Option<BasicBlock>,
        unwind: UnwindAction,
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let fty = self.mono(func.ty(self.body, tcx));
        let dest = self.place(destination)?;
        let cont = CallCont { dest: Some(dest), target, unwind };
        let srcs: Vec<ArgSrc<'_, 'tcx>> = args.iter().map(|a| ArgSrc::Operand(&a.node)).collect();
        match *fty.kind() {
            ty::FnDef(def_id, fn_args) => {
                let fn_args = fn_args.no_bound_vars().expect("monomorphic callee");
                let callee =
                    Instance::expect_resolve(tcx, TypingEnv::fully_monomorphized(), def_id, fn_args, source_info.span);
                match callee.def {
                    InstanceKind::Intrinsic(_) => self.intrinsic_call(callee, fty, &srcs, cont, source_info),
                    InstanceKind::LlvmIntrinsic(_) => native("call of an LLVM intrinsic"),
                    InstanceKind::Item(_) | InstanceKind::Virtual(..) | InstanceKind::Shim(_) => {
                        self.direct_call(fty, callee, &srcs, cont, source_info)
                    }
                }
            }
            ty::FnPtr(..) => self.indirect_call(func, fty, &srcs, cont, source_info),
            _ => native("call of a non-fn type"),
        }
    }

    /// A call of the resolved `callee`, whose fn item type is `fty`.
    pub fn direct_call(
        &mut self,
        fty: Ty<'tcx>,
        callee: Instance<'tcx>,
        args: &[ArgSrc<'_, 'tcx>],
        cont: CallCont<'tcx>,
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let (target, sig, args) = self.direct_target(fty, callee, args, false)?;
        self.write_args(&sig, &args, source_info)?;
        self.emit_call(target, &sig, cont)
    }

    /// A call through a fn pointer: `call.ind` (Rust ABI) or a `call_cN` island.
    fn indirect_call(
        &mut self,
        func: &Operand<'tcx>,
        fty: Ty<'tcx>,
        args: &[ArgSrc<'_, 'tcx>],
        cont: CallCont<'tcx>,
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let (target, sig) = self.ptr_target(func, fty)?;
        self.write_args(&sig, args, source_info)?;
        self.emit_call(target, &sig, cont)
    }

    /// How to reach the resolved `callee` (fn item type `fty`), its signature, and the
    /// arguments as the signature takes them (a virtual call passes the receiver's data
    /// pointer). With `tail`, a callee with a symbol is never called through the `call`
    /// template, which can't be a tail call.
    fn direct_target<'b>(
        &mut self,
        fty: Ty<'tcx>,
        callee: Instance<'tcx>,
        args: &[ArgSrc<'b, 'tcx>],
        tail: bool,
    ) -> Result<(Target<'tcx>, AbiSig<'tcx>, Vec<ArgSrc<'b, 'tcx>>), NeedsNative> {
        let tcx = self.tcx;
        let rust_call = fty.fn_sig(tcx).abi() == ExternAbi::RustCall;
        let mut args = args.to_vec();
        if let InstanceKind::Virtual(_, idx) = callee.def {
            let Some(&recv) = args.first() else { return native("virtual call without a receiver") };
            let (data, vtable, recv_ty) = self.receiver(recv, tail)?;
            let mut sig = virtual_sig(tcx, callee, recv_ty)?;
            sig.rust_call = rust_call;
            // The method's entry in the vtable (`VirtualIndex::get_fn`).
            let f = self.temp8();
            let k = u32::try_from(idx * 8).map_err(|_| NeedsNative("vtable index".into()))?;
            self.op(opcode("LoadW64"), &[f, vtable, k]);
            args[0] = ArgSrc::Slot(data);
            return Ok((Target::Ptr(f, sig.conv), sig, args));
        }
        let has_symbol = !matches!(callee.def, InstanceKind::Intrinsic(_));
        // The callee's ABI signature, if computed to pick the target (reused below).
        let mut callee_sig = None;
        let target = if self.cx.vm.contains(&callee) {
            Target::Vm(callee)
        } else if !has_symbol {
            if tail || !self.fn_once_able(fty, callee) {
                return native(no_trim(|| format!("call of {callee} (needs an intrinsic wrapper)")));
            }
            Target::Template(fty)
        } else {
            let sig = abi_sig(tcx, callee)?;
            let target = match sig.conv {
                CallConv::Rust if !tcx.should_codegen_locally(callee) => Target::Ext(callee),
                CallConv::Rust if !tail && self.fn_once_able(fty, callee) => Target::Template(fty),
                conv => Target::Sym(callee, conv),
            };
            callee_sig = Some(sig);
            target
        };
        let sig = match target {
            Target::Template(_) => {
                let s = tcx.normalize_erasing_late_bound_regions(TypingEnv::fully_monomorphized(), fty.fn_sig(tcx));
                tys_sig(tcx, s.inputs().to_vec(), s.output())?
            }
            Target::Vm(_) | Target::Ext(_) | Target::Sym(..) | Target::Ptr(..) => {
                let mut sig = match callee_sig {
                    Some(sig) => sig,
                    None => abi_sig(tcx, callee)?,
                };
                sig.rust_call = rust_call;
                sig
            }
        };
        Ok((target, sig, args))
    }

    /// The target and signature of a call through the fn pointer `func` of type `fty`.
    fn ptr_target(&mut self, func: &Operand<'tcx>, fty: Ty<'tcx>) -> Result<(Target<'tcx>, AbiSig<'tcx>), NeedsNative> {
        let mut sig = fn_ptr_sig(self.tcx, fty.fn_sig(self.tcx))?;
        sig.rust_call = fty.fn_sig(self.tcx).abi() == ExternAbi::RustCall;
        let (p, _) = self.operand_slot(func)?;
        Ok((Target::Ptr(p, sig.conv), sig))
    }

    /// The receiver of a virtual call: the slots holding its data pointer and its vtable, and
    /// the thin receiver type the signature uses ([`virtual_sig`]). As cg_ssa does
    /// (`codegen_call_terminator`), a wrapper (`Box`, `Rc`, `Pin`, …) is peeled down to its
    /// one non-1-ZST field until a pointer remains, and an unsized by-value receiver (a
    /// `VTableShim` callee) passes its address.
    fn receiver(&mut self, a: ArgSrc<'_, 'tcx>, tail: bool) -> Result<(u32, u32, Ty<'tcx>), NeedsNative> {
        let tcx = self.tcx;
        let ArgSrc::Operand(op) = a else { return native("virtual call receiver in a slot") };
        let raw = Ty::new_mut_ptr(tcx, tcx.types.unit);
        let (s, layout) = match op {
            Operand::Copy(place) | Operand::Move(place) => {
                let pv = self.place(*place)?;
                if let Some(meta) = pv.meta {
                    if tail {
                        // The address of a local of the frame the tail call replaces.
                        return native("tail call with an unsized by-value receiver");
                    }
                    let t = self.temp8();
                    self.addr_into(t, pv.loc);
                    return Ok((t, meta, raw));
                }
                (self.loc_slot(pv.loc, pv.layout)?, pv.layout)
            }
            Operand::Constant(_) | Operand::RuntimeChecks(_) => self.operand_slot(op)?,
        };
        let cx = self.lcx();
        let mut l = layout;
        let mut off = 0;
        while !l.ty.is_raw_ptr() && !l.ty.is_ref() {
            let Some((i, f)) = l.non_1zst_field(&cx) else {
                return native("virtual call receiver without exactly one non-1-ZST field");
            };
            off += l.fields.offset(i.as_usize()).bytes() as u32;
            l = f;
        }
        // The niche comes from the outermost type (`Box`'s `NonNull`, a reference), the
        // offsets from the pointer itself.
        let (BackendRepr::ScalarPair { a: data, .. }, BackendRepr::ScalarPair { b_offset, .. }) =
            (layout.backend_repr, l.backend_repr)
        else {
            return native("virtual call receiver isn't a wide pointer");
        };
        let nonnull = !data.valid_range(&cx).contains(0);
        let thin = if nonnull { Ty::new_imm_ref(tcx, tcx.lifetimes.re_erased, tcx.types.unit) } else { raw };
        Ok((s + off, s + off + b_offset.bytes() as u32, thin))
    }

    /// Emits the call (arguments already written) and continues as `cont` says. A result
    /// that doesn't come back in registers comes back at the start of the outgoing block
    /// ([`ret_len`]), where the VM callee or the native path's island leaves it.
    fn emit_call(&mut self, target: Target<'tcx>, sig: &AbiSig<'tcx>, cont: CallCont<'tcx>) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let (d, after) = self.call_dest(&cont, sig)?;
        let block = Self::out(0);
        let size = sig.output.size.bytes() as u32;
        let len = ret_len(size);
        let in_block = size != 0 && len == 0;
        // The destination of `call.ext`/`call.ind`, which their island writes.
        let cd = if in_block { block } else { d };
        let mut copy = false;
        match target {
            Target::Vm(callee) => {
                let f = self.reloc(CodeReloc::Call { callee });
                let d = if len == 0 { 0 } else { d };
                let at = self.op(Opcode::Call, &[d, f, len]);
                self.unwind_entry(at, cont.unwind);
                copy = in_block;
            }
            Target::Ext(callee) => {
                let island = self.call_ptr_island(sig)?;
                let f = self.temp8();
                let r = CodeReloc::Symbol { target: callee };
                let op = if self.sym_indirect(&r) { Opcode::CallExtInd } else { Opcode::CallExt };
                let sym = self.reloc(r);
                let site = self.reloc(CodeReloc::Site);
                let isl = self.reloc(CodeReloc::Island { template: island.0, args: island.1 });
                let at = self.op(op, &[cd, sym, site, isl, f, len]);
                self.unwind_entry(at, cont.unwind);
                copy = in_block;
            }
            Target::Template(fty) => {
                let args = [fty.into(), sig.args_tuple(tcx).into(), sig.output.ty.into()];
                self.island(templates::CALL, &args, &[block, d], Some(cont.unwind));
            }
            Target::Sym(callee, conv) => {
                let p = self.sym_addr(callee);
                let (name, args) = self.ptr_island(sig, conv)?;
                self.island(&name, &args, &[block, d, p], Some(cont.unwind));
            }
            Target::Ptr(p, CallConv::Rust) => {
                let island = self.call_ptr_island(sig)?;
                let site = self.reloc(CodeReloc::Site);
                let isl = self.reloc(CodeReloc::Island { template: island.0, args: island.1 });
                let at = self.op(Opcode::CallInd, &[cd, p, site, isl, len]);
                self.unwind_entry(at, cont.unwind);
                copy = in_block;
            }
            Target::Ptr(p, CallConv::C) => {
                let (name, args) = self.ptr_island(sig, CallConv::C)?;
                self.island(&name, &args, &[block, d, p], Some(cont.unwind));
            }
        }
        if copy {
            self.outgoing(size);
            self.mov(d, block, size);
        }
        self.finish_call(cont, d, after)
    }

    /// `ret` of `_0`: in registers, or copied to the start of the argument block first
    /// ([`ret_len`]).
    pub fn ret(&mut self) {
        let r = self.frame.locals[rustc_middle::mir::RETURN_PLACE];
        let size = r.layout.size.bytes() as u32;
        let len = ret_len(size);
        if len == 0 {
            self.mov(frame::slot(HEADER_SIZE as i32), r.off, size);
            self.op(Opcode::Ret, &[0, 0]);
        } else {
            self.op(Opcode::Ret, &[r.off, len]);
        }
    }

    /// `addr.sym` of `callee`'s symbol into a temporary.
    fn sym_addr(&mut self, callee: Instance<'tcx>) -> u32 {
        let p = self.temp8();
        self.addr_sym(p, CodeReloc::Symbol { target: callee });
        p
    }

    /// `TerminatorKind::TailCall` (`become`): the arguments are staged in the outgoing block,
    /// then `tail_call` (a VM function of this image) or `tail_call.ind` (anything else with
    /// an address; the VM makes a native target an ordinary call, whose result goes to `_0`,
    /// followed by a return) replaces the frame (design/vm.md#calls-and-islands). Both name
    /// the size of the argument block they move.
    pub fn tail_call_terminator(
        &mut self,
        func: &Operand<'tcx>,
        args: &[Spanned<Operand<'tcx>>],
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let fty = self.mono(func.ty(self.body, tcx));
        let srcs: Vec<ArgSrc<'_, 'tcx>> = args.iter().map(|a| ArgSrc::Operand(&a.node)).collect();
        let (target, sig, srcs) = match *fty.kind() {
            ty::FnDef(def_id, fn_args) => {
                let fn_args = fn_args.no_bound_vars().expect("monomorphic callee");
                let callee =
                    Instance::expect_resolve(tcx, TypingEnv::fully_monomorphized(), def_id, fn_args, source_info.span);
                match callee.def {
                    InstanceKind::Intrinsic(_) => return native("tail call of an intrinsic"),
                    InstanceKind::LlvmIntrinsic(_) => return native("call of an LLVM intrinsic"),
                    InstanceKind::Item(_) | InstanceKind::Virtual(..) | InstanceKind::Shim(_) => {
                        self.direct_target(fty, callee, &srcs, true)?
                    }
                }
            }
            ty::FnPtr(..) => {
                let (t, sig) = self.ptr_target(func, fty)?;
                (t, sig, srcs)
            }
            _ => return native("call of a non-fn type"),
        };
        if sig.conv != CallConv::Rust {
            return native("tail call of a non-Rust ABI");
        }
        // The VM returns a native target's result with the caller's `ret_size`, and `become`
        // requires matching signatures.
        let ret = self.frame.locals[rustc_middle::mir::RETURN_PLACE].layout;
        if ret.size != sig.output.size {
            return native("tail call with a different return size");
        }
        self.write_args(&sig, &srcs, source_info)?;
        match target {
            Target::Vm(callee) => {
                let f = self.reloc(CodeReloc::Call { callee });
                self.op(Opcode::TailCall, &[f, sig.block_size]);
            }
            Target::Ext(callee) | Target::Sym(callee, _) => {
                let p = self.sym_addr(callee);
                self.tail_call_ind(p, &sig)?;
            }
            Target::Ptr(p, _) => self.tail_call_ind(p, &sig)?,
            Target::Template(_) => unreachable!("tail calls don't use the call template"),
        }
        Ok(())
    }

    fn tail_call_ind(&mut self, p: u32, sig: &AbiSig<'tcx>) -> Result<(), NeedsNative> {
        let island = self.call_ptr_island(sig)?;
        let ret = self.frame.locals[rustc_middle::mir::RETURN_PLACE];
        let size = ret.layout.size.bytes() as u32;
        let len = ret_len(size);
        // A result that doesn't return in registers the island writes straight to the start
        // of the argument block.
        let s = if size != 0 && len == 0 { frame::slot(HEADER_SIZE as i32) } else { ret.off };
        let site = self.reloc(CodeReloc::Site);
        let isl = self.reloc(CodeReloc::Island { template: island.0, args: island.1 });
        let at = self.op(Opcode::TailCallInd, &[p, site, isl, sig.block_size, s, len]);
        // A tail call keeps no frame to land in: unwinding continues in the caller.
        self.unwind_entry(at, UnwindAction::Continue);
        Ok(())
    }

    /// The `call_ptrN` island for a `call.ext` / `call.ind` native fallback.
    fn call_ptr_island(
        &mut self,
        sig: &AbiSig<'tcx>,
    ) -> Result<(rustc_span::Symbol, ty::GenericArgsRef<'tcx>), NeedsNative> {
        let (name, args) = self.ptr_island(sig, CallConv::Rust)?;
        Ok((rustc_span::Symbol::intern(&name), self.tcx.mk_args(&args)))
    }

    /// The template and generic args of a fn-pointer call island for `sig`.
    fn ptr_island(&self, sig: &AbiSig<'tcx>, conv: CallConv) -> Result<(&'static str, Vec<GenericArg<'tcx>>), NeedsNative> {
        let n = sig.inputs.len();
        let name = match conv {
            CallConv::Rust => templates::call_ptr(n),
            CallConv::C => templates::call_c(n),
        };
        let Some(name) = name else { return native(format!("call with {n} arguments")) };
        let mut args: Vec<GenericArg<'tcx>> = sig.inputs.iter().map(|&t| t.into()).collect();
        args.push(sig.output.ty.into());
        Ok((name, args))
    }

    /// Whether `fty` can be called through `FnOnce` (the `call` template): a safe, Rust-ABI,
    /// non-variadic fn item without `#[target_feature]` or `#[track_caller]`
    /// (design/stubs.md#templates).
    pub(super) fn fn_once_able(&self, fty: Ty<'tcx>, callee: Instance<'tcx>) -> bool {
        let tcx = self.tcx;
        let ty::FnDef(def_id, _) = *fty.kind() else { return false };
        // The template calls `<F as FnOnce>::call_once`, the `FnPtr` shim of `F`
        // (`rustc_ty_utils/src/instance.rs:338`). From one of `F`'s own `Fn*` shims, which
        // calls `F`, that comes back to a VM shim calling `F` the same way, forever.
        if let InstanceKind::Shim(ty::ShimKind::FnPtr(_, shim_ty)) = self.instance.def
            && shim_ty == fty
        {
            return false;
        }
        let sig = fty.fn_sig(tcx);
        sig.safety().is_safe()
            && sig.abi() == ExternAbi::Rust
            && !sig.c_variadic()
            && tcx.codegen_fn_attrs(def_id).target_features.is_empty()
            && !callee.def.requires_caller_location(tcx)
    }

    /// Writes the arguments to the outgoing argument block. A `rust-call` callee's trailing
    /// tuple is spread; a `#[track_caller]` callee gets the caller location last.
    pub fn write_args(
        &mut self,
        sig: &AbiSig<'tcx>,
        args: &[ArgSrc<'_, 'tcx>],
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let n = sig.inputs.len() - usize::from(sig.caller_location);
        let spread = sig.rust_call;
        if !spread && args.len() != n {
            return native("argument count mismatch");
        }
        let direct = if spread { args.len().saturating_sub(1) } else { args.len() };
        for (i, a) in args[..direct].iter().enumerate() {
            let f = sig.fields[i];
            self.arg_into(*a, Self::out(f.offset), f.size)?;
        }
        if spread {
            let Some(&last) = args.last() else { return native("argument count mismatch") };
            let (s, layout) = match last {
                ArgSrc::Operand(op) => self.operand_slot(op)?,
                ArgSrc::Slot(_) => return native("spread argument in a slot"),
            };
            if !matches!(layout.ty.kind(), ty::Tuple(_)) || direct + layout.fields.count() != n {
                return native("argument count mismatch");
            }
            for j in 0..layout.fields.count() {
                let f = sig.fields[direct + j];
                self.mov(Self::out(f.offset), s + layout.fields.offset(j).bytes() as u32, f.size);
            }
        }
        if sig.caller_location {
            let f = sig.fields[n];
            self.caller_location_into(source_info, Self::out(f.offset))?;
        }
        self.outgoing(sig.block_size);
        Ok(())
    }

    /// Writes the caller location for a call (or `caller_location`) at `source_info` to
    /// slot `d`, as cg_ssa's `get_caller_location`: a pool `Location` for the span, or this
    /// function's own incoming location if it is `#[track_caller]` and the span isn't from a
    /// non-`#[track_caller]` function inlined into it (design/lowering.md#caller-location).
    pub fn caller_location_into(&mut self, source_info: SourceInfo, d: u32) -> Result<(), NeedsNative> {
        enum CallerLoc {
            Incoming(u32),
            Const(rustc_middle::mir::ConstValue),
        }
        let tcx = self.tcx;
        let own = self.caller_location.map(CallerLoc::Incoming);
        let loc = self.body.caller_location_span(source_info, own, tcx, |span| {
            CallerLoc::Const(tcx.span_as_caller_location(span))
        });
        match loc {
            CallerLoc::Incoming(s) => self.mov(d, s, 8),
            CallerLoc::Const(c) => {
                let layout = self.layout_of(tcx.caller_location_ty())?;
                self.const_value_into(c, layout, Loc::Slot(d))?;
            }
        }
        Ok(())
    }

    fn arg_into(&mut self, a: ArgSrc<'_, 'tcx>, d: u32, size: u32) -> Result<(), NeedsNative> {
        match a {
            ArgSrc::Operand(op) => self.operand_into(op, Loc::Slot(d)),
            ArgSrc::Slot(s) => {
                self.mov(d, s, size);
                Ok(())
            }
        }
    }

    /// The destination slot of a call, and whether it must be stored to memory afterwards.
    fn call_dest(&mut self, cont: &CallCont<'tcx>, sig: &AbiSig<'tcx>) -> Result<(u32, bool), NeedsNative> {
        match cont.dest {
            Some(PlaceVal { loc: Loc::Slot(d), meta: None, .. }) => Ok((d, false)),
            Some(PlaceVal { loc: Loc::Mem { .. }, meta: None, .. }) | None => {
                let t = self.frame.temp(sig.output.size.bytes(), sig.output.align.abi.bytes());
                Ok((t, cont.dest.is_some()))
            }
            Some(PlaceVal { meta: Some(_), .. }) => native("unsized call destination"),
        }
    }

    /// After the call instruction: stores a destination in memory, then continues at the
    /// target (or traps if the call diverges).
    fn finish_call(&mut self, cont: CallCont<'tcx>, d: u32, store: bool) -> Result<(), NeedsNative> {
        if store && let Some(dest) = cont.dest {
            self.store(dest.loc, d, dest.layout.size.bytes() as u32);
        }
        match cont.target {
            Some(bb) => self.jump(bb),
            None => {
                self.op(Opcode::Unreachable, &[]);
            }
        }
        Ok(())
    }

    /// `TerminatorKind::Drop`: nothing without drop glue, a VM `call` of the glue if it is a
    /// VM function, else the `drop_in_place::<T>` island.
    pub fn drop_terminator(
        &mut self,
        place: Place<'tcx>,
        target: BasicBlock,
        unwind: UnwindAction,
    ) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let ty = self.mono(place.ty(self.body, tcx).ty);
        let glue = Instance::resolve_drop_glue(tcx, ty);
        if let InstanceKind::Shim(ty::ShimKind::DropGlue(_, None)) = glue.def {
            self.jump(target);
            return Ok(());
        }
        let pv = self.place(place)?;
        if let ty::Dynamic(..) = ty.kind() {
            return self.virtual_drop(pv, target, unwind);
        }
        let ptr = self.frame.temp(if pv.meta.is_some() { 16 } else { 8 }, 8);
        self.addr_into(ptr, pv.loc);
        if let Some(m) = pv.meta {
            self.mov(ptr + 8, m, 8);
        }
        if self.cx.vm.contains(&glue) {
            // The glue of an unsized type takes the wide pointer.
            let sig = abi_sig(tcx, glue)?;
            self.write_args(&sig, &[ArgSrc::Slot(ptr)], self.body.source_info(rustc_middle::mir::Location::START).clone())?;
            let f = self.reloc(CodeReloc::Call { callee: glue });
            let at = self.op(Opcode::Call, &[0, f, 0]);
            self.unwind_entry(at, unwind);
        } else {
            self.island(templates::DROP_IN_PLACE, &[ty.into()], &[ptr], Some(unwind));
        }
        self.jump(target);
        Ok(())
    }
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Drop of a trait object: the vtable's `drop_in_place` entry (null if the type needs no
    /// drop), called with the data pointer, as cg_ssa does.
    fn virtual_drop(&mut self, pv: PlaceVal<'tcx>, target: BasicBlock, unwind: UnwindAction) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let Some(vtable) = pv.meta else { return native("trait object without metadata") };
        let f = self.temp8();
        let idx = ty::COMMON_VTABLE_ENTRIES_DROPINPLACE as u32;
        self.op(super::emit::opcode("LoadW64"), &[f, vtable, idx * 8]);
        self.op_branch(super::emit::opcode("BrEqImmW64"), &[f, 0, 0], false, target);
        let data = Ty::new_mut_ptr(tcx, tcx.types.unit);
        let sig = tys_sig(tcx, vec![data], tcx.types.unit)?;
        let ptr = self.temp8();
        self.addr_into(ptr, pv.loc);
        self.write_args(&sig, &[ArgSrc::Slot(ptr)], self.body.source_info(rustc_middle::mir::Location::START).clone())?;
        let island = self.call_ptr_island(&sig)?;
        let d = self.frame.temp(0, 1);
        let site = self.reloc(CodeReloc::Site);
        let isl = self.reloc(CodeReloc::Island { template: island.0, args: island.1 });
        let at = self.op(Opcode::CallInd, &[d, f, site, isl, 0]);
        self.unwind_entry(at, unwind);
        self.jump(target);
        Ok(())
    }
}

impl<'tcx> CallCont<'tcx> {
    /// A call that never returns, unwinding as `unwind` says.
    pub fn diverging(unwind: UnwindAction) -> Self {
        CallCont { dest: None, target: None, unwind }
    }
}

/// The `len` operand of a call or `ret` of a `size`-byte value: `size` if it returns in
/// registers ([`ret_in_regs`]), else 0, and the value goes through the start of the
/// argument block, which the lowering copies it to and from (design/vm.md, "Calls and
/// islands").
pub fn ret_len(size: u32) -> u32 {
    if ret_in_regs(size) { size } else { 0 }
}
