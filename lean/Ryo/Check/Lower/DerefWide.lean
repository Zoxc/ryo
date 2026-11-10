/-
Ryo.Check.Lower.DerefWide — `Deref.lean`'s `load` and `store` through a wide pointer held in a
local (aot.md §C1, M5b): `_d = copy (*_p).f₁.….fₖ` and `(*_p).f₁.….fₖ = copy _a` with `_p` of
reference or raw pointer type whose metadata is a length or a vtable (`pt.metaKind ≠ .none`,
16 bytes), `k ≥ 1` sized fields of the pointee (a struct with an unsized tail, `fieldPath`).

The backend (`place.rs` `deref`) makes `*_p` the memory operand `Loc::Mem { p: sp.off, k }` for
a wide `_p` too: its data pointer is the slot's first 8 bytes, which `load`/`store`'s `.mem`
operand reads. So the rules are `Deref.lean`'s with `sp.size = 16` and a non-empty field list
(the place L0 reaches is the data pointer offset by the fields', `runOn_evalPlace_derefWideF`).

`checkDerefWide` answers `none` unless `st` reads or writes `(*_p).fields` with `_p` a wide
pointer local; it runs before `checkDeref`, which reports those as "deref: wide pointer".
-/
import Ryo.Check.Lower.Deref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerDerefWide (Γ : StmtCtx) : Statement → List Insn → Prop where
  | load {d p : Local} {oa : Operand} {pointee ty : Ty} {fe : ProjElem} {fields : List ProjElem}
      {pt : PtrType} {valid : ValidRange} {off n : Nat} {sd sp : LocalSlot} {i : Insn}
      (ha : operandPlace? oa = some ⟨p, .deref pointee :: fe :: fields⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
      (hpath : fieldPath pointee (fe :: fields) = some (off, ty))
      (htd : Γ.body.locals[d]? = some ty)
      (hn : ty.size? = some n) (hpos : 0 < n) (hwf : ty.wf = true)
      (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp)
      (hsize : sd.size = n ∧ sp.size = 16)
      (hoff : offOk sd.off ∧ offOk sp.off ∧ offOk (off : Int))
      (hi : loadInsnOk Γ i n sd.off sp.off off = true) :
      LowerDerefWide Γ (.assign ⟨d, []⟩ (.use oa)) [i]
  | store {p a : Local} {oa : Operand} {pointee ty : Ty} {fe : ProjElem} {fields : List ProjElem}
      {pt : PtrType} {valid : ValidRange} {off n : Nat} {sp sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
      (hpath : fieldPath pointee (fe :: fields) = some (off, ty))
      (hta : Γ.body.locals[a]? = some ty)
      (hn : ty.size? = some n) (hpos : 0 < n) (hwf : ty.wf = true)
      (hsp : Γ.slots[p]? = some sp) (hsa : Γ.slots[a]? = some sa)
      (hsize : sa.size = n ∧ sp.size = 16)
      (hoff : offOk sp.off ∧ offOk sa.off ∧ offOk (off : Int))
      (hi : storeInsnOk Γ i n sp.off off sa.off = true) :
      LowerDerefWide Γ (.assign ⟨p, .deref pointee :: fe :: fields⟩ (.use oa)) [i]

/-- `load`'s checker for `_d = copy/move (*_p).fe.fields`, `_p` wide. -/
def checkDerefWideLoad (Γ : StmtCtx) (d p : Local) (pointee : Ty) (fe : ProjElem)
    (fields : List ProjElem) (is : List Insn) : Verdict :=
  match fieldPath pointee (fe :: fields) with
  | none => .unsupported ("deref wide: then " ++ projWhy (fe :: fields))
  | some (off, ty) =>
    match Γ.body.locals[d]? with
    | none => .rejected "deref wide: no destination local"
    | some td =>
      if td != ty then .unsupported "deref wide: types"
      else match ty.size? with
        | none => .unsupported "deref wide: unsized"
        | some n =>
          if n = 0 then .unsupported "deref wide: zero-sized"
          else if !ty.wf then .rejected "deref wide: ill-formed type"
          else if !movWidth n then .unsupported "deref wide: not a load width"
          else match Γ.slots[d]?, Γ.slots[p]?, is with
            | some sd, some sp, [i] =>
              if !(sd.size == n && sp.size == 16) then .rejected "deref wide: slot sizes"
              else if !(offOk sd.off && offOk sp.off && offOk (off : Int)) then
                .rejected "deref wide: offsets"
              else if loadInsnOk Γ i n sd.off sp.off off then .ok
              else .unsupported "deref wide: instruction form"
            | _, _, _ => .unsupported "deref wide: slots or instruction count"

/-- `store`'s checker for `(*_p).fe.fields = copy/move _a`, `_p` wide. -/
def checkDerefWideStore (Γ : StmtCtx) (p : Local) (pointee : Ty) (fe : ProjElem)
    (fields : List ProjElem) (a : Local) (is : List Insn) : Verdict :=
  match fieldPath pointee (fe :: fields) with
  | none => .unsupported ("deref wide store: then " ++ projWhy (fe :: fields))
  | some (off, ty) =>
    match Γ.body.locals[a]? with
    | none => .rejected "deref wide store: no source local"
    | some ta =>
      if ta != ty then .unsupported "deref wide store: types"
      else match ty.size? with
        | none => .unsupported "deref wide store: unsized"
        | some n =>
          if n = 0 then .unsupported "deref wide store: zero-sized"
          else if !ty.wf then .rejected "deref wide store: ill-formed type"
          else if !movWidth n then .unsupported "deref wide store: not a store width"
          else match Γ.slots[p]?, Γ.slots[a]?, is with
            | some sp, some sa, [i] =>
              if !(sa.size == n && sp.size == 16) then .rejected "deref wide store: slot sizes"
              else if !(offOk sp.off && offOk sa.off && offOk (off : Int)) then
                .rejected "deref wide store: offsets"
              else if storeInsnOk Γ i n sp.off off sa.off then .ok
              else .unsupported "deref wide store: instruction form"
            | _, _, _ => .unsupported "deref wide store: slots or instruction count"

/-- `_p` is a local holding a wide pointer. -/
def widePtrLocal (Γ : StmtCtx) (p : Local) : Bool :=
  match Γ.body.locals[p]? with
  | some (.ptr pt _) => !decide (pt.metaKind = .none)
  | _ => false

theorem widePtrLocal_spec {Γ : StmtCtx} {p : Local} (h : widePtrLocal Γ p = true) :
    ∃ pt valid, Γ.body.locals[p]? = some (.ptr pt valid) ∧ pt.metaKind ≠ .none := by
  unfold widePtrLocal at h
  split at h
  next pt valid htp => exact ⟨pt, valid, htp, by simpa using h⟩
  · cases h

/-- The family's checker (see the module comment). -/
def checkDerefWide (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use oa) =>
    match operandPlace? oa with
    | some ⟨p, .deref pointee :: fe :: fields⟩ =>
      if widePtrLocal Γ p then some (checkDerefWideLoad Γ d p pointee fe fields is) else none
    | _ => none
  | .assign ⟨p, .deref pointee :: fe :: fields⟩ (.use oa) =>
    match oa.local? with
    | some a =>
      if widePtrLocal Γ p then some (checkDerefWideStore Γ p pointee fe fields a is) else none
    | none => none
  | _ => none

theorem checkDerefWideLoad_sound {Γ : StmtCtx} {d p : Local} {oa : Operand} {pointee : Ty}
    {fe : ProjElem} {fields : List ProjElem} {is : List Insn}
    (ha : operandPlace? oa = some ⟨p, .deref pointee :: fe :: fields⟩)
    (hw : widePtrLocal Γ p = true)
    (h : checkDerefWideLoad Γ d p pointee fe fields is = .ok) :
    LowerDerefWide Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  obtain ⟨pt, valid, htp, hk⟩ := widePtrLocal_spec hw
  unfold checkDerefWideLoad at h
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
              · cases h
              next =>
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
                        exact .load ha htp hk hpath htd hn (Nat.pos_of_ne_zero hn0) hwf'
                          hsd hsp (by simpa using hsz)
                          (by simp at hoff; exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩) hi
                      · cases h
                · cases h

theorem checkDerefWideStore_sound {Γ : StmtCtx} {p a : Local} {oa : Operand} {pointee : Ty}
    {fe : ProjElem} {fields : List ProjElem} {is : List Insn} (ha : oa.local? = some a)
    (hw : widePtrLocal Γ p = true)
    (h : checkDerefWideStore Γ p pointee fe fields a is = .ok) :
    LowerDerefWide Γ (.assign ⟨p, .deref pointee :: fe :: fields⟩ (.use oa)) is := by
  obtain ⟨pt, valid, htp, hk⟩ := widePtrLocal_spec hw
  unfold checkDerefWideStore at h
  split at h
  · cases h
  next off ty hpath =>
    split at h
    · cases h
    next ta hta =>
      split at h
      · cases h
      next hty =>
        have e : ta = ty := by simpa using hty
        rw [e] at hta
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
                        exact .store ha htp hk hpath hta hn (Nat.pos_of_ne_zero hn0) hwf'
                          hsp hsa (by simpa using hsz)
                          (by simp at hoff; exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩) hi
                      · cases h
                · cases h

theorem checkDerefWide_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkDerefWide Γ st is = some .ok) : LowerDerefWide Γ st is := by
  unfold checkDerefWide at h
  split at h
  next d oa =>
    split at h
    next p pointee fe fields hp =>
      split at h
      next hw => exact checkDerefWideLoad_sound hp hw (Option.some.inj h)
      · cases h
    · cases h
  next p pointee fe fields oa =>
    split at h
    next a ha =>
      split at h
      next hw => exact checkDerefWideStore_sound ha hw (Option.some.inj h)
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
