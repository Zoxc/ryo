/-
Ryo.Proofs.Discharge.StackSizes — the `StackSizes` fields and `Hyps.peShadow` (`32 ≤ F`) from
`stackSizesCheck` (`Ryo/Vm/StackSizes.lean`).

- `of_check`: the check, `stackSize` zero past the instructions (`stackSizeOut`) and
  `F ≤ 2 ^ 31` (`FrameBounds.F_le`) give `StackSizes`' three fields and, on PE, `32 ≤ F`.
- `argSlots_of_check`, `argSlots_call`: its `argSlotsCheck` part (`FrameInv.slots` across a
  call's answer, `Discharge/PeStackArg.lean`).
- `regionCalls_of_check`, `regionCalls_call`: its `regionCallsCheck` part (`StackSizes.region`).
- `imageStackSize_out`: `imageProgram`'s `stackSize` is zero past the instructions (no
  `imageCallee` there), so `stackSizeOut` holds of the image's codes.

This file doesn't import `DecodeSound/Basic.lean`, so `Basic.lean` can import it.
-/
import Ryo.Vm.StackSizes
import Ryo.Vm.R.Run

namespace Ryo.Proofs.Discharge.StackSizes

open Ryo.Vm Ryo.Vm.R

set_option maxRecDepth 8000

/-- `stackSizesCheck`'s success (with `stackSize` zero past the instructions and the frame
under `2 ^ 31`): `StackSizes.stack`, `.shadow`, `.frame`, and on PE `32 ≤ F`. -/
theorem of_check {c : R.Code} (h : stackSizesCheck c = true)
    (hout : ∀ k, c.d.insns.size ≤ k → c.stackSize k = 0)
    (hF : (c.d.frameSize : Int) ≤ 2 ^ 31) :
    (∀ k, c.d.frameSize + c.stackSize k < 2 ^ 62) ∧
    (c.mode.pe = true → ∀ (k : Nat) (op : Reduced.Opcode) (ops : List (R.Opnd Nat))
      (f : Full.Opcode), c.d.insns[k]? = some (.native op ops) →
      op.full = some f → f.info.shape = .call → 32 ≤ c.stackSize k) ∧
    (∀ k, c.stackSize k + (if c.mode.pe then 16 else 0) ≤ c.d.frameSize) ∧
    (c.mode.pe = true → 32 ≤ c.d.frameSize) := by
  unfold stackSizesCheck at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨⟨h0, hall⟩, -⟩ := h
  have hpeF : c.mode.pe = true → 32 ≤ c.d.frameSize := by
    intro hpe
    rw [hpe] at h0
    simpa using h0
  have hat : ∀ k, k < c.d.insns.size →
      decide (c.stackSize k + (if c.mode.pe then 16 else 0) ≤ c.d.frameSize) = true ∧
        (!c.mode.pe || !((c.d.insns[k]?.map R.Insn.isCall).getD false) ||
          decide (32 ≤ c.stackSize k)) = true := by
    intro k hk
    have := List.all_eq_true.1 hall k (List.mem_range.2 hk)
    simpa only [Bool.and_eq_true] using this
  have hframe : ∀ k, c.stackSize k + (if c.mode.pe then 16 else 0) ≤ c.d.frameSize := by
    intro k
    by_cases hk : k < c.d.insns.size
    · exact of_decide_eq_true (hat k hk).1
    · rw [hout k (by omega)]
      split
      · next hpe => have := hpeF hpe; omega
      · omega
  refine ⟨fun k => ?_, fun hpe k op ops f hi hf hsh => ?_, hframe, hpeF⟩
  · have h1 := hframe k
    have h2 : c.stackSize k ≤ c.d.frameSize := by split at h1 <;> omega
    omega
  · have hk : k < c.d.insns.size := (Array.getElem?_eq_some_iff.1 hi).1
    have h2 := (hat k hk).2
    have hc : R.Insn.isCall (.native op ops) = true := by
      unfold R.Insn.isCall; dsimp only; rw [hf]; dsimp only; rw [hsh]; rfl
    rw [hi, hpe] at h2
    simp only [Option.map_some, Option.getD_some, hc, Bool.not_true, Bool.false_or] at h2
    exact of_decide_eq_true h2

/-- `stackSizesCheck` includes `argSlotsCheck`. -/
theorem argSlots_of_check {c : R.Code} (h : stackSizesCheck c = true) : argSlotsCheck c = true := by
  unfold stackSizesCheck at h
  simp only [Bool.and_eq_true] at h
  exact h.2.1

/-- `stackSizesCheck` includes `regionCallsCheck`. -/
theorem regionCalls_of_check {c : R.Code} (h : stackSizesCheck c = true) :
    regionCallsCheck c = true := by
  unfold stackSizesCheck at h
  simp only [Bool.and_eq_true] at h
  exact h.2.2

/-- `regionCallsCheck`'s success: a call in PE's pad region has an area of at most the shadow
space (`StackSizes.region`). -/
theorem regionCalls_call {c : R.Code} (h : regionCallsCheck c = true) {k : Nat}
    {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    (hi : c.d.insns[k]? = some (.native op ops)) (hf : op.full = some f)
    (hsh : f.info.shape = .call) (hreg : c.inRegion k = true) : c.stackSize k ≤ 32 := by
  unfold regionCallsCheck at h
  have hk : k < c.d.insns.size := (Array.getElem?_eq_some_iff.1 hi).1
  have h2 := List.all_eq_true.1 h k (List.mem_range.2 hk)
  have hc : R.Insn.isCall (.native op ops) = true := by
    unfold R.Insn.isCall; dsimp only; rw [hf]; dsimp only; rw [hsh]; rfl
  rw [hi, hreg] at h2
  simp only [Option.map_some, Option.getD_some, hc, Bool.not_true, Bool.false_or] at h2
  exact of_decide_eq_true h2

/-- `argSlotsCheck`'s success: no handler call's stack argument (`shadowSize ≤ 32`), or a call's
area is at most the shadow space. -/
theorem argSlots_call {c : R.Code} (h : argSlotsCheck c = true) {k : Nat} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} (hi : c.d.insns[k]? = some (.native op ops))
    (hf : op.full = some f) (hsh : f.info.shape = .call) :
    c.d.shadowSize c.mode ≤ 32 ∨ c.stackSize k ≤ 32 := by
  unfold argSlotsCheck at h
  rw [Bool.or_eq_true] at h
  rcases h with h | h
  · exact .inl (of_decide_eq_true h)
  · right
    have hk : k < c.d.insns.size := (Array.getElem?_eq_some_iff.1 hi).1
    have h2 := List.all_eq_true.1 h k (List.mem_range.2 hk)
    have hc : R.Insn.isCall (.native op ops) = true := by
      unfold R.Insn.isCall; dsimp only; rw [hf]; dsimp only; rw [hsh]; rfl
    rw [hi] at h2
    simp only [Option.map_some, Option.getD_some, hc, Bool.not_true, Bool.false_or] at h2
    exact of_decide_eq_true h2

/-- `imageProgram`'s `stackSize` (`Run.lean`) is zero past the instructions. -/
theorem imageStackSize_out (o : Ryo.Obj.ImageObject) (d : R.Decoded) (k : Nat)
    (hk : d.insns.size ≤ k) :
    (((Image.imageCallee d k).bind (o.funcs[·]?)).map (·.argSize) |>.getD 0) = 0 := by
  have hn : d.insns[k]? = none := Array.getElem?_eq_none_iff.2 hk
  simp [Image.imageCallee, hn]

end Ryo.Proofs.Discharge.StackSizes
