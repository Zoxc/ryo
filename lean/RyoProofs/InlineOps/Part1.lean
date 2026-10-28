/-
RyoProofs.InlineOps.Part1 — `shapeOk` for chunk 1 of `inlineOpsL` (`InlineOps/Base.lean`).
-/
import RyoProofs.InlineOps.Base

namespace Ryo.Proofs.Inline

open Ryo.Vm Ryo.Vm.Asm

set_option maxRecDepth 100000 in
theorem inlineOpsC1_shape : ∀ p ∈ inlineOpsC 1, shapeOk p.1 p.2 = true := by decide +kernel

end Ryo.Proofs.Inline
