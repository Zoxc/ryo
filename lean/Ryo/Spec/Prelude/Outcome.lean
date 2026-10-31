/-
Ryo.Spec.Prelude.Outcome — how an execution stops abnormally.

Ports: MiniRust `prelude/main.md` (`TerminationInfo`).

Differences: no `Deadlock` (single thread, D17) and no `MemoryLeak` (leaks are not checked:
the heap is external, D21). `MachineStop` is `exit code` (the `exit` shim, mir-spec §A.6).
Added:
- `noBehavior`: a choice was answered outside its constraint (mir-spec §A.4): a daemonic
  one, or an invalid angelic answer (`exposedProv`), which `Behaviors` doesn't count as
  avoiding UB; not a program behavior.
- `stackOverflow` (D25).
- `outOfFuel`: interpreter-only; not part of the semantics.
-/
import Ryo.Spec.Prelude.Basic

namespace Ryo.Spec

inductive Outcome where
  /-- Undefined behavior. -/
  | ub (msg : String)
  /-- The program aborted (`abort` intrinsic/shim, failed unwind termination). -/
  | abort
  /-- The program called `exit`. -/
  | exit (code : Int)
  /-- The program (or its dump) is ill-formed, or the spec hit a case it rules out. -/
  | illFormed (msg : String)
  /-- A choice (daemonic, or angelic `exposedProv`) was answered outside its constraint. -/
  | noBehavior (msg : String)
  /-- The stack overflowed (D25). -/
  | stackOverflow
  /-- The interpreter ran out of fuel (not a behavior). -/
  | outOfFuel
deriving Repr, BEq, Inhabited

instance : ToString Outcome where
  toString
    | .ub m => s!"UB: {m}"
    | .abort => "abort"
    | .exit c => s!"exit({c})"
    | .illFormed m => s!"ill-formed: {m}"
    | .noBehavior m => s!"no behavior: {m}"
    | .stackOverflow => "stack overflow"
    | .outOfFuel => "out of fuel"

def Outcome.isUb : Outcome → Bool
  | .ub _ => true
  | _ => false

/-- Throw UB. -/
def throwUb {m : Type → Type} {α : Type} [MonadExceptOf Outcome m] (msg : String) : m α :=
  throwThe Outcome (.ub msg)

def throwIllFormed {m : Type → Type} {α : Type} [MonadExceptOf Outcome m] (msg : String) : m α :=
  throwThe Outcome (.illFormed msg)

/-- `ensure_else_ub`. -/
def ensureUb {m : Type → Type} [Monad m] [MonadExceptOf Outcome m] (b : Bool) (msg : String) :
    m Unit :=
  if b then pure () else throwUb msg

end Ryo.Spec
