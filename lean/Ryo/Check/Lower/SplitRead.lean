/-
Ryo.Check.Lower.SplitRead — reads of a projected place copied in several pieces (aot.md §C1,
M5b), and their checker.

`_d = copy/move _a.projs` with the place inside `_a`'s slot (`fieldPath`: fields; or
`downcastPath`: fields and enum downcasts, `Enum.lean`) at offset `off`, of `n` bytes that are
not one `mov` width: the backend's `copy_val` copies them slot to slot in pieces
(`movPieces`, as `Agg.lean`'s split copies of whole locals), the destination's slot apart from
the source range.

Rules (`field`, `downcast`): `ty` the place's type and `_d`'s, well-formed, of `n > 0` bytes,
`_d`'s slot of `n` bytes and never escaped, the source range `[sa.off + off, +n)` inside `_a`'s
slot and apart from `_d`'s, the offsets in range, and the instructions `movPieces sd.off
(sa.off + off) 0 ws` for widths `ws` summing to `n` (`piecesOk`). The simulation is
`Proofs/Lower/SimSplitRead.lean`.

`checkSplitRead` claims a read of a projected place only when its instructions parse as such
pieces with more than one instruction (single `mov`s are `Field.lean`'s and `Enum.lean`'s), and
is `none` otherwise; it must run before `checkEnum` and `checkField`, which report these as
`… slots or instruction count`. The widths are read off the instructions (`parseMovs`,
untrusted) and then checked.
-/
import Ryo.Check.Lower.Enum
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The facts shared by both rules, for the place at `off` of type `ty` in `_a`. -/
def SplitReadOk (Γ : StmtCtx) (d a : Local) (off : Nat) (ty : Ty) (is : List Insn) : Prop :=
  ∃ (n : Nat) (sd sa : LocalSlot) (ws : List Nat),
    Γ.body.locals[d]? = some ty ∧ ty.size? = some n ∧ 0 < n ∧ ty.wf = true ∧
    Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧
    (sd.size = n ∧ off + n ≤ sa.size) ∧
    (offOk sd.off = true ∧ offOk (sd.off + n) = true ∧ offOk (sa.off + off) = true ∧
      offOk (sa.off + off + n) = true) ∧
    (sa.off + off + n ≤ sd.off ∨ sd.off + n ≤ sa.off + off) ∧
    (∀ k < sd.size, Γ.escaped (sd.off + k) = false) ∧
    ws.sum = n ∧ piecesOk Γ is (movPieces sd.off (sa.off + off) 0 ws) = true

inductive LowerSplitRead (Γ : StmtCtx) : Statement → List Insn → Prop where
  | field {d a : Local} {oa : Operand} {projs : List ProjElem} {ta ty : Ty} {off : Nat}
      {is : List Insn}
      (ha : operandPlace? oa = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
      (hpath : fieldPath ta projs = some (off, ty)) (hok : SplitReadOk Γ d a off ty is) :
      LowerSplitRead Γ (.assign ⟨d, []⟩ (.use oa)) is
  | downcast {d a : Local} {oa : Operand} {projs : List ProjElem} {ta ty : Ty} {off : Nat}
      {is : List Insn}
      (ha : operandPlace? oa = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
      (hpath : downcastPath ta projs = some (off, ty)) (hok : SplitReadOk Γ d a off ty is) :
      LowerSplitRead Γ (.assign ⟨d, []⟩ (.use oa)) is

/-! ### The checker -/

/-- `SplitReadOk`'s conditions, the widths guessed by `parseMovs`. -/
def splitReadOk (Γ : StmtCtx) (d a : Local) (off : Nat) (ty : Ty) (is : List Insn) : Bool :=
  match Γ.body.locals[d]?, ty.size?, Γ.slots[d]?, Γ.slots[a]? with
  | some td, some n, some sd, some sa =>
    match parseMovs Γ sd.off (sa.off + off) n 0 is with
    | some (ws, []) =>
      decide (td = ty) && decide (0 < n) && ty.wf && sd.size == n &&
        decide (off + n ≤ sa.size) && offOk sd.off && offOk (sd.off + n) &&
        offOk (sa.off + off) && offOk (sa.off + off + n) &&
        (decide (sa.off + off + n ≤ sd.off) || decide (sd.off + n ≤ sa.off + off)) &&
        privOk Γ sd.off sd.size && ws.sum == n &&
        piecesOk Γ is (movPieces sd.off (sa.off + off) 0 ws)
    | _ => false
  | _, _, _, _ => false

theorem splitReadOk_spec {Γ : StmtCtx} {d a : Local} {off : Nat} {ty : Ty} {is : List Insn}
    (h : splitReadOk Γ d a off ty is = true) : SplitReadOk Γ d a off ty is := by
  unfold splitReadOk at h
  split at h
  next td n sd sa htd hn hsd hsa =>
    split at h
    next ws hp =>
      simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq, decide_eq_true_eq] at h
      obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩, h11⟩, h12⟩, h13⟩ := h
      subst h1
      exact ⟨n, sd, sa, ws, htd, hn, h2, h3, hsd, hsa, ⟨h4, h5⟩, ⟨h6, h7, h8, h9⟩, h10,
        privOk_spec h11, h12, h13⟩
    next => cases h
  next => cases h

/-- Decide `LowerSplitRead` (see the module comment). -/
def checkSplitRead (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use oa) =>
    match operandPlace? oa, is with
    | some p, _ :: _ :: _ =>
      match Γ.body.locals[p.base]? with
      | some ta =>
        match fieldPath ta p.proj with
        | some (off, ty) =>
          if splitReadOk Γ d p.base off ty is then some .ok else none
        | none =>
          match downcastPath ta p.proj with
          | some (off, ty) =>
            if splitReadOk Γ d p.base off ty is then some .ok else none
          | none => none
      | none => none
    | _, _ => none
  | _ => none

theorem checkSplitRead_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkSplitRead Γ st is = some .ok) : LowerSplitRead Γ st is := by
  unfold checkSplitRead at h
  split at h
  next d oa =>
    split at h
    next p i1 i2 rest ha =>
      split at h
      next ta hta =>
        split at h
        next off ty hpath =>
          split at h
          next hok =>
            exact .field (a := p.base) (projs := p.proj) ha hta hpath (splitReadOk_spec hok)
          next => cases h
        next =>
          split at h
          next off ty hpath =>
            split at h
            next hok =>
              exact .downcast (a := p.base) (projs := p.proj) ha hta hpath
                (splitReadOk_spec hok)
            next => cases h
          next => cases h
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
