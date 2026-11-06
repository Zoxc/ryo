/-
Ryo.Vm.StackSizes — a Lean-only check of the calls' stack-argument areas against the frame
(`stackSizesCheck`). Unlike `frameSizesCheck` it reads an `R.Code`, not just the decoding: the
areas (`Code.stackSize`, in `imageProgram` the callee's `FuncEntry::arg_size`) come from the
image, which the decoder doesn't see, so `Frame.decodeChecked` can't run it; check-image (or
whatever builds the `R.Code`s) does. `Ryo.Proofs.Discharge.StackSizes` turns its success into
`StackSizes` (and `Hyps.peShadow`, `32 ≤ F`). `windowCheck`, the frame window's end against the
incoming area, reads the image's `argSize` the same way.

It checks: on PE `32 ≤ F`; for every instruction `k`, its area fits in the frame with PE's 16
bytes of return address and alignment (`StackSizes.frame`), and on PE a call's holds the
32-byte shadow space (`StackSizes.shadow`). `StackSizes.stack` (`F + n < 2 ^ 62`) follows from
`frame` and `F ≤ 2 ^ 31` (`boundsOk`). And `argSlotsCheck`: on PE with a handler call's stack
argument (`shadowSize` 40, the argument at `[-F + 32, -F + 40)`, below `frameLo`), every call's
area is the 32-byte shadow space only, so a call's answer, which rewrites the area
(`R.answer`), leaves the argument's bytes private and `Uninit` (`FrameInv.slots`). And
`regionCallsCheck`: a call in PE's pad region (`Code.inRegion`) has the shadow space only (no
stack arguments; `StackSizes.region`): there the area is on the dispatcher's stack at the
region's `rsp`, 40 bytes below the trampoline's return address (`RegionInv.tramp`), which a
callee writing below `sp + n` would otherwise reach. The backend keeps a function with such a
call native (`lower/call.rs`).
-/
import Ryo.Vm.R.Sem
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.Vm.R

/-- A native instruction of the `call` shape (`StackSizes.shadow`'s premise). -/
def R.Insn.isCall : R.Insn → Bool
  | .native op _ => match op.full with
    | some f => decide (f.info.shape = .call)
    | none => false
  | .handler .. => false

/-- On PE with a handler call's stack argument, every call's stack area is at most the shadow
space (see the module comment). -/
def argSlotsCheck (c : R.Code) : Bool :=
  decide (c.d.shadowSize c.mode ≤ 32) ||
    (List.range c.d.insns.size).all fun k =>
      !((c.d.insns[k]?.map R.Insn.isCall).getD false) || decide (c.stackSize k ≤ 32)

/-- PE's pad region: a call there has no stack arguments, its area the 32-byte shadow space only
(see the module comment). -/
def regionCallsCheck (c : R.Code) : Bool :=
  (List.range c.d.insns.size).all fun k =>
    !c.inRegion k || !((c.d.insns[k]?.map R.Insn.isCall).getD false) ||
      decide (c.stackSize k ≤ 32)

/-- The calls' stack-argument areas fit in the frame (see the module comment). -/
def stackSizesCheck (c : R.Code) : Bool :=
  ((!c.mode.pe || decide (32 ≤ c.d.frameSize)) &&
    (List.range c.d.insns.size).all fun k =>
      decide (c.stackSize k + (if c.mode.pe then 16 else 0) ≤ c.d.frameSize) &&
        (!c.mode.pe || !((c.d.insns[k]?.map R.Insn.isCall).getD false) ||
          decide (32 ≤ c.stackSize k))) &&
    (argSlotsCheck c && regionCallsCheck c)

/-- The window check: the frame ranges end no higher than the incoming area's end
`16 + argSize`, itself at most `2 ^ 31` (`Hyps.windowOk`: with `boundsOk` it gives the window's
`FrameBounds`, `Ryo.Proofs.Discharge.FrameBounds`). Like `stackSizesCheck` it reads the image's
`argSize`, so check-image runs it. -/
def windowCheck (c : R.Code) : Bool :=
  decide (c.d.frameTop c.mode ≤ 16 + (c.argSize : Int)) && decide (16 + (c.argSize : Int) ≤ 2 ^ 31)

end Ryo.Vm
