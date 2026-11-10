/-
Ryo.Check.Lower.OvfMore — `Ovf.lean`'s overflow-checked operators on field projections of locals
(aot.md §C1, M5b), and their checker.

As in `BinMore.lean`, an operand reading a sized place inside a local's slot uses that sub-slot
(`PlaceInt`); a constant right operand is materialized into a temporary, as in `OvfConst.lean`.

Rules (`_d` the pair `(t, bool)` as in `Ovf.lean`, `t.wf`):
- `placeOvf`: `_d = op(p, q)`, two operand slots, lowered to `ovf d+ov, d+oo, p, q`.
- `placeOvfImm`: `_d = op(p, const bits : t)`, lowered to `[imm tt, bits; ovf d+ov, d+oo, p, tt]`
  with `tt` a temporary (`tempOk`).

`checkOvfMore` claims these when an operand is projected and is `none` otherwise (whole locals
stay with `Ovf.lean`/`OvfConst.lean`); it must run before `checkOvf`, which claims every
overflow-checked operator.
-/
import Ryo.Check.Lower.Ovf
import Ryo.Check.Lower.BinMore

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerOvfMore (Γ : StmtCtx) : Statement → List Insn → Prop where
  | placeOvf {d : Local} {oa ob : Operand} {op : BinOp} {m : String} {t : IntType}
      {vt : ValidRange} {ov oo : Nat} {head : TupleHeadLayout} {sd : LocalSlot} {xa xb : Int}
      {i : Insn}
      (hm : ovfMethod op = some m) (hwf : t.wf = true)
      (htd : Γ.body.locals[d]? = some (.tuple [(ov, .int t vt), (oo, .bool)] head none))
      (hsd : Γ.slots[d]? = some sd) (hsize : sd.size = head.headSizeAndAlign.1)
      (hlay : ovfLayoutOk sd.size ov oo t.size = true)
      (hoff : offOk (sd.off + ov) = true ∧ offOk (sd.off + oo) = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hA : PlaceInt Γ oa t xa) (hB : PlaceInt Γ ob t xb)
      (hi : ovfInsnOk Γ i m t.size t.signed (sd.off + ov) (sd.off + oo) xa xb = true) :
      LowerOvfMore Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]
  | placeOvfImm {d : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {t : IntType}
      {vt vc : ValidRange} {ov oo : Nat} {head : TupleHeadLayout} {sd : LocalSlot} {xa tt : Int}
      {i1 i2 : Insn}
      (hm : ovfMethod op = some m) (hwf : t.wf = true)
      (htd : Γ.body.locals[d]? = some (.tuple [(ov, .int t vt), (oo, .bool)] head none))
      (hsd : Γ.slots[d]? = some sd) (hsize : sd.size = head.headSizeAndAlign.1)
      (hlay : ovfLayoutOk sd.size ov oo t.size = true)
      (hoff : offOk (sd.off + ov) = true ∧ offOk (sd.off + oo) = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hA : PlaceInt Γ oa t xa)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt bits = true)
      (hi2 : ovfInsnOk Γ i2 m t.size t.signed (sd.off + ov) (sd.off + oo) xa tt = true) :
      LowerOvfMore Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int t vc))))
        [i1, i2]

/-! ### The checker -/

def ovfPlaceOk (Γ : StmtCtx) (d : Local) (m : String) (oa ob : Operand) (i : Insn) : Bool :=
  match Γ.body.locals[d]?, Γ.slots[d]?, placeInt? Γ oa, placeInt? Γ ob with
  | some (.tuple [(ov, .int t _), (oo, .bool)] head none), some sd, some (ta, xa),
      some (tb, xb) =>
    decide (ta = t) && decide (tb = t) && t.wf && sd.size == head.headSizeAndAlign.1 &&
      ovfLayoutOk sd.size ov oo t.size && offOk (sd.off + ov) && offOk (sd.off + oo) &&
      privOk Γ sd.off sd.size &&
      ovfInsnOk Γ i m t.size t.signed (sd.off + ov) (sd.off + oo) xa xb
  | _, _, _, _ => false

theorem ovfPlaceOk_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {m : String} {oa ob : Operand}
    {i : Insn} (hm : ovfMethod op = some m) (h : ovfPlaceOk Γ d m oa ob i = true) :
    LowerOvfMore Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i] := by
  unfold ovfPlaceOk at h
  split at h
  next ov t vt oo head sd ta xa tb xb htd hsd hpa hpb =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩ := h
    subst h1 h2
    exact .placeOvf hm h3 htd hsd h4 h5 ⟨h6, h7⟩ (privOk_spec h8) (placeInt?_spec hpa)
      (placeInt?_spec hpb) h9
  next => cases h

def ovfPlaceImmOk (Γ : StmtCtx) (d : Local) (m : String) (oa : Operand) (bits : Nat)
    (tc : IntType) (i1 i2 : Insn) : Bool :=
  match Γ.body.locals[d]?, Γ.slots[d]?, placeInt? Γ oa, immSlotOf Γ i1 with
  | some (.tuple [(ov, .int t _), (oo, .bool)] head none), some sd, some (ta, xa), some tt =>
    decide (ta = t) && decide (tc = t) && t.wf && sd.size == head.headSizeAndAlign.1 &&
      ovfLayoutOk sd.size ov oo t.size && offOk (sd.off + ov) && offOk (sd.off + oo) &&
      privOk Γ sd.off sd.size && tempOk Γ tt t.size && immInsnOk Γ i1 t.size tt bits &&
      ovfInsnOk Γ i2 m t.size t.signed (sd.off + ov) (sd.off + oo) xa tt
  | _, _, _, _ => false

theorem ovfPlaceImmOk_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {m : String} {oa : Operand}
    {bits : Nat} {tc : IntType} {vc : ValidRange} {i1 i2 : Insn} (hm : ovfMethod op = some m)
    (h : ovfPlaceImmOk Γ d m oa bits tc i1 i2 = true) :
    LowerOvfMore Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc vc))))
      [i1, i2] := by
  unfold ovfPlaceImmOk at h
  split at h
  next ov t vt oo head sd ta xa tt htd hsd hpa htt =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩, h11⟩ := h
    subst h1 h2
    exact .placeOvfImm hm h3 htd hsd h4 h5 ⟨h6, h7⟩ (privOk_spec h8) (placeInt?_spec hpa) h9
      h10 h11
  next => cases h

/-- Decide `LowerOvfMore` (see the module comment for what it claims). -/
def checkOvfMore (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc _))) =>
    if hasProj oa then
      match ovfMethod op with
      | some m => some (match is with
        | [i1, i2] => okIf (ovfPlaceImmOk Γ d m oa bits tc i1 i2) "ovf place imm: form"
        | _ => .unsupported "ovf place imm: instruction count")
      | none => none
    else none
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    if hasProj oa || hasProj ob then
      match ovfMethod op with
      | some m => some (match is with
        | [i] => okIf (ovfPlaceOk Γ d m oa ob i) "ovf place: form"
        | _ => .unsupported "ovf place: instruction count")
      | none => none
    else none
  | _ => none

theorem checkOvfMore_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkOvfMore Γ st is = some .ok) : LowerOvfMore Γ st is := by
  unfold checkOvfMore at h
  split at h
  · split at h
    · split at h
      next m hm =>
        have h' := Option.some.inj h
        split at h'
        · exact ovfPlaceImmOk_sound hm (okIf_ok h')
        · cases h'
      · cases h
    · cases h
  · split at h
    · split at h
      next m hm =>
        have h' := Option.some.inj h
        split at h'
        · exact ovfPlaceOk_sound hm (okIf_ok h')
        · cases h'
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
