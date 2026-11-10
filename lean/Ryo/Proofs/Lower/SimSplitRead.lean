/-
Ryo.Proofs.Lower.SimSplitRead — the simulation of `LowerSplitRead`
(`Check/Lower/SplitRead.lean`, M5b): a read of `n` bytes of a projected place of `_a` into
`_d`'s private slot, copied by `mov` pieces.

- L0 (`field_mem`, `downcast_mem`): `n` bytes `bs0` loaded at `_a`'s pointer plus `off`, their
  re-encoding `bsd` (below `bs0`: `reenc_wf`) stored into `_d`.
- R: `_a`'s slot holds related bytes `bs1` at `sa.off + off` (`readLocal_sub_inj`), each one a
  successful `byteAt` (`aggMapM_ok` over `readFrame`); the pieces run (`sim_pieces`, all inside
  `_d`'s private slot, every source outside it) and leave `_d`'s slot holding `bs1`
  (`pieceFrame_movPieces`), which refines `bsd` (`BytesInj.of_le`).
- `frameLocal_priv` and `LocalRel.frame_apart` (`SimAgg.lean`) give `_d`'s and the other locals'
  relations; the stored provenance is the loaded bytes' (`bytesLeDefined_prov`), so `Hidden`,
  the provenance bound and `MemKept` carry over (`lift_splitRead`).
-/
import Ryo.Proofs.Lower.SimEnum
import Ryo.Check.Lower.SplitRead

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- The common lift, from L0's memory facts for the place at `off` in `_a`. -/
theorem lift_splitRead_mem {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d a : Local} {off : Nat} {ty : Spec.Ty} {is : List R.Insn}
    (hok : SplitReadOk Γ d a off ty is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hla : live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hmem0 : ∀ n, ty.size? = some n →
      ∃ pd pa bs0 v bsd, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
        s.mem.load ⟨pa.addr + off, pa.prov⟩ n .one = .ok bs0 ∧ ty.decode bs0 = some v ∧
        ty.encode v = some bsd ∧ s.mem.store pd bsd .one = .ok s'.mem ∧
        s'.stack = s.stack) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  obtain ⟨n, sd, sa, ws, htd, hn, hpos, hwf, hsd, hsa, hsize, hoff, hap, hpriv, hws, hpo⟩ := hok
  obtain ⟨pd, pa, bs0, v, bsd, hpd, hpa, hlo, hdec, hen, hsto, hstk⟩ := hmem0 n hn
  have hsz1 : sd.size = n := hsize.1
  have hsz2 : off + n ≤ sa.size := hsize.2
  have hbl : bs0.length = n := load_length hlo
  have hle := reenc_wf hwf hn hbl hdec hen
  have hlbd : bsd.length = n :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans hbl
  -- R's source bytes
  have hra := hrel.opnd hpa hsa hla
  obtain ⟨bs1, hrd, hbi⟩ := readLocal_sub_inj hrel.frame.mem hra hsize.2 hlo
  have hrd' := hrd
  unfold OpSem.State.readFrame at hrd'
  obtain ⟨hlen1, hall⟩ := aggMapM_ok hrd'
  have hl1 : bs1.length = n := by simpa using hlen1
  have hbyte : ∀ i (h : i < n), s1.st.byteAt (sa.off + off + i) = .ok (bs1[i]'(by omega)) := by
    intro i h
    have := hall i (by simp; omega) (by omega)
    simpa using this
  have hfb : ∀ i (h : i < n), frameByte s1.st (sa.off + off + i) = bs1[i]'(by omega) := by
    intro i h
    simp only [frameByte, hbyte i h]
  have hbe := BytesInj.of_le hle hbi
  -- the pieces
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2.1
  have hf3 := offOk_spec hoff.2.2.1
  have hf4 := offOk_spec hoff.2.2.2
  have hwithin : ∀ p ∈ movPieces sd.off (sa.off + off) 0 ws,
      p.Within sd.off (sd.off + n) := by
    intro p hp
    obtain ⟨o', w, rfl, -, how⟩ := movPieces_mem hp
    rw [hws] at how
    simp only [AggPiece.Within]
    omega
  have hesc' : ∀ o, sd.off ≤ o → o < sd.off + n → s1.st.escapedAt o = none := by
    intro o h1 h2
    cases he : s1.st.escapedAt o with
    | none => rfl
    | some e =>
      exfalso
      have h3 := hrel.esc o e he
      have h4 := hpriv (o - sd.off).toNat (by omega)
      rw [show sd.off + ((o - sd.off).toNat : Int) = o by omega, h3] at h4
      cases h4
  have hsrcs : ∀ p ∈ movPieces sd.off (sa.off + off) 0 ws, ∀ d' s'' w, p = .mov d' s'' w →
      ∀ i < w, s1.st.byteAt (s'' + i) = .ok (frameByte s1.st (s'' + i)) := by
    intro p hp d' s'' w he i hi'
    obtain ⟨o', w', rfl, -, how⟩ := movPieces_mem hp
    cases he
    rw [hws] at how
    have e : sa.off + (off : Int) + (o' : Int) + (i : Int) =
        sa.off + (off : Int) + ((o' + i : Nat) : Int) := by omega
    rw [e, hfb (o' + i) (by omega)]
    exact hbyte (o' + i) (by omega)
  obtain ⟨st', hsteps, hmem, hesc, hfr'⟩ :=
    sim_pieces (ch := ch) (src := frameByte s1.st) hmode hρ hpo hi hsc hpe hpl hwithin hesc'
      hsrcs
  -- `_d`'s bytes
  have hbsL : ∀ k (h : k < bsd.length), ByteInj ι bsd[k] (st'.frame (sd.off + k)) := by
    intro k h
    rw [hfr', pieceFrame_movPieces, if_pos (by rw [hws]; omega)]
    have e : sa.off + off + (sd.off + (k : Int) - sd.off) = sa.off + off + ((k : Nat) : Int) := by
      omega
    rw [e, hfb k (by omega)]
    exact hbe.getElem' k h (by omega)
  have hfro : ∀ o, (o < sd.off ∨ sd.off + n ≤ o) → st'.frame o = s1.st.frame o := by
    intro o ho
    rw [hfr']
    exact pieceFrame_outside hwithin ho
  have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
  obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ :=
    hrel.priv_dst hpd hsd hpos' hpriv
  obtain ⟨hmi, hrdd⟩ := frameLocal_priv hrel.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv
    (hlbd.trans hsize.1.symm) hbsL hsto hmem hesc
  have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
      p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' s'.mem slot p lv := by
    intro slot p lv hr hne hap'
    rw [hsize.1] at hap'
    exact (hr.frame_apart hmem hesc hfro hap').store_other hsto (.inl (Ne.symm hne))
  -- `Hidden` and the bound: the stored provenance is the loaded bytes'
  have hsub := bytesLeDefined_prov hle
  have hhid := hrel.hidden.load hlo
  have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hhid _ (List.getElem_mem hj) fr0 hf0
  have hbd := hpb.load hlo
  have hbd' : BytesBounded s.mem.allocs.size bsd := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hbd _ (List.getElem_mem hj) fr0 hf0
  exact ⟨st', hsteps, hstk,
    hrel.after hpd hsd hmi hrdd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlo hsub⟩

theorem lift_splitRead {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerSplitRead Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @field d a oa projs ta ty off is ha hta hpath hok =>
    have hla := hlo a (operandPlace?_mem ha)
    rw [eval_use_place_norm ha] at h
    have hta' : f.body.locals[a]? = some ta := by rw [← hbody]; exact hta
    obtain ⟨_, _, _, _, htd, -⟩ := id hok
    have htd' : f.body.locals[d]? = some ty := by rw [← hbody]; exact htd
    exact lift_splitRead_mem hmode hρ hok hi hsc hpe hpl hrel hpb hla hlive'
      (fun n hn => field_mem hs hta' hpath htd' hn h)
  | @downcast d a oa projs ta ty off is ha hta hpath hok =>
    have hla := hlo a (operandPlace?_mem ha)
    rw [eval_use_place_norm ha] at h
    have hta' : f.body.locals[a]? = some ta := by rw [← hbody]; exact hta
    obtain ⟨_, _, _, _, htd, -⟩ := id hok
    have htd' : f.body.locals[d]? = some ty := by rw [← hbody]; exact htd
    exact lift_splitRead_mem hmode hρ hok hi hsc hpe hpl hrel hpb hla hlive'
      (fun n hn => downcast_mem hs hta' hpath htd' hn h)

theorem stmt_sim_splitRead {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerSplitRead Γ.toStmtCtx st (rangeInsns c.d r))
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
  exact lift_splitRead M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    hl2 hl1 hev

end Ryo.Proofs.Lower
