/-
Ryo.Proofs.Lower.SimCmpConst — the simulation of `LowerCmpConst` (`Check/Lower/CmpConst.lean`,
M5b): comparisons with a scalar constant on the left, its value materialized into a temporary.

R runs two instructions (`LiftOutN … 2`, `liftOutN_two`):
- `imm t, ba` (`step_immTemp`): a write of the constant's bytes to the temporary, which is
  private (no `Escape` covers it, so R's escapes don't: `FnRel.esc`) and apart from every local's
  slot; R's memory is unchanged (`writeFrame_private_ok`) and every local's relation survives
  (`LocalRel.writeFrame_apart_any`): `FnRel.tempWrite`. L0 takes no step for it.
- the comparison, read from the temporary (`readFrame_after_write`: the bytes just written,
  whose bits are the constant's modulo `2 ^ (8 * n)`, `decodeBits_encodeBits`), as
  `SimCmp.lift_cmp`'s cases: `cmp_imm` against the right constant, or `cmp` against `_b`'s
  slot. The result is stored into `_d` by `lift_boolOut` (the common tail: `FnRel.write_dst`,
  `boolByte`'s provenance-free bytes).

L0 (`assign_binop_gen_inv`): both operands evaluate (constants by `runOn_evalOperand_const_cmp`,
the local by `runOn_evalOperand_copy` and `typedLoad_cmp`) without changing the state, and
`cmp_eval` gives the result with the constant as its first operand (its type `tc` in the role
of the local's: `cmpConstTy_symm`).
-/
import Ryo.Proofs.Lower.SimCmp
import Ryo.Proofs.Lower.SimAgg
import Ryo.Check.Lower.CmpConst

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### R: a private temporary -/

/-- A frame write to bytes no escaped object covers succeeds and leaves memory unchanged. -/
theorem writeFrame_private_ok {st : OpSem.State} {t : Int} {bs : List AbstractByte}
    (hp : ∀ k < bs.length, st.escapedAt (t + k) = none) :
    ∃ st', st.writeFrame t bs = .ok st' ∧ st'.mem = st.mem := by
  unfold OpSem.State.writeFrame
  rw [writeEscaped_private' hp]
  exact ⟨_, rfl, rfl⟩

/-- After a write to private bytes, reading them back gives the bytes written. -/
theorem readFrame_after_write {st st' : OpSem.State} {t : Int} {bs : List AbstractByte}
    (hw : st.writeFrame t bs = .ok st') (hp : ∀ k < bs.length, st.escapedAt (t + k) = none) :
    st'.readFrame t bs.length = .ok bs := by
  obtain ⟨-, hesc, hfr⟩ := writeFrame_split hw
  have hea : ∀ o, st'.escapedAt o = st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc]
  have h := readFrame_eq_map (st := st') (off := t) (n := bs.length)
    (g := fun i => bs.getD i .uninit) (fun i hi => by
      unfold OpSem.State.byteAt
      rw [hea, hp i hi, hfr]
      have hpi : st.privateIn t bs.length (t + (i : Int)) = true := by
        simp only [OpSem.State.privateIn, hp i hi, Option.isNone_none, Bool.and_true,
          decide_eq_true_eq]
        omega
      rw [if_pos hpi]
      have e : (t + (i : Int) - t).toNat = i := by omega
      rw [e]
      rfl)
  rw [h]
  congr 1
  apply List.ext_getElem (by simp)
  intro j h1 h2
  simp [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h2]

/-- A write of a temporary apart from every local's slot, not touching memory, keeps `FnRel`
(at any `pc`). -/
theorem FnRel.tempWrite {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m s1) {t : Int}
    {bs : List AbstractByte} {st' : OpSem.State} (hw : s1.st.writeFrame t bs = .ok st')
    (hmem : st'.mem = s1.st.mem)
    (hap : ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
      t + bs.length ≤ sl.off ∨ sl.off + sl.size ≤ t) (pc : Nat) :
    FnRel Γ ι live f m { s1 with pc := pc, st := st' } := by
  obtain ⟨-, hesc, -⟩ := writeFrame_split hw
  refine ⟨⟨?_, ?_⟩, hrel.hidden, hrel.unaliased, hrel.provNe, hrel.apart, ?_⟩
  · show MemInj ι m st'.mem
    rw [hmem]
    exact hrel.frame.mem
  · intro l p hp hal
    obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
    exact ⟨slot, hsl, hr.writeFrame_apart_any hw (hap l slot hsl)⟩
  · intro o e he
    apply hrel.esc o e
    have he' : st'.escapedAt o = some e := he
    unfold OpSem.State.escapedAt at he' ⊢
    rw [hesc] at he'
    exact he'

/-- R's escapes are among the function's `Escape`s, so a never-escaped temporary is private. -/
theorem temp_private {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m s1) {t : Int} {n : Nat}
    (hpv : ∀ k < n, Γ.escaped (t + k) = false) :
    ∀ k < n, s1.st.escapedAt (t + k) = none := by
  intro k hk
  cases he : s1.st.escapedAt (t + k) with
  | none => rfl
  | some e =>
    have h1 := hrel.esc _ e he
    rw [hpv k hk] at h1
    cases h1

/-- R's escaped bytes all lie in local slots (`FnRelX.objs`; vacuous without scopes). -/
def EscInSlots (Γ : StmtCtx) (s1 : R.RState) : Prop :=
  ∀ o e, s1.st.escapedAt o = some e →
    ∃ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl ∧ sl.off ≤ o ∧ o < sl.off + sl.size

/-- Without `Escape`s (`LowersFn.noEsc`), nothing is escaped. -/
theorem escInSlots_of_noEsc {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m s1)
    (hno : ∀ o, Γ.escaped o = false) : EscInSlots Γ s1 := by
  intro o e he
  have h1 := hrel.esc _ e he
  rw [hno o] at h1
  cases h1

/-- A temporary apart from every local's slot is private when the escaped bytes all lie in
local slots. -/
theorem temp_private_apart {Γ : StmtCtx} {s1 : R.RState} (hesc : EscInSlots Γ s1) {t : Int}
    {n : Nat}
    (hap : ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
      t + n ≤ sl.off ∨ sl.off + sl.size ≤ t) :
    ∀ k < n, s1.st.escapedAt (t + k) = none := by
  intro k hk
  cases he : s1.st.escapedAt (t + k) with
  | none => rfl
  | some e =>
    obtain ⟨l, sl, hsl, h1, h2⟩ := hesc _ e he
    rcases hap l sl hsl with h | h <;> omega

/-- R's step of the `imm` that materializes the constant into the private temporary `t`. -/
theorem step_immTemp {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {i : R.Insn} (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) {n : Nat} {t : Int} {bits : Nat}
    (hii : immInsnOk Γ i n t bits = true) (hft : offOk t = true)
    (hpv : ∀ k < n, s1.st.escapedAt (t + k) = none) :
    ∃ x st1, x % 2 ^ (8 * n) = bits % 2 ^ (8 * n) ∧
      R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st1 }) ∧
      s1.st.writeFrame t (intBytes n x) = .ok st1 ∧ st1.mem = s1.st.mem := by
  obtain ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩ := immInsnOk_spec hii
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
  obtain ⟨k, ho⟩ := operands2 hn hk
  have hops'' : v.ops = [.slot t, .imm x] := hops'
  have hfk : Val.fits k (.imm x) = true :=
    fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
  have hlen : (intBytes n x).length = n := Ryo.Spec.Theorems.encodeBits_length n x
  obtain ⟨st1, hw, hmem⟩ := writeFrame_private_ok (st := s1.st) (t := t) (bs := intBytes n x)
    (fun k hk => hpv k (by omega))
  have hf := offOk_spec hft
  have hop := opSem_imm_fwd (ch := ch) hh hty' ho ⟨hf.1, hf.2⟩ hfk hw
  exact ⟨x, st1, hx, step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hw, hmem⟩

/-- The temporary's bits after the `imm`: the constant's, modulo `2 ^ (8 * n)`. -/
theorem asNat_intBytes (n x : Nat) : asNat (intBytes n x) = .ok (x % 2 ^ (8 * n)) := by
  unfold asNat intBytes
  rw [Ryo.Spec.Theorems.decodeBits_encodeBits]
  rfl

/-! ### The common tail -/

/-- A one-instruction comparison that writes `boolByte res` to `_d` (private or escaped), where
L0 stores the same byte, lifts (`lift_cmp`'s tail). -/
theorem lift_boolOut {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame} {i : R.Insn} {v : R.View}
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hv : R.view c.mode c.ρ i = some v)
    (hctl : v.ctl = some .next)
    (hrel : FnRel Γ ι live f s.mem s1) (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    {d : Local} {pd : ThinPointer} {sd : LocalSlot} {res : Bool}
    (hpd : f.locals[d]? = some (some pd)) (hsd : Γ.slots[d]? = some sd) (hsize : sd.size = 1)
    (hsto : s.mem.store pd (boolByte res) .one = .ok s'.mem) (hstk : s'.stack = s.stack)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hop : ∀ st', s1.st.writeFrame sd.off (boolByte res) = .ok st' →
      opSem v.op v.ops s1.st ch = .ok (.next, st')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  have hpos : 0 < sd.size := by rw [hsize]; exact Nat.one_pos
  have hlen0 : (boolByte res).length = sd.size := by rw [boolByte_length, hsize]
  have hbs : BytesInj ι (boolByte res) (boolByte res) := by
    first
      | exact encodeBits_inj ι _ _
      | (unfold boolByte intBytes; exact encodeBits_inj ι _ _)
  obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hrel.write_dst hld hpd hsd hpos hbs hlen0 hsto
  have hnp : ∀ b ∈ boolByte res, b.provFrag = none := by
    first
      | exact encodeBits_noprov 1 _
      | (unfold boolByte intBytes; exact encodeBits_noprov 1 _)
  obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
  refine ⟨st', step_of_view hi hsc hpe hpl hv hctl (hop st' hwr), hstk, ?_, hpb', hle⟩
  exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive'

/-- A step followed by a one-step lift is a two-step `LiftOutN`. -/
theorem liftOutN_two {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {live' : Local → Bool} {f : Spec.Frame} {s s' : Spec.State} {s1 : R.RState}
    {st1 : OpSem.State}
    (h1 : R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st1 }))
    (hl : LiftOut Γ c ch ι live' f s s' { s1 with pc := s1.pc + 1, st := st1 }) :
    LiftOutN Γ c ch ι live' f s s' s1 2 := by
  obtain ⟨st', hstep, hstk, hrel, hpb, hle, hk⟩ := hl
  exact ⟨st', .cons h1 (.cons hstep (.refl _)), hstk, hrel, hpb, hle, hk⟩

/-! ### L0 -/

/-- An assignment of a binary operator on any two operands, run to success. -/
theorem assign_binop_gen_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {op : BinOp}
    {oa ob : Operand}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op oa ob))) o s = (.ok (), s')) :
    ∃ pd td ra s3 rb s4 v s5 mem', f.locals[d]? = some (some pd) ∧
      f.body.locals[d]? = some td ∧
      runOn (evalOperand oa) o s = (.ok ra, s3) ∧ runOn (evalOperand ob) o s3 = (.ok rb, s4) ∧
      runOn (evalBinOp op ra rb td) o s4 = (.ok v, s5) ∧
      typedStore s5.mem pd v td .one = .ok mem' ∧ s' = { s5 with mem := mem' } := by
  have e : evalStatement (.assign ⟨d, []⟩ (.binaryOp op oa ob)) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.binaryOp op oa ob) ty >>= fun v => placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.binaryOp op oa ob) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.binaryOp op oa ob) td =
      (evalOperand oa >>= fun l => evalOperand ob >>= fun r => evalBinOp op l r td) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨ra, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨rb, s4, h7, h8⟩ := runOn_bind_ok h6
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨pd, td, ra, s3, rb, s4, v, s2, mem', hld, htd, h5, h7, h8, hst, hs'⟩

theorem cmpConstTy_symm {ta tb : Spec.Ty} (h : cmpConstTy ta tb = true) :
    cmpConstTy tb ta = true := by
  rcases cmpConstTy_spec h with ⟨t, vc, valid, rfl, rfl⟩ | ⟨rfl, rfl⟩
  · simp [cmpConstTy]
  · rfl

/-- Types `cmpConstTy` relates have the same comparison shape and bit conditions. -/
theorem cmpConstTy_opnd {ta tb : Spec.Ty} (h : cmpConstTy ta tb = true) :
    cmpOpnd ta = cmpOpnd tb ∧ ∀ u, cmpBitsOk ta u ↔ cmpBitsOk tb u := by
  rcases cmpConstTy_spec h with ⟨t, vc, valid, rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact ⟨rfl, fun _ => Iff.rfl⟩
  · exact ⟨rfl, fun _ => Iff.rfl⟩

/-! ### The lift -/

/-- `LowerCmpConst`'s lift: the `imm` (`step_immTemp`, `FnRel.tempWrite`), then the comparison
(`lift_boolOut` with `opSem_cmpImm_fwd` or `opSem_cmp_fwd`, the temporary read back by
`readFrame_after_write`), `liftOutN_two`. -/
theorem lift_cmpConst {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerCmpConst Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hesc : EscInSlots Γ s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @constImm d op oc ba bb tc tc' n sg sd t i1 i2 ho htd hty hc hsd hsize hoff ht hi1 hi2 =>
    obtain ⟨hft, hft2, hap⟩ := tempApartC_spec ht
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    -- R: the temporary
    have hpv := temp_private_apart hesc hap
    obtain ⟨x1, st1, hx1, hstep1, hw1, hmem1⟩ :=
      step_immTemp (ch := ch) hmode hρ hc0 hsc0 hpe hpl0 hi1 hft hpv
    have hlen1 : (intBytes n x1).length = n := Ryo.Spec.Theorems.encodeBits_length n x1
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame t n = .ok (intBytes n x1) := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    -- L0
    rw [hbody] at htd
    obtain ⟨pd, td, ra, s3, rb, s4, w, s5, mem', hpd, htd', hea, heb, hev, hst, hs'⟩ :=
      assign_binop_gen_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    subst e4
    obtain ⟨hra, hua, hs3⟩ := runOn_evalOperand_const_cmp hty hea
    rw [hs3] at heb
    have hty' : cmpOpnd tc' = some (n, sg) := by rw [(cmpConstTy_opnd hc).1]; exact hty
    obtain ⟨hrb, hub, hs4⟩ := runOn_evalOperand_const_cmp hty' heb
    rw [hs4] at hev
    subst hra hrb
    have hub' : cmpBitsOk tc (bb % 2 ^ (8 * n)) := ((cmpConstTy_opnd hc).2 _).mp hub
    -- the comparison
    obtain ⟨v, tys, r, hv, hh, htyh, hn, hk, hops, hctl⟩ := cmpImmInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec htyh
    obtain ⟨x2, hops', hx2⟩ := immOpsOk_spec hops
    obtain ⟨k, ho'⟩ := operands3 hn hk
    have hops'' : v.ops = [.slot sd.off, .slot t, .imm x2] := hops'
    have hfk : Val.fits k (.imm x2) = true :=
      fits_last (hpl1.fits v hv) (by rw [ho', hops'']; simp)
    obtain ⟨res, hres, hev2⟩ := cmp_eval ho hty hc hsg hua hub' o s
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hstk : s'.stack = s.stack := by rw [hs']
    have hsto : s.mem.store pd (boolByte res) .one = .ok s'.mem := by
      rw [hs']; exact typedStore_bool hst
    have hva : asNat (intBytes n x1) = .ok (ba % 2 ^ (8 * n)) := by
      rw [asNat_intBytes, hx1]
    have hxe : BitVec.ofNat (8 * n) x2 = BitVec.ofNat (8 * n) (bb % 2 ^ (8 * n)) := by
      apply BitVec.eq_of_toNat_eq
      rw [BitVec.toNat_ofNat, BitVec.toNat_ofNat, Nat.mod_mod, hx2]
    have hres' : intCmp oc sgh (BitVec.ofNat (8 * n) (ba % 2 ^ (8 * n)))
        (BitVec.ofNat (8 * n) x2) = .ok res := by
      rw [hxe]; exact hres
    have hf1 := offOk_spec hoff
    have hft' := offOk_spec hft
    refine liftOutN_two hstep1 ?_
    refine lift_boolOut hc1 hsc1 hpe hpl1 hv hctl hrel1 hpb hld hpd hsd hsize hsto hstk hlive'
      fun st' hwr => ?_
    rw [hops'']
    exact opSem_cmpImm_fwd hh hps ho' ⟨hf1.1, hf1.2, hft'.1, hft'.2⟩ hfk hrd1 hva hres' hwr
  | @constReg d b ob op oc sw ba tc ty n sg sd sb t i1 i2 hf hb htd htb hty hc hsd hsb hsize
      hoff ht hi1 hi2 =>
    obtain ⟨hft, hft2, hap⟩ := tempApartC_spec ht
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    have hlb : live b = true := hlo b (by
      rcases local?_cases hb with rfl | rfl <;> simp [rvalueLocals, operandLocals, placeLocals])
    -- R: the temporary
    have hpv := temp_private_apart hesc hap
    obtain ⟨x1, st1, hx1, hstep1, hw1, hmem1⟩ :=
      step_immTemp (ch := ch) hmode hρ hc0 hsc0 hpe hpl0 hi1 hft hpv
    have hlen1 : (intBytes n x1).length = n := Ryo.Spec.Theorems.encodeBits_length n x1
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame t n = .ok (intBytes n x1) := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    -- L0
    rw [hbody] at htd htb
    obtain ⟨pd, td, ra, s3, rb, s4, w, s5, mem', hpd, htd', hea, heb, hev, hst, hs'⟩ :=
      assign_binop_gen_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    subst e4
    have htc : cmpOpnd tc = some (n, sg) := by rw [(cmpConstTy_opnd hc).1]; exact hty
    obtain ⟨hra, hua, hs3⟩ := runOn_evalOperand_const_cmp htc hea
    rw [hs3] at heb
    have heb' : runOn (evalOperand (.copy ⟨b, []⟩)) o s = (.ok rb, s4) := by
      rcases local?_cases hb with rfl | rfl
      · exact heb
      · rw [evalOperand_move] at heb; exact heb
    obtain ⟨pb, tb', vb, hpbb, htb', hlb0, hrb, hs4⟩ := runOn_evalOperand_copy hs heb'
    rw [hs4] at hev
    have e6 : ty = tb' := Option.some.inj (htb.symm.trans htb')
    subst e6
    subst hra hrb
    obtain ⟨bsb, ub, hlob, hdb, -, hub, rfl⟩ := typedLoad_cmp hty hlb0
    have hub' : cmpBitsOk tc ub := ((cmpConstTy_opnd hc).2 _).mpr hub
    -- the comparison
    obtain ⟨v, tys, r, hv, hh, htyh, ho, hops, hctl⟩ := cmpInsnOk_spec hi2
    rw [hmode, hρ] at hv
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec htyh
    obtain ⟨o', hop, hiff, hsw⟩ := cmpRegForm_spec hf
    have hsg' : (o' = "==" ∨ o' = "!=") ∨ sgh = sg := hsg.imp_left hiff.mp
    obtain ⟨res, hres, hev2⟩ := cmp_eval hop htc (cmpConstTy_symm hc) hsg' hua hub' o s
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hstk : s'.stack = s.stack := by rw [hs']
    have hsto : s.mem.store pd (boolByte res) .one = .ok s'.mem := by
      rw [hs']; exact typedStore_bool hst
    -- R's reads: the temporary and `_b` (whose relation the temporary's write kept)
    have hva : asNat (intBytes n x1) = .ok (ba % 2 ^ (8 * n)) := by
      rw [asNat_intBytes, hx1]
    have hrb := hrel1.opnd hpbb hsb hlb
    rw [← hsize.2] at hlob
    obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hrel1.frame.mem hrb hlob
    rw [hsize.2] at hrfb
    have hdb' := decodeBits_inj hib hdb
    have hvb : asNat bb = .ok ub := by unfold asNat; rw [hdb']; rfl
    have hf1 := offOk_spec hoff.1
    have hf3 := offOk_spec hoff.2
    have hft' := offOk_spec hft
    refine liftOutN_two hstep1 ?_
    refine lift_boolOut hc1 hsc1 hpe hpl1 hv hctl hrel1 hpb hld hpd hsd hsize.1 hsto hstk hlive'
      fun st' hwr => ?_
    rw [hops]
    cases sw
    · exact opSem_cmp_fwd hh hps ho ⟨hf1.1, hf1.2, hft'.1, hft'.2, hf3.1, hf3.2⟩ hrd1 hrfb hva hvb
        ((hsw sgh (BitVec.ofNat (8 * n) (ba % 2 ^ (8 * n))) (BitVec.ofNat (8 * n) ub)).trans
          hres) hwr
    · exact opSem_cmp_fwd hh hps ho ⟨hf1.1, hf1.2, hf3.1, hf3.2, hft'.1, hft'.2⟩ hrfb hrd1 hvb hva
        ((hsw sgh (BitVec.ofNat (8 * n) (ba % 2 ^ (8 * n))) (BitVec.ofNat (8 * n) ub)).trans
          hres) hwr

/-- `LowerCmpConst` in a scope-free function: `stmt_sim`'s case (as its `castMore` case, with
`LiveDisjoint` from `MatchAt.dinv`). -/
theorem stmt_sim_cmpConst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerCmpConst Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
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
  exact lift_cmpConst M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel
    (escInSlots_of_noEsc M.rel hfn.noEsc) M.pb M.dinv.2 hl2 hl1 hev

end Ryo.Proofs.Lower
