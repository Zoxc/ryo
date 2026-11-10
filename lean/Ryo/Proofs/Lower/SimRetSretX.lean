/-
Ryo.Proofs.Lower.SimRetSretX — sret returns in functions with scopes (`LowersFnX`, M5b):
`SimRetSret.lean`'s argument with `Escape` and `End` scopes before instructions.

**What the steps keep** (`PinInv m0 so s args`): the argument registers are `args`, the sret
slot holds `gpr0`'s bytes (`PinAt`) and is not escaped, every allocation of the entry memory
`m0` keeps its address, liveness, size and mutability (`Keep0`; new allocations may appear),
and every escaped object's allocation is new (`id ≥ m0`'s count), so an `End` frees none of
the entry's allocations (the caller's sret destination among them).

- `applyScope_pin`, `scopes_pin`: a scope missing the slot (`pinScopesOk`) keeps `PinInv`:
  `Escape` adds a fresh allocation and an object apart from the slot (`escape_ok`,
  `escapedAt_append_apart`); `End` frees new objects only (`freeObjs_get`) and writes
  `Uninit` apart from the slot (`storageEnd_ok`, `writeFrame_frame`).
- `stepBody_pin`, `step_pin`, `steps_pin`: `step_keep`'s cases with objects present (an `arg`'s
  write at the private slot, `writeFrame_frame_at`; memory changes by `KeepM`).
- `sim_retSretX`: `sim_retSret` from `TermAtX`: the `store.copy` after the first instruction's
  scopes (`step_of_view_scopes`), then the `ret`.
-/
import Ryo.Proofs.Lower.SimRetSret
import Ryo.Proofs.Scope

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The entry memory kept -/

/-- Every allocation of `m0` is in `m` with its address, liveness, size and mutability. -/
def Keep0 (m0 m : Memory) : Prop :=
  ∀ id a, m0.get? id = some a → ∃ a', m.get? id = some a' ∧ a'.addr = a.addr ∧
    a'.live = a.live ∧ a'.data.size = a.data.size ∧ a'.mutable = a.mutable

theorem Keep0.refl (m : Memory) : Keep0 m m := fun _ a h => ⟨a, h, rfl, rfl, rfl, rfl⟩

theorem Keep0.keepM {m0 m m' : Memory} (h : Keep0 m0 m) (hk : KeepM m m') : Keep0 m0 m' := by
  intro id a ha
  obtain ⟨a1, h1, e1, e2, e3, e4⟩ := h id a ha
  have hlt : id < m.allocs.size :=
    (Array.getElem?_eq_some_iff.mp (show m.allocs[id]? = some a1 from h1)).1
  have hlt' : id < m'.allocs.size := by rw [hk.1]; exact hlt
  obtain ⟨a2, h2, f1, f2, f3, f4⟩ := hk.2 id m'.allocs[id] (get?_of_lt hlt')
  rw [h1] at h2
  have e := Option.some.inj h2
  rw [← e] at f1 f2 f3 f4
  exact ⟨_, get?_of_lt hlt', f1.trans e1, f2.trans e2, f3.trans e3, f4.trans e4⟩

theorem Keep0.push {m0 m : Memory} (h : Keep0 m0 m) (x : Allocation) :
    Keep0 m0 ⟨m.allocs.push x⟩ := by
  intro id a ha
  obtain ⟨a', h', e1, e2, e3, e4⟩ := h id a ha
  refine ⟨a', ?_, e1, e2, e3, e4⟩
  have hlt : id < m.allocs.size :=
    (Array.getElem?_eq_some_iff.mp (show m.allocs[id]? = some a' from h')).1
  have hne : id ≠ m.allocs.size := Nat.ne_of_lt hlt
  show (m.allocs.push x)[id]? = some a'
  simp only [Array.getElem?_push, hne, ↓reduceIte]
  exact h'

theorem Keep0.free {m0 m : Memory} (h : Keep0 m0 m) {es : List EscapedObj}
    (hf : ∀ e ∈ es, m0.allocs.size ≤ e.id) : Keep0 m0 (R.freeObjs m es) := by
  intro i a ha
  have hlt : i < m0.allocs.size :=
    (Array.getElem?_eq_some_iff.mp (show m0.allocs[i]? = some a from ha)).1
  rw [Ryo.Proofs.Scope.freeObjs_get es m i
    (fun e he hid => absurd (hid ▸ hf e he) (Nat.not_le.mpr hlt))]
  exact h i a ha

theorem SretDest.keep0 {m0 m : Memory} {pb : List AbstractByte} {n : Nat} (h : SretDest m0 pb n)
    (hk : Keep0 m0 m) : SretDest m pb n := by
  obtain ⟨q, id, y, hq, hp, hy, hl, hmu, h1, h2⟩ := h
  obtain ⟨y', hy', e1, e2, e3, e4⟩ := hk id y hy
  refine ⟨q, id, y', hq, hp, hy', by rw [e2]; exact hl, by rw [e4]; exact hmu,
    by rw [e1]; exact h1, ?_⟩
  show q.addr + n ≤ y'.addr + y'.data.size
  rw [e1, e3]
  exact h2

theorem SretOk.keep0 {Γ : TermCtx} {m0 m : Memory} {pb : List AbstractByte} (h : SretOk Γ m0 pb)
    (hk : Keep0 m0 m) : SretOk Γ m pb := by
  obtain ⟨ty, n, h1, h2, h3⟩ := h
  exact ⟨ty, n, h1, h2, h3.keep0 hk⟩

/-! ### The invariant -/

/-- What the steps of a function with scopes keep (see the module comment). -/
structure PinInv (m0 : Memory) (so : Int) (s : R.RState) (args : R.Regs) : Prop where
  hargs : s.args = args
  pin : PinAt s.st so args
  priv : ∀ j : Nat, j < 8 → s.st.escapedAt (so + j) = none
  keep : Keep0 m0 s.st.mem
  size : m0.allocs.size ≤ s.st.mem.allocs.size
  fresh : ∀ e ∈ s.st.escaped, m0.allocs.size ≤ e.id

theorem escapedAt_sub_none {st st' : OpSem.State} {o : Int}
    (hsub : ∀ e ∈ st'.escaped, e ∈ st.escaped) (h : st.escapedAt o = none) :
    st'.escapedAt o = none := by
  unfold OpSem.State.escapedAt at h ⊢
  rw [List.find?_eq_none] at h ⊢
  intro e he
  exact h e (hsub e he)

/-- A frame write's byte at a private offset. -/
theorem writeFrame_frame_at {st st' : OpSem.State} {off : Int} {bs : List AbstractByte} {o : Int}
    (h : st.writeFrame off bs = .ok st') (hn : st.escapedAt o = none) :
    st'.frame o =
      if off ≤ o ∧ o < off + bs.length then bs.getD (o - off).toNat .uninit else st.frame o := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    simp only [OpSem.State.privateIn, hn, Option.isNone_none, Bool.and_true, decide_eq_true_eq]

/-- A frame read of private bytes. -/
theorem readFrame_privB {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    (hn : ∀ j : Nat, j < bs.length → st.escapedAt (off + j) = none)
    (hb : ∀ (j : Nat) (hj : j < bs.length), st.frame (off + j) = bs[j]) :
    st.readFrame off bs.length = .ok bs := by
  have h := readFrame_eq_map (st := st) (off := off) (n := bs.length)
    (g := fun i => bs.getD i .uninit) (by
      intro i hi
      simp only [OpSem.State.byteAt, hn i hi, hb i hi]
      simp [List.getD, List.getElem?_eq_getElem hi, pure, Except.pure])
  rw [h]
  congr 1
  apply List.ext_getElem
  · simp
  · intro i h1 h2
    simp [List.getD, List.getElem?_eq_getElem h2]

/-- `arg_pin` with objects present: the slot's bytes private. -/
theorem arg_pinX {st st' : OpSem.State} {args : R.Regs} {so d : Int} {a : Asm.ArgReg}
    (hn : ∀ j : Nat, j < 8 → st.escapedAt (so + j) = none) (hpin : PinAt st so args)
    (hw : st.writeFrame d ((args.get (.ofArgReg a)).take a.size) = .ok st')
    (hd : (d + a.size ≤ so ∨ so + 8 ≤ d) ∨ (d = so ∧ a = sretReg)) : PinAt st' so args := by
  intro j hj
  rw [writeFrame_frame_at hw (hn j hj)]
  rcases hd with hd | ⟨hds, has⟩
  · have hlen := List.length_take_le a.size (args.get (.ofArgReg a))
    have hc : ¬ (d ≤ so + (j : Int) ∧
        so + (j : Int) < d + (((args.get (.ofArgReg a)).take a.size).length : Int)) := by
      omega
    rw [if_neg hc]
    exact hpin j hj
  · subst has
    split
    · have e : (so + (j : Int) - d).toNat = j := by rw [hds]; omega
      rw [e]
      rfl
    · exact hpin j hj

/-- One scope missing the sret slot keeps `PinInv` (see the module comment). -/
theorem applyScope_pin {m0 : Memory} {so : Int} {args : R.Regs} {s s' : R.RState} {sc : R.Scope}
    (hd : sc.frameOffset.toInt + sc.size ≤ so ∨ so + 8 ≤ sc.frameOffset.toInt)
    (h : R.applyScope s sc = .ok s') (hi : PinInv m0 so s args) : PinInv m0 so s' args := by
  unfold R.applyScope at h
  split at h
  · rcases Ryo.Proofs.Scope.escape_ok h with rfl | ⟨bytes, a, -, -, -, -, -, -, rfl⟩
    · exact hi
    · refine ⟨hi.hargs, hi.pin, fun j hj => ?_, hi.keep.push a, ?_, ?_⟩
      · refine (escapedAt_append_apart (st := s.st)
          (e := ⟨sc.frameOffset.toInt, sc.size, s.st.mem.allocs.size⟩) rfl ?_).trans
          (hi.priv j hj)
        show ¬ (sc.frameOffset.toInt ≤ so + (j : Int) ∧
          so + (j : Int) < sc.frameOffset.toInt + (sc.size : Int))
        omega
      · show m0.allocs.size ≤ (s.st.mem.allocs.push a).size
        simp only [Array.size_push]
        have := hi.size
        omega
      · intro e he
        rcases List.mem_append.mp he with he | he
        · exact hi.fresh e he
        · simp only [List.mem_singleton] at he
          subst he
          exact hi.size
  · obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h
    have hesc := writeFrame_escaped hw
    have hkm := writeFrame_keepM hw
    have hsub : ∀ e ∈ st'.escaped, e ∈ s.st.escaped := by
      intro e he
      rw [hesc] at he
      exact (List.mem_filter.mp he).1
    refine ⟨hi.hargs, fun j hj => ?_, fun j hj => ?_, ?_, ?_, fun e he => hi.fresh e (hsub e he)⟩
    · show st'.frame (so + j) = _
      rw [writeFrame_frame (o := so + j) hw (by simp [inRange]; omega)]
      exact hi.pin j hj
    · exact escapedAt_sub_none hsub (hi.priv j hj)
    · exact (hi.keep.free fun e he => hi.fresh e (List.mem_filter.mp he).1).keepM hkm
    · show m0.allocs.size ≤ st'.mem.allocs.size
      rw [hkm.1]
      show m0.allocs.size ≤ (R.freeObjs _ _).allocs.size
      rw [Ryo.Proofs.Scope.freeObjs_size]
      exact hi.size
  · cases h
    exact hi

theorem scopes_pin {m0 : Memory} {so : Int} {args : R.Regs} :
    ∀ (l : List R.Scope) {s s' : R.RState},
    (∀ sc ∈ l, sc.frameOffset.toInt + sc.size ≤ so ∨ so + 8 ≤ sc.frameOffset.toInt) →
    l.foldlM R.applyScope s = .ok s' → PinInv m0 so s args → PinInv m0 so s' args
  | [], s, s', _, h, hi => by
    simp only [List.foldlM_nil, pure, Except.pure, Except.ok.injEq] at h
    subst h
    exact hi
  | sc :: l, s, s', hd, h, hi => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => rw [h1] at h; cases h
    | ok s1 =>
      rw [h1] at h
      exact scopes_pin l (fun sc' hs => hd sc' (List.mem_cons_of_mem _ hs)) h
        (applyScope_pin (hd sc (List.mem_cons_self ..)) h1 hi)

/-- The scopes at an instruction miss the sret slot. -/
theorem pinScopes_at {c : R.Code} {so : Int} (h : pinScopesOk so c.d = true) (k : Nat) :
    ∀ sc ∈ c.scopesAt k, sc.frameOffset.toInt + sc.size ≤ so ∨ so + 8 ≤ sc.frameOffset.toInt := by
  intro sc hsc
  unfold R.Code.scopesAt at hsc
  simp only [List.mem_map, List.mem_filter] at hsc
  obtain ⟨ks, ⟨hmem, -⟩, rfl⟩ := hsc
  have := Array.all_eq_true'.mp h ks (Array.mem_toList_iff.mp hmem)
  simpa using this

set_option maxRecDepth 8000 in
/-- An instruction's step after its scopes keeps `PinInv` (`step_keep`'s cases). -/
theorem stepBody_pin {c : R.Code} {s s' : R.RState} {ch : OpSem.Choice} {i : R.Insn}
    {so : Int} {m0 : Memory} {args : R.Regs} (hpe : c.mode.pe = false)
    (hok : pinInsnOk c.mode c.ρ so i = true) (hi : PinInv m0 so s args)
    (h : stepBody c s i ch = .ok (.step s')) : PinInv m0 so s' args := by
  have hfin : s'.args = s.args → s'.st.escaped = s.st.escaped → KeepM s.st.mem s'.st.mem →
      PinAt s'.st so s'.args → PinInv m0 so s' args := by
    intro ha he hk hp
    refine ⟨ha.trans hi.hargs, by rw [ha.trans hi.hargs] at hp; exact hp, fun j hj => ?_,
      hi.keep.keepM hk, by rw [hk.1]; exact hi.size,
      fun e he' => hi.fresh e (by rw [← he]; exact he')⟩
    rw [escapedAt_of_escaped he]
    exact hi.priv j hj
  have hpin0 : PinAt s.st so s.args := by rw [hi.hargs]; exact hi.pin
  cases i with
  | handler hh args t =>
    obtain ⟨ha, he, hk, hp⟩ := stepView_keep hpe hok hpin0 h
    exact hfin ha he hk hp
  | native op ops =>
    cases hf : op.full with
    | none =>
      unfold stepBody at h
      simp [hf, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
    | some f =>
      have hok' : pinShapeOk c.mode c.ρ so op ops f.info.shape = true := by
        have h0 : (match op.full with
            | some f => pinShapeOk c.mode c.ρ so op ops f.info.shape
            | none => true) = true := hok
        rw [hf] at h0
        exact h0
      unfold stepBody at h
      simp only [hf] at h
      cases hsh : f.info.shape <;> (try rw [hsh] at h) <;> (rw [hsh] at hok')
      case jmp =>
        split at h
        all_goals try contradiction
        all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
        simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
        subst h
        exact hfin rfl rfl (KeepM.refl _) hpin0
      case arg =>
        have hap : argPinOk so ops = true := hok'
        split at h
        all_goals try contradiction
        all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
        split at h
        all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
        obtain ⟨st, hw, h⟩ := ebind_ok' h
        simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
        subst h
        exact hfin rfl (writeFrame_escaped hw) (writeFrame_keepM hw)
          (arg_pinX (fun j hj => hi.priv j hj) hpin0 hw (argPinOk_spec (by assumption) hap))
      case ret =>
        split at h
        all_goals try contradiction
        all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
        repeat (obtain ⟨_, -, h⟩ := ebind_ok' h)
        first
          | (simp [pure, Except.pure] at h; done)
          | (simp only [pure, Except.pure, Except.ok.injEq] at h <;> cases h)
      case tailCall =>
        split at h
        all_goals try contradiction
        all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
        repeat (obtain ⟨_, -, h⟩ := ebind_ok' h)
        first
          | (simp [pure, Except.pure] at h; done)
          | (simp only [pure, Except.pure, Except.ok.injEq] at h <;> cases h)
      case call =>
        split at h
        all_goals try contradiction
        all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
        repeat' (first | (obtain ⟨_, -, h⟩ := ebind_ok' h) | split at h)
        all_goals first
          | (simp [pure, Except.pure] at h; done)
          | (simp only [pure, Except.pure, Except.ok.injEq] at h <;> cases h)
      case island =>
        try split at h
        all_goals try contradiction
        all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
        all_goals first
          | (simp [pure, Except.pure] at h; done)
          | (simp only [pure, Except.pure, Except.ok.injEq] at h <;> cases h)
      all_goals
        have hv : R.stepView c s (.native op ops) ch = .ok (.step s') := h
        have hvp : viewPinOk c.mode c.ρ so (.native op ops) = true := hok'
        obtain ⟨ha, he, hk, hp⟩ := stepView_keep hpe hvp hpin0 hv
        exact hfin ha he hk hp

/-- One step keeps `PinInv`: its scopes (`scopes_pin`), then the instruction (`stepBody_pin`). -/
theorem step_pin {c : R.Code} {s s' : R.RState} {ch : OpSem.Choice} {i : R.Insn}
    {so : Int} {m0 : Memory} {args : R.Regs} (hpe : c.mode.pe = false)
    (hsc : pinScopesOk so c.d = true) (hi : c.d.insns[s.pc]? = some i)
    (hok : pinInsnOk c.mode c.ρ so i = true) (hinv : PinInv m0 so s args)
    (h : R.step c s ch = .ok (.step s')) : PinInv m0 so s' args := by
  cases hf : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    unfold R.step at h
    simp [hi, hf, bind, Except.bind] at h
  | ok s0 =>
    rw [step_eq_stepBody hi hf] at h
    exact stepBody_pin hpe hok (scopes_pin _ (pinScopes_at hsc s.pc) hf hinv) h

theorem steps_pin {c : R.Code} {ch : OpSem.Choice} {so : Int} {m0 : Memory} {args : R.Regs}
    (hpe : c.mode.pe = false) (hsc : pinScopesOk so c.d = true)
    (hok : ∀ (k : Nat) i, c.d.insns[k]? = some i → pinInsnOk c.mode c.ρ so i = true) :
    ∀ {s s' : R.RState}, StepsTo c ch s s' → PinInv m0 so s args → PinInv m0 so s' args := by
  intro s s' hst
  induction hst with
  | refl s => exact id
  | @cons s0 s1 s2 hstep hrest ih =>
    intro hinv
    cases hi : c.d.insns[s0.pc]? with
    | none => unfold R.step at hstep; rw [hi] at hstep; cases hstep
    | some i => exact ih (step_pin hpe hsc hi (hok _ _ hi) hinv hstep)

/-! ### The return -/

/-- `sim_retSret` from `TermAtX` (see the module comment): `PinInv` at the fold `s0` of the first
instruction's scopes, the caller's destination in the entry memory `m0`. -/
theorem sim_retSretX {Γ : TermCtx} {c : R.Code} {s1 s0 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {so : Int} {next : Nat} {is : List R.Insn} (hlow : LowerRetSret Γ so .«return» is)
    (hat : TermAtX c s1 s0 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hlive : live 0 = true)
    (hcont : f.cont = .bottom) (hinc : IncomingOk c)
    {m0 : Memory} {args : R.Regs} (hpin : PinInv m0 so s0 args)
    (hpbl : (regBytes args sretReg).length = 8) (hdest : SretOk Γ m0 (regBytes args sretReg))
    (h : runOn (evalTerminator .«return») o s = (.ok (), s')) :
    ∃ v s1m regs incoming, s'.final = some (.returned v) ∧
      R.step c s1 ch = .ok (.step s1m) ∧
      R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) ∧
      RetSret Γ ι v (regBytes args sretReg) s0.st.mem s1m.st.mem regs := by
  cases hlow with
  | @mk i1 i2 ty sl0 k hkind hty hsl hsize hst hro hk =>
    obtain ⟨hi1, hfold⟩ := hat.head
    have hat2 := hat.tail
    have h2 := hat2.code 0 (by simp)
    have hs2 := hat2.scopes 0 (by simp)
    simp only [Nat.add_zero, List.getElem_cons_zero] at h2 hs2
    -- L0: `_0`'s bytes
    obtain ⟨p, ty', v, g, sx, hp, hty', hload, -, -, hfin⟩ := return_inv hs h
    have hfinal : s'.final = some (.returned v) := by rw [hfin hcont]
    rw [← hbody, hty] at hty'
    obtain rfl := Option.some.inj hty'
    obtain ⟨bs0, hld, hdec⟩ := typedLoad_inv hsize hload
    have hr := hrel.opnd hp hsl hlive
    obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld
    have hlen1 : bs1.length = sl0.size := Ryo.Proofs.Inline.readFrame_length hrf
    have hlen0 : bs0.length = sl0.size := (BytesInj.length hbi).trans hlen1
    -- the store through the sret pointer
    obtain ⟨ty2, n2, hty2, hn2, hd⟩ := hdest
    rw [hty] at hty2
    have hty2' := Option.some.inj hty2
    rw [← hty2', hsize] at hn2
    have hn2' := Option.some.inj hn2
    have hd' : SretDest s0.st.mem (regBytes args sretReg) bs1.length := by
      rw [hlen1, hn2']; exact hd.keep0 hpin.keep
    obtain ⟨q, mem', hq, hstore, hmstore⟩ := sret_store_ok hpbl hd'
    obtain ⟨v1, ps, r, hv, hh, ho, hops, hctl, hf1, hf2, hn32⟩ := storeCopyOk_spec hst
    rw [hmode, hρ] at hv
    have hpb := hpin.pin.bytes hpbl
    have hnp : ∀ j : Nat, j < (regBytes args sretReg).length →
        s0.st.escapedAt (so + j) = none := fun j hj => hpin.priv j (by omega)
    have hrp : s0.st.readFrame so 8 = .ok (regBytes args sretReg) := by
      have := readFrame_privB hnp hpb
      rw [hpbl] at this
      exact this
    have hfa := offOk_spec hf1
    have hfb := offOk_spec hf2
    have hop := opSem_storeCopy_fwd (ch := ch) hh ho ⟨hfa.1, hfa.2, hfb.1, hfb.2, hn32⟩ hrp hq
      hrf hstore
    have hstep1 := step_of_view_scopes (ch := ch) hi1 hfold hat.pe (hpl _ _ hi1) hv hctl
      (by rw [hops]; exact hop)
    -- the `ret` of the sret slot
    let s1m : R.RState := { s0 with pc := s0.pc + 1, st := { s0.st with mem := mem' } }
    obtain ⟨op, fo, sw, kw, rfl, hf, hsh, hsrc, hkw⟩ := retOps_spec hro
    have hk' : Asm.retParts k true = some (some ⟨false, 8, 0⟩, none) := hk
    have hparts : R.retRegs kw.toNat true = .ok [(⟨false, 8, 0⟩, .gpr 0)] := by
      rw [hkw]; exact retRegs_one hk'
    have hnp1 : ∀ j : Nat, j < (regBytes args sretReg).length →
        s1m.st.escapedAt (so + j) = none := fun j hj => hnp j hj
    have hrp2 : s1m.st.readFrame (sw.toInt + ((⟨false, 8, 0⟩ : Asm.RetPart).off : Int))
        (⟨false, 8, 0⟩ : Asm.RetPart).size = .ok (regBytes args sretReg) := by
      have e : sw.toInt + ((⟨false, 8, 0⟩ : Asm.RetPart).off : Int) = so := by
        rw [hsrc]; simp
      rw [e]
      have := readFrame_privB (st := s1m.st) hnp1 hpb
      rw [hpbl] at this
      exact this
    obtain ⟨regs, hfold2, hregs⟩ := ret_fold (st := s1m.st) (src := sw.toInt)
      (prs := [(⟨false, 8, 0⟩, .gpr 0)]) (by simp) (fun pr hpr => by
        simp only [List.mem_singleton] at hpr
        subst hpr
        exact ⟨_, hrp2⟩)
    obtain ⟨incoming, hinc'⟩ := hinc s1m.st
    have hstep2 : R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) := by
      rw [step_eq_stepBody_nil (s := s1m) h2 hs2]
      exact stepBody_ret hf hsh hparts hfold2 hinc'
    refine ⟨v, s1m, regs, incoming, hfinal, hstep1, hstep2, ?_, ty, bs0, bs1, q, hty,
      by rw [hsize, hlen0], hdec, hbi, hq, hmstore⟩
    exact hregs _ (List.mem_singleton_self _) _ hrp2

/-! ### From entry -/

/-- `fn_soundEscI` (`SimPrologI.lean`) with sret returns resolved (`StoppedX`'s `SretAtX` by
`sim_retSretX`; `PinInv` from the prologue's end, `match_entryEscI`, kept by `steps_pin` and
the return's scopes, `scopes_pin`). Beyond `fn_soundEscI`'s hypotheses: `fn_soundS`'s `hpsr`,
`hsr8`, `hsrd`. The sixth outcome: L0 returned `v` from `sa` to `sb`, and R's `ret` ends the
function with `RetSret`. -/
theorem fn_soundEscS {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ ι s s1, MatchEsc Γ c ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologICtx} {is : List R.Insn} {inps : List InputI} {lw : List ArgWrite}
    (hpl : LowerPrologI Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ) (hpsr : Γp.sret = Γ.sret)
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
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelI ι s1.fp s.mem s1.st.mem s1.args inps[j] qs[j])
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
    (hsr8 : ∀ so, Γ.sret = some so → (regBytes s1.args sretReg).length = 8)
    (hsrd : ∀ so, Γ.sret = some so → SretOk Γ s1.st.mem (regBytes s1.args sretReg))
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
        StoppedX Γ c ch ι' o sa sb s1') ∨
      (∃ ι' s1m sa sb m v regs incoming m1, ι.Le ι' ∧ StepsTo c ch s1 s1m ∧
        L0Steps o m s sa ∧ runOn (evalTerminator .«return») o sa = (.ok (), sb) ∧
        sb.final = some (.returned v) ∧
        R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) ∧
        RetSret Γ ι' v (regBytes s1.args sretReg) m1 s1m.st.mem regs) := by
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hpl' : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  obtain ⟨s0, hst0, hm0, hw0, ha0, hme0, hes0⟩ := match_entryEscI (ch := ch) hfn hmode hρ hpl
    hslots hpm hpρ hcode hnoobj hfree hblk hbd hstart hs hbody hbb hstmt hpu hcont hal qs hqs
    hloc hrel hmem hhid hprov hapart hsl hpb hfresh hdinv haligned
  rcases fn_simX hfn hmode hρ hinc hpick hre hfre hsk hm0 hpool
      (hfinv.of_steps hsk hst0) hrun with
    ⟨ι', s1', hle, hst, hm⟩ | ⟨ι', s1', s0', v, regs, incoming, hle, hst, hf, hr, hv⟩ |
    ⟨s1', hst, hd⟩ | ⟨ι', s1', hle, hst, hu⟩ | ⟨ι', s1', sa, sb, m, hle, hst, hsa, hsx⟩
  · exact .inl ⟨ι', s1', hle, hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨ι', s1', s0', v, regs, incoming, hle, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr (.inl ⟨s1', hst0.trans hst, hd⟩))
  · exact .inr (.inr (.inr (.inl ⟨ι', s1', hle, hst0.trans hst, hu⟩)))
  · rcases hsx with hA | hS
    · exact .inr (.inr (.inr (.inr (.inl ⟨ι', s1', sa, sb, m, hle, hst0.trans hst, hsa,
        .inl hA⟩))))
    · obtain ⟨f', rest', live, next, is', so, s0', hs', hb', hso, hlow, hat, hrel', hl0, hc',
        hret⟩ := hS
      have hpin2 := hfn.pinX so hso
      have hso' : Γp.sret = some so := hpsr.trans hso
      have hwin : (so, sretReg) ∈ sretWrites Γp.toPrologXCtx ++ lw := by
        simp [sretWrites, hso']
      have h8 := hsr8 so hso
      have hok : ∀ (k : Nat) i, c.d.insns[k]? = some i → pinInsnOk c.mode c.ρ so i = true :=
        fun k i h => by rw [hmode, hρ]; exact pinCheck_sound hpin2.1 k i h
      have hsc : pinScopesOk so c.d = true := hpin2.2
      have hinv0 : PinInv s1.st.mem so s0 s1.args := by
        refine ⟨ha0, PinAt.of_bytes h8 (fun j hj => hw0 _ hwin j hj), fun j _ => ?_,
          by rw [hme0]; exact Keep0.refl _, Nat.le_of_eq (by rw [hme0]),
          fun e he => by rw [hes0] at he; cases he⟩
        unfold OpSem.State.escapedAt
        rw [hes0]
        rfl
      have hinv1 := steps_pin hpe hsc hok hst hinv0
      have hne : is' ≠ [] := by cases hlow; exact List.cons_ne_nil _ _
      have hinv2 : PinInv s1.st.mem so s0' s1.args :=
        scopes_pin _ (pinScopes_at hsc s1'.pc) (hat.fold hne) hinv1
      obtain ⟨v, s1m, regs, incoming, hfinal, hstep1, hstep2, hret'⟩ :=
        sim_retSretX (ch := ch) hs' hb' hmode.symm hρ.symm hpl' hlow hat hrel' hl0 hc' hinc
          hinv2 h8 (hsrd so hso) hret
      exact .inr (.inr (.inr (.inr (.inr ⟨ι', s1m, sa, sb, m, v, regs, incoming, _, hle,
        hst0.trans (hst.trans (.cons hstep1 (.refl _))), hsa, hret, hfinal, hstep2, hret'⟩))))

end Ryo.Proofs.Lower
