/-
Ryo.Spec.Mir.Interp — the interpreter: the semantics run with a concrete oracle.

Ports: MiniRust's `minirun` (`tooling/minirust-rs` driver loop), with the concrete oracle of
mir-spec §A.4:
- allocation addresses: a bump allocator above every allocation made so far, respecting
  alignment (so no overlap; D8 zero-size allocations get addresses too);
- exposed provenance (angelic, D11): the live exposed allocation containing the address, as
  Miri does (preferring one where the address is not one-past-the-end);
- NaN payloads (D5): the preferred positive quiet NaN;
- constant copies (D7) and function addresses (D6): always the first copy;
- `ptr_guaranteed_cmp` (D20): the exact answer.
Any run this produces without UB is a behavior of the program (the oracle answers within
every constraint); a reported UB can be spurious for programs that cast integers to pointers
(as with Miri).
-/
import Ryo.Spec.Mir.Step
import Ryo.Spec.Mir.WellFormed

namespace Ryo.Spec

/-- The lowest address the bump allocator hands out. -/
def bumpBase : Nat := 0x10000

/-- The concrete oracle. -/
def concreteOracle : Oracle where
  answer := fun _ c s =>
    match c with
    | .allocAddr _ align =>
      let top := s.mem.allocs.foldl (fun acc a => max acc (a.addr + a.size + 1)) bumpBase
      (alignTo top align : Nat)
    | .exposedProv addr =>
      let cands := s.intptr.exposed.filter fun id =>
        match s.mem.get? id with
        | some a => a.live && a.containsAddr addr
        | none => false
      let inner := cands.filter fun id =>
        match s.mem.get? id with
        | some a => addr < a.addr + a.size
        | none => false
      (inner.head? <|> cands.head? : Option AllocId)
    | .nanBits _ cands => (cands.head?.getD 0 : Nat)
    | .constCopy .. => (0 : Nat)
    | .fnAddr .. => (0 : Nat)
    | .guaranteedCmp => true

structure RunResult where
  /-- `.ok final` for a normal end, `.error o` for UB, abort, exit, ill-formedness, ... -/
  result : Except Outcome Final
  events : Array Event
  steps : Nat
  state : State

/-- Run one `SemM` action on a state. -/
def SemM.runOn {α : Type} (m : SemM α) (o : Oracle) (s : State) : Except Outcome α × State :=
  (m.run.run s).run o

/-- Run the program for at most `fuel` steps. -/
def runWith (o : Oracle) (prog : Program) (args : List (Value × Ty) := []) (fuel : Nat := 1000000)
    (maxDepth : Nat := 10000) : RunResult := Id.run do
  if let .error e := Wf.checkProgram prog then
    return ⟨.error (.illFormed e), #[], 0, { prog, maxDepth }⟩
  let (r, s) := (Sem.start args).runOn o { prog, maxDepth }
  if let .error e := r then return ⟨.error e, s.events, 0, s⟩
  let mut s := s
  let mut n := 0
  for _ in [0:fuel] do
    if let some f := s.final then return ⟨.ok f, s.events, n, s⟩
    let (r, s') := Sem.step.runOn o s
    s := s'
    n := n + 1
    if let .error e := r then return ⟨.error e, s.events, n, s⟩
  match s.final with
  | some f => pure ⟨.ok f, s.events, n, s⟩
  | none => pure ⟨.error .outOfFuel, s.events, n, s⟩

/-- `run` with the concrete oracle. -/
def run (prog : Program) (args : List (Value × Ty) := []) (fuel : Nat := 1000000) : RunResult :=
  runWith concreteOracle prog args fuel

end Ryo.Spec
