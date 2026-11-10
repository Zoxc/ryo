/-
Ryo.Check.Lower.Ovf — the statement rule for the overflow-checked binary operators (aot.md §C1,
M5b) and its checker.

Rule (`LowerOvf`), on whole locals (`copy`/`move` of a local), the destination's slot never
escaped in the function (the simulation is for private destinations, as `LowerStmt`'s):
- `ovf`: `_d = AddWithOverflow/SubWithOverflow/MulWithOverflow(_a, _b)`, `_a` and `_b` of one
  integer type `t` (`t.wf`), `_d` the pair `(t, bool)`: a tuple type with fields
  `[(ov, int t), (oo, bool)]`, no tail, of the slot's size, the two fields' bytes in the slot and
  apart. Lowered to one `ovf` handler instruction (method `ovfMethod op`, `t`'s width and
  signedness) on `d + ov`, `d + oo`, `a`, `b` (`backend/src/lower/binop.rs`: the fields' offsets
  in `_d`'s layout). R writes the wrapped result and the overflow flag; L0 stores the same values
  over uninitialized padding.

Not covered: 128-bit `MulWithOverflow` (an island), a constant operand (materialized: two
instructions).

`checkOvf` decides the rule (`checkOvf_sound`): `none` for any statement that is not one of these
operators assigned to a whole local.
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The R method of an overflow-checked operator (an `ovf` handler). -/
def ovfMethod : BinOp → Option String
  | .addWithOverflow => some "overflowing_add"
  | .subWithOverflow => some "overflowing_sub"
  | .mulWithOverflow => some "overflowing_mul"
  | _ => none

/-- `ty` names an integer handler type of `n` bytes and signedness `sg`. -/
def intTyOkSg (ty : String) (n : Nat) (sg : Bool) : Bool :=
  match OpSem.Ty.parse ty with
  | some (.int n' sg') => n' == n && sg' == sg
  | _ => false

/-- An instruction whose view is an `ovf` handler with method `m` at `n` bytes and signedness
`sg`, on slots `d, o, a, b`, falling through. -/
def ovfInsnOk (Γ : StmtCtx) (i : Insn) (m : String) (n : Nat) (sg : Bool) (d o a b : Int) :
    Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, m'], _⟩ =>
      kd == .ovf && m' == m && intTyOkSg ty n sg &&
        v.op.info.operands ==
          [⟨"d", .slot⟩, ⟨"o", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] &&
        v.ops == [.slot d, .slot o, .slot a, .slot b] && v.ctl == some .next
    | _ => false
  | none => false

/-- The pair's layout: the value's `n` bytes at `ov` and the flag's byte at `oo` inside `N`
bytes, apart. -/
def ovfLayoutOk (N ov oo n : Nat) : Bool :=
  ov + n ≤ N && oo + 1 ≤ N && (ov + n ≤ oo || oo + 1 ≤ ov)

inductive LowerOvf (Γ : StmtCtx) : Statement → List Insn → Prop where
  | ovf {d a b : Local} {oa ob : Operand} {op : BinOp} {m : String} {t : IntType}
      {valid vt : ValidRange} {ov oo : Nat} {head : TupleHeadLayout} {sd sa sb : LocalSlot}
      {i : Insn}
      (hm : ovfMethod op = some m) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (hwf : t.wf = true)
      (htd : Γ.body.locals[d]? = some (.tuple [(ov, .int t vt), (oo, .bool)] head none))
      (hta : Γ.body.locals[a]? = some (.int t valid))
      (htb : Γ.body.locals[b]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = head.headSizeAndAlign.1 ∧ sa.size = t.size ∧ sb.size = t.size)
      (hlay : ovfLayoutOk sd.size ov oo t.size = true)
      (hoff : offOk (sd.off + ov) ∧ offOk (sd.off + oo) ∧ offOk sa.off ∧ offOk sb.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : ovfInsnOk Γ i m t.size t.signed (sd.off + ov) (sd.off + oo) sa.off sb.off = true) :
      LowerOvf Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]

/-- `ovf`'s checker. -/
def checkOvfAt (Γ : StmtCtx) (d : Local) (op : BinOp) (oa ob : Operand) (is : List Insn) :
    Verdict :=
  match ovfMethod op, oa.local?, ob.local? with
  | some m, some a, some b =>
    match Γ.body.locals[d]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some (.tuple [(ov, .int t' vt), (oo, .bool)] head none), some (.int t valid), some tb =>
      if !(tb == Ty.int t valid && t' == t && t.wf) then .unsupported "ovf: types"
      else match Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
        | some sd, some sa, some sb, [i] =>
          if !(sd.size == head.headSizeAndAlign.1 && sa.size == t.size && sb.size == t.size) then
            .rejected "ovf: slot sizes"
          else if !ovfLayoutOk sd.size ov oo t.size then .rejected "ovf: layout"
          else if !(offOk (sd.off + ov) && offOk (sd.off + oo) && offOk sa.off &&
              offOk sb.off) then .rejected "ovf: offsets"
          else if !privOk Γ sd.off sd.size then .unsupported "ovf: escaped destination"
          else if ovfInsnOk Γ i m t.size t.signed (sd.off + ov) (sd.off + oo) sa.off sb.off then
            .ok
          else .unsupported "ovf: instruction form"
        | _, _, _, _ => .unsupported "ovf: slots or instruction count"
    | _, _, _ => .unsupported "ovf: types"
  | _, _, _ => .unsupported "ovf: operands"

theorem checkOvfAt_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {oa ob : Operand}
    {is : List Insn} (h : checkOvfAt Γ d op oa ob is = .ok) :
    LowerOvf Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) is := by
  unfold checkOvfAt at h
  split at h
  next m a b hm ha hb =>
    split at h
    next ov t' vt oo head t valid tb htd hta htb =>
      split at h
      · cases h
      next hty =>
        have hty : (tb = .int t valid ∧ t' = t) ∧ t.wf = true := by simpa using hty
        obtain ⟨⟨rfl, rfl⟩, hwf⟩ := hty
        split at h
        next sd sa sb i hsd hsa hsb =>
          split at h
          · cases h
          next hsz =>
            split at h
            · cases h
            next hlay =>
              split at h
              · cases h
              next hoff =>
                split at h
                · cases h
                next hpriv =>
                  split at h
                  next hi =>
                    exact .ovf hm ha hb hwf htd hta htb hsd hsa hsb
                      (by simp at hsz; exact ⟨hsz.1.1, hsz.1.2, hsz.2⟩)
                      (by simpa using hlay)
                      (by simp at hoff; exact ⟨hoff.1.1.1, hoff.1.1.2, hoff.1.2, hoff.2⟩)
                      (privOk_spec (by simpa using hpriv)) hi
                  · cases h
        · cases h
    · cases h
  · cases h

/-- Decide `LowerOvf`: `none` unless `st` assigns an overflow-checked operator to a whole
local. -/
def checkOvf (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    match ovfMethod op with
    | some _ => some (checkOvfAt Γ d op oa ob is)
    | none => none
  | _ => none

theorem checkOvf_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkOvf Γ st is = some .ok) : LowerOvf Γ st is := by
  unfold checkOvf at h
  split at h
  · split at h
    · exact checkOvfAt_sound (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
