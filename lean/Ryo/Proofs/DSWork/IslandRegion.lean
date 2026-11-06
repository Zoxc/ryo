/-
Ryo.Proofs.DSWork.IslandRegion — an island in PE's pad region (PE-T3, `regionSim_island`).

As `bodySim_islandB`: the island's query has no `sp` and `IslandAtB` no `rsp`; the template
writes below `rsp + 8 + 32` (`IslandEnd.mem`), off the frame (`RegionInv.below`) and the
trampoline's return address (`RegionInv.allocsOff`, `EnvApart.stackOff`). R's `islandShadow`
clears frame bytes as in the body. Unwinds as for calls (`regionSim_call`).
-/
import Ryo.Proofs.DSWork.Island
import Ryo.Proofs.DecodeSound.RegionEntry

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- PE-T3: an island in PE's pad region. -/
theorem regionSim_island (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hop : q.op = .island) :
    RegionSimB S k p := by
  sorry -- PE-P11

end Ryo.Proofs.DecodeSound
