/-
Ryo.Proofs.Lower.SimFieldCopyN — the lift of `LowerFieldCopyN` (`Check/Lower/FieldWrite.lean`,
M5b): a copy of a whole local into a field of a private local, in `mov` pieces.

R: the pieces are `Agg.lean`'s one field of the "slot" `⟨sx.off + off, n⟩` (the field's bytes),
so `SimAgg.sim_pieces` runs them (its sources read through `srcRel_of_fieldMem`, inside the
range by `aggPieces_within`): the frame inside the field's bytes refines L0's stored bytes
(`pieceFrame_aggPieces` over `n` uninitialized bytes), outside it is unchanged
(`pieceFrame_outside`), memory and escapes are unchanged. `writeLocalSub_gen` (the frame-level
form of `SimFieldWrite.writeLocalSub_priv`) then relates `_x`, `FnRel.after_sub` the function.

L0 is `SimFieldWrite`'s `copy`: the stored bytes are the re-encoding of `_a`'s loaded ones, below
them (`FieldMem`), so their provenance is a loaded byte's.
-/
import Ryo.Proofs.Lower.SimFieldWrite

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-- `writeLocalSub_priv` for a frame changed by any private update: memory and escapes kept,
the field's bytes refining `bs0`, the rest of the frame unchanged. -/
theorem writeLocalSub_gen {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p : ThinPointer} {lv : Bool}
    (hm : MemInj ι m0 st.mem) (hr : LocalRel ι fp st m0 slot p lv)
    (hpv : ∀ k < slot.size, st.escapedAt (slot.off + k) = none) (hpos : 0 < slot.size)
    {off : Nat} {bs0 : List AbstractByte} (hin : off + bs0.length ≤ slot.size) {al : Align}
    (h0 : m0.store ⟨p.addr + off, p.prov⟩ bs0 al = .ok m0')
    (hmem : st'.mem = st.mem) (hesc : st'.escaped = st.escaped)
    (hnew : ∀ k (h : k < bs0.length), ByteInj ι bs0[k] (st'.frame (slot.off + off + k)))
    (hout : ∀ o, (o < slot.off + off ∨ slot.off + off + bs0.length ≤ o) →
      st'.frame o = st.frame o) :
    MemInj ι m0' st'.mem ∧ LocalRel ι fp st' m0' slot p lv := by
  have hea : ∀ o, st'.escapedAt o = st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc]
  cases hr with
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin' hy hyl hya hys =>
    exfalso
    have h := hin' 0 hpos
    rw [hpv 0 hpos] at h
    cases h
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    have hpriv' : ∀ k < slot.size, st'.escapedAt (slot.off + k) = none :=
      fun k hk => (hea _).trans (hpriv k hk)
    have hout' : ∀ k : Nat, ¬ (off ≤ k ∧ k < off + bs0.length) →
        st'.frame (slot.off + k) = st.frame (slot.off + k) := fun k hk => hout _ (by omega)
    rcases Ryo.Spec.Theorems.Memory.store_eq_ok h0 with
      ⟨-, hz, rfl⟩ | ⟨id, hid, -, -, hpid, -, -, -, -, hm0'⟩
    · refine ⟨by rw [hmem]; exact hm, .priv a x hp hι hx hlive haddr hpaddr hsize hpriv' ?_⟩
      intro hlv k hk
      rw [hout' k (by omega)]
      exact hbytes hlv k hk
    · have hai : a = id := Option.some.inj (hp.symm.trans hpid)
      cases hai
      have hxa : m0.allocs[a] = x := by
        simp only [Memory.get?, Array.getElem?_eq_getElem hid, Option.some.injEq] at hx
        exact hx
      subst hxa
      have hmi : MemInj ι m0' st'.mem := by
        rw [hmem]
        intro a' b x' hg hb
        have hne : a ≠ a' := fun e => by subst e; rw [hι] at hb; cases hb
        have hg' : m0.get? a' = some x' := by
          subst hm0'
          simpa [Memory.get?, Array.getElem?_set, hne] using hg
        exact hm a' b x' hg' hb
      refine ⟨hmi, ?_⟩
      have ha' : a < m0'.allocs.size := by subst hm0'; simpa using hid
      have hoffe : p.addr + off - m0.allocs[a].addr = off := by omega
      have hcomp : m0'.allocs[a] = { m0.allocs[a] with
          data := (bs0.zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) m0.allocs[a].data } := by
        subst hm0'
        simp [hoffe]
      have hdata : m0'.allocs[a].data =
          (bs0.zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) m0.allocs[a].data := by
        rw [hcomp]
      have hsz' : m0'.allocs[a].data.size = slot.size := by
        rw [hdata]
        exact (Ryo.Spec.Theorems.foldl_set_size bs0 0 off m0.allocs[a].data).trans hsize
      refine .priv a m0'.allocs[a] hp hι ?_ (by rw [hcomp]; exact hlive)
        (by rw [hcomp]; exact haddr) (by rw [hcomp]; exact hpaddr) hsz' hpriv' ?_
      · show m0'.allocs[a]? = _
        exact Array.getElem?_eq_getElem ha'
      · intro hlv k hk
        have hks : k < slot.size := hsz' ▸ hk
        have hkd : k < m0.allocs[a].data.size := by omega
        have hg0 := Ryo.Spec.Theorems.foldl_set_getElem bs0 0 off m0.allocs[a].data k
        simp only [Nat.add_zero, Nat.sub_zero] at hg0
        have hg : m0'.allocs[a].data[k]? = (if off ≤ k ∧ k < off + bs0.length ∧
            k < m0.allocs[a].data.size then bs0[k - off]? else m0.allocs[a].data[k]?) := by
          rw [hdata]; exact hg0
        by_cases hkin : off ≤ k ∧ k < off + bs0.length
        · rw [if_pos ⟨hkin.1, hkin.2, hkd⟩] at hg
          have hkb : k - off < bs0.length := by omega
          rw [Array.getElem?_eq_getElem hk, List.getElem?_eq_getElem hkb] at hg
          have hdk : m0'.allocs[a].data[k] = bs0[k - off] := Option.some.inj hg
          rw [hdk]
          have e : slot.off + (k : Int) = slot.off + (off : Int) + ((k - off : Nat) : Int) := by
            omega
          rw [e]
          exact hnew (k - off) hkb
        · rw [if_neg (fun hc => hkin ⟨hc.1, hc.2.1⟩)] at hg
          rw [Array.getElem?_eq_getElem hk, Array.getElem?_eq_getElem hkd] at hg
          have hdk : m0'.allocs[a].data[k] = m0.allocs[a].data[k] := Option.some.inj hg
          rw [hdk, hout' k hkin]
          exact hbytes hlv k hkd

/-- Bytes equal to `bs0` and related pointwise give `bs0` related pointwise. -/
theorem byteInj_of_eq {ι : Inj} {F : Nat → AbstractByte} {W bs0 : List AbstractByte}
    (hW : W = bs0) (h : ∀ k (hk : k < W.length), ByteInj ι W[k] (F k)) :
    ∀ k (hk : k < bs0.length), ByteInj ι bs0[k] (F k) := by
  subst hW
  exact h

/-- `LowerFieldCopyN`'s lift (see the module comment). -/
theorem lift_fieldCopyN {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {pl : MPlace} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerFieldCopyN Γ (.assign pl rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ stmtReads (.assign pl rv), live l = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assign pl rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @mk x a oa fe fields tx ty off n sx so ws is htx hpath hn hsx hin hoff hpriv hf hpo =>
    -- the operand's facts
    have ha : oa.local? = some a := by cases hf with | slot ha => exact ha
    have hfacts : Γ.body.locals[a]? = some ty ∧ ty.wf = true ∧ ws.sum = n ∧ 0 < n := by
      cases hf with
      | slot _ hta hwf hn' hpos' _ _ _ hws _ _ =>
        have e := Option.some.inj (hn'.symm.trans hn)
        exact ⟨hta, hwf, hws.trans e, e ▸ hpos'⟩
    obtain ⟨htaΓ, hwf, hws, hnpos⟩ := hfacts
    have hla : live a = true := hlo a (by
      show a ∈ placeLocals ⟨x, fe :: fields⟩ ++ rvalueLocals (.use oa)
      exact List.mem_append_right _ (operand_local_mem ha))
    -- L0
    rw [eval_use_norm ha] at h
    rw [hbody] at htx
    have hta : f.body.locals[a]? = some ty := by rw [← hbody]; exact htaΓ
    obtain ⟨px, w, s2, mem', hpx, h3, hst, hs'⟩ := fieldAssign_inv hs htx hpath h
    have e2 : evalRvalue (.use (.copy ⟨a, []⟩)) ty =
        (evalOperand (.copy ⟨a, []⟩) >>= fun r => pure r.1) := by
      first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
    rw [e2] at h3
    obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
    obtain ⟨pa, ta', wa, hpa, hta', hlwa, hr, hs3⟩ := runOn_evalOperand_copy hs h5
    subst hr
    obtain ⟨hw', hs2⟩ := runOn_pure_inv h6
    subst hw'
    have e5 : ta' = ty := Option.some.inj (hta'.symm.trans hta)
    rw [e5] at hlwa
    obtain ⟨bsa, hla0, hda⟩ := typedLoad_inv hn hlwa
    have hbl : bsa.length = n := load_length hla0
    rw [hs2, hs3] at hst
    obtain ⟨bs0, hen, hsto0⟩ := typedStore_inv hst
    have hle := reenc_wf hwf hn hbl hda hen
    have hl0 : bs0.length = n := ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans hbl
    have hsto : s.mem.store ⟨px.addr + off, px.prov⟩ bs0 .one = .ok s'.mem := by
      rw [hs', hs2, hs3]; exact hsto0
    have hstk : s'.stack = s.stack := by rw [hs', hs2, hs3]
    have hfm : FieldMem f s.mem (.slot a so ws) bs0 :=
      ⟨pa, bsa, hpa, by rw [hws]; exact hla0, hle⟩
    -- R: the pieces
    have hpv := temp_private hrel hpriv
    have hfs : AggFields Γ ⟨sx.off + off, n⟩ [oa] [(0, ty)] [.slot a so ws] := .cons hf .nil
    have hwithin := aggPieces_within hfs hoff
    have hesc' : ∀ o', sx.off + off ≤ o' → o' < sx.off + off + n →
        s1.st.escapedAt o' = none := by
      intro o' h1 h2
      have h4 := hpv (o' - sx.off).toNat (by omega)
      rw [show sx.off + ((o' - sx.off).toNat : Int) = o' by omega] at h4
      exact h4
    have hsrc1 := srcRel_of_fieldMem hrel hf hfm (fun a' s' ws' he => by cases he; exact hla)
    have hsrcs : ∀ p ∈ aggPieces (sx.off + off) [(0, ty)] [.slot a so ws], ∀ d' s'' w',
        p = .mov d' s'' w' →
        ∀ i < w', s1.st.byteAt (s'' + i) = .ok (frameByte s1.st (s'' + i)) := by
      intro p hp d' s'' w' he i hi'
      obtain ⟨src, hsm, a', so', ws', rfl, o', rfl, how⟩ :=
        aggPieces_mov_src (sx.off + off) [(0, ty)] [.slot a so ws] p hp d' s'' w' he
      have hsm' : AggSrc.slot a' so' ws' = .slot a so ws := by simpa using hsm
      cases hsm'
      have := hsrc1.2 _ _ _ rfl (o' + i) (by omega)
      rw [Int.natCast_add, ← Int.add_assoc] at this
      exact this
    have hpo' : piecesOk Γ is (aggPieces (sx.off + off) [(0, ty)] [.slot a so ws]) = true := by
      rw [aggPieces_single]; exact hpo
    obtain ⟨st', hsteps, hmem, hesc, hfr'⟩ := sim_pieces (ch := ch) (src := frameByte s1.st)
      hmode hρ hpo' hi hsc hpe hpl hwithin hesc' hsrcs
    -- the frame inside and outside the field
    obtain ⟨-, hLrel⟩ := pieceFrame_aggPieces (ι := ι) (src := frameByte s1.st)
      (base := sx.off + off) (acc := List.replicate n .uninit) (fr := s1.st.frame)
      (fields := [(0, ty)]) (srcs := [.slot a so ws]) (ebs := [bs0]) rfl rfl
      (fun j h1 h2 => by
        cases j with
        | zero => exact hsrc1.1
        | succ j => simp at h1)
      (fun j h1 h2 => by
        cases j with
        | zero => show 0 + bs0.length ≤ (List.replicate n AbstractByte.uninit).length; simp [hl0]
        | succ j => simp at h1)
      (fun k h => by simp only [List.getElem_replicate]; exact True.intro)
    have hW : writeFields (List.replicate n AbstractByte.uninit)
        ((([(0, ty)] : List (Nat × Spec.Ty)).map (·.1)).zip [bs0]) = bs0 := by
      show writeAt _ 0 bs0 = bs0
      simp [writeAt, hl0]
    have hnew : ∀ k (h : k < bs0.length), ByteInj ι bs0[k] (st'.frame (sx.off + off + k)) := by
      have := byteInj_of_eq (F := fun k => pieceFrame (frameByte s1.st)
        (aggPieces (sx.off + off) [(0, ty)] [.slot a so ws]) s1.st.frame (sx.off + off + k)) hW
        hLrel
      intro k hk
      rw [hfr']
      exact this k hk
    have hout : ∀ o', (o' < sx.off + off ∨ sx.off + off + bs0.length ≤ o') →
        st'.frame o' = s1.st.frame o' := by
      intro o' ho
      rw [hfr']
      exact pieceFrame_outside hwithin (by rw [hl0] at ho; exact ho)
    -- `_x`'s relation and the others'
    have hpsx : 0 < sx.size := by omega
    obtain ⟨sl, hsl, hrx⟩ := hrel.frame.locals x px hpx (by rw [hrel.unaliased]; simp)
    rw [hsx] at hsl
    have esl : sx = sl := Option.some.inj hsl
    rw [← esl] at hrx
    obtain ⟨hmi, hrd⟩ := writeLocalSub_gen hrel.frame.mem hrx hpv hpsx (by rw [hl0]; exact hin)
      hsto hmem hesc hnew hout
    have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
        p.prov ≠ px.prov → (sx.off + sx.size ≤ slot.off ∨ slot.off + slot.size ≤ sx.off) →
        LocalRel ι s1.fp st' s'.mem slot p lv := by
      intro slot p lv hr hne hap
      have hfro : ∀ o', (o' < sx.off + off ∨ sx.off + off + n ≤ o') →
          st'.frame o' = s1.st.frame o' := fun o' ho => hout o' (by rw [hl0]; exact ho)
      exact (hr.frame_apart hmem hesc hfro (by omega)).store_other hsto (.inl (Ne.symm hne))
    have hsub := le_prov hle
    have hhid' : ∀ b ∈ bs0, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hrel.hidden.load hla0 _ (List.getElem_mem hj) fr0 hf0
    have hbd' : BytesBounded s.mem.allocs.size bs0 := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hpb.load hla0 _ (List.getElem_mem hj) fr0 hf0
    exact ⟨st', hsteps, hstk,
      hrel.after_sub hpx hsx hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hla0 hsub⟩

/-- `LowerFieldCopyN` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_storeTemp`). -/
theorem stmt_sim_fieldCopyN {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerFieldCopyN Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨b, x, xs, rv, rfl⟩ : ∃ b x xs rv, st = .assign ⟨b, x :: xs⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h; exact ⟨_, _, _, _, rfl⟩
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
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
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  obtain ⟨st', hsteps, hstk, hrel, hpb, hle, hk⟩ := lift_fieldCopyN (ch := ch) M.stack
    M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb hlv2
    (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
  refine ⟨_, f, hsteps, hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl,
    (by show s1.pc + (rangeInsns c.d r).length = r.2; rw [hpc0, hlen]; omega), hrel, ?_, hpb,
    ?_, M.dinv.of_memKept hk⟩
  · intro l p hp
    exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by intro e; cases e)
  · intro a ha
    exact M.fresh a (Nat.le_trans hle ha)

end Ryo.Proofs.Lower
