/-
Ryo.Proofs.Lower.SimDerefWide — the simulation of `LowerDerefWide` (`Check/Lower/DerefWide.lean`,
M5b): `SimDeref`'s `load`/`store` through a wide pointer local `_p` (16 bytes) into or from a
sized field of its pointee.

L0 (`derefLoadW_mem`, `derefStoreW_mem`): as `derefLoad_mem`/`derefStore_mem`, with
`runOn_evalPlace_derefWideF` (`SimRefDerefWide`) for the place: `_p`'s 16 bytes `bs` load, their
first 8 decode to the data pointer `q`, the place is `q + off`. R's `.mem` operand reads the
slot's first 8 bytes: `load_sub_of_load` (`SimWide`) gives L0's load of `bs.take 8` at `pp`,
`readLocal_sub_inj` R's related read at `sp.off`. `sim_derefLoadW`/`sim_derefStoreW` are
`sim_derefLoad`/`sim_derefStore` from that read (`hrfp`, `hbp`) instead of `_p`'s whole 8-byte
slot; the lifts are `lift_derefLoad`/`lift_derefStore` with them, the L0 facts about the
pointer bytes (`deref_target_mapped`, `Hidden`) taken at `bs.take 8`. `stmt_sim_derefWide` is
the scope-free case (as `stmt_sim_derefCast`).
-/
import Ryo.Proofs.Lower.SimRefDerefWide

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### L0 -/

/-- `derefLoad_mem` through a wide `_p` (`runOn_evalPlace_derefWideF`). -/
theorem derefLoadW_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p : Local} {pointee ty : Spec.Ty}
    {fe : ProjElem} {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off n : Nat}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (hpath : fieldPath pointee (fe :: fields) = some (off, ty))
    (htd : f.body.locals[d]? = some ty) (hn : ty.size? = some n)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.use (.copy ⟨p, .deref pointee :: fe :: fields⟩)))) o s = (.ok (), s')) :
    ∃ pd pp bs q bs0 v bsd, f.locals[d]? = some (some pd) ∧ f.locals[p]? = some (some pp) ∧
      s.mem.load pp 16 .one = .ok bs ∧ bs.length = 16 ∧ decodePtr (bs.take 8) = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.load ⟨q.addr + off, q.prov⟩ n .one = .ok bs0 ∧ ty.decode bs0 = some v ∧
      ty.encode v = some bsd ∧ s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  obtain ⟨pd, td, rv, s1, hpd, htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  have e : evalOperand (.copy ⟨p, .deref pointee :: fe :: fields⟩) =
      (evalPlace ⟨p, .deref pointee :: fe :: fields⟩ >>= fun x => match x with
        | (pl, ty) => placeLoad pl ty >>= fun v => pure (v, ty)) := rfl
  rw [e] at hev
  obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨pp, bs, q, al, hpp, hlp, hlen, hq, hlim, rfl, hs2⟩ :=
    runOn_evalPlace_derefWideF hs htp hk hpath h1
  have h2' : runOn (placeLoad ⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩ ty >>=
      fun v => pure (v, ty)) o s2 = (.ok rv, s1) := h2
  rw [hs2] at h2'
  obtain ⟨v, s3, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨hv, hs3⟩ := runOn_placeLoad_ok h3
  obtain ⟨hrv, hs1⟩ := prod_ok_inj h4
  have hs1' : s1 = s := hs1.symm.trans hs3
  have e4 : td = ty := Option.some.inj (htd'.symm.trans htd)
  subst e4
  obtain ⟨bs0, hlo, hd⟩ := typedLoad_inv hn hv
  rw [← hrv, hs1'] at hst
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  exact ⟨pd, pp, bs, q, bs0, v, bsd, hpd, hpp, hlp, hlen, hq, hlim, hlo, hd, hen, hsto,
    by rw [hs1']⟩

/-- `derefStore_mem` through a wide `_p` (`runOn_evalPlace_derefWideF`). -/
theorem derefStoreW_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p a : Local} {pointee ty : Spec.Ty}
    {fe : ProjElem} {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off n : Nat}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (hpath : fieldPath pointee (fe :: fields) = some (off, ty))
    (hta : f.body.locals[a]? = some ty) (hn : ty.size? = some n)
    (h : runOn (evalStatement (.assign ⟨p, .deref pointee :: fe :: fields⟩
      (.use (.copy ⟨a, []⟩)))) o s = (.ok (), s')) :
    ∃ pp pa bs q bsa v bsd, f.locals[p]? = some (some pp) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.load pp 16 .one = .ok bs ∧ bs.length = 16 ∧ decodePtr (bs.take 8) = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.load pa n .one = .ok bsa ∧ ty.decode bsa = some v ∧ ty.encode v = some bsd ∧
      s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  have e : evalStatement (.assign ⟨p, .deref pointee :: fe :: fields⟩ (.use (.copy ⟨a, []⟩))) =
      (evalPlace ⟨p, .deref pointee :: fe :: fields⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.use (.copy ⟨a, []⟩)) ty >>= fun v => placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pp, bs, q, al, hpp, hlp, hlen, hq, hlim, rfl, hs1⟩ :=
    runOn_evalPlace_derefWideF hs htp hk hpath h1
  have h2' : runOn (evalRvalue (.use (.copy ⟨a, []⟩)) ty >>= fun v =>
      placeStore ⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩ v ty) o s1 =
      (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.use (.copy ⟨a, []⟩)) ty =
      (evalOperand (.copy ⟨a, []⟩) >>= fun r => pure r.1) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨rr, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨hv, hs3⟩ := prod_ok_inj h6
  obtain ⟨pa, ta, w, hpa, hta', hlw, hrr, hs3'⟩ := runOn_evalOperand_copy hs h5
  subst hrr
  have e3 : ta = ty := Option.some.inj (hta'.symm.trans hta)
  subst e3
  obtain ⟨bsa, hla, hd⟩ := typedLoad_inv hn hlw
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  have hs2 : s2 = s := hs3.symm.trans hs3'
  rw [hs2, ← hv] at hst
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  subst hs'
  exact ⟨pp, pa, bs, q, bsa, w, bsd, hpp, hpa, hlp, hlen, hq, hlim, hla, hd, hen, hsto,
    by rw [hs2]⟩

/-- The data pointer's 8 bytes: L0's load of `bs.take 8` at `_p`'s pointer, and R's related
read of `_p`'s slot's first 8 bytes. -/
theorem widePtr_read {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory} {sp : LocalSlot}
    {pp : ThinPointer} {bs : List AbstractByte} (hm : MemInj ι m0 st.mem)
    (hrp : LocalRel ι fp st m0 sp pp true) (hsp : sp.size = 16)
    (hlp : m0.load pp 16 .one = .ok bs) :
    m0.load pp 8 .one = .ok (bs.take 8) ∧
      ∃ bp1, st.readFrame sp.off 8 = .ok bp1 ∧ BytesInj ι (bs.take 8) bp1 := by
  have hlp8 : m0.load ⟨pp.addr + 0, pp.prov⟩ 8 .one = .ok ((bs.drop 0).take 8) :=
    load_sub_of_load (j := 0) (k := 8) hlp (by omega) (by omega)
  rw [List.drop_zero] at hlp8
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_sub_inj hm hrp
    (show 0 + 8 ≤ sp.size by rw [hsp]; omega) hlp8
  have hrfp' : st.readFrame sp.off 8 = .ok bp1 := by simpa using hrfp
  refine ⟨?_, bp1, hrfp', hbp⟩
  simpa using hlp8

/-! ### R: the handlers -/

/-- `sim_derefLoad` from R's read of the pointer bytes (`hrfp`, `hbp`). Same proof. -/
theorem sim_derefLoadW {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {ty : Spec.Ty} {n off : Nat} (hwf : ty.wf = true) (hn : ty.size? = some n) (hpos : 0 < n)
    {sd sp : LocalSlot} (hsd : sd.size = n)
    {pd q : ThinPointer} {bp bp1 bs0 bsd : List AbstractByte} {v : Value}
    (hrfp : st.readFrame sp.off 8 = .ok bp1) (hbp : BytesInj ι bp bp1)
    (hq : decodePtr bp = some q)
    (hmq : ∀ a, q.prov = some a → ι a ≠ none) (hlim : q.addr + off < Target.ADDR_LIMIT)
    (hlo : s.mem.load ⟨q.addr + off, q.prov⟩ n .one = .ok bs0)
    (hdec : ty.decode bs0 = some v) (hen : ty.encode v = some bsd)
    (hmem : MemInj ι s.mem st.mem)
    (hW : DstWrite ι fp st s.mem s'.mem sd pd bsd)
    {opc : Full.Opcode} {r : Option String} {tyN : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.load, [tyN], r⟩)
    (hty : OpSem.Ty.parse tyN = some (.int n sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"m", .mem⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sp.off ∧ sp.off < 2 ^ 31 ∧
      -2 ^ 31 ≤ (off : Int) ∧ (off : Int) < 2 ^ 31)
    {ch : OpSem.Choice} :
    ∃ st', opSem opc [.slot sd.off, .mem sp.off (off : Int)] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  have hwo : (q1.wrappingOffset (off : Int)).addr = q.addr + off := wrappingOffset_addr hpq.1 hlim
  have hpi : PtrInj ι ⟨q.addr + off, q.prov⟩ (q1.wrappingOffset (off : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  obtain ⟨bs1, hl1, hia⟩ := stLoad_inj hmem hpi (by omega) hmq hlo
  have hbl : bs0.length = n := load_length hlo
  have hle := reenc_wf hwf hn hbl hdec hen
  obtain ⟨hbs, hlend⟩ := BytesInj.of_le_trans hle hia
  rw [hbl] at hlend
  have hlenb : bs1.length = n := (BytesInj.length hbs).symm.trans hlend
  obtain ⟨st', hwr, -, hmi, hrd, hoth⟩ := hW bs1 hbs
  have hop := opSem_load_fwd (ch := ch) hh hty ho hfits hrfp hq1 hl1 hlenb hwr
  exact ⟨st', hop, hmi, hrd, hoth⟩

/-- `sim_derefStore` from R's read of the pointer bytes (`hrfp`, `hbp`). Same proof. -/
theorem sim_derefStoreW {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {ty : Spec.Ty} {n off : Nat} (hwf : ty.wf = true) (hn : ty.size? = some n) (hpos : 0 < n)
    {sp sa : LocalSlot} (hsa : sa.size = n)
    {pa q : ThinPointer} {bp bp1 bsa bsd : List AbstractByte} {v : Value}
    (hrfp : st.readFrame sp.off 8 = .ok bp1) (hbp : BytesInj ι bp bp1)
    (hq : decodePtr bp = some q)
    {a0 b0 : AllocId} (hqa : q.prov = some a0) (hb0 : ι a0 = some b0)
    (hlim : q.addr + off < Target.ADDR_LIMIT)
    (hla : s.mem.load pa n .one = .ok bsa) (hdec : ty.decode bsa = some v)
    (hen : ty.encode v = some bsd)
    (hsto : s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem)
    (hld : LiveDisjoint s.mem)
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true)
    {opc : Full.Opcode} {r : Option String} {tyN : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.store, [tyN], r⟩)
    (hty : OpSem.Ty.parse tyN = some (.int n sg))
    (ho : opc.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ sp.off ∧ sp.off < 2 ^ 31 ∧ -2 ^ 31 ≤ (off : Int) ∧ (off : Int) < 2 ^ 31 ∧
      -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    {ch : OpSem.Choice} :
    ∃ mem', opSem opc [.mem sp.off (off : Int), .slot sa.off] st ch =
        .ok (.next, { st with mem := mem' }) ∧
      MemInj ι s'.mem mem' ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv →
        LocalRel ι fp { st with mem := mem' } s'.mem slot p lv := by
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra
    (show s.mem.load pa sa.size .one = .ok bsa by rw [hsa]; exact hla)
  rw [hsa] at hrfa
  have hbl : bsa.length = n := load_length hla
  have hle := reenc_wf hwf hn hbl hdec hen
  obtain ⟨hbs, hlend⟩ := BytesInj.of_le_trans hle hia
  have hlenba : ba.length = bsd.length := (BytesInj.length hbs).symm
  have hN : bsd.length ≠ 0 := by omega
  have hwo : (q1.wrappingOffset (off : Int)).addr = q.addr + off :=
    wrappingOffset_addr hpq.1 hlim
  have hpi : PtrInj ι ⟨q.addr + off, q.prov⟩ (q1.wrappingOffset (off : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
    ⟨_, hl0, -⟩ | ⟨id, hid, _, _, hprov, hlv, h1, h2, -, -⟩
  · exact absurd hl0 hN
  have hia0 : id = a0 := Option.some.inj (hprov.symm.trans hqa)
  have hbid : ι id = some b0 := by rw [hia0]; exact hb0
  -- the stored range's bounds, on `q.addr + off` itself (not through the pointer's `addr`)
  have h1' : s.mem.allocs[id].addr ≤ q.addr + off := h1
  have h2' : q.addr + off + bsd.length ≤ s.mem.allocs[id].addr + s.mem.allocs[id].data.size :=
    h2
  have hc := (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok (mem := s.mem)
    (p := ⟨q.addr + off, q.prov⟩) (len := ba.length)
    (r := some (id, (⟨q.addr + off, q.prov⟩ : ThinPointer).addr - s.mem.allocs[id].addr))).mpr
    (.inr ⟨id, hid, by omega, hprov, hlv, h1, by rw [hlenba]; exact h2, rfl⟩)
  have hres := resolve_inj_of_checkPtr (st := st) hmem hpi hprov hbid (by omega) hc
  have hal : Align.one.isAligned (⟨q.addr + off, q.prov⟩ : ThinPointer).addr = true := by
    simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]
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

/-! ### The lifts -/

/-- `load`'s lift through a wide `_p` (as `lift_derefLoad`, the pointer by `widePtr_read`). -/
theorem lift_derefWideLoad {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerDerefWide Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @load d p oa pointee ty fe fields pt valid off n sd sp i ha htp hk hpath htd hn hpos hwf hsd
      hsp hsize hoff hmi =>
    rw [eval_use_place_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := loadInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htp htd
    obtain ⟨pd, pp, bs, q, bs0, w, bsd, hpd, hpp, hlp, hlen, hq, hlim, hlo0, hd, hen, hsto,
      hstk⟩ := derefLoadW_mem hs htp hk hpath htd hn h
    have hlp' : live p = true := hlo _ (operandPlace?_mem ha)
    have hrp := hrel.opnd hpp hsp hlp'
    obtain ⟨hlp8, bp1, hrfp, hbp⟩ := widePtr_read hrel.frame.mem hrp hsize.2 hlp
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    have hlen0 : bsd.length = sd.size :=
      ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp
        (reenc_wf hwf hn (load_length hlo0) hd hen)).1.trans
        ((load_length hlo0).trans hsize.1.symm)
    have hW := hrel.dstWrite hld hpd hsd hpos' hlen0 hsto
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_target_mapped hmap hlp8 hq (by omega) hlo0
    have hmq : ∀ a, q.prov = some a → ι a ≠ none := by
      intro a ha'
      have e : a = a0 := Option.some.inj (ha'.symm.trans hqa)
      rw [e, hb0]
      simp
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨st', hop, hmi', hrd, hoth⟩ := sim_derefLoadW (ch := ch) hwf hn hpos hsize.1
      hrfp hbp hq hmq hlim hlo0 hd hen hrel.frame.mem hW hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩
    have hsub := bytesLeDefined_prov (reenc_wf hwf hn (load_length hlo0) hd hen)
    have hhid := hrel.hidden.load hlo0
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
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hlo0 hsub⟩

/-- `store`'s lift through a wide `_p` (as `lift_derefStore`, the pointer by `widePtr_read`). -/
theorem lift_derefWideStore {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {pl : MPlace} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerDerefWide Γ (.assign pl rv) [i]) (hproj : pl.proj ≠ [])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ stmtReads (.assign pl rv), live l = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assign pl rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | load => exact (hproj rfl).elim
  | @store p a oa pointee ty fe fields pt valid off n sp sa i ha htp hk hpath hta hn hpos hwf
      hsp hsa hsize hoff hmi =>
    rw [eval_use_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := storeInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htp hta
    obtain ⟨pp, pa, bs, q, bsa, w, bsd, hpp, hpa, hlp, hlen, hq, hlim, hla, hd, hen, hsto,
      hstk⟩ := derefStoreW_mem hs htp hk hpath hta hn h
    have hmemp : p ∈ stmtReads (.assign ⟨p, .deref pointee :: fe :: fields⟩ (.use oa)) := by
      show p ∈ placeLocals ⟨p, .deref pointee :: fe :: fields⟩ ++ rvalueLocals (.use oa)
      simp [placeLocals]
    have hmema : a ∈ stmtReads (.assign ⟨p, .deref pointee :: fe :: fields⟩ (.use oa)) := by
      show a ∈ placeLocals ⟨p, .deref pointee :: fe :: fields⟩ ++ rvalueLocals (.use oa)
      rcases local?_cases ha with rfl | rfl <;>
        simp [placeLocals, rvalueLocals, operandLocals]
    have hrp := hrel.opnd hpp hsp (hlo _ hmemp)
    have hra := hrel.opnd hpa hsa (hlo _ hmema)
    obtain ⟨hlp8, bp1, hrfp, hbp⟩ := widePtr_read hrel.frame.mem hrp hsize.2 hlp
    have hbl : bsa.length = n := load_length hla
    have hle := reenc_wf hwf hn hbl hd hen
    have hlbd : bsd.length = n := (BytesInj.of_leDefined hle).length.trans hbl
    have hne : bsd ≠ [] := by
      intro he
      rw [he, List.length_nil] at hlbd
      omega
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_store_target_mapped hmap hlp8 hq hne hsto
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨mem', hop, hmi', hloc⟩ := sim_derefStoreW (ch := ch) hwf hn hpos hsize.1 hrfp hbp
      hq hqa hb0 hlim hla hd hen hsto hld hrel.frame.mem hra hh hty' ho
      ⟨hf1.1, hf1.2, hf3.1, hf3.2, hf2.1, hf2.2⟩
    have hsub := bytesLeDefined_prov hle
    have hhid := hrel.hidden.load hla
    have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hhid _ (List.getElem_mem hj) fr0 hf0
    have hbd := hpb.load hla
    have hbd' : BytesBounded s.mem.allocs.size bsd := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hbd _ (List.getElem_mem hj) fr0 hf0
    exact ⟨{ s1.st with mem := mem' },
      step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after_store hmi' hloc (hrel.hidden.store_hidden hsto hhid') hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hla hsub⟩

/-- `LowerDerefWide` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_derefCast`). -/
theorem stmt_sim_derefWide {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerDerefWide Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨pl, rv, i, rfl, hR⟩ : ∃ pl rv i, st = .assign pl rv ∧ rangeInsns c.d r = [i] := by
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
  obtain ⟨b, ps⟩ := pl
  cases ps with
  | nil =>
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      (lift_derefWideLoad M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb
        M.dinv.1 M.dinv.2 hl2 hl1 hev)
  | cons x xs =>
    have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
    obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
    obtain ⟨st', hstep, hstk, hrel, hpb, hle, hk⟩ := lift_derefWideStore (ch := ch) M.stack
      M.body.symm hmode.symm hρ.symm h (List.cons_ne_nil _ _) hc hsc hpe hpl M.rel M.pb
      M.dinv.1 M.dinv.2 hlv2 (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
    refine ⟨_, f, .cons hstep (.refl _), hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl, hpc, hrel,
      ?_, hpb, ?_, M.dinv.of_memKept hk⟩
    · intro l p hp
      exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by intro e; cases e)
    · intro a ha
      exact M.fresh a (Nat.le_trans hle ha)

end Ryo.Proofs.Lower
