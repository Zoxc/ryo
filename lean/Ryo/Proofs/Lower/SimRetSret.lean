/-
Ryo.Proofs.Lower.SimRetSret — `return` through the caller's sret pointer simulated for
`LowerRetSret` (`Check/Lower/RetSret.lean`, M5b).

**The relation** (`RetSret`): with `pb` the sret pointer's bytes (`gpr0`'s 8 bytes at entry,
`regBytes args sretReg`), `rax`'s 8 bytes are `pb`, and the memory at the end is the memory
before the return with `bs1` stored where `pb` points, `bs1` refined by bytes `bs0` that decode
to the returned value at `_0`'s type. This is the ABI's meaning of an sret return: the caller
reads the value from its destination (a later call rule, M5c).

**The caller's side** (`SretOk`): `pb` decodes to a pointer into a live, mutable allocation of
R's memory containing `_0`'s size from it (`SretDest`), and `pb` is 8 bytes.

**What the callee keeps** (`steps_keep`): from the prologue on, every step of a function
without scopes, outside PE, all of whose instructions pass `pinInsnOk`, keeps the argument
registers, nothing escaped, the sret slot's bytes (`PinAt`: still `pb`) and every
allocation's address, liveness, size and mutability (`KeepM`), so `SretOk` at entry still holds
at the return (`SretOk.keep`). `step_keep` is the step lemma: `jmp` changes no byte, an `arg`
misses the slot or rewrites the same bytes (`arg_pin`), an operation writes only its
footprint's ranges (`opSem_frame_writes`, `stepView_keep`); returns, tail calls, calls and
islands never give a `step`. `KeepM` for an operation: `opSem_keepM` (stores keep everything
but the data).

**The return** (`sim_retSret`): `return_inv`, `typedLoad_inv` and `readLocal_inj` as
`sim_retX`'s (L0 loads `_0`'s bytes `bs0`, R's slot holds `bs1` refining them); the
`store.copy` (`opSem_storeCopy_fwd`: the pointer read from the sret slot, `sret_store_ok`),
then the `ret` of the slot (`ret_fold`, `stepBody_ret`: `rax` holds the slot's bytes).
`sim_retSret_from` runs it from the prologue's end (`steps_keep`), the shape the function
theorem uses.
-/
import Ryo.Proofs.Lower.SimRetX
import Ryo.Proofs.Lower.SimPrologI
import Ryo.Proofs.Lower.CopyOps
import Ryo.Proofs.OpFacts
import Ryo.Proofs.Inline.Rel
import Ryo.Vm.OpSem.Lemmas
import Ryo.Check.Lower.RetSret

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

theorem ebind_ok' {ε α β : Type} {x : Except ε α} {f : α → Except ε β} {b : β}
    (h : (x >>= f) = .ok b) : ∃ a, x = .ok a ∧ f a = .ok b := by
  cases x with
  | error e => cases h
  | ok a => exact ⟨a, rfl, h⟩

/-! ### Allocations kept -/

/-- Every allocation keeps its address, liveness, size and mutability (`AllocsKept` with
mutability). -/
def KeepM (m m' : Memory) : Prop :=
  m'.allocs.size = m.allocs.size ∧ ∀ id a', m'.get? id = some a' →
    ∃ a, m.get? id = some a ∧ a'.addr = a.addr ∧ a'.live = a.live ∧
      a'.data.size = a.data.size ∧ a'.mutable = a.mutable

theorem KeepM.refl (m : Memory) : KeepM m m := ⟨rfl, fun _ a h => ⟨a, h, rfl, rfl, rfl, rfl⟩⟩

theorem KeepM.trans {m1 m2 m3 : Memory} (h1 : KeepM m1 m2) (h2 : KeepM m2 m3) : KeepM m1 m3 := by
  refine ⟨h2.1.trans h1.1, fun id a3 h => ?_⟩
  obtain ⟨a2, h2', e1, e2, e3, e4⟩ := h2.2 id a3 h
  obtain ⟨a1, h1', f1, f2, f3, f4⟩ := h1.2 id a2 h2'
  exact ⟨a1, h1', e1.trans f1, e2.trans f2, e3.trans f3, e4.trans f4⟩

theorem KeepM.of_escFrom {st : OpSem.State} {off : Int} {l : List (AbstractByte × Nat)}
    {m m' : Memory} (h : Ryo.Proofs.Inline.EscFrom st off l m m') : KeepM m m' :=
  ⟨h.1, fun id a' ha => by
    obtain ⟨a, ha', he, hsz, -⟩ := h.2 id a' ha
    have e1 := congrArg Allocation.addr he
    have e2 := congrArg Allocation.live he
    have e3 := congrArg Allocation.mutable he
    exact ⟨a, ha', e1, e2, hsz, e3⟩⟩

/-- A store changes only the stored-to allocation's data. -/
theorem store_keepM {m m' : Memory} {p : ThinPointer} {bytes : List AbstractByte} {al : Align}
    (h : m.store p bytes al = .ok m') : KeepM m m' := by
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h with
    ⟨-, -, rfl⟩ | ⟨id, hid, -, -, -, -, -, -, -, rfl⟩
  · exact KeepM.refl _
  · refine ⟨by simp, fun j a' ha' => ?_⟩
    by_cases hj : id = j
    · subst hj
      simp only [Memory.get?, Array.getElem?_set_self, Option.some.injEq] at ha'
      subst ha'
      refine ⟨m.allocs[id], get?_of_lt hid, rfl, rfl, ?_, rfl⟩
      exact Ryo.Spec.Theorems.foldl_set_size _ _ _ _
    · refine ⟨a', ?_, rfl, rfl, rfl, rfl⟩
      simpa [Memory.get?, Array.getElem?_set, hj] using ha'

theorem stStore_keepM {st : OpSem.State} {m m' : Memory} {p : ThinPointer}
    {bs : List AbstractByte} {al : Align} (h : st.store m p bs al = .ok m') : KeepM m m' := by
  unfold OpSem.State.store liftOutcome at h
  split at h
  · cases h
    exact store_keepM (by assumption)
  all_goals cases h

/-- As `kindSem_allocsKept`. -/
theorem kindSem_keepM {k : Handlers.HandlerKind} {ps : List String} {e : OpSem.Env}
    {o : OpSem.Out} (h : kindSem k ps e = .ok o) : KeepM e.st.mem o.mem := by
  cases k <;> simp only [kindSem, bind, Except.bind, pure, Except.pure] at h <;>
    repeat'
      first
        | (simp only [reduceCtorEq] at h; done)
        | (simp [illFormed, ub] at h; done)
        | split at h
  all_goals
    injection h with h
    subst h
    first | exact KeepM.refl _ | exact stStore_keepM (by assumption)

theorem writeFrame_keepM {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') : KeepM st.mem st'.mem := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    exact KeepM.of_escFrom (Ryo.Proofs.Inline.writeEscaped_spec hm)

theorem commit_keepM {fp : Footprint} {val : String → Option Val} :
    ∀ (ws : List (String × List AbstractByte)) {st st' : OpSem.State},
      commit fp val st ws = .ok st' → KeepM st.mem st'.mem
  | [], st, st', h => by cases h; exact KeepM.refl _
  | w :: ws, st, st', h => by
    simp only [commit, List.foldlM_cons, bind, Except.bind] at h
    cases h1 : commitOne fp val st w with
    | error e => simp [h1] at h
    | ok st1 =>
      simp only [h1] at h
      have k1 : KeepM st.mem st1.mem := by
        unfold commitOne at h1
        split at h1
        · simp [illFormed] at h1
        split at h1
        · simp [illFormed] at h1
        split at h1
        · exact writeFrame_keepM h1
        · simp [illFormed] at h1
      exact k1.trans (commit_keepM ws h)

/-- As `opSem_allocsKept`. -/
theorem opSem_keepM {op : Full.Opcode} {ops : Operands} {st st' : OpSem.State}
    {ch : OpSem.Choice} {ctl : OpSem.Control} (h : opSem op ops st ch = .ok (ctl, st')) :
    KeepM st.mem st'.mem := by
  unfold opSem at h
  simp only [bind, Except.bind] at h
  cases hp : prepare op ops with
  | error e => simp [hp] at h
  | ok r =>
    obtain ⟨hi, fp, val⟩ := r
    simp only [hp] at h
    cases hr : readAll fp val st with
    | error e => simp [hr] at h
    | ok reads =>
      simp only [hr] at h
      cases hk : kindSem hi.kind hi.params (mkEnv reads val st ch) with
      | error e => simp [hk] at h
      | ok o =>
        simp only [hk] at h
        cases hc : commit fp val { st with mem := o.mem } o.writes with
        | error e => simp [hc] at h
        | ok st1 =>
          simp only [hc, pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h
          obtain ⟨-, rfl⟩ := h
          have k1 : KeepM st.mem o.mem := kindSem_keepM hk
          exact k1.trans (commit_keepM _ hc)

/-! ### The sret slot kept -/

/-- The sret slot `so` holds the sret pointer's bytes, `gpr0`'s 8 (`regBytes args sretReg`). -/
def PinAt (st : OpSem.State) (so : Int) (args : R.Regs) : Prop :=
  ∀ j : Nat, j < 8 → st.frame (so + j) = (regBytes args sretReg).getD j .uninit

/-- The prologue's `arg` of the sret pointer gives `PinAt` (`match_entryX`'s last conjunct). -/
theorem PinAt.of_bytes {st : OpSem.State} {so : Int} {args : R.Regs}
    (hl : (regBytes args sretReg).length = 8)
    (h : ∀ (j : Nat) (hj : j < (regBytes args sretReg).length),
      st.frame (so + j) = (regBytes args sretReg)[j]) : PinAt st so args := by
  intro j hj
  have hj' : j < (regBytes args sretReg).length := by omega
  rw [h j hj']
  simp [List.getD, List.getElem?_eq_getElem hj']

theorem PinAt.bytes {st : OpSem.State} {so : Int} {args : R.Regs} (h : PinAt st so args)
    (hl : (regBytes args sretReg).length = 8) :
    ∀ (j : Nat) (hj : j < (regBytes args sretReg).length),
      st.frame (so + j) = (regBytes args sretReg)[j] := by
  intro j hj
  rw [h j (by omega)]
  simp [List.getD, List.getElem?_eq_getElem hj]

/-- An `arg` that misses the slot or rewrites it with `gpr0`'s bytes keeps `PinAt`. -/
theorem arg_pin {st st' : OpSem.State} {args : R.Regs} {so d : Int} {a : Asm.ArgReg}
    (hn : ∀ o, st.escapedAt o = none) (hpin : PinAt st so args)
    (hw : st.writeFrame d ((args.get (.ofArgReg a)).take a.size) = .ok st')
    (hd : (d + a.size ≤ so ∨ so + 8 ≤ d) ∨ (d = so ∧ a = sretReg)) : PinAt st' so args := by
  obtain ⟨-, -, -, hfr⟩ := writeFrame_noesc' hw hn
  intro j hj
  rw [hfr]
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

/-- `unwindAt`'s step: to the landing pad, the exception register set. -/
theorem unwindAt_keep {c : R.Code} {s s' : R.RState} {exc : ThinPointer}
    (h : R.unwindAt c s exc = .ok (.step s')) :
    s'.args = s.args ∧ s'.fp = s.fp ∧ s'.st = { s.st with exception := exc } := by
  unfold R.unwindAt at h
  cases hcl : c.cleanupAt s.pc with
  | none => rw [hcl] at h; simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw] at h
  | some cb =>
    obtain ⟨opad, b⟩ := cb
    cases opad with
    | none =>
      rw [hcl] at h
      simp [pure, Except.pure] at h
    | some pad =>
      rw [hcl] at h
      simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
      subst h
      exact ⟨rfl, rfl, rfl⟩

/-- A successful `stepView` outside PE: its operation's `opSem`, the state its result, or a
`resume`'s unwinding to a landing pad (only the exception register changes); `args` and `fp`
kept. -/
theorem stepView_opSem {c : R.Code} {s s' : R.RState} {i : R.Insn} {ch : OpSem.Choice}
    (hpe : c.mode.pe = false) (h : R.stepView c s i ch = .ok (.step s')) :
    (∃ v ctl st, R.view c.mode c.ρ i = some v ∧ opSem v.op v.ops s.st ch = .ok (ctl, st) ∧
      s'.args = s.args ∧ s'.fp = s.fp ∧ s'.st = st) ∨
    (∃ exc, s'.args = s.args ∧ s'.fp = s.fp ∧ s'.st = { s.st with exception := exc }) := by
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
                  exact .inr ⟨p, unwindAt_keep h⟩
            all_goals simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
      · have hr' : (v.op == .resume) = false := by
          revert hr; cases (v.op == .resume) <;> simp
        by_cases hu : (v.op == .unreachable) = true
        · simp [hctl, hr', hu, bind, Except.bind, throw, throwThe, MonadExceptOf.throw] at h
        · have hu' : (v.op == .unreachable) = false := by
            revert hu; cases (v.op == .unreachable) <;> simp
          simp only [hctl, hr', hu', Bool.false_eq_true, ↓reduceIte, bind, Except.bind] at h
          generalize ho : opSem v.op v.ops s.st ch = oo at h
          cases oo with
          | error e => simp at h
          | ok r =>
            obtain ⟨ctl, st⟩ := r
            left
            refine ⟨v, ctl, st, by first | exact hview | rfl, ho, ?_⟩
            cases i with
            | handler hh args tt =>
              try simp only at h
              generalize hcl : R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st = oc
                at h
              cases oc with
              | error e => simp at h
              | ok st2 =>
                have e2 : st2 = st := by
                  rw [hpe] at hcl
                  simp [R.clearHome, pure, Except.pure] at hcl
                  first | exact hcl.symm | exact hcl
                subst e2
                try simp only at h
                generalize hp : t.succ s.pc ctl = op' at h
                cases op' with
                | none => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
                | some pc' =>
                  simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
                  subst h
                  exact ⟨rfl, rfl, rfl⟩
            | native op ops =>
              try simp only [pure, Except.pure] at h
              generalize hp : t.succ s.pc ctl = op' at h
              cases op' with
              | none => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
              | some pc' =>
                simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
                subst h
                exact ⟨rfl, rfl, rfl⟩

/-- `opSem` fails without a footprint. -/
theorem opSem_fp_none {op : Full.Opcode} {ops : Operands} {st : OpSem.State} {ch : OpSem.Choice}
    {r : OpSem.Control × OpSem.State} (hfp : footprint op = none)
    (h : opSem op ops st ch = .ok r) : False := by
  unfold opSem at h
  cases hp : prepare op ops with
  | error e => simp [hp, bind, Except.bind] at h
  | ok x =>
    obtain ⟨hi, fp, val⟩ := x
    have := (prepare_ok hp).1
    rw [hfp] at this
    cases this

/-- `stepView`'s step keeps the arguments, the escapes, the allocations and the sret slot. -/
theorem stepView_keep {c : R.Code} {s s' : R.RState} {i : R.Insn} {ch : OpSem.Choice}
    {so : Int} (hpe : c.mode.pe = false) (hok : viewPinOk c.mode c.ρ so i = true)
    (hpin : PinAt s.st so s.args)
    (h : R.stepView c s i ch = .ok (.step s')) :
    s'.args = s.args ∧ s'.st.escaped = s.st.escaped ∧ KeepM s.st.mem s'.st.mem ∧
      PinAt s'.st so s'.args := by
  rcases stepView_opSem hpe h with ⟨v, ctl, st, hv, hop, hargs, -, hst⟩ | ⟨exc, hargs, -, hst⟩
  rotate_left
  · rw [hargs, hst]
    exact ⟨rfl, rfl, KeepM.refl _, hpin⟩
  rw [hargs, hst]
  unfold viewPinOk at hok
  cases hfp : footprint v.op with
  | none => exact (opSem_fp_none hfp hop).elim
  | some fp =>
    simp only [hv, hfp, List.all_eq_true, decide_eq_true_eq] at hok
    refine ⟨rfl, (Ryo.Proofs.OpFacts.opSem_out hop).2.1, opSem_keepM hop, ?_⟩
    intro j hj
    rw [opSem_frame_writes hfp hop (so + j) ?_]
    · exact hpin j hj
    · intro r hr
      have := hok r hr
      simp only [inRange, decide_eq_false_iff_not]
      omega

set_option maxRecDepth 8000 in
/-- One step of a scope-free instruction passing `pinInsnOk` (see the module comment). -/
theorem step_keep {c : R.Code} {s s' : R.RState} {ch : OpSem.Choice} {i : R.Insn} {so : Int}
    (hi : c.d.insns[s.pc]? = some i) (hsc : c.scopesAt s.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hok : pinInsnOk c.mode c.ρ so i = true)
    (hn : ∀ o, s.st.escapedAt o = none) (hpin : PinAt s.st so s.args)
    (h : R.step c s ch = .ok (.step s')) :
    s'.args = s.args ∧ s'.st.escaped = s.st.escaped ∧ KeepM s.st.mem s'.st.mem ∧
      PinAt s'.st so s'.args := by
  rw [step_eq_stepBody_nil hi hsc] at h
  cases i with
  | handler hh args t =>
    exact stepView_keep hpe hok hpin h
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
        exact ⟨rfl, rfl, KeepM.refl _, hpin⟩
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
        obtain ⟨hm, -, he, -⟩ := writeFrame_noesc' hw hn
        refine ⟨rfl, he, by show KeepM s.st.mem st.mem; rw [hm]; exact KeepM.refl _, ?_⟩
        exact arg_pin hn hpin hw (argPinOk_spec (by assumption) hap)
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
      -- the shapes `opSem` gives the meaning of: `stepView`
      all_goals
        have hv : R.stepView c s (.native op ops) ch = .ok (.step s') := h
        have hvp : viewPinOk c.mode c.ρ so (.native op ops) = true := hok'
        exact stepView_keep hpe hvp hpin hv

/-- Steps of such a function keep what `step_keep` keeps (see the module comment). -/
theorem steps_keep {c : R.Code} {ch : OpSem.Choice} {so : Int}
    (hsc : ∀ k, c.scopesAt k = []) (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    (hok : ∀ (k : Nat) i, c.d.insns[k]? = some i → pinInsnOk c.mode c.ρ so i = true) :
    ∀ {s s' : R.RState}, StepsTo c ch s s' → (∀ o, s.st.escapedAt o = none) →
      PinAt s.st so s.args →
      s'.args = s.args ∧ (∀ o, s'.st.escapedAt o = none) ∧ KeepM s.st.mem s'.st.mem ∧
        PinAt s'.st so s'.args := by
  intro s s' hst
  induction hst with
  | refl s => intro hn hp; exact ⟨rfl, hn, KeepM.refl _, hp⟩
  | @cons s0 s1 s2 hstep hrest ih =>
    intro hn hp
    cases hi : c.d.insns[s0.pc]? with
    | none => unfold R.step at hstep; rw [hi] at hstep; cases hstep
    | some i =>
      obtain ⟨ha, he, hk, hp1⟩ :=
        step_keep hi (hsc _) hpe (hpl _ _ hi) (hok _ _ hi) hn hp hstep
      have hn1 : ∀ o, s1.st.escapedAt o = none := fun o => by
        rw [escapedAt_of_escaped he]; exact hn o
      obtain ⟨ha2, hn2, hk2, hp2⟩ := ih hn1 hp1
      exact ⟨ha2.trans ha, hn2, hk.trans hk2, hp2⟩

/-! ### The caller's destination -/

/-- `pb` points to `n` bytes of a live, mutable allocation (see the module comment). -/
def SretDest (m : Memory) (pb : List AbstractByte) (n : Nat) : Prop :=
  ∃ q id y, decodePtr pb = some q ∧ q.prov = some id ∧ m.get? id = some y ∧ y.live = true ∧
    y.mutable = true ∧ y.addr ≤ q.addr ∧ q.addr + n ≤ y.addr + y.size

/-- The caller's side of an sret return: `pb` points to `_0`'s size of writable memory. -/
def SretOk (Γ : TermCtx) (m : Memory) (pb : List AbstractByte) : Prop :=
  ∃ ty n, Γ.body.locals[0]? = some ty ∧ ty.size? = some n ∧ SretDest m pb n

theorem SretDest.keep {m m' : Memory} {pb : List AbstractByte} {n : Nat} (h : SretDest m pb n)
    (hk : KeepM m m') : SretDest m' pb n := by
  obtain ⟨q, id, y, hq, hp, hy, hl, hmu, h1, h2⟩ := h
  have hy' : m.allocs[id]? = some y := hy
  have hid : id < m.allocs.size := (Array.getElem?_eq_some_iff.mp hy').1
  have hid' : id < m'.allocs.size := by rw [hk.1]; exact hid
  obtain ⟨a, ha, e1, e2, e3, e4⟩ := hk.2 id m'.allocs[id] (get?_of_lt hid')
  rw [hy] at ha
  have hya := Option.some.inj ha
  rw [← hya] at e1 e2 e3 e4
  refine ⟨q, id, m'.allocs[id], hq, hp, get?_of_lt hid', by rw [e2]; exact hl,
    by rw [e4]; exact hmu, by rw [e1]; exact h1, ?_⟩
  show q.addr + n ≤ m'.allocs[id].addr + m'.allocs[id].data.size
  rw [e1, e3]
  exact h2

theorem SretOk.keep {Γ : TermCtx} {m m' : Memory} {pb : List AbstractByte} (h : SretOk Γ m pb)
    (hk : KeepM m m') : SretOk Γ m' pb := by
  obtain ⟨ty, n, h1, h2, h3⟩ := h
  exact ⟨ty, n, h1, h2, h3.keep hk⟩

theorem store_of_fits {st : OpSem.State} {mem : Memory} {q : ThinPointer}
    {bs : List AbstractByte} {id : AllocId} (hp : q.prov = some id)
    (hf : st.fits q.addr bs.length id = true) :
    st.store mem q bs = liftOutcome (mem.store q bs Align.one) := by
  unfold OpSem.State.store OpSem.State.resolve
  rw [hp]
  dsimp only
  rw [if_pos hf]

theorem mem_store_ok {m : Memory} {q : ThinPointer} {bs : List AbstractByte} {id : AllocId}
    {y : Allocation} (hp : q.prov = some id) (hy : m.get? id = some y) (hl : y.live = true)
    (hmu : y.mutable = true) (h1 : y.addr ≤ q.addr) (h2 : q.addr + bs.length ≤ y.addr + y.size) :
    ∃ m', m.store q bs Align.one = .ok m' := by
  have hal : Align.one.isAligned q.addr = true := by
    simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]
  by_cases hz : bs.length = 0
  · have hbs : bs = [] := List.eq_nil_of_length_eq_zero hz
    subst hbs
    refine ⟨m, ?_⟩
    first
      | (simp [Memory.store, hal, checkPtr_zero', bind, Except.bind, pure, Except.pure]; done)
      | (unfold Memory.store
         simp only [hal, Bool.not_true, Bool.false_eq_true, ite_false, List.length_nil,
           checkPtr_zero']
         rfl)
  · have hy' : m.allocs[id]? = some y := hy
    obtain ⟨hid, hyeq⟩ := Array.getElem?_eq_some_iff.mp hy'
    exact store_ok_exists hid hal hz hp (by rw [hyeq]; exact hl) (by rw [hyeq]; exact h1)
      (by rw [hyeq]; exact h2) (by rw [hyeq]; exact hmu)

/-- The `store.copy` of `bs` through the sret pointer succeeds, as memory's `store`. -/
theorem sret_store_ok {st : OpSem.State} {pb bs : List AbstractByte} (hpl : pb.length = 8)
    (hd : SretDest st.mem pb bs.length) :
    ∃ q mem', decodePtr pb = some q ∧ st.store st.mem (q.wrappingOffset 0) bs = .ok mem' ∧
      st.mem.store q bs Align.one = .ok mem' := by
  obtain ⟨q, id, y, hq, hp, hy, hl, hmu, h1, h2⟩ := hd
  obtain ⟨mem', hm⟩ := mem_store_ok hp hy hl hmu h1 h2
  refine ⟨q, mem', hq, ?_, hm⟩
  rw [wrappingOffset_zero (decodePtr_addr_lt hq hpl),
    store_of_fits (st := st) hp (fits_of hy hl h1 h2), hm]
  all_goals first | rfl | exact liftOutcome_pure _

/-! ### The return -/

/-- The returned value `v` related to the end of an sret return (see the module comment):
`m` the memory before the return, `m'` at its end. -/
def RetSret (Γ : TermCtx) (ι : Inj) (v : Value) (pb : List AbstractByte) (m m' : Memory)
    (regs : R.Regs) : Prop :=
  (regs.get (.gpr 0)).take 8 = pb ∧ ∃ ty bs0 bs1 q, Γ.body.locals[0]? = some ty ∧
    ty.size? = some bs0.length ∧ ty.decode bs0 = some v ∧ BytesInj ι bs0 bs1 ∧
    decodePtr pb = some q ∧ m.store q bs1 Align.one = .ok m'

/-- `return` under `LowerRetSret`: L0 ends the run with `_0`'s value `v`; R's `store.copy` and
`ret` end the function with `RetSret` (see the module comment). -/
theorem sim_retSret {Γ : TermCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {so : Int} {next : Nat} {is : List R.Insn} (hlow : LowerRetSret Γ so .«return» is)
    (hat : TermAt c s1 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live 0 = true)
    (hcont : f.cont = .bottom) (hn : ∀ o, s1.st.escapedAt o = none) (hinc : IncomingOk c)
    (hpin : PinAt s1.st so s1.args) (hpbl : (regBytes s1.args sretReg).length = 8)
    (hdest : SretOk Γ s1.st.mem (regBytes s1.args sretReg))
    (h : runOn (evalTerminator .«return») o s = (.ok (), s')) :
    ∃ v s1m regs incoming, s'.final = some (.returned v) ∧
      R.step c s1 ch = .ok (.step s1m) ∧
      R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) ∧
      RetSret Γ ι v (regBytes s1.args sretReg) s1.st.mem s1m.st.mem regs := by
  cases hlow with
  | @mk i1 i2 ty s0 k hkind hty hsl hsize hst hro hk =>
    obtain ⟨hi1, hs0⟩ := hat.head
    have h2 := hat.code 1 (by simp)
    have hs2 := hat.scopes 1 (by simp)
    simp only [List.getElem_cons_succ, List.getElem_cons_zero] at h2
    -- L0: `_0`'s bytes
    obtain ⟨p, ty', v, g, sx, hp, hty', hload, -, -, hfin⟩ := return_inv hs h
    have hfinal : s'.final = some (.returned v) := by rw [hfin hcont]
    rw [← hbody, hty] at hty'
    obtain rfl := Option.some.inj hty'
    obtain ⟨bs0, hld, hdec⟩ := typedLoad_inv hsize hload
    have hr := hrel.opnd hp hsl hlive
    obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld
    have hlen1 : bs1.length = s0.size := Ryo.Proofs.Inline.readFrame_length hrf
    have hlen0 : bs0.length = s0.size := (BytesInj.length hbi).trans hlen1
    -- the store through the sret pointer
    obtain ⟨ty2, n2, hty2, hn2, hd⟩ := hdest
    rw [hty] at hty2
    have hty2' := Option.some.inj hty2
    rw [← hty2', hsize] at hn2
    have hn2' := Option.some.inj hn2
    have hd' : SretDest s1.st.mem (regBytes s1.args sretReg) bs1.length := by
      rw [hlen1, hn2']; exact hd
    obtain ⟨q, mem', hq, hstore, hmstore⟩ := sret_store_ok hpbl hd'
    obtain ⟨v1, ps, r, hv, hh, ho, hops, hctl, hf1, hf2, hn32⟩ := storeCopyOk_spec hst
    rw [hmode, hρ] at hv
    have hpb := hpin.bytes hpbl
    have hrp : s1.st.readFrame so 8 = .ok (regBytes s1.args sretReg) := by
      have := readFrame_noesc hn hpb
      rw [hpbl] at this
      exact this
    have hfa := offOk_spec hf1
    have hfb := offOk_spec hf2
    have hop := opSem_storeCopy_fwd (ch := ch) hh ho ⟨hfa.1, hfa.2, hfb.1, hfb.2, hn32⟩ hrp hq
      hrf hstore
    have hstep1 := step_of_view (ch := ch) hi1 hs0 hat.pe (hpl _ _ hi1) hv hctl
      (by rw [hops]; exact hop)
    -- the `ret` of the sret slot
    let s1m : R.RState := { s1 with pc := s1.pc + 1, st := { s1.st with mem := mem' } }
    obtain ⟨op, fo, sw, kw, rfl, hf, hsh, hsrc, hkw⟩ := retOps_spec hro
    have hk' : Asm.retParts k true = some (some ⟨false, 8, 0⟩, none) := hk
    have hparts : R.retRegs kw.toNat true = .ok [(⟨false, 8, 0⟩, .gpr 0)] := by
      rw [hkw]; exact retRegs_one hk'
    have hn1 : ∀ o, s1m.st.escapedAt o = none := fun o => hn o
    have hrp2 : s1m.st.readFrame (sw.toInt + ((⟨false, 8, 0⟩ : Asm.RetPart).off : Int))
        (⟨false, 8, 0⟩ : Asm.RetPart).size = .ok (regBytes s1.args sretReg) := by
      have e : sw.toInt + ((⟨false, 8, 0⟩ : Asm.RetPart).off : Int) = so := by
        rw [hsrc]; simp
      rw [e]
      have := readFrame_noesc hn1 (off := so) hpb
      rw [hpbl] at this
      exact this
    obtain ⟨regs, hfold, hregs⟩ := ret_fold (st := s1m.st) (src := sw.toInt)
      (prs := [(⟨false, 8, 0⟩, .gpr 0)]) (by simp) (fun pr hpr => by
        simp only [List.mem_singleton] at hpr
        subst hpr
        exact ⟨_, hrp2⟩)
    obtain ⟨incoming, hinc'⟩ := hinc s1m.st
    have hstep2 : R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) := by
      rw [step_eq_stepBody_nil (s := s1m) h2 hs2]
      exact stepBody_ret hf hsh hparts hfold hinc'
    refine ⟨v, s1m, regs, incoming, hfinal, hstep1, hstep2, ?_, ty, bs0, bs1, q, hty,
      by rw [hsize, hlen0], hdec, hbi, hq, hmstore⟩
    exact hregs _ (List.mem_singleton_self _) _ hrp2

/-- `sim_retSret` from the prologue's end `s0` (see the module comment): `s0`'s facts are the
prologue's (`PinAt.of_bytes` from `match_entryX`'s last conjunct, nothing escaped) and the
caller's (`hpbl`, `hd0`); every step to the return keeps them (`steps_keep`, with `pinCheck`
over the function's instructions). -/
theorem sim_retSret_from {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} {so : Int} {next : Nat} {is : List R.Insn}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpc : pinCheck Γ.mode Γ.ρ so c.d = true)
    {s0 s1 : R.RState} (hst : StepsTo c ch s0 s1) (hn0 : ∀ o, s0.st.escapedAt o = none)
    (hp0 : PinAt s0.st so s0.args) (hpbl : (regBytes s0.args sretReg).length = 8)
    (hd0 : SretOk Γ s0.st.mem (regBytes s0.args sretReg))
    (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hlow : LowerRetSret Γ so .«return» is) (hat : TermAt c s1 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live 0 = true)
    (hcont : f.cont = .bottom)
    (h : runOn (evalTerminator .«return») o s = (.ok (), s')) :
    ∃ v s1m regs incoming, s'.final = some (.returned v) ∧ StepsTo c ch s0 s1m ∧
      R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) ∧
      RetSret Γ ι v (regBytes s0.args sretReg) s1.st.mem s1m.st.mem regs := by
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  have hok : ∀ (k : Nat) i, c.d.insns[k]? = some i → pinInsnOk c.mode c.ρ so i = true :=
    fun k i h => by rw [hmode, hρ]; exact pinCheck_sound hpc k i h
  obtain ⟨ha, hn1, hk, hp1⟩ := steps_keep (scopesAt_nil hfn.noScopes) hpe hpl hok hst hn0 hp0
  rw [← ha] at hpbl hd0
  obtain ⟨v, s1m, regs, incoming, hfinal, hstep1, hstep2, hret⟩ :=
    sim_retSret (ch := ch) hs hbody hmode.symm hρ.symm hpl hlow hat hrel hlive hcont hn1 hinc
      hp1 hpbl (hd0.keep hk) h
  rw [ha] at hret
  exact ⟨v, s1m, regs, incoming, hfinal, hst.trans (.cons hstep1 (.refl _)), hstep2, hret⟩

/-- `fn_soundI` with sret returns resolved (`FnStop`'s `SretAt` by `sim_retSret_from`): the
function theorem from entry for every prologue `prologIVerdict` accepts and every return rule.
Beyond `fn_soundI`'s hypotheses: the prologue's sret slot is the function's (`hpsr`), and, with
an sret slot, the caller's facts (`hsr8`: `gpr0` holds 8 bytes; `hsrd`: they point to writable
memory of `_0`'s size, `SretOk`; M5c). The third outcome: L0 returned `v` from `sa` (after
`m` steps) to `sb`, and R's `ret` ends the function with `RetSret` (`m1` R's memory before the
return's store); the rest are `fn_soundI`'s. -/
theorem fn_soundS {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologICtx} {is : List R.Insn} {inps : List InputI} {lw : List ArgWrite}
    (hpl : LowerPrologI Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ) (hpsr : Γp.sret = Γ.sret)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
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
    (hsr8 : ∀ so, Γ.sret = some so → (regBytes s1.args sretReg).length = 8)
    (hsrd : ∀ so, Γ.sret = some so → SretOk Γ s1.st.mem (regBytes s1.args sretReg))
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧
          RetValX Γ ι v regs) ∨
      (∃ s1m sa sb m v regs incoming m1, StepsTo c ch s1 s1m ∧ L0Steps o m s sa ∧
        runOn (evalTerminator .«return») o sa = (.ok (), sb) ∧ sb.final = some (.returned v) ∧
        R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) ∧
        RetSret Γ ι v (regBytes s1.args sretReg) m1 s1m.st.mem regs) ∨
      FnStop Γ c ch ι o s s' s1 := by
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  obtain ⟨s0, hst0, hm0, hw0, ha0, hn0, hme0⟩ := match_entryI (ch := ch) hpl hslots
    (hpm.trans hmode.symm) (hpρ.trans hρ.symm) hpe hplain hcode hnoesc hblk hbd hstart
    hfn.reach.entry (fused_start hfn hfn.reach.entry hbd hblk) hs hbody hbb hstmt hpu hcont hal
    qs hqs hloc hrel hmem hhid hprov hapart hsl hpb hfresh hdinv
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩ | hstop
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩)
  · rcases hstop with hd | hr | ha | ⟨s1', sa, sb, m, hst, hm, hsr⟩
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inl hd))))
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inr (.inl hr)))))
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inr (.inr (.inl ha))))))
    · obtain ⟨f', rest', live, next, is', so, hs', hb', hso, hlow, hat, hrel', hl0, hc', hret⟩ :=
        hsr
      have hso' : Γp.sret = some so := hpsr.trans hso
      have hwin : (so, sretReg) ∈ sretWrites Γp.toPrologXCtx ++ lw := by
        simp [sretWrites, hso']
      have h8 := hsr8 so hso
      have hpin : PinAt s0.st so s0.args := by
        rw [ha0]
        exact PinAt.of_bytes h8 (fun j hj => hw0 _ hwin j hj)
      have hd0 : SretOk Γ s0.st.mem (regBytes s0.args sretReg) := by
        rw [ha0, hme0]; exact hsrd so hso
      obtain ⟨v, s1m, regs, incoming, hfinal, hst', hstep2, hret'⟩ :=
        sim_retSret_from (ch := ch) hfn hmode hρ hinc (hfn.pin so hso) hst hn0 hpin
          (by rw [ha0]; exact h8) hd0 hs' hb' hlow hat hrel' hl0 hc' hret
      rw [ha0] at hret'
      exact .inr (.inr (.inl ⟨s1m, sa, sb, m, v, regs, incoming, _, hst0.trans hst', hm, hret,
        hfinal, hstep2, hret'⟩))

end Ryo.Proofs.Lower
