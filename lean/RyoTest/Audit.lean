/-
Tests for the fixes of the spec audit (docs/divergences.md R1–R8): negative int-to-pointer
casts, the allocation bound, `powi`, `fmuladd`, `minimum_number_nsz` of zeros, `compare_bytes`,
`realloc` in place, and `write` in the trace; R23: `Reborrow` copies the place.
-/
import RyoTest.Harness

namespace RyoTest.Audit

open Ryo.Spec Ryo.Spec.Build

/-- An oracle that answers `c` with `f` where it applies, else as the concrete one. -/
def withOracle (f : (c : Choice) → State → Option c.Answer) : Oracle where
  answer := fun n c s => (f c s).getD (concreteOracle.answer n c s)

/-! ### R1: negative integers cast to pointers sign-extend -/

def negIntToPtr : Program := mainOnly do
  let p ← tmp (rawTo u8) (.cast .pointerWithExposedProvenance (cint isize (-1)) (rawTo u8))
  assumeEq (← tmp usize (.cast .transmute p usize)) (cusize (2 ^ 64 - 1))
  let q ← tmp (rawTo u8) (.cast .pointerWithExposedProvenance (cint i32 (-16)) (rawTo u8))
  assumeEq (← tmp usize (.cast .transmute q usize)) (cusize (2 ^ 64 - 16))
  ret

/-! ### R2: an allocation must end below 2^64 -/

def addrBound : Except String Unit := do
  check (!(({} : Memory).addrOk (2 ^ 64 - 8) 8 ⟨3⟩)) "an allocation ending at 2^64 is allowed"
  check (({} : Memory).addrOk (2 ^ 64 - 16) 8 ⟨3⟩) "an allocation ending below 2^64 is rejected"
  let top := withOracle fun c _ => match c with
    | .allocAddr size _ => some (2 ^ 64 - size)
    | _ => none
  match (runWith top (mainOnly do let a ← newLocal u64; storageLive a; ret)).result with
  | .error (.noBehavior _) => pure ()
  | r => throw s!"an allocation ending at 2^64 should be no behavior: {repr r}"

/-! ### R3: `powi` is compiler-rt's `__powidf2` -/

/-- `__powidf2` on the hardware's `Float` (one rounding per operation, as the C code). -/
def hwPowi64 (x : Nat) (k : Int) : Nat := Id.run do
  let mut a := _root_.Float.ofBits (UInt64.ofNat x)
  let mut r : _root_.Float := 1.0
  let mut b := k.natAbs
  for _ in [0:40] do
    if b % 2 == 1 then r := r * a
    b := b / 2
    if b == 0 then break
    a := a * a
  (if k < 0 then 1.0 / r else r).toBits.toNat

def hwPowi32 (x : Nat) (k : Int) : Nat := Id.run do
  let mut a := _root_.Float32.ofBits (UInt32.ofNat x)
  let mut r : _root_.Float32 := 1.0
  let mut b := k.natAbs
  for _ in [0:40] do
    if b % 2 == 1 then r := r * a
    b := b / 2
    if b == 0 then break
    a := a * a
  (if k < 0 then 1.0 / r else r).toBits.toNat

def powiMatchesLoop : Except String Unit := Id.run do
  let mut s := 123456789
  let ks : List Int := [0, 1, 2, 3, 7, 13, 31, 77, -1, -2, -5, -31, 1000, -1000, 2147483647,
    -2147483648]
  for _ in [0:300] do
    s := (s * 6364136223846793005 + 1442695040888963407) % 2 ^ 64
    -- values in [0.5, 4) with either sign, plus some arbitrary bit patterns
    let x := if s % 4 == 0 then s else (s % 2 ^ 52) + (if s % 3 == 0 then 1022 else 1024) * 2 ^ 52 +
      (if s % 5 == 0 then 2 ^ 63 else 0)
    for k in ks do
      let hw := hwPowi64 x k
      let ok := match Ryo.Spec.Float.powi .f64 x k with
        | .ok b => b == hw
        | .nan _ => Ryo.Spec.Float.isNaN .f64 hw
      if !ok then
        return .error s!"f64 powi {x} {k}: spec {repr (Ryo.Spec.Float.powi .f64 x k)}, loop {hw}"
      let x32 := x % 2 ^ 32
      let hw32 := hwPowi32 x32 k
      let ok32 := match Ryo.Spec.Float.powi .f32 x32 k with
        | .ok b => b == hw32
        | .nan _ => Ryo.Spec.Float.isNaN .f32 hw32
      if !ok32 then return .error s!"f32 powi {x32} {k}: spec {repr (Ryo.Spec.Float.powi .f32 x32 k)}"
  .ok ()

def powiProg : Program := program do
  let powi ← addIntrinsic "powif64"
  addFn "main" <| body unit [] do
    assumeEq (← callTmp powi f64 [cf64 1.5, ci32 3]) (cf64 3.375)
    assumeEq (← callTmp powi f64 [cf64 2.0, ci32 (-2)]) (cf64 0.25)
    -- powi(NaN, 0) = 1
    let nan ← tmp f64 (.binaryOp .div (cf64 0.0) (cf64 0.0))
    assumeEq (← callTmp powi f64 [nan, ci32 0]) (cf64 1.0)
    -- (1 + 2/37)^7: the repeated-squaring result, which differs from the host `pow`'s
    let x : _root_.Float := 1.0 + 2.0 / 37.0
    let r ← callTmp powi f64 [cf64 x, ci32 7]
    assumeEq r (.const (.scalar (hwPowi64 x.toBits.toNat 7)) f64)
    assumeRv (.binaryOp .ne r (cf64 (x.pow 7)))
    ret

/-! ### R4: `fmuladd` is fused or not -/

def fmuladdProg : Program := program do
  let fmuladd ← addIntrinsic "fmuladdf64"
  addFn "main" <| body f64 [] do
    call (.inst fmuladd) [cf64 0.1, cf64 10.0, cf64 (-1.0)] (place 0)
    ret

def fmuladdChoice : Except String Unit := do
  -- unfused: 0.1 * 10.0 rounds to 1.0 exactly
  expectReturnValue fmuladdProg (.float .f64 0)
  let fused := withOracle fun c _ => match c with
    | .fmulAddFused => some true
    | _ => none
  match (runWith fused fmuladdProg).result with
  | .ok (.returned (.float .f64 b)) =>
    check (b == (5.551115123125783e-17 : _root_.Float).toBits.toNat) s!"fused result {b}"
  | r => throw s!"fused fmuladd: {repr r}"

/-! ### R5: `minimum_number_nsz` of opposite zeros -/

def nszProg : Program := program do
  let mn ← addIntrinsic "minimum_number_nsz_f64"
  addFn "main" <| body f64 [] do
    call (.inst mn) [cf64 0.0, cf64 (-0.0)] (place 0)
    ret

def nszChoice : Except String Unit := do
  -- the concrete oracle takes the second operand (as the fallback body)
  expectReturnValue nszProg (.float .f64 (2 ^ 63))
  let first := withOracle fun c _ => match c with
    | .nszZero => some false
    | _ => none
  match (runWith first nszProg).result with
  | .ok (.returned (.float .f64 0)) => pure ()
  | r => throw s!"nsz zero, first operand: {repr r}"

/-! ### R6: `compare_bytes` returns any value of the right sign -/

def compareBytesProg : Program := program do
  let a ← constBytes [1, 5, 9]
  let b ← constBytes [1, 2, 0]
  let cmp ← addIntrinsic "compare_bytes"
  addFn "main" <| body i32 [] do
    call (.inst cmp) [.const (.ptr (.alloc a) 0) (rawTo u8), .const (.ptr (.alloc b) 0) (rawTo u8),
      cusize 3] (place 0)
    ret

def compareBytesChoice : Except String Unit := do
  expectReturnValue compareBytesProg (.int 3)
  let answer (r : Int) := withOracle fun c _ => match c with
    | .compareBytes _ => some r
    | _ => none
  match (runWith (answer 1) compareBytesProg).result with
  | .ok (.returned (.int 1)) => pure ()
  | r => throw s!"compare_bytes answer 1: {repr r}"
  match (runWith (answer (-1)) compareBytesProg).result with
  | .error (.noBehavior _) => pure ()
  | r => throw s!"compare_bytes with the wrong sign should be no behavior: {repr r}"

/-! ### R7: `__rust_realloc` may return the old address -/

def reallocProg : Program := program do
  let alloc ← addExtern "__rust_alloc"
  let realloc ← addExtern "__rust_realloc"
  addFn "main" <| body u64 [] do
    let p ← newLocal (rawTo u64 true)
    storageLive p
    call (.inst alloc) [cusize 8, cusize 8] (place p)
    assign ((place p).deref u64) (.use (cint u64 42))
    let b ← tmp (rawTo u8 true) (.cast .ptrToPtr (copyL p) (rawTo u8 true))
    let q ← newLocal (rawTo u8 true)
    storageLive q
    call (.inst realloc) [b, cusize 8, cusize 8, cusize 16] (place q)
    assumeRv (.binaryOp .eq (copyL q) b)
    let q64 ← tmp (rawTo u64 true) (.cast .ptrToPtr (copyL q) (rawTo u64 true))
    let r ← newLocal (rawTo u64 true)
    storageLive r
    assignL r (.use q64)
    assignL 0 (.use (copy ((place r).deref u64)))
    ret

/-- The 16-byte block reuses the address of a dead heap allocation. -/
def reuseOracle : Oracle := withOracle fun c s => match c with
  | .allocAddr 16 _ =>
    (s.mem.allocs.toList.find? fun a => !a.live && a.kind == .heap).map (·.addr)
  | _ => none

def reallocInPlace : Except String Unit := do
  match (runWith reuseOracle reallocProg).result with
  | .ok (.returned (.int 42)) => pure ()
  | r => throw s!"realloc in place: {repr r}"
  -- the concrete oracle moves the block, so the `assume` fails
  expectUb reallocProg "Assume"

/-! ### R8: `write` records the bytes -/

def writeProg (uninit : Bool) : Program := program do
  let msg ← constBytes "hi".toUTF8.toList
  let write ← addExtern "write"
  addFn "main" <| body unit [] do
    let buf ← if uninit then do
        let a ← newLocal (array u8 2)
        storageLive a
        tmp (rawTo u8) (.cast .ptrToPtr (← tmp (rawTo (array u8 2)) (.rawPtr false (place a))) (rawTo u8))
      else pure (.const (.ptr (.alloc msg) 0) (rawTo u8))
    let _ ← callTmp write isize [ci32 1, buf, cusize 2]
    ret

def writeTrace : Except String Unit := do
  let r := run (writeProg false)
  check (r.events.toList == [.write 1 [104, 105]]) s!"write events: {repr r.events}"
  expectUb (writeProg true) "uninitialized"

/-! ### R23: `Reborrow` copies the place's value -/

/-- `s = (&mut x, 7)`; `t = Reborrow(s)`; `*t.0 = 42`; returns `x` (42) after checking `t.1`. -/
def reborrowProg (mutbl : Bool) (ty : Ty) (f1 : Ty := i32) : Program := mainOnly (retTy := i32) do
  let sTy := cTuple [refTo i32 true, i32]
  let x ← newLocal i32
  storageLive x
  assignL x (.use (ci32 5))
  let r ← tmp (refTo i32 true) (.ref true (place x))
  let s ← newLocal sTy
  storageLive s
  assignL s (.aggregate .tuple [r, ci32 7])
  let t ← newLocal ty
  storageLive t
  assignL t (.reborrow ty mutbl (place s))
  assumeEq (copy ((place t).field 1 f1)) (cint f1 7)
  assign (((place t).field 0 (refTo i32 true)).deref i32) (.use (ci32 42))
  assignL 0 (.use (copyL x))
  ret

def reborrowCopies : Except String Unit := do
  let sTy := cTuple [refTo i32 true, i32]
  expectReturnValue (reborrowProg true sTy) (.int 42)
  -- `CoerceShared` to a type of the same layout
  expectReturnValue (reborrowProg false (cTuple [refTo i32 true, u32]) u32) (.int 42)
  expectIllFormed (reborrowProg false (cTuple [refTo i32 true, u64, u64]) u64) "Reborrow"

def tests : List TestCase := [
  ⟨"R1/neg_int_to_ptr", fun _ => expectReturn negIntToPtr⟩,
  ⟨"R2/addr_bound", fun _ => addrBound⟩,
  ⟨"R3/powi_loop", fun _ => powiMatchesLoop⟩,
  ⟨"R3/powi", fun _ => expectReturn powiProg⟩,
  ⟨"R4/fmuladd", fun _ => fmuladdChoice⟩,
  ⟨"R5/nsz_zero", fun _ => nszChoice⟩,
  ⟨"R6/compare_bytes", fun _ => compareBytesChoice⟩,
  ⟨"R7/realloc_in_place", fun _ => reallocInPlace⟩,
  ⟨"R8/write_trace", fun _ => writeTrace⟩,
  ⟨"R23/reborrow_copies", fun _ => reborrowCopies⟩
]

end RyoTest.Audit
