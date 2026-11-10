/-
Ryo.Check.Lower.Deref — the lowering rules for reading and writing through a thin pointer held
in a local (aot.md §C1, M5b's places) and their checker.

What the backend emits (`backend/src/lower/place.rs` `deref`/`field`, `operand.rs`
`copy_val`/`load`/`store`): the place `(*_p).f₁.….fₖ` with `_p` a local of reference or raw
pointer type with a thin pointer (`Loc::Slot`) becomes the memory operand `[sp.off + off]`
(`Loc::Mem { p: sp.off, k: off }`), `off` the sum of the field offsets. A copy between it and a
frame slot of `n` bytes is one `load.wN d, [p + k]` / `store.wN [p + k], s` when `n` is 1, 2, 4,
8 or 16 (`Width::of_size`); other sizes are split into pieces or use `load.copy`/`store.copy`,
which these rules do not cover.

Rules:
- `load`: `_d = copy/move (*_p).f₁.….fₖ`, `_p`'s L0 type `.ptr pt valid` with a thin pointer
  (`pt.metaKind = .none`, 8 bytes), the projections after the deref all fields `fieldPath`
  covers from the deref's pointee type (the type L0 projects through: `projectPlace`'s
  `.deref pointee`), `ty` the projected type, equal to `_d`'s declared type, well-formed, of
  `n > 0` bytes; one `load` handler of `n` bytes (`loadInsnOk`) from `[sp.off + off]` to `_d`'s
  slot (`n` bytes, never escaped). L0 loads `_p`, decodes the pointer `q`, offsets it in bounds
  by `off`, loads `n` bytes at `ty` and stores the re-encoding into `_d`; R reads `_p`'s slot,
  decodes the pointer and loads `n` bytes at `q + off` (`Ryo.Proofs.Lower.lift_derefLoad`).
- `store`: `(*_p).f₁.….fₖ = copy/move _a` (the same place), `_a` a whole local of the projected
  type `ty` (well-formed, `n > 0` bytes, its slot `n` bytes), one `store` handler of `n` bytes
  (`storeInsnOk`) from `_a`'s slot to `[sp.off + off]` (`Ryo.Proofs.Lower.lift_derefStore`).

`_p` and `_a` may be private or escaped (the simulation reads either). Nothing is assumed about
where `_p` points: the simulation shows a pointer read from L0 memory points outside the
frame's private locals.

`checkDeref` answers `none` for any other statement, so a dispatcher can try families in turn;
it must run before `checkField`, which reports reads through a deref as unsupported.
-/
import Ryo.Check.Lower.Field
import Ryo.Check.Lower.Copy

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- An instruction whose view is a `load` handler of `n` bytes from `[p + k]` into slot `d`,
falling through. -/
def loadInsnOk (Γ : StmtCtx) (i : Insn) (n : Nat) (d p k : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty], _⟩ =>
      kd == .load && intTyOk ty n &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"m", .mem⟩] &&
        v.ops == [.slot d, .mem p k] && v.ctl == some .next
    | _ => false
  | none => false

/-- An instruction whose view is a `store` handler of `n` bytes from slot `s` to `[p + k]`,
falling through. -/
def storeInsnOk (Γ : StmtCtx) (i : Insn) (n : Nat) (p k s : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty], _⟩ =>
      kd == .store && intTyOk ty n &&
        v.op.info.operands == [⟨"m", .mem⟩, ⟨"s", .slot⟩] &&
        v.ops == [.mem p k, .slot s] && v.ctl == some .next
    | _ => false
  | none => false

theorem loadInsnOk_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {d p k : Int}
    (h : loadInsnOk Γ i n d p k = true) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.load, [ty], r⟩ ∧
      intTyOk ty n = true ∧ v.op.info.operands = [⟨"d", .slot⟩, ⟨"m", .mem⟩] ∧
      v.ops = [.slot d, .mem p k] ∧ v.ctl = some .next := by
  unfold loadInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨hkd, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hkd
      exact ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩
    · cases h
  · cases h

theorem storeInsnOk_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {p k s : Int}
    (h : storeInsnOk Γ i n p k s = true) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.store, [ty], r⟩ ∧
      intTyOk ty n = true ∧ v.op.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩] ∧
      v.ops = [.mem p k, .slot s] ∧ v.ctl = some .next := by
  unfold storeInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨hkd, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hkd
      exact ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩
    · cases h
  · cases h

inductive LowerDeref (Γ : StmtCtx) : Statement → List Insn → Prop where
  | load {d p : Local} {oa : Operand} {pointee ty : Ty} {fields : List ProjElem} {pt : PtrType}
      {valid : ValidRange} {off n : Nat} {sd sp : LocalSlot} {i : Insn}
      (ha : operandPlace? oa = some ⟨p, .deref pointee :: fields⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (htd : Γ.body.locals[d]? = some ty)
      (hn : ty.size? = some n) (hpos : 0 < n) (hwf : ty.wf = true)
      (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp)
      (hsize : sd.size = n ∧ sp.size = 8)
      (hoff : offOk sd.off ∧ offOk sp.off ∧ offOk (off : Int))
      (hi : loadInsnOk Γ i n sd.off sp.off off = true) :
      LowerDeref Γ (.assign ⟨d, []⟩ (.use oa)) [i]
  | store {p a : Local} {oa : Operand} {pointee ty : Ty} {fields : List ProjElem} {pt : PtrType}
      {valid : ValidRange} {off n : Nat} {sp sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (hta : Γ.body.locals[a]? = some ty)
      (hn : ty.size? = some n) (hpos : 0 < n) (hwf : ty.wf = true)
      (hsp : Γ.slots[p]? = some sp) (hsa : Γ.slots[a]? = some sa)
      (hsize : sa.size = n ∧ sp.size = 8)
      (hoff : offOk sp.off ∧ offOk sa.off ∧ offOk (off : Int))
      (hi : storeInsnOk Γ i n sp.off off sa.off = true) :
      LowerDeref Γ (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) [i]

/-- A coverage bucket for the projections after a deref that `fieldPath` does not cover. -/
def derefWhy (fields : List ProjElem) : String :=
  "deref: then " ++ projWhy fields

/-- `load`'s checker for `_d = copy/move (*_p).fields`. -/
def checkDerefLoad (Γ : StmtCtx) (d p : Local) (pointee : Ty) (fields : List ProjElem)
    (is : List Insn) : Verdict :=
  match Γ.body.locals[p]? with
  | some (.ptr pt _) =>
    if pt.metaKind = .none then
      match fieldPath pointee fields with
      | none => .unsupported (derefWhy fields)
      | some (off, ty) =>
        match Γ.body.locals[d]? with
        | none => .rejected "deref: no destination local"
        | some td =>
          if td != ty then .unsupported "deref: types"
          else match ty.size? with
            | none => .unsupported "deref: unsized"
            | some n =>
              if n = 0 then .unsupported "deref: zero-sized"
              else if !ty.wf then .rejected "deref: ill-formed type"
              else if !movWidth n then .unsupported "deref: not a load width"
              else match Γ.slots[d]?, Γ.slots[p]?, is with
                | some sd, some sp, [i] =>
                  if !(sd.size == n && sp.size == 8) then .rejected "deref: slot sizes"
                  else if !(offOk sd.off && offOk sp.off && offOk (off : Int)) then
                    .rejected "deref: offsets"
                  else if loadInsnOk Γ i n sd.off sp.off off then .ok
                  else .unsupported "deref: instruction form"
                | _, _, _ => .unsupported "deref: slots or instruction count"
    else .unsupported "deref: wide pointer"
  | _ => .unsupported "deref: not a pointer local"

/-- `store`'s checker for `(*_p).fields = copy/move _a`. -/
def checkDerefStore (Γ : StmtCtx) (p : Local) (pointee : Ty) (fields : List ProjElem) (a : Local)
    (is : List Insn) : Verdict :=
  match Γ.body.locals[p]? with
  | some (.ptr pt _) =>
    if pt.metaKind = .none then
      match fieldPath pointee fields with
      | none => .unsupported ("store " ++ derefWhy fields)
      | some (off, ty) =>
        match Γ.body.locals[a]? with
        | none => .rejected "deref store: no source local"
        | some ta =>
          if ta != ty then .unsupported "deref store: types"
          else match ty.size? with
            | none => .unsupported "deref store: unsized"
            | some n =>
              if n = 0 then .unsupported "deref store: zero-sized"
              else if !ty.wf then .rejected "deref store: ill-formed type"
              else if !movWidth n then .unsupported "deref store: not a store width"
              else match Γ.slots[p]?, Γ.slots[a]?, is with
                | some sp, some sa, [i] =>
                  if !(sa.size == n && sp.size == 8) then .rejected "deref store: slot sizes"
                  else if !(offOk sp.off && offOk sa.off && offOk (off : Int)) then
                    .rejected "deref store: offsets"
                  else if storeInsnOk Γ i n sp.off off sa.off then .ok
                  else .unsupported "deref store: instruction form"
                | _, _, _ => .unsupported "deref store: slots or instruction count"
    else .unsupported "deref store: wide pointer"
  | _ => .unsupported "deref store: not a pointer local"

/-- The family's checker: `none` unless `st` reads `(*_p).fields` into a whole local or writes a
whole local's operand to it. -/
def checkDeref (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use oa) =>
    match operandPlace? oa with
    | some ⟨p, .deref pointee :: fields⟩ => some (checkDerefLoad Γ d p pointee fields is)
    | _ => none
  | .assign ⟨p, .deref pointee :: fields⟩ (.use oa) =>
    match oa.local? with
    | some a => some (checkDerefStore Γ p pointee fields a is)
    | none => none
  | _ => none

theorem checkDerefLoad_sound {Γ : StmtCtx} {d p : Local} {oa : Operand} {pointee : Ty}
    {fields : List ProjElem} {is : List Insn}
    (ha : operandPlace? oa = some ⟨p, .deref pointee :: fields⟩)
    (h : checkDerefLoad Γ d p pointee fields is = .ok) :
    LowerDeref Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkDerefLoad at h
  split at h
  next pt valid htp =>
    split at h
    next hk =>
      split at h
      · cases h
      next off ty hpath =>
        split at h
        · cases h
        next td htd =>
          split at h
          · cases h
          next hty =>
            have e : td = ty := by simpa using hty
            rw [e] at htd
            split at h
            · cases h
            next n hn =>
              split at h
              · cases h
              next hn0 =>
                split at h
                · cases h
                next hwf =>
                  have hwf' : ty.wf = true := by simpa using hwf
                  split at h
                  · cases h
                  next =>
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
                            exact .load ha htp hk hpath htd hn (Nat.pos_of_ne_zero hn0) hwf'
                              hsd hsp (by simpa using hsz)
                              (by simp at hoff; exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩) hi
                          · cases h
                    · cases h
    · cases h
  · cases h

theorem checkDerefStore_sound {Γ : StmtCtx} {p a : Local} {oa : Operand} {pointee : Ty}
    {fields : List ProjElem} {is : List Insn} (ha : oa.local? = some a)
    (h : checkDerefStore Γ p pointee fields a is = .ok) :
    LowerDeref Γ (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) is := by
  unfold checkDerefStore at h
  split at h
  next pt valid htp =>
    split at h
    next hk =>
      split at h
      · cases h
      next off ty hpath =>
        split at h
        · cases h
        next ta hta =>
          split at h
          · cases h
          next hty =>
            have e : ta = ty := by simpa using hty
            rw [e] at hta
            split at h
            · cases h
            next n hn =>
              split at h
              · cases h
              next hn0 =>
                split at h
                · cases h
                next hwf =>
                  have hwf' : ty.wf = true := by simpa using hwf
                  split at h
                  · cases h
                  next =>
                    split at h
                    next sp sa i hsp hsa =>
                      split at h
                      · cases h
                      next hsz =>
                        split at h
                        · cases h
                        next hoff =>
                          split at h
                          next hi =>
                            exact .store ha htp hk hpath hta hn (Nat.pos_of_ne_zero hn0) hwf'
                              hsp hsa (by simpa using hsz)
                              (by simp at hoff; exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩) hi
                          · cases h
                    · cases h
    · cases h
  · cases h

theorem checkDeref_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkDeref Γ st is = some .ok) : LowerDeref Γ st is := by
  unfold checkDeref at h
  split at h
  next d oa =>
    split at h
    next p pointee fields hp => exact checkDerefLoad_sound hp (Option.some.inj h)
    · cases h
  next p pointee fields oa =>
    split at h
    next a ha => exact checkDerefStore_sound ha (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
