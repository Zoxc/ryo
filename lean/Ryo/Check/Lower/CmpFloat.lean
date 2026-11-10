/-
Ryo.Check.Lower.CmpFloat — float comparisons of locals (aot.md §C1, M5b), and their checker.

`_d = op(copy/move _a, copy/move _b)` with `op` one of `== != < <= > >=`, `_a` and `_b` of L0
type `.float f` and `_d` a `bool`: one `fcmp` handler on the three slots. The backend
(`backend/src/lower/binop.rs` `compare`) has only `feq`/`fne`/`flt`/`fle`, so `>` and `>=` are
`flt`/`fle` with the operands swapped (`fcmpOp`'s flag). L0 (`relResult` of `Float.cmp`) and R
(`floatCmp`) both use `Ryo.Spec.Float.cmp`; the swap is `Float.cmp`'s antisymmetry
(`Proofs/Lower/SimCmpFloat.lean`, which is the simulation).

`checkCmpFloat` answers `none` unless the statement is such a comparison with all checks
passing, so it must run before `checkCmp`, which reports float operands as unsupported.
-/
import Ryo.Check.Lower.BinFloat

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The `fcmp` operator of a comparison, and whether the operands are swapped. -/
def fcmpOp : BinOp → Option (String × Bool)
  | .eq => some ("==", false)
  | .ne => some ("!=", false)
  | .lt => some ("<", false)
  | .le => some ("<=", false)
  | .gt => some ("<", true)
  | .ge => some ("<=", true)
  | _ => none

/-- An instruction whose view is an `fcmp` handler with operator `o` at format `f`, on slots
`d, a, b`, falling through. -/
def fcmpInsnOk (Γ : StmtCtx) (i : Insn) (o : String) (f : FloatTy) (d a b : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, o'], _⟩ =>
      kd == .fcmp && o' == o && OpSem.Ty.parse ty == some (.float f) &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] &&
        v.ops == [.slot d, .slot a, .slot b] && v.ctl == some .next
    | _ => false
  | none => false

theorem fcmpInsnOk_spec {Γ : StmtCtx} {i : Insn} {o : String} {f : FloatTy} {d a b : Int}
    (h : fcmpInsnOk Γ i o f d a b = true) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.fcmp, [ty, o], r⟩ ∧
      OpSem.Ty.parse ty = some (.float f) ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] ∧
      v.ops = [.slot d, .slot a, .slot b] ∧ v.ctl = some .next := by
  unfold fcmpInsnOk at h
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

inductive LowerCmpFloat (Γ : StmtCtx) : Statement → List Insn → Prop where
  | cmp {d a b : Local} {op : BinOp} {oa ob : Operand} {o : String} {sw : Bool} {f : FloatTy}
      {sd sa sb : LocalSlot} {i : Insn}
      (hm : fcmpOp op = some (o, sw)) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some (.float f))
      (htb : Γ.body.locals[b]? = some (.float f))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = 1 ∧ sa.size = f.size ∧ sb.size = f.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true ∧ offOk sb.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : fcmpInsnOk Γ i o f sd.off (if sw then sb.off else sa.off)
        (if sw then sa.off else sb.off) = true) :
      LowerCmpFloat Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]

/-! ### The checker -/

/-- The rule's conditions after the statement's shape. -/
def cmpFloatOk (Γ : StmtCtx) (d a b : Local) (o : String) (sw : Bool) (is : List Insn) : Bool :=
  match Γ.body.locals[a]?, Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
  | some (.float f), some sd, some sa, some sb, [i] =>
    decide (Γ.body.locals[d]? = some .bool) &&
      decide (Γ.body.locals[b]? = some (.float f)) &&
      sd.size == 1 && sa.size == f.size && sb.size == f.size &&
      offOk sd.off && offOk sa.off && offOk sb.off && privOk Γ sd.off sd.size &&
      fcmpInsnOk Γ i o f sd.off (if sw then sb.off else sa.off) (if sw then sa.off else sb.off)
  | _, _, _, _, _ => false

/-- Decide `LowerCmpFloat` (see the module comment). -/
def checkCmpFloat (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    match fcmpOp op, oa.local?, ob.local? with
    | some (o, sw), some a, some b => if cmpFloatOk Γ d a b o sw is then some .ok else none
    | _, _, _ => none
  | _ => none

theorem cmpFloatOk_sound {Γ : StmtCtx} {d a b : Local} {op : BinOp} {oa ob : Operand}
    {o : String} {sw : Bool} {is : List Insn} (hm : fcmpOp op = some (o, sw))
    (ha : oa.local? = some a) (hb : ob.local? = some b) (h : cmpFloatOk Γ d a b o sw is = true) :
    LowerCmpFloat Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) is := by
  unfold cmpFloatOk at h
  split at h
  next f sd sa sb i hta hsd hsa hsb =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨htd, htb⟩, h1⟩, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, hi⟩ := h
    exact .cmp hm ha hb htd hta htb hsd hsa hsb ⟨h1, h2, h3⟩ ⟨h4, h5, h6⟩ (privOk_spec h7) hi
  next => cases h

theorem checkCmpFloat_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkCmpFloat Γ st is = some .ok) : LowerCmpFloat Γ st is := by
  unfold checkCmpFloat at h
  split at h
  next d op oa ob =>
    split at h
    next o sw a b hm ha hb =>
      split at h
      next hok => exact cmpFloatOk_sound hm ha hb hok
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
