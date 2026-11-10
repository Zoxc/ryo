/-
Ryo.Check.Lower.Offset — the statement rule for pointer `Offset` (aot.md §C1, M5b) and its
checker.

Rule (`LowerOffset`), on whole locals (`copy`/`move` of a local), the destination's slot never
escaped in the function (the simulation is for private destinations, as `LowerStmt`'s):
- `offset`: `_d = Offset(_a, _b)`, `_a` and `_d` of one thin pointer type whose pointee is
  sized (`sz` bytes), `_b` an 8-byte integer (`usize`/`isize`), lowered to one `ptr_index`
  handler instruction `ptr.index d, a, b, sz` (`backend/src/lower/binop.rs`: the stride is the
  pointee's size), the slots of 8 bytes. R offsets the address by `b * sz` modulo `2 ^ 64`, keeping
  the provenance; L0 requires the exact result to stay in bounds, so the two agree.

Not covered: a constant index (materialized into a temporary: two instructions).

`checkOffset` decides the rule (`checkOffset_sound`): `none` for any statement that is not an
`Offset` assigned to a whole local.
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- An instruction whose view is a `ptr_index` handler on slots `d, a, b` with stride `sz`,
falling through. -/
def ptrIndexInsnOk (Γ : StmtCtx) (i : Insn) (d a b : Int) (sz : Nat) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, _, _⟩ =>
      kd == .ptr_index &&
        v.op.info.operands.map (·.name) == ["d", "p", "i", "stride"] &&
        (v.op.info.operands.take 3).map (·.kind) == [.slot, .slot, .slot] &&
        v.ops == [.slot d, .slot a, .slot b, .imm sz] && v.ctl == some .next
    | _ => false
  | none => false

/-- The size of a pointer type's sized pointee. -/
def pointeeSized? (pt : PtrType) : Option (Nat × Align × Bool) :=
  match pt.pointee? with
  | some ⟨.sized sz al, inh⟩ => some (sz, al, inh)
  | _ => none

theorem pointeeSized?_spec {pt : PtrType} {sz : Nat} {al : Align} {inh : Bool}
    (h : pointeeSized? pt = some (sz, al, inh)) : pt.pointee? = some ⟨.sized sz al, inh⟩ := by
  unfold pointeeSized? at h
  split at h
  next sz' al' inh' hp =>
    cases h
    exact hp
  · cases h

inductive LowerOffset (Γ : StmtCtx) : Statement → List Insn → Prop where
  | offset {d a b : Local} {oa ob : Operand} {pt : PtrType} {valid : ValidRange} {tb : IntType}
      {vb : ValidRange} {sz : Nat} {al : Align} {inh : Bool} {sd sa sb : LocalSlot} {i : Insn}
      (ha : oa.local? = some a) (hb : ob.local? = some b)
      (hk : pt.metaKind = .none) (hpe : pt.pointee? = some ⟨.sized sz al, inh⟩)
      (htd : Γ.body.locals[d]? = some (.ptr pt valid))
      (hta : Γ.body.locals[a]? = some (.ptr pt valid))
      (htb : Γ.body.locals[b]? = some (.int tb vb)) (htb8 : tb.size = 8)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = 8 ∧ sa.size = 8 ∧ sb.size = 8)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk sb.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : ptrIndexInsnOk Γ i sd.off sa.off sb.off sz = true) :
      LowerOffset Γ (.assign ⟨d, []⟩ (.binaryOp .offset oa ob)) [i]

/-- `offset`'s checker. -/
def checkOffsetAt (Γ : StmtCtx) (d : Local) (oa ob : Operand) (is : List Insn) : Verdict :=
  match oa.local?, ob.local? with
  | some a, some b =>
    match Γ.body.locals[d]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some (.ptr pt valid), some ta, some (.int tb _) =>
      if ta != Ty.ptr pt valid then .unsupported "offset: mixed types"
      else if !(pt.metaKind == .none && tb.size == 8) then .unsupported "offset: pointer or index type"
      else match pointeeSized? pt with
        | some (sz, _, _) =>
          match Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
          | some sd, some sa, some sb, [i] =>
            if !(sd.size == 8 && sa.size == 8 && sb.size == 8) then
              .rejected "offset: slot sizes"
            else if !(offOk sd.off && offOk sa.off && offOk sb.off) then
              .rejected "offset: offsets"
            else if !privOk Γ sd.off sd.size then .unsupported "offset: escaped destination"
            else if ptrIndexInsnOk Γ i sd.off sa.off sb.off sz then .ok
            else .unsupported "offset: instruction form"
          | _, _, _, _ => .unsupported "offset: slots or instruction count"
        | none => .unsupported "offset: unsized pointee"
    | _, _, _ => .unsupported "offset: not a pointer and an integer"
  | _, _ => .unsupported "offset: operands"

theorem checkOffsetAt_sound {Γ : StmtCtx} {d : Local} {oa ob : Operand} {is : List Insn}
    (h : checkOffsetAt Γ d oa ob is = .ok) :
    LowerOffset Γ (.assign ⟨d, []⟩ (.binaryOp .offset oa ob)) is := by
  unfold checkOffsetAt at h
  split at h
  next a b ha hb =>
    split at h
    next pt valid ta tb vb htd hta htb =>
      split at h
      · cases h
      next hty =>
        have hty : ta = .ptr pt valid := by simpa using hty
        subst hty
        split at h
        · cases h
        next hkt =>
          have hkt : pt.metaKind = .none ∧ tb.size = 8 := by simpa using hkt
          split at h
          next sz al inh hps =>
            split at h
            next sd sa sb i hsd hsa hsb =>
              split at h
              · cases h
              next hsz =>
                split at h
                · cases h
                next hoff =>
                  split at h
                  · cases h
                  next hpriv =>
                    split at h
                    next hi =>
                      exact .offset ha hb hkt.1 (pointeeSized?_spec hps) htd hta htb hkt.2 hsd
                        hsa hsb (by simp at hsz; exact ⟨hsz.1.1, hsz.1.2, hsz.2⟩)
                        (by simp at hoff; exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩)
                        (privOk_spec (by simpa using hpriv)) hi
                    · cases h
            · cases h
          · cases h
    · cases h
  · cases h

/-- Decide `LowerOffset`: `none` unless `st` assigns an `Offset` to a whole local. -/
def checkOffset (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp .offset oa ob) => some (checkOffsetAt Γ d oa ob is)
  | _ => none

theorem checkOffset_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkOffset Γ st is = some .ok) : LowerOffset Γ st is := by
  unfold checkOffset at h
  split at h
  · exact checkOffsetAt_sound (Option.some.inj h)
  · cases h

end Ryo.Check.Lower
