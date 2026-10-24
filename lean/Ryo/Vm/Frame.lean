/-
Ryo.Vm.Frame — frame accesses of R code and the dead-store check aot.md §C2 asks of the Lean
decoder: the Rust decoder trusts the encoder's list of dropped stores; `droppedNotDead` checks
each by a backward liveness over the decoded code.

`access` ports `asm::frame::insns` (`native`, `handler`): the frame operands of each instruction,
read (exactly, or at most for a handler's operand: 16 bytes, or the lengths its `len` /
`elem_size × count` operands give), written, clobbered, address-taken, or opaque (an island's).
Calls and islands read every byte. Beyond `head_liveness`, a pointer access (a native load or
store through a `Mem` operand, any handler call) reads every byte of every escaped object (the
`Escape` scopes', ignoring their ends: conservative).

Inline instructions are taken as their machine items: a read the register cache serves from a
register reads no frame byte, and a dropped store writes none (the L2 frame may differ from R's
there until the bytes are overwritten, aot.md §C2).

A dropped store is dead if none of its bytes is live after its instruction, along the
instruction's successors (fall-through, branch targets, its landing pad). The check is
conservative: a store the encoder dropped by a dead-slot hint (`Asm::dead`) is accepted only if
the code itself shows the bytes dead, which over-estimated handler extents can prevent.
-/
import Ryo.Vm.DecodeReduced

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

/-- `frame::native`: the frame operands of a native instruction. -/
def native (op : Reduced.Opcode) (ops : List (Opnd Nat)) : Effects := Id.run do
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
        let acc : Access := match retParts k false with
          | some (some a, some b) => if b.off == a.size then .write (a.size + b.size) else .clobber (b.off + b.size)
          | some (some a, none) => .write a.size
          | _ => .write 0
        if let some d := slotOf (named "d") then out := out ++ [(d, acc)]
    let ws := match named "a" with
      | some (.words ws) => ws
      | _ => []
    return { opnds := out ++ argPairs ws, readsAll := true }
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
    return { opnds := ws.map (·, .opaque), readsAll := true }
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

/-- `frame::handler`: a handler's slot operands, by `h`'s layout, at most 16 bytes or the
lengths its operands give. Every handler may access memory through a pointer. -/
def handler (h : Full.Opcode) (args : List Arg) (mode : Mode) : Except String Effects := do
  let some l := h.layout mode.fpArg | throw "no layout"
  if args.length != l.regs then throw "handler arguments"
  let info := h.info
  let imm (k : Nat) : Except String Nat := do
    let loc := l.locs[k]!
    match args[loc.reg]? with
    | some (.imm v) => pure (if loc.shared then (v.toNat >>> loc.shift) % 2 ^ 32 else v.toNat)
    | _ => throw "handler argument"
  let index (name : String) : Option Nat := info.operands.findIdx? (·.name == name)
  let mut ext := 16
  if let some k := index "len" then ext := max ext (← imm k)
  if let (some e, some c) := (index "elem_size", index "count") then ext := max ext ((← imm e) * (← imm c))
  let ext' := min ext (2 ^ 32 - 1)
  let mut out : List (BitVec 32 × Access) := []
  for (o, k) in info.operands.zipIdx do
    let loc := l.locs[k]!
    if loc.count == 0 || !(o.kind == .slot || o.kind == .mem) then continue
    let some (.imm v) := args[loc.reg]? | throw "a slot operand that isn't an immediate"
    let s := BitVec.ofNat 32 (v.toNat >>> (loc.shift / 32 * 32))
    let acc : Access := if o.kind == .mem || o.name == "p" then .read 8
      else if o.name == "d" then .clobber ext' else .read ext'
    out := out ++ [(s, acc)]
  return { opnds := out, pointer := true }

/-- An inline instruction's frame accesses as its machine items make them: reads not served by
the register cache, and the writes but a dropped store. -/
def inlineEffects (items : List Item) : Effects :=
  { opnds := items.flatMap fun it =>
      (frameRead it).toList.map (fun (m, n) => (m.disp, Access.read n)) ++
      (frameWrite it).toList.map (fun (m, n) => (m.disp, Access.write n)),
    pointer := items.any fun it => (it.mem?.any (·.base != .rbp)) }

def effects (i : Insn) (items : List Item) (mode : Mode) : Except String Effects :=
  match i with
  | .native op ops =>
    if (op.full.bind classOf).isSome then pure (inlineEffects items) else pure (native op ops)
  | .handler h args _ => handler h args mode

/-! ### Liveness over frame bytes `-F .. 0` -/

/-- The byte indices (`F + off`) of `n` bytes at `off`, clamped to the frame. -/
def range (f : Nat) (off : BitVec 32) (n : Nat) : List Nat :=
  let fi : Int := f
  let lo := max (min off.toInt 0) (-fi) + fi
  let hi := max (min (off.toInt + n) 0) (-fi) + fi
  (List.range (hi - lo).toNat).map (· + lo.toNat)

/-- The dropped stores `droppedNotDead` can't show dead: their instruction indices. -/
def droppedNotDead (d : Decoded) (mode : Mode) : Except String (List Nat) := do
  if d.dropped.isEmpty then return []
  let n := d.insns.size
  let f := d.frameSize
  let all := Array.replicate f true
  let none_ := Array.replicate f false
  let escaped := d.scopes.foldl (fun acc (_, sc) => match sc.kind with
    | .escape _ => (range f sc.frameOffset sc.size).foldl (fun a b => a.set! b true) acc
    | .end => acc) none_
  let mut gen : Array (Array Bool) := #[]
  let mut kill : Array (Array Bool) := #[]
  let mut succ : Array (List Nat) := #[]
  let mut pad : Array (List Nat) := #[]
  for h : k in [0:n] do
    let i := d.insns[k]
    let e ← effects i (d.items[k]?.getD []) mode
    let mut g := if e.readsAll then all else none_
    let mut kl := none_
    if e.pointer then g := g.zipWith (· || ·) escaped
    for (off, acc) in e.opnds do
      match acc with
      | .read m => g := (range f off m).foldl (fun a b => a.set! b true) g
      | .write m => kl := (range f off m).foldl (fun a b => a.set! b true) kl
      | .opaque => g := all
      | _ => pure ()
    kl := kl.zipWith (fun a b => a && !b) g
    gen := gen.push g
    kill := kill.push kl
    let (next, ts) : Bool × List Nat := match i with
      | .native op ops =>
        (!(op.info.shape == .jmp || op.info.shape == .ret || op.info.shape == .tailCall),
          ops.flatMap Opnd.targetsOf)
      | .handler h _ t =>
        (h.info.shape == .op || h.info.shape == .br || h.info.shape == .lpad, t.targets)
    -- Unwinding: to the landing pad, past nothing the instruction writes.
    pad := pad.push (d.cleanup.toList.filterMap fun (c, p, _) => if c == k then p else none)
    succ := succ.push ((if next && k + 1 < n then [k + 1] else []) ++ ts)
  let mut liveIn : Array (Array Bool) := Array.replicate n none_
  let mut changed := true
  let mut rounds := 0
  while changed && rounds < 10 * n + 10 do
    changed := false
    rounds := rounds + 1
    for k' in [0:n] do
      let k := n - 1 - k'
      let out := succ[k]!.foldl (fun a s => a.zipWith (· || ·) liveIn[s]!) none_
      let v := (out.zipWith (fun a b => a && !b) kill[k]!).zipWith (· || ·) gen[k]!
      let v := pad[k]!.foldl (fun a s => a.zipWith (· || ·) liveIn[s]!) v
      let v := v.zipWith (· || ·) liveIn[k]!
      if v != liveIn[k]! then
        liveIn := liveIn.set! k v
        changed := true
  let mut bad : List Nat := []
  for k in d.dropped do
    let liveOut := succ[k]!.foldl (fun a s => a.zipWith (· || ·) liveIn[s]!) none_
    -- The dropped store: the instruction's destination (`mov.w128`'s low half).
    let st : Option (BitVec 32 × Nat) := match d.insns[k]! with
      | .native op ops =>
        match (op.info.operands.zip ops).find? (·.1.name == "d") with
        | some (_, .slot s) =>
          let w := if op.info.mnemonic == "mov.w128" then 8
            else if op.info.mnemonic == "addr" || op.info.mnemonic.startsWith "ptr" then 8
            else (widthOfMnemonic op.info.mnemonic).getD 8
          some (s, w)
        | _ => none
      | _ => none
    match st with
    | some (s, w) => if (range f s w).any (liveOut[·]!) then bad := bad ++ [k]
    | none => bad := bad ++ [k]
  return bad

end Ryo.Vm.Frame
