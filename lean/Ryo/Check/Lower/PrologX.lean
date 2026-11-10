/-
Ryo.Check.Lower.PrologX — the prologue's rule extended to every register input (aot.md §C1,
M5b), next to `Prolog.lean`'s rule (one integer register piece per input, of its local's whole
size).

`LowerPrologX Γ is inps lw` says that the R instructions `is` (the certificate's `prologue`
range) are `FnCx::prologue`'s (`backend/src/lower/frame.rs`) for a plan all of whose pieces are
in registers: one `arg home, r` per piece, in order (`allWrites`):

- the sret pointer first, if the function returns through one: `gpr0`'s 8 bytes to the sret slot
  (`FuncCert.sret`);
- then per MIR input `k` (`inps`, local `k + 1`, its home `FuncCert.argHomes[k]` that local's
  slot): each of its plan pieces `.reg a off` (`InputOk`) as `arg (home + off), a` (without
  `sext`: the callee doesn't rely on the caller's extension), the piece inside the slot. This
  covers integer, `bool`, `char` and thin-pointer scalars, `Cast` units, scalar pairs (two
  pieces: wide pointers, `(u64, u64)`, `i128`), floats in `xmm`, and ZSTs (no pieces);
- then, for a `#[track_caller]` function, the caller location, the plan's last input: one
  8-byte integer register to `FuncCert.callerLocation` (`lw`).

The writes are pairwise disjoint (`WriteDisj`), so each one's bytes survive the later ones.
Nothing is required of the home bytes outside the pieces (padding): the L0 side of call entry
has them uninitialized (`ArgRelX`, `SimPrologX.lean`). Unlike `Prolog.lean`, no check that the
written bytes are outside every `Escape` scope: at function entry nothing is escaped, and the
prologue's instructions carry no scopes (`match_entry`'s `hnoesc`, `hcode`).

Not covered (`prologXVerdict`'s buckets): `Indirect` inputs (`arg` of the pointer, then
`load.copy` through it), stack pieces and `byval` (`mov`s from the incoming area), and a spread
argument (`rust-call`: the inputs are fields of one local).
-/
import Ryo.Check.Lower.Prolog

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- A function's context for its prologue, with the slots `Prolog.lean` doesn't look at. -/
structure PrologXCtx extends PrologCtx where
  /-- `FuncCert.sret`: the slot the sret pointer is stored to. -/
  sret : Option Int
  /-- `FuncCert.callerLocation`: the slot of a `#[track_caller]` function's caller location. -/
  callerLoc : Option Int
  /-- Whether the function has a spread argument (`FuncCert.spreadArg`). -/
  spread : Bool

/-- One `arg`: the frame offset written and the register (its low `size` bytes). -/
abbrev ArgWrite := Int × Asm.ArgReg

/-- `gpr0` as the sret pointer's register. -/
def sretReg : Asm.ArgReg := ⟨false, 8, 0, false⟩

/-- An input's plan pieces when all are in registers: (offset in the value, register as the
`arg` names it, without `sext`). -/
def regPieces : List ArgLoc → Option (List (Nat × Asm.ArgReg))
  | [] => some []
  | .reg a off :: ls => (regPieces ls).map fun ps => (off, { a with sext := false }) :: ps
  | _ :: _ => none

/-- A MIR input's home slot and pieces. -/
structure InputX where
  slot : LocalSlot
  pieces : List (Nat × Asm.ArgReg)

/-- An input's `arg` writes. -/
def InputX.writes (inp : InputX) : List ArgWrite :=
  inp.pieces.map fun p => (inp.slot.off + p.1, p.2)

/-- Input `k`'s rule: its plan pieces all in registers, local `k + 1`'s slot its home, every
piece inside the slot. -/
abbrev InputOk (Γ : PrologXCtx) (k : Nat) (inp : InputX) : Prop :=
  ∃ ls, Γ.plan.locs[k]? = some ls ∧ regPieces ls = some inp.pieces ∧
    Γ.slots[k + 1]? = some inp.slot ∧ Γ.argHomes[k]? = some inp.slot.off ∧
    ∀ p ∈ inp.pieces, p.1 + p.2.size ≤ inp.slot.size

/-- The inputs from `k` on. -/
inductive InputsOk (Γ : PrologXCtx) : Nat → List InputX → Prop where
  | nil (k : Nat) : InputsOk Γ k []
  | cons {k : Nat} {inp : InputX} {inps : List InputX} :
      InputOk Γ k inp → InputsOk Γ (k + 1) inps → InputsOk Γ k (inp :: inps)

/-- The number of MIR inputs: the plan's inputs but a `#[track_caller]` caller location. -/
def nInputs (Γ : PrologXCtx) : Nat :=
  Γ.plan.locs.length - (if Γ.callerLoc.isSome then 1 else 0)

/-- The sret pointer's write. -/
def sretWrites (Γ : PrologXCtx) : List ArgWrite := Γ.sret.toList.map fun o => (o, sretReg)

/-- The caller location's write: plan input `n` (the last), one 8-byte integer register, its
home the caller-location slot. -/
def locWrites (Γ : PrologXCtx) (n : Nat) : Option (List ArgWrite) :=
  match Γ.callerLoc with
  | none => some []
  | some off =>
    match Γ.plan.locs[n]?, Γ.argHomes[n]? with
    | some [.reg a 0], some h =>
      if h == off && !a.xmm && a.size == 8 && !a.sext then some [(off, a)] else none
    | _, _ => none

/-- Every `arg`, in the prologue's order. -/
def allWrites (Γ : PrologXCtx) (inps : List InputX) (lw : List ArgWrite) : List ArgWrite :=
  sretWrites Γ ++ inps.flatMap InputX.writes ++ lw

/-- Two writes' byte ranges are disjoint. -/
def WriteDisj (w v : ArgWrite) : Prop :=
  w.1 + (w.2.size : Int) ≤ v.1 ∨ v.1 + (v.2.size : Int) ≤ w.1

instance (w v : ArgWrite) : Decidable (WriteDisj w v) := by
  unfold WriteDisj; infer_instance

/-- Each instruction the `arg` of the matching write, in order. -/
inductive ArgsAre : List Insn → List ArgWrite → Prop where
  | nil : ArgsAre [] []
  | cons {i : Insn} {is : List Insn} {w : ArgWrite} {ws : List ArgWrite} :
      argOps i = some w → ArgsAre is ws → ArgsAre (i :: is) (w :: ws)

structure LowerPrologX (Γ : PrologXCtx) (is : List Insn) (inps : List InputX)
    (lw : List ArgWrite) : Prop where
  spread : Γ.spread = false
  len : inps.length = nInputs Γ
  inputs : InputsOk Γ 0 inps
  loc : locWrites Γ inps.length = some lw
  insns : ArgsAre is (allWrites Γ inps lw)
  disj : (allWrites Γ inps lw).Pairwise WriteDisj

/-! ### The checker -/

/-- Input `k`'s checker. -/
def checkInput (Γ : PrologXCtx) (k : Nat) : Option InputX :=
  match Γ.plan.locs[k]?, Γ.slots[k + 1]?, Γ.argHomes[k]? with
  | some ls, some slot, some h =>
    match regPieces ls with
    | some ps =>
      if h == slot.off && ps.all (fun p => decide (p.1 + p.2.size ≤ slot.size)) then
        some ⟨slot, ps⟩
      else none
    | none => none
  | _, _, _ => none

theorem checkInput_sound {Γ : PrologXCtx} {k : Nat} {inp : InputX}
    (h : checkInput Γ k = some inp) : InputOk Γ k inp := by
  unfold checkInput at h
  split at h
  next ls slot hh h1 h2 h3 =>
    split at h
    next ps hps =>
      split at h
      next hc =>
        simp only [Option.some.injEq] at h
        subst h
        simp only [Bool.and_eq_true, beq_iff_eq, List.all_eq_true, decide_eq_true_eq] at hc
        obtain ⟨hh', hfit⟩ := hc
        exact ⟨ls, h1, hps, h2, h3.trans (congrArg some hh'), hfit⟩
      next => cases h
    next => cases h
  next => cases h

/-- The inputs from `k` on, `n` of them. -/
def checkInputs (Γ : PrologXCtx) : Nat → Nat → Option (List InputX)
  | _, 0 => some []
  | k, n + 1 =>
    match checkInput Γ k, checkInputs Γ (k + 1) n with
    | some p, some ps => some (p :: ps)
    | _, _ => none

theorem checkInputs_sound {Γ : PrologXCtx} :
    ∀ {k n : Nat} {inps : List InputX}, checkInputs Γ k n = some inps →
      inps.length = n ∧ InputsOk Γ k inps
  | k, 0, inps, h => by
    simp only [checkInputs, Option.some.injEq] at h
    subst h
    exact ⟨rfl, .nil k⟩
  | k, n + 1, inps, h => by
    unfold checkInputs at h
    split at h
    next p ps h1 h2 =>
      simp only [Option.some.injEq] at h
      subst h
      obtain ⟨hl, hok⟩ := checkInputs_sound h2
      exact ⟨by simp only [List.length_cons, hl], .cons (checkInput_sound h1) hok⟩
    next => cases h

/-- Each instruction an `arg` of the matching write. -/
def argsMatch : List Insn → List ArgWrite → Bool
  | [], [] => true
  | i :: is, w :: ws => decide (argOps i = some w) && argsMatch is ws
  | _, _ => false

theorem argsMatch_sound : ∀ {is : List Insn} {ws : List ArgWrite}, argsMatch is ws = true →
    ArgsAre is ws
  | [], [], _ => .nil
  | i :: is, w :: ws, h => by
    simp only [argsMatch, Bool.and_eq_true, decide_eq_true_eq] at h
    exact .cons h.1 (argsMatch_sound h.2)
  | [], _ :: _, h => by first | (simp [argsMatch] at h; done) | cases h
  | _ :: _, [], h => by first | (simp [argsMatch] at h; done) | cases h

def writesDisjoint : List ArgWrite → Bool
  | [] => true
  | w :: ws => ws.all (fun v => decide (WriteDisj w v)) && writesDisjoint ws

theorem writesDisjoint_sound :
    ∀ {ws : List ArgWrite}, writesDisjoint ws = true → ws.Pairwise WriteDisj
  | [], _ => List.Pairwise.nil
  | w :: ws, h => by
    simp only [writesDisjoint, Bool.and_eq_true] at h
    exact List.pairwise_cons.mpr
      ⟨fun v hv => of_decide_eq_true (List.all_eq_true.mp h.1 v hv), writesDisjoint_sound h.2⟩

/-- The prologue's checker: the inputs and the caller location's write when the rule covers it. -/
def checkPrologX (Γ : PrologXCtx) (is : List Insn) : Option (List InputX × List ArgWrite) :=
  if Γ.spread then none
  else
    match checkInputs Γ 0 (nInputs Γ) with
    | some inps =>
      match locWrites Γ inps.length with
      | some lw =>
        if argsMatch is (allWrites Γ inps lw) && writesDisjoint (allWrites Γ inps lw) then
          some (inps, lw)
        else none
      | none => none
    | none => none

theorem checkPrologX_sound {Γ : PrologXCtx} {is : List Insn} {inps : List InputX}
    {lw : List ArgWrite} (h : checkPrologX Γ is = some (inps, lw)) : LowerPrologX Γ is inps lw := by
  unfold checkPrologX at h
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
          obtain ⟨hlen, hin⟩ := checkInputs_sound hc
          exact ⟨by simpa using hsp, hlen, hin, hl, argsMatch_sound hm.1,
            writesDisjoint_sound hm.2⟩
        next => cases h
      next => cases h
    next => cases h

def ArgLoc.isIndirect : ArgLoc → Bool
  | .ptrReg _ | .ptrStack _ => true
  | _ => false

def ArgLoc.isStack : ArgLoc → Bool
  | .stack .. | .stackByval .. => true
  | _ => false

/-- Why the plan has a piece the rule doesn't cover, if it does. -/
def prologXWhy (Γ : PrologXCtx) : Option String :=
  if Γ.spread then some "prologue: spread argument"
  else if Γ.plan.locs.any (fun ls => ls.any ArgLoc.isIndirect) then
    some "prologue: indirect input"
  else if Γ.plan.locs.any (fun ls => ls.any ArgLoc.isStack) then some "prologue: stack input"
  else none

/-- The prologue's verdict, for coverage. -/
def prologXVerdict (Γ : PrologXCtx) (is : List Insn) : Verdict :=
  match checkPrologX Γ is with
  | some _ => .ok
  | none => .unsupported ((prologXWhy Γ).getD "prologue: form")

theorem prologXVerdict_sound {Γ : PrologXCtx} {is : List Insn} (h : prologXVerdict Γ is = .ok) :
    ∃ inps lw, LowerPrologX Γ is inps lw := by
  unfold prologXVerdict at h
  split at h
  next r hr => exact ⟨r.1, r.2, checkPrologX_sound hr⟩
  next => cases h

end Ryo.Check.Lower
