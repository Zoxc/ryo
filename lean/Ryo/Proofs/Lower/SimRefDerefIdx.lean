/-
Ryo.Proofs.Lower.SimRefDerefIdx — the simulation of `LowerRefDerefIdx`
(`Check/Lower/RefDerefIdx.lean`, M5b): `_d = &(*_p)[_i]` / `&raw (*_p)[_i]` for a slice pointer
`_p`, lowered to `ptr.index t, p, i, stride` into a private temporary and `mov.w64 d, t`.

L0 (`assign_refDerefIdx_inv`): `_p`'s 16 bytes load (`runOn_projectPlace_derefWide`), their
first 8 decode to the data pointer `q`; the index projection (`runOn_projectPlace_indexSlice`)
reads `_i` (`readIndexLocal`: a `usize`, its 8 bytes decode to `u`, the index is `u % 2^64`),
the slice length from the place's metadata (`elemsOf`), and offsets in bounds by
`(u % 2^64) * elem.size` (`runOn_offset_place_al`: below `ADDR_LIMIT`); the address's encoding
is stored into `_d`.

R: `ptr.index` reads the data pointer (`widePtr_read`, `decodePtr_inj`: `q1`) and `_i`'s 8 bytes
(`readLocal_inj`, `decodeBits_inj`: `u`), and writes `encodePtr (q1.wrappingOffset ((u * stride)
% 2^64))` into the temporary (`SimOffset.opSem_ptrIndex_fwd`; private, `FnRel.tempWrite`); its
address is L0's (`wrappingOffset_addr`, the offsets agreeing below `2^64`). `mov.w64 d, t` reads it back
(`readFrame_after_write`) and writes `_d` through `DstWrite` (`encodePtr_inj'`). `Hidden`,
`ProvBounded`, `MemKept` as `lift_refDerefWideField` (the stored provenance is `_p`'s data
pointer's).
-/
import Ryo.Proofs.Lower.SimDerefWide
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Proofs.Lower.SimOffset
import Ryo.Check.Lower.RefDerefIdx

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### L0 -/

theorem ofBits_usize (u : Nat) : IntType.usize.ofBits u = ((u % 2 ^ 64 : Nat) : Int) := by
  unfold IntType.ofBits
  simp [IntType.usize, IntType.modulus, IntType.bits]

/-- The `.index` projection of a slice place, run to success: `_i` (a `usize` local) loads its 8
bytes, which decode to `u`, and the place is the pointer offset in bounds by
`(u % 2^64) * elem.size`, the state unchanged. -/
theorem runOn_projectPlace_indexSlice {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {l : Local} {vi : ValidRange}
    (hti : f.body.locals[l]? = some (.int IntType.usize vi)) {pv : Pointer} {al : Bool}
    {elem : Spec.Ty} {y : Spec.Place × Spec.Ty}
    (h : runOn (projectPlace ⟨pv, al⟩ (.slice elem) (.index l)) o s = (.ok y, s1)) :
    ∃ pl bi u, f.locals[l]? = some (some pl) ∧ s.mem.load pl 8 .one = .ok bi ∧
      decodeBits bi = some u ∧
      pv.thin.addr + (u % 2 ^ 64) * elem.size < Target.ADDR_LIMIT ∧
      y = (⟨(⟨pv.thin.addr + (u % 2 ^ 64) * elem.size, pv.thin.prov⟩ : ThinPointer).widen, al⟩,
        elem) ∧ s1 = s := by
  simp only [projectPlace] at h
  obtain ⟨i, s2, hri, h2⟩ := runOn_bind_ok h
  -- `readIndexLocal`
  have hri' : runOn (readIndexLocal l) o s = (.ok i, s2) := hri
  unfold readIndexLocal at hri'
  obtain ⟨x0, s5, hlp0, h7⟩ := runOn_bind_ok hri'
  obtain ⟨pl, tl, hpl, htl, hx0, hs5⟩ := runOn_localPlace_ok hs hlp0
  subst hx0
  have etl : tl = .int IntType.usize vi := Option.some.inj (htl.symm.trans hti)
  subst etl
  rw [hs5] at h7
  obtain ⟨v0, s6, hpl0, h8⟩ := runOn_bind_ok h7
  obtain ⟨hv0, hs6⟩ := runOn_placeLoad_ok hpl0
  obtain ⟨bi, u, hlb, hdb, -, hv⟩ := typedLoad_int hv0
  subst hv
  rw [hs6] at h8
  rw [ofBits_usize] at h8
  have h8' : runOn (pure (((u % 2 ^ 64 : Nat) : Int)).toNat : SemM Nat) o s = (.ok i, s2) := by
    first
      | (simp only [ge_iff_le, Int.natCast_nonneg, ↓reduceIte] at h8; exact h8)
      | (rw [if_pos (Int.natCast_nonneg _)] at h8; exact h8)
      | (dsimp only at h8; rw [if_pos (Int.natCast_nonneg _)] at h8; exact h8)
      | (simp at h8 ⊢; exact h8)
  obtain ⟨hi, hs2⟩ := runOn_pure_inv h8'
  have hi' : i = u % 2 ^ 64 := by
    rw [hi]
    first
      | exact Int.toNat_natCast _
      | exact Int.toNat_ofNat _
      | omega
      | simp
  subst hi'
  rw [hs2] at h2
  -- `elemsOf`
  obtain ⟨x1, s7, hel, h9⟩ := runOn_bind_ok h2
  have hel' : runOn (elemsOf ⟨pv, al⟩ (.slice elem)) o s = (.ok x1, s7) := hel
  obtain ⟨n, hx1, hs7⟩ : ∃ n, x1 = (elem, n, true) ∧ s7 = s := by
    simp only [elemsOf] at hel'
    split at hel'
    next n _ =>
      obtain ⟨h10, h11⟩ := runOn_pure_inv hel'
      exact ⟨n, h10, h11⟩
    next =>
      rw [runOn_throwIllFormed] at hel'
      exact (prod_err_ok hel').elim
  subst hx1
  rw [hs7] at h9
  -- the bounds check, then the offset
  dsimp only at h9
  split at h9
  next =>
    obtain ⟨_, _, h10, -⟩ := runOn_bind_ok h9
    rw [runOn_throwUb] at h10
    exact (prod_err_ok h10).elim
  next =>
    try dsimp only at h9
    have h9' : runOn (ptrOffsetInbounds pv.thin (((u % 2 ^ 64) * elem.size : Nat) : Int) >>=
        fun q' => pure ((⟨q'.widen, al⟩ : Spec.Place), elem)) o s = (.ok y, s1) := by
      first
        | exact h9
        | (rw [Int.natCast_mul]; exact h9)
        | (simp only [Int.natCast_mul]; exact h9)
        | (simp only [pure_bind] at h9; exact h9)
        | (simp only [pure_bind] at h9; rw [Int.natCast_mul]; exact h9)
    obtain ⟨hy, hs1, hlt⟩ := runOn_offset_place_al h9'
    exact ⟨pl, bi, u, hpl, hlb, hdb, hlt, hy, hs1⟩

/-- The place `(*_p)[_i]` for a slice pointer local `_p`. -/
theorem runOn_evalPlace_derefWideIdx {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p l : Local} {elem : Spec.Ty}
    {pt : PtrType} {valid vi : ValidRange} {r : Spec.Place × Spec.Ty}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (hti : f.body.locals[l]? = some (.int IntType.usize vi))
    (h : runOn (evalPlace ⟨p, [.deref (.slice elem), .index l]⟩) o s = (.ok r, s1)) :
    ∃ pp bs q pl bi u al, f.locals[p]? = some (some pp) ∧ s.mem.load pp 16 .one = .ok bs ∧
      bs.length = 16 ∧ decodePtr (bs.take 8) = some q ∧ f.locals[l]? = some (some pl) ∧
      s.mem.load pl 8 .one = .ok bi ∧ decodeBits bi = some u ∧
      q.addr + (u % 2 ^ 64) * elem.size < Target.ADDR_LIMIT ∧
      r = (⟨(⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ : ThinPointer).widen, al⟩, elem) ∧
      s1 = s := by
  have e : evalPlace ⟨p, [.deref (.slice elem), .index l]⟩ = (localPlace p >>= fun init =>
      [ProjElem.deref (.slice elem), .index l].foldlM (fun (pl, ty) pe => projectPlace pl ty pe)
        init) := rfl
  rw [e] at h
  obtain ⟨init, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pp, tp, hpp, htp', hinit, hs2⟩ := runOn_localPlace_ok hs h1
  subst hinit
  have e2 : tp = .ptr pt valid := Option.some.inj (htp'.symm.trans htp)
  subst e2
  rw [hs2, List.foldlM_cons] at h2
  obtain ⟨x, s3, h3, h4⟩ := runOn_bind_ok h2
  have h3' : runOn (projectPlace ⟨pp.widen, true⟩ (.ptr pt valid) (.deref (.slice elem))) o s =
      (.ok x, s3) := h3
  obtain ⟨bs, pv, al, hlp, hd, hlen, rfl, hs3⟩ := runOn_projectPlace_derefWide hk h3'
  rw [hs3, List.foldlM_cons] at h4
  obtain ⟨y, s4, h5, h6⟩ := runOn_bind_ok h4
  have h5' : runOn (projectPlace ⟨pv, al⟩ (.slice elem) (.index l)) o s = (.ok y, s4) := h5
  obtain ⟨pl, bi, u, hpl, hlb, hdb, hlt, rfl, hs4⟩ := runOn_projectPlace_indexSlice hs hti h5'
  rw [hs4] at h6
  have h6' : runOn (pure ((⟨(⟨pv.thin.addr + (u % 2 ^ 64) * elem.size, pv.thin.prov⟩ :
      ThinPointer).widen, al⟩ : Spec.Place), elem) : SemM (Spec.Place × Spec.Ty)) o s =
      (.ok r, s1) := h6
  obtain ⟨hr, hs1⟩ := runOn_pure_inv h6'
  obtain ⟨pv', -, hdp, hv, -⟩ := decode_ptr_wide_inv hk hd
  have e3 : pv' = pv := by injection hv with e; exact e.symm
  rw [e3] at hdp
  exact ⟨pp, bs, pv.thin, pl, bi, u, al, hpp, hlp, hlen, hdp, hpl, hlb, hdb, hlt, hr, hs1⟩

/-- L0's `_d = &(*_p)[_i]` / `&raw …` (as `assign_refDerefWideF_inv`, with
`runOn_evalPlace_derefWideIdx`). -/
theorem assign_refDerefIdx_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p l : Local} {rv : Rvalue}
    {elem : Spec.Ty} {pt ptd : PtrType} {valid vd vi : ValidRange}
    (hrv : refPlace? rv = some ⟨p, [.deref (.slice elem), .index l]⟩)
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (hti : f.body.locals[l]? = some (.int IntType.usize vi))
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    ∃ pd pp bs q pl bi u, f.locals[d]? = some (some pd) ∧ f.locals[p]? = some (some pp) ∧
      s.mem.load pp 16 .one = .ok bs ∧ bs.length = 16 ∧ decodePtr (bs.take 8) = some q ∧
      f.locals[l]? = some (some pl) ∧ s.mem.load pl 8 .one = .ok bi ∧ decodeBits bi = some u ∧
      q.addr + (u % 2 ^ 64) * elem.size < Target.ADDR_LIMIT ∧
      s.mem.store pd (encodePtr ⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩) .one = .ok s'.mem ∧
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
  have hE : ∃ chk, evalRvalue rv td = addrOf ⟨p, [.deref (.slice elem), .index l]⟩ td chk := by
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
  have e3 : runOn (addrOf ⟨p, [.deref (.slice elem), .index l]⟩ td chk) o s =
      runOn (evalPlace ⟨p, [.deref (.slice elem), .index l]⟩ >>= fun x =>
        if chk then (SemM.getMem >>= fun m => SemM.liftE (checkValue m (.ptr x.1.ptr) td) >>=
          fun _ => pure (Value.ptr x.1.ptr)) else pure (Value.ptr x.1.ptr)) o s := by
    cases chk <;> first | rfl | (unfold addrOf; rfl) | (simp only [addrOf]; rfl)
  rw [e3] at h3
  obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pp, bs, q, pl, bi, u, al, hpp, hlp, hlen, hq, hpl, hlb, hdb, hlim, hr, hs3⟩ :=
    runOn_evalPlace_derefWideIdx hs htp hk hti h5
  subst hr
  rw [hs3] at h6
  have hv : v = .ptr (⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ : ThinPointer).widen ∧
      s2 = s := by
    cases chk with
    | false =>
      have h6' : runOn (pure (Value.ptr (⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ :
          ThinPointer).widen) : SemM Value) o s = (.ok v, s2) := h6
      rw [runOn_pure] at h6'
      obtain ⟨h7, h8⟩ := prod_ok_inj h6'
      exact ⟨h7.symm, h8.symm⟩
    | true =>
      have h6' : runOn (SemM.getMem >>= fun m => SemM.liftE (checkValue m
          (.ptr (⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ : ThinPointer).widen) td) >>=
          fun _ => pure (Value.ptr (⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ :
            ThinPointer).widen)) o s = (.ok v, s2) := h6
      obtain ⟨m, s4, h7, h8⟩ := runOn_bind_ok h6'
      rw [runOn_getMem] at h7
      obtain ⟨-, hs4⟩ := prod_ok_inj h7
      rw [← hs4] at h8
      obtain ⟨w, s5, h9, h10⟩ := runOn_bind_ok h8
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
  have hbs : bs' = encodePtr ⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ := by
    simp [Spec.Ty.encode, hkd, ThinPointer.widen] at hen
    first | exact hen.symm | exact hen
  subst hbs
  exact ⟨pd, pp, bs, q, pl, bi, u, hld, hpp, hlp, hlen, hq, hpl, hlb, hdb, hlim, hsto, rfl⟩

/-! ### The lift -/

/-- `LowerRefDerefIdx`'s lift (see the module comment). -/
theorem lift_refDerefIdx {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerRefDerefIdx Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @mk d p l rv elem pt ptd valid vd vi sd sp si t i1 i2 hrv htpΓ hk htiΓ htdΓ hkd hsd hsp hsi
      hsize hoff htmp hi1 hi2 =>
    obtain ⟨hft, -, htpv, hap⟩ := tempOk_spec htmp
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    -- L0
    have htp : f.body.locals[p]? = some (.ptr pt valid) := by rw [← hbody]; exact htpΓ
    have hti : f.body.locals[l]? = some (.int IntType.usize vi) := by rw [← hbody]; exact htiΓ
    have htd : f.body.locals[d]? = some (.ptr ptd vd) := by rw [← hbody]; exact htdΓ
    obtain ⟨pd, pp, bs, q, pl, bi, u, hpd, hpp, hlp, hlen, hq, hpl', hlb, hdb, hlim, hsto,
      hstk⟩ := assign_refDerefIdx_inv hs hrv htp hk hti htd hkd h
    have hmemp : p ∈ rvalueLocals rv := by
      cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv <;>
        (subst hrv; simp [rvalueLocals, placeLocals])
    have hmeml : l ∈ rvalueLocals rv := by
      cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv <;>
        (subst hrv; simp [rvalueLocals, placeLocals])
    -- R's reads: the data pointer and the index
    have hrp := hrel.opnd hpp hsp (hlo _ hmemp)
    obtain ⟨hlp8, bp1, hrfp, hbp⟩ := widePtr_read hrel.frame.mem hrp hsize.2.1 hlp
    obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
    have hri := hrel.opnd hpl' hsi (hlo _ hmeml)
    obtain ⟨bi1, hrfi, hbi⟩ := readLocal_inj hrel.frame.mem hri
      (show s.mem.load pl si.size .one = .ok bi by rw [hsize.2.2]; exact hlb)
    rw [hsize.2.2] at hrfi
    have hdb1 := decodeBits_inj hbi hdb
    have hu : asNat bi1 = .ok u := by unfold asNat; rw [hdb1]; rfl
    -- the offsets agree below `2^64`
    have hAL : Target.ADDR_LIMIT = 2 ^ 64 := rfl
    have hlt : (u % 2 ^ 64) * elem.size < 2 ^ 64 := by
      rw [hAL] at hlim
      exact Nat.lt_of_le_of_lt (Nat.le_add_left _ _) hlim
    have hoffeq : (u * elem.size) % 2 ^ 64 = (u % 2 ^ 64) * elem.size := by
      have e1 : (u * elem.size) % 2 ^ 64 = ((u % 2 ^ 64) * elem.size) % 2 ^ 64 := by
        rw [Nat.mul_mod u elem.size (2 ^ 64), Nat.mul_mod (u % 2 ^ 64) elem.size (2 ^ 64),
          Nat.mod_mod]
      rw [e1, Nat.mod_eq_of_lt hlt]
    have hlim' : q.addr + (u * elem.size) % 2 ^ 64 < Target.ADDR_LIMIT := by
      rw [hoffeq]; exact hlim
    have hwo := wrappingOffset_addr hpq.1 hlim'
    have hpi : PtrInj ι ⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩
        (q1.wrappingOffset (((u * elem.size) % 2 ^ 64 : Nat) : Int)) := by
      unfold PtrInj
      refine ⟨?_, hpq.2⟩
      rw [hwo, hoffeq]
    -- step 1: `ptr.index` into the temporary
    obtain ⟨v1, ps, r1, hv1, hh1, hn1, hk1, hops1, hctl1⟩ := ptrIndexInsnOk_spec hi1
    rw [hmode, hρ] at hv1
    obtain ⟨k1, ho1⟩ := operandsPtrIndex hn1 hk1
    have hfk : Val.fits k1 (.imm elem.size) = true :=
      fits_stride (hpl0.fits v1 hv1) (by rw [ho1, hops1]; simp)
    have hpv := temp_private hrel htpv
    have hlenP : (encodePtr (q1.wrappingOffset (((u * elem.size) % 2 ^ 64 : Nat) : Int))).length
        = 8 := Ryo.Spec.Theorems.encodePtr_length _
    have hpw : ∀ k < (encodePtr (q1.wrappingOffset
        (((u * elem.size) % 2 ^ 64 : Nat) : Int))).length, s1.st.escapedAt (t + k) = none := by
      rw [hlenP]; exact hpv
    obtain ⟨st1, hw1⟩ : ∃ st1, s1.st.writeFrame t
        (encodePtr (q1.wrappingOffset (((u * elem.size) % 2 ^ 64 : Nat) : Int))) = .ok st1 := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hmem1 : st1.mem = s1.st.mem := (writeFrame_private_eq hw1 hpw).1
    have hf1 := offOk_spec hft
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    have hop1 := opSem_ptrIndex_fwd (ch := ch) hh1 ho1
      ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩ hfk hrfp hrfi hq1 hu hw1
    have hstep1 := step_of_view hc0 hsc0 hpe hpl0 hv1 hctl1 (by rw [hops1]; exact hop1)
    have hrel1 := hrel.tempWrite hw1 hmem1
      (fun l' sl hsl => by rw [hlenP]; exact hap l' sl hsl) (s1.pc + 1)
    have hrd1 : st1.readFrame t 8 = .ok
        (encodePtr (q1.wrappingOffset (((u * elem.size) % 2 ^ 64 : Nat) : Int))) := by
      have := readFrame_after_write hw1 hpw
      rwa [hlenP] at this
    -- step 2: `mov.w64 d, t`, `_d` private or escaped
    obtain ⟨v2, ty2, r2, hv2, hh2, hty2, ho2, hops2, hctl2⟩ := movInsnOk_spec hi2
    rw [hmode, hρ] at hv2
    obtain ⟨sg2, hty2'⟩ := intTyOk_spec hty2
    have hpos8 : 0 < sd.size := by omega
    have hlen0 : (encodePtr (⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ : ThinPointer)).length =
        sd.size := by rw [Ryo.Spec.Theorems.encodePtr_length, hsize.1]
    have hW := hrel1.dstWrite hld hpd hsd hpos8 hlen0 hsto
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hW _ (encodePtr_inj' hpi)
    have hfd := offOk_spec hoff.1
    have hop2 := opSem_mov_fwd (ch := ch) hh2 hty2' ho2 ⟨hfd.1, hfd.2, hf1.1, hf1.2⟩ hrd1 hlenP
      hwr
    have hstep2 := step_of_view (s1 := { s1 with pc := s1.pc + 1, st := st1 }) hc1 hsc1 hpe
      hpl1 hv2 hctl2 (by rw [hops2]; exact hop2)
    -- the stored provenance is the data pointer's (`_p`'s load)
    have hsub := encodePtr_sub hq ((u % 2 ^ 64) * elem.size)
    have hhid' : ∀ b ∈ encodePtr (⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ : ThinPointer),
        ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hrel.hidden.load hlp8 _ (List.getElem_mem hj) fr0 hf0
    have hbd' : BytesBounded s.mem.allocs.size
        (encodePtr (⟨q.addr + (u % 2 ^ 64) * elem.size, q.prov⟩ : ThinPointer)) := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hpb.load hlp8 _ (List.getElem_mem hj) fr0 hf0
    exact liftOutN_two hstep1 ⟨st', hstep2, hstk,
      hrel1.after hpd hsd hmi hrd hoth (hrel1.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlp8 hsub⟩

/-- `LowerRefDerefIdx` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_cmpConst`). -/
theorem stmt_sim_refDerefIdx {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerRefDerefIdx Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h; exact ⟨_, _, rfl⟩
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
  exact lift_refDerefIdx M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    M.dinv.2 hl2 hl1 hev

end Ryo.Proofs.Lower
