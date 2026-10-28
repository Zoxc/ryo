/-
Ryo.Vm.Frame — frame accesses of R code and the dead-store check aot.md §C2 asks of the Lean
decoder: the Rust decoder trusts the encoder's list of dropped stores; `droppedNotDead` checks
each by a backward liveness over the decoded code, and `decodeChecked` decodes only code whose
dropped stores it shows dead (and whose frame ranges lie in the frame, `decodeBounded`).

A dropped store is dead if none of its bytes is live after its instruction, along the
instruction's successors (fall-through, branch targets, its landing pad): no path reads a byte
of it before an instruction writes that byte for sure. An overflow op's result store is followed
by its flag's, in the same instruction, which writes `o`'s byte for sure. Liveness is over the frame bytes
`-F .. 0`; bytes above `fp` (the incoming area) aren't tracked, and no dropped store reaches
them. The L2 frame then differs from R's only on bytes R never reads again (aot.md §C2).

What each instruction reads (`gen`) and writes for sure (`kill`), and what that assumes:

- **Inline instructions** are taken as their machine items: a read the register cache serves
  from a register reads no frame byte, a dropped store writes none. The decoder checked that
  the items are what the cache emits for the instruction.
- **Handlers** access their frame operands as `opSem`'s footprint says (`OpSem.footprint`,
  validated against the handlers by `vm/rt/tests/lean_opsem.rs`), its extents evaluated on
  the operands unpacked through the layout: exact widths, `len`, `elem_size × count`. This
  is the handler contract of reduced.md §C0.5. A handler dereferencing a pointer from a slot, a memory operand or an
  address operand's contents makes a pointer access (an address operand itself is a
  constant or symbol, never a frame object). `resume` (assembly, no footprint) reads
  its slot and leaves the function as a return does. Where the operands don't give an
  extent, `asm::frame::handler`'s over-estimate: a read of 16 bytes or the lengths its `len`
  / `elem_size × count` operands give, its `d` clobbered, and a pointer access.
- **Calls** read their argument list `a` (each slot at its register's size; a by-address
  argument reads no byte itself), `call.ptr`'s `p`, and memory through pointers (below). A
  callee reads the caller's frame otherwise only as its stack arguments, in the outgoing area
  at `fp - F` (design/vm.md, "Calls"), which no operand names. The convention (`sig.rs`'s
  `arg_plan`, as LLVM's) puts a piece on the stack only once its class's registers ran out:
  SysV with all six integer registers taken (an `i128` with five), or all eight `xmm` ones;
  Win64 from argument position 4 on. So a call whose list uses no integer register from `r8`
  on and no `xmm7` (SysV), or no register of position 3 (Win64), has no stack arguments; any
  other call reads every frame byte, or with `Facts.stackArgs` = `n` the `n` bytes from
  `fp - F` (frame byte 0). This assumes the argument list is the callee's register plan (the
  C1 call check validates it against the plan, aot.md §C1). A tail call's stack arguments go
  to the incoming area, above `fp`. A call's result stores write each part exactly, on the
  fall-through only.
- **Stack-argument extents** (`Facts.stackArgs`). The callee's `fp + 16` is the caller's
  `fp - F` (design/vm.md, "Frames"), so what the callee accesses of its incoming area is what
  the call accesses of the caller's outgoing area. For a `call` of an image function `g`
  (`DecodeObj.imageFacts`) the extent is `g`'s `arg_size` if `g`'s own decoded code accesses
  its incoming area only within those bytes (`incomingUse`, joined over tail calls by
  `incomingExtents`): every frame access at its extent, in both the item and the operand view
  of an inline instruction (an inline `addr` is a `lea`, which no item reads), every `Escape`
  and `Lend` scope's extent (accesses through pointers stay inside the escaped object), no
  address taken there that no escape covers, and no tail call of a non-image function that
  may pass stack arguments. That is a property of `g`'s R code, not of the `arg_size` field,
  so it doesn't rest on `Check.Image.Funcs`, whose "incoming-area accesses within `arg_size`"
  bounds only where accesses start (not their extents, escapes or addresses taken there).
  For `call.sym`/`call.ptr` the extent is the call's `ArgPlan`'s stack size, which the
  certificate gives and C1' checks: a callee reads the stack arguments its convention puts
  there and no other byte of the outgoing area (the convention of aot.md §C1, "Calls"; for
  native callees, under the assumption that native code keeps its convention).
- **sret destinations** (`Facts.sretSize`). A call with an sret destination (its argument
  list's first entry, the first integer register by address, `pass_args`) makes the
  destination's `sretSize` bytes `Uninit` after reading its arguments and before the callee
  runs, as L0 does (D12; reduced.md §C0.4). So those bytes are dead into the call but for
  what the call itself reads: its argument list and stack arguments stay live (read before),
  its pointer accesses don't read them (they read `Uninit`), and neither does anything after
  the call or on its landing pad (`Flow.uninit`). The size must be the destination type's:
  only the certificate check gives it, for calls whose ABI the dump has (the dumped return
  size); not the image, since no image check ties an sret callee's `ret_size` to its return
  type (`Check.Image.Funcs` checks `ret_size` only for kinds returned in registers).
- **Islands** read the extents of the `Lend` scopes before them (`asm::ScopeKind::Lend`, one
  per operand of a nonzero size, recorded by the lowering with the size its template
  accesses there), may write them (no kill: they are clobbered), and make a pointer access
  (they take `fp` and may call anything). This assumes the island contract: an island's
  template accesses each operand only within its `Lend` extent, and other frame bytes only
  through pointers to escaped objects; C1' checks the extents against the template
  (aot.md §C1, "Islands"; reduced.md §C0.1). An operand without a `Lend` has an empty
  extent: the encoder skips a `Lend` only for a zero-sized operand (`Asm::lend` in
  `asm/encode.rs`: `if size != 0`), and C1' checks every operand's extent, "no `Lend` means
  size 0" included, against the contract. With the island's template known
  (`Facts.islandTemplate`, from its symbol), the contract's operand roles
  (`Ryo.Vm.R.Islands`, trusted like the extents) refine this per `Lend`: one that only
  operands the template doesn't read sit at is not read, and if each of them is a
  destination the template writes whole when it returns, it is written for sure on the
  fall-through (not on the landing pad). A `Lend` is matched to the operands at its offset,
  all of them, since the scope table doesn't say which one it is; one at no operand's offset
  is read.
- **Pointer accesses** (a native `[p + k]` operand, a handler's dereference, any call) read
  the bytes of every frame object that may be escaped at that instruction. Under R's memory
  model (reduced.md §C0.3) a frame object is an allocation only from an `Escape` scope to the
  matching `End`; an access through a pointer needs the provenance of a live allocation, so
  it reaches no other frame byte (after the `End` it is UB, and L2 may read anything). R is
  sequential (D17: atomics are sequential, no other thread reads the frame in between). The
  escaped objects at each instruction are a forward "maybe" dataflow over the same
  successors and landing pads, from none at entry: an `Escape` scope before the instruction
  adds its object, an `End` removes the objects it covers whole (one it covers partly stays).
  A by-address call argument whose byte no escape covers reads every byte (the lowering
  check rules it out).
- **Storage ends**: an `End` scope before an instruction makes the bytes it covers `Uninit`
  in R (reduced.md §C0.3), so they are dead into it: what R reads there is `Uninit`, which
  any L2 byte refines. A partial end kills only the bytes it covers.

`Facts` are keyed by R instruction index; `DecodeObj.deadLines` merges the image's
(`imageFacts`) with ones checked against the C1' certificate.

Known remaining classes the check rejects: `call.sym`/`call.ptr` calls that may have stack
arguments, without the certificate's extent; stores into an object that may be escaped at a
later pointer access only along other paths (the escape dataflow is path-insensitive: a
temporary escaped by one statement and stored by another, reaching a landing pad that both
unwind to); and stale bytes that a copy (`mov.w128`, `copy`, `store.copy`) moves without
any later use (a value-flow, not liveness, question).

`native`/`handler`/`effects` port `asm::frame::insns` with these refinements; Rust's
`head_liveness` is coarser (calls read every byte, handlers kill nothing).
-/
import Ryo.Vm.DecodeReduced
import Ryo.Vm.OpSem.Footprint
import Ryo.Vm.R.Islands
import Std.Data.HashMap

namespace Ryo.Vm.Frame

open Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm Ryo.X86

/-- How an instruction uses one of its frame operands (`frame::Access`). -/
inductive Access
  | read (n : Nat)
  | write (n : Nat)
  | clobber (n : Nat)
  | addr
  | opaque
deriving DecidableEq, Repr, Inhabited

/-- What the dead-store check may assume of a function's calls and islands beyond what the
decoded code says: facts checked elsewhere (against the callees' `FuncEntry`s, or the C1'
certificate against the dump), each keyed by R instruction index. The default assumes nothing. -/
structure Facts where
  /-- A call's stack-argument area: the callee reads at most these many bytes from `fp - F` (the
  outgoing area) besides its argument list. -/
  stackArgs : Nat → Option Nat := fun _ => none
  /-- A call with an sret destination (the argument list's first-integer-register entry, by
  address): the return value's size. -/
  sretSize : Nat → Option Nat := fun _ => none
  /-- An island's template (its diagnostic item name), from its symbol. -/
  islandTemplate : Nat → Option String := fun _ => none

instance : Inhabited Facts := ⟨{}⟩

/-- `a`'s facts, and `b`'s where `a` has none. -/
def Facts.merge (a b : Facts) : Facts where
  stackArgs k := (a.stackArgs k).orElse fun _ => b.stackArgs k
  sretSize k := (a.sretSize k).orElse fun _ => b.sretSize k
  islandTemplate k := (a.islandTemplate k).orElse fun _ => b.islandTemplate k

/-- An instruction's frame operands (offset, access), whether it reads every byte, and whether
it may access memory through a pointer. -/
structure Effects where
  opnds : List (BitVec 32 × Access) := []
  readsAll : Bool := false
  pointer : Bool := false
deriving Repr, Inhabited

def widthOfMnemonic (m : String) : Option Nat :=
  (m.splitOn ".").findSome? fun
    | "w8" => some 1 | "w16" => some 2 | "w32" => some 4 | "w64" => some 8 | "w128" => some 16
    | _ => none

/-- The second width of a mnemonic (`zext.w8.w32`: 4). -/
def secondWidth (m : String) : Option Nat :=
  ((m.splitOn ".").filterMap fun
    | "w8" => some 1 | "w16" => some 2 | "w32" => some 4 | "w64" => some 8 | "w128" => some 16
    | _ => none)[1]?

/-- A call's argument list: (slot, register) pairs, read at the register's size or
address-taken. -/
def argPairs : List (BitVec 32) → List (BitVec 32 × Access)
  | s :: r :: rest =>
    let rn := r.toNat
    let acc := if rn &&& Ryo.Vm.Asm.argAddr != 0 then Access.addr
      else .read ((ArgReg.of? rn false).map (·.size) |>.getD 8)
    (s, acc) :: argPairs rest
  | _ => []

/-- The registers of a call's argument list, `none` for a word that isn't one. -/
def argRegs : List (BitVec 32) → List (Option ArgReg)
  | _ :: r :: rest => ArgReg.of? (if r.toNat &&& Ryo.Vm.Asm.argAddr != 0 then r.toNat - Ryo.Vm.Asm.argAddr else r.toNat) false :: argRegs rest
  | _ => []

/-- Whether a call with the argument list `ws` may have stack arguments: some piece took a
stack slot only if its class's registers ran out (`arg_plan`). SysV: an integer piece once
`r9` (index 5) is taken, an `i128` once `r8` (index 4) is, a float once `xmm7` is; Win64:
from position 4 on, after position 3's register. -/
def mayHaveStackArgs (pe : Bool) (ws : List (BitVec 32)) : Bool :=
  (argRegs ws).any fun
    | none => true
    | some r => if pe then r.index ≥ 3 else if r.xmm then r.index ≥ 7 else r.index ≥ 4

/-- How an island of template `template` (if known), its operand slots being `ws`, accesses
the `Lend` extent of `n` bytes at `off`. A `Lend` belongs to an operand at its offset (the
lowering records one per operand of a nonzero size, at the operand's slot), but which one,
when several share the offset, the scope table doesn't say; so the extent is read unless the
contract (`Islands.role`) says no operand there is read, written for sure (on the
fall-through) if it says each of them is written whole, and else clobbered. An extent at no
operand's offset is read. -/
def islandAccess (template : Option String) (ws : List (BitVec 32)) (off : BitVec 32) (n : Nat) :
    Access :=
  match template with
  | none => .read n
  | some t =>
    let roles := (ws.zipIdx.filter (·.1 == off)).map fun (_, i) => Islands.role t ws.length i
    if roles.isEmpty || roles.contains .read then .read n
    else if roles.all (· == .write) then .write n
    else .clobber n

/-- `frame::native`: the frame operands of a native instruction. A call reads every byte if it
may have stack arguments (`mayHaveStackArgs`; `Flow.of` narrows that to the stack-argument
area when it knows the callee's extent). An island reads the extents `lends` (the `Lend`
scopes before it: offset, size; an operand without one is zero-sized) but those of operands
its template's contract says it doesn't read, which it writes or clobbers (`islandAccess`),
and makes a pointer access. -/
def native (op : Reduced.Opcode) (ops : List (Opnd Nat)) (pe : Bool := false)
    (lends : List (BitVec 32 × Nat) := []) (template : Option String := none) : Effects := Id.run do
  let info := op.info
  let m := info.mnemonic
  let n := (widthOfMnemonic m).getD 8
  let first := (m.splitOn ".").headD ""
  let compare := ["eq", "ne", "lt", "le", "gt", "ge"].contains first
  let pairs := info.operands.zip ops
  let named (name : String) : Option (Opnd Nat) := (pairs.find? (·.1.name == name)).map (·.2)
  let slotOf : Option (Opnd Nat) → Option (BitVec 32)
    | some (.slot s) => some s
    | _ => none
  let immOf : Option (Opnd Nat) → Nat
    | some (.imm v) => v.toNat % 2 ^ 32
    | _ => 0
  match info.shape with
  | .call | .tailCall =>
    let mut out : List (BitVec 32 × Access) := []
    if let some p := slotOf (named "p") then out := out ++ [(p, .read 8)]
    if info.shape == .call then
      let k := immOf (named "k")
      if k != 0 then
        -- The result's stores, after the call returns: each part exactly.
        let parts : List (Nat × Nat) := match retParts k false with
          | some (a, b) => ([a, b].filterMap id).map fun p => (p.off, p.size)
          | none => []
        if let some d := slotOf (named "d") then
          out := out ++ parts.map fun (o, n) => (d + BitVec.ofNat 32 o, Access.write n)
    let ws := match named "a" with
      | some (.words ws) => ws
      | _ => []
    -- A tail call's stack arguments go over the incoming ones, above `fp`.
    let stack := info.shape == .call && mayHaveStackArgs pe ws
    return { opnds := out ++ argPairs ws, readsAll := stack, pointer := true }
  | .ret =>
    let k := immOf (named "k")
    if k == 0 then return {}
    let hi := match retParts k true with
      | some (a, b) => ([a, b].filterMap id).foldl (fun x p => max x (p.off + p.size)) 0
      | none => 0
    return { opnds := (slotOf (named "s")).toList.map (·, .read hi) }
  | .arg =>
    let size := (ArgReg.of? (immOf (named "r")) true).map (·.size) |>.getD 0
    return { opnds := (slotOf (named "d")).toList.map (·, .write size) }
  | .island =>
    let ws := match named "ops" with
      | some (.words ws) => ws
      | _ => []
    return { opnds := lends.map (fun (o, n) => (o, islandAccess template ws o n)), pointer := true }
  | _ =>
    let mut out : List (BitVec 32 × Access) := []
    let mut pointer := false
    -- An extension or truncation writes its second width.
    let ext := ["zext", "sext", "trunc"].contains first
    let to := (secondWidth m).getD n
    for (o, v) in pairs do
      match o.kind, v with
      | .slot, .slot s =>
        let acc : Access :=
          if o.name == "d" && ext then .write to
          -- An overflow flag.
          else if o.name == "o" then .write 1
          else if o.name == "d" then (if m == "addr" || first == "ptr" then .write 8 else .write (if compare then 1 else n))
          else if o.name == "s" && m == "addr" then .addr
          else if o.name == "s" && m == "br" then .read 1
          else if o.name == "p" || o.name == "i" then .read 8
          else .read n
        out := out ++ [(s, acc)]
      | .mem, .mem p _ =>
        out := out ++ [(p, .read 8)]
        pointer := true
      | _, _ => pure ()
    return { opnds := out, pointer }

/-! ### Handler footprints -/

/-- An operand's value as `opSem` takes it (`OpSem.Val`), from the handler's argument
registers by `h`'s layout: slots, memory operands' slots and immediates; `none` for the
others, which no frame extent depends on. -/
def opndVals (h : Full.Opcode) (args : List Arg) (l : Asm.Layout) : List (String × OpSem.Val) :=
  h.info.operands.zipIdx.filterMap fun (o, k) => do
    let loc := l.locs[k]!
    if loc.count == 0 then none
    let some (.imm v) := args[loc.reg]? | none
    let word := v.toNat >>> (loc.shift / 32 * 32) % 2 ^ 32
    match o.kind with
    | .slot => some (o.name, .slot (BitVec.ofNat 32 word).toInt)
    | .mem => some (o.name, .mem (BitVec.ofNat 32 word).toInt 0)
    | .u8 | .u16 | .u32 | .u64 | .i64 =>
      some (o.name, .imm (if loc.shared then (v.toNat >>> loc.shift) % 2 ^ 32 else v.toNat))
    | _ => none

/-- `frame::handler`: a handler's slot operands, by `h`'s layout. With `opSem`'s footprint
(`OpSem.footprint`): its frame reads and writes at their extents for these operands, its
addresses taken, and a pointer access if it dereferences a pointer that may reach the frame
(one in a slot, a memory operand, or loaded from an address operand; an address operand
itself is a constant or a symbol). `resume` (assembly, no footprint) reads its slot
and leaves the function as a return does. Else, and for an extent the operands don't give,
`asm::frame::handler`'s over-estimate: 16 bytes or the lengths its `len` / `elem_size ×
count` operands give, `d` clobbered, and a pointer access. -/
def handler (h : Full.Opcode) (args : List Arg) (mode : Mode) : Except String Effects := do
  let some l := h.layout mode.fpArg mode.pe | throw "no layout"
  if args.length != l.regs then throw "handler arguments"
  let info := h.info
  let vals := opndVals h args l
  let val (n : String) : Option OpSem.Val := (vals.find? (·.1 == n)).map (·.2)
  let immOf (n : String) : Option Nat := match val n with
    | some (.imm v) => some v
    | _ => none
  -- The over-estimate's extent.
  let mut ext := 16
  if let some x := immOf "len" then ext := max ext x
  if let (some e, some c) := (immOf "elem_size", immOf "count") then ext := max ext (e * c)
  let cap (x : Nat) := min x (2 ^ 32 - 1)
  let off (o : Int) : BitVec 32 := BitVec.ofInt 32 o
  let fp? : Option OpSem.Footprint :=
    if h == Full.Opcode.resume then some { reads := [⟨"x", .bytes 8⟩], flow := .trap }
    else OpSem.footprint h
  -- The exact effects, if every access's range evaluates.
  let exact : Option Effects := do
    let fp ← fp?
    let rs ← fp.reads.mapM (·.range val)
    let ws ← fp.writes.mapM (·.range val)
    let as ← fp.addrs.mapM fun n => (val n).bind OpSem.Val.slotOff
    pure { opnds := rs.map (fun (o, n) => (off o, Access.read (cap n))) ++
             ws.map (fun (o, n) => (off o, Access.write (cap n))) ++ as.map (off ·, Access.addr),
           pointer := fp.derefs.any fun d => match d.src with
             | .addr _ => false
             | _ => true }
  if let some e := exact then return e
  let mut out : List (BitVec 32 × Access) := []
  for (o, k) in info.operands.zipIdx do
    if !(o.kind == .slot || o.kind == .mem) then continue
    if l.locs[k]!.count == 0 then continue
    let some (.imm v) := args[l.locs[k]!.reg]? | throw "a slot operand that isn't an immediate"
    let s := BitVec.ofNat 32 (v.toNat >>> (l.locs[k]!.shift / 32 * 32))
    out := out ++ [(s, if o.kind == .mem || o.name == "p" then .read 8
      else if o.name == "d" then .clobber (cap ext) else .read (cap ext))]
  return { opnds := out, pointer := true }

/-- An inline instruction's frame accesses as its machine items make them: reads not served by
the register cache, and the writes but a dropped store. -/
def inlineEffects (items : List Item) : Effects :=
  { opnds := items.flatMap fun it =>
      (frameRead it).toList.map (fun (m, n) => (m.disp, Access.read n)) ++
      (frameWrite it).toList.map (fun (m, n) => (m.disp, Access.write n)),
    pointer := items.any fun it => (it.mem?.any (·.base != .rbp)) }

/-- The `Lend` scopes before instruction `k`: (frame offset, size). -/
def lendsAt (d : Decoded) (k : Nat) : List (BitVec 32 × Nat) :=
  d.scopes.toList.filterMap fun (j, sc) =>
    if j == k && sc.kind == .lend then some (sc.frameOffset, sc.size) else none

/-- Instruction `i`'s frame accesses: an inline one's by its machine `items`; an island's by
the `Lend` extents `lends` before it and its template's contract, if `template` is known. -/
def effects (i : Insn) (items : List Item) (mode : Mode) (lends : List (BitVec 32 × Nat) := [])
    (template : Option String := none) : Except String Effects :=
  match i with
  | .native op ops =>
    if (op.full.bind classOf).isSome then pure (inlineEffects items)
    else pure (native op ops mode.pe lends template)
  | .handler h args _ => handler h args mode

/-! ### Liveness over frame bytes `-F .. 0`

A set of frame bytes is a bitset, a `Nat` whose bit `F + off` is the byte at `off` (GMP does the
word-wise `|||`, `&&&`, `^^^`); an instruction's own sets, mostly one or a few ranges, are kept as
`Ranges` and made bitsets where they are combined. So the memory is one bitset per instruction
(the bytes live into it) and per set of escaped objects, not one per set and instruction. -/

/-- The byte indices `lo .. hi` (`F + off`, `hi` excluded) of `n` bytes at `off`, clamped to the
frame. -/
def range (f : Nat) (off : BitVec 32) (n : Nat) : Nat × Nat :=
  let fi : Int := f
  let lo := max (min off.toInt 0) (-fi) + fi
  let hi := max (min (off.toInt + n) 0) (-fi) + fi
  (lo.toNat, hi.toNat)

/-- The bitset of the bytes `lo .. hi`. -/
def bitsOf (lo hi : Nat) : Nat := ((1 <<< (hi - lo)) - 1) <<< lo

/-- `a`'s bits that aren't `b`'s. -/
def diff (a b : Nat) : Nat := a ^^^ (a &&& b)

/-- A set of bytes as the union of ranges (`range`'s, possibly overlapping). -/
abbrev Ranges := List (Nat × Nat)

def Ranges.bits (rs : Ranges) : Nat := rs.foldl (fun b (lo, hi) => b ||| bitsOf lo hi) 0

/-- Each instruction's successors (fall-through and branch targets) and landing pads. -/
def flow (d : Decoded) : Array (List Nat) × Array (List Nat) := Id.run do
  let n := d.insns.size
  let mut succ : Array (List Nat) := #[]
  let mut pad : Array (List Nat) := Array.replicate n []
  for (c, p, _) in d.cleanup.toList.reverse do
    if let some p := p then
      if c < n && p < n then pad := pad.modify c (p :: ·)
  for h : k in [0:n] do
    let (next, ts) : Bool × List Nat := match d.insns[k] with
      | .native op ops =>
        (!(op.info.shape == .jmp || op.info.shape == .ret || op.info.shape == .tailCall),
          ops.flatMap Opnd.targetsOf)
      | .handler h _ t =>
        (h.info.shape == .op || h.info.shape == .br || h.info.shape == .lpad, t.targets)
    succ := succ.push (((if next && k + 1 < n then [k + 1] else []) ++ ts).filter (· < n))
  return (succ, pad)

/-- The `Escape` scopes (`d.scopes`' indices) as frame ranges `[lo, hi)`, and what the scopes
before each instruction do to a set of them (a bitset over the indices), in order: an `Escape`
adds its object (`true`), an `End` removes each object it covers whole (`false`), a `Lend` (not
an escape) changes nothing. -/
def escapeSteps (d : Decoded) : Array (Int × Int × Nat) × Array (Array (Bool × Nat)) := Id.run do
  let n := d.insns.size
  let escapes : Array (Int × Int × Nat) := d.scopes.zipIdx.filterMap fun ((_, sc), j) =>
    match sc.kind with
    | .escape _ => some (sc.frameOffset.toInt, sc.frameOffset.toInt + sc.size, j)
    | _ => none
  let mut steps : Array (Array (Bool × Nat)) := Array.replicate n #[]
  for ((k, sc), j) in d.scopes.zipIdx do
    if k ≥ n then continue
    match sc.kind with
    | .escape _ => steps := steps.modify k (·.push (true, 1 <<< j))
    | .lend => pure ()
    | .end =>
      let lo := sc.frameOffset.toInt
      let hi := lo + sc.size
      let covered := escapes.foldl (fun b (l, h, i) => if lo ≤ l && h ≤ hi then b ||| 1 <<< i else b) 0
      steps := steps.modify k (·.push (false, covered))
  return (escapes, steps)

/-- `escapeSteps`' steps applied to `st`. -/
def applySteps (steps : Array (Bool × Nat)) (st : Nat) : Nat :=
  steps.foldl (fun st (add, b) => if add then st ||| b else diff st b) st

/-- The frame objects that may be escaped at each instruction (after the scopes before it), as
a bitset over `Escape` scopes (`d.scopes`' indices): a forward dataflow over `edges` (successors
and landing pads) from nothing escaped at entry. An `Escape` adds its object; an `End` removes
each object it covers whole; a `Lend` (not an escape) changes nothing. -/
def escapedAt (d : Decoded) (edges : Array (List Nat)) : Array Nat := Id.run do
  let n := d.insns.size
  if n == 0 || d.scopes.isEmpty then return Array.replicate n 0
  let (_, steps) := escapeSteps d
  let apply (k : Nat) (st : Nat) : Nat := applySteps steps[k]! st
  let mut inS : Array Nat := Array.replicate n 0
  let mut at_ : Array Nat := Array.replicate n 0
  let mut dirty := Array.replicate n true
  let mut more := true
  while more do
    more := false
    for k in [0:n] do
      if !dirty[k]! then continue
      dirty := dirty.set! k false
      let v := apply k inS[k]!
      at_ := at_.set! k v
      for s in edges[k]! do
        let u := inS[s]! ||| v
        if u != inS[s]! then
          inS := inS.set! s u
          dirty := dirty.set! s true
          more := true
  return at_

/-- The frame objects escaped on **every** path to each instruction (after the scopes before
it), as a bitset over `Escape` scopes: `escapedAt`'s dataflow as a *must* analysis (the
intersection over the predecessors along `edges`; nothing escaped at entry, instruction 0). An
instruction no path reaches has every object (vacuously). -/
def mustEscapedAt (d : Decoded) (edges : Array (List Nat)) : Array Nat := Id.run do
  let n := d.insns.size
  if n == 0 || d.scopes.isEmpty then return Array.replicate n 0
  let (_, steps) := escapeSteps d
  let top : Nat := (1 <<< d.scopes.size) - 1
  let mut inS : Array Nat := (Array.replicate n top).set! 0 0
  let mut at_ : Array Nat := Array.replicate n 0
  let mut dirty := Array.replicate n true
  let mut more := true
  while more do
    more := false
    for k in [0:n] do
      if !dirty[k]! then continue
      dirty := dirty.set! k false
      let v := applySteps steps[k]! inS[k]!
      at_ := at_.set! k v
      for s in edges[k]! do
        let u := inS[s]! &&& v
        if u != inS[s]! then
          inS := inS.set! s u
          dirty := dirty.set! s true
          more := true
  return at_

/-- What the liveness works on: each instruction's successors and landing pads, the frame
bytes it reads (`Flow.gen`: its operands', its callee's stack arguments' (`stack`) and its
pointer accesses', which read the escaped objects (`pointer`) but for what it makes `Uninit`
after its own operand reads (`uninit`: an sret destination)), and the bytes it writes for sure
(`kill`). -/
structure Flow where
  succ : Array (List Nat)
  pad : Array (List Nat)
  operand : Array Ranges
  stack : Array Ranges
  /-- The bytes of the objects escaped at it if it makes a pointer access (one bitset for each
  set of escapes, shared), else none. -/
  pointer : Array Nat
  uninit : Array Ranges
  kill : Array Ranges
  /-- It reads every byte. -/
  readsAll : Array Bool
  /-- The bytes `End` scopes before it make `Uninit`. -/
  ends : Array Ranges

/-- The bytes instruction `k` reads by its operands and stack arguments. -/
def Flow.direct (fl : Flow) (k : Nat) : Nat := (fl.operand[k]! ++ fl.stack[k]!).bits

/-- The bytes instruction `k` reads. -/
def Flow.gen (fl : Flow) (k : Nat) : Nat := fl.direct k ||| diff fl.pointer[k]! fl.uninit[k]!.bits

/-- The part of `gen` only its pointer accesses read. -/
def Flow.viaPointer (fl : Flow) (k : Nat) : Nat :=
  diff (diff fl.pointer[k]! (fl.direct k)) fl.uninit[k]!.bits

/-- The part of `gen` only its callee's stack arguments read. -/
def Flow.viaStack (fl : Flow) (k : Nat) : Nat := diff fl.stack[k]!.bits fl.operand[k]!.bits

/-- The sret destination of a call whose argument list is `ws`: the slot of its first entry,
if that is the first integer register, by address (`pass_args` puts it first). -/
def sretDest (ws : List (BitVec 32)) : Option (BitVec 32) :=
  match ws with
  | s :: r :: _ =>
    if r.toNat == (ArgReg.mk false 8 0).word ||| Ryo.Vm.Asm.argAddr then some s else none
  | _ => none

/-- A call instruction's argument list. -/
def callArgs (ops : List (Opnd Nat)) : List (BitVec 32) :=
  (ops.findSome? fun | .words ws => some ws | _ => none).getD []

/-- A bitset as a hash map key. -/
structure BitsKey where
  bits : Nat
deriving BEq

instance : Hashable BitsKey := ⟨fun k => UInt64.ofNat (k.bits % 0xFFFFFFFFFFFFFFC5)⟩

/-- The scopes before each instruction, with their indices in `d.scopes`, in order. -/
def scopesAt (d : Decoded) : Array (List (Nat × Scope)) :=
  d.scopes.zipIdx.foldr (fun ((k, sc), j) a => if k < a.size then a.modify k ((j, sc) :: ·) else a)
    (Array.replicate d.insns.size [])

def Flow.of (d : Decoded) (mode : Mode) (facts : Facts := {}) : Except String Flow := do
  let n := d.insns.size
  let f := d.frameSize
  let all : Ranges := [(0, f)]
  let (succ, pad) := flow d
  let esc := escapedAt d ((succ.zip pad).map fun (s, p) => s ++ p)
  let scopes : Array (List (Nat × Scope)) := scopesAt d
  -- The bytes of the objects escaped at `k`, computed once per set of escapes.
  let mut escBytes : Std.HashMap BitsKey Nat := {}
  let mut operand : Array Ranges := #[]
  let mut stack : Array Ranges := #[]
  let mut pointer : Array Nat := #[]
  let mut uninit : Array Ranges := #[]
  let mut kill : Array Ranges := #[]
  let mut readsAll : Array Bool := #[]
  let mut ends : Array Ranges := #[]
  for h : k in [0:n] do
    let i : Insn := d.insns[k]
    let lends := scopes[k]!.filterMap fun (_, sc) =>
      if sc.kind == .lend then some (sc.frameOffset, sc.size) else none
    let e ← effects i (d.items[k]?.getD []) mode lends (facts.islandTemplate k)
    let mut eb := 0
    if e.pointer || e.opnds.any (·.2 == .addr) then
      let key : BitsKey := ⟨esc[k]!⟩
      match escBytes[key]? with
      | some b => eb := b
      | none =>
        let mut st := esc[k]!
        while st != 0 do
          let j := st.log2
          st := st ^^^ (1 <<< j)
          let sc := d.scopes[j]!.2
          let (lo, hi) := range f sc.frameOffset sc.size
          eb := eb ||| bitsOf lo hi
        escBytes := escBytes.insert key eb
    let (isCall, call, ws) : Bool × Bool × List (BitVec 32) := match i with
      | .native op ops => (op.info.shape == .call || op.info.shape == .tailCall,
          op.info.shape == .call, callArgs ops)
      | _ => (false, false, [])
    -- A call that may have stack arguments: the callee reads at most `stackArgs` bytes of the
    -- outgoing area, at `fp - F` (frame byte 0), if known; else any byte.
    let gs : Ranges := if !e.readsAll then [] else match call, facts.stackArgs k with
      | true, some m => [range f (BitVec.ofInt 32 (-(f : Int))) m]
      | _, _ => all
    let mut g : Ranges := []
    let mut kl : Ranges := []
    for (off, acc) in e.opnds do
      match acc with
      | .read m => g := range f off m :: g
      | .write m => kl := range f off m :: kl
      | .opaque => g := all
      -- A by-address argument no escape covers: its object's extent is unknown.
      | .addr =>
        let (lo, hi) := range f off 1
        if isCall && lo < hi && !eb.testBit lo then g := all
      | _ => pure ()
    -- An sret destination is `Uninit` once the call has read its arguments (reduced.md §C0.4):
    -- what the callee reads of it through pointers is that.
    let un : Ranges := match call, facts.sretSize k, sretDest ws with
      | true, some m, some s => [range f s m]
      | _, _, _ => []
    let gen := (g ++ gs).bits ||| (if e.pointer then diff eb un.bits else 0)
    operand := operand.push g
    stack := stack.push gs
    pointer := pointer.push (if e.pointer then eb else 0)
    uninit := uninit.push un
    -- What it writes and also reads is live into it all the same: `gen` is added after `kill`.
    kill := kill.push kl
    readsAll := readsAll.push (gen == bitsOf 0 f)
    ends := ends.push (scopes[k]!.filterMap fun (_, sc) =>
      if sc.kind == .end then some (range f sc.frameOffset sc.size) else none)
  return { succ, pad, operand, stack, pointer, uninit, kill, readsAll, ends }

/-- The frame bytes live into each instruction: some path from it reads them before an
instruction writes them for sure (unwinding to a landing pad past nothing it writes). A
worklist, in reverse order, from nothing live. -/
def Flow.liveIn (fl : Flow) : Array Nat := Id.run do
  let n := fl.succ.size
  let mut preds : Array (List Nat) := Array.replicate n []
  for k in [0:n] do
    for s in fl.succ[k]! ++ fl.pad[k]! do
      preds := preds.modify s (k :: ·)
  let mut liveIn : Array Nat := Array.replicate n 0
  let mut dirty := Array.replicate n true
  let mut more := true
  while more do
    more := false
    for k' in [0:n] do
      let k := n - 1 - k'
      if !dirty[k]! then continue
      dirty := dirty.set! k false
      let out := fl.succ[k]!.foldl (fun a s => a ||| liveIn[s]!) 0
      let v := diff out fl.kill[k]!.bits
      let v := fl.pad[k]!.foldl (fun a s => a ||| liveIn[s]!) v
      -- What `k` makes `Uninit` after reading its operands is dead into it, but what it reads.
      let v := diff v fl.uninit[k]!.bits ||| fl.gen k
      -- What R reads of the bytes an `End` before `k` covers is `Uninit`.
      let v := diff v fl.ends[k]!.bits ||| liveIn[k]!
      if v != liveIn[k]! then
        liveIn := liveIn.set! k v
        for p in preds[k]! do dirty := dirty.set! p true
        more := true
  return liveIn

/-- The store instruction `k` dropped: its destination (`mov.w128`'s low half) and width. -/
def droppedStore (d : Decoded) (k : Nat) : Option (BitVec 32 × Nat) :=
  match d.insns[k]? with
  | some (.native op ops) =>
    match (op.info.operands.zip ops).find? (·.1.name == "d") with
    | some (_, .slot s) =>
      let first := (op.info.mnemonic.splitOn ".").headD ""
      let w := if op.info.mnemonic == "mov.w128" then 8
        else if op.info.mnemonic == "addr" || op.info.mnemonic.startsWith "ptr" then 8
        -- `cmp3` stores a byte, `cttz`/`ctlz` a `u32`, at any width.
        else if first == "cmp3" then 1
        else if first == "cttz" || first == "ctlz" then 4
        else ((secondWidth op.info.mnemonic).orElse fun _ => widthOfMnemonic op.info.mnemonic).getD 8
      some (s, w)
    | _ => none
  | _ => none

/-- The flag slot `o` of instruction `k`, an overflow op, stored after its result. -/
def flagSlot (d : Decoded) (k : Nat) : Option (BitVec 32) :=
  match d.insns[k]? with
  | some (.native op ops) =>
    match (op.info.operands.zip ops).find? (·.1.name == "o") with
    | some (_, .slot s) => some s
    | _ => none
  | _ => none

/-- The dropped stores `droppedNotDead` can't show dead: their instruction indices. -/
def droppedNotDead (d : Decoded) (mode : Mode) (facts : Facts := {}) : Except String (List Nat) := do
  if d.dropped.isEmpty then return []
  let f := d.frameSize
  let fl ← Flow.of d mode facts
  let liveIn := fl.liveIn
  let mut bad : List Nat := []
  for k in d.dropped do
    let liveOut := fl.succ[k]!.foldl (fun a s => a ||| liveIn[s]!) 0
    -- An overflow op's flag store, after its (dropped) result's, writes `o`'s byte for sure.
    let liveOut := match flagSlot d k with
      | some o => let (lo, hi) := range f o 1; diff liveOut (bitsOf lo hi)
      | none => liveOut
    match droppedStore d k with
    | some (s, w) =>
      let (lo, hi) := range f s w
      if liveOut &&& bitsOf lo hi != 0 then bad := bad ++ [k]
    | none => bad := bad ++ [k]
  return bad

/-- How `firstReader`'s instruction reads the bytes. -/
inductive ReadBy
  | operand
  | pointer
  | stack
  | everything
deriving DecidableEq, Repr

/-- For a diagnosis: an instruction that reads a byte of the store `k` dropped, on a path from
`k` that doesn't write it first, and how it reads it. -/
def firstReader (d : Decoded) (mode : Mode) (k : Nat) (facts : Facts := {}) :
    Except String (Option (Nat × ReadBy)) := do
  let f := d.frameSize
  let fl ← Flow.of d mode facts
  let some (s, w) := droppedStore d k | return none
  let (lo, hi) := range f s w
  let start := bitsOf lo hi
  let n := d.insns.size
  let mut seen : Array Nat := Array.replicate n 0
  let mut work : Std.Queue (Nat × Nat) := fl.succ[k]!.foldl (fun q s => q.enqueue (s, start)) .empty
  for _ in [0:8 * (n + 1) * (w + 1)] do
    match work.dequeue? with
    | none => return none
    | some ((j, st), rest) =>
      work := rest
      let st := diff (diff st seen[j]!) fl.ends[j]!.bits
      if st == 0 then continue
      seen := seen.set! j (seen[j]! ||| st)
      let hit := st &&& fl.gen j
      if hit != 0 then
        let by_ := if fl.readsAll[j]! then ReadBy.everything
          else if diff hit (fl.viaPointer j) == 0 then .pointer
          else if diff hit (fl.viaStack j) == 0 then .stack
          else .operand
        return some (j, by_)
      let st := diff st fl.uninit[j]!.bits
      let after := diff st fl.kill[j]!.bits
      work := fl.succ[j]!.foldl (fun q s => q.enqueue (s, after)) work
      work := fl.pad[j]!.foldl (fun q s => q.enqueue (s, st)) work
  return none

/-! ### What a function accesses of its incoming area -/

/-- The extent of its incoming area (the bytes from `fp + 16`, its caller's outgoing area)
that function `d` may access itself, and the image functions it tail-calls (whose accesses
of the same area count too); `none` if it isn't bounded. Every frame access counts (reads and
writes, at their extents, as `effects` gives them and, for an inline instruction, as its
operands do: `native`'s view), and every `Escape` and `Lend` scope's
extent: an access through a pointer to an escaped object stays inside it (reduced.md §C0.3).
Unbounded: an address taken in the area that no escape covers, an opaque access, and a tail
call of something else than an image function that may pass stack arguments (its callee
reads them from this area). The callee is decoded R code, so this holds of its R semantics:
its accesses of the area are these. -/
def incomingUse (d : Decoded) (mode : Mode) : Except String (Option (Nat × List Nat)) := do
  let ext (off : Int) (m : Nat) : Nat := if off + m > 16 then (off + m - 16).toNat else 0
  let escapes := d.scopes.toList.filterMap fun (_, sc) => match sc.kind with
    | .escape _ => some (sc.frameOffset.toInt, sc.frameOffset.toInt + sc.size)
    | _ => none
  let mut hi := d.scopes.foldl (fun h (_, sc) => match sc.kind with
    | .end => h
    | _ => max h (ext sc.frameOffset.toInt sc.size)) 0
  let mut tails : List Nat := []
  for h : k in [0:d.insns.size] do
    let i := d.insns[k]
    let e ← effects i (d.items[k]?.getD []) mode (lendsAt d k)
    -- An inline instruction's operands too: its items show no address it takes (a `lea`).
    let opnds := match i with
      | .native op ops => e.opnds ++ (native op ops mode.pe (lendsAt d k)).opnds
      | _ => e.opnds
    for (off, acc) in opnds do
      let o := off.toInt
      match acc with
      | .read m | .write m | .clobber m => hi := max hi (ext o m)
      | .addr => if o ≥ 16 && !escapes.any (fun (lo, up) => lo ≤ o && o < up) then return none
      | .opaque => return none
    if let .native op ops := i then
      if op.info.shape == .tailCall then
        match ops.findSome? (fun | .func g => some g | _ => none) with
        | some g => tails := g :: tails
        | none => if mayHaveStackArgs mode.pe (callArgs ops) then return none
  return some (hi, tails)

/-- The incoming-area extents of an image's functions (`decoded`, `none` where not decoded):
`incomingUse`'s, joined over tail calls (the least fixpoint: an execution entering function
`f` accesses the area only within `f`'s own extent and those of the functions it reaches by
tail calls); `none` where unbounded. -/
def incomingExtents (decoded : Array (Option Decoded)) (mode : Mode) : Array (Option Nat) :=
    Id.run do
  let uses := decoded.map fun d? => d?.bind fun d => (incomingUse d mode).toOption.join
  let mut ext : Array (Option Nat) := uses.map (·.map (·.1))
  for _ in [0:decoded.size + 1] do
    let next := uses.map fun u => u.bind fun (b, tails) =>
      tails.foldl (fun acc g => acc.bind fun a => (ext[g]?.join).map (max a)) (some b)
    if next == ext then return ext
    ext := next
  return uses.map fun _ => none

/-! ### The checked decoding -/

/-- `decodeBounded` (`decodeReducedWith` with the frame bounds), accepting the code only if
`droppedNotDead` shows every dropped store dead (given `facts`): the decoding, or an error
naming the first store it doesn't (its word offset). -/
def decodeChecked (code : ByteArray) (fields : Fields) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) (facts : Facts := {}) : Except String Decoded := do
  let d ← match decodeBounded code fields rodata callSites dropped scopes mode with
    | .ok d => pure d
    | .error e => throw s!"{e.what} at {e.at_}"
  checkDropped d mode facts

where
  /-- `d` if every dropped store is shown dead. -/
  checkDropped (d : Decoded) (mode : Mode) (facts : Facts := {}) : Except String Decoded := do
    match ← droppedNotDead d mode facts with
    | [] => pure d
    | k :: rest =>
      throw s!"dropped store at {d.wordPos[k]!} not shown dead ({rest.length + 1} of {d.dropped.size})"

/-- `Inputs.decode`, checked (`decodeChecked`). -/
def Inputs.decodeChecked (i : Inputs) : Except String Decoded :=
  Frame.decodeChecked i.code (.relocs i.relocs) i.rodata i.callSites i.dropped i.scopes i.mode

end Ryo.Vm.Frame
