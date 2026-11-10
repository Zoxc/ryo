/-
Ryo.Check.Lower.BinMore — integer binary operators on operands other than whole locals (aot.md
§C1, M5b), and their checker: field projections of locals, and two constants.

What the backend emits (`backend/src/lower/binop.rs` `arith`, `operand.rs` `operand_slot`): an
operand that reads a sized place inside a local's slot uses that sub-slot directly (`loc_slot`),
so a field of a local is read like a whole local at `slot + offset`; a constant has no slot, so
a constant left operand is materialized into a temporary (`imm`).

Operators: `binMethod`'s (wrapping arithmetic, bit operations) and `BinX.lean`'s
(`ccMethodB` for two operands in slots, `ccMethod` for an `.imm` right operand, which excludes
`Div`/`Rem`). Operand slots (`PlaceInt`): `copy`/`move` of a place `_a.f₁.….fₖ` that `fieldPath`
covers, of an integer type `t`, inside `_a`'s slot.

Rules (`_d` a whole local of type `t`, private, its slot of `t`'s size):
- `placeBin`: `_d = op(p, q)`, two operand slots, lowered to one `binXInsnOk` instruction on
  them.
- `placeImm`: `_d = op(p, const bits : tc)`, lowered to one `binImmXInsnOk` instruction.
- `constConst`: `_d = op(const ba : t, const bb : tc)`, lowered to `[imm tt, ba; op.imm d, tt,
  bb]` with `tt` a temporary (`tempOk`).
- `constLeft`: `_d = op(const ba : t, q)`, `q` an operand slot, lowered to `[imm tt, ba;
  op d, tt, q]` (`BinXConst.lean`'s rule for any operand slot and `binMethod`'s operators too).

`checkBinMore` claims these statements when an operand is projected, the left one is a constant
and the right one an operand slot, or both are constants, and
is `none` otherwise, so whole-local operands stay with `Stmt.lean`/`BinX.lean`; it must run
before `checkBinX`, which claims `BinX.lean`'s operators on any operands.
-/
import Ryo.Check.Lower.BinX
import Ryo.Check.Lower.Field
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The operators on two operand slots. -/
def ccMethodB (op : BinOp) : Option String :=
  match binMethod op with
  | some m => some m
  | none => binXMethod op

/-- The operators with an `.imm` right operand. -/
def ccMethod (op : BinOp) : Option String :=
  match binMethod op with
  | some m => some m
  | none => binImmXMethod op

/-- An operand reading a projected place. -/
def hasProj : Operand → Bool
  | .copy p | .move p => !p.proj.isEmpty
  | _ => false

/-- `o` reads an integer of type `t` at frame offset `x`, inside its base local's slot. -/
inductive PlaceInt (Γ : StmtCtx) (o : Operand) (t : IntType) (x : Int) : Prop where
  | mk {a : Local} {projs : List ProjElem} {ta : Ty} {off : Nat} {valid : ValidRange}
      {sa : LocalSlot}
      (hl : operandPlace? o = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
      (hpath : fieldPath ta projs = some (off, .int t valid))
      (hsa : Γ.slots[a]? = some sa) (hin : off + t.size ≤ sa.size) (hx : x = sa.off + off)
      (hoff : offOk (sa.off + off) = true)

/-- `PlaceInt`'s type and offset, if `o` has one. -/
def placeInt? (Γ : StmtCtx) (o : Operand) : Option (IntType × Int) :=
  match operandPlace? o with
  | some ⟨a, projs⟩ =>
    match Γ.body.locals[a]?, Γ.slots[a]? with
    | some ta, some sa =>
      match fieldPath ta projs with
      | some (off, .int t _) =>
        if off + t.size ≤ sa.size ∧ offOk (sa.off + off) = true then some (t, sa.off + off)
        else none
      | _ => none
    | _, _ => none
  | none => none

theorem placeInt?_spec {Γ : StmtCtx} {o : Operand} {t : IntType} {x : Int}
    (h : placeInt? Γ o = some (t, x)) : PlaceInt Γ o t x := by
  unfold placeInt? at h
  split at h
  next a projs hl =>
    split at h
    next ta sa hta hsa =>
      split at h
      next off t' valid hpath =>
        split at h
        next hc =>
          cases h
          exact .mk hl hta hpath hsa hc.1 rfl hc.2
        next => cases h
      next => cases h
    next => cases h
  next => cases h

inductive LowerBinMore (Γ : StmtCtx) : Statement → List Insn → Prop where
  | placeBin {d : Local} {oa ob : Operand} {op : BinOp} {m : String} {t : IntType}
      {valid : ValidRange} {sd : LocalSlot} {xa xb : Int} {i : Insn}
      (hm : ccMethodB op = some m) (hmod : shiftOk t t = true)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size) (hoff : offOk sd.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hA : PlaceInt Γ oa t xa) (hB : PlaceInt Γ ob t xb)
      (hi : binXInsnOk Γ i m t.size (binXSigned op) t.signed sd.off xa xb = true) :
      LowerBinMore Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]
  | placeImm {d : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {t tc : IntType}
      {valid vc : ValidRange} {sd : LocalSlot} {xa : Int} {i : Insn}
      (hm : ccMethod op = some m) (hmod : immModOk op t tc = true)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size) (hoff : offOk sd.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hA : PlaceInt Γ oa t xa)
      (hi : binImmXInsnOk Γ i m t.size (binXSigned op) t.signed sd.off xa (immMod op t) bits
        = true) :
      LowerBinMore Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc vc)))) [i]
  | constConst {d : Local} {op : BinOp} {m : String} {ba bb : Nat} {t tc : IntType}
      {valid va vc : ValidRange} {sd : LocalSlot} {tt : Int} {i1 i2 : Insn}
      (hm : ccMethod op = some m) (hmod : immModOk op t tc = true)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size) (hoff : offOk sd.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt ba = true)
      (hi2 : binImmXInsnOk Γ i2 m t.size (binXSigned op) t.signed sd.off tt (immMod op t) bb
        = true) :
      LowerBinMore Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) (.int t va))
        (.const (.scalar bb) (.int tc vc)))) [i1, i2]
  | constLeft {d : Local} {ob : Operand} {op : BinOp} {m : String} {ba : Nat} {t : IntType}
      {valid va : ValidRange} {sd : LocalSlot} {xb tt : Int} {i1 i2 : Insn}
      (hm : ccMethodB op = some m) (hmod : shiftOk t t = true)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size) (hoff : offOk sd.off = true)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hB : PlaceInt Γ ob t xb)
      (ht : tempOk Γ tt t.size = true) (hi1 : immInsnOk Γ i1 t.size tt ba = true)
      (hi2 : binXInsnOk Γ i2 m t.size (binXSigned op) t.signed sd.off tt xb = true) :
      LowerBinMore Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) (.int t va)) ob))
        [i1, i2]

/-! ### The checker -/

def placeBinOk (Γ : StmtCtx) (d : Local) (op : BinOp) (m : String) (oa ob : Operand)
    (i : Insn) : Bool :=
  match Γ.body.locals[d]?, Γ.slots[d]?, placeInt? Γ oa, placeInt? Γ ob with
  | some (.int t _), some sd, some (ta, xa), some (tb, xb) =>
    decide (ta = t) && decide (tb = t) && shiftOk t t && sd.size == t.size && offOk sd.off &&
      privOk Γ sd.off sd.size && binXInsnOk Γ i m t.size (binXSigned op) t.signed sd.off xa xb
  | _, _, _, _ => false

theorem placeBinOk_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {m : String} {oa ob : Operand}
    {i : Insn} (hm : ccMethodB op = some m) (h : placeBinOk Γ d op m oa ob i = true) :
    LowerBinMore Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i] := by
  unfold placeBinOk at h
  split at h
  next t valid sd ta xa tb xb htd hsd hpa hpb =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩ := h
    subst h1 h2
    exact .placeBin hm h3 htd hsd h4 h5 (privOk_spec h6) (placeInt?_spec hpa)
      (placeInt?_spec hpb) h7
  next => cases h

def placeImmOk (Γ : StmtCtx) (d : Local) (op : BinOp) (m : String) (oa : Operand) (bits : Nat)
    (tc : IntType) (i : Insn) : Bool :=
  match Γ.body.locals[d]?, Γ.slots[d]?, placeInt? Γ oa with
  | some (.int t _), some sd, some (ta, xa) =>
    decide (ta = t) && immModOk op t tc && sd.size == t.size && offOk sd.off &&
      privOk Γ sd.off sd.size &&
      binImmXInsnOk Γ i m t.size (binXSigned op) t.signed sd.off xa (immMod op t) bits
  | _, _, _ => false

theorem placeImmOk_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {m : String} {oa : Operand}
    {bits : Nat} {tc : IntType} {vc : ValidRange} {i : Insn} (hm : ccMethod op = some m)
    (h : placeImmOk Γ d op m oa bits tc i = true) :
    LowerBinMore Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc vc)))) [i] := by
  unfold placeImmOk at h
  split at h
  next t valid sd ta xa htd hsd hpa =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := h
    subst h1
    exact .placeImm hm h2 htd hsd h3 h4 (privOk_spec h5) (placeInt?_spec hpa) h6
  next => cases h

def constConstOk (Γ : StmtCtx) (d : Local) (op : BinOp) (m : String) (ba : Nat) (ta : IntType)
    (bb : Nat) (tc : IntType) (i1 i2 : Insn) : Bool :=
  match Γ.body.locals[d]?, Γ.slots[d]?, immSlotOf Γ i1 with
  | some (.int t _), some sd, some tt =>
    decide (ta = t) && immModOk op t tc && sd.size == t.size && offOk sd.off &&
      privOk Γ sd.off sd.size && tempOk Γ tt t.size && immInsnOk Γ i1 t.size tt ba &&
      binImmXInsnOk Γ i2 m t.size (binXSigned op) t.signed sd.off tt (immMod op t) bb
  | _, _, _ => false

theorem constConstOk_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {m : String} {ba bb : Nat}
    {ta tc : IntType} {va vc : ValidRange} {i1 i2 : Insn} (hm : ccMethod op = some m)
    (h : constConstOk Γ d op m ba ta bb tc i1 i2 = true) :
    LowerBinMore Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) (.int ta va))
      (.const (.scalar bb) (.int tc vc)))) [i1, i2] := by
  unfold constConstOk at h
  split at h
  next t valid sd tt htd hsd htt =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩ := h
    subst h1
    exact .constConst hm h2 htd hsd h3 h4 (privOk_spec h5) h6 h7 h8
  next => cases h

def constLeftOk (Γ : StmtCtx) (d : Local) (op : BinOp) (m : String) (ba : Nat) (ta : IntType)
    (ob : Operand) (i1 i2 : Insn) : Bool :=
  match Γ.body.locals[d]?, Γ.slots[d]?, placeInt? Γ ob, immSlotOf Γ i1 with
  | some (.int t _), some sd, some (tb, xb), some tt =>
    decide (ta = t) && decide (tb = t) && shiftOk t t && sd.size == t.size && offOk sd.off &&
      privOk Γ sd.off sd.size && tempOk Γ tt t.size && immInsnOk Γ i1 t.size tt ba &&
      binXInsnOk Γ i2 m t.size (binXSigned op) t.signed sd.off tt xb
  | _, _, _, _ => false

theorem constLeftOk_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {m : String} {ba : Nat}
    {ta : IntType} {va : ValidRange} {ob : Operand} {i1 i2 : Insn} (hm : ccMethodB op = some m)
    (h : constLeftOk Γ d op m ba ta ob i1 i2 = true) :
    LowerBinMore Γ (.assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) (.int ta va)) ob))
      [i1, i2] := by
  unfold constLeftOk at h
  split at h
  next t valid sd tb xb tt htd hsd hpb htt =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩ := h
    subst h1 h2
    exact .constLeft hm h3 htd hsd h4 h5 (privOk_spec h6) (placeInt?_spec hpb) h7 h8 h9
  next => cases h

/-- Decide `LowerBinMore` (see the module comment for what it claims). -/
def checkBinMore (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) (.int ta _))
      (.const (.scalar bb) (.int tc _))) =>
    match ccMethod op with
    | some m => some (match is with
      | [i1, i2] => okIf (constConstOk Γ d op m ba ta bb tc i1 i2) "binop const const: form"
      | _ => .unsupported "binop const const: instruction count")
    | none => none
  | .assign ⟨d, []⟩ (.binaryOp op (.const (.scalar ba) (.int ta _)) ob) =>
    match ccMethodB op, placeInt? Γ ob with
    | some m, some _ => some (match is with
      | [i1, i2] => okIf (constLeftOk Γ d op m ba ta ob i1 i2) "binop const left: form"
      | _ => .unsupported "binop const left: instruction count")
    | _, _ => none
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc _))) =>
    if hasProj oa then
      match ccMethod op with
      | some m => some (match is with
        | [i] => okIf (placeImmOk Γ d op m oa bits tc i) "binop place imm: form"
        | _ => .unsupported "binop place imm: instruction count")
      | none => none
    else none
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    if hasProj oa || hasProj ob then
      match ccMethodB op with
      | some m => some (match is with
        | [i] => okIf (placeBinOk Γ d op m oa ob i) "binop place: form"
        | _ => .unsupported "binop place: instruction count")
      | none => none
    else none
  | _ => none

theorem checkBinMore_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkBinMore Γ st is = some .ok) : LowerBinMore Γ st is := by
  unfold checkBinMore at h
  split at h
  · split at h
    next m hm =>
      have h' := Option.some.inj h
      split at h'
      · exact constConstOk_sound hm (okIf_ok h')
      · cases h'
    · cases h
  · split at h
    next m _ hm _ =>
      have h' := Option.some.inj h
      split at h'
      · exact constLeftOk_sound hm (okIf_ok h')
      · cases h'
    · cases h
  · split at h
    · split at h
      next m hm =>
        have h' := Option.some.inj h
        split at h'
        · exact placeImmOk_sound hm (okIf_ok h')
        · cases h'
      · cases h
    · cases h
  · split at h
    · split at h
      next m hm =>
        have h' := Option.some.inj h
        split at h'
        · exact placeBinOk_sound hm (okIf_ok h')
        · cases h'
      · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
