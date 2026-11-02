/-
Ryo.Proofs.PassArgs — facts about the register words of call argument lists: the SysV
C-variadic `al` entry `passArgs` appends (`raxWord`), which `ArgReg.of?` accepts only in call
lists (`exact = false`), and where `of?` allows a sign-extending load.
-/
import Ryo.Check.Lower.CertCheck
import Ryo.Proofs.Call

namespace Ryo.Proofs.PassArgs

open Ryo.Vm.Asm Ryo.Proofs.Call

/-- The `al` entry `passArgs` appends on SysV is `raxWord`. -/
theorem raxWord_eq : raxWord = (ArgReg.mk false 1 argRax false).word := rfl

/-- `raxWord`'s value: one byte, integer index 6 (`0x601`). -/
theorem raxWord_val : raxWord = 0x601 := by rfl

/-- In a call's argument list `raxWord` decodes to the one-byte, zero-extended `rax`. -/
theorem of?_raxWord_call : ArgReg.of? raxWord false = some ⟨false, 1, argRax, false⟩ := by
  rfl

/-- Outside call argument lists (`exact`: an `arg`'s register) `raxWord` is rejected. -/
theorem of?_raxWord_exact : ArgReg.of? raxWord true = none := by
  rfl

/-- `ArgReg.of?` accepts `sext` only in call argument lists, for 1- or 2-byte integers. -/
theorem ArgReg.of?_sext {r : Nat} {exact : Bool} {a : ArgReg}
    (h : ArgReg.of? r exact = some a) (hs : a.sext = true) :
    exact = false ∧ a.xmm = false ∧ (a.size = 1 ∨ a.size = 2) := by
  unfold ArgReg.of? at h
  simp only [Option.ite_none_right_eq_some, Option.some.injEq] at h
  obtain ⟨hok, rfl⟩ := h
  simp only at hs ⊢
  revert hok hs
  cases exact <;> cases r &&& 0x20 != 0 <;> cases r &&& argSext != 0 <;> intro hok hs <;>
    simp_all

/-- A decoded register with `sext` is not `rax`'s word (the `al` load is zero-extended). -/
theorem ArgReg.of?_sext_word_ne {r : Nat} {exact : Bool} {a : ArgReg}
    (h : ArgReg.of? r exact = some a) (hs : a.sext = true) : r ≠ raxWord := by
  intro hr
  subst hr
  cases exact
  · rw [of?_raxWord_call] at h
    cases h
    cases hs
  · rw [of?_raxWord_exact] at h
    cases h

end Ryo.Proofs.PassArgs
