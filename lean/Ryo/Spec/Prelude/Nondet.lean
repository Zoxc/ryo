/-
Ryo.Spec.Prelude.Nondet — non-determinism through an oracle (mir-spec §A.4).

Ports: MiniRust `prelude/main.md` (`Nondet`, `pick`, `predict`, `NdResult`).

MiniRust leaves its non-determinism monad opaque and uses `pick` (daemonic) and `predict`
(angelic). Here every choice point is a `Choice` request answered through `MonadChoice`. The
semantics *checks* each answer: a daemonic answer violating its constraint yields
`Outcome.noBehavior`. The same code is
- an interpreter, when the oracle is the concrete one in `Ryo.Spec.Mir.Interp`, and
- a semantics, by quantifying over oracles (`Ryo.Spec.Mir.Behavior`).

Choices added by divergences: NaN payloads (D5), copies of constant allocations (D7), function
addresses (D6), `ptr_guaranteed_cmp` (D20); and where Rust leaves a result open: whether
`fmuladd` fuses, the sign of a zero from `minimum_number_nsz`/`maximum_number_nsz`, the
magnitude of `compare_bytes`.
-/
import Ryo.Spec.Prelude.Basic
import Ryo.Spec.Prelude.Outcome

namespace Ryo.Spec

inductive ChoiceKind where
  | daemonic
  | angelic
deriving DecidableEq, Repr

/-- A choice point: what is asked. The semantics checks the answer. -/
inductive Choice where
  /-- Address of a new allocation (daemonic; checked by `Memory.allocate`). -/
  | allocAddr (size : Size) (align : Align)
  /-- Provenance for an integer-to-pointer cast at `addr` (angelic; answer must be `none` or an
  exposed allocation). -/
  | exposedProv (addr : Nat)
  /-- Bits of a NaN result (D5, daemonic; answer must be one of `candidates`). -/
  | nanBits (fmt : FloatTy) (candidates : List Nat)
  /-- Which copy of constant allocation `g` an evaluation uses (D7, daemonic). An answer
  `< existing` reuses that copy, anything else makes a fresh copy. -/
  | constCopy (g : GlobalId) (existing : Nat)
  /-- Which copy of function `i`'s address a reification uses (D6, daemonic), as `constCopy`. -/
  | fnAddr (i : InstanceId) (existing : Nat)
  /-- `ptr_guaranteed_cmp` (D20, daemonic): `true` = answer exactly, `false` = answer 2. -/
  | guaranteedCmp
  /-- `fmuladd` (daemonic): `true` = fused (one rounding), `false` = multiply then add. -/
  | fmulAddFused
  /-- `minimum_number_nsz`/`maximum_number_nsz` of two zeros of different sign (daemonic):
  `false` = the first operand, `true` = the second. -/
  | nszZero
  /-- The result of `compare_bytes` (daemonic, `memcmp`): any `i32` with the sign of `diff`,
  the difference of the first differing bytes (0 if equal). -/
  | compareBytes (diff : Int)
deriving Repr, BEq, Inhabited

def Choice.kind : Choice → ChoiceKind
  | .exposedProv _ => .angelic
  | _ => .daemonic

/-- The type of answers for each kind of choice. -/
@[reducible] def Choice.Answer : Choice → Type
  | .allocAddr .. => Nat
  | .exposedProv _ => Option AllocId
  | .nanBits .. => Nat
  | .constCopy .. => Nat
  | .fnAddr .. => Nat
  | .guaranteedCmp => Bool
  | .fmulAddFused => Bool
  | .nszZero => Bool
  | .compareBytes _ => Int

class MonadChoice (m : Type → Type) where
  choose : (c : Choice) → m c.Answer

export MonadChoice (choose)

/-- Daemonic constraint violated: no behavior. -/
def throwNoBehavior {m : Type → Type} {α : Type} [MonadExceptOf Outcome m] (msg : String) : m α :=
  throwThe Outcome (.noBehavior msg)

end Ryo.Spec
