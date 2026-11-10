/-
Ryo.Check.Lower.Field — the lowering rule for reading a field of a local (aot.md §C1, M5b's
places, first rule) and its checker.

Rule:
- `field`: `_d = copy/move _a.f₁.….fₖ`, the place's projections all `.field` (no deref, index,
  downcast or cast), each a sized field of a tuple/struct/closure or union type, lowered to one
  `mov` of `n` bytes from slot offset `sa.off + off` to `_d`'s slot. `off` is the sum of the
  field offsets, read from the L0 types of `_a` (`fieldPath`: the offsets `projectPlace` adds,
  so exactly L0's), `ty` the projected type as L0 computes it (the projections' own type
  annotations are not used), equal to `_d`'s declared type, well-formed (`Ty.wf`: its
  re-encoding refines the bytes it was decoded from, MiniRust's `encode_decode_le`), of
  `n > 0` bytes; `_d`'s slot is `n` bytes (private or escaped), the field range lies in `_a`'s
  slot (`off + n ≤ sa.size`). `_a` may be private or escaped (the simulation reads and writes
  either, `Ryo.Proofs.Lower.lift_field`, SimDst.lean).

`checkField` answers `none` for any other statement (including a whole-local copy, which
`LowerStmt`'s rules cover), so a dispatcher can try families in turn.
-/
import Ryo.Check.Lower.Stmt
import Ryo.Spec.Lang.WellFormed

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The place an operand reads (`copy p` or `move p`). -/
def operandPlace? : Operand → Option MPlace
  | .copy p | .move p => some p
  | _ => none

/-- L0's field `f` of type `ty` (`projectPlace`'s `.field` case for a sized field of a tuple or
union): its offset and type. Unsized tails are not covered. -/
def fieldOf : Ty → Nat → Option (Nat × Ty)
  | .tuple fields _ _, f => fields[f]?
  | .union fields _ _ _, f => fields[f]?
  | _, _ => none

/-- The offset and type L0 reaches from type `ty` through `projs`, when they are all field
projections `fieldOf` covers (the offsets add up: each step offsets the pointer). -/
def fieldPath : Ty → List ProjElem → Option (Nat × Ty)
  | ty, [] => some (0, ty)
  | ty, .field f _ :: ps =>
    match fieldOf ty f with
    | some (o, fty) =>
      match fieldPath fty ps with
      | some (o', t) => some (o + o', t)
      | none => none
    | none => none
  | _, _ :: _ => none

/-- A coverage bucket for projections `fieldPath` does not cover. -/
def projWhy : List ProjElem → String
  | [] => "field: unsized tail, out of range or not a struct/tuple/union"
  | .field .. :: ps => projWhy ps
  | .deref _ :: _ => "place: deref"
  | .index _ :: _ | .constantIndex .. :: _ | .subslice .. :: _ => "place: index"
  | .downcast _ :: _ => "place: downcast"
  | _ :: _ => "place: cast projection"

inductive LowerField (Γ : StmtCtx) : Statement → List Insn → Prop where
  | field {d a : Local} {oa : Operand} {projs : List ProjElem} {ta ty : Ty} {off n : Nat}
      {sd sa : LocalSlot} {i : Insn}
      (ha : operandPlace? oa = some ⟨a, projs⟩)
      (hta : Γ.body.locals[a]? = some ta) (hpath : fieldPath ta projs = some (off, ty))
      (htd : Γ.body.locals[d]? = some ty)
      (hn : ty.size? = some n) (hpos : 0 < n) (hwf : ty.wf = true)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = n ∧ off + n ≤ sa.size)
      (hoff : offOk sd.off ∧ offOk (sa.off + off))
      (hi : movInsnOk Γ i n sd.off (sa.off + off) = true) :
      LowerField Γ (.assign ⟨d, []⟩ (.use oa)) [i]

/-- `field`'s checker for `_d = copy/move _a.projs`. -/
def checkFieldUse (Γ : StmtCtx) (d a : Local) (projs : List ProjElem) (is : List Insn) :
    Verdict :=
  match Γ.body.locals[a]? with
  | none => .rejected "field: no source local"
  | some ta =>
    match fieldPath ta projs with
    | none => .unsupported (projWhy projs)
    | some (off, ty) =>
      match Γ.body.locals[d]? with
      | none => .rejected "field: no destination local"
      | some td =>
        if td != ty then .unsupported "field: types"
        else match ty.size? with
          | none => .unsupported "field: unsized"
          | some n =>
            if n = 0 then .unsupported "field: zero-sized"
            else if !ty.wf then .rejected "field: ill-formed type"
            else match Γ.slots[d]?, Γ.slots[a]?, is with
              | some sd, some sa, [i] =>
                if !(sd.size == n && decide (off + n ≤ sa.size)) then
                  .rejected "field: slot sizes"
                else if !(offOk sd.off && offOk (sa.off + off)) then .rejected "field: offsets"
                else if movInsnOk Γ i n sd.off (sa.off + off) then .ok
                else .unsupported "field: instruction form"
              | _, _, _ => .unsupported "field: slots or instruction count"

/-- The family's checker: `none` unless `st` is `_d = copy/move` of a projected place. -/
def checkField (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use oa) =>
    match operandPlace? oa with
    | some p => if p.proj.isEmpty then none else some (checkFieldUse Γ d p.base p.proj is)
    | none => none
  | _ => none

theorem checkFieldUse_sound {Γ : StmtCtx} {d a : Local} {oa : Operand} {projs : List ProjElem}
    {is : List Insn} (ha : operandPlace? oa = some ⟨a, projs⟩)
    (h : checkFieldUse Γ d a projs is = .ok) : LowerField Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkFieldUse at h
  split at h
  · cases h
  next ta hta =>
    split at h
    · cases h
    next off ty hpath =>
      split at h
      · cases h
      next td htd =>
        split at h
        · cases h
        next hty =>
          have e : td = ty := by simpa using hty
          rw [e] at htd
          split at h
          · cases h
          next n hn =>
            split at h
            · cases h
            next hn0 =>
              split at h
              · cases h
              next hwf =>
                have hwf' : ty.wf = true := by simpa using hwf
                split at h
                next sd sa i hsd hsa =>
                  split at h
                  · cases h
                  next hsz =>
                    split at h
                    · cases h
                    next hoff =>
                      split at h
                      next hi =>
                        exact .field ha hta hpath htd hn (Nat.pos_of_ne_zero hn0) hwf' hsd hsa
                          (by simpa using hsz) (by simpa using hoff) hi
                      · cases h
                · cases h

theorem checkField_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkField Γ st is = some .ok) : LowerField Γ st is := by
  unfold checkField at h
  split at h
  next d oa =>
    split at h
    next p hp =>
      split at h
      · cases h
      · exact checkFieldUse_sound (a := p.base) (projs := p.proj) hp (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
