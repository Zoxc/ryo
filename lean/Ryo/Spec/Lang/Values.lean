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
deriving Repr, Inhabited, ToJson, FromJson

/-! ## Structural equality (as for `Ty`: `Value` is nested, so `deriving BEq` is opaque) -/

mutual

def Value.beq : Value → Value → Bool
  | .int i, .int i' => i == i'
  | .bool b, .bool b' => b == b'
  | .float f b, .float f' b' => f == f' && b == b'
  | .ptr p, .ptr p' => p == p'
  | .tuple vs, .tuple vs' => Value.beqList vs vs'
  | .variant i d, .variant i' d' => i == i' && Value.beq d d'
  | .union cs, .union cs' => cs == cs'
  | _, _ => false

def Value.beqList : List Value → List Value → Bool
  | [], [] => true
  | v :: vs, v' :: vs' => Value.beq v v' && Value.beqList vs vs'
  | _, _ => false

end

mutual

theorem Value.beq_iff : (a b : Value) → Value.beq a b = true ↔ a = b
  | .int _, b | .bool _, b | .float .., b | .ptr _, b | .union _, b => by
    cases b <;> simp [Value.beq]
  | .tuple vs, b => by cases b <;> simp [Value.beq, Value.beqList_iff vs]
  | .variant _ d, b => by cases b <;> simp [Value.beq, Value.beq_iff d]

theorem Value.beqList_iff : (a b : List Value) → Value.beqList a b = true ↔ a = b
  | [], b => by cases b <;> simp [Value.beqList]
  | v :: vs, b => by
    cases b <;> simp [Value.beqList, Value.beq_iff v, Value.beqList_iff vs]

end

instance : DecidableEq Value := fun a b => decidable_of_iff _ (Value.beq_iff a b)

def unitValue : Value := .tuple []

/-- A place: a (possibly wide) pointer and whether it was aligned when created. -/
structure Place where
  ptr : Pointer
  aligned : Bool := true
deriving Repr, DecidableEq, Inhabited

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
