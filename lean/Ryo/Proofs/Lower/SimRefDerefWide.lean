/-
Ryo.Proofs.Lower.SimRefDerefWide — the lift of `LowerRefDerefWide`
(`Check/Lower/RefDerefWide.lean`, M5b's places): `_d = &(*_p)` / `&raw (*_p)` for a wide pointer
`_p`, lowered to `mov` pieces copying `_p`'s 16 bytes into `_d`'s private slot, simulated by
`SimAgg.lift_aggMem` as a one-field copy.

The rule states R's side as `Agg.lean`'s field (`AggField` of `copy _p`, `piecesOk` of its
`srcPieces`), so all that is left is L0's (`refDerefWide_mem`, giving `AggMem`):
- the place (`runOn_evalPlace_derefWide`, the wide analogue of `SimDeref.runOn_evalPlace_deref`
  without fields): `_p`'s 16 bytes `bs` decode at `_p`'s type to `.ptr pv`, metadata included
  (`decode_ptr_wide_inv`), the `safePointee`/`sizeAlignOf` checks only read memory (`KeepPost`),
  and the place is `pv` with some alignment flag;
- `addrOf` returns `.ptr pv` (for `&`, `checkValue` keeps the state), stored at `_d`'s type,
  whose encoding is the one at `_p`'s (`encode_ptr_shape`), below `bs` (`reenc_wf`); over 16
  uninitialized bytes that is `writeFields` of the one field.
`lift_refDerefWide` hands it to `lift_aggMem`. The `field` rule (a sized field, a thin result)
is `SimRefDeref.lift_refDeref`'s with the data half of the 16 bytes: the field projection drops
the metadata (`projectPlace_field_thin`), so the place is the thin case's from the decoded data
pointer (`runOn_foldlM_fields_wide`, `runOn_evalPlace_derefWideF`); R reads the first 8 bytes
of `_p`'s slot (`load_sub_of_load`, `readLocal_sub_inj`) and `refDeref_rstep` writes `_d`; `stmt_sim_refDerefWide` is `FnStep.stmt_sim`'s
case (as `castMore`'s: `stmtOut_of_liftN` over the statement's range).
-/
import Ryo.Proofs.Lower.SimDeref
import Ryo.Proofs.Lower.SimWide
import Ryo.Proofs.Lower.SimAgg
import Ryo.Proofs.Lower.SimRefDeref
import Ryo.Check.Lower.RefDerefWide

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### L0: the place -/

/-- The deref projection of a wide pointer place, run to success: the place's 16 bytes decode to
the pointer `pv`, and the result is `pv` at the pointee type with some alignment flag, the state
unchanged (as `runOn_projectPlace_deref`). -/
theorem runOn_projectPlace_derefWide {o : Spec.Oracle} {s s1 : Spec.State} {pl : Spec.Place}
    {pt : PtrType} {valid : ValidRange} {pointee : Spec.Ty} {r : Spec.Place × Spec.Ty}
    (hk : pt.metaKind ≠ .none)
    (h : runOn (projectPlace pl (.ptr pt valid) (.deref pointee)) o s = (.ok r, s1)) :
    ∃ bs pv al, s.mem.load pl.ptr.thin 16 .one = .ok bs ∧
      (Spec.Ty.ptr pt valid).decode bs = some (.ptr pv) ∧ bs.length = 16 ∧
      r = (⟨pv, al⟩, pointee) ∧ s1 = s := by
  try simp only [projectPlace] at h
  obtain ⟨v, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨hv, hs2⟩ := runOn_placeLoad_ok h1
  obtain ⟨bs, hlp, hd⟩ := typedLoad_inv (size?_ptr_wide hk) hv
  obtain ⟨pv, hlen, -, rfl, -⟩ := decode_ptr_wide_inv hk hd
  rw [hs2] at h2
  obtain ⟨hs1, al, hr⟩ := KeepPost.run
    (P := fun r : Spec.Place × Spec.Ty => ∃ al, r = (⟨pv, al⟩, pointee)) h2 (by
      repeat
        first
          | exact KeepPost.getMem'
          | exact KeepPost.liftE'
          | exact KeepPost.sizeAlignOf'
          | exact KeepPost.throwUb'
          | exact KeepPost.throwIllFormed'
          | exact KeepPost.pure' trivial
          | exact KeepPost.pure' ⟨_, rfl⟩
          | apply KeepPost.bind'
          | intro _
          | dsimp only
          | split)
  exact ⟨bs, pv, al, hlp, hd, hlen, hr, hs1⟩

/-- The place `*_p` for a wide pointer local `_p`: `_p`'s 16 bytes decode to `pv`, the place is
`pv` at the pointee type, the state unchanged.

Proof: as `runOn_evalPlace_deref`: `localPlace p` (`runOn_localPlace_ok`), then the one deref
projection (`runOn_projectPlace_derefWide`); the fold's rest is `pure` (`runOn_pure_inv`). -/
theorem runOn_evalPlace_derefWide {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p : Local} {pointee : Spec.Ty}
    {pt : PtrType} {valid : ValidRange} {r : Spec.Place × Spec.Ty}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (h : runOn (evalPlace ⟨p, [.deref pointee]⟩) o s = (.ok r, s1)) :
    ∃ pp bs pv al, f.locals[p]? = some (some pp) ∧ s.mem.load pp 16 .one = .ok bs ∧
      (Spec.Ty.ptr pt valid).decode bs = some (.ptr pv) ∧ bs.length = 16 ∧
      r = (⟨pv, al⟩, pointee) ∧ s1 = s := by
  have e : evalPlace ⟨p, [.deref pointee]⟩ = (localPlace p >>= fun init =>
      [ProjElem.deref pointee].foldlM (fun (pl, ty) pe => projectPlace pl ty pe) init) := rfl
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
  obtain ⟨bs, pv, al, hlp, hd, hlen, rfl, hs3⟩ := runOn_projectPlace_derefWide hk h3'
  rw [hs3] at h4
  have h4' : runOn (pure ((⟨pv, al⟩, pointee) : Spec.Place × Spec.Ty) :
      SemM (Spec.Place × Spec.Ty)) o s = (.ok r, s1) := h4
  obtain ⟨hr, hs1⟩ := runOn_pure_inv h4'
  exact ⟨pp, bs, pv, al, hpp, hlp, hd, hlen, hr, hs1⟩

/-! ### L0: the statement -/

/-- L0's `_d = &(*_p)` / `&raw (*_p)` for a wide pointer `_p`, as `AggMem` of the one field
copied from `_p` (`ws` the copy's pieces).

Proof: as `assign_refDeref_inv`: `evalStatement`'s `assign` binds `evalPlace ⟨d, []⟩`
(`runOn_localPlace_ok`) and `evalRvalue`, which is `addrOf ⟨p, [.deref pointee]⟩ _ chk`;
`runOn_evalPlace_derefWide` gives the place `pv` and the state unchanged, `checkValue` (for `&`)
keeps it (`runOn_liftE_ok`); `placeStore` at `.ptr ptd vd` is `typedStore` (`typedStore_inv`),
whose encoding is the one at `_p`'s type (`encode_ptr_shape`), below `bs` (`reenc_wf`, 16 bytes);
written over 16 uninitialized bytes at offset 0 it is itself (`writeAt`). -/
theorem refDerefWide_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p : Local} {rv : Rvalue}
    {pointee : Spec.Ty} {pt ptd : PtrType} {valid vd : ValidRange} {so : Int} {ws : List Nat}
    (hrv : refPlace? rv = some ⟨p, [.deref pointee]⟩)
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (htd : f.body.locals[d]? = some (.ptr ptd vd))
    (hshape : sameMetaShape ptd.metaKind pt.metaKind = true)
    (hwf : (Spec.Ty.ptr pt valid).wf = true) (hws : ws.sum = 16)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    AggMem f d 16 [(0, .ptr pt valid)] [.slot p so ws] s s' := by
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
  -- the rvalue is `addrOf ⟨p, [.deref pointee]⟩ td chk`
  have hE : ∃ chk, evalRvalue rv td = addrOf ⟨p, [.deref pointee]⟩ td chk := by
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
  -- `addrOf`: the place, then (for `&`) `checkValue`, which keeps the state
  have e3 : runOn (addrOf ⟨p, [.deref pointee]⟩ td chk) o s =
      runOn (evalPlace ⟨p, [.deref pointee]⟩ >>= fun x =>
        if chk then (SemM.getMem >>= fun m => SemM.liftE (checkValue m (.ptr x.1.ptr) td) >>=
          fun _ => pure (Value.ptr x.1.ptr)) else pure (Value.ptr x.1.ptr)) o s := by
    cases chk <;> first | rfl | (unfold addrOf; rfl) | (simp only [addrOf]; rfl)
  rw [e3] at h3
  obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pp, bs, pv, al, hpp, hlp, hd, hlen, hr, hs3⟩ := runOn_evalPlace_derefWide hs htp hk h5
  subst hr
  rw [hs3] at h6
  have hv : v = .ptr pv ∧ s2 = s := by
    cases chk with
    | false =>
      have h6' : runOn (pure (Value.ptr pv) : SemM Value) o s = (.ok v, s2) := h6
      rw [runOn_pure] at h6'
      obtain ⟨h7, h8⟩ := prod_ok_inj h6'
      exact ⟨h7.symm, h8.symm⟩
    | true =>
      have h6' : runOn (SemM.getMem >>= fun m => SemM.liftE (checkValue m (.ptr pv) td) >>=
          fun _ => pure (Value.ptr pv)) o s = (.ok v, s2) := h6
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
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  subst e4
  rw [encode_ptr_shape hshape] at hen
  have hle : bytesLeDefined bsd bs = true := reenc_wf hwf (size?_ptr_wide hk) hlen hd hen
  have hbl : bsd.length = 16 := ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans hlen
  have hw' : writeFields (List.replicate 16 AbstractByte.uninit)
      ((([(0, Spec.Ty.ptr pt valid)] : List (Nat × Spec.Ty)).map (·.1)).zip [bsd]) = bsd := by
    show writeAt _ 0 bsd = bsd
    simp [writeAt, hbl]
  refine ⟨pd, [bsd], hld, rfl, rfl, ?_, ?_, ?_, rfl⟩
  · intro j h1 h2
    cases j with
    | zero =>
      show ∃ pa bs0, f.locals[p]? = some (some pa) ∧ s.mem.load pa ws.sum .one = .ok bs0 ∧
        bytesLeDefined bsd bs0 = true
      rw [hws]
      exact ⟨pp, bs, hpp, hlp, hle⟩
    | succ j => simp at h1
  · intro j h1 h2
    cases j with
    | zero => show 0 + bsd.length ≤ 16; omega
    | succ j => simp at h1
  · rw [hw']
    exact hsto

/-! ### L0: sized fields of a wide pointer's pointee -/

/-- A sized field projection reads only the place's thin part (and drops its metadata). -/
theorem projectPlace_field_thin {pv : Pointer} {al : Bool} {t : Spec.Ty} {f : Nat}
    {ann : Spec.Ty} {o : Nat} {fty : Spec.Ty} (hfo : fieldOf t f = some (o, fty)) :
    projectPlace ⟨pv, al⟩ t (.field f ann) = projectPlace ⟨pv.thin.widen, al⟩ t (.field f ann) := by
  cases t
  all_goals first
    | (simp [fieldOf] at hfo; done)
    | (simp only [fieldOf] at hfo; simp only [projectPlace, hfo]; done)
    | (simp only [fieldOf] at hfo; unfold projectPlace; simp only [hfo]; rfl)

/-- Field projections from a place with metadata: as from its thin part. -/
theorem runOn_foldlM_fields_wide {o : Spec.Oracle}
    {F : Spec.Place × Spec.Ty → ProjElem → SemM (Spec.Place × Spec.Ty)}
    (hF : ∀ x e, F x e = projectPlace x.1 x.2 e) {pv : Pointer} {al : Bool} {t ty : Spec.Ty}
    {fe : ProjElem} {fields : List ProjElem} {off : Nat} {s s1 : Spec.State}
    {r : Spec.Place × Spec.Ty} (hp : fieldPath t (fe :: fields) = some (off, ty))
    (h : runOn ((fe :: fields).foldlM F (⟨pv, al⟩, t)) o s = (.ok r, s1)) :
    r = (⟨(⟨pv.thin.addr + off, pv.thin.prov⟩ : ThinPointer).widen, al⟩, ty) ∧ s1 = s ∧
      (pv.thin.addr < Target.ADDR_LIMIT → pv.thin.addr + off < Target.ADDR_LIMIT) := by
  cases fe with
  | field f ann =>
    have hfo : ∃ o' fty, fieldOf t f = some (o', fty) := by
      simp only [fieldPath] at hp
      split at hp
      next o' fty hfo => exact ⟨o', fty, hfo⟩
      · cases hp
    obtain ⟨o', fty, hfo⟩ := hfo
    have e : (ProjElem.field f ann :: fields).foldlM F ((⟨pv, al⟩ : Spec.Place), t) =
        (ProjElem.field f ann :: fields).foldlM F ((⟨pv.thin.widen, al⟩ : Spec.Place), t) := by
      simp only [List.foldlM_cons, hF]
      rw [projectPlace_field_thin hfo]
    rw [e] at h
    exact runOn_foldlM_fields_al (.field f ann :: fields) hp h hF
  | _ => simp [fieldPath] at hp

/-- The place `(*_p).fields` for a wide pointer local `_p` and sized fields: the data pointer
(the first 8 of `_p`'s 16 bytes) offset by the fields, without metadata. -/
theorem runOn_evalPlace_derefWideF {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p : Local} {pointee ty : Spec.Ty}
    {fe : ProjElem} {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off : Nat}
    {r : Spec.Place × Spec.Ty}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (hpath : fieldPath pointee (fe :: fields) = some (off, ty))
    (h : runOn (evalPlace ⟨p, .deref pointee :: fe :: fields⟩) o s = (.ok r, s1)) :
    ∃ pp bs q al, f.locals[p]? = some (some pp) ∧ s.mem.load pp 16 .one = .ok bs ∧
      bs.length = 16 ∧ decodePtr (bs.take 8) = some q ∧ q.addr + off < Target.ADDR_LIMIT ∧
      r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩, ty) ∧ s1 = s := by
  have e : evalPlace ⟨p, .deref pointee :: fe :: fields⟩ = (localPlace p >>= fun init =>
      (ProjElem.deref pointee :: fe :: fields).foldlM (fun (pl, ty) pe => projectPlace pl ty pe)
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
  obtain ⟨bs, pv, al, hlp, hd, hlen, rfl, hs3⟩ := runOn_projectPlace_derefWide hk h3'
  rw [hs3] at h4
  have h4' : runOn ((fe :: fields).foldlM (fun (pl, ty) pe => projectPlace pl ty pe)
      ((⟨pv, al⟩ : Spec.Place), pointee)) o s = (.ok r, s1) := h4
  obtain ⟨hr, hs1, hb⟩ := runOn_foldlM_fields_wide (fun ⟨_, _⟩ _ => rfl) hpath h4'
  obtain ⟨pv', -, hdp, hv, -⟩ := decode_ptr_wide_inv hk hd
  have e3 : pv' = pv := by injection hv with e; exact e.symm
  rw [e3] at hdp
  have hl8 : (bs.take 8).length = 8 := by simp [hlen]
  exact ⟨pp, bs, pv.thin, al, hpp, hlp, hlen, hdp, hb (decodePtr_addr_lt hdp hl8), hr, hs1⟩

/-- L0's `_d = &(*_p).fields` / `&raw …` for a wide `_p` and sized fields into a thin pointer
local (`assign_refDeref_inv` with `runOn_evalPlace_derefWideF`). -/
theorem assign_refDerefWideF_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p : Local} {rv : Rvalue}
    {pointee ty : Spec.Ty} {fe : ProjElem} {fields : List ProjElem} {off : Nat}
    {pt ptd : PtrType} {valid vd : ValidRange}
    (hrv : refPlace? rv = some ⟨p, .deref pointee :: fe :: fields⟩)
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (hpath : fieldPath pointee (fe :: fields) = some (off, ty))
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    ∃ pd pp bs q, f.locals[d]? = some (some pd) ∧ f.locals[p]? = some (some pp) ∧
      s.mem.load pp 16 .one = .ok bs ∧ bs.length = 16 ∧ decodePtr (bs.take 8) = some q ∧
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
  have hE : ∃ chk, evalRvalue rv td = addrOf ⟨p, .deref pointee :: fe :: fields⟩ td chk := by
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
  have e3 : runOn (addrOf ⟨p, .deref pointee :: fe :: fields⟩ td chk) o s =
      runOn (evalPlace ⟨p, .deref pointee :: fe :: fields⟩ >>= fun x =>
        if chk then (SemM.getMem >>= fun m => SemM.liftE (checkValue m (.ptr x.1.ptr) td) >>=
          fun _ => pure (Value.ptr x.1.ptr)) else pure (Value.ptr x.1.ptr)) o s := by
    cases chk <;> first | rfl | (unfold addrOf; rfl) | (simp only [addrOf]; rfl)
  rw [e3] at h3
  obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pp, bs, q, al, hpp, hlp, hlen, hq, hlim, hr, hs3⟩ :=
    runOn_evalPlace_derefWideF hs htp hk hpath h5
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
  obtain ⟨bs', hen, hsto⟩ := typedStore_inv hst
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  subst e4
  have hbs : bs' = encodePtr ⟨q.addr + off, q.prov⟩ := by
    simp [Spec.Ty.encode, hkd, ThinPointer.widen] at hen
    first | exact hen.symm | exact hen
  subst hbs
  exact ⟨pd, pp, bs, q, hld, hpp, hlp, hlen, hq, hlim, hsto, rfl⟩

/-- The `field` rule's lift (`lift_refDeref` with the data half of `_p`'s slot). -/
theorem lift_refDerefWideField {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d p : Local} {rv : Rvalue} {pointee ty : Spec.Ty} {fe : ProjElem} {fields : List ProjElem}
    {pt ptd : PtrType} {valid vd : ValidRange} {off : Nat} {sd sp : LocalSlot} {i : R.Insn}
    (hrv : refPlace? rv = some ⟨p, .deref pointee :: fe :: fields⟩)
    (htpΓ : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (hpath : fieldPath pointee (fe :: fields) = some (off, ty))
    (htdΓ : Γ.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
    (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp)
    (hsize : sd.size = 8 ∧ sp.size = 16) (hoff : offOk sd.off ∧ offOk sp.off)
    (hri : refDerefInsnOk Γ i sd.off sp.off off = true)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  have htp : f.body.locals[p]? = some (.ptr pt valid) := by rw [← hbody]; exact htpΓ
  have htd : f.body.locals[d]? = some (.ptr ptd vd) := by rw [← hbody]; exact htdΓ
  obtain ⟨pd, pp, bs, q, hpd, hpp, hlp, hlen, hq, hlim, hsto, hstk⟩ :=
    assign_refDerefWideF_inv hs hrv htp hk hpath htd hkd h
  have hlp' : live p = true := hlo p (by
    cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv <;>
      (subst hrv; simp [rvalueLocals, placeLocals]))
  have hrp := hrel.opnd hpp hsp hlp'
  have hlp8 : s.mem.load ⟨pp.addr + 0, pp.prov⟩ 8 .one = .ok ((bs.drop 0).take 8) :=
    load_sub_of_load (j := 0) (k := 8) hlp (by omega) (by omega)
  rw [List.drop_zero] at hlp8
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_sub_inj hrel.frame.mem hrp
    (show 0 + 8 ≤ sp.size by rw [hsize.2]; omega) hlp8
  have hrfp' : s1.st.readFrame sp.off 8 = .ok bp1 := by simpa using hrfp
  have hl8 : (bs.take 8).length = 8 := by simp [hlen]
  have hpos8 : 0 < sd.size := by omega
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  have hlen0 : (encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer)).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodePtr_length, hsize.1]
  have hW := hrel.dstWrite hld hpd hsd hpos8 hlen0 hsto
  obtain ⟨st', hstep, hesc, hmi, hrd, hoth⟩ := refDeref_rstep (ch := ch) hmode hρ hi hsc
    hpe hpl hri hf1 hf2 hrfp' hbp hq hl8 hlim hW
  have hsub := encodePtr_sub hq off
  have hhid' : ∀ b ∈ encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer), ∀ fr,
      b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hrel.hidden.load hlp8 _ (List.getElem_mem hj) fr0 hf0
  have hbd' : BytesBounded s.mem.allocs.size (encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer)) := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hpb.load hlp8 _ (List.getElem_mem hj) fr0 hf0
  exact ⟨st', hstep, hstk,
    hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlp8 hsub⟩

/-! ### The lift -/

/-- `LowerRefDerefWide`'s lift: R runs the statement's `is.length` `mov` pieces.

Proof: `cases hlow`, then `cases` on the copy's `AggField` (only `slot` has a `.slot` source):
its local is `_p` (`Operand.local?`), its pieces sum to `_p`'s 16 bytes (`size?_ptr_wide`).
`refDerefWide_mem` (types through `hbody`) gives `AggMem`; `lift_aggMem` with the one field
(`aggPieces_single`), whose one `.slot` source `_p` is read by the rvalue (`rvalueLocals`), so
live by `hlo`. -/
theorem lift_refDerefWide {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerRefDerefWide Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @field d p rv pointee ty fe fields pt ptd valid vd off sd sp i is hrv htp hk hpath htd hkd
      hsd hsp hsize hoff his hri =>
    subst his
    have hi0 : c.d.insns[s1.pc]? = some i := by simpa using hi 0 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    exact liftOutN_of_lift (lift_refDerefWideField hs hbody hmode hρ hrv htp hk hpath htd hkd
      hsd hsp hsize hoff hri hi0 hsc0 hpe (hpl i (by simp)) hrel hpb hld hlo hlive' h)
  | @mk d p rv pointee pt ptd valid vd sd a so ws is hrv htpΓ hk htdΓ hshape hsd hsz hoff hpriv
      hf hpo =>
    have htp : f.body.locals[p]? = some (.ptr pt valid) := by rw [← hbody]; exact htpΓ
    have htd : f.body.locals[d]? = some (.ptr ptd vd) := by rw [← hbody]; exact htdΓ
    have hlp' : live p = true := hlo p (by
      cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv <;>
        (subst hrv; simp [rvalueLocals, placeLocals]))
    -- the copy's facts; `cases` may rename `a`, `so`, `ws`, so they are not named below
    have hf' := hf
    cases hf' with
    | slot ha _ hwf hn _ _ _ _ hws _ _ =>
      simp only [Operand.local?, Option.some.injEq] at ha
      subst ha
      rw [size?_ptr_wide hk, Option.some.injEq] at hn
      subst hn
      refine lift_aggMem hmode hρ hsd hoff hpriv (AggFields.cons hf AggFields.nil)
        (by rw [aggPieces_single]; exact hpo) hi hsc hpe hpl hrel hpb ?_ hlive'
        (by rw [hsz]; exact refDerefWide_mem hs hrv htp hk htd hshape hwf hws h)
      intro src hsrc a' so' ws' he
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hsrc
      subst hsrc
      cases he
      exact hlp'

/-- `LowerRefDerefWide` in a scope-free function: `stmt_sim`'s case (as its `castMore` case). -/
theorem stmt_sim_refDerefWide {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerRefDerefWide Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
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
  exact lift_refDerefWide M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    M.dinv.2 hl2 hl1 hev

end Ryo.Proofs.Lower
