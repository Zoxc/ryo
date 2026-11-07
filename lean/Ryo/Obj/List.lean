/-
# A function's instruction list (`asm::list`, design/vm.md "Instruction list")

The side data the decoder reads alongside a function's machine code, as one sparse stream of
entries at byte positions (`FuncEntry::list`, a run of the image's instruction-list bytes).
Each entry starts with a varint `v`: the position advances by `v >>> 1` from the previous
entry's (from 0 for the first), and `v &&& 1` says what follows:

- `0`, an instruction: the opcode and the register cache selector plus one (wrapping at
  `2 ^ 32`) of an inline sequence the cache emitted other than plainly, starting here; or,
  with the selector `handlerSel` (stored as `0`), the opcode of the handler the `call` here
  calls (every handler call has one);
- `1`, a modifier: its kind, then its fields: `0` a branch target (where the register cache
  is cleared); `1` a dropped store (the frame offset, then `size_log2 <<< 4 ||| reg`); `2`,
  `3`, `4` an escape, a storage end, an island operand (the frame offset and the size, then
  for an escape the alignment); `5` a source location (`asm::list::Loc`: `file <<< 1 |||
  inlined`, the line as a zigzag delta from the previous location's (from 0, summed in a
  wrapping `i64`, each line in `u32`), the column, then if `inlined` the nonzero name; `file`
  and the name are offsets in the image's string pool, `Header.strings`).

Numbers are LEB128, frame offsets zigzag-encoded. At one position the entries come in the
order target, scopes, dropped stores, locations, instructions (a target once). Locations are
pure labels: the decoders ignore them (`InsnList.read` drops them).

`walk` ports `list::walk` (the well-formedness `Image::validate` checks), `InsnList.read`
`InsnList::read`. The Lean decoder (`decodeReduced`) uses the list's dropped stores and scopes,
and the handler entries for the opcodes of handler calls (`Ryo.Vm.DecodeObj`, as
`asm::decode_linked`): it reads the code in two passes, as `asm::decode_reduced` does, and
doesn't take the targets and inline sequences' entries as an index (`asm::decode_linked`,
which checks them against the code).
-/
import Ryo.Obj.Reloc
import Ryo.Obj.Elf

namespace Ryo.Obj

open Ryo.Vm

/-- The selector of a handler entry (`list::HANDLER_SEL`): the `call` at its position calls
the opcode's handler. -/
def handlerSel : Nat := 2 ^ 32 - 1

/-- An entry of the stream (`list::Entry`). -/
inductive ListEntry where
  /-- An inline sequence the register cache emitted non-plainly: its opcode and selector; or
  with `handlerSel`, a handler call's opcode. -/
  | insn (op : Full.Opcode) (sel : Nat)
  | target
  /-- The frame offset, the size (1, 2, 4 or 8) and the register (x86 number, of the pool). -/
  | dropped (frameOffset : Int) (size reg : Nat)
  | scope (frameOffset : Int) (size : Nat) (kind : ScopeKind)
  /-- A source location: the file's and the name's string pool offsets (`0`: none), the
  absolute line and the column. -/
  | loc (file line col name : Nat)
  deriving Repr, DecidableEq, Inhabited

/-- An instruction entry (`list::Hint`). -/
structure Hint where
  pos : Nat
  op : Full.Opcode
  sel : Nat
  deriving Repr, DecidableEq, Inhabited

/-- Whether it names a handler call (`Hint::is_handler`, `handlerSel`), not an inline
sequence. -/
def Hint.isHandler (h : Hint) : Bool := h.sel == handlerSel

/-- A function's instruction list, its entries by kind, each sorted by position
(`list::InsnList`). -/
structure InsnList where
  /-- The branch targets (byte positions), without duplicates. -/
  targets : Array Nat := #[]
  hints : Array Hint := #[]
  dropped : Array DroppedStore := #[]
  scopes : Array Scope := #[]
  deriving Repr, Inhabited

/-- The LEB128 number at byte `i` (`leb::Reader::u64`: at most 10 bytes, the 10th holding only
bit 63), and the index after it. -/
def readVarint (b : ByteArray) (i : Nat) : Option (Nat × Nat) := Id.run do
  let mut v := 0
  let mut j := i
  for k in [0:10] do
    let some x := b[j]? | return none
    j := j + 1
    if k == 9 && x.toNat &&& 0x7e != 0 then return none
    v := v ||| ((x.toNat &&& 0x7f) <<< (7 * k))
    if x.toNat &&& 0x80 == 0 then return some (v, j)
  return none

/-- `list::walk`: the entries of the stream `bytes` of a function of `codeLen` bytes, with
their positions, if it is well formed: every position within the code (the end included),
every field valid, the entries at one position in order (a target once). -/
def walkList (bytes : ByteArray) (codeLen : Nat) : Option (Array (Nat × ListEntry)) := do
  let mut i := 0
  let mut pos := 0
  -- The kind order of the last entry at `pos`.
  let mut last : Option Nat := none
  let mut out : Array (Nat × ListEntry) := #[]
  -- The line of the last location, an `i64` (`walk` adds deltas wrapping).
  let mut line : Int := 0
  let u32 (r : Nat × Nat) : Option (Nat × Nat) := if r.1 < 2 ^ 32 then some r else none
  let i32 (r : Nat × Nat) : Option (Int × Nat) := do
    let (v, j) ← u32 r
    pure (if v % 2 == 0 then ((v / 2 : Nat) : Int) else -((v / 2 : Nat) : Int) - 1, j)
  -- Every entry takes at least two bytes.
  for _ in [0:bytes.size] do
    if i ≥ bytes.size then break
    let (v, j) ← readVarint bytes i
    i := j
    let delta := v >>> 1
    if delta ≥ 2 ^ 32 || pos + delta ≥ 2 ^ 32 || pos + delta > codeLen then none
    pos := pos + delta
    if delta != 0 then last := none
    let mut order := 0
    let mut e := ListEntry.target
    if v % 2 == 0 then
      let (o, j) ← readVarint bytes i
      let (sel, j) ← u32 (← readVarint bytes j)
      i := j
      if o ≥ 2 ^ 16 then none
      let op ← Full.Opcode.ofNat? o
      order := 4
      e := .insn op ((sel + handlerSel) % 2 ^ 32)
    else
      let (k, j) ← readVarint bytes i
      i := j
      match k with
      | 0 => pure ()
      | 1 =>
        let (off, j) ← i32 (← readVarint bytes i)
        let (sr, j) ← readVarint bytes j
        i := j
        if sr >>> 4 > 3 then none
        let reg := sr &&& 0xf
        if ![0, 2, 6, 7, 8, 9, 10, 11].contains reg then none
        order := 2
        e := .dropped off (2 ^ (sr >>> 4)) reg
      | 2 | 3 | 4 =>
        let (off, j) ← i32 (← readVarint bytes i)
        let (size, j) ← u32 (← readVarint bytes j)
        i := j
        let mut kind := if k == 3 then ScopeKind.end else ScopeKind.lend
        if k == 2 then
          let (a, j) ← u32 (← readVarint bytes i)
          i := j
          if a == 0 || a &&& (a - 1) != 0 || a > 16 then none
          kind := .escape a
        order := 1
        e := .scope off size kind
      | 5 =>
        let (fi, j) ← readVarint bytes i
        let file := fi >>> 1
        if file ≥ 2 ^ 32 then none
        let (d, j) ← readVarint bytes j
        -- `((d >> 1) as i64) ^ -((d & 1) as i64)`, `d >> 1 < 2 ^ 63`.
        let dl : Int := if d % 2 == 0 then ((d >>> 1 : Nat) : Int) else -((d >>> 1 : Nat) : Int) - 1
        line := toSigned 64 ((line + dl) % (2 ^ 64 : Nat)).toNat
        let (col, j) ← u32 (← readVarint bytes j)
        i := j
        let mut name := 0
        if fi % 2 == 1 then
          let (n, j) ← u32 (← readVarint bytes i)
          i := j
          if n == 0 then none
          name := n
        if line < 0 || line ≥ 2 ^ 32 then none
        order := 3
        e := .loc file line.toNat col name
      | _ => none
    if let some l := last then
      if order < l || (order == l && order == 0) then none
    last := some order
    out := out.push (pos, e)
  if i < bytes.size then none
  return out

/-- `InsnList::read`: the list a stream holds, if it is well formed (`walkList`). -/
def InsnList.read (bytes : ByteArray) (codeLen : Nat) : Option InsnList := do
  let es ← walkList bytes codeLen
  return es.foldl (init := {}) fun l (pos, e) => match e with
    | .insn op sel => { l with hints := l.hints.push ⟨pos, op, sel⟩ }
    | .target => { l with targets := l.targets.push pos }
    | .dropped off size reg => { l with dropped := l.dropped.push ⟨pos, off, size, reg⟩ }
    | .scope off size kind => { l with scopes := l.scopes.push ⟨pos, off, size, kind⟩ }
    | .loc .. => l

end Ryo.Obj
