/-
Ryo.Proofs.Lower.SimProlog — the prologue's argument stores simulated (M5a, `LowerProlog`).

An `arg slot, a` steps to the next instruction with the register's low `a.size` bytes written to
the slot (`step_arg`); a prologue of such instructions on disjoint private slots runs to its end
with each slot holding its register's bytes and nothing else of the frame changed
(`prolog_run`). With the L0 side of call entry as a hypothesis (`ArgRel`: each input local's
allocation is private, live, at its slot, and its bytes refine the register's), every input
local is then related privately and live (`prolog_sim`).
-/
import Ryo.Check.Lower.Prolog
import Ryo.Proofs.Lower.StepTerm
import Ryo.Proofs.Lower.FrameRel

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-- R steps through `.step` outcomes, with one choice. -/
inductive StepsTo (c : Code) (ch : OpSem.Choice) : RState → RState → Prop where
  | refl (s : RState) : StepsTo c ch s s
  | cons {s s1 s2 : RState} : step c s ch = .ok (.step s1) → StepsTo c ch s1 s2 → StepsTo c ch s s2

/-- `arg off, a`: the register's low `a.size` bytes to `off`, then the next instruction. -/
theorem step_arg {c : Code} {s : RState} {ch : OpSem.Choice} {i : Insn} {off : Int}
    {a : Asm.ArgReg} (hi : c.d.insns[s.pc]? = some i) (hsc : c.scopesAt s.pc = [])
    (ha : argOps i = some (off, a)) {st' : OpSem.State}
    (hw : s.st.writeFrame off ((s.args.get (.ofArgReg a)).take a.size) = .ok st') :
    step c s ch = .ok (.step { s with pc := s.pc + 1, st := st' }) := by
  obtain ⟨op, f, d, w, rfl, hf, hsh, hd, hof⟩ := argOps_spec ha
  subst hd
  rw [step_eq_stepBody_nil hi hsc]
  unfold stepBody
  dsimp only
  rw [hf]
  dsimp only
  rw [hsh]
  dsimp only
  rw [hof]
  dsimp only
  simp only [hw, bind, Except.bind, pure, Except.pure]

/-- The bytes `arg` writes for input `p`. -/
def argBytes (args : Regs) (p : LocalSlot × Asm.ArgReg) : List AbstractByte :=
  (args.get (.ofArgReg p.2)).take p.2.size

theorem argBytes_length_le {args : Regs} {Γ : PrologCtx} {k : Nat} {i : Insn}
    {p : LocalSlot × Asm.ArgReg} (h : ArgOk Γ k i p.1 p.2) :
    (argBytes args p).length ≤ p.1.size := by
  unfold argBytes
  rw [h.2.2.2.1]
  exact List.length_take_le _ _

/-- Running the prologue: see the module comment. -/
theorem prolog_run {Γ : PrologCtx} {c : Code} {ch : OpSem.Choice} :
    ∀ {k : Nat} {is : List Insn} {ps : List (LocalSlot × Asm.ArgReg)}, ArgsOk Γ k is ps →
    ∀ (s : RState),
    (∀ j (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧ c.scopesAt (s.pc + j) = []) →
    (∀ p ∈ ps, ∀ j < p.1.size, s.st.escapedAt (p.1.off + j) = none) →
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      s'.st.mem = s.st.mem ∧ (∀ o, s'.st.escapedAt o = s.st.escapedAt o) ∧
      (∀ o, (∀ p ∈ ps, ¬ (p.1.off ≤ o ∧ o < p.1.off + p.1.size)) → s'.st.frame o = s.st.frame o) ∧
      (ps.Pairwise SlotDisj → ∀ p ∈ ps, ∀ j (hj : j < (argBytes s.args p).length),
        s'.st.frame (p.1.off + j) = (argBytes s.args p)[j])
  | _, _, _, .nil k, s, _, _ => by
    refine ⟨s, .refl s, by simp, rfl, rfl, rfl, fun _ => rfl, fun _ _ => rfl, ?_⟩
    intro _ p hp
    simp at hp
  | _, _, _, .cons (k := k) (i := i) (is := is) (p := p) (ps := ps) hok hrest, s, hcode, hpriv => by
    have hlen := argBytes_length_le (args := s.args) hok
    have hpw : ∀ j < (argBytes s.args p).length, s.st.escapedAt (p.1.off + j) = none :=
      fun j hj => hpriv p (List.mem_cons_self ..) j (by omega)
    obtain ⟨st', hwr⟩ : ∃ st', s.st.writeFrame p.1.off (argBytes s.args p) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    obtain ⟨hmem1, hesc1, hfr1⟩ := writeFrame_private_eq hwr hpw
    have h0 := hcode 0 (by simp)
    simp only [Nat.add_zero, List.getElem_cons_zero] at h0
    have hstep := step_arg (ch := ch) h0.1 h0.2 hok.2.2.2.2.2.2 hwr
    let s1 : RState := { s with pc := s.pc + 1, st := st' }
    have hcode1 : ∀ j (hj : j < is.length),
        c.d.insns[s1.pc + j]? = some is[j] ∧ c.scopesAt (s1.pc + j) = [] := by
      intro j hj
      have := hcode (j + 1) (by simp; omega)
      have e : s1.pc + j = s.pc + (j + 1) := by show s.pc + 1 + j = _; omega
      rw [e]
      simpa using this
    have hpriv1 : ∀ q ∈ ps, ∀ j < q.1.size, s1.st.escapedAt (q.1.off + j) = none := by
      intro q hq j hj
      show st'.escapedAt (q.1.off + j) = none
      rw [hesc1]
      exact hpriv q (List.mem_cons_of_mem _ hq) j hj
    obtain ⟨s', hst, hpc, hfp, hargs, hmem, hesc, hout, hin⟩ := prolog_run hrest s1 hcode1 hpriv1
    -- the write's frame outside and inside `p`'s slot
    have hfr_out : ∀ o, ¬ (p.1.off ≤ o ∧ o < p.1.off + p.1.size) → st'.frame o = s.st.frame o := by
      intro o ho
      rw [hfr1 o]
      have : s.st.privateIn p.1.off (argBytes s.args p).length o = false := by
        unfold OpSem.State.privateIn
        have : ¬ (p.1.off ≤ o ∧ o < p.1.off + ((argBytes s.args p).length : Int)) := by omega
        simp [this]
      rw [this]
      rfl
    have hfr_in : ∀ j (hj : j < (argBytes s.args p).length),
        st'.frame (p.1.off + j) = (argBytes s.args p)[j] := by
      intro j hj
      rw [hfr1]
      have hpi : s.st.privateIn p.1.off (argBytes s.args p).length (p.1.off + j) = true := by
        unfold OpSem.State.privateIn
        rw [hpw j hj]
        simp only [Option.isNone_none, Bool.and_true, decide_eq_true_eq]
        omega
      rw [if_pos hpi]
      have e : (p.1.off + (j : Int) - p.1.off).toNat = j := by omega
      rw [e, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hj, Option.getD_some]
    refine ⟨s', .cons hstep hst, ?_, hfp, hargs, ?_, ?_, ?_, ?_⟩
    · rw [hpc]; show s.pc + 1 + is.length = s.pc + (i :: is).length; simp only [List.length_cons]; omega
    · rw [hmem]; exact hmem1
    · intro o; rw [hesc o]; exact hesc1 o
    · intro o ho
      rw [hout o (fun q hq => ho q (List.mem_cons_of_mem _ hq))]
      exact hfr_out o (ho p (List.mem_cons_self ..))
    · intro hpw' q hq j hj
      have hpw'' := List.pairwise_cons.mp hpw'
      rcases List.mem_cons.mp hq with rfl | hq'
      · have hd := hpw''.1
        rw [hout]
        · exact hfr_in j hj
        · intro r hr hin'
          have := hd r hr
          unfold SlotDisj at this
          omega
      · exact hin hpw''.2 q hq' j hj

/-- The L0 side of call entry for input `p` with storage `ptr`: its allocation private, live, at
the slot, its bytes refining the register's (see the module comment). -/
def ArgRel (ι : Inj) (fp : Nat) (m0 : Memory) (args : Regs) (p : LocalSlot × Asm.ArgReg)
    (ptr : ThinPointer) : Prop :=
  ∃ al x, ptr.prov = some al ∧ ι al = none ∧ m0.get? al = some x ∧ x.live = true ∧
    (x.addr : Int) = fp + p.1.off ∧ ptr.addr = x.addr ∧ x.data.size = p.1.size ∧
    ∀ k (hk : k < x.data.size), ∃ b, (argBytes args p)[k]? = some b ∧ ByteInj ι x.data[k] b

/-- The prologue simulated: every input local related privately and live afterwards. -/
theorem prolog_sim {Γ : PrologCtx} {c : Code} {ch : OpSem.Choice} {is : List Insn}
    {ps : List (LocalSlot × Asm.ArgReg)} (hl : LowerProlog Γ is ps)
    {ι : Inj} {fp : Nat} {m0 : Memory} {s : RState}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧
      c.scopesAt (s.pc + j) = [])
    (hpriv : ∀ p ∈ ps, ∀ j < p.1.size, s.st.escapedAt (p.1.off + j) = none)
    (qs : List ThinPointer)
    (hrel : ∀ j (h1 : j < ps.length) (h2 : j < qs.length), ArgRel ι fp m0 s.args ps[j] qs[j])
    (hmem : MemInj ι m0 s.st.mem) :
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      MemInj ι m0 s'.st.mem ∧
      ∀ j (h1 : j < ps.length) (h2 : j < qs.length), LocalRel ι fp s'.st m0 ps[j].1 qs[j] true := by
  obtain ⟨s', hst, hpc, hfp, hargs, hmem', hesc, -, hin⟩ := prolog_run hl.args s hcode hpriv
  refine ⟨s', hst, hpc, hfp, hargs, by rw [hmem']; exact hmem, ?_⟩
  intro j h1 h2
  obtain ⟨al, x, hp, hι, hx, hlive, haddr, hpaddr, hsize, hb⟩ := hrel j h1 h2
  have hmemj : ps[j] ∈ ps := List.getElem_mem h1
  refine .priv al x hp hι hx hlive haddr hpaddr hsize ?_ ?_
  · intro k hk
    rw [hesc]
    exact hpriv _ hmemj k hk
  · intro _ k hk
    obtain ⟨b, hbk, hbi⟩ := hb k hk
    obtain ⟨hkl, hbe⟩ := List.getElem?_eq_some_iff.mp hbk
    rw [hin hl.disj _ hmemj k hkl, hbe]
    exact hbi

end Ryo.Proofs.Lower
