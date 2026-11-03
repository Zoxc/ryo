/-
Ryo.Proofs.Discharge.FrameSizes — the `Hyps` fields on the frame's sizes.

- `peFrame_of_check`: `frameSizesCheck` (`Ryo/Vm/FrameSizes.lean`, run by
  `Frame.decodeChecked`) gives `peFrame`, on PE `F + 8 < 2 ^ 31`.
- `16 + argSize ≤ K` holds by definition (`Setup.K = 16 + argSize`, `Hyps.argSizeK`); the
  window's `FrameBounds` comes from `windowCheck` (`Discharge/FrameBounds.lean`).

This file doesn't import `DecodeSound/Basic.lean`, so `Basic.lean` can import it.
-/
import Ryo.Vm.FrameSizes
import Ryo.Vm.R.Sem

namespace Ryo.Proofs.Discharge.FrameSizes

open Ryo.Vm

/-- `frameSizesCheck`'s success: on PE, `F + 8 < 2 ^ 31` (its `peStackArgCheck` part:
`Discharge.PeStackArg.peStackArgCheck_of_frameSizes`). -/
theorem peFrame_of_check {c : R.Code} (h : frameSizesCheck c.d c.mode = true) :
    c.mode.pe = true → c.d.frameSize + 8 < 2 ^ 31 := by
  intro hpe
  unfold frameSizesCheck at h
  rw [Bool.and_eq_true, hpe] at h
  simpa using h.1

end Ryo.Proofs.Discharge.FrameSizes
