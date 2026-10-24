/-
Ryo.X86.State — the x86-64 machine state of L2 (x86.md §B.2).

- 16 general-purpose registers (`BitVec 64`, by x86 number: `rax` 0 … `r15` 15), `rip`;
- the flags the emitted code reads or writes: `CF ZF SF OF`. Each is an `Option Bool`: `none` is
  a value the SDM leaves undefined (e.g. `OF` after a shift by more than one, `SF`/`ZF` after
  `imul`). Reading an undefined flag (`jcc`, `setcc`) faults (`Fault.undefinedFlag`), so a
  proof about code that executes must show it never reads one, and a co-simulation compares only
  defined flags. `PF` and `AF` are not modeled: no emitted instruction reads them;
- `xmm0`–`xmm15` (`BitVec 128`);
- flat byte memory, total (no faults, no provenance), little-endian `read`/`write`.

`State.View` is a finite, serializable view (registers, flags, `xmm`s, memory regions) for
feeding states in and out (`ryo-lean exec-item`, `Ryo.X86.Cosim`, uses a compact variant:
memory as hex strings, undefined flags as `null`).
-/
import Ryo.X86.Item

namespace Ryo.X86

open Lean

/-- Flat byte memory. -/
abbrev Mem := BitVec 64 → UInt8

namespace Mem

/-- The little-endian value of the `n` bytes at `a` (addresses wrap). -/
def readNat (m : Mem) (a : BitVec 64) (n : Nat) : Nat :=
  (List.range n).foldr (fun i acc => (m (a + BitVec.ofNat 64 i)).toNat + 256 * acc) 0

/-- The `n` bytes at `a`, as a `BitVec (8 * n)`. -/
def read (m : Mem) (a : BitVec 64) (n : Nat) : BitVec (8 * n) := BitVec.ofNat _ (m.readNat a n)

/-- Writes the low `n` bytes of `v` at `a`, little-endian. -/
def write (m : Mem) (a : BitVec 64) (n : Nat) (v : Nat) : Mem := fun x =>
  let i := (x - a).toNat
  if i < n then UInt8.ofNat (v >>> (8 * i)) else m x

def read64 (m : Mem) (a : BitVec 64) : BitVec 64 := BitVec.ofNat 64 (m.readNat a 8)
def write64 (m : Mem) (a : BitVec 64) (v : BitVec 64) : Mem := m.write a 8 v.toNat

theorem write_other (m : Mem) (a x : BitVec 64) (n v : Nat) (h : n ≤ (x - a).toNat) :
    m.write a n v x = m x := by
  simp only [write]
  split
  · omega
  · rfl

theorem write_byte (m : Mem) (a : BitVec 64) (v : Nat) : m.write a 1 v a = UInt8.ofNat v := by
  simp [write]

end Mem

/-- The flags of L2: `none` where the SDM leaves the value undefined. -/
structure Flags where
  cf : Option Bool := none
  zf : Option Bool := none
  sf : Option Bool := none
  of : Option Bool := none
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- The machine state. -/
structure State where
  regs : Fin 16 → BitVec 64
  rip : BitVec 64
  flags : Flags
  xmm : Fin 16 → BitVec 128
  mem : Mem

instance : Inhabited State := ⟨⟨fun _ => 0, 0, {}, fun _ => 0, fun _ => 0⟩⟩

def Reg.idx (r : Reg) : Fin 16 := ⟨r.num % 16, Nat.mod_lt _ (by decide)⟩

namespace State

def reg (s : State) (r : Reg) : BitVec 64 := s.regs r.idx

/-- Writes the whole 64-bit register. -/
def setReg (s : State) (r : Reg) (v : BitVec 64) : State :=
  { s with regs := fun i => if i = r.idx then v else s.regs i }

def setXmm (s : State) (x : Fin 16) (v : BitVec 128) : State :=
  { s with xmm := fun i => if i = x then v else s.xmm i }

def setMem (s : State) (a : BitVec 64) (n : Nat) (v : Nat) : State :=
  { s with mem := s.mem.write a n v }

def rsp (s : State) : BitVec 64 := s.reg .rsp

/-- `push v`. -/
def push (s : State) (v : BitVec 64) : State :=
  let sp := s.rsp - 8
  (s.setReg .rsp sp).setMem sp 8 v.toNat

/-- `pop`: the value, and the state after. -/
def pop (s : State) : BitVec 64 × State :=
  (s.mem.read64 s.rsp, s.setReg .rsp (s.rsp + 8))

theorem reg_setReg (s : State) (r : Reg) (v : BitVec 64) : (s.setReg r v).reg r = v := by
  simp [reg, setReg]

theorem reg_setReg_other (s : State) (r r' : Reg) (v : BitVec 64) (h : r'.idx ≠ r.idx) :
    (s.setReg r v).reg r' = s.reg r' := by
  simp [reg, setReg, h]

/-- A finite, serializable view of a state: registers and `xmm`s by number, the flags, and
memory regions (start address, bytes). -/
structure View where
  regs : List (BitVec 64)
  rip : BitVec 64
  flags : Flags
  xmm : List (BitVec 128)
  mem : List (BitVec 64 × List UInt8)
deriving Repr, ToJson, FromJson

/-- The state of a view: memory outside the regions is 0. -/
def ofView (v : View) : State where
  regs i := v.regs.getD i 0
  rip := v.rip
  flags := v.flags
  xmm i := v.xmm.getD i 0
  mem a := v.mem.foldr (fun (start, bs) acc =>
    let i := (a - start).toNat
    if i < bs.length then bs.getD i 0 else acc) 0

/-- The view of a state over the given memory regions (start, length). -/
def view (s : State) (regions : List (BitVec 64 × Nat)) : View where
  regs := (List.finRange 16).map s.regs
  rip := s.rip
  flags := s.flags
  xmm := (List.finRange 16).map s.xmm
  mem := regions.map fun (a, n) => (a, (List.range n).map fun i => s.mem (a + BitVec.ofNat 64 i))

end State

end Ryo.X86
