/-
Ryo.Proofs.Discharge.FrameSizes — the `Hyps` fields on the frame's sizes.

- `peFrame_of_check`: `frameSizesCheck` (`Ryo/Vm/FrameSizes.lean`, run by
  `Frame.decodeChecked`) gives `peFrame`, on PE `F + 8 < 2 ^ 31`.
- `argSizeK` (`16 + argSize ≤ K`) isn't a fact of the decoded code: `K` is a free field of the
  `Setup` (the window's end above `fp`) and `argSize` one of the `R.Code`, neither an input of
  the decoder. It holds for the window `decode_sound` is meant for, `K = 16 + argSize`
  (`argSizeK_of_window`), whose `FrameBounds` the image checker's `checkSignature`
  (`frameTop ≤ 16 + argSize ≤ 2 ^ 31`) gives (`Discharge/FrameBounds.lean`).

This file doesn't import `DecodeSound/Basic.lean`, so `Basic.lean` can import it.
-/
import Ryo.Vm.FrameSizes
import Ryo.Vm.R.Sem

namespace Ryo.Proofs.Discharge.FrameSizes

open Ryo.Vm

/-- `frameSizesCheck`'s success: on PE, `F + 8 < 2 ^ 31`. -/
theorem peFrame_of_check {c : R.Code} (h : frameSizesCheck c.d c.mode = true) :
    c.mode.pe = true → c.d.frameSize + 8 < 2 ^ 31 := by
  intro hpe
  unfold frameSizesCheck at h
  rw [hpe] at h
  simpa using h

/-- The window `K = 16 + argSize` holds the incoming area. -/
theorem argSizeK_of_window {c : R.Code} {K : Int} (hK : K = 16 + c.argSize) :
    (16 + c.argSize : Int) ≤ K :=
  by subst hK; exact Int.le_refl _

end Ryo.Proofs.Discharge.FrameSizes
