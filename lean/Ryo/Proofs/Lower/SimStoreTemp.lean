/-
Ryo.Proofs.Lower.SimStoreTemp — the simulation of `LowerStoreTemp` (`Check/Lower/StoreTemp.lean`,
M5b): an integer value computed into a temporary and stored through a thin pointer.

R runs two instructions (`liftOutN_two`):
- the computation into the private temporary `t` (`step_immTemp`; `bin`/`bin_imm` by
  `opSem_bin_fwd`/`opSem_binImm_fwd`), a frame write apart from every local's slot that keeps
  `FnRel` (`FnRel.tempWrite`); L0 takes no step for it;
- the store of `t`'s bytes through `_p` (`lift_storeTempStep`: `sim_derefStoreBytes`, which is
  `SimDeref.sim_derefStore` with R's stored bytes read from the temporary instead of a local,
  and `FnRel.after_store`).

L0 (`derefStoreRv_inv`): the place through the deref, then the rvalue, then the store at the
place's integer type, whose bytes are exactly the temporary's: for a constant
`encodeBits n bits` (`encodeBits_toBits_ofBits`, `encodeBits_mod`), for an operator
`encodeBits n res` with `res` R's result (`intBin_wrap`, `evalIntBinOp_wrap`). Those bytes carry
no provenance (`encodeBits_noprov`), so the invariants are those of a constant store.
-/
import Ryo.Proofs.Lower.SimDerefCast
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Proofs.Lower.SimBinImm
import Ryo.Check.Lower.StoreTemp

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### R: a store of a temporary through a pointer -/

/-- `SimDeref.sim_derefStore` with R's stored bytes `ba` read from frame slot `so` and given as
refining L0's. -/
theorem sim_derefStoreBytes {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {n off : Nat} (hpos : 0 < n)
    {sp : LocalSlot} {so : Int} (hsp : sp.size = 8)
    {pp q : ThinPointer} {bp bsd ba : List AbstractByte}
    (hlp : s.mem.load pp 8 .one = .ok bp) (hq : decodePtr bp = some q)
    {a0 b0 : AllocId} (hqa : q.prov = some a0) (hb0 : ι a0 = some b0)
    (hlim : q.addr + off < Target.ADDR_LIMIT)
    (hrfa : st.readFrame so n = .ok ba) (hbs : BytesInj ι bsd ba)
    (hlend : bsd.length = n)
    (hsto : s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem)
    (hld : LiveDisjoint s.mem)
    (hmem : MemInj ι s.mem st.mem) (hrp : LocalRel ι fp st s.mem sp pp true)
    -- the instruction
    {opc : Full.Opcode} {r : Option String} {tyN : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.store, [tyN], r⟩)
    (hty : OpSem.Ty.parse tyN = some (.int n sg))
    (ho : opc.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ sp.off ∧ sp.off < 2 ^ 31 ∧ -2 ^ 31 ≤ (off : Int) ∧ (off : Int) < 2 ^ 31 ∧
      -2 ^ 31 ≤ so ∧ so < 2 ^ 31)
    {ch : OpSem.Choice} :
    ∃ mem', opSem opc [.mem sp.off (off : Int), .slot so] st ch =
        .ok (.next, { st with mem := mem' }) ∧
      MemInj ι s'.mem mem' ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv →
        LocalRel ι fp { st with mem := mem' } s'.mem slot p lv := by
  -- R's pointer and stored bytes
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hmem hrp
    (show s.mem.load pp sp.size .one = .ok bp by rw [hsp]; exact hlp)
  rw [hsp] at hrfp
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  have hlenba : ba.length = bsd.length := (BytesInj.length hbs).symm
  have hN : bsd.length ≠ 0 := by omega
  have hP0 : (⟨q.addr + off, q.prov⟩ : ThinPointer).addr = q.addr + off := rfl
  have hwo : (q1.wrappingOffset (off : Int)).addr = q.addr + off :=
    wrappingOffset_addr hpq.1 hlim
  have hpi : PtrInj ι ⟨q.addr + off, q.prov⟩ (q1.wrappingOffset (off : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  -- the stored-to allocation
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
    ⟨_, hl0, -⟩ | ⟨id, hid, _, _, hprov, hlv, h1, h2, -, -⟩
  · exact absurd hl0 hN
  have hia0 : id = a0 := Option.some.inj (hprov.symm.trans hqa)
  have hbid : ι id = some b0 := by rw [hia0]; exact hb0
  -- R's store resolves to `b0`
  have hc := (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok (mem := s.mem)
    (p := ⟨q.addr + off, q.prov⟩) (len := ba.length)
    (r := some (id, (⟨q.addr + off, q.prov⟩ : ThinPointer).addr - s.mem.allocs[id].addr))).mpr
    (.inr ⟨id, hid, by omega, hprov, hlv, h1, by rw [hlenba]; exact h2, rfl⟩)
  have hres := resolve_inj_of_checkPtr (st := st) hmem hpi hprov hbid (by omega) hc
  have hal : Align.one.isAligned (⟨q.addr + off, q.prov⟩ : ThinPointer).addr = true := by
    simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]
  -- the other L0 allocations in `b0` are apart from the stored range (`LiveDisjoint`)
  have hdisj : ∀ a' x', s.mem.get? a' = some x' → x'.live = true → ι a' = some b0 → a' ≠ a0 →
      x'.size = 0 ∨ x'.addr + x'.size ≤ (⟨q.addr + off, q.prov⟩ : ThinPointer).addr ∨
      (⟨q.addr + off, q.prov⟩ : ThinPointer).addr + bsd.length ≤ x'.addr := by
    intro a' x' hx' hl' _ hne
    show x'.size = 0 ∨ x'.addr + x'.size ≤ q.addr + off ∨ q.addr + off + bsd.length ≤ x'.addr
    simp only [Allocation.size]
    by_cases g0 : x'.data.size = 0
    · exact .inl g0
    by_cases g1 : x'.addr + x'.data.size ≤ q.addr + off
    · exact .inr (.inl g1)
    by_cases g2 : q.addr + off + bsd.length ≤ x'.addr
    · exact .inr (.inr g2)
    exfalso
    apply hne
    rw [← hia0]
    rcases Nat.le_total x'.addr (q.addr + off) with hle' | hle'
    · exact hld a' id x' s.mem.allocs[id] (q.addr + off) hx' (get?_of_lt hid) hl' hlv hle'
        (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)
    · exact hld a' id x' s.mem.allocs[id] x'.addr hx' (get?_of_lt hid) hl' hlv (Nat.le_refl _)
        (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)
  obtain ⟨m1', hst1, hmi⟩ := store_inj (p := ⟨q.addr + off, q.prov⟩) hmem hqa hb0 hbs hal hsto
    hdisj
  have hPeq : ({ q1.wrappingOffset (off : Int) with prov := some b0 } : ThinPointer) =
      { (⟨q.addr + off, q.prov⟩ : ThinPointer) with prov := some b0 } := by
    show (⟨(q1.wrappingOffset (off : Int)).addr, some b0⟩ : ThinPointer) = ⟨q.addr + off, some b0⟩
    rw [hwo]
  have hRst : st.store st.mem (q1.wrappingOffset (off : Int)) ba = .ok m1' := by
    unfold OpSem.State.store
    rw [Ryo.Proofs.Inline.liftOutcome_ok, hres, hPeq]
    exact hst1
  have hop := opSem_store_fwd (ch := ch) hh hty ho hfits hrfp hq1 hrfa hRst
  refine ⟨m1', hop, hmi, ?_⟩
  intro slot p lv hr
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    -- `a` is unmapped, so it is not the stored-to allocation
    have hne : (⟨q.addr + off, q.prov⟩ : ThinPointer).prov ≠ some a := by
      show q.prov ≠ some a
      rw [hqa]
      intro he
      have e : a0 = a := Option.some.inj he
      rw [e, hι] at hb0
      cases hb0
    have hx' : s'.mem.get? a = some x := by
      rw [get?_store_other hsto (.inl hne)]
      exact hx
    exact .priv a x hp hι hx' hlive haddr hpaddr hsize hpriv hbytes
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    obtain ⟨x', hx', ea, el, es⟩ := store_get?_bwd hsto hx
    obtain ⟨y', hy', eya, eyl, eys⟩ := store_get?_bwd hst1 hy
    exact .esc a x' e y' hp hι hx' (el.trans hlive) (by rw [ea]; exact haddr)
      (by rw [ea]; exact hpaddr) (by rw [es]; exact hsize) hin hy' (eyl.trans hylive)
      (by rw [eya]; exact hyaddr) (by rw [eys]; exact hysize)



/-- The store step: `store [p + off], t` from a state where the temporary holds L0's stored
bytes `encodeBits n X`, lifting the deref store (`lift_derefStore`'s tail). -/
theorem lift_storeTempStep {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ) {i : R.Insn}
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    {p : Local} {pp q : ThinPointer} {sp : LocalSlot} {bp : List AbstractByte} {off n X : Nat}
    {tt : Int}
    (hpp : f.locals[p]? = some (some pp)) (hsp : Γ.slots[p]? = some sp) (hlp' : live p = true)
    (hspz : sp.size = 8) (hlp : s.mem.load pp 8 .one = .ok bp) (hq : decodePtr bp = some q)
    (hlim : q.addr + off < Target.ADDR_LIMIT) (hpos : 0 < n)
    (hsto : s.mem.store ⟨q.addr + off, q.prov⟩ (encodeBits n X) .one = .ok s'.mem)
    (hstk : s'.stack = s.stack)
    (hrft : s1.st.readFrame tt n = .ok (intBytes n X))
    (hii : storeInsnOk Γ i n sp.off off tt = true)
    (hfo : offOk sp.off = true ∧ offOk (off : Int) = true ∧ offOk tt = true)
    (hlive' : ∀ l, live' l = true → live l = true) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := storeInsnOk_spec hii
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  have hrp := hrel.opnd hpp hsp hlp'
  have hlenX : (encodeBits n X).length = n := Ryo.Spec.Theorems.encodeBits_length n X
  have hne : encodeBits n X ≠ [] := by
    intro he
    rw [he, List.length_nil] at hlenX
    omega
  obtain ⟨a0, b0, hqa, hb0⟩ := deref_store_target_mapped hmap hlp hq hne hsto
  have hf1 := offOk_spec hfo.1
  have hf2 := offOk_spec hfo.2.1
  have hf3 := offOk_spec hfo.2.2
  obtain ⟨mem', hop, hmi', hloc⟩ := sim_derefStoreBytes (ch := ch) hpos hspz hlp hq hqa hb0 hlim
    hrft (encodeBits_inj ι n X) hlenX hsto hld hrel.frame.mem hrp hh hty' ho
    ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩
  have hnp := encodeBits_noprov n X
  obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
  exact ⟨{ s1.st with mem := mem' },
    step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
    hrel.after_store hmi' hloc (hrel.hidden.store_noprov hsto hnp) hlive', hpb', hle⟩

/-! ### L0 -/

/-- An assignment to `(*_p).fields`, run to success: the place through the deref, the rvalue at
the place type, the store there. -/
theorem derefStoreRv_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p : Local} {pointee ty : Spec.Ty}
    {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off : Nat} {rv : Rvalue}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hpk : pt.metaKind = .none)
    (hpath : fieldPath pointee fields = some (off, ty))
    (h : runOn (evalStatement (.assign ⟨p, .deref pointee :: fields⟩ rv)) o s = (.ok (), s')) :
    ∃ pp bp q v s2 mem', f.locals[p]? = some (some pp) ∧ s.mem.load pp 8 .one = .ok bp ∧
      decodePtr bp = some q ∧ q.addr + off < Target.ADDR_LIMIT ∧
      runOn (evalRvalue rv ty) o s = (.ok v, s2) ∧
      typedStore s2.mem ⟨q.addr + off, q.prov⟩ v ty .one = .ok mem' ∧
      s' = { s2 with mem := mem' } := by
  have e : evalStatement (.assign ⟨p, .deref pointee :: fields⟩ rv) =
      (evalPlace ⟨p, .deref pointee :: fields⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue rv ty' >>= fun v => placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pp, bp, q, al, hpp, hlp, hq, hlim, rfl, hs1⟩ :=
    runOn_evalPlace_deref hs htp hpk hpath h1
  have h2' : runOn (evalRvalue rv ty >>= fun v =>
      placeStore ⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩ v ty) o s1 =
      (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨pp, bp, q, v, s2, mem', hpp, hlp, hq, hlim, h3, hst, hs'⟩

/-- A binary operator on two loaded integers of type `t`. -/
theorem evalBinOp_int {op : BinOp} {t : IntType} {x y : Int} {va vb : ValidRange}
    {dt : Spec.Ty} :
    evalBinOp op (.int x, .int t va) (.int y, .int t vb) dt = evalIntBinOp op t x y dt := rfl

/-! ### The lift -/

/-- `LowerStoreTemp`'s lift: the computation into the temporary, then `lift_storeTempStep`. -/
theorem lift_storeTemp {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {pl : MPlace} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerStoreTemp Γ (.assign pl rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ stmtReads (.assign pl rv), live l = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assign pl rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @const p pointee fields pt valid off t vp vc bits sp tt i1 i2 htp hpk hpath hn hw hsp hspz
      hoff ht hi1 hi2 =>
    obtain ⟨hft, hft2, htpv, hap⟩ := tempOk_spec ht
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    have hpos : 0 < t.size := movWidth_pos hw
    have hlp' : live p = true := hlo p (by
      show p ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ _
      simp [placeLocals])
    -- R: the temporary
    have hpv := temp_private hrel htpv
    obtain ⟨x, st1, hx, hstep1, hw1, hmem1⟩ :=
      step_immTemp (ch := ch) hmode hρ hc0 hsc0 hpe hpl0 hi1 hft hpv
    have hlen1 : (intBytes t.size x).length = t.size := Ryo.Spec.Theorems.encodeBits_length _ x
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame tt t.size = .ok (intBytes t.size x) := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    -- L0
    rw [hbody] at htp
    obtain ⟨pp, bp, q, v, s2, mem', hpp, hlp, hq, hlim, h3, hst, hs'⟩ :=
      derefStoreRv_inv hs htp hpk hpath h
    have e2 : evalRvalue (.use (.const (.scalar bits) (.int t vc))) (.int t vp) =
        (evalOperand (.const (.scalar bits) (.int t vc)) >>= fun r => pure r.1) := by
      first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
    rw [e2] at h3
    obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
    obtain ⟨hr, hs3⟩ := runOn_evalOperand_const_scalar_int h5
    subst hr
    obtain ⟨hv, hs2⟩ := runOn_pure_inv h6
    subst hv
    rw [hs2, hs3] at hst
    have hst' := typedStore_int hst
    have hbytes : encodeBits t.size (t.toBits (t.ofBits (bits % 2 ^ (8 * t.size)))) =
        encodeBits t.size x := by
      rw [encodeBits_toBits_ofBits, encodeBits_mod, ← encodeBits_mod t.size x, hx, encodeBits_mod]
    have hsto : s.mem.store ⟨q.addr + off, q.prov⟩ (encodeBits t.size x) .one = .ok s'.mem := by
      rw [hs', ← hbytes]; exact hst'
    have hstk : s'.stack = s.stack := by rw [hs', hs2, hs3]
    refine liftOutN_two hstep1 ?_
    exact lift_storeTempStep hmode hρ hc1 hsc1 hpe hpl1 hrel1 hpb hmap hld hpp hsp hlp' hspz hlp
      hq hlim hpos hsto hstk hrd1 hi2 ⟨hoff.1, hoff.2, hft⟩ hlive'
  | @bin p a b oa ob op m pointee fields pt valid off t vp va vb sp sa sb tt i1 i2 hm ha hb htp hpk
      hpath hta htb hn hw hsp hsa hsb hsize hoff ht hi1 hi2 =>
    obtain ⟨hft, hft2, htpv, hap⟩ := tempOk_spec ht
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    have hpos : 0 < t.size := movWidth_pos hw
    have hlp' : live p = true := hlo p (by
      show p ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ _
      simp [placeLocals])
    have hla : live a = true := hlo a (by
      show a ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.binaryOp op oa ob)
      exact List.mem_append_right _ (List.mem_append_left _ (operand_local_mem ha)))
    have hlb : live b = true := hlo b (by
      show b ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.binaryOp op oa ob)
      exact List.mem_append_right _ (List.mem_append_right _ (operand_local_mem hb)))
    -- L0
    rw [eval_binop_norm ha hb] at h
    rw [hbody] at htp hta htb
    obtain ⟨pp, bp, q, v, s2, mem', hpp, hlp, hq, hlim, h3, hst, hs'⟩ :=
      derefStoreRv_inv hs htp hpk hpath h
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
    obtain ⟨hv, hs2⟩ := prod_ok_inj h8
    subst hv
    -- R: the operands, the computation into the temporary
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpb' hsb hlb
    rw [← hsize.2.1] at hloa
    rw [← hsize.2.2] at hlob
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hrel.frame.mem hrb hlob
    rw [hsize.2.1] at hrfa
    rw [hsize.2.2] at hrfb
    have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
    have hvb : asNat bb = .ok ub := by unfold asNat; rw [decodeBits_inj hib hdb]; rfl
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binInsnOk_spec hi1
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨res, hres, hresv⟩ := intBin_wrap hm t sg ua ub
    have hpv := temp_private hrel htpv
    have hlen1 : (intBytes t.size res.toNat).length = t.size :=
      Ryo.Spec.Theorems.encodeBits_length _ _
    obtain ⟨st1, hw1, hmem1⟩ := writeFrame_private_ok (st := s1.st) (t := tt)
      (bs := intBytes t.size res.toNat) (fun k hk => hpv k (by omega))
    have hf0 := offOk_spec hft
    have hfa := offOk_spec hoff.2.2.1
    have hfb := offOk_spec hoff.2.2.2
    have hop := opSem_bin_fwd (ch := ch) hkd hh hty' ho ⟨hf0.1, hf0.2, hfa.1, hfa.2, hfb.1, hfb.2⟩
      hrfa hrfb hva hvb hres hw1
    have hstep1 := step_of_view hc0 hsc0 hpe hpl0 hv hctl (by rw [hops]; exact hop)
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame tt t.size = .ok (intBytes t.size res.toNat) := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    -- L0's stored bytes are the temporary's
    rw [← hs2] at hst
    have hst' := typedStore_int hst
    rw [← hresv] at hst'
    have hsto : s.mem.store ⟨q.addr + off, q.prov⟩ (encodeBits t.size res.toNat) .one =
        .ok s'.mem := by
      rw [hs', ← hs2]; exact hst'
    have hstk : s'.stack = s.stack := by rw [hs', ← hs2]
    refine liftOutN_two hstep1 ?_
    exact lift_storeTempStep hmode hρ hc1 hsc1 hpe hpl1 hrel1 hpb hmap hld hpp hsp hlp' hsize.1
      hlp hq hlim hpos hsto hstk hrd1 hi2 ⟨hoff.1, hoff.2.1, hft⟩ hlive'
  | @binImm p a oa op m pointee fields pt valid off t vp va vc bits sp sa tt i1 i2 hm ha htp hpk
      hpath hta hn hw hsp hsa hsize hoff ht hi1 hi2 =>
    obtain ⟨hft, hft2, htpv, hap⟩ := tempOk_spec ht
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    have hpos : 0 < t.size := movWidth_pos hw
    have hlp' : live p = true := hlo p (by
      show p ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ _
      simp [placeLocals])
    have hla : live a = true := hlo a (by
      show a ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++
        rvalueLocals (.binaryOp op oa (.const (.scalar bits) (.int t vc)))
      exact List.mem_append_right _ (List.mem_append_left _ (operand_local_mem ha)))
    -- L0
    rw [eval_binopImm_norm ha] at h
    rw [hbody] at htp hta
    obtain ⟨pp, bp, q, v, s2, mem', hpp, hlp, hq, hlim, h3, hst, hs'⟩ :=
      derefStoreRv_inv hs htp hpk hpath h
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
    obtain ⟨hv, hs2⟩ := prod_ok_inj h8
    subst hv
    -- R: the operand, the computation into the temporary
    have hra := hrel.opnd hpa hsa hla
    rw [← hsize.2] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsize.2] at hrfa
    have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn', hk, hops, hctl⟩ := binImmInsnOk_spec hi1
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho'⟩ := operands3 hn' hk
    have hops'' : v.ops = [.slot tt, .slot sa.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl0.fits v hv) (by rw [ho', hops'']; simp)
    obtain ⟨res, hres, hresv⟩ := intBin_wrap hm t sg ua x
    have hpv := temp_private hrel htpv
    have hlen1 : (intBytes t.size res.toNat).length = t.size :=
      Ryo.Spec.Theorems.encodeBits_length _ _
    obtain ⟨st1, hw1, hmem1⟩ := writeFrame_private_ok (st := s1.st) (t := tt)
      (bs := intBytes t.size res.toNat) (fun k hk => hpv k (by omega))
    have hf0 := offOk_spec hft
    have hfa := offOk_spec hoff.2.2
    have hop := opSem_binImm_fwd (ch := ch) hkd hh hty' ho' ⟨hf0.1, hf0.2, hfa.1, hfa.2⟩ hfk
      hrfa hva hres hw1
    have hstep1 := step_of_view hc0 hsc0 hpe hpl0 hv hctl (by rw [hops'']; exact hop)
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame tt t.size = .ok (intBytes t.size res.toNat) := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    -- L0's stored bytes are the temporary's (the immediate denotes the constant)
    have hcong : t.ofBits x = t.ofBits (bits % 2 ^ (8 * t.size)) :=
      ofBits_congr t (by rw [Nat.mod_mod]; exact hx)
    rw [← hs2] at hst
    have hst' := typedStore_int hst
    rw [← hcong, ← hresv] at hst'
    have hsto : s.mem.store ⟨q.addr + off, q.prov⟩ (encodeBits t.size res.toNat) .one =
        .ok s'.mem := by
      rw [hs', ← hs2]; exact hst'
    have hstk : s'.stack = s.stack := by rw [hs', ← hs2]
    refine liftOutN_two hstep1 ?_
    exact lift_storeTempStep hmode hρ hc1 hsc1 hpe hpl1 hrel1 hpb hmap hld hpp hsp hlp' hsize.1
      hlp hq hlim hpos hsto hstk hrd1 hi2 ⟨hoff.1, hoff.2.1, hft⟩ hlive'

/-- `LowerStoreTemp` in a scope-free function: `stmt_sim`'s case (as its `deref` store case,
over two instructions). -/
theorem stmt_sim_storeTemp {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerStoreTemp Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨b, x, xs, rv, rfl⟩ : ∃ b x xs rv, st = .assign ⟨b, x :: xs⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h <;> exact ⟨_, _, _, _, rfl⟩
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
  obtain ⟨st', hsteps, hstk, hrel, hpb, hle, hk⟩ := lift_storeTemp (ch := ch) M.stack
    M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb M.dinv.1 M.dinv.2 hlv2
    (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
  refine ⟨_, f, hsteps, hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl,
    (by show s1.pc + (rangeInsns c.d r).length = r.2; rw [hpc0, hlen]; omega), hrel, ?_, hpb,
    ?_, M.dinv.of_memKept hk⟩
  · intro l p hp
    exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by intro e; cases e)
  · intro a ha
    exact M.fresh a (Nat.le_trans hle ha)

end Ryo.Proofs.Lower
