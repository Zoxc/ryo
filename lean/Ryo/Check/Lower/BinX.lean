/-
Ryo.Check.Lower.BinX — the statement rules for the integer binary operators `Stmt.lean`'s
`binop`/`binopImm` leave out (aot.md §C1, M5b), and their checker.

The operators (`binXMethod`) and their R handlers (`backend/src/lower/binop.rs`, `arith`):
- `AddUnchecked`/`SubUnchecked`/`MulUnchecked`: the wrapping `add`/`sub`/`mul` handlers (L0 is
  UB on overflow; where it is not, the wrapped result is the exact one).
- `Shl`/`ShlUnchecked`, `Shr`/`ShrUnchecked`: the `shift` handlers (`wrapping_shl`,
  `wrapping_shr`, the latter signed for a signed type). L0's shift amount is `rhs.rem_euclid(bits)`
  (or `rhs` in range, else UB); R's is the amount operand's bit pattern modulo the width.
- `Div`/`Rem` by a local: the `bin_fn` handlers `unchecked_div`/`unchecked_rem` at the type's
  signedness. R is UB on a zero divisor and on `MIN / -1`, where L0 is too.

Rules (`LowerBinX`), on whole locals (`copy`/`move` of a local), the destination's slot never
escaped in the function (the simulations are for private destinations, as `LowerStmt`'s):
- `bin`: `_d = op(_a, _b)`, all three of one integer type `t`, lowered to one `bin`/`bin_fn`/
  `binop`/`shift` handler instruction (method `binXMethod op`, `t`'s width; signedness `t`'s
  when `binXSigned op`) on the three slots, of `t`'s size.
- `binImm`: `_d = op(_a, const bits : tc)`, lowered to one `bin_imm`/`binop_imm`/`shift_imm`
  instruction on `_d`'s and `_a`'s slots and an immediate congruent to `bits` modulo `immMod op
  t`: `2 ^ (8 * t.size)` for the arithmetic (then `tc = t`), the width `8 * t.size` for a shift,
  whose amount may have any integer type `tc` (`immModOk`).

Shifts need the width to divide the moduli (`shiftOk`; true for all integer sizes, checked).
Not covered: `Div`/`Rem` by a constant (the backend's `mov`/`shr`/`and`/multiply sequences, or
the constant materialized: two instructions), shifts whose amount has another type than the value (the
backend casts it first: two instructions), a constant left operand (materialized: two
instructions), `*WithOverflow` (`ovf` into a pair), `Offset` (`ptr_index`).

`checkBinX` decides the rules (`checkBinX_sound`): `none` for any statement that is not one of
these operators assigned to a whole local, so a dispatcher can try families in turn.
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The R method of an operator the `bin`/`shift` handlers implement beyond `binMethod`'s. -/
def binXMethod : BinOp → Option String
  | .addUnchecked => some "wrapping_add"
  | .subUnchecked => some "wrapping_sub"
  | .mulUnchecked => some "wrapping_mul"
  | .shl | .shlUnchecked => some "wrapping_shl"
  | .shr | .shrUnchecked => some "wrapping_shr"
  | .div => some "unchecked_div"
  | .rem => some "unchecked_rem"
  | _ => none

/-- `binXMethod` for the `.imm` forms: not `Div`/`Rem` (by a constant the backend emits other
sequences, or materializes the constant). -/
def binImmXMethod : BinOp → Option String
  | .div | .rem => none
  | op => binXMethod op

/-- Whether R's method reads the handler type's signedness. -/
def binXSigned : BinOp → Bool
  | .shr | .shrUnchecked | .div | .rem => true
  | _ => false

def isShift : BinOp → Bool
  | .shl | .shlUnchecked | .shr | .shrUnchecked => true
  | _ => false

/-- The width of `t` divides `2 ^ (8 * t.size)` and `2 ^ (8 * tc.size)` (shift amounts are
taken modulo the width). -/
def shiftOk (t tc : IntType) : Bool :=
  2 ^ (8 * t.size) % (8 * t.size) == 0 && 2 ^ (8 * tc.size) % (8 * t.size) == 0

/-- The modulus an immediate must agree with the constant at. -/
def immMod (op : BinOp) (t : IntType) : Nat :=
  match isShift op with
  | true => 8 * t.size
  | false => 2 ^ (8 * t.size)

/-- The constant's type: any for a shift (with `shiftOk`), else the operands'. -/
def immModOk (op : BinOp) (t tc : IntType) : Bool :=
  match isShift op with
  | true => shiftOk t tc
  | false => tc == t

/-- `ty` names an integer handler type of `n` bytes, of signedness `sg` if `chk`. -/
def intTyOkS (ty : String) (n : Nat) (chk sg : Bool) : Bool :=
  match OpSem.Ty.parse ty with
  | some (.int n' sg') => n' == n && (sg' == sg || !chk)
  | _ => false

def binKd (kd : Handlers.HandlerKind) : Bool :=
  kd == .bin || kd == .bin_fn || kd == .binop || kd == .shift

def binImmKd (kd : Handlers.HandlerKind) : Bool :=
  kd == .bin_imm || kd == .binop_imm || kd == .shift_imm

/-- An instruction whose view is a `bin`/`bin_fn`/`binop`/`shift` handler with method `m` at
`n` bytes (signedness `sg` if `chk`), on slots `d, a, b`, falling through. -/
def binXInsnOk (Γ : StmtCtx) (i : Insn) (m : String) (n : Nat) (chk sg : Bool) (d a b : Int) :
    Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, m'], _⟩ =>
      binKd kd && m' == m && intTyOkS ty n chk sg &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] &&
        v.ops == [.slot d, .slot a, .slot b] && v.ctl == some .next
    | _ => false
  | none => false

/-- Operands `slots` followed by one immediate congruent to `bits` modulo `q`. -/
def immOpsModOk (ops : OpSem.Operands) (slots : List Int) (q bits : Nat) : Bool :=
  match ops.getLast? with
  | some (.imm x) => ops == slots.map OpSem.Val.slot ++ [.imm x] && x % q == bits % q
  | _ => false

theorem immOpsModOk_spec {ops : OpSem.Operands} {slots : List Int} {q bits : Nat}
    (h : immOpsModOk ops slots q bits = true) :
    ∃ x, ops = slots.map OpSem.Val.slot ++ [.imm x] ∧ x % q = bits % q := by
  unfold immOpsModOk at h
  split at h
  next x _ =>
    simp only [Bool.and_eq_true, beq_iff_eq] at h
    exact ⟨x, h.1, h.2⟩
  · cases h

/-- An instruction whose view is a `bin_imm`/`binop_imm`/`shift_imm` handler with method `m` at
`n` bytes (signedness `sg` if `chk`), on slots `d, a` and an immediate congruent to `bits`
modulo `q`, falling through. -/
def binImmXInsnOk (Γ : StmtCtx) (i : Insn) (m : String) (n : Nat) (chk sg : Bool) (d a : Int)
    (q bits : Nat) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, m'], _⟩ =>
      binImmKd kd && m' == m && intTyOkS ty n chk sg &&
        v.op.info.operands.map (·.name) == ["d", "a", "imm"] &&
        (v.op.info.operands.take 2).map (·.kind) == [.slot, .slot] &&
        immOpsModOk v.ops [d, a] q bits && v.ctl == some .next
    | _ => false
  | none => false

inductive LowerBinX (Γ : StmtCtx) : Statement → List Insn → Prop where
  | bin {d a b : Local} {oa ob : Operand} {op : BinOp} {m : String} {t : IntType}
      {valid : ValidRange} {sd sa sb : LocalSlot} {i : Insn}
      (hm : binXMethod op = some m) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (hmod : shiftOk t t = true)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hta : Γ.body.locals[a]? = some (.int t valid))
      (htb : Γ.body.locals[b]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = t.size ∧ sa.size = t.size ∧ sb.size = t.size)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk sb.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : binXInsnOk Γ i m t.size (binXSigned op) t.signed sd.off sa.off sb.off = true) :
      LowerBinX Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]
  | binImm {d a : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {t tc : IntType}
      {valid vc : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hm : binImmXMethod op = some m) (ha : oa.local? = some a)
      (hmod : immModOk op t tc = true)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = t.size)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : binImmXInsnOk Γ i m t.size (binXSigned op) t.signed sd.off sa.off (immMod op t) bits
        = true) :
      LowerBinX Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc vc)))) [i]

/-- `bin`'s checker (`checkBinop`'s shape). -/
def checkBinXAt (Γ : StmtCtx) (d : Local) (op : BinOp) (oa ob : Operand) (is : List Insn) :
    Verdict :=
  match binXMethod op, oa.local?, ob.local? with
  | some m, some a, some b =>
    match Γ.body.locals[d]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some (.int t valid), some ta, some tb =>
      if ta != Ty.int t valid || tb != Ty.int t valid then .unsupported "binop x: mixed types"
      else if !shiftOk t t then .unsupported "binop x: width"
      else match Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
        | some sd, some sa, some sb, [i] =>
          if !(sd.size == t.size && sa.size == t.size && sb.size == t.size) then
            .rejected "binop x: slot sizes"
          else if !(offOk sd.off && offOk sa.off && offOk sb.off) then
            .rejected "binop x: offsets"
          else if !privOk Γ sd.off sd.size then .unsupported "binop x: escaped destination"
          else if binXInsnOk Γ i m t.size (binXSigned op) t.signed sd.off sa.off sb.off then .ok
          else .unsupported "binop x: instruction form"
        | _, _, _, _ => .unsupported "binop x: slots or instruction count"
    | _, _, _ => .unsupported "binop x: not integers"
  | _, _, _ => .unsupported "binop x: operands"

/-- `binImm`'s checker (`checkBinopImm`'s shape). -/
def checkBinImmXAt (Γ : StmtCtx) (d : Local) (op : BinOp) (oa : Operand) (bits : Nat)
    (tc : IntType) (is : List Insn) : Verdict :=
  match binImmXMethod op, oa.local? with
  | some m, some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]? with
    | some (.int t valid), some ta =>
      if ta != Ty.int t valid then .unsupported "binop x imm: types"
      else if !immModOk op t tc then .unsupported "binop x imm: constant type"
      else match Γ.slots[d]?, Γ.slots[a]?, is with
        | some sd, some sa, [i] =>
          if !(sd.size == t.size && sa.size == t.size) then .rejected "binop x imm: slot sizes"
          else if !(offOk sd.off && offOk sa.off) then .rejected "binop x imm: offsets"
          else if !privOk Γ sd.off sd.size then .unsupported "binop x imm: escaped destination"
          else if binImmXInsnOk Γ i m t.size (binXSigned op) t.signed sd.off sa.off
              (immMod op t) bits then .ok
          else .unsupported "binop x imm: instruction form"
        | _, _, _ => .unsupported "binop x imm: slots or instruction count"
    | _, _ => .unsupported "binop x imm: not integers"
  | _, _ => .unsupported "binop x imm: operand"

theorem checkBinXAt_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {oa ob : Operand}
    {is : List Insn} (h : checkBinXAt Γ d op oa ob is = .ok) :
    LowerBinX Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) is := by
  unfold checkBinXAt at h
  split at h
  next m a b hm ha hb =>
    split at h
    next t valid ta tb htd hta htb =>
      split at h
      · cases h
      next hty =>
        have hty : ta = .int t valid ∧ tb = .int t valid := by simpa using hty
        obtain ⟨rfl, rfl⟩ := hty
        split at h
        · cases h
        next hmod =>
          have hmod : shiftOk t t = true := by simpa using hmod
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
                    exact .bin hm ha hb hmod htd hta htb hsd hsa hsb
                      (by simp at hsz; exact ⟨hsz.1.1, hsz.1.2, hsz.2⟩)
                      (by simp at hoff; exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩)
                      (privOk_spec (by simpa using hpriv)) hi
                  · cases h
          · cases h
    · cases h
  · cases h

theorem checkBinImmXAt_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {oa : Operand} {bits : Nat}
    {tc : IntType} {vc : ValidRange} {is : List Insn}
    (h : checkBinImmXAt Γ d op oa bits tc is = .ok) :
    LowerBinX Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc vc)))) is := by
  unfold checkBinImmXAt at h
  split at h
  next m a hm ha =>
    split at h
    next t valid ta htd hta =>
      split at h
      · cases h
      next hty =>
        have hty : ta = .int t valid := by simpa using hty
        subst hty
        split at h
        · cases h
        next hmod =>
          have hmod : immModOk op t tc = true := by simpa using hmod
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
                    exact .binImm hm ha hmod htd hta hsd hsa (by simpa using hsz)
                      (by simpa using hoff) (privOk_spec (by simpa using hpriv)) hi
                  · cases h
          · cases h
    · cases h
  · cases h

/-- Decide `LowerBinX`: `none` unless `st` assigns one of its operators to a whole local. -/
def checkBinX (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int tc _))) =>
    match binImmXMethod op with
    | some _ => some (checkBinImmXAt Γ d op oa bits tc is)
    | none => none
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    match binXMethod op with
    | some _ => some (checkBinXAt Γ d op oa ob is)
    | none => none
  | _ => none

theorem checkBinX_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkBinX Γ st is = some .ok) : LowerBinX Γ st is := by
  unfold checkBinX at h
  split at h
  · split at h
    · exact checkBinImmXAt_sound (Option.some.inj h)
    · cases h
  · split at h
    · exact checkBinXAt_sound (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
