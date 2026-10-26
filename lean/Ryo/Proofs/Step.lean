/-
Ryo.Proofs.Step — one R step of an inline instruction against its sequence (aot.md §C2,
toward `decode_sound`): R's `step` (scopes, then `view` and `opSem`, then `Then.succ`) and the
inline theorems (`Ryo/Proofs/Inline.lean`) give the step's simulation under `RRel`.

- `step_native`: what a successful `step` of a native instruction of an `opSem` shape is: the
  scopes, then `opSem` on `nativeVals`, then its control through `nativeCtl`.
- `inline_step`: for an instruction whose class has `Sound` (every `frameOnly` class), from
  `RRel s x`, running the class's sequence reaches `x'` with `RRel s' x'`, `rip` past the
  items, and the next instruction `s'.pc` the fall-through or, for a branch class, the target
  exactly when the sequence's condition holds on `x'`'s flags (the decoder's `jcc` then jumps
  on it).

The sequence is the one on `rax` (`sequence`); the register cache's renaming and its operand
substitution (`Cache.emit`) are a separate step. The facts about the opcode tables it needs
are hypotheses (`InlineOk`): the opcode has the class's shape (`shapeOk`, which
`inlineOps_shape` proves for every inline opcode), an `opSem` shape, and isn't `resume` or
`unreachable`.
-/
import Ryo.Proofs.Inline
import Ryo.Proofs.Scope

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Step

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope

/-- What the step needs of an inline opcode and its class (see the module comment). -/
structure InlineOk (f : Full.Opcode) (c : Class) : Prop where
  shape : shapeOk f c = true
  opShape : R.opShape f = true
  notResume : f ≠ .resume
  notUnreachable : f ≠ .unreachable

/-- A native instruction's view is its `nativeVals` and `nativeCtl`. -/
theorem view_native {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {v : R.View} {f : Full.Opcode} (hf : op.full = some f)
    (hs : R.opShape f = true) (h : R.view mode ρ (.native op ops) = some v) :
    ∃ vals t, nativeVals ρ f ops = some vals ∧ R.nativeCtl f ops = some t ∧
      v = ⟨f, vals, some t⟩ := by
  simp only [R.view, hf, Option.bind_eq_bind, Option.bind_some, hs, ↓reduceIte] at h
  split at h
  · cases h
  · rename_i hlen
    cases hv : (f.info.operands.zip ops).mapM (fun (i, o) => R.nativeVal ρ i.kind o) with
    | none => simp [hv] at h
    | some vals =>
      cases hc : R.nativeCtl f ops with
      | none => simp [hv, hc] at h
      | some t =>
        simp only [hv, hc, Option.bind_some] at h
        refine ⟨vals, t, ?_, rfl, ?_⟩
        · simp only [nativeVals]
          simp only [show f.info.operands.length = ops.length by simpa using hlen, ↓reduceIte]
          exact hv
        · simp_all

theorem opShape_cases {f : Full.Opcode} (h : R.opShape f = true) :
    f.info.shape = .op ∨ f.info.shape = .br ∨ f.info.shape = .switch ∨ f.info.shape = .trap ∨
      f.info.shape = .lpad := by
  unfold R.opShape at h
  split at h <;> simp_all

/-- `stepView` of a native instruction of an `opSem` shape (not `resume` or `unreachable`). -/
theorem stepView_native {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} {o : R.Out} (hf : op.full = some f)
    (hs : R.opShape f = true) (hres : f ≠ .resume) (hun : f ≠ .unreachable)
    (h : R.stepView c s (.native op ops) ch = .ok o) :
    ∃ vals t ctl st' pc', nativeVals c.ρ f ops = some vals ∧ R.nativeCtl f ops = some t ∧
      opSem f vals s.st ch = .ok (ctl, st') ∧ t.succ s.pc ctl = some pc' ∧
      o = .step { s with pc := pc', st := st' } := by
  unfold R.stepView at h
  cases hv : R.view c.mode c.ρ (.native op ops) with
  | none => simp [hv, illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some v =>
    obtain ⟨vals, t, hn, hc, rfl⟩ := view_native hf hs hv
    simp only [hv, bind, Except.bind, beq_iff_eq, hres, hun, ↓reduceIte] at h
    cases ho : opSem f vals s.st ch with
    | error e => simp [ho] at h
    | ok r =>
      obtain ⟨ctl, st'⟩ := r
      simp only [ho] at h
      cases hp : t.succ s.pc ctl with
      | none => simp [hp, illFormed, throw, throwThe, MonadExceptOf.throw] at h
      | some pc' =>
        simp only [hp, pure, Except.pure, Except.ok.injEq] at h
        exact ⟨vals, t, ctl, st', pc', hn, hc, ho, hp, h.symm⟩

/-- A successful `step` of a native instruction of an `opSem` shape: the scopes, then
`stepView`. -/
theorem step_native {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} {o : R.Out}
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hs : R.opShape f = true) (h : R.step c s ch = .ok o) :
    ∃ s1, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.stepView c s1 (.native op ops) ch = .ok o := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    refine ⟨s1, rfl, ?_⟩
    simp only [hsc, hf] at h
    rcases opShape_cases hs with hsh | hsh | hsh | hsh | hsh <;>
      (rw [hsh] at h; exact h)

/-- One R step of an inline instruction of a `Sound` class, against its sequence (see the
module comment). -/
theorem inline_step (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class}
    {items : List Item} {br : Option Cond} (hsound : Sound cls) (hr : RRel s x)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (hseq : sequence cls ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      match br with
      | none => s'.pc = s.pc + 1
      | some cond => ∃ neg t b, R.nativeCtl f ops = some (.branch neg t) ∧
          cond.eval x'.flags = .ok b ∧ s'.pc = if b then t else s.pc + 1 := by
  obtain ⟨s1, hsc, hv⟩ := step_native hi hf hok.opShape h
  have hr1 := rrel_scopes hr hsc
  have hpc : s1.pc = s.pc := (scopes_keeps _ hsc).pc
  obtain ⟨vals, t, ctl, st', pc', hn, hc, ho, hp, hs'⟩ :=
    stepView_native hf hok.opShape hok.notResume hok.notUnreachable hv
  cases hs'
  obtain ⟨x', hx, hpost⟩ := hsound ctx c.ρ f ops items br vals s1.st st' ctl ch x hok.shape hseq hn ho hr1.rel
  refine ⟨x', hx, ⟨hpost.rel, ?_, escWF_of_sameButWrites hr1.wf hpost.same⟩, hpost.rip, ?_⟩
  · have := hpost.regs 5 (by decide) (by decide)
    simp only [X86.State.reg] at hr1 ⊢
    rw [show X86.Reg.rbp.idx = 5 from rfl, this]
    exact hr1.rbp
  · have hctl := hpost.ctl
    cases br with
    | none =>
      simp only at hctl ⊢
      subst hctl
      cases t <;> simp [R.Then.succ] at hp
      rw [← hp, hpc]
    | some cond =>
      simp only at hctl ⊢
      obtain ⟨b, rfl, hb⟩ := hctl
      cases t with
      | branch neg tt =>
        refine ⟨neg, tt, b != neg, hc, hb neg tt hc, ?_⟩
        simp only [R.Then.succ, Option.some.injEq] at hp
        rw [← hp, hpc]
      | _ => simp [R.Then.succ] at hp

end Ryo.Proofs.Step
