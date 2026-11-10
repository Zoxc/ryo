/-
Ryo.Spec.Mir.Step — the transition function and the initial state.

Ports: MiniRust `lang/machine.md` (`Machine::new`, `Machine::step`, `new_thread`).

Differences:
- D17: one thread, no scheduling choice.
- D7: constants and vtables get one copy each up front (`instantiateConsts`, as
  `Machine::new` allocates globals), and each evaluation may still pick another copy
  (`Ryo.Spec.Mir.Operand`); statics get their (unique) allocation on first use. Since
  allocation addresses are daemonic choices either way, this does not change the set of
  behaviors.
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

-- [D7]
/-- One copy of each constant and vtable allocation, made before the start function runs (a
global that a relocation of an earlier one reaches has its copy already). A copy exists for
every such global from then on, so a lowering may use it for every evaluation. -/
def instantiateConsts : SemM Unit := do
  let p ← prog
  for g in List.range p.globals.size do
    match p.globals[g]? with
    | some gl =>
      if gl.kind matches .const | .vtable _ then
        if ((← get).constCopies.getD g []).isEmpty then
          let _ ← globalPtr g
          pure ()
    | none => pure ()

/-- Set up the initial state: the constants' copies (D7), then a frame for the start function
with the given arguments. -/
def start (args : List (Value × Ty)) : SemM Unit := do
  instantiateConsts
  let p ← prog
  let some b := p.body? p.start | throwIllFormed "the start instance has no body"
  callBody p.start b .bottom (args.map fun (v, t) => ⟨v, t, none⟩) none none b.abi

end Ryo.Spec.Sem
