/-
Ryo.Proofs.Lower.FnStep — one L0 step of a function `LowersFn` accepts, and runs of them
(aot.md §C1): `stmt_sim` dispatches a statement's `LowerStmtX` to `stmt_sim_base` (FnSim.lean)
or to the family's lift (`SimCopy`, `SimIntCast`, `SimUnop`, `SimField`, `SimCmp`, `SimAgg`,
`SimDeref`); every family's rule is an assignment to a whole local, lowered to one instruction but
for `Agg`'s, whose run over the statement's range closes with `stmtOut_of_liftN`, and `Deref`'s
`store`, an assignment to a projected place (one instruction, no local killed). The deref rules
take `DerefInv` of L0's memory (`MatchAt.dinv`), which every statement keeps (`StmtOut`).
A terminator's `LowerTermX` goes to `sim_term` or `sim_switch` (`SimSwitch`), whose dead end
(`DeadAt`) ends the run, a `return` to `sim_retX` (`SimRetX`). The step and run theorems over
all of a block's shapes (fused compares included) are `FnEntry.lean`'s
`fn_step_sim_ret`/`fn_sim_ret`.
-/
import Ryo.Proofs.Lower.SimCopy
import Ryo.Proofs.Lower.SimIntCast
import Ryo.Proofs.Lower.SimUnop
import Ryo.Proofs.Lower.SimField
import Ryo.Proofs.Lower.SimCmp
import Ryo.Proofs.Lower.SimAgg
import Ryo.Proofs.Lower.SimWide
import Ryo.Proofs.Lower.SimEnum
import Ryo.Proofs.Lower.SimSwitch
import Ryo.Proofs.Lower.SimSwitchStatic
import Ryo.Proofs.Lower.SimTermMore
import Ryo.Proofs.Lower.SimRetX
import Ryo.Proofs.Lower.SimDeref
import Ryo.Proofs.Lower.SimRefDeref
import Ryo.Proofs.Lower.SimIntrinsic
import Ryo.Proofs.Lower.SimBinX
import Ryo.Proofs.Lower.SimOffset
import Ryo.Proofs.Lower.SimOvf
import Ryo.Proofs.Lower.SimOvfConst
import Ryo.Proofs.Lower.SimNicheRead
import Ryo.Proofs.Lower.SimDivConst
import Ryo.Proofs.Lower.SimBinMore
import Ryo.Proofs.Lower.SimOvfMore
import Ryo.Proofs.Lower.SimBinFloatConst
import Ryo.Proofs.Lower.SimRawPtrAgg
import Ryo.Proofs.Lower.SimUnionAgg
import Ryo.Proofs.Lower.SimZstRead
import Ryo.Proofs.Lower.SimStoreTemp
import Ryo.Proofs.Lower.SimSplitRead
import Ryo.Proofs.Lower.SimDiscrPlace
import Ryo.Proofs.Lower.SimFieldWrite
import Ryo.Proofs.Lower.SimFieldCopyN
import Ryo.Proofs.Lower.SimStmtEsc
import Ryo.Proofs.Lower.SimDerefWide
import Ryo.Proofs.Lower.SimCmpFloat
import Ryo.Proofs.Lower.SimDerefZst
import Ryo.Proofs.Lower.SimRefDerefIdx
import Ryo.Proofs.Lower.SimRefDerefDown
import Ryo.Proofs.Lower.SimDerefStoreF
import Ryo.Proofs.Lower.SimRefDerefWideE
import Ryo.Proofs.Lower.SimAggDst
import Ryo.Proofs.Lower.SimUnionAggDst
import Ryo.Proofs.Lower.SimCmpX
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Proofs.Lower.SimBoolBin
import Ryo.Proofs.Lower.SimDerefCast
import Ryo.Proofs.Lower.SimCopyNO
import Ryo.Proofs.Lower.SimOffsetConst
import Ryo.Proofs.Lower.SimBinXConst
import Ryo.Proofs.Lower.SimRefDerefWide
import Ryo.Proofs.Lower.SimCastMore
import Ryo.Proofs.Lower.SimDst
import Ryo.Proofs.Lower.SimDerefSplit
import Ryo.Proofs.Lower.SimBinFloat
import Ryo.Proofs.Lower.SimFloatCast

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- A family rule's statement and range: an assignment to a whole local, one instruction. -/
theorem family_shape {Γ : StmtCtx} {st : Statement} {is : List R.Insn}
    (h : LowerCopy Γ st is ∨ LowerIntCast Γ st is ∨ LowerUnop Γ st is ∨ LowerField Γ st is ∨
      LowerCmp Γ st is ∨ LowerWide Γ st is ∨ LowerBinX Γ st is ∨ LowerOffset Γ st is ∨ LowerOvf Γ st is ∨
      (LowerDeref Γ st is ∧ ∃ d rv, st = .assign ⟨d, []⟩ rv)) :
    ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ is = [i] := by
  rcases h with h | h | h | h | h | h | h | h | h | ⟨h, d, rv, rfl⟩
  all_goals first
    | (cases h <;> exact ⟨_, _, _, rfl, rfl⟩)
    | (cases h; exact ⟨_, _, _, rfl, rfl⟩)

/-- One statement, from `MatchAt` before it. -/
theorem stmt_sim {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    (hpick : PicksAt Γ o ch s s1.fp)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hlow : LowerStmtX Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  have fam : LowerCopy Γ.toStmtCtx st (rangeInsns c.d r) ∨
      LowerIntCast Γ.toStmtCtx st (rangeInsns c.d r) ∨ LowerUnop Γ.toStmtCtx st (rangeInsns c.d r) ∨
      LowerField Γ.toStmtCtx st (rangeInsns c.d r) ∨ LowerCmp Γ.toStmtCtx st (rangeInsns c.d r) ∨
      LowerWide Γ.toStmtCtx st (rangeInsns c.d r) ∨ LowerBinX Γ.toStmtCtx st (rangeInsns c.d r) ∨
      LowerOffset Γ.toStmtCtx st (rangeInsns c.d r) ∨ LowerOvf Γ.toStmtCtx st (rangeInsns c.d r) ∨
      (LowerDeref Γ.toStmtCtx st (rangeInsns c.d r) ∧ ∃ d rv, st = .assign ⟨d, []⟩ rv) →
      StmtOut Γ c ch ι f rest r s s1x s1 := by
    intro hf
    obtain ⟨d, rv, i, rfl, hR⟩ := family_shape hf
    have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
    have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
    have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
    have hbody : Γ.toStmtCtx.body = f.body := M.body.symm
    have hmode' : Γ.toStmtCtx.mode = c.mode := hmode.symm
    have hρ' : Γ.toStmtCtx.ρ = c.ρ := hρ.symm
    have hwf : IntsSized f.body := by rw [M.body]; exact hfn.ints
    obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
    have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
    have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
    have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    rw [hR] at hf
    refine stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc ?_
    rcases hf with hf | hf | hf | hf | hf | hf | hf | hf | hf | hf
    · exact lift_copy M.stack hbody hmode' hρ' hf hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_intCast M.stack hbody hwf hmode' hρ' hf hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_unop M.stack hbody hwf hmode' hρ' hf hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_field M.stack hbody hmode' hρ' hf hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_cmp M.stack hbody hmode' hρ' hf hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_wide M.stack hbody hmode' hρ' hf hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_binX M.stack hbody hwf hmode' hρ' hf hc hsc hpe hpl M.rel M.pb hl2 hl1 hev
    · exact lift_offset M.stack hbody hmode' hρ' hf hc hsc hpe hpl M.rel M.pb hl2 hl1 hev
    · exact lift_ovf M.stack hbody hwf hmode' hρ' hf hc hsc hpe hpl M.rel M.pb hl2 hl1 hev
    · exact lift_derefLoad M.stack hbody hmode' hρ' hf.1 hc hsc hpe hpl M.rel M.pb M.dinv.1 M.dinv.2 hl2
        hl1 hev
  cases hlow with
  | base h => exact stmt_sim_base hfn hmode hρ M hpick hst hr h1 h2 h hev
  | copy h => exact fam (.inl h)
  | intCast h => exact fam (.inr (.inl h))
  | unop h => exact fam (.inr (.inr (.inl h)))
  | field h => exact fam (.inr (.inr (.inr (.inl h))))
  | cmp h => exact fam (.inr (.inr (.inr (.inr (.inl h)))))
  | enum h => exact stmt_sim_enum hfn hmode hρ M hst hr h1 h2 h hev
  | wide h => exact fam (.inr (.inr (.inr (.inr (.inr (.inl h))))))
  | binX h => exact fam (.inr (.inr (.inr (.inr (.inr (.inr (.inl h)))))))
  | offset h => exact fam (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inl h))))))))
  | ovf h => exact fam (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inl h)))))))))
  | deref h =>
    by_cases hd : ∃ d rv, st = .assign ⟨d, []⟩ rv
    · exact fam (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inr ⟨h, hd⟩)))))))))
    -- `store`: an assignment to a projected place, one instruction
    obtain ⟨pl, rv, i, rfl, hR, hproj, hkill, hlowS⟩ : ∃ pl rv i, st = .assign pl rv ∧
        rangeInsns c.d r = [i] ∧ pl.proj ≠ [] ∧ stmtKill (.assign pl rv) = none ∧
        LowerDeref Γ.toStmtCtx (.assign pl rv) [i] := by
      generalize rangeInsns c.d r = is at h ⊢
      cases h with
      | load => exact (hd ⟨_, _, rfl⟩).elim
      | store ha htp hk hpath hta hn hpos hwf hsp hsa hsize hoff hi =>
        exact ⟨_, _, _, rfl, rfl, List.cons_ne_nil _ _, rfl,
          .store ha htp hk hpath hta hn hpos hwf hsp hsa hsize hoff hi⟩
    have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
    have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
    have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
    obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
    have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
    have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
    have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
    obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
    obtain ⟨st', hstep, hstk, hrel, hpb, hle, hk⟩ := lift_derefStore (ch := ch) M.stack M.body.symm
      hmode.symm hρ.symm hlowS hproj hc hsc hpe hpl M.rel M.pb M.dinv.1 M.dinv.2 hlv2
      (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
    refine ⟨_, f, .cons hstep (.refl _), hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl, hpc, hrel,
      ?_, hpb, ?_, M.dinv.of_memKept hk⟩
    · intro l p hp
      exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by intro e; cases e)
    · intro a ha
      exact M.fresh a (Nat.le_trans hle ha)
  | intrinsic h => exact stmt_sim_intrinsic hfn M hst hr h1 h2 h hev
  | castMore h => exact stmt_sim_castMore hfn hmode hρ M hst hr h1 h2 h hev
  | derefSplit h => exact stmt_sim_derefSplit hfn hmode hρ M hst hr h1 h2 h hev M.dinv.below
  | binFloat h => exact stmt_sim_binFloat hfn hmode hρ M hst hr h2 h hev hpick.2
  | floatCast h => exact stmt_sim_floatCast hfn hmode hρ M hst hr h2 h hev hpick.2
  | refDerefWide h => exact stmt_sim_refDerefWide hfn hmode hρ M hst hr h1 h2 h hev
  | rawPtrAgg h => exact stmt_sim_rawPtrAgg hfn hmode hρ M hst hr h1 h2 h hev
  | cmpX h => exact stmt_sim_cmpX hfn hmode hρ M hst hr h2 h hev
  | cmpConst h => exact stmt_sim_cmpConst hfn hmode hρ M hst hr h1 h2 h hev
  | boolBin h => exact stmt_sim_boolBin hfn hmode hρ M hst hr h2 h hev
  | derefCast h => exact stmt_sim_derefCast hfn hmode hρ M hst hr h2 h hev
  | copyNO h => exact stmt_sim_copyNO hfn hmode hρ M hst hr h1 h2 h hev
  | offsetConst h => exact stmt_sim_offsetConst hfn hmode hρ M hst hr h1 h2 h hev
  | binXConst h => exact stmt_sim_binXConst hfn hmode hρ M hst hr h1 h2 h hev
  | unionAgg h => exact stmt_sim_unionAgg hfn hmode hρ M hst hr h1 h2 h hev
  | zstRead h => exact stmt_sim_zstRead hfn M hst hr h1 h2 h hev
  | storeTemp h => exact stmt_sim_storeTemp hfn hmode hρ M hst hr h1 h2 h hev
  | splitRead h => exact stmt_sim_splitRead hfn hmode hρ M hst hr h1 h2 h hev
  | discrPlace h => exact stmt_sim_discrPlace hfn hmode hρ M hst hr h1 h2 h hev
  | fieldWrite h => exact stmt_sim_fieldWrite hfn hmode hρ M hst hr h2 h hev
  | fieldCopyN h => exact stmt_sim_fieldCopyN hfn hmode hρ M hst hr h1 h2 h hev
  | stmtEsc h => exact stmt_sim_stmtEsc hfn hmode hρ M hst hr h2 h hev
  | derefWide h => exact stmt_sim_derefWide hfn hmode hρ M hst hr h2 h hev
  | cmpFloat h => exact stmt_sim_cmpFloat hfn hmode hρ M hst hr h2 h hev
  | derefZst h => exact stmt_sim_derefZst hfn M hst hr h1 h2 h hev
  | refDerefIdx h => exact stmt_sim_refDerefIdx hfn hmode hρ M hst hr h1 h2 h hev
  | refDerefDown h => exact stmt_sim_refDerefDown hfn hmode hρ M hst hr h2 h hev
  | derefStoreF h => exact stmt_sim_derefStoreF hfn hmode hρ M hst hr h2 h hev
  | idxRead h =>
    -- needs an `Escape`, which `LowersFn` excludes (`noEsc`)
    exfalso
    generalize rangeInsns c.d r = is at h
    cases h with
    | mk _ _ _ _ _ _ _ _ _ _ hsize _ _ hesc _ _ _ =>
      have h0 := hesc 0 hsize.2.2
      rw [hfn.noEsc] at h0
      cases h0
  | refDerefWideE h => exact stmt_sim_refDerefWideE hfn hmode hρ M hst hr h1 h2 h hev
  | ovfConst h => exact stmt_sim_ovfConst hfn hmode hρ M hst hr h1 h2 h hev
  | nicheRead h => exact stmt_sim_nicheRead hfn hmode hρ M hst hr h1 h2 h hev
  | divConst h => exact stmt_sim_divConst hfn hmode hρ M hst hr h1 h2 h hev
  | binMore h => exact stmt_sim_binMore hfn hmode hρ M hst hr h1 h2 h hev
  | ovfMore h => exact stmt_sim_ovfMore hfn hmode hρ M hst hr h1 h2 h hev
  | binFloatConst h => exact stmt_sim_binFloatConst hfn hmode hρ M hst hr h1 h2 h hev hpick.2
  | refDeref h =>
    obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
      generalize rangeInsns c.d r = is at h ⊢
      cases h
      exact ⟨_, _, _, rfl, rfl⟩
    rw [hR] at h
    have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
    have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
    have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
    obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
    have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
    have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
    have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      (lift_refDeref M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2 hl1 hev)
  | ref h =>
    -- `ref` needs an `Escape`, which `LowersFn` excludes (`noEsc`)
    exfalso
    generalize rangeInsns c.d r = is at h
    cases h with
    | ref _ _ _ _ _ _ _ _ hsize _ _ hesc _ =>
      have h0 := hesc 0 (by omega)
      rw [hfn.noEsc] at h0
      cases h0
  | poolConst h =>
    -- the pool rules need a placement, which `LowersFn` excludes (`noPool`)
    exfalso
    generalize rangeInsns c.d r = is at h
    cases h with
    | ptr hk => simp [StmtCtx.poolAt, hfn.noPool] at hk
    | slice hk => simp [StmtCtx.poolAt, hfn.noPool] at hk
  | fnPtrCast h =>
    -- a fn pointer needs a symbol slot (`noFnSym`), a vtable a placement (`noPool`)
    exfalso
    generalize rangeInsns c.d r = is at h
    cases h with
    | fnPtr _ _ hn => simp [StmtCtx.fnSymAt, hfn.noFnSym] at hn
    | vtable _ hk => simp [StmtCtx.poolAt, hfn.noPool] at hk
  | agg h =>
    obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
      cases h <;> exact ⟨_, _, rfl⟩
    have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
    have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
    have hlen := rangeInsns_length (r := r) h2
    have hi : ∀ j (hj : j < (rangeInsns c.d r).length),
        c.d.insns[s1.pc + j]? = some ((rangeInsns c.d r)[j]'hj) := by
      rw [hpc0]; exact rangeInsns_at h2
    have hsc : ∀ j, j < (rangeInsns c.d r).length → c.scopesAt (s1.pc + j) = [] :=
      fun _ _ => scopesAt_nil hfn.noScopes _
    have hpl : ∀ i ∈ rangeInsns c.d r, PlainView c.mode c.ρ i := by
      intro i hmem
      obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hmem
      rw [hmode, hρ]
      exact hfn.plain _ _ (hi j hj)
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    refine stmtOut_of_liftN (k := (rangeInsns c.d r).length) M.stack hfn.storage M.hbd hst M.sl
      M.fresh M.dinv (by rw [hpc0, hlen]; omega) ?_
    exact lift_agg M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb M.dinv.2
      (escIdOff_of_noEsc M.rel hfn.noEsc) hl2 hl1 hev

/-! ### One step -/

/-- L0 at the start of a dead block (`deadBlock`: no statements, `unreachable`), no unwind
pending: `sim_switch`'s dead end, from which L0 has no successful step (`dead_no_step`). -/
def DeadAt (Γ : TermCtx) (s : Spec.State) : Prop :=
  ∃ f rest, s.stack = f :: rest ∧ f.body = Γ.body ∧ f.pendingUnwind = none ∧ f.stmt = 0 ∧
    deadBlock Γ f.bb = true

/-- `term_next` for the switch families too (`LowerTermMore`'s terminators, which may not
jump, are excluded: `hnm`; its `Assert` jumps give their target themselves, `JumpOut`). -/
theorem term_nextX {Γ : TermCtx} {next : Nat} {term : Terminator} {is : List R.Insn}
    (hlow : LowerTermX Γ next term is) (hnr : term ≠ .return)
    (hnm : ¬ LowerTermMore Γ next term is) {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : f.body = Γ.body)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    ∃ b', b' ∈ termSuccs term ∧ s'.stack = { f with bb := b', stmt := 0 } :: rest ∧
      s'.mem = s.mem := by
  cases hlow with
  | base hl => exact term_next hl hnr hs h
  | retX hl => exact absurd hl.term_eq hnr
  | static hl => exact hl.term_next hs h
  | more hl => exact absurd hl hnm
  | retSret hl =>
    obtain ⟨_, _, hl⟩ := hl
    exact absurd hl.term_eq hnr
  | switch hl => exact hl.term_next hs hbody h

/-! ### Runs -/

/-- `n` successful L0 steps. -/
inductive L0Steps (o : Spec.Oracle) : Nat → Spec.State → Spec.State → Prop where
  | zero (s : Spec.State) : L0Steps o 0 s s
  | succ {n : Nat} {s s1 s2 : Spec.State} : runOn Sem.step o s = (.ok (), s1) →
      L0Steps o n s1 s2 → L0Steps o (n + 1) s s2

theorem StepsTo.trans {c : R.Code} {ch : OpSem.Choice} {a b d : R.RState}
    (h1 : StepsTo c ch a b) (h2 : StepsTo c ch b d) : StepsTo c ch a d := by
  induction h1 with
  | refl => exact h2
  | cons hs _ ih => exact .cons hs (ih h2)

end Ryo.Proofs.Lower

