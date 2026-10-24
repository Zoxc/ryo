/-
Ryo.Vm.Frame — frame accesses of R code and the dead-store check aot.md §C2 asks of the Lean
decoder: the Rust decoder trusts the encoder's list of dropped stores; `droppedNotDead` checks
each by a backward liveness over the decoded code, and `decodeChecked` decodes only code whose
dropped stores it shows dead.

A dropped store is dead if none of its bytes is live after its instruction, along the
instruction's successors (fall-through, branch targets, its landing pad): no path reads a byte
of it before an instruction writes that byte for sure. Liveness is over the frame bytes
`-F .. 0`; bytes above `fp` (the incoming area) aren't tracked, and no dropped store reaches
them. The L2 frame then differs from R's only on bytes R never reads again (aot.md §C2).

What each instruction reads (`gen`) and writes for sure (`kill`), and what that assumes:

- **Inline instructions** are taken as their machine items: a read the register cache serves
  from a register reads no frame byte, a dropped store writes none. The decoder checked that
  the items are what the cache emits for the instruction.
- **Handlers** access their frame operands as `opSem`'s footprint says (`OpSem.footprint`,
  validated against the handlers by `vm/rt/tests/lean_opsem.rs`), its extents evaluated on
  the operands unpacked through the layout: exact widths, `len`, `elem_size × count`,
  `set_discr`'s write unless `variant = untagged`. This is the handler contract of
  reduced.md §C0.5. A handler dereferencing a pointer from a slot, a memory operand or an
  address operand's contents makes a pointer access (an address operand itself is a
  constant, symbol or site, never a frame object). `resume` (assembly, no footprint) reads
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
    for (o, v) in pairs do
      match o.kind, v with
      | .slot, .slot s =>
        let acc : Access :=
          if o.name == "d" then (if m == "addr" || first == "ptr" then .write 8 else .write (if compare then 1 else n))
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
itself is a constant, a symbol or a site). `resume` (assembly, no footprint) reads its slot
and leaves the function as a return does. Else, and for an extent the operands don't give,
`asm::frame::handler`'s over-estimate: 16 bytes or the lengths its `len` / `elem_size ×
count` operands give, `d` clobbered, and a pointer access. -/
def handler (h : Full.Opcode) (args : List Arg) (mode : Mode) : Except String Effects := do
  let some l := h.layout mode.fpArg | throw "no layout"
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

/-! ### Liveness over frame bytes `-F .. 0` -/

/-- The byte indices (`F + off`) of `n` bytes at `off`, clamped to the frame. -/
def range (f : Nat) (off : BitVec 32) (n : Nat) : List Nat :=
  let fi : Int := f
  let lo := max (min off.toInt 0) (-fi) + fi
  let hi := max (min (off.toInt + n) 0) (-fi) + fi
  (List.range (hi - lo).toNat).map (· + lo.toNat)

def orA (a b : Array Bool) : Array Bool := a.zipWith (· || ·) b

def setRange (f : Nat) (a : Array Bool) (off : BitVec 32) (n : Nat) : Array Bool :=
  (range f off n).foldl (fun a b => a.set! b true) a

/-- Each instruction's successors (fall-through and branch targets) and landing pads. -/
def flow (d : Decoded) : Array (List Nat) × Array (List Nat) := Id.run do
  let n := d.insns.size
  let mut succ : Array (List Nat) := #[]
  let mut pad : Array (List Nat) := #[]
  for h : k in [0:n] do
    let (next, ts) : Bool × List Nat := match d.insns[k] with
      | .native op ops =>
        (!(op.info.shape == .jmp || op.info.shape == .ret || op.info.shape == .tailCall),
          ops.flatMap Opnd.targetsOf)
      | .handler h _ t =>
        (h.info.shape == .op || h.info.shape == .br || h.info.shape == .lpad, t.targets)
    pad := pad.push (d.cleanup.toList.filterMap fun (c, p, _) => if c == k then p else none)
    succ := succ.push (((if next && k + 1 < n then [k + 1] else []) ++ ts).filter (· < n))
  return (succ, pad.map (·.filter (· < n)))

/-- The frame objects that may be escaped at each instruction (after the scopes before it), as
flags over `Escape` scopes (`d.scopes`' indices): a forward dataflow over `edges` (successors
and landing pads) from nothing escaped at entry. An `Escape` adds its object; an `End` removes
each object it covers whole; a `Lend` (not an escape) changes nothing. -/
def escapedAt (d : Decoded) (edges : Array (List Nat)) : Array (Array Bool) := Id.run do
  let n := d.insns.size
  let m := d.scopes.size
  let none_ := Array.replicate m false
  if n == 0 || m == 0 then return Array.replicate n none_
  let apply (k : Nat) (st : Array Bool) : Array Bool :=
    (d.scopes.zipIdx.filter (·.1.1 == k)).foldl (fun st ((_, sc), j) =>
      match sc.kind with
      | .escape _ => st.set! j true
      | .lend => st
      | .end =>
        let lo := sc.frameOffset.toInt
        let hi := lo + sc.size
        st.zipWith (fun e (_, o) => e && !(match o.kind with
          | .escape _ => lo ≤ o.frameOffset.toInt && o.frameOffset.toInt + o.size ≤ hi
          | _ => false)) d.scopes) st
  let mut inS : Array (Array Bool) := Array.replicate n none_
  let mut at_ : Array (Array Bool) := Array.replicate n none_
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
        let u := orA inS[s]! v
        if u != inS[s]! then
          inS := inS.set! s u
          dirty := dirty.set! s true
          more := true
  return at_

/-- What the liveness works on: each instruction's successors and landing pads, the frame
bytes it reads (`gen`; `viaPointer` the part only its pointer accesses read, `viaStack` the
part only its callee's stack arguments read), makes `Uninit` after its own operand reads
(`uninit`: an sret destination) and writes for sure (`kill`). -/
structure Flow where
  succ : Array (List Nat)
  pad : Array (List Nat)
  gen : Array (Array Bool)
  viaPointer : Array (Array Bool)
  viaStack : Array (Array Bool)
  uninit : Array (Array Bool)
  kill : Array (Array Bool)
  /-- It reads every byte. -/
  readsAll : Array Bool
  /-- The bytes `End` scopes before it make `Uninit`. -/
  ends : Array (Array Bool)

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

def Flow.of (d : Decoded) (mode : Mode) (facts : Facts := {}) : Except String Flow := do
  let n := d.insns.size
  let f := d.frameSize
  let all := Array.replicate f true
  let none_ := Array.replicate f false
  let (succ, pad) := flow d
  let esc := escapedAt d ((succ.zip pad).map fun (s, p) => s ++ p)
  let escBytes (k : Nat) : Array Bool :=
    (esc[k]!.zip d.scopes).foldl (fun a (e, (_, sc)) => if e then setRange f a sc.frameOffset sc.size else a) none_
  let mut gen : Array (Array Bool) := #[]
  let mut viaPointer : Array (Array Bool) := #[]
  let mut viaStack : Array (Array Bool) := #[]
  let mut uninit : Array (Array Bool) := #[]
  let mut kill : Array (Array Bool) := #[]
  let mut readsAll : Array Bool := #[]
  for h : k in [0:n] do
    let i := d.insns[k]
    let e ← effects i (d.items[k]?.getD []) mode (lendsAt d k) (facts.islandTemplate k)
    let eb := if e.pointer || e.opnds.any (·.2 == .addr) then escBytes k else none_
    let (isCall, call, ws) := match i with
      | .native op ops => (op.info.shape == .call || op.info.shape == .tailCall,
          op.info.shape == .call, callArgs ops)
      | _ => (false, false, [])
    -- A call that may have stack arguments: the callee reads at most `stackArgs` bytes of the
    -- outgoing area, at `fp - F` (frame byte 0), if known; else any byte.
    let gs := if !e.readsAll then none_ else match call, facts.stackArgs k with
      | true, some m => setRange f none_ (BitVec.ofInt 32 (-(f : Int))) m
      | _, _ => all
    let mut g := none_
    let mut kl := none_
    for (off, acc) in e.opnds do
      match acc with
      | .read m => g := setRange f g off m
      | .write m => kl := setRange f kl off m
      | .opaque => g := all
      -- A by-address argument no escape covers: its object's extent is unknown.
      | .addr => if isCall && (range f off 1).any (!eb[·]!) then g := all
      | _ => pure ()
    let vs := gs.zipWith (fun a b => a && !b) g
    g := orA g gs
    -- An sret destination is `Uninit` once the call has read its arguments (reduced.md §C0.4):
    -- what the callee reads of it through pointers is that.
    let un := match call, facts.sretSize k, sretDest ws with
      | true, some m, some s => setRange f none_ s m
      | _, _, _ => none_
    let gp := if e.pointer then (eb.zipWith (fun a b => a && !b) g).zipWith (fun a b => a && !b) un
      else none_
    g := orA g gp
    kl := kl.zipWith (fun a b => a && !b) g
    gen := gen.push g
    viaPointer := viaPointer.push gp
    viaStack := viaStack.push vs
    uninit := uninit.push un
    kill := kill.push kl
    readsAll := readsAll.push (g.all id)
  let ends := (List.range n).toArray.map fun k =>
    (d.scopes.filter fun (j, sc) => j == k && sc.kind == .end).foldl
      (fun a (_, sc) => setRange f a sc.frameOffset sc.size) none_
  return { succ, pad, gen, viaPointer, viaStack, uninit, kill, readsAll, ends }

/-- The frame bytes live into each instruction: some path from it reads them before an
instruction writes them for sure (unwinding to a landing pad past nothing it writes). -/
def Flow.liveIn (fl : Flow) (f : Nat) : Except String (Array (Array Bool)) := do
  let n := fl.gen.size
  let none_ := Array.replicate f false
  let mut liveIn : Array (Array Bool) := Array.replicate n none_
  let mut changed := true
  let mut rounds := 0
  while changed && rounds < 10 * n + 10 do
    changed := false
    rounds := rounds + 1
    for k' in [0:n] do
      let k := n - 1 - k'
      let out := fl.succ[k]!.foldl (fun a s => orA a liveIn[s]!) none_
      let v := out.zipWith (fun a b => a && !b) fl.kill[k]!
      let v := fl.pad[k]!.foldl (fun a s => orA a liveIn[s]!) v
      -- What `k` makes `Uninit` after reading its operands is dead into it, but what it reads.
      let v := orA (v.zipWith (fun a b => a && !b) fl.uninit[k]!) fl.gen[k]!
      -- What R reads of the bytes an `End` before `k` covers is `Uninit`.
      let v := v.zipWith (fun a b => a && !b) fl.ends[k]!
      let v := orA v liveIn[k]!
      if v != liveIn[k]! then
        liveIn := liveIn.set! k v
        changed := true
  if changed then throw "liveness didn't converge"
  return liveIn

/-- The store instruction `k` dropped: its destination (`mov.w128`'s low half) and width. -/
def droppedStore (d : Decoded) (k : Nat) : Option (BitVec 32 × Nat) :=
  match d.insns[k]? with
  | some (.native op ops) =>
    match (op.info.operands.zip ops).find? (·.1.name == "d") with
    | some (_, .slot s) =>
      let w := if op.info.mnemonic == "mov.w128" then 8
        else if op.info.mnemonic == "addr" || op.info.mnemonic.startsWith "ptr" then 8
        else (widthOfMnemonic op.info.mnemonic).getD 8
      some (s, w)
    | _ => none
  | _ => none

/-- The dropped stores `droppedNotDead` can't show dead: their instruction indices. -/
def droppedNotDead (d : Decoded) (mode : Mode) (facts : Facts := {}) : Except String (List Nat) := do
  if d.dropped.isEmpty then return []
  let f := d.frameSize
  let fl ← Flow.of d mode facts
  let liveIn ← fl.liveIn f
  let mut bad : List Nat := []
  for k in d.dropped do
    let liveOut := fl.succ[k]!.foldl (fun a s => orA a liveIn[s]!) (Array.replicate f false)
    match droppedStore d k with
    | some (s, w) => if (range f s w).any (liveOut[·]!) then bad := bad ++ [k]
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
  let start := setRange f (Array.replicate f false) s w
  let n := d.insns.size
  let mut seen : Array (Array Bool) := Array.replicate n (Array.replicate f false)
  let mut work : List (Nat × Array Bool) := fl.succ[k]!.map (·, start)
  for _ in [0:8 * (n + 1) * (w + 1)] do
    match work with
    | [] => return none
    | (j, st) :: rest =>
      work := rest
      let st := (st.zipWith (fun a b => a && !b) seen[j]!).zipWith (fun a b => a && !b) fl.ends[j]!
      if !st.any id then continue
      seen := seen.set! j (orA seen[j]! st)
      let hit := st.zipWith (· && ·) fl.gen[j]!
      if hit.any id then
        let by_ := if fl.readsAll[j]! then ReadBy.everything
          else if (hit.zipWith (fun a b => a && !b) fl.viaPointer[j]!).all (!·) then .pointer
          else if (hit.zipWith (fun a b => a && !b) fl.viaStack[j]!).all (!·) then .stack
          else .operand
        return some (j, by_)
      let st := st.zipWith (fun a b => a && !b) fl.uninit[j]!
      let after := st.zipWith (fun a b => a && !b) fl.kill[j]!
      work := work ++ fl.succ[j]!.map (·, after) ++ fl.pad[j]!.map (·, st)
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

/-- `decodeReducedWith`, accepting the code only if `droppedNotDead` shows every dropped store
dead (given `facts`): the decoding, or an error naming the first store it doesn't (its word
offset). -/
def decodeChecked (code : ByteArray) (fields : Fields) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) (facts : Facts := {}) : Except String Decoded := do
  let d ← match decodeReducedWith code fields rodata callSites dropped scopes mode with
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
