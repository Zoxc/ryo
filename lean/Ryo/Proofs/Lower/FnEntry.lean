/-
Ryo.Proofs.Lower.FnEntry — M5a's function theorem from function entry (aot.md §C1).

- `match_entry`: from L0's entry frame of the function and R at the prologue's start, R runs
  the prologue (`prolog_run`) to a state related by `Match` (FnSim) to L0's entry state. What
  L0's call entry (`callBody`) gives is stated as hypotheses, not derived: the frame is the
  function's bottom frame at block 0, point 0, unaliased; its storage-live locals are exactly
  the register inputs (local `j + 1` for input `j`) with `ArgRel` to R's registers (private,
  live, at the slot, bytes refining the register's); `MemInj`, `Hidden` for the private locals,
  distinct provenance, disjoint slots (what `checkFn`'s slot check gives), storage liveness at
  the entry point, `ProvBounded` and `ι` fresh past the end of memory. R: the prologue's
  instructions at consecutive indices without scopes, nothing escaped, block 0 starting right
  after the prologue.
- `fn_step_sim_ret`/`fn_sim_ret`: `fn_step_sim`/`fn_sim` with `sim_ret`'s value relation
  (`RetVal`: an integer `_0`'s bits are the low bytes of `rax`) in the return case.
- `fn_sound`: the two composed, from function entry.
-/
import Ryo.Proofs.Lower.FnSim

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `sim_ret`'s relation of the returned value `v` to R's return registers `regs`. -/
def RetVal (Γ : TermCtx) (v : Value) (regs : R.Regs) : Prop :=
  Γ.retKind ≠ 0 → ∀ t valid, Γ.body.locals[0]? = some (.int t valid) →
    ∃ u, v = .int (t.ofBits u) ∧ decodeBits ((regs.get (.gpr 0)).take t.size) = some u

/-! ### Entry -/

/-- Input `j`'s home is local `k + j + 1`'s slot. -/
theorem argsOk_slot {Γp : PrologCtx} : ∀ {k : Nat} {is : List R.Insn}
    {ps : List (LocalSlot × Asm.ArgReg)}, ArgsOk Γp k is ps →
    ∀ j (h : j < ps.length), Γp.slots[k + j + 1]? = some (ps[j]).1
  | _, _, _, .nil _, j, h => by simp at h
  | _, _, _, .cons (k := k) (p := p) (ps := ps) hok hrest, j, h => by
    cases j with
    | zero => simpa using hok.2.2.1
    | succ j =>
      have h' : j < ps.length := by simp at h; omega
      have := argsOk_slot hrest j h'
      have e : k + (j + 1) + 1 = k + 1 + j + 1 := by omega
      rw [e]
      simpa using this

/-- From L0's entry frame and R at the prologue, R runs the prologue to `Match` (see the
module comment). -/
theorem match_entry {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {Γp : PrologCtx} {is : List R.Insn} {ps : List (LocalSlot × Asm.ArgReg)}
    (hpl : LowerProlog Γp is ps) (hslots : Γp.slots = Γ.slots)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    -- R at the prologue
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    -- L0's entry frame (`callBody`)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < ps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < ps.length) (h2 : j < qs.length),
      ArgRel ι s1.fp s.mem s1.args ps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none) :
    ∃ s1', StepsTo c ch s1 s1' ∧ Match Γ ι s s1' := by
  obtain ⟨s', hst, hpc, hfp, -, hmem', hesc, -, hin⟩ :=
    prolog_run (ch := ch) hpl.args s1 hcode (fun _ _ _ _ => hnoesc _)
  have hlr : ∀ j (h1 : j < ps.length) (h2 : j < qs.length),
      LocalRel ι s'.fp s'.st s.mem ps[j].1 qs[j] true := by
    intro j h1 h2
    obtain ⟨al, x, hp, hι, hx, hlive, haddr, hpaddr, hsize, hb⟩ := hrel j h1 h2
    have hmemj : ps[j] ∈ ps := List.getElem_mem h1
    refine .priv al x hp hι hx hlive (by rw [hfp]; exact haddr) hpaddr hsize ?_ ?_
    · intro k _
      rw [hesc]
      exact hnoesc _
    · intro _ k hk
      obtain ⟨b, hbk, hbi⟩ := hb k hk
      obtain ⟨hkl, hbe⟩ := List.getElem?_eq_some_iff.mp hbk
      rw [hin hpl.disj _ hmemj k hkl, hbe]
      exact hbi
  refine ⟨s', hst, f, rest, blk, bd, ?_⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, rel := ?_, sl := ?_, pb := hpb, fresh := hfresh }
  · rw [hbb]; exact hblk
  · rw [hbb]; exact hbd
  · rw [hstmt]; exact Nat.zero_le _
  · rw [hstmt, hstart, hpc]
  · refine ⟨⟨?_, ?_⟩, hhid, hal, hprov, hapart, ?_⟩
    · rw [hmem']; exact hmem
    · intro l p hp _
      obtain ⟨j, h1, h2, rfl, rfl⟩ := hloc l p hp
      refine ⟨ps[j].1, ?_, (hlr j h1 h2).weaken (fun _ => rfl)⟩
      have := argsOk_slot hpl.args j h1
      rw [hslots] at this
      simpa using this
    · intro o e he
      rw [hesc, hnoesc] at he
      cases he
  · intro l p hp
    rw [hbb, hstmt]
    exact hsl l p hp

/-! ### The return value -/

/-- `fn_step_sim` with `sim_ret`'s value relation in the return case. -/
theorem fn_step_sim_ret {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    {s s' : Spec.State} {s1 : R.RState} (hm : Match Γ ι s s1) (hpick : PicksAt Γ o s s1.fp)
    (h : runOn Sem.step o s = (.ok (), s')) :
    (∃ s1', StepsTo c ch s1 s1' ∧ Match Γ ι s' s1') ∨
      (∃ v regs incoming, s'.final = some (.returned v) ∧
        R.step c s1 ch = .ok (.done (R.exit s1 (.ret regs incoming))) ∧ RetVal Γ v regs) := by
  obtain ⟨f, rest, blk, bd, M⟩ := hm
  have hfin := step_final_none h
  have hbd' : f.body.blocks[f.bb]? = some bd := by rw [M.body]; exact M.hbd
  have hB := hfn.block f.bb bd blk M.hbd M.hblk
  cases hst : bd.stmts[f.stmt]? with
  | some st =>
    obtain ⟨s1x, f1, rest1, hev, hs1x, rfl⟩ := step_stmt_inv M.stack hfin M.pu hbd' hst h
    have hlt : f.stmt < bd.stmts.length := (List.getElem?_eq_some_iff.mp hst).1
    have hlt' : f.stmt < blk.stmts.size := by rw [hB.len]; exact hlt
    have hr : blk.stmts[f.stmt]? = some blk.stmts[f.stmt] := Array.getElem?_eq_getElem hlt'
    obtain ⟨h1, h2, hnext, hlow⟩ := hB.stmt _ _ _ hst hr
    obtain ⟨s1', f', hsteps, hs', hb', hbb', hst', hpu', hc', hpc', hrel', hsl', hpb', hfr'⟩ :=
      stmt_sim (ch := ch) hfn hmode hρ M hpick hst hr h1 h2 hlow hev
    rw [hs'] at hs1x
    obtain ⟨e1, e2⟩ := List.cons.inj hs1x
    subst e1 e2
    refine .inl ⟨s1', hsteps, { f' with stmt := f'.stmt + 1 }, rest, blk, bd, ?_⟩
    refine { stack := rfl, body := hb'.trans M.body, pu := hpu'.trans M.pu,
             cont := hc'.trans M.cont, hblk := ?_, hbd := ?_, le := ?_,
             pc := ?_, rel := ?_, sl := ?_, pb := hpb', fresh := hfr' }
    · show Γ.blocks[f'.bb]? = some blk
      rw [hbb']; exact M.hblk
    · show Γ.body.blocks[f'.bb]? = some bd
      rw [hbb']; exact M.hbd
    · show f'.stmt + 1 ≤ bd.stmts.length
      rw [hst']; exact hlt
    · show pcAt blk (f'.stmt + 1) = s1'.pc
      rw [hst', ← nextStart_eq, ← hnext, hpc']
    · show FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get f'.bb (f'.stmt + 1))
        { f' with stmt := f'.stmt + 1 } s1x.mem s1'
      have h2 : FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get f'.bb (f'.stmt + 1)) f' s1x.mem s1' := by
        rw [hbb', hst']; exact hrel'
      exact FnRel.congr h2 rfl rfl rfl rfl
    · intro l p hp
      show (computeStorage Γ.body).get f'.bb (f'.stmt + 1) l = true
      rw [hbb', hst']
      exact hsl' l p hp
  | none =>
    have h' := step_term_inv M.stack hfin M.pu hbd' hst h
    have hlen : f.stmt = bd.stmts.length := by
      have := List.getElem?_eq_none_iff.mp hst
      exact Nat.le_antisymm M.le this
    have hnone : blk.stmts[f.stmt]? = none := by
      rw [Array.getElem?_eq_none_iff, hB.len]; omega
    have hpc0 : s1.pc = blk.term.1 := by rw [← M.pc, pcAt_none hnone]
    have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
    have hat := termAt_of hB.termIn hfn.noScopes hpe hpc0 hB.termLe
    have hlr := (hfn.live.term f.bb bd M.hbd).1
    by_cases hret : bd.term = .return
    · have hlow := hB.term
      have hat' := hat
      generalize hR : rangeInsns c.d blk.term = is at hlow hat'
      rw [hret] at hlow h'
      cases hlow with
      | ret hok =>
        have hl0 : (computeLive Γ.body).get f.bb f.stmt 0 = true := by
          rw [hlen]; exact hlr 0 (by rw [hret]; simp [termReads])
        obtain ⟨v, regs, incoming, hfinal, hstep, hval⟩ := sim_ret (ch := ch) M.stack M.body.symm
          hok hat' M.rel hl0 M.cont (hinc _) h'
        exact .inr ⟨v, regs, incoming, hfinal, hstep, hval⟩
    · have hpl : ∀ i, (rangeInsns c.d blk.term).head? = some i → PlainView c.mode c.ρ i := by
        intro i hi
        cases hR : rangeInsns c.d blk.term with
        | nil => rw [hR] at hi; cases hi
        | cons j tl =>
          rw [hR] at hi
          simp only [List.head?_cons, Option.some.injEq] at hi
          subst hi
          have hc := hat.code 0 (by rw [hR]; simp)
          simp only [Nat.add_zero, hR, List.getElem_cons_zero] at hc
          rw [hmode, hρ]
          exact hfn.plain _ _ hc
      have hlive : ∀ (d : Operand) cs ow l, bd.term = .switchInt d cs ow → d.local? = some l →
          (computeLive Γ.body).get f.bb f.stmt l = true := by
        intro d cs ow l he hd
        rw [hlen]
        exact hlr l (by rw [he]; exact operand_local_mem hd)
      obtain ⟨s1', f', hsteps, hs', -, -, hstart, hmem, hrel'⟩ := sim_term (ch := ch)
        (live' := (computeLive Γ.body).get f.bb f.stmt) M.stack M.body.symm hmode hρ hB.term
        hret hat hpl M.rel hlive (fun _ h => h) h'
      obtain ⟨b', hsucc, hs'', -⟩ := term_next hB.term hret M.stack h'
      rw [hs''] at hs'
      obtain ⟨e, -⟩ := List.cons.inj hs'
      subst e
      -- the target block
      unfold blockStart at hstart
      obtain ⟨blk', hblk', hpc'⟩ := Option.map_eq_some_iff.mp hstart
      have hb'lt : b' < Γ.body.blocks.size := by
        rw [← hfn.blocksSize]; exact (Array.getElem?_eq_some_iff.mp hblk').1
      obtain ⟨bd', hbd''⟩ : ∃ bd', Γ.body.blocks[b']? = some bd' :=
        ⟨_, Array.getElem?_eq_getElem hb'lt⟩
      refine .inl ⟨s1', hsteps, { f with bb := b', stmt := 0 }, rest, blk', bd', ?_⟩
      refine { stack := hs'', body := M.body, pu := M.pu, cont := M.cont, hblk := hblk',
               hbd := hbd'', le := Nat.zero_le _, pc := hpc', rel := ?_, sl := ?_,
               pb := by rw [hmem]; exact M.pb, fresh := by rw [hmem]; exact M.fresh }
      · show FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get b' 0) { f with bb := b', stmt := 0 }
          s'.mem s1'
        refine hrel'.weaken fun l hl => ?_
        rw [hlen]
        exact (hfn.live.term f.bb bd M.hbd).2 b' hsucc l hl
      · intro l p hp
        show (computeStorage Γ.body).get b' 0 l = true
        have := M.sl l p hp
        rw [hlen] at this
        exact hfn.storage.term f.bb bd M.hbd b' hsucc l this


/-- `fn_sim` with the returned value related to R's return registers (`RetVal`). -/
theorem fn_sim_ret {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o s s1.fp) :
    ∀ {n : Nat} {s s' : Spec.State} {s1 : R.RState}, Match Γ ι s s1 → L0Steps o n s s' →
      (∃ s1', StepsTo c ch s1 s1' ∧ Match Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧ RetVal Γ v regs) := by
  intro n s s' s1 hm hrun
  revert s1
  induction hrun with
  | zero s0 => intro s1 hm; exact .inl ⟨s1, .refl _, hm⟩
  | succ hstep hrest ih =>
    intro s1 hm
    rcases fn_step_sim_ret (ch := ch) hfn hmode hρ hinc hm (hpick _ _ hm) hstep with
      ⟨s1', hst, hm'⟩ | ⟨v, regs, incoming, hfinal, hret, hval⟩
    · rcases ih hm' with ⟨s1'', hst', hm''⟩ | ⟨s1'', v, regs, incoming, hst', hf, hr, hv⟩
      · exact .inl ⟨s1'', hst.trans hst', hm''⟩
      · exact .inr ⟨s1'', v, regs, incoming, hst.trans hst', hf, hr, hv⟩
    · cases hrest with
      | zero => exact .inr ⟨s1, v, regs, incoming, .refl _, hfinal, hret, hval⟩
      | succ hstep' _ =>
        have := step_final_none hstep'
        rw [hfinal] at this
        cases this

/-! ### From entry -/

/-- M5a's function theorem from entry: given L0's entry frame and R at the prologue (as in
`match_entry`), every L0 run of the function is matched by an R run through the prologue to
related states, or L0 returned and R's `ret` ends the function with the value related. -/
theorem fn_sound {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o s s1.fp)
    {Γp : PrologCtx} {is : List R.Insn} {ps : List (LocalSlot × Asm.ArgReg)}
    (hpl : LowerProlog Γp is ps) (hslots : Γp.slots = Γ.slots)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < ps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < ps.length) (h2 : j < qs.length),
      ArgRel ι s1.fp s.mem s1.args ps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ s1', StepsTo c ch s1 s1' ∧ Match Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧ RetVal Γ v regs) := by
  obtain ⟨s0, hst0, hm0⟩ := match_entry (ch := ch) hpl hslots hcode hnoesc hblk hbd hstart hs
    hbody hbb hstmt hpu hcont hal qs hloc hrel hmem hhid hprov hapart hsl hpb hfresh
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩

end Ryo.Proofs.Lower
