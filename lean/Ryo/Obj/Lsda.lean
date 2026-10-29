/-
# A function's LSDA (aot.md §C3, "Unwind")

A port of `asm::lsda` (`vm/bytecode/src/asm/lsda.rs`): the call-site table
`rust_eh_personality` reads from `.gcc_except_table`. A landing pad is a cleanup (action 0) or
catches everything (action 1, the one action record: type filter 1, which the Rust personality
takes as a catch without reading a type table).

Layout: `lpstart` omitted (`0xff`), `ttype` omitted (`0xff`), call-site encoding `uleb128`
(`0x01`), the table's length, then per call site its start, length, landing pad (0: none) and
action, all `uleb128`; then, if a call site catches, the action record `01 00`.

`parse` accepts exactly what Rust's `parse` accepts: every value is read as
`leb::Reader::minimal_u32` reads it (at most 10 groups, the value at most `u32::MAX`, in its
shortest encoding), and the table is the `len` bytes after its length.
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

/-- `lsda::write`: the LSDA of a function with these call sites (sorted by position). -/
def write (sites : Array CallSite) : ByteArray :=
  let table := sites.toList.flatMap fun s =>
    uleb s.start ++ uleb s.len ++ uleb (s.pad.getD 0) ++ uleb (if s.catches then 1 else 0)
  let actions : List UInt8 := if sites.any (·.catches) then [1, 0] else []
  ⟨([0xff, 0xff, 0x01] ++ uleb table.length ++ table ++ actions).toArray⟩

/-- `leb::Reader::minimal_u32` on the bytes `b` up to `stop`: the `uleb128` at `pos` and the
position after it. At most 10 groups (the 10th holding only bit 63), the value at most
`u32::MAX`, and no trailing zero group. -/
def readUleb (b : ByteArray) (stop pos : Nat) : Option (Nat × Nat) :=
  let rec go (p v k : Nat) (fuel : Nat) : Option (Nat × Nat) :=
    match fuel with
    | 0 => none
    | fuel + 1 =>
      if p < stop ∧ p < b.size then
        let byte := b[p]!.toNat
        if k == 9 && byte &&& 0x7e != 0 then none
        else
          let v := v ||| ((byte % 128) <<< (7 * k))
          if byte < 128 then
            if v < 2 ^ 32 && (k == 0 || byte != 0) then some (v, p + 1) else none
          else go (p + 1) v (k + 1) fuel
      else none
  go pos 0 0 10

/-- `lsda::parse`: the call sites of an LSDA written by `write`, `none` if it isn't one. -/
def parse (b : ByteArray) : Option (Array CallSite) := do
  unless b.size ≥ 3 && b[0]! == 0xff && b[1]! == 0xff && b[2]! == 0x01 do none
  let (len, pos) ← readUleb b b.size 3
  let end_ := pos + len
  unless end_ ≤ b.size do none
  -- Each site reads at least 4 bytes, so `len / 4 + 2` rounds suffice.
  let rec sites (pos : Nat) (acc : Array CallSite) (fuel : Nat) : Option (Array CallSite) :=
    match fuel with
    | 0 => none
    | fuel + 1 =>
      if pos < end_ then do
        let (start, pos) ← readUleb b end_ pos
        let (l, pos) ← readUleb b end_ pos
        let (pad, pos) ← readUleb b end_ pos
        let (action, pos) ← readUleb b end_ pos
        if action > 1 || (action == 1 && pad == 0) then none
        sites pos (acc.push ⟨start, l, if pad != 0 then some pad else none, action == 1⟩) fuel
      else some acc
  let out ← sites pos #[] (len / 4 + 2)
  let actions : List UInt8 := if out.any (·.catches) then [1, 0] else []
  if (b.extract end_ b.size).toList == actions then some out else none

end Ryo.Obj.Lsda
