/-
Ryo.Proofs.Lower.SimDerefStoreF — the simulation of `LowerDerefStoreF`
(`Check/Lower/DerefStoreF.lean`, M5b): `(*_p).fields = copy _a.projs` lowered to one
`store.wN [sp.off + off], sa.off + offa`.

L0 (`derefStoreF_mem`): as `derefStore_mem`, the source by `runOn_evalOperand_field` (a load at
`_a`'s pointer plus `offa`). R: the source bytes by `readLocal_sub_inj` (inside `_a`'s slot);
`sim_derefStoreR` is `sim_derefStore` from R's reads of the pointer and of the source (any slot
offset `x`) and L0's source bytes' length; `lift_derefStoreF` is `lift_derefStore` with them.
`stmt_sim_derefStoreF` is the scope-free case (as `stmt_sim_derefCast`'s store).
-/
import Ryo.Proofs.Lower.SimDerefWide
import Ryo.Proofs.Lower.SimTermMore
import Ryo.Check.Lower.DerefStoreF

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### L0 -/

/-- `derefStore_mem` with a field of `_a` as the source. -/
theorem derefStoreF_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p a : Local} {pointee ty ta : Spec.Ty}
    {fields projs : List ProjElem} {pt : PtrType} {valid : ValidRange} {off offa n : Nat}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
    (hpath : fieldPath pointee fields = some (off, ty))
    (hta : f.body.locals[a]? = some ta) (hpa : fieldPath ta projs = some (offa, ty))
    (hn : ty.size? = some n)
    (h : runOn (evalStatement (.assign ⟨p, .deref pointee :: fields⟩
      (.use (.copy ⟨a, projs⟩)))) o s = (.ok (), s')) :
    ∃ pp pa bp q bsa v bsd, f.locals[p]? = some (some pp) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.load pp 8 .one = .ok bp ∧ decodePtr bp = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.load ⟨pa.addr + offa, pa.prov⟩ n .one = .ok bsa ∧ ty.decode bsa = some v ∧
      ty.encode v = some bsd ∧
      s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  have e : evalStatement (.assign ⟨p, .deref pointee :: fields⟩ (.use (.copy ⟨a, projs⟩))) =
      (evalPlace ⟨p, .deref pointee :: fields⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.use (.copy ⟨a, projs⟩)) ty >>= fun v =>
          placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pp, bp, q, al, hpp, hlp, hq, hlim, rfl, hs1⟩ :=
    runOn_evalPlace_deref hs htp hk hpath h1
  have h2' : runOn (evalRvalue (.use (.copy ⟨a, projs⟩)) ty >>= fun v =>
      placeStore ⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩ v ty) o s1 =
      (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.use (.copy ⟨a, projs⟩)) ty =
      (evalOperand (.copy ⟨a, projs⟩) >>= fun r => pure r.1) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨rr, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨hv, hs3⟩ := prod_ok_inj h6
  obtain ⟨pa, w, hpa', hlw, hrr, hs3'⟩ :=
    runOn_evalOperand_field (d := .copy ⟨a, projs⟩) hs rfl hta hpa h5
  subst hrr
  obtain ⟨bsa, hla, hd⟩ := typedLoad_inv hn hlw
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  have hs2 : s2 = s := hs3.symm.trans hs3'
  rw [hs2, ← hv] at hst
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  subst hs'
  exact ⟨pp, pa, bp, q, bsa, w, bsd, hpp, hpa', hlp, hq, hlim, hla, hd, hen, hsto,
    by rw [hs2]⟩

/-! ### R -/

/-- `sim_derefStore` from R's reads: the pointer bytes `bp1` (related to L0's `bp`) and the
source bytes `ba` at slot offset `x` (related to L0's `bsa`). Same proof. -/
theorem sim_derefStoreR {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {ty : Spec.Ty} {n off : Nat} (hwf : ty.wf = true) (hn : ty.size? = some n) (hpos : 0 < n)
    {sp : Int} {x : Int} {q : ThinPointer} {bp bp1 bsa ba bsd : List AbstractByte} {v : Value}
    (hrfp : st.readFrame sp 8 = .ok bp1) (hbp : BytesInj ι bp bp1)
    (hq : decodePtr bp = some q)
    {a0 b0 : AllocId} (hqa : q.prov = some a0) (hb0 : ι a0 = some b0)
    (hlim : q.addr + off < Target.ADDR_LIMIT)
    (hbl : bsa.length = n) (hrfa : st.readFrame x n = .ok ba) (hia : BytesInj ι bsa ba)
    (hdec : ty.decode bsa = some v) (hen : ty.encode v = some bsd)
    (hsto : s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem)
    (hld : LiveDisjoint s.mem)
    (hmem : MemInj ι s.mem st.mem)
    {opc : Full.Opcode} {r : Option String} {tyN : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.store, [tyN], r⟩)
    (hty : OpSem.Ty.parse tyN = some (.int n sg))
    (ho : opc.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ sp ∧ sp < 2 ^ 31 ∧ -2 ^ 31 ≤ (off : Int) ∧ (off : Int) < 2 ^ 31 ∧
      -2 ^ 31 ≤ x ∧ x < 2 ^ 31)
    {ch : OpSem.Choice} :
    ∃ mem', opSem opc [.mem sp (off : Int), .slot x] st ch =
        .ok (.next, { st with mem := mem' }) ∧
      MemInj ι s'.mem mem' ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv →
        LocalRel ι fp { st with mem := mem' } s'.mem slot p lv := by
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
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

/-! ### The lift -/

/-- `LowerDerefStoreF`'s lift (as `lift_derefStore`). -/
theorem lift_derefStoreF {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {pl : MPlace} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerDerefStoreF Γ (.assign pl rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ stmtReads (.assign pl rv), live l = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assign pl rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @mk p a oa pointee ty ta fields projs pt valid off offa n sp sa i ha htaΓ hpa htpΓ hk hpath
      hn hpos hwf hsp hsa hsize hoff hmi =>
    rw [eval_use_place_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := storeInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    have htp : f.body.locals[p]? = some (.ptr pt valid) := by rw [← hbody]; exact htpΓ
    have hta : f.body.locals[a]? = some ta := by rw [← hbody]; exact htaΓ
    obtain ⟨pp, pa, bp, q, bsa, w, bsd, hpp, hpa', hlp, hq, hlim, hla, hd, hen, hsto, hstk⟩ :=
      derefStoreF_mem hs htp hk hpath hta hpa hn h
    -- `_p` and `_a` are read, so live
    have hmemp : p ∈ stmtReads (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) := by
      show p ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.use oa)
      simp [placeLocals]
    have hmema : a ∈ stmtReads (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) := by
      show a ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.use oa)
      exact List.mem_append_right _ (operandPlace?_mem ha)
    have hrp := hrel.opnd hpp hsp (hlo _ hmemp)
    have hra := hrel.opnd hpa' hsa (hlo _ hmema)
    obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hrel.frame.mem hrp
      (show s.mem.load pp sp.size .one = .ok bp by rw [hsize.1]; exact hlp)
    rw [hsize.1] at hrfp
    obtain ⟨ba, hrfa, hia⟩ := readLocal_sub_inj hrel.frame.mem hra hsize.2 hla
    have hbl : bsa.length = n := load_length hla
    have hle := reenc_wf hwf hn hbl hd hen
    have hlbd : bsd.length = n := (BytesInj.of_leDefined hle).length.trans hbl
    have hne : bsd ≠ [] := by
      intro he
      rw [he, List.length_nil] at hlbd
      omega
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_store_target_mapped hmap hlp hq hne hsto
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨mem', hop, hmi', hloc⟩ := sim_derefStoreR (ch := ch) hwf hn hpos hrfp hbp hq hqa hb0
      hlim hbl hrfa hia hd hen hsto hld hrel.frame.mem hh hty' ho
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

/-- `LowerDerefStoreF` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_derefCast`'s
store). -/
theorem stmt_sim_derefStoreF {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerDerefStoreF Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨b, x, xs, rv, i, rfl, hR⟩ : ∃ b x xs rv i, st = .assign ⟨b, x :: xs⟩ rv ∧
      rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h
    exact ⟨_, _, _, _, _, rfl, rfl⟩
  rw [hR] at h
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
  have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  obtain ⟨st', hstep, hstk, hrel, hpb, hle, hk⟩ := lift_derefStoreF (ch := ch) M.stack
    M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb
    M.dinv.1 M.dinv.2 hlv2 (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
  refine ⟨_, f, .cons hstep (.refl _), hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl, hpc, hrel,
    ?_, hpb, ?_, M.dinv.of_memKept hk⟩
  · intro l p hp
    exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by intro e; cases e)
  · intro a ha
    exact M.fresh a (Nat.le_trans hle ha)

end Ryo.Proofs.Lower
