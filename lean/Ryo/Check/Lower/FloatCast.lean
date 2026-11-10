/-
Ryo.Check.Lower.FloatCast — `as` casts involving floats between locals (aot.md §C1, M5b), and
their checker.

`_d = cast k (copy/move _a) ty` lowered to one `cvt` handler (`backend/src/lower/cast.rs`:
`cvt_f2i`, `cvt_i2f`, `cvt_f2f`) on `_d`'s and `_a`'s slots (`cvtInsnOk`), `_d`'s slot never
escaped:
- `f2i`: `floatToInt` from `.float f` to `.int t`: `cvt [f, t]` (saturating, NaN → 0, both
  sides `Float.toInt`);
- `i2f`: `intToFloat` from `.int t` to `.float g`: `cvt [t, g]` (`Float.ofInt`);
- `f2f`: `floatToFloat` from `.float f` to `.float g`: `cvt [f, g]` (`Float.convert`, a NaN's
  bits L0's oracle answer and R's choice, as `BinFloat.lean`).
The simulation is `Proofs/Lower/SimFloatCast.lean`.

`checkFloatCast` answers `none` unless the statement is such a cast with all checks passing, so
it must run before the families that report these casts (`checkCastMore`).
-/
import Ryo.Check.Lower.BinFloat

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- An instruction whose view is a `cvt` handler from type `X` to type `Y`, on slots `d, s`,
falling through. -/
def cvtInsnOk (Γ : StmtCtx) (i : Insn) (X Y : OpSem.Ty) (d s : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [tx, ty], _⟩ =>
      kd == .cvt && OpSem.Ty.parse tx == some X && OpSem.Ty.parse ty == some Y &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"s", .slot⟩] &&
        v.ops == [.slot d, .slot s] && v.ctl == some .next
    | _ => false
  | none => false

theorem cvtInsnOk_spec {Γ : StmtCtx} {i : Insn} {X Y : OpSem.Ty} {d s : Int}
    (h : cvtInsnOk Γ i X Y d s = true) :
    ∃ v tx ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.cvt, [tx, ty], r⟩ ∧
      OpSem.Ty.parse tx = some X ∧ OpSem.Ty.parse ty = some Y ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩] ∧
      v.ops = [.slot d, .slot s] ∧ v.ctl = some .next := by
  unfold cvtInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd tx ty r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨hkd, htx⟩, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hkd
      exact ⟨v, tx, ty, r, hv, hh, htx, hty, ho, hops, hctl⟩
    · cases h
  · cases h

inductive LowerFloatCast (Γ : StmtCtx) : Statement → List Insn → Prop where
  | f2i {d a : Local} {oa : Operand} {f : FloatTy} {t : IntType} {vd vc : ValidRange}
      {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.int t vd)) (hta : Γ.body.locals[a]? = some (.float f))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = f.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : cvtInsnOk Γ i (.float f) (.int t.size t.signed) sd.off sa.off = true) :
      LowerFloatCast Γ (.assign ⟨d, []⟩ (.cast .floatToInt oa (.int t vc))) [i]
  | i2f {d a : Local} {oa : Operand} {g : FloatTy} {t : IntType} {va : ValidRange}
      {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.float g)) (hta : Γ.body.locals[a]? = some (.int t va))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = g.size ∧ sa.size = t.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : cvtInsnOk Γ i (.int t.size t.signed) (.float g) sd.off sa.off = true) :
      LowerFloatCast Γ (.assign ⟨d, []⟩ (.cast .intToFloat oa (.float g))) [i]
  | f2f {d a : Local} {oa : Operand} {f g : FloatTy} {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.float g)) (hta : Γ.body.locals[a]? = some (.float f))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = g.size ∧ sa.size = f.size)
      (hoff : offOk sd.off = true ∧ offOk sa.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : cvtInsnOk Γ i (.float f) (.float g) sd.off sa.off = true) :
      LowerFloatCast Γ (.assign ⟨d, []⟩ (.cast .floatToFloat oa (.float g))) [i]

/-! ### The checker -/

/-- The checks shared by the rules: `_d`'s and `_a`'s slots of `nd` and `na` bytes, the offsets,
`_d` private, and the instruction. -/
def floatCastOk (Γ : StmtCtx) (d a : Local) (nd na : Nat) (X Y : OpSem.Ty) (is : List Insn) :
    Bool :=
  match Γ.slots[d]?, Γ.slots[a]?, is with
  | some sd, some sa, [i] =>
    sd.size == nd && sa.size == na && offOk sd.off && offOk sa.off &&
      privOk Γ sd.off sd.size && cvtInsnOk Γ i X Y sd.off sa.off
  | _, _, _ => false

theorem floatCastOk_spec {Γ : StmtCtx} {d a : Local} {nd na : Nat} {X Y : OpSem.Ty}
    {is : List Insn} (h : floatCastOk Γ d a nd na X Y is = true) :
    ∃ sd sa i, is = [i] ∧ Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧
      (sd.size = nd ∧ sa.size = na) ∧ (offOk sd.off = true ∧ offOk sa.off = true) ∧
      (∀ k < sd.size, Γ.escaped (sd.off + k) = false) ∧
      cvtInsnOk Γ i X Y sd.off sa.off = true := by
  unfold floatCastOk at h
  split at h
  next sd sa i hsd hsa =>
    simp only [Bool.and_eq_true, beq_iff_eq] at h
    obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := h
    exact ⟨sd, sa, i, rfl, hsd, hsa, ⟨h1, h2⟩, ⟨h3, h4⟩, privOk_spec h5, h6⟩
  next => cases h

/-- Decide `LowerFloatCast` (see the module comment). -/
def checkFloatCast (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.cast .floatToInt oa (.int t _)) =>
    match oa.local?, Γ.body.locals[d]?, Γ.body.locals[oa.local?.getD 0]? with
    | some a, some (.int t' _), some (.float f) =>
      if t' = t ∧ floatCastOk Γ d a t.size f.size (.float f) (.int t.size t.signed) is = true
      then some .ok else none
    | _, _, _ => none
  | .assign ⟨d, []⟩ (.cast .intToFloat oa (.float g)) =>
    match oa.local?, Γ.body.locals[d]?, Γ.body.locals[oa.local?.getD 0]? with
    | some a, some (.float g'), some (.int t _) =>
      if g' = g ∧ floatCastOk Γ d a g.size t.size (.int t.size t.signed) (.float g) is = true
      then some .ok else none
    | _, _, _ => none
  | .assign ⟨d, []⟩ (.cast .floatToFloat oa (.float g)) =>
    match oa.local?, Γ.body.locals[d]?, Γ.body.locals[oa.local?.getD 0]? with
    | some a, some (.float g'), some (.float f) =>
      if g' = g ∧ floatCastOk Γ d a g.size f.size (.float f) (.float g) is = true
      then some .ok else none
    | _, _, _ => none
  | _ => none

theorem checkFloatCast_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkFloatCast Γ st is = some .ok) : LowerFloatCast Γ st is := by
  unfold checkFloatCast at h
  split at h
  next d oa t _ =>
    split at h
    next a t' vd f ha htd hta =>
      simp only [ha, Option.getD_some] at hta
      split at h
      next hc =>
        obtain ⟨rfl, hok⟩ := hc
        obtain ⟨sd, sa, i, rfl, hsd, hsa, hsize, hoff, hpriv, hi⟩ := floatCastOk_spec hok
        exact .f2i ha htd hta hsd hsa hsize hoff hpriv hi
      next => cases h
    next => cases h
  next d oa g =>
    split at h
    next a g' t va ha htd hta =>
      simp only [ha, Option.getD_some] at hta
      split at h
      next hc =>
        obtain ⟨rfl, hok⟩ := hc
        obtain ⟨sd, sa, i, rfl, hsd, hsa, hsize, hoff, hpriv, hi⟩ := floatCastOk_spec hok
        exact .i2f ha htd hta hsd hsa hsize hoff hpriv hi
      next => cases h
    next => cases h
  next d oa g =>
    split at h
    next a g' f ha htd hta =>
      simp only [ha, Option.getD_some] at hta
      split at h
      next hc =>
        obtain ⟨rfl, hok⟩ := hc
        obtain ⟨sd, sa, i, rfl, hsd, hsa, hsize, hoff, hpriv, hi⟩ := floatCastOk_spec hok
        exact .f2f ha htd hta hsd hsa hsize hoff hpriv hi
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
