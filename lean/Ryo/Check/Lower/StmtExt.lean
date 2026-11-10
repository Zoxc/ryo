/-
Ryo.Check.Lower.StmtExt — the statement rules of all families (aot.md §C1, M5b): `LowerStmtX`
is `Stmt.lean`'s `LowerStmt` or one of the families' relations (`Copy.lean`, `IntCast.lean`,
`Unop.lean`, `Deref.lean`, `Field.lean`, `Cmp.lean`, `Agg.lean`, `Ref.lean`), and `checkStmtX`
decides it, trying `checkStmt` and then each family's checker (`checkStmtX_sound`). Every family's rule is an assignment to a
whole local; all but `Agg`'s lower it to one instruction. `checkAgg` goes first: it declines
whole-local copies of a `mov` width (Copy's), and claims split copies and aggregates. `Deref`'s
`store` rule is the one assignment to a projected place; `checkDeref` runs before `checkField`,
which reports reads through a deref as unsupported.
-/
import Ryo.Check.Lower.Copy
import Ryo.Check.Lower.IntCast
import Ryo.Check.Lower.Unop
import Ryo.Check.Lower.Field
import Ryo.Check.Lower.Cmp
import Ryo.Check.Lower.Agg
import Ryo.Check.Lower.Wide
import Ryo.Check.Lower.Enum
import Ryo.Check.Lower.Deref
import Ryo.Check.Lower.Ref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerStmtX (Γ : StmtCtx) (st : Statement) (is : List Insn) : Prop where
  | base (h : LowerStmt Γ st is)
  | copy (h : LowerCopy Γ st is)
  | intCast (h : LowerIntCast Γ st is)
  | unop (h : LowerUnop Γ st is)
  | field (h : LowerField Γ st is)
  | cmp (h : LowerCmp Γ st is)
  | agg (h : LowerAgg Γ st is)
  | wide (h : LowerWide Γ st is)
  | enum (h : LowerEnum Γ st is)
  | deref (h : LowerDeref Γ st is)
  | ref (h : LowerRef Γ st is)

/-- The families' checkers in turn: the first that claims the statement decides it. -/
def checkFamilies (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match checkEnum Γ st is with
  | some v => some v
  | none =>
  match checkWide Γ st is with
  | some v => some v
  | none => match checkAgg Γ st is with
  | some v => some v
  | none => match checkCopy Γ st is with
    | some v => some v
    | none => match checkIntCast Γ st is with
      | some v => some v
      | none => match checkUnop Γ st is with
        | some v => some v
        | none => match checkDeref Γ st is with
          | some v => some v
          | none => match checkField Γ st is with
            | some v => some v
            | none => match checkRef Γ st is with
              | some v => some v
              | none => checkCmp Γ st is

def checkStmtX (Γ : StmtCtx) (st : Statement) (is : List Insn) : Verdict :=
  match checkStmt Γ st is with
  | .ok => .ok
  | v => (checkFamilies Γ st is).getD v

theorem checkFamilies_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkFamilies Γ st is = some .ok) : LowerStmtX Γ st is := by
  unfold checkFamilies at h
  split at h
  next v hv => cases h; exact .enum (checkEnum_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .wide (checkWide_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .agg (checkAgg_sound hv)
  next =>
    split at h
    next v hv => cases h; exact .copy (checkCopy_sound hv)
    next =>
      split at h
      next v hv => cases h; exact .intCast (checkIntCast_sound hv)
      next =>
        split at h
        next v hv => cases h; exact .unop (checkUnop_sound hv)
        next =>
          split at h
          next v hv => cases h; exact .deref (checkDeref_sound hv)
          next =>
            split at h
            next v hv => cases h; exact .field (checkField_sound hv)
            next =>
              split at h
              next v hv => cases h; exact .ref (checkRef_sound hv)
              next => exact .cmp (checkCmp_sound h)

theorem checkStmtX_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkStmtX Γ st is = .ok) : LowerStmtX Γ st is := by
  unfold checkStmtX at h
  split at h
  next hb => exact .base (checkStmt_sound hb)
  next hne =>
    cases hf : checkFamilies Γ st is with
    | none => rw [hf] at h; simp only [Option.getD] at h; exact absurd h hne
    | some v =>
      rw [hf] at h
      simp only [Option.getD] at h
      subst h
      exact checkFamilies_sound hf

end Ryo.Check.Lower
