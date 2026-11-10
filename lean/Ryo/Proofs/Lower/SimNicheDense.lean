/-
Ryo.Proofs.Lower.SimNicheDense — the simulation of `LowerNicheDense`
(`Check/Lower/NicheDense.lean`, M5b): a fused niche-discriminant switch lowered to `sub.imm`,
`br.gt.u.imm` and `switch.dense` on a temporary.

`sim_fusedNicheDense` has `sim_fused`'s statement (`SimFused.lean`), which dispatches to it;
`nicheDense_stmt_stack` and `nicheDense_kill` are `fused_stmt_stack`'s and `fused_live`'s cases.

- L0 as in `sim_fusedNiche` (`SimNiche.lean`), with `niche_rel`: the variant `tagToVariant`
  decodes is `lo + rel` (`rel` within the range, not the untagged one) or the untagged one
  (`rel` past it).
- R: the `sub.imm` is `NicheRead`'s op (`nop_step`): it writes the tag minus `niche_start`, whose
  value is `rel` (`NicheDiscr.sub_toNat`), to the temporary, keeping `FnRel`
  (`FnRel.writeTemp`, `SimSwitchStatic.lean`); the branch (`opSem_brCmpImmN_fwd`, a copy of
  `SimFused.lean`'s `opSem_brCmpImm_fwd'`, which this file can't import) is taken exactly when
  `rel > hi - lo`, to the untagged variant's target; else `switch.dense` picks entry `rel`.
- `FnRel` at the target without `_d` (`FnRel.store_dead`).
-/
import Ryo.Proofs.Lower.SimNicheRead
import Ryo.Check.Lower.NicheDense

namespace Ryo.Proofs.Lower

/-! ### `br_cmp_imm`'s forward `opSem` (`SimFused.lean`'s `opSem_brCmpImm_fwd'`) -/

section
open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem

theorem opSem_brCmpImmN_fwd {op : Full.Opcode} {r : Option String} {ty o : String} {n : Nat}
    {sg : Bool} {k2 k3 k4 : OperandKind} {a : Int} {y : Nat} {st : OpSem.State}
    {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.br_cmp_imm, [ty, o], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"a", .slot⟩, ⟨"imm", k2⟩, ⟨"neg", k3⟩, ⟨"t", k4⟩])
    (hfa : Val.fits .slot (.slot a) = true) (hk2 : Val.fits k2 (.imm y) = true)
    (hk3 : Val.fits k3 .none = true) (hk4 : Val.fits k4 .none = true)
    {ba : List AbstractByte} {va : Nat} {res : Bool}
    (hra : st.readFrame a n = .ok ba) (hva : asNat ba = .ok va)
    (hres : intCmp o sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) y) = .ok res) :
    opSem op [.slot a, .imm y, .none, .none] st ch = .ok (.branch res, st) := by
  have hfp : footprint op = some { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch } := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.2.2.2.2.2.2.2
  have hprep : prepare op [.slot a, .imm y, .none, .none] =
      .ok (⟨.br_cmp_imm, [ty, o], r⟩,
        { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch },
        opndVal op.info [.slot a, .imm y, .none, .none]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfa, hk2, hk3, hk4])]
    rfl
  have hva' : opndVal op.info [.slot a, .imm y, .none, .none] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvy : opndVal op.info [.slot a, .imm y, .none, .none] "imm" = some (.imm y) := by
    simp [opndVal, ho]
  have hrd : readAll { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch }
      (opndVal op.info [.slot a, .imm y, .none, .none]) st = .ok [("a", ba)] := by
    simp only [readAll, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', Val.slotOff, Extent.eval, hra,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .br_cmp_imm [ty, o]
      (mkEnv [("a", ba)] (opndVal op.info [.slot a, .imm y, .none, .none]) st ch) =
      .ok { ctl := .branch res, mem := st.mem, writes := [] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, Env.immBv,
      Env.imm, out, hva, hvy, hres, bind, Except.bind, pure, Except.pure]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure, commit,
    List.foldlM_nil, hst]

end

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Vm.OpSem Ryo.Check.Lower

/-- `brCmpImmOpsN`'s facts (`SimFused.lean`'s `brCmpImmOps_spec`). -/
theorem brCmpImmOpsN_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {sg : Bool} {o : String} {a : Int}
    {y : Nat} {neg : Bool} {t : Nat} (h : brCmpImmOpsN Γ i n sg = some (o, a, y, neg, t)) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.br_cmp_imm, [ty, o], r⟩ ∧
      cmpTyOk ty o n sg = true ∧ v.ops = [.slot a, .imm y, .none, .none] ∧
      v.ctl = some (.branch neg t) ∧
      v.op.info.operands.map (·.name) = ["a", "imm", "neg", "t"] ∧
      v.op.info.operands.head?.map (·.kind) = some .slot := by
  unfold brCmpImmOpsN at h
  split at h
  next v hv =>
    split at h
    next ty o' r a' y' neg' t' hh hops hctl =>
      split at h
      next hc =>
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := h
        simp only [Bool.and_eq_true, beq_iff_eq] at hc
        obtain ⟨⟨hty, hn⟩, hk⟩ := hc
        exact ⟨v, ty, r, hv, hh, hty, hops, hctl, hn, hk⟩
      next => cases h
    next => cases h
  next => cases h

/-- A niche encoding's decoded variant from the relative value `rel` (the tag minus the niche
start): `lo + rel` within the range (not the untagged variant), else the untagged one. -/
theorem niche_rel {vs : List Spec.Variant} {discrTy : IntType} {tag : TagInfo} {u idx : Nat}
    {untagged lo hi ns : Nat} (henc : tag.encoding = .niche untagged lo hi ns)
    (h : tagToVariant vs discrTy tag u = .ok idx) :
    ((u + tag.tag.modulus - ns % tag.tag.modulus) % tag.tag.modulus ≤ hi - lo ∧
        idx = lo + (u + tag.tag.modulus - ns % tag.tag.modulus) % tag.tag.modulus ∧
        idx ≠ untagged) ∨
      (¬ (u + tag.tag.modulus - ns % tag.tag.modulus) % tag.tag.modulus ≤ hi - lo ∧
        idx = untagged) := by
  unfold tagToVariant at h
  rw [henc] at h
  simp only at h
  split at h
  · rename_i hrel
    split at h
    · cases h
    · rename_i hne
      have h' : lo + (u + tag.tag.modulus - ns % tag.tag.modulus) % tag.tag.modulus = idx := by
        simpa using h
      refine .inl ⟨hrel, h'.symm, ?_⟩
      rw [← h']
      simpa using hne
  · rename_i hrel
    split at h
    · cases h
    · have h' : untagged = idx := by simpa using h
      exact .inr ⟨hrel, h'.symm⟩

/-- The statement leaves L0's stack as it is (`fused_stmt_stack`'s case). -/
theorem nicheDense_stmt_stack {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerNicheDense Γ next st term is) {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (h : runOn (evalStatement st) o s = (.ok (), s')) :
    s'.stack = s.stack := by
  cases hlow with
  | mk dl e od vs discrTy tag esz eal t vd sd se cs ow untagged lo hi ns i1 i2 i3 hd hte htd
      hsd hse henc hsize hoff hpriv hok hdead =>
    rw [hbody] at hte htd
    obtain ⟨-, -, -, -, -, -, -, hstk⟩ := discr_assign_inv hs hte htd h
    exact hstk

/-- The statement kills `_d`, dead at every successor (`fused_live`'s `hkc`). -/
theorem nicheDense_kill {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerNicheDense Γ next st term is) {b' : Nat}
    (hsucc : b' ∈ termSuccs term) :
    ∃ c, stmtKill st = some c ∧ (computeLive Γ.body).get b' 0 c = false := by
  cases hlow with
  | mk dl e od vs discrTy tag esz eal t vd sd se cs ow untagged lo hi ns i1 i2 i3 hd hte htd
      hsd hse henc hsize hoff hpriv hok hdead =>
    refine ⟨dl, rfl, ?_⟩
    have h := List.all_eq_true.mp hdead b' hsucc
    simpa using h

/-- A fused niche-discriminant switch in the dense form (see the module comment),
`sim_fused`'s statement. -/
theorem sim_fusedNicheDense {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o0 o : Spec.Oracle} {s0 sx s s' : Spec.State}
    {f f1 : Spec.Frame} {rest rest1 : List Spec.Frame} (hs0 : s0.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {next : Nat} {st : Statement} {term : Terminator} {is : List Insn}
    (hlow : LowerNicheDense Γ next st term is) (hat : TermAt c s1 next is)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s0.mem s1) (hpb : ProvBounded s0.mem)
    (hlo : ∀ l ∈ stmtReads st, live l = true)
    (hw : ∀ l, live' l = true → live l = true ∧ stmtKill st ≠ some l)
    (h1 : runOn (evalStatement st) o0 s0 = (.ok (), sx)) (hsx : sx.stack = f1 :: rest1)
    (hs : s = { sx with stack := { f1 with stmt := f1.stmt + 1 } :: rest1 })
    (h2 : runOn (evalTerminator term) o s = (.ok (), s')) :
    ∃ s1' b', StepsTo c ch s1 s1' ∧ s'.stack = { f with bb := b', stmt := 0 } :: rest ∧
      b' ∈ termSuccs term ∧ blockStart Γ b' = some s1'.pc ∧ ProvBounded s'.mem ∧
      s'.mem.allocs.size = s0.mem.allocs.size ∧ MemKept s0.mem s'.mem ∧
      FnRel Γ.toStmtCtx ι live' { f with bb := b', stmt := 0 } s'.mem s1' := by
  rcases hlow with ⟨dl, e, od, vs, discrTy, tag, esz, eal, t, vd, sd, se, cs, ow, untagged, lo,
    hi, ns, i1, i2, i3, hd, hte, htd, hsd, hse, henc, hsize, hoff, hpriv, hok, hdead⟩
  -- the rule's facts
  unfold nicheDenseOk at hok
  rcases hr1 : dstSlot Γ.toStmtCtx i1 with _ | r
  · simp [hr1] at hok
  simp only [hr1] at hok
  rcases hb2 : brCmpImmOpsN Γ.toStmtCtx i2 tag.tag.size false with _ | ⟨oN, r2, y, neg, tg⟩
  · simp [hb2] at hok
  rcases hd3 : denseOps Γ.toStmtCtx i3 tag.tag.size with _ | ⟨r3, base, len, ts⟩
  · simp [hb2, hd3] at hok
  simp only [hb2, hd3, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at hok
  obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨hroff, hrpriv⟩, hrap⟩, hi1⟩, ho⟩, hr2⟩, hneg⟩, hy⟩, hrange⟩, hr3⟩,
    hbase⟩, hlen⟩, hut⟩, harms⟩ := hok
  subst ho hneg hlen
  rw [hr2] at hb2
  rw [hr3] at hd3
  have htagpos : @LT.lt Nat _ 0 tag.tag.size := hsize.2.1
  -- L0
  rw [hbody] at hte htd
  obtain ⟨pd, pe, idx, hpd, hpe, hrd, hsto, hstk⟩ := discr_assign_inv hs0 hte htd h1
  obtain ⟨bs, u, hld, hdb, htv⟩ := readDiscr_multiple_inv hrd
  -- R's tag bytes
  have hle : live e = true := hlo e (by simp [stmtReads, rvalueLocals, placeLocals])
  have hre := hrel.opnd hpe hse hle
  have hn0 : tag.tag.size ≠ 0 := Nat.pos_iff_ne_zero.mp hsize.2.1
  obtain ⟨id, hid, hpid, -, hlo', -⟩ := load_eq_ok_pos hn0 hld
  have hle2 : pe.addr ≤ (pe.wrappingOffset tag.offset).addr :=
    start_le (q := pe.wrappingOffset tag.offset) hre rfl hid hpid hlo'
  have hoffNat : tag.offset < 2 ^ 64 := by
    have hA := offOk_spec hoff.1
    have hB := offOk_spec hoff.2
    try dsimp only [Size, Offset] at *
    omega
  rw [wrappingOffset_eq hoffNat hle2] at hld
  obtain ⟨ba, hrf, hia⟩ := readLocal_sub_inj hrel.frame.mem hre hsize.2.2 hld
  have hda := decodeBits_inj hia hdb
  have hva : asNat ba = .ok u := by unfold asNat; rw [hda] <;> rfl
  have hlenba : ba.length = tag.tag.size := (BytesInj.length hia).symm.trans (load_length hld)
  have hlt : u < 2 ^ (8 * tag.tag.size) := by
    have h0 := Ryo.Spec.Theorems.decodeBits_length hdb
    rw [load_length hld] at h0
    exact h0
  -- the relative value
  generalize hR : BitVec.ofNat (8 * tag.tag.size) u - BitVec.ofNat (8 * tag.tag.size) ns = Rv
  have hRrel : Rv.toNat = (u + tag.tag.modulus - ns % tag.tag.modulus) % tag.tag.modulus := by
    rw [← hR, Ryo.Proofs.NicheDiscr.sub_toNat (8 * tag.tag.size) u ns hlt, modulus_eq_two_pow]
  have hrange' : hi - lo < 2 ^ (8 * tag.tag.size) := by rw [modulus_eq_two_pow]; exact hrange
  -- the `sub.imm`
  obtain ⟨hi0, hsc0⟩ := hat.head
  have hpl1 : PlainView c.mode c.ρ i1 := hpl i1 (by simp)
  have hv1 : (NOp.binImm "wrapping_sub" tag.tag.size r (se.off + tag.offset) ns).val
      (fun o => if o = se.off + tag.offset then some u else none) = some Rv.toNat := by
    have hE0 : (fun o => if o = se.off + tag.offset then some u else none : Int → Option Nat)
        (se.off + tag.offset) = some u := by simp
    rw [val_binImm hE0, binPure_sub, hR] <;> rfl
  obtain ⟨wb, hwlen, hwa, -, hwr⟩ := nop_step (ch := ch) hmode.symm hρ.symm
    (op := NOp.binImm "wrapping_sub" tag.tag.size r (se.off + tag.offset) ns) hi1 hpl1
    (st := s1.st)
    (fun p hp x hx => by
      simp only [NOp.srcs, List.mem_singleton] at hp
      subst hp
      simp at hx
      subst hx
      exact ⟨ba, hrf, hva, hlenba, hlt⟩)
    (fun p hp => by
      simp only [NOp.dst, NOp.srcs, List.mem_cons, List.mem_nil_iff, or_false] at hp
      rcases hp with rfl | rfl
      · exact offOk_spec hroff
      · exact offOk_spec hoff.2) hv1
  have hwlen' : wb.length = tag.tag.size := hwlen
  have hpw : ∀ k < wb.length, s1.st.escapedAt (r + k) = none := by
    intro k hk
    rw [hwlen'] at hk
    cases he' : s1.st.escapedAt (r + k) with
    | none => rfl
    | some e'' =>
      have h1' := hrel.esc _ _ he'
      rw [privOk_spec hrpriv k hk] at h1'
      cases h1'
  obtain ⟨st1, hw1⟩ : ∃ st1, s1.st.writeFrame r wb = .ok st1 := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  obtain ⟨vw1, hvw1, hctl1, hop1⟩ := hwr st1 hw1
  have hstep1 : R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st1 }) :=
    step_of_view hi0 hsc0 hat.pe hpl1 hvw1 hctl1 hop1
  have hrel1 := hrel.writeTemp hw1 hpw
    (fun l sl hsl => by rw [hwlen']; exact tempApart_spec hrap hsl) (s1.pc + 1)
  have hrb : st1.readFrame r tag.tag.size = .ok wb := by
    have := readFrame_written hw1 hpw
    rw [hwlen'] at this
    exact this
  -- the branch
  have hat2 := hat.tail
  obtain ⟨hi2, hsc2⟩ := hat2.head
  have hpl2 : PlainView c.mode c.ρ i2 := hpl i2 (by simp)
  obtain ⟨vw2, ty2, rr2, hvw2, hh2, hty2, hops2, hctl2, hn2, hk2⟩ := brCmpImmOpsN_spec hb2
  rw [← hmode, ← hρ] at hvw2
  obtain ⟨sg2, hps2, hsg2⟩ := cmpTyOk_spec hty2
  have hsg2' : sg2 = false := by
    rcases hsg2 with (e' | e') | e'
    · exact absurd e' (by decide)
    · exact absurd e' (by decide)
    · exact e'
  subst hsg2'
  obtain ⟨k2, k3, k4, ho2⟩ := operands4 hn2 hk2
  have hfits2 := hpl2.fits vw2 hvw2
  rw [ho2, hops2] at hfits2
  simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
    Bool.and_true, Bool.and_eq_true] at hfits2
  obtain ⟨hfa2, hk2', hk3', hk4'⟩ := hfits2
  have hK : BitVec.ofNat (8 * tag.tag.size) y = BitVec.ofNat (8 * tag.tag.size) (hi - lo) :=
    ofNat_eq_of_mod hy
  have hop2 : opSem vw2.op vw2.ops st1 ch =
      .ok (.branch ((BitVec.ofNat (8 * tag.tag.size) (hi - lo)).ult Rv), st1) := by
    rw [hops2]
    refine opSem_brCmpImmN_fwd hh2 hps2 ho2 hfa2 hk2' hk3' hk4' hrb hwa ?_
    rw [ofNat_toNat_self, hK]
    rfl
  have hstep2 := step_branch (s1 := { s1 with pc := s1.pc + 1, st := st1 }) hi2 hsc2 hat2.pe hpl2
    hvw2 hctl2 hop2
  have hKn : (BitVec.ofNat (8 * tag.tag.size) (hi - lo)).toNat = hi - lo := by
    rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hrange']
  have hult : (BitVec.ofNat (8 * tag.tag.size) (hi - lo)).ult Rv = decide (hi - lo < Rv.toNat) := by
    rw [BitVec.ult, hKn]
  -- R reaches the start of L0's target, its state that after the `sub.imm`
  obtain ⟨s2, hst2, hs2st, hs2fp, hb2'⟩ : ∃ s2, StepsTo c ch s1 s2 ∧ s2.st = st1 ∧
      s2.fp = s1.fp ∧
      blockStart Γ (caseTarget cs ow (nicheBits vs discrTy t idx)) = some s2.pc := by
    rcases niche_rel henc htv with ⟨hrl, hidx, hne⟩ | ⟨hrl, hidx⟩
    · -- within the range: the table
      rw [← hRrel] at hrl hidx
      have hc : ((BitVec.ofNat (8 * tag.tag.size) (hi - lo)).ult Rv != false) = false := by
        rw [hult]; simp; omega
      rw [hc] at hstep2
      simp only [Bool.false_eq_true, ↓reduceIte] at hstep2
      have hat3 := hat2.tail
      obtain ⟨hi3, hsc3⟩ := hat3.head
      have hpl3 : PlainView c.mode c.ρ i3 := hpl i3 (by simp)
      obtain ⟨vw3, ty3, rr3, hvw3, hh3, hty3, hops3, hctl3, hn3, hk3, hlen3⟩ := denseOps_spec hd3
      obtain ⟨sg3, hps3⟩ := intTyOk_spec hty3
      obtain ⟨j2, j3, j4, ho3⟩ := operandsDense hn3 hk3
      rw [← hmode, ← hρ] at hvw3
      have hfits3 := hpl3.fits vw3 hvw3
      rw [ho3, hops3] at hfits3
      simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
        Bool.and_true, Bool.and_eq_true] at hfits3
      obtain ⟨hfa3, hj2, hj3, hj4⟩ := hfits3
      have hop3 := opSem_switchDense_fwd (ch := ch) hh3 hps3 ho3 hfa3 hj2 hj3 hj4 hrb hwa
      have hb0 : BitVec.ofNat (8 * tag.tag.size) base = 0 := by
        have h0 := ofNat_eq_of_mod (w := 8 * tag.tag.size) (a := base) (b := 0)
          (by rw [hbase]; simp)
        rw [h0]; rfl
      have hsub : Rv - (0 : BitVec (8 * tag.tag.size)) = Rv := by
        apply BitVec.eq_of_toNat_eq
        simp
      rw [ofNat_toNat_self, hb0, hsub] at hop3
      rw [if_pos (show Rv.toNat < hi - lo + 1 by omega)] at hop3
      have hlt3 : Rv.toNat < ts.length := by omega
      have hget : ts[Rv.toNat]? = some ts[Rv.toNat] := List.getElem?_eq_getElem hlt3
      have hnat : ViewShape i3 := by
        intro op ops he f' hf
        subst he
        exact shapes_of_opShape (view_native_opShape hvw3 hf (by rw [hctl3]; rfl))
      have hstep3 : R.step c { s1 with pc := s1.pc + 1 + 1, st := st1 } ch =
          .ok (.step { s1 with pc := ts[Rv.toNat], st := st1 }) := by
        have hi3' : c.d.insns[s1.pc + 1 + 1]? = some i3 := hi3
        have hsc3' : c.scopesAt (s1.pc + 1 + 1) = [] := hsc3
        rw [step_eq_stepBody_nil (s := { s1 with pc := s1.pc + 1 + 1, st := st1 }) hi3' hsc3']
        exact stepBody_switch hnat hvw3 hctl3 (hpl3.notResume _ hvw3 (ctl_ne_trap hctl3))
          (hpl3.notUnreachable _ hvw3 (ctl_ne_trap hctl3)) hat3.pe (by rw [hops3]; exact hop3) hget
      refine ⟨{ s1 with pc := ts[Rv.toNat], st := st1 },
        .cons hstep1 (.cons hstep2 (.cons hstep3 (.refl _))), rfl, rfl, ?_⟩
      have harm := List.all_eq_true.mp harms Rv.toNat (List.mem_range.mpr (by omega))
      rw [hget] at harm
      simp only [Bool.or_eq_true, beq_iff_eq] at harm
      rcases harm with harm | harm
      · exact absurd (hidx.trans harm) hne
      · rw [hidx]
        simpa [startOk] using harm
    · -- past the range: the branch, to the untagged variant's target
      rw [← hRrel] at hrl
      have hc : ((BitVec.ofNat (8 * tag.tag.size) (hi - lo)).ult Rv != false) = true := by
        rw [hult]; simp; omega
      rw [hc] at hstep2
      simp only [↓reduceIte] at hstep2
      refine ⟨{ s1 with pc := tg, st := st1 }, .cons hstep1 (.cons hstep2 (.refl _)), rfl, rfl,
        ?_⟩
      rw [hidx]
      simpa [startOk] using hut
  -- L0's switch
  have hstk' : f :: rest = f1 :: rest1 := (hsx.symm.trans (hstk.trans hs0)).symm
  obtain ⟨rfl, rfl⟩ := List.cons.inj hstk'
  have hsS : s.stack = { f with stmt := f.stmt + 1 } :: rest := by rw [hs]
  have hstoS : s0.mem.store pd (encodeBits t.size (t.toBits (t.bringInBounds
      (discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0))))) .one = .ok s.mem := by
    rw [hs]; exact hsto
  have hs2' := niche_switch_l0 (f := { f with stmt := f.stmt + 1 }) hsS hd hpd htd hstoS h2
  have hm' : s'.mem = sx.mem := by rw [hs2', hs]
  have hw' : ∀ l, live' l = true → live l = true ∧ l ≠ dl := fun l hl =>
    ⟨(hw l hl).1, fun e' => (hw l hl).2 (by subst e'; rfl)⟩
  refine ⟨s2, caseTarget cs ow (nicheBits vs discrTy t idx), hst2, ?_,
    caseTarget_mem_termSuccs _, hb2', ?_, ?_, ?_, ?_⟩
  · rw [hs2']
    try rfl
  · rw [hm']; exact hpb.store_noprov hsto (encodeBits_noprov _ _)
  · rw [hm']; exact store_size hsto
  · rw [hm']; exact memKept_noprov hsto (encodeBits_noprov _ _)
  · rw [hm']
    exact (FnRel.store_dead hrel1 hpd hsd hsize.1 hpriv hsto (encodeBits_noprov _ _)
      hw').congr rfl rfl hs2st hs2fp

end Ryo.Proofs.Lower
