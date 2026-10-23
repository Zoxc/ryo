/-
Ryo.Spec.Mir.Cast — `Rvalue::Cast`.

Ports: MiniRust `lang/step/operators.md` § Casts (`IntToInt`, `Transmute`), the intrinsics
`PointerExposeProvenance`/`PointerWithExposedProvenance` (`intrinsics.md`), and
`minimize/src/rvalue.rs` (MiniRust's reading of each `CastKind`).

Divergences:
- D11: pointer ↔ integer casts expose provenance / pick an exposed provenance (angelic), as in
  MiniRust.
- D30: `PointerCoercion::Unsize` attaches metadata to the innermost pointer; structs (`Box`,
  `Rc`, ...) are coerced field by field where the field types differ (cg_ssa
  `coerce_unsized_into`). Trait upcasting reads the new vtable pointer from the old vtable
  (D29).
- D33: `Transmute` (and `BoxDerefTransmute`, `Subtype`) go through encode/decode: UB if the
  sizes differ or the result is invalid.
- D34: `FloatToInt` saturates (NaN → 0); `IntToFloat`/`FloatToFloat` round to nearest even;
  NaN payloads are a daemonic choice (D5).
- D35: `PtrToPtr` from a wide to a thin pointer drops the metadata; `FnPtrToPtr`,
  `ReifyFnPointer` (D6: an address choice), `ClosureFnPointer`, `UnsafeFnPointer`,
  `MutToConstPointer`, `ArrayToPointer` keep the address.
-/
import Ryo.Spec.Mir.Ops

namespace Ryo.Spec.Sem

open SemM

/-- Read the vtable pointer stored in word `k` of a vtable (trait upcasting, D29/D30). -/
def vtableWordPtr (vt : ThinPointer) (k : Nat) : SemM ThinPointer := do
  let bytes ← liftE ((← getMem).load (vt.wrappingOffset (8 * k)) 8 .one)
  match decodePtr bytes with
  | some p => pure p
  | none => throwUb "invalid vtable entry"

-- [D30] [D29]
/-- Attach the unsizing metadata (D30). `fuel` bounds the struct nesting. -/
def unsizeValue (m : UnsizeMeta) : Nat → Value → Ty → Ty → SemM Value
  | 0, _, _, _ => throwIllFormed "Unsize: types nested too deeply"
  | fuel + 1, v, src, dst =>
    match v, src, dst with
    | .ptr p, .ptr _ _, .ptr _ _ => do
      match m with
      | .length n => pure (.ptr ⟨p.thin, some (.elementCount n)⟩)
      | .vtable g => pure (.ptr ⟨p.thin, some (.vtablePointer (← globalPtr g))⟩)
      | .upcast none => pure (.ptr p)
      | .upcast (some k) =>
        match p.metadata with
        | some (.vtablePointer vt) => do
          pure (.ptr ⟨p.thin, some (.vtablePointer (← vtableWordPtr vt k))⟩)
        | _ => throwIllFormed "Unsize upcast of a pointer without a vtable"
    | .tuple vs, .tuple sfs _ none, .tuple dfs _ none => do
      if vs.length != sfs.length || sfs.length != dfs.length then
        throwIllFormed "Unsize: struct shapes differ"
      let mut out := []
      for (fv, (_, st), (_, dt)) in vs.zip (sfs.zip dfs) do
        if st == dt then out := out ++ [fv]
        else out := out ++ [← unsizeValue m fuel fv st dt]
      pure (.tuple out)
    | _, _, _ => throwIllFormed "Unsize: unsupported source/destination types"

/-- An integer view of int-like values (`bool` as 0/1, `char` as its code point). -/
def intLike : Value → SemM Int
  | .int i => pure i
  | .bool b => pure (if b then 1 else 0)
  | _ => throwIllFormed "integer cast of a non-integer"

-- [D11] [D33] [D34] [D35] [D6]
def evalCast (k : CastKind) (v : Value × Ty) (dst : Ty) : SemM Value := do
  let (val, src) := v
  match k with
  | .intToInt => do
    let i ← intLike val
    match dst with
    | .int t _ => pure (.int (t.bringInBounds i))
    | .char =>
      if 0 ≤ i && isUnicodeScalar i.toNat then pure (.int i)
      else throwUb "IntToInt: invalid char"
    | _ => throwIllFormed "IntToInt to a non-integer type"
  | .floatToInt =>
    match val, dst with
    | .float f b, .int t _ => pure (.int (Float.toInt f t b))
    | _, _ => throwIllFormed "FloatToInt: bad operands"
  | .intToFloat =>
    match dst with
    | .float g => do pure (.float g (Float.ofInt g (← intLike val)))
    | _ => throwIllFormed "IntToFloat: bad destination"
  | .floatToFloat =>
    match val, dst with
    | .float f b, .float g => resolveFloat g (Float.convert f g b)
    | _, _ => throwIllFormed "FloatToFloat: bad operands"
  | .pointerExposeProvenance =>
    match val with
    | .ptr p => do
      modify fun s => { s with intptr := s.intptr.expose p.thin }
      pure (.int p.thin.addr)
    | _ => throwIllFormed "PointerExposeProvenance of a non-pointer"
  | .pointerWithExposedProvenance => do
    let i ← intLike val
    let p ← (← get).intptr.ptrFromInt (i.toNat % Target.ADDR_LIMIT)
    pure (.ptr p.widen)
  | .ptrToPtr | .fnPtrToPtr =>
    match val, dst with
    | .ptr p, .ptr pt _ =>
      if pt.isWide then pure (.ptr p) else pure (.ptr p.thin.widen)
    | _, _ => throwIllFormed "PtrToPtr: bad operands"
  | .transmute | .boxDerefTransmute | .subtype =>
    liftE (transmute (← getMem) val src dst)
  | .pointerCoercion c =>
    match c with
    | .reifyFnPointer i | .closureFnPointer i => do pure (.ptr (← fnPointer i).widen)
    | .unsafeFnPointer | .mutToConstPointer => pure val
    | .arrayToPointer =>
      match val with
      | .ptr p => pure (.ptr p.thin.widen)
      | _ => throwIllFormed "ArrayToPointer of a non-pointer"
    | .unsize m => unsizeValue m 64 val src dst

end Ryo.Spec.Sem
