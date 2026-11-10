/-
Ryo.Check.Lower.Switch — the rules of a `SwitchInt` with one or more cases on a whole integer
or `bool` local (aot.md §C1, M5b), next to `Term.lean`'s rules for none and one case
(`checkTermX` tries those first).

`LowerSwitch Γ next term is`: the R instructions `is` (the block's terminator range, ending at
`next`) are a lowering of `term = switchInt d cases otherwise`, `d` a copy or move of local `l`
of an integer type or `bool` (`switchTy`: `n` bytes, `bool` as one byte holding 0 or 1) whose
slot has `n` bytes. L0's target for the switch value `x` (`switchBits`, the value's bits below
`2 ^ (8 n)`) is `caseTarget cases otherwise x`, the first case of value `x`. Rules mirror
`FnCx::switch_int` (`backend/src/lower/terminator.rs`), checked by what R does rather than by
the instruction sequence the backend picks:

- `chain`: a chain of `br.eq.imm` tests on the slot, ending in a goto (fallthrough or `jmp`):
  the two-value form (`test v0 → bb0; test v1 → bb1; jmp otherwise`, the last test inverted
  to `otherwise` when `bb1` follows, or `jmp bb1` alone when `otherwise` is unreachable).
  `chainOk` walks it with the values already tested unequal (`ex`): a test of `y` without
  `neg` must branch to a correct place for `y` (`hitOk`), one with `neg` (only last) must fall
  through to one for `y` and branch to one for every other value (`restOk`), the final goto
  must reach one for every value not tested.
- `dense`: one `switch.dense s, base, default, table`: entry `k` of the table is a correct
  place for `base + k` (at the width), the default one for every value outside the table.

A correct place for `x` (`hitOk`) is the start (`blockStart`) of `caseTarget cases otherwise
x`, or anything when that target is `otherwise` and `otherwise` is an empty block ending in
`unreachable` (`deadBlock`): the backend's two-value form jumps to the second case for every
value but the first when `otherwise` is unreachable (enum discriminants). L0 then reaches that
block, whose terminator is UB, so the simulation (`Proofs/Lower/SimSwitch.lean`) ends there
(`SwitchOut`'s second case).

Not covered (`checkSwitch`'s buckets): `switch.sparse` (its case values are code constants
that `ρ` places, which nothing relates to the cases yet), a `char` or other discriminant, an
operand that isn't a local, a slot of the wrong size; fused switches (niche discriminants,
compares) are `checkBlockTerm`'s.
-/
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The width in bytes of a switch on a local of type `ty`: integers, and `bool` as a byte. -/
def switchTy : Ty → Option Nat
  | .int t _ => some t.size
  | .bool => some 1
  | _ => none

/-- L0's target for switch value `x` (`evalTerminator`'s `find?`). -/
def caseTarget (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock) (x : Nat) :
    BasicBlock :=
  match cases.find? (·.1 == x) with
  | some (_, bb) => bb
  | none => otherwise

/-- Block `bb` of the body is empty and ends in `unreachable`. -/
def deadBlock (Γ : TermCtx) (bb : BasicBlock) : Bool :=
  match Γ.body.blocks[bb]? with
  | some bd => bd.stmts.isEmpty && bd.term == Terminator.unreachable
  | none => false

/-- R index `pc` is a correct place to be for switch value `x` (see the module comment). -/
def hitOk (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
    (x pc : Nat) : Bool :=
  blockStart Γ (caseTarget cases otherwise x) == some pc ||
    (caseTarget cases otherwise x == otherwise && deadBlock Γ otherwise)

/-- `pc` is a correct place for every value below `2 ^ (8 n)` outside `ex`: the values that
aren't cases go to `otherwise`, the cases are checked one by one. -/
def restOk (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock) (n : Nat)
    (ex : Nat → Bool) (pc : Nat) : Bool :=
  (blockStart Γ otherwise == some pc || deadBlock Γ otherwise) &&
    cases.all fun cv =>
      decide (2 ^ (8 * n) ≤ cv.1) || ex cv.1 || hitOk Γ cases otherwise cv.1 pc

/-- A chain of `br.eq.imm` tests on slot `a` at `n` bytes ending in a goto, the values in `ex`
already tested unequal (see the module comment). -/
def chainOk (Γ : TermCtx) (next : Nat) (cases : List (Nat × BasicBlock))
    (otherwise : BasicBlock) (n : Nat) (a : Int) : List Nat → List Insn → Bool
  | ex, [] => restOk Γ cases otherwise n (ex.contains ·) next
  | ex, i :: tl =>
    match brImmOps Γ.toStmtCtx i n with
    | some (a', y, neg, t) =>
      let yv := y % 2 ^ (8 * n)
      a' == a &&
        (if neg then
          tl.isEmpty && (ex.contains yv || hitOk Γ cases otherwise yv next) &&
            restOk Γ cases otherwise n (fun x => x == yv || ex.contains x) t
        else
          (ex.contains yv || hitOk Γ cases otherwise yv t) &&
            chainOk Γ next cases otherwise n a (yv :: ex) tl)
    | none =>
      match jmpTo i, tl with
      | some t, [] => restOk Γ cases otherwise n (ex.contains ·) t
      | _, _ => false

/-- `switch.dense` at `n` bytes: slot `a`, base `y`, table length `len`, and the R targets `ts`
(the table, then the default). -/
def denseOps (Γ : StmtCtx) (i : Insn) (n : Nat) : Option (Int × Nat × Nat × List Nat) :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler?, v.ops, v.ctl with
    | some ⟨.switch_dense, [ty], _⟩, [.slot a, .imm y, .none, .targets len], some (.table ts) =>
      if intTyOk ty n && v.op.info.operands.map (·.name) == ["s", "base", "default", "table"] &&
          v.op.info.operands.head?.map (·.kind) == some .slot && ts.length == len + 1 then
        some (a, y, len, ts)
      else none
    | _, _, _ => none
  | none => none

/-- Whether `i` is a `switch.sparse` (to report it as its own bucket). -/
def sparseIs (Γ : StmtCtx) (i : Insn) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨.switch_sparse, _, _⟩ => true
    | _ => false
  | none => false

/-- A dense table with base `y`: entry `k` a correct place for `y + k`, the default (`ts[len]`)
for the values whose index `x - y` (at the width) is past the table. -/
def denseOk (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
    (n y len : Nat) (ts : List Nat) : Bool :=
  (List.range len).all (fun k =>
      decide (2 ^ (8 * n) ≤ k) ||
        match ts[k]? with
        | some t => hitOk Γ cases otherwise ((y + k) % 2 ^ (8 * n)) t
        | none => false) &&
    match ts[len]? with
    | some t =>
      restOk Γ cases otherwise n
        (fun x => decide ((x + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n) < len)) t
    | none => false

inductive LowerSwitch (Γ : TermCtx) (next : Nat) : Terminator → List Insn → Prop where
  | chain {d : Operand} {l : Local} {ty : Ty} {n : Nat} {sl : LocalSlot}
      {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {is : List Insn}
      (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some ty) (hn : switchTy ty = some n)
      (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = n) (hoff : offOk sl.off = true)
      (hok : chainOk Γ next cases otherwise n sl.off [] is = true) :
      LowerSwitch Γ next (.switchInt d cases otherwise) is
  | dense {d : Operand} {l : Local} {ty : Ty} {n : Nat} {sl : LocalSlot}
      {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {i : Insn}
      {a : Int} {y len : Nat} {ts : List Nat}
      (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some ty) (hn : switchTy ty = some n)
      (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = n) (hoff : offOk sl.off = true)
      (hden : denseOps Γ.toStmtCtx i n = some (a, y, len, ts)) (ha : a = sl.off)
      (hok : denseOk Γ cases otherwise n y len ts = true) :
      LowerSwitch Γ next (.switchInt d cases otherwise) [i]

/-- The instruction form, once the slot `off` and width `n` are known. -/
def switchForm (Γ : TermCtx) (next : Nat) (cases : List (Nat × BasicBlock))
    (otherwise : BasicBlock) (n : Nat) (off : Int) : List Insn → Verdict
  | [i] =>
    match denseOps Γ.toStmtCtx i n with
    | some (a, y, len, ts) =>
      okIf (a == off && denseOk Γ cases otherwise n y len ts) "switch: dense table, targets"
    | none =>
      if sparseIs Γ.toStmtCtx i then .unsupported "switch: sparse table"
      else okIf (chainOk Γ next cases otherwise n off [] [i]) "switch: compare chain, form"
  | is => okIf (chainOk Γ next cases otherwise n off [] is) "switch: compare chain, form"

theorem switchForm_sound {Γ : TermCtx} {next : Nat} {cases : List (Nat × BasicBlock)}
    {otherwise : BasicBlock} {n : Nat} {off : Int} {is : List Insn}
    (h : switchForm Γ next cases otherwise n off is = .ok) :
    chainOk Γ next cases otherwise n off [] is = true ∨
      ∃ i a y len ts, is = [i] ∧ denseOps Γ.toStmtCtx i n = some (a, y, len, ts) ∧ a = off ∧
        denseOk Γ cases otherwise n y len ts = true := by
  unfold switchForm at h
  split at h
  next i =>
    split at h
    next a y len ts hden =>
      have h' := okIf_ok h
      simp only [Bool.and_eq_true, beq_iff_eq] at h'
      exact .inr ⟨i, a, y, len, ts, rfl, hden, h'.1, h'.2⟩
    next =>
      split at h
      next => cases h
      next => exact .inl (okIf_ok h)
  next => exact .inl (okIf_ok h)

/-- A `SwitchInt`'s checker once it has one or more cases. -/
def checkSwitchN (Γ : TermCtx) (next : Nat) (d : Operand) (cases : List (Nat × BasicBlock))
    (otherwise : BasicBlock) (is : List Insn) : Verdict :=
  match d.local? with
  | none => .unsupported "switch: operand"
  | some l =>
    match Γ.body.locals[l]?, Γ.slots[l]? with
    | some ty, some sl =>
      match switchTy ty with
      | none => .unsupported "switch: discriminant type"
      | some n =>
        if sl.size == n && offOk sl.off then switchForm Γ next cases otherwise n sl.off is
        else .unsupported "switch: slot"
    | _, _ => .unsupported "switch: local"

theorem checkSwitchN_sound {Γ : TermCtx} {next : Nat} {d : Operand}
    {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {is : List Insn}
    (h : checkSwitchN Γ next d cases otherwise is = .ok) :
    LowerSwitch Γ next (.switchInt d cases otherwise) is := by
  unfold checkSwitchN at h
  split at h
  next => cases h
  next l hl =>
    split at h
    next ty sl hty hsl =>
      split at h
      next => cases h
      next n hn =>
        split at h
        next hslot =>
          simp only [Bool.and_eq_true, beq_iff_eq] at hslot
          obtain ⟨h1, h2⟩ := hslot
          rcases switchForm_sound h with hc | ⟨i, a, y, len, ts, rfl, hden, ha, hok⟩
          · exact LowerSwitch.chain (hd := hl) (hty := hty) (hn := hn) (hsl := hsl)
              (hsize := h1) (hoff := h2) (hok := hc)
          · exact LowerSwitch.dense (hd := hl) (hty := hty) (hn := hn) (hsl := hsl)
              (hsize := h1) (hoff := h2) (hden := hden) (ha := ha) (hok := hok)
        next => cases h
    next => cases h

/-- `SwitchInt` with one or more cases: `none` for other terminators (see the module comment
for the buckets). -/
def checkSwitch (Γ : TermCtx) (next : Nat) (term : Terminator) (is : List Insn) :
    Option Verdict :=
  match term with
  | .switchInt d cases otherwise =>
    if cases.isEmpty then none else some (checkSwitchN Γ next d cases otherwise is)
  | _ => none

theorem checkSwitch_sound {Γ : TermCtx} {next : Nat} {term : Terminator} {is : List Insn}
    (h : checkSwitch Γ next term is = some .ok) : LowerSwitch Γ next term is := by
  unfold checkSwitch at h
  split at h
  next d cases otherwise =>
    split at h
    next => cases h
    next =>
      simp only [Option.some.injEq] at h
      exact checkSwitchN_sound h
  next => cases h

end Ryo.Check.Lower
