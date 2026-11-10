/-
Ryo.Proofs.Lower.SimUnionAggDst — `LowerUnionAgg`'s lift with a destination that may be escaped
(M5b), as `SimAggDst.lean` for `LowerAgg`: `lift_aggMemLeP` (`SimUnionAgg.lift_aggMemLe`, which
stays, with R's privacy of the slot as a premise), `lift_aggMemLeE` (`lift_aggMemE` with the
stored bytes below the fields' writes: `ByteInj.of_le'`, `le_prov`), `lift_aggMemLeX` (by `_d`'s
`LocalRel`), then `lift_unionAgg` and `stmt_sim_unionAgg` (moved from SimUnionAgg.lean).
-/
import Ryo.Proofs.Lower.SimUnionAgg
import Ryo.Proofs.Lower.SimAggDst

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-- `lift_aggMemLe` with the slot's privacy in R (`hpv`) instead of the static `hpriv`. -/
theorem lift_aggMemLeP {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {ops : List Operand} {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc}
    {sd : LocalSlot} {is : List R.Insn}
    (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
    (hpv : ∀ o, sd.off ≤ o → o < sd.off + sd.size → s1.st.escapedAt o = none)
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
  have hesc' := hpv
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
          have h3 := hin 0 (by omega)
          rw [hpv (sd.off + ((0 : Nat) : Int)) (by omega) (by omega)] at h3
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

/-- `lift_aggMemE` for `AggMemLe` (the stored bytes below the fields' writes,
`ByteInj.of_le'`, `le_prov`). -/
theorem lift_aggMemLeE {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {ops : List Operand} {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc}
    {sd : LocalSlot} {is : List R.Insn}
    (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
    (hf : AggFields Γ sd ops fields srcs)
    (hpo : piecesOk Γ is (aggPieces sd.off fields srcs) = true)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hla : ∀ src ∈ srcs, ∀ a so ws, src = .slot a so ws → live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hmm : AggMemLe f d sd.size fields srcs s s')
    {pd : ThinPointer} {a : AllocId} {x : Allocation} {e : EscapedObj} {y : Allocation}
    (hpd : f.locals[d]? = some (some pd)) (hp : pd.prov = some a) (hι : ι a = some e.id)
    (hx : s.mem.get? a = some x) (hlive : x.live = true)
    (haddr : (x.addr : Int) = s1.fp + sd.off) (hpaddr : pd.addr = x.addr)
    (hsize : x.data.size = sd.size)
    (hin : ∀ k < sd.size, s1.st.escapedAt (sd.off + k) = some e)
    (hy : s1.st.mem.get? e.id = some y) (hyl : y.live = true)
    (hya : (y.addr : Int) = s1.fp + e.off) (hys : y.data.size = e.size) (hpos : 0 < sd.size)
    (hio : ∀ o (e2 : EscapedObj), s1.st.escapedAt o = some e2 → e2.id = e.id → e2.off = e.off) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  obtain ⟨pd', ebs, bsd, hpd', hl1, hl2, hfm, hbd, hleW, hsto, hstk⟩ := hmm
  have e0 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  rw [e0] at hsto
  have hfl := AggFields.length hf
  have hwithin := aggPieces_within hf hoff
  have hlh : ∀ o, sd.off ≤ o → o < sd.off + sd.size → s1.st.escapedAt o = some e := by
    intro o h1 h2
    have := hin (o - sd.off).toNat (by omega)
    rwa [show sd.off + ((o - sd.off).toNat : Int) = o by omega] at this
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
  -- R: the pieces write the object
  obtain ⟨st', hsteps, I⟩ := sim_piecesE (ch := ch) (src := frameByte s1.st) hmode hρ
    (by omega : sd.off < sd.off + sd.size) hlh hy hys hio hpo hi hsc hpe hpl hwithin
    (objInv_init hlh hy hyl hys) hsrcs
  -- the bytes
  obtain ⟨hLlen, hLrel⟩ := pieceFrame_aggPieces (ι := ι) (src := frameByte s1.st) (base := sd.off)
    (acc := List.replicate sd.size .uninit) (fr := frameByte s1.st) (by omega) hl1
    (fun j h1 h2 => (hsrc1 j h1 h2).1)
    (fun j h1 h2 => by rw [List.length_replicate]; exact hbd j h1 h2)
    (fun k h => by simp only [List.getElem_replicate]; exact True.intro)
  rw [List.length_replicate] at hLlen
  -- the stored bytes are below the fields' writes
  obtain ⟨hlW, hpW⟩ := (Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hleW
  have hLlen' : bsd.length = sd.size := hlW.trans hLlen
  have hbs : BytesInj ι bsd
      ((List.range sd.size).map fun k : Nat => pieceFrame (frameByte s1.st)
        (aggPieces sd.off fields srcs) (frameByte s1.st) (sd.off + (k : Int))) := by
    apply BytesInj_of_getElem (by simp [hLlen'])
    intro k h0 h1
    simp only [List.getElem_map, List.getElem_range]
    exact ByteInj.of_le' (hpW k h0 (by omega)) (hLrel k (by omega))
  -- `_d`'s relation and `MemInj`
  obtain ⟨y2, hy2, hxy⟩ := hrel.frame.mem a e.id x hx hι
  have e2 : y2 = y := Option.some.inj (hy2.symm.trans hy)
  rw [e2] at hxy
  have hlo : y.addr ≤ x.addr := hxy.lo
  have hend := (Ryo.Proofs.Inline.escapedAt_some (hin (sd.size - 1) (by omega))).2.2
  have hw := I.wroteAt hy (pa := pd.addr) (n := sd.size) (by omega) (by omega) rfl (by omega)
  have hea : ∀ o, st'.escapedAt o = s1.st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [I.esc]
  have hdisj := liveDisjoint_apart hld hx hlive hpaddr hsize hpos ι e.id
  obtain ⟨hmi, hrd⟩ := writeLocal_esc_wrote hrel.frame.mem a x e y hp hι hx hlive haddr hpaddr
    hsize hin hy hyl hya hys hdisj hpos hbs hLlen' hsto hea hw
  have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
      p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' s'.mem slot p lv := by
    intro slot p lv hr hne _
    exact (hr.objInv I hy).store_other hsto (.inl (Ne.symm hne))
  -- L0's memory invariants, as `lift_aggMem`
  have hprovW := aggStored_prov (N := sd.size) (fields := fields) hl1 hfm
  have hprov : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ∃ pa n bs0,
      s.mem.load pa n .one = .ok bs0 ∧
      ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := le_prov hleW b hb fr hfr
    obtain ⟨pa, n, bs0, hld0, j', hj', fr1, hf1, he1⟩ := hprovW _ (List.getElem_mem hj) fr0 hf0
    exact ⟨pa, n, bs0, hld0, j', hj', fr1, hf1, he1.trans he0⟩
  have hhid' : ∀ b ∈ bsd,
      ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs0, hld0, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hrel.hidden.load hld0 _ (List.getElem_mem hj) fr0 hf0
  have hbd' : BytesBounded s.mem.allocs.size bsd := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs0, hld0, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hpb.load hld0 _ (List.getElem_mem hj) fr0 hf0
  exact ⟨st', hsteps, hstk,
    hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') I.esc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
    memKept_store hsto fun A hA b hb fr hfr => by
      obtain ⟨pa, n, bs0, hld0, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
      rw [← he0]
      exact hA.load hld0 _ (List.getElem_mem hj) fr0 hf0⟩

/-- `lift_aggMemX` for `AggMemLe`. -/
theorem lift_aggMemLeX {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {ops : List Operand} {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc}
    {sd : LocalSlot} {is : List R.Insn}
    (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
    (hf : AggFields Γ sd ops fields srcs)
    (hpo : piecesOk Γ is (aggPieces sd.off fields srcs) = true)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem) (hio : EscIdOff s1.st)
    (hla : ∀ src ∈ srcs, ∀ a so ws, src = .slot a so ws → live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hmm : AggMemLe f d sd.size fields srcs s s') :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  obtain ⟨pd, _, _, hpd, _⟩ := id hmm
  obtain ⟨sd', hsd', hr⟩ := hrel.frame.locals d pd hpd (by rw [hrel.unaliased]; simp)
  rw [hsd] at hsd'
  have e := (Option.some.inj hsd').symm
  rw [e] at hr
  cases hr with
  | priv a x hp hι hx hl haddr hpaddr hsz hpv _ =>
    exact lift_aggMemLeP hmode hρ hsd hoff (fun o h1 h2 => by
      have := hpv (o - sd.off).toNat (by omega)
      rwa [show sd.off + ((o - sd.off).toNat : Int) = o by omega] at this)
      hf hpo hi hsc hpe hpl hrel hpb hla hlive' hmm
  | esc a x e y hp hι hx hl haddr hpaddr hsz hin hy hyl hya hys =>
    by_cases hz : sd.size = 0
    · exact lift_aggMemLeP hmode hρ hsd hoff (fun o h1 h2 => absurd h2 (by omega))
        hf hpo hi hsc hpe hpl hrel hpb hla hlive' hmm
    · exact lift_aggMemLeE hmode hρ hsd hoff hf hpo hi hsc hpe hpl hrel hpb hld hla hlive' hmm
        hpd hp hι hx hl haddr hpaddr hsz hin hy hyl hya hys (by omega)
        (fun o e2 h2 hid => hio _ _ _ _ h2 (hin 0 (by omega)) hid)

/-- `LowerUnionAgg`'s lift: `unionAgg_mem`, then `lift_aggMemLe` with the one field (the live
sources as `lift_agg`'s). -/
theorem lift_unionAgg {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerUnionAgg Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem) (hio : EscIdOff s1.st)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @mk d variant fi op ufields chunks usize ual off fty sd src is htd hwf hfld hsz hsd hoff
      hfa hpo =>
    have hmm := unionAgg_mem hs hbody htd hwf hfld hsz hfa h
    have hf1 : AggFields Γ sd [op] [(off, fty)] [src] := .cons hfa .nil
    have hpe' : aggPieces sd.off [(off, fty)] [src] = srcPieces (sd.off + off) src := by
      simp [aggPieces]
    refine lift_aggMemLeX hmode hρ hsd hoff hf1 (by rw [hpe']; exact hpo) hi hsc hpe hpl
      hrel hpb hld hio ?_ hlive' hmm
    intro src' hsrc a so ws he
    apply hlo
    have := aggFields_slot_mem hf1 src' hsrc a so ws he
    simpa [rvalueLocals] using this

/-- `LowerUnionAgg` in a scope-free function: `stmt_sim`'s case (as its `castMore` case). -/
theorem stmt_sim_unionAgg {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerUnionAgg Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    cases h; exact ⟨_, _, rfl⟩
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
  exact lift_unionAgg M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    M.dinv.2 (escIdOff_of_noEsc M.rel hfn.noEsc) hl2 hl1 hev

end Ryo.Proofs.Lower
