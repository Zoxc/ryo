/-
Ryo.Spec.Lang.Float — IEEE 754 binary floating point (D5, D34).

Ports: none (MiniRust has no floats).

D5: a float value is its bit pattern (`Value.float fmt bits`). Instead of mir-spec's opaque
hardware functions, the operations are defined exactly on `Nat`/`Int`: a finite float is
`(-1)^s * M * 2^E`, every operation computes its exact result as a rational `num/den * 2^e`
and `roundRat` rounds it to nearest, ties to even. So the arithmetic is transparent to proofs
(and checked against Lean's hardware `Float`/`Float32` in the tests). This works for every
`FloatTy`, so `f16`/`f128` get arithmetic too, although mir-spec only requires their bits.

NaN results are not computed here: an operation returns `.nan candidates`, the list of bit
patterns RFC 3514 allows (the preferred quiet NaN with either sign, and each NaN input made
quiet with either sign). The machine resolves it with the daemonic `Choice.nanBits`.

D34: `as` casts: float → int truncates and saturates, NaN → 0; int → float and float → float
round to nearest, ties to even.
-/
import Ryo.Spec.Prelude.Basic

namespace Ryo.Spec.Float

open FloatTy

/-- Result of a float operation: definite bits, or a NaN whose bits are a daemonic choice. -/
inductive FRes where
  | ok (bits : Nat)
  | nan (candidates : List Nat)
deriving Repr, BEq, Inhabited

def bias (f : FloatTy) : Nat := 2 ^ (f.expBits - 1) - 1
def expMax (f : FloatTy) : Nat := 2 ^ f.expBits - 1
def signBit (f : FloatTy) : Nat := 2 ^ (f.bits - 1)
def quietBit (f : FloatTy) : Nat := 2 ^ (f.manBits - 1)

def sign (f : FloatTy) (b : Nat) : Bool := (b / signBit f) % 2 == 1
def expField (f : FloatTy) (b : Nat) : Nat := (b / 2 ^ f.manBits) % 2 ^ f.expBits
def manField (f : FloatTy) (b : Nat) : Nat := b % 2 ^ f.manBits

def isNaN (f : FloatTy) (b : Nat) : Bool := expField f b == expMax f && manField f b != 0
def isInf (f : FloatTy) (b : Nat) : Bool := expField f b == expMax f && manField f b == 0
def isZero (f : FloatTy) (b : Nat) : Bool := expField f b == 0 && manField f b == 0

def mkBits (f : FloatTy) (s : Bool) (e m : Nat) : Nat :=
  (if s then signBit f else 0) + e * 2 ^ f.manBits + m

def zero (f : FloatTy) (s : Bool) : Nat := mkBits f s 0 0
def inf (f : FloatTy) (s : Bool) : Nat := mkBits f s (expMax f) 0
/-- The preferred (canonical) quiet NaN. -/
def qnan (f : FloatTy) (s : Bool := false) : Nat := mkBits f s (expMax f) (quietBit f)

/-- Flip the sign bit (`fneg`: exact, also on NaN). -/
def neg (f : FloatTy) (b : Nat) : Nat := if sign f b then b - signBit f else b + signBit f
def abs (f : FloatTy) (b : Nat) : Nat := if sign f b then b - signBit f else b
def copysign (f : FloatTy) (x y : Nat) : Nat :=
  let a := abs f x
  if sign f y then a + signBit f else a

/-- Finite value `(sign, M, E)` with value `(-1)^sign * M * 2^E`. -/
def finite (f : FloatTy) (b : Nat) : Bool × Nat × Int :=
  let e := expField f b
  let m := manField f b
  if e == 0 then (sign f b, m, (1 : Int) - bias f - f.manBits)
  else (sign f b, m + 2 ^ f.manBits, (e : Int) - bias f - f.manBits)

/-- `num * 2^e` vs `den * 2^k`, as a comparison of naturals. -/
def geScaled (num den : Nat) (e k : Int) : Bool :=
  if e ≥ k then num * 2 ^ (e - k).toNat ≥ den else num ≥ den * 2 ^ (k - e).toNat

/-- `floor(log2(num/den * 2^e))` for `num, den > 0`. -/
def flog2 (num den : Nat) (e : Int) : Int :=
  let k0 : Int := (Nat.log2 num : Int) - (Nat.log2 den : Int) + e
  -- the true value is in [k0 - 1, k0]
  if geScaled num den e k0 then k0 else k0 - 1

/-- Round `(-1)^s * num/den * 2^e` (`den > 0`) to nearest, ties to even. -/
def roundRat (f : FloatTy) (s : Bool) (num den : Nat) (e : Int) : Nat :=
  if num == 0 || den == 0 then zero f s
  else
    let emin : Int := 1 - (bias f : Int)
    let k := flog2 num den e
    let ulp : Int := (if k < emin then emin else k) - f.manBits
    -- q = num/den * 2^(e - ulp)
    let n := num * 2 ^ (e - ulp).toNat
    let d := den * 2 ^ (ulp - e).toNat
    let q0 := n / d
    let r := n % d
    let q := if 2 * r > d || (2 * r == d && q0 % 2 == 1) then q0 + 1 else q0
    let (q, ulp) := if q ≥ 2 ^ (f.manBits + 1) then (q / 2, ulp + 1) else (q, ulp)
    if q < 2 ^ f.manBits then mkBits f s 0 q  -- subnormal (or zero)
    else
      let ef : Int := ulp + f.manBits + bias f
      if ef ≥ expMax f then inf f s else mkBits f s ef.toNat (q - 2 ^ f.manBits)

/-- Round an integer (D34 `IntToFloat`). -/
def ofInt (f : FloatTy) (i : Int) : Nat := roundRat f (i < 0) i.natAbs 1 0

-- [D5]
/-- The NaN candidates of RFC 3514 for an operation with the given inputs. -/
def nanCandidates (f : FloatTy) (inputs : List Nat) : List Nat :=
  let quieted := (inputs.filter (isNaN f)).map fun b => (abs f b) ||| quietBit f
  ([qnan f false, qnan f true] ++ quieted.flatMap fun b => [b, b + signBit f]).eraseDups

def nanOf (f : FloatTy) (inputs : List Nat) : FRes := .nan (nanCandidates f inputs)

/-- Exact sum of two finite values as a signed integer times `2^E`. -/
def exactAdd (f : FloatTy) (x y : Nat) : Int × Int :=
  let (sx, mx, ex) := finite f x
  let (sy, my, ey) := finite f y
  let e := min ex ey
  let vx : Int := (mx * 2 ^ (ex - e).toNat : Nat)
  let vy : Int := (my * 2 ^ (ey - e).toNat : Nat)
  ((if sx then -vx else vx) + (if sy then -vy else vy), e)

def add (f : FloatTy) (x y : Nat) : FRes :=
  if isNaN f x || isNaN f y then nanOf f [x, y]
  else if isInf f x && isInf f y then
    if sign f x == sign f y then .ok x else nanOf f [x, y]
  else if isInf f x then .ok x
  else if isInf f y then .ok y
  else
    let (v, e) := exactAdd f x y
    if v == 0 then .ok (zero f (sign f x && sign f y))
    else .ok (roundRat f (v < 0) v.natAbs 1 e)

def sub (f : FloatTy) (x y : Nat) : FRes :=
  if isNaN f y then nanOf f [x, y] else add f x (neg f y)

def mul (f : FloatTy) (x y : Nat) : FRes :=
  let s := sign f x != sign f y
  if isNaN f x || isNaN f y then nanOf f [x, y]
  else if (isInf f x && isZero f y) || (isZero f x && isInf f y) then nanOf f [x, y]
  else if isInf f x || isInf f y then .ok (inf f s)
  else
    let (_, mx, ex) := finite f x
    let (_, my, ey) := finite f y
    .ok (roundRat f s (mx * my) 1 (ex + ey))

def div (f : FloatTy) (x y : Nat) : FRes :=
  let s := sign f x != sign f y
  if isNaN f x || isNaN f y then nanOf f [x, y]
  else if (isInf f x && isInf f y) || (isZero f x && isZero f y) then nanOf f [x, y]
  else if isInf f x then .ok (inf f s)
  else if isInf f y then .ok (zero f s)
  else if isZero f y then .ok (inf f s)
  else
    let (_, mx, ex) := finite f x
    let (_, my, ey) := finite f y
    .ok (roundRat f s mx my (ex - ey))

/-- `%` on floats: C `fmod` (exact; the sign of the result is the sign of `x`). -/
def rem (f : FloatTy) (x y : Nat) : FRes :=
  if isNaN f x || isNaN f y || isInf f x || isZero f y then nanOf f [x, y]
  else if isInf f y || isZero f x then .ok x
  else
    let (sx, mx, ex) := finite f x
    let (_, my, ey) := finite f y
    let e := min ex ey
    let r := (mx * 2 ^ (ex - e).toNat) % (my * 2 ^ (ey - e).toNat)
    .ok (roundRat f sx r 1 e)

/-- Fused multiply-add `x * y + z`, one rounding. -/
def fma (f : FloatTy) (x y z : Nat) : FRes :=
  let sp := sign f x != sign f y
  if isNaN f x || isNaN f y || isNaN f z then nanOf f [x, y, z]
  else if (isInf f x && isZero f y) || (isZero f x && isInf f y) then nanOf f [x, y, z]
  else if isInf f x || isInf f y then
    if isInf f z && sign f z != sp then nanOf f [x, y, z] else .ok (inf f sp)
  else if isInf f z then .ok z
  else
    let (_, mx, ex) := finite f x
    let (_, my, ey) := finite f y
    let (sz, mz, ez) := finite f z
    let ep := ex + ey
    let e := min ep ez
    let vp : Int := (mx * my * 2 ^ (ep - e).toNat : Nat)
    let vz : Int := (mz * 2 ^ (ez - e).toNat : Nat)
    let v := (if sp then -vp else vp) + (if sz then -vz else vz)
    if v == 0 then
      -- exact zero: -0 only when both addends are (negative) zeros
      .ok (zero f (vp == 0 && vz == 0 && sp && sz))
    else .ok (roundRat f (v < 0) v.natAbs 1 e)

def sqrt (f : FloatTy) (x : Nat) : FRes :=
  if isNaN f x then nanOf f [x]
  else if isZero f x then .ok x
  else if sign f x then nanOf f [x]
  else if isInf f x then .ok x
  else
    let (_, m, e) := finite f x
    let (m, e) := if e % 2 == 0 then (m, e) else (2 * m, e - 1)
    let p := f.manBits + 3
    let sc := m * 4 ^ p
    let r := Nat.sqrt sc
    let sticky := if r * r == sc then 0 else 1
    .ok (roundRat f false (4 * r + sticky) 4 (e / 2 - p))

/-- IEEE comparison: `none` if unordered (a NaN is involved). `-0 == +0`. -/
def cmp (f : FloatTy) (x y : Nat) : Option Ordering :=
  if isNaN f x || isNaN f y then none
  else
    let rank (b : Nat) : Int := if isInf f b then (if sign f b then -1 else 1) else 0
    if isInf f x || isInf f y then some (compare (rank x) (rank y))
    else some (compare (exactAdd f x (neg f y)).1 0)

-- [D34]
/-- `FloatToInt` (D34): truncate toward zero, saturate, NaN → 0. -/
def toInt (f : FloatTy) (t : IntType) (x : Nat) : Int :=
  if isNaN f x then 0
  else if isInf f x then (if sign f x then t.min else t.max)
  else
    let (s, m, e) := finite f x
    let mag : Nat := if e ≥ 0 then m * 2 ^ e.toNat else m / 2 ^ (-e).toNat
    let v : Int := if s then -(mag : Int) else mag
    if v < t.min then t.min else if v > t.max then t.max else v

/-- Exact truncation toward zero, `none` for NaN/inf (`float_to_int_unchecked` checks range). -/
def truncInt? (f : FloatTy) (x : Nat) : Option Int :=
  if isNaN f x || isInf f x then none
  else
    let (s, m, e) := finite f x
    let mag : Nat := if e ≥ 0 then m * 2 ^ e.toNat else m / 2 ^ (-e).toNat
    some (if s then -(mag : Int) else mag)

-- [D34] [D5]
/-- `FloatToFloat` (D34): exact or rounded; NaN payloads are a daemonic choice. -/
def convert (src dst : FloatTy) (x : Nat) : FRes :=
  if isNaN src x then
    let payload := manField src x
    let shifted :=
      if dst.manBits ≥ src.manBits then payload * 2 ^ (dst.manBits - src.manBits)
      else payload / 2 ^ (src.manBits - dst.manBits)
    let q := mkBits dst false (expMax dst) (shifted ||| quietBit dst)
    .nan ([qnan dst false, qnan dst true, q, q + signBit dst]).eraseDups
  else if isInf src x then .ok (inf dst (sign src x))
  else if isZero src x then .ok (zero dst (sign src x))
  else
    let (s, m, e) := finite src x
    .ok (roundRat dst s m 1 e)

/-- IEEE 754-2019 `minimumNumber`/`maximumNumber` (`minimum_number_nsz_*`): a NaN operand is
ignored. With `nsz`, the sign of a zero result is unspecified; we return `x` (a refinement). -/
def minNum (f : FloatTy) (isMax : Bool) (x y : Nat) : FRes :=
  if isNaN f x && isNaN f y then nanOf f [x, y]
  else if isNaN f x then .ok y
  else if isNaN f y then .ok x
  else match cmp f x y with
    | some .lt => .ok (if isMax then y else x)
    | some .gt => .ok (if isMax then x else y)
    | _ => .ok x

/-- IEEE 754-2019 `minimum`/`maximum` (`minimumf*`): NaN-propagating, `-0 < +0`. -/
def minimum (f : FloatTy) (isMax : Bool) (x y : Nat) : FRes :=
  if isNaN f x || isNaN f y then nanOf f [x, y]
  else match cmp f x y with
    | some .lt => .ok (if isMax then y else x)
    | some .gt => .ok (if isMax then x else y)
    | _ =>
      -- equal: distinguish zeros by sign
      if isZero f x && isZero f y && sign f x != sign f y then
        .ok (if isMax then zero f false else zero f true)
      else .ok x

/-- Hardware reference implementations, used only by the tests to cross-check the exact
arithmetic above. -/
def hwBinop64 (op : String) (x y : Nat) : Nat :=
  let a := _root_.Float.ofBits (UInt64.ofNat x)
  let b := _root_.Float.ofBits (UInt64.ofNat y)
  let r := match op with
    | "add" => a + b | "sub" => a - b | "mul" => a * b | "div" => a / b | _ => a
  r.toBits.toNat

def hwBinop32 (op : String) (x y : Nat) : Nat :=
  let a := _root_.Float32.ofBits (UInt32.ofNat x)
  let b := _root_.Float32.ofBits (UInt32.ofNat y)
  let r := match op with
    | "add" => a + b | "sub" => a - b | "mul" => a * b | "div" => a / b | _ => a
  r.toBits.toNat

def hwSqrt64 (x : Nat) : Nat := (_root_.Float.ofBits (UInt64.ofNat x)).sqrt.toBits.toNat

end Ryo.Spec.Float
