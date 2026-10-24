/-
Ryo.Spec.Lang.WellFormed — well-formed types (layouts) and value shapes.

Ports: MiniRust `lang/well-formed.md` § "Well-formed layouts and types" (`IntType::check_wf`,
`Type::check_wf`, `LayoutStrategy::check_wf`, `TupleHeadLayout::check_wf`).

D2: layouts are rustc's, so this only checks internal consistency (fields inside the size,
disjoint fields and union chunks, sized fields and elements, variants as large as the enum,
tags inside the enum and consistent with the variants (`variantTagWf`), valid ranges inside
the scalar), never recomputes rustc's choices. These are what the representation laws
(`Ryo.Spec.Theorems`) need. `Align` is a power of two by
construction.
-/
import Ryo.Spec.Lang.Representation

namespace Ryo.Spec

def IntType.wf (t : IntType) : Bool := [1, 2, 4, 8, 16].contains t.size

def ValidRange.wf (r : ValidRange) (size : Size) : Bool :=
  r.start < 2 ^ (size * 8) && r.stop < 2 ^ (size * 8)

def LayoutStrategy.wf : LayoutStrategy → Bool
  | .sized s _ => Target.validSize s
  | .slice es _ => Target.validSize es
  | .traitObject _ => true
  | .tuple head tail => Target.validSize head.end && tail.wf && !tail.isSized

def PtrType.wf : PtrType → Bool
  | .ref _ p | .box p | .raw _ p => p.layout.wf
  | .fnPtr | .vtablePtr _ => true

/-- Are two byte ranges disjoint (empty ranges are disjoint from everything)? -/
def rangeDisjoint (a b : Offset × Size) : Bool :=
  a.2 == 0 || b.2 == 0 || a.1 + a.2 ≤ b.1 || b.1 + b.2 ≤ a.1

/-- Are the byte ranges pairwise disjoint? -/
def rangesDisjoint : List (Offset × Size) → Bool
  | [] => true
  | r :: rs => rs.all (rangeDisjoint r) && rangesDisjoint rs

/-! ## Enum tags (D2)

What the representation laws need from an enum's `TagInfo` (`Ryo.Spec.Theorems`). rustc's
layouts satisfy these by construction; they are checked here because layouts are input. -/

namespace ValidRange

/-- The range as at most two (non-wrapping, inclusive) intervals of values below `m`. -/
def intervals (r : ValidRange) (m : Nat) : List (Nat × Nat) :=
  if r.start ≤ r.stop then [(r.start, r.stop)] else [(r.start, m - 1), (0, r.stop)]

/-- Every value of `r` is in `s` (values below `m`; sufficient, not necessary). -/
def subset (r s : ValidRange) (m : Nat) : Bool :=
  (r.intervals m).all fun (a, b) => b < a || (s.intervals m).any fun (c, d) => c ≤ a && b ≤ d

/-- No value is in both `r` and `s` (values below `m`). -/
def disjoint (r s : ValidRange) (m : Nat) : Bool :=
  (r.intervals m).all fun (a, b) => (s.intervals m).all fun (c, d) =>
    b < a || d < c || b < c || d < a

end ValidRange

/-- The tag values of a niche encoding's tagged variants, `start ..= start + (hi - lo)`
(wrapping): the tag values `tagToVariant` does not map to the untagged variant. -/
def nicheRange (tag : TagInfo) (lo hi start : Nat) : ValidRange :=
  ⟨start % tag.tag.modulus, (start % tag.tag.modulus + (hi - lo)) % tag.tag.modulus⟩

mutual

/-- The valid range of the scalar that every valid value of `t` stores at bytes
`[off, off + size)`, if there is one (the scalars rustc uses as niches: integers, `bool`,
`char`, the address of a pointer, an enum's tag, found through struct fields, the first array
element and the variant of a `Single` enum). -/
def Ty.scalarRange : Ty → Offset → Size → Option ValidRange
  | .int t r, off, size => if off == 0 && size == t.size then some r else none
  | .bool, off, size => if off == 0 && size == 1 then some ⟨0, 1⟩ else none
  | .char, off, size => if off == 0 && size == 4 then some ⟨0, 0x10FFFF⟩ else none
  | .ptr _ r, off, size => if off == 0 && size == 8 then some r else none
  | .tuple fs _ none, off, size => Ty.scalarRangeFields fs off size
  | .array e n, off, size => if 0 < n && off + size ≤ e.size then e.scalarRange off size else none
  | .enum vs _ repr _ _, off, size =>
    match repr with
    | .multiple tag => if off == tag.offset && size == tag.tag.size then some tag.valid else none
    | .single i => Ty.scalarRangeVariant vs i off size
    | .empty => none
  | _, _, _ => none

/-- The first field containing `[off, off + size)`. -/
def Ty.scalarRangeFields : List (Offset × Ty) → Offset → Size → Option ValidRange
  | [], _, _ => none
  | (o, t) :: fs, off, size =>
    if o ≤ off && off + size ≤ o + t.size then t.scalarRange (off - o) size
    else Ty.scalarRangeFields fs off size

def Ty.scalarRangeVariant : List Variant → Nat → Offset → Size → Option ValidRange
  | [], _, _, _ => none
  | ⟨_, t, _⟩ :: _, 0, off, size => t.scalarRange off size
  | _ :: vs, n + 1, off, size => Ty.scalarRangeVariant vs n off size

end

/-- The fields of a variant type avoid the bytes `[off, off + n)`. -/
def fieldsAvoid (t : Ty) (off n : Nat) : Bool :=
  match t with
  | .tuple fs _ none => fs.all fun (o, ft) => rangeDisjoint (o, ft.size) (off, n)
  | _ => false

-- [D2]
/-- The tag of inhabited variant `idx` round-trips: a tagged variant's tag value is valid,
decodes to `idx` and lies outside its fields; the untagged variant's data stores a scalar at
the tag's place whose values all decode to it (they are valid tag values outside the niche
values). -/
def variantTagWf (vs : List Variant) (discrTy : IntType) (tag : TagInfo) (idx : Nat) : Bool :=
  match vs[idx]? with
  | none => true
  | some v =>
    !v.inhabited ||
    match tagForVariant vs tag idx with
    | some bits =>
      bits < tag.tag.modulus && tag.valid.contains bits &&
        fieldsAvoid v.fields tag.offset tag.tag.size &&
        match tagToVariant vs discrTy tag bits with
        | .ok i => i == idx
        | .error _ => false
    | none =>
      match tag.encoding, v.fields.scalarRange tag.offset tag.tag.size with
      | .niche _ lo hi start, some r =>
        r.wf tag.tag.size && r.subset tag.valid tag.tag.modulus &&
          r.disjoint (nicheRange tag lo hi start) tag.tag.modulus
      | _, _ => false

mutual

/-- `Type::check_wf` (as a Boolean; `Ty.wfMsg` explains failures). -/
def Ty.wf : Ty → Bool
  | .int t r => t.wf && r.wf t.size
  | .bool | .char | .fnDef _ | .traitObject _ => true
  | .float _ => true
  | .ptr p r => p.wf && r.wf 8
  | .tuple fields head tail =>
    Ty.wfFields fields &&
      (fields.all fun (off, t) => off + t.size ≤ head.end) &&
      rangesDisjoint (fields.map fun (o, t) => (o, t.size)) &&
      Target.validSize (head.headSizeAndAlign.1) &&
      match tail with
      | none => true
      | some t => t.wf && !t.isSized
  | .array e n => e.wf && e.isSized && Target.validSize (e.size * n)
  | .slice e => e.wf && e.isSized
  | .union fields chunks size _ =>
    Ty.wfFields fields && (fields.all fun (off, t) => off + t.size ≤ size) &&
      (chunks.all fun (off, s) => off + s ≤ size) && rangesDisjoint chunks &&
      Target.validSize size
  | .enum vs discrTy repr size _ =>
    discrTy.wf && Target.validSize size && Ty.wfVariants vs size &&
      match repr with
      | .empty => vs.all (!·.inhabited)
      | .single i => i < vs.length
      | .multiple tag =>
        tag.tag.wf && tag.offset + tag.tag.size ≤ size && tag.valid.wf tag.tag.size &&
          (match tag.encoding with
           -- the tag may be wider than the discriminant type: without an explicit `repr`,
           -- rustc widens it to the variants' alignment (`layout_of_enum`, e.g. the `u128`
           -- tag of `Option<i128>`), so it isn't compared with `discrTy`
           | .direct => true
           | .niche u lo hi _ => u < vs.length && lo ≤ hi && hi < vs.length &&
               hi - lo < tag.tag.modulus) &&
          (List.range vs.length).all (variantTagWf vs discrTy tag)
  | .opaqueBytes s _ => Target.validSize s

def Ty.wfFields : List (Offset × Ty) → Bool
  | [] => true
  | (_, t) :: fs => t.wf && t.isSized && Ty.wfFields fs

def Ty.wfVariants : List Variant → Size → Bool
  | [], _ => true
  | ⟨_, t, _⟩ :: vs, size =>
    t.wf && (match t with | .tuple _ _ none => true | _ => false) && t.size == size &&
      Ty.wfVariants vs size

end

mutual

/-- The shape part of `check_value` (no memory: pointer dereferenceability is not checked). -/
def Value.wfShape : Value → Ty → Bool
  | .int i, .int t r => t.canRepresent i && r.contains (t.toBits i)
  | .int i, .char => 0 ≤ i && isUnicodeScalar i.toNat
  | .bool _, .bool => true
  | .float f b, .float g => f == g && b < 2 ^ g.bits
  | .ptr p, .ptr pt r => r.contains p.thin.addr &&
      (match p.metadata, pt.metaKind with
       | none, .none => true
       | some (.elementCount _), .elementCount => true
       | some (.vtablePointer _), .vtablePointer _ => true
       | _, _ => false)
  | .tuple [], .fnDef _ => true
  | .tuple vs, .tuple fields _ none => Value.wfShapeFields vs fields
  | .tuple vs, .array e n => vs.length == n && Value.wfShapeElems vs e
  | .union d, .union _ cs _ _ => d.length == cs.length &&
      (d.zip cs).all fun (b, (_, s)) => b.length == s
  | .union [bs], .opaqueBytes s _ => bs.length == s
  | .variant i d, .enum vs _ _ _ _ => variantInhabited vs i && Value.wfShapeVariant vs i d
  | _, _ => false

def Value.wfShapeFields : List Value → List (Offset × Ty) → Bool
  | [], [] => true
  | v :: vs, (_, t) :: fs => v.wfShape t && Value.wfShapeFields vs fs
  | _, _ => false

def Value.wfShapeElems : List Value → Ty → Bool
  | [], _ => true
  | v :: vs, t => v.wfShape t && Value.wfShapeElems vs t

def Value.wfShapeVariant : List Variant → Nat → Value → Bool
  | [], _, _ => false
  | ⟨_, t, _⟩ :: _, 0, v => v.wfShape t
  | _ :: vs, n + 1, v => Value.wfShapeVariant vs n v

end

/-- `WfTy` as a proposition. -/
def WfTy (t : Ty) : Prop := t.wf = true

/-- `WfValue` as a proposition (the memory-independent part of `check_value`). -/
def WfValue (v : Value) (t : Ty) : Prop := v.wfShape t = true

end Ryo.Spec
