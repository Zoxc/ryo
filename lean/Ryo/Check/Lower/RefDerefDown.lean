/-
Ryo.Check.Lower.RefDerefDown — `RefDeref.lean`'s rule with downcasts among the projections
after the deref (aot.md §C1, M5b's places): `_d = &(*_p).p₁.….pₖ` / `&raw …` with `_p` a thin
pointer local and the `pᵢ` fields and enum downcasts (`Enum.lean`'s `downcastPath`: a downcast
moves to the variant's field tuple at offset 0), `_d` a thin pointer local.

The backend's place (`place.rs` `deref`, `field`, `downcast`) is `[sp.off + off]`, a downcast
adding nothing, so the instruction is `RefDeref.lean`'s (`refDerefInsnOk`: `mov.w64 d, p` at
offset 0, else `ptr_add d, p, off`). L0's `.downcast` projection keeps the place and changes
its type (`projectPlace`); the simulation is `Proofs/Lower/SimRefDerefDown.lean`.

`checkRefDerefDown` answers `none` unless the projections after the deref contain a downcast
and `_p` is a thin pointer local; it runs before `checkRefDeref`, which reports downcasts as
unsupported.
-/
import Ryo.Check.Lower.RefDeref
import Ryo.Check.Lower.Enum

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerRefDerefDown (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {d p : Local} {rv : Rvalue} {pointee ty : Ty} {fields : List ProjElem} {pt ptd : PtrType}
      {valid vd : ValidRange} {off : Nat} {sd sp : LocalSlot} {i : Insn}
      (hrv : refPlace? rv = some ⟨p, .deref pointee :: fields⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hpath : downcastPath pointee fields = some (off, ty))
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
      (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp)
      (hsize : sd.size = 8 ∧ sp.size = 8)
      (hoff : offOk sd.off ∧ offOk sp.off)
      (hi : refDerefInsnOk Γ i sd.off sp.off off = true) :
      LowerRefDerefDown Γ (.assign ⟨d, []⟩ rv) [i]

/-- `mk`'s checker. -/
def checkRefDerefDownPlace (Γ : StmtCtx) (d p : Local) (pointee : Ty) (fields : List ProjElem)
    (is : List Insn) : Verdict :=
  match Γ.body.locals[p]? with
  | some (.ptr pt _) =>
    if pt.metaKind = .none then
      match downcastPath pointee fields with
      | none => .unsupported ("ref deref " ++ downcastWhy fields)
      | some (off, _) =>
        match Γ.body.locals[d]? with
        | some (.ptr ptd _) =>
          if ptd.metaKind = .none then
            match Γ.slots[d]?, Γ.slots[p]?, is with
            | some sd, some sp, [i] =>
              if !(sd.size == 8 && sp.size == 8) then .rejected "ref deref down: slot sizes"
              else if !(offOk sd.off && offOk sp.off) then .rejected "ref deref down: offsets"
              else if refDerefInsnOk Γ i sd.off sp.off off then .ok
              else .unsupported "ref deref down: instruction form"
            | _, _, _ => .unsupported "ref deref down: slots or instruction count"
          else .unsupported "ref deref down: wide destination"
        | _ => .unsupported "ref deref down: destination not a pointer"
    else .unsupported "ref deref down: wide pointer"
  | _ => .unsupported "ref deref down: not a pointer local"

/-- `_p` is a thin pointer local. -/
def thinPtrLocal (Γ : StmtCtx) (p : Local) : Bool :=
  match Γ.body.locals[p]? with
  | some (.ptr pt _) => decide (pt.metaKind = .none)
  | _ => false

/-- The family's checker (see the module comment). -/
def checkRefDerefDown (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ rv =>
    match refPlace? rv with
    | some ⟨p, .deref pointee :: fields⟩ =>
      if fields.any isDowncast && thinPtrLocal Γ p then
        some (checkRefDerefDownPlace Γ d p pointee fields is)
      else none
    | _ => none
  | _ => none

theorem checkRefDerefDownPlace_sound {Γ : StmtCtx} {d p : Local} {rv : Rvalue} {pointee : Ty}
    {fields : List ProjElem} {is : List Insn}
    (hrv : refPlace? rv = some ⟨p, .deref pointee :: fields⟩)
    (h : checkRefDerefDownPlace Γ d p pointee fields is = .ok) :
    LowerRefDerefDown Γ (.assign ⟨d, []⟩ rv) is := by
  unfold checkRefDerefDownPlace at h
  split at h
  next pt valid htp =>
    split at h
    next hk =>
      split at h
      · cases h
      next off ty hpath =>
        split at h
        next ptd vd htd =>
          split at h
          next hkd =>
            split at h
            next sd sp i hsd hsp =>
              split at h
              · cases h
              next hsz =>
                split at h
                · cases h
                next hoff =>
                  split at h
                  next hi =>
                    exact .mk hrv htp hk hpath htd hkd hsd hsp (by simpa using hsz)
                      (by simpa using hoff) hi
                  · cases h
            · cases h
          · cases h
        · cases h
    · cases h
  · cases h

theorem checkRefDerefDown_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkRefDerefDown Γ st is = some .ok) : LowerRefDerefDown Γ st is := by
  unfold checkRefDerefDown at h
  split at h
  next d rv =>
    split at h
    next p pointee fields hp =>
      split at h
      · exact checkRefDerefDownPlace_sound hp (Option.some.inj h)
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
