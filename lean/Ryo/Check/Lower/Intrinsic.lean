/-
Ryo.Check.Lower.Intrinsic — statement rules for the non-diverging intrinsics (aot.md §C1, M5b).

- `assume`: `Assume(op)` (rustc `NonDivergingIntrinsic::Assume`), lowered to no instruction
  (`backend/src/lower/rvalue.rs`: `Assume(_) => Ok(())`). L0 evaluates `op` and is UB unless it
  is `true` (`evalStatement`), so a run that goes on is in the state it was in, given an operand
  whose evaluation only reads (`assumeOperand`: a whole local or a runtime check). R takes no
  step, and the relation holds at the next point's liveness, which is below this one's (the
  statement kills nothing): `Ryo/Proofs/Lower/SimIntrinsic.lean`.

`CopyNonOverlapping` is not covered: the backend copies `count * size_of::<T>()` bytes through
a frame temporary outside the locals (`mem_copy_pieces`: `load`s then `store`s through the
pointers) or calls the `memcpy` handler, so its simulation needs loads and stores through two
pointers of a run-time length and a frame slot no local owns.

`checkIntrinsic` claims every `Assume` and is `none` for any other statement.
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The operands `assume` takes: their evaluation leaves L0's state as it is. -/
def assumeOperand : Operand → Bool
  | .copy ⟨_, []⟩ | .move ⟨_, []⟩ | .runtimeChecks .. => true
  | _ => false

inductive LowerIntrinsic (Γ : StmtCtx) : Statement → List Insn → Prop where
  | assume {op : Operand} (hop : assumeOperand op = true) : LowerIntrinsic Γ (.assume op) []

/-- The family's checker: `none` unless the statement is an `Assume`. -/
def checkIntrinsic (_Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assume op =>
    if !assumeOperand op then some (.unsupported "assume: operand")
    else match is with
      | [] => some .ok
      | _ :: _ => some (.rejected "assume: instructions")
  | _ => none

theorem checkIntrinsic_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkIntrinsic Γ st is = some .ok) : LowerIntrinsic Γ st is := by
  unfold checkIntrinsic at h
  split at h
  next op =>
    split at h
    · cases h
    next hop =>
      split at h
      · exact .assume (by simpa using hop)
      · cases h
  · cases h

end Ryo.Check.Lower
