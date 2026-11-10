/-
Ryo.Check.Lower.RefDeref — the lowering rule for taking an address through a thin pointer held
in a local (aot.md §C1, M5b's places): reborrows `_d = &(*_p)` and field addresses
`_d = &(*_p).f₁.….fₖ` / `&raw …`, and its checker.

What the backend emits (`backend/src/lower/rvalue.rs` `address_of`, `place.rs`
`deref`/`field`/`addr_into`): the place `(*_p).f₁.….fₖ`, `_p` a local holding a thin pointer, is
the memory operand `Loc::Mem { p: sp.off, k: off }` (`off` the sum of the field offsets), whose
address `addr_into` writes as `mov.w64 d, p` when `off = 0` and `ptr.add d, p, off` otherwise.
No `Escape`: the pointee is not a frame slot.

Rule (`LowerRefDeref.mk`): `_d = &(*_p).fields` or `&raw`, `_p`'s L0 type `.ptr pt valid` with
`pt.metaKind = .none` (8 bytes), the projections after the deref all fields `fieldPath` covers
from the deref's pointee type, `_d` a thin pointer local with an 8-byte slot, private or escaped
(its write is `FnRel.write_dst`'s), one instruction `refDerefInsnOk`: `mov` of 8 bytes from `_p`'s slot when `off = 0`,
else `ptr_add` from `_p`'s slot with the immediate `off` (an `i64` that reads back as `off`).
`_p` may be private or escaped. L0 loads `_p`, decodes the pointer `q`, offsets it in bounds by
`off` and stores the encoding of `⟨q.addr + off, q.prov⟩` (`&` checks its validity, which only
adds UB); R reads `_p`'s slot and writes the same address with the related provenance
(`Ryo.Proofs.Lower.lift_refDeref`). `_d = _p` is allowed (R reads before it writes).

`checkRefDeref` answers `none` for any other statement; it must run before `checkRef`, which
claims every `&`/`&raw` and reports places through a deref as unsupported.
-/
import Ryo.Check.Lower.Deref
import Ryo.Check.Lower.Ref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- An instruction whose view is a `ptr_add` handler from slot `p` to slot `d` by the immediate
`off` (whose `i64` reading is `off`), falling through. -/
def ptrAddInsnOk (Γ : StmtCtx) (i : Insn) (d p : Int) (off : Nat) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, _, _⟩ =>
      kd == .ptr_add && v.op.info.operands == [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"imm", .i64⟩] &&
        v.ops == [.slot d, .slot p, .imm off] && (BitVec.ofNat 64 off).toInt == (off : Int) &&
        v.ctl == some .next
    | none => false
  | none => false

theorem ptrAddInsnOk_spec {Γ : StmtCtx} {i : Insn} {d p : Int} {off : Nat}
    (h : ptrAddInsnOk Γ i d p off = true) :
    ∃ v ps r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.ptr_add, ps, r⟩ ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"imm", .i64⟩] ∧
      v.ops = [.slot d, .slot p, .imm off] ∧ (BitVec.ofNat 64 off).toInt = (off : Int) ∧
      v.ctl = some .next := by
  unfold ptrAddInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ps r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨hkd, ho⟩, hops⟩, hbv⟩, hctl⟩ := h
      subst hkd
      exact ⟨v, ps, r, hv, hh, ho, hops, hbv, hctl⟩
    · cases h
  · cases h

/-- The address of `[p + off]` into slot `d`: `mov.w64 d, p` at offset 0, else
`ptr_add d, p, off` (`addr_into`'s two memory forms). -/
def refDerefInsnOk (Γ : StmtCtx) (i : Insn) (d p : Int) (off : Nat) : Bool :=
  if off = 0 then movInsnOk Γ i 8 d p else ptrAddInsnOk Γ i d p off

inductive LowerRefDeref (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {d p : Local} {rv : Rvalue} {pointee ty : Ty} {fields : List ProjElem} {pt ptd : PtrType}
      {valid vd : ValidRange} {off : Nat} {sd sp : LocalSlot} {i : Insn}
      (hrv : refPlace? rv = some ⟨p, .deref pointee :: fields⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
      (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp)
      (hsize : sd.size = 8 ∧ sp.size = 8)
      (hoff : offOk sd.off ∧ offOk sp.off)
      (hi : refDerefInsnOk Γ i sd.off sp.off off = true) :
      LowerRefDeref Γ (.assign ⟨d, []⟩ rv) [i]

/-- `mk`'s checker for `_d = &(*_p).fields` / `&raw (*_p).fields`. -/
def checkRefDerefPlace (Γ : StmtCtx) (d p : Local) (pointee : Ty) (fields : List ProjElem)
    (is : List Insn) : Verdict :=
  match Γ.body.locals[p]? with
  | some (.ptr pt _) =>
    if pt.metaKind = .none then
      match fieldPath pointee fields with
      | none => .unsupported ("ref " ++ derefWhy fields)
      | some (off, _) =>
        match Γ.body.locals[d]? with
        | some (.ptr ptd _) =>
          if ptd.metaKind = .none then
            match Γ.slots[d]?, Γ.slots[p]?, is with
            | some sd, some sp, [i] =>
              if !(sd.size == 8 && sp.size == 8) then .rejected "ref deref: slot sizes"
              else if !(offOk sd.off && offOk sp.off) then .rejected "ref deref: offsets"
              else if refDerefInsnOk Γ i sd.off sp.off off then .ok
              else .unsupported "ref deref: instruction form"
            | _, _, _ => .unsupported "ref deref: slots or instruction count"
          else .unsupported "ref deref: wide destination"
        | _ => .unsupported "ref deref: destination not a pointer"
    else .unsupported "ref deref: wide pointer"
  | _ => .unsupported "ref deref: not a pointer local"

/-- The family's checker: `none` unless `st` is `_d = &(*_p)…` or `_d = &raw (*_p)…`. -/
def checkRefDeref (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ rv =>
    match refPlace? rv with
    | some ⟨p, .deref pointee :: fields⟩ => some (checkRefDerefPlace Γ d p pointee fields is)
    | _ => none
  | _ => none

theorem checkRefDerefPlace_sound {Γ : StmtCtx} {d p : Local} {rv : Rvalue} {pointee : Ty}
    {fields : List ProjElem} {is : List Insn}
    (hrv : refPlace? rv = some ⟨p, .deref pointee :: fields⟩)
    (h : checkRefDerefPlace Γ d p pointee fields is = .ok) :
    LowerRefDeref Γ (.assign ⟨d, []⟩ rv) is := by
  unfold checkRefDerefPlace at h
  split at h
  next pt valid htp =>
    split at h
    next hk =>
      split at h
      · cases h
      next off ty hpath =>
        split at h
        next ptd vd htd =>
          split at h
          next hkd =>
            split at h
            next sd sp i hsd hsp =>
              split at h
              · cases h
              next hsz =>
                split at h
                · cases h
                next hoff =>
                  split at h
                  next hi =>
                    exact .mk hrv htp hk hpath htd hkd hsd hsp (by simpa using hsz)
                      (by simpa using hoff) hi
                  · cases h
            · cases h
          · cases h
        · cases h
    · cases h
  · cases h

theorem checkRefDeref_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkRefDeref Γ st is = some .ok) : LowerRefDeref Γ st is := by
  unfold checkRefDeref at h
  split at h
  next d rv =>
    split at h
    next p pointee fields hp => exact checkRefDerefPlace_sound hp (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
