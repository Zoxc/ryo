/-
Ryo.Proofs.Lower.FnSimX — the function-level simulation L0 → R for functions with escaped locals
(aot.md §C1, M5b): `fn_sim_ret`/`fn_sound` (`FnEntry.lean`, `SimPrologX.lean`) for
`LowersFnX` (`Check/Lower/FnX.lean`), over `FnRelEsc.lean`'s `MatchAtX`.

- `MatchEscR`: the invariant, `MatchEsc` at a reachable block (`LowersFnX` has no fused block,
  so there is no point between a fused compare and its switch).
- `fn_step_simX`: one L0 step. A statement by `stmt_simX` (`StmtSimX.lean`), `ι` growing; a
  terminator from its `TermAtX` (`termAtX_of`: the pending `End`s at the range's first index are
  all its scopes, `ScopesOk.term`/`termEmpty`/`termInner`) by `sim_termX`/`sim_switchX`
  (`TermSimX.lean`), R's state and `fp` at the target the fold's, so `FnRelX` carries over
  (`FnRelX.congr'`) and the target block's first statement has no pending scope
  (`pendSpecs_zero`); a `return` by `sim_retXX`, R's `ret` ending the function in the fold.
- `fn_simX`: runs, with `∃ ι' ≥ ι`. Besides `fn_sim_ret`'s outcomes: L0 unwinding out of the
  function (`UnwindsX`, a `resume`) and a failed `Assert` starting its panic (`StoppedX`; the
  run stops at that step, so the outcome is a prefix of it). Terminators: `TermSimX.lean`'s
  `sim_termX`, `sim_switchX`, `sim_switchStaticX`, `sim_termMoreX`, `sim_retXX`.
- `match_entryEsc`: the prologue to `MatchEscR`, as `match_entryX`, with `FnRelX`'s object
  invariants from what the caller states (M5c discharges them): R has no escaped object at the
  prologue (`hnoobj`; the prologue's `arg`s keep the list, `writes_run_esc`), R's live
  allocations are apart from every local slot (`hfree`; the prologue keeps the memory), and the
  storage-live locals are aligned to their types (`haligned`, L0's side).
- `fn_soundEsc`: the two composed, `fn_soundX` for `LowersFnX`.

The trusted inputs are `fn_soundX`'s (`PicksAt`, `IncomingOk`).

The pool and function invariants (`PoolInv`, `SimPoolConst.lean`; `FnInv`, `SimFnPtrCast.lean`)
are carried along the run: `PoolInv` by `GlobKept`, `FnInv` by `GlobKept` (L0's first address
copies) and `SymsKept` (R's symbol slots, an open hypothesis of `fn_simX`); `FnInv` holds at
R's state at the statement and moves to its scope fold by `FnInv.of_fold`.
-/
import Ryo.Proofs.Lower.TermSimX
import Ryo.Proofs.Lower.StmtSimX
import Ryo.Proofs.Lower.SimPrologX
import Ryo.Proofs.Lower.SimPoolConst
import Ryo.Proofs.Lower.SimFnPtrCast

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-! ### Small facts -/

theorem inj_le_trans {ι1 ι2 ι3 : Inj} (h1 : ι1.Le ι2) (h2 : ι2.Le ι3) : ι1.Le ι3 :=
  fun a b h => h2 a b (h1 a b h)

theorem pendSpecs_zero (Γ : StmtCtx) (bd : BlockData) (blk : BlockCert) :
    pendSpecs Γ bd blk 0 = [] := by
  first | rfl | simp [pendSpecs]

/-- `FnRelX` for another frame with the same locals and body, and another R state with the same
escaped objects, memory and `fp`, given `FnRel` there. -/
theorem FnRelX.congr' {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f f' : Spec.Frame}
    {m : Memory} {s0 s1' : RState} (hX : FnRelX Γ ι live f m s0)
    (hrel : FnRel Γ ι live' f' m s1') (hloc : f'.locals = f.locals) (hbody : f'.body = f.body)
    (hesc : s1'.st.escaped = s0.st.escaped) (hmem : s1'.st.mem = s0.st.mem)
    (hfp : s1'.fp = s0.fp) : FnRelX Γ ι live' f' m s1' := by
  refine ⟨hrel, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hesc, hloc]; exact hX.objs
  · rw [hesc]; exact hX.disj
  · rw [hesc, hloc]; exact hX.owned
  · rw [hesc, hmem, hfp]; exact hX.free
  · rw [hloc, hbody]; exact hX.aligned
  · rw [hesc, hmem]; exact hX.idLt
  · rw [hesc, hmem, hfp]; exact hX.addrAt

/-! ### The invariant and the terminator's range -/

/-- The function simulation's invariant with scopes (see the module comment). -/
def MatchEscR (Γ : TermCtx) (c : R.Code) (ι : Inj) (s : Spec.State) (s1 : R.RState) : Prop :=
  ∃ s0 f rest blk bd, MatchAtX Γ c ι s s1 s0 f rest blk bd ∧
    reachGet (computeReach Γ.body) f.bb = true

/-- At the terminator point, R's range from `s1` with the pending scopes folded to `s0`. -/
theorem termAtX_of {Γ : TermCtx} {c : R.Code} {ι : Inj} {s : Spec.State} {s1 s0 : R.RState}
    {f : Spec.Frame} {rest : List Spec.Frame} {blk : BlockCert} {bd : BlockData}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    (hB : BlockOk Γ c.d bd blk) (hlen : f.stmt = bd.stmts.length)
    (hnone : blk.stmts[f.stmt]? = none) :
    TermAtX c s1 s0 blk.term.2 (rangeInsns c.d blk.term) := by
  have hpc0 : s1.pc = blk.term.1 := by rw [← M.pc, pcAt_none hnone]
  have hS := hfn.scopes f.bb bd blk M.hbd M.hblk
  have hpend := M.pend
  rw [hlen] at hpend
  have hl := rangeInsns_length (r := blk.term) hB.termIn
  refine ⟨fun j hj => ?_, fun j hj0 hj => ?_, fun hne => ?_, fun he => ?_, ?_, ?_⟩
  · rw [hpc0]; exact rangeInsns_at hB.termIn j hj
  · rw [hpc0]
    rw [hl] at hj
    exact hS.termInner _ (by omega) (by omega)
  · have hlt : blk.term.1 < blk.term.2 := by
      cases hR : rangeInsns c.d blk.term with
      | nil => exact absurd hR hne
      | cons _ _ =>
        rw [hR] at hl
        simp only [List.length_cons] at hl
        omega
    have hsc := hS.term hlt
    have hlen' := specsOk_length _ _ hsc
    have ht : (c.scopesAt s1.pc).take (pendSpecs Γ.toStmtCtx bd blk bd.stmts.length).length =
        c.scopesAt s1.pc := by
      apply List.take_of_length_le
      have h3 : (c.scopesAt s1.pc).length =
          (pendSpecs Γ.toStmtCtx bd blk bd.stmts.length).length := by
        rw [hpc0]; exact hlen'
      omega
    rw [ht] at hpend
    exact hpend
  · have hle : blk.term.2 ≤ blk.term.1 := by
      rw [he] at hl
      simp only [List.length_nil] at hl
      omega
    have h0 := hS.termEmpty hle
    rw [h0] at hpend
    simp only [List.length_nil, List.take_zero, List.foldlM_nil, pure, Except.pure,
      Except.ok.injEq] at hpend
    exact hpend.symm
  · rw [hpc0, hl]
    have := hB.termLe
    omega
  · rw [hmode]; exact hfn.notPe

/-! ### Outcomes that end the simulated run -/

/-- L0 unwinds out of the function (a `resume`, `ResumeOutX`): under `ExcAt` on the fold `s0`,
R's step from `s1` exits with a related exception object. -/
def UnwindsX (c : R.Code) (ch : OpSem.Choice) (ι : Inj) (s' : Spec.State) (s1 : R.RState) :
    Prop :=
  ∃ (f : Spec.Frame) (x : Int) (s0 : R.RState), ResumeOutX c ch ι s' f s1 s0 x

/-- L0's `return` from `s` to `s'` of a function returning through the caller's sret pointer,
R at the return's instructions in `s1` (its scopes folding to `s0`): the facts `sim_retSretX`
needs (`SimRetSretX.lean`'s `fn_soundEscS` resolves it). -/
def SretAtX (Γ : TermCtx) (c : R.Code) (ι : Inj) (o : Spec.Oracle) (s s' : Spec.State)
    (s1 : R.RState) : Prop :=
  ∃ (f : Spec.Frame) (rest : List Spec.Frame) (live : Local → Bool) (next : Nat)
    (is : List R.Insn) (so : Int) (s0 : R.RState), s.stack = f :: rest ∧ Γ.body = f.body ∧
    Γ.sret = some so ∧ LowerRetSret Γ so .«return» is ∧ TermAtX c s1 s0 next is ∧
    FnRel Γ.toStmtCtx ι live f s.mem s0 ∧ live 0 = true ∧ f.cont = .bottom ∧
    runOn (evalTerminator .«return») o s = (.ok (), s')

/-- The L0 step `s → s'` starts a failed `Assert`'s panic (`AssertFailsX`): R is at the panic
call's code (from `s1'`, its scopes folding to `s0'`), `FnRelX` holds for L0's frame there.
The run stops here (M5c continues from it). Or it is an sret return (`SretAtX`). -/
def StoppedX (Γ : TermCtx) (c : R.Code) (ch : OpSem.Choice) (ι : Inj) (o : Spec.Oracle)
    (s s' : Spec.State) (s1 : R.RState) : Prop :=
  (∃ (s1' s0' : R.RState) (f : Spec.Frame) (rest : List Spec.Frame) (live : Local → Bool)
    (next : Nat) (msg : AssertMessage) (unwind : UnwindAction) (tl : List R.Insn),
    StepsTo c ch s1 s1' ∧ s.stack = f :: rest ∧ TermAtX c s1' s0' next tl ∧
    FnRelX Γ.toStmtCtx ι live f s.mem s0' ∧ runOn (assertPanic msg unwind) o s = (.ok (), s')) ∨
  SretAtX Γ c ι o s s' s1

/-- A terminator `fn_step_simX` jumps after without `LowerTermMore` (a `goto` or a `switchInt`)
keeps L0's globals (`GlobKept.lean`). -/
theorem term_globKept {Γ : TermCtx} {next : Nat} {term : Terminator} {is : List R.Insn}
    (hT : LowerTermX Γ next term is) (hret : term ≠ .return)
    (hnm : ¬ LowerTermMore Γ next term is) {o : Spec.Oracle} {s s' : Spec.State}
    {r : Except Outcome Unit} (h : runOn (evalTerminator term) o s = (r, s')) :
    GlobKept s s' := by
  have hk : Keeps (evalTerminator term) := by
    rcases hT with hlow | hlow | hlow | hlow | hlow | ⟨_, _, hlow⟩
    · cases hlow with
      | goto => exact keeps_term_goto _
      | ret => exact absurd rfl hret
      | switchNone => exact keeps_term_switchInt _ _ _
      | switchBool => exact keeps_term_switchInt _ _ _
      | switchInt => exact keeps_term_switchInt _ _ _
    · cases hlow <;> exact keeps_term_switchInt _ _ _
    · exact absurd hlow.term_eq hret
    · cases hlow; exact keeps_term_switchInt _ _ _
    · exact absurd hlow hnm
    · exact absurd hlow.term_eq hret
  have := hk.run o s
  rw [h] at this
  exact this

/-! ### One step -/

/-- One L0 step from `MatchEscR` (see the module comment). -/
theorem fn_step_simX {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    {s s' : Spec.State} {s1 : R.RState} (hm : MatchEscR Γ c ι s s1)
    (hpick : MatchEsc Γ c ι s s1 → PicksAt Γ o ch s s1.fp)
    (hpool : PoolInv Γ.poolAt c.ρ ι s) (hre : ReusesAt o)
    (hfinv : FnInv Γ.fnSymAt c.ρ ι s s1.st) (hfre : FnReusesAt o) (hsk : SymsKept c ch)
    (h : runOn Sem.step o s = (.ok (), s')) :
    (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ MatchEscR Γ c ι' s' s1' ∧
      PoolInv Γ.poolAt c.ρ ι' s' ∧ FnInv Γ.fnSymAt c.ρ ι' s' s1'.st) ∨
      (∃ s0 v regs incoming, s'.final = some (.returned v) ∧
        R.step c s1 ch = .ok (.done (R.exit s0 (.ret regs incoming))) ∧ RetValX Γ ι v regs) ∨
      DeadAt Γ s' ∨ UnwindsX c ch ι s' s1 ∨ StoppedX Γ c ch ι o s s' s1 := by
  have hfin := step_final_none h
  obtain ⟨s0, f, rest, blk, bd, M, hreach⟩ := hm
  have hbd' : f.body.blocks[f.bb]? = some bd := by rw [M.body]; exact M.hbd
  have hB := hfn.block f.bb bd blk hreach M.hbd M.hblk
  have hnf : blk.fused = false := hfn.noFused f.bb blk M.hblk
  have hsz : blk.stmts.size = bd.stmts.length := by
    have hl := hB.len
    rw [hnf] at hl
    simpa using hl
  cases hst : bd.stmts[f.stmt]? with
  | some st =>
    obtain ⟨s1x, f1, rest1, hev, hs1x, rfl⟩ := step_stmt_inv M.stack hfin M.pu hbd' hst h
    have hlt : f.stmt < bd.stmts.length := (List.getElem?_eq_some_iff.mp hst).1
    have hr : blk.stmts[f.stmt]? = some blk.stmts[f.stmt] :=
      Array.getElem?_eq_getElem (by omega)
    obtain ⟨h1, h2, hnext, hlow⟩ := hB.stmt _ _ _ hst hr
    obtain ⟨ι', s1', s0', f', hle, hsteps, hs', hb', hbb', hst', hpu', hc', hpc', hpend', hrel',
      hsl', hpb', hfr', hdi'⟩ :=
      stmt_simX (ch := ch) hfn hmode hρ M (hpick ⟨s0, f, rest, blk, bd, M⟩) hpool hre
        (hfinv.of_fold hsk M.pend) hfre hst hr h1 h2 hnext hlow hev
    rw [hs'] at hs1x
    obtain ⟨e1, e2⟩ := List.cons.inj hs1x
    subst e1 e2
    refine .inl ⟨ι', s1', hle, hsteps, ⟨s0', { f' with stmt := f'.stmt + 1 }, rest, blk, bd, ?_,
      ?_⟩, hpool.keep hle ((stmt_globKept hev).trans (GlobKept.of_eq rfl rfl rfl)),
      hfinv.keep hle (GlobKept.fns ((stmt_globKept hev).trans (GlobKept.of_eq rfl rfl rfl)))
        (hsk.steps hsteps)⟩
    · refine { stack := rfl, body := hb'.trans M.body, pu := hpu'.trans M.pu,
               cont := hc'.trans M.cont, hblk := ?_, hbd := ?_, le := ?_, pc := ?_,
               pend := ?_, rel := ?_, sl := ?_, pb := hpb', fresh := hfr', dinv := hdi' }
      · show Γ.blocks[f'.bb]? = some blk
        rw [hbb']; exact M.hblk
      · show Γ.body.blocks[f'.bb]? = some bd
        rw [hbb']; exact M.hbd
      · show f'.stmt + 1 ≤ bd.stmts.length
        rw [hst']; exact hlt
      · show pcAt blk (f'.stmt + 1) = s1'.pc
        rw [hst', hpc']
      · show ((c.scopesAt s1'.pc).take
            (pendSpecs Γ.toStmtCtx bd blk (f'.stmt + 1)).length).foldlM R.applyScope s1' =
          .ok s0'
        rw [hst']; exact hpend'
      · show FnRelX Γ.toStmtCtx ι' ((computeLive Γ.body).get f'.bb (f'.stmt + 1))
          { f' with stmt := f'.stmt + 1 } s1x.mem s0'
        have h2 : FnRelX Γ.toStmtCtx ι' ((computeLive Γ.body).get f'.bb (f'.stmt + 1)) f'
            s1x.mem s0' := by
          rw [hbb', hst']; exact hrel'
        exact FnRelX.congr' h2 (h2.rel.congr rfl rfl rfl rfl) rfl rfl rfl rfl rfl
      · intro l p hp
        show (computeStorage Γ.body).get f'.bb (f'.stmt + 1) l = true
        rw [hbb', hst']
        exact hsl' l p hp
    · show reachGet (computeReach Γ.body) f'.bb = true
      rw [hbb']; exact hreach
  | none =>
    have h' := step_term_inv M.stack hfin M.pu hbd' hst h
    have hlen : f.stmt = bd.stmts.length := by
      have := List.getElem?_eq_none_iff.mp hst
      exact Nat.le_antisymm M.le this
    have hT := hB.term hnf
    have hnone : blk.stmts[f.stmt]? = none := by
      rw [Array.getElem?_eq_none_iff]; omega
    have hat := termAtX_of hfn hmode M hB hlen hnone
    have hlr := (hfn.live.term f.bb bd M.hbd).1
    by_cases hret : bd.term = .return
    · have hlow := hT
      rw [hret] at hlow h'
      have hl0 : (computeLive Γ.body).get f.bb f.stmt 0 = true := by
        rw [hlen]; exact hlr 0 (by rw [hret]; simp [termReads])
      rcases hlow.ret_cases with hX | ⟨so, hso, hS⟩
      · obtain ⟨i, hi⟩ := hX.single
        have hat' := hat
        rw [hi] at hX hat'
        obtain ⟨v, regs, incoming, hfinal, hstep, hval⟩ := sim_retXX (ch := ch) M.stack
          M.body.symm hX hat' M.rel.rel hl0 M.cont (hinc s0.st) h'
        exact .inr (.inl ⟨s0, v, regs, incoming, hfinal, hstep, hval⟩)
      · exact .inr (.inr (.inr (.inr (.inr ⟨f, rest, _, _, _, so, s0, M.stack, M.body.symm, hso,
          hS, hat, M.rel.rel, hl0, M.cont, h'⟩))))
    · have hplA : ∀ i ∈ rangeInsns c.d blk.term, PlainView c.mode c.ρ i := by
        intro i hi
        obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hi
        have hc := hat.code j hj
        rw [hmode, hρ]
        exact hfn.plain _ _ hc
      have hliveS : ∀ (d : Operand) cs ow l, bd.term = .switchInt d cs ow →
          l ∈ operandLocals d → (computeLive Γ.body).get f.bb f.stmt l = true := by
        intro d cs ow l he hd
        rw [hlen]
        exact hlr l (by rw [he]; exact hd)
      have hlive : ∀ (d : Operand) cs ow l, bd.term = .switchInt d cs ow → d.local? = some l →
          (computeLive Γ.body).get f.bb f.stmt l = true := by
        intro d cs ow l he hd
        rw [hlen]
        exact hlr l (by rw [he]; exact operand_local_mem hd)
      have hJ : JumpOutX Γ c ch ι ((computeLive Γ.body).get f.bb f.stmt) bd.term s s' f rest s1
            s0 ∨ DeadAt Γ s' ∨ UnwindsX c ch ι s' s1 ∨ StoppedX Γ c ch ι o s s' s1 := by
        by_cases hmore : Nonempty (LowerTermMore Γ blk.term.2 bd.term (rangeInsns c.d blk.term))
        · obtain ⟨hlowM⟩ := hmore
          have hlvA : ∀ (d : Operand) e msg target unwind l,
              bd.term = .assert d e msg target unwind → l ∈ operandLocals d →
              (computeLive Γ.body).get f.bb f.stmt l = true := by
            intro d e msg target unwind l he hd
            rw [hlen]
            exact hlr l (by rw [he]; exact List.mem_append_left _ hd)
          have hres : ∀ (k : Nat) i, c.d.insns[k]? = some i → isResume c.mode c.ρ i = true →
              contAt c.d k = true := by
            rw [hmode, hρ]; exact hfn.resumes
          rcases sim_termMoreX (ch := ch) (live' := (computeLive Γ.body).get f.bb f.stmt)
              M.stack M.body.symm M.cont hmode hρ hlowM hat hplA hres M.rel.rel hlvA
              (fun _ h => h) h' with
            hj | ⟨_, _, msg, _, unwind, _, s1', s0', tl, hst, hatx, hst0, hfp0, hrelF, hpan⟩ |
              ⟨x, _, hr⟩
          · exact .inl hj
          · exact .inr (.inr (.inr (.inl ⟨s1', s0', f, rest, _, _, msg, unwind, tl, hst, M.stack,
              hatx, FnRelX.congr' M.rel hrelF rfl rfl (by rw [hst0]) (by rw [hst0]) hfp0,
              hpan⟩)))
          · exact .inr (.inr (.inl ⟨f, x, s0, hr⟩))
        · have hnm : ¬ LowerTermMore Γ blk.term.2 bd.term (rangeInsns c.d blk.term) :=
            fun hl => hmore ⟨hl⟩
          have hout : SwitchOutX Γ c ch ι ((computeLive Γ.body).get f.bb f.stmt) s s' f rest s1
              s0 := by
            rcases hT with hlow | hlow | hlow | hlow | hlow | ⟨_, _, hlow⟩
            · exact .inl (sim_termX (ch := ch) (live' := (computeLive Γ.body).get f.bb f.stmt)
                M.stack M.body.symm hmode hρ hlow hret hat hplA M.rel.rel hlive (fun _ h => h)
                h')
            · exact sim_switchX (ch := ch) M.stack M.body.symm hmode hρ hlow hat hplA M.rel.rel
                hliveS (fun _ h => h) h'
            · exact absurd hlow.term_eq hret
            · exact sim_switchStaticX (ch := ch) M.stack hmode hρ hlow hat hplA M.rel.rel
                (fun _ h => h) h'
            · exact absurd hlow hnm
            · exact absurd hlow.term_eq hret
          rcases hout with
            ⟨s1', f', hsteps, hs', -, -, hstart, hmem, hsesc, hsmem, hsfp, hrel'⟩ |
              ⟨ow, hs'', hd⟩
          · obtain ⟨b', hsucc, hs'', -⟩ := term_nextX hT hret hnm M.stack M.body h'
            rw [hs''] at hs'
            obtain ⟨e, -⟩ := List.cons.inj hs'
            subst e
            exact .inl ⟨s1', b', hsteps, hsucc, hs'', hmem, hstart, hsesc, hsmem, hsfp, hrel',
              term_globKept hT hret hnm h'⟩
          · exact .inr (.inl ⟨_, rest, hs'', M.body, M.pu, rfl, hd⟩)
      rcases hJ with ⟨s1', b', hsteps, hsucc, hs'', hmem, hstart, hsesc, hsmem, hsfp, hrel', hgk⟩ |
        hd | hu | hstop
      rotate_left
      · exact .inr (.inr (.inl hd))
      · exact .inr (.inr (.inr (.inl hu)))
      · exact .inr (.inr (.inr (.inr hstop)))
      have hreach' : reachGet (computeReach Γ.body) b' = true :=
        hfn.reach.closed f.bb bd M.hbd hreach b' (term_target_mono M.stack hsucc hs'' h')
      unfold blockStart at hstart
      obtain ⟨blk', hblk', hpc'⟩ := Option.map_eq_some_iff.mp hstart
      have hb'lt : b' < Γ.body.blocks.size := by
        rw [← hfn.blocksSize]; exact (Array.getElem?_eq_some_iff.mp hblk').1
      obtain ⟨bd', hbd''⟩ : ∃ bd', Γ.body.blocks[b']? = some bd' :=
        ⟨_, Array.getElem?_eq_getElem hb'lt⟩
      refine .inl ⟨ι, s1', fun _ _ h => h, hsteps, ⟨s1', { f with bb := b', stmt := 0 }, rest,
        blk', bd', ?_, hreach'⟩, hpool.keep (fun _ _ h => h) hgk,
        hfinv.keep (fun _ _ h => h) hgk.fns (hsk.steps hsteps)⟩
      refine { stack := hs'', body := M.body, pu := M.pu, cont := M.cont, hblk := hblk',
               hbd := hbd'', le := Nat.zero_le _, pc := hpc', pend := ?_, rel := ?_, sl := ?_,
               pb := by rw [hmem]; exact M.pb, fresh := by rw [hmem]; exact M.fresh,
               dinv := by rw [hmem]; exact M.dinv }
      · -- no pending scope at a block's first statement
        show ((c.scopesAt s1'.pc).take (pendSpecs Γ.toStmtCtx bd' blk' 0).length).foldlM
          R.applyScope s1' = .ok s1'
        rw [pendSpecs_zero]
        all_goals first | rfl | simp [pure, Except.pure]
      · show FnRelX Γ.toStmtCtx ι ((computeLive Γ.body).get b' 0)
          { f with bb := b', stmt := 0 } s'.mem s1'
        have hr2 : FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get b' 0)
            { f with bb := b', stmt := 0 } s'.mem s1' := by
          refine hrel'.weaken fun l hl => ?_
          rw [hlen]
          exact (hfn.live.term f.bb bd M.hbd).2 b' hsucc l hl
        rw [hmem] at hr2 ⊢
        exact FnRelX.congr' M.rel hr2 rfl rfl hsesc hsmem hsfp
      · intro l p hp
        show (computeStorage Γ.body).get b' 0 l = true
        have := M.sl l p hp
        rw [hlen] at this
        exact hfn.storage.term f.bb bd M.hbd b' hsucc l this

/-! ### Runs -/

/-- `fn_sim_ret` for `LowersFnX`: `ι` grows along the run. -/
theorem fn_simX {Γ : TermCtx} {c : R.Code} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ ι s s1, MatchEsc Γ c ι s s1 → PicksAt Γ o ch s s1.fp) (hre : ReusesAt o)
    (hfre : FnReusesAt o) (hsk : SymsKept c ch) :
    ∀ {n : Nat} {ι : Inj} {s s' : Spec.State} {s1 : R.RState}, MatchEscR Γ c ι s s1 →
      PoolInv Γ.poolAt c.ρ ι s → FnInv Γ.fnSymAt c.ρ ι s s1.st → L0Steps o n s s' →
      (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ MatchEscR Γ c ι' s' s1') ∨
      (∃ ι' s1' s0 v regs incoming, ι.Le ι' ∧ StepsTo c ch s1 s1' ∧
        s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s0 (.ret regs incoming))) ∧ RetValX Γ ι' v regs) ∨
      (∃ s1', StepsTo c ch s1 s1' ∧ DeadAt Γ s') ∨
      (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ UnwindsX c ch ι' s' s1') ∨
      (∃ ι' s1' sa sb m, ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ L0Steps o m s sa ∧
        StoppedX Γ c ch ι' o sa sb s1') := by
  intro n ι s s' s1 hm hp hfi hrun
  revert ι s1
  induction hrun with
  | zero s0 => intro ι s1 hm _ _; exact .inl ⟨ι, s1, fun _ _ h => h, .refl _, hm⟩
  | succ hstep hrest ih =>
    intro ι s1 hm hp hfi
    rcases fn_step_simX (ch := ch) hfn hmode hρ hinc hm (hpick _ _ _) hp hre hfi hfre hsk
        hstep with
      ⟨ι1, s1', hle, hst, hm', hp', hfi'⟩ | ⟨s0, v, regs, incoming, hfinal, hret, hval⟩ | hdead |
        hunw | hstop
    · rcases ih hm' hp' hfi' with ⟨ι2, s1'', hle2, hst', hm''⟩ |
        ⟨ι2, s1'', s0', v, regs, incoming, hle2, hst', hf, hr, hv⟩ | ⟨s1'', hst', hd⟩ |
        ⟨ι2, s1'', hle2, hst', hu⟩ | ⟨ι2, s1'', sa, sb, m, hle2, hst', hsa, hsx⟩
      · exact .inl ⟨ι2, s1'', inj_le_trans hle hle2, hst.trans hst', hm''⟩
      · exact .inr (.inl ⟨ι2, s1'', s0', v, regs, incoming, inj_le_trans hle hle2,
          hst.trans hst', hf, hr, hv⟩)
      · exact .inr (.inr (.inl ⟨s1'', hst.trans hst', hd⟩))
      · exact .inr (.inr (.inr (.inl ⟨ι2, s1'', inj_le_trans hle hle2, hst.trans hst', hu⟩)))
      · exact .inr (.inr (.inr (.inr ⟨ι2, s1'', sa, sb, m + 1, inj_le_trans hle hle2,
          hst.trans hst', .succ hstep hsa, hsx⟩)))
    · cases hrest with
      | zero =>
        exact .inr (.inl ⟨ι, s1, s0, v, regs, incoming, fun _ _ h => h, .refl _, hfinal, hret,
          hval⟩)
      | succ hstep' _ =>
        have := step_final_none hstep'
        rw [hfinal] at this
        cases this
    · cases hrest with
      | zero => exact .inr (.inr (.inl ⟨s1, .refl _, hdead⟩))
      | succ hstep' _ =>
        obtain ⟨f, rest, hs, hb, hpu, hst0, hd⟩ := hdead
        exact absurd hstep' (dead_no_step hs hb hpu hst0 hd)
    · cases hrest with
      | zero => exact .inr (.inr (.inr (.inl ⟨ι, s1, fun _ _ h => h, .refl _, hunw⟩)))
      | succ hstep' _ =>
        obtain ⟨_, _, _, _, _, hfinal, _⟩ := hunw
        have := step_final_none hstep'
        rw [hfinal] at this
        cases this
    · exact .inr (.inr (.inr (.inr ⟨ι, s1, _, _, 0, fun _ _ h => h, .refl _, .zero _,
        hstop⟩)))

/-! ### Entry -/

/-- `writes_run` (`SimPrologX.lean`) with the escaped objects' list kept. -/
theorem writes_run_esc {c : Code} {ch : OpSem.Choice} :
    ∀ {is : List Insn} {ws : List ArgWrite}, ArgsAre is ws →
    ∀ (s : RState),
    (∀ j (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧ c.scopesAt (s.pc + j) = []) →
    (∀ w ∈ ws, ∀ j < w.2.size, s.st.escapedAt (w.1 + j) = none) →
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      s'.st.mem = s.st.mem ∧ s'.st.escaped = s.st.escaped ∧
      (∀ o, s'.st.escapedAt o = s.st.escapedAt o) ∧
      (∀ o, (∀ w ∈ ws, ¬ (w.1 ≤ o ∧ o < w.1 + w.2.size)) → s'.st.frame o = s.st.frame o) ∧
      (ws.Pairwise WriteDisj → ∀ w ∈ ws, ∀ j (hj : j < (regBytes s.args w.2).length),
        s'.st.frame (w.1 + j) = (regBytes s.args w.2)[j])
  | _, _, .nil, s, _, _ => by
    refine ⟨s, .refl s, by simp, rfl, rfl, rfl, rfl, fun _ => rfl, fun _ _ => rfl, ?_⟩
    intro _ w hw
    simp at hw
  | _, _, .cons (i := i) (is := is) (w := w) (ws := ws) hok hrest, s, hcode, hpriv => by
    have hlen := regBytes_length_le s.args w.2
    have hpw : ∀ j < (regBytes s.args w.2).length, s.st.escapedAt (w.1 + j) = none :=
      fun j hj => hpriv w (List.mem_cons_self ..) j (by omega)
    obtain ⟨st', hwr⟩ : ∃ st', s.st.writeFrame w.1 (regBytes s.args w.2) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    obtain ⟨hmem1, hesc1, hfr1⟩ := writeFrame_private_eq hwr hpw
    have h0 := hcode 0 (by simp)
    simp only [Nat.add_zero, List.getElem_cons_zero] at h0
    have hstep := step_arg (ch := ch) (off := w.1) (a := w.2) h0.1 h0.2 hok hwr
    let s1 : RState := { s with pc := s.pc + 1, st := st' }
    have hcode1 : ∀ j (hj : j < is.length),
        c.d.insns[s1.pc + j]? = some is[j] ∧ c.scopesAt (s1.pc + j) = [] := by
      intro j hj
      have := hcode (j + 1) (by simp; omega)
      have e : s1.pc + j = s.pc + (j + 1) := by show s.pc + 1 + j = _; omega
      rw [e]
      simpa using this
    have hpriv1 : ∀ v ∈ ws, ∀ j < v.2.size, s1.st.escapedAt (v.1 + j) = none := by
      intro v hv j hj
      show st'.escapedAt (v.1 + j) = none
      rw [hesc1]
      exact hpriv v (List.mem_cons_of_mem _ hv) j hj
    obtain ⟨s', hst, hpc, hfp, hargs, hmem, hescl, hesc, hout, hin⟩ :=
      writes_run_esc hrest s1 hcode1 hpriv1
    have hfr_out : ∀ o, ¬ (w.1 ≤ o ∧ o < w.1 + w.2.size) → st'.frame o = s.st.frame o := by
      intro o ho
      rw [hfr1 o]
      have : s.st.privateIn w.1 (regBytes s.args w.2).length o = false := by
        unfold OpSem.State.privateIn
        have : ¬ (w.1 ≤ o ∧ o < w.1 + ((regBytes s.args w.2).length : Int)) := by omega
        simp [this]
      rw [this]
      rfl
    have hfr_in : ∀ j (hj : j < (regBytes s.args w.2).length),
        st'.frame (w.1 + j) = (regBytes s.args w.2)[j] := by
      intro j hj
      rw [hfr1]
      have hpi : s.st.privateIn w.1 (regBytes s.args w.2).length (w.1 + j) = true := by
        unfold OpSem.State.privateIn
        rw [hpw j hj]
        simp only [Option.isNone_none, Bool.and_true, decide_eq_true_eq]
        omega
      rw [if_pos hpi]
      have e : (w.1 + (j : Int) - w.1).toNat = j := by omega
      rw [e, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hj, Option.getD_some]
    refine ⟨s', .cons hstep hst, ?_, hfp, hargs, ?_, ?_, ?_, ?_, ?_⟩
    · rw [hpc]; show s.pc + 1 + is.length = s.pc + (i :: is).length
      simp only [List.length_cons]; omega
    · rw [hmem]; exact hmem1
    · exact hescl.trans (writeFrame_escaped hwr)
    · intro o; rw [hesc o]; exact hesc1 o
    · intro o ho
      rw [hout o (fun v hv => ho v (List.mem_cons_of_mem _ hv))]
      exact hfr_out o (ho w (List.mem_cons_self ..))
    · intro hpw' v hv j hj
      have hpw'' := List.pairwise_cons.mp hpw'
      rcases List.mem_cons.mp hv with rfl | hv'
      · have hd := hpw''.1
        rw [hout]
        · exact hfr_in j hj
        · intro r hr hin'
          have := hd r hr
          unfold WriteDisj at this
          omega
      · exact hin hpw''.2 v hv' j hj

/-- From L0's entry frame and R at the prologue, R runs the prologue to `MatchEscR` (see the
module comment): `match_entryX`'s hypotheses, and `hnoobj`, `hfree`, `haligned` for `FnRelX`.
-/
theorem match_entryEsc {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    (hfn : LowersFnX Γ c.d)
    {Γp : PrologXCtx} {is : List R.Insn} {inps : List InputX} {lw : List ArgWrite}
    (hpl : LowerPrologX Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    -- R at the prologue
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoobj : s1.st.escaped = [])
    (hfree : ∀ id y, s1.st.mem.get? id = some y → y.live = true →
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        (y.addr : Int) + y.data.size ≤ s1.fp + sl.off ∨ s1.fp + sl.off + sl.size ≤ y.addr)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    -- L0's entry frame (`callBody`)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelX ι s1.fp s.mem s1.args inps[j] qs[j])
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
    (haligned : ∀ (l : Local) (p : ThinPointer) (ty : Spec.Ty), f.locals[l]? = some (some p) →
      f.body.locals[l]? = some ty → p.addr % ty.align.bytes = 0) :
    ∃ s1', StepsTo c ch s1 s1' ∧ MatchEscR Γ c ι s s1' := by
  have hnoesc : ∀ o, s1.st.escapedAt o = none := fun o => by
    unfold OpSem.State.escapedAt
    rw [hnoobj]
    rfl
  obtain ⟨s', hst, hpc, hfp, -, hmem', hesc', hescAt, -, hin⟩ :=
    writes_run_esc (ch := ch) hpl.insns s1 hcode (fun _ _ _ _ => hnoesc _)
  have hnoobj' : s'.st.escaped = [] := by rw [hesc', hnoobj]
  -- the inputs' locals, as `prologX_sim`
  have hlr : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      LocalRel ι s'.fp s'.st s.mem inps[j].slot qs[j] true := by
    intro j h1 h2
    obtain ⟨al, x, hp, hι, hx, hlive, haddr, hpaddr, hsize, hb⟩ := hrel j h1 h2
    refine .priv al x hp hι hx hlive (by rw [hfp]; exact haddr) hpaddr hsize
      (fun k _ => by rw [hescAt]; exact hnoesc _) ?_
    intro _ k hk
    rcases hb k hk with hu | ⟨p, hp', hle, b, hbk, hbi⟩
    · rw [hu]; trivial
    · obtain ⟨hkl, hbe⟩ := List.getElem?_eq_some_iff.mp hbk
      obtain ⟨hwm, -⟩ := input_write_mem hpl j h1 hp'
      have hfk := hin hpl.disj _ hwm (k - p.1) hkl
      dsimp only at hfk
      have e : inps[j].slot.off + (k : Int) =
          inps[j].slot.off + (p.1 : Int) + ((k - p.1 : Nat) : Int) := by omega
      rw [e, hfk, hbe]
      exact hbi
  have hfnrel : FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb f.stmt) f s.mem s' := by
    refine ⟨⟨?_, ?_⟩, hhid, hal, hprov, hapart, ?_⟩
    · rw [hmem']; exact hmem
    · intro l p hp _
      obtain ⟨j, h1, h2, rfl, rfl⟩ := hloc l p hp
      refine ⟨inps[j].slot, ?_, (hlr j h1 h2).weaken (fun _ => rfl)⟩
      have := inputsOk_slot hpl.inputs j h1
      rw [hslots] at this
      simpa using this
    · intro o e he
      rw [hescAt, hnoesc] at he
      cases he
  have hX : FnRelX Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb f.stmt) f s.mem s' := by
    refine ⟨hfnrel, fun e he => ?_, ?_, fun a b x e _ _ _ he _ => ?_, fun id y hy hl => ?_,
      haligned, fun e he => ?_, fun e he _ _ => ?_⟩
    · rw [hnoobj'] at he; simp at he
    · rw [hnoobj']; exact List.Pairwise.nil
    · rw [hnoobj'] at he; simp at he
    · refine .inr fun l sl hsl => ?_
      rw [hmem'] at hy
      rw [hfp]
      exact hfree id y hy hl l sl hsl
    · rw [hnoobj'] at he; simp at he
    · rw [hnoobj'] at he; simp at he
  refine ⟨s', hst, s', f, rest, blk, bd, ?_, by rw [hbb]; exact hfn.reach.entry⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, pend := ?_, rel := hX, sl := ?_, pb := hpb, fresh := hfresh,
           dinv := hdinv }
  · rw [hbb]; exact hblk
  · rw [hbb]; exact hbd
  · rw [hstmt]; exact Nat.zero_le _
  · rw [hstmt, hstart, hpc]
  · rw [hstmt, pendSpecs_zero]
    all_goals first | rfl | simp [pure, Except.pure]
  · intro l p hp
    rw [hbb, hstmt]
    exact hsl l p hp

/-- The function theorem from entry for `LowersFnX` (`fn_soundX` with scopes): every L0 run is
matched by an R run through the prologue to `MatchEscR` at some `ι' ≥ ι`, or L0 returned and
R's `ret` ends the function with the value related, or L0 reached a dead block. Besides
`fn_soundX`'s hypotheses: R has no escaped object at the prologue (`hnoobj`), R's live
allocations are apart from the local slots (`hfree`), and L0's storage-live locals are aligned
(`haligned`), for M5c to discharge. -/
theorem fn_soundEsc {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ ι s s1, MatchEsc Γ c ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologXCtx} {is : List R.Insn} {inps : List InputX} {lw : List ArgWrite}
    (hpl : LowerPrologX Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoobj : s1.st.escaped = [])
    (hfree : ∀ id y, s1.st.mem.get? id = some y → y.live = true →
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        (y.addr : Int) + y.data.size ≤ s1.fp + sl.off ∨ s1.fp + sl.off + sl.size ≤ y.addr)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelX ι s1.fp s.mem s1.args inps[j] qs[j])
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
    (haligned : ∀ (l : Local) (p : ThinPointer) (ty : Spec.Ty), f.locals[l]? = some (some p) →
      f.body.locals[l]? = some ty → p.addr % ty.align.bytes = 0)
    (hre : ReusesAt o) (hpool : PoolInv Γ.poolAt c.ρ ι s)
    (hfre : FnReusesAt o) (hsk : SymsKept c ch)
    (hfinv : FnInv Γ.fnSymAt c.ρ ι s s1.st)
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ MatchEscR Γ c ι' s' s1') ∨
      (∃ ι' s1' s0 v regs incoming, ι.Le ι' ∧ StepsTo c ch s1 s1' ∧
        s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s0 (.ret regs incoming))) ∧ RetValX Γ ι' v regs) ∨
      (∃ s1', StepsTo c ch s1 s1' ∧ DeadAt Γ s') ∨
      (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ UnwindsX c ch ι' s' s1') ∨
      (∃ ι' s1' sa sb m, ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ L0Steps o m s sa ∧
        StoppedX Γ c ch ι' o sa sb s1') := by
  obtain ⟨s0, hst0, hm0⟩ := match_entryEsc (ch := ch) hfn hpl hslots hcode hnoobj hfree hblk
    hbd hstart hs hbody hbb hstmt hpu hcont hal qs hloc hrel hmem hhid hprov hapart hsl hpb
    hfresh hdinv haligned
  rcases fn_simX hfn hmode hρ hinc hpick hre hfre hsk hm0 hpool
      (hfinv.of_steps hsk hst0) hrun with
    ⟨ι', s1', hle, hst, hm⟩ | ⟨ι', s1', s0', v, regs, incoming, hle, hst, hf, hr, hv⟩ |
    ⟨s1', hst, hd⟩ | ⟨ι', s1', hle, hst, hu⟩ | ⟨ι', s1', sa, sb, m, hle, hst, hsa, hsx⟩
  · exact .inl ⟨ι', s1', hle, hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨ι', s1', s0', v, regs, incoming, hle, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr (.inl ⟨s1', hst0.trans hst, hd⟩))
  · exact .inr (.inr (.inr (.inl ⟨ι', s1', hle, hst0.trans hst, hu⟩)))
  · exact .inr (.inr (.inr (.inr ⟨ι', s1', sa, sb, m, hle, hst0.trans hst, hsa, hsx⟩)))

end Ryo.Proofs.Lower
