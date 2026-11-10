/-
Ryo.Proofs.Lower.StmtSimX — `stmt_simX`, one statement of a function with scopes (the
generalization of `FnStep.stmt_sim`), dispatching to `SimRef.lean`'s lemmas (one-instruction
families, `ref`, `StorageDead`) and `ScopeMulti.lean`'s (`StorageLive`, the deref `store`,
`enum`, `agg`), and `SimPoolConst.lean`'s pool constants (given the pool invariant `PoolInv` and
the copy choice `ReusesAt`) and `SimFnPtrCast.lean`'s fn pointers and vtable unsizings (also
given the function invariant `FnInv` and the address choice `FnReusesAt`).
-/
import Ryo.Proofs.Lower.ScopeMulti
import Ryo.Proofs.Lower.SimMoreX
import Ryo.Proofs.Lower.SimRefDerefWideX
import Ryo.Proofs.Lower.SimRawPtrAggX
import Ryo.Proofs.Lower.SimCmpMoreX
import Ryo.Proofs.Lower.SimCopyNOX
import Ryo.Proofs.Lower.SimConstX
import Ryo.Proofs.Lower.SimZstReadX
import Ryo.Proofs.Lower.SimSplitReadX
import Ryo.Proofs.Lower.SimDiscrPlaceX
import Ryo.Proofs.Lower.SimCmpFloatX
import Ryo.Proofs.Lower.SimDerefZstX
import Ryo.Proofs.Lower.SimIdxRead
import Ryo.Proofs.Lower.SimOvfConstX
import Ryo.Proofs.Lower.SimNicheReadX
import Ryo.Proofs.Lower.SimDivConstX
import Ryo.Proofs.Lower.SimBinMoreX
import Ryo.Proofs.Lower.SimOvfMoreX
import Ryo.Proofs.Lower.SimBinFloatConstX
import Ryo.Proofs.Lower.SimDerefSplitX
import Ryo.Proofs.Lower.SimBinFloatX
import Ryo.Proofs.Lower.SimFloatCastX
import Ryo.Proofs.Lower.SimPoolConst
import Ryo.Proofs.Lower.SimFnPtrCast

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- One statement with scopes (the generalization of `FnStep.stmt_sim`). -/
theorem stmt_simX {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    (hpick : PicksAt Γ o ch s s1.fp)
    (hpool : PoolInv Γ.poolAt c.ρ ι s) (hre : ReusesAt o)
    (hfinv : FnInv Γ.fnSymAt c.ρ ι s s0.st) (hfre : FnReusesAt o)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (hlow : LowerStmtX Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have fam := fun hf => stmt_simX_family (ch := ch) hfn hmode hρ M hst hr h2 hnext hf hev
  cases hlow with
  | copy h => exact fam (.inl h)
  | intCast h => exact fam (.inr (.inl h))
  | unop h => exact fam (.inr (.inr (.inl h)))
  | field h => exact fam (.inr (.inr (.inr (.inl h))))
  | cmp h => exact fam (.inr (.inr (.inr (.inr (.inl h)))))
  | wide h => exact fam (.inr (.inr (.inr (.inr (.inr (.inl h))))))
  | binX h => exact fam (.inr (.inr (.inr (.inr (.inr (.inr (.inl h)))))))
  | offset h => exact fam (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inl h))))))))
  | ovf h => exact fam (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inl h)))))))))
  | intrinsic h => exact stmt_simX_intrinsic hfn hmode hρ M hst hr h1 h2 hnext h hev
  | castMore h => exact stmt_simX_castMore hfn hmode hρ M hst hr h1 h2 hnext h hev
  | derefSplit h =>
    exact stmt_simX_derefSplit hfn hmode hρ M hst hr h1 h2 hnext h hev M.dinv.below
  | binFloat h => exact stmt_simX_binFloat hfn hmode hρ M hst hr h1 h2 hnext h hev hpick.2
  | floatCast h => exact stmt_simX_floatCast hfn hmode hρ M hst hr h1 h2 hnext h hev hpick.2
  | refDerefWide h => exact stmt_simX_refDerefWide hfn hmode hρ M hst hr h1 h2 hnext h hev
  | rawPtrAgg h => exact stmt_simX_rawPtrAgg hfn hmode hρ M hst hr h1 h2 hnext h hev
  | cmpX h => exact stmt_simX_cmpX hfn hmode hρ M hst hr h2 hnext h hev
  | cmpConst h => exact stmt_simX_cmpConst hfn hmode hρ M hst hr h1 h2 hnext h hev
  | boolBin h => exact stmt_simX_boolBin hfn hmode hρ M hst hr h2 hnext h hev
  | derefCast h => exact stmt_simX_derefCast hfn hmode hρ M hst hr h1 h2 hnext h hev
  | copyNO h => exact stmt_simX_copyNO hfn hmode hρ M hst hr h1 h2 hnext h hev
  | offsetConst h => exact stmt_simX_offsetConst hfn hmode hρ M hst hr h1 h2 hnext h hev
  | binXConst h => exact stmt_simX_binXConst hfn hmode hρ M hst hr h1 h2 hnext h hev
  | unionAgg h => exact stmt_simX_unionAgg hfn hmode hρ M hst hr h1 h2 hnext h hev
  | zstRead h => exact stmt_simX_zstRead hfn hmode hρ M hst hr h1 h2 hnext h hev
  | storeTemp h => exact stmt_simX_storeTemp hfn hmode hρ M hst hr h1 h2 hnext h hev
  | splitRead h => exact stmt_simX_splitRead hfn hmode hρ M hst hr h1 h2 hnext h hev
  | discrPlace h => exact stmt_simX_discrPlace hfn hmode hρ M hst hr h1 h2 hnext h hev
  | fieldWrite h => exact stmt_simX_fieldWrite hfn hmode hρ M hst hr h1 h2 hnext h hev
  | fieldCopyN h => exact stmt_simX_fieldCopyN hfn hmode hρ M hst hr h1 h2 hnext h hev
  | stmtEsc h => exact stmt_simX_stmtEsc hfn hmode hρ M hst hr h2 hnext h hev
  | derefWide h => exact stmt_simX_derefWide hfn hmode hρ M hst hr h1 h2 hnext h hev
  | cmpFloat h => exact stmt_simX_cmpFloat hfn hmode hρ M hst hr h1 h2 hnext h hev
  | derefZst h => exact stmt_simX_derefZst hfn hmode hρ M hst hr h1 h2 hnext h hev
  | refDerefIdx h => exact stmt_simX_refDerefIdx hfn hmode hρ M hst hr h1 h2 hnext h hev
  | refDerefDown h => exact stmt_simX_refDerefDown hfn hmode hρ M hst hr h2 hnext h hev
  | derefStoreF h => exact stmt_simX_derefStoreF hfn hmode hρ M hst hr h1 h2 hnext h hev
  | idxRead h => exact stmt_simX_idxRead hfn hmode hρ M hst hr h2 hnext h hev
  | refDerefWideE h => exact stmt_simX_refDerefWideE hfn hmode hρ M hst hr h1 h2 hnext h hev
  | ovfConst h => exact stmt_simX_ovfConst hfn hmode hρ M hst hr h1 h2 hnext h hev
  | nicheRead h => exact stmt_simX_nicheRead hfn hmode hρ M hst hr h1 h2 hnext h hev
  | divConst h => exact stmt_simX_divConst hfn hmode hρ M hst hr h1 h2 hnext h hev
  | binMore h => exact stmt_simX_binMore hfn hmode hρ M hst hr h1 h2 hnext h hev
  | ovfMore h => exact stmt_simX_ovfMore hfn hmode hρ M hst hr h1 h2 hnext h hev
  | binFloatConst h => exact stmt_simX_binFloatConst hfn hmode hρ M hst hr h1 h2 hnext h hev hpick.2
  | refDeref h =>
    obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
      generalize rangeInsns c.d r = is at h ⊢
      cases h
      exact ⟨_, _, _, rfl, rfl⟩
    rw [hR] at h
    have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
      cases h with
      | mk hrv htp _ _ _ _ _ hsp _ _ _ => simp [ownSpec, hrv, hsp, htp, fieldPath]
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact stmt_simX_single hfn hmode hρ M hst hr h2 hnext hR hown fun hc0 hsc0 hpe0 hpl0 =>
      lift_refDeref M.stack M.body.symm hmode.symm hρ.symm h hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb
        M.dinv.2 hl2 hl1 hev
  | ref h => exact stmt_simX_ref hfn hmode hρ M hst hr h2 hnext h hev
  | deref h =>
    by_cases hd : ∃ d rv, st = .assign ⟨d, []⟩ rv
    · exact fam (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inr (.inr ⟨h, hd⟩)))))))))
    · exact stmt_simX_derefStore hfn hmode hρ M hst hr h1 h2 hnext h hd hev
  | base h =>
    by_cases hnl : ∀ l, st ≠ .storageLive l
    · by_cases hnd : ∀ l, st ≠ .storageDead l
      · exact stmt_simX_baseAssign hfn hmode hρ M hst hr h2 hnext rfl h hnl hnd hev
      · obtain ⟨l, hl⟩ := Classical.not_forall.mp hnd
        have e : st = .storageDead l := Classical.not_not.mp hl
        subst e
        have hR0 : rangeInsns c.d r = [] := by
          generalize hR : rangeInsns c.d r = is at h
          cases h
          rfl
        exact stmt_simX_storageDead hfn M hst hr h1 h2 hnext hR0 hev
    · obtain ⟨l, hl⟩ := Classical.not_forall.mp hnl
      have e : st = .storageLive l := Classical.not_not.mp hl
      subst e
      have hR0 : rangeInsns c.d r = [] := by
        generalize hR : rangeInsns c.d r = is at h
        cases h
        rfl
      exact stmt_simX_storageLive hfn M hpick hst hr h1 h2 hnext hR0 hev
  | enum h => exact stmt_simX_enum hfn hmode hρ M hst hr h1 h2 hnext h hev
  | agg h => exact stmt_simX_agg hfn hmode hρ M hst hr h1 h2 hnext h hev
  | poolConst h => exact stmt_simX_poolConst hfn hmode hρ M hpool hre hst hr h2 hnext h hev
  | fnPtrCast h =>
    exact stmt_simX_fnPtrCast hfn hmode hρ M hpool hre hfinv hfre hst hr h2 hnext h hev

end Ryo.Proofs.Lower
