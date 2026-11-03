/-
Ryo.Vm.RelocsInCheck — a Lean-only check that every relocated field lies within the
function's code (`relocsInCheck`, run by `Frame.decodeChecked`).

The decoder doesn't check it, and the object reader (`ImageObject.funcInputs`) keeps the
relocations that start in the function's range, so a field could straddle its end. The proofs
need each 4-byte field inside the code (`RelocsIn`; `Ryo.Proofs.Discharge.RelocsIn` turns the
check's success into `Hyps.relocsIn`).
-/
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.X86

/-- Every relocated field `[pos, pos + 4)` lies within the code. -/
def relocsInCheck (code : Array UInt8) (relocs : Array Reloc) : Bool :=
  relocs.toList.all fun r => decide (r.pos + 4 ≤ code.size)

end Ryo.Vm
