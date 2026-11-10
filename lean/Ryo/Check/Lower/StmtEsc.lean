/-
Ryo.Check.Lower.StmtEsc — `Stmt.lean`'s arithmetic and constant rules with a destination that
may be escaped (aot.md §C1, M5b).

`LowerStmtEsc Γ st is` has `LowerStmt`'s `binop`, `binopImm`, `constInt` and `constBool`
rules without their `hpriv` (`_d`'s slot never escaped): the simulation
(`Proofs/Lower/SimStmtEsc.lean`) writes `_d` through `FnRel.dstWriteAll` (`WriteDst.lean`),
private or escaped.

`checkStmtEsc` reuses `checkStmt` at `Γ.noEsc` (`Γ` with no offset escaped: `privOk` holds
there, and nothing else the four rules check reads `escaped`), on the statements of those four
shapes (`escShape`: a binary operation or a constant; copies of locals are `Copy.lean`'s, whose
rules already allow an escaped destination). It answers `some .ok` or `none`, so that it can go
first in `checkFamilies` without hiding the other families' buckets.
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- `Γ` with no frame offset escaped. -/
def StmtCtx.noEsc (Γ : StmtCtx) : StmtCtx := { Γ with escaped := fun _ => false }

inductive LowerStmtEsc (Γ : StmtCtx) : Statement → List Insn → Prop where
  | binop {d a b : Local} {oa ob : Operand} {op : BinOp} {m : String} {t : IntType}
      {valid : ValidRange} {sd sa sb : LocalSlot} {i : Insn}
      (hm : binMethod op = some m) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hta : Γ.body.locals[a]? = some (.int t valid))
      (htb : Γ.body.locals[b]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = t.size ∧ sa.size = t.size ∧ sb.size = t.size)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk sb.off)
      (hi : binInsnOk Γ i m t.size sd.off sa.off sb.off = true) :
      LowerStmtEsc Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]
  | binopImm {d a : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {t : IntType}
      {valid : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hm : binMethod op = some m) (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = t.size)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : binImmInsnOk Γ i m t.size sd.off sa.off bits = true) :
      LowerStmtEsc Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int t valid)))) [i]
  | constInt {d : Local} {bits : Nat} {t : IntType} {valid : ValidRange} {sd : LocalSlot}
      {i : Insn}
      (htd : Γ.body.locals[d]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size)
      (hoff : offOk sd.off)
      (hi : immInsnOk Γ i t.size sd.off bits = true) :
      LowerStmtEsc Γ (.assign ⟨d, []⟩ (.use (.const (.scalar bits) (.int t valid)))) [i]
  | constBool {d : Local} {bits : Nat} {sd : LocalSlot} {i : Insn}
      (htd : Γ.body.locals[d]? = some .bool)
      (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = 1)
      (hoff : offOk sd.off)
      (hi : immInsnOk Γ i 1 sd.off bits = true) :
      LowerStmtEsc Γ (.assign ⟨d, []⟩ (.use (.const (.scalar bits) .bool))) [i]

/-- The statements the family covers: a binary operation or a `use` of a non-local. -/
def escShape : Statement → Bool
  | .assign ⟨_, []⟩ (.binaryOp ..) => true
  | .assign ⟨_, []⟩ (.use oa) => oa.local?.isNone
  | _ => false

/-- The instruction checks read only `Γ`'s mode and placement. -/
theorem binInsnOk_noEsc (Γ : StmtCtx) : binInsnOk Γ.noEsc = binInsnOk Γ := rfl
theorem binImmInsnOk_noEsc (Γ : StmtCtx) : binImmInsnOk Γ.noEsc = binImmInsnOk Γ := rfl
theorem immInsnOk_noEsc (Γ : StmtCtx) : immInsnOk Γ.noEsc = immInsnOk Γ := rfl

/-- `LowerStmt` at `Γ.noEsc` of an `escShape` statement is `LowerStmtEsc` at `Γ`. -/
theorem lowerStmtEsc_of {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : LowerStmt Γ.noEsc st is) (hs : escShape st = true) : LowerStmtEsc Γ st is := by
  cases h with
  | binop hm ha hb htd hta htb hsd hsa hsb hsize hoff _ hi =>
    rw [binInsnOk_noEsc] at hi
    exact .binop hm ha hb htd hta htb hsd hsa hsb hsize hoff hi
  | binopImm hm ha htd hta hsd hsa hsize hoff _ hi =>
    rw [binImmInsnOk_noEsc] at hi
    exact .binopImm hm ha htd hta hsd hsa hsize hoff hi
  | constInt htd hsd hsize hoff _ hi =>
    rw [immInsnOk_noEsc] at hi
    exact .constInt htd hsd hsize hoff hi
  | constBool htd hsd hsize hoff _ hi =>
    rw [immInsnOk_noEsc] at hi
    exact .constBool htd hsd hsize hoff hi
  | copyInt ha => simp [escShape, ha] at hs
  | copyBool ha => simp [escShape, ha] at hs
  | copyPtr _ ha => simp [escShape, ha] at hs
  | storageLive => simp [escShape] at hs
  | storageDead => simp [escShape] at hs

/-- The family's checker: `some .ok` when `checkStmt` accepts the statement at `Γ.noEsc`. -/
def checkStmtEsc (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  if escShape st = true ∧ checkStmt Γ.noEsc st is = .ok then some .ok else none

theorem checkStmtEsc_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkStmtEsc Γ st is = some .ok) : LowerStmtEsc Γ st is := by
  unfold checkStmtEsc at h
  split at h
  next hc => exact lowerStmtEsc_of (checkStmt_sound hc.2) hc.1
  next => cases h

end Ryo.Check.Lower
