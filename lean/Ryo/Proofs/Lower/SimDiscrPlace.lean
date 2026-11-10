/-
Ryo.Proofs.Lower.SimDiscrPlace — the simulation of `LowerDiscrPlace`
(`Check/Lower/DiscrPlace.lean`, M5b): `_d = discriminant(_a.fields)` with a direct tag, one
`mov`/`cvt` from `_a`'s slot at the tag.

- L0 (`discrField_mem`): `discrDirect_mem`'s facts with the place's pointer
  `⟨pa.addr + off, pa.prov⟩` (`runOn_evalPlace_fields`) for `_a`'s (`readDiscr_direct`: the
  `.direct` branch of `readDiscriminant`).
- The tag's address: `pa.addr` is the start of `_a`'s allocation (`start_le`), so the wrapping
  offset to the tag does not wrap (`wrappingOffset_eq2`).
- R: `sim_tagRead` at the offset `off + tag.offset`; the rest as `lift_enumRead`'s
  `discrDirect` case (`lift_discrPlace`).
-/
import Ryo.Proofs.Lower.SimEnum
import Ryo.Check.Lower.DiscrPlace

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `wrappingOffset_eq` for a pointer `off` past an allocation start `p`. -/
theorem wrappingOffset_eq2 {p : ThinPointer} {off toff : Nat} (hoff : off + toff < 2 ^ 64)
    (hle : p.addr ≤ ((⟨p.addr + off, p.prov⟩ : ThinPointer).wrappingOffset toff).addr) :
    (⟨p.addr + off, p.prov⟩ : ThinPointer).wrappingOffset toff =
      ⟨p.addr + (off + toff), p.prov⟩ := by
  have hL : ((Target.ADDR_LIMIT : Nat) : Int) = 18446744073709551616 := by
    first | rfl | decide | simp [Target.ADDR_LIMIT]
  have hoff' : off + toff < 18446744073709551616 := hoff
  have hle' : p.addr ≤ ((((p.addr + off : Nat) : Int) + (toff : Int)) %
      ((Target.ADDR_LIMIT : Nat) : Int)).toNat := hle
  rw [hL] at hle'
  have hk : ((((p.addr + off : Nat) : Int) + (toff : Int)) %
      ((Target.ADDR_LIMIT : Nat) : Int)).toNat = p.addr + (off + toff) := by
    rw [hL]; omega
  first
    | (unfold ThinPointer.wrappingOffset; rw [hk])
    | (simp only [ThinPointer.wrappingOffset, hk])
    | (show ThinPointer.mk _ p.prov = _; rw [hk])

/-- `readDiscriminant`'s `.direct` branch, run to success: the tag bytes at the tag's offset
decode to the tag of variant `idx`'s discriminant (as in `discrDirect_mem`). -/
theorem readDiscr_direct {m : Memory} {pe : ThinPointer} {vs : List Spec.Variant}
    {discrTy : IntType} {tag : TagInfo} {esz : Nat} {eal : Align} {idx : Nat}
    (henc : tag.encoding = .direct)
    (hrd : readDiscriminant m pe (.enum vs discrTy (.multiple tag) esz eal) = .ok idx) :
    ∃ bs var, m.load (pe.wrappingOffset tag.offset) tag.tag.size .one = .ok bs ∧
      decodeBits bs = some (tag.tag.toBits var.discr) ∧ vs[idx]? = some var := by
  cases hsd : m.signedDereferenceable pe tag.offset with
  | error x =>
    exfalso
    simp only [readDiscriminant, hsd, pure_bind, exE_ok_bind, exE_error_bind, exE_pure, exE_throw,
        exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false, Except.ok.injEq,
        reduceCtorEq] at hrd
  | ok u0 =>
    cases hld : m.load (pe.wrappingOffset tag.offset) tag.tag.size .one with
    | error x =>
      exfalso
      simp only [readDiscriminant, hsd, hld, pure_bind, exE_ok_bind, exE_error_bind, exE_pure,
          exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
          Except.ok.injEq, reduceCtorEq] at hrd
    | ok bs =>
      cases hdb : decodeBits bs with
      | none =>
        exfalso
        simp only [readDiscriminant, hsd, hld, hdb, pure_bind, exE_ok_bind, exE_error_bind,
            exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
            Except.ok.injEq, reduceCtorEq] at hrd
      | some u =>
        cases htv : tagToVariant vs discrTy tag u with
        | error msg =>
          exfalso
          simp only [readDiscriminant, hsd, hld, hdb, htv, pure_bind, exE_ok_bind, exE_error_bind,
              exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true,
              exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
        | ok i =>
          have hi : i = idx := by
            cases hv : variantInhabited vs i
            · simp only [readDiscriminant, hsd, hld, hdb, htv, hv, pure_bind, exE_ok_bind,
                exE_error_bind, exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed,
                exE_ensure_true, exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
            · simp only [readDiscriminant, hsd, hld, hdb, htv, hv, pure_bind, exE_ok_bind,
                exE_error_bind, exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed,
                exE_ensure_true, exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
              first | exact hrd | exact hrd.symm
          subst hi
          obtain ⟨var, hvar, hbits⟩ : ∃ var, vs[i]? = some var ∧ tag.tag.toBits var.discr = u := by
            unfold tagToVariant at htv
            simp only [henc] at htv
            split at htv
            · cases htv
            · split at htv
              next v0 i0 hf =>
                cases htv
                have hp := List.find?_some hf
                have hm := List.mem_of_find?_eq_some hf
                rw [List.mem_zipIdx_iff_getElem?] at hm
                exact ⟨v0, hm, by simpa using hp⟩
              · cases htv
          exact ⟨bs, var, rfl, by rw [hbits]; exact hdb, hvar⟩

/-- `_d = discriminant(_a.projs)` of an enum field of a local, run to success, in memory terms
(`discr_assign_inv` with `runOn_evalPlace_fields` for `_a`'s place). -/
theorem discrField_assign_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {projs : List ProjElem}
    {ta : Spec.Ty} {off : Nat}
    {vs : List Spec.Variant} {discrTy : IntType} {repr : EnumRepr} {esz : Nat} {eal : Align}
    {t : IntType} {vd : ValidRange}
    (hta : f.body.locals[a]? = some ta)
    (hpath : fieldPath ta projs = some (off, .enum vs discrTy repr esz eal))
    (htd : f.body.locals[d]? = some (.int t vd))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.discriminant ⟨a, projs⟩))) o s = (.ok (), s')) :
    ∃ pd pa idx, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      readDiscriminant s.mem ⟨pa.addr + off, pa.prov⟩ (.enum vs discrTy repr esz eal) =
        .ok idx ∧
      s.mem.store pd (encodeBits t.size (t.toBits (t.bringInBounds
        (discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0))))) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  have e0 : evalStatement (.assign ⟨d, []⟩ (.discriminant ⟨a, projs⟩)) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue (.discriminant ⟨a, projs⟩) ty' >>= fun v =>
          placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e0] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hpd, htd', rfl, hs1⟩ := runOn_localPlace_ok hs h1
  rw [hs1] at h2
  obtain rfl : td = .int t vd := Option.some.inj (htd'.symm.trans htd)
  have h2' : runOn (evalRvalue (.discriminant ⟨a, projs⟩) (.int t vd) >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v (.int t vd)) o s = (.ok (), s') := h2
  obtain ⟨w, s2, h3, h4⟩ := runOn_bind_ok h2'
  -- the rvalue
  have e1 : evalRvalue (.discriminant ⟨a, projs⟩) (.int t vd) =
      (evalPlace ⟨a, projs⟩ >>= fun x =>
      match x with
      | (pl, ty) =>
        match ty with
        | .enum vs discrTy .. => do
          if !pl.aligned then
            throwUb "getting the discriminant of a place based on a misaligned pointer"
          let idx ← SemM.liftE (readDiscriminant (← SemM.getMem) pl.ptr.thin ty)
          let d := (vs[idx]?.map (·.discr)).getD 0
          pure (Value.int (t.bringInBounds (discrTy.bringInBounds d)))
        | _ => pure (.int 0)) := by
    first | rfl | (unfold evalRvalue; rfl) | (simp only [evalRvalue]; rfl)
  rw [e1] at h3
  obtain ⟨y, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pa, hpa, rfl, rfl⟩ := runOn_evalPlace_fields hs hta hpath h5
  simp only [Bool.not_true, Bool.false_eq_true, ↓reduceIte, pure_bind] at h6
  obtain ⟨m, s4, h7, h8⟩ := runOn_bind_ok h6
  rw [runOn_getMem0] at h7
  obtain ⟨rfl, rfl⟩ := prod_ok_inj h7
  obtain ⟨idx, s5, h9, h10⟩ := runOn_bind_ok h8
  obtain ⟨hrd, rfl⟩ := runOn_liftE_ok h9
  obtain ⟨hw, rfl⟩ := runOn_pure_inv h10
  subst hw
  obtain ⟨mem', hst, rfl⟩ := runOn_placeStore_ok h4
  exact ⟨pd, pa, idx, hpd, hpa, hrd, typedStore_int hst, rfl⟩

/-- `discrDirect_mem` for an enum field of a local. -/
theorem discrField_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {projs : List ProjElem}
    {ta : Spec.Ty} {off : Nat}
    {vs : List Spec.Variant} {discrTy : IntType} {tag : TagInfo} {esz : Nat} {eal : Align}
    {t : IntType} {vd : ValidRange}
    (hta : f.body.locals[a]? = some ta)
    (hpath : fieldPath ta projs = some (off, .enum vs discrTy (.multiple tag) esz eal))
    (henc : tag.encoding = .direct) (htd : f.body.locals[d]? = some (.int t vd))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.discriminant ⟨a, projs⟩))) o s = (.ok (), s')) :
    ∃ (pd pa : ThinPointer) (bs : List AbstractByte) (var : Spec.Variant),
      f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.load ((⟨pa.addr + off, pa.prov⟩ : ThinPointer).wrappingOffset tag.offset)
        tag.tag.size .one = .ok bs ∧
      decodeBits bs = some (tag.tag.toBits var.discr) ∧ var ∈ vs ∧
      s.mem.store pd (encodeBits t.size (t.toBits (t.bringInBounds
        (discrTy.bringInBounds var.discr)))) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  obtain ⟨pd, pa, idx, hpd, hpa, hrd, hsto, hstk⟩ := discrField_assign_inv hs hta hpath htd h
  obtain ⟨bs, var, hld, hdb, hvar⟩ := readDiscr_direct henc hrd
  simp only [hvar, Option.map_some, Option.getD_some] at hsto
  exact ⟨pd, pa, bs, var, hpd, hpa, hld, hdb, List.mem_of_getElem? hvar, hsto, hstk⟩

/-! ### The lift -/

theorem lift_discrPlace {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerDiscrPlace Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : Ryo.Proofs.Provenance.LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @discrField d a projs ta off vs discrTy tag esz eal t vd sd sa i hta hpath henc htd hagree
      hsd hsa hsize hoff hbound hii =>
    have hc0 : c.d.insns[s1.pc]? = some i := by simpa using hi 0 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hpl0 : PlainView c.mode c.ρ i := hpl i (by simp)
    rw [hbody] at hta htd
    obtain ⟨pd, pa, bs, var, hpd, hpa, hlde, hdec, hvar, hsto, hstk⟩ :=
      discrField_mem hs hta hpath henc htd h
    have hla : live a = true := hlo a (by simp [rvalueLocals, placeLocals])
    have hre := hrel.opnd hpa hsa hla
    -- the tag's address does not wrap
    have hn0 : tag.tag.size ≠ 0 := Nat.pos_iff_ne_zero.mp hsize.2.2.1
    obtain ⟨id, hid, hpid, -, hlo', -⟩ := load_eq_ok_pos hn0 hlde
    have hle2 : pa.addr ≤
        ((⟨pa.addr + off, pa.prov⟩ : ThinPointer).wrappingOffset tag.offset).addr :=
      start_le (q := (⟨pa.addr + off, pa.prov⟩ : ThinPointer).wrappingOffset tag.offset) hre rfl
        hid hpid hlo'
    rw [wrappingOffset_eq2 hbound hle2] at hlde
    -- `_d` private or escaped
    have hpos : 0 < sd.size := by rw [hsize.1]; exact hsize.2.1
    have hW := hrel.dstWrite hld hpd hsd hpos
      (by rw [Ryo.Spec.Theorems.encodeBits_length, hsize.1]) hsto
    have hf1 := offOk_spec hoff.1
    have hf3 := offOk_spec hoff.2
    have hin : off + tag.offset + tag.tag.size ≤ sa.size := hsize.2.2.2
    obtain ⟨v, st', hv, hctl, hop, hmi, hrd, hoth⟩ := sim_tagRead (ch := ch) (dv := var.discr)
      (toff := off + tag.offset) hii hsize.1 hin ⟨hf1.1, hf1.2, hf3.1, hf3.2⟩ hlde hdec
      (discrAgree_spec hagree var hvar) hsto hrel.frame.mem hre hW
    rw [hmode, hρ] at hv
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle'⟩ := memInv_store hpb hsto (encodeBits_noprov _ _)
    exact liftOutN_of_lift ⟨st', step_of_view hc0 hsc0 hpe hpl0 hv hctl hop, hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto (encodeBits_noprov _ _))
        hesc hlive', hpb', hle'⟩

/-! ### The statement -/

theorem stmt_sim_discrPlace {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerDiscrPlace Γ.toStmtCtx st (rangeInsns c.d r))
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
  exact lift_discrPlace M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    M.dinv.2 hl2 hl1 hev

end Ryo.Proofs.Lower
