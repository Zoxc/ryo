/-
Ryo.Proofs.Lower.SimAggDst — the lift of `LowerAgg` (`agg`, `useAny`) with a destination that
may be escaped (M5b): the rules no longer require `_d`'s slot private.

- `lift_aggMemP`: `SimAgg.lift_aggMem` (which stays, with its static `hpriv`, for the families
  that call it) with R's privacy of the slot as a premise instead.
- `lift_aggMemE`: an escaped `_d` (its slot inside one object `e`, allocation `y`): the pieces
  by `sim_piecesE` (SimAggEsc.lean), whose `ObjInv` gives `WroteAt` (`ObjInv.wroteAt`) for
  `writeLocal_esc_wrote` (`writeLocal_esc` from a `WroteAt`: `MemInj.wrote`, `hdisj` from
  `LiveDisjoint` by `liveDisjoint_apart`) and the other locals (`LocalRel.objInv`). The bytes
  are `pieceFrame_aggPieces`' with the frame view `frameByte` (R reads `y` there).
- `lift_aggMemX`: by `_d`'s `LocalRel`: private, or escaped of size 0, goes to `lift_aggMemP`;
  escaped to `lift_aggMemE` (with `EscIdOff`).
- `lift_agg`: `LowerAgg`'s lift, taking `LiveDisjoint` (`MatchAt(X).dinv.2`) and `EscIdOff`
  (`escIdOff_of_noEsc` without scopes, `FnRelX.escIdOff` with them).
-/
import Ryo.Proofs.Lower.SimAggEsc

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-- A live L0 allocation `x` (at `pa`, `n > 0` bytes): any other live allocation is apart from
it (`LiveDisjoint`), the `hdisj` of `MemInj.wrote`. -/
theorem liveDisjoint_apart {m0 : Memory} (hld : LiveDisjoint m0) {a : AllocId}
    {x : Allocation} {pa n : Nat} (hx : m0.get? a = some x) (hl : x.live = true)
    (hpa : pa = x.addr) (hxs : x.data.size = n) (hpos : 0 < n) (ι : Inj) (b : AllocId) :
    ∀ a' x', m0.get? a' = some x' → x'.live = true → ι a' = some b → a' ≠ a →
      x'.size = 0 ∨ x'.addr + x'.size ≤ pa ∨ pa + n ≤ x'.addr := by
  intro a' x' hx' hl' _ hne
  -- `Allocation.size` is `Size`-valued: state everything over `data.size` (`Nat`)
  show x'.data.size = 0 ∨ x'.addr + x'.data.size ≤ pa ∨ pa + n ≤ x'.addr
  by_cases c1 : x'.data.size = 0
  · exact .inl c1
  by_cases c2 : x'.addr + x'.data.size ≤ pa
  · exact .inr (.inl c2)
  by_cases c3 : pa + n ≤ x'.addr
  · exact .inr (.inr c3)
  exfalso
  apply hne
  by_cases c4 : x.addr ≤ x'.addr
  · exact hld a' a x' x x'.addr hx' hx hl' hl (Nat.le_refl _)
      (by show x'.addr < x'.addr + x'.data.size; omega) c4
      (by show x'.addr < x.addr + x.data.size; omega)
  · exact hld a' a x' x x.addr hx' hx hl' hl (by omega)
      (by show x.addr < x'.addr + x'.data.size; omega) (Nat.le_refl _)
      (by show x.addr < x.addr + x.data.size; omega)

/-- `writeLocal_esc` from R's memory change given as `WroteAt` (several frame writes into the
object, not one `writeFrame`). -/
theorem writeLocal_esc_wrote {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p : ThinPointer} (hm : MemInj ι m0 st.mem)
    (a : AllocId) (x : Allocation) (e : OpSem.EscapedObj) (y : Allocation)
    (hp : p.prov = some a) (hι : ι a = some e.id) (hx : m0.get? a = some x)
    (hlive : x.live = true) (haddr : (x.addr : Int) = fp + slot.off) (hpaddr : p.addr = x.addr)
    (hsize : x.data.size = slot.size)
    (hin : ∀ k < slot.size, st.escapedAt (slot.off + k) = some e)
    (hy : st.mem.get? e.id = some y) (hylive : y.live = true)
    (hyaddr : (y.addr : Int) = fp + e.off) (hysize : y.data.size = e.size)
    (hdisj : ∀ a' x', m0.get? a' = some x' → x'.live = true → ι a' = some e.id → a' ≠ a →
      x'.size = 0 ∨ x'.addr + x'.size ≤ p.addr ∨ p.addr + slot.size ≤ x'.addr)
    (hpos : 0 < slot.size)
    {bs0 bs1 : List AbstractByte} (hbs : BytesInj ι bs0 bs1) (hlen : bs0.length = slot.size)
    {al : Align} (h0 : m0.store p bs0 al = .ok m0')
    (hea : ∀ o, st'.escapedAt o = st.escapedAt o)
    (hw : WroteAt st.mem st'.mem e.id p.addr bs1) :
    MemInj ι m0' st'.mem ∧ LocalRel ι fp st' m0' slot p true := by
  have hmi : MemInj ι m0' st'.mem :=
    MemInj.wrote hm hp hι hbs h0 (by omega) hw (fun a' x' g1 g2 g3 g4 => by
      rw [hlen]; exact hdisj a' x' g1 g2 g3 g4)
  refine ⟨hmi, ?_⟩
  have hlt : a < m0.allocs.size :=
    (Array.getElem?_eq_some_iff.mp (show m0.allocs[a]? = some x from hx)).1
  have hlt' : a < m0'.allocs.size := by rw [store_size h0]; exact hlt
  obtain ⟨x0, hx0, hxa, hxl, hxs⟩ := store_get?_fwd h0 (get?_of_lt hlt')
  have e3 : x0 = x := Option.some.inj (hx0.symm.trans hx)
  rw [e3] at hxa hxl hxs
  obtain ⟨y', hy', -, hyb⟩ := hw e.id y hy
  obtain ⟨arr, rfl, hsz, -⟩ := hyb rfl
  exact .esc a m0'.allocs[a] e { y with data := arr } hp hι (get?_of_lt hlt')
    (by rw [← hxl]; exact hlive) (by rw [← hxa]; exact haddr) (by rw [← hxa]; exact hpaddr)
    (by rw [← hxs]; exact hsize) (fun k hk => (hea _).trans (hin k hk)) hy' hylive hyaddr
    (hsz.trans hysize)

/-- `lift_aggMem` with the slot's privacy in R (`hpv`) instead of the static `hpriv`. -/
theorem lift_aggMemP {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
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
    (hmm : AggMem f d sd.size fields srcs s s') :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  obtain ⟨pd, ebs, hpd, hl1, hl2, hfm, hbd, hsto, hstk⟩ := hmm
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
  -- `_d`'s relation after the statement
  obtain ⟨sd', hsd', hrd0⟩ := hrel.frame.locals d pd hpd (by rw [hrel.unaliased]; simp)
  rw [hsd] at hsd'
  obtain rfl := Option.some.inj hsd'
  have hdst : MemInj ι s'.mem st'.mem ∧ LocalRel ι s1.fp st' s'.mem sd pd true := by
    cases hrd0 with
    | priv a x hp hι hx hlive haddr hpaddr hsize hpv _ =>
      exact frameLocal_priv hrel.frame.mem a x hp hι hx hlive haddr hpaddr hsize hpv hLlen hbsL
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
        · exact absurd (hLlen.trans hz) hne
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
  have hprov := aggStored_prov (N := sd.size) (fields := fields) hl1 hfm
  have hhid' : ∀ b ∈ writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs),
      ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs0, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hrel.hidden.load hld _ (List.getElem_mem hj) fr0 hf0
  have hbd' : BytesBounded s.mem.allocs.size
      (writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs)) := by
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


/-- An escaped destination (see the module comment). -/
theorem lift_aggMemE {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
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
    (hmm : AggMem f d sd.size fields srcs s s')
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
  obtain ⟨pd', ebs, hpd', hl1, hl2, hfm, hbd, hsto, hstk⟩ := hmm
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
  have hbs : BytesInj ι (writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs))
      ((List.range sd.size).map fun k : Nat => pieceFrame (frameByte s1.st)
        (aggPieces sd.off fields srcs) (frameByte s1.st) (sd.off + (k : Int))) := by
    apply BytesInj_of_getElem (by simp [hLlen])
    intro k h0 h1
    simp only [List.getElem_map, List.getElem_range]
    exact hLrel k h0
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
    hsize hin hy hyl hya hys hdisj hpos hbs hLlen hsto hea hw
  have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
      p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' s'.mem slot p lv := by
    intro slot p lv hr hne _
    exact (hr.objInv I hy).store_other hsto (.inl (Ne.symm hne))
  -- L0's memory invariants, as `lift_aggMem`
  have hprov := aggStored_prov (N := sd.size) (fields := fields) hl1 hfm
  have hhid' : ∀ b ∈ writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs),
      ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs0, hld0, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hrel.hidden.load hld0 _ (List.getElem_mem hj) fr0 hf0
  have hbd' : BytesBounded s.mem.allocs.size
      (writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs)) := by
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

/-- An aggregate's pieces into `_d`, private or escaped (see the module comment). -/
theorem lift_aggMemX {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
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
    (hmm : AggMem f d sd.size fields srcs s s') :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  obtain ⟨pd, _, hpd, _⟩ := id hmm
  obtain ⟨sd', hsd', hr⟩ := hrel.frame.locals d pd hpd (by rw [hrel.unaliased]; simp)
  rw [hsd] at hsd'
  have e := (Option.some.inj hsd').symm
  rw [e] at hr
  cases hr with
  | priv a x hp hι hx hl haddr hpaddr hsz hpv _ =>
    exact lift_aggMemP hmode hρ hsd hoff (fun o h1 h2 => by
      have := hpv (o - sd.off).toNat (by omega)
      rwa [show sd.off + ((o - sd.off).toNat : Int) = o by omega] at this)
      hf hpo hi hsc hpe hpl hrel hpb hla hlive' hmm
  | esc a x e y hp hι hx hl haddr hpaddr hsz hin hy hyl hya hys =>
    by_cases hz : sd.size = 0
    · exact lift_aggMemP hmode hρ hsd hoff (fun o h1 h2 => absurd h2 (by omega))
        hf hpo hi hsc hpe hpl hrel hpb hla hlive' hmm
    · exact lift_aggMemE hmode hρ hsd hoff hf hpo hi hsc hpe hpl hrel hpb hld hla hlive' hmm
        hpd hp hι hx hl haddr hpaddr hsz hin hy hyl hya hys (by omega)
        (fun o e2 h2 hid => hio _ _ _ _ h2 (hin 0 (by omega)) hid)

/-- `LowerAgg`'s lift (any destination).

Proof: as `SimAgg`'s former `lift_agg` (`agg_mem`/`aggUse_mem`, the live sources from
`aggFields_slot_mem`), with `lift_aggMemX`. -/
theorem lift_agg {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerAgg Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem) (hio : EscIdOff s1.st)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | agg hk htd hlay hsz hsd hoff hf hpo =>
    have hmm := agg_mem hs hbody hk htd hlay hsz hf h
    refine lift_aggMemX hmode hρ hsd hoff hf hpo hi hsc hpe hpl hrel hpb hld hio ?_ hlive' hmm
    intro src hsrc a so ws he
    apply hlo
    have := aggFields_slot_mem hf src hsrc a so ws he
    simpa [rvalueLocals] using this
  | useAny htd hsz hsd hoff hf hpo =>
    have hmm := aggUse_mem hs hbody htd hsz hf h
    have hf' := AggFields.cons hf AggFields.nil
    refine lift_aggMemX hmode hρ hsd hoff hf' (by rw [aggPieces_single]; exact hpo)
      hi hsc hpe hpl hrel hpb hld hio ?_ hlive' hmm
    intro src' hsrc a so ws he
    apply hlo
    have := aggFields_slot_mem hf' src' hsrc a so ws he
    simpa [rvalueLocals] using this

end Ryo.Proofs.Lower
