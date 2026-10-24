/-
Ryo.Vm.OpSem.Lemmas — `opSem` touches the frame only through its footprint (reduced.md
Part D).

- `opSem_frame_writes` (proved): a successful `opSem` changes no private frame byte outside
  the ranges of the footprint's writes.
- `opSem_reads_footprint` (proved): `opSem`'s result depends on the private frame bytes only
  through the footprint's read ranges: two states that agree on those bytes (and on memory,
  escapes, exposure and the exception) give the same outcome, the same control and memory,
  and frames that are equal wherever either was written.

Both hold for every opcode at once, because `opSem` reads the frame only in `readAll` (the
footprint's reads), gives the kind's semantics the state with its private bytes erased, and
writes only in `commit`, at the footprint's ranges. What is left to the tests is that each
kind's semantics writes *every* footprint write (exactness), which `RyoTest/OpSem.lean`
checks on random operands.
-/
import Ryo.Vm.OpSem.Sem

namespace Ryo.Vm.OpSem

open Ryo.Spec Ryo.Vm

theorem writeFrame_frame {st st' : State} {off : Int} {bs : List AbstractByte} {o : Int}
    (h : st.writeFrame off bs = .ok st') (ho : inRange o (off, bs.length) = false) :
    st'.frame o = st.frame o := by
  unfold State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok mem =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    simp only [inRange, decide_eq_false_iff_not] at ho
    simp [State.privateIn, ho]

theorem commitOne_frame {fp : Footprint} {val : String → Option Val} {o : Int}
    {st st' : State} {w : String × List AbstractByte} (h : commitOne fp val st w = .ok st')
    (hr : ∀ r ∈ fp.writeRanges val, inRange o r = false) : st'.frame o = st.frame o := by
  unfold commitOne at h
  cases ha : fp.writes.find? (·.opnd == w.1) with
  | none => simp [ha, illFormed] at h
  | some a =>
    cases hr' : a.range val with
    | none => simp [ha, hr', illFormed] at h
    | some r =>
      obtain ⟨off, n⟩ := r
      simp only [ha, hr'] at h
      by_cases hn : w.2.length = n
      · simp only [hn, ↓reduceIte] at h
        apply writeFrame_frame h
        apply hr
        simp only [Footprint.writeRanges, List.mem_filterMap]
        exact ⟨a, List.mem_of_find?_eq_some ha, by rw [hr', hn]⟩
      · simp [hn, illFormed] at h

/-- `commit` keeps every private byte outside the footprint's write ranges. -/
theorem commit_frame {fp : Footprint} {val : String → Option Val} {o : Int}
    (hr : ∀ r ∈ fp.writeRanges val, inRange o r = false) :
    ∀ (ws : List (String × List AbstractByte)) (st st' : State),
      commit fp val st ws = .ok st' → st'.frame o = st.frame o := by
  intro ws
  induction ws with
  | nil =>
    intro st st' h
    simp [commit, List.foldlM, pure, Except.pure] at h
    subst h; rfl
  | cons w ws ih =>
    intro st st' h
    simp only [commit, List.foldlM_cons] at h
    cases hstep : commitOne fp val st w with
    | error e => simp [hstep, bind, Except.bind] at h
    | ok st1 =>
      simp only [hstep, bind, Except.bind] at h
      rw [ih st1 st' h, commitOne_frame hstep hr]

theorem prepare_ok {op : Full.Opcode} {ops : Operands} {h : Handlers.HandlerInfo}
    {fp : Footprint} {val : String → Option Val} (hp : prepare op ops = .ok (h, fp, val)) :
    footprint op = some fp ∧ val = opndVal op.info ops := by
  unfold prepare at hp
  cases hh : op.handler? with
  | none => simp [hh] at hp
  | some hi =>
    cases hf : footprint op with
    | none => simp [hh, hf] at hp
    | some fp' =>
      simp only [hh, hf] at hp
      split at hp
      · cases hp
      split at hp
      · cases hp
      simp only [pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at hp
      obtain ⟨-, rfl, rfl⟩ := hp
      exact ⟨rfl, rfl⟩

/-- `opSem` writes the private frame bytes only inside its footprint's write ranges. -/
theorem opSem_frame_writes {op : Full.Opcode} {ops : Operands} {st st' : State} {ch : Choice}
    {c : Control} {fp : Footprint} (hfp : footprint op = some fp)
    (h : opSem op ops st ch = .ok (c, st')) (o : Int)
    (ho : ∀ r ∈ fp.writeRanges (opndVal op.info ops), inRange o r = false) :
    st'.frame o = st.frame o := by
  unfold opSem at h
  cases hp : prepare op ops with
  | error e => simp [hp, bind, Except.bind] at h
  | ok x =>
    obtain ⟨hi, fp', val⟩ := x
    obtain ⟨hfp', rfl⟩ := prepare_ok hp
    rw [hfp] at hfp'
    cases hfp'
    simp only [hp, bind, Except.bind] at h
    cases hra : readAll fp (opndVal op.info ops) st with
    | error e => simp [hra] at h
    | ok reads =>
      simp only [hra] at h
      cases hk : kindSem hi.kind hi.params (mkEnv reads (opndVal op.info ops) st ch) with
      | error e => simp [hk] at h
      | ok o' =>
        simp only [hk] at h
        cases hc : commit fp (opndVal op.info ops) { st with mem := o'.mem } o'.writes with
        | error e => simp [hc] at h
        | ok st1 =>
          simp only [hc, pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h
          obtain ⟨-, rfl⟩ := h
          have h2 := commit_frame ho _ _ st1 hc
          exact h2

/-! ### Reads -/

/-- Two states that differ at most in their private frame bytes. -/
def State.SameButFrame (s1 s2 : State) : Prop :=
  s1.escaped = s2.escaped ∧ s1.mem = s2.mem ∧ s1.exposed = s2.exposed ∧
    s1.exception = s2.exception

/-- Two outcomes that both fail the same way, or both succeed with related values. -/
def ResultRel {α β : Type} (P : α → β → Prop) : M α → M β → Prop
  | .ok a, .ok b => P a b
  | .error e1, .error e2 => e1 = e2
  | _, _ => False

theorem mapM_congr {α β : Type} {f g : α → M β} :
    ∀ (l : List α), (∀ x ∈ l, f x = g x) → l.mapM f = l.mapM g := by
  intro l
  induction l with
  | nil => intro; rfl
  | cons x xs ih =>
    intro h
    simp only [List.mapM_cons]
    rw [h x (List.mem_cons_self ..), ih (fun y hy => h y (List.mem_cons_of_mem _ hy))]

theorem byteAt_congr {s1 s2 : State} {o : Int} (hs : s1.SameButFrame s2)
    (hf : s1.frame o = s2.frame o) : s1.byteAt o = s2.byteAt o := by
  obtain ⟨he, hm, -, -⟩ := hs
  simp only [State.byteAt, State.escapedAt, he, hm, hf]

theorem readFrame_congr {s1 s2 : State} {off : Int} {n : Nat} (hs : s1.SameButFrame s2)
    (hf : ∀ o, inRange o (off, n) = true → s1.frame o = s2.frame o) :
    s1.readFrame off n = s2.readFrame off n := by
  unfold State.readFrame
  apply mapM_congr
  intro i hi
  apply byteAt_congr hs
  apply hf
  simp only [List.mem_range] at hi
  simp only [inRange, decide_eq_true_eq]
  omega

theorem readAll_congr {fp : Footprint} {val : String → Option Val} {s1 s2 : State}
    (hs : s1.SameButFrame s2)
    (hf : ∀ o, (∃ r ∈ fp.readRanges val, inRange o r = true) → s1.frame o = s2.frame o) :
    readAll fp val s1 = readAll fp val s2 := by
  unfold readAll
  apply mapM_congr
  intro a ha
  cases hr : a.range val with
  | none => rfl
  | some r =>
    obtain ⟨off, n⟩ := r
    simp only
    rw [readFrame_congr hs (fun o ho => hf o ⟨(off, n), ?_, ho⟩)]
    simp only [Footprint.readRanges, List.mem_filterMap]
    exact ⟨a, ha, hr⟩

/-- How the frames of two runs relate: equal, or both unchanged from where they started. -/
def FrameRel (f1 f2 : Int → AbstractByte) (s1 s2 : State) : Prop :=
  s1.SameButFrame s2 ∧ ∀ o, s1.frame o = s2.frame o ∨ (s1.frame o = f1 o ∧ s2.frame o = f2 o)

theorem writeFrame_rel {f1 f2 : Int → AbstractByte} {s1 s2 : State} {off : Int}
    {bs : List AbstractByte} (hr : FrameRel f1 f2 s1 s2) :
    ResultRel (FrameRel f1 f2) (s1.writeFrame off bs) (s2.writeFrame off bs) := by
  obtain ⟨⟨he, hm, hx, hc⟩, hfr⟩ := hr
  have hesc : s1.writeEscaped off bs = s2.writeEscaped off bs := by
    simp only [State.writeEscaped, State.escapedAt, he, hm]
  unfold State.writeFrame
  rw [hesc]
  cases s2.writeEscaped off bs with
  | error e => simp [bind, Except.bind, ResultRel]
  | ok mem =>
    simp only [bind, Except.bind, pure, Except.pure, ResultRel]
    refine ⟨⟨he, rfl, hx, hc⟩, fun o => ?_⟩
    simp only
    have hp : s1.privateIn off bs.length o = s2.privateIn off bs.length o := by
      simp only [State.privateIn, State.escapedAt, he]
    rw [hp]
    split
    · exact Or.inl rfl
    · exact hfr o

theorem commitOne_rel {fp : Footprint} {val : String → Option Val} {f1 f2 : Int → AbstractByte}
    {s1 s2 : State} {w : String × List AbstractByte} (hr : FrameRel f1 f2 s1 s2) :
    ResultRel (FrameRel f1 f2) (commitOne fp val s1 w) (commitOne fp val s2 w) := by
  unfold commitOne
  cases ha : fp.writes.find? (·.opnd == w.1) with
  | none => rfl
  | some a =>
    cases hra : a.range val with
    | none => simp only [hra]; rfl
    | some r =>
      obtain ⟨off, n⟩ := r
      simp only [hra]
      split
      · exact writeFrame_rel hr
      · rfl

theorem commit_rel {fp : Footprint} {val : String → Option Val} {f1 f2 : Int → AbstractByte} :
    ∀ (ws : List (String × List AbstractByte)) (s1 s2 : State), FrameRel f1 f2 s1 s2 →
      ResultRel (FrameRel f1 f2) (commit fp val s1 ws) (commit fp val s2 ws) := by
  intro ws
  induction ws with
  | nil => intro s1 s2 hr; simpa [commit, List.foldlM, pure, Except.pure, ResultRel] using hr
  | cons w ws ih =>
    intro s1 s2 hr
    simp only [commit, List.foldlM_cons]
    have h1 := commitOne_rel (fp := fp) (val := val) (w := w) hr
    revert h1
    cases commitOne fp val s1 w <;> cases commitOne fp val s2 w <;>
      simp only [ResultRel, bind, Except.bind, imp_self, false_implies]
    all_goals (intro h; first | exact ih _ _ h | (subst h; rfl))

/-- `opSem` reads the private frame bytes only inside its footprint's read ranges: two states
that agree on those bytes and on everything but the private frame give the same outcome, the
same control effect and memory, and frames that are equal wherever they changed. -/
theorem opSem_reads_footprint {op : Full.Opcode} {ops : Operands} {st1 st2 : State}
    {ch : Choice} {fp : Footprint} (hfp : footprint op = some fp) (hs : st1.SameButFrame st2)
    (hf : ∀ o, (∃ r ∈ fp.readRanges (opndVal op.info ops), inRange o r = true) →
      st1.frame o = st2.frame o) :
    ResultRel (fun (r1 r2 : Control × State) => r1.1 = r2.1 ∧ FrameRel st1.frame st2.frame r1.2 r2.2)
      (opSem op ops st1 ch) (opSem op ops st2 ch) := by
  unfold opSem
  cases hp : prepare op ops with
  | error e => simp [bind, Except.bind, ResultRel]
  | ok x =>
    obtain ⟨hi, fp', val⟩ := x
    obtain ⟨hfp', rfl⟩ := prepare_ok hp
    rw [hfp] at hfp'
    cases hfp'
    simp only [bind, Except.bind]
    rw [readAll_congr hs hf]
    cases readAll fp (opndVal op.info ops) st2 with
    | error e => simp [ResultRel]
    | ok reads =>
      simp only
      have henv : mkEnv reads (opndVal op.info ops) st1 ch = mkEnv reads (opndVal op.info ops) st2 ch := by
        obtain ⟨he, hm, hx, hc⟩ := hs
        cases st1; cases st2
        simp_all [mkEnv]
      rw [henv]
      cases kindSem hi.kind hi.params (mkEnv reads (opndVal op.info ops) st2 ch) with
      | error e => simp [ResultRel]
      | ok o' =>
        simp only
        have h0 : FrameRel st1.frame st2.frame { st1 with mem := o'.mem } { st2 with mem := o'.mem } := by
          obtain ⟨he, -, hx, hc⟩ := hs
          exact ⟨⟨he, rfl, hx, hc⟩, fun o => Or.inr ⟨rfl, rfl⟩⟩
        have h1 := commit_rel o'.writes _ _ h0 (fp := fp) (val := opndVal op.info ops)
        revert h1
        cases commit fp (opndVal op.info ops) { st1 with mem := o'.mem } o'.writes <;>
          cases commit fp (opndVal op.info ops) { st2 with mem := o'.mem } o'.writes <;>
          simp [ResultRel, pure, Except.pure]

end Ryo.Vm.OpSem
