/-
Ryo.Vm.OpSem.Basic — the state, operands and results of `opSem` (reduced.md Part D, §C0.3).

- `Val`: an operand's value as the handler receives it (after `unpack`): a frame offset, a
  memory operand `[p + k]`, an immediate, an address (`Const`/`Abs`/`Sym`/`Site`, with
  provenance), a jump table's length or a case table's address and count.
- `State`: the frame's **private bytes** by `fp` offset, the frame objects that escaped (each
  an allocation of `mem`), the frame's zero-sized objects with their addresses, L0's memory
  (`Ryo/Spec/Mem`), the exposed allocations, and the exception register a landing pad stores.
- `Stop`: how an operation fails to produce a next state: UB, `abort`, `unreachable`, an
  unimplemented kind, ill-formed operands, or a choice outside its constraint.

Frame bytes are abstract bytes (provenance fragments, `Uninit`). A frame access at offset `o`
of an escaped object reads or writes its allocation's byte, so a frame object has one copy of
its bytes at every point; private bytes are reachable only through frame operands.

`addr` (`State.addrOf`) gives a pointer into an escaped object (with its provenance), one at an
escaped object's end (one past its last byte, with its provenance), or, for a zero-sized frame
object, a pointer without provenance at its address, which only zero-sized accesses may use
(a non-zero access resolves among the exposed allocations, `State.resolve`, which also
serves a pointer whose own allocation doesn't contain the range). Zero-sized
objects never escape (the encoder drops size-0 escapes), so their addresses are part of the
state (`zeroSized`): the layout restricted to them, the one place `opSem` sees a frame address
that isn't an allocation's.
-/
import Ryo.Spec
import Ryo.Vm.Generated

namespace Ryo.Vm.OpSem

open Ryo.Spec

/-- An operand's value as its handler receives it (in `Full.Opcode.info` operand order). -/
inductive Val where
  /-- A `Slot`: the signed frame offset. -/
  | slot (off : Int)
  /-- A `Mem` operand `[p + k]`: the slot holding the pointer, and the signed byte offset. -/
  | mem (p k : Int)
  /-- `U8`…`U64`, `I64` (its 64-bit pattern), `U128`. -/
  | imm (v : Nat)
  /-- `Const`, `Abs`, `Sym`, `Site`: the address the handler gets, with its provenance. -/
  | addr (p : ThinPointer)
  /-- A `Targets` list (`switch.dense`'s table): its length, what the handler gets. -/
  | targets (n : Nat)
  /-- A case list (`switch.sparse`): the address of its `n` values (a code constant). -/
  | cases (p : ThinPointer) (n : Nat)
  /-- An operand the handler doesn't get (`Target`, `Neg`, `Func`). -/
  | none
deriving Repr, DecidableEq, Inhabited

/-- One `Val` per operand of the opcode, in order. -/
abbrev Operands := List Val

/-- Does `v` have the encoding of an operand of kind `k`? -/
def Val.fits : OperandKind → Val → Bool
  | .slot, .slot o => -2 ^ 31 ≤ o && o < 2 ^ 31
  | .mem, .mem p k => -2 ^ 31 ≤ p && p < 2 ^ 31 && -2 ^ 31 ≤ k && k < 2 ^ 31
  | .u8, .imm v => v < 2 ^ 8
  | .u16, .imm v => v < 2 ^ 16
  | .u32, .imm v => v < 2 ^ 32
  | .u64, .imm v | .i64, .imm v => v < 2 ^ 64
  | .u128, .imm v => v < 2 ^ 128
  | .const, .addr _ | .abs, .addr _ | .sym, .addr _ | .site, .addr _ => true
  | .list .target, .targets _ => true
  | .list .case8, .cases .. | .list .case16, .cases .. | .list .case32, .cases ..
  | .list .case64, .cases .. | .list .case128, .cases .. => true
  | .target, .none | .neg, .none | .func, .none | .handler, .none => true
  | _, _ => false

/-- A frame object that escaped: `[off, off + size)` is allocation `id`, from its start. -/
structure EscapedObj where
  off : Int
  size : Nat
  id : AllocId
deriving Repr, DecidableEq, Inhabited

/-- What `opSem` runs on. -/
structure State where
  /-- The private frame bytes, by `fp` offset (an escaped object's are in `mem`). -/
  frame : Int → AbstractByte := fun _ => .uninit
  escaped : List EscapedObj := []
  /-- The frame's zero-sized objects: (`fp` offset, address). The layout restricted to them
  (in R at `φ_AOT`, `fp + off`); `addrOf` of such an offset that isn't in or at the end of an
  escaped object is a pointer without provenance at the address. -/
  zeroSized : List (Int × Nat) := []
  mem : Memory := {}
  /-- The exposed allocations: a pointer without provenance accesses one of them (angelic,
  `IntPtrCast`; R counts every escaped object as exposed). -/
  exposed : List AllocId := []
  /-- `rax` at a landing pad: the exception object `lpad` stores. -/
  exception : ThinPointer := ThinPointer.null

instance : Inhabited State := ⟨{}⟩

/-- Why an operation has no next state. -/
inductive Stop where
  | ub (msg : String)
  /-- `abort` (`core::intrinsics::abort`). -/
  | abort
  /-- `unreachable`: a bare `ud2` (no handler); the lowering only emits it where MIR has UB,
  so R may take it as UB. -/
  | unreachable
  /-- A handler kind this library doesn't define (yet). -/
  | unsupported (what : String)
  /-- The operands don't fit the opcode, or a state invariant is broken. -/
  | illFormed (msg : String)
  /-- A `Choice` outside the allowed set. -/
  | noBehavior (msg : String)
deriving Repr, DecidableEq, Inhabited

instance : ToString Stop where
  toString
    | .ub m => s!"UB: {m}"
    | .abort => "abort"
    | .unreachable => "unreachable"
    | .unsupported m => s!"unsupported: {m}"
    | .illFormed m => s!"ill-formed: {m}"
    | .noBehavior m => s!"no behavior: {m}"

/-- What follows the operation: the next instruction, the branch condition the handler
returns (before the polarity), or the case index (the table's length for the default). -/
inductive Control where
  | next
  | branch (b : Bool)
  | index (i : Nat)
deriving Repr, DecidableEq, Inhabited

/-- The non-deterministic choices of an operation. Each is checked: a choice outside the
allowed set is `noBehavior`, so a differential test passes the handler's own choice.
- `nan`: the bits of a NaN result (the default: the first of the candidates RFC 3514 allows).
- `pickY`: `fmin`/`fmax` of zeros of opposite sign return `b` (else `a`).
- `spurious`: a weak compare-exchange fails although the values are equal. -/
structure Choice where
  nan : Option Nat := none
  pickY : Bool := false
  spurious : Bool := false
deriving Repr, DecidableEq, Inhabited

abbrev M := Except Stop

def ub {α : Type} (msg : String) : M α := throw (.ub msg)
def illFormed {α : Type} (msg : String) : M α := throw (.illFormed msg)

/-- An L0 memory operation's outcome as a `Stop`. -/
def liftOutcome {α : Type} : Except Outcome α → M α
  | .ok a => pure a
  | .error (.ub m) => throw (.ub m)
  | .error (.noBehavior m) => throw (.noBehavior m)
  | .error .abort => throw .abort
  | .error o => throw (.illFormed (toString o))

/-! ### Frame bytes -/

namespace State

/-- The escaped object containing offset `o`, if any. -/
def escapedAt (st : State) (o : Int) : Option EscapedObj :=
  st.escaped.find? fun e => decide (e.off ≤ o ∧ o < e.off + e.size)

/-- The frame byte at `o`: private, or its object's allocation byte. -/
def byteAt (st : State) (o : Int) : M AbstractByte :=
  match st.escapedAt o with
  | none => pure (st.frame o)
  | some e =>
    match st.mem.get? e.id with
    | some a =>
      if !a.live then illFormed s!"escaped frame object at {e.off} is not live"
      else match a.data[(o - e.off).toNat]? with
        | some b => pure b
        | none => illFormed s!"escaped frame object at {e.off} is smaller than its allocation"
    | none => illFormed s!"escaped frame object at {e.off} has no allocation"

/-- `n` frame bytes from `off`. -/
def readFrame (st : State) (off : Int) (n : Nat) : M (List AbstractByte) :=
  (List.range n).mapM fun (i : Nat) => st.byteAt (off + i)

/-- The bytes of `bs` that fall in escaped objects, written to their allocations. -/
def writeEscaped (st : State) (off : Int) (bs : List AbstractByte) : M Memory :=
  bs.zipIdx.foldlM (init := st.mem) fun mem (b, i) =>
    match st.escapedAt (off + i) with
    | none => pure mem
    | some e =>
      match mem.get? e.id with
      | none => illFormed s!"escaped frame object at {e.off} has no allocation"
      | some a =>
        let a' := { a with data := a.data.set! (off + i - e.off).toNat b }
        pure { allocs := mem.allocs.set! e.id a' }

/-- Is `o` in `[off, off + n)` and private? -/
def privateIn (st : State) (off : Int) (n : Nat) (o : Int) : Bool :=
  decide (off ≤ o ∧ o < off + n) && (st.escapedAt o).isNone

/-- Write `bs` at frame offset `off`. -/
def writeFrame (st : State) (off : Int) (bs : List AbstractByte) : M State := do
  let mem ← st.writeEscaped off bs
  let frame : Int → AbstractByte := fun o =>
    if st.privateIn off bs.length o then bs.getD (o - off).toNat .uninit else st.frame o
  pure { st with mem := mem, frame := frame }

/-- The pointer to frame offset `s` (`addr`, a by-address call argument), §C0.3, in this order:
1. `s` in an escaped object `e`: into `e`'s allocation, with its provenance;
2. `s = e.off + e.size` for an escaped object `e` of non-zero size: `e`'s allocation's end (one
   past its last byte), with its provenance (a zero-sized field at the end of an object; `ptr.add`
   back from it reaches the object's bytes);
3. `s` the offset of a zero-sized object (`zeroSized`): its address, without provenance; only a
   zero-sized access may use it (L0 accepts any pointer for length 0; a non-zero access resolves
   among the exposed allocations, `resolve`, and is UB when none contains the range);
4. else UB. -/
def addrOf (st : State) (s : Int) : M ThinPointer :=
  match st.escapedAt s with
  | some e =>
    match st.mem.get? e.id with
    | some a => pure ⟨a.addr + (s - e.off).toNat, some e.id⟩
    | none => illFormed s!"escaped frame object at {e.off} has no allocation"
  | none =>
    match st.escaped.find? (fun e => e.size != 0 && e.off + e.size == s) with
    | some e =>
      match st.mem.get? e.id with
      | some a => pure ⟨a.addr + e.size, some e.id⟩
      | none => illFormed s!"escaped frame object at {e.off} has no allocation"
    | none =>
      match st.zeroSized.find? (·.1 == s) with
      | some (_, addr) => pure ⟨addr, none⟩
      | none => ub s!"taking the address of frame offset {s}, which is neither in nor at the end of an escaped object nor a zero-sized object"

/-! ### Memory through pointers -/

/-- Does live allocation `id` contain `[addr, addr + len)`? -/
def fits (st : State) (addr len : Nat) (id : AllocId) : Bool :=
  match st.mem.get? id with
  | some a => a.live && a.addr ≤ addr && addr + len ≤ a.addr + a.size
  | none => false

/-- `p` with the provenance of the exposed live allocation containing `[p.addr, p.addr + len)`,
or `p` unchanged if there is none. -/
def resolveExposed (st : State) (p : ThinPointer) (len : Nat) : ThinPointer :=
  match st.exposed.find? (st.fits p.addr len) with
  | some id => { p with prov := some id }
  | none => p

/-- A pointer's provenance for an access of `len` bytes: its own if that live allocation
contains the range, else the exposed live allocation containing it (`IntPtrCast`'s angelic
choice, made at the access; allocations of non-zero size don't overlap, so there is at most
one), else its own (and the access is UB unless `len = 0`).

The fallback for a pointer *with* provenance makes provenance only ever add definedness: R
keeps provenance where Rust drops it (`expose_provenance` and ptr↔int transmutes are moves,
the JIT's identities `x + 0 → x` return the pointer), and L0 resolves a provenance-less
pointer at the int→ptr cast. With the fallback, a pointer is at least as defined as the same
address without provenance, or with any exposed one (`Ryo.Proofs.Provenance`,
reduced.md §C0.3). -/
def resolve (st : State) (p : ThinPointer) (len : Nat) : ThinPointer :=
  match p.prov with
  | some id => if st.fits p.addr len id then p else st.resolveExposed p len
  | none => st.resolveExposed p len

def load (st : State) (p : ThinPointer) (len : Nat) (align : Align := Align.one) :
    M (List AbstractByte) :=
  liftOutcome (st.mem.load (st.resolve p len) len align)

def store (st : State) (mem : Memory) (p : ThinPointer) (bs : List AbstractByte)
    (align : Align := Align.one) : M Memory :=
  liftOutcome (mem.store (st.resolve p bs.length) bs align)

/-- Is `p` dereferenceable for `len` bytes (before building a long byte list)? -/
def checkDeref (st : State) (p : ThinPointer) (len : Nat) : M Unit :=
  liftOutcome (st.mem.dereferenceable (st.resolve p len) len)

end State

/-! ### Values in bytes -/

/-- Bytes read as an integer: provenance dropped, `Uninit` is UB (MiniRust's integer decode). -/
def asNat (bs : List AbstractByte) : M Nat :=
  match decodeBits bs with
  | some n => pure n
  | none => ub "reading uninitialized bytes as an integer"

/-- Bytes read as a pointer (`decode_ptr`): provenance kept if all bytes carry it in order. -/
def asPtr (bs : List AbstractByte) : M ThinPointer :=
  match decodePtr bs with
  | some p => pure p
  | none => ub "reading uninitialized bytes as a pointer"

/-- An integer's `n` bytes, without provenance. -/
def intBytes (n v : Nat) : List AbstractByte := encodeBits n v

/-- The types of handler parameters (`u8`…`u128`, `i8`…`i128`, `usize`, `bool`, `f32`,
`f64`). -/
inductive Ty where
  | int (size : Nat) (signed : Bool)
  | float (f : FloatTy)
deriving Repr, DecidableEq, Inhabited

def Ty.parse : String → Option Ty
  | "u8" => some (.int 1 false) | "u16" => some (.int 2 false) | "u32" => some (.int 4 false)
  | "u64" => some (.int 8 false) | "u128" => some (.int 16 false)
  | "i8" => some (.int 1 true) | "i16" => some (.int 2 true) | "i32" => some (.int 4 true)
  | "i64" => some (.int 8 true) | "i128" => some (.int 16 true)
  | "usize" => some (.int 8 false) | "bool" => some (.int 1 false)
  | "f32" => some (.float .f32) | "f64" => some (.float .f64)
  | _ => none

def Ty.size : Ty → Nat
  | .int n _ => n
  | .float f => f.size

def Ty.signed : Ty → Bool
  | .int _ s => s
  | .float _ => true

/-- The `IntType` of an integer `Ty`. -/
def Ty.intType : Ty → IntType
  | .int n s => ⟨s, n⟩
  | .float f => ⟨true, f.size⟩

end Ryo.Vm.OpSem
