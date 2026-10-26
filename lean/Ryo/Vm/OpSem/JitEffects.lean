/-
The JIT's handler effect table (`vm/bytecode/src/jit/effects_table.rs`, behind
`jit::effects::effects`), generated from opSem's footprints (`OpSem/Footprint.lean`; reduced.md
Part D, jit.md §E.7) by `ryo-lean effects`; `y lean` checks the file is up to date and
`y lean gen` rewrites it.

The mapping, per `Slot`/`Mem` operand (in `OpInfo.operands` order; other operands have none):
- address taken (`addrs`) → `Addr`;
- read at a fixed width `n` (a `Mem` operand's pointer slot: 8) → `Read(n)`; written at `n` →
  `Write(n)`;
- accessed at a length the operands give (`opnd`, `mul`: `copy`, `const`, `zero`, `fill`,
  `load.copy`, `store.copy`) → `Block`;
- not named → none.
And `memory` ↔ a deref through a pointer that comes from the frame (`PtrSrc.slot`, `.mem`:
loads, stores, `memcpy`/`memmove`/`memset`, atomics), or a fence. Exceptions the footprints
don't express, handled here explicitly:
- Derefs through address operands (`PtrSrc.addr`, `.loaded`: `const`'s and `fill`'s pool
  bytes, `switch.sparse`'s case list, `addr.sym`'s symbol slot and `addr.sym.ind`'s pointer
  in it) read the image's read-only data, which no store can change; opSem lists them (they
  are L0 accesses with provenance) but they don't order against, or alias, the program's
  memory accesses, so `memory` leaves them out.
- Fences have an empty footprint (opSem is sequentially consistent: a fence does nothing),
  but the JIT's `memory` also means "orders memory accesses", so they have it (`isFence`).
- `resume`'s handler is assembly, outside opSem (no footprint): `overrides` gives its entry
  (it reads the exception slot `x`). `vm/rt/tests/ops.rs` checks it, like every entry,
  against the handlers themselves.
-/
import Ryo.Vm.OpSem.Footprint

namespace Ryo.Vm.OpSem.JitEffects

open Ryo.Vm Ryo.Vm.Handlers

/-- `jit::effects::Effect` (`update` is never produced). -/
inductive Effect where
  | read (n : Nat)
  | write (n : Nat)
  | update (n : Nat)
  | addr
  | block
deriving Repr, DecidableEq

/-- `jit::effects::Effects`: per operand (in `OpInfo.operands` order), and `memory`. -/
structure Effects where
  opnds : List (Option Effect)
  memory : Bool
deriving Repr, DecidableEq

/-- The JIT effect of operand `name` under the footprint `fp` (`error` for a combination the
mapping has no word for). -/
def opndEffect (fp : Footprint) (name : String) : Except String (Option Effect) := do
  if fp.addrs.contains name then
    if fp.reads.any (·.opnd == name) || fp.writes.any (·.opnd == name) then
      throw s!"{name} is both address-taken and accessed"
    return some .addr
  let rs := (fp.reads.filter (·.opnd == name)).map (·.extent)
  let ws := (fp.writes.filter (·.opnd == name)).map (·.extent)
  let lengthDep : Extent → Bool
    | .opnd _ | .mul _ _ => true
    | _ => false
  match rs, ws with
  | [], [] => return none
  | [.bytes n], [] => return some (.read n)
  | [], [.bytes n] => return some (.write n)
  | _, _ =>
    if (rs ++ ws).all lengthDep then return some .block
    throw s!"{name}: no JIT effect for reads {repr rs}, writes {repr ws}"

def isFence (op : Full.Opcode) : Bool :=
  match op.handler? with
  | some h => h.kind == .fence || h.kind == .compiler_fence
  | none => false

/-- The footprint of `op` in the JIT's vocabulary (see the module doc). -/
def jitEffects (op : Full.Opcode) (fp : Footprint) : Except String Effects := do
  let opnds ← op.info.operands.mapM fun o =>
    if o.kind == .slot || o.kind == .mem then opndEffect fp o.name else pure none
  -- Every name the footprint uses is a frame operand (`RyoTest/OpSem.lean`'s
  -- `footprint-names`), so nothing is dropped above.
  let fromFrame : PtrSrc → Bool
    | .slot _ | .mem _ => true
    | .addr _ | .loaded _ => false
  pure { opnds, memory := fp.derefs.any (fromFrame ·.src) || isFence op }

/-- The handlers outside opSem (no footprint), by mnemonic, with their effects. -/
def overrides : List (String × Effects) :=
  [("resume", { opnds := [some (.read 8)], memory := false })]

/-- Every full opcode's effects, in value order (`none` without a handler). -/
def table : Except String (List (Full.Opcode × Option Effects)) :=
  Full.all.mapM fun op => do
    let m := op.info.mnemonic
    match footprint op, overrides.lookup m with
    | some _, some _ => throw s!"{m}: overridden, but has a footprint"
    | none, some e => pure (op, some e)
    | none, none => pure (op, none)
    | some fp, none => pure (op, some (← (jitEffects op fp).mapError (s!"{m}: " ++ ·)))

def rustEffect : Option Effect → String
  | none => "None"
  | some (.read n) => s!"Some(Read({n}))"
  | some (.write n) => s!"Some(Write({n}))"
  | some (.update n) => s!"Some(Update({n}))"
  | some .addr => "Some(Addr)"
  | some .block => "Some(Block)"

/-- `vm/bytecode/src/jit/effects_table.rs`. -/
def rust : Except String String := do
  let t ← table
  let lines := t.map fun (op, e) =>
    let v := match e with
      | none => "None"
      | some e => s!"e(&[{", ".intercalate (e.opnds.map rustEffect)}], {e.memory})"
    s!"    /* {op.info.mnemonic} */ {v},\n"
  pure <| "// @generated by `ryo-lean effects` (lean/Ryo/Vm/OpSem/JitEffects.lean) from opSem's\n\
    // footprints. Do not edit: regenerate with `./y.sh lean gen`.\n\n\
    //! The handler effect table: every full opcode's `effects`, by opcode value.\n\n\
    use super::effects::Effect::*;\n\
    use super::effects::{Effects, e};\n\
    use crate::full::Opcode;\n\n\
    pub(super) const TABLE: [Option<Effects>; Opcode::COUNT] = [\n" ++
    String.join lines ++ "];\n"

/-- `ryo-lean effects [<out.rs>]`: the Rust table, to the file or stdout. -/
def main (args : List String) : IO UInt32 := do
  match rust with
  | .error e => IO.eprintln s!"ryo-lean effects: {e}"; pure 1
  | .ok s =>
    match args with
    | [] => IO.print s; pure 0
    | [path] => IO.FS.writeFile path s; pure 0
    | _ => IO.eprintln "usage: ryo-lean effects [<out.rs>]"; pure 2

end Ryo.Vm.OpSem.JitEffects
