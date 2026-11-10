/-
Ryo.Check.Lower.Agg — statement rules lowered to several instructions: aggregates built field
by field, and whole-value assignments whose copy is split into pieces (aot.md §C1, M5b).

What the backend emits (`backend/src/lower/adt.rs` `aggregate`, `operand.rs`): for
`_d = aggregate k [op₀, …, opₘ]` into a tuple, struct, closure or array, one `operand_into` per
operand, in operand order, at `_d`'s slot plus the field's offset (`layout.fields.offset(i)`,
for arrays `i * elem_size`). `operand_into` of
- a whole local `_a` of `n` bytes: `copy_val`, i.e. nothing when `n = 0`, else `mov` (slot to
  slot): one `mov.wN` when `n` is 1, 2, 4, 8 or 16; for other `n ≤ 48` (`SPLIT_MAX`) with the
  two ranges disjoint, pieces `mov.wK d+o, s+o` at increasing `o` (the widest width up to 16
  that fits and doesn't straddle one of the operand type's field offsets, `pieces`); else one
  block `copy` (not covered);
- a scalar constant (`ConstValue::Scalar(Int)`): one `imm` of the constant's width;
- a zero-sized constant: nothing. Other constants (pointers, pool copies) are not covered.
Enum aggregates (field writes then `set_discriminant`), unions and `RawPtr` are other rules'.

L0 (`evalRvalue (.aggregate ..)`): every kind but `rawPtr` builds `.tuple vals` when the
destination type is a tuple/struct/closure (`.tuple fields _ none`) or an array, and the store
encodes it as each field's encoding written at its offset over uninitialized bytes
(`Ty.encodeFields`; arrays: the elements' encodings concatenated). R writes the same fields at
the same offsets in the same order, so R's final slot bytes refine L0's whatever the padding
(uninitialized in L0) holds in R (`Ryo/Proofs/Lower/SimAgg.lean`).

Rules:
- `agg`: `_d = aggregate k ops`, `k ≠ rawPtr`, `_d` a whole private local whose L0 type has
  field layout `fields` (`aggLayout`: exactly L0's offsets and types), lowered to the
  concatenation, in field order, of each field's pieces (`aggPieces`), checked instruction by
  instruction (`piecesOk`). Per field (`AggField`): the operand is a whole local of the field's
  type (pieces `mov`s of widths `ws` tiling its `n > 0` bytes, its slot disjoint from `_d`'s), a
  scalar constant at the field's type (one `imm` of its `n > 0` bytes), or a zero-sized local or
  constant (no instruction); every field type well-formed (its re-encoding refines its bytes,
  `encode_decode_le`), the field inside `_d`'s slot.
- `useAny`: `_d = op` lowered as one such field at offset 0 of `_d`'s type: copies of a whole
  local at any size the `mov` splits (`Split::Pieces`; one-`mov` sizes are `Copy.lean`'s
  `copyAny`), scalar constants at any well-formed type (one `imm`), zero-sized operands (no
  instruction, e.g. `_d = const ()`).

`checkAgg` is `none` for any other statement and for `_d = op` with `op` a whole local of a
`mov` width (`checkCopy`'s), so a dispatcher trying `checkAgg` before `checkCopy` keeps
`checkCopy`'s verdicts. The checker guesses each field's pieces from the instructions
(`guessSrcs`, not trusted) and then checks the guess (`aggFieldsOk`, `piecesOk`).
-/
import Ryo.Check.Lower.Copy

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-! ### Pieces -/

/-- One instruction of a field write: `mov` of `w` bytes from slot `s` to slot `d`, or `imm` of
`w` bytes whose low bytes are `bits`'s into slot `d`. -/
inductive AggPiece where
  | mov (d s : Int) (w : Nat)
  | imm (d : Int) (w bits : Nat)
deriving Repr

/-- The instruction form of a piece. -/
def pieceOk (Γ : StmtCtx) (i : Insn) : AggPiece → Bool
  | .mov d s w => movInsnOk Γ i w d s
  | .imm d w bits => immInsnOk Γ i w d bits

/-- Each instruction is its piece. -/
def piecesOk (Γ : StmtCtx) : List Insn → List AggPiece → Bool
  | [], [] => true
  | i :: is, p :: ps => pieceOk Γ i p && piecesOk Γ is ps
  | _, _ => false

/-- `mov`s of widths `ws` copying from `s + o` to `d + o`, `o` advancing by each width. -/
def movPieces (d s : Int) : Nat → List Nat → List AggPiece
  | _, [] => []
  | o, w :: ws => .mov (d + o) (s + o) w :: movPieces d s (o + w) ws

/-- Where a field's bytes come from: a whole local `a` at slot offset `s` copied by `mov`s of
widths `ws`, a scalar constant of `n` bytes, or nothing (zero-sized). -/
inductive AggSrc where
  | slot (a : Local) (s : Int) (ws : List Nat)
  | imm (n bits : Nat)
  | zst
deriving Repr

/-- A field's pieces at destination slot offset `d`. -/
def srcPieces (d : Int) : AggSrc → List AggPiece
  | .slot _ s ws => movPieces d s 0 ws
  | .imm n bits => [.imm d n bits]
  | .zst => []

/-- The pieces of all fields, in field order, `_d`'s slot at `dOff`. -/
def aggPieces (dOff : Int) : List (Nat × Ty) → List AggSrc → List AggPiece
  | (off, _) :: fs, src :: srcs => srcPieces (dOff + off) src ++ aggPieces dOff fs srcs
  | _, _ => []

/-! ### L0's layout -/

/-- The fields (offset, type) of an aggregate of type `ty`, exactly as L0 encodes them: a
tuple/struct/closure without unsized tail, or an array of sized elements. -/
def aggLayout : Ty → Option (List (Nat × Ty))
  | .tuple fields _ none => some fields
  | .array elem n =>
    match elem.size? with
    | some m => some ((List.range n).map fun i => (i * m, elem))
    | none => none
  | _ => none

/-- A coverage bucket for destination types `aggLayout` does not cover. -/
def aggWhy : Ty → String
  | .enum .. => "aggregate: enum"
  | .union .. => "aggregate: union"
  | .tuple _ _ (some _) => "aggregate: unsized tail"
  | .array .. => "aggregate: unsized element"
  | _ => "aggregate: destination type"

/-! ### Fields -/

/-- A zero-sized operand of type `t`: a whole local or a scalar/zero-sized constant. -/
def zstOperand (Γ : StmtCtx) (op : Operand) (t : Ty) : Bool :=
  match op with
  | .const .zeroSized t' | .const (.scalar _) t' => decide (t' = t)
  | .copy ⟨a, []⟩ | .move ⟨a, []⟩ => decide (Γ.body.locals[a]? = some t)
  | _ => false

/-- Field `op` at offset `off` of type `t` of a destination slot `sd`, its bytes from `src`. -/
inductive AggField (Γ : StmtCtx) (sd : LocalSlot) : Operand → Nat → Ty → AggSrc → Prop where
  | slot {op : Operand} {a : Local} {off n : Nat} {t : Ty} {sa : LocalSlot} {ws : List Nat}
      (ha : op.local? = some a) (hta : Γ.body.locals[a]? = some t) (hwf : t.wf = true)
      (hn : t.size? = some n) (hpos : 0 < n) (hsa : Γ.slots[a]? = some sa) (hsz : sa.size = n)
      (hin : off + n ≤ sd.size) (hws : ws.sum = n)
      (hoff : offOk sa.off ∧ offOk (sa.off + n))
      (hap : sd.off + sd.size ≤ sa.off ∨ sa.off + sa.size ≤ sd.off) :
      AggField Γ sd op off t (.slot a sa.off ws)
  | imm {bits off n : Nat} {t : Ty} (hwf : t.wf = true) (hn : t.size? = some n) (hpos : 0 < n)
      (hin : off + n ≤ sd.size) :
      AggField Γ sd (.const (.scalar bits) t) off t (.imm n bits)
  | zst {op : Operand} {off : Nat} {t : Ty} (hwf : t.wf = true) (hn : t.size? = some 0)
      (hin : off ≤ sd.size) (hop : zstOperand Γ op t = true) :
      AggField Γ sd op off t .zst

/-- `AggField` for each operand, field and source, in order. -/
inductive AggFields (Γ : StmtCtx) (sd : LocalSlot) :
    List Operand → List (Nat × Ty) → List AggSrc → Prop where
  | nil : AggFields Γ sd [] [] []
  | cons {op : Operand} {off : Nat} {t : Ty} {src : AggSrc} {ops : List Operand}
      {fs : List (Nat × Ty)} {srcs : List AggSrc} (h : AggField Γ sd op off t src)
      (hs : AggFields Γ sd ops fs srcs) :
      AggFields Γ sd (op :: ops) ((off, t) :: fs) (src :: srcs)

inductive LowerAgg (Γ : StmtCtx) : Statement → List Insn → Prop where
  | agg {d : Local} {k : AggregateKind} {ops : List Operand} {ty : Ty}
      {fields : List (Nat × Ty)} {sd : LocalSlot} {srcs : List AggSrc} {is : List Insn}
      (hk : k ≠ .rawPtr) (htd : Γ.body.locals[d]? = some ty)
      (hlay : aggLayout ty = some fields) (hsz : ty.size? = some sd.size)
      (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
      (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
      (hf : AggFields Γ sd ops fields srcs)
      (hi : piecesOk Γ is (aggPieces sd.off fields srcs) = true) :
      LowerAgg Γ (.assign ⟨d, []⟩ (.aggregate k ops)) is
  | useAny {d : Local} {op : Operand} {ty : Ty} {sd : LocalSlot} {src : AggSrc}
      {is : List Insn}
      (htd : Γ.body.locals[d]? = some ty) (hsz : ty.size? = some sd.size)
      (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
      (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
      (hf : AggField Γ sd op 0 ty src)
      (hi : piecesOk Γ is (srcPieces sd.off src) = true) :
      LowerAgg Γ (.assign ⟨d, []⟩ (.use op)) is

/-! ### Checking a guess -/

/-- Whether two slots are disjoint. -/
def apartB (sd sa : LocalSlot) : Bool :=
  decide (sd.off + sd.size ≤ sa.off) || decide (sa.off + sa.size ≤ sd.off)

/-- `AggField`, decided. -/
def aggFieldOk (Γ : StmtCtx) (sd : LocalSlot) (op : Operand) (off : Nat) (t : Ty) :
    AggSrc → Bool
  | .slot a s ws =>
    match op.local?, Γ.slots[a]?, t.size? with
    | some a', some sa, some n =>
      decide (a' = a) && decide (Γ.body.locals[a]? = some t) && t.wf && decide (0 < n) &&
        decide (sa.size = n) && decide (sa.off = s) && decide (off + n ≤ sd.size) &&
        decide (ws.sum = n) && offOk sa.off && offOk (sa.off + n) && apartB sd sa
    | _, _, _ => false
  | .imm n bits =>
    match op with
    | .const (.scalar b) t' =>
      decide (b = bits) && decide (t' = t) && t.wf && decide (t.size? = some n) &&
        decide (0 < n) && decide (off + n ≤ sd.size)
    | _ => false
  | .zst => t.wf && decide (t.size? = some 0) && decide (off ≤ sd.size) && zstOperand Γ op t

/-- `AggFields`, decided. -/
def aggFieldsOk (Γ : StmtCtx) (sd : LocalSlot) :
    List Operand → List (Nat × Ty) → List AggSrc → Bool
  | [], [], [] => true
  | op :: ops, (off, t) :: fs, src :: srcs =>
    aggFieldOk Γ sd op off t src && aggFieldsOk Γ sd ops fs srcs
  | _, _, _ => false

theorem aggFieldOk_spec {Γ : StmtCtx} {sd : LocalSlot} {op : Operand} {off : Nat} {t : Ty}
    {src : AggSrc} (h : aggFieldOk Γ sd op off t src = true) : AggField Γ sd op off t src := by
  cases src with
  | slot a s ws =>
    simp only [aggFieldOk] at h
    split at h
    next a' sa n ha hsa hn =>
      simp only [Bool.and_eq_true, decide_eq_true_eq] at h
      obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨ha', hta⟩, hwf⟩, hpos⟩, hsz⟩, hs⟩, hin⟩, hws⟩, ho1⟩, ho2⟩, hap⟩ := h
      subst ha' hs
      exact .slot ha hta hwf hn hpos hsa hsz hin hws ⟨ho1, ho2⟩ (by simpa [apartB] using hap)
    · cases h
  | imm n bits =>
    simp only [aggFieldOk] at h
    split at h
    next b t' =>
      simp only [Bool.and_eq_true, decide_eq_true_eq] at h
      obtain ⟨⟨⟨⟨⟨hb, ht⟩, hwf⟩, hn⟩, hpos⟩, hin⟩ := h
      subst hb ht
      exact .imm hwf hn hpos hin
    · cases h
  | zst =>
    simp only [aggFieldOk, Bool.and_eq_true, decide_eq_true_eq] at h
    obtain ⟨⟨⟨hwf, hn⟩, hin⟩, hop⟩ := h
    exact .zst hwf hn hin hop

theorem aggFieldsOk_spec {Γ : StmtCtx} {sd : LocalSlot} :
    ∀ {ops : List Operand} {fs : List (Nat × Ty)} {srcs : List AggSrc},
      aggFieldsOk Γ sd ops fs srcs = true → AggFields Γ sd ops fs srcs := by
  intro ops
  induction ops with
  | nil =>
    intro fs srcs h
    rcases fs with _ | ⟨⟨off, t⟩, fs⟩ <;> rcases srcs with _ | ⟨src, srcs⟩ <;>
      first | exact .nil | (simp [aggFieldsOk] at h)
  | cons op ops ih =>
    intro fs srcs h
    rcases fs with _ | ⟨⟨off, t⟩, fs⟩
    · simp [aggFieldsOk] at h
    · rcases srcs with _ | ⟨src, srcs⟩
      · simp [aggFieldsOk] at h
      · simp only [aggFieldsOk, Bool.and_eq_true] at h
        exact .cons (aggFieldOk_spec h.1) (ih h.2)

/-! ### Guessing the fields' pieces (untrusted) -/

/-- The width of a `mov` instruction from `s` to `d` of at most `m` bytes, if `i` is one. -/
def movWidthOf (Γ : StmtCtx) (i : Insn) (m : Nat) (d s : Int) : Option Nat :=
  [16, 8, 4, 2, 1].find? fun w => decide (w ≤ m) && movInsnOk Γ i w d s

/-- The widths of the `mov`s at the head of `is` copying bytes `o .. n` from `s` to `d`, and
the instructions after them. -/
def parseMovs (Γ : StmtCtx) (d s : Int) (n : Nat) : Nat → List Insn →
    Option (List Nat × List Insn)
  | o, [] => if n ≤ o then some ([], []) else none
  | o, i :: is =>
    if n ≤ o then some ([], i :: is)
    else match movWidthOf Γ i (n - o) (d + o) (s + o) with
      | some w => (parseMovs Γ d s n (o + w) is).map fun p => (w :: p.1, p.2)
      | none => none

/-- A field's source guessed from the instructions at its start (`dOff` its destination
offset), with the instructions after its pieces. -/
def guessSrc (Γ : StmtCtx) (rule : String) (dOff : Int) (op : Operand) (t : Ty)
    (is : List Insn) : Except String (AggSrc × List Insn) :=
  match t.size? with
  | none => .error s!"{rule}: unsized field"
  | some 0 => .ok (.zst, is)
  | some n =>
    match op with
    | .const (.scalar bits) _ =>
      match is with
      | _ :: r => .ok (.imm n bits, r)
      | [] => .error s!"{rule}: instruction count"
    | .const _ _ => .error s!"{rule}: constant operand"
    | .runtimeChecks _ _ => .error s!"{rule}: runtime-checks operand"
    | .copy p | .move p =>
      if !p.proj.isEmpty then .error s!"{rule}: projected operand"
      else match Γ.slots[p.base]? with
        | none => .error s!"{rule}: operand slot"
        | some sa =>
          if 48 < n then .error s!"{rule}: block copy"
          else match parseMovs Γ dOff sa.off n 0 is with
            | some (ws, r) => .ok (.slot p.base sa.off ws, r)
            | none => .error s!"{rule}: copy form"

/-- All fields' sources, guessed in order. -/
def guessSrcs (Γ : StmtCtx) (dOff : Int) : List Operand → List (Nat × Ty) → List Insn →
    Except String (List AggSrc)
  | op :: ops, (off, t) :: fs, is => do
    let (src, r) ← guessSrc Γ "aggregate" (dOff + off) op t is
    let srcs ← guessSrcs Γ dOff ops fs r
    pure (src :: srcs)
  | _, _, [] => .ok []
  | _, _, _ => .error "aggregate: instruction count"

/-! ### The checkers -/

/-- `agg`'s checker. -/
def checkAggregate (Γ : StmtCtx) (d : Local) (k : AggregateKind) (ops : List Operand)
    (is : List Insn) : Verdict :=
  if k = .rawPtr then .unsupported "aggregate: raw pointer"
  else match Γ.body.locals[d]? with
  | none => .rejected "aggregate: no destination local"
  | some ty =>
    match aggLayout ty with
    | none => .unsupported (aggWhy ty)
    | some fields =>
      match Γ.slots[d]? with
      | none => .rejected "aggregate: no destination slot"
      | some sd =>
        if ty.size? ≠ some sd.size then .rejected "aggregate: slot size"
        else if !(offOk sd.off && offOk (sd.off + sd.size)) then .rejected "aggregate: offsets"
        else if !privOk Γ sd.off sd.size then .unsupported "aggregate: escaped destination"
        else if ops.length ≠ fields.length then .rejected "aggregate: operand count"
        else match guessSrcs Γ sd.off ops fields is with
          | .error why => .unsupported why
          | .ok srcs =>
            if !aggFieldsOk Γ sd ops fields srcs then .unsupported "aggregate: field operands"
            else if piecesOk Γ is (aggPieces sd.off fields srcs) then .ok
            else .unsupported "aggregate: instruction form"

/-- `useAny`'s checker for `_d = op`. -/
def checkUseAny (Γ : StmtCtx) (d : Local) (op : Operand) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]? with
  | none => .rejected "use: no destination local"
  | some ty =>
    match Γ.slots[d]? with
    | none => .rejected "use: no destination slot"
    | some sd =>
      if ty.size? ≠ some sd.size then .rejected "use: slot size"
      else if !(offOk sd.off && offOk (sd.off + sd.size)) then .rejected "use: offsets"
      else if !privOk Γ sd.off sd.size then .unsupported "use: escaped destination"
      else match guessSrc Γ "use" sd.off op ty is with
        | .error why => .unsupported why
        | .ok p =>
          if !aggFieldOk Γ sd op 0 ty p.1 then .unsupported "use: operand"
          else if piecesOk Γ is (srcPieces sd.off p.1) then .ok
          else .unsupported "use: instruction form"

/-- The `_d = op` this family claims: scalar and zero-sized constants, and whole locals whose
size is not a `mov` width (`checkCopy` decides those). -/
def useClaimed (Γ : StmtCtx) : Operand → Bool
  | .const (.scalar _) _ | .const .zeroSized _ => true
  | .copy ⟨a, []⟩ | .move ⟨a, []⟩ =>
    match Γ.body.locals[a]? with
    | some t =>
      match t.size? with
      | some n => !movWidth n
      | none => false
    | none => false
  | _ => false

/-- The family's checker: `none` unless `st` is an aggregate into a whole local, or a `_d = op`
`useClaimed` claims. -/
def checkAgg (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.aggregate k ops) => some (checkAggregate Γ d k ops is)
  | .assign ⟨d, []⟩ (.use op) => if useClaimed Γ op then some (checkUseAny Γ d op is) else none
  | _ => none

theorem checkAggregate_sound {Γ : StmtCtx} {d : Local} {k : AggregateKind}
    {ops : List Operand} {is : List Insn} (h : checkAggregate Γ d k ops is = .ok) :
    LowerAgg Γ (.assign ⟨d, []⟩ (.aggregate k ops)) is := by
  unfold checkAggregate at h
  split at h
  · cases h
  next hk =>
    split at h
    · cases h
    next ty htd =>
      split at h
      · cases h
      next fields hlay =>
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
                next =>
                  split at h
                  · cases h
                  next srcs _ =>
                    split at h
                    · cases h
                    next hf =>
                      split at h
                      next hi =>
                        exact .agg hk htd hlay (by simpa using hsz) hsd (by simpa using hoff)
                          (privOk_spec (by simpa using hpriv))
                          (aggFieldsOk_spec (by simpa using hf)) hi
                      · cases h

theorem checkUseAny_sound {Γ : StmtCtx} {d : Local} {op : Operand} {is : List Insn}
    (h : checkUseAny Γ d op is = .ok) : LowerAgg Γ (.assign ⟨d, []⟩ (.use op)) is := by
  unfold checkUseAny at h
  split at h
  · cases h
  next ty htd =>
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
            next p _ =>
              split at h
              · cases h
              next hf =>
                split at h
                next hi =>
                  exact .useAny htd (by simpa using hsz) hsd (by simpa using hoff)
                    (privOk_spec (by simpa using hpriv)) (aggFieldOk_spec (by simpa using hf)) hi
                · cases h

theorem checkAgg_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkAgg Γ st is = some .ok) : LowerAgg Γ st is := by
  unfold checkAgg at h
  split at h
  next d k ops => exact checkAggregate_sound (Option.some.inj h)
  next d op =>
    split at h
    · exact checkUseAny_sound (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
