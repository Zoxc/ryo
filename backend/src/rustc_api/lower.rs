//! MIR → bytecode, one function at a time (design/lowering.md).
//!
//! [`lower`] is the seam between the pipeline (`partition.rs`) and the lowering: it takes one
//! instance and returns its code plus everything the merge pass needs to place it in the
//! image, or [`NeedsNative`] if the function must stay native as a whole.
//!
//! Milestone 3 lowers only a small subset: `Item` instances with the Rust ABI whose bodies
//! consist of moves of whole locals, scalar constants, direct calls of other VM functions in
//! this image, `goto`, `return` and `unreachable`. Everything else reports `NeedsNative`, and
//! the full lowering replaces this module's body later. The interface below is the one it
//! keeps.

use rustc_abi::ExternAbi;
use rustc_middle::mir::{
    self, BasicBlock, Body, Local, Operand, Place, Rvalue, StatementKind, TerminatorKind, UnwindAction,
};
use rustc_middle::ty::{self, GenericArgsRef, Instance, InstanceKind, Ty, TyCtxt, TypingEnv};
use rustc_span::Symbol;
use ryo_bytecode::abi::{self, ArgField, HEADER_SIZE};
use ryo_bytecode::image::{CleanupEntry, TERMINATE};
use ryo_bytecode::insn::{CodeBuf, Func, Insn, Opcode, Slot, Target};

/// A lowered function. Code positions are word offsets from the function's start.
pub struct LoweredFn<'tcx> {
    pub code: Vec<u32>,
    /// Operands the merge pass fills in, once every function's index and symbol is known.
    pub relocs: Vec<CodeReloc<'tcx>>,
    /// Island template instances the code needs (none in milestone 3).
    pub islands: Vec<IslandRequest<'tcx>>,
    /// Cleanup table entries (unsorted).
    pub cleanup: Vec<CleanupEntry>,
    pub frame_size: u32,
    pub max_outgoing: u32,
    pub arg_size: u32,
    pub ret_size: u32,
}

/// An operand the merge pass resolves.
// `Symbol` is part of the seam; the milestone 3 subset doesn't emit it yet.
#[allow(dead_code)]
pub enum CodeReloc<'tcx> {
    /// The `call` instruction at word `at` calls `callee`, which must be a VM function of this
    /// image: the merge pass fills in its function index and frame size. If `callee` stays
    /// native, the calling function is made native too (until calls to native code become
    /// islands).
    Call { at: u32, callee: Instance<'tcx> },
    /// The `sym` operand at word `at` refers to `target`'s symbol: its portal if it is a VM
    /// function (which then gets one), the native definition otherwise.
    Symbol { at: u32, target: Instance<'tcx> },
}

/// An island the code calls: the template (by diagnostic item name) and its generic args. The
/// merge pass deduplicates requests, adds the instances to the native CGU, and fills the
/// island instruction's `sym` operand at word `at`.
// Part of the seam; the milestone 3 subset makes no island requests yet.
#[allow(dead_code)]
pub struct IslandRequest<'tcx> {
    pub at: u32,
    pub template: Symbol,
    pub args: GenericArgsRef<'tcx>,
}

/// Why a function stays native.
#[derive(Debug)]
pub struct NeedsNative(pub String);

fn native<T>(why: impl Into<String>) -> Result<T, NeedsNative> {
    Err(NeedsNative(why.into()))
}

/// The signature and argument block of an `Item` instance with the Rust ABI.
pub struct Sig<'tcx> {
    pub inputs: Vec<Ty<'tcx>>,
    pub output: Ty<'tcx>,
    /// Per input: offset, size and alignment in the argument block (`tcx.layout_of` of the
    /// tuple of the inputs, design/lowering.md#frame-slots).
    pub fields: Vec<ArgField>,
    pub block_size: u32,
}

/// The ABI signature of `instance` if the subset supports it: Rust ABI, no C-variadic, no
/// `#[track_caller]`, no rust-call spreading.
pub fn rust_sig<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> Result<Sig<'tcx>, NeedsNative> {
    let typing_env = TypingEnv::fully_monomorphized();
    let InstanceKind::Item(def_id) = instance.def else { return native("not an Item instance") };
    if tcx.is_closure_like(def_id) {
        return native("closure");
    }
    let fn_ty = instance.ty(tcx, typing_env);
    if !fn_ty.is_fn() {
        return native("not a function");
    }
    let sig = tcx.normalize_erasing_late_bound_regions(typing_env, fn_ty.fn_sig(tcx));
    if sig.abi() != ExternAbi::Rust {
        return native(format!("{} ABI", sig.abi()));
    }
    if sig.c_variadic() {
        return native("C-variadic");
    }
    if instance.def.requires_caller_location(tcx) {
        return native("#[track_caller]");
    }
    let inputs = sig.inputs().to_vec();
    let tuple = Ty::new_tup(tcx, &inputs);
    let layout = tcx.layout_of(typing_env.as_query_input(tuple)).map_err(layout_error)?;
    let fields: Vec<ArgField> = (0..inputs.len())
        .map(|i| {
            let f = layout.field(&LayoutCx(tcx), i);
            ArgField {
                offset: layout.fields.offset(i).bytes() as u32,
                size: f.size.bytes() as u32,
                align: f.align.abi.bytes() as u32,
            }
        })
        .collect();
    let block = abi::arg_block(&fields, layout.size.bytes() as u32, layout.align.abi.bytes() as u32)
        .map_err(|e| NeedsNative(format!("argument block: {e:?}")))?;
    Ok(Sig { inputs, output: sig.output(), block_size: block.size(), fields })
}

/// `layout.field(cx, i)` needs a layout context; the `TyCtxt` plus a monomorphic typing env.
struct LayoutCx<'tcx>(TyCtxt<'tcx>);

impl<'tcx> ty::layout::HasTyCtxt<'tcx> for LayoutCx<'tcx> {
    fn tcx(&self) -> TyCtxt<'tcx> {
        self.0
    }
}

impl<'tcx> ty::layout::HasTypingEnv<'tcx> for LayoutCx<'tcx> {
    fn typing_env(&self) -> TypingEnv<'tcx> {
        TypingEnv::fully_monomorphized()
    }
}

impl rustc_abi::HasDataLayout for LayoutCx<'_> {
    fn data_layout(&self) -> &rustc_abi::TargetDataLayout {
        &self.0.data_layout
    }
}

/// Lowers `instance` to bytecode, or says why it must stay native.
pub fn lower<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> Result<LoweredFn<'tcx>, NeedsNative> {
    let sig = rust_sig(tcx, instance)?;
    let def_id = instance.def_id();
    let attrs = tcx.codegen_instance_attrs(instance.def);
    if attrs.flags.contains(rustc_middle::middle::codegen_fn_attrs::CodegenFnAttrFlags::NAKED) {
        return native("#[naked]");
    }
    if !attrs.target_features.is_empty() {
        return native("#[target_feature]");
    }
    if !tcx.is_mir_available(def_id) {
        return native("no MIR");
    }
    let body = tcx.instance_mir(instance.def);
    if body.spread_arg.is_some() {
        return native("spread argument");
    }
    Lowering::new(tcx, instance, body, &sig)?.run()
}

/// Per-local frame slot: offset and size.
#[derive(Clone, Copy)]
struct LocalSlot {
    off: u32,
    size: u32,
}

struct Lowering<'a, 'tcx> {
    tcx: TyCtxt<'tcx>,
    instance: Instance<'tcx>,
    body: &'a Body<'tcx>,
    slots: Vec<LocalSlot>,
    frame_size: u32,
    arg_size: u32,
    max_outgoing: u32,
    code: CodeBuf,
    relocs: Vec<CodeReloc<'tcx>>,
    cleanup: Vec<CleanupEntry>,
    /// (instruction, target operand index, block) branches to patch.
    branches: Vec<(u32, usize, BasicBlock)>,
}

impl<'a, 'tcx> Lowering<'a, 'tcx> {
    fn new(
        tcx: TyCtxt<'tcx>,
        instance: Instance<'tcx>,
        body: &'a Body<'tcx>,
        sig: &Sig<'tcx>,
    ) -> Result<Self, NeedsNative> {
        let typing_env = TypingEnv::fully_monomorphized();
        let mut slots = Vec::with_capacity(body.local_decls.len());
        let mut end = HEADER_SIZE + sig.block_size;
        for (local, decl) in body.local_decls.iter_enumerated() {
            let ty = mono(tcx, instance, decl.ty);
            let layout = tcx.layout_of(typing_env.as_query_input(ty)).map_err(layout_error)?;
            if layout.is_unsized() {
                return native("unsized local");
            }
            let align = layout.align.abi.bytes() as u32;
            if align > abi::FRAME_ALIGN {
                return native("local aligned above 16");
            }
            let size = layout.size.bytes() as u32;
            let i = local.as_usize();
            if (1..=body.arg_count).contains(&i) {
                let f = sig.fields[i - 1];
                if f.size != size {
                    return native("argument local doesn't match the signature");
                }
                slots.push(LocalSlot { off: HEADER_SIZE + f.offset, size });
            } else {
                let off = end.next_multiple_of(align.max(1));
                end = off + size;
                slots.push(LocalSlot { off, size });
            }
        }
        if body.arg_count != sig.inputs.len() {
            return native("argument count doesn't match the signature");
        }
        Ok(Lowering {
            tcx,
            instance,
            body,
            slots,
            frame_size: abi::frame_size(end),
            arg_size: sig.block_size,
            max_outgoing: 0,
            code: CodeBuf::new(),
            relocs: Vec::new(),
            cleanup: Vec::new(),
            branches: Vec::new(),
        })
    }

    fn run(mut self) -> Result<LoweredFn<'tcx>, NeedsNative> {
        let body = self.body;
        let order: Vec<BasicBlock> = body.basic_blocks.indices().collect();
        let mut starts = vec![u32::MAX; order.len()];
        for (n, &bb) in order.iter().enumerate() {
            let data = &body.basic_blocks[bb];
            if data.is_cleanup {
                // Only reachable through unwinding, which needs cleanup entries (not yet).
                continue;
            }
            starts[bb.as_usize()] = self.code.pos();
            for stmt in &data.statements {
                self.statement(&stmt.kind)?;
            }
            let next = order.get(n + 1).copied();
            self.terminator(&data.terminator().kind, next)?;
        }
        for &(at, operand, bb) in &self.branches {
            let target = starts[bb.as_usize()];
            if target == u32::MAX {
                return native("branch to a cleanup block");
            }
            self.code.set_target(at, operand, target);
        }
        let ret_size = self.slots[mir::RETURN_PLACE.as_usize()].size;
        Ok(LoweredFn {
            code: self.code.words,
            relocs: self.relocs,
            islands: Vec::new(),
            cleanup: self.cleanup,
            frame_size: self.frame_size,
            max_outgoing: self.max_outgoing,
            arg_size: self.arg_size,
            ret_size,
        })
    }

    fn local_place(&self, place: &Place<'tcx>) -> Result<Local, NeedsNative> {
        if !place.projection.is_empty() {
            return native("place projection");
        }
        Ok(place.local)
    }

    fn statement(&mut self, kind: &StatementKind<'tcx>) -> Result<(), NeedsNative> {
        match kind {
            StatementKind::Assign(b) => {
                let (place, rvalue) = &**b;
                let d = self.local_place(place)?;
                let d = self.slots[d.as_usize()];
                match rvalue {
                    Rvalue::Use(op, _) => self.operand_to(op, d.off, d.size),
                    Rvalue::Repeat(..) => native("Repeat"),
                    Rvalue::Ref(..) => native("Ref"),
                    Rvalue::ThreadLocalRef(..) => native("ThreadLocalRef"),
                    Rvalue::RawPtr(..) => native("RawPtr"),
                    Rvalue::Cast(..) => native("Cast"),
                    Rvalue::BinaryOp(..) => native("BinaryOp"),
                    Rvalue::UnaryOp(..) => native("UnaryOp"),
                    Rvalue::Discriminant(..) => native("Discriminant"),
                    Rvalue::Aggregate(..) => native("Aggregate"),
                    Rvalue::CopyForDeref(..) => native("CopyForDeref"),
                    Rvalue::WrapUnsafeBinder(..) => native("WrapUnsafeBinder"),
                    Rvalue::Reborrow(..) => native("Reborrow"),
                }
            }
            StatementKind::StorageLive(_)
            | StatementKind::StorageDead(_)
            | StatementKind::FakeRead(_)
            | StatementKind::PlaceMention(_)
            | StatementKind::AscribeUserType(..)
            | StatementKind::Coverage(_)
            | StatementKind::ConstEvalCounter
            | StatementKind::Nop
            | StatementKind::BackwardIncompatibleDropHint { .. } => Ok(()),
            StatementKind::SetDiscriminant { .. } => native("SetDiscriminant"),
            StatementKind::Intrinsic(_) => native("intrinsic statement"),
        }
    }

    /// Writes the value of `op` (of `size` bytes) to the frame slot at `d`.
    fn operand_to(&mut self, op: &Operand<'tcx>, d: u32, size: u32) -> Result<(), NeedsNative> {
        match op {
            Operand::Copy(place) | Operand::Move(place) => {
                let s = self.slots[self.local_place(place)?.as_usize()];
                self.mov(d, s.off, size);
                Ok(())
            }
            Operand::Constant(c) => {
                if size == 0 {
                    return Ok(());
                }
                let typing_env = TypingEnv::fully_monomorphized();
                let c = mono(self.tcx, self.instance, c.const_);
                let Some(int) = c.try_eval_scalar_int(self.tcx, typing_env) else {
                    return native("non-scalar constant");
                };
                if int.size().bytes() as u32 != size {
                    return native("constant size mismatch");
                }
                let bits = int.to_bits(int.size());
                let d = Slot(d);
                self.code.emit(&match size {
                    1 => Insn::ImmW8 { d, imm: bits as u32 },
                    2 => Insn::ImmW16 { d, imm: bits as u32 },
                    4 => Insn::ImmW32 { d, imm: bits as u32 },
                    8 => Insn::ImmW64 { d, imm: bits as u64 },
                    16 => Insn::ImmW128 { d, imm: bits },
                    _ => return native("odd-sized scalar constant"),
                });
                Ok(())
            }
            Operand::RuntimeChecks(_) => native("RuntimeChecks"),
        }
    }

    fn mov(&mut self, d: u32, s: u32, size: u32) {
        if size == 0 || d == s {
            return;
        }
        let (d, s) = (Slot(d), Slot(s));
        self.code.emit(&match size {
            1 => Insn::MovW8 { d, s },
            2 => Insn::MovW16 { d, s },
            4 => Insn::MovW32 { d, s },
            8 => Insn::MovW64 { d, s },
            16 => Insn::MovW128 { d, s },
            len => Insn::Copy { d, s, len },
        });
    }

    fn jump(&mut self, target: BasicBlock, next: Option<BasicBlock>) {
        if Some(target) != next {
            let at = self.code.emit(&Insn::Jmp { t: Target(0) });
            self.branches.push((at, 0, target));
        }
    }

    fn terminator(&mut self, kind: &TerminatorKind<'tcx>, next: Option<BasicBlock>) -> Result<(), NeedsNative> {
        match kind {
            TerminatorKind::Goto { target } => {
                self.jump(*target, next);
                Ok(())
            }
            TerminatorKind::Return => {
                let r = self.slots[mir::RETURN_PLACE.as_usize()];
                self.code.emit(&Insn::Ret { s: Slot(r.off), len: r.size });
                Ok(())
            }
            TerminatorKind::Unreachable => {
                self.code.emit(&Insn::Unreachable {});
                Ok(())
            }
            TerminatorKind::Call { func, args, destination, target, unwind, .. } => {
                self.call(func, args, destination, *target, *unwind, next)
            }
            TerminatorKind::SwitchInt { .. } => native("SwitchInt"),
            TerminatorKind::UnwindResume => native("UnwindResume"),
            TerminatorKind::UnwindTerminate(_) => native("UnwindTerminate"),
            TerminatorKind::Drop { .. } => native("Drop"),
            TerminatorKind::TailCall { .. } => native("TailCall"),
            TerminatorKind::Assert { .. } => native("Assert"),
            TerminatorKind::InlineAsm { .. } => native("inline asm"),
            TerminatorKind::Yield { .. }
            | TerminatorKind::CoroutineDrop
            | TerminatorKind::FalseEdge { .. }
            | TerminatorKind::FalseUnwind { .. } => {
                rustc_middle::bug!("{kind:?} in runtime MIR of {}", self.instance)
            }
        }
    }

    fn call(
        &mut self,
        func: &Operand<'tcx>,
        args: &[rustc_span::Spanned<Operand<'tcx>>],
        destination: &Place<'tcx>,
        target: Option<BasicBlock>,
        unwind: UnwindAction,
        next: Option<BasicBlock>,
    ) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let typing_env = TypingEnv::fully_monomorphized();
        let fty = mono(tcx, self.instance, func.ty(self.body, tcx));
        let ty::FnDef(def_id, fn_args) = *fty.kind() else { return native("indirect call") };
        let fn_args = fn_args.no_bound_vars().expect("monomorphic callee");
        let callee = Instance::expect_resolve(tcx, typing_env, def_id, fn_args, rustc_span::DUMMY_SP);
        if !matches!(callee.def, InstanceKind::Item(_)) || !tcx.should_codegen_locally(callee) {
            return native(no_trim(|| format!("call of {callee} (needs an island)")));
        }
        let Some(target) = target else { return native("diverging call") };
        match unwind {
            UnwindAction::Continue | UnwindAction::Unreachable => {}
            UnwindAction::Terminate(_) => {}
            UnwindAction::Cleanup(_) => return native("call with a cleanup block"),
        }
        let sig = rust_sig(tcx, callee)?;
        if sig.inputs.len() != args.len() {
            return native("call argument count mismatch");
        }
        let out = self.frame_size + HEADER_SIZE;
        for (arg, field) in args.iter().zip(&sig.fields) {
            self.operand_to(&arg.node, out + field.offset, field.size)?;
        }
        self.max_outgoing = self.max_outgoing.max(HEADER_SIZE + sig.block_size);
        let d = self.slots[self.local_place(destination)?.as_usize()];
        let at = self.code.emit(&Insn::Call { d: Slot(d.off), f: Func(0), frame_size: 0 });
        if let UnwindAction::Terminate(_) = unwind {
            self.cleanup.push(CleanupEntry { offset: at, target: TERMINATE });
        }
        self.relocs.push(CodeReloc::Call { at, callee });
        self.jump(target, next);
        Ok(())
    }
}

/// Formats with untrimmed paths: trimmed ones may only be computed for a diagnostic that is
/// actually emitted.
fn no_trim(f: impl FnOnce() -> String) -> String {
    rustc_middle::ty::print::with_no_trimmed_paths!(f())
}

fn layout_error(e: &ty::layout::LayoutError<'_>) -> NeedsNative {
    NeedsNative(no_trim(|| format!("layout: {e:?}")))
}

/// Word offset of operand `i` within an instruction of opcode `op`.
pub fn operand_offset(op: Opcode, i: usize) -> usize {
    op.info().operand_offset(i).expect("operand after a list")
}

fn mono<'tcx, T>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>, v: T) -> T
where
    T: ty::TypeFoldable<TyCtxt<'tcx>>,
{
    instance.instantiate_mir_and_normalize_erasing_regions(
        tcx,
        TypingEnv::fully_monomorphized(),
        ty::EarlyBinder::bind(tcx, v),
    )
}
