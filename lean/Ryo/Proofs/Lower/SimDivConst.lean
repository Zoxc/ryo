/-
Ryo.Proofs.Lower.SimDivConst — the simulation of `LowerDivConst` (`Check/Lower/DivConst.lean`,
M5b): `Div`/`Rem` by an integer constant.

- `pow2Div`/`pow2Rem` (one instruction): `SimBinX.lean`'s `sim_binImmX` with the arithmetic of a
  power-of-two divisor: on the unsigned value, `u / 2 ^ k` is `u >>> k` (`refines_pow2Div`,
  `shr_arith`) and `u % 2 ^ k` is `u &&& (2 ^ k - 1)` (`refines_pow2Rem`,
  `Nat.and_two_pow_sub_one_eq_mod`); L0's `tdiv`/`tmod` of non-negative integers are `Nat`'s.
- `tempRight` (two instructions): the `imm` into the temporary (`step_immTemp`,
  `FnRel.tempWrite`, `SimCmpConst.lean`), then `sim_binX` with the right operand read from it
  (`sim_binXConstR`); `binX_refines` (`refines_divrem`) covers the constant's bits.
- `ccPow2Div`/`ccPow2Rem` (two instructions): the left constant into a temporary, then the
  power-of-two shift or mask on it (`SimBinMore.lean`'s `sim_binImmGen`, `opndFacts_const`).
- `lift_divConst` (`LiftOutN`: `liftOutN_of_lift` for the one-instruction rules,
  `liftOutN_two` for the others), `stmt_sim_divConst` the statement's `StmtOut`
  (`stmt_simX_divConst`, the scoped case, is in `SimDivConstX.lean`).
-/
import Ryo.Proofs.Lower.SimBinXConst
import Ryo.Proofs.Lower.SimBinMore
import Ryo.Check.Lower.DivConst

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Arithmetic -/

/-- Unsigned division by `2 ^ k` is a right shift by `k`. -/
theorem refines_pow2Div {t : IntType} (hpos : 0 < t.size) (hsg : t.signed = false)
    {c k x : Nat} (hc : c % t.modulus = 2 ^ k)
    (hx : (BitVec.ofNat (8 * t.size) x).toNat % (8 * t.size) = k) (u : Nat) :
    BinRefines .div "wrapping_shr" false t (t.ofBits u) (t.ofBits c) (BitVec.ofNat _ u)
      (BitVec.ofNat _ x) := by
  intro dt o s s1 v h
  obtain ⟨hs1, -, -, rfl⟩ := div_ok h
  obtain ⟨res, h1, h2⟩ := shr_arith (t := t) hpos (u := u) hx
  rw [hsg] at h1
  have e : (t.ofBits u).tdiv (t.ofBits c) = t.ofBits u / 2 ^ k := by
    rw [ofBits_unsigned hsg u, ofBits_unsigned hsg c, hc] <;> rfl
  refine ⟨hs1, _, res, rfl, h1, ?_⟩
  rw [e]
  exact h2

/-- Unsigned remainder by `2 ^ k` is a mask with `2 ^ k - 1`. -/
theorem refines_pow2Rem {t : IntType} (hsg : t.signed = false) {c k x : Nat}
    (hc : c % t.modulus = 2 ^ k) (hx : x % 2 ^ (8 * t.size) = 2 ^ k - 1) (sg : Bool) (u : Nat) :
    BinRefines .rem "&" sg t (t.ofBits u) (t.ofBits c) (BitVec.ofNat _ u)
      (BitVec.ofNat _ x) := by
  intro dt o s s1 v h
  obtain ⟨hs1, -, -, rfl⟩ := rem_ok h
  have e : (t.ofBits u).tmod (t.ofBits c) = ((u % t.modulus % 2 ^ k : Nat) : Int) := by
    rw [ofBits_unsigned hsg u, ofBits_unsigned hsg c, hc] <;> rfl
  refine ⟨hs1, _, _, rfl, rfl, ?_⟩
  rw [e, toBits_natCast_lt t (Nat.lt_of_le_of_lt (Nat.mod_le (u % t.modulus) (2 ^ k))
      (Nat.mod_lt u (Ryo.Spec.Theorems.IntType.modulus_pos t))),
    BitVec.toNat_and, BitVec.toNat_ofNat, BitVec.toNat_ofNat, hx,
    Nat.and_two_pow_sub_one_eq_mod, modulus_eq_two_pow]

/-! ### The temporary form -/

/-- `sim_binX` with a constant right operand, R's right bytes `bb` read from slot `tt`. -/
theorem sim_binXConstR {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {oa : Operand} {op : BinOp} {m : String} {t : IntType}
    {valid vc : ValidRange} {bits : Nat} (ha : oa.local? = some a)
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    {sd sa : LocalSlot} (hsd : sd.size = t.size) (hsa : sa.size = t.size)
    {pd pa : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa))
    (hmem : MemInj ι s.mem st.mem) (hra : LocalRel ι fp st s.mem sa pa true)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {tt : Int} {bb : List AbstractByte} (hrfb : st.readFrame tt t.size = .ok bb)
    (hvb : asNat bb = .ok (bits % 2 ^ (8 * t.size)))
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String} {sg : Bool}
    (hkd : binKd kd = true) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31 ∧
      -2 ^ 31 ≤ tt ∧ tt < 2 ^ 31)
    (har : ∀ u w, BinRefines op m sg t (t.ofBits u) (t.ofBits w) (BitVec.ofNat _ u)
      (BitVec.ofNat _ w))
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op oa (.const (.scalar bits) (.int t vc))))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off, .slot tt] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv) ∧
      s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd', td, ra, s3, rb, s4, v, s5, mem', hpd', htd', hea, heb, hev, hst, rfl⟩ :=
    assign_binop_gen_inv hs h
  obtain ⟨pa', ta, va', hpa', hta', hla, hra', hs3⟩ := runOn_evalOperand_local hs ha hea
  subst ra s3
  obtain ⟨hrb, hs4⟩ := runOn_evalOperand_const_scalar_int heb
  subst rb s4
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hla
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size)))
    (.int t valid)) o s = _ at hev
  obtain ⟨hs1, iv, res, rfl, hres, hrn⟩ := (har ua (bits % 2 ^ (8 * t.size))) _ o s s5 v hev
  subst s5
  rw [← hsa] at hloa
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  rw [hsa] at hrfa
  have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
  obtain ⟨st', hop, hmi, hrd, hoth, bs, hsto, hnp⟩ := sim_int_write hsd hmem ad xd hpdp hιd hxd
    hlived haddrd hpaddrd hsized hprivd hst hrn
    (fun st' hwr => opSem_binX_fwd (ch := ch) hkd hh hty ho hfits hrfa hrfb hva hvb hres hwr)
  exact ⟨st', hop, hmi, hrd, hoth, rfl, bs, hsto, hnp⟩

/-! ### The lift -/

/-- The one-instruction rules: `sim_binImmX` with `har`, lifted as `lift_binX`'s `binImm`. -/
theorem lift_divPow2 {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d a : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {t : IntType}
    {valid vc : ValidRange} {sd sa : LocalSlot} {q kbits : Nat} {chk sg0 : Bool} {i : R.Insn}
    (ha : oa.local? = some a)
    (htd : Γ.body.locals[d]? = some (.int t valid))
    (hta : Γ.body.locals[a]? = some (.int t valid))
    (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
    (hsize : sd.size = t.size ∧ sa.size = t.size)
    (hoff : offOk sd.off = true ∧ offOk sa.off = true)
    (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
    (hbi : binImmXInsnOk Γ i m t.size chk sg0 sd.off sa.off q kbits = true)
    (har : ∀ sg x, (chk = true → sg = sg0) → x % q = kbits % q → ∀ u,
      BinRefines op m sg t (t.ofBits u) (t.ofBits (bits % 2 ^ (8 * t.size))) (BitVec.ofNat _ u)
        (BitVec.ofNat _ x))
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hla : live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op oa (.const (.scalar bits) (.int t vc))))) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  rw [eval_binopImm_norm ha] at h
  obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmXInsnOk_spec hbi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
  obtain ⟨x, hops', hx⟩ := immOpsModOk_spec hops
  obtain ⟨k, ho⟩ := operands3 hn hk
  have hops'' : v.ops = [.slot sd.off, .slot sa.off, .imm x] := hops'
  have hfk : Val.fits k (.imm x) = true :=
    fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
  rw [hbody] at htd hta
  obtain ⟨pd, pa, _, _, _, _, hpd, hpa, -⟩ := assign_binimm_inv hs h
  have hra := hrel.opnd hpa hsa hla
  have hpos : 0 < t.size := hwf d t valid htd
  have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
  obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
    hrel.priv_dst hpd hsd hpos' hpriv
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binImmX (ch := ch) hs htd hta
    hsize.1 hsize.2 hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hkd hh
    hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk (har sg x hsg hx) h
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
    hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩

theorem lift_divConst {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerDivConst Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @tempRight d a oa op m bits t valid vc sd sa tt i1 i2 hm ha hmod htd hta hsd hsa hsize hoff
      hpriv ht hi1 hi2 =>
    obtain ⟨hft, -, htpv, hap⟩ := tempOk_spec ht
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
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
    -- the handler
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binXInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
    rw [hbody] at htd hta
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -, hea, -⟩ := assign_binop_gen_inv hs h
    obtain ⟨pa, _, _, hpa, -⟩ := runOn_evalOperand_local hs ha hea
    have hra := hrel1.opnd hpa hsa hla
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hf3 := offOk_spec hft
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binXConstR (ch := ch) hs ha htd
      hta hsize.1 hsize.2 hpd hpa hrel1.frame.mem hra ad xd hp hι hx hl haddr hpaddr hsz hpv'
      hrd1 hvb hkd hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩
      (fun u w => binX_refines hm hsg hpos hmod u w) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩
  | @pow2Div d a oa bits t valid vc sd sa k i ha hsg hmod hk hkw htd hta hsd hsa hsize hoff
      hpriv hbi =>
    have hc0 : c.d.insns[s1.pc]? = some i := by simpa using hi 0 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hpl0 : PlainView c.mode c.ρ i := hpl i (by simp)
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    have hpos : 0 < t.size := hwf d t valid (by rw [← hbody]; exact htd)
    obtain ⟨hd1, -⟩ := shiftOk_spec hmod
    have hc : bits % 2 ^ (8 * t.size) % t.modulus = 2 ^ k := by
      rw [← modulus_eq_two_pow, Nat.mod_mod]; exact hk
    refine liftOutN_of_lift (lift_divPow2 hs hbody hwf hmode hρ ha htd hta hsd hsa hsize hoff
      hpriv hbi ?_ hc0 hsc0 hpe hpl0 hrel hpb hla hlive' h)
    intro sg x hsg' hx u
    obtain rfl := hsg' rfl
    have hx' : (BitVec.ofNat (8 * t.size) x).toNat % (8 * t.size) = k := by
      rw [BitVec.toNat_ofNat, Nat.mod_mod_of_dvd x hd1, hx, Nat.mod_eq_of_lt hkw]
    exact refines_pow2Div hpos hsg hc hx' u
  | @pow2Rem d a oa bits t valid vc sd sa k i ha hsg hk htd hta hsd hsa hsize hoff hpriv hbi =>
    have hc0 : c.d.insns[s1.pc]? = some i := by simpa using hi 0 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hpl0 : PlainView c.mode c.ρ i := hpl i (by simp)
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    have hc : bits % 2 ^ (8 * t.size) % t.modulus = 2 ^ k := by
      rw [← modulus_eq_two_pow, Nat.mod_mod]; exact hk
    have hlt : 2 ^ k - 1 < 2 ^ (8 * t.size) := by
      have h1 := Nat.mod_lt bits (Nat.two_pow_pos (8 * t.size))
      rw [hk] at h1
      omega
    refine liftOutN_of_lift (lift_divPow2 hs hbody hwf hmode hρ ha htd hta hsd hsa hsize hoff
      hpriv hbi ?_ hc0 hsc0 hpe hpl0 hrel hpb hla hlive' h)
    intro sg x _ hx u
    have hx' : x % 2 ^ (8 * t.size) = 2 ^ k - 1 := by
      rw [hx, Nat.mod_eq_of_lt hlt]
    exact refines_pow2Rem hsg hc hx' sg u

  | @ccPow2Div d ba bb t valid va vc sd k tt i1 i2 hsg hmod hk hkw htd hsd hsize hoff hpriv
      ht hi1 hi2 =>
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
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk', hops, hctl⟩ := binImmXInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg'⟩ := intTyOkS_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsModOk_spec hops
    obtain ⟨kk, ho⟩ := operands3 hn hk'
    have hops'' : v.ops = [.slot sd.off, .slot tt, .imm x] := hops'
    have hfk : Val.fits kk (.imm x) = true :=
      fits_last (hpl1.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize]; exact hpos
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff
    have hf2 := offOk_spec hft
    have hc : bb % 2 ^ (8 * t.size) % t.modulus = 2 ^ k := by
      rw [← modulus_eq_two_pow, Nat.mod_mod]; exact hk
    obtain rfl := hsg' rfl
    obtain ⟨hd1, -⟩ := shiftOk_spec hmod
    have hx' : (BitVec.ofNat (8 * t.size) x).toNat % (8 * t.size) = k := by
      rw [BitVec.toNat_ofNat, Nat.mod_mod_of_dvd x hd1, hx, Nat.mod_eq_of_lt hkw]
    have har := fun u => refines_pow2Div hpos hsg hc hx' u
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binImmGen (ch := ch) hs htd
      hsize hpd hrel1.frame.mem ad xd hp hι hxd hl haddr hpaddr hsz hpv' hkd hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk har (opndFacts_const hrd1 hva) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops'']; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩
  | @ccPow2Rem d ba bb t valid va vc sd k tt i1 i2 hsg hk htd hsd hsize hoff hpriv ht hi1 hi2 =>
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
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk', hops, hctl⟩ := binImmXInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg'⟩ := intTyOkS_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsModOk_spec hops
    obtain ⟨kk, ho⟩ := operands3 hn hk'
    have hops'' : v.ops = [.slot sd.off, .slot tt, .imm x] := hops'
    have hfk : Val.fits kk (.imm x) = true :=
      fits_last (hpl1.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -⟩ := assign_binop_gen_inv hs h
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize]; exact hpos
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff
    have hf2 := offOk_spec hft
    have hc : bb % 2 ^ (8 * t.size) % t.modulus = 2 ^ k := by
      rw [← modulus_eq_two_pow, Nat.mod_mod]; exact hk
    have hlt : 2 ^ k - 1 < 2 ^ (8 * t.size) := by
      have h1 := Nat.mod_lt bb (Nat.two_pow_pos (8 * t.size))
      rw [hk] at h1
      omega
    have hx' : x % 2 ^ (8 * t.size) = 2 ^ k - 1 := by
      rw [hx, Nat.mod_eq_of_lt hlt]
    have har := fun u => refines_pow2Rem hsg hc hx' sg u
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binImmGen (ch := ch) hs htd
      hsize hpd hrel1.frame.mem ad xd hp hι hxd hl haddr hpaddr hsz hpv' hkd hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk har (opndFacts_const hrd1 hva) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops'']; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩

/-! ### The statement -/

theorem stmt_sim_divConst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerDivConst Γ.toStmtCtx st (rangeInsns c.d r))
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
  exact lift_divConst M.stack M.body.symm hwf hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    hl2 hl1 hev

end Ryo.Proofs.Lower
