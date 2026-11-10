/-
Ryo.Check.Lower.CmpX — comparisons of thin pointers and of `char`s between whole locals
(aot.md §C1, M5b), and their checker.

What the backend emits (`backend/src/lower/binop.rs` `compare`): a thin pointer or a `char` is
not a float and not a wide pointer, so `scalar_kind` makes it an unsigned integer of its size (8
or 4 bytes; `is_signed` is false), and the comparison is `Cmp.lean`'s register form: one `cmp`
handler at that width, `gt`/`ge` with the operands swapped.

L0 (`evalBinOp`): pointers compare by `comparePtr`, the address and then the metadata, which
for thin pointers is none on both sides, so the address order; `char`s by `compare` of their
code points. A thin pointer's address and a `char`'s code point are the bits of its bytes
(`decodePtr`, `Ty.decode`), so both are the unsigned comparison of the bit patterns
(`Ryo/Proofs/Lower/SimCmpX.lean`).

Rule (`LowerCmpX.uReg`): `_d = op(_a, _b)`, `op` a comparison, `_a : ta`, `_b : tb` both thin
pointers (any pointee) or both `char` (`cmpUKind ta tb = some n`), `_d : bool`, the slots of
sizes 1, `n`, `n`, one `cmp` instruction (`cmpInsnOk`, unsigned) on `cmpRegForm`'s operands.
`_d` may be private or escaped.

`checkCmpX` claims a comparison of two whole locals of these types and is `none` otherwise; it
must run before `checkCmp`, which reports them as `cmp: operand type`.
-/
import Ryo.Check.Lower.Cmp

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- Two comparison operand types R compares as unsigned integers of `n` bytes: both thin
pointers (8) or both `char` (4). -/
def cmpUKind : Ty → Ty → Option Nat
  | .ptr pa _, .ptr pb _ => if pa.metaKind = .none ∧ pb.metaKind = .none then some 8 else none
  | .char, .char => some 4
  | _, _ => none

theorem cmpUKind_spec {ta tb : Ty} {n : Nat} (h : cmpUKind ta tb = some n) :
    (∃ pa va pb vb, ta = .ptr pa va ∧ tb = .ptr pb vb ∧ pa.metaKind = .none ∧
      pb.metaKind = .none ∧ n = 8) ∨ (ta = .char ∧ tb = .char ∧ n = 4) := by
  unfold cmpUKind at h
  split at h
  next pa va pb vb =>
    split at h
    next hc => exact .inl ⟨pa, va, pb, vb, rfl, rfl, hc.1, hc.2, (Option.some.inj h).symm⟩
    next => cases h
  next => exact .inr ⟨rfl, rfl, (Option.some.inj h).symm⟩
  next => cases h

/-- `cmpInsnOk` on the register form's operands (swapped when `sw`). A definition, so that
`split` in the checkers' proofs doesn't take the `if`s apart. -/
def cmpSwOk (Γ : StmtCtx) (i : Insn) (o : String) (n : Nat) (sg sw : Bool) (d a b : Int) :
    Bool :=
  cmpInsnOk Γ i o n sg d (if sw then b else a) (if sw then a else b)

inductive LowerCmpX (Γ : StmtCtx) : Statement → List Insn → Prop where
  | uReg {d a b : Local} {oa ob : Operand} {op : BinOp} {o : String} {sw : Bool}
      {ta tb : Ty} {n : Nat} {sd sa sb : LocalSlot} {i : Insn}
      (hf : cmpRegForm op = some (o, sw)) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some ta)
      (htb : Γ.body.locals[b]? = some tb) (hk : cmpUKind ta tb = some n)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = 1 ∧ sa.size = n ∧ sb.size = n)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk sb.off)
      (hi : cmpInsnOk Γ i o n false sd.off (if sw then sb.off else sa.off)
        (if sw then sa.off else sb.off) = true) :
      LowerCmpX Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]

/-- `uReg`'s checker. -/
def checkCmpU (Γ : StmtCtx) (d a b : Local) (o : String) (sw : Bool) (n : Nat) (is : List Insn) :
    Verdict :=
  match Γ.body.locals[d]?, Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
  | some .bool, some sd, some sa, some sb, [i] =>
    if !(sd.size == 1 && sa.size == n && sb.size == n) then .rejected "cmp ptr/char: slot sizes"
    else if !(offOk sd.off && offOk sa.off && offOk sb.off) then
      .rejected "cmp ptr/char: offsets"
    else if cmpSwOk Γ i o n false sw sd.off sa.off sb.off then .ok
    else .unsupported "cmp ptr/char: instruction form"
  | _, _, _, _, _ => .unsupported "cmp ptr/char: destination, slots or instruction count"

/-- The family's checker: `none` unless `st` compares two whole locals that are both thin
pointers or both `char`s. -/
def checkCmpX (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    match cmpRegForm op, oa.local?, ob.local? with
    | some (o, sw), some a, some b =>
      match Γ.body.locals[a]?, Γ.body.locals[b]? with
      | some ta, some tb =>
        match cmpUKind ta tb with
        | some n => some (checkCmpU Γ d a b o sw n is)
        | none => none
      | _, _ => none
    | _, _, _ => none
  | _ => none

theorem checkCmpU_sound {Γ : StmtCtx} {d a b : Local} {oa ob : Operand} {op : BinOp}
    {o : String} {sw : Bool} {ta tb : Ty} {n : Nat} {is : List Insn}
    (hf : cmpRegForm op = some (o, sw)) (ha : oa.local? = some a) (hb : ob.local? = some b)
    (hta : Γ.body.locals[a]? = some ta) (htb : Γ.body.locals[b]? = some tb)
    (hk : cmpUKind ta tb = some n) (h : checkCmpU Γ d a b o sw n is = .ok) :
    LowerCmpX Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) is := by
  unfold checkCmpU at h
  split at h
  next sd sa sb i htd hsd hsa hsb =>
    split at h
    · cases h
    next hsz =>
      split at h
      · cases h
      next hoff =>
        split at h
        next hi =>
          exact .uReg hf ha hb htd hta htb hk hsd hsa hsb (by simpa [and_assoc] using hsz)
            (by simpa [and_assoc] using hoff) hi
        · cases h
  · cases h

theorem checkCmpX_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkCmpX Γ st is = some .ok) : LowerCmpX Γ st is := by
  unfold checkCmpX at h
  split at h
  next d op oa ob =>
    split at h
    next o sw a b hf ha hb =>
      split at h
      next ta tb hta htb =>
        split at h
        next n hk => exact checkCmpU_sound hf ha hb hta htb hk (Option.some.inj h)
        · cases h
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
