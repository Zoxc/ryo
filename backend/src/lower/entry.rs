//! The C `main` of a binary whose entry fn is a VM function (design/stubs.md#program-entry-main):
//! a VM function the backend adds to the entry fn's image, lowered from a MIR body it builds
//! itself, as cg_ssa's `maybe_create_entry_wrapper` builds its LLVM function:
//!
//! ```text
//! extern "C" fn main(argc: c_int, argv: *const *const c_char) -> c_int {
//!     lang_start::<T>(entry_fn as fn() -> T, argc as isize, argv as *const *const u8, SIGPIPE) as c_int
//! }
//! ```
//!
//! Its instance is `ryo_rt::entry::c_main::<M, T, SIGPIPE>`: `M` the entry fn's `FnDef` type,
//! `T` its return type, `SIGPIPE` the `on_broken_pipe` setting. The template gives it a
//! `DefId`, its C signature and its symbol (`main`, `symbols.rs`); its own body is never used.

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

use crate::rt::RtItems;

/// The entry wrapper's instance for the entry fn `main` with `sigpipe`.
pub fn wrapper<'tcx>(tcx: TyCtxt<'tcx>, rt: RtItems, main: Instance<'tcx>, sigpipe: u8) -> Instance<'tcx> {
    let typing_env = TypingEnv::fully_monomorphized();
    let sig = tcx.fn_sig(main.def_id()).instantiate_identity().skip_norm_wip();
    let main_ret = tcx.normalize_erasing_late_bound_regions(typing_env, sig).output();
    let main_ty = Ty::new_fn_def(tcx, main.def_id(), ty::Binder::dummy(main.args));
    let sigpipe = ty::Const::from_bits(tcx, u128::from(sigpipe), typing_env, tcx.types.u8);
    Instance::new_raw(rt.c_main, tcx.mk_args(&[main_ty.into(), main_ret.into(), sigpipe.into()]))
}

/// Whether `instance` is an entry wrapper ([`wrapper`]).
pub fn is_wrapper(tcx: TyCtxt<'_>, instance: Instance<'_>) -> bool {
    matches!(instance.def, ty::InstanceKind::Item(def_id) if crate::rt::is_c_main(tcx, def_id))
}

/// The MIR body of the entry wrapper `instance`, monomorphic.
pub fn body<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> &'tcx Body<'tcx> {
    let typing_env = TypingEnv::fully_monomorphized();
    let span = DUMMY_SP;
    let source_info = SourceInfo::outermost(span);
    let main_ty = instance.args.type_at(0);
    let main_ret = instance.args.type_at(1);
    let sigpipe = instance.args.const_at(2).to_leaf().to_u8();

    let c_sig = tcx.normalize_erasing_late_bound_regions(typing_env, tcx.fn_sig(instance.def_id()).instantiate(tcx, instance.args).skip_norm_wip());
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
    let mut body = Body::new(
        MirSource::item(instance.def_id()),
        blocks,
        IndexVec::from_elem_n(scope, 1),
        locals,
        IndexVec::new(),
        2,
        Vec::new(),
        span,
        None,
        None,
    );
    body.set_required_consts(Vec::new());
    tcx.arena.alloc(body)
}

fn bug(what: &str) -> ! {
    rustc_middle::bug!("ryo entry wrapper: unexpected {what}")
}
