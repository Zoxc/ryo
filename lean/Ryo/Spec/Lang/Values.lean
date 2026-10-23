/-
Ryo.Spec.Lang.Values — values and places.

Ports: MiniRust `lang/values.md` (`Value`, `Place`) and the `Value` part of
`lang/representation.md` § Generic properties (`le_defined` on values).

Differences:
- D5: `Value.float fmt bits`.
- D4: `char` values are `Value.int` (the code point); `Ty.char` restricts them.
- Enum values are `variant idx data` with the *variant index* (rustc `VariantIdx`), not the
  discriminant; the discriminant is `Variant.discr` of the type (D2, D28).
- Values of `Ty.opaqueBytes` are `Value.union [bytes]` (one chunk covering the type).
-/
import Ryo.Spec.Lang.Types
import Ryo.Spec.Mem.Refine

namespace Ryo.Spec

open Lean

-- [D5]
inductive Value where
  | int (i : Int)
  | bool (b : Bool)
  | float (f : FloatTy) (bits : Nat)
  | ptr (p : Pointer)
  /-- Tuples, structs, arrays, closures (and `()`). -/
  | tuple (vs : List Value)
  /-- An enum value: variant index and the variant's field tuple. -/
  | variant (idx : Nat) (data : Value)
  /-- Unions (and opaque bytes): the preserved chunks. -/
  | union (chunks : List (List AbstractByte))
deriving Repr, BEq, Inhabited, ToJson, FromJson

def unitValue : Value := .tuple []

/-- A place: a (possibly wide) pointer and whether it was aligned when created. -/
structure Place where
  ptr : Pointer
  aligned : Bool := true
deriving Repr, BEq, Inhabited

/-- `le_defined` on values: equality except on pointers (provenance) and union bytes. -/
def Value.leDefined : Value → Value → Bool
  | .int a, .int b => a == b
  | .bool a, .bool b => a == b
  | .float f a, .float g b => f == g && a == b
  | .ptr p, .ptr q => p.leDefined q
  | .tuple as, .tuple bs => leDefinedList as bs
  | .variant i a, .variant j b => i == j && a.leDefined b
  | .union as, .union bs => List.leDefinedBy bytesLeDefined as bs
  | _, _ => false
where
  leDefinedList : List Value → List Value → Bool
    | [], [] => true
    | a :: as, b :: bs => a.leDefined b && leDefinedList as bs
    | _, _ => false

end Ryo.Spec
