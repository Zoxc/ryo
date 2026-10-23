/-
Ryo.Spec.Mir.Unwind — returning to and unwinding into callers.

Ports: replaces MiniRust `lang/step/terminators.md` § unwinding (`StartUnwind`, `StopUnwind`,
`ResumeUnwind`, the payload stack) and the stack-pop part of § Return.

D18: MIR unwinding. Unwinding starts only in callees (the panic runtime is external,
mir-spec §A.6): a call ends with `ret v` or `unwind payload`. In the caller the call's
`UnwindAction` decides:
- `Continue`: the caller unwinds too (its frame is popped by the next step);
- `Cleanup bb`: run cleanup block `bb` in unwinding mode (the frame remembers the payload, and
  `UnwindResume` continues unwinding with it);
- `Unreachable`: UB;
- `Terminate reason`: call the reason's lang item (`panic_cannot_unwind`/`panic_in_cleanup`),
  which must not return or unwind (either aborts); without the lang item: abort.
`catch_unwind(try, data, catch)` calls `try(data)`; if it unwinds, `catch(data, payload)` is
called; the intrinsic returns 0, or 1 after a caught unwind (rustc `codegen_gnu_try`).
Unwinding out of the bottom frame ends the run with `Final.unwound`.
-/
import Ryo.Spec.Mir.Call

namespace Ryo.Spec.Sem

open SemM

def deinitPlaces (ps : List (ThinPointer × Size)) : SemM Unit := do
  for (p, sz) in ps do
    memUpdate (·.deinit p sz .one)

def jumpOrUb (target : Option BasicBlock) : SemM Unit :=
  match target with
  | some bb => jumpTo bb
  | none => throwUb "return from a function where the caller did not specify a next block"

/-- After the callee is gone: continue the caller for a normal return. -/
def contReturn : Cont → SemM Unit
  | .bottom => throwIllFormed "return to the bottom continuation"
  | .caller target _ deinit => do
    deinitPlaces deinit
    jumpOrUb target
  | .terminate => throw .abort
  | .catchTry _ _ dest destTy target _ => do
    placeStore dest (.int 0) destTy
    jumpOrUb target
  | .catchHandler dest destTy target _ => do
    placeStore dest (.int 1) destTy
    jumpOrUb target

/-- Call a terminate lang item (D18), or abort without one. -/
def callTerminate (r : TerminateReason) : SemM Unit := do
  let p ← prog
  let item := match r with
    | .abi => p.langItems.panicCannotUnwind
    | .inCleanup => p.langItems.panicInCleanup
  match item with
  | some i =>
    match p.body? i with
    | some b => callBody i b .terminate [] none none none
    | none => throw .abort
  | none => throw .abort

-- [D18]
/-- Apply a call's unwind action in the active (calling) frame. -/
def applyUnwindAction (a : UnwindAction) (payload : Payload) : SemM Unit :=
  match a with
  | .continue => modifyCurFrame fun f => { f with pendingUnwind := some payload }
  | .cleanup bb => do
    modifyCurFrame fun f => { f with unwinding := some payload }
    jumpTo bb
  | .unreachable => throwUb "unwinding out of a call whose unwind action is `Unreachable`"
  | .terminate r => callTerminate r

-- [D18]
/-- After the callee is gone: continue the caller for an unwind. -/
def contUnwind (c : Cont) (payload : Payload) : SemM Unit := do
  match c with
  | .bottom => modify fun s => { s with final := some (.unwound payload) }
  | .caller _ unwind deinit => do
    deinitPlaces deinit
    applyUnwindAction unwind payload
  | .terminate => throw .abort
  | .catchTry data catchFn dest destTy target unwind => do
    let .ptr fp := catchFn | throwIllFormed "catch_unwind: catch function is not a pointer"
    let i ← instOfFnPtr fp
    let some b := (← prog).body? i | throwIllFormed "catch_unwind: catch function has no body"
    let argTy (l : Local) : Ty := b.locals[l]?.getD bytePtrTy
    callBody i b (.catchHandler dest destTy target unwind)
      [⟨data, argTy 1, none⟩, ⟨.ptr payload.widen, argTy 2, none⟩] none none none
  | .catchHandler _ _ _ unwind => applyUnwindAction unwind payload

/-- Unwind out of the active frame: pop it and continue in its caller. -/
def unwindOut (payload : Payload) : SemM Unit := do
  let f ← popFrame
  contUnwind f.cont payload

end Ryo.Spec.Sem
