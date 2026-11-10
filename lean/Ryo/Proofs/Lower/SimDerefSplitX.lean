/-
Ryo.Proofs.Lower.SimDerefSplitX — `LowerDerefSplit` in functions with scopes (`stmt_simX`'s
case, as `stmt_simX_storeTemp`): `stmtOutX_of_liftN` (`ScopeMulti.lean`) runs `lift_derefSplit`
on the cut code. Separate from `SimDerefSplit.lean` so that `FnStep` can import that one without
`ScopeMulti`.
-/
import Ryo.Proofs.Lower.ScopeMulti
import Ryo.Proofs.Lower.SimDerefSplit

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

theorem stmt_simX_derefSplit {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerDerefSplit Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) (hbelow : AllocsBelow s.mem) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨b, x, xs, rv, rfl⟩ : ∃ b x xs rv, st = .assign ⟨b, x :: xs⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h <;> exact ⟨_, _, _, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, x :: xs⟩ rv) = [] := rfl
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_derefSplit (ch := ch) M.stack M.body.symm hmode' hρ' h hi hsc
      hpe0 hpl0 M.rel.rel M.pb M.dinv.1 M.dinv.2 hbelow hlv2
      (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev)

end Ryo.Proofs.Lower
