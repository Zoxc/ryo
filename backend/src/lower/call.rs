//! Calls and drops (design/lowering.md#calls, design/stubs.md#calls-between-vm-and-native-code).
//!
//! A direct call of a resolved instance is, in order of preference:
//!
//! - `call fn`: a Rust-ABI VM function of this image ([`LowerCx::vm`])
//! - `call.sym sym` (`call.sym.ind` through a PE import slot): any other Rust-ABI instance
//!   with a symbol, native or from another crate
//! - `island call<F, Args, R>`: a safe Rust fn item without a symbol (through `FnOnce`)
//! - `addr.sym` + `island call_cN`: a function with another ABI
//!
//! Fn-pointer calls and virtual calls (`InstanceKind::Virtual`, the fn pointer loaded from
//! the receiver's vtable) are `call.ptr` (Rust ABI) or a `call_cN` island. `become` is
//! `tail_call` / `tail_call.ptr`.
//!
//! Arguments go where the platform calling convention says ([`super::sig::ArgPlan`]): the
//! stack pieces are stored to the outgoing area before the call, the register pieces are
//! the call instruction's argument list. For a `#[track_caller]` callee the caller location
//! is appended (design/lowering.md#caller-location).
//!
//! [`LowerCx::vm`]: super::LowerCx::vm

use rustc_abi::{BackendRepr, ExternAbi};
use rustc_middle::mir::{BasicBlock, Operand, Place, SourceInfo, UnwindAction};
use rustc_middle::ty::{self, GenericArg, Instance, InstanceKind, Ty, TypingEnv};
use rustc_span::Spanned;
use ryo_bytecode::abi::HEADER_SIZE;
use ryo_bytecode::asm::{ARG_ADDR, ArgReg, RET_SRET, RetPart, ret_kind, ret_parts};
use ryo_bytecode::full::Opcode;

use super::cert::CallKind;
use super::emit::{IntOp, Width};
use super::frame;
use super::island::templates;
use super::place::{Loc, PlaceVal};
use super::sig::{AbiSig, ArgLoc, ArgPlan, CallConv, fn_ptr_sig, tys_sig, virtual_sig};
use super::{CodeReloc, FnCx, NeedsNative, native, no_trim};

/// Where an argument comes from.
#[derive(Clone, Copy)]
pub enum ArgSrc<'b, 'tcx> {
    Operand(&'b Operand<'tcx>),
    /// A value already in a frame slot.
    Slot(u32),
}

/// [`ArgSrc`] accessors.
impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// An argument in a frame slot, with its size (a slot given as one is a receiver's data
    /// pointer).
    fn arg_slot_sized(&mut self, a: &ArgSrc<'_, 'tcx>) -> Result<(u32, u32), NeedsNative> {
        match *a {
            ArgSrc::Operand(op) => self.operand_slot(op).map(|(s, l)| (s, l.size.bytes() as u32)),
            ArgSrc::Slot(s) => Ok((s, 8)),
        }
    }

    /// An argument in a frame slot.
    pub(super) fn arg_slot(&mut self, a: &ArgSrc<'_, 'tcx>) -> Result<u32, NeedsNative> {
        Ok(self.arg_slot_sized(a)?.0)
    }

    /// The arguments in frame slots, each with its size, as island operands.
    pub(super) fn island_args(&mut self, args: &[ArgSrc<'_, 'tcx>]) -> Result<Vec<(u32, u32)>, NeedsNative> {
        args.iter().map(|a| self.arg_slot_sized(a)).collect()
    }

    /// The `N` arguments of an intrinsic in frame slots.
    pub(super) fn arg_slots<const N: usize>(&mut self, args: &[ArgSrc<'_, 'tcx>]) -> Result<[u32; N], NeedsNative> {
        if args.len() != N {
            return native("intrinsic argument count");
        }
        let mut out = [0; N];
        for (o, a) in out.iter_mut().zip(args) {
            *o = self.arg_slot(a)?;
        }
        Ok(out)
    }

    /// The value of an argument if it is an integer constant.
    pub(super) fn arg_const(&self, a: &ArgSrc<'_, 'tcx>) -> Result<Option<u128>, NeedsNative> {
        match *a {
            ArgSrc::Operand(op) => self.const_int(op),
            ArgSrc::Slot(_) => Ok(None),
        }
    }

    /// Copies argument `a` (`size` bytes) to slot `d`.
    fn arg_into(&mut self, a: ArgSrc<'_, 'tcx>, d: u32, size: u32) -> Result<(), NeedsNative> {
        match a {
            ArgSrc::Operand(op) => self.operand_into(op, Loc::Slot(d)),
            ArgSrc::Slot(s) => {
                self.mov(d, s, size);
                Ok(())
            }
        }
    }
}

/// How a call is made.
#[derive(Clone, Copy)]
enum Target<'tcx> {
    /// A VM call instruction (Rust ABI): `call` / `call.sym[.ind]` / `call.ptr`, or
    /// `tail_call` / `tail_call.ptr`.
    Direct(Callee<'tcx>),
    /// `island call<F, Args, R>`: a safe Rust fn item `F` without a symbol, through `FnOnce`.
    Template(Ty<'tcx>),
    /// A `call_cN` island on the callee's address (another ABI).
    CIsland(Callee<'tcx>),
}

impl<'tcx> Target<'tcx> {
    /// A call of `callee`, whose calling convention is `conv`.
    fn of(conv: CallConv, callee: Callee<'tcx>) -> Self {
        match conv {
            CallConv::Rust => Target::Direct(callee),
            CallConv::C => Target::CIsland(callee),
        }
    }

    /// Whether the call goes through an island, which takes its arguments as a block.
    fn is_island(self) -> bool {
        matches!(self, Target::Template(_) | Target::CIsland(_))
    }
}

/// Where a call's callee is.
#[derive(Clone, Copy)]
enum Callee<'tcx> {
    /// A VM function of this image: `call fn` / `tail_call fn`.
    Vm(Instance<'tcx>),
    /// The drop glue of a type, a VM function: as `Vm`, with a drop's certificate kind.
    DropGlue(Instance<'tcx>),
    /// An instance with a symbol, native or from another crate: `call.sym sym`.
    Sym(Instance<'tcx>),
    /// The fn pointer in this slot: fn-pointer calls and virtual calls (the pointer loaded
    /// from the vtable).
    Ptr(u32),
}

/// What a call's operand resolves to.
enum Resolved<'tcx> {
    Intrinsic(Instance<'tcx>),
    /// A fn item: a body, a virtual call or a shim.
    Direct(Instance<'tcx>),
    /// A fn pointer.
    Ptr,
}

/// What happens after a call: where the value goes and where control goes.
pub struct CallCont<'tcx> {
    pub dest: Option<PlaceVal<'tcx>>,
    pub target: Option<BasicBlock>,
    pub unwind: UnwindAction,
}

impl CallCont<'_> {
    /// The destination's size, 0 without one.
    pub fn dest_size(&self) -> u32 {
        self.dest.map_or(0, |d| d.layout.size.bytes() as u32)
    }
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
        let (fty, callee) = self.resolve_callee(func, source_info)?;
        let dest = self.place(destination)?;
        let cont = CallCont { dest: Some(dest), target, unwind };
        let srcs = arg_srcs(args);
        match callee {
            Resolved::Intrinsic(callee) => self.intrinsic_call(callee, fty, &srcs, cont, source_info),
            Resolved::Direct(callee) => self.direct_call(fty, callee, &srcs, cont, source_info),
            Resolved::Ptr => self.indirect_call(func, fty, &srcs, cont, source_info),
        }
    }

    /// The monomorphic type of the called operand `func` and what it resolves to.
    fn resolve_callee(&self, func: &Operand<'tcx>, source_info: SourceInfo) -> Result<(Ty<'tcx>, Resolved<'tcx>), NeedsNative> {
        let tcx = self.tcx;
        let fty = self.mono(func.ty(self.body, tcx));
        let callee = match *fty.kind() {
            ty::FnDef(def_id, fn_args) => {
                let fn_args = fn_args.no_bound_vars().expect("monomorphic callee");
                let callee = Instance::expect_resolve(tcx, TypingEnv::fully_monomorphized(), def_id, fn_args, source_info.span);
                match callee.def {
                    InstanceKind::Intrinsic(_) => Resolved::Intrinsic(callee),
                    InstanceKind::LlvmIntrinsic(_) => return native("call of an LLVM intrinsic"),
                    InstanceKind::Item(_) | InstanceKind::Virtual(..) | InstanceKind::Shim(_) => Resolved::Direct(callee),
                }
            }
            ty::FnPtr(..) => Resolved::Ptr,
            _ => return native("call of a non-fn type"),
        };
        Ok((fty, callee))
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
        let homes = self.write_args(&sig, &args, source_info, target.is_island())?;
        self.emit_call(target, &sig, &homes, cont)
    }

    /// A call through a fn pointer: `call.ptr` (Rust ABI) or a `call_cN` island.
    fn indirect_call(
        &mut self,
        func: &Operand<'tcx>,
        fty: Ty<'tcx>,
        args: &[ArgSrc<'_, 'tcx>],
        cont: CallCont<'tcx>,
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let (target, sig) = self.ptr_target(func, fty)?;
        let homes = self.write_args(&sig, args, source_info, target.is_island())?;
        self.emit_call(target, &sig, &homes, cont)
    }

    /// How to reach the resolved `callee` (fn item type `fty`), its signature, and the
    /// arguments as the signature takes them (a virtual call passes the receiver's data
    /// pointer). Only callees without a symbol (intrinsics) go through the `call` template,
    /// which can't be a tail call: with `tail` they stay native, as do virtual calls with an
    /// unsized by-value receiver.
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
        let (target, sig) = if let InstanceKind::Virtual(_, idx) = callee.def {
            let Some(&recv) = args.first() else { return native("virtual call without a receiver") };
            let (data, vtable, recv_ty) = self.receiver(recv, tail)?;
            let sig = virtual_sig(tcx, callee, recv_ty)?;
            // The method's entry in the vtable (`VirtualIndex::get_fn`).
            let f = self.temp8();
            let k = u32::try_from(idx * 8).map_err(|_| NeedsNative("vtable index".into()))?;
            self.op(Opcode::LoadW64, &[f, vtable, k]);
            args[0] = ArgSrc::Slot(data);
            (Target::of(sig.conv, Callee::Ptr(f)), sig)
        } else {
            let has_symbol = !matches!(callee.def, InstanceKind::Intrinsic(_));
            let vm = self.cx.vm.contains(&callee);
            let callee_sig = (has_symbol || vm).then(|| self.abi_sig(callee));
            match callee_sig {
                // VM functions are Rust-ABI; a candidate with another ABI stays native.
                Some(Ok(sig)) if vm && sig.conv == CallConv::Rust => (Target::Direct(Callee::Vm(callee)), sig),
                _ if !has_symbol => {
                    if tail || !self.fn_once_able(fty, callee) {
                        return native(no_trim(|| format!("call of {callee} (needs an intrinsic wrapper)")));
                    }
                    let s = tcx.normalize_erasing_late_bound_regions(TypingEnv::fully_monomorphized(), fty.fn_sig(tcx));
                    return Ok((Target::Template(fty), tys_sig(tcx, s.inputs().to_vec(), s.output())?, args));
                }
                Some(sig) => {
                    let sig = sig?;
                    (Target::of(sig.conv, Callee::Sym(callee)), sig)
                }
                None => unreachable!("a callee without a symbol is a template call"),
            }
        };
        Ok((target, AbiSig { rust_call, ..sig }, args))
    }

    /// The target and signature of a call through the fn pointer `func` of type `fty`.
    fn ptr_target(&mut self, func: &Operand<'tcx>, fty: Ty<'tcx>) -> Result<(Target<'tcx>, AbiSig<'tcx>), NeedsNative> {
        let sig = fn_ptr_sig(self.tcx, fty.fn_sig(self.tcx))?;
        let (p, _) = self.operand_slot(func)?;
        Ok((Target::of(sig.conv, Callee::Ptr(p)), sig))
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
                    self.addr_into(t, pv.loc, pv.base)?;
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
        let (BackendRepr::ScalarPair { a: data, .. }, BackendRepr::ScalarPair { b_offset, .. }) = (layout.backend_repr, l.backend_repr) else {
            return native("virtual call receiver isn't a wide pointer");
        };
        let nonnull = !data.valid_range(&cx).contains(0);
        let thin = if nonnull { Ty::new_imm_ref(tcx, tcx.lifetimes.re_erased, tcx.types.unit) } else { raw };
        Ok((s + off, s + off + b_offset.bytes() as u32, thin))
    }

    /// Emits the call (arguments already written, `homes` their slots) and continues as
    /// `cont` says. The result comes back as the signature's return kind says, into `d`; for
    /// sret, the call passes `d`'s address.
    fn emit_call(&mut self, target: Target<'tcx>, sig: &AbiSig<'tcx>, homes: &[u32], cont: CallCont<'tcx>) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let (d, after) = self.call_dest(&cont, sig)?;
        let block = Self::out(self.island_block());
        let k = if sig.ret_kind == RET_SRET { 0 } else { sig.ret_kind };
        let rd = if k == 0 { 0 } else { d };
        // The island calls' operands: the argument block, the result, and the callee.
        let (bn, dn) = (sig.block_size, sig.output.size.bytes() as u32);
        match target {
            Target::Template(fty) => {
                let args = [fty.into(), sig.args_tuple(tcx).into(), sig.output.ty.into()];
                self.island(templates::CALL, &args, &[(block, bn), (d, dn)], Some(cont.unwind));
            }
            Target::CIsland(callee) => {
                let p = self.callee_addr(callee);
                let (name, args) = self.ptr_island(sig)?;
                self.island(&name, &args, &[(block, bn), (d, dn), (p, 8)], Some(cont.unwind));
            }
            Target::Direct(callee) => {
                let a = self.pass_args(sig, homes, Some(d), false)?;
                let (op, f, kind) = self.call_op(callee, false);
                let at = self.call_insn(op, &[rd, f, k], &a, kind, sig);
                self.unwind_entry(at, cont.unwind);
            }
        }
        self.finish_call(cont, d, after)
    }

    /// The address of `callee` in a slot.
    fn callee_addr(&mut self, callee: Callee<'tcx>) -> u32 {
        match callee {
            Callee::Vm(i) | Callee::DropGlue(i) | Callee::Sym(i) => self.sym_addr(i),
            Callee::Ptr(p) => p,
        }
    }

    /// The call instruction for `callee` (a tail call with `tail`), its callee operand and
    /// its certificate kind.
    fn call_op(&mut self, callee: Callee<'tcx>, tail: bool) -> (Opcode, u32, CallKind) {
        match (callee, tail) {
            (Callee::Vm(callee), false) => (Opcode::Call, self.reloc(CodeReloc::Call { callee }), CallKind::Vm),
            (Callee::DropGlue(callee), false) => (Opcode::Call, self.reloc(CodeReloc::Call { callee }), CallKind::DropVm),
            (Callee::Vm(callee) | Callee::DropGlue(callee), true) => (Opcode::TailCall, self.reloc(CodeReloc::Call { callee }), CallKind::TailVm),
            (Callee::Sym(callee), false) => {
                let r = CodeReloc::Symbol { target: callee };
                let op = if self.sym_indirect(&r) { Opcode::CallSymInd } else { Opcode::CallSym };
                (op, self.reloc(r), CallKind::Sym)
            }
            (Callee::Ptr(p), false) => (Opcode::CallPtr, p, CallKind::Ptr),
            (Callee::Sym(_) | Callee::Ptr(_), true) => (Opcode::TailCallPtr, self.callee_addr(callee), CallKind::TailPtr),
        }
    }

    /// The call instruction `op` with the operands `head` then the register arguments `a`,
    /// and its certificate entry.
    fn call_insn(&mut self, op: Opcode, head: &[u32], a: &[u32], kind: CallKind, sig: &AbiSig<'tcx>) -> super::InsnId {
        let at = self.op(op, &[head, a].concat());
        self.cert_call(at, kind, sig.plan.as_ref(), sig.ret_kind, sig.output.size.bytes());
        at
    }

    /// Passes the inputs in their slots `homes` as `sig`'s calling convention says: the
    /// stack pieces stored to the outgoing area (or for a tail call, over the function's own
    /// incoming one), and the argument list of the call instruction for the registers. An
    /// `Indirect` input is passed as its home's address, or for a tail call copied over the
    /// function's own incoming value, whose address is passed on (as rustc does). For an
    /// sret callee, the destination `d`'s address, or for a tail call the function's own.
    /// The stack pieces must be stored right before the call, with no other call in between:
    /// the JIT's inlining merges callees' outgoing areas into the caller's on that basis, and
    /// refuses to inline where it doesn't hold (vm/bytecode/src/jit/inline.rs
    /// `outgoing_pending`).
    fn pass_args(&mut self, sig: &AbiSig<'tcx>, homes: &[u32], d: Option<u32>, tail: bool) -> Result<Vec<u32>, NeedsNative> {
        let Some(plan) = &sig.plan else { return native("a call without a calling convention") };
        let mut a = Vec::new();
        let gpr = |index| ArgReg { xmm: false, size: 8, index }.word();
        if sig.ret_kind == RET_SRET {
            match (tail, self.frame.sret) {
                (false, _) => a.extend([d.expect("call destination"), gpr(0) | ARG_ADDR]),
                (true, Some(p)) => a.extend([p, gpr(0)]),
                (true, None) => return native("tail call of an sret function from another one"),
            }
        }
        // A stack piece's slot: the outgoing area at `rsp`, or the incoming one at `fp + 16`.
        // In the PE pad region `rsp` isn't `fp - F`, where the outgoing area is.
        if self.in_region && plan.locs.iter().flatten().any(|l| matches!(l, ArgLoc::Stack { .. } | ArgLoc::PtrStack(_))) {
            return native("a call with stack arguments in PE cleanup code");
        }
        let stack = |at: u32| if tail { frame::slot((HEADER_SIZE + at) as i32) } else { Self::out(at) };
        for (i, locs) in plan.locs.iter().enumerate() {
            let home = homes[i];
            // A tail call reuses the incoming `Indirect` value's memory.
            let incoming_ptr = |fx: &mut Self| -> Result<u32, NeedsNative> {
                let Some(p) = fx.frame.arg_ptrs.get(i).copied().flatten() else {
                    return native("tail call passing an indirect argument the function didn't get");
                };
                fx.op(Opcode::StoreCopy, &[p, 0, home, sig.fields[i].size]);
                Ok(p)
            };
            for &l in locs {
                match l {
                    ArgLoc::Reg { reg, off } => {
                        let size = if reg.xmm { reg.size } else { reg.size.next_power_of_two() };
                        a.extend([home + off, ArgReg { size, ..reg }.word()]);
                    }
                    ArgLoc::Stack { at, off, size } => self.mov(stack(at), home + off, size),
                    ArgLoc::PtrReg(index) if tail => {
                        let p = incoming_ptr(self)?;
                        a.extend([p, gpr(index)]);
                    }
                    ArgLoc::PtrReg(index) => {
                        self.escape(home, None)?;
                        a.extend([home, gpr(index) | ARG_ADDR]);
                    }
                    ArgLoc::PtrStack(at) if tail => {
                        let p = incoming_ptr(self)?;
                        self.mov(stack(at), p, 8);
                    }
                    ArgLoc::PtrStack(at) => self.addr_into(stack(at), Loc::Slot(home), None)?,
                }
            }
        }
        if !tail {
            self.outgoing(plan.stack_size);
        }
        Ok(a)
    }

    /// `ret` of `_0`, as the function's return kind says: in registers, or (sret) copied to
    /// the address the caller passed, which is returned.
    pub fn ret(&mut self) {
        let r = self.frame.locals[rustc_middle::mir::RETURN_PLACE];
        let size = r.layout.size.bytes() as u32;
        match self.ret_kind {
            0 => self.op(Opcode::Ret, &[0, 0]),
            RET_SRET => {
                let p = self.frame.sret.expect("sret slot");
                self.op(Opcode::StoreCopy, &[p, 0, r.off, size]);
                self.op(Opcode::Ret, &[p, load_kind(ret_kind(&[RetPart { xmm: false, size: 8, off: 0 }]))])
            }
            k => self.op(Opcode::Ret, &[r.off, load_kind(k)]),
        };
    }

    /// `addr.sym` of `callee`'s symbol into a temporary.
    fn sym_addr(&mut self, callee: Instance<'tcx>) -> u32 {
        let p = self.temp8();
        self.addr_sym(p, CodeReloc::Symbol { target: callee });
        p
    }

    /// `TerminatorKind::TailCall` (`become`): the arguments are staged in temporaries, their
    /// stack pieces stored over the function's own incoming ones, then `tail_call` (a VM
    /// function of this image) or `tail_call.ptr` (anything else with an address) loads the
    /// argument registers and jumps (design/vm.md#calls-and-islands).
    pub fn tail_call_terminator(
        &mut self,
        func: &Operand<'tcx>,
        args: &[Spanned<Operand<'tcx>>],
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let (fty, callee) = self.resolve_callee(func, source_info)?;
        let srcs = arg_srcs(args);
        let (target, sig, srcs) = match callee {
            Resolved::Intrinsic(_) => return native("tail call of an intrinsic"),
            Resolved::Direct(callee) => self.direct_target(fty, callee, &srcs, true)?,
            Resolved::Ptr => {
                let (t, sig) = self.ptr_target(func, fty)?;
                (t, sig, srcs)
            }
        };
        let Target::Direct(callee) = target else { return native("tail call of a non-Rust ABI") };
        // `become` requires matching signatures.
        let ret = self.frame.locals[rustc_middle::mir::RETURN_PLACE].layout;
        if ret.size != sig.output.size || sig.ret_kind != self.ret_kind {
            return native("tail call with a different return");
        }
        let homes = self.write_args(&sig, &srcs, source_info, false)?;
        // A symbol's address is taken before the arguments are passed.
        let callee = match callee {
            Callee::Sym(_) => Callee::Ptr(self.callee_addr(callee)),
            c => c,
        };
        let a = self.pass_args(&sig, &homes, None, true)?;
        let (op, f, kind) = self.call_op(callee, true);
        self.call_insn(op, &[f], &a, kind, &sig);
        Ok(())
    }

    /// The template and generic args of a `call_cN` island for `sig`.
    fn ptr_island(&self, sig: &AbiSig<'tcx>) -> Result<(String, Vec<GenericArg<'tcx>>), NeedsNative> {
        let n = sig.inputs.len();
        let name = match sig.conv {
            CallConv::C => templates::call_c(n),
            CallConv::Rust => unreachable!("Rust-ABI calls are direct"),
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

    /// The arguments' slots, one per ABI input: a `rust-call` callee's trailing tuple is
    /// spread, a `#[track_caller]` callee gets the caller location last. For an `island`
    /// call, they are the fields of the argument block in the outgoing area (the templates'
    /// `Args`). Otherwise each is the operand's own slot, except that an `Indirect` input,
    /// which the callee may write to, is a copy in a temporary.
    pub fn write_args(
        &mut self,
        sig: &AbiSig<'tcx>,
        args: &[ArgSrc<'_, 'tcx>],
        source_info: SourceInfo,
        island: bool,
    ) -> Result<Vec<u32>, NeedsNative> {
        let n = sig.inputs.len() - usize::from(sig.caller_location);
        let spread = sig.rust_call;
        if !spread && args.len() != n {
            return native("argument count mismatch");
        }
        let indirect =
            |i: usize| sig.plan.as_ref().is_some_and(|p| matches!(p.locs.get(i).map(|l| &l[..]), Some([ArgLoc::PtrReg(_) | ArgLoc::PtrStack(_)])));
        // The slot of input `i` whose value is at `s`.
        let home = |fx: &mut Self, i: usize, s: u32| -> u32 {
            let f = sig.fields[i];
            if island {
                let at = Self::out(fx.island_block() + f.offset);
                fx.mov(at, s, f.size);
                at
            } else if indirect(i) {
                let t = fx.frame.temp(u64::from(f.size), u64::from(f.align));
                fx.mov(t, s, f.size);
                t
            } else {
                s
            }
        };
        let direct = if spread { args.len().saturating_sub(1) } else { args.len() };
        let mut homes = Vec::with_capacity(sig.inputs.len());
        for (i, a) in args[..direct].iter().enumerate() {
            let f = sig.fields[i];
            let s = match *a {
                ArgSrc::Slot(s) => s,
                ArgSrc::Operand(op) => match self.operand_slot(op) {
                    Ok((s, _)) => s,
                    Err(_) => {
                        // An operand without a slot of its own: a temporary.
                        let t = self.frame.temp(u64::from(f.size), u64::from(f.align));
                        self.arg_into(*a, t, f.size)?;
                        t
                    }
                },
            };
            homes.push(home(self, i, s));
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
                let h = home(self, direct + j, s + layout.fields.offset(j).bytes() as u32);
                homes.push(h);
            }
        }
        if sig.caller_location {
            let t = if island { Self::out(self.island_block() + sig.fields[n].offset) } else { self.temp8() };
            self.caller_location_into(source_info, t)?;
            homes.push(t);
        }
        if island {
            self.outgoing(self.island_block() + sig.block_size);
        }
        Ok(homes)
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
        let loc = self.body.caller_location_span(source_info, own, tcx, |span| CallerLoc::Const(tcx.span_as_caller_location(span)));
        match loc {
            CallerLoc::Incoming(s) => self.mov(d, s, 8),
            CallerLoc::Const(c) => {
                let layout = self.layout_of(tcx.caller_location_ty())?;
                self.const_value_into(c, layout, Loc::Slot(d))?;
            }
        }
        Ok(())
    }

    /// The destination slot of a call, and whether it must be stored to memory afterwards.
    /// An sret callee gets its address, so it escapes ([`FnCx::escape`]).
    fn call_dest(&mut self, cont: &CallCont<'tcx>, sig: &AbiSig<'tcx>) -> Result<(u32, bool), NeedsNative> {
        let (d, base, store) = match cont.dest {
            Some(PlaceVal { loc: Loc::Slot(d), meta: None, base, .. }) => (d, base, false),
            Some(PlaceVal { loc: Loc::Mem { .. }, meta: None, .. }) | None => {
                let t = self.frame.temp(sig.output.size.bytes(), sig.output.align.abi.bytes());
                (t, None, cont.dest.is_some())
            }
            Some(PlaceVal { meta: Some(_), .. }) => return native("unsized call destination"),
        };
        if sig.ret_kind == RET_SRET {
            self.escape(d, base)?;
        }
        Ok((d, store))
    }

    /// After the call instruction: stores a destination in memory, then continues at the
    /// target (or traps if the call diverges).
    fn finish_call(&mut self, cont: CallCont<'tcx>, d: u32, store: bool) -> Result<(), NeedsNative> {
        if store && let Some(dest) = cont.dest {
            self.with_cuts(dest.layout, |fx| fx.store(dest.loc, d, dest.layout.size.bytes() as u32));
        }
        self.continue_at(&cont)
    }

    /// Continues after a call (or a lowered intrinsic): at its target block, or traps if it
    /// diverges.
    pub(super) fn continue_at(&mut self, cont: &CallCont<'tcx>) -> Result<(), NeedsNative> {
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
    pub fn drop_terminator(&mut self, place: Place<'tcx>, target: BasicBlock, unwind: UnwindAction) -> Result<(), NeedsNative> {
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
        let ptr_size = if pv.meta.is_some() { 16 } else { 8 };
        let ptr = self.frame.temp(u64::from(ptr_size), 8);
        self.addr_into(ptr, pv.loc, pv.base)?;
        if let Some(m) = pv.meta {
            self.mov(ptr + 8, m, 8);
        }
        if self.cx.vm.contains(&glue) {
            // The glue of an unsized type takes the wide pointer.
            let sig = self.abi_sig(glue)?;
            let homes = self.write_args(&sig, &[ArgSrc::Slot(ptr)], *self.body.source_info(rustc_middle::mir::Location::START), false)?;
            // The glue returns `()`: `call 0, f, 0`, then the jump to `target`.
            return self.emit_call(Target::Direct(Callee::DropGlue(glue)), &sig, &homes, CallCont { dest: None, target: Some(target), unwind });
        }
        self.island(templates::DROP_IN_PLACE, &[ty.into()], &[(ptr, ptr_size)], Some(unwind));
        self.jump(target);
        Ok(())
    }
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Drop of a trait object: the vtable's `drop_in_place` entry (null if the type needs no
    /// drop), called with the data pointer, as cg_ssa does.
    fn virtual_drop(&mut self, pv: PlaceVal<'tcx>, target: BasicBlock, unwind: UnwindAction) -> Result<(), NeedsNative> {
        let Some(vtable) = pv.meta else { return native("trait object without metadata") };
        let f = self.temp8();
        let idx = ty::COMMON_VTABLE_ENTRIES_DROPINPLACE as u32;
        self.op(Opcode::LoadW64, &[f, vtable, idx * 8]);
        self.br_imm(IntOp::Eq, Width::W64, f, 0, false, target);
        let ptr = self.temp8();
        self.addr_into(ptr, pv.loc, pv.base)?;
        // `unsafe fn(*mut ())`: the pointer in the first integer register.
        let reg = ArgReg { xmm: false, size: 8, index: 0 };
        let at = self.op(Opcode::CallPtr, &[0, f, 0, ptr, reg.word()]);
        let plan = ArgPlan { locs: vec![vec![ArgLoc::Reg { reg, off: 0 }]], stack_size: 0 };
        self.cert_call(at, CallKind::VirtualDrop, Some(&plan), 0, 0);
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

/// The kind `ret` loads for the call kind `k`: integer parts rounded up to the width of a
/// load ([`ryo_bytecode::asm::RET_SRET`]).
pub fn load_kind(k: u32) -> u32 {
    let parts: Vec<RetPart> = ret_parts(k, false)
        .expect("register parts")
        .into_iter()
        .flatten()
        .map(|p| if p.xmm { p } else { RetPart { size: p.size.next_power_of_two(), ..p } })
        .collect();
    ret_kind(&parts)
}

/// A call's MIR arguments as argument sources.
fn arg_srcs<'b, 'tcx>(args: &'b [Spanned<Operand<'tcx>>]) -> Vec<ArgSrc<'b, 'tcx>> {
    args.iter().map(|a| ArgSrc::Operand(&a.node)).collect()
}
