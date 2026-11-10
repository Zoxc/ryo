/-
Ryo.Proofs.Lower.ScopeMulti — `stmt_simX`'s remaining cases (StmtSimX.lean): `StorageLive`
under pending scopes, and the statements whose lift is a `LiftOutN` (the deref `store`, `enum`,
`agg`), on scope-free code from the fold `s0`.

**Multi-instruction lifts.** A `LiftOutN` gives a `StepsTo` to `pc + k`, which may in principle
run past the range and come back. The lifts are run on `c.cut e` (`e` the range's end): the
code without scopes and without the instructions from `e` on, so a run on it stops at `e`
(`step_cut_lt`: no instruction is no step). Every step of such a run from `pc ∈ [r.1, e)` is a
fall-through view (`LowersFnX.stmtsX.next`), so it is `opSem` on the state, keeps the escaped
objects and `AllocsKept` (`step_cut_inv`), and is also `c`'s step: the first from `s1` through
its scopes (`step_of_view_scopes` with the fold to `s0`), the later ones with no scopes
(`stmtInner`; `run_cut`). `fnRelX_keep` then lifts `FnRel` to `FnRelX` (as
`liftOutX_of_liftOut`), and `stmtOutX_of_liftN` assembles `StmtOutX` (no pending `End` after a
non-empty range, `stmtsX.pend0`; an empty range leaves R at `s1` and the pending list unchanged,
`pendSpecs_succ`).

**`StorageLive _l`** (`stmt_simX_storageLive`): R doesn't step; `lift_storageLive` on `s0` with
`hpriv` from `storageLive_privX`; `live_fnRelX` the escape invariants for the new frame (the
new allocation is fresh, so `ι` maps it nowhere; `_l`'s address is aligned by `allocate`'s
`addrOk`).
-/
import Ryo.Proofs.Lower.SimRef

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Code cut at a range's end -/

/-- `c` without scopes and without the instructions from `e` on. -/
def _root_.Ryo.Vm.R.Code.cut (c : R.Code) (e : Nat) : R.Code :=
  ({ c with d := { c.d with insns := c.d.insns.extract 0 e } } : R.Code).dropScopes

theorem cut_scopesAt (c : R.Code) (e k : Nat) : (c.cut e).scopesAt k = [] := by
  unfold R.Code.cut
  exact dropScopes_scopesAt _ k

theorem cut_lt {c : R.Code} {e k : Nat} (h : k < e) :
    (c.cut e).d.insns[k]? = c.d.insns[k]? := by
  show (c.d.insns.extract 0 e)[k]? = c.d.insns[k]?
  rw [Array.getElem?_extract]
  by_cases hs : k < c.d.insns.size
  · rw [if_pos (by omega), Nat.zero_add]
  · rw [if_neg (by omega)]
    exact (Array.getElem?_eq_none (by omega)).symm

theorem cut_ge {c : R.Code} {e k : Nat} (h : e ≤ k) : (c.cut e).d.insns[k]? = none := by
  show (c.d.insns.extract 0 e)[k]? = none
  rw [Array.getElem?_extract, if_neg (by omega)]

/-- A step of the cut code is from an instruction before `e`. -/
theorem step_cut_lt {c : R.Code} {e : Nat} {t t1 : R.RState} {ch : OpSem.Choice}
    (hs : R.step (c.cut e) t ch = .ok (.step t1)) :
    ∃ i, (c.cut e).d.insns[t.pc]? = some i ∧ t.pc < e := by
  cases hx : (c.cut e).d.insns[t.pc]? with
  | none =>
    exfalso
    unfold R.step at hs
    first
      | (simp only [hx] at hs; done)
      | (simp only [hx] at hs; cases hs)
      | (simp only [hx, illFormed, throw, throwThe, MonadExceptOf.throw] at hs; done)
      | (rw [hx] at hs; cases hs)
      | (simp [hx, illFormed, throw, throwThe, MonadExceptOf.throw, bind, Except.bind] at hs)
  | some i =>
    refine ⟨i, rfl, ?_⟩
    rcases Nat.lt_or_ge t.pc e with h | h
    · exact h
    · rw [cut_ge h] at hx
      cases hx

/-- A run of the cut code from `e` on is empty. -/
theorem steps_cut_stop {c : R.Code} {e : Nat} {t u : R.RState} {ch : OpSem.Choice}
    (h : StepsTo (c.cut e) ch t u) (hle : e ≤ t.pc) : u = t := by
  cases h with
  | refl => rfl
  | cons hs _ =>
    obtain ⟨_, _, hlt⟩ := step_cut_lt hs
    omega

/-- A fall-through step of the cut code: `opSem` on the state, the next index; it keeps the
escaped objects and the allocations (as `step_plain_keeps`). -/
theorem step_cut_inv {c : R.Code} {e : Nat} {t t1 : R.RState} {ch : OpSem.Choice} {i : R.Insn}
    {v : R.View} (hc : (c.cut e).d.insns[t.pc]? = some i) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hv : R.view c.mode c.ρ i = some v)
    (hctl : v.ctl = some .next) (h : R.step (c.cut e) t ch = .ok (.step t1)) :
    ∃ st'', opSem v.op v.ops t.st ch = .ok (.next, st'') ∧ st''.escaped = t.st.escaped ∧
      AllocsKept t.st.mem st''.mem ∧ t1 = { t with pc := t.pc + 1, st := st'' } := by
  have hnat : ViewShape i := fun op ops he f hf => by
    subst he
    exact shapes_of_opShape (view_native_opShape hv hf (by rw [hctl]; rfl))
  have hv' : R.view (c.cut e).mode (c.cut e).ρ i = some v := hv
  have hpe' : (c.cut e).mode.pe = false := hpe
  have hres := hpl.notResume v hv (ctl_ne_trap hctl)
  have hun := hpl.notUnreachable v hv (ctl_ne_trap hctl)
  rw [step_eq_stepBody_nil hc (cut_scopesAt c e _), stepBody_view (c := c.cut e) hnat ⟨v, hv'⟩]
    at h
  cases hop : opSem v.op v.ops t.st ch with
  | error err =>
    exfalso
    have h1 : (v.op == Full.Opcode.resume) = false := beq_eq_false_iff_ne.mpr hres
    have h2 : (v.op == Full.Opcode.unreachable) = false := beq_eq_false_iff_ne.mpr hun
    unfold R.stepView at h
    simp [hv', hctl, h1, h2, hop, bind, Except.bind] at h
  | ok r =>
    obtain ⟨ctl, st''⟩ := r
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    have hak := opSem_allocsKept hop
    cases ctl with
    | next =>
      have hfw := stepView_of_opSem (c := c.cut e) (s := t) hv' hctl hres hun hpe' hop rfl
      rw [hfw] at h
      injection h with h
      injection h with h
      exact ⟨st'', rfl, hesc, hak, h.symm⟩
    | branch b =>
      exfalso
      have h1 : (v.op == Full.Opcode.resume) = false := beq_eq_false_iff_ne.mpr hres
      have h2 : (v.op == Full.Opcode.unreachable) = false := beq_eq_false_iff_ne.mpr hun
      unfold R.stepView at h
      cases i <;> simp [hv', hctl, h1, h2, hop, R.Then.succ, R.clearHome, hpe', bind,
        Except.bind, pure, Except.pure, illFormed, throw, throwThe, MonadExceptOf.throw] at h
    | index k =>
      exfalso
      have h1 : (v.op == Full.Opcode.resume) = false := beq_eq_false_iff_ne.mpr hres
      have h2 : (v.op == Full.Opcode.unreachable) = false := beq_eq_false_iff_ne.mpr hun
      unfold R.stepView at h
      cases i <;> simp [hv', hctl, h1, h2, hop, R.Then.succ, R.clearHome, hpe', bind,
        Except.bind, pure, Except.pure, illFormed, throw, throwThe, MonadExceptOf.throw] at h

/-- A run of the cut code from `pc ≥ b`, where every instruction in `[b, e)` falls through and
has no scopes, is a run of `c` keeping the escaped objects and the allocations. -/
theorem run_cut {c : R.Code} {ch : OpSem.Choice} {b e : Nat} (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) (i : R.Insn), c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    (hnx : ∀ (k : Nat) (i : R.Insn), b ≤ k → k < e → c.d.insns[k]? = some i →
      ∃ v, R.view c.mode c.ρ i = some v ∧ v.ctl = some .next)
    (hsc : ∀ k, b ≤ k → k < e → c.scopesAt k = []) {t u : R.RState}
    (h : StepsTo (c.cut e) ch t u) (hb : b ≤ t.pc) :
    StepsTo c ch t u ∧ u.st.escaped = t.st.escaped ∧ AllocsKept t.st.mem u.st.mem := by
  revert hb
  induction h with
  | refl => intro _; exact ⟨.refl _, rfl, AllocsKept.refl _⟩
  | @cons x x1 y hs _ ih =>
    intro hb
    obtain ⟨i, hci, hlt⟩ := step_cut_lt hs
    have hc : c.d.insns[x.pc]? = some i := by rw [← cut_lt hlt]; exact hci
    obtain ⟨v, hv, hctl⟩ := hnx x.pc i hb hlt hc
    obtain ⟨st'', hop, hesc, hak, rfl⟩ := step_cut_inv hci hpe (hpl _ _ hc) hv hctl hs
    have hstep : R.step c x ch = .ok (.step { x with pc := x.pc + 1, st := st'' }) :=
      step_of_view_scopes (s1 := x) (s0 := x) hc (by rw [hsc x.pc hb hlt]; rfl) hpe
        (hpl _ _ hc) hv hctl hop
    obtain ⟨hr, he, ha⟩ := ih (by show b ≤ x.pc + 1; omega)
    exact ⟨.cons hstep hr, he.trans hesc, hak.trans ha⟩

/-! ### Assembling `StmtOutX` -/

/-- `FnRel` after steps that keep the escaped objects and the allocations is `FnRelX` (the body
of `liftOutX_of_liftOut`). -/
theorem fnRelX_keep {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m m' : Memory} {t : R.RState} {p : Nat} {st' : OpSem.State}
    (hX : FnRelX Γ ι live f m t)
    (hrel' : FnRel Γ ι live' f m' { t with pc := p, st := st' })
    (hesc : ({ t with pc := p, st := st' } : R.RState).st.escaped = t.st.escaped)
    (hak : AllocsKept t.st.mem ({ t with pc := p, st := st' } : R.RState).st.mem)
    (hk : MemKept m m') :
    FnRelX Γ ι live' f m' { t with pc := p, st := st' } := by
  refine ⟨hrel', fun e he => ?_, ?_, fun a b x e hι hx hl he hid => ?_,
    fun id y hy hl => ?_, hX.aligned, fun e he => ?_, fun e he y hy => ?_⟩
  · first
      | (rw [hesc] at he; exact hX.objs e he)
      | exact hX.objs e (hesc ▸ he)
  · first
      | (rw [hesc]; exact hX.disj)
      | exact hesc ▸ hX.disj
  · obtain ⟨x0, h1, -, hl', -⟩ := hk.1 a x hx
    first
      | (rw [hesc] at he; exact hX.owned a b x0 e hι h1 (hl' hl) he hid)
      | exact hX.owned a b x0 e hι h1 (hl' hl) (hesc ▸ he) hid
  · obtain ⟨y0, hy0, hadd, hlv, hsz⟩ := hak.2 id y hy
    rcases hX.free id y0 hy0 (by rw [← hlv]; exact hl) with ⟨e, he, hid, hya, hys⟩ | hfr
    · refine .inl ⟨e, by first | (rw [hesc]; exact he) | exact hesc ▸ he, hid, ?_, ?_⟩
      · rw [hadd]; exact hya
      · rw [hsz]; exact hys
    · refine .inr fun l sl hsl => ?_
      rw [hadd, hsz]
      exact hfr l sl hsl
  · rw [hak.1]
    first
      | (rw [hesc] at he; exact hX.idLt e he)
      | exact hX.idLt e (hesc ▸ he)
  · obtain ⟨y0, hy0, hadd, -, -⟩ := hak.2 e.id y hy
    rw [hadd]
    first
      | (rw [hesc] at he; exact hX.addrAt e he y0 hy0)
      | exact hX.addrAt e (hesc ▸ he) y0 hy0

/-- A statement without own scopes, `End` or storage kill, whose lift on the cut code from the
fold `s0` is a `LiftOutN` over its range (`hlift`, given the cut code's facts there). -/
theorem stmtOutX_of_liftN {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s' : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (hkill : storageKill st = none) (hend : endSpec Γ.toStmtCtx st = [])
    (hown : ownSpec Γ.toStmtCtx st = [])
    {is : List R.Insn} (hR : rangeInsns c.d r = is)
    (hlift : (∀ j (hj : j < is.length), (c.cut r.2).d.insns[s0.pc + j]? = some (is[j]'hj)) →
      (∀ j, j < is.length → (c.cut r.2).scopesAt (s0.pc + j) = []) →
      (c.cut r.2).mode.pe = false → (∀ i ∈ is, PlainView (c.cut r.2).mode (c.cut r.2).ρ i) →
      LiftOutN Γ.toStmtCtx (c.cut r.2) ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f s s'
        s0 is.length) :
    StmtOutX Γ c ch ι f rest bd blk s s' s1 := by
  subst hR
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hpcs : s0.pc = s1.pc := scopes_pc M.pend
  have hlen := rangeInsns_length (r := r) h2
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hplc : ∀ (k : Nat) (i : R.Insn), c.d.insns[k]? = some i → PlainView c.mode c.ρ i :=
    fun k i h => by rw [hmode, hρ]; exact hfn.plain k i h
  have hat := rangeInsns_at (r := r) h2
  have hl := hlift
    (fun j hj => by
      rw [hpcs, hpc0, cut_lt (show r.1 + j < r.2 by omega)]
      exact hat j hj)
    (fun j _ => cut_scopesAt c r.2 _) hpe
    (fun i hmem => by
      obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hmem
      exact hplc _ _ (hat j hj))
  obtain ⟨st', hsteps, hstk, hrel, hpb, hle, hk⟩ := hl
  have hsl' : ∀ l p, f.locals[l]? = some (some p) →
      (computeStorage Γ.body).get f.bb (f.stmt + 1) l = true := fun l p hp =>
    (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp)
      (by rw [hkill]; intro hk'; cases hk')
  have hfr' : ∀ a, s'.mem.allocs.size ≤ a → ι a = none :=
    fun a ha => M.fresh a (Nat.le_trans hle ha)
  rcases Nat.lt_or_ge r.1 r.2 with hlt | hge
  · -- a non-empty range: its first step from `s1` through all the scopes at `pc`, then `run_cut`
    have hsx := hfn.stmtsX f.bb bd blk M.hbd M.hblk
    have hscB := hfn.scopes f.bb bd blk M.hbd M.hblk
    have hsc := hscB.stmt f.stmt st r hst hr hlt
    rw [hown, List.append_nil] at hsc
    have hlen' := specsOk_length _ _ hsc
    have hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0 := by
      have hp := M.pend
      have ht : (c.scopesAt s1.pc).take (pendSpecs Γ.toStmtCtx bd blk f.stmt).length =
          c.scopesAt s1.pc := by
        apply List.take_of_length_le
        have hl' : (c.scopesAt s1.pc).length = (pendSpecs Γ.toStmtCtx bd blk f.stmt).length := by
          rw [hpc0]
          exact hlen'
        omega
      rw [ht] at hp
      exact hp
    have hnx : ∀ (k : Nat) (i : R.Insn), r.1 ≤ k → k < r.2 → c.d.insns[k]? = some i →
        ∃ v, R.view c.mode c.ρ i = some v ∧ v.ctl = some .next := by
      intro k i hk1 hk2 hi
      rw [hmode, hρ]
      exact hsx.next f.stmt r hr k hk1 hk2 i hi
    generalize hu : ({ s0 with pc := s0.pc + (rangeInsns c.d r).length, st := st' } :
      R.RState) = u at hsteps
    cases hsteps with
    | refl =>
      exfalso
      have e1 : s0.pc + (rangeInsns c.d r).length = s0.pc := congrArg R.RState.pc hu
      omega
    | @cons _ t1 _ hs hrest =>
      obtain ⟨i, hci, hlt0⟩ := step_cut_lt hs
      have hc : c.d.insns[s0.pc]? = some i := by rw [← cut_lt hlt0]; exact hci
      obtain ⟨v, hv, hctl⟩ := hnx s0.pc i (by omega) hlt0 hc
      obtain ⟨st'', hop, hesc1, hak1, rfl⟩ := step_cut_inv hci hpe (hplc _ _ hc) hv hctl hs
      have hc1 : c.d.insns[s1.pc]? = some i := by rw [← hpcs]; exact hc
      have hstep1 : R.step c s1 ch = .ok (.step { s0 with pc := s0.pc + 1, st := st'' }) :=
        step_of_view_scopes (s1 := s1) (s0 := s0) hc1 hfold hpe (hplc _ _ hc) hv hctl hop
      obtain ⟨hrun, he, ha⟩ := run_cut (b := r.1 + 1) hpe hplc
        (fun k i hk1 hk2 hi => hnx k i (by omega) hk2 hi)
        (fun k hk1 hk2 => hscB.stmtInner f.stmt r hr k (by omega) hk2) hrest
        (by show r.1 + 1 ≤ s0.pc + 1; omega)
      subst hu
      have hesc' : ({ s0 with pc := s0.pc + (rangeInsns c.d r).length, st := st' } :
          R.RState).st.escaped = s0.st.escaped := he.trans hesc1
      have hak' : AllocsKept s0.st.mem
          ({ s0 with pc := s0.pc + (rangeInsns c.d r).length, st := st' } : R.RState).st.mem :=
        hak1.trans ha
      refine ⟨ι, _, _, f, fun _ _ h => h,
        .cons hstep1 hrun, hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl, ?_, ?_,
        fnRelX_keep M.rel hrel hesc' hak' hk, hsl', hpb, hfr', M.dinv.of_memKept hk⟩
      · show s0.pc + (rangeInsns c.d r).length = pcAt blk (f.stmt + 1)
        rw [← nextStart_eq, ← hnext]
        omega
      · rw [hsx.pend0 f.stmt r hr hlt]
        rfl
  · -- an empty range: no step, the pending list unchanged
    have he : r.2 = r.1 := by omega
    have hu : ({ s0 with pc := s0.pc + (rangeInsns c.d r).length, st := st' } : R.RState) =
        s0 := steps_cut_stop hsteps (by omega)
    have hstart : startAt blk f.stmt = r.1 := pcAt_some hr
    have hstart1 : startAt blk (f.stmt + 1) = startAt blk f.stmt := by
      show pcAt blk (f.stmt + 1) = _
      rw [← nextStart_eq, ← hnext, he, hstart]
    have hps := pendSpecs_succ (Γ := Γ.toStmtCtx) hstart1 hst
    have hpcN : s1.pc = pcAt blk (f.stmt + 1) := by
      rw [hpc0, ← he, hnext, nextStart_eq]
    have hesc' : ({ s0 with pc := s0.pc + (rangeInsns c.d r).length, st := st' } :
        R.RState).st.escaped = s0.st.escaped := by rw [hu]
    have hak' : AllocsKept s0.st.mem
        ({ s0 with pc := s0.pc + (rangeInsns c.d r).length, st := st' } : R.RState).st.mem := by
      rw [hu]; exact AllocsKept.refl _
    refine ⟨ι, s1, _, f, fun _ _ h => h, .refl _, hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl,
      hpcN, ?_,
      fnRelX_keep M.rel hrel hesc' hak' hk, hsl', hpb, hfr', M.dinv.of_memKept hk⟩
    rw [hps, hend, List.append_nil, hu]
    exact M.pend

/-! ### The cases -/

/-- The deref `store` (an assignment to a projected place, one instruction) under pending
scopes. -/
theorem stmt_simX_derefStore {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerDeref Γ.toStmtCtx st (rangeInsns c.d r))
    (hd : ¬ ∃ d rv, st = .assign ⟨d, []⟩ rv)
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨pl, rv, i, rfl, hR, hproj, hkill, hlowS⟩ : ∃ pl rv i, st = .assign pl rv ∧
      rangeInsns c.d r = [i] ∧ pl.proj ≠ [] ∧ stmtKill (.assign pl rv) = none ∧
      LowerDeref Γ.toStmtCtx (.assign pl rv) [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h with
    | load => exact (hd ⟨_, _, rfl⟩).elim
    | store ha htp hk hpath hta hn hpos hwf hsp hsa hsize hoff hi =>
      exact ⟨_, _, _, rfl, rfl, List.cons_ne_nil _ _, rfl,
        .store ha htp hk hpath hta hn hpos hwf hsp hsa hsize hoff hi⟩
  have hown : ownSpec Γ.toStmtCtx (.assign pl rv) = [] := by
    obtain ⟨b, ps⟩ := pl
    cases ps with
    | nil => exact (hproj rfl).elim
    | cons x xs => rfl
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  refine stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown hR
    (fun hi _ hpe0 hpl0 => ?_)
  have hc : (c.cut r.2).d.insns[s0.pc]? = some i := hi 0 (by simp)
  have hpl1 : PlainView (c.cut r.2).mode (c.cut r.2).ρ i := hpl0 i (by simp)
  exact liftOutN_of_lift (lift_derefStore (ch := ch) M.stack M.body.symm hmode' hρ' hlowS hproj
    hc (cut_scopesAt c r.2 _) hpe0 hpl1 M.rel.rel M.pb M.dinv.1 M.dinv.2 hlv2
    (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev)

/-- `agg` under pending scopes: `lift_agg` on the cut code. -/
theorem stmt_simX_agg {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerAgg Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    cases h <;> exact ⟨_, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    cases h <;> first | rfl | (simp only [ownSpec, refPlace?]; exact useSpec_aggField (by assumption))
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_agg M.stack M.body.symm hmode' hρ' h hi hsc hpe0 hpl0
      M.rel.rel M.pb M.dinv.2 M.rel.escIdOff hl2 hl1 hev)

/-- `enum` under pending scopes: each rule's lift on the cut code (`setDiscr`'s implicit case
has an empty range). -/
theorem stmt_simX_enum {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (hlow : LowerEnum Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  cases hlow with
  | read h =>
    obtain ⟨d, rv, i, rfl, hR⟩ := enumRead_shape h
    rw [hR] at h
    have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
      cases h <;> first | rfl | simp_all [ownSpec, refPlace?]
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    refine stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown hR
      (fun hi _ hpe0 hpl0 => ?_)
    have hc : (c.cut r.2).d.insns[s0.pc]? = some i := hi 0 (by simp)
    have hpl1 : PlainView (c.cut r.2).mode (c.cut r.2).ρ i := hpl0 i (by simp)
    exact liftOutN_of_lift (lift_enumRead M.stack M.body.symm hmode' hρ' h hc
      (cut_scopesAt c r.2 _) hpe0 hpl1 M.rel.rel M.pb M.dinv.2 hl2 hl1 hev)
  | setDiscr h =>
    generalize hR : rangeInsns c.d r = is at h
    cases h with
    | @tag e v vs discrTy tag esz eal bits se i hte hbits hse hsize hoff hpriv hii =>
      obtain ⟨hl1, hl2⟩ := setDiscr_live hfn.live M.hbd hst
      refine stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl rfl hR
        (fun hi _ hpe0 hpl0 => ?_)
      have hc : (c.cut r.2).d.insns[s0.pc]? = some i := hi 0 (by simp)
      have hpl1 : PlainView (c.cut r.2).mode (c.cut r.2).ρ i := hpl0 i (by simp)
      exact liftOutN_of_lift (lift_setTag M.stack M.body.symm hmode' hρ'
        (.tag hte hbits hse hsize hoff hpriv hii) hc (cut_scopesAt c r.2 _) hpe0 hpl1 M.rel.rel
        M.pb hl2 hl1 hev)
    | implicit hte himp =>
      obtain ⟨hl1, -⟩ := setDiscr_live hfn.live M.hbd hst
      refine stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl rfl hR
        (fun _ _ _ _ => ?_)
      obtain ⟨hstk, hrel', hpb', hle, hk⟩ :=
        lift_setImplicit M.stack M.body.symm (.implicit hte himp) M.rel.rel M.pb hl1 hev
      exact liftOutN_zero hstk hrel' hpb' hle hk
  | agg h =>
    obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
      cases h; exact ⟨_, _, rfl⟩
    have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
      cases h; first | rfl | simp [ownSpec, refPlace?]
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
      (fun hi hsc hpe0 hpl0 => lift_enumAgg M.stack M.body.symm hmode' hρ' h hi hsc hpe0 hpl0
        M.rel.rel M.pb M.dinv.2 M.rel.escIdOff hl2 hl1 hev)

/-! ### `StorageLive` -/

/-- `FnRelX` after a `StorageLive _l`: R unchanged; the new allocation (index `m0`'s size) is
fresh, so `ι` maps it nowhere (`owned`); `_l`'s address is aligned (`hal`). -/
theorem live_fnRelX {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 m' : Memory} {s0 : R.RState} {l : Local} {p : ThinPointer} {a : Allocation}
    {ty : Spec.Ty} (hX : FnRelX Γ ι live f m0 s0)
    (hrel : FnRel Γ ι live' { f with locals := f.locals.set! l (some p) } m' s0)
    (hm' : m' = { allocs := m0.allocs.push a })
    (hl : ∀ p, f.locals[l]? ≠ some (some p))
    (hfr : ∀ a, m0.allocs.size ≤ a → ι a = none)
    (hty : f.body.locals[l]? = some ty) (hal : p.addr % ty.align.bytes = 0) :
    FnRelX Γ ι live' { f with locals := f.locals.set! l (some p) } m' s0 := by
  have hold : ∀ l' p', f.locals[l']? = some (some p') → l' ≠ l := fun l' p' hp e => by
    subst e
    exact hl p' hp
  have hset : ∀ l' p', f.locals[l']? = some (some p') →
      (f.locals.set! l (some p))[l']? = some (some p') := fun l' p' hp => by
    rw [getElem?_set!_ne (hold l' p' hp)]
    exact hp
  refine ⟨hrel, fun e he => ?_, hX.disj, fun a' b x e hι hx hlv he hid => ?_, hX.free,
    fun l' p' ty' hp' hty' => ?_, hX.idLt, hX.addrAt⟩
  · obtain ⟨l2, p2, sl2, hp2, hsl2, ho2, hs2, hpos⟩ := hX.objs e he
    exact ⟨l2, p2, sl2, hset l2 p2 hp2, hsl2, ho2, hs2, hpos⟩
  · have hlt : a' < m0.allocs.size := by
      rcases Nat.lt_or_ge a' m0.allocs.size with h | h
      · exact h
      · rw [hfr a' h] at hι
        cases hι
    have hx0 : m0.get? a' = some x := by
      have e1 : ({ allocs := m0.allocs.push a } : Memory).get? a' = m0.get? a' := by
        simp [Memory.get?, Array.getElem?_push, Nat.ne_of_lt hlt]
      rw [← e1, ← hm']
      exact hx
    obtain ⟨l3, p3, sl3, hp3, hpa3, hsl3, ho3, hs3⟩ := hX.owned a' b x e hι hx0 hlv he hid
    exact ⟨l3, p3, sl3, hset l3 p3 hp3, hpa3, hsl3, ho3, hs3⟩
  · have hp'' : (f.locals.set! l (some p))[l']? = some (some p') := hp'
    have hty'' : f.body.locals[l']? = some ty' := hty'
    by_cases e : l' = l
    · subst e
      have e1 : p' = p := Option.some.inj (getElem?_set!_self hp'')
      have e2 : ty' = ty := Option.some.inj (hty''.symm.trans hty)
      rw [e1, e2]
      exact hal
    · rw [getElem?_set!_ne e] at hp''
      exact hX.aligned l' p' ty' hp'' hty''

/-- `StorageLive _l` under pending scopes (as `stmt_sim_base`'s, on the fold `s0`): R doesn't
step, the pending list is unchanged (`endSpec = []`). -/
theorem stmt_simX_storageLive {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    (hpick : PicksAt Γ o ch s s1.fp)
    {l : Local} (hst : bd.stmts[f.stmt]? = some (.storageLive l)) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt) (hR0 : rangeInsns c.d r = [])
    (hev : runOn (evalStatement (.storageLive l)) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have he : r.2 = r.1 := rangeInsns_nil h1 h2 hR0
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hstart : startAt blk f.stmt = r.1 := pcAt_some hr
  have hstart1 : startAt blk (f.stmt + 1) = startAt blk f.stmt := by
    show pcAt blk (f.stmt + 1) = _
    rw [← nextStart_eq, ← hnext, he, hstart]
  have hps := pendSpecs_succ (Γ := Γ.toStmtCtx) hstart1 hst
  have hpcN : s1.pc = pcAt blk (f.stmt + 1) := by
    rw [hpc0, ← he, hnext, nextStart_eq]
  have hfp : s0.fp = s1.fp := scopes_fp M.pend
  obtain ⟨hdead, sd, hsd, hsz⟩ := hfn.fresh f.bb bd f.stmt l M.hbd hst
  have hl : ∀ p, f.locals[l]? ≠ some (some p) := by
    intro p hp
    have := M.sl l p hp
    rw [hdead] at this
    cases this
  have hlt : l < Γ.body.locals.size :=
    Nat.lt_of_lt_of_le (Array.getElem?_eq_some_iff.mp hsd).1 hfn.share.1
  have hpriv := storageLive_privX M.hbd hst hsd hlt hl hfn.storage hfn.share.2 M.sl M.rel
  have happ : ∀ l' (p' : ThinPointer) sl', l' ≠ l → f.locals[l']? = some (some p') →
      Γ.toStmtCtx.slots[l']? = some sl' → SlotsApart sd sl' ∧ SlotsApart sl' sd :=
    fun l' p' sl' hne hp' hsl' => by
      have hd := hfn.share.2 f.bb bd M.hbd f.stmt l (.inl hst) l' (Ne.symm hne)
        (M.sl l' p' hp') sd sl' hsd hsl'
      exact ⟨hd, hd.symm⟩
  have hbd' : f.body.blocks[f.bb]? = some bd := by rw [M.body]; exact M.hbd
  have hlive' : ∀ l', (computeLive Γ.body).get f.bb (f.stmt + 1) l' = true →
      l' = l ∨ (computeLive Γ.body).get f.bb f.stmt l' = true := by
    intro l' hl'
    by_cases e : l' = l
    · exact .inl e
    · exact .inr ((hfn.live.stmt f.bb bd M.hbd f.stmt _ hst).1 l' hl'
        (by intro h; exact e (Option.some.inj h).symm))
  obtain ⟨f', hs', hb', hbb', hst', hrel'⟩ := lift_storageLive M.stack M.rel.rel hl hsd
    (fun ty hty => hsz ty (by rw [← M.body]; exact hty))
    (fun ty p m' s2 hty hal => by
      rw [hfp]
      exact hpick.1 f rest bd l sd ty p m' s2 M.stack hbd' hst hsd hty hal)
    hpriv happ M.pb.hidden (M.fresh _ (Nat.le_refl _)) hlive' hev
  obtain ⟨ty, size, p, m', s2, hty, hsz', hal, hs2, hs1x⟩ :=
    storageLive_dead M.stack hl (show runOn (storageLive l) o s = _ from hev)
  subst hs1x
  obtain ⟨e, -⟩ := List.cons.inj hs'
  subst e
  obtain ⟨a, hda, hpa, -, -, -, -, hm', hok, -⟩ := runOn_allocate_ok hal
  have hA : ty.align.isAligned p.addr = true := by
    unfold Memory.addrOk at hok
    simp only [Bool.and_eq_true] at hok
    exact hok.1.1.2
  have hal2 : p.addr % ty.align.bytes = 0 := by
    unfold Align.isAligned at hA
    exact beq_iff_eq.mp hA
  have hX := live_fnRelX M.rel hrel' hm' hl M.fresh hty hal2
  refine ⟨ι, s1, s0, _, fun _ _ h => h, .refl _, rfl, rfl, rfl, rfl, rfl, rfl, hpcN, ?_, hX,
    ?_, ?_, ?_, ?_⟩
  · rw [hps, show endSpec Γ.toStmtCtx (.storageLive l) = [] from rfl, List.append_nil]
    exact M.pend
  · intro l' p' hp'
    by_cases e : l' = l
    · rw [e]
      exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).2 l rfl hlt
    · have hp'' : (f.locals.set! l (some p))[l']? = some (some p') := hp'
      rw [getElem?_set!_ne e] at hp''
      exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l' (M.sl l' p' hp'')
        (by intro e'; cases e')
  · exact M.pb.allocate hal
  · intro x hx
    apply M.fresh
    have hx' : m'.allocs.size ≤ x := hx
    rw [hm', Array.size_push] at hx'
    exact Nat.le_of_succ_le hx'
  · show DerefInv ι m'
    rw [hm']
    exact M.dinv.push M.pb hda (by rw [hpa]; exact hok)

end Ryo.Proofs.Lower
