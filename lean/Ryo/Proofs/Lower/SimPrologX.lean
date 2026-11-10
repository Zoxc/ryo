/-
Ryo.Proofs.Lower.SimPrologX — the prologue simulated for `LowerPrologX`
(`Check/Lower/PrologX.lean`, M5b): every register input, in `prolog_run`/`prolog_sim`/
`match_entry`'s shapes (`SimProlog.lean`, `FnEntry.lean`).

- `writes_run`: `prolog_run` over the prologue's `arg` writes (`allWrites`) instead of
  `ArgsOk`'s one per input: R runs them to the range's end, each write's range holding its
  register's low bytes (`regBytes`) when the writes are disjoint, the rest of the frame, the
  memory and the escapes unchanged.
- `ArgRelX`: the L0 side of call entry for input `inp`, generalizing `ArgRel`: the local's
  allocation private, live, at the slot, of the slot's size, and each byte either `Uninit`
  (padding between and after the pieces, a ZST's none) or inside a piece `(off, a)` and
  refining register `a`'s byte at `k - off`.
- `prologX_sim`: every input local related privately and live afterwards (`LocalRel.priv`), and
  the sret pointer's and the caller location's slots holding their registers' bytes (for the
  sret and `caller_location` rules to use).
- `match_entryX`: `match_entry` with `LowerPrologX` and `ArgRelX`; `fn_soundX` is `fn_sound`
  (`FnEntry.lean`) changed the same way (its `hpl`, `hrel`, `hloc` over `inps`): the function
  theorem for prologues `prologXVerdict` accepts (the coverage report's prologue check).

What changes against `match_entry`'s hypotheses: `hloc` and `hrel` range over the MIR inputs
`inps` (a `#[track_caller]` function's caller location is not a local; L0 keeps it in
`Frame.callerLocation`, related by nothing here yet); no `Prolog.lean`-style privacy check of
the homes: `hnoesc` (nothing escaped at entry) gives it.
-/
import Ryo.Proofs.Lower.FnEntry
import Ryo.Check.Lower.PrologX

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-- The low `a.size` bytes of register `a`, as `arg` writes them. -/
def regBytes (args : Regs) (a : Asm.ArgReg) : List AbstractByte :=
  (args.get (.ofArgReg a)).take a.size

theorem regBytes_length_le (args : Regs) (a : Asm.ArgReg) : (regBytes args a).length ≤ a.size :=
  List.length_take_le _ _

/-- Running the prologue's writes: see the module comment.

Proof: `prolog_run`'s, by induction on `ArgsAre` (`.nil`: `StepsTo.refl`; `.cons`: one
`step_arg` with the head's `argOps`, `writeEscaped_private'` and `writeFrame_private_eq` for the
write, the induction hypothesis on the rest), with `regBytes_length_le` in place of
`argBytes_length_le` and the write's own range `[w.1, w.1 + w.2.size)` in place of the slot's;
the frame inside the head's range survives the later writes by the `Pairwise` head
(`List.pairwise_cons`). -/
theorem writes_run {c : Code} {ch : OpSem.Choice} :
    ∀ {is : List Insn} {ws : List ArgWrite}, ArgsAre is ws →
    ∀ (s : RState),
    (∀ j (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧ c.scopesAt (s.pc + j) = []) →
    (∀ w ∈ ws, ∀ j < w.2.size, s.st.escapedAt (w.1 + j) = none) →
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      s'.st.mem = s.st.mem ∧ (∀ o, s'.st.escapedAt o = s.st.escapedAt o) ∧
      (∀ o, (∀ w ∈ ws, ¬ (w.1 ≤ o ∧ o < w.1 + w.2.size)) → s'.st.frame o = s.st.frame o) ∧
      (ws.Pairwise WriteDisj → ∀ w ∈ ws, ∀ j (hj : j < (regBytes s.args w.2).length),
        s'.st.frame (w.1 + j) = (regBytes s.args w.2)[j])
  | _, _, .nil, s, _, _ => by
    refine ⟨s, .refl s, by simp, rfl, rfl, rfl, fun _ => rfl, fun _ _ => rfl, ?_⟩
    intro _ w hw
    simp at hw
  | _, _, .cons (i := i) (is := is) (w := w) (ws := ws) hok hrest, s, hcode, hpriv => by
    have hlen := regBytes_length_le s.args w.2
    have hpw : ∀ j < (regBytes s.args w.2).length, s.st.escapedAt (w.1 + j) = none :=
      fun j hj => hpriv w (List.mem_cons_self ..) j (by omega)
    obtain ⟨st', hwr⟩ : ∃ st', s.st.writeFrame w.1 (regBytes s.args w.2) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    obtain ⟨hmem1, hesc1, hfr1⟩ := writeFrame_private_eq hwr hpw
    have h0 := hcode 0 (by simp)
    simp only [Nat.add_zero, List.getElem_cons_zero] at h0
    have hstep := step_arg (ch := ch) (off := w.1) (a := w.2) h0.1 h0.2 hok hwr
    let s1 : RState := { s with pc := s.pc + 1, st := st' }
    have hcode1 : ∀ j (hj : j < is.length),
        c.d.insns[s1.pc + j]? = some is[j] ∧ c.scopesAt (s1.pc + j) = [] := by
      intro j hj
      have := hcode (j + 1) (by simp; omega)
      have e : s1.pc + j = s.pc + (j + 1) := by show s.pc + 1 + j = _; omega
      rw [e]
      simpa using this
    have hpriv1 : ∀ v ∈ ws, ∀ j < v.2.size, s1.st.escapedAt (v.1 + j) = none := by
      intro v hv j hj
      show st'.escapedAt (v.1 + j) = none
      rw [hesc1]
      exact hpriv v (List.mem_cons_of_mem _ hv) j hj
    obtain ⟨s', hst, hpc, hfp, hargs, hmem, hesc, hout, hin⟩ := writes_run hrest s1 hcode1 hpriv1
    have hfr_out : ∀ o, ¬ (w.1 ≤ o ∧ o < w.1 + w.2.size) → st'.frame o = s.st.frame o := by
      intro o ho
      rw [hfr1 o]
      have : s.st.privateIn w.1 (regBytes s.args w.2).length o = false := by
        unfold OpSem.State.privateIn
        have : ¬ (w.1 ≤ o ∧ o < w.1 + ((regBytes s.args w.2).length : Int)) := by omega
        simp [this]
      rw [this]
      rfl
    have hfr_in : ∀ j (hj : j < (regBytes s.args w.2).length),
        st'.frame (w.1 + j) = (regBytes s.args w.2)[j] := by
      intro j hj
      rw [hfr1]
      have hpi : s.st.privateIn w.1 (regBytes s.args w.2).length (w.1 + j) = true := by
        unfold OpSem.State.privateIn
        rw [hpw j hj]
        simp only [Option.isNone_none, Bool.and_true, decide_eq_true_eq]
        omega
      rw [if_pos hpi]
      have e : (w.1 + (j : Int) - w.1).toNat = j := by omega
      rw [e, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hj, Option.getD_some]
    refine ⟨s', .cons hstep hst, ?_, hfp, hargs, ?_, ?_, ?_, ?_⟩
    · rw [hpc]; show s.pc + 1 + is.length = s.pc + (i :: is).length
      simp only [List.length_cons]; omega
    · rw [hmem]; exact hmem1
    · intro o; rw [hesc o]; exact hesc1 o
    · intro o ho
      rw [hout o (fun v hv => ho v (List.mem_cons_of_mem _ hv))]
      exact hfr_out o (ho w (List.mem_cons_self ..))
    · intro hpw' v hv j hj
      have hpw'' := List.pairwise_cons.mp hpw'
      rcases List.mem_cons.mp hv with rfl | hv'
      · have hd := hpw''.1
        rw [hout]
        · exact hfr_in j hj
        · intro r hr hin'
          have := hd r hr
          unfold WriteDisj at this
          omega
      · exact hin hpw''.2 v hv' j hj

/-- The L0 side of call entry for input `inp` with storage `ptr` (see the module comment). -/
def ArgRelX (ι : Inj) (fp : Nat) (m0 : Memory) (args : Regs) (inp : InputX)
    (ptr : ThinPointer) : Prop :=
  ∃ al x, ptr.prov = some al ∧ ι al = none ∧ m0.get? al = some x ∧ x.live = true ∧
    (x.addr : Int) = fp + inp.slot.off ∧ ptr.addr = x.addr ∧ x.data.size = inp.slot.size ∧
    ∀ k (hk : k < x.data.size), x.data[k] = .uninit ∨
      ∃ p ∈ inp.pieces, p.1 ≤ k ∧
        ∃ b, (regBytes args p.2)[k - p.1]? = some b ∧ ByteInj ι x.data[k] b

/-- `ArgRel` is `ArgRelX` for `Prolog.lean`'s inputs (one piece at offset 0 of the slot's size).

Proof: unfold both; the same allocation; for byte `k`, the right disjunct with the one piece
(`k - 0 = k`). -/
theorem ArgRel.toX {ι : Inj} {fp : Nat} {m0 : Memory} {args : Regs} {p : LocalSlot × Asm.ArgReg}
    {ptr : ThinPointer} (h : ArgRel ι fp m0 args p ptr) :
    ArgRelX ι fp m0 args ⟨p.1, [(0, p.2)]⟩ ptr := by
  unfold ArgRel at h
  obtain ⟨al, x, hp, hι, hx, hl, ha, hpa, hs, hb⟩ := h
  unfold ArgRelX
  refine ⟨al, x, hp, hι, hx, hl, ha, hpa, hs, fun k hk => .inr ⟨(0, p.2),
    List.mem_singleton.mpr rfl, Nat.zero_le _, ?_⟩⟩
  obtain ⟨b, hb1, hb2⟩ := hb k hk
  refine ⟨b, ?_, hb2⟩
  show (regBytes args p.2)[k - 0]? = some b
  rw [Nat.sub_zero]
  exact hb1

/-- Input `j`'s home is local `k + j + 1`'s slot. -/
theorem inputsOk_slot {Γp : PrologXCtx} : ∀ {k : Nat} {inps : List InputX},
    InputsOk Γp k inps → ∀ j (h : j < inps.length), Γp.slots[k + j + 1]? = some (inps[j]).slot
  | _, _, .nil _, j, h => by simp at h
  | _, _, .cons (k := k) (inp := inp) (inps := inps) hok hrest, j, h => by
    cases j with
    | zero =>
      obtain ⟨_, _, _, hs, _⟩ := hok
      simpa using hs
    | succ j =>
      have h' : j < inps.length := by simp at h; omega
      have := inputsOk_slot hrest j h'
      have e : k + (j + 1) + 1 = k + 1 + j + 1 := by omega
      rw [e]
      simpa using this

/-- Input `j` satisfies its rule (`InputsOk` at index `j`). -/
theorem inputsOk_get {Γp : PrologXCtx} : ∀ {k : Nat} {inps : List InputX},
    InputsOk Γp k inps → ∀ j (h : j < inps.length), InputOk Γp (k + j) inps[j]
  | _, _, .nil _, j, h => by simp at h
  | _, _, .cons (k := k) (inp := inp) (inps := inps) hok hrest, j, h => by
    cases j with
    | zero => first | exact hok | simpa using hok
    | succ j =>
      have h' : j < inps.length := by simp at h; omega
      have := inputsOk_get hrest j h'
      have e : k + (j + 1) = k + 1 + j := by omega
      rw [e]
      first | exact this | simpa using this

/-- An input's writes are among the prologue's, and so pairwise disjoint and within its slot.

Proof: `List.mem_append`, `List.mem_flatMap` with `List.getElem_mem` for `inps[j]`; the piece's
bound is `InputOk`'s last conjunct (from `InputsOk` at index `j`, by induction as
`inputsOk_slot`). -/
theorem input_write_mem {Γp : PrologXCtx} {is : List Insn} {inps : List InputX}
    {lw : List ArgWrite} (hl : LowerPrologX Γp is inps lw) (j : Nat) (hj : j < inps.length)
    {p : Nat × Asm.ArgReg} (hp : p ∈ inps[j].pieces) :
    (inps[j].slot.off + p.1, p.2) ∈ allWrites Γp inps lw ∧
      p.1 + p.2.size ≤ inps[j].slot.size := by
  have hmw : (inps[j].slot.off + p.1, p.2) ∈ inps[j].writes := by
    unfold InputX.writes
    exact List.mem_map.mpr ⟨p, hp, rfl⟩
  refine ⟨?_, ?_⟩
  · simp only [allWrites, List.mem_append, List.mem_flatMap]
    first
      | exact Or.inl (Or.inr ⟨_, List.getElem_mem hj, hmw⟩)
      | exact Or.inr (Or.inl ⟨_, List.getElem_mem hj, hmw⟩)
  · obtain ⟨_, _, _, _, _, hfit⟩ := inputsOk_get hl.inputs j hj
    exact hfit p hp

/-- The prologue simulated: see the module comment.

Proof: `writes_run hl.insns s hcode` (privacy from `hnoesc`); for input `j`, `ArgRelX` gives the
allocation and `.priv` (`LocalRel`) needs, per byte `k` of the slot, `ByteInj ι x.data[k]
(frame (slot.off + k))`: `Uninit` refines anything; inside piece `p` the frame byte at
`slot.off + p.1 + (k - p.1)` is `regBytes`' (`writes_run`'s last conjunct with `hl.disj` and
`input_write_mem`, index `k - p.1 < (regBytes ..).length` from the `getElem?`). The
extra writes' bytes: the same conjunct, as `sretWrites Γp ++ lw ⊆ allWrites Γp inps lw`. -/
theorem prologX_sim {Γp : PrologXCtx} {c : Code} {ch : OpSem.Choice} {is : List Insn}
    {inps : List InputX} {lw : List ArgWrite} (hl : LowerPrologX Γp is inps lw)
    {ι : Inj} {fp : Nat} {m0 : Memory} {s : RState}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧
      c.scopesAt (s.pc + j) = [])
    (hnoesc : ∀ o, s.st.escapedAt o = none)
    (qs : List ThinPointer)
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelX ι fp m0 s.args inps[j] qs[j])
    (hmem : MemInj ι m0 s.st.mem) :
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      MemInj ι m0 s'.st.mem ∧ (∀ o, s'.st.escapedAt o = none) ∧
      (∀ j (h1 : j < inps.length) (h2 : j < qs.length),
        LocalRel ι fp s'.st m0 inps[j].slot qs[j] true) ∧
      (∀ w ∈ sretWrites Γp ++ lw, ∀ j (hj : j < (regBytes s.args w.2).length),
        s'.st.frame (w.1 + j) = (regBytes s.args w.2)[j]) := by
  obtain ⟨s', hst, hpc, hfp, hargs, hmem', hesc, -, hin⟩ :=
    writes_run (ch := ch) hl.insns s hcode (fun _ _ _ _ => hnoesc _)
  refine ⟨s', hst, hpc, hfp, hargs, by rw [hmem']; exact hmem,
    fun o => by rw [hesc]; exact hnoesc o, ?_, ?_⟩
  · intro j h1 h2
    obtain ⟨al, x, hp, hι, hx, hlive, haddr, hpaddr, hsize, hb⟩ := hrel j h1 h2
    refine .priv al x hp hι hx hlive haddr hpaddr hsize
      (fun k _ => by rw [hesc]; exact hnoesc _) ?_
    intro _ k hk
    rcases hb k hk with hu | ⟨p, hp', hle, b, hbk, hbi⟩
    · rw [hu]; trivial
    · obtain ⟨hkl, hbe⟩ := List.getElem?_eq_some_iff.mp hbk
      obtain ⟨hwm, -⟩ := input_write_mem hl j h1 hp'
      have hfk := hin hl.disj _ hwm (k - p.1) hkl
      dsimp only at hfk
      have e : inps[j].slot.off + (k : Int) =
          inps[j].slot.off + (p.1 : Int) + ((k - p.1 : Nat) : Int) := by omega
      rw [e, hfk, hbe]
      exact hbi
  · intro w hw j hj
    refine hin hl.disj w ?_ j hj
    simp only [allWrites, List.mem_append] at hw ⊢
    rcases hw with h | h <;> simp [h]

/-- `match_entry` for `LowerPrologX` (see the module comment), with the extra writes' bytes.

Proof: `match_entry`'s, with `prologX_sim` (at `fp := s1.fp`, then `s'.fp = s1.fp`) in place of
`prolog_run` and the `LocalRel` it builds, `inputsOk_slot hpl.inputs` in place of
`argsOk_slot`. -/
theorem match_entryX {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {ι : Inj}
    {Γp : PrologXCtx} {is : List Insn} {inps : List InputX} {lw : List ArgWrite}
    (hpl : LowerPrologX Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    -- R at the prologue
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hreach : reachGet (computeReach Γ.body) 0 = true)
    (hfz : blk.fused = true → 0 < bd.stmts.length)
    -- L0's entry frame (`callBody`)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelX ι s1.fp s.mem s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem) :
    ∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s s1' ∧
      ∀ w ∈ sretWrites Γp ++ lw, ∀ j (hj : j < (regBytes s1.args w.2).length),
        s1'.st.frame (w.1 + j) = (regBytes s1.args w.2)[j] := by
  obtain ⟨s', hst, hpc, hfp, -, hmem', hesc, hlr0, hw⟩ :=
    prologX_sim (ch := ch) hpl hcode hnoesc qs hrel hmem
  have hlr : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      LocalRel ι s'.fp s'.st s.mem inps[j].slot qs[j] true := by
    rw [hfp]; exact hlr0
  refine ⟨s', hst, Or.inl ⟨f, rest, blk, bd, ?_, by rw [hbb]; exact hreach,
    fun h => by rw [hstmt]; exact hfz h⟩, hw⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, rel := ?_, sl := ?_, pb := hpb, fresh := hfresh, dinv := hdinv }
  · rw [hbb]; exact hblk
  · rw [hbb]; exact hbd
  · rw [hstmt]; exact Nat.zero_le _
  · rw [hstmt, hstart, hpc]
  · refine ⟨⟨?_, ?_⟩, hhid, hal, hprov, hapart, ?_⟩
    · exact hmem'
    · intro l p hp _
      obtain ⟨j, h1, h2, rfl, rfl⟩ := hloc l p hp
      refine ⟨inps[j].slot, ?_, (hlr j h1 h2).weaken (fun _ => rfl)⟩
      have := inputsOk_slot hpl.inputs j h1
      rw [hslots] at this
      simpa using this
    · intro o e he
      rw [hesc] at he
      cases he
  · intro l p hp
    rw [hbb, hstmt]
    exact hsl l p hp

/-- `fn_sound` with `LowerPrologX`'s entry (`match_entryX`): the function theorem from entry
for every prologue `prologXVerdict` accepts. -/
theorem fn_soundX {Γ : TermCtx} {c : Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o s s1.fp)
    {Γp : PrologXCtx} {is : List Insn} {inps : List InputX} {lw : List ArgWrite}
    (hpl : LowerPrologX Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelX ι s1.fp s.mem s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem)
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧
          RetValX Γ ι v regs) ∨
      (∃ s1', StepsTo c ch s1 s1' ∧ DeadAt Γ s') := by
  obtain ⟨s0, hst0, hm0, -⟩ := match_entryX (ch := ch) hpl hslots hcode hnoesc hblk hbd hstart
    hfn.reach.entry (fused_start hfn hfn.reach.entry hbd hblk) hs hbody hbb hstmt hpu hcont hal
    qs hloc hrel hmem hhid hprov hapart hsl hpb hfresh hdinv
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩ | ⟨s1', hst, hd⟩
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr ⟨s1', hst0.trans hst, hd⟩)

end Ryo.Proofs.Lower
