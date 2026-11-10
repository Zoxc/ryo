/-
Ryo.Check.Lower.StoreTemp — integer values computed into a temporary and stored through a thin
pointer (aot.md §C1, M5b), and their checker.

What the backend emits (`backend/src/lower/operand.rs` `with_slot`, `binop.rs`, `constant.rs`):
an rvalue assigned to a place in memory (`(*_p).f₁.….fₖ`, `Loc::Mem`) is computed into a fresh
temporary `t` (`frame.temp`, apart from every local's slot) and then stored, `store.wN [p + off],
t` (one store when the size is at most 8: `store` splits at `W64`). The computations covered:
- a scalar integer constant: `imm t, bits` (`const_into`);
- `_a op _b`, `op` with a `binMethod` (`+`, `-`, `*` wrapping, `&`, `|`, `^`): one `bin`/`binop`
  instruction `t = a op b` (`arith`);
- `_a op const`: one `bin_imm`/`binop_imm` instruction.

L0 stores the result's encoding at the place's integer type, which is exactly the bytes R
computed into `t` (`Ryo/Proofs/Lower/SimStoreTemp.lean`).

Rules (`_p : .ptr pt valid` thin, the fields after the deref covered by `fieldPath` with place
type `.int t vp`, `t.size ≤ 8` a `mov` width; `t` the temporary, `tempOk`; the second
instruction `storeInsnOk` of `t.size` bytes from `t`):
- `const`: `(*_p).fields = const bits : int t _`, first instruction `imm t, bits`;
- `bin`: `(*_p).fields = op(_a, _b)`, `_a : .int t _`, `_b : .int t _` whole locals of slots of
  `t.size` bytes, first instruction `binInsnOk` into `t`;
- `binImm`: `(*_p).fields = op(_a, const bits : int t _)`, first instruction `binImmInsnOk`.

`checkStoreTemp` claims these statements (a deref place, an integer constant or a `binMethod`
operator) and is `none` otherwise.
-/
import Ryo.Check.Lower.Deref
import Ryo.Check.Lower.CmpConst

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerStoreTemp (Γ : StmtCtx) : Statement → List Insn → Prop where
  | const {p : Local} {pointee : Ty} {fields : List ProjElem} {pt : PtrType} {valid : ValidRange}
      {off : Nat} {t : IntType} {vp vc : ValidRange} {bits : Nat} {sp : LocalSlot} {tt : Int}
      {i1 i2 : Insn}
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hpk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, .int t vp))
      (hn : t.size ≤ 8) (hw : movWidth t.size = true)
      (hsp : Γ.slots[p]? = some sp) (hspz : sp.size = 8)
      (hoff : offOk sp.off ∧ offOk (off : Int)) (ht : tempOk Γ tt t.size = true)
      (hi1 : immInsnOk Γ i1 t.size tt bits = true)
      (hi2 : storeInsnOk Γ i2 t.size sp.off off tt = true) :
      LowerStoreTemp Γ (.assign ⟨p, .deref pointee :: fields⟩
        (.use (.const (.scalar bits) (.int t vc)))) [i1, i2]
  | bin {p a b : Local} {oa ob : Operand} {op : BinOp} {m : String} {pointee : Ty}
      {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off : Nat} {t : IntType}
      {vp va vb : ValidRange} {sp sa sb : LocalSlot} {tt : Int} {i1 i2 : Insn}
      (hm : binMethod op = some m) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hpk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, .int t vp))
      (hta : Γ.body.locals[a]? = some (.int t va)) (htb : Γ.body.locals[b]? = some (.int t vb))
      (hn : t.size ≤ 8) (hw : movWidth t.size = true)
      (hsp : Γ.slots[p]? = some sp) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sp.size = 8 ∧ sa.size = t.size ∧ sb.size = t.size)
      (hoff : offOk sp.off ∧ offOk (off : Int) ∧ offOk sa.off ∧ offOk sb.off)
      (ht : tempOk Γ tt t.size = true)
      (hi1 : binInsnOk Γ i1 m t.size tt sa.off sb.off = true)
      (hi2 : storeInsnOk Γ i2 t.size sp.off off tt = true) :
      LowerStoreTemp Γ (.assign ⟨p, .deref pointee :: fields⟩ (.binaryOp op oa ob)) [i1, i2]
  | binImm {p a : Local} {oa : Operand} {op : BinOp} {m : String} {pointee : Ty}
      {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off : Nat} {t : IntType}
      {vp va vc : ValidRange} {bits : Nat} {sp sa : LocalSlot} {tt : Int} {i1 i2 : Insn}
      (hm : binMethod op = some m) (ha : oa.local? = some a)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hpk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, .int t vp))
      (hta : Γ.body.locals[a]? = some (.int t va))
      (hn : t.size ≤ 8) (hw : movWidth t.size = true)
      (hsp : Γ.slots[p]? = some sp) (hsa : Γ.slots[a]? = some sa)
      (hsize : sp.size = 8 ∧ sa.size = t.size)
      (hoff : offOk sp.off ∧ offOk (off : Int) ∧ offOk sa.off)
      (ht : tempOk Γ tt t.size = true)
      (hi1 : binImmInsnOk Γ i1 m t.size tt sa.off bits = true)
      (hi2 : storeInsnOk Γ i2 t.size sp.off off tt = true) :
      LowerStoreTemp Γ (.assign ⟨p, .deref pointee :: fields⟩
        (.binaryOp op oa (.const (.scalar bits) (.int t vc)))) [i1, i2]

/-- The slot the first instruction writes, read off it (untrusted). -/
def firstSlotOf (Γ : StmtCtx) (i : Insn) : Option Int :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.ops with
    | .slot t :: _ => some t
    | _ => none
  | none => none

/-- The common part of the checkers: the pointer, the place's integer type (its `IntType`),
the offset and the slots and instructions; `k` checks the first instruction. -/
def checkStoreTempPlace (Γ : StmtCtx) (p : Local) (pointee : Ty) (fields : List ProjElem)
    (is : List Insn) (k : IntType → Int → Insn → Verdict) : Verdict :=
  match Γ.body.locals[p]? with
  | some (.ptr pt _) =>
    if pt.metaKind ≠ .none then .unsupported "store temp: wide pointer"
    else match fieldPath pointee fields with
      | some (off, .int t _) =>
        if !(decide (t.size ≤ 8) && movWidth t.size) then .unsupported "store temp: store width"
        else match Γ.slots[p]?, is with
          | some sp, [i1, i2] =>
            match firstSlotOf Γ i1 with
            | none => .unsupported "store temp: temporary"
            | some tt =>
              if sp.size ≠ 8 then .rejected "store temp: slot size"
              else if !(offOk sp.off && offOk (off : Int)) then .rejected "store temp: offsets"
              else if !tempOk Γ tt t.size then .unsupported "store temp: temporary"
              else if !storeInsnOk Γ i2 t.size sp.off off tt then
                .unsupported "store temp: store form"
              else k t tt i1
          | _, _ => .unsupported "store temp: slots or instruction count"
      | some _ => .unsupported "store temp: not an integer place"
      | none => .unsupported ("store temp " ++ derefWhy fields)
  | _ => .unsupported "store temp: not a pointer local"

theorem checkStoreTempPlace_ok {Γ : StmtCtx} {p : Local} {pointee : Ty}
    {fields : List ProjElem} {is : List Insn} {k : IntType → Int → Insn → Verdict}
    (h : checkStoreTempPlace Γ p pointee fields is k = .ok) :
    ∃ pt valid off t vp sp tt i1 i2, Γ.body.locals[p]? = some (.ptr pt valid) ∧
      pt.metaKind = .none ∧ fieldPath pointee fields = some (off, .int t vp) ∧
      t.size ≤ 8 ∧ movWidth t.size = true ∧ Γ.slots[p]? = some sp ∧ sp.size = 8 ∧
      (offOk sp.off = true ∧ offOk (off : Int) = true) ∧ tempOk Γ tt t.size = true ∧
      storeInsnOk Γ i2 t.size sp.off off tt = true ∧ is = [i1, i2] ∧ k t tt i1 = .ok := by
  unfold checkStoreTempPlace at h
  split at h
  next pt valid htp =>
    split at h
    · cases h
    next hpk =>
      split at h
      next off t vp hpath =>
        split at h
        · cases h
        next hw =>
          split at h
          next sp i1 i2 hsp =>
            split at h
            · cases h
            next tt _ =>
              split at h
              · cases h
              next hsz =>
                split at h
                · cases h
                next hoff =>
                  split at h
                  · cases h
                  next ht =>
                    split at h
                    · cases h
                    next hi2 =>
                      have hw' : t.size ≤ 8 ∧ movWidth t.size = true := by simpa using hw
                      exact ⟨pt, valid, off, t, vp, sp, tt, i1, i2, htp, by simpa using hpk, hpath,
                        hw'.1, hw'.2, hsp, by simpa using hsz, by simpa using hoff,
                        by simpa using ht, by simpa using hi2, rfl, h⟩
          · cases h
      all_goals cases h
  · cases h

/-- The family's checker: `none` unless `st` stores an integer constant or a `binMethod`
operator's result through a deref. -/
def checkStoreTemp (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨p, .deref pointee :: fields⟩ (.use (.const (.scalar bits) (.int tc _))) =>
    some (checkStoreTempPlace Γ p pointee fields is fun t tt i1 =>
      if tc ≠ t then .unsupported "store temp: constant type"
      else if immInsnOk Γ i1 t.size tt bits then .ok
      else .unsupported "store temp: constant form")
  | .assign ⟨p, .deref pointee :: fields⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc _))) =>
    match binMethod op, oa.local? with
    | some m, some a =>
      some (checkStoreTempPlace Γ p pointee fields is fun t tt i1 =>
        match Γ.body.locals[a]?, Γ.slots[a]? with
        | some (.int ta _), some sa =>
          if !(decide (ta = t) && decide (tc = t)) then .unsupported "store temp: operand types"
          else if sa.size ≠ t.size then .rejected "store temp: operand slot size"
          else if !offOk sa.off then .rejected "store temp: operand offset"
          else if binImmInsnOk Γ i1 m t.size tt sa.off bits then .ok
          else .unsupported "store temp: operator form"
        | _, _ => .unsupported "store temp: operand")
    | _, _ => none
  | .assign ⟨p, .deref pointee :: fields⟩ (.binaryOp op oa ob) =>
    match binMethod op, oa.local?, ob.local? with
    | some m, some a, some b =>
      some (checkStoreTempPlace Γ p pointee fields is fun t tt i1 =>
        match Γ.body.locals[a]?, Γ.body.locals[b]?, Γ.slots[a]?, Γ.slots[b]? with
        | some (.int ta _), some (.int tb _), some sa, some sb =>
          if !(decide (ta = t) && decide (tb = t)) then .unsupported "store temp: operand types"
          else if !(sa.size == t.size && sb.size == t.size) then
            .rejected "store temp: operand slot sizes"
          else if !(offOk sa.off && offOk sb.off) then .rejected "store temp: operand offsets"
          else if binInsnOk Γ i1 m t.size tt sa.off sb.off then .ok
          else .unsupported "store temp: operator form"
        | _, _, _, _ => .unsupported "store temp: operands")
    | _, _, _ => none
  | _ => none

theorem checkStoreTemp_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkStoreTemp Γ st is = some .ok) : LowerStoreTemp Γ st is := by
  unfold checkStoreTemp at h
  split at h
  next p pointee fields bits tc vc =>
    obtain ⟨pt, valid, off, t, vp, sp, tt, i1, i2, htp, hpk, hpath, hn, hw, hsp, hspz, hoff, ht,
      hi2, rfl, hk⟩ := checkStoreTempPlace_ok (Option.some.inj h)
    try dsimp only at hk
    split at hk
    · cases hk
    next htc =>
      have e : tc = t := by simpa using htc
      subst e
      split at hk
      next hi1 => exact .const htp hpk hpath hn hw hsp hspz hoff ht hi1 hi2
      · cases hk
  next p pointee fields op oa bits tc vc =>
    split at h
    next m a hm ha =>
      obtain ⟨pt, valid, off, t, vp, sp, tt, i1, i2, htp, hpk, hpath, hn, hw, hsp, hspz, hoff, ht,
        hi2, rfl, hk⟩ := checkStoreTempPlace_ok (Option.some.inj h)
      try dsimp only at hk
      split at hk
      next ta va sa hta hsa =>
        split at hk
        · cases hk
        next hty =>
          have hty' : ta = t ∧ tc = t := by simpa using hty
          obtain ⟨rfl, rfl⟩ := hty'
          split at hk
          · cases hk
          next hsz =>
            split at hk
            · cases hk
            next hoa =>
              split at hk
              next hi1 =>
                exact .binImm hm ha htp hpk hpath hta hn hw hsp hsa
                  ⟨hspz, by simpa using hsz⟩ ⟨hoff.1, hoff.2, by simpa using hoa⟩ ht hi1 hi2
              · cases hk
      · cases hk
    · cases h
  next p pointee fields op oa ob =>
    split at h
    next m a b hm ha hb =>
      obtain ⟨pt, valid, off, t, vp, sp, tt, i1, i2, htp, hpk, hpath, hn, hw, hsp, hspz, hoff, ht,
        hi2, rfl, hk⟩ := checkStoreTempPlace_ok (Option.some.inj h)
      try dsimp only at hk
      split at hk
      next ta va tb vb sa sb hta htb hsa hsb =>
        split at hk
        · cases hk
        next hty =>
          have hty' : ta = t ∧ tb = t := by simpa using hty
          obtain ⟨rfl, rfl⟩ := hty'
          split at hk
          · cases hk
          next hsz =>
            split at hk
            · cases hk
            next hoab =>
              split at hk
              next hi1 =>
                exact .bin hm ha hb htp hpk hpath hta htb hn hw hsp hsa hsb
                  ⟨hspz, by simpa using hsz⟩ ⟨hoff.1, hoff.2, by simpa using hoab⟩ ht hi1 hi2
              · cases hk
      · cases hk
    · cases h
  · cases h

end Ryo.Check.Lower
