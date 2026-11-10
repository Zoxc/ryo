/-
Ryo.Proofs.Lower.SimTermMore — the simulation of `LowerTermMore` (`Check/Lower/TermMore.lean`,
M5b): `Unreachable`, `UnwindResume` and `Assert`, from `FnRel` at the terminator's first R
index (`TermAt`, as `SimTerm.lean`'s rules; only `TermAt.head`/`tail`/`pe` and `goto_run` are
used of it).

- `unreachable_no_step`: L0's step at `Unreachable` is UB, never a successful step, so the
  function simulation closes that case by `absurd` and needs nothing of R.
- `sim_resume`: L0 unwinds out of the function (`resume_inv`: the frame's payload `p`, the
  frame popped; at the bottom continuation the run ends with `Final.unwound p`). R's `resume x`
  reads the exception object from slot `x` and, its cleanup entry continuing (`contAt`), ends
  the function unwinding with it (`stepView_resume`). The outcome (`ResumeOut`) relates the two
  under `ExcAt`: L0's payload is `PtrInj`-related to the pointer in R's slot `x`. That is the
  landing pads' invariant (they store the exception object there), M5c's with calls: it is a
  premise of the outcome, not derived. Without it, `resume_no_step` covers a frame that is not
  unwinding (L0's `resume` is then ill-formed).
- `sim_assert` (`assert`): L0 loads the `bool` condition, R branches on its byte
  (`br_bool_step`, as `sim_switchBool`). Equal to `expected` both reach `target`'s start
  (`JumpOut`, the shape `fn_step_sim_ret` uses after `term_nextX`); else L0 calls the panic
  function (`assertPanic`) and R falls through to the panic call's code (`AssertFails`: R one
  step on, state unchanged, `FnRel` at the terminator's liveness, `TermAt` of the rest, L0's
  `assertPanic` run): the simulation stops there, for M5c to extend with the call.
- `sim_assertField` (`assertField`): the same on a `bool` field of a local, read through
  `runOn_evalOperand_field` (L0) and `readLocal_sub_inj` (R), the branch by `br_read_step`.
- `sim_assertKnown`/`sim_assertKnownFail`: a constant condition (`assert_const_inv`), a goto
  (`goto_run`) or only the panic call (`AssertFails` with no R step).
- `sim_termMore`: the dispatch (`TermMoreOut`).

The trap instructions themselves need no `PlainView` here (only the assert's `br` does).
-/
import Ryo.Proofs.Lower.SimCmp
import Ryo.Proofs.Lower.SimField
import Ryo.Check.Lower.TermMore

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-! ### L0's side -/

theorem unreachable_no_step {o : Spec.Oracle} {s s' : Spec.State} :
    runOn (evalTerminator .unreachable) o s ≠ (.ok (), s') := by
  intro h
  have e : runOn (evalTerminator .unreachable) o s =
      (.error (.ub "reached unreachable code"), s) := rfl
  rw [e] at h
  exact prod_err_ok h

/-- `UnwindResume`: the frame unwinds with payload `p`, popped (`popFrame`); at the bottom
continuation the run ends with `Final.unwound p`.

Proof: as `return_inv`: `evalTerminator .unwindResume` is `curFrame` and a match on its
`unwinding` (`rfl`); `none` is `throwIllFormed`; `some p` is `unwindOut p`, `popFrame` then
`contUnwind`, whose `bottom` case sets `final` (`rfl`). -/
theorem resume_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (h : runOn (evalTerminator .unwindResume) o s = (.ok (), s')) :
    ∃ p s2, f.unwinding = some p ∧ runOn popFrame o s = (.ok f, s2) ∧
      (f.cont = .bottom → s' = { s2 with final := some (.unwound p) }) := by
  have e : evalTerminator .unwindResume = (SemM.curFrame >>= fun g => match g.unwinding with
      | some p => unwindOut p
      | none => throwIllFormed "UnwindResume outside a cleanup block") := rfl
  rw [e, runOn_bind, runOn_curFrame hs] at h
  change runOn (match f.unwinding with
      | some p => unwindOut p
      | none => throwIllFormed "UnwindResume outside a cleanup block") o s = (.ok (), s') at h
  rcases hu : f.unwinding with _ | p
  · simp only [hu, runOn_throwIllFormed] at h
    exact (prod_err_ok h).elim
  · simp only [hu] at h
    have e2 : unwindOut p = (popFrame >>= fun g => contUnwind g.cont p) := rfl
    rw [e2] at h
    obtain ⟨g, s2, h5, h6⟩ := runOn_bind_ok h
    have hg : g = f := by
      have h5' := h5
      unfold popFrame at h5'
      rw [runOn_bind, runOn_curFrame hs] at h5'
      obtain ⟨_, s4, -, h7⟩ := runOn_bind_ok h5'
      obtain ⟨_, s5, -, h8⟩ := runOn_bind_ok h7
      exact (prod_ok_inj h8).1.symm
    rw [hg] at h5 h6
    refine ⟨p, s2, by first | rfl | exact hu, h5, fun hc => ?_⟩
    rw [hc] at h6
    have e3 : runOn (contUnwind .bottom p) o s2 =
        (.ok (), { s2 with final := some (.unwound p) }) := rfl
    rw [e3] at h6
    exact (prod_ok_inj h6).2.symm

/-- A frame that is not unwinding has no successful `UnwindResume` step. -/
theorem resume_no_step {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hu : f.unwinding = none) :
    runOn (evalTerminator .unwindResume) o s ≠ (.ok (), s') := by
  intro h
  obtain ⟨p, s2, hp, -⟩ := resume_inv hs h
  rw [hu] at hp
  cases hp

/-- A failed `Assert`'s call of its panic function (`evalTerminator`'s else branch): where the
simulation stops, for M5c. -/
def assertPanic (msg : AssertMessage) (unwind : UnwindAction) : SemM Unit := do
  let args ← msg.args.mapM fun o => do
    let (v, ty) ← evalOperand o
    pure (⟨v, ty, none⟩ : ArgVal)
  let loc ← evalCallerLoc msg.callerLocation
  callInstance msg.panicFn args none (.caller none unwind []) loc none

/-- `Assert` on the condition's value. -/
def assertSel (v : Value) (expected : Bool) (target : BasicBlock) (msg : AssertMessage)
    (unwind : UnwindAction) : SemM Unit :=
  match v with
  | .bool b => if b == expected then SemM.jumpTo target else assertPanic msg unwind
  | _ => throwIllFormed "Assert on a non-bool"

theorem assert_eq (cond : Operand) (expected : Bool) (msg : AssertMessage) (target : BasicBlock)
    (unwind : UnwindAction) :
    evalTerminator (.assert cond expected msg target unwind) =
      (evalOperand cond >>= fun x => assertSel x.1 expected target msg unwind) := rfl

/-- `Assert` on a `bool`: to `target` when it is `expected`, else the panic call. -/
theorem assert_bool_step {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {b expected : Bool}
    {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction}
    (h : runOn (assertSel (.bool b) expected target msg unwind) o s = (.ok (), s')) :
    (b = expected ∧ s' = { s with stack := { f with bb := target, stmt := 0 } :: rest }) ∨
      (b ≠ expected ∧ runOn (assertPanic msg unwind) o s = (.ok (), s')) := by
  have e : assertSel (.bool b) expected target msg unwind =
      if b == expected then SemM.jumpTo target else assertPanic msg unwind := rfl
  rw [e] at h
  by_cases hb : b = expected
  · have hc : (b == expected) = true := beq_iff_eq.mpr hb
    rw [hc, if_pos (rfl : true = true), runOn_jumpTo hs] at h
    exact .inl ⟨hb, (prod_ok_inj h).2.symm⟩
  · have hc : (b == expected) = false := beq_eq_false_iff_ne.mpr hb
    rw [hc, if_neg Bool.false_ne_true] at h
    exact .inr ⟨hb, h⟩

/-- `Assert` on a whole local: it loads at its type, then `assertSel`. -/
theorem assert_local_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Operand} {l : Local}
    (hl : d.local? = some l) {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
    {unwind : UnwindAction}
    (h : runOn (evalTerminator (.assert d expected msg target unwind)) o s = (.ok (), s')) :
    ∃ p ty v, f.locals[l]? = some (some p) ∧ f.body.locals[l]? = some ty ∧
      typedLoad s.mem p ty .one = .ok v ∧
      runOn (assertSel v expected target msg unwind) o s = (.ok (), s') := by
  rw [assert_eq] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨p, ty, v, hp, hty, hv, hx, hs1⟩ := runOn_evalOperand_local hs hl h1
  subst x s1
  exact ⟨p, ty, v, hp, hty, hv, h2⟩

/-- `Assert` on a `bool` constant: its value is `bits % 256 == 1` (`runOn_evalOperand_const_cmp`).
-/
theorem assert_const_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {bits : Nat} {expected : Bool}
    {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction}
    (h : runOn (evalTerminator (.assert (.const (.scalar bits) .bool) expected msg target unwind))
      o s = (.ok (), s')) :
    ((bits % 256 == 1) = expected ∧
        s' = { s with stack := { f with bb := target, stmt := 0 } :: rest }) ∨
      ((bits % 256 == 1) ≠ expected ∧ runOn (assertPanic msg unwind) o s = (.ok (), s')) := by
  rw [assert_eq] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨hr, -, hs1⟩ := runOn_evalOperand_const_cmp (n := 1) (sg := false) (tc := .bool) rfl h1
  subst x s1
  have h3 : runOn (assertSel (.bool (bits % 2 ^ (8 * 1) == 1)) expected target msg unwind) o s =
      (.ok (), s') := h2
  have e256 : (2 : Nat) ^ (8 * 1) = 256 := rfl
  rw [e256] at h3
  exact assert_bool_step hs h3

/-! ### R's side -/

/-- R's `br` on a `bool` local's slot (`brOps`, as in `sim_switchBool`): L0's value is `.bool b`
and R branches on `b`. -/
theorem br_bool_step {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {f : Spec.Frame} {m0 : Memory} (hmode : c.mode = Γ.mode)
    (hρ : c.ρ = Γ.ρ) {next : Nat} {l : Local} {sl : LocalSlot} {p : ThinPointer} {ibr : Insn}
    {tl : List Insn} {neg : Bool} {t : Nat}
    (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = 1) (hoff : offOk sl.off = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (sl.off, neg, t)) (hat : TermAt c s1 next (ibr :: tl))
    (hpl : PlainView c.mode c.ρ ibr) (hrel : FnRel Γ.toStmtCtx ι live f m0 s1)
    (hp : f.locals[l]? = some (some p)) (hlive : live l = true) {v : Value}
    (hload : typedLoad m0 p .bool .one = .ok v) :
    ∃ b, v = .bool b ∧
      R.step c s1 ch = .ok (.step { s1 with pc := if b != neg then t else s1.pc + 1 }) := by
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
  have hrf' : s1.st.readFrame sl.off 1 = .ok bs1 := by rw [← hsize]; exact hrf
  have hop : OpSem.opSem vw.op vw.ops s1.st ch = .ok (.branch (leDecode [dd] != 0), s1.st) := by
    rw [hops]; exact opSem_br_fwd hh ho h1 h2 hrf' hasn
  obtain ⟨hi0, hs0⟩ := hat.head
  have hstep := step_branch hi0 hs0 hat.pe hpl hvw hctl hop
  obtain ⟨b, rfl, hcb⟩ : ∃ b, v = .bool b ∧ (leDecode [dd] != 0) = b := by
    rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨false, rfl, by decide⟩
    · exact ⟨true, rfl, by decide⟩
  rw [hcb] at hstep
  exact ⟨b, rfl, hstep⟩

/-- `evalOperand` of a field place (`fieldPath`): a load at the local's pointer plus the
offset, the state unchanged (as `field_mem`'s first half). -/
theorem runOn_evalOperand_field {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Operand} {a : Local}
    {projs : List ProjElem} {ta ty : Spec.Ty} {off : Nat}
    (hd : operandPlace? d = some ⟨a, projs⟩) (hta : f.body.locals[a]? = some ta)
    (hpath : fieldPath ta projs = some (off, ty)) {r : Value × Spec.Ty}
    (h : runOn (evalOperand d) o s = (.ok r, s1)) :
    ∃ pa v, f.locals[a]? = some (some pa) ∧
      typedLoad s.mem ⟨pa.addr + off, pa.prov⟩ ty .one = .ok v ∧ r = (v, ty) ∧ s1 = s := by
  have e : evalOperand d = (evalPlace ⟨a, projs⟩ >>= fun x => match x with
      | (pl, ty) => placeLoad pl ty >>= fun v => pure (v, ty)) := by
    cases d with
    | copy p => cases hd; rfl
    | move p => cases hd; rfl
    | _ => cases hd
  rw [e] at h
  obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pa, hpa, rfl, hs2⟩ := runOn_evalPlace_fields hs hta hpath h1
  have h2' : runOn (placeLoad ⟨(⟨pa.addr + off, pa.prov⟩ : ThinPointer).widen, true⟩ ty >>=
      fun v => pure (v, ty)) o s2 = (.ok r, s1) := h2
  rw [hs2] at h2'
  obtain ⟨v, s3, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨hv, hs3⟩ := runOn_placeLoad_ok h3
  obtain ⟨hrv, hs1⟩ := prod_ok_inj h4
  exact ⟨pa, v, hpa, hv, hrv.symm, hs1.symm.trans hs3⟩

theorem operandPlace?_base_mem {d : Operand} {p : MPlace} (h : operandPlace? d = some p) :
    p.base ∈ operandLocals d := by
  cases d <;> simp [operandPlace?] at h <;> subst h <;> simp [operandLocals, placeLocals]

/-- R's `br` on slot `x` of a `bool` L0 loads from `q`, whose byte R's slot relates to
(`hread`): L0's value is `.bool b` and R branches on `b` (`br_bool_step` with the read
abstracted). -/
theorem br_read_step {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {x : Int} {ibr : Insn}
    {tl : List Insn} {neg : Bool} {t : Nat} (hoff : offOk x = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (x, neg, t)) (hat : TermAt c s1 next (ibr :: tl))
    (hpl : PlainView c.mode c.ρ ibr) {m0 : Memory} {q : ThinPointer} {v : Value}
    (hload : typedLoad m0 q .bool .one = .ok v)
    (hread : ∀ bs0, m0.load q 1 .one = .ok bs0 →
      ∃ bs1, s1.st.readFrame x 1 = .ok bs1 ∧ BytesInj ι bs0 bs1) :
    ∃ b, v = .bool b ∧
      R.step c s1 ch = .ok (.step { s1 with pc := if b != neg then t else s1.pc + 1 }) := by
  obtain ⟨dd, pr, hld, hcase⟩ := typedLoad_bool hload
  obtain ⟨bs1, hrf, hbi⟩ := hread _ hld
  have hdec0 : decodeBits [AbstractByte.init dd pr] = some (leDecode [dd]) := rfl
  have hdec1 := decodeBits_inj hbi hdec0
  have hasn : OpSem.asNat bs1 = .ok (leDecode [dd]) := by
    unfold OpSem.asNat; rw [hdec1]; rfl
  obtain ⟨vw, r, hvw, hh, hops, hctl, ho⟩ := brOps_spec hbr
  rw [← hmode, ← hρ] at hvw
  obtain ⟨h1, h2⟩ := offOk_spec hoff
  have hop : OpSem.opSem vw.op vw.ops s1.st ch = .ok (.branch (leDecode [dd] != 0), s1.st) := by
    rw [hops]; exact opSem_br_fwd hh ho h1 h2 hrf hasn
  obtain ⟨hi0, hs0⟩ := hat.head
  have hstep := step_branch hi0 hs0 hat.pe hpl hvw hctl hop
  obtain ⟨b, rfl, hcb⟩ : ∃ b, v = .bool b ∧ (leDecode [dd] != 0) = b := by
    rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨false, rfl, by decide⟩
    · exact ⟨true, rfl, by decide⟩
  rw [hcb] at hstep
  exact ⟨b, rfl, hstep⟩

set_option maxRecDepth 8000 in
/-- `resume x` with exception object `exc` in slot `x` and a continuing cleanup entry: the
function ends unwinding with `exc`.

Proof: unfold `stepView`: the view, its control, `v.op == .resume`, the operand pattern; then
`readFrame`, `asPtr` (`decodePtr`) and `unwindAt` (`hcl`). -/
theorem stepView_resume {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {x : Int} {bs : List AbstractByte} {exc : ThinPointer} {b : Bool}
    (hv : view c.mode c.ρ i = some v) (hop : v.op = .resume) (hctl : v.ctl.isSome = true)
    (hops : v.ops = [.slot x]) (hr : s.st.readFrame x 8 = .ok bs) (hd : decodePtr bs = some exc)
    (hcl : c.cleanupAt s.pc = some (none, b)) :
    stepView c s i ch = .ok (.done (R.exit s (.unwind exc))) := by
  obtain ⟨t, ht⟩ := Option.isSome_iff_exists.mp hctl
  have hap : OpSem.asPtr bs = .ok exc := by unfold OpSem.asPtr; rw [hd]; rfl
  have hu : unwindAt c s exc = .ok (.done (R.exit s (.unwind exc))) := by
    unfold unwindAt; simp only [hcl]; rfl
  have hre : (v.op == Full.Opcode.resume) = true := by simp [hop]
  unfold stepView
  simp only [hv, ht, hre, ↓reduceIte, hops, bind, Except.bind, hr, hap, hu, pure, Except.pure]

theorem resumeOps_spec {Γ : StmtCtx} {i : Insn} {x : Int} (h : resumeOps Γ i = some x) :
    ∃ v, view Γ.mode Γ.ρ i = some v ∧ v.op = .resume ∧ v.ctl.isSome = true ∧
      v.ops = [.slot x] := by
  unfold resumeOps at h
  split at h
  next v hv =>
    split at h
    next hc =>
      split at h
      next x' hx =>
        cases h
        simp only [Bool.and_eq_true, beq_iff_eq] at hc
        exact ⟨v, hv, hc.1, hc.2, hx⟩
      next => cases h
    next => cases h
  next => cases h

theorem cleanupAt_of_contAt {c : Code} {k : Nat} (h : contAt c.d k = true) :
    ∃ b, c.cleanupAt k = some (none, b) := by
  unfold contAt at h
  unfold Code.cleanupAt
  split at h
  next b hb => exact ⟨b, hb⟩
  next => cases h

/-! ### The outcomes -/

/-- R reaches, frame and memory unchanged, the start of L0's target `b'` (a successor of
`term`), with `FnRel` there at `live'`: what `fn_step_sim_ret` uses of `sim_term`/`sim_switch`
together with `term_nextX`. -/
def JumpOut (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (term : Terminator) (s s' : Spec.State) (f : Spec.Frame) (rest : List Spec.Frame)
    (s1 : RState) : Prop :=
  ∃ s1' b', StepsTo c ch s1 s1' ∧ b' ∈ termSuccs term ∧
    s'.stack = { f with bb := b', stmt := 0 } :: rest ∧ s'.mem = s.mem ∧
    blockStart Γ b' = some s1'.pc ∧
    FnRel Γ.toStmtCtx ι live' { f with bb := b', stmt := 0 } s'.mem s1'

/-- A failed `Assert` (see the module comment): R at the panic call's code `tl` (`TermAt`), its
state and frame as before and `FnRel` at the terminator's liveness `live`; L0 runs
`assertPanic` from `s` to `s'`. M5c continues from here. -/
def AssertFails (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj) (live : Local → Bool)
    (o : Spec.Oracle) (s s' : Spec.State) (f : Spec.Frame) (s1 : RState) (next : Nat)
    (msg : AssertMessage) (unwind : UnwindAction) : Prop :=
  ∃ s1' tl, StepsTo c ch s1 s1' ∧ s1'.st = s1.st ∧ s1'.fp = s1.fp ∧ TermAt c s1' next tl ∧
    FnRel Γ.toStmtCtx ι live f s.mem s1' ∧ runOn (assertPanic msg unwind) o s = (.ok (), s')

/-- M5c's landing-pad invariant for `resume x`: while L0's frame unwinds with payload `p`, R's
slot `x` holds a pointer `PtrInj`-related to it. -/
def ExcAt (ι : Inj) (f : Spec.Frame) (st : OpSem.State) (x : Int) : Prop :=
  ∀ p, f.unwinding = some p → ∃ bs exc, st.readFrame x 8 = .ok bs ∧ decodePtr bs = some exc ∧
    PtrInj ι p exc

/-- L0 unwinds out of the function with its payload `p`; under `ExcAt`, so does R, with a
related exception object (see the module comment). -/
def ResumeOut (c : Code) (ch : OpSem.Choice) (ι : Inj) (s' : Spec.State) (f : Spec.Frame)
    (s1 : RState) (x : Int) : Prop :=
  ∃ p, f.unwinding = some p ∧ s'.final = some (.unwound p) ∧
    (ExcAt ι f s1.st x →
      ∃ exc, R.step c s1 ch = .ok (.done (R.exit s1 (.unwind exc))) ∧ PtrInj ι p exc)

/-! ### The rules -/

theorem sim_resume {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    (hs : s.stack = f :: rest) (hcont : f.cont = .bottom) (hmode : c.mode = Γ.mode)
    (hρ : c.ρ = Γ.ρ) {next : Nat} {i : Insn} {x : Int}
    (hrule : resumeOps Γ.toStmtCtx i = some x) (hat : TermAt c s1 next [i])
    (hcl : ∃ b, c.cleanupAt s1.pc = some (none, b))
    (h : runOn (evalTerminator .unwindResume) o s = (.ok (), s')) :
    ResumeOut c ch ι s' f s1 x := by
  obtain ⟨p, s2, hu, -, hfin⟩ := resume_inv hs h
  refine ⟨p, hu, by simp only [hfin hcont], fun hexc => ?_⟩
  obtain ⟨bs, exc, hr, hd, hpi⟩ := hexc p hu
  refine ⟨exc, ?_, hpi⟩
  obtain ⟨hi, hs0⟩ := hat.head
  obtain ⟨v, hv, hop, hctl, hops⟩ := resumeOps_spec hrule
  rw [← hmode, ← hρ] at hv
  obtain ⟨b, hcl⟩ := hcl
  have hnat : ViewShape i := by
    intro op ops he g hg
    subst he
    exact shapes_of_opShape (view_native_opShape hv hg hctl)
  rw [step_eq_stepBody_nil hi hs0, stepBody_view hnat ⟨v, hv⟩]
  exact stepView_resume hv hop hctl hops hr hd hcl

theorem sim_assert {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
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
    (hat : TermAt c s1 next (ibr :: tl)) (hpl : PlainView c.mode c.ρ ibr)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.assert d expected msg target unwind)) o s = (.ok (), s')) :
    JumpOut Γ c ch ι live' (.assert d expected msg target unwind) s s' f rest s1 ∨
      AssertFails Γ c ch ι live o s s' f s1 next msg unwind := by
  subst hsv hneg
  obtain ⟨p, ty, v, hp, hty', hload, h2⟩ := assert_local_inv hs hd h
  rw [← hbody, hty] at hty'
  obtain rfl := (Option.some.inj hty').symm
  obtain ⟨b, rfl, hstep⟩ :=
    br_bool_step (ch := ch) hmode hρ hsl hsize hoff hbr hat hpl hrel hp hlive hload
  rcases assert_bool_step hs h2 with ⟨he, hs'⟩ | ⟨hne, hpan⟩
  · have hc : (b != !expected) = true := by rw [he]; cases expected <;> rfl
    simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
    subst hs'
    exact .inl ⟨{ s1 with pc := t }, target, .cons hstep (.refl _), by simp [termSuccs], rfl,
      rfl, ht, (hrel.weaken hw).congr rfl rfl rfl rfl⟩
  · have hc : (b != !expected) = false := by
      revert hne; cases b <;> cases expected <;> decide
    simp only [hc, Bool.false_eq_true, if_false, ↓reduceIte] at hstep
    exact .inr ⟨{ s1 with pc := s1.pc + 1 }, tl, .cons hstep (.refl _), rfl, rfl, hat.tail,
      hrel.congr rfl rfl rfl rfl, hpan⟩

theorem sim_assertField {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat}
    {d : Operand} {a : Local} {projs : List ProjElem} {ta : Spec.Ty} {off : Nat}
    {expected : Bool} {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction}
    {sl : LocalSlot} {ibr : Insn} {tl : List Insn} {sv : Int} {neg : Bool} {t : Nat}
    (hd : operandPlace? d = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
    (hpath : fieldPath ta projs = some (off, .bool)) (hsl : Γ.slots[a]? = some sl)
    (hin : off + 1 ≤ sl.size) (hoff : offOk (sl.off + off) = true)
    (hbr : brOps Γ.toStmtCtx ibr = some (sv, neg, t)) (hsv : sv = sl.off + off)
    (hneg : neg = !expected) (ht : blockStart Γ target = some t)
    (hat : TermAt c s1 next (ibr :: tl)) (hpl : PlainView c.mode c.ρ ibr)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live a = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.assert d expected msg target unwind)) o s = (.ok (), s')) :
    JumpOut Γ c ch ι live' (.assert d expected msg target unwind) s s' f rest s1 ∨
      AssertFails Γ c ch ι live o s s' f s1 next msg unwind := by
  subst hsv hneg
  rw [assert_eq] at h
  obtain ⟨x, s1x, h1, h2⟩ := runOn_bind_ok h
  have hta' : f.body.locals[a]? = some ta := by rw [← hbody]; exact hta
  obtain ⟨pa, v, hpa, hload, hx, hs1⟩ := runOn_evalOperand_field hs hd hta' hpath h1
  subst x s1x
  have hr := hrel.opnd hpa hsl hlive
  obtain ⟨b, rfl, hstep⟩ := br_read_step (ch := ch) hmode hρ hoff hbr hat hpl hload
    (fun bs0 hl => readLocal_sub_inj hrel.frame.mem hr hin hl)
  rcases assert_bool_step hs h2 with ⟨he, hs'⟩ | ⟨hne, hpan⟩
  · have hc : (b != !expected) = true := by rw [he]; cases expected <;> rfl
    simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
    subst hs'
    exact .inl ⟨{ s1 with pc := t }, target, .cons hstep (.refl _), by simp [termSuccs], rfl,
      rfl, ht, (hrel.weaken hw).congr rfl rfl rfl rfl⟩
  · have hc : (b != !expected) = false := by
      revert hne; cases b <;> cases expected <;> decide
    simp only [hc, Bool.false_eq_true, if_false, ↓reduceIte] at hstep
    exact .inr ⟨{ s1 with pc := s1.pc + 1 }, tl, .cons hstep (.refl _), rfl, rfl, hat.tail,
      hrel.congr rfl rfl rfl rfl, hpan⟩

theorem sim_assertKnown {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {next : Nat} {bits : Nat}
    {expected : Bool} {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction}
    {is : List Insn} (hk : ((bits % 256 == 1) == expected) = true)
    (hg : gotoOk Γ next target is = true) (hat : TermAt c s1 next is)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator (.assert (.const (.scalar bits) .bool) expected msg target unwind))
      o s = (.ok (), s')) :
    JumpOut Γ c ch ι live' (.assert (.const (.scalar bits) .bool) expected msg target unwind)
      s s' f rest s1 := by
  rcases assert_const_inv hs h with ⟨-, hs'⟩ | ⟨hne, -⟩
  · obtain ⟨s2, hst, hb, hsst, hfp, -⟩ := goto_run (ch := ch) hg hat
    subst hs'
    exact ⟨s2, target, hst, by simp [termSuccs], rfl, rfl, hb,
      (hrel.weaken hw).congr rfl rfl hsst hfp⟩
  · exact absurd (beq_iff_eq.mp hk) hne

theorem sim_assertKnownFail {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice}
    {ι : Inj} {live : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {next : Nat} {bits : Nat}
    {expected : Bool} {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction}
    {is : List Insn} (hk : ((bits % 256 == 1) == expected) = false)
    (hat : TermAt c s1 next is) (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1)
    (h : runOn (evalTerminator (.assert (.const (.scalar bits) .bool) expected msg target unwind))
      o s = (.ok (), s')) :
    AssertFails Γ c ch ι live o s s' f s1 next msg unwind := by
  rcases assert_const_inv hs h with ⟨he, -⟩ | ⟨-, hpan⟩
  · rw [he, beq_self_eq_true] at hk
    cases hk
  · exact ⟨s1, is, .refl _, rfl, rfl, hat, hrel, hpan⟩

/-- `sim_termMore`'s conclusion: a jump (`JumpOut`), a failed assert (`AssertFails`) or an
unwind out of the function (`ResumeOut`). -/
def TermMoreOut (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj)
    (live live' : Local → Bool) (o : Spec.Oracle) (s s' : Spec.State) (f : Spec.Frame)
    (rest : List Spec.Frame) (s1 : RState) (next : Nat) (term : Terminator) : Prop :=
  JumpOut Γ c ch ι live' term s s' f rest s1 ∨
    (∃ d expected msg target unwind, term = .assert d expected msg target unwind ∧
      AssertFails Γ c ch ι live o s s' f s1 next msg unwind) ∨
    (∃ x, term = .unwindResume ∧ ResumeOut c ch ι s' f s1 x)

/-- The dispatch over `LowerTermMore`'s rules. `hres` is `resumesCheck`'s fact (the cleanup
entries of `resume`), `hlive` the liveness of an `Assert`'s condition local, `hcont` the frame's
bottom continuation (`MatchAt.cont`). -/
theorem sim_termMore {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hcont : f.cont = .bottom) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat}
    {term : Terminator} {is : List Insn} (hlow : LowerTermMore Γ next term is)
    (hat : TermAt c s1 next is) (hpl : ∀ i, is.head? = some i → PlainView c.mode c.ρ i)
    (hres : ∀ (k : Nat) i, c.d.insns[k]? = some i → isResume c.mode c.ρ i = true →
      contAt c.d k = true)
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1)
    (hlive : ∀ (d : Operand) e msg target unwind l, term = .assert d e msg target unwind →
      l ∈ operandLocals d → live l = true)
    (hw : ∀ l, live' l = true → live l = true)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    TermMoreOut Γ c ch ι live live' o s s' f rest s1 next term := by
  cases hlow
  case unreachable => exact absurd h unreachable_no_step
  case resume hr =>
    obtain ⟨hi, -⟩ := hat.head
    have hir := resumeOps_isResume hr
    rw [← hmode, ← hρ] at hir
    have hcl := cleanupAt_of_contAt (hres _ _ hi hir)
    exact .inr (.inr ⟨_, rfl, sim_resume hs hcont hmode hρ hr hat hcl h⟩)
  case assert hd hty hsl hsize hoff hbr hsv hneg ht =>
    rcases sim_assert (ch := ch) (live' := live') hs hbody hmode hρ hd hty hsl hsize hoff hbr hsv
        hneg ht hat (hpl _ rfl) hrel (hlive _ _ _ _ _ _ rfl (operand_local_mem hd)) hw h with
      hj | hf
    · exact .inl hj
    · exact .inr (.inl ⟨_, _, _, _, _, rfl, hf⟩)
  case assertField hd hta hpath hsl hin hoff hbr hsv hneg ht =>
    rcases sim_assertField (ch := ch) (live' := live') hs hbody hmode hρ hd hta hpath hsl hin hoff
        hbr hsv hneg ht hat (hpl _ rfl) hrel
        (hlive _ _ _ _ _ _ rfl (operandPlace?_base_mem hd)) hw h with hj | hf
    · exact .inl hj
    · exact .inr (.inl ⟨_, _, _, _, _, rfl, hf⟩)
  case assertKnown hk hg => exact .inl (sim_assertKnown hs hk hg hat hrel hw h)
  case assertKnownFail hk =>
    exact .inr (.inl ⟨_, _, _, _, _, rfl, sim_assertKnownFail hs hk hat hrel h⟩)

end Ryo.Proofs.Lower
