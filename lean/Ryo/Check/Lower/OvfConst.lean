/-
Ryo.Check.Lower.OvfConst — `Ovf.lean`'s overflow-checked operators with one constant operand
(aot.md §C1, M5b), and their checker.

What the backend emits (`backend/src/lower/binop.rs`, `operand.rs` `operand_slot`): the constant
has no slot, so it is materialized into a fresh temporary `tt` (one `imm` of the type's width, as
`BinXConst.lean`'s), then the `ovf` handler on `d + ov, d + oo` and the two operands' slots.

Rules (`_d` the pair `(t, bool)` as in `Ovf.lean`, `t.wf`, the constant of type `t`, `tt` a
temporary of `t.size` bytes, `tempOk`):
- `constRight`: `_d = op(_a, const bits)`, lowered to `[imm tt, bits; ovf d+ov, d+oo, a, tt]`.
- `constLeft`: `_d = op(const bits, _b)`, lowered to `[imm tt, bits; ovf d+ov, d+oo, tt, b]`.

`checkOvfConst` claims every such statement whose other operand is a whole local and is `none`
otherwise; it must run before `checkOvf`, which reports them as `ovf: operands`. The temporary's
offset is read off the `imm` (untrusted, then checked).
-/
import Ryo.Check.Lower.Ovf
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerOvfConst (Γ : StmtCtx) : Statement → List Insn → Prop where
  | constRight {d a : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {t : IntType}
      {valid vt vc : ValidRange} {ov oo : Nat} {head : TupleHeadLayout} {sd sa : LocalSlot}
      {tt : Int} {i1 i2 : Insn}
      (hm : ovfMethod op = some m) (ha : oa.local? = some a) (hwf : t.wf = true)
      (htd : Γ.body.locals[d]? = some (.tuple [(ov, .int t vt), (oo, .bool)] head none))
      (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = head.headSizeAndAlign.1 ∧ sa.size = t.size)
      (hlay : ovfLayoutOk sd.size ov oo t.size = true)
      (hoff : offOk (sd.off + ov) = true ∧ offOk (sd.off + oo) = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt bits = true)
      (hi2 : ovfInsnOk Γ i2 m t.size t.signed (sd.off + ov) (sd.off + oo) sa.off tt = true) :
      LowerOvfConst Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int t vc))))
        [i1, i2]
  | constLeft {d b : Local} {ob : Operand} {op : BinOp} {m : String} {bits : Nat} {t : IntType}
      {valid vt vc : ValidRange} {ov oo : Nat} {head : TupleHeadLayout} {sd sb : LocalSlot}
      {tt : Int} {i1 i2 : Insn}
      (hm : ovfMethod op = some m) (hb : ob.local? = some b) (hwf : t.wf = true)
      (htd : Γ.body.locals[d]? = some (.tuple [(ov, .int t vt), (oo, .bool)] head none))
      (htb : Γ.body.locals[b]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = head.headSizeAndAlign.1 ∧ sb.size = t.size)
      (hlay : ovfLayoutOk sd.size ov oo t.size = true)
      (hoff : offOk (sd.off + ov) = true ∧ offOk (sd.off + oo) = true ∧ offOk sb.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt bits = true)
      (hi2 : ovfInsnOk Γ i2 m t.size t.signed (sd.off + ov) (sd.off + oo) tt sb.off = true) :
      LowerOvfConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.int t vc)) ob))
        [i1, i2]

/-! ### The checker -/

/-- `constRight`'s (`left = false`) or `constLeft`'s (`left = true`) conditions, `ol` the local
operand. -/
def ovfConstOk (Γ : StmtCtx) (left : Bool) (d : Local) (op : BinOp) (bits : Nat) (tc : IntType)
    (ol : Operand) (i1 i2 : Insn) : Bool :=
  match ovfMethod op, ol.local? with
  | some m, some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]?, Γ.slots[d]?, Γ.slots[a]?, immSlotOf Γ i1 with
    | some (.tuple [(ov, .int t' _), (oo, .bool)] head none), some (.int t _), some sd, some sa,
        some tt =>
      decide (t' = t) && decide (tc = t) && t.wf && sd.size == head.headSizeAndAlign.1 &&
        sa.size == t.size && ovfLayoutOk sd.size ov oo t.size && offOk (sd.off + ov) &&
        offOk (sd.off + oo) && offOk sa.off && privOk Γ sd.off sd.size && tempOk Γ tt t.size &&
        immInsnOk Γ i1 t.size tt bits &&
        (if left then ovfInsnOk Γ i2 m t.size t.signed (sd.off + ov) (sd.off + oo) tt sa.off
         else ovfInsnOk Γ i2 m t.size t.signed (sd.off + ov) (sd.off + oo) sa.off tt)
    | _, _, _, _, _ => false
  | _, _ => false

theorem ovfConstOk_right {Γ : StmtCtx} {d : Local} {op : BinOp} {bits : Nat} {tc : IntType}
    {vc : ValidRange} {oa : Operand} {i1 i2 : Insn}
    (h : ovfConstOk Γ false d op bits tc oa i1 i2 = true) :
    LowerOvfConst Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc vc))))
      [i1, i2] := by
  unfold ovfConstOk at h
  split at h
  next m a hm ha =>
    split at h
    next ov t' vt oo head t valid sd sa tt htd hta hsd hsa htt =>
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq, Bool.false_eq_true,
        ↓reduceIte] at h
      obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩, h11⟩, h12⟩, h13⟩ := h
      subst h1 h2
      exact .constRight hm ha h3 htd hta hsd hsa ⟨h4, h5⟩ h6 ⟨h7, h8, h9⟩ (privOk_spec h10) h11
        h12 h13
    next => cases h
  next => cases h

theorem ovfConstOk_left {Γ : StmtCtx} {d : Local} {op : BinOp} {bits : Nat} {tc : IntType}
    {vc : ValidRange} {ob : Operand} {i1 i2 : Insn}
    (h : ovfConstOk Γ true d op bits tc ob i1 i2 = true) :
    LowerOvfConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.int tc vc)) ob))
      [i1, i2] := by
  unfold ovfConstOk at h
  split at h
  next m b hm hb =>
    split at h
    next ov t' vt oo head t valid sd sb tt htd htb hsd hsb htt =>
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq, ↓reduceIte] at h
      obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩, h11⟩, h12⟩, h13⟩ := h
      subst h1 h2
      exact .constLeft hm hb h3 htd htb hsd hsb ⟨h4, h5⟩ h6 ⟨h7, h8, h9⟩ (privOk_spec h10) h11
        h12 h13
    next => cases h
  next => cases h

/-- Decide `LowerOvfConst`: `none` unless `st` assigns an overflow-checked operator on a whole
local and an integer constant to a whole local. -/
def checkOvfConst (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc _))) =>
    match ovfMethod op, oa.local? with
    | some _, some _ =>
      some (match is with
        | [i1, i2] => okIf (ovfConstOk Γ false d op bits tc oa i1 i2) "ovf const: form"
        | _ => .unsupported "ovf const: instruction count")
    | _, _ => none
  | .assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.int tc _)) ob) =>
    match ovfMethod op, ob.local? with
    | some _, some _ =>
      some (match is with
        | [i1, i2] => okIf (ovfConstOk Γ true d op bits tc ob i1 i2) "ovf const: form"
        | _ => .unsupported "ovf const: instruction count")
    | _, _ => none
  | _ => none

theorem checkOvfConst_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkOvfConst Γ st is = some .ok) : LowerOvfConst Γ st is := by
  unfold checkOvfConst at h
  split at h
  · split at h
    · have h' := Option.some.inj h
      split at h'
      · exact ovfConstOk_right (okIf_ok h')
      · cases h'
    · cases h
  · split at h
    · have h' := Option.some.inj h
      split at h'
      · exact ovfConstOk_left (okIf_ok h')
      · cases h'
    · cases h
  · cases h

end Ryo.Check.Lower
