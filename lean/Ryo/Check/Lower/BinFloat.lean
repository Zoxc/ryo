/-
Ryo.Check.Lower.BinFloat — float arithmetic on locals (aot.md §C1, M5b), and its checker.

`_d = op(copy/move _a, copy/move _b)` with `op` one of `+ - * / %` (`floatMethod`) and `_d`,
`_a`, `_b` all of L0 type `.float f`: one `fbin` handler `[f, o]` (`fadd`/`fsub`/`fmul`/`fdiv`/
`frem`) on the three slots (`fbinInsnOk`), each of `f.size` bytes, `_d`'s never escaped.
L0 (`evalBinOp`) and R (`floatBin`) both compute `Ryo.Spec.Float`'s exact IEEE operation
(`floatRes`); a NaN result's bits are L0's oracle answer and R's `Choice` (`resolveNaN`). The
simulation is `Proofs/Lower/SimBinFloat.lean`.

`checkBinFloat` answers `none` unless the statement is such an operator on two whole locals with
a float destination, so it can run anywhere before `checkBinop` (which reports these as
`binop: not integers`).
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The `fbin` operator of a float `BinOp`. -/
def floatMethod : BinOp → Option String
  | .add => some "+"
  | .sub => some "-"
  | .mul => some "*"
  | .div => some "/"
  | .rem => some "%"
  | _ => none

/-- An instruction whose view is an `fbin` handler with operator `o` at format `f`, on slots
`d, a, b`, falling through. -/
def fbinInsnOk (Γ : StmtCtx) (i : Insn) (o : String) (f : FloatTy) (d a b : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, o'], _⟩ =>
      kd == .fbin && o' == o && OpSem.Ty.parse ty == some (.float f) &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] &&
        v.ops == [.slot d, .slot a, .slot b] && v.ctl == some .next
    | _ => false
  | none => false

theorem fbinInsnOk_spec {Γ : StmtCtx} {i : Insn} {o : String} {f : FloatTy} {d a b : Int}
    (h : fbinInsnOk Γ i o f d a b = true) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.fbin, [ty, o], r⟩ ∧
      OpSem.Ty.parse ty = some (.float f) ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] ∧
      v.ops = [.slot d, .slot a, .slot b] ∧ v.ctl = some .next := by
  unfold fbinInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty o' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨hkd, ho'⟩, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hkd
      subst ho'
      exact ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩
    · cases h
  · cases h

inductive LowerBinFloat (Γ : StmtCtx) : Statement → List Insn → Prop where
  | bin {d a b : Local} {op : BinOp} {oa ob : Operand} {o : String} {f : FloatTy}
      {sd sa sb : LocalSlot} {i : Insn}
      (hm : floatMethod op = some o) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some (.float f)) (hta : Γ.body.locals[a]? = some (.float f))
      (htb : Γ.body.locals[b]? = some (.float f))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = f.size ∧ sa.size = f.size ∧ sb.size = f.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true ∧ offOk sb.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : fbinInsnOk Γ i o f sd.off sa.off sb.off = true) :
      LowerBinFloat Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]

/-! ### The checker -/

/-- The rule's conditions after the statement's shape. -/
def binFloatOk (Γ : StmtCtx) (d a b : Local) (o : String) (is : List Insn) : Bool :=
  match Γ.body.locals[d]?, Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
  | some (.float f), some sd, some sa, some sb, [i] =>
    decide (Γ.body.locals[a]? = some (.float f)) &&
      decide (Γ.body.locals[b]? = some (.float f)) &&
      sd.size == f.size && sa.size == f.size && sb.size == f.size &&
      offOk sd.off && offOk sa.off && offOk sb.off && privOk Γ sd.off sd.size &&
      fbinInsnOk Γ i o f sd.off sa.off sb.off
  | _, _, _, _, _ => false

/-- Decide `LowerBinFloat` (see the module comment). -/
def checkBinFloat (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    match floatMethod op, oa.local?, ob.local? with
    | some o, some a, some b =>
      match Γ.body.locals[d]? with
      | some (.float _) => if binFloatOk Γ d a b o is then some .ok else none
      | _ => none
    | _, _, _ => none
  | _ => none

theorem binFloatOk_sound {Γ : StmtCtx} {d a b : Local} {op : BinOp} {oa ob : Operand}
    {o : String} {is : List Insn} (hm : floatMethod op = some o) (ha : oa.local? = some a)
    (hb : ob.local? = some b) (h : binFloatOk Γ d a b o is = true) :
    LowerBinFloat Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) is := by
  unfold binFloatOk at h
  split at h
  next f sd sa sb i htd hsd hsa hsb =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨hta, htb⟩, h1⟩, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, hi⟩ := h
    exact .bin hm ha hb htd hta htb hsd hsa hsb ⟨h1, h2, h3⟩ ⟨h4, h5, h6⟩ (privOk_spec h7) hi
  next => cases h

theorem checkBinFloat_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkBinFloat Γ st is = some .ok) : LowerBinFloat Γ st is := by
  unfold checkBinFloat at h
  split at h
  next d op oa ob =>
    split at h
    next o a b hm ha hb =>
      split at h
      next f htd =>
        split at h
        next hok => exact binFloatOk_sound hm ha hb hok
        next => cases h
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
