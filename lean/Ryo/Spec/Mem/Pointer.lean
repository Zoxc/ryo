/-
Ryo.Spec.Mem.Pointer — pointers and what they point to.

Ports: MiniRust `mem/pointer.md` (`ThinPointer`, `PointerMeta`, `Pointer`, `wrapping_offset`,
`TupleHeadLayout`, `LayoutStrategy`, `PointeeInfo`, `TraitName`, `PointerMetaKind`, `PtrType`,
`safe_pointee`, `meta_kind`), and `lang/types.md` § layout of `TupleHeadLayout`/`LayoutStrategy`.

Differences:
- Provenance is just the `AllocId` (MiniRust `BasicMemory` provenance with `()` extra).
- Addresses are `Nat` below `2^64` (MiniRust: `Int`, kept in bounds by `wrapping_offset`).
- `PointeeInfo` drops `unsafe_cells`, `freeze`, `unpin`: they only feed aliasing models (D16).
- `PtrType.raw` carries the pointee's `LayoutStrategy` (MiniRust: only the metadata kind), so
  `Offset` and `ptr_offset_from` can scale by the pointee size (D10, D20).
- D29: `PointerMeta.vtablePointer` points at a vtable *allocation* in memory (a `Global`),
  whose words `[drop_in_place, size, align, entries...]` are read by `computeSizeAndAlign`.
-/
import Ryo.Spec.Prelude.Basic
import Ryo.Spec.Prelude.Target

namespace Ryo.Spec

open Lean

abbrev Provenance := AllocId

/-- A thin pointer: an address and optional provenance. -/
structure ThinPointer where
  addr : Nat
  prov : Option Provenance
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- Runtime metadata of a wide pointer. -/
inductive PointerMeta where
  /-- Element count of a slice (`usize`). -/
  | elementCount (n : Nat)
  /-- Pointer to a vtable allocation (D29). -/
  | vtablePointer (p : ThinPointer)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- A pointer, thin (`meta = none`) or wide. -/
structure Pointer where
  thin : ThinPointer
  metadata : Option PointerMeta := none
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

namespace ThinPointer

/-- `wrapping_offset`: offset the address modulo `2^64`, keep provenance. -/
def wrappingOffset (p : ThinPointer) (off : Int) : ThinPointer :=
  { p with addr := ((p.addr + off) % (Target.ADDR_LIMIT : Int)).toNat }

def widen (p : ThinPointer) (md : Option PointerMeta := none) : Pointer := ⟨p, md⟩

def null : ThinPointer := ⟨0, none⟩

end ThinPointer

/-- Describes the sized head of a tuple/struct `(head.., tail)`. -/
structure TupleHeadLayout where
  /-- Where the head ends (for an unsized struct: rustc's unadjusted offset of the tail field;
  for a sized one: the size). Not necessarily a multiple of `align`. -/
  «end» : Offset
  /-- Alignment of the head (capped by `packed`). -/
  align : Align
  /-- `repr(packed(n))`: the tail's alignment is capped at this. -/
  packedAlign : Option Align := none
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- The name of a trait, identifying what a vtable is for. -/
abbrev TraitName := String

/-- How the size and alignment of a pointee are determined. -/
inductive LayoutStrategy where
  | sized (size : Size) (align : Align)
  /-- `[T]`: element size and alignment. -/
  | slice (elemSize : Size) (align : Align)
  /-- `dyn Trait`: from the vtable (D29). -/
  | traitObject (t : TraitName)
  /-- A sized head and an unsized tail. -/
  | tuple (head : TupleHeadLayout) (tail : LayoutStrategy)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- The statically known kind of metadata of a pointer. -/
inductive PointerMetaKind where
  | none
  | elementCount
  | vtablePointer (t : TraitName)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

namespace TupleHeadLayout

/-- The tail's alignment after the `packed` cap. -/
def cappedTailAlign (h : TupleHeadLayout) (tailAlign : Align) : Align :=
  match h.packedAlign with
  | some p => tailAlign.min p
  | none => tailAlign

/-- Offset of the tail given its (dynamic) alignment (cg_ssa `project_field` for unsized
fields: the unadjusted offset rounded up to the dynamic alignment). -/
def tailOffset (h : TupleHeadLayout) (tailAlign : Align) : Offset :=
  alignTo h.end (h.cappedTailAlign tailAlign)

/-- Size and alignment of the whole tuple given the tail's size and alignment
(cg_ssa `size_and_align_of_dst`). -/
def fullSizeAndAlign (h : TupleHeadLayout) (tailSize : Size) (tailAlign : Align) : Size × Align :=
  let align := (h.cappedTailAlign tailAlign).max h.align
  let e := h.tailOffset tailAlign + tailSize
  (alignTo e align, align)

/-- Size and alignment without a tail. -/
def headSizeAndAlign (h : TupleHeadLayout) : Size × Align := (alignTo h.end h.align, h.align)

end TupleHeadLayout

namespace LayoutStrategy

def isSized : LayoutStrategy → Bool
  | .sized .. => true
  | _ => false

def metaKind : LayoutStrategy → PointerMetaKind
  | .sized .. => .none
  | .slice .. => .elementCount
  | .traitObject t => .vtablePointer t
  | .tuple _ tail => tail.metaKind

/-- Size, if statically known. -/
def size? : LayoutStrategy → Option Size
  | .sized s _ => some s
  | _ => none

def align? : LayoutStrategy → Option Align
  | .sized _ a => some a
  | _ => none

/-- `compute_size_and_align`: dynamic size and alignment from the metadata. `vtable` reads
size and alignment out of a vtable (D29). `none` if the metadata does not fit the strategy
(MiniRust: a spec bug) or the vtable is invalid. -/
def computeSizeAndAlign (vtable : ThinPointer → Option (Size × Align)) :
    LayoutStrategy → Option PointerMeta → Option (Size × Align)
  | .sized s a, none => some (s, a)
  | .slice es a, some (.elementCount n) => some (n * es, a)
  | .traitObject _, some (.vtablePointer p) => vtable p
  | .tuple head tail, some md => do
    let (ts, ta) ← computeSizeAndAlign vtable tail (some md)
    pure (head.fullSizeAndAlign ts ta)
  | _, _ => none

end LayoutStrategy

/-- What we know about the target of a pointer. -/
structure PointeeInfo where
  layout : LayoutStrategy
  inhabited : Bool := true
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- Pointer types (MiniRust `PtrType`). -/
inductive PtrType where
  /-- `&T` / `&mut T`. -/
  | ref (mutbl : Bool) (pointee : PointeeInfo)
  /-- The pointer inside `Box<T>` (rustc's box pointer scalar). -/
  | box (pointee : PointeeInfo)
  /-- `*const T` / `*mut T`. The pointee info is used only for its metadata kind and for
  scaling `Offset`/`ptr_offset_from`. -/
  | raw (mutbl : Bool) (pointee : PointeeInfo)
  /-- `fn(..)` pointers. -/
  | fnPtr
  /-- A stand-alone vtable pointer (the metadata of `*const dyn Trait`). -/
  | vtablePtr (t : TraitName)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

namespace PtrType

/-- `safe_pointee`: the pointee of references and boxes. -/
def safePointee : PtrType → Option PointeeInfo
  | .ref _ p | .box p => some p
  | _ => none

def pointee? : PtrType → Option PointeeInfo
  | .ref _ p | .box p | .raw _ p => some p
  | _ => none

def metaKind : PtrType → PointerMetaKind
  | .ref _ p | .box p | .raw _ p => p.layout.metaKind
  | .fnPtr | .vtablePtr _ => .none

def isWide (p : PtrType) : Bool := p.metaKind != .none

end PtrType

end Ryo.Spec
