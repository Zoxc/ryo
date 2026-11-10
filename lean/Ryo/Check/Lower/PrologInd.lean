/-
Ryo.Check.Lower.PrologInd — the prologue's rule extended to `Indirect` inputs (aot.md §C1,
M5b), next to `PrologX.lean`'s (every input in registers).

`LowerPrologI Γ is inps lw` says that the R instructions `is` (the certificate's `prologue`
range) are `FnCx::prologue`'s (`backend/src/lower/frame.rs`) for a plan whose inputs are each
in registers or passed by address in one integer register (`ArgLoc.ptrReg`), with no stack
pieces:

- first the `arg`s, in order (`allWritesI`, as `PrologX.lean`'s `allWrites`): the sret
  pointer, then per MIR input `k` its register pieces (`InKind.regs`, as `InputOk`) or, for an
  `Indirect` input (`InKind.ind ptr idx`), `gpr idx`'s 8 bytes to its pointer slot `ptr`
  (`FuncCert.argPtrs[k]`), then a `#[track_caller]` function's caller location;
- then per `Indirect` input of non-zero size, in order (`allCopies`), `load.copy home,
  [ptr + 0], size` (`loadCopyOk`): the value copied from where the caller's pointer points
  into the local's slot (its home). The local is a private copy: nothing of the caller's
  memory is aliased (L0's in-place arguments, `ArgVal.inPlace`, are M5c's: `fn_sound`'s
  `hal`).

Every range written, the `arg`s' and the copies' destinations, is pairwise disjoint
(`allRanges`, `RngDisj`): each `arg`'s bytes survive the later writes, and each pointer slot
still holds its register when its copy reads it.

Not covered (`prologIVerdict`'s buckets): stack pieces, `byval` and pointers on the stack
(`mov`s from the incoming area, interleaved with the copies), and a spread argument
(`rust-call`: the inputs are fields of one local).
-/
import Ryo.Check.Lower.PrologX

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- A function's context for its prologue with `Indirect` inputs. -/
structure PrologICtx extends PrologXCtx where
  /-- `FuncCert.argPtrs`: per input, the slot its pointer is stored to if it is `Indirect`. -/
  argPtrs : Array (Option Int)
  /-- The mode and placement `view` reads the copies with. -/
  mode : Ryo.Obj.Mode
  ρ : Addrs

/-- The register of an `Indirect` input's pointer, as its `arg` names it. -/
def ptrArg (idx : Nat) : Asm.ArgReg := ⟨false, 8, idx, false⟩

/-- How an input is passed. -/
inductive InKind where
  /-- Its pieces in registers: (offset in the value, register). -/
  | regs (pieces : List (Nat × Asm.ArgReg))
  /-- By address in integer register `idx`, the pointer stored to slot `ptr`. -/
  | ind (ptr : Int) (idx : Nat)

/-- A MIR input's home slot and how it is passed. -/
structure InputI where
  slot : LocalSlot
  kind : InKind

/-- An input's `arg` writes. -/
def InputI.writes (inp : InputI) : List ArgWrite :=
  match inp.kind with
  | .regs ps => ps.map fun p => (inp.slot.off + p.1, p.2)
  | .ind ptr idx => [(ptr, ptrArg idx)]

/-- A `load.copy`: destination, pointer slot, size. -/
structure CopyIn where
  dst : Int
  ptr : Int
  size : Nat

/-- An input's copy: an `Indirect` input of non-zero size, into its home. -/
def InputI.copies (inp : InputI) : List CopyIn :=
  match inp.kind with
  | .regs _ => []
  | .ind ptr _ => if inp.slot.size = 0 then [] else [⟨inp.slot.off, ptr, inp.slot.size⟩]

/-- Input `k`'s rule: local `k + 1`'s slot its home, and its plan pieces all in registers
(inside the slot), or one pointer in an integer register. -/
inductive InputOkI (Γ : PrologICtx) (k : Nat) : InputI → Prop where
  | regs {slot : LocalSlot} {ps : List (Nat × Asm.ArgReg)} (ls : List ArgLoc)
      (hs : Γ.slots[k + 1]? = some slot) (hh : Γ.argHomes[k]? = some slot.off)
      (hl : Γ.plan.locs[k]? = some ls) (hp : regPieces ls = some ps)
      (hfit : ∀ p ∈ ps, p.1 + p.2.size ≤ slot.size) : InputOkI Γ k ⟨slot, .regs ps⟩
  | ind {slot : LocalSlot} {ptr : Int} {idx : Nat}
      (hs : Γ.slots[k + 1]? = some slot) (hh : Γ.argHomes[k]? = some slot.off)
      (hl : Γ.plan.locs[k]? = some [.ptrReg idx]) : InputOkI Γ k ⟨slot, .ind ptr idx⟩

theorem InputOkI.slot_eq {Γ : PrologICtx} {k : Nat} {inp : InputI} (h : InputOkI Γ k inp) :
    Γ.slots[k + 1]? = some inp.slot := by
  cases h with
  | regs _ hs => exact hs
  | ind hs => exact hs

/-- The inputs from `k` on. -/
inductive InputsOkI (Γ : PrologICtx) : Nat → List InputI → Prop where
  | nil (k : Nat) : InputsOkI Γ k []
  | cons {k : Nat} {inp : InputI} {inps : List InputI} :
      InputOkI Γ k inp → InputsOkI Γ (k + 1) inps → InputsOkI Γ k (inp :: inps)

/-- Every `arg`, in the prologue's order. -/
def allWritesI (Γ : PrologICtx) (inps : List InputI) (lw : List ArgWrite) : List ArgWrite :=
  sretWrites Γ.toPrologXCtx ++ inps.flatMap InputI.writes ++ lw

/-- Every copy, in order. -/
def allCopies (inps : List InputI) : List CopyIn := inps.flatMap InputI.copies

/-- A write's byte range. -/
def ArgWrite.rng (w : ArgWrite) : Int × Nat := (w.1, w.2.size)

/-- A copy's destination range. -/
def CopyIn.rng (c : CopyIn) : Int × Nat := (c.dst, c.size)

/-- Every range the prologue writes. -/
def allRanges (Γ : PrologICtx) (inps : List InputI) (lw : List ArgWrite) : List (Int × Nat) :=
  (allWritesI Γ inps lw).map ArgWrite.rng ++ (allCopies inps).map CopyIn.rng

/-- Two byte ranges are disjoint. -/
def RngDisj (a b : Int × Nat) : Prop := a.1 + (a.2 : Int) ≤ b.1 ∨ b.1 + (b.2 : Int) ≤ a.1

instance (a b : Int × Nat) : Decidable (RngDisj a b) := by
  unfold RngDisj; infer_instance

/-- An instruction whose view is `load.copy cp.dst, [cp.ptr + 0], cp.size`, falling through,
its operands in range. -/
def loadCopyOk (mode : Ryo.Obj.Mode) (ρ : Addrs) (i : Insn) (cp : CopyIn) : Bool :=
  match view mode ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, _, _⟩ =>
      kd == .load_copy &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"m", .mem⟩, ⟨"len", .u32⟩] &&
        v.ops == [.slot cp.dst, .mem cp.ptr 0, .imm cp.size] && v.ctl == some .next &&
        offOk cp.dst && offOk cp.ptr && decide (cp.size < 2 ^ 32)
    | none => false
  | none => false

theorem loadCopyOk_spec {mode : Ryo.Obj.Mode} {ρ : Addrs} {i : Insn} {cp : CopyIn}
    (h : loadCopyOk mode ρ i cp = true) :
    ∃ v ps r, view mode ρ i = some v ∧ v.op.handler? = some ⟨.load_copy, ps, r⟩ ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"m", .mem⟩, ⟨"len", .u32⟩] ∧
      v.ops = [.slot cp.dst, .mem cp.ptr 0, .imm cp.size] ∧ v.ctl = some .next ∧
      offOk cp.dst = true ∧ offOk cp.ptr = true ∧ cp.size < 2 ^ 32 := by
  unfold loadCopyOk at h
  split at h
  next v hv =>
    split at h
    next kd ps r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
      obtain ⟨⟨⟨⟨⟨⟨hkd, ho⟩, hops⟩, hctl⟩, h1⟩, h2⟩, h3⟩ := h
      subst hkd
      exact ⟨v, ps, r, hv, hh, ho, hops, hctl, h1, h2, h3⟩
    · cases h
  · cases h

/-- Each instruction the `load.copy` of the matching copy, in order. -/
inductive CopiesAre (mode : Ryo.Obj.Mode) (ρ : Addrs) : List Insn → List CopyIn → Prop where
  | nil : CopiesAre mode ρ [] []
  | cons {i : Insn} {is : List Insn} {cp : CopyIn} {cs : List CopyIn} :
      loadCopyOk mode ρ i cp = true → CopiesAre mode ρ is cs → CopiesAre mode ρ (i :: is) (cp :: cs)

structure LowerPrologI (Γ : PrologICtx) (is : List Insn) (inps : List InputI)
    (lw : List ArgWrite) : Prop where
  spread : Γ.spread = false
  len : inps.length = nInputs Γ.toPrologXCtx
  inputs : InputsOkI Γ 0 inps
  loc : locWrites Γ.toPrologXCtx inps.length = some lw
  args : ArgsAre (is.take (allWritesI Γ inps lw).length) (allWritesI Γ inps lw)
  copies : CopiesAre Γ.mode Γ.ρ (is.drop (allWritesI Γ inps lw).length) (allCopies inps)
  disj : (allRanges Γ inps lw).Pairwise RngDisj

/-! ### The checker -/

/-- Input `k`'s checker. -/
def checkInputI (Γ : PrologICtx) (k : Nat) : Option InputI :=
  match Γ.slots[k + 1]?, Γ.argHomes[k]?, Γ.plan.locs[k]? with
  | some slot, some h, some ls =>
    if h == slot.off then
      match ls with
      | [.ptrReg idx] =>
        match Γ.argPtrs[k]? with
        | some (some p) => some ⟨slot, .ind p idx⟩
        | _ => none
      | _ =>
        match regPieces ls with
        | some ps =>
          if ps.all (fun p => decide (p.1 + p.2.size ≤ slot.size)) then some ⟨slot, .regs ps⟩
          else none
        | none => none
    else none
  | _, _, _ => none

theorem checkInputI_sound {Γ : PrologICtx} {k : Nat} {inp : InputI}
    (h : checkInputI Γ k = some inp) : InputOkI Γ k inp := by
  unfold checkInputI at h
  split at h
  next slot hm ls h1 h2 h3 =>
    split at h
    next hc =>
      have hh : Γ.argHomes[k]? = some slot.off := by
        rw [h2]; simp only [beq_iff_eq] at hc; rw [hc]
      split at h
      next idx =>
        split at h
        next p _ =>
          simp only [Option.some.injEq] at h
          subst h
          exact .ind h1 hh h3
        next => cases h
      next =>
        split at h
        next ps hps =>
          split at h
          next hall =>
            simp only [Option.some.injEq] at h
            subst h
            simp only [List.all_eq_true, decide_eq_true_eq] at hall
            exact .regs ls h1 hh h3 hps hall
          next => cases h
        next => cases h
    next => cases h
  next => cases h

/-- The inputs from `k` on, `n` of them. -/
def checkInputsI (Γ : PrologICtx) : Nat → Nat → Option (List InputI)
  | _, 0 => some []
  | k, n + 1 =>
    match checkInputI Γ k, checkInputsI Γ (k + 1) n with
    | some p, some ps => some (p :: ps)
    | _, _ => none

theorem checkInputsI_sound {Γ : PrologICtx} :
    ∀ {k n : Nat} {inps : List InputI}, checkInputsI Γ k n = some inps →
      inps.length = n ∧ InputsOkI Γ k inps
  | k, 0, inps, h => by
    simp only [checkInputsI, Option.some.injEq] at h
    subst h
    exact ⟨rfl, .nil k⟩
  | k, n + 1, inps, h => by
    unfold checkInputsI at h
    split at h
    next p ps h1 h2 =>
      simp only [Option.some.injEq] at h
      subst h
      obtain ⟨hl, hok⟩ := checkInputsI_sound h2
      exact ⟨by simp only [List.length_cons, hl], .cons (checkInputI_sound h1) hok⟩
    next => cases h

/-- Each instruction the `load.copy` of the matching copy. -/
def copiesMatch (mode : Ryo.Obj.Mode) (ρ : Addrs) : List Insn → List CopyIn → Bool
  | [], [] => true
  | i :: is, cp :: cs => loadCopyOk mode ρ i cp && copiesMatch mode ρ is cs
  | _, _ => false

theorem copiesMatch_sound {mode : Ryo.Obj.Mode} {ρ : Addrs} :
    ∀ {is : List Insn} {cs : List CopyIn}, copiesMatch mode ρ is cs = true →
      CopiesAre mode ρ is cs
  | [], [], _ => .nil
  | i :: is, cp :: cs, h => by
    simp only [copiesMatch, Bool.and_eq_true] at h
    exact .cons h.1 (copiesMatch_sound h.2)
  | [], _ :: _, h => by first | (simp [copiesMatch] at h; done) | cases h
  | _ :: _, [], h => by first | (simp [copiesMatch] at h; done) | cases h

def rngsDisjoint : List (Int × Nat) → Bool
  | [] => true
  | r :: rs => rs.all (fun v => decide (RngDisj r v)) && rngsDisjoint rs

theorem rngsDisjoint_sound :
    ∀ {rs : List (Int × Nat)}, rngsDisjoint rs = true → rs.Pairwise RngDisj
  | [], _ => List.Pairwise.nil
  | r :: rs, h => by
    simp only [rngsDisjoint, Bool.and_eq_true] at h
    exact List.pairwise_cons.mpr
      ⟨fun v hv => of_decide_eq_true (List.all_eq_true.mp h.1 v hv), rngsDisjoint_sound h.2⟩

/-- The prologue's checker: the inputs and the caller location's write when the rule covers it. -/
def checkPrologI (Γ : PrologICtx) (is : List Insn) : Option (List InputI × List ArgWrite) :=
  if Γ.spread then none
  else
    match checkInputsI Γ 0 (nInputs Γ.toPrologXCtx) with
    | some inps =>
      match locWrites Γ.toPrologXCtx inps.length with
      | some lw =>
        if argsMatch (is.take (allWritesI Γ inps lw).length) (allWritesI Γ inps lw) &&
            copiesMatch Γ.mode Γ.ρ (is.drop (allWritesI Γ inps lw).length) (allCopies inps) &&
            rngsDisjoint (allRanges Γ inps lw) then
          some (inps, lw)
        else none
      | none => none
    | none => none

theorem checkPrologI_sound {Γ : PrologICtx} {is : List Insn} {inps : List InputI}
    {lw : List ArgWrite} (h : checkPrologI Γ is = some (inps, lw)) : LowerPrologI Γ is inps lw := by
  unfold checkPrologI at h
  split at h
  next => cases h
  next hsp =>
    split at h
    next inps' hc =>
      split at h
      next lw' hl =>
        split at h
        next hm =>
          simp only [Option.some.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          simp only [Bool.and_eq_true] at hm
          obtain ⟨⟨h1, h2⟩, h3⟩ := hm
          obtain ⟨hlen, hin⟩ := checkInputsI_sound hc
          exact ⟨by simpa using hsp, hlen, hin, hl, argsMatch_sound h1, copiesMatch_sound h2,
            rngsDisjoint_sound h3⟩
        next => cases h
      next => cases h
    next => cases h

/-- Why the plan has a piece the rule doesn't cover, if it does. -/
def prologIWhy (Γ : PrologICtx) : Option String :=
  if Γ.spread then some "prologue: spread argument"
  else if Γ.plan.locs.any (fun ls => ls.any fun l =>
      l.isStack || (match l with | .ptrStack _ => true | _ => false)) then
    some "prologue: stack input"
  else none

/-- The prologue's verdict, for coverage: `PrologX.lean`'s rule is the case without
`Indirect` inputs, so this replaces `prologXVerdict`. -/
def prologIVerdict (Γ : PrologICtx) (is : List Insn) : Verdict :=
  match checkPrologI Γ is with
  | some _ => .ok
  | none => .unsupported ((prologIWhy Γ).getD "prologue: form")

theorem prologIVerdict_sound {Γ : PrologICtx} {is : List Insn} (h : prologIVerdict Γ is = .ok) :
    ∃ inps lw, LowerPrologI Γ is inps lw := by
  unfold prologIVerdict at h
  split at h
  next r hr => exact ⟨r.1, r.2, checkPrologI_sound hr⟩
  next => cases h

end Ryo.Check.Lower
