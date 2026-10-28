/-
RyoProofs.InlineOps — every opcode `Asm.inlineOps` lists is of its class's shape (`shapeOk`), so
the inline-sequence theorems (`Ryo/Proofs/Inline.lean`, stated for every opcode of a class's
shape) cover every inline opcode. The kernel evaluation is split into chunks
(`InlineOps/Base.lean`, `InlineOps/Part*.lean`).
-/
import RyoProofs.InlineOps.Part0
import RyoProofs.InlineOps.Part1
import RyoProofs.InlineOps.Part2
import RyoProofs.InlineOps.Part3

namespace Ryo.Proofs.Inline

open Ryo.Vm Ryo.Vm.Asm

theorem inlineOpsL_shape : ∀ p ∈ inlineOpsL, shapeOk p.1 p.2 = true := by
  intro p hp
  rw [inlineOpsL_chunks] at hp
  simp only [List.mem_append] at hp
  rcases hp with ((h | h) | h) | h
  · exact inlineOpsC0_shape p h
  · exact inlineOpsC1_shape p h
  · exact inlineOpsC2_shape p h
  · exact inlineOpsC3_shape p h

/-- Every opcode with an inline form is of its class's shape, so the inline-sequence theorems
(stated for every opcode of that shape) cover it. -/
theorem inlineOps_shape : ∀ p ∈ inlineOps, shapeOk p.1 p.2 = true :=
  inlineOps_eq ▸ inlineOpsL_shape

end Ryo.Proofs.Inline
