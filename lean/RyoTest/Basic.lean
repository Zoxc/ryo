/-
Ports of MiniRust `tooling/minitest/src/tests/{bool, switch, locals, assume, unreachable, zst,
align, null, uninit_read, negative_index, place_mention, dereferenceable, packed}.rs`.

Adaptations: MIR has no nested expressions (temporaries instead), `exit()` becomes `return`,
and pointers are dereferenced through locals.
-/
import RyoTest.Harness

namespace RyoTest.Basic

open Ryo.Spec Ryo.Spec.Build

/-! ### bool.rs -/

def boolToInt (b : Bool) (expect : Nat) : Program := mainOnly do
  let i ← tmp u8 (.cast .intToInt (cbool b) u8)
  let ok ← newBlock
  let bad ← newBlock
  term (.switchInt i [(expect, ok)] bad)
  setBlock ok; ret
  setBlock bad; term .unreachable

def boolOps : Program := mainOnly do
  assumeEq (← tmp .bool (.unaryOp .not (cbool false))) (cbool true)
  assumeEq (← tmp .bool (.unaryOp .not (cbool true))) (cbool false)
  for (a, b) in [(false, false), (false, true), (true, false), (true, true)] do
    assumeBin .bitAnd .bool (cbool a) (cbool b) (cbool (a && b))
    assumeBin .bitOr .bool (cbool a) (cbool b) (cbool (a || b))
    assumeBin .bitXor .bool (cbool a) (cbool b) (cbool (a != b))
  ret

/-! ### switch.rs -/

def ifProg (c : Bool) : Program := mainOnly do
  let t ← newBlock
  let e ← newBlock
  term (.switchInt (cbool c) [(0, e)] t)
  setBlock t
  if c then ret else term .unreachable
  setBlock e
  if c then term .unreachable else ret

def switchIntWorks : Program := mainOnly do
  let b1 ← newBlock
  let b2 ← newBlock
  let b3 ← newBlock
  term (.switchInt (cu8 1) [(0, b3), (1, b1)] b3)
  setBlock b1; term (.switchInt (cu8 12) [(0, b3), (1, b3)] b2)
  setBlock b2; ret
  setBlock b3; term .unreachable

/-- An enum with a direct `u8` tag at offset 0 (variants 0 ↦ tag 4, 1 ↦ tag 2 in MiniRust;
here the tag is the discriminant). -/
def twoVariantEnum : Ty :=
  .enum [variant 4 [] 1 1, variant 2 [] 1 1] IntType.u8
    (.multiple ⟨0, IntType.u8, ⟨2, 4⟩, .direct⟩) 1 .one

def switchEnumWorks : Program := mainOnly do
  let e ← newLocal twoVariantEnum
  storageLive e
  stmt (.setDiscriminant (place e) 0)
  let d ← tmp u8 (.discriminant (place e))
  let ok ← newBlock
  let bad ← newBlock
  term (.switchInt d [(4, ok), (2, bad)] bad)
  setBlock ok; ret
  setBlock bad; term .unreachable

def switchOnFloatIllFormed : Program := mainOnly do
  let b ← newBlock
  term (.switchInt (cf64 1.0) [(0, b)] b)
  setBlock b; ret

/-! ### locals.rs -/

def deadBeforeLive : Program := mainOnly do
  let l ← newLocal .bool
  storageDead l
  ret

def doubleLive : Program := mainOnly do
  let l ← newLocal .bool
  storageLive l
  storageLive l
  ret

/-- MiniRust's `assign_dead`: in MIR the local must have a storage statement to be dead
(D9: locals without storage statements are always live). -/
def assignDead : Program := mainOnly do
  let l ← newLocal u32
  storageDead l
  assignL l (.use (cint u32 42))
  ret

/-- D9: a local without storage statements is live for the whole call. -/
def alwaysLive : Program := mainOnly do
  let l ← newLocal u32
  assignL l (.use (cint u32 42))
  assumeEq (copyL l) (cint u32 42)
  ret

/-- D9: `StorageLive` of a live local re-allocates: the old value is gone. -/
def reLiveForgets : Program := mainOnly do
  let l ← newLocal u32
  storageLive l
  assignL l (.use (cint u32 42))
  storageLive l
  let _ ← tmp u32 (.use (copyL l))
  ret

/-! ### assume.rs, unreachable.rs -/

def assumeProg (b : Bool) : Program := mainOnly do
  assume (cbool b)
  ret

def reachUnreachable : Program := mainOnly (term .unreachable)

/-! ### zst.rs -/

def zstArray : Program := mainOnly do
  let a ← newLocal (array unit 2)
  storageLive a
  assignL a (.use (copyL a))
  ret

def zstTuple : Program := mainOnly do
  let t ← newLocal (tuple [(0, unit), (0, unit)] 0 1)
  let u ← newLocal unit
  storageLive t
  storageLive u
  assignL u (.use (copy ((place t).field 0 unit)))
  ret

def zstTuple2 : Program := mainOnly do
  let t ← newLocal (tuple [(0, i8), (1, unit)] 1 1)
  let u ← newLocal unit
  storageLive t
  storageLive u
  assignL u (.use (copy ((place t).field 1 unit)))
  ret

def zstEnum : Program := mainOnly do
  let e ← newLocal (.enum [variant 0 [] 0 1] IntType.u8 (.single 0) 0 .one)
  storageLive e
  assignL e (.use (copyL e))
  ret

/-! ### align.rs -/

def manualAlign : Program := mainOnly do
  let buf ← newLocal (array u8 64)
  storageLive buf
  let p ← tmp (rawTo u8 true) (rawOf buf)
  let addr ← tmp usize (.cast .pointerExposeProvenance p usize)
  -- pad = 8 - addr % 8 (in 1..=8)
  let r ← tmp usize (.binaryOp .rem addr (cusize 8))
  let pad ← tmp usize (.binaryOp .sub (cusize 8) r)
  let q ← tmp (rawTo u8 true) (.binaryOp .offset p pad)
  let q64 ← newLocal (rawTo u64 true)
  storageLive q64
  assignL q64 (.cast .ptrToPtr q (rawTo u64 true))
  assign ((place q64).deref u64) (.use (cint u64 42))
  ret

def unionUsizePtr (pointee : Ty) : Ty :=
  .union [(0, usize), (0, rawTo pointee)] [(0, 8)] 8 (Align.ofBytes 8)

def loadPlaceMisaligned (store : Bool) : Program := mainOnly do
  let uTy := unionUsizePtr (array i32 0)
  let u ← newLocal uTy
  let x ← newLocal (array i32 0)
  storageLive u
  storageLive x
  assign ((place u).field 0 usize) (.use (cusize 1))
  let deref := ((place u).field 1 (rawTo (array i32 0))).deref (array i32 0)
  if store then assign deref (.use (copyL x)) else assignL x (.use (copy deref))
  ret

/-- `&*(ptr+1 as *const u16)`: a misaligned reference. -/
def misalignedRef (refDest : Bool) : Program := mainOnly do
  let x ← newLocal i32
  storageLive x
  assignL x (.use (ci32 0))
  let p ← tmp (rawTo u8) (.rawPtr false (place x))
  let q ← tmp (rawTo u8) (.binaryOp .offset p (cusize 1))
  let r ← newLocal (rawTo u16)
  storageLive r
  assignL r (.cast .ptrToPtr q (rawTo u16))
  let destTy := if refDest then refTo u16 else rawTo u32
  let d ← newLocal destTy
  storageLive d
  let pl := (place r).deref u8
  assignL d (if refDest then .ref false pl else .rawPtr false pl)
  ret

/-- `transmute::<*const u16, &u16>(misaligned)`. -/
def transmuteMisalignedRef : Program := mainOnly do
  let x ← newLocal i32
  storageLive x
  let p ← tmp (rawTo u8) (.rawPtr false (place x))
  let q ← tmp (rawTo u8) (.binaryOp .offset p (cusize 1))
  let _ ← tmp (refTo u16) (.cast .transmute q (refTo u16))
  ret

def derefOveraligned : Program := mainOnly do
  let x ← newLocal i32
  storageLive x
  assignL x (.use (ci32 0))
  let p ← newLocal (rawTo u8)
  storageLive p
  assignL p (.rawPtr false (place x))
  let _ ← tmp u32 (.use (copy ((place p).deref u32)))
  ret

/-! ### null.rs, uninit_read.rs, negative_index.rs -/

def ptrNull (zst : Bool) : Program := mainOnly do
  let t := if zst then unit else i32
  let u ← newLocal (unionUsizePtr t)
  let x ← newLocal t
  storageLive u
  storageLive x
  assign ((place u).field 0 usize) (.use (cusize 0))
  assignL x (.use (copy (((place u).field 1 (rawTo t)).deref t)))
  ret

def uninitRead : Program := mainOnly do
  let a ← newLocal .bool
  let b ← newLocal .bool
  storageLive a
  storageLive b
  assignL a (.use (copyL b))
  ret

def negativeIndex : Program := mainOnly do
  let arr ← newLocal (array unit 2)
  let x ← newLocal unit
  let i ← newLocal usize
  storageLive arr
  storageLive x
  storageLive i
  assignL i (.use (cusize (2 ^ 64 - 1)))  -- `-1isize as usize`
  assignL x (.use (copy ((place arr).index i)))
  ret

/-! ### place_mention.rs -/

def placeMentionDangling (nested : Bool) : Program := mainOnly do
  if nested then
    let v ← newLocal (rawTo (rawTo u32))
    storageLive v
    assignL v (.cast .transmute (cusize 16) (rawTo (rawTo u32)))
    stmt (.placeMention (((place v).deref (rawTo u32)).deref u32))
  else
    let v ← newLocal (rawTo u32)
    storageLive v
    assignL v (.cast .transmute (cusize 16) (rawTo u32))
    stmt (.placeMention ((place v).deref u32))
  ret

/-! ### dereferenceable.rs -/

def derefDanglingRef : Program := mainOnly do
  let _ ← tmp (refTo i32) (.cast .transmute (cusize 16) (refTo i32))
  ret

def derefDanglingPtr (mkRef : Bool) : Program := mainOnly do
  let p ← newLocal (rawTo i32)
  storageLive p
  assignL p (.cast .transmute (cusize 16) (rawTo i32))
  if mkRef then
    let _ ← tmp (refTo i32) (.ref false ((place p).deref unit))
  else
    let _ ← tmp (rawTo i32) (.rawPtr false ((place p).deref i32))
  ret

/-! ### packed.rs (D36) -/

def packedTy : Ty := .tuple [(0, i32)] ⟨4, .one, none⟩ none

def packedWorks : Program := mainOnly do
  let t ← newLocal packedTy
  storageLive t
  assign ((place t).field 0 i32) (.use (ci32 0))
  let _ ← tmp i32 (.use (copy ((place t).field 0 i32)))
  ret

def packedRef : Program := mainOnly do
  let t ← newLocal packedTy
  storageLive t
  assign ((place t).field 0 i32) (.use (ci32 0))
  let _ ← tmp (refTo i32) (.ref false ((place t).field 0 i32))
  ret

/-- An oracle that puts align-1 allocations at odd addresses (MiniRust's
`assert_ub_eventually` tries random addresses instead). -/
def oddOracle : Oracle where
  answer := fun n c s =>
    match c with
    | .allocAddr size align =>
      let a : Nat := concreteOracle.answer n (.allocAddr size align) s
      if align.bytes == 1 then a + 1 else a
    | c' => concreteOracle.answer n c' s

def packedIsNotAligned : Except String Unit :=
  let r := runWith oddOracle packedRef
  match r.result with
  | .error (.ub m) => check ((m.splitOn "unaligned safe pointer").length > 1) m
  | _ => .error s!"expected UB, got {describe r}"

def tests : List TestCase := [
  ⟨"bool/false_to_int", fun _ => expectReturn (boolToInt false 0)⟩,
  ⟨"bool/true_to_int", fun _ => expectReturn (boolToInt true 1)⟩,
  ⟨"bool/ops", fun _ => expectReturn boolOps⟩,
  ⟨"switch/if_works", fun _ => expectReturn (ifProg true)⟩,
  ⟨"switch/else_works", fun _ => expectReturn (ifProg false)⟩,
  ⟨"switch/switch_int_works", fun _ => expectReturn switchIntWorks⟩,
  ⟨"switch/switch_enum_works", fun _ => expectReturn switchEnumWorks⟩,
  ⟨"switch/float_switch_ill_formed", fun _ => expectIllFormed switchOnFloatIllFormed "SwitchInt"⟩,
  ⟨"locals/dead_before_live", fun _ => expectReturn deadBeforeLive⟩,
  ⟨"locals/double_live", fun _ => expectReturn doubleLive⟩,
  ⟨"locals/assign_dead", fun _ => expectUb assignDead "access to a dead local"⟩,
  ⟨"locals/always_live (D9)", fun _ => expectReturn alwaysLive⟩,
  ⟨"locals/relive_forgets (D9)", fun _ => expectUb reLiveForgets "violates the language invariant"⟩,
  ⟨"assume/true", fun _ => expectReturn (assumeProg true)⟩,
  ⟨"assume/false", fun _ =>
    expectUb (assumeProg false) "`Assume` intrinsic called on condition that is violated"⟩,
  ⟨"unreachable/reach", fun _ => expectUb reachUnreachable "reached unreachable code"⟩,
  ⟨"zst/array", fun _ => expectReturn zstArray⟩,
  ⟨"zst/tuple", fun _ => expectReturn zstTuple⟩,
  ⟨"zst/tuple2", fun _ => expectReturn zstTuple2⟩,
  ⟨"zst/enum", fun _ => expectReturn zstEnum⟩,
  ⟨"align/manual_align", fun _ => expectReturn manualAlign⟩,
  ⟨"align/load_place_misaligned", fun _ =>
    expectUb (loadPlaceMisaligned false) "loading from a place based on a misaligned pointer"⟩,
  ⟨"align/store_place_misaligned", fun _ =>
    expectUb (loadPlaceMisaligned true) "storing to a place based on a misaligned pointer"⟩,
  ⟨"align/transmute_misaligned_ref", fun _ =>
    expectUb transmuteMisalignedRef "Value::Ptr: unaligned safe pointer"⟩,
  ⟨"align/addr_of_misaligned_ref", fun _ =>
    expectUb (misalignedRef true) "Value::Ptr: unaligned safe pointer"⟩,
  ⟨"align/addr_of_misaligned_ptr", fun _ => expectReturn (misalignedRef false)⟩,
  ⟨"align/deref_overaligned", fun _ => expectReturn derefOveraligned⟩,
  ⟨"null/ptr_null", fun _ => expectUb (ptrNull false) "dereferencing pointer without provenance"⟩,
  ⟨"null/ptr_null_zst", fun _ => expectReturn (ptrNull true)⟩,
  ⟨"uninit_read", fun _ => expectUb uninitRead "violates the language invariant"⟩,
  ⟨"negative_index", fun _ => expectUb negativeIndex "access to out-of-bounds index"⟩,
  ⟨"place_mention/dangling_pointer", fun _ => expectReturn (placeMentionDangling false)⟩,
  ⟨"place_mention/not_ignored", fun _ =>
    expectUb (placeMentionDangling true) "dereferencing pointer without provenance"⟩,
  ⟨"dereferenceable/deref_dangling_ref", fun _ =>
    expectUb derefDanglingRef "Value::Ptr: non-dereferenceable safe pointer"⟩,
  ⟨"dereferenceable/deref_dangling_ptr", fun _ => expectReturn (derefDanglingPtr false)⟩,
  ⟨"dereferenceable/ref_dangling_ptr", fun _ =>
    expectUb (derefDanglingPtr true) "Value::Ptr: non-dereferenceable safe pointer"⟩,
  ⟨"packed/works", fun _ => expectReturn packedWorks⟩,
  ⟨"packed/is_not_aligned (D36)", fun _ => packedIsNotAligned⟩
]

end RyoTest.Basic
