/-
# A function's LSDA (aot.md §C3, "Unwind")

A port of `asm::lsda` (`vm/bytecode/src/asm/lsda.rs`): the call-site table
`rust_eh_personality` reads from `.gcc_except_table`. A landing pad is a cleanup (action 0) or
catches everything (action 1, the one action record: type filter 1, which the Rust personality
takes as a catch without reading a type table).

Layout: `lpstart` omitted (`0xff`), `ttype` omitted (`0xff`), call-site encoding `uleb128`
(`0x01`), the table's length, then per call site its start, length, landing pad (0: none) and
action, all `uleb128`; then, if a call site catches, the action record `01 00`.

`parse` accepts exactly what Rust's `parse` accepts, quirks included: a `uleb128` is read with
the same overflow rule (more than 6 groups, or a value past `u32`, rejects), and the table's
extent is counted in *canonical* `uleb128` lengths (`uleb_len`), as Rust counts it, not in the
bytes actually read.
-/
import Ryo.Obj.Reloc

namespace Ryo.Obj.Lsda

/-- `lsda::uleb`: `v` (below `2 ^ 32`) as `uleb128`. -/
def uleb (v : Nat) : List UInt8 :=
  let rec go (v : Nat) (fuel : Nat) : List UInt8 :=
    match fuel with
    | 0 => []
    | fuel + 1 =>
      let b := (v % 128).toUInt8
      if v / 128 == 0 then [b] else (b ||| 0x80) :: go (v / 128) fuel
  go v 6

/-- `lsda::uleb_len`: the length of `uleb v` for `v < 2 ^ 32` (`v = 0` takes one byte). -/
def ulebLen (v : Nat) : Nat := ((Nat.max v 1).log2 + 1 + 6) / 7

/-- `lsda::write`: the LSDA of a function with these call sites (sorted by position). -/
def write (sites : Array CallSite) : ByteArray :=
  let table := sites.toList.flatMap fun s =>
    uleb s.start ++ uleb s.len ++ uleb (s.pad.getD 0) ++ uleb (if s.catches then 1 else 0)
  let actions : List UInt8 := if sites.any (·.catches) then [1, 0] else []
  ⟨([0xff, 0xff, 0x01] ++ uleb table.length ++ table ++ actions).toArray⟩

/-- The `uleb128` at `pos`, and the position after it, as `parse`'s `next` reads it: at most
6 groups (the 7th group's shift would pass 35), the value at most `u32::MAX`. -/
def readUleb (b : ByteArray) (pos : Nat) : Option (Nat × Nat) :=
  let rec go (pos v shift : Nat) (fuel : Nat) : Option (Nat × Nat) :=
    match fuel with
    | 0 => none
    | fuel + 1 =>
      if h : pos < b.size then
        let byte := b[pos].toNat
        let v := v ||| ((byte % 128) <<< shift)
        if byte < 128 then (if v < 2 ^ 32 then some (v, pos + 1) else none)
        else if shift + 7 > 35 then none
        else go (pos + 1) v (shift + 7) fuel
      else none
  go pos 0 0 6

/-- `lsda::parse`: the call sites of an LSDA written by `write`, `none` if it isn't one. -/
def parse (b : ByteArray) : Option (Array CallSite) := do
  unless b.size ≥ 3 && b[0]! == 0xff && b[1]! == 0xff && b[2]! == 0x01 do none
  let (len, pos) ← readUleb b 3
  -- `read`: the header and the length in canonical lengths; `pos`: the bytes actually read.
  let read := 3 + ulebLen len
  let end_ := read + len
  -- Each site advances `read` by at least 4, so `len / 4 + 1` rounds suffice.
  let rec sites (pos read : Nat) (acc : Array CallSite) (fuel : Nat) :
      Option (Nat × Array CallSite) :=
    match fuel with
    | 0 => none
    | fuel + 1 =>
      if read < end_ then do
        let (start, pos) ← readUleb b pos
        let (l, pos) ← readUleb b pos
        let (pad, pos) ← readUleb b pos
        let (action, pos) ← readUleb b pos
        if action > 1 || (action == 1 && pad == 0) then none
        let read := read + ulebLen start + ulebLen l + ulebLen pad + ulebLen action
        sites pos read (acc.push ⟨start, l, if pad != 0 then some pad else none, action == 1⟩) fuel
      else some (read, acc)
  let (read, out) ← sites pos read #[] (len / 4 + 2)
  let actions : List UInt8 := if out.any (·.catches) then [1, 0] else []
  if read == end_ && end_ ≤ b.size && (b.extract end_ b.size).toList == actions then some out
  else none

end Ryo.Obj.Lsda
