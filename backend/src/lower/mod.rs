//! MIR → machine code, one function at a time (design/lowering.md): each MIR construct becomes
//! VM instructions, which `asm::Asm` turns into their x86 sequences as they are emitted.
//!
//! [`lower`] is the seam between the pipeline (`partition.rs`) and the lowering: it takes one
//! instance and returns its code plus everything the merge pass needs to place it in the
//! image ([`LoweredFn`]), or [`NeedsNative`] if the function must stay native as a whole.
//!
//! One module per concern, each extending [`FnCx`] with its own `impl` block:
//!
//! | Module | Concern |
//! |---|---|
//! | `mod.rs` | the seam, [`FnCx`], the block loop, branch and unwind fixups, landing pads |
//! | [`sig`] | ABI signatures and argument blocks |
//! | [`frame`] | slot allocation: arguments, locals, temporaries, the spread-arg prologue |
//! | [`emit`] | opcode selection by family and width, immediates |
//! | [`place`] | places → frame slots or memory operands |
//! | [`operand`] | operands and value moves between slots and memory |
//! | [`rvalue`] | statements and rvalues |
//! | [`adt`] | aggregates and discriminants (enums via layout) |
//! | [`cast`] | casts and pointer coercions |
//! | [`binop`] | binary and unary operations |
//! | [`terminator`] | terminators other than calls |
//! | [`call`] | calls: VM calls, `call.ext`, call islands, drops |
//! | [`intrinsic`] | intrinsic calls |
//! | [`simd`] | `simd_*` intrinsics with an instruction |
//! | [`constant`] | constants and constant-pool references |
//! | [`island`] | island instructions and requests |
//!
//! Every MIR enum is matched exhaustively (no `_` arm), so a MIR change in a toolchain bump is
//! a compile error. What isn't implemented yet reports [`NeedsNative`] with a precise reason
//! (`RYO_STATS=2` prints them).

mod adt;
mod binop;
mod call;
mod cast;
mod cert;
mod constant;
mod emit;
mod frame;
mod intrinsic;
mod island;
mod operand;
mod place;
mod rvalue;
mod sig;
mod simd;
mod terminator;

use rustc_data_structures::fx::FxHashSet;
use rustc_middle::mir::interpret::AllocId;
use rustc_middle::mir::{BasicBlock, Body};
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, GenericArgsRef, Instance, InstanceKind, Ty, TyCtxt, TypeVisitableExt, TypingEnv};
use rustc_span::Symbol;
use ryo_bytecode::asm::{self, Asm, InsnId, Label, Opnd, Unwind};
use ryo_bytecode::full::{Abs, Const, ElemKind, Func, Opcode, OperandKind, Site, Sym};

pub use self::constant::{is_import, is_tls_shim, vtable_alloc};
use self::emit::{IntOp, Width};
use self::frame::{Frame, OUT_END};
pub use self::operand::SPLIT_MAX;
pub use self::sig::{AbiSig, abi_sig};

/// PE: the 32 bytes of shadow space at the bottom of every frame (`FnCx::finish`).
const PE_SHADOW: u32 = 32;

/// A lowered function: its machine code, whose `Func`, `Sym`, `Site`, `Const` and `Data`
/// references are indices into `relocs` until the merge pass resolves them.
pub struct LoweredFn<'tcx> {
    pub code: asm::Encoded,
    /// What the code refers to, resolved by the merge pass once every function's index and
    /// symbol is known.
    pub relocs: Vec<CodeReloc<'tcx>>,
    /// The frame size `F`: locals and the largest outgoing argument block.
    pub frame_size: u32,
    pub arg_size: u32,
    /// The certificate for the Lean lowering check, as JSON, if [`LowerCx::cert`] (`cert.rs`).
    pub cert: Option<String>,
    pub ret_size: u32,
    /// See [`ryo_bytecode::image::FuncEntry::ret_kind`].
    pub ret_kind: u32,
}

/// Something the code refers to, which the merge pass resolves. The code names it by its
/// index in [`LoweredFn::relocs`], as the operand of the kind the variant says.
pub enum CodeReloc<'tcx> {
    /// A `func` operand (`call`, `tail_call`): `callee`, a VM function of this image (one of
    /// [`LowerCx::vm`]); the merge pass fills in its function index. If `callee` ends up
    /// native after all, the caller is lowered again.
    Call { callee: Instance<'tcx> },
    /// A `sym` operand: `target`'s symbol: a VM function's (which the image then defines
    /// globally), the native definition otherwise (made visible to the image if it is
    /// internal).
    Symbol { target: Instance<'tcx> },
    /// A `sym` operand: the static `def_id` (made visible to the image if it is internal).
    Static { def_id: rustc_hir::def_id::DefId },
    /// A `k` (or `addr.const`) operand: `offset` bytes into the constant-pool copy of `alloc`.
    Const { alloc: AllocId, offset: u32 },
    /// A `k` operand: a constant-pool allocation of these bytes.
    Bytes { bytes: Vec<u8>, align: u32 },
    /// An `addr.const` operand: `offset` bytes into the fixup-area copy of `alloc` (PE: an
    /// allocation pointing at imports, `constant::needs_fixup`).
    Data { alloc: AllocId, offset: u32 },
    /// An `isl` operand: an island the code calls, the template (by diagnostic item name) and
    /// its generic args. The merge pass deduplicates them, adds the instances to the native
    /// CGU, and uses the instance's symbol.
    Island { template: Symbol, args: GenericArgsRef<'tcx> },
}

/// Why a function stays native.
#[derive(Debug)]
pub struct NeedsNative(pub String);

pub(crate) fn native<T>(why: impl Into<String>) -> Result<T, NeedsNative> {
    Err(NeedsNative(why.into()))
}

/// What every function's lowering may read: shared, read-only.
pub struct LowerCx<'a, 'tcx> {
    /// The functions assumed to be VM functions of this image (its CGU). A call of one of them
    /// is a `call`; a VM function of another image is called by symbol (`call.sym`), as a
    /// native Rust function; any other local callee is called through an island.
    pub vm: &'a FxHashSet<Instance<'tcx>>,
    /// How the machine code is generated.
    pub mode: asm::Mode,
    /// Whether to record the certificate for the Lean lowering check (`cert.rs`).
    pub cert: bool,
    /// `RYO_ASM_CHECK`: re-encode the machine code and check it.
    pub asm_check: bool,
}

/// Lowers `instance` to bytecode, or says why it must stay native.
pub fn lower<'tcx>(tcx: TyCtxt<'tcx>, cx: &LowerCx<'_, 'tcx>, instance: Instance<'tcx>) -> Result<LoweredFn<'tcx>, NeedsNative> {
    let sig = vm_fn_sig(tcx, instance)?;
    let body = tcx.instance_mir(instance.def);
    let mut fx = FnCx::new(tcx, cx, instance, body, &sig)?;
    fx.prologue(&sig)?;
    fx.cert_prologue();
    fx.blocks()?;
    fx.finish(&sig)
}

/// The signature of `instance` if it can be a VM function: a Rust-ABI function whose
/// arguments and return value the backend can pass in the platform calling convention
/// (design/backend.md#pipeline, step 2).
pub fn vm_fn_sig<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    match instance.def {
        InstanceKind::Item(def_id) => {
            // `instance_mir` reads a constructor's body from `mir_for_ctfe`, which metadata
            // always has for constructors, while `is_mir_available` asks for `optimized_mir`,
            // which it never has for them (`should_encode_mir`,
            // `rustc_metadata/src/rmeta/encoder.rs:1108`).
            let available = matches!(tcx.def_kind(def_id), rustc_hir::def::DefKind::Ctor(..)) || tcx.is_mir_available(def_id);
            if !available {
                return native("no MIR");
            }
        }
        // The VM reaches thread locals through this shim (`constant.rs`).
        InstanceKind::Shim(ty::ShimKind::ThreadLocal(_)) => return native("thread-local shim"),
        InstanceKind::Shim(_) => {}
        InstanceKind::Intrinsic(_) | InstanceKind::LlvmIntrinsic(_) | InstanceKind::Virtual(..) => {
            return native("no body");
        }
    }
    let attrs = tcx.codegen_instance_attrs(instance.def);
    if attrs.flags.contains(rustc_middle::middle::codegen_fn_attrs::CodegenFnAttrFlags::NAKED) {
        return native("#[naked]");
    }
    // Its nops are for patching native code (`-Zpatchable-function-entry`, which applies to
    // every function, is rejected).
    if attrs.patchable_function_entry.is_some() {
        return native("#[patchable_function_entry]");
    }
    // The images lay out VM functions at their own alignment.
    if attrs.alignment.is_some() {
        return native("#[align]");
    }
    // An EII implementation: cg_llvm defines the declaration's symbol as a forwarder to it
    // when it predefines the function (`add_function_aliases`,
    // `rustc_codegen_llvm/src/mono_item.rs`), which it doesn't do for a VM function.
    if !attrs.foreign_item_symbol_aliases.is_empty() {
        return native("EII implementation");
    }
    // An explicit `#[linkage]` other than `external` or `internal`: a weak or linkonce
    // definition may be replaced by another object's, which the image's direct `call`s would
    // bypass, an `available_externally` one must not be defined at all, and PE has no weak
    // definitions outside a comdat. cg_llvm handles all of them.
    if attrs.linkage.is_some_and(|l| !matches!(l, rustc_hir::attrs::Linkage::External | rustc_hir::attrs::Linkage::Internal)) {
        return native("#[linkage]");
    }
    // A `#[target_feature]` function whose features the crate already enables is codegened
    // exactly as without the attribute, so it can be VM code. Its ABI doesn't depend on the
    // features: the Rust ABI passes vectors indirectly (`rustc_target/src/callconv/mod.rs`,
    // #44367), and other ABIs stay native below. The MIR inliner only inlines callees whose
    // features are a subset, so what it inlined is checked with the body: an `llvm.*` link
    // or inline asm keeps the function native, and so does a `simd_*` intrinsic without an
    // instruction (`FnCx::strict_simd`).
    if !attrs.target_features.iter().all(|f| tcx.sess.internal_target_features.contains(&f.name)) {
        return native("#[target_feature] not enabled for the crate");
    }
    let sig = abi_sig(tcx, instance)?;
    if sig.conv != sig::CallConv::Rust {
        return native("non-Rust ABI");
    }
    Ok(sig)
}

/// Where unwinding out of a call-like instruction goes.
#[derive(Clone, Copy, PartialEq)]
enum UnwindTo {
    /// Out of the frame, to the caller.
    Continue,
    /// Through a landing pad ([`FnCx::unwind_targets`]) to this block.
    Block(BasicBlock),
    /// Through a landing pad to the function's stub calling the reason's lang item
    /// ([`FnCx::unwind_targets`]).
    Terminate(rustc_middle::mir::UnwindTerminateReason),
}

/// The per-function lowering state. Each module adds its own `impl` block.
pub struct FnCx<'a, 'tcx> {
    pub tcx: TyCtxt<'tcx>,
    pub cx: &'a LowerCx<'a, 'tcx>,
    pub instance: Instance<'tcx>,
    pub body: &'tcx Body<'tcx>,
    pub frame: Frame<'tcx>,
    pub asm: Asm,
    pub relocs: Vec<CodeReloc<'tcx>>,
    /// (call-like instruction, where unwinding out of it goes). Instructions without an entry
    /// can't unwind.
    cleanup: Vec<(InsnId, UnwindTo)>,
    /// Each block's label.
    block_labels: Vec<Label>,
    /// Reused operand buffer of [`FnCx::op`].
    scratch: Vec<Opnd<Label>>,
    /// Largest outgoing argument block of the calls made so far.
    pub max_outgoing: u32,
    /// Field offsets the pieces of a split block copy may not straddle ([`pieces`]), set
    /// by [`FnCx::with_cuts`] for the copy of a value of known layout.
    pub cuts: Vec<u32>,
    arg_size: u32,
    /// How the function returns ([`ryo_bytecode::asm::RET_SRET`]).
    pub ret_kind: u32,
    /// The block after the one being lowered, in code order (for fall-through).
    pub next_block: Option<BasicBlock>,
    /// For a `#[track_caller]` function: the slot of its incoming `&'static Location` (the
    /// last field of the argument block, design/lowering.md#caller-location).
    pub caller_location: Option<u32>,
    /// The current block's last statement, fused into its terminator (`terminator::Fused`).
    fused: Option<terminator::Fused<'tcx>>,
    /// The number of instructions emitted so far: the next one's `InsnId`.
    insns: u32,
    /// The certificate being recorded, if [`LowerCx::cert`].
    cert: Option<Box<cert::Recorder>>,
    /// A `#[target_feature]` function: a `simd_*` intrinsic without an instruction keeps it
    /// native instead of becoming an island, which is compiled without the features.
    pub strict_simd: bool,
    /// PE: lowering the pad region ([`Asm::begin_region`]), whose `rsp` isn't `fp - F`.
    pub in_region: bool,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    fn new(
        tcx: TyCtxt<'tcx>,
        cx: &'a LowerCx<'a, 'tcx>,
        instance: Instance<'tcx>,
        body: &'tcx Body<'tcx>,
        sig: &AbiSig<'tcx>,
    ) -> Result<Self, NeedsNative> {
        let frame = Frame::new(body, sig, |local| {
            let ty = mono(tcx, instance, body.local_decls[local].ty);
            layout_of(tcx, ty)
        })?;
        let mut asm = Asm::new(cx.mode);
        let block_labels = (0..body.basic_blocks.len()).map(|_| asm.label()).collect();
        let caller_location = sig.caller_location.then(|| *frame.arg_homes.last().expect("location input"));
        Ok(FnCx {
            tcx,
            cx,
            instance,
            body,
            frame,
            asm,
            relocs: Vec::new(),
            cleanup: Vec::new(),
            block_labels,
            scratch: Vec::new(),
            max_outgoing: 0,
            cuts: Vec::new(),
            arg_size: sig.plan.as_ref().map_or(0, |p| p.stack_size),
            ret_kind: sig.ret_kind,
            next_block: None,
            fused: None,
            insns: 0,
            cert: cx.cert.then(Box::default),
            caller_location,
            strict_simd: !tcx.codegen_instance_attrs(instance.def).target_features.is_empty(),
            in_region: false,
        })
    }

    /// Lowers every block, in index order. A block that is unreachable after
    /// monomorphization (behind a `SwitchInt` on a constant, as `if T::IS_ZST`, or on
    /// `ub_checks()`) is lowered as a lone `unreachable`, as cg_ssa does
    /// (`codegen_block_as_unreachable`), so its calls don't make the image refer to items the
    /// collector never collected for it (design/lowering.md#blocks). Cleanup blocks are only reached through landing
    /// pads; on PE they come last, in the pad region (design/vm.md#unwinding), after the
    /// body's unwind targets: the body's terminate stubs and their landing pads, then (the
    /// region's start) the cleanup landing pads, the cleanup blocks and their own terminate
    /// stubs. Without a cleanup landing pad there is no region, and the (unreachable) cleanup
    /// blocks stay in the body.
    fn blocks(&mut self) -> Result<(), NeedsNative> {
        let body = self.body;
        let uses = terminator::local_uses(body);
        let dead = frame::dead_after_read(body);
        let pe = self.cx.mode.pe;
        let reachable = rustc_middle::mir::traversal::mono_reachable_as_bitset(body, self.tcx, self.instance);
        let mut order: Vec<BasicBlock> = body.basic_blocks.indices().collect();
        if pe {
            order.sort_by_key(|&bb| body.basic_blocks[bb].is_cleanup);
        }
        // Where the cleanup blocks start in `order` (its length without any on PE).
        let cleanup_at = if pe { order.partition_point(|&bb| !body.basic_blocks[bb].is_cleanup) } else { order.len() };
        for (i, &bb) in order.iter().enumerate() {
            if i == cleanup_at {
                let entries = std::mem::take(&mut self.cleanup);
                let (pads, others): (Vec<_>, Vec<_>) = entries.into_iter().partition(|e| matches!(e.1, UnwindTo::Block(_)));
                self.unwind_targets(others)?;
                if !pads.is_empty() {
                    self.asm.begin_region();
                    self.in_region = true;
                }
                self.unwind_targets(pads)?;
            }
            let data = &body.basic_blocks[bb];
            self.bind(self.block_labels[bb.as_usize()]);
            self.next_block = order.get(i + 1).copied().filter(|_| i + 1 != cleanup_at);
            if !reachable.contains(bb) {
                self.fused = None;
                self.cert_block(bb.as_usize(), false);
                self.cert_dead();
                self.reset_temps();
                let start = self.insns;
                self.op(Opcode::Unreachable, &[]);
                self.cert_term(start);
                continue;
            }
            self.fused = self.fusable(data, &uses);
            self.cert_block(bb.as_usize(), self.fused.is_some());
            let stmts = &data.statements[..data.statements.len() - usize::from(self.fused.is_some())];
            // The locals dead after this block's statements, in order.
            let block_dead = &dead[dead.partition_point(|d| d.0.block < bb)..dead.partition_point(|d| d.0.block <= bb)];
            let mut block_dead = block_dead.iter().peekable();
            for (i, stmt) in stmts.iter().enumerate() {
                self.reset_temps();
                let start = self.insns;
                self.statement(stmt)?;
                self.cert_stmt(start);
                let here = rustc_middle::mir::Location { block: bb, statement_index: i };
                while let Some(&&(at, local)) = block_dead.peek()
                    && at <= here
                {
                    if at == here {
                        self.local_dead(local);
                    }
                    block_dead.next();
                }
            }
            self.reset_temps();
            let start = self.insns;
            self.terminator(data.terminator())?;
            self.cert_term(start);
        }
        let entries = std::mem::take(&mut self.cleanup);
        self.unwind_targets(entries)
    }

    /// Emits the unwind targets of the cleanup entries `entries`, and points each at its pad.
    ///
    /// First one stub per terminate reason the entries use: a call of the reason's lang item,
    /// as cg_ssa's terminate block (design/lowering.md#unwinding). Then one landing pad per
    /// distinct place unwinding goes to in this frame: `lpad x` (which stores the exception
    /// object in the function's exception slot `x`), then a jump to the cleanup block or
    /// terminate stub. A cleanup block may also be reached by a jump from another one, so the
    /// pads are separate from the blocks, and `lpad` runs once per landing.
    fn unwind_targets(&mut self, cleanup: Vec<(InsnId, UnwindTo)>) -> Result<(), NeedsNative> {
        // Few distinct targets per function: linear lookups (the reasons aren't `Hash`).
        let mut stubs = Vec::new();
        for &(_, to) in &cleanup {
            if let UnwindTo::Terminate(reason) = to
                && !stubs.iter().any(|&(r, _)| r == reason)
            {
                let at = self.asm.label();
                self.bind(at);
                self.reset_temps();
                self.next_block = None;
                let start = self.insns;
                self.terminate_call(reason, self.body.source_info(rustc_middle::mir::Location::START).clone())?;
                self.cert_stub(reason, start);
                stubs.push((reason, at));
            }
        }
        let mut pads: Vec<(UnwindTo, Label)> = Vec::new();
        for &(id, to) in &cleanup {
            let (target, catch) = match to {
                UnwindTo::Continue => {
                    self.asm.set_unwind(id, Unwind::Continue);
                    continue;
                }
                UnwindTo::Block(bb) => (self.block_labels[bb.as_usize()], false),
                // As cg_llvm's terminate pads: a catch-all, so it runs even when nothing up
                // the stack catches.
                UnwindTo::Terminate(r) => (stubs.iter().find(|s| s.0 == r).expect("terminate stub").1, true),
            };
            let pad = match pads.iter().find(|p| p.0 == to) {
                Some(&(_, at)) => at,
                None => {
                    let at = self.asm.label();
                    self.bind(at);
                    let start = self.insns;
                    self.op(Opcode::Lpad, &[self.frame.exception_slot()]);
                    self.jmp_label(target);
                    self.cert_pad(start, if let UnwindTo::Block(bb) = to { Some(bb.as_u32()) } else { None });
                    pads.push((to, at));
                    at
                }
            };
            self.asm.set_unwind(id, Unwind::Pad { pad, catch });
        }
        Ok(())
    }

    /// Finishes the machine code, now that the frame size is known.
    fn finish(mut self, sig: &AbiSig<'tcx>) -> Result<LoweredFn<'tcx>, NeedsNative> {
        if self.cx.mode.pe {
            // The shadow space of the Win64 handlers, islands and calls, reserved once at the
            // frame's bottom (design/vm.md#frames).
            self.outgoing(PE_SHADOW);
        }
        let frame_size = self.frame.frame_size(self.max_outgoing)?;
        let cert = self.cert_json(frame_size, sig.plan.as_ref());
        let code = std::mem::replace(&mut self.asm, Asm::new(self.cx.mode)).finish(frame_size, |s| frame::frame_offset(s, frame_size) as u32);
        if self.cx.asm_check {
            reencode_check(&code, self.cx.mode);
        }
        let ret = self.frame.locals[rustc_middle::mir::RETURN_PLACE];
        Ok(LoweredFn {
            code,
            relocs: self.relocs,
            frame_size,
            arg_size: self.arg_size,
            ret_size: ret.layout.size.bytes() as u32,
            ret_kind: self.ret_kind,
            cert,
        })
    }

    // ---- emission ----

    /// Emits an instruction.
    pub fn emit(&mut self, op: Opcode, ops: Vec<Opnd<Label>>) -> InsnId {
        self.insn(op, &ops)
    }

    /// Emits `op` with operands `ops`, counting it.
    fn insn(&mut self, op: Opcode, ops: &[Opnd<Label>]) -> InsnId {
        self.insns += 1;
        // PE: a handler's fifth argument goes past the shadow space (`asm::handler_arg`).
        if self.cx.mode.pe
            && ryo_bytecode::asm::has_handler(op)
            && ryo_bytecode::asm::layout(op, self.cx.mode).regs as usize > ryo_bytecode::asm::PE_ARG_REGS
        {
            self.outgoing(PE_SHADOW + 8);
        }
        self.asm.insn(op, ops)
    }

    /// `jmp` to `l`.
    pub fn jmp_label(&mut self, l: Label) {
        self.insn(Opcode::Jmp, &[Opnd::Target(l)]);
    }

    /// Binds `l` to the current position.
    pub fn bind(&mut self, l: Label) {
        self.asm.bind(l);
    }

    /// Emits an instruction without branch targets from its operand words, in the
    /// instruction-word encoding of each operand kind (`sym`, `func`, `site`, `k` operands:
    /// indices into [`FnCx::relocs`]).
    pub fn op(&mut self, op: Opcode, operands: &[u32]) -> InsnId {
        let mut ops = std::mem::take(&mut self.scratch);
        opnds(op, operands, &mut ops);
        let id = self.insn(op, &ops);
        self.scratch = ops;
        id
    }

    /// Emits a branch to `bb`: an instruction whose last operands are its polarity and target.
    /// With `neg`, it branches when its condition is false.
    pub fn op_branch(&mut self, op: Opcode, operands: &[u32], neg: bool, bb: BasicBlock) -> InsnId {
        let mut ops = std::mem::take(&mut self.scratch);
        opnds(op, operands, &mut ops);
        ops.push(Opnd::Neg(neg));
        ops.push(Opnd::Target(self.block_labels[bb.as_usize()]));
        let id = self.insn(op, &ops);
        self.scratch = ops;
        id
    }

    /// `bb`'s label.
    pub fn block_label(&self, bb: BasicBlock) -> Label {
        self.block_labels[bb.as_usize()]
    }

    /// Adds a reference for the merge pass to resolve; returns its index, the operand value
    /// that names it.
    pub fn reloc(&mut self, r: CodeReloc<'tcx>) -> u32 {
        self.relocs.push(r);
        self.relocs.len() as u32 - 1
    }

    /// Whether a `sym` operand naming `r` (a [`CodeReloc::Symbol`] or [`CodeReloc::Static`])
    /// loads through an indirect slot (PE imports, design/platforms.md): then the
    /// instruction takes its `.ind` form.
    pub fn sym_indirect(&self, r: &CodeReloc<'tcx>) -> bool {
        let flags = match *r {
            CodeReloc::Symbol { target } => crate::symbols::symbol_flags(self.tcx, target, crate::symbols::SymRole::Target),
            CodeReloc::Static { def_id } => crate::symbols::static_symbol_flags(self.tcx, def_id),
            _ => unreachable!("not a symbol"),
        };
        flags & ryo_bytecode::image::SYM_INDIRECT != 0
    }

    /// `addr.sym d, sym` of `r` (a [`CodeReloc::Symbol`] or [`CodeReloc::Static`]), or
    /// `addr.sym.ind` for an indirect slot.
    pub fn addr_sym(&mut self, d: u32, r: CodeReloc<'tcx>) {
        let op = if self.sym_indirect(&r) { Opcode::AddrSymInd } else { Opcode::AddrSym };
        let s = self.reloc(r);
        self.op(op, &[d, s]);
    }

    /// `jmp` to `bb`, unless it is the next block.
    pub fn jump(&mut self, bb: BasicBlock) {
        if Some(bb) != self.next_block {
            self.jmp_label(self.block_labels[bb.as_usize()]);
        }
    }

    /// Records the unwind action of the call-like instruction `at`
    /// (design/lowering.md#unwinding). `Unreachable` records nothing: the instruction can't
    /// unwind.
    pub fn unwind_entry(&mut self, at: InsnId, unwind: rustc_middle::mir::UnwindAction) {
        use rustc_middle::mir::UnwindAction;
        match unwind {
            UnwindAction::Continue => self.cleanup.push((at, UnwindTo::Continue)),
            UnwindAction::Cleanup(bb) => self.cleanup.push((at, UnwindTo::Block(bb))),
            UnwindAction::Terminate(reason) => self.cleanup.push((at, UnwindTo::Terminate(reason))),
            UnwindAction::Unreachable => {}
        }
    }

    /// `br.family.imm.w s, v` (`v` truncated to the width), branching to `bb` per `neg`.
    pub fn br_imm(&mut self, family: IntOp, w: Width, s: u32, v: u128, neg: bool, bb: BasicBlock) {
        let mut ops = vec![s];
        ops.extend(emit::imm_words(w, w.truncate(v)));
        self.op_branch(
            family.br_imm_at(w).unwrap_or_else(|| panic!("ryo lowering: no opcode br.{}.imm.{}", family.stem(), w.mnemonic())),
            &ops,
            neg,
            bb,
        );
    }

    /// The outgoing argument block's field at `off`: the slot at `fp - F + off`, once the
    /// frame size `F` is known (`frame.rs`).
    pub fn out(off: u32) -> u32 {
        debug_assert!(off < OUT_END);
        off
    }

    /// Where an island's argument block starts in the outgoing area: past the shadow space on
    /// PE, which the calls (handlers' too) may write while the block is being filled.
    pub fn island_block(&self) -> u32 {
        if self.cx.mode.pe { PE_SHADOW } else { 0 }
    }

    /// Notes an outgoing argument block of `size` bytes.
    pub fn outgoing(&mut self, size: u32) {
        self.max_outgoing = self.max_outgoing.max(size);
    }

    // ---- types ----

    pub fn mono<T: ty::TypeFoldable<TyCtxt<'tcx>>>(&self, v: T) -> T {
        mono(self.tcx, self.instance, v)
    }

    pub fn layout_of(&self, ty: Ty<'tcx>) -> Result<TyAndLayout<'tcx>, NeedsNative> {
        layout_of(self.tcx, ty)
    }

    pub fn lcx(&self) -> LayoutCx<'tcx> {
        LayoutCx(self.tcx)
    }
}

pub fn layout_of<'tcx>(tcx: TyCtxt<'tcx>, ty: Ty<'tcx>) -> Result<TyAndLayout<'tcx>, NeedsNative> {
    tcx.layout_of(TypingEnv::fully_monomorphized().as_query_input(ty)).map_err(layout_error)
}

/// `layout.field(cx, i)` and `for_variant` need a layout context: the `TyCtxt` plus a
/// monomorphic typing env.
#[derive(Clone, Copy)]
pub struct LayoutCx<'tcx>(pub TyCtxt<'tcx>);

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

/// Formats with untrimmed paths: trimmed ones may only be computed for a diagnostic that is
/// actually emitted.
pub fn no_trim(f: impl FnOnce() -> String) -> String {
    rustc_middle::ty::print::with_no_trimmed_paths!(f())
}

fn layout_error(e: &ty::layout::LayoutError<'_>) -> NeedsNative {
    NeedsNative(no_trim(|| format!("layout: {e:?}")))
}

/// The operands of `op` from their instruction words, up to the first branch target (which
/// the callers add as labels). A `Words` list takes the rest of `w`.
fn opnds(op: Opcode, w: &[u32], out: &mut Vec<Opnd<Label>>) {
    out.clear();
    let mut pos = 0;
    for o in op.info().operands {
        if pos == w.len() && matches!(o.kind, OperandKind::Neg | OperandKind::Target) {
            break;
        }
        let wide = |n: usize| (0..n).fold(0u128, |v, i| v | (w[pos + i] as u128) << (32 * i));
        out.push(match o.kind {
            OperandKind::Slot => Opnd::Slot(w[pos] as i32),
            OperandKind::Mem => Opnd::Mem(w[pos] as i32, w[pos + 1] as i32),
            OperandKind::U8 | OperandKind::U16 | OperandKind::U32 => Opnd::Imm(w[pos] as u64),
            OperandKind::U64 | OperandKind::I64 => Opnd::Imm(wide(2) as u64),
            OperandKind::U128 => Opnd::Imm128(wide(4)),
            OperandKind::Const => Opnd::Const(Const(w[pos])),
            OperandKind::Abs => match Abs::from_word(w[pos]) {
                Abs::Const(k) => Opnd::Const(k),
                Abs::Data(d) => Opnd::Data(d),
            },
            OperandKind::Sym => Opnd::Sym(Sym(w[pos])),
            OperandKind::Site => Opnd::Site(Site(w[pos])),
            OperandKind::Func => Opnd::Func(Func(w[pos])),
            OperandKind::Neg => Opnd::Neg(w[pos] != 0),
            OperandKind::List(ElemKind::Word) => {
                out.push(Opnd::Words(w[pos..].to_vec()));
                pos = w.len();
                continue;
            }
            OperandKind::Target | OperandKind::List(_) => panic!("ryo lowering: {op:?} takes labels"),
            OperandKind::Handler => unreachable!("not in the full set"),
        });
        pos += o.kind.words().unwrap();
    }
    debug_assert_eq!(pos, w.len(), "{op:?}");
}

fn mono<'tcx, T>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>, v: T) -> T
where
    T: ty::TypeFoldable<TyCtxt<'tcx>>,
{
    // Most MIR types have nothing to instantiate, normalize or erase: the folding would
    // return them unchanged.
    let flags = ty::TypeFlags::HAS_PARAM | ty::TypeFlags::HAS_ALIAS | ty::TypeFlags::HAS_FREE_REGIONS | ty::TypeFlags::HAS_RE_BOUND;
    if !v.has_type_flags(flags) {
        return v;
    }
    instance.instantiate_mir_and_normalize_erasing_regions(tcx, TypingEnv::fully_monomorphized(), ty::EarlyBinder::bind(tcx, v))
}

/// `RYO_ASM_CHECK`: the machine code read to the reduced set and encoded again must be the
/// same, byte for byte, with the same side data.
fn reencode_check(code: &asm::Encoded, mode: asm::Mode) {
    let d = asm::decode_reduced(&code, mode).unwrap_or_else(|e| panic!("ryo: RYO_ASM_CHECK: decoding: {e:?}\n{code:?}"));
    let re = asm::encode_reduced(&d.words, d.frame_size, &d.cleanup, &d.scopes, &d.dropped, &code.rodata, mode)
        .unwrap_or_else(|e| panic!("ryo: RYO_ASM_CHECK: re-encoding: {e:?}"));
    if re != *code {
        let at = code.code.iter().zip(&re.code).position(|(a, b)| a != b).unwrap_or(code.code.len().min(re.code.len()));
        panic!(
            "ryo: RYO_ASM_CHECK: re-encoding differs (code from byte {at}: {}):\n{}\n{code:?}\n---\n{re:?}",
            code.code == re.code,
            ryo_bytecode::reduced::Disasm(&d.words)
        );
    }
}
