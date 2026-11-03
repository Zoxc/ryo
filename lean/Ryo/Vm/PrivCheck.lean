/-
Ryo.Vm.PrivCheck — a Lean-only check of frame privacy that `Frame.decodeChecked` runs
(`privCheck`): which frame bytes the scopes may make escaped.

R's frame objects escape only through `Escape` scopes (`R.escape`), each the range of one
scope; nothing else adds an escaped object (`FrameInv.esc`, `Ryo.Proofs.Discharge.EscFrom`).
So a byte that no `Escape` scope's range covers is private at every boundary, and a byte that no
`Escape` scope at or before instruction `k` covers is private in the straight run of leading
`arg`s up to `k` (no branch targets a leading `arg`, `argsLeadCheck`). The check accepts if

- no `Escape` or `Lend` scope's range overlaps the frame's link slots `[0, 16)` (`linkPrivOk`;
  gives `Hyps.linkPrivate`), and
- for every `arg d, w` at `k`, no `Escape` scope overlaps its destination `[d, d + size)`:
  for a leading `arg` (every instruction up to `k` an `arg`), no such scope at or before `k`;
  for any other, none at all (`argPrivOk`; gives `Hyps.argPrivate`).
-/
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.Vm.R Ryo.Vm.Asm

/-- `[a, a + n)` and `[b, b + m)` overlap. -/
def rangesMeet (a : Int) (n : Nat) (b : Int) (m : Nat) : Bool :=
  decide (a < b + m ∧ b < a + n)

/-- An `Escape` scope. -/
def R.Scope.isEscape (sc : R.Scope) : Bool :=
  match sc.kind with
  | .escape _ => true
  | _ => false

/-- An `arg d, w`'s destination `(d, size)`. -/
def R.Insn.argDest : R.Insn → Option (Int × Nat)
  | .native op [.slot d, .imm w] =>
    match op.full with
    | some f => if f.info.shape == .arg then
        (ArgReg.of? w.toNat true).map fun a => (d.toInt, a.size) else none
    | none => none
  | _ => none

/-- Every instruction up to `k` is an `arg`. -/
def R.Decoded.leadUpTo (d : R.Decoded) (k : Nat) : Bool :=
  (List.range (k + 1)).all fun j => ((d.insns[j]?.bind R.Insn.argDest).isSome)

/-- No `Escape` or `Lend` scope overlaps the link slots `[0, 16)`. -/
def linkPrivOk (d : R.Decoded) : Bool :=
  d.scopes.toList.all fun p => p.2.kind == .end || !rangesMeet p.2.frameOffset.toInt p.2.size 0 16

/-- No `Escape` scope that may have run before an `arg` overlaps its destination. -/
def argPrivOk (d : R.Decoded) : Bool :=
  (List.range d.insns.size).all fun k =>
    match d.insns[k]?.bind R.Insn.argDest with
    | none => true
    | some (o, n) =>
      let lead := d.leadUpTo k
      d.scopes.toList.all fun p =>
        !p.2.isEscape || (lead && decide (k < p.1)) || !rangesMeet p.2.frameOffset.toInt p.2.size o n

/-- The privacy check (see the module comment). -/
def privCheck (d : R.Decoded) : Bool :=
  linkPrivOk d && argPrivOk d

end Ryo.Vm
