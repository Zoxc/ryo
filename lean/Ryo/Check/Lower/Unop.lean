/-
Ryo.Check.Lower.Unop — the statement rules for unary operators (aot.md §C1, M5b) and their
checker.

Rules (`LowerUnop`), each on whole locals (`copy`/`move` of a local without projections) of one
type, the destination private or escaped (`Ryo.Proofs.Lower.FnRel.dstWriteAll`):
- `intUn`: `_d = not(_a)` or `_d = neg(_a)` at an integer type `t`, lowered to one `un`
  handler-kind instruction (method `not` or `wrapping_neg`, `t`'s width, either signedness) on
  the two locals' slots, the slots of `t`'s size. L0's `not` and `neg` on integers wrap
  (`bringInBounds`); MIR's `Neg` is unchecked (an overflow check is a separate `Assert`).
- `notBool`: `_d = not(_a)` at `bool`, lowered to one `bin_imm`/`binop_imm` instruction with
  method `^` at 1 byte on the two slots and an immediate whose low byte is 1 (the backend's
  `xor.imm.w8 d, s, 1`); the slots of 1 byte.

Not covered: `ptrMetadata` (of a thin pointer it lowers to nothing, of a wide one to a `mov` of
the metadata half, a projected read), float `neg`.

`checkUnop` decides the rules: `none` for statements that are not a unary operator assigned to a
whole local, so a dispatcher can try families in turn (`checkUnop_sound`).
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The R method of an L0 unary operator the lowering maps to an `un` handler on integers. -/
def unMethod : UnOp → Option String
  | .not => some "not"
  | .neg => some "wrapping_neg"
  | .ptrMetadata => none

/-- An instruction whose view is an `un` handler with method `m` at `n` bytes, on slots `d, a`,
falling through. -/
def unInsnOk (Γ : StmtCtx) (i : Insn) (m : String) (n : Nat) (d a : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, m'], _⟩ =>
      kd == .un && m' == m && intTyOk ty n &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"a", .slot⟩] &&
        v.ops == [.slot d, .slot a] && v.ctl == some .next
    | _ => false
  | none => false

inductive LowerUnop (Γ : StmtCtx) : Statement → List Insn → Prop where
  | intUn {d a : Local} {oa : Operand} {op : UnOp} {m : String} {t : IntType}
      {valid : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hm : unMethod op = some m) (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.int t valid))
      (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = t.size)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : unInsnOk Γ i m t.size sd.off sa.off = true) :
      LowerUnop Γ (.assign ⟨d, []⟩ (.unaryOp op oa)) [i]
  | notBool {d a : Local} {oa : Operand} {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some .bool)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 1 ∧ sa.size = 1)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : binImmInsnOk Γ i "^" 1 sd.off sa.off 1 = true) :
      LowerUnop Γ (.assign ⟨d, []⟩ (.unaryOp .not oa)) [i]

/-- One instruction on the slots of `_d` and `_a`, both of `n` bytes (`_d` private or escaped), the
instruction accepted by `insnOk` (given the two slots). `what` names the rule in the reasons. -/
def checkSlots2 (Γ : StmtCtx) (what : String) (d a : Local) (n : Nat)
    (insnOk : LocalSlot → LocalSlot → Insn → Bool) (is : List Insn) : Verdict :=
  match Γ.slots[d]?, Γ.slots[a]?, is with
  | some sd, some sa, [i] =>
    if !(sd.size == n && sa.size == n) then .rejected (what ++ ": slot sizes")
    else if !(offOk sd.off && offOk sa.off) then .rejected (what ++ ": offsets")
    else if insnOk sd sa i then .ok
    else .unsupported (what ++ ": instruction form")
  | _, _, _ => .unsupported (what ++ ": slots or instruction count")

theorem checkSlots2_ok {Γ : StmtCtx} {what : String} {d a : Local} {n : Nat}
    {insnOk : LocalSlot → LocalSlot → Insn → Bool} {is : List Insn}
    (h : checkSlots2 Γ what d a n insnOk is = .ok) :
    ∃ sd sa i, is = [i] ∧ Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧
      (sd.size = n ∧ sa.size = n) ∧ (offOk sd.off ∧ offOk sa.off) ∧ insnOk sd sa i = true := by
  unfold checkSlots2 at h
  split at h
  next sd sa i hsd hsa =>
    split at h
    · cases h
    next hsz =>
      split at h
      · cases h
      next hoff =>
        split at h
        next hi =>
          exact ⟨sd, sa, i, rfl, hsd, hsa, by simpa using hsz, by simpa using hoff, hi⟩
        · cases h
  · cases h

/-- The reason for a unary operator on locals of other types. -/
def unopOtherWhy : UnOp → String
  | .ptrMetadata => "unop: ptr metadata"
  | _ => "unop: not integers or bools"

/-- `_d = op(oa)`'s checker. -/
def checkUnopAt (Γ : StmtCtx) (d : Local) (op : UnOp) (oa : Operand) (is : List Insn) :
    Verdict :=
  match oa.local? with
  | some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]? with
    | some .bool, some .bool =>
      if op = .not then
        checkSlots2 Γ "not bool" d a 1 (fun sd sa i => binImmInsnOk Γ i "^" 1 sd.off sa.off 1) is
      else .unsupported "unop: neg on bool"
    | some (.int t valid), some ta =>
      match unMethod op with
      | some m =>
        if ta != Ty.int t valid then .unsupported "unop: mixed types"
        else checkSlots2 Γ "unop" d a t.size
          (fun sd sa i => unInsnOk Γ i m t.size sd.off sa.off) is
      | none => .unsupported "unop: ptr metadata"
    | _, _ => .unsupported (unopOtherWhy op)
  | none => .unsupported "unop: operand not a whole local"

theorem checkUnopAt_sound {Γ : StmtCtx} {d : Local} {op : UnOp} {oa : Operand}
    {is : List Insn} (h : checkUnopAt Γ d op oa is = .ok) :
    LowerUnop Γ (.assign ⟨d, []⟩ (.unaryOp op oa)) is := by
  unfold checkUnopAt at h
  split at h
  next a ha =>
    split at h
    next htd hta =>
      split at h
      next hop =>
        subst hop
        obtain ⟨sd, sa, i, rfl, hsd, hsa, hsz, hoff, hi⟩ := checkSlots2_ok h
        exact .notBool ha htd hta hsd hsa hsz hoff hi
      · cases h
    next t valid ta htd hta =>
      split at h
      next m hm =>
        split at h
        · cases h
        next hty =>
          have hty : ta = .int t valid := by simpa using hty
          subst hty
          obtain ⟨sd, sa, i, rfl, hsd, hsa, hsz, hoff, hi⟩ := checkSlots2_ok h
          exact .intUn hm ha htd hta hsd hsa hsz hoff hi
      · cases h
    · cases h
  · cases h

/-- Decide `LowerUnop`: `none` if `st` is not a unary operator assigned to a whole local. -/
def checkUnop (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.unaryOp op oa) => some (checkUnopAt Γ d op oa is)
  | _ => none

theorem checkUnop_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkUnop Γ st is = some .ok) : LowerUnop Γ st is := by
  unfold checkUnop at h
  split at h
  next d op oa => exact checkUnopAt_sound (Option.some.inj h)
  · cases h

end Ryo.Check.Lower
