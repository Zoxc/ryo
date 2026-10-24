/-
RyoTest.DecodeReduced — `Ryo.Vm.decodeReduced` against Rust's `asm::decode_reduced`, over the
vectors of `vm/bytecode/tests/lean_reduced_vectors.rs` (`RyoTest/DecodeReducedVectors.lean`):
for every encoded function and every mutation of one, the same text (`Decoded.toText`: frame
size, the code as `reduced::Disasm` prints it, cleanup entries, scopes, dropped stores, loop
heads), or the same error at the same byte.

Also: the inline classes (`classOf`) are exactly the generated `hasInline` opcodes; and the
dead-store check (`Ryo.Vm.Frame.droppedNotDead`) accepts every dropped store of the functions
encoded without dead-slot hints (whose dropped stores are all overwritten before any read).
-/
import RyoTest.Harness
import RyoTest.DecodeReducedVectors
import Ryo.Vm.DecodeReduced
import Ryo.Vm.Frame

namespace RyoTest.DecodeReduced

open Lean Ryo.Vm Ryo.Vm.Asm Ryo.X86

/-- A vector: the inputs and Rust's text. -/
structure Vector where
  name : String
  inputs : Inputs
  out : String
  /-- Its dropped stores are all overwritten (encoded without dead-slot hints). -/
  soundDrops : Bool := false
deriving Inhabited

def parseSites (j : Json) : Except String (Array CallSite) := do
  (← j.getArr?).mapM fun r => do
    let start ← (← r.getArrVal? 0).getNat?
    let len ← (← r.getArrVal? 1).getNat?
    let pad : Option Nat ← fromJson? (← r.getArrVal? 2)
    let catches ← (← r.getArrVal? 3).getBool?
    pure { start, len, pad, catches }

def parseDropped (j : Json) : Except String (Array DroppedStore) := do
  (← j.getArr?).mapM fun r => do
    let at_ ← (← r.getArrVal? 0).getNat?
    let off ← i32OfJson (← r.getArrVal? 1)
    let size ← (← r.getArrVal? 2).getNat?
    let reg ← (← r.getArrVal? 3).getNat?
    match DroppedStore.ofParts? at_ off size reg with
    | some d => pure d
    | none => throw "bad dropped store"

/-- The vectors, mutations applied to their base. -/
def vectors : Except String (Array Vector) := do
  let j ← Json.parse DecodeReducedVectors.json
  let mut bases : Array Inputs := #[]
  let mut out : Array Vector := #[]
  for (v, k) in (← j.getArr?).zipIdx do
    let text ← v.getObjValAs? String "out"
    match v.getObjVal? "in" with
    | .ok i =>
      let inputs ← Inputs.ofJson i
      bases := bases.push inputs
      let sound := (v.getObjValAs? Bool "sound_drops").toOption.getD false
      out := out.push ⟨s!"#{k} (function {bases.size - 1})", inputs, text, sound⟩
    | .error _ =>
      let b ← v.getObjValAs? Nat "base"
      let some base := bases[b]? | throw s!"vector {k}: no base {b}"
      let mut i := base
      if let .ok sets := v.getObjVal? "code_set" then
        for s in ← sets.getArr? do
          let p ← (← s.getArrVal? 0).getNat?
          let x ← (← s.getArrVal? 1).getNat?
          i := { i with code := i.code.set! p (UInt8.ofNat x) }
      if let .ok n := v.getObjValAs? Nat "code_len" then
        i := { i with code := i.code.extract 0 n }
      if let .ok s := v.getObjVal? "call_sites" then
        i := { i with callSites := ← parseSites s }
      if let .ok d := v.getObjVal? "dropped" then
        i := { i with dropped := ← parseDropped d }
      out := out.push ⟨s!"#{k} (mutation of {b}: {v.compress.take 200})", i, text, false⟩
  return out

/-- Checks the vectors `lo .. hi`. -/
def checkRange (lo hi : Nat) : Except String Unit := do
  let vs ← vectors
  let mut bad : Array String := #[]
  for v in vs.extract lo hi do
    let got := decodeText v.inputs.decode
    if got != v.out then
      bad := bad.push s!"{v.name}:\n--- rust\n{v.out}--- lean\n{got}"
  if bad.isEmpty then return
  throw s!"{bad.size} vectors differ; the first:\n{bad[0]!}"

def chunk : Nat := 500

def vectorCount : Nat := match vectors with
  | .ok v => v.size
  | .error _ => 0

def classes : Except String Unit := do
  for op in Ryo.Vm.Full.all do
    if (classOf op).isSome != op.hasInline then
      throw s!"{op.mnemonic}: class {repr (classOf op)}, has_inline {op.hasInline}"

/-- The dead-store check accepts the overwritten stores. -/
def soundDrops : Except String Unit := do
  let mut n := 0
  for v in ← vectors do
    if !v.soundDrops then continue
    let .ok d := v.inputs.decode | throw s!"{v.name} doesn't decode"
    n := n + d.dropped.size
    let bad ← Frame.droppedNotDead d v.inputs.mode
    if !bad.isEmpty then throw s!"{v.name}: dropped stores {bad} not shown dead\n{d.toText}"
  if n < 20 then throw s!"only {n} dropped stores checked"

def tests : List TestCase :=
  [⟨"decode_reduced/classes", fun _ => classes⟩,
   ⟨"decode_reduced/dropped stores dead", fun _ => soundDrops⟩,
   ⟨"decode_reduced/parse", fun _ => do
      let vs ← vectors
      if vs.size == 0 then throw "no vectors"⟩] ++
  (List.range ((vectorCount + chunk - 1) / chunk)).map fun k =>
    ⟨s!"decode_reduced/vectors {k * chunk}..{(k + 1) * chunk}", fun _ => checkRange (k * chunk) ((k + 1) * chunk)⟩

end RyoTest.DecodeReduced
