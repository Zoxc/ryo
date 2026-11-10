/-
Ryo.Proofs.Lower.SimBoolBin — the simulation of `LowerBoolBin` (`Check/Lower/BoolBin.lean`,
M5b): `&`, `|`, `^` on `bool`s, one `bin`/`bin_imm` instruction at 1 byte.

- L0: the operands load as `cmpValue .bool u` with `u < 2` (`SimCmp.typedLoad_cmp`; a constant by
  `runOn_evalOperand_const_cmp`), `evalBinOp`'s `bool` case computes the result, stored as its
  `boolByte` (`typedStore_bool`).
- The bytes (`bool_bin`): for `u, v ∈ {0, 1}` R's `intBin` on `BitVec.ofNat 8 u`,
  `BitVec.ofNat 8 v` gives a byte whose `intBytes 1` is L0's `boolByte` (12 cases, each
  computed).
- R: `opSem_bin_fwd`/`opSem_binImm_fwd` and the common tail `lift_boolOut`
  (`SimCmpConst.lean`: `FnRel.write_dst`, so `_d` may be escaped).
-/
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Proofs.Lower.SimBinImm
import Ryo.Check.Lower.BoolBin

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-- R's bitwise operator on two `bool` bytes is L0's, as bytes. -/
theorem bool_bin {op : BinOp} {m : String} (hop : boolBinOp op = true)
    (hm : binMethod op = some m) {ua ub : Nat} (hua : ua < 2) (hub : ub < 2) (sg : Bool)
    (ω : Spec.Oracle) (s : Spec.State) :
    ∃ (res : BitVec (8 * 1)) (b : Bool),
      intBin m sg (BitVec.ofNat (8 * 1) ua) (BitVec.ofNat (8 * 1) ub) = .ok res ∧
      runOn (evalBinOp op (cmpValue .bool ua, .bool) (cmpValue .bool ub, .bool) .bool) ω s =
        (.ok (.bool b), s) ∧
      intBytes 1 res.toNat = boolByte b := by
  obtain rfl | rfl : ua = 0 ∨ ua = 1 := by omega
  all_goals obtain rfl | rfl : ub = 0 ∨ ub = 1 := by omega
  all_goals cases op <;> simp [boolBinOp] at hop
  all_goals simp [binMethod] at hm
  all_goals subst hm
  all_goals exact ⟨_, _, rfl, rfl, by first | rfl | decide⟩

/-- `LowerBoolBin`'s lift, with `lift_cmpX`'s interface. -/
theorem lift_boolBin {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerBoolBin Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  have hbo : cmpOpnd Spec.Ty.bool = some (1, false) := rfl
  cases hlow with
  | @reg d a b oa ob op m sd sa sb i hop hm ha hb htd hta htb hsd hsa hsb hsize hoff hbi =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb, td, ta, tb, va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = .bool := Option.some.inj (hta'.symm.trans hta)
    have e6 : tb = .bool := Option.some.inj (htb'.symm.trans htb)
    subst e4 e5 e6
    obtain ⟨bsa, ua, hloa, hda, -, hua, rfl⟩ := typedLoad_cmp hbo hla0
    obtain ⟨bsb, ub, hlob, hdb, -, hub, rfl⟩ := typedLoad_cmp hbo hlb0
    obtain ⟨res, bres, hres, hev2, hbytes⟩ := bool_bin hop hm hua hub sg o s
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hstk : s'.stack = s.stack := by rw [hs']
    have hsto : s.mem.store pd (boolByte bres) .one = .ok s'.mem := by
      rw [hs']; exact typedStore_bool hst
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpbb hsb hlb
    rw [← hsize.2.1] at hloa
    rw [← hsize.2.2] at hlob
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hrel.frame.mem hrb hlob
    rw [hsize.2.1] at hrfa
    rw [hsize.2.2] at hrfb
    have hda' := decodeBits_inj hia hda
    have hdb' := decodeBits_inj hib hdb
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    have hvb : asNat bb = .ok ub := by unfold asNat; rw [hdb']; rfl
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    refine lift_boolOut hi hsc hpe hpl hv hctl hrel hpb hld hpd hsd hsize.1 hsto hstk hlive'
      fun st' hwr => ?_
    rw [hops]
    exact opSem_bin_fwd hkd hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩ hrfa hrfb hva hvb
      hres (by rw [hbytes]; exact hwr)
  | @imm d a oa op m bits sd sa i hop hm ha htd hta hsd hsa hsize hoff hbi =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    rw [eval_binopImm_norm ha] at h
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho'⟩ := operands3 hn hk
    have hops'' : v.ops = [.slot sd.off, .slot sa.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho', hops'']; simp)
    rw [hbody] at htd hta
    obtain ⟨pd, pa, td, ta, va, vc, w, hpd, hpa, htd', hta', hla0, hcst, s2, hev, mem', hst,
      hs'⟩ := assign_cmpImm_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = .bool := Option.some.inj (hta'.symm.trans hta)
    subst e4 e5
    obtain ⟨bsa, ua, hloa, hda, -, hua, rfl⟩ := typedLoad_cmp hbo hla0
    obtain ⟨hvc, hub, -⟩ := runOn_evalOperand_const_cmp hbo hcst
    obtain ⟨rfl, -⟩ := Prod.mk.inj hvc
    obtain ⟨res, bres, hres, hev2, hbytes⟩ := bool_bin hop hm hua hub sg o s
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hstk : s'.stack = s.stack := by rw [hs']
    have hsto : s.mem.store pd (boolByte bres) .one = .ok s'.mem := by
      rw [hs']; exact typedStore_bool hst
    have hra := hrel.opnd hpa hsa hla
    rw [← hsize.2] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsize.2] at hrfa
    have hda' := decodeBits_inj hia hda
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    have hxe : BitVec.ofNat (8 * 1) x = BitVec.ofNat (8 * 1) (bits % 2 ^ (8 * 1)) := by
      apply BitVec.eq_of_toNat_eq
      rw [BitVec.toNat_ofNat, BitVec.toNat_ofNat, Nat.mod_mod, hx]
    have hres' : intBin m sg (BitVec.ofNat (8 * 1) ua) (BitVec.ofNat (8 * 1) x) = .ok res := by
      rw [hxe]; exact hres
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    refine lift_boolOut hi hsc hpe hpl hv hctl hrel hpb hld hpd hsd hsize.1 hsto hstk hlive'
      fun st' hwr => ?_
    rw [hops'']
    exact opSem_binImm_fwd hkd hh hty' ho' ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk hrfa hva hres'
      (by rw [hbytes]; exact hwr)

/-- `LowerBoolBin` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_cmpX`). -/
theorem stmt_sim_boolBin {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerBoolBin Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
  have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
    (lift_boolBin M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2
      hl1 hev)

end Ryo.Proofs.Lower
