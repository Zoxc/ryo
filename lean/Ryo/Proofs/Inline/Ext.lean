/-
Ryo.Proofs.Inline.Ext — the integer extensions and truncations (`cvt` between integer types,
class `ext src dst sx`) against `opSem`: a zero- or sign-extending load of the source, through
`shl`/`sar` for a sign extension to 64 bits, and a store of the destination's width.

In the module chain after `Cmp` (see `Ryo/Proofs/Inline/Arith.lean`).
-/
import Ryo.Proofs.Inline.Cmp

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm

theorem ofInt_ext {n : Nat} (sx : Bool) (m : Nat) (a : BitVec m) :
    BitVec.ofInt n (if sx then a.toInt else (a.toNat : Int)) =
      if sx then a.signExtend n else a.setWidth n := by
  cases sx
  · simp only [Bool.false_eq_true, ↓reduceIte, BitVec.ofInt_natCast]
    apply BitVec.eq_of_toNat_eq; simp
  · rfl

theorem ofNat_trunc (k m : Nat) {L : Nat} (h : k ≤ m := by decide) :
    BitVec.ofNat k L = (BitVec.ofNat m L).setWidth k := by
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, BitVec.toNat_setWidth]
  exact (Nat.mod_mod_of_dvd _ (Nat.pow_dvd_pow 2 h)).symm

theorem sound_ext (src dst : W) (sx : Bool) : Sound (.ext src dst sx) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  have htx : Ty.parse (tyName sx src) = some (.int (wbytes src) sx) := by
    cases sx
    · exact (tyName_parse src).1
    · exact (tyName_parse src).2
  have hty : Ty.parse (tyName sx dst) = some (.int (wbytes dst) sx) := by
    cases sx
    · exact (tyName_parse dst).1
    · exact (tyName_parse dst).2
  obtain ⟨bs, va, hra, hva, hwr, rfl⟩ := opSem_ext hh htx hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt]) (d := s0.toInt)
    hh (fp_cvt (tySize_of_parse htx) (tySize_of_parse hty)) (by simp [opndVal, ho])
  have hn : wbytes src ≤ 8 := by cases src <;> decide
  have ha := read_int hr (by omega) hra hva
  subst ha
  have hlen : ∀ v, (intBytes (wbytes dst) v).length = wbytes dst := by
    intro v; simp [intBytes, Theorems.encodeBits_length]
  have hvx : ((BitVec.ofNat (8 * wbytes src) (leDecode (bytesAt x.mem (fpAddr x s1.toInt)
      (wbytes src)))).toNat : Int) = (leDecode (bytesAt x.mem (fpAddr x s1.toInt) (wbytes src)) : Int) := by
    rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt]
    have := Theorems.leDecode_lt (bytesAt x.mem (fpAddr x s1.toInt) (wbytes src))
    rw [bytesAt_length] at this
    exact this
  rw [← hvx, ofInt_ext] at hwr
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  cases sx <;> cases src <;> cases dst
  all_goals
    try simp (config := { decide := true }) only [↓reduceIte, List.cons_append, List.nil_append]
    xrun
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals first
    | with_reducible rfl
    | bv_decide
    | (rw [ofNat_trunc 8 32]; bv_decide)
    | (rw [ofNat_trunc 16 32]; bv_decide)
    | (rw [ofNat_trunc 8 64]; bv_decide)
    | (rw [ofNat_trunc 16 64]; bv_decide)
    | (rw [ofNat_trunc 32 64]; bv_decide)

end Ryo.Proofs.Inline
