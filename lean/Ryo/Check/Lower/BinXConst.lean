/-
Ryo.Check.Lower.BinXConst — `BinX.lean`'s operators with a constant left operand (aot.md §C1,
M5b), and their checker.

What the backend emits (`backend/src/lower/binop.rs` `arith`, `operand.rs` `operand_slot`): the
constant has no slot, so it is materialized into a fresh temporary `t` (one `imm` of the type's
width, as `CmpConst.lean`'s), then the `bin`/`bin_fn`/`binop`/`shift` handler on `d, t, b`.

Rule (`constLeft`): `_d = op(const bits : t, _b)`, `op` one of `binXMethod`'s, `_d` and `_b` of
the integer type `t`, slots of `t`'s size, `_d` never escaped, `t` a temporary of `t.size` bytes
(`tempOk`), lowered to `[imm t, bits; binX d, t, b]` (`binXInsnOk`). The simulation
(`Proofs/Lower/SimBinXConst.lean`) is `BinX`'s `bin` with the left operand read back from the
temporary.

`checkBinXConst` claims every such statement whose right operand is a whole local and is `none`
otherwise; it must run before `checkBinX`, which reports them as `binop x: operands`. The
temporary's offset is read off the `imm` (untrusted, then checked).
-/
import Ryo.Check.Lower.BinX
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerBinXConst (Γ : StmtCtx) : Statement → List Insn → Prop where
  | constLeft {d b : Local} {ob : Operand} {op : BinOp} {m : String} {bits : Nat} {t : IntType}
      {valid vc : ValidRange} {sd sb : LocalSlot} {tt : Int} {i1 i2 : Insn}
      (hm : binXMethod op = some m) (hb : ob.local? = some b) (hmod : shiftOk t t = true)
      (htd : Γ.body.locals[d]? = some (.int t valid))
      (htb : Γ.body.locals[b]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = t.size ∧ sb.size = t.size)
      (hoff : offOk sd.off = true ∧ offOk sb.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt bits = true)
      (hi2 : binXInsnOk Γ i2 m t.size (binXSigned op) t.signed sd.off tt sb.off = true) :
      LowerBinXConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.int t vc)) ob))
        [i1, i2]

/-! ### The checker -/

/-- `constLeft`'s conditions. -/
def binXConstOk (Γ : StmtCtx) (d : Local) (op : BinOp) (bits : Nat) (tc : IntType)
    (ob : Operand) (i1 i2 : Insn) : Bool :=
  match binXMethod op, ob.local? with
  | some m, some b =>
    match Γ.body.locals[d]?, Γ.body.locals[b]?, Γ.slots[d]?, Γ.slots[b]?, immSlotOf Γ i1 with
    | some (.int t valid), some tb, some sd, some sb, some tt =>
      decide (tb = .int t valid) && decide (tc = t) && shiftOk t t && sd.size == t.size &&
        sb.size == t.size && offOk sd.off && offOk sb.off && privOk Γ sd.off sd.size &&
        tempOk Γ tt t.size && immInsnOk Γ i1 t.size tt bits &&
        binXInsnOk Γ i2 m t.size (binXSigned op) t.signed sd.off tt sb.off
    | _, _, _, _, _ => false
  | _, _ => false

theorem binXConstOk_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {bits : Nat} {tc : IntType}
    {vc : ValidRange} {ob : Operand} {i1 i2 : Insn}
    (h : binXConstOk Γ d op bits tc ob i1 i2 = true) :
    LowerBinXConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.int tc vc)) ob))
      [i1, i2] := by
  unfold binXConstOk at h
  split at h
  next m b hm hb =>
    split at h
    next t valid tb sd sb tt htd htb hsd hsb htt =>
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
      obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩, h11⟩ := h
      subst h1 h2
      exact .constLeft hm hb h3 htd htb hsd hsb ⟨h4, h5⟩ ⟨h6, h7⟩ (privOk_spec h8) h9 h10 h11
    next => cases h
  next => cases h

/-- Decide `LowerBinXConst`: `none` unless `st` assigns one of `binXMethod`'s operators on an
integer constant and a whole local to a whole local. -/
def checkBinXConst (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op (.const (.scalar bits) (.int tc _)) ob) =>
    match binXMethod op, ob.local? with
    | some _, some _ =>
      some (match is with
        | [i1, i2] => okIf (binXConstOk Γ d op bits tc ob i1 i2) "binop x const: form"
        | _ => .unsupported "binop x const: instruction count")
    | _, _ => none
  | _ => none

theorem checkBinXConst_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkBinXConst Γ st is = some .ok) : LowerBinXConst Γ st is := by
  unfold checkBinXConst at h
  split at h
  next d op bits tc vc ob =>
    split at h
    next m b hm hb =>
      have h' := Option.some.inj h
      split at h'
      next i1 i2 => exact binXConstOk_sound (okIf_ok h')
      next => cases h'
    next => cases h
  next => cases h

end Ryo.Check.Lower
