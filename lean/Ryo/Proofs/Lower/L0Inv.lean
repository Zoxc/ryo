/-
Ryo.Proofs.Lower.L0Inv — inversions of L0's `step` for the lowering simulation (M5a).

On an active frame `f` without a pending unwind, in a run that has not ended:
- `step_stmt_inv`: at a statement, `step` is the statement's `evalStatement` followed by
  advancing the frame's `stmt`;
- `step_term_inv`: past the last statement, `step` is `evalTerminator` of the block's
  terminator;
- `storageDead_dead`, `storageDead_live`: `StorageDead` of a dead local changes nothing; of a
  live, non-aliased one deallocates its storage and clears it;
- `storageLive_dead`: `StorageLive` of a dead local allocates a fresh stack allocation of the
  local's size and alignment (`runOn_allocate_ok`: a new `AllocId`, the oracle's address,
  `Uninit` bytes, live) and records it;
- `goto_inv`, `switchInt_inv`: jumps change only the frame's `bb` and `stmt := 0`; a switch on a
  copied or moved whole local loads it at its type and jumps to the matching case's target or
  `otherwise`;
- `return_inv`: `Return` loads the return place `_0` at its type, then pops the frame; at the
  bottom of the stack the run ends with that value.

All states are related through `runOn` (`IntBin.lean`).
-/
import Ryo.Proofs.Lower.IntBin

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem

/-! ## Monad helpers -/

theorem runOn_setCurFrame {o : Spec.Oracle} {s : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (g : Spec.Frame) :
    runOn (SemM.setCurFrame g) o s = (.ok (), { s with stack := g :: rest }) := by
  have e : runOn (SemM.setCurFrame g) o s = runOn (match s.stack with
      | _ :: rest => (modify fun s => { s with stack := g :: rest } : SemM Unit)
      | [] => throwIllFormed "no active frame") o s := rfl
  rw [e, hs]; rfl

theorem runOn_modifyCurFrame {o : Spec.Oracle} {s : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (g : Spec.Frame → Spec.Frame) :
    runOn (SemM.modifyCurFrame g) o s = (.ok (), { s with stack := g f :: rest }) := by
  have e1 : SemM.modifyCurFrame g = (SemM.curFrame >>= fun f => SemM.setCurFrame (g f)) := rfl
  rw [e1, runOn_bind, runOn_curFrame hs]
  exact runOn_setCurFrame hs (g f)

theorem runOn_curFrame_nil {o : Spec.Oracle} {s : Spec.State} (hs : s.stack = []) :
    runOn SemM.curFrame o s = (.error (.illFormed "no active frame"), s) := by
  have e : runOn SemM.curFrame o s = runOn (match s.stack with
      | g :: _ => pure g
      | [] => throwIllFormed "no active frame" : SemM Spec.Frame) o s := rfl
  rw [e, hs]; rfl

theorem runOn_modifyCurFrame_ok {o : Spec.Oracle} {s s' : Spec.State}
    {g : Spec.Frame → Spec.Frame} (h : runOn (SemM.modifyCurFrame g) o s = (.ok (), s')) :
    ∃ f rest, s.stack = f :: rest ∧ s' = { s with stack := g f :: rest } := by
  rcases hs : s.stack with _ | ⟨f, rest⟩
  · have e1 : SemM.modifyCurFrame g = (SemM.curFrame >>= fun f => SemM.setCurFrame (g f)) := rfl
    rw [e1, runOn_bind, runOn_curFrame_nil hs] at h
    exact (prod_err_ok h).elim
  · refine ⟨f, rest, rfl, ?_⟩
    rw [runOn_modifyCurFrame hs] at h
    exact (prod_ok_inj h).2.symm

theorem runOn_liftE {α : Type} (e : Except Outcome α) (o : Spec.Oracle) (s : Spec.State) :
    runOn (SemM.liftE e) o s = (match e with
      | .ok a => (.ok a, s)
      | .error x => (.error x, s)) := by
  cases e <;> rfl

theorem runOn_getMem0 (o : Spec.Oracle) (s : Spec.State) :
    runOn SemM.getMem o s = (.ok s.mem, s) := rfl

theorem runOn_choose (c : Choice) (o : Spec.Oracle) (s : Spec.State) :
    runOn (choose c : SemM c.Answer) o s =
      (.ok (o.answer s.choiceCount c s), { s with choiceCount := s.choiceCount + 1 }) := rfl

theorem runOn_choose_alloc (size : Size) (al : Align) (o : Spec.Oracle) (s : Spec.State) :
    runOn (choose (Choice.allocAddr size al) : SemM Nat) o s =
      (.ok (o.answer s.choiceCount (.allocAddr size al) s),
        { s with choiceCount := s.choiceCount + 1 }) := rfl

theorem runOn_throwUb {α : Type} (msg : String) (o : Spec.Oracle) (s : Spec.State) :
    runOn (throwUb msg : SemM α) o s = (.error (.ub msg), s) := rfl

theorem runOn_throwNoBehavior {α : Type} (msg : String) (o : Spec.Oracle) (s : Spec.State) :
    runOn (throwNoBehavior msg : SemM α) o s = (.error (.noBehavior msg), s) := rfl

theorem runOn_setMem (m : Memory) (o : Spec.Oracle) (s : Spec.State) :
    runOn (SemM.setMem m) o s = (.ok (), { s with mem := m }) := rfl

theorem runOn_memUpdate (g : Memory → Except Outcome Memory) (o : Spec.Oracle) (s : Spec.State) :
    runOn (SemM.memUpdate g) o s = (match g s.mem with
      | .ok m => (.ok (), { s with mem := m })
      | .error x => (.error x, s)) := by
  have e : runOn (SemM.memUpdate g) o s =
      runOn (SemM.liftE (g s.mem) >>= fun m => SemM.setMem m) o s := rfl
  rw [e, runOn_bind]
  cases g s.mem <;> rfl

theorem runOn_localTy {o : Spec.Oracle} {s : Spec.State} {f : Spec.Frame} {l : Local}
    {t : Spec.Ty} (h : f.body.locals[l]? = some t) :
    runOn (SemM.localTy f l) o s = (.ok t, s) := by
  unfold SemM.localTy
  rw [h]; rfl

theorem runOn_jumpTo {o : Spec.Oracle} {s : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (bb : BasicBlock) :
    runOn (SemM.jumpTo bb) o s = (.ok (), { s with stack := { f with bb, stmt := 0 } :: rest }) :=
  runOn_modifyCurFrame hs _

/-- `evalOperand` of a moved whole local, as `runOn_evalOperand_copy`. -/
theorem runOn_evalOperand_move {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {l : Local} {r : Value × Spec.Ty}
    (h : runOn (evalOperand (.move ⟨l, []⟩)) o s = (.ok r, s1)) :
    ∃ p ty v, f.locals[l]? = some (some p) ∧ f.body.locals[l]? = some ty ∧
      typedLoad s.mem p ty .one = .ok v ∧ r = (v, ty) ∧ s1 = s := by
  have e : runOn (evalOperand (.move ⟨l, []⟩)) o s = runOn (evalOperand (.copy ⟨l, []⟩)) o s := rfl
  rw [e] at h
  exact runOn_evalOperand_copy hs h

/-- `evalOperand` of an operand reading a whole local (`Operand.local?`). -/
theorem runOn_evalOperand_local {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {op : Operand} {l : Local}
    (hl : op.local? = some l) {r : Value × Spec.Ty}
    (h : runOn (evalOperand op) o s = (.ok r, s1)) :
    ∃ p ty v, f.locals[l]? = some (some p) ∧ f.body.locals[l]? = some ty ∧
      typedLoad s.mem p ty .one = .ok v ∧ r = (v, ty) ∧ s1 = s := by
  match op, hl with
  | .copy ⟨l', []⟩, hl =>
    cases hl; exact runOn_evalOperand_copy hs h
  | .move ⟨l', []⟩, hl =>
    cases hl; exact runOn_evalOperand_move hs h

/-! ## `step` -/

/-- `step` at a statement: the statement, then the frame's `stmt` advanced. -/
theorem step_eq_stmt {o : Spec.Oracle} {s : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hfin : s.final = none)
    (hpu : f.pendingUnwind = none) {bd : BlockData} (hbd : f.body.blocks[f.bb]? = some bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) :
    runOn step o s = runOn (evalStatement st >>= fun _ =>
      SemM.modifyCurFrame fun f => { f with stmt := f.stmt + 1 }) o s := by
  unfold step
  simp only [runOn_bind, runOn_get, runOn_curFrame hs, hfin, hpu, hbd, hst, Option.isSome_none,
    Bool.false_eq_true, ↓reduceIte]

/-- `step` past a block's statements: its terminator. -/
theorem step_eq_term {o : Spec.Oracle} {s : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hfin : s.final = none)
    (hpu : f.pendingUnwind = none) {bd : BlockData} (hbd : f.body.blocks[f.bb]? = some bd)
    (hst : bd.stmts[f.stmt]? = none) :
    runOn step o s = runOn (evalTerminator bd.term) o s := by
  unfold step
  simp only [runOn_bind, runOn_get, runOn_curFrame hs, hfin, hpu, hbd, hst, Option.isSome_none,
    Bool.false_eq_true, ↓reduceIte]

/-- A successful `step` at a statement runs the statement, which leaves an active frame `f1`,
and then advances `f1`'s `stmt`. -/
theorem step_stmt_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hfin : s.final = none)
    (hpu : f.pendingUnwind = none) {bd : BlockData} (hbd : f.body.blocks[f.bb]? = some bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) (h : runOn step o s = (.ok (), s')) :
    ∃ s1 f1 rest1, runOn (evalStatement st) o s = (.ok (), s1) ∧ s1.stack = f1 :: rest1 ∧
      s' = { s1 with stack := { f1 with stmt := f1.stmt + 1 } :: rest1 } := by
  rw [step_eq_stmt hs hfin hpu hbd hst] at h
  obtain ⟨u, s1, h1, h2⟩ := runOn_bind_ok h
  cases u
  obtain ⟨f1, rest1, hs1, rfl⟩ := runOn_modifyCurFrame_ok h2
  exact ⟨s1, f1, rest1, h1, hs1, rfl⟩

/-- A successful `step` past the statements runs the terminator. -/
theorem step_term_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hfin : s.final = none)
    (hpu : f.pendingUnwind = none) {bd : BlockData} (hbd : f.body.blocks[f.bb]? = some bd)
    (hst : bd.stmts[f.stmt]? = none) (h : runOn step o s = (.ok (), s')) :
    runOn (evalTerminator bd.term) o s = (.ok (), s') := by
  rw [← step_eq_term hs hfin hpu hbd hst]; exact h

/-! ## Storage statements -/

/-- `StorageDead` of a dead local changes nothing. -/
theorem storageDead_dead {o : Spec.Oracle} {s : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {l : Local}
    (hl : ∀ p, f.locals[l]? ≠ some (some p)) :
    runOn (storageDead l) o s = (.ok (), s) := by
  unfold storageDead
  rw [runOn_bind, runOn_curFrame hs]
  show runOn (match f.locals[l]? with
    | some (some p) => _
    | _ => pure ()) o s = _
  rcases hx : f.locals[l]? with _ | _ | p
  · rfl
  · rfl
  · exact absurd hx (hl p)

/-- `StorageDead` of a live, non-aliased local: its storage deallocated (at its type's size and
alignment, as a stack allocation), the local cleared. -/
theorem storageDead_live {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {l : Local} {p : ThinPointer}
    (hl : f.locals[l]? = some (some p)) (hna : f.aliased.contains l = false)
    (h : runOn (storageDead l) o s = (.ok (), s')) :
    ∃ ty m', f.body.locals[l]? = some ty ∧ s.mem.deallocate p .stack ty.size ty.align = .ok m' ∧
      s' = { s with mem := m', stack := { f with locals := f.locals.set! l none, aliased := f.aliased.erase l } :: rest } := by
  rcases hty : f.body.locals[l]? with _ | ty
  · unfold storageDead at h
    simp only [runOn_bind, runOn_curFrame hs, hl, hna, Bool.not_false, ↓reduceIte,
      SemM.localTy, hty] at h
    exact (prod_err_ok h).elim
  · rcases hd : s.mem.deallocate p .stack ty.size ty.align with e | m'
    · unfold storageDead at h
      simp only [runOn_bind, runOn_curFrame hs, hl, hna, Bool.not_false, ↓reduceIte,
        runOn_localTy hty, runOn_memUpdate, hd] at h
      exact (prod_err_ok h).elim
    · unfold storageDead at h
      simp only [runOn_bind, runOn_curFrame hs, hl, hna, Bool.not_false, ↓reduceIte,
        runOn_localTy hty, runOn_memUpdate, hd] at h
      have hs2 : ({ s with mem := m' } : Spec.State).stack = f :: rest := hs
      rw [runOn_setCurFrame hs2] at h
      exact ⟨ty, m', rfl, hd, (prod_ok_inj h).2.symm⟩

/-- A successful `Memory.allocate` of a stack allocation in L0: a fresh id (the memory's
size), the oracle's address, `Uninit` bytes of the size, the alignment, live; one choice taken. -/
theorem runOn_allocate_ok {o : Spec.Oracle} {s s2 : Spec.State} {m m' : Memory} {size : Size}
    {al : Align} {p : ThinPointer}
    (h : runOn (m.allocate .stack size al : SemM (ThinPointer × Memory)) o s = (.ok (p, m'), s2)) :
    ∃ a : Allocation, a.data = Array.replicate size .uninit ∧ a.addr = p.addr ∧ a.align = al ∧
      a.kind = .stack ∧ a.live = true ∧ p.prov = some m.allocs.size ∧
      m' = { allocs := m.allocs.push a } ∧ m.addrOk p.addr size al = true ∧
      s2 = { s with choiceCount := s.choiceCount + 1 } := by
  unfold Memory.allocate at h
  cases hv : Target.validSize size
  · simp only [runOn_bind, hv, Bool.not_false, ↓reduceIte, runOn_throwUb, Prod.mk.injEq,
      reduceCtorEq, false_and] at h
  · cases ha : m.addrOk (o.answer s.choiceCount (.allocAddr size al) s) size al
    · simp only [runOn_bind, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte, runOn_pure] at h
      erw [runOn_choose_alloc] at h
      simp only [ha, Bool.not_false, ↓reduceIte, runOn_bind, runOn_throwNoBehavior, Prod.mk.injEq,
        reduceCtorEq, false_and] at h
    · simp only [runOn_bind, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte, runOn_pure] at h
      erw [runOn_choose_alloc] at h
      simp only [ha, Bool.not_true, Bool.false_eq_true, ↓reduceIte, runOn_pure, Prod.mk.injEq,
        Except.ok.injEq] at h
      obtain ⟨⟨hp, hm⟩, hs2⟩ := h
      subst hp hm hs2
      exact ⟨_, rfl, rfl, rfl, rfl, rfl, rfl, rfl, ha, rfl⟩

/-- `StorageLive` of a dead local: a fresh stack allocation of its type's size and alignment
(`runOn_allocate_ok` describes it) recorded as the local's storage. -/
theorem storageLive_dead {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {l : Local}
    (hl : ∀ p, f.locals[l]? ≠ some (some p)) (h : runOn (storageLive l) o s = (.ok (), s')) :
    ∃ ty size p m' s2, f.body.locals[l]? = some ty ∧ ty.size? = some size ∧
      runOn (s.mem.allocate .stack size ty.align : SemM (ThinPointer × Memory)) o s =
        (.ok (p, m'), s2) ∧ s2.stack = s.stack ∧
      s' = { s2 with mem := m', stack := { f with locals := f.locals.set! l (some p) } :: rest } := by
  unfold storageLive at h
  obtain ⟨u, sA, hA, h1⟩ := runOn_bind_ok h
  rw [storageDead_dead hs hl] at hA
  have hsA : sA = s := (prod_ok_inj hA).2.symm
  subst sA
  rw [runOn_bind, runOn_curFrame hs] at h1
  obtain ⟨ty, sB, hB, h2⟩ := runOn_bind_ok h1
  obtain ⟨hty, hsB⟩ := runOn_localTy_ok hB
  subst sB
  rcases hsz : ty.size? with _ | size
  · simp only [hsz] at h2
    exact (prod_err_ok h2).elim
  · simp only [hsz] at h2
    rw [runOn_bind, runOn_getMem0] at h2
    obtain ⟨⟨p, m'⟩, s2, ha, h3⟩ := runOn_bind_ok h2
    rw [runOn_bind, runOn_setMem] at h3
    have hs2 : s2.stack = s.stack := by
      obtain ⟨-, -, -, -, -, -, -, -, -, hs2⟩ := runOn_allocate_ok ha
      rw [hs2]
    have hs3 : ({ s2 with mem := m' } : Spec.State).stack = f :: rest := hs2.trans hs
    change runOn (SemM.setCurFrame { f with locals := f.locals.set! l (some p) }) o
      { s2 with mem := m' } = _ at h3
    rw [runOn_setCurFrame hs3] at h3
    exact ⟨ty, size, p, m', s2, hty, hsz, ha, hs2, (prod_ok_inj h3).2.symm⟩

/-! ## Terminators -/

theorem goto_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {bb : BasicBlock}
    (h : runOn (evalTerminator (.goto bb)) o s = (.ok (), s')) :
    s' = { s with stack := { f with bb, stmt := 0 } :: rest } := by
  have e : evalTerminator (.goto bb) = SemM.jumpTo bb := rfl
  rw [e, runOn_jumpTo hs] at h
  exact (prod_ok_inj h).2.symm

/-- `SwitchInt` on a whole local: it loads at its type to a value whose `switchBits` select
the target. -/
theorem switchInt_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Operand} {l : Local}
    (hl : d.local? = some l) {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    (h : runOn (evalTerminator (.switchInt d cases otherwise)) o s = (.ok (), s')) :
    ∃ p ty v bits, f.locals[l]? = some (some p) ∧ f.body.locals[l]? = some ty ∧
      typedLoad s.mem p ty .one = .ok v ∧ runOn (switchBits (v, ty)) o s = (.ok bits, s) ∧
      s' = { s with stack := { f with
        bb := (match cases.find? (·.1 == bits) with
          | some (_, bb) => bb
          | none => otherwise), stmt := 0 } :: rest } := by
  have e : evalTerminator (.switchInt d cases otherwise) = (evalOperand d >>= fun x =>
      switchBits x >>= fun bits =>
      match cases.find? (·.1 == bits) with
      | some (_, bb) => SemM.jumpTo bb
      | none => SemM.jumpTo otherwise) := rfl
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨p, ty, v, hp, hty, hv, hx, hs1⟩ := runOn_evalOperand_local hs hl h1
  subst x s1
  obtain ⟨bits, s2, h3, h4⟩ := runOn_bind_ok h2
  have hs2 : s2 = s := by
    revert h3
    unfold switchBits
    split <;> intro h3 <;> first
      | exact (prod_ok_inj h3).2.symm
      | exact (prod_err_ok h3).elim
  subst s2
  refine ⟨p, ty, v, bits, hp, hty, hv, h3, ?_⟩
  rcases hf : cases.find? (·.1 == bits) with _ | ⟨_, bb⟩
  · simp only [hf] at h4 ⊢
    rw [runOn_jumpTo hs] at h4
    exact (prod_ok_inj h4).2.symm
  · simp only [hf] at h4 ⊢
    rw [runOn_jumpTo hs] at h4
    exact (prod_ok_inj h4).2.symm

/-- `Return`: `_0` is live and loads at its type to `v`; then the frame is popped (`popFrame`
returns the active frame), and at the bottom of the stack the run ends with `v`. -/
theorem return_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (h : runOn (evalTerminator .return) o s = (.ok (), s')) :
    ∃ p ty v g s2, f.locals[0]? = some (some p) ∧ f.body.locals[0]? = some ty ∧
      typedLoad s.mem p ty .one = .ok v ∧ runOn popFrame o s = (.ok g, s2) ∧ g = f ∧
      (f.cont = .bottom → s' = { s2 with final := some (.returned v) }) := by
  have e : evalTerminator .return = doReturn := rfl
  rw [e] at h
  unfold doReturn at h
  rw [runOn_bind, runOn_curFrame hs] at h
  obtain ⟨ty, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨hty, hs1⟩ := runOn_localTy_ok h1
  subst s1
  rcases hp : f.locals[0]? with _ | _ | p
  · simp only [hp] at h2; exact (prod_err_ok h2).elim
  · simp only [hp] at h2; exact (prod_err_ok h2).elim
  · simp only [hp] at h2
    rw [runOn_bind, runOn_getMem0] at h2
    obtain ⟨v, s3, h3, h4⟩ := runOn_bind_ok h2
    obtain ⟨hv, hs3⟩ := runOn_liftE_ok h3
    subst s3
    obtain ⟨g, s2, h5, h6⟩ := runOn_bind_ok h4
    have hg : g = f := by
      unfold popFrame at h5
      rw [runOn_bind, runOn_curFrame hs] at h5
      obtain ⟨_, s4, -, h7⟩ := runOn_bind_ok h5
      obtain ⟨_, s5, -, h8⟩ := runOn_bind_ok h7
      exact (prod_ok_inj h8).1.symm
    subst g
    refine ⟨p, ty, v, f, s2, rfl, hty, hv, h5, rfl, fun hc => ?_⟩
    simp only [hc] at h6
    exact (prod_ok_inj h6).2.symm

end Ryo.Proofs.Lower
