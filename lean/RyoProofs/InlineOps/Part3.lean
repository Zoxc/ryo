/-
RyoProofs.InlineOps.Part3 — `shapeOk` for chunk 3 of `inlineOpsL` (`InlineOps/Base.lean`).
-/
import RyoProofs.InlineOps.Base

namespace Ryo.Proofs.Inline

open Ryo.Vm Ryo.Vm.Asm

set_option maxRecDepth 100000 in
theorem inlineOpsC3_shape : ∀ p ∈ inlineOpsC 3, shapeOk p.1 p.2 = true := by decide +kernel

end Ryo.Proofs.Inline
