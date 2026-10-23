/-
Ports of MiniRust `tooling/minitest/src/tests/{enum_discriminant, enum_downcast,
enum_representation}.rs`, adapted to rustc layouts (D2: `Variants::{Empty, Single, Multiple}`
with `TagEncoding::{Direct, Niche}` instead of MiniRust's discriminator trees) and to D28
(`Discriminant`/`SetDiscriminant` follow rustc/Miri).
-/
import RyoTest.Harness

namespace RyoTest.Enum

open Ryo.Spec Ryo.Spec.Build

/-- `#[repr(u8)] enum E { A(u8) = 0, B(u16) = 1 }`: tag `u8` at 0, `A.0` at 1, `B.0` at 2. -/
def directEnum : Ty :=
  .enum [variant 0 [(1, u8)] 4 2, variant 1 [(2, u16)] 4 2] IntType.u8
    (.multiple ⟨0, IntType.u8, ⟨0, 1⟩, .direct⟩) 4 (Align.ofBytes 2)

/-- `Option<bool>`: `None` is the niche value 2 of the `bool`, `Some` is untagged. -/
def optBool : Ty :=
  .enum [variant 0 [] 1 1, variant 1 [(0, .bool)] 1 1] IntType.isize
    (.multiple ⟨0, IntType.u8, ⟨0, 2⟩, .niche 1 0 0 2⟩) 1 .one

/-- `enum N { A, B(bool), C }` with niche variants `0..=2` covering the untagged `B`:
`A` ↦ 2, `C` ↦ 4, and 3 (the niche slot of `B`) is invalid. -/
def nicheAroundUntagged : Ty :=
  .enum [variant 0 [] 1 1, variant 1 [(0, .bool)] 1 1, variant 2 [] 1 1] IntType.isize
    (.multiple ⟨0, IntType.u8, ⟨0, 4⟩, .niche 1 0 2 2⟩) 1 .one

/-- `#[repr(i8)] enum Neg { A = -1, B = -2 }`. -/
def negEnum : Ty :=
  .enum [variant (-1) [] 1 1, variant (-2) [] 1 1] IntType.i8
    (.multiple ⟨0, IntType.u8, ⟨0xFE, 0xFF⟩, .direct⟩) 1 .one

/-- `#[repr(u32)] enum Big { A = 0, B = 70000 }`. -/
def bigTagEnum : Ty :=
  .enum [variant 0 [] 4 4, variant 70000 [] 4 4] IntType.u32
    (.multiple ⟨0, IntType.u32, ⟨0, 70000⟩, .direct⟩) 4 (Align.ofBytes 4)

/-- `enum E { A(!), B(u8) }`: `Variants::Single { index: 1 }`. -/
def singleEnum : Ty :=
  .enum [variant 0 [(0, neverTy)] 1 1 (inhabited := false), variant 1 [(0, u8)] 1 1] IntType.isize
    (.single 1) 1 .one

/-- Read the raw first byte of a local. -/
def rawByte (l : Local) : FnB Operand := do
  let p ← newLocal (rawTo u8)
  storageLive p
  assignL p (.rawPtr false (place l))
  pure (copy ((place p).deref u8))

/-- Overwrite the first byte(s) of a local. -/
def writeRaw (l : Local) (ty : Ty) (v : Operand) : FnB Unit := do
  let p ← newLocal (rawTo ty true)
  storageLive p
  assignL p (.rawPtr true (place l))
  assign ((place p).deref ty) (.use v)

def discrIs (l : Local) (ty : Ty) (d : Int) : FnB Unit := do
  assumeEq (← tmp ty (.discriminant (place l))) (cint ty d)

def directWorks : Program := mainOnly do
  let e ← newLocal directEnum
  storageLive e
  assignL e (.aggregate (.adt 1 none) [cint u16 0x1234])
  discrIs e u8 1
  assumeEq (← rawByte e) (cu8 1)
  assumeEq (copy (((place e).downcast 1).field 0 u16)) (cint u16 0x1234)
  -- SetDiscriminant writes the tag only: data stays
  assign (((place e).downcast 0).field 0 u8) (.use (cu8 9))
  stmt (.setDiscriminant (place e) 0)
  discrIs e u8 0
  assumeEq (copy (((place e).downcast 0).field 0 u8)) (cu8 9)
  -- a whole-value copy decodes the active variant
  let e2 ← newLocal directEnum
  storageLive e2
  assignL e2 (.use (copyL e))
  discrIs e2 u8 0
  ret

def uninitDiscriminant : Program := mainOnly do
  let e ← newLocal directEnum
  storageLive e
  discrIs e u8 0
  ret

def invalidDiscriminant : Program := mainOnly do
  let e ← newLocal directEnum
  storageLive e
  writeRaw e u8 (cu8 7)
  discrIs e u8 0
  ret

def invalidLoad : Program := mainOnly do
  let e ← newLocal directEnum
  storageLive e
  assignL e (.aggregate (.adt 0 none) [cu8 1])
  writeRaw e u8 (cu8 7)
  let _ ← tmp directEnum (.use (copyL e))
  ret

def misalignedDiscriminant : Program := mainOnly do
  let buf ← newLocal (array u16 4)
  storageLive buf
  assignL buf (.aggregate .array [cint u16 0, cint u16 0, cint u16 0, cint u16 0])
  let p ← tmp (rawTo u8) (.rawPtr false (place buf))
  let q ← tmp (rawTo u8) (.binaryOp .offset p (cusize 1))
  let r ← newLocal (rawTo directEnum)
  storageLive r
  assignL r (.cast .ptrToPtr q (rawTo directEnum))
  let _ ← tmp u8 (.discriminant ((place r).deref directEnum))
  ret

def nicheWorks : Program := mainOnly do
  let o ← newLocal optBool
  storageLive o
  assignL o (.aggregate (.adt 0 none) [])
  assumeEq (← rawByte o) (cu8 2)
  discrIs o isize 0
  assignL o (.aggregate (.adt 1 none) [cbool true])
  assumeEq (← rawByte o) (cu8 1)
  discrIs o isize 1
  -- SetDiscriminant of the untagged variant writes nothing (after a validation read)
  stmt (.setDiscriminant (place o) 1)
  assumeEq (copy (((place o).downcast 1).field 0 .bool)) (cbool true)
  ret

def nicheInvalidByte : Program := mainOnly do
  let o ← newLocal optBool
  storageLive o
  writeRaw o u8 (cu8 3)
  discrIs o isize 0
  ret

def nicheUntaggedSlot : Program := mainOnly do
  let n ← newLocal nicheAroundUntagged
  storageLive n
  assignL n (.aggregate (.adt 2 none) [])
  assumeEq (← rawByte n) (cu8 4)
  writeRaw n u8 (cu8 3)
  discrIs n isize 1
  ret

def setUntaggedMismatch : Program := mainOnly do
  let o ← newLocal optBool
  storageLive o
  assignL o (.aggregate (.adt 0 none) [])
  stmt (.setDiscriminant (place o) 1)
  ret

def transmuteIntoNiche : Program := mainOnly do
  let _ ← tmp optBool (.cast .transmute (cu8 3) optBool)
  ret

def negativeDiscriminants : Program := mainOnly do
  let e ← newLocal negEnum
  storageLive e
  assignL e (.aggregate (.adt 1 none) [])
  discrIs e i8 (-2)
  assumeEq (← rawByte e) (cu8 0xFE)
  ret

def largerTag : Program := mainOnly do
  let e ← newLocal bigTagEnum
  storageLive e
  stmt (.setDiscriminant (place e) 1)
  discrIs e u32 70000
  ret

def singleVariant : Program := mainOnly do
  let e ← newLocal singleEnum
  storageLive e
  assignL e (.aggregate (.adt 1 none) [cu8 5])
  discrIs e isize 1
  let _ ← tmp singleEnum (.use (copyL e))
  ret

def writeUninhabited : Program := mainOnly do
  let e ← newLocal singleEnum
  storageLive e
  stmt (.setDiscriminant (place e) 0)
  ret

def loadNever : Program := mainOnly do
  let e ← newLocal neverTy
  storageLive e
  let _ ← tmp neverTy (.use (copyL e))
  ret

def downcastOutOfRange : Program := mainOnly do
  let e ← newLocal directEnum
  storageLive e
  let _ ← tmp u8 (.use (copy (((place e).downcast 2).field 0 u8)))
  ret

def variantSizeIllFormed : Program := mainOnly do
  let e ← newLocal (.enum [variant 0 [] 2 1] IntType.u8 (.single 0) 1 .one)
  storageLive e
  ret

def tests : List TestCase := [
  ⟨"enum/direct_works (D2, D28)", fun _ => expectReturn directWorks⟩,
  ⟨"enum/uninit_discriminant", fun _ => expectUb uninitDiscriminant "enum tag is uninitialized"⟩,
  ⟨"enum/invalid_discriminant", fun _ =>
    expectUb invalidDiscriminant "outside its valid range"⟩,
  ⟨"enum/invalid_load", fun _ => expectUb invalidLoad "violates the language invariant"⟩,
  ⟨"enum/misaligned_discriminant", fun _ =>
    expectUb misalignedDiscriminant "getting the discriminant of a place based on a misaligned"⟩,
  ⟨"enum/niche_works (D2)", fun _ => expectReturn nicheWorks⟩,
  ⟨"enum/niche_invalid_byte (D3)", fun _ => expectUb nicheInvalidByte "outside its valid range"⟩,
  ⟨"enum/niche_untagged_slot (D28)", fun _ =>
    expectUb nicheUntaggedSlot "niche value of the untagged variant"⟩,
  ⟨"enum/set_untagged_mismatch (D28)", fun _ =>
    expectUb setUntaggedMismatch "invalid niched enum variant written"⟩,
  ⟨"enum/transmute_into_niche (D33)", fun _ =>
    expectUb transmuteIntoNiche "transmuted value is not valid at new type"⟩,
  ⟨"enum/negative_discriminants", fun _ => expectReturn negativeDiscriminants⟩,
  ⟨"enum/larger_tag", fun _ => expectReturn largerTag⟩,
  ⟨"enum/single_variant", fun _ => expectReturn singleVariant⟩,
  ⟨"enum/write_uninhabited", fun _ => expectUb writeUninhabited "uninhabited variant"⟩,
  ⟨"enum/load_never", fun _ => expectUb loadNever "violates the language invariant"⟩,
  ⟨"enum/downcast_out_of_range", fun _ => expectIllFormed downcastOutOfRange "Downcast"⟩,
  ⟨"enum/variant_size_ill_formed", fun _ => expectIllFormed variantSizeIllFormed "ill-formed type"⟩
]

end RyoTest.Enum
