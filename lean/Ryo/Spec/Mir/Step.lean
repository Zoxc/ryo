/-
Ryo.Spec.Mir.Step — the transition function and the initial state.

Ports: MiniRust `lang/machine.md` (`Machine::new`, `Machine::step`, `new_thread`).

Differences:
- D17: one thread, no scheduling choice.
- D7: globals are not all allocated up front; statics get their (unique) allocation on first
  use and constants a copy per evaluation (`Ryo.Spec.Mir.Operand`). Since allocation
  addresses are daemonic choices either way, this does not change the set of behaviors.
- D18: a frame with a pending unwind (its callee unwound with `UnwindAction::Continue`) is
  popped by the next step.
- The start function is called with the given arguments (by value) and its return value (or
  unwinding payload) ends the run (`State.final`); MiniRust instead requires the start
  function to call `exit`.
-/
import Ryo.Spec.Mir.Terminator

namespace Ryo.Spec.Sem

open SemM

-- [D18]
/-- One step: a statement, a terminator, or unwinding out of a frame. -/
def step : SemM Unit := do
  if (← get).final.isSome then throwIllFormed "step after the end of the run"
  let f ← curFrame
  if let some p := f.pendingUnwind then
    unwindOut p
  else
    let some bd := f.body.blocks[f.bb]? | throwIllFormed s!"basic block bb{f.bb} out of range"
    match bd.stmts[f.stmt]? with
    | some st => do
      evalStatement st
      modifyCurFrame fun f => { f with stmt := f.stmt + 1 }
    | none => evalTerminator bd.term

/-- Set up the initial state: a frame for the start function with the given arguments. -/
def start (args : List (Value × Ty)) : SemM Unit := do
  let p ← prog
  let some b := p.body? p.start | throwIllFormed "the start instance has no body"
  callBody p.start b .bottom (args.map fun (v, t) => ⟨v, t, none⟩) none none b.abi

end Ryo.Spec.Sem
