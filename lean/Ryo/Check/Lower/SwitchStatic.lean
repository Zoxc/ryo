/-
Ryo.Check.Lower.SwitchStatic — the rule of a `SwitchInt` on an operand known statically (aot.md
§C1, M5b): a `bool` or integer constant, or a runtime check (`RuntimeChecks`, D23), next to
`Switch.lean`'s switches on a local.

`FnCx::switch_int` (`backend/src/lower/terminator.rs`) puts such an operand in a frame
temporary (`operand_slot`: `const_into`/`operand_into`, one `imm` of the operand's width) and
switches on it as on a local. So the terminator range is `imm t, x` followed by that switch's
code on `t` (any of `Term.lean`'s and `Switch.lean`'s forms: a goto, `br`, `br.eq.imm` chains,
`switch.dense`).

`LowerSwitchStatic Γ next term is`: `term = switchInt d cases otherwise`, `staticOpnd d = some
(n, x)` (the width `n` and L0's `switchBits` value `x`, below `2 ^ (8 n)`), `is = i :: tl`
with `i` an `imm` of `x` at `n` bytes into slot `t`, where `t`'s `n` bytes are private (no
`Escape` covers them, `privOk`) and disjoint from every local's slot (`tempApart`: R's frame
bytes no local owns are unconstrained by `FnRel`, so the write keeps it), and `tl` takes R,
with `t` holding `x`, to a correct place for `x` (`hitOk`, as `Switch.lean`'s). `staticWalk`
decides the last part by running `tl` on the known value: each branch's condition is computed
as R's `opSem` computes it (taken: its target must be correct; not taken: the rest), a
`switch.dense` picks its entry the same way, a `jmp` or the range's end is the place.

The simulation is `Proofs/Lower/SimSwitchStatic.lean`. Not covered: a `switch.sparse` (its
case values are code constants), a temporary an `Escape` covers.
-/
import Ryo.Check.Lower.Switch

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- A statically known `SwitchInt` operand: its width in bytes and L0's `switchBits` of it
(`Reach.lean`'s `staticBits`, with the width). -/
def staticOpnd : Operand → Option (Nat × Nat)
  | .const (.scalar bits) .bool => some (1, bits % 256)
  | .const (.scalar bits) (.int t _) =>
    if 0 < t.size then some (t.size, bits % 2 ^ (8 * t.size)) else none
  | .runtimeChecks _ b => some (1, if b then 1 else 0)
  | _ => none

theorem staticOpnd_cases {d : Operand} {n x : Nat} (h : staticOpnd d = some (n, x)) :
    (∃ b, d = .const (.scalar b) .bool ∧ n = 1 ∧ x = b % 256) ∨
    (∃ b t v, d = .const (.scalar b) (.int t v) ∧ 0 < t.size ∧ n = t.size ∧
      x = b % 2 ^ (8 * t.size)) ∨
    (∃ k b, d = .runtimeChecks k b ∧ n = 1 ∧ x = if b then 1 else 0) := by
  unfold staticOpnd at h
  split at h
  · simp only [Option.some.injEq, Prod.mk.injEq] at h
    exact Or.inl ⟨_, rfl, h.1.symm, h.2.symm⟩
  · split at h
    · simp only [Option.some.injEq, Prod.mk.injEq] at h
      exact Or.inr (Or.inl ⟨_, _, _, rfl, by assumption, h.1.symm, h.2.symm⟩)
    · cases h
  · simp only [Option.some.injEq, Prod.mk.injEq] at h
    exact Or.inr (Or.inr ⟨_, _, rfl, h.1.symm, h.2.symm⟩)
  · cases h

theorem staticOpnd_lt {d : Operand} {n x : Nat} (h : staticOpnd d = some (n, x)) :
    x < 2 ^ (8 * n) := by
  rcases staticOpnd_cases h with ⟨b, -, rfl, rfl⟩ | ⟨b, t, v, -, -, rfl, rfl⟩ |
      ⟨k, b, -, rfl, rfl⟩
  · show b % 256 < 256
    exact Nat.mod_lt _ (by decide)
  · exact Nat.mod_lt _ (Nat.two_pow_pos _)
  · cases b <;> decide

/-- Frame bytes `[a, a + n)` meet no local's slot. -/
def tempApart (slots : Array LocalSlot) (a : Int) (n : Nat) : Bool :=
  (List.range slots.size).all fun l =>
    match slots[l]? with
    | some sl => decide (a + n ≤ sl.off) || decide (sl.off + sl.size ≤ a)
    | none => true

theorem tempApart_spec {slots : Array LocalSlot} {a : Int} {n : Nat}
    (h : tempApart slots a n = true) {l : Nat} {sl : LocalSlot} (hl : slots[l]? = some sl) :
    a + n ≤ sl.off ∨ sl.off + sl.size ≤ a := by
  have hlt := (Array.getElem?_eq_some_iff.mp hl).1
  have h1 := List.all_eq_true.mp h l (List.mem_range.mpr hlt)
  simp only [hl, Bool.or_eq_true, decide_eq_true_eq] at h1
  exact h1

/-- R's run of `tl` with slot `a` holding `x` at `n` bytes ends at a correct place for `x` (see
the module comment). -/
def staticWalk (Γ : TermCtx) (next : Nat) (cases : List (Nat × BasicBlock))
    (otherwise : BasicBlock) (n : Nat) (a : Int) (x : Nat) : List Insn → Bool
  | [] => hitOk Γ cases otherwise x next
  | i :: tl =>
    match brImmOps Γ.toStmtCtx i n with
    | some (a', y, neg, t) =>
      a' == a &&
        (if (BitVec.ofNat (8 * n) x == BitVec.ofNat (8 * n) y) != neg then
          hitOk Γ cases otherwise x t
        else staticWalk Γ next cases otherwise n a x tl)
    | none =>
      match brOps Γ.toStmtCtx i with
      | some (s, neg, t) =>
        s == a && n == 1 &&
          (if (x != 0) != neg then hitOk Γ cases otherwise x t
          else staticWalk Γ next cases otherwise n a x tl)
      | none =>
        match denseOps Γ.toStmtCtx i n with
        | some (a', y, len, ts) =>
          a' == a &&
            (match ts[if (BitVec.ofNat (8 * n) x - BitVec.ofNat (8 * n) y).toNat < len then
                (BitVec.ofNat (8 * n) x - BitVec.ofNat (8 * n) y).toNat else len]? with
            | some t => hitOk Γ cases otherwise x t
            | none => false)
        | none =>
          match jmpTo i with
          | some t => hitOk Γ cases otherwise x t
          | none => false

inductive LowerSwitchStatic (Γ : TermCtx) (next : Nat) : Terminator → List Insn → Prop where
  | mk (d : Operand) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock) (n x : Nat)
      (i : Insn) (tl : List Insn) (a : Int)
      (hd : staticOpnd d = some (n, x)) (hi : immInsnOk Γ.toStmtCtx i n a x = true)
      (hoff : offOk a = true) (hpriv : ∀ k < n, Γ.escaped (a + k) = false)
      (hap : tempApart Γ.slots a n = true)
      (hok : staticWalk Γ next cases otherwise n a x tl = true) :
      LowerSwitchStatic Γ next (.switchInt d cases otherwise) (i :: tl)

/-- The destination slot of a two-operand instruction (the `imm`'s, checked by `immInsnOk`). -/
def immDst (Γ : StmtCtx) (i : Insn) : Option Int :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.ops with
    | [.slot d, _] => some d
    | _ => none
  | none => none

/-- The checker once the operand's width `n` and value `x` are known. -/
def checkSwitchStaticN (Γ : TermCtx) (next : Nat) (n x : Nat) (cases : List (Nat × BasicBlock))
    (otherwise : BasicBlock) : List Insn → Verdict
  | [] => .unsupported "switch static: form"
  | i :: tl =>
    match immDst Γ.toStmtCtx i with
    | none => .unsupported "switch static: form"
    | some a =>
      if immInsnOk Γ.toStmtCtx i n a x && offOk a && privOk Γ.toStmtCtx a n &&
          tempApart Γ.slots a n then
        okIf (staticWalk Γ next cases otherwise n a x tl) "switch static: targets"
      else .unsupported "switch static: temporary"

theorem checkSwitchStaticN_sound {Γ : TermCtx} {next n x : Nat} {d : Operand}
    {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {is : List Insn}
    (hd : staticOpnd d = some (n, x))
    (h : checkSwitchStaticN Γ next n x cases otherwise is = .ok) :
    LowerSwitchStatic Γ next (.switchInt d cases otherwise) is := by
  match is, h with
  | [], h => exact absurd h (by simp [checkSwitchStaticN])
  | i :: tl, h =>
    simp only [checkSwitchStaticN] at h
    split at h
    next => cases h
    next a _ =>
      split at h
      next hc =>
        simp only [Bool.and_eq_true] at hc
        obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hc
        exact LowerSwitchStatic.mk d cases otherwise n x i tl a hd h1 h2 (privOk_spec h3) h4
          (okIf_ok h)
      next => cases h

/-- A `SwitchInt` on a statically known operand: `none` for other terminators. -/
def checkSwitchStatic (Γ : TermCtx) (next : Nat) (term : Terminator) (is : List Insn) :
    Option Verdict :=
  match term with
  | .switchInt d cases otherwise =>
    match staticOpnd d with
    | some (n, x) => some (checkSwitchStaticN Γ next n x cases otherwise is)
    | none => none
  | _ => none

theorem checkSwitchStatic_sound {Γ : TermCtx} {next : Nat} {term : Terminator}
    {is : List Insn} (h : checkSwitchStatic Γ next term is = some .ok) :
    LowerSwitchStatic Γ next term is := by
  unfold checkSwitchStatic at h
  split at h
  next d cases otherwise =>
    split at h
    next n x hd =>
      simp only [Option.some.injEq] at h
      exact checkSwitchStaticN_sound hd h
    next => cases h
  next => cases h

end Ryo.Check.Lower
