/-
RyoTest.Tables — the generated-table facts the proofs state but don't kernel-check (they compare
`String`s), evaluated over every opcode:

- `footprintNamesOk` (`DeadStore/RStep.lean`'s `footprintNamesTable`);
- `footprintOf_names`: each handler's footprint names what `namesOf` / `addrsOf` say;
- `DeadStore/DropForm.lean`'s `reduced_operandsTable`: a reduced opcode has its full opcode's
  operands.

`hasInline_classOf` (`RStep.lean`) is `decode_reduced/classes` (`RyoTest/DecodeReduced.lean`).
-/
import RyoTest.Harness
import Ryo.Proofs.DeadStore.Names

namespace RyoTest.Tables

open Ryo.Vm Ryo.Proofs.DeadStore

def footprintNames : Except String Unit := do
  for op in Full.all do
    if !footprintNamesOk op then throw s!"{op.mnemonic}: footprintNamesOk"

def footprintOfNames : Except String Unit := do
  for op in Full.all do
    let some h := op.handler? | continue
    let some fp := OpSem.footprintOf h.kind h.params | continue
    if (fp.reads ++ fp.writes).map (fun a => (a.opnd, extentNames a.extent)) != namesOf h.kind then
      throw s!"{op.mnemonic}: footprint names differ from namesOf"
    if fp.addrs != addrsOf h.kind then
      throw s!"{op.mnemonic}: footprint addresses differ from addrsOf"

def reducedOperands : Except String Unit := do
  let ok := (List.range Reduced.ofFullTable.size).all fun i =>
    (Reduced.ofFullTable[i]!).all fun op =>
      op.info.operands == (Full.Opcode.info ⟨i.toUInt16⟩).operands
  if !ok then throw "a reduced opcode's operands differ from its full opcode's"

def tests : List TestCase :=
  [⟨"tables/footprintNamesOk", fun _ => footprintNames⟩,
   ⟨"tables/footprintOf names", fun _ => footprintOfNames⟩,
   ⟨"tables/reduced operands", fun _ => reducedOperands⟩]

end RyoTest.Tables
