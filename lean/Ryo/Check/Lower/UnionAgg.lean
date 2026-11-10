/-
Ryo.Check.Lower.UnionAgg — union aggregates (aot.md §C1, M5b), and their checker.

What the backend emits (`backend/src/lower/adt.rs` `aggregate`, `Adt` with an active field):
`operand_into` of the one operand at the active field's offset of `_d`'s slot, i.e.
`Agg.lean`'s pieces of one field (`srcPieces`). The other bytes of the slot are left as they
are.

L0 (`evalRvalue`'s union case): the operand's value encoded at the field type, written at the
field's offset over the union's size of uninitialized bytes, decoded at the union type, and
stored (re-encoded) at it. The stored bytes are below the written ones (`encode_decode_le`, the
union type well-formed), whose uninitialized part refines whatever R holds there
(`Ryo/Proofs/Lower/SimUnionAgg.lean`).

Rule (`LowerUnionAgg.mk`): `_d = aggregate (adt _ (some f)) [op]`, `_d : .union ufields chunks
usize ual` well-formed with `usize` its slot's size, `ufields[f]? = some (off, fty)`, `op` a field
of `_d` at `(off, fty)` (`AggField`: a whole local, a scalar constant or a zero-sized operand),
the instructions its pieces; `_d` private or escaped (`SimUnionAggDst.lean`).

`checkUnionAgg` claims every union aggregate into a whole local and is `none` otherwise; it must
run before `checkAgg`, which reports them as `aggregate: union`.
-/
import Ryo.Check.Lower.Agg

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerUnionAgg (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {d : Local} {variant f : Nat} {op : Operand} {ufields : List (Nat × Ty)}
      {chunks : List (Nat × Nat)} {usize : Nat} {ual : Align} {off : Nat} {fty : Ty}
      {sd : LocalSlot} {src : AggSrc} {is : List Insn}
      (htd : Γ.body.locals[d]? = some (.union ufields chunks usize ual))
      (hwf : (Ty.union ufields chunks usize ual).wf = true)
      (hfld : ufields[f]? = some (off, fty)) (hsz : usize = sd.size)
      (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
      (hfa : AggField Γ sd op off fty src)
      (hi : piecesOk Γ is (srcPieces (sd.off + off) src) = true) :
      LowerUnionAgg Γ (.assign ⟨d, []⟩ (.aggregate (.adt variant (some f)) [op])) is

/-- `mk`'s checker. -/
def checkUnionAggOp (Γ : StmtCtx) (d : Local) (f : Nat) (op : Operand) (is : List Insn) :
    Verdict :=
  match Γ.body.locals[d]? with
  | some (.union ufields chunks usize ual) =>
    if !(Ty.union ufields chunks usize ual).wf then .rejected "union aggregate: ill-formed type"
    else match ufields[f]?, Γ.slots[d]? with
      | some (off, fty), some sd =>
        if usize ≠ sd.size then .rejected "union aggregate: slot size"
        else if !(offOk sd.off && offOk (sd.off + sd.size)) then .rejected "union aggregate: offsets"
        else match guessSrc Γ "union aggregate" (sd.off + off) op fty is with
          | .error why => .unsupported why
          | .ok g =>
            if !aggFieldOk Γ sd op off fty g.1 then .unsupported "union aggregate: operand"
            else if piecesOk Γ is (srcPieces (sd.off + off) g.1) then .ok
            else .unsupported "union aggregate: instruction form"
      | _, _ => .rejected "union aggregate: field or slot"
  | _ => .unsupported "union aggregate: destination type"

/-- The family's checker: `none` unless `st` is a union aggregate into a whole local. -/
def checkUnionAgg (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.aggregate (.adt _ (some f)) [op]) =>
    match Γ.body.locals[d]? with
    | some (.union ..) => some (checkUnionAggOp Γ d f op is)
    | _ => none
  | _ => none

theorem checkUnionAggOp_sound {Γ : StmtCtx} {d : Local} {variant f : Nat} {op : Operand}
    {is : List Insn} (h : checkUnionAggOp Γ d f op is = .ok) :
    LowerUnionAgg Γ (.assign ⟨d, []⟩ (.aggregate (.adt variant (some f)) [op])) is := by
  unfold checkUnionAggOp at h
  split at h
  next ufields chunks usize ual htd =>
    split at h
    · cases h
    next hwf =>
      split at h
      next off fty sd hfld hsd =>
        split at h
        · cases h
        next hsz =>
          split at h
          · cases h
          next hoff =>
            split at h
            · cases h
            next g =>
              split at h
              · cases h
              next hfa =>
                split at h
                next hi =>
                  exact .mk htd (by simpa using hwf) hfld (by simpa using hsz) hsd
                    (by simpa using hoff) (aggFieldOk_spec (by simpa using hfa)) hi
                · cases h
      · cases h
  · cases h

theorem checkUnionAgg_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkUnionAgg Γ st is = some .ok) : LowerUnionAgg Γ st is := by
  unfold checkUnionAgg at h
  split at h
  next d variant f op =>
    split at h
    next => exact checkUnionAggOp_sound (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
