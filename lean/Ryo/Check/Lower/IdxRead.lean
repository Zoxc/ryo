/-
Ryo.Check.Lower.IdxRead — reading an element of a local array (aot.md §C1, M5b's places):
`_d = copy/move _a[_l]`, `_a : [elem; len]` a local, `_l : usize`, `_d : elem` of `n > 0` bytes
(a load width).

What the backend emits (`place.rs` `index` on a `Loc::Slot` base, `addr_into`): the `Escape` of
`_a`'s whole slot (the statement's own scope: `Ref.lean`'s `ownSpec`, `useSpec`), then
`addr t, a` into a temporary, `ptr.index t, t, l, stride` (`stride` the element size), and
`load.wN d, [t + 0]`. L0's index projection checks the bound (UB past `len`) and offsets in
bounds, so its address is below `ADDR_LIMIT`, where R's wrapping offset is the same.

Rule (`LowerIdxRead.mk`): the three instructions, `t` a temporary apart from every local's slot
(`tempApartC`: private at the statement, `EscInSlots`), `_a`'s slot non-empty and covered by
some `Escape` (`hesc`, as `Ref.lean`'s rule), `_d`'s slot private or escaped. The simulation is
`Proofs/Lower/SimIdxRead.lean`.

`checkIdxRead` answers `none` unless the statement reads `_a[_l]` of an array local.
-/
import Ryo.Check.Lower.RefDerefIdx

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerIdxRead (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {d a l : Local} {oa : Operand} {elem : Ty} {len n : Nat} {vi : ValidRange}
      {sd sa si : LocalSlot} {t : Int} {i1 i2 i3 : Insn}
      (ha : operandPlace? oa = some ⟨a, [.index l]⟩)
      (hta : Γ.body.locals[a]? = some (.array elem len))
      (hti : Γ.body.locals[l]? = some (.int IntType.usize vi))
      (htd : Γ.body.locals[d]? = some elem)
      (hn : elem.size? = some n) (hpos : 0 < n) (hwf : elem.wf = true)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsi : Γ.slots[l]? = some si)
      (hsize : sd.size = n ∧ si.size = 8 ∧ 0 < sa.size)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk si.off)
      (htmp : tempApartC Γ t 8 = true)
      (hesc : ∀ k < sa.size, Γ.escaped (sa.off + k) = true)
      (hi1 : addrInsnOk Γ i1 t sa.off = true)
      (hi2 : ptrIndexInsnOk Γ i2 t t si.off elem.size = true)
      (hi3 : loadInsnOk Γ i3 n sd.off t 0 = true) :
      LowerIdxRead Γ (.assign ⟨d, []⟩ (.use oa)) [i1, i2, i3]

/-- The statement's own scope (`Ref.lean`'s `ownSpec`, `useSpec`): the `Escape` of `_a`'s slot. -/
theorem ownSpec_idxRead {Γ : StmtCtx} {d a l : Local} {oa : Operand} {elem : Ty} {len : Nat}
    {sa : LocalSlot} (ha : operandPlace? oa = some ⟨a, [.index l]⟩)
    (hta : Γ.body.locals[a]? = some (.array elem len)) (hsa : Γ.slots[a]? = some sa)
    (hpos : 0 < sa.size) :
    ownSpec Γ (.assign ⟨d, []⟩ (.use oa)) = [.escS sa.off sa.size (Ty.array elem len).align.exp] := by
  cases oa <;> simp [operandPlace?] at ha <;> subst ha <;>
    simp [ownSpec, refPlace?, useSpec, idxPlaceSpec, Operand.local?, operandPlace?, hta, hsa,
      hpos, fieldPath, downcastPath, idxSplit, idxSplit.isFieldProj]

/-- `mk`'s checker. -/
def checkIdxReadPlace (Γ : StmtCtx) (d a l : Local) (is : List Insn) : Verdict :=
  match Γ.body.locals[a]?, Γ.body.locals[l]?, Γ.body.locals[d]? with
  | some (.array elem _), some (.int it _), some td =>
    if it ≠ IntType.usize then .unsupported "index read: index type"
    else if td ≠ elem then .unsupported "index read: types"
    else match elem.size? with
      | none => .unsupported "index read: unsized"
      | some n =>
        if n = 0 then .unsupported "index read: zero-sized"
        else if !elem.wf then .rejected "index read: ill-formed type"
        else if !movWidth n then .unsupported "index read: not a load width"
        else match Γ.slots[d]?, Γ.slots[a]?, Γ.slots[l]?, is with
          | some sd, some sa, some si, [i1, i2, i3] =>
            if !(sd.size == n && si.size == 8 && decide (0 < sa.size)) then
              .rejected "index read: slot sizes"
            else if !(offOk sd.off && offOk sa.off && offOk si.off) then
              .rejected "index read: offsets"
            else if !escAll Γ sa.off sa.size then .rejected "index read: array never escaped"
            else match ptrIndexDst Γ i1 with
              | none => .unsupported "index read: instruction form"
              | some t =>
                if !tempApartC Γ t 8 then .unsupported "index read: temporary"
                else if addrInsnOk Γ i1 t sa.off && ptrIndexInsnOk Γ i2 t t si.off elem.size &&
                    loadInsnOk Γ i3 n sd.off t 0 then .ok
                else .unsupported "index read: instruction form"
          | _, _, _, _ => .unsupported "index read: slots or instruction count"
  | _, _, _ => .unsupported "index read: types"

/-- The family's checker (see the module comment). -/
def checkIdxRead (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use oa) =>
    match operandPlace? oa with
    | some ⟨a, [.index l]⟩ =>
      match Γ.body.locals[a]? with
      | some (.array ..) => some (checkIdxReadPlace Γ d a l is)
      | _ => none
    | _ => none
  | _ => none

theorem checkIdxReadPlace_sound {Γ : StmtCtx} {d a l : Local} {oa : Operand} {is : List Insn}
    (ha : operandPlace? oa = some ⟨a, [.index l]⟩) (h : checkIdxReadPlace Γ d a l is = .ok) :
    LowerIdxRead Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkIdxReadPlace at h
  split at h
  next elem len it vi td hta hti htd =>
    split at h
    · cases h
    next hit =>
      have hit' : it = IntType.usize := Decidable.of_not_not hit
      subst hit'
      split at h
      · cases h
      next hty =>
        have hty' : td = elem := Decidable.of_not_not hty
        subst hty'
        split at h
        · cases h
        next n hn =>
          split at h
          · cases h
          next hn0 =>
            split at h
            · cases h
            next hwf =>
              have hwf' : td.wf = true := by simpa using hwf
              split at h
              · cases h
              next =>
                split at h
                next sd sa si i1 i2 i3 hsd hsa hsi =>
                  split at h
                  · cases h
                  next hsz =>
                    split at h
                    · cases h
                    next hoff =>
                      split at h
                      · cases h
                      next hesc =>
                        split at h
                        · cases h
                        next t _ =>
                          split at h
                          · cases h
                          next htmp =>
                            split at h
                            next hi =>
                              simp only [Bool.and_eq_true] at hi
                              have hsz' : sd.size = n ∧ si.size = 8 ∧ 0 < sa.size := by
                                simp at hsz
                                first
                                  | exact ⟨hsz.1.1, hsz.1.2, Nat.pos_of_ne_zero hsz.2⟩
                                  | exact ⟨hsz.1.1, hsz.1.2, hsz.2⟩
                                  | exact ⟨hsz.1, hsz.2.1, Nat.pos_of_ne_zero hsz.2.2⟩
                                  | exact ⟨hsz.1, hsz.2.1, hsz.2.2⟩
                              have hoff' : offOk sd.off = true ∧ offOk sa.off = true ∧
                                  offOk si.off = true := by
                                simp at hoff
                                first
                                  | exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩
                                  | exact ⟨hoff.1, hoff.2.1, hoff.2.2⟩
                              exact .mk ha hta hti htd hn (Nat.pos_of_ne_zero hn0) hwf' hsd hsa
                                hsi hsz' hoff' (by simpa using htmp)
                                (escAll_spec (by simpa using hesc)) hi.1.1 hi.1.2 hi.2
                            · cases h
                · cases h
  · cases h

theorem checkIdxRead_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkIdxRead Γ st is = some .ok) : LowerIdxRead Γ st is := by
  unfold checkIdxRead at h
  split at h
  next d oa =>
    split at h
    next a l hp =>
      split at h
      · exact checkIdxReadPlace_sound hp (Option.some.inj h)
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
