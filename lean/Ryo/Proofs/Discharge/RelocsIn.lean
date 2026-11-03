/-
Ryo.Proofs.Discharge.RelocsIn — `RelocsIn` (`DecodeSound/Basic.lean`: every relocated field
lies within the code) from the Lean-only check `relocsInCheck` (`Ryo/Vm/RelocsInCheck.lean`,
run by `Frame.decodeChecked`).

- `relocsIn_of_check`: the check's success gives the bound for every relocation.
- `Hyps.relocsIn`: `RelocsIn S` from `Hyps.relocsInOk`.
- `relocsInOk_of_decodes`: `decodeChecked`'s check on its inputs (`decodeChecked_ok`) is
  `Hyps.relocsInOk` for a `Setup` that is their read (`Decodes`).
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Vm.RelocsInCheck

namespace Ryo.Proofs.DecodeSound

open Ryo.Vm Ryo.Vm.Asm Ryo.X86 Ryo.Vm.R Ryo.Proofs.DecodeLink

/-- `relocsInCheck`'s success: every relocated field ends within the code. -/
theorem relocsIn_of_check {code : Array UInt8} {rs : Array Reloc}
    (h : relocsInCheck code rs = true) : ∀ r ∈ rs.toList, r.pos + 4 ≤ code.size := by
  intro r hr
  simp only [relocsInCheck, List.all_eq_true, decide_eq_true_eq] at h
  exact h r hr

/-- Every relocated field lies within the code, from `relocsInCheck`. -/
theorem Hyps.relocsIn {S : Setup} (H : Hyps S) : RelocsIn S :=
  relocsIn_of_check H.relocsInOk

/-- `decodeChecked`'s `relocsInCheck` on the function's inputs gives `Hyps.relocsInOk` for
their read. -/
theorem relocsInOk_of_decodes {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (h : relocsInCheck code.data relocs = true) : relocsInCheck S.body.code S.rs = true := by
  have hc : S.body.code = code.data := (congrArg Cursor.code hD.bodyEq).trans rfl
  rw [hc, hD.rsEq]
  exact h

end Ryo.Proofs.DecodeSound
