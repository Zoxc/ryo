/-
Ryo.Proofs.Lower.StmtSimX — `stmt_simX`, one statement of a function with scopes (the
generalization of `FnStep.stmt_sim`), dispatching to `SimRef.lean`'s lemmas. In progress: the
`StorageLive`, deref-store, `enum` and `agg` cases are open (`sorry`), so this module is not
imported by `Ryo.lean`; see `SimRef.lean`'s module comment for the plan.
-/
import Ryo.Proofs.Lower.SimRef

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- One statement with scopes (the generalization of `FnStep.stmt_sim`). Still open
(`sorry`, see the module comment): `StorageLive`, `enum`, `agg` and the deref `store`. -/
theorem stmt_simX {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    (hpick : PicksAt Γ o s s1.fp)
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
  | ref h => exact stmt_simX_ref hfn hmode hρ M hst hr h2 hnext h hev
  | deref h =>
    by_cases hd : ∃ d rv, st = .assign ⟨d, []⟩ rv
    · exact fam (.inr (.inr (.inr (.inr (.inr (.inr ⟨h, hd⟩))))))
    · -- TODO: the deref `store` under pending scopes (as `FnStep.stmt_sim`, on `c.dropScopes`)
      sorry
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
    · -- TODO: sub-lemma 4, `StorageLive` (`storageLive_privX`)
      sorry
  | enum h =>
    -- TODO: sub-lemma 5 (multi-instruction, on `c.dropScopes`)
    sorry
  | agg h =>
    -- TODO: sub-lemma 5
    sorry

end Ryo.Proofs.Lower
