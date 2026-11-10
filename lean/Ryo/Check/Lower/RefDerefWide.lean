/-
Ryo.Check.Lower.RefDerefWide — the lowering rule for reborrowing a wide pointer held in a local
(aot.md §C1, M5b's places): `_d = &(*_p)` / `&raw (*_p)` with `_p` a slice, `str` or `dyn`
pointer, and its checker.

What the backend emits (`backend/src/lower/rvalue.rs` `address_of`, `place.rs` `deref`,
`addr_into`): the place `*_p`, `_p` a local holding a wide pointer, is `Loc::Mem { p: sp.off,
k: 0 }` with metadata `sp.off + 8`; `address_of` writes the address by `addr_into` (`mov.w64 d,
p` at offset 0) and then the metadata by `mov(d + META, m, PTR)` (`mov.w64 d+8, p+8`). That is a
copy of `_p`'s 16 bytes into `_d` in `mov` pieces, which is how the rule states it: as
`Agg.lean`'s one-field copy (`AggField` of the operand `copy _p` at `_p`'s type, its pieces
`srcPieces`), so a `[8, 8]` split and a single `mov.w128` are both covered. No `Escape`: the
pointee is not a frame slot.

Rule (`LowerRefDerefWide.mk`): `_d = &(*_p)` or `&raw (*_p)` (no projection after the deref),
`_p`'s L0 type `.ptr pt valid` with `pt.metaKind ≠ .none`, `_d : .ptr ptd vd` whose metadata
kind encodes like `pt`'s (`sameMetaShape`), `_d`'s slot 16 bytes and private, the copy of `_p`
(`AggField`: `_p`'s type well-formed, its slot 16 bytes apart from `_d`'s) checked instruction
by instruction (`piecesOk`). L0 loads `_p`'s 16 bytes, decodes the pointer (metadata included),
and stores its encoding at `_d`'s type, which is its encoding at `_p`'s, below the loaded bytes
(`Ryo.Proofs.Lower.lift_refDerefWide`).

Rule `field`: `_d = &(*_p).f₁.….fₖ` (or `&raw`) with `_p` wide and the fields sized
(`fieldPath`), `_d` a thin pointer: `place.rs` `field` drops the metadata for a sized field, so
the place is `[sp.off + off]` and `addr_into` writes `mov.w64 d, p` (`off = 0`) or
`ptr_add d, p, off` (`RefDeref.lean`'s `refDerefInsnOk`) from the data half of `_p`'s 16-byte
slot. L0's field projection likewise drops the metadata (`projectPlace`'s `.field`).

Not covered: the unsized tail of a struct (`ref deref wide: unsized tail field`: its offset may
depend on the vtable's alignment); escaped destinations of `mk`.

`checkRefDerefWide` claims `&(*_p)…`/`&raw (*_p)…` into a whole local with `_p` a wide pointer
local and is `none` otherwise; it must run before `checkRefDeref`, which claims every deref place
and reports wide pointers as unsupported.
-/
import Ryo.Check.Lower.Agg
import Ryo.Check.Lower.Wide
import Ryo.Check.Lower.Ref
import Ryo.Check.Lower.RefDeref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerRefDerefWide (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {d p : Local} {rv : Rvalue} {pointee : Ty} {pt ptd : PtrType} {valid vd : ValidRange}
      {sd : LocalSlot} {a : Local} {so : Int} {ws : List Nat} {is : List Insn}
      (hrv : refPlace? rv = some ⟨p, [.deref pointee]⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd))
      (hshape : sameMetaShape ptd.metaKind pt.metaKind = true)
      (hsd : Γ.slots[d]? = some sd) (hsz : sd.size = 16)
      (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
      (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
      (hf : AggField Γ sd (.copy ⟨p, []⟩) 0 (.ptr pt valid) (.slot a so ws))
      (hi : piecesOk Γ is (srcPieces sd.off (.slot a so ws)) = true) :
      LowerRefDerefWide Γ (.assign ⟨d, []⟩ rv) is
  | field {d p : Local} {rv : Rvalue} {pointee ty : Ty} {fe : ProjElem} {fields : List ProjElem}
      {pt ptd : PtrType} {valid vd : ValidRange} {off : Nat} {sd sp : LocalSlot} {i : Insn}
      {is : List Insn}
      (hrv : refPlace? rv = some ⟨p, .deref pointee :: fe :: fields⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
      (hpath : fieldPath pointee (fe :: fields) = some (off, ty))
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
      (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp)
      (hsize : sd.size = 8 ∧ sp.size = 16) (hoff : offOk sd.off ∧ offOk sp.off)
      (his : is = [i]) (hi : refDerefInsnOk Γ i sd.off sp.off off = true) :
      LowerRefDerefWide Γ (.assign ⟨d, []⟩ rv) is

/-- `field`'s checker for `_d = &(*_p).fields` with `_p` wide and the fields sized. -/
def checkRefDerefWideField (Γ : StmtCtx) (d p : Local) (pointee : Ty) (fe : ProjElem)
    (fields : List ProjElem) (is : List Insn) : Verdict :=
  match Γ.body.locals[p]?, Γ.body.locals[d]? with
  | some (.ptr pt _), some (.ptr ptd _) =>
    if pt.metaKind = .none then .unsupported "ref deref wide field: thin pointer"
    else if ptd.metaKind ≠ .none then .unsupported "ref deref wide: unsized tail field"
    else match fieldPath pointee (fe :: fields) with
      | none => .unsupported ("ref deref wide " ++ derefWhy (fe :: fields))
      | some (off, _) =>
        match Γ.slots[d]?, Γ.slots[p]?, is with
        | some sd, some sp, [i] =>
          if !(sd.size == 8 && sp.size == 16) then .rejected "ref deref wide field: slot sizes"
          else if !(offOk sd.off && offOk sp.off) then .rejected "ref deref wide field: offsets"
          else if refDerefInsnOk Γ i sd.off sp.off off then .ok
          else .unsupported "ref deref wide field: instruction form"
        | _, _, _ => .unsupported "ref deref wide field: slots or instruction count"
  | _, _ => .unsupported "ref deref wide field: not pointers"

/-- `mk`'s checker for `_d = &(*_p)` / `&raw (*_p)`. -/
def checkRefDerefWidePlace (Γ : StmtCtx) (d p : Local) (is : List Insn) : Verdict :=
  match Γ.body.locals[p]?, Γ.body.locals[d]? with
  | some (.ptr pt valid), some (.ptr ptd _) =>
    if pt.metaKind = .none then .unsupported "ref deref wide: thin pointer"
    else if !sameMetaShape ptd.metaKind pt.metaKind then
      .unsupported "ref deref wide: metadata kinds"
    else match Γ.slots[d]? with
      | none => .rejected "ref deref wide: no destination slot"
      | some sd =>
        if sd.size != 16 then .rejected "ref deref wide: slot size"
        else if !(offOk sd.off && offOk (sd.off + sd.size)) then
          .rejected "ref deref wide: offsets"
        else if !privOk Γ sd.off sd.size then .unsupported "ref deref wide: escaped destination"
        else match guessSrc Γ "ref deref wide" sd.off (.copy ⟨p, []⟩) (.ptr pt valid) is with
          | .error why => .unsupported why
          | .ok g =>
            match g.1 with
            | .slot a so ws =>
              if !aggFieldOk Γ sd (.copy ⟨p, []⟩) 0 (.ptr pt valid) (.slot a so ws) then
                .unsupported "ref deref wide: source"
              else if piecesOk Γ is (srcPieces sd.off (.slot a so ws)) then .ok
              else .unsupported "ref deref wide: instruction form"
            | _ => .unsupported "ref deref wide: source"
  | _, _ => .unsupported "ref deref wide: not pointers"

/-- The family's checker: `none` unless `st` is `_d = &(*_p)…` or `&raw (*_p)…` with `_p` a
wide pointer local. -/
def checkRefDerefWide (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ rv =>
    match refPlace? rv with
    | some ⟨p, [.deref _]⟩ =>
      if isWidePtr Γ.body.locals[p]? then some (checkRefDerefWidePlace Γ d p is) else none
    | some ⟨p, .deref pointee :: fe :: fields⟩ =>
      if isWidePtr Γ.body.locals[p]? then
        some (checkRefDerefWideField Γ d p pointee fe fields is)
      else none
    | _ => none
  | _ => none

theorem checkRefDerefWidePlace_sound {Γ : StmtCtx} {d p : Local} {rv : Rvalue} {pointee : Ty}
    {is : List Insn} (hrv : refPlace? rv = some ⟨p, [.deref pointee]⟩)
    (h : checkRefDerefWidePlace Γ d p is = .ok) :
    LowerRefDerefWide Γ (.assign ⟨d, []⟩ rv) is := by
  unfold checkRefDerefWidePlace at h
  split at h
  next pt valid ptd vd htp htd =>
    split at h
    · cases h
    next hk =>
      split at h
      · cases h
      next hsh =>
        split at h
        · cases h
        next sd hsd =>
          split at h
          · cases h
          next hsz =>
            split at h
            · cases h
            next hoff =>
              split at h
              · cases h
              next hpriv =>
                split at h
                · cases h
                next g _ =>
                  split at h
                  next a so ws _ =>
                    split at h
                    · cases h
                    next hf =>
                      split at h
                      next hi =>
                        exact .mk hrv htp hk htd (by simpa using hsh) hsd (by simpa using hsz)
                          (by simpa using hoff) (privOk_spec (by simpa using hpriv))
                          (aggFieldOk_spec (by simpa using hf)) hi
                      · cases h
                  all_goals cases h
  · cases h

theorem checkRefDerefWideField_sound {Γ : StmtCtx} {d p : Local} {rv : Rvalue} {pointee : Ty}
    {fe : ProjElem} {fields : List ProjElem} {is : List Insn}
    (hrv : refPlace? rv = some ⟨p, .deref pointee :: fe :: fields⟩)
    (h : checkRefDerefWideField Γ d p pointee fe fields is = .ok) :
    LowerRefDerefWide Γ (.assign ⟨d, []⟩ rv) is := by
  unfold checkRefDerefWideField at h
  split at h
  next pt valid ptd vd htp htd =>
    split at h
    · cases h
    next hk =>
      split at h
      · cases h
      next hkd =>
        have hkd' : ptd.metaKind = .none := by simpa using hkd
        split at h
        · cases h
        next off ty hpath =>
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
                  exact .field hrv htp hk hpath htd hkd' hsd hsp (by simpa using hsz)
                    (by simpa using hoff) rfl hi
                · cases h
          · cases h
  · cases h

theorem checkRefDerefWide_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkRefDerefWide Γ st is = some .ok) : LowerRefDerefWide Γ st is := by
  unfold checkRefDerefWide at h
  split at h
  next d rv =>
    split at h
    next p pointee hp =>
      split at h
      · exact checkRefDerefWidePlace_sound hp (Option.some.inj h)
      · cases h
    next p pointee fe fields hp =>
      split at h
      · exact checkRefDerefWideField_sound hp (Option.some.inj h)
      · cases h
    all_goals cases h
  · cases h

end Ryo.Check.Lower
