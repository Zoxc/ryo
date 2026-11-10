/-
Ryo.Check.Lower.DerefCast — transmutes read from or written to a place through a thin pointer
held in a local (aot.md §C1, M5b), and their checker.

What the backend emits (`backend/src/lower/cast.rs`): a transmute (`Transmute`, `Subtype`,
`BoxDerefTransmute`) between types of one size is `operand_into(op, dst)`, the same copy as
`_dst = op`. So
- `_d = transmute (*_p).f₁.….fₖ` is `Deref.lean`'s `load`: one `load.wN d, [p + off]`;
- `(*_p).f₁.….fₖ = transmute _a` is `Deref.lean`'s `store`: one `store.wN [p + off], a`.

L0 (`transmute`: encode at the source type, decode at the target): the stored bytes are two
re-encodings of the loaded ones, each less defined (`encode_decode_le`, both types
well-formed), so the simulations are `Deref.lean`'s with "the stored bytes are below the loaded
ones" in place of one re-encoding (`Ryo/Proofs/Lower/SimDerefCast.lean`).

Rules (both types well-formed of `n > 0` bytes, `n` a `mov` width; `_p : .ptr pt valid` thin;
the projections after the deref covered by `fieldPath`, giving the place type `ty`):
- `load`: `_d = cast k (copy/move (*_p).fields) tyd`, `k` a transmute (`bitCastKind`), `_d : tyd`,
  one `load` of `n` bytes into `_d`'s slot (private or escaped).
- `store`: `(*_p).fields = cast k _a ty`, the cast's target the place type, `_a : ta` a whole
  local, one `store` of `n` bytes from `_a`'s slot.

`checkDerefCast` claims these statements and is `none` otherwise.
-/
import Ryo.Check.Lower.Deref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerDerefCast (Γ : StmtCtx) : Statement → List Insn → Prop where
  | load {d p : Local} {oa : Operand} {k : CastKind} {pointee ty tyd : Ty}
      {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off n : Nat}
      {sd sp : LocalSlot} {i : Insn}
      (hk : bitCastKind k = true) (ha : operandPlace? oa = some ⟨p, .deref pointee :: fields⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hpk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (htd : Γ.body.locals[d]? = some tyd)
      (hn : ty.size? = some n) (hnd : tyd.size? = some n) (hpos : 0 < n)
      (hwf : ty.wf = true) (hwfd : tyd.wf = true)
      (hsd : Γ.slots[d]? = some sd) (hsp : Γ.slots[p]? = some sp)
      (hsize : sd.size = n ∧ sp.size = 8)
      (hoff : offOk sd.off ∧ offOk sp.off ∧ offOk (off : Int))
      (hi : loadInsnOk Γ i n sd.off sp.off off = true) :
      LowerDerefCast Γ (.assign ⟨d, []⟩ (.cast k oa tyd)) [i]
  | store {p a : Local} {oa : Operand} {k : CastKind} {pointee ty ta : Ty}
      {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off n : Nat}
      {sp sa : LocalSlot} {i : Insn}
      (hk : bitCastKind k = true) (ha : oa.local? = some a)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hpk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (hta : Γ.body.locals[a]? = some ta)
      (hn : ty.size? = some n) (hna : ta.size? = some n) (hpos : 0 < n)
      (hwf : ty.wf = true) (hwfa : ta.wf = true)
      (hsp : Γ.slots[p]? = some sp) (hsa : Γ.slots[a]? = some sa)
      (hsize : sa.size = n ∧ sp.size = 8)
      (hoff : offOk sp.off ∧ offOk sa.off ∧ offOk (off : Int))
      (hi : storeInsnOk Γ i n sp.off off sa.off = true) :
      LowerDerefCast Γ (.assign ⟨p, .deref pointee :: fields⟩ (.cast k oa ty)) [i]

/-- The common part of both checkers: the pointer `_p`, the place, and the two types' sizes.
Gives the place type, the offset and the size. -/
def derefCastShape (Γ : StmtCtx) (p : Local) (pointee : Ty) (fields : List ProjElem)
    (t2 : Ty) : Except String (Nat × Ty × Nat) :=
  match Γ.body.locals[p]? with
  | some (.ptr pt _) =>
    if pt.metaKind ≠ .none then .error "deref transmute: wide pointer"
    else match fieldPath pointee fields with
      | none => .error ("deref transmute: " ++ derefWhy fields)
      | some (off, ty) =>
        match ty.size?, t2.size? with
        | some n, some n2 =>
          if n ≠ n2 then .error "deref transmute: sizes"
          else if n = 0 then .error "deref transmute: zero-sized"
          else if !(ty.wf && t2.wf) then .error "deref transmute: ill-formed type"
          else if !movWidth n then .error "deref transmute: not a load/store width"
          else .ok (off, ty, n)
        | _, _ => .error "deref transmute: unsized"
  | _ => .error "deref transmute: not a pointer local"

theorem derefCastShape_ok {Γ : StmtCtx} {p : Local} {pointee : Ty} {fields : List ProjElem}
    {t2 : Ty} {off : Nat} {ty : Ty} {n : Nat}
    (h : derefCastShape Γ p pointee fields t2 = .ok (off, ty, n)) :
    ∃ pt valid, Γ.body.locals[p]? = some (.ptr pt valid) ∧ pt.metaKind = .none ∧
      fieldPath pointee fields = some (off, ty) ∧ ty.size? = some n ∧ t2.size? = some n ∧
      0 < n ∧ ty.wf = true ∧ t2.wf = true := by
  unfold derefCastShape at h
  split at h
  next pt valid htp =>
    split at h
    · cases h
    next hpk =>
      split at h
      · cases h
      next off' ty' hpath =>
        split at h
        next n' n2 hn hn2 =>
          split at h
          · cases h
          next hne =>
            split at h
            · cases h
            next h0 =>
              split at h
              · cases h
              next hwf =>
                split at h
                · cases h
                next =>
                  have hwf' : ty'.wf = true ∧ t2.wf = true := by simpa using hwf
                  have hn2' : t2.size? = some n' := by
                    have e : n' = n2 := by simpa using hne
                    rw [e]; exact hn2
                  have hpos' : 0 < n' := Nat.pos_of_ne_zero h0
                  have hpk' : pt.metaKind = .none := by simpa using hpk
                  cases h
                  exact ⟨pt, valid, htp, hpk', hpath, hn, hn2', hpos', hwf'.1, hwf'.2⟩
        · cases h
  · cases h

/-- `load`'s checker. -/
def checkDerefCastLoad (Γ : StmtCtx) (d p : Local) (pointee : Ty) (fields : List ProjElem)
    (tyd : Ty) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]? with
  | none => .rejected "deref transmute: no destination local"
  | some td =>
    if td ≠ tyd then .unsupported "deref transmute: destination type"
    else match derefCastShape Γ p pointee fields tyd with
      | .error why => .unsupported why
      | .ok (off, _, n) =>
        match Γ.slots[d]?, Γ.slots[p]?, is with
        | some sd, some sp, [i] =>
          if !(sd.size == n && sp.size == 8) then .rejected "deref transmute: slot sizes"
          else if !(offOk sd.off && offOk sp.off && offOk (off : Int)) then
            .rejected "deref transmute: offsets"
          else if loadInsnOk Γ i n sd.off sp.off off then .ok
          else .unsupported "deref transmute: instruction form"
        | _, _, _ => .unsupported "deref transmute: slots or instruction count"

/-- `store`'s checker. -/
def checkDerefCastStore (Γ : StmtCtx) (p : Local) (pointee : Ty) (fields : List ProjElem)
    (a : Local) (tyc : Ty) (is : List Insn) : Verdict :=
  match Γ.body.locals[a]? with
  | none => .rejected "deref store transmute: no source local"
  | some ta =>
    match derefCastShape Γ p pointee fields ta with
    | .error why => .unsupported ("store " ++ why)
    | .ok (off, ty, n) =>
      if tyc ≠ ty then .unsupported "deref store transmute: target type"
      else match Γ.slots[p]?, Γ.slots[a]?, is with
        | some sp, some sa, [i] =>
          if !(sa.size == n && sp.size == 8) then .rejected "deref store transmute: slot sizes"
          else if !(offOk sp.off && offOk sa.off && offOk (off : Int)) then
            .rejected "deref store transmute: offsets"
          else if storeInsnOk Γ i n sp.off off sa.off then .ok
          else .unsupported "deref store transmute: instruction form"
        | _, _, _ => .unsupported "deref store transmute: slots or instruction count"

/-- The family's checker: `none` unless `st` transmutes from or into a place through a deref. -/
def checkDerefCast (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.cast k oa tyd) =>
    if bitCastKind k then
      match operandPlace? oa with
      | some ⟨p, .deref pointee :: fields⟩ =>
        some (checkDerefCastLoad Γ d p pointee fields tyd is)
      | _ => none
    else none
  | .assign ⟨p, .deref pointee :: fields⟩ (.cast k oa tyc) =>
    if bitCastKind k then
      match oa.local? with
      | some a => some (checkDerefCastStore Γ p pointee fields a tyc is)
      | none => none
    else none
  | _ => none

theorem checkDerefCastLoad_sound {Γ : StmtCtx} {d p : Local} {oa : Operand} {k : CastKind}
    {pointee tyd : Ty} {fields : List ProjElem} {is : List Insn} (hk : bitCastKind k = true)
    (ha : operandPlace? oa = some ⟨p, .deref pointee :: fields⟩)
    (h : checkDerefCastLoad Γ d p pointee fields tyd is = .ok) :
    LowerDerefCast Γ (.assign ⟨d, []⟩ (.cast k oa tyd)) is := by
  unfold checkDerefCastLoad at h
  split at h
  · cases h
  next td htd =>
    split at h
    · cases h
    next hty =>
      have e : td = tyd := by simpa using hty
      subst e
      split at h
      · cases h
      next off ty n hsh =>
        obtain ⟨pt, valid, htp, hpk, hpath, hn, hnd, hpos, hwf, hwfd⟩ := derefCastShape_ok hsh
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
                exact .load hk ha htp hpk hpath htd hn hnd hpos hwf hwfd hsd hsp
                  (by simpa using hsz) (by simpa [and_assoc] using hoff) hi
              · cases h
        · cases h

theorem checkDerefCastStore_sound {Γ : StmtCtx} {p a : Local} {oa : Operand} {k : CastKind}
    {pointee tyc : Ty} {fields : List ProjElem} {is : List Insn} (hk : bitCastKind k = true)
    (ha : oa.local? = some a)
    (h : checkDerefCastStore Γ p pointee fields a tyc is = .ok) :
    LowerDerefCast Γ (.assign ⟨p, .deref pointee :: fields⟩ (.cast k oa tyc)) is := by
  unfold checkDerefCastStore at h
  split at h
  · cases h
  next ta hta =>
    split at h
    · cases h
    next off ty n hsh =>
      obtain ⟨pt, valid, htp, hpk, hpath, hn, hna, hpos, hwf, hwfa⟩ := derefCastShape_ok hsh
      split at h
      · cases h
      next hty =>
        have e : tyc = ty := by simpa using hty
        subst e
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
                exact .store hk ha htp hpk hpath hta hn hna hpos hwf hwfa hsp hsa
                  (by simpa using hsz) (by simpa [and_assoc] using hoff) hi
              · cases h
        · cases h

theorem checkDerefCast_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkDerefCast Γ st is = some .ok) : LowerDerefCast Γ st is := by
  unfold checkDerefCast at h
  split at h
  next d k oa tyd =>
    split at h
    next hk =>
      split at h
      next p pointee fields ha => exact checkDerefCastLoad_sound hk ha (Option.some.inj h)
      · cases h
    · cases h
  next p pointee fields k oa tyc =>
    split at h
    next hk =>
      split at h
      next a ha => exact checkDerefCastStore_sound hk ha (Option.some.inj h)
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
