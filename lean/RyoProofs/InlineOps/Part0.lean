/-
RyoProofs.InlineOps.Part0 — `shapeOk` for chunk 0 of `inlineOpsL` (`InlineOps/Base.lean`).
-/
import RyoProofs.InlineOps.Base

namespace Ryo.Proofs.Inline

open Ryo.Vm Ryo.Vm.Asm

set_option maxRecDepth 100000 in
theorem inlineOpsC0_shape : ∀ p ∈ inlineOpsC 0, shapeOk p.1 p.2 = true := by decide +kernel

end Ryo.Proofs.Inline
