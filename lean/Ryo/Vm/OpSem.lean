/-
Ryo.Vm.OpSem — the shared operation semantics of the VM's opcodes (reduced.md Part D):
`opSem` per handler kind, on abstract bytes with provenance, and each opcode's footprint
(the JIT's exact handler effect tables, jit.md §E.7).

- `OpSem/Basic`: operands (`Val`), the state (private frame bytes, escaped objects, L0
  memory), `Stop`, `Control`, `Choice`.
- `OpSem/Footprint`: `footprint`, from the generated handler table.
- `OpSem/Arith`: the integer and float operations by Rust method name.
- `OpSem/Sem`: `kindSem` and `opSem`.
- `OpSem/Lemmas`: `opSem` writes the frame only inside its footprint.
- `OpSem/Json`: `ryo-lean opsem`, for the differential test against the handlers.
- `OpSem/JitEffects`: `ryo-lean effects`, the JIT's handler effect table from the footprints.
-/
import Ryo.Vm.OpSem.Basic
import Ryo.Vm.OpSem.Footprint
import Ryo.Vm.OpSem.Arith
import Ryo.Vm.OpSem.Sem
import Ryo.Vm.OpSem.Lemmas
import Ryo.Vm.OpSem.Json
import Ryo.Vm.OpSem.JitEffects
