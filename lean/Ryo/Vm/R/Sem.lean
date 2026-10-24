/-
Ryo.Vm.R.Sem — the small-step semantics of one R function body (reduced.md §C0.3, §C0.4),
open at calls: a call or an island is an external event (`Query`) the environment answers
(`Answer`) with a new state, and a return, a tail call or unwinding out of the function ends
it (`Final`), as in CompCertO's open semantics.

**Layout.** This is `R(φ_AOT)`: a frame object at frame offset `off` lives at `fp + off`, with
`fp` (the frame pointer, an address) part of the state. The object table of §C0.2 is not
modeled: an `Escape` scope's range is taken as its object. A layout parametric in `φ` replaces
`fp + off` in `escape` (the only place a frame address is made) by `φ(o) + (off - off_o)`;
`opSem` is layout-independent already (frame addresses appear only through allocations).

**State** (`RState`): the instruction index `pc`, `fp`, `opSem`'s `State` (the private frame
bytes by offset, the escaped objects as allocations of the memory, L0's memory, the exposed
allocations, the exception register), and the incoming argument registers `arg` reads. What
doesn't change (the `Decoded` code and side data, the mode, the placement `ρ` of the image's
addressed things, and the facts about calls) is the `Code`.

**A step** at `pc`:

1. The scopes before instruction `pc` take effect, in order: `Escape` makes its range an
   allocation at `fp + off` (a fresh `AllocId`, exposed, holding the frame's current bytes;
   nothing if an escaped object already contains it), `End` deallocates the escaped objects
   it covers whole and makes the bytes it covers private and `Uninit` (in a partly covered
   object, its allocation's bytes), `Lend` does nothing (an island's operand extent, which
   the island event reports).
2. The instruction:
   - a native instruction `opSem` gives the meaning of (shapes `op`, `br`, `switch`, `trap`,
     `lpad`) or a handler call: `view`, then `opSem` and the shape's control flow
     (`Then.succ`): `semR i = opSem (view i)` plus control. `view = none` is `illFormed`.
     `resume` (no `opSem`: its handler is assembly) unwinds from `pc` with the exception
     object in its slot.
   - `jmp t`: to `t`.
   - `arg d, r`: register `r` of the incoming argument registers, its `r.size` low bytes
     stored at `d`.
   - `call`/`call.sym`/`call.sym.ind`/`call.ptr` `d, f, k, a`: the argument registers built
     from the list `a` of (slot, register) pairs (by value: the slot's bytes at the register's
     size, zero-extended to the register; by address, `ARG_ADDR`: a pointer to the slot, UB
     unless it is escaped), the outgoing stack area `[fp - F, fp - F + n)` for the call's
     stack size `n` (`Code.stackSize`), then the sret destination (the list's first entry, the
     first integer register by address) made `Uninit` for `Code.sretSize` bytes (reduced.md
     §C0.4), then the `Query`. The answer returns or unwinds: a return stores its registers'
     parts by `k` (`Asm.retParts k false`) at `d`; unwinding lands at the call's landing pad
     (its cleanup entry), or leaves the function for a `continue` entry; with no entry it is
     UB (the lowering emits none only where L0 has UB).
   - `tail_call`/`tail_call.ptr`: the argument registers and the stack arguments
     `[fp + 16, fp + 16 + n)` (the incoming area, which becomes the callee's), and the
     function ends (`Exit.tailCall`).
   - `ret s, k`: the parts of `s` by `k` (`Asm.retParts k true`) in `rax`/`rdx` and
     `xmm0`/`xmm1`, zero-extended, and the function ends (`Exit.ret`, with the incoming area's
     bytes, which are the caller's outgoing area).
   - `island isl, ops`: a `Query` with the template (if known), `fp`, the operand slots and
     the `Lend` extents before it; the answer gives the new bytes of those extents and the memory (what the template does
     is its contract's: `Ryo.Vm.R.Islands` has the operand roles, the rest is to come), or
     unwinds as a call does.
   - `lpad x` stores the exception register (`opSem`).
   At the end of the function (return, tail call, unwinding out) every escaped object is
   deallocated.

The answer's `world` (memory and exposed allocations) replaces the state's: the environment
sees and changes memory, escaped frame objects included, but not the private frame bytes,
which only the answer's outgoing-area and `Lend` bytes write. What an answer may be (that a
callee keeps its convention, that an island keeps its contract) is the environment's
specification, not this file's.

**Unwinding** is single-phase here: the environment answers a call by unwinding with an
exception object, and the function lands at the call's landing pad. A `catch` entry (a pad
that catches: `catch_unwind`'s, a terminate pad) lands the same way; the flag
(`Code.catchesAt`) is what an unwinder's search phase asks of the frame.
-/
import Ryo.Vm.R.View
import Ryo.Vm.OpSem.Sem
import Ryo.Vm.Frame

namespace Ryo.Vm.R

open Ryo.Spec Ryo.Vm.OpSem

/-! ### Registers, events and answers -/

/-- An argument or return register: an integer register by index (an argument register in the
convention's order, `rdi rsi rdx rcx r8 r9` or PE `rcx rdx r8 r9`; for a return value `rax`
then `rdx`), or `xmm` by index. -/
inductive Reg where
  | gpr (i : Nat)
  | xmm (i : Nat)
deriving DecidableEq, Repr, Inhabited

def Reg.width : Reg → Nat
  | .gpr _ => 8
  | .xmm _ => 16

def Reg.ofArgReg (a : Asm.ArgReg) : Reg := if a.xmm then .xmm a.index else .gpr a.index

/-- A register file at a call boundary, holding abstract bytes (a register not listed is
`Uninit`). -/
structure Regs where
  vals : List (Reg × List AbstractByte) := []
deriving DecidableEq, Repr, Inhabited

def Regs.get (rs : Regs) (r : Reg) : List AbstractByte :=
  match rs.vals.find? (·.1 == r) with
  | some (_, bs) => bs
  | none => List.replicate r.width .uninit

def Regs.set (rs : Regs) (r : Reg) (bs : List AbstractByte) : Regs :=
  ⟨rs.vals.filter (·.1 != r) ++ [(r, bs)]⟩

/-- An integer register holding `v` (its 8 bytes). -/
def Regs.ofInts (vs : List Nat) : Regs :=
  ⟨vs.zipIdx.map fun (v, i) => (.gpr i, encodeBits 8 v)⟩

/-- What the environment shares with the function: memory (escaped frame objects included)
and the exposed allocations. -/
structure World where
  mem : Memory := {}
  exposed : List AllocId := []
deriving Repr, Inhabited

/-- A call's callee: an image function, the function whose address symbol slot `s` holds
(`call.sym`: `call [rip + slot]`), the function whose address is stored where slot `s` points
(`call.sym.ind`: `mov rax, [rip + slot]; call [rax]`), or a pointer read from a slot
(`call.ptr`, `tail_call.ptr`). The environment reads the slots (memory it shares). -/
inductive Callee where
  | func (f : Nat)
  | sym (s : Nat)
  | symInd (s : Nat)
  | ptr (p : ThinPointer)
deriving DecidableEq, Repr, Inhabited

/-- An outgoing event: what the environment is asked. -/
inductive Ext where
  /-- A call: the argument registers, and the stack arguments at `sp` (the caller's
  `fp - F`, so the callee's `fp + 16`). -/
  | call (callee : Callee) (args : Regs) (sp : Nat) (stack : List AbstractByte)
  /-- An island `isl(fp, &ops)`: its symbol slot, its template if known (`Code.islandTemplate`),
  `fp`, its operand slots, and the `Lend` extents (offset, size) before it. -/
  | island (sym : Nat) (template : Option String) (fp : Nat) (ops : List Int) (lends : List (Int × Nat))
deriving Repr, Inhabited

structure Query where
  ext : Ext
  world : World
deriving Repr, Inhabited

/-- How a call ends. -/
inductive Result where
  | ret (regs : Regs)
  | unwind (exc : ThinPointer)
deriving DecidableEq, Repr, Inhabited

/-- The environment's answer. `frame` is the new bytes of the frame ranges the callee may
write: for a call, `[]` or the outgoing stack area's (as long as the query's `stack`); for an
island, `[]` or one list per `Lend` extent, in order, each the extent's size. -/
structure Answer where
  result : Result
  frame : List (List AbstractByte) := []
  world : World
deriving Repr, Inhabited

/-- How the function ends. -/
inductive Exit where
  /-- The return registers, and the incoming area's bytes `[fp + 16, fp + 16 + argSize)`
  (the caller's outgoing area). -/
  | ret (regs : Regs) (incoming : List AbstractByte)
  /-- A tail call: the callee, its argument registers, and its stack arguments at `sp`
  (`fp + 16`: the incoming area, which the callee takes over). -/
  | tailCall (callee : Callee) (args : Regs) (sp : Nat) (stack : List AbstractByte)
  /-- Unwinding out of the function. -/
  | unwind (exc : ThinPointer)
deriving DecidableEq, Repr, Inhabited

structure Final where
  exit : Exit
  world : World
deriving Repr, Inhabited

/-! ### Code and state -/

/-- A function's R code and what its steps need from outside it. -/
structure Code where
  d : Decoded
  mode : Ryo.Obj.Mode
  /-- Where the image's addressed things are (`view`'s placement). -/
  ρ : Addrs
  /-- The function's incoming stack-argument area (`FuncEntry::arg_size`). -/
  argSize : Nat := 0
  /-- Per call or tail call instruction, its stack-argument bytes (the callee's `arg_size`, the
  certificate's `ArgPlan` stack size). -/
  stackSize : Nat → Nat := fun _ => 0
  /-- Per call with an sret destination, the size of the callee's return type. -/
  sretSize : Nat → Option Nat := fun _ => none
  /-- Per island, its template (the diagnostic item name `Ryo.Vm.R.Islands` knows), from its
  symbol. -/
  islandTemplate : Nat → Option String := fun _ => none

instance : Inhabited Code := ⟨{ d := default, mode := default, ρ := fun _ => none }⟩

/-- The cleanup entry of instruction `k`: `some (some pad, catch)`, `some (none, _)` to
continue unwinding, `none` if it has none. -/
def Code.cleanupAt (c : Code) (k : Nat) : Option (Option Nat × Bool) :=
  (c.d.cleanup.find? (·.1 == k)).map (·.2)

/-- Whether instruction `k`'s landing pad catches (what an unwinder's search phase asks). -/
def Code.catchesAt (c : Code) (k : Nat) : Bool :=
  match c.cleanupAt k with
  | some (some _, true) => true
  | _ => false

/-- An R function's state (see the module comment). -/
structure RState where
  pc : Nat
  fp : Nat
  st : OpSem.State
  /-- The incoming argument registers. -/
  args : Regs := {}

instance : Inhabited RState := ⟨⟨0, 0, {}, {}⟩⟩

def RState.world (s : RState) : World := ⟨s.st.mem, s.st.exposed⟩

def RState.withWorld (s : RState) (w : World) : RState :=
  { s with st := { s.st with mem := w.mem, exposed := w.exposed } }

/-- What a step gives: the next state, an external event with the state waiting at it (`pc`
still the call's; `answer` continues it), or the end of the function. -/
inductive Out where
  | step (s : RState)
  | ext (q : Query) (s : RState)
  | done (f : Final)

instance : Inhabited Out := ⟨.done default⟩

/-! ### Scopes -/

/-- The address of frame offset `off`, `φ_AOT`. -/
def frameAddr (fp : Nat) (off : Int) : M Nat :=
  let a : Int := fp + off
  if a < 0 then illFormed s!"frame offset {off} below address 0" else pure a.toNat

/-- `Escape [off, off + size)` with alignment `align`: an allocation at `fp + off` holding the
frame's current bytes, exposed; nothing if an escaped object contains the range. -/
def escape (s : RState) (off : Int) (size align : Nat) : M RState := do
  let st := s.st
  if st.escaped.any (fun e => decide (e.off ≤ off ∧ off + size ≤ e.off + e.size)) then return s
  if st.escaped.any (fun e => decide (e.off < off + size ∧ off < e.off + e.size)) then
    illFormed s!"escape of [{off}, {off + size}) partly overlaps an escaped object"
  let addr ← frameAddr s.fp off
  let al := Align.ofBytes align
  if !al.isAligned addr then illFormed s!"escaped object at {off} misaligned for {align}"
  if st.mem.allocs.any (fun a => a.live && a.overlaps addr size) then
    illFormed s!"escaped object at {off} overlaps a live allocation"
  let bytes ← st.readFrame off size
  let a : Allocation :=
    { data := bytes.toArray, addr, align := al, kind := .stack, vtableRo := by simp }
  let id := st.mem.allocs.size
  pure { s with st := { st with mem := ⟨st.mem.allocs.push a⟩,
                                escaped := st.escaped ++ [⟨off, size, id⟩],
                                exposed := st.exposed ++ [id] } }

/-- Deallocate the escaped objects `es`. -/
def freeObjs (mem : Memory) (es : List EscapedObj) : Memory :=
  es.foldl (fun m e => match m.get? e.id with
    | some a => ⟨m.allocs.set! e.id { a with live := false }⟩
    | none => m) mem

/-- `End [off, off + size)`: the escaped objects it covers whole are deallocated, and the
bytes it covers become private and `Uninit` (an object it covers partly stays escaped, those
bytes of it `Uninit`). -/
def storageEnd (s : RState) (off : Int) (size : Nat) : M RState := do
  let st := s.st
  let (gone, kept) := st.escaped.partition fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)
  let st := { st with mem := freeObjs st.mem gone, escaped := kept }
  let st ← st.writeFrame off (List.replicate size .uninit)
  pure { s with st }

def applyScope (s : RState) (sc : Scope) : M RState :=
  match sc.kind with
  | .escape a => escape s sc.frameOffset.toInt sc.size a
  | .end => storageEnd s sc.frameOffset.toInt sc.size
  | .lend => pure s

/-- The scopes before instruction `k`, in order. -/
def Code.scopesAt (c : Code) (k : Nat) : List Scope :=
  (c.d.scopes.toList.filter (·.1 == k)).map (·.2)

/-- The `Lend` extents before instruction `k`. -/
def Code.lendsAt (c : Code) (k : Nat) : List (Int × Nat) :=
  (c.scopesAt k).filterMap fun sc => if sc.kind == .lend then some (sc.frameOffset.toInt, sc.size) else none

/-- The end of the function: every escaped object deallocated. -/
def exit (s : RState) (e : Exit) : Final :=
  { exit := e, world := ⟨freeObjs s.st.mem s.st.escaped, s.st.exposed⟩ }

/-! ### Calls -/

/-- `bs` zero-extended to `n` bytes (a register loaded from a narrower slot). -/
def zext (bs : List AbstractByte) (n : Nat) : List AbstractByte :=
  bs ++ List.replicate (n - bs.length) (.ofByte 0)

/-- The argument registers a call's list `ws` of (slot, register word) pairs builds: by value,
the slot's bytes at the register's size; by address (`ARG_ADDR`, an integer register of 8
bytes), a pointer to the slot, which must be escaped (`addrOf`). -/
def argRegs (st : OpSem.State) : List (BitVec 32) → M Regs
  | [] => pure {}
  | [_] => illFormed "an argument list of odd length"
  | s :: r :: rest => do
    let rs ← argRegs st rest
    let rn := r.toNat
    let byAddr := rn &&& Asm.argAddr != 0
    let some a := Asm.ArgReg.of? (if byAddr then rn - Asm.argAddr else rn) false
      | illFormed s!"argument register word {rn}"
    let reg := Reg.ofArgReg a
    if rs.vals.any (·.1 == reg) then illFormed s!"argument register {repr reg} passed twice"
    let bs ← if byAddr then do
        if a.xmm || a.size != 8 then illFormed s!"by-address argument in {repr reg}"
        pure (encodePtr (← st.addrOf s.toInt))
      else st.readFrame s.toInt a.size
    pure ⟨(reg, zext bs reg.width) :: rs.vals⟩

/-- The parts of return kind `k` with their registers, in order (`part_regs`): integer parts
in `rax` then `rdx`, `xmm` parts in `xmm0` then `xmm1`. `load` as `ret_parts`'. -/
def retRegs (k : Nat) (load : Bool) : M (List (Asm.RetPart × Reg)) := do
  let some (a, b) := Asm.retParts k load | illFormed s!"return kind {k}"
  let ps := [a, b].filterMap id
  pure (ps.foldl (fun (acc, g, x) p =>
    if p.xmm then (acc ++ [(p, Reg.xmm x)], g, x + 1) else (acc ++ [(p, Reg.gpr g)], g + 1, x))
    ([], 0, 0)).1

/-- A call's or tail call's callee. -/
def callee (st : OpSem.State) (f : Full.Opcode) (o : Opnd Nat) : M Callee := do
  match o with
  | .func g => if f == .call || f == .tailCall then pure (.func g) else illFormed "callee"
  | .sym s =>
    if f == .callSym then pure (.sym s)
    else if f == .callSymInd then pure (.symInd s)
    else illFormed "callee"
  | .slot p =>
    if f == .callPtr || f == .tailCallPtr then pure (.ptr (← asPtr (← st.readFrame p.toInt 8)))
    else illFormed "callee"
  | _ => illFormed "callee"

/-! ### The step -/

/-- Unwinding from instruction `s.pc` with exception object `exc`: to its landing pad, out of
the function for a `continue` entry; UB without an entry. -/
def unwindAt (c : Code) (s : RState) (exc : ThinPointer) : M Out :=
  match c.cleanupAt s.pc with
  | some (some pad, _) => pure (.step { s with pc := pad, st := { s.st with exception := exc } })
  | some (none, _) => pure (.done (exit s (.unwind exc)))
  | none => ub s!"unwinding through instruction {s.pc}, which has no call-site entry"

/-- An instruction `opSem` gives the meaning of (through `view`), or `resume`. -/
def stepView (c : Code) (s : RState) (i : Insn) (ch : OpSem.Choice) : M Out := do
  let some v := view c.mode c.ρ i | illFormed s!"instruction {s.pc} has no view"
  let some t := v.ctl | illFormed s!"instruction {s.pc} ({v.op.mnemonic}) is not an operation"
  if v.op == .resume then
    let [.slot x] := v.ops | illFormed "resume's operands"
    return ← unwindAt c s (← asPtr (← s.st.readFrame x 8))
  let (ctl, st) ← opSem v.op v.ops s.st ch
  let some pc := t.succ s.pc ctl | illFormed s!"{v.op.mnemonic}'s control flow"
  pure (.step { s with pc, st })

/-- One step of the instruction at `s.pc`, its scopes first (see the module comment). -/
def step (c : Code) (s : RState) (ch : OpSem.Choice := {}) : M Out := do
  let some i := c.d.insns[s.pc]? | illFormed s!"no instruction {s.pc}"
  let s ← (c.scopesAt s.pc).foldlM applyScope s
  let .native op ops := i | stepView c s i ch
  let some f := op.full | illFormed s!"{op.mnemonic} isn't a full opcode"
  match f.info.shape, ops with
  | .jmp, [.target t] => pure (.step { s with pc := t })
  | .arg, [.slot d, .imm r] =>
    let some a := Asm.ArgReg.of? r.toNat true | illFormed s!"arg register word {r.toNat}"
    let st ← s.st.writeFrame d.toInt ((s.args.get (.ofArgReg a)).take a.size)
    pure (.step { s with pc := s.pc + 1, st })
  | .ret, [.slot src, .imm k] =>
    let parts ← retRegs k.toNat true
    let regs ← parts.foldlM (init := ({} : Regs)) fun rs (p, r) => do
      pure (rs.set r (zext (← s.st.readFrame (src.toInt + p.off) p.size) r.width))
    let incoming ← s.st.readFrame 16 c.argSize
    pure (.done (exit s (.ret regs incoming)))
  | .call, [.slot _, fo, .imm k, .words ws] =>
    let _ ← retRegs k.toNat false
    let cal ← callee s.st f fo
    let regs ← argRegs s.st ws
    let sp ← frameAddr s.fp (-(c.d.frameSize : Int))
    let stack ← s.st.readFrame (-(c.d.frameSize : Int)) (c.stackSize s.pc)
    let st ← match c.sretSize s.pc, Frame.sretDest ws with
      | some n, some dst => s.st.writeFrame dst.toInt (List.replicate n .uninit)
      | _, _ => pure s.st
    let s := { s with st }
    pure (.ext ⟨.call cal regs sp stack, s.world⟩ s)
  | .tailCall, [fo, .words ws] =>
    let cal ← callee s.st f fo
    let regs ← argRegs s.st ws
    let stack ← s.st.readFrame 16 (c.stackSize s.pc)
    pure (.done (exit s (.tailCall cal regs (s.fp + 16) stack)))
  | .island, [.sym isl, .words ws] =>
    pure (.ext ⟨.island isl (c.islandTemplate s.pc) s.fp (ws.map (·.toInt)) (c.lendsAt s.pc), s.world⟩ s)
  | .jmp, _ | .arg, _ | .ret, _ | .call, _ | .tailCall, _ | .island, _ =>
    illFormed s!"{op.mnemonic}'s operands"
  | _, _ => stepView c s i ch

/-- Write `new` (`[]`: unchanged) over the ranges `rs`, each list the range's size. -/
def writeRanges (st : OpSem.State) (rs : List (Int × Nat)) (new : List (List AbstractByte)) : M OpSem.State := do
  if new.isEmpty then return st
  if new.length != rs.length then illFormed "an answer's frame bytes don't match the ranges"
  (rs.zip new).foldlM (init := st) fun st ((off, n), bs) => do
    if bs.length != n then illFormed s!"an answer's bytes for [{off}, {off + n}) have the wrong length"
    st.writeFrame off bs

/-- Continue the state `s` waiting at a call or island (`step`'s `ext`) with the answer `a`. -/
def answer (c : Code) (s : RState) (a : Answer) : M Out := do
  let some (.native op ops) := c.d.insns[s.pc]? | illFormed s!"no call at {s.pc}"
  let some f := op.full | illFormed s!"no call at {s.pc}"
  let s := s.withWorld a.world
  match f.info.shape, ops with
  | .call, [.slot d, _, .imm k, _] =>
    let st ← writeRanges s.st [(-(c.d.frameSize : Int), c.stackSize s.pc)] a.frame
    let s := { s with st }
    match a.result with
    | .unwind exc => unwindAt c s exc
    | .ret regs =>
      let parts ← retRegs k.toNat false
      let st ← parts.foldlM (init := s.st) fun st (p, r) =>
        st.writeFrame (d.toInt + p.off) ((regs.get r).take p.size)
      pure (.step { s with pc := s.pc + 1, st })
  | .island, _ =>
    let st ← writeRanges s.st (c.lendsAt s.pc) a.frame
    let s := { s with st }
    match a.result with
    | .unwind exc => unwindAt c s exc
    | .ret _ => pure (.step { s with pc := s.pc + 1 })
  | _, _ => illFormed s!"no call at {s.pc}"

/-- The state at entry: `fp`, the argument registers, the stack arguments at `fp + 16`, the
world; every other frame byte `Uninit`. -/
def entry (fp : Nat) (args : Regs) (stack : List AbstractByte) (w : World) : M RState := do
  let st : OpSem.State := { mem := w.mem, exposed := w.exposed }
  pure ⟨0, fp, ← st.writeFrame 16 stack, args⟩

end Ryo.Vm.R
