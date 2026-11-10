/-
Ryo.Proofs.Lower.SimBinFloat — the simulation of `LowerBinFloat` (`Check/Lower/BinFloat.lean`,
M5b): `_d = op(_a, _b)` on floats lowered to one `fbin` handler.

- L0 (`assign_binop_inv`, `typedLoad_float`, `evalBinOp_float`): both operands decode to their
  bits `ua`, `ub`; `evalBinOp` is `resolveFloat f (floatRes op f ua ub)`, `Ryo.Spec.Float`'s
  exact IEEE result, a NaN's bits the oracle's answer (`runOn_resolveFloat`); the store writes
  `encodeBits f.size bits` (`typedStore_float`).
- R (`opSem_fbin_fwd`): `floatBin` is `resolveNaN ch (floatRes op f ua ub)` (`floatBin_res`) on
  the same bits (`decodeBits_inj`), writing `intBytes f.size bits`, the same bytes.
- NaN payloads: L0's is the oracle's daemonic answer (`Choice.nanBits`, which must be a
  candidate), R's the `Choice`'s (`resolveNaN`). They agree when the oracle answers what R's
  choice resolves to (`NanPicks`, a hypothesis like `PicksAt` for allocation addresses: the
  oracle that plays R's choices satisfies it).
- The written bytes carry no provenance, so the invariants are those of an integer `binop`
  (`lift_binop`'s tail, `memInv_store`).
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Proofs.Lower.SimAgg
import Ryo.Check.Lower.BinFloat

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- The exact result of a float operator (`evalBinOp`'s and `floatBin`'s). -/
def floatRes (op : BinOp) (f : FloatTy) (a b : Nat) : Ryo.Spec.Float.FRes :=
  match op with
  | .add => Ryo.Spec.Float.add f a b
  | .sub => Ryo.Spec.Float.sub f a b
  | .mul => Ryo.Spec.Float.mul f a b
  | .div => Ryo.Spec.Float.div f a b
  | _ => Ryo.Spec.Float.rem f a b

-- `NanPicks` (the oracle's NaN answers are R's choice's) is in `FnSim.lean`, part of `PicksAt`.

/-! ### L0 -/

theorem typedLoad_float {mem : Memory} {p : ThinPointer} {f : FloatTy} {al : Align} {v : Value}
    (h : typedLoad mem p (.float f) al = .ok v) :
    ∃ bs u, mem.load p f.size al = .ok bs ∧ decodeBits bs = some u ∧ v = .float f u := by
  have hs : (Spec.Ty.float f).size? = some f.size := rfl
  cases hl : mem.load p f.size al with
  | error e =>
    simp [typedLoad, hs, hl] at h
  | ok bs =>
    cases hdec : (Spec.Ty.float f).decode bs with
    | none =>
      first
        | (simp [typedLoad, hs, hl, hdec, throwUb, throwThe, MonadExceptOf.throw] at h; done)
        | (simp [typedLoad, hs, hl, hdec] at h; done)
        | (simp only [typedLoad, hs, hl, hdec] at h; cases h)
    | some w =>
      have hw : ∃ u, decodeBits bs = some u ∧ w = .float f u := by
        simp only [Spec.Ty.decode] at hdec
        by_cases hlen : bs.length = f.size
        · cases hdb : decodeBits bs with
          | none => simp [hlen, hdb] at hdec
          | some u =>
            refine ⟨u, rfl, ?_⟩
            simp [hlen, hdb] at hdec
            subst hdec
            rfl
        · simp [hlen] at hdec
      obtain ⟨u, hdb, rfl⟩ := hw
      cases hc : checkValue mem (.float f u) (.float f) with
      | error e =>
        first
          | (simp [typedLoad, hs, hl, hdec, hc] at h; done)
          | (simp [typedLoad, hs, hl, hdec, hc] at h; cases h)
      | ok _ =>
        simp [typedLoad, hs, hl, hdec, hc] at h
        cases h
        exact ⟨bs, u, rfl, hdb, rfl⟩

theorem typedStore_float {mem mem' : Memory} {p : ThinPointer} {f : FloatTy} {al : Align}
    {bits : Nat} (h : typedStore mem p (.float f bits) (.float f) al = .ok mem') :
    mem.store p (encodeBits f.size bits) al = .ok mem' := by
  have he : (Spec.Ty.float f).encode (.float f bits) = some (encodeBits f.size bits) := by
    simp [Spec.Ty.encode]
  simp only [typedStore, he] at h
  exact h

/-- A float operator on two floats of the same format is `resolveFloat` of `floatRes`. -/
theorem evalBinOp_float {op : BinOp} {o : String} (hm : floatMethod op = some o) (f : FloatTy)
    (ua ub : Nat) (td : Spec.Ty) :
    evalBinOp op (.float f ua, .float f) (.float f ub, .float f) td =
      resolveFloat f (floatRes op f ua ub) := by
  cases op <;> simp [floatMethod] at hm <;>
    first
      | rfl
      | simp [evalBinOp, floatRes]

/-- `resolveFloat`, run to success: the result's bits, which R's `resolveNaN` reproduces under
`NanPicks`; only the choice count changes. -/
theorem runOn_resolveFloat {o : Spec.Oracle} {s s1 : Spec.State} {f : FloatTy}
    {r : Ryo.Spec.Float.FRes} {v : Value} (h : runOn (resolveFloat f r) o s = (.ok v, s1)) :
    ∃ bits, v = .float f bits ∧ s1.mem = s.mem ∧ s1.stack = s.stack ∧
      ∀ ch, NanPicks o s ch → resolveNaN ch r = .ok bits := by
  cases r with
  | ok b =>
    have h' : ((Except.ok (Value.float f b), s) : Except Outcome Value × Spec.State) =
        (.ok v, s1) := h
    obtain ⟨hv, hs1⟩ := prod_ok_inj h'
    subst hs1
    exact ⟨b, hv.symm, rfl, rfl, fun _ _ => rfl⟩
  | nan cs =>
    have e : resolveFloat f (.nan cs) =
        ((choose (Ryo.Spec.Choice.nanBits f cs) : SemM Nat) >>= fun b =>
          if cs.contains b then pure (Value.float f b)
          else throwNoBehavior "NaN payload outside the allowed set") := rfl
    rw [e] at h
    obtain ⟨b, s2, h1, h2⟩ := runOn_bind_ok h
    have hch : runOn (choose (Ryo.Spec.Choice.nanBits f cs) : SemM Nat) o s =
        (.ok (o.answer s.choiceCount (Ryo.Spec.Choice.nanBits f cs) s),
          { s with choiceCount := s.choiceCount + 1 }) := rfl
    rw [hch] at h1
    obtain ⟨hb, hs2⟩ := prod_ok_inj h1
    subst hs2
    cases hc : cs.contains b with
    | false =>
      rw [hc] at h2
      exact (prod_err_ok h2).elim
    | true =>
      rw [hc] at h2
      have h3 : ((Except.ok (Value.float f b), { s with choiceCount := s.choiceCount + 1 }) :
          Except Outcome Value × Spec.State) = (.ok v, s1) := h2
      obtain ⟨hv, hs1⟩ := prod_ok_inj h3
      subst hs1
      refine ⟨b, hv.symm, rfl, rfl, fun ch hn => ?_⟩
      rw [← hb] at hc ⊢
      exact hn f cs hc

/-! ### R -/

theorem floatTy_of_parse {ty : String} {f : FloatTy} (h : OpSem.Ty.parse ty = some (.float f)) :
    floatTy (some ty) = .ok f := by
  simp [OpSem.floatTy, parseTy, h, bind, Except.bind, pure, Except.pure]

theorem tySize_of_parse_float {ty : String} {f : FloatTy}
    (h : OpSem.Ty.parse ty = some (.float f)) : tySize ty = some f.size := by
  simp [tySize, h, OpSem.Ty.size]

theorem fp_fbin {ty o : String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .fbin [ty, o] = some (binFp n) := by
  simp only [footprintOf, List.head?, Option.bind_some, h] <;> rfl

/-- `floatBin` is `resolveNaN` of `floatRes`. -/
theorem floatBin_res {op : BinOp} {o : String} (hm : floatMethod op = some o) (ch : OpSem.Choice)
    (f : FloatTy) (a b : Nat) : floatBin ch o f a b = resolveNaN ch (floatRes op f a b) := by
  cases op <;> simp [floatMethod] at hm <;> subst hm <;> rfl

/-- The forward direction of an `fbin` handler's semantics. -/
theorem opSem_fbin_fwd {op : Full.Opcode} {r : Option String} {ty o : String} {f : FloatTy}
    {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.fbin, [ty, o], r⟩) (hty : OpSem.Ty.parse ty = some (.float f))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31 ∧ -2 ^ 31 ≤ b ∧ b < 2 ^ 31)
    {ba bb : List AbstractByte} {va vb bits : Nat}
    (hra : st.readFrame a f.size = .ok ba) (hrb : st.readFrame b f.size = .ok bb)
    (hva : asNat ba = .ok va) (hvb : asNat bb = .ok vb)
    (hres : floatBin ch o f va vb = .ok bits)
    (hw : st.writeFrame d (intBytes f.size bits) = .ok st') :
    opSem op [.slot d, .slot a, .slot b] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2, hb1, hb2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfb := slot_fits hb1 hb2
  have hfp : footprint op = some (binFp f.size) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact fp_fbin (tySize_of_parse_float hty)
  have hprep : prepare op [.slot d, .slot a, .slot b] =
      .ok (⟨.fbin, [ty, o], r⟩, (binFp f.size),
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
  have hrd : readAll (binFp f.size) (opndVal op.info [.slot d, .slot a, .slot b]) st =
      .ok [("a", ba), ("b", bb)] := by
    simp only [readAll, binFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', hvb', Val.slotOff, Extent.eval, hra, hrb,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .fbin [ty, o] (mkEnv [("a", ba), ("b", bb)]
      (opndVal op.info [.slot d, .slot a, .slot b]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", intBytes f.size bits)] } := by
    simp [kindSem, floatTy_of_parse hty, mkEnv, Env.int, out, hva, hvb, hres, bind, Except.bind,
      pure, Except.pure]
  have hlen : (intBytes f.size bits).length = f.size := Ryo.Spec.Theorems.encodeBits_length _ _
  have hc : commit (binFp f.size) (opndVal op.info [.slot d, .slot a, .slot b]) st
      [("d", intBytes f.size bits)] = .ok st' := by
    simp only [commit, binFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', Val.slotOff, Extent.eval, hlen, hw,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | rw [hc]
    | rw [hst, hc]
    | erw [hc]

/-! ### The lift -/

theorem lift_binFloat {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerBinFloat Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hnan : NanPicks o s ch)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @bin d a b op oa ob om fl sd sa sb i hm ha hb htd hta htb hsd hsa hsb hsize hoff hpriv
      hii =>
    have hla := hlo a (by
      show a ∈ operandLocals oa ++ operandLocals ob
      rcases local?_cases ha with rfl | rfl <;> simp [operandLocals, placeLocals])
    have hlb := hlo b (by
      show b ∈ operandLocals oa ++ operandLocals ob
      rcases local?_cases hb with rfl | rfl <;> simp [operandLocals, placeLocals])
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := fbinInsnOk_spec hii
    rw [hmode, hρ] at hv
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb, td, ta, tb, va, vb, w, hpd, hpa, hpb', htd', hta', htb', hla0, hlb0,
      s2, hev, mem', hst, hs'⟩ := assign_binop_inv hs h
    have e4 : td = .float fl := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = .float fl := Option.some.inj (hta'.symm.trans hta)
    have e6 : tb = .float fl := Option.some.inj (htb'.symm.trans htb)
    subst e4 e5 e6
    obtain ⟨bsa, ua, hloa, hda, rfl⟩ := typedLoad_float hla0
    obtain ⟨bsb, ub, hlob, hdb, rfl⟩ := typedLoad_float hlb0
    rw [evalBinOp_float hm] at hev
    obtain ⟨bits, rfl, hm2, hk2, hR⟩ := runOn_resolveFloat hev
    have hres : floatBin ch om fl ua ub = .ok bits := by
      rw [floatBin_res hm]; exact hR ch hnan
    have hsto0 := typedStore_float hst
    rw [hm2] at hsto0
    have hsto : s.mem.store pd (encodeBits fl.size bits) .one = .ok s'.mem := by
      rw [hs']; exact hsto0
    have hstk : s'.stack = s.stack := by rw [hs']; exact hk2
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
    have hpos : 0 < sd.size := by
      rw [hsize.1]
      cases fl <;> first | decide | simp [FloatTy.size]
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    -- R's write
    have hlen : (intBytes fl.size bits).length = fl.size :=
      Ryo.Spec.Theorems.encodeBits_length _ _
    have hpw : ∀ k < (intBytes fl.size bits).length, s1.st.escapedAt (sd.off + k) = none := by
      intro k hk
      rw [hlen, ← hsize.1] at hk
      exact hpv k hk
    obtain ⟨st', hwr⟩ : ∃ st', s1.st.writeFrame sd.off (intBytes fl.size bits) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    have hop := opSem_fbin_fwd (ch := ch) hh hty ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩
      hrfa hrfb hva hvb hres hwr
    have hbs : BytesInj ι (encodeBits fl.size bits) (intBytes fl.size bits) :=
      encodeBits_inj ι _ _
    have hlen0 : (encodeBits fl.size bits).length = sd.size := by
      rw [Ryo.Spec.Theorems.encodeBits_length, hsize.1]
    obtain ⟨hmi, hrd⟩ := writeLocal_priv hrel.frame.mem ad xd hp hι hx hl haddr hpaddr hsz hpv
      hbs hlen0 hsto hwr
    have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
        p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι s1.fp st' s'.mem slot p lv := by
      intro slot p lv hr hne hap
      have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
      exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsize.1]; exact hap)
    have hnp := encodeBits_noprov fl.size bits
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb2, hle, hk⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb2,
      hle, hk⟩

/-- `LowerBinFloat` in a scope-free function: `stmt_sim`'s case, given `NanPicks`. -/
theorem stmt_sim_binFloat {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerBinFloat Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) (hnan : NanPicks o s ch) :
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
  exact liftOutN_of_lift (lift_binFloat M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl
    M.rel M.pb hnan hl2 hl1 hev)

end Ryo.Proofs.Lower
