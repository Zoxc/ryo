/-
Ryo.Check.Lower.Prolog — the relational spec of the prologue's argument stores and its checker
(aot.md §C1 `LowerProlog`, M5a), first rule.

`LowerProlog Γ is ps` says that the R instructions `is` (the certificate's `prologue` range)
store the function's ABI inputs into their locals' home slots, `ps` giving per input its slot
and argument register. Covered so far: every input is a single integer register piece
(`[.reg a 0]`, not `xmm`) of its local's whole size, lowered to one `arg` instruction
(`FnCx::prologue`) writing the register's low `a.size` bytes to the home slot
(`FuncCert.argHomes[k]`, the slot of local `k + 1`), which no `Escape` covers; the home slots
are pairwise disjoint. Stack pieces, `Indirect` inputs, spread arguments and `xmm` pieces are
not covered (`checkProlog` answers `none`).
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- A function's context for its prologue. -/
structure PrologCtx where
  slots : Array LocalSlot
  argHomes : Array Int
  plan : ArgPlan
  /-- Frame offsets some `Escape` scope of the function covers. -/
  escaped : Int → Bool

/-- A native `arg d, r`'s destination slot and register. -/
def argOps : Insn → Option (Int × Asm.ArgReg)
  | .native op [.slot d, .imm w] =>
    match op.full with
    | some f =>
      if f.info.shape == .arg then
        match Asm.ArgReg.of? w.toNat true with
        | some a => some (d.toInt, a)
        | none => none
      else none
    | none => none
  | _ => none

theorem argOps_spec {i : Insn} {off : Int} {a : Asm.ArgReg} (h : argOps i = some (off, a)) :
    ∃ op f d w, i = .native op [.slot d, .imm w] ∧ op.full = some f ∧ f.info.shape = .arg ∧
      d.toInt = off ∧ Asm.ArgReg.of? w.toNat true = some a := by
  unfold argOps at h
  split at h
  next op d w =>
    split at h
    next f hf =>
      split at h
      next hs =>
        split at h
        next a' ha =>
          simp only [Option.some.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          exact ⟨op, f, d, w, rfl, hf, by simpa using hs, rfl, ha⟩
        next => cases h
      next => cases h
    next => cases h
  next => cases h

/-- Input `k`'s rule: one integer register piece `a`, local `k + 1`'s slot `slot` its home, of
`a`'s size, private, and the instruction `arg slot, a`. -/
abbrev ArgOk (Γ : PrologCtx) (k : Nat) (i : Insn) (slot : LocalSlot) (a : Asm.ArgReg) : Prop :=
  Γ.plan.locs[k]? = some [.reg a 0] ∧ a.xmm = false ∧ Γ.slots[k + 1]? = some slot ∧
    slot.size = a.size ∧ Γ.argHomes[k]? = some slot.off ∧
    (∀ j < slot.size, Γ.escaped (slot.off + j) = false) ∧ argOps i = some (slot.off, a)

/-- The inputs from `k` on, one instruction each. -/
inductive ArgsOk (Γ : PrologCtx) : Nat → List Insn → List (LocalSlot × Asm.ArgReg) → Prop where
  | nil (k : Nat) : ArgsOk Γ k [] []
  | cons {k : Nat} {i : Insn} {is : List Insn} {p : LocalSlot × Asm.ArgReg}
      {ps : List (LocalSlot × Asm.ArgReg)} :
      ArgOk Γ k i p.1 p.2 → ArgsOk Γ (k + 1) is ps → ArgsOk Γ k (i :: is) (p :: ps)

/-- Two inputs' home slots are disjoint. -/
def SlotDisj (p q : LocalSlot × Asm.ArgReg) : Prop :=
  p.1.off + (p.1.size : Int) ≤ q.1.off ∨ q.1.off + (q.1.size : Int) ≤ p.1.off

instance (p q : LocalSlot × Asm.ArgReg) : Decidable (SlotDisj p q) := by
  unfold SlotDisj; infer_instance

structure LowerProlog (Γ : PrologCtx) (is : List Insn) (ps : List (LocalSlot × Asm.ArgReg)) :
    Prop where
  len : is.length = Γ.plan.locs.length
  args : ArgsOk Γ 0 is ps
  disj : ps.Pairwise SlotDisj

/-- Input `k`'s checker. -/
def checkArg (Γ : PrologCtx) (k : Nat) (i : Insn) : Option (LocalSlot × Asm.ArgReg) :=
  match Γ.plan.locs[k]?, Γ.slots[k + 1]? with
  | some [.reg a 0], some slot =>
    if decide (a.xmm = false ∧ slot.size = a.size ∧ Γ.argHomes[k]? = some slot.off ∧
        argOps i = some (slot.off, a)) &&
        (List.range slot.size).all (fun j => !Γ.escaped (slot.off + j)) then
      some (slot, a)
    else none
  | _, _ => none

theorem checkArg_sound {Γ : PrologCtx} {k : Nat} {i : Insn} {p : LocalSlot × Asm.ArgReg}
    (h : checkArg Γ k i = some p) : ArgOk Γ k i p.1 p.2 := by
  unfold checkArg at h
  split at h
  next a slot h1 h2 =>
    split at h
    next hc =>
      simp only [Option.some.injEq] at h
      subst h
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hc
      obtain ⟨⟨hx, hs, hh, ho⟩, hp⟩ := hc
      refine ⟨h1, hx, h2, hs, hh, ?_, ho⟩
      intro j hj
      simpa using List.all_eq_true.mp hp j (List.mem_range.mpr hj)
    next => cases h
  next => cases h

def checkArgs (Γ : PrologCtx) : Nat → List Insn → Option (List (LocalSlot × Asm.ArgReg))
  | _, [] => some []
  | k, i :: is =>
    match checkArg Γ k i, checkArgs Γ (k + 1) is with
    | some p, some ps => some (p :: ps)
    | _, _ => none

theorem checkArgs_sound {Γ : PrologCtx} :
    ∀ {k : Nat} {is : List Insn} {ps : List (LocalSlot × Asm.ArgReg)},
      checkArgs Γ k is = some ps → ArgsOk Γ k is ps
  | k, [], ps, h => by
    simp only [checkArgs, Option.some.injEq] at h
    subst h
    exact .nil k
  | k, i :: is, ps, h => by
    unfold checkArgs at h
    split at h
    next p ps' h1 h2 =>
      simp only [Option.some.injEq] at h
      subst h
      exact .cons (checkArg_sound h1) (checkArgs_sound h2)
    next => cases h

def pairsDisjoint : List (LocalSlot × Asm.ArgReg) → Bool
  | [] => true
  | p :: ps => ps.all (fun q => decide (SlotDisj p q)) && pairsDisjoint ps

theorem pairsDisjoint_sound :
    ∀ {ps : List (LocalSlot × Asm.ArgReg)}, pairsDisjoint ps = true → ps.Pairwise SlotDisj
  | [], _ => List.Pairwise.nil
  | p :: ps, h => by
    simp only [pairsDisjoint, Bool.and_eq_true] at h
    exact List.pairwise_cons.mpr
      ⟨fun q hq => of_decide_eq_true (List.all_eq_true.mp h.1 q hq), pairsDisjoint_sound h.2⟩

/-- The prologue's checker: the inputs' slots and registers when the rule covers it. -/
def checkProlog (Γ : PrologCtx) (is : List Insn) : Option (List (LocalSlot × Asm.ArgReg)) :=
  if is.length = Γ.plan.locs.length then
    match checkArgs Γ 0 is with
    | some ps => if pairsDisjoint ps = true then some ps else none
    | none => none
  else none

theorem checkProlog_sound {Γ : PrologCtx} {is : List Insn} {ps : List (LocalSlot × Asm.ArgReg)}
    (h : checkProlog Γ is = some ps) : LowerProlog Γ is ps := by
  unfold checkProlog at h
  split at h
  next hl =>
    split at h
    next ps' hc =>
      split at h
      next hd =>
        simp only [Option.some.injEq] at h
        subst h
        exact ⟨hl, checkArgs_sound hc, pairsDisjoint_sound hd⟩
      next => cases h
    next => cases h
  next => cases h

/-- The prologue's verdict, for coverage. -/
def prologVerdict (Γ : PrologCtx) (is : List Insn) : Verdict :=
  match checkProlog Γ is with
  | some _ => .ok
  | none => .unsupported "prologue"

end Ryo.Check.Lower
