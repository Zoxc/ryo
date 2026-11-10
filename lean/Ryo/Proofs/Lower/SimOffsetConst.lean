/-
Ryo.Proofs.Lower.SimOffsetConst — the simulation of `LowerOffsetConst`
(`Check/Lower/OffsetConst.lean`, M5b): `_d = Offset(_a, const)` lowered to `imm t, bits` and
`ptr.index d, a, t, sz`.

- The `imm` (`step_immTemp`): R writes the constant's 8 bytes to the private temporary `t`
  (`FnRel.tempWrite`); L0 takes no step.
- The `ptr.index` (`sim_offsetConst`): `SimOffset.lean`'s `sim_offset` with the index read from
  `t` (`readFrame_after_write`, `asNat_intBytes`) instead of `_b`'s slot, and L0's index the
  constant (`runOn_evalOperand_const_scalar_int`, through `assign_binop_gen_inv`).
- `lift_offsetConst` puts them together (`liftOutN_two`), with `lift_offset`'s memory facts;
  `stmt_sim_offsetConst` is the statement's `StmtOut` (`StmtOutX`: `SimConstX.lean`).
-/
import Ryo.Proofs.Lower.SimOffset
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Check.Lower.OffsetConst

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `sim_offset` with a constant index, R's index bytes `bb` read from slot `t`. -/
theorem sim_offsetConst {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {oa : Operand} {bits : Nat} {pt : PtrType} {valid : ValidRange} {tb : IntType}
    {vb : ValidRange} {sz : Nat} {al : Align} {inh : Bool}
    (ha : oa.local? = some a)
    (hk : pt.metaKind = .none) (hpe : pt.pointee? = some ⟨.sized sz al, inh⟩)
    (htd : f.body.locals[d]? = some (.ptr pt valid))
    (hta : f.body.locals[a]? = some (.ptr pt valid)) (htb8 : tb.size = 8)
    {sd sa : LocalSlot} (hsd : sd.size = 8) (hsa : sa.size = 8)
    {pd pa : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa))
    (hmem : MemInj ι s.mem st.mem) (hra : LocalRel ι fp st s.mem sa pa true)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {t : Int} {bb : List AbstractByte} (hrfb : st.readFrame t 8 = .ok bb)
    (hvb : asNat bb = .ok (bits % 2 ^ (8 * tb.size)))
    {opc : Full.Opcode} {r : Option String} {ps : List String} {k : OperandKind}
    (hh : opc.handler? = some ⟨.ptr_index, ps, r⟩)
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"i", .slot⟩, ⟨"stride", k⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31 ∧
      -2 ^ 31 ≤ t ∧ t < 2 ^ 31)
    (hfk : Val.fits k (.imm sz) = true)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp .offset oa (.const (.scalar bits) (.int tb vb))))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off, .slot t, .imm sz] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv) ∧
      s'.stack = s.stack ∧
      ∃ bs0 bsd, s.mem.load pa 8 .one = .ok bs0 ∧ s.mem.store pd bsd .one = .ok s'.mem ∧
        (∀ b ∈ bsd, ∀ fr, b.provFrag = some fr →
          ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov) := by
  obtain ⟨pd', td, ra, s3, rb, s4, v, s5, mem', hpd', htd', hea, heb, hev, hst, rfl⟩ :=
    assign_binop_gen_inv hs h
  obtain ⟨pa', ta, va, hpa', hta', hla, hra', hs3⟩ := runOn_evalOperand_local hs ha hea
  subst ra s3
  obtain ⟨hrb, hs4⟩ := runOn_evalOperand_const_scalar_int heb
  subst rb s4
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = .ptr pt valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .ptr pt valid := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  -- the pointer's load
  obtain ⟨bs0, hlo0, hd0⟩ := typedLoad_inv (size?_ptr_thin hk) hla
  obtain ⟨tp, -, hdp, rfl⟩ := decode_ptr_thin_inv hk hd0
  -- the operation
  obtain ⟨hs1, h0, hlt, hv⟩ := offset_ok hpe hev
  subst s5
  have h0' : 0 ≤ (tp.addr : Int) + tb.ofBits (bits % 2 ^ (8 * tb.size)) * sz := h0
  have hlt' : (tp.addr : Int) + tb.ofBits (bits % 2 ^ (8 * tb.size)) * sz <
      (Target.ADDR_LIMIT : Int) := hlt
  have hv' : v = .ptr (⟨((tp.addr : Int) + tb.ofBits (bits % 2 ^ (8 * tb.size)) * sz).toNat,
      tp.prov⟩ : ThinPointer).widen := hv
  subst hv'
  -- the store
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have hbsd : bsd = encodePtr
      ⟨((tp.addr : Int) + tb.ofBits (bits % 2 ^ (8 * tb.size)) * sz).toNat, tp.prov⟩ := by
    simp [Spec.Ty.encode, hk, ThinPointer.widen] at hen
    first | exact hen.symm | exact hen
  subst hbsd
  -- R's pointer
  have hlo0' := hlo0
  rw [← hsa] at hlo0'
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hlo0'
  rw [hsa] at hrfa
  obtain ⟨p1, hdp1, hpi⟩ := decodePtr_inj hia hdp
  -- the address
  have hmod : tb.modulus = Target.ADDR_LIMIT := by
    unfold IntType.modulus IntType.bits
    rw [htb8] <;> rfl
  have hu : ((bits % 2 ^ (8 * tb.size) : Nat) : Int) % (Target.ADDR_LIMIT : Int) =
      tb.ofBits (bits % 2 ^ (8 * tb.size)) % (Target.ADDR_LIMIT : Int) := by
    rw [← hmod]
    exact (Ryo.Spec.Theorems.IntType.ofBits_emod tb _).symm
  have hq1 : p1.wrappingOffset (((bits % 2 ^ (8 * tb.size)) * sz % 2 ^ 64 : Nat) : Int) =
      ⟨((tp.addr : Int) + tb.ofBits (bits % 2 ^ (8 * tb.size)) * sz).toNat, p1.prov⟩ := by
    unfold ThinPointer.wrappingOffset
    rw [← hpi.1, wrap_addr hu h0' hlt']
  have hbs : BytesInj ι
      (encodePtr ⟨((tp.addr : Int) + tb.ofBits (bits % 2 ^ (8 * tb.size)) * sz).toNat, tp.prov⟩)
      (encodePtr (p1.wrappingOffset
        (((bits % 2 ^ (8 * tb.size)) * sz % 2 ^ 64 : Nat) : Int))) := by
    rw [hq1]
    exact encodePtr_inj' (And.intro rfl hpi.2)
  -- R's write
  have hlen : (encodePtr (p1.wrappingOffset
      (((bits % 2 ^ (8 * tb.size)) * sz % 2 ^ 64 : Nat) : Int))).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodePtr_length, hsd]
  have hpw : ∀ i < (encodePtr (p1.wrappingOffset
      (((bits % 2 ^ (8 * tb.size)) * sz % 2 ^ 64 : Nat) : Int))).length,
      st.escapedAt (sd.off + i) = none := by
    intro i hi
    rw [hlen] at hi
    exact hprivd i hi
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off (encodePtr (p1.wrappingOffset
      (((bits % 2 ^ (8 * tb.size)) * sz % 2 ^ 64 : Nat) : Int))) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_ptrIndex_fwd (ch := ch) hh ho hfits hfk hrfa hrfb hdp1 hvb hwr
  have hlen0 : (encodePtr
      ⟨((tp.addr : Int) + tb.ofBits (bits % 2 ^ (8 * tb.size)) * sz).toNat, tp.prov⟩).length =
      sd.size := by
    rw [Ryo.Spec.Theorems.encodePtr_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_, rfl, bs0, _, hlo0, hsto, offset_prov_sub hdp _⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen]; exact hap)

/-! ### The lift -/

theorem lift_offsetConst {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerOffsetConst Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @constIdx d a oa bits tb vb pt valid sz al inh sd sa t i1 i2 ha hk hpe0 htd hta htb8 hsd
      hsa hsize hoff hpriv ht hi1 hi2 =>
    obtain ⟨hft, hft2, htpv, hap⟩ := tempOk_spec ht
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
    have hlen1 : (intBytes 8 x1).length = 8 := Ryo.Spec.Theorems.encodeBits_length 8 x1
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame t 8 = .ok (intBytes 8 x1) := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    have hvb : asNat (intBytes 8 x1) = .ok (bits % 2 ^ (8 * tb.size)) := by
      rw [asNat_intBytes, hx1, htb8]
    -- the `ptr.index`
    obtain ⟨v, ps, r, hv, hh, hn, hk3, hops, hctl⟩ := ptrIndexInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨k, ho⟩ := operandsPtrIndex hn hk3
    have hfk : Val.fits k (.imm sz) = true :=
      fits_stride (hpl1.fits v hv) (by rw [ho, hops]; simp)
    rw [hbody] at htd hta
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -, hea, -⟩ := assign_binop_gen_inv hs h
    obtain ⟨pa, _, _, hpa, -⟩ := runOn_evalOperand_local hs ha hea
    have hra := hrel1.opnd hpa hsa hla
    have hpos : 0 < sd.size := by rw [hsize.1]; decide
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hf3 := offOk_spec hft
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs0, bsd, hlo0, hsto, hsub⟩ :=
      sim_offsetConst (ch := ch) hs ha hk hpe0 htd hta htb8 hsize.1 hsize.2 hpd hpa
        hrel1.frame.mem hra ad xd hp hι hx hl haddr hpaddr hsz hpv' hrd1 hvb hh ho
        ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩ hfk h
    -- `Hidden` and the bound: the stored provenance is the loaded bytes'
    have hhid := hrel1.hidden.load hlo0
    have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hhid _ (List.getElem_mem hj) fr0 hf0
    have hbd := hpb.load hlo0
    have hbd' : BytesBounded s.mem.allocs.size bsd := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hbd _ (List.getElem_mem hj) fr0 hf0
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    refine liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlo0 hsub⟩

/-! ### The statement -/

theorem stmt_sim_offsetConst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerOffsetConst Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h
    exact ⟨_, _, rfl⟩
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
  exact lift_offsetConst M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    hl2 hl1 hev

end Ryo.Proofs.Lower
