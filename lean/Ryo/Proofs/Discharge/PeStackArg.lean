/-
Ryo.Proofs.Discharge.PeStackArg — `Hyps.peStackArg` (PE's handler stack argument at the frame
offsets `[-F + 32, -F + 36)`) from the checks and `FrameInv.slots` (`ArgSlots`), and the step
lemmas that keep `ArgSlots`.

A five-argument handler call (the `atomic.cxchg` handlers') makes `shadowSize` 40, so
`frameLo = -F + 40` (`frameLo_of_five`), and:
- `F_ge_of_check`: `frameSizesCheck`'s `peStackArgCheck` (`shadowSize ≤ F`, run by
  `Frame.decodeChecked`) gives `40 ≤ F`, so `36 ≤ F`;
- `below_frameLo_scopes`: the bound check (`boundsOk`: every scope's range starts at or above
  `frameLo`) makes the scopes keep the bytes below `frameLo` private and `Uninit`: an
  `Escape` there doesn't cover them (`ScopeMem.escFree_foldlM`), and no scope makes a byte
  initialized (`End` writes `Uninit`, `uninit_foldlM`).
That the bytes are private and `Uninit` before the scopes is a fact of the states R reaches,
`ArgSlots` (`FrameInv.slots`), which every step keeps:
- the scopes (`ArgSlots.scopes`, `below_frameLo_scopes`);
- every frame write the decoded code makes but a call's stack area and an island's shadow space
  starts at or above `frameLo` (`boundsOk`: `native_lo`, `handler_lo`, `arg_lo`, `result_lo`,
  `lends_lo`), so it misses them (`ArgSlots.writeFrame_above`, `ArgSlots.opSem`,
  `ArgSlots.parts`, `ArgSlots.writeRanges`);
- an island's answer makes its shadow space `Uninit` (`ArgSlots.writeFrame_uninit`), as do a
  call's write of its sret destination and a handler call's clearing of its PE home space
  (`ArgSlots.clearHome`);
- a call's answer rewrites its stack area `[-F, -F + stackSize)`, which `argSlotsCheck` (in
  `stackSizesCheck`) keeps below `-F + 32` when there is a stack argument (`area_miss`);
- the world, the exception and `pc` don't touch the frame (`ArgSlots.congr`).

This file doesn't import `DecodeSound/Basic.lean`, so `Basic.lean` can import it.
-/
import Ryo.Vm.FrameSizes
import Ryo.Proofs.ScopeMem
import Ryo.Proofs.MemPost
import Ryo.Proofs.DecodeLink.Bounds

namespace Ryo.Proofs.Discharge.PeStackArg

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.R

/-- `frameSizesCheck` includes `peStackArgCheck`. -/
theorem peStackArgCheck_of_frameSizes {d : R.Decoded} {mode : Ryo.Obj.Mode}
    (h : frameSizesCheck d mode = true) : peStackArgCheck d mode = true := by
  unfold frameSizesCheck at h
  rw [Bool.and_eq_true] at h
  exact h.2

/-- A five-argument handler call makes PE's `shadowSize` 40. -/
theorem shadowSize_of_five {c : R.Code} (hpe : c.mode.pe = true) {k : Nat} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} (hi : c.d.insns[k]? = some (.handler h args t))
    (h5 : args.length = 5) : c.d.shadowSize c.mode = 40 := by
  unfold R.Decoded.shadowSize
  split
  · next hn => simp [hpe] at hn
  · split
    · rfl
    · next hno =>
      exfalso
      apply hno
      exact Array.any_eq_true'.2 ⟨_, Array.mem_of_getElem? hi, by simp [h5]⟩

/-- With a five-argument handler call on PE, `frameLo` is `-F + 40`. -/
theorem frameLo_of_five {c : R.Code} (hpe : c.mode.pe = true) {k : Nat} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} (hi : c.d.insns[k]? = some (.handler h args t))
    (h5 : args.length = 5) : c.d.frameLo c.mode = -(c.d.frameSize : Int) + 40 := by
  have hs := shadowSize_of_five hpe hi h5
  unfold R.Decoded.frameLo
  omega

/-- `frameSizesCheck` with a five-argument handler call on PE: `40 ≤ F`. -/
theorem F_ge_of_check {c : R.Code} (hc : frameSizesCheck c.d c.mode = true)
    (hpe : c.mode.pe = true) {k : Nat} {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat}
    (hi : c.d.insns[k]? = some (.handler h args t)) (h5 : args.length = 5) :
    40 ≤ c.d.frameSize := by
  have hs := shadowSize_of_five hpe hi h5
  have hp := peStackArgCheck_of_frameSizes hc
  unfold peStackArgCheck at hp
  have := of_decide_eq_true hp
  omega

/-- The bound check: every scope's range starts at or above `frameLo`. -/
theorem scopes_ge {c : R.Code} (hb : c.d.boundsOk c.mode = true) (k : Nat) :
    ∀ sc ∈ c.scopesAt k, c.d.frameLo c.mode ≤ sc.frameOffset.toInt := by
  unfold R.Decoded.boundsOk at hb
  simp only [Bool.and_eq_true] at hb
  have hall := hb.1.2
  intro sc hsc
  unfold R.Code.scopesAt at hsc
  obtain ⟨p, hp, rfl⟩ := List.mem_map.1 hsc
  have hp' := (List.mem_filter.1 hp).1
  have hr : (p.2.frameOffset.toInt, p.2.size) ∈ c.d.frameRanges c.mode := by
    unfold R.Decoded.frameRanges
    exact List.mem_append.2 (Or.inl (List.mem_map.2 ⟨p, hp', rfl⟩))
  exact of_decide_eq_true (List.all_eq_true.1 hall _ hr)

/-- A frame write of `Uninit` bytes keeps a byte `Uninit`. -/
theorem writeFrame_uninit {st st' : OpSem.State} {off : Int} {n : Nat} {o : Int}
    (h : st.writeFrame off (List.replicate n .uninit) = .ok st') (hu : st.frame o = .uninit) :
    st'.frame o = .uninit := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off (List.replicate n .uninit) with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    dsimp only
    split
    · rw [List.getD_eq_getElem?_getD, List.getElem?_replicate]
      split <;> rfl
    · exact hu

/-- A scope keeps a byte `Uninit`: `Escape` and `Lend` don't change the frame bytes, `End`
writes `Uninit`. -/
theorem uninit_applyScope {o : Int} {s s' : R.RState} {sc : R.Scope}
    (hu : s.st.frame o = .uninit) (h : R.applyScope s sc = .ok s') : s'.st.frame o = .uninit := by
  unfold R.applyScope at h
  split at h
  · rcases Ryo.Proofs.Scope.escape_ok h with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
    · exact hu
    · exact hu
  · obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h
    exact writeFrame_uninit hw hu
  · cases h; exact hu

theorem uninit_foldlM {o : Int} : ∀ (l : List R.Scope) {s s' : R.RState},
    s.st.frame o = .uninit → l.foldlM R.applyScope s = .ok s' → s'.st.frame o = .uninit
  | [], s, s', hu, h => by cases h; exact hu
  | sc :: l, s, s', hu, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      exact uninit_foldlM l (uninit_applyScope hu h1) h

/-- The bound check makes the scopes before any instruction keep the frame bytes in
`[lo, frameLo)` private and `Uninit`. -/
theorem below_frameLo_scopes {c : R.Code} (hb : c.d.boundsOk c.mode = true) {lo : Int}
    {k : Nat} {s s1 : R.RState}
    (hlow : ∀ o : Int, lo ≤ o → o < c.d.frameLo c.mode →
      s.st.escapedAt o = none ∧ s.st.frame o = .uninit)
    (hsc : (c.scopesAt k).foldlM R.applyScope s = .ok s1) :
    ∀ o : Int, lo ≤ o → o < c.d.frameLo c.mode →
      s1.st.escapedAt o = none ∧ s1.st.frame o = .uninit := by
  intro o h1 h2
  refine ⟨Ryo.Proofs.ScopeMem.escFree_foldlM (S := fun o' => lo ≤ o' ∧ o' < c.d.frameLo c.mode)
      (c.scopesAt k) ?_ (fun o' ho' => (hlow o' ho'.1 ho'.2).1) hsc o ⟨h1, h2⟩,
    uninit_foldlM (c.scopesAt k) (hlow o h1 h2).2 hsc⟩
  intro sc hsc' _ _ o' ho' hin
  have hge := scopes_ge hb k sc hsc'
  have ho2 := ho'.2
  have hin1 := hin.1
  omega

/-! ### `ArgSlots`: the slots stay private and `Uninit` -/

/-- The frame bytes in `[-F + 32, frameLo)` (on PE with a handler call's stack argument, the 8
bytes above the shadow space; empty otherwise) are private and `Uninit` (`FrameInv.slots`). -/
def ArgSlots (c : R.Code) (st : OpSem.State) : Prop :=
  ∀ o : Int, -(c.d.frameSize : Int) + 32 ≤ o → o < c.d.frameLo c.mode →
    st.escapedAt o = none ∧ st.frame o = .uninit

theorem inRange_below {o : Int} {r : Int × Nat} (h : o < r.1) : inRange o r = false := by
  cases hr : inRange o r
  · rfl
  · simp only [inRange, decide_eq_true_eq] at hr
    have := hr.1
    omega

theorem ArgSlots.congr {c : R.Code} {st st' : OpSem.State} (h : ArgSlots c st)
    (he : st'.escaped = st.escaped)
    (hf : ∀ o : Int, -(c.d.frameSize : Int) + 32 ≤ o → o < c.d.frameLo c.mode →
      st'.frame o = st.frame o) : ArgSlots c st' := by
  intro o h1 h2
  obtain ⟨ha, hb⟩ := h o h1 h2
  refine ⟨?_, by rw [hf o h1 h2]; exact hb⟩
  unfold OpSem.State.escapedAt at ha ⊢
  rw [he]; exact ha

/-- A frame write missing the slots keeps them. -/
theorem ArgSlots.writeFrame {c : R.Code} {st st' : OpSem.State} {off : Int}
    {bs : List AbstractByte} (h : ArgSlots c st) (hw : st.writeFrame off bs = .ok st')
    (hmiss : ∀ o : Int, -(c.d.frameSize : Int) + 32 ≤ o → o < c.d.frameLo c.mode →
      inRange o (off, bs.length) = false) : ArgSlots c st' :=
  h.congr (Ryo.Proofs.ScopeMem.writeFrame_escaped hw)
    (fun o h1 h2 => writeFrame_frame hw (hmiss o h1 h2))

/-- A frame write at or above `frameLo` keeps the slots. -/
theorem ArgSlots.writeFrame_above {c : R.Code} {st st' : OpSem.State} {off : Int}
    {bs : List AbstractByte} (h : ArgSlots c st) (hw : st.writeFrame off bs = .ok st')
    (hoff : c.d.frameLo c.mode ≤ off) : ArgSlots c st' :=
  h.writeFrame hw fun o _ h2 => inRange_below (by show o < off; omega)

/-- A write of `Uninit` bytes keeps the slots. -/
theorem ArgSlots.writeFrame_uninit {c : R.Code} {st st' : OpSem.State} {off : Int} {n : Nat}
    (h : ArgSlots c st) (hw : st.writeFrame off (List.replicate n .uninit) = .ok st') :
    ArgSlots c st' := by
  intro o h1 h2
  obtain ⟨ha, hb⟩ := h o h1 h2
  refine ⟨?_, Ryo.Proofs.Discharge.PeStackArg.writeFrame_uninit hw hb⟩
  unfold OpSem.State.escapedAt at ha ⊢
  rw [Ryo.Proofs.ScopeMem.writeFrame_escaped hw]; exact ha

/-- A handler call's clearing of its PE home space (`R.clearHome`, `Uninit` bytes) keeps the
slots. -/
theorem ArgSlots.clearHome {c : R.Code} {pe : Bool} {n : Nat} {off : Int} {st st' : OpSem.State}
    (h : ArgSlots c st) (hc : R.clearHome pe n off st = .ok st') : ArgSlots c st' := by
  unfold R.clearHome at hc
  split at hc
  · exact h.writeFrame_uninit hc
  · cases hc; exact h

/-- The scopes keep the slots (`below_frameLo_scopes`). -/
theorem ArgSlots.scopes {c : R.Code} (hb : c.d.boundsOk c.mode = true) {k : Nat}
    {s s1 : R.RState} (h : ArgSlots c s.st)
    (hsc : (c.scopesAt k).foldlM R.applyScope s = .ok s1) : ArgSlots c s1.st :=
  below_frameLo_scopes (lo := -(c.d.frameSize : Int) + 32) hb h hsc

/-- `opSem` with its written ranges at or above `frameLo` keeps the slots. -/
theorem ArgSlots.opSem {c : R.Code} {f : Full.Opcode} {vals : Operands} {st st' : OpSem.State}
    {ch : OpSem.Choice} {ctl : OpSem.Control} (h : ArgSlots c st)
    (hop : OpSem.opSem f vals st ch = .ok (ctl, st'))
    (hw : ∀ r ∈ Ryo.Proofs.Inline.wranges f vals, c.d.frameLo c.mode ≤ r.1) : ArgSlots c st' :=
  h.congr (Ryo.Proofs.OpFacts.opSem_out hop).2.1 fun o _ h2 => by
    rcases Ryo.Proofs.MemPost.opSem_frame_or hop o with e | ⟨r, hr, hin⟩
    · exact e
    · have := hw r hr
      simp only [inRange, decide_eq_true_eq] at hin
      have := hin.1
      omega

/-- Writes of a call's result parts at `D + off`, `D` at or above `frameLo`, keep the slots. -/
theorem ArgSlots.parts {c : R.Code} {D : Int} (hD : c.d.frameLo c.mode ≤ D) (regs : R.Regs)
    (parts : List (Ryo.Vm.Asm.RetPart × R.Reg)) {st st' : OpSem.State} (h : ArgSlots c st)
    (hf : parts.foldlM (init := st) (fun st (q : Ryo.Vm.Asm.RetPart × R.Reg) =>
      st.writeFrame (D + q.1.off) ((regs.get q.2).take q.1.size)) = .ok st') :
    ArgSlots c st' :=
  Ryo.Proofs.ScopeMem.foldlM_inv (ArgSlots c) (fun _ => True)
    (fun st (q : Ryo.Vm.Asm.RetPart × R.Reg) =>
      st.writeFrame (D + q.1.off) ((regs.get q.2).take q.1.size))
    (fun _ _ _ hs _ hw => hs.writeFrame_above hw (by omega)) parts st st' h
    (fun _ _ => trivial) hf

/-- An answer's writes over ranges missing the slots keep them. -/
theorem ArgSlots.writeRanges {c : R.Code} {st st' : OpSem.State} {rs : List (Int × Nat)}
    {new : List (List AbstractByte)} (h : ArgSlots c st) (hw : R.writeRanges st rs new = .ok st')
    (hmiss : ∀ r ∈ rs, ∀ o : Int, -(c.d.frameSize : Int) + 32 ≤ o → o < c.d.frameLo c.mode →
      inRange o r = false) : ArgSlots c st' := by
  unfold R.writeRanges at hw
  split at hw
  · cases hw; exact h
  split at hw
  · cases hw
  simp only at hw
  refine Ryo.Proofs.ScopeMem.foldlM_inv (ArgSlots c)
    (fun p : (Int × Nat) × List AbstractByte => ∀ o : Int, -(c.d.frameSize : Int) + 32 ≤ o →
      o < c.d.frameLo c.mode → inRange o p.1 = false) _ ?_ _ st st' h
    (fun p hp => hmiss p.1 (List.of_mem_zip hp).1) hw
  rintro s0 ⟨⟨off, n⟩, bs⟩ s1 h0 hp hst
  simp only at hst hp
  split at hst
  · cases hst
  · rename_i hlen
    have hlen' : bs.length = n := by simpa using hlen
    exact h0.writeFrame hst (fun o h1 h2 => by rw [hlen']; exact hp o h1 h2)

/-- A call's stack area `[-F, -F + stackSize)` misses the slots when `argSlotsCheck` holds
(`Discharge.StackSizes.argSlots_call`). -/
theorem area_miss {c : R.Code} {n : Nat} (h : c.d.shadowSize c.mode ≤ 32 ∨ n ≤ 32) :
    ∀ o : Int, -(c.d.frameSize : Int) + 32 ≤ o → o < c.d.frameLo c.mode →
      inRange o (-(c.d.frameSize : Int), n) = false := by
  intro o h1 h2
  unfold R.Decoded.frameLo at h2
  cases hr : inRange o (-(c.d.frameSize : Int), n)
  · rfl
  · simp only [inRange, decide_eq_true_eq] at hr
    have := hr.2
    rcases h with h | h <;> omega

/-! ### The frame writes at or above `frameLo` (`boundsOk`) -/

/-- The bound check: every frame range starts at or above `frameLo`. -/
theorem frameRanges_ge {c : R.Code} (hb : c.d.boundsOk c.mode = true) :
    ∀ r ∈ c.d.frameRanges c.mode, c.d.frameLo c.mode ≤ r.1 := by
  unfold R.Decoded.boundsOk at hb
  simp only [Bool.and_eq_true] at hb
  intro r hr
  exact of_decide_eq_true (List.all_eq_true.1 hb.1.2 r hr)

/-- A native instruction's written ranges. -/
theorem native_lo {c : R.Code} (hb : c.d.boundsOk c.mode = true) {k : Nat} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} {vals : Operands}
    (hi : c.d.insns[k]? = some (.native op ops)) (hf : op.full = some f)
    (hv : Ryo.Proofs.Inline.nativeVals c.ρ f ops = some vals) :
    ∀ r ∈ Ryo.Proofs.Inline.wranges f vals, c.d.frameLo c.mode ≤ r.1 := by
  intro r hr
  rw [Ryo.Proofs.DecodeLink.Bounds.nativeWrites_eq hv] at hr
  refine frameRanges_ge hb r (Ryo.Proofs.DecodeLink.Bounds.mem_frameRanges_insn hi ?_)
  rw [Ryo.Proofs.DecodeLink.Bounds.frameRanges_native hf, nativeRanges]
  exact List.mem_append_left _ hr

/-- A handler call's written ranges. -/
theorem handler_lo {c : R.Code} (hb : c.d.boundsOk c.mode = true) {k : Nat} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {vals : Operands}
    (hi : c.d.insns[k]? = some (.handler h args t)) (hu : R.unpack c.ρ h c.mode args = some vals) :
    ∀ r ∈ Ryo.Proofs.Inline.wranges h vals, c.d.frameLo c.mode ≤ r.1 := by
  intro r hr
  rw [Ryo.Proofs.DecodeLink.Bounds.handlerWrites_eq hu] at hr
  exact frameRanges_ge hb r (Ryo.Proofs.DecodeLink.Bounds.mem_frameRanges_insn hi hr)

/-- `arg`'s destination. -/
theorem arg_lo {c : R.Code} (hb : c.d.boundsOk c.mode = true) {k : Nat} {op : Reduced.Opcode}
    {d : BitVec 32} {r : BitVec 64} {f : Full.Opcode} {a : Ryo.Vm.Asm.ArgReg}
    (hi : c.d.insns[k]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (ha : Ryo.Vm.Asm.ArgReg.of? r.toNat true = some a) :
    c.d.frameLo c.mode ≤ d.toInt := by
  refine frameRanges_ge hb (d.toInt, a.size)
    (Ryo.Proofs.DecodeLink.Bounds.mem_frameRanges_insn hi ?_)
  rw [Ryo.Proofs.DecodeLink.Bounds.frameRanges_native hf, nativeRanges, ite_eq_left hsh, argRange]
  simp only [ha]
  exact List.mem_append_right _ (List.mem_singleton_self _)

/-- A call's 16-byte result slot. -/
theorem result_lo {c : R.Code} (hb : c.d.boundsOk c.mode = true) {k : Nat} {op : Reduced.Opcode}
    {d : BitVec 32} {fo : R.Opnd Nat} {kk : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode}
    (hi : c.d.insns[k]? = some (.native op [.slot d, fo, .imm kk, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) : c.d.frameLo c.mode ≤ d.toInt := by
  refine frameRanges_ge hb (d.toInt, 16)
    (Ryo.Proofs.DecodeLink.Bounds.mem_frameRanges_insn hi ?_)
  rw [Ryo.Proofs.DecodeLink.Bounds.frameRanges_native hf, nativeRanges,
    ite_eq_right (by rw [hsh]; decide), ite_eq_right (by rw [hsh]; decide), ite_eq_left hsh,
    resultRange]
  exact List.mem_append_right _ (List.mem_singleton_self _)

/-- The `Lend` extents before an instruction (scopes). -/
theorem lends_lo {c : R.Code} (hb : c.d.boundsOk c.mode = true) (k : Nat) :
    ∀ l ∈ c.lendsAt k, c.d.frameLo c.mode ≤ l.1 := by
  intro l hl
  unfold R.Code.lendsAt at hl
  obtain ⟨sc, hsc, he⟩ := List.mem_filterMap.1 hl
  split at he
  · cases he; exact scopes_ge hb k sc hsc
  · cases he

/-- The ranges at or above `frameLo` miss the slots. -/
theorem miss_of_ge {c : R.Code} {rs : List (Int × Nat)}
    (h : ∀ r ∈ rs, c.d.frameLo c.mode ≤ r.1) :
    ∀ r ∈ rs, ∀ o : Int, -(c.d.frameSize : Int) + 32 ≤ o → o < c.d.frameLo c.mode →
      inRange o r = false :=
  fun r hr o _ h2 => inRange_below (by have := h r hr; omega)

/-- At the function's entry (`R.entry`: every frame byte `Uninit` but the incoming area at `16`,
no escaped object) the slots hold, when they lie below `16` (`frameSizesCheck`'s
`shadowSize ≤ F` gives `frameLo ≤ 0`). -/
theorem entry_slots {c : R.Code} {fp : Nat} {args : R.Regs} {stack : List AbstractByte}
    {w : R.World} {s : R.RState} (hlo : c.d.frameLo c.mode ≤ 16)
    (h : R.entry c fp args stack w = .ok s) : ArgSlots c s.st := by
  unfold R.entry at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · cases h
  split at h
  · cases h
  rename_i hw
  cases h
  refine ArgSlots.writeFrame_above ?_ hw hlo
  intro o _ _
  exact ⟨rfl, rfl⟩

end Ryo.Proofs.Discharge.PeStackArg
