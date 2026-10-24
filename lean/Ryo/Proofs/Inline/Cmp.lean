/-
Ryo.Proofs.Inline.Cmp — the comparisons and branches against `opSem`: `cmp`, `cmpImm` (the
`setcc` byte), `br`, `brCmp`, `brCmpImm` (the condition on the flags, with the polarity), at
each width and condition.
-/
import Ryo.Proofs.Inline.Arith

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm


theorem sound_cmp (c : Cond) (w : W) : Sound (.cmp c w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hp
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, cmpParams] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  have hty : Ty.parse (tyName (condOp c).2 w) = some (.int (wbytes w) (condOp c).2) := by
    cases h : (condOp c).2
    · exact (tyName_parse w).1
    · exact (tyName_parse w).2
  obtain ⟨ba, bb, va, vb, res, hra, hrb, hva, hvb, hres, hwr, rfl⟩ := opSem_cmp hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .slot s2.toInt]) (d := s0.toInt)
    hh (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.2.1 (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  have hb := read_int hr (by omega) hrb hvb
  subst ha hb
  have hlen : (boolByte res).length = 1 := rfl
  cases c <;> simp [condOp, intCmp, pure, Except.pure, throw, throwThe, MonadExceptOf.throw]
    at hres
  all_goals
    subst hres
    cases w
  all_goals
    xrun
    refine post_mem hr hwr hlen (by decide) hwr' hp (bytesRel_bool ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals first | with_reducible rfl | bv_decide

theorem sound_cmpImm (c : Cond) (w : W) : Sound (.cmpImm c w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hp
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, cmpParams] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨i, rfl, rfl, hi⟩ := nv_imm (by cases w <;> simp [immKind]) h2
  have hty : Ty.parse (tyName (condOp c).2 w) = some (.int (wbytes w) (condOp c).2) := by
    cases h : (condOp c).2
    · exact (tyName_parse w).1
    · exact (tyName_parse w).2
  obtain ⟨ba, va, res, hra, hva, hres, hwr, rfl⟩ := opSem_cmpImm hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .imm i.toNat]) (d := s0.toInt)
    hh (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.2.2.1 (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  subst ha
  have hlen : (boolByte res).length = 1 := rfl
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ,
    cmpImmSeq] at hseq
  cases c <;> simp [condOp, intCmp, pure, Except.pure, throw, throwThe, MonadExceptOf.throw]
    at hres
  all_goals
    subst hres
    cases w
  case' z.q | nz.q | l.q | b.q | le.q | be.q | g.q | a.q | ge.q | ae.q => by_cases hf : fits i = true
  all_goals first | simp [-fits_iff, hf] at hseq | simp at hseq
  all_goals
    obtain ⟨rfl, rfl⟩ := hseq
    xrun
    refine post_mem hr hwr hlen (by decide) hwr' hp (bytesRel_bool ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals first | with_reducible rfl | ((try simp only [fits_iff] at hf); bv_decide)

theorem sound_br : Sound .br := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hp
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨n, rfl, rfl⟩ := nv_neg.1 h1
  obtain ⟨t, rfl, rfl⟩ := nv_target.1 h2
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  obtain ⟨bs, v, hrd, hv', rfl, rfl⟩ := opSem_br hh ho hsem
  have ha := read_int hr (n := 1) (by omega) hrd hv'
  subst ha
  have hlt := Theorems.leDecode_lt (bytesAt x.mem (fpAddr x s0.toInt) 1)
  simp only [bytesAt_length] at hlt
  have hlt8 : leDecode (bytesAt x.mem (fpAddr x s0.toInt) 1) < 2 ^ 8 := by simpa using hlt
  xrun
  refine post_branch hr ?_ ?_ ?_ ?_ ?_ ⟨_, rfl, fun neg t' h => ?_⟩
  · xobs
  · xobs
  · xobs
  · xobs
  · xobs
  · have := nativeCtl_neg h
    simp [ho] at this
    subst this
    cases n <;> simp [Cond.not, Cond.cc?, Cond.ofCc?, Cond.eval, need, State.memW,
      readNat_eq, Functor.map, Except.map, State.ea, M.frame, rbp_sext, W.bits] <;>
      exact br_zf hlt8

theorem sound_brCmp (c : Cond) (w : W) : Sound (.brCmp c w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hp
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, cmpParams] at hh ho
  obtain ⟨o0, o1, o2, o3, v0, v1, v2, v3, rfl, rfl, h0, h1, h2, h3⟩ := nvs4 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨n, rfl, rfl⟩ := nv_neg.1 h2
  obtain ⟨t, rfl, rfl⟩ := nv_target.1 h3
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  have hty : Ty.parse (tyName (condOp c).2 w) = some (.int (wbytes w) (condOp c).2) := by
    cases h : (condOp c).2
    · exact (tyName_parse w).1
    · exact (tyName_parse w).2
  obtain ⟨ba, bb, va, vb, res, hra, hrb, hva, hvb, hres, rfl, rfl⟩ := opSem_brCmp hh hty ho hsem
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  have hb := read_int hr (by omega) hrb hvb
  subst ha hb
  cases c <;> simp [condOp, intCmp, pure, Except.pure, throw, throwThe, MonadExceptOf.throw]
    at hres
  all_goals
    subst hres
    cases w
  all_goals
    xrun
    refine post_branch hr ?_ ?_ ?_ ?_ ?_ ⟨_, rfl, fun neg t' h => ?_⟩
  all_goals try xobs
  all_goals
    have := nativeCtl_neg h
    simp [ho] at this
    subst this
    cases n <;> simp [Cond.not, Cond.cc?, Cond.ofCc?, Cond.eval, need, Functor.map, Except.map] <;>
      bv_decide

theorem sound_brCmpImm (c : Cond) (w : W) : Sound (.brCmpImm c w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hp
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, cmpParams] at hh ho
  obtain ⟨o0, o1, o2, o3, v0, v1, v2, v3, rfl, rfl, h0, h1, h2, h3⟩ := nvs4 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨i, rfl, rfl, hi⟩ := nv_imm (by cases w <;> simp [immKind]) h1
  obtain ⟨n, rfl, rfl⟩ := nv_neg.1 h2
  obtain ⟨t, rfl, rfl⟩ := nv_target.1 h3
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ,
    cmpImmSeq] at hseq
  have hty : Ty.parse (tyName (condOp c).2 w) = some (.int (wbytes w) (condOp c).2) := by
    cases h : (condOp c).2
    · exact (tyName_parse w).1
    · exact (tyName_parse w).2
  obtain ⟨ba, va, res, hra, hva, hres, rfl, rfl⟩ := opSem_brCmpImm hh hty ho hsem
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  subst ha
  cases c <;> simp [condOp, intCmp, pure, Except.pure, throw, throwThe, MonadExceptOf.throw]
    at hres
  all_goals
    subst hres
    cases w
  case' z.q | l.q | b.q | g.q | a.q | nz.q | le.q | be.q | ge.q | ae.q =>
    by_cases hf : fits i = true
  all_goals first | simp [-fits_iff, hf] at hseq | simp at hseq
  all_goals
    obtain ⟨rfl, rfl⟩ := hseq
    xrun
    refine post_branch hr ?_ ?_ ?_ ?_ ?_ ⟨_, rfl, fun neg t' h => ?_⟩
  all_goals try xobs
  all_goals
    have := nativeCtl_neg h
    simp [ho] at this
    subst this
    (try simp only [fits_iff] at hf)
    cases n <;> simp [Cond.not, Cond.cc?, Cond.ofCc?, Cond.eval, need, Functor.map, Except.map] <;>
      bv_decide

end Ryo.Proofs.Inline
