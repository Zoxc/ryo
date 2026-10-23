/-
Ryo.Spec.Mir.Statement — statements.

Ports: MiniRust `lang/step/statements.md` (`Assign`, `PlaceMention`, `SetDiscriminant`,
`StorageLive`, `StorageDead`, `place_store`) and the `CopyNonOverlapping`/`Assume` parts of
`intrinsics.md`.

Divergences:
- `Assign` evaluates the place first, then the rvalue, as Miri does.
- D9: `StorageLive` of a live local re-allocates; `StorageDead` of a dead local is a no-op;
  locals without storage statements are allocated at frame creation (`Ryo.Spec.Mir.Call`).
  Aliased locals (D12) are only forgotten, not deallocated.
- D28: `SetDiscriminant` writes the tag only (rustc/Miri `write_discriminant`): nothing for
  implicitly encoded variants, after a validation read.
- D20: `CopyNonOverlapping` copies raw bytes (provenance included); overlapping ranges are UB;
  both pointers must be aligned for `T`. `Assume(false)` is UB.
-/
import Ryo.Spec.Mir.Rvalue

namespace Ryo.Spec.Sem

open SemM

-- [D9]
/-- `storage_dead` on the active frame. -/
def storageDead (l : Local) : SemM Unit := do
  let f ← curFrame
  match f.locals[l]? with
  | some (some p) => do
    if !f.aliased.contains l then
      let ty ← localTy f l
      memUpdate (·.deallocate p .stack ty.size ty.align)
    setCurFrame { f with locals := f.locals.set! l none, aliased := f.aliased.erase l }
  | _ => pure ()

/-- `storage_live` on the active frame (D9: re-allocates a live local). -/
def storageLive (l : Local) : SemM Unit := do
  storageDead l
  let f ← curFrame
  let ty ← localTy f l
  let some size := ty.size? | throwIllFormed s!"local _{l} is unsized"
  let (p, mem) ← (← getMem).allocate .stack size ty.align
  setMem mem
  setCurFrame { f with locals := f.locals.set! l (some p) }

-- [D20]
/-- Raw byte copy for `copy`/`copy_nonoverlapping` (D20). -/
def copyBytes (src dst : Pointer) (pt : PtrType) (count : Int) (nonOverlapping : Bool) :
    SemM Unit := do
  let es ← pointeeSize pt
  let al := match pt.pointee? with
    | some ⟨.sized _ a, _⟩ => a
    | _ => Align.one
  if count < 0 then throwUb "copy: negative count"
  let size := count.toNat * es
  if size > Target.ISIZE_MAX then throwUb "copy: size overflows isize"
  let bytes ← liftE ((← getMem).load src.thin size al)
  if nonOverlapping && size > 0 then
    let a := src.thin.addr
    let b := dst.thin.addr
    if a < b + size && b < a + size then throwUb "copy_nonoverlapping: overlapping ranges"
  memUpdate (·.store dst.thin bytes al)

def evalStatement : Statement → SemM Unit
  | .assign p rv => do
    let (pl, ty) ← evalPlace p
    let v ← evalRvalue rv ty
    placeStore pl v ty
  | .setDiscriminant p v => do
    let (pl, ty) ← evalPlace p
    if !pl.aligned then
      throwUb "setting the discriminant of a place based on a misaligned pointer"
    memUpdate (writeDiscriminant · pl.ptr.thin ty v)
  | .storageLive l => storageLive l
  | .storageDead l => storageDead l
  | .assume o => do
    match (← evalOperand o).1 with
    | .bool true => pure ()
    | .bool false => throwUb "`Assume` intrinsic called on condition that is violated"
    | _ => throwIllFormed "Assume of a non-bool"
  | .copyNonOverlapping src dst count => do
    let (sv, sty) ← evalOperand src
    let (dv, _) ← evalOperand dst
    let (cv, _) ← evalOperand count
    match sv, sty, dv, cv with
    | .ptr s, .ptr pt _, .ptr d, .int n => copyBytes s d pt n true
    | _, _, _, _ => throwIllFormed "CopyNonOverlapping: bad operands"
  | .placeMention p => do
    let _ ← evalPlace p
    pure ()
  | .nop _ => pure ()

end Ryo.Spec.Sem
