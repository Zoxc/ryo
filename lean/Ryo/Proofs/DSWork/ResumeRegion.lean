/-
Ryo.Proofs.DSWork.ResumeRegion — `resume` in PE's pad region (PE-T4.3, `regionSim_resume`).

`add rsp, 40; ret` (`InsnRead.resume`): `rsp` back to the trampoline's entry `e.rsp`, `ret` to its
return address (`RegionInv.tramp`). R: `resumeSlots` made the instruction
`handler .resume [.slot x] .trap` (`S.fixResume`), whose step reads the slot and, with
`cleanupAt k = some (none, false)` (`RegionFacts.resume`), ends the function with
`.unwind exc`: `ExitRel`'s `unwind` from `FrameFacts` (the saved `rbp` and the return address,
memory unchanged by the two items). A handler-form `resume` (a call of `ryo_h_Resume`) never
returns on PE (`Hyps.resumePe`).
-/
import Ryo.Proofs.DSWork.Handler
import Ryo.Proofs.DecodeSound.Region

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink Ryo.Proofs.Scope Ryo.Proofs.ScopeMem

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- `Code.inRegion` is upward closed. -/
theorem rgn_mono {c : R.Code} {k j : Nat} (h : c.inRegion k = true) (hkj : k ≤ j) :
    c.inRegion j = true := by
  unfold R.Code.inRegion at h ⊢
  simp only [Bool.and_eq_true] at h ⊢
  obtain ⟨h1, h2⟩ := h
  refine ⟨h1, ?_⟩
  cases hr : c.d.regionStart with
  | none => rw [hr] at h2; cases h2
  | some L =>
    rw [hr] at h2
    simp only [Option.any_some, decide_eq_true_eq] at h2 ⊢
    omega

/-- The region's numbers: `rbp` is `fp` (no wrap, 16 bytes of room above), the entry's `rsp` is
`fp + 8`, and the region's 48 bytes lie below the frame and above `lo`. -/
theorem rgn_nums (H : Hyps S) {e : X86.State} {s : R.RState} {x : X86.State}
    (hR : RegionInv S e s x) :
    (x.reg .rbp).toNat = s.fp ∧ s.fp + 16 ≤ 2 ^ 64 ∧ S.x0.rsp.toNat = s.fp + 8 ∧
      x.rsp.toNat + 48 ≤ s.fp - S.F ∧ S.lo.toNat + 64 ≤ x.rsp.toNat ∧ S.F ≤ s.fp := by
  have hwin := hR.win
  have hK := H.argSizeK
  have hfp64 : s.fp + 16 ≤ 2 ^ 64 := by omega
  have hrbpN : (x.reg .rbp).toNat = s.fp := by
    rw [hR.rrel.rbp, BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
  have hfr := hR.frame.rbp
  have hb := hR.below
  have hx0 : S.x0.rsp.toNat = s.fp + 8 := by bv_omega
  refine ⟨hrbpN, hfp64, hx0, by rw [← hrbpN]; exact hb, hR.room, hR.fpF⟩

/-- In PE's pad region `pe` holds (`Code.inRegion` is false off PE). -/
theorem rgn_pe {k : Nat} (h : S.c.inRegion k = true) : S.c.mode.pe = true := by
  unfold R.Code.inRegion at h
  cases hp : S.c.mode.pe with
  | false => rw [hp] at h; cases h
  | true => rfl

/-- The region's code bytes are off the dispatcher's stack: no code address is in the PE stack
argument `[rsp + 32, rsp + 36)` of the region's `rsp` (between `lo` and the entry's `rsp`,
`CodeApart`). -/
theorem rgn_code_not_stackArg (H : Hyps S) {e : X86.State} {s : R.RState} {x : X86.State}
    (hR : RegionInv S e s x) {j : Nat} (hj : j < S.body.code.size) :
    ¬ HandlerStackArg.InStackArg x.rsp (addrAt S.ctx j) := by
  intro hin
  have hns := (H.codeApart (addrAt S.ctx j) (.inl ⟨j, hj, rfl⟩)).2.1
  have hwin := hR.win
  have hK := H.argSizeK
  have hfp64 : s.fp + 16 ≤ 2 ^ 64 := by omega
  have hrbpN : (x.reg .rbp).toNat = s.fp := by
    rw [hR.rrel.rbp, BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
  have hfr := hR.frame.rbp
  have hb := hR.below
  have hro := hR.room
  apply hns
  unfold HandlerStackArg.InStackArg at hin
  unfold Counter.InStack
  constructor <;> bv_omega

/-- `ExitRel`'s link conjuncts in the region: the saved `rbp` below the entry's `rsp` and the
return address at it (`FrameFacts`, with PE's frame pointer). -/
theorem rgn_link (hfp : S.c.mode.framePointer = true) {s : R.RState} {x : X86.State}
    (hc : FrameCore S s x) (H : Hyps S) :
    x.mem.read64 (S.x0.rsp - 8) = S.x0.reg .rbp ∧
      x.mem.read64 S.x0.rsp = S.x0.mem.read64 S.x0.rsp := by
  have hwin := hc.win
  have hK := H.argSizeK
  have hrbpN : (x.reg .rbp).toNat = s.fp := by
    rw [hc.rrel.rbp, BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
  have hfr := hc.frame.rbp
  have e1 : S.x0.rsp - 8 = x.reg .rbp := by bv_omega
  have e2 : x.reg .rbp + 8 = S.x0.rsp := by bv_omega
  refine ⟨by rw [e1]; exact hc.frame.savedRbp hfp, ?_⟩
  have h := hc.frame.retAddr
  rw [e2] at h
  exact h

/-- `S.fixResume` leaves a proto that isn't a `resume` alone. -/
theorem rgn_fixResume_ne {q : Proto} (h : q.op ≠ .resume) : S.fixResume q = q := by
  unfold Setup.fixResume
  rw [ite_eq_right_iff.mpr (fun hc => absurd (by simpa using hc) h)]

/-- `S.fixResume` of a read `resume` keeps the opcode and gives a `trap` handler form. -/
theorem rgn_fixResume {q : Proto} (hop : q.op = .resume) (hh : q.handler = some ([], .trap)) :
    (S.fixResume q).op = .resume ∧ ∃ args, (S.fixResume q).handler = some (args, .trap) := by
  unfold Setup.fixResume
  simp only [hop, show (Full.Opcode.resume == Full.Opcode.resume) = true from by decide,
    ↓reduceIte]
  split <;> first | exact ⟨hop, _, hh⟩ | exact ⟨rfl, _, rfl⟩ | exact ⟨hop, _, rfl⟩

theorem rgn_fixResume' {P q : Proto} (hpk : P = S.fixResume q) (hop : q.op = .resume)
    (hh : q.handler = some ([], .trap)) :
    P.op = .resume ∧ ∃ args, P.handler = some (args, .trap) :=
  by subst hpk; exact rgn_fixResume hop hh

/-- A handler-form `resume` in the region: the setup and `call` reach `ryo_h_Resume`'s entry,
from which the environment never returns on PE (`Hyps.resumePe`). -/
theorem rgn_resume_handler (H : Hyps S) (hpe : S.c.mode.pe = true) (hsp : S.body.spFrame = none)
    {e : X86.State} {s : R.RState} {x : X86.State} (hR : RegionInv S e s x) {p : Nat}
    (hb : Boundary S.rs p) (hrip : x.rip = addrAt S.ctx p)
    {items : List Item} {hat n len : Nat} {args : List R.Arg}
    (hd : Dec (atPos S.body p) p items hat)
    (hcall : decodeItem (atPos (atPos S.body p) hat) = some (.call (.handler n), len))
    (hnop : Full.Opcode.ofNat? n = some .resume)
    (hsetup : Handler.setupItems S.c.mode args = some items) (Q : X86.State → Prop) :
    Reach S.ctx S.E Q x := by
  have hlk : LinkOk S.ctx x.mem (atPos S.body p) S.rs :=
    ⟨hR.code.fields, hR.code.sorted, hR.code.loaded, hR.code.small, hsp⟩
  have hdc : Dec (atPos S.body p) p (items ++ [Item.call (.handler n)]) (hat + len) :=
    hd.append (Dec.single hcall)
  obtain ⟨hca, -, -⟩ := hlk.dec hdc hb
  have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by have := hR.room; omega
  have hout : ∀ x2, Handler.AtHandler S.ctx .resume x2 → Steps S.ctx x x2 →
      Reach S.ctx S.E Q x := fun x2 hat2 hs =>
    Reach.steps hs (.env (H.envOutside.handler .resume x2 hat2)
      fun y hy => absurd hy (H.resumePe hpe x2 y hat2))
  rcases HandlerStackArg.setupItems_length hsetup with hreg | ⟨-, h5⟩
  · obtain ⟨x2, hx2, hat2, -⟩ :=
      handler_call_ret (lo := S.lo) (x := x) S.ctx H.linked hnop hsetup hreg hlo
    exact hout x2 hat2 (handler_call_steps hsetup hreg hca hrip hx2)
  · obtain ⟨a0, a1, a2, a3, a4, rfl⟩ := HandlerStackArg.eq_five h5
    obtain ⟨x2, hx2, hat2, -⟩ :=
      HandlerStackArg.handler_call5 (lo := S.lo) S.ctx H.linked hpe hnop hsetup hlo
    refine hout x2 hat2 (handler_call_steps5 hpe H.linked hsetup hca hrip (fun a ha => ?_) hx2)
    obtain ⟨j, hj, rfl⟩ := hdl_inCode_dec hlk hdc hb a ha
    exact rgn_code_not_stackArg H hR hj

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
/-- PE-T4.3: `resume` in PE's pad region, either form. -/
theorem regionSim_resume (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hres : q.op = .resume) :
    RegionSimB S k p := by
  intro e s x hs hR hrip hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  have hpe : S.c.mode.pe = true := rgn_pe hP.inR
  have hfp : S.c.mode.framePointer = true := vt_fp_of_pe hD.modeValid hpe
  have hsp : S.body.spFrame = none := hD.spFrame_of_fp hfp
  have hsp' : (atPos S.body p).spFrame = none := hsp
  cases hr with
  | ret => simp only at hres; exact absurd hres (by decide)
  | unreachable => simp only at hres; exact absurd hres (by decide)
  | jmp => simp only at hres; exact absurd hres (by decide)
  | island => simp only at hres; exact absurd hres (by decide)
  | dense hd =>
    obtain ⟨w, hw⟩ := handler_dense_op hd
    rw [hw] at hres; cases w <;> exact absurd hres (by decide)
  | @handler items hat n len nn op args t sites c'' hd hcall hnop hhh hsetup hthen =>
    simp only at hres
    subst hres
    exact rgn_resume_handler H hpe hsp hR hP.bound hrip hd hcall hnop hsetup _
  | @resume len len2 hrg h1 h2 =>
  -- R: the instruction is `handler resume args trap` (`fixResume`); its step unwinds out of
  -- the function (`RegionFacts.resume`).
  obtain ⟨p1, ctr, hpq⟩ := hP.proto
  have hpk : S.r.protos[k]'hP.lt = S.fixResume _ := (Array.getElem?_eq_some_iff.mp hpq).2
  obtain ⟨hop, args, hha⟩ := rgn_fixResume' hpk rfl rfl
  obtain ⟨i, hi, hio⟩ := hP.insn
  have hio' := hio hP.lt
  simp only [InsnOf, hha] at hio'
  obtain ⟨t', rfl, ht'⟩ := hio'
  have := thenMap_trap ht'
  subst this
  rw [hop] at hi
  have hcl := hD.region.resume k hP.lt hP.inR hop
  rw [← hs] at hi
  cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    exfalso
    obtain ⟨m, rfl⟩ := hsafe.1 {} e (step_scopes_err hi hsc)
    exact handler_scopes_err hsc m rfl
  | ok s1 =>
  have hst := Shapes.step_handler (ch := {}) hi hsc
  have hE : ∀ e, R.step S.c s {} = .error e → handler_NotNB e → False := fun e h1 h2 => by
    obtain ⟨m, hm⟩ := hsafe.1 {} e h1; exact h2 m hm
  cases hv : R.view S.c.mode S.c.ρ (.handler .resume args .trap) with
  | none =>
    exfalso
    obtain ⟨msg, hmsg⟩ : ∃ msg, R.stepView S.c s1 (.handler .resume args .trap) {} =
        .error (.illFormed msg) := by
      unfold R.stepView; simp only [hv]; exact ⟨_, rfl⟩
    exact hE _ (hst.trans hmsg) (handler_illFormed_notNB _)
  | some v =>
  obtain ⟨vals, hu, rfl⟩ := handler_view hv
  have hsv := hst
  unfold R.stepView at hsv
  simp only [hv] at hsv
  simp only [show (Full.Opcode.resume == Full.Opcode.resume) = true from by decide,
    ↓reduceIte] at hsv
  split at hsv
  rotate_left
  · exact (hE (.illFormed "resume's operands") (hsv.trans rfl) (handler_illFormed_notNB _)).elim
  rename_i off
  cases hrf : s1.st.readFrame off 8 with
  | error e =>
    rw [hrf] at hsv
    exact (hE e (hsv.trans rfl) (handler_readFrame_err hrf)).elim
  | ok bs =>
  cases hap : asPtr bs with
  | error e =>
    refine (hE e (by rw [hsv, hrf]; simp only [bind, Except.bind, hap]) ?_).elim
    unfold asPtr at hap
    split at hap
    · cases hap
    · simp only [OpSem.ub, throw, throwThe, MonadExceptOf.throw, Except.error.injEq] at hap
      subst hap
      intro m h; cases h
  | ok exc =>
  have hstep : R.step S.c s {} = unwindAt S.c s1 exc := by
    rw [hsv, hrf]; simp only [bind, Except.bind, hap]
  have hk1 := scopes_keeps _ hsc
  have hpc1 : s1.pc = k := hk1.pc.trans hs
  unfold unwindAt at hstep
  rw [hpc1, hcl] at hstep
  have hstep' : R.step S.c s {} = .ok (.done (R.exit s1 (.unwind exc))) := hstep.trans rfl
  have hm1 := (memRel_foldlM _ (H.frameBounds.scope_size _) hR.rrel hR.mem hsc).2
  -- x86: `add rsp, 40` and `ret`, to the trampoline's return address.
  have hlk := hR.code.atPos p
  obtain ⟨hia1, hsz1, -, hb1⟩ := decodeItem_itemAt_F hlk hP.bound h1
  rw [hsp'] at hia1 hsz1
  have hsz1' : (Item.addRsp (BitVec.ofNat 32 peRegionAlloc)).size = len := hsz1
  obtain ⟨hia2, -, -, -⟩ := decodeItem_itemAt_F (hlk.atPos ((atPos S.body p).pos + len)) hb1 h2
  have hsp2 : (atPos (atPos S.body p) ((atPos S.body p).pos + len)).spFrame = none := hsp
  rw [hsp2] at hia2
  have h40 : (BitVec.ofNat 32 peRegionAlloc).signExtend 64 = (40 : BitVec 64) := by
    unfold peRegionAlloc; decide
  obtain ⟨x1, hx1, hx1r, hx1m, hx1rip⟩ : ∃ x1 : X86.State,
      (Item.addRsp (BitVec.ofNat 32 peRegionAlloc)).exec S.ctx x = .ok x1 ∧
      x1.rsp = x.rsp + 40 ∧ x1.mem = x.mem ∧
      x1.rip = x.rip + BitVec.ofNat 64 (Item.addRsp (BitVec.ofNat 32 peRegionAlloc)).size := by
    refine ⟨_, rfl, ?_, rfl, rfl⟩
    simp [X86.State.rsp, X86.State.reg, X86.State.setFlags, X86.State.setReg, X86.State.jump,
      addF, h40]
  obtain ⟨x2, hx2, hx2r, hx2m, hx2rip⟩ : ∃ x2 : X86.State,
      Item.ret.exec S.ctx x1 = .ok x2 ∧ x2.rsp = x1.rsp + 8 ∧ x2.mem = x1.mem ∧
      x2.rip = x1.mem.read64 x1.rsp := by
    refine ⟨_, rfl, ?_, rfl, rfl⟩
    simp [X86.State.rsp, X86.State.reg, X86.State.setReg, X86.State.jump, X86.State.pop]
  have hst1 : Step S.ctx x x1 :=
    .exec (.addRsp (BitVec.ofNat 32 peRegionAlloc)) (atPos S.body p).pos
      ⟨fun _ _ h => (by cases h), .inl rfl⟩ hia1 hrip hx1
  have hrip1 : x1.rip = addrAt S.ctx ((atPos S.body p).pos + len) := by
    rw [hx1rip, hrip, hsz1']; exact addrAt_add' _ _ _
  have hst2 : Step S.ctx x1 x2 :=
    .exec .ret ((atPos S.body p).pos + len) ⟨fun _ _ h => (by cases h), .inl rfl⟩
      (by rw [hx1m]; exact hia2) hrip1 hx2
  have hm2 : x2.mem = x.mem := hx2m.trans hx1m
  have hlink := rgn_link hfp hR.toFrameCore H
  refine .step hst1 (.step hst2 (.done (.inr ⟨_, .step hstep', ?_⟩)))
  refine ⟨Ryo.Proofs.Call.worldRel_exit _ (Shapes.memRel_congr hm2 hm1), hpe, e, hR.entered,
    ?_, ?_, by rw [hm2]; exact hlink.1, by rw [hm2]; exact hlink.2⟩
  · rw [hx2rip, hx1r, hx1m, hR.tramp]
  · rw [hx2r, hx1r, hR.rsp]; bv_omega

end Ryo.Proofs.DecodeSound
