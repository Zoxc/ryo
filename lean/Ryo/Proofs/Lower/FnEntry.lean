/-
Ryo.Proofs.Lower.FnEntry — M5a's function theorem from function entry (aot.md §C1).

- `match_entry`: from L0's entry frame of the function and R at the prologue's start, R runs
  the prologue (`prolog_run`) to a state related by `MatchX` (SimReach; its `MatchAt` disjunct,
  block 0 being reached) to L0's entry state. What
  L0's call entry (`callBody`) gives is stated as hypotheses, not derived: the frame is the
  function's bottom frame at block 0, point 0, unaliased; its storage-live locals are exactly
  the register inputs (local `j + 1` for input `j`) with `ArgRel` to R's registers (private,
  live, at the slot, bytes refining the register's); `MemInj`, `Hidden` for the private locals,
  distinct provenance, disjoint slots (what `checkFn`'s slot check gives), storage liveness at
  the entry point, `ProvBounded` and `ι` fresh past the end of memory. R: the prologue's
  instructions at consecutive indices without scopes, nothing escaped, block 0 starting right
  after the prologue.
- `fn_step_sim_ret`/`fn_sim_ret`: one L0 step and a run from `MatchX`: a statement by
  `stmt_sim`; a fused block's compare by no R step (to `MatchMid`), then its switch by
  `sim_fused`; a terminator by `sim_term`/`sim_switch`, the target reached (`term_target_mono`,
  `ReachSound.closed`); a return by `sim_retX`, with its value relation (`RetValX`,
  `SimRetX.lean`: each return register part holds `_0`'s bytes at its offset).
  `RetVal` (an integer `_0`'s bits are the low bytes of `rax`) follows from it for
  `Term.lean`'s rule's shape (`RetValX.toRetVal`).
- `fn_sound`: the two composed, from function entry.
-/
import Ryo.Proofs.Lower.FnStep
import Ryo.Proofs.Lower.SimReach

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `sim_ret`'s relation of the returned value `v` to R's return registers `regs`. -/
def RetVal (Γ : TermCtx) (v : Value) (regs : R.Regs) : Prop :=
  Γ.retKind ≠ 0 → ∀ t valid, Γ.body.locals[0]? = some (.int t valid) →
    ∃ u, v = .int (t.ofBits u) ∧ decodeBits ((regs.get (.gpr 0)).take t.size) = some u

/-- For an integer `_0` returned in `rax` alone (`Term.lean`'s rule), `RetValX` gives `RetVal`.

Proof: from `hk`, `retRegs_one` gives the one part `(⟨false, t.size, 0⟩, gpr 0)`; `RetValX`
at `ty := .int t valid` gives `bs0` with `(Ty.int t valid).decode bs0 = some v` and its length
`t.size` (`size?_int`); the int case of `Ty.decode` gives `decodeBits bs0 = some u` and
`v = .int (t.ofBits u)` (unfold `Ty.decode`, as in `typedLoad_int`'s proof, `IntBin.lean`);
`(bs0.drop 0).take t.size = bs0` (`List.take_of_length_le`), and `decodeBits_inj` on the
part's `BytesInj` gives `decodeBits ((regs.get (.gpr 0)).take t.size) = some u`. -/
theorem RetValX.toRetVal {Γ : TermCtx} {ι : Inj} {v : Value} {regs : R.Regs}
    (h : RetValX Γ ι v regs)
    (hk : ∀ t valid, Γ.body.locals[0]? = some (.int t valid) →
      Asm.retParts Γ.retKind true = some (some ⟨false, t.size, 0⟩, none)) :
    RetVal Γ v regs := by
  intro hne t valid hl
  have hp := hk t valid hl
  obtain ⟨bs0, hlen, hdec, hregs⟩ := h hne _ hl
  rw [size?_int] at hlen
  obtain ⟨-, u, hdb, rfl⟩ := decode_int_some hdec
  have hlen' : bs0.length = t.size := (Option.some.inj hlen).symm
  have hb := hregs _ (retRegs_one hp) _ (List.mem_singleton_self _)
  have htk : bs0.take t.size = bs0 := List.take_of_length_le (by omega)
  simp only [List.drop_zero, htk] at hb
  exact ⟨u, rfl, decodeBits_inj hb hdb⟩

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
    (hreach : reachGet (computeReach Γ.body) 0 = true)
    (hfz : blk.fused = true → 0 < bd.stmts.length)
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
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem) :
    ∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s s1' := by
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
  refine ⟨s', hst, Or.inl ⟨f, rest, blk, bd, ?_, by rw [hbb]; exact hreach,
    fun h => by rw [hstmt]; exact hfz h⟩⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, rel := ?_, sl := ?_, pb := hpb, fresh := hfresh, dinv := hdinv }
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

/-- A fused rule's statement is an assignment to a whole local. -/
theorem _root_.Ryo.Check.Lower.LowerFused.assign_shape {Γ : TermCtx} {next : Nat}
    {st : Statement} {term : Terminator}
    {is : List R.Insn} (hlow : LowerFused Γ next st term is) :
    ∃ c rv, st = .assign ⟨c, []⟩ rv := by
  cases hlow <;> exact ⟨_, _, rfl⟩

/-- A reached block's `MatchX` condition at its start: a fused block has its compare. -/
theorem fused_start {Γ : TermCtx} {d : R.Decoded} (hfn : LowersFn Γ d) {b : Nat}
    {bd : BlockData} {blk : BlockCert} (hr : reachGet (computeReach Γ.body) b = true)
    (hbd : Γ.body.blocks[b]? = some bd) (hblk : Γ.blocks[b]? = some blk) :
    blk.fused = true → 0 < bd.stmts.length := by
  intro hfu
  have hl := (hfn.block b bd blk hr hbd hblk).len
  rw [hfu] at hl
  simp at hl
  omega

/-- One L0 step from `MatchX` (see the module comment), with `sim_retX`'s value relation in the
return case. -/
theorem fn_step_sim_ret {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    {s s' : Spec.State} {s1 : R.RState} (hm : MatchX Γ ι s s1)
    (hpick : Match Γ ι s s1 → PicksAt Γ o s s1.fp)
    (h : runOn Sem.step o s = (.ok (), s')) :
    (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ v regs incoming, s'.final = some (.returned v) ∧
        R.step c s1 ch = .ok (.done (R.exit s1 (.ret regs incoming))) ∧ RetValX Γ ι v regs) ∨
      DeadAt Γ s' := by
  have hfin := step_final_none h
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  rcases hm with ⟨f, rest, blk, bd, M, hreach, hfz⟩ |
    ⟨s0, sx, o0, f, rest, blk, bd, st, f1, rest1, M, hreach, hfu, heq, hst, hev, hsx, rfl⟩
  · -- at a `MatchAt` point
    have hbd' : f.body.blocks[f.bb]? = some bd := by rw [M.body]; exact M.hbd
    have hB := hfn.block f.bb bd blk hreach M.hbd M.hblk
    cases hst : bd.stmts[f.stmt]? with
    | some st =>
      obtain ⟨s1x, f1, rest1, hev, hs1x, rfl⟩ := step_stmt_inv M.stack hfin M.pu hbd' hst h
      have hlt : f.stmt < bd.stmts.length := (List.getElem?_eq_some_iff.mp hst).1
      by_cases hlt' : f.stmt < blk.stmts.size
      · have hr : blk.stmts[f.stmt]? = some blk.stmts[f.stmt] := Array.getElem?_eq_getElem hlt'
        obtain ⟨h1, h2, hnext, hlow⟩ := hB.stmt _ _ _ hst hr
        obtain ⟨s1', f', hsteps, hs', hb', hbb', hst', hpu', hc', hpc', hrel', hsl', hpb', hfr',
          hdi'⟩ :=
          stmt_sim (ch := ch) hfn hmode hρ M (hpick ⟨f, rest, blk, bd, M⟩) hst hr h1 h2 hlow hev
        rw [hs'] at hs1x
        obtain ⟨e1, e2⟩ := List.cons.inj hs1x
        subst e1 e2
        refine .inl ⟨s1', hsteps,
          Or.inl ⟨{ f' with stmt := f'.stmt + 1 }, rest, blk, bd, ?_, ?_, ?_⟩⟩
        · refine { stack := rfl, body := hb'.trans M.body, pu := hpu'.trans M.pu,
                   cont := hc'.trans M.cont, hblk := ?_, hbd := ?_, le := ?_,
                   pc := ?_, rel := ?_, sl := ?_, pb := hpb', fresh := hfr',
                   dinv := hdi' }
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
            have h2 : FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get f'.bb (f'.stmt + 1)) f'
                s1x.mem s1' := by
              rw [hbb', hst']; exact hrel'
            exact FnRel.congr h2 rfl rfl rfl rfl
          · intro l p hp
            show (computeStorage Γ.body).get f'.bb (f'.stmt + 1) l = true
            rw [hbb', hst']
            exact hsl' l p hp
        · show reachGet (computeReach Γ.body) f'.bb = true
          rw [hbb']; exact hreach
        · intro hfu
          show f'.stmt + 1 < bd.stmts.length
          have hl := hB.len
          rw [hfu] at hl
          simp at hl
          rw [hst']
          omega
      · -- a fused block's compare: no R step, L0 between the compare and the switch
        have hfu : blk.fused = true := by
          cases hf : blk.fused
          · have hl := hB.len
            rw [hf] at hl
            simp at hl
            exfalso
            omega
          · rfl
        have heq : f.stmt = blk.stmts.size := by
          have hl := hB.len
          rw [hfu] at hl
          simp at hl
          omega
        exact .inl ⟨s1, .refl _, Or.inr ⟨s, s1x, o, f, rest, blk, bd, st, f1, rest1, M, hreach,
          hfu, heq, hst, hev, hs1x, rfl⟩⟩
    | none =>
      have h' := step_term_inv M.stack hfin M.pu hbd' hst h
      have hlen : f.stmt = bd.stmts.length := by
        have := List.getElem?_eq_none_iff.mp hst
        exact Nat.le_antisymm M.le this
      have hnf : blk.fused = false := by
        cases hf : blk.fused
        · rfl
        · have := hfz hf
          omega
      have hT := hB.term hnf
      have hnone : blk.stmts[f.stmt]? = none := by
        have hl := hB.len
        rw [hnf] at hl
        simp at hl
        rw [Array.getElem?_eq_none_iff]; omega
      have hpc0 : s1.pc = blk.term.1 := by rw [← M.pc, pcAt_none hnone]
      have hat := termAt_of hB.termIn hfn.noScopes hpe hpc0 hB.termLe
      have hlr := (hfn.live.term f.bb bd M.hbd).1
      by_cases hret : bd.term = .return
      · have hlow := hT
        rw [hret] at hlow h'
        have hX := hlow.retX_of
        obtain ⟨i, hi⟩ := hX.single
        have hat' := hat
        rw [hi] at hX hat'
        have hl0 : (computeLive Γ.body).get f.bb f.stmt 0 = true := by
          rw [hlen]; exact hlr 0 (by rw [hret]; simp [termReads])
        obtain ⟨v, regs, incoming, hfinal, hstep, hval⟩ := sim_retX (ch := ch) M.stack
          M.body.symm hX hat' M.rel hl0 M.cont (hinc _) h'
        exact .inr (.inl ⟨v, regs, incoming, hfinal, hstep, hval⟩)
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
        have hplA : ∀ i ∈ rangeInsns c.d blk.term, PlainView c.mode c.ρ i := by
          intro i hi
          obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hi
          have hc := hat.code j hj
          rw [hmode, hρ]
          exact hfn.plain _ _ hc
        have hout : SwitchOut Γ c ch ι ((computeLive Γ.body).get f.bb f.stmt) s s' f rest s1 := by
          rcases hT with hlow | hlow | hlow
          · exact .inl (sim_term (ch := ch) (live' := (computeLive Γ.body).get f.bb f.stmt)
              M.stack M.body.symm hmode hρ hlow hret hat hpl M.rel hlive (fun _ h => h) h')
          · exact sim_switch (ch := ch) M.stack M.body.symm hmode hρ hlow hat hplA M.rel hlive
              (fun _ h => h) h'
          · exact absurd hlow.term_eq hret
        rcases hout with ⟨s1', f', hsteps, hs', -, -, hstart, hmem, hrel'⟩ | ⟨ow, hs'', hd⟩
        rotate_left
        · -- the dead end: L0 at the start of a dead block
          exact .inr (.inr ⟨_, rest, hs'', M.body, M.pu, rfl, hd⟩)
        obtain ⟨b', hsucc, hs'', -⟩ := term_nextX hT hret M.stack h'
        rw [hs''] at hs'
        obtain ⟨e, -⟩ := List.cons.inj hs'
        subst e
        -- the target block, reached
        have hreach' : reachGet (computeReach Γ.body) b' = true :=
          hfn.reach.closed f.bb bd M.hbd hreach b' (term_target_mono M.stack hsucc hs'' h')
        unfold blockStart at hstart
        obtain ⟨blk', hblk', hpc'⟩ := Option.map_eq_some_iff.mp hstart
        have hb'lt : b' < Γ.body.blocks.size := by
          rw [← hfn.blocksSize]; exact (Array.getElem?_eq_some_iff.mp hblk').1
        obtain ⟨bd', hbd''⟩ : ∃ bd', Γ.body.blocks[b']? = some bd' :=
          ⟨_, Array.getElem?_eq_getElem hb'lt⟩
        refine .inl ⟨s1', hsteps, Or.inl ⟨{ f with bb := b', stmt := 0 }, rest, blk', bd', ?_,
          hreach', fused_start hfn hreach' hbd'' hblk'⟩⟩
        refine { stack := hs'', body := M.body, pu := M.pu, cont := M.cont, hblk := hblk',
                 hbd := hbd'', le := Nat.zero_le _, pc := hpc', rel := ?_, sl := ?_,
                 pb := by rw [hmem]; exact M.pb, fresh := by rw [hmem]; exact M.fresh,
                 dinv := by rw [hmem]; exact M.dinv }
        · show FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get b' 0)
            { f with bb := b', stmt := 0 } s'.mem s1'
          refine hrel'.weaken fun l hl => ?_
          rw [hlen]
          exact (hfn.live.term f.bb bd M.hbd).2 b' hsucc l hl
        · intro l p hp
          show (computeStorage Γ.body).get b' 0 l = true
          have := M.sl l p hp
          rw [hlen] at this
          exact hfn.storage.term f.bb bd M.hbd b' hsucc l this
  · -- between a fused block's compare and its switch: the switch
    have hB := hfn.block f.bb bd blk hreach M.hbd M.hblk
    obtain ⟨hk, st', hst', hlow⟩ := hB.fusedOk hfu
    have hst2 := hst
    rw [heq] at hst2
    rw [hst2] at hst'
    obtain rfl := Option.some.inj hst'
    have hstk := fused_stmt_stack hlow M.stack M.body.symm hev
    rw [hsx, M.stack] at hstk
    obtain ⟨rfl, rfl⟩ := List.cons.inj hstk.symm
    have hlen1 : f.stmt + 1 = bd.stmts.length := by rw [heq]; exact hk
    have hbdF : ({ f with stmt := f.stmt + 1 } : Spec.Frame).body.blocks[f.bb]? = some bd := by
      show f.body.blocks[f.bb]? = some bd
      rw [M.body]; exact M.hbd
    have hnoneF : bd.stmts[({ f with stmt := f.stmt + 1 } : Spec.Frame).stmt]? = none := by
      show bd.stmts[f.stmt + 1]? = none
      rw [List.getElem?_eq_none_iff]; omega
    have h' := step_term_inv (f := { f with stmt := f.stmt + 1 }) rfl hfin M.pu hbdF hnoneF h
    have hpc0 : s1.pc = blk.term.1 := by
      rw [← M.pc, heq, pcAt_none (Array.getElem?_eq_none_iff.mpr (Nat.le_refl _))]
    have hat := termAt_of hB.termIn hfn.noScopes hpe hpc0 hB.termLe
    have hplA : ∀ i ∈ rangeInsns c.d blk.term, PlainView c.mode c.ρ i := by
      intro i hi
      obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hi
      have hc := hat.code j hj
      rw [hmode, hρ]
      exact hfn.plain _ _ hc
    have hlo := (hfn.live.stmt f.bb bd M.hbd f.stmt st hst).2
    obtain ⟨s1', b', hsteps, hs'', hsucc, hstart, hpb', hsz, hkept, hrel'⟩ :=
      sim_fused (ch := ch)
        (live' := fun l => (computeLive Γ.body).get f.bb f.stmt l && !(stmtKill st == some l))
        M.stack M.body.symm hmode hρ hlow hat hplA M.rel M.pb hlo
        (fun l hl => by
          simp only [Bool.and_eq_true, Bool.not_eq_true', beq_eq_false_iff_ne] at hl
          exact hl)
        hev hsx rfl h'
    have hreach' : reachGet (computeReach Γ.body) b' = true :=
      hfn.reach.closed f.bb bd M.hbd hreach b'
        (term_target_mono (f := { f with stmt := f.stmt + 1 }) rfl hsucc hs'' h')
    unfold blockStart at hstart
    obtain ⟨blk', hblk', hpc'⟩ := Option.map_eq_some_iff.mp hstart
    have hb'lt : b' < Γ.body.blocks.size := by
      rw [← hfn.blocksSize]; exact (Array.getElem?_eq_some_iff.mp hblk').1
    obtain ⟨bd', hbd''⟩ : ∃ bd', Γ.body.blocks[b']? = some bd' :=
      ⟨_, Array.getElem?_eq_getElem hb'lt⟩
    refine .inl ⟨s1', hsteps, Or.inl ⟨{ f with bb := b', stmt := 0 }, rest, blk', bd', ?_,
      hreach', fused_start hfn hreach' hbd'' hblk'⟩⟩
    refine { stack := hs'', body := M.body, pu := M.pu, cont := M.cont, hblk := hblk',
             hbd := hbd'', le := Nat.zero_le _, pc := hpc', rel := ?_, sl := ?_,
             pb := hpb', fresh := fun a ha => M.fresh a (by rw [← hsz]; exact ha),
             dinv := M.dinv.of_memKept hkept }
    · show FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get b' 0)
        { f with bb := b', stmt := 0 } s'.mem s1'
      refine hrel'.weaken fun l hl => ?_
      obtain ⟨h1, h2⟩ := fused_live hlow hfn.live M.hbd hst hlen1 rfl hsucc l hl
      simp [h1, h2]
    · intro l p hp
      show (computeStorage Γ.body).get b' 0 l = true
      have h0 := M.sl l p hp
      obtain ⟨cl, rv, hsta⟩ := hlow.assign_shape
      have h1 := (hfn.storage.stmt f.bb bd M.hbd f.stmt st hst).1 l h0
        (by rw [hsta]; intro e; cases e)
      rw [hlen1] at h1
      exact hfn.storage.term f.bb bd M.hbd b' hsucc l h1

/-- `fn_sim` with the returned value related to R's return registers (`RetValX`). -/
theorem fn_sim_ret {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o s s1.fp) :
    ∀ {n : Nat} {s s' : Spec.State} {s1 : R.RState}, MatchX Γ ι s s1 → L0Steps o n s s' →
      (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧ RetValX Γ ι v regs) ∨
      (∃ s1', StepsTo c ch s1 s1' ∧ DeadAt Γ s') := by
  intro n s s' s1 hm hrun
  revert s1
  induction hrun with
  | zero s0 => intro s1 hm; exact .inl ⟨s1, .refl _, hm⟩
  | succ hstep hrest ih =>
    intro s1 hm
    rcases fn_step_sim_ret (ch := ch) hfn hmode hρ hinc hm (hpick _ _) hstep with
      ⟨s1', hst, hm'⟩ | ⟨v, regs, incoming, hfinal, hret, hval⟩ | hdead
    · rcases ih hm' with ⟨s1'', hst', hm''⟩ | ⟨s1'', v, regs, incoming, hst', hf, hr, hv⟩ |
        ⟨s1'', hst', hd⟩
      · exact .inl ⟨s1'', hst.trans hst', hm''⟩
      · exact .inr (.inl ⟨s1'', v, regs, incoming, hst.trans hst', hf, hr, hv⟩)
      · exact .inr (.inr ⟨s1'', hst.trans hst', hd⟩)
    · cases hrest with
      | zero => exact .inr (.inl ⟨s1, v, regs, incoming, .refl _, hfinal, hret, hval⟩)
      | succ hstep' _ =>
        have := step_final_none hstep'
        rw [hfinal] at this
        cases this
    · cases hrest with
      | zero => exact .inr (.inr ⟨s1, .refl _, hdead⟩)
      | succ hstep' _ =>
        obtain ⟨f, rest, hs, hb, hpu, hst0, hd⟩ := hdead
        exact absurd hstep' (dead_no_step hs hb hpu hst0 hd)

/-! ### From entry -/

/-- M5a's function theorem from entry: given L0's entry frame and R at the prologue (as in
`match_entry`), every L0 run of the function is matched by an R run through the prologue to
related states, or L0 returned and R's `ret` ends the function with the value related, or
L0 reached a dead block (`DeadAt`), whose terminator is UB. `hdinv` is the deref rules'
invariant (`DerefInv`) for L0's entry memory: live allocations disjoint, and no live byte
carrying the provenance of a live, non-empty allocation `ι` drops (the caller's side, M5c/M6);
every step keeps it (`MatchAt.dinv`). -/
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
    (hdinv : DerefInv ι s.mem)
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧ RetValX Γ ι v regs) ∨
      (∃ s1', StepsTo c ch s1 s1' ∧ DeadAt Γ s') := by
  obtain ⟨s0, hst0, hm0⟩ := match_entry (ch := ch) hpl hslots hcode hnoesc hblk hbd hstart
    hfn.reach.entry (fused_start hfn hfn.reach.entry hbd hblk) hs hbody hbb hstmt hpu hcont hal
    qs hloc hrel hmem hhid
    hprov hapart hsl hpb hfresh hdinv
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩ | ⟨s1', hst, hd⟩
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr ⟨s1', hst0.trans hst, hd⟩)

end Ryo.Proofs.Lower
