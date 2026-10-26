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
//! | [`emit`] | opcode selection by name and width, immediates |
//! | [`place`] | places → frame slots or memory operands |
//! | [`operand`] | operands and value moves between slots and memory |
//! | [`rvalue`] | statements and rvalues |
//! | [`adt`] | aggregates and discriminants (enums via layout) |
//! | [`cast`] | casts and pointer coercions |
//! | [`binop`] | binary and unary operations |
//! | [`terminator`] | terminators other than calls |
//! | [`call`] | calls: VM calls, `call.ext`, call islands, drops |
//! | [`intrinsic`] | intrinsic calls |
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
use self::emit::{Width, opw};
use self::frame::{Frame, OUT_END};
pub use self::sig::{AbiSig, abi_sig};

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
    /// The functions assumed to be VM functions of this image. A call of one of them is a
    /// `call`; any other local callee is called through an island.
    pub vm: &'a FxHashSet<Instance<'tcx>>,
    /// How the machine code is generated.
    pub mode: asm::Mode,
    /// Whether to record the certificate for the Lean lowering check (`cert.rs`).
    pub cert: bool,
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
    if !attrs.target_features.is_empty() {
        return native("#[target_feature]");
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
    /// Through a landing pad ([`FnCx::landing_pads`]) to this block.
    Block(BasicBlock),
    /// Through a landing pad to the function's stub calling the reason's lang item
    /// ([`FnCx::terminate_stubs`]).
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
    /// Label of each terminate stub.
    terminate_at: Vec<(rustc_middle::mir::UnwindTerminateReason, Label)>,
    /// Label of each landing pad, by where it goes.
    pads: Vec<(UnwindTo, Label)>,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    fn new(
        tcx: TyCtxt<'tcx>,
        cx: &'a LowerCx<'a, 'tcx>,
        instance: Instance<'tcx>,
        body: &'tcx Body<'tcx>,
        sig: &AbiSig<'tcx>,
    ) -> Result<Self, NeedsNative> {
        let frame = Frame::new(body, sig, cx.mode.pe, |local| {
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
            terminate_at: Vec::new(),
            pads: Vec::new(),
            caller_location,
        })
    }

    /// Lowers every block, in index order. Cleanup blocks are only reached through landing
    /// pads.
    fn blocks(&mut self) -> Result<(), NeedsNative> {
        let body = self.body;
        let n = body.basic_blocks.len();
        let uses = terminator::local_uses(body);
        let dead = frame::dead_after_read(body);
        let mut dead = dead.iter().peekable();
        for (bb, data) in body.basic_blocks.iter_enumerated() {
            self.bind(self.block_labels[bb.as_usize()]);
            self.next_block = (bb.as_usize() + 1 < n).then(|| BasicBlock::from_usize(bb.as_usize() + 1));
            self.fused = self.fusable(data, &uses);
            self.cert_block(self.fused.is_some());
            let stmts = &data.statements[..data.statements.len() - usize::from(self.fused.is_some())];
            for (i, stmt) in stmts.iter().enumerate() {
                self.reset_temps();
                let start = self.insns;
                self.statement(stmt)?;
                self.cert_stmt(start);
                let here = rustc_middle::mir::Location { block: bb, statement_index: i };
                while let Some(&&(at, local)) = dead.peek()
                    && at <= here
                {
                    if at == here {
                        self.local_dead(local);
                    }
                    dead.next();
                }
            }
            self.reset_temps();
            let start = self.insns;
            self.terminator(data.terminator())?;
            self.cert_term(start);
        }
        self.terminate_stubs()?;
        self.landing_pads();
        Ok(())
    }

    /// Emits one stub per terminate reason the cleanup entries use, after the blocks: a call
    /// of the reason's lang item, as cg_ssa's terminate block (design/lowering.md#unwinding).
    fn terminate_stubs(&mut self) -> Result<(), NeedsNative> {
        let mut done = Vec::new();
        for i in 0..self.cleanup.len() {
            if let UnwindTo::Terminate(reason) = self.cleanup[i].1
                && !done.contains(&reason)
            {
                done.push(reason);
                let at = self.asm.label();
                self.bind(at);
                self.reset_temps();
                self.next_block = None;
                let start = self.insns;
                self.terminate_call(reason, self.body.source_info(rustc_middle::mir::Location::START).clone())?;
                self.cert_stub(reason, start);
                self.terminate_at.push((reason, at));
            }
        }
        Ok(())
    }

    /// Emits one landing pad per distinct place unwinding goes to in this frame, after the
    /// blocks and terminate stubs: `lpad x` (which stores the exception object in the
    /// function's exception slot `x`), then a jump to the cleanup block or terminate stub. A
    /// cleanup block may also be reached by a jump from another one, so the pads are separate
    /// from the blocks, and `lpad` runs once per landing.
    fn landing_pads(&mut self) {
        for i in 0..self.cleanup.len() {
            let to = self.cleanup[i].1;
            if to == UnwindTo::Continue || self.pads.iter().any(|p| p.0 == to) {
                continue;
            }
            let at = self.asm.label();
            self.bind(at);
            let start = self.insns;
            self.op(Opcode::Lpad, &[self.frame.exception_slot()]);
            let target = match to {
                UnwindTo::Block(bb) => self.block_labels[bb.as_usize()],
                UnwindTo::Terminate(r) => self.terminate_at.iter().find(|t| t.0 == r).expect("terminate stub").1,
                UnwindTo::Continue => unreachable!(),
            };
            self.emit(Opcode::Jmp, vec![Opnd::Target(target)]);
            self.cert_pad(start, if let UnwindTo::Block(bb) = to { Some(bb.as_u32()) } else { None });
            self.pads.push((to, at));
        }
        for &(id, to) in &self.cleanup {
            let u = match to {
                UnwindTo::Continue => Unwind::Continue,
                UnwindTo::Block(_) => Unwind::Pad { pad: self.pads.iter().find(|p| p.0 == to).expect("landing pad").1, catch: false },
                // As cg_llvm's terminate pads: a catch-all, so it runs even when nothing up
                // the stack catches.
                UnwindTo::Terminate(_) => Unwind::Pad { pad: self.pads.iter().find(|p| p.0 == to).expect("landing pad").1, catch: true },
            };
            self.asm.set_unwind(id, u);
        }
    }

    /// Finishes the machine code, now that the frame size is known.
    fn finish(mut self, sig: &AbiSig<'tcx>) -> Result<LoweredFn<'tcx>, NeedsNative> {
        let frame_size = self.frame.frame_size(self.max_outgoing)?;
        let cert = self.cert_json(frame_size, sig.plan.as_ref());
        let code = std::mem::replace(&mut self.asm, Asm::new(self.cx.mode)).finish(frame_size, |s| frame::frame_offset(s, frame_size) as u32);
        if crate::rustc_api::switches::get().asm_check {
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
        self.insns += 1;
        self.asm.insn(op, &ops)
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
        self.insns += 1;
        let id = self.asm.insn(op, &ops);
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
        self.insns += 1;
        let id = self.asm.insn(op, &ops);
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
            CodeReloc::Symbol { target } => crate::rustc_api::symbols::symbol_flags(self.tcx, target, crate::rustc_api::symbols::SymRole::Target),
            CodeReloc::Static { def_id } => crate::rustc_api::symbols::static_symbol_flags(self.tcx, def_id),
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
            self.emit(Opcode::Jmp, vec![Opnd::Target(self.block_labels[bb.as_usize()])]);
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

    /// Copies `size` bytes between two frame slots.
    pub fn mov(&mut self, d: u32, s: u32, size: u32) {
        if size == 0 || d == s {
            return;
        }
        match Width::of_size(u64::from(size)) {
            Some(w) => {
                self.op(opw("Mov", w), &[d, s]);
            }
            None if size <= SPLIT_MAX && (d + size <= s || s + size <= d) => {
                for (o, w) in pieces(size, Width::W128, &self.cuts) {
                    self.op(opw("Mov", w), &[d + o, s + o]);
                }
            }
            None => {
                self.op(Opcode::Copy, &[d, s, size]);
            }
        };
    }

    /// Zeroes `size` bytes of slots at `d`: `imm 0` pieces up to [`SPLIT_MAX`] bytes, else
    /// `zero`.
    pub fn zero(&mut self, d: u32, size: u32) {
        if size > SPLIT_MAX {
            self.op(Opcode::Zero, &[d, size]);
            return;
        }
        for (o, w) in pieces(size, Width::W64, &self.cuts) {
            self.imm(w, d + o, 0);
        }
    }

    /// Runs `f` (a copy of a value of `layout`) with [`FnCx::cuts`] at the layout's field
    /// offsets.
    pub fn with_cuts<R>(&mut self, layout: TyAndLayout<'tcx>, f: impl FnOnce(&mut Self) -> R) -> R {
        let mut cuts = Vec::new();
        if layout.size.bytes() <= u64::from(SPLIT_MAX) {
            field_cuts(&self.lcx(), layout, 0, SPLIT_MAX, &mut cuts);
        }
        let old = std::mem::replace(&mut self.cuts, cuts);
        let r = f(self);
        self.cuts = old;
        r
    }

    /// Stores an immediate of width `w` into slot `d`.
    pub fn imm(&mut self, w: Width, d: u32, v: u128) {
        let mut ops = vec![d];
        ops.extend(emit::imm_words(w, v));
        self.op(opw("Imm", w), &ops);
    }

    /// `family.imm.w d, a, v`, `v` truncated to the width.
    pub fn op_imm(&mut self, family: &str, w: Width, d: u32, a: u32, v: u128) {
        let mut ops = vec![d, a];
        ops.extend(emit::imm_words(w, w.truncate(v)));
        self.op(opw(&format!("{family}Imm"), w), &ops);
    }

    /// Copies `n <= SPLIT_MAX` bytes from the memory at `src` to the memory at `dst` as
    /// `load`/`store` pieces (cut at [`FnCx::cuts`]) through a temporary: every piece is loaded
    /// before the first store, so overlapping ranges copy as `memmove` does.
    pub fn mem_copy_pieces(&mut self, dst: u32, src: u32, n: u32) {
        debug_assert!(n <= SPLIT_MAX);
        if n == 0 {
            return;
        }
        let t = self.frame.temp(u64::from(n), 16);
        self.load_pieces(t, src, n);
        self.store_pieces(dst, t, n);
    }

    /// `load.wK d+i, [p+i]` pieces (`K` <= 64) for `n` bytes.
    pub fn load_pieces(&mut self, d: u32, p: u32, n: u32) {
        for (o, w) in pieces(n, Width::W64, &self.cuts) {
            self.op(opw("Load", w), &[d + o, p, o]);
        }
    }

    /// `store.wK [p+i], s+i` pieces (`K` <= 64) for `n` bytes.
    pub fn store_pieces(&mut self, p: u32, s: u32, n: u32) {
        for (o, w) in pieces(n, Width::W64, &self.cuts) {
            self.op(opw("Store", w), &[p, o, s + o]);
        }
    }

    /// Sets `n <= SPLIT_MAX` bytes of the memory at `dst` to a byte (a constant, or the `u8`
    /// in a slot) as `store` pieces of a 64-bit pattern.
    pub fn mem_set_pieces(&mut self, dst: u32, byte: Result<u8, u32>, n: u32) {
        debug_assert!(n <= SPLIT_MAX);
        if n == 0 {
            return;
        }
        let ones = 0x0101_0101_0101_0101u128;
        let t = self.temp8();
        match byte {
            Ok(b) => self.imm(Width::W64, t, u128::from(b) * ones),
            Err(s) => {
                self.int_cast(t, s, Width::W8, Width::W64, false);
                self.op_imm("Mul", Width::W64, t, t, ones);
            }
        }
        for (o, w) in pieces(n, Width::W64, &[]) {
            self.op(opw("Store", w), &[dst, o, t]);
        }
    }

    /// The outgoing argument block's field at `off`: the slot at `fp - F + off`, once the
    /// frame size `F` is known (`frame.rs`).
    pub fn out(off: u32) -> u32 {
        debug_assert!(off < OUT_END);
        off
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

/// Block copies and zeroing of at most this many bytes are split into scalar pieces
/// (`mov`/`load`/`store`/`imm`), which are inline, instead of the `copy`, `load.copy`,
/// `store.copy` and `zero` handler calls. Valid since MIR assignments never partially overlap.
pub const SPLIT_MAX: u32 = 48;

/// The `(offset, width)` pieces of a `size`-byte block: at each offset the widest width up
/// to `max` that fits and doesn't straddle one of the field offsets `cuts`, so the pieces
/// match the accesses the rest of the code makes to the fields.
pub fn pieces(size: u32, max: Width, cuts: &[u32]) -> Vec<(u32, Width)> {
    let mut v = Vec::new();
    let mut o = 0;
    while o < size {
        let w = [Width::W128, Width::W64, Width::W32, Width::W16, Width::W8]
            .into_iter()
            .find(|w| w.bytes() <= max.bytes() && o + w.bytes() <= size && !cuts.iter().any(|&c| o < c && c < o + w.bytes()))
            .expect("w8 always fits");
        v.push((o, w));
        o += w.bytes();
    }
    v
}

/// The offsets of the scalar leaves of `layout` (of every variant), up to `limit` bytes.
fn field_cuts<'tcx>(cx: &LayoutCx<'tcx>, layout: TyAndLayout<'tcx>, base: u32, limit: u32, out: &mut Vec<u32>) {
    if layout.size.bytes() > u64::from(limit) {
        return;
    }
    out.push(base);
    if let rustc_abi::BackendRepr::ScalarPair { b_offset, .. } = layout.backend_repr {
        out.push(base + b_offset.bytes() as u32);
        return;
    }
    if let rustc_abi::Variants::Multiple { ref variants, .. } = layout.variants {
        for v in variants.indices() {
            let vl = layout.for_variant(cx, v);
            for i in 0..vl.fields.count() {
                field_cuts(cx, vl.field(cx, i), base + vl.fields.offset(i).bytes() as u32, limit, out);
            }
        }
    }
    for i in 0..layout.fields.count() {
        field_cuts(cx, layout.field(cx, i), base + layout.fields.offset(i).bytes() as u32, limit, out);
    }
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
    let d = asm::decode_reduced(&code.code, &code.relocs, &code.rodata, &code.call_sites, &code.dropped, &code.scopes, mode)
        .unwrap_or_else(|e| panic!("ryo: RYO_ASM_CHECK: decoding: {e:?}\n{code:?}"));
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
