/-
RyoProofs.InlineOk — the opcode-table facts the inline step takes as hypotheses, for every
opcode of `Asm.inlineOps` (aot.md §C2, toward `decode_sound`).

- `all_kindOk`: every opcode whose handler is of an inline class's kind (`inlineKind`) has an
  `opSem` shape, isn't `resume` or `unreachable`, and isn't a `cvt` from `i64` to a signed
  integer (`kindOk`, `Ryo/Proofs/CacheStep.lean`). A `decide +kernel` over every opcode (in chunks),
  slow on a busy machine, hence here, outside the default build (like `InlineOps.lean`).
- `inlineOps_ok`: `(op, cls) ∈ inlineOps` gives `InlineOk op cls` (`shapeOk` is
  `inlineOps_shape`, the rest `all_kindOk` through the handler kind `shapeOk` fixes).
- `inlineOps_ext`: no inline class is a sign extension from 64 bits, which `sequence_cacheSafe`
  needs.
- `all_clsOk`/`inlineOps_clsOk`: every inline class is `clsOk` (`emit_canonical`).
- `inline_step_cached_ops`: `inline_step_cached` for an inline opcode, with those discharged.
-/
import Ryo.Proofs.CacheStep
import Ryo.Proofs.CacheEmit
import RyoProofs.InlineOps

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

-- In chunks of 100 opcodes (`opsIn`): one `decide +kernel` over `Full.all` peaked at 8.8 GiB.
set_option maxRecDepth 100000 in
theorem all_kindOk_0 : (opsIn 0 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_100 : (opsIn 100 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_200 : (opsIn 200 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_300 : (opsIn 300 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_400 : (opsIn 400 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_500 : (opsIn 500 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_600 : (opsIn 600 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_700 : (opsIn 700 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_800 : (opsIn 800 100).all kindOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem all_kindOk_900 : (opsIn 900 5).all kindOk = true := by
  decide +kernel
theorem all_kindOk : Full.all.all kindOk = true := by
  rw [all_eq_opsIn]
  have h0 := all_kindOk_0
  have h1 : (opsIn 0 200).all kindOk = true :=
    all_opsIn_append (m := 100) (n := 100) rfl h0 all_kindOk_100
  have h2 : (opsIn 0 300).all kindOk = true :=
    all_opsIn_append (m := 200) (n := 100) rfl h1 all_kindOk_200
  have h3 : (opsIn 0 400).all kindOk = true :=
    all_opsIn_append (m := 300) (n := 100) rfl h2 all_kindOk_300
  have h4 : (opsIn 0 500).all kindOk = true :=
    all_opsIn_append (m := 400) (n := 100) rfl h3 all_kindOk_400
  have h5 : (opsIn 0 600).all kindOk = true :=
    all_opsIn_append (m := 500) (n := 100) rfl h4 all_kindOk_500
  have h6 : (opsIn 0 700).all kindOk = true :=
    all_opsIn_append (m := 600) (n := 100) rfl h5 all_kindOk_600
  have h7 : (opsIn 0 800).all kindOk = true :=
    all_opsIn_append (m := 700) (n := 100) rfl h6 all_kindOk_700
  have h8 : (opsIn 0 900).all kindOk = true :=
    all_opsIn_append (m := 800) (n := 100) rfl h7 all_kindOk_800
  have h9 : (opsIn 0 905).all kindOk = true :=
    all_opsIn_append (m := 900) (n := 5) rfl h8 all_kindOk_900
  exact h9

set_option maxRecDepth 100000 in
theorem all_clsOk : inlineOps.all (fun p => clsOk p.2) = true := by
  rw [Ryo.Proofs.Inline.inlineOps_eq, Ryo.Proofs.Inline.inlineOpsL_chunks]
  simp only [List.all_append, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩ <;> decide +kernel

/-- Every inline opcode's class has canonical items (`clsOk`, for `emit_canonical`). -/
theorem inlineOps_clsOk {f : Full.Opcode} {cls : Class} (h : (f, cls) ∈ inlineOps) :
    clsOk cls = true :=
  List.all_eq_true.1 all_clsOk (f, cls) h

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
    (hinv : CacheInv cache x) (hr : RRel s x) (hi : c.d.insns[s.pc]? = some (.native op ops))
    (hf : op.full = some f) (hmem : (f, cls) ∈ inlineOps)
    (hseq : sequence cls ops = some (cand, br)) (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      match br with
      | none => s'.pc = s.pc + 1
      | some cond => ∃ neg t b, R.nativeCtl f ops = some (.branch neg t) ∧
          cond.eval x'.flags = .ok b ∧ s'.pc = if b then t else s.pc + 1 :=
  inline_step_cached ctx hsound hinv hr hi hf (inlineOps_ok hmem) (inlineOps_ext hmem) hseq h

/-- `DecodeSound.Hyps.inlineClsOk`, which the default build can't evaluate. -/
theorem inlineClsOk_holds (f : Full.Opcode) (cls : Class) (h : (f, cls) ∈ inlineOps) :
    shapeOk f cls = true ∧ clsOk cls = true :=
  ⟨Ryo.Proofs.Inline.inlineOps_shape (f, cls) h, inlineOps_clsOk h⟩

end Ryo.Proofs.CacheStep
