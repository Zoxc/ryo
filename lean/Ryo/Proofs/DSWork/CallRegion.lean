/-
Ryo.Proofs.DSWork.CallRegion — a call in PE's pad region (PE-T3, `regionSim_call`).

The outgoing area is on the dispatcher's stack at the region's `rsp` (R's query with the choice's
`sp`, `Uninit` stack bytes: `Call.call_query_region`), at most the shadow space
(`StackSizes.region`), so the callee's writes below `rsp + 32` miss the frame
(`Call.FrameSep.callApartR`, `RegionInv.below`) and the trampoline's return address
(`RegionInv.tramp`; `cr_kept`, `EnvApart.stackOff`). The return comes back to
`RegionInv` at `k + 1` with the same entry; an unwind at a region cleanup site re-enters the
region (`reach_regionPad`, a nested trampoline), at a catching pad lands with `rsp` the
region's, and else leaves no return (no pad: `PadsLinked`). No tail call (`region_shape`).
-/
import Ryo.Proofs.DSWork.Call
import Ryo.Proofs.DecodeSound.RegionEntry
import Ryo.Proofs.DSWork.IslandRegion

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- `call_return_at` in PE's pad region: no outgoing area written (`answer_ret_region`,
`answer_rel_region`), the result stores from the answer's state. -/
theorem cr_return_at (ctx : Ctx) {c : R.Code} {s : R.RState} {x1 x' : X86.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)} {Owned : BitVec 64 → Prop} {lo : BitVec 64} {a : R.Answer}
    {sp n : Nat}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (hreg : c.inRegion s.pc = true)
    (hcr : Call.CallReturn c.mode.pe Owned lo sp n s.world x1 x' a)
    (hr : RRel s x1) (hd : d.toInt + 16 ≤ 2 ^ 31)
    (hap : Call.CallApartR Owned lo sp n s.st x1)
    (hk : ∃ parts, R.retRegs k.toNat false = .ok parts)
    (hres : Call.ResultApart k.toNat d (s.withWorld a.world).st x') :
    ∃ s'' x'', R.answer c s a = .ok (.step s'') ∧
      execItems ctx (resultStores k.toNat d) x' = .ok x'' ∧
      RRel s'' x'' ∧ MemRel s''.st x'' ∧ s''.pc = s.pc + 1 ∧ s''.fp = s.fp ∧
      x''.rip = x'.rip + BitVec.ofNat 64 ((resultStores k.toNat d).map Item.size).sum ∧
      x''.rsp = x'.rsp ∧ x''.reg .rbp = x'.reg .rbp ∧
      (∀ i, Saved c.mode.pe i → x''.regs i = x'.regs i) ∧
      ∃ (parts : List (RetPart × R.Reg)) (regs : R.Regs), R.retRegs k.toNat false = .ok parts ∧
        parts.foldlM (init := (s.withWorld a.world).st) (fun st (q : RetPart × R.Reg) =>
          st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size)) = .ok s''.st := by
  have hrbp : x'.reg .rbp = x1.reg .rbp :=
    hcr.saved 5 (Call.saved_of_calleeSaved (by simp [CalleeSaved]))
  obtain ⟨hrel, hwf, hmr, -⟩ := Call.answer_rel_region hr hcr.toCallEnd hap hrbp
  obtain ⟨regsR, hresR, hRet⟩ := hcr.regs
  obtain ⟨parts, hp⟩ := hk
  obtain ⟨hstores, hpq, hnd⟩ := CallLemmas.retRegsS_parts hp d
  obtain ⟨lo', hi', hown, hesc, hin⟩ := hres
  obtain ⟨st2, x'', hfold, hx, hrel2, hmr2, g1, g2, -, -, -, rs2, p2⟩ :=
    CallLemmas.exec_stores ctx d regsR hd parts _ x' hpq hnd hrel hmr hwf hown hesc
      (hin parts hp) (fun q hq => by
      apply hRet
      obtain ⟨_, hfor, _⟩ := hpq q hq
      rcases hfor with ⟨_, h | h⟩ | ⟨_, h | h⟩ <;> rw [h] <;> simp [ArgRet.retRegList])
  have hrbp2 : x''.reg .rbp = x'.reg .rbp := rs2 5 (by decide) (by decide) (by decide)
  refine ⟨⟨s.pc + 1, s.fp, st2, s.args⟩, x'',
    CallLemmas.answer_ret_region hi hf hsh hreg hresR hp hfold,
    by rw [hstores]; exact hx, ⟨hrel2, by rw [hrbp2, hrbp]; exact hr.rbp, ?_⟩, hmr2, rfl, rfl,
    by rw [p2, hstores], ?_, hrbp2, fun i hi' => ?_, parts, regsR, hp, hfold⟩
  · exact hwf.of_sizes g1 (SizesKept.of_escOnly g2)
  · show x''.regs 4 = x'.regs 4
    exact rs2 4 (by decide) (by decide) (by decide)
  · obtain ⟨h0, h2, h11, -⟩ := Call.saved_ne hi'
    exact rs2 i h0 h2 h11

/-- `call_unwind_at_rbp` in PE's pad region. -/
theorem cr_unwind_at {c : R.Code} {s : R.RState} {x1 x' : X86.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)} {Owned : BitVec 64 → Prop} {lo : BitVec 64} {sp n : Nat}
    {a : R.Answer} {exc : ThinPointer} {pad : Nat} {cat : Bool}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (hreg : c.inRegion s.pc = true)
    (hres : a.result = .unwind exc)
    (hce : Call.CallEnd Owned lo sp n s.world x1 x' a)
    (hrbp : x'.reg .rbp = x1.reg .rbp) (hr : RRel s x1)
    (hap : Call.CallApartR Owned lo sp n s.st x1)
    (hpad : c.cleanupAt s.pc = some (some pad, cat)) :
    R.answer c s a = .ok (.step ⟨pad, s.fp,
        { (s.withWorld a.world).st with exception := exc }, s.args⟩) ∧
      RRel ⟨pad, s.fp, { (s.withWorld a.world).st with exception := exc }, s.args⟩ x' ∧
      MemRel (s.withWorld a.world).st x' := by
  obtain ⟨hrel, hwf, hmr, -⟩ := Call.answer_rel_region hr hce hap hrbp
  exact ⟨CallLemmas.answer_unwind_region hi hf hsh hreg hres hpad,
    ⟨Call.rel_exc exc hrel, by rw [hrbp]; exact hr.rbp, ⟨hwf.idLt, hwf.idInj, hwf.size, hwf.disj⟩⟩,
    hmr⟩

/-- The frame separation after a region call's answer: only the result parts are written. -/
theorem cr_sep_answer (H : Hyps S) {st1 st2 : OpSem.State} {y : X86.State} {d : BitVec 32}
    {k : Nat} {parts : List (RetPart × R.Reg)} {regs : R.Regs}
    (hs : FrameSep (-(S.F : Int)) S.K st1 y)
    (hdb : -(S.F : Int) ≤ d.toInt ∧ d.toInt + 16 ≤ S.K)
    (hp : R.retRegs k false = .ok parts)
    (hfold : parts.foldlM (init := st1) (fun st (q : RetPart × R.Reg) =>
      st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size)) = .ok st2) :
    FrameSep (-(S.F : Int)) S.K st2 y := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  obtain ⟨-, hpq, -⟩ := CallLemmas.retRegsS_parts hp d
  exact foldlM_inv (fun st => FrameSep (-(S.F : Int)) S.K st y)
    (fun q : RetPart × R.Reg => q.1.off + q.1.size ≤ 16)
    (fun st (q : RetPart × R.Reg) =>
      st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size))
    (fun st q st' hP hQ hst => island_sep_writeFrame hP hst (by omega)
      (by have := List.length_take_le q.1.size (regs.get q.2); omega))
    parts st1 st2 hs (fun q hq => (hpq q hq).2.2) hfold

/-- `call_kept_callee` with `CodeOff` for `CodeApart`'s allocation clause (no `BInv`): for the
pad region's ghost state. -/
theorem call_kept_co (H : Hyps S) {s s1 s' : R.RState} {x : X86.State} (hf : FrameInv S s x)
    (hco : CodeOff S s)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hsh : AllocShape s1.st.mem s'.st.mem) (hesc : s'.st.escaped = s1.st.escaped)
    (hsep' : FrameSep (-(S.F : Int)) S.K s'.st x) (n : Nat) (hn : n ≤ S.F)
    (b : BitVec 64) (hb : IslandKept S x b) :
    ¬ InStack S.lo x.rsp b ∧
      ¬ Call.CallMayWrite S.Owned S.lo (s.fp - S.F) n s'.world b := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hwin : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  have hfb := H.frameBounds
  have hrsp0 := island_rsp_toNat hf.rrel.rbp (by omega) hfpF hf.rsp
  have hrbp : x.reg .rbp = BitVec.ofNat 64 s.fp := hf.rrel.rbp
  have hW : ∀ o, S.winAddr o = BitVec.ofNat 64 s.fp + BitVec.ofInt 64 o := fun o => by
    rw [← hf.fpAddr_eq]; simp [fpAddr, hrbp]
  have hx0 : S.x0.rsp.toNat = s.fp + 8 := by
    have h0 : S.x0.rsp = x.reg .rbp + 8 := by have := hf.frame.rbp; bv_omega
    have h8 : (8 : BitVec 64).toNat = 8 := rfl
    rw [h0, hrbp, BitVec.toNat_add, BitVec.toNat_ofNat, h8,
      Nat.mod_eq_of_lt (show s.fp < 2 ^ 64 by omega)]
    omega
  have hspn : (BitVec.ofNat 64 (s.fp - S.F + n)).toNat = s.fp - S.F + n := by
    rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
  rcases call_kept_cases H hb with hcode | ⟨o, ho1, ho2, rfl⟩
  · obtain ⟨hown, hstk, hnw, -⟩ := H.codeApart b hcode
    refine ⟨fun h => hstk ⟨h.1, by have := h.2; omega⟩, ?_⟩
    rintro (h | ⟨id, al, hg, hl, hlt⟩ | h)
    · exact hstk ⟨h.1, by have := h.2; omega⟩
    · have hold : island_AllOk (fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz) s.st :=
        fun id al hg hl hlt => hco b hcode ⟨id, al, hg, hl, hlt⟩
      have hnew := island_allOk_foldlM
        (P := fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz)
        (F := S.F) (K := S.K) _ (fun off sz h1 h2 h3 hlt => by
          refine hnw (off + (b - BitVec.ofNat 64 ((s.fp : Int) + off).toNat).toNat)
            (by omega) (by omega) ?_
          rw [hW, island_ofInt_add, ← BitVec.add_assoc, ← ofNat_frameAddr _ _ h3]
          exact island_sub_toNat rfl) (hfb.scopesIn s.pc) hold hsc
      obtain ⟨a0, hg0, had, hlv, hsz⟩ := hsh id al hg
      exact hnew id a0 hg0 (hlv ▸ hl) (by rw [← had, ← hsz]; exact hlt)
    · exact hown h
  · have hoF : -(S.F : Int) ≤ o := by omega
    have hfo : (fpAddr x o).toNat = s.fp + o.toNat := by
      rw [fpAddr, hrbp, ← ofNat_frameAddr _ _ (by omega), BitVec.toNat_ofNat,
        Nat.mod_eq_of_lt (by omega)]
      omega
    obtain ⟨hesc1, -⟩ := H.linkPrivate s x s1 hf hsc o ho1 ho2
    refine ⟨fun h => by have := h.2; omega, ?_⟩
    rintro (h | ⟨id, al, hg, hlv, hlt⟩ | h)
    · have := h.2; omega
    · obtain ⟨e, hem, he1, he2, -⟩ := hsep'.own id al o hg hlv hoF (by omega) hlt
      have hesc' : s'.st.escapedAt o = none := by
        unfold OpSem.State.escapedAt at hesc1 ⊢; rw [hesc]; exact hesc1
      exact escapedAt_none hesc' e hem ⟨he1, he2⟩
    · rw [hf.fpAddr_eq] at h
      exact H.envApart.window o hoF (by omega) h


/-- What a callee called from the region leaves alone (`IslandKeptR`): off the stack below the
region's `rsp`, and not where the callee may write (its area `[rsp, rsp + n)`, `n ≤ 32`):
`call_kept_co` at the ghost state, and the trampoline's return address is above the area, in no
allocation (`island_allocs'` at the ghost) and not runtime-owned (`EnvApart.stackOff`). -/
theorem cr_kept (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {e : X86.State} {s s1 s' : R.RState} {x : X86.State} (hR : RegionInv S e s x)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hsh : AllocShape s1.st.mem s'.st.mem) (hesc : s'.st.escaped = s1.st.escaped)
    (hsep' : FrameSep (-(S.F : Int)) S.K s'.st x) (n : Nat) (hn : n ≤ 32)
    (b : BitVec 64) (hb : IslandKeptR S x b) :
    ¬ InStack S.lo x.rsp b ∧ ¬ Call.CallMayWrite S.Owned S.lo x.rsp.toNat n s'.world b := by
  obtain ⟨hrbpN, hfp16, hx0, hbel, hroom, hfpF⟩ := rgn_nums H hR
  obtain ⟨hg5, hgsp⟩ := ir_ghost_regs (S := S) x
  have hg := hR.ghost hD
  have hF32 : 32 ≤ S.F := H.peShadow (rgn_pe hR.inR)
  have hgN : (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp.toNat = s.fp - S.F := by
    rw [hgsp]; bv_omega
  rcases hb with hb | ⟨i, hi, hbeq⟩
  · have hbg : IslandKept S (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)) b := by
      unfold IslandKept at hb ⊢; rw [hg5]; exact hb
    obtain ⟨h1, h2⟩ := call_kept_co H hg (codeOff_of_region H hR) hsc hsh hesc
      (hsep'.congr hg5) n (by omega) b hbg
    refine ⟨fun hst => h1 ⟨hst.1, by have := hst.2; omega⟩, ?_⟩
    rintro (hst | hrest)
    · refine h2 (.inl ⟨hst.1, ?_⟩)
      have h3 := hst.2
      simp only [BitVec.toNat_ofNat] at h3 ⊢
      omega
    · exact h2 (.inr hrest)
  · have hbN : b.toNat = x.rsp.toNat + 40 + i := by rw [hbeq]; bv_omega
    refine ⟨fun hst => by have := hst.2; omega, ?_⟩
    rintro (hst | ⟨id, al, hga, hlv, hlt⟩ | ho)
    · have h3 := hst.2
      simp only [BitVec.toNat_ofNat] at h3
      omega
    · obtain ⟨a0, hg0, had, hlv0, hsz⟩ := hsh id al hga
      have hA := island_allocs' H hg hsc
      generalize hd : (b - BitVec.ofNat 64 al.addr).toNat = d at hlt
      have hb' := island_sub_toNat hd
      apply hA id a0 hg0 (hlv0 ▸ hlv) d (by rw [← hsz]; exact hlt)
      rw [← had, BitVec.ofNat_add, ← hb', hgsp]
      show S.lo.toNat ≤ b.toNat ∧ b.toNat < (x.reg .rbp - BitVec.ofNat 64 S.F).toNat
      refine ⟨by omega, ?_⟩
      bv_omega
    · exact H.envApart.stackOff b ⟨by omega, by omega⟩ ho

/-- `call_kept_off` for `IslandKeptR`: the trampoline's slot is below the window. -/
theorem cr_kept_off (H : Hyps S) {e : X86.State} {s : R.RState} {x : X86.State}
    (hR : RegionInv S e s x)
    {D : Int} {n : Nat} (hD : -(S.F : Int) ≤ D) (hDK : D + n ≤ S.K) (hoff : D + n ≤ 0 ∨ 16 ≤ D)
    (b : BitVec 64) (hb : IslandKeptR S x b) : n ≤ (b - fpAddr x D).toNat := by
  rcases hb with hb | ⟨i, hi, hbeq⟩
  · exact call_kept_off H hR.toFrameCore hD hDK hoff b hb
  · rcases Nat.eq_zero_or_pos n with rfl | hn0
    · exact Nat.zero_le _
    obtain ⟨hrbpN, hfp16, -, hbel, -, hfpF⟩ := rgn_nums H hR
    have hwin := hR.win
    have hbN : b.toNat = x.rsp.toNat + 40 + i := by rw [hbeq]; bv_omega
    have hfa : (fpAddr x D).toNat = ((s.fp : Int) + D).toNat :=
      HandlerStackArg.fpAddr_toNat hR.rrel.rbp (by omega) (by omega)
    rw [BitVec.toNat_sub, hfa]
    omega

/-- `call_stores_steps_core` in the region, keeping `IslandKeptR` (the trampoline's slot too). -/
theorem cr_stores_steps (H : Hyps S) {e : X86.State} {s : R.RState} {x y y' : X86.State} {k : Nat}
    {d : BitVec 32} {parts : List (RetPart × R.Reg)} {q0 : Nat} (hR : RegionInv S e s x)
    (hp : R.retRegs k false = .ok parts) (hdb : -(S.F : Int) ≤ d.toInt ∧ d.toInt + 16 ≤ S.K)
    (hoff : ∀ q ∈ parts, OffLink (d.toInt + q.1.off, q.1.size))
    (hca : CodeAt S.ctx y.mem (resultStores k d) q0)
    (hinC : ∀ b, InCode S.ctx (resultStores k d) q0 b → IslandKeptR S x b)
    (hrip : y.rip = addrAt S.ctx q0) (hrb : y.reg .rbp = x.reg .rbp)
    (he : execItems S.ctx (resultStores k d) y = .ok y') :
    Steps S.ctx y y' ∧ y'.rip = addrAt S.ctx (q0 + codeSize (resultStores k d)) ∧
      ∀ b, IslandKeptR S x b → y'.mem b = y.mem b := by
  obtain ⟨hst, hpq, -⟩ := CallLemmas.retRegsS_parts hp d
  have hKl := H.frameBounds.K_le
  have hdb' := toInt_bounds d
  have hmem : ∀ i ∈ resultStores k d, ∃ q ∈ parts,
      ArgItemForm (d + BitVec.ofNat 32 q.1.off) q.1.size i ∧
      (d + BitVec.ofNat 32 q.1.off).toInt = d.toInt + q.1.off ∧ 1 ≤ q.1.size ∧
      q.1.off + q.1.size ≤ 16 := by
    intro i hi
    rw [hst, List.mem_flatMap] at hi
    obtain ⟨⟨pp, rr⟩, hq, hi⟩ := hi
    obtain ⟨hok, hfor, hle⟩ := hpq _ hq
    simp only at hok hfor hle
    have h1 : 1 ≤ pp.size := by unfold CallLemmas.partOkS at hok; split at hok <;> omega
    exact ⟨(pp, rr), hq, call_storeR_form hok hfor i hi,
      CallLemmas.toInt_disp d pp.off (by omega) (by omega), h1, hle⟩
  have hcan : Canon (resultStores k d) q0 := call_canon_list (fun i hi pos => by
    obtain ⟨q, -, hform, -⟩ := hmem i hi
    exact arg_item_canonical hform pos) q0
  have hrun : FetchRun S.ctx (IslandKeptR S x) (resultStores k d) y :=
    arg_fetchRun (fun z => z.reg .rbp = x.reg .rbp) (fun i hi z z' hz hez => by
      obtain ⟨q, hq, hform, hdisp, h1, hle⟩ := hmem i hi
      have hoffq := hoff q hq
      obtain ⟨r1, r2, r3⟩ := arg_item_exec S.ctx hform (by rw [hdisp]; omega) (by omega) hez
      refine ⟨r1, fun b hb => r3 b ?_, r2.trans hz⟩
      have e : fpAddr z (d + BitVec.ofNat 32 q.1.off).toInt =
          fpAddr x (d.toInt + q.1.off) := by simp [fpAddr, hz, hdisp]
      rw [e]
      exact cr_kept_off H hR (by omega) (by omega) hoffq b hb) y hrb
  exact steps_of_run hcan hca hrip hinC hrun he


set_option maxHeartbeats 2000000 in
/-- PE-T3: a call in PE's pad region. -/
theorem regionSim_call (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : (callInsn S.frR (S.dr k)).run cur = .ok (some q, c')) :
    RegionSimB S k p := by
  intro e s x hs hR hrip hsafe
  have hcur := noArg_call hn hr
  subst hcur
  have hpe : S.c.mode.pe = true := rgn_pe hP.inR
  have hfp : S.c.mode.framePointer = true := vt_fp_of_pe hD.modeValid hpe
  have hlk : LinkOk S.ctx x.mem (atPos S.body p) S.rs := bs_linkOk_at (hR.code.toLinkOk hfp) p
  have eF : (S.F : Int) = S.c.d.frameSize := rfl
  have eF' : S.F = S.c.d.frameSize := rfl
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hR.win
  have hwin := hfb.window hwinT
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hFl := hfb.F_le
  have hKl := hfb.K_le
  have hfpF : S.F ≤ s.fp := hR.fpF
  have hfp64 : s.fp < 2 ^ 64 := by omega
  obtain ⟨hrbpN, hfp16, hx0, hbel, hroom, -⟩ := rgn_nums H hR
  obtain ⟨hlt, ⟨p1, ctr, hpq⟩, ⟨i, hi, hio⟩, hbd, hnop, hcache, hinR⟩ := hP
  have hpk0 := (Array.getElem?_eq_some_iff.1 hpq).2
  cases call_read_site hr with
  | @call f fo pre ps ci ws d kk p3 n c'' hhead hd hn1 hd2 hc' hps hk32 hrax =>
    have hfnr : f ≠ .resume := by
      rcases call_head_cases hhead with ⟨_, rfl, -, -, -⟩ | ⟨_, rfl, -, -, -⟩ |
        ⟨_, rfl, -, -, -⟩ | ⟨_, rfl, -, -, -⟩ <;> decide
    have hpk := hpk0.trans (rgn_fixResume_ne hfnr)
    have hio' := hpk ▸ hio hlt
    -- The instruction.
    simp only [InsnOf] at hio'
    obtain ⟨op, ops, hof, rfl, hops⟩ := hio'
    obtain ⟨hf, hsh, hfoT, -, -⟩ := call_head_op hhead hof
    have hops' : ops = [.slot d, fo, .imm (BitVec.ofNat 64 kk), .words ws] :=
      opnds_plain hops (by
        intro o ho
        simp only [List.mem_cons, List.not_mem_nil, or_false] at ho
        rcases ho with rfl | rfl | rfl | rfl
        · rfl
        · exact hfoT
        · rfl
        · rfl)
    subst hops'
    have hkk : (BitVec.ofNat 64 kk).toNat = kk := by
      rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
    have hxok : ∀ it ∈ ps, XmmOk it := fun it hit => hd.xmmOk it (by simp [hit])
    have hpsOk : Call.paramItems S.c.mode.pe ws = some ps := hps hxok
    have hseq : Call.callSeq S.c.mode.pe f fo ws = some (pre ++ ps ++ [ci]) := by
      simp [Call.callSeq, hhead, hpsOk, bind, Option.bind, pure]
    -- The code.
    have hdA : Dec (atPos S.body p) p (pre ++ ps ++ [ci]) (p3 + n) := hd.append (Dec.single hn1)
    obtain ⟨hca, hq3, hb3⟩ := hlk.dec hdA hbd
    have hn0 : 0 < n := by
      obtain ⟨-, hq3', -⟩ := hlk.dec hd hbd
      have e1 := codeSize_append (pre ++ ps) [ci]
      have e2 : codeSize [ci] = ci.size := by simp [codeSize]
      have epos : (atPos S.body p).pos = p := rfl
      have := (call_head_op hhead hof).2.2.2.2
      omega
    -- R's step, for the outgoing area at the region's `rsp`.
    rw [← hs] at hi
    have hreg : S.c.inRegion s.pc = true := by rw [hs]; exact hinR
    obtain ⟨qq, s', hstep⟩ := call_step_ext_region hi hf hsh hreg hsafe x.rsp.toNat
    have hsafeQ := hsafe.2 _ qq s' hstep
    obtain ⟨s1, parts, -, -, hsc, hp, -, -, hsret, hpc', hfp', -, -⟩ :=
      CallLemmas.step_call_region hi hf hsh hreg hstep
    have hk1 := scopes_keeps _ hsc
    have hpcS : s'.pc = s.pc := hpc'.trans hk1.pc
    have hfpS : s'.fp = s.fp := hfp'.trans hk1.fp
    have hsep1 := (sep_foldlM _ (hfb.scopesIn _) hwin hR.rrel hR.sep hsc).2
    have hS' : FrameSep (-(S.F : Int)) S.K s'.st x ∧ AllocShape s1.st.mem s'.st.mem ∧
        s'.st.escaped = s1.st.escaped := by
      rcases hsret with heq | ⟨nn, dst, hw⟩
      · rw [heq]; exact ⟨hsep1, fun id a h => ⟨a, h, rfl, rfl, rfl⟩, rfl⟩
      · exact call_sep_uninit hsep1 hw
    obtain ⟨hsep', hshp, hesc'⟩ := hS'
    have hslots1 := Discharge.PeStackArg.ArgSlots.scopes H.boundsOk hR.slots hsc
    have hslots' : Discharge.PeStackArg.ArgSlots S.c s'.st := by
      rcases hsret with heq | ⟨nn, dst, hw⟩
      · rw [heq]; exact hslots1
      · exact hslots1.writeFrame_uninit hw
    have hap : Handler.StackApart S.lo s'.st x :=
      Handler.FrameSep.stackApart hsep'
        (Handler.stack_off_window (by rw [hrbpN]; omega) (by rw [hrbpN]; omega))
        (call_allocsApart_shape (ir_allocs hD H hR hsc) hshp)
    have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by omega
    obtain ⟨cal, regs, x1, hq, hx1, he1, hrr1, -, -, -, -, hrsp1, hret1, hsv1, hmem1⟩ :=
      Call.call_query_region S.ctx hi hf hsh hreg hseq hrax hR.rrel hR.mem (hfb.scope_size _)
        hlo (H.envApartR.syms e s x hR) hstep hap
    have hrbp1 : x1.reg .rbp = x.reg .rbp := by
      show x1.regs 5 = x.regs 5; exact hsv1 5 (Island.saved_rbp _)
    -- Fetching the call.
    have hcanon : Canon (pre ++ ps ++ [ci]) p := call_canon_list (fun it hit pos => by
      rcases List.mem_append.1 hit with hit | hit
      · rcases List.mem_append.1 hit with hit | hit
        · exact (call_head_canon hhead).1 it hit pos
        · exact call_paramItems_canon hpsOk it hit pos
      · simp only [List.mem_singleton] at hit; subst hit; exact (call_head_canon hhead).2 pos) p
    have hshapes : ∀ it ∈ pre ++ ps, it.FallsThrough S.ctx ∧ it.MemKept S.ctx := by
      intro it hit
      refine call_shape_ok S.ctx ?_
      rcases List.mem_append.1 hit with hit | hit
      · rcases call_head_cases hhead with ⟨_, -, -, rfl, -⟩ | ⟨_, -, -, rfl, -⟩ |
          ⟨_, -, -, rfl, -⟩ | ⟨_, -, -, rfl, -⟩
        · cases hit
        · cases hit
        · simp only [List.mem_singleton] at hit; subst hit; exact .inr (.inr ⟨_, _, rfl⟩)
        · simp only [List.mem_singleton] at hit; subst hit; exact call_ldFrame_shape _
      · exact call_paramItems_shape hpsOk it hit
    have hsteps1 : Steps S.ctx x x1 :=
      steps_of_run_last (S := fun _ => True) hcanon hca hrip (fun _ _ => trivial)
        (fetchRun_of_forall hshapes x) hx1
    -- The callee.
    have hstkR : S.c.stackSize s.pc ≤ 32 := H.stackSizes.region s.pc op _ f hi hf hsh hreg
    have hsafeQ' : S.Safe ⟨.call cal regs x.rsp.toNat
        (List.replicate (S.c.stackSize s.pc) .uninit), s'.world⟩ := hq ▸ hsafeQ
    have hshad : S.c.mode.pe = true →
        32 ≤ (List.replicate (S.c.stackSize s.pc) AbstractByte.uninit).length := fun hpe => by
      rw [List.length_replicate]; exact H.stackSizes.shadow hpe s.pc op _ f hi hf hsh
    have hcaX : Call.CallApartR S.Owned S.lo x.rsp.toNat (S.c.stackSize s.pc) s'.st x :=
      Call.FrameSep.callApartR hsep' hwin (by omega) hR.rrel.rbp hfpF
        (fun o h1 h2 => by rw [ir_fpAddr hR.toFrameCore]; exact H.envApart.window o h1 h2)
        (by omega)
    have hcaX1 : Call.CallApartR S.Owned S.lo x.rsp.toNat (S.c.stackSize s.pc) s'.st x1 :=
      fun o h1 h2 he hu => by
        rw [show fpAddr x1 o = fpAddr x o by simp [fpAddr, hrbp1]]
        exact hcaX o h1 h2 he hu
    have hkept := cr_kept hD H hR hsc hshp hesc' hsep' (S.c.stackSize s.pc) hstkR
    have hdb := hfb.result s.pc op d fo _ ws f hi hf hsh
    have hi' : S.c.d.insns[s'.pc]? = some (.native op [.slot d, fo, .imm (BitVec.ofNat 64 kk),
        .words ws]) := by rw [hpcS]; exact hi
    have hreg' : S.c.inRegion s'.pc = true := by rw [hpcS]; exact hreg
    have hra : x1.mem.read64 x1.rsp = addrAt S.ctx (p3 + n) := by
      rw [hret1, hrip, hq3, addrAt_add]; rfl
    have htramp : ∀ y : X86.State, (∀ b, IslandKeptR S x b → y.mem b = x.mem b) →
        y.mem.read64 (x.rsp + 40) = e.mem.read64 e.rsp := fun y hm => by
      rw [island_read64_kept (fun i hi => hm _ (.inr ⟨i, hi, rfl⟩))]; exact hR.tramp
    refine Reach.steps hsteps1 (Reach.env (H.envOutside.call _ _ _ _ _ _ he1) fun y hy => ?_)
    have hsa := H.sepAcross.call cal regs x.rsp.toNat _ s'.st x1 y x he1 hsafeQ' hshad hsep'
    by_cases hry : y.rip = x1.mem.read64 x1.rsp
    · -- It returns.
      obtain ⟨a', hcr, hal⟩ := hsa.1 ⟨hy, hry⟩
      rw [List.length_replicate] at hcr
      have hrbpY : y.reg .rbp = x.reg .rbp := by
        show y.regs 5 = x.regs 5; rw [hcr.saved 5 (Island.saved_rbp _)]; exact hrbp1
      have hsepW : FrameSep (-(S.F : Int)) S.K (s'.withWorld a'.world).st y :=
        FrameSep.extend hsep' hrbpY rfl hal.1 hsep'.init hal.2.1 hal.2.2
      have hresA : Call.ResultApart (BitVec.ofNat 64 kk).toNat d (s'.withWorld a'.world).st y :=
        call_resultApart' H hi hf hsh hsepW
      have hcr' : Call.CallReturn S.c.mode.pe S.Owned S.lo x.rsp.toNat
          (S.c.stackSize s'.pc) s'.world x1 y a' := by rw [hpcS]; exact hcr
      have hmemKy : ∀ b, IslandKeptR S x b → y.mem b = x.mem b := fun b hb => by
        obtain ⟨h1, h2⟩ := hkept b hb
        rw [hcr.mem b h2, hmem1 b h1]
      have hmemK : ∀ b, IslandKept S x b → y.mem b = x.mem b := fun b hb => hmemKy b (.inl hb)
      have hlky := island_link_kept (hR.code.toLinkOk hfp) hmemK
      have hlk' : LinkOk S.ctx y.mem (atPos S.body p) S.rs := bs_linkOk_at hlky p
      obtain ⟨s'', x'', hans, hx'', hrr'', hmr'', hpc'', hfp'', hrip'', hrsp'', hrbp'', hsv'',
          parts', regsR, hp', hfold⟩ :=
        cr_return_at S.ctx hi' hf hsh hreg' hcr' hrr1 (by omega)
          (by rw [hpcS]; exact hcaX1) ⟨parts, hp⟩ hresA
      have hoff := hfb.resultOff s.pc op d fo _ ws f hi hf hsh parts hp
      rw [hkk] at hp hx''
      have hyrip : y.rip = addrAt S.ctx (p3 + n) := by rw [hry, hra]
      obtain ⟨hca2, hcpos, hbE⟩ := hlk'.dec hd2 hb3
      obtain ⟨hsteps2, hrip2, hmem2⟩ := cr_stores_steps H hR hp hdb hoff hca2
        (fun b hb => by
          obtain ⟨j, hj, rfl⟩ := call_dec_inCode hlk' hd2 hb3 b hb
          exact .inl (.inl ⟨j, hj, rfl⟩)) hyrip hrbpY hx''
      have hmemKR'' : ∀ b, IslandKeptR S x b → x''.mem b = x.mem b :=
        fun b hb => (hmem2 b hb).trans (hmemKy b hb)
      have hmemK'' : ∀ b, IslandKept S x b → x''.mem b = x.mem b :=
        fun b hb => hmemKR'' b (.inl hb)
      have hsepX : FrameSep (-(S.F : Int)) S.K s''.st x'' :=
        FrameSep.congr hrbp'' (cr_sep_answer H hsepW hdb hp' hfold)
      have hrbpX : x''.reg .rbp = x.reg .rbp := hrbp''.trans hrbpY
      have hrspX : x''.rsp = x.rsp := by
        rw [hrsp'', hcr.rsp, hrsp1]; exact BitVec.sub_add_cancel _ _
      have hsvX : ∀ i, Saved S.c.mode.pe i → x''.regs i = x.regs i := fun i hi => by
        rw [hsv'' i hi, hcr.saved i hi, hsv1 i hi]
      have hpcK : s''.pc = k + 1 := by rw [hpc'', hpcS, hs]
      have hinR' : S.c.inRegion s''.pc = true := by
        rw [hpcK]; exact rgn_mono hinR (Nat.le_succ k)
      have hsl'' : Discharge.PeStackArg.ArgSlots S.c s''.st :=
        Discharge.PeStackArg.ArgSlots.parts (Discharge.PeStackArg.result_lo H.boundsOk hi hf hsh)
          regsR parts' (hslots'.congr (st' := (s'.withWorld a'.world).st) rfl
            (fun _ _ _ => rfl)) hfold
      have hNL : ¬ LeadArg S s''.pc :=
        (region_not_leadArg hD (by rw [hpcK]; omega) hinR').1
      have hE : s''.st.escaped = s1.st.escaped := by
        rw [Discharge.EscFrom.foldlM_keep _ (fun _ _ _ h => writeFrame_escaped h) _ hfold]
        exact hesc'
      have hFC : FrameCore S s'' x'' :=
        ⟨hrr'', hmr'', hsepX, by rw [hfp'', hfpS]; exact hwinT,
          by rw [hfp'', hfpS]; exact hfpF, (island_link_kept (hR.code.toLinkOk hfp) hmemK'').toF _,
          island_ro_kept hR.ro hmemK'',
          island_frame_kept hR.frame hmemK'' hrbpX (fun i hi _ => hsvX i hi), hsl'',
          ((hR.esc.scopes hsc).of_not hNL).congr hE⟩
      have hRI : RegionInv S e s'' x'' :=
        { toFrameCore := hFC
          inR := hinR'
          entered := hR.entered
          rsp := hrspX.trans hR.rsp
          align := by rw [hrspX]; exact hR.align
          below := by rw [hrspX, hrbpX]; exact hR.below
          room := by rw [hrspX]; exact hR.room
          tramp := by rw [hrspX]; exact htramp x'' hmemKR'' }
      have fin : ∀ z : X86.State, z.regs = x''.regs → z.xmm = x''.xmm → z.mem = x''.mem →
          z.rip = addrAt S.ctx (S.start (k + 1)) → Reach S.ctx S.E (RSNext S s) z := by
        intro z hzr _ hzm hzrip
        have hzRI := hRI.congr hzr hzm
        refine .done (.inl ⟨_, .answer hstep hans,
          (rbInv_region hzRI.inR).2 ⟨e, hzRI, .inl ⟨?_, ?_⟩⟩⟩)
        · change z.rip = addrAt S.ctx (S.start s''.pc)
          rw [hpcK]; exact hzrip
        · change CacheInv (S.cache s''.pc) z
          rw [hpcK, hcache]; exact CacheInv.emptyPe _ _
      refine Reach.steps hsteps2 ?_
      have hxrip : x''.rip = addrAt S.ctx c'.pos := by rw [hrip2, hcpos]
      have hlkX := island_link_kept (hR.code.toLinkOk hfp) hmemK''
      generalize hE : S.start (k + 1) = pE at hnop fin
      generalize hC : c'.pos = pC at hnop hxrip hbE
      cases hnop with
      | none _ => exact fin x'' rfl rfl rfl hxrip
      | nop _ hby hrl =>
        obtain ⟨hit, -, -⟩ := nop_itemAt hlkX (p := pC) (n := 1) (by omega) (by omega)
          (island_nop_bytes hby) hrl hbE
        refine reach_padding (ns := [1]) (by simp) ⟨hit, trivial⟩ hxrip fun z h1 h2 h3 h4 => ?_
        refine fin z h1 h2 h3 ?_
        rw [h4]; rfl
    · -- It unwinds.
      obtain ⟨a', exc, hres, hend, hlandR, hal⟩ := hsa.2 ⟨hy, hry⟩
      rw [List.length_replicate] at hend
      have hsiteM : (p3, n) ∈ S.r.protos[k].sites := by rw [hpk]; simp
      have hpads := (H.padsLinked hD hR.code.small) k hlt (p3, n) hsiteM (p3 + n)
        (by show p3 < p3 + n; omega) (by show p3 + n ≤ p3 + n; omega)
      have hcls := (H.cleansLinked hD hR.code.small) k hlt (p3, n) hsiteM (p3 + n)
        (by show p3 < p3 + n; omega) (by show p3 + n ≤ p3 + n; omega)
      have hmemKy : ∀ b, IslandKeptR S x b → y.mem b = x.mem b := fun b hb => by
        obtain ⟨h1, h2⟩ := hkept b hb
        rw [hend.mem b h2, hmem1 b h1]
      have hmemK : ∀ b, IslandKept S x b → y.mem b = x.mem b := fun b hb => hmemKy b (.inl hb)
      have hnoPad : (S.c.mode.pe && S.cleans (x1.mem.read64 x1.rsp)) = false →
          S.padOf (addrAt S.ctx (p3 + n)) = none → False := fun hc hn' => by
        have hl := (hlandR.landed hc).rip
        rw [hra, hn'] at hl; cases hl
      cases hcl : S.c.cleanupAt k with
      | none =>
        rw [hcl] at hpads hcls
        exact (hnoPad (by rw [hra, hcls]; simp) hpads).elim
      | some pr =>
      obtain ⟨pad?, cat⟩ := pr
      cases pad? with
      | none =>
        rw [hcl] at hpads hcls
        exact (hnoPad (by rw [hra, hcls]; simp) hpads).elim
      | some pad =>
      rw [hcl] at hpads hcls
      have hpad' : S.c.cleanupAt s'.pc = some (some pad, cat) := by rw [hpcS, hs]; exact hcl
      have hend' : Call.CallEnd S.Owned S.lo x.rsp.toNat (S.c.stackSize s'.pc)
          s'.world x1 y a' := by rw [hpcS]; exact hend
      -- The frame after the unwind, from the saved registers.
      have mkCore : (∀ i, Saved S.c.mode.pe i → y.regs i = x1.regs i) →
          y.reg .rbp = x.reg .rbp ∧
          R.answer S.c s' a' = .ok (.step ⟨pad, s'.fp,
            { (s'.withWorld a'.world).st with exception := exc }, s'.args⟩) ∧
          FrameCore S ⟨pad, s'.fp, { (s'.withWorld a'.world).st with exception := exc },
            s'.args⟩ y := by
        intro hsv0
        have hrbpY1 : y.reg .rbp = x1.reg .rbp := hsv0 5 (Island.saved_rbp _)
        have hrbpY : y.reg .rbp = x.reg .rbp := hrbpY1.trans hrbp1
        obtain ⟨hans, hrrY, hmrY⟩ := cr_unwind_at hi' hf hsh hreg' hres hend' hrbpY1 hrr1
          (by rw [hpcS]; exact hcaX1) hpad'
        have hsepW : FrameSep (-(S.F : Int)) S.K (s'.withWorld a'.world).st y :=
          FrameSep.extend hsep' hrbpY rfl hal.1 hsep'.init hal.2.1 hal.2.2
        have hsvY : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i := fun i hi => by
          rw [hsv0 i hi, hsv1 i hi]
        refine ⟨hrbpY, hans, hrrY, hmrY,
          ⟨hsepW.own, hsepW.init, hsepW.dis, hsepW.space, hsepW.esc⟩,
          by show (s'.fp : Int) + _ ≤ _; rw [hfpS]; exact hwinT,
          by show S.c.d.frameSize ≤ s'.fp; rw [hfpS]; exact hfpF,
          (island_link_kept (hR.code.toLinkOk hfp) hmemK).toF _, island_ro_kept hR.ro hmemK,
          island_frame_kept hR.frame hmemK hrbpY (fun i hi _ => hsvY i hi),
          (hslots'.congr (st' := (s'.withWorld a'.world).st) rfl (fun _ _ _ => rfl)).congr
            (st' := { (s'.withWorld a'.world).st with exception := exc }) rfl
            (fun _ _ _ => rfl),
          ((hR.esc.scopes hsc).of_not (pad_not_leadArg hD hcl)).congr
            (by show s'.st.escaped = _; exact hesc')⟩
      cases cat with
      | true =>
        -- A catching pad: in the region, `rsp` the region's.
        have hland := hlandR.landed (by rw [hra, hcls]; simp)
        obtain ⟨hrbpY, hans, hFC⟩ := mkCore hland.saved
        have hrspY : y.rsp = x.rsp := by rw [hland.rsp, hrsp1]; exact BitVec.sub_add_cancel _ _
        have hyrip : y.rip = addrAt S.ctx (posOf S.r pad) := by
          have hl := hland.rip
          rw [hra, hpads] at hl
          rw [← Option.some.inj hl]
          have h32 := posOf_lt_32 hD (hR.code.toLinkOk hfp) (pad_lpad hD hcl).1
          have e : (pos32 S.r pad).setWidth 64 = BitVec.ofNat 64 (posOf S.r pad) := by
            apply BitVec.eq_of_toNat_eq
            rw [BitVec.toNat_setWidth, pos32, BitVec.toNat_ofNat, BitVec.toNat_ofNat,
              Nat.mod_eq_of_lt h32]
          rw [e]; rfl
        have hRI : RegionInv S e ⟨pad, s'.fp,
            { (s'.withWorld a'.world).st with exception := exc }, s'.args⟩ y :=
          { toFrameCore := hFC
            inR := (hD.region.catchPads k pad hcl).trans hinR
            entered := hR.entered
            rsp := hrspY.trans hR.rsp
            align := by rw [hrspY]; exact hR.align
            below := by rw [hrspY, hrbpY]; exact hR.below
            room := by rw [hrspY]; exact hR.room
            tramp := by rw [hrspY]; exact htramp y hmemKy }
        refine .done (.inl ⟨_, .answer hstep hans,
          (rbInv_region hRI.inR).2 ⟨e, hRI, .inr ⟨hyrip, ?_⟩⟩⟩)
        change CacheInv (S.used pad) y
        rw [(H.cacheCleared hD).pads k pad true hcl]; exact CacheInv.emptyPe _ _
      | false =>
        -- A cleanup pad: the dispatcher calls the region's entry again (`reach_regionPad`).
        have hPC := hlandR.padCalled (by rw [hra, hcls, hpe]; rfl)
        obtain ⟨hrbpY, hans, hFC⟩ := mkCore (fun i hi => hPC.saved i (hpe ▸ hi))
        have hbelow : x1.rsp.toNat ≤ (y.reg .rbp).toNat - S.F := by
          rw [hrbpY, hrbpN, hrsp1]
          bv_omega
        refine (reach_regionPad hD H hpe hlt hcl rfl hsiteM hra hn0 hPC hFC hbelow).mono
          fun z hz => .inl ⟨_, .answer hstep hans, hz.1⟩
  | @tail w f fo pre ps j ws c'' hhead hd hc' hps hrax =>
    have hfnr : f ≠ .resume := by
      rcases call_tail_cases hhead with ⟨_, rfl, -, -⟩ | ⟨_, rfl, -, -⟩ <;> decide
    have hpk := hpk0.trans (rgn_fixResume_ne hfnr)
    have hio' := hpk ▸ hio hlt
    simp only [InsnOf] at hio'
    obtain ⟨op, ops, hof, -, -⟩ := hio'
    obtain ⟨-, hsh, -⟩ := call_tail_op hhead hof
    exact absurd (by rw [hpk]; exact hsh) (region_shape hD hlt hinR).2

end Ryo.Proofs.DecodeSound
