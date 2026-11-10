/-
Ryo.Proofs.Lower.SimBinMore — the simulation of `LowerBinMore` (`Check/Lower/BinMore.lean`,
M5b): integer binary operators on field projections of locals and on two constants.

- Operands (`SimOvfConst.lean`'s `OpndFacts`): a place operand that `fieldPath` covers reads its
  integer from `slot + off` (`opndFacts_place`: `runOn_evalPlace_fields`, `readLocal_sub_inj`,
  `SimField.lean`); a constant in a temporary is `opndFacts_const`.
- `sim_binGen`/`sim_binImmGen`: `sim_binX`/`sim_binImmX` (`SimBinX.lean`) with the operands given
  by `OpndFacts`; the arithmetic is `binMore_refines`/`binMoreImm_refines` (`binMethod`'s
  operators by `refines_wrap`, `BinX.lean`'s by `binX_refines`/`binImmX_refines`).
- `lift_binMore` (`LiftOutN`: one step for the place rules, `step_immTemp` then the handler for
  `constConst` and `constLeft`), `stmt_sim_binMore` the statement's `StmtOut`
  (`stmt_simX_binMore` is in `SimBinMoreX.lean`).
-/
import Ryo.Proofs.Lower.SimOvfConst
import Ryo.Proofs.Lower.SimField
import Ryo.Check.Lower.BinMore

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Operands -/

theorem opndFacts_place {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {op : Operand} {a : Local} {projs : List ProjElem}
    (hl : operandPlace? op = some ⟨a, projs⟩) {ta : Spec.Ty} {t : IntType} {valid : ValidRange}
    {off : Nat} (hta : f.body.locals[a]? = some ta)
    (hpath : fieldPath ta projs = some (off, .int t valid)) {sa : LocalSlot}
    (hin : off + t.size ≤ sa.size) (hmem : MemInj ι s.mem st.mem)
    (hra : ∀ pa, f.locals[a]? = some (some pa) → LocalRel ι fp st s.mem sa pa true) :
    OpndFacts o s st t op (sa.off + off) := by
  intro r s3 h
  have e0 : evalOperand op = evalOperand (.copy ⟨a, projs⟩) := by
    cases op <;> simp [operandPlace?] at hl <;> subst hl <;>
      first | rfl | exact evalOperand_move _
  rw [e0] at h
  have e : evalOperand (.copy ⟨a, projs⟩) = (evalPlace ⟨a, projs⟩ >>= fun x => match x with
      | (pl, ty) => placeLoad pl ty >>= fun v => pure (v, ty)) := rfl
  rw [e] at h
  obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pa, hpa, rfl, hs2⟩ := runOn_evalPlace_fields hs hta hpath h1
  have h2' : runOn (placeLoad ⟨(⟨pa.addr + off, pa.prov⟩ : ThinPointer).widen, true⟩
      (.int t valid) >>= fun v => pure (v, Spec.Ty.int t valid)) o s2 = (.ok r, s3) := h2
  rw [hs2] at h2'
  obtain ⟨v, s4, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨hv, hs4⟩ := runOn_placeLoad_ok h3
  obtain ⟨hrv, hs3⟩ := prod_ok_inj h4
  obtain ⟨bs, u, hlo, hd, -, rfl⟩ := typedLoad_int hv
  have hlo' : s.mem.load ⟨pa.addr + off, pa.prov⟩ t.size .one = .ok bs := hlo
  obtain ⟨bs1, hrf, hia⟩ := readLocal_sub_inj hmem (hra pa hpa) hin hlo'
  refine ⟨hs3.symm.trans hs4, u, valid, bs1, hrv.symm, hrf, ?_⟩
  unfold asNat; rw [decodeBits_inj hia hd]; rfl

/-! ### Arithmetic -/

theorem refines_wrap {op : BinOp} {m : String} (hm : binMethod op = some m) (t : IntType)
    (sg : Bool) (u w : Nat) :
    BinRefines op m sg t (t.ofBits u) (t.ofBits w) (BitVec.ofNat _ u) (BitVec.ofNat _ w) := by
  intro dt o s s1 v h
  rw [evalIntBinOp_wrap hm] at h
  obtain ⟨hv, hs1⟩ := prod_ok_inj h
  obtain ⟨res, hres, hrn⟩ := intBin_wrap hm t sg u w
  exact ⟨hs1.symm, _, res, hv.symm, hres, hrn⟩

theorem binMore_refines {op : BinOp} {m : String} (hm : ccMethodB op = some m) {t : IntType}
    {sg : Bool} (hsg : binXSigned op = true → sg = t.signed) (hpos : 0 < t.size)
    (hmod : shiftOk t t = true) (u w : Nat) :
    BinRefines op m sg t (t.ofBits u) (t.ofBits w) (BitVec.ofNat _ u) (BitVec.ofNat _ w) := by
  unfold ccMethodB at hm
  split at hm
  next m' hb =>
    obtain rfl : m' = m := Option.some.inj hm
    exact refines_wrap hb t sg u w
  next => exact binX_refines hm hsg hpos hmod u w

theorem binMoreImm_refines {op : BinOp} {m : String} (hm : ccMethod op = some m)
    {t tc : IntType} {sg : Bool} (hsg : binXSigned op = true → sg = t.signed) (hpos : 0 < t.size)
    (hmod : immModOk op t tc = true) {x bits : Nat}
    (hx : x % immMod op t = bits % immMod op t) (u : Nat) :
    BinRefines op m sg t (t.ofBits u) (tc.ofBits (bits % 2 ^ (8 * tc.size)))
      (BitVec.ofNat _ u) (BitVec.ofNat _ x) := by
  unfold ccMethod at hm
  split at hm
  next m' hb =>
    obtain rfl : m' = m := Option.some.inj hm
    have hns : isShift op = false := by
      cases op <;> first | rfl | (simp [binMethod] at hb)
    have htc : tc = t := by
      have e : immModOk op t tc = (tc == t) := by
        first
          | (simp only [immModOk, hns]; done)
          | (unfold immModOk; rw [hns]; done)
          | (unfold immModOk; rw [hns]; rfl)
      rw [e] at hmod
      simpa using hmod
    have hx' : x % 2 ^ (8 * t.size) = bits % 2 ^ (8 * t.size) := by
      have e : immMod op t = 2 ^ (8 * t.size) := by
        first
          | (simp only [immMod, hns]; done)
          | (unfold immMod; rw [hns]; done)
          | (unfold immMod; rw [hns]; rfl)
      rw [e] at hx
      exact hx
    rw [htc, ofBits_congr t (show bits % 2 ^ (8 * t.size) % 2 ^ (8 * t.size) =
      x % 2 ^ (8 * t.size) by rw [Nat.mod_mod]; exact hx'.symm)]
    exact refines_wrap hb t sg u x
  next => exact binImmX_refines hm hsg hpos hmod hx u

/-! ### The simulations -/

/-- `sim_binX` with the operands given by `OpndFacts` at slots `xa`, `xb`. -/
theorem sim_binGen {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d : Local} {op : BinOp} {m : String} {t : IntType} {valid : ValidRange}
    (htd : f.body.locals[d]? = some (.int t valid))
    {sd : LocalSlot} (hsd : sd.size = t.size)
    {pd : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hmem : MemInj ι s.mem st.mem)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String} {sg : Bool}
    (hkd : binKd kd = true) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    {xa xb : Int}
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ xa ∧ xa < 2 ^ 31 ∧
      -2 ^ 31 ≤ xb ∧ xb < 2 ^ 31)
    (har : ∀ u w, BinRefines op m sg t (t.ofBits u) (t.ofBits w) (BitVec.ofNat _ u)
      (BitVec.ofNat _ w))
    {oa ob : Operand} (hA : OpndFacts o s st t oa xa) (hB : OpndFacts o s st t ob xb)
    {ch : OpSem.Choice}
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
  obtain ⟨hs3, ua, vla, ba, rfl, hrfa, hva⟩ := hA _ _ hea
  subst s3
  obtain ⟨hs4, ub, vlb, bb, rfl, hrfb, hvb⟩ := hB _ _ heb
  subst s4
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  subst e1 e4
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits ub) (.int t valid)) o s = _ at hev
  obtain ⟨hs1, iv, res, rfl, hres, hrn⟩ := (har ua ub) _ o s s5 v hev
  subst s5
  obtain ⟨st', hop, hmi, hrd, hoth, bs, hsto, hnp⟩ := sim_int_write hsd hmem ad xd hpdp hιd hxd
    hlived haddrd hpaddrd hsized hprivd hst hrn
    (fun st' hwr => opSem_binX_fwd (ch := ch) hkd hh hty ho hfits hrfa hrfb hva hvb hres hwr)
  exact ⟨st', hop, hmi, hrd, hoth, rfl, bs, hsto, hnp⟩

/-- `sim_binImmX` with the left operand given by `OpndFacts` at slot `xa`. -/
theorem sim_binImmGen {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d : Local} {op : BinOp} {m : String} {t tc : IntType} {valid vc : ValidRange} {bits : Nat}
    (htd : f.body.locals[d]? = some (.int t valid))
    {sd : LocalSlot} (hsd : sd.size = t.size)
    {pd : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hmem : MemInj ι s.mem st.mem)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String} {sg : Bool}
    {k : OperandKind} {x : Nat}
    (hkd : binImmKd kd = true) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩])
    {xa : Int}
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ xa ∧ xa < 2 ^ 31)
    (hfk : Val.fits k (.imm x) = true)
    (har : ∀ u, BinRefines op m sg t (t.ofBits u) (tc.ofBits (bits % 2 ^ (8 * tc.size)))
      (BitVec.ofNat _ u) (BitVec.ofNat _ x))
    {oa : Operand} (hA : OpndFacts o s st t oa xa)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op oa (.const (.scalar bits) (.int tc vc))))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot xa, .imm x] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv) ∧
      s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd', td, ra, s3, rb, s4, v, s5, mem', hpd', htd', hea, heb, hev, hst, rfl⟩ :=
    assign_binop_gen_inv hs h
  obtain ⟨hs3, ua, vla, ba, rfl, hrfa, hva⟩ := hA _ _ hea
  subst s3
  obtain ⟨hrb, hs4⟩ := runOn_evalOperand_const_scalar_int heb
  subst rb s4
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  subst e1 e4
  change runOn (evalIntBinOp op t (t.ofBits ua) (tc.ofBits (bits % 2 ^ (8 * tc.size)))
    (.int t valid)) o s = _ at hev
  obtain ⟨hs1, iv, res, rfl, hres, hrn⟩ := (har ua) _ o s s5 v hev
  subst s5
  obtain ⟨st', hop, hmi, hrd, hoth, bs, hsto, hnp⟩ := sim_int_write hsd hmem ad xd hpdp hιd hxd
    hlived haddrd hpaddrd hsized hprivd hst hrn
    (fun st' hwr => opSem_binImmX_fwd (ch := ch) hkd hh hty ho hfits hfk hrfa hva hres hwr)
  exact ⟨st', hop, hmi, hrd, hoth, rfl, bs, hsto, hnp⟩

/-! ### The lift -/

/-- A `PlaceInt` operand's facts against `FnRel` (its base local live). -/
theorem placeInt_facts {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {s : Spec.State} {s1 : R.RState} {rest : List Spec.Frame} {o : Spec.Oracle}
    (hs : s.stack = f :: rest) (hbody : Γ.body = f.body) (hrel : FnRel Γ ι live f s.mem s1)
    {oa : Operand} {t : IntType} {xa : Int} (hA : PlaceInt Γ oa t xa)
    (hlive : ∀ a, a ∈ operandLocals oa → live a = true) :
    OpndFacts o s s1.st t oa xa ∧ -2 ^ 31 ≤ xa ∧ xa < 2 ^ 31 := by
  cases hA with
  | @mk a projs ta off valid sa hl hta hpath hsa hin hx hoff =>
    subst hx
    have hla : live a = true := hlive a (operandPlace?_mem hl)
    rw [hbody] at hta
    exact ⟨opndFacts_place hs hl hta hpath hin hrel.frame.mem
      (fun pa hpa => hrel.opnd hpa hsa hla), offOk_spec hoff⟩

theorem lift_binMore {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerBinMore Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @placeBin d oa ob op m t valid sd xa xb i hm hmod htd hsd hsize hoff hpriv hA hB hbi =>
    have hc0 : c.d.insns[s1.pc]? = some i := by simpa using hi 0 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hpl0 : PlainView c.mode c.ρ i := hpl i (by simp)
    obtain ⟨hfa, hxa1, hxa2⟩ := placeInt_facts (o := o) hs hbody hrel hA
      (fun a ha => hlo a (List.mem_append_left _ ha))
    obtain ⟨hfb, hxb1, hxb2⟩ := placeInt_facts (o := o) hs hbody hrel hB
      (fun a ha => hlo a (List.mem_append_right _ ha))
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binXInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize]; exact hpos
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binGen (ch := ch) hs htd hsize
      hpd hrel.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv hkd hh hty' ho
      ⟨hf1.1, hf1.2, hxa1, hxa2, hxb1, hxb2⟩ (fun u w => binMore_refines hm hsg hpos hmod u w)
      hfa hfb h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_of_lift ⟨st', step_of_view hc0 hsc0 hpe hpl0 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩
  | @placeImm d oa op m bits t tc valid vc sd xa i hm hmod htd hsd hsize hoff hpriv hA hbi =>
    have hc0 : c.d.insns[s1.pc]? = some i := by simpa using hi 0 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hpl0 : PlainView c.mode c.ρ i := hpl i (by simp)
    obtain ⟨hfa, hxa1, hxa2⟩ := placeInt_facts (o := o) hs hbody hrel hA
      (fun a ha => hlo a (List.mem_append_left _ ha))
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmXInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsModOk_spec hops
    obtain ⟨k, ho⟩ := operands3 hn hk
    have hops'' : v.ops = [.slot sd.off, .slot xa, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl0.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize]; exact hpos
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binImmGen (ch := ch) hs htd
      hsize hpd hrel.frame.mem ad xd hp hι hxd hl haddr hpaddr hsz hpv hkd hh hty' ho
      ⟨hf1.1, hf1.2, hxa1, hxa2⟩ hfk (fun u => binMoreImm_refines hm hsg hpos hmod hx u) hfa h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_of_lift ⟨st', step_of_view hc0 hsc0 hpe hpl0 hv hctl
      (by rw [hops'']; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩
  | @constConst d op m ba bb t tc valid va vc sd tt i1 i2 hm hmod htd hsd hsize hoff hpriv ht
      hi1 hi2 =>
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
    have hva : asNat (intBytes t.size x1) = .ok (ba % 2 ^ (8 * t.size)) := by
      rw [asNat_intBytes, hx1]
    -- the handler
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmXInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsModOk_spec hops
    obtain ⟨k, ho⟩ := operands3 hn hk
    have hops'' : v.ops = [.slot sd.off, .slot tt, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl1.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize]; exact hpos
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff
    have hf2 := offOk_spec hft
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binImmGen (ch := ch) hs htd
      hsize hpd hrel1.frame.mem ad xd hp hι hxd hl haddr hpaddr hsz hpv' hkd hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk (fun u => binMoreImm_refines hm hsg hpos hmod hx u)
      (opndFacts_const hrd1 hva) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops'']; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩

  | @constLeft d ob op m ba t valid va sd xb tt i1 i2 hm hmod htd hsd hsize hoff hpriv hB ht hi1
      hi2 =>
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
    have hva : asNat (intBytes t.size x1) = .ok (ba % 2 ^ (8 * t.size)) := by
      rw [asNat_intBytes, hx1]
    obtain ⟨hfb, hxb1, hxb2⟩ := placeInt_facts (o := o) hs hbody hrel1 hB
      (fun a ha => hlo a (List.mem_append_right _ ha))
    -- the handler
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binXInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize]; exact hpos
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff
    have hf2 := offOk_spec hft
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binGen (ch := ch) hs htd hsize
      hpd hrel1.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv' hkd hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2, hxb1, hxb2⟩ (fun u w => binMore_refines hm hsg hpos hmod u w)
      (opndFacts_const hrd1 hva) hfb h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩

/-! ### The statement -/

theorem stmt_sim_binMore {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerBinMore Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h <;> exact ⟨_, _, rfl⟩
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hwf : IntsSized f.body := by rw [M.body]; exact hfn.ints
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
  exact lift_binMore M.stack M.body.symm hwf hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    hl2 hl1 hev

end Ryo.Proofs.Lower
