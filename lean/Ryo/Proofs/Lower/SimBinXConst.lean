/-
Ryo.Proofs.Lower.SimBinXConst — the simulation of `LowerBinXConst`
(`Check/Lower/BinXConst.lean`, M5b): `_d = op(const, _b)` lowered to `imm t, bits` and the `bin`
handler on `d, t, b`.

- The `imm` (`step_immTemp`): R writes the constant's bytes to the private temporary `t`
  (`FnRel.tempWrite`); L0 takes no step.
- The handler (`sim_binXConst`): `SimBinX.lean`'s `sim_binX` with the left operand read back
  from `t` (`readFrame_after_write`, `asNat_intBytes`) and L0's left operand the constant
  (`runOn_evalOperand_const_scalar_int`, through `assign_binop_gen_inv`); `binX_refines` covers
  every left value, the constant's bits included.
- `lift_binXConst` puts them together (`liftOutN_two`); `stmt_sim_binXConst` is the
  statement's `StmtOut` (`StmtOutX`: `SimConstX.lean`).
-/
import Ryo.Proofs.Lower.SimBinX
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Check.Lower.BinXConst

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `sim_binX` with a constant left operand, R's left bytes `ba` read from slot `tt`. -/
theorem sim_binXConst {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d b : Local} {ob : Operand} {op : BinOp} {m : String} {t : IntType}
    {valid vc : ValidRange} {bits : Nat} (hb : ob.local? = some b)
    (htd : f.body.locals[d]? = some (.int t valid)) (htb : f.body.locals[b]? = some (.int t valid))
    {sd sb : LocalSlot} (hsd : sd.size = t.size) (hsb : sb.size = t.size)
    {pd pb : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpb : f.locals[b]? = some (some pb))
    (hmem : MemInj ι s.mem st.mem) (hrb : LocalRel ι fp st s.mem sb pb true)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {tt : Int} {ba : List AbstractByte} (hrfa : st.readFrame tt t.size = .ok ba)
    (hva : asNat ba = .ok (bits % 2 ^ (8 * t.size)))
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String} {sg : Bool}
    (hkd : binKd kd = true) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ tt ∧ tt < 2 ^ 31 ∧
      -2 ^ 31 ≤ sb.off ∧ sb.off < 2 ^ 31)
    (har : ∀ u w, BinRefines op m sg t (t.ofBits u) (t.ofBits w) (BitVec.ofNat _ u)
      (BitVec.ofNat _ w))
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.const (.scalar bits) (.int t vc)) ob))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot tt, .slot sb.off] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv) ∧
      s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd', td, ra, s3, rb, s4, v, s5, mem', hpd', htd', hea, heb, hev, hst, rfl⟩ :=
    assign_binop_gen_inv hs h
  obtain ⟨hra, hs3⟩ := runOn_evalOperand_const_scalar_int hea
  subst ra s3
  obtain ⟨pb', tb, vb', hpb', htb', hlb, hrb', hs4⟩ := runOn_evalOperand_local hs hb heb
  subst rb s4
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e3 : pb' = pb := Option.some.inj (Option.some.inj (hpb'.symm.trans hpb))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  have e6 : tb = .int t valid := Option.some.inj (htb'.symm.trans htb)
  subst e1 e3 e4 e6
  obtain ⟨bsb, ub, hlob, hdb, -, rfl⟩ := typedLoad_int hlb
  change runOn (evalIntBinOp op t (t.ofBits (bits % 2 ^ (8 * t.size))) (t.ofBits ub)
    (.int t valid)) o s = _ at hev
  obtain ⟨hs1, iv, res, rfl, hres, hrn⟩ := (har (bits % 2 ^ (8 * t.size)) ub) _ o s s5 v hev
  subst s5
  rw [← hsb] at hlob
  obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hmem hrb hlob
  rw [hsb] at hrfb
  have hvb : asNat bb = .ok ub := by unfold asNat; rw [decodeBits_inj hib hdb]; rfl
  obtain ⟨st', hop, hmi, hrd, hoth, bs, hsto, hnp⟩ := sim_int_write hsd hmem ad xd hpdp hιd hxd
    hlived haddrd hpaddrd hsized hprivd hst hrn
    (fun st' hwr => opSem_binX_fwd (ch := ch) hkd hh hty ho hfits hrfa hrfb hva hvb hres hwr)
  exact ⟨st', hop, hmi, hrd, hoth, rfl, bs, hsto, hnp⟩

/-! ### The lift -/

theorem lift_binXConst {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerBinXConst Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @constLeft d b ob op m bits t valid vc sd sb tt i1 i2 hm hb hmod htd htb hsd hsb hsize hoff
      hpriv ht hi1 hi2 =>
    obtain ⟨hft, hft2, htpv, hap⟩ := tempOk_spec ht
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
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binXInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
    rw [hbody] at htd htb
    obtain ⟨pd, _, _, _, _, _, _, _, _, hpd, -, hea, heb, -⟩ := assign_binop_gen_inv hs h
    obtain ⟨-, hs3⟩ := runOn_evalOperand_const_scalar_int hea
    rw [hs3] at heb
    obtain ⟨pb0, _, _, hpb0, -⟩ := runOn_evalOperand_local hs hb heb
    have hrb := hrel1.opnd hpb0 hsb hlb
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv'⟩ :=
      hrel1.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hft
    have hf3 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binXConst (ch := ch) hs hb htd
      htb hsize.1 hsize.2 hpd hpb0 hrel1.frame.mem hrb ad xd hp hι hx hl haddr hpaddr hsz hpv'
      hrd1 hva hkd hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩
      (fun u w => binX_refines hm hsg hpos hmod u w) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    refine liftOutN_two hstep1 ⟨st', step_of_view hc1 hsc1 hpe hpl1 hv hctl
      (by rw [hops]; exact hop), hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_noprov hsto hnp) hesc hlive', hpb',
      hle⟩

/-! ### The statement -/

theorem stmt_sim_binXConst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerBinXConst Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h
    exact ⟨_, _, rfl⟩
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
  exact lift_binXConst M.stack M.body.symm hwf hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    hl2 hl1 hev

end Ryo.Proofs.Lower
