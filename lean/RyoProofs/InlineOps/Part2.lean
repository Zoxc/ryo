/-
RyoProofs.InlineOps.Part2 — `shapeOk` for chunk 2 of `inlineOpsL` (`InlineOps/Base.lean`).
-/
import RyoProofs.InlineOps.Base

namespace Ryo.Proofs.Inline

open Ryo.Vm Ryo.Vm.Asm

set_option maxRecDepth 100000 in
theorem inlineOpsC2_shape : ∀ p ∈ inlineOpsC 2, shapeOk p.1 p.2 = true := by decide +kernel

end Ryo.Proofs.Inline
