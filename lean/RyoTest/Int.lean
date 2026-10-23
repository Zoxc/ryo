/-
Port of MiniRust `tooling/minitest/src/tests/int.rs` (D10 integer operators, D20 integer
intrinsics). Nested MiniRust expressions become temporaries.
-/
import RyoTest.Harness

namespace RyoTest.Int

open Ryo.Spec Ryo.Spec.Build

def arithWorks : Program := mainOnly do
  assumeBin .add u8 (cu8 1) (cu8 7) (cu8 8)
  assumeBin .sub u8 (cu8 1) (cu8 7) (cu8 250)
  assumeBin .mul u8 (cu8 1) (cu8 7) (cu8 7)
  assumeBin .div u8 (cu8 1) (cu8 7) (cu8 0)
  assumeBin .rem u8 (cu8 1) (cu8 7) (cu8 1)
  let i := cint i8
  assumeBin .div i8 (i 7) (i 3) (i 2)
  assumeBin .rem i8 (i 7) (i 3) (i 1)
  assumeBin .div i8 (i 7) (i (-3)) (i (-2))
  assumeBin .rem i8 (i 7) (i (-3)) (i 1)
  assumeBin .div i8 (i (-7)) (i 3) (i (-2))
  assumeBin .rem i8 (i (-7)) (i 3) (i (-1))
  assumeBin .div i8 (i (-7)) (i (-3)) (i 2)
  assumeBin .rem i8 (i (-7)) (i (-3)) (i (-1))
  ret

def ubProg (op : BinOp) (ty : Ty) (a b : Operand) : Program := mainOnly do
  evalBin op ty a b
  ret

def bitOps : Program := mainOnly do
  assumeBin .bitAnd i32 (ci32 171) (ci32 62) (ci32 42)
  assumeBin .bitAnd i32 (ci32 171) (ci32 (-214)) (ci32 42)
  assumeBin .bitAnd i32 (ci32 (-2645)) (ci32 62) (ci32 42)
  assumeBin .bitAnd i32 (ci32 (-41)) (ci32 (-10)) (ci32 (-42))
  assumeBin .bitOr i32 (ci32 34) (ci32 10) (ci32 42)
  assumeBin .bitOr i32 (ci32 6) (ci32 (-46)) (ci32 (-42))
  assumeBin .bitOr i32 (ci32 (-44)) (ci32 18) (ci32 (-42))
  assumeBin .bitOr i32 (ci32 (-58)) (ci32 (-46)) (ci32 (-42))
  assumeBin .bitXor i32 (ci32 14) (ci32 36) (ci32 42)
  assumeBin .bitXor i32 (ci32 6) (ci32 (-48)) (ci32 (-42))
  assumeBin .bitXor i32 (ci32 41) (ci32 (-1)) (ci32 (-42))
  assumeBin .bitXor i32 (ci32 (-1)) (ci32 (-43)) (ci32 42)
  assumeEq (← tmp i32 (.unaryOp .not (ci32 42))) (ci32 (-43))
  assumeEq (← tmp i32 (.unaryOp .not (ci32 (-43)))) (ci32 42)
  assumeEq (← tmp u8 (.unaryOp .not (cu8 0))) (cu8 255)
  ret

def countOnes : Program := program do
  let ctpop ← addIntrinsic "ctpop"
  addFn "main" <| body unit [] do
    let chk (t : Ty) (v : Int) (expect : Int) : FnB Unit := do
      assumeEq (← callTmp ctpop u32 [cint t v]) (cint u32 expect)
    chk u8 0 0
    chk i8 (-128) 1
    chk i32 2934823 10
    chk i32 (-90238485) 20
    chk u64 98238923898093 23
    ret

def shlShrWorks : Program := mainOnly do
  assumeBin .shl u8 (cu8 1) (cu8 7) (cu8 128)
  assumeBin .shl u8 (cu8 1) (cu8 0) (cu8 1)
  assumeBin .shl i32 (ci32 (-1)) (ci32 1) (ci32 (-2))
  assumeBin .shl i32 (ci32 2147483647) (ci32 1) (ci32 (-2))
  assumeBin .shl u16 (cint u16 1) (ci32 7) (cint u16 128)
  assumeBin .shl u8 (cu8 1) (ci32 8) (cu8 1)
  assumeBin .shl u8 (cu8 1) (ci32 9) (cu8 2)
  assumeBin .shl u8 (cu8 1) (ci32 (-1)) (cu8 128)
  assumeBin .shr u8 (cu8 255) (cu8 7) (cu8 1)
  assumeBin .shr u8 (cu8 1) (ci32 0) (cu8 1)
  assumeBin .shr i16 (cint i16 (-4)) (cint u16 1) (cint i16 (-2))
  assumeBin .shr i32 (ci32 (-1)) (ci32 1) (ci32 (-1))
  assumeBin .shr i32 (ci32 1) (ci32 1) (ci32 0)
  assumeBin .shr i32 (ci32 2147483647) (ci32 1) (ci32 1073741823)
  assumeBin .shr i32 (ci32 (-2147483648)) (ci32 1) (ci32 (-1073741824))
  assumeBin .shr u8 (cu8 255) (ci32 7) (cu8 1)
  assumeBin .shr i16 (cint i16 (-4)) (cu8 1) (cint i16 (-2))
  assumeBin .shr u8 (cu8 1) (ci32 8) (cu8 1)
  assumeBin .shr u8 (cu8 2) (ci32 9) (cu8 1)
  assumeBin .shr u8 (cu8 255) (ci32 (-1)) (cu8 1)
  ret

def uncheckedWorks : Program := mainOnly do
  let i := cint i8
  assumeBin .addUnchecked i8 (i (-128)) (i 127) (i (-1))
  assumeBin .addUnchecked i8 (i 0) (i (-127)) (i (-127))
  assumeBin .subUnchecked i8 (i (-1)) (i 127) (i (-128))
  assumeBin .subUnchecked i8 (i (-1)) (i (-128)) (i 127)
  assumeBin .mulUnchecked i8 (i (-1)) (i 127) (i (-127))
  assumeBin .mulUnchecked i8 (i (-8)) (i 16) (i (-128))
  assumeBin .shlUnchecked u8 (cu8 1) (cu8 7) (cu8 128)
  assumeBin .shlUnchecked i32 (ci32 2147483647) (ci32 1) (ci32 (-2))
  assumeBin .shlUnchecked u16 (cint u16 1) (ci32 7) (cint u16 128)
  assumeBin .shrUnchecked u8 (cu8 255) (cu8 7) (cu8 1)
  assumeBin .shrUnchecked i32 (ci32 (-2147483648)) (ci32 1) (ci32 (-1073741824))
  assumeBin .shrUnchecked i16 (cint i16 (-4)) (cu8 1) (cint i16 (-2))
  ret

def ordering : Ty := .enum
  [⟨-1, tuple [] 1 1, true⟩, ⟨0, tuple [] 1 1, true⟩, ⟨1, tuple [] 1 1, true⟩] IntType.i8
  (.multiple ⟨0, IntType.i8, ⟨255, 1⟩, .direct⟩) 1 .one

def cmpWorks : Program := mainOnly do
  assumeBin .cmp i8 (ci32 0) (ci32 (-1)) (cint i8 1)
  assumeBin .cmp i8 (ci32 (-1)) (ci32 0) (cint i8 (-1))
  assumeBin .cmp i8 (ci32 0) (ci32 1) (cint i8 (-1))
  assumeBin .cmp i8 (ci32 0) (ci32 0) (cint i8 0)
  assumeBin .cmp i8 (cint i128 (2^127 - 1)) (cint i128 (-(2^127))) (cint i8 1)
  -- D10: `Cmp` at rustc's `Ordering` (an `i8`-tagged enum)
  let o ← newLocal ordering
  storageLive o
  assignL o (.binaryOp .cmp (ci32 3) (ci32 5))
  assumeEq (← tmp i8 (.discriminant (place o))) (cint i8 (-1))
  ret

def overflowTy : Ty := tuple [(0, i32), (4, bool)] 8 4

def overflowWorks : Program := mainOnly do
  let loc ← newLocal overflowTy
  storageLive loc
  let test (op : BinOp) (l r : Int) (res : Int) (ov : Bool) : FnB Unit := do
    assignL loc (.binaryOp op (ci32 l) (ci32 r))
    assumeEq (copy ((place loc).field 0 i32)) (ci32 res)
    assumeEq (copy ((place loc).field 1 bool)) (cbool ov)
  test .addWithOverflow 21 21 42 false
  test .addWithOverflow (-2147483648) 2147483647 (-1) false
  test .addWithOverflow 2147483647 1 (-2147483648) true
  test .addWithOverflow (-2147483648) (-1) 2147483647 true
  test .subWithOverflow (-1) 2147483647 (-2147483648) false
  test .subWithOverflow (-2147483648) 1 2147483647 true
  test .subWithOverflow 0 (-2147483648) (-2147483648) true
  test .mulWithOverflow 6 7 42 false
  test .mulWithOverflow (-2147483648) (-1) (-2147483648) true
  test .mulWithOverflow 65536 65536 0 true
  ret

def intrinsicsWork : Program := program do
  let exactDiv ← addIntrinsic "exact_div"
  let rotl ← addIntrinsic "rotate_left"
  let ctlz ← addIntrinsic "ctlz"
  let cttz ← addIntrinsic "cttz"
  let bswap ← addIntrinsic "bswap"
  let bitrev ← addIntrinsic "bitreverse"
  let satAdd ← addIntrinsic "saturating_add"
  addFn "main" <| body unit [] do
    assumeEq (← callTmp exactDiv i32 [ci32 4, ci32 2]) (ci32 2)
    assumeEq (← callTmp exactDiv i32 [ci32 4, ci32 (-1)]) (ci32 (-4))
    assumeEq (← callTmp rotl u8 [cu8 0x81, cint u32 1]) (cu8 0x03)
    assumeEq (← callTmp ctlz u32 [cint u16 1]) (cint u32 15)
    assumeEq (← callTmp cttz u32 [cint u16 0]) (cint u32 16)
    assumeEq (← callTmp bswap u32 [cint u32 0x12345678]) (cint u32 0x78563412)
    assumeEq (← callTmp bitrev u8 [cu8 1]) (cu8 128)
    assumeEq (← callTmp satAdd i8 [cint i8 100, cint i8 100]) (cint i8 127)
    ret

def exactDivRemainder : Program := program do
  let exactDiv ← addIntrinsic "exact_div"
  addFn "main" <| body unit [] do
    let _ ← callTmp exactDiv i32 [ci32 4, ci32 3]
    ret

def ctlzNonzeroZero : Program := program do
  let f ← addIntrinsic "ctlz_nonzero"
  addFn "main" <| body unit [] do
    let _ ← callTmp f u32 [cu8 0]
    ret

def tests : List TestCase := [
  ⟨"int/arith_works", fun _ => expectReturn arithWorks⟩,
  ⟨"int/div_zero", fun _ => expectUb (ubProg .div i32 (ci32 1) (ci32 0)) "division by zero"⟩,
  ⟨"int/rem_zero", fun _ => expectUb (ubProg .rem i32 (ci32 1) (ci32 0)) "modulus of remainder is zero"⟩,
  ⟨"int/div_overflow", fun _ =>
    expectUb (ubProg .div i32 (ci32 (-2147483648)) (ci32 (-1))) "overflow in division"⟩,
  ⟨"int/rem_overflow", fun _ =>
    expectUb (ubProg .rem i32 (ci32 (-2147483648)) (ci32 (-1))) "overflow in remainder"⟩,
  ⟨"int/bit_ops", fun _ => expectReturn bitOps⟩,
  ⟨"int/count_ones", fun _ => expectReturn countOnes⟩,
  ⟨"int/shl_shr_works", fun _ => expectReturn shlShrWorks⟩,
  ⟨"int/unchecked_works", fun _ => expectReturn uncheckedWorks⟩,
  ⟨"int/unchecked_add_ub", fun _ =>
    expectUb (ubProg .addUnchecked i8 (cint i8 127) (cint i8 1)) "overflow in unchecked add"⟩,
  ⟨"int/unchecked_add_ub2", fun _ =>
    expectUb (ubProg .addUnchecked i8 (cint i8 (-128)) (cint i8 (-1))) "overflow in unchecked add"⟩,
  ⟨"int/unchecked_sub_ub", fun _ =>
    expectUb (ubProg .subUnchecked i8 (cint i8 0) (cint i8 (-128))) "overflow in unchecked sub"⟩,
  ⟨"int/unchecked_mul_ub", fun _ =>
    expectUb (ubProg .mulUnchecked i8 (cint i8 56) (cint i8 3)) "overflow in unchecked mul"⟩,
  ⟨"int/unchecked_shl_ub", fun _ =>
    expectUb (ubProg .shlUnchecked u8 (cu8 1) (ci32 8)) "overflow in unchecked shift"⟩,
  ⟨"int/unchecked_shl_ub_neg", fun _ =>
    expectUb (ubProg .shlUnchecked u8 (cu8 1) (ci32 (-1))) "overflow in unchecked shift"⟩,
  ⟨"int/unchecked_shr_ub", fun _ =>
    expectUb (ubProg .shrUnchecked u8 (cu8 2) (ci32 9)) "overflow in unchecked shift"⟩,
  ⟨"int/cmp_works", fun _ => expectReturn cmpWorks⟩,
  ⟨"int/overflow_works", fun _ => expectReturn overflowWorks⟩,
  ⟨"int/intrinsics_work", fun _ => expectReturn intrinsicsWork⟩,
  ⟨"int/div_exact_remainder", fun _ =>
    expectUb exactDivRemainder "non-zero remainder in exact division"⟩,
  ⟨"int/ctlz_nonzero_zero", fun _ => expectUb ctlzNonzeroZero "`ctlz_nonzero` called on 0"⟩,
  ⟨"int/bit_and_requires_int", fun _ =>
    expectIllFormed (ubProg .bitAnd i32 (.const .zeroSized (array u8 0)) (.const .zeroSized (array u8 0)))⟩
]

end RyoTest.Int
