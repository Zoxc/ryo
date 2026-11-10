/-
Ryo.Proofs.Lower.SimIntrinsic — the simulation of `LowerIntrinsic` (`Check/Lower/Intrinsic.lean`,
M5b): `Assume(op)`, lowered to no instruction.

- L0 (`assume_state`): `evalStatement (.assume op)` is `evalOperand op` and then `pure ()` for
  `true` (UB for `false`, ill-formed otherwise), so a successful run ends where it began when the
  operand's evaluation does (`evalOperand_assume_state`: a whole local, `runOn_evalOperand_copy`/
  `_move`; a runtime check, a `pure`).
- R takes no step: `lift_assume` is a `LiftOutN` of length 0 (`FnRel.weaken` to the next point's
  liveness, which `LiveSound` puts below this one's since `Assume` kills nothing), for
  `ScopeMulti.stmtOutX_of_liftN` (`SimMoreX.lean`), and `stmt_sim_intrinsic` the scope-free
  `StmtOut` (as `StorageDead`'s case of `stmt_sim_base`, without the frame change), for
  `FnStep.stmt_sim`.
-/
import Ryo.Proofs.Lower.SimAgg
import Ryo.Proofs.Lower.L0Inv
import Ryo.Check.Lower.Intrinsic

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

theorem runOn_ub_inv {α : Type} {msg : String} {b : α} {o : Spec.Oracle} {s s' : Spec.State}
    (h : runOn (throwUb msg : SemM α) o s = (.ok b, s')) : False := by
  rw [runOn_throwUb] at h
  exact prod_err_ok h

/-- An operand `assume` takes evaluates without changing the state. -/
theorem evalOperand_assume_state {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {op : Operand}
    (hop : assumeOperand op = true) {r : Value × Spec.Ty}
    (h : runOn (evalOperand op) o s = (.ok r, s1)) : s1 = s := by
  cases op with
  | copy p =>
    obtain ⟨l, proj⟩ := p
    cases proj with
    | nil =>
      obtain ⟨_, _, _, _, _, _, _, hs1⟩ := runOn_evalOperand_copy hs h
      exact hs1
    | cons _ _ => simp [assumeOperand] at hop
  | move p =>
    obtain ⟨l, proj⟩ := p
    cases proj with
    | nil =>
      obtain ⟨_, _, _, _, _, _, _, hs1⟩ := runOn_evalOperand_move hs h
      exact hs1
    | cons _ _ => simp [assumeOperand] at hop
  | const c t => simp [assumeOperand] at hop
  | runtimeChecks k b => exact (runOn_pure_inv h).2

/-- A successful `Assume` leaves L0's state as it was. -/
theorem assume_state {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {op : Operand}
    (hop : assumeOperand op = true)
    (h : runOn (evalStatement (.assume op)) o s = (.ok (), s')) : s' = s := by
  simp only [evalStatement] at h
  obtain ⟨r, s2, h1, h2⟩ := runOn_bind_ok h
  have hs2 := evalOperand_assume_state hs hop h1
  subst hs2
  obtain ⟨v, t⟩ := r
  cases v
  case bool b =>
    cases b
    · exact (runOn_ub_inv h2).elim
    · exact (runOn_pure_inv h2).2
  all_goals exact (runOn_illFormed_inv h2).elim

/-- `Assume`'s lift: no R step, the relation at a smaller liveness. -/
theorem lift_assume {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} {s1 : R.RState} {op : Operand} (hs : s.stack = f :: rest)
    (hop : assumeOperand op = true) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assume op)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 0 := by
  obtain rfl := assume_state hs hop h
  have e : ({ s1 with pc := s1.pc + 0, st := s1.st } : R.RState) = s1 := by
    cases s1; rfl
  refine ⟨s1.st, ?_, rfl, ?_, hpb, Nat.le_refl _, MemKept.refl _⟩
  · first | exact .refl _ | (rw [e]; exact .refl _)
  · first | exact hrel.weaken hlive' | (rw [e]; exact hrel.weaken hlive')

/-- `LowerIntrinsic` in a scope-free function: `stmt_sim`'s case. -/
theorem stmt_sim_intrinsic {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hlow : LowerIntrinsic Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  generalize hR : rangeInsns c.d r = is at hlow
  cases hlow with
  | assume hop =>
    have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
    have hpc : s1.pc = r.2 := by rw [hpc0, rangeInsns_nil h1 h2 hR]
    have e := assume_state M.stack hop hev
    subst e
    obtain ⟨hlv1, -⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
    refine ⟨s1, f, .refl _, M.stack, rfl, rfl, rfl, rfl, rfl, hpc,
      M.rel.weaken (fun l hl => hlv1 l hl (by simp [stmtKill])), ?_, M.pb, M.fresh, M.dinv⟩
    intro l p hp
    exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by simp [storageKill])

end Ryo.Proofs.Lower
