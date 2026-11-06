/-
Ryo.Proofs.RSucc — where an R step goes (toward `rnext_succ`): the next instruction, when the
instruction falls through; one of its targets; or a landing pad of its call-site entry.

- `then_succ` (`Then.succ`'s results), `nativeCtl_spec` (a native instruction's control flow is
  its shape's, its targets among its operands').
- `unwindAt_out`, `stepView_out`, `step_out`, `answer_succ`: what a step, a `stepView` and an
  answer give.
- `rnext_succ`: an `RNext` goes to a successor (`Succ`): the next instruction when the
  instruction falls through (`insnFalls`, `Frame.flow`'s test), one of its targets
  (`insnTargets`), or a landing pad of its cleanup entry.
-/
import Ryo.Proofs.Step
import Ryo.Proofs.DeadStore.RStep

namespace Ryo.Proofs.RSucc

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- An R instruction's targets: its operands' (native) or its `then`'s (handler call). -/
def insnTargets : R.Insn → List Nat
  | .native _ ops => ops.flatMap Opnd.targetsOf
  | .handler _ _ t => t.targets

/-- `Then.succ`: the next instruction (after `next` or an untaken branch) or a target. -/
theorem then_succ {t : R.Then Nat} {pc pc' : Nat} {ctl : OpSem.Control}
    (h : t.succ pc ctl = some pc') :
    (pc' = pc + 1 ∧ (t = .next ∨ ∃ n x, t = .branch n x)) ∨ pc' ∈ t.targets := by
  unfold R.Then.succ at h
  split at h
  · cases h
    exact .inl ⟨rfl, .inl rfl⟩
  · split at h
    · cases h
      exact .inr (by simp [R.Then.targets])
    · cases h
      exact .inl ⟨rfl, .inr ⟨_, _, rfl⟩⟩
  · exact .inr (by simp only [R.Then.targets]; exact List.mem_of_getElem? h)
  · cases h

/-- A native instruction's control flow (`nativeCtl`): `next` for `op`/`lpad`, `trap`, a branch
for `br` to an operand's target, or a table of operands' targets. -/
theorem nativeCtl_spec {f : Full.Opcode} {ops : List (Opnd Nat)} {t : R.Then Nat}
    (h : R.nativeCtl f ops = some t) :
    (t = .next ∧ (f.info.shape = .op ∨ f.info.shape = .lpad)) ∨ t = .trap ∨
      (f.info.shape = .br ∧ ∃ n x, t = .branch n x ∧ x ∈ ops.flatMap Opnd.targetsOf) ∨
      (∃ ts, t = .table ts ∧ ∀ x ∈ ts, x ∈ ops.flatMap Opnd.targetsOf) := by
  have hnamed : ∀ (n : String) (o : Opnd Nat),
      ((f.info.operands.zip ops).find? (·.1.name == n)).map (·.2) = some o → o ∈ ops := by
    intro n o hn
    obtain ⟨e, he, rfl⟩ := Option.map_eq_some_iff.1 hn
    exact (List.of_mem_zip (List.mem_of_find?_eq_some he)).2
  unfold R.nativeCtl at h
  try dsimp only at h
  split at h
  · rename_i hsh
    cases h
    exact .inl ⟨rfl, .inl hsh⟩
  · rename_i hsh
    cases h
    exact .inl ⟨rfl, .inr hsh⟩
  · cases h
    exact .inr (.inl rfl)
  · rename_i hsh
    split at h
    · rename_i n x heq
      cases h
      simp only [Prod.mk.injEq] at heq
      refine .inr (.inr (.inl ⟨hsh, n, x, rfl, ?_⟩))
      exact List.mem_flatMap.2 ⟨_, hnamed "t" _ heq.2, by simp [Opnd.targetsOf]⟩
    · cases h
  · split at h
    · rename_i d hd
      cases h
      refine .inr (.inr (.inr ⟨_, rfl, fun x hx => ?_⟩))
      rcases List.mem_append.1 hx with hx | hx
      · obtain ⟨o, ho, hxo⟩ := List.mem_flatMap.1 hx
        refine List.mem_flatMap.2 ⟨o, ho, ?_⟩
        cases o <;> simp_all [Opnd.targetsOf]
      · simp only [List.mem_singleton] at hx
        subst hx
        exact List.mem_flatMap.2 ⟨_, hnamed "default" _ hd, by simp [Opnd.targetsOf]⟩
    · cases h
  · cases h

/-- Instruction `i` may continue at the next one (`Frame.flow`'s test, `Proto.fallsThrough`'s). -/
def insnFalls : R.Insn → Bool
  | .native op _ => !(op.info.shape == .jmp || op.info.shape == .ret ||
      op.info.shape == .tailCall || op.info.shape == .trap)
  | .handler h _ _ => h.info.shape == .op || h.info.shape == .br || h.info.shape == .lpad

/-- Where instruction `i` at `k` may go: the next instruction (when it falls through), one of its
targets, or a landing pad of its cleanup entry. -/
abbrev Succ (c : R.Code) (k : Nat) (i : R.Insn) (k' : Nat) : Prop :=
  (k' = k + 1 ∧ insnFalls i = true) ∨ k' ∈ insnTargets i ∨
    ∃ pad b, c.cleanupAt k = some (some pad, b) ∧ k' = pad

theorem unwindAt_out {c : R.Code} {s : R.RState} {exc : ThinPointer} {o : R.Out}
    (h : R.unwindAt c s exc = .ok o) :
    (∃ pad b, c.cleanupAt s.pc = some (some pad, b) ∧ ∃ s', o = .step s' ∧ s'.pc = pad) ∨
      ∃ f, o = .done f := by
  unfold R.unwindAt at h
  cases hcl : c.cleanupAt s.pc with
  | none => rw [hcl] at h; simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw] at h
  | some cb =>
    obtain ⟨opad, b⟩ := cb
    cases opad with
    | none =>
      rw [hcl] at h
      simp only [pure, Except.pure, Except.ok.injEq] at h
      exact .inr ⟨_, h.symm⟩
    | some pad =>
      rw [hcl] at h
      simp only [pure, Except.pure, Except.ok.injEq] at h
      exact .inl ⟨pad, b, by first | rfl | exact hcl, _, h.symm, rfl⟩

set_option maxRecDepth 8000 in
/-- What `stepView` gives: the shape's control flow from `pc`, unwinding (`resume`), or the end. -/
theorem stepView_out {c : R.Code} {s : R.RState} {i : R.Insn} {ch : OpSem.Choice} {o : R.Out}
    (h : R.stepView c s i ch = .ok o) :
    (∃ v t ctl pc', R.view c.mode c.ρ i = some v ∧ v.ctl = some t ∧ t.succ s.pc ctl = some pc' ∧
      ∃ st, o = .step { s with pc := pc', st }) ∨
    (∃ pad b, c.cleanupAt s.pc = some (some pad, b) ∧ ∃ s', o = .step s' ∧ s'.pc = pad) ∨
    ∃ f, o = .done f := by
  unfold R.stepView at h
  generalize hview : R.view c.mode c.ρ i = ov at h
  cases ov with
  | none => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some v =>
    cases hctl : v.ctl with
    | none => simp [hctl, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
    | some t =>
      by_cases hr : (v.op == .resume) = true
      · simp only [hctl, hr, ↓reduceIte, bind, Except.bind] at h
        generalize hops : v.ops = ops at h
        cases ops with
        | nil => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
        | cons o1 rest =>
          cases rest with
          | cons _ _ => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
          | nil =>
            cases o1
            case slot x =>
              dsimp only at h
              cases hrf : s.st.readFrame x 8 with
              | error e => rw [hrf] at h; simp at h
              | ok bs =>
                rw [hrf] at h
                try simp only at h
                cases hap : OpSem.asPtr bs with
                | error e => rw [hap] at h; simp at h
                | ok p =>
                  rw [hap] at h
                  try simp only at h
                  exact .inr (unwindAt_out h)
            all_goals simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
      · have hr' : (v.op == .resume) = false := by
          revert hr; cases (v.op == .resume) <;> simp
        by_cases hu : (v.op == .unreachable) = true
        · simp [hctl, hr', hu, bind, Except.bind, throw, throwThe, MonadExceptOf.throw] at h
        · have hu' : (v.op == .unreachable) = false := by
            revert hu; cases (v.op == .unreachable) <;> simp
          simp only [hctl, hr', hu', Bool.false_eq_true, ↓reduceIte, bind, Except.bind] at h
          generalize ho : OpSem.opSem v.op v.ops s.st ch = oo at h
          cases oo with
          | error e => simp at h
          | ok r =>
            obtain ⟨ctl, st⟩ := r
            cases i with
            | handler hh args tt =>
              try simp only at h
              generalize hcl : R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st = oc
                at h
              cases oc with
              | error e => simp at h
              | ok st2 =>
                try simp only at h
                generalize hp : t.succ s.pc ctl = op' at h
                cases op' with
                | none => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
                | some pc' =>
                  simp only [pure, Except.pure, Except.ok.injEq] at h
                  exact .inl ⟨v, t, ctl, pc', rfl, hctl, hp, st2, h.symm⟩
            | native op ops =>
              try simp only [pure, Except.pure] at h
              generalize hp : t.succ s.pc ctl = op' at h
              cases op' with
              | none => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
              | some pc' =>
                simp only [pure, Except.pure, Except.ok.injEq] at h
                exact .inl ⟨v, t, ctl, pc', rfl, hctl, hp, st, h.symm⟩

/-- A handler call's view checks its `then` against its shape: `next` for `op`/`lpad`, a branch
for `br`. -/
theorem view_handler_shape {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {v : R.View}
    (hv : R.view mode ρ (.handler h args t) = some v) :
    (t = .next → h.info.shape = .op ∨ h.info.shape = .lpad) ∧
      (∀ n x, t = .branch n x → h.info.shape = .br) := by
  simp only [R.view, Option.bind_eq_bind] at hv
  split at hv
  · cases hv
  cases hu : R.unpack ρ h mode args with
  | none => simp [hu] at hv
  | some vals =>
    simp only [hu, Option.bind_some] at hv
    refine ⟨fun ht => ?_, fun n x ht => ?_⟩ <;> subst ht <;>
      cases hs : h.info.shape <;> simp_all

/-- A native instruction's successor from its control flow (`nativeCtl`). -/
theorem native_succ {op : Reduced.Opcode} {f : Full.Opcode} {ops : List (Opnd Nat)}
    {t : R.Then Nat} {pc pc' : Nat} {ctl : OpSem.Control} (hf : op.full = some f)
    (hnc : R.nativeCtl f ops = some t) (h : t.succ pc ctl = some pc') :
    (pc' = pc + 1 ∧ insnFalls (.native op ops) = true) ∨ pc' ∈ insnTargets (.native op ops) := by
  have hsh := DeadStore.reduced_shape hf
  rcases then_succ h with ⟨hpc, hform⟩ | hmem
  · rcases nativeCtl_spec hnc with ⟨rfl, hs | hs⟩ | rfl | ⟨hs, n, x, rfl, hx⟩ | ⟨ts, rfl, hts⟩
    · exact .inl ⟨hpc, by simp only [insnFalls, hsh, hs] <;> decide⟩
    · exact .inl ⟨hpc, by simp only [insnFalls, hsh, hs] <;> decide⟩
    · rcases hform with h' | ⟨_, _, h'⟩ <;> cases h'
    · exact .inl ⟨hpc, by simp only [insnFalls, hsh, hs] <;> decide⟩
    · rcases hform with h' | ⟨_, _, h'⟩ <;> cases h'
  · rcases nativeCtl_spec hnc with ⟨rfl, -⟩ | rfl | ⟨-, n, x, rfl, hx⟩ | ⟨ts, rfl, hts⟩
    · simp [R.Then.targets] at hmem
    · simp [R.Then.targets] at hmem
    · simp only [R.Then.targets, List.mem_singleton] at hmem
      subst hmem
      exact .inr hx
    · exact .inr (hts _ hmem)

set_option maxRecDepth 8000 in
/-- What a step gives: from a `step`, a successor; from an external event, the state at the
same instruction. -/
theorem step_out {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {o : R.Out}
    (h : R.step c s ch = .ok o) :
    ∃ i, c.d.insns[s.pc]? = some i ∧ (∀ s', o = .step s' → Succ c s.pc i s'.pc) ∧
      ∀ q s1, o = .ext q s1 → s1.pc = s.pc := by
  cases hi : c.d.insns[s.pc]? with
  | none => unfold R.step at h; rw [hi] at h; cases h
  | some i =>
    refine ⟨i, rfl, ?_⟩
    cases i with
    | handler hh args t =>
      obtain ⟨s1, hsc⟩ := DeadStore.step_scopes_ok h
      have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hsc).pc
      rw [Ryo.Proofs.Shapes.step_handler hi hsc] at h
      rcases stepView_out h with ⟨v, t0, ctl, pc', hv, hctl, hsucc, st, rfl⟩ |
          ⟨pad, b, hcl, s', rfl, hp⟩ | ⟨fin, rfl⟩
      · refine ⟨fun s' hs' => ?_, fun q s2 hq => (by cases hq)⟩
        cases hs'
        obtain ⟨-, hct⟩ := DeadStore.view_handler hv
        have ht0 : t0 = t := Option.some.inj (hctl.symm.trans hct)
        subst ht0
        rw [hpc] at hsucc
        rcases then_succ hsucc with ⟨hpc', hform⟩ | hmem
        · refine .inl ⟨hpc', ?_⟩
          rcases hform with hn | ⟨n, x, hb⟩
          · rcases (view_handler_shape hv).1 hn with e | e <;>
              simp only [insnFalls, e] <;> decide
          · simp only [insnFalls, (view_handler_shape hv).2 n x hb] <;> decide
        · exact .inr (.inl hmem)
      · refine ⟨fun s'' hs'' => ?_, fun q s2 hq => (by cases hq)⟩
        cases hs''
        rw [hpc] at hcl
        exact .inr (.inr ⟨pad, b, hcl, hp⟩)
      · exact ⟨fun _ h' => (by cases h'), fun _ _ h' => (by cases h')⟩
    | native op ops =>
      cases hf : op.full with
      | none =>
        unfold R.step at h
        simp only [hi] at h
        obtain ⟨s1, -, h⟩ := DecodeLink.ebind_ok h
        simp [hf, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
      | some f =>
        unfold R.step at h
        simp only [hi] at h
        obtain ⟨s1, hsc, h⟩ := DecodeLink.ebind_ok h
        have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hsc).pc
        simp only [hf] at h
        cases hsh : f.info.shape <;> (try rw [hsh] at h)
        case jmp =>
          split at h
          all_goals try contradiction
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          simp only [pure, Except.pure, Except.ok.injEq] at h
          subst h
          refine ⟨fun s' hs' => ?_, fun q s2 hq => (by cases hq)⟩
          cases hs'
          first
            | exact .inr (.inl (by simp [insnTargets, Opnd.targetsOf]))
            | (subst_vars; exact .inr (.inl (by simp [insnTargets, Opnd.targetsOf])))
        case arg =>
          split at h
          all_goals try contradiction
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          split at h
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          obtain ⟨st, -, h⟩ := DecodeLink.ebind_ok h
          simp only [pure, Except.pure, Except.ok.injEq] at h
          subst h
          refine ⟨fun s' hs' => ?_, fun q s2 hq => (by cases hq)⟩
          cases hs'
          refine .inl ⟨by simp [hpc], ?_⟩
          simp only [insnFalls, DeadStore.reduced_shape hf, hsh] <;> decide
        case ret =>
          split at h
          all_goals try contradiction
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          repeat (obtain ⟨_, -, h⟩ := DecodeLink.ebind_ok h)
          simp only [pure, Except.pure, Except.ok.injEq] at h
          subst h
          exact ⟨fun _ h' => (by cases h'), fun _ _ h' => (by cases h')⟩
        case tailCall =>
          split at h
          all_goals try contradiction
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          repeat (obtain ⟨_, -, h⟩ := DecodeLink.ebind_ok h)
          simp only [pure, Except.pure, Except.ok.injEq] at h
          subst h
          exact ⟨fun _ h' => (by cases h'), fun _ _ h' => (by cases h')⟩
        case call =>
          split at h
          all_goals try contradiction
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          repeat' (first | (obtain ⟨_, -, h⟩ := DecodeLink.ebind_ok h) | split at h)
          all_goals
            simp only [pure, Except.pure, Except.ok.injEq] at h
            subst h
            exact ⟨fun _ h' => (by cases h'), fun q s2 h' => (by cases h'; exact hpc)⟩
        case island =>
          try split at h
          all_goals try contradiction
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          simp only [pure, Except.pure, Except.ok.injEq] at h
          subst h
          exact ⟨fun _ h' => (by cases h'), fun q s2 h' => (by cases h'; exact hpc)⟩
        -- the shapes `opSem` gives the meaning of: `stepView`
        all_goals
          have hs : R.opShape f = true := by unfold R.opShape; rw [hsh]
          have hv : R.stepView c s1 (.native op ops) ch = .ok o := h
          rcases stepView_out hv with ⟨v, t0, ctl, pc', hview, hctl, hsucc, st, rfl⟩ |
              ⟨pad, b, hcl, s', rfl, hp⟩ | ⟨fin, rfl⟩
          · refine ⟨fun s' hs' => ?_, fun q s2 hq => (by cases hq)⟩
            cases hs'
            obtain ⟨vals, t, -, hnc, rfl⟩ := Ryo.Proofs.Step.view_native hf hs hview
            have ht0 : t0 = t := (Option.some.inj hctl).symm
            subst ht0
            rw [hpc] at hsucc
            rcases native_succ hf hnc hsucc with h1 | h1
            · exact .inl h1
            · exact .inr (.inl h1)
          · refine ⟨fun s'' hs'' => ?_, fun q s2 hq => (by cases hq)⟩
            cases hs''
            rw [hpc] at hcl
            exact .inr (.inr ⟨pad, b, hcl, hp⟩)
          · exact ⟨fun _ h' => (by cases h'), fun _ _ h' => (by cases h')⟩

set_option maxRecDepth 8000 in
/-- What an answer gives: the next instruction (after a call or an island) or a landing pad. -/
theorem answer_succ {c : R.Code} {s s' : R.RState} {a : R.Answer}
    (h : R.answer c s a = .ok (.step s')) :
    (s'.pc = s.pc + 1 ∧ ∃ op ops f, c.d.insns[s.pc]? = some (.native op ops) ∧
      op.full = some f ∧ (f.info.shape = .call ∨ f.info.shape = .island)) ∨
    ∃ pad b, c.cleanupAt s.pc = some (some pad, b) ∧ s'.pc = pad := by
  unfold R.answer at h
  cases hi : c.d.insns[s.pc]? with
  | none => simp [hi, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some i =>
    cases i with
    | handler _ _ _ => simp [hi, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
    | native op ops =>
      cases hf : op.full with
      | none => simp [hi, hf, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
      | some f =>
        simp only [hi, hf] at h
        cases hsh : f.info.shape <;> (try rw [hsh] at h)
        all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
        case call =>
          split at h
          all_goals try contradiction
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          split at h
          all_goals
            obtain ⟨st, -, h⟩ := DecodeLink.ebind_ok h
            try simp only at h
            split at h
            · right
              rcases unwindAt_out h with ⟨pad, b, hcl, s2, hs2, hpad⟩ | ⟨_, hd⟩
              · cases hs2
                exact ⟨pad, b, hcl, hpad⟩
              · cases hd
            · left
              repeat (obtain ⟨_, -, h⟩ := DecodeLink.ebind_ok h)
              simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
              subst h
              first | exact ⟨rfl, op, _, f, rfl, hf, .inl hsh⟩ | exact ⟨rfl, op, _, f, hi, hf, .inl hsh⟩
        case island =>
          try split at h
          all_goals try contradiction
          all_goals try (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)
          obtain ⟨st, -, h⟩ := DecodeLink.ebind_ok h
          try simp only at h
          split at h
          · right
            rcases unwindAt_out h with ⟨pad, b, hcl, s2, hs2, hpad⟩ | ⟨_, hd⟩
            · cases hs2
              exact ⟨pad, b, hcl, hpad⟩
            · cases hd
          · left
            simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
            subst h
            exact ⟨rfl, op, _, f, (by first | exact hi | rfl), hf, .inr hsh⟩

/-- **`rnext_succ`**: an `RNext` from `s` goes to a successor of its instruction. -/
theorem rnext_succ {c : R.Code} {s s' : R.RState} (h : Ryo.Proofs.DecodeSound.RNext c s s') :
    ∃ i, c.d.insns[s.pc]? = some i ∧ Succ c s.pc i s'.pc := by
  cases h with
  | step hs =>
    obtain ⟨i, hi, h1, -⟩ := step_out hs
    exact ⟨i, hi, h1 _ rfl⟩
  | answer hs ha =>
    obtain ⟨i, hi, -, h2⟩ := step_out hs
    have hpc := h2 _ _ rfl
    rcases answer_succ ha with ⟨hp1, op, ops, f, hi', hf, hsh⟩ | ⟨pad, b, hcl, hp⟩
    · rw [hpc] at hi' hp1
      rw [hi] at hi'
      cases hi'
      refine ⟨_, hi, .inl ⟨hp1, ?_⟩⟩
      rcases hsh with e | e <;> simp only [insnFalls, DeadStore.reduced_shape hf, e] <;> decide
    · rw [hpc] at hcl
      exact ⟨i, hi, .inr (.inr ⟨pad, b, hcl, hp⟩)⟩

end Ryo.Proofs.RSucc
