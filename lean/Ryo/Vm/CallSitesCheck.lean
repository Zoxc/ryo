/-
Ryo.Vm.CallSitesCheck — a Lean-only check of the call sites against the decoder's read
(`callSitesCheck`, run by `Frame.decodeChecked`).

Neither `read` nor the image checks verify two facts about the call sites the landing-pad proof
needs (`Ryo.Proofs.Discharge.CallSites`): that no two share a start (`StartsDistinct`; checked as
starts strictly increasing, the order the writer, `lsda::write`, emits them in), and that a call
site whose return-address range `(start, start + len]` meets one of a read instruction's call
ranges starts where that one does (`SitesAligned`).
-/
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.X86 Ryo.Vm.R Ryo.Vm.Asm

/-- The call sites' starts strictly increase. -/
def startsSorted : List CallSite → Bool
  | [] => true
  | [_] => true
  | a :: b :: rest => decide (a.start < b.start) && startsSorted (b :: rest)

/-- Every call range `(s, s + n]` of every instruction and every call site whose return-address
range `(start, start + len]` meets it start at the same place. -/
def sitesAlignedOk (protos : Array Proto) (callSites : Array CallSite) : Bool :=
  protos.toList.all fun q => q.sites.all fun s => callSites.toList.all fun cs =>
    decide (s.1 < cs.start + cs.len → cs.start < s.1 + s.2 → 0 < s.2 → 0 < cs.len →
      cs.start = s.1)

/-- `startsSorted` for the call sites, and `sitesAlignedOk` for the instructions `read` gives. -/
def callSitesCheck (code : ByteArray) (relocs : Array Reloc) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) : Bool :=
  startsSorted callSites.toList &&
    match (read rodata callSites dropped.toList scopes mode).run
        ({ code := code.data, pos := 0, fields := .relocs relocs } : Cursor) with
    | .ok (r, _) => sitesAlignedOk r.protos callSites
    | .error _ => false

end Ryo.Vm
