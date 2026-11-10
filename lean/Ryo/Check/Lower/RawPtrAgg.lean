/-
Ryo.Check.Lower.RawPtrAgg — `AggregateKind::RawPtr` (`ptr::from_raw_parts`): a raw pointer
built from a data pointer and metadata (aot.md §C1, M5b), and its checker.

What the backend emits (`backend/src/lower/adt.rs` `aggregate`, `RawPtr`): `operand_into` of
the data operand at `_d`'s slot, then, for a wide `_d` (`ScalarPair`), `operand_into` of the
metadata at the second scalar's offset (8); for a thin `_d` (`Scalar`) nothing for the
metadata (a ZST). These are `Agg.lean`'s fields, so the rule states them as `AggFields` of the
two operands at offsets 0 and 8, with `aggPieces` checked instruction by instruction.

L0 (`evalRvalue`'s `rawPtr` case, MiniRust `ConstructWidePointer`): the data value `.ptr p` and
the metadata `md`, `_d : .ptr ptd vd`; the result `.ptr ⟨p.thin, m⟩` with `m` none (thin),
`.elementCount n.toNat` (`md = .int n`) or `.vtablePointer vt.thin` (`md = .ptr vt`), and
`checkValue` (only UB). Its encoding at `_d`'s type is the data's encoding (`encodePtr p.thin`)
followed by the metadata's at the field type (`encodeBits 8` of the length, `encodePtr` of the
vtable), which is `writeFields` of the two fields (`Ryo/Proofs/Lower/SimRawPtrAgg.lean`).

Rule (`LowerRawPtrAgg.mk`): `_d = aggregate rawPtr ops` into a whole private local
`_d : .ptr ptd vd` (slot of the type's size), the fields `[(0, t0), (8, t1)]` with `t0` a thin
pointer type (`thinPtrTy`) and `t1` the metadata's type for `ptd`'s kind (`rawPtrMetaOk`: a
ZST for thin, `usize` for a length, a thin pointer for a vtable), `AggFields` of `ops` at them.

`checkRawPtrAgg` claims every `rawPtr` aggregate into a whole local and is `none` otherwise; it
must run before `checkAgg`, which reports them as `aggregate: raw pointer`.
-/
import Ryo.Check.Lower.Agg

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- A thin pointer type. -/
def thinPtrTy : Ty → Bool
  | .ptr p _ => p.metaKind == .none
  | _ => false

/-- The metadata operand's type for a raw pointer of metadata kind `k`. -/
def rawPtrMetaOk : PointerMetaKind → Ty → Bool
  | .none, t => t.size? == some 0
  | .elementCount, .int it _ => it == ⟨false, 8⟩
  | .vtablePointer _, t => thinPtrTy t
  | _, _ => false

/-- The two fields of a raw pointer aggregate. -/
abbrev rawPtrFields (t0 t1 : Ty) : List (Nat × Ty) := [(0, t0), (8, t1)]

inductive LowerRawPtrAgg (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {d : Local} {ops : List Operand} {ptd : PtrType} {vd : ValidRange} {t0 t1 : Ty}
      {sd : LocalSlot} {srcs : List AggSrc} {is : List Insn}
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd))
      (hsz : (Ty.ptr ptd vd).size? = some sd.size)
      (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
      (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
      (h0 : thinPtrTy t0 = true) (h1 : rawPtrMetaOk ptd.metaKind t1 = true)
      (hf : AggFields Γ sd ops (rawPtrFields t0 t1) srcs)
      (hi : piecesOk Γ is (aggPieces sd.off (rawPtrFields t0 t1) srcs) = true) :
      LowerRawPtrAgg Γ (.assign ⟨d, []⟩ (.aggregate .rawPtr ops)) is

/-- An operand's type, for guessing the fields (not trusted: `AggFields` checks it). -/
def operandTy? (Γ : StmtCtx) : Operand → Option Ty
  | .copy ⟨a, []⟩ | .move ⟨a, []⟩ => Γ.body.locals[a]?
  | .const _ t => some t
  | _ => none

/-- `mk`'s checker. -/
def checkRawPtrAggOps (Γ : StmtCtx) (d : Local) (ops : List Operand) (is : List Insn) :
    Verdict :=
  match ops with
  | [opd, opm] =>
    match Γ.body.locals[d]?, operandTy? Γ opd, operandTy? Γ opm with
    | some (.ptr ptd vd), some t0, some t1 =>
      if !thinPtrTy t0 then .unsupported "raw pointer aggregate: data type"
      else if !rawPtrMetaOk ptd.metaKind t1 then .unsupported "raw pointer aggregate: metadata type"
      else match Γ.slots[d]? with
        | none => .rejected "raw pointer aggregate: no destination slot"
        | some sd =>
          if (Ty.ptr ptd vd).size? ≠ some sd.size then .rejected "raw pointer aggregate: slot size"
          else if !(offOk sd.off && offOk (sd.off + sd.size)) then
            .rejected "raw pointer aggregate: offsets"
          else if !privOk Γ sd.off sd.size then
            .unsupported "raw pointer aggregate: escaped destination"
          else match guessSrcs Γ sd.off ops (rawPtrFields t0 t1) is with
            | .error why => .unsupported why
            | .ok srcs =>
              if !aggFieldsOk Γ sd ops (rawPtrFields t0 t1) srcs then
                .unsupported "raw pointer aggregate: operands"
              else if piecesOk Γ is (aggPieces sd.off (rawPtrFields t0 t1) srcs) then .ok
              else .unsupported "raw pointer aggregate: instruction form"
    | _, _, _ => .unsupported "raw pointer aggregate: types"
  | _ => .rejected "raw pointer aggregate: operand count"

/-- The family's checker: `none` unless `st` is a `rawPtr` aggregate into a whole local. -/
def checkRawPtrAgg (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.aggregate .rawPtr ops) => some (checkRawPtrAggOps Γ d ops is)
  | _ => none

theorem checkRawPtrAggOps_sound {Γ : StmtCtx} {d : Local} {ops : List Operand}
    {is : List Insn} (h : checkRawPtrAggOps Γ d ops is = .ok) :
    LowerRawPtrAgg Γ (.assign ⟨d, []⟩ (.aggregate .rawPtr ops)) is := by
  unfold checkRawPtrAggOps at h
  split at h
  next opd opm =>
    split at h
    next ptd vd t0 t1 htd _ _ =>
      split at h
      · cases h
      next h0 =>
        split at h
        · cases h
        next h1 =>
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
                  next srcs _ =>
                    split at h
                    · cases h
                    next hf =>
                      split at h
                      next hi =>
                        exact .mk htd (by simpa using hsz) hsd (by simpa using hoff)
                          (privOk_spec (by simpa using hpriv)) (by simpa using h0)
                          (by simpa using h1) (aggFieldsOk_spec (by simpa using hf)) hi
                      · cases h
    · cases h
  · cases h

theorem checkRawPtrAgg_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkRawPtrAgg Γ st is = some .ok) : LowerRawPtrAgg Γ st is := by
  unfold checkRawPtrAgg at h
  split at h
  next d ops => exact checkRawPtrAggOps_sound (Option.some.inj h)
  · cases h

end Ryo.Check.Lower
