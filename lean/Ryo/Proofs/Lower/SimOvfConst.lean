/-
Ryo.Proofs.Lower.SimOvfConst — the simulation of `LowerOvfConst`
(`Check/Lower/OvfConst.lean`, M5b): `_d = op(_a, const)` or `op(const, _b)` for the
overflow-checked operators, lowered to `imm tt, bits` and the `ovf` handler with `tt` for the
constant.

- `sim_ovfGen`: `SimOvf.lean`'s `sim_ovf` for any two operands whose L0 values are integers of
  `t` R reads back from given slots (`OpndFacts`: `opndFacts_local` for a whole local,
  `opndFacts_const` for the constant in the temporary).
- The `imm` (`step_immTemp`, `FnRel.tempWrite`, `SimCmpConst.lean`): R writes the constant's
  bytes to the private temporary; L0 takes no step.
- `lift_ovfConst` puts them together (`liftOutN_two`); `stmt_sim_ovfConst` is the statement's
  `StmtOut` (`stmt_simX_ovfConst`, the scoped case, is in `SimOvfConstX.lean`).
-/
import Ryo.Proofs.Lower.SimOvf
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Check.Lower.OvfConst

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- An operand whose L0 value is an integer of `t` (the state unchanged), its bits read back by
R from the slot at `x`. -/
def OpndFacts (o : Spec.Oracle) (s : Spec.State) (st : OpSem.State) (t : IntType)
    (op : Operand) (x : Int) : Prop :=
  ∀ r s3, runOn (evalOperand op) o s = (.ok r, s3) →
    s3 = s ∧ ∃ u vl ba, r = (.int (t.ofBits u), .int t vl) ∧ st.readFrame x t.size = .ok ba ∧
      asNat ba = .ok u

theorem opndFacts_local {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {op : Operand} {a : Local} (hl : op.local? = some a) {t : IntType} {valid : ValidRange}
    (hta : f.body.locals[a]? = some (.int t valid)) {sa : LocalSlot} (hsa : sa.size = t.size)
    {pa : ThinPointer} (hpa : f.locals[a]? = some (some pa)) (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true) : OpndFacts o s st t op sa.off := by
  intro r s3 h
  obtain ⟨p, ty, v, hp, hty, hlv, rfl, rfl⟩ := runOn_evalOperand_local hs hl h
  have e1 : p = pa := Option.some.inj (Option.some.inj (hp.symm.trans hpa))
  have e2 : ty = .int t valid := Option.some.inj (hty.symm.trans hta)
  subst e1 e2
  obtain ⟨bs, u, hlo, hd, -, rfl⟩ := typedLoad_int hlv
  rw [← hsa] at hlo
  obtain ⟨ba, hrf, hia⟩ := readLocal_inj hmem hra hlo
  rw [hsa] at hrf
  exact ⟨rfl, u, valid, ba, rfl, hrf, by unfold asNat; rw [decodeBits_inj hia hd]; rfl⟩

theorem opndFacts_const {st : OpSem.State} {o : Spec.Oracle} {s : Spec.State} {t : IntType}
    {bits : Nat} {vc : ValidRange} {x : Int} {ba : List AbstractByte}
    (hrf : st.readFrame x t.size = .ok ba) (hva : asNat ba = .ok (bits % 2 ^ (8 * t.size))) :
    OpndFacts o s st t (.const (.scalar bits) (.int t vc)) x := by
  intro r s3 h
  obtain ⟨rfl, rfl⟩ := runOn_evalOperand_const_scalar_int h
  exact ⟨rfl, _, vc, ba, rfl, hrf, hva⟩

/-- `sim_ovf` for any two operands with `OpndFacts`, R's operand slots `xa`, `xb`. -/
theorem sim_ovfGen {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d : Local} {op : BinOp} {m : String} (hm : ovfMethod op = some m)
    {t : IntType} {vt : ValidRange} {ov oo : Nat} {head : TupleHeadLayout}
    (hwf : t.wf = true) (hpos : 0 < t.size)
    (htd : f.body.locals[d]? = some (.tuple [(ov, .int t vt), (oo, .bool)] head none))
    {sd : LocalSlot} (hsd : sd.size = head.headSizeAndAlign.1)
    (hov : ov + t.size ≤ sd.size) (hoo : oo + 1 ≤ sd.size)
    {pd : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hmem : MemInj ι s.mem st.mem)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {opc : Full.Opcode} {r : Option String} {ty : String}
    (hh : opc.handler? = some ⟨.ovf, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size t.signed))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"o", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    {xa xb : Int}
    (hfits : -2 ^ 31 ≤ sd.off + ov ∧ sd.off + ov < 2 ^ 31 ∧ -2 ^ 31 ≤ sd.off + oo ∧
      sd.off + oo < 2 ^ 31 ∧ -2 ^ 31 ≤ xa ∧ xa < 2 ^ 31 ∧ -2 ^ 31 ≤ xb ∧ xb < 2 ^ 31)
    {oa ob : Operand} (hA : OpndFacts o s st t oa xa) (hB : OpndFacts o s st t ob xb)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op oa ob))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot (sd.off + ov), .slot (sd.off + oo), .slot xa, .slot xb] st
        ch = .ok (.next, st') ∧
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
  have e4 : td = .tuple [(ov, .int t vt), (oo, .bool)] head none :=
    Option.some.inj (htd'.symm.trans htd)
  subst e1 e4
  -- the operation
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits ub)
    (.tuple [(ov, .int t vt), (oo, .bool)] head none)) o s = _ at hev
  obtain ⟨hs1, rfl⟩ := ovf_ok hm hev
  subst s5
  generalize hi : ovfExact op (t.ofBits ua) (t.ofBits ub) = i at hst
  -- the store
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have hrep : t.canRepresent (t.bringInBounds i) = true :=
    Ryo.Spec.Theorems.IntType.canRepresent_ofBits t hwf (t.toBits i)
  rw [encode_pair hrep] at hen
  obtain rfl := Option.some.inj hen
  have hres := intOvf_eq hm (sg := t.signed) (BitVec.ofNat (8 * t.size) ua)
    (BitVec.ofNat (8 * t.size) ub)
  rw [val_ofNat hpos, val_ofNat hpos, hi, val_ofInt hpos, ovf_flag hwf] at hres
  -- the bytes R writes are L0's
  have hRV : intBytes t.size (BitVec.ofInt (8 * t.size) i).toNat =
      encodeBits t.size (t.toBits (t.bringInBounds i)) := by
    show encodeBits t.size _ = _
    rw [toNat_ofInt_toBits, Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
      (Ryo.Spec.Theorems.IntType.bringInBounds_emod t i)]
  have hRB : boolByte (!t.canRepresent i) =
      [.init (if (!t.canRepresent i) then 1 else 0) none] := by
    generalize (!t.canRepresent i) = fl
    cases fl <;> first | rfl | decide
  -- R's writes
  have hEV : (encodeBits t.size (t.toBits (t.bringInBounds i))).length = t.size :=
    Ryo.Spec.Theorems.encodeBits_length _ _
  have hpV := privRange hprivd (off := sd.off + ov) (n := t.size) (by omega) (by omega)
  have hpB := privRange hprivd (off := sd.off + oo) (n := 1) (by omega) (by omega)
  have hw1 := writeFrame_priv_ok (st := st) (off := sd.off + ov)
    (bs := encodeBits t.size (t.toBits (t.bringInBounds i)))
    (fun j hj => hpV _ (by omega) (by rw [hEV] at hj; omega))
  have hw2 := writeFrame_priv_ok
    (st := privState st (sd.off + ov) (encodeBits t.size (t.toBits (t.bringInBounds i))))
    (off := sd.off + oo) (bs := [.init (if (!t.canRepresent i) then 1 else 0) none])
    (fun j hj => hpB _ (by omega) (by simp at hj; omega))
  have hfits' := hfits
  obtain ⟨hf1, hf2, hf3, hf4, hf5, hf6, hf7, hf8⟩ := hfits'
  have hop := opSem_ovf_fwd (ch := ch) hh hty ho hfits hrfa hrfb hva hvb hres
    (by rw [hRV]; exact hw1) (by rw [hRB]; exact hw2)
  -- the frame after both writes
  have hframe := ovf_frame (st := st) (n := t.size) (m := 1) hEV (rfl : ([AbstractByte.init
    (if (!t.canRepresent i) then 1 else 0) none]).length = 1) hpV hpB
  have hselfV : ∀ e ∈ encodeBits t.size (t.toBits (t.bringInBounds i)), ByteInj ι e e :=
    fun e he => encodeBits_inj_self he
  have hselfB : ∀ e ∈ ([AbstractByte.init (if (!t.canRepresent i) then 1 else 0) none]),
      ByteInj ι e e := by
    intro e he
    rw [List.mem_singleton.mp he]
    exact rfl
  have hbs := ovf_bytes (ι := ι) (N := sd.size) hEV rfl hov hoo hselfV hselfB
    (F := fun k => (privState (privState st (sd.off + ov)
      (encodeBits t.size (t.toBits (t.bringInBounds i)))) (sd.off + oo)
      [.init (if (!t.canRepresent i) then 1 else 0) none]).frame (sd.off + k))
    (G := fun k => st.frame (sd.off + k))
    (fun k hk => by
      try dsimp only
      rw [hframe]
      try dsimp only
      by_cases h1 : oo ≤ k ∧ k < oo + 1
      · have hA : sd.off + (oo : Int) ≤ sd.off + (k : Int) ∧
            sd.off + (k : Int) < sd.off + (oo : Int) + ((1 : Nat) : Int) := by omega
        have e : (sd.off + (k : Int) - (sd.off + (oo : Int))).toNat = k - oo := by omega
        rw [if_pos hA, if_pos h1, e]
      · have hA : ¬(sd.off + (oo : Int) ≤ sd.off + (k : Int) ∧
            sd.off + (k : Int) < sd.off + (oo : Int) + ((1 : Nat) : Int)) := by omega
        rw [if_neg hA, if_neg h1]
        by_cases h2 : ov ≤ k ∧ k < ov + t.size
        · have hB : sd.off + (ov : Int) ≤ sd.off + (k : Int) ∧
              sd.off + (k : Int) < sd.off + (ov : Int) + ((t.size : Nat) : Int) := by omega
          have e : (sd.off + (k : Int) - (sd.off + (ov : Int))).toNat = k - ov := by omega
          rw [if_pos hB, if_pos h2, e]
        · have hB : ¬(sd.off + (ov : Int) ≤ sd.off + (k : Int) ∧
              sd.off + (k : Int) < sd.off + (ov : Int) + ((t.size : Nat) : Int)) := by omega
          rw [if_neg hB, if_neg h2])
  rw [← hsd] at hsto
  have hN1 : (writeAt (List.replicate sd.size AbstractByte.uninit) ov
      (encodeBits t.size (t.toBits (t.bringInBounds i)))).length = sd.size := by
    rw [Ryo.Spec.Theorems.writeAt_length _ _ _ (by rw [List.length_replicate, hEV]; exact hov),
      List.length_replicate]
  have hN2 : (writeAt (writeAt (List.replicate sd.size AbstractByte.uninit) ov
      (encodeBits t.size (t.toBits (t.bringInBounds i)))) oo
      [.init (if (!t.canRepresent i) then 1 else 0) none]).length = sd.size := by
    rw [Ryo.Spec.Theorems.writeAt_length _ _ _ (by rw [hN1]; exact hoo), hN1]
  obtain ⟨hmi, hrd⟩ := frameLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hN2 hbs hsto rfl rfl
  refine ⟨_, hop, hmi, hrd, ?_, rfl, _, hsto, ovf_noprov⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  refine LocalRel.frame_apart h1 (lo := sd.off) (hi := sd.off + sd.size) rfl rfl ?_ hap
  intro q hq
  rw [hframe]
  try dsimp only
  have hov' : ov + (t.size : Nat) ≤ sd.size := hov
  have hA : ¬(sd.off + (oo : Int) ≤ q ∧ q < sd.off + (oo : Int) + ((1 : Nat) : Int)) := by
    intro ⟨h1, h2⟩
    rcases hq with hq | hq <;> omega
  have hB : ¬(sd.off + (ov : Int) ≤ q ∧ q < sd.off + (ov : Int) + ((t.size : Nat) : Int)) := by
    intro ⟨h1, h2⟩
    rcases hq with hq | hq <;> omega
  rw [if_neg hA, if_neg hB]


/-! ### The lift -/

theorem lift_ovfConst {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerOvfConst Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @constRight d a oa op m bits t valid vt vc ov oo head sd sa tt i1 i2 hm ha htwf htd hta hsd
      hsa hsize hlay hoff hpriv ht hi1 hi2 =>
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
    have hva : asNat (intBytes t.size x1) = .ok (bits % 2 ^ (8 * t.size)) := by
      rw [asNat_intBytes, hx1]
    -- the handler
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := ovfInsnOk_spec hi2
    rw [hmode, hρ] at hv
    rw [hbody] at htd hta
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -, hea, -⟩ := assign_binop_gen_inv hs h
    obtain ⟨pa, _, _, hpa, -⟩ := runOn_evalOperand_local hs ha hea
    have hra := hrel1.opnd hpa hsa hla
    have hpos : 0 < t.size := hwf a t valid hta
    obtain ⟨hov, hoo⟩ := ovfLayoutOk_spec hlay
    have hpos' : 0 < sd.size := Nat.lt_of_lt_of_le hpos (Nat.le_trans (Nat.le_add_left _ _) hov)
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    have hf4 := offOk_spec hft
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_ovfGen (ch := ch) hs hm htwf
      hpos htd hsize.1 hov hoo hpd hrel1.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv' hh hty
      ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2, hf4.1, hf4.2⟩
      (opndFacts_local hs ha hta hsize.2 hpa hrel1.frame.mem hra) (opndFacts_const hrd1 hva) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩
  | @constLeft d b ob op m bits t valid vt vc ov oo head sd sb tt i1 i2 hm hb htwf htd htb hsd
      hsb hsize hlay hoff hpriv ht hi1 hi2 =>
    obtain ⟨hft, -, htpv, hap⟩ := tempOk_spec ht
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    have hlb := hlo b (List.mem_append_right _ (operand_local_mem hb))
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
    have hva : asNat (intBytes t.size x1) = .ok (bits % 2 ^ (8 * t.size)) := by
      rw [asNat_intBytes, hx1]
    -- the handler
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := ovfInsnOk_spec hi2
    rw [hmode, hρ] at hv
    rw [hbody] at htd htb
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -, hea, heb, -⟩ := assign_binop_gen_inv hs h
    obtain ⟨-, hs3⟩ := runOn_evalOperand_const_scalar_int hea
    rw [hs3] at heb
    obtain ⟨pb0, _, _, hpb0, -⟩ := runOn_evalOperand_local hs hb heb
    have hrb := hrel1.opnd hpb0 hsb hlb
    have hpos : 0 < t.size := hwf b t valid htb
    obtain ⟨hov, hoo⟩ := ovfLayoutOk_spec hlay
    have hpos' : 0 < sd.size := Nat.lt_of_lt_of_le hpos (Nat.le_trans (Nat.le_add_left _ _) hov)
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    have hf4 := offOk_spec hft
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_ovfGen (ch := ch) hs hm htwf
      hpos htd hsize.1 hov hoo hpd hrel1.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv' hh hty
      ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf4.1, hf4.2, hf3.1, hf3.2⟩
      (opndFacts_const hrd1 hva) (opndFacts_local hs hb htb hsize.2 hpb0 hrel1.frame.mem hrb) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩

/-! ### The statement -/

theorem stmt_sim_ovfConst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerOvfConst Γ.toStmtCtx st (rangeInsns c.d r))
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
  exact lift_ovfConst M.stack M.body.symm hwf hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    hl2 hl1 hev

end Ryo.Proofs.Lower
