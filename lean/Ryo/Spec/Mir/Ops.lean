/-
Ryo.Spec.Mir.Ops — unary and binary operators.

Ports: MiniRust `lang/step/operators.md` (`eval_int_un_op`, `eval_int_bin_op`,
`IntWithOverflow`, `eval_rel_op`, `compare_ptr`, `ptr_offset_inbounds`, `PtrOffset`,
`GetMetadata`), on rustc's `BinOp`/`UnOp`.

Divergences (D10):
- `Add`/`Sub`/`Mul` wrap; `*Unchecked` are UB on overflow; `*WithOverflow` return `(T, bool)`
  stored at the destination's rustc layout.
- `Div`/`Rem` truncate toward zero; UB on a zero divisor and on `MIN / -1`, `MIN % -1`.
- `Shl`/`Shr`: the right operand may have any integer type; the shift amount is
  `rhs.rem_euclid(bits)`. `ShlUnchecked`/`ShrUnchecked`: UB unless `0 <= rhs < bits`.
- `BitAnd`/`BitOr`/`BitXor`/`Not` also on `bool`.
- `Eq`...`Ge`: integers, `char`, `bool`, floats (IEEE, D5), raw/fn pointers by address and
  then metadata (lexicographically), ignoring provenance.
- `Cmp` returns `Ordering` (an `i8`-tagged enum) at the destination type.
- `Offset` is `ptr.offset(count)`: `count * size_of::<T>()` must fit `isize`, and the
  result must stay in bounds of the allocation (in-bounds arithmetic).
- D5: float arithmetic is exact-then-rounded (`Ryo.Spec.Lang.Float`); NaN results are a
  daemonic choice among RFC 3514's candidates.
- `PtrMetadata` (D29: a vtable pointer for `dyn` pointees).
-/
import Ryo.Spec.Mir.Operand
import Ryo.Spec.Lang.Float

namespace Ryo.Spec.Sem

open SemM

-- [D5]
/-- Resolve a float result: a NaN's bits are a daemonic choice among the candidates (D5). -/
def resolveFloat (f : FloatTy) : Float.FRes → SemM Value
  | .ok b => pure (.float f b)
  | .nan cands => do
    let b ← choose (.nanBits f cands)
    if cands.contains b then pure (.float f b)
    else throwNoBehavior "NaN payload outside the allowed set"

def ordFromBool (lt eq : Bool) : Ordering := if eq then .eq else if lt then .lt else .gt

/-- `compare_ptr`: address, then metadata; provenance is ignored. -/
def comparePtr (a b : Pointer) : Ordering :=
  let metaKey : Option PointerMeta → Nat
    | some (.elementCount n) => n
    | some (.vtablePointer p) => p.addr
    | none => 0
  (compare a.thin.addr b.thin.addr).then (compare (metaKey a.metadata) (metaKey b.metadata))

/-- The value of an `Ordering` at the destination type (D10 `Cmp`). -/
def orderingValue (o : Ordering) (destTy : Ty) : SemM Value := do
  let d : Int := match o with | .lt => -1 | .eq => 0 | .gt => 1
  match destTy with
  | .int .. => pure (.int d)
  | .enum vs discrTy .. =>
    match vs.zipIdx.find? (fun (v, _) => discrTy.bringInBounds v.discr == d) with
    | some (_, i) => pure (.variant i (.tuple []))
    | none => throwIllFormed "Cmp: destination is not Ordering-like"
  | _ => throwIllFormed "Cmp: destination is not Ordering-like"

def relResult (op : BinOp) (o : Option Ordering) (destTy : Ty) : SemM Value :=
  match op, o with
  | .eq, o => pure (.bool (o == some .eq))
  | .ne, o => pure (.bool (o != some .eq))
  | .lt, o => pure (.bool (o == some .lt))
  | .le, o => pure (.bool (o == some .lt || o == some .eq))
  | .gt, o => pure (.bool (o == some .gt))
  | .ge, o => pure (.bool (o == some .gt || o == some .eq))
  | .cmp, some o => orderingValue o destTy
  | _, _ => throwIllFormed "not a relational operator"

def isRel : BinOp → Bool
  | .eq | .ne | .lt | .le | .gt | .ge | .cmp => true
  | _ => false

def bitOp (op : BinOp) (a b : Nat) : Nat :=
  match op with
  | .bitAnd => a &&& b
  | .bitOr => a ||| b
  | _ => a ^^^ b

-- [D10]
/-- `eval_int_bin_op` (+ D10). -/
def evalIntBinOp (op : BinOp) (t : IntType) (l r : Int) (destTy : Ty) : SemM Value := do
  let wrap (i : Int) : Value := .int (t.bringInBounds i)
  let unchecked (i : Int) (what : String) : SemM Value :=
    if t.canRepresent i then pure (.int i) else throwUb s!"overflow in unchecked {what}"
  let withOverflow (i : Int) : SemM Value :=
    pure (.tuple [.int (t.bringInBounds i), .bool (!t.canRepresent i)])
  match op with
  | .add => pure (wrap (l + r))
  | .sub => pure (wrap (l - r))
  | .mul => pure (wrap (l * r))
  | .addUnchecked => unchecked (l + r) "add"
  | .subUnchecked => unchecked (l - r) "sub"
  | .mulUnchecked => unchecked (l * r) "mul"
  | .addWithOverflow => withOverflow (l + r)
  | .subWithOverflow => withOverflow (l - r)
  | .mulWithOverflow => withOverflow (l * r)
  | .div =>
    if r == 0 then throwUb "division by zero"
    else if !t.canRepresent (l.tdiv r) then throwUb "overflow in division"
    else pure (.int (l.tdiv r))
  | .rem =>
    if r == 0 then throwUb "modulus of remainder is zero"
    else if !t.canRepresent (l.tdiv r) then throwUb "overflow in remainder"
    else pure (.int (l.tmod r))
  | .bitAnd | .bitOr | .bitXor => pure (.int (t.ofBits (bitOp op (t.toBits l) (t.toBits r))))
  | .shl | .shr | .shlUnchecked | .shrUnchecked => do
    let bits : Int := t.bits
    let s ← match op with
      | .shl | .shr => pure (r % bits)  -- `rem_euclid`
      | _ =>
        if r < 0 || r ≥ bits then throwUb "overflow in unchecked shift" else pure r
    match op with
    | .shl | .shlUnchecked => pure (wrap (l * 2 ^ s.toNat))
    | _ => pure (.int (l / 2 ^ s.toNat))  -- floor division: arithmetic/logical shift
  | op =>
    if isRel op then relResult op (some (compare l r)) destTy
    else throwIllFormed "invalid integer binary operator"

/-- Pointee size of a pointer type (for `Offset`, `ptr_offset_from`). -/
def pointeeSize (pt : PtrType) : SemM Size :=
  match pt.pointee? with
  | some ⟨.sized s _, _⟩ => pure s
  | _ => throwIllFormed "pointer arithmetic on a pointer to an unsized type"

-- [D10] [D5]
/-- `eval_bin_op`. `destTy` is the type of the assignment's destination. -/
def evalBinOp (op : BinOp) (l : Value × Ty) (r : Value × Ty) (destTy : Ty) : SemM Value := do
  match l, r with
  | (.int a, .int t _), (.int b, _) => evalIntBinOp op t a b destTy
  | (.int a, .char), (.int b, .char) =>
    if isRel op then relResult op (some (compare a b)) destTy
    else throwIllFormed "invalid char operator"
  | (.bool a, .bool), (.bool b, .bool) =>
    match op with
    | .bitAnd => pure (.bool (a && b))
    | .bitOr => pure (.bool (a || b))
    | .bitXor => pure (.bool (a != b))
    | op =>
      if isRel op then relResult op (some (compare a b)) destTy
      else throwIllFormed "invalid bool operator"
  | (.float f a, .float _), (.float g b, .float _) => do
    if f != g then throwIllFormed "float format mismatch"
    match op with
    | .add => resolveFloat f (Float.add f a b)
    | .sub => resolveFloat f (Float.sub f a b)
    | .mul => resolveFloat f (Float.mul f a b)
    | .div => resolveFloat f (Float.div f a b)
    | .rem => resolveFloat f (Float.rem f a b)
    | op =>
      if isRel op then relResult op (Float.cmp f a b) destTy
      else throwIllFormed "invalid float operator"
  | (.ptr p, .ptr pt _), (.int n, _) =>
    match op with
    | .offset => do
      let sz ← pointeeSize pt
      let bytes : Int := n * sz
      if !IntType.isize.canRepresent bytes then throwUb "Offset: byte offset overflows isize"
      let q ← ptrOffsetInbounds p.thin bytes
      pure (.ptr q.widen)
    | _ => throwIllFormed "invalid pointer-integer operator"
  | (.ptr a, .ptr _ _), (.ptr b, .ptr _ _) =>
    if isRel op then relResult op (some (comparePtr a b)) destTy
    else throwIllFormed "invalid pointer operator"
  | _, _ => throwIllFormed "binary operator on incompatible operands"

/-- `eval_un_op`. -/
def evalUnOp (op : UnOp) (v : Value × Ty) (destTy : Ty) : SemM Value := do
  match op, v with
  | .not, (.int i, .int t _) => pure (.int (t.bringInBounds (-i - 1)))
  | .not, (.bool b, _) => pure (.bool !b)
  | .neg, (.int i, .int t _) => pure (.int (t.bringInBounds (-i)))
  | .neg, (.float f b, _) => pure (.float f (Float.neg f b))
  | .ptrMetadata, (.ptr p, .ptr pt _) =>
    match pt.metaKind, p.metadata with
    | .none, none => pure (.tuple [])
    | .elementCount, some (.elementCount n) => pure (.int n)
    | .vtablePointer _, some (.vtablePointer vt) => pure (.ptr vt.widen)
    | _, _ => throwIllFormed "PtrMetadata: metadata does not match the type"
  | _, _ =>
    let _ := destTy
    throwIllFormed "unary operator on an invalid operand"

end Ryo.Spec.Sem
