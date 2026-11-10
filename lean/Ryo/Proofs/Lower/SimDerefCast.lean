/-
Ryo.Proofs.Lower.SimDerefCast — the simulation of `LowerDerefCast` (`Check/Lower/DerefCast.lean`,
M5b): transmutes read from or written to a place through a thin pointer, one `load`/`store`.

The R side is `SimDeref`'s: `sim_derefLoadLe`/`sim_derefStoreLe` are `sim_derefLoad`/
`sim_derefStore` with "the stored bytes are below the loaded ones" as their hypothesis in place
of one re-encoding at one type (the proofs used nothing else of it). L0
(`derefLoadCast_mem`, `derefStoreCast_mem`): as `derefLoad_mem`/`derefStore_mem` with the
value passed through `evalCast`, a transmute, whose bytes are two re-encodings below the loaded
ones (`cast_le`, as `SimCopy.bitCast_mem`). The lifts are `lift_derefLoad`'s and
`lift_derefStore`'s; `stmt_sim_derefCast` is `FnStep.stmt_sim`'s case (the store as its
`deref` store case).
-/
import Ryo.Proofs.Lower.SimDeref
import Ryo.Proofs.Lower.SimCopy
import Ryo.Proofs.Lower.WriteDst
import Ryo.Check.Lower.DerefCast

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### L0 -/

/-- A transmute of a value loaded at `ta` to `ty` (both well-formed of `n` bytes), run to
success and stored as `bsd`: the state unchanged, `bsd` below the loaded bytes.

Proof: as `bitCast_mem`: `evalCast` is `getMem >>= liftE ∘ transmute`; `transmute_bytes`
(encode at `ta`, decode at `ty`); two `encode_decode_le`s and `bytesLe_trans`. -/
theorem cast_le {k : CastKind} (hk : bitCastKind k = true) {p : ThinPointer} {ta ty : Spec.Ty}
    {n : Nat} {va w : Value} {bsd : List AbstractByte} {o : Spec.Oracle} {s s2 : Spec.State}
    (hwfa : ta.wf = true) (hwf : ty.wf = true) (hna : ta.size? = some n)
    (hn : ty.size? = some n) (hla : typedLoad s.mem p ta .one = .ok va)
    (hca : runOn (evalCast k (va, ta) ty) o s = (.ok w, s2))
    (hen : ty.encode w = some bsd) :
    s2 = s ∧ ∃ bs0, s.mem.load p n .one = .ok bs0 ∧ bytesLeDefined bsd bs0 = true := by
  have e3 : evalCast k (va, ta) ty =
      (SemM.getMem >>= fun m => SemM.liftE (transmute m va ta ty)) := by
    cases k <;> first | rfl | (cases hk; done) | simp [bitCastKind] at hk
  rw [e3] at hca
  obtain ⟨m, s3, h7, h8⟩ := runOn_bind_ok hca
  rw [runOn_getMem] at h7
  obtain ⟨hm, hs3⟩ := prod_ok_inj h7
  subst hm
  subst hs3
  obtain ⟨htr, hs2⟩ := runOn_liftE_ok h8
  obtain ⟨bs1, hen1, hdec1⟩ := transmute_bytes htr
  obtain ⟨bs0, hlo, hd0⟩ := typedLoad_inv hna hla
  have hl0 : bs0.length = ta.size := (movLoad_length hlo).trans (tySize_of hna).symm
  obtain ⟨bs1', he1', hle1⟩ := Ryo.Spec.Theorems.encode_decode_le ta bs0 va hwfa hl0 hd0
  have e6 : bs1' = bs1 := Option.some.inj (he1'.symm.trans hen1)
  rw [e6] at hle1
  have hl1 : bs1.length = ty.size :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle1).1.trans
      ((movLoad_length hlo).trans (tySize_of hn).symm)
  obtain ⟨bsd', he2', hle2⟩ := Ryo.Spec.Theorems.encode_decode_le ty bs1 w hwf hl1 hdec1
  have e7 : bsd' = bsd := Option.some.inj (he2'.symm.trans hen)
  rw [e7] at hle2
  exact ⟨hs2, bs0, hlo, bytesLe_trans hle2 hle1⟩

theorem eval_cast_place_norm {pl : MPlace} {k : CastKind} {oa : Operand} {p : MPlace}
    {ty : Spec.Ty} (ha : operandPlace? oa = some p) :
    evalStatement (.assign pl (.cast k oa ty)) = evalStatement (.assign pl (.cast k (.copy p) ty)) := by
  cases oa <;> simp [operandPlace?] at ha <;> subst ha <;>
    first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]

/-- `_d = transmute (*_p).fields` run to success, in memory terms (`derefLoad_mem` with the
transmute: `cast_le`). -/
theorem derefLoadCast_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p : Local} {k : CastKind}
    (hk : bitCastKind k = true) {pointee ty tyd : Spec.Ty} {fields : List ProjElem}
    {pt : PtrType} {valid : ValidRange} {off n : Nat}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hpk : pt.metaKind = .none)
    (hpath : fieldPath pointee fields = some (off, ty))
    (htd : f.body.locals[d]? = some tyd) (hwf : ty.wf = true) (hwfd : tyd.wf = true)
    (hn : ty.size? = some n) (hnd : tyd.size? = some n)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.cast k (.copy ⟨p, .deref pointee :: fields⟩) tyd))) o s = (.ok (), s')) :
    ∃ pd pp bp q bs0 bsd, f.locals[d]? = some (some pd) ∧ f.locals[p]? = some (some pp) ∧
      s.mem.load pp 8 .one = .ok bp ∧ decodePtr bp = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.load ⟨q.addr + off, q.prov⟩ n .one = .ok bs0 ∧ bytesLeDefined bsd bs0 = true ∧
      s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  have e : evalOperand (.copy ⟨p, .deref pointee :: fields⟩) =
      (evalPlace ⟨p, .deref pointee :: fields⟩ >>= fun x => match x with
        | (pl, ty) => placeLoad pl ty >>= fun v => pure (v, ty)) := rfl
  rw [e] at hev
  obtain ⟨x, s3, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨pp, bp, q, al, hpp, hlp, hq, hlim, rfl, hs3⟩ :=
    runOn_evalPlace_deref hs htp hpk hpath h1
  have h2' : runOn (placeLoad ⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩ ty >>=
      fun v => pure (v, ty)) o s3 = (.ok r, s1) := h2
  rw [hs3] at h2'
  obtain ⟨v, s4, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨hv, hs4⟩ := runOn_placeLoad_ok h3
  obtain ⟨hrv, hs1⟩ := prod_ok_inj h4
  subst hrv
  have hs1' : s1 = s := hs1.symm.trans hs4
  rw [hs1'] at hca
  have e4 : td = tyd := Option.some.inj (htd'.symm.trans htd)
  subst e4
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  obtain ⟨hs2, bs0, hlo, hle⟩ := cast_le hk hwf hwfd hn hnd hv hca hen
  rw [hs2] at hsto
  subst hs'
  refine ⟨pd, pp, bp, q, bs0, bsd, hpd, hpp, hlp, hq, hlim, hlo, hle, hsto, ?_⟩
  show s2.stack = s.stack
  rw [hs2]

/-- `(*_p).fields = transmute _a` run to success, in memory terms (`derefStore_mem` with the
transmute: `cast_le`). -/
theorem derefStoreCast_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p a : Local} {k : CastKind}
    (hk : bitCastKind k = true) {pointee ty ta : Spec.Ty} {fields : List ProjElem}
    {pt : PtrType} {valid : ValidRange} {off n : Nat}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hpk : pt.metaKind = .none)
    (hpath : fieldPath pointee fields = some (off, ty))
    (hta : f.body.locals[a]? = some ta) (hwf : ty.wf = true) (hwfa : ta.wf = true)
    (hn : ty.size? = some n) (hna : ta.size? = some n)
    (h : runOn (evalStatement (.assign ⟨p, .deref pointee :: fields⟩
      (.cast k (.copy ⟨a, []⟩) ty))) o s = (.ok (), s')) :
    ∃ pp pa bp q bsa bsd, f.locals[p]? = some (some pp) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.load pp 8 .one = .ok bp ∧ decodePtr bp = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.load pa n .one = .ok bsa ∧ bytesLeDefined bsd bsa = true ∧
      s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  have e : evalStatement (.assign ⟨p, .deref pointee :: fields⟩ (.cast k (.copy ⟨a, []⟩) ty)) =
      (evalPlace ⟨p, .deref pointee :: fields⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue (.cast k (.copy ⟨a, []⟩) ty) ty' >>= fun v =>
          placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pp, bp, q, al, hpp, hlp, hq, hlim, rfl, hs1⟩ :=
    runOn_evalPlace_deref hs htp hpk hpath h1
  have h2' : runOn (evalRvalue (.cast k (.copy ⟨a, []⟩) ty) ty >>= fun v =>
      placeStore ⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩ v ty) o s1 =
      (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.cast k (.copy ⟨a, []⟩) ty) ty =
      (evalOperand (.copy ⟨a, []⟩) >>= fun r => evalCast k r ty) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨rr, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pa, ta', w, hpa, hta', hlw, hrr, hs3⟩ := runOn_evalOperand_copy hs h5
  subst hrr
  have e3 : ta' = ta := Option.some.inj (hta'.symm.trans hta)
  subst e3
  rw [hs3] at h6
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  obtain ⟨hs2, bsa, hla, hle⟩ := cast_le hk hwfa hwf hna hn hlw h6 hen
  rw [hs2] at hsto
  subst hs'
  refine ⟨pp, pa, bp, q, bsa, bsd, hpp, hpa, hlp, hq, hlim, hla, hle, hsto, ?_⟩
  show s2.stack = s.stack
  rw [hs2]

/-! ### R -/

/-- `SimDeref.sim_derefLoad` with the stored bytes given only as below the loaded ones. -/
theorem sim_derefLoadLe {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {n off : Nat} (hpos : 0 < n)
    {sd sp : LocalSlot} (hsd : sd.size = n) (hsp : sp.size = 8)
    {pd pp q : ThinPointer} {bp bs0 bsd : List AbstractByte}
    (hlp : s.mem.load pp 8 .one = .ok bp) (hq : decodePtr bp = some q)
    (hmq : ∀ a, q.prov = some a → ι a ≠ none) (hlim : q.addr + off < Target.ADDR_LIMIT)
    (hlo : s.mem.load ⟨q.addr + off, q.prov⟩ n .one = .ok bs0)
    (hle : bytesLeDefined bsd bs0 = true)
    (hsto : s.mem.store pd bsd .one = .ok s'.mem)
    (hmem : MemInj ι s.mem st.mem) (hrp : LocalRel ι fp st s.mem sp pp true)
    -- `_d`, private or escaped (`FnRel.dstWrite`)
    (hW : DstWrite ι fp st s.mem s'.mem sd pd bsd)
    -- the instruction
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
  -- R's pointer
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hmem hrp
    (show s.mem.load pp sp.size .one = .ok bp by rw [hsp]; exact hlp)
  rw [hsp] at hrfp
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  have hwo : (q1.wrappingOffset (off : Int)).addr = q.addr + off := wrappingOffset_addr hpq.1 hlim
  have hpi : PtrInj ι ⟨q.addr + off, q.prov⟩ (q1.wrappingOffset (off : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  -- R's load
  obtain ⟨bs1, hl1, hia⟩ := stLoad_inj hmem hpi (by omega) hmq hlo
  have hbl : bs0.length = n := load_length hlo
  obtain ⟨hbs, hlend⟩ := BytesInj.of_le_trans hle hia
  rw [hbl] at hlend
  have hlenb : bs1.length = n := (BytesInj.length hbs).symm.trans hlend
  -- R's write
  obtain ⟨st', hwr, -, hmi, hrd, hoth⟩ := hW bs1 hbs
  have hop := opSem_load_fwd (ch := ch) hh hty ho hfits hrfp hq1 hl1 hlenb hwr
  exact ⟨st', hop, hmi, hrd, hoth⟩

/-- `SimDeref.sim_derefStore` with the stored bytes given only as below `_a`'s loaded ones. -/
theorem sim_derefStoreLe {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {n off : Nat} (hpos : 0 < n)
    {sp sa : LocalSlot} (hsp : sp.size = 8) (hsa : sa.size = n)
    {pp pa q : ThinPointer} {bp bsa bsd : List AbstractByte}
    (hlp : s.mem.load pp 8 .one = .ok bp) (hq : decodePtr bp = some q)
    {a0 b0 : AllocId} (hqa : q.prov = some a0) (hb0 : ι a0 = some b0)
    (hlim : q.addr + off < Target.ADDR_LIMIT)
    (hla : s.mem.load pa n .one = .ok bsa) (hle : bytesLeDefined bsd bsa = true)
    (hsto : s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem)
    (hld : LiveDisjoint s.mem)
    (hmem : MemInj ι s.mem st.mem) (hrp : LocalRel ι fp st s.mem sp pp true)
    (hra : LocalRel ι fp st s.mem sa pa true)
    -- the instruction
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
  -- R's pointer and stored bytes
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hmem hrp
    (show s.mem.load pp sp.size .one = .ok bp by rw [hsp]; exact hlp)
  rw [hsp] at hrfp
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra
    (show s.mem.load pa sa.size .one = .ok bsa by rw [hsa]; exact hla)
  rw [hsa] at hrfa
  have hbl : bsa.length = n := load_length hla
  obtain ⟨hbs, hlend⟩ := BytesInj.of_le_trans hle hia
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


/-! ### The lifts -/

/-- `load`'s lift (`lift_derefLoad` with `derefLoadCast_mem` and `sim_derefLoadLe`). -/
theorem lift_derefCastLoad {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerDerefCast Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @load d p oa k pointee ty tyd fields pt valid off n sd sp i hk ha htp hpk hpath htd hn hnd
      hpos hwf hwfd hsd hsp hsize hoff hmi =>
    have hlp' : live p = true := hlo p (by
      cases oa <;> simp [operandPlace?] at ha <;> subst ha <;>
        simp [rvalueLocals, operandLocals, placeLocals])
    rw [eval_cast_place_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := loadInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htp htd
    obtain ⟨pd, pp, bp, q, bs0, bsd, hpd, hpp, hlp, hq, hlim, hlo0, hle, hsto, hstk⟩ :=
      derefLoadCast_mem hs hk htp hpk hpath htd hwf hwfd hn hnd h
    have hrp := hrel.opnd hpp hsp hlp'
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    have hlen0 : bsd.length = sd.size :=
      ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans
        ((load_length hlo0).trans hsize.1.symm)
    have hW := hrel.dstWrite hld hpd hsd hpos' hlen0 hsto
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_target_mapped hmap hlp hq (by omega) hlo0
    have hmq : ∀ a, q.prov = some a → ι a ≠ none := by
      intro a ha'
      have e : a = a0 := Option.some.inj (ha'.symm.trans hqa)
      rw [e, hb0]
      simp
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨st', hop, hmi', hrd, hoth⟩ := sim_derefLoadLe (ch := ch) hpos hsize.1 hsize.2
      hlp hq hmq hlim hlo0 hle hsto hrel.frame.mem hrp hW hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩
    have hsub := bytesLeDefined_prov hle
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

/-- `store`'s lift (`lift_derefStore` with `derefStoreCast_mem` and `sim_derefStoreLe`). -/
theorem lift_derefCastStore {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {pl : MPlace} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerDerefCast Γ (.assign pl rv) [i]) (hproj : pl.proj ≠ [])
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
  | @store p a oa k pointee ty ta fields pt valid off n sp sa i hk ha htp hpk hpath hta hn hna
      hpos hwf hwfa hsp hsa hsize hoff hmi =>
    have hmemp : p ∈ stmtReads (.assign ⟨p, .deref pointee :: fields⟩ (.cast k oa ty)) := by
      show p ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.cast k oa ty)
      simp [placeLocals]
    have hmema : a ∈ stmtReads (.assign ⟨p, .deref pointee :: fields⟩ (.cast k oa ty)) := by
      show a ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.cast k oa ty)
      rcases local?_cases ha with rfl | rfl <;>
        simp [placeLocals, rvalueLocals, operandLocals]
    rw [eval_cast_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := storeInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htp hta
    obtain ⟨pp, pa, bp, q, bsa, bsd, hpp, hpa, hlp, hq, hlim, hla, hle, hsto, hstk⟩ :=
      derefStoreCast_mem hs hk htp hpk hpath hta hwf hwfa hn hna h
    have hrp := hrel.opnd hpp hsp (hlo _ hmemp)
    have hra := hrel.opnd hpa hsa (hlo _ hmema)
    have hbl : bsa.length = n := load_length hla
    have hlbd : bsd.length = n :=
      ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans hbl
    have hne : bsd ≠ [] := by
      intro he
      rw [he, List.length_nil] at hlbd
      omega
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_store_target_mapped hmap hlp hq hne hsto
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨mem', hop, hmi', hloc⟩ := sim_derefStoreLe (ch := ch) hpos hsize.2 hsize.1 hlp
      hq hqa hb0 hlim hla hle hsto hld hrel.frame.mem hrp hra hh hty' ho
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

/-- `LowerDerefCast` in a scope-free function: `stmt_sim`'s case (the load as `refDeref`'s,
the store as `deref`'s store case). -/
theorem stmt_sim_derefCast {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerDerefCast Γ.toStmtCtx st (rangeInsns c.d r))
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
      (lift_derefCastLoad M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb
        M.dinv.1 M.dinv.2 hl2 hl1 hev)
  | cons x xs =>
    have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
    obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
    obtain ⟨st', hstep, hstk, hrel, hpb, hle, hk⟩ := lift_derefCastStore (ch := ch) M.stack
      M.body.symm hmode.symm hρ.symm h (List.cons_ne_nil _ _) hc hsc hpe hpl M.rel M.pb
      M.dinv.1 M.dinv.2 hlv2 (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
    refine ⟨_, f, .cons hstep (.refl _), hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl, hpc, hrel,
      ?_, hpb, ?_, M.dinv.of_memKept hk⟩
    · intro l p hp
      exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by intro e; cases e)
    · intro a ha
      exact M.fresh a (Nat.le_trans hle ha)

end Ryo.Proofs.Lower
