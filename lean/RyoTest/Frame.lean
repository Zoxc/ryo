/-
RyoTest.Frame — the dead-store check (`Ryo.Vm.Frame.droppedNotDead`, `decodeChecked`) on small
hand-built functions: each precision rule accepts a store nothing reads, and a store that is
read (by a call argument, by a call that may have stack arguments, by a pointer access while
its object is escaped, by a handler operand, by an island's `Lend` extent, after an `End` of part of it) is rejected.

Every function starts with a dropped store, an inline `mov` whose items are empty (its load
served by the register cache, its store dropped), and ends in `ret`. Other inline `mov`s have
the items given (none by default: no frame access).
-/
import RyoTest.Harness
import Ryo.Vm.Frame

namespace RyoTest.Frame

open Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm Ryo.Vm.Frame

def mode : Mode := { fpArg := true, framePointer := true, alignLoops := false, pe := false, counters := false }

def red (m : String) : Reduced.Opcode := (Reduced.all.find? (·.info.mnemonic == m)).get!
def full (m : String) : Full.Opcode := (Full.all.find? (·.info.mnemonic == m)).get!

def s32 (o : Int) : BitVec 32 := BitVec.ofInt 32 o

/-- `mov.wN $d, $s`, its store dropped. -/
def mov (w : Nat) (d : Int) : Insn := .native (red s!"mov.w{w}") [.slot (s32 d), .slot (s32 (-64))]

/-- `call $0, fn0, 0, a` with the (slot, register word) pairs `a`. -/
def call (a : List (Int × Nat)) : Insn :=
  .native (red "call") [.slot 0, .func 0, .imm 0, .words (a.flatMap fun (s, r) => [s32 s, BitVec.ofNat 32 r])]

def ret : Insn := .native (red "ret") [.slot 0, .imm 0]

/-- An integer argument register's word: 8 bytes, index `i`. -/
def reg (i : Nat) : Nat := 8 ||| (i <<< 8)

/-- The handler of `m` with its operands' values (slots as offsets), by its layout. -/
def handler (m : String) (vals : List Int) : Insn := Id.run do
  let h := full m
  let l := (h.layout mode.fpArg).get!
  let mut regs : Array Nat := Array.replicate l.regs 0
  for (v, k) in vals.zipIdx do
    let loc := l.locs[k]!
    regs := regs.modify loc.reg (· ||| ((s32 v).toNat <<< loc.shift))
  let args := (List.range l.regs).map fun r =>
    if r < l.first then Arg.fp else Arg.imm (BitVec.ofNat 64 regs[r]!)
  return .handler h args .next

def escape (at_ : Nat) (off : Int) (n : Nat) : Nat × Scope := (at_, ⟨0, s32 off, n, .escape 8⟩)
def «end» (at_ : Nat) (off : Int) (n : Nat) : Nat × Scope := (at_, ⟨0, s32 off, n, .end⟩)
def lend (at_ : Nat) (off : Int) (n : Nat) : Nat × Scope := (at_, ⟨0, s32 off, n, .lend⟩)

/-- An island with the operands `ops`. -/
def island (ops : List Int) : Insn := .native (red "island") [.sym 0, .words (ops.map s32)]

/-- A function of `insns` (then `ret`) in a frame of 64, instruction 0's store dropped. -/
def fn (insns : List Insn) (scopes : List (Nat × Scope) := []) (items : List (List Ryo.X86.Item) := []) :
    Decoded :=
  { insns := (insns ++ [ret]).toArray, frameSize := 64, cleanup := #[], scopes := scopes.toArray,
    dropped := #[0], heads := #[], items := items.toArray }

/-- An inline store's item: `mov [fp + d], rax`. -/
def st (d : Int) : Ryo.X86.Item := .st .q .rax (Ryo.X86.M.frame (s32 d))

def accepts (name : String) (d : Decoded) : TestCase :=
  ⟨s!"frame/accepts {name}", fun _ => do
    match decodeChecked.checkDropped d mode with
    | .ok _ => pure ()
    | .error e => throw e⟩

def rejects (name : String) (d : Decoded) : TestCase :=
  ⟨s!"frame/rejects {name}", fun _ => do
    match decodeChecked.checkDropped d mode with
    | .ok _ => throw "accepted"
    | .error _ => pure ()⟩

def tests : List TestCase :=
  [-- Calls read their arguments, not every byte.
   accepts "a call not passing the store" (fn [mov 64 (-8), call [(-16, reg 0)]]),
   rejects "a call passing the store" (fn [mov 64 (-8), call [(-16, reg 0), (-8, reg 1)]]),
   rejects "a call that may have stack arguments" (fn [mov 64 (-8), call [(-16, reg 0), (-24, reg 4)]]),
   accepts "an overwrite before the call" (fn [mov 64 (-8), mov 64 (-8), call [(-8, reg 0)]] [] [[], [st (-8)]]),
   -- Pointer accesses read the objects escaped there.
   rejects "a call while the object is escaped" (fn [mov 64 (-8), call []] [escape 1 (-16) 16]),
   accepts "a call after the object's end" (fn [mov 64 (-8), mov 64 (-32), call []]
     [escape 1 (-16) 16, «end» 2 (-16) 16]),
   rejects "a call after a partial end" (fn [mov 64 (-8), mov 64 (-32), call []]
     [escape 1 (-16) 16, «end» 2 (-16) 8]),
   accepts "a call while another object is escaped" (fn [mov 64 (-8), call []] [escape 1 (-32) 16]),
   rejects "a handler load through a pointer while escaped" (fn [mov 64 (-8), handler "load.w64" [-32, -40]]
     [escape 0 (-8) 8]),
   accepts "a handler that doesn't dereference while escaped" (fn [mov 64 (-8), handler "add.w64" [-32, -40, -48]]
     [escape 0 (-8) 8]),
   -- Handlers access their operands at their widths.
   accepts "a handler reading the bytes below" (fn [mov 8 (-9), handler "add.w64" [-32, -24, -17]]),
   rejects "a handler reading the store" (fn [mov 8 (-9), handler "add.w64" [-32, -24, -16]]),
   accepts "rotl's u32 amount" (fn [mov 32 (-12), handler "rotl.w64" [-32, -24, -16]]),
   rejects "rotl's operand" (fn [mov 32 (-12), handler "rotl.w64" [-32, -12, -16]]),
   accepts "a copy's length" (fn [mov 64 (-8), handler "copy" [-32, -24, 16]]),
   rejects "a copy over the store" (fn [mov 64 (-8), handler "copy" [-32, -24, 17]]),
   accepts "a handler's write" (fn [mov 64 (-8), handler "copy" [-8, -24, 8], call [(-8, reg 0)]]),
   accepts "set_discr's write" (fn [mov 8 (-8), handler "set_discr.niche.w8" [-8, 0, 0, 0, 1], call [(-8, reg 0)]]),
   rejects "set_discr of the untagged variant" (fn [mov 8 (-8), handler "set_discr.niche.w8" [-8, 1, 0, 0, 1],
     call [(-8, reg 0)]]),
   -- What R reads after an `End` is `Uninit`.
   accepts "a read after the storage's end" (fn [mov 64 (-8), call [(-8, reg 0)]] [«end» 1 (-8) 8]),
   rejects "a read after a partial end" (fn [mov 64 (-8), call [(-8, reg 0)]] [«end» 1 (-8) 4]),
   -- Islands read their operands' `Lend` extents, and escaped objects through pointers.
   rejects "an island's lend over the store" (fn [mov 64 (-8), island [-16]] [lend 1 (-16) 16]),
   accepts "a store outside an island's lends" (fn [mov 64 (-8), island [-32, -48]]
     [lend 1 (-32) 8, lend 1 (-48) 16]),
   accepts "an island's lend at another instruction" (fn [mov 64 (-8), island [-32], call []]
     [lend 1 (-32) 8, lend 2 (-8) 8]),
   rejects "an island while the object is escaped" (fn [mov 64 (-8), island [-32]]
     [escape 0 (-8) 8, lend 1 (-32) 8]),
   -- An operand without a lend is zero-sized: the island reads only escaped bytes there.
   accepts "an island without lends" (fn [mov 64 (-8), island [-32]]),
   accepts "an island with an operand no lend starts" (fn [mov 64 (-8), island [-8, -48]] [lend 1 (-48) 8]),
   rejects "an island without lends while the object is escaped" (fn [mov 64 (-8), island [-32]]
     [escape 0 (-8) 8])]

end RyoTest.Frame
