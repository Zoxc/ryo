/-
Ryo.Check.Lower.DivConst — `Div`/`Rem` by an integer constant (aot.md §C1, M5b), and their
checker.

What the backend emits (`backend/src/lower/binop.rs`, `arith`), for `_d = op(_a, const v)`:
- `v` a power of two `2 ^ k`, unsigned: `shr.u.imm d, a, k` for `Div`, `and.imm d, a, 2^k - 1`
  for `Rem` (rules `pow2Div`, `pow2Rem`).
- otherwise, outside the special cases below, the constant has no `.imm` form of the handler:
  it is materialized into a temporary `tt` (`imm tt, v`, as `BinXConst.lean`'s), then
  `div`/`rem d, a, tt` (rule `tempRight`; `BinX.lean`'s `bin` with the right operand read from
  `tt`).

- the left operand a constant too, `v` a power of two, unsigned: the constant left into a
  temporary, then the shift or mask on it (rules `ccPow2Div`, `ccPow2Rem`).

Not covered: `v = 1` and signed `v = -1` (`mov`, `mul.imm` by all-ones, `imm 0`), and unsigned
8–32-bit division by other constants (a multiply-shift sequence through a 64-bit temporary).

`checkDivConst` claims every `Div`/`Rem` by an integer scalar constant and is `none` otherwise
(`checkStmt`'s `binopImm` and `checkBinX` decline them). The temporary's offset is read off the
`imm` (untrusted, then checked).
-/
import Ryo.Check.Lower.BinX
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- `k` with `c = 2 ^ k`, if `c` is a power of two. -/
def pow2Of (c : Nat) : Option Nat := if c = 2 ^ c.log2 then some c.log2 else none

theorem pow2Of_spec {c k : Nat} (h : pow2Of c = some k) : c = 2 ^ k := by
  unfold pow2Of at h
  split at h
  next hc =>
    cases h
    exact hc
  · cases h

inductive LowerDivConst (Γ : StmtCtx) : Statement → List Insn → Prop where
  | tempRight {d a : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {t : IntType}
      {valid vc : ValidRange} {sd sa : LocalSlot} {tt : Int} {i1 i2 : Insn}
      (hm : binXMethod op = some m) (ha : oa.local? = some a) (hmod : shiftOk t t = true)
      (htd : Γ.body.locals[d]? = some (.int t valid))
      (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = t.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt bits = true)
      (hi2 : binXInsnOk Γ i2 m t.size (binXSigned op) t.signed sd.off sa.off tt = true) :
      LowerDivConst Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int t vc))))
        [i1, i2]
  | pow2Div {d a : Local} {oa : Operand} {bits : Nat} {t : IntType} {valid vc : ValidRange}
      {sd sa : LocalSlot} {k : Nat} {i : Insn}
      (ha : oa.local? = some a) (hsg : t.signed = false) (hmod : shiftOk t t = true)
      (hk : bits % 2 ^ (8 * t.size) = 2 ^ k) (hkw : k < 8 * t.size)
      (htd : Γ.body.locals[d]? = some (.int t valid))
      (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = t.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : binImmXInsnOk Γ i "wrapping_shr" t.size true false sd.off sa.off (8 * t.size) k
        = true) :
      LowerDivConst Γ (.assign ⟨d, []⟩ (.binaryOp .div oa (.const (.scalar bits) (.int t vc))))
        [i]
  | pow2Rem {d a : Local} {oa : Operand} {bits : Nat} {t : IntType} {valid vc : ValidRange}
      {sd sa : LocalSlot} {k : Nat} {i : Insn}
      (ha : oa.local? = some a) (hsg : t.signed = false)
      (hk : bits % 2 ^ (8 * t.size) = 2 ^ k)
      (htd : Γ.body.locals[d]? = some (.int t valid))
      (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = t.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : binImmXInsnOk Γ i "&" t.size false false sd.off sa.off (2 ^ (8 * t.size)) (2 ^ k - 1)
        = true) :
      LowerDivConst Γ (.assign ⟨d, []⟩ (.binaryOp .rem oa (.const (.scalar bits) (.int t vc))))
        [i]
  | ccPow2Div {d : Local} {ba bb : Nat} {t : IntType} {valid va vc : ValidRange}
      {sd : LocalSlot} {k : Nat} {tt : Int} {i1 i2 : Insn}
      (hsg : t.signed = false) (hmod : shiftOk t t = true)
      (hk : bb % 2 ^ (8 * t.size) = 2 ^ k) (hkw : k < 8 * t.size)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size) (hoff : offOk sd.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt ba = true)
      (hi2 : binImmXInsnOk Γ i2 "wrapping_shr" t.size true false sd.off tt (8 * t.size) k
        = true) :
      LowerDivConst Γ (.assign ⟨d, []⟩ (.binaryOp .div (.const (.scalar ba) (.int t va))
        (.const (.scalar bb) (.int t vc)))) [i1, i2]
  | ccPow2Rem {d : Local} {ba bb : Nat} {t : IntType} {valid va vc : ValidRange}
      {sd : LocalSlot} {k : Nat} {tt : Int} {i1 i2 : Insn}
      (hsg : t.signed = false) (hk : bb % 2 ^ (8 * t.size) = 2 ^ k)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size) (hoff : offOk sd.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt ba = true)
      (hi2 : binImmXInsnOk Γ i2 "&" t.size false false sd.off tt (2 ^ (8 * t.size)) (2 ^ k - 1)
        = true) :
      LowerDivConst Γ (.assign ⟨d, []⟩ (.binaryOp .rem (.const (.scalar ba) (.int t va))
        (.const (.scalar bb) (.int t vc)))) [i1, i2]

/-! ### The checker -/

/-- `_d = op(const ba : ta, const bb : tc)`'s checker (`ccPow2Div`, `ccPow2Rem`). -/
def divCCVerdict (Γ : StmtCtx) (d : Local) (op : BinOp) (ba : Nat) (ta : IntType) (bb : Nat)
    (tc : IntType) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]?, Γ.slots[d]?, is with
  | some (.int t _), some sd, [i1, i2] =>
    match pow2Of (bb % 2 ^ (8 * t.size)), immSlotOf Γ i1 with
    | some k, some tt =>
      if op = .div then
        okIf (decide (ta = t) && decide (tc = t) && t.signed == false && shiftOk t t &&
          decide (k < 8 * t.size) && sd.size == t.size && offOk sd.off &&
          privOk Γ sd.off sd.size && tempOk Γ tt t.size && immInsnOk Γ i1 t.size tt ba &&
          binImmXInsnOk Γ i2 "wrapping_shr" t.size true false sd.off tt (8 * t.size) k)
          "div const const: form"
      else
        okIf (decide (ta = t) && decide (tc = t) && t.signed == false && sd.size == t.size &&
          offOk sd.off && privOk Γ sd.off sd.size && tempOk Γ tt t.size &&
          immInsnOk Γ i1 t.size tt ba &&
          binImmXInsnOk Γ i2 "&" t.size false false sd.off tt (2 ^ (8 * t.size)) (2 ^ k - 1))
          "rem const const: form"
    | _, _ => .unsupported "div const const: form"
  | _, _, _ => .unsupported "div const const: types, slots or instruction count"

theorem divCCVerdict_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {ba bb : Nat}
    {ta tc : IntType} {va vc : ValidRange} {is : List Insn} (hop : op = .div ∨ op = .rem)
    (h : divCCVerdict Γ d op ba ta bb tc is = .ok) :
    LowerDivConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) (.int ta va))
      (.const (.scalar bb) (.int tc vc)))) is := by
  unfold divCCVerdict at h
  split at h
  next t valid sd i1 i2 htd hsd =>
    split at h
    next k tt hk htt =>
      split at h
      next hd =>
        subst hd
        have hc := okIf_ok h
        simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at hc
        obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩, h11⟩ := hc
        subst h1 h2
        exact .ccPow2Div h3 h4 (pow2Of_spec hk) h5 htd hsd h6 h7 (privOk_spec h8) h9 h10 h11
      next hd =>
        have hr : op = .rem := hop.resolve_left hd
        subst hr
        have hc := okIf_ok h
        simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at hc
        obtain ⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩ := hc
        subst h1 h2
        exact .ccPow2Rem h3 (pow2Of_spec hk) htd hsd h4 h5 (privOk_spec h6) h7 h8 h9
    next => cases h
  next => cases h

/-- `_d = op(oa, const bits : tc)`'s checker, `op` `Div` or `Rem`. -/
def checkDivConstAt (Γ : StmtCtx) (d : Local) (op : BinOp) (oa : Operand) (bits : Nat)
    (tc : IntType) (is : List Insn) : Verdict :=
  match oa.local? with
  | some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]?, Γ.slots[d]?, Γ.slots[a]? with
    | some (.int t valid), some ta, some sd, some sa =>
      if (ta == Ty.int t valid && tc == t && sd.size == t.size && sa.size == t.size &&
          offOk sd.off && offOk sa.off && privOk Γ sd.off sd.size) then
        match is with
        | [i] =>
          match pow2Of (bits % 2 ^ (8 * t.size)) with
          | some k =>
            if op = .div then
              okIf (t.signed == false && shiftOk t t && decide (k < 8 * t.size) &&
                binImmXInsnOk Γ i "wrapping_shr" t.size true false sd.off sa.off (8 * t.size) k)
                "div const: power-of-two form"
            else
              okIf (t.signed == false &&
                binImmXInsnOk Γ i "&" t.size false false sd.off sa.off (2 ^ (8 * t.size))
                  (2 ^ k - 1))
                "rem const: power-of-two form"
          | none => .unsupported "div const: single instruction"
        | [i1, i2] =>
          match immSlotOf Γ i1, binXMethod op with
          | some tt, some m =>
            okIf (shiftOk t t && tempOk Γ tt t.size && immInsnOk Γ i1 t.size tt bits &&
              binXInsnOk Γ i2 m t.size (binXSigned op) t.signed sd.off sa.off tt)
              "div const: temporary form"
          | _, _ => .unsupported "div const: temporary form"
        | _ => .unsupported "div const: instruction count (multiply sequence?)"
      else .unsupported "div const: types or slots"
    | _, _, _, _ => .unsupported "div const: not integers"
  | none =>
    match oa with
    | .const (.scalar ba) (.int ta _) => divCCVerdict Γ d op ba ta bits tc is
    | _ => .unsupported "div const: operand"

theorem checkDivConstAt_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {oa : Operand} {bits : Nat}
    {tc : IntType} {vc : ValidRange} {is : List Insn} (hop : op = .div ∨ op = .rem)
    (h : checkDivConstAt Γ d op oa bits tc is = .ok) :
    LowerDivConst Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc vc)))) is := by
  unfold checkDivConstAt at h
  split at h
  next a ha =>
    split at h
    next t valid ta sd sa htd hta hsd hsa =>
      split at h
      next hc =>
        simp only [Bool.and_eq_true, beq_iff_eq] at hc
        obtain ⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩ := hc
        subst h1 h2
        split at h
        next i =>
          split at h
          next k hk =>
            split at h
            next hd =>
              subst hd
              have hc := okIf_ok h
              simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at hc
              obtain ⟨⟨⟨hs, hmod⟩, hkw⟩, hi⟩ := hc
              exact .pow2Div ha hs hmod (pow2Of_spec hk) hkw htd hta hsd hsa ⟨h3, h4⟩ ⟨h5, h6⟩
                (privOk_spec h7) hi
            next hd =>
              have hr : op = .rem := hop.resolve_left hd
              subst hr
              have hc := okIf_ok h
              simp only [Bool.and_eq_true, beq_iff_eq] at hc
              obtain ⟨hs, hi⟩ := hc
              exact .pow2Rem ha hs (pow2Of_spec hk) htd hta hsd hsa ⟨h3, h4⟩ ⟨h5, h6⟩
                (privOk_spec h7) hi
          next => cases h
        next i1 i2 =>
          split at h
          next tt m htt hm =>
            have hc := okIf_ok h
            simp only [Bool.and_eq_true] at hc
            obtain ⟨⟨⟨hmod, ht⟩, hi1⟩, hi2⟩ := hc
            exact .tempRight hm ha hmod htd hta hsd hsa ⟨h3, h4⟩ ⟨h5, h6⟩ (privOk_spec h7) ht
              hi1 hi2
          next => cases h
        next => cases h
      next => cases h
    next => cases h
  next =>
    split at h
    next ba ta va' => exact divCCVerdict_sound hop h
    next => cases h

/-- Decide `LowerDivConst`: `none` unless `st` assigns a `Div`/`Rem` by an integer constant to a
whole local. -/
def checkDivConst (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc _))) =>
    if op = .div ∨ op = .rem then some (checkDivConstAt Γ d op oa bits tc is) else none
  | _ => none

theorem checkDivConst_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkDivConst Γ st is = some .ok) : LowerDivConst Γ st is := by
  unfold checkDivConst at h
  split at h
  next d op oa bits tc vc =>
    split at h
    next hop => exact checkDivConstAt_sound hop (Option.some.inj h)
    next => cases h
  next => cases h

end Ryo.Check.Lower
