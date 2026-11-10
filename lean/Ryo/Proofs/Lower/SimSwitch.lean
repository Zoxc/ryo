/-
Ryo.Proofs.Lower.SimSwitch — the simulation of `LowerSwitch` (`Check/Lower/Switch.lean`, M5b):
a `SwitchInt` with one or more cases on an integer or `bool` local, lowered to a `br.eq.imm`
chain or a `switch.dense`, from `FnRel` at the terminator's first R index.

`sim_switch` has `sim_switchInt`'s shape (`SimTerm.lean`) with one more outcome
(`SwitchOut`): either R reaches, frame and memory unchanged, the start of L0's target block
and `FnRel` holds there at any weaker liveness, or L0's target is an empty block ending in
`unreachable` (`deadBlock`), from which L0 has no successful step (`dead_no_step`), so the
simulation needs nothing of R there. Using it in `fn_step_sim` needs `Match` (or `fn_sim`'s
conclusion) to admit that dead end.

Hypotheses beyond `sim_switchInt`'s: every instruction of the range is a plain view (`hpl`,
`LowersFn.plain`), as the chain has several branches.

The steps: `switch_read` (L0's load of the local and its `switchBits`, related to R's read of
the slot), `chain_run`/`dense_run` (R's run of the instructions, to a place `hitOk` for the
value), `hit_finish` (the end, `term_finish` or the dead end). `restOk_spec` is the meaning of
the check of the values a branch or goto takes; `opSem_switchDense_fwd` the forward `opSem` of
`switch.dense`.

The field rules (`chainF`/`denseF`, a switch on a field of a local): L0 loads the field
(`switchInt_inv_field`, by `runOn_evalOperand_field`), R reads the same bytes at the slot
offset (`readLocal_sub_inj`), `switchF_read` relates the two (`switch_read_at`, `switch_read`
for a load through any pointer); the run is the local rules'. `sim_switch`'s liveness
hypothesis is over every local of the operand (`operandLocals`), as a field's local is not
`d.local?`. `LowerSwitch.term_next` is `term_nextX`'s case for the family. -/
import Ryo.Proofs.Lower.FnSim
import Ryo.Proofs.Lower.SimTermMore
import Ryo.Check.Lower.Switch

namespace Ryo.Proofs.Lower

/-! ### Forward `opSem` of `switch.dense` -/

section
open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem

/-- `switch.dense` at `n` bytes on slot `a` with base `y` and a table of `len` entries: the
index `(s - base)` at the width, `len` (the default) when past the table, the state unchanged.

Proof: as `opSem_brCmpImm_fwd` (`SimTerm.lean`): `footprint_eq hh` and `footprintOf`'s
`switch_dense` case (`{ reads := [rdA "s" n], flow := .table }`, by `simp [footprintOf,
tySize_of_parse hty]`), `prepare` (the fits from `hfa`..`hk4`), `readAll` of the one read,
`kindSem .switch_dense` (`intTy` from `hty`, `e.val "table" = some (.targets len)` by
`opndVal`), `commit` of no writes. -/
theorem opSem_switchDense_fwd {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat}
    {sg : Bool} {k2 k3 k4 : OperandKind} {a : Int} {y len : Nat} {st : OpSem.State}
    {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.switch_dense, [ty], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"s", .slot⟩, ⟨"base", k2⟩, ⟨"default", k3⟩, ⟨"table", k4⟩])
    (hfa : Val.fits .slot (.slot a) = true) (hk2 : Val.fits k2 (.imm y) = true)
    (hk3 : Val.fits k3 .none = true) (hk4 : Val.fits k4 (.targets len) = true)
    {bs : List AbstractByte} {u : Nat}
    (hr : st.readFrame a n = .ok bs) (hu : asNat bs = .ok u) :
    opSem op [.slot a, .imm y, .none, .targets len] st ch =
      .ok (.index
        (if (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat < len then
          (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat
        else len), st) := by
  have hfp : footprint op = some { reads := [Ryo.Proofs.Inline.rdA "s" n], flow := .table } := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    simp only [footprintOf, List.head?, Option.bind_some, Ryo.Proofs.Inline.tySize_of_parse hty]
    try rfl
  have hprep : prepare op [.slot a, .imm y, .none, .targets len] =
      .ok (⟨.switch_dense, [ty], r⟩,
        { reads := [Ryo.Proofs.Inline.rdA "s" n], flow := .table },
        opndVal op.info [.slot a, .imm y, .none, .targets len]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfa, hk2, hk3, hk4])]
    rfl
  have hvs : opndVal op.info [.slot a, .imm y, .none, .targets len] "s" = some (.slot a) := by
    simp [opndVal, ho]
  have hvy : opndVal op.info [.slot a, .imm y, .none, .targets len] "base" = some (.imm y) := by
    simp [opndVal, ho]
  have hvt : opndVal op.info [.slot a, .imm y, .none, .targets len] "table" =
      some (.targets len) := by
    simp [opndVal, ho]
  have hrd : readAll { reads := [Ryo.Proofs.Inline.rdA "s" n], flow := .table }
      (opndVal op.info [.slot a, .imm y, .none, .targets len]) st = .ok [("s", bs)] := by
    simp only [readAll, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvs, Val.slotOff, Extent.eval, hr,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .switch_dense [ty]
      (mkEnv [("s", bs)] (opndVal op.info [.slot a, .imm y, .none, .targets len]) st ch) =
      .ok { ctl := .index
              (if (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat < len then
                (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat
              else len),
            mem := st.mem, writes := [] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, Env.immBv,
      Env.imm, out, hu, hvy, hvt, bind, Except.bind, pure, Except.pure]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure, commit,
    List.foldlM_nil, hst]

end

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-! ### The outcome -/

/-- `sim_switchInt`'s conclusion, or L0 at the start of a dead block (see the module
comment). -/
def SwitchOut (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (s s' : Spec.State) (f : Spec.Frame) (rest : List Spec.Frame) (s1 : RState) : Prop :=
  (∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.stmt = 0 ∧ f'.body = f.body ∧
      blockStart Γ f'.bb = some s1'.pc ∧ s'.mem = s.mem ∧
      FnRel Γ.toStmtCtx ι live' f' s'.mem s1') ∨
    ∃ ow, s'.stack = { f with bb := ow, stmt := 0 } :: rest ∧ deadBlock Γ ow = true

/-- L0 has no successful step at the start of a dead block: its terminator is `unreachable`.

Proof: `step_final_none` gives `s.final = none`; the block has no statements (`deadBlock`:
`stmts.isEmpty`), so `step_term_inv` (with `hbody`, `hpu`) turns the step into
`evalTerminator .unreachable`, which is `throwUb` (`Terminator.lean`), an error:
`prod_err_ok`. -/
theorem dead_no_step {Γ : TermCtx} {o : Spec.Oracle} {s s'' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : f.body = Γ.body)
    (hpu : f.pendingUnwind = none) (hst : f.stmt = 0) (hd : deadBlock Γ f.bb = true) :
    runOn Sem.step o s ≠ (.ok (), s'') := by
  intro h
  have hfin := step_final_none h
  unfold deadBlock at hd
  split at hd
  next bd hbd =>
    simp only [Bool.and_eq_true, beq_iff_eq, List.isEmpty_iff] at hd
    obtain ⟨hem, hterm⟩ := hd
    have hbd' : f.body.blocks[f.bb]? = some bd := by rw [hbody]; exact hbd
    have hst' : bd.stmts[f.stmt]? = none := by simp [hem]
    have h2 := step_term_inv hs hfin hpu hbd' hst' h
    rw [hterm] at h2
    have e : runOn (evalTerminator .unreachable) o s =
        (.error (.ub "reached unreachable code"), s) := rfl
    rw [e] at h2
    exact prod_err_ok h2
  next => cases hd

/-! ### Reading the switch value -/

/-- R reads the switch value: the slot's `n` bytes are a number `u` whose low `8 n` bits are
L0's `switchBits`.

Proof: integers as `sim_switchInt` (`typedLoad_int`, `hrel.opnd`, `readLocal_inj
hrel.frame.mem`, `decodeBits_inj`; `switchBits` is `ty.toBits (ty.ofBits u)`, so
`IntType.toBits_ofBits` and `modulus_eq_two_pow`); `bool` as `sim_switchBool`
(`typedLoad_bool`: the byte `dd` is 0 or 1, `asNat` is `leDecode [dd] = dd`, and
`switchBits` is `dd`, `dd % 2 ^ 8 = dd`). -/
theorem switch_read {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {s : Spec.State} {s1 : RState} {o : Spec.Oracle} {l : Local} {ty : Spec.Ty} {n : Nat}
    {sl : LocalSlot} {p : ThinPointer} {v : Value} {bits : Nat}
    (hrel : FnRel Γ ι live f s.mem s1) (hlive : live l = true)
    (hp : f.locals[l]? = some (some p)) (hty : f.body.locals[l]? = some ty)
    (hbody : Γ.body = f.body) (hn : switchTy ty = some n) (hsl : Γ.slots[l]? = some sl)
    (hsize : sl.size = n) (hload : typedLoad s.mem p ty .one = .ok v)
    (hsw : runOn (switchBits (v, ty)) o s = (.ok bits, s)) :
    ∃ bs u, s1.st.readFrame sl.off n = .ok bs ∧ OpSem.asNat bs = .ok u ∧
      bits = u % 2 ^ (8 * n) := by
  cases ty
  all_goals first | (simp [switchTy] at hn; done) | skip
  case int t valid =>
    have hn' : n = t.size := by
      simp only [switchTy, Option.some.injEq] at hn; exact hn.symm
    subst hn'
    obtain ⟨bs, u, hld, hdb, -, rfl⟩ := typedLoad_int hload
    have hr := hrel.opnd hp hsl hlive
    have hld' : s.mem.load p sl.size .one = .ok bs := by rw [hsize]; exact hld
    obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld'
    have hdec1 := decodeBits_inj hbi hdb
    have hasn : OpSem.asNat bs1 = .ok u := by
      unfold OpSem.asNat; rw [hdec1]; rfl
    refine ⟨bs1, u, by rw [← hsize]; exact hrf, hasn, ?_⟩
    have e : runOn (switchBits (.int (t.ofBits u), .int t valid)) o s =
        (.ok (t.toBits (t.ofBits u)), s) := rfl
    rw [e] at hsw
    simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
    rw [← hsw.1, Ryo.Spec.Theorems.IntType.toBits_ofBits, ← modulus_eq_two_pow]
  case bool =>
    have hn' : n = 1 := by
      simp only [switchTy, Option.some.injEq] at hn; omega
    subst hn'
    obtain ⟨dd, pr, hld, hcase⟩ := typedLoad_bool hload
    have hr := hrel.opnd hp hsl hlive
    have hld' : s.mem.load p sl.size .one = .ok [.init dd pr] := by rw [hsize]; exact hld
    obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld'
    have hdec0 : decodeBits [AbstractByte.init dd pr] = some (leDecode [dd]) := rfl
    have hdec1 := decodeBits_inj hbi hdec0
    have hasn : OpSem.asNat bs1 = .ok (leDecode [dd]) := by
      unfold OpSem.asNat; rw [hdec1]; rfl
    refine ⟨bs1, leDecode [dd], by rw [← hsize]; exact hrf, hasn, ?_⟩
    rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · have e : runOn (switchBits (.bool false, .bool)) o s = (.ok 0, s) := rfl
      rw [e] at hsw
      simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
      rw [← hsw.1]
      first | rfl | decide | simp [leDecode]
    · have e : runOn (switchBits (.bool true, .bool)) o s = (.ok 1, s) := rfl
      rw [e] at hsw
      simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
      rw [← hsw.1]
      first | rfl | decide | simp [leDecode]

/-- `switch_read` for a load through any pointer `q` whose `n` bytes R reads at `x`
(`hread`), as `br_read_step` does for `br`. Same proof. -/
theorem switch_read_at {ι : Inj} {s : Spec.State} {q : ThinPointer} {ty : Spec.Ty} {n : Nat}
    {v : Value} {bits : Nat} {o : Spec.Oracle} {st : OpSem.State} {x : Int}
    (hn : switchTy ty = some n) (hload : typedLoad s.mem q ty .one = .ok v)
    (hread : ∀ bs0, s.mem.load q n .one = .ok bs0 →
      ∃ bs1, st.readFrame x n = .ok bs1 ∧ BytesInj ι bs0 bs1)
    (hsw : runOn (switchBits (v, ty)) o s = (.ok bits, s)) :
    ∃ bs u, st.readFrame x n = .ok bs ∧ OpSem.asNat bs = .ok u ∧
      bits = u % 2 ^ (8 * n) := by
  cases ty
  all_goals first | (simp [switchTy] at hn; done) | skip
  case int t valid =>
    have hn' : n = t.size := by
      simp only [switchTy, Option.some.injEq] at hn; exact hn.symm
    subst hn'
    obtain ⟨bs, u, hld, hdb, -, rfl⟩ := typedLoad_int hload
    obtain ⟨bs1, hrf, hbi⟩ := hread _ hld
    have hdec1 := decodeBits_inj hbi hdb
    have hasn : OpSem.asNat bs1 = .ok u := by
      unfold OpSem.asNat; rw [hdec1]; rfl
    refine ⟨bs1, u, hrf, hasn, ?_⟩
    have e : runOn (switchBits (.int (t.ofBits u), .int t valid)) o s =
        (.ok (t.toBits (t.ofBits u)), s) := rfl
    rw [e] at hsw
    simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
    rw [← hsw.1, Ryo.Spec.Theorems.IntType.toBits_ofBits, ← modulus_eq_two_pow]
  case bool =>
    have hn' : n = 1 := by
      simp only [switchTy, Option.some.injEq] at hn; omega
    subst hn'
    obtain ⟨dd, pr, hld, hcase⟩ := typedLoad_bool hload
    obtain ⟨bs1, hrf, hbi⟩ := hread _ hld
    have hdec0 : decodeBits [AbstractByte.init dd pr] = some (leDecode [dd]) := rfl
    have hdec1 := decodeBits_inj hbi hdec0
    have hasn : OpSem.asNat bs1 = .ok (leDecode [dd]) := by
      unfold OpSem.asNat; rw [hdec1]; rfl
    refine ⟨bs1, leDecode [dd], hrf, hasn, ?_⟩
    rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · have e : runOn (switchBits (.bool false, .bool)) o s = (.ok 0, s) := rfl
      rw [e] at hsw
      simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
      rw [← hsw.1]
      first | rfl | decide | simp [leDecode]
    · have e : runOn (switchBits (.bool true, .bool)) o s = (.ok 1, s) := rfl
      rw [e] at hsw
      simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
      rw [← hsw.1]
      first | rfl | decide | simp [leDecode]

/-- `switchInt_inv` for a field of a local (`fieldPath`): L0 loads the field at the local's
pointer plus `off` and goes to `caseTarget` of the value's `switchBits`.

Proof: as `switchInt_inv`, with `runOn_evalOperand_field` for the operand. -/
theorem switchInt_inv_field {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Operand} {a : Local}
    {projs : List ProjElem} {ta ty : Spec.Ty} {off : Nat}
    (hd : operandPlace? d = some ⟨a, projs⟩) (hta : f.body.locals[a]? = some ta)
    (hpath : fieldPath ta projs = some (off, ty)) {cases : List (Nat × BasicBlock)}
    {otherwise : BasicBlock}
    (h : runOn (evalTerminator (.switchInt d cases otherwise)) o s = (.ok (), s')) :
    ∃ pa v bits, f.locals[a]? = some (some pa) ∧
      typedLoad s.mem ⟨pa.addr + off, pa.prov⟩ ty .one = .ok v ∧
      runOn (switchBits (v, ty)) o s = (.ok bits, s) ∧
      s' = { s with stack :=
        { f with bb := caseTarget cases otherwise bits, stmt := 0 } :: rest } := by
  have e : evalTerminator (.switchInt d cases otherwise) = (evalOperand d >>= fun x =>
      switchBits x >>= fun bits =>
      match cases.find? (·.1 == bits) with
      | some (_, bb) => SemM.jumpTo bb
      | none => SemM.jumpTo otherwise) := rfl
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pa, v, hpa, hv, hx, hs1⟩ := runOn_evalOperand_field hs hd hta hpath h1
  rw [hx, hs1] at h2
  obtain ⟨bits, s2, h3, h4⟩ := runOn_bind_ok h2
  have hs2 : s2 = s := by
    revert h3
    unfold switchBits
    split <;> intro h3 <;> first
      | exact (prod_ok_inj h3).2.symm
      | exact (prod_err_ok h3).elim
  subst s2
  refine ⟨pa, v, bits, hpa, hv, h3, ?_⟩
  rcases hf : cases.find? (·.1 == bits) with _ | ⟨_, bb⟩
  · simp only [hf] at h4
    rw [runOn_jumpTo hs] at h4
    simp only [caseTarget, hf]
    exact (prod_ok_inj h4).2.symm
  · simp only [hf] at h4
    rw [runOn_jumpTo hs] at h4
    simp only [caseTarget, hf]
    exact (prod_ok_inj h4).2.symm

/-- A switch on a field of a related local: R reads the field's bytes at `sa.off + off`, a
number `u` whose low `8 n` bits L0's target is chosen by.

Proof: `switchInt_inv_field`, `FnRel.opnd` (`_a` live), `switch_read_at` with
`readLocal_sub_inj`. -/
theorem switchF_read {Γ : TermCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {s s' : Spec.State} {rest : List Spec.Frame} {s1 : RState} {o : Spec.Oracle}
    (hs : s.stack = f :: rest) (hbody : Γ.body = f.body) {d : Operand} {a : Local}
    {projs : List ProjElem} {ta ty : Spec.Ty} {off n : Nat} {sa : LocalSlot}
    {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    (hd : operandPlace? d = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
    (hpath : fieldPath ta projs = some (off, ty)) (hn : switchTy ty = some n)
    (hsa : Γ.slots[a]? = some sa) (hin : off + n ≤ sa.size)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live a = true)
    (h : runOn (evalTerminator (.switchInt d cases otherwise)) o s = (.ok (), s')) :
    ∃ bs u, s1.st.readFrame (sa.off + off) n = .ok bs ∧ OpSem.asNat bs = .ok u ∧
      s' = { s with stack :=
        { f with bb := caseTarget cases otherwise (u % 2 ^ (8 * n)), stmt := 0 } :: rest } := by
  rw [hbody] at hta
  obtain ⟨pa, v, bits, hpa, hload, hsw, hs'⟩ := switchInt_inv_field hs hd hta hpath h
  have hr := hrel.opnd (Γ := Γ.toStmtCtx) hpa hsa hlive
  obtain ⟨bs, u, hrf, hu, hb⟩ := switch_read_at (ι := ι) (st := s1.st) (x := sa.off + off) hn
    hload (fun _ hl => readLocal_sub_inj hrel.frame.mem hr hin hl) hsw
  subst hb
  exact ⟨bs, u, hrf, hu, hs'⟩

/-! ### R's run -/

/-- `restOk`'s meaning: `pc` is a correct place for each value below `2 ^ (8 n)` outside `ex`.

Proof: unfold `restOk`, `hitOk`, `caseTarget`; on `cases.find? (·.1 == x)`: `none`, the target
is `otherwise` and the first conjunct gives it; `some (v, bb)`, `v = x`
(`List.find?_some`), and the case's conjunct (`List.all_eq_true`,
`List.mem_of_find?_eq_some`) has its first two disjuncts false (`hx`, `hex`). -/
theorem restOk_spec {Γ : TermCtx} {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    {n : Nat} {ex : Nat → Bool} {pc : Nat} (h : restOk Γ cases otherwise n ex pc = true)
    {x : Nat} (hx : x < 2 ^ (8 * n)) (hex : ex x = false) :
    hitOk Γ cases otherwise x pc = true := by
  unfold restOk at h
  simp only [Bool.and_eq_true, List.all_eq_true] at h
  obtain ⟨h1, h2⟩ := h
  rcases hf : cases.find? (·.1 == x) with _ | ⟨v, bb⟩
  · unfold hitOk caseTarget
    simp only [hf]
    simp only [Bool.or_eq_true, beq_iff_eq] at h1
    rcases h1 with h1 | h1 <;> simp [h1]
  · have hv : v = x := by simpa using List.find?_some hf
    subst hv
    have h3 := h2 _ (List.mem_of_find?_eq_some hf)
    simp only [Bool.or_eq_true, decide_eq_true_eq] at h3
    rcases h3 with (h3 | h3) | h3
    · exact absurd h3 (Nat.not_le.mpr hx)
    · rw [hex] at h3; cases h3
    · exact h3

/-- R's run of a `chainOk` chain, for the slot value `u` not among the tested values `ex`: to
a correct place for `u`'s low `8 n` bits, its state unchanged.

Proof: induction on `is` (generalizing `ex`, `s1`). `[]`: `restOk_spec` at `s1.pc = next`
(`hat.hnext`). A `jmp`: `jmpTo_spec`, one step (`step_eq_stepBody_nil`, `stepBody_jmp`), then
`restOk_spec`. A test (`brImmOps_spec`, `intTyOk_spec`, `operands4`, the fits from `hpl`): its
step by `opSem_brCmpImm_fwd` and `step_branch` (with `hmode`, `hρ`), its condition
`u % m == y % m` by `bv_ofNat_beq`. Without `neg`: taken, `x = yv`, so `yv ∉ ex` and the
`hitOk` conjunct gives it; not taken, the induction hypothesis on `hat.tail` with
`x ∉ yv :: ex`. With `neg`: taken, `x ≠ yv`, `restOk_spec`; not taken, `x = yv` and
`s1.pc + 1 = next` (`tl = []`, `hat.hnext`). -/
theorem chain_run {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} (hmode : c.mode = Γ.mode)
    (hρ : c.ρ = Γ.ρ) {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {n : Nat}
    {a : Int} {bs : List AbstractByte} {u : Nat} (hu : OpSem.asNat bs = .ok u) :
    ∀ {ex : List Nat} {is : List Insn} {s1 : RState} {next : Nat},
      chainOk Γ next cases otherwise n a ex is = true → TermAt c s1 next is →
      (∀ i ∈ is, PlainView c.mode c.ρ i) → s1.st.readFrame a n = .ok bs →
      ex.contains (u % 2 ^ (8 * n)) = false →
      ∃ s2, StepsTo c ch s1 s2 ∧ hitOk Γ cases otherwise (u % 2 ^ (8 * n)) s2.pc = true ∧
        s2.st = s1.st ∧ s2.fp = s1.fp ∧ s2.args = s1.args := by
  have hxlt : u % 2 ^ (8 * n) < 2 ^ (8 * n) := Nat.mod_lt _ (Nat.two_pow_pos _)
  intro ex is
  induction is generalizing ex with
  | nil =>
    intro s1 next hok hat _ _ hex
    refine ⟨s1, .refl _, ?_, rfl, rfl, rfl⟩
    have h := hat.hnext
    simp only [List.length_nil, Nat.add_zero] at h
    subst h
    simp only [chainOk] at hok
    exact restOk_spec (ex := fun x => ex.contains x) hok hxlt hex
  | cons i tl ih =>
    intro s1 next hok hat hpl hrf hex
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
      have hop : OpSem.opSem vw.op vw.ops s1.st ch =
          .ok (.branch (BitVec.ofNat (8 * n) u == BitVec.ofNat (8 * n) y), s1.st) := by
        rw [hops]; exact opSem_brCmpImm_fwd hh hparse ho hfa hk2 hk3 hk4 hrf hu
      have hstep := step_branch hi0 hs0 hat.pe hpli hvw hctl hop
      rw [bv_ofNat_beq] at hstep
      cases neg
      · -- a test without `neg`: taken on equality, else the rest of the chain
        simp only [Bool.false_eq_true, ↓reduceIte, Bool.and_eq_true, Bool.or_eq_true] at hok
        obtain ⟨hhit, hrest⟩ := hok
        by_cases hxy : u % 2 ^ (8 * n) = y % 2 ^ (8 * n)
        · have hc : ((u % 2 ^ (8 * n) == y % 2 ^ (8 * n)) != false) = true := by simp [hxy]
          simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
          refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl, rfl⟩
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
          obtain ⟨s2, hst2, hhit2, hsst, hfp, har⟩ :=
            @ih (y % 2 ^ (8 * n) :: ex) { s1 with pc := s1.pc + 1 } next hrest hat.tail
              (fun j hj => hpl j (List.mem_cons_of_mem _ hj)) hrf hex'
          exact ⟨s2, .cons hstep hst2, hhit2, hsst, hfp, har⟩
      · -- the last test, with `neg`: falls through on equality, else branches
        simp only [eq_self_iff_true, if_true, ↓reduceIte, Bool.and_eq_true, Bool.or_eq_true,
          List.isEmpty_iff] at hok
        obtain ⟨⟨htl, hhit⟩, hrest⟩ := hok
        subst htl
        by_cases hxy : u % 2 ^ (8 * n) = y % 2 ^ (8 * n)
        · have hc : ((u % 2 ^ (8 * n) == y % 2 ^ (8 * n)) != true) = false := by simp [hxy]
          simp only [hc, Bool.false_eq_true, ↓reduceIte] at hstep
          have hn' : s1.pc + 1 = next := by
            have h := hat.hnext
            simp only [List.length_cons, List.length_nil] at h
            omega
          refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl, rfl⟩
          show hitOk Γ cases otherwise (u % 2 ^ (8 * n)) (s1.pc + 1) = true
          rw [hn', hxy]
          rcases hhit with h | h
          · rw [hxy] at hex; rw [hex] at h; cases h
          · exact h
        · have hc : ((u % 2 ^ (8 * n) == y % 2 ^ (8 * n)) != true) = true := by simp [hxy]
          simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
          refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl, rfl⟩
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
          have hstep : R.step c s1 ch = .ok (.step { s1 with pc := t }) := by
            rw [step_eq_stepBody_nil hi0 hs0, stepBody_jmp hf hsh]
          exact ⟨{ s1 with pc := t }, .cons hstep (.refl _),
            restOk_spec (ex := fun x => ex.contains x) (pc := t) hok hxlt hex, rfl, rfl, rfl⟩

/-- `denseOps`'s facts. -/
theorem denseOps_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {a : Int} {y len : Nat}
    {ts : List Nat} (h : denseOps Γ i n = some (a, y, len, ts)) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.switch_dense, [ty], r⟩ ∧
      intTyOk ty n = true ∧ v.ops = [.slot a, .imm y, .none, .targets len] ∧
      v.ctl = some (.table ts) ∧
      v.op.info.operands.map (·.name) = ["s", "base", "default", "table"] ∧
      v.op.info.operands.head?.map (·.kind) = some .slot ∧ ts.length = len + 1 := by
  unfold denseOps at h
  split at h
  next v hv =>
    split at h
    next ty r a' y' len' ts' hh hops hctl =>
      split at h
      next hc =>
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl, rfl, rfl⟩ := h
        simp only [Bool.and_eq_true, beq_iff_eq] at hc
        obtain ⟨⟨⟨hty, hn⟩, hk⟩, hl⟩ := hc
        exact ⟨v, ty, r, hv, hh, hty, hops, hctl, hn, hk, hl⟩
      next => cases h
    next => cases h
  next => cases h

theorem operandsDense {l : List OperandInfo}
    (hn : l.map (·.name) = ["s", "base", "default", "table"])
    (hk : l.head?.map (·.kind) = some .slot) :
    ∃ k2 k3 k4, l = [⟨"s", .slot⟩, ⟨"base", k2⟩, ⟨"default", k3⟩, ⟨"table", k4⟩] := by
  rcases l with _ | ⟨⟨n1, k1⟩, _ | ⟨⟨n2, k2⟩, _ | ⟨⟨n3, k3⟩, _ | ⟨⟨n4, k4⟩, _ | ⟨w, l⟩⟩⟩⟩⟩ <;>
    simp at hn
  simp at hk
  obtain ⟨rfl, rfl, rfl, rfl⟩ := hn
  subst hk
  exact ⟨_, _, _, rfl⟩

/-- The dense index `(A + (m - B)) % m` of value `A` from base `B`, added back to `B`. -/
theorem dense_idx_mod {m A B : Nat} (hA : A < m) (hB : B < m) :
    (B + (A + (m - B)) % m) % m = A ∧ (A + (m - B)) % m < m := by
  refine ⟨?_, Nat.mod_lt _ (by omega)⟩
  by_cases h : B ≤ A
  · have e1 : A + (m - B) = (A - B) + m := by omega
    rw [e1, Nat.add_mod_right, Nat.mod_eq_of_lt (by omega : A - B < m)]
    have e2 : B + (A - B) = A := by omega
    rw [e2, Nat.mod_eq_of_lt hA]
  · rw [Nat.mod_eq_of_lt (by omega : A + (m - B) < m)]
    have e2 : B + (A + (m - B)) = A + m := by omega
    rw [e2, Nat.add_mod_right, Nat.mod_eq_of_lt hA]

/-- R's step of a `denseOk` `switch.dense`: to a correct place for the slot value's low
`8 n` bits, its state unchanged.

Proof: `denseOps`'s facts (as `brImmOps_spec`: the view, `switch_dense` handler, operands,
`ctl = some (.table ts)`, `ts.length = len + 1`), `opSem_switchDense_fwd`, the step by
`step_eq_stepBody_nil`, `stepBody_switch` (`ViewShape` as in `step_branch`). With
`x = u % m` and `i = (x + (m - y % m)) % m` (`BitVec.toNat_sub`, `BitVec.toNat_ofNat`):
`i < len` gives `ts[i]?`, `(y + i) % m = x` (`omega` after `Nat.add_mod`), and `denseOk`'s
first conjunct at `k = i` (`List.mem_range`; `i < m`); else the default `ts[len]?` and
`restOk_spec` with `ex x = false` from `¬ i < len`. -/
theorem dense_run {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {s1 : RState} {next : Nat}
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {cases : List (Nat × BasicBlock)}
    {otherwise : BasicBlock} {n : Nat} {i : Insn} {a : Int} {y len : Nat} {ts : List Nat}
    (hden : denseOps Γ.toStmtCtx i n = some (a, y, len, ts))
    (hok : denseOk Γ cases otherwise n y len ts = true)
    (hat : TermAt c s1 next [i]) (hpl : PlainView c.mode c.ρ i)
    {bs : List AbstractByte} {u : Nat} (hrf : s1.st.readFrame a n = .ok bs)
    (hu : OpSem.asNat bs = .ok u) :
    ∃ s2, StepsTo c ch s1 s2 ∧ hitOk Γ cases otherwise (u % 2 ^ (8 * n)) s2.pc = true ∧
      s2.st = s1.st ∧ s2.fp = s1.fp ∧ s2.args = s1.args := by
  obtain ⟨vw, tyS, r, hvw, hh, htyS, hops, hctl, hn, hk, hlen⟩ := denseOps_spec hden
  obtain ⟨sg, hparse⟩ := intTyOk_spec htyS
  obtain ⟨k2, k3, k4, ho⟩ := operandsDense hn hk
  rw [← hmode, ← hρ] at hvw
  have hfits := hpl.fits vw hvw
  rw [ho, hops] at hfits
  simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
    Bool.and_true, Bool.and_eq_true] at hfits
  obtain ⟨hfa, hk2, hk3, hk4⟩ := hfits
  have hop : OpSem.opSem vw.op vw.ops s1.st ch =
      .ok (.index
        (if (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat < len then
          (BitVec.ofNat (8 * n) u - BitVec.ofNat (8 * n) y).toNat
        else len), s1.st) := by
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
    have hstep : R.step c s1 ch = .ok (.step { s1 with pc :=
        ts[(u % 2 ^ (8 * n) + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n)] }) := by
      rw [step_eq_stepBody_nil hi0 hs0]
      exact stepBody_switch hnat hvw hctl (hpl.notResume _ hvw (ctl_ne_trap hctl))
          (hpl.notUnreachable _ hvw (ctl_ne_trap hctl))
        hat.pe hop hget
    have h3 := List.all_eq_true.mp hall _ (List.mem_range.mpr hil)
    try dsimp only at h3
    rw [hget] at h3
    simp only [Bool.or_eq_true, decide_eq_true_eq] at h3
    rcases h3 with h3 | h3
    · exact absurd h3 (Nat.not_le.mpr hlt)
    · refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl, rfl⟩
      rw [Nat.add_mod y _ (2 ^ (8 * n)),
        Nat.mod_mod (u % 2 ^ (8 * n) + (2 ^ (8 * n) - y % 2 ^ (8 * n))) (2 ^ (8 * n)),
        hmod] at h3
      exact h3
  · rw [if_neg hil] at hop
    have hget : ts[len]? = some ts[len] := List.getElem?_eq_getElem (by omega)
    have hstep : R.step c s1 ch = .ok (.step { s1 with pc := ts[len] }) := by
      rw [step_eq_stepBody_nil hi0 hs0]
      exact stepBody_switch hnat hvw hctl (hpl.notResume _ hvw (ctl_ne_trap hctl))
          (hpl.notUnreachable _ hvw (ctl_ne_trap hctl))
        hat.pe hop hget
    rw [hget] at hdef
    refine ⟨_, .cons hstep (.refl _), ?_, rfl, rfl, rfl⟩
    exact restOk_spec
      (ex := fun x => decide ((x + (2 ^ (8 * n) - y % 2 ^ (8 * n))) % 2 ^ (8 * n) < len))
      (pc := ts[len]) hdef hA (decide_eq_false hil)

/-- The end: L0 at `caseTarget`'s start, R at a correct place for the value.

Proof: unfold `hitOk`; if `blockStart` of the target is `s2.pc`, `term_finish` (left);
else the target is `otherwise` and `otherwise` is dead (right, `rw [hs', e]`). -/
theorem hit_finish {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    {s1 s2 : RState} {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock} {x : Nat}
    (hs' : s' = { s with stack :=
      { f with bb := caseTarget cases otherwise x, stmt := 0 } :: rest })
    (hst : StepsTo c ch s1 s2) (hhit : hitOk Γ cases otherwise x s2.pc = true)
    (hsst : s2.st = s1.st) (hfp : s2.fp = s1.fp) (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1)
    (hw : ∀ l, live' l = true → live l = true) :
    SwitchOut Γ c ch ι live' s s' f rest s1 := by
  unfold hitOk at hhit
  simp only [Bool.or_eq_true, beq_iff_eq, Bool.and_eq_true] at hhit
  rcases hhit with hb | ⟨e, hd⟩
  · exact .inl (term_finish hs' hst hb hsst hfp hrel hw)
  · refine .inr ⟨otherwise, ?_, hd⟩
    subst hs'
    show ({ f with bb := caseTarget cases otherwise x, stmt := 0 } :: rest) = _
    rw [e]

/-! ### The rule -/

/-- A `SwitchInt` with one or more cases (see the module comment).

Proof: `cases hlow`; in both rules `switchInt_inv hs hd h` (its target is `caseTarget cases
otherwise bits` by `rfl`), `switch_read` (with `hbody`, `hlive _ _ _ _ rfl hd`), then
`chain_run` (`ex = []`, `hpl`) or `dense_run` (`hpl _ (by simp)`), the value `bits = u % m`,
and `hit_finish`. -/
theorem sim_switch {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {term : Terminator}
    {is : List Insn} (hlow : LowerSwitch Γ next term is)
    (hat : TermAt c s1 next is) (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1)
    (hlive : ∀ (d : Operand) cs ow l, term = .switchInt d cs ow → l ∈ operandLocals d →
      live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    SwitchOut Γ c ch ι live' s s' f rest s1 := by
  cases hlow
  case chain hd hty hn hsl hsize hoff hok =>
    obtain ⟨p, ty0, v, bits, hp, hty', hload, hsw, hs'⟩ := switchInt_inv hs hd h
    rw [hbody] at hty
    rw [hty] at hty'
    obtain rfl := (Option.some.inj hty').symm
    obtain ⟨bs, u, hrf, hu, hbits⟩ := switch_read (Γ := Γ.toStmtCtx) hrel
      (hlive _ _ _ _ rfl (operand_local_mem hd)) hp hty hbody hn hsl hsize hload hsw
    subst hbits
    obtain ⟨s2, hst, hhit, hsst, hfp, -⟩ :=
      chain_run (ch := ch) hmode hρ hu (ex := []) hok hat hpl hrf rfl
    refine hit_finish ?_ hst hhit hsst hfp hrel hw
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
    obtain ⟨s2, hst, hhit, hsst, hfp, -⟩ :=
      dense_run (ch := ch) hmode hρ hden hok hat (hpl _ (by simp)) hrf hu
    refine hit_finish ?_ hst hhit hsst hfp hrel hw
    exact hs'
  case chainF hd hta hpath hn hsa hin hok =>
    obtain ⟨bs, u, hrf, hu, hs'⟩ := switchF_read hs hbody hd hta hpath hn hsa hin hrel
      (hlive _ _ _ _ rfl (operandPlace?_base_mem hd)) h
    obtain ⟨s2, hst, hhit, hsst, hfp, -⟩ :=
      chain_run (ch := ch) hmode hρ hu (ex := []) hok hat hpl hrf rfl
    exact hit_finish hs' hst hhit hsst hfp hrel hw
  case denseF hd hta hpath hn hsa hin hden ha hok =>
    subst ha
    obtain ⟨bs, u, hrf, hu, hs'⟩ := switchF_read hs hbody hd hta hpath hn hsa hin hrel
      (hlive _ _ _ _ rfl (operandPlace?_base_mem hd)) h
    obtain ⟨s2, hst, hhit, hsst, hfp, -⟩ :=
      dense_run (ch := ch) hmode hρ hden hok hat (hpl _ (by simp)) hrf hu
    exact hit_finish hs' hst hhit hsst hfp hrel hw

/-- `term_nextX`'s case for `LowerSwitch`: L0 jumps to one of the switch's successors, memory
unchanged.

Proof: per rule, `switchInt_inv` or `switchInt_inv_field` (with `hbody`); the target
`caseTarget cs ow bits` is a case's block or `otherwise` (`List.mem_of_find?_eq_some`). -/
theorem _root_.Ryo.Check.Lower.LowerSwitch.term_next {Γ : TermCtx} {next : Nat}
    {term : Terminator} {is : List Insn} (hl : LowerSwitch Γ next term is) {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : f.body = Γ.body) (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    ∃ b', b' ∈ termSuccs term ∧ s'.stack = { f with bb := b', stmt := 0 } :: rest ∧
      s'.mem = s.mem := by
  have hsucc : ∀ {d : Operand} {cs : List (Nat × BasicBlock)} {ow : BasicBlock} (x : Nat),
      caseTarget cs ow x ∈ termSuccs (.switchInt d cs ow) := by
    intro d cs ow x
    unfold caseTarget
    simp only [termSuccs, List.mem_append, List.mem_map, List.mem_singleton]
    cases hf : cs.find? (·.1 == x) with
    | none => exact .inr rfl
    | some y => exact .inl ⟨y, List.mem_of_find?_eq_some hf, rfl⟩
  cases hl
  case chain hd hty hn hsl hsize hoff hok =>
    obtain ⟨_, _, _, bits, _, _, _, _, rfl⟩ := switchInt_inv hs hd h
    exact ⟨_, hsucc bits, rfl, rfl⟩
  case dense hd hty hn hsl hsize hoff hden ha hok =>
    obtain ⟨_, _, _, bits, _, _, _, _, rfl⟩ := switchInt_inv hs hd h
    exact ⟨_, hsucc bits, rfl, rfl⟩
  case chainF hd hta hpath hn hsa hin hok =>
    rw [← hbody] at hta
    obtain ⟨_, _, bits, _, _, _, rfl⟩ := switchInt_inv_field hs hd hta hpath h
    exact ⟨_, hsucc bits, rfl, rfl⟩
  case denseF hd hta hpath hn hsa hin hden ha hok =>
    rw [← hbody] at hta
    obtain ⟨_, _, bits, _, _, _, rfl⟩ := switchInt_inv_field hs hd hta hpath h
    exact ⟨_, hsucc bits, rfl, rfl⟩

end Ryo.Proofs.Lower
