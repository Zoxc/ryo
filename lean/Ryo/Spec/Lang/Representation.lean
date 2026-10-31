/-
Ryo.Spec.Lang.Representation — the representation relation, well-formed values, typed
memory accesses, transmutation.

Ports: MiniRust `lang/representation.md` (`decode`, `encode`, `decode_ptr`, `encode_ptr`,
`PointerMetaKind::{decode_value, encode_as_value}`, `check_ptr_metadata`, `check_ptr`,
`check_value`, `typed_load`, `typed_store`, `transmute`), `lang/machine.md`
(`vtable_lookup`, `compute_size`, `compute_align`), and `lang/step/expressions.md`
(`decode_discriminant`) / `statements.md` (`encode_discriminant`).

Divergences:
- D2, D28: enums are decoded and encoded with rustc's algorithm (cg_ssa `codegen_get_discr` /
  `codegen_set_discr`, Miri `read_discriminant`/`write_discriminant`): `Variants::Empty` has
  no values, `Single` has no tag, `Multiple` reads the tag at its offset and maps it to a
  variant by `TagEncoding::{Direct, Niche}`. An invalid tag (outside the tag's valid range, no
  variant with that discriminant, the untagged variant's own niche value) or an uninhabited
  variant does not decode (UB on load).
- D3: integers, pointers and tags outside their `ValidRange` do not decode.
- D4: `char` decodes only Unicode scalar values.
- D5: floats decode to their bits (any initialized bits are valid).
- D13: uninitialized bytes do not decode as integers, floats, bools, chars or pointers; padding
  becomes `Uninit` on encode.
- D29: vtable pointers must point at the start of a live vtable allocation, whose words 1 and 2
  give size and alignment.

`decode`/`encode` are total with `Option` results: MiniRust's `panic!` cases (unsized types,
values not matching the type) give `none`, and the machine-level callers turn spec-bug
situations into `illFormed` before calling them.
-/
import Ryo.Spec.Lang.Values
import Ryo.Spec.Mem.Basic

namespace Ryo.Spec

/-! ## Bytes, integers, pointers -/

/-- The data of a list of initialized bytes, little endian (`None` if any byte is `Uninit`). -/
def decodeBits (bytes : List AbstractByte) : Option Nat := do
  let ds ← bytes.mapM AbstractByte.data
  pure (leDecode ds)

def encodeBits (size : Size) (n : Nat) : List AbstractByte :=
  (leEncode size n).map AbstractByte.ofByte

/-- Replace `bytes[off .. off + src.length]` by `src`. -/
def writeAt (bytes : List AbstractByte) (off : Nat) (src : List AbstractByte) : List AbstractByte :=
  bytes.take off ++ src ++ bytes.drop (off + src.length)

/-- `decode_ptr`: the provenance survives only if all bytes carry the same provenance at
consecutive positions. -/
def decodePtr (bytes : List AbstractByte) : Option ThinPointer := do
  let addr ← decodeBits bytes
  let prov : Option Provenance :=
    match bytes with
    | [] => none
    | b0 :: _ =>
      match b0.provFrag with
      | none => none
      | some f0 =>
        if (bytes.zipIdx.all fun (b, i) =>
              match b.provFrag with
              | some f => f.prov == f0.prov && f.pos == i
              | none => false) then some f0.prov else none
  pure ⟨addr, prov⟩

/-- `encode_ptr`. -/
def encodePtr (p : ThinPointer) : List AbstractByte :=
  (leEncode Target.PTR_SIZE p.addr).zipIdx.map fun (b, i) =>
    .init b (p.prov.map fun pr => ⟨pr, i⟩)

/-- D4: Unicode scalar values. -/
def isUnicodeScalar (v : Nat) : Bool := v ≤ 0x10FFFF && !(0xD800 ≤ v && v ≤ 0xDFFF)

/-! ## Enum tags (D2, D28) -/

-- [D2] [D28]
/-- The variant index a tag value denotes, or an error message (rustc/Miri
`read_discriminant`). Does not check inhabitedness. -/
def tagToVariant (vs : List Variant) (discrTy : IntType) (tag : TagInfo) (bits : Nat) :
    Except String Nat :=
  match tag.encoding with
  | .direct =>
    if !tag.valid.contains bits then .error s!"enum tag {bits} outside its valid range"
    else
      -- the tag is the discriminant at the tag's width. rustc may make the tag wider than
      -- the discriminant type (`layout_of_enum` widens it to the variants' alignment when
      -- there is no `repr`, e.g. the `u128` tag of `Option<i128>`); on tags in the valid
      -- range this agrees with cg_ssa's cast of the tag to the discriminant type
      match vs.zipIdx.find? (fun (v, _) => tag.tag.toBits v.discr == bits) with
      | some (_, i) => .ok i
      | none => .error s!"enum tag {bits} does not match any variant"
  | .niche untagged lo hi start =>
    let rel := (bits + tag.tag.modulus - start % tag.tag.modulus) % tag.tag.modulus
    if rel ≤ hi - lo then
      let idx := lo + rel
      if idx == untagged then .error s!"enum tag {bits} is the niche value of the untagged variant"
      else .ok idx
    else if !tag.valid.contains bits then .error s!"enum tag {bits} outside its valid range"
    else .ok untagged

-- [D2] [D28]
/-- What to write for variant `idx` (rustc/Miri `tag_for_variant`): `none` = nothing (the
variant is encoded implicitly), `some bits` = store these tag bits. -/
def tagForVariant (vs : List Variant) (tag : TagInfo) (idx : Nat) : Option Nat :=
  match tag.encoding with
  | .direct => some (tag.tag.toBits ((vs[idx]?.map (·.discr)).getD 0))
  | .niche untagged lo _ start =>
    if idx == untagged then none
    else some ((idx - lo + start) % tag.tag.modulus)

def variantInhabited (vs : List Variant) (idx : Nat) : Bool :=
  (vs[idx]?.map (·.inhabited)).getD false

/-! ## decode / encode -/

mutual

-- [D3] [D4] [D5] [D13]
/-- `Type::decode`: bytes to a value (not yet checked for pointer validity). Assumes the
length matches the type's size. -/
def Ty.decode : Ty → List AbstractByte → Option Value
  | .int t valid, bytes => do
    if bytes.length != t.size then none
    let n ← decodeBits bytes
    if !valid.contains n then none
    pure (.int (t.ofBits n))
  | .bool, bytes =>
    match bytes with
    | [.init 0 _] => some (.bool false)
    | [.init 1 _] => some (.bool true)
    | _ => none
  | .char, bytes => do
    if bytes.length != 4 then none
    let n ← decodeBits bytes
    if !isUnicodeScalar n then none
    pure (.int n)
  | .float f, bytes => do
    if bytes.length != f.size then none
    let n ← decodeBits bytes
    pure (.float f n)
  | .ptr p valid, bytes => do
    match p.metaKind with
    | .none =>
      if bytes.length != 8 then none
      let tp ← decodePtr bytes
      if !valid.contains tp.addr then none
      pure (.ptr ⟨tp, none⟩)
    | .elementCount =>
      if bytes.length != 16 then none
      let tp ← decodePtr (bytes.take 8)
      if !valid.contains tp.addr then none
      let n ← decodeBits (bytes.drop 8)
      pure (.ptr ⟨tp, some (.elementCount n)⟩)
    | .vtablePointer _ =>
      if bytes.length != 16 then none
      let tp ← decodePtr (bytes.take 8)
      if !valid.contains tp.addr then none
      let vt ← decodePtr (bytes.drop 8)
      pure (.ptr ⟨tp, some (.vtablePointer vt)⟩)
  | .fnDef _, bytes => if bytes.isEmpty then some (.tuple []) else none
  | .tuple fields _ none, bytes => do
    let vs ← Ty.decodeFields fields bytes
    pure (.tuple vs)
  | .tuple _ _ (some _), _ => none
  | .array elem n, bytes =>
    match elem.layout with
    | .sized es _ => do
      if bytes.length != es * n then none
      let vs ← (List.range n).mapM fun i => elem.decode ((bytes.drop (i * es)).take es)
      pure (.tuple vs)
    | _ => none
  | .slice _, _ => none
  | .union _ chunks size _, bytes =>
    if bytes.length != size then none
    else some (.union (chunks.map fun (off, sz) => (bytes.drop off).take sz))
  | .enum vs discrTy repr size _, bytes => do
    if bytes.length != size then none
    let idx ← match repr with
      | .empty => none
      | .single idx => some idx
      | .multiple tag => do
        let bits ← decodeBits ((bytes.drop tag.offset).take tag.tag.size)
        match tagToVariant vs discrTy tag bits with
        | .ok i => some i
        | .error _ => none
    if !variantInhabited vs idx then none
    let data ← Ty.decodeVariant vs idx bytes
    pure (.variant idx data)
  | .traitObject _, _ => none
  | .opaqueBytes size _, bytes => if bytes.length == size then some (.union [bytes]) else none

def Ty.decodeFields : List (Offset × Ty) → List AbstractByte → Option (List Value)
  | [], _ => some []
  | (off, t) :: rest, bytes => do
    let s ← t.size?
    let v ← t.decode ((bytes.drop off).take s)
    let vs ← Ty.decodeFields rest bytes
    pure (v :: vs)

def Ty.decodeVariant : List Variant → Nat → List AbstractByte → Option Value
  | [], _, _ => none
  | ⟨_, t, _⟩ :: _, 0, bytes => t.decode bytes
  | _ :: vs, n + 1, bytes => Ty.decodeVariant vs n bytes

end

mutual

/-- `Type::encode`: a value to bytes; `none` if the value has the wrong shape for the type, or
is an integer the integer type can't represent (a spec bug for well-formed values). Other
ranges aren't checked here but by `checkValue`: a `char` above `u32`, float bits wider than
the format, a slice length or address of 2^64 or more are truncated, and integer and pointer
`ValidRange`s are ignored. -/
def Ty.encode : Ty → Value → Option (List AbstractByte)
  | .int t _, .int i => if t.canRepresent i then some (encodeBits t.size (t.toBits i)) else none
  | .bool, .bool b => some [.init (if b then 1 else 0) none]
  | .char, .int i => if 0 ≤ i then some (encodeBits 4 i.toNat) else none
  | .float f, .float g bits => if f == g then some (encodeBits f.size bits) else none
  | .ptr p _, .ptr pv =>
    match p.metaKind, pv.metadata with
    | .none, none => some (encodePtr pv.thin)
    | .elementCount, some (.elementCount n) => some (encodePtr pv.thin ++ encodeBits 8 n)
    | .vtablePointer _, some (.vtablePointer vt) => some (encodePtr pv.thin ++ encodePtr vt)
    | _, _ => none
  | .fnDef _, .tuple [] => some []
  | .tuple fields head none, .tuple vs => do
    let init := List.replicate head.headSizeAndAlign.1 AbstractByte.uninit
    Ty.encodeFields fields vs init
  | .array elem n, .tuple vs => do
    if vs.length != n then none
    let parts ← vs.mapM elem.encode
    pure parts.flatten
  | .union _ chunks size _, .union data => do
    if chunks.length != data.length then none
    -- MiniRust: `assert!(data.len() == size)` per chunk
    if !((chunks.zip data).all fun ((_, sz), d) => d.length == sz) then none
    let init := List.replicate size AbstractByte.uninit
    pure ((chunks.zip data).foldl (fun acc ((off, _), d) => writeAt acc off d) init)
  | .enum vs _ repr _ _, .variant idx data => do
    let bytes ← Ty.encodeVariant vs idx data
    match repr with
    | .empty => none
    | .single i => if i == idx then some bytes else none
    | .multiple tag =>
      match tagForVariant vs tag idx with
      | none => some bytes
      | some bits => some (writeAt bytes tag.offset (encodeBits tag.tag.size bits))
  | .opaqueBytes size _, .union [bs] => if bs.length == size then some bs else none
  | _, _ => none

def Ty.encodeFields : List (Offset × Ty) → List Value → List AbstractByte →
    Option (List AbstractByte)
  | [], [], acc => some acc
  | (off, t) :: fs, v :: vs, acc => do
    let b ← t.encode v
    Ty.encodeFields fs vs (writeAt acc off b)
  | _, _, _ => none

def Ty.encodeVariant : List Variant → Nat → Value → Option (List AbstractByte)
  | [], _, _ => none
  | ⟨_, t, _⟩ :: _, 0, v => t.encode v
  | _ :: vs, n + 1, v => Ty.encodeVariant vs n v

end

/-! ## Vtables (D29) -/

/-- Read a little-endian word (data only) from an allocation. -/
def Allocation.readWord (a : Allocation) (off : Nat) : Option Nat :=
  decodeBits (a.data.extract off (off + 8)).toList

-- [D29]
/-- Size and alignment stored in the vtable `p` points to: `p` must point to the start of a
live vtable allocation (D29: layout `[drop_in_place, size, align, entries...]`). -/
def vtableSizeAlign (mem : Memory) (p : ThinPointer) : Option (Size × Align) := do
  let (_, a) ← mem.allocAt? p .vtable
  let size ← a.readWord 8
  let align ← a.readWord 16
  let al ← Align.ofBytes? align
  pure (size, al)

/-- `compute_size`/`compute_align` with the vtables in memory. -/
def computeSizeAndAlign (mem : Memory) (l : LayoutStrategy) (md : Option PointerMeta) :
    Option (Size × Align) :=
  l.computeSizeAndAlign (vtableSizeAlign mem) md

/-! ## Well-formed values -/

/-- `check_ptr_metadata`. -/
def checkPtrMetadata (mem : Memory) (md : Option PointerMeta) (k : PointerMetaKind) :
    Except Outcome Unit :=
  match md, k with
  | none, .none => pure ()
  | some (.elementCount n), .elementCount =>
    ensureUb (n < 2 ^ 64) "Value::Ptr: invalid slice length"
  | some (.vtablePointer vt), .vtablePointer _ => do
    ensureUb (vt.addr != 0 && vt.addr < Target.ADDR_LIMIT) "Value::Ptr: invalid vtable in metadata"
    ensureUb (vtableSizeAlign mem vt).isSome "Value::Ptr: invalid vtable in metadata"
  | _, _ => throwUb "Value::Ptr: invalid metadata"

-- [D3] [D15]
/-- `check_ptr`: pointer validity, including (D3) the valid range and, for references and
boxes, non-null, aligned, dereferenceable, inhabited pointee (D15's `nonnull`, `align`,
`dereferenceable`). -/
def checkPtr (mem : Memory) (p : Pointer) (pt : PtrType) (valid : ValidRange) :
    Except Outcome Unit := do
  ensureUb (p.thin.addr < Target.ADDR_LIMIT) "Value::Ptr: pointer out-of-bounds"
  ensureUb (valid.contains p.thin.addr) "Value::Ptr: pointer outside its valid range"
  checkPtrMetadata mem p.metadata pt.metaKind
  match pt.safePointee with
  | some pointee =>
    let some (size, align) := computeSizeAndAlign mem pointee.layout p.metadata
      | throwUb "Value::Ptr: cannot compute pointee size"
    ensureUb (size ≤ Target.ISIZE_MAX) "Value::Ptr: total size exceeds isize::MAX"
    ensureUb (p.thin.addr != 0) "Value::Ptr: null safe pointer"
    ensureUb (align.isAligned p.thin.addr) "Value::Ptr: unaligned safe pointer"
    ensureUb pointee.inhabited "Value::Ptr: safe pointer to uninhabited type"
    match mem.dereferenceable p.thin size with
    | .ok _ => pure ()
    | .error _ => throwUb "Value::Ptr: non-dereferenceable safe pointer"
  | none =>
    match pt with
    | .vtablePtr _ =>
      ensureUb (vtableSizeAlign mem p.thin).isSome "Value::Ptr: invalid vtable pointer"
    | _ => pure ()

mutual

/-- `check_value`: is a (decoded) value well-formed at a sized type? -/
def checkValue (mem : Memory) : Value → Ty → Except Outcome Unit
  | .int i, .int t valid => do
    ensureUb (t.canRepresent i) "Value::Int: invalid integer value"
    ensureUb (valid.contains (t.toBits i)) "Value::Int: outside the valid range"
  | .int i, .char => ensureUb (0 ≤ i && isUnicodeScalar i.toNat) "invalid char"
  | .bool _, .bool => pure ()
  | .float f bits, .float g =>
    if f == g && bits < 2 ^ g.bits then pure () else throwIllFormed "float value does not match its type"
  | .ptr p, .ptr pt valid => checkPtr mem p pt valid
  | .tuple [], .fnDef _ => pure ()
  | .tuple vs, .tuple fields _ none => checkFields mem vs fields
  | .tuple vs, .array elem n => do
    ensureUb (vs.length == n) "Value::Tuple: invalid number of elements"
    checkElems mem vs elem
  | .union data, .union _ chunks _ _ => do
    ensureUb (data.length == chunks.length) "Value::Union: invalid chunk size"
    ensureUb ((data.zip chunks).all fun (d, (_, sz)) => d.length == sz)
      "Value::Union: invalid chunk data"
  | .union [bs], .opaqueBytes size _ => ensureUb (bs.length == size) "invalid opaque bytes"
  | .variant idx data, .enum vs _ repr _ _ => do
    ensureUb (variantInhabited vs idx) "Value::Variant: uninhabited variant"
    match repr with
    | .single i => ensureUb (i == idx) "Value::Variant: invalid variant"
    | .empty => throwUb "Value::Variant: uninhabited enum"
    | .multiple _ => pure ()
    checkVariant mem vs idx data
  | _, _ => throwIllFormed "check_value: value does not match type"

def checkFields (mem : Memory) : List Value → List (Offset × Ty) → Except Outcome Unit
  | [], [] => pure ()
  | v :: vs, (_, t) :: fs => do checkValue mem v t; checkFields mem vs fs
  | _, _ => throwUb "Value::Tuple: invalid number of fields"

def checkElems (mem : Memory) : List Value → Ty → Except Outcome Unit
  | [], _ => pure ()
  | v :: vs, t => do checkValue mem v t; checkElems mem vs t

def checkVariant (mem : Memory) : List Variant → Nat → Value → Except Outcome Unit
  | [], _, _ => throwUb "Value::Variant: invalid variant"
  | ⟨_, t, _⟩ :: _, 0, v => checkValue mem v t
  | _ :: vs, n + 1, v => checkVariant mem vs n v

end

/-! ## Typed memory accesses -/

/-- `typed_load`: load, decode (UB if invalid), check the value. -/
def typedLoad (mem : Memory) (p : ThinPointer) (ty : Ty) (align : Align) :
    Except Outcome Value := do
  let some size := ty.size? | throwIllFormed "typed load at an unsized type"
  let bytes ← mem.load p size align
  match ty.decode bytes with
  | some v => do checkValue mem v ty; pure v
  | none => throwUb "load at type but the data in memory violates the language invariant"

/-- `typed_store`: encode and store. -/
def typedStore (mem : Memory) (p : ThinPointer) (v : Value) (ty : Ty) (align : Align) :
    Except Outcome Memory := do
  let some bytes := ty.encode v | throwIllFormed s!"spec bug: storing an ill-formed value"
  mem.store p bytes align

-- [D33]
/-- `transmute` (D33: UB if the sizes differ; the result must be valid). -/
def transmute (mem : Memory) (v : Value) (t1 t2 : Ty) : Except Outcome Value := do
  let some s1 := t1.size? | throwIllFormed "transmute of an unsized type"
  let some s2 := t2.size? | throwIllFormed "transmute to an unsized type"
  if s1 != s2 then throwUb "transmute between types of different size"
  let some bytes := t1.encode v | throwIllFormed "spec bug: transmuting an ill-formed value"
  match t2.decode bytes with
  | some w => do checkValue mem w t2; pure w
  | none => throwUb "transmuted value is not valid at new type"

/-! ## Discriminants in memory (D28) -/

-- [D28]
/-- Read the variant index of the enum at `p` (rustc/Miri `read_discriminant`): only the tag
bytes are read. `p` must be aligned for the enum (checked by the caller). -/
def readDiscriminant (mem : Memory) (p : ThinPointer) (ty : Ty) : Except Outcome Nat := do
  let .enum vs discrTy repr _ _ := ty | throwIllFormed "discriminant of a non-enum"
  let idx ← match repr with
    | .empty => throwUb "reading the discriminant of an uninhabited enum"
    | .single i => pure i
    | .multiple tag => do
      let tp ← match mem.signedDereferenceable p tag.offset with
        | .ok _ => pure (p.wrappingOffset tag.offset)
        | .error e => throw e
      let bytes ← mem.load tp tag.tag.size .one
      let some bits := decodeBits bytes | throwUb "enum tag is uninitialized"
      match tagToVariant vs discrTy tag bits with
      | .ok i => pure i
      | .error msg => throwUb msg
  ensureUb (variantInhabited vs idx) "reading the discriminant of an uninhabited variant"
  pure idx

-- [D28]
/-- Write the tag of variant `idx` into the enum at `p` (rustc/Miri `write_discriminant`). For
variants encoded implicitly (`Single`, the niche's untagged variant), check by a validation
read that the data already encodes `idx`. -/
def writeDiscriminant (mem : Memory) (p : ThinPointer) (ty : Ty) (idx : Nat) :
    Except Outcome Memory := do
  let .enum vs _ repr _ _ := ty | throwIllFormed "SetDiscriminant of a non-enum"
  ensureUb (variantInhabited vs idx) "writing the discriminant of an uninhabited variant"
  let check : Except Outcome Memory := do
    let actual ← readDiscriminant mem p ty
    ensureUb (actual == idx) "invalid niched enum variant written"
    pure mem
  match repr with
  | .empty => throwUb "writing the discriminant of an uninhabited enum"
  | .single _ => check
  | .multiple tag =>
    match tagForVariant vs tag idx with
    | none => check
    | some bits => do
      mem.signedDereferenceable p tag.offset
      mem.store (p.wrappingOffset tag.offset) (encodeBits tag.tag.size bits) .one

end Ryo.Spec
