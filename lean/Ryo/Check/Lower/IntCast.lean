/-
Ryo.Check.Lower.IntCast — the integer-cast statement rules of the lowering (aot.md §C1, M5b)
and their checker.

`_d = cast intToInt (_a) (int t' _)`, `_a` a whole local (`copy`/`move`) of an int-like type
(`castSrc`: an integer type `t`, `bool` as `u8`, `char` as `u32`, the types L0's `intLike`
reads as integers; the backend's `scalar_kind` gives them the same width and signedness), `_d`
a whole local (private or escaped) of the integer type `t'` (any valid range: L0 stores
`t'.bringInBounds i` with `typedStore`, which only checks it is representable). A `char`
destination (UB-checked in L0) is not a rule. The lowering (`backend/src/lower/cast.rs`,
`int_cast`):

- `castMov`: same width (`ts.size = t'.size`), one `mov` of that width from `_a`'s slot to
  `_d`'s (`movInsnOk`): the bit pattern is unchanged.
- `castExt`: different widths, one handler from `int_cast_op(from, to, signed)` (`zext`,
  `sext` or `trunc`; handler kind `cvt` with the source and destination types), operands
  `[d, s]` (`castInsnOk`). The handler's source signedness must be the source type's, except
  when narrowing (`trunc`'s source type is unsigned whatever the source's; a truncation does
  not depend on it).

As in `Stmt.lean`, each rule carries the slot sizes, offsets in the 32-bit range and `_d`'s
static privacy; `checkIntCast` decides the relation (`checkIntCast_sound`), `none` for any
statement that is not an `IntToInt` cast into a whole local.
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The integer type an `IntToInt` cast reads its source at (L0's `intLike`): an integer type
itself, `bool` as `u8`, `char` as `u32`. -/
def castSrc : Ty → Option IntType
  | .int t _ => some t
  | .bool => some .u8
  | .char => some .u32
  | _ => none

/-- An instruction whose view is a `cvt` handler from an integer type of `n` bytes to one of
`n'` bytes, on slots `d, s`, falling through; the handler's source signedness is `sg` unless it
narrows. -/
def castInsnOk (Γ : StmtCtx) (i : Insn) (n : Nat) (sg : Bool) (n' : Nat) (d s : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [tx, ty], _⟩ =>
      match OpSem.Ty.parse tx, OpSem.Ty.parse ty with
      | some (.int nx sx), some (.int ny _sy) =>
        kd == .cvt && nx == n && ny == n' && (sx == sg || decide (n' ≤ n)) &&
          v.op.info.operands == [⟨"d", .slot⟩, ⟨"s", .slot⟩] &&
          v.ops == [.slot d, .slot s] && v.ctl == some .next
      | _, _ => false
    | _ => false
  | none => false

inductive LowerIntCast (Γ : StmtCtx) : Statement → List Insn → Prop where
  | castMov {d a : Local} {oa : Operand} {ta : Ty} {ts t' : IntType} {vd vc : ValidRange}
      {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.int t' vd)) (hta : Γ.body.locals[a]? = some ta)
      (hts : castSrc ta = some ts) (hw : ts.size = t'.size)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t'.size ∧ sa.size = ts.size)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : movInsnOk Γ i t'.size sd.off sa.off = true) :
      LowerIntCast Γ (.assign ⟨d, []⟩ (.cast .intToInt oa (.int t' vc))) [i]
  | castExt {d a : Local} {oa : Operand} {ta : Ty} {ts t' : IntType} {vd vc : ValidRange}
      {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.int t' vd)) (hta : Γ.body.locals[a]? = some ta)
      (hts : castSrc ta = some ts)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t'.size ∧ sa.size = ts.size)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : castInsnOk Γ i ts.size ts.signed t'.size sd.off sa.off = true) :
      LowerIntCast Γ (.assign ⟨d, []⟩ (.cast .intToInt oa (.int t' vc))) [i]

/-- The checker of `_d = cast intToInt oa (int t' _)`. -/
def checkIntCastAt (Γ : StmtCtx) (d : Local) (oa : Operand) (t' : IntType) (is : List Insn) :
    Verdict :=
  match oa.local? with
  | some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]? with
    | some (.int td _), some ta =>
      if td != t' then .unsupported "int cast: destination type differs from the cast's"
      else match castSrc ta with
        | some ts =>
          match Γ.slots[d]?, Γ.slots[a]?, is with
          | some sd, some sa, [i] =>
            if !(sd.size == t'.size && sa.size == ts.size) then .rejected "int cast: slot sizes"
            else if !(offOk sd.off && offOk sa.off) then .rejected "int cast: offsets"
            else if ts.size == t'.size then
              if movInsnOk Γ i t'.size sd.off sa.off then .ok
              else .unsupported "int cast: same-width instruction form"
            else if castInsnOk Γ i ts.size ts.signed t'.size sd.off sa.off then .ok
            else .unsupported "int cast: extension instruction form"
          | _, _, _ => .unsupported "int cast: slots or instruction count"
        | none => .unsupported "int cast: source not int-like"
    | _, _ => .unsupported "int cast: destination not an integer local"
  | none => .unsupported "int cast: operand not a whole local"

/-- The family's checker: `none` unless `st` is an `IntToInt` cast into a whole local. -/
def checkIntCast (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.cast .intToInt oa (.int t' _)) => some (checkIntCastAt Γ d oa t' is)
  | .assign ⟨_, []⟩ (.cast .intToInt _ _) =>
    some (.unsupported "int cast: destination type not an integer")
  | _ => none

theorem checkIntCastAt_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {t' : IntType}
    {vc : ValidRange} {is : List Insn} (h : checkIntCastAt Γ d oa t' is = .ok) :
    LowerIntCast Γ (.assign ⟨d, []⟩ (.cast .intToInt oa (.int t' vc))) is := by
  unfold checkIntCastAt at h
  split at h
  next a ha =>
    split at h
    next td vd ta htd hta =>
      split at h
      · cases h
      next hty =>
        have hty : td = t' := by simpa using hty
        subst hty
        split at h
        next ts hts =>
          split at h
          next sd sa i hsd hsa =>
            split at h
            · cases h
            next hsz =>
              split at h
              · cases h
              next hoff =>
                split at h
                next hsame =>
                  split at h
                  next hi =>
                    exact .castMov ha htd hta hts (by simpa using hsame) hsd hsa
                      (by simpa using hsz) (by simpa using hoff) hi
                  · cases h
                next =>
                  split at h
                  next hi =>
                    exact .castExt ha htd hta hts hsd hsa (by simpa using hsz)
                      (by simpa using hoff) hi
                  · cases h
          · cases h
        · cases h
    · cases h
  · cases h

theorem checkIntCast_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkIntCast Γ st is = some .ok) : LowerIntCast Γ st is := by
  unfold checkIntCast at h
  split at h
  · exact checkIntCastAt_sound (Option.some.inj h)
  all_goals first
    | (cases h; done)
    | (simp at h; done)

end Ryo.Check.Lower
