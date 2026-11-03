/-
Ryo.Vm.CacheClearedCheck — a Lean-only check that the register cache the decoder used is empty
wherever control arrives other than by falling through (`cacheClearedCheck`, run by
`Frame.decodeChecked`).

`read` decodes the body twice: the first pass (no targets) collects the branch targets, the
second clears the cache at them (`instructions` with `some targets`). Nothing makes the second
pass's own targets a subset of the first's (its inline sequences may differ), and nothing clears
the cache at a landing pad. The check reruns the first pass (`readTargets`, `read`'s prefix up
to its targets) and `read`, and accepts if (`cacheClearedOk`)

- every target of every instruction of the second pass is one of the first pass's
  (`targetsIn`), and
- every cleanup landing pad `pad` (`Decoded.cleanup`) is at a first-pass target, or is
  instruction 0, or follows an instruction that leaves the cache empty (`clearsCache`: neither
  an `arg`, which keeps it, nor an opcode with an inline form, the only ones `inlineInsn`
  reads; a call or any other instruction `insn` reads empties it) (`padsCleared`).

`Ryo.Proofs.Discharge.CacheCleared` turns its success into `CacheCleared`.
-/
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.X86 Ryo.Vm.R Ryo.Vm.Asm DM

/-- `read`'s first pass and its sorted branch targets: `read`'s code up to its `targets`. -/
def readTargets (ro : ByteArray) (callSites : Array CallSite) (dropped : List DroppedStore)
    (mode : Mode) : DM (Array Nat) := do
  let (entry, frameSize) ← readFrame mode
  let fr : Frame := ⟨frameSize, mode, false⟩
  let size := (← get).code.size
  let regionAt ← regionEntry mode callSites
  let limit := regionAt.getD size
  let droppedBody := match regionAt with
    | some r => dropped.takeWhile (·.at_ < r)
    | none => dropped
  let droppedRegion := match regionAt with
    | some r => dropped.dropWhile (·.at_ < r)
    | none => []
  let body ← pos
  let stubs := entry.map (·.1)
  let (protos1, _, _) ← readParts fr ro callSites droppedBody droppedRegion stubs regionAt body
    limit size none
  return (protos1.toList.flatMap Proto.targets).toArray.qsort (· < ·)

/-- Every target of every instruction is in `targets` (sorted). -/
def targetsIn (protos : Array Proto) (targets : Array Nat) : Bool :=
  protos.toList.all fun q => q.targets.all (sortedContains targets ·)

/-- The instruction leaves the cache empty: it isn't an `arg` and has no inline form. -/
def clearsCache (q : Proto) : Bool :=
  q.op != .arg && (classOf q.op).isNone

/-- The cache is empty at instruction `pad`: at a target, the first instruction, or after one
that empties it. -/
def padCleared (protos : Array Proto) (targets : Array Nat) (pad : Nat) : Bool :=
  sortedContains targets ((protos.map (·.pos))[pad]!) ||
    match pad with
    | 0 => true
    | j + 1 => match protos[j]? with
      | some q => clearsCache q
      | none => false

/-- `padCleared` at every cleanup landing pad. -/
def padsCleared (protos : Array Proto) (cleanup : Array (Nat × Option Nat × Bool))
    (targets : Array Nat) : Bool :=
  cleanup.toList.all fun e => match e.2.1 with
    | some pad => padCleared protos targets pad
    | none => true

/-- The check on a read's instructions, its cleanup entries and the first pass's targets. -/
def cacheClearedOk (protos : Array Proto) (cleanup : Array (Nat × Option Nat × Bool))
    (targets : Array Nat) : Bool :=
  targetsIn protos targets && padsCleared protos cleanup targets

/-- `cacheClearedOk` for the first pass's targets, `read`'s instructions and the cleanup entries
of their R form (`reducedOf`). -/
def cacheClearedCheck (code : ByteArray) (relocs : Array Reloc) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) : Bool :=
  match (readTargets rodata callSites dropped.toList mode).run
      ({ code := code.data, pos := 0, fields := .relocs relocs } : Cursor) with
  | .error _ => false
  | .ok (ts, _) =>
    match (read rodata callSites dropped.toList scopes mode).run
        ({ code := code.data, pos := 0, fields := .relocs relocs } : Cursor) with
    | .error _ => false
    | .ok (r, _) =>
      match reducedOf r mode.pe with
      | .error _ => false
      | .ok d => cacheClearedOk r.protos d.cleanup ts

end Ryo.Vm
