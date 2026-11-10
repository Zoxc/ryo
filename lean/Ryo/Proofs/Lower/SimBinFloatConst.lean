/-
Ryo.Proofs.Lower.SimBinFloatConst — the simulation of `LowerBinFloatConst`
(`Check/Lower/BinFloatConst.lean`, M5b): float arithmetic with one constant operand, lowered to
`imm tt, bits` and the `fbin` handler with `tt` for the constant.

- Operands (`FOpndFacts`): a float operand's L0 value is `.float f u`, the state unchanged, and R
  reads `u`'s bits back from a slot: a whole local (`fopnd_local`, `typedLoad_float`,
  `readLocal_inj`), or the constant in the temporary (`fopnd_const`,
  `runOn_evalOperand_const_float`: the constant decodes to its low `8 * f.size` bits).
- `sim_binFloatGen`: `lift_binFloat`'s body (`SimBinFloat.lean`) for operands given by
  `FOpndFacts`, under `NanPicks` (a NaN result's bits).
- The `imm` (`step_immTemp`, `FnRel.tempWrite`, `SimCmpConst.lean`): R writes the constant's
  bytes to the private temporary; L0 takes no step. `lift_binFloatConst` puts them together
  (`liftOutN_two`); `stmt_sim_binFloatConst` is the statement's `StmtOut`
  (`stmt_simX_binFloatConst` is in `SimBinFloatConstX.lean`).
-/
import Ryo.Proofs.Lower.SimBinFloat
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Check.Lower.BinFloatConst

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Operands -/

/-- A scalar constant at a float type: its low `8 * f.size` bits, the state unchanged. -/
theorem runOn_evalOperand_const_float {o : Spec.Oracle} {s s1 : Spec.State} {bits : Nat}
    {fl : FloatTy} {r : Value × Spec.Ty}
    (h : runOn (evalOperand (.const (.scalar bits) (.float fl))) o s = (.ok r, s1)) :
    r = (.float fl (bits % 2 ^ (8 * fl.size)), .float fl) ∧ s1 = s := by
  have hsz : (Spec.Ty.float fl).size = fl.size := by cases fl <;> rfl
  have hdec : (Spec.Ty.float fl).decode (encodeBits fl.size bits) =
      some (.float fl (bits % 2 ^ (8 * fl.size))) := by
    first
      | (simp [Spec.Ty.decode, Ryo.Spec.Theorems.encodeBits_length,
          Ryo.Spec.Theorems.decodeBits_encodeBits]; done)
      | (cases fl <;> simp [Spec.Ty.decode, Ryo.Spec.Theorems.encodeBits_length,
          Ryo.Spec.Theorems.decodeBits_encodeBits])
  have e : evalOperand (.const (.scalar bits) (.float fl)) =
      (evalConst (.scalar bits) (.float fl) >>= fun v => pure (v, .float fl)) := rfl
  rw [e] at h
  obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok h
  have e0 : evalConst (.scalar bits) (.float fl) =
      decodeConst (encodeBits (Spec.Ty.float fl).size bits) (.float fl) := rfl
  rw [e0, hsz] at h1
  have e1 : decodeConst (encodeBits fl.size bits) (.float fl) =
      (match (Spec.Ty.float fl).decode (encodeBits fl.size bits) with
       | some v => (SemM.getMem >>= fun m =>
          SemM.liftE (checkValue m v (.float fl)) >>= fun _ => pure v)
       | none => throwIllFormed "constant is not valid at its type" : SemM Value) := rfl
  rw [e1, hdec] at h1
  have h1' : runOn (SemM.getMem >>= fun m =>
      SemM.liftE (checkValue m (.float fl (bits % 2 ^ (8 * fl.size))) (.float fl)) >>= fun _ =>
        pure (Value.float fl (bits % 2 ^ (8 * fl.size)))) o s = (.ok w, s2) := h1
  obtain ⟨m, s3, h3, h4⟩ := runOn_bind_ok h1'
  have h3' : ((Except.ok s.mem, s) : Except Outcome Memory × Spec.State) = (.ok m, s3) := h3
  obtain ⟨hm, hs3⟩ := prod_ok_inj h3'
  subst hm
  subst hs3
  obtain ⟨u, s4, h5, h6⟩ := runOn_bind_ok h4
  obtain ⟨-, hs4⟩ := runOn_liftE_ok h5
  rw [hs4] at h6
  obtain ⟨hw, hs2⟩ := prod_ok_inj h6
  subst hw
  subst hs2
  obtain ⟨hr, hs1⟩ := prod_ok_inj h2
  exact ⟨hr.symm, hs1.symm⟩

/-- A float operand whose L0 value is `.float fl u` (the state unchanged), `u` read back by R
from the slot at `x`. -/
def FOpndFacts (o : Spec.Oracle) (s : Spec.State) (st : OpSem.State) (fl : FloatTy)
    (op : Operand) (x : Int) : Prop :=
  ∀ r s3, runOn (evalOperand op) o s = (.ok r, s3) →
    s3 = s ∧ ∃ u ba, r = (.float fl u, .float fl) ∧ st.readFrame x fl.size = .ok ba ∧
      asNat ba = .ok u

theorem fopnd_local {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {op : Operand} {a : Local} (hl : op.local? = some a) {fl : FloatTy}
    (hta : f.body.locals[a]? = some (.float fl)) {sa : LocalSlot} (hsa : sa.size = fl.size)
    (hmem : MemInj ι s.mem st.mem)
    (hra : ∀ pa, f.locals[a]? = some (some pa) → LocalRel ι fp st s.mem sa pa true) :
    FOpndFacts o s st fl op sa.off := by
  intro r s3 h
  obtain ⟨p, ty, v, hp, hty, hlv, rfl, rfl⟩ := runOn_evalOperand_local hs hl h
  have e2 : ty = .float fl := Option.some.inj (hty.symm.trans hta)
  subst e2
  obtain ⟨bs, u, hlo, hd, rfl⟩ := typedLoad_float hlv
  rw [← hsa] at hlo
  obtain ⟨ba, hrf, hia⟩ := readLocal_inj hmem (hra p hp) hlo
  rw [hsa] at hrf
  exact ⟨rfl, u, ba, rfl, hrf, by unfold asNat; rw [decodeBits_inj hia hd]; rfl⟩

theorem fopnd_const {st : OpSem.State} {o : Spec.Oracle} {s : Spec.State} {fl : FloatTy}
    {bits : Nat} {x : Int} {ba : List AbstractByte}
    (hrf : st.readFrame x fl.size = .ok ba) (hva : asNat ba = .ok (bits % 2 ^ (8 * fl.size))) :
    FOpndFacts o s st fl (.const (.scalar bits) (.float fl)) x := by
  intro r s3 h
  obtain ⟨rfl, rfl⟩ := runOn_evalOperand_const_float h
  exact ⟨rfl, _, ba, rfl, hrf, hva⟩

/-! ### The simulation -/

/-- `lift_binFloat`'s body for operands given by `FOpndFacts` at slots `xa`, `xb`. -/
theorem sim_binFloatGen {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d : Local} {op : BinOp} {om : String} (hm : floatMethod op = some om) {fl : FloatTy}
    (htd : f.body.locals[d]? = some (.float fl))
    {sd : LocalSlot} (hsd : sd.size = fl.size)
    {pd : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hmem : MemInj ι s.mem st.mem)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {opc : Full.Opcode} {r : Option String} {ty : String}
    (hh : opc.handler? = some ⟨.fbin, [ty, om], r⟩) (hty : OpSem.Ty.parse ty = some (.float fl))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    {xa xb : Int}
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ xa ∧ xa < 2 ^ 31 ∧
      -2 ^ 31 ≤ xb ∧ xb < 2 ^ 31)
    {oa ob : Operand} (hA : FOpndFacts o s st fl oa xa) (hB : FOpndFacts o s st fl ob xb)
    {ch : OpSem.Choice} (hnan : NanPicks o s ch)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op oa ob))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot xa, .slot xb] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv) ∧
      s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd', td, ra, s3, rb, s4, v, s5, mem', hpd', htd', hea, heb, hev, hst, rfl⟩ :=
    assign_binop_gen_inv hs h
  obtain ⟨hs3, ua, ba, rfl, hrfa, hva⟩ := hA _ _ hea
  subst s3
  obtain ⟨hs4, ub, bb, rfl, hrfb, hvb⟩ := hB _ _ heb
  subst s4
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e4 : td = .float fl := Option.some.inj (htd'.symm.trans htd)
  subst e1 e4
  rw [evalBinOp_float hm] at hev
  obtain ⟨bits, rfl, hm2, hk2, hR⟩ := runOn_resolveFloat hev
  have hres : floatBin ch om fl ua ub = .ok bits := by
    rw [floatBin_res hm]; exact hR ch hnan
  have hsto0 := typedStore_float hst
  rw [hm2] at hsto0
  -- R's write
  have hlen : (intBytes fl.size bits).length = fl.size :=
    Ryo.Spec.Theorems.encodeBits_length _ _
  have hpw : ∀ k < (intBytes fl.size bits).length, st.escapedAt (sd.off + k) = none := by
    intro k hk
    rw [hlen, ← hsd] at hk
    exact hprivd k hk
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off (intBytes fl.size bits) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_fbin_fwd (ch := ch) hh hty ho hfits hrfa hrfb hva hvb hres hwr
  have hbs : BytesInj ι (encodeBits fl.size bits) (intBytes fl.size bits) :=
    encodeBits_inj ι _ _
  have hlen0 : (encodeBits fl.size bits).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto0 hwr
  refine ⟨st', hop, hmi, hrd, ?_, hk2, _, hsto0, encodeBits_noprov _ _⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto0 (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsd]; exact hap)

/-! ### The lift -/

theorem lift_binFloatConst {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerBinFloatConst Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hnan : NanPicks o s ch)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  -- the common part: the temporary, then the handler on the given slots
  have common : ∀ {fl : FloatTy} {bits : Nat} {sd : LocalSlot} {tt : Int} {i1 i2 : R.Insn}
      {om : String} {op : BinOp} (oa ob : Operand) (xa xb : Int),
      is = [i1, i2] → floatMethod op = some om → rv = .binaryOp op oa ob →
      Γ.body.locals[d]? = some (.float fl) → Γ.slots[d]? = some sd → sd.size = fl.size →
      offOk sd.off = true → (∀ k < sd.size, Γ.escaped (sd.off + k) = false) →
      tempOk Γ tt fl.size = true → immInsnOk Γ i1 fl.size tt bits = true →
      fbinInsnOk Γ i2 om fl sd.off xa xb = true →
      (∀ st1 : OpSem.State, ∀ x1, st1.readFrame tt fl.size = .ok (intBytes fl.size x1) →
        x1 % 2 ^ (8 * fl.size) = bits % 2 ^ (8 * fl.size) →
        FnRel Γ ι live f s.mem { s1 with pc := s1.pc + 1, st := st1 } →
        FOpndFacts o s st1 fl oa xa ∧ FOpndFacts o s st1 fl ob xb ∧
          -2 ^ 31 ≤ xa ∧ xa < 2 ^ 31 ∧ -2 ^ 31 ≤ xb ∧ xb < 2 ^ 31) →
      LiftOutN Γ c ch ι live' f s s' s1 is.length := by
    intro fl bits sd tt i1 i2 om op oa ob xa xb his hm hrv htd hsd hsize hoff hpriv ht hi1 hi2
      hfacts
    subst his hrv
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
    have hlen1 : (intBytes fl.size x1).length = fl.size :=
      Ryo.Spec.Theorems.encodeBits_length fl.size x1
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame tt fl.size = .ok (intBytes fl.size x1) := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    obtain ⟨hA, hB, hxa1, hxa2, hxb1, hxb2⟩ := hfacts st1 x1 hrd1 hx1 hrel1
    -- the handler
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := fbinInsnOk_spec hi2
    rw [hmode, hρ] at hv
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < sd.size := by
      rw [hsize]
      cases fl <;> first | decide | simp [FloatTy.size]
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binFloatGen (ch := ch) hs hm
      htd hsize hpd hrel1.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv' hh hty ho
      ⟨hf1.1, hf1.2, hxa1, hxa2, hxb1, hxb2⟩ hA hB hnan h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩
  cases hlow with
  | @constRight d a oa op om bits fl sd sa tt i1 i2 hm ha htd hta hsd hsa hsize hoff hpriv ht hi1
      hi2 =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    refine common oa _ sa.off tt rfl hm rfl htd hsd hsize.1 hoff.1 hpriv ht hi1 hi2 ?_
    intro st1 x1 hrd1 hx1 hrel1
    have hta' := hta
    rw [hbody] at hta'
    have hf := offOk_spec hoff.2
    have hft := offOk_spec (tempOk_spec ht).1
    refine ⟨fopnd_local hs ha hta' hsize.2 hrel1.frame.mem (fun pa hpa => hrel1.opnd hpa hsa hla),
      fopnd_const hrd1 ?_, hf.1, hf.2, hft.1, hft.2⟩
    rw [asNat_intBytes, hx1]
  | @constLeft d b ob op om bits fl sd sb tt i1 i2 hm hb htd htb hsd hsb hsize hoff hpriv ht hi1
      hi2 =>
    have hlb := hlo b (List.mem_append_right _ (operand_local_mem hb))
    refine common _ ob tt sb.off rfl hm rfl htd hsd hsize.1 hoff.1 hpriv ht hi1 hi2 ?_
    intro st1 x1 hrd1 hx1 hrel1
    have htb' := htb
    rw [hbody] at htb'
    have hf := offOk_spec hoff.2
    have hft := offOk_spec (tempOk_spec ht).1
    refine ⟨fopnd_const hrd1 ?_,
      fopnd_local hs hb htb' hsize.2 hrel1.frame.mem (fun pb hpb => hrel1.opnd hpb hsb hlb),
      hft.1, hft.2, hf.1, hf.2⟩
    rw [asNat_intBytes, hx1]

/-! ### The statement -/

theorem stmt_sim_binFloatConst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerBinFloatConst Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) (hnan : NanPicks o s ch) :
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
  exact lift_binFloatConst M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    hnan hl2 hl1 hev

end Ryo.Proofs.Lower
