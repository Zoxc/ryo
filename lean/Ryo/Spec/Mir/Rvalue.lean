/-
Ryo.Spec.Mir.Rvalue — `Rvalue` evaluation.

Ports: MiniRust `lang/step/expressions.md` (`ValueExpr::{Tuple, Union, Variant,
GetDiscriminant, AddrOf, Load}`), `operators.md` (`ConstructWidePointer`, `GetMetadata`),
and `minimize/src/rvalue.rs` (how MiniRust reads each rustc `Rvalue`).

Divergences:
- D1: rustc's 13 rvalues. The aggregate's type is the assignment destination's type.
- D28: `Discriminant` reads only the tag (rustc/Miri `read_discriminant`); invalid tags and
  uninhabited variants are UB; non-enum places have discriminant 0.
- D31: `Repeat` is the operand's value `n` times (each element re-encoded on store).
- D32: `Aggregate` builds the value (`Value.variant` for enums: fields then tag, by encoding;
  writing an uninhabited variant is UB as in Miri); `AggregateKind::RawPtr` builds a (wide)
  pointer from data pointer and metadata (MiniRust `ConstructWidePointer`).
- `Ref`/`Reborrow` check the new reference's validity (MiniRust `AddrOf` does `check_value`);
  `RawPtr` does not. No retagging (D16).
- D22: `ThreadLocalRef` points to the (single) thread-local allocation.
-/
import Ryo.Spec.Mir.Cast

namespace Ryo.Spec.Sem

open SemM

/-- `&place`, `&raw place`. -/
def addrOf (p : MPlace) (destTy : Ty) (check : Bool) : SemM Value := do
  let (pl, _) ← evalPlace p
  let v := Value.ptr pl.ptr
  if check then liftE (checkValue (← getMem) v destTy)
  pure v

-- [D28] [D31] [D32] [D22]
def evalRvalue (rv : Rvalue) (destTy : Ty) : SemM Value := do
  match rv with
  | .use o => pure (← evalOperand o).1
  | .repeat o n => do
    let (v, _) ← evalOperand o
    pure (.tuple (List.replicate n v))
  | .ref _ p => addrOf p destTy true
  | .reborrow _ _ p => addrOf p destTy true
  | .rawPtr _ p => addrOf p destTy false
  | .threadLocalRef g => do pure (.ptr (← globalPtr g).widen)
  | .cast k o ty => evalCast k (← evalOperand o) ty
  | .binaryOp op a b => do
    let l ← evalOperand a
    let r ← evalOperand b
    evalBinOp op l r destTy
  | .unaryOp op a => do evalUnOp op (← evalOperand a) destTy
  | .discriminant p => do
    let (pl, ty) ← evalPlace p
    match ty with
    | .enum vs discrTy .. => do
      if !pl.aligned then
        throwUb "getting the discriminant of a place based on a misaligned pointer"
      let idx ← liftE (readDiscriminant (← getMem) pl.ptr.thin ty)
      let d := (vs[idx]?.map (·.discr)).getD 0
      match destTy with
      | .int t _ => pure (.int (t.bringInBounds (discrTy.bringInBounds d)))
      | _ => throwIllFormed "Discriminant: destination is not an integer"
    | _ => pure (.int 0)
  | .aggregate k ops => do
    let vals ← ops.mapM fun o => do pure (← evalOperand o).1
    match k with
    | .array | .tuple | .closure => pure (.tuple vals)
    | .adt variant active =>
      match destTy with
      | .enum vs .. =>
        if !variantInhabited vs variant then throwUb "writing an uninhabited enum variant"
        else pure (.variant variant (.tuple vals))
      | .union fields _ size _ => do
        let some f := active | throwIllFormed "union aggregate without an active field"
        let some (off, fty) := fields[f]? | throwIllFormed "union field out of range"
        let some v := vals.head? | throwIllFormed "union aggregate without an operand"
        let some fb := fty.encode v | throwIllFormed "spec bug: ill-formed union field value"
        match destTy.decode (writeAt (List.replicate size .uninit) off fb) with
        | some u => pure u
        | none => throwIllFormed "spec bug: union does not decode"
      | _ => pure (.tuple vals)
    | .rawPtr =>
      match vals, destTy with
      | [.ptr p, md], .ptr pt _ => do
        let m ← match pt.metaKind, md with
          | .none, _ => pure none
          | .elementCount, .int n => pure (some (.elementCount n.toNat))
          | .vtablePointer _, .ptr vt => pure (some (.vtablePointer vt.thin))
          | _, _ => throwIllFormed "AggregateKind::RawPtr: bad metadata"
        let v := Value.ptr ⟨p.thin, m⟩
        liftE (checkValue (← getMem) v destTy)
        pure v
      | _, _ => throwIllFormed "AggregateKind::RawPtr: bad operands"
  | .copyForDeref p => do
    let (pl, ty) ← evalPlace p
    placeLoad pl ty
  | .wrapUnsafeBinder o _ => pure (← evalOperand o).1

end Ryo.Spec.Sem
