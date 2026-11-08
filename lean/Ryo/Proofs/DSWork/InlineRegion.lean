/-
Ryo.Proofs.DSWork.InlineRegion — inline code, dense switches, `jmp` and `unreachable` in PE's pad
region (PE-T4.2).

After the mid-level lemmas take `FrameCore` (PE-T4.0) the x86 run and the frame of
`bodySim_inline'`/`bodySim_denseB` apply to the region's state itself; `rsp` is kept, and the
trampoline's return address isn't a frame range or a live allocation (`RegionInv.allocsOff`).
Branch targets stay in the region (`RegionFacts.noCross`).
-/
import Ryo.Proofs.DSWork.Inline
import Ryo.Proofs.Dense
import Ryo.Proofs.DecodeSound.Region
import Ryo.Proofs.DecodeSound.Dense
import Ryo.Proofs.DSWork.Handler
import Ryo.Proofs.DecodeLink.CacheRegs
import Ryo.Proofs.HandlerStackArg

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Call (Saved)
open Ryo.Proofs.Counter (InStack)

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- An instruction in PE's pad region is on PE. -/
theorem region_pe {k : Nat} (h : S.c.inRegion k = true) : S.c.mode.pe = true := by
  simp only [R.Code.inRegion, Bool.and_eq_true] at h
  exact h.1

/-- `protoFacts_insnOf` for the region: `fixResume` is the identity off `resume`. -/
theorem protoFactsR_insnOf {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    (hP : ProtoFactsR S k p q c' cache') (hop : q.op ≠ .resume) :
    ∃ i p1 counter, S.c.d.insns[k]? = some i ∧
      InsnOf (posOf S.r) { q with pos := p1, counter } i ∧
      ∃ hk : k < S.r.protos.size, S.r.protos[k] = { q with pos := p1, counter } := by
  obtain ⟨hlt, ⟨p1, ctr, hpq⟩, ⟨i, hi, hio⟩, -⟩ := hP
  have hfx : S.fixResume { q with pos := p1, counter := ctr } =
      { q with pos := p1, counter := ctr } := by
    simp [Setup.fixResume, hop]
  rw [hfx] at hpq
  have hpk : S.r.protos[k] = { q with pos := p1, counter := ctr } := by
    rw [Array.getElem?_eq_some_iff] at hpq
    exact hpq.2
  exact ⟨i, p1, ctr, hi, hpk ▸ hio hlt, hlt, hpk⟩

/-- `RegionInv` at a successor in the region, from the frame there (`FrameCore`) on a machine
state with the same memory, `rbp` and `rsp`. -/
theorem RegionInv.next {e : X86.State} {s s' : R.RState} {x y : X86.State}
    (hf : RegionInv S e s x) (hc : FrameCore S s' y) (hin : S.c.inRegion s'.pc = true)
    (hrbp : y.reg .rbp = x.reg .rbp) (hrsp : y.rsp = x.rsp) (hm : y.mem = x.mem) :
    RegionInv S e s' y :=
  { toFrameCore := hc
    inR := hin
    entered := hf.entered
    rsp := hrsp.trans hf.rsp
    align := by rw [hrsp]; exact hf.align
    below := by rw [hrsp, hrbp]; exact hf.below
    room := by rw [hrsp]; exact hf.room
    tramp := by rw [hrsp, hm]; exact hf.tramp }

/-- An inline instruction's run keeps every byte outside its frame writes and the live
allocations (`inline_effects'`'s memory facts, before they are specialized). -/
theorem inline_mem_kept (H : Hyps S) (hbl : InlineBelowLink S) {s s' : R.RState}
    {x x' : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {cls : Class} {cand : List Item} {br : Option Cond} {cache : Cache}
    (hf : FrameCore S s x) (hco : CodeOff S s) (hci : CacheInv cache x)
    (hcro : CacheRegsOk S cache)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hfull : op.full = some f)
    (hmem : (f, cls) ∈ inlineOps)
    (hseq : sequence cls ops = some (cand, br))
    (hstep : R.step S.c s ch = .ok (.step s'))
    (hx : execItems S.ctx (cache.emit cand).1 x = .ok x') :
    (∀ b, (((∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) ∧
        ¬ Ryo.Proofs.Call.InAlloc s.world b) ∨
        ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o) → x'.mem b = x.mem b) := by
  have hok := H.inlineOk f cls hmem
  have hfb := H.frameBounds
  obtain ⟨hovf, hext, hshi⟩ := inline_class_of hmem
  obtain ⟨s1, hsc, hv⟩ := Step.step_native hi hfull hok.opShape hstep
  obtain ⟨vals, _, _, _, _, hn, _, _, _, _⟩ :=
    Step.stepView_native hfull hok.opShape hok.notResume hok.notUnreachable hv
  have hwin : WrIn (-(S.F : Int)) S.K f vals := hfb.writes s.pc op ops f vals hi hfull hn
  have hoff : ∀ r ∈ wranges f vals, r.1 + r.2 ≤ 0 ∨ 16 ≤ r.1 :=
    hbl s.pc op ops f cls vals hi hfull hmem hn
  have hpeO : S.c.mode.pe = true → (emitHead { cache with tick := cache.tick + 1 } cand).1 ≠ 2 ∧
      (emitHead { cache with tick := cache.tick + 1 } cand).1 ≠ 3 := fun hp => hcro hp cand
  have fin : ∀ {Clob : Fin 16 → Prop}, (∀ i, Clob i → i.val ≤ 2) →
      EmitKept Clob cache cand x x' →
      (∀ b, (((∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) ∧
        ¬ Ryo.Proofs.Call.InAlloc s.world b) ∨
        ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o) → x'.mem b = x.mem b) →
      (∀ b, (((∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) ∧
        ¬ Ryo.Proofs.Call.InAlloc s.world b) ∨
        ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o) → x'.mem b = x.mem b) := by
    intro Clob _ _ hm
    exact hm
  have hmW : MemOutW S.c f ops x x' → ∀ b, (((∀ o : Int, -(S.F : Int) ≤ o → o < S.K →
      b ≠ S.winAddr o) ∧ ¬ Ryo.Proofs.Call.InAlloc s.world b) ∨
      ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o) → x'.mem b = x.mem b :=
    fun ho b hb => ho vals hn b (inline_memW_cases H hf hwin hoff (hb.imp_left (fun h => h.1)))
  have hcl01 : ∀ i : Fin 16, (i = 0 ∨ i = 1) → i.val ≤ 2 := by
    rintro i (rfl | rfl) <;> decide
  have cached : SoundC cls → ∀ b, (((∀ o : Int, -(S.F : Int) ≤ o → o < S.K →
      b ≠ S.winAddr o) ∧ ¬ Ryo.Proofs.Call.InAlloc s.world b) ∨
      ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o) → x'.mem b = x.mem b := fun hsd => by
    obtain ⟨x1, hx1, -, -, -, -, hk, ho⟩ := inline_step_cached_regs S.ctx hsd hci hf.rrel hi hfull
      hok hext hseq hstep
    cases hx.symm.trans hx1
    exact fin (Clob := (· ∈ clobbers cls)) (inline_clobbers_le2 cls) hk (hmW ho)
  cases cls with
  | load w =>
    obtain ⟨x1, hx1, -, -, -, -, -, -, hk, ho⟩ := load_step_sep_cached_regs S.ctx hci hf.rrel
      hf.mem hf.sep (hfb.window hf.win) (hfb.scopesIn s.pc) (hfb.scope_size s.pc)
      (hfb.wrIn hi hfull) hi hfull hok hseq hstep
    cases hx.symm.trans hx1
    exact fin (Clob := fun i => i = 0 ∨ i = 1) hcl01 hk (hmW ho)
  | store w =>
    obtain ⟨x1, hx1, -, -, -, -, -, -, hk, ho⟩ := store_step_sep_cached_regs S.ctx hci hf.rrel
      hf.mem hf.sep (hfb.window hf.win) (hfb.scopesIn s.pc) (hfb.scope_size s.pc)
      hi hfull hok hseq hstep
    cases hx.symm.trans hx1
    exact fin (Clob := fun i => i = 0 ∨ i = 1) hcl01 hk
      (fun b hb => ho s1 hsc b (inline_store_apart' H hf hsc hb))
  | addrConst =>
    obtain ⟨st0, x0, hg⟩ := H.globals
    obtain ⟨x1, hx1, -, -, -, -, -, hk, ho⟩ := rip_step_sep_cached_regs S.ctx rfl hci hf.rrel
      hf.mem hg hf.sep (hfb.window hf.win) (hfb.scopesIn s.pc) (hfb.scope_size s.pc)
      (hfb.wrIn hi hfull) hi hfull hok hseq hstep
    cases hx.symm.trans hx1
    exact fin (Clob := fun i => i = 0 ∨ i = 1) hcl01 hk (hmW ho)
  | addrSym =>
    obtain ⟨st0, x0, hg⟩ := H.globals
    obtain ⟨x1, hx1, -, -, -, -, -, hk, ho⟩ := rip_step_sep_cached_regs S.ctx rfl hci hf.rrel
      hf.mem hg hf.sep (hfb.window hf.win) (hfb.scopesIn s.pc) (hfb.scope_size s.pc)
      (hfb.wrIn hi hfull) hi hfull hok hseq hstep
    cases hx.symm.trans hx1
    exact fin (Clob := fun i => i = 0 ∨ i = 1) hcl01 hk (hmW ho)
  | addrSymInd =>
    obtain ⟨st0, x0, hg⟩ := H.globals
    obtain ⟨x1, hx1, -, -, -, -, -, hk, ho⟩ := rip_step_sep_cached_regs S.ctx rfl hci hf.rrel
      hf.mem hg hf.sep (hfb.window hf.win) (hfb.scopesIn s.pc) (hfb.scope_size s.pc)
      (hfb.wrIn hi hfull) hi hfull hok hseq hstep
    cases hx.symm.trans hx1
    exact fin (Clob := fun i => i = 0 ∨ i = 1) hcl01 hk (hmW ho)
  | ovf aop sg w =>
    rcases hovf aop sg w rfl with rfl | rfl
    · exact cached (inline_soundC _ (.inr rfl))
    · exact cached (inline_soundC _ (.inr rfl))
  | mulOvf sg w => exact cached (inline_soundC _ (.inr rfl))
  | mov w => exact cached (inline_soundC _ (.inl rfl))
  | mov128 => exact cached (inline_soundC _ (.inl rfl))
  | imm w => exact cached (inline_soundC _ (.inl rfl))
  | addr => exact cached (inline_soundC _ (.inl rfl))
  | ptrAdd => exact cached (inline_soundC _ (.inl rfl))
  | ptrIndex => exact cached (inline_soundC _ (.inl rfl))
  | bin o w => exact cached (inline_soundC _ (.inl rfl))
  | binImm o w => exact cached (inline_soundC _ (.inl rfl))
  | mul w => exact cached (inline_soundC _ (.inl rfl))
  | mulImm w => exact cached (inline_soundC _ (.inl rfl))
  | shiftImm sh w => exact cached (inline_soundC _ (.inl (hshi sh w rfl)))
  | cmp c w => exact cached (inline_soundC _ (.inl rfl))
  | cmpImm c w => exact cached (inline_soundC _ (.inl rfl))
  | br => exact cached (inline_soundC _ (.inl rfl))
  | brCmp c w => exact cached (inline_soundC _ (.inl rfl))
  | brCmpImm c w => exact cached (inline_soundC _ (.inl rfl))
  | ext a b sx => exact cached (inline_soundC _ (.inl rfl))
  | shiftVar | div | count | cmp3 | bswap => exact cached (inline_soundC_all _ (.inr (.inr rfl)))

/-- `RegionInv.next` with memory changed but for the trampoline's return address. -/
theorem RegionInv.next' {e : X86.State} {s s' : R.RState} {x y : X86.State}
    (hf : RegionInv S e s x) (hc : FrameCore S s' y) (hin : S.c.inRegion s'.pc = true)
    (hrbp : y.reg .rbp = x.reg .rbp) (hrsp : y.rsp = x.rsp)
    (htr : y.mem.read64 (x.rsp + 40) = x.mem.read64 (x.rsp + 40)) :
    RegionInv S e s' y :=
  { toFrameCore := hc
    inR := hin
    entered := hf.entered
    rsp := hrsp.trans hf.rsp
    align := by rw [hrsp]; exact hf.align
    below := by rw [hrsp, hrbp]; exact hf.below
    room := by rw [hrsp]; exact hf.room
    tramp := by rw [hrsp, htr]; exact hf.tramp }

/-- The trampoline's return address `[rsp + 40, rsp + 48)` in the region is below the frame
window (`below`) and in no live allocation (`allocsOff`: those are off the stack below the
frame, and `room` puts it above `lo`). -/
theorem region_tramp_off (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {e : X86.State} {s : R.RState} {x : X86.State} (hf : RegionInv S e s x)
    {i : Nat} (hi : i < 8) :
    (∀ o : Int, -(S.F : Int) ≤ o → o < S.K → x.rsp + 40 + BitVec.ofNat 64 i ≠ S.winAddr o) ∧
      ¬ Ryo.Proofs.Call.InAlloc s.world (x.rsp + 40 + BitVec.ofNat 64 i) := by
  have hb := hf.below
  have hro := hf.room
  have hrb := hf.rrel.rbp
  have hwin := hf.win
  have hfF := hf.fpF
  have hK : (16 : Int) ≤ S.K := by unfold Setup.K; omega
  have hfp64 : s.fp < 2 ^ 64 := by omega
  have hrbn : (x.reg .rbp).toNat = s.fp := by
    rw [hrb, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hfp64]
  have hbt : (x.rsp + 40 + BitVec.ofNat 64 i).toNat = x.rsp.toNat + 40 + i := by
    have : x.rsp.toNat + 48 < 2 ^ 64 := by omega
    bv_omega
  refine ⟨fun o h1 h2 heq => ?_, fun ha => ?_⟩
  · rw [← hf.toFrameCore.fpAddr_eq] at heq
    have ht := HandlerStackArg.fpAddr_toNat (x := x) (o := o) hrb (by omega) (by omega)
    rw [← heq, hbt] at ht
    omega
  · apply (RegionInv.allocsOff hD H hf _ ha).2
    have hFl : S.F ≤ (x.reg .rbp).toNat := by omega
    have hsub : (x.reg .rbp - BitVec.ofNat 64 S.F).toNat = (x.reg .rbp).toNat - S.F := by
      rw [BitVec.toNat_sub, BitVec.toNat_ofNat, Nat.mod_eq_of_lt (a := S.F) (by omega)]
      omega
    unfold InStack
    rw [hsub, hbt]
    omega

/-- The trampoline's return address is kept by a run that keeps every byte outside the frame
window and the live allocations (`inline_mem_kept`'s condition). -/
theorem region_tramp_kept (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {e : X86.State} {s : R.RState} {x x' : X86.State} (hf : RegionInv S e s x)
    (hm : ∀ b, (((∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) ∧
        ¬ Ryo.Proofs.Call.InAlloc s.world b) ∨
        ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o) → x'.mem b = x.mem b) :
    x'.mem.read64 (x.rsp + 40) = x.mem.read64 (x.rsp + 40) :=
  CallLemmas.read64_congr fun i hi => hm _ (.inl (region_tramp_off hD H hf hi))

/-- After an inline instruction in the region, R is still in the region (the next instruction,
`inRegion` is monotone, or a target, `noCross`), not at a leading `arg`. -/
theorem inline_region_succ (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache} {s s' : R.RState}
    {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class}
    {ch : OpSem.Choice}
    (hP : ProtoFactsR S k p q c' cache') (hs : s.pc = k)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hc : (f, cls) ∈ inlineOps) (hstep : R.step S.c s ch = .ok (.step s')) :
    S.c.inRegion s'.pc = true ∧ ¬ LeadArg S s'.pc := by
  have hok := H.inlineOk f cls hc
  obtain ⟨s1, hsc, hv⟩ := Step.step_native hi hf hok.opShape hstep
  obtain ⟨vals, t, ctl, st', pc', -, hctl, -, hsucc, ho⟩ :=
    Step.stepView_native hf hok.opShape hok.notResume hok.notUnreachable hv
  have hpc : s'.pc = pc' := by cases ho; rfl
  have hk1 : s1.pc = k := by rw [(scopes_keeps _ hsc).pc, hs]
  rw [hk1] at hsucc
  rw [hpc]
  have hlt := hP.lt
  have hin : S.c.inRegion pc' = true := by
    rcases inline_succ hsucc with rfl | hx
    · have h := hP.inR
      unfold R.Code.inRegion at h ⊢
      cases hrs : S.c.d.regionStart with
      | none => rw [hrs] at h; simp at h
      | some L =>
        rw [hrs] at h
        simp only [Option.any_some, Bool.and_eq_true, decide_eq_true_eq] at h ⊢
        exact ⟨h.1, by omega⟩
    · obtain ⟨o, hoo, hxo⟩ := inline_ctl_targets hctl hx
      have hik := hi
      rw [hs] at hik
      obtain ⟨hk', hie⟩ := Array.getElem?_eq_some_iff.1 hik
      have hj : pc' < S.r.protos.size :=
        reducedOf_targets_lt hD.reduced k hk' pc' (by
          rw [hie]; exact List.mem_flatMap.2 ⟨o, hoo, hxo⟩)
      obtain ⟨i, hi', hio⟩ := hP.insn
      rw [hik] at hi'
      cases hi'
      have hio' := hio hlt
      have htg : posOf S.r pc' ∈ S.r.protos[k].targets := by
        unfold InsnOf at hio'
        split at hio'
        · obtain ⟨_, he, -⟩ := hio'; cases he
        · obtain ⟨op', ops', -, he, hops⟩ := hio'
          cases he
          unfold Proto.targets
          refine List.mem_append_left _ (List.mem_flatMap.2 ⟨opndMap (posOf S.r) o, ?_, ?_⟩)
          · rw [← hops]; exact List.mem_map_of_mem hoo
          · rw [inline_targetsOf_map]; exact List.mem_map_of_mem hxo
      exact (hD.region.noCross k hlt _ htg pc' hj rfl).trans hP.inR
  exact ⟨hin, fun ha => (region_not_leadArg hD (Nat.le_of_lt ha.1) hin).1 ha⟩

set_option maxRecDepth 100000 in
/-- PE-T4.2: an inline instruction (without a dropped store) in PE's pad region. -/
theorem regionSim_inline (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur cur' c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore}
    (hP : ProtoFactsR S k p q c' cache') (hn : NoArg S.frR S.body p a cur)
    (hc : (callInsn S.frR (S.dr k)).run cur = .ok (none, cur'))
    (hr : (inlineInsn (S.used k) (S.dr k) true).run cur' = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) :
    RegionSim S k p (S.used k) := by
  have hpeM := region_pe hP.inR
  have hfp := vt_fp_of_pe hD.modeValid hpeM
  have hbl := inlineBelowLink_of H.frameBounds
  have heb := inlineEscBounded_of H
  have hcls := H.inlineClsOk
  have hcro : CacheRegsOk S (S.used k) := CacheRegs.cacheRegsOk_of_decodes hD k
    (by rw [Array.length_toList]; exact Nat.le_of_lt hP.lt)
  intro e s x hs hf hrip hci hsafe
  have e1 := callInsn_none hc
  subst e1
  have hcur := noArg_inline hn hc hr hq
  subst hcur
  obtain ⟨hpos, hh, cand, br, hdi, ⟨cls, hmem, hseq⟩, hemit, hd⟩ := inlineInsn_read hr hq
  -- The R instruction.
  obtain ⟨i, p1, counter, hi, hio', hk, hpk'⟩ :=
    protoFactsR_insnOf hP (H.inlineOk _ _ hmem).notResume
  unfold InsnOf at hio'
  simp only [hh] at hio'
  obtain ⟨op, ops, hof, rfl, hops⟩ := hio'
  have hfull := inline_full_of hof
  have hseqR : sequence cls ops = some (cand, br.map (·.1)) := by
    rw [← inline_seq_map (posOf S.r), hops]; exact hseq
  have hok := H.inlineOk _ _ hmem
  have hi' : S.c.d.insns[s.pc]? = some (.native op ops) := hs ▸ hi
  -- R's step.
  obtain ⟨s', hstep⟩ : ∃ s', R.step S.c s {} = .ok (.step s') := by
    cases h : R.step S.c s {} with
    | error e =>
      obtain ⟨m, rfl⟩ := hsafe.1 _ _ h
      exact absurd h (inline_progress' H s op ops _ cls m hi' hfull hmem)
    | ok o =>
      obtain ⟨s1, -, hv⟩ := Step.step_native hi' hfull hok.opShape h
      obtain ⟨_, _, _, _, _, _, _, _, _, rfl⟩ :=
        Step.stepView_native hfull hok.opShape hok.notResume hok.notUnreachable hv
      exact ⟨_, rfl⟩
  obtain ⟨hinR', hnl⟩ := inline_region_succ hD H hP hs hi' hfull hmem hstep
  have hco := codeOff_of_region H hf
  obtain ⟨x', hx', hrr, hcc, hrip', hbr⟩ :=
    inline_cls_step H hf.toFrameCore hci hi' hfull hmem hseqR hstep
  have hkept := inline_mem_kept H hbl hf.toFrameCore hco hci hcro hi' hfull hmem hseqR hstep hx'
  rw [hemit] at hx' hcc hrip'
  simp only at hx' hcc hrip'
  have htr := region_tramp_kept hD H hf hkept
  have hb := hP.bound
  have hstop : S.start (k + 1) = c'.pos := inline_nop_none (inline_read_bare hr) hP.nop
  have hex : ∃ op ops f cls cand br, ∃ cache : Cache, S.c.d.insns[s.pc]? = some (.native op ops) ∧
      op.full = some f ∧ (f, cls) ∈ inlineOps ∧ sequence cls ops = some (cand, br) ∧
      CacheInv cache x ∧ CacheRegsOk S cache ∧ (cache.emit cand).1 = q.items :=
    ⟨op, ops, q.op, cls, cand, _, S.used k, hi', hfull, hmem, hseqR, hci, hcro, by rw [hemit]⟩
  rcases hd with ⟨hbrn, hdec⟩ | ⟨cond, tgt, long, hbrs, hdec⟩
  · -- No branch: fall through to `k + 1`.
    subst hbrn
    have hdec' := Dec.at_iff.1 hdec
    obtain ⟨hcode, hcpos, -⟩ := (hf.code.toLinkOk hfp).dec hdec' hb
    obtain ⟨hsteps, hf', hrbp', hrsp'⟩ :=
      inline_run_core H hbl heb hcls s s' x x' {} p q.items hf.toFrameCore hco hrip hcode
        (inline_inCode_dec (hf.code.toLinkOk hfp) hdec' hb) hex hnl hstep hx' hrr
    have hpc : s'.pc = k + 1 := by simp only [BrOk, Option.map_none] at hbr; rw [hbr, hs]
    have hinv := RegionInv.next' hf hf' hinR' hrbp' hrsp' htr
    refine Reach.steps hsteps (.done (.inl ⟨s', .step hstep,
      (rbInv_region hinR').2 ⟨e, hinv, .inl ⟨?_, ?_⟩⟩⟩))
    · rw [hpc, hstop, hcpos, hrip', hrip, addrAt_add]; rfl
    · rw [hpc, hP.cache]; exact hcc
  · -- A branch class: the `jcc` after the items.
    subst hbrs
    have hdec' := Dec.at_iff.1 hdec
    obtain ⟨hcode, hcpos, -⟩ := (hf.code.toLinkOk hfp).dec hdec' hb
    rw [codeAt_append] at hcode
    obtain ⟨hsteps, hf', hrbp', hrsp'⟩ :=
      inline_run_core H hbl heb hcls s s' x x' {} p q.items hf.toFrameCore hco hrip hcode.1
        (fun a h => inline_inCode_dec (hf.code.toLinkOk hfp) hdec' hb a
          ((inCode_append _ _ _ _).2 (.inl h))) hex hnl hstep hx' hrr
    have hinv := RegionInv.next' hf hf' hinR' hrbp' hrsp' htr
    obtain ⟨hcode', -, -⟩ := (hf'.code.toLinkOk hfp).dec hdec' hb
    rw [codeAt_append] at hcode'
    obtain ⟨m, hd1, hd2⟩ := inline_dec_split hdec'
    obtain ⟨-, hm, -⟩ := (hf.code.toLinkOk hfp).dec hd1 hb
    have hcan : (Item.branch cond tgt long).Canonical (p + codeSize q.items) := by
      cases hd2 with
      | cons hdi2 hnil => rw [← hm]; exact branch_canonical (hf.code.fp hfp) hdi2
    have hxr : x'.rip = addrAt S.ctx (p + codeSize q.items) := by
      rw [hrip', hrip, addrAt_add]; rfl
    simp only [BrOk, Option.map_some] at hbr
    obtain ⟨neg, t, b, hctl, heval, hpc⟩ := hbr
    have htgt : posOf S.r t = tgt.toNat :=
      inline_branch_index (inline_targets hdi) hops hctl
    have hexec : (Item.branch cond tgt long).exec S.ctx x' = .ok (x'.jump
        (if b then S.ctx.base + tgt.setWidth 64
          else x'.rip + BitVec.ofNat 64 (Item.branch cond tgt long).size)) := by
      cases b <;> simp [Item.exec, State.jump, heval, bind, Except.bind, pure, Except.pure]
    refine Reach.steps hsteps (.step (.exec _ _ hcan hcode'.2.1 hxr hexec)
      (.done (.inl ⟨s', .step hstep, (rbInv_region hinR').2 ⟨e, hinv.congr rfl rfl, ?_⟩⟩)))
    cases b with
    | false =>
      simp only [Bool.false_eq_true, ↓reduceIte] at hpc ⊢
      refine .inl ⟨?_, ?_⟩
      · show x'.rip + _ = _
        rw [hpc, hs, hstop, hcpos, hxr, ← addrAt_add, codeSize_append, codeSize_cons,
          codeSize_nil, Nat.add_zero, Nat.add_assoc]
      · rw [hpc, hs, hP.cache]; exact hcc
    | true =>
      simp only [↓reduceIte] at hpc ⊢
      refine .inr ⟨?_, ?_⟩
      · show _ = addrAt S.ctx _
        rw [hpc, htgt]
        simp only [addrAt]
        congr 1
        apply BitVec.eq_of_toNat_eq
        simp
      · rw [hpc]
        have hmemt : posOf S.r t ∈ S.r.protos[k].targets := by
          rw [hpk']
          simp only [Proto.targets, hh, List.append_nil, List.mem_flatMap]
          refine ⟨.target (posOf S.r t), ?_, by simp [Opnd.targetsOf]⟩
          rw [← hops]
          exact List.mem_map_of_mem (nativeCtl_target hctl)
        have := H.cacheTargets k hk _ hmemt
        unfold Setup.used
        rw [ite_eq_left_iff.mpr (fun h => absurd this h)]
        exact CacheInv.empty _

set_option maxHeartbeats 1000000 in
/-- PE-T4.2: a dense switch in PE's pad region (as `bodySim_denseB`, frame-pointer form; R's
frame on the ghost state `RegionInv.ghost`, moved back by `FrameCore.congr`). -/
theorem regionSim_dense (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : (denseSwitch S.frR).run cur = .ok (some q, c')) (htable : HdlTables S) :
    RegionSimB S k p := by
  intro e s x hs hf hrip hsafe
  have hpeM := region_pe hP.inR
  have hsp : S.body.spFrame = none := hD.spFrame_of_fp (vt_fp_of_pe hD.modeValid hpeM)
  -- The ghost frame state (the body's `rsp`): `FrameInv` there.
  have hfg := RegionInv.ghost hD hf
  have hgr : ∀ i : Fin 16, i ≠ Reg.rsp.idx →
      (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).regs i = x.regs i := fun i hi => by
    simp only [X86.State.setReg, if_neg hi]
  have hcur := noArg_insn hn (InsnRead.dense (ro := S.ro) hr)
  subst hcur
  obtain ⟨w, sl, base, n, its, at_, tb, pE, args, es, hden, hq, hargs, hd1, hd2, hes⟩ :=
    dense_read hr
  subst hq
  have hargs' : denseArgs S.fr (denseOp w) sl base n = some args := by
    rw [show S.frR = ⟨S.r.frameSize, S.c.mode, true⟩ from rfl, dense_args_eq] at hargs
    rw [show S.fr = ⟨S.r.frameSize, S.c.mode, false⟩ from rfl, dense_args_eq]
    exact hargs
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFactsR_insnOf hP (by
    show denseOp w ≠ .resume
    cases w <;> decide)
  simp only [InsnOf] at hio
  obtain ⟨t', rfl, ht'⟩ := hio
  obtain ⟨rs', rfl, hmap⟩ := thenMap_table ht'
  have hik := hi
  rw [← hs] at hi
  have hres : denseOp w ≠ .resume := by cases w <;> decide
  have hun : denseOp w ≠ .unreachable := by cases w <;> decide
  obtain ⟨s1, vals, hsc, hu, hno, hsucc⟩ := handler_rside hi hsafe hres hun
  have hfb := H.frameBounds
  obtain ⟨hr1, -⟩ := memRel_foldlM _ (hfb.scope_size _) hf.rrel hf.mem hsc
  obtain ⟨ch, hop⟩ := dense_opSem hargs' hu hr1.rel hno
  generalize hI : Dense.denseIdx w (x.memW w (x.ea (M.frame sl))) base n = idx at hop
  obtain ⟨st'', pc, hcl, hpc, hstep⟩ := hsucc ch _ _ hop
  obtain ⟨j, hj, hget⟩ := hdl_succ_table hpc
  cases hj
  obtain ⟨hil, -⟩ := List.getElem?_eq_some_iff.1 hget
  have hlen' : rs'.length = es.length := by
    have := congrArg List.length hmap
    simpa using this
  have hi2 : idx < es.length := hlen' ▸ hil
  have hpe : posOf S.r pc = es[idx].toNat := by
    have h1 : (rs'.map (posOf S.r))[idx]? = (es.map (·.toNat))[idx]? := by rw [hmap]
    rw [List.getElem?_map, List.getElem?_map, hget, List.getElem?_eq_getElem hi2] at h1
    simpa using h1
  have htg : es[idx].toNat ∈ S.r.protos[k].targets := by
    rw [hpk]
    simp [Proto.targets, R.Then.targets] <;> exact ⟨es[idx], List.getElem_mem hi2, rfl⟩
  have hnl : ¬ LeadArg S pc := H.argsUntargeted hD k hlt _ htg pc hpe
  -- The successor is in the region (`noCross`).
  obtain ⟨hk', hie⟩ := Array.getElem?_eq_some_iff.1 hik
  have hjlt : pc < S.r.protos.size :=
    reducedOf_targets_lt hD.reduced k hk' pc (by
      rw [hie]; exact List.mem_of_getElem? hget)
  have hinR' : S.c.inRegion pc = true :=
    (hD.region.noCross k hlt _ htg pc hjlt hpe).trans hP.inR
  -- The table in memory.
  obtain ⟨htb, hbtb, hes31⟩ :=
    htable (atPos (atPos S.body p) at_) tb pE es k rfl rfl rfl (Dec.at_iff.2 hd2) hes
      (List.ne_nil_of_length_pos (by omega)) hlt (fun e0 he0 => by
        rw [hpk]
        simp [Proto.targets, R.Then.targets] <;> exact ⟨e0, he0, rfl⟩)
  have htab : CodeAt S.ctx x.mem (es.map (Item.tableEntry tb)) tb.toNat :=
    entries_codeAtF hf.code hes hbtb
  -- The machine (frame-pointer form): the index computation and the table jump.
  subst hI
  have hlk : LinkOk S.ctx x.mem (atPos S.body p) S.rs :=
    ⟨hf.code.fields, hf.code.sorted, hf.code.loaded, hf.code.small, hsp⟩
  obtain ⟨hca, -, -⟩ := hlk.dec (hd1.append hd2) hP.bound
  have hcan : Canon (its ++ Switch.switchItems tb) p :=
    (canon_append _ _ _).2 ⟨handler_canon_of (Dense.dense_items_canonical hden),
      dense_switch_canon _ _⟩
  obtain ⟨x'', hst, -, hrip'', hmem, -, y, -, hky, hex⟩ :=
    Dense.dense_switch_steps (ctx := S.ctx) hden hcan hca hrip htab hi2 htb hes31
  have hreg : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → x''.regs i = x.regs i := fun i h0 h1 =>
    (hdl_switch_regs hex i h0 h1).trans (hky.2.2 i h0 h1)
  have hrbp : x''.reg .rbp = x.reg .rbp := by
    show x''.regs 5 = x.regs 5
    exact hreg 5 (by decide) (by decide)
  have hrsp : x''.rsp = x.rsp := by
    show x''.regs 4 = x.regs 4
    exact hreg 4 (by decide) (by decide)
  have hsv : ∀ i, Saved S.c.mode.pe i → x''.regs i = x.regs i := by
    intro i hi
    apply hreg <;> rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;> decide
  -- R's frame after the scopes and the cleared home space, on the ghost state, then moved to
  -- `x''` (same `rbp`, callee-saved registers and memory).
  have hfi := hdl_frameInv_clear H (dense_frameInv H hfg hsc hnl) (hdl_home_le H hi) hcl
  have hcore : FrameCore S { s1 with pc, st := st'' } x'' :=
    hfi.toCore.congr (hrbp.trans (hgr Reg.rbp.idx (by decide)).symm)
      (fun i hi => (hsv i hi).trans
        (hgr i (fun h4 => (Call.saved_ne hi).2.2.2 (h4.trans rfl))).symm)
      (by rw [hmem]; rfl)
  have hinv : RegionInv S e { s1 with pc, st := st'' } x'' :=
    RegionInv.next hf hcore hinR' hrbp hrsp hmem
  have hc := H.cacheTargets k hlt _ htg
  have hripT : x''.rip = addrAt S.ctx (posOf S.r pc) := by rw [hrip'', hpe]
  have hused : S.used pc = { pe := S.c.mode.pe } := by
    simp only [Setup.used, hpe, hc, ↓reduceIte]
  refine Reach.steps hst (.done (.inl ⟨_, .step hstep, ?_⟩))
  refine (rbInv_region (s := { s1 with pc, st := st'' }) hinR').2 ⟨e, hinv, .inr ⟨hripT, ?_⟩⟩
  show CacheInv (S.used pc) x''
  rw [hused]
  exact CacheInv.emptyPe _ _

set_option maxRecDepth 100000 in
/-- PE-T4.2: a `jmp` in PE's pad region (as `bodySim_jmpB`; the target is in the region,
`RegionFacts.noCross`). -/
theorem regionSim_jmp (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hop : q.op = .jmp) :
    RegionSimB S k p := by
  intro e s x hs hf hrip hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFactsR_insnOf hP (by rw [hop]; decide)
  have hb := hP.bound
  cases hr with
  | dense hds =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hds
    rw [hw] at hop
    cases w <;> exact absurd hop (by decide)
  | handler _ _ _ hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | unreachable => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | @jmp t long len hd =>
    obtain ⟨hca, -, -⟩ := hf.code.dec (Dec.single hd) hb
    simp only [List.map_cons, List.map_nil, fform_item_branch] at hca
    simp only [InsnOf] at hio
    obtain ⟨op, ops, hof, rfl, hops⟩ := hio
    obtain ⟨t', rfl, ht'⟩ : ∃ t', ops = [.target t'] ∧ posOf S.r t' = t.toNat := by
      match ops, hops with
      | [o], h =>
        cases o <;> simp [opndMap] at h
        exact ⟨_, rfl, h⟩
      | [], h => simp at h
      | _ :: _ :: _, h => simp at h
    have hf' := ofFull_jmp hof
    have hik := hi
    rw [← hs] at hi
    -- The target: in the region (`noCross`), not a leading `arg`, its cache cleared.
    have htg : t.toNat ∈ S.r.protos[k].targets := by
      rw [hpk]; simp [Proto.targets, Opnd.targetsOf]
    obtain ⟨hk', hie⟩ := Array.getElem?_eq_some_iff.1 hik
    have hj : t' < S.r.protos.size :=
      reducedOf_targets_lt hD.reduced k hk' t' (by
        rw [hie]; simp [RSucc.insnTargets, Opnd.targetsOf])
    have hinR' : S.c.inRegion t' = true :=
      (hD.region.noCross k hlt t.toNat htg t' hj ht').trans hP.inR
    have hna : ¬ LeadArg S t' := (region_not_leadArg hD (Nat.le_of_lt hj) hinR').1
    cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
    | error e =>
      exfalso
      obtain ⟨m, rfl⟩ := hsafe.1 {} e (step_scopes_err hi hsc)
      exact noNB_scopes _ _ m hsc
    | ok s1 =>
      have hsh : Full.Opcode.jmp.info.shape = .jmp := by decide
      have hstep : R.step S.c s {} = .ok (.step { s1 with pc := t' }) := by
        unfold R.step
        simp only [hi, hsc, hf', bind, Except.bind]
        rw [hsh]
        rfl
      obtain ⟨x', hx, hr', hm', hpc, hrip', hregs, hmem⟩ :=
        Shapes.jmp_step S.ctx (tgt := t) (long := long) (fun n => BitVec.ofNat 32 (posOf S.r n))
          (by simp [ht']) hi hf' hsh hf.rrel hf.mem (H.frameBounds.scope_size _) hstep
      have hex : (Item.branch .always t long).exec S.ctx x = .ok x' := by
        rw [Inline.execItems_cons] at hx
        obtain ⟨y, hy, hn⟩ := except_bind_ok hx
        cases hn; exact hy
      obtain ⟨A, hA⟩ : ∃ A : BitVec 64, A = S.ctx.base + t.setWidth 64 := ⟨_, rfl⟩
      have hbx : ∀ y : X86.State, (Item.branch .always t long).exec S.ctx y = .ok (y.jump A) := by
        intro y
        subst hA
        simp [Item.exec, Cond.eval, bind, Except.bind, pure, Except.pure, State.jump]
      have hx'e : x' = x.jump A := by
        rw [hbx] at hex
        exact (Except.ok.inj hex).symm
      subst hx'e
      have hrbp : (x.jump A).reg .rbp = x.reg .rbp := by simp [State.reg, hregs]
      have hrsp : (x.jump A).rsp = x.rsp := by simp [State.rsp, State.reg, hregs]
      have hc0 := hf.toFrameCore.congr hrbp (fun i _ => by rw [hregs]) hmem
      have hk := scopes_keeps _ hsc
      have hsep := (sep_foldlM _ (H.frameBounds.scopesIn s.pc) (H.frameBounds.window hf.win)
        hf.rrel hf.sep hsc).2
      have hcore : FrameCore S { s1 with pc := t' } (x.jump A) :=
        ⟨hr', hm', hsep.congr hrbp, hk.fp ▸ hf.win, hk.fp ▸ hf.fpF, hc0.code, hc0.ro, hc0.frame,
          (Discharge.PeStackArg.ArgSlots.scopes (s1 := s1) H.boundsOk hf.slots hsc :),
          (hf.esc.scopes hsc).of_not hna⟩
      have hinv : RegionInv S e { s1 with pc := t' } (x.jump A) :=
        RegionInv.next hf hcore hinR' hrbp hrsp hmem
      have hripT : (x.jump A).rip = addrAt S.ctx (posOf S.r t') := by
        rw [hrip', ht']
        simp only [addrAt, BitVec.ofNat_toNat]
        congr 1
      have hcT : CacheInv (S.used t') (x.jump A) := by
        have hc := H.cacheTargets k hlt t.toNat htg
        simp only [Setup.used, ht', hc, ↓reduceIte]
        exact CacheInv.emptyPe _ _
      refine .step (.exec _ p (branch_canonical_any hd) hca.1 hrip (hbx x))
        (.done (.inl ⟨_, .step hstep, ?_⟩))
      exact (rbInv_region (s := { s1 with pc := t' }) hinR').2 ⟨e, hinv, .inr ⟨hripT, hcT⟩⟩

/-- PE-T4.2: a bare `unreachable` in PE's pad region (R's step is an error, excluded by
`RSafe`; as `bodySim_unreachableB`). -/
theorem regionSim_unreachable (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hop : q.op = .unreachable) :
    RegionSimB S k p := by
  intro e s x hs _ _ hsafe
  exfalso
  obtain ⟨i, p1, ctr, hi, hio, -⟩ := protoFactsR_insnOf hP (by rw [hop]; decide)
  cases hr with
  | dense hds =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hds
    rw [hw] at hop
    cases w <;> exact absurd hop (by decide)
  | handler _ _ _ hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | jmp => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | unreachable _ =>
    simp only [InsnOf] at hio
    obtain ⟨op, ops, hof, rfl, hops⟩ := hio
    have hops' : ops = [] := List.map_eq_nil_iff.mp hops
    subst hops'
    have hf := ofFull_unreachable hof
    rw [← hs] at hi
    cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
    | error e =>
      obtain ⟨m, rfl⟩ := hsafe.1 {} e (step_scopes_err hi hsc)
      exact noNB_scopes _ _ m hsc
    | ok s1 =>
      obtain ⟨m, hm⟩ := hsafe.1 {} _ (Shapes.unreachable_step S.ctx (x := x) (ch := {}) hi hf hsc).2
      cases hm

end Ryo.Proofs.DecodeSound
