/-
Ryo.Proofs.DSWork.InlineRegion — inline code, dense switches, `jmp` and `unreachable` in PE's pad
region (PE-T4.2).

After the mid-level lemmas take `FrameCore` (PE-T4.0) the x86 run and the frame of
`bodySim_inline'`/`bodySim_denseB` apply to the region's state itself; `rsp` is kept, and the
trampoline's return address isn't a frame range or a live allocation (`RegionInv.allocsOff`).
Branch targets stay in the region (`RegionFacts.noCross`).
-/
import Ryo.Proofs.DSWork.Inline
import Ryo.Proofs.Dense
import Ryo.Proofs.DecodeSound.Region

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- PE-T4.2: an inline instruction (without a dropped store) in PE's pad region. -/
theorem regionSim_inline (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur cur' c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore}
    (hP : ProtoFactsR S k p q c' cache') (hn : NoArg S.frR S.body p a cur)
    (hc : (callInsn S.frR (S.dr k)).run cur = .ok (none, cur'))
    (hr : (inlineInsn (S.used k) (S.dr k) true).run cur' = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) :
    RegionSim S k p (S.used k) := by
  sorry -- PE-P13

/-- PE-T4.2: a dense switch in PE's pad region (as `bodySim_denseB`). -/
theorem regionSim_dense (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : (denseSwitch S.frR).run cur = .ok (some q, c')) (htable : HdlTables S) :
    RegionSimB S k p := by
  sorry -- PE-P13

/-- PE-T4.2: a `jmp` in PE's pad region (as `bodySim_jmpB`; the target is in the region,
`RegionFacts.noCross`). -/
theorem regionSim_jmp (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hop : q.op = .jmp) :
    RegionSimB S k p := by
  sorry -- PE-P13

/-- PE-T4.2: a bare `unreachable` in PE's pad region (R's step is an error, excluded by
`RSafe`; as `bodySim_unreachableB`). -/
theorem regionSim_unreachable (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hop : q.op = .unreachable) :
    RegionSimB S k p := by
  sorry -- PE-P13

end Ryo.Proofs.DecodeSound
