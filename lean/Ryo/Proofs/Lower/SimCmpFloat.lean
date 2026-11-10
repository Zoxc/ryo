/-
Ryo.Proofs.Lower.SimCmpFloat — the simulation of `LowerCmpFloat` (`Check/Lower/CmpFloat.lean`,
M5b): a float comparison of two locals into a `bool` lowered to one `fcmp` handler.

- L0 (`evalBinOp_fcmp`): `relResult` of `Float.cmp f ua ub`, i.e. `fcmpBool`, stored as
  `boolByte` (`SimCmp.typedStore_bool`).
- R (`opSem_fcmp_fwd`): `floatCmp` on the operands, swapped for `>`/`>=` (`floatCmp_res`). The
  swap is `Float.cmp`'s antisymmetry `cmp_swap`: the NaN and infinity tests are symmetric, and
  for finite operands `exactAdd f y (neg f x)` is minus `exactAdd f x (neg f y)` (`neg` flips
  only the sign bit: `neg_bits`, by cases on the format, on numerals).
- No NaN choice: a comparison is a `Bool`. The written byte carries no provenance
  (`lift_binFloat`'s tail).
-/
import Ryo.Proofs.Lower.SimBinFloat
import Ryo.Proofs.Lower.SimCmp
import Ryo.Check.Lower.CmpFloat

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### `Float.cmp` is antisymmetric -/

/-- `neg` flips the sign bit and keeps the exponent and significand fields. -/
theorem neg_bits (f : FloatTy) (b : Nat) :
    Ryo.Spec.Float.expField f (Ryo.Spec.Float.neg f b) = Ryo.Spec.Float.expField f b ∧
    Ryo.Spec.Float.manField f (Ryo.Spec.Float.neg f b) = Ryo.Spec.Float.manField f b ∧
    Ryo.Spec.Float.sign f (Ryo.Spec.Float.neg f b) = !Ryo.Spec.Float.sign f b := by
  have key : ∀ b' : Nat, (Ryo.Spec.Float.sign f b = true → b' = b - Ryo.Spec.Float.signBit f) →
      (Ryo.Spec.Float.sign f b = false → b' = b + Ryo.Spec.Float.signBit f) →
      Ryo.Spec.Float.expField f b' = Ryo.Spec.Float.expField f b ∧
      Ryo.Spec.Float.manField f b' = Ryo.Spec.Float.manField f b ∧
      Ryo.Spec.Float.sign f b' = !Ryo.Spec.Float.sign f b := by
    intro b' h1 h2
    cases hs : Ryo.Spec.Float.sign f b with
    | true =>
      have e := h1 hs
      subst e
      revert hs
      cases f
      all_goals
        simp only [Ryo.Spec.Float.expField, Ryo.Spec.Float.manField, Ryo.Spec.Float.sign,
          Ryo.Spec.Float.signBit, FloatTy.bits, FloatTy.size, FloatTy.manBits, FloatTy.expBits,
          Nat.reduceMul, Nat.reduceSub, Nat.reducePow, beq_iff_eq, Bool.not_true,
          beq_eq_false_iff_ne, ne_eq]
        intro h
        exact ⟨by omega, by omega, by omega⟩
    | false =>
      have e := h2 hs
      subst e
      revert hs
      cases f
      all_goals
        simp only [Ryo.Spec.Float.expField, Ryo.Spec.Float.manField, Ryo.Spec.Float.sign,
          Ryo.Spec.Float.signBit, FloatTy.bits, FloatTy.size, FloatTy.manBits, FloatTy.expBits,
          Nat.reduceMul, Nat.reduceSub, Nat.reducePow, beq_iff_eq, Bool.not_false,
          beq_eq_false_iff_ne, ne_eq]
        intro h
        exact ⟨by omega, by omega, by omega⟩
  exact key _ (fun h => by simp [Ryo.Spec.Float.neg, h]) (fun h => by simp [Ryo.Spec.Float.neg, h])

theorem finite_neg (f : FloatTy) (b : Nat) :
    Ryo.Spec.Float.finite f (Ryo.Spec.Float.neg f b) =
      (!(Ryo.Spec.Float.finite f b).1, (Ryo.Spec.Float.finite f b).2.1,
        (Ryo.Spec.Float.finite f b).2.2) := by
  obtain ⟨he, hm, hs⟩ := neg_bits f b
  unfold Ryo.Spec.Float.finite
  rw [he, hm, hs]
  by_cases h : (Ryo.Spec.Float.expField f b == 0) = true <;> simp [h]

theorem exactAdd_swap (f : FloatTy) (x y : Nat) :
    (Ryo.Spec.Float.exactAdd f y (Ryo.Spec.Float.neg f x)).1 =
      -(Ryo.Spec.Float.exactAdd f x (Ryo.Spec.Float.neg f y)).1 := by
  unfold Ryo.Spec.Float.exactAdd
  rw [finite_neg f x, finite_neg f y]
  generalize Ryo.Spec.Float.finite f x = px
  generalize Ryo.Spec.Float.finite f y = py
  obtain ⟨sx, mx, ex⟩ := px
  obtain ⟨sy, my, ey⟩ := py
  dsimp only
  rw [Int.min_comm ey ex]
  cases sx <;> cases sy
  all_goals
    first
      | (simp only [Bool.not_true, Bool.not_false, Bool.false_eq_true, ↓reduceIte]; omega)
      | (simp; omega)
      | simp

theorem cmp_swap (f : FloatTy) (x y : Nat) :
    Ryo.Spec.Float.cmp f y x = (Ryo.Spec.Float.cmp f x y).map Ordering.swap := by
  have hk := exactAdd_swap f x y
  unfold Ryo.Spec.Float.cmp
  try dsimp only
  by_cases hn : (Ryo.Spec.Float.isNaN f x || Ryo.Spec.Float.isNaN f y) = true
  · have hn' : (Ryo.Spec.Float.isNaN f y || Ryo.Spec.Float.isNaN f x) = true := by
      rw [Bool.or_comm]; exact hn
    rw [if_pos hn', if_pos hn]
    rfl
  · have hn' : ¬ (Ryo.Spec.Float.isNaN f y || Ryo.Spec.Float.isNaN f x) = true := by
      rw [Bool.or_comm]; exact hn
    rw [if_neg hn', if_neg hn]
    by_cases hi : (Ryo.Spec.Float.isInf f x || Ryo.Spec.Float.isInf f y) = true
    · have hi' : (Ryo.Spec.Float.isInf f y || Ryo.Spec.Float.isInf f x) = true := by
        rw [Bool.or_comm]; exact hi
      rw [if_pos hi', if_pos hi]
      exact congrArg some (Int.compare_swap _ _).symm
    · have hi' : ¬ (Ryo.Spec.Float.isInf f y || Ryo.Spec.Float.isInf f x) = true := by
        rw [Bool.or_comm]; exact hi
      rw [if_neg hi', if_neg hi]
      refine congrArg some ?_
      rw [hk, Int.compare_swap, Int.compare_eq_ite_lt, Int.compare_eq_ite_lt]
      generalize (Ryo.Spec.Float.exactAdd f x (Ryo.Spec.Float.neg f y)).1 = A
      by_cases h1 : -A < 0 <;> by_cases h2 : 0 < -A <;> by_cases h3 : (0 : Int) < A <;>
        by_cases h4 : A < 0 <;> simp only [h1, h2, h3, h4, ↓reduceIte] <;>
        first | rfl | (exfalso; omega)

/-! ### L0 and R's results -/

/-- The result of a comparison of `Float.cmp`'s answer (`relResult`'s). -/
def fcmpBool (op : BinOp) (c : Option Ordering) : Bool :=
  match op with
  | .eq => c == some .eq
  | .ne => c != some .eq
  | .lt => c == some .lt
  | .le => c == some .lt || c == some .eq
  | .gt => c == some .gt
  | _ => c == some .gt || c == some .eq

theorem evalBinOp_fcmp {op : BinOp} {o : String} {sw : Bool} (hm : fcmpOp op = some (o, sw))
    (f : FloatTy) (ua ub : Nat) :
    evalBinOp op (.float f ua, .float f) (.float f ub, .float f) .bool =
      pure (.bool (fcmpBool op (Ryo.Spec.Float.cmp f ua ub))) := by
  cases op <;> simp [fcmpOp] at hm <;>
    first
      | rfl
      | simp [evalBinOp, isRel, relResult, fcmpBool]

/-- R's comparison, the operands swapped for `>`/`>=`, is L0's. -/
theorem floatCmp_res {op : BinOp} {o : String} {sw : Bool} (hm : fcmpOp op = some (o, sw))
    (f : FloatTy) (ua ub : Nat) :
    floatCmp o f (if sw then ub else ua) (if sw then ua else ub) =
      .ok (fcmpBool op (Ryo.Spec.Float.cmp f ua ub)) := by
  cases op <;> simp [fcmpOp] at hm <;> obtain ⟨rfl, rfl⟩ := hm
  all_goals
    first
      | rfl
      | (show floatCmp "<" f ub ua = _
         rw [show floatCmp "<" f ub ua = .ok (Ryo.Spec.Float.cmp f ub ua == some .lt) from rfl,
           cmp_swap]
         cases Ryo.Spec.Float.cmp f ua ub with
         | none => rfl
         | some c => cases c <;> rfl)
      | (show floatCmp "<=" f ub ua = _
         rw [show floatCmp "<=" f ub ua = .ok (Ryo.Spec.Float.cmp f ub ua == some .lt ||
             Ryo.Spec.Float.cmp f ub ua == some .eq) from rfl, cmp_swap]
         cases Ryo.Spec.Float.cmp f ua ub with
         | none => rfl
         | some c => cases c <;> rfl)

/-! ### R -/

theorem fp_fcmp {ty o : String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .fcmp [ty, o] = some (cmpFp n) := by
  simp only [footprintOf, List.head?, Option.bind_some, h] <;> rfl

/-- The forward direction of an `fcmp` handler's semantics. -/
theorem opSem_fcmp_fwd {op : Full.Opcode} {r : Option String} {ty o : String} {f : FloatTy}
    {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.fcmp, [ty, o], r⟩) (hty : OpSem.Ty.parse ty = some (.float f))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31 ∧ -2 ^ 31 ≤ b ∧ b < 2 ^ 31)
    {ba bb : List AbstractByte} {va vb : Nat} {res : Bool}
    (hra : st.readFrame a f.size = .ok ba) (hrb : st.readFrame b f.size = .ok bb)
    (hva : asNat ba = .ok va) (hvb : asNat bb = .ok vb)
    (hres : floatCmp o f va vb = .ok res)
    (hw : st.writeFrame d (boolByte res) = .ok st') :
    opSem op [.slot d, .slot a, .slot b] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2, hb1, hb2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfb := slot_fits hb1 hb2
  have hfp : footprint op = some (cmpFp f.size) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact fp_fcmp (tySize_of_parse_float hty)
  have hprep : prepare op [.slot d, .slot a, .slot b] =
      .ok (⟨.fcmp, [ty, o], r⟩, (cmpFp f.size),
        opndVal op.info [.slot d, .slot a, .slot b]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfa, hfb])]
    rfl
  have hva' : opndVal op.info [.slot d, .slot a, .slot b] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvb' : opndVal op.info [.slot d, .slot a, .slot b] "b" = some (.slot b) := by
    simp [opndVal, ho]
  have hvd' : opndVal op.info [.slot d, .slot a, .slot b] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (cmpFp f.size) (opndVal op.info [.slot d, .slot a, .slot b]) st =
      .ok [("a", ba), ("b", bb)] := by
    simp only [readAll, cmpFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', hvb', Val.slotOff, Extent.eval, hra, hrb,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .fcmp [ty, o] (mkEnv [("a", ba), ("b", bb)]
      (opndVal op.info [.slot d, .slot a, .slot b]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", boolByte res)] } := by
    simp [kindSem, floatTy_of_parse hty, mkEnv, Env.int, out, hva, hvb, hres, bind, Except.bind,
      pure, Except.pure]
  have hlen : (boolByte res).length = 1 := boolByte_length res
  have hc : commit (cmpFp f.size) (opndVal op.info [.slot d, .slot a, .slot b]) st
      [("d", boolByte res)] = .ok st' := by
    simp only [commit, cmpFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', Val.slotOff, Extent.eval, hlen, hw,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | rw [hc]
    | rw [hst, hc]
    | erw [hc]

/-! ### The lift -/

theorem lift_cmpFloat {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerCmpFloat Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @cmp d a b op oa ob om sw fl sd sa sb i hm ha hb htd hta htb hsd hsa hsb hsize hoff hpriv
      hii =>
    have hla := hlo a (by
      show a ∈ operandLocals oa ++ operandLocals ob
      rcases local?_cases ha with rfl | rfl <;> simp [operandLocals, placeLocals])
    have hlb := hlo b (by
      show b ∈ operandLocals oa ++ operandLocals ob
      rcases local?_cases hb with rfl | rfl <;> simp [operandLocals, placeLocals])
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := fcmpInsnOk_spec hii
    rw [hmode, hρ] at hv
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb, td, ta, tb, va, vb, w, hpd, hpa, hpb', htd', hta', htb', hla0, hlb0,
      s2, hev, mem', hst, hs'⟩ := assign_binop_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = .float fl := Option.some.inj (hta'.symm.trans hta)
    have e6 : tb = .float fl := Option.some.inj (htb'.symm.trans htb)
    subst e4 e5 e6
    obtain ⟨bsa, ua, hloa, hda, rfl⟩ := typedLoad_float hla0
    obtain ⟨bsb, ub, hlob, hdb, rfl⟩ := typedLoad_float hlb0
    rw [evalBinOp_fcmp hm] at hev
    have hev' : ((Except.ok (Value.bool (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub))), s) :
        Except Outcome Value × Spec.State) = (.ok w, s2) := hev
    obtain ⟨hw, hs2⟩ := prod_ok_inj hev'
    subst hw
    rw [← hs2] at hst hs'
    have hsto : s.mem.store pd (boolByte (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub))) .one =
        .ok s'.mem := by
      rw [hs']; exact typedStore_bool hst
    have hstk : s'.stack = s.stack := by rw [hs']
    -- R's reads
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
    -- `_d` private
    have hpos : 0 < sd.size := by rw [hsize.1]; exact Nat.one_pos
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    -- R's write
    have hlen : (boolByte (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub))).length = 1 :=
      boolByte_length _
    have hpw : ∀ k < (boolByte (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub))).length,
        s1.st.escapedAt (sd.off + k) = none := by
      intro k hk
      rw [hlen, ← hsize.1] at hk
      exact hpv k hk
    obtain ⟨st', hwr⟩ : ∃ st', s1.st.writeFrame sd.off
        (boolByte (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub))) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    have hres := floatCmp_res hm fl ua ub
    have hop : opSem v.op v.ops s1.st ch = .ok (.next, st') := by
      rw [hops]
      cases sw
      · exact opSem_fcmp_fwd hh hty ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩ hrfa hrfb hva
          hvb hres hwr
      · exact opSem_fcmp_fwd hh hty ho ⟨hf1.1, hf1.2, hf3.1, hf3.2, hf2.1, hf2.2⟩ hrfb hrfa hvb
          hva hres hwr
    have hbs : BytesInj ι (boolByte (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub)))
        (boolByte (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub))) := by
      first
        | exact encodeBits_inj ι _ _
        | (unfold boolByte intBytes; exact encodeBits_inj ι _ _)
    have hlen0 : (boolByte (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub))).length = sd.size := by
      rw [boolByte_length, hsize.1]
    obtain ⟨hmi, hrd⟩ := writeLocal_priv hrel.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv
      hbs hlen0 hsto hwr
    have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
        p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι s1.fp st' s'.mem slot p lv := by
      intro slot p lv hr hne hap
      have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
      exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsize.1]; exact hap)
    have hnp : ∀ b ∈ boolByte (fcmpBool op (Ryo.Spec.Float.cmp fl ua ub)),
        b.provFrag = none := by
      first
        | exact encodeBits_noprov 1 _
        | (unfold boolByte intBytes; exact encodeBits_noprov 1 _)
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb2, hle, hk⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl hop, hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb2,
      hle, hk⟩

/-- `LowerCmpFloat` in a scope-free function: `stmt_sim`'s case. -/
theorem stmt_sim_cmpFloat {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerCmpFloat Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h
    exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  refine stmtOut_of_liftN (k := 1) M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv
    (by rw [hpc0, he]) ?_
  exact liftOutN_of_lift (lift_cmpFloat M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl
    M.rel M.pb hl2 hl1 hev)

end Ryo.Proofs.Lower
