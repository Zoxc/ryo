//! The C `main` of a binary whose entry fn is a VM function (design/stubs.md#program-entry-main),
//! built by the backend as cg_ssa's `maybe_create_entry_wrapper` builds its LLVM function: a
//! function of the target's entry signature (`main(argc: c_int, argv) -> c_int`, C ABI) under
//! `target.entry_name`, which calls `lang_start::<T>` with the entry fn:
//!
//! ```text
//! extern "C" fn main(argc: c_int, argv: *const *const u8) -> c_int {
//!     lang_start::<T>(entry_fn as fn() -> T, argc as isize, argv, SIGPIPE) as c_int
//! }
//! ```
//!
//! It is no rustc instance: the image adds it as a function of its own ([`EntryWrapper`] in the
//! partition), lowered from the MIR body [`body`] builds, with the signature [`c_sig`].

use rustc_hir::attrs::lang_items::LangItem;
use rustc_index::IndexVec;
use rustc_middle::mir::interpret::Scalar;
use rustc_middle::mir::{
    BasicBlock, BasicBlockData, Body, CallSource, CastKind, ClearCrossCrate, Local, LocalDecl, MirSource, Operand, Place, Rvalue, SourceInfo,
    SourceScopeData, Statement, StatementKind, Terminator, TerminatorKind, UnwindAction,
};
use rustc_middle::ty::adjustment::PointerCoercion;
use rustc_middle::ty::{self, Instance, Ty, TyCtxt, TypingEnv};
use rustc_span::{DUMMY_SP, Spanned};

/// The C signature of `main` cg_ssa declares (`create_entry_fn`): `(c_int, *const *const u8)
/// -> c_int`, C ABI.
pub fn c_sig<'tcx>(tcx: TyCtxt<'tcx>) -> ty::PolyFnSig<'tcx> {
    let c_int = match tcx.sess.target.c_int_width {
        16 => tcx.types.i16,
        32 => tcx.types.i32,
        64 => tcx.types.i64,
        w => bug(&format!("c_int width {w}")),
    };
    let argv = Ty::new_imm_ptr(tcx, Ty::new_imm_ptr(tcx, tcx.types.u8));
    let kind = ty::FnSigKind::default().set_abi(rustc_abi::ExternAbi::C { unwind: false });
    ty::Binder::dummy(tcx.mk_fn_sig([c_int, argv], c_int, kind))
}

/// The MIR body of the entry wrapper of the entry fn `main` with `sigpipe`, monomorphic.
pub fn body<'tcx>(tcx: TyCtxt<'tcx>, main: Instance<'tcx>, sigpipe: u8) -> &'tcx Body<'tcx> {
    let typing_env = TypingEnv::fully_monomorphized();
    let span = DUMMY_SP;
    let source_info = SourceInfo::outermost(span);
    let main_ty = Ty::new_fn_def(tcx, main.def_id(), ty::Binder::dummy(main.args));
    let main_sig = tcx.fn_sig(main.def_id()).instantiate_identity().skip_norm_wip();
    let main_ret = tcx.normalize_erasing_late_bound_regions(typing_env, main_sig).output();
    let c_sig = c_sig(tcx).skip_binder();
    let start_def = tcx.require_lang_item(LangItem::Start, span);
    let start_args = [ty::GenericArg::from(main_ret)];
    let start_sig = tcx.normalize_erasing_late_bound_regions(typing_env, tcx.fn_sig(start_def).instantiate(tcx, &start_args).skip_norm_wip());
    let [fn_ptr_ty, argc_ty, argv_ty, _] = start_sig.inputs()[..] else { bug("lang_start's signature") };

    let mut locals: IndexVec<Local, LocalDecl<'tcx>> = IndexVec::new();
    let mut local = |ty| locals.push(LocalDecl::new(ty, span));
    let ret = local(c_sig.output());
    let argc = local(c_sig.inputs()[0]);
    let argv = local(c_sig.inputs()[1]);
    let status = local(start_sig.output());
    let main_ptr = local(fn_ptr_ty);
    let argc_cast = local(argc_ty);
    let argv_cast = local(argv_ty);

    let assign = |place: Local, rvalue| Statement::new(source_info, StatementKind::Assign(Box::new((Place::from(place), rvalue))));
    let reify = CastKind::PointerCoercion(PointerCoercion::ReifyFnPointer(rustc_hir::Safety::Safe), rustc_middle::mir::CoercionSource::Implicit);
    let start = vec![
        assign(main_ptr, Rvalue::Cast(reify, Operand::zero_sized_constant(main_ty, span), fn_ptr_ty)),
        assign(argc_cast, Rvalue::Cast(CastKind::IntToInt, Operand::Move(Place::from(argc)), argc_ty)),
        assign(argv_cast, Rvalue::Cast(CastKind::PtrToPtr, Operand::Move(Place::from(argv)), argv_ty)),
    ];
    let arg = |node| Spanned { node, span };
    let call = TerminatorKind::Call {
        func: Operand::function_handle(tcx, start_def, &start_args, span),
        args: Box::new([
            arg(Operand::Move(Place::from(main_ptr))),
            arg(Operand::Move(Place::from(argc_cast))),
            arg(Operand::Move(Place::from(argv_cast))),
            arg(Operand::const_from_scalar(tcx, tcx.types.u8, Scalar::from_u8(sigpipe), span)),
        ]),
        destination: Place::from(status),
        target: Some(BasicBlock::from_u32(1)),
        // `lang_start` catches the panics of `main`; cg_ssa's wrapper is `nounwind` too.
        unwind: UnwindAction::Unreachable,
        call_source: CallSource::Misc,
        fn_span: span,
    };
    let terminator = |kind| Some(Terminator { source_info, kind, attributes: Default::default() });
    let ret_ty = c_sig.output();
    let blocks = IndexVec::from_raw(vec![
        BasicBlockData::new_stmts(start, terminator(call), false),
        BasicBlockData::new_stmts(
            vec![assign(ret, Rvalue::Cast(CastKind::IntToInt, Operand::Move(Place::from(status)), ret_ty))],
            terminator(TerminatorKind::Return),
            false,
        ),
    ]);
    let scope = SourceScopeData { span, parent_scope: None, inlined: None, inlined_parent_scope: None, local_data: ClearCrossCrate::Clear };
    let mut body =
        Body::new(MirSource::item(main.def_id()), blocks, IndexVec::from_elem_n(scope, 1), locals, IndexVec::new(), 2, Vec::new(), span, None, None);
    body.set_required_consts(Vec::new());
    tcx.arena.alloc(body)
}

fn bug(what: &str) -> ! {
    rustc_middle::bug!("ryo entry wrapper: unexpected {what}")
}
