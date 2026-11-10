/-
Ryo.Check.Lower.NicheDense — the dense form of a fused niche-discriminant switch (aot.md §C1,
M5b), next to `Niche.lean`'s `br.eq.imm` chain: with more than four tested arms
`FnCx::switch_niche` (`backend/src/lower/terminator.rs`) emits

    sub.imm r, t, niche_start        -- r = tag - niche_start (a frame temporary)
    br.gt.u.imm r, hi - lo, untagged -- past the niche range: the untagged variant
    switch.dense r, 0, untagged, [target(lo), …, target(hi)]

`LowerNicheDense Γ next st term is`: `st = _d = discriminant(_e)` and `term = switchInt(_d)`
as in `Niche.lean` (`_d` dead at every successor, its slot private), `is = [i1, i2, i3]` those
three instructions (`nicheDenseOk`), the temporary `r` private and meeting no local's slot,
`hi - lo` below the tag's modulus. For the tag value `u`, `r` is `tagToVariant`'s relative
value `rel` (the tag minus `niche_start`); `rel > hi - lo` decodes to the untagged variant, whose
target must start at the branch's target; `rel = k ≤ hi - lo` to variant `lo + k` (unless that
is the untagged one, which L0 rejects), whose target must start at the table's entry `k`
(`denseArmsOk`).

`brCmpImmOpsN` is `Fused.lean`'s `brCmpImmOps` (this file comes before `Fused.lean`, which
imports it for `LowerFused.nicheDense`). The simulation is `Proofs/Lower/SimNicheDense.lean`.
-/
import Ryo.Check.Lower.Niche
import Ryo.Check.Lower.SwitchStatic
import Ryo.Check.Lower.NicheRead

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- `Fused.lean`'s `brCmpImmOps`: a `br_cmp_imm` at `n` bytes (signedness `sg` for an order
operator): its operator, slot `a`, immediate `y`, `neg` and target `t`. -/
def brCmpImmOpsN (Γ : StmtCtx) (i : Insn) (n : Nat) (sg : Bool) :
    Option (String × Int × Nat × Bool × Nat) :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler?, v.ops, v.ctl with
    | some ⟨.br_cmp_imm, [ty, o], _⟩, [.slot a, .imm y, .none, .none], some (.branch neg t) =>
      if cmpTyOk ty o n sg && v.op.info.operands.map (·.name) == ["a", "imm", "neg", "t"] &&
          v.op.info.operands.head?.map (·.kind) == some .slot then
        some (o, a, y, neg, t)
      else none
    | _, _, _ => none
  | none => none

/-- Each tested arm `k ≤ hi - lo`: variant `lo + k`'s target starts at the table's entry `k`. -/
def denseArmsOk (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
    (vs : List Variant) (discrTy t : IntType) (untagged lo hi : Nat) (ts : List Nat) : Bool :=
  (List.range (hi - lo + 1)).all fun k =>
    lo + k == untagged ||
      match ts[k]? with
      | some p => startOk Γ cases otherwise (nicheBits vs discrTy t (lo + k)) p
      | none => false

/-- The three instructions and the arms (see the module comment). -/
def nicheDenseOk (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
    (vs : List Variant) (discrTy t : IntType) (tag : TagInfo) (untagged lo hi ns : Nat)
    (a : Int) (i1 i2 i3 : Insn) : Bool :=
  match dstSlot Γ.toStmtCtx i1 with
  | none => false
  | some r =>
    match brCmpImmOpsN Γ.toStmtCtx i2 tag.tag.size false, denseOps Γ.toStmtCtx i3 tag.tag.size with
    | some (o, r2, y, neg, tg), some (r3, base, len, ts) =>
      offOk r && privOk Γ.toStmtCtx r tag.tag.size && tempApart Γ.slots r tag.tag.size &&
        binImmInsnOk Γ.toStmtCtx i1 "wrapping_sub" tag.tag.size r a ns &&
        o == ">" && r2 == r && neg == false &&
        y % 2 ^ (8 * tag.tag.size) == (hi - lo) % 2 ^ (8 * tag.tag.size) &&
        decide (hi - lo < tag.tag.modulus) &&
        r3 == r && base % 2 ^ (8 * tag.tag.size) == 0 && len == hi - lo + 1 &&
        startOk Γ cases otherwise (nicheBits vs discrTy t untagged) tg &&
        denseArmsOk Γ cases otherwise vs discrTy t untagged lo hi ts
    | _, _ => false

inductive LowerNicheDense (Γ : TermCtx) (next : Nat) :
    Statement → Terminator → List Insn → Prop where
  | mk (dl e : Local) (od : Operand) (vs : List Variant) (discrTy : IntType) (tag : TagInfo)
      (esz : Size) (eal : Align) (t : IntType) (vd : ValidRange) (sd se : LocalSlot)
      (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock) (untagged lo hi ns : Nat)
      (i1 i2 i3 : Insn)
      (hd : od.local? = some dl)
      (hte : Γ.body.locals[e]? = some (.enum vs discrTy (.multiple tag) esz eal))
      (htd : Γ.body.locals[dl]? = some (.int t vd))
      (hsd : Γ.slots[dl]? = some sd) (hse : Γ.slots[e]? = some se)
      (henc : tag.encoding = .niche untagged lo hi ns)
      (hsize : 0 < sd.size ∧ 0 < tag.tag.size ∧ tag.offset + tag.tag.size ≤ se.size)
      (hoff : offOk se.off = true ∧ offOk (se.off + tag.offset) = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hok : nicheDenseOk Γ cases otherwise vs discrTy t tag untagged lo hi ns
        (se.off + tag.offset) i1 i2 i3 = true)
      (hdead : (termSuccs (.switchInt od cases otherwise)).all
        (fun b => !(computeLive Γ.body).get b 0 dl) = true) :
      LowerNicheDense Γ next (.assign ⟨dl, []⟩ (.discriminant ⟨e, []⟩))
        (.switchInt od cases otherwise) [i1, i2, i3]

/-- The dense form's checker (`checkFused`'s niche bucket, after `checkNicheFused`). -/
def checkNicheDense (Γ : TermCtx) (st : Statement) (term : Terminator) (is : List Insn) :
    Verdict :=
  match st, term, is with
  | .assign ⟨dl, []⟩ (.discriminant ⟨e, []⟩), .switchInt od cases otherwise, [i1, i2, i3] =>
    match od.local?, Γ.body.locals[e]?, Γ.body.locals[dl]?, Γ.slots[dl]?, Γ.slots[e]? with
    | some dl', some (.enum vs discrTy (.multiple tag) esz eal), some (.int t vd), some sd,
        some se =>
      match tag.encoding with
      | .niche untagged lo hi ns =>
        if dl' = dl ∧ 0 < sd.size ∧ 0 < tag.tag.size ∧ tag.offset + tag.tag.size ≤ se.size ∧
            offOk se.off = true ∧ offOk (se.off + tag.offset) = true ∧
            privOk Γ.toStmtCtx sd.off sd.size = true ∧
            (termSuccs (.switchInt od cases otherwise)).all
              (fun b => !(computeLive Γ.body).get b 0 dl) = true then
          okIf (nicheDenseOk Γ cases otherwise vs discrTy t tag untagged lo hi ns
            (se.off + tag.offset) i1 i2 i3) "fused: niche discriminant, dense form"
        else .unsupported "fused: niche discriminant, slots"
      | .direct => .unsupported "fused: niche discriminant, types"
    | _, _, _, _, _ => .unsupported "fused: niche discriminant, types"
  | _, _, _ => .unsupported "fused: niche discriminant, form"

theorem checkNicheDense_sound {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (h : checkNicheDense Γ st term is = .ok) :
    LowerNicheDense Γ next st term is := by
  unfold checkNicheDense at h
  split at h
  next dl e od cs ow i1 i2 i3 =>
    split at h
    next dl' vs discrTy tag esz eal t vd sd se hod hte htd hsd hse =>
      split at h
      next untagged lo hi ns henc =>
        split at h
        next hc =>
          obtain ⟨hdl, h1, h2, h3, h4, h5, h6, h7⟩ := hc
          rw [hdl] at hod
          exact .mk dl e od vs discrTy tag esz eal t vd sd se cs ow untagged lo hi ns i1 i2 i3
            hod hte htd hsd hse henc ⟨h1, h2, h3⟩ ⟨h4, h5⟩ (privOk_spec h6) (okIf_ok h) h7
        next => cases h
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
