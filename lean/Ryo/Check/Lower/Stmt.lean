/-
Ryo.Check.Lower.Stmt — the relational spec of statement lowering and its checker (aot.md §C1,
M5a), first rules.

`LowerStmt Γ st is` says that the R instructions `is` (a statement's certificate range in the
decoded code) are a lowering of MIR statement `st` in function context `Γ` (the body's local
types, the certificate's frame map, the code's mode and placement). Each rule carries exactly
the facts its simulation lemma (`Ryo/Proofs/Lower/`) needs. `checkStmt` decides the relation for
the rules so far (`checkStmt_sound`); any other statement is `unsupported`, reported in the
coverage, not an error.

Rules:
- `binop`: `_d = op(_a, _b)` (`copy` or `move` of whole locals) for a wrapping or bitwise
  operator (`binMethod`) on locals of one integer type `t`, lowered to one handler-kind
  instruction (`bin`/`binop`, the operator's method, `t`'s width) on the three locals' slots, the
  slots of `t`'s size, `_d`'s slot never escaped in the function (its simulation is for private
  destinations: `Ryo.Proofs.Lower.sim_binop`).
- `binopImm`: `_d = op(_a, const)` with an integer constant of `t`, lowered to one
  `bin_imm`/`binop_imm` instruction on `_d`'s and `_a`'s slots and an immediate whose low
  `t.size` bytes are the constant's (`Env.immBv` reads only those).
- `copyInt`: `_d = _a` (`copy`/`move` of a whole local) at one integer type, lowered to one
  `mov` of `t`'s width between the slots.
- `constInt`: `_d = const` with an integer constant, lowered to one `imm` of `t`'s width on
  `_d`'s slot, the immediate's low `t.size` bytes the constant's (`imm` writes `intBytes n`).
- `copyBool`, `copyPtr`: `_d = _a` at `bool` or at a thin pointer type, lowered to one `mov`
  of 1 or 8 bytes (`mov` copies bytes, provenance included).
- `constBool`: `_d = const bits : bool`, lowered to one `imm` of 1 byte.
- `storageLive`/`storageDead`: lower to no instruction (their effect on R is the scopes').
-/
import Ryo.Check.Lower.Cert
import Ryo.Vm.R.View

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The R method of an L0 operator the lowering maps to a `bin`/`binop` handler without a check. -/
def binMethod : BinOp → Option String
  | .add => some "wrapping_add"
  | .sub => some "wrapping_sub"
  | .mul => some "wrapping_mul"
  | .bitAnd => some "&"
  | .bitOr => some "|"
  | .bitXor => some "^"
  | _ => none

/-- A function's context for its statements' rules. -/
structure StmtCtx where
  body : Body
  slots : Array LocalSlot
  mode : Ryo.Obj.Mode
  ρ : Addrs
  /-- Frame offsets some `Escape` scope of the function covers. -/
  escaped : Int → Bool

/-- An operand that reads a whole local (`copy _l` or `move _l`). -/
def _root_.Ryo.Spec.Operand.local? : Operand → Option Local
  | .copy ⟨l, []⟩ | .move ⟨l, []⟩ => some l
  | _ => none

/-- `ty` names an integer handler type of `n` bytes. -/
def intTyOk (ty : String) (n : Nat) : Bool :=
  match OpSem.Ty.parse ty with
  | some (.int n' _) => n' == n
  | _ => false

/-- An instruction whose view is a `bin`/`binop` handler with method `m` at `n` bytes, on slots
`d, a, b`, falling through. -/
def binInsnOk (Γ : StmtCtx) (i : Insn) (m : String) (n : Nat) (d a b : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, m'], _⟩ =>
      (kd == .bin || kd == .binop) && m' == m && intTyOk ty n &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] &&
        v.ops == [.slot d, .slot a, .slot b] && v.ctl == some .next
    | _ => false
  | none => false

/-- An instruction whose view is a `mov` handler at `n` bytes from slot `s` to slot `d`, falling
through. -/
def movInsnOk (Γ : StmtCtx) (i : Insn) (n : Nat) (d s : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty], _⟩ =>
      kd == .mov && intTyOk ty n &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"s", .slot⟩] &&
        v.ops == [.slot d, .slot s] && v.ctl == some .next
    | _ => false
  | none => false

/-- Operands `slots` followed by one immediate whose low `n` bytes are `bits`'s. -/
def immOpsOk (ops : OpSem.Operands) (slots : List Int) (n bits : Nat) : Bool :=
  match ops.getLast? with
  | some (.imm x) =>
    ops == slots.map OpSem.Val.slot ++ [.imm x] && x % 2 ^ (8 * n) == bits % 2 ^ (8 * n)
  | _ => false

theorem immOpsOk_spec {ops : OpSem.Operands} {slots : List Int} {n bits : Nat}
    (h : immOpsOk ops slots n bits = true) :
    ∃ x, ops = slots.map OpSem.Val.slot ++ [.imm x] ∧ x % 2 ^ (8 * n) = bits % 2 ^ (8 * n) := by
  unfold immOpsOk at h
  split at h
  next x _ =>
    simp only [Bool.and_eq_true, beq_iff_eq] at h
    exact ⟨x, h.1, h.2⟩
  · cases h

/-- An instruction whose view is an `imm` handler at `n` bytes on slot `d`, its immediate's low
`n` bytes `bits`'s, falling through. -/
def immInsnOk (Γ : StmtCtx) (i : Insn) (n : Nat) (d : Int) (bits : Nat) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty], _⟩ =>
      kd == .imm && intTyOk ty n &&
        v.op.info.operands.map (·.name) == ["d", "imm"] &&
        v.op.info.operands.head?.map (·.kind) == some .slot &&
        immOpsOk v.ops [d] n bits && v.ctl == some .next
    | _ => false
  | none => false

/-- An instruction whose view is a `bin_imm`/`binop_imm` handler with method `m` at `n` bytes,
on slots `d, a` and an immediate whose low `n` bytes are `bits`'s, falling through. -/
def binImmInsnOk (Γ : StmtCtx) (i : Insn) (m : String) (n : Nat) (d a : Int) (bits : Nat) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, m'], _⟩ =>
      (kd == .bin_imm || kd == .binop_imm) && m' == m && intTyOk ty n &&
        v.op.info.operands.map (·.name) == ["d", "a", "imm"] &&
        (v.op.info.operands.take 2).map (·.kind) == [.slot, .slot] &&
        immOpsOk v.ops [d, a] n bits && v.ctl == some .next
    | _ => false
  | none => false

/-- A slot offset in the 32-bit range. -/
def offOk (o : Int) : Bool := -2 ^ 31 ≤ o && o < 2 ^ 31

inductive LowerStmt (Γ : StmtCtx) : Statement → List Insn → Prop where
  | binop {d a b : Local} {oa ob : Operand} {op : BinOp} {m : String} {t : IntType}
      {valid : ValidRange} {sd sa sb : LocalSlot} {i : Insn}
      (hm : binMethod op = some m) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hta : Γ.body.locals[a]? = some (.int t valid))
      (htb : Γ.body.locals[b]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = t.size ∧ sa.size = t.size ∧ sb.size = t.size)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk sb.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : binInsnOk Γ i m t.size sd.off sa.off sb.off = true) :
      LowerStmt Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]
  | binopImm {d a : Local} {oa : Operand} {op : BinOp} {m : String} {bits : Nat} {t : IntType}
      {valid : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hm : binMethod op = some m) (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = t.size)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : binImmInsnOk Γ i m t.size sd.off sa.off bits = true) :
      LowerStmt Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int t valid)))) [i]
  | copyInt {d a : Local} {oa : Operand} {t : IntType} {valid : ValidRange} {sd sa : LocalSlot}
      {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.int t valid)) (hta : Γ.body.locals[a]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = t.size ∧ sa.size = t.size)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : movInsnOk Γ i t.size sd.off sa.off = true) :
      LowerStmt Γ (.assign ⟨d, []⟩ (.use oa)) [i]
  | constInt {d : Local} {bits : Nat} {t : IntType} {valid : ValidRange} {sd : LocalSlot}
      {i : Insn}
      (htd : Γ.body.locals[d]? = some (.int t valid))
      (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = t.size)
      (hoff : offOk sd.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : immInsnOk Γ i t.size sd.off bits = true) :
      LowerStmt Γ (.assign ⟨d, []⟩ (.use (.const (.scalar bits) (.int t valid)))) [i]
  | copyBool {d a : Local} {oa : Operand} {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some .bool)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 1 ∧ sa.size = 1)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : movInsnOk Γ i 1 sd.off sa.off = true) :
      LowerStmt Γ (.assign ⟨d, []⟩ (.use oa)) [i]
  | copyPtr {d a : Local} {oa : Operand} {pt : PtrType} {valid : ValidRange}
      {sd sa : LocalSlot} {i : Insn}
      (hk : pt.metaKind = .none) (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some (.ptr pt valid))
      (hta : Γ.body.locals[a]? = some (.ptr pt valid))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 8 ∧ sa.size = 8)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : movInsnOk Γ i 8 sd.off sa.off = true) :
      LowerStmt Γ (.assign ⟨d, []⟩ (.use oa)) [i]
  | constBool {d : Local} {bits : Nat} {sd : LocalSlot} {i : Insn}
      (htd : Γ.body.locals[d]? = some .bool)
      (hsd : Γ.slots[d]? = some sd)
      (hsize : sd.size = 1)
      (hoff : offOk sd.off)
      (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
      (hi : immInsnOk Γ i 1 sd.off bits = true) :
      LowerStmt Γ (.assign ⟨d, []⟩ (.use (.const (.scalar bits) .bool))) [i]
  | storageLive (l : Local) : LowerStmt Γ (.storageLive l) []
  | storageDead (l : Local) : LowerStmt Γ (.storageDead l) []

/-- The checker's answer for one statement. -/
inductive Verdict where
  | ok
  | unsupported (rule : String)
  | rejected (why : String)
deriving Repr, DecidableEq, Inhabited

/-- Whether no offset of the `n` bytes at `o` is escaped. -/
def privOk (Γ : StmtCtx) (o : Int) (n : Nat) : Bool :=
  (List.range n).all fun k => !Γ.escaped (o + k)

theorem privOk_spec {Γ : StmtCtx} {o : Int} {n : Nat} (h : privOk Γ o n = true) :
    ∀ k < n, Γ.escaped (o + k) = false := by
  unfold privOk at h
  intro k hk
  simpa using List.all_eq_true.mp h k (List.mem_range.mpr hk)

/-- `binop`'s checker. -/
def checkBinop (Γ : StmtCtx) (d : Local) (op : BinOp) (oa ob : Operand) (is : List Insn) :
    Verdict :=
  match binMethod op, oa.local?, ob.local? with
  | some m, some a, some b =>
    match Γ.body.locals[d]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some (.int t valid), some ta, some tb =>
      if ta != Ty.int t valid || tb != Ty.int t valid then .unsupported "binop: mixed types"
      else match Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
        | some sd, some sa, some sb, [i] =>
          if !(sd.size == t.size && sa.size == t.size && sb.size == t.size) then
            .rejected "binop: slot sizes"
          else if !(offOk sd.off && offOk sa.off && offOk sb.off) then .rejected "binop: offsets"
          else if !privOk Γ sd.off sd.size then .unsupported "binop: escaped destination"
          else if binInsnOk Γ i m t.size sd.off sa.off sb.off then .ok
          else .unsupported "binop: instruction form"
        | _, _, _, _ => .unsupported "binop: slots or instruction count"
    | _, _, _ => .unsupported "binop: not integers"
  | _, _, _ => .unsupported "binop: operator or operands"

/-- `binopImm`'s checker: `_d = op(oa, const bits : t)`. -/
def checkBinopImm (Γ : StmtCtx) (d : Local) (op : BinOp) (oa : Operand) (bits : Nat)
    (t : IntType) (valid : ValidRange) (is : List Insn) : Verdict :=
  match binMethod op, oa.local? with
  | some m, some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]? with
    | some td, some ta =>
      if td != Ty.int t valid || ta != Ty.int t valid then .unsupported "binop imm: types"
      else match Γ.slots[d]?, Γ.slots[a]?, is with
        | some sd, some sa, [i] =>
          if !(sd.size == t.size && sa.size == t.size) then .rejected "binop imm: slot sizes"
          else if !(offOk sd.off && offOk sa.off) then .rejected "binop imm: offsets"
          else if !privOk Γ sd.off sd.size then .unsupported "binop imm: escaped destination"
          else if binImmInsnOk Γ i m t.size sd.off sa.off bits then .ok
          else .unsupported "binop imm: instruction form"
        | _, _, _ => .unsupported "binop imm: slots or instruction count"
    | _, _ => .unsupported "binop imm: locals"
  | _, _ => .unsupported "binop imm: operator or operand"

/-- `copyInt`'s checker: `_d = oa`. -/
def checkCopyInt (Γ : StmtCtx) (d : Local) (oa : Operand) (is : List Insn) : Verdict :=
  match oa.local? with
  | some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]? with
    | some (.int t valid), some ta =>
      if ta != Ty.int t valid then .unsupported "copy: mixed types"
      else match Γ.slots[d]?, Γ.slots[a]?, is with
        | some sd, some sa, [i] =>
          if !(sd.size == t.size && sa.size == t.size) then .rejected "copy: slot sizes"
          else if !(offOk sd.off && offOk sa.off) then .rejected "copy: offsets"
          else if !privOk Γ sd.off sd.size then .unsupported "copy: escaped destination"
          else if movInsnOk Γ i t.size sd.off sa.off then .ok
          else .unsupported "copy: instruction form"
        | _, _, _ => .unsupported "copy: slots or instruction count"
    | _, _ => .unsupported "copy: not integers"
  | none => .unsupported (match oa with
    | .copy _ | .move _ => "use: projected place" | .const .. => "use: const" | _ => "use: operand")

/-- `constInt`'s checker: `_d = const bits : t`. -/
def checkConstInt (Γ : StmtCtx) (d : Local) (bits : Nat) (t : IntType) (valid : ValidRange)
    (is : List Insn) : Verdict :=
  match Γ.body.locals[d]? with
  | some td =>
    if td != Ty.int t valid then .unsupported "const: types"
    else match Γ.slots[d]?, is with
      | some sd, [i] =>
        if sd.size != t.size then .rejected "const: slot size"
        else if !offOk sd.off then .rejected "const: offset"
        else if !privOk Γ sd.off sd.size then .unsupported "const: escaped destination"
        else if immInsnOk Γ i t.size sd.off bits then .ok
        else .unsupported "const: instruction form"
      | _, _ => .unsupported "const: slot or instruction count"
  | none => .unsupported "const: no local"

/-- A `mov` at `n` bytes from `_a`'s slot to `_d`'s, both of `n` bytes, `_d`'s never escaped. -/
def movSlotsOk (Γ : StmtCtx) (d a : Local) (n : Nat) (i : Insn) : Bool :=
  match Γ.slots[d]?, Γ.slots[a]? with
  | some sd, some sa =>
    sd.size == n && sa.size == n && offOk sd.off && offOk sa.off && privOk Γ sd.off sd.size &&
      movInsnOk Γ i n sd.off sa.off
  | _, _ => false

theorem movSlotsOk_spec {Γ : StmtCtx} {d a : Local} {n : Nat} {i : Insn}
    (h : movSlotsOk Γ d a n i = true) :
    ∃ sd sa, Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧ (sd.size = n ∧ sa.size = n) ∧
      (offOk sd.off ∧ offOk sa.off) ∧ (∀ k < sd.size, Γ.escaped (sd.off + k) = false) ∧
      movInsnOk Γ i n sd.off sa.off = true := by
  unfold movSlotsOk at h
  split at h
  next sd sa hsd hsa =>
    simp only [Bool.and_eq_true, beq_iff_eq] at h
    obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := h
    exact ⟨sd, sa, hsd, hsa, ⟨h1, h2⟩, ⟨h3, h4⟩, privOk_spec h5, h6⟩
  · cases h

/-- A copy lowered to one `mov` at `n` bytes. -/
def checkCopyN (Γ : StmtCtx) (d a : Local) (n : Nat) (is : List Insn) : Verdict :=
  match is with
  | [i] => if movSlotsOk Γ d a n i then .ok else .unsupported "copy: slots or instruction form"
  | _ => .unsupported "copy: instruction count"

theorem checkCopyN_ok {Γ : StmtCtx} {d a : Local} {n : Nat} {is : List Insn}
    (h : checkCopyN Γ d a n is = .ok) : ∃ i, is = [i] ∧ movSlotsOk Γ d a n i = true := by
  unfold checkCopyN at h
  split at h
  next i =>
    split at h
    next hm => exact ⟨i, rfl, hm⟩
    · cases h
  · cases h

/-- `copyBool`'s and `copyPtr`'s checker. -/
def checkCopyOther (Γ : StmtCtx) (d : Local) (oa : Operand) (is : List Insn) : Verdict :=
  match oa.local? with
  | some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]? with
    | some .bool, some .bool => checkCopyN Γ d a 1 is
    | some (.ptr pt valid), some ta =>
      if pt.metaKind = .none ∧ ta = .ptr pt valid then checkCopyN Γ d a 8 is
      else .unsupported "copy: wide pointer or mixed types"
    | _, _ => .unsupported "copy: not integers, bools or thin pointers"
  | none => .unsupported (match oa with
    | .copy _ | .move _ => "use: projected place" | .const .. => "use: const" | _ => "use: operand")

theorem checkCopyOther_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {is : List Insn}
    (h : checkCopyOther Γ d oa is = .ok) : LowerStmt Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkCopyOther at h
  split at h
  next a ha =>
    split at h
    next htd hta =>
      obtain ⟨i, rfl, hm⟩ := checkCopyN_ok h
      obtain ⟨sd, sa, hsd, hsa, hsz, hoff, hpriv, hi⟩ := movSlotsOk_spec hm
      exact .copyBool ha htd hta hsd hsa hsz hoff hpriv hi
    next pt valid ta htd hta =>
      split at h
      next hc =>
        obtain ⟨hk, rfl⟩ := hc
        obtain ⟨i, rfl, hm⟩ := checkCopyN_ok h
        obtain ⟨sd, sa, hsd, hsa, hsz, hoff, hpriv, hi⟩ := movSlotsOk_spec hm
        exact .copyPtr hk ha htd hta hsd hsa hsz hoff hpriv hi
      · cases h
    · cases h
  · cases h

/-- A copy: `copyInt`, else (other types) `copyBool`/`copyPtr`. -/
def checkUse (Γ : StmtCtx) (d : Local) (oa : Operand) (is : List Insn) : Verdict :=
  if checkCopyInt Γ d oa is = .unsupported "copy: not integers" then checkCopyOther Γ d oa is
  else checkCopyInt Γ d oa is

/-- `constBool`'s checker. -/
def checkConstBool (Γ : StmtCtx) (d : Local) (bits : Nat) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]?, Γ.slots[d]?, is with
  | some .bool, some sd, [i] =>
    if sd.size = 1 ∧ offOk sd.off = true ∧ privOk Γ sd.off sd.size = true ∧
        immInsnOk Γ i 1 sd.off bits = true then .ok
    else .unsupported "const bool: slot or instruction form"
  | _, _, _ => .unsupported "const bool: type, slot or instruction count"

theorem checkConstBool_sound {Γ : StmtCtx} {d : Local} {bits : Nat} {is : List Insn}
    (h : checkConstBool Γ d bits is = .ok) :
    LowerStmt Γ (.assign ⟨d, []⟩ (.use (.const (.scalar bits) .bool))) is := by
  unfold checkConstBool at h
  split at h
  next sd i htd hsd =>
    split at h
    next hc =>
      obtain ⟨h1, h2, h3, h4⟩ := hc
      exact .constBool htd hsd h1 h2 (privOk_spec h3) h4
    · cases h
  · cases h

/-- A coverage bucket for a statement no rule handles. -/
def stmtKind : Statement → String
  | .assign p rv =>
    let dst := if p.proj.isEmpty then "" else " (projected place)"
    let k := match rv with
      | .use (.copy q) | .use (.move q) => if q.proj.isEmpty then "use local" else "use place"
      | .use (.const c _) => match c with
        | .scalar _ => "use const scalar" | .ptr .. => "use const ptr"
        | .zeroSized => "use const zst" | .slice .. => "use const slice"
        | .indirect .. => "use const indirect"
      | .use _ => "use other"
      | .repeat .. => "repeat" | .ref .. => "ref" | .threadLocalRef _ => "tls ref"
      | .rawPtr .. => "raw ptr" | .cast k _ _ => s!"cast {(repr k).pretty}"
      | .binaryOp op _ _ => s!"binop {(repr op).pretty}"
      | .unaryOp op _ => s!"unop {(repr op).pretty}"
      | .discriminant _ => "discriminant" | .aggregate k _ => s!"aggregate {(repr k).pretty}"
      | .copyForDeref _ => "copy for deref" | .wrapUnsafeBinder .. => "wrap binder"
      | .reborrow .. => "reborrow"
    "statement: " ++ k ++ dst
  | .setDiscriminant .. => "statement: set discriminant"
  | .assume _ => "statement: assume"
  | .copyNonOverlapping .. => "statement: copy nonoverlapping"
  | .placeMention _ => "statement: place mention"
  | .nop w => s!"statement: nop {w}"
  | _ => "statement"

/-- Decide `LowerStmt` for the rules so far. -/
def checkStmt (Γ : StmtCtx) : Statement → List Insn → Verdict
  | .storageLive _, [] | .storageDead _, [] => .ok
  | .storageLive _, _ | .storageDead _, _ => .rejected "storage statement with instructions"
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int t valid))), is =>
    checkBinopImm Γ d op oa bits t valid is
  | .assign ⟨d, []⟩ (.binaryOp op oa ob), is => checkBinop Γ d op oa ob is
  | .assign ⟨d, []⟩ (.use (.const (.scalar bits) (.int t valid))), is =>
    checkConstInt Γ d bits t valid is
  | .assign ⟨d, []⟩ (.use (.const (.scalar bits) .bool)), is => checkConstBool Γ d bits is
  | .assign ⟨d, []⟩ (.use oa), is => checkUse Γ d oa is
  | st, _ => .unsupported (stmtKind st)

theorem checkBinop_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {oa ob : Operand}
    {is : List Insn} (h : checkBinop Γ d op oa ob is = .ok) :
    LowerStmt Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) is := by
  unfold checkBinop at h
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
                  exact .binop hm ha hb htd hta htb hsd hsa hsb (by simp at hsz; exact ⟨hsz.1.1, hsz.1.2, hsz.2⟩)
                    (by simp at hoff; exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩) (privOk_spec (by simpa using hpriv)) hi
                · cases h
        · cases h
    · cases h
  · cases h

theorem checkBinopImm_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {oa : Operand} {bits : Nat}
    {t : IntType} {valid : ValidRange} {is : List Insn}
    (h : checkBinopImm Γ d op oa bits t valid is = .ok) :
    LowerStmt Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) (.int t valid)))) is := by
  unfold checkBinopImm at h
  split at h
  next m a hm ha =>
    split at h
    next td ta htd hta =>
      split at h
      · cases h
      next hty =>
        have hty : td = .int t valid ∧ ta = .int t valid := by simpa using hty
        obtain ⟨rfl, rfl⟩ := hty
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
                  exact .binopImm hm ha htd hta hsd hsa (by simpa using hsz)
                    (by simpa using hoff) (privOk_spec (by simpa using hpriv)) hi
                · cases h
        · cases h
    · cases h
  · cases h

theorem checkCopyInt_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {is : List Insn}
    (h : checkCopyInt Γ d oa is = .ok) : LowerStmt Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkCopyInt at h
  split at h
  next a ha =>
    split at h
    next t valid ta htd hta =>
      split at h
      · cases h
      next hty =>
        have hty : ta = .int t valid := by simpa using hty
        subst hty
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
                  exact .copyInt ha htd hta hsd hsa (by simpa using hsz) (by simpa using hoff)
                    (privOk_spec (by simpa using hpriv)) hi
                · cases h
        · cases h
    · cases h
  · cases h

theorem checkConstInt_sound {Γ : StmtCtx} {d : Local} {bits : Nat} {t : IntType}
    {valid : ValidRange} {is : List Insn} (h : checkConstInt Γ d bits t valid is = .ok) :
    LowerStmt Γ (.assign ⟨d, []⟩ (.use (.const (.scalar bits) (.int t valid)))) is := by
  unfold checkConstInt at h
  split at h
  next td htd =>
    split at h
    · cases h
    next hty =>
      have hty : td = .int t valid := by simpa using hty
      subst hty
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
                exact .constInt htd hsd (by simpa using hsz) (by simpa using hoff)
                  (privOk_spec (by simpa using hpriv)) hi
              · cases h
      · cases h
  · cases h

theorem checkUse_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {is : List Insn}
    (h : checkUse Γ d oa is = .ok) : LowerStmt Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkUse at h
  split at h
  · exact checkCopyOther_sound h
  · exact checkCopyInt_sound h

theorem checkStmt_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkStmt Γ st is = .ok) : LowerStmt Γ st is := by
  unfold checkStmt at h
  split at h
  all_goals first
    | exact .storageLive _
    | exact .storageDead _
    | exact checkBinopImm_sound h
    | exact checkBinop_sound h
    | exact checkConstInt_sound h
    | exact checkConstBool_sound h
    | exact checkUse_sound h
    | (cases h; done)

end Ryo.Check.Lower
