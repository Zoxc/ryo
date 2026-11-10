/-
Ryo.Check.Lower.PrologSpread — the prologue's rule for a function with a spread argument
(`rust-call`, aot.md §C1, M5b), next to `PrologInd.lean`'s.

The callee's MIR has its last argument local `sp` (`FuncCert.spreadArg`, `sp = n + 1` for `n`
fixed inputs) a tuple whose fields are the ABI's last inputs: input `n + j` is field `j`, its
home `FuncCert.argHomes[n + j]` the spread local's slot plus the field's offset
(`frame.rs`, `Frame::new`). The prologue is `PrologInd.lean`'s, over the fixed inputs and then
the fields (`fixed ++ fields`), each field an `InputI` whose `slot` is its home range inside the
spread local's slot (`FieldOk`: the field's offset and size from the tuple type,
`PrologSCtx.spreadFields`, and its pieces in registers or one pointer).

`LowerPrologS Γ is fixed fields lw sl`: the fixed inputs as `InputsOkI`, the spread local's slot
`sl` (`Γ.slots[n + 1]`), the fields as `FieldsOk`, and `LowerPrologI`'s instruction and range
facts over `fixed ++ fields`.
-/
import Ryo.Check.Lower.PrologInd
import Ryo.Check.Lower.PrologStack

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- A function's context for a prologue with a spread argument. -/
structure PrologSCtx extends PrologICtx where
  /-- The spread local's tuple fields: (offset, size), in order. -/
  spreadFields : List (Nat × Nat)

/-- Input `k`'s passing, its pieces inside a home of `size` bytes (`InputOkI`'s kinds). -/
def KindOk (Γ : PrologICtx) (k : Nat) (size : Nat) : InKind → Prop
  | .regs ps => ∃ ls, Γ.plan.locs[k]? = some ls ∧ regPieces ls = some ps ∧
      ∀ p ∈ ps, p.1 + p.2.size ≤ size
  | .ind _ idx => Γ.plan.locs[k]? = some [.ptrReg idx]

/-- Input `k` is the spread field at `fo = (offset, size)` of the spread local's slot `sl`. -/
structure FieldOk (Γ : PrologICtx) (sl : LocalSlot) (k : Nat) (fo : Nat × Nat) (inp : InputI) :
    Prop where
  off : inp.slot.off = sl.off + fo.1
  size : inp.slot.size = fo.2
  inside : fo.1 + fo.2 ≤ sl.size
  home : Γ.argHomes[k]? = some inp.slot.off
  kind : KindOk Γ k fo.2 inp.kind

/-- The spread fields from input `k` on. -/
inductive FieldsOk (Γ : PrologICtx) (sl : LocalSlot) : Nat → List (Nat × Nat) → List InputI → Prop
  where
  | nil (k : Nat) : FieldsOk Γ sl k [] []
  | cons {k : Nat} {fo : Nat × Nat} {fos : List (Nat × Nat)} {inp : InputI} {inps : List InputI} :
      FieldOk Γ sl k fo inp → FieldsOk Γ sl (k + 1) fos inps →
        FieldsOk Γ sl k (fo :: fos) (inp :: inps)

structure LowerPrologS (Γ : PrologSCtx) (is : List Insn) (fixed fields : List InputI)
    (lw : List ArgWrite) (sl : LocalSlot) : Prop where
  spread : Γ.spread = true
  len : fixed.length + fields.length = nInputs Γ.toPrologXCtx
  fixedOk : InputsOkI Γ.toPrologICtx 0 fixed
  slot : Γ.slots[fixed.length + 1]? = some sl
  fieldsOk : FieldsOk Γ.toPrologICtx sl fixed.length Γ.spreadFields fields
  loc : locWrites Γ.toPrologXCtx (fixed.length + fields.length) = some lw
  args : ArgsAre (is.take (allWritesI Γ.toPrologICtx (fixed ++ fields) lw).length)
    (allWritesI Γ.toPrologICtx (fixed ++ fields) lw)
  copies : CopiesAre Γ.mode Γ.ρ (is.drop (allWritesI Γ.toPrologICtx (fixed ++ fields) lw).length)
    (allCopies (fixed ++ fields))
  disj : (allRanges Γ.toPrologICtx (fixed ++ fields) lw).Pairwise RngDisj

/-! ### The checker -/

/-- Input `k`'s passing into a home `slot` (`checkInputI`'s kinds). -/
def checkKind (Γ : PrologICtx) (k : Nat) (slot : LocalSlot) : Option InKind :=
  match Γ.plan.locs[k]? with
  | some ls =>
    match ls with
    | [.ptrReg idx] =>
      match Γ.argPtrs[k]? with
      | some (some p) => some (.ind p idx)
      | _ => none
    | _ =>
      match regPieces ls with
      | some ps =>
        if ps.all (fun p => decide (p.1 + p.2.size ≤ slot.size)) then some (.regs ps) else none
      | none => none
  | none => none

theorem checkKind_sound {Γ : PrologICtx} {k : Nat} {slot : LocalSlot} {kd : InKind}
    (h : checkKind Γ k slot = some kd) : KindOk Γ k slot.size kd := by
  unfold checkKind at h
  cases hl : Γ.plan.locs[k]? with
  | none => rw [hl] at h; cases h
  | some ls =>
    rw [hl] at h
    dsimp only at h
    split at h
    next idx =>
      split at h
      next p _ =>
        simp only [Option.some.injEq] at h
        subst h
        exact hl
      next => cases h
    next =>
      split at h
      next ps hps =>
        split at h
        next hall =>
          simp only [Option.some.injEq] at h
          subst h
          simp only [List.all_eq_true, decide_eq_true_eq] at hall
          exact ⟨ls, hl, hps, hall⟩
        next => cases h
      next => cases h

/-- The spread fields from input `k` on. -/
def checkFields (Γ : PrologICtx) (sl : LocalSlot) : Nat → List (Nat × Nat) → Option (List InputI)
  | _, [] => some []
  | k, fo :: fos =>
    let slot : LocalSlot := ⟨sl.off + fo.1, fo.2⟩
    if Γ.argHomes[k]? == some slot.off && decide (fo.1 + fo.2 ≤ sl.size) then
      match checkKind Γ k slot, checkFields Γ sl (k + 1) fos with
      | some kd, some inps => some (⟨slot, kd⟩ :: inps)
      | _, _ => none
    else none

theorem checkFields_sound {Γ : PrologICtx} {sl : LocalSlot} :
    ∀ {k : Nat} {fos : List (Nat × Nat)} {inps : List InputI}, checkFields Γ sl k fos = some inps →
      FieldsOk Γ sl k fos inps
  | k, [], inps, h => by
    simp only [checkFields, Option.some.injEq] at h
    subst h
    exact .nil k
  | k, fo :: fos, inps, h => by
    unfold checkFields at h
    simp only at h
    split at h
    next hc =>
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at hc
      split at h
      next kd tl h1 h2 =>
        simp only [Option.some.injEq] at h
        subst h
        exact .cons ⟨rfl, rfl, hc.2, hc.1, checkKind_sound h1⟩ (checkFields_sound h2)
      next => cases h
    next => cases h

/-- The prologue's checker for a spread argument: the fixed inputs, the fields, and the caller
location's write. -/
def checkPrologS (Γ : PrologSCtx) (is : List Insn) :
    Option (List InputI × List InputI × List ArgWrite × LocalSlot) :=
  if !Γ.spread then none
  else
    let nf := nInputs Γ.toPrologXCtx - Γ.spreadFields.length
    match checkInputsI Γ.toPrologICtx 0 nf, Γ.slots[nf + 1]? with
    | some fixed, some sl =>
      match checkFields Γ.toPrologICtx sl fixed.length Γ.spreadFields with
      | some fields =>
        match locWrites Γ.toPrologXCtx (fixed.length + fields.length) with
        | some lw =>
          if fixed.length = nf ∧ fixed.length + fields.length = nInputs Γ.toPrologXCtx ∧
              argsMatch (is.take (allWritesI Γ.toPrologICtx (fixed ++ fields) lw).length)
                (allWritesI Γ.toPrologICtx (fixed ++ fields) lw) = true ∧
              copiesMatch Γ.mode Γ.ρ
                (is.drop (allWritesI Γ.toPrologICtx (fixed ++ fields) lw).length)
                (allCopies (fixed ++ fields)) = true ∧
              rngsDisjoint (allRanges Γ.toPrologICtx (fixed ++ fields) lw) = true then
            some (fixed, fields, lw, sl)
          else none
        | none => none
      | none => none
    | _, _ => none

theorem checkPrologS_sound {Γ : PrologSCtx} {is : List Insn} {fixed fields : List InputI}
    {lw : List ArgWrite} {sl : LocalSlot} (h : checkPrologS Γ is = some (fixed, fields, lw, sl)) :
    LowerPrologS Γ is fixed fields lw sl := by
  unfold checkPrologS at h
  split at h
  next => cases h
  next hsp =>
    simp only at h
    split at h
    next fx sl' hc hsl =>
      split at h
      next fl hf =>
        split at h
        next lw' hl =>
          split at h
          next hm =>
            simp only [Option.some.injEq, Prod.mk.injEq] at h
            obtain ⟨rfl, rfl, rfl, rfl⟩ := h
            obtain ⟨hnf, hlen, h1, h2, h3⟩ := hm
            obtain ⟨-, hin⟩ := checkInputsI_sound hc
            refine ⟨by simpa using hsp, hlen, hin, by rw [hnf]; exact hsl,
              checkFields_sound hf, hl, argsMatch_sound h1, copiesMatch_sound h2,
              rngsDisjoint_sound h3⟩
          next => cases h
        next => cases h
      next => cases h
    next => cases h

/-- The prologue's verdict with a spread argument (`prologTVerdict` otherwise: `PrologInd.lean`'s
rule, else `PrologStack.lean`'s). -/
def prologSVerdict (Γ : PrologSCtx) (is : List Insn) : Verdict :=
  if Γ.spread then
    match checkPrologS Γ is with
    | some _ => .ok
    | none => .unsupported "prologue: spread argument"
  else prologTVerdict Γ.toPrologICtx is

theorem prologSVerdict_sound {Γ : PrologSCtx} {is : List Insn} (h : prologSVerdict Γ is = .ok) :
    (∃ fixed fields lw sl, LowerPrologS Γ is fixed fields lw sl) ∨
      (∃ inps lw, LowerPrologI Γ.toPrologICtx is inps lw) ∨
      ∃ inps lw, LowerPrologT Γ.toPrologICtx is inps lw := by
  unfold prologSVerdict at h
  split at h
  next =>
    split at h
    next r hr => exact .inl ⟨r.1, r.2.1, r.2.2.1, r.2.2.2, checkPrologS_sound hr⟩
    next => cases h
  next => exact .inr (prologTVerdict_sound h)

end Ryo.Check.Lower
