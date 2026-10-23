/-
Ryo.Spec.Mem.Basic — the basic memory model: allocations with concrete addresses and
per-allocation provenance.

Ports: MiniRust `mem/basic.md` (`Allocation`, `BasicMemory`, `overlaps`, `allocate`,
`deallocate`, `check_ptr`, `load`, `store`, `dereferenceable`) and `mem/interface.md`
(`signed_dereferenceable`).

Differences:
- No `class Memory` (mir-spec §A.2.3): this is the one memory model. No `Atomicity` (D17: atomics
  are plain accesses), no frame/alloc extras (D16: no aliasing model), no leak check.
- D7: `Allocation.mutable`; a non-empty store into an immutable allocation (constants,
  immutable statics, vtables, functions) is UB.
- D8: allocations of size 0 never overlap anything (MiniRust: equal addresses count as
  overlap), so zero-size allocations may share an address.
- Operations return `Except Outcome`; `allocate` asks the oracle (`MonadChoice`) for the
  address and checks the answer (daemonic: a bad answer is `noBehavior`).
-/
import Ryo.Spec.Mem.AbstractByte
import Ryo.Spec.Prelude.Outcome
import Ryo.Spec.Prelude.Nondet

namespace Ryo.Spec

structure Allocation where
  data : Array AbstractByte
  addr : Nat
  align : Align
  kind : AllocationKind
  live : Bool := true
  /-- D7: writes are UB when `false`. -/
  mutable : Bool := true
  /-- D7, D29: vtable allocations are always read-only (`store_load` relies on it: a value's
  validity reads the vtable its metadata points to). -/
  vtableRo : kind = .vtable → mutable = false

instance : Inhabited Allocation :=
  ⟨{ data := #[], addr := 0, align := default, kind := .heap, mutable := true,
     vtableRo := by simp }⟩

instance : Repr Allocation where
  reprPrec a _ := s!"\{ data := {repr a.data}, addr := {a.addr}, align := {repr a.align}, kind := {repr a.kind}, live := {a.live}, mutable := {a.mutable} }"

namespace Allocation

def size (a : Allocation) : Size := a.data.size

/-- `Allocation::overlaps`, with D8: zero-sized ranges never overlap. -/
def overlaps (a : Allocation) (addr : Nat) (size : Size) : Bool :=
  if a.size == 0 || size == 0 then false
  else !(a.addr + a.size ≤ addr || addr + size ≤ a.addr)

/-- Does the allocation contain `addr` (one-past-the-end included)? -/
def containsAddr (a : Allocation) (addr : Nat) : Bool :=
  a.addr ≤ addr && addr ≤ a.addr + a.size

end Allocation

-- [D16]
/-- `BasicMemory`: allocations indexed by `AllocId`, assigned consecutively. No aliasing
model (D16): provenance is only the `AllocId`. -/
structure Memory where
  allocs : Array Allocation := #[]
deriving Repr, Inhabited

namespace Memory

def get? (m : Memory) (id : AllocId) : Option Allocation := m.allocs[id]?

/-- Is `addr` a legal base address for a new allocation (`allocate`'s `pick` constraint)?
As in MiniRust, the end address `addr + size` must itself be a valid `usize`, so that the
one-past-the-end pointer is in bounds. -/
def addrOk (m : Memory) (addr : Nat) (size : Size) (align : Align) : Bool :=
  addr > 0 && align.isAligned addr && addr + size < Target.ADDR_LIMIT &&
    !(m.allocs.any fun a => a.live && a.overlaps addr size)

-- [D8] [D26]
/-- `allocate`: the address is a daemonic choice, checked against the constraint.
D7: vtable allocations are created read-only, whatever `mutable` says. -/
def allocate {mo : Type → Type} [Monad mo] [MonadExceptOf Outcome mo] [MonadChoice mo]
    (m : Memory) (kind : AllocationKind) (size : Size) (align : Align) (mutable := true) :
    mo (ThinPointer × Memory) := do
  if !Target.validSize size then throwUb "asking for a too large allocation"
  let addr ← choose (.allocAddr size align)
  if !m.addrOk addr size align then
    throwNoBehavior s!"allocation address {addr} violates the allocation constraints"
  let a : Allocation :=
    { data := Array.replicate size .uninit, addr, align, kind,
      mutable := mutable && kind != .vtable, vtableRo := by intro h; simp [h] }
  let id := m.allocs.size
  pure (⟨addr, some id⟩, { allocs := m.allocs.push a })

/-- `deallocate`. -/
def deallocate (m : Memory) (p : ThinPointer) (kind : AllocationKind) (size : Size)
    (align : Align) : Except Outcome Memory := do
  let some id := p.prov | throwUb "deallocating invalid pointer"
  let some a := m.get? id | throwUb "deallocating invalid pointer"
  if !a.live then throwUb "double-free"
  if p.addr != a.addr then
    throwUb "deallocating with pointer not to the beginning of its allocation"
  if kind != a.kind then throwUb s!"deallocating {repr a.kind} memory with {repr kind} operation"
  if size != a.size then throwUb "deallocating with incorrect size information"
  if align != a.align then throwUb "deallocating with incorrect alignment information"
  pure { allocs := m.allocs.set! id { a with live := false } }

/-- `check_ptr`: is `p` dereferenceable for `len` bytes? Returns the allocation and offset,
or `none` for zero-sized accesses (which are always fine). -/
def checkPtr (m : Memory) (p : ThinPointer) (len : Size) :
    Except Outcome (Option (AllocId × Nat)) := do
  if len == 0 then return none
  let some id := p.prov | throwUb "dereferencing pointer without provenance"
  let some a := m.get? id | throwUb "dereferencing pointer without provenance"
  if !a.live then throwUb "dereferencing pointer to dead allocation"
  if p.addr < a.addr || p.addr + len > a.addr + a.size then
    throwUb "dereferencing pointer outside the bounds of its allocation"
  pure (some (id, p.addr - a.addr))

def dereferenceable (m : Memory) (p : ThinPointer) (len : Size) : Except Outcome Unit := do
  let _ ← m.checkPtr p len
  pure ()

/-- `signed_dereferenceable`: the range between `p` and `p + len` (either direction). -/
def signedDereferenceable (m : Memory) (p : ThinPointer) (len : Int) : Except Outcome Unit :=
  if len ≥ 0 then m.dereferenceable p len.toNat
  else
    let begin : Int := p.addr + len
    if begin < 0 then throwUb "dereferencing pointer outside the bounds of its allocation"
    else m.dereferenceable { p with addr := begin.toNat } (-len).toNat

-- [D7]
/-- `store`. D7: UB into immutable allocations. -/
def store (m : Memory) (p : ThinPointer) (bytes : List AbstractByte) (align : Align) :
    Except Outcome Memory := do
  if !align.isAligned p.addr then throwUb "store to a misaligned pointer"
  match ← m.checkPtr p bytes.length with
  | none => pure m
  | some (id, off) =>
    let a := m.allocs[id]!
    if !a.mutable then throwUb "store to read-only memory"
    let data := (bytes.zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) a.data
    pure { allocs := m.allocs.set! id { a with data } }

/-- `load`. -/
def load (m : Memory) (p : ThinPointer) (len : Size) (align : Align) :
    Except Outcome (List AbstractByte) := do
  if !align.isAligned p.addr then throwUb "load from a misaligned pointer"
  match ← m.checkPtr p len with
  | none => pure []
  | some (id, off) =>
    let a := m.allocs[id]!
    pure (a.data.extract off (off + len)).toList

/-- Write bytes ignoring mutability (used to initialize constant allocations). -/
def writeInit (m : Memory) (p : ThinPointer) (bytes : List AbstractByte) : Memory :=
  match p.prov with
  | none => m
  | some id =>
    match m.get? id with
    | none => m
    | some a =>
      let off := p.addr - a.addr
      let data := (bytes.zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) a.data
      { allocs := m.allocs.set! id { a with data } }

/-- `deinit`: overwrite with `Uninit` (MiniRust `ConcurrentMemory::deinit`). -/
def deinit (m : Memory) (p : ThinPointer) (len : Size) (align : Align) : Except Outcome Memory :=
  m.store p (List.replicate len .uninit) align

/-- The live allocation of the given kind that starts exactly at `p` (with its provenance). -/
def allocAt? (m : Memory) (p : ThinPointer) (kind : AllocationKind) : Option (AllocId × Allocation) := do
  let id ← p.prov
  let a ← m.get? id
  if a.live && a.kind == kind && a.addr == p.addr then some (id, a) else none

end Memory

end Ryo.Spec
