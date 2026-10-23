/-
Ports of MiniRust `tooling/minitest/src/tests/{ptr, ptr_offset, ptr_offset_from, expose,
no_preserve_padding, no_preserve_prov, raw_eq, wide_ptr, slice}.rs`.

Adaptations: MiniRust's byte-offset `PtrOffset` becomes MIR `Offset` (scaled by the pointee
size, D10) on `*const u8`, or `arith_offset` for the wrapping variant; `PtrOffsetFrom` is the
`ptr_offset_from(_unsigned)` intrinsic (an element count, D20); wide pointers are built with
`AggregateKind::RawPtr` and taken apart with `PtrMetadata`/`PtrToPtr`.
-/
import RyoTest.Harness

namespace RyoTest.Ptr

open Ryo.Spec Ryo.Spec.Build

/-! ### ptr.rs -/

def pointerPartialOverwrite : Program := mainOnly do
  let x ← newLocal i32
  let r ← newLocal (refTo i32)
  let y ← newLocal i32
  storageLive x; storageLive r; storageLive y
  assignL x (.use (ci32 42))
  assignL r (.ref false (place x))
  -- corrupt one byte of the reference through a `*mut u8`, stripping its provenance
  let p ← newLocal (rawTo u8 true)
  storageLive p
  assignL p (.rawPtr true (place r))
  assign ((place p).deref u8) (.use (cu8 12))
  assignL y (.use (copy ((place r).deref i32)))
  ret

def pointerRel : Program := mainOnly do
  let a ← newLocal i32
  let b ← newLocal i32
  storageLive a; storageLive b
  let pa ← tmp (rawTo i32) (.rawPtr false (place a))
  let pb ← tmp (rawTo i32) (.rawPtr false (place b))
  assumeRv (.binaryOp .eq pa pa)
  assumeRv (.binaryOp .ne pa pb)
  let lt ← tmp .bool (.binaryOp .lt pa pb)
  let gt ← tmp .bool (.binaryOp .gt pa pb)
  assumeRv (.binaryOp .bitOr lt gt)
  assumeRv (.binaryOp .ne (← tmp i8 (.binaryOp .cmp pa pb)) (cint i8 0))
  ret

/-! ### ptr_offset.rs -/

def ptrOffset (count : Operand) (wrapping : Bool) : Program := program do
  let arith ← addIntrinsic "arith_offset"
  addFn "main" <| body unit [] do
    let x ← newLocal i32
    storageLive x
    assignL x (.use (ci32 42))
    let p ← tmp (rawTo i32) (.rawPtr false (place x))
    if wrapping then
      let _ ← callTmp arith (rawTo i32) [p, count]
    else
      let _ ← tmp (rawTo i32) (.binaryOp .offset p count)
    ret

/-- Offset through a pointer whose provenance was stripped by a union round trip. -/
def invalidOffset : Program := mainOnly do
  let uTy : Ty := .union [(0, rawTo i32), (0, usize)] [(0, 8)] 8 (Align.ofBytes 8)
  let arr ← newLocal (array i32 2)
  let u ← newLocal uTy
  storageLive arr; storageLive u
  assignL arr (.aggregate .array [ci32 42, ci32 24])
  let i ← newLocal usize
  storageLive i
  assignL i (.use (cusize 0))
  assign ((place u).field 0 (rawTo i32)) (.rawPtr false ((place arr).index i))
  assign ((place u).field 1 usize) (.use (copy ((place u).field 1 usize)))
  let _ ← tmp (rawTo i32) (.binaryOp .offset (copy ((place u).field 0 (rawTo i32))) (cusize 1))
  ret

/-! ### ptr_offset_from.rs -/

def offsetFrom (name : String) (sameAlloc : Bool) (backwards : Bool) (expect : Int) : Program :=
  program do
    let f ← addIntrinsic name
    addFn "main" <| body unit [] do
      let arr ← newLocal (array u32 4)
      let other ← newLocal u32
      storageLive arr; storageLive other
      let i0 ← newLocal usize
      let i1 ← newLocal usize
      storageLive i0; storageLive i1
      assignL i0 (.use (cusize 0)); assignL i1 (.use (cusize 1))
      let p1 ← tmp (rawTo u32) (.rawPtr false ((place arr).index i0))
      let p2 ← if sameAlloc then tmp (rawTo u32) (.rawPtr false ((place arr).index i1))
               else tmp (rawTo u32) (.rawPtr false (place other))
      let (a, b) := if backwards then (p1, p2) else (p2, p1)
      let r ← callTmp f (if name == "ptr_offset_from" then isize else usize) [a, b]
      assumeEq r (if name == "ptr_offset_from" then cint isize expect else cusize expect)
      ret

/-! ### expose.rs (D11) -/

def exposeRoundTrip (doExpose : Bool) : Program := mainOnly do
  let x ← newLocal i32
  storageLive x
  assignL x (.use (ci32 42))
  let p ← tmp (rawTo i32) (.rawPtr false (place x))
  let addr ← if doExpose then tmp usize (.cast .pointerExposeProvenance p usize)
             else tmp usize (.cast .transmute p usize)
  let q ← newLocal (rawTo i32)
  storageLive q
  assignL q (.cast .pointerWithExposedProvenance addr (rawTo i32))
  assumeEq (copy ((place q).deref i32)) (ci32 42)
  ret

/-! ### no_preserve_padding.rs, no_preserve_prov.rs -/

def noPreservePadding : Program := mainOnly do
  let pairTy := tuple [(0, u8), (2, u16)] 4 2
  let uTy : Ty := .union [(0, pairTy), (0, u32)] [(0, 4)] 4 (Align.ofBytes 4)
  let u ← newLocal uTy
  let pair ← newLocal pairTy
  storageLive u; storageLive pair
  assign ((place u).field 1 u32) (.use (cint u32 0))
  assignL pair (.use (copy ((place u).field 0 pairTy)))
  let p ← tmp (rawTo u8) (.rawPtr false (place pair))
  let q ← newLocal (rawTo u8)
  storageLive q
  assignL q (.binaryOp .offset p (cusize 1))
  let _ ← tmp u8 (.use (copy ((place q).deref u8)))
  ret

def noPreserveProv : Program := mainOnly do
  let uTy : Ty := .union [(0, array (refTo i32) 1), (0, array usize 1), (0, refTo i32)]
    [(0, 8)] 8 (Align.ofBytes 8)
  let x ← newLocal i32
  let u ← newLocal uTy
  let y ← newLocal i32
  storageLive x; storageLive u; storageLive y
  assignL x (.use (ci32 42))
  let i ← newLocal usize
  storageLive i
  assignL i (.use (cusize 0))
  assign (((place u).field 0 (array (refTo i32) 1)).index i) (.ref false (place x))
  assign ((place u).field 1 (array usize 1)) (.use (copy ((place u).field 1 (array usize 1))))
  assignL y (.use (copy (((place u).field 2 (refTo i32)).deref i32)))
  ret

/-! ### raw_eq.rs -/

def rawEq (init2 : Bool) (v2 : Int) (expect : Bool) : Program := program do
  let f ← addIntrinsic "raw_eq"
  addFn "main" <| body unit [] do
    let a ← newLocal (array u8 2)
    let b ← newLocal (array u8 2)
    storageLive a; storageLive b
    assignL a (.aggregate .array [cu8 1, cu8 2])
    if init2 then assignL b (.aggregate .array [cu8 1, cu8 v2])
    let ra ← tmp (refTo (array u8 2)) (.ref false (place a))
    let rb ← tmp (rawTo (array u8 2)) (.rawPtr false (place b))
    let r ← callTmp f .bool [ra, rb]
    assumeEq r (cbool expect)
    ret

/-! ### wide_ptr.rs, slice.rs -/

/-- A `*const [u32]` to the first `len` elements of a local array, plus checks on it. -/
def sliceOf (arr : Local) (elem : Ty) (len : Nat) : FnB Operand := do
  let p ← tmp (rawTo elem) (.rawPtr false ((place arr).proj1 (.constantIndex 0 1 false)))
  tmp (rawTo (slice elem)) (.aggregate .rawPtr [p, cusize len])

def constructSlice : Program := mainOnly do
  let arr ← newLocal (array u32 3)
  storageLive arr
  assignL arr (.aggregate .array [cint u32 10, cint u32 20, cint u32 30])
  let s ← sliceOf arr u32 3
  assumeEq (← tmp usize (.unaryOp .ptrMetadata s)) (cusize 3)
  -- the thin part is the first element
  let thin ← tmp (rawTo u32) (.cast .ptrToPtr s (rawTo u32))
  let first ← tmp (rawTo u32) (.rawPtr false ((place arr).proj1 (.constantIndex 0 1 false)))
  assumeRv (.binaryOp .eq thin first)
  -- index through a reference to the slice
  let sl ← newLocal (refTo (slice u32))
  storageLive sl
  assignL sl (.cast .transmute s (refTo (slice u32)))
  let i ← newLocal usize
  storageLive i
  assignL i (.use (cusize 2))
  assumeEq (copy (((place sl).deref (slice u32)).index i)) (cint u32 30)
  assumeEq (copy (((place sl).deref (slice u32)).proj1 (.constantIndex 2 3 true)))
    (cint u32 20)
  -- subslice [1..] of the slice has length 2
  let sub ← tmp (rawTo (slice u32))
    (.rawPtr false (((place sl).deref (slice u32)).proj1 (.subslice 1 0 true)))
  assumeEq (← tmp usize (.unaryOp .ptrMetadata sub)) (cusize 2)
  ret

def sliceIndexOob : Program := mainOnly do
  let arr ← newLocal (array u32 3)
  storageLive arr
  assignL arr (.aggregate .array [cint u32 10, cint u32 20, cint u32 30])
  let s ← sliceOf arr u32 2
  let sl ← newLocal (refTo (slice u32))
  storageLive sl
  assignL sl (.cast .transmute s (refTo (slice u32)))
  let i ← newLocal usize
  storageLive i
  assignL i (.use (cusize 2))
  let _ ← tmp u32 (.use (copy (((place sl).deref (slice u32)).index i)))
  ret

def largeRawSlice (asRef : Bool) : Program := mainOnly do
  let arr ← newLocal (array u32 1)
  storageLive arr
  let p ← tmp (rawTo u32) (.rawPtr false ((place arr).proj1 (.constantIndex 0 1 false)))
  let s ← tmp (rawTo (slice u32)) (.aggregate .rawPtr [p, cusize (2 ^ 62)])
  if asRef then
    let _ ← tmp (refTo (slice u32)) (.cast .transmute s (refTo (slice u32)))
  ret

def compareSlicePtrs : Program := mainOnly do
  let arr ← newLocal (array u32 4)
  storageLive arr
  let a ← sliceOf arr u32 2
  let b ← sliceOf arr u32 3
  assumeRv (.binaryOp .lt a b)
  assumeRv (.binaryOp .ne a b)
  assumeRv (.binaryOp .eq a a)
  ret

/-- Passing a wide pointer where the callee expects a thin one (D14). -/
def wideThinAbi : Program := program do
  let callee ← addFn "callee" (body unit [rawTo u32] ret)
  addFn "main" <| body unit [] do
    let arr ← newLocal (array u32 4)
    storageLive arr
    let s ← sliceOf arr u32 2
    callUnit (.inst callee) [s]
    ret

def tests : List TestCase := [
  ⟨"ptr/partial_overwrite", fun _ =>
    expectUb pointerPartialOverwrite "Value::Ptr: non-dereferenceable safe pointer"⟩,
  ⟨"ptr/rel", fun _ => expectReturn pointerRel⟩,
  ⟨"ptr_offset/success", fun _ => expectReturn (ptrOffset (cusize 1) false)⟩,
  ⟨"ptr_offset/inbounds", fun _ =>
    expectUb (ptrOffset (cint isize (-1)) false) "dereferencing pointer outside the bounds"⟩,
  ⟨"ptr_offset/count_overflows_isize", fun _ =>
    expectUb (ptrOffset (cusize (2 ^ 64 - 1)) false) "overflows isize"⟩,
  ⟨"ptr_offset/no_inbounds", fun _ => expectReturn (ptrOffset (cint isize (-1)) true)⟩,
  ⟨"ptr_offset/out_of_bounds", fun _ =>
    expectUb (ptrOffset (cusize 2) false) "dereferencing pointer outside the bounds"⟩,
  ⟨"ptr_offset/invalid_offset", fun _ =>
    expectUb invalidOffset "dereferencing pointer without provenance"⟩,
  ⟨"ptr_offset_from/inbounds_success", fun _ =>
    expectReturn (offsetFrom "ptr_offset_from" true false 1)⟩,
  ⟨"ptr_offset_from/inbounds_negative", fun _ =>
    expectReturn (offsetFrom "ptr_offset_from" true true (-1))⟩,
  ⟨"ptr_offset_from/unsigned_negative", fun _ =>
    expectUb (offsetFrom "ptr_offset_from_unsigned" true true 0) "negative distance"⟩,
  ⟨"ptr_offset_from/cross_alloc", fun _ =>
    expectUb (offsetFrom "ptr_offset_from" false false 0) "different allocations"⟩,
  ⟨"expose/round_trip (D11)", fun _ => expectReturn (exposeRoundTrip true)⟩,
  ⟨"expose/not_exposed (D11)", fun _ =>
    expectUb (exposeRoundTrip false) "dereferencing pointer without provenance"⟩,
  ⟨"no_preserve_padding", fun _ => expectUb noPreservePadding "violates the language invariant"⟩,
  ⟨"no_preserve_prov", fun _ =>
    expectUb noPreserveProv "Value::Ptr: non-dereferenceable safe pointer"⟩,
  ⟨"raw_eq/true", fun _ => expectReturn (rawEq true 2 true)⟩,
  ⟨"raw_eq/false", fun _ => expectReturn (rawEq true 3 false)⟩,
  ⟨"raw_eq/uninit", fun _ => expectUb (rawEq false 0 false) "raw_eq: uninitialized bytes"⟩,
  ⟨"slice/construct_index_subslice", fun _ => expectReturn constructSlice⟩,
  ⟨"slice/index_oob", fun _ => expectUb sliceIndexOob "access to out-of-bounds index"⟩,
  ⟨"slice/large_raw", fun _ => expectReturn (largeRawSlice false)⟩,
  ⟨"slice/too_large_ref", fun _ =>
    expectUb (largeRawSlice true) "Value::Ptr: total size exceeds isize::MAX"⟩,
  ⟨"wide_ptr/compare_slice_ptr", fun _ => expectReturn compareSlicePtrs⟩,
  ⟨"wide_ptr/wide_thin_abi_incompatible", fun _ =>
    expectUb wideThinAbi "call ABI violation: argument types are not compatible"⟩
]

end RyoTest.Ptr
