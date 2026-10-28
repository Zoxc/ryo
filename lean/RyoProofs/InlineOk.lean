/-
RyoProofs.InlineOk — the opcode-table facts the inline step takes as hypotheses, for every
opcode of `Asm.inlineOps` (aot.md §C2, toward `decode_sound`).

- `all_kindOk`: every opcode whose handler is of an inline class's kind (`inlineKind`) has an
  `opSem` shape, isn't `resume` or `unreachable`, and isn't a `cvt` from `i64` to a signed
  integer (`kindOk`, `Ryo/Proofs/CacheStep.lean`). A `decide +kernel` over the 901 opcodes,
  slow on a busy machine, hence here, outside the default build (like `InlineOps.lean`).
- `inlineOps_ok`: `(op, cls) ∈ inlineOps` gives `InlineOk op cls` (`shapeOk` is
  `inlineOps_shape`, the rest `all_kindOk` through the handler kind `shapeOk` fixes).
- `inlineOps_ext`: no inline class is a sign extension from 64 bits, which `sequence_cacheSafe`
  needs.
- `inline_step_cached_ops`: `inline_step_cached` for an inline opcode, with those discharged.
-/
import Ryo.Proofs.CacheStep
import RyoProofs.InlineOps

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

set_option maxRecDepth 100000 in
theorem all_kindOk : Full.all.all kindOk = true := by decide +kernel

/-- Every inline opcode satisfies what `inline_step` needs of it. -/
theorem inlineOps_ok {f : Full.Opcode} {cls : Class} (h : (f, cls) ∈ inlineOps) :
    InlineOk f cls :=
  inlineOk_of all_kindOk h (inlineOps_shape (f, cls) h)

/-- No inline class sign-extends from 64 bits. -/
theorem inlineOps_ext {f : Full.Opcode} {cls : Class} (h : (f, cls) ∈ inlineOps) :
    ∀ b, cls ≠ .ext .q b true :=
  not_ext64 all_kindOk h (inlineOps_shape (f, cls) h)

/-- `inline_step_cached` for an inline opcode of a `SoundC` class. -/
theorem inline_step_cached_ops (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {cls : Class} {cand : List Item} {br : Option Cond} {cache : Cache} (hsound : SoundC cls)
    (hcount : ∀ lz w, cls = .count lz w → w = .q) (hinv : CacheInv cache x) (hr : RRel s x) (hi : c.d.insns[s.pc]? = some (.native op ops))
    (hf : op.full = some f) (hmem : (f, cls) ∈ inlineOps)
    (hseq : sequence cls ops = some (cand, br)) (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      match br with
      | none => s'.pc = s.pc + 1
      | some cond => ∃ neg t b, R.nativeCtl f ops = some (.branch neg t) ∧
          cond.eval x'.flags = .ok b ∧ s'.pc = if b then t else s.pc + 1 :=
  inline_step_cached ctx hsound hinv hr hi hf (inlineOps_ok hmem) (inlineOps_ext hmem) hcount hseq h

end Ryo.Proofs.CacheStep
