/-
Ryo.Proofs.Lower.SimFloatCast — the simulation of `LowerFloatCast`
(`Check/Lower/FloatCast.lean`, M5b): a cast involving floats between locals lowered to one `cvt`.

- L0 (`assign_castLocal_inv`: `SimIntCast.assign_intCast_inv` for any kind): the source loads
  at its type (`typedLoad_float`, `typedLoad_int`), `evalCast` computes `Float.toInt`,
  `Float.ofInt` or `resolveFloat` of `Float.convert` (by `rfl`), the store writes its bits
  (`typedStore_int`, `typedStore_float`).
- R (`opSem_cvtG_fwd`, `opSem_cvt_fwd` for any parameter types): `convert` on the same bits
  (`decodeBits_inj`) computes the same function: `BitVec.ofInt` of `Float.toInt` is
  `t.toBits` of it (`f2i_bits`), an integer read signed or not is `t.ofBits` of its bits
  (`i2f_val`, `SimCmp.ofBits_bv`), and `Float.convert`'s NaN is resolved as in `SimBinFloat`
  (`NanPicks`).
- The written bytes carry no provenance (`lift_writeBytes`, `lift_binFloat`'s tail).
-/
import Ryo.Proofs.Lower.SimBinFloat
import Ryo.Proofs.Lower.SimCmp
import Ryo.Proofs.Lower.SimIntCast
import Ryo.Check.Lower.FloatCast

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### L0 -/

/-- A cast of a whole local into a whole local, run to success. -/
theorem assign_castLocal_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    (ha : oa.local? = some a) {k : CastKind} {ty : Spec.Ty}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k oa ty))) o s = (.ok (), s')) :
    ∃ pd pa td ta va v s2, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      f.body.locals[d]? = some td ∧ f.body.locals[a]? = some ta ∧
      typedLoad s.mem pa ta .one = .ok va ∧ runOn (evalCast k (va, ta) ty) o s = (.ok v, s2) ∧
      ∃ mem', typedStore s2.mem pd v td .one = .ok mem' ∧ s' = { s2 with mem := mem' } := by
  rcases local?_cases ha with rfl | rfl
  all_goals
    have hn : evalStatement (.assign ⟨d, []⟩ (.cast k (.move ⟨a, []⟩) ty)) =
        evalStatement (.assign ⟨d, []⟩ (.cast k (.copy ⟨a, []⟩) ty)) := by
      first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]
    try rw [hn] at h
    clear hn
    have e : evalStatement (.assign ⟨d, []⟩ (.cast k (.copy ⟨a, []⟩) ty)) =
        (evalPlace ⟨d, []⟩ >>= fun x => match x with
          | (pl, ty') => evalRvalue (.cast k (.copy ⟨a, []⟩) ty) ty' >>=
              fun v => placeStore pl v ty') := by
      first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
    rw [e] at h
    obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
    rw [runOn_evalPlace_nil] at h1
    obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
    subst hx
    have h2' : runOn (evalRvalue (.cast k (.copy ⟨a, []⟩) ty) td >>= fun v =>
        placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
    rw [hs1] at h2'
    obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
    have e2 : evalRvalue (.cast k (.copy ⟨a, []⟩) ty) td =
        (evalOperand (.copy ⟨a, []⟩) >>= fun r => evalCast k r ty) := by
      first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
    rw [e2] at h3
    obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
    obtain ⟨pa, ta, va, hla, hta, hva, hr, hs3⟩ := runOn_evalOperand_copy hs h5
    subst r
    subst s3
    obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
    exact ⟨pd, pa, td, ta, va, v, s2, hld, hla, htd, hta, hva, h6, mem', hst, hs'⟩

/-! ### The bits -/

/-- R's `BitVec.ofInt` of an integer is `t.toBits` of it. -/
theorem f2i_bits (t : IntType) (i : Int) : (BitVec.ofInt (8 * t.size) i).toNat = t.toBits i := by
  rw [BitVec.toNat_ofInt, modulus_eq_two_pow t] <;> rfl

/-- R's reading of an integer's bits (signed or not) is L0's `t.ofBits`. -/
theorem i2f_val (t : IntType) {u : Nat} (hu : u < 2 ^ (8 * t.size)) :
    (if t.signed then (BitVec.ofNat (8 * t.size) u).toInt else (u : Int)) = t.ofBits u := by
  rw [ofBits_bv t u]
  cases t.signed
  · simp only [Bool.false_eq_true, ↓reduceIte, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hu]
  · rfl

/-! ### R -/

/-- The forward direction of a `cvt` handler between any two parameter types. -/
theorem opSem_cvtG_fwd {op : Full.Opcode} {r : Option String} {tx ty : String}
    {X Y : OpSem.Ty} {d s : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.cvt, [tx, ty], r⟩) (htx : OpSem.Ty.parse tx = some X)
    (hty : OpSem.Ty.parse ty = some Y)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ s ∧ s < 2 ^ 31)
    {bs : List AbstractByte} {v w : Nat} (hr : st.readFrame s X.size = .ok bs)
    (hv : asNat bs = .ok v) (hres : convert ch X Y v = .ok w)
    (hw : st.writeFrame d (intBytes Y.size w) = .ok st') :
    opSem op [.slot d, .slot s] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, hs1, hs2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfs := slot_fits hs1 hs2
  have hsx : tySize tx = some X.size := by simp [tySize, htx]
  have hsy : tySize ty = some Y.size := by simp [tySize, hty]
  have hfp : footprint op = some (cvtFp X.size Y.size) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact Ryo.Proofs.Inline.fp_cvt hsx hsy
  have hprep : prepare op [.slot d, .slot s] =
      .ok (⟨.cvt, [tx, ty], r⟩, (cvtFp X.size Y.size), opndVal op.info [.slot d, .slot s]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfs])]
    rfl
  have hvs : opndVal op.info [.slot d, .slot s] "s" = some (.slot s) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .slot s] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (cvtFp X.size Y.size) (opndVal op.info [.slot d, .slot s]) st =
      .ok [("s", bs)] := by
    simp only [readAll, cvtFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvs, Val.slotOff, Extent.eval, hr,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .cvt [tx, ty] (mkEnv [("s", bs)] (opndVal op.info [.slot d, .slot s]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", intBytes Y.size w)] } := by
    simp [kindSem, parseTy, htx, hty, mkEnv, Env.int, hv, hres, out, bind, Except.bind, pure,
      Except.pure]
  have hlen : (intBytes Y.size w).length = Y.size := Ryo.Spec.Theorems.encodeBits_length _ _
  have hc : commit (cvtFp X.size Y.size) (opndVal op.info [.slot d, .slot s]) st
      [("d", intBytes Y.size w)] = .ok st' := by
    simp only [commit, cvtFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff, Extent.eval, hlen,
      hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)

/-! ### The lift -/

/-- The common tail: one instruction writing `intBytes n w` into `_d`'s private slot, against
L0's store of the same bytes. -/
theorem lift_writeBytes {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    {i : R.Insn} {v : R.View} (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = [])
    (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i) (hv : R.view c.mode c.ρ i = some v)
    (hctl : v.ctl = some .next) (hrel : FnRel Γ ι live f s.mem s1) (hpb : ProvBounded s.mem)
    {d : Local} {pd : ThinPointer} {sd : LocalSlot} {n w : Nat}
    (hpd : f.locals[d]? = some (some pd)) (hsd : Γ.slots[d]? = some sd) (hsz : sd.size = n)
    (hpos : 0 < n) (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
    (hsto : s.mem.store pd (encodeBits n w) .one = .ok s'.mem) (hstk : s'.stack = s.stack)
    (hop : ∀ st', s1.st.writeFrame sd.off (intBytes n w) = .ok st' →
      opSem v.op v.ops s1.st ch = .ok (.next, st'))
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  have hpos' : 0 < sd.size := by rw [hsz]; exact hpos
  obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz', hpv⟩ :=
    hrel.priv_dst hpd hsd hpos' hpriv
  have hlen : (intBytes n w).length = n := Ryo.Spec.Theorems.encodeBits_length _ _
  have hpw : ∀ k < (intBytes n w).length, s1.st.escapedAt (sd.off + k) = none := by
    intro k hk
    rw [hlen, ← hsz] at hk
    exact hpv k hk
  obtain ⟨st', hwr⟩ : ∃ st', s1.st.writeFrame sd.off (intBytes n w) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop' := hop st' hwr
  have hbs : BytesInj ι (encodeBits n w) (intBytes n w) := encodeBits_inj ι _ _
  have hlen0 : (encodeBits n w).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsz]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hrel.frame.mem ad xd hp hι hx hl haddr hpaddr hsz' hpv
    hbs hlen0 hsto hwr
  have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
      p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' s'.mem slot p lv := by
    intro slot p lv hr hne hap
    have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
    exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsz]; exact hap)
  have hnp := encodeBits_noprov n w
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop').2.1
  obtain ⟨hpb2, hle, hk⟩ := memInv_store hpb hsto hnp
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl hop', hstk,
    hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb2,
    hle, hk⟩

theorem floatTy_size_pos (f : FloatTy) : 0 < f.size := by
  cases f <;> first | decide | simp [FloatTy.size]

theorem lift_floatCast {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerFloatCast Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hnan : NanPicks o s ch) (hwf : IntsSized f.body)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @f2i d a oa fl t vd vc sd sa i ha htd hta hsd hsa hsize hoff hpriv hii =>
    have hla := hlo a (by
      show a ∈ operandLocals oa
      rcases local?_cases ha with rfl | rfl <;> simp [operandLocals, placeLocals])
    obtain ⟨v, tx, ty, r, hv, hh, htx, hty, ho, hops, hctl⟩ := cvtInsnOk_spec hii
    rw [hmode, hρ] at hv
    rw [hbody] at htd hta
    obtain ⟨pd, pa, td, ta, va, w, s2, hpd, hpa, htd', hta', hla0, hev, mem', hst, hs'⟩ :=
      assign_castLocal_inv hs ha h
    have e4 : td = .int t vd := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = .float fl := Option.some.inj (hta'.symm.trans hta)
    subst e4 e5
    obtain ⟨bsa, ua, hloa, hda, rfl⟩ := typedLoad_float hla0
    have hev' : ((Except.ok (Value.int (Ryo.Spec.Float.toInt fl t ua)), s) :
        Except Outcome Value × Spec.State) = (.ok w, s2) := hev
    obtain ⟨hw, hs2⟩ := prod_ok_inj hev'
    subst hw
    rw [← hs2] at hst hs'
    have hsto : s.mem.store pd (encodeBits t.size (t.toBits (Ryo.Spec.Float.toInt fl t ua))) .one =
        .ok s'.mem := by
      rw [hs']; exact typedStore_int hst
    have hstk : s'.stack = s.stack := by rw [hs']
    have hra := hrel.opnd hpa hsa hla
    rw [← hsize.2] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsize.2] at hrfa
    have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hres : convert ch (.float fl) (.int t.size t.signed) ua =
        .ok (t.toBits (Ryo.Spec.Float.toInt fl t ua)) := by
      rw [← f2i_bits] <;> rfl
    exact lift_writeBytes hi hsc hpe hpl hv hctl hrel hpb hpd hsd hsize.1
      (hwf d t vd htd)
      hpriv hsto hstk
      (fun st' hwr => by
        rw [hops]
        exact opSem_cvtG_fwd hh htx hty ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfa hva hres hwr)
      hlive'
  | @i2f d a oa g t vt sd sa i ha htd hta hsd hsa hsize hoff hpriv hii =>
    have hla := hlo a (by
      show a ∈ operandLocals oa
      rcases local?_cases ha with rfl | rfl <;> simp [operandLocals, placeLocals])
    obtain ⟨v, tx, ty, r, hv, hh, htx, hty, ho, hops, hctl⟩ := cvtInsnOk_spec hii
    rw [hmode, hρ] at hv
    rw [hbody] at htd hta
    obtain ⟨pd, pa, td, ta, va, w, s2, hpd, hpa, htd', hta', hla0, hev, mem', hst, hs'⟩ :=
      assign_castLocal_inv hs ha h
    have e4 : td = .float g := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = .int t vt := Option.some.inj (hta'.symm.trans hta)
    subst e4 e5
    obtain ⟨bsa, ua, hloa, hda, hlena, rfl⟩ := typedLoad_int hla0
    have hev' : ((Except.ok (Value.float g (Ryo.Spec.Float.ofInt g (t.ofBits ua))), s) :
        Except Outcome Value × Spec.State) = (.ok w, s2) := hev
    obtain ⟨hw, hs2⟩ := prod_ok_inj hev'
    subst hw
    rw [← hs2] at hst hs'
    have hsto : s.mem.store pd (encodeBits g.size (Ryo.Spec.Float.ofInt g (t.ofBits ua))) .one =
        .ok s'.mem := by
      rw [hs']; exact typedStore_float hst
    have hstk : s'.stack = s.stack := by rw [hs']
    have hra := hrel.opnd hpa hsa hla
    rw [← hsize.2] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsize.2] at hrfa
    have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
    have hu : ua < 2 ^ (8 * t.size) := by
      have := Ryo.Proofs.Provenance.decodeBits_lt hda
      rw [hlena] at this
      exact this
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hres : convert ch (.int t.size t.signed) (.float g) ua =
        .ok (Ryo.Spec.Float.ofInt g (t.ofBits ua)) := by
      rw [← i2f_val t hu] <;> rfl
    exact lift_writeBytes hi hsc hpe hpl hv hctl hrel hpb hpd hsd hsize.1 (floatTy_size_pos g)
      hpriv hsto hstk
      (fun st' hwr => by
        rw [hops]
        exact opSem_cvtG_fwd hh htx hty ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfa hva hres hwr)
      hlive'
  | @f2f d a oa fl g sd sa i ha htd hta hsd hsa hsize hoff hpriv hii =>
    have hla := hlo a (by
      show a ∈ operandLocals oa
      rcases local?_cases ha with rfl | rfl <;> simp [operandLocals, placeLocals])
    obtain ⟨v, tx, ty, r, hv, hh, htx, hty, ho, hops, hctl⟩ := cvtInsnOk_spec hii
    rw [hmode, hρ] at hv
    rw [hbody] at htd hta
    obtain ⟨pd, pa, td, ta, va, w, s2, hpd, hpa, htd', hta', hla0, hev, mem', hst, hs'⟩ :=
      assign_castLocal_inv hs ha h
    have e4 : td = .float g := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = .float fl := Option.some.inj (hta'.symm.trans hta)
    subst e4 e5
    obtain ⟨bsa, ua, hloa, hda, rfl⟩ := typedLoad_float hla0
    have hev' : runOn (resolveFloat g (Ryo.Spec.Float.convert fl g ua)) o s = (.ok w, s2) := hev
    obtain ⟨bits, rfl, hm2, hk2, hR⟩ := runOn_resolveFloat hev'
    have hsto0 := typedStore_float hst
    rw [hm2] at hsto0
    have hsto : s.mem.store pd (encodeBits g.size bits) .one = .ok s'.mem := by
      rw [hs']; exact hsto0
    have hstk : s'.stack = s.stack := by rw [hs']; exact hk2
    have hra := hrel.opnd hpa hsa hla
    rw [← hsize.2] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsize.2] at hrfa
    have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hres : convert ch (.float fl) (.float g) ua = .ok bits := hR ch hnan
    exact lift_writeBytes hi hsc hpe hpl hv hctl hrel hpb hpd hsd hsize.1 (floatTy_size_pos g)
      hpriv hsto hstk
      (fun st' hwr => by
        rw [hops]
        exact opSem_cvtG_fwd hh htx hty ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfa hva hres hwr)
      hlive'

/-- `LowerFloatCast` in a scope-free function: `stmt_sim`'s case, given `NanPicks`. -/
theorem stmt_sim_floatCast {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerFloatCast Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) (hnan : NanPicks o s ch) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  have hwf : IntsSized f.body := by rw [M.body]; exact hfn.ints
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  refine stmtOut_of_liftN (k := 1) M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv
    (by rw [hpc0, he]) ?_
  exact liftOutN_of_lift (lift_floatCast M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl
    M.rel M.pb hnan hwf hl2 hl1 hev)

end Ryo.Proofs.Lower
