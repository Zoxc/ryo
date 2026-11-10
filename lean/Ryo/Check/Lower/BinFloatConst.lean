/-
Ryo.Check.Lower.BinFloatConst — `BinFloat.lean`'s float arithmetic with one constant operand
(aot.md §C1, M5b), and its checker.

What the backend emits (`backend/src/lower/binop.rs` `float_arith`, `operand.rs`
`operand_slot`, `constant.rs` `const_value_into`): the constant has no slot, so its bits are
materialized into a temporary `tt` (one `imm` of the format's width), then the `fbin` handler on
the two slots.

Rules (`op` one of `floatMethod`'s, `_d` and the local operand of L0 type `.float f`, the
constant of type `.float f`, slots of `f.size` bytes, `_d` private, `tt` a temporary of `f.size`
bytes, `tempOk`):
- `constRight`: `_d = op(_a, const bits)`, lowered to `[imm tt, bits; fbin d, a, tt]`.
- `constLeft`: `_d = op(const bits, _b)`, lowered to `[imm tt, bits; fbin d, tt, b]`.

`checkBinFloatConst` claims these operators on a float constant and a whole local and is `none`
otherwise. The temporary's offset is read off the `imm` (untrusted, then checked).
-/
import Ryo.Check.Lower.BinFloat
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerBinFloatConst (Γ : StmtCtx) : Statement → List Insn → Prop where
  | constRight {d a : Local} {oa : Operand} {op : BinOp} {o : String} {bits : Nat}
      {f : FloatTy} {sd sa : LocalSlot} {tt : Int} {i1 i2 : Insn}
      (hm : floatMethod op = some o) (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.float f)) (hta : Γ.body.locals[a]? = some (.float f))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = f.size ∧ sa.size = f.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt f.size = true) (hi1 : immInsnOk Γ i1 f.size tt bits = true)
      (hi2 : fbinInsnOk Γ i2 o f sd.off sa.off tt = true) :
      LowerBinFloatConst Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.float f))))
        [i1, i2]
  | constLeft {d b : Local} {ob : Operand} {op : BinOp} {o : String} {bits : Nat}
      {f : FloatTy} {sd sb : LocalSlot} {tt : Int} {i1 i2 : Insn}
      (hm : floatMethod op = some o) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some (.float f)) (htb : Γ.body.locals[b]? = some (.float f))
      (hsd : Γ.slots[d]? = some sd) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = f.size ∧ sb.size = f.size)
      (hoff : offOk sd.off = true ∧ offOk sb.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt f.size = true) (hi1 : immInsnOk Γ i1 f.size tt bits = true)
      (hi2 : fbinInsnOk Γ i2 o f sd.off tt sb.off = true) :
      LowerBinFloatConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.float f)) ob))
        [i1, i2]

/-! ### The checker -/

/-- `constRight`'s (`left = false`) or `constLeft`'s (`left = true`) conditions, `ol` the local
operand. -/
def floatConstOk (Γ : StmtCtx) (left : Bool) (d : Local) (o : String) (bits : Nat)
    (fc : FloatTy) (ol : Operand) (i1 i2 : Insn) : Bool :=
  match ol.local?, Γ.body.locals[d]?, Γ.slots[d]?, immSlotOf Γ i1 with
  | some a, some (.float f), some sd, some tt =>
    match Γ.slots[a]? with
    | some sa =>
      decide (Γ.body.locals[a]? = some (.float f)) && decide (fc = f) && sd.size == f.size &&
        sa.size == f.size && offOk sd.off && offOk sa.off && privOk Γ sd.off sd.size &&
        tempOk Γ tt f.size && immInsnOk Γ i1 f.size tt bits &&
        (if left then fbinInsnOk Γ i2 o f sd.off tt sa.off
         else fbinInsnOk Γ i2 o f sd.off sa.off tt)
    | none => false
  | _, _, _, _ => false

theorem floatConstOk_right {Γ : StmtCtx} {d : Local} {op : BinOp} {o : String} {bits : Nat}
    {fc : FloatTy} {oa : Operand} {i1 i2 : Insn} (hm : floatMethod op = some o)
    (h : floatConstOk Γ false d o bits fc oa i1 i2 = true) :
    LowerBinFloatConst Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.float fc))))
      [i1, i2] := by
  unfold floatConstOk at h
  split at h
  next a f sd tt ha htd hsd htt =>
    split at h
    next sa hsa =>
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq, Bool.false_eq_true,
        ↓reduceIte] at h
      obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩ := h
      subst h2
      exact .constRight hm ha htd h1 hsd hsa ⟨h3, h4⟩ ⟨h5, h6⟩ (privOk_spec h7) h8 h9 h10
    next => cases h
  next => cases h

theorem floatConstOk_left {Γ : StmtCtx} {d : Local} {op : BinOp} {o : String} {bits : Nat}
    {fc : FloatTy} {ob : Operand} {i1 i2 : Insn} (hm : floatMethod op = some o)
    (h : floatConstOk Γ true d o bits fc ob i1 i2 = true) :
    LowerBinFloatConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.float fc)) ob))
      [i1, i2] := by
  unfold floatConstOk at h
  split at h
  next b f sd tt hb htd hsd htt =>
    split at h
    next sb hsb =>
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq, ↓reduceIte] at h
      obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩ := h
      subst h2
      exact .constLeft hm hb htd h1 hsd hsb ⟨h3, h4⟩ ⟨h5, h6⟩ (privOk_spec h7) h8 h9 h10
    next => cases h
  next => cases h

/-- Decide `LowerBinFloatConst` (see the module comment). -/
def checkBinFloatConst (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.float fc))) =>
    match floatMethod op, oa.local? with
    | some o, some _ => some (match is with
      | [i1, i2] => okIf (floatConstOk Γ false d o bits fc oa i1 i2) "float const: form"
      | _ => .unsupported "float const: instruction count")
    | _, _ => none
  | .assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.float fc)) ob) =>
    match floatMethod op, ob.local? with
    | some o, some _ => some (match is with
      | [i1, i2] => okIf (floatConstOk Γ true d o bits fc ob i1 i2) "float const: form"
      | _ => .unsupported "float const: instruction count")
    | _, _ => none
  | _ => none

theorem checkBinFloatConst_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkBinFloatConst Γ st is = some .ok) : LowerBinFloatConst Γ st is := by
  unfold checkBinFloatConst at h
  split at h
  · split at h
    next o _ hm _ =>
      have h' := Option.some.inj h
      split at h'
      · exact floatConstOk_right hm (okIf_ok h')
      · cases h'
    · cases h
  · split at h
    next o _ hm _ =>
      have h' := Option.some.inj h
      split at h'
      · exact floatConstOk_left hm (okIf_ok h')
      · cases h'
    · cases h
  · cases h

end Ryo.Check.Lower
