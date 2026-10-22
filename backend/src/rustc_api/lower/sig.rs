//! ABI signatures and argument blocks (design/lowering.md#frame-slots).
//!
//! The argument block of a callee is the layout of the tuple of its ABI argument types: the
//! inputs of `fn_abi_of_instance`, which already spreads a trailing `rust-call` tuple and
//! appends the `&'static Location` of `#[track_caller]` functions. Callers, callees, portals
//! and the call templates all use this one definition.

use rustc_abi::{BackendRepr, CanonAbi, Primitive, RegKind, Scalar};
use rustc_target::callconv::{ArgAbi, PassMode};
use ryo_bytecode::asm::{self, RET_SRET, RetPart};
use rustc_middle::ty::layout::TyAndLayout;
use rustc_middle::ty::{self, Instance, Ty, TyCtxt, TypingEnv};
use ryo_bytecode::abi::{self, ArgField};

use super::{LayoutCx, NeedsNative, layout_error, native};

/// How a callee is called natively.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CallConv {
    /// `Rust` / `rust-call`: `call_ptrN`, `call`, portals.
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
    /// spread over the ABI inputs. Set by the call site, which knows the fn type.
    pub rust_call: bool,
    /// How a VM function of this signature returns its value (a call's kind, exact sizes,
    /// [`ryo_bytecode::asm::RET_SRET`]); 0 for signatures only islands call.
    pub ret_kind: u32,
}

impl<'tcx> AbiSig<'tcx> {
    /// The tuple of the inputs: the portal's and the call templates' `Args`.
    pub fn args_tuple(&self, tcx: TyCtxt<'tcx>) -> Ty<'tcx> {
        Ty::new_tup(tcx, &self.inputs)
    }
}

/// The ABI signature of a direct call of (or the body of) `instance`.
pub fn abi_sig<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    let typing_env = TypingEnv::fully_monomorphized();
    let fn_abi = tcx
        .fn_abi_of_instance_no_deduced_attrs(typing_env.as_query_input((instance, ty::List::empty())))
        .map_err(|e| NeedsNative(super::no_trim(|| format!("fn ABI: {e:?}"))))?;
    from_fn_abi(tcx, fn_abi, instance.def.requires_caller_location(tcx), None)
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
pub fn virtual_sig<'tcx>(
    tcx: TyCtxt<'tcx>,
    instance: Instance<'tcx>,
    receiver: Ty<'tcx>,
) -> Result<AbiSig<'tcx>, NeedsNative> {
    let typing_env = TypingEnv::fully_monomorphized();
    let fn_abi = tcx
        .fn_abi_of_instance_no_deduced_attrs(typing_env.as_query_input((instance, ty::List::empty())))
        .map_err(|e| NeedsNative(super::no_trim(|| format!("fn ABI: {e:?}"))))?;
    from_fn_abi(tcx, fn_abi, instance.def.requires_caller_location(tcx), Some(receiver))
}

/// The ABI signature of a call through a fn pointer of type `sig`.
pub fn fn_ptr_sig<'tcx>(tcx: TyCtxt<'tcx>, sig: ty::PolyFnSig<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    let typing_env = TypingEnv::fully_monomorphized();
    let fn_abi = tcx
        .fn_abi_of_fn_ptr(typing_env.as_query_input((sig, ty::List::empty())))
        .map_err(|e| NeedsNative(super::no_trim(|| format!("fn ABI: {e:?}"))))?;
    from_fn_abi(tcx, fn_abi, false, None)
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
    let ret_kind = if conv == CallConv::Rust { ret_kind(tcx, &fn_abi.ret)? } else { 0 };
    Ok(AbiSig { inputs, output: fn_abi.ret.layout, fields, block_size, conv, caller_location, rust_call: false, ret_kind })
}

/// The signature of a Rust-ABI fn with these (non-spread) inputs: the `call` template's
/// `Args` and `R`.
pub fn tys_sig<'tcx>(tcx: TyCtxt<'tcx>, inputs: Vec<Ty<'tcx>>, output: Ty<'tcx>) -> Result<AbiSig<'tcx>, NeedsNative> {
    let (fields, block_size) = arg_block(tcx, &inputs)?;
    let output = super::layout_of(tcx, output)?;
    Ok(AbiSig { inputs, output, fields, block_size, conv: CallConv::Rust, caller_location: false, rust_call: false, ret_kind: 0 })
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
            ArgField {
                offset: layout.fields.offset(i).bytes() as u32,
                size: f.size.bytes() as u32,
                align: f.align.abi.bytes() as u32,
            }
        })
        .collect();
    let block = abi::arg_block(&fields, layout.size.bytes() as u32, layout.align.abi.bytes() as u32)
        .map_err(|e| NeedsNative(format!("argument block: {e:?}")))?;
    let size = block.size();
    Ok((fields, size))
}

/// The return kind of `ret` ([`ryo_bytecode::asm::RET_SRET`]): its `PassMode` as LLVM lowers
/// it on x86-64. `Direct` and `Pair` scalars go to the next of `rax`, `rdx` (integers and
/// pointers; `i128` takes both) or `xmm0`, `xmm1` (floats); a `Cast` is the Rust ABI's
/// integer for an aggregate of up to 8 bytes; `Indirect` is sret.
fn ret_kind<'tcx>(tcx: TyCtxt<'tcx>, ret: &ArgAbi<'tcx, Ty<'tcx>>) -> Result<u32, NeedsNative> {
    let cx = LayoutCx(tcx);
    let scalar = |s: Scalar, off: u32, out: &mut Vec<RetPart>| -> Result<(), NeedsNative> {
        let size = s.size(&cx).bytes() as u32;
        match s.primitive() {
            Primitive::Float(_) => out.push(RetPart { xmm: true, size, off }),
            Primitive::Int(..) | Primitive::Pointer(_) if size == 16 => {
                out.extend([RetPart { xmm: false, size: 8, off }, RetPart { xmm: false, size: 8, off: off + 8 }])
            }
            Primitive::Int(..) | Primitive::Pointer(_) => out.push(RetPart { xmm: false, size, off }),
        }
        Ok(())
    };
    let mut parts = Vec::new();
    match (&ret.mode, ret.layout.backend_repr) {
        (PassMode::Ignore, _) => return Ok(0),
        (PassMode::Indirect { .. }, _) => return Ok(RET_SRET),
        (PassMode::Direct(_), BackendRepr::Scalar(s)) => scalar(s, 0, &mut parts)?,
        (PassMode::Pair(..), BackendRepr::ScalarPair { a, b, b_offset }) => {
            scalar(a, 0, &mut parts)?;
            scalar(b, b_offset.bytes() as u32, &mut parts)?;
        }
        (PassMode::Cast { cast, pad_i32: false }, _)
            if cast.prefix.is_empty()
                && cast.rest_offset.is_none()
                && cast.rest.unit.kind == RegKind::Integer
                && cast.rest.total == cast.rest.unit.size
                && cast.rest.total.bytes() <= 8 =>
        {
            parts.push(RetPart { xmm: false, size: cast.rest.total.bytes() as u32, off: 0 })
        }
        (mode, repr) => return native(format!("return passed as {mode:?} ({repr:?})")),
    }
    if parts.len() > 2 {
        return native("return value in more than two registers");
    }
    Ok(asm::ret_kind(&parts))
}
