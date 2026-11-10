/-
Ryo.Check.Lower.CmpConst — comparisons whose left operand is a scalar constant (aot.md §C1, M5b),
and their checker.

What the backend emits (`backend/src/lower/binop.rs` `compare`, `operand.rs` `operand_slot`): a
constant left operand has no slot, so `operand_slot` materializes it into a fresh temporary `t`
(`temp_for`: above every local's slot, `frame.rs` `temp`) by `operand_into`, one `imm` of the
constant's width. Then:
- a constant right operand (`const_int`): one `cmp_imm d, t, imm` (`Cmp.lean`'s `imm` form);
- a local right operand `_b`: one `cmp d, x, y` (`Cmp.lean`'s `reg` form, `gt`/`ge` swapped)
  with `t` for the left operand.

The temporary is no local's: R's write of it leaves every local's relation, and the memory, as
they were (`Ryo.Proofs.Lower.FnRel.tempWrite`), so the first instruction simulates no L0 step,
and the second is the comparison read from `t` (`Ryo/Proofs/Lower/SimCmpConst.lean`).

Rules (`op` a comparison, `_d : bool` with a 1-byte slot, private or escaped; the temporary `t`
of `n` bytes, its offsets in range and apart from every local's slot: `tempApartC`, which, unlike
`tempOk`, does not ask that no `Escape` of the function covers `t`: the backend's temporaries
are reused, and one escaped elsewhere in the function may cover `t`; at the statement R's escaped
bytes all lie in local slots (`FnRelX.objs`; none at all without scopes), so `t`'s are private
anyway, `Proofs/Lower/SimCmpConst.lean`'s `EscInSlots`):
- `constImm`: `_d = op(const ba : tc, const bb : tc')`, `tc` a comparison type of `n` bytes,
  `tc'` the same (`cmpConstTy`), lowered to `[imm t ba, cmp_imm d t bb]`.
- `constReg`: `_d = op(const ba : tc, _b)`, `_b : ty` a comparison type of `n` bytes and `tc`
  the same, lowered to `[imm t ba, cmp d x y]` with `cmpRegForm`'s operands for `(t, _b)`.

`checkCmpConst` claims every comparison with a scalar constant on the left and is `none`
otherwise; it must run before `checkCmp`, which reports them as `cmp imm: operand` and
`cmp: operands`. The temporary's offset is read off the `imm` instruction (untrusted guess,
then checked).
-/
import Ryo.Check.Lower.CmpX

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- A temporary of `n` bytes at `t`: offsets in range, never escaped, apart from every local's
slot. -/
def tempOk (Γ : StmtCtx) (t : Int) (n : Nat) : Bool :=
  offOk t && offOk (t + n) && privOk Γ t n &&
    Γ.slots.all fun sl => decide (t + n ≤ sl.off) || decide (sl.off + sl.size ≤ t)

theorem tempOk_spec {Γ : StmtCtx} {t : Int} {n : Nat} (h : tempOk Γ t n = true) :
    offOk t = true ∧ offOk (t + n) = true ∧ (∀ k < n, Γ.escaped (t + k) = false) ∧
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        t + n ≤ sl.off ∨ sl.off + sl.size ≤ t := by
  unfold tempOk at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := h
  refine ⟨h1, h2, privOk_spec h3, fun l sl hsl => ?_⟩
  have hm := Array.mem_of_getElem? hsl
  have := Array.all_eq_true_iff_forall_mem.mp h4 sl hm
  simpa using this

/-- `tempOk` without the `Escape` condition (see the module comment). -/
def tempApartC (Γ : StmtCtx) (t : Int) (n : Nat) : Bool :=
  offOk t && offOk (t + n) &&
    Γ.slots.all fun sl => decide (t + n ≤ sl.off) || decide (sl.off + sl.size ≤ t)

theorem tempApartC_spec {Γ : StmtCtx} {t : Int} {n : Nat} (h : tempApartC Γ t n = true) :
    offOk t = true ∧ offOk (t + n) = true ∧
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        t + n ≤ sl.off ∨ sl.off + sl.size ≤ t := by
  unfold tempApartC at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨⟨h1, h2⟩, h4⟩ := h
  refine ⟨h1, h2, fun l sl hsl => ?_⟩
  have hm := Array.mem_of_getElem? hsl
  have := Array.all_eq_true_iff_forall_mem.mp h4 sl hm
  simpa using this

/-- The slot an `imm` instruction writes, if `i` is one (untrusted). -/
def immSlotOf (Γ : StmtCtx) (i : Insn) : Option Int :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.ops with
    | [.slot t, .imm _] => some t
    | _ => none
  | none => none

inductive LowerCmpConst (Γ : StmtCtx) : Statement → List Insn → Prop where
  | constImm {d : Local} {op : BinOp} {o : String} {ba bb : Nat} {tc tc' : Ty} {n : Nat}
      {sg : Bool} {sd : LocalSlot} {t : Int} {i1 i2 : Insn}
      (ho : cmpOp op = some o) (htd : Γ.body.locals[d]? = some .bool)
      (hty : cmpOpnd tc = some (n, sg)) (hc : cmpConstTy tc' tc = true)
      (hsd : Γ.slots[d]? = some sd) (hsize : sd.size = 1) (hoff : offOk sd.off)
      (ht : tempApartC Γ t n = true)
      (hi1 : immInsnOk Γ i1 n t ba = true)
      (hi2 : cmpImmInsnOk Γ i2 o n sg sd.off t bb = true) :
      LowerCmpConst Γ (.assign ⟨d, []⟩
        (.binaryOp op (.const (.scalar ba) tc) (.const (.scalar bb) tc'))) [i1, i2]
  | constReg {d b : Local} {ob : Operand} {op : BinOp} {o : String} {sw : Bool} {ba : Nat}
      {tc ty : Ty} {n : Nat} {sg : Bool} {sd sb : LocalSlot} {t : Int} {i1 i2 : Insn}
      (hf : cmpRegForm op = some (o, sw)) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some .bool) (htb : Γ.body.locals[b]? = some ty)
      (hty : cmpOpnd ty = some (n, sg)) (hc : cmpConstTy tc ty = true)
      (hsd : Γ.slots[d]? = some sd) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = 1 ∧ sb.size = n) (hoff : offOk sd.off ∧ offOk sb.off)
      (ht : tempApartC Γ t n = true)
      (hi1 : immInsnOk Γ i1 n t ba = true)
      (hi2 : cmpInsnOk Γ i2 o n sg sd.off (if sw then sb.off else t)
        (if sw then t else sb.off) = true) :
      LowerCmpConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) tc) ob)) [i1, i2]

/-- `constImm`'s checker. -/
def checkCmpConstImm (Γ : StmtCtx) (d : Local) (o : String) (ba bb : Nat) (tc tc' : Ty)
    (is : List Insn) : Verdict :=
  match cmpOpnd tc with
  | none => .unsupported "cmp const: operand type"
  | some (n, sg) =>
    if !cmpConstTy tc' tc then .unsupported "cmp const: mixed types"
    else match Γ.body.locals[d]?, Γ.slots[d]?, is with
      | some .bool, some sd, [i1, i2] =>
        match immSlotOf Γ i1 with
        | none => .unsupported "cmp const: materialization"
        | some t =>
          if sd.size != 1 then .rejected "cmp const: slot size"
          else if !offOk sd.off then .rejected "cmp const: offsets"
          else if !tempApartC Γ t n then .unsupported "cmp const: temporary"
          else if !immInsnOk Γ i1 n t ba then .unsupported "cmp const: materialization form"
          else if cmpImmInsnOk Γ i2 o n sg sd.off t bb then .ok
          else .unsupported "cmp const: instruction form"
      | _, _, _ => .unsupported "cmp const: destination or instruction count"

/-- `constReg`'s checker. -/
def checkCmpConstReg (Γ : StmtCtx) (d : Local) (o : String) (sw : Bool) (ba : Nat) (tc : Ty)
    (ob : Operand) (is : List Insn) : Verdict :=
  match ob.local? with
  | none => .unsupported "cmp const: right operand"
  | some b =>
    match Γ.body.locals[b]? with
    | none => .rejected "cmp const: operand local"
    | some ty =>
      match cmpOpnd ty with
      | none => .unsupported "cmp const: operand type"
      | some (n, sg) =>
        if !cmpConstTy tc ty then .unsupported "cmp const: mixed types"
        else match Γ.body.locals[d]?, Γ.slots[d]?, Γ.slots[b]?, is with
          | some .bool, some sd, some sb, [i1, i2] =>
            match immSlotOf Γ i1 with
            | none => .unsupported "cmp const: materialization"
            | some t =>
              if !(sd.size == 1 && sb.size == n) then .rejected "cmp const: slot sizes"
              else if !(offOk sd.off && offOk sb.off) then .rejected "cmp const: offsets"
              else if !tempApartC Γ t n then .unsupported "cmp const: temporary"
              else if !immInsnOk Γ i1 n t ba then .unsupported "cmp const: materialization form"
              else if cmpSwOk Γ i2 o n sg sw sd.off t sb.off then .ok
              else .unsupported "cmp const: instruction form"
          | _, _, _, _ => .unsupported "cmp const: destination, slots or instruction count"

/-- The family's checker: `none` unless `st` is a comparison with a scalar constant on the
left. -/
def checkCmpConst (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) tc) (.const (.scalar bb) tc')) =>
    match cmpOp op with
    | some o => some (checkCmpConstImm Γ d o ba bb tc tc' is)
    | none => none
  | .assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) tc) ob) =>
    match cmpRegForm op with
    | some (o, sw) => some (checkCmpConstReg Γ d o sw ba tc ob is)
    | none => none
  | _ => none

theorem checkCmpConstImm_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {o : String}
    {ba bb : Nat} {tc tc' : Ty} {is : List Insn} (ho : cmpOp op = some o)
    (h : checkCmpConstImm Γ d o ba bb tc tc' is = .ok) :
    LowerCmpConst Γ (.assign ⟨d, []⟩
      (.binaryOp op (.const (.scalar ba) tc) (.const (.scalar bb) tc'))) is := by
  unfold checkCmpConstImm at h
  split at h
  · cases h
  next n sg hty =>
    split at h
    · cases h
    next hc =>
      split at h
      next sd i1 i2 htd hsd =>
        split at h
        · cases h
        next t =>
          split at h
          · cases h
          next hsz =>
            split at h
            · cases h
            next hoff =>
              split at h
              · cases h
              next ht =>
                split at h
                · cases h
                next hi1 =>
                  split at h
                  next hi2 =>
                    exact .constImm ho htd hty (by simpa using hc) hsd (by simpa using hsz)
                      (by simpa using hoff) (by simpa using ht) (by simpa using hi1) hi2
                  · cases h
      · cases h

theorem checkCmpConstReg_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {o : String}
    {sw : Bool} {ba : Nat} {tc : Ty} {ob : Operand} {is : List Insn}
    (hf : cmpRegForm op = some (o, sw)) (h : checkCmpConstReg Γ d o sw ba tc ob is = .ok) :
    LowerCmpConst Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) tc) ob)) is := by
  unfold checkCmpConstReg at h
  split at h
  · cases h
  next b hb =>
    split at h
    · cases h
    next ty htb =>
      split at h
      · cases h
      next n sg hty =>
        split at h
        · cases h
        next hc =>
          split at h
          next sd sb i1 i2 htd hsd hsb =>
            split at h
            · cases h
            next t =>
              split at h
              · cases h
              next hsz =>
                split at h
                · cases h
                next hoff =>
                  split at h
                  · cases h
                  next ht =>
                    split at h
                    · cases h
                    next hi1 =>
                      split at h
                      next hi2 =>
                        exact .constReg hf hb htd htb hty (by simpa using hc) hsd hsb
                          (by simpa using hsz) (by simpa using hoff) (by simpa using ht)
                          (by simpa using hi1) hi2
                      · cases h
          · cases h

theorem checkCmpConst_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkCmpConst Γ st is = some .ok) : LowerCmpConst Γ st is := by
  unfold checkCmpConst at h
  split at h
  next d op ba tc bb tc' =>
    split at h
    next o ho => exact checkCmpConstImm_sound ho (Option.some.inj h)
    · cases h
  next d op ba tc ob =>
    split at h
    next o sw hf => exact checkCmpConstReg_sound hf (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
