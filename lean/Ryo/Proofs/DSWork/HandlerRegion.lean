/-
Ryo.Proofs.DSWork.HandlerRegion — a handler call in PE's pad region (PE-T4.1,
`regionSim_handler`).

The handler's home space is at the region's `rsp + 8`, off the frame: `SepAcross.handlerAt` and
`HandlerContractB.sound` with `ho = rsp + 8 - fp` (below the window; `FrameOwn` there holds as
no live allocation is below the frame, `RegionInv.allocsOff`), then the cleared range moved to
R's `-F` (`hrel_clearHome_move`). `MayWrite` changes `[rsp + 8, rsp + 48)` (home space and
PE's fifth argument), the stack below, allocations and owned bytes: the trampoline's return
address at `rsp + 40` of the region (`RegionInv.tramp`) is above the call's `rsp + 8 + 32`
(`RegionInv.allocsOff`, `EnvApart.stackOff`). Successors stay in the region
(`RegionFacts.noCross`).
-/
import Ryo.Proofs.DSWork.Handler
import Ryo.Proofs.DecodeSound.Region

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- `opSem`'s relation with the home space cleared off the window (at `ho`, below `-F`) gives
the one with R's (at `-F`): the bytes cleared at `ho` aren't initialized (`FrameInit`), and
clearing more bytes keeps `HRel` (`Uninit` relates to anything). -/
theorem hrel_clearHome_move {F : Nat} {K : Int} {st' st1 st2 : OpSem.State} {x' : X86.State}
    {n : Nat} {ho : Int} (hinit : ScopeMem.FrameInit (-(F : Int)) K st')
    (hoff : ho + R.handlerHome true n ≤ -(F : Int))
    (h1 : R.clearHome true n ho st' = .ok st1) (hr : Handler.HRel st1 x')
    (h2 : R.clearHome true n (-(F : Int)) st' = .ok st2) : Handler.HRel st2 x' := by
  sorry -- PE-P12

/-- PE-T4.1: a handler call other than `resume` in PE's pad region (as `handler_general'B`). -/
theorem regionSim_handler (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hh : q.handler ≠ none) (hres : q.op ≠ .resume)
    (hnd : ∀ c'', (denseSwitch S.frR).run cur ≠ .ok (some q, c''))
    (htable : HdlTables S) :
    RegionSimB S k p := by
  sorry -- PE-P12

end Ryo.Proofs.DecodeSound
