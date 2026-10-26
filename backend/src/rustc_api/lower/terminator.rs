//! Terminators other than calls and drops (design/lowering.md#terminators).
//!
//! Compare fusion: a `SwitchInt` or `Assert` on a `bool` local that the block's last
//! statement computes with an integer compare, and that nothing else uses, branches with
//! `br.eq`/`br.lt`/`br.gt.imm` on the compare's operands; the compare itself isn't emitted
//! ([`FusedCmp`]). Each compare is one of those with a polarity and maybe swapped operands
//! ([`branch_form`]).

use rustc_abi::{TagEncoding, Variants};
use rustc_hir::attrs::lang_items::LangItem;
use rustc_index::IndexVec;
use rustc_middle::mir::visit::{PlaceContext, Visitor};
use rustc_middle::mir::{
    AssertKind, BasicBlock, BasicBlockData, BinOp, Body, Local, Location, Operand, Place, Rvalue, SourceInfo, StatementKind, SwitchTargets,
    Terminator, TerminatorKind, UnwindAction, UnwindTerminateReason,
};
use rustc_middle::ty::{self, Instance, Ty};
use ryo_bytecode::asm::Opnd;
use ryo_bytecode::full::Opcode;

use super::call::{ArgSrc, CallCont};
use super::emit::{Width, opw, try_opcode};
use super::{FnCx, NeedsNative, native};

/// The branch that tests `a op b`: the compare it calls (`"Eq"`, `"Lt"`, `"Gt"`), whether
/// `a` and `b` are swapped, and its polarity (`neg`: branch when the compare is false). The
/// register forms exist for `eq` and `lt`, the immediate forms (`imm`, `b` the immediate)
/// also for `gt`.
pub fn branch_form(op: BinOp, imm: bool) -> (&'static str, bool, bool) {
    match (op, imm) {
        (BinOp::Eq, _) => ("Eq", false, false),
        (BinOp::Ne, _) => ("Eq", false, true),
        (BinOp::Lt, _) => ("Lt", false, false),
        (BinOp::Ge, _) => ("Lt", false, true),
        (BinOp::Gt, false) => ("Lt", true, false),
        (BinOp::Le, false) => ("Lt", true, true),
        (BinOp::Gt, true) => ("Gt", false, false),
        (BinOp::Le, true) => ("Gt", false, true),
        _ => unreachable!("not a compare: {op:?}"),
    }
}

/// An integer compare `a op b` (`Eq` … `Ge`) whose `bool` result only feeds the block's
/// `SwitchInt` or `Assert`: the block's last statement, which [`FnCx::blocks`] skips.
#[derive(Clone, Copy)]
pub struct FusedCmp<'tcx> {
    op: BinOp,
    a: &'tcx Operand<'tcx>,
    b: &'tcx Operand<'tcx>,
}

/// What the block's last statement fuses into its terminator, which then lowers it.
#[derive(Clone, Copy)]
pub enum Fused<'tcx> {
    /// A compare feeding a `SwitchInt` or `Assert` ([`FusedCmp`]).
    Cmp(FusedCmp<'tcx>),
    /// `_d = discriminant(p)` of a niche-encoded enum, `_d` only feeding the `SwitchInt`: the
    /// switch tests the tag of `p` directly ([`FnCx::switch_niche`]).
    Discr(Place<'tcx>),
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

/// A niche switch with at most this many tested arms branches on the tag with `br.eq.imm`.
const NICHE_TESTS_MAX: usize = 4;

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
                self.ret();
                Ok(())
            }
            TerminatorKind::Unreachable => {
                self.op(Opcode::Unreachable, &[]);
                Ok(())
            }
            TerminatorKind::UnwindResume => {
                let at = self.op(Opcode::Resume, &[self.frame.exception_slot()]);
                self.unwind_entry(at, UnwindAction::Continue);
                Ok(())
            }
            TerminatorKind::UnwindTerminate(reason) => self.terminate_call(*reason, term.source_info),
            TerminatorKind::Call { func, args, destination, target, unwind, call_source: _, fn_span } => {
                // The caller location comes from the call's span (cg_ssa's `codegen_call_terminator`).
                let source_info = rustc_middle::mir::SourceInfo { span: *fn_span, ..term.source_info };
                self.call_terminator(func, args, *destination, *target, *unwind, source_info)
            }
            TerminatorKind::Drop { place, target, unwind, replace: _, drop: _ } => self.drop_terminator(*place, *target, *unwind),
            TerminatorKind::Assert { cond, expected, msg, target, unwind } => self.assert(term, cond, *expected, msg, *target, *unwind),
            TerminatorKind::TailCall { func, args, fn_span } => {
                let source_info = rustc_middle::mir::SourceInfo { span: *fn_span, ..term.source_info };
                self.tail_call_terminator(func, args, source_info)
            }
            TerminatorKind::InlineAsm { .. } => native("inline asm"),
            TerminatorKind::Yield { .. } | TerminatorKind::CoroutineDrop | TerminatorKind::FalseEdge { .. } | TerminatorKind::FalseUnwind { .. } => {
                rustc_middle::bug!("{:?} in runtime MIR of {}", term.kind, self.instance)
            }
        }
    }

    /// The last statement of `data` that its terminator can lower together with ([`Fused`]).
    pub fn fusable(&self, data: &'tcx BasicBlockData<'tcx>, uses: &IndexVec<Local, u32>) -> Option<Fused<'tcx>> {
        if let Some(c) = self.fusable_compare(data, uses) {
            return Some(Fused::Cmp(c));
        }
        self.fusable_discr(data, uses).map(Fused::Discr)
    }

    /// The place whose niche-encoded discriminant only the `SwitchInt` of `data` reads.
    fn fusable_discr(&self, data: &'tcx BasicBlockData<'tcx>, uses: &IndexVec<Local, u32>) -> Option<Place<'tcx>> {
        let TerminatorKind::SwitchInt { discr, .. } = &data.terminator().kind else { return None };
        let Rvalue::Discriminant(p) = fused_def(data, discr, uses)? else { return None };
        let layout = self.layout_of(self.mono(p.ty(self.body, self.tcx).ty)).ok()?;
        matches!(layout.variants, Variants::Multiple { tag_encoding: TagEncoding::Niche { .. }, .. }).then_some(*p)
    }

    /// The compare that the terminator of `data` can fuse with ([`FusedCmp`]).
    fn fusable_compare(&self, data: &'tcx BasicBlockData<'tcx>, uses: &IndexVec<Local, u32>) -> Option<FusedCmp<'tcx>> {
        let cond = match &data.terminator().kind {
            TerminatorKind::SwitchInt { discr, targets } if targets.iter().len() == 1 => discr,
            TerminatorKind::Assert { cond, .. } => cond,
            _ => return None,
        };
        let Rvalue::BinaryOp(op, ops) = fused_def(data, cond, uses)? else { return None };
        let (a, b) = (&ops.0, &ops.1);
        if !matches!(op, BinOp::Eq | BinOp::Ne | BinOp::Lt | BinOp::Le | BinOp::Gt | BinOp::Ge) {
            return None;
        }
        if matches!(a, Operand::Constant(_)) {
            return None;
        }
        let ty = self.mono(a.ty(self.body, self.tcx));
        let thin_ptr = matches!(ty.kind(), ty::RawPtr(..) | ty::Ref(..) | ty::FnPtr(..)) && self.layout_of(ty).is_ok_and(|l| l.size.bytes() == 8);
        if !(ty.is_integral() || ty.is_bool() || ty.is_char() || thin_ptr) {
            return None;
        }
        Some(FusedCmp { op: *op, a, b })
    }

    /// Branches to `bb` if the fused compare `c` is `when`, and falls through otherwise. The
    /// branch's handler computes the compare or (`neg` of [`branch_form`]) its negation, so the
    /// branch is taken on a false handler result exactly when those two agree.
    fn branch_cmp(&mut self, c: FusedCmp<'tcx>, when: bool, bb: BasicBlock) -> Result<(), NeedsNative> {
        let layout = self.operand_layout(c.a)?;
        let Some(w) = Width::of_size(layout.size.bytes()) else { return native("compare of a non-scalar") };
        let su = if layout.ty.is_signed() { "S" } else { "U" };
        let name = |cmp: &str| if cmp == "Eq" { cmp.to_owned() } else { format!("{cmp}{su}") };
        let (sa, _) = self.operand_slot(c.a)?;
        if let Some(v) = self.const_int(c.b)? {
            let (cmp, _, neg) = branch_form(c.op, true);
            if try_opcode(&format!("Br{}Imm{}", name(cmp), w.suffix())).is_none() {
                return native("no br.imm for the width");
            }
            self.br_imm(&name(cmp), w, sa, v, neg == when, bb);
            return Ok(());
        }
        let (sb, _) = self.operand_slot(c.b)?;
        let (cmp, swap, neg) = branch_form(c.op, false);
        let (x, y) = if swap { (sb, sa) } else { (sa, sb) };
        let Some(opc) = try_opcode(&format!("Br{}{}", name(cmp), w.suffix())) else {
            return native("no br for the width");
        };
        self.op_branch(opc, &[x, y], neg == when, bb);
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
        if let Some(Fused::Discr(p)) = self.fused {
            self.fused = None;
            return self.switch_niche(p, targets);
        }
        if let Some(Fused::Cmp(c)) = self.fused.take() {
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
                // One value: a compare-and-branch, falling through where possible. `ne`
                // branches when `s != v`.
                let (ne, t, rest) =
                    if Some(bb) == self.next_block && Some(otherwise) != self.next_block { (true, otherwise, bb) } else { (false, bb, otherwise) };
                if layout.ty.is_bool() {
                    // `br` branches when `s != 0`.
                    self.op_branch(Opcode::Br, &[s], (v == 1) == ne, t);
                } else {
                    self.br_imm("Eq", w, s, v, ne, t);
                }
                self.jump(rest);
                return Ok(());
            }
            _ => {}
        }
        cases.sort_by_key(|&(v, _)| v);
        if let [(v0, bb0), (v1, bb1)] = cases[..]
            && w != Width::W128
        {
            // Two values: compare-and-branch on each instead of a `switch.dense` table. An
            // unreachable `otherwise` makes the second test unnecessary.
            let test = |fx: &mut Self, v: u128, ne: bool, bb: BasicBlock| fx.br_imm("Eq", w, s, v, ne, bb);
            test(self, v0, false, bb0);
            if self.body[otherwise].is_empty_unreachable() {
                self.jump(bb1);
            } else if Some(bb1) == self.next_block && Some(otherwise) != self.next_block {
                test(self, v1, true, otherwise);
            } else {
                test(self, v1, false, bb1);
                self.jump(otherwise);
            }
            return Ok(());
        }
        let (lo, hi) = (cases[0].0, cases[cases.len() - 1].0);
        let span = (hi - lo).saturating_add(1);
        let base = |v: u128| if w == Width::W128 { Opnd::Imm128(v) } else { Opnd::Imm(v as u64) };
        let default = self.block_label(otherwise);
        if span <= DENSE_MAX_SPAN && span <= 2 * cases.len() as u128 + 4 {
            let mut next = cases.iter().peekable();
            let mut targets = Vec::with_capacity(span as usize);
            for v in lo..=hi {
                let bb = match next.peek() {
                    Some(&&(cv, bb)) if cv == v => {
                        next.next();
                        bb
                    }
                    _ => otherwise,
                };
                targets.push(self.block_label(bb));
            }
            self.emit(opw("SwitchDense", w), vec![Opnd::Slot(s as i32), base(lo), Opnd::Target(default), Opnd::Targets(targets)]);
        } else {
            let vals = cases.iter().map(|&(v, _)| v).collect();
            let targets = cases.iter().map(|&(_, bb)| self.block_label(bb)).collect();
            self.emit(opw("SwitchSparse", w), vec![Opnd::Slot(s as i32), Opnd::Target(default), Opnd::Cases(vals, targets)]);
        }
        Ok(())
    }

    /// A `SwitchInt` on the discriminant of `p`, a niche-encoded enum, that tests the tag
    /// instead of decoding it (cg_ssa's `codegen_get_discr` folded into the switch). The
    /// switch values are variant indices; niche variant `i` has tag `niche_start + (i -
    /// start)` (wrapping at the tag width), and the untagged variant is "no niche variant
    /// matched". Up to [`NICHE_TESTS_MAX`] tested arms are `br.eq.imm` on the tag, more a
    /// `switch.dense` on `tag - niche_start` after a range check.
    fn switch_niche(&mut self, p: Place<'tcx>, targets: &SwitchTargets) -> Result<(), NeedsNative> {
        let pv = self.place(p)?;
        let Some(n) = self.niche_tag(pv)? else { unreachable!("fusable_discr checked the layout") };
        let tw = n.tw;
        let target = |v: u32| targets.iter().find(|&(c, _)| c == u128::from(v)).map_or(targets.otherwise(), |(_, bb)| bb);
        let untagged_bb = target(n.untagged);
        // `otherwise` covers the variant indices the switch doesn't list; when it is
        // unreachable, those arms aren't tested.
        let dead = |bb: BasicBlock| bb == targets.otherwise() && self.body[bb].is_empty_unreachable();
        let tag_of = |i: u32| tw.truncate(n.niche_start.wrapping_add(u128::from(i - n.start)));
        let arms: Vec<(u128, BasicBlock)> = (n.start..=n.end)
            .filter(|&i| i != n.untagged)
            .map(|i| (tag_of(i), target(i)))
            .filter(|&(_, bb)| bb != untagged_bb && !dead(bb))
            .collect();
        if arms.len() <= NICHE_TESTS_MAX {
            for (k, &(v, bb)) in arms.iter().enumerate() {
                if k + 1 == arms.len() && Some(bb) == self.next_block && Some(untagged_bb) != self.next_block {
                    // The last arm falls through: branch away when the tag differs.
                    self.br_imm("Eq", tw, n.slot, v, true, untagged_bb);
                    return Ok(());
                }
                self.br_imm("Eq", tw, n.slot, v, false, bb);
            }
            self.jump(untagged_bb);
            return Ok(());
        }
        // `r = tag - niche_start`; `r >u relative_max` is the untagged variant, otherwise `r`
        // is the niche variant `start + r`.
        let r = self.frame.temp(u64::from(tw.bytes()), u64::from(tw.bytes()));
        self.op_imm("Sub", tw, r, n.slot, n.niche_start);
        self.br_imm("GtU", tw, r, u128::from(n.end - n.start), false, untagged_bb);
        let labels = (n.start..=n.end).map(|i| self.block_label(target(i))).collect();
        let base = if tw == Width::W128 { Opnd::Imm128(0) } else { Opnd::Imm(0) };
        let default = self.block_label(untagged_bb);
        self.emit(opw("SwitchDense", tw), vec![Opnd::Slot(r as i32), base, Opnd::Target(default), Opnd::Targets(labels)]);
        Ok(())
    }

    /// A call of the lang item for `reason` (`panic_cannot_unwind`, `panic_in_cleanup`), which
    /// reports the panic and aborts, as cg_ssa's `codegen_terminate_terminator`.
    pub fn terminate_call(&mut self, reason: UnwindTerminateReason, source_info: SourceInfo) -> Result<(), NeedsNative> {
        self.lang_item_call(reason.lang_item(), &[], UnwindAction::Unreachable, source_info)
    }

    /// A diverging call of the monomorphic lang item `item` (a panic function).
    fn lang_item_call(
        &mut self,
        item: LangItem,
        args: &[ArgSrc<'_, 'tcx>],
        unwind: UnwindAction,
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let tcx = self.tcx;
        let def_id = tcx.require_lang_item(item, source_info.span);
        let instance = Instance::mono(tcx, def_id);
        let fty = Ty::new_fn_def(tcx, def_id, ty::Binder::dummy(instance.args));
        self.direct_call(fty, instance, args, CallCont::diverging(unwind), source_info)
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
        if let Some(Fused::Cmp(c)) = self.fused.take() {
            self.branch_cmp(c, expected, target)?;
        } else if known.is_none() {
            let (c, _) = self.operand_slot(cond)?;
            self.op_branch(Opcode::Br, &[c], !expected, target);
        }
        let (item, args): (LangItem, Vec<ArgSrc<'_, 'tcx>>) = match msg {
            AssertKind::BoundsCheck { len, index } => (LangItem::PanicBoundsCheck, vec![ArgSrc::Operand(index), ArgSrc::Operand(len)]),
            AssertKind::MisalignedPointerDereference { required, found } => {
                (LangItem::PanicMisalignedPointerDereference, vec![ArgSrc::Operand(required), ArgSrc::Operand(found)])
            }
            AssertKind::NullPointerDereference => (LangItem::PanicNullPointerDereference, vec![]),
            AssertKind::NullReferenceConstructed => (LangItem::PanicNullReferenceConstructed, vec![]),
            AssertKind::InvalidEnumConstruction(source) => (LangItem::PanicInvalidEnumConstruction, vec![ArgSrc::Operand(source)]),
            AssertKind::Overflow(..)
            | AssertKind::OverflowNeg(_)
            | AssertKind::DivisionByZero(_)
            | AssertKind::RemainderByZero(_)
            | AssertKind::ResumedAfterReturn(_)
            | AssertKind::ResumedAfterPanic(_)
            | AssertKind::ResumedAfterDrop(_) => (msg.panic_function(), vec![]),
        };
        self.lang_item_call(item, &args, unwind, term.source_info)
    }
}

/// The rvalue that the last statement of `data` assigns to `cond`, when that statement is
/// `cond`'s only definition and the terminator is its only other use.
fn fused_def<'b, 'tcx>(data: &'b BasicBlockData<'tcx>, cond: &Operand<'tcx>, uses: &IndexVec<Local, u32>) -> Option<&'b Rvalue<'tcx>> {
    let Operand::Move(cond) = cond else { return None };
    let local = cond.as_local()?;
    let StatementKind::Assign(assign) = &data.statements.last()?.kind else { return None };
    let (dst, rvalue) = &**assign;
    (dst.as_local() == Some(local) && uses[local] == 2).then_some(rvalue)
}
