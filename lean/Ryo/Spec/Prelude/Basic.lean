/-
Ryo.Spec.Prelude.Basic — basic numeric domains of the L0 (MIR) spec.

Ports: libspecr's `Int`, `Size`, `Align` as used by MiniRust
(github.com/minirust/minirust, commit d821c6e3), and `lang/types.md` § "Integer type convenience
functions" (`IntType::can_represent`, `bring_in_bounds`).

Choices:
- `Size`/`Offset` are `Nat` (libspecr `Size` is a non-negative `Int`).
- `Align` stores the power-of-two exponent, so every `Align` is a power of two by construction.
- Ids (`AllocId`, `GlobalId`, `InstanceId`, `Local`, `BasicBlock`) are `Nat`.
- Integer values are mathematical `Int`, as in MiniRust (mir-spec §A.2.5). Bit-level operations go
  through `IntType.toBits`/`IntType.ofBits` (two's complement on `size * 8` bits), which is also
  the bridge to the `BitVec` world of the lower levels.

Divergences applied here: none (D27: 128-bit integers are ordinary `IntType`s).
-/
import Lean.Data.Json

namespace Ryo.Spec

open Lean

instance : ToJson UInt8 := ⟨fun b => toJson b.toNat⟩
instance : FromJson UInt8 := ⟨fun j => do
  let n : Nat ← fromJson? j
  if n < 256 then pure (UInt8.ofNat n) else throw s!"byte out of range: {n}"⟩

abbrev Size := Nat
abbrev Offset := Nat
abbrev AllocId := Nat
abbrev GlobalId := Nat
abbrev InstanceId := Nat
abbrev Local := Nat
abbrev BasicBlock := Nat

/-- An alignment: `2 ^ exp` bytes. JSON: the byte count. -/
structure Align where
  exp : Nat
deriving DecidableEq, Repr, Inhabited, Hashable, Ord

namespace Align

def bytes (a : Align) : Nat := 2 ^ a.exp

def one : Align := ⟨0⟩

/-- `Align::from_bytes`: `none` unless `n` is a power of two. -/
def ofBytes? (n : Nat) : Option Align :=
  if n == 0 then none
  else
    let e := Nat.log2 n
    if 2 ^ e == n then some ⟨e⟩ else none

/-- Total version, rounding down to a power of two (used only for literals in tests). -/
def ofBytes (n : Nat) : Align := ⟨Nat.log2 n⟩

def isAligned (a : Align) (addr : Nat) : Bool := addr % a.bytes == 0

def min (a b : Align) : Align := if a.exp ≤ b.exp then a else b
def max (a b : Align) : Align := if a.exp ≤ b.exp then b else a

instance : ToJson Align := ⟨fun a => toJson a.bytes⟩
instance : FromJson Align := ⟨fun j => do
  let n : Nat ← fromJson? j
  match ofBytes? n with
  | some a => pure a
  | none => throw s!"alignment {n} is not a power of two"⟩

instance : ToString Align := ⟨fun a => toString a.bytes⟩

end Align

/-- Round `n` up to a multiple of `a` (libspecr `Size::align_to`). -/
def alignTo (n : Nat) (a : Align) : Nat := (n + a.bytes - 1) / a.bytes * a.bytes

/-- Integer types (MiniRust `IntType`). `size` is in bytes: 1, 2, 4, 8 or 16. -/
structure IntType where
  signed : Bool
  size : Size
deriving DecidableEq, Repr, Inhabited, Hashable, ToJson, FromJson

namespace IntType

def bits (t : IntType) : Nat := t.size * 8

def modulus (t : IntType) : Nat := 2 ^ t.bits

def min (t : IntType) : Int := if t.signed then -((2 : Int) ^ (t.bits - 1)) else 0

def max (t : IntType) : Int :=
  if t.signed then (2 : Int) ^ (t.bits - 1) - 1 else (2 : Int) ^ t.bits - 1

/-- `IntType::can_represent` (`Int::in_bounds`). -/
def canRepresent (t : IntType) (i : Int) : Bool := t.min ≤ i && i ≤ t.max

/-- Two's complement bits of `i` (any `Int`), i.e. `i mod 2^bits`. -/
def toBits (t : IntType) (i : Int) : Nat := (i % (t.modulus : Int)).toNat

/-- The integer that the low `bits` bits of `n` denote at this type. -/
def ofBits (t : IntType) (n : Nat) : Int :=
  let n := n % t.modulus
  if t.signed && n ≥ 2 ^ (t.bits - 1) then (n : Int) - t.modulus else n

/-- `IntType::bring_in_bounds`: wrap `i` into the range of the type. -/
def bringInBounds (t : IntType) (i : Int) : Int := t.ofBits (t.toBits i)

def align (t : IntType) : Align :=
  -- Natural alignment, capped by `INT_MAX_ALIGN` = 16 (x86-64; i128 is 16-aligned since 1.77).
  Align.min (Align.ofBytes t.size) ⟨4⟩

def u8 : IntType := ⟨false, 1⟩
def u16 : IntType := ⟨false, 2⟩
def u32 : IntType := ⟨false, 4⟩
def u64 : IntType := ⟨false, 8⟩
def u128 : IntType := ⟨false, 16⟩
def i8 : IntType := ⟨true, 1⟩
def i16 : IntType := ⟨true, 2⟩
def i32 : IntType := ⟨true, 4⟩
def i64 : IntType := ⟨true, 8⟩
def i128 : IntType := ⟨true, 16⟩
def usize : IntType := ⟨false, 8⟩
def isize : IntType := ⟨true, 8⟩

end IntType

/-- Floating-point formats (D5). `f16`/`f128` are bits only. -/
inductive FloatTy where
  | f16 | f32 | f64 | f128
deriving DecidableEq, Repr, Inhabited, Hashable, ToJson, FromJson

namespace FloatTy
def size : FloatTy → Size
  | f16 => 2 | f32 => 4 | f64 => 8 | f128 => 16
def bits (f : FloatTy) : Nat := f.size * 8
def align (f : FloatTy) : Align := Align.ofBytes f.size
/-- Width of the exponent field. -/
def expBits : FloatTy → Nat
  | f16 => 5 | f32 => 8 | f64 => 11 | f128 => 15
/-- Width of the stored significand field. -/
def manBits : FloatTy → Nat
  | f16 => 10 | f32 => 23 | f64 => 52 | f128 => 112
end FloatTy

/-- The value of a little-endian byte list. -/
def leDecode : List UInt8 → Nat
  | [] => 0
  | b :: bs => b.toNat + 256 * leDecode bs

/-- Little-endian encoding of `v mod 256^n` in `n` bytes. -/
def leEncode : Nat → Nat → List UInt8
  | 0, _ => []
  | n + 1, v => UInt8.ofNat (v % 256) :: leEncode n (v / 256)

theorem leEncode_length (n v : Nat) : (leEncode n v).length = n := by
  induction n generalizing v with
  | zero => rfl
  | succ n ih => simp [leEncode, ih]

end Ryo.Spec
