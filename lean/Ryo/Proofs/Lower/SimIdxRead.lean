/-
Ryo.Proofs.Lower.SimIdxRead — the simulation of `LowerIdxRead` (`Check/Lower/IdxRead.lean`, M5b):
`_d = copy _a[_l]` for a local array `_a`, lowered to the `Escape` of `_a`'s slot, then
`addr t, a; ptr.index t, t, l, stride; load.wN d, [t + 0]`.

L0 (`idxRead_mem`): `_a`'s pointer `pa`, the index `u % 2^64` read from `_l`'s 8 bytes
(`runOn_projectPlace_indexArray`, as `SimRefDerefIdx.runOn_projectPlace_indexSlice` with the
array's own length), the element loaded at `pa + (u % 2^64) * elem.size` (below `ADDR_LIMIT`), its
re-encoding stored into `_d`.

R (`lift_idxRead`, as `SimRef.lift_ref`): the own `Escape` (`scope_escape_rel`) makes `_a`
escaped; `addr` gives R's pointer `p1` to its object (`addrOf_inj`) into the private temporary
(`EscInSlots`, `FnRel.tempWrite`); `ptr.index` moves it by `(u * stride) % 2^64`, L0's offset
(`SimOffset.opSem_ptrIndex_fwd`, `wrappingOffset_addr`); `load` is `SimDerefWide.sim_derefLoadW`
from the temporary's pointer bytes (`decodePtr_encodePtr`, `encodePtr_inj'`), the element's
allocation mapped (`ι'` maps `_a`'s), `_d` written through `DstWrite`. `FnRelX.keep` carries
`FnRelX`'s fields from the escape's state to the end (the objects kept, the allocations kept by
the frame writes, L0's liveness by the store). `LiftOutXN`/`stmtOutX_of_liftXN` are `LiftOutX`/
`stmtOutX_of_liftX` over `k` steps.
-/
import Ryo.Proofs.Lower.SimRefDerefIdx
import Ryo.Proofs.Lower.SimCmpMoreX
import Ryo.Check.Lower.IdxRead

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### L0 -/

/-- The `.index` projection of a local array place (as `runOn_projectPlace_indexSlice`). -/
theorem runOn_projectPlace_indexArray {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {l : Local} {vi : ValidRange}
    (hti : f.body.locals[l]? = some (.int IntType.usize vi)) {q : ThinPointer}
    {elem : Spec.Ty} {len : Nat} {y : Spec.Place × Spec.Ty}
    (h : runOn (projectPlace ⟨q.widen, true⟩ (.array elem len) (.index l)) o s = (.ok y, s1)) :
    ∃ pl bi u, f.locals[l]? = some (some pl) ∧ s.mem.load pl 8 .one = .ok bi ∧
      decodeBits bi = some u ∧
      q.addr + (u % 2 ^ 64) * elem.size < Target.ADDR_LIMIT ∧
      y = (⟨(⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ : ThinPointer).widen, true⟩, elem) ∧
      s1 = s := by
  simp only [projectPlace] at h
  obtain ⟨i, s2, hri, h2⟩ := runOn_bind_ok h
  have hri' : runOn (readIndexLocal l) o s = (.ok i, s2) := hri
  unfold readIndexLocal at hri'
  obtain ⟨x0, s5, hlp0, h7⟩ := runOn_bind_ok hri'
  obtain ⟨pl, tl, hpl, htl, hx0, hs5⟩ := runOn_localPlace_ok hs hlp0
  subst hx0
  have etl : tl = .int IntType.usize vi := Option.some.inj (htl.symm.trans hti)
  subst etl
  rw [hs5] at h7
  obtain ⟨v0, s6, hpl0, h8⟩ := runOn_bind_ok h7
  obtain ⟨hv0, hs6⟩ := runOn_placeLoad_ok hpl0
  obtain ⟨bi, u, hlb, hdb, -, hv⟩ := typedLoad_int hv0
  subst hv
  rw [hs6] at h8
  rw [ofBits_usize] at h8
  have h8' : runOn (pure (((u % 2 ^ 64 : Nat) : Int)).toNat : SemM Nat) o s = (.ok i, s2) := by
    first
      | (simp only [ge_iff_le, Int.natCast_nonneg, ↓reduceIte] at h8; exact h8)
      | (rw [if_pos (Int.natCast_nonneg _)] at h8; exact h8)
      | (dsimp only at h8; rw [if_pos (Int.natCast_nonneg _)] at h8; exact h8)
      | (simp at h8 ⊢; exact h8)
  obtain ⟨hi, hs2⟩ := runOn_pure_inv h8'
  have hi' : i = u % 2 ^ 64 := by
    rw [hi]
    first
      | exact Int.toNat_natCast _
      | exact Int.toNat_ofNat _
      | omega
      | simp
  subst hi'
  rw [hs2] at h2
  -- `elemsOf` of an array
  obtain ⟨x1, s7, hel, h9⟩ := runOn_bind_ok h2
  have hel' : runOn (elemsOf ⟨q.widen, true⟩ (.array elem len)) o s = (.ok x1, s7) := hel
  simp only [elemsOf] at hel'
  obtain ⟨hx1, hs7⟩ := runOn_pure_inv hel'
  subst hx1
  rw [hs7] at h9
  -- the bounds check, then the offset
  dsimp only at h9
  split at h9
  next =>
    obtain ⟨_, _, h10, -⟩ := runOn_bind_ok h9
    rw [runOn_throwUb] at h10
    exact (prod_err_ok h10).elim
  next =>
    try dsimp only at h9
    have h9' : runOn (ptrOffsetInbounds q (((u % 2 ^ 64) * elem.size : Nat) : Int) >>=
        fun q' => pure ((⟨q'.widen, true⟩ : Spec.Place), elem)) o s = (.ok y, s1) := by
      first
        | exact h9
        | (rw [Int.natCast_mul]; exact h9)
        | (simp only [Int.natCast_mul]; exact h9)
        | (simp only [pure_bind] at h9; exact h9)
        | (simp only [pure_bind] at h9; rw [Int.natCast_mul]; exact h9)
    obtain ⟨hy, hs1, hlt⟩ := runOn_offset_place_al h9'
    exact ⟨pl, bi, u, hpl, hlb, hdb, hlt, hy, hs1⟩

/-- `_d = copy _a[_l]` run to success, in memory terms. -/
theorem idxRead_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a l : Local} {elem : Spec.Ty}
    {len n : Nat} {vi : ValidRange}
    (hta : f.body.locals[a]? = some (.array elem len))
    (hti : f.body.locals[l]? = some (.int IntType.usize vi))
    (htd : f.body.locals[d]? = some elem) (hn : elem.size? = some n)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.copy ⟨a, [.index l]⟩)))) o s =
      (.ok (), s')) :
    ∃ pd pa pl bi u bs0 v bsd, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      f.locals[l]? = some (some pl) ∧ s.mem.load pl 8 .one = .ok bi ∧ decodeBits bi = some u ∧
      pa.addr + (u % 2 ^ 64) * elem.size < Target.ADDR_LIMIT ∧
      s.mem.load ⟨pa.addr + (u % 2 ^ 64) * elem.size, pa.prov⟩ n .one = .ok bs0 ∧
      elem.decode bs0 = some v ∧ elem.encode v = some bsd ∧
      s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  obtain ⟨pd, td, rv, s1, hpd, htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  have e : evalOperand (.copy ⟨a, [.index l]⟩) =
      (evalPlace ⟨a, [.index l]⟩ >>= fun x => match x with
        | (pl, ty) => placeLoad pl ty >>= fun v => pure (v, ty)) := rfl
  rw [e] at hev
  obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok hev
  have e1 : evalPlace ⟨a, [.index l]⟩ = (localPlace a >>= fun init =>
      [ProjElem.index l].foldlM (fun (pl, ty) pe => projectPlace pl ty pe) init) := rfl
  rw [e1] at h1
  obtain ⟨init, s3, h3, h4⟩ := runOn_bind_ok h1
  obtain ⟨pa, ta, hpa, hta', hinit, hs3⟩ := runOn_localPlace_ok hs h3
  subst hinit
  have e2 : ta = .array elem len := Option.some.inj (hta'.symm.trans hta)
  subst e2
  rw [hs3, List.foldlM_cons] at h4
  obtain ⟨y, s4, h5, h6⟩ := runOn_bind_ok h4
  have h5' : runOn (projectPlace ⟨pa.widen, true⟩ (.array elem len) (.index l)) o s =
      (.ok y, s4) := h5
  obtain ⟨pl, bi, u, hpl, hlb, hdb, hlim, rfl, hs4⟩ := runOn_projectPlace_indexArray hs hti h5'
  rw [hs4] at h6
  have h6' : runOn (pure ((⟨(⟨pa.addr + (u % 2 ^ 64) * elem.size, pa.prov⟩ :
      ThinPointer).widen, true⟩ : Spec.Place), elem) : SemM (Spec.Place × Spec.Ty)) o s =
      (.ok x, s2) := h6
  obtain ⟨hx, hs2⟩ := runOn_pure_inv h6'
  subst hx
  rw [hs2] at h2
  have h2' : runOn (placeLoad ⟨(⟨pa.addr + (u % 2 ^ 64) * elem.size, pa.prov⟩ :
      ThinPointer).widen, true⟩ elem >>= fun v => pure (v, elem)) o s = (.ok rv, s1) := h2
  obtain ⟨v, s5, h7, h8⟩ := runOn_bind_ok h2'
  obtain ⟨hv, hs5⟩ := runOn_placeLoad_ok h7
  obtain ⟨hrv, hs1⟩ := prod_ok_inj h8
  have hs1' : s1 = s := hs1.symm.trans hs5
  have e4 : td = elem := Option.some.inj (htd'.symm.trans htd)
  subst e4
  obtain ⟨bs0, hlo, hd⟩ := typedLoad_inv hn hv
  rw [← hrv, hs1'] at hst
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  exact ⟨pd, pa, pl, bi, u, bs0, v, bsd, hpd, hpa, hpl, hlb, hdb, hlim, hlo, hd, hen, hsto,
    by rw [hs1']⟩

/-! ### `FnRelX` across steps that keep R's objects and allocations -/

/-- `FnRelX` at `s2` from `FnRelX` at `s0` and `FnRel` at `s2`, when the steps between kept R's
escaped objects, its frame pointer and its allocations (`AllocsKept`), and L0's allocations
were live before if they are after (the proof of `lift_ref`'s other fields). -/
theorem FnRelX.keep {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 m0' : Memory} {s0 s2 : R.RState} (hX : FnRelX Γ ι live f m0 s0)
    (hrel : FnRel Γ ι live' f m0' s2) (hesc : s2.st.escaped = s0.st.escaped)
    (hfp : s2.fp = s0.fp) (hak : AllocsKept s0.st.mem s2.st.mem)
    (hagree : ∀ q x1, m0'.get? q = some x1 →
      ∃ x0, m0.get? q = some x0 ∧ (x1.live = true → x0.live = true)) :
    FnRelX Γ ι live' f m0' s2 := by
  refine ⟨hrel, fun e' he' => ?_, ?_, fun q b x e' hq hx hl' he' hid => ?_,
    fun j y hy hl' => ?_, hX.aligned, fun e' he' => ?_, fun e' he' y hy => ?_⟩
  · rw [hesc] at he'
    exact hX.objs e' he'
  · rw [hesc]
    exact hX.disj
  · rw [hesc] at he'
    obtain ⟨x0, h1, hl0⟩ := hagree q x hx
    exact hX.owned q b x0 e' hq h1 (hl0 hl') he' hid
  · obtain ⟨y0, hy0, hadd, hlv, hsz⟩ := hak.2 j y hy
    rcases hX.free j y0 hy0 (by rw [← hlv]; exact hl') with ⟨e2, he2, h1, h2, h3⟩ | hfr
    · refine .inl ⟨e2, ?_, h1, ?_, ?_⟩
      · rw [hesc]; exact he2
      · rw [hadd, hfp]; exact h2
      · rw [hsz]; exact h3
    · refine .inr fun l sl hsl => ?_
      rw [hadd, hsz, hfp]
      exact hfr l sl hsl
  · rw [hesc] at he'
    rw [hak.1]
    exact hX.idLt e' he'
  · rw [hesc] at he'
    obtain ⟨y0, hy0, hadd, -, -⟩ := hak.2 e'.id y hy
    rw [hadd, hfp]
    exact hX.addrAt e' he' y0 hy0

/-! ### Several steps with scopes -/

/-- `LiftOutX` over `k` steps. -/
def LiftOutXN (Γ : StmtCtx) (c : R.Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (f : Spec.Frame) (s s' : Spec.State) (s1 s0 : R.RState) (k : Nat) : Prop :=
  ∃ ι' st', ι.Le ι' ∧ (∀ a, s.mem.allocs.size ≤ a → ι' a = ι a) ∧
    StepsTo c ch s1 { s0 with pc := s0.pc + k, st := st' } ∧
    s'.stack = s.stack ∧
    FnRelX Γ ι' live' f s'.mem { s0 with pc := s0.pc + k, st := st' } ∧
    ProvBounded s'.mem ∧ s.mem.allocs.size ≤ s'.mem.allocs.size ∧ DerefInv ι' s'.mem

/-- `stmtOutX_of_liftX` over `k` steps (the same proof). -/
theorem stmtOutX_of_liftXN {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {f : Spec.Frame} {rest : List Spec.Frame} {bd : BlockData} {blk : BlockCert}
    {s s' : Spec.State} {s1 s0 : R.RState} {d : Local} {rv : Rvalue} {k : Nat}
    (hs : s.stack = f :: rest) (hstor : StorageSound Γ.body (computeStorage Γ.body).get)
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hst : bd.stmts[f.stmt]? = some (.assign ⟨d, []⟩ rv))
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hfr : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hpc : s0.pc + k = pcAt blk (f.stmt + 1))
    (hpend0 : pendSpecs Γ.toStmtCtx bd blk (f.stmt + 1) = [])
    (hl : LiftOutXN Γ.toStmtCtx c ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f s s' s1
      s0 k) :
    StmtOutX Γ c ch ι f rest bd blk s s' s1 := by
  obtain ⟨ι', st', hle, hfix, hsteps, hstk, hrel, hpb, hsz, hdi⟩ := hl
  refine ⟨ι', { s0 with pc := s0.pc + k, st := st' }, { s0 with pc := s0.pc + k, st := st' }, f,
    hle, hsteps, hstk.trans hs, rfl, rfl, rfl, rfl, rfl, hpc, ?_, hrel, ?_, hpb, ?_, hdi⟩
  · rw [hpend0]
    rfl
  · intro l p hp
    exact (hstor.stmt f.bb bd hbd f.stmt _ hst).1 l (hsl l p hp) (by intro e; cases e)
  · intro a ha
    rw [hfix a (Nat.le_trans hsz ha)]
    exact hfr a (Nat.le_trans hsz ha)

/-! ### The lift -/

/-- `LowerIdxRead`'s lift (see the module comment). -/
theorem lift_idxRead {Γ : StmtCtx} {c : R.Code} {s1 s0 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i1 i2 i3 : R.Insn}
    (hlow : LowerIdxRead Γ (.assign ⟨d, []⟩ rv) [i1, i2, i3])
    (hc0 : c.d.insns[s1.pc]? = some i1) (hc1 : c.d.insns[s1.pc + 1]? = some i2)
    (hc2 : c.d.insns[s1.pc + 2]? = some i3)
    {pre : List R.Scope} {sc : R.Scope} (hsc : c.scopesAt s1.pc = pre ++ [sc])
    (hpre : pre.foldlM R.applyScope s1 = .ok s0)
    (hown : specsOk (ownSpec Γ (.assign ⟨d, []⟩ rv)) [sc] = true)
    (hsc1 : c.scopesAt (s1.pc + 1) = []) (hsc2 : c.scopesAt (s1.pc + 2) = [])
    (hpe : c.mode.pe = false) (hpl0 : PlainView c.mode c.ρ i1)
    (hpl1 : PlainView c.mode c.ρ i2) (hpl2 : PlainView c.mode c.ρ i3)
    (hrel : FnRelX Γ ι live f s.mem s0) (hpb : ProvBounded s.mem)
    (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    ∃ s0', R.applyScope s0 sc = .ok s0' ∧ LiftOutXN Γ c ch ι live' f s s' s1 s0' 3 := by
  cases hlow with
  | @mk d a l oa elem len n vi sd sa si t i1 i2 i3 ha htaΓ htiΓ htdΓ hn hpos hwf hsd hsa hsi
      hsize hoff htmp hesc hi1 hi2 hi3 =>
    rw [eval_use_place_norm ha] at h
    have hta : f.body.locals[a]? = some (.array elem len) := by rw [← hbody]; exact htaΓ
    have hti : f.body.locals[l]? = some (.int IntType.usize vi) := by rw [← hbody]; exact htiΓ
    have htd : f.body.locals[d]? = some elem := by rw [← hbody]; exact htdΓ
    obtain ⟨pd, pa, pl, bi, u, bs0, w, bsd, hpd, hpa, hpl, hlb, hdb, hlim, hlo0, hd, hen, hsto,
      hstk⟩ := idxRead_mem hs hta hti htd hn h
    have hla : live a = true := hlo _ (operandPlace?_mem ha)
    have hll : live l = true := hlo l (by
      cases oa <;> simp [operandPlace?] at ha <;> subst ha <;>
        simp [rvalueLocals, operandLocals, placeLocals])
    -- the own `Escape`
    have hsc1' : ScopeSpec.ok (.escS sa.off sa.size (Spec.Ty.array elem len).align.exp) sc =
        true := by
      rw [ownSpec_idxRead ha htaΓ hsa hsize.2.2] at hown
      simpa [specsOk] using hown
    obtain ⟨ι', s0', hsc', hle, hext, hpc', hfp', -, hX', e, hine⟩ :=
      scope_escape_rel hrel hpa hsa hta hla hsize.2.2 hesc hsc1' hfresh
    have hnal : ∀ l, l ∉ f.aliased := by
      intro l
      rw [hrel.rel.unaliased]
      simp
    obtain ⟨slot, hslot, hra⟩ := hX'.rel.frame.locals a pa hpa (hnal a)
    have hss : slot = sa := Option.some.inj (hslot.symm.trans hsa)
    rw [hss] at hra
    have hesc0 : s0'.st.escapedAt sa.off ≠ none := by
      have h0 : s0'.st.escapedAt sa.off = some e := by simpa using hine 0 hsize.2.2
      rw [h0]
      simp
    obtain ⟨p1, -, haddr1, hpinj, -, -⟩ := addrOf_inj hra hesc0 hsize.2.2
    obtain ⟨a0, hpa0, hlt0⟩ := LocalRel.prov_lt hra
    have hιa : ι' a0 ≠ none := by
      cases hra with
      | priv a1 x1 hp1 hι1 _ _ _ _ _ hpv1 _ =>
        exfalso
        have h1 := hpv1 0 hsize.2.2
        rw [hine 0 hsize.2.2] at h1
        cases h1
      | esc a1 x1 e2 y2 hp1 hι1 =>
        have e3 : a1 = a0 := Option.some.inj (hp1.symm.trans hpa0)
        subst e3
        rw [hι1]
        simp
    have hpcs : s0'.pc = s1.pc := hpc'.trans (scopes_pc hpre)
    -- the temporary is private
    obtain ⟨hft, -, hap⟩ := tempApartC_spec htmp
    have hpv0 := temp_private_apart hX'.escInSlots hap
    have hf1 := offOk_spec hft
    have hfa := offOk_spec hoff.2.1
    have hfi := offOk_spec hoff.2.2
    have hfd := offOk_spec hoff.1
    -- step 1: `addr t, a`
    obtain ⟨v1, ps1, r1, hv1, hh1, ho1, hops1, hctl1⟩ := addrInsnOk_spec hi1
    rw [hmode, hρ] at hv1
    have hlenP1 : (encodePtr p1).length = 8 := Ryo.Spec.Theorems.encodePtr_length _
    have hpw1 : ∀ k < (encodePtr p1).length, s0'.st.escapedAt (t + k) = none := by
      rw [hlenP1]; exact hpv0
    obtain ⟨st1, hw1⟩ : ∃ st1, s0'.st.writeFrame t (encodePtr p1) = .ok st1 := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw1]
      exact ⟨_, rfl⟩
    have hmem1 : st1.mem = s0'.st.mem := (writeFrame_private_eq hw1 hpw1).1
    have haddr1' : s0'.st.addrOf sa.off = .ok p1 := by simpa using haddr1
    have hop1 := opSem_addr_fwd (ch := ch) hh1 ho1 ⟨hf1.1, hf1.2, hfa.1, hfa.2⟩ haddr1' hw1
    have hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0' := by
      rw [hsc, scopes_append_ok hpre, List.foldlM_cons, hsc']
      all_goals rfl
    have hstep1 := step_of_view_scopes hc0 hfold hpe hpl0 hv1 hctl1 (by rw [hops1]; exact hop1)
    have hrel1 := hX'.rel.tempWrite hw1 hmem1
      (fun l' sl hsl => by rw [hlenP1]; exact hap l' sl hsl) (s0'.pc + 1)
    have hrd1 : st1.readFrame t 8 = .ok (encodePtr p1) := by
      have := readFrame_after_write hw1 hpw1
      rwa [hlenP1] at this
    have hesc1 : st1.escaped = s0'.st.escaped := (writeFrame_split hw1).2.1
    -- the R pointer's address and provenance
    have hpa1 : pa.addr = p1.addr := by
      have := hpinj.1
      simpa using this
    have hAL : Target.ADDR_LIMIT = 2 ^ 64 := rfl
    have hlt : (u % 2 ^ 64) * elem.size < 2 ^ 64 := by
      rw [hAL] at hlim
      exact Nat.lt_of_le_of_lt (Nat.le_add_left _ _) hlim
    have hdp1 : decodePtr (encodePtr p1) = some p1 :=
      Ryo.Spec.Theorems.decodePtr_encodePtr p1 (by rw [← hpa1, ← hAL]; omega)
    have hoffeq : (u * elem.size) % 2 ^ 64 = (u % 2 ^ 64) * elem.size := by
      have e1 : (u * elem.size) % 2 ^ 64 = ((u % 2 ^ 64) * elem.size) % 2 ^ 64 := by
        rw [Nat.mul_mod u elem.size (2 ^ 64), Nat.mul_mod (u % 2 ^ 64) elem.size (2 ^ 64),
          Nat.mod_mod]
      rw [e1, Nat.mod_eq_of_lt hlt]
    -- step 2: `ptr.index t, t, l, stride`
    have hri := hrel1.opnd hpl hsi hll
    obtain ⟨bi1, hrfi, hbi⟩ := readLocal_inj hrel1.frame.mem hri
      (show s.mem.load pl si.size .one = .ok bi by rw [hsize.2.1]; exact hlb)
    rw [hsize.2.1] at hrfi
    have hdb1 := decodeBits_inj hbi hdb
    have hu : asNat bi1 = .ok u := by unfold asNat; rw [hdb1]; rfl
    obtain ⟨v2, ps2, r2, hv2, hh2, hn2, hk2, hops2, hctl2⟩ := ptrIndexInsnOk_spec hi2
    rw [hmode, hρ] at hv2
    obtain ⟨k2, ho2⟩ := operandsPtrIndex hn2 hk2
    have hfk2 : Val.fits k2 (.imm elem.size) = true :=
      fits_stride (hpl1.fits v2 hv2) (by rw [ho2, hops2]; simp)
    have hlenP2 : (encodePtr (p1.wrappingOffset (((u * elem.size) % 2 ^ 64 : Nat) : Int))).length
        = 8 := Ryo.Spec.Theorems.encodePtr_length _
    have hpv1 : ∀ k : Nat, k < 8 → st1.escapedAt (t + k) = none := by
      intro k hk
      have := hpv0 k hk
      unfold OpSem.State.escapedAt at this ⊢
      rw [hesc1]
      exact this
    have hpw2 : ∀ k < (encodePtr (p1.wrappingOffset
        (((u * elem.size) % 2 ^ 64 : Nat) : Int))).length, st1.escapedAt (t + k) = none := by
      rw [hlenP2]; exact hpv1
    obtain ⟨st2, hw2⟩ : ∃ st2, st1.writeFrame t
        (encodePtr (p1.wrappingOffset (((u * elem.size) % 2 ^ 64 : Nat) : Int))) = .ok st2 := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw2]
      exact ⟨_, rfl⟩
    have hmem2 : st2.mem = st1.mem := (writeFrame_private_eq hw2 hpw2).1
    have hop2 := opSem_ptrIndex_fwd (ch := ch) hh2 ho2
      ⟨hf1.1, hf1.2, hf1.1, hf1.2, hfi.1, hfi.2⟩ hfk2 hrd1 hrfi hdp1 hu hw2
    have hc1' : c.d.insns[s0'.pc + 1]? = some i2 := by rw [hpcs]; exact hc1
    have hsc1'' : c.scopesAt (s0'.pc + 1) = [] := by rw [hpcs]; exact hsc1
    have hstep2 := step_of_view (s1 := { s0' with pc := s0'.pc + 1, st := st1 }) hc1' hsc1''
      hpe hpl1 hv2 hctl2 (by rw [hops2]; exact hop2)
    have hrel2 := hrel1.tempWrite hw2 hmem2
      (fun l' sl hsl => by rw [hlenP2]; exact hap l' sl hsl) (s0'.pc + 1 + 1)
    have hrd2 : st2.readFrame t 8 = .ok
        (encodePtr (p1.wrappingOffset (((u * elem.size) % 2 ^ 64 : Nat) : Int))) := by
      have := readFrame_after_write hw2 hpw2
      rwa [hlenP2] at this
    have hesc2 : st2.escaped = st1.escaped := (writeFrame_split hw2).2.1
    -- step 3: `load.wN d, [t + 0]`, through L0's pointer `Q` and R's `P2`
    obtain ⟨v3, ty3, r3, hv3, hh3, hty3, ho3, hops3, hctl3⟩ := loadInsnOk_spec hi3
    rw [hmode, hρ] at hv3
    obtain ⟨sg3, hty3'⟩ := intTyOk_spec hty3
    have hlim' : pa.addr + (u * elem.size) % 2 ^ 64 < Target.ADDR_LIMIT := by
      rw [hoffeq]; exact hlim
    have hwo := wrappingOffset_addr (q := pa) (q1 := p1) hpa1 hlim'
    have hpiQ : PtrInj ι' ⟨pa.addr + (u % 2 ^ 64) * elem.size, pa.prov⟩
        (p1.wrappingOffset (((u * elem.size) % 2 ^ 64 : Nat) : Int)) := by
      unfold PtrInj
      refine ⟨?_, ?_⟩
      · rw [hwo, hoffeq]
      · first
          | exact hpinj.2
          | simpa using hpinj.2
    have hQ : decodePtr (encodePtr (⟨pa.addr + (u % 2 ^ 64) * elem.size, pa.prov⟩ :
        ThinPointer)) = some ⟨pa.addr + (u % 2 ^ 64) * elem.size, pa.prov⟩ :=
      Ryo.Spec.Theorems.decodePtr_encodePtr _ (by show _ < 2 ^ 64; rw [← hAL]; exact hlim)
    have hmq : ∀ a', (⟨pa.addr + (u % 2 ^ 64) * elem.size, pa.prov⟩ : ThinPointer).prov =
        some a' → ι' a' ≠ none := by
      intro a' ha'
      have e5 : a' = a0 := Option.some.inj (ha'.symm.trans hpa0)
      rw [e5]
      exact hιa
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    have hlen0 : bsd.length = sd.size :=
      ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp
        (reenc_wf hwf hn (load_length hlo0) hd hen)).1.trans
        ((load_length hlo0).trans hsize.1.symm)
    have hW := hrel2.dstWrite hdi.2 hpd hsd hpos' hlen0 hsto
    obtain ⟨st', hop3, hmi, hrd, hoth⟩ := sim_derefLoadW (sp := ⟨t, 8⟩) (off := 0) (ch := ch)
      hwf hn hpos hsize.1 hrd2 (encodePtr_inj' hpiQ) hQ hmq (by simpa using hlim)
      (by simpa using hlo0) hd hen hrel2.frame.mem hW hh3 hty3' ho3
      ⟨hfd.1, hfd.2, hf1.1, hf1.2, by omega, by omega⟩
    have hc2' : c.d.insns[s0'.pc + 1 + 1]? = some i3 := by rw [hpcs]; exact hc2
    have hsc2'' : c.scopesAt (s0'.pc + 1 + 1) = [] := by rw [hpcs]; exact hsc2
    have hstep3 := step_of_view
      (s1 := { ({ s0' with pc := s0'.pc + 1, st := st1 } : R.RState) with
        pc := s0'.pc + 1 + 1, st := st2 }) hc2' hsc2'' hpe hpl2 hv3 hctl3
      (by rw [hops3]; exact hop3)
    -- the relation
    have hsub := bytesLeDefined_prov (reenc_wf hwf hn (load_length hlo0) hd hen)
    have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι' f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hX'.rel.hidden.load hlo0 _ (List.getElem_mem hj) fr0 hf0
    have hbd' : BytesBounded s.mem.allocs.size bsd := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hpb.load hlo0 _ (List.getElem_mem hj) fr0 hf0
    have hesc3 := (Ryo.Proofs.OpFacts.opSem_out hop3).2.1
    have hfn := hrel2.after hpd hsd hmi hrd hoth (hrel2.hidden.store_hidden hsto hhid') hesc3
      hlive' (pc' := s0'.pc + 3)
    have hak3 : AllocsKept st2.mem st'.mem := opSem_allocsKept hop3
    have hak : AllocsKept s0'.st.mem st'.mem := by
      rw [← hmem1, ← hmem2]
      exact hak3
    have hagree := Ryo.Spec.Theorems.Memory.store_agree hsto
    have hagree' : ∀ q x1, s'.mem.get? q = some x1 →
        ∃ x0, s.mem.get? q = some x0 ∧ (x1.live = true → x0.live = true) := by
      intro q x1 hx
      rcases hagree.get? q with ⟨-, h2⟩ | ⟨x0, x1', h1, h2, -, -, hl0, -, -⟩
      · rw [h2] at hx; cases hx
      · rw [h2] at hx
        cases hx
        exact ⟨x0, h1, fun hl => hl0.trans hl⟩
    have hX3 := FnRelX.keep (s2 := { s0' with pc := s0'.pc + 3, st := st' }) hX' hfn
      (show st'.escaped = s0'.st.escaped from hesc3.trans (hesc2.trans hesc1)) rfl hak hagree'
    refine ⟨s0', hsc', ι', st', hle, fun q hq => hext q (by
        rw [hpa0]
        intro he'
        have h1 : a0 = q := Option.some.inj he'
        subst h1
        exact absurd hq (Nat.not_le.mpr hlt0)),
      .cons hstep1 (.cons hstep2 (.cons hstep3 (.refl _))), hstk, hX3, hpb.store hsto hbd',
      Nat.le_of_eq (store_size hsto).symm,
      (hdi.mono hle).of_memKept (memKept_load hsto hlo0 hsub)⟩

/-! ### One statement -/

/-- `LowerIdxRead` needs an `Escape`, which a scope-free function (`LowersFn.noEsc`) has none
of: `stmt_sim`'s case is vacuous. -/
theorem stmt_sim_idxRead {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) {s s1x : Spec.State} {s1 : R.RState}
    {f : Spec.Frame} {rest : List Spec.Frame} {st : Statement} {r : Range}
    (h : LowerIdxRead Γ.toStmtCtx st (rangeInsns c.d r)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  exfalso
  generalize rangeInsns c.d r = is at h
  cases h with
  | mk _ _ _ _ _ _ _ _ _ _ hsize _ _ hesc _ _ _ =>
    have h0 := hesc 0 hsize.2.2
    rw [hfn.noEsc] at h0
    cases h0

/-- `LowerIdxRead` under pending scopes (as `SimRef.stmt_simX_ref`): the scopes at `pc` are the
pending ones then the statement's own `Escape`; the three steps by `lift_idxRead`. -/
theorem stmt_simX_idxRead {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (hlow : LowerIdxRead Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have hlow0 := hlow
  obtain ⟨d, rv, i1, i2, i3, rfl, hR⟩ : ∃ d rv i1 i2 i3, st = .assign ⟨d, []⟩ rv ∧
      rangeInsns c.d r = [i1, i2, i3] := by
    generalize rangeInsns c.d r = is at hlow0 ⊢
    cases hlow0
    exact ⟨_, _, _, _, _, rfl, rfl⟩
  rw [hR] at hlow
  obtain ⟨sa, ta, hown1⟩ : ∃ (sa : LocalSlot) (ta : Spec.Ty),
      ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [.escS sa.off sa.size ta.align.exp] := by
    have hl2 := hlow
    cases hl2 with
    | mk ha hta _ _ _ _ _ _ hsa _ hsize _ _ _ _ _ _ =>
      exact ⟨_, _, ownSpec_idxRead ha hta hsa hsize.2.2⟩
  have hlen := rangeInsns_length (r := r) h2
  rw [hR] at hlen
  simp only [List.length_cons, List.length_nil] at hlen
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hat := rangeInsns_at (r := r) h2
  have hget : ∀ j, j < 3 → c.d.insns[r.1 + j]? = [i1, i2, i3][j]? := by
    intro j hj
    have hj' : j < (rangeInsns c.d r).length := by rw [hR]; simpa using hj
    rw [hat j hj', ← List.getElem?_eq_getElem hj', hR]
  have hc0 : c.d.insns[s1.pc]? = some i1 := by
    rw [hpc0]; simpa using hget 0 (by decide)
  have hc1 : c.d.insns[s1.pc + 1]? = some i2 := by
    rw [hpc0]; simpa using hget 1 (by decide)
  have hc2 : c.d.insns[s1.pc + 2]? = some i3 := by
    rw [hpc0]; simpa using hget 2 (by decide)
  have hlt : r.1 < r.2 := by omega
  have hsc := (hfn.scopes f.bb bd blk M.hbd M.hblk).stmt f.stmt _ r hst hr hlt
  have hX : scopesAtD c.d r.1 = c.scopesAt s1.pc := by rw [hpc0]; rfl
  rw [hown1, hX] at hsc
  obtain ⟨hsplit, -, hown_ok⟩ := specsOk_append hsc
  have hlen1 := specsOk_length _ _ hown_ok
  obtain ⟨sc, hsc1⟩ : ∃ sc, (c.scopesAt s1.pc).drop (pendSpecs Γ.toStmtCtx bd blk f.stmt).length
      = [sc] := by
    rcases hd : (c.scopesAt s1.pc).drop (pendSpecs Γ.toStmtCtx bd blk f.stmt).length with
      _ | ⟨x, _ | ⟨y, ys⟩⟩
    · rw [hd] at hlen1; simp at hlen1
    · exact ⟨x, rfl⟩
    · rw [hd] at hlen1; simp at hlen1
  have hscs : c.scopesAt s1.pc =
      (c.scopesAt s1.pc).take (pendSpecs Γ.toStmtCtx bd blk f.stmt).length ++ [sc] :=
    hsplit.trans (by rw [hsc1])
  have hown' : specsOk (ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv)) [sc] = true := by
    rw [hown1, ← hsc1]
    exact hown_ok
  have hin := (hfn.scopes f.bb bd blk M.hbd M.hblk).stmtInner f.stmt r hr
  have hsc1' : c.scopesAt (s1.pc + 1) = [] := by
    have := hin (r.1 + 1) (by omega) (by omega)
    rw [hpc0]; exact this
  have hsc2' : c.scopesAt (s1.pc + 2) = [] := by
    have := hin (r.1 + 2) (by omega) (by omega)
    rw [hpc0]; exact this
  have hsx := hfn.stmtsX f.bb bd blk M.hbd M.hblk
  have hpend0 := hsx.pend0 f.stmt r hr hlt
  have hpcNext : r.2 = pcAt blk (f.stmt + 1) := hnext.trans (nextStart_eq blk f.stmt)
  have hplc : ∀ (k : Nat) (i : R.Insn), c.d.insns[k]? = some i → PlainView c.mode c.ρ i :=
    fun k i h => by rw [hmode, hρ]; exact hfn.plain k i h
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  obtain ⟨s0', hA, hXl⟩ := lift_idxRead M.stack M.body.symm hmode.symm hρ.symm hlow hc0 hc1 hc2
    hscs M.pend hown' hsc1' hsc2' hpe (hplc _ _ hc0) (hplc _ _ hc1) (hplc _ _ hc2) M.rel M.pb
    M.fresh M.dinv hl2 hl1 hev
  refine stmtOutX_of_liftXN M.stack hfn.storage M.hbd hst M.sl M.fresh ?_ hpend0 hXl
  rw [(applyScope_pc_fp hA).1, scopes_pc M.pend, hpc0, ← hpcNext]
  omega

end Ryo.Proofs.Lower
