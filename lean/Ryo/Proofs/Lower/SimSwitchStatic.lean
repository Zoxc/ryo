/-
Ryo.Proofs.Lower.SimSwitchStatic — the simulation of `LowerSwitchStatic`
(`Check/Lower/SwitchStatic.lean`, M5b): a `SwitchInt` on a constant or runtime check, lowered
to an `imm` into a frame temporary and a switch on it.

`sim_switchStatic` has `sim_switch`'s shape and outcome (`SwitchOut`, `SimSwitch.lean`), without
its liveness hypothesis (the operand reads no local):

- L0 (`switch_static_inv`): the switch goes to `caseTarget cases otherwise x`, `x` the
  operand's `staticOpnd` value, its state otherwise unchanged (as `SimReach.lean`'s
  `switch_static_target`, which states only the stack).
- R's `imm` writes `x`'s `n` bytes to the temporary `t` (`opSem_imm_fwd`): a private write
  (`privOk`, through `FnRel.esc`) to bytes no local's slot meets (`tempApart`), so `FnRel`
  holds after it (`FnRel.writeTemp`, `LocalRel.writeFrame_apart` per local) and `t` reads back
  as `x` (`readFrame_written`, `decodeBits_encodeBits`).
- `walk_run`: R's run of the rest from there, by induction on the instructions, each step as
  `staticWalk` computes it (`opSem_brCmpImm_fwd`, `opSem_br_fwd`, `opSem_switchDense_fwd`,
  `jmp`), ends at a place `hitOk` for `x` with R's state unchanged; `hit_finish` concludes.

`LowerSwitchStatic.term_next` is `term_nextX`'s case for the rule (the target is one of the
switch's `termSuccs`, memory unchanged).
-/
import Ryo.Proofs.Lower.SimSwitch
import Ryo.Proofs.Lower.SimCmp
import Ryo.Check.Lower.SwitchStatic

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-! ### L0 -/

/-- A `SwitchInt` on a statically known operand goes to that value's target.

Proof: `switch_static_target`'s (`SimReach.lean`) per `staticOpnd_cases`, keeping the whole
state from `runOn_jumpTo`. -/
theorem switch_static_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Operand} {n x : Nat}
    (hd : staticOpnd d = some (n, x)) {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    (h : runOn (evalTerminator (.switchInt d cases otherwise)) o s = (.ok (), s')) :
    s' = { s with stack := { f with bb := caseTarget cases otherwise x, stmt := 0 } :: rest } := by
  have e : evalTerminator (.switchInt d cases otherwise) = (evalOperand d >>= fun w =>
      switchBits w >>= fun bits =>
      match cases.find? (·.1 == bits) with
      | some (_, bb) => SemM.jumpTo bb
      | none => SemM.jumpTo otherwise) := rfl
  rw [e] at h
  obtain ⟨w, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨bits', s2, h3, h4⟩ := runOn_bind_ok h2
  have key : bits' = x ∧ s2 = s := by
    rcases staticOpnd_cases hd with ⟨b, rfl, rfl, rfl⟩ | ⟨b, t, v, rfl, -, rfl, rfl⟩ |
        ⟨k, b, rfl, rfl, rfl⟩
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
    exact (prod_ok_inj h4).2.symm
  · simp only [hf] at h4 ⊢
    rw [runOn_jumpTo hs] at h4
    exact (prod_ok_inj h4).2.symm

/-- `term_nextX`'s case for the rule: L0's target is one of the switch's successors.

Proof: `switch_static_inv`; `caseTarget` is a case's block (`List.mem_of_find?_eq_some`) or
`otherwise`, as in `term_nextX`'s switch case. -/
theorem _root_.Ryo.Check.Lower.LowerSwitchStatic.term_next {Γ : TermCtx} {next : Nat}
    {term : Terminator} {is : List Insn} (hlow : LowerSwitchStatic Γ next term is)
    {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    (hs : s.stack = f :: rest) (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    ∃ b', b' ∈ termSuccs term ∧ s'.stack = { f with bb := b', stmt := 0 } :: rest ∧
      s'.mem = s.mem := by
  cases hlow with
  | mk d cs ow n x i tl a hd hi hoff hpriv hap hok =>
    have hs' := switch_static_inv hs hd h
    subst hs'
    refine ⟨_, ?_, rfl, rfl⟩
    simp only [termSuccs, List.mem_append, List.mem_map, List.mem_singleton]
    unfold caseTarget
    cases hf : cs.find? (·.1 == x) with
    | none => exact .inr rfl
    | some p => exact .inl ⟨p, List.mem_of_find?_eq_some hf, rfl⟩

/-! ### The temporary -/

/-- A private frame write reads back. -/
theorem readFrame_written {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') (hp : ∀ i < bs.length, st.escapedAt (off + i) = none) :
    st'.readFrame off bs.length = .ok bs := by
  obtain ⟨-, hea, hfr⟩ := writeFrame_private_eq h hp
  have hb : ∀ i < bs.length, st'.byteAt (off + i) = .ok (bs.getD i .uninit) := by
    intro i hi
    rw [OpSem.State.byteAt, hea, hp i hi]
    show (pure (st'.frame (off + i)) : OpSem.M AbstractByte) = .ok (bs.getD i .uninit)
    have hpi : st.privateIn off bs.length (off + i) = true := by
      simp only [OpSem.State.privateIn, hp i hi, Option.isNone_none, Bool.and_true,
        decide_eq_true_eq]
      omega
    rw [hfr]
    simp only [hpi, ↓reduceIte]
    have ht : (off + (i : Int) - off).toNat = i := by omega
    rw [ht] <;> rfl
  rw [readFrame_eq_map (g := fun i => bs.getD i .uninit) hb]
  congr 1
  apply List.ext_getElem (by simp)
  intro k h1 h2
  simp [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h2]

/-- `FnRel` after a private write to bytes no local's slot meets.

Proof: `writeFrame_private_eq` (memory and escapes unchanged); each local by
`LocalRel.writeFrame_apart`; the rest doesn't look at R's frame. -/
theorem FnRel.writeTemp {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : RState} (hrel : FnRel Γ ι live f m0 s1) {a : Int}
    {bs : List AbstractByte} {st' : OpSem.State} (hwr : s1.st.writeFrame a bs = .ok st')
    (hpw : ∀ k < bs.length, s1.st.escapedAt (a + k) = none)
    (hap : ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
      a + bs.length ≤ sl.off ∨ sl.off + sl.size ≤ a) (pc' : Nat) :
    FnRel Γ ι live f m0 { s1 with pc := pc', st := st' } := by
  obtain ⟨hmem, hea, -⟩ := writeFrame_private_eq hwr hpw
  refine ⟨⟨?_, ?_⟩, hrel.hidden, hrel.unaliased, hrel.provNe, hrel.apart, ?_⟩
  · show MemInj ι m0 st'.mem
    rw [hmem]
    exact hrel.frame.mem
  · intro l p hp hal
    obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
    exact ⟨slot, hsl, LocalRel.writeFrame_apart hr hwr hpw (hap l slot hsl)⟩
  · intro o e he
    apply hrel.esc o e
    have h2 : st'.escapedAt o = some e := he
    rw [hea] at h2
    exact h2

/-! ### R's run -/

/-- R's run of a `staticWalk` range with slot `a` holding `x`: to a correct place for `x`, its
state unchanged (see the module comment).

Proof: induction on the instructions. `[]`: `hat.hnext`. A `br.eq.imm` (`brImmOps_spec`,
`operands4`, the fits from `hpl`) steps by `opSem_brCmpImm_fwd` and `step_branch`; taken, the
check is `hitOk` at its target, else the induction hypothesis on `hat.tail`. A `br` the same by
`opSem_br_fwd` (`n = 1`). A `switch.dense` (`denseOps_spec`, `operandsDense`) by
`opSem_switchDense_fwd` and `stepBody_switch` to the entry the check picked. A `jmp` by
`stepBody_jmp`. -/
theorem walk_run {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} (hmode : c.mode = Γ.mode)
    (hρ : c.ρ = Γ.ρ) {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {n : Nat}
    {a : Int} {x : Nat} (hoff : -2 ^ 31 ≤ a ∧ a < 2 ^ 31) {bs : List AbstractByte}
    (hu : OpSem.asNat bs = .ok x) :
    ∀ {is : List Insn} {s1 : RState} {next : Nat},
      staticWalk Γ next cases otherwise n a x is = true → TermAt c s1 next is →
      (∀ i ∈ is, PlainView c.mode c.ρ i) → s1.st.readFrame a n = .ok bs →
      ∃ s2, StepsTo c ch s1 s2 ∧ hitOk Γ cases otherwise x s2.pc = true ∧
        s2.st = s1.st ∧ s2.fp = s1.fp := by
  intro is
  induction is with
  | nil =>
    intro s1 next hok hat _ _
    refine ⟨s1, .refl _, ?_, rfl, rfl⟩
    have h := hat.hnext
    simp only [List.length_nil, Nat.add_zero] at h
    subst h
    simpa only [staticWalk] using hok
  | cons i tl ih =>
    intro s1 next hok hat hpl hrf
    obtain ⟨hi0, hs0⟩ := hat.head
    have hpli : PlainView c.mode c.ρ i := hpl i (List.mem_cons_self ..)
    have hpl' : ∀ j ∈ tl, PlainView c.mode c.ρ j := fun j hj => hpl j (List.mem_cons_of_mem _ hj)
    simp only [staticWalk] at hok
    split at hok
    next a' y neg t hb =>
      -- `br.eq.imm`
      rw [Bool.and_eq_true] at hok
      obtain ⟨ha, hok⟩ := hok
      have ha' : a' = a := by simpa using ha
      rw [ha'] at hb
      obtain ⟨vw, tyS, r, hvw, hh, htyS, hops, hctl, hn, hk⟩ := brImmOps_spec hb
      obtain ⟨sg, hparse⟩ := intTyOk_spec htyS
      obtain ⟨k2, k3, k4, ho⟩ := operands4 hn hk
      rw [← hmode, ← hρ] at hvw
      have hfits := hpli.fits vw hvw
      rw [ho, hops] at hfits
      simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
        Bool.and_true, Bool.and_eq_true] at hfits
      obtain ⟨hfa, hk2, hk3, hk4⟩ := hfits
      have hop : OpSem.opSem vw.op vw.ops s1.st ch =
          .ok (.branch (BitVec.ofNat (8 * n) x == BitVec.ofNat (8 * n) y), s1.st) := by
        rw [hops]; exact opSem_brCmpImm_fwd hh hparse ho hfa hk2 hk3 hk4 hrf hu
      have hstep := step_branch hi0 hs0 hat.pe hpli hvw hctl hop
      cases hc : ((BitVec.ofNat (8 * n) x == BitVec.ofNat (8 * n) y) != neg)
      · simp only [hc, Bool.false_eq_true, ↓reduceIte] at hok
        simp only [hc, Bool.false_eq_true, ↓reduceIte] at hstep
        obtain ⟨s2, hst2, hhit2, hsst, hfp⟩ :=
          @ih { s1 with pc := s1.pc + 1 } next hok hat.tail hpl' hrf
        exact ⟨s2, .cons hstep hst2, hhit2, hsst, hfp⟩
      · simp only [hc, ↓reduceIte] at hok
        simp only [hc, ↓reduceIte] at hstep
        refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
        exact hok
    next hb1 =>
      split at hok
      next sa neg t hb =>
        -- `br` on a byte
        rw [Bool.and_eq_true, Bool.and_eq_true] at hok
        obtain ⟨⟨hsa, hn1⟩, hok⟩ := hok
        have hsa' : sa = a := by simpa using hsa
        have hn1' : n = 1 := by simpa using hn1
        subst hsa' hn1'
        obtain ⟨vw, r, hvw, hh, hops, hctl, ho⟩ := brOps_spec hb
        rw [← hmode, ← hρ] at hvw
        have hop : OpSem.opSem vw.op vw.ops s1.st ch = .ok (.branch (x != 0), s1.st) := by
          rw [hops]; exact opSem_br_fwd hh ho hoff.1 hoff.2 hrf hu
        have hstep := step_branch hi0 hs0 hat.pe hpli hvw hctl hop
        cases hc : ((x != 0) != neg)
        · simp only [hc, Bool.false_eq_true, ↓reduceIte] at hok
          simp only [hc, Bool.false_eq_true, ↓reduceIte] at hstep
          obtain ⟨s2, hst2, hhit2, hsst, hfp⟩ :=
            @ih { s1 with pc := s1.pc + 1 } next hok hat.tail hpl' hrf
          exact ⟨s2, .cons hstep hst2, hhit2, hsst, hfp⟩
        · simp only [hc, ↓reduceIte] at hok
          simp only [hc, ↓reduceIte] at hstep
          refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
          exact hok
      next hb2 =>
        split at hok
        next a' y len ts hden =>
          -- `switch.dense`
          rw [Bool.and_eq_true] at hok
          obtain ⟨ha, hok⟩ := hok
          have ha' : a' = a := by simpa using ha
          rw [ha'] at hden
          obtain ⟨vw, tyS, r, hvw, hh, htyS, hops, hctl, hn, hk, hlen⟩ := denseOps_spec hden
          obtain ⟨sg, hparse⟩ := intTyOk_spec htyS
          obtain ⟨k2, k3, k4, ho⟩ := operandsDense hn hk
          rw [← hmode, ← hρ] at hvw
          have hfits := hpli.fits vw hvw
          rw [ho, hops] at hfits
          simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
            Bool.and_true, Bool.and_eq_true] at hfits
          obtain ⟨hfa, hk2, hk3, hk4⟩ := hfits
          have hop : OpSem.opSem vw.op vw.ops s1.st ch =
              .ok (.index
                (if (BitVec.ofNat (8 * n) x - BitVec.ofNat (8 * n) y).toNat < len then
                  (BitVec.ofNat (8 * n) x - BitVec.ofNat (8 * n) y).toNat
                else len), s1.st) := by
            rw [hops]; exact opSem_switchDense_fwd hh hparse ho hfa hk2 hk3 hk4 hrf hu
          have hnat : ViewShape i := by
            intro op ops he f hf
            subst he
            exact shapes_of_opShape (view_native_opShape hvw hf (by rw [hctl]; rfl))
          split at hok
          next t ht =>
            have hstep : R.step c s1 ch = .ok (.step { s1 with pc := t }) := by
              rw [step_eq_stepBody_nil hi0 hs0]
              exact stepBody_switch hnat hvw hctl (hpli.notResume _ hvw (ctl_ne_trap hctl))
                (hpli.notUnreachable _ hvw (ctl_ne_trap hctl)) hat.pe hop ht
            refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
            exact hok
          next => cases hok
        next hb3 =>
          -- `jmp`
          split at hok
          next t hj =>
            obtain ⟨op, f, rfl, hf, hsh⟩ := jmpTo_spec hj
            have hstep : R.step c s1 ch = .ok (.step { s1 with pc := t }) := by
              rw [step_eq_stepBody_nil hi0 hs0, stepBody_jmp hf hsh]
            refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
            exact hok
          next => cases hok

/-! ### The rule -/

/-- A `SwitchInt` on a statically known operand (see the module comment).

Proof: `switch_static_inv` for L0. R's first step is the `imm` (`immInsnOk_spec`,
`opSem_imm_fwd`, `step_of_view`), a private write (`hpriv` against `hrel.esc`) keeping `FnRel`
(`FnRel.writeTemp`, `tempApart_spec`) and leaving `x` in the temporary (`readFrame_written`,
`decodeBits_encodeBits` with the immediate's low bits); then `walk_run` and `hit_finish`, its
steps prefixed by the `imm`'s. -/
theorem sim_switchStatic {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {term : Terminator}
    {is : List Insn} (hlow : LowerSwitchStatic Γ next term is)
    (hat : TermAt c s1 next is) (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    SwitchOut Γ c ch ι live' s s' f rest s1 := by
  cases hlow with
  | mk d cs ow n x i tl a hd hi hoff hpriv hap hok =>
    have hs' := switch_static_inv hs hd h
    have hx := staticOpnd_lt hd
    -- the `imm`
    obtain ⟨hi0, hs0⟩ := hat.head
    have hpli : PlainView c.mode c.ρ i := hpl i (List.mem_cons_self ..)
    obtain ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩ := immInsnOk_spec hi
    rw [← hmode, ← hρ] at hv
    obtain ⟨sg, hparse⟩ := intTyOk_spec hty
    obtain ⟨y, hops', hy⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands2 hn hk
    have hops'' : v.ops = [.slot a, .imm y] := hops'
    have hfk : OpSem.Val.fits k (.imm y) = true :=
      fits_last (hpli.fits v hv) (by rw [ho, hops'']; simp)
    have hlenI : (OpSem.intBytes n y).length = n := Ryo.Spec.Theorems.encodeBits_length n y
    have hpw : ∀ j < (OpSem.intBytes n y).length, s1.st.escapedAt (a + j) = none := by
      intro j hj
      rw [hlenI] at hj
      cases he : s1.st.escapedAt (a + j) with
      | none => rfl
      | some e =>
        have h1 := hrel.esc _ _ he
        rw [hpriv j hj] at h1
        cases h1
    obtain ⟨st', hwr⟩ : ∃ st', s1.st.writeFrame a (OpSem.intBytes n y) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hop := opSem_imm_fwd (ch := ch) hh hparse ho (offOk_spec hoff) hfk hwr
    have hstep : R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) :=
      step_of_view hi0 hs0 hat.pe hpli hv hctl (by rw [hops'']; exact hop)
    have hrel' := hrel.writeTemp hwr hpw
      (fun l sl hsl => by rw [hlenI]; exact tempApart_spec hap hsl) (s1.pc + 1)
    -- the temporary holds `x`
    have hrb := readFrame_written hwr hpw
    rw [hlenI] at hrb
    have hdec : decodeBits (OpSem.intBytes n y) = some x := by
      show decodeBits (encodeBits n y) = some x
      rw [Ryo.Spec.Theorems.decodeBits_encodeBits, hy, Nat.mod_eq_of_lt hx]
    have hasn : OpSem.asNat (OpSem.intBytes n y) = .ok x := by
      unfold OpSem.asNat; rw [hdec] <;> rfl
    -- the switch on it
    have hat' : TermAt c { s1 with pc := s1.pc + 1, st := st' } next tl :=
      ⟨hat.tail.code, hat.tail.scopes, hat.tail.hnext, hat.pe⟩
    obtain ⟨s2, hst, hhit, hsst, hfp⟩ := walk_run (ch := ch) hmode hρ (offOk_spec hoff) hasn
      hok hat' (fun j hj => hpl j (List.mem_cons_of_mem _ hj)) hrb
    rcases hit_finish hs' hst hhit hsst hfp hrel' hw with ⟨s1', f', hst', hrest⟩ | hdead
    · exact .inl ⟨s1', f', .cons hstep hst', hrest⟩
    · exact .inr hdead

end Ryo.Proofs.Lower
