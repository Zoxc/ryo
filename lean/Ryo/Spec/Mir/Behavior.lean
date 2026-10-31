/-
Ryo.Spec.Mir.Behavior — program behaviors and refinement (stated; proofs come later).

Ports: none (MiniRust leaves `Nondet` abstract). Implements mir-spec §A.4:
- a run is the semantics executed with an oracle; the oracle answers every choice;
- behaviors quantify over oracles. A UB outcome counts only if, for the same daemonic
  answers, every angelic alternative also goes wrong (MiniRust's `predict`);
- runs that end in `noBehavior` (a daemonic answer violated its constraint), `illFormed` or out
  of fuel are not behaviors;
- `Refines tgt src`: every target behavior is a source behavior (diverging ones up to
  stuttering, `Behavior.equiv`: the same limit trace, whatever step each event comes at), or
  the source goes wrong after a prefix of the target's trace, or (D25) the target overflows
  its stack after a prefix of some source behavior's trace.

The environment (mir-spec §A.6): external calls not covered by the shims
(`Ryo.Spec.Mir.External`) are run by the oracle (`Oracle.env`). Behaviors and refinement are
relative to an `ExtSpec`, CompCert's `extcall` contract: only oracles whose environment
`respects` it count. Within one program the environment is not angelic: `sameDaemonic`
oracles share it. `ExtSpec.none` allows no environment call, leaving the shims only (the
interpreter's view).

Known limits of `Refines` (no proof uses it yet):
- The source picks its own oracle, environment included, and traces record an external
  call's arguments and result but not the memory it writes. So for an `ExtSpec` other than
  `none`, a target that ignores what a callee wrote refines a source that reads it: matching
  the two programs' environments needs more than `Oracle.env`, which is indexed by the
  choice count (daemonic choices included).
- Values in behaviors carry provenance as allocation indices (`Memory.allocate`), compared
  exactly: a target that makes more or fewer allocations before a pointer reaches an event
  or the result doesn't refine its source (CompCert compares up to a memory injection).
-/
import Ryo.Spec.Mir.Interp

namespace Ryo.Spec

/-- The environment's contract for an external call (mir-spec §A.6), as CompCert's `extcall`
properties: memory the callee cannot reach is unchanged, it frees only reachable heap
allocations, it may allocate, and existing allocations stay where and what they are. -/
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
  /-- Allocations are never removed (only marked dead; new ones are appended) and keep their
  address, kind, size, alignment and mutability; read-only ones (D7: constants, vtables,
  immutable statics) keep their contents. -/
  keepsAllocs : ∀ f args m m' r, allowed f args m m' r →
    ∀ id a, m.get? id = some a → ∃ a', m'.get? id = some a' ∧ a'.addr = a.addr ∧
      a'.kind = a.kind ∧ a'.size = a.size ∧ a'.align = a.align ∧ a'.mutable = a.mutable ∧
      (a.mutable = false → a'.data = a.data)

/-- The environment that runs nothing: external calls are the shims' only, as in the
interpreter (`concreteOracle`). -/
def ExtSpec.none : ExtSpec where
  allowed := fun _ _ _ _ _ => False
  reachable := fun _ _ _ => False
  unreachableUnchanged := fun _ _ _ _ _ h => h.elim
  freesOnlyReachableHeap := fun _ _ _ _ _ h => h.elim
  keepsAllocs := fun _ _ _ _ _ h => h.elim

/-- Every environment answer of `o` is one `spec` allows. -/
def Oracle.respects (spec : ExtSpec) (o : Oracle) : Prop :=
  ∀ n f args s m' r, o.env n f args s = some (m', r) → spec.allowed f args s.mem m' r

/-- Two oracles that give the same daemonic answers (they may differ on angelic ones) and
have the same environment. -/
def Oracle.sameDaemonic (o1 o2 : Oracle) : Prop :=
  (∀ n c s, c.kind = .daemonic → o1.answer n c s = o2.answer n c s) ∧ o1.env = o2.env

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

/-- The same behavior up to stuttering: finite ones as `RunsTo.sameShape` compares them,
diverging ones with the same limit trace (each one's traces are prefixes of the other's). -/
def Behavior.equiv : Behavior → Behavior → Prop
  | .diverges t, .diverges s => (∀ n, ∃ m, t n <+: s m) ∧ (∀ m, ∃ n, s m <+: t n)
  | b, b' => RunsTo.sameShape b b'

def Behavior.isGoesWrong : Behavior → Bool
  | .goesWrong .. => true
  | _ => false

/-- The behaviors of a program in environments allowed by `spec` (mir-spec §A.4, §A.6): UB
only counts if no angelic choice avoids it. An alternative whose run has no behavior (it
ends in `noBehavior`: an invalid angelic answer, such as an `exposedProv` allocation that was
never exposed, which MiniRust's `predict` never gives) avoids nothing. `Behaviors .none` are
the shim-only behaviors. -/
def Behaviors (spec : ExtSpec) (p : Program) (args : List (Value × Ty)) (b : Behavior) : Prop :=
  ∃ o, o.respects spec ∧ RunsTo p args o b ∧
    (b.isGoesWrong → ∀ o', o'.sameDaemonic o →
      (∃ tr m, RunsTo p args o' (.goesWrong tr m)) ∨
      ∃ n msg, (runN o' p args n).result = .error (.noBehavior msg))

/-- `tr` is a prefix of the behavior's trace. -/
def Behavior.hasPrefix (tr : List Event) : Behavior → Prop
  | .terminates t _ | .exits t _ | .aborts t | .goesWrong t _ | .stackOverflow t => tr <+: t
  | .diverges t => ∃ n, tr <+: t n

-- [D25]
/-- Refinement in environments allowed by `spec` (mir-spec §A.4, D25). -/
def Refines (spec : ExtSpec) (tgt src : Program) (args : List (Value × Ty)) : Prop :=
  ∀ b, Behaviors spec tgt args b →
    (∃ b', Behaviors spec src args b' ∧ b'.equiv b) ∨
    (∃ tr m, Behaviors spec src args (.goesWrong tr m) ∧ b.hasPrefix tr) ∨
    (∃ tr, (match b with | .stackOverflow t => t = tr | _ => False) ∧
      ∃ b', Behaviors spec src args b' ∧ b'.hasPrefix tr)

end Ryo.Spec
