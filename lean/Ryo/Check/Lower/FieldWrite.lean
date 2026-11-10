/-
Ryo.Check.Lower.FieldWrite — assignments to a field of a local (aot.md §C1, M5b), and their
checker.

What the backend emits (`backend/src/lower/place.rs` `field`, `operand.rs`): the place
`_x.f₁.….fₖ` (only field projections, `fieldPath`) is the frame slot `sx.off + off`
(`Loc::Slot`), so the rvalue is written there directly, as into a whole local of the field's
type:
- `_x.fields = copy/move _a`: one `mov` of `n` bytes (`copy_val`, `n` a `mov` width);
- `_x.fields = const bits : int t`: one `imm` of `t`'s width (`const_into`);
- `_x.fields = op(_a, _b)` / `op(_a, const)`, `op` with a `binMethod`: one `bin`/`bin_imm`
  instruction into the field's bytes (`arith`).

L0 stores the value's encoding at the field's place `⟨px.addr + off, px.prov⟩` inside `_x`'s
allocation; R writes the corresponding bytes of `_x`'s slot. The rest of `_x`'s bytes are
untouched on both sides (`Ryo.Proofs.Lower.writeLocalSub_priv`, `SimFieldWrite.lean`).

Rules (`_x`'s slot private, the field inside it, offsets in range):
- `copy`: `_a` a whole local of the field type `ty`, well-formed of `n > 0` bytes, its slot `n`
  bytes;
- `const`: the field type `.int t _`, the constant at `.int t _`;
- `bin`/`binImm`: the field type `.int t _`, the operands whole locals (and a constant) of
  `.int t _` (`fieldIntPlace` for the field).

`checkFieldWrite` claims assignments of these rvalues to a place with only field projections
and is `none` otherwise.
-/
import Ryo.Check.Lower.Field
import Ryo.Check.Lower.Copy
import Ryo.Check.Lower.Agg

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerFieldWrite (Γ : StmtCtx) : Statement → List Insn → Prop where
  | copy {x a : Local} {oa : Operand} {fe : ProjElem} {fields : List ProjElem} {tx ty : Ty}
      {off n : Nat} {sx sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a) (htx : Γ.body.locals[x]? = some tx)
      (hpath : fieldPath tx (fe :: fields) = some (off, ty))
      (hta : Γ.body.locals[a]? = some ty) (hwf : ty.wf = true) (hn : ty.size? = some n)
      (hpos : 0 < n) (hsx : Γ.slots[x]? = some sx) (hsa : Γ.slots[a]? = some sa)
      (hin : off + n ≤ sx.size) (hsz : sa.size = n)
      (hoff : offOk (sx.off + off) ∧ offOk sa.off)
      (hpriv : ∀ k < sx.size, Γ.escaped (sx.off + k) = false)
      (hi : movInsnOk Γ i n (sx.off + off) sa.off = true) :
      LowerFieldWrite Γ (.assign ⟨x, fe :: fields⟩ (.use oa)) [i]
  | const {x : Local} {fe : ProjElem} {fields : List ProjElem} {tx : Ty} {t : IntType}
      {vp vc : ValidRange} {bits off : Nat} {sx : LocalSlot} {i : Insn}
      (htx : Γ.body.locals[x]? = some tx)
      (hpath : fieldPath tx (fe :: fields) = some (off, .int t vp))
      (hpos : 0 < t.size) (hsx : Γ.slots[x]? = some sx) (hin : off + t.size ≤ sx.size)
      (hoff : offOk (sx.off + off))
      (hpriv : ∀ k < sx.size, Γ.escaped (sx.off + k) = false)
      (hi : immInsnOk Γ i t.size (sx.off + off) bits = true) :
      LowerFieldWrite Γ (.assign ⟨x, fe :: fields⟩ (.use (.const (.scalar bits) (.int t vc)))) [i]
  | bin {x a b : Local} {oa ob : Operand} {op : BinOp} {m : String} {fe : ProjElem}
      {fields : List ProjElem} {tx : Ty} {t : IntType} {vp va vb : ValidRange} {off : Nat}
      {sx sa sb : LocalSlot} {i : Insn}
      (hm : binMethod op = some m) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htx : Γ.body.locals[x]? = some tx)
      (hpath : fieldPath tx (fe :: fields) = some (off, .int t vp))
      (hta : Γ.body.locals[a]? = some (.int t va)) (htb : Γ.body.locals[b]? = some (.int t vb))
      (hpos : 0 < t.size) (hsx : Γ.slots[x]? = some sx) (hsa : Γ.slots[a]? = some sa)
      (hsb : Γ.slots[b]? = some sb) (hin : off + t.size ≤ sx.size)
      (hsz : sa.size = t.size ∧ sb.size = t.size)
      (hoff : offOk (sx.off + off) ∧ offOk sa.off ∧ offOk sb.off)
      (hpriv : ∀ k < sx.size, Γ.escaped (sx.off + k) = false)
      (hi : binInsnOk Γ i m t.size (sx.off + off) sa.off sb.off = true) :
      LowerFieldWrite Γ (.assign ⟨x, fe :: fields⟩ (.binaryOp op oa ob)) [i]
  | binImm {x a : Local} {oa : Operand} {op : BinOp} {m : String} {fe : ProjElem}
      {fields : List ProjElem} {tx : Ty} {t : IntType} {vp va vc : ValidRange} {bits off : Nat}
      {sx sa : LocalSlot} {i : Insn}
      (hm : binMethod op = some m) (ha : oa.local? = some a)
      (htx : Γ.body.locals[x]? = some tx)
      (hpath : fieldPath tx (fe :: fields) = some (off, .int t vp))
      (hta : Γ.body.locals[a]? = some (.int t va))
      (hpos : 0 < t.size) (hsx : Γ.slots[x]? = some sx) (hsa : Γ.slots[a]? = some sa)
      (hin : off + t.size ≤ sx.size) (hsz : sa.size = t.size)
      (hoff : offOk (sx.off + off) ∧ offOk sa.off)
      (hpriv : ∀ k < sx.size, Γ.escaped (sx.off + k) = false)
      (hi : binImmInsnOk Γ i m t.size (sx.off + off) sa.off bits = true) :
      LowerFieldWrite Γ (.assign ⟨x, fe :: fields⟩
        (.binaryOp op oa (.const (.scalar bits) (.int t vc)))) [i]

/-- An integer field of a local, inside its private slot: offset, type and slot. -/
def fieldIntPlace (Γ : StmtCtx) (x : Local) (fe : ProjElem) (fields : List ProjElem) :
    Option (Nat × IntType × LocalSlot) :=
  match Γ.body.locals[x]? with
  | some tx =>
    match fieldPath tx (fe :: fields), Γ.slots[x]? with
    | some (off, .int t _), some sx =>
      if decide (0 < t.size) && decide (off + t.size ≤ sx.size) && offOk (sx.off + off) &&
        privOk Γ sx.off sx.size then some (off, t, sx) else none
    | _, _ => none
  | none => none

theorem fieldIntPlace_spec {Γ : StmtCtx} {x : Local} {fe : ProjElem} {fields : List ProjElem}
    {off : Nat} {t : IntType} {sx : LocalSlot}
    (h : fieldIntPlace Γ x fe fields = some (off, t, sx)) :
    ∃ tx vp, Γ.body.locals[x]? = some tx ∧ fieldPath tx (fe :: fields) = some (off, .int t vp) ∧
      Γ.slots[x]? = some sx ∧ 0 < t.size ∧ off + t.size ≤ sx.size ∧
      offOk (sx.off + off) = true ∧ ∀ k < sx.size, Γ.escaped (sx.off + k) = false := by
  unfold fieldIntPlace at h
  split at h
  next tx htx =>
    split at h
    next off' t' vp sx' hpath hsx =>
      split at h
      next hc =>
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hc
        obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hc
        cases h
        exact ⟨tx, vp, htx, hpath, hsx, h1, h2, h3, privOk_spec h4⟩
      · cases h
    · cases h
  · cases h

/-- `bin`'s checker. -/
def checkFieldWriteBin (Γ : StmtCtx) (x : Local) (fe : ProjElem) (fields : List ProjElem)
    (m : String) (a b : Local) (is : List Insn) : Verdict :=
  match fieldIntPlace Γ x fe fields with
  | none => .unsupported "field write binop: place"
  | some (off, t, sx) =>
    match Γ.body.locals[a]?, Γ.body.locals[b]?, Γ.slots[a]?, Γ.slots[b]?, is with
    | some (.int ta _), some (.int tb _), some sa, some sb, [i] =>
      if !(decide (ta = t) && decide (tb = t)) then .unsupported "field write binop: types"
      else if !(sa.size == t.size && sb.size == t.size) then
        .rejected "field write binop: slot sizes"
      else if !(offOk sa.off && offOk sb.off) then .rejected "field write binop: offsets"
      else if binInsnOk Γ i m t.size (sx.off + off) sa.off sb.off then .ok
      else .unsupported "field write binop: instruction form"
    | _, _, _, _, _ => .unsupported "field write binop: operands, slots or instruction count"

/-- `binImm`'s checker. -/
def checkFieldWriteBinImm (Γ : StmtCtx) (x : Local) (fe : ProjElem) (fields : List ProjElem)
    (m : String) (a : Local) (bits : Nat) (tc : IntType) (is : List Insn) : Verdict :=
  match fieldIntPlace Γ x fe fields with
  | none => .unsupported "field write binop: place"
  | some (off, t, sx) =>
    match Γ.body.locals[a]?, Γ.slots[a]?, is with
    | some (.int ta _), some sa, [i] =>
      if !(decide (ta = t) && decide (tc = t)) then .unsupported "field write binop: types"
      else if sa.size ≠ t.size then .rejected "field write binop: slot sizes"
      else if !offOk sa.off then .rejected "field write binop: offsets"
      else if binImmInsnOk Γ i m t.size (sx.off + off) sa.off bits then .ok
      else .unsupported "field write binop: instruction form"
    | _, _, _ => .unsupported "field write binop: operand, slots or instruction count"

/-- `copy`'s checker. -/
def checkFieldWriteCopy (Γ : StmtCtx) (x a : Local) (fe : ProjElem) (fields : List ProjElem)
    (is : List Insn) : Verdict :=
  match Γ.body.locals[x]? with
  | none => .rejected "field write: no destination local"
  | some tx =>
    match fieldPath tx (fe :: fields) with
    | none => .unsupported "field write: place"
    | some (off, ty) =>
      match Γ.body.locals[a]?, ty.size?, Γ.slots[x]?, Γ.slots[a]?, is with
      | some ta, some n, some sx, some sa, [i] =>
        if ta ≠ ty then .unsupported "field write: types"
        else if !(ty.wf && decide (0 < n)) then .unsupported "field write: type"
        else if !(decide (off + n ≤ sx.size) && sa.size == n) then .rejected "field write: slot sizes"
        else if !(offOk (sx.off + off) && offOk sa.off) then .rejected "field write: offsets"
        else if !privOk Γ sx.off sx.size then .unsupported "field write: escaped destination"
        else if movInsnOk Γ i n (sx.off + off) sa.off then .ok
        else .unsupported "field write: instruction form"
      | _, _, _, _, _ => .unsupported "field write: operand, slots or instruction count"

/-- `const`'s checker. -/
def checkFieldWriteConst (Γ : StmtCtx) (x : Local) (fe : ProjElem) (fields : List ProjElem)
    (bits : Nat) (tc : IntType) (is : List Insn) : Verdict :=
  match Γ.body.locals[x]? with
  | none => .rejected "field write: no destination local"
  | some tx =>
    match fieldPath tx (fe :: fields) with
    | some (off, .int t _) =>
      match Γ.slots[x]?, is with
      | some sx, [i] =>
        if tc ≠ t then .unsupported "field write const: types"
        else if !(decide (0 < t.size) && decide (off + t.size ≤ sx.size)) then
          .rejected "field write const: slot size"
        else if !offOk (sx.off + off) then .rejected "field write const: offsets"
        else if !privOk Γ sx.off sx.size then .unsupported "field write: escaped destination"
        else if immInsnOk Γ i t.size (sx.off + off) bits then .ok
        else .unsupported "field write const: instruction form"
      | _, _ => .unsupported "field write const: slots or instruction count"
    | some _ => .unsupported "field write const: not an integer field"
    | none => .unsupported "field write: place"

/-- The family's checker: `none` unless `st` writes a whole local or an integer constant to a
place `_x.f₁.….fₖ` with only field projections. -/
def checkFieldWrite (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨x, (.field f ann) :: fields⟩ (.use (.const (.scalar bits) (.int tc _))) =>
    some (checkFieldWriteConst Γ x (.field f ann) fields bits tc is)
  | .assign ⟨x, (.field f ann) :: fields⟩ (.use oa) =>
    match oa.local? with
    | some a => some (checkFieldWriteCopy Γ x a (.field f ann) fields is)
    | none => none
  | .assign ⟨x, (.field f ann) :: fields⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc _))) =>
    match binMethod op, oa.local? with
    | some m, some a => some (checkFieldWriteBinImm Γ x (.field f ann) fields m a bits tc is)
    | _, _ => none
  | .assign ⟨x, (.field f ann) :: fields⟩ (.binaryOp op oa ob) =>
    match binMethod op, oa.local?, ob.local? with
    | some m, some a, some b => some (checkFieldWriteBin Γ x (.field f ann) fields m a b is)
    | _, _, _ => none
  | _ => none

theorem checkFieldWriteCopy_sound {Γ : StmtCtx} {x a : Local} {oa : Operand} {fe : ProjElem}
    {fields : List ProjElem} {is : List Insn} (ha : oa.local? = some a)
    (h : checkFieldWriteCopy Γ x a fe fields is = .ok) :
    LowerFieldWrite Γ (.assign ⟨x, fe :: fields⟩ (.use oa)) is := by
  unfold checkFieldWriteCopy at h
  split at h
  · cases h
  next tx htx =>
    split at h
    · cases h
    next off ty hpath =>
      split at h
      next ta n sx sa i hta hn hsx hsa =>
        split at h
        · cases h
        next hty =>
          have e : ta = ty := by simpa using hty
          rw [e] at hta
          split at h
          · cases h
          next hwf =>
            have hwf0 : ty.wf = true ∧ ¬ n = 0 := by simpa using hwf
            have hwf' : ty.wf = true ∧ 0 < n := ⟨hwf0.1, Nat.pos_of_ne_zero hwf0.2⟩
            split at h
            · cases h
            next hsz =>
              have hsz' : off + n ≤ sx.size ∧ sa.size = n := by simpa using hsz
              split at h
              · cases h
              next hoff =>
                split at h
                · cases h
                next hpriv =>
                  split at h
                  next hi =>
                    exact .copy ha htx hpath hta hwf'.1 hn hwf'.2 hsx hsa hsz'.1 hsz'.2
                      (by simpa using hoff) (privOk_spec (by simpa using hpriv)) hi
                  · cases h
      · cases h

theorem checkFieldWriteConst_sound {Γ : StmtCtx} {x : Local} {fe : ProjElem}
    {fields : List ProjElem} {bits : Nat} {tc : IntType} {vc : ValidRange} {is : List Insn}
    (h : checkFieldWriteConst Γ x fe fields bits tc is = .ok) :
    LowerFieldWrite Γ (.assign ⟨x, fe :: fields⟩ (.use (.const (.scalar bits) (.int tc vc))))
      is := by
  unfold checkFieldWriteConst at h
  split at h
  · cases h
  next tx htx =>
    split at h
    next off t vp hpath =>
      split at h
      next sx i hsx =>
        split at h
        · cases h
        next htc =>
          have e : tc = t := by simpa using htc
          rw [e]
          split at h
          · cases h
          next hsz =>
            have hsz0 : ¬ t.size = 0 ∧ off + t.size ≤ sx.size := by simpa using hsz
            have hsz' : 0 < t.size ∧ off + t.size ≤ sx.size :=
              ⟨Nat.pos_of_ne_zero hsz0.1, hsz0.2⟩
            split at h
            · cases h
            next hoff =>
              split at h
              · cases h
              next hpriv =>
                split at h
                next hi =>
                  exact .const htx hpath hsz'.1 hsx hsz'.2 (by simpa using hoff)
                    (privOk_spec (by simpa using hpriv)) hi
                · cases h
      · cases h
    all_goals cases h

theorem checkFieldWriteBin_sound {Γ : StmtCtx} {x a b : Local} {oa ob : Operand} {op : BinOp}
    {m : String} {fe : ProjElem} {fields : List ProjElem} {is : List Insn}
    (hm : binMethod op = some m) (ha : oa.local? = some a) (hb : ob.local? = some b)
    (h : checkFieldWriteBin Γ x fe fields m a b is = .ok) :
    LowerFieldWrite Γ (.assign ⟨x, fe :: fields⟩ (.binaryOp op oa ob)) is := by
  unfold checkFieldWriteBin at h
  split at h
  · cases h
  next off t sx hpl =>
    obtain ⟨tx, vp, htx, hpath, hsx, hpos, hin, hoffx, hpriv⟩ := fieldIntPlace_spec hpl
    split at h
    next ta va tb vb sa sb i hta htb hsa hsb =>
      split at h
      · cases h
      next hty =>
        have hty' : ta = t ∧ tb = t := by simpa using hty
        rw [hty'.1] at hta
        rw [hty'.2] at htb
        split at h
        · cases h
        next hsz =>
          split at h
          · cases h
          next hoab =>
            split at h
            next hi =>
              exact .bin hm ha hb htx hpath hta htb hpos hsx hsa hsb hin (by simpa using hsz)
                ⟨hoffx, by simpa using hoab⟩ hpriv hi
            · cases h
    · cases h

theorem checkFieldWriteBinImm_sound {Γ : StmtCtx} {x a : Local} {oa : Operand} {op : BinOp}
    {m : String} {fe : ProjElem} {fields : List ProjElem} {bits : Nat} {tc : IntType}
    {vc : ValidRange} {is : List Insn}
    (hm : binMethod op = some m) (ha : oa.local? = some a)
    (h : checkFieldWriteBinImm Γ x fe fields m a bits tc is = .ok) :
    LowerFieldWrite Γ (.assign ⟨x, fe :: fields⟩
      (.binaryOp op oa (.const (.scalar bits) (.int tc vc)))) is := by
  unfold checkFieldWriteBinImm at h
  split at h
  · cases h
  next off t sx hpl =>
    obtain ⟨tx, vp, htx, hpath, hsx, hpos, hin, hoffx, hpriv⟩ := fieldIntPlace_spec hpl
    split at h
    next ta va sa i hta hsa =>
      split at h
      · cases h
      next hty =>
        have hty' : ta = t ∧ tc = t := by simpa using hty
        rw [hty'.1] at hta
        rw [hty'.2]
        split at h
        · cases h
        next hsz =>
          split at h
          · cases h
          next hoa =>
            split at h
            next hi =>
              exact .binImm hm ha htx hpath hta hpos hsx hsa hin (by simpa using hsz)
                ⟨hoffx, by simpa using hoa⟩ hpriv hi
            · cases h
    · cases h

theorem checkFieldWrite_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkFieldWrite Γ st is = some .ok) : LowerFieldWrite Γ st is := by
  unfold checkFieldWrite at h
  split at h
  next x f ann fields bits tc vc => exact checkFieldWriteConst_sound (Option.some.inj h)
  next x f ann fields oa =>
    split at h
    next a ha => exact checkFieldWriteCopy_sound ha (Option.some.inj h)
    · cases h
  next x f ann fields op oa bits tc vc =>
    split at h
    next m a hm ha => exact checkFieldWriteBinImm_sound hm ha (Option.some.inj h)
    · cases h
  next x f ann fields op oa ob =>
    split at h
    next m a b hm ha hb => exact checkFieldWriteBin_sound hm ha hb (Option.some.inj h)
    · cases h
  · cases h

/-! ### Copies in pieces -/

/-- A copy of a whole local into a field whose size is not a `mov` width: `copy_val`'s `mov`
pieces (`Split::Pieces`) into the field's bytes, stated as `Agg.lean`'s one field of the
"slot" `⟨sx.off + off, n⟩` (`AggField`, `srcPieces`). -/
inductive LowerFieldCopyN (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk {x a : Local} {oa : Operand} {fe : ProjElem} {fields : List ProjElem} {tx ty : Ty}
      {off n : Nat} {sx : LocalSlot} {so : Int} {ws : List Nat} {is : List Insn}
      (htx : Γ.body.locals[x]? = some tx)
      (hpath : fieldPath tx (fe :: fields) = some (off, ty)) (hn : ty.size? = some n)
      (hsx : Γ.slots[x]? = some sx) (hin : off + n ≤ sx.size)
      (hoff : offOk (sx.off + off) ∧ offOk (sx.off + off + n))
      (hpriv : ∀ k < sx.size, Γ.escaped (sx.off + k) = false)
      (hf : AggField Γ ⟨sx.off + off, n⟩ oa 0 ty (.slot a so ws))
      (hi : piecesOk Γ is (srcPieces (sx.off + off) (.slot a so ws)) = true) :
      LowerFieldCopyN Γ (.assign ⟨x, fe :: fields⟩ (.use oa)) is

/-- The field's size is known and not a `mov` width (`LowerFieldWrite.copy`'s otherwise). -/
def fieldCopyMulti (Γ : StmtCtx) (x : Local) (fe : ProjElem) (fields : List ProjElem) : Bool :=
  match Γ.body.locals[x]? with
  | some tx =>
    match fieldPath tx (fe :: fields) with
    | some (_, ty) =>
      match ty.size? with
      | some n => !movWidth n
      | none => false
    | none => false
  | none => false

/-- `LowerFieldCopyN.mk`'s checker. -/
def checkFieldCopyNBody (Γ : StmtCtx) (x : Local) (oa : Operand) (fe : ProjElem)
    (fields : List ProjElem) (is : List Insn) : Verdict :=
  match Γ.body.locals[x]?, Γ.slots[x]? with
  | some tx, some sx =>
    match fieldPath tx (fe :: fields) with
    | none => .unsupported "field copy: place"
    | some (off, ty) =>
      match ty.size? with
      | none => .unsupported "field copy: unsized"
      | some n =>
        if !decide (off + n ≤ sx.size) then .rejected "field copy: slot size"
        else if !(offOk (sx.off + off) && offOk (sx.off + off + n)) then
          .rejected "field copy: offsets"
        else if !privOk Γ sx.off sx.size then .unsupported "field copy: escaped destination"
        else match guessSrc Γ "field copy" (sx.off + off) oa ty is with
          | .error why => .unsupported why
          | .ok g =>
            match g.1 with
            | .slot a so ws =>
              if !aggFieldOk Γ ⟨sx.off + off, n⟩ oa 0 ty (.slot a so ws) then
                .unsupported "field copy: operand"
              else if piecesOk Γ is (srcPieces (sx.off + off) (.slot a so ws)) then .ok
              else .unsupported "field copy: instruction form"
            | _ => .unsupported "field copy: source"
  | _, _ => .unsupported "field copy: destination"

/-- The family's checker: `none` unless `st` copies a whole local into a field of a local whose
size is not a `mov` width. Run before `checkFieldWrite`. -/
def checkFieldCopyN (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨x, (.field f ann) :: fields⟩ (.use oa) =>
    if oa.local?.isSome && fieldCopyMulti Γ x (.field f ann) fields then
      some (checkFieldCopyNBody Γ x oa (.field f ann) fields is)
    else none
  | _ => none

theorem checkFieldCopyNBody_sound {Γ : StmtCtx} {x : Local} {oa : Operand} {fe : ProjElem}
    {fields : List ProjElem} {is : List Insn}
    (h : checkFieldCopyNBody Γ x oa fe fields is = .ok) :
    LowerFieldCopyN Γ (.assign ⟨x, fe :: fields⟩ (.use oa)) is := by
  unfold checkFieldCopyNBody at h
  split at h
  next tx sx htx hsx =>
    split at h
    · cases h
    next off ty hpath =>
      split at h
      · cases h
      next n hn =>
        split at h
        · cases h
        next hin =>
          split at h
          · cases h
          next hoff =>
            split at h
            · cases h
            next hpriv =>
              split at h
              · cases h
              next g =>
                split at h
                next a so ws _ =>
                  split at h
                  · cases h
                  next hf =>
                    split at h
                    next hi =>
                      exact .mk htx hpath hn hsx (by simpa using hin) (by simpa using hoff)
                        (privOk_spec (by simpa using hpriv)) (aggFieldOk_spec (by simpa using hf))
                        hi
                    · cases h
                all_goals cases h
  · cases h

theorem checkFieldCopyN_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkFieldCopyN Γ st is = some .ok) : LowerFieldCopyN Γ st is := by
  unfold checkFieldCopyN at h
  split at h
  next x f ann fields oa =>
    split at h
    · exact checkFieldCopyNBody_sound (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
