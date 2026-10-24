/-
Tests for the spec fixes found by the M1b differential runs: v0-mangled internal symbols and
ABI-transparent wrappers in the allocator shims, `__rust_no_alloc_shim_is_unstable_v2`,
`Ignore` arguments and `rust`/`rust-call` in fn-pointer calls, `Drop` of `dyn Trait` places,
direct tags wider than the discriminant type, `is_val_statically_known`, and
`caller_location` with a constant caller location.
-/
import RyoTest.Harness
import RyoTest.Unsized

namespace RyoTest.M1b

open Ryo.Spec Ryo.Spec.Build

/-! ### `internalName`: v0-mangled `#[rustc_std_internal_symbol]`s -/

/-- Allocate 8 bytes through the mangled `__rust_alloc`, store 42, load it back. -/
def mangledAlloc : Program := program do
  let alloc ← addExtern "_RNvCs5fGHjzWXRav_7___rustc12___rust_alloc"
  addFn "main" <| body u64 [] do
    let p ← newLocal (rawTo u64 true)
    storageLive p
    call (.inst alloc) [cusize 8, cusize 8] (place p)
    assign ((place p).deref u64) (.use (cint u64 42))
    assignL 0 (.use (copy ((place p).deref u64)))
    ret

/-! ### `scalarOf`: `Alignment` and `NonNull<u8>` arguments -/

/-- A cut-down `AlignmentEnum`: fieldless, `repr(usize)`, discriminants 1, 2, 4, 8. -/
def alignEnum : Ty :=
  .enum [variant 1 [] 8 8, variant 2 [] 8 8, variant 4 [] 8 8, variant 8 [] 8 8] IntType.usize
    (.multiple ⟨0, IntType.usize, ⟨1, 8⟩, .direct⟩) 8 (Align.ofBytes 8)

/-- `struct Alignment(AlignmentEnum)`. -/
def alignment : Ty := tuple [(0, alignEnum)] 8 8

/-- `struct NonNull<u8>(*const u8)`. -/
def nonNullU8 : Ty := tuple [(0, rawTo u8)] 8 8

/-- `__rust_alloc(8, Alignment(8))`, store/load, `__rust_dealloc(NonNull(p), 8, Alignment(8))`. -/
def wrappedAllocArgs : Program := program do
  let alloc ← addExtern "__rust_alloc"
  let dealloc ← addExtern "__rust_dealloc"
  addFn "main" <| body u64 [] do
    let e ← newLocal alignEnum
    storageLive e
    assignL e (.aggregate (.adt 3 none) [])
    let a ← tmp alignment (.aggregate .tuple [copyL e])
    let p ← newLocal (rawTo u8 true)
    storageLive p
    call (.inst alloc) [cusize 8, a] (place p)
    let q ← tmp (rawTo u64 true) (.cast .ptrToPtr (copyL p) (rawTo u64 true))
    let ql ← newLocal (rawTo u64 true)
    storageLive ql
    assignL ql (.use q)
    assign ((place ql).deref u64) (.use (cint u64 42))
    assignL 0 (.use (copy ((place ql).deref u64)))
    let pc ← tmp (rawTo u8) (.cast .ptrToPtr (copyL p) (rawTo u8))
    let nn ← tmp nonNullU8 (.aggregate .tuple [pc])
    callUnit (.inst dealloc) [nn, cusize 8, a]
    ret

/-! ### `__rust_no_alloc_shim_is_unstable_v2` -/

def noAllocShim : Program := program do
  let f ← addExtern "__rust_no_alloc_shim_is_unstable_v2"
  addFn "main" <| body i32 [] do
    callUnit (.inst f) []
    assignL 0 (.use (ci32 7))
    ret

/-! ### `fnAbiCompatible`/`createFrame`: `Ignore` arguments, `rust` vs `rust-call` -/

def abiI32 : ArgAbi := ⟨.direct, 4, Align.ofBytes 4, "i32"⟩
def abiIgnore : ArgAbi := ⟨.ignore, 0, .one, ""⟩

/-- A closure's `FnOnce` shim: `rust-call`, a zero-sized environment (`Ignore`), then an `i32`;
returns the argument + 1. With `spread`, the `i32` arrives in a `(i32,)` spread tuple. -/
def onceShim (spread : Bool) : Body :=
  let argTy := if spread then tuple [(0, i32)] 4 4 else i32
  let argOp := if spread then copy ((place 2).field 0 i32) else copyL 2
  { body i32 [unit, argTy] (spread := spread) (do
      assignL 0 (.binaryOp .add argOp (ci32 1))
      ret) with
    abi := some ⟨.rustCall, [abiIgnore, abiI32], abiI32⟩ }

/-- `(f as fn(i32) -> i32)(41)` where `f` is the shim; the caller's ABI is `callerAbi`. -/
def fnPtrToShim (callerAbi : FnAbiSummary) (spread := false) : Program := program do
  let shim ← addFn "<{closure} as FnOnce<(i32,)>>::call_once" (onceShim spread)
  addFn "main" <| body i32 [] do
    let f ← tmp fnPtrTy (.use (cfnPtr shim))
    let next ← newBlock
    term (.call (.fnPtr f) [ci32 41] (place 0) (some next) .continue none (some callerAbi))
    setBlock next
    ret

def rustI32 : FnAbiSummary := ⟨.rust, [abiI32], abiI32⟩

def ignoreArgs : Except String Unit := do
  expectReturnValue (fnPtrToShim rustI32) (.int 42)
  expectReturnValue (fnPtrToShim rustI32 (spread := true)) (.int 42)
  -- a different calling convention, and a different argument class, are still UB
  expectUb (fnPtrToShim ⟨.c, [abiI32], abiI32⟩) "function ABIs are not compatible"
  expectUb (fnPtrToShim ⟨.rust, [⟨.direct, 4, Align.ofBytes 4, "f32"⟩], abiI32⟩)
    "function ABIs are not compatible"

/-! ### `Drop` of a `dyn Trait` place calls the vtable's drop entry -/

/-- `drop(*d)` with `d : *mut dyn Speak` pointing at `x = 5u32`; the vtable's drop entry
(`withDrop`) prints `*self`. -/
def dynDrop (withDrop : Bool) : Program := program do
  let pr ← addExtern "ryo_test_print"
  let dropU32 ← addFn "drop_in_place::<u32>" <| body unit [rawTo u32 true] do
    printI pr (copy ((place 1).deref u32))
    ret
  let vt ← Unsized.vtable (if withDrop then some dropU32 else none) 4 4 []
  let dynT := Unsized.dynTy
  addFn "main" <| body unit [] do
    let x ← newLocal u32
    storageLive x
    assignL x (.use (cint u32 5))
    let px ← tmp (rawTo u32 true) (rawOf x)
    let d ← newLocal (rawTo dynT true)
    storageLive d
    assignL d (.cast (.pointerCoercion (.unsize (.vtable vt))) px (rawTo dynT true))
    let next ← newBlock
    term (.drop ((place d).deref dynT) none next .continue)
    setBlock next
    printI pr (cint u32 6)
    ret

/-! ### Direct tags wider than the discriminant type -/

/-- `Option<i128>`: discriminant type `isize`, tag `u128` at 0, payload at 16. -/
def optI128 : Ty :=
  .enum [variant 0 [] 32 16, variant 1 [(16, i128)] 32 16] IntType.isize
    (.multiple ⟨0, IntType.u128, ⟨0, 1⟩, .direct⟩) 32 (Align.ofBytes 16)

/-- Write `Some(-3)`, copy it, match on the discriminant and return the payload; then `None`. -/
def wideTag : Program := mainOnly (retTy := i128) do
  let o ← newLocal optI128
  storageLive o
  assignL o (.aggregate (.adt 1 none) [cint i128 (-3)])
  let o2 ← newLocal optI128
  storageLive o2
  assignL o2 (.use (copyL o))
  let d ← tmp isize (.discriminant (place o2))
  ite d (assignL 0 (.use (copy (((place o2).downcast 1).field 0 i128))))
    (term .unreachable)
  stmt (.setDiscriminant (place o2) 0)
  assumeEq (← tmp isize (.discriminant (place o2))) (cint isize 0)
  ret

/-! ### `is_val_statically_known` -/

def staticallyKnown : Program := program do
  let f ← addIntrinsic "is_val_statically_known"
  addFn "main" <| body .bool [] do
    call (.inst f) [ci32 3] (place 0)
    ret

/-! ### `caller_location` with a constant caller location in a plain body -/

/-- `caller_location()` inlined into `main` (not `#[track_caller]`): the call's constant. -/
def inlinedCallerLocation : Program := program do
  let loc ← constBytes [42] 1
  let cl ← addIntrinsic "caller_location"
  addFn "main" <| body u8 [] do
    let r ← newLocal (refTo u8)
    storageLive r
    call (.inst cl) [] (place r) (callerLocation := some (.const (.ptr (.alloc loc) 0) (refTo u8)))
    assignL 0 (.use (copy ((place r).deref u8)))
    ret

def tests : List TestCase := [
  ⟨"M1b/mangled_internal_symbol", fun _ => expectReturnValue mangledAlloc (.int 42)⟩,
  ⟨"M1b/alloc_wrapped_args", fun _ => expectReturnValue wrappedAllocArgs (.int 42)⟩,
  ⟨"M1b/no_alloc_shim_marker", fun _ => expectReturnValue noAllocShim (.int 7)⟩,
  ⟨"M1b/fn_ptr_ignore_args", fun _ => ignoreArgs⟩,
  ⟨"M1b/drop_dyn", fun _ => expectPrinted (dynDrop true) [5, 6]⟩,
  ⟨"M1b/drop_dyn_null_entry", fun _ => expectPrinted (dynDrop false) [6]⟩,
  ⟨"M1b/wide_direct_tag", fun _ => expectReturnValue wideTag (.int (-3))⟩,
  ⟨"M1b/is_val_statically_known", fun _ => expectReturnValue staticallyKnown (.bool false)⟩,
  ⟨"M1b/caller_location_const", fun _ => expectReturnValue inlinedCallerLocation (.int 42)⟩
]

end RyoTest.M1b
