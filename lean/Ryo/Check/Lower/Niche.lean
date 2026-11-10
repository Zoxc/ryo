/-
Ryo.Check.Lower.Niche — the rule of a fused niche-discriminant switch (aot.md §C1, M5b): a block
whose last statement `_d = discriminant(_e)` reads a niche-encoded enum and feeds its
`switchInt(_d)`, the two lowered together over the terminator's range (`Fused::Discr`,
`FnCx::switch_niche`, `backend/src/lower/terminator.rs`): the backend tests the tag instead of
decoding it. With up to four tested arms that is a chain of `br.eq.imm` on the tag's bytes
(`_e`'s slot at the tag offset), each to the target of one niche variant's tag, then a goto to
the untagged variant's target (or, the last arm falling through, a `br.eq.imm` with `neg` to
it). The certificate marks the block `fused` (`BlockCert`), as for fused compares
(`Fused.lean`).

`LowerNicheSwitch Γ next st term is`: `st = _d = discriminant(_e)`, `_e` a `.multiple tag`
enum, `_d` an integer of type `t`, `term = switchInt(_d) cases otherwise`, and `is` checked by
`nicheChain` against L0's target for each tag value `u` (`NicheHit`, decided by `startOk`):
L0 decodes `u` to a variant `idx` (`tagToVariant`), stores its discriminant at `t` and the
switch goes to `caseTarget cases otherwise (nicheBits vs discrTy t idx)`, whose start R must
reach. `nicheChain` walks the tests with the tag values already tested unequal (`ex`), as
`Switch.lean`'s `chainOk`: a tested value's variant is computed by `tagToVariant` itself
(`nicheAt`); the place the chain ends at must be right for every value not tested
(`nicheRest`): the untagged variant's target, and for each variant `idx` below `lo + (hi - lo)
+ 1` (the niche variants), unless its tag (`tagForVariant`) was tested, its target. A value
decoding to a niche variant is that variant's tag (`tagForVariant_of_tagToVariant`), so these
cover every value L0 decodes.

R never writes `_d`'s slot, so (as for fused compares) `_d` must be dead at every successor
(`hdead`) and its slot private (`hpriv`). The simulation is `Proofs/Lower/SimNiche.lean`.

Not covered: more than four arms (`switch.dense` on `tag - niche_start` after a range check),
a niche discriminant read on its own (`niche_discr`, Enum.lean's bucket), projected places, a
target reached only through an unreachable `otherwise` (the fused simulation's conclusion has
no dead end).
-/
import Ryo.Check.Lower.TermExt
import Ryo.Check.Lower.Live

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The switch value L0 computes from variant `idx`: its discriminant brought into `discrTy`
then `t`, stored and read back at `t` (`readDiscriminant`, `discriminant`, `switchBits`). -/
def nicheBits (vs : List Variant) (discrTy t : IntType) (idx : Nat) : Nat :=
  t.toBits (t.bringInBounds (discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0))) %
    2 ^ (8 * t.size)

/-- R index `pc` is the start of L0's target for switch value `x`. -/
def startOk (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
    (x pc : Nat) : Bool :=
  blockStart Γ (caseTarget cases otherwise x) == some pc

/-- `pc` is right for tag value `u` (nothing is needed when L0 rejects `u`). -/
def nicheAt (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
    (vs : List Variant) (discrTy : IntType) (tag : TagInfo) (t : IntType) (u pc : Nat) : Bool :=
  match tagToVariant vs discrTy tag u with
  | .ok idx => startOk Γ cases otherwise (nicheBits vs discrTy t idx) pc
  | .error _ => true

/-- `pc` is right for every tag value outside `ex` (see the module comment). -/
def nicheRest (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
    (vs : List Variant) (discrTy : IntType) (tag : TagInfo) (t : IntType) (ex : List Nat)
    (pc : Nat) : Bool :=
  match tag.encoding with
  | .niche untagged lo hi _st =>
    startOk Γ cases otherwise (nicheBits vs discrTy t untagged) pc &&
      (List.range (lo + (hi - lo) + 1)).all fun idx =>
        match tagForVariant vs tag idx with
        | some tv => ex.contains tv || startOk Γ cases otherwise (nicheBits vs discrTy t idx) pc
        | none => startOk Γ cases otherwise (nicheBits vs discrTy t idx) pc
  | .direct => false

/-- A chain of `br.eq.imm` tests on the tag's bytes at slot `a`, ending in a goto, the values in
`ex` already tested unequal (see the module comment). -/
def nicheChain (Γ : TermCtx) (next : Nat) (cases : List (Nat × BasicBlock))
    (otherwise : BasicBlock) (vs : List Variant) (discrTy : IntType) (tag : TagInfo)
    (t : IntType) (a : Int) : List Nat → List Insn → Bool
  | ex, [] => nicheRest Γ cases otherwise vs discrTy tag t ex next
  | ex, i :: tl =>
    match brImmOps Γ.toStmtCtx i tag.tag.size with
    | some (a', y, neg, tg) =>
      let yv := y % 2 ^ (8 * tag.tag.size)
      a' == a &&
        (if neg then
          tl.isEmpty && (ex.contains yv || nicheAt Γ cases otherwise vs discrTy tag t yv next) &&
            nicheRest Γ cases otherwise vs discrTy tag t (yv :: ex) tg
        else
          (ex.contains yv || nicheAt Γ cases otherwise vs discrTy tag t yv tg) &&
            nicheChain Γ next cases otherwise vs discrTy tag t a (yv :: ex) tl)
    | none =>
      match jmpTo i, tl with
      | some tg, [] => nicheRest Γ cases otherwise vs discrTy tag t ex tg
      | _, _ => false

inductive LowerNicheSwitch (Γ : TermCtx) (next : Nat) :
    Statement → Terminator → List Insn → Prop where
  | chain (dl e : Local) (od : Operand) (vs : List Variant) (discrTy : IntType) (tag : TagInfo)
      (esz : Size) (eal : Align) (t : IntType) (vd : ValidRange) (sd se : LocalSlot)
      (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock) (is : List Insn)
      (hd : od.local? = some dl)
      (hte : Γ.body.locals[e]? = some (.enum vs discrTy (.multiple tag) esz eal))
      (htd : Γ.body.locals[dl]? = some (.int t vd))
      (hsd : Γ.slots[dl]? = some sd) (hse : Γ.slots[e]? = some se)
      (hsize : 0 < sd.size ∧ 0 < tag.tag.size ∧ tag.offset + tag.tag.size ≤ se.size)
      (hoff : offOk se.off = true ∧ offOk (se.off + tag.offset) = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hok : nicheChain Γ next cases otherwise vs discrTy tag t (se.off + tag.offset) [] is =
        true)
      (hdead : (termSuccs (.switchInt od cases otherwise)).all
        (fun b => !(computeLive Γ.body).get b 0 dl) = true) :
      LowerNicheSwitch Γ next (.assign ⟨dl, []⟩ (.discriminant ⟨e, []⟩))
        (.switchInt od cases otherwise) is

/-- A fused block's last statement and terminator, when the statement is a discriminant read
(`checkFused`'s niche bucket). -/
def checkNicheFused (Γ : TermCtx) (next : Nat) (st : Statement) (term : Terminator)
    (is : List Insn) : Verdict :=
  match st, term with
  | .assign ⟨dl, []⟩ (.discriminant ⟨e, []⟩), .switchInt od cases otherwise =>
    match od.local?, Γ.body.locals[e]?, Γ.body.locals[dl]?, Γ.slots[dl]?, Γ.slots[e]? with
    | some dl', some (.enum vs discrTy (.multiple tag) esz eal), some (.int t vd), some sd,
        some se =>
      if dl' = dl ∧ 0 < sd.size ∧ 0 < tag.tag.size ∧ tag.offset + tag.tag.size ≤ se.size ∧
          offOk se.off = true ∧ offOk (se.off + tag.offset) = true ∧
          privOk Γ.toStmtCtx sd.off sd.size = true ∧
          (termSuccs (.switchInt od cases otherwise)).all
            (fun b => !(computeLive Γ.body).get b 0 dl) = true then
        okIf (nicheChain Γ next cases otherwise vs discrTy tag t (se.off + tag.offset) [] is)
          "fused: niche discriminant, form"
      else .unsupported "fused: niche discriminant, slots"
    | _, _, _, _, _ => .unsupported "fused: niche discriminant, types"
  | _, _ => .unsupported "fused: niche discriminant"

theorem checkNicheFused_sound {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (h : checkNicheFused Γ next st term is = .ok) :
    LowerNicheSwitch Γ next st term is := by
  unfold checkNicheFused at h
  split at h
  next dl e od cs ow =>
    split at h
    next dl' vs discrTy tag esz eal t vd sd se hod hte htd hsd hse =>
      split at h
      next hc =>
        obtain ⟨hdl, h1, h2, h3, h4, h5, h6, h7⟩ := hc
        rw [hdl] at hod
        exact .chain dl e od vs discrTy tag esz eal t vd sd se cs ow is hod hte htd hsd hse
          ⟨h1, h2, h3⟩ ⟨h4, h5⟩ (privOk_spec h6) (okIf_ok h) h7
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
