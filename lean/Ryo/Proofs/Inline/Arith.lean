/-
Ryo.Proofs.Inline.Arith — the integer inline sequences against `opSem`: `bin` (add, sub, and,
or, xor), `binImm`, `mul`, `mulImm`, `shiftImm`, at each width.

The class files import each other in a chain (`Move`, `Arith`, `Cmp`, `Ext`, `Ovf`,
`LaterDiv`): `bv_decide` declares helpers (`W.enumToBitVec`, …) in the first module that needs
them, and two modules that both declare one can't be imported together.
-/
import Ryo.Proofs.Inline.Move

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm


theorem sound_bin (a : Alu) (w : W) : Sound (.bin a w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  have hty := (tyName_parse w).1
  have hkd : aluKind false a = .bin ∨ aluKind false a = .binop := by
    cases a <;> simp [aluKind]
  obtain ⟨ba, bb, va, vb, res, hra, hrb, hva, hvb, hres, hwr, rfl⟩ :=
    opSem_bin hkd hh hty ho hsem
  have hfp : footprintOf (aluKind false a) [tyName false w, aluMethod a] =
      some { reads := [rdA "a" (wbytes w), rdA "b" (wbytes w)],
             writes := [rdA "d" (wbytes w)] } := by
    rcases hkd with h | h <;> rw [h]
    · exact (fp_w (tySize_of_parse hty)).2.2.1
    · exact (fp_w (tySize_of_parse hty)).2.2.2.1
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .slot s2.toInt]) (d := s0.toInt)
    hh hfp (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  have hb := read_int hr (by omega) hrb hvb
  subst ha hb
  have hlen : (intBytes (wbytes w) res.toNat).length = wbytes w := by
    simp [intBytes, Theorems.encodeBits_length]
  cases a <;> simp [intBin, aluMethod, pure, Except.pure, throw, throwThe, MonadExceptOf.throw] at hres
  all_goals
    subst hres
    cases w <;> xrun <;>
      refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals rfl

set_option maxHeartbeats 1000000 in
theorem sound_binImm (a : Alu) (w : W) : Sound (.binImm a w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨i, rfl, rfl, hi⟩ := nv_imm (by cases w <;> simp [immKind]) h2
  have hty := (tyName_parse w).1
  have hkd : aluKind true a = .bin_imm ∨ aluKind true a = .binop_imm ∨
      aluKind true a = .shift_imm := by
    cases a <;> simp [aluKind]
  obtain ⟨ba, va, res, hra, hva, hres, hwr, rfl⟩ := opSem_binImm hkd hh hty ho hsem
  have hfp : footprintOf (aluKind true a) [tyName false w, aluMethod a] =
      some { reads := [rdA "a" (wbytes w)], writes := [rdA "d" (wbytes w)] } := by
    rcases hkd with h | h | h <;> rw [h]
    · exact (fp_w (tySize_of_parse hty)).2.2.2.2.1
    · exact (fp_w (tySize_of_parse hty)).2.2.2.2.2.1
    · exact (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.1
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .imm i.toNat]) (d := s0.toInt)
    hh hfp (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  subst ha
  have hlen : (intBytes (wbytes w) res.toNat).length = wbytes w := by
    simp [intBytes, Theorems.encodeBits_length]
  cases a <;> simp [intBin, aluMethod, pure, Except.pure, throw, throwThe, MonadExceptOf.throw]
    at hres
  all_goals
    subst hres
    cases w
  all_goals
    simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
      Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ,
      List.cons_append, List.nil_append] at hseq
  case' add.q | sub.q | and.q | or.q | xor.q =>
    by_cases hf : fits i = true <;>
      simp only [hf, Bool.not_true, Bool.not_false, Bool.false_eq_true, ↓reduceIte,
        List.cons_append, List.nil_append] at hseq
  all_goals
    obtain ⟨rfl, rfl⟩ := hseq
    xrun
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals first | with_reducible rfl | ((try simp only [fits_iff] at hf); bv_decide)

theorem sound_mul (w : W) : Sound (.mul w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  have hty := (tyName_parse w).1
  obtain ⟨ba, bb, va, vb, res, hra, hrb, hva, hvb, hres, hwr, rfl⟩ :=
    opSem_bin (Or.inl rfl) hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .slot s2.toInt]) (d := s0.toInt)
    hh (fp_w (tySize_of_parse hty)).2.2.1 (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  have hb := read_int hr (by omega) hrb hvb
  subst ha hb
  have hlen : (intBytes (wbytes w) res.toNat).length = wbytes w := by
    simp [intBytes, Theorems.encodeBits_length]
  simp [intBin, pure, Except.pure] at hres
  subst hres
  cases w
  all_goals
    simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
      Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ,
      List.cons_append, List.nil_append] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    xrun
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals first | with_reducible rfl | bv_decide

theorem sound_mulImm (w : W) : Sound (.mulImm w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨i, rfl, rfl, hi⟩ := nv_imm (by cases w <;> simp [immKind]) h2
  have hty := (tyName_parse w).1
  obtain ⟨ba, va, res, hra, hva, hres, hwr, rfl⟩ :=
    opSem_binImm (Or.inl rfl) hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .imm i.toNat]) (d := s0.toInt)
    hh (fp_w (tySize_of_parse hty)).2.2.2.2.1 (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  subst ha
  have hlen : (intBytes (wbytes w) res.toNat).length = wbytes w := by
    simp [intBytes, Theorems.encodeBits_length]
  simp [intBin, pure, Except.pure] at hres
  subst hres
  cases w
  all_goals
    simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
      Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ,
      List.cons_append, List.nil_append] at hseq
  case' q =>
    by_cases hf : fits i = true <;>
      simp only [hf, Bool.not_true, Bool.not_false, Bool.false_eq_true, ↓reduceIte,
        List.cons_append, List.nil_append] at hseq
  all_goals
    obtain ⟨rfl, rfl⟩ := hseq
    xrun
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals first
    | with_reducible rfl
    | (simp only [fits_iff] at hf; simp only [hf]; done)
    | (simp only [fits_iff] at hf; simp only [hf]; rfl)
    | bv_decide

theorem sound_shiftImm (sh : Sh) (w : W) (hsh : sh.isShift = true) : Sound (.shiftImm sh w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨i, rfl, rfl, hi⟩ := nv_imm (by cases w <;> simp [immKind]) h2
  have hty : Ty.parse (tyName (sh == .sar) w) = some (.int (wbytes w) (sh == .sar)) := by
    cases sh
    · exact (tyName_parse w).1
    · exact (tyName_parse w).1
    · exact (tyName_parse w).2
    all_goals simp [Sh.isShift] at hsh
  obtain ⟨ba, va, res, hra, hva, hres, hwr, rfl⟩ :=
    opSem_binImm (Or.inr (Or.inr rfl)) hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .imm i.toNat]) (d := s0.toInt)
    hh (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.1 (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  subst ha
  have hlen : (intBytes (wbytes w) res.toNat).length = wbytes w := by
    simp [intBytes, Theorems.encodeBits_length]
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  by_cases hc : i.toNat ≥ w.bits
  · simp [hc] at hseq
  simp only [ge_iff_le, hc, ↓reduceIte, Option.some.injEq,
    Prod.mk.injEq] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  have hlt : i < BitVec.ofNat 64 w.bits := by
    rw [BitVec.lt_def]; cases w <;> simp [W.bits] at hc ⊢ <;> omega
  have hm8 : i.toNat % 256 = i.toNat := Nat.mod_eq_of_lt (by cases w <;> simp [W.bits] at hc <;> omega)
  have hm64 : i.toNat % 64 = i.toNat :=
    Nat.mod_eq_of_lt (by cases w <;> simp [W.bits] at hc ⊢ <;> omega)
  have hm32 : w ≠ .q → i.toNat % 32 = i.toNat := by
    cases w <;> simp [W.bits] at hc ⊢ <;> omega
  have hmw : i.toNat % w.bits = i.toNat := Nat.mod_eq_of_lt (by omega)
  cases sh <;> (try simp [Sh.isShift] at hsh) <;> simp [intBin, shMethod, pure, Except.pure] at hres
  all_goals
    subst hres
    cases w
  all_goals
    xrun
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals simp only [W.bits, ne_eq, reduceCtorEq, not_false_eq_true, forall_const] at hlt hmw hm32
  all_goals xobs
  all_goals
    first
    | with_reducible rfl
    | ((try simp only [hmw])
       (try simp only [hm32])
       (try simp only [shr_nat, sar_nat])
       first | done | exact shl_nat .. | exact shr_nat .. | exact sar_nat .. | bv_decide)

end Ryo.Proofs.Inline
