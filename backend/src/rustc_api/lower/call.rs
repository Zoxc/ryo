//! Calls and drops (design/lowering.md#calls, design/stubs.md#calls-between-vm-and-native-code).
//!
//! A direct call of a resolved instance is, in order of preference:
//!
//! - `call fn`: a VM function of this image ([`LowerCx::vm`])
//! - `call.ext sym, site, call_ptrN`: a Rust-ABI instance from another crate (one
//!   `should_codegen_locally` says isn't codegened here)
//! - `island call<F, Args, R>`: a safe Rust fn item (through `FnOnce`, no symbol needed)
//! - `addr.sym` + `island call_ptrN` / `call_cN`: any other local native function
//!
//! Arguments are written to the outgoing argument block just before the call. For a
//! `#[track_caller]` callee the caller location is appended (design/lowering.md#caller-location).
//!
//! [`LowerCx::vm`]: super::LowerCx::vm

use rustc_abi::ExternAbi;
use rustc_middle::mir::{BasicBlock, Operand, Place, SourceInfo, UnwindAction};
use rustc_middle::ty::{self, GenericArg, Instance, InstanceKind, Ty, TypingEnv};
use rustc_span::Spanned;
use ryo_bytecode::insn::Opcode;

use super::island::templates;
use super::place::{Loc, PlaceVal};
use super::sig::{AbiSig, CallConv, abi_sig, fn_ptr_sig, tys_sig};
use super::{CodeReloc, FnCx, NeedsNative, native, no_trim};

/// Where an argument comes from.
#[derive(Clone, Copy)]
pub enum ArgSrc<'b, 'tcx> {
    Operand(&'b Operand<'tcx>),
    /// A value already in a frame slot.
    Slot(u32),
}

/// How a direct call is made.
enum Path {
    Vm,
    Ext,
    CallTemplate,
    Ptr(CallConv),
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
        let tcx = self.tcx;
        let has_symbol = !matches!(callee.def, InstanceKind::Virtual(..) | InstanceKind::Intrinsic(_));
        let path = if self.cx.vm.contains(&callee) {
            Path::Vm
        } else if !has_symbol {
            if !self.fn_once_able(fty, callee) {
                return native(no_trim(|| format!("call of {callee} (needs call.ind or an intrinsic wrapper)")));
            }
            Path::CallTemplate
        } else {
            let sig = abi_sig(tcx, callee)?;
            match sig.conv {
                CallConv::Rust if !tcx.should_codegen_locally(callee) => Path::Ext,
                CallConv::Rust if self.fn_once_able(fty, callee) => Path::CallTemplate,
                conv => Path::Ptr(conv),
            }
        };
        let sig = match path {
            Path::CallTemplate => {
                let s = tcx.normalize_erasing_late_bound_regions(TypingEnv::fully_monomorphized(), fty.fn_sig(tcx));
                tys_sig(tcx, s.inputs().to_vec(), s.output())?
            }
            Path::Vm | Path::Ext | Path::Ptr(_) => {
                let mut sig = abi_sig(tcx, callee)?;
                sig.rust_call = fty.fn_sig(tcx).abi() == ExternAbi::RustCall;
                sig
            }
        };
        self.write_args(&sig, args, source_info)?;
        let (d, after) = self.call_dest(&cont, &sig)?;
        let block = Self::out(0);
        match path {
            Path::Vm => {
                let at = self.op(Opcode::Call, &[d, 0, 0]);
                self.relocs.push(CodeReloc::Call { at, callee });
                self.unwind_entry(at, cont.unwind);
            }
            Path::Ext => {
                let island = self.call_ptr_island(&sig)?;
                let at = self.op(Opcode::CallExt, &[d, 0, 0, 0]);
                self.relocs.push(CodeReloc::Symbol { at: at + 2, target: callee });
                self.relocs.push(CodeReloc::Site { at: at + 3 });
                self.islands.push(super::IslandRequest { at: at + 4, template: island.0, args: island.1 });
                self.unwind_entry(at, cont.unwind);
            }
            Path::CallTemplate => {
                let args = [fty.into(), sig.args_tuple(tcx).into(), sig.output.ty.into()];
                self.island(templates::CALL, &args, &[block, d], Some(cont.unwind));
            }
            Path::Ptr(conv) => {
                let p = self.temp8();
                let at = self.op(Opcode::AddrSym, &[p, 0]);
                self.relocs.push(CodeReloc::Symbol { at: at + 2, target: callee });
                let (name, args) = self.ptr_island(&sig, conv)?;
                self.island(&name, &args, &[block, d, p], Some(cont.unwind));
            }
        }
        self.finish_call(cont, d, after)
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
        let mut sig = fn_ptr_sig(self.tcx, fty.fn_sig(self.tcx))?;
        sig.rust_call = fty.fn_sig(self.tcx).abi() == ExternAbi::RustCall;
        let (p, _) = self.operand_slot(func)?;
        self.write_args(&sig, args, source_info)?;
        let (d, after) = self.call_dest(&cont, &sig)?;
        match sig.conv {
            CallConv::Rust => {
                let island = self.call_ptr_island(&sig)?;
                let at = self.op(Opcode::CallInd, &[d, p, 0, 0]);
                self.relocs.push(CodeReloc::Site { at: at + 3 });
                self.islands.push(super::IslandRequest { at: at + 4, template: island.0, args: island.1 });
                self.unwind_entry(at, cont.unwind);
            }
            CallConv::C => {
                let (name, args) = self.ptr_island(&sig, CallConv::C)?;
                self.island(&name, &args, &[Self::out(0), d, p], Some(cont.unwind));
            }
        }
        self.finish_call(cont, d, after)
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
    fn ptr_island(&self, sig: &AbiSig<'tcx>, conv: CallConv) -> Result<(String, Vec<GenericArg<'tcx>>), NeedsNative> {
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
    fn fn_once_able(&self, fty: Ty<'tcx>, callee: Instance<'tcx>) -> bool {
        let tcx = self.tcx;
        let ty::FnDef(def_id, _) = *fty.kind() else { return false };
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
            let tcx = self.tcx;
            let loc = self.body.caller_location_span(source_info, None, tcx, |span| tcx.span_as_caller_location(span));
            let layout = self.layout_of(tcx.caller_location_ty())?;
            let f = sig.fields[n];
            self.const_value_into(loc, layout, Loc::Slot(Self::out(f.offset)))?;
        }
        self.outgoing(sig.block_size);
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
        if pv.meta.is_none() && self.cx.vm.contains(&glue) {
            let sig = abi_sig(tcx, glue)?;
            self.write_args(&sig, &[ArgSrc::Slot(ptr)], self.body.source_info(rustc_middle::mir::Location::START).clone())?;
            let d = self.frame.temp(0, 1);
            let at = self.op(Opcode::Call, &[d, 0, 0]);
            self.relocs.push(CodeReloc::Call { at, callee: glue });
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
        self.op_branch(super::emit::opcode("BrCmpEqImmW64"), &[f, 0, 0], target);
        let data = Ty::new_mut_ptr(tcx, tcx.types.unit);
        let sig = tys_sig(tcx, vec![data], tcx.types.unit)?;
        let ptr = self.temp8();
        self.addr_into(ptr, pv.loc);
        self.write_args(&sig, &[ArgSrc::Slot(ptr)], self.body.source_info(rustc_middle::mir::Location::START).clone())?;
        let island = self.call_ptr_island(&sig)?;
        let d = self.frame.temp(0, 1);
        let at = self.op(Opcode::CallInd, &[d, f, 0, 0]);
        self.relocs.push(CodeReloc::Site { at: at + 3 });
        self.islands.push(super::IslandRequest { at: at + 4, template: island.0, args: island.1 });
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
