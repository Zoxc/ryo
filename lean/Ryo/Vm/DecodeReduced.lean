/-
Ryo.Vm.DecodeReduced — machine code back to R (aot.md §C2): `decodeReduced`, a port of Rust's
`asm::decode_reduced` (`vm/bytecode/src/asm/decode.rs`, with `asm/reduced.rs`'s `words`).

It accepts only the canonical sequences (`asm::x86`, read by `Ryo.X86.decodeItem`), with operand
registers set in order, and recovers every operand, the frame size and the unwind entries:

- the prologue and epilogue of the frame size (`push rbp; mov rbp, rsp; sub rsp, F`, or
  `sub rsp, F + 8` without a frame pointer; a stack probe from 4096 bytes; PE's epilogue
  `add rsp, F; pop rbp`);
- with `Mode.counters`, the entry's and each loop head's counter check
  (`inc qword [rip + rec]; jns stub`, a loop head's on the loop counter, `rec + 56`) and the
  stubs after the code, in order;
- the `arg`s at the start, calls and tail calls (argument loads, call, result stores),
  islands, `ret`, `jmp`, and every handler call as `handler h args then`, its argument
  registers read from `rdi` on (on PE the Win64 positions `rcx, rdx, r8, r9` and the stack,
  `Asm.handlerPos`) (`fp`, the exception object, an immediate or an address), then
  its shape's control flow (a branch on `al`, a jump table, `ud2`); a `switch.dense.w8-w64`
  whose index computation (`Asm.denseIndex`) stands in for the call, read as that handler call
  (`denseSwitch`); `unreachable`, a bare `ud2`;
- inline sequences, as the register cache (`Ryo.Vm.Asm.Cache`) emits them: the decoder runs
  the same cache, cleared at branch targets (known after a first pass) and by every
  instruction that isn't inline, and accepts a sequence only if emitting its instruction
  again gives exactly its items; the stores the encoder dropped (`DroppedStore`) end their
  sequence where they would have been;
- loop-head padding (`Mode.alignLoops`), jump tables and their `int3` padding;
- the call sites (from the LSDA) against the calls, landing pads that are `lpad`s, and the
  scopes, placed before the first instruction at or after their position;
- PE (design/vm.md#unwinding): the `nop` after a call with a landing pad that ends its
  instruction (`Proto.bare`), and the pad region: from the first cleanup landing pad on, behind
  its entry `sub rsp, 40; jmp r11` after the counter stubs, with no padding or counter checks,
  `resume` as `add rsp, 40; ret` (taking the landing pads' exception slot, `resumeSlots`), and no
  branch across its start.

The functions mirror Rust's one for one, including their quirks (`arg`'s cursor after a
failed `movd` pair; `binary_search`'s choice among equal positions; `u32` wrapping where Rust
wraps, and its checked sums: a result piece's offset, the pad region's entry).
Loops that Rust runs until the code ends take fuel (the code's length, plus the dropped stores
for the instruction loop), which they never exhaust: every element read is at least one byte
(`decodeItem_pos`).

Beyond Rust (aot.md §C2): the Rust decoder trusts the list of dropped stores; the Lean one
checks their deadness by a backward liveness over the decoded code, `Ryo.Vm.Frame.decodeChecked`
(`decodeReducedWith` and `Frame.droppedNotDead`). `decodeReduced` itself trusts the list, as
Rust does, so that the two can be diffed. Likewise `decodeBounded` checks that every frame access
lies in the frame (`Decoded.boundsOk`, see "Frame bounds"), which Rust's decoder doesn't.

`Inputs` is the JSON form of one function's decoder inputs, read by `ryo-lean decode` and by the
test vectors:

```
{ "mode": <bits: 1 fp_arg | 2 frame_pointer | 4 align_loops | 8 pe | 16 counters>,
  "code": "<hex>", "rodata": "<hex>",
  "relocs": [[<at>, "<ref>"], …],        -- sorted by `at`; <ref>: "handler <Name or number>",
                                         -- "probe", "func <i>", "sym <i>",
                                         -- "const <off>", "data <off>", "ro <off>", "rec", "recloopctr"
  "call_sites": [[<start>, <len>, <pad or null>, <catches>], …],
  "dropped": [[<at>, <frame_offset>, <size>, <reg number>], …],   -- sorted by `at`
  "scopes": [[<code_offset>, <frame_offset>, <size>, <align, null for an end, or "lend">], …] }
```
-/
import Ryo.Vm.Asm
import Ryo.Vm.R.View
import Ryo.Vm.OpSem.Footprint
import Lean.Data.Json

set_option linter.constructorNameAsVariable false

namespace Ryo.Vm

open Ryo.X86 Ryo.Vm.R Ryo.Vm.Asm

/-- Why machine code isn't the canonical form of any function (`asm::AsmError`). -/
structure AsmError where
  at_ : Nat
  what : String
deriving DecidableEq, Repr, Inhabited

def AsmError.text (e : AsmError) : String := s!"error at {e.at_}: {e.what}"

/-- The decoder's state: the cursor (its position and, without a frame pointer, the frame
size). -/
abbrev DM := StateT Cursor (Except AsmError)

namespace DM

def pos : DM Nat := do return (← get).pos

def setPos (p : Nat) : DM Unit := modify fun c => { c with pos := p }

def err {α : Type} (at_ : Nat) (what : String) : DM α := throw ⟨at_, what⟩

/-- `c.item().ok()`: the element at the cursor, or `none` with the cursor unmoved. -/
def tryItem : DM (Option Item) := do
  let c ← get
  match decodeItem c with
  | some (i, n) => set { c with pos := c.pos + n }; return some i
  | none => return none

/-- `c.item()?`. -/
def item : DM Item := do
  match ← tryItem with
  | some i => return i
  | none => err (← pos) "not a canonical instruction"

def atEnd : DM Bool := do let c ← get; return c.pos ≥ c.code.size

def fuel : DM Nat := do return (← get).code.size + 2

/-- `Cursor::padding`: 9-byte `nop`s, then at most one shorter one; its length. -/
def padding : DM Nat := do
  let start ← pos
  for _ in [0:← fuel] do
    let c ← get
    let some n := ((List.range 9).reverse.map (· + 1)).find? fun n =>
        c.bytes n == some (nops.getD n []) | break
    if c.relocsHere n != [] then break
    setPos (c.pos + n)
    if n != 9 then break
  return (← pos) - start

/-- `Cursor::table_padding`: `int3`s up to a multiple of 4. -/
def tablePadding : DM Unit := do
  for _ in [0:4] do
    let c ← get
    if c.pos % 4 == 0 then return
    if c.code[c.pos]? != some 0xcc then err c.pos "not a canonical instruction"
    setPos (c.pos + 1)

/-- `Cursor::table_entry`. -/
def tableEntry (base : Nat) : DM Nat := do
  let c ← get
  match c.tableEntry (BitVec.ofNat 32 base) with
  | some t => setPos (c.pos + 4); return t.toNat
  | none => err c.pos "not a canonical instruction"

/-- Whether the items at the cursor are `want`, read one after the other (the cursor past those
that are). -/
def expectItems : List Item → DM Bool
  | [] => return true
  | w :: want => do
    if (← tryItem) != some w then return false
    expectItems want

/-- The items at the cursor while `f` takes them (`take`). -/
def take (f : Item → Bool) : DM (List Item) := do
  let mut out : Array Item := #[]
  for _ in [0:← fuel] do
    let a ← pos
    match ← tryItem with
    | some it =>
      if f it then out := out.push it
      else setPos a; return out.toList
    | none => setPos a; return out.toList
  return out.toList

end DM

open DM

/-- Rust's `slice::binary_search` (1.99): the last of equal elements, or where it would go. -/
def rustBinarySearch (a : Array Nat) (x : Nat) : Except Nat Nat := Id.run do
  if a.size == 0 then return .error 0
  let mut size := a.size
  let mut base := 0
  for _ in [0:64] do
    if size ≤ 1 then break
    let half := size / 2
    let mid := base + half
    if !(a[mid]! > x) then base := mid
    size := size - half
  let v := a[base]!
  if v == x then return .ok base
  return .error (if v < x then base + 1 else base)

def sortedContains (a : Array Nat) (x : Nat) : Bool := (rustBinarySearch a x).toBool

/-- The frame size and the mode (`Frame`). -/
structure Frame where
  size : Nat
  mode : Mode
  /-- In the pad region (PE). -/
  region : Bool := false

def Frame.epilogue (fr : Frame) : List Item := Asm.epilogue fr.size fr.mode
def Frame.fp (fr : Frame) (r : Reg) : Item := fpItem r fr.mode

/-- An instruction being decoded (`Proto`): operands with byte-position targets, and its calls
that may be call sites (position, length). -/
structure Proto where
  op : Full.Opcode
  ops : List (Opnd Nat) := []
  handler : Option (List Arg × Then Nat) := none
  pos : Nat
  sites : List (Nat × Nat) := []
  dropped : Bool := false
  /-- With counters, a loop head's check: its stub's position and where the stub returns. -/
  counter : Option (Nat × Nat) := none
  /-- An inline instruction's items in the code (without its dropped store). -/
  items : List Item := []
  /-- Its last item is its call (a call storing no result, a PE island), which on PE a `nop`
  follows if it has a landing pad. -/
  bare : Bool := false
deriving Repr, Inhabited

def Proto.targets (p : Proto) : List Nat :=
  p.ops.flatMap Opnd.targetsOf ++ (match p.handler with
    | some (_, t) => t.targets
    | none => [])

/-- `op_may_unwind`. -/
def opMayUnwind (op : Full.Opcode) : Bool :=
  op == .call || op == .callSym || op == .callSymInd || op == .callPtr || op == .island ||
    op == .resume

/-- `addr_arg`: the argument value of the address of `r`, if a handler can take it. -/
def addrArg : Ref → Option Arg
  | .const k => some (.const k)
  | .data d => some (.data d)
  | .sym s => some (.sym s)
  | .ro o => some (.ro o)
  | _ => none

/-! ### Return values, calls and `arg` -/

/-- `parts_of`: the register parts the loads or stores `items` move, relative to the slot of
the first, and that slot. -/
def partsOf (items : List Item) : Option (BitVec 32 × List RetPart) :=
  go items #[] none none
where
  off (m : M) (base : Option (BitVec 32)) : Option (Nat × Option (BitVec 32)) :=
    let b := base.getD m.disp
    if m.base == .rbp then some ((m.disp - b).toNat, some b) else none
  go : List Item → Array RetPart → Option (BitVec 32) → Option Reg → Option (BitVec 32 × List RetPart)
    | [], parts, base, _ => some (base.getD 0, parts.toList)
    | it :: rest, parts, base, last =>
      match it with
      | .ld w false dst m =>
        if dst == .rax || dst == .rdx then do
          let (o, b) ← off m base
          go rest (parts.push ⟨false, w.bits / 8, o⟩) b none
        else if dst == .r11 && w == .w then do
          match rest with
          | [] => none
          | _ :: rest' =>
            let (o, b) ← off m base
            go rest' (parts.push ⟨true, 2, o⟩) b none
        else none
      | .st w r m =>
        if r == .rax || r == .rdx then do
          let (o, b) ← off m base
          let parts := match parts.back? with
            | some p =>
              if !p.xmm && last == some r && o == p.off + p.size then
                parts.pop.push { p with size := p.size + w.bits / 8 }
              else parts.push ⟨false, w.bits / 8, o⟩
            | none => parts.push ⟨false, w.bits / 8, o⟩
          go rest parts b (some r)
        else none
      | .shift _ _ reg _ => if last == some reg then go rest parts base last else none
      | .sse _ size _ m => do
        let (o, b) ← off m base
        go rest (parts.push ⟨true, size, o⟩) b none
      | .movd false _ _ =>
        match rest with
        | .st _ _ m :: rest' => do
          let (o, b) ← off m base
          go rest' (parts.push ⟨true, 2, o⟩) b none
        | _ => none
      | _ => none

/-- `ret`'s sequence: the loads into the return registers, the epilogue, `ret`. -/
def retSeq (fr : Frame) : DM (BitVec 32 × Nat) := do
  let at_ ← pos
  let items ← take fun
    | .ld .. | .sse false .. | .movd true .. => true
    | _ => false
  let some (s, parts) := (partsOf items).filter (·.2.length ≤ 2) | err at_ "return value loads"
  let k := retKind parts
  if retLoads k s != items || ((retParts k true).isNone && k != 0) then err at_ "return value loads"
  for want in fr.epilogue ++ [Item.ret] do
    let a ← pos
    if (← item) != want then err a "not the return sequence"
  return (s, k)

/-- A call's result stores, if any: the destination and the kind (slot 0 for none). -/
def resultSeq : DM (BitVec 32 × Nat) := do
  let at_ ← pos
  let items ← take fun
    | .st _ .rax _ | .st _ .rdx _ | .st _ .r11 _ | .shift _ _ .rax _ | .shift _ _ .rdx _
    | .sse true .. | .movd false .. => true
    | _ => false
  if let some (d, parts) := (partsOf items).filter (·.2.length ≤ 2) then
    let k := retKind parts
    if (retParts k false).isSome && resultStores k d == items then return (d, k)
  setPos at_
  return (0, 0)

/-- A call's argument registers' loads: (slot, register) words. -/
def params (mode : Mode) : DM (List (BitVec 32)) := do
  let mut out : Array (BitVec 32) := #[]
  for _ in [0:← fuel] do
    let at_ ← pos
    let next : Option (BitVec 32 × Nat) ← (do
      match ← tryItem with
      | some (.ld w false dst m) =>
        match intIndex dst mode with
        | some i => if m.base == .rbp then return some (m.disp, (ArgReg.mk false (w.bits / 8) i).word) else return none
        | none =>
          if dst == .r11 && w == .w && m.base == .rbp then
            match ← tryItem with
            | some (.movd true x .r11) => return some (m.disp, (ArgReg.mk true 2 x).word)
            | _ => return none
          else return none
      | some (.leaM dst m) =>
        match intIndex dst mode with
        | some i => if m.base == .rbp then return some (m.disp, (ArgReg.mk false 8 i).word ||| argAddr) else return none
        | none => return none
      | some (.sse false size x m) => return some (m.disp, (ArgReg.mk true size x).word)
      | _ => return none)
    match next with
    | some (s, w) => out := out.push s |>.push (BitVec.ofNat 32 w)
    | none => setPos at_; return out.toList
  return out.toList

inductive Pre
  | none
  | sym (s : Nat)
  | ptr (p : BitVec 32)

/-- A call or tail call at the cursor (`call_insn`), or `none` with the cursor unmoved. -/
def callInsn (fr : Frame) (dropped : List DroppedStore) : DM (Option Proto) := do
  let p0 ← pos
  let pre ← (do
    match ← tryItem with
    | some (.loadRip .rax (.sym s)) => return Pre.sym s
    | some (.ld .q false .rax m) => if m.base == .rbp then return Pre.ptr m.disp else setPos p0; return Pre.none
    | _ => setPos p0; return Pre.none)
  let ps ← params fr.mode
  let callAt ← pos
  if dropped.head?.any (·.at_ < callAt) then setPos p0; return none
  let aOp : Opnd Nat := .words ps
  let it ← tryItem
  let r : Option (Full.Opcode × List (Opnd Nat) × Bool) ← (do
    match it, pre with
    | some (.call (.func f)), .none => return some (.call, [.func f], true)
    | some (.callMem (.sym s)), .none => return some (.callSym, [.sym s], true)
    | some .callMemRax, .sym s => return some (.callSymInd, [.sym s], true)
    | some .callRax, .ptr p => return some (.callPtr, [.slot p], true)
    | _, _ =>
      -- A tail call: the epilogue and the jump.
      setPos callAt
      if !(← expectItems fr.epilogue) then return none
      match ← tryItem, pre with
      | some (.jmp (.func f)), .none => return some (.tailCall, [.func f, aOp], false)
      | some .jmpRax, .ptr p => return some (.tailCallPtr, [.slot p, aOp], false)
      | _, _ => return none)
  let some (op, ops, call) := r | setPos p0; return none
  if call then
    let site := (callAt, (← pos) - callAt)
    let (d, k) ← resultSeq
    let ops := .slot d :: ops ++ [.imm (BitVec.ofNat 64 k), aOp]
    return some { op, ops, pos := p0, sites := [site], bare := k == 0 }
  return some { op, ops, pos := p0 }

/-- An `arg` at the cursor: the store of an argument register to its slot. -/
def argInsn (mode : Mode) : DM (Option Proto) := do
  let p0 ← pos
  let some first ← tryItem | return none
  let r : Option (Option ArgReg × M) ← (do
    match first with
    | .st w src m =>
      let mut size := w.bits / 8
      for _ in [0:← fuel] do
        let at_ ← pos
        let i1 ← tryItem
        let i2 ← tryItem
        match i1, i2 with
        | some (.shift _ _ reg _), some (.st w2 s m2) =>
          if reg == src && s == src && m2.disp == m.disp + BitVec.ofNat 32 size then
            size := size + w2.bits / 8
          else setPos at_; break
        | _, _ => setPos at_; break
      return some ((intIndex src mode).map (ArgReg.mk false size ·), m)
    | .sse true size x m => return some (some ⟨true, size, x⟩, m)
    | .movd false x .r11 =>
      match ← tryItem with
      | some (.st _ _ m) => return some (some ⟨true, 2, x⟩, m)
      -- `c.item().ok()?`: out, the cursor past the `movd`.
      | some _ => return some (none, M.frame 0)
      | none => return none
    | _ => return some (none, M.frame 0))
  let some (a, m) := r | return none
  let end_ ← pos
  setPos p0
  let some a := a.filter (fun a => (ArgReg.of? a.word true).isSome && m.base == .rbp) | return none
  for w in argStore a m.disp mode.pe do
    if (← tryItem) != some w then setPos p0; return none
  if (← pos) != end_ then setPos p0; return none
  return some { op := .arg, ops := [.slot m.disp, .imm (BitVec.ofNat 64 a.word)], pos := p0 }

/-! ### Inline sequences -/

/-- An inline sequence at the cursor (`inline_insn`): items up to the one that writes the
result (or its dropped store; an overflow op's result store, kept or dropped, is followed by
its flag's, which ends it), or up to a conditional branch, which must be the sequence as
the cache emits it (with `exact`; else only its extent and target matter). The proto, the
cache after it and the dropped stores left; `none` with the cursor unmoved. -/
def inlineInsn (cache : Cache) (dropped : List DroppedStore) (exact : Bool) :
    DM (Option (Proto × Cache × List DroppedStore)) := do
  let p0 ← pos
  let mut items : Array Item := #[]
  let mut branch : Option (Cond × Nat) := none
  let mut wasDropped := false
  let mut dropAt := 0
  let mut dr := dropped
  let mut ended := false
  for _ in [0:(← fuel) + dropped.length] do
    if let some d := dr.head? then
      if d.at_ == (← pos) then
        dropAt := items.size
        items := items.push d.item
        wasDropped := true
        dr := dr.tail
        -- An overflow op's dropped result store: its flag's `setcc cl` follows.
        let p ← pos
        let next ← tryItem
        setPos p
        match next with
        | some (.setccCl _) => continue
        | _ => ended := true; break
    match ← tryItem with
    | some it =>
      if isInline it then
        let p ← pos
        let next ← tryItem
        setPos p
        let e := endsInlineAt it items.back? next
        items := items.push it
        if e then ended := true; break
      else
        match it with
        | .branch cond t _ =>
          if cond != .always && !items.isEmpty then
            branch := some (cond, t.toNat); ended := true; break
          else setPos p0; return none
        | _ => setPos p0; return none
    | none => setPos p0; return none
  if !ended then setPos p0; return none
  let its := items.toList
  if !exact then
    let (op, ops) : Full.Opcode × List (Opnd Nat) := match branch with
      | some (_, t) => (.jmp, [.target t])
      | none => (.abort, [])
    return some ({ op, ops, pos := p0 }, cache, dr)
  let accept (cand : List Item) (d : Full.Opcode × List (Opnd Nat)) : Option (Proto × Cache) :=
    let (out, after) := cache.emit cand
    if out != its then none
    else
      let items := if wasDropped then its.eraseIdx dropAt else its
      some ({ op := d.1, ops := d.2, pos := p0, dropped := wasDropped, items }, after)
  if let some d := decodeInline its branch then
    if let some (p, c) := accept its d then return some (p, c, dr)
  for cand in cache.unemit its do
    if let some d := decodeInline cand branch then
      if let some (p, c) := accept cand d then return some (p, c, dr)
  setPos p0
  return none

/-! ### Handler calls, tables, islands -/

/-- The jump table sequence and its `n` entries. -/
def table (n : Nat) : DM (List Nat) := do
  let at_ ← pos
  let .leaTable t ← item | err at_ "jump table"
  if (← item) != .loadTableEntry then err at_ "jump table"
  if (← item) != .addRaxRcx then err at_ "jump table"
  if (← item) != .jmpRax then err at_ "jump table"
  tablePadding
  if (← pos) != t.toNat then err at_ "jump table"
  let mut out : Array Nat := #[]
  for _ in [0:n] do
    out := out.push (← tableEntry t.toNat)
  return out.toList

/-- An island call: its symbol slot, the rodata offset of its operands, the call site. -/
def islandCall (fr : Frame) : DM (Nat × Nat × (Nat × Nat)) := do
  let at_ ← pos
  let bad {α : Type} : DM α := err at_ "island call"
  let (fpR, opsR) := if fr.mode.pe then (Reg.rcx, Reg.rdx) else (Reg.rdi, Reg.rsi)
  if (← item) != fr.fp fpR then bad
  let .lea r (.ro ops) ← item | bad
  if r != opsR then bad
  let site ← pos
  let .callMem (.sym isl) ← item | bad
  return (isl, ops, (site, 6))

/-- The control flow after `op`'s handler call (`then`): for a switch, a table of `n` cases and
the default. `hat` is the call's position, a call site for `resume`. -/
def thenSeq (op : Full.Opcode) (n hat : Nat) : DM (Then Nat × List (Nat × Nat)) := do
  let fixed (want : Item) : DM Unit := do
    let at_ ← pos
    if (← item) != want then err at_ "not the instruction's canonical sequence"
  match op.info.shape with
  | .op | .lpad => return (.next, [])
  | .br =>
    fixed .testAl
    let at_ ← pos
    match ← item with
    | .branch c t _ =>
      if c == .z || c == .nz then return (.branch (c == .z) t.toNat, []) else err at_ "branch"
    | _ => err at_ "branch"
  | .switch => return (.table (← table (n + 1)), [])
  | .trap =>
    let sites := if op == .resume then [(hat, 5)] else []
    fixed .ud2
    return (.trap, sites)
  | _ => err hat "not an instruction"

/-- The argument at position `i` of a handler call that setup item `it` sets (`handler_args`):
`fp`, the exception object, an immediate or an address in the position's register
(`handlerReg`), or PE's stack argument, a 32-bit immediate (`M.stackArg`). -/
def setupArg (fr : Frame) (i : Nat) (it : Item) : Option Arg :=
  match handlerReg fr.mode.pe i with
  | none => match it with
    | .stImm .d m imm => if m == M.stackArg then some (.imm (imm.setWidth 64)) else none
    | _ => none
  | some r =>
    if it == fr.fp r then some .fp
    else match it with
      | .mov g .rax => if g == r then some .exception else none
      | .setReg g v => if g == r then some (.imm v) else none
      | .lea g to => if g == r then addrArg to else none
      | _ => none

/-- The argument registers of a handler call from the register setup before it
(`handler_args`): position `i` from the `i`th item. -/
def handlerArgs (setup : List (Nat × Item)) (fr : Frame) (p0 : Nat) : DM (List Arg) := do
  let mut out : Array Arg := #[]
  for (at_, it) in setup do
    if out.size ≥ handlerPositions fr.mode.pe then err at_ "too many argument registers"
    let some a := setupArg fr out.size it | err p0 "operand registers out of order"
    out := out.push a
  return out.toList

/-- `ops_array`: the operand array at `at_` of the rodata (its count the word before). -/
def opsArray (ro : ByteArray) (at_ : Nat) : Option (List (BitVec 32)) := Id.run do
  let rd (p : Nat) : Option (BitVec 32) :=
    if p + 4 ≤ ro.size then
      some (BitVec.ofNat 32 (ro[p]!.toNat ||| ro[p+1]!.toNat <<< 8 ||| ro[p+2]!.toNat <<< 16 ||| ro[p+3]!.toNat <<< 24))
    else none
  if at_ < 4 then return none
  let some n := rd (at_ - 4) | return none
  let mut out : Array (BitVec 32) := #[]
  for i in [0:n.toNat] do
    match rd (at_ + 4 * i) with
    | some w => out := out.push w
    | none => return none
  return some out.toList

/-- `dense_switch`'s scan: the items at the cursor up to the table's `lea` (at most six, each a
load, an ALU operation, a `mov` of an immediate or a `cmov`), and the `lea`'s position. -/
def denseItems (c : Cursor) : Option (List Item × Nat) := go c.pos [] 7
where
  go (p : Nat) (acc : List Item) : Nat → Option (List Item × Nat)
    | 0 => none
    | k + 1 =>
      match decodeItem { c with pos := p } with
      | some (.leaTable _, _) => if acc.isEmpty then none else some (acc.reverse, p)
      | some (it, n) =>
        if (it matches .ld .. | .aluImm .. | .setReg .. | .alu .. | .cmov ..) && acc.length < 6 then
          go (p + n) (it :: acc) k
        else none
      | none => none

/-- The opcode of `switch.dense.wN` at width `w`. -/
def denseOp : W → Full.Opcode
  | .b => .switchDenseW8 | .w => .switchDenseW16 | .d => .switchDenseW32 | .q => .switchDenseW64

/-- A dense switch's index computation at the cursor (`dense_switch`, up to the table): its
width, slot `s`, `base`, case count `n` and the table's position, if the items there are
exactly `denseIndex` of them. -/
def denseScan (c : Cursor) : Option (W × BitVec 32 × BitVec 64 × BitVec 64 × Nat) := do
  let (its, at_) ← denseItems c
  let (some (.ld w _ _ m), some (.cmov ..)) := (its.head?, its.getLast?) | none
  let base : BitVec 64 := match (its[1]? : Option Item), (its[2]? : Option Item) with
    | some (.aluImm .sub _ _ imm), _ => match w with
      | .b => (imm.setWidth 8).setWidth 64
      | .w => (imm.setWidth 16).setWidth 64
      | .d => imm.setWidth 64
      | .q => imm.signExtend 64
    | some (.setReg .rcx v), some (.alu .sub _ _ (.reg .rcx)) => v
    | _, _ => 0
  let some (.setReg .rcx n) := (if its.length < 3 then none else its[its.length - 3]?) | none
  if denseIndex (denseOp w) m.disp base n != some its || m.base != .rbp then none
  some (w, m.disp, base, n, at_)

/-- The handler arguments of a dense switch in the reduced form (`dense_switch`): `s`, `base`
and the case count `n` in their registers, `fp` first with `Mode.fpArg`, the others 0. -/
def denseArgs (fr : Frame) (op : Full.Opcode) (s : BitVec 32) (base n : BitVec 64) :
    Option (List Arg) := do
  let l ← op.layout fr.mode.fpArg fr.mode.pe
  let mut args : Array Arg := Array.replicate l.regs (.imm 0)
  if fr.mode.fpArg then args := args.set! 0 .fp
  for (o, loc) in op.info.operands.zip l.locs do
    let v? : Option (BitVec 64) :=
      if o.name == "s" then some (s.setWidth 64)
      else if o.name == "base" then some base
      else if o.name == "table" then some n
      else none
    if let some v := v? then args := args.set! loc.reg (.imm v)
  return args.toList

/-- A dense switch whose index computation (`Asm.denseIndex`) stands in for its handler call,
with its jump table (`dense_switch`), as that handler call in the reduced form
(`denseArgs`); `none`, the cursor unmoved, if there is none at the cursor. -/
def denseSwitch (fr : Frame) : DM (Option Proto) := do
  let c ← get
  let some (w, s, base, n, at_) := denseScan c | return none
  setPos at_
  let ts ← table (n.toNat + 1)
  match denseArgs fr (denseOp w) s base n with
  | some args => return some { op := denseOp w, handler := some (args, .table ts), pos := c.pos }
  | none => err c.pos "no layout"

/-- One instruction that isn't inline (`insn`, in the reduced form) and isn't a dense switch's
index computation. -/
def insnCore (fr : Frame) (ro : ByteArray) : DM Proto := do
  let p0 ← pos
  let mut setup : Array (Nat × Item) := #[]
  let mut head : Option (Nat × Item) := none
  for _ in [0:← fuel] do
    let at_ ← pos
    let it ← item
    match it with
    | .setReg .. | .lea .. | .mov .. | .leaM .. => setup := setup.push (at_, it)
    | _ =>
      -- PE's handler stack argument (`M.stackArg`).
      if fr.mode.pe && it.isStackArg then setup := setup.push (at_, it)
      else head := some (at_, it); break
  let some (hat, h) := head | err p0 "not an instruction"
  let handlerOp : Option Full.Opcode := match h with
    | .call (.handler n) => (Full.Opcode.ofNat? n).filter (·.hasHandler)
    | _ => none
  if let some op := handlerOp then
    let args ← handlerArgs setup.toList fr p0
    let some l := op.layout fr.mode.fpArg fr.mode.pe | err p0 "no layout"
    let nreg := (op.info.operands.zip l.locs).findSome? fun (o, loc) => match o.kind with
      | .list .target => some loc.reg
      | .list .case8 | .list .case16 | .list .case32 | .list .case64 | .list .case128 => some (loc.reg + 1)
      | _ => none
    let n ← match nreg with
      | none => pure 0
      | some r => match (args[r]? : Option Arg) with
        | some (.imm v) => if v.toNat < 2 ^ 31 then pure v.toNat else err p0 "case count"
        | _ => err p0 "case count"
    let (t, sites) ← thenSeq op n hat
    return { op, handler := some (args, t), pos := p0, sites }
  -- `resume` in the pad region, `add rsp, 40; ret`: its slot is the landing pads' (`resumeSlots`).
  if fr.region && setup.isEmpty && h == .addRsp (BitVec.ofNat 32 peRegionAlloc) then
    let at_ ← pos
    if (← item) != .ret then err at_ "not the pad region's return"
    return { op := .resume, handler := some ([], .trap), pos := p0 }
  match h with
  | .ld .. | .sse .. | .leave | .popRbp | .addRsp _ =>
    if setup.isEmpty then
      setPos p0
      let (s, k) ← retSeq fr
      return { op := .ret, ops := [.slot s, .imm (BitVec.ofNat 64 k)], pos := p0 }
    else err hat "not an instruction"
  -- A handler call's `ud2` is read with it (`thenSeq`): a bare one is `unreachable`.
  | .ud2 =>
    if setup.isEmpty then return { op := .unreachable, pos := p0 }
    else err hat "not an instruction"
  | .branch .always t _ =>
    if setup.isEmpty then return { op := .jmp, ops := [.target t.toNat], pos := p0 }
    else err hat "not an instruction"
  | .callMem _ =>
    -- An island: `fp`, `ops`, the call through the slot.
    setPos p0
    let (isl, opsRo, site) ← islandCall fr
    let some ws := opsArray ro opsRo | err p0 "island operands"
    let ops := [.sym isl, .words ws]
    return { op := .island, ops, pos := p0, sites := [site], bare := fr.mode.pe }
  | _ => err hat "not an instruction"

/-- One instruction that isn't inline (`insn`, in the reduced form): a dense switch's index
computation stands in for its handler call (`denseSwitch`), else `insnCore`. -/
def insn (fr : Frame) (ro : ByteArray) : DM Proto := do
  if let some p ← denseSwitch fr then return p
  insnCore fr ro

/-! ### The instruction loop and the function -/

/-- PE: a `nop` follows proto `q`, a call with a landing pad that ends its instruction. -/
def nopAfter (mode : Mode) (callSites : Array CallSite) (q : Proto) : Bool :=
  mode.pe && q.bare && q.sites.any fun (at_, _) => callSites.any fun cs => cs.start == at_ && cs.pad.isSome

/-- PE: the `nop` after proto `q`, a call with a landing pad that ends its instruction
(`nopAfter`): a `0x90` with no relocation in it. -/
def nopStep (mode : Mode) (callSites : Array CallSite) (q : Proto) : DM Unit := do
  if nopAfter mode callSites q then
    let c ← get
    if !(c.code[c.pos]? == some 0x90 && c.relocsHere 1 == []) then
      err c.pos "no nop after a call with a landing pad"
    setPos (c.pos + 1)

/-- The instructions from the cursor to `limit` (`instructions`), and whether each is padded.
With `targets` (sorted) the cache is cleared at them and inline sequences must be exact. With
counters the code ends at the counter stubs. In the pad region, no padding or counter checks. -/
def instructions (fr : Frame) (ro : ByteArray) (dropped : List DroppedStore)
    (targets : Option (Array Nat)) (entryStub : Option Nat) (limit : Nat)
    (callSites : Array CallSite) : DM (Array Proto × Array Bool) := do
  let mut protos : Array Proto := #[]
  let mut padded : Array Bool := #[]
  let mut cache : Cache := { pe := fr.mode.pe }
  let mut endPos := entryStub
  let mut dr := dropped
  for _ in [0:(← fuel) + dropped.length] do
    if (← pos) ≥ limit || some (← pos) == endPos then break
    -- A sequence that left no code (its reload hit the cache, its store was dropped) ends the
    -- block before a loop head's padding and counter check: none starts at a target.
    if dr.head?.any (·.at_ == (← pos)) then
      let p ← pos
      if let some (q, c, d) ← inlineInsn cache dr targets.isSome then
        cache := c
        dr := d
        padded := padded.push false
        protos := protos.push { q with pos := p }
        continue
    let pad ← padding
    let p ← pos
    if pad != 0 && (fr.region || !fr.mode.alignLoops || pad ≥ 16 || p % 16 != 0) then err p "padding"
    padded := padded.push (pad != 0)
    if targets.any (sortedContains · p) then cache := { pe := fr.mode.pe }
    let mut counter : Option (Nat × Nat) := none
    if fr.mode.counters && !fr.region then
      match ← tryItem, ← tryItem with
      | some (.ctrInc true), some (.branch .ns t _) =>
        counter := some (t.toNat, ← pos)
        if protos.all (·.counter.isNone) then endPos := some t.toNat
      | _, _ => setPos p
    let mut proto : Option Proto := none
    if protos.all (·.op == .arg) then
      proto ← argInsn fr.mode
    if proto.isNone then
      if let some q ← callInsn fr dr then
        cache := { pe := fr.mode.pe }
        proto := some q
    if proto.isNone then
      match ← inlineInsn cache dr targets.isSome with
      | some (q, c, d) =>
        proto := some q
        cache := c
        dr := d
      | none =>
        cache := { pe := fr.mode.pe }
        proto := some (← insn fr ro)
    let some q := proto | err p "not an instruction"
    nopStep fr.mode callSites q
    protos := protos.push { q with pos := p, counter }
  if !((← pos) ≥ limit || some (← pos) == endPos) then err (← pos) "decoder out of fuel"
  if let some d := dr.head? then err d.at_ "dropped store not at the end of a sequence"
  return (protos, padded)

/-- A function read from machine code (`Read`). -/
structure ReadResult where
  protos : Array Proto
  frameSize : Nat
  actions : Array (Option (Option Nat × Bool))
  scopes : Array (Nat × Scope)
  heads : Array Nat

/-- The argument registers of `resume` of slot `x` (`handler_args`): `fp` first with
`Mode.fpArg`, the slot in its operand's position. -/
def resumeArgs (fr : Frame) (x : BitVec 32) : List Arg :=
  match Full.Opcode.resume.layout fr.mode.fpArg fr.mode.pe with
  | some l => (List.range l.regs).map fun r =>
      if fr.mode.fpArg && r == 0 then .fp
      else if (l.locs.head?.map (·.reg)) == some r then .imm (x.setWidth 64) else .imm 0
  | none => []

/-- Gives each `resume` of the pad region (from proto `rs` on), which its return doesn't show,
the exception slot of the function's landing pads (`resume_slots`): every `lpad` and `resume` of
a function has the same, the first `lpad`'s last argument. -/
def resumeSlots (protos : Array Proto) (rs : Nat) (fr : Frame) : DM (Array Proto) := do
  let slot : Option (BitVec 32) := (protos.find? (·.op == .lpad)).bind fun p =>
    match p.handler with
    | some (args, _) => match args.getLast? with
      | some (.imm v) => some (v.setWidth 32)
      | _ => none
    | none => match p.ops.head? with
      | some (.slot s) => some s
      | _ => none
  let mut out := protos
  for i in [rs:protos.size] do
    let p := protos[i]!
    if p.op == .resume then
      let some x := slot | err p.pos "resume without a landing pad"
      out := out.set! i { p with handler := some (resumeArgs fr x, .trap) }
  return out

/-- `PE_REGION_ENTRY`'s length: the pad region's entry, `sub rsp, 40; jmp r11`. -/
def regionEntryLen : Nat := 7

/-- `read`'s prologue part: the entry's counter check (its stub and where the stub returns to),
the frame size (from the prologue's `sub`: less the 8 bytes in place of the saved `rbp` without a
frame pointer), and the prologue of that size; the cursor at the body, without a frame pointer
with `spFrame` the frame size. -/
def readFrame (mode : Mode) : DM (Option (Nat × Nat) × Nat) := do
  if !mode.valid then err 0 "unsupported mode"
  -- The entry's counter check.
  let entry : Option (Nat × Nat) ← (do
    if mode.counters then
      match ← tryItem, ← tryItem with
      | some (.ctrInc false), some (.branch .ns t _) => return some (t.toNat, ← pos)
      | _, _ => err 0 "no counter check at the entry"
    else return none)
  let start ← pos
  let mut alloc := 0
  for _ in [0:← fuel] do
    match ← tryItem with
    | some (.subRsp n) => alloc := n.toNat; break
    | some .pushRbp | some (.mov .rbp .rsp) | some (.setReg .rax _) | some (.call .probe) => continue
    | _ => break
  let frameSize := if mode.framePointer then alloc else u32 (alloc + 2 ^ 32 - 8)
  if frameSize % 16 != 0 then err 0 "frame size not a multiple of 16"
  setPos start
  for want in prologue frameSize mode do
    let at_ ← pos
    if (← tryItem) != some want then err at_ "not the prologue of the frame size"
  if !mode.framePointer then modify fun c => { c with spFrame := some (BitVec.ofNat 32 frameSize) }
  return (entry, frameSize)

/-- PE: the first cleanup landing pad, where the pad region starts (`encode::pe_region_start`),
if there is one. -/
def regionPad (mode : Mode) (callSites : Array CallSite) : Option Nat :=
  if mode.pe then ((callSites.toList.filter (!·.catches)).filterMap (·.pad)).min? else none

/-- The pad region's entry, right before its first cleanup landing pad (`regionPad`). -/
def regionEntry (mode : Mode) (callSites : Array CallSite) : DM (Option Nat) := do
  match regionPad mode callSites with
  | some p => if p < regionEntryLen then err p "no pad region entry" else return some (p - regionEntryLen)
  | none => return none

/-- `cond`, or the error `what` at `at_`. -/
def expect (cond : Bool) (at_ : Nat) (what : String) : DM Unit :=
  if cond then pure () else err at_ what

/-- The pad region from its entry at `r` (`sub rsp, 40; jmp r11`) to the code's end (`size`). -/
def readRegion (fr : Frame) (ro : ByteArray) (callSites : Array CallSite)
    (droppedRegion : List DroppedStore) (targets : Option (Array Nat)) (size r : Nat) :
    DM (Array Proto × Array Bool) := do
  setPos r
  let i1 ← item
  expect (i1 == .subRsp (BitVec.ofNat 32 peRegionAlloc)) r "not the pad region's entry"
  let i2 ← item
  expect (i2 == .jmpR11) r "not the pad region's entry"
  instructions { fr with region := true } ro droppedRegion targets none size callSites

/-- `read_parts`: the body's instructions from `body` to `limit` (with `stubs`, the counter
stubs, after the first loop head's check), and the pad region's (from its entry at
`regionAt`; the counter stubs come between, `checkStubs`), read with the targets `targets`;
and where the body ends. -/
def readParts (fr : Frame) (ro : ByteArray) (callSites : Array CallSite)
    (droppedBody droppedRegion : List DroppedStore) (stubs regionAt : Option Nat)
    (body limit size : Nat) (targets : Option (Array Nat)) : DM (Array Proto × Array Bool × Nat) := do
  setPos body
  let (protos, padded) ← instructions fr ro droppedBody targets stubs limit callSites
  let bodyEnd ← pos
  expect (fr.mode.counters || bodyEnd == limit) bodyEnd "an instruction across the pad region's entry"
  match regionAt with
  | none => return (protos, padded, bodyEnd)
  | some r =>
    let (rp, rpad) ← readRegion fr ro callSites droppedRegion targets size r
    return (protos ++ rp, padded ++ rpad, bodyEnd)

/-- The pad region's first instruction (proto `rs`) is right after its entry. -/
def checkRegionStart (protos : Array Proto) (rs : Nat) : Option Nat → DM Unit
  | none => pure ()
  | some r => expect ((protos[rs]?.map (·.pos)) == some (r + regionEntryLen)) (r + regionEntryLen)
      "pad region without instructions"

/-- The index of the instruction at byte position `b` (for a target of the instruction at
`at_`). -/
def indexAt (ipos : Array Nat) (at_ b : Nat) : DM Nat := match rustBinarySearch ipos b with
  | .ok i => pure i
  | .error _ => err at_ "target isn't an instruction"

/-- The loop heads: single branch targets at or before their branch, not in the pad region (from
proto `rs` on), which no branch crosses into or out of; checked against the padding and the
counter checks. -/
def loopHeads (mode : Mode) (protos : Array Proto) (padded : Array Bool) (rs : Nat) :
    DM (Array Nat) := do
  let ipos := protos.map (·.pos)
  let mut head := Array.replicate protos.size false
  for h : i in [0:protos.size] do
    let p := protos[i]
    for t in p.targets do
      if (decide ((← indexAt ipos p.pos t) ≥ rs)) != decide (i ≥ rs) then
        err p.pos "a branch across the pad region's start"
    let single := p.ops.filterMap fun
      | .target t => some t
      | _ => none
    let br : List Nat := match p.handler with
      | some (_, .branch _ t) => [t]
      | some (_, .table ts) => ts.getLast?.toList
      | _ => []
    for t in single ++ br do
      let j ← indexAt ipos p.pos t
      if j ≤ i && j < rs then head := head.set! j true
  for i in [0:protos.size] do
    if (padded[i]! && !head[i]!) || (mode.alignLoops && head[i]! && ipos[i]! % 16 != 0) then
      err ipos[i]! "loop head padding"
    if protos[i]!.counter.isSome != (mode.counters && head[i]!) then
      err ipos[i]! "counter check not at a loop head"
  return (List.range protos.size).filter (head[·]!) |>.toArray

/-- The counter stubs after the body (from `bodyEnd` to `limit`): the loop heads' in order, then
the entry's. -/
def checkStubs (entry : Option (Nat × Nat)) (protos : Array Proto) (heads : Array Nat)
    (bodyEnd limit : Nat) : DM Unit := do
  if let some (entryStub, entryBack) := entry then
    setPos bodyEnd
    let checks := heads.toList.map fun i => protos[i]!.counter.getD (0, 0)
    let all := checks ++ [(entryStub, entryBack)]
    for h : n in [0:all.length] do
      let (stub, back) := all[n]
      let at_ ← pos
      let bad {α : Type} : DM α := err at_ "counter stub"
      if at_ != stub then bad
      if (← item) != .lea .r11 .record then bad
      if n < heads.size then
        if (← item) != .setReg .rax (BitVec.ofNat 64 n) then bad
        if (← item) != .callR11 16 then bad
      else
        if (← item) != .callR11 8 then bad
      match ← item with
      | .branch .always t _ => if t.toNat != back then bad
      | _ => bad
    if (← pos) != limit then err (← pos) "code after the counter stubs"

/-- The unwind actions from the call sites (and the pad region's `resume`s, from proto `rs` on,
which continue unwinding). -/
def actionsOf (callSites : Array CallSite) (protos : Array Proto) (rs : Nat) :
    DM (Array (Option (Option Nat × Bool))) := do
  let ipos := protos.map (·.pos)
  let mut actions : Array (Option (Option Nat × Bool)) := Array.replicate protos.size none
  let mut used := 0
  for i in [0:protos.size] do
    let p := protos[i]!
    let mut action : Option (Option Nat × Bool) := none
    let mut missing := false
    for (s, l) in p.sites do
      match callSites.find? (·.start == s) with
      | some cs =>
        if cs.len == l then
          used := used + 1
          if action.any (· != (cs.pad, cs.catches)) || (cs.catches && cs.pad.isNone) then
            err s "call sites of one instruction disagree"
          action := some (cs.pad, cs.catches)
        else err s "call site length"
      | none => missing := true
    match action with
    | some (pad, catches) =>
      if missing then err ipos[i]! "call sites of one instruction disagree"
      if !opMayUnwind p.op then err ipos[i]! "call site of an instruction that can't unwind"
      let pad ← match pad with
        | none => pure none
        | some b => do
          let j ← indexAt ipos ipos[i]! b
          if protos[j]!.op != .lpad then err b "landing pad isn't an lpad"
          pure (some j)
      actions := actions.set! i (some (pad, catches))
    | none =>
      -- The pad region's `resume`, a return with no call site, continues unwinding.
      if p.op == .resume && i ≥ rs then actions := actions.set! i (some (none, false))
  if used != callSites.size then err 0 "call site outside every call"
  return actions

/-- `read`, handler calls in the reduced form. -/
def read (ro : ByteArray) (callSites : Array CallSite) (dropped : List DroppedStore)
    (scopes : Array Scope) (mode : Mode) : DM ReadResult := do
  let (entry, frameSize) ← readFrame mode
  let fr : Frame := ⟨frameSize, mode, false⟩
  let size := (← get).code.size
  -- PE: the pad region's entry, right before the first cleanup landing pad; the body (and the
  -- counter stubs) end there.
  let regionAt ← regionEntry mode callSites
  let limit := regionAt.getD size
  let droppedBody := match regionAt with
    | some r => dropped.takeWhile (·.at_ < r)
    | none => dropped
  let droppedRegion := match regionAt with
    | some r => dropped.dropWhile (·.at_ < r)
    | none => []
  -- Twice: the cache is cleared at branch targets, known once the whole function is read.
  let body ← pos
  let stubs := entry.map (·.1)
  let (protos1, _, _) ← readParts fr ro callSites droppedBody droppedRegion stubs regionAt body
    limit size none
  let targets := (protos1.toList.flatMap Proto.targets).toArray.qsort (· < ·)
  let (protos, padded, bodyEnd) ← readParts fr ro callSites droppedBody droppedRegion stubs
    regionAt body limit size (some targets)
  -- The index of the region's first instruction (the count without one).
  let rs := match regionAt with
    | some r => (protos.toList.takeWhile (·.pos < r + regionEntryLen)).length
    | none => protos.size
  checkRegionStart protos rs regionAt
  let heads ← loopHeads mode protos padded rs
  checkStubs entry protos heads bodyEnd limit
  -- `resume` in the pad region takes the landing pads' exception slot.
  let protos ← if rs < protos.size then resumeSlots protos rs fr else pure protos
  let actions ← actionsOf callSites protos rs
  -- Scopes: before the first instruction at or after their position.
  let ipos := protos.map (·.pos)
  let scopes := scopes.map fun sc => ((ipos.filter (· < sc.codeOffset)).size, sc)
  return { protos, frameSize, actions, scopes, heads }

/-- The R form of a function read (`reduced_of`, with `reduced::words`'s loop heads: with `pe`,
none from the first cleanup landing pad on, the pad region). -/
def reducedOf (r : ReadResult) (pe : Bool) : Except AsmError Decoded := do
  let ipos := r.protos.map (·.pos)
  let index (at_ b : Nat) : Except AsmError Nat := match rustBinarySearch ipos b with
    | .ok i => pure i
    | .error _ => throw ⟨at_, "target isn't an instruction"⟩
  let cleanup := (List.range r.actions.size).filterMap (fun i =>
    r.actions[i]!.map fun (pad, c) => (i, pad, c)) |>.toArray
  let region : Nat := if pe then
      ((cleanup.toList.filter (!·.2.2)).filterMap (·.2.1)).min?.getD r.protos.size
    else r.protos.size
  let dropped := (List.range r.protos.size).filter (r.protos[·]!.dropped) |>.toArray
  let mut insns : Array Insn := #[]
  for p in r.protos do
    match p.handler with
    | some (args, t) => insns := insns.push (.handler p.op args (← t.mapM (index p.pos)))
    | none =>
      let ops ← p.ops.mapM (·.mapTargets (index p.pos))
      let some op := Reduced.Opcode.ofFull p.op | throw ⟨p.pos, "not in the reduced set"⟩
      insns := insns.push (.native op ops)
  let mut head := Array.replicate insns.size false
  for h : k in [0:insns.size] do
    let single : List Nat := match insns[k] with
      | .native _ ops => ops.filterMap fun
        | .target t => some t
        | _ => none
      | .handler _ _ (.branch _ t) => [t]
      | .handler _ _ (.table ts) => ts.getLast?.toList
      | .handler .. => []
    for t in single do
      if t ≤ k && t < region then head := head.set! t true
  let heads := (List.range insns.size).filter (head[·]!) |>.toArray
  let items := r.protos.map (·.items)
  return { insns, frameSize := r.frameSize, cleanup, scopes := r.scopes, dropped, heads, items }

/-- Decodes one function's machine code, its `rel32` fields as `fields` says (relocations, or
linked code through a `LinkMap`), to R (`decode_reduced`, `decode_linked`). `dropped` sorted by
position. -/
def decodeReducedWith (code : ByteArray) (fields : Fields) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) : Except AsmError Decoded := do
  let c : Cursor := { code := code.data, pos := 0, fields }
  let (r, _) ← (read rodata callSites dropped.toList scopes mode).run c
  reducedOf r mode.pe

/-- `asm::decode_reduced`: one function's machine code with its relocations (sorted), code
constants, call sites, dropped stores and scopes, to R. -/
def decodeReduced (code : ByteArray) (relocs : Array Reloc) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) : Except AsmError Decoded :=
  decodeReducedWith code (.relocs relocs) rodata callSites dropped scopes mode

/-! ### Frame bounds (Lean only)

What the decoded code touches of its frame: each scope's range, the frame ranges each native
instruction writes (its footprint's), `arg`'s destination, `ret`'s 16-byte source, a call's
16-byte result slot and the frame ranges a handler call writes (its handler's footprint's, of
the operands `unpack` gives) (`frameRanges`). Of those, the writes (`writeRanges`: the native
and handler footprints' writes, `arg`'s destination, a call's result parts) must also miss the
frame's link slots `[0, 16)`: the saved `rbp` and the return address; `arg`'s destination must
lie below them. `boundsOk` accepts the code only if all frame ranges start at or above
`frameLo` and end at or below `frameTop`, the highest end (`0` if lower), with `F` and
`frameTop` at most `2 ^ 31`, and the writes miss the link slots. `frameLo` is `-F`, but on PE
the frame's bottom is the calls' 32 bytes of shadow space, which callees may write, and with a
handler call's stack argument (`M.stackArg`) the 8 bytes above them (`shadowSize`):
`Ryo.Proofs.DecodeLink.Bounds` turns it into `FrameBounds c frameTop`. Rust's decoder has no
such check (its test vectors take random slots), so `decodeReduced` doesn't make it, and stays
diffable; `decodeBounded` (and `Frame.decodeChecked`) do. -/

/-- The placement the bounds check reads operands with: no frame range depends on it (a
range's offset is a slot's, its length an immediate's or a case list's count). -/
def anyAddrs : Addrs := fun _ => some default

/-- The frame range `r` misses the link slots `[0, 16)`: the saved `rbp` at `0`, the return
address at `8`. -/
def offLink (r : Int × Nat) : Bool :=
  decide (r.1 + r.2 ≤ 0) || decide (16 ≤ r.1)

/-- The frame ranges a native instruction of opcode `f` with operands `ops` writes (its
footprint's, `wranges`), `[]` if its operands don't fit. -/
def nativeWrites (f : Full.Opcode) (ops : List (Opnd Nat)) : List (Int × Nat) :=
  if f.info.operands.length = ops.length then
    match (f.info.operands.zip ops).mapM (fun (i, o) => R.nativeVal anyAddrs i.kind o) with
    | some vals => match OpSem.footprint f with
      | some fp => fp.writeRanges (OpSem.opndVal f.info vals)
      | none => []
    | none => []
  else []

/-- The frame ranges a handler call of `h` with argument registers `args` writes (its handler's
footprint's, of the operands `unpack` gives), `[]` if they don't unpack. -/
def handlerWrites (mode : Mode) (h : Full.Opcode) (args : List Arg) : List (Int × Nat) :=
  match R.unpack anyAddrs h mode args with
  | some vals => match OpSem.footprint h with
    | some fp => fp.writeRanges (OpSem.opndVal h.info vals)
    | none => []
  | none => []

/-- `arg`'s destination, of operands `[slot d, imm r]`. -/
def argRange : List (Opnd Nat) → List (Int × Nat)
  | [.slot d, .imm r] => match ArgReg.of? r.toNat true with
    | some a => [(d.toInt, a.size)]
    | none => []
  | _ => []

/-- `ret`'s 16-byte source, of operands `[slot s, imm k]`. -/
def retRange : List (Opnd Nat) → List (Int × Nat)
  | [.slot s, .imm _] => [(s.toInt, 16)]
  | _ => []

/-- A call's 16-byte result slot, of operands `[slot d, callee, imm k, words]`. -/
def resultRange : List (Opnd Nat) → List (Int × Nat)
  | [.slot d, _, .imm _, .words _] => [(d.toInt, 16)]
  | _ => []

/-- The parts of a call's result slot it stores (`retParts k`'s), of operands
`[slot d, callee, imm k, words]`. -/
def resultParts : List (Opnd Nat) → List (Int × Nat)
  | [.slot d, _, .imm k, .words _] => match retParts k.toNat false with
    | some (a, b) => ([a, b].filterMap id).map fun p => (d.toInt + p.off, p.size)
    | none => []
  | _ => []

/-- The frame ranges of a native instruction of opcode `f` that `FrameBounds` bounds. -/
def nativeRanges (f : Full.Opcode) (ops : List (Opnd Nat)) : List (Int × Nat) :=
  nativeWrites f ops ++ (if f.info.shape = .arg then argRange ops
    else if f.info.shape = .ret then retRange ops
    else if f.info.shape = .call then resultRange ops else [])

/-- The frame ranges of instruction `i` that `FrameBounds` bounds. -/
def R.Insn.frameRanges (mode : Mode) : Insn → List (Int × Nat)
  | .native op ops => (op.full.map (nativeRanges · ops)).getD []
  | .handler h args _ => handlerWrites mode h args

/-- The frame ranges instruction `i` writes but `arg`'s destination (which `boundsOk` checks
below the link slots): its footprint's and a call's result parts. -/
def R.Insn.writeRanges (mode : Mode) : Insn → List (Int × Nat)
  | .native op ops => (op.full.map fun f => nativeWrites f ops ++
      (if f.info.shape = .call then resultParts ops else [])).getD []
  | .handler h args _ => handlerWrites mode h args

/-- `arg`'s destination, if `i` is an `arg`. -/
def R.Insn.argRanges : Insn → List (Int × Nat)
  | .native op ops => (op.full.map fun f =>
      if f.info.shape = .arg then argRange ops else []).getD []
  | .handler .. => []

/-- The scopes' and the instructions' frame ranges. -/
def R.Decoded.frameRanges (d : Decoded) (mode : Mode) : List (Int × Nat) :=
  d.scopes.toList.map (fun p => (p.2.frameOffset.toInt, p.2.size)) ++
    d.insns.toList.flatMap (Insn.frameRanges mode)

/-- The highest end of a frame range (at least `0`). -/
def R.Decoded.frameTop (d : Decoded) (mode : Mode) : Int :=
  (d.frameRanges mode).foldl (fun t r => max t (r.1 + r.2)) 0

/-- PE: the bytes at the frame's bottom its calls' callees may use: the 32 bytes of shadow space,
and with a handler call's stack argument (its fifth position) the 8 above (0 off PE). -/
def R.Decoded.shadowSize (d : Decoded) (mode : Mode) : Nat :=
  if !mode.pe then 0
  else if d.insns.any (fun | .handler _ args _ => args.length > 4 | _ => false) then 40 else 32

/-- The lowest frame offset the frame's ranges may start at: `-F`, above PE's shadow space. -/
def R.Decoded.frameLo (d : Decoded) (mode : Mode) : Int :=
  -(d.frameSize : Int) + d.shadowSize mode

/-- Every frame range lies in `[frameLo, frameTop)`, `F` and `frameTop` at most `2 ^ 31`;
every frame write misses the link slots, and every `arg` destination lies below them. -/
def R.Decoded.boundsOk (d : Decoded) (mode : Mode) : Bool :=
  decide (d.frameSize ≤ 2 ^ 31) && decide (d.frameTop mode ≤ 2 ^ 31) &&
    (d.frameRanges mode).all (fun r => decide (d.frameLo mode ≤ r.1)) &&
    d.insns.toList.all (fun i => (i.writeRanges mode).all offLink &&
      i.argRanges.all fun r => decide (r.1 + r.2 ≤ 0))

/-- `decodeReducedWith`, rejecting code whose frame ranges `boundsOk` doesn't accept. -/
def decodeBounded (code : ByteArray) (fields : Fields) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) : Except AsmError Decoded := do
  let d ← decodeReducedWith code fields rodata callSites dropped scopes mode
  if d.boundsOk mode then pure d else throw ⟨0, "frame access outside the frame"⟩

/-- The decoded function's text (`Decoded.toText`), or the error's. -/
def decodeText (r : Except AsmError Decoded) : String :=
  match r with
  | .ok d => d.toText
  | .error e => e.text ++ "\n"

/-! ### The inputs as JSON -/

section Json

open Lean

def hexDigit? (c : Char) : Option Nat :=
  if '0' ≤ c ∧ c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c ∧ c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c ∧ c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

def unhex (s : String) : Except String ByteArray := do
  let cs := s.toList.toArray
  if cs.size % 2 != 0 then throw "odd hex length"
  let mut out := ByteArray.emptyWithCapacity (cs.size / 2)
  for i in [0:cs.size / 2] do
    let (some a, some b) := (hexDigit? cs[2 * i]!, hexDigit? cs[2 * i + 1]!) | throw "bad hex digit"
    out := out.push (UInt8.ofNat (16 * a + b))
  return out

/-- A reference's text form (`handler <Name>`, `probe`, `func <i>`, …, `rec`, `recloopctr`). -/
def refOfString (s : String) : Except String Ref := do
  let num (x : String) : Except String Nat := match x.toNat? with
    | some n => pure n
    | none => throw s!"bad number in reference `{s}`"
  match s.splitOn " " with
  | ["handler", x] =>
    match x.toNat? with
    | some n => pure (.handler n)
    | none => match Full.all.find? (·.info.name == x) with
      | some op => pure (.handler op.val.toNat)
      | none => throw s!"unknown handler `{x}`"
  | ["probe"] => pure .probe
  | ["func", x] => .func <$> num x
  | ["sym", x] => .sym <$> num x
  | ["const", x] => .const <$> num x
  | ["data", x] => .data <$> num x
  | ["ro", x] => .ro <$> num x
  | ["rec"] => pure .record
  | ["recloopctr"] => pure .recordLoopCtr
  | _ => throw s!"bad reference `{s}`"

def i32OfJson (j : Json) : Except String (BitVec 32) := do
  let i : Int ← fromJson? j
  if i < -(2 ^ 31 : Int) ∨ i ≥ 2 ^ 32 then throw s!"{i} out of range for i32"
  pure (BitVec.ofInt 32 i)

/-- One function's decoder inputs (see the module comment for the JSON form). -/
structure Inputs where
  mode : Mode
  code : ByteArray
  relocs : Array Reloc
  rodata : ByteArray
  callSites : Array CallSite
  dropped : Array DroppedStore
  scopes : Array Scope
deriving Inhabited

def Inputs.ofJson (j : Json) : Except String Inputs := do
  let mode := Ryo.Obj.Mode.ofBits (← j.getObjValAs? Nat "mode")
  let code ← unhex (← j.getObjValAs? String "code")
  let rodata ← unhex (← j.getObjValAs? String "rodata")
  let relocs ← (← j.getObjValAs? (Array Json) "relocs").mapM fun r => do
    let at_ ← (← r.getArrVal? 0).getNat?
    let to ← refOfString (← (← r.getArrVal? 1).getStr?)
    pure ({ pos := at_, to } : Reloc)
  let callSites ← (← j.getObjValAs? (Array Json) "call_sites").mapM fun r => do
    let start ← (← r.getArrVal? 0).getNat?
    let len ← (← r.getArrVal? 1).getNat?
    let pad : Option Nat ← fromJson? (← r.getArrVal? 2)
    let catches ← (← r.getArrVal? 3).getBool?
    pure ({ start, len, pad, catches } : CallSite)
  let dropped ← (← j.getObjValAs? (Array Json) "dropped").mapM fun r => do
    let at_ ← (← r.getArrVal? 0).getNat?
    let off ← i32OfJson (← r.getArrVal? 1)
    let size ← (← r.getArrVal? 2).getNat?
    let reg ← (← r.getArrVal? 3).getNat?
    match DroppedStore.ofParts? at_ off size reg with
    | some d => pure d
    | none => throw s!"bad dropped store {r.compress}"
  let scopes ← (← j.getObjValAs? (Array Json) "scopes").mapM fun r => do
    let codeOffset ← (← r.getArrVal? 0).getNat?
    let frameOffset ← i32OfJson (← r.getArrVal? 1)
    let size ← (← r.getArrVal? 2).getNat?
    let k ← r.getArrVal? 3
    let kind ← if k == Json.str "lend" then pure ScopeKind.lend else do
      let align : Option Nat ← fromJson? k
      pure (match align with
        | some a => .escape a
        | none => .end)
    pure ({ codeOffset, frameOffset, size, kind } : Scope)
  return { mode, code, relocs, rodata, callSites, dropped, scopes }

def Inputs.decode (i : Inputs) : Except AsmError Decoded :=
  decodeReduced i.code i.relocs i.rodata i.callSites i.dropped i.scopes i.mode

end Json

end Ryo.Vm
