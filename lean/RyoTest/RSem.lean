/-
RyoTest.RSem — R's semantics (`Ryo.Vm.R.Sem`, `Ryo.Vm.R.Run`) on small hand-built functions:
recursive `fib` run as a program (calls answered by running the callee's R code), native and
handler instructions and branch polarity, escapes and storage ends (pointers to escaped
objects, `Uninit` and dangling after an `End`, `addr` of a private slot), calls (argument
registers by value and by address, the outgoing stack area, sret destinations, result
stores), unwinding to a landing pad and out of a function, tail calls, islands and their
`Lend` extents, and ill-formed instructions.
-/
import RyoTest.Harness
import Ryo.Vm.R.Run

namespace RyoTest.RSem

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.Vm.OpSem

def mode : Ryo.Obj.Mode := { fpArg := true, framePointer := true, alignLoops := false, pe := false, counters := false }

def red (m : String) : Reduced.Opcode := (Reduced.all.find? (·.info.mnemonic == m)).get!
def full (m : String) : Full.Opcode := (Full.all.find? (·.info.mnemonic == m)).get!

def s32 (o : Int) : BitVec 32 := BitVec.ofInt 32 o
def sl (o : Int) : Opnd Nat := .slot (s32 o)
def im (v : Nat) : Opnd Nat := .imm (BitVec.ofNat 64 v)

def nat (m : String) (ops : List (Opnd Nat)) : Insn := .native (red m) ops

/-- An integer argument register's word: `size` bytes, index `i`; by address with `addr`. -/
def reg (i : Nat) (size : Nat := 8) (addr := false) : Nat :=
  size ||| (i <<< 8) ||| (if addr then Asm.argAddr else 0)

def words (a : List (Int × Nat)) : Opnd Nat := .words (a.flatMap fun (s, r) => [s32 s, BitVec.ofNat 32 r])

/-- `call d, fn f, k, a`. -/
def call (d : Int) (f k : Nat) (a : List (Int × Nat)) : Insn := nat "call" [sl d, .func f, im k, words a]

def ret (s : Int) (k : Nat) : Insn := nat "ret" [sl s, im k]
def arg (d : Int) (r : Nat) : Insn := nat "arg" [sl d, im r]

/-- The handler of `m` with its operands' values (slots as offsets), by its layout, and
`then_`. -/
def handler (m : String) (vals : List Int) (then_ : Then Nat := .next) : Insn := Id.run do
  let h := full m
  let l := (h.layout mode.fpArg).get!
  let mut regs : Array Nat := Array.replicate l.regs 0
  for (v, k) in vals.zipIdx do
    let loc := l.locs[k]!
    regs := regs.modify loc.reg (· ||| ((s32 v).toNat <<< loc.shift))
  let args := (List.range l.regs).map fun r =>
    if r < l.first then Arg.fp else Arg.imm (BitVec.ofNat 64 regs[r]!)
  return .handler h args then_

def lpad (x : Int) : Insn := .handler (full "lpad") [.fp, .exception, .imm (BitVec.ofNat 64 (s32 x).toNat)] .next
def resume (x : Int) : Insn := .handler (full "resume") [.fp, .imm (BitVec.ofNat 64 (s32 x).toNat)] .trap

def escape (at_ : Nat) (off : Int) (n : Nat) : Nat × Scope := (at_, ⟨0, s32 off, n, .escape 8⟩)
def «end» (at_ : Nat) (off : Int) (n : Nat) : Nat × Scope := (at_, ⟨0, s32 off, n, .end⟩)
def lend (at_ : Nat) (off : Int) (n : Nat) : Nat × Scope := (at_, ⟨0, s32 off, n, .lend⟩)

def code (insns : List Insn) (frame : Nat := 64) (scopes : List (Nat × Scope) := [])
    (cleanup : List (Nat × Option Nat × Bool) := []) (stackSize : Nat → Nat := fun _ => 0)
    (sretSize : Nat → Option Nat := fun _ => none) (argSize : Nat := 0) : Code :=
  { d := { insns := insns.toArray, frameSize := frame, cleanup := cleanup.toArray,
           scopes := scopes.toArray, dropped := #[], heads := #[] },
    mode, ρ := fun _ => none, argSize, stackSize, sretSize }

def prog (cs : List Code) : R.Program := { codes := cs.toArray.map some }

/-- Run function `f` of `cs` on integer arguments. -/
def runP (cs : List Code) (f : Nat) (args : List Nat) (fuel := 10000) : RM R.Final :=
  (prog cs).run f (Regs.ofInts args) {} fuel

def haltText : Halt → String
  | .stop s => toString s
  | .fuel => "out of fuel"
  | .external _ => "external"

/-- The function returns `rax = v`. -/
def returns (name : String) (cs : List Code) (f : Nat) (args : List Nat) (v : Nat) : TestCase :=
  ⟨s!"rsem/{name}", fun _ => do
    match runP cs f args with
    | .ok { exit := .ret regs _, .. } =>
      match decodeBits ((regs.get (.gpr 0)).take 8) with
      | some w => if w == v then pure () else throw s!"returned {w}, not {v}"
      | none => throw s!"returned uninitialized bytes"
    | .ok f => throw s!"ended with {f.text}"
    | .error h => throw (haltText h)⟩

/-- The run stops with a `Stop` whose text contains `msg`. -/
def stops (name : String) (cs : List Code) (f : Nat) (args : List Nat) (msg : String) : TestCase :=
  ⟨s!"rsem/{name}", fun _ => do
    match runP cs f args with
    | .error (.stop s) =>
      if ((toString s).splitOn msg).length > 1 then pure () else throw s!"stopped with `{s}`"
    | .error h => throw (haltText h)
    | .ok f => throw s!"ended with {f.text}"⟩

/-! ### fib -/

/-- `fib(n: u64) -> u64`, recursive, function 0: `n < 2` branches to the return of `n`. The
sum is a handler call when `handlerAdd`. -/
def fib (handlerAdd : Bool) (self : Nat := 0) : Code := code (frame := 32) [
  arg (-8) (reg 0),
  nat "br.lt.u.imm.w64" [sl (-8), im 2, .neg false, .target 7],
  nat "sub.imm.w64" [sl (-16), sl (-8), im 1],
  call (-24) self 8 [(-16, reg 0)],
  nat "sub.imm.w64" [sl (-16), sl (-8), im 2],
  call (-32) self 8 [(-16, reg 0)],
  if handlerAdd then handler "add.w64" [-8, -24, -32] else nat "add.w64" [sl (-8), sl (-24), sl (-32)],
  ret (-8) 8]

/-- `n ≥ 2 ? 1 : 0`, through a negated branch (`br!`: taken when the condition is false). -/
def geTwo : Code := code [
  arg (-8) (reg 0),
  nat "br.lt.u.imm.w64" [sl (-8), im 2, .neg true, .target 4],
  nat "imm.w64" [sl (-16), im 0],
  ret (-16) 8,
  nat "imm.w64" [sl (-16), im 1],
  ret (-16) 8]

/-! ### Escapes and storage ends -/

/-- `x = 7; p = &x; *p = 5` then `body`, `x` escaped before 1 and ended before `endAt`. -/
def escaped (body : List Insn) (endAt : Option Nat := none) : Code :=
  code ([nat "imm.w64" [sl (-16), im 7], nat "addr" [sl (-24), sl (-16)],
         nat "imm.w64" [sl (-32), im 5]] ++ body)
    (scopes := [escape 1 (-16) 8] ++ (endAt.map fun k => [«end» k (-16) 8]).getD [])

def mem0 (p : Int) (k : Int := 0) : Opnd Nat := .mem (s32 p) (s32 k)

/-- The escape holds the slot's bytes: a load through the pointer reads 7. -/
def escapeKeeps : Code := escaped [nat "load.w64" [sl (-8), mem0 (-24)], ret (-8) 8]

/-- A store through the pointer is the slot's byte: `x` reads 5. -/
def storeThrough : Code :=
  escaped [nat "store.w64" [mem0 (-24), sl (-32)], ret (-16) 8]

/-- After the `End`, `x` is `Uninit`. -/
def readAfterEnd : Code :=
  escaped [nat "add.imm.w64" [sl (-8), sl (-16), im 0], ret (-8) 8] (endAt := some 3)

/-- After the `End`, the pointer dangles. -/
def loadAfterEnd : Code :=
  escaped [nat "load.w64" [sl (-8), mem0 (-24)], ret (-8) 8] (endAt := some 3)

/-- `addr` of a slot no escape covers. -/
def addrPrivate : Code := code [nat "addr" [sl (-24), sl (-16)], ret 0 0]

/-- An escape of part of an escaped object adds nothing; an `End` of part of one keeps it
escaped (the pointer still reads the rest) and makes those bytes `Uninit`. -/
def partialEnd (k : Int) : Code :=
  code [nat "imm.w64" [sl (-16), im 0x0102030405060708], nat "addr" [sl (-24), sl (-16)],
        nat "imm.w32" [sl (-4), im 0], nat "load.w32" [sl (-8), mem0 (-24) k],
        nat "add.imm.w32" [sl (-8), sl (-8), im 0], ret (-8) 8]
    (scopes := [escape 1 (-16) 8, escape 2 (-16) 4, «end» 3 (-12) 4])

/-! ### Calls -/

/-- Function 1: returns its argument plus the 8 bytes of its first stack argument. -/
def addStack : Code := code (frame := 16) (argSize := 8) [
  arg (-8) (reg 0), nat "add.w64" [sl (-16), sl (-8), sl 16], ret (-16) 8]

/-- Function 0 calls function 1 with 30 in `rdi` and 12 as its stack argument. -/
def callStack : Code := code (frame := 32) (stackSize := fun k => if k == 2 then 8 else 0) [
  nat "imm.w64" [sl (-24), im 30], nat "imm.w64" [sl (-32), im 12],
  call (-8) 1 8 [(-24, reg 0)], ret (-8) 8]

/-- Function 1 reads the `u64` its first argument points at, as an integer. -/
def deref : Code := code (frame := 16) [arg (-8) (reg 0), nat "load.w64" [sl (-16), mem0 (-8)],
  nat "add.imm.w64" [sl (-16), sl (-16), im 0], ret (-16) 8]

/-- Function 0 passes `&x` (escaped, `x = 41`), by address. -/
def callByAddr (esc : Bool) : Code := code [
  nat "imm.w64" [sl (-16), im 41], call (-8) 1 8 [(-16, reg 0 8 true)], ret (-8) 8]
  (scopes := if esc then [escape 1 (-16) 8] else [])

/-- An sret call: function 1 reads its destination, which the call made `Uninit`. -/
def sretCaller : Code := code (sretSize := fun k => if k == 1 then some 8 else none) [
  nat "imm.w64" [sl (-16), im 41], call 0 1 0 [(-16, reg 0 8 true)], ret (-16) 8]
  (scopes := [escape 1 (-16) 8])

/-- One step of function `c` from entry until its first event, on integer arguments. -/
def firstEvent (c : Code) (args : List Nat) (fuel : Nat := 100) : Except String (Query × RState) := do
  let rec go : Nat → RState → Except String (Query × RState)
    | 0, _ => throw "out of fuel"
    | n + 1, s => match step c s with
      | .ok (.step s) => go n s
      | .ok (.ext q s) => pure (q, s)
      | .ok (.done f) => throw s!"ended with {f.text}"
      | .error e => throw (toString e)
  go fuel (← (entry stackTop (Regs.ofInts args) [] {}).mapError toString)

/-- The query of a call: the by-value register, the by-address pointer with the provenance of
the escaped slot, the stack area at `sp = fp - F`; the answer's `rax` stored at `d`. -/
def callQuery : TestCase := ⟨"rsem/call query and answer", fun _ => do
  let c := code (frame := 32) (stackSize := fun _ => 8) [
    nat "imm.w64" [sl (-8), im 30], nat "imm.w64" [sl (-32), im 12],
    call (-16) 5 8 [(-8, reg 1), (-24, reg 0 8 true)], ret (-16) 8]
    (scopes := [escape 2 (-24) 8])
  let (q, s) ← firstEvent c []
  let .call (.func 5) args sp stack := q.ext | throw "not a call of fn5"
  if sp != stackTop - 32 then throw s!"sp {sp}"
  if decodeBits stack != some 12 then throw "stack area"
  if decodeBits (args.get (.gpr 1)) != some 30 then throw "by-value register"
  let some p := decodePtr (args.get (.gpr 0)) | throw "by-address register"
  if p.addr != stackTop - 24 || p.prov != some 0 then throw s!"pointer {repr p}"
  let a : Answer := { result := .ret (Regs.ofInts [99]), world := q.world }
  match answer c s a with
  | .ok (.step s) =>
    if s.pc != 3 then throw s!"pc {s.pc}"
    match s.st.readFrame (-16) 8 with
    | .ok bs => if decodeBits bs != some 99 then throw "result store"
    | .error e => throw (toString e)
  | _ => throw "answer"⟩

/-- An answer's outgoing-area bytes of the wrong length are ill-formed. -/
def badAnswer : TestCase := ⟨"rsem/answer with wrong stack bytes", fun _ => do
  let c := code (stackSize := fun _ => 8) [call 0 1 0 [], ret 0 0]
  let (q, s) ← firstEvent c []
  match answer c s { result := .ret {}, frame := [[.uninit]], world := q.world } with
  | .error (.illFormed _) => pure ()
  | _ => throw "accepted"⟩

/-! ### Unwinding -/

/-- Function 1 resumes unwinding with its argument as the exception object. -/
def resumer : Code := code (frame := 16) [arg (-8) (reg 0), resume (-8)] (cleanup := [(1, none, false)])

/-- Function 0 calls function 1 (exception 1234); the landing pad stores it and returns it. -/
def catcher (pad : Bool) : Code := code (frame := 32) [
  nat "imm.w64" [sl (-24), im 1234], call 0 1 0 [(-24, reg 0)], ret 0 0, lpad (-8), ret (-8) 8]
  (cleanup := if pad then [(1, some 3, false)] else [])

/-- Function 0 unwinds through a `continue` entry, its escaped object deallocated. -/
def unwindOut : TestCase := ⟨"rsem/unwind out", fun _ => do
  let c := code (frame := 32) [
    nat "imm.w64" [sl (-24), im 1234], call 0 1 0 [(-24, reg 0)], ret 0 0]
    (cleanup := [(1, none, false)]) (scopes := [escape 1 (-16) 8])
  match runP [c, resumer] 0 [] with
  | .ok { exit := .unwind exc, world } =>
    if exc.addr != 1234 then throw "exception object"
    match world.mem.get? 0 with
    | some a => if a.live then throw "the escaped object is still live"
    | none => throw "no allocation"
  | .ok f => throw s!"ended with {f.text}"
  | .error h => throw (haltText h)⟩

def catchFlag : TestCase := ⟨"rsem/catch flag", fun _ => do
  let c := code [ret 0 0] (cleanup := [(0, some 0, true), (1, some 0, false)])
  if !(c.catchesAt 0 && !c.catchesAt 1 && !c.catchesAt 2) then throw "catchesAt"⟩

/-! ### Tail calls, islands, returns -/

/-- Function 0 tail-calls function 1 (`fib`) with its argument plus one. -/
def tailer : Code := code [arg (-8) (reg 0), nat "add.imm.w64" [sl (-16), sl (-8), im 1],
  nat "tail_call" [.func 1, words [(-16, reg 0)]]]

/-- An island's query has `fp`, its operands and its `Lend` extents; the answer writes them. -/
def islandQuery : TestCase := ⟨"rsem/island", fun _ => do
  let c := { code [nat "island" [.sym 3, .words [s32 (-16), s32 (-8)]], ret (-8) 8]
    (scopes := [lend 0 (-16) 8, lend 0 (-8) 8]) with islandTemplate := fun _ => some "ryo_island_sqrtf64" }
  let (q, s) ← firstEvent c []
  let .island 3 (some "ryo_island_sqrtf64") fp ops lends := q.ext | throw "not an island"
  if fp != stackTop || ops != [-16, -8] || lends != [(-16, 8), (-8, 8)] then throw "operands"
  match answer c s { result := .ret {}, frame := [encodeBits 8 1, encodeBits 8 77], world := q.world } with
  | .ok (.step s) =>
    match step c s with
    | .ok (.done { exit := .ret regs _, .. }) =>
      if decodeBits (regs.get (.gpr 0)) != some 77 then throw "the island's write"
    | _ => throw "ret"
  | _ => throw "answer"
  match answer c s { result := .ret {}, frame := [encodeBits 8 1], world := q.world } with
  | .error (.illFormed _) => pure ()
  | _ => throw "accepted one list for two extents"⟩

/-- A two-part return (`rax` 4 bytes, `rdx` 8 bytes at offset 8): parts zero-extended. -/
def twoParts : TestCase := ⟨"rsem/two-part return", fun _ => do
  let k := Asm.retKind [⟨false, 4, 0⟩, ⟨false, 8, 8⟩]
  let c := code [nat "imm.w64" [sl (-16), im 0xffffffff00000005], nat "imm.w64" [sl (-8), im 6],
    ret (-16) k]
  match runP [c] 0 [] with
  | .ok { exit := .ret regs _, .. } =>
    if decodeBits (regs.get (.gpr 0)) != some 5 || decodeBits (regs.get (.gpr 1)) != some 6 then
      throw s!"{regs.text}"
  | _ => throw "ret"⟩

/-- A handler call whose arguments don't unpack has no view. -/
def noView : Code := code [.handler (full "add.w64") [.fp] .next, ret 0 0]

/-- A handler call whose `Then` isn't its shape's. -/
def wrongThen : Code := code [handler "add.w64" [-8, -8, -8] (.branch false 0), ret 0 0]

def tests : List TestCase := [
  returns "fib 10" [fib false] 0 [10] 55,
  returns "fib 10, handler add" [fib true] 0 [10] 55,
  returns "fib 1" [fib false] 0 [1] 1,
  returns "negated branch taken" [geTwo] 0 [5] 1,
  returns "negated branch not taken" [geTwo] 0 [1] 0,
  returns "escape keeps the bytes" [escapeKeeps] 0 [] 7,
  returns "store through a pointer" [storeThrough] 0 [] 5,
  stops "uninit after end" [readAfterEnd] 0 [] "uninitialized",
  stops "dangling after end" [loadAfterEnd] 0 [] "dead allocation",
  stops "addr of a private slot" [addrPrivate] 0 [] "not in an escaped object",
  returns "partial end" [partialEnd 0] 0 [] 0x05060708,
  stops "partial end uninit" [partialEnd 4] 0 [] "uninitialized",
  returns "stack arguments" [callStack, addStack] 0 [] 42,
  returns "by-address argument" [callByAddr true, deref] 0 [] 41,
  stops "by-address argument not escaped" [callByAddr false, deref] 0 [] "not in an escaped object",
  stops "sret destination uninit" [sretCaller, deref] 0 [] "uninitialized",
  callQuery,
  badAnswer,
  returns "unwind to a landing pad" [catcher true, resumer] 0 [] 1234,
  stops "unwind without a call-site entry" [catcher false, resumer] 0 [] "no call-site entry",
  unwindOut,
  catchFlag,
  returns "tail call" [tailer, fib false 1] 0 [9] 55,
  islandQuery,
  twoParts,
  stops "no view" [noView] 0 [] "no view",
  stops "wrong control flow" [wrongThen] 0 [] "no view",
  stops "fall off the end" [code [nat "imm.w64" [sl (-8), im 0]]] 0 [] "no instruction 1"]

end RyoTest.RSem
