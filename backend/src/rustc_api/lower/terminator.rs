//! Terminators other than calls and drops (design/lowering.md#terminators).
//!
//! `br.cmp` fusion: a `SwitchInt` or `Assert` on a `bool` local that the block's last
//! statement computes with an integer compare, and that nothing else uses, branches with
//! `br.cmp.*` on the compare's operands; the compare itself isn't emitted ([`FusedCmp`]).

use rustc_hir::attrs::lang_items::LangItem;
use rustc_index::IndexVec;
use rustc_middle::mir::visit::{PlaceContext, Visitor};
use rustc_middle::mir::{
    AssertKind, BasicBlock, BasicBlockData, BinOp, Body, Local, Location, Operand, Rvalue, SourceInfo,
    StatementKind, SwitchTargets, Terminator, TerminatorKind, UnwindAction, UnwindTerminateReason,
};
use rustc_middle::ty::{self, Instance, Ty};
use ryo_bytecode::insn::Opcode;

use super::call::{ArgSrc, CallCont};
use super::emit::{Width, imm_words, opw, try_opcode};
use super::{FnCx, NeedsNative, native};

/// An integer compare `a op b` (`Eq` … `Ge`) whose `bool` result only feeds the block's
/// `SwitchInt` or `Assert`: the block's last statement, which [`FnCx::blocks`] skips.
#[derive(Clone, Copy)]
pub struct FusedCmp<'tcx> {
    op: BinOp,
    a: &'tcx Operand<'tcx>,
    b: &'tcx Operand<'tcx>,
}

/// How often each local is used (defined, read, borrowed), not counting storage markers and
/// debug info.
pub fn local_uses(body: &Body<'_>) -> IndexVec<Local, u32> {
    struct Count(IndexVec<Local, u32>);
    impl<'tcx> Visitor<'tcx> for Count {
        fn visit_local(&mut self, local: Local, cx: PlaceContext, _: Location) {
            if !matches!(cx, PlaceContext::NonUse(_)) {
                self.0[local] += 1;
            }
        }
    }
    let mut c = Count(IndexVec::from_elem(0, &body.local_decls));
    c.visit_body(body);
    c.0
}

/// A switch over at most this many values per case uses a jump table (`switch.dense`).
const DENSE_MAX_SPAN: u128 = 1024;

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    pub fn terminator(&mut self, term: &Terminator<'tcx>) -> Result<(), NeedsNative> {
        match &term.kind {
            TerminatorKind::Goto { target } => {
                self.jump(*target);
                Ok(())
            }
            TerminatorKind::SwitchInt { discr, targets } => self.switch_int(discr, targets),
            TerminatorKind::Return => {
                let r = self.frame.locals[rustc_middle::mir::RETURN_PLACE];
                self.op(Opcode::Ret, &[r.off, r.layout.size.bytes() as u32]);
                Ok(())
            }
            TerminatorKind::Unreachable => {
                self.op(Opcode::Unreachable, &[]);
                Ok(())
            }
            TerminatorKind::UnwindResume => {
                self.op(Opcode::Resume, &[]);
                Ok(())
            }
            TerminatorKind::UnwindTerminate(reason) => self.terminate_call(*reason, term.source_info),
            TerminatorKind::Call { func, args, destination, target, unwind, call_source: _, fn_span } => {
                // The caller location comes from the call's span (cg_ssa's `codegen_call_terminator`).
                let source_info = rustc_middle::mir::SourceInfo { span: *fn_span, ..term.source_info };
                self.call_terminator(func, args, *destination, *target, *unwind, source_info)
            }
            TerminatorKind::Drop { place, target, unwind, replace: _, drop: _ } => {
                self.drop_terminator(*place, *target, *unwind)
            }
            TerminatorKind::Assert { cond, expected, msg, target, unwind } => {
                self.assert(term, cond, *expected, msg, *target, *unwind)
            }
            TerminatorKind::TailCall { func, args, fn_span } => {
                let source_info = rustc_middle::mir::SourceInfo { span: *fn_span, ..term.source_info };
                self.tail_call_terminator(func, args, source_info)
            }
            TerminatorKind::InlineAsm { .. } => native("inline asm"),
            TerminatorKind::Yield { .. }
            | TerminatorKind::CoroutineDrop
            | TerminatorKind::FalseEdge { .. }
            | TerminatorKind::FalseUnwind { .. } => {
                rustc_middle::bug!("{:?} in runtime MIR of {}", term.kind, self.instance)
            }
        }
    }

    /// The compare that the terminator of `data` can fuse with ([`FusedCmp`]).
    pub fn fusable_compare(&self, data: &'tcx BasicBlockData<'tcx>, uses: &IndexVec<Local, u32>) -> Option<FusedCmp<'tcx>> {
        let cond = match &data.terminator().kind {
            TerminatorKind::SwitchInt { discr, targets } if targets.iter().len() == 1 => discr,
            TerminatorKind::Assert { cond, .. } => cond,
            _ => return None,
        };
        let Operand::Move(cond) = cond else { return None };
        let local = cond.as_local()?;
        let StatementKind::Assign(assign) = &data.statements.last()?.kind else { return None };
        let (dst, Rvalue::BinaryOp(op, ops)) = &**assign else { return None };
        let (a, b) = (&ops.0, &ops.1);
        if dst.as_local() != Some(local) || uses[local] != 2 {
            return None;
        }
        if !matches!(op, BinOp::Eq | BinOp::Ne | BinOp::Lt | BinOp::Le | BinOp::Gt | BinOp::Ge) {
            return None;
        }
        if matches!(a, Operand::Constant(_)) {
            return None;
        }
        let ty = self.mono(a.ty(self.body, self.tcx));
        let thin_ptr = matches!(ty.kind(), ty::RawPtr(..) | ty::Ref(..) | ty::FnPtr(..))
            && self.layout_of(ty).is_ok_and(|l| l.size.bytes() == 8);
        if !(ty.is_integral() || ty.is_bool() || ty.is_char() || thin_ptr) {
            return None;
        }
        Some(FusedCmp { op: *op, a, b })
    }

    /// Branches to `bb` if the fused compare `c` is `when`, and falls through otherwise.
    fn branch_cmp(&mut self, c: FusedCmp<'tcx>, when: bool, bb: BasicBlock) -> Result<(), NeedsNative> {
        let layout = self.operand_layout(c.a)?;
        let Some(w) = Width::of_size(layout.size.bytes()) else { return native("compare of a non-scalar") };
        let su = if layout.ty.is_signed() { "S" } else { "U" };
        // The condition to branch on, as a compare of `a` and `b`.
        let op = if when {
            c.op
        } else {
            match c.op {
                BinOp::Eq => BinOp::Ne,
                BinOp::Ne => BinOp::Eq,
                BinOp::Lt => BinOp::Ge,
                BinOp::Le => BinOp::Gt,
                BinOp::Gt => BinOp::Le,
                BinOp::Ge => BinOp::Lt,
                _ => unreachable!("fused compare {:?}", c.op),
            }
        };
        let name = |op: BinOp| match op {
            BinOp::Eq => "Eq".to_owned(),
            BinOp::Ne => "Ne".to_owned(),
            BinOp::Lt => format!("Lt{su}"),
            BinOp::Le => format!("Le{su}"),
            BinOp::Gt => format!("Gt{su}"),
            BinOp::Ge => format!("Ge{su}"),
            _ => unreachable!(),
        };
        let (sa, _) = self.operand_slot(c.a)?;
        if let Some(v) = self.const_int(c.b)? {
            let Some(opc) = try_opcode(&format!("BrCmp{}Imm{}", name(op), w.suffix())) else {
                return native("no br.cmp.imm for the width");
            };
            let mut ops = vec![sa];
            ops.extend(imm_words(w, w.truncate(v)));
            self.op_branch(opc, &ops, bb);
            return Ok(());
        }
        let (sb, _) = self.operand_slot(c.b)?;
        // Register forms exist for eq/ne/lt/le only: `a > b` is `b < a`.
        let (op, x, y) = match op {
            BinOp::Gt => (BinOp::Lt, sb, sa),
            BinOp::Ge => (BinOp::Le, sb, sa),
            op => (op, sa, sb),
        };
        let Some(opc) = try_opcode(&format!("BrCmp{}{}", name(op), w.suffix())) else {
            return native("no br.cmp for the width");
        };
        self.op_branch(opc, &[x, y], bb);
        Ok(())
    }

    /// A two-way branch on the fused compare: to `t` if it is true, else to `f`, falling
    /// through where possible.
    fn branch_cmp2(&mut self, c: FusedCmp<'tcx>, t: BasicBlock, f: BasicBlock) -> Result<(), NeedsNative> {
        if Some(t) == self.next_block {
            self.branch_cmp(c, false, f)
        } else {
            self.branch_cmp(c, true, t)?;
            self.jump(f);
            Ok(())
        }
    }

    fn switch_int(&mut self, discr: &Operand<'tcx>, targets: &SwitchTargets) -> Result<(), NeedsNative> {
        if let Some(c) = self.fused.take() {
            // A `bool`: one case, 0 or 1 (`fusable_compare`).
            let (v, bb) = targets.iter().next().expect("one case");
            let (t, f) = if v == 0 { (targets.otherwise(), bb) } else { (bb, targets.otherwise()) };
            return self.branch_cmp2(c, t, f);
        }
        let (s, layout) = self.operand_slot(discr)?;
        let Some(w) = Width::of_size(layout.size.bytes()) else { return native("switch on a non-integer") };
        let otherwise = targets.otherwise();
        let mut cases: Vec<(u128, BasicBlock)> = targets.iter().collect();
        match cases[..] {
            [] => {
                self.jump(otherwise);
                return Ok(());
            }
            [(v, bb)] => {
                // One value: a compare-and-branch, falling through where possible.
                let (op, t, rest) = if Some(bb) == self.next_block && Some(otherwise) != self.next_block {
                    ("BrCmpNeImm", otherwise, bb)
                } else {
                    ("BrCmpEqImm", bb, otherwise)
                };
                if layout.ty.is_bool() {
                    let br = if (v == 1) == (op == "BrCmpEqImm") { Opcode::BrIf } else { Opcode::BrUnless };
                    self.op_branch(br, &[s], t);
                } else {
                    let mut ops = vec![s];
                    ops.extend(imm_words(w, v));
                    self.op_branch(opw(op, w), &ops, t);
                }
                self.jump(rest);
                return Ok(());
            }
            _ => {}
        }
        cases.sort_by_key(|&(v, _)| v);
        let (lo, hi) = (cases[0].0, cases[cases.len() - 1].0);
        let span = (hi - lo).saturating_add(1);
        let at = self.code.pos();
        if span <= DENSE_MAX_SPAN && span <= 2 * cases.len() as u128 + 4 {
            let op = opw("SwitchDense", w);
            self.code.words.extend([op as u32, s]);
            self.code.words.extend(imm_words(w, lo));
            let default_word = self.code.pos();
            self.code.words.extend([0, span as u32]);
            self.target_fixup(at, default_word, otherwise);
            let mut next = cases.iter().peekable();
            for v in lo..=hi {
                let word = self.code.pos();
                self.code.words.push(0);
                let bb = match next.peek() {
                    Some(&&(cv, bb)) if cv == v => {
                        next.next();
                        bb
                    }
                    _ => otherwise,
                };
                self.target_fixup(at, word, bb);
            }
        } else {
            let op = opw("SwitchSparse", w);
            self.code.words.extend([op as u32, s]);
            let default_word = self.code.pos();
            self.code.words.extend([0, cases.len() as u32]);
            self.target_fixup(at, default_word, otherwise);
            for &(v, bb) in &cases {
                self.code.words.extend(imm_words(w, v));
                let word = self.code.pos();
                self.code.words.push(0);
                self.target_fixup(at, word, bb);
            }
        }
        Ok(())
    }

    /// A call of the lang item for `reason` (`panic_cannot_unwind`, `panic_in_cleanup`), which
    /// reports the panic and aborts, as cg_ssa's `codegen_terminate_terminator`.
    pub fn terminate_call(&mut self, reason: UnwindTerminateReason, source_info: SourceInfo) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let def_id = tcx.require_lang_item(reason.lang_item(), source_info.span);
        let instance = Instance::mono(tcx, def_id);
        let fty = Ty::new_fn_def(tcx, def_id, ty::Binder::dummy(instance.args));
        self.direct_call(fty, instance, &[], CallCont::diverging(UnwindAction::Unreachable), source_info)
    }

    /// `Assert`: branch to `target` if `cond == expected`, else call the panic function for
    /// `msg` (design/lowering.md#assert-messages, as cg_ssa's `codegen_assert_terminator`).
    fn assert(
        &mut self,
        term: &Terminator<'tcx>,
        cond: &Operand<'tcx>,
        expected: bool,
        msg: &AssertKind<Operand<'tcx>>,
        target: BasicBlock,
        unwind: UnwindAction,
    ) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let mut known = self.const_int(cond)?.map(|v| v == 1);
        if !tcx.sess.overflow_checks() && msg.is_optional_overflow_check() {
            known = Some(expected);
        }
        if known == Some(expected) {
            self.jump(target);
            return Ok(());
        }
        if let Some(c) = self.fused.take() {
            self.branch_cmp(c, expected, target)?;
        } else if known.is_none() {
            let (c, _) = self.operand_slot(cond)?;
            let br = if expected { Opcode::BrIf } else { Opcode::BrUnless };
            self.op_branch(br, &[c], target);
        }
        let (item, args): (LangItem, Vec<ArgSrc<'_, 'tcx>>) = match msg {
            AssertKind::BoundsCheck { len, index } => {
                (LangItem::PanicBoundsCheck, vec![ArgSrc::Operand(index), ArgSrc::Operand(len)])
            }
            AssertKind::MisalignedPointerDereference { required, found } => {
                (LangItem::PanicMisalignedPointerDereference, vec![ArgSrc::Operand(required), ArgSrc::Operand(found)])
            }
            AssertKind::NullPointerDereference => (LangItem::PanicNullPointerDereference, vec![]),
            AssertKind::NullReferenceConstructed => (LangItem::PanicNullReferenceConstructed, vec![]),
            AssertKind::InvalidEnumConstruction(source) => {
                (LangItem::PanicInvalidEnumConstruction, vec![ArgSrc::Operand(source)])
            }
            AssertKind::Overflow(..)
            | AssertKind::OverflowNeg(_)
            | AssertKind::DivisionByZero(_)
            | AssertKind::RemainderByZero(_)
            | AssertKind::ResumedAfterReturn(_)
            | AssertKind::ResumedAfterPanic(_)
            | AssertKind::ResumedAfterDrop(_) => (msg.panic_function(), vec![]),
        };
        let def_id = tcx.require_lang_item(item, term.source_info.span);
        let instance = Instance::mono(tcx, def_id);
        let fty = Ty::new_fn_def(tcx, def_id, ty::Binder::dummy(instance.args));
        self.direct_call(fty, instance, &args, CallCont::diverging(unwind), term.source_info)
    }
}
