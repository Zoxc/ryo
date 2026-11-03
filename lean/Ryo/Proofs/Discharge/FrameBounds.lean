/-
Ryo.Proofs.Discharge.FrameBounds — `FrameBounds c K` (the `Hyps` field `frameBounds`) from the
decoder's bound check and the window's end.

`DecodeLink.Bounds.frameBounds_of_boundsOk` gives `FrameBounds c frameTop` from
`Decoded.boundsOk` (which `decodeBounded`, and so `Frame.decodeChecked`, checks), and
`DecodeLink.Bounds.FrameBounds.mono` raises the end to any `K` with `frameTop ≤ K ≤ 2 ^ 31`.
The window's end is `Setup.K = 16 + argSize`; neither inequality follows from `Decodes`
(`argSize` is the image's, not an input of the decoder). `windowCheck` (`Ryo.Vm.StackSizes`) checks
both; check-image runs it on each function's `imageCode`, and
`frameBounds_of_window` gives `FrameBounds c (16 + argSize)` from it (the `Hyps` field
`windowOk`).

This file doesn't import `DecodeSound/Basic.lean`, so `Basic.lean` can import it and derive
`Hyps.frameBounds` from the fields replacing it.
-/
import Ryo.Proofs.DecodeLink.Bounds
import Ryo.Vm.StackSizes

namespace Ryo.Proofs.Discharge.FrameBounds

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.Asm Ryo.Proofs.FrameBounds

/-- `FrameBounds` for a window end between `frameTop` and `2 ^ 31`, from the bound check. -/
theorem frameBounds_of_boundsOk_le {c : R.Code} {K : Int}
    (hb : c.d.boundsOk c.mode = true) (hK : c.d.frameTop c.mode ≤ K) (hK' : K ≤ 2 ^ 31) :
    Ryo.Proofs.FrameBounds.FrameBounds c K :=
  Ryo.Proofs.DecodeLink.Bounds.FrameBounds.mono
    (Ryo.Proofs.DecodeLink.Bounds.frameBounds_of_boundsOk hb) hK hK'

/-- `FrameBounds` for the window `[-F, 16 + argSize)`, from the bound and window checks. -/
theorem frameBounds_of_window {c : R.Code}
    (hb : c.d.boundsOk c.mode = true) (hw : windowCheck c = true) :
    Ryo.Proofs.FrameBounds.FrameBounds c (16 + c.argSize) := by
  unfold windowCheck at hw
  rw [Bool.and_eq_true, decide_eq_true_eq, decide_eq_true_eq] at hw
  exact frameBounds_of_boundsOk_le hb hw.1 hw.2

/-- The same from `decodeBounded`'s acceptance of `c`'s decoding. -/
theorem frameBounds_of_decodeBounded {code : ByteArray} {fields : Ryo.X86.Fields}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Mode} {d : R.Decoded}
    (h : decodeBounded code fields rodata callSites dropped scopes mode = .ok d)
    {c : R.Code} (hc : c.d = d) (hm : c.mode = mode) {K : Int}
    (hK : d.frameTop mode ≤ K) (hK' : K ≤ 2 ^ 31) : Ryo.Proofs.FrameBounds.FrameBounds c K :=
  Ryo.Proofs.DecodeLink.Bounds.FrameBounds.mono
    (Ryo.Proofs.DecodeLink.Bounds.decode_frameBounds h hc hm).2 hK hK'

end Ryo.Proofs.Discharge.FrameBounds
