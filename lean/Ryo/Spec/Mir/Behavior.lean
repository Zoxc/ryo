/-
Ryo.Spec.Mir.Behavior — program behaviors and refinement (stated; proofs come later).

Ports: none (MiniRust leaves `Nondet` abstract). Implements mir-spec §A.4:
- a run is the semantics executed with an oracle; the oracle answers every choice;
- behaviors quantify over oracles. A UB outcome counts only if, for the same daemonic
  answers, every angelic alternative also goes wrong (MiniRust's `predict`);
- runs that end in `noBehavior` (a daemonic answer violated its constraint), `illFormed` or out
  of fuel are not behaviors;
- `Refines tgt src`: every target behavior is a source behavior, or the source goes wrong
  after a prefix of the target's trace, or (D25) the target overflows its stack after a prefix
  of some source behavior's trace.

The environment (mir-spec §A.6) is, for now, the interpreter's shims (`Ryo.Spec.Mir.External`); the
relational `ExtSpec` below is stated but not yet plugged into the semantics.
-/
import Ryo.Spec.Mir.Interp

namespace Ryo.Spec

/-- Two oracles that give the same daemonic answers (they may differ on angelic ones). -/
def Oracle.sameDaemonic (o1 o2 : Oracle) : Prop :=
  ∀ n c s, c.kind = .daemonic → o1.answer n c s = o2.answer n c s

inductive Behavior where
  | terminates (trace : List Event) (final : Final)
  | exits (trace : List Event) (code : Int)
  | aborts (trace : List Event)
  | goesWrong (trace : List Event) (msg : String)
  /-- D25 (only targets have it: sources run with an unbounded stack). -/
  | stackOverflow (trace : List Event)
  /-- A run that never ends; `traceAt n` is the trace after `n` steps. -/
  | diverges (traceAt : Nat → List Event)

/-- The behavior a finished run shows, if it is one. -/
def RunResult.behavior? (r : RunResult) : Option Behavior :=
  let tr := r.events.toList
  match r.result with
  | .ok f => some (.terminates tr f)
  | .error (.exit c) => some (.exits tr c)
  | .error .abort => some (.aborts tr)
  | .error (.ub m) => some (.goesWrong tr m)
  | .error .stackOverflow => some (.stackOverflow tr)
  | .error (.illFormed _) | .error (.noBehavior _) | .error .outOfFuel => none

/-- Run with `n` steps of fuel and a stack that cannot overflow within them. -/
def runN (o : Oracle) (p : Program) (args : List (Value × Ty)) (n : Nat) : RunResult :=
  runWith o p args n (maxDepth := n + 1)

/-- With oracle `o`, the program shows behavior `b`. -/
def RunsTo (p : Program) (args : List (Value × Ty)) (o : Oracle) : Behavior → Prop
  | .diverges tr => ∀ n, (runN o p args n).result = .error .outOfFuel ∧
      (runN o p args n).events.toList = tr n
  | b => ∃ n, ∃ b', (runN o p args n).behavior? = some b' ∧ sameShape b' b
where
  /-- `Behavior` has no decidable equality (`diverges` holds a function); compare the finite
  ones structurally. -/
  sameShape : Behavior → Behavior → Prop
    | .terminates t f, .terminates t' f' => t = t' ∧ f = f'
    | .exits t c, .exits t' c' => t = t' ∧ c = c'
    | .aborts t, .aborts t' => t = t'
    | .goesWrong t m, .goesWrong t' m' => t = t' ∧ m = m'
    | .stackOverflow t, .stackOverflow t' => t = t'
    | _, _ => False

def Behavior.isGoesWrong : Behavior → Bool
  | .goesWrong .. => true
  | _ => false

/-- The behaviors of a program (mir-spec §A.4): UB only counts if no angelic choice avoids it. -/
def Behaviors (p : Program) (args : List (Value × Ty)) (b : Behavior) : Prop :=
  ∃ o, RunsTo p args o b ∧
    (b.isGoesWrong → ∀ o', o'.sameDaemonic o → ∃ tr m, RunsTo p args o' (.goesWrong tr m))

/-- `tr` is a prefix of the behavior's trace. -/
def Behavior.hasPrefix (tr : List Event) : Behavior → Prop
  | .terminates t _ | .exits t _ | .aborts t | .goesWrong t _ | .stackOverflow t => tr <+: t
  | .diverges t => ∃ n, tr <+: t n

-- [D25]
/-- Refinement (mir-spec §A.4, D25). -/
def Refines (tgt src : Program) (args : List (Value × Ty)) : Prop :=
  ∀ b, Behaviors tgt args b →
    Behaviors src args b ∨
    (∃ tr m, Behaviors src args (.goesWrong tr m) ∧ b.hasPrefix tr) ∨
    (∃ tr, (match b with | .stackOverflow t => t = tr | _ => False) ∧
      ∃ b', Behaviors src args b' ∧ b'.hasPrefix tr)

/-- The environment's contract for an external call (mir-spec §A.6), as CompCert's `extcall`
properties: memory the callee cannot reach is unchanged, it frees only reachable heap
allocations, it may allocate. Stated for the dumper/checker milestones; the current
semantics uses the interpreter's shims. -/
structure ExtSpec where
  /-- `allowed callee args memBefore memAfter result`. -/
  allowed : String → List Value → Memory → Memory → ExtResult → Prop
  /-- Allocations reachable by the callee: through the pointer arguments, exposed
  allocations, globals, transitively through memory. -/
  reachable : List Value → Memory → AllocId → Prop
  /-- Unreachable allocations keep their contents and liveness. -/
  unreachableUnchanged : ∀ f args m m' r, allowed f args m m' r →
    ∀ id, ¬ reachable args m id →
      (m.get? id).map (fun a => (a.data.toList, a.live)) =
        (m'.get? id).map (fun a => (a.data.toList, a.live))
  /-- Only reachable heap allocations are freed. -/
  freesOnlyReachableHeap : ∀ f args m m' r, allowed f args m m' r →
    ∀ id a a', m.get? id = some a → m'.get? id = some a' → a.live → !a'.live →
      reachable args m id ∧ a.kind = .heap

end Ryo.Spec
