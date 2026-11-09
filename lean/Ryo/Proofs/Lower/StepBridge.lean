/-
Ryo.Proofs.Lower.StepBridge — from an instruction's `opSem` to R's `step` (M5a): an instruction
whose view is an operation falling through (`ctl = some .next`, not `resume` or `unreachable`)
with no scopes before it steps to the next index with `opSem`'s state, outside PE (where a
handler call also clears its home space).
-/
import Ryo.Vm.R.Sem

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

theorem step_of_opSem {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {st' : OpSem.State} (hi : c.d.insns[s.pc]? = some i) (hsc : c.scopesAt s.pc = [])
    (hv : view c.mode c.ρ i = some v) (hctl : v.ctl = some .next)
    (hres : v.op ≠ .resume) (hun : v.op ≠ .unreachable) (hpe : c.mode.pe = false)
    (hnat : ∀ op ops, i = .native op ops → ∀ f, op.full = some f →
      f.info.shape ≠ .jmp ∧ f.info.shape ≠ .arg ∧ f.info.shape ≠ .ret ∧ f.info.shape ≠ .call ∧
      f.info.shape ≠ .tailCall ∧ f.info.shape ≠ .island)
    (hop : OpSem.opSem v.op v.ops s.st ch = .ok (.next, st')) :
    step c s ch = .ok (.step { s with pc := s.pc + 1, st := st' }) := by
  have h1 : (v.op == Full.Opcode.resume) = false := beq_eq_false_iff_ne.mpr hres
  have h2 : (v.op == Full.Opcode.unreachable) = false := beq_eq_false_iff_ne.mpr hun
  have hsv : stepView c s i ch = .ok (.step { s with pc := s.pc + 1, st := st' }) := by
    unfold stepView
    simp only [hv, hctl, h1, h2, Bool.false_eq_true, if_false, hop, bind,
      Except.bind]
    cases i <;> simp [clearHome, hpe, Then.succ, pure, Except.pure]
  unfold step
  simp only [hi, hsc, List.foldlM_nil, bind, Except.bind, pure, Except.pure]
  cases i with
  | handler h args t => exact hsv
  | native op ops =>
    cases hf : op.full with
    | none => simp [view, hf, bind, Option.bind] at hv
    | some f =>
      obtain ⟨n1, n2, n3, n4, n5, n6⟩ := hnat op ops rfl f hf
      simp only [hf]
      cases hsh : f.info.shape <;>
        first
        | exact absurd hsh n1 | exact absurd hsh n2 | exact absurd hsh n3
        | exact absurd hsh n4 | exact absurd hsh n5 | exact absurd hsh n6
        | exact hsv | (rw [hsh]; exact hsv) | (simp only [hsh]; exact hsv)

end Ryo.Proofs.Lower
