/-
Ryo.Vm.StackSizes — a Lean-only check of the calls' stack-argument areas against the frame
(`stackSizesCheck`). Unlike `frameSizesCheck` it reads an `R.Code`, not just the decoding: the
areas (`Code.stackSize`, in `imageProgram` the callee's `FuncEntry::arg_size`) come from the
image, which the decoder doesn't see, so `Frame.decodeChecked` can't run it; check-image (or
whatever builds the `R.Code`s) does. `Ryo.Proofs.Discharge.StackSizes` turns its success into
`StackSizes` (and `Hyps.peShadow`, `32 ≤ F`).

It checks: on PE `32 ≤ F`; for every instruction `k`, its area fits in the frame with PE's 16
bytes of return address and alignment (`StackSizes.frame`), and on PE a call's holds the
32-byte shadow space (`StackSizes.shadow`). `StackSizes.stack` (`F + n < 2 ^ 62`) follows from
`frame` and `F ≤ 2 ^ 31` (`boundsOk`).
-/
import Ryo.Vm.R.Sem

namespace Ryo.Vm

open Ryo.Vm.R

/-- A native instruction of the `call` shape (`StackSizes.shadow`'s premise). -/
def R.Insn.isCall : R.Insn → Bool
  | .native op _ => match op.full with
    | some f => decide (f.info.shape = .call)
    | none => false
  | .handler .. => false

/-- The calls' stack-argument areas fit in the frame (see the module comment). -/
def stackSizesCheck (c : R.Code) : Bool :=
  (!c.mode.pe || decide (32 ≤ c.d.frameSize)) &&
    (List.range c.d.insns.size).all fun k =>
      decide (c.stackSize k + (if c.mode.pe then 16 else 0) ≤ c.d.frameSize) &&
        (!c.mode.pe || !((c.d.insns[k]?.map R.Insn.isCall).getD false) ||
          decide (32 ≤ c.stackSize k))

end Ryo.Vm
