/-
Ryo.Check.Lower.TermExt — the terminator rules of all families (aot.md §C1, M5b): `LowerTermX`
is `Term.lean`'s `LowerTerm`, `Switch.lean`'s `LowerSwitch` (a `SwitchInt` with one or more
cases) or `RetX.lean`'s `LowerRetX` (every register return), and `checkTermX` decides it,
trying `checkRetX` on a `return` first, then `checkTerm` and `checkSwitch`
(`checkTermX_sound`).
-/
import Ryo.Check.Lower.Switch
import Ryo.Check.Lower.RetX

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerTermX (Γ : TermCtx) (next : Nat) (term : Terminator) (is : List Insn) :
    Prop where
  | base (h : LowerTerm Γ next term is)
  | switch (h : LowerSwitch Γ next term is)
  | retX (h : LowerRetX Γ term is)

theorem LowerRetX.term_eq {Γ : TermCtx} {term : Terminator} {is : List Insn}
    (h : LowerRetX Γ term is) : term = .«return» := by
  cases h <;> rfl

theorem LowerRetX.single {Γ : TermCtx} {term : Terminator} {is : List Insn}
    (h : LowerRetX Γ term is) : ∃ i, is = [i] := by
  cases h <;> exact ⟨_, rfl⟩

/-- `checkTerm`, then `checkSwitch`. -/
def checkTermB (Γ : TermCtx) (next : Nat) (term : Terminator) (is : List Insn) : Verdict :=
  match checkTerm Γ next term is with
  | .ok => .ok
  | v => (checkSwitch Γ next term is).getD v

/-- `checkRetX` first (its reason kept when neither accepts a `return`), then `checkTermB`. -/
def checkTermX (Γ : TermCtx) (next : Nat) (term : Terminator) (is : List Insn) : Verdict :=
  match checkRetX Γ term is with
  | some v =>
    if v = .ok then .ok else if checkTermB Γ next term is = .ok then .ok else v
  | none => checkTermB Γ next term is

theorem checkTermB_sound {Γ : TermCtx} {next : Nat} {term : Terminator} {is : List Insn}
    (h : checkTermB Γ next term is = .ok) : LowerTermX Γ next term is := by
  unfold checkTermB at h
  split at h
  next hb => exact .base (checkTerm_sound hb)
  next hne =>
    cases hf : checkSwitch Γ next term is with
    | none => rw [hf] at h; simp only [Option.getD] at h; exact absurd h hne
    | some v =>
      rw [hf] at h
      simp only [Option.getD] at h
      subst h
      exact .switch (checkSwitch_sound hf)

theorem checkTermX_sound {Γ : TermCtx} {next : Nat} {term : Terminator} {is : List Insn}
    (h : checkTermX Γ next term is = .ok) : LowerTermX Γ next term is := by
  unfold checkTermX at h
  cases hr : checkRetX Γ term is with
  | none => rw [hr] at h; exact checkTermB_sound h
  | some v =>
    rw [hr] at h
    dsimp only at h
    by_cases hv : v = .ok
    · subst hv; exact .retX (checkRetX_sound hr)
    · rw [if_neg hv] at h
      by_cases hb : checkTermB Γ next term is = .ok
      · exact checkTermB_sound hb
      · rw [if_neg hb] at h; exact absurd h hv

/-- `checkBlockTerm` with the switch family: a block's terminator range against its terminator,
for the coverage report. -/
def checkBlockTermX (Γ : TermCtx) (b : BlockCert) (term : Terminator) (insns : Array Insn) :
    Verdict :=
  if b.fused then .unsupported "terminator: fused compare"
  else if b.dead then .unsupported "terminator: dead block"
  else checkTermX Γ b.term.2 term (insns.extract b.term.1 b.term.2).toList

theorem checkBlockTermX_sound {Γ : TermCtx} {b : BlockCert} {term : Terminator}
    {insns : Array Insn} (h : checkBlockTermX Γ b term insns = .ok) :
    b.fused = false ∧ b.dead = false ∧
      LowerTermX Γ b.term.2 term (insns.extract b.term.1 b.term.2).toList := by
  unfold checkBlockTermX at h
  cases hf : b.fused <;> simp only [hf, if_true, if_false, Bool.false_eq_true] at h
  · cases hd : b.dead <;> simp only [hd, if_true, if_false, Bool.false_eq_true] at h
    · exact ⟨rfl, rfl, checkTermX_sound h⟩
    · cases h
  · cases h

end Ryo.Check.Lower
