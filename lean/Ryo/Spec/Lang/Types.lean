/-
Ryo.Spec.Lang.Types — types with rustc's layouts.

Ports: MiniRust `lang/types.md` (`Type`, `IntType`, `Fields`, `Variant`, `layout`, `meta_kind`,
`unit_ty`), with the enum part replaced by rustc's layout description (`minimize/src/ty.rs`,
`minimize/src/enums.rs` are MiniRust's translation of the same rustc data).

Divergences:
- D2: layouts are input, not computed. Every type carries rustc's `layout_of` data: field
  offsets, size, alignment, scalar valid ranges, per-variant layouts, and for enums
  `Variants::{Empty, Single, Multiple}` with the tag's offset, integer type, valid range and
  `TagEncoding::{Direct, Niche}` (instead of MiniRust's `Discriminator` tree and `tagger`).
- D3: `ValidRange` (rustc `WrappingRange`) on integer, pointer and tag scalars.
- D4: `char` is its own type (a `u32` with Unicode scalar validity).
- D5: `float`; `opaqueBytes` for SIMD vectors and other types whose values are only bytes.
- `fnDef` (a zero-sized function item type, resolved to an instance).

Types are a nested (not mutual) inductive: an enum's variants are `VariantOf Ty`, so that
structural recursion over `Ty` works.
-/
import Ryo.Spec.Mem.Pointer

namespace Ryo.Spec

open Lean

-- [D3]
/-- rustc's `WrappingRange`: valid bit patterns `start ..= stop` of a scalar, which may wrap
around (`stop < start`). -/
structure ValidRange where
  start : Nat
  stop : Nat
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

namespace ValidRange

/-- The full range for a scalar of `size` bytes. -/
def full (size : Size) : ValidRange := ⟨0, 2 ^ (size * 8) - 1⟩

def contains (r : ValidRange) (v : Nat) : Bool :=
  if r.start ≤ r.stop then r.start ≤ v && v ≤ r.stop else r.start ≤ v || v ≤ r.stop

/-- Non-null pointers (`NonNull`, references, fn pointers). -/
def nonNull : ValidRange := ⟨1, 2 ^ 64 - 1⟩

end ValidRange

-- [D2]
/-- rustc `TagEncoding`. -/
inductive TagEncoding where
  /-- The tag is the discriminant (truncated to the tag type). -/
  | direct
  /-- Variants `lo..=hi` (except `untagged`) are encoded as `nicheStart + (v - lo)` (wrapping)
  in the tag; any other tag value means `untagged`. -/
  | niche (untagged : Nat) (lo hi : Nat) (nicheStart : Nat)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- Where and how an enum's tag is stored (rustc `Variants::Multiple`). -/
structure TagInfo where
  /-- Offset of the tag field (rustc `tag_field`'s offset). -/
  offset : Offset
  /-- The tag's integer type (`tag.primitive().to_int_ty()`; pointer tags are `usize`). -/
  tag : IntType
  /-- The tag scalar's valid range. -/
  valid : ValidRange
  encoding : TagEncoding
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

-- [D2]
/-- rustc `Variants`. -/
inductive EnumRepr where
  /-- No inhabited variant (`!`, empty enums). -/
  | empty
  /-- Only variant `idx` has a layout (rustc `Variants::Single`); no tag in memory. -/
  | single (idx : Nat)
  | multiple (tag : TagInfo)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- An enum variant. -/
structure VariantOf (α : Type) where
  /-- The discriminant value (rustc `discriminant_for_variant`). -/
  discr : Int
  /-- The variant's fields: a `tuple` type with rustc's offsets, of the enum's size. -/
  fields : α
  /-- Whether the variant is inhabited (rustc `is_variant_uninhabited` is the negation). -/
  inhabited : Bool := true
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

-- [D2] [D4] [D5] [D27]
inductive Ty where
  | int (t : IntType) (valid : ValidRange)
  | bool
  /-- D4. -/
  | char
  /-- D5. -/
  | float (f : FloatTy)
  /-- References, raw pointers, the pointer in `Box`, fn pointers, vtable pointers. -/
  | ptr (p : PtrType) (valid : ValidRange)
  /-- A function item: zero-sized, resolved to an instance. -/
  | fnDef (i : InstanceId)
  /-- Tuples, structs, closures: sized fields at rustc offsets and an optional unsized tail. -/
  | tuple (fields : List (Offset × Ty)) (head : TupleHeadLayout) (tail : Option Ty)
  | array (elem : Ty) (count : Nat)
  /-- `[T]`; `str` is `[u8]` (UTF-8 validity is not a language invariant). -/
  | slice (elem : Ty)
  | union (fields : List (Offset × Ty)) (chunks : List (Offset × Size)) (size : Size) (align : Align)
  | enum (variants : List (VariantOf Ty)) (discrTy : IntType) (repr : EnumRepr) (size : Size)
      (align : Align)
  | traitObject (t : TraitName)
  /-- Values that are only bytes (SIMD vectors, ...). -/
  | opaqueBytes (size : Size) (align : Align)
deriving Repr, Inhabited, ToJson, FromJson

abbrev Variant := VariantOf Ty

/-! ## Structural equality

`deriving BEq`/`DecidableEq` cannot handle the nested inductive `Ty` (Lean derives an opaque
`partial` `BEq`, about which nothing can be proved). `Ty.beq` is structural, `Ty.beq_iff`
proves it decides equality, and `DecidableEq Ty` is built from it, so `==` on `Ty` (through
`instBEqOfDecidableEq`) is a `LawfulBEq`. -/

mutual

def Ty.beq : Ty → Ty → Bool
  | .int t r, .int t' r' => t == t' && r == r'
  | .bool, .bool => true
  | .char, .char => true
  | .float f, .float f' => f == f'
  | .ptr p r, .ptr p' r' => p == p' && r == r'
  | .fnDef i, .fnDef i' => i == i'
  | .tuple fs h tl, .tuple fs' h' tl' => Ty.beqFields fs fs' && h == h' && Ty.beqOpt tl tl'
  | .array e n, .array e' n' => Ty.beq e e' && n == n'
  | .slice e, .slice e' => Ty.beq e e'
  | .union fs cs sz al, .union fs' cs' sz' al' =>
    Ty.beqFields fs fs' && cs == cs' && sz == sz' && al == al'
  | .enum vs d r sz al, .enum vs' d' r' sz' al' =>
    Ty.beqVariants vs vs' && d == d' && r == r' && sz == sz' && al == al'
  | .traitObject n, .traitObject n' => n == n'
  | .opaqueBytes sz al, .opaqueBytes sz' al' => sz == sz' && al == al'
  | _, _ => false

def Ty.beqFields : List (Offset × Ty) → List (Offset × Ty) → Bool
  | [], [] => true
  | (o, t) :: fs, (o', t') :: fs' => o == o' && Ty.beq t t' && Ty.beqFields fs fs'
  | _, _ => false

def Ty.beqOpt : Option Ty → Option Ty → Bool
  | none, none => true
  | some t, some t' => Ty.beq t t'
  | _, _ => false

def Ty.beqVariants : List (VariantOf Ty) → List (VariantOf Ty) → Bool
  | [], [] => true
  | ⟨d, t, i⟩ :: vs, ⟨d', t', i'⟩ :: vs' =>
    d == d' && Ty.beq t t' && i == i' && Ty.beqVariants vs vs'
  | _, _ => false

end

mutual

theorem Ty.beq_iff : (a b : Ty) → Ty.beq a b = true ↔ a = b
  | .int .., b | .bool, b | .char, b | .float _, b | .ptr .., b | .fnDef _, b
  | .traitObject _, b | .opaqueBytes .., b => by cases b <;> simp [Ty.beq]
  | .tuple fs _ tl, b => by
    cases b <;> simp [Ty.beq, Ty.beqFields_iff fs, Ty.beqOpt_iff tl, and_assoc]
  | .array e _, b => by cases b <;> simp [Ty.beq, Ty.beq_iff e]
  | .slice e, b => by cases b <;> simp [Ty.beq, Ty.beq_iff e]
  | .union fs .., b => by cases b <;> simp [Ty.beq, Ty.beqFields_iff fs, and_assoc]
  | .enum vs .., b => by cases b <;> simp [Ty.beq, Ty.beqVariants_iff vs, and_assoc]

theorem Ty.beqFields_iff : (a b : List (Offset × Ty)) → Ty.beqFields a b = true ↔ a = b
  | [], b => by cases b <;> simp [Ty.beqFields]
  | (_, t) :: fs, b => by
    cases b with
    | nil => simp [Ty.beqFields]
    | cons p _ =>
      obtain ⟨_, _⟩ := p
      simp [Ty.beqFields, Ty.beq_iff t, Ty.beqFields_iff fs, and_assoc]

theorem Ty.beqOpt_iff : (a b : Option Ty) → Ty.beqOpt a b = true ↔ a = b
  | none, b => by cases b <;> simp [Ty.beqOpt]
  | some t, b => by cases b <;> simp [Ty.beqOpt, Ty.beq_iff t]

theorem Ty.beqVariants_iff : (a b : List (VariantOf Ty)) → Ty.beqVariants a b = true ↔ a = b
  | [], b => by cases b <;> simp [Ty.beqVariants]
  | ⟨_, t, _⟩ :: vs, b => by
    cases b with
    | nil => simp [Ty.beqVariants]
    | cons p _ =>
      obtain ⟨_, _, _⟩ := p
      simp [Ty.beqVariants, Ty.beq_iff t, Ty.beqVariants_iff vs, VariantOf.mk.injEq, and_assoc]

end

instance : DecidableEq Ty := fun a b => decidable_of_iff _ (Ty.beq_iff a b)

namespace Ty

/-- `Type::layout`. -/
def layout : Ty → LayoutStrategy
  | int t _ => .sized t.size t.align
  | bool => .sized 1 .one
  | char => .sized 4 ⟨2⟩
  | float f => .sized f.size f.align
  | ptr p _ => if p.isWide then .sized 16 Target.PTR_ALIGN else .sized 8 Target.PTR_ALIGN
  | fnDef _ => .sized 0 .one
  | tuple _ head none =>
    let (s, a) := head.headSizeAndAlign
    .sized s a
  | tuple _ head (some t) => .tuple head t.layout
  | array e n =>
    match e.layout with
    | .sized s a => .sized (s * n) a
    | _ => .sized 0 .one  -- ill-formed (WF rejects unsized elements)
  | slice e =>
    match e.layout with
    | .sized s a => .slice s a
    | _ => .slice 0 .one  -- ill-formed
  | union _ _ s a => .sized s a
  | enum _ _ _ s a => .sized s a
  | traitObject t => .traitObject t
  | opaqueBytes s a => .sized s a

/-- `Type::meta_kind`: the metadata kind of a pointer to this type. -/
def metaKind (t : Ty) : PointerMetaKind := t.layout.metaKind

def size? (t : Ty) : Option Size := t.layout.size?
def align? (t : Ty) : Option Align := t.layout.align?
def isSized (t : Ty) : Bool := t.layout.isSized

/-- Size of a sized type (0 for unsized: callers check `isSized`). -/
def size (t : Ty) : Size := t.size?.getD 0
def align (t : Ty) : Align := t.align?.getD .one

def pointeeInfo (t : Ty) (inhabited := true) : PointeeInfo := ⟨t.layout, inhabited⟩

end Ty

/-- The unit type `()`. -/
def unitTy : Ty := .tuple [] ⟨0, .one, none⟩ none

def intTy (t : IntType) : Ty := .int t (ValidRange.full t.size)
def usizeTy : Ty := intTy .usize
def isizeTy : Ty := intTy .isize
def u8Ty : Ty := intTy .u8
def u32Ty : Ty := intTy .u32
def i8Ty : Ty := intTy .i8
def i32Ty : Ty := intTy .i32

/-- `*const T` / `*mut T` for a pointee type. -/
def rawPtrTy (pointee : Ty) (mutbl := false) : Ty :=
  .ptr (.raw mutbl pointee.pointeeInfo) (ValidRange.full 8)

/-- `&T` / `&mut T`. -/
def refTy (pointee : Ty) (mutbl := false) : Ty :=
  .ptr (.ref mutbl pointee.pointeeInfo) ValidRange.nonNull

/-- `fn(..)` pointer type. -/
def fnPtrTy : Ty := .ptr .fnPtr ValidRange.nonNull

/-- A thin raw pointer to bytes (`*mut u8`). -/
def bytePtrTy : Ty := rawPtrTy u8Ty true

/-- The type of a pointer's metadata as a value (MiniRust `PointerMetaKind::ty`). -/
def PointerMetaKind.ty : PointerMetaKind → Ty
  | .none => unitTy
  | .elementCount => usizeTy
  | .vtablePointer t => .ptr (.vtablePtr t) ValidRange.nonNull

/-- A tuple type from sized fields at the given offsets, with rustc's size and alignment. -/
def tupleTy (fields : List (Offset × Ty)) (size : Size) (align : Align) : Ty :=
  .tuple fields ⟨size, align, none⟩ none

/-- The `(T, bool)` result of `*WithOverflow` for an integer type with natural layout. -/
def IntType.withOverflowTy (t : IntType) : Ty :=
  tupleTy [(0, intTy t), (t.size, .bool)] (alignTo (t.size + 1) t.align) t.align

/-- The never type `!`. -/
def neverTy : Ty := .enum [] IntType.u8 .empty 0 .one

end Ryo.Spec
