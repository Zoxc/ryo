/-
Ryo.Proofs.Discharge.FrameBounds — `FrameBounds c K` (the `Hyps` field `frameBounds`) from the
decoder's bound check and the window's end.

`DecodeLink.Bounds.frameBounds_of_boundsOk` gives `FrameBounds c frameTop` from
`Decoded.boundsOk` (which `decodeBounded`, and so `Frame.decodeChecked`, checks), and
`DecodeLink.Bounds.FrameBounds.mono` raises the end to any `K` with `frameTop ≤ K ≤ 2 ^ 31`.
Neither inequality follows from `Decodes` or the `Setup`: `K` is a free field of the `Setup`
(the window's end above `fp`), and `Hyps.argSizeK` only bounds it from below by
`16 + argSize`. Both are facts of the function entry (the image checker's `checkSignature`
checks `frameTop ≤ 16 + argSize ≤ 2 ^ 31`), so with `K = 16 + argSize` they hold.

This file doesn't import `DecodeSound/Basic.lean`, so `Basic.lean` can import it and derive
`Hyps.frameBounds` from the fields replacing it.
-/
import Ryo.Proofs.DecodeLink.Bounds

namespace Ryo.Proofs.Discharge.FrameBounds

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.Asm Ryo.Proofs.FrameBounds

/-- `FrameBounds` for a window end between `frameTop` and `2 ^ 31`, from the bound check. -/
theorem frameBounds_of_boundsOk_le {c : R.Code} {K : Int}
    (hb : c.d.boundsOk c.mode = true) (hK : c.d.frameTop c.mode ≤ K) (hK' : K ≤ 2 ^ 31) :
    Ryo.Proofs.FrameBounds.FrameBounds c K :=
  Ryo.Proofs.DecodeLink.Bounds.FrameBounds.mono
    (Ryo.Proofs.DecodeLink.Bounds.frameBounds_of_boundsOk hb) hK hK'

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
