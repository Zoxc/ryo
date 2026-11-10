/-
Ryo.Proofs.Lower.TermSimX — the terminators with pending scopes (aot.md §C1, M5b; the
"Terminators" paragraph of `FnRelEsc.lean`): a terminator range whose first index carries the
`End`s of the block's last instruction-less statements (`StorageDead(_2); return`).

`TermAtX c s1 s0 next is` is `SimTerm.TermAt` with scopes allowed at the first index: R is at
`s1`, the scopes there fold to `s0` (an empty range has none and `s0 = s1`), and every later
index has none. The first step goes through `step_eq_stepBody` from `s0` (`step_branchX`, the
`jmp`s); the rest of the range is a `TermAt` from `{ s0 with pc := s0.pc + 1 }`
(`TermAtX.tail`), on which `SimTerm`'s `goto_run` and `SimSwitch`'s `chain_run` apply unchanged.
`TermAt` itself and its M5a users are untouched.

The rules' simulations are `SimTerm`'s and `SimSwitch`'s with `FnRel` at `s0` and the first step
taken this way; they also state that R's state and `fp` at the target are `s0`'s (`TermOutX`,
`SwitchOutX`), which the function level needs to carry `FnRelX`'s object invariants:
`sim_termX` (`goto`, `SwitchInt` without or with one case), `sim_switchX` (`br.eq.imm` chains,
`switch.dense`; `chain_runX`, `dense_runX`), `sim_switchStaticX` (`SimSwitchStatic`: the
temporary's `imm` after the scopes, then `walk_run`), `sim_termMoreX` (`SimTermMore`: the
assert's `br` after the scopes, `br_bool_stepX`; `resume` through `step_dropScopes`). `return` is `SimRetX.sim_retX` on `c.dropScopes`
from `s0` (`TermAtX.drop`): `ret`'s step doesn't read the scopes, so it is the real code's from
`s1` (`step_ret_drop`), giving `sim_retXX`.
-/
import Ryo.Proofs.Lower.FnRelEsc
import Ryo.Proofs.Lower.FnStep
import Ryo.Proofs.Lower.GlobKept

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-! ### R's side -/

/-- A terminator range's instructions at R's consecutive indices from `s1.pc`, scopes only at
the first, folded to `s0` (see the module comment). -/
structure TermAtX (c : Code) (s1 s0 : RState) (next : Nat) (is : List Insn) : Prop where
  code : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj)
  scopes : ∀ j, 0 < j → j < is.length → c.scopesAt (s1.pc + j) = []
  fold : is ≠ [] → (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0
  nil : is = [] → s0 = s1
  hnext : s1.pc + is.length = next
  pe : c.mode.pe = false

theorem TermAtX.pc_fp {c : Code} {s1 s0 : RState} {next : Nat} {is : List Insn}
    (hat : TermAtX c s1 s0 next is) : s0.pc = s1.pc ∧ s0.fp = s1.fp := by
  cases is with
  | nil =>
    have e := hat.nil rfl
    subst e
    exact ⟨rfl, rfl⟩
  | cons i tl => exact scopes_pc_fp (hat.fold (List.cons_ne_nil i tl))

theorem TermAtX.head {c : Code} {s1 s0 : RState} {next : Nat} {i : Insn} {tl : List Insn}
    (hat : TermAtX c s1 s0 next (i :: tl)) :
    c.d.insns[s1.pc]? = some i ∧ (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0 := by
  have h1 := hat.code 0 (by simp)
  simp only [Nat.add_zero, List.getElem_cons_zero] at h1
  exact ⟨h1, hat.fold (List.cons_ne_nil i tl)⟩

/-- After the first instruction: a scope-free `TermAt` from the fold. -/
theorem TermAtX.tail {c : Code} {s1 s0 : RState} {next : Nat} {i : Insn} {tl : List Insn}
    (hat : TermAtX c s1 s0 next (i :: tl)) : TermAt c { s0 with pc := s0.pc + 1 } next tl := by
  have hpc : s0.pc = s1.pc := hat.pc_fp.1
  refine ⟨fun j hj => ?_, fun j hj => ?_, ?_, hat.pe⟩
  · have h := hat.code (j + 1) (by simp only [List.length_cons]; omega)
    have e : s0.pc + 1 + j = s1.pc + (j + 1) := by omega
    show c.d.insns[s0.pc + 1 + j]? = _
    rw [e, h]
    rfl
  · have h := hat.scopes (j + 1) (by omega) (by simp only [List.length_cons]; omega)
    have e : s0.pc + 1 + j = s1.pc + (j + 1) := by omega
    show c.scopesAt (s0.pc + 1 + j) = []
    rw [e]; exact h
  · have h := hat.hnext
    simp only [List.length_cons] at h
    show s0.pc + 1 + tl.length = next
    omega

/-- The scope-free code from the fold. -/
theorem TermAtX.drop {c : Code} {s1 s0 : RState} {next : Nat} {is : List Insn}
    (hat : TermAtX c s1 s0 next is) : TermAt c.dropScopes s0 next is := by
  have hpc : s0.pc = s1.pc := hat.pc_fp.1
  refine ⟨fun j hj => ?_, fun j _ => dropScopes_scopesAt c _, ?_, hat.pe⟩
  · rw [hpc]; exact hat.code j hj
  · rw [hpc]; exact hat.hnext

/-- A branch whose `opSem` leaves the state, after the scopes at its index. -/
theorem step_branchX {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {neg b : Bool} {x : Nat} (hi : c.d.insns[s1.pc]? = some i)
    (hsc : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0)
    (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i) (hv : view c.mode c.ρ i = some v)
    (hctl : v.ctl = some (.branch neg x))
    (hop : OpSem.opSem v.op v.ops s0.st ch = .ok (.branch b, s0.st)) :
    R.step c s1 ch = .ok (.step { s0 with pc := if b != neg then x else s0.pc + 1 }) := by
  rw [step_eq_stepBody hi hsc]
  have hnat : ViewShape i := by
    intro op ops he f hf
    subst he
    exact shapes_of_opShape (view_native_opShape hv hf (by rw [hctl]; rfl))
  exact stepBody_br hnat hv hctl (hpl.notResume v hv (ctl_ne_trap hctl))
      (hpl.notUnreachable v hv (ctl_ne_trap hctl)) hpe hop

/-- `goto_run` from `TermAtX`. -/
theorem goto_runX {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {s1 s0 : RState} {next : Nat}
    {bb : BasicBlock} {is : List Insn} (hg : gotoOk Γ next bb is = true)
    (hat : TermAtX c s1 s0 next is) :
    ∃ s2, StepsTo c ch s1 s2 ∧ blockStart Γ bb = some s2.pc ∧ s2.st = s0.st ∧
      s2.fp = s0.fp := by
  rcases gotoOk_spec hg with ⟨rfl, hb⟩ | ⟨i, t, rfl, hj, hb⟩
  · have e := hat.nil rfl
    refine ⟨s1, .refl _, ?_, by rw [e], by rw [e]⟩
    have h := hat.hnext
    simp only [List.length_nil, Nat.add_zero] at h
    rw [hb, h]
  · obtain ⟨op, f, rfl, hf, hsh⟩ := jmpTo_spec hj
    obtain ⟨hi, hsc⟩ := hat.head
    have hstep : R.step c s1 ch = .ok (.step { s0 with pc := t }) := by
      rw [step_eq_stepBody hi hsc, stepBody_jmp hf hsh]
    exact ⟨{ s0 with pc := t }, .cons hstep (.refl _), hb, rfl, rfl⟩

/-- `branch_run` from `TermAtX`. -/
theorem branch_runX {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {s1 s0 : RState} {next : Nat}
    {ibr : Insn} {tl : List Insn} {neg cb : Bool} {t : Nat} {sel : Bool → BasicBlock}
    (hstep : R.step c s1 ch = .ok (.step { s0 with pc := if cb != neg then t else s0.pc + 1 }))
    (hsel : selOk Γ next neg t sel tl = true) (hat : TermAtX c s1 s0 next (ibr :: tl)) :
    ∃ s2, StepsTo c ch s1 s2 ∧ blockStart Γ (sel cb) = some s2.pc ∧ s2.st = s0.st ∧
      s2.fp = s0.fp := by
  obtain ⟨h1, h2⟩ := selOk_spec hsel cb
  cases hc : (cb != neg)
  · rw [hc] at hstep
    simp only [Bool.false_eq_true, if_false, ↓reduceIte] at hstep
    obtain ⟨s2, hst2, hb, hsst, hfp, -⟩ := goto_run (ch := ch) (h2 hc) hat.tail
    exact ⟨s2, .cons hstep hst2, hb, hsst, hfp⟩
  · rw [hc] at hstep
    simp only [eq_self_iff_true, if_true, ↓reduceIte] at hstep
    exact ⟨_, .cons hstep (.refl _), h1 hc, rfl, rfl⟩

/-! ### The rules -/

/-- A terminator's simulation: R reaches L0's target block's start with its escaped objects,
memory and `fp` those of the fold `s0` (a static switch's temporary changes R's private frame
bytes, nothing else), and `FnRel` holds there. -/
def TermOutX (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (s s' : Spec.State) (f : Spec.Frame) (rest : List Spec.Frame) (s1 s0 : RState) : Prop :=
  ∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.stmt = 0 ∧ f'.body = f.body ∧
    blockStart Γ f'.bb = some s1'.pc ∧ s'.mem = s.mem ∧ s1'.st.escaped = s0.st.escaped ∧
    s1'.st.mem = s0.st.mem ∧ s1'.fp = s0.fp ∧ FnRel Γ.toStmtCtx ι live' f' s'.mem s1'

/-- `SwitchOut` with `TermOutX`. -/
def SwitchOutX (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (s s' : Spec.State) (f : Spec.Frame) (rest : List Spec.Frame) (s1 s0 : RState) : Prop :=
  TermOutX Γ c ch ι live' s s' f rest s1 s0 ∨
    ∃ ow, s'.stack = { f with bb := ow, stmt := 0 } :: rest ∧ deadBlock Γ ow = true

theorem term_finishX {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    {s1 s0 s2 : RState} {X : BasicBlock}
    (hs' : s' = { s with stack := { f with bb := X, stmt := 0 } :: rest })
    (hst : StepsTo c ch s1 s2) (hb : blockStart Γ X = some s2.pc) (hsst : s2.st = s0.st)
    (hfp : s2.fp = s0.fp) (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0)
    (hw : ∀ l, live' l = true → live l = true) :
    TermOutX Γ c ch ι live' s s' f rest s1 s0 := by
  subst hs'
  exact ⟨s2, { f with bb := X, stmt := 0 }, hst, rfl, rfl, rfl, hb, rfl, by rw [hsst],
    by rw [hsst], hfp, (hrel.weaken hw).congr rfl rfl hsst hfp⟩

theorem sim_gotoX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {next : Nat} {bb : BasicBlock}
    {is : List Insn} (hg : gotoOk Γ next bb is = true) (hat : TermAtX c s1 s0 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.goto bb)) o s = (.ok (), s')) :
    TermOutX Γ c ch ι live' s s' f rest s1 s0 := by
  obtain ⟨s2, hst, hb, hsst, hfp⟩ := goto_runX (ch := ch) hg hat
  exact term_finishX (goto_inv hs h) hst hb hsst hfp hrel hw

theorem sim_switchNoneX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest) {next : Nat}
    {d : Operand} {l : Local} {otherwise : BasicBlock} {is : List Insn} (hd : d.local? = some l)
    (hg : gotoOk Γ next otherwise is = true) (hat : TermAtX c s1 s0 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.switchInt d [] otherwise)) o s = (.ok (), s')) :
    TermOutX Γ c ch ι live' s s' f rest s1 s0 := by
  obtain ⟨p0, ty0, v0, bits0, hp0, hty0, hload0, hsw0, hs'⟩ := switchInt_inv hs hd h
  simp only [List.find?_nil] at hs'
  obtain ⟨s2, hst, hb, hsst, hfp⟩ := goto_runX (ch := ch) hg hat
  exact term_finishX hs' hst hb hsst hfp hrel hw

/-- `sim_switchBool` from `TermAtX`. -/
theorem sim_switchBoolX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat}
    {d : Operand} {l : Local} {vc : Nat} {bb otherwise : BasicBlock} {sl : LocalSlot}
    {ibr : Insn} {tl : List Insn} {sv : Int} {neg : Bool} {t : Nat}
    (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some .bool)
    (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = 1) (hoff : offOk sl.off = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (sv, neg, t)) (hsv : sv = sl.off) (hv : vc < 2)
    (hsel : selOk Γ next neg t (selBool vc bb otherwise) tl = true)
    (hat : TermAtX c s1 s0 next (ibr :: tl)) (hpl : PlainView c.mode c.ρ ibr)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hlive : live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.switchInt d [(vc, bb)] otherwise)) o s = (.ok (), s')) :
    TermOutX Γ c ch ι live' s s' f rest s1 s0 := by
  subst hsv
  obtain ⟨p, ty0, v, bits, hp, hty', hload, hsw, hs'⟩ := switchInt_inv hs hd h
  rw [← hbody, hty] at hty'
  obtain rfl := (Option.some.inj hty').symm
  obtain ⟨dd, pr, hld, hcase⟩ := typedLoad_bool hload
  -- R reads the related byte
  have hr := hrel.opnd hp hsl hlive
  have hld' : s.mem.load p sl.size .one = .ok [.init dd pr] := by rw [hsize]; exact hld
  obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld'
  have hdec0 : decodeBits [AbstractByte.init dd pr] = some (leDecode [dd]) := rfl
  have hdec1 := decodeBits_inj hbi hdec0
  have hasn : OpSem.asNat bs1 = .ok (leDecode [dd]) := by
    unfold OpSem.asNat; rw [hdec1]; rfl
  obtain ⟨vw, r, hvw, hh, hops, hctl, ho⟩ := brOps_spec hbr
  rw [← hmode, ← hρ] at hvw
  obtain ⟨h1, h2⟩ := offOk_spec hoff
  have hrf' : s0.st.readFrame sl.off 1 = .ok bs1 := by rw [← hsize]; exact hrf
  have hop : OpSem.opSem vw.op vw.ops s0.st ch = .ok (.branch (leDecode [dd] != 0), s0.st) := by
    rw [hops]; exact opSem_br_fwd hh ho h1 h2 hrf' hasn
  obtain ⟨hi0, hs0⟩ := hat.head
  have hstep := step_branchX hi0 hs0 hat.pe hpl hvw hctl hop
  obtain ⟨s2, hst2, hb2, hsst, hfp2⟩ := branch_runX hstep hsel hat
  -- L0's target
  obtain ⟨b, rfl, hcb⟩ : ∃ b, v = .bool b ∧ (leDecode [dd] != 0) = b := by
    rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨false, rfl, by decide⟩
    · exact ⟨true, rfl, by decide⟩
  rw [hcb] at hb2
  have hbits : bits = if b then 1 else 0 := by
    have e : runOn (switchBits (.bool b, .bool)) o s = (.ok (if b then 1 else 0), s) := rfl
    rw [e] at hsw
    simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
    exact hsw.1.symm
  subst hbits
  rw [find_single] at hs'
  by_cases hvb : vc = (if b then 1 else 0)
  · rw [if_pos hvb] at hs'
    dsimp only at hs'
    rw [← bool_target hv bb otherwise, if_pos hvb] at hb2
    exact term_finishX hs' hst2 hb2 hsst hfp2 hrel hw
  · rw [if_neg hvb] at hs'
    dsimp only at hs'
    rw [← bool_target hv bb otherwise, if_neg hvb] at hb2
    exact term_finishX hs' hst2 hb2 hsst hfp2 hrel hw

/-- `sim_switchInt` from `TermAtX`. -/
theorem sim_switchIntX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat}
    {d : Operand} {l : Local} {vc : Nat} {bb otherwise : BasicBlock} {sl : LocalSlot}
    {ty : IntType} {valid : ValidRange}
    {ibr : Insn} {tl : List Insn} {a : Int} {y : Nat} {neg : Bool} {t : Nat}
    (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some (.int ty valid))
    (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = ty.size) (hoff : offOk sl.off = true)
    (hbr : brImmOps Γ.toStmtCtx ibr ty.size = some (a, y, neg, t)) (ha : a = sl.off)
    (hy : y % 2 ^ (8 * ty.size) = vc)
    (hsel : selOk Γ next neg t (selInt bb otherwise) tl = true)
    (hat : TermAtX c s1 s0 next (ibr :: tl)) (hpl : PlainView c.mode c.ρ ibr)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hlive : live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.switchInt d [(vc, bb)] otherwise)) o s = (.ok (), s')) :
    TermOutX Γ c ch ι live' s s' f rest s1 s0 := by
  subst ha
  obtain ⟨p, ty0, v, bits, hp, hty', hload, hsw, hs'⟩ := switchInt_inv hs hd h
  rw [← hbody, hty] at hty'
  obtain rfl := (Option.some.inj hty').symm
  obtain ⟨bs, u, hld, hdb, -, rfl⟩ := typedLoad_int hload
  -- R reads the related bytes
  have hr := hrel.opnd hp hsl hlive
  have hld' : s.mem.load p sl.size .one = .ok bs := by rw [hsize]; exact hld
  obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld'
  have hdec1 := decodeBits_inj hbi hdb
  have hasn : OpSem.asNat bs1 = .ok u := by
    unfold OpSem.asNat; rw [hdec1]; rfl
  obtain ⟨vw, tyS, r, hvw, hh, htyS, hops, hctl, hn, hk⟩ := brImmOps_spec hbr
  obtain ⟨sg, hparse⟩ := intTyOk_spec htyS
  obtain ⟨k2, k3, k4, ho⟩ := operands4 hn hk
  rw [← hmode, ← hρ] at hvw
  obtain ⟨h1, h2⟩ := offOk_spec hoff
  have hfits := hpl.fits vw hvw
  rw [ho, hops] at hfits
  simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil, Bool.and_true,
    Bool.and_eq_true] at hfits
  obtain ⟨hfa, hk2, hk3, hk4⟩ := hfits
  have hrf' : s0.st.readFrame sl.off ty.size = .ok bs1 := by rw [← hsize]; exact hrf
  have hop : OpSem.opSem vw.op vw.ops s0.st ch =
      .ok (.branch (BitVec.ofNat (8 * ty.size) u == BitVec.ofNat (8 * ty.size) y), s0.st) := by
    rw [hops]; exact opSem_brCmpImm_fwd hh hparse ho hfa hk2 hk3 hk4 hrf' hasn
  obtain ⟨hi0, hs0⟩ := hat.head
  have hstep := step_branchX hi0 hs0 hat.pe hpl hvw hctl hop
  obtain ⟨s2, hst2, hb2, hsst, hfp2⟩ := branch_runX hstep hsel hat
  -- L0's target
  have hcb : (BitVec.ofNat (8 * ty.size) u == BitVec.ofNat (8 * ty.size) y) =
      (u % 2 ^ (8 * ty.size) == vc) := by
    rw [bv_ofNat_beq, hy]
  rw [hcb] at hb2
  have hbits : bits = u % 2 ^ (8 * ty.size) := by
    have e : runOn (switchBits (.int (ty.ofBits u), .int ty valid)) o s =
        (.ok (ty.toBits (ty.ofBits u)), s) := rfl
    rw [e] at hsw
    simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
    rw [← hsw.1, Ryo.Spec.Theorems.IntType.toBits_ofBits, ← modulus_eq_two_pow]
  subst hbits
  rw [find_single] at hs'
  by_cases hvb : vc = u % 2 ^ (8 * ty.size)
  · rw [if_pos hvb] at hs'
    dsimp only at hs'
    have hc : (u % 2 ^ (8 * ty.size) == vc) = true := by simp [hvb]
    simp only [selInt, hc, eq_self_iff_true, if_true, ↓reduceIte] at hb2
    exact term_finishX hs' hst2 hb2 hsst hfp2 hrel hw
  · rw [if_neg hvb] at hs'
    dsimp only at hs'
    have hc : (u % 2 ^ (8 * ty.size) == vc) = false := by
      simp only [beq_eq_false_iff_ne, ne_eq]
      exact fun e => hvb e.symm
    simp only [selInt, hc, Bool.false_eq_true, if_false, ↓reduceIte] at hb2
    exact term_finishX hs' hst2 hb2 hsst hfp2 hrel hw

/-- `sim_term` from `TermAtX` (see the module comment). -/
theorem sim_termX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {term : Terminator}
    {is : List Insn} (hlow : LowerTerm Γ next term is) (hnr : term ≠ .return)
    (hat : TermAtX c s1 s0 next is) (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0)
    (hlive : ∀ (d : Operand) cs ow l, term = .switchInt d cs ow → d.local? = some l →
      live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    TermOutX Γ c ch ι live' s s' f rest s1 s0 := by
  cases hlow
  case goto hg => exact sim_gotoX hs hg hat hrel hw h
  case ret => exact absurd rfl hnr
  case switchNone hd hg => exact sim_switchNoneX hs hd hg hat hrel hw h
  case switchBool hd hty hsl hsize hoff hbr hsv hv hsel =>
    exact sim_switchBoolX hs hbody hmode hρ hd hty hsl hsize hoff hbr hsv hv hsel hat
      (hpl _ (by simp)) hrel (hlive _ _ _ _ rfl hd) hw h
  case switchInt hd hty hsl hsize hoff hbr ha hv hy hsel =>
    exact sim_switchIntX hs hbody hmode hρ hd hty hsl hsize hoff hbr ha hy hsel hat
      (hpl _ (by simp)) hrel (hlive _ _ _ _ rfl hd) hw h

/-! ### Switches -/

/-- `chain_run` from `TermAtX`: the first test or `jmp` after the scopes, then `chain_run` on the
rest. -/
theorem chain_runX {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} (hmode : c.mode = Γ.mode)
    (hρ : c.ρ = Γ.ρ) {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {n : Nat}
    {a : Int} {bs : List AbstractByte} {u : Nat} (hu : OpSem.asNat bs = .ok u)
    {ex : List Nat} {is : List Insn} {s1 s0 : RState} {next : Nat}
    (hok : chainOk Γ next cases otherwise n a ex is = true) (hat : TermAtX c s1 s0 next is)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrf : s0.st.readFrame a n = .ok bs)
    (hex : ex.contains (u % 2 ^ (8 * n)) = false) :
    ∃ s2, StepsTo c ch s1 s2 ∧ hitOk Γ cases otherwise (u % 2 ^ (8 * n)) s2.pc = true ∧
      s2.st = s0.st ∧ s2.fp = s0.fp := by
  have hxlt : u % 2 ^ (8 * n) < 2 ^ (8 * n) := Nat.mod_lt _ (Nat.two_pow_pos _)
  have hpc : s0.pc = s1.pc := hat.pc_fp.1
  cases is with
  | nil =>
    have e := hat.nil rfl
    refine ⟨s1, .refl _, ?_, by rw [e], by rw [e]⟩
    have h := hat.hnext
    simp only [List.length_nil, Nat.add_zero] at h
    subst h
    simp only [chainOk] at hok
    exact restOk_spec (ex := fun x => ex.contains x) hok hxlt hex
  | cons i tl =>
    obtain ⟨hi0, hs0⟩ := hat.head
    have hpli : PlainView c.mode c.ρ i := hpl i (by simp)
    simp only [chainOk] at hok
    split at hok
    next a' y neg t hb =>
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
      have hop : OpSem.opSem vw.op vw.ops s0.st ch =
          .ok (.branch (BitVec.ofNat (8 * n) u == BitVec.ofNat (8 * n) y), s0.st) := by
        rw [hops]; exact opSem_brCmpImm_fwd hh hparse ho hfa hk2 hk3 hk4 hrf hu
      have hstep := step_branchX hi0 hs0 hat.pe hpli hvw hctl hop
      rw [bv_ofNat_beq] at hstep
      cases neg
      · -- a test without `neg`: taken on equality, else the rest of the chain
        simp only [Bool.false_eq_true, ↓reduceIte, Bool.and_eq_true, Bool.or_eq_true] at hok
        obtain ⟨hhit, hrest⟩ := hok
        by_cases hxy : u % 2 ^ (8 * n) = y % 2 ^ (8 * n)
        · have hc : ((u % 2 ^ (8 * n) == y % 2 ^ (8 * n)) != false) = true := by simp [hxy]
          simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
          refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
          show hitOk Γ cases otherwise (u % 2 ^ (8 * n)) t = true
          rw [hxy]
          rcases hhit with h | h
          · rw [hxy] at hex; rw [hex] at h; cases h
          · exact h
        · have hc : ((u % 2 ^ (8 * n) == y % 2 ^ (8 * n)) != false) = false := by simp [hxy]
          simp only [hc, Bool.false_eq_true, ↓reduceIte] at hstep
          have hex' : (y % 2 ^ (8 * n) :: ex).contains (u % 2 ^ (8 * n)) = false := by
            first
              | (rw [List.contains_cons, hex, Bool.or_false]; exact beq_eq_false_iff_ne.mpr hxy)
              | simp [hex, hxy]
          obtain ⟨s2, hst2, hhit2, hsst, hfp, -⟩ :=
            chain_run (ch := ch) hmode hρ hu (ex := y % 2 ^ (8 * n) :: ex) hrest hat.tail
              (fun j hj => hpl j (List.mem_cons_of_mem _ hj)) hrf hex'
          exact ⟨s2, .cons hstep hst2, hhit2, hsst, hfp⟩
      · -- the last test, with `neg`: falls through on equality, else branches
        simp only [eq_self_iff_true, if_true, ↓reduceIte, Bool.and_eq_true, Bool.or_eq_true,
          List.isEmpty_iff] at hok
        obtain ⟨⟨htl, hhit⟩, hrest⟩ := hok
        subst htl
        by_cases hxy : u % 2 ^ (8 * n) = y % 2 ^ (8 * n)
        · have hc : ((u % 2 ^ (8 * n) == y % 2 ^ (8 * n)) != true) = false := by simp [hxy]
          simp only [hc, Bool.false_eq_true, ↓reduceIte] at hstep
          have hn' : s0.pc + 1 = next := by
            have h := hat.hnext
            simp only [List.length_cons, List.length_nil] at h
            omega
          refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
          show hitOk Γ cases otherwise (u % 2 ^ (8 * n)) (s0.pc + 1) = true
          rw [hn', hxy]
          rcases hhit with h | h
          · rw [hxy] at hex; rw [hex] at h; cases h
          · exact h
        · have hc : ((u % 2 ^ (8 * n) == y % 2 ^ (8 * n)) != true) = true := by simp [hxy]
          simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
          refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
          show hitOk Γ cases otherwise (u % 2 ^ (8 * n)) t = true
          refine restOk_spec
            (ex := fun x => x == y % 2 ^ (8 * n) || ex.contains x) hrest hxlt ?_
          show (u % 2 ^ (8 * n) == y % 2 ^ (8 * n) || ex.contains (u % 2 ^ (8 * n))) = false
          rw [hex, Bool.or_false]
          exact beq_eq_false_iff_ne.mpr hxy
    next hb =>
      rcases hj : jmpTo i with _ | t
      · rw [hj] at hok
        cases tl <;> simp at hok
      · rw [hj] at hok
        cases tl with
        | cons _ _ => simp at hok
        | nil =>
          obtain ⟨op, f, rfl, hf, hsh⟩ := jmpTo_spec hj
          have hstep : R.step c s1 ch = .ok (.step { s0 with pc := t }) := by
            rw [step_eq_stepBody hi0 hs0, stepBody_jmp hf hsh]
          exact ⟨{ s0 with pc := t }, .cons hstep (.refl _),
            restOk_spec (ex := fun x => ex.contains x) (pc := t) hok hxlt hex, rfl, rfl⟩

/-- `dense_run` from `TermAtX`. -/
theorem dense_runX {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {s1 s0 : RState} {next : Nat}
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {cases : List (Nat × BasicBlock)}
    {otherwise : BasicBlock} {n : Nat} {i : Insn} {a : Int} {y len : Nat} {ts : List Nat}
    (hden : denseOps Γ.toStmtCtx i n = some (a, y, len, ts))
    (hok : denseOk Γ cases otherwise n y len ts = true)
    (hat : TermAtX c s1 s0 next [i]) (hpl : PlainView c.mode c.ρ i)
    {bs : List AbstractByte} {u : Nat} (hrf : s0.st.readFrame a n = .ok bs)
    (hu : OpSem.asNat bs = .ok u) :
    ∃ s2, StepsTo c ch s1 s2 ∧ hitOk Γ cases otherwise (u % 2 ^ (8 * n)) s2.pc = true ∧
      s2.st = s0.st ∧ s2.fp = s0.fp := by
  obtain ⟨vw, tyS, r, hvw, hh, htyS, hops, hctl, hn, hk, hlen⟩ := denseOps_spec hden
  obtain ⟨sg, hparse⟩ := intTyOk_spec htyS
  obtain ⟨k2, k3, k4, ho⟩ := operandsDense hn hk
  rw [← hmode, ← hρ] at hvw
  have hfits := hpl.fits vw hvw
  rw [ho, hops] at hfits
  simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
    Bool.and_true, Bool.and_eq_true] at hfits
  obtain ⟨hfa, hk2, hk3, hk4⟩ := hfits
  have hop : OpSem.opSem vw.op vw.ops s0.st ch =
      .ok (.index
        (if (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat < len then
          (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat
        else len), s0.st) := by
    rw [hops]; exact opSem_switchDense_fwd hh hparse ho hfa hk2 hk3 hk4 hrf hu
  obtain ⟨hi0, hs0⟩ := hat.head
  have hnat : ViewShape i := by
    intro op ops he f hf
    subst he
    exact shapes_of_opShape (view_native_opShape hvw hf (by rw [hctl]; rfl))
  have hm : 0 < 2 ^ (8 * n) := Nat.two_pow_pos _
  have hA : u % 2 ^ (8 * n) < 2 ^ (8 * n) := Nat.mod_lt _ hm
  have hB : y % 2 ^ (8 * n) < 2 ^ (8 * n) := Nat.mod_lt _ hm
  have hidx : (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat =
      (u % 2 ^ (8 * n) + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n) := by
    rw [BitVec.toNat_sub, BitVec.toNat_ofNat, BitVec.toNat_ofNat,
      Nat.add_comm (2 ^ (8 * n) - y % 2 ^ (8 * n))]
  rw [hidx] at hop
  obtain ⟨hmod, hlt⟩ := dense_idx_mod hA hB
  unfold denseOk at hok
  rw [Bool.and_eq_true] at hok
  obtain ⟨hall, hdef⟩ := hok
  by_cases hil : (u % 2 ^ (8 * n) + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n) < len
  · rw [if_pos hil] at hop
    have hget : ts[(u % 2 ^ (8 * n) + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n)]? =
        some ts[(u % 2 ^ (8 * n) + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n)] :=
      List.getElem?_eq_getElem (by omega)
    have hstep : R.step c s1 ch = .ok (.step { s0 with pc :=
        ts[(u % 2 ^ (8 * n) + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n)] }) := by
      rw [step_eq_stepBody hi0 hs0]
      exact stepBody_switch hnat hvw hctl (hpl.notResume _ hvw (ctl_ne_trap hctl))
          (hpl.notUnreachable _ hvw (ctl_ne_trap hctl))
        hat.pe hop hget
    have h3 := List.all_eq_true.mp hall _ (List.mem_range.mpr hil)
    try dsimp only at h3
    rw [hget] at h3
    simp only [Bool.or_eq_true, decide_eq_true_eq] at h3
    rcases h3 with h3 | h3
    · exact absurd h3 (Nat.not_le.mpr hlt)
    · refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
      rw [Nat.add_mod y _ (2 ^ (8 * n)),
        Nat.mod_mod (u % 2 ^ (8 * n) + (2 ^ (8 * n) - y % 2 ^ (8 * n))) (2 ^ (8 * n)),
        hmod] at h3
      exact h3
  · rw [if_neg hil] at hop
    have hget : ts[len]? = some ts[len] := List.getElem?_eq_getElem (by omega)
    have hstep : R.step c s1 ch = .ok (.step { s0 with pc := ts[len] }) := by
      rw [step_eq_stepBody hi0 hs0]
      exact stepBody_switch hnat hvw hctl (hpl.notResume _ hvw (ctl_ne_trap hctl))
          (hpl.notUnreachable _ hvw (ctl_ne_trap hctl))
        hat.pe hop hget
    rw [hget] at hdef
    refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl⟩
    exact restOk_spec
      (ex := fun x => decide ((x + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n) < len))
      (pc := ts[len]) hdef hA (decide_eq_false hil)

/-- `hit_finish` with `TermOutX`. -/
theorem hit_finishX {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    {s1 s0 s2 : RState} {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {x : Nat}
    (hs' : s' = { s with stack :=
      { f with bb := caseTarget cases otherwise x, stmt := 0 } :: rest })
    (hst : StepsTo c ch s1 s2) (hhit : hitOk Γ cases otherwise x s2.pc = true)
    (hsst : s2.st = s0.st) (hfp : s2.fp = s0.fp) (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0)
    (hw : ∀ l, live' l = true → live l = true) :
    SwitchOutX Γ c ch ι live' s s' f rest s1 s0 := by
  unfold hitOk at hhit
  simp only [Bool.or_eq_true, beq_iff_eq, Bool.and_eq_true] at hhit
  rcases hhit with hb | ⟨e, hd⟩
  · exact .inl (term_finishX hs' hst hb hsst hfp hrel hw)
  · refine .inr ⟨otherwise, ?_, hd⟩
    subst hs'
    show ({ f with bb := caseTarget cases otherwise x, stmt := 0 } :: rest) = _
    rw [e]

/-- `sim_switch` from `TermAtX`. -/
theorem sim_switchX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {term : Terminator}
    {is : List Insn} (hlow : LowerSwitch Γ next term is)
    (hat : TermAtX c s1 s0 next is) (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0)
    (hlive : ∀ (d : Operand) cs ow l, term = .switchInt d cs ow → l ∈ operandLocals d →
      live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    SwitchOutX Γ c ch ι live' s s' f rest s1 s0 := by
  cases hlow
  case chain hd hty hn hsl hsize hoff hok =>
    obtain ⟨p, ty0, v, bits, hp, hty', hload, hsw, hs'⟩ := switchInt_inv hs hd h
    rw [hbody] at hty
    rw [hty] at hty'
    obtain rfl := (Option.some.inj hty').symm
    obtain ⟨bs, u, hrf, hu, hbits⟩ := switch_read (Γ := Γ.toStmtCtx) hrel
      (hlive _ _ _ _ rfl (operand_local_mem hd)) hp hty hbody hn hsl hsize hload hsw
    subst hbits
    obtain ⟨s2, hst, hhit, hsst, hfp⟩ :=
      chain_runX (ch := ch) hmode hρ hu (ex := []) hok hat hpl hrf rfl
    refine hit_finishX ?_ hst hhit hsst hfp hrel hw
    exact hs'
  case dense hd hty hn hsl hsize hoff hden ha hok =>
    subst ha
    obtain ⟨p, ty0, v, bits, hp, hty', hload, hsw, hs'⟩ := switchInt_inv hs hd h
    rw [hbody] at hty
    rw [hty] at hty'
    obtain rfl := (Option.some.inj hty').symm
    obtain ⟨bs, u, hrf, hu, hbits⟩ := switch_read (Γ := Γ.toStmtCtx) hrel
      (hlive _ _ _ _ rfl (operand_local_mem hd)) hp hty hbody hn hsl hsize hload hsw
    subst hbits
    obtain ⟨s2, hst, hhit, hsst, hfp⟩ :=
      dense_runX (ch := ch) hmode hρ hden hok hat (hpl _ (by simp)) hrf hu
    refine hit_finishX ?_ hst hhit hsst hfp hrel hw
    exact hs'
  case chainF hd hta hpath hn hsa hin hok =>
    obtain ⟨bs, u, hrf, hu, hs'⟩ := switchF_read hs hbody hd hta hpath hn hsa hin hrel
      (hlive _ _ _ _ rfl (operandPlace?_base_mem hd)) h
    obtain ⟨s2, hst, hhit, hsst, hfp⟩ :=
      chain_runX (ch := ch) hmode hρ hu (ex := []) hok hat hpl hrf rfl
    exact hit_finishX hs' hst hhit hsst hfp hrel hw
  case denseF hd hta hpath hn hsa hin hden ha hok =>
    subst ha
    obtain ⟨bs, u, hrf, hu, hs'⟩ := switchF_read hs hbody hd hta hpath hn hsa hin hrel
      (hlive _ _ _ _ rfl (operandPlace?_base_mem hd)) h
    obtain ⟨s2, hst, hhit, hsst, hfp⟩ :=
      dense_runX (ch := ch) hmode hρ hden hok hat (hpl _ (by simp)) hrf hu
    exact hit_finishX hs' hst hhit hsst hfp hrel hw

/-! ### `return` -/

theorem retX_retOps {Γ : TermCtx} {term : Terminator} {i : Insn}
    (h : LowerRetX Γ term [i]) : ∃ src k, retOps i = some (src, k) := by
  cases h with
  | zero hro => exact ⟨_, _, hro⟩
  | reg hro => exact ⟨_, _, hro⟩

/-- `ret`'s step after its scopes is the scope-free code's from the fold (`ret` reads neither
the scopes nor the `Lend`s). -/
theorem step_ret_drop {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {i : Insn} {src : Int}
    {k : Nat} (hi : c.d.insns[s1.pc]? = some i)
    (hsc : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0)
    (hro : retOps i = some (src, k)) :
    R.step c s1 ch = R.step c.dropScopes s0 ch := by
  obtain ⟨op, f, sw, kw, rfl, hf, hsh, -, -⟩ := retOps_spec hro
  have hpc : s0.pc = s1.pc := scopes_pc hsc
  have hi' : c.dropScopes.d.insns[s0.pc]? = some (.native op [.slot sw, .imm kw]) := by
    rw [hpc]; exact hi
  rw [step_eq_stepBody hi hsc, step_eq_stepBody_nil hi' (dropScopes_scopesAt c _)]
  unfold stepBody
  dsimp only
  rw [hf]
  dsimp only
  rw [hsh]
  all_goals first | rfl | (dsimp only; rfl)

/-- `sim_retX` from `TermAtX`: R's `ret` from `s1` ends the function in the fold `s0`. -/
theorem sim_retXX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {next : Nat} {i : Insn} (hlow : LowerRetX Γ .«return» [i]) (hat : TermAtX c s1 s0 next [i])
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hlive : live 0 = true)
    (hcont : f.cont = .bottom)
    (hinc : ∃ bs, s0.st.readFrame 16 c.argSize = .ok bs)
    (h : runOn (evalTerminator .«return») o s = (.ok (), s')) :
    ∃ v regs incoming, s'.final = some (.returned v) ∧
      R.step c s1 ch = .ok (.done (exit s0 (.ret regs incoming))) ∧ RetValX Γ ι v regs := by
  obtain ⟨v, regs, incoming, hfinal, hstep, hval⟩ :=
    sim_retX (ch := ch) (c := c.dropScopes) hs hbody hlow hat.drop hrel hlive hcont hinc h
  obtain ⟨hi, hsc⟩ := hat.head
  obtain ⟨src, k, hro⟩ := retX_retOps hlow
  exact ⟨v, regs, incoming, hfinal, (step_ret_drop hi hsc hro).trans hstep, hval⟩

/-! ### Static switches -/

theorem writeFrame_escaped {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') : st'.escaped = st.escaped := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    rfl

/-- `sim_switchStatic` from `TermAtX`. -/
theorem sim_switchStaticX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {term : Terminator}
    {is : List Insn} (hlow : LowerSwitchStatic Γ next term is)
    (hat : TermAtX c s1 s0 next is) (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    SwitchOutX Γ c ch ι live' s s' f rest s1 s0 := by
  cases hlow with
  | mk d cs ow n x i tl a hd hi hoff hpriv hap hok =>
    have hs' := switch_static_inv hs hd h
    have hx := staticOpnd_lt hd
    -- the `imm`, after the scopes
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
    have hpw : ∀ j < (OpSem.intBytes n y).length, s0.st.escapedAt (a + j) = none := by
      intro j hj
      rw [hlenI] at hj
      cases he : s0.st.escapedAt (a + j) with
      | none => rfl
      | some e =>
        have h1 := hrel.esc _ _ he
        rw [hpriv j hj] at h1
        cases h1
    obtain ⟨st', hwr⟩ : ∃ st', s0.st.writeFrame a (OpSem.intBytes n y) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hop := opSem_imm_fwd (ch := ch) hh hparse ho (offOk_spec hoff) hfk hwr
    have hstep : R.step c s1 ch = .ok (.step { s0 with pc := s0.pc + 1, st := st' }) :=
      step_of_view_scopes hi0 hs0 hat.pe hpli hv hctl (by rw [hops'']; exact hop)
    have hrel' := hrel.writeTemp hwr hpw
      (fun l sl hsl => by rw [hlenI]; exact tempApart_spec hap hsl) (s0.pc + 1)
    obtain ⟨hmemw, -, -⟩ := writeFrame_private_eq hwr hpw
    have hescw := writeFrame_escaped hwr
    -- the temporary holds `x`
    have hrb := readFrame_written hwr hpw
    rw [hlenI] at hrb
    have hdec : decodeBits (OpSem.intBytes n y) = some x := by
      show decodeBits (encodeBits n y) = some x
      rw [Ryo.Spec.Theorems.decodeBits_encodeBits, hy, Nat.mod_eq_of_lt hx]
    have hasn : OpSem.asNat (OpSem.intBytes n y) = .ok x := by
      unfold OpSem.asNat; rw [hdec] <;> rfl
    -- the switch on it
    have hat' : TermAt c { s0 with pc := s0.pc + 1, st := st' } next tl :=
      ⟨hat.tail.code, hat.tail.scopes, hat.tail.hnext, hat.pe⟩
    obtain ⟨s2, hst, hhit, hsst, hfp⟩ := walk_run (ch := ch) hmode hρ (offOk_spec hoff) hasn
      hok hat' (fun j hj => hpl j (List.mem_cons_of_mem _ hj)) hrb
    rcases hit_finishX (s1 := { s0 with pc := s0.pc + 1, st := st' })
        (s0 := { s0 with pc := s0.pc + 1, st := st' }) hs' hst hhit hsst hfp hrel' hw with
      ⟨s1', f', hst', hstk, hstm, hbo, hstart, hmem, hesc, hm2, hfp2, hrel2⟩ | hdead
    · exact .inl ⟨s1', f', .cons hstep hst', hstk, hstm, hbo, hstart, hmem, hesc.trans hescw,
        hm2.trans hmemw, hfp2, hrel2⟩
    · exact .inr hdead

/-! ### `Unreachable`, `UnwindResume`, `Assert` -/

theorem TermAt.toX {c : Code} {s : RState} {next : Nat} {is : List Insn}
    (hat : TermAt c s next is) : TermAtX c s s next is := by
  refine ⟨hat.code, fun j _ hj => hat.scopes j hj, fun hne => ?_, fun _ => rfl, hat.hnext,
    hat.pe⟩
  have h0 : 0 < is.length := by
    cases is with
    | nil => exact absurd rfl hne
    | cons _ _ => simp
  have h1 := hat.scopes 0 h0
  simp only [Nat.add_zero] at h1
  rw [h1]
  rfl

/-- `JumpOut` with R's objects, memory and `fp` the fold's, and L0's globals kept (`GlobKept`:
the jump changes only the stack, which the pool invariant needs). -/
def JumpOutX (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (term : Terminator) (s s' : Spec.State) (f : Spec.Frame) (rest : List Spec.Frame)
    (s1 s0 : RState) : Prop :=
  ∃ s1' b', StepsTo c ch s1 s1' ∧ b' ∈ termSuccs term ∧
    s'.stack = { f with bb := b', stmt := 0 } :: rest ∧ s'.mem = s.mem ∧
    blockStart Γ b' = some s1'.pc ∧ s1'.st.escaped = s0.st.escaped ∧
    s1'.st.mem = s0.st.mem ∧ s1'.fp = s0.fp ∧
    FnRel Γ.toStmtCtx ι live' { f with bb := b', stmt := 0 } s'.mem s1' ∧ GlobKept s s'

/-- `AssertFails` from `TermAtX`: R at the panic call's code (`TermAtX` from `s1'` to `s0'`,
whose state and `fp` are the fold's), `FnRel` at `s0'`. -/
def AssertFailsX (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj) (live : Local → Bool)
    (o : Spec.Oracle) (s s' : Spec.State) (f : Spec.Frame) (s1 s0 : RState) (next : Nat)
    (msg : AssertMessage) (unwind : UnwindAction) : Prop :=
  ∃ s1' s0' tl, StepsTo c ch s1 s1' ∧ TermAtX c s1' s0' next tl ∧ s0'.st = s0.st ∧
    s0'.fp = s0.fp ∧ FnRel Γ.toStmtCtx ι live f s.mem s0' ∧
    runOn (assertPanic msg unwind) o s = (.ok (), s')

/-- `ResumeOut` from `TermAtX`: under `ExcAt` on the fold, R's step from `s1` exits in it. -/
def ResumeOutX (c : Code) (ch : OpSem.Choice) (ι : Inj) (s' : Spec.State) (f : Spec.Frame)
    (s1 s0 : RState) (x : Int) : Prop :=
  ∃ p, f.unwinding = some p ∧ s'.final = some (.unwound p) ∧
    (ExcAt ι f s0.st x →
      ∃ exc, R.step c s1 ch = .ok (.done (R.exit s0 (.unwind exc))) ∧ PtrInj ι p exc)

/-- `br_bool_step` from `TermAtX`. -/
theorem br_bool_stepX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {f : Spec.Frame} {m0 : Memory} (hmode : c.mode = Γ.mode)
    (hρ : c.ρ = Γ.ρ) {next : Nat} {l : Local} {sl : LocalSlot} {p : ThinPointer} {ibr : Insn}
    {tl : List Insn} {neg : Bool} {t : Nat}
    (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = 1) (hoff : offOk sl.off = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (sl.off, neg, t))
    (hat : TermAtX c s1 s0 next (ibr :: tl))
    (hpl : PlainView c.mode c.ρ ibr) (hrel : FnRel Γ.toStmtCtx ι live f m0 s0)
    (hp : f.locals[l]? = some (some p)) (hlive : live l = true) {v : Value}
    (hload : typedLoad m0 p .bool .one = .ok v) :
    ∃ b, v = .bool b ∧
      R.step c s1 ch = .ok (.step { s0 with pc := if b != neg then t else s0.pc + 1 }) := by
  obtain ⟨dd, pr, hld, hcase⟩ := typedLoad_bool hload
  have hr := hrel.opnd hp hsl hlive
  have hld' : m0.load p sl.size .one = .ok [.init dd pr] := by rw [hsize]; exact hld
  obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld'
  have hdec0 : decodeBits [AbstractByte.init dd pr] = some (leDecode [dd]) := rfl
  have hdec1 := decodeBits_inj hbi hdec0
  have hasn : OpSem.asNat bs1 = .ok (leDecode [dd]) := by
    unfold OpSem.asNat; rw [hdec1]; rfl
  obtain ⟨vw, r, hvw, hh, hops, hctl, ho⟩ := brOps_spec hbr
  rw [← hmode, ← hρ] at hvw
  obtain ⟨h1, h2⟩ := offOk_spec hoff
  have hrf' : s0.st.readFrame sl.off 1 = .ok bs1 := by rw [← hsize]; exact hrf
  have hop : OpSem.opSem vw.op vw.ops s0.st ch = .ok (.branch (leDecode [dd] != 0), s0.st) := by
    rw [hops]; exact opSem_br_fwd hh ho h1 h2 hrf' hasn
  obtain ⟨hi0, hs0⟩ := hat.head
  have hstep := step_branchX hi0 hs0 hat.pe hpl hvw hctl hop
  obtain ⟨b, rfl, hcb⟩ : ∃ b, v = .bool b ∧ (leDecode [dd] != 0) = b := by
    rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨false, rfl, by decide⟩
    · exact ⟨true, rfl, by decide⟩
  rw [hcb] at hstep
  exact ⟨b, rfl, hstep⟩

theorem sim_assertX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat}
    {d : Operand} {l : Local} {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
    {unwind : UnwindAction} {sl : LocalSlot} {ibr : Insn} {tl : List Insn} {sv : Int}
    {neg : Bool} {t : Nat}
    (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some .bool)
    (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = 1) (hoff : offOk sl.off = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (sv, neg, t)) (hsv : sv = sl.off)
    (hneg : neg = !expected) (ht : blockStart Γ target = some t)
    (hat : TermAtX c s1 s0 next (ibr :: tl)) (hpl : PlainView c.mode c.ρ ibr)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hlive : live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.assert d expected msg target unwind)) o s = (.ok (), s')) :
    JumpOutX Γ c ch ι live' (.assert d expected msg target unwind) s s' f rest s1 s0 ∨
      AssertFailsX Γ c ch ι live o s s' f s1 s0 next msg unwind := by
  subst hsv hneg
  obtain ⟨p, ty, v, hp, hty', hload, h2⟩ := assert_local_inv hs hd h
  rw [← hbody, hty] at hty'
  obtain rfl := (Option.some.inj hty').symm
  obtain ⟨b, rfl, hstep⟩ :=
    br_bool_stepX (ch := ch) hmode hρ hsl hsize hoff hbr hat hpl hrel hp hlive hload
  rcases assert_bool_step hs h2 with ⟨he, hs'⟩ | ⟨hne, hpan⟩
  · have hc : (b != !expected) = true := by rw [he]; cases expected <;> rfl
    simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
    subst hs'
    exact .inl ⟨{ s0 with pc := t }, target, .cons hstep (.refl _), by simp [termSuccs], rfl,
      rfl, ht, rfl, rfl, rfl, (hrel.weaken hw).congr rfl rfl rfl rfl, GlobKept.of_eq rfl rfl rfl⟩
  · have hc : (b != !expected) = false := by
      revert hne; cases b <;> cases expected <;> decide
    simp only [hc, Bool.false_eq_true, if_false, ↓reduceIte] at hstep
    exact .inr ⟨{ s0 with pc := s0.pc + 1 }, { s0 with pc := s0.pc + 1 }, tl,
      .cons hstep (.refl _), hat.tail.toX, rfl, rfl, hrel.congr rfl rfl rfl rfl, hpan⟩

/-- `br_read_step` from `TermAtX`. -/
theorem br_read_stepX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {x : Int} {ibr : Insn}
    {tl : List Insn} {neg : Bool} {t : Nat} (hoff : offOk x = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (x, neg, t)) (hat : TermAtX c s1 s0 next (ibr :: tl))
    (hpl : PlainView c.mode c.ρ ibr) {m0 : Memory} {q : ThinPointer} {v : Value}
    (hload : typedLoad m0 q .bool .one = .ok v)
    (hread : ∀ bs0, m0.load q 1 .one = .ok bs0 →
      ∃ bs1, s0.st.readFrame x 1 = .ok bs1 ∧ BytesInj ι bs0 bs1) :
    ∃ b, v = .bool b ∧
      R.step c s1 ch = .ok (.step { s0 with pc := if b != neg then t else s0.pc + 1 }) := by
  obtain ⟨dd, pr, hld, hcase⟩ := typedLoad_bool hload
  obtain ⟨bs1, hrf, hbi⟩ := hread _ hld
  have hdec0 : decodeBits [AbstractByte.init dd pr] = some (leDecode [dd]) := rfl
  have hdec1 := decodeBits_inj hbi hdec0
  have hasn : OpSem.asNat bs1 = .ok (leDecode [dd]) := by
    unfold OpSem.asNat; rw [hdec1]; rfl
  obtain ⟨vw, r, hvw, hh, hops, hctl, ho⟩ := brOps_spec hbr
  rw [← hmode, ← hρ] at hvw
  obtain ⟨h1, h2⟩ := offOk_spec hoff
  have hop : OpSem.opSem vw.op vw.ops s0.st ch = .ok (.branch (leDecode [dd] != 0), s0.st) := by
    rw [hops]; exact opSem_br_fwd hh ho h1 h2 hrf hasn
  obtain ⟨hi0, hs0⟩ := hat.head
  have hstep := step_branchX hi0 hs0 hat.pe hpl hvw hctl hop
  obtain ⟨b, rfl, hcb⟩ : ∃ b, v = .bool b ∧ (leDecode [dd] != 0) = b := by
    rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨false, rfl, by decide⟩
    · exact ⟨true, rfl, by decide⟩
  rw [hcb] at hstep
  exact ⟨b, rfl, hstep⟩

/-- `sim_assertField` from `TermAtX`. -/
theorem sim_assertFieldX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat}
    {d : Operand} {a : Local} {projs : List ProjElem} {ta : Spec.Ty} {off : Nat}
    {expected : Bool} {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction}
    {sl : LocalSlot} {ibr : Insn} {tl : List Insn} {sv : Int} {neg : Bool} {t : Nat}
    (hd : operandPlace? d = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
    (hpath : fieldPath ta projs = some (off, .bool)) (hsl : Γ.slots[a]? = some sl)
    (hin : off + 1 ≤ sl.size) (hoff : offOk (sl.off + off) = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (sv, neg, t)) (hsv : sv = sl.off + off)
    (hneg : neg = !expected) (ht : blockStart Γ target = some t)
    (hat : TermAtX c s1 s0 next (ibr :: tl)) (hpl : PlainView c.mode c.ρ ibr)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hlive : live a = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.assert d expected msg target unwind)) o s = (.ok (), s')) :
    JumpOutX Γ c ch ι live' (.assert d expected msg target unwind) s s' f rest s1 s0 ∨
      AssertFailsX Γ c ch ι live o s s' f s1 s0 next msg unwind := by
  subst hsv hneg
  rw [assert_eq] at h
  obtain ⟨x, s1x, h1, h2⟩ := runOn_bind_ok h
  have hta' : f.body.locals[a]? = some ta := by rw [← hbody]; exact hta
  obtain ⟨pa, v, hpa, hload, hx, hs1⟩ := runOn_evalOperand_field hs hd hta' hpath h1
  subst x s1x
  have hr := hrel.opnd hpa hsl hlive
  obtain ⟨b, rfl, hstep⟩ := br_read_stepX (ch := ch) hmode hρ hoff hbr hat hpl hload
    (fun bs0 hl => readLocal_sub_inj hrel.frame.mem hr hin hl)
  rcases assert_bool_step hs h2 with ⟨he, hs'⟩ | ⟨hne, hpan⟩
  · have hc : (b != !expected) = true := by rw [he]; cases expected <;> rfl
    simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
    subst hs'
    exact .inl ⟨{ s0 with pc := t }, target, .cons hstep (.refl _), by simp [termSuccs], rfl,
      rfl, ht, rfl, rfl, rfl, (hrel.weaken hw).congr rfl rfl rfl rfl, GlobKept.of_eq rfl rfl rfl⟩
  · have hc : (b != !expected) = false := by
      revert hne; cases b <;> cases expected <;> decide
    simp only [hc, Bool.false_eq_true, if_false, ↓reduceIte] at hstep
    exact .inr ⟨{ s0 with pc := s0.pc + 1 }, { s0 with pc := s0.pc + 1 }, tl,
      .cons hstep (.refl _), hat.tail.toX, rfl, rfl, hrel.congr rfl rfl rfl rfl, hpan⟩

theorem sim_assertKnownX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest) {next : Nat}
    {bits : Nat} {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
    {unwind : UnwindAction} {is : List Insn} (hk : ((bits % 256 == 1) == expected) = true)
    (hg : gotoOk Γ next target is = true) (hat : TermAtX c s1 s0 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0) (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.assert (.const (.scalar bits) .bool) expected msg target unwind))
      o s = (.ok (), s')) :
    JumpOutX Γ c ch ι live' (.assert (.const (.scalar bits) .bool) expected msg target unwind)
      s s' f rest s1 s0 := by
  rcases assert_const_inv hs h with ⟨-, hs'⟩ | ⟨hne, -⟩
  · obtain ⟨s2, hst, hb, hsst, hfp⟩ := goto_runX (ch := ch) hg hat
    subst hs'
    exact ⟨s2, target, hst, by simp [termSuccs], rfl, rfl, hb, by rw [hsst], by rw [hsst], hfp,
      (hrel.weaken hw).congr rfl rfl hsst hfp, GlobKept.of_eq rfl rfl rfl⟩
  · exact absurd (beq_iff_eq.mp hk) hne

theorem sim_assertKnownFailX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice}
    {ι : Inj} {live : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {next : Nat} {bits : Nat}
    {expected : Bool} {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction}
    {is : List Insn} (hk : ((bits % 256 == 1) == expected) = false)
    (hat : TermAtX c s1 s0 next is) (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0)
    (h : runOn (evalTerminator (.assert (.const (.scalar bits) .bool) expected msg target unwind))
      o s = (.ok (), s')) :
    AssertFailsX Γ c ch ι live o s s' f s1 s0 next msg unwind := by
  rcases assert_const_inv hs h with ⟨he, -⟩ | ⟨-, hpan⟩
  · rw [he, beq_self_eq_true] at hk
    cases hk
  · exact ⟨s1, s0, is, .refl _, hat, rfl, rfl, hrel, hpan⟩

/-- `sim_resume` from `TermAtX`: `resume` is a view, so its step after the scopes is the
scope-free code's from the fold (`step_dropScopes`). -/
theorem sim_resumeX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    (hs : s.stack = f :: rest) (hcont : f.cont = .bottom) (hmode : c.mode = Γ.mode)
    (hρ : c.ρ = Γ.ρ) {next : Nat} {i : Insn} {x : Int}
    (hrule : resumeOps Γ.toStmtCtx i = some x) (hat : TermAtX c s1 s0 next [i])
    (hcl : ∃ b, c.cleanupAt s1.pc = some (none, b))
    (h : runOn (evalTerminator .unwindResume) o s = (.ok (), s')) :
    ResumeOutX c ch ι s' f s1 s0 x := by
  have hpc : s0.pc = s1.pc := hat.pc_fp.1
  have hcl' : ∃ b, c.dropScopes.cleanupAt s0.pc = some (none, b) := by
    rw [hpc]; exact hcl
  obtain ⟨p, hu, hfin, hR⟩ := sim_resume (ch := ch) (c := c.dropScopes) (ι := ι) hs hcont
    hmode hρ hrule hat.drop hcl' h
  refine ⟨p, hu, hfin, fun hexc => ?_⟩
  obtain ⟨exc, hstep, hpi⟩ := hR hexc
  obtain ⟨hi, hsc⟩ := hat.head
  obtain ⟨v, hv, hop, hctl, hops⟩ := resumeOps_spec hrule
  rw [← hmode, ← hρ] at hv
  have hnat : ViewShape i := by
    intro op ops he g hg
    subst he
    exact shapes_of_opShape (view_native_opShape hv hg hctl)
  exact ⟨exc, (step_dropScopes hi hsc hnat ⟨v, hv⟩).trans hstep, hpi⟩

/-- `TermMoreOut` from `TermAtX`. -/
def TermMoreOutX (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj)
    (live live' : Local → Bool) (o : Spec.Oracle) (s s' : Spec.State) (f : Spec.Frame)
    (rest : List Spec.Frame) (s1 s0 : RState) (next : Nat) (term : Terminator) : Prop :=
  JumpOutX Γ c ch ι live' term s s' f rest s1 s0 ∨
    (∃ d expected msg target unwind, term = .assert d expected msg target unwind ∧
      AssertFailsX Γ c ch ι live o s s' f s1 s0 next msg unwind) ∨
    (∃ x, term = .unwindResume ∧ ResumeOutX c ch ι s' f s1 s0 x)

/-- `sim_termMore` from `TermAtX`. -/
theorem sim_termMoreX {Γ : TermCtx} {c : Code} {s1 s0 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hcont : f.cont = .bottom) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat}
    {term : Terminator} {is : List Insn} (hlow : LowerTermMore Γ next term is)
    (hat : TermAtX c s1 s0 next is) (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hres : ∀ (k : Nat) i, c.d.insns[k]? = some i → isResume c.mode c.ρ i = true →
      contAt c.d k = true)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s0)
    (hlive : ∀ (d : Operand) e msg target unwind l, term = .assert d e msg target unwind →
      l ∈ operandLocals d → live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    TermMoreOutX Γ c ch ι live live' o s s' f rest s1 s0 next term := by
  cases hlow
  case unreachable => exact absurd h unreachable_no_step
  case resume hr =>
    obtain ⟨hi, -⟩ := hat.head
    have hir := resumeOps_isResume hr
    rw [← hmode, ← hρ] at hir
    have hcl := cleanupAt_of_contAt (hres _ _ hi hir)
    exact .inr (.inr ⟨_, rfl, sim_resumeX hs hcont hmode hρ hr hat hcl h⟩)
  case assert hd hty hsl hsize hoff hbr hsv hneg ht =>
    rcases sim_assertX (ch := ch) (live' := live') hs hbody hmode hρ hd hty hsl hsize hoff hbr
        hsv hneg ht hat (hpl _ (by simp)) hrel (hlive _ _ _ _ _ _ rfl (operand_local_mem hd)) hw
        h with hj | hf
    · exact .inl hj
    · exact .inr (.inl ⟨_, _, _, _, _, rfl, hf⟩)
  case assertField hd hta hpath hsl hin hoff hbr hsv hneg ht =>
    rcases sim_assertFieldX (ch := ch) (live' := live') hs hbody hmode hρ hd hta hpath hsl hin
        hoff hbr hsv hneg ht hat (hpl _ (by simp)) hrel
        (hlive _ _ _ _ _ _ rfl (operandPlace?_base_mem hd)) hw h with hj | hf
    · exact .inl hj
    · exact .inr (.inl ⟨_, _, _, _, _, rfl, hf⟩)
  case assertKnown hk hg => exact .inl (sim_assertKnownX hs hk hg hat hrel hw h)
  case assertKnownFail hk =>
    exact .inr (.inl ⟨_, _, _, _, _, rfl, sim_assertKnownFailX hs hk hat hrel h⟩)

end Ryo.Proofs.Lower
