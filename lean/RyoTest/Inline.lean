/-
RyoTest.Inline — the link between `Asm.inlineOps` and the inline-sequence theorems
(`Ryo/Proofs/Inline.lean`): every opcode with an inline form has its class's shape
(`shapeOk`: handler kind and parameters, operands), so the theorems, stated for every opcode
of that shape, cover it. Not proved: `inlineOps` is computed with `String.splitOn`, which the
kernel doesn't reduce.
-/
import RyoTest.Harness
import Ryo.Proofs.Inline.Shape

namespace RyoTest.Inline

open Ryo.Vm Ryo.Proofs.Inline

def shapes : Except String Unit := do
  let bad := Asm.inlineOps.filter fun (op, c) => !shapeOk op c
  if !bad.isEmpty then
    throw s!"opcodes not of their inline class's shape: {bad.map (·.1.mnemonic)}"
  if Asm.inlineOps.isEmpty then throw "no inline opcodes"

def tests : List TestCase := [
  ⟨"Inline/shapes", fun _ => shapes⟩,
]

end RyoTest.Inline
