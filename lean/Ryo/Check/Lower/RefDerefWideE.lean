/-
Ryo.Check.Lower.RefDerefWideE — `RefDerefWide.lean`'s `mk` (`_d = &(*_p)` / `&raw (*_p)`, `_p`
a wide pointer local) with `_d`'s slot possibly escaped (aot.md §C1, M5b).

The backend's two `mov.w64` (`d, p` then `d + 8, p + 8`) write `_d`'s 16 bytes in two frame
writes; the simulation (`Proofs/Lower/SimRefDerefWideE.lean`) shows them one write of the
concatenation (`writeFrame_append`), which `FnRel.dstWrite` relates whether `_d` is private or
escaped. `_p` must be private (no `Escape` of the function covers it, `privOk`): the second
`mov` reads `_p`'s second half after the first wrote `_d`'s first, and a private byte apart
from the written range is unchanged. `_p`'s and `_d`'s slots are apart.

`checkRefDerefWideE` answers `some .ok` or `none`; it runs before `checkRefDerefWide`, so that a
reborrow it does not take keeps that family's bucket.
-/
import Ryo.Check.Lower.RefDerefWide

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerRefDerefWideE (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {d p : Local} {rv : Rvalue} {pointee : Ty} {pt ptd : PtrType} {valid vd : ValidRange}
      {sd sp : LocalSlot} {i1 i2 : Insn}
      (hrv : refPlace? rv = some ⟨p, [.deref pointee]⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd))
      (hshape : sameMetaShape ptd.metaKind pt.metaKind = true)
      (hwf : (Ty.ptr pt valid).wf = true)
      (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp)
      (hsize : sd.size = 16 ∧ sp.size = 16)
      (hoff : offOk sd.off ∧ offOk (sd.off + 8) ∧ offOk sp.off ∧ offOk (sp.off + 8))
      (hpp : ∀ k < sp.size, Γ.escaped (sp.off + k) = false)
      (hap : sd.off + sd.size ≤ sp.off ∨ sp.off + sp.size ≤ sd.off)
      (hi1 : movInsnOk Γ i1 8 sd.off sp.off = true)
      (hi2 : movInsnOk Γ i2 8 (sd.off + 8) (sp.off + 8) = true) :
      LowerRefDerefWideE Γ (.assign ⟨d, []⟩ rv) [i1, i2]

/-- The family's checker (see the module comment). -/
def checkRefDerefWideE (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st, is with
  | .assign ⟨d, []⟩ rv, [i1, i2] =>
    match refPlace? rv with
    | some ⟨p, [.deref _]⟩ =>
      match Γ.body.locals[p]?, Γ.body.locals[d]?, Γ.slots[d]?, Γ.slots[p]? with
      | some (.ptr pt valid), some (.ptr ptd _), some sd, some sp =>
        if pt.metaKind ≠ .none ∧ sameMetaShape ptd.metaKind pt.metaKind = true ∧
            (Ty.ptr pt valid).wf = true ∧ sd.size = 16 ∧ sp.size = 16 ∧
            offOk sd.off = true ∧ offOk (sd.off + 8) = true ∧ offOk sp.off = true ∧
            offOk (sp.off + 8) = true ∧ privOk Γ sp.off sp.size = true ∧
            (sd.off + sd.size ≤ sp.off ∨ sp.off + sp.size ≤ sd.off) ∧
            movInsnOk Γ i1 8 sd.off sp.off = true ∧
            movInsnOk Γ i2 8 (sd.off + 8) (sp.off + 8) = true then some .ok
        else none
      | _, _, _, _ => none
    | _ => none
  | _, _ => none

theorem checkRefDerefWideE_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkRefDerefWideE Γ st is = some .ok) : LowerRefDerefWideE Γ st is := by
  unfold checkRefDerefWideE at h
  split at h
  next d rv i1 i2 =>
    split at h
    next p pointee hrv =>
      split at h
      next pt valid ptd vd sd sp htp htd hsd hsp =>
        split at h
        next hc =>
          obtain ⟨hk, hsh, hwf, h1, h2, h3, h4, h5, h6, hpv, hap, hi1, hi2⟩ := hc
          exact .mk hrv htp hk htd hsh hwf hsd hsp ⟨h1, h2⟩ ⟨h3, h4, h5, h6⟩ (privOk_spec hpv)
            hap hi1 hi2
        next => cases h
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
