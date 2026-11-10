/-
Ryo.Proofs.Lower.SimZstReadX — `LowerZstRead` in functions with scopes (`stmt_simX`'s case):
`stmtOutX_of_liftN` (`ScopeMulti.lean`) runs `lift_zstRead` on the cut code. Separate from
`SimZstRead.lean` so that `FnStep` can import that one without `ScopeMulti`.
-/
import Ryo.Proofs.Lower.ScopeMulti
import Ryo.Proofs.Lower.SimZstRead

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

theorem stmt_simX_zstRead {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerZstRead Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h <;> exact ⟨_, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    generalize rangeInsns c.d r = is at h
    cases h <;> first | rfl | simp_all [ownSpec, refPlace?]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun _ _ _ _ => lift_zstRead M.stack M.body.symm h M.rel.rel M.pb hl1 hev)

end Ryo.Proofs.Lower
