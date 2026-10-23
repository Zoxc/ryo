/-
Ryo.Spec.Mem.AbstractByte — abstract bytes and allocation kinds.

Ports: MiniRust `mem/interface.md` (`ProvenanceFrag`, `AbstractByte`, `AllocationKind`).

Differences: `AllocationKind` splits MiniRust's `Global` into `static` and `const` (D7: copies
of constant allocations have no unique address and are read-only) and has `threadLocal` (D22).
-/
import Ryo.Spec.Mem.Pointer

namespace Ryo.Spec

open Lean

/-- A one-byte fragment of a pointer's provenance: which allocation, and which byte of the
pointer this was. -/
structure ProvenanceFrag where
  prov : Provenance
  pos : Nat
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

inductive AbstractByte where
  | uninit
  | init (b : UInt8) (frag : Option ProvenanceFrag)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

namespace AbstractByte

def data : AbstractByte → Option UInt8
  | uninit => none
  | init b _ => some b

def provFrag : AbstractByte → Option ProvenanceFrag
  | uninit => none
  | init _ f => f

def ofByte (b : UInt8) : AbstractByte := init b none

end AbstractByte

inductive AllocationKind where
  /-- A stack variable (a MIR local). -/
  | stack
  /-- Heap memory from the allocator shims (D21). -/
  | heap
  /-- A `static` (unique address). -/
  | static
  /-- A copy of a constant allocation (D7). -/
  | const
  /-- A `#[thread_local]` static (D22; single thread, so one instance). -/
  | threadLocal
  /-- A function: zero-size allocation used as the target of function pointers (D6). -/
  | function
  /-- A copy of a vtable allocation (D29). -/
  | vtable
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

end Ryo.Spec
