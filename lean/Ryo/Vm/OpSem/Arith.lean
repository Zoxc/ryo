/-
Ryo.Vm.OpSem.Arith — the handlers' integer and float operations, by the Rust method or
operator token the handler table names (`HandlerInfo.params`).

Integers are `BitVec w` at the opcode's width (`w = 8 × size`); the signedness comes from
the parameter type (`i*` for the `.s` forms). Floats are bit patterns, computed by L0's exact
IEEE implementation (`Ryo/Spec/Lang/Float.lean`), NaN results resolved by a `Choice`.
-/
import Ryo.Vm.OpSem.Basic

namespace Ryo.Vm.OpSem

open Ryo.Spec

/-! ### Integers -/

def intMin (w : Nat) : BitVec w := BitVec.ofNat w (2 ^ (w - 1))

/-- Rust's binary integer methods and operators on `a`, `b` (`bin`, `bin_fn`, `binop`,
`shift`, and their `.imm` forms). `wrapping_sh*` masks the amount to the width;
`unchecked_div`/`unchecked_rem` are UB on a zero divisor and on `MIN / -1`. -/
def intBin (m : String) (signed : Bool) {w : Nat} (a b : BitVec w) : M (BitVec w) :=
  match m with
  | "wrapping_add" => pure (a + b)
  | "wrapping_sub" => pure (a - b)
  | "wrapping_mul" => pure (a * b)
  | "&" => pure (a &&& b)
  | "|" => pure (a ||| b)
  | "^" => pure (a ^^^ b)
  | "unchecked_div" | "unchecked_rem" =>
    if b == 0 then ub "division by zero"
    else if signed && a == intMin w && b == BitVec.allOnes w then
      ub "overflow in signed division (MIN / -1)"
    else if m == "unchecked_div" then pure (if signed then a.sdiv b else a.udiv b)
    else pure (if signed then a.srem b else a.umod b)
  | "wrapping_shl" => pure (a <<< (b.toNat % w))
  | "wrapping_shr" => pure (if signed then a.sshiftRight (b.toNat % w) else a >>> (b.toNat % w))
  | _ => throw (.unsupported s!"integer method {m}")

/-- `a.rotate_left(b)`, `a.rotate_right(b)`: `b` is a `u32`, taken modulo the width. -/
def intRot (m : String) {w : Nat} (a : BitVec w) (b : Nat) : M (BitVec w) :=
  match m with
  | "rotate_left" => pure (a.rotateLeft (b % w))
  | "rotate_right" => pure (a.rotateRight (b % w))
  | _ => throw (.unsupported s!"rotation {m}")

/-- Rust's comparison operators. -/
def intCmp (o : String) (signed : Bool) {w : Nat} (a b : BitVec w) : M Bool :=
  match o with
  | "==" => pure (a == b)
  | "!=" => pure (a != b)
  | "<" => pure (if signed then a.slt b else a.ult b)
  | "<=" => pure (if signed then a.sle b else a.ule b)
  | ">" => pure (if signed then b.slt a else b.ult a)
  | ">=" => pure (if signed then b.sle a else b.ule a)
  | _ => throw (.unsupported s!"comparison {o}")

/-- `a.cmp(&b) as i8`. -/
def intCmp3 (signed : Bool) {w : Nat} (a b : BitVec w) : BitVec 8 :=
  let o := if signed then compare a.toInt b.toInt else compare a.toNat b.toNat
  match o with
  | .lt => BitVec.allOnes 8
  | .eq => 0
  | .gt => 1

def countOnes {w : Nat} (a : BitVec w) : Nat := (List.range w).countP (a.getLsbD ·)

def leadingZeros {w : Nat} (a : BitVec w) : Nat :=
  if a.toNat = 0 then w else w - (Nat.log2 a.toNat + 1)

def trailingZeros {w : Nat} (a : BitVec w) : Nat :=
  ((List.range w).find? (a.getLsbD ·)).getD w

/-- `count_ones`, `leading_zeros`, `trailing_zeros` (a `u32`). -/
def intCount (m : String) {w : Nat} (a : BitVec w) : M Nat :=
  match m with
  | "count_ones" => pure (countOnes a)
  | "leading_zeros" => pure (leadingZeros a)
  | "trailing_zeros" => pure (trailingZeros a)
  | _ => throw (.unsupported s!"count {m}")

def swapBytes {w : Nat} (a : BitVec w) : BitVec w :=
  BitVec.ofNat w (leDecode (leEncode (w / 8) a.toNat).reverse)

def reverseBits {w : Nat} (a : BitVec w) : BitVec w :=
  BitVec.ofNat w ((List.range w).foldl (fun acc i => if a.getLsbD i then acc + 2 ^ (w - 1 - i) else acc) 0)

/-- The unary methods (`un`). -/
def intUn (m : String) {w : Nat} (a : BitVec w) : M (BitVec w) :=
  match m with
  | "wrapping_neg" => pure (-a)
  | "not" => pure (~~~a)
  | "swap_bytes" => pure (swapBytes a)
  | "reverse_bits" => pure (reverseBits a)
  | _ => throw (.unsupported s!"unary method {m}")

/-- The value of `a` as the type: signed or unsigned. -/
def BitVec.val {w : Nat} (signed : Bool) (a : BitVec w) : Int := if signed then a.toInt else a.toNat

/-- `overflowing_add`/`_sub`/`_mul`: the wrapped result, and whether the exact result is out
of the type's range. -/
def intOvf (m : String) (signed : Bool) {w : Nat} (a b : BitVec w) : M (BitVec w × Bool) := do
  let x := BitVec.val signed a
  let y := BitVec.val signed b
  let exact ← match m with
    | "overflowing_add" => pure (x + y)
    | "overflowing_sub" => pure (x - y)
    | "overflowing_mul" => pure (x * y)
    | _ => throw (.unsupported s!"overflowing method {m}")
  let r := BitVec.ofInt w exact
  pure (r, BitVec.val signed r != exact)

/-! ### Floats -/

/-- A float result's bits: a NaN's bits are the choice, which must be a candidate. -/
def resolveNaN (ch : Choice) : Ryo.Spec.Float.FRes → M Nat
  | .ok b => pure b
  | .nan cs =>
    match ch.nan with
    | none => pure (cs.headD 0)
    | some b =>
      if cs.contains b then pure b
      else throw (.noBehavior s!"NaN bits {b} are not among the allowed {cs}")

/-- Rust's float operators `+ - * / %` (`%` is `fmod`). -/
def floatBin (ch : Choice) (o : String) (f : FloatTy) (a b : Nat) : M Nat :=
  match o with
  | "+" => resolveNaN ch (Ryo.Spec.Float.add f a b)
  | "-" => resolveNaN ch (Ryo.Spec.Float.sub f a b)
  | "*" => resolveNaN ch (Ryo.Spec.Float.mul f a b)
  | "/" => resolveNaN ch (Ryo.Spec.Float.div f a b)
  | "%" => resolveNaN ch (Ryo.Spec.Float.rem f a b)
  | _ => throw (.unsupported s!"float operator {o}")

/-- `f::min`, `f::max` (IEEE `minNum`/`maxNum`: a NaN operand is ignored; zeros of opposite
sign give either, `Choice.pickY`) and `copysign`. -/
def floatMeth (ch : Choice) (m : String) (f : FloatTy) (a b : Nat) : M Nat :=
  match m with
  | "min" => resolveNaN ch (Ryo.Spec.Float.minNum f false a b ch.pickY)
  | "max" => resolveNaN ch (Ryo.Spec.Float.minNum f true a b ch.pickY)
  | "copysign" => pure (Ryo.Spec.Float.copysign f a b)
  | _ => throw (.unsupported s!"float method {m}")

/-- IEEE comparisons: `!=` is true when unordered, the others false. -/
def floatCmp (o : String) (f : FloatTy) (a b : Nat) : M Bool :=
  let c := Ryo.Spec.Float.cmp f a b
  match o with
  | "==" => pure (c == some .eq)
  | "!=" => pure (c != some .eq)
  | "<" => pure (c == some .lt)
  | "<=" => pure (c == some .lt || c == some .eq)
  | _ => throw (.unsupported s!"float comparison {o}")

/-- `x as y` between the parameter types: integer extension/truncation, saturating float →
integer (NaN → 0), integer → float and float → float rounding to nearest (D34). -/
def convert (ch : Choice) (x y : Ty) (v : Nat) : M Nat :=
  match x, y with
  | .int nx sx, .int ny _ =>
    let i : Int := if sx then (BitVec.ofNat (8 * nx) v).toInt else v
    pure (BitVec.ofInt (8 * ny) i).toNat
  | .float f, .int ny sy =>
    pure (BitVec.ofInt (8 * ny) (Ryo.Spec.Float.toInt f ⟨sy, ny⟩ v)).toNat
  | .int nx sx, .float f =>
    let i : Int := if sx then (BitVec.ofNat (8 * nx) v).toInt else v
    pure (Ryo.Spec.Float.ofInt f i)
  | .float f, .float g => resolveNaN ch (Ryo.Spec.Float.convert f g v)

end Ryo.Vm.OpSem
