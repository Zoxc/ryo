/-
Ryo.Spec.Mir.Place — evaluating places.

Ports: MiniRust `lang/step/expressions.md` § Place Expressions (`PlaceExpr::{Local, Deref,
Field, Index, Downcast}`), § Load (`place_load`), `statements.md` (`place_store`) and
`operators.md` (`ptr_offset_inbounds`), applied to MIR projections (rustc `ProjectionElem`).

Divergences:
- D1: MIR projections. `ConstantIndex`/`Subslice` (with `from_end`) follow Miri's
  `project_constant_index`/`project_subslice`; `OpaqueCast`/`UnwrapUnsafeBinder` only
  change the type.
- D29: the offset of an unsized tail field is rounded up to the tail's dynamic alignment,
  which for `dyn Trait` tails is read from the vtable (cg_ssa `project_field`).
- D36: places carry `aligned` (MiniRust); loads and stores through misaligned places are UB,
  but fields of packed structs are accessed with alignment 1.
-/
import Ryo.Spec.Mir.State

namespace Ryo.Spec.Sem

open SemM

/-- `ptr_offset_inbounds`: the range must be dereferenceable, and the result must not wrap. -/
def ptrOffsetInbounds (p : ThinPointer) (off : Int) : SemM ThinPointer := do
  liftE ((← getMem).signedDereferenceable p off)
  let a : Int := p.addr + off
  if a < 0 || a ≥ Target.ADDR_LIMIT then throwUb "in-bounds pointer arithmetic overflowed"
  pure { p with addr := a.toNat }

/-- Size and alignment of a value of `ty` behind a pointer with metadata `md`. -/
def sizeAlignOf (ty : Ty) (md : Option PointerMeta) : SemM (Size × Align) := do
  match computeSizeAndAlign (← getMem) ty.layout md with
  | some r => pure r
  | none => throwUb "pointer metadata does not fit the pointee type"

/-- `place_load`. -/
def placeLoad (pl : Place) (ty : Ty) : SemM Value := do
  if !pl.aligned then throwUb "loading from a place based on a misaligned pointer"
  liftE (typedLoad (← getMem) pl.ptr.thin ty .one)

/-- `place_store`. -/
def placeStore (pl : Place) (v : Value) (ty : Ty) : SemM Unit := do
  if !pl.aligned then throwUb "storing to a place based on a misaligned pointer"
  memUpdate (typedStore · pl.ptr.thin v ty .one)

/-- The place of a local (`PlaceExpr::Local`). -/
def localPlace (l : Local) : SemM (Place × Ty) := do
  let f ← curFrame
  let ty ← localTy f l
  match f.locals[l]? with
  | some (some p) => pure (⟨p.widen, true⟩, ty)
  | _ => throwUb s!"access to a dead local _{l}"

/-- Read an index local (`usize`). -/
def readIndexLocal (l : Local) : SemM Nat := do
  let (pl, ty) ← localPlace l
  match ← placeLoad pl ty with
  | .int i => if i ≥ 0 then pure i.toNat else throwIllFormed "negative index"
  | _ => throwIllFormed "non-integer index local"

/-- Element type and count of an array or slice place. -/
def elemsOf (pl : Place) (ty : Ty) : SemM (Ty × Nat × Bool) :=
  match ty with
  | .array e n => pure (e, n, false)
  | .slice e =>
    match pl.ptr.metadata with
    | some (.elementCount n) => pure (e, n, true)
    | _ => throwIllFormed "slice place without a length"
  | _ => throwIllFormed "index projection on a non-indexable type"

-- [D1] [D29] [D36]
/-- Apply one projection. -/
def projectPlace (pl : Place) (ty : Ty) : ProjElem → SemM (Place × Ty)
  | .deref pointee => do
    let .ptr pt _ := ty | throwIllFormed "deref of a non-pointer"
    let v ← placeLoad pl ty
    let .ptr p := v | throwIllFormed "deref: not a pointer value"
    -- Safe pointers must be dereferenceable (already part of their validity).
    if let some pi := pt.safePointee then
      match computeSizeAndAlign (← getMem) pi.layout p.metadata with
      | some (size, _) => liftE ((← getMem).dereferenceable p.thin size)
      | none => throwUb "deref: invalid metadata"
    -- Misaligned places can still be turned into raw pointers, but not loaded from.
    let (_, align) ← sizeAlignOf pointee p.metadata
    pure (⟨p, align.isAligned p.thin.addr⟩, pointee)
  | .field f _ => do
    match ty with
    | .tuple fields head tail =>
      match fields[f]? with
      | some (off, fty) => do
        let q ← ptrOffsetInbounds pl.ptr.thin off
        pure ({ pl with ptr := q.widen }, fty)
      | none =>
        match tail with
        | some t =>
          if f == fields.length then do
            let (_, ta) ← sizeAlignOf t pl.ptr.metadata
            let q ← ptrOffsetInbounds pl.ptr.thin (head.tailOffset ta)
            pure ({ pl with ptr := q.widen pl.ptr.metadata }, t)
          else throwIllFormed s!"field {f} out of range"
        | none => throwIllFormed s!"field {f} out of range"
    | .union fields _ _ _ =>
      match fields[f]? with
      | some (off, fty) => do
        let q ← ptrOffsetInbounds pl.ptr.thin off
        pure ({ pl with ptr := q.widen }, fty)
      | none => throwIllFormed s!"union field {f} out of range"
    | _ => throwIllFormed "field projection on a non-projectable type"
  | .index l => do
    let i ← readIndexLocal l
    let (e, n, _) ← elemsOf pl ty
    if i ≥ n then throwUb "access to out-of-bounds index"
    let q ← ptrOffsetInbounds pl.ptr.thin (i * e.size)
    pure ({ pl with ptr := q.widen }, e)
  | .constantIndex off _ fromEnd => do
    let (e, n, _) ← elemsOf pl ty
    let i : Int := if fromEnd then (n : Int) - off else off
    if i < 0 || i ≥ n then throwUb "access to out-of-bounds index"
    let q ← ptrOffsetInbounds pl.ptr.thin (i * e.size)
    pure ({ pl with ptr := q.widen }, e)
  | .subslice fr to fromEnd => do
    let (e, n, isSlice) ← elemsOf pl ty
    let len : Int := if fromEnd then (n : Int) - fr - to else (to : Int) - fr
    if len < 0 || fr + len > n then throwUb "subslice out of bounds"
    let q ← ptrOffsetInbounds pl.ptr.thin (fr * e.size)
    if isSlice then pure ({ pl with ptr := q.widen (some (.elementCount len.toNat)) }, .slice e)
    else pure ({ pl with ptr := q.widen }, .array e len.toNat)
  | .downcast v => do
    let .enum vs .. := ty | throwIllFormed "downcast of a non-enum"
    match vs[v]? with
    | some var => pure (pl, var.fields)
    | none => throwIllFormed s!"downcast to variant {v} out of range"
  | .opaqueCast t => pure (pl, t)
  | .unwrapUnsafeBinder t => pure (pl, t)

/-- Evaluate a place (left to right through the projections). -/
def evalPlace (p : MPlace) : SemM (Place × Ty) := do
  let init ← localPlace p.base
  p.proj.foldlM (fun (pl, ty) e => projectPlace pl ty e) init

end Ryo.Spec.Sem
