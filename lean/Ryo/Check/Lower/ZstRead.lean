/-
Ryo.Check.Lower.ZstRead — reads of a zero-sized projected place (aot.md §C1, M5b), and their
checker.

`_d = copy/move _a.projs` where the projected place (`fieldPath`: fields; `downcastPath`: fields
and enum downcasts, `Enum.lean`) has a zero-sized type: the backend copies no bytes, so the
range has no instruction. L0 loads and stores no bytes either (its memory is unchanged), so the
simulation (`Proofs/Lower/SimZstRead.lean`) takes no R step; `_d`'s slot is empty, so its
relation holds at any liveness.

Rules (`field`, `downcast`): the place's type `ty` is `_d`'s declared type, well-formed, of
0 bytes, `_d`'s slot of 0 bytes, no instruction.

`checkZstRead` claims exactly these statements (zero-sized by `fieldPath` or `downcastPath`) and
is `none` otherwise; it must run before `checkEnum` and `checkField`, which report them as
`downcast: zero-sized` and `field: zero-sized`.
-/
import Ryo.Check.Lower.Enum
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerZstRead (Γ : StmtCtx) : Statement → List Insn → Prop where
  | field {d a : Local} {oa : Operand} {projs : List ProjElem} {ta ty : Ty} {off : Nat}
      {sd : LocalSlot}
      (ha : operandPlace? oa = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
      (hpath : fieldPath ta projs = some (off, ty)) (htd : Γ.body.locals[d]? = some ty)
      (hn : ty.size? = some 0) (hwf : ty.wf = true) (hsd : Γ.slots[d]? = some sd)
      (hz : sd.size = 0) :
      LowerZstRead Γ (.assign ⟨d, []⟩ (.use oa)) []
  | downcast {d a : Local} {oa : Operand} {projs : List ProjElem} {ta ty : Ty} {off : Nat}
      {sd : LocalSlot}
      (ha : operandPlace? oa = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
      (hpath : downcastPath ta projs = some (off, ty)) (htd : Γ.body.locals[d]? = some ty)
      (hn : ty.size? = some 0) (hwf : ty.wf = true) (hsd : Γ.slots[d]? = some sd)
      (hz : sd.size = 0) :
      LowerZstRead Γ (.assign ⟨d, []⟩ (.use oa)) []

/-! ### The checker -/

/-- The conditions on the destination for a place of type `ty`. -/
def zstDstOk (td ty : Ty) (sd : LocalSlot) : Bool :=
  decide (td = ty) && decide (ty.size? = some 0) && ty.wf && sd.size == 0

theorem zstDstOk_spec {td ty : Ty} {sd : LocalSlot} (h : zstDstOk td ty sd = true) :
    td = ty ∧ ty.size? = some 0 ∧ ty.wf = true ∧ sd.size = 0 := by
  unfold zstDstOk at h
  simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
  exact ⟨h.1.1.1, h.1.1.2, h.1.2, h.2⟩

/-- `field`'s conditions for the place `p`. -/
def fieldZstOk (Γ : StmtCtx) (d : Local) (p : MPlace) : Bool :=
  match Γ.body.locals[p.base]?, Γ.body.locals[d]?, Γ.slots[d]? with
  | some ta, some td, some sd =>
    match fieldPath ta p.proj with
    | some (_, ty) => zstDstOk td ty sd
    | none => false
  | _, _, _ => false

/-- `downcast`'s conditions for the place `p`. -/
def downcastZstOk (Γ : StmtCtx) (d : Local) (p : MPlace) : Bool :=
  match Γ.body.locals[p.base]?, Γ.body.locals[d]?, Γ.slots[d]? with
  | some ta, some td, some sd =>
    match downcastPath ta p.proj with
    | some (_, ty) => zstDstOk td ty sd
    | none => false
  | _, _, _ => false

theorem fieldZstOk_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {p : MPlace}
    (ha : operandPlace? oa = some p) (h : fieldZstOk Γ d p = true) :
    LowerZstRead Γ (.assign ⟨d, []⟩ (.use oa)) [] := by
  unfold fieldZstOk at h
  split at h
  next ta td sd hta htd hsd =>
    split at h
    next off ty hpath =>
      obtain ⟨rfl, hn, hwf, hz⟩ := zstDstOk_spec h
      exact .field (a := p.base) (projs := p.proj) ha hta hpath htd hn hwf hsd hz
    next => cases h
  next => cases h

theorem downcastZstOk_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {p : MPlace}
    (ha : operandPlace? oa = some p) (h : downcastZstOk Γ d p = true) :
    LowerZstRead Γ (.assign ⟨d, []⟩ (.use oa)) [] := by
  unfold downcastZstOk at h
  split at h
  next ta td sd hta htd hsd =>
    split at h
    next off ty hpath =>
      obtain ⟨rfl, hn, hwf, hz⟩ := zstDstOk_spec h
      exact .downcast (a := p.base) (projs := p.proj) ha hta hpath htd hn hwf hsd hz
    next => cases h
  next => cases h

/-- Decide `LowerZstRead` (see the module comment). -/
def checkZstRead (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use oa) =>
    match operandPlace? oa with
    | some p =>
      if fieldZstOk Γ d p || downcastZstOk Γ d p then
        some (match is with
          | [] => .ok
          | _ :: _ => .unsupported "zero-sized read: instructions")
      else none
    | none => none
  | _ => none

theorem checkZstRead_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkZstRead Γ st is = some .ok) : LowerZstRead Γ st is := by
  unfold checkZstRead at h
  split at h
  next d oa =>
    split at h
    next p ha =>
      split at h
      next hok =>
        have h' := Option.some.inj h
        split at h'
        · simp only [Bool.or_eq_true] at hok
          rcases hok with hf | hd
          · exact fieldZstOk_sound ha hf
          · exact downcastZstOk_sound ha hd
        · cases h'
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
