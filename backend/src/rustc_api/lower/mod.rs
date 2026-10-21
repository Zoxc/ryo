//! MIR → bytecode, one function at a time (design/lowering.md).
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
//! | [`emit`] | opcode selection, encoding, outgoing-slot relocation |
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
use rustc_middle::ty::{self, GenericArgsRef, Instance, InstanceKind, Ty, TyCtxt, TypingEnv};
use rustc_span::Symbol;
use ryo_bytecode::abi::HEADER_SIZE;
use ryo_bytecode::image::{CATCH, CONTINUE, CleanupEntry};
use ryo_bytecode::insn::{CodeBuf, Opcode};

pub use self::constant::{is_import, is_tls_shim, vtable_alloc};
pub use self::sig::{AbiSig, abi_sig};
use self::emit::{Width, opw};
use self::frame::{Frame, OUT_END};

/// A lowered function. Code positions are word offsets from the function's start.
pub struct LoweredFn<'tcx> {
    pub code: Vec<u32>,
    /// Operands the merge pass fills in, once every function's index and symbol is known.
    pub relocs: Vec<CodeReloc<'tcx>>,
    /// Island template instances the code needs.
    pub islands: Vec<IslandRequest<'tcx>>,
    /// Cleanup table entries (unsorted): one per call-like instruction that may unwind, with
    /// its landing pad or [`CONTINUE`].
    pub cleanup: Vec<CleanupEntry>,
    /// The frame size `F`: locals and the largest outgoing argument block.
    pub frame_size: u32,
    pub arg_size: u32,
    pub ret_size: u32,
}

/// An operand the merge pass resolves.
pub enum CodeReloc<'tcx> {
    /// The `call` instruction at word `at` calls `callee`, a VM function of this image (one of
    /// [`LowerCx::vm`]): the merge pass fills in its function index. If `callee` ends up
    /// native after all, the caller is lowered again.
    Call { at: u32, callee: Instance<'tcx> },
    /// The `sym` operand at word `at` refers to `target`'s symbol: its portal if it is a VM
    /// function (which then gets one), the native definition otherwise (made visible to the
    /// image if it is internal).
    Symbol { at: u32, target: Instance<'tcx> },
    /// The `sym` operand at word `at` refers to the static `def_id` (made visible to the image
    /// if it is internal).
    Static { at: u32, def_id: rustc_hir::def_id::DefId },
    /// The `site` operand at word `at` gets a fresh site cache slot.
    Site { at: u32 },
    /// The `k` (or `addr.abs`) operand at word `at` is `offset` bytes into the constant-pool
    /// copy of `alloc`.
    Const { at: u32, alloc: AllocId, offset: u32 },
    /// The `k` operand at word `at` is a constant-pool allocation of these bytes.
    Bytes { at: u32, bytes: Vec<u8>, align: u32 },
    /// The `tail_call` instruction at word `at` calls `callee`, as for [`CodeReloc::Call`].
    TailCall { at: u32, callee: Instance<'tcx> },
    /// The `addr.abs` operand at word `at` is `offset` bytes into the fixup-area copy of
    /// `alloc` (PE: an allocation pointing at imports, `constant::needs_fixup`).
    Data { at: u32, alloc: AllocId, offset: u32 },
}

/// An island the code calls: the template (by diagnostic item name) and its generic args. The
/// merge pass deduplicates requests, adds the instances to the native CGU, and fills the
/// `sym` operand at word `at` with the instance's symbol.
pub struct IslandRequest<'tcx> {
    pub at: u32,
    pub template: Symbol,
    pub args: GenericArgsRef<'tcx>,
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
}

/// Lowers `instance` to bytecode, or says why it must stay native.
pub fn lower<'tcx>(
    tcx: TyCtxt<'tcx>,
    cx: &LowerCx<'_, 'tcx>,
    instance: Instance<'tcx>,
) -> Result<LoweredFn<'tcx>, NeedsNative> {
    let sig = vm_fn_sig(tcx, instance)?;
    let body = tcx.instance_mir(instance.def);
    let mut fx = FnCx::new(tcx, cx, instance, body, &sig)?;
    fx.prologue(&sig);
    fx.blocks()?;
    fx.finish()
}

/// The signature of `instance` if it can be a VM function: one whose portal (a `Rust`-ABI
/// template) can stand in for it (design/backend.md#pipeline, step 2).
pub fn vm_fn_sig<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    match instance.def {
        InstanceKind::Item(def_id) => {
            // `instance_mir` reads a constructor's body from `mir_for_ctfe`, which metadata
            // always has for constructors, while `is_mir_available` asks for `optimized_mir`,
            // which it never has for them (`should_encode_mir`,
            // `rustc_metadata/src/rmeta/encoder.rs:1108`).
            let available = matches!(tcx.def_kind(def_id), rustc_hir::def::DefKind::Ctor(..))
                || tcx.is_mir_available(def_id);
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
    if !attrs.target_features.is_empty() {
        return native("#[target_feature]");
    }
    let sig = abi_sig(tcx, instance)?;
    if sig.conv != sig::CallConv::Rust {
        return native("non-Rust ABI (the portal template is Rust-ABI)");
    }
    if sig.caller_location && sig.inputs.len() - 1 > MAX_PORTAL_TC_ARITY {
        // `#[track_caller]` functions get a `portal_tcN` (design/stubs.md#portals-native--vm).
        return native("#[track_caller] function with more than 16 arguments");
    }
    Ok(sig)
}

/// The largest `N` of `ryo_rt::portal::portal_tcN`.
pub const MAX_PORTAL_TC_ARITY: usize = 16;

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

/// A pending branch target: word `word` of the instruction at `insn` must branch to `bb`.
struct Fixup {
    insn: u32,
    word: u32,
    bb: BasicBlock,
}

/// The per-function lowering state. Each module adds its own `impl` block.
pub struct FnCx<'a, 'tcx> {
    pub tcx: TyCtxt<'tcx>,
    pub cx: &'a LowerCx<'a, 'tcx>,
    pub instance: Instance<'tcx>,
    pub body: &'tcx Body<'tcx>,
    pub frame: Frame<'tcx>,
    pub code: CodeBuf,
    pub relocs: Vec<CodeReloc<'tcx>>,
    pub islands: Vec<IslandRequest<'tcx>>,
    /// (call-like instruction, where unwinding out of it goes). Instructions without an entry
    /// can't unwind.
    cleanup: Vec<(u32, UnwindTo)>,
    fixups: Vec<Fixup>,
    /// Largest outgoing argument block of the calls made so far.
    pub max_outgoing: u32,
    arg_size: u32,
    /// The block after the one being lowered, in code order (for fall-through).
    pub next_block: Option<BasicBlock>,
    /// Code position of each block, once lowered.
    block_starts: Vec<u32>,
    /// For a `#[track_caller]` function: the slot of its incoming `&'static Location` (the
    /// last field of the argument block, design/lowering.md#caller-location).
    pub caller_location: Option<u32>,
    /// The current block's compare, fused into its terminator (`terminator::FusedCmp`).
    fused: Option<terminator::FusedCmp<'tcx>>,
    /// Code position of each terminate stub.
    terminate_at: Vec<(rustc_middle::mir::UnwindTerminateReason, u32)>,
    /// Code position of each landing pad, by where it goes.
    pads: Vec<(UnwindTo, u32)>,
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
        Ok(FnCx {
            tcx,
            cx,
            instance,
            body,
            frame,
            code: CodeBuf::new(),
            relocs: Vec::new(),
            islands: Vec::new(),
            cleanup: Vec::new(),
            fixups: Vec::new(),
            max_outgoing: 0,
            arg_size: sig.block_size,
            next_block: None,
            block_starts: Vec::new(),
            fused: None,
            terminate_at: Vec::new(),
            pads: Vec::new(),
            caller_location: sig
                .caller_location
                .then(|| frame::slot((HEADER_SIZE + sig.fields.last().expect("location field").offset) as i32)),
        })
    }

    /// Lowers every block, in index order. Cleanup blocks are only reached through landing
    /// pads.
    fn blocks(&mut self) -> Result<(), NeedsNative> {
        let body = self.body;
        let n = body.basic_blocks.len();
        let mut starts = vec![u32::MAX; n];
        let uses = terminator::local_uses(body);
        for (bb, data) in body.basic_blocks.iter_enumerated() {
            starts[bb.as_usize()] = self.code.pos();
            self.next_block = (bb.as_usize() + 1 < n).then(|| BasicBlock::from_usize(bb.as_usize() + 1));
            self.fused = self.fusable_compare(data, &uses);
            let stmts = &data.statements[..data.statements.len() - usize::from(self.fused.is_some())];
            for stmt in stmts {
                self.frame.reset_temps();
                self.statement(stmt)?;
            }
            self.frame.reset_temps();
            self.terminator(data.terminator())?;
        }
        self.block_starts = starts;
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
                let at = self.code.pos();
                self.frame.reset_temps();
                self.next_block = None;
                self.terminate_call(reason, self.body.source_info(rustc_middle::mir::Location::START).clone())?;
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
            let at = self.op(Opcode::Lpad, &[self.frame.exception_slot()]);
            let jmp = self.op(Opcode::Jmp, &[0]);
            let target = match to {
                UnwindTo::Block(bb) => self.block_starts[bb.as_usize()],
                UnwindTo::Terminate(r) => self.terminate_at.iter().find(|t| t.0 == r).expect("terminate stub").1,
                UnwindTo::Continue => unreachable!(),
            };
            self.code.words[jmp as usize + 1] = target.wrapping_sub(jmp);
            self.pads.push((to, at));
        }
    }

    /// Patches branches and unwind targets, turns slots into signed frame offsets.
    fn finish(mut self) -> Result<LoweredFn<'tcx>, NeedsNative> {
        let starts = std::mem::take(&mut self.block_starts);
        for f in &self.fixups {
            let target = starts[f.bb.as_usize()];
            self.code.words[f.word as usize] = target.wrapping_sub(f.insn);
        }
        let cleanup = self
            .cleanup
            .iter()
            .map(|&(offset, to)| {
                let pad = || self.pads.iter().find(|p| p.0 == to).expect("landing pad").1;
                let target = match to {
                    UnwindTo::Continue => CONTINUE,
                    UnwindTo::Block(_) => pad(),
                    // As cg_llvm's terminate pads: a catch-all, so it runs even when nothing up
                    // the stack catches.
                    UnwindTo::Terminate(_) => pad() | CATCH,
                };
                CleanupEntry { offset, target }
            })
            .collect();
        let frame_size = self.frame.frame_size(self.max_outgoing)?;
        emit::finish_slots(&mut self.code.words, frame_size);
        let ret = self.frame.locals[rustc_middle::mir::RETURN_PLACE];
        Ok(LoweredFn {
            code: self.code.words,
            relocs: self.relocs,
            islands: self.islands,
            cleanup,
            frame_size,
            arg_size: self.arg_size,
            ret_size: ret.layout.size.bytes() as u32,
        })
    }

    // ---- emission ----

    /// Emits a fixed-length instruction from its operand words; returns its position.
    pub fn op(&mut self, op: Opcode, operands: &[u32]) -> u32 {
        debug_assert_eq!(op.fixed_len(), Some(1 + operands.len()), "{op:?}");
        let at = self.code.pos();
        self.code.words.push(op as u32);
        self.code.words.extend_from_slice(operands);
        at
    }

    /// Emits a branch to `bb`: an instruction whose last operands are its polarity and target.
    /// With `neg`, it branches when its condition is false.
    pub fn op_branch(&mut self, op: Opcode, operands: &[u32], neg: bool, bb: BasicBlock) -> u32 {
        let mut w = operands.to_vec();
        w.extend([u32::from(neg), 0]);
        let at = self.op(op, &w);
        self.fixups.push(Fixup { insn: at, word: self.code.pos() - 1, bb });
        at
    }

    /// Records that word `word` of the instruction at `insn` is a branch target to `bb`.
    pub fn target_fixup(&mut self, insn: u32, word: u32, bb: BasicBlock) {
        self.fixups.push(Fixup { insn, word, bb });
    }

    /// `jmp` to `bb`, unless it is the next block.
    pub fn jump(&mut self, bb: BasicBlock) {
        if Some(bb) != self.next_block {
            let at = self.op(Opcode::Jmp, &[0]);
            self.fixups.push(Fixup { insn: at, word: at + 1, bb });
        }
    }

    /// Records the unwind action of the call-like instruction at `at`
    /// (design/lowering.md#unwinding). `Unreachable` records nothing: the instruction can't
    /// unwind.
    pub fn unwind_entry(&mut self, at: u32, unwind: rustc_middle::mir::UnwindAction) {
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
            Some(w) => self.op(opw("Mov", w), &[d, s]),
            None => self.op(Opcode::Copy, &[d, s, size]),
        };
    }

    /// Stores an immediate of width `w` into slot `d`.
    pub fn imm(&mut self, w: Width, d: u32, v: u128) {
        let mut ops = vec![d];
        ops.extend(emit::imm_words(w, v));
        self.op(opw("Imm", w), &ops);
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
