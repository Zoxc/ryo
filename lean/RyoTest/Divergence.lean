/-
Tests for the divergences from MiniRust (mir-spec §A.7) with run-time effects that the ported
MiniRust tests do not already cover: D3, D4, D5, D6, D7, D8, D13, D17, D20, D21, D22, D23,
D24, D27, D31, D32, D33, D34, D35, and the oracle checks of mir-spec §A.4 (`noBehavior`).
-/
import RyoTest.Harness

namespace RyoTest.Divergence

open Ryo.Spec Ryo.Spec.Build

/-! ### D3: valid ranges -/

def nonZeroU32 : Ty := .int .u32 ⟨1, 2 ^ 32 - 1⟩

def transmuteNonZero (v : Nat) : Program := mainOnly do
  let _ ← tmp nonZeroU32 (.cast .transmute (cint u32 v) nonZeroU32)
  ret

/-! ### D4: char -/

def charCast (v : Nat) (transmute : Bool) : Program := mainOnly do
  if transmute then
    let _ ← tmp .char (.cast .transmute (cint u32 v) .char)
  else
    let c ← tmp .char (.cast .intToInt (cu8 v) .char)
    assumeEq (← tmp u32 (.cast .intToInt c u32)) (cint u32 v)
  ret

/-! ### D5, D34: floats -/

def floats : Program := mainOnly do
  assumeBin .add f64 (cf64 0.1) (cf64 0.2) (cf64 (0.1 + 0.2))
  assumeBin .mul f32 (cf32 1.5) (cf32 3.0) (cf32 4.5)
  assumeBin .div f64 (cf64 1.0) (cf64 3.0) (cf64 (1.0 / 3.0))
  assumeBin .rem f64 (cf64 7.5) (cf64 2.0) (cf64 1.5)
  -- NaN compares unequal, also to itself
  let nan ← tmp f64 (.binaryOp .div (cf64 0.0) (cf64 0.0))
  assumeRv (.binaryOp .ne nan nan)
  let lt ← tmp .bool (.binaryOp .lt nan (cf64 1.0))
  assumeRv (.unaryOp .not lt)
  -- -0.0 == 0.0
  assumeRv (.binaryOp .eq (cf64 (-0.0)) (cf64 0.0))
  -- D34: saturating float -> int, NaN -> 0
  assumeEq (← tmp i32 (.cast .floatToInt (cf64 1e20) i32)) (ci32 2147483647)
  assumeEq (← tmp i32 (.cast .floatToInt (cf64 (-1e20)) i32)) (ci32 (-2147483648))
  assumeEq (← tmp u8 (.cast .floatToInt (cf64 (-3.7)) u8)) (cu8 0)
  assumeEq (← tmp i32 (.cast .floatToInt (cf64 (-3.7)) i32)) (ci32 (-3))
  assumeEq (← tmp i32 (.cast .floatToInt nan i32)) (ci32 0)
  -- D34: int -> float rounds to nearest even
  assumeEq (← tmp f64 (.cast .intToFloat (cint u64 (2 ^ 53 + 1)) f64)) (cf64 9007199254740992.0)
  assumeEq (← tmp f32 (.cast .floatToFloat (cf64 0.1) f32)) (cf32 0.1)
  assumeEq (← tmp f64 (.unaryOp .neg (cf64 2.5))) (cf64 (-2.5))
  ret

/-- D5: a NaN result's bits are a daemonic choice: an oracle answer outside RFC 3514's set
is "no behavior". -/
def nanOracle (bits : Nat) : Oracle where
  answer := fun n c s =>
    match c with
    | .nanBits _ _ => (bits : Nat)
    | c' => concreteOracle.answer n c' s

def nanProg : Program := mainOnly do
  let _ ← tmp f64 (.binaryOp .div (cf64 0.0) (cf64 0.0))
  ret

def nanChoice : Except String Unit := do
  -- the negative quiet NaN is allowed
  match (runWith (nanOracle 0xFFF8000000000000) nanProg).result with
  | .ok _ => pure ()
  | r => throw s!"negative qNaN should be allowed: {repr r}"
  -- a signaling NaN is not
  match (runWith (nanOracle 0x7FF0000000000001) nanProg).result with
  | .error (.noBehavior _) => pure ()
  | r => throw s!"sNaN should be no behavior: {repr r}"

/-- Exact float arithmetic agrees with the hardware on pseudo-random inputs. -/
def floatsMatchHardware : Except String Unit := Id.run do
  let mut s := 987654321
  for _ in [0:3000] do
    s := (s * 6364136223846793005 + 1442695040888963407) % 2 ^ 64
    let x := s
    s := (s * 6364136223846793005 + 1442695040888963407) % 2 ^ 64
    let y := s
    for op in ["add", "sub", "mul", "div"] do
      let r := match op with
        | "add" => Ryo.Spec.Float.add .f64 x y | "sub" => Ryo.Spec.Float.sub .f64 x y
        | "mul" => Ryo.Spec.Float.mul .f64 x y | _ => Ryo.Spec.Float.div .f64 x y
      let hw := Ryo.Spec.Float.hwBinop64 op x y
      let ok := match r with
        | .ok b => b == hw
        | .nan cands => Ryo.Spec.Float.isNaN .f64 hw && cands.length ≥ 2
      if !ok then return .error s!"f64 {op} {x} {y}: spec {repr r}, hardware {hw}"
      let r32 := match op with
        | "add" => Ryo.Spec.Float.add .f32 (x % 2^32) (y % 2^32) | "sub" => Ryo.Spec.Float.sub .f32 (x % 2^32) (y % 2^32)
        | "mul" => Ryo.Spec.Float.mul .f32 (x % 2^32) (y % 2^32) | _ => Ryo.Spec.Float.div .f32 (x % 2^32) (y % 2^32)
      let hw32 := Ryo.Spec.Float.hwBinop32 op (x % 2^32) (y % 2^32)
      let ok32 := match r32 with
        | .ok b => b == hw32
        | .nan _ => Ryo.Spec.Float.isNaN .f32 hw32
      if !ok32 then return .error s!"f32 {op} {x % 2^32} {y % 2^32}: spec {repr r32}, hardware {hw32}"
  .ok ()

/-! ### D6: function pointers -/

def fnPtrs : Program := program do
  let f ← addFn "f" (body i32 [i32] (do assignL 0 (.binaryOp .add (copyL 1) (ci32 1)); ret))
  addFn "main" <| body i32 [] do
    let fp ← newLocal fnPtrTy
    storageLive fp
    assignL fp (.cast (.pointerCoercion (.reifyFnPointer f)) (cfnDef f) fnPtrTy)
    call (.fnPtr (copyL fp)) [ci32 41] (place 0)
    ret

def callNonFnPtr : Program := mainOnly do
  let x ← newLocal u8
  storageLive x
  let p ← tmp fnPtrTy (.cast .transmute (← tmp (rawTo u8) (.rawPtr false (place x))) fnPtrTy)
  let u ← newLocal unit
  storageLive u
  call (.fnPtr p) [] (place u)
  ret

/-! ### D7: constants and statics -/

def writeConst : Program := program do
  let g ← constBytes [1, 2, 3, 4] 4
  addFn "main" <| body unit [] do
    let p ← newLocal (rawTo u32 true)
    storageLive p
    assignL p (.use (.const (.ptr (.alloc g) 0) (rawTo u32 true)))
    assumeEq (copy ((place p).deref u32)) (cint u32 0x04030201)
    assign ((place p).deref u32) (.use (cint u32 0))
    ret

def staticProg (mutable : Bool) : Program := program do
  let g ← addGlobal { bytes := [some 5, some 0, some 0, some 0], align := Align.ofBytes 4,
                      kind := .static mutable }
  addFn "main" <| body u32 [] do
    let p ← newLocal (rawTo u32 true)
    storageLive p
    assignL p (.use (.const (.ptr (.alloc g) 0) (rawTo u32 true)))
    assign ((place p).deref u32) (.use (cint u32 6))
    -- statics are unique: a second reference sees the write
    let q ← newLocal (rawTo u32)
    storageLive q
    assignL q (.use (.const (.ptr (.alloc g) 0) (rawTo u32)))
    assignL 0 (.use (copy ((place q).deref u32)))
    ret

/-- `ConstValue::Slice` (`&str`) and `ConstValue::Indirect`. -/
def constValues : Program := program do
  let s ← constBytes "hi!".toUTF8.toList 1
  let pair ← constBytes [7, 0, 0, 0, 9, 0, 0, 0] 4
  addFn "main" <| body unit [] do
    let r ← newLocal (refTo str)
    storageLive r
    assignL r (.use (.const (.slice s 3) (refTo str)))
    assumeEq (← tmp usize (.unaryOp .ptrMetadata (copyL r))) (cusize 3)
    let i ← newLocal usize
    storageLive i
    assignL i (.use (cusize 1))
    assumeEq (copy (((place r).deref str).index i)) (cu8 105)
    let pTy := tuple [(0, u32), (4, u32)] 8 4
    let v ← newLocal pTy
    storageLive v
    assignL v (.use (.const (.indirect pair 0) pTy))
    assumeEq (copy ((place v).field 1 u32)) (cint u32 9)
    ret

/-! ### D8: zero-sized allocations may share addresses -/

def sameAddrOracle : Oracle where
  answer := fun n c s =>
    match c with
    | .allocAddr 0 align => (alignTo 0x1000 align : Nat)
    | c' => concreteOracle.answer n c' s

def zstLocals : Program := mainOnly do
  let a ← newLocal unit
  let b ← newLocal unit
  storageLive a; storageLive b
  let pa ← tmp (rawTo unit) (.rawPtr false (place a))
  let pb ← tmp (rawTo unit) (.rawPtr false (place b))
  let _ ← tmp .bool (.binaryOp .eq pa pb)
  ret

def overlapOracle : Oracle where
  answer := fun n c s =>
    match c with
    | .allocAddr _ align => (alignTo 0x1000 align : Nat)
    | c' => concreteOracle.answer n c' s

def twoLocals : Program := mainOnly do
  let a ← newLocal u32
  let b ← newLocal u32
  storageLive a; storageLive b
  ret

def zstSharing : Except String Unit := do
  match (runWith sameAddrOracle zstLocals).result with
  | .ok _ => pure ()
  | r => throw s!"ZST allocations at the same address should be allowed: {repr r}"
  match (runWith overlapOracle twoLocals).result with
  | .error (.noBehavior _) => pure ()
  | r => throw s!"overlapping allocations should be no behavior: {repr r}"

/-! ### D13: uninitialized integers -/

def uninitInt : Program := mainOnly do
  let a ← newLocal u64
  storageLive a
  let _ ← tmp u64 (.binaryOp .add (copyL a) (cint u64 1))
  ret

/-! ### D17: atomics -/

def atomics (misaligned : Bool) : Program := program do
  let load ← addIntrinsic "atomic_load"
  let store ← addIntrinsic "atomic_store"
  let xadd ← addIntrinsic "atomic_xadd"
  let cxchg ← addIntrinsic "atomic_cxchg"
  addFn "main" <| body u32 [] do
    let x ← newLocal (array u32 2)
    storageLive x
    assignL x (.aggregate .array [cint u32 0, cint u32 0])
    let p0 ← tmp (rawTo u32 true) (.rawPtr true ((place x).proj1 (.constantIndex 0 2 false)))
    let p ← if misaligned then do
        let b ← tmp (rawTo u8 true) (.cast .ptrToPtr p0 (rawTo u8 true))
        let b1 ← tmp (rawTo u8 true) (.binaryOp .offset b (cusize 1))
        tmp (rawTo u32 true) (.cast .ptrToPtr b1 (rawTo u32 true))
      else pure p0
    callUnit (.inst store) [p, cint u32 5]
    assumeEq (← callTmp xadd u32 [p, cint u32 3]) (cint u32 5)
    let pairTy := tuple [(0, u32), (4, .bool)] 8 4
    let r ← callTmp cxchg pairTy [p, cint u32 8, cint u32 10]
    let _ := r
    call (.inst load) [p] (place 0)
    ret

/-! ### D21: heap -/

def heapProg (doubleFree : Bool) : Program := program do
  let alloc ← addExtern "__rust_alloc"
  let dealloc ← addExtern "__rust_dealloc"
  addFn "main" <| body unit [] do
    let p ← newLocal (rawTo u64 true)
    storageLive p
    call (.inst alloc) [cusize 8, cusize 8] (place p)
    assign ((place p).deref u64) (.use (cint u64 1))
    let b ← tmp (rawTo u8 true) (.cast .ptrToPtr (copyL p) (rawTo u8 true))
    callUnit (.inst dealloc) [b, cusize 8, cusize 8]
    if doubleFree then callUnit (.inst dealloc) [b, cusize 8, cusize 8]
    else
      -- use after free
      let _ ← tmp u64 (.use (copy ((place p).deref u64)))
    ret

/-! ### D22, D23, D24 -/

def threadLocal : Program := program do
  let g ← addGlobal { bytes := [some 1, some 0, some 0, some 0], align := Align.ofBytes 4,
                      kind := .threadLocal }
  addFn "main" <| body u32 [] do
    let p ← newLocal (rawTo u32 true)
    storageLive p
    assignL p (.threadLocalRef g)
    assign ((place p).deref u32) (.use (cint u32 3))
    let q ← newLocal (rawTo u32 true)
    storageLive q
    assignL q (.threadLocalRef g)
    assignL 0 (.use (copy ((place q).deref u32)))
    ret

def runtimeChecks : Program := mainOnly do
  assumeEq (.runtimeChecks .overflowChecks true) (cbool true)
  assumeEq (.runtimeChecks .ubChecks false) (cbool false)
  ret

def typeIdPtr : Program := mainOnly do
  let p ← tmp (rawTo u8) (.use (.const (.ptr .typeId 0x1234) (rawTo u8)))
  assumeEq (← tmp usize (.cast .transmute p usize)) (cusize 0x1234)
  ret

/-! ### D27: 128-bit integers -/

def i128Ops : Program := mainOnly do
  assumeBin .mul u128 (cint u128 (2 ^ 64)) (cint u128 (2 ^ 63)) (cint u128 (2 ^ 127))
  assumeBin .add i128 (cint i128 (2 ^ 127 - 1)) (cint i128 1) (cint i128 (-(2 ^ 127)))
  assumeBin .div i128 (cint i128 (-(2 ^ 100))) (cint i128 (2 ^ 50)) (cint i128 (-(2 ^ 50)))
  ret

/-! ### D31, D32 -/

def repeatAndUnion : Program := mainOnly do
  let a ← newLocal (array u16 3)
  storageLive a
  assignL a (.repeat (cint u16 7) 3)
  let i ← newLocal usize
  storageLive i
  assignL i (.use (cusize 2))
  assumeEq (copy ((place a).index i)) (cint u16 7)
  let uTy : Ty := .union [(0, u8), (0, u32)] [(0, 4)] 4 (Align.ofBytes 4)
  let u ← newLocal uTy
  storageLive u
  assignL u (.aggregate (.adt 0 (some 0)) [cu8 0xAB])
  assumeEq (copy ((place u).field 0 u8)) (cu8 0xAB)
  ret

/-! ### D33, D35 -/

def transmuteSize : Program := mainOnly do
  let _ ← tmp u32 (.cast .transmute (cint u64 1) u32)
  ret

def wideToThin : Program := mainOnly do
  let arr ← newLocal (array u8 4)
  storageLive arr
  let p ← tmp (rawTo u8) (.rawPtr false (place arr))
  let s ← tmp (rawTo (slice u8)) (.aggregate .rawPtr [p, cusize 4])
  let t ← tmp (rawTo u8) (.cast .ptrToPtr s (rawTo u8))
  assumeRv (.binaryOp .eq t p)
  ret

def tests : List TestCase := [
  ⟨"D3/nonzero_valid", fun _ => expectReturn (transmuteNonZero 1)⟩,
  ⟨"D3/nonzero_invalid", fun _ => expectUb (transmuteNonZero 0) "not valid at new type"⟩,
  ⟨"D4/u8_as_char", fun _ => expectReturn (charCast 65 false)⟩,
  ⟨"D4/surrogate_char", fun _ => expectUb (charCast 0xD800 true) "not valid at new type"⟩,
  ⟨"D4/too_large_char", fun _ => expectUb (charCast 0x110000 true) "not valid at new type"⟩,
  ⟨"D5/floats", fun _ => expectReturn floats⟩,
  ⟨"D5/nan_choice", fun _ => nanChoice⟩,
  ⟨"D5/matches_hardware", fun _ => floatsMatchHardware⟩,
  ⟨"D6/fn_ptr_call", fun _ => expectReturnValue fnPtrs (.int 42)⟩,
  ⟨"D6/call_non_fn_ptr", fun _ => expectUb callNonFnPtr "invalid pointer for function lookup"⟩,
  ⟨"D7/write_const", fun _ => expectUb writeConst "store to read-only memory"⟩,
  ⟨"D7/static_mut", fun _ => expectReturnValue (staticProg true) (.int 6)⟩,
  ⟨"D7/static_immutable", fun _ => expectUb (staticProg false) "store to read-only memory"⟩,
  ⟨"D7/const_values", fun _ => expectReturn constValues⟩,
  ⟨"D8/zst_sharing", fun _ => zstSharing⟩,
  ⟨"D13/uninit_int", fun _ => expectUb uninitInt "violates the language invariant"⟩,
  ⟨"D17/atomics", fun _ => expectReturnValue (atomics false) (.int 10)⟩,
  ⟨"D17/atomics_misaligned", fun _ => expectUb (atomics true) "misaligned"⟩,
  ⟨"D21/use_after_free", fun _ => expectUb (heapProg false) "dead allocation"⟩,
  ⟨"D21/double_free", fun _ => expectUb (heapProg true) "double-free"⟩,
  ⟨"D22/thread_local", fun _ => expectReturnValue threadLocal (.int 3)⟩,
  ⟨"D23/runtime_checks", fun _ => expectReturn runtimeChecks⟩,
  ⟨"D24/type_id_ptr", fun _ => expectReturn typeIdPtr⟩,
  ⟨"D27/i128", fun _ => expectReturn i128Ops⟩,
  ⟨"D31_D32/repeat_union", fun _ => expectReturn repeatAndUnion⟩,
  ⟨"D33/transmute_size", fun _ => expectUb transmuteSize "different size"⟩,
  ⟨"D35/wide_to_thin", fun _ => expectReturn wideToThin⟩
]

end RyoTest.Divergence
