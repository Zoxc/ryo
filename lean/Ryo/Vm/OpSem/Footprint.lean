/-
Ryo.Vm.OpSem.Footprint — each opcode's footprint, from the generated handler table
(reduced.md Part D, jit.md §E.7: the JIT's exact handler effect tables).

A footprint names operands of the opcode (`Full.Opcode.info`), so it is per opcode and
symbolic in the operand values:

- `reads`, `writes`: the frame operands read and written, each at its exact extent (a fixed
  width, a `U32` operand such as `copy`'s `len`, `fill`'s `elem_size × count`, or
  `set_discr`'s width unless `variant = untagged`). A `Mem` operand `[p + k]` reads the 8
  bytes of its slot `p`. Writes are in the handler's order (`ovf`: `d`, then `o`).
- `addrs`: the slot operands whose address is taken (`addr`).
- `derefs`: the accesses through pointers (L0 memory accesses with provenance): through a
  pointer in a slot, a memory operand, an address operand, or the pointer an address operand
  points to (`addr.sym.ind`), with an extent, read/write/read-modify-write, and whether the
  access is aligned (atomics). A memory extent is an upper bound where the handler may stop
  early (`switch.sparse`'s search, a failed compare-exchange's store).
- `flow`: fall through, branch on the returned `bool`, jump through a table on the returned
  index, or not return.

`opSem` reads the frame only through `reads` and writes it only through `writes`
(`Ryo/Vm/OpSem/Lemmas.lean`).
-/
import Ryo.Vm.OpSem.Basic

namespace Ryo.Vm.OpSem

open Ryo.Vm Ryo.Vm.Handlers

/-- The extent of an access. -/
inductive Extent where
  | bytes (n : Nat)
  /-- The value of the immediate operand `name` (`len`). -/
  | opnd (name : String)
  /-- The product of two immediate operands (`fill`'s `elem_size × count`). -/
  | mul (a b : String)
  /-- `n` bytes, or none when the immediates `a` and `b` are equal (`set_discr`). -/
  | unlessEq (n : Nat) (a b : String)
  /-- The `usize` in the frame slot `name` (`memcpy`'s `n`); memory accesses only. -/
  | slotVal (name : String)
  /-- `size ×` the count of the case list `name` (`switch.sparse`); memory accesses only. -/
  | cases (name : String) (size : Nat)
deriving Repr, DecidableEq, Inhabited

/-- A frame operand access: the operand and its extent. -/
structure Access where
  opnd : String
  extent : Extent
deriving Repr, DecidableEq, Inhabited

/-- Where a pointer access's pointer comes from. -/
inductive PtrSrc where
  /-- The pointer in the frame slot `name`. -/
  | slot (name : String)
  /-- The memory operand `name`: `load64(fp + p) + k`. -/
  | mem (name : String)
  /-- The address operand `name` (`Const`, `Sym`, a case list). -/
  | addr (name : String)
  /-- The pointer stored at the address operand `name`. -/
  | loaded (name : String)
deriving Repr, DecidableEq, Inhabited

inductive MemKind where
  | read
  | write
  | rmw
deriving Repr, DecidableEq, Inhabited

structure Deref where
  src : PtrSrc
  extent : Extent
  kind : MemKind
  aligned : Bool := false
deriving Repr, DecidableEq, Inhabited

/-- The control effect. -/
inductive Flow where
  | next
  /-- Branch on the returned `bool` (with the instruction's polarity). -/
  | branch
  /-- Jump through the table on the returned index, the default last. -/
  | table
  /-- Doesn't return. -/
  | trap
deriving Repr, DecidableEq, Inhabited

structure Footprint where
  reads : List Access := []
  writes : List Access := []
  addrs : List String := []
  derefs : List Deref := []
  flow : Flow := .next
deriving Repr, DecidableEq, Inhabited

/-- Width in bytes of a handler type parameter. -/
def tySize (t : String) : Option Nat := (Ty.parse t).map Ty.size

private def rd (n : String) (k : Nat) : Access := ⟨n, .bytes k⟩

/-- The footprint of a handler kind with its parameters (`HandlerInfo`); `none` if a type
parameter is unknown. Operand names follow `ops.rs`'s conventions, which the tests check
against every opcode's operands. -/
def footprintOf (k : HandlerKind) (ps : List String) : Option Footprint := do
  let w : Option Nat := ps.head?.bind tySize
  match k with
  | .mov => let n ← w; pure { reads := [rd "s" n], writes := [rd "d" n] }
  | .copy => pure { reads := [⟨"s", .opnd "len"⟩], writes := [⟨"d", .opnd "len"⟩] }
  | .imm => let n ← w; pure { writes := [rd "d" n] }
  | .konst =>
    pure { writes := [⟨"d", .opnd "len"⟩], derefs := [⟨.addr "k", .opnd "len", .read, false⟩] }
  | .zero => pure { writes := [⟨"d", .opnd "len"⟩] }
  | .load =>
    let n ← w
    pure { reads := [rd "m" 8], writes := [rd "d" n], derefs := [⟨.mem "m", .bytes n, .read, false⟩] }
  | .store =>
    let n ← w
    pure { reads := [rd "m" 8, rd "s" n], derefs := [⟨.mem "m", .bytes n, .write, false⟩] }
  | .load_copy =>
    pure { reads := [rd "m" 8], writes := [⟨"d", .opnd "len"⟩],
           derefs := [⟨.mem "m", .opnd "len", .read, false⟩] }
  | .store_copy =>
    pure { reads := [rd "m" 8, ⟨"s", .opnd "len"⟩],
           derefs := [⟨.mem "m", .opnd "len", .write, false⟩] }
  | .memcpy | .memmove =>
    pure { reads := [rd "dp" 8, rd "sp" 8, rd "n" 8],
           derefs := [⟨.slot "sp", .slotVal "n", .read, false⟩, ⟨.slot "dp", .slotVal "n", .write, false⟩] }
  | .memset =>
    pure { reads := [rd "dp" 8, rd "b" 1, rd "n" 8],
           derefs := [⟨.slot "dp", .slotVal "n", .write, false⟩] }
  | .fill =>
    pure { writes := [⟨"d", .mul "elem_size" "count"⟩],
           derefs := [⟨.addr "k", .opnd "elem_size", .read, false⟩] }
  | .addr => pure { writes := [rd "d" 8], addrs := ["s"] }
  | .addr_sym =>
    let ind := ps.head? == some "true"
    pure { writes := [rd "d" 8],
           derefs := [⟨.addr "sym", .bytes 8, .read, true⟩] ++
             (if ind then [⟨.loaded "sym", .bytes 8, .read, true⟩] else []) }
  | .addr_abs => pure { writes := [rd "d" 8] }
  | .ptr_add => pure { reads := [rd "p" 8], writes := [rd "d" 8] }
  | .ptr_index => pure { reads := [rd "p" 8, rd "i" 8], writes := [rd "d" 8] }
  | .bin | .bin_fn | .binop | .shift | .fbin | .fmeth =>
    let n ← w; pure { reads := [rd "a" n, rd "b" n], writes := [rd "d" n] }
  | .cmp | .cmp3 | .fcmp =>
    let n ← w; pure { reads := [rd "a" n, rd "b" n], writes := [rd "d" 1] }
  | .rot => let n ← w; pure { reads := [rd "a" n, rd "b" 4], writes := [rd "d" n] }
  | .bin_imm | .binop_imm | .shift_imm | .un | .fneg | .«fun» =>
    let n ← w; pure { reads := [rd "a" n], writes := [rd "d" n] }
  | .cmp_imm => let n ← w; pure { reads := [rd "a" n], writes := [rd "d" 1] }
  | .count => let n ← w; pure { reads := [rd "a" n], writes := [rd "d" 4] }
  | .ovf =>
    let n ← w; pure { reads := [rd "a" n, rd "b" n], writes := [rd "d" n, rd "o" 1] }
  | .cvt =>
    let x ← w
    let y ← (ps.drop 1).head?.bind tySize
    pure { reads := [rd "s" x], writes := [rd "d" y] }
  | .discr => let n ← w; pure { reads := [rd "s" n], writes := [rd "d" 4] }
  | .set_discr => let n ← w; pure { writes := [⟨"d", .unlessEq n "variant" "untagged"⟩] }
  | .aload =>
    let n ← (ps.drop 1).head?.bind tySize
    pure { reads := [rd "p" 8], writes := [rd "d" n], derefs := [⟨.slot "p", .bytes n, .read, true⟩] }
  | .astore =>
    let n ← (ps.drop 1).head?.bind tySize
    pure { reads := [rd "p" 8, rd "s" n], derefs := [⟨.slot "p", .bytes n, .write, true⟩] }
  | .armw =>
    let n ← (ps.drop 1).head?.bind tySize
    pure { reads := [rd "p" 8, rd "s" n], writes := [rd "d" n],
           derefs := [⟨.slot "p", .bytes n, .rmw, true⟩] }
  | .cxchg =>
    let n ← (ps.drop 1).head?.bind tySize
    pure { reads := [rd "p" 8, rd "old" n, rd "new" n], writes := [rd "d" n, rd "o" 1],
           derefs := [⟨.slot "p", .bytes n, .rmw, true⟩] }
  | .fence | .compiler_fence => pure {}
  | .br => pure { reads := [rd "s" 1], flow := .branch }
  | .br_cmp => let n ← w; pure { reads := [rd "a" n, rd "b" n], flow := .branch }
  | .br_cmp_imm => let n ← w; pure { reads := [rd "a" n], flow := .branch }
  | .switch_dense => let n ← w; pure { reads := [rd "s" n], flow := .table }
  | .switch_sparse =>
    let n ← w
    pure { reads := [rd "s" n], derefs := [⟨.addr "cases", .cases "cases" n, .read, false⟩],
           flow := .table }
  | .trap | .abort_now => pure { flow := .trap }
  | .lpad => pure { writes := [rd "x" 8] }

/-- The footprint of a full opcode with a handler written in Rust (`none` for the others:
the calls, `ret`, `arg`, `jmp`, `island`, and `resume`, whose handler is assembly). -/
def footprint (op : Full.Opcode) : Option Footprint :=
  op.handler?.bind fun h => footprintOf h.kind h.params

/-! ### Concrete extents and ranges -/

/-- The operand `name`'s value. -/
def opndVal (info : OpInfo) (ops : Operands) (name : String) : Option Val :=
  ((info.operands.zip ops).find? (·.1.name == name)).map (·.2)

/-- An extent's length given the operand values (`none` for the memory-only extents). -/
def Extent.eval (val : String → Option Val) : Extent → Option Nat
  | .bytes n => some n
  | .opnd a => match val a with
    | some (.imm v) => some v
    | _ => Option.none
  | .mul a b => match val a, val b with
    | some (.imm x), some (.imm y) => some (x * y)
    | _, _ => none
  | .unlessEq n a b => match val a, val b with
    | some (.imm x), some (.imm y) => some (if x == y then 0 else n)
    | _, _ => none
  | .slotVal _ => none
  | .cases c n => match val c with
    | some (.cases _ k) => some (k * n)
    | _ => Option.none

/-- The frame offset of a slot or memory operand (the slot `p` of `[p + k]`). -/
def Val.slotOff : Val → Option Int
  | .slot o => some o
  | .mem p _ => some p
  | _ => Option.none

/-- A frame access's byte range `(offset, length)`. -/
def Access.range (val : String → Option Val) (a : Access) : Option (Int × Nat) := do
  let off ← (val a.opnd).bind Val.slotOff
  let n ← a.extent.eval val
  pure (off, n)

/-- The frame ranges of a footprint's reads and writes for the given operands. -/
def Footprint.readRanges (fp : Footprint) (val : String → Option Val) : List (Int × Nat) :=
  fp.reads.filterMap (·.range val)

def Footprint.writeRanges (fp : Footprint) (val : String → Option Val) : List (Int × Nat) :=
  fp.writes.filterMap (·.range val)

def inRange (o : Int) (r : Int × Nat) : Bool := decide (r.1 ≤ o ∧ o < r.1 + r.2)

end Ryo.Vm.OpSem
