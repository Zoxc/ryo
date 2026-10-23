/-
Ryo.Spec.Prelude.Target — the target (x86-64 only).

Ports: MiniRust `prelude/target.md` (`Target`, the `x86_64` instance).

ryo compiles for x86-64 (Linux, macOS, Windows), so the target is fixed instead of being a
trait parameter. D26: addresses range over `(0, 2^64)` as in MiniRust; the real user address
space is smaller, but the target's choices are a subset of the spec's.
-/
import Ryo.Spec.Prelude.Basic

namespace Ryo.Spec.Target

def PTR_SIZE : Size := 8
def PTR_ALIGN : Align := ⟨3⟩
def INT_MAX_ALIGN : Align := ⟨4⟩
def MAX_ATOMIC_SIZE : Size := 8
/-- `2^64`: one past the largest address. -/
def ADDR_LIMIT : Nat := 2 ^ 64
/-- `isize::MAX`. -/
def ISIZE_MAX : Nat := 2 ^ 63 - 1

/-- `Target::valid_size`: sizes must fit in `isize`. -/
def validSize (s : Size) : Bool := s ≤ ISIZE_MAX

/-- Little-endian encoding of an unsigned value (`Endianness::encode`, `LittleEndian`). -/
def encodeUnsigned (size : Size) (v : Nat) : List UInt8 := leEncode size v

/-- Little-endian decoding (`Endianness::decode`). -/
def decodeUnsigned (bytes : List UInt8) : Nat := leDecode bytes

end Ryo.Spec.Target
