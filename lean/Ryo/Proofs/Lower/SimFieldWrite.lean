/-
Ryo.Proofs.Lower.SimFieldWrite — partial writes of a private local, and the lift of
`LowerFieldWrite` (`Check/Lower/FieldWrite.lean`, M5b).

The generic part:
- `writeLocalSub_priv`: an L0 store of `bs0` at `off` inside a private local's allocation and an
  R frame write of related `bs1` at `slot.off + off` keep `MemInj` (only the unmapped allocation
  changed) and the local's `LocalRel` at the same liveness: inside the written range the new
  bytes relate (`foldl_set_getElem`, `writeFrame_private_eq`), outside both sides are unchanged
  and the old relation holds.
- `FnRel.after_sub`: `FnRel.after` with the destination's relation at its old liveness (a
  partial write kills nothing, so `live'` is below `live`).
- `lift_fieldWrite`: a one-instruction R write of `bs1` into the field's bytes of `_x`'s private
  slot simulates an L0 store of related `bs0` at the field's place, given that every
  provenance `bs0` carries is a loaded byte's (for `Hidden`, `ProvBounded`, `MemKept`).

The rules: L0's place is `runOn_evalPlace_fields` (`fieldAssign_inv`); `copy` stores the
re-encoding of `_a`'s loaded bytes (below them, `reenc_wf`), R's `mov` copies them
(`readLocal_inj`, `opSem_mov_fwd`); `const` stores the constant's `encodeBits`, R's `imm` the
same bytes (`opSem_imm_fwd`); `bin`/`binImm` store `encodeBits` of R's result (`intBin_wrap`,
`evalIntBinOp_wrap`, as `SimStoreTemp`), computed into the field by `opSem_bin_fwd`/
`opSem_binImm_fwd`.
-/
import Ryo.Proofs.Lower.SimStoreTemp
import Ryo.Check.Lower.FieldWrite

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### Partial writes -/

/-- See the module comment. -/
theorem writeLocalSub_priv {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p : ThinPointer} {lv : Bool}
    (hm : MemInj ι m0 st.mem) (hr : LocalRel ι fp st m0 slot p lv)
    (hpv : ∀ k < slot.size, st.escapedAt (slot.off + k) = none) (hpos : 0 < slot.size)
    {off : Nat} {bs0 bs1 : List AbstractByte} (hbs : BytesInj ι bs0 bs1)
    (hin : off + bs0.length ≤ slot.size) {al : Align}
    (h0 : m0.store ⟨p.addr + off, p.prov⟩ bs0 al = .ok m0')
    (h1 : st.writeFrame (slot.off + off) bs1 = .ok st') :
    MemInj ι m0' st'.mem ∧ LocalRel ι fp st' m0' slot p lv := by
  cases hr with
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin' hy hyl hya hys =>
    exfalso
    have h := hin' 0 hpos
    rw [hpv 0 hpos] at h
    cases h
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    have hl1 : bs1.length = bs0.length := (BytesInj.length hbs).symm
    have hpw : ∀ k < bs1.length, st.escapedAt (slot.off + off + k) = none := by
      intro k hk
      have h := hpv (off + k) (by omega)
      have e : slot.off + ((off + k : Nat) : Int) = slot.off + (off : Int) + (k : Int) := by
        omega
      rw [e] at h
      exact h
    obtain ⟨hmem, hea, hfr⟩ := writeFrame_private_eq h1 hpw
    have hpriv' : ∀ k < slot.size, st'.escapedAt (slot.off + k) = none :=
      fun k hk => (hea _).trans (hpriv k hk)
    -- a frame byte outside the written range is unchanged
    have hout : ∀ k : Nat, ¬ (off ≤ k ∧ k < off + bs0.length) →
        st'.frame (slot.off + k) = st.frame (slot.off + k) := by
      intro k hk
      rw [hfr, if_neg]
      simp only [OpSem.State.privateIn, Bool.and_eq_true, decide_eq_true_eq]
      intro hc
      exact hk ⟨by omega, by omega⟩
    rcases Ryo.Spec.Theorems.Memory.store_eq_ok h0 with
      ⟨-, hz, rfl⟩ | ⟨id, hid, -, -, hpid, -, -, -, -, hm0'⟩
    · refine ⟨by rw [hmem]; exact hm, .priv a x hp hι hx hlive haddr hpaddr hsize hpriv' ?_⟩
      intro hlv k hk
      rw [hout k (by omega)]
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
          rw [hdk, hfr, if_pos (by
            simp only [OpSem.State.privateIn, hpriv k hks, Option.isNone_none, Bool.and_true,
              decide_eq_true_eq]
            omega)]
          have ht : (slot.off + (k : Int) - (slot.off + (off : Int))).toNat = k - off := by omega
          have hk1 : k - off < bs1.length := by omega
          rw [ht, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hk1, Option.getD_some]
          exact BytesInj.getElem' hbs (k - off) hkb hk1
        · rw [if_neg (fun hc => hkin ⟨hc.1, hc.2.1⟩)] at hg
          rw [Array.getElem?_eq_getElem hk, Array.getElem?_eq_getElem hkd] at hg
          have hdk : m0'.allocs[a].data[k] = m0.allocs[a].data[k] := Option.some.inj hg
          rw [hdk, hout k hkin]
          exact hbytes hlv k hkd

/-- `FnRel.after` for a partial write of `_d`: its relation at its old liveness, `live'` below
`live` (the statement kills nothing). -/
theorem FnRel.after_sub {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 m0' : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) {st' : OpSem.State}
    {pc' : Nat} {d : Local} {pd : ThinPointer} {sd : LocalSlot}
    (hpd : f.locals[d]? = some (some pd)) (hsd : Γ.slots[d]? = some sd)
    (hmi : MemInj ι m0' st'.mem) (hrd : LocalRel ι s1.fp st' m0' sd pd (live d))
    (hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st m0 slot p lv → p.prov ≠ pd.prov →
      (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' m0' slot p lv)
    (hhid : Hidden m0' (PrivAlloc ι f)) (hesc : st'.escaped = s1.st.escaped)
    (hlive' : ∀ l, live' l = true → live l = true) :
    FnRel Γ ι live' f m0' { s1 with pc := pc', st := st' } := by
  refine ⟨⟨hmi, ?_⟩, hhid, hrel.unaliased, hrel.provNe, hrel.apart, ?_⟩
  · intro l p hp hal
    by_cases hl : l = d
    · subst hl
      have e : p = pd := Option.some.inj (Option.some.inj (hp.symm.trans hpd))
      subst e
      exact ⟨sd, hsd, hrd.weaken (hlive' l)⟩
    · obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
      exact ⟨slot, hsl, (hoth slot p (live l) hr (hrel.provNe l d p pd hl hp hpd)
        (hrel.apart d l pd p sd slot (Ne.symm hl) hpd hp hsd hsl)).weaken (hlive' l)⟩
  · intro o e he
    apply hrel.esc o e
    have h2 : st'.escapedAt o = some e := he
    show s1.st.escapedAt o = some e
    unfold OpSem.State.escapedAt at h2 ⊢
    rw [← hesc]
    exact h2

/-- A one-instruction write of `bs1` into the field bytes of `_x`'s private slot simulates
L0's store of related `bs0` at the field (see the module comment). -/
theorem lift_fieldWrite {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame} {i : R.Insn}
    {v : R.View}
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hv : R.view c.mode c.ρ i = some v)
    (hctl : v.ctl = some .next) (hrel : FnRel Γ ι live f s.mem s1) (hpb : ProvBounded s.mem)
    {x : Local} {px : ThinPointer} {sx : LocalSlot} {off : Nat} {bs0 bs1 : List AbstractByte}
    (hpx : f.locals[x]? = some (some px)) (hsx : Γ.slots[x]? = some sx)
    (hpriv : ∀ k < sx.size, Γ.escaped (sx.off + k) = false) (hpos : 0 < sx.size)
    (hin : off + bs0.length ≤ sx.size) (hbs : BytesInj ι bs0 bs1)
    (hsto : s.mem.store ⟨px.addr + off, px.prov⟩ bs0 .one = .ok s'.mem)
    (hstk : s'.stack = s.stack)
    (hprov : ∀ b ∈ bs0, ∀ fr, b.provFrag = some fr → ∃ pa n bs, s.mem.load pa n .one = .ok bs ∧
      ∃ j, ∃ hj : j < bs.length, ∃ fr0, bs[j].provFrag = some fr0 ∧ fr0.prov = fr.prov)
    (hop : ∀ st', s1.st.writeFrame (sx.off + off) bs1 = .ok st' →
      opSem v.op v.ops s1.st ch = .ok (.next, st'))
    (hlive' : ∀ l, live' l = true → live l = true) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  have hpv := temp_private hrel hpriv
  have hl1 : bs1.length = bs0.length := (BytesInj.length hbs).symm
  have hpw : ∀ k < bs1.length, s1.st.escapedAt (sx.off + off + k) = none := by
    intro k hk
    have h := hpv (off + k) (by omega)
    have e : sx.off + ((off + k : Nat) : Int) = sx.off + (off : Int) + (k : Int) := by omega
    rw [e] at h
    exact h
  obtain ⟨st', hwr, -⟩ := writeFrame_private_ok (st := s1.st) (t := sx.off + off) (bs := bs1) hpw
  have hesc := (writeFrame_split hwr).2.1
  obtain ⟨sl, hsl, hrx⟩ := hrel.frame.locals x px hpx (by rw [hrel.unaliased]; simp)
  rw [hsx] at hsl
  have esl : sx = sl := Option.some.inj hsl
  rw [← esl] at hrx
  obtain ⟨hmi, hrd⟩ := writeLocalSub_priv hrel.frame.mem hrx hpv hpos hbs hin hsto hwr
  have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
      p.prov ≠ px.prov → (sx.off + sx.size ≤ slot.off ∨ slot.off + slot.size ≤ sx.off) →
      LocalRel ι s1.fp st' s'.mem slot p lv := by
    intro slot p lv hr hne hap
    have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
    exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hl1]; omega)
  have hhid' : ∀ b ∈ bs0, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hrel.hidden.load hld _ (List.getElem_mem hj) fr0 hf0
  have hbd' : BytesBounded s.mem.allocs.size bs0 := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hpb.load hld _ (List.getElem_mem hj) fr0 hf0
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (hop st' hwr), hstk,
    hrel.after_sub hpx hsx hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
    memKept_store hsto fun A hA b hb fr hfr => by
      obtain ⟨pa, n, bs, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
      rw [← he0]
      exact hA.load hld _ (List.getElem_mem hj) fr0 hf0⟩

/-! ### L0 -/

/-- An assignment to `_x.fields` (field projections only), run to success. -/
theorem fieldAssign_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {x : Local} {projs : List ProjElem}
    {tx ty : Spec.Ty} {off : Nat} {rv : Rvalue}
    (htx : f.body.locals[x]? = some tx) (hpath : fieldPath tx projs = some (off, ty))
    (h : runOn (evalStatement (.assign ⟨x, projs⟩ rv)) o s = (.ok (), s')) :
    ∃ px v s2 mem', f.locals[x]? = some (some px) ∧
      runOn (evalRvalue rv ty) o s = (.ok v, s2) ∧
      typedStore s2.mem ⟨px.addr + off, px.prov⟩ v ty .one = .ok mem' ∧
      s' = { s2 with mem := mem' } := by
  have e : evalStatement (.assign ⟨x, projs⟩ rv) =
      (evalPlace ⟨x, projs⟩ >>= fun y => match y with
        | (pl, ty') => evalRvalue rv ty' >>= fun v => placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨y, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨px, hpx, rfl, hs1⟩ := runOn_evalPlace_fields hs htx hpath h1
  have h2' : runOn (evalRvalue rv ty >>= fun v =>
      placeStore ⟨(⟨px.addr + off, px.prov⟩ : ThinPointer).widen, true⟩ v ty) o s1 =
      (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨px, v, s2, mem', hpx, h3, hst, hs'⟩

/-! ### The lift -/

/-- `LowerFieldWrite`'s lift, with `lift_derefStore`'s interface. -/
theorem lift_fieldWriteRule {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {pl : MPlace} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerFieldWrite Γ (.assign pl rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ stmtReads (.assign pl rv), live l = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assign pl rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @copy x a oa fe fields tx ty off n sx sa i ha htx hpath hta hwf hn hpos hsx hsa hin hsz hoff
      hpriv hmi =>
    have hla : live a = true := hlo a (by
      show a ∈ placeLocals ⟨x, fe :: fields⟩ ++ rvalueLocals (.use oa)
      exact List.mem_append_right _ (operand_local_mem ha))
    rw [eval_use_norm ha] at h
    rw [hbody] at htx hta
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
    subst e5
    obtain ⟨bsa, hla0, hda⟩ := typedLoad_inv hn hlwa
    have hbl : bsa.length = n := load_length hla0
    rw [hs2, hs3] at hst
    obtain ⟨bs0, hen, hsto0⟩ := typedStore_inv hst
    have hle := reenc_wf hwf hn hbl hda hen
    -- R's read of `_a`
    have hra := hrel.opnd hpa hsa hla
    rw [← hsz] at hla0
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hla0
    rw [hsz] at hrfa
    obtain ⟨hbs, hlen⟩ := BytesInj.of_le_trans hle hia
    have hlenb : ba.length = n := (BytesInj.length hia).symm.trans hbl
    have hl0 : bs0.length = n := hlen.trans hbl
    obtain ⟨vv, tyN, rr, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hsto : s.mem.store ⟨px.addr + off, px.prov⟩ bs0 .one = .ok s'.mem := by
      rw [hs', hs2, hs3]; exact hsto0
    have hstk : s'.stack = s.stack := by rw [hs', hs2, hs3]
    have hsub := le_prov hle
    refine lift_fieldWrite hi hsc hpe hpl hv hctl hrel hpb hpx hsx hpriv (by omega)
      (by rw [hl0]; exact hin) hbs hsto hstk ?_ (fun st' hwr => ?_) hlive'
    · intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      exact ⟨pa, sa.size, bsa, hla0, j, hj, fr0, hf0, he0⟩
    · rw [hops]
      exact opSem_mov_fwd hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfa hlenb hwr
  | @const x fe fields tx t vp vc bits off sx i htx hpath hpos hsx hin hoff hpriv hii =>
    rw [hbody] at htx
    obtain ⟨px, w, s2, mem', hpx, h3, hst, hs'⟩ := fieldAssign_inv hs htx hpath h
    have e2 : evalRvalue (.use (.const (.scalar bits) (.int t vc))) (.int t vp) =
        (evalOperand (.const (.scalar bits) (.int t vc)) >>= fun r => pure r.1) := by
      first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
    rw [e2] at h3
    obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
    obtain ⟨hr, hs3⟩ := runOn_evalOperand_const_scalar_int h5
    subst hr
    obtain ⟨hw', hs2⟩ := runOn_pure_inv h6
    subst hw'
    rw [hs2, hs3] at hst
    have hst' := typedStore_int hst
    obtain ⟨vv, tyN, rr, hv, hh, hty, hn, hk, hops, hctl⟩ := immInsnOk_spec hii
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x', hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands2 hn hk
    have hops'' : vv.ops = [.slot (sx.off + off), .imm x'] := hops'
    have hfk : Val.fits k (.imm x') = true :=
      fits_last (hpl.fits vv hv) (by rw [ho, hops'']; simp)
    have hbytes : encodeBits t.size (t.toBits (t.ofBits (bits % 2 ^ (8 * t.size)))) =
        encodeBits t.size x' := by
      rw [encodeBits_toBits_ofBits, encodeBits_mod, ← encodeBits_mod t.size x', hx,
        encodeBits_mod]
    rw [hbytes] at hst'
    have hsto : s.mem.store ⟨px.addr + off, px.prov⟩ (encodeBits t.size x') .one =
        .ok s'.mem := by
      rw [hs', hs2, hs3]; exact hst'
    have hstk : s'.stack = s.stack := by rw [hs', hs2, hs3]
    have hf1 := offOk_spec hoff
    have hl0 : (encodeBits t.size x').length = t.size := Ryo.Spec.Theorems.encodeBits_length _ _
    have hpsx : 0 < sx.size := Nat.lt_of_lt_of_le hpos (Nat.le_trans (Nat.le_add_left _ _) hin)
    refine lift_fieldWrite hi hsc hpe hpl hv hctl hrel hpb hpx hsx hpriv hpsx
      (by rw [hl0]; exact hin) (encodeBits_inj ι t.size x') hsto hstk ?_ (fun st' hwr => ?_)
      hlive'
    · intro b hb fr hfr
      rw [encodeBits_noprov t.size x' b hb] at hfr
      cases hfr
    · rw [hops'']
      exact opSem_imm_fwd hh hty' ho ⟨hf1.1, hf1.2⟩ hfk hwr

  | @bin x a b oa ob op m fe fields tx t vp va vb off sx sa sb i hm ha hb htx hpath hta htb hpos
      hsx hsa hsb hin hsz hoff hpriv hbi =>
    have hla : live a = true := hlo a (by
      show a ∈ placeLocals ⟨x, fe :: fields⟩ ++ rvalueLocals (.binaryOp op oa ob)
      exact List.mem_append_right _ (List.mem_append_left _ (operand_local_mem ha)))
    have hlb : live b = true := hlo b (by
      show b ∈ placeLocals ⟨x, fe :: fields⟩ ++ rvalueLocals (.binaryOp op oa ob)
      exact List.mem_append_right _ (List.mem_append_right _ (operand_local_mem hb)))
    rw [eval_binop_norm ha hb] at h
    rw [hbody] at htx hta htb
    obtain ⟨px, w, s2, mem', hpx, h3, hst, hs'⟩ := fieldAssign_inv hs htx hpath h
    have e2 : evalRvalue (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩)) (.int t vp) =
        (evalOperand (.copy ⟨a, []⟩) >>= fun l => evalOperand (.copy ⟨b, []⟩) >>= fun r =>
          evalBinOp op l r (.int t vp)) := by
      first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
    rw [e2] at h3
    obtain ⟨la, s3, h5, h6⟩ := runOn_bind_ok h3
    obtain ⟨pa, ta', wa, hpa, hta', hlwa, hla', hs3⟩ := runOn_evalOperand_copy hs h5
    subst hla'
    rw [hs3] at h6
    obtain ⟨lb, s4, h7, h8⟩ := runOn_bind_ok h6
    obtain ⟨pb, tb', wb, hpb', htb', hlwb, hlb', hs4⟩ := runOn_evalOperand_copy hs h7
    subst hlb'
    rw [hs4] at h8
    have e5 : ta' = .int t va := Option.some.inj (hta'.symm.trans hta)
    have e6 : tb' = .int t vb := Option.some.inj (htb'.symm.trans htb)
    subst e5 e6
    obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hlwa
    obtain ⟨bsb, ub, hlob, hdb, -, rfl⟩ := typedLoad_int hlwb
    rw [evalBinOp_int, evalIntBinOp_wrap hm] at h8
    obtain ⟨hv0, hs2⟩ := prod_ok_inj h8
    subst hv0
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpb' hsb hlb
    rw [← hsz.1] at hloa
    rw [← hsz.2] at hlob
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hrel.frame.mem hrb hlob
    rw [hsz.1] at hrfa
    rw [hsz.2] at hrfb
    have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
    have hvb : asNat bb = .ok ub := by unfold asNat; rw [decodeBits_inj hib hdb]; rfl
    obtain ⟨vv, kd, tyN, rr, hv, hh, hkd, hty, ho, hops, hctl⟩ := binInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨res, hres, hresv⟩ := intBin_wrap hm t sg ua ub
    rw [← hs2] at hst
    have hst' := typedStore_int hst
    rw [← hresv] at hst'
    have hsto : s.mem.store ⟨px.addr + off, px.prov⟩ (encodeBits t.size res.toNat) .one =
        .ok s'.mem := by
      rw [hs', ← hs2]; exact hst'
    have hstk : s'.stack = s.stack := by rw [hs', ← hs2]
    have hl0 : (encodeBits t.size res.toNat).length = t.size :=
      Ryo.Spec.Theorems.encodeBits_length _ _
    have hpsx : 0 < sx.size := Nat.lt_of_lt_of_le hpos (Nat.le_trans (Nat.le_add_left _ _) hin)
    have hf0 := offOk_spec hoff.1
    have hfa := offOk_spec hoff.2.1
    have hfb := offOk_spec hoff.2.2
    refine lift_fieldWrite hi hsc hpe hpl hv hctl hrel hpb hpx hsx hpriv hpsx
      (by rw [hl0]; exact hin) (encodeBits_inj ι t.size res.toNat) hsto hstk ?_
      (fun st' hwr => ?_) hlive'
    · intro b' hb' fr hfr
      rw [encodeBits_noprov t.size res.toNat b' hb'] at hfr
      cases hfr
    · rw [hops]
      exact opSem_bin_fwd hkd hh hty' ho ⟨hf0.1, hf0.2, hfa.1, hfa.2, hfb.1, hfb.2⟩ hrfa hrfb
        hva hvb hres hwr
  | @binImm x a oa op m fe fields tx t vp va vc bits off sx sa i hm ha htx hpath hta hpos hsx
      hsa hin hsz hoff hpriv hbi =>
    have hla : live a = true := hlo a (by
      show a ∈ placeLocals ⟨x, fe :: fields⟩ ++
        rvalueLocals (.binaryOp op oa (.const (.scalar bits) (.int t vc)))
      exact List.mem_append_right _ (List.mem_append_left _ (operand_local_mem ha)))
    rw [eval_binopImm_norm ha] at h
    rw [hbody] at htx hta
    obtain ⟨px, w, s2, mem', hpx, h3, hst, hs'⟩ := fieldAssign_inv hs htx hpath h
    have e2 : evalRvalue (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) (.int t vc)))
        (.int t vp) =
        (evalOperand (.copy ⟨a, []⟩) >>= fun l =>
          evalOperand (.const (.scalar bits) (.int t vc)) >>= fun r =>
            evalBinOp op l r (.int t vp)) := by
      first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
    rw [e2] at h3
    obtain ⟨la, s3, h5, h6⟩ := runOn_bind_ok h3
    obtain ⟨pa, ta', wa, hpa, hta', hlwa, hla', hs3⟩ := runOn_evalOperand_copy hs h5
    subst hla'
    rw [hs3] at h6
    obtain ⟨lb, s4, h7, h8⟩ := runOn_bind_ok h6
    obtain ⟨hlb', hs4⟩ := runOn_evalOperand_const_scalar_int h7
    subst hlb'
    rw [hs4] at h8
    have e5 : ta' = .int t va := Option.some.inj (hta'.symm.trans hta)
    subst e5
    obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hlwa
    rw [evalBinOp_int, evalIntBinOp_wrap hm] at h8
    obtain ⟨hv0, hs2⟩ := prod_ok_inj h8
    subst hv0
    have hra := hrel.opnd hpa hsa hla
    rw [← hsz] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsz] at hrfa
    have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
    obtain ⟨vv, kd, tyN, rr, hv, hh, hkd, hty, hn', hk, hops, hctl⟩ := binImmInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x', hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho'⟩ := operands3 hn' hk
    have hops'' : vv.ops = [.slot (sx.off + off), .slot sa.off, .imm x'] := hops'
    have hfk : Val.fits k (.imm x') = true :=
      fits_last (hpl.fits vv hv) (by rw [ho', hops'']; simp)
    obtain ⟨res, hres, hresv⟩ := intBin_wrap hm t sg ua x'
    have hcong : t.ofBits x' = t.ofBits (bits % 2 ^ (8 * t.size)) :=
      ofBits_congr t (by rw [Nat.mod_mod]; exact hx)
    rw [← hs2] at hst
    have hst' := typedStore_int hst
    rw [← hcong, ← hresv] at hst'
    have hsto : s.mem.store ⟨px.addr + off, px.prov⟩ (encodeBits t.size res.toNat) .one =
        .ok s'.mem := by
      rw [hs', ← hs2]; exact hst'
    have hstk : s'.stack = s.stack := by rw [hs', ← hs2]
    have hl0 : (encodeBits t.size res.toNat).length = t.size :=
      Ryo.Spec.Theorems.encodeBits_length _ _
    have hpsx : 0 < sx.size := Nat.lt_of_lt_of_le hpos (Nat.le_trans (Nat.le_add_left _ _) hin)
    have hf0 := offOk_spec hoff.1
    have hfa := offOk_spec hoff.2
    refine lift_fieldWrite hi hsc hpe hpl hv hctl hrel hpb hpx hsx hpriv hpsx
      (by rw [hl0]; exact hin) (encodeBits_inj ι t.size res.toNat) hsto hstk ?_
      (fun st' hwr => ?_) hlive'
    · intro b' hb' fr hfr
      rw [encodeBits_noprov t.size res.toNat b' hb'] at hfr
      cases hfr
    · rw [hops'']
      exact opSem_binImm_fwd hkd hh hty' ho' ⟨hf0.1, hf0.2, hfa.1, hfa.2⟩ hfk hrfa hva hres hwr

/-- `LowerFieldWrite` in a scope-free function: `stmt_sim`'s case (as its `deref` store case). -/
theorem stmt_sim_fieldWrite {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerFieldWrite Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨b, x, xs, rv, i, rfl, hR⟩ : ∃ b x xs rv i, st = .assign ⟨b, x :: xs⟩ rv ∧
      rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, _, _, rfl, rfl⟩
  rw [hR] at h
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
  have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  obtain ⟨st', hstep, hstk, hrel, hpb, hle, hk⟩ := lift_fieldWriteRule (ch := ch) M.stack
    M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb hlv2
    (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
  refine ⟨_, f, .cons hstep (.refl _), hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl, hpc, hrel,
    ?_, hpb, ?_, M.dinv.of_memKept hk⟩
  · intro l p hp
    exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by intro e; cases e)
  · intro a ha
    exact M.fresh a (Nat.le_trans hle ha)

end Ryo.Proofs.Lower
