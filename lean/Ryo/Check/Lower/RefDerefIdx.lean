/-
Ryo.Check.Lower.RefDerefIdx — the lowering rule for the address of a slice element through a
wide pointer local (aot.md §C1, M5b's places): `_d = &(*_p)[_i]` / `&raw (*_p)[_i]`, `_p` a
slice pointer (`pt.metaKind = .elementCount`, 16 bytes), `_i` a `usize` local, `_d` a thin
pointer local.

What the backend emits (`place.rs` `deref`, `index`; `rvalue.rs` `address_of`): the place
`(*_p)[_i]` is `ptr.index t, p, i, stride` into a temporary `t` (the data pointer, the first 8
bytes of `_p`'s slot, plus `_i`'s value times the element size `stride`), then `addr_into`'s
`Loc::Mem { p: t, k: 0 }` case, `mov.w64 d, t`. The bounds check is MIR's own `Assert` before
the statement; L0's `.index` projection checks it again (UB past the length) and offsets in
bounds (`ptrOffsetInbounds`), so a successful L0 run has the address below `ADDR_LIMIT`, where
R's wrapping `(i * stride) % 2^64` offset is the same.

Rule (`LowerRefDerefIdx.mk`): the two instructions (`Offset.lean`'s `ptrIndexInsnOk`,
`movInsnOk` at 8 bytes), the temporary `tempOk` (private, inside the frame, apart from every
local's slot), `_d`'s slot 8 bytes (private or escaped: the simulation writes it through `DstWrite`), `_i`'s slot 8 bytes.
The simulation is `Proofs/Lower/SimRefDerefIdx.lean`.

`checkRefDerefIdx` answers `none` unless `st` has that shape with `_p` a wide pointer local; it
must run before `checkRefDerefWide`, which reports index projections as unsupported.
-/
import Ryo.Check.Lower.RefDerefWide
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.Offset

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerRefDerefIdx (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {d p l : Local} {rv : Rvalue} {elem : Ty} {pt ptd : PtrType} {valid vd vi : ValidRange}
      {sd sp si : LocalSlot} {t : Int} {i1 i2 : Insn}
      (hrv : refPlace? rv = some ⟨p, [.deref (.slice elem), .index l]⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
      (hti : Γ.body.locals[l]? = some (.int IntType.usize vi))
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
      (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp) (hsi : Γ.slots[l]? = some si)
      (hsize : sd.size = 8 ∧ sp.size = 16 ∧ si.size = 8)
      (hoff : offOk sd.off ∧ offOk sp.off ∧ offOk si.off)
      (htmp : tempOk Γ t 8)
      (hi1 : ptrIndexInsnOk Γ i1 t sp.off si.off elem.size = true)
      (hi2 : movInsnOk Γ i2 8 sd.off t = true) :
      LowerRefDerefIdx Γ (.assign ⟨d, []⟩ rv) [i1, i2]

/-- The temporary a `ptr_index` writes, if `i` is one (untrusted). -/
def ptrIndexDst (Γ : StmtCtx) (i : Insn) : Option Int :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.ops with
    | .slot t :: _ => some t
    | _ => none
  | none => none

/-- `mk`'s checker for `_d = &(*_p)[_l]`, `_p` wide. -/
def checkRefDerefIdxPlace (Γ : StmtCtx) (d p l : Local) (elem : Ty) (is : List Insn) :
    Verdict :=
  match Γ.body.locals[p]?, Γ.body.locals[d]?, Γ.body.locals[l]? with
  | some (.ptr pt _), some (.ptr ptd _), some (.int it _) =>
    if pt.metaKind = .none then .unsupported "ref deref index: thin pointer"
    else if ptd.metaKind ≠ .none then .unsupported "ref deref index: wide destination"
    else if it ≠ IntType.usize then .unsupported "ref deref index: index type"
    else match Γ.slots[d]?, Γ.slots[p]?, Γ.slots[l]?, is with
      | some sd, some sp, some si, [i1, i2] =>
        if !(sd.size == 8 && sp.size == 16 && si.size == 8) then
          .rejected "ref deref index: slot sizes"
        else if !(offOk sd.off && offOk sp.off && offOk si.off) then
          .rejected "ref deref index: offsets"
        else match ptrIndexDst Γ i1 with
          | none => .unsupported "ref deref index: instruction form"
          | some t =>
            if !tempOk Γ t 8 then .unsupported "ref deref index: temporary"
            else if ptrIndexInsnOk Γ i1 t sp.off si.off elem.size &&
                movInsnOk Γ i2 8 sd.off t then .ok
            else .unsupported "ref deref index: instruction form"
      | _, _, _, _ => .unsupported "ref deref index: slots or instruction count"
  | _, _, _ => .unsupported "ref deref index: types"

/-- The family's checker (see the module comment). -/
def checkRefDerefIdx (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ rv =>
    match refPlace? rv with
    | some ⟨p, [.deref (.slice elem), .index l]⟩ =>
      if isWidePtr Γ.body.locals[p]? then some (checkRefDerefIdxPlace Γ d p l elem is)
      else none
    | _ => none
  | _ => none

theorem checkRefDerefIdxPlace_sound {Γ : StmtCtx} {d p l : Local} {rv : Rvalue} {elem : Ty}
    {is : List Insn} (hrv : refPlace? rv = some ⟨p, [.deref (.slice elem), .index l]⟩)
    (h : checkRefDerefIdxPlace Γ d p l elem is = .ok) :
    LowerRefDerefIdx Γ (.assign ⟨d, []⟩ rv) is := by
  unfold checkRefDerefIdxPlace at h
  split at h
  next pt valid ptd vd it vi htp htd hti =>
    split at h
    · cases h
    next hk =>
      split at h
      · cases h
      next hkd =>
        have hkd' : ptd.metaKind = .none := Decidable.of_not_not hkd
        split at h
        · cases h
        next hit =>
          have hit' : it = IntType.usize := Decidable.of_not_not hit
          subst hit'
          split at h
          next sd sp si i1 i2 hsd hsp hsi =>
            split at h
            · cases h
            next hsz =>
              split at h
              · cases h
              next hoff =>
                split at h
                · cases h
                next t _ =>
                  split at h
                  · cases h
                  next htmp =>
                    split at h
                    next hi =>
                      simp only [Bool.and_eq_true] at hi
                      have hsz' : sd.size = 8 ∧ sp.size = 16 ∧ si.size = 8 := by
                        simp at hsz
                        first
                          | exact ⟨hsz.1.1, hsz.1.2, hsz.2⟩
                          | exact ⟨hsz.1, hsz.2.1, hsz.2.2⟩
                      have hoff' : offOk sd.off = true ∧ offOk sp.off = true ∧
                          offOk si.off = true := by
                        simp at hoff
                        first
                          | exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩
                          | exact ⟨hoff.1, hoff.2.1, hoff.2.2⟩
                      exact .mk hrv htp hk hti htd hkd' hsd hsp hsi hsz' hoff'
                        (by simpa using htmp) hi.1 hi.2
                    · cases h
          · cases h
  · cases h

theorem checkRefDerefIdx_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkRefDerefIdx Γ st is = some .ok) : LowerRefDerefIdx Γ st is := by
  unfold checkRefDerefIdx at h
  split at h
  next d rv =>
    split at h
    next p elem l hp =>
      split at h
      · exact checkRefDerefIdxPlace_sound hp (Option.some.inj h)
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
