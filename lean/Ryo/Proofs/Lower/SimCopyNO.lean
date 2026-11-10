/-
Ryo.Proofs.Lower.SimCopyNO — the simulation of `LowerCopyNO` (`Check/Lower/CopyNO.lean`, M5b):
`CopyNonOverlapping(_ps, _pd, count)` with a constant count, lowered to a `load` of the
`n = count * size` bytes at `_ps`'s pointer into a temporary `t` and a `store` of them from `t`
at `_pd`'s pointer.

- L0 (`copyNO_inv`, `copyBytes_inv`): the operands are `_ps`'s and `_pd`'s pointers (decoded
  from their 8 bytes, as `Deref.lean`'s) and the count; `copyBytes` loads the `n` bytes `bs` at
  the source and stores them at the destination, both at the pointee's alignment (the
  non-overlap check is not needed here).
- R's `load` (`step_loadTemp`, as `sim_derefLoad` into a temporary): `_ps`'s slot holds a
  related pointer, the source is a mapped allocation (`deref_target_mapped`, from the deref
  invariant `hmap`), so R loads bytes `bs1` related to `bs` (`stLoad_inj`) and writes them to the
  private temporary (`writeFrame_private_ok`), which keeps `FnRel` (`FnRel.tempWrite`).
- R's `store` (`step_storeTemp`, as `sim_derefStore` with the bytes read back from the temporary,
  `readFrame_after_write`): the destination is mapped (`deref_store_target_mapped`), R's store
  through the image keeps `MemInj` (`store_inj`, with `LiveDisjoint`) and every local's
  `LocalRel`.
- The memory facts: the stored bytes are loaded ones (`Hidden.load`, `ProvBounded.load`,
  `memKept_load`), so `FnRel.after_store` and the invariants hold after (`lift_copyNO`).

`stmt_sim_copyNO` is the statement's `StmtOut` (the statement kills nothing:
`stmtOut_of_liftN_kill`).
-/
import Ryo.Proofs.Lower.SimDeref
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Proofs.Lower.SimEnum
import Ryo.Check.Lower.CopyNO

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### L0 -/

/-- `copyBytes` run to success: the loaded bytes stored, the stack unchanged.

Proof: `pointeeSize pt` is `pure es` (`hpt`), the alignment `al`; then each `if … then throwUb`
splits (`split`; the `throwUb` branch is an error: `runOn_bind_ok`, `runOn_throwUb`); `getMem`,
the `liftE` of the load (`runOn_liftE_ok`), and `memUpdate` of the store (`runOn_memUpdate`). -/
theorem copyBytes_inv {o : Spec.Oracle} {s s' : Spec.State} {src dst : Pointer} {pt : PtrType}
    {es : Nat} {al : Align} {inh : Bool} {count : Int}
    (hpt : pt.pointee? = some ⟨.sized es al, inh⟩)
    (h : runOn (copyBytes src dst pt count true) o s = (.ok (), s')) :
    ∃ bs, s.mem.load src.thin (count.toNat * es) al = .ok bs ∧
      s.mem.store dst.thin bs al = .ok s'.mem ∧ s'.stack = s.stack := by
  have hps : pointeeSize pt = pure es := by simp only [pointeeSize, hpt]
  unfold copyBytes at h
  rw [hps] at h
  simp only [hpt] at h
  obtain ⟨es', s2, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_pure] at h1
  obtain ⟨he, hs2⟩ := prod_ok_inj h1
  rw [← he, ← hs2] at h2
  try dsimp only at h2
  split at h2
  · obtain ⟨_, _, h3, -⟩ := runOn_bind_ok h2
    rw [runOn_throwUb] at h3
    exact (prod_err_ok h3).elim
  try dsimp only at h2
  split at h2
  · obtain ⟨_, _, h3, -⟩ := runOn_bind_ok h2
    rw [runOn_throwUb] at h3
    exact (prod_err_ok h3).elim
  try dsimp only at h2
  obtain ⟨m, s3, h3, h4⟩ := runOn_bind_ok h2
  rw [runOn_getMem0] at h3
  obtain ⟨hm, hs3⟩ := prod_ok_inj h3
  rw [← hm, ← hs3] at h4
  obtain ⟨bytes, s4, h5, h6⟩ := runOn_bind_ok h4
  obtain ⟨hlo, hs4⟩ := runOn_liftE_ok h5
  rw [hs4] at h6
  have fin : runOn (SemM.memUpdate (fun m => m.store dst.thin bytes al)) o s = (.ok (), s') →
      ∃ bs, s.mem.load src.thin (count.toNat * es) al = .ok bs ∧
        s.mem.store dst.thin bs al = .ok s'.mem ∧ s'.stack = s.stack := by
    intro h7
    rw [runOn_memUpdate] at h7
    split at h7
    next m' hst =>
      obtain ⟨-, rfl⟩ := prod_ok_inj h7
      exact ⟨bytes, hlo, hst, rfl⟩
    next => exact (prod_err_ok h7).elim
  try dsimp only at h6
  split at h6
  · split at h6
    · obtain ⟨_, _, h7, -⟩ := runOn_bind_ok h6
      rw [runOn_throwUb] at h7
      exact (prod_err_ok h7).elim
    · exact fin h6
  · exact fin h6

/-- `CopyNonOverlapping(_ps, _pd, const)` run to success, in memory terms: the pointers read
from `_ps`'s and `_pd`'s 8 bytes, the count's bytes `n` loaded at the source and stored at the
destination.

Proof: unfold `evalStatement`; the three operands by `runOn_evalOperand_local` (with
`typedLoad_inv (size?_ptr_thin hk)` and `decode_ptr_thin_inv hk` for the pointers) and
`runOn_evalOperand_const_scalar_int`; the operand match picks `copyBytes`, `copyBytes_inv`. -/
theorem copyNO_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {os od : Operand} {ps pd : Local}
    {bits : Nat} {ct : IntType} {cvalid : ValidRange} {pt pt' : PtrType} {v v' : ValidRange}
    {es : Nat} {al : Align} {inh : Bool}
    (hos : os.local? = some ps) (hod : od.local? = some pd)
    (hts : f.body.locals[ps]? = some (.ptr pt v)) (hks : pt.metaKind = .none)
    (htd : f.body.locals[pd]? = some (.ptr pt' v')) (hkd : pt'.metaKind = .none)
    (hpt : pt.pointee? = some ⟨.sized es al, inh⟩)
    (h : runOn (evalStatement (.copyNonOverlapping os od (.const (.scalar bits) (.int ct cvalid))))
      o s = (.ok (), s')) :
    ∃ pps ppd bps bpd qs qd bs, f.locals[ps]? = some (some pps) ∧
      f.locals[pd]? = some (some ppd) ∧
      s.mem.load pps 8 .one = .ok bps ∧ decodePtr bps = some qs ∧
      s.mem.load ppd 8 .one = .ok bpd ∧ decodePtr bpd = some qd ∧
      s.mem.load qs ((ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es) al = .ok bs ∧
      s.mem.store qd bs al = .ok s'.mem ∧ s'.stack = s.stack := by
  simp only [evalStatement] at h
  obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pps, ty, vs, hpps, hty, hls, hx, hs2⟩ := runOn_evalOperand_local hs hos h1
  subst x s2
  rw [hts] at hty
  obtain rfl := Option.some.inj hty
  obtain ⟨bps, hlps, hdps⟩ := typedLoad_inv (size?_ptr_thin hks) hls
  obtain ⟨qs, -, hqs, rfl⟩ := decode_ptr_thin_inv hks hdps
  try dsimp only at h2
  obtain ⟨y, s3, h3, h4⟩ := runOn_bind_ok h2
  obtain ⟨ppd, ty', vd, hppd, hty', hld, hy, hs3⟩ := runOn_evalOperand_local hs hod h3
  subst y s3
  rw [htd] at hty'
  obtain rfl := Option.some.inj hty'
  obtain ⟨bpd, hlpd, hdpd⟩ := typedLoad_inv (size?_ptr_thin hkd) hld
  obtain ⟨qd, -, hqd, rfl⟩ := decode_ptr_thin_inv hkd hdpd
  try dsimp only at h4
  obtain ⟨z, s4, h5, h6⟩ := runOn_bind_ok h4
  obtain ⟨hz, hs4⟩ := runOn_evalOperand_const_scalar_int h5
  subst z s4
  try dsimp only at h6
  obtain ⟨bs, hlo, hsto, hstk⟩ := copyBytes_inv hpt h6
  exact ⟨pps, ppd, bps, bpd, qs, qd, bs, hpps, hppd, hlps, hqs, hlpd, hqd, hlo, hsto, hstk⟩

/-! ### R -/

/-- The `load` of `n` bytes at `_ps`'s pointer into the private temporary `t` (as
`sim_derefLoad`): R loads bytes related to L0's and writes them to `t`, memory unchanged. -/
theorem step_loadTemp {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {m0 : Memory} {i : R.Insn} (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) {n : Nat} {t : Int} {sps : LocalSlot}
    (hli : loadInsnOk Γ i n t sps.off 0 = true) (hft : offOk t = true)
    (hfp : offOk sps.off = true) (hsps : sps.size = 8)
    {pps qs : ThinPointer} {bps bs : List AbstractByte} {al : Align}
    (hmem : MemInj ι m0 s1.st.mem) (hrp : LocalRel ι s1.fp s1.st m0 sps pps true)
    (hlp : m0.load pps 8 .one = .ok bps) (hq : decodePtr bps = some qs)
    (hmq : ∀ a, qs.prov = some a → ι a ≠ none) (hn : n ≠ 0)
    (hlo : m0.load qs n al = .ok bs)
    (hpv : ∀ k < n, s1.st.escapedAt (t + k) = none) :
    ∃ bs1 st1, BytesInj ι bs bs1 ∧ bs1.length = n ∧
      R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st1 }) ∧
      s1.st.writeFrame t bs1 = .ok st1 ∧ st1.mem = s1.st.mem := by
  obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := loadInsnOk_spec hli
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hmem hrp
    (show m0.load pps sps.size .one = .ok bps by rw [hsps]; exact hlp)
  rw [hsps] at hrfp
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  have hlim : qs.addr + 0 < Target.ADDR_LIMIT := decodePtr_addr_lt hq (load_length hlp)
  have hwo : (q1.wrappingOffset ((0 : Nat) : Int)).addr = qs.addr + 0 :=
    wrappingOffset_addr hpq.1 hlim
  have hpi : PtrInj ι ⟨qs.addr + 0, qs.prov⟩ (q1.wrappingOffset ((0 : Nat) : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  have hlo' : m0.load ⟨qs.addr + 0, qs.prov⟩ n al = .ok bs := hlo
  obtain ⟨bs1, hl1, hia⟩ := stLoad_inj hmem hpi hn hmq hlo'
  have hlen : bs1.length = n := (BytesInj.length hia).symm.trans (load_length hlo)
  obtain ⟨st1, hw, hmem1⟩ := writeFrame_private_ok (st := s1.st) (t := t) (bs := bs1)
    (fun k hk => hpv k (by omega))
  have hf1 := offOk_spec hft
  have hf2 := offOk_spec hfp
  have hop := opSem_load_fwd (ch := ch) hh hty' ho
    ⟨hf1.1, hf1.2, hf2.1, hf2.2, by omega, by omega⟩ hrfp hq1 hl1 hlen hw
  refine ⟨bs1, st1, hia, hlen, step_of_view hi hsc hpe hpl hv hctl ?_, hw, hmem1⟩
  rw [hops]
  exact hop

/-- The `store` of the temporary's `n` bytes at `_pd`'s pointer (as `sim_derefStore`, the bytes
read from the frame): the store succeeds, keeping `MemInj` and every local's `LocalRel`. -/
theorem step_storeTemp {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {m0 m0' : Memory} {i : R.Insn} (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) {n : Nat} {t : Int} {spd : LocalSlot}
    (hsi : storeInsnOk Γ i n spd.off 0 t = true) (hft : offOk t = true)
    (hfp : offOk spd.off = true) (hspd : spd.size = 8)
    {ppd qd : ThinPointer} {bpd bs bs1 : List AbstractByte} {al : Align}
    (hmem : MemInj ι m0 s1.st.mem) (hrp : LocalRel ι s1.fp s1.st m0 spd ppd true)
    (hlp : m0.load ppd 8 .one = .ok bpd) (hq : decodePtr bpd = some qd)
    {a0 b0 : AllocId} (hqa : qd.prov = some a0) (hb0 : ι a0 = some b0)
    (hrd : s1.st.readFrame t n = .ok bs1) (hbs : BytesInj ι bs bs1) (hlen : bs.length = n)
    (hn : n ≠ 0) (hsto : m0.store qd bs al = .ok m0') (hld : LiveDisjoint m0) :
    ∃ mem', R.step c s1 ch =
        .ok (.step { s1 with pc := s1.pc + 1, st := { s1.st with mem := mem' } }) ∧
      MemInj ι m0' mem' ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st m0 slot p lv →
        LocalRel ι s1.fp { s1.st with mem := mem' } m0' slot p lv := by
  obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := storeInsnOk_spec hsi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hmem hrp
    (show m0.load ppd spd.size .one = .ok bpd by rw [hspd]; exact hlp)
  rw [hspd] at hrfp
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  have hlenba : bs1.length = bs.length := (BytesInj.length hbs).symm
  have hN : bs.length ≠ 0 := by omega
  have hlim : qd.addr + 0 < Target.ADDR_LIMIT := decodePtr_addr_lt hq (load_length hlp)
  have hwo : (q1.wrappingOffset ((0 : Nat) : Int)).addr = qd.addr := by
    have := wrappingOffset_addr hpq.1 hlim
    simpa using this
  have hpi : PtrInj ι qd (q1.wrappingOffset ((0 : Nat) : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  -- the stored-to allocation
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
    ⟨_, hl0, -⟩ | ⟨id, hid, _, _, hprov, hlv, h1, h2, -, -⟩
  · exact absurd hl0 hN
  have hia0 : id = a0 := Option.some.inj (hprov.symm.trans hqa)
  have hbid : ι id = some b0 := by rw [hia0]; exact hb0
  -- R's store resolves to `b0`
  have hc := (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok (mem := m0)
    (p := qd) (len := bs1.length) (r := some (id, qd.addr - m0.allocs[id].addr))).mpr
    (.inr ⟨id, hid, by omega, hprov, hlv, h1, by rw [hlenba]; exact h2, rfl⟩)
  have hres := resolve_inj_of_checkPtr (st := s1.st) hmem hpi hprov hbid (by omega) hc
  have hal : Align.one.isAligned qd.addr = true := by
    simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]
  -- the other L0 allocations in `b0` are apart from the stored range (`LiveDisjoint`)
  have hdisj : ∀ a' x', m0.get? a' = some x' → x'.live = true → ι a' = some b0 → a' ≠ a0 →
      x'.size = 0 ∨ x'.addr + x'.size ≤ qd.addr ∨ qd.addr + bs.length ≤ x'.addr := by
    intro a' x' hx' hl' _ hne
    simp only [Allocation.size]
    by_cases g0 : x'.data.size = 0
    · exact .inl g0
    by_cases g1 : x'.addr + x'.data.size ≤ qd.addr
    · exact .inr (.inl g1)
    by_cases g2 : qd.addr + bs.length ≤ x'.addr
    · exact .inr (.inr g2)
    exfalso
    apply hne
    rw [← hia0]
    rcases Nat.le_total x'.addr qd.addr with hle' | hle'
    · exact hld a' id x' m0.allocs[id] qd.addr hx' (get?_of_lt hid) hl' hlv hle'
        (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)
    · exact hld a' id x' m0.allocs[id] x'.addr hx' (get?_of_lt hid) hl' hlv (Nat.le_refl _)
        (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)
  obtain ⟨m1', hst1, hmi⟩ := store_inj (p := qd) hmem hqa hb0 hbs hal hsto hdisj
  have hPeq : ({ q1.wrappingOffset ((0 : Nat) : Int) with prov := some b0 } : ThinPointer) =
      { qd with prov := some b0 } := by
    show (⟨(q1.wrappingOffset ((0 : Nat) : Int)).addr, some b0⟩ : ThinPointer) =
      ⟨qd.addr, some b0⟩
    rw [hwo]
  have hRst : s1.st.store s1.st.mem (q1.wrappingOffset ((0 : Nat) : Int)) bs1 = .ok m1' := by
    unfold OpSem.State.store
    rw [Ryo.Proofs.Inline.liftOutcome_ok, hres, hPeq]
    exact hst1
  have hf1 := offOk_spec hfp
  have hf2 := offOk_spec hft
  have hrd' : s1.st.readFrame t n = .ok bs1 := hrd
  have hop := opSem_store_fwd (ch := ch) hh hty' ho
    ⟨hf1.1, hf1.2, by omega, by omega, hf2.1, hf2.2⟩ hrfp hq1 hrd' hRst
  refine ⟨m1', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hmi, ?_⟩
  intro slot p lv hr
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    have hne : qd.prov ≠ some a := by
      rw [hqa]
      intro he
      have e : a0 = a := Option.some.inj he
      rw [e, hι] at hb0
      cases hb0
    have hx' : m0'.get? a = some x := by
      rw [get?_store_other hsto (.inl hne)]
      exact hx
    exact .priv a x hp hι hx' hlive haddr hpaddr hsize hpriv hbytes
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    obtain ⟨x', hx', ea, el, es⟩ := store_get?_bwd hsto hx
    obtain ⟨y', hy', eya, eyl, eys⟩ := store_get?_bwd hst1 hy
    exact .esc a x' e y' hp hι hx' (el.trans hlive) (by rw [ea]; exact haddr)
      (by rw [ea]; exact hpaddr) (by rw [es]; exact hsize) hin hy' (eyl.trans hylive)
      (by rw [eya]; exact hyaddr) (by rw [eys]; exact hysize)

/-! ### The lift -/

/-- `one`'s lift over its two instructions (see the module comment). -/
theorem lift_copyNO {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ) {st : Statement} {is : List R.Insn}
    (hlow : LowerCopyNO Γ st is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ stmtReads st, live l = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement st) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @one os od ps pd bits ct cvalid pt pt' v v' es al inh sps spd iL iS t n hos hod hts hks htd
      hkd hpt hn hpos hsps hspd hsz hoff ht hiL hiS =>
    subst hn
    obtain ⟨hft, hft2, htpv, hap⟩ := tempOk_spec ht
    have hc0 : c.d.insns[s1.pc]? = some iL := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some iS := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ iL := hpl iL (by simp)
    have hpl1 : PlainView c.mode c.ρ iS := hpl iS (by simp)
    -- L0
    rw [hbody] at hts htd
    obtain ⟨pps, ppd, bps, bpd, qs, qd, bs, hpps, hppd, hlps, hqs, hlpd, hqd, hlo0, hsto,
      hstk⟩ := copyNO_inv hs hos hod hts hks htd hkd hpt h
    have hlen0 : bs.length = (ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es :=
      load_length hlo0
    have hn0 : (ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es ≠ 0 := by omega
    -- `_ps` and `_pd` are read, so live
    have hlps' : live ps = true := hlo ps
      (List.mem_append_left _ (List.mem_append_left _ (operand_local_mem hos)))
    have hlpd' : live pd = true := hlo pd
      (List.mem_append_left _ (List.mem_append_right _ (operand_local_mem hod)))
    -- the targets are mapped
    obtain ⟨a1, b1, hqa1, hb1⟩ := deref_target_mapped (off := 0) hmap hlps hqs hn0 hlo0
    have hmq : ∀ a, qs.prov = some a → ι a ≠ none := by
      intro a ha'
      have e : a = a1 := Option.some.inj (ha'.symm.trans hqa1)
      rw [e, hb1]
      simp
    have hne : bs ≠ [] := by
      intro he
      rw [he, List.length_nil] at hlen0
      omega
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_store_target_mapped (off := 0) hmap hlpd hqd hne hsto
    -- R: the load into the temporary
    have hpv := temp_private hrel htpv
    have hrps := hrel.opnd hpps hsps hlps'
    obtain ⟨bs1, st1, hbs, hlen1, hstep1, hw1, hmem1⟩ :=
      step_loadTemp (ch := ch) hmode hρ hc0 hsc0 hpe hpl0 hiL hft hoff.1 hsz.1
        hrel.frame.mem hrps hlps hqs hmq hn0 hlo0 hpv
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l sl hsl => by rw [hlen1]; exact hap l sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame t ((ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es) =
        .ok bs1 := by
      have := readFrame_after_write hw1 (fun k hk => hpv k (by omega))
      rwa [hlen1] at this
    -- R: the store from the temporary
    have hrpd := hrel1.opnd hppd hspd hlpd'
    obtain ⟨mem', hstep2, hmi', hloc⟩ :=
      step_storeTemp (s1 := { s1 with pc := s1.pc + 1, st := st1 }) (ch := ch) hmode hρ hc1
        hsc1 hpe hpl1 hiS hft hoff.2 hsz.2 hrel1.frame.mem hrpd hlpd hqd hqa hb0 hrd1 hbs hlen0
        hn0 hsto hld
    -- the memory facts: the stored bytes are loaded ones
    have hsub : ∀ b ∈ bs, ∀ fr, b.provFrag = some fr →
        ∃ j, ∃ hj : j < bs.length, ∃ fr0, bs[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hb
      exact ⟨j, hj, fr, hfr, rfl⟩
    have hhid := hrel.hidden.store_hidden hsto (hrel.hidden.load hlo0)
    refine liftOutN_two hstep1 ⟨{ st1 with mem := mem' }, hstep2, hstk,
      hrel1.after_store hmi' hloc hhid hlive', hpb.store hsto (hpb.load hlo0),
      Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlo0 hsub⟩

/-- `CopyNonOverlapping`'s `StmtOut` (it kills nothing: `stmtOut_of_liftN_kill`). -/
theorem stmt_sim_copyNO {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerCopyNO Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨os, od, oc, rfl⟩ : ∃ os od oc, st = .copyNonOverlapping os od oc := by
    generalize rangeInsns c.d r = is at h
    cases h
    exact ⟨_, _, _, rfl⟩
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
  refine stmtOut_of_liftN_kill (k := (rangeInsns c.d r).length) M.stack hfn.storage M.hbd hst
    rfl M.sl M.fresh M.dinv (by rw [hpc0, hlen]; omega) ?_
  exact lift_copyNO M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    M.dinv.1 M.dinv.2 hlv2 (fun l hl => hlv1 l hl (by intro e; cases e)) hev

end Ryo.Proofs.Lower
