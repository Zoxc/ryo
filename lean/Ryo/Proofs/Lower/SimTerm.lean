/-
Ryo.Proofs.Lower.SimTerm — the terminators' simulation (M5a): each `LowerTerm` rule
(`Check/Lower/Term.lean`) from `FnRel` at the terminator's first R index.

`TermAt c s1 next is`: the rule's instructions `is` are R's at consecutive indices from `s1.pc`,
with no scopes there, the range ending at `next`, outside PE. From a successful L0 terminator
step (`goto`, `SwitchInt` without cases or with one on a `bool` or integer local), R takes at most
two steps (`StepsTo`) to the start (`blockStart`) of the L0 target block, its frame and memory
unchanged, and `FnRel` holds there for the target frame at any weaker liveness (a terminator
only reads): `sim_goto`, `sim_switchNone`, `sim_switchBool`, `sim_switchInt`, dispatched by
`sim_term`. `sim_ret` states `return`'s step (open).

The branches' forward `opSem` (`opSem_br_fwd`, `opSem_brCmpImm_fwd`) mirror
`Inline.opSem_br`/`opSem_brCmpImm`.
-/
import Ryo.Proofs.Lower.FnRel
import Ryo.Proofs.Lower.SimProlog
import Ryo.Check.Lower.Term
import Ryo.Proofs.Inline.OpSem

namespace Ryo.Proofs.Lower

/-! ### Forward `opSem` of the branches -/

section
open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem

/-- `br` on slot `s`: branch on the byte being non-zero, the state unchanged. -/
theorem opSem_br_fwd {op : Full.Opcode} {r : Option String} {ps : List String} {s : Int}
    {st : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.br, ps, r⟩)
    (ho : op.info.operands = [⟨"s", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩])
    (hs1 : -2 ^ 31 ≤ s) (hs2 : s < 2 ^ 31)
    {bs : List AbstractByte} {v : Nat}
    (hr : st.readFrame s 1 = .ok bs) (hv : asNat bs = .ok v) :
    opSem op [.slot s, .none, .none] st ch = .ok (.branch (v != 0), st) := by
  have hfs := slot_fits hs1 hs2
  have hfp : footprint op = some { reads := [Ryo.Proofs.Inline.rdA "s" 1], flow := .branch } := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact Ryo.Proofs.Inline.fp_br ps
  have hprep : prepare op [.slot s, .none, .none] =
      .ok (⟨.br, ps, r⟩, { reads := [Ryo.Proofs.Inline.rdA "s" 1], flow := .branch },
        opndVal op.info [.slot s, .none, .none]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, Val.fits]; omega)]
    rfl
  have hvs : opndVal op.info [.slot s, .none, .none] "s" = some (.slot s) := by
    simp [opndVal, ho]
  have hrd : readAll { reads := [Ryo.Proofs.Inline.rdA "s" 1], flow := .branch }
      (opndVal op.info [.slot s, .none, .none]) st = .ok [("s", bs)] := by
    simp only [readAll, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvs, Val.slotOff, Extent.eval, hr,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .br ps (mkEnv [("s", bs)] (opndVal op.info [.slot s, .none, .none]) st ch) =
      .ok { ctl := .branch (v != 0), mem := st.mem, writes := [] } := by
    simp [kindSem, mkEnv, Env.int, out, hv, bind, Except.bind, pure, Except.pure]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure, commit,
    List.foldlM_nil, hst]

/-- `br.eq.imm` at `n` bytes on slot `a` and immediate `y`: branch on the equality of their low
`8 n` bits, the state unchanged. -/
theorem opSem_brCmpImm_fwd {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat}
    {sg : Bool} {k2 k3 k4 : OperandKind} {a : Int} {y : Nat} {st : OpSem.State}
    {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.br_cmp_imm, [ty, "=="], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"a", .slot⟩, ⟨"imm", k2⟩, ⟨"neg", k3⟩, ⟨"t", k4⟩])
    (hfa : Val.fits .slot (.slot a) = true) (hk2 : Val.fits k2 (.imm y) = true)
    (hk3 : Val.fits k3 .none = true) (hk4 : Val.fits k4 .none = true)
    {ba : List AbstractByte} {va : Nat}
    (hra : st.readFrame a n = .ok ba) (hva : asNat ba = .ok va) :
    opSem op [.slot a, .imm y, .none, .none] st ch =
      .ok (.branch (BitVec.ofNat (8 * n) va == BitVec.ofNat (8 * n) y), st) := by
  have hfp : footprint op = some { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch } := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.2.2.2.2.2.2.2
  have hprep : prepare op [.slot a, .imm y, .none, .none] =
      .ok (⟨.br_cmp_imm, [ty, "=="], r⟩,
        { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch },
        opndVal op.info [.slot a, .imm y, .none, .none]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfa, hk2, hk3, hk4])]
    rfl
  have hva' : opndVal op.info [.slot a, .imm y, .none, .none] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvy : opndVal op.info [.slot a, .imm y, .none, .none] "imm" = some (.imm y) := by
    simp [opndVal, ho]
  have hrd : readAll { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch }
      (opndVal op.info [.slot a, .imm y, .none, .none]) st = .ok [("a", ba)] := by
    simp only [readAll, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', Val.slotOff, Extent.eval, hra,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .br_cmp_imm [ty, "=="]
      (mkEnv [("a", ba)] (opndVal op.info [.slot a, .imm y, .none, .none]) st ch) =
      .ok { ctl := .branch (BitVec.ofNat (8 * n) va == BitVec.ofNat (8 * n) y), mem := st.mem,
            writes := [] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, Env.immBv,
      Env.imm, out, hva, hvy, intCmp, bind, Except.bind, pure, Except.pure]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure, commit,
    List.foldlM_nil, hst]

end

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-! ### Small facts -/

theorem bv_ofNat_beq (w a b : Nat) :
    (BitVec.ofNat w a == BitVec.ofNat w b) = (a % 2 ^ w == b % 2 ^ w) := by
  rw [Bool.eq_iff_iff]
  simp only [beq_iff_eq]
  constructor
  · intro h
    have := congrArg BitVec.toNat h
    simpa [BitVec.toNat_ofNat] using this
  · intro h
    apply BitVec.eq_of_toNat_eq
    simpa [BitVec.toNat_ofNat] using h

theorem find_single {vc bits : Nat} {bb : BasicBlock} :
    [(vc, bb)].find? (·.1 == bits) = if vc = bits then some (vc, bb) else none := by
  by_cases h : vc = bits
  · simp [List.find?, h]
  · have hb : (vc == bits) = false := by simp [h]
    simp [List.find?, hb, h]

theorem bool_target {b : Bool} {vc : Nat} (hv : vc < 2) (bb otherwise : BasicBlock) :
    (if vc = (if b then 1 else 0) then bb else otherwise) = selBool vc bb otherwise b := by
  have : vc = 0 ∨ vc = 1 := by omega
  rcases this with rfl | rfl <;> cases b <;> simp [selBool]

/-- L0's typed load of a `bool`: one initialized byte, `0` or `1`. -/
theorem typedLoad_bool {mem : Memory} {p : ThinPointer} {al : Align} {v : Value}
    (h : typedLoad mem p .bool al = .ok v) :
    ∃ d pr, mem.load p 1 al = .ok [.init d pr] ∧
      ((d = 0 ∧ v = .bool false) ∨ (d = 1 ∧ v = .bool true)) := by
  have hs : (Spec.Ty.bool).size? = some 1 := rfl
  cases hl : mem.load p 1 al with
  | error e =>
    simp [typedLoad, hs, hl] at h
  | ok bs =>
    cases hdec : (Spec.Ty.bool).decode bs with
    | none =>
      first
        | (simp [typedLoad, hs, hl, hdec, throwUb, throwThe, MonadExceptOf.throw] at h; done)
        | (simp [typedLoad, hs, hl, hdec] at h; done)
        | (simp only [typedLoad, hs, hl, hdec] at h; cases h)
    | some w =>
      cases hc : checkValue mem w .bool with
      | error e => simp [typedLoad, hs, hl, hdec, hc] at h; cases h
      | ok _ =>
        simp [typedLoad, hs, hl, hdec, hc] at h
        cases h
        simp only [Spec.Ty.decode] at hdec
        split at hdec
        next pr =>
          cases hdec
          exact ⟨0, pr, rfl, .inl ⟨rfl, rfl⟩⟩
        next pr =>
          cases hdec
          exact ⟨1, pr, rfl, .inr ⟨rfl, rfl⟩⟩
        next => cases hdec

/-- `brOps`'s facts. -/
theorem brOps_spec {Γ : StmtCtx} {i : Insn} {s : Int} {neg : Bool} {t : Nat}
    (h : brOps Γ i = some (s, neg, t)) :
    ∃ v r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.br, [], r⟩ ∧
      v.ops = [.slot s, .none, .none] ∧ v.ctl = some (.branch neg t) ∧
      v.op.info.operands = [⟨"s", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩] := by
  unfold brOps at h
  split at h
  next v hv =>
    split at h
    next r s' neg' t' hh hops hctl =>
      split at h
      next ho =>
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl, rfl⟩ := h
        exact ⟨v, r, hv, hh, hops, hctl, by simpa using ho⟩
      next => cases h
    next => cases h
  next => cases h

/-- `brImmOps`'s facts. -/
theorem brImmOps_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {a : Int} {y : Nat} {neg : Bool}
    {t : Nat} (h : brImmOps Γ i n = some (a, y, neg, t)) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.br_cmp_imm, [ty, "=="], r⟩ ∧
      intTyOk ty n = true ∧ v.ops = [.slot a, .imm y, .none, .none] ∧
      v.ctl = some (.branch neg t) ∧
      v.op.info.operands.map (·.name) = ["a", "imm", "neg", "t"] ∧
      v.op.info.operands.head?.map (·.kind) = some .slot := by
  unfold brImmOps at h
  split at h
  next v hv =>
    split at h
    next ty m r a' y' neg' t' hh hops hctl =>
      split at h
      next hc =>
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl, rfl, rfl⟩ := h
        simp only [Bool.and_eq_true, beq_iff_eq] at hc
        obtain ⟨⟨⟨hm, hty⟩, hn⟩, hk⟩ := hc
        subst hm
        exact ⟨v, ty, r, hv, hh, hty, hops, hctl, hn, hk⟩
      next => cases h
    next => cases h
  next => cases h

theorem operands4 {l : List OperandInfo}
    (hn : l.map (·.name) = ["a", "imm", "neg", "t"]) (hk : l.head?.map (·.kind) = some .slot) :
    ∃ k2 k3 k4, l = [⟨"a", .slot⟩, ⟨"imm", k2⟩, ⟨"neg", k3⟩, ⟨"t", k4⟩] := by
  rcases l with _ | ⟨⟨n1, k1⟩, _ | ⟨⟨n2, k2⟩, _ | ⟨⟨n3, k3⟩, _ | ⟨⟨n4, k4⟩, _ | ⟨w, l⟩⟩⟩⟩⟩ <;>
    simp at hn
  simp at hk
  obtain ⟨rfl, rfl, rfl, rfl⟩ := hn
  subst hk
  exact ⟨_, _, _, rfl⟩

/-! ### `FnRel` across a terminator -/

/-- `FnRel` only looks at the frame's locals and aliases and R's frame pointer and state. -/
theorem FnRel.congr {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f f' : Spec.Frame}
    {m0 : Memory} {s1 s1' : RState} (hrel : FnRel Γ ι live f m0 s1)
    (hloc : f'.locals = f.locals) (hal : f'.aliased = f.aliased) (hst : s1'.st = s1.st)
    (hfp : s1'.fp = s1.fp) : FnRel Γ ι live f' m0 s1' := by
  obtain ⟨⟨hm, hl⟩, hh, hu, hp, ha, he⟩ := hrel
  refine ⟨⟨?_, ?_⟩, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hst]; exact hm
  · intro l p h1 h2
    rw [hloc] at h1
    rw [hal] at h2
    rw [hst, hfp]
    exact hl l p h1 h2
  · have e : PrivAlloc ι f' = PrivAlloc ι f := by
      funext a
      simp only [PrivAlloc, hloc]
    rw [e]; exact hh
  · rw [hal]; exact hu
  · intro l l' p p' hne h1 h2
    rw [hloc] at h1 h2
    exact hp l l' p p' hne h1 h2
  · intro l l' p p' sl sl' hne h1 h2
    rw [hloc] at h1 h2
    exact ha l l' p p' sl sl' hne h1 h2
  · intro o e h
    rw [hst] at h
    exact he o e h

/-! ### R's side -/

/-- A terminator range's instructions at R's consecutive indices from `s1.pc` (see the module
comment). -/
structure TermAt (c : Code) (s1 : RState) (next : Nat) (is : List Insn) : Prop where
  code : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj)
  scopes : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []
  hnext : s1.pc + is.length = next
  pe : c.mode.pe = false

theorem TermAt.head {c : Code} {s1 : RState} {next : Nat} {i : Insn} {tl : List Insn}
    (hat : TermAt c s1 next (i :: tl)) :
    c.d.insns[s1.pc]? = some i ∧ c.scopesAt s1.pc = [] := by
  have h1 := hat.code 0 (by simp)
  have h2 := hat.scopes 0 (by simp)
  simp only [Nat.add_zero, List.getElem_cons_zero] at h1 h2
  exact ⟨h1, h2⟩

theorem TermAt.tail {c : Code} {s1 : RState} {next : Nat} {i : Insn} {tl : List Insn}
    (hat : TermAt c s1 next (i :: tl)) : TermAt c { s1 with pc := s1.pc + 1 } next tl := by
  refine ⟨fun j hj => ?_, fun j hj => ?_, ?_, hat.pe⟩
  · have h := hat.code (j + 1) (by simp only [List.length_cons]; omega)
    have e : s1.pc + 1 + j = s1.pc + (j + 1) := by omega
    show c.d.insns[s1.pc + 1 + j]? = _
    rw [e, h]
    rfl
  · have h := hat.scopes (j + 1) (by simp only [List.length_cons]; omega)
    have e : s1.pc + 1 + j = s1.pc + (j + 1) := by omega
    show c.scopesAt (s1.pc + 1 + j) = []
    rw [e]; exact h
  · have h := hat.hnext
    simp only [List.length_cons] at h
    show s1.pc + 1 + tl.length = next
    omega

/-- A goto's code (`gotoOk`): R reaches the target's start. -/
theorem goto_run {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {s1 : RState} {next : Nat}
    {bb : BasicBlock} {is : List Insn} (hg : gotoOk Γ next bb is = true)
    (hat : TermAt c s1 next is) :
    ∃ s1', StepsTo c ch s1 s1' ∧ blockStart Γ bb = some s1'.pc ∧ s1'.st = s1.st ∧
      s1'.fp = s1.fp ∧ s1'.args = s1.args := by
  rcases gotoOk_spec hg with ⟨rfl, hb⟩ | ⟨i, t, rfl, hj, hb⟩
  · refine ⟨s1, .refl _, ?_, rfl, rfl, rfl⟩
    have h := hat.hnext
    simp only [List.length_nil, Nat.add_zero] at h
    rw [hb, h]
  · obtain ⟨op, f, rfl, hf, hsh⟩ := jmpTo_spec hj
    obtain ⟨hi, hs0⟩ := hat.head
    have hstep : R.step c s1 ch = .ok (.step { s1 with pc := t }) := by
      rw [step_eq_stepBody_nil hi hs0, stepBody_jmp hf hsh]
    exact ⟨{ s1 with pc := t }, .cons hstep (.refl _), hb, rfl, rfl, rfl⟩

/-- A branch on R's condition `cb`, then a goto's code (`selOk`): R reaches `sel cb`'s start. -/
theorem branch_run {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {s1 : RState} {next : Nat}
    {ibr : Insn} {tl : List Insn} {neg cb : Bool} {t : Nat} {sel : Bool → BasicBlock}
    (hstep : R.step c s1 ch = .ok (.step { s1 with pc := if cb != neg then t else s1.pc + 1 }))
    (hsel : selOk Γ next neg t sel tl = true) (hat : TermAt c s1 next (ibr :: tl)) :
    ∃ s1', StepsTo c ch s1 s1' ∧ blockStart Γ (sel cb) = some s1'.pc ∧ s1'.st = s1.st ∧
      s1'.fp = s1.fp ∧ s1'.args = s1.args := by
  obtain ⟨h1, h2⟩ := selOk_spec hsel cb
  cases hc : (cb != neg)
  · rw [hc] at hstep
    simp only [Bool.false_eq_true, if_false, ↓reduceIte] at hstep
    obtain ⟨s2, hst2, hb, hsst, hfp, har⟩ := goto_run (ch := ch) (h2 hc) hat.tail
    exact ⟨s2, .cons hstep hst2, hb, hsst, hfp, har⟩
  · rw [hc] at hstep
    simp only [eq_self_iff_true, if_true, ↓reduceIte] at hstep
    exact ⟨_, .cons hstep (.refl _), h1 hc, rfl, rfl, rfl⟩

/-- R's step of a branch whose `opSem` leaves the state. -/
theorem step_branch {c : Code} {s1 : RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {neg b : Bool} {x : Nat} (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = [])
    (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i) (hv : view c.mode c.ρ i = some v)
    (hctl : v.ctl = some (.branch neg x))
    (hop : OpSem.opSem v.op v.ops s1.st ch = .ok (.branch b, s1.st)) :
    R.step c s1 ch = .ok (.step { s1 with pc := if b != neg then x else s1.pc + 1 }) := by
  rw [step_eq_stepBody_nil hi hsc]
  have hnat : ViewShape i := by
    intro op ops he f hf
    subst he
    exact shapes_of_opShape (view_native_opShape hv hf (by rw [hctl]; rfl))
  exact stepBody_br hnat hv hctl (hpl.notResume v hv (ctl_ne_trap hctl))
      (hpl.notUnreachable v hv (ctl_ne_trap hctl)) hpe hop

/-! ### The rules -/

/-- The common end: L0 at block `X`'s start, R at its R start. -/
theorem term_finish {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    {s1 s2 : RState} {X : BasicBlock}
    (hs' : s' = { s with stack := { f with bb := X, stmt := 0 } :: rest })
    (hst : StepsTo c ch s1 s2) (hb : blockStart Γ X = some s2.pc) (hsst : s2.st = s1.st)
    (hfp : s2.fp = s1.fp) (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1)
    (hw : ∀ l, live' l = true → live l = true) :
    ∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.stmt = 0 ∧ f'.body = f.body ∧
      blockStart Γ f'.bb = some s1'.pc ∧ s'.mem = s.mem ∧
      FnRel Γ.toStmtCtx ι live' f' s'.mem s1' := by
  subst hs'
  exact ⟨s2, { f with bb := X, stmt := 0 }, hst, rfl, rfl, rfl, hb, rfl,
    (hrel.weaken hw).congr rfl rfl hsst hfp⟩

theorem sim_goto {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {next : Nat} {bb : BasicBlock}
    {is : List Insn} (hg : gotoOk Γ next bb is = true) (hat : TermAt c s1 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.goto bb)) o s = (.ok (), s')) :
    ∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.stmt = 0 ∧ f'.body = f.body ∧
      blockStart Γ f'.bb = some s1'.pc ∧ s'.mem = s.mem ∧
      FnRel Γ.toStmtCtx ι live' f' s'.mem s1' := by
  obtain ⟨s2, hst, hb, hsst, hfp, -⟩ := goto_run (ch := ch) hg hat
  exact term_finish (goto_inv hs h) hst hb hsst hfp hrel hw

theorem sim_switchNone {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {next : Nat} {d : Operand} {l : Local}
    {otherwise : BasicBlock} {is : List Insn} (hd : d.local? = some l)
    (hg : gotoOk Γ next otherwise is = true) (hat : TermAt c s1 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.switchInt d [] otherwise)) o s = (.ok (), s')) :
    ∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.stmt = 0 ∧ f'.body = f.body ∧
      blockStart Γ f'.bb = some s1'.pc ∧ s'.mem = s.mem ∧
      FnRel Γ.toStmtCtx ι live' f' s'.mem s1' := by
  obtain ⟨p0, ty0, v0, bits0, hp0, hty0, hload0, hsw0, hs'⟩ := switchInt_inv hs hd h
  simp only [List.find?_nil] at hs'
  obtain ⟨s2, hst, hb, hsst, hfp, -⟩ := goto_run (ch := ch) hg hat
  exact term_finish hs' hst hb hsst hfp hrel hw

theorem sim_switchBool {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat}
    {d : Operand} {l : Local} {vc : Nat} {bb otherwise : BasicBlock} {sl : LocalSlot}
    {ibr : Insn} {tl : List Insn} {sv : Int} {neg : Bool} {t : Nat}
    (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some .bool)
    (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = 1) (hoff : offOk sl.off = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (sv, neg, t)) (hsv : sv = sl.off) (hv : vc < 2)
    (hsel : selOk Γ next neg t (selBool vc bb otherwise) tl = true)
    (hat : TermAt c s1 next (ibr :: tl)) (hpl : PlainView c.mode c.ρ ibr)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.switchInt d [(vc, bb)] otherwise)) o s = (.ok (), s')) :
    ∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.stmt = 0 ∧ f'.body = f.body ∧
      blockStart Γ f'.bb = some s1'.pc ∧ s'.mem = s.mem ∧
      FnRel Γ.toStmtCtx ι live' f' s'.mem s1' := by
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
  have hrf' : s1.st.readFrame sl.off 1 = .ok bs1 := by rw [← hsize]; exact hrf
  have hop : OpSem.opSem vw.op vw.ops s1.st ch = .ok (.branch (leDecode [dd] != 0), s1.st) := by
    rw [hops]; exact opSem_br_fwd hh ho h1 h2 hrf' hasn
  obtain ⟨hi0, hs0⟩ := hat.head
  have hstep := step_branch hi0 hs0 hat.pe hpl hvw hctl hop
  obtain ⟨s2, hst2, hb2, hsst, hfp2, -⟩ := branch_run hstep hsel hat
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
    exact term_finish hs' hst2 hb2 hsst hfp2 hrel hw
  · rw [if_neg hvb] at hs'
    dsimp only at hs'
    rw [← bool_target hv bb otherwise, if_neg hvb] at hb2
    exact term_finish hs' hst2 hb2 hsst hfp2 hrel hw

theorem sim_switchInt {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
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
    (hat : TermAt c s1 next (ibr :: tl)) (hpl : PlainView c.mode c.ρ ibr)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.switchInt d [(vc, bb)] otherwise)) o s = (.ok (), s')) :
    ∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.stmt = 0 ∧ f'.body = f.body ∧
      blockStart Γ f'.bb = some s1'.pc ∧ s'.mem = s.mem ∧
      FnRel Γ.toStmtCtx ι live' f' s'.mem s1' := by
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
  have hrf' : s1.st.readFrame sl.off ty.size = .ok bs1 := by rw [← hsize]; exact hrf
  have hop : OpSem.opSem vw.op vw.ops s1.st ch =
      .ok (.branch (BitVec.ofNat (8 * ty.size) u == BitVec.ofNat (8 * ty.size) y), s1.st) := by
    rw [hops]; exact opSem_brCmpImm_fwd hh hparse ho hfa hk2 hk3 hk4 hrf' hasn
  obtain ⟨hi0, hs0⟩ := hat.head
  have hstep := step_branch hi0 hs0 hat.pe hpl hvw hctl hop
  obtain ⟨s2, hst2, hb2, hsst, hfp2, -⟩ := branch_run hstep hsel hat
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
    exact term_finish hs' hst2 hb2 hsst hfp2 hrel hw
  · rw [if_neg hvb] at hs'
    dsimp only at hs'
    have hc : (u % 2 ^ (8 * ty.size) == vc) = false := by
      simp only [beq_eq_false_iff_ne, ne_eq]
      exact fun e => hvb e.symm
    simp only [selInt, hc, Bool.false_eq_true, if_false, ↓reduceIte] at hb2
    exact term_finish hs' hst2 hb2 hsst hfp2 hrel hw

/-- The dispatch over the rules other than `return`. -/
theorem sim_term {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {term : Terminator}
    {is : List Insn} (hlow : LowerTerm Γ next term is) (hnr : term ≠ .return)
    (hat : TermAt c s1 next is) (hpl : ∀ i, is.head? = some i → PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1)
    (hlive : ∀ (d : Operand) cs ow l, term = .switchInt d cs ow → d.local? = some l →
      live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    ∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.stmt = 0 ∧ f'.body = f.body ∧
      blockStart Γ f'.bb = some s1'.pc ∧ s'.mem = s.mem ∧
      FnRel Γ.toStmtCtx ι live' f' s'.mem s1' := by
  cases hlow
  case goto hg => exact sim_goto hs hg hat hrel hw h
  case ret => exact absurd rfl hnr
  case switchNone hd hg => exact sim_switchNone hs hd hg hat hrel hw h
  case switchBool hd hty hsl hsize hoff hbr hsv hv hsel =>
    exact sim_switchBool hs hbody hmode hρ hd hty hsl hsize hoff hbr hsv hv hsel hat
      (hpl _ rfl) hrel (hlive _ _ _ _ rfl hd) hw h
  case switchInt hd hty hsl hsize hoff hbr ha hv hy hsel =>
    exact sim_switchInt hs hbody hmode hρ hd hty hsl hsize hoff hbr ha hy hsel hat
      (hpl _ rfl) hrel (hlive _ _ _ _ rfl hd) hw h

/-- `retOk`'s facts. -/
theorem retOk_spec {Γ : TermCtx} {i : Insn} (h : retOk Γ i = true) :
    ∃ src k, retOps i = some (src, k) ∧ k = Γ.retKind ∧
      (k = 0 ∨ ∃ t valid s0, Γ.body.locals[0]? = some (.int t valid) ∧ Γ.slots[0]? = some s0 ∧
        Asm.retParts k true = some (some ⟨false, t.size, 0⟩, none) ∧ s0.size = t.size ∧
        s0.off = src) := by
  unfold retOk at h
  split at h
  next src k hro =>
    simp only [Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true] at h
    obtain ⟨hk, h2⟩ := h
    refine ⟨src, k, hro, hk, ?_⟩
    rcases h2 with h2 | h2
    · exact .inl h2
    · right
      split at h2
      next t valid s0 hl hs =>
        simp only [Bool.and_eq_true, beq_iff_eq] at h2
        obtain ⟨⟨h3, h4⟩, h5⟩ := h2
        exact ⟨t, valid, s0, hl, hs, h3, h4, h5⟩
      next => cases h2
  next => cases h

theorem retRegs_zero : retRegs 0 true = .ok [] := rfl

theorem retRegs_one {k n : Nat} (h : Asm.retParts k true = some (some ⟨false, n, 0⟩, none)) :
    retRegs k true = .ok [(⟨false, n, 0⟩, .gpr 0)] := by
  unfold retRegs
  rw [h]
  rfl

theorem regs_get_set (r : Reg) (bs : List AbstractByte) :
    (({} : Regs).set r bs).get r = bs := by
  simp [Regs.get, Regs.set]

/-- `return`: L0 ends the run with `_0`'s value `v` (at the bottom frame), and R's `ret` ends the
function with return registers whose low bytes decode to `v`'s bits when `_0` is an integer.

R's side: `retRegs` of the return kind (`retOk_spec`), the register fold
reading `_0`'s related slot); the incoming area's read is a hypothesis. -/
theorem sim_ret {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {next : Nat} {i : Insn} (hret : retOk Γ i = true) (hat : TermAt c s1 next [i])
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live 0 = true)
    (hcont : f.cont = .bottom)
    (hinc : ∃ bs, s1.st.readFrame 16 c.argSize = .ok bs)
    (h : runOn (evalTerminator .return) o s = (.ok (), s')) :
    ∃ v regs incoming, s'.final = some (.returned v) ∧
      R.step c s1 ch = .ok (.done (exit s1 (.ret regs incoming))) ∧
      (Γ.retKind ≠ 0 → ∀ t valid, Γ.body.locals[0]? = some (.int t valid) →
        ∃ u, v = .int (t.ofBits u) ∧ decodeBits ((regs.get (.gpr 0)).take t.size) = some u) := by
  obtain ⟨src, k, hro, hk, hcase⟩ := retOk_spec hret
  obtain ⟨op, fo, sw, kw, rfl, hf, hsh, hsrc, hkw⟩ := retOps_spec hro
  obtain ⟨hi, hs0⟩ := hat.head
  obtain ⟨incoming, hinc'⟩ := hinc
  obtain ⟨p, ty, v, g, s2, hp, hty, hload, -, -, hfin⟩ := return_inv hs h
  have hfinal : s'.final = some (.returned v) := by rw [hfin hcont]
  rw [step_eq_stepBody_nil hi hs0]
  by_cases hk0 : k = 0
  · have hparts : retRegs kw.toNat true = .ok [] := by rw [hkw, hk0]; exact retRegs_zero
    refine ⟨v, {}, incoming, hfinal, stepBody_ret hf hsh hparts rfl hinc', ?_⟩
    intro hne
    exact absurd (hk.symm.trans hk0) hne
  · rcases hcase with hk0' | ⟨t, valid, s0, hl0, hsl0, hrp, hsz, hoff⟩
    · exact absurd hk0' hk0
    rw [← hbody, hl0] at hty
    obtain rfl := (Option.some.inj hty).symm
    obtain ⟨bs0, u, hld, hdb, hlen0, rfl⟩ := typedLoad_int hload
    have hr := hrel.opnd hp hsl0 hlive
    have hld' : s.mem.load p s0.size .one = .ok bs0 := by rw [hsz]; exact hld
    obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld'
    have hlen1 : bs1.length = t.size := (BytesInj.length hbi).symm.trans hlen0
    have hrf' : s1.st.readFrame sw.toInt t.size = .ok bs1 := by
      rw [hsrc, ← hoff, ← hsz]; exact hrf
    have hparts : retRegs kw.toNat true = .ok [(⟨false, t.size, 0⟩, .gpr 0)] := by
      rw [hkw]; exact retRegs_one hrp
    refine ⟨.int (t.ofBits u), ({} : Regs).set (.gpr 0) (zext bs1 (Reg.gpr 0).width), incoming,
      hfinal, stepBody_ret hf hsh hparts ?_ hinc', ?_⟩
    · simp [hrf', bind, Except.bind, pure, Except.pure]
    · intro _ t' valid' hl'
      rw [hl0] at hl'
      obtain ⟨rfl, rfl⟩ : t = t' ∧ valid = valid' := by
        simp only [Option.some.injEq, Spec.Ty.int.injEq] at hl'
        exact hl'
      refine ⟨u, rfl, ?_⟩
      rw [regs_get_set]
      have htk : (zext bs1 (Reg.gpr 0).width).take t.size = bs1 := by
        unfold zext
        rw [← hlen1]
        simp
      rw [htk]
      exact decodeBits_inj hbi hdb

end Ryo.Proofs.Lower
