//! Terminators other than calls and drops (design/lowering.md#terminators).

use rustc_hir::attrs::lang_items::LangItem;
use rustc_middle::mir::{AssertKind, BasicBlock, Operand, SwitchTargets, Terminator, TerminatorKind, UnwindAction};
use rustc_middle::ty::{self, Instance, Ty};
use ryo_bytecode::insn::Opcode;

use super::call::{ArgSrc, CallCont};
use super::emit::{Width, imm_words, opw};
use super::{FnCx, NeedsNative, native};

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
            TerminatorKind::UnwindTerminate(_) => {
                self.op(Opcode::Abort, &[]);
                Ok(())
            }
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
            TerminatorKind::TailCall { .. } => native("TailCall"),
            TerminatorKind::InlineAsm { .. } => native("inline asm"),
            TerminatorKind::Yield { .. }
            | TerminatorKind::CoroutineDrop
            | TerminatorKind::FalseEdge { .. }
            | TerminatorKind::FalseUnwind { .. } => {
                rustc_middle::bug!("{:?} in runtime MIR of {}", term.kind, self.instance)
            }
        }
    }

    fn switch_int(&mut self, discr: &Operand<'tcx>, targets: &SwitchTargets) -> Result<(), NeedsNative> {
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
        if known.is_none() {
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
