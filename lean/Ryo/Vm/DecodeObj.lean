/-
Ryo.Vm.DecodeObj — `decodeReduced` on the functions of an image object (`ryo-lean decode <obj>`),
printed as `scripts/lean-decode-ref` prints Rust's decoding (`ImageResolver::decode`), for
`scripts/lean-decode-diff.py --decode`.

`Ryo.Obj.funcInputs` gathers each function's inputs from the object. In an image object calls
between the image's functions carry no relocation (the writer resolves them), so the function's
code is decoded as linked code (`Fields.linked`, Rust's `decode_linked`, which the reference
uses too): the code is placed at a made-up address, its relocated fields pointed at made-up
addresses of their references, one range per kind, and the `LinkMap` maps those back, and
function starts to `Ref.func`. The side data comes from the function's instruction list
(`Ryo.Obj.List`): its dropped stores and scopes. Rust's `decode_linked` also takes the list's
branch targets and inline sequences' instruction entries as an index, read in one pass and
checked against the code; the Lean decoder reads the code in two passes as `decode_reduced`
does, without them, which gives the same result on a list that passes Rust's checks.

**Handler calls.** Handlers are linked at a handler table's addresses (`HandlerTable`,
`Resolver::handlers`), which needn't be distinct: LLVM's MergeFunctions or a linker's ICF fold
handlers with the same code, so an address alone doesn't say which opcode a call calls. As in
Rust, the opcode comes from the call's handler entry in the instruction list (`Hint.isHandler`,
`HANDLER_SEL`), which must be one of the opcodes the table registers at the call's target
(`registers`): `Fields::Linked` resolves such a target through the entry at the item's
position, else to `Field::Bad`. The Lean `LinkMap` sees only the target, not the item's
position, so `linkHandlerCalls` does that resolution ahead of decoding: it points each entry's
`call rel32` whose target registers the entry's opcode at that opcode's own slot (`opSlot`),
which `resolve` maps to `Ref.handler`; table addresses resolve to nothing, so a handler call
without its entry (or with one naming an opcode the table doesn't register there) is a bad
field, as in Rust. The decoded opcode's layout must then match the call's argument setup, as
for any handler call (`insnCore`). After reading, the handler calls must be exactly the
entries, position and opcode (`checkEntries`): a decoded handler call without its entry, or
an entry left over (stray), fails the decode with Rust's errors. The default table
(`distinctTable`) puts each opcode at its own address, as `scripts/lean-decode-ref` does;
nothing relies on it being injective.
-/
import Ryo.Vm.DecodeReduced
import Ryo.Vm.Frame
import Ryo.Obj
import Ryo.Obj.List

namespace Ryo.Vm.DecodeObj

open Ryo.X86 Ryo.Vm.R Ryo.Vm.Asm

/-- The made-up address map: the text at `text`, each kind of reference in a range below it. -/
def text : Nat := 0x4000_0000
/-- The opcodes' slots (`opSlot`): a handler call's target once its entry resolved it. -/
def opSlots : Nat := 0x0e00_0000
def probe : Nat := 0x0f00_0000
/-- The handler table's range (`handlersLen` bytes, `HandlerTable`). -/
def handlers : Nat := 0x1000_0000
def handlersLen : Nat := 0x0100_0000
def syms : Nat := 0x1100_0000
def consts : Nat := 0x1400_0000
def datas : Nat := 0x1800_0000
def ros : Nat := 0x1c00_0000
def record : Nat := 0x3f00_0000
/-- The size of the ranges from `consts` on. -/
def span : Nat := 0x0400_0000

def toRef : Ryo.Obj.Ref → Ref
  | .handler op => .handler op.val.toNat
  | .probe => .probe
  | .func i => .func i
  | .sym i => .sym i
  | .const o => .const o
  | .data o => .data o
  | .ro o => .ro o
  | .record => .record
  | .recordLoopCtr => .recordLoopCtr

/-- The handler table (`Resolver::handlers`' entries): each opcode's handler address, by
opcode value, in `[handlers, handlers + handlersLen)`. Several opcodes may share an address
(folded handlers). -/
abbrev HandlerTable := Nat → Nat

/-- Each opcode's handler at its own address, as `scripts/lean-decode-ref` places them. -/
def distinctTable : HandlerTable := fun op => handlers + 16 * op

/-- Whether `a` lies in the handler table's range. -/
def inTable (a : Nat) : Bool := handlers ≤ a && a < handlers + handlersLen

/-- Whether `op` is among the opcodes `table` registers at address `a` (`Resolver::handlers(a)`,
several for folded handlers). -/
def registers (table : HandlerTable) (a op : Nat) : Bool :=
  op < Full.count && inTable a && table op == a

/-- The slot standing for opcode `op`'s handler once a call's entry resolved it. -/
def opSlot (op : Nat) : Nat := opSlots + 16 * op

/-- The made-up address of a reference, if it fits its range: a handler's is its table
address (`linkHandlerCalls` resolves the calls). -/
def addrOf (funcStarts : Array Nat) (table : HandlerTable) : Ref → Option Nat
  | .handler op => if inTable (table op) then some (table op) else none
  | .probe => some probe
  | .func i => funcStarts[i]?.map (text + ·)
  | .sym s => if 8 * s < 0x0100_0000 then some (syms + 8 * s) else none
  | .const k => if k < span then some (consts + k) else none
  | .data d => if d < span then some (datas + d) else none
  | .ro o => if o < span then some (ros + o) else none
  | .record => some record
  | .recordLoopCtr => some (record + loopCtr)

/-- The inverse of `addrOf`, the `LinkMap` of the decoding (`Resolver::resolve`). A handler
table address resolves to nothing: a call there needs its entry (`linkHandlerCalls`, which
points it at its opcode's slot, resolved here). -/
def resolve (funcStarts : Array Nat) (a : BitVec 64) : Option Ref :=
  let a := a.toNat
  let inRange (base len : Nat) : Option Nat := if base ≤ a && a < base + len then some (a - base) else none
  if a == probe then some .probe
  else if let some d := inRange opSlots (16 * Full.count) then
    if d % 16 == 0 then some (.handler (d / 16)) else none
  else if inTable a then none
  else if let some d := inRange syms 0x0100_0000 then
    if d % 8 == 0 then some (.sym (d / 8)) else none
  else if let some d := inRange consts span then some (.const d)
  else if let some d := inRange datas span then some (.data d)
  else if let some d := inRange ros span then some (.ro d)
  else if a ≥ text then (funcStarts.findIdx? (· == a - text)).map .func
  else none

/-- `code`, at address `addr`, with its `rel32` field at `pos` pointing at `target`. -/
def putRel32 (code : ByteArray) (addr pos target : Nat) : ByteArray := Id.run do
  let d := BitVec.ofInt 32 ((target : Int) - (addr + pos + 4 : Nat))
  let mut code := code
  for k in [0:4] do
    if pos + k < code.size then
      code := code.set! (pos + k) (UInt8.ofNat ((d.toNat >>> (8 * k)) % 256))
  return code

/-- `Fields::Linked`'s handler targets, resolved ahead of decoding (the `LinkMap` doesn't see
the item's position): for the first handler entry at each position (`hints`, by position), a
`call rel32` there whose target `table` registers the entry's opcode at (`registers`) is
pointed at that opcode's slot (`opSlot`). Any other call into the table keeps its target,
which `resolve` leaves unresolved (`Field::Bad`). -/
def linkHandlerCalls (table : HandlerTable) (addr : Nat) (code : ByteArray)
    (hints : Array Ryo.Obj.Hint) : ByteArray := Id.run do
  let mut code := code
  let mut last : Option Nat := none
  for h in hints do
    if !h.isHandler || last == some h.pos then continue
    last := some h.pos
    if code.data[h.pos]? != some 0xe8 || h.pos + 5 > code.size then continue
    let d := BitVec.ofNat 32 (ofLeBytes (code.extract (h.pos + 1) (h.pos + 5)).toList)
    let to := (BitVec.ofNat 64 (addr + h.pos + 5) + d.signExtend 64).toNat
    let op := h.op.val.toNat
    if registers table to op then
      code := putRel32 code addr (h.pos + 1) (opSlot op)
  return code

/-- Function `f`'s decoder inputs, its code linked at the made-up addresses (handlers at
`table`'s, its handler calls resolved by the instruction entries `hints`,
`linkHandlerCalls`): the arguments of `decodeReducedWith` after the code; `none` for inputs
the reference can't decode either (a malformed instruction list). -/
def funcArgs (f : Ryo.Obj.FuncInputs) (hints : Array Ryo.Obj.Hint)
    (table : HandlerTable := distinctTable) :
    Except String (Option (ByteArray × Fields × Array DroppedStore × Array Scope)) := do
  let addr := text + f.codeOff
  let mut code := f.code
  for r in f.relocs do
    let to := toRef r.to
    let some t := addrOf f.funcStarts table to | throw s!"reference {repr to} past the made-up address map"
    code := putRel32 code addr r.pos t
  code := linkHandlerCalls table addr code hints
  let kind (k : Ryo.Obj.ScopeKind) : ScopeKind := match k with
    | .escape a => .escape a
    | .end => .end
    | .lend => .lend
  let scopes := f.scopes.map fun s => Scope.mk s.codeOffset (BitVec.ofInt 32 s.frameOffset) s.size (kind s.kind)
  let some dropped := f.dropped.mapM fun d => DroppedStore.ofParts? d.pos (BitVec.ofInt 32 d.frameOffset) d.size d.reg
    | return none
  let fields := Fields.linked (BitVec.ofNat 64 addr) (BitVec.ofNat 64 record) (resolve f.funcStarts)
  return some (code, fields, dropped, scopes)

/-- Function `i`'s instruction entries (`InsnList::hints`) from its instruction list; none if
the list is malformed (`funcInputs` then fails). -/
def listHints (o : Ryo.Obj.ImageObject) (i : Nat) : Array Ryo.Obj.Hint :=
  match o.image.function? i with
  | some f => ((Ryo.Obj.InsnList.read (o.image.list f) f.codeLen).map (·.hints)).getD #[]
  | none => #[]

/-- The handler call heading the instruction read from `p0` (`insn`'s head, after the
register setup and PE's stack argument), with cursor `c` (the decoding's, for its fields and
frame): its position and opcode value; `none` if it isn't one. -/
def handlerCallAt (c : Cursor) (pe : Bool) (p0 : Nat) : Option (Nat × Nat) := Id.run do
  let mut p := p0
  for _ in [0:c.code.size + 2] do
    let some (it, n) := decodeItem { c with pos := p } | return none
    match it with
    | .setReg .. | .lea .. | .mov .. | .leaM .. => p := p + n
    | .call (.handler op) => return some (p, op)
    | _ => if pe && it.isStackArg then p := p + n else return none
  return none

/-- The handler entries of `hints` are exactly the handler calls read (`r`, with the decoding's
cursor `c`), by position and opcode, in order: `insn`'s check that a handler call has its
entry ("handler call without its instruction list entry") and `instructions`' that no entry
is left over ("instruction list entry not at its inline sequence"): at the first mismatch the
call's error at the call while calls remain, as `insn` reports it, else the leftover entry's.
Rust raises the latter per part (the body, then PE's pad region) and before reading on, and
this runs after the whole read, so on a malformed list the error can still differ (a later
decode error, or a stray body entry reported after a pad-region call's). A handler call's
position is past its loop head's counter check. -/
def checkEntries (r : ReadResult) (c : Cursor) (pe : Bool) (hints : Array Ryo.Obj.Hint) :
    Except AsmError Unit := do
  let entries := hints.filterMap fun h => if h.isHandler then some (h.pos, h.op.val.toNat) else none
  let calls := r.protos.filterMap fun p =>
    if p.handler.isNone then none
    else handlerCallAt c pe (match p.counter with | some (_, after) => after | none => p.pos)
  for k in [0:max calls.size entries.size] do
    match calls[k]?, entries[k]? with
    | some (a, op), some (b, op') =>
      if a == b && op == op' then continue
      -- Rust's `insn` meets the call with another entry first: the call's error, also for a
      -- stray entry before it.
      throw ⟨a, "handler call without its instruction list entry"⟩
    | some (a, _), none => throw ⟨a, "handler call without its instruction list entry"⟩
    | none, some (b, _) => throw ⟨b, "instruction list entry not at its inline sequence"⟩
    | none, none => pure ()

/-- `decode_linked` on code `linkHandlerCalls` resolved: `decodeReducedWith`, the handler
calls checked against the handler entries of `hints` (`checkEntries`) before the reduced
form is built. -/
def decodeLinked (code : ByteArray) (fields : Fields) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) (hints : Array Ryo.Obj.Hint) : Except AsmError Decoded := do
  let c : Cursor := { code := code.data, pos := 0, fields }
  let (r, c) ← (Ryo.Vm.read rodata callSites dropped.toList scopes mode).run c
  checkEntries r c mode.pe hints
  reducedOf r mode.pe

/-- Function `f`'s decoding (`decodeLinked`, trusting the dropped stores as Rust does), with
its instruction entries `hints` (`listHints`) and handlers at `table`'s addresses; `none` as
for `funcArgs`. -/
def decodeFunc (f : Ryo.Obj.FuncInputs) (hints : Array Ryo.Obj.Hint)
    (table : HandlerTable := distinctTable) : Except String (Option (Except AsmError Decoded)) := do
  let some (code, fields, dropped, scopes) ← funcArgs f hints table | return none
  return some (decodeLinked code fields f.rodata f.callSites dropped scopes f.mode hints)

/-- Function `f`'s checked decoding (`Frame.decodeChecked`, given `facts`), once its handler
calls pass `decodeLinked`'s check; `none` as for `funcArgs`. -/
def decodeFuncChecked (f : Ryo.Obj.FuncInputs) (hints : Array Ryo.Obj.Hint)
    (facts : Frame.Facts := {}) (table : HandlerTable := distinctTable) :
    Except String (Option (Except String Decoded)) := do
  let some (code, fields, dropped, scopes) ← funcArgs f hints table | return none
  if let .error e := decodeLinked code fields f.rodata f.callSites dropped scopes f.mode hints then
    return some (.error s!"{e.what} at {e.at_}")
  return some (Frame.decodeChecked code fields f.rodata f.callSites dropped scopes f.mode facts)

/-- Each function of the image decoded (`decodeFunc`), `none` where it isn't. -/
def decodeAll (o : Ryo.Obj.ImageObject) : Array (Option (Ryo.Obj.FuncInputs × Decoded)) :=
  (Array.range o.funcs.size).map fun i => do
    let fi ← (o.funcInputs i).toOption
    let .ok (some (.ok d)) := decodeFunc fi (listHints o i) | none
    pure (fi, d)

/-- What the image itself says of decoded function `d`'s calls of image functions
(`call` of `Ref.func g`), for the dead-store check (`Frame.Facts`):

- `stackArgs`: `g`'s `arg_size`, if `g`'s own code accesses its incoming area only within
  it, tail calls included (`extents`, from `Frame.incomingExtents`). The callee's stack
  arguments are that area: what the call reads of the caller's frame besides the argument
  list is in its first `arg_size` bytes.
- no `sretSize`: an sret callee's `ret_size` isn't checked against its return type by any
  image check (C1''s to do), and making more bytes `Uninit` than L0's destination has would be
  unsound. The certificate check gives it for calls whose ABI the dump has.
- `islandTemplate`: an island's template by its symbol slot's name, as `islands` maps it
  (the C1' certificate's islands; none by default). -/
def imageFacts (o : Ryo.Obj.ImageObject) (extents : Array (Option Nat)) (d : Decoded)
    (islands : String → Option String := fun _ => none) : Frame.Facts :=
  let callee (k : Nat) : Option (Nat × Ryo.Obj.FuncEntry) := match d.insns[k]? with
    | some (.native op (_ :: .func g :: _)) =>
      if op.info.mnemonic == "call" then (o.funcs[g]?).map (g, ·) else none
    | _ => none
  { stackArgs := fun k => do
      let (g, c) ← callee k
      let b ← extents[g]?.join
      if b ≤ c.argSize then some c.argSize else none
    islandTemplate := fun k => match d.insns[k]? with
      | some (.native op (.sym s :: _)) =>
        if op.info.shape == .island then (o.slotName s).toOption.bind islands else none
      | _ => none }

/-- One function's lines, as `lean-decode-ref decode` prints them. -/
def funcLines (d : Decoded) : Array String := Id.run do
  let wpos := d.wordPos
  let mut out := #[s!"  frame {d.frameSize}"]
  for h : k in [0:d.insns.size] do
    out := out.push s!"  {pad6 wpos[k]!}: {insnText wpos k d.insns[k]}"
  for e in d.cleanupEntries do
    out := out.push (if e.target == continueTarget then s!"  cleanup {e.offset} -> continue"
      else if e.target &&& catchBit != 0 then s!"  cleanup {e.offset} -> {e.target &&& (catchBit - 1)} catch"
      else s!"  cleanup {e.offset} -> {e.target}")
  for (i, sc) in d.scopes do
    out := out.push s!"  scope {wpos[i]!} {signed32 sc.frameOffset} {sc.size} {sc.kind.text}"
  for i in d.dropped do out := out.push s!"  dropped {wpos[i]!}"
  for i in d.heads do out := out.push s!"  head {wpos[i]!}"
  return out

/-- `ryo-lean decode <obj>`'s lines: each function of the image object, decoded. -/
def objLines (o : Ryo.Obj.ImageObject) : Array String := Id.run do
  let mut out : Array String := #[]
  for h : i in [0:o.funcs.size] do
    let f := o.funcs[i]
    out := out.push s!"func {i} {o.funcName f.codeOff}"
    match o.funcInputs i with
    | .error e =>
      out := out.push (if (e.splitOn "malformed instruction list").length > 1 then "  error: malformed instruction list"
        else s!"  error: {e}")
    | .ok fi =>
      match decodeFunc fi (listHints o i) with
      | .error e => out := out.push s!"  error: {e}"
      | .ok none => out := out.push "  error: malformed instruction list"
      | .ok (some (.error e)) => out := out.push s!"  error: {e.what} at {e.at_}"
      | .ok (some (.ok d)) => out := out ++ funcLines d
  return out

/-- `ryo-lean dead <obj>`'s lines: per function with dropped stores that the checked decoding
(`Frame.decodeChecked`) rejects, its verdict, the stores `Frame.droppedNotDead` doesn't show
dead, and the function's text; then the totals. The check is given the image's facts
(`imageFacts`, with the island templates `islands` maps symbol names to) merged with
`extra i` for function `i` (facts checked elsewhere, e.g. against the C1' certificate). -/
def deadLines (o : Ryo.Obj.ImageObject) (extra : Nat → Frame.Facts := fun _ => {})
    (islands : String → Option String := fun _ => none) : Array String := Id.run do
  let mut out : Array String := #[]
  let mut total := 0
  let mut bad := 0
  let decoded := decodeAll o
  let extents := Frame.incomingExtents (decoded.map (·.map (·.2))) o.image.mode
  for h : i in [0:o.funcs.size] do
    let f := o.funcs[i]
    let some (fi, d) := decoded[i]! | continue
    if d.dropped.isEmpty then continue
    total := total + d.dropped.size
    let facts := (imageFacts o extents d islands).merge (extra i)
    let .ok (some r) := decodeFuncChecked fi (listHints o i) facts | continue
    let .error e := r | continue
    let wpos := d.wordPos
    match Frame.droppedNotDead d fi.mode facts with
    | .ok ks =>
      bad := bad + ks.length
      let why := ks.map fun k => match Frame.firstReader d fi.mode k facts with
        | .ok (some (j, by_)) => s!"{wpos[k]!} read at {wpos[j]!}" ++ match by_ with
          | .operand => ""
          | .pointer => " through a pointer"
          | .stack => " (stack arguments)"
          | .everything => " (reads everything)"
        | _ => s!"{wpos[k]!}"
      out := out.push s!"func {i} {o.funcName f.codeOff}: {e}: {", ".intercalate why}"
    | .error _ =>
      bad := bad + d.dropped.size
      out := out.push s!"func {i} {o.funcName f.codeOff}: {e}"
    out := out ++ funcLines d
  out := out.push s!"total dropped {total}, not shown dead {bad}"
  return out

end Ryo.Vm.DecodeObj
