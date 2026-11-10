/-
Ryo.Proofs.Lower.SimRefDerefDown — the simulation of `LowerRefDerefDown`
(`Check/Lower/RefDerefDown.lean`, M5b): `SimRefDeref`'s `lift_refDeref` with downcasts among the
projections after the deref.

L0: `runOn_foldlM_downcast_al` is `SimDeref.runOn_foldlM_fields_al` (any alignment flag, the
address bound) with `SimEnum.runOn_foldlM_downcast`'s downcast case (the place unchanged, the
type the variant's field tuple); `runOn_evalPlace_derefDown` and `assign_refDerefDown_inv` are
`runOn_evalPlace_deref` and `assign_refDeref_inv` with it. R and the rest are `lift_refDeref`'s
(`refDeref_rstep`).
-/
import Ryo.Proofs.Lower.SimRefDeref
import Ryo.Proofs.Lower.SimEnum
import Ryo.Check.Lower.RefDerefDown

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### L0 -/

/-- `runOn_foldlM_fields_al` over field and downcast projections (`downcastPath`). -/
theorem runOn_foldlM_downcast_al {o : Spec.Oracle}
    {F : Spec.Place × Spec.Ty → ProjElem → SemM (Spec.Place × Spec.Ty)} (projs : List ProjElem) :
    ∀ {q : ThinPointer} {al : Bool} {t ty : Spec.Ty} {off : Nat} {s s1 : Spec.State}
      {r : Spec.Place × Spec.Ty},
    downcastPath t projs = some (off, ty) →
    runOn (projs.foldlM F (⟨q.widen, al⟩, t)) o s = (.ok r, s1) →
    (∀ x e, F x e = projectPlace x.1 x.2 e) →
    r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩, ty) ∧ s1 = s ∧
      (q.addr < Target.ADDR_LIMIT → q.addr + off < Target.ADDR_LIMIT) := by
  induction projs with
  | nil =>
    intro q al t ty off s s1 r hp h _
    simp only [downcastPath, Option.some.injEq, Prod.mk.injEq] at hp
    obtain ⟨rfl, rfl⟩ := hp
    rw [List.foldlM_nil, runOn_pure] at h
    obtain ⟨hr, hs⟩ := prod_ok_inj h
    exact ⟨by rw [← hr, Nat.add_zero], hs.symm, fun hq => by omega⟩
  | cons e ps ih =>
    intro q al t ty off s s1 r hp h hF
    cases e
    case field fi ann =>
      simp only [downcastPath] at hp
      split at hp
      next o1 fty hfo =>
        split at hp
        next o2 t2 hps =>
          simp only [Option.some.injEq, Prod.mk.injEq] at hp
          obtain ⟨rfl, rfl⟩ := hp
          rw [List.foldlM_cons] at h
          obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok h
          simp only [hF] at h1
          obtain ⟨rfl, hs2, hlt1⟩ := runOn_projectPlace_field_al hfo h1
          obtain ⟨hr, hs1, hb⟩ := ih hps h2 hF
          refine ⟨by rw [hr, Nat.add_assoc], by rw [hs1, hs2], fun _ => ?_⟩
          have e1 : (⟨q.addr + o1, q.prov⟩ : ThinPointer).addr = q.addr + o1 := rfl
          have hb1 := hb hlt1
          omega
        · cases hp
      · cases hp
    case downcast v =>
      cases t
      case enum vs dt rp sz al' =>
        simp only [downcastPath] at hp
        split at hp
        next var hvar =>
          rw [List.foldlM_cons] at h
          obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok h
          simp only [hF] at h1
          have e : projectPlace ⟨q.widen, al⟩ (.enum vs dt rp sz al') (.downcast v) =
              pure (⟨q.widen, al⟩, var.fields) := by
            first
              | (simp only [projectPlace, hvar]; done)
              | (simp only [projectPlace, hvar]; rfl)
              | simp [projectPlace, hvar]
          rw [e, runOn_pure] at h1
          obtain ⟨rfl, rfl⟩ := prod_ok_inj h1
          exact ih hp h2 hF
        · cases hp
      all_goals first | (simp [downcastPath] at hp; done) | cases hp
    all_goals first | (simp [downcastPath] at hp; done) | cases hp

/-- `runOn_evalPlace_deref` with `downcastPath`. -/
theorem runOn_evalPlace_derefDown {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p : Local} {pointee ty : Spec.Ty}
    {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off : Nat}
    {r : Spec.Place × Spec.Ty}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
    (hpath : downcastPath pointee fields = some (off, ty))
    (h : runOn (evalPlace ⟨p, .deref pointee :: fields⟩) o s = (.ok r, s1)) :
    ∃ pp bp q al, f.locals[p]? = some (some pp) ∧ s.mem.load pp 8 .one = .ok bp ∧
      decodePtr bp = some q ∧ q.addr + off < Target.ADDR_LIMIT ∧
      r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩, ty) ∧ s1 = s := by
  have e : evalPlace ⟨p, .deref pointee :: fields⟩ = (localPlace p >>= fun init =>
      (ProjElem.deref pointee :: fields).foldlM (fun (pl, ty) pe => projectPlace pl ty pe)
        init) := rfl
  rw [e] at h
  obtain ⟨init, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pp, tp, hpp, htp', hinit, hs2⟩ := runOn_localPlace_ok hs h1
  subst hinit
  have e2 : tp = .ptr pt valid := Option.some.inj (htp'.symm.trans htp)
  subst e2
  rw [hs2, List.foldlM_cons] at h2
  obtain ⟨x, s3, h3, h4⟩ := runOn_bind_ok h2
  have h3' : runOn (projectPlace ⟨pp.widen, true⟩ (.ptr pt valid) (.deref pointee)) o s =
      (.ok x, s3) := h3
  obtain ⟨bp, q, al, hlp, hq, rfl, hs3⟩ := runOn_projectPlace_deref hk h3'
  rw [hs3] at h4
  obtain ⟨hr, hs1, hb⟩ := runOn_foldlM_downcast_al fields hpath h4 (fun ⟨_, _⟩ _ => rfl)
  have hl8 : bp.length = 8 := load_length hlp
  exact ⟨pp, bp, q, al, hpp, hlp, hq, hb (decodePtr_addr_lt hq hl8), hr, hs1⟩

/-- `assign_refDeref_inv` with `downcastPath` (`runOn_evalPlace_derefDown`). -/
theorem assign_refDerefDown_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p : Local} {rv : Rvalue}
    {pointee ty : Spec.Ty} {fields : List ProjElem} {off : Nat} {pt ptd : PtrType}
    {valid vd : ValidRange}
    (hrv : refPlace? rv = some ⟨p, .deref pointee :: fields⟩)
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
    (hpath : downcastPath pointee fields = some (off, ty))
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    ∃ pd pp bp q, f.locals[d]? = some (some pd) ∧ f.locals[p]? = some (some pp) ∧
      s.mem.load pp 8 .one = .ok bp ∧ decodePtr bp = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.store pd (encodePtr ⟨q.addr + off, q.prov⟩) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  have e : evalStatement (.assign ⟨d, []⟩ rv) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue rv ty >>= fun v => placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd', hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue rv td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have hE : ∃ chk, evalRvalue rv td = addrOf ⟨p, .deref pointee :: fields⟩ td chk := by
    cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv
    all_goals subst hrv
    all_goals first
      | exact ⟨true, rfl⟩
      | exact ⟨false, rfl⟩
      | (refine ⟨true, ?_⟩; unfold evalRvalue; rfl)
      | (refine ⟨false, ?_⟩; unfold evalRvalue; rfl)
      | (refine ⟨true, ?_⟩; simp only [evalRvalue]; done)
      | (refine ⟨false, ?_⟩; simp only [evalRvalue]; done)
  obtain ⟨chk, hE⟩ := hE
  rw [hE] at h3
  have e3 : runOn (addrOf ⟨p, .deref pointee :: fields⟩ td chk) o s =
      runOn (evalPlace ⟨p, .deref pointee :: fields⟩ >>= fun x =>
        if chk then (SemM.getMem >>= fun m => SemM.liftE (checkValue m (.ptr x.1.ptr) td) >>=
          fun _ => pure (Value.ptr x.1.ptr)) else pure (Value.ptr x.1.ptr)) o s := by
    cases chk <;> first | rfl | (unfold addrOf; rfl) | (simp only [addrOf]; rfl)
  rw [e3] at h3
  obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pp, bp, q, al, hpp, hlp, hq, hlim, hr, hs3⟩ :=
    runOn_evalPlace_derefDown hs htp hk hpath h5
  subst hr
  rw [hs3] at h6
  have hv : v = .ptr (⟨q.addr + off, q.prov⟩ : ThinPointer).widen ∧ s2 = s := by
    cases chk with
    | false =>
      have h6' : runOn (pure (Value.ptr (⟨q.addr + off, q.prov⟩ : ThinPointer).widen) :
          SemM Value) o s = (.ok v, s2) := h6
      rw [runOn_pure] at h6'
      obtain ⟨h7, h8⟩ := prod_ok_inj h6'
      exact ⟨h7.symm, h8.symm⟩
    | true =>
      have h6' : runOn (SemM.getMem >>= fun m => SemM.liftE (checkValue m
          (.ptr (⟨q.addr + off, q.prov⟩ : ThinPointer).widen) td) >>=
          fun _ => pure (Value.ptr (⟨q.addr + off, q.prov⟩ : ThinPointer).widen)) o s =
          (.ok v, s2) := h6
      obtain ⟨m, s4, h7, h8⟩ := runOn_bind_ok h6'
      rw [runOn_getMem] at h7
      obtain ⟨-, hs4⟩ := prod_ok_inj h7
      rw [← hs4] at h8
      obtain ⟨u, s5, h9, h10⟩ := runOn_bind_ok h8
      obtain ⟨-, hs5⟩ := runOn_liftE_ok h9
      rw [hs5] at h10
      rw [runOn_pure] at h10
      obtain ⟨h11, h12⟩ := prod_ok_inj h10
      exact ⟨h11.symm, h12.symm⟩
  obtain ⟨hv1, hv2⟩ := hv
  subst hv1
  rw [hv2] at h4
  obtain ⟨mem', hst, rfl⟩ := runOn_placeStore_ok h4
  obtain ⟨bs, hen, hsto⟩ := typedStore_inv hst
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  subst e4
  have hbs : bs = encodePtr ⟨q.addr + off, q.prov⟩ := by
    simp [Spec.Ty.encode, hkd, ThinPointer.widen] at hen
    first | exact hen.symm | exact hen
  subst hbs
  exact ⟨pd, pp, bp, q, hld, hpp, hlp, hq, hlim, hsto, rfl⟩

/-! ### The lift -/

/-- `LowerRefDerefDown`'s lift (`lift_refDeref`'s proof with `assign_refDerefDown_inv`). -/
theorem lift_refDerefDown {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerRefDerefDown Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : Ryo.Proofs.Provenance.LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @mk d p rv pointee ty fields pt ptd valid vd off sd sp i hrv htpΓ hk hpath htdΓ hkd hsd hsp
      hsize hoff hri =>
    have htp : f.body.locals[p]? = some (.ptr pt valid) := by rw [← hbody]; exact htpΓ
    have htd : f.body.locals[d]? = some (.ptr ptd vd) := by rw [← hbody]; exact htdΓ
    obtain ⟨pd, pp, bp, q, hpd, hpp, hlp, hq, hlim, hsto, hstk⟩ :=
      assign_refDerefDown_inv hs hrv htp hk hpath htd hkd h
    have hlp' : live p = true := hlo p (by
      cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv <;>
        (subst hrv; simp [rvalueLocals, placeLocals]))
    have hrp := hrel.opnd hpp hsp hlp'
    obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hrel.frame.mem hrp
      (show s.mem.load pp sp.size .one = .ok bp by rw [hsize.2]; exact hlp)
    rw [hsize.2] at hrfp
    have hpos8 : 0 < sd.size := by omega
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hlen0 : (encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer)).length = sd.size := by
      rw [Ryo.Spec.Theorems.encodePtr_length, hsize.1]
    have hW := hrel.dstWrite hld hpd hsd hpos8 hlen0 hsto
    obtain ⟨st', hstep, hesc, hmi, hrd, hoth⟩ := refDeref_rstep (ch := ch) hmode hρ hi hsc
      hpe hpl hri hf1 hf2 hrfp hbp hq (load_length hlp) hlim hW
    have hsub := encodePtr_sub hq off
    have hhid' : ∀ b ∈ encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer), ∀ fr,
        b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hrel.hidden.load hlp _ (List.getElem_mem hj) fr0 hf0
    have hbd' : BytesBounded s.mem.allocs.size
        (encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer)) := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hpb.load hlp _ (List.getElem_mem hj) fr0 hf0
    exact ⟨st', hstep, hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlp hsub⟩

/-- `LowerRefDerefDown` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_cmpX`). -/
theorem stmt_sim_refDerefDown {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerRefDerefDown Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h
    exact ⟨_, _, _, rfl, rfl⟩
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
    (lift_refDerefDown M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb
      M.dinv.2 hl2 hl1 hev)

end Ryo.Proofs.Lower
