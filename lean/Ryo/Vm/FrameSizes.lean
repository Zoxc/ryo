/-
Ryo.Vm.FrameSizes — a check of the decoded frame size that `Frame.decodeChecked` runs:
`frameSizesCheck`, on PE and without a frame pointer `F + 8 < 2 ^ 31` (PE's epilogue
`add rsp, F` and the return address above the saved `rbp`, or the no-frame-pointer prologue's
and epilogue's `sub/add rsp, F + 8`, as signed 32-bit immediates; `Decoded.boundsOk` gives `F ≤ 2 ^ 31`
only), and `peStackArgCheck`: the frame holds PE's bytes at its bottom (`shadowSize`: the
32-byte shadow space, and with a handler call's stack argument the 8 bytes above it).
`Ryo.Proofs.Discharge.FrameSizes` turns its success into `Hyps.peFrame`,
`Ryo.Proofs.Discharge.PeStackArg` into `Hyps.peStackArg`'s `36 ≤ F`.
-/
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.Vm.R Ryo.Vm.Asm

/-- The frame holds the bytes at its bottom that PE's callees may use (`shadowSize`: `0` off
PE, so true there). -/
def peStackArgCheck (d : R.Decoded) (mode : Mode) : Bool :=
  decide (d.shadowSize mode ≤ d.frameSize)

/-- On PE and without a frame pointer, the frame size and the return address fit a signed 32-bit displacement; and the frame
holds PE's shadow space and stack argument (`peStackArgCheck`). -/
def frameSizesCheck (d : R.Decoded) (mode : Mode) : Bool :=
  (!(mode.pe || !mode.framePointer) || decide (d.frameSize + 8 < 2 ^ 31)) && peStackArgCheck d mode

end Ryo.Vm
