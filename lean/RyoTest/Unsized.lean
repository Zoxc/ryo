/-
Ports of MiniRust `tooling/minitest/src/tests/{unsized_struct, compute_size, compute_align,
trait_object}.rs`, adapted to D29 (vtables are constant allocations `[drop_in_place, size,
align, entries...]`, virtual calls load entry `idx`, `size_of_val`/`align_of_val` read the
vtable) and D30 (`PointerCoercion::Unsize`, also through structs, and trait upcasting).
-/
import RyoTest.Harness

namespace RyoTest.Unsized

open Ryo.Spec Ryo.Spec.Build

/-- A vtable allocation (D29). -/
def vtable (drop : Option InstanceId) (size align : Nat) (entries : List GlobalRef)
    (traitName := "Speak") : ProgB GlobalId :=
  let words := 3 + entries.length
  let bytes := (List.replicate (8 * words) (some (0 : UInt8)))
  let bytes := (writeAtOpt bytes 8 (leEncode 8 size))
  let bytes := (writeAtOpt bytes 16 (leEncode 8 align))
  let relocs := (match drop with | some d => [⟨0, .fn d, 0⟩] | none => []) ++
    entries.zipIdx.map fun (r, i) => ⟨8 * (3 + i), r, 0⟩
  addGlobal { bytes, relocs, align := Align.ofBytes 8, kind := .vtable (some traitName) }
where
  writeAtOpt (bs : List (Option UInt8)) (off : Nat) (src : List UInt8) : List (Option UInt8) :=
    bs.take off ++ src.map some ++ bs.drop (off + src.length)

def dynTy (t := "Speak") : Ty := .traitObject t

/-- `trait Speak { fn speak(&self) -> i32; }` for `u32` (returns the value) and `u8` (value +
100); `main` calls through `*const dyn Speak`. -/
def dynamicDispatch : Program := program do
  let speakU32 ← addFn "<u32 as Speak>::speak" <| body i32 [refTo u32] do
    assignL 0 (.cast .intToInt (copy ((place 1).deref u32)) i32)
    ret
  let speakU8 ← addFn "<u8 as Speak>::speak" <| body i32 [refTo u8] do
    let v ← tmp i32 (.cast .intToInt (copy ((place 1).deref u8)) i32)
    assignL 0 (.binaryOp .add v (ci32 100))
    ret
  let vtU32 ← vtable none 4 4 [.fn speakU32]
  let vtU8 ← vtable none 1 1 [.fn speakU8]
  let sizeOfVal ← addIntrinsic "size_of_val"
  let alignOfVal ← addIntrinsic "align_of_val"
  let vtSize ← addIntrinsic "vtable_size"
  addFn "main" <| body i32 [] do
    let x ← newLocal u32
    let y ← newLocal u8
    storageLive x; storageLive y
    assignL x (.use (cint u32 7))
    assignL y (.use (cu8 5))
    let px ← tmp (refTo u32) (.ref false (place x))
    let dx ← tmp (refTo (dynTy)) (.cast (.pointerCoercion (.unsize (.vtable vtU32))) px (refTo dynTy))
    let py ← tmp (rawTo u8) (.rawPtr false (place y))
    let dy ← tmp (rawTo dynTy) (.cast (.pointerCoercion (.unsize (.vtable vtU8))) py (rawTo dynTy))
    let a ← newLocal i32
    let b ← newLocal i32
    storageLive a; storageLive b
    call (.virtual 3) [dx] (place a)
    call (.virtual 3) [dy] (place b)
    assumeEq (copyL a) (ci32 7)
    assumeEq (copyL b) (ci32 105)
    assumeEq (← callTmp sizeOfVal usize [dx]) (cusize 4)
    assumeEq (← callTmp alignOfVal usize [dy]) (cusize 1)
    let vt ← tmp (dynTy.metaKind.ty) (.unaryOp .ptrMetadata dx)
    assumeEq (← callTmp vtSize usize [vt]) (cusize 4)
    -- `*dx` read through the wide reference
    let d ← newLocal (refTo dynTy)
    storageLive d
    assignL d (.use dx)
    let _ ← tmp (rawTo dynTy) (.rawPtr false ((place d).deref dynTy))
    assignL 0 (.binaryOp .add (copyL a) (copyL b))
    ret

/-- A wide pointer whose vtable pointer does not point to a vtable. -/
def badVtable : Program := mainOnly do
  let x ← newLocal u32
  storageLive x
  let p ← tmp (rawTo u32) (.rawPtr false (place x))
  let fake ← tmp (rawTo u8) (.rawPtr false (place x))
  let _ ← tmp (rawTo dynTy) (.aggregate .rawPtr [p, fake])
  ret

/-- `struct S { a: u8, tail: [u16] }`: head end 2, size `alignTo(2 + 2n, 2)`. -/
def sliceTailStruct : Ty := .tuple [(0, u8)] ⟨2, Align.ofBytes 2, none⟩ (some (slice u16))

def unsizedTail : Program := program do
  let sizeOfVal ← addIntrinsic "size_of_val"
  let alignOfVal ← addIntrinsic "align_of_val"
  addFn "main" <| body unit [] do
    let buf ← newLocal (array u16 4)
    storageLive buf
    assignL buf (.aggregate .array [cint u16 0x0101, cint u16 2, cint u16 3, cint u16 4])
    let p ← tmp (rawTo u16) (.rawPtr false (place buf))
    let s ← newLocal (rawTo sliceTailStruct)
    storageLive s
    assignL s (.aggregate .rawPtr [p, cusize 3])
    assumeEq (← callTmp sizeOfVal usize [copyL s]) (cusize 8)
    assumeEq (← callTmp alignOfVal usize [copyL s]) (cusize 2)
    -- field `a` and tail element 2
    assumeEq (copy (((place s).deref sliceTailStruct).field 0 u8)) (cu8 1)
    let i ← newLocal usize
    storageLive i
    assignL i (.use (cusize 2))
    assumeEq (copy ((((place s).deref sliceTailStruct).field 1 (slice u16)).index i)) (cint u16 4)
    -- the tail keeps the metadata
    let t ← tmp (rawTo (slice u16)) (.rawPtr false (((place s).deref sliceTailStruct).field 1 (slice u16)))
    assumeEq (← tmp usize (.unaryOp .ptrMetadata t)) (cusize 3)
    ret

/-- `struct D { a: u8, tail: dyn Speak }`: the tail's offset is rounded up to the vtable's
alignment (D29, cg_ssa `project_field`). -/
def dynTailStruct : Ty := .tuple [(0, u8)] ⟨1, .one, none⟩ (some dynTy)

def dynTail (packed : Bool) : Program := program do
  let vt ← vtable none 4 4 []
  let sizeOfVal ← addIntrinsic "size_of_val"
  let structTy : Ty := .tuple [(0, u8)] ⟨1, .one, if packed then some .one else none⟩ (some dynTy)
  addFn "main" <| body unit [] do
    let buf ← newLocal (array u32 2)
    storageLive buf
    let p ← tmp (rawTo u32) (.rawPtr false (place buf))
    let vp ← tmp (rawTo u8) (.use (.const (.ptr (.alloc vt) 0) (rawTo u8)))
    let s ← newLocal (rawTo structTy)
    storageLive s
    assignL s (.aggregate .rawPtr [p, vp])
    assumeEq (← callTmp sizeOfVal usize [copyL s]) (cusize (if packed then 5 else 8))
    let base ← tmp usize (.cast .pointerExposeProvenance (copyL s) usize)
    let t ← tmp (rawTo dynTy) (.rawPtr false (((place s).deref structTy).field 1 dynTy))
    let ta ← tmp usize (.cast .pointerExposeProvenance t usize)
    assumeEq (← tmp usize (.binaryOp .sub ta base)) (cusize (if packed then 1 else 4))
    ret

/-- D30: unsizing through a struct (`MyBox<[u32; 3]>` → `MyBox<[u32]>`). -/
def unsizeStruct : Program := mainOnly do
  let boxArr := tuple [(0, rawTo (array u32 3))] 8 8
  let boxSl := tuple [(0, rawTo (slice u32))] 16 8
  let arr ← newLocal (array u32 3)
  storageLive arr
  let p ← tmp (rawTo (array u32 3)) (.rawPtr false (place arr))
  let b ← tmp boxArr (.aggregate .tuple [p])
  let s ← newLocal boxSl
  storageLive s
  assignL s (.cast (.pointerCoercion (.unsize (.length 3))) b boxSl)
  assumeEq (← tmp usize (.unaryOp .ptrMetadata (copy ((place s).field 0 (rawTo (slice u32))))))
    (cusize 3)
  ret

/-- D30/D29: trait upcasting reads the super-trait vtable from the sub-trait vtable. -/
def upcast : Program := program do
  let get ← addFn "<u32 as Super>::get" <| body u32 [refTo u32] do
    assignL 0 (.use (copy ((place 1).deref u32)))
    ret
  let superVt ← vtable none 4 4 [.fn get] (traitName := "Super")
  let subVt ← vtable none 4 4 [.alloc superVt] (traitName := "Sub")
  addFn "main" <| body u32 [] do
    let x ← newLocal u32
    storageLive x
    assignL x (.use (cint u32 9))
    let px ← tmp (refTo u32) (.ref false (place x))
    let dsub ← tmp (refTo (dynTy "Sub")) (.cast (.pointerCoercion (.unsize (.vtable subVt))) px
      (refTo (dynTy "Sub")))
    let dsup ← tmp (refTo (dynTy "Super")) (.cast (.pointerCoercion (.unsize (.upcast (some 3))))
      dsub (refTo (dynTy "Super")))
    call (.virtual 3) [dsup] (place 0)
    ret

/-- MiniRust `compute_size.rs`/`compute_align.rs`: `size_of_val`/`align_of_val` on sized
pointees and slices. -/
def computeSizeAlign : Program := program do
  let sizeOfVal ← addIntrinsic "size_of_val"
  let alignOfVal ← addIntrinsic "align_of_val"
  addFn "main" <| body unit [] do
    let chk (t : Ty) (size align : Nat) : FnB Unit := do
      let x ← newLocal t
      storageLive x
      let p ← tmp (rawTo t) (.rawPtr false (place x))
      assumeEq (← callTmp sizeOfVal usize [p]) (cusize size)
      assumeEq (← callTmp alignOfVal usize [p]) (cusize align)
    chk u8 1 1
    chk i32 4 4
    chk u64 8 8
    chk i128 16 16
    chk .bool 1 1
    chk (rawTo u8) 8 8
    chk (rawTo (slice u8)) 16 8
    chk unit 0 1
    chk (cTuple [u8, u32, u16]) 12 4
    chk (array u16 5) 10 2
    let arr ← newLocal (array u16 5)
    storageLive arr
    let p ← tmp (rawTo u16) (.rawPtr false (place arr))
    let s ← tmp (rawTo (slice u16)) (.aggregate .rawPtr [p, cusize 5])
    assumeEq (← callTmp sizeOfVal usize [s]) (cusize 10)
    assumeEq (← callTmp alignOfVal usize [s]) (cusize 2)
    ret

def tests : List TestCase := [
  ⟨"compute_size_align", fun _ => expectReturn computeSizeAlign⟩,
  ⟨"trait_object/dynamic_dispatch (D29)", fun _ => expectReturnValue dynamicDispatch (.int 112)⟩,
  ⟨"trait_object/bad_vtable (D29)", fun _ => expectUb badVtable "invalid vtable in metadata"⟩,
  ⟨"unsized_struct/slice_tail", fun _ => expectReturn unsizedTail⟩,
  ⟨"unsized_struct/dyn_tail (D29)", fun _ => expectReturn (dynTail false)⟩,
  ⟨"unsized_struct/packed_dyn_tail", fun _ => expectReturn (dynTail true)⟩,
  ⟨"unsize/struct (D30)", fun _ => expectReturn unsizeStruct⟩,
  ⟨"unsize/upcast (D30)", fun _ => expectReturnValue upcast (.int 9)⟩
]

end RyoTest.Unsized
