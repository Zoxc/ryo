/-
The JIT's handler effect table, generated from opSem's footprints
(`Ryo/Vm/OpSem/JitEffects.lean`, `ryo-lean effects`, written to
`vm/bytecode/src/jit/effects_table.rs`; reduced.md Part D, jit.md §E.7): the mapping's cases on
known opcodes, and that every opcode maps. `y lean` checks the Rust file is up to date;
`vm/rt/tests/ops.rs` checks the table against the handlers themselves.
-/
import RyoTest.Harness

namespace RyoTest.Effects

open Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.OpSem.JitEffects

/-- Every opcode maps; those with a handler (a footprint, or an override) have effects. -/
def table : Except String Unit := do
  let t ← JitEffects.table
  check (t.length == Full.count) "the table's length differs from Full.count"
  let n := (t.filter (·.2.isSome)).length
  check (n > 600) s!"only {n} opcodes have effects"
  check ((t.find? (·.1.info.mnemonic == "resume")).bind (·.2) |>.isSome) "resume has effects"

/-- The mapping's cases, on known opcodes. -/
def mapping : Except String Unit := do
  let e (m : String) : Except String Effects := do
    let some op := Full.Opcode.ofMnemonic? m | throw s!"no opcode {m}"
    let some fp := footprint op | throw s!"{m}: no footprint"
    jitEffects op fp
  check ((← e "add.w32") == { opnds := [some (.write 4), some (.read 4), some (.read 4)], memory := false })
    "add.w32"
  check ((← e "addr").opnds.contains (some .addr)) "addr"
  check ((← e "copy").opnds.contains (some .block)) "copy is a block"
  check (← e "load.w32").memory "load touches memory"
  check (← e "fence.seqcst").memory "a fence orders memory"
  check (!(← e "addr.sym.ind").memory) "addr.sym.ind reads read-only image data"
  check (!(← e "switch.sparse.w32").memory) "switch.sparse reads read-only image data"

def tests : List TestCase := [
  ⟨"Effects/mapping", fun _ => mapping⟩,
  ⟨"Effects/table", fun _ => table⟩,
]

end RyoTest.Effects
