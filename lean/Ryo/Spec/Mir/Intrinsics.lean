/-
Ryo.Spec.Mir.Intrinsics — rustc intrinsics (D20).

Ports: MiniRust `lang/step/intrinsics.md` (`Assume`, `Exit`, `Abort`, `RawEq`, the atomics,
`PointerExposeProvenance`/`PointerWithExposedProvenance` are casts in MIR), with rustc's
intrinsics and their documented UB instead of MiniRust's own set.

D20 set handled here (value-returning; `abort`, `unreachable` and `catch_unwind` are control
flow and live in `Ryo.Spec.Mir.Terminator`): `assume`, `black_box`, `likely`, `unlikely`,
`cold_path`, `select_unpredictable`, `ctpop`, `ctlz`, `cttz`, `ctlz_nonzero`, `cttz_nonzero`
(UB on 0), `bswap`, `bitreverse`, `rotate_left`, `rotate_right`, `unchecked_funnel_shl/shr`,
`exact_div`, `disjoint_bitor`, `unchecked_{add,sub,mul,div,rem,shl,shr}`,
`wrapping_{add,sub,mul}`, `saturating_{add,sub}`, `{add,sub,mul}_with_overflow`,
`three_way_compare`, `ptr_offset_from(_unsigned)`, `arith_offset`, `offset`, `ptr_mask`,
`copy`, `copy_nonoverlapping` (UB on overlap), `write_bytes`, `typed_swap_nonoverlapping`,
`size_of_val`, `align_of_val`, `vtable_size`, `vtable_align`, `ptr_guaranteed_cmp`
(daemonic: exact answer or 2), `volatile_*`, `unaligned_volatile_*`, `nontemporal_store`
(plain accesses), the atomics (D17: plain accesses of size ≤ 8 with natural alignment,
read-modify-write computed sequentially, orderings ignored, fences no-ops), `fabs`,
`copysign*`, `minimum_number_nsz_*`/`maximum_number_nsz_*`, `minimum*`/`maximum*`, `sqrt*`,
`fma*`, `fmuladd*` (fused or not, daemonic), `powi*` (compiler-rt's `__powidf2` loop;
`f16` through `f32`),
`float_to_int_unchecked`, `f*_fast` (UB on non-finite inputs or results), `f*_algebraic`
(exact operation: a refinement of the allowed reassociations), `caller_location` (D14),
`raw_eq`, `compare_bytes` (any `i32` of the right sign, daemonic), `prefetch_*` (no-ops).
`minimum_number_nsz_*`/`maximum_number_nsz_*` of zeros of different sign return either one
(daemonic).

Intrinsics that runtime MIR never calls (lowered by `LowerIntrinsics`, or const-evaluated:
`transmute`, `size_of`, `discriminant_value`, `read_via_copy`, ...) and all others are
ill-formed here.
-/
import Ryo.Spec.Mir.External

namespace Ryo.Spec.Sem

open SemM

def intArg : Value × Ty → SemM (Int × IntType)
  | (.int i, .int t _) => pure (i, t)
  | _ => throwIllFormed "intrinsic: expected an integer argument"

def ptrArg : Value × Ty → SemM (Pointer × PtrType)
  | (.ptr p, .ptr pt _) => pure (p, pt)
  | _ => throwIllFormed "intrinsic: expected a pointer argument"

def floatArg : Value × Ty → SemM (FloatTy × Nat)
  | (.float f b, _) => pure (f, b)
  | _ => throwIllFormed "intrinsic: expected a float argument"

def popcount (bits n : Nat) : Nat := ((List.range bits).filter fun i => n.testBit i).length

def leadingZeros (bits n : Nat) : Nat :=
  ((List.range bits).reverse.takeWhile fun i => !n.testBit i).length

def trailingZeros (bits n : Nat) : Nat :=
  ((List.range bits).takeWhile fun i => !n.testBit i).length

def reverseBits (bits n : Nat) : Nat :=
  (List.range bits).foldl (fun acc i => if n.testBit i then acc ||| (1 <<< (bits - 1 - i)) else acc) 0

def swapBytes (size n : Nat) : Nat := leDecode (leEncode size n).reverse

def pointeeLayout (pt : PtrType) : SemM (Size × Align) :=
  match pt.pointee? with
  | some ⟨.sized s a, _⟩ => pure (s, a)
  | _ => throwIllFormed "intrinsic: pointer to an unsized type"

-- [D17]
/-- D17: atomic accesses: size ≤ 8, power of two, natural alignment. -/
def atomicAlign (ty : Ty) : SemM Align := do
  let some size := ty.size? | throwUb "atomic access at an unsized type"
  if size > Target.MAX_ATOMIC_SIZE then throwUb "atomic access too large"
  let some al := Align.ofBytes? size | throwUb "atomic access size is not a power of two"
  pure al

def floatPrefix (n : String) : String :=
  if n.endsWith "f16" then n.dropEnd 3 |>.toString
  else if n.endsWith "f32" || n.endsWith "f64" then n.dropEnd 3 |>.toString
  else if n.endsWith "f128" then n.dropEnd 4 |>.toString
  else n

def isFinite (f : FloatTy) (b : Nat) : Bool := !Float.isNaN f b && !Float.isInf f b

-- [D20] [D17] [D5] [D14]
/-- Value-returning intrinsics. -/
def evalIntrinsic (name : String) (args : List (Value × Ty)) (destTy : Ty) : SemM Value := do
  let unchecked (t : IntType) (i : Int) (what : String) : SemM Value :=
    if t.canRepresent i then pure (.int i) else throwUb s!"overflow in unchecked {what}"
  match name, args with
  | "assume", [(.bool b, _)] =>
    if b then pure unitValue else throwUb "`assume` called on a condition that is false"
  | "black_box", [(v, _)] | "likely", [(v, _)] | "unlikely", [(v, _)] => pure v
  | "cold_path", [] => pure unitValue
  | "select_unpredictable", [(.bool c, _), (a, _), (b, _)] => pure (if c then a else b)
  | "prefetch_read_data", _ | "prefetch_write_data", _ | "prefetch_read_instruction", _
  | "prefetch_write_instruction", _ => pure unitValue
  -- bit manipulation
  | "ctpop", [a] => do
    let (i, t) ← intArg a
    pure (.int (popcount t.bits (t.toBits i)))
  | "ctlz", [a] | "ctlz_nonzero", [a] => do
    let (i, t) ← intArg a
    if name == "ctlz_nonzero" && i == 0 then throwUb "`ctlz_nonzero` called on 0"
    pure (.int (leadingZeros t.bits (t.toBits i)))
  | "cttz", [a] | "cttz_nonzero", [a] => do
    let (i, t) ← intArg a
    if name == "cttz_nonzero" && i == 0 then throwUb "`cttz_nonzero` called on 0"
    pure (.int (trailingZeros t.bits (t.toBits i)))
  | "bswap", [a] => do
    let (i, t) ← intArg a
    pure (.int (t.ofBits (swapBytes t.size (t.toBits i))))
  | "bitreverse", [a] => do
    let (i, t) ← intArg a
    pure (.int (t.ofBits (reverseBits t.bits (t.toBits i))))
  | "rotate_left", [a, n] | "rotate_right", [a, n] => do
    let (i, t) ← intArg a
    let (s, _) ← intArg n
    let s := (s % t.bits).toNat
    let s := if name == "rotate_left" then s else (t.bits - s) % t.bits
    let x := t.toBits i
    pure (.int (t.ofBits ((x <<< s) ||| (x >>> (t.bits - s)))))
  | "unchecked_funnel_shl", [a, b, n] | "unchecked_funnel_shr", [a, b, n] => do
    let (x, t) ← intArg a
    let (y, _) ← intArg b
    let (s, _) ← intArg n
    if s < 0 || s ≥ t.bits then throwUb "funnel shift amount out of range"
    let wide := t.toBits x * 2 ^ t.bits + t.toBits y
    let r := if name == "unchecked_funnel_shl" then (wide <<< s.toNat) >>> t.bits
      else wide >>> s.toNat
    pure (.int (t.ofBits r))
  | "exact_div", [a, b] => do
    let (x, t) ← intArg a
    let (y, _) ← intArg b
    if y == 0 then throwUb "division by zero"
    if !t.canRepresent (x.tdiv y) then throwUb "overflow in division"
    if x.tmod y != 0 then throwUb "non-zero remainder in exact division"
    pure (.int (x.tdiv y))
  | "disjoint_bitor", [a, b] => do
    let (x, t) ← intArg a
    let (y, _) ← intArg b
    if t.toBits x &&& t.toBits y != 0 then throwUb "`disjoint_bitor` on overlapping bits"
    pure (.int (t.ofBits (t.toBits x ||| t.toBits y)))
  | "unchecked_add", [a, b] => do
    let (x, t) ← intArg a; let (y, _) ← intArg b; unchecked t (x + y) "add"
  | "unchecked_sub", [a, b] => do
    let (x, t) ← intArg a; let (y, _) ← intArg b; unchecked t (x - y) "sub"
  | "unchecked_mul", [a, b] => do
    let (x, t) ← intArg a; let (y, _) ← intArg b; unchecked t (x * y) "mul"
  | "unchecked_div", [a, b] => evalIntBinOp .div (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "unchecked_rem", [a, b] => evalIntBinOp .rem (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "unchecked_shl", [a, b] =>
    evalIntBinOp .shlUnchecked (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "unchecked_shr", [a, b] =>
    evalIntBinOp .shrUnchecked (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "wrapping_add", [a, b] => evalIntBinOp .add (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "wrapping_sub", [a, b] => evalIntBinOp .sub (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "wrapping_mul", [a, b] => evalIntBinOp .mul (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "add_with_overflow", [a, b] =>
    evalIntBinOp .addWithOverflow (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "sub_with_overflow", [a, b] =>
    evalIntBinOp .subWithOverflow (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "mul_with_overflow", [a, b] =>
    evalIntBinOp .mulWithOverflow (← intArg a).2 (← intArg a).1 (← intArg b).1 destTy
  | "saturating_add", [a, b] | "saturating_sub", [a, b] => do
    let (x, t) ← intArg a
    let (y, _) ← intArg b
    let r := if name == "saturating_add" then x + y else x - y
    pure (.int (if r < t.min then t.min else if r > t.max then t.max else r))
  | "three_way_compare", [a, b] => evalBinOp .cmp a b destTy
  -- pointers
  | "ptr_offset_from", [a, b] | "ptr_offset_from_unsigned", [a, b] => do
    let (p, pt) ← ptrArg a
    let (q, _) ← ptrArg b
    let sz ← pointeeSize pt
    if sz == 0 then throwUb "ptr_offset_from on a zero-sized type"
    let dist : Int := (p.thin.addr : Int) - q.thin.addr
    -- the range between the two pointers must be in bounds of one allocation
    if p.thin.prov != q.thin.prov && dist != 0 then
      throwUb "ptr_offset_from: pointers into different allocations"
    liftE ((← getMem).signedDereferenceable q.thin dist)
    if dist % sz != 0 then throwUb "ptr_offset_from: distance is not a multiple of the size"
    let n := dist / sz
    if name == "ptr_offset_from_unsigned" && n < 0 then
      throwUb "ptr_offset_from_unsigned: negative distance"
    pure (.int n)
  | "arith_offset", [a, n] => do
    let (p, pt) ← ptrArg a
    let (k, _) ← intArg n
    pure (.ptr (p.thin.wrappingOffset (k * (← pointeeSize pt))).widen)
  | "offset", [a, n] => evalBinOp .offset a n destTy
  | "ptr_mask", [a, m] => do
    let (p, _) ← ptrArg a
    let (mask, t) ← intArg m
    pure (.ptr { p.thin with addr := p.thin.addr &&& t.toBits mask }.widen)
  | "copy", [s, d, c] | "copy_nonoverlapping", [s, d, c]
  | "volatile_copy_memory", [d, s, c] | "volatile_copy_nonoverlapping_memory", [d, s, c] => do
    let (sp, pt) ← ptrArg s
    let (dp, _) ← ptrArg d
    let (n, _) ← intArg c
    let nonOverlapping := name == "copy_nonoverlapping" ||
      name == "volatile_copy_nonoverlapping_memory"
    copyBytes sp dp pt n nonOverlapping
    pure unitValue
  | "write_bytes", [d, v, c] | "volatile_set_memory", [d, v, c] => do
    let (dp, pt) ← ptrArg d
    let (b, _) ← intArg v
    let (n, _) ← intArg c
    let (sz, al) ← pointeeLayout pt
    if n < 0 || n * sz > Target.ISIZE_MAX then throwUb "write_bytes: size overflows isize"
    memUpdate (·.store dp.thin (List.replicate (n.toNat * sz) (.init (UInt8.ofNat b.toNat) none)) al)
    pure unitValue
  | "typed_swap_nonoverlapping", [a, b] => do
    let (x, pt) ← ptrArg a
    let (y, _) ← ptrArg b
    let some pointee := pt.pointee? | throwIllFormed "typed_swap: bad pointer"
    let (sz, al) ← pointeeLayout pt
    let mem ← getMem
    let bx ← liftE (mem.load x.thin sz al)
    let by_ ← liftE (mem.load y.thin sz al)
    if sz > 0 && x.thin.addr < y.thin.addr + sz && y.thin.addr < x.thin.addr + sz then
      throwUb "typed_swap_nonoverlapping: overlapping"
    let _ := pointee
    memUpdate (·.store x.thin by_ al)
    memUpdate (·.store y.thin bx al)
    pure unitValue
  | "size_of_val", [a] | "align_of_val", [a] => do
    let (p, pt) ← ptrArg a
    let some pi := pt.pointee? | throwIllFormed "size_of_val: bad pointer"
    let some (s, al) := computeSizeAndAlign (← getMem) pi.layout p.metadata
      | throwUb "size_of_val: invalid metadata"
    pure (.int (if name == "size_of_val" then s else al.bytes))
  | "vtable_size", [(.ptr p, _)] | "vtable_align", [(.ptr p, _)] => do
    let some (s, al) := vtableSizeAlign (← getMem) p.thin | throwUb "invalid vtable pointer"
    pure (.int (if name == "vtable_size" then s else al.bytes))
  | "ptr_guaranteed_cmp", [a, b] => do
    let exact ← choose .guaranteedCmp
    if !exact then pure (.int 2)
    else
      match a.1, b.1 with
      | .ptr p, .ptr q => pure (.int (if p.thin.addr == q.thin.addr then 1 else 0))
      | _, _ => throwIllFormed "ptr_guaranteed_cmp: bad operands"
  | "volatile_load", [a] | "unaligned_volatile_load", [a] => do
    let (p, _) ← ptrArg a
    let al := if name == "volatile_load" then destTy.align else .one
    liftE (typedLoad (← getMem) p.thin destTy al)
  | "volatile_store", [a, (v, vt)] | "unaligned_volatile_store", [a, (v, vt)]
  | "nontemporal_store", [a, (v, vt)] => do
    let (p, _) ← ptrArg a
    let al := if name == "unaligned_volatile_store" then .one else vt.align
    memUpdate (typedStore · p.thin v vt al)
    pure unitValue
  -- atomics (D17)
  | "atomic_load", [a] => do
    let (p, _) ← ptrArg a
    liftE (typedLoad (← getMem) p.thin destTy (← atomicAlign destTy))
  | "atomic_store", [a, (v, vt)] => do
    let (p, _) ← ptrArg a
    memUpdate (typedStore · p.thin v vt (← atomicAlign vt))
    pure unitValue
  | "atomic_xchg", [a, (v, vt)] => do
    let (p, _) ← ptrArg a
    let al ← atomicAlign vt
    let old ← liftE (typedLoad (← getMem) p.thin vt al)
    memUpdate (typedStore · p.thin v vt al)
    pure old
  | "atomic_cxchg", [a, (expected, vt), (new, _)]
  | "atomic_cxchgweak", [a, (expected, vt), (new, _)] => do
    let (p, _) ← ptrArg a
    let al ← atomicAlign vt
    let old ← liftE (typedLoad (← getMem) p.thin vt al)
    let same := match old, expected with
      | .ptr x, .ptr y => x.thin.addr == y.thin.addr
      | x, y => x == y
    if same then memUpdate (typedStore · p.thin new vt al)
    pure (.tuple [old, .bool same])
  | "atomic_xadd", [a, (v, vt)] | "atomic_xsub", [a, (v, vt)] | "atomic_and", [a, (v, vt)]
  | "atomic_nand", [a, (v, vt)] | "atomic_or", [a, (v, vt)] | "atomic_xor", [a, (v, vt)]
  | "atomic_max", [a, (v, vt)] | "atomic_min", [a, (v, vt)] | "atomic_umax", [a, (v, vt)]
  | "atomic_umin", [a, (v, vt)] => do
    let (p, _) ← ptrArg a
    let al ← atomicAlign vt
    let old ← liftE (typedLoad (← getMem) p.thin vt al)
    let (x, t) ← intArg (old, vt)
    let (y, _) ← intArg (v, vt)
    let bx := t.toBits x
    let byy := t.toBits y
    let r : Int := match name with
      | "atomic_xadd" => t.bringInBounds (x + y)
      | "atomic_xsub" => t.bringInBounds (x - y)
      | "atomic_and" => t.ofBits (bx &&& byy)
      | "atomic_nand" => t.ofBits ((bx &&& byy) ^^^ (t.modulus - 1))
      | "atomic_or" => t.ofBits (bx ||| byy)
      | "atomic_xor" => t.ofBits (bx ^^^ byy)
      | "atomic_max" | "atomic_umax" => max x y
      | _ => min x y
    memUpdate (typedStore · p.thin (.int r) vt al)
    pure old
  | "atomic_fence", [] | "atomic_singlethreadfence", [] => pure unitValue
  -- floats (D5)
  | "fabs", [a] => do
    let (f, b) ← floatArg a
    pure (.float f (Float.abs f b))
  | n, [a, b] =>
    match floatPrefix n with
    | "copysign" => do
      let (f, x) ← floatArg a
      let (_, y) ← floatArg b
      pure (.float f (Float.copysign f x y))
    | "minimum_number_nsz_" | "maximum_number_nsz_" => do
      let (f, x) ← floatArg a
      let (_, y) ← floatArg b
      -- the sign of a zero result is unspecified (`nsz`): a daemonic choice
      let pickY ← if Float.oppositeZeros f x y then choose .nszZero else pure false
      resolveFloat f (Float.minNum f (n.startsWith "max") x y pickY)
    | "minimum" | "maximum" => do
      let (f, x) ← floatArg a
      let (_, y) ← floatArg b
      resolveFloat f (Float.minimum f (n.startsWith "max") x y)
    | "powi" => do
      let (f, x) ← floatArg a
      let (k, _) ← intArg b
      match f with
      | .f16 => resolveFloat f (Float.powiF16 x k)
      | _ => resolveFloat f (Float.powi f x k)
    | _ =>
      match n with
      | "fadd_fast" | "fsub_fast" | "fmul_fast" | "fdiv_fast" | "frem_fast"
      | "fadd_algebraic" | "fsub_algebraic" | "fmul_algebraic" | "fdiv_algebraic"
      | "frem_algebraic" => do
        let (f, x) ← floatArg a
        let (_, y) ← floatArg b
        let r := match n.take 4 |>.toString with
          | "fadd" => Float.add f x y
          | "fsub" => Float.sub f x y
          | "fmul" => Float.mul f x y
          | "fdiv" => Float.div f x y
          | _ => Float.rem f x y
        if n.endsWith "_fast" then
          if !isFinite f x || !isFinite f y then throwUb s!"{n}: non-finite input"
          match r with
          | .ok bits => if isFinite f bits then pure (.float f bits)
                        else throwUb s!"{n}: non-finite result"
          | .nan _ => throwUb s!"{n}: NaN result"
        else resolveFloat f r
      | "raw_eq" => do
        let (p, pt) ← ptrArg a
        let (q, _) ← ptrArg b
        let (sz, al) ← pointeeLayout pt
        let mem ← getMem
        let some x := decodeBits (← liftE (mem.load p.thin sz al))
          | throwUb "raw_eq: uninitialized bytes"
        let some y := decodeBits (← liftE (mem.load q.thin sz al))
          | throwUb "raw_eq: uninitialized bytes"
        pure (.bool (x == y))
      | _ => throwIllFormed s!"unsupported intrinsic `{n}` with 2 arguments"
  | n, [a] =>
    match floatPrefix n with
    | "sqrt" => do
      let (f, x) ← floatArg a
      resolveFloat f (Float.sqrt f x)
    | _ =>
      match n with
      | "float_to_int_unchecked" => do
        let (f, x) ← floatArg a
        let .int t _ := destTy | throwIllFormed "float_to_int_unchecked: bad destination"
        match Float.truncInt? f x with
        | some i => if t.canRepresent i then pure (.int i)
                    else throwUb "float_to_int_unchecked: out of range"
        | none => throwUb "float_to_int_unchecked: not finite"
      | _ => throwIllFormed s!"unsupported intrinsic `{n}` with 1 argument"
  | n, [a, b, c] =>
    match floatPrefix n with
    | "fma" => do
      let (f, x) ← floatArg a
      let (_, y) ← floatArg b
      let (_, z) ← floatArg c
      resolveFloat f (Float.fma f x y z)
    | "fmuladd" => do
      -- fused or not is a daemonic choice (the fallback body and baseline x86-64 do not fuse)
      let (f, x) ← floatArg a
      let (_, y) ← floatArg b
      let (_, z) ← floatArg c
      if ← choose .fmulAddFused then resolveFloat f (Float.fma f x y z)
      else
        let .float _ p ← resolveFloat f (Float.mul f x y) | throwIllFormed "fmuladd"
        resolveFloat f (Float.add f p z)
    | _ =>
      match n with
      | "compare_bytes" => do
        let (p, _) ← ptrArg a
        let (q, _) ← ptrArg b
        let (len, _) ← intArg c
        let mem ← getMem
        let some xs := (← liftE (mem.load p.thin len.toNat .one)).mapM (·.data)
          | throwUb "compare_bytes: uninitialized bytes"
        let some ys := (← liftE (mem.load q.thin len.toNat .one)).mapM (·.data)
          | throwUb "compare_bytes: uninitialized bytes"
        -- `memcmp`: only the sign is specified; the value is a daemonic choice
        let diff : Int := match (xs.zip ys).find? (fun (x, y) => x != y) with
          | some (x, y) => (x.toNat : Int) - y.toNat
          | none => 0
        let r ← choose (.compareBytes diff)
        if !(IntType.i32.canRepresent r && r.sign == diff.sign) then
          throwNoBehavior "compare_bytes result with the wrong sign"
        pure (.int r)
      | _ => throwIllFormed s!"unsupported intrinsic `{n}` with 3 arguments"
  | "caller_location", [] => do
    match (← curFrame).callerLocation with
    | some v => pure v
    | none => throwIllFormed "caller_location outside a #[track_caller] function"
  | n, _ => throwIllFormed s!"unsupported intrinsic `{n}`"

end Ryo.Spec.Sem
