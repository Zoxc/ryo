/-
Ryo.Proofs.Lower.SimRefDerefWideE — the simulation of `LowerRefDerefWideE`
(`Check/Lower/RefDerefWideE.lean`, M5b): `_d = &(*_p)` for a wide `_p`, lowered to
`mov.w64 d, p; mov.w64 d + 8, p + 8`, `_d` private or escaped.

R's frame writes compose: two adjacent writes are one write of the concatenation
(`writeFrame_append`, from `writeEscaped_append`: the escaped bytes are written in order either
way, and the frame's private bytes are the same function). `_p` is private, so its bytes are
frame bytes (`readFrame_priv`) the first write leaves alone (apart from it), and the two halves
the `mov`s read make the 16 bytes R reads of `_p` (`readLocal_inj`). L0
(`refDerefWideE_mem`, as `refDerefWide_mem`) stores into `_d` bytes below `_p`'s 16; so
`FnRel.dstWrite`'s write of the concatenation is R's two-step result, and `FnRel.after`
assembles the relation (`Hidden`, `ProvBounded`, `MemKept` from `_p`'s load).
-/
import Ryo.Proofs.Lower.SimRefDerefWide
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Check.Lower.RefDerefWideE

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### R's frame writes -/

theorem escapedAt_congr {st st' : OpSem.State} (h : st'.escaped = st.escaped) (o : Int) :
    st'.escapedAt o = st.escapedAt o := by
  unfold OpSem.State.escapedAt; rw [h]

/-- A successful frame write: its escaped-bytes write, and the state is `st`'s with the new
memory and frame. -/
theorem writeFrame_parts {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') :
    st.writeEscaped off bs = .ok st'.mem ∧ st' = { st with mem := st'.mem, frame := st'.frame } := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    exact ⟨rfl, rfl⟩

/-- The escaped bytes of `xs ++ ys`: those of `xs`, then those of `ys` from the result. -/
theorem writeEscaped_append {st st1 : OpSem.State} {off : Int} {xs ys : List AbstractByte}
    (hesc : st1.escaped = st.escaped) (hm : st.writeEscaped off xs = .ok st1.mem) :
    st.writeEscaped off (xs ++ ys) = st1.writeEscaped (off + xs.length) ys := by
  unfold OpSem.State.writeEscaped at hm ⊢
  rw [List.zipIdx_append, List.foldlM_append, hm]
  show (ys.zipIdx (0 + xs.length)).foldlM _ st1.mem = _
  rw [List.zipIdx_eq_map_add (l := ys) (i := 0 + xs.length), List.foldlM_map]
  congr 1
  funext mem p
  obtain ⟨b, i⟩ := p
  have ho : off + ((0 + xs.length + i : Nat) : Int) = off + (xs.length : Int) + (i : Int) := by
    push_cast; omega
  simp only [ho, escapedAt_congr hesc]

/-- Byte `o - off` of `xs ++ ys` (`off ≤ o`): `xs`'s, or `ys`'s at `o - (off + xs.length)`. -/
theorem getD_append_at {xs ys : List AbstractByte} {off o : Int} (h0 : off ≤ o)
    (d : AbstractByte) :
    (xs ++ ys).getD (o - off).toNat d =
      if o < off + xs.length then xs.getD (o - off).toNat d
      else ys.getD (o - (off + xs.length)).toNat d := by
  obtain ⟨n, hn⟩ : ∃ n : Nat, o - off = n := ⟨(o - off).toNat, (Int.toNat_of_nonneg (by omega)).symm⟩
  have e1 : (o - off).toNat = n := by rw [hn]; rfl
  rw [e1]
  split
  next hlt =>
    rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD,
      List.getElem?_append_left (by omega)]
  next hge =>
    have e2 : (o - (off + xs.length)).toNat = n - xs.length := by
      have : o - (off + xs.length) = ((n - xs.length : Nat) : Int) := by omega
      rw [this]; rfl
    rw [e2, List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD,
      List.getElem?_append_right (by omega)]

/-- Two adjacent frame writes are one write of the concatenation. -/
theorem writeFrame_append {st st1 st2 : OpSem.State} {off : Int} {xs ys : List AbstractByte}
    (h1 : st.writeFrame off xs = .ok st1) (h2 : st1.writeFrame (off + xs.length) ys = .ok st2) :
    st.writeFrame off (xs ++ ys) = .ok st2 := by
  obtain ⟨hm1, he1⟩ := writeFrame_parts h1
  obtain ⟨hm2, he2⟩ := writeFrame_parts h2
  obtain ⟨-, hesc1, hfr1⟩ := writeFrame_split h1
  obtain ⟨-, -, hfr2⟩ := writeFrame_split h2
  unfold OpSem.State.writeFrame
  rw [writeEscaped_append hesc1 hm1, hm2]
  show Except.ok _ = Except.ok st2
  congr 1
  conv => rhs; rw [he2, he1]
  congr 1
  funext o
  rw [hfr2 o, hfr1 o]
  simp only [OpSem.State.privateIn, escapedAt_congr hesc1, List.length_append]
  by_cases hE : (st.escapedAt o).isNone = true
  · simp only [hE, Bool.and_true]
    by_cases h0 : off ≤ o
    · rw [getD_append_at h0]
      by_cases ha : o < off + xs.length
      · have hA : off ≤ o ∧ o < off + ((xs.length + ys.length : Nat) : Int) := by
          push_cast; omega
        have hC : ¬ (off + (xs.length : Int) ≤ o ∧ o < off + xs.length + ys.length) := by omega
        have hD : off ≤ o ∧ o < off + (xs.length : Int) := ⟨h0, ha⟩
        simp only [hA, hC, hD, ha,
          and_self, true_and, and_true, and_false, false_and, decide_true, decide_false, Bool.false_eq_true,
            eq_self_iff_true, Bool.true_eq_false, ↓reduceIte]
      · by_cases hb : o < off + xs.length + ys.length
        · have hA : off ≤ o ∧ o < off + ((xs.length + ys.length : Nat) : Int) := by
            push_cast; omega
          have hC : off + (xs.length : Int) ≤ o ∧ o < off + xs.length + ys.length := by omega
          simp only [hA, hC, ha,
            and_self, true_and, and_true, and_false, false_and, decide_true, decide_false, Bool.false_eq_true,
            eq_self_iff_true, Bool.true_eq_false, ↓reduceIte]
        · have hA : ¬ (off ≤ o ∧ o < off + ((xs.length + ys.length : Nat) : Int)) := by
            push_cast; omega
          have hC : ¬ (off + (xs.length : Int) ≤ o ∧ o < off + xs.length + ys.length) := by
            omega
          have hD : ¬ (off ≤ o ∧ o < off + (xs.length : Int)) := by omega
          simp only [hA, hC, hD,
            and_self, true_and, and_true, and_false, false_and, decide_true, decide_false, Bool.false_eq_true,
            eq_self_iff_true, Bool.true_eq_false, ↓reduceIte]
    · have hA : ¬ (off ≤ o ∧ o < off + ((xs.length + ys.length : Nat) : Int)) := by omega
      have hC : ¬ (off + (xs.length : Int) ≤ o ∧ o < off + xs.length + ys.length) := by omega
      have hD : ¬ (off ≤ o ∧ o < off + (xs.length : Int)) := by omega
      simp only [hA, hC, hD,
        and_self, true_and, and_true, and_false, false_and, decide_true, decide_false, Bool.false_eq_true,
            eq_self_iff_true, Bool.true_eq_false, ↓reduceIte]
  · simp only [Bool.not_eq_true] at hE
    simp only [hE, Bool.and_false, Bool.false_eq_true, ↓reduceIte]

/-- Private frame bytes read as the frame. -/
theorem readFrame_priv {st : OpSem.State} {x : Int} {n : Nat}
    (hp : ∀ k < n, st.escapedAt (x + k) = none) :
    st.readFrame x n = .ok ((List.range n).map fun (i : Nat) => st.frame (x + i)) :=
  readFrame_eq_map fun i hi => by
    unfold OpSem.State.byteAt
    rw [hp i hi]
    rfl

/-! ### L0 -/

/-- `refDerefWide_mem` in plain terms: L0 loads `_p`'s 16 bytes and stores bytes below them
into `_d`. -/
theorem refDerefWideE_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p : Local} {rv : Rvalue}
    {pointee : Spec.Ty} {pt ptd : PtrType} {valid vd : ValidRange}
    (hrv : refPlace? rv = some ⟨p, [.deref pointee]⟩)
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind ≠ .none)
    (htd : f.body.locals[d]? = some (.ptr ptd vd))
    (hshape : sameMetaShape ptd.metaKind pt.metaKind = true)
    (hwf : (Spec.Ty.ptr pt valid).wf = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    ∃ pd pp bs bsd, f.locals[d]? = some (some pd) ∧ f.locals[p]? = some (some pp) ∧
      s.mem.load pp 16 .one = .ok bs ∧ bytesLeDefined bsd bs = true ∧ bsd.length = 16 ∧
      s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  obtain ⟨pd, ebs, hpd, hl1, hl2, hfm, -, hsto, hstk⟩ :=
    refDerefWide_mem (so := 0) (ws := [16]) hs hrv htp hk htd hshape hwf rfl h
  rcases ebs with _ | ⟨eb, _ | ⟨eb2, ebs⟩⟩
  · simp at hl1
  · obtain ⟨pa, bs0, hpa, hlo, hle⟩ := hfm 0 (by simp) (by simp)
    have hlen0 : bs0.length = 16 := load_length hlo
    have hbl : eb.length = 16 :=
      ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans hlen0
    have hw' : writeFields (List.replicate 16 AbstractByte.uninit)
        ((([(0, Spec.Ty.ptr pt valid)] : List (Nat × Spec.Ty)).map (·.1)).zip [eb]) = eb := by
      show writeAt _ 0 eb = eb
      simp [writeAt, hbl]
    rw [hw'] at hsto
    exact ⟨pd, pa, bs0, eb, hpd, hpa, hlo, hle, hbl, hsto, hstk⟩
  · simp at hl1

/-! ### The lift -/

/-- `LowerRefDerefWideE`'s lift (see the module comment). -/
theorem lift_refDerefWideE {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerRefDerefWideE Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @mk d p rv pointee pt ptd valid vd sd sp i1 i2 hrv htpΓ hk htdΓ hshape hwf hsd hsp hsize
      hoff hpp hap hi1 hi2 =>
    have hc0 : c.d.insns[s1.pc]? = some i1 := by simpa using hi 0 (by simp)
    have hc1 : c.d.insns[s1.pc + 1]? = some i2 := hi 1 (by simp)
    have hsc0 : c.scopesAt s1.pc = [] := by simpa using hsc 0 (by simp)
    have hsc1 : c.scopesAt (s1.pc + 1) = [] := hsc 1 (by simp)
    have hpl0 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
    have hpl1 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
    have htp : f.body.locals[p]? = some (.ptr pt valid) := by rw [← hbody]; exact htpΓ
    have htd : f.body.locals[d]? = some (.ptr ptd vd) := by rw [← hbody]; exact htdΓ
    obtain ⟨pd, pp, bs, bsd, hpd, hpp', hlp, hle, hbl, hsto, hstk⟩ :=
      refDerefWideE_mem hs hrv htp hk htd hshape hwf h
    have hlp' : live p = true := hlo p (by
      cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv <;>
        (subst hrv; simp [rvalueLocals, placeLocals]))
    -- `_p`'s 16 bytes in R: private frame bytes, related to L0's
    have hrp := hrel.opnd hpp' hsp hlp'
    obtain ⟨bp1, hrf16, hbp⟩ := readLocal_inj hrel.frame.mem hrp
      (show s.mem.load pp sp.size .one = .ok bs by rw [hsize.2]; exact hlp)
    rw [hsize.2] at hrf16
    have hpv := temp_private hrel hpp
    rw [hsize.2] at hpv
    let g : Nat → AbstractByte := fun i => s1.st.frame (sp.off + i)
    have hR16 := readFrame_priv (st := s1.st) (x := sp.off) (n := 16) hpv
    rw [hrf16] at hR16
    obtain rfl : bp1 = (List.range 16).map g := Except.ok.inj hR16
    have hR1 : s1.st.readFrame sp.off 8 = .ok ((List.range 8).map g) :=
      readFrame_priv (fun k hk => hpv k (by omega))
    -- R may write `_d`'s slot: its escaped bytes have allocations
    have hok : ∀ k : Nat, k < 16 → ∀ e, s1.st.escapedAt (sd.off + k) = some e →
        e.id < s1.st.mem.allocs.size := by
      intro k hk e he
      obtain ⟨sd', hsd', hrd⟩ := hrel.frame.locals d pd hpd (by rw [hrel.unaliased]; simp)
      rw [hsd] at hsd'
      obtain rfl := Option.some.inj hsd'
      cases hrd with
      | priv a x hp hι hx hlive haddr hpaddr hsz hpriv _ =>
        rw [hpriv k (by omega)] at he
        cases he
      | esc a x e' y hp hι hx hlive haddr hpaddr hsz hin hy =>
        rw [hin k (by omega)] at he
        cases he
        unfold Memory.get? at hy
        exact (Array.getElem?_eq_some_iff.mp hy).1
    -- step 1: `mov.w64 d, p`
    obtain ⟨v1, ty1, r1, hv1, hh1, hty1, ho1, hops1, hctl1⟩ := movInsnOk_spec hi1
    rw [hmode, hρ] at hv1
    obtain ⟨sg1, hty1'⟩ := intTyOk_spec hty1
    have hlen8 : ((List.range 8).map g).length = 8 := by simp
    obtain ⟨st1, hw1⟩ := writeFrame_ok_of (st := s1.st) (off := sd.off)
      (bs := (List.range 8).map g) (fun k hk e he => hok k (by rw [hlen8] at hk; omega) e he)
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2.1
    have hf4 := offOk_spec hoff.2.2.2
    have hop1 := opSem_mov_fwd (ch := ch) hh1 hty1' ho1 ⟨hf1.1, hf1.2, hf3.1, hf3.2⟩ hR1 hlen8
      hw1
    have hstep1 := step_of_view hc0 hsc0 hpe hpl0 hv1 hctl1 (by rw [hops1]; exact hop1)
    obtain ⟨hef1, hesc1, hfr1⟩ := writeFrame_split hw1
    -- step 2: `mov.w64 d + 8, p + 8`, reading `_p`'s second half, untouched
    let g2 : Nat → AbstractByte := fun i => s1.st.frame (sp.off + 8 + i)
    have hR2 : st1.readFrame (sp.off + 8) 8 = .ok ((List.range 8).map g2) := by
      have hp2 : ∀ k : Nat, k < 8 → st1.escapedAt (sp.off + 8 + k) = none := fun k hk => by
        rw [escapedAt_congr hesc1]
        have := hpv (8 + k) (by omega)
        rw [show sp.off + ((8 + k : Nat) : Int) = sp.off + 8 + k by push_cast; omega] at this
        exact this
      rw [readFrame_priv hp2]
      apply congrArg Except.ok
      apply List.map_congr_left
      intro i hi
      have hi' := List.mem_range.mp hi
      show st1.frame (sp.off + 8 + i) = s1.st.frame (sp.off + 8 + i)
      rw [hfr1, if_neg]
      simp only [OpSem.State.privateIn]
      intro hc
      simp only [Bool.and_eq_true, decide_eq_true_eq, hlen8] at hc
      obtain ⟨⟨h1, h2⟩, -⟩ := hc
      have hs1 := hsize.1
      have hs2 := hsize.2
      omega
    have hlen8' : ((List.range 8).map g2).length = 8 := by simp
    have hok2 : ∀ k < ((List.range 8).map g2).length, ∀ e, st1.escapedAt (sd.off + 8 + k) =
        some e → e.id < st1.mem.allocs.size := by
      intro k hk e he
      rw [escapedAt_congr hesc1] at he
      rw [hef1.1]
      exact hok (8 + k) (by rw [hlen8'] at hk; omega) e
        (by rw [show sd.off + ((8 + k : Nat) : Int) = sd.off + 8 + k by push_cast; omega]
            exact he)
    obtain ⟨st2, hw2⟩ := writeFrame_ok_of hok2
    obtain ⟨v2, ty2, r2, hv2, hh2, hty2, ho2, hops2, hctl2⟩ := movInsnOk_spec hi2
    rw [hmode, hρ] at hv2
    obtain ⟨sg2, hty2'⟩ := intTyOk_spec hty2
    have hop2 := opSem_mov_fwd (ch := ch) hh2 hty2' ho2 ⟨hf2.1, hf2.2, hf4.1, hf4.2⟩ hR2 hlen8'
      hw2
    have hstep2 := step_of_view (s1 := { s1 with pc := s1.pc + 1, st := st1 }) hc1 hsc1 hpe
      hpl1 hv2 hctl2 (by rw [hops2]; exact hop2)
    -- the two writes are one: `FnRel.dstWrite`
    have hcat : (List.range 8).map g ++ (List.range 8).map g2 = (List.range 16).map g := by
      rw [show (16 : Nat) = 8 + 8 from rfl, List.range_add, List.map_append, List.map_map]
      apply congrArg ((List.range 8).map g ++ ·)
      apply List.map_congr_left
      intro i _
      show s1.st.frame (sp.off + 8 + i) = s1.st.frame (sp.off + ((8 + i : Nat) : Int))
      apply congrArg s1.st.frame
      push_cast
      omega
    have hw12 : s1.st.writeFrame sd.off ((List.range 8).map g ++ (List.range 8).map g2) =
        .ok st2 := writeFrame_append hw1 (by rw [hlen8]; exact hw2)
    rw [hcat] at hw12
    have hpos16 : 0 < sd.size := by omega
    have hlen0 : bsd.length = sd.size := by rw [hbl, hsize.1]
    have hW := hrel.dstWrite hld hpd hsd hpos16 hlen0 hsto
    obtain ⟨hbs, -⟩ := BytesInj.of_le_trans hle hbp
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hW _ hbs
    rw [hw12] at hwr
    have e2 : st2 = st' := Except.ok.inj hwr
    rw [e2] at hstep2
    -- the relation
    have hsub := bytesLeDefined_prov hle
    have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hrel.hidden.load hlp _ (List.getElem_mem hj) fr0 hf0
    have hbd' : BytesBounded s.mem.allocs.size bsd := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hpb.load hlp _ (List.getElem_mem hj) fr0 hf0
    refine ⟨st', .cons hstep1 (.cons hstep2 (.refl _)), hstk, ?_, hpb.store hsto hbd',
      Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlp hsub⟩
    exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive'

/-- `LowerRefDerefWideE` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_cmpConst`). -/
theorem stmt_sim_refDerefWideE {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerRefDerefWideE Γ.toStmtCtx st (rangeInsns c.d r))
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
  exact lift_refDerefWideE M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb
    M.dinv.2 hl2 hl1 hev

end Ryo.Proofs.Lower
