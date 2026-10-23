/-
Ryo.Spec.Lang.WellFormed — well-formed types (layouts) and value shapes.

Ports: MiniRust `lang/well-formed.md` § "Well-formed layouts and types" (`IntType::check_wf`,
`Type::check_wf`, `LayoutStrategy::check_wf`, `TupleHeadLayout::check_wf`).

D2: layouts are rustc's, so this only checks internal consistency (fields inside the size,
sized fields and elements, variants as large as the enum, tags inside the enum, valid ranges
inside the scalar), never recomputes rustc's choices. `Align` is a power of two by
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

/-- Do non-empty byte ranges overlap? -/
def rangesDisjoint (rs : List (Offset × Size)) : Bool :=
  let rs := rs.filter (·.2 != 0)
  rs.zipIdx.all fun ((o1, s1), i) =>
    rs.zipIdx.all fun ((o2, s2), j) => i == j || o1 + s1 ≤ o2 || o2 + s2 ≤ o1

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
      (chunks.all fun (off, s) => off + s ≤ size) && Target.validSize size
  | .enum vs discrTy repr size _ =>
    discrTy.wf && Target.validSize size && Ty.wfVariants vs size &&
      match repr with
      | .empty => vs.all (!·.inhabited)
      | .single i => i < vs.length
      | .multiple tag =>
        tag.tag.wf && tag.offset + tag.tag.size ≤ size && tag.valid.wf tag.tag.size &&
          match tag.encoding with
          | .direct => true
          | .niche u lo hi _ => u < vs.length && lo ≤ hi && hi < vs.length
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
  | .float f _, .float g => f == g
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
