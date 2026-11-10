/-
Ryo.Check.Lower.DiscrPlace — the discriminant of an enum in a field of a local (aot.md §C1,
M5b), next to `Enum.lean`'s whole-local rules, and its checker.

What the backend emits (`backend/src/lower/adt.rs` `discriminant`, `tag_field`; `place.rs`):
`_d = discriminant(_a.f₁.….fₖ)` with the place in `_a`'s slot (`Loc::Slot(sa.off + off)`, `off`
the fields' offset) reads the tag from the slot at `off + tag.offset`, then `int_cast`s it into
`_d` (`mov` or `cvt`, as `Enum.lean`'s `discrDirect`): one instruction.

Rule (`discrField`): the fields (`fieldPath`) lead from `_a`'s type to a `.multiple` enum with a
`.direct` tag, `_d` an integer, `discrAgree` as for `discrDirect`, the tag inside `_a`'s slot,
`tagReadOk` from `sa.off + (off + tag.offset)`, and the tag's offset in the place's allocation
below `2 ^ 64` (so L0's `wrappingOffset` to the tag does not wrap). The simulation is
`Proofs/Lower/SimDiscrPlace.lean`.

`checkDiscrPlace` claims exactly these statements and is `none` otherwise; it must run before
`checkEnum`, which reports every projected discriminant as `discriminant: projected place`.
Not covered: discriminants through a pointer (`*_p`), niche tags.
-/
import Ryo.Check.Lower.Enum
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerDiscrPlace (Γ : StmtCtx) : Statement → List Insn → Prop where
  | discrField {d a : Local} {projs : List ProjElem} {ta : Ty} {off : Nat} {vs : List Variant}
      {discrTy : IntType} {tag : TagInfo} {esz : Size} {eal : Align} {t : IntType}
      {vd : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hta : Γ.body.locals[a]? = some ta)
      (hpath : fieldPath ta projs = some (off, .enum vs discrTy (.multiple tag) esz eal))
      (henc : tag.encoding = .direct)
      (htd : Γ.body.locals[d]? = some (.int t vd))
      (hagree : discrAgree vs discrTy tag t = true)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ 0 < t.size ∧ 0 < tag.tag.size ∧
        off + tag.offset + tag.tag.size ≤ sa.size)
      (hoff : offOk sd.off = true ∧ offOk (sa.off + (off + tag.offset)) = true)
      (hbound : off + tag.offset < 2 ^ 64)
      (hi : tagReadOk Γ i tag.tag t.size sd.off (sa.off + (off + tag.offset)) = true) :
      LowerDiscrPlace Γ (.assign ⟨d, []⟩ (.discriminant ⟨a, projs⟩)) [i]

/-! ### The checker -/

/-- `discrField`'s conditions. -/
def discrFieldOk (Γ : StmtCtx) (d a : Local) (projs : List ProjElem) (i : Insn) : Bool :=
  match Γ.body.locals[a]?, Γ.body.locals[d]?, Γ.slots[d]?, Γ.slots[a]? with
  | some ta, some (.int t _), some sd, some sa =>
    match fieldPath ta projs with
    | some (off, .enum vs discrTy (.multiple tag) _ _) =>
      match tag.encoding with
      | .direct =>
        discrAgree vs discrTy tag t && sd.size == t.size && decide (0 < t.size) &&
          decide (0 < tag.tag.size) && decide (off + tag.offset + tag.tag.size ≤ sa.size) &&
          offOk sd.off && offOk (sa.off + (off + tag.offset)) &&
          decide (off + tag.offset < 2 ^ 64) &&
          tagReadOk Γ i tag.tag t.size sd.off (sa.off + (off + tag.offset))
      | _ => false
    | _ => false
  | _, _, _, _ => false

theorem discrFieldOk_sound {Γ : StmtCtx} {d a : Local} {projs : List ProjElem} {i : Insn}
    (h : discrFieldOk Γ d a projs i = true) :
    LowerDiscrPlace Γ (.assign ⟨d, []⟩ (.discriminant ⟨a, projs⟩)) [i] := by
  unfold discrFieldOk at h
  split at h
  next ta t vd sd sa hta htd hsd hsa =>
    split at h
    next off vs discrTy tag esz eal hpath =>
      split at h
      next henc =>
        simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
        obtain ⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩ := h
        exact .discrField hta hpath henc htd h1 hsd hsa ⟨h2, h3, h4, h5⟩ ⟨h6, h7⟩ h8 h9
      next => cases h
    next => cases h
  next => cases h

/-- Decide `LowerDiscrPlace` (see the module comment). -/
def checkDiscrPlace (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.discriminant ⟨a, projs⟩) =>
    if projs.isEmpty then none
    else if projs.all (fun | .field .. => true | _ => false) then
      some (match is with
        | [i] => okIf (discrFieldOk Γ d a projs i) "discriminant of a field: form"
        | _ => .unsupported "discriminant of a field: instruction count")
    else none
  | _ => none

theorem checkDiscrPlace_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkDiscrPlace Γ st is = some .ok) : LowerDiscrPlace Γ st is := by
  unfold checkDiscrPlace at h
  split at h
  next d a projs =>
    split at h
    · cases h
    · split at h
      · have h' := Option.some.inj h
        split at h'
        next i => exact discrFieldOk_sound (okIf_ok h')
        next => cases h'
      · cases h
  next => cases h

end Ryo.Check.Lower
