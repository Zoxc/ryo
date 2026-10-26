//! ABI signatures (design/lowering.md#frame-slots): the inputs of `fn_abi_of_instance`, which
//! already spreads a trailing `rust-call` tuple and appends the `&'static Location` of
//! `#[track_caller]` functions; where the platform calling convention puts them
//! ([`ArgPlan`]); and the argument block, the layout of their tuple, which the island
//! templates take.

use rustc_abi::{BackendRepr, CanonAbi, Primitive, RegKind, Scalar};
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, Instance, Ty, TyCtxt, TypingEnv};
use rustc_target::callconv::{ArgAbi, FnAbi, PassMode};
use ryo_bytecode::abi::{self, ArgField};
use ryo_bytecode::asm::{self, ArgReg, RET_SRET, RetPart};

use super::{LayoutCx, NeedsNative, layout_error, native};

/// How a callee is called natively.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CallConv {
    /// `Rust` / `rust-call`: direct calls, and the `call` template.
    Rust,
    /// `extern "C"` that can't unwind: `call_cN`.
    C,
}

/// A callee's ABI signature and argument block.
#[derive(Clone, Debug)]
pub struct AbiSig<'tcx> {
    /// The ABI argument types, in order (rust-call spread, caller location last).
    pub inputs: Vec<Ty<'tcx>>,
    pub output: TyAndLayout<'tcx>,
    /// Per input: its place in the argument block.
    pub fields: Vec<ArgField>,
    /// Size of the argument block.
    pub block_size: u32,
    pub conv: CallConv,
    /// Whether the last input is the implicit `#[track_caller]` location.
    pub caller_location: bool,
    /// Whether the callee is `extern "rust-call"`: the caller's trailing tuple argument is
    /// spread over the ABI inputs. Set by `fn_ptr_sig`, and for an instance by the call site,
    /// which knows the fn type.
    pub rust_call: bool,
    /// How a VM function of this signature returns its value (a call's kind, exact sizes,
    /// [`ryo_bytecode::asm::RET_SRET`]); 0 for signatures only islands call.
    pub ret_kind: u32,
    /// Where each input goes in the platform calling convention; `None` for signatures only
    /// islands call.
    pub plan: Option<ArgPlan>,
}

/// Where a piece of an ABI input goes (design/vm.md, "Calls and islands").
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ArgLoc {
    /// The `reg.size` bytes at `off` of the value, in an argument register (`reg.index` is
    /// the register's position among its class's argument registers; on PE, the argument's
    /// position).
    Reg { reg: ArgReg, off: u32 },
    /// The `size` bytes at `off` of the value, `at` bytes into the stack argument area (the
    /// caller's `rsp`, the callee's `fp + 16`; on PE after 32 bytes of shadow space).
    Stack { at: u32, off: u32, size: u32 },
    /// An `Indirect` input: a pointer to the value, in an integer argument register.
    PtrReg(u32),
    /// The same, on the stack.
    PtrStack(u32),
}

/// The calling-convention assignment of a signature's inputs.
#[derive(Clone, Debug)]
pub struct ArgPlan {
    /// Per input, its pieces.
    pub locs: Vec<Vec<ArgLoc>>,
    /// The size of the stack argument area: the outgoing area's, a multiple of 8 (16 for the
    /// frame), and on PE at least the 32 bytes of shadow space.
    pub stack_size: u32,
}

impl<'tcx> AbiSig<'tcx> {
    /// The tuple of the inputs: the portal's and the call templates' `Args`.
    pub fn args_tuple(&self, tcx: TyCtxt<'tcx>) -> Ty<'tcx> {
        Ty::new_tup(tcx, &self.inputs)
    }
}

/// The ABI signature of a direct call of (or the body of) `instance`.
pub fn abi_sig<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    instance_sig(tcx, instance, None)
}

/// The ABI signature of the virtual call `instance` (`InstanceKind::Virtual`), with `receiver`
/// (a thin pointer type) as the type of the data pointer passed as the first argument.
///
/// `fn_abi_of_instance` gives a virtual call's receiver the wide pointer's type with the layout
/// of `*mut ()` (`make_thin_self_ptr`, `rustc_ty_utils/src/abi.rs:694`). The method behind the
/// vtable takes `&Self`, `&mut Self`, `Box<Self>`, `Pin<&mut Self>`, … or `*mut Self` (a
/// `VTableShim`), and rustc orders tuple fields by niche too, so the caller's argument block
/// only matches the callee's if `receiver` has the callee receiver's niche: the caller passes
/// `&()` when the receiver's data pointer is non-null, `*mut ()` otherwise.
pub fn virtual_sig<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>, receiver: Ty<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    instance_sig(tcx, instance, Some(receiver))
}

fn instance_sig<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>, receiver: Option<Ty<'tcx>>) -> Result<AbiSig<'tcx>, NeedsNative> {
    let typing_env = TypingEnv::fully_monomorphized();
    let fn_abi = tcx.fn_abi_of_instance_no_deduced_attrs(typing_env.as_query_input((instance, ty::List::empty()))).map_err(fn_abi_err)?;
    from_fn_abi(tcx, fn_abi, instance.def.requires_caller_location(tcx), receiver)
}

/// The ABI signature of a call through a fn pointer of type `sig`.
pub fn fn_ptr_sig<'tcx>(tcx: TyCtxt<'tcx>, sig: ty::PolyFnSig<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    let typing_env = TypingEnv::fully_monomorphized();
    let fn_abi = tcx.fn_abi_of_fn_ptr(typing_env.as_query_input((sig, ty::List::empty()))).map_err(fn_abi_err)?;
    let rust_call = sig.abi() == rustc_abi::ExternAbi::RustCall;
    Ok(AbiSig { rust_call, ..from_fn_abi(tcx, fn_abi, false, None)? })
}

fn fn_abi_err(e: &ty::layout::FnAbiError<'_>) -> NeedsNative {
    NeedsNative(super::no_trim(|| format!("fn ABI: {e:?}")))
}

/// `receiver` replaces the type of the first input (virtual calls).
fn from_fn_abi<'tcx>(
    tcx: TyCtxt<'tcx>,
    fn_abi: &rustc_target::callconv::FnAbi<'tcx, Ty<'tcx>>,
    caller_location: bool,
    receiver: Option<Ty<'tcx>>,
) -> Result<AbiSig<'tcx>, NeedsNative> {
    if fn_abi.c_variadic {
        return native("C-variadic");
    }
    let conv = match fn_abi.conv {
        CanonAbi::Rust => CallConv::Rust,
        CanonAbi::C if !fn_abi.can_unwind => CallConv::C,
        CanonAbi::C => return native("C-unwind ABI"),
        other => return native(format!("{other} ABI")),
    };
    let mut inputs: Vec<Ty<'tcx>> = fn_abi.args.iter().map(|a| a.layout.ty).collect();
    if let Some(r) = receiver {
        let Some(first) = inputs.first_mut() else { return native("virtual call without a receiver") };
        *first = r;
    }
    let (fields, block_size) = arg_block(tcx, &inputs)?;
    if fn_abi.ret.layout.align.abi.bytes() > u64::from(abi::FRAME_ALIGN) {
        return native("return value aligned above 16");
    }
    let (ret_kind, plan) = if conv == CallConv::Rust {
        let k = ret_kind(tcx, &fn_abi.ret)?;
        (k, Some(arg_plan(tcx, fn_abi, k == RET_SRET)?))
    } else {
        (0, None)
    };
    Ok(AbiSig { inputs, output: fn_abi.ret.layout, fields, block_size, conv, caller_location, rust_call: false, ret_kind, plan })
}

/// The signature of a Rust-ABI fn with these (non-spread) inputs: the `call` template's
/// `Args` and `R`.
pub fn tys_sig<'tcx>(tcx: TyCtxt<'tcx>, inputs: Vec<Ty<'tcx>>, output: Ty<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    let (fields, block_size) = arg_block(tcx, &inputs)?;
    let output = super::layout_of(tcx, output)?;
    Ok(AbiSig { inputs, output, fields, block_size, conv: CallConv::Rust, caller_location: false, rust_call: false, ret_kind: 0, plan: None })
}

/// The argument block for `inputs`: the layout of their tuple (design/lowering.md#frame-slots).
pub fn arg_block<'tcx>(tcx: TyCtxt<'tcx>, inputs: &[Ty<'tcx>]) -> Result<(Vec<ArgField>, u32), NeedsNative> {
    let typing_env = TypingEnv::fully_monomorphized();
    // A tuple with an unsized field before the last has no layout (`layout_of` would ICE
    // through a delayed bug): by-value unsized arguments (`unsized_fn_params`).
    if inputs.iter().any(|t| !t.is_sized(tcx, typing_env)) {
        return native("unsized argument");
    }
    let tuple = Ty::new_tup(tcx, inputs);
    let layout = tcx.layout_of(typing_env.as_query_input(tuple)).map_err(layout_error)?;
    let cx = LayoutCx(tcx);
    let fields: Vec<ArgField> = (0..inputs.len())
        .map(|i| {
            let f = layout.field(&cx, i);
            ArgField { offset: layout.fields.offset(i).bytes() as u32, size: f.size.bytes() as u32, align: f.align.abi.bytes() as u32 }
        })
        .collect();
    let block = abi::arg_block(&fields, layout.size.bytes() as u32, layout.align.abi.bytes() as u32)
        .map_err(|e| NeedsNative(format!("argument block: {e:?}")))?;
    let size = block.size();
    Ok((fields, size))
}

/// One register-sized piece of a value passed in registers: a scalar, or the Rust ABI's
/// integer for a small aggregate.
#[derive(Clone, Copy)]
struct Piece {
    float: bool,
    size: u32,
    off: u32,
}

/// The pieces of `arg` when its `PassMode` passes it in registers as LLVM lowers it on x86-64:
/// a `Direct` scalar, the two scalars of a `Pair`, or a `Cast` to one integer of at most 8
/// bytes (the Rust ABI's small aggregates). `None` for every other mode.
fn reg_pieces<'tcx>(tcx: TyCtxt<'tcx>, arg: &ArgAbi<'tcx, Ty<'tcx>>) -> Option<Vec<Piece>> {
    let cx = LayoutCx(tcx);
    let scalar = |s: Scalar, off: u32| Piece { float: matches!(s.primitive(), Primitive::Float(_)), size: s.size(&cx).bytes() as u32, off };
    match (&arg.mode, arg.layout.backend_repr) {
        (PassMode::Direct(_), BackendRepr::Scalar(s)) => Some(vec![scalar(s, 0)]),
        (PassMode::Pair(..), BackendRepr::ScalarPair { a, b, b_offset }) => Some(vec![scalar(a, 0), scalar(b, b_offset.bytes() as u32)]),
        (PassMode::Cast { cast, pad_i32: false }, _)
            if cast.prefix.is_empty()
                && cast.rest_offset.is_none()
                && cast.rest.unit.kind == RegKind::Integer
                && cast.rest.total == cast.rest.unit.size
                && cast.rest.total.bytes() <= 8 =>
        {
            Some(vec![Piece { float: false, size: cast.rest.total.bytes() as u32, off: 0 }])
        }
        _ => None,
    }
}

/// The return kind of `ret` ([`ryo_bytecode::asm::RET_SRET`]): its `PassMode` as LLVM lowers
/// it on x86-64. `Direct` and `Pair` scalars go to the next of `rax`, `rdx` (integers and
/// pointers; `i128` takes both) or `xmm0`, `xmm1` (floats); a `Cast` is the Rust ABI's
/// integer for an aggregate of up to 8 bytes; `Indirect` is sret.
fn ret_kind<'tcx>(tcx: TyCtxt<'tcx>, ret: &ArgAbi<'tcx, Ty<'tcx>>) -> Result<u32, NeedsNative> {
    match ret.mode {
        PassMode::Ignore => return Ok(0),
        PassMode::Indirect { .. } => return Ok(RET_SRET),
        _ => {}
    }
    let Some(pieces) = reg_pieces(tcx, ret) else {
        return native(format!("return passed as {:?} ({:?})", ret.mode, ret.layout.backend_repr));
    };
    let pe = crate::rustc_api::symbols::is_pe(tcx);
    if pe && pieces.iter().any(|p| p.float && p.size == 16) {
        // Win64: LLVM returns an `f128` in memory the caller passes the address of, like an
        // sret (`i128` comes back in `rax:rdx` as on SysV, `f16` in `xmm0`).
        if pieces.len() > 1 {
            return native("f128 in a returned pair on Win64");
        }
        return Ok(RET_SRET);
    }
    let mut parts = Vec::new();
    for Piece { float, size, off } in pieces {
        if !float && size == 16 {
            parts.extend([RetPart { xmm: false, size: 8, off }, RetPart { xmm: false, size: 8, off: off + 8 }]);
        } else {
            parts.push(RetPart { xmm: float, size, off });
        }
    }
    if parts.len() > 2 {
        return native("return value in more than two registers");
    }
    Ok(asm::ret_kind(&parts))
}

/// The assignment of `fn_abi`'s inputs to argument registers and the stack, as LLVM lowers
/// rustc's `PassMode`s on x86-64 (design/vm.md, "Calls and islands"). Each `Direct` scalar,
/// each half of a `Pair`, the Rust ABI's small-aggregate integer `Cast` and an `Indirect`
/// input's pointer is one LLVM argument. On SysV, an integer or pointer takes the next of
/// `rdi rsi rdx rcx r8 r9` (`i128` two at once, or the stack if fewer are left, the rest staying
/// free), a float the next of `xmm0`–`xmm7`, and the rest go on the stack in 8-byte slots
/// (16-aligned for 16-byte values). On Win64 each argument takes the next position: `rcx rdx
/// r8 r9` or `xmm0`–`xmm3` by class, then 8-byte stack slots after the shadow space; an `i128`
/// takes two positions, an `f128` is passed by reference (as LLVM 23 lowers them for the Rust
/// ABI on x86_64-pc-windows-msvc). An sret return takes the first integer register.
fn arg_plan<'tcx>(tcx: TyCtxt<'tcx>, fn_abi: &FnAbi<'tcx, Ty<'tcx>>, sret: bool) -> Result<ArgPlan, NeedsNative> {
    let pe = crate::rustc_api::symbols::is_pe(tcx);
    struct State {
        pe: bool,
        gpr: u32,
        xmm: u32,
        /// PE: the next position.
        pos: u32,
        stack: u32,
    }
    impl State {
        /// A slot of `size` bytes (8 or 16) in the stack area.
        fn stack(&mut self, size: u32) -> u32 {
            let at = self.stack.next_multiple_of(if size == 16 && !self.pe { 16 } else { 8 });
            self.stack = at + size.next_multiple_of(8);
            at
        }
        /// An integer of `size` bytes (1 to 8, or 16 for `i128`) at `off`.
        fn int(&mut self, size: u32, off: u32, out: &mut Vec<ArgLoc>) -> Result<(), NeedsNative> {
            if self.pe && size == 16 {
                // Win64 (Rust ABI): an `i128` is two 8-byte arguments, low half first, each
                // taking the next position, so it can straddle `r9` and the stack.
                self.int(8, off, out)?;
                self.int(8, off + 8, out)?;
            } else if self.pe {
                if self.pos < 4 {
                    out.push(ArgLoc::Reg { reg: ArgReg { xmm: false, size, index: self.pos }, off });
                } else {
                    let at = self.stack(8);
                    out.push(ArgLoc::Stack { at, off, size });
                }
                self.pos += 1;
            } else if size == 16 {
                if self.gpr <= 4 {
                    for k in 0..2 {
                        out.push(ArgLoc::Reg { reg: ArgReg { xmm: false, size: 8, index: self.gpr }, off: off + 8 * k });
                        self.gpr += 1;
                    }
                } else {
                    let at = self.stack(16);
                    out.push(ArgLoc::Stack { at, off, size: 16 });
                }
            } else if self.gpr < 6 {
                out.push(ArgLoc::Reg { reg: ArgReg { xmm: false, size, index: self.gpr }, off });
                self.gpr += 1;
            } else {
                let at = self.stack(8);
                out.push(ArgLoc::Stack { at, off, size });
            }
            Ok(())
        }
        /// A float of `size` bytes at `off`.
        fn float(&mut self, size: u32, off: u32, out: &mut Vec<ArgLoc>) -> Result<(), NeedsNative> {
            if self.pe {
                // An `f16` goes in the low 2 bytes of its `xmm` or its 8-byte stack slot; the
                // caller passes an `f128` by reference (`Direct` ones only: see `arg_plan`).
                if size == 16 {
                    self.ptr(out);
                    return Ok(());
                }
                if self.pos < 4 {
                    out.push(ArgLoc::Reg { reg: ArgReg { xmm: true, size, index: self.pos }, off });
                } else {
                    let at = self.stack(8);
                    out.push(ArgLoc::Stack { at, off, size });
                }
                self.pos += 1;
            } else if self.xmm < 8 {
                out.push(ArgLoc::Reg { reg: ArgReg { xmm: true, size, index: self.xmm }, off });
                self.xmm += 1;
            } else {
                let at = self.stack(size.max(8));
                out.push(ArgLoc::Stack { at, off, size });
            }
            Ok(())
        }
        /// An `Indirect` input's pointer.
        fn ptr(&mut self, out: &mut Vec<ArgLoc>) {
            let reg = if self.pe { (self.pos < 4).then_some(self.pos) } else { (self.gpr < 6).then_some(self.gpr) };
            match reg {
                Some(i) => out.push(ArgLoc::PtrReg(i)),
                None => {
                    let at = self.stack(8);
                    out.push(ArgLoc::PtrStack(at));
                }
            }
            if self.pe {
                self.pos += 1;
            } else if reg.is_some() {
                self.gpr += 1;
            }
        }
    }
    let mut st = State { pe, gpr: 0, xmm: 0, pos: 0, stack: if pe { 32 } else { 0 } };
    if sret {
        st.gpr = 1;
        st.pos = 1;
    }
    let mut locs = Vec::with_capacity(fn_abi.args.len());
    for arg in fn_abi.args.iter() {
        let mut out = Vec::new();
        match arg.mode {
            PassMode::Ignore => {}
            PassMode::Indirect { meta_attrs: None, on_stack: false, .. } => st.ptr(&mut out),
            _ => {
                let Some(pieces) = reg_pieces(tcx, arg) else {
                    return native(format!("argument passed as {:?} ({:?})", arg.mode, arg.layout.backend_repr));
                };
                // A pointer to one half of the input isn't an `ArgLoc`.
                if pe && pieces.len() > 1 && pieces.iter().any(|p| p.float && p.size == 16) {
                    return native("f128 in a pair argument on Win64");
                }
                for Piece { float, size, off } in pieces {
                    if float { st.float(size, off, &mut out)? } else { st.int(size, off, &mut out)? }
                }
            }
        }
        locs.push(out);
    }
    Ok(ArgPlan { locs, stack_size: st.stack.next_multiple_of(16) })
}
