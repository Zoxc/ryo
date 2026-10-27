/-
RyoTest.Inline — the link between `Asm.inlineOps` and the inline-sequence theorems
(`Ryo/Proofs/Inline.lean`): every opcode with an inline form has its class's shape
(`shapeOk`: handler kind and parameters, operands), so the theorems, stated for every opcode
of that shape, cover it. Proved as `inlineOps_shape` in the slow library `RyoProofs`
(`RyoProofs/InlineOps.lean`); this test checks it in the default `lake test`.

`later`: the sequences of the classes the theorems don't cover yet (`laterClass`: variable
shifts and rotates, `div`/`rem`, `cttz`/`ctlz`, `cmp3`, `bswap`) run by `Item.exec` on frame
slots with garbage above their width, against the handlers' Rust methods (`wrapping_shl`,
`rotate_left`, `unchecked_div`, `trailing_zeros`, `cmp`, `swap_bytes`, …) at every inline
width, for two values of the context's undefined-destination oracle (`Ctx.undef`).
-/
import RyoTest.Harness
import Ryo.Proofs.Inline.Shape
import Ryo.Proofs.Inline

namespace RyoTest.Inline

open Ryo.Vm Ryo.Proofs.Inline Ryo.X86

def shapes : Except String Unit := do
  let bad := Asm.inlineOps.filter fun (op, c) => !shapeOk op c
  if !bad.isEmpty then
    throw s!"opcodes not of their inline class's shape: {bad.map (·.1.mnemonic)}"
  if Asm.inlineOps.isEmpty then throw "no inline opcodes"

/-! ### The later classes' sequences, run -/

def fp : BitVec 64 := 0x7fff0100
def slotD : BitVec 32 := BitVec.ofInt 32 (-24)
def slotA : BitVec 32 := BitVec.ofInt 32 (-8)
def slotB : BitVec 32 := BitVec.ofInt 32 (-16)

/-- The low `k` bytes of `v`, then `0xa5`s up to 8 bytes. -/
def slotBytes (k v : Nat) : Nat := v % 2 ^ (8 * k) + (0xa5a5a5a5a5a5a5a5 / 2 ^ (8 * k)) * 2 ^ (8 * k)

/-- Runs `cls`'s sequence on `a` (and `b`), the result's `out` bytes at `d`. -/
def runSeq (undef : BitVec 64) (cls : Asm.Class) (n a b out : Nat) : Except String Nat := do
  let ops : List (R.Opnd Nat) := [.slot slotD, .slot slotA, .slot slotB]
  let some (items, _) := Asm.sequence cls ops | throw s!"{repr cls}: no sequence"
  let s0 : State := { (default : State) with regs := fun i => BitVec.ofNat 64 (0x0123456789abcdef * (i.val + 3)) }
  let s0 := (s0.setReg .rbp fp).setReg .rsp (fp - 0x100)
  let s0 := s0.setMem (fp + slotA.signExtend 64) 8 (slotBytes (n / 8) a)
  let s0 := s0.setMem (fp + slotB.signExtend 64) 8 (slotBytes (max (n / 8) 4) b)
  let s0 := s0.setMem (fp + slotD.signExtend 64) 8 0x5a5a5a5a5a5a5a5a
  let ctx : Ctx := { base := 0x1000, addrOf := fun _ => 0, undef }
  match execItems ctx items s0 with
  | .ok s => pure (s.mem.readNat (fp + slotD.signExtend 64) out)
  | .error f => throw s!"{repr cls} {a} {b}: fault {repr f}"

def toInt (n v : Nat) : Int := if v < 2 ^ (n - 1) then v else (v : Int) - 2 ^ n
def ofInt (n : Nat) (i : Int) : Nat := (i % (2 ^ n : Int)).toNat

/-- What the handler computes (its Rust method on `n`-bit values), and the bytes it stores;
`none` where it's UB (division by zero, `MIN / -1`). -/
def reference (cls : Asm.Class) (n a b : Nat) : Option (Nat × Nat) :=
  let bytes := n / 8
  let sh := b % n
  match cls with
  | .shiftVar .shl _ => some (a * 2 ^ sh % 2 ^ n, bytes)
  | .shiftVar .shr _ => some (a / 2 ^ sh, bytes)
  | .shiftVar .sar _ => some (ofInt n ((toInt n a).fdiv (2 ^ sh : Int)), bytes)
  | .shiftVar .rol _ => some ((a * 2 ^ sh + a / 2 ^ (n - sh)) % 2 ^ n, bytes)
  | .shiftVar .ror _ => some ((a / 2 ^ sh + a * 2 ^ (n - sh)) % 2 ^ n, bytes)
  | .div signed rem _ =>
    if b == 0 then none
    else if signed then
      let (x, y) := (toInt n a, toInt n b)
      if x == -(2 ^ (n - 1) : Int) && y == -1 then none
      else some (ofInt n (if rem then x.tmod y else x.tdiv y), bytes)
    else some (if rem then a % b else a / b, bytes)
  | .count lz _ =>
    let bits := (List.range n).map fun i => a / 2 ^ i % 2 == 1
    let k := if lz then (bits.reverse.findIdx? id).getD n else (bits.findIdx? id).getD n
    some (k, 4)
  | .cmp3 signed _ =>
    let (x, y) : Int × Int := if signed then (toInt n a, toInt n b) else (a, b)
    some (if x < y then 0xff else if x == y then 0 else 1, 1)
  | .bswap _ =>
    some (((List.range bytes).map fun i => a / 2 ^ (8 * i) % 256).foldl (fun acc x => acc * 256 + x) 0, bytes)
  | _ => none

def samples (n : Nat) : List Nat :=
  [0, 1, 2, 3, 7, n - 1, n, n + 1, 2 * n + 3, 2 ^ (n - 1), 2 ^ (n - 1) + 1, 2 ^ n - 1, 2 ^ n - 2,
    0x5a5a5a5a5a5a5a5a % 2 ^ n, 0x0123456789abcdef % 2 ^ n, 2 ^ (n / 2)]

def later : Except String Unit := do
  let ops := Asm.inlineOps.filter (laterClass ·.2)
  if ops.length != 55 then throw s!"{ops.length} later inline opcodes, not 55"
  for (op, cls) in ops do
    let some n := Frame.widthOfMnemonic op.mnemonic |>.map (8 * ·) | throw s!"{op.mnemonic}: no width"
    for a in samples n do
      for b in samples n do
        let some (want, out) := reference cls n a b | continue
        for undef in [0, 0xdeadbeefcafef00d] do
          let got ← runSeq undef cls n a b out
          if got != want then throw s!"{op.mnemonic} {a} {b}: got {got}, want {want}"

def tests : List TestCase := [
  ⟨"Inline/shapes", fun _ => shapes⟩,
  ⟨"Inline/later classes' sequences run", fun _ => later⟩,
]

end RyoTest.Inline
