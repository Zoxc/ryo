/-
Ryo.Proofs.Lower.SimReach — L0 only enters blocks `computeReach` holds of (aot.md §C1, M5b;
`Check/Lower/Reach.lean`), so the function simulation's invariant can carry it and `LowersFn`
need only check the lowering of those blocks: the certificate's `dead` blocks (and any other
unreachable one) need none.

- `switch_static_target`: a `SwitchInt` on a statically known operand (`staticBits`) goes to
  the target of that value.
- `term_target_mono`: L0's target after a terminator step is in `monoSuccs`, the successors
  `ReachSound.closed` covers.
- `MatchX`: the invariant `fn_step_sim_ret` keeps once fused compares and unreachable blocks are
  covered: `MatchAt` at a reachable block, short of a fused block's terminator point (that
  point is `MatchMid`'s), or `MatchMid` (`SimFused.lean`).
-/
import Ryo.Proofs.Lower.FnStep
import Ryo.Proofs.Lower.SimFused
import Ryo.Check.Lower.Reach

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-- `staticBits`' cases. -/
theorem staticBits_cases {d : Operand} {bits : Nat} (h : staticBits d = some bits) :
    (∃ b, d = .const (.scalar b) .bool ∧ bits = b % 256) ∨
    (∃ b t v, d = .const (.scalar b) (.int t v) ∧ bits = b % 2 ^ (8 * t.size)) ∨
    (∃ k b, d = .runtimeChecks k b ∧ bits = if b then 1 else 0) := by
  unfold staticBits at h
  split at h
  · exact Or.inl ⟨_, rfl, (Option.some.inj h).symm⟩
  · split at h
    · exact Or.inr (Or.inl ⟨_, _, _, rfl, (Option.some.inj h).symm⟩)
    · cases h
  · exact Or.inr (Or.inr ⟨_, _, rfl, (Option.some.inj h).symm⟩)
  · cases h

/-- A `SwitchInt` on a statically known operand goes to that value's target.

Proof: unfold `evalTerminator` as in `switchInt_inv` (`evalOperand d >>= switchBits >>= …`,
`runOn_bind_ok`), then per `staticBits` case: a `bool` constant evaluates as in
`runOn_evalOperand_const_cmp`'s `bool` case to `.bool (bits % 256 == 1)` with `bits % 256 < 2`
(else the decode fails: no successful step), whose `switchBits` is `bits % 256`; an integer
constant by `runOn_evalOperand_const_scalar_int` (`SimBinImm.lean`) to
`.int (t.ofBits (bits % m))`, whose `switchBits` is `t.toBits (t.ofBits u) = u` for `u < m`
(`IntType.toBits_ofBits`, `modulus_eq_two_pow`, `0 < t.size`); a runtime check evaluates to
`.bool b` (`Operand.lean`, D23: `rfl`). The `find?` match is `caseTarget`'s (`rfl`); `jumpTo`'s
effect as in `switchInt_inv`. -/
theorem switch_static_target {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Operand} {bits : Nat}
    (hd : staticBits d = some bits) {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    (h : runOn (evalTerminator (.switchInt d cases otherwise)) o s = (.ok (), s')) :
    s'.stack = { f with bb := caseTarget cases otherwise bits, stmt := 0 } :: rest := by
  have e : evalTerminator (.switchInt d cases otherwise) = (evalOperand d >>= fun x =>
      switchBits x >>= fun bits =>
      match cases.find? (·.1 == bits) with
      | some (_, bb) => SemM.jumpTo bb
      | none => SemM.jumpTo otherwise) := rfl
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨bits', s2, h3, h4⟩ := runOn_bind_ok h2
  have key : bits' = bits ∧ s2 = s := by
    rcases staticBits_cases hd with ⟨b, rfl, rfl⟩ | ⟨b, t, v, rfl, rfl⟩ | ⟨k, b, rfl, rfl⟩
    · obtain ⟨hr, hok, hs1⟩ :=
        runOn_evalOperand_const_cmp (n := 1) (sg := false) (tc := .bool) rfl h1
      subst hr
      rw [hs1] at h3
      have hok' : b % 2 ^ (8 * 1) < 2 := hok
      have e3 : runOn (switchBits (cmpValue Spec.Ty.bool (b % 2 ^ (8 * 1)), Spec.Ty.bool)) o s =
          (.ok (if (b % 2 ^ (8 * 1) == 1) = true then 1 else 0), s) := rfl
      rw [e3] at h3
      obtain ⟨hb, hs2⟩ := prod_ok_inj h3
      refine ⟨?_, hs2.symm⟩
      rw [← hb]
      have e256 : (2 : Nat) ^ (8 * 1) = 256 := rfl
      rw [e256] at hok' ⊢
      by_cases hc : b % 256 = 1
      · simp [hc]
      · simp [hc]
        omega
    · obtain ⟨hx, hs1⟩ := runOn_evalOperand_const_scalar_int h1
      subst hx
      rw [hs1] at h3
      have e3 : runOn (switchBits (Value.int (t.ofBits (b % 2 ^ (8 * t.size))), Spec.Ty.int t v))
          o s = (.ok (t.toBits (t.ofBits (b % 2 ^ (8 * t.size)))), s) := rfl
      rw [e3] at h3
      obtain ⟨hb, hs2⟩ := prod_ok_inj h3
      refine ⟨?_, hs2.symm⟩
      rw [← hb, Ryo.Spec.Theorems.IntType.toBits_ofBits, ← modulus_eq_two_pow, Nat.mod_mod]
    · have e1 : runOn (evalOperand (.runtimeChecks k b)) o s = (.ok (.bool b, .bool), s) := rfl
      rw [e1] at h1
      obtain ⟨hx, hs1⟩ := prod_ok_inj h1
      subst hx
      rw [← hs1] at h3
      have e3 : runOn (switchBits (Value.bool b, Spec.Ty.bool)) o s =
          (.ok (if b then 1 else 0), s) := rfl
      rw [e3] at h3
      obtain ⟨hb, hs2⟩ := prod_ok_inj h3
      exact ⟨hb.symm, hs2.symm⟩
  obtain ⟨rfl, rfl⟩ := key
  unfold caseTarget
  rcases hf : cases.find? (·.1 == bits') with _ | ⟨_, bb⟩
  · simp only [hf] at h4 ⊢
    rw [runOn_jumpTo hs] at h4
    exact (congrArg Spec.State.stack (prod_ok_inj h4).2).symm
  · simp only [hf] at h4 ⊢
    rw [runOn_jumpTo hs] at h4
    exact (congrArg Spec.State.stack (prod_ok_inj h4).2).symm

/-- L0's target after a terminator step is a `monoSuccs` block.

Proof: if `term` is a `SwitchInt` with `staticBits d = some bits`, `switch_static_target`
and `hs'` give `b' = caseTarget cases otherwise bits` (`List.cons.inj`, `congrArg
Spec.Frame.bb`), the one element of `monoSuccs`; otherwise `monoSuccs_of_termSuccs hsucc`. -/
theorem term_target_mono {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {term : Terminator} {b' : BasicBlock}
    (hsucc : b' ∈ termSuccs term) (hs' : s'.stack = { f with bb := b', stmt := 0 } :: rest)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) : b' ∈ monoSuccs term := by
  cases term
  case switchInt d cases otherwise =>
    rcases hd : staticBits d with _ | bits
    · exact monoSuccs_of_termSuccs hsucc (fun _ _ _ he => by cases he; exact hd)
    · have h2 := switch_static_target hs hd h
      rw [hs'] at h2
      have hb : b' = caseTarget cases otherwise bits :=
        congrArg Spec.Frame.bb (List.cons.inj h2).1
      simp only [monoSuccs, hd, List.mem_singleton]
      exact hb
  all_goals exact monoSuccs_of_termSuccs hsucc (fun _ _ _ he => by cases he)

/-- The function simulation's invariant with fused compares and reachability (see the module
comment). -/
def MatchX (Γ : TermCtx) (ι : Inj) (s : Spec.State) (s1 : RState) : Prop :=
  (∃ f rest blk bd, MatchAt Γ ι s s1 f rest blk bd ∧
      reachGet (computeReach Γ.body) f.bb = true ∧
      (blk.fused = true → f.stmt < bd.stmts.length)) ∨
    MatchMid Γ (reachGet (computeReach Γ.body)) ι s s1

end Ryo.Proofs.Lower
