/-
Ryo.Check.Lower.Enum — the lowering rules for enums held in whole locals (aot.md §C1, M5b): reading
a discriminant, reading a field of a variant, writing a tag, building a variant. And their
checkers.

L0's enums (`Ryo.Spec.Lang.Types`, `Representation`): an enum type is
`.enum vs discrTy repr size align`, `repr` rustc's `Variants`: `.single idx` (no tag in memory),
`.multiple tag` (the tag's integer type `tag.tag` at `tag.offset`, `.direct` or `.niche`
encoded), `.empty`. `readDiscriminant` loads the tag bytes, maps them to a variant
(`tagToVariant`: for `.direct`, the first variant whose `tag.tag.toBits discr` is the tag), and
`discriminant` stores that variant's `discr` brought into `discrTy` then into the destination's
integer type. `writeDiscriminant` stores `tagForVariant`'s bits at the tag's offset, or (for
`.single` and the niche's untagged variant) only checks by a read. A `.downcast v` projection
keeps the pointer and takes variant `v`'s field tuple as the type. An enum aggregate's value is
`.variant v (.tuple vals)`, encoded as the variant's fields over uninitialized bytes with the
tag written last.

What the backend emits (`backend/src/lower/adt.rs`, `place.rs`): `discriminant` of a `Single`
layout is one `imm` of the variant's discriminant; of a `Direct` tag, `int_cast` from the tag's
slot (`mov` at equal widths, else `zext`/`sext`/`trunc` by the tag's signedness); of a `Niche`
tag, several integer instructions (`niche_discr`). `set_discriminant` writes one `imm` of the
tag's width (`imm_into`), nothing for `Single` and the untagged variant, an `abort` for
uninhabited variants. A downcast leaves the location alone; a field is at its offset in the
variant's layout. An enum aggregate is `operand_into` per field at the variant's offsets, then
`set_discriminant`.

Rules (each on whole locals, the written one private in R, as in `Stmt.lean`):
- `LowerEnumRead.discrDirect`: `_d = discriminant(_e)`, `_e` a `.multiple` enum with a `.direct`
  tag, `_d` an integer of type `t`, lowered to one `mov` (equal widths) or `cvt` (the tag type's
  signedness unless it narrows) from `_e`'s slot at the tag offset to `_d`'s slot
  (`tagReadOk`). That R's cast of the tag gives L0's value is checked per variant
  (`discrAgree`: the destination bits of the tag of `discr`, read back at the tag type, are those
  of `discr` brought into `discrTy`), so nothing about rustc's choice of tag type is assumed.
- `LowerEnumRead.discrSingle`: `_d = discriminant(_e)`, `_e` a `.single idx` enum, one `imm`
  of L0's value (`singleDiscr`) into `_d`.
- `LowerEnumRead.downcast`: `_d = copy/move _a.projs`, the projections fields and downcasts
  (`downcastPath`: Field.lean's `fieldPath` with `.downcast v` adding offset 0 and moving to
  variant `v`'s fields), one `mov` from the sub-range, as Field.lean's `field`.
- `LowerSetDiscr.tag`: `SetDiscriminant(_e, v)` with `tagForVariant` bits, one `imm` of the
  tag's width into `_e`'s slot at the tag offset (the range private).
- `LowerSetDiscr.implicit`: `SetDiscriminant(_e, v)` for an implicitly encoded variant
  (`implicitTag`: `.single`, or `tagForVariant` gives nothing), no instruction.
- `LowerEnumAgg.agg`: `_d = aggregate (adt v _) ops` into an enum, as Agg.lean's `agg` over
  the variant's fields (`aggLayout` of its field tuple, which has `_d`'s slot size) followed by
  the tag as one more field (`tagField`: a constant operand of the tag's bits at the tag offset
  and type, so the tag's `imm` is that field's piece; none for implicit variants).

Not covered: niche-encoded discriminant reads (several instructions), discriminants and
`SetDiscriminant` of projected places, empty enums, uninhabited variants (`abort`).

`checkEnum` answers `none` for statements outside the family, and claims downcast reads and
enum aggregates, which `checkField` and `checkAgg` would call unsupported: a dispatcher must try
it before them.
-/
import Ryo.Check.Lower.Field
import Ryo.Check.Lower.IntCast
import Ryo.Check.Lower.Agg

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-! ### Discriminants -/

/-- R's direct-tag read gives L0's discriminant at every variant: the tag of `discr`
(`tag.tag.toBits`), read at the tag type (`ofBits`) and cast to `t`, has the bits of `discr`
brought into `discrTy` (L0 then brings it into `t`, which keeps those bits). -/
def discrAgree (vs : List Variant) (discrTy : IntType) (tag : TagInfo) (t : IntType) : Bool :=
  vs.all fun v =>
    t.toBits (tag.tag.ofBits (tag.tag.toBits v.discr)) == t.toBits (discrTy.bringInBounds v.discr)

theorem discrAgree_spec {vs : List Variant} {discrTy : IntType} {tag : TagInfo} {t : IntType}
    (h : discrAgree vs discrTy tag t = true) :
    ∀ v ∈ vs, t.toBits (tag.tag.ofBits (tag.tag.toBits v.discr)) =
      t.toBits (discrTy.bringInBounds v.discr) := by
  intro v hv
  have := List.all_eq_true.mp h v hv
  simpa using this

/-- An instruction reading `tt.size` tag bytes at slot `s` into an integer of `n` bytes at slot
`d`: a `mov` at equal widths, else a `cvt` (`castInsnOk`, the tag type's signedness). -/
def tagReadOk (Γ : StmtCtx) (i : Insn) (tt : IntType) (n : Nat) (d s : Int) : Bool :=
  (tt.size == n && movInsnOk Γ i n d s) || castInsnOk Γ i tt.size tt.signed n d s

/-- L0's discriminant of a `.single idx` enum, before the destination type. -/
def singleDiscr (vs : List Variant) (discrTy : IntType) (idx : Nat) : Int :=
  discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0)

/-! ### Downcast places -/

/-- The offset and type L0 reaches from `ty` through field and downcast projections: a field
as `fieldOf` covers it, a downcast of an enum to variant `v`'s field tuple at offset 0. -/
def downcastPath : Ty → List ProjElem → Option (Nat × Ty)
  | ty, [] => some (0, ty)
  | ty, .field f _ :: ps =>
    match fieldOf ty f with
    | some (o, fty) =>
      match downcastPath fty ps with
      | some (o', t) => some (o + o', t)
      | none => none
    | none => none
  | .enum vs _ _ _ _, .downcast v :: ps =>
    match vs[v]? with
    | some var => downcastPath var.fields ps
    | none => none
  | _, _ :: _ => none

def isDowncast : ProjElem → Bool
  | .downcast _ => true
  | _ => false

/-- A coverage bucket for projections `downcastPath` does not cover. -/
def downcastWhy : List ProjElem → String
  | [] => "downcast: unsized tail, out of range or not a struct/tuple/union/enum"
  | .field .. :: ps | .downcast _ :: ps => downcastWhy ps
  | .deref _ :: _ => "downcast: deref"
  | .index _ :: _ | .constantIndex .. :: _ | .subslice .. :: _ => "downcast: index"
  | _ :: _ => "downcast: cast projection"

/-! ### Tags -/

/-- The tag's type as an aggregate field: an integer of the tag's type, any bits valid. -/
def enumTagTy (tag : TagInfo) : Ty := .int tag.tag (ValidRange.full tag.tag.size)

/-- Variant `v` is encoded without a tag write (`writeDiscriminant` only checks it). -/
def implicitTag : Ty → Nat → Bool
  | .enum _ _ (.single _) _ _, _ => true
  | .enum vs _ (.multiple tag) _ _, v => (tagForVariant vs tag v).isNone
  | _, _ => false

/-- The tag of variant `v` as extra aggregate fields after the variant's: one constant operand
of the tag bits at the tag's offset and type, or none for an implicitly encoded variant; `none`
when L0 cannot encode `v` (`.empty`, another `.single` variant). -/
def tagField (vs : List Variant) (repr : EnumRepr) (v : Nat) :
    Option (List Operand × List (Nat × Ty)) :=
  match repr with
  | .empty => none
  | .single i => if i = v then some ([], []) else none
  | .multiple tag =>
    match tagForVariant vs tag v with
    | none => some ([], [])
    | some bits => some ([.const (.scalar bits) (enumTagTy tag)], [(tag.offset, enumTagTy tag)])

/-! ### The rules -/

inductive LowerEnumRead (Γ : StmtCtx) : Statement → List Insn → Prop where
  | discrDirect {d e : Local} {vs : List Variant} {discrTy : IntType} {tag : TagInfo}
      {esz : Size} {eal : Align} {t : IntType} {vd : ValidRange} {sd se : LocalSlot} {i : Insn}
      (hte : Γ.body.locals[e]? = some (.enum vs discrTy (.multiple tag) esz eal))
      (henc : tag.encoding = .direct)
      (htd : Γ.body.locals[d]? = some (.int t vd))
      (hagree : discrAgree vs discrTy tag t = true)
      (hsd : Γ.slots[d]? = some sd) (hse : Γ.slots[e]? = some se)
      (hsize : sd.size = t.size ∧ 0 < t.size ∧ 0 < tag.tag.size ∧
        tag.offset + tag.tag.size ≤ se.size)
      (hoff : offOk sd.off ∧ offOk se.off ∧ offOk (se.off + tag.offset))
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : tagReadOk Γ i tag.tag t.size sd.off (se.off + tag.offset) = true) :
      LowerEnumRead Γ (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩)) [i]
  | discrSingle {d e : Local} {vs : List Variant} {discrTy : IntType} {idx : Nat}
      {esz : Size} {eal : Align} {t : IntType} {vd : ValidRange} {sd : LocalSlot} {i : Insn}
      (hte : Γ.body.locals[e]? = some (.enum vs discrTy (.single idx) esz eal))
      (htd : Γ.body.locals[d]? = some (.int t vd))
      (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size ∧ 0 < t.size)
      (hoff : offOk sd.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : immInsnOk Γ i t.size sd.off (t.toBits (singleDiscr vs discrTy idx)) = true) :
      LowerEnumRead Γ (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩)) [i]
  | downcast {d a : Local} {oa : Operand} {projs : List ProjElem} {ta ty : Ty} {off n : Nat}
      {sd sa : LocalSlot} {i : Insn}
      (ha : operandPlace? oa = some ⟨a, projs⟩)
      (hta : Γ.body.locals[a]? = some ta) (hpath : downcastPath ta projs = some (off, ty))
      (htd : Γ.body.locals[d]? = some ty)
      (hn : ty.size? = some n) (hpos : 0 < n) (hwf : ty.wf = true)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = n ∧ off + n ≤ sa.size)
      (hoff : offOk sd.off ∧ offOk (sa.off + off))
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : movInsnOk Γ i n sd.off (sa.off + off) = true) :
      LowerEnumRead Γ (.assign ⟨d, []⟩ (.use oa)) [i]

inductive LowerSetDiscr (Γ : StmtCtx) : Statement → List Insn → Prop where
  | tag {e : Local} {v : Nat} {vs : List Variant} {discrTy : IntType} {tag : TagInfo}
      {esz : Size} {eal : Align} {bits : Nat} {se : LocalSlot} {i : Insn}
      (hte : Γ.body.locals[e]? = some (.enum vs discrTy (.multiple tag) esz eal))
      (hbits : tagForVariant vs tag v = some bits)
      (hse : Γ.slots[e]? = some se)
      (hsize : 0 < tag.tag.size ∧ tag.offset + tag.tag.size ≤ se.size)
      (hoff : offOk se.off ∧ offOk (se.off + tag.offset))
      (hpriv : ∀ k < tag.tag.size, Γ.escaped (se.off + tag.offset + k) = false)
      (hi : immInsnOk Γ i tag.tag.size (se.off + tag.offset) bits = true) :
      LowerSetDiscr Γ (.setDiscriminant ⟨e, []⟩ v) [i]
  | implicit {e : Local} {v : Nat} {ty : Ty}
      (hte : Γ.body.locals[e]? = some ty) (himp : implicitTag ty v = true) :
      LowerSetDiscr Γ (.setDiscriminant ⟨e, []⟩ v) []

inductive LowerEnumAgg (Γ : StmtCtx) : Statement → List Insn → Prop where
  | agg {d : Local} {v : Nat} {act : Option Nat} {ops : List Operand} {vs : List Variant}
      {discrTy : IntType} {repr : EnumRepr} {esz : Size} {eal : Align} {var : Variant}
      {vfields : List (Nat × Ty)} {tops : List Operand} {tfs : List (Nat × Ty)}
      {sd : LocalSlot} {srcs : List AggSrc} {is : List Insn}
      (htd : Γ.body.locals[d]? = some (.enum vs discrTy repr esz eal))
      (hvar : vs[v]? = some var) (hlay : aggLayout var.fields = some vfields)
      (htag : tagField vs repr v = some (tops, tfs))
      (hsz : var.fields.size? = some sd.size) (hsd : Γ.slots[d]? = some sd)
      (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
      (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
      (hf : AggFields Γ sd (ops ++ tops) (vfields ++ tfs) srcs)
      (hi : piecesOk Γ is (aggPieces sd.off (vfields ++ tfs) srcs) = true) :
      LowerEnumAgg Γ (.assign ⟨d, []⟩ (.aggregate (.adt v act) ops)) is

/-- The family: reads (one instruction), tag writes (one or none), aggregates (several). -/
inductive LowerEnum (Γ : StmtCtx) (st : Statement) (is : List Insn) : Prop where
  | read (h : LowerEnumRead Γ st is)
  | setDiscr (h : LowerSetDiscr Γ st is)
  | agg (h : LowerEnumAgg Γ st is)

/-! ### Checkers: discriminants -/

def checkDiscrDirect (Γ : StmtCtx) (d e : Local) (vs : List Variant) (discrTy : IntType)
    (tag : TagInfo) (t : IntType) (is : List Insn) : Verdict :=
  if !discrAgree vs discrTy tag t then .unsupported "discriminant: tag cast differs from L0's"
  else match Γ.slots[d]?, Γ.slots[e]?, is with
    | some sd, some se, [i] =>
      if !(sd.size == t.size && (decide (0 < t.size) && (decide (0 < tag.tag.size) &&
          decide (tag.offset + tag.tag.size ≤ se.size)))) then
        .rejected "discriminant: slot sizes"
      else if !(offOk sd.off && (offOk se.off && offOk (se.off + tag.offset))) then
        .rejected "discriminant: offsets"
      else if !privOk Γ sd.off sd.size then .unsupported "discriminant: escaped destination"
      else if tagReadOk Γ i tag.tag t.size sd.off (se.off + tag.offset) then .ok
      else .unsupported "discriminant: instruction form"
    | _, _, _ => .unsupported "discriminant: slots or instruction count"

theorem checkDiscrDirect_sound {Γ : StmtCtx} {d e : Local} {vs : List Variant}
    {discrTy : IntType} {tag : TagInfo} {esz : Size} {eal : Align} {t : IntType}
    {vd : ValidRange} {is : List Insn}
    (hte : Γ.body.locals[e]? = some (.enum vs discrTy (.multiple tag) esz eal))
    (henc : tag.encoding = .direct) (htd : Γ.body.locals[d]? = some (.int t vd))
    (h : checkDiscrDirect Γ d e vs discrTy tag t is = .ok) :
    LowerEnumRead Γ (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩)) is := by
  unfold checkDiscrDirect at h
  split at h
  · cases h
  next hag =>
    split at h
    next sd se i hsd hse =>
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
              have hsz' : sd.size = t.size ∧ ¬t.size = 0 ∧ ¬tag.tag.size = 0 ∧
                  tag.offset + tag.tag.size ≤ se.size := by simpa using hsz
              exact .discrDirect hte henc htd (by simpa using hag) hsd hse
                ⟨hsz'.1, Nat.pos_of_ne_zero hsz'.2.1, Nat.pos_of_ne_zero hsz'.2.2.1, hsz'.2.2.2⟩
                (by simpa using hoff) (privOk_spec (by simpa using hpriv)) hi
            · cases h
    · cases h

def checkDiscrSingle (Γ : StmtCtx) (d : Local) (vs : List Variant) (discrTy : IntType)
    (idx : Nat) (t : IntType) (is : List Insn) : Verdict :=
  match Γ.slots[d]?, is with
  | some sd, [i] =>
    if !(sd.size == t.size && decide (0 < t.size)) then .rejected "discriminant: slot size"
    else if !offOk sd.off then .rejected "discriminant: offset"
    else if !privOk Γ sd.off sd.size then .unsupported "discriminant: escaped destination"
    else if immInsnOk Γ i t.size sd.off (t.toBits (singleDiscr vs discrTy idx)) then .ok
    else .unsupported "discriminant: single-variant instruction form"
  | _, _ => .unsupported "discriminant: slot or instruction count"

theorem checkDiscrSingle_sound {Γ : StmtCtx} {d e : Local} {vs : List Variant}
    {discrTy : IntType} {idx : Nat} {esz : Size} {eal : Align} {t : IntType}
    {vd : ValidRange} {is : List Insn}
    (hte : Γ.body.locals[e]? = some (.enum vs discrTy (.single idx) esz eal))
    (htd : Γ.body.locals[d]? = some (.int t vd))
    (h : checkDiscrSingle Γ d vs discrTy idx t is = .ok) :
    LowerEnumRead Γ (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩)) is := by
  unfold checkDiscrSingle at h
  split at h
  next sd i hsd =>
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
            have hsz' : sd.size = t.size ∧ ¬t.size = 0 := by simpa using hsz
            exact .discrSingle hte htd hsd ⟨hsz'.1, Nat.pos_of_ne_zero hsz'.2⟩
              (by simpa using hoff)
              (privOk_spec (by simpa using hpriv)) hi
          · cases h
  · cases h

/-- `_d = discriminant(_e)` of whole locals. -/
def checkDiscr (Γ : StmtCtx) (d e : Local) (is : List Insn) : Verdict :=
  match Γ.body.locals[e]?, Γ.body.locals[d]? with
  | some (.enum vs discrTy repr _ _), some (.int t _) =>
    match repr with
    | .multiple tag =>
      match tag.encoding with
      | .direct => checkDiscrDirect Γ d e vs discrTy tag t is
      | .niche .. => .unsupported "discriminant: niche encoding"
    | .single idx => checkDiscrSingle Γ d vs discrTy idx t is
    | .empty => .unsupported "discriminant: empty enum"
  | some (.enum ..), _ => .unsupported "discriminant: destination not an integer"
  | some _, _ => .unsupported "discriminant: not an enum"
  | none, _ => .rejected "discriminant: no source local"

theorem checkDiscr_sound {Γ : StmtCtx} {d e : Local} {is : List Insn}
    (h : checkDiscr Γ d e is = .ok) :
    LowerEnumRead Γ (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩)) is := by
  unfold checkDiscr at h
  split at h
  next vs discrTy repr esz eal t vd hte htd =>
    split at h
    next tag =>
      split at h
      next henc => exact checkDiscrDirect_sound hte henc htd h
      next => cases h
    next idx => exact checkDiscrSingle_sound hte htd h
    next => cases h
  all_goals cases h

/-! ### Checkers: downcast reads -/

/-- `downcast`'s checker for `_d = copy/move _a.projs` (as `checkFieldUse`). -/
def checkDowncastUse (Γ : StmtCtx) (d a : Local) (projs : List ProjElem) (is : List Insn) :
    Verdict :=
  match Γ.body.locals[a]? with
  | none => .rejected "downcast: no source local"
  | some ta =>
    match downcastPath ta projs with
    | none => .unsupported (downcastWhy projs)
    | some (off, ty) =>
      match Γ.body.locals[d]? with
      | none => .rejected "downcast: no destination local"
      | some td =>
        if td != ty then .unsupported "downcast: types"
        else match ty.size? with
          | none => .unsupported "downcast: unsized"
          | some n =>
            if n = 0 then .unsupported "downcast: zero-sized"
            else if !ty.wf then .rejected "downcast: ill-formed type"
            else match Γ.slots[d]?, Γ.slots[a]?, is with
              | some sd, some sa, [i] =>
                if !(sd.size == n && decide (off + n ≤ sa.size)) then
                  .rejected "downcast: slot sizes"
                else if !(offOk sd.off && offOk (sa.off + off)) then
                  .rejected "downcast: offsets"
                else if !privOk Γ sd.off sd.size then
                  .unsupported "downcast: escaped destination"
                else if movInsnOk Γ i n sd.off (sa.off + off) then .ok
                else .unsupported "downcast: instruction form"
              | _, _, _ => .unsupported "downcast: slots or instruction count"

theorem checkDowncastUse_sound {Γ : StmtCtx} {d a : Local} {oa : Operand}
    {projs : List ProjElem} {is : List Insn} (ha : operandPlace? oa = some ⟨a, projs⟩)
    (h : checkDowncastUse Γ d a projs is = .ok) :
    LowerEnumRead Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkDowncastUse at h
  split at h
  · cases h
  next ta hta =>
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
                next sd sa i hsd hsa =>
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
                          exact .downcast ha hta hpath htd hn (Nat.pos_of_ne_zero hn0) hwf' hsd
                            hsa (by simpa using hsz) (by simpa using hoff)
                            (privOk_spec (by simpa using hpriv)) hi
                        · cases h
                · cases h

/-- `_d = copy/move p` with a downcast among `p`'s projections. -/
def checkDowncastOp (Γ : StmtCtx) (d : Local) (oa : Operand) (is : List Insn) :
    Option Verdict :=
  match operandPlace? oa with
  | some p =>
    if p.proj.any isDowncast then some (checkDowncastUse Γ d p.base p.proj is) else none
  | none => none

theorem checkDowncastOp_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {is : List Insn}
    (h : checkDowncastOp Γ d oa is = some .ok) :
    LowerEnumRead Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkDowncastOp at h
  split at h
  next p hp =>
    split at h
    · exact checkDowncastUse_sound (a := p.base) (projs := p.proj) hp (Option.some.inj h)
    · cases h
  · cases h

/-! ### Checkers: tag writes -/

def checkSetTag (Γ : StmtCtx) (e : Local) (tag : TagInfo) (bits : Nat) (is : List Insn) :
    Verdict :=
  match Γ.slots[e]?, is with
  | some se, [i] =>
    if !(decide (0 < tag.tag.size) && decide (tag.offset + tag.tag.size ≤ se.size)) then
      .rejected "set discriminant: slot size"
    else if !(offOk se.off && offOk (se.off + tag.offset)) then
      .rejected "set discriminant: offsets"
    else if !privOk Γ (se.off + tag.offset) tag.tag.size then
      .unsupported "set discriminant: escaped local"
    else if immInsnOk Γ i tag.tag.size (se.off + tag.offset) bits then .ok
    else .unsupported "set discriminant: instruction form"
  | _, _ => .unsupported "set discriminant: slot or instruction count"

theorem checkSetTag_sound {Γ : StmtCtx} {e : Local} {v : Nat} {vs : List Variant}
    {discrTy : IntType} {tag : TagInfo} {esz : Size} {eal : Align} {bits : Nat}
    {is : List Insn}
    (hte : Γ.body.locals[e]? = some (.enum vs discrTy (.multiple tag) esz eal))
    (hbits : tagForVariant vs tag v = some bits)
    (h : checkSetTag Γ e tag bits is = .ok) :
    LowerSetDiscr Γ (.setDiscriminant ⟨e, []⟩ v) is := by
  unfold checkSetTag at h
  split at h
  next se i hse =>
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
            have hsz' : ¬tag.tag.size = 0 ∧ tag.offset + tag.tag.size ≤ se.size := by
              simpa using hsz
            exact .tag hte hbits hse ⟨Nat.pos_of_ne_zero hsz'.1, hsz'.2⟩
              (by simpa using hoff)
              (privOk_spec (by simpa using hpriv)) hi
          · cases h
  · cases h

/-- `SetDiscriminant(_e, v)` of a whole local. -/
def checkSetDiscr (Γ : StmtCtx) (e : Local) (v : Nat) (is : List Insn) : Verdict :=
  match Γ.body.locals[e]? with
  | none => .rejected "set discriminant: no local"
  | some ty =>
    if implicitTag ty v then
      match is with
      | [] => .ok
      | _ :: _ => .unsupported "set discriminant: implicit variant with code"
    else match ty with
      | .enum vs discrTy (.multiple tag) esz eal =>
        match tagForVariant vs tag v with
        | some bits => checkSetTag Γ e tag bits is
        | none => .unsupported "set discriminant: implicit variant"
      | _ => .unsupported "set discriminant: not a tagged enum"

theorem checkSetDiscr_sound {Γ : StmtCtx} {e : Local} {v : Nat} {is : List Insn}
    (h : checkSetDiscr Γ e v is = .ok) : LowerSetDiscr Γ (.setDiscriminant ⟨e, []⟩ v) is := by
  unfold checkSetDiscr at h
  split at h
  · cases h
  next ty hte =>
    split at h
    next himp =>
      split at h
      · exact .implicit hte himp
      · cases h
    next =>
      split at h
      next vs discrTy tag esz eal =>
        split at h
        next bits hbits => exact checkSetTag_sound hte hbits h
        next => cases h
      next => cases h

/-! ### Checkers: aggregates -/

def checkEnumAgg (Γ : StmtCtx) (d : Local) (vs : List Variant) (repr : EnumRepr) (v : Nat)
    (ops : List Operand) (is : List Insn) : Verdict :=
  match vs[v]? with
  | none => .rejected "enum aggregate: variant out of range"
  | some var =>
    match aggLayout var.fields with
    | none => .unsupported "enum aggregate: variant layout"
    | some vfields =>
      match tagField vs repr v with
      | none => .unsupported "enum aggregate: empty enum or other single variant"
      | some (tops, tfs) =>
        match Γ.slots[d]? with
        | none => .rejected "enum aggregate: no destination slot"
        | some sd =>
          if var.fields.size? ≠ some sd.size then .rejected "enum aggregate: slot size"
          else if !(offOk sd.off && offOk (sd.off + sd.size)) then
            .rejected "enum aggregate: offsets"
          else if !privOk Γ sd.off sd.size then
            .unsupported "enum aggregate: escaped destination"
          else match guessSrcs Γ sd.off (ops ++ tops) (vfields ++ tfs) is with
            | .error why => .unsupported why
            | .ok srcs =>
              if !aggFieldsOk Γ sd (ops ++ tops) (vfields ++ tfs) srcs then
                .unsupported "enum aggregate: field operands"
              else if piecesOk Γ is (aggPieces sd.off (vfields ++ tfs) srcs) then .ok
              else .unsupported "enum aggregate: instruction form"

theorem checkEnumAgg_sound {Γ : StmtCtx} {d : Local} {vs : List Variant} {discrTy : IntType}
    {repr : EnumRepr} {esz : Size} {eal : Align} {v : Nat} {act : Option Nat}
    {ops : List Operand} {is : List Insn}
    (htd : Γ.body.locals[d]? = some (.enum vs discrTy repr esz eal))
    (h : checkEnumAgg Γ d vs repr v ops is = .ok) :
    LowerEnumAgg Γ (.assign ⟨d, []⟩ (.aggregate (.adt v act) ops)) is := by
  unfold checkEnumAgg at h
  split at h
  · cases h
  next var hvar =>
    split at h
    · cases h
    next vfields hlay =>
      split at h
      · cases h
      next tops tfs htag =>
        split at h
        · cases h
        next sd hsd =>
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
                · cases h
                next srcs _ =>
                  split at h
                  · cases h
                  next hf =>
                    split at h
                    next hi =>
                      exact .agg htd hvar hlay htag (by simpa using hsz) hsd
                        (by simpa using hoff) (privOk_spec (by simpa using hpriv))
                        (aggFieldsOk_spec (by simpa using hf)) hi
                    · cases h

/-- `_d = aggregate (adt v _) ops` when `_d` is an enum. -/
def checkEnumAggAt (Γ : StmtCtx) (d : Local) (v : Nat) (ops : List Operand) (is : List Insn) :
    Option Verdict :=
  match Γ.body.locals[d]? with
  | some (.enum vs _ repr _ _) => some (checkEnumAgg Γ d vs repr v ops is)
  | _ => none

theorem checkEnumAggAt_sound {Γ : StmtCtx} {d : Local} {v : Nat} {act : Option Nat}
    {ops : List Operand} {is : List Insn} (h : checkEnumAggAt Γ d v ops is = some .ok) :
    LowerEnumAgg Γ (.assign ⟨d, []⟩ (.aggregate (.adt v act) ops)) is := by
  unfold checkEnumAggAt at h
  split at h
  next vs discrTy repr esz eal htd => exact checkEnumAgg_sound htd (Option.some.inj h)
  next => cases h

/-! ### The family's checker -/

/-- An assignment to a whole local `_d`. -/
def checkEnumRv (Γ : StmtCtx) (d : Local) (rv : Rvalue) (is : List Insn) : Option Verdict :=
  match rv with
  | .discriminant ⟨e, []⟩ => some (checkDiscr Γ d e is)
  | .discriminant _ => some (.unsupported "discriminant: projected place")
  | .use oa => checkDowncastOp Γ d oa is
  | .aggregate (.adt v _) ops => checkEnumAggAt Γ d v ops is
  | _ => none

theorem checkEnumRv_sound {Γ : StmtCtx} {d : Local} {rv : Rvalue} {is : List Insn}
    (h : checkEnumRv Γ d rv is = some .ok) : LowerEnum Γ (.assign ⟨d, []⟩ rv) is := by
  unfold checkEnumRv at h
  split at h
  next e => exact .read (checkDiscr_sound (Option.some.inj h))
  next => cases h
  next oa => exact .read (checkDowncastOp_sound h)
  next v act ops => exact .agg (checkEnumAggAt_sound h)
  next => cases h

def checkEnum (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ rv => checkEnumRv Γ d rv is
  | .setDiscriminant ⟨e, []⟩ v => some (checkSetDiscr Γ e v is)
  | .setDiscriminant _ _ => some (.unsupported "set discriminant: projected place")
  | _ => none

theorem checkEnum_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkEnum Γ st is = some .ok) : LowerEnum Γ st is := by
  unfold checkEnum at h
  split at h
  next d rv => exact checkEnumRv_sound h
  next e v => exact .setDiscr (checkSetDiscr_sound (Option.some.inj h))
  next => cases h
  next => cases h

end Ryo.Check.Lower
