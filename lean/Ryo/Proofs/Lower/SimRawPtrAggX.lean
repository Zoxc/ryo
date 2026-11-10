/-
Ryo.Proofs.Lower.SimRawPtrAggX — `stmt_simX`'s case (StmtSimX.lean) for `LowerRawPtrAgg` under
pending scopes: `lift_rawPtrAgg` is a `LiftOutN` on the cut code from the fold `s0`, closed by
`ScopeMulti.stmtOutX_of_liftN` (as `SimMoreX.stmt_simX_castMore`). A file of its own because
`ScopeMulti` imports `FnStep`, which imports `SimRawPtrAgg`.
-/
import Ryo.Proofs.Lower.ScopeMulti
import Ryo.Proofs.Lower.SimRawPtrAgg

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `LowerRawPtrAgg` under pending scopes: `lift_rawPtrAgg` on the cut code. -/
theorem stmt_simX_rawPtrAgg {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerRawPtrAgg Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    cases h; exact ⟨_, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    cases h <;> first | rfl | simp [ownSpec, refPlace?]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_rawPtrAgg M.stack M.body.symm hmode' hρ' h hi hsc hpe0
      hpl0 M.rel.rel M.pb hl2 hl1 hev)

end Ryo.Proofs.Lower
