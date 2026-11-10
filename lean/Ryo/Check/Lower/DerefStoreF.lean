/-
Ryo.Check.Lower.DerefStoreF — `Deref.lean`'s `store` with a field of a local as the source
(aot.md §C1, M5b's places): `(*_p).f₁.….fₖ = copy/move _a.g₁.….gⱼ`, `_p` a thin pointer local,
`j ≥ 1` sized fields of `_a` (`fieldPath`), the two places of one type `ty` of `n` bytes.

The backend's source operand is the field's slot `sa.off + offa` (`operand_slot` of a field
place: `Loc::Slot`), so the instruction is `store.wN [sp.off + off], sa.off + offa`
(`storeInsnOk`). L0 loads the field (`runOn_evalOperand_field`) and stores its re-encoding
through the pointer; R reads the field's bytes from `_a`'s slot (`readLocal_sub_inj`). The
simulation is `Proofs/Lower/SimDerefStoreF.lean`.

`checkDerefStoreF` answers `none` unless the statement has that shape (a deref destination, a
projected local source); `checkDeref` declines it (its store needs a whole-local source).
-/
import Ryo.Check.Lower.Deref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerDerefStoreF (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {p a : Local} {oa : Operand} {pointee ty ta : Ty} {fields projs : List ProjElem}
      {pt : PtrType} {valid : ValidRange} {off offa n : Nat} {sp sa : LocalSlot} {i : Insn}
      (ha : operandPlace? oa = some ⟨a, projs⟩)
      (hta : Γ.body.locals[a]? = some ta) (hpa : fieldPath ta projs = some (offa, ty))
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (hn : ty.size? = some n) (hpos : 0 < n) (hwf : ty.wf = true)
      (hsp : Γ.slots[p]? = some sp) (hsa : Γ.slots[a]? = some sa)
      (hsize : sp.size = 8 ∧ offa + n ≤ sa.size)
      (hoff : offOk sp.off ∧ offOk (sa.off + offa) ∧ offOk (off : Int))
      (hi : storeInsnOk Γ i n sp.off off (sa.off + offa) = true) :
      LowerDerefStoreF Γ (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) [i]

/-- `mk`'s checker. -/
def checkDerefStoreFPlace (Γ : StmtCtx) (p : Local) (pointee : Ty) (fields : List ProjElem)
    (a : Local) (projs : List ProjElem) (is : List Insn) : Verdict :=
  match Γ.body.locals[p]?, Γ.body.locals[a]? with
  | some (.ptr pt _), some ta =>
    if pt.metaKind = .none then
      match fieldPath pointee fields, fieldPath ta projs with
      | some (off, ty), some (offa, tya) =>
        if tya != ty then .unsupported "deref store field: types"
        else match ty.size? with
          | none => .unsupported "deref store field: unsized"
          | some n =>
            if n = 0 then .unsupported "deref store field: zero-sized"
            else if !ty.wf then .rejected "deref store field: ill-formed type"
            else if !movWidth n then .unsupported "deref store field: not a store width"
            else match Γ.slots[p]?, Γ.slots[a]?, is with
              | some sp, some sa, [i] =>
                if !(sp.size == 8 && decide (offa + n ≤ sa.size)) then
                  .rejected "deref store field: slot sizes"
                else if !(offOk sp.off && offOk (sa.off + offa) && offOk (off : Int)) then
                  .rejected "deref store field: offsets"
                else if storeInsnOk Γ i n sp.off off (sa.off + offa) then .ok
                else .unsupported "deref store field: instruction form"
              | _, _, _ => .unsupported "deref store field: slots or instruction count"
      | none, _ => .unsupported ("store " ++ derefWhy fields)
      | _, none => .unsupported ("deref store field: source " ++ projWhy projs)
    else .unsupported "deref store field: wide pointer"
  | _, _ => .unsupported "deref store field: not a pointer local"

/-- The family's checker (see the module comment). -/
def checkDerefStoreF (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨p, .deref pointee :: fields⟩ (.use oa) =>
    match operandPlace? oa with
    | some ⟨a, projs⟩ =>
      if projs.isEmpty then none else some (checkDerefStoreFPlace Γ p pointee fields a projs is)
    | none => none
  | _ => none

theorem checkDerefStoreFPlace_sound {Γ : StmtCtx} {p a : Local} {oa : Operand} {pointee : Ty}
    {fields projs : List ProjElem} {is : List Insn} (ha : operandPlace? oa = some ⟨a, projs⟩)
    (h : checkDerefStoreFPlace Γ p pointee fields a projs is = .ok) :
    LowerDerefStoreF Γ (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) is := by
  unfold checkDerefStoreFPlace at h
  split at h
  next pt valid ta htp hta =>
    split at h
    next hk =>
      split at h
      next off ty offa tya hpath hpa =>
        split at h
        · cases h
        next hty =>
          have e : tya = ty := by simpa using hty
          rw [e] at hpa
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
                · cases h
                next =>
                  split at h
                  next sp sa i hsp hsa =>
                    split at h
                    · cases h
                    next hsz =>
                      split at h
                      · cases h
                      next hoff =>
                        split at h
                        next hi =>
                          have hsz' : sp.size = 8 ∧ offa + n ≤ sa.size := by simpa using hsz
                          have hoff' : offOk sp.off = true ∧ offOk (sa.off + offa) = true ∧
                              offOk (off : Int) = true := by
                            simp at hoff
                            first
                              | exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩
                              | exact ⟨hoff.1, hoff.2.1, hoff.2.2⟩
                          exact .mk ha hta hpa htp hk hpath hn (Nat.pos_of_ne_zero hn0) hwf' hsp
                            hsa hsz' hoff' hi
                        · cases h
                  · cases h
      · cases h
      · cases h
    · cases h
  · cases h

theorem checkDerefStoreF_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkDerefStoreF Γ st is = some .ok) : LowerDerefStoreF Γ st is := by
  unfold checkDerefStoreF at h
  split at h
  next p pointee fields oa =>
    split at h
    next a projs hp =>
      split at h
      · cases h
      · exact checkDerefStoreFPlace_sound hp (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
