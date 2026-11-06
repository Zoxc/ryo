/-
Ryo.Proofs.DSWork.ResumeRegion — `resume` in PE's pad region (PE-T4.3, `regionSim_resume`).

`add rsp, 40; ret` (`InsnRead.resume`): `rsp` back to the trampoline's entry `e.rsp`, `ret` to its
return address (`RegionInv.tramp`). R: `resumeSlots` made the instruction
`handler .resume [.slot x] .trap` (`S.fixResume`), whose step reads the slot and, with
`cleanupAt k = some (none, false)` (`RegionFacts.resume`), ends the function with
`.unwind exc`: `ExitRel`'s `unwind` from `FrameFacts` (the saved `rbp` and the return address,
memory unchanged by the two items). A handler-form `resume` (a call of `ryo_h_Resume`) never
returns on PE (`Hyps.resumePe`).
-/
import Ryo.Proofs.DSWork.Handler
import Ryo.Proofs.DecodeSound.Region

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- PE-T4.3: `resume` in PE's pad region, either form. -/
theorem regionSim_resume (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hres : q.op = .resume) :
    RegionSimB S k p := by
  sorry -- PE-P14

end Ryo.Proofs.DecodeSound
