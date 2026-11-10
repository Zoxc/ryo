/-
Ryo.Proofs.Lower.SimDerefZst — the simulation of `LowerDerefZst` (`Check/Lower/DerefZst.lean`,
M5b): a zero-sized read or write through a thin pointer, with no instruction.

L0 (`derefLoad_mem`, `derefStore_mem`): the bytes loaded are none, so the re-encoding stored is
empty too and the store leaves the memory (`zst_store_eq`). R takes no step. `FnRel`: for the
read as `lift_zstRead` (`FnRel.zstWrite`, `_d`'s slot is empty); for the write the liveness
after is below the liveness before (`FnRel.weakenLive`).
-/
import Ryo.Proofs.Lower.SimZstRead
import Ryo.Proofs.Lower.SimDeref
import Ryo.Check.Lower.DerefZst

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `FnRel` at a liveness below. -/
theorem FnRel.weakenLive {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1)
    (hlive' : ∀ l, live' l = true → live l = true) : FnRel Γ ι live' f m0 s1 := by
  refine ⟨⟨hrel.frame.mem, ?_⟩, hrel.hidden, hrel.unaliased, hrel.provNe, hrel.apart, hrel.esc⟩
  intro l p hp hal
  obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
  exact ⟨slot, hsl, hr.weaken (fun h => hlive' l h)⟩

/-- No step, memory and stack unchanged: a `LiftOutN` of no instruction. -/
theorem liftOutN_nil {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {live' : Local → Bool} {f : Spec.Frame} {s s' : Spec.State} {s1 : R.RState}
    (hrel : FnRel Γ ι live' f s.mem s1) (hpb : ProvBounded s.mem) (hstk : s'.stack = s.stack)
    (hm : s'.mem = s.mem) : LiftOutN Γ c ch ι live' f s s' s1 0 := by
  refine ⟨s1.st, .refl _, hstk, ?_, ?_, ?_, ?_⟩
  · rw [hm]
    exact hrel.congr rfl rfl rfl rfl
  · rw [hm]; exact hpb
  · exact Nat.le_of_eq (by rw [hm])
  · rw [hm]; exact MemKept.refl _

/-- The read's lift: no R step. -/
theorem lift_derefZstLoad {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerDerefZst Γ (.assign ⟨d, []⟩ rv) is) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @load d p oa pointee ty fields pt valid off sd ha htp hk hpath htd hn hwf hsd hz =>
    rw [eval_use_place_norm ha] at h
    rw [hbody] at htp htd
    obtain ⟨pd, pp, bp, q, bs0, w, bsd, -, -, -, -, -, hlo0, hd, hen, hsto, hstk⟩ :=
      derefLoad_mem hs htp hk hpath htd hn h
    exact liftOutN_nil (hrel.zstWrite hsd hz hlive') hpb hstk
      (zst_store_eq hwf hn hlo0 hd hen hsto)

/-- The write's lift: no R step. -/
theorem lift_derefZstStore {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {p : Local} {x : ProjElem} {xs : List ProjElem} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerDerefZst Γ (.assign ⟨p, x :: xs⟩ rv) is) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assign ⟨p, x :: xs⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @store p a oa pointee ty fields pt valid off ha htp hk hpath hta hn hwf =>
    rw [eval_use_norm ha] at h
    rw [hbody] at htp hta
    obtain ⟨pp, pa, bp, q, bsa, w, bsd, -, -, -, -, -, hla, hd, hen, hsto, hstk⟩ :=
      derefStore_mem hs htp hk hpath hta hn h
    exact liftOutN_nil (hrel.weakenLive hlive') hpb hstk (zst_store_eq hwf hn hla hd hen hsto)

/-- The statement's `StmtOut` in a scope-free function. -/
theorem stmt_sim_derefZst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerDerefZst Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hlen := rangeInsns_length (r := r) h2
  obtain ⟨d, rv, rfl⟩ | ⟨p, x, xs, rv, rfl⟩ :
      (∃ d rv, st = .assign ⟨d, []⟩ rv) ∨ (∃ p x xs rv, st = .assign ⟨p, x :: xs⟩ rv) := by
    generalize rangeInsns c.d r = is at h
    cases h
    · exact .inl ⟨_, _, rfl⟩
    · exact .inr ⟨_, _, _, _, rfl⟩
  · obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    refine stmtOut_of_liftN (k := (rangeInsns c.d r).length) M.stack hfn.storage M.hbd hst M.sl
      M.fresh M.dinv (by rw [hpc0, hlen]; omega) ?_
    exact lift_derefZstLoad M.stack M.body.symm h M.rel M.pb hl1 hev
  · have hkill : stmtKill (.assign ⟨p, x :: xs⟩ rv) = none := rfl
    obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
    obtain ⟨st', hsteps, hstk, hrel, hpb, hle, hk⟩ := lift_derefZstStore (ch := ch) M.stack
      M.body.symm h M.rel M.pb (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
    refine ⟨_, f, hsteps, hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl,
      (by show s1.pc + (rangeInsns c.d r).length = r.2; rw [hpc0, hlen]; omega), hrel, ?_, hpb,
      ?_, M.dinv.of_memKept hk⟩
    · intro l q hq
      exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l q hq) (by intro e; cases e)
    · intro a ha
      exact M.fresh a (Nat.le_trans hle ha)

end Ryo.Proofs.Lower
