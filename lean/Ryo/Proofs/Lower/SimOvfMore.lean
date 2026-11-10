/-
Ryo.Proofs.Lower.SimOvfMore — the simulation of `LowerOvfMore` (`Check/Lower/OvfMore.lean`,
M5b): overflow-checked operators on field projections of locals.

`SimOvfConst.lean`'s `sim_ovfGen` with the operands' `OpndFacts` from `SimBinMore.lean`'s
`placeInt_facts` (and `opndFacts_const` for a constant in a temporary). `lift_ovfMore` is one
step for `placeOvf` (`liftOutN_of_lift`), the `imm` then the handler for `placeOvfImm`
(`liftOutN_two`); `stmt_sim_ovfMore` is the statement's `StmtOut` (`stmt_simX_ovfMore` is in
`SimOvfMoreX.lean`).
-/
import Ryo.Proofs.Lower.SimBinMore
import Ryo.Check.Lower.OvfMore

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

theorem intType_size_pos {t : IntType} (h : t.wf = true) : 0 < t.size := by
  unfold IntType.wf at h
  have h' : t.size = 1 ∨ t.size = 2 ∨ t.size = 4 ∨ t.size = 8 ∨ t.size = 16 := by
    simpa using h
  rcases h' with h' | h' | h' | h' | h' <;> rw [h'] <;> decide

theorem lift_ovfMore {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerOvfMore Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @placeOvf d oa ob op m t vt ov oo head sd xa xb i hm htwf htd hsd hsize hlay hoff hpriv hA
      hB hoi =>
    have hc0 : c.d.insns[s1.pc]? = some i := by simpa using hi 0 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hpl0 : PlainView c.mode c.ρ i := hpl i (by simp)
    obtain ⟨hfa, hxa1, hxa2⟩ := placeInt_facts (o := o) hs hbody hrel hA
      (fun a ha => hlo a (List.mem_append_left _ ha))
    obtain ⟨hfb, hxb1, hxb2⟩ := placeInt_facts (o := o) hs hbody hrel hB
      (fun a ha => hlo a (List.mem_append_right _ ha))
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := ovfInsnOk_spec hoi
    rw [hmode, hρ] at hv
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < t.size := intType_size_pos htwf
    obtain ⟨hov, hoo⟩ := ovfLayoutOk_spec hlay
    have hpos' : 0 < sd.size := Nat.lt_of_lt_of_le hpos (Nat.le_trans (Nat.le_add_left _ _) hov)
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_ovfGen (ch := ch) hs hm htwf
      hpos htd hsize hov hoo hpd hrel.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv hh hty
      ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hxa1, hxa2, hxb1, hxb2⟩ hfa hfb h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_of_lift ⟨st', step_of_view hc0 hsc0 hpe hpl0 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩
  | @placeOvfImm d oa op m bits t vt vc ov oo head sd xa tt i1 i2 hm htwf htd hsd hsize hlay
      hoff hpriv hA ht hi1 hi2 =>
    obtain ⟨hft, -, htpv, hap⟩ := tempOk_spec ht
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    -- R: the temporary
    have hpv := temp_private hrel htpv
    obtain ⟨x1, st1, hx1, hstep1, hw1, hmem1⟩ :=
      step_immTemp (ch := ch) hmode hρ hc0 hsc0 hpe hpl0 hi1 hft hpv
    have hlen1 : (intBytes t.size x1).length = t.size :=
      Ryo.Spec.Theorems.encodeBits_length t.size x1
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame tt t.size = .ok (intBytes t.size x1) := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    have hvb : asNat (intBytes t.size x1) = .ok (bits % 2 ^ (8 * t.size)) := by
      rw [asNat_intBytes, hx1]
    obtain ⟨hfa, hxa1, hxa2⟩ := placeInt_facts (o := o) hs hbody hrel1 hA
      (fun a ha => hlo a (List.mem_append_left _ ha))
    -- the handler
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := ovfInsnOk_spec hi2
    rw [hmode, hρ] at hv
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < t.size := intType_size_pos htwf
    obtain ⟨hov, hoo⟩ := ovfLayoutOk_spec hlay
    have hpos' : 0 < sd.size := Nat.lt_of_lt_of_le hpos (Nat.le_trans (Nat.le_add_left _ _) hov)
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hf3 := offOk_spec hft
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_ovfGen (ch := ch) hs hm htwf
      hpos htd hsize hov hoo hpd hrel1.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv' hh hty
      ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hxa1, hxa2, hf3.1, hf3.2⟩ hfa (opndFacts_const hrd1 hvb) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩

theorem stmt_sim_ovfMore {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerOvfMore Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
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
  exact lift_ovfMore M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    hl2 hl1 hev

end Ryo.Proofs.Lower
