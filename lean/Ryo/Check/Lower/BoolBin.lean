/-
Ryo.Check.Lower.BoolBin — `&`, `|` and `^` on `bool`s (aot.md §C1, M5b), and their checker.

What the backend emits (`backend/src/lower/binop.rs` `arith`): a `bool` is an unsigned byte to
`scalar_kind`, so `_d = _a & _b` is one `and.w8 d, a, b` (`|`, `^` likewise), and with a constant
right operand one `and.imm.w8 d, a, imm` (the `.imm` form). L0 (`evalBinOp`'s `bool` case):
`a && b`, `a || b`, `a != b`; on the bytes 0 and 1 the bitwise operators compute exactly these,
so R's result byte is L0's stored one (`Ryo/Proofs/Lower/SimBoolBin.lean`).

Rules (`op` with `binMethod op = some m` among `&`, `|`, `^`; `_d`, `_a` and `_b` of type
`bool` with 1-byte slots; `_d` private or escaped):
- `reg`: `_d = op(_a, _b)`, one `bin`/`binop` instruction (`binInsnOk`, 1 byte);
- `imm`: `_d = op(_a, const bits : bool)`, one `bin_imm`/`binop_imm` instruction
  (`binImmInsnOk`, the immediate's low byte `bits`'s).

`checkBoolBin` claims these operators on a `bool` left local (and a `bool` right local or
constant) and is `none` otherwise.
-/
import Ryo.Check.Lower.Cmp

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The bitwise operators on `bool`. -/
def boolBinOp : BinOp → Bool
  | .bitAnd | .bitOr | .bitXor => true
  | _ => false

inductive LowerBoolBin (Γ : StmtCtx) : Statement → List Insn → Prop where
  | reg {d a b : Local} {oa ob : Operand} {op : BinOp} {m : String} {sd sa sb : LocalSlot}
      {i : Insn}
      (hop : boolBinOp op = true) (hm : binMethod op = some m)
      (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some .bool)
      (htb : Γ.body.locals[b]? = some .bool)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = 1 ∧ sa.size = 1 ∧ sb.size = 1)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk sb.off)
      (hi : binInsnOk Γ i m 1 sd.off sa.off sb.off = true) :
      LowerBoolBin Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]
  | imm {d a : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {sd sa : LocalSlot}
      {i : Insn}
      (hop : boolBinOp op = true) (hm : binMethod op = some m) (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some .bool)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 1 ∧ sa.size = 1) (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : binImmInsnOk Γ i m 1 sd.off sa.off bits = true) :
      LowerBoolBin Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) .bool))) [i]

/-- `reg`'s checker. -/
def checkBoolBinReg (Γ : StmtCtx) (d a b : Local) (m : String) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]?, Γ.body.locals[b]?, Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
  | some .bool, some .bool, some sd, some sa, some sb, [i] =>
    if !(sd.size == 1 && sa.size == 1 && sb.size == 1) then .rejected "bool binop: slot sizes"
    else if !(offOk sd.off && offOk sa.off && offOk sb.off) then .rejected "bool binop: offsets"
    else if binInsnOk Γ i m 1 sd.off sa.off sb.off then .ok
    else .unsupported "bool binop: instruction form"
  | _, _, _, _, _, _ => .unsupported "bool binop: types, slots or instruction count"

/-- `imm`'s checker. -/
def checkBoolBinImm (Γ : StmtCtx) (d a : Local) (m : String) (bits : Nat) (is : List Insn) :
    Verdict :=
  match Γ.body.locals[d]?, Γ.slots[d]?, Γ.slots[a]?, is with
  | some .bool, some sd, some sa, [i] =>
    if !(sd.size == 1 && sa.size == 1) then .rejected "bool binop imm: slot sizes"
    else if !(offOk sd.off && offOk sa.off) then .rejected "bool binop imm: offsets"
    else if binImmInsnOk Γ i m 1 sd.off sa.off bits then .ok
    else .unsupported "bool binop imm: instruction form"
  | _, _, _, _ => .unsupported "bool binop imm: destination, slots or instruction count"

/-- The family's checker: `none` unless `st` is `&`/`|`/`^` on a `bool` local. -/
def checkBoolBin (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) .bool)) =>
    match boolBinOp op, binMethod op, oa.local? with
    | true, some m, some a =>
      if Γ.body.locals[a]? = some .bool then some (checkBoolBinImm Γ d a m bits is) else none
    | _, _, _ => none
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    match boolBinOp op, binMethod op, oa.local?, ob.local? with
    | true, some m, some a, some b =>
      if Γ.body.locals[a]? = some .bool then some (checkBoolBinReg Γ d a b m is) else none
    | _, _, _, _ => none
  | _ => none

theorem checkBoolBinReg_sound {Γ : StmtCtx} {d a b : Local} {oa ob : Operand} {op : BinOp}
    {m : String} {is : List Insn} (hop : boolBinOp op = true) (hm : binMethod op = some m)
    (ha : oa.local? = some a) (hb : ob.local? = some b)
    (hta : Γ.body.locals[a]? = some .bool) (h : checkBoolBinReg Γ d a b m is = .ok) :
    LowerBoolBin Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) is := by
  unfold checkBoolBinReg at h
  split at h
  next sd sa sb i htd htb hsd hsa hsb =>
    split at h
    · cases h
    next hsz =>
      split at h
      · cases h
      next hoff =>
        split at h
        next hi =>
          exact .reg hop hm ha hb htd hta htb hsd hsa hsb (by simpa [and_assoc] using hsz)
            (by simpa [and_assoc] using hoff) hi
        · cases h
  · cases h

theorem checkBoolBinImm_sound {Γ : StmtCtx} {d a : Local} {oa : Operand} {op : BinOp}
    {m : String} {bits : Nat} {is : List Insn} (hop : boolBinOp op = true)
    (hm : binMethod op = some m) (ha : oa.local? = some a)
    (hta : Γ.body.locals[a]? = some .bool) (h : checkBoolBinImm Γ d a m bits is = .ok) :
    LowerBoolBin Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) .bool))) is := by
  unfold checkBoolBinImm at h
  split at h
  next sd sa i htd hsd hsa =>
    split at h
    · cases h
    next hsz =>
      split at h
      · cases h
      next hoff =>
        split at h
        next hi =>
          exact .imm hop hm ha htd hta hsd hsa (by simpa using hsz) (by simpa using hoff) hi
        · cases h
  · cases h

theorem checkBoolBin_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkBoolBin Γ st is = some .ok) : LowerBoolBin Γ st is := by
  unfold checkBoolBin at h
  split at h
  next d op oa bits =>
    split at h
    next m a hop hm ha =>
      split at h
      next hta => exact checkBoolBinImm_sound hop hm ha hta (Option.some.inj h)
      · cases h
    · cases h
  next d op oa ob =>
    split at h
    next m a b hop hm ha hb =>
      split at h
      next hta => exact checkBoolBinReg_sound hop hm ha hb hta (Option.some.inj h)
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
