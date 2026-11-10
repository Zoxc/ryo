/-
Ryo.Proofs.Lower.SimUnionAgg — the lift of `LowerUnionAgg` (`Check/Lower/UnionAgg.lean`, M5b):
a union aggregate, its one field written into `_d`'s private slot.

- `lift_aggMemLe`: `SimAgg.lift_aggMem` for an L0 store of bytes *below* the fields' writes
  (`AggMemLe`): R's frame refines the writes (as there), hence the stored bytes
  (`ByteInj.of_le'`), and their provenance is the writes' (`le_prov`, `aggStored_prov`). The
  proof is `lift_aggMem`'s with these two steps added.
- L0 (`unionAgg_mem`): the operand evaluates as a field (`aggFields_mapM`), the union case
  writes its encoding at the field's offset over uninitialized bytes, decodes and the store
  re-encodes it, below the written bytes (`encode_decode_le`).
-/
import Ryo.Proofs.Lower.SimAgg
import Ryo.Check.Lower.UnionAgg

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `AggMem` with the stored bytes `bsd` only below the fields' writes. -/
def AggMemLe (f : Spec.Frame) (d : Local) (N : Nat) (fields : List (Nat × Spec.Ty))
    (srcs : List AggSrc) (s s' : Spec.State) : Prop :=
  ∃ pd ebs bsd, f.locals[d]? = some (some pd) ∧ srcs.length = ebs.length ∧
    fields.length = ebs.length ∧
    (∀ j (h1 : j < srcs.length) (h2 : j < ebs.length), FieldMem f s.mem srcs[j] ebs[j]) ∧
    (∀ j (h1 : j < fields.length) (h2 : j < ebs.length), fields[j].1 + ebs[j].length ≤ N) ∧
    bytesLeDefined bsd (writeFields (List.replicate N .uninit) ((fields.map (·.1)).zip ebs)) =
      true ∧
    s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack

/-- `lift_aggMem` for `AggMemLe` (see the module comment). -/
theorem lift_aggMemLe {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {ops : List Operand} {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc}
    {sd : LocalSlot} {is : List R.Insn}
    (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
    (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
    (hf : AggFields Γ sd ops fields srcs)
    (hpo : piecesOk Γ is (aggPieces sd.off fields srcs) = true)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hla : ∀ src ∈ srcs, ∀ a so ws, src = .slot a so ws → live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hmm : AggMemLe f d sd.size fields srcs s s') :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  obtain ⟨pd, ebs, bsd, hpd, hl1, hl2, hfm, hbd, hleW, hsto, hstk⟩ := hmm
  have hfl := AggFields.length hf
  have hwithin := aggPieces_within hf hoff
  have hesc' : ∀ o, sd.off ≤ o → o < sd.off + sd.size → s1.st.escapedAt o = none := by
    intro o h1 h2
    cases he : s1.st.escapedAt o with
    | none => rfl
    | some e =>
      exfalso
      have h3 := hrel.esc o e he
      have h4 := hpriv (o - sd.off).toNat (by omega)
      rw [show sd.off + ((o - sd.off).toNat : Int) = o by omega, h3] at h4
      cases h4
  have hsrc1 : ∀ j (h1 : j < srcs.length) (h2 : j < ebs.length),
      SrcRel ι (frameByte s1.st) srcs[j] ebs[j] ∧
        ∀ a s ws, srcs[j] = .slot a s ws →
          ∀ i < ws.sum, s1.st.byteAt (s + i) = .ok (frameByte s1.st (s + i)) := by
    intro j h1 h2
    obtain ⟨op, hfj⟩ := AggFields.get hf j (by omega) h1
    exact srcRel_of_fieldMem hrel hfj (hfm j h1 h2)
      (fun a s ws he => hla _ (List.getElem_mem h1) a s ws he)
  have hsrcs : ∀ p ∈ aggPieces sd.off fields srcs, ∀ d' s'' w, p = .mov d' s'' w →
      ∀ i < w, s1.st.byteAt (s'' + i) = .ok (frameByte s1.st (s'' + i)) := by
    intro p hp d' s'' w he i hi'
    obtain ⟨src, hsm, a, so, ws, rfl, o', rfl, how⟩ :=
      aggPieces_mov_src sd.off fields srcs p hp d' s'' w he
    obtain ⟨j, hj, hjs⟩ := List.getElem_of_mem hsm
    have := (hsrc1 j hj (by omega)).2 a so ws hjs (o' + i) (by omega)
    rw [show so + ((o' + i : Nat) : Int) = so + o' + i by omega] at this
    exact this
  obtain ⟨st', hsteps, hmem, hesc, hfr'⟩ :=
    sim_pieces (ch := ch) (src := frameByte s1.st) hmode hρ hpo hi hsc hpe hpl hwithin hesc' hsrcs
  obtain ⟨hLlen, hLrel⟩ := pieceFrame_aggPieces (ι := ι) (src := frameByte s1.st) (base := sd.off)
    (acc := List.replicate sd.size .uninit) (fr := s1.st.frame) (by omega) hl1
    (fun j h1 h2 => (hsrc1 j h1 h2).1)
    (fun j h1 h2 => by rw [List.length_replicate]; exact hbd j h1 h2)
    (fun k h => by simp only [List.getElem_replicate]; exact True.intro)
  rw [List.length_replicate] at hLlen
  have hbsL : ∀ k (h : k < (writeFields (List.replicate sd.size .uninit)
      ((fields.map (·.1)).zip ebs)).length),
      ByteInj ι (writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs))[k]
        (st'.frame (sd.off + k)) := by
    intro k h
    rw [hfr']
    exact hLrel k h
  have hfro : ∀ o, (o < sd.off ∨ sd.off + sd.size ≤ o) → st'.frame o = s1.st.frame o := by
    intro o ho
    rw [hfr']
    exact pieceFrame_outside hwithin ho
  -- the stored bytes are below the fields' writes
  obtain ⟨hlW, hpW⟩ := (Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hleW
  have hLlen' : bsd.length = sd.size := hlW.trans hLlen
  have hbsL' : ∀ k (h : k < bsd.length), ByteInj ι bsd[k] (st'.frame (sd.off + k)) :=
    fun k h => ByteInj.of_le' (hpW k h (by omega)) (hbsL k (by omega))
  -- `_d`'s relation after the statement
  obtain ⟨sd', hsd', hrd0⟩ := hrel.frame.locals d pd hpd (by rw [hrel.unaliased]; simp)
  rw [hsd] at hsd'
  obtain rfl := Option.some.inj hsd'
  have hdst : MemInj ι s'.mem st'.mem ∧ LocalRel ι s1.fp st' s'.mem sd pd true := by
    cases hrd0 with
    | priv a x hp hι hx hlive haddr hpaddr hsize hpv _ =>
      exact frameLocal_priv hrel.frame.mem a x hp hι hx hlive haddr hpaddr hsize hpv hLlen' hbsL'
        hsto hmem hesc
    | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
      have hz : sd.size = 0 := by
        by_cases hne : sd.size = 0
        · exact hne
        · exfalso
          have h3 := hrel.esc _ _ (hin 0 (by omega))
          rw [hpriv 0 (by omega)] at h3
          cases h3
      have hm' : s'.mem = s.mem := by
        rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with ⟨-, -, h⟩ | ⟨_, _, _, hne, _⟩
        · exact h
        · exact absurd (hLlen'.trans hz) hne
      have hea : ∀ o, st'.escapedAt o = s1.st.escapedAt o := fun o => by
        unfold OpSem.State.escapedAt; rw [hesc]
      rw [hm']
      exact ⟨by rw [hmem]; exact hrel.frame.mem,
        .esc a x e y hp hι hx hlive haddr hpaddr hsize (fun k hk => (hea _).trans (hin k hk))
          (by rw [hmem]; exact hy) hylive hyaddr hysize⟩
  obtain ⟨hmi, hrd⟩ := hdst
  have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
      p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' s'.mem slot p lv := by
    intro slot p lv hr hne hap
    exact (hr.frame_apart hmem hesc hfro hap).store_other hsto (.inl (Ne.symm hne))
  have hprovW := aggStored_prov (N := sd.size) (fields := fields) hl1 hfm
  have hprov : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ∃ pa n bs0,
      s.mem.load pa n .one = .ok bs0 ∧
      ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := le_prov hleW b hb fr hfr
    obtain ⟨pa, n, bs0, hld, j', hj', fr1, hf1, he1⟩ := hprovW _ (List.getElem_mem hj) fr0 hf0
    exact ⟨pa, n, bs0, hld, j', hj', fr1, hf1, he1.trans he0⟩
  have hhid' : ∀ b ∈ bsd,
      ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs0, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hrel.hidden.load hld _ (List.getElem_mem hj) fr0 hf0
  have hbd' : BytesBounded s.mem.allocs.size bsd := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs0, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hpb.load hld _ (List.getElem_mem hj) fr0 hf0
  exact ⟨st', hsteps, hstk,
    hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
    memKept_store hsto fun A hA b hb fr hfr => by
      obtain ⟨pa, n, bs0, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
      rw [← he0]
      exact hA.load hld _ (List.getElem_mem hj) fr0 hf0⟩

/-! ### L0: the union -/

/-- L0's union aggregate as `AggMemLe` of its one field (see the module comment). -/
theorem unionAgg_mem {Γ : StmtCtx} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {variant fi : Nat} {op : Operand} {ufields : List (Nat × Spec.Ty)}
    {chunks : List (Nat × Nat)} {usize : Nat} {ual : Align} {off : Nat} {fty : Spec.Ty}
    {sd : LocalSlot} {src : AggSrc}
    (htd : Γ.body.locals[d]? = some (.union ufields chunks usize ual))
    (hwf : (Spec.Ty.union ufields chunks usize ual).wf = true)
    (hfld : ufields[fi]? = some (off, fty)) (hsz : usize = sd.size)
    (hfa : AggField Γ sd op off fty src)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.aggregate (.adt variant (some fi)) [op]))) o s =
      (.ok (), s')) :
    AggMemLe f d sd.size [(off, fty)] [src] s s' := by
  have e : evalStatement (.assign ⟨d, []⟩ (.aggregate (.adt variant (some fi)) [op])) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue (.aggregate (.adt variant (some fi)) [op]) ty' >>= fun v =>
          placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd', hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.aggregate (.adt variant (some fi)) [op]) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  have htd2 : f.body.locals[d]? = some (.union ufields chunks usize ual) := by
    rw [← hbody]; exact htd
  obtain rfl : td = .union ufields chunks usize ual := Option.some.inj (htd'.symm.trans htd2)
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  obtain ⟨vals, s3, h5, h6⟩ :=
    runOn_bind_ok (x := [op].mapM fun o => do pure (← evalOperand o).1) h3
  have hf1 : AggFields Γ sd [op] [(off, fty)] [src] := .cons hfa .nil
  obtain ⟨hs3, ebs, hl1, hl2, hl3, hall, hfms, hbds⟩ := aggFields_mapM hs hbody hf1 h5
  rcases vals with _ | ⟨v0, _ | ⟨v1, vals⟩⟩
  all_goals first | (simp at hl2; done) | (simp at hl2; omega) | skip
  rcases ebs with _ | ⟨e0, _ | ⟨e1, ebs⟩⟩
  all_goals first | (simp at hl1; done) | (simp at hl1; omega) | skip
  have he0 : fty.encode v0 = some e0 := hall 0 (by simp) (by simp) (by simp)
  have hb0 : off + e0.length ≤ sd.size := hbds 0 (by simp) (by simp)
  rw [hs3] at h6
  -- the union case: the field's encoding written at its offset, decoded at the union type
  dsimp only at h6
  simp only [hfld, List.head?_cons, he0] at h6
  split at h6
  next u hdu =>
    obtain ⟨rfl, rfl⟩ := runOn_pure_inv h6
    obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
    have hsU : (Spec.Ty.union ufields chunks usize ual).size? = some usize := by
      first | rfl | simp [Spec.Ty.size?, Spec.Ty.layout, LayoutStrategy.size?]
    have hlW : (writeAt (List.replicate usize AbstractByte.uninit) off e0).length =
        (Spec.Ty.union ufields chunks usize ual).size := by
      rw [Ryo.Spec.Theorems.writeAt_length _ _ _ (by rw [List.length_replicate]; omega),
        List.length_replicate, tySize_of hsU]
    obtain ⟨bs', he', hle⟩ := Ryo.Spec.Theorems.encode_decode_le _ _ _ hwf hlW hdu
    have e7 : bs' = bsd := Option.some.inj (he'.symm.trans hen)
    rw [e7] at hle
    refine ⟨pd, [e0], bsd, hld, hl3, rfl, hfms, hbds, ?_, ?_, ?_⟩
    · show bytesLeDefined bsd (writeAt (List.replicate sd.size .uninit) off e0) = true
      rw [← hsz]; exact hle
    · rw [hs']; exact hsto
    · rw [hs']
  next => exact (runOn_illFormed_inv h6).elim

/-! ### The lift -/

-- `lift_unionAgg` and `stmt_sim_unionAgg` (any destination) are in `SimUnionAggDst.lean`.

end Ryo.Proofs.Lower
