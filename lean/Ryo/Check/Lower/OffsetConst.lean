/-
Ryo.Check.Lower.OffsetConst — pointer `Offset` by a constant index (aot.md §C1, M5b), next to
`Offset.lean`'s local-index rule, and its checker.

What the backend emits (`backend/src/lower/binop.rs`, `BinOp::Offset`; `operand.rs`
`operand_slot`): the constant index has no slot, so it is materialized into a fresh temporary
`t` (one `imm` of 8 bytes, as `CmpConst.lean`'s), then `ptr.index d, a, t, sz`.

Rule (`constIdx`): `_d = Offset(_a, const bits : tb)`, `_a` and `_d` of one thin pointer type with
a sized pointee (`sz` bytes), `tb` an 8-byte integer type, 8-byte slots, `_d` never escaped, `t`
a temporary of 8 bytes (`tempOk`), lowered to `[imm t, bits; ptr.index sd.off, sa.off, t, sz]`.
The simulation (`Proofs/Lower/SimOffsetConst.lean`) is `Offset`'s with the index read back
from the temporary.

`checkOffsetConst` claims every `Offset` of a whole local by a constant into a whole local and
is `none` otherwise; it must run before `checkOffset`, which reports these as
`offset: operands`. The temporary's offset is read off the `imm` (untrusted, then checked).
-/
import Ryo.Check.Lower.Offset
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerOffsetConst (Γ : StmtCtx) : Statement → List Insn → Prop where
  | constIdx {d a : Local} {oa : Operand} {bits : Nat} {tb : IntType} {vb : ValidRange}
      {pt : PtrType} {valid : ValidRange} {sz : Nat} {al : Align} {inh : Bool}
      {sd sa : LocalSlot} {t : Int} {i1 i2 : Insn}
      (ha : oa.local? = some a) (hk : pt.metaKind = .none)
      (hpe : pt.pointee? = some ⟨.sized sz al, inh⟩)
      (htd : Γ.body.locals[d]? = some (.ptr pt valid))
      (hta : Γ.body.locals[a]? = some (.ptr pt valid)) (htb8 : tb.size = 8)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 8 ∧ sa.size = 8) (hoff : offOk sd.off = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ t 8 = true) (hi1 : immInsnOk Γ i1 8 t bits = true)
      (hi2 : ptrIndexInsnOk Γ i2 sd.off sa.off t sz = true) :
      LowerOffsetConst Γ
        (.assign ⟨d, []⟩ (.binaryOp .offset oa (.const (.scalar bits) (.int tb vb)))) [i1, i2]

/-! ### The checker -/

/-- `constIdx`'s conditions. -/
def offsetConstOk (Γ : StmtCtx) (d : Local) (oa : Operand) (bits : Nat) (tb : IntType)
    (i1 i2 : Insn) : Bool :=
  match oa.local? with
  | some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]?, Γ.slots[d]?, Γ.slots[a]? with
    | some (.ptr pt valid), some ta, some sd, some sa =>
      match pointeeSized? pt, immSlotOf Γ i1 with
      | some (sz, _, _), some t =>
        decide (ta = .ptr pt valid) && decide (pt.metaKind = .none) && tb.size == 8 &&
          sd.size == 8 && sa.size == 8 && offOk sd.off && offOk sa.off &&
          privOk Γ sd.off sd.size && tempOk Γ t 8 && immInsnOk Γ i1 8 t bits &&
          ptrIndexInsnOk Γ i2 sd.off sa.off t sz
      | _, _ => false
    | _, _, _, _ => false
  | none => false

theorem offsetConstOk_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {bits : Nat}
    {tb : IntType} {vb : ValidRange} {i1 i2 : Insn}
    (h : offsetConstOk Γ d oa bits tb i1 i2 = true) :
    LowerOffsetConst Γ (.assign ⟨d, []⟩ (.binaryOp .offset oa (.const (.scalar bits) (.int tb vb))))
      [i1, i2] := by
  unfold offsetConstOk at h
  split at h
  next a ha =>
    split at h
    next pt valid ta sd sa htd hta hsd hsa =>
      split at h
      next sz al inh t hps ht0 =>
        simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
        obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩, h11⟩ := h
        subst h1
        exact .constIdx ha h2 (pointeeSized?_spec hps) htd hta h3 hsd hsa ⟨h4, h5⟩ ⟨h6, h7⟩
          (privOk_spec h8) h9 h10 h11
      next => cases h
    next => cases h
  next => cases h

/-- Decide `LowerOffsetConst`: `none` unless `st` assigns an `Offset` of a whole local by a
constant to a whole local. -/
def checkOffsetConst (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp .offset oa (.const (.scalar bits) (.int tb _))) =>
    match oa.local? with
    | some _ =>
      some (match is with
        | [i1, i2] => okIf (offsetConstOk Γ d oa bits tb i1 i2) "offset const: form"
        | _ => .unsupported "offset const: instruction count")
    | none => none
  | _ => none

theorem checkOffsetConst_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkOffsetConst Γ st is = some .ok) : LowerOffsetConst Γ st is := by
  unfold checkOffsetConst at h
  split at h
  next d oa bits tb vb =>
    split at h
    next a ha =>
      have h' := Option.some.inj h
      split at h'
      next i1 i2 => exact offsetConstOk_sound (okIf_ok h')
      next => cases h'
    next => cases h
  next => cases h

end Ryo.Check.Lower
