/-
Ryo.Proofs.DSWork.CallRegion — a call in PE's pad region (PE-T3, `regionSim_call`).

The outgoing area is on the dispatcher's stack at the region's `rsp` (R's query with the choice's
`sp`, `Uninit` stack bytes: `Call.call_query_region`), at most the shadow space
(`StackSizes.region`), so the callee's writes below `rsp + 32` miss the frame
(`Call.FrameSep.callApartR`, `RegionInv.below`) and the trampoline's return address
(`RegionInv.tramp`; `RegionInv.allocsOff`, `EnvApart.stackOff`). The return comes back to
`RegionInv` at `k + 1` with the same entry; an unwind at a region cleanup site re-enters the
region (`reach_regionPad`, a nested trampoline), at a catching pad lands with `rsp` the
region's, and else leaves no return (no pad: `PadsLinked`). No tail call (`region_shape`).
-/
import Ryo.Proofs.DSWork.Call
import Ryo.Proofs.DecodeSound.RegionEntry

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- PE-T3: a call in PE's pad region. -/
theorem regionSim_call (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : (callInsn S.frR (S.dr k)).run cur = .ok (some q, c')) :
    RegionSimB S k p := by
  sorry -- PE-P10

end Ryo.Proofs.DecodeSound
