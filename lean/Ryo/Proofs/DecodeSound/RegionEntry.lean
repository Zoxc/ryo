/-
Ryo.Proofs.DecodeSound.RegionEntry — PE's pad region entered from a cleanup site (PE-T2.1).

- `reach_regionPad`: an unwind out of a call or island at a PE cleanup site comes back through
  the dispatcher's trampoline at the region's entry (`Call.PadCalled`); its `sub rsp, 40;
  jmp r11` (`RegionFacts.start`, at a relocation boundary by `regionEntry_boundary`) reaches the
  pad with `RegionInv` (entered at the trampoline's state) and the empty cache
  (`CacheCleared.pads`).
-/
import Ryo.Proofs.DecodeSound.Region
import Ryo.Proofs.Discharge.PadsLinked

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- From a `PadCalled` return out of a call or island (entry state `x1`, its return address in
instruction `k`'s call site `site`) with the frame relation at the pad's R state (`FrameCore`):
the region's entry `sub rsp, 40; jmp r11` reaches the pad with `RegionInv` (entered at `y`). -/
theorem reach_regionPad (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {s' : R.RState} {x1 y : X86.State} {exc : ThinPointer} {k pad : Nat}
    {site : Nat × Nat} (hpe : S.c.mode.pe = true) (hk : k < S.r.protos.size)
    (hcl : S.c.cleanupAt k = some (some pad, false)) (hpc : s'.pc = pad)
    (hsite : site ∈ S.r.protos[k].sites)
    (hra : x1.mem.read64 x1.rsp = addrAt S.ctx (site.1 + site.2)) (hn : 0 < site.2)
    (hP : Call.PadCalled S.padOf S.region S.lo x1 y exc)
    (hcore : FrameCore S s' y)
    (hbelow : x1.rsp.toNat ≤ (y.reg .rbp).toNat - S.F) :
    Reach S.ctx S.E (RBInv S s') y := by
  sorry -- PE-P4

end Ryo.Proofs.DecodeSound
