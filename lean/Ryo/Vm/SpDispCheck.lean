/-
Ryo.Vm.SpDispCheck — a Lean-only check that, without a frame pointer, no frame operand's
displacement wraps (`spDispCheck`, run by `Frame.decodeChecked`).

Without a frame pointer the decoder reads a frame slot `[rsp + e]` as `[rbp + (e - F)]`
(`Cursor.fromSpFrame`, `F` the frame size). The proofs run the item on a virtual state with
`rbp = rsp + F`, which needs `e - F + F` and `e` to be the same signed 32-bit displacement
(`Item.SpDispOk`). The decoder doesn't check it. The check runs the two candidate parsers that
`fromSpFrame` applies to (`sseCandidate`, `nativeCandidate`; a base item has no memory operand)
at every position of the code, so it covers every item any decode of the code can return
(`Ryo.Proofs.Discharge.SpDisp` turns its success into `Hyps.spDisp`). The candidates read the
code and the position only, so the check's cursor stands for any.
-/
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.X86 Ryo.Vm.R Ryo.Vm.Asm

/-- The item's frame operand `[rbp + d]` (if any) doesn't wrap as `[rsp + d + F]`
(`Item.SpDispOk`). -/
def spDispItemOk (F : BitVec 32) (i : Item) : Bool :=
  match i.mem? with
  | some m => m.base != .rbp || decide ((m.disp + F).toInt = m.disp.toInt + F.toNat)
  | none => true

/-- The cursor the check reads position `p` with (frame slots off `rsp`, `F` the frame size). -/
def spDispCursor (code : Array UInt8) (F : BitVec 32) (p : Nat) : Cursor :=
  { code, pos := p, fields := .relocs #[], spFrame := some F }

/-- A candidate, mapped by `fromSpFrame`, is `spDispItemOk`. -/
def spDispAt (c : Cursor) (F : BitVec 32) (k : Option Item) : Bool :=
  match k.bind c.fromSpFrame with
  | some j => spDispItemOk F j
  | none => true

/-- At every position, the SSE and native candidates are `spDispItemOk`. -/
def spDispScan (code : Array UInt8) (F : BitVec 32) : Bool :=
  (List.range code.size).all fun p =>
    spDispAt (spDispCursor code F p) F (spDispCursor code F p).sseCandidate &&
      spDispAt (spDispCursor code F p) F (spDispCursor code F p).nativeCandidate

/-- With a frame pointer nothing to check; without, `spDispScan` with the decoded frame size. -/
def spDispCheck (code : Array UInt8) (d : R.Decoded) (mode : Mode) : Bool :=
  mode.framePointer || spDispScan code (BitVec.ofNat 32 d.frameSize)

end Ryo.Vm
