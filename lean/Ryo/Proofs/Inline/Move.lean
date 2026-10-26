/-
Ryo.Proofs.Inline.Move — the inline sequences that move bytes and pointers against `opSem`:
`mov` (each width), `mov.w128`, `imm`, `addr`, `ptr.add`, `ptr.index`.
-/
import Ryo.Proofs.Inline.Basic

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm


theorem sound_mov (w : W) : Sound (.mov w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  have hty : Ty.parse (tyName false w) = some (.int (wbytes w) false) := by cases w <;> rfl
  obtain ⟨bs, hrd, hwr, rfl⟩ := opSem_mov hh hty ho hsem
  have hwr' : wranges op [.slot s0.toInt, .slot s1.toInt] = [(s0.toInt, wbytes w)] :=
    wranges_eq hh (fp_w (ps := []) (tySize_of_parse hty)).1 (by simp [opndVal, ho])
  have hb1 := toInt_bounds s1
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have hrel := readFrame_rel hr hrd (by omega) (by omega)
  have hlen := readFrame_length hrd
  cases w <;> xrun <;>
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_val hrel (bytesAt_length ..) ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs

theorem sound_imm (w : W) : Sound (.imm w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨i, rfl, rfl, hi⟩ := nv_imm (by cases w <;> simp [immKind]) h1
  have hty := (tyName_parse w).1
  obtain ⟨hwr, rfl⟩ := opSem_imm hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .imm i.toNat]) (d := s0.toInt)
    hh (fp_w (ps := []) (tySize_of_parse hty)).2.1 (by simp [opndVal, ho])
  have hlen : (intBytes (wbytes w) i.toNat).length = wbytes w := by
    simp [intBytes, Theorems.encodeBits_length]
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  cases w
  case' q => by_cases hf : fits i = true
  all_goals simp_all only [bne, beq_self_eq_true, Bool.not_true, Bool.false_or, ↓reduceIte,
    Bool.false_eq_true, Option.some.injEq, Prod.mk.injEq]
  all_goals
    obtain ⟨rfl, rfl⟩ := hseq
    xrun
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl)
      (bytesRel_imm ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals
    (try simp only [fits_iff] at hf)
    bv_decide

theorem sound_addr : Sound .addr := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  obtain ⟨p, hpa, hwr, rfl⟩ := opSem_addr hh ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt]) (d := s0.toInt)
    hh (fp_addr []) (by simp [opndVal, ho])
  have hpv := addrOf_rel hr hpa
  xrun
  refine post_mem hr hwr (by rw [Theorems.encodePtr_length]; rfl) (by decide) (by rw [hwr']; rfl)
    ?_ ?_ ?_ ?_ ?_ ?_ rfl
  · xobs
    exact bytesRel_ptr hpv
  all_goals xobs

theorem sound_ptrAdd : Sound .ptrAdd := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨i, rfl, rfl, hi⟩ := nv_imm (by simp) h2
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  by_cases hf : fits i = true
  case neg => simp [-fits_iff, hf] at hseq
  simp only [hf, Bool.not_true, Bool.false_eq_true, ↓reduceIte, Option.some.injEq,
    Prod.mk.injEq] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  obtain ⟨bs, q, hrd, hq, hwr, rfl⟩ := opSem_ptrAdd hh ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .imm i.toNat]) (d := s0.toInt)
    hh (fp_ptr_add []) (by simp [opndVal, ho])
  have hb1 := toInt_bounds s1
  have hqa := asPtr_rel (readFrame_rel hr hrd (by omega) (by omega)) hq
  simp only [fits_iff] at hf
  have hpv : BitVec.ofNat 64 (q.wrappingOffset (BitVec.ofNat 64 i.toNat).toInt).addr =
      BitVec.ofNat 64 (leDecode (bytesAt x.mem (fpAddr x s1.toInt) 8)) +
        BitVec.signExtend 64 (BitVec.setWidth 32 i) := by
    rw [wrappingOffset_bv, hqa, hf]
    simp
  xrun
  refine post_mem hr hwr (by rw [Theorems.encodePtr_length]; rfl) (by decide) (by rw [hwr']; rfl)
    ?_ ?_ ?_ ?_ ?_ ?_ rfl
  · refine bytesRel_ptr ?_
    rw [hpv]
    xobs
  all_goals xobs

theorem sound_ptrIndex : Sound .ptrIndex := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, o3, v0, v1, v2, v3, rfl, rfl, h0, h1, h2, h3⟩ := nvs4 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  obtain ⟨i, rfl, rfl, hi⟩ := nv_imm (by simp) h3
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  by_cases hs' : i.toNat > 0x7fffffff
  · simp [hs'] at hseq
  simp only [hs', ↓reduceIte, Option.some.injEq,
    Prod.mk.injEq] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  obtain ⟨bp, bi, q, k, hrp, hri, hq, hk, hwr, rfl⟩ := opSem_ptrIndex hh ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .slot s2.toInt, .imm i.toNat])
    (d := s0.toInt) hh (fp_ptr_index []) (by simp [opndVal, ho])
  have hb1 := toInt_bounds s1
  have hqa := asPtr_rel (readFrame_rel hr hrp (by omega) (by omega)) hq
  have hka := read_int hr (n := 8) (by omega) hri hk
  subst hka
  have hlt : i < 0x80000000#64 := by
    rw [BitVec.lt_def]; simp; omega
  have hsx : BitVec.signExtend 64 (BitVec.setWidth 32 i) = i := by bv_decide
  have hpv : BitVec.ofNat 64 (q.wrappingOffset
        ((leDecode (bytesAt x.mem (fpAddr x s2.toInt) 8) * i.toNat % 2 ^ 64 : Nat) : Int)).addr =
      BitVec.ofNat 64 (leDecode (bytesAt x.mem (fpAddr x s1.toInt) 8)) +
        BitVec.ofNat 64 (leDecode (bytesAt x.mem (fpAddr x s2.toInt) 8)) *
          BitVec.signExtend 64 (BitVec.setWidth 32 i) := by
    rw [hsx]; exact ptrIndex_addr q _ _ i hqa
  xrun
  refine post_mem hr hwr (by rw [Theorems.encodePtr_length]; rfl) (by decide) (by rw [hwr']; rfl)
    ?_ ?_ ?_ ?_ ?_ ?_ rfl
  · refine bytesRel_ptr ?_
    rw [hpv]
    xobs
    rfl
  all_goals xobs

theorem sound_mov128 : Sound .mov128 := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    List.getElem?_cons_zero, List.getElem?_cons_succ, M.frame] at hseq
  by_cases hb : s1.toInt + 8 ≥ 2 ^ 31 ∨ s0.toInt + 8 ≥ 2 ^ 31
  · simp at hseq; omega
  simp only [not_or, ge_iff_le, Int.not_le] at hb
  simp only [ge_iff_le, Int.not_le.2 hb.1, Int.not_le.2 hb.2, decide_false, Bool.or_false,
    Bool.false_eq_true, ↓reduceIte, Option.some.injEq, Prod.mk.injEq] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  have hty : Ty.parse "u128" = some (.int 16 false) := rfl
  obtain ⟨bs, hrd, hwr, rfl⟩ := opSem_mov hh hty ho hsem
  have hwr' : wranges op [.slot s0.toInt, .slot s1.toInt] = [(s0.toInt, 16)] :=
    wranges_eq hh (fp_w (ps := []) (tySize_of_parse hty)).1 (by simp [opndVal, ho])
  have hb0 := toInt_bounds s0
  have hb1 := toInt_bounds s1
  -- `d + 8` doesn't wrap.
  have h8 : ∀ d : BitVec 32, d.toInt + 8 < 2 ^ 31 → (d + 8).toInt = d.toInt + 8 := by
    intro d hd
    rw [BitVec.toInt_add_of_not_saddOverflow]
    · rfl
    · simp [BitVec.saddOverflow]; have := toInt_bounds d; omega
  have hrel := readFrame_rel hr hrd (by omega) (by omega)
  rw [show (16 : Nat) = 8 + 8 from rfl, bytesAt_add] at hrel
  have hlen := readFrame_length hrd
  xrun
  refine post_mov128 hr hwr hlen hb.2 rfl rfl hwr' ?_ ?_ ?_ ?_ ?_ ?_ rfl
  · have hfa := fpAddr_add8 x s1 hb.1
    refine bytesRel_halves hrel (bytesAt_length ..) (bytesAt_length ..) ?_ ?_
    · xobs
    · xobs
      have hfa' := hfa
      simp at hfa'
      rw [hfa']
  all_goals xobs

end Ryo.Proofs.Inline
