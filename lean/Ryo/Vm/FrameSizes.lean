/-
Ryo.Vm.FrameSizes — a check of the decoded frame size that `Frame.decodeChecked` runs:
`frameSizesCheck`, on PE `F + 8 < 2 ^ 31` (PE's epilogue `add rsp, F` and the return address
above the saved `rbp` as signed 32-bit displacements; `Decoded.boundsOk` gives `F ≤ 2 ^ 31`
only). `Ryo.Proofs.Discharge.FrameSizes` turns its success into `Hyps.peFrame`.
-/
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.Vm.R Ryo.Vm.Asm

/-- On PE, the frame size and the return address fit a signed 32-bit displacement. -/
def frameSizesCheck (d : R.Decoded) (mode : Mode) : Bool :=
  !mode.pe || decide (d.frameSize + 8 < 2 ^ 31)

end Ryo.Vm
