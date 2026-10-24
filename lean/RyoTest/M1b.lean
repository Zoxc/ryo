/-
Tests for the spec fixes found by the M1b differential runs: v0-mangled internal symbols and
ABI-transparent wrappers in the allocator shims, `__rust_no_alloc_shim_is_unstable_v2`,
`Ignore` arguments and `rust`/`rust-call` in fn-pointer calls, `Drop` of `dyn Trait` places,
direct tags wider than the discriminant type, `is_val_statically_known`,
`caller_location` with a constant caller location, and `assert_inhabited` & co. (R30).
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

/-! ### `assert_inhabited`, `assert_zero_valid`, `assert_mem_uninitialized_valid` (R30) -/

def neverT : Ty := neverTy
/-- `NonZero<u32>`: a struct around `pattern_type!(u32 is 1..)`. -/
def nonZeroU32 : Ty := tuple [(0, .int IntType.u32 ⟨1, 2 ^ 32 - 1⟩)] 4 4
/-- `Option<&u8>`: niche in the pointer (tag range `0..=max` after reserving 0). -/
def optRefU8 : Ty :=
  .enum [variant 0 [] 8 8, variant 1 [(0, refTo u8)] 8 8] IntType.isize
    (.multiple ⟨0, IntType.usize, ⟨0, 2 ^ 64 - 1⟩, .niche 1 0 0 0⟩) 8 (Align.ofBytes 8)
/-- `Option<bool>`: tag range `0..=2`. -/
def optBool : Ty :=
  .enum [variant 0 [] 1 1, variant 1 [(0, bool)] 1 1] IntType.isize
    (.multiple ⟨0, IntType.u8, ⟨0, 2⟩, .niche 1 0 0 2⟩) 1 .one
/-- `enum E { A = 1, B = 2 }`: direct tag, range `1..=2`. -/
def oneTwo : Ty :=
  .enum [variant 1 [] 1 1, variant 2 [] 1 1] IntType.isize
    (.multiple ⟨0, IntType.u8, ⟨1, 2⟩, .direct⟩) 1 .one
/-- `Ordering` (`-1..=1` as `i8`): a wrapping tag range `255..=1`. -/
def ordering : Ty :=
  .enum [variant (-1) [] 1 1, variant 0 [] 1 1, variant 1 [] 1 1] IntType.i8
    (.multiple ⟨0, IntType.i8, ⟨255, 1⟩, .direct⟩) 1 .one
/-- `enum W { A(&u8) }`: `Variants::Single`, the variant's fields are checked. -/
def singleRef : Ty := .enum [variant 0 [(0, refTo u8)] 8 8] IntType.isize (.single 0) 8 (Align.ofBytes 8)
/-- `enum { A(u32, !), B(!) }` with `Variants::Single` of the uninhabited `A`. -/
def singleUninhabited : Ty :=
  .enum [variant 0 [(0, u32), (4, neverT)] 4 4 false, variant 1 [(0, neverT)] 4 4 false]
    IntType.isize (.single 0) 4 (Align.ofBytes 4)
/-- `union { a: &u8 }`. -/
def unionRef : Ty := .union [(0, refTo u8)] [(0, 8)] 8 (Align.ofBytes 8)
/-- `Box<T>` as an intrinsic's type argument shows it (`TyArg.ty`). -/
def boxOf (t : Ty) : Ty := tuple [(0, boxTo t)] (if t.isSized then 8 else 16) 8

/-- (name, type, inhabited, zero-valid, 0x01-fill-valid), by
`check_validity_requirement{,_lax}`. -/
def validityTable : List (String × Ty × Bool × Bool × Bool) := [
  ("!", neverT, false, false, false),
  ("(u8, !)", tuple [(0, u8), (1, neverT)] 1 1, false, false, false),
  ("[!; 0]", .array neverT 0, true, true, true),
  ("[!; 1]", .array neverT 1, false, false, false),
  ("bool", bool, true, true, true),
  ("char", .char, true, true, false),
  ("u8", u8, true, true, true),
  ("u32", u32, true, true, true),
  ("f32", f32, true, true, true),
  ("()", unit, true, true, true),
  ("NonZeroU32", nonZeroU32, true, false, true),
  ("&u8", refTo u8, true, false, false),
  ("&u16", refTo u16, true, false, false),
  ("&()", refTo unit, true, false, true),
  ("&str", refTo (.slice u8), true, false, true),
  ("&[u16]", refTo (.slice u16), true, false, false),
  -- `dyn` metadata is a `&[usize; n]` field
  ("&dyn Speak", refTo Unsized.dynTy, true, false, false),
  ("*const u32", rawTo u32, true, true, true),
  ("*const [u32]", rawTo (.slice u32), true, true, true),
  ("*const dyn Speak", rawTo Unsized.dynTy, true, false, false),
  ("Box<dyn Speak>", boxOf Unsized.dynTy, true, false, false),
  ("fn()", fnPtrTy, true, false, true),
  ("Box<u32>", boxOf u32, true, false, false),
  ("Box<u8>", boxOf u8, true, false, false),
  ("Box<()>", boxOf unit, true, false, true),
  ("Box<[u8]>", boxOf (.slice u8), true, false, true),
  ("[u8; 4]", .array u8 4, true, true, true),
  ("[bool; 2]", .array bool 2, true, true, true),
  ("[&u8; 1]", .array (refTo u8) 1, true, true, true),
  ("[char; 1]", .array .char 1, true, true, true),
  ("(u32, u16)", tuple [(0, u32), (4, u16)] 8 4, true, true, true),
  ("(u32, &u8)", tuple [(0, u32), (8, refTo u8)] 16 8, true, false, false),
  ("(u32, char)", tuple [(0, u32), (4, .char)] 8 4, true, true, false),
  ("(NonZeroU32,)", tuple [(0, nonZeroU32)] 4 4, true, false, true),
  ("Option<&u8>", optRefU8, true, true, true),
  ("Option<bool>", optBool, true, true, true),
  ("enum { A = 1, B = 2 }", oneTwo, true, false, true),
  ("Ordering", ordering, true, true, true),
  ("enum { A(&u8) }", singleRef, true, false, false),
  ("enum { A(u32, !), B(!) }", singleUninhabited, false, false, false),
  ("union { a: &u8 }", unionRef, true, true, true)
]

def validityChecks : Except String Unit :=
  validityTable.forM fun (name, ty, inh, zero, uninit) => do
    let got := (Sem.checkValidityRequirement .inhabited ty,
      Sem.checkValidityRequirement .zero ty,
      Sem.checkValidityRequirement .uninitMitigated0x01Fill ty)
    if got != (inh, zero, uninit) then
      throw s!"{name}: expected {(inh, zero, uninit)}, got {got}"

def validityMessages : Except String Unit := do
  let m (req : Sem.ValidityRequirement) (name : String) (ty : Ty) :=
    Sem.panicIntrinsicMessage req ⟨ty, name⟩
  check (m .zero "u32" u32 == none) "u32 is zero-valid"
  check (m .zero "&u8" (refTo u8) ==
    some "attempted to zero-initialize type `&u8`, which is invalid") "zero message"
  check (m .uninitMitigated0x01Fill "char" .char ==
    some "attempted to leave type `char` uninitialized, which is invalid") "uninit message"
  -- the uninhabited message wins for all three
  check (m .zero "!" neverT == some "attempted to instantiate uninhabited type `!`") "never zero"
  check (m .inhabited "!" neverT == some "attempted to instantiate uninhabited type `!`")
    "never inhabited"

/-- `main` calls `name::<arg>()`, then prints 7; `panic_nounwind` (a body here) prints the
message's length and first byte, then aborts. -/
def panicIntrinsic (name : String) (arg : TyArg) (withLangItem := true) : Program := program do
  let pr ← addExtern "ryo_test_print"
  let ab ← addExtern "abort"
  let strRef := refTo (.slice u8)
  let pn ← addFn "panic_nounwind" <| body unit [strRef] do
    printI pr (← tmp usize (.unaryOp .ptrMetadata (copyL 1)))
    printI pr (.copy ⟨1, [.deref (.slice u8), .constantIndex 0 1 false]⟩)
    callUnit (.inst ab) []
    ret
  if withLangItem then modify fun s => { s with langItems := { panicNounwind := some pn } }
  let f ← addIntrinsic name [some arg]
  addFn "main" <| body unit [] do
    callUnit (.inst f) []
    printI pr (cint u32 7)
    ret

def expectPanicMessage (p : Program) (msg : String) : Except String Unit :=
  expectPrinted p [msg.utf8ByteSize, msg.toUTF8[0]!.toNat]
    (fun r => match r.result with | .error .abort => true | _ => false)

def tests : List TestCase := [
  ⟨"M1b/mangled_internal_symbol", fun _ => expectReturnValue mangledAlloc (.int 42)⟩,
  ⟨"M1b/alloc_wrapped_args", fun _ => expectReturnValue wrappedAllocArgs (.int 42)⟩,
  ⟨"M1b/no_alloc_shim_marker", fun _ => expectReturnValue noAllocShim (.int 7)⟩,
  ⟨"M1b/fn_ptr_ignore_args", fun _ => ignoreArgs⟩,
  ⟨"M1b/drop_dyn", fun _ => expectPrinted (dynDrop true) [5, 6]⟩,
  ⟨"M1b/drop_dyn_null_entry", fun _ => expectPrinted (dynDrop false) [6]⟩,
  ⟨"M1b/wide_direct_tag", fun _ => expectReturnValue wideTag (.int (-3))⟩,
  ⟨"M1b/is_val_statically_known", fun _ => expectReturnValue staticallyKnown (.bool false)⟩,
  ⟨"M1b/caller_location_const", fun _ => expectReturnValue inlinedCallerLocation (.int 42)⟩,
  ⟨"M1b/validity_requirements", fun _ => validityChecks⟩,
  ⟨"M1b/validity_messages", fun _ => validityMessages⟩,
  ⟨"M1b/assert_zero_valid_ok", fun _ =>
    expectPrinted (panicIntrinsic "assert_zero_valid" ⟨u32, "u32"⟩) [7]⟩,
  ⟨"M1b/assert_zero_valid_panics", fun _ =>
    expectPanicMessage (panicIntrinsic "assert_zero_valid" ⟨refTo u8, "&u8"⟩)
      "attempted to zero-initialize type `&u8`, which is invalid"⟩,
  ⟨"M1b/assert_mem_uninitialized_valid_ok", fun _ =>
    expectPrinted (panicIntrinsic "assert_mem_uninitialized_valid" ⟨bool, "bool"⟩) [7]⟩,
  ⟨"M1b/assert_mem_uninitialized_valid_panics", fun _ =>
    expectPanicMessage (panicIntrinsic "assert_mem_uninitialized_valid" ⟨.char, "char"⟩)
      "attempted to leave type `char` uninitialized, which is invalid"⟩,
  ⟨"M1b/assert_inhabited_ok", fun _ =>
    expectPrinted (panicIntrinsic "assert_inhabited" ⟨.array neverT 0, "[!; 0]"⟩) [7]⟩,
  ⟨"M1b/assert_inhabited_panics", fun _ =>
    expectPanicMessage (panicIntrinsic "assert_inhabited" ⟨neverT, "!"⟩)
      "attempted to instantiate uninhabited type `!`"⟩,
  ⟨"M1b/assert_zero_valid_uninhabited", fun _ =>
    expectPanicMessage (panicIntrinsic "assert_zero_valid" ⟨neverT, "!"⟩)
      "attempted to instantiate uninhabited type `!`"⟩,
  ⟨"M1b/assert_without_panic_nounwind", fun _ =>
    expectIllFormed (panicIntrinsic "assert_inhabited" ⟨neverT, "!"⟩ (withLangItem := false))
      "panic_nounwind"⟩
]

end RyoTest.M1b
