/-
Ryo.Proofs.Lower.StepTerm — R's `step` split at its scopes, and the terminator steps (M5a).

`step` first folds the scopes before the instruction (`applyScope`), then runs the
instruction on the result: `stepBody`, a copy of the rest of `step`, and `step_eq_stepBody`.
Scopes keep `pc` and `fp` (`scopes_pc`, `scopes_fp`), so ScopeRel's `escape_rel`/
`storageEnd_rel` apply to the folded state and the instruction lemmas below to the rest.

Instruction lemmas (outside PE): an operation through its view with any control
(`stepBody_of_opSem`: `Then.succ` picks the next index), its `br` and `switch` cases
(`stepBody_br`, `stepBody_switch`), `jmp` (`stepBody_jmp`), and `ret` (`stepBody_ret`: the
function ends with the return registers and the incoming bytes).
-/
import Ryo.Vm.R.Sem

namespace Ryo.Proofs.Lower

set_option maxRecDepth 8000

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.Vm.OpSem

/-- `step` after its scopes: instruction `i` on the state `s` the scopes gave. -/
def stepBody (c : Code) (s : RState) (i : Insn) (ch : OpSem.Choice) : M R.Out :=
  do
  let .native op ops := i | stepView c s i ch
  let some f := op.full | illFormed s!"{op.mnemonic} isn't a full opcode"
  match f.info.shape, ops with
  | .jmp, [.target t] => pure (.step { s with pc := t })
  | .arg, [.slot d, .imm r] =>
    let some a := Asm.ArgReg.of? r.toNat true | illFormed s!"arg register word {r.toNat}"
    let st ← s.st.writeFrame d.toInt ((s.args.get (.ofArgReg a)).take a.size)
    pure (.step { s with pc := s.pc + 1, st })
  | .ret, [.slot src, .imm k] =>
    let parts ← retRegs k.toNat true
    let regs ← parts.foldlM (init := ({} : Regs)) fun rs (p, r) => do
      pure (rs.set r (zext (← s.st.readFrame (src.toInt + p.off) p.size) r.width))
    let incoming ← s.st.readFrame 16 c.argSize
    pure (.done (exit s (.ret regs incoming)))
  | .call, [.slot _, fo, .imm k, .words ws] =>
    let _ ← retRegs k.toNat false
    let cal ← callee s.st f fo
    let regs ← argRegs s.st ws
    -- In PE's pad region the outgoing area is on the dispatcher's stack (the choice's `sp`),
    -- its bytes unknown here.
    let sp ← if c.inRegion s.pc then pure ch.sp else frameAddr s.fp (-(c.d.frameSize : Int))
    let stack ← if c.inRegion s.pc then pure (List.replicate (c.stackSize s.pc) .uninit)
      else s.st.readFrame (-(c.d.frameSize : Int)) (c.stackSize s.pc)
    let st ← match c.sretSize s.pc, Frame.sretDest ws with
      | some n, some dst => s.st.writeFrame dst.toInt (List.replicate n .uninit)
      | _, _ => pure s.st
    let s := { s with st }
    pure (.ext ⟨.call cal regs sp stack, s.world⟩ s)
  | .tailCall, [fo, .words ws] =>
    let cal ← callee s.st f fo
    let regs ← argRegs s.st ws
    let stack ← s.st.readFrame 16 (c.stackSize s.pc)
    pure (.done (exit s (.tailCall cal regs (s.fp + 16) stack)))
  | .island, [.sym isl, .words ws] =>
    pure (.ext ⟨.island isl (c.islandTemplate s.pc) s.fp (ws.map (·.toInt)) (c.lendsAt s.pc), s.world⟩ s)
  | .jmp, _ | .arg, _ | .ret, _ | .call, _ | .tailCall, _ | .island, _ =>
    illFormed s!"{op.mnemonic}'s operands"
  | _, _ => stepView c s i ch

/-- `step` is the scopes, then `stepBody` on their result. -/
theorem step_eq_stepBody {c : Code} {s s' : RState} {ch : OpSem.Choice} {i : Insn}
    (hi : c.d.insns[s.pc]? = some i)
    (hf : (c.scopesAt s.pc).foldlM applyScope s = .ok s') :
    step c s ch = stepBody c s' i ch := by
  unfold step stepBody
  simp only [hi]
  rw [hf]
  rfl

/-- One scope keeps `pc` and `fp`. -/
theorem applyScope_pc_fp {s s' : RState} {sc : Scope} (h : applyScope s sc = .ok s') :
    s'.pc = s.pc ∧ s'.fp = s.fp := by
  unfold applyScope at h
  split at h
  · unfold escape at h
    simp only [bind, Except.bind, pure, Except.pure] at h
    repeat' split at h
    all_goals first
      | (cases h; exact ⟨rfl, rfl⟩)
      | (injection h with h; subst h; exact ⟨rfl, rfl⟩)
      | (simp_all [illFormed, throw, throwThe, MonadExcept.throw, ])
  · unfold storageEnd at h
    simp only [bind, Except.bind, pure, Except.pure] at h
    split at h
    · cases h
    · cases h; exact ⟨rfl, rfl⟩
  · cases h; exact ⟨rfl, rfl⟩

/-- Folding scopes keeps `pc` and `fp`. -/
theorem scopes_pc_fp : ∀ {scs : List Scope} {s s' : RState},
    scs.foldlM applyScope s = .ok s' → s'.pc = s.pc ∧ s'.fp = s.fp
  | [], s, s', h => by
    simp only [List.foldlM_nil, pure, Except.pure, Except.ok.injEq] at h
    subst h; exact ⟨rfl, rfl⟩
  | sc :: scs, s, s', h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : applyScope s sc with
    | error e => rw [h1] at h; cases h
    | ok s1 =>
      rw [h1] at h
      obtain ⟨p1, f1⟩ := applyScope_pc_fp h1
      obtain ⟨p2, f2⟩ := scopes_pc_fp h
      exact ⟨p2.trans p1, f2.trans f1⟩

theorem scopes_pc {scs : List Scope} {s s' : RState}
    (h : scs.foldlM applyScope s = .ok s') : s'.pc = s.pc := (scopes_pc_fp h).1

theorem scopes_fp {scs : List Scope} {s s' : RState}
    (h : scs.foldlM applyScope s = .ok s') : s'.fp = s.fp := (scopes_pc_fp h).2

/-- No native shape `stepBody` handles itself. -/
def ViewShape (i : Insn) : Prop :=
  ∀ op ops, i = .native op ops → ∀ f, op.full = some f →
    f.info.shape ≠ .jmp ∧ f.info.shape ≠ .arg ∧ f.info.shape ≠ .ret ∧ f.info.shape ≠ .call ∧
    f.info.shape ≠ .tailCall ∧ f.info.shape ≠ .island

theorem stepBody_view {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn}
    (hnat : ViewShape i) (hv : ∃ v, view c.mode c.ρ i = some v) :
    stepBody c s i ch = stepView c s i ch := by
  cases i with
  | handler h args t => rfl
  | native op ops =>
    cases hf : op.full with
    | none =>
      obtain ⟨v, hv⟩ := hv
      simp [view, hf, bind, Option.bind] at hv
    | some f =>
      obtain ⟨n1, n2, n3, n4, n5, n6⟩ := hnat op ops rfl f hf
      unfold stepBody
      dsimp only
      rw [hf]
      cases hsh : f.info.shape <;>
        first
        | exact absurd hsh n1 | exact absurd hsh n2 | exact absurd hsh n3
        | exact absurd hsh n4 | exact absurd hsh n5 | exact absurd hsh n6
        | rfl | (simp only [hsh]) | (split <;> rfl)

/-- An operation through its view, outside PE: `opSem`'s control picks the next index. -/
theorem stepView_of_opSem {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {t : Then Nat} {ctl : OpSem.Control} {st' : OpSem.State} {pc' : Nat}
    (hv : view c.mode c.ρ i = some v) (hctl : v.ctl = some t)
    (hres : v.op ≠ .resume) (hun : v.op ≠ .unreachable) (hpe : c.mode.pe = false)
    (hop : OpSem.opSem v.op v.ops s.st ch = .ok (ctl, st'))
    (hsucc : t.succ s.pc ctl = some pc') :
    stepView c s i ch = .ok (.step { s with pc := pc', st := st' }) := by
  have h1 : (v.op == Full.Opcode.resume) = false := beq_eq_false_iff_ne.mpr hres
  have h2 : (v.op == Full.Opcode.unreachable) = false := beq_eq_false_iff_ne.mpr hun
  unfold stepView
  simp only [hv, hctl, h1, h2, Bool.false_eq_true, ite_false, hop, bind, Except.bind]
  cases i <;> simp [clearHome, hpe, hsucc, pure, Except.pure]

theorem stepBody_of_opSem {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {t : Then Nat} {ctl : OpSem.Control} {st' : OpSem.State} {pc' : Nat}
    (hnat : ViewShape i)
    (hv : view c.mode c.ρ i = some v) (hctl : v.ctl = some t)
    (hres : v.op ≠ .resume) (hun : v.op ≠ .unreachable) (hpe : c.mode.pe = false)
    (hop : OpSem.opSem v.op v.ops s.st ch = .ok (ctl, st'))
    (hsucc : t.succ s.pc ctl = some pc') :
    stepBody c s i ch = .ok (.step { s with pc := pc', st := st' }) := by
  rw [stepBody_view hnat ⟨v, hv⟩]
  exact stepView_of_opSem hv hctl hres hun hpe hop hsucc

/-- A conditional branch (`br`): to `x` when the result `b` differs from `neg`, else on. -/
theorem stepBody_br {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {neg b : Bool} {x : Nat} {st' : OpSem.State}
    (hnat : ViewShape i)
    (hv : view c.mode c.ρ i = some v) (hctl : v.ctl = some (.branch neg x))
    (hres : v.op ≠ .resume) (hun : v.op ≠ .unreachable) (hpe : c.mode.pe = false)
    (hop : OpSem.opSem v.op v.ops s.st ch = .ok (.branch b, st')) :
    stepBody c s i ch =
      .ok (.step { s with pc := if b != neg then x else s.pc + 1, st := st' }) :=
  stepBody_of_opSem hnat hv hctl hres hun hpe hop rfl

/-- A table jump (`switch`): to the table's entry `k`. -/
theorem stepBody_switch {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {ts : List Nat} {k pc' : Nat} {st' : OpSem.State}
    (hnat : ViewShape i)
    (hv : view c.mode c.ρ i = some v) (hctl : v.ctl = some (.table ts))
    (hres : v.op ≠ .resume) (hun : v.op ≠ .unreachable) (hpe : c.mode.pe = false)
    (hop : OpSem.opSem v.op v.ops s.st ch = .ok (.index k, st'))
    (hk : ts[k]? = some pc') :
    stepBody c s i ch = .ok (.step { s with pc := pc', st := st' }) :=
  stepBody_of_opSem hnat hv hctl hres hun hpe hop hk

/-- `jmp t`. -/
theorem stepBody_jmp {c : Code} {s : RState} {ch : OpSem.Choice} {op : Reduced.Opcode} {f : Full.Opcode}
    {t : Nat} (hf : op.full = some f) (hsh : f.info.shape = .jmp) :
    stepBody c s (.native op [.target t]) ch = .ok (.step { s with pc := t }) := by
  unfold stepBody
  dsimp only
  rw [hf]
  dsimp only
  rw [hsh]
  rfl

/-- `ret src, k`: the function ends with the return registers `regs` read from `src` and the
incoming argument bytes. -/
theorem stepBody_ret {c : Code} {s : RState} {ch : OpSem.Choice} {op : Reduced.Opcode} {f : Full.Opcode}
    {src : BitVec 32} {k : BitVec 64} {parts : List (Asm.RetPart × Reg)} {regs : Regs}
    {incoming : List AbstractByte}
    (hf : op.full = some f) (hsh : f.info.shape = .ret)
    (hparts : retRegs k.toNat true = .ok parts)
    (hregs : parts.foldlM (m := M) (init := ({} : Regs)) (fun rs (p, r) => do
      pure (rs.set r (zext (← s.st.readFrame (src.toInt + p.off) p.size) r.width))) = .ok regs)
    (hinc : s.st.readFrame 16 c.argSize = .ok incoming) :
    stepBody c s (.native op [.slot src, .imm k]) ch =
      .ok (.done (exit s (.ret regs incoming))) := by
  unfold stepBody
  dsimp only
  rw [hf]
  dsimp only
  rw [hsh]
  dsimp only
  simp only [hparts, bind, Except.bind]
  simp only [bind, Except.bind] at hregs
  rw [hregs]
  simp only [hinc, pure, Except.pure]

/-- With no scopes, `step` is `stepBody`. -/
theorem step_eq_stepBody_nil {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn}
    (hi : c.d.insns[s.pc]? = some i) (hsc : c.scopesAt s.pc = []) :
    step c s ch = stepBody c s i ch :=
  step_eq_stepBody hi (by rw [hsc]; rfl)

end Ryo.Proofs.Lower
