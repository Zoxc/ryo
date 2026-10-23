/-
Ports of MiniRust `tooling/minitest/src/tests/{call, return_, unwinding, catch_unwind}.rs`,
plus tests for the call-related divergences: D12 (in-place arguments and return place), D14
(ABI compatibility, `#[track_caller]`, `rust-call`), D15 (validation at entry/return), D18
(MIR unwinding), D19 (`Drop`, `Assert`), D25 (stack overflow), tail calls.

Adaptations: unwinding is started by an external call to `_Unwind_RaiseException` (D18:
unwinding starts only in callees); `print` is the `ryo_test_print` shim; MiniRust's
`StartUnwind`/`StopUnwind` and catch blocks are replaced by MIR `UnwindAction`s and the
`catch_unwind` intrinsic.
-/
import RyoTest.Harness

namespace RyoTest.Call

open Ryo.Spec Ryo.Spec.Build

/-! ### call.rs, return_.rs -/

def callProg (calleeRet : Ty) (calleeArgs : List Ty) (args : List Operand) (destTy : Ty)
    (target := true) : Program := program do
  let callee ← addFn "callee" (body calleeRet calleeArgs ret)
  addFn "main" <| body unit [] do
    let d ← newLocal destTy
    storageLive d
    if target then
      call (.inst callee) args (place d)
      ret
    else
      term (.call (.inst callee) args (place d) none .continue)

def retMismatch : Program := program do
  let callee ← addFn "callee" (body u64 [] (do assignL 0 (.use (cint u64 0)); ret))
  addFn "main" <| body unit [] do
    let d ← newLocal u8
    storageLive d
    call (.inst callee) [] (place d)
    ret

/-! ### D14: ABI compatibility -/

def nonZeroI32 : Ty := .int .i32 ⟨1, 2 ^ 32 - 1⟩

/-- A `repr(transparent)`-like wrapper `struct W(i32, ())`. -/
def wrapperI32 : Ty := tuple [(0, i32), (4, unit)] 4 4

/-- `Option<&i32>`: niche in the null pointer. -/
def optRef : Ty :=
  .enum [variant 0 [] 8 8, variant 1 [(0, refTo i32)] 8 8] IntType.isize
    (.multiple ⟨0, IntType.usize, ValidRange.full 8, .niche 1 0 0 0⟩) 8 (Align.ofBytes 8)

def abiCompat (argTy paramTy : Ty) (arg : Operand) : Program := program do
  let callee ← addFn "callee" (body unit [paramTy] ret)
  addFn "main" <| body unit [] do
    callUnit (.inst callee) [arg]
    ret

/-- Pass `Option<&i32>` (`None`) where `*const i32` is expected: compatible (D14). -/
def optRefToPtr : Program := program do
  let callee ← addFn "callee" (body unit [rawTo i32] ret)
  addFn "main" <| body unit [] do
    let o ← newLocal optRef
    storageLive o
    stmt (.setDiscriminant (place o) 0)
    callUnit (.inst callee) [copyL o]
    ret

/-- D15: the callee validates its argument at its own type (`NonZero`-like range). -/
def entryValidation : Program := abiCompat i32 nonZeroI32 (ci32 0)

/-- D15: the return value is validated at `Return`. -/
def returnValidation : Program := program do
  let callee ← addFn "callee" (body .bool [] ret)  -- never writes `_0`
  addFn "main" <| body unit [] do
    let d ← newLocal .bool
    storageLive d
    call (.inst callee) [] (place d)
    ret

/-! ### D12: in-place arguments and return place -/

/-- `callee(move x, &raw x)`: the callee's argument lives at the caller's place. -/
def inPlaceAliases : Program := program do
  let callee ← addFn "callee" <| body .bool [u32, rawTo u32] do
    assignL 0 (.binaryOp .eq (← tmp (rawTo u32) (.rawPtr false (place 1))) (copyL 2))
    ret
  addFn "main" <| body .bool [] do
    let x ← newLocal u32
    storageLive x
    assignL x (.use (cint u32 7))
    let p ← tmp (rawTo u32) (.rawPtr false (place x))
    call (.inst callee) [move (place x), p] (place 0)
    ret

/-- After a call with `move x`, `x` is unspecified (here: uninitialized). -/
def movedIsUninit : Program := program do
  let callee ← addFn "callee" (body unit [u32] ret)
  addFn "main" <| body unit [] do
    let x ← newLocal u32
    storageLive x
    assignL x (.use (cint u32 7))
    callUnit (.inst callee) [move (place x)]
    let _ ← tmp u32 (.use (copyL x))
    ret

/-- `copy` arguments are not affected. -/
def copiedIsKept : Program := program do
  let callee ← addFn "callee" (body unit [u32] (do assignL 1 (.use (cint u32 0)); ret))
  addFn "main" <| body unit [] do
    let x ← newLocal u32
    storageLive x
    assignL x (.use (cint u32 7))
    callUnit (.inst callee) [copyL x]
    assumeEq (copyL x) (cint u32 7)
    ret

/-- The destination is de-initialized while the call runs: the callee observes it through a
pointer. -/
def destDeinit : Program := program do
  let callee ← addFn "callee" <| body u32 [rawTo u32] do
    assignL 0 (.use (copy ((place 1).deref u32)))
    ret
  addFn "main" <| body unit [] do
    let d ← newLocal u32
    storageLive d
    assignL d (.use (cint u32 1))
    let p ← tmp (rawTo u32) (.rawPtr false (place d))
    call (.inst callee) [p] (place d)
    ret

/-! ### D14: track_caller, rust-call -/

/-- A `#[track_caller]` function returning its caller location; another one forwarding it. -/
def trackCaller : Program := program do
  let loc ← constBytes [42] 1
  let cl ← addIntrinsic "caller_location"
  let inner ← addFn "inner" (body (refTo u8) [] (do
    call (.inst cl) [] (place 0)
    ret) (trackCaller := true))
  let outer ← addFn "outer" (body (refTo u8) [] (do
    call (.inst inner) [] (place 0) (callerLocation := some .inherit)
    ret) (trackCaller := true))
  addFn "main" <| body u8 [] do
    let r ← newLocal (refTo u8)
    storageLive r
    call (.inst outer) [] (place r) (callerLocation := some (.const (.ptr (.alloc loc) 0) (refTo u8)))
    assignL 0 (.use (copy ((place r).deref u8)))
    ret

/-- `rust-call`: the caller passes a tuple, the callee (`spread_arg`) gets it back. -/
def rustCall : Program := program do
  let pairTy := tuple [(0, u32), (4, u32)] 8 4
  let callee ← addFn "callee" (body u32 [u8, pairTy] (do
    assignL 0 (.binaryOp .add (copy ((place 2).field 0 u32)) (copy ((place 2).field 1 u32)))
    ret) (spread := true))
  addFn "main" <| body u32 [] do
    let t ← tmp pairTy (.aggregate .tuple [cint u32 40, cint u32 2])
    call (.inst callee) [cu8 0, t] (place 0)
    ret

/-! ### Tail calls, D25 -/

def tailFact : Program := program do
  let f ← declareFn "fact"
  defineFn f <| body u64 [u64, u64] do
    let z ← tmp .bool (.binaryOp .eq (copyL 1) (cint u64 0))
    ite z (do assignL 0 (.use (copyL 2)); ret) (do
      let n ← tmp u64 (.binaryOp .sub (copyL 1) (cint u64 1))
      let a ← tmp u64 (.binaryOp .mul (copyL 2) (copyL 1))
      term (.tailCall (.inst f) [n, a]))
    term .unreachable
  addFn "main" <| body u64 [] do
    call (.inst f) [cint u64 20, cint u64 1] (place 0)
    ret

def deepRecursion : Program := program do
  let f ← declareFn "f"
  defineFn f (body unit [] (do callUnit (.inst f) []; ret))
  addFn "main" <| body unit [] (do callUnit (.inst f) []; ret)

/-! ### D19: Drop, Assert -/

def dropProg (withGlue : Bool) : Program := program do
  let pr ← addExtern "ryo_test_print"
  let glue ← addFn "drop_in_place::<u32>" <| body unit [rawTo u32 true] do
    printI pr (copy ((place 1).deref u32))
    ret
  addFn "main" <| body unit [] do
    let x ← newLocal u32
    storageLive x
    assignL x (.use (cint u32 5))
    let next ← newBlock
    term (.drop (place x) (if withGlue then some glue else none) next .continue)
    setBlock next
    printI pr (cint u32 6)
    ret

def assertProg (cond : Bool) : Program := program do
  let pr ← addExtern "ryo_test_print"
  let abort ← addExtern "abort"
  let panicBounds ← addFn "panic_bounds_check" <| body neverTy [usize, usize] do
    printI pr (copyL 1)
    printI pr (copyL 2)
    callUnit (.inst abort) []
    term .unreachable
  addFn "main" <| body unit [] do
    let next ← newBlock
    term (.assert (cbool cond) true ⟨panicBounds, [cusize 7, cusize 3], none⟩ next .continue)
    setBlock next
    ret

/-! ### unwinding.rs, catch_unwind.rs (D18) -/

structure Rt where
  pr : InstanceId
  raise : InstanceId
  abort : InstanceId

def rt : ProgB Rt := do
  pure ⟨← addExtern "ryo_test_print", ← addExtern "_Unwind_RaiseException", ← addExtern "abort"⟩

/-- Start unwinding (call the external raise function). -/
def raise (r : Rt) (unwind : UnwindAction) : FnB Unit := do
  callUnit (.inst r.raise) [cptr bytePtrTy 0] unwind
  term .unreachable

def panicFn (r : Rt) : ProgB InstanceId := addFn "panic" (body unit [] (raise r .continue))

/-- MiniRust `reach_terminate_block`: unwinding again inside a cleanup block terminates. -/
def reachTerminate (withLangItem : Bool) : Program := program do
  let r ← rt
  let p ← panicFn r
  let inCleanup ← addFn "panic_in_cleanup" <| body neverTy [] do
    printI r.pr (ci32 99)
    callUnit (.inst r.abort) []
    term .unreachable
  if withLangItem then
    modify fun s => { s with langItems := { panicInCleanup := some inCleanup } }
  addFn "main" <| body unit [] do
    let cleanup ← cleanupBlock do
      callUnit (.inst p) [] (unwind := .terminate .inCleanup)
      term .unwindResume
    callUnit (.inst p) [] (unwind := .cleanup cleanup)
    ret

def abortInCleanup : Program := program do
  let r ← rt
  addFn "main" <| body unit [] do
    let cleanup ← cleanupBlock do
      callUnit (.inst r.abort) [] (unwind := .unreachable)
      term .unreachable
    raise r (.cleanup cleanup)

/-- MiniRust `unwind_recursive_func`: prints on the way down and in the cleanups. -/
def unwindRecursive : Program := program do
  let r ← rt
  let f ← declareFn "rec"
  defineFn f <| body unit [i32] do
    let resume ← cleanupBlock (term .unwindResume)
    let printBlk ← cleanupBlock do
      printI r.pr (copyL 1)
      term (.goto resume)
    printI r.pr (copyL 1)
    let z ← tmp .bool (.binaryOp .eq (copyL 1) (ci32 0))
    ite z (raise r (.cleanup resume)) (do
      let n ← tmp i32 (.binaryOp .sub (copyL 1) (ci32 1))
      callUnit (.inst f) [n] (unwind := .cleanup printBlk)
      ret)
    ret
  addFn "main" <| body unit [] do
    let cleanup ← cleanupBlock do
      callUnit (.inst r.abort) [] (unwind := .unreachable)
      term .unreachable
    let _ := cleanup
    let done ← cleanupBlock (term .unwindResume)
    callUnit (.inst f) [ci32 6] (unwind := .cleanup done)
    ret

def statementsInCleanup : Program := program do
  let r ← rt
  let f ← addFn "f" <| body unit [i32] do
    let v ← newLocal i32
    let cleanup ← cleanupBlock do
      assignL v (.binaryOp .addUnchecked (copyL 1) (ci32 3))
      assignL v (.binaryOp .mulUnchecked (copyL v) (copyL 1))
      assignL v (.binaryOp .shlUnchecked (copyL v) (ci32 2))
      printI r.pr (copyL v)
      term .unwindResume
    storageLive v
    raise r (.cleanup cleanup)
  addFn "main" <| body unit [] do
    let cleanup ← cleanupBlock (callUnit (.inst r.abort) [] (unwind := .unreachable))
    callUnit (.inst f) [ci32 10] (unwind := .cleanup cleanup)
    ret

def printAfterUnwind : Program := program do
  let r ← rt
  let p ← panicFn r
  addFn "main" <| body unit [] do
    let cleanup ← cleanupBlock (callUnit (.inst r.abort) [] (unwind := .unreachable))
    printI r.pr (ci32 1)
    callUnit (.inst p) [] (unwind := .cleanup cleanup)
    printI r.pr (ci32 2)
    ret

/-- MiniRust `resume_no_unwind_block`: unwinding into `UnwindAction::Unreachable` is UB. -/
def unwindIntoUnreachable : Program := program do
  let r ← rt
  let p ← panicFn r
  addFn "main" <| body unit [] do
    callUnit (.inst p) [] (unwind := .unreachable)
    ret

/-- Unwinding out of `main` ends the run (MiniRust: UB at the bottom of the stack). -/
def unwindOutOfMain : Program := program do
  let r ← rt
  let p ← panicFn r
  addFn "main" <| body unit [] (do callUnit (.inst p) []; ret)

def catchUnwind (panics : Bool) : Program := program do
  let r ← rt
  let ci ← addIntrinsic "catch_unwind"
  let tryFn ← addFn "try" <| body unit [bytePtrTy] do
    printI r.pr (ci32 2)
    if panics then raise r .continue else ret
  let catchFn ← addFn "catch" <| body unit [bytePtrTy, bytePtrTy] do
    printI r.pr (ci32 3)
    ret
  addFn "main" <| body i32 [] do
    printI r.pr (ci32 1)
    call (.inst ci) [cfnPtr tryFn, cptr bytePtrTy 0, cfnPtr catchFn] (place 0)
    printI r.pr (copyL 0)
    ret

def tests : List TestCase := [
  ⟨"call/success", fun _ => expectReturn (callProg unit [unit] [cunit] unit)⟩,
  ⟨"call/arg_count", fun _ => expectUb (callProg unit [unit] [] unit)
    "call ABI violation: number of arguments does not agree"⟩,
  ⟨"call/arg_abi", fun _ => expectUb (callProg unit [unit] [ci32 42] unit)
    "call ABI violation: argument types are not compatible"⟩,
  ⟨"call/ret_abi", fun _ => expectUb (callProg unit [unit] [cunit] i32)
    "call ABI violation: return types are not compatible"⟩,
  ⟨"call/ret_mismatch", fun _ => expectUb retMismatch
    "call ABI violation: return types are not compatible"⟩,
  ⟨"return/success", fun _ => expectReturn (callProg unit [] [] unit)⟩,
  ⟨"return/no_next", fun _ => expectUb (callProg unit [] [] unit (target := false))
    "return from a function where the caller did not specify a next block"⟩,
  ⟨"abi/signedness (D14)", fun _ => expectUb (abiCompat u32 i32 (cint u32 1))
    "argument types are not compatible"⟩,
  ⟨"abi/transparent_wrapper (D14)", fun _ =>
    expectReturn (abiCompat wrapperI32 i32 (.const (.scalar 5) wrapperI32))⟩,
  ⟨"abi/option_ref_as_ptr (D14)", fun _ => expectReturn optRefToPtr⟩,
  ⟨"abi/char_u32 (D14)", fun _ => expectReturn (abiCompat .char u32 (.const (.scalar 65) .char))⟩,
  ⟨"validate/entry (D15)", fun _ => expectUb entryValidation "violates the language invariant"⟩,
  ⟨"validate/return (D15)", fun _ => expectUb returnValidation "violates the language invariant"⟩,
  ⟨"in_place/aliases (D12)", fun _ => expectReturnValue inPlaceAliases (.bool true)⟩,
  ⟨"in_place/moved_is_uninit (D12)", fun _ =>
    expectUb movedIsUninit "violates the language invariant"⟩,
  ⟨"in_place/copied_is_kept (D12)", fun _ => expectReturn copiedIsKept⟩,
  ⟨"in_place/dest_deinit (D12)", fun _ => expectUb destDeinit "violates the language invariant"⟩,
  ⟨"track_caller (D14)", fun _ => expectReturnValue trackCaller (.int 42)⟩,
  ⟨"rust_call (D14)", fun _ => expectReturnValue rustCall (.int 42)⟩,
  ⟨"tail_call", fun _ => expectReturnValue tailFact (.int 2432902008176640000)⟩,
  ⟨"stack_overflow (D25)", fun _ =>
    match (run deepRecursion).result with
    | .error .stackOverflow => .ok ()
    | r => .error s!"expected stack overflow, got {repr r}"⟩,
  ⟨"drop/glue (D19)", fun _ => expectPrinted (dropProg true) [5, 6]⟩,
  ⟨"drop/no_glue (D19)", fun _ => expectPrinted (dropProg false) [6]⟩,
  ⟨"assert/ok (D19)", fun _ => expectReturn (assertProg true)⟩,
  ⟨"assert/fails (D19)", fun _ =>
    expectPrinted (assertProg false) [7, 3] (fun r => r.result matches .error .abort)⟩,
  ⟨"unwinding/reach_terminate (D18)", fun _ =>
    expectPrinted (reachTerminate true) [99] (fun r => r.result matches .error .abort)⟩,
  ⟨"unwinding/terminate_without_lang_item (D18)", fun _ => expectAbort (reachTerminate false)⟩,
  ⟨"unwinding/abort_in_cleanup", fun _ => expectAbort abortInCleanup⟩,
  ⟨"unwinding/recursive", fun _ =>
    expectPrinted unwindRecursive [6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6]
      (fun r => r.result matches .ok (.unwound _))⟩,
  ⟨"unwinding/statements_in_cleanup", fun _ =>
    expectPrinted statementsInCleanup [520] (fun r => r.result matches .error .abort)⟩,
  ⟨"unwinding/print_after_unwind", fun _ =>
    expectPrinted printAfterUnwind [1] (fun r => r.result matches .error .abort)⟩,
  ⟨"unwinding/into_unreachable (D18)", fun _ =>
    expectUb unwindIntoUnreachable "unwind action is `Unreachable`"⟩,
  ⟨"unwinding/out_of_main (D18)", fun _ => expectUnwound unwindOutOfMain⟩,
  ⟨"catch_unwind/catch", fun _ =>
    expectPrinted (catchUnwind true) [1, 2, 3, 1] (fun r => r.result matches .ok (.returned _))⟩,
  ⟨"catch_unwind/no_unwind", fun _ =>
    expectPrinted (catchUnwind false) [1, 2, 0] (fun r => r.result matches .ok (.returned _))⟩
]

end RyoTest.Call
