/-
Ryo.Check.Lower.CastMore — casts lowered as field writes into `_d`'s slot (aot.md §C1, M5b):
array-to-slice unsizing of a thin pointer (two instructions) and transmutes of a scalar
constant (one `imm`). Both are stated as `Agg.lean`'s pieces (`AggFields`, `aggPieces`), so their
simulation is `SimAgg.lift_aggMem` once L0's store is shown to be the fields' bytes
(`Ryo/Proofs/Lower/SimCastMore.lean`).

What the backend emits (`backend/src/lower/cast.rs`):
- `PointerCoercion::Unsize` from `&[T; n]` (or `*const [T; n]`) to `&[T]`: `coerce_unsized_into`
  takes the `Ref`/`RawPtr` case, `fx.mov(d, s, PTR)` (the data pointer, from `_a`'s slot) and
  `unsized_info`'s `(Array, Slice)` case, `imm(W64, d + META, n)` (the length).
- `Transmute` (also `BoxDerefTransmute`, `Subtype`) of a constant: `operand_into`, for a scalar
  constant one `imm` of its width (the sizes are equal, or the backend declines).

L0: the unsizing attaches `.elementCount n` to the thin pointer (`unsizeValue`, D30), and the
store at `_d`'s slice pointer type encodes it as `encodePtr` of the thin part followed by
`encodeBits 8 n` (`Spec.Ty.encode`). The transmute encodes the constant's value at its type and
decodes the bytes at `ty` (D33); re-encoding at `ty` is below the bytes, which are below the
constant's `encodeBits` (`encode_decode_le`).

Rules (`_d` a whole local whose slot no `Escape` covers, as `Agg`'s):
- `unsizeLen`: `_d = cast (unsize (length n)) _a (.ptr ptd vd)`, `_d : .ptr ptd vd` a slice-like
  pointer (`elementCount`) of 16 bytes, `_a : .ptr pta va` thin, as the fields
  `unsizeLenFields`/`unsizeLenSrcs`: `_a`'s 8 bytes at offset 0 (a `.slot`, its slot apart from
  `_d`'s) and the constant `n` at offset 8 (an `.imm` of 8 bytes). The second field's type and
  operand (`unsizeLenOps`) only fix its size for `AggField`: `_a`'s type, the constant `n`.
- `transmuteConst`: `_d = cast k (const (scalar bits) tc) ty`, `k` a transmute, `_d : ty`, `tc`
  well-formed of `n` bytes, as the one field `.imm n bits` at offset 0 of `ty` (`AggField.imm`
  with the constant restated at `ty`, which gives `ty` well-formed of `n` bytes).

Not covered: unsizing to `dyn` (`unsize (vtable g)`, the vtable's address, a global) and fn item
to fn pointer (`reifyFnPointer`, a function's address): both need an invariant relating L0's
global and function addresses to R's (see `Wide.lean`'s note on pool constants); unsizing of
structs (`Rc<[T; n]>` → `Rc<[T]>`, field by field); transmutes of pool constants (slices,
`indirect`, `ptr`), of projected places and into projected places.

`checkCastMore` claims every array-to-slice unsizing of a whole local into a whole local and
every transmute of a scalar constant into a whole local, and is `none` otherwise.
-/
import Ryo.Check.Lower.Agg

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-! ### The unsizing's fields -/

/-- The operands of the unsizing's two fields: `_a` and the length. -/
abbrev unsizeLenOps (oa : Operand) (n : Nat) (ta : Ty) : List Operand :=
  [oa, .const (.scalar n) ta]

/-- The unsizing's two fields, both at `_a`'s type `ta` (8 bytes). -/
abbrev unsizeLenFields (ta : Ty) : List (Nat × Ty) := [(0, ta), (8, ta)]

/-- Where the unsizing's fields come from: `_a`'s slot at `so`, one 8-byte `mov`; the length. -/
abbrev unsizeLenSrcs (a : Local) (so : Int) (n : Nat) : List AggSrc := [.slot a so [8], .imm 8 n]

inductive LowerCastMore (Γ : StmtCtx) : Statement → List Insn → Prop where
  | unsizeLen {d a : Local} {oa : Operand} {n : Nat} {ptd pta : PtrType} {vd va : ValidRange}
      {sd : LocalSlot} {so : Int} {is : List Insn}
      (ha : oa.local? = some a) (hkd : ptd.metaKind = .elementCount)
      (hka : pta.metaKind = .none)
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd))
      (hta : Γ.body.locals[a]? = some (.ptr pta va))
      (hsd : Γ.slots[d]? = some sd) (hsz : sd.size = 16)
      (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
      (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
      (hf : AggFields Γ sd (unsizeLenOps oa n (.ptr pta va)) (unsizeLenFields (.ptr pta va))
        (unsizeLenSrcs a so n))
      (hi : piecesOk Γ is (aggPieces sd.off (unsizeLenFields (.ptr pta va))
        (unsizeLenSrcs a so n)) = true) :
      LowerCastMore Γ
        (.assign ⟨d, []⟩ (.cast (.pointerCoercion (.unsize (.length n))) oa (.ptr ptd vd))) is
  | transmuteConst {d : Local} {k : CastKind} {bits n : Nat} {tc ty : Ty} {sd : LocalSlot}
      {is : List Insn}
      (hk : bitCastKind k = true) (htd : Γ.body.locals[d]? = some ty)
      (hwfc : tc.wf = true) (hnc : tc.size? = some n)
      (hsd : Γ.slots[d]? = some sd) (hsz : ty.size? = some sd.size)
      (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
      (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
      (hf : AggField Γ sd (.const (.scalar bits) ty) 0 ty (.imm n bits))
      (hi : piecesOk Γ is (srcPieces sd.off (.imm n bits)) = true) :
      LowerCastMore Γ (.assign ⟨d, []⟩ (.cast k (.const (.scalar bits) tc) ty)) is

/-! ### Checkers -/

/-- `unsizeLen`'s checker: `_d = cast (unsize (length n)) _a (.ptr ptd vd)`. -/
def checkUnsizeLen (Γ : StmtCtx) (d a : Local) (oa : Operand) (n : Nat) (ptd : PtrType)
    (vd : ValidRange) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]?, Γ.body.locals[a]? with
  | some td, some (.ptr pta va) =>
    match Γ.slots[d]?, Γ.slots[a]? with
    | some sd, some sa =>
      if td != .ptr ptd vd then .unsupported "unsize length: destination type"
      else if !(decide (ptd.metaKind = .elementCount) && decide (pta.metaKind = .none)) then
        .unsupported "unsize length: pointer kinds"
      else if sd.size != 16 then .rejected "unsize length: slot size"
      else if !(offOk sd.off && offOk (sd.off + sd.size)) then .rejected "unsize length: offsets"
      else if !privOk Γ sd.off sd.size then .unsupported "unsize length: escaped destination"
      else if !aggFieldsOk Γ sd (unsizeLenOps oa n (.ptr pta va)) (unsizeLenFields (.ptr pta va))
          (unsizeLenSrcs a sa.off n) then .unsupported "unsize length: source"
      else if piecesOk Γ is (aggPieces sd.off (unsizeLenFields (.ptr pta va))
          (unsizeLenSrcs a sa.off n)) then .ok
      else .unsupported "unsize length: instruction form"
    | _, _ => .unsupported "unsize length: slots"
  | _, _ => .unsupported "unsize length: types"

/-- `transmuteConst`'s checker: `_d = cast k (const (scalar bits) tc) ty`. -/
def checkTransmuteConst (Γ : StmtCtx) (d : Local) (bits : Nat) (tc ty : Ty) (is : List Insn) :
    Verdict :=
  match Γ.body.locals[d]?, Γ.slots[d]? with
  | some td, some sd =>
    if td != ty then .unsupported "transmute const: destination type"
    else if !tc.wf then .unsupported "transmute const: ill-formed source type"
    else match tc.size? with
      | none => .unsupported "transmute const: unsized source"
      | some n =>
        if ty.size? != some sd.size then .rejected "transmute const: slot size"
        else if !(offOk sd.off && offOk (sd.off + sd.size)) then
          .rejected "transmute const: offsets"
        else if !privOk Γ sd.off sd.size then .unsupported "transmute const: escaped destination"
        else if !aggFieldOk Γ sd (.const (.scalar bits) ty) 0 ty (.imm n bits) then
          .unsupported "transmute const: constant"
        else if piecesOk Γ is (srcPieces sd.off (.imm n bits)) then .ok
        else .unsupported "transmute const: instruction form"
  | _, _ => .unsupported "transmute const: locals"

/-- The family's checker. -/
def checkCastMore (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.cast (.pointerCoercion (.unsize (.length n))) oa (.ptr ptd vd)) =>
    match oa.local? with
    | some a => some (checkUnsizeLen Γ d a oa n ptd vd is)
    | none => none
  | .assign ⟨d, []⟩ (.cast k (.const (.scalar bits) tc) ty) =>
    if bitCastKind k then some (checkTransmuteConst Γ d bits tc ty is) else none
  | _ => none

theorem checkUnsizeLen_sound {Γ : StmtCtx} {d a : Local} {oa : Operand} {n : Nat}
    {ptd : PtrType} {vd : ValidRange} {is : List Insn} (ha : oa.local? = some a)
    (h : checkUnsizeLen Γ d a oa n ptd vd is = .ok) :
    LowerCastMore Γ
      (.assign ⟨d, []⟩ (.cast (.pointerCoercion (.unsize (.length n))) oa (.ptr ptd vd))) is := by
  unfold checkUnsizeLen at h
  split at h
  next td pta va htd hta =>
    split at h
    next sd sa hsd hsa =>
      split at h
      · cases h
      next hty =>
        have hty : td = .ptr ptd vd := by simpa using hty
        subst hty
        split at h
        · cases h
        next hk =>
          have hk : ptd.metaKind = .elementCount ∧ pta.metaKind = .none := by simpa using hk
          split at h
          · cases h
          next hsz =>
            have hsz : sd.size = 16 := by simpa using hsz
            split at h
            · cases h
            next hoff =>
              split at h
              · cases h
              next hpriv =>
                split at h
                · cases h
                next hf =>
                  split at h
                  next hi =>
                    exact .unsizeLen ha hk.1 hk.2 htd hta hsd hsz (by simpa using hoff)
                      (privOk_spec (by simpa using hpriv)) (aggFieldsOk_spec (by simpa using hf))
                      hi
                  · cases h
    · cases h
  · cases h

theorem checkTransmuteConst_sound {Γ : StmtCtx} {d : Local} {k : CastKind} {bits : Nat}
    {tc ty : Ty} {is : List Insn} (hk : bitCastKind k = true)
    (h : checkTransmuteConst Γ d bits tc ty is = .ok) :
    LowerCastMore Γ (.assign ⟨d, []⟩ (.cast k (.const (.scalar bits) tc) ty)) is := by
  unfold checkTransmuteConst at h
  split at h
  next td sd htd hsd =>
    split at h
    · cases h
    next hty =>
      have hty : td = ty := by simpa using hty
      subst hty
      split at h
      · cases h
      next hwfc =>
        split at h
        · cases h
        next n hnc =>
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
                next hf =>
                  split at h
                  next hi =>
                    exact .transmuteConst hk htd (by simpa using hwfc) hnc hsd
                      (by simpa using hsz) (by simpa using hoff)
                      (privOk_spec (by simpa using hpriv)) (aggFieldOk_spec (by simpa using hf))
                      hi
                  · cases h
  · cases h

theorem checkCastMore_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkCastMore Γ st is = some .ok) : LowerCastMore Γ st is := by
  unfold checkCastMore at h
  split at h
  next d n oa ptd vd =>
    split at h
    next a ha => exact checkUnsizeLen_sound ha (Option.some.inj h)
    · cases h
  next d k bits tc ty =>
    split at h
    next hk => exact checkTransmuteConst_sound hk (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
