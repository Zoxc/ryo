/-
Ryo.Proofs.OpFacts — `Shapes.OpFacts` from `opSem` and the opcode tables (aot.md §C2, toward
`decode_sound`).

- `kindSem_out`: a successful `kindSem k` keeps the number of allocations (each store is an L0
  `store`: `Memory.store_agree`) and gives the control of its kind (`KindCtl`: a `bool` for
  `br`/`br_cmp`/`br_cmp_imm`, anything for the switches, `next` otherwise).
- `commit_keeps`, `opSem_out`: `commit`'s frame writes keep the escaped objects and the number
  of allocations, so `opSem` does (`opSem_escWF`: it keeps `EscWF`).
- `kindFits`, `ctlTableOk`, `opFacts_of`: an opcode whose handler kind fits its shape (no
  branch or switch kind for `op`/`lpad`, a branch kind for `br`) has `OpFacts`;
  `RyoProofs/OpFacts.lean` checks the table (`ctlTableOk_all`) and gives `opFacts`.
-/
import Ryo.Proofs.Shapes
import Ryo.Spec.Theorems.Memory

namespace Ryo.Proofs.OpFacts

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.Handlers Ryo.Proofs.Scope

/-- The control a handler of kind `k` gives. -/
def KindCtl : HandlerKind → Control → Prop
  | .br | .br_cmp | .br_cmp_imm => fun c => ∃ b, c = .branch b
  | .switch_dense | .switch_sparse => fun _ => True
  | _ => fun c => c = .next

theorem store_size {st : OpSem.State} {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte}
    {al : Align} (h : st.store m p bs al = .ok m') : m'.allocs.size = m.allocs.size := by
  unfold OpSem.State.store liftOutcome at h
  split at h
  · cases h; exact (Ryo.Spec.Theorems.Memory.store_agree (by assumption)).1.symm
  all_goals cases h

theorem kindSem_out {k : HandlerKind} {ps : List String} {e : Env} {o : Out}
    (h : kindSem k ps e = .ok o) :
    o.mem.allocs.size = e.st.mem.allocs.size ∧ KindCtl k o.ctl := by
  cases k <;> simp only [kindSem, bind, Except.bind, pure, Except.pure] at h <;>
    repeat' (first | (simp only [reduceCtorEq] at h; done) | (simp [illFormed, ub] at h; done) | split at h)
  all_goals
    injection h with h
    subst h
    exact ⟨by first | rfl | exact store_size (by assumption),
      by first | rfl | exact ⟨_, rfl⟩ | trivial⟩


/-! ### `opSem` -/

theorem writeFrame_keeps {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') :
    st'.escaped = st.escaped ∧ st'.mem.allocs.size = st.mem.allocs.size := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    exact ⟨rfl, (Inline.writeEscaped_spec hm).1⟩

theorem commitOne_keeps {fp : Footprint} {val : String → Option Val} {st st' : OpSem.State}
    {w : String × List AbstractByte} (h : commitOne fp val st w = .ok st') :
    st'.escaped = st.escaped ∧ st'.mem.allocs.size = st.mem.allocs.size := by
  unfold commitOne at h
  split at h
  · simp [illFormed] at h
  split at h
  · simp [illFormed] at h
  split at h
  · exact writeFrame_keeps h
  · simp [illFormed] at h

theorem commit_keeps {fp : Footprint} {val : String → Option Val} :
    ∀ (ws : List (String × List AbstractByte)) {st st' : OpSem.State},
      commit fp val st ws = .ok st' →
        st'.escaped = st.escaped ∧ st'.mem.allocs.size = st.mem.allocs.size
  | [], st, st', h => by cases h; exact ⟨rfl, rfl⟩
  | w :: ws, st, st', h => by
    simp only [commit, List.foldlM_cons, bind, Except.bind] at h
    cases h1 : commitOne fp val st w with
    | error e => simp [h1] at h
    | ok st1 =>
      simp only [h1] at h
      obtain ⟨e1, s1⟩ := commitOne_keeps h1
      obtain ⟨e2, s2⟩ := commit_keeps ws h
      exact ⟨e2.trans e1, s2.trans s1⟩

/-- A successful `opSem` runs a handler whose kind gives its control (`KindCtl`), keeps the
escaped objects and the number of allocations. -/
theorem opSem_out {op : Full.Opcode} {ops : Operands} {st st' : OpSem.State} {ch : OpSem.Choice}
    {ctl : Control} (h : opSem op ops st ch = .ok (ctl, st')) :
    (∃ hi, op.handler? = some hi ∧ KindCtl hi.kind ctl) ∧ st'.escaped = st.escaped ∧
      st'.mem.allocs.size = st.mem.allocs.size := by
  unfold opSem at h
  simp only [bind, Except.bind] at h
  cases hp : prepare op ops with
  | error e => simp [hp] at h
  | ok r =>
    obtain ⟨hi, fp, val⟩ := r
    have hh : op.handler? = some hi := by
      unfold prepare at hp
      cases hh : op.handler? with
      | none => simp [hh] at hp
      | some hi' =>
        cases hf : footprint op with
        | none => simp [hh, hf] at hp
        | some fp' =>
          simp only [hh, hf] at hp
          split at hp
          · cases hp
          split at hp
          · cases hp
          simp only [pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at hp
          rw [hp.1]
    simp only [hp] at h
    cases hr : readAll fp val st with
    | error e => simp [hr] at h
    | ok reads =>
      simp only [hr] at h
      cases hk : kindSem hi.kind hi.params (mkEnv reads val st ch) with
      | error e => simp [hk] at h
      | ok o =>
        simp only [hk] at h
        cases hc : commit fp val { st with mem := o.mem } o.writes with
        | error e => simp [hc] at h
        | ok st1 =>
          simp only [hc, pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          obtain ⟨s1, c1⟩ := kindSem_out hk
          obtain ⟨e2, s2⟩ := commit_keeps _ hc
          exact ⟨⟨hi, hh, c1⟩, e2, s2.trans s1⟩

/-- `opSem` keeps `EscWF`. -/
theorem opSem_escWF {op : Full.Opcode} {ops : Operands} {st st' : OpSem.State} {ch : OpSem.Choice}
    {ctl : Control} (h : opSem op ops st ch = .ok (ctl, st')) (hw : EscWF st) : EscWF st' := by
  obtain ⟨-, he, hs⟩ := opSem_out h
  refine ⟨fun e h1 => ?_, fun e h1 e' h2 hid => ?_⟩
  · rw [he] at h1; rw [hs]; exact hw.idLt e h1
  · rw [he] at h1 h2; exact hw.idInj e h1 e' h2 hid

/-! ### Control by shape -/

def isBranch : HandlerKind → Bool
  | .br | .br_cmp | .br_cmp_imm => true
  | _ => false

def isSwitch : HandlerKind → Bool
  | .switch_dense | .switch_sparse => true
  | _ => false

/-- Does a handler of kind `k` give the control a shape `sh` needs (`CtlFits`)? -/
def kindFits (sh : Shape) (k : HandlerKind) : Bool :=
  match sh with
  | .op | .lpad => !isBranch k && !isSwitch k
  | .br => isBranch k
  | _ => true

/-- The table fact: every opcode's handler kind fits its shape (`ctlTableOk_all`). -/
def ctlTableOk (f : Full.Opcode) : Bool :=
  match f.handler? with
  | some hi => kindFits f.info.shape hi.kind
  | none => true

theorem kindCtl_spec {k : HandlerKind} {c : Control} (h : KindCtl k c) :
    (isBranch k = false → isSwitch k = false → c = .next) ∧
      (isBranch k = true → ∃ b, c = .branch b) := by
  cases k <;> simp_all [KindCtl, isBranch, isSwitch]

theorem ctlFits_of {sh : Shape} {k : HandlerKind} {c : Control} (hf : kindFits sh k = true)
    (h : KindCtl k c) : Shapes.CtlFits sh c := by
  obtain ⟨h1, h2⟩ := kindCtl_spec h
  refine ⟨fun hs => ?_, fun hs => ?_⟩
  · rcases hs with rfl | rfl <;> simp only [kindFits, Bool.and_eq_true, Bool.not_eq_true'] at hf <;>
      exact h1 hf.1 hf.2
  · subst hs; exact h2 hf

/-- `OpFacts` for an opcode the table accepts. -/
theorem opFacts_of {op : Full.Opcode} (ht : ctlTableOk op = true) : Shapes.OpFacts op where
  ctl _ _ _ _ _ h := by
    obtain ⟨⟨hi, hh, hc⟩, -⟩ := opSem_out h
    unfold ctlTableOk at ht
    rw [hh] at ht
    exact ctlFits_of ht hc
  escWF _ _ _ _ _ h := opSem_escWF h

end Ryo.Proofs.OpFacts
