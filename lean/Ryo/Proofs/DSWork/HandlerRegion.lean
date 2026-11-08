/-
Ryo.Proofs.DSWork.HandlerRegion — a handler call in PE's pad region (PE-T4.1,
`regionSim_handler`).

The handler's home space is at the region's `rsp + 8`, off the frame: `SepAcross.handlerAt` and
`HandlerContractB.sound` with `ho = rsp + 8 - fp` (below the window; `FrameOwn` there holds as
no live allocation is below the frame, `RegionInv.allocsOff`), then the cleared range moved to
R's `-F` (`hrel_clearHome_move`). `MayWrite` changes `[rsp + 8, rsp + 48)` (home space and
PE's fifth argument), the stack below, allocations and owned bytes: the trampoline's return
address at `rsp + 40` of the region (`RegionInv.tramp`) is above the call's `rsp + 8 + 32`
(`RegionInv.allocsOff`, `EnvApart.stackOff`). Successors stay in the region
(`RegionFacts.noCross`).
-/
import Ryo.Proofs.DSWork.Handler
import Ryo.Proofs.DecodeSound.Region
import Ryo.Proofs.DSWork.IslandRegion
import Ryo.Proofs.DSWork.InlineRegion

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- `opSem`'s relation with the home space cleared off the window (at `ho`, below `-F`) gives
the one with R's (at `-F`): the bytes cleared at `ho` are private (`hesc`) and not initialized
(`FrameInit`), so that clear changes nothing `HRel` reads; clearing at `-F` keeps `HRel`
(`Uninit` relates to anything). `hesc` is needed: `writeFrame` also clears escaped objects'
allocation bytes, which `HRel st1` then wouldn't relate. -/
theorem hrel_clearHome_move {F : Nat} {K : Int} {st' st1 st2 : OpSem.State} {x' : X86.State}
    {n : Nat} {ho : Int} (hinit : ScopeMem.FrameInit (-(F : Int)) K st')
    (hoff : ho + R.handlerHome true n ≤ -(F : Int))
    (hesc : ∀ i < R.handlerHome true n, st'.escapedAt (ho + i) = none)
    (hF : (F : Int) ≤ 2 ^ 31)
    (h1 : R.clearHome true n ho st' = .ok st1) (hr : Handler.HRel st1 x')
    (h2 : R.clearHome true n (-(F : Int)) st' = .ok st2) : Handler.HRel st2 x' := by
  have h40 : R.handlerHome true n ≤ 40 := by
    simp only [R.handlerHome, ↓reduceIte]; split <;> omega
  simp only [R.clearHome, ↓reduceIte] at h1 h2
  -- The clear at `ho` changes nothing `HRel` reads: `HRel st' x'`.
  have hst : Handler.HRel st' x' := by
    obtain ⟨hrel, hmem⟩ := hr
    unfold OpSem.State.writeFrame at h1
    rw [writeEscaped_private (fun i hi => hesc i (by rwa [List.length_replicate] at hi))] at h1
    simp only [bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h1
    subst h1
    refine ⟨⟨fun o hlo hhi b hb => ?_, hrel.layout, hrel.zeroSized⟩, hmem⟩
    have hb1 := hrel.frame o hlo hhi b
    rw [byteAt_with] at hb1
    cases he : st'.escapedAt o with
    | some e0 =>
      rw [he] at hb1
      exact hb1 hb
    | none =>
      rw [he] at hb1
      have hbf : st'.frame o = b := by
        unfold OpSem.State.byteAt at hb
        rw [he] at hb
        simpa only [pure, Except.pure, Except.ok.injEq] using hb
      by_cases hp : st'.privateIn ho
          (List.replicate (R.handlerHome true n) AbstractByte.uninit).length o = true
      · have hu : b = .uninit := by
          refine Classical.byContradiction fun hne => ?_
          have hin := hinit o he (by rw [hbf]; exact hne)
          simp only [OpSem.State.privateIn, Bool.and_eq_true, decide_eq_true_eq,
            List.length_replicate] at hp
          omega
        rw [hu]; trivial
      · apply hb1
        simp only [hp, Bool.false_eq_true, ↓reduceIte, pure, Except.pure, hbf]
  -- Clearing at `-F`.
  obtain ⟨hrel, hmem⟩ := hst
  have hbs : BytesRel (List.replicate (R.handlerHome true n) .uninit)
      (bytesAt x'.mem (fpAddr x' (-(F : Int)))
        (List.replicate (R.handlerHome true n) AbstractByte.uninit).length) := by
    rw [List.length_replicate]
    have := Ryo.Proofs.ArgRet.BytesRel.uninit
      (bytesAt x'.mem (fpAddr x' (-(F : Int))) (R.handlerHome true n))
    rwa [bytesAt_length] at this
  exact ⟨(CallLemmas.rel_writeFrame_in (fun o h1 h2 _ b hb => hrel.frame o h1 h2 b hb)
      hrel.layout hrel.zeroSized h2 (by omega) (by rw [List.length_replicate]; omega) hbs).1,
    ScopeMem.memRel_writeUninit hmem h2⟩

set_option maxRecDepth 100000 in
/-- A handler leaves the code, the rodata and the frame's link slots alone, and none is on the
stack below `rsp` (as `island_kept'`: the frame writes lie in the window, `FrameBounds.handler`,
and off the link slots, `FrameBounds.handlerOff`). -/
theorem hdl_kept_co (H : Hyps S) {s s1 : R.RState} {x x2 : X86.State} (hf : FrameInv S s x)
    (hco : CodeOff S s)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat} {vals : Operands}
    (hi : S.c.d.insns[s.pc]? = some (.handler h args t))
    (hu : R.unpack S.c.ρ h S.c.mode args = some vals)
    (hrbp2 : x2.reg .rbp = x.reg .rbp) (hrsp2 : x2.rsp.toNat ≤ x.rsp.toNat)
    (hrsp2e : x2.rsp = x.rsp - 8) (hhome : R.handlerHome S.c.mode.pe args.length ≤ S.F)
    (b : BitVec 64) (hb : IslandKept S x b) :
    ¬ Handler.MayWrite S.Owned S.lo (R.handlerHome S.c.mode.pe args.length) h vals s1.st x2 b ∧
      ¬ InStack S.lo x.rsp b := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hwin : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  have hfb := H.frameBounds
  have hFle : (S.F : Int) ≤ 2 ^ 31 := hfb.F_le
  have hKle : S.K ≤ 2 ^ 31 := hfb.K_le
  have hrsp0 : x.rsp.toNat = s.fp - S.F := island_rsp_toNat hf.rrel.rbp (by omega) hfpF hf.rsp
  have hrbp : x.reg .rbp = BitVec.ofNat 64 s.fp := hf.rrel.rbp
  have hrbpX2 : x2.reg .rbp = BitVec.ofNat 64 s.fp := hrbp2.trans hrbp
  have hW : ∀ o, S.winAddr o = BitVec.ofNat 64 s.fp + BitVec.ofInt 64 o := fun o => by
    rw [← hf.fpAddr_eq]; simp [fpAddr, hrbp]
  have hwr : WrIn (-(S.F : Int)) S.K h vals := hfb.handler s.pc h args t vals hi hu
  -- A home byte (PE's home space and stack argument, `[x2.rsp + 8, + home)`): the frame offsets
  -- `[-F, -F + home)`, below the link slots.
  have hhomeW : ∀ b, (b - (x2.rsp + 8)).toNat < R.handlerHome S.c.mode.pe args.length →
      ∃ o : Int, -(S.F : Int) ≤ o ∧ o < 0 ∧ b = fpAddr x o := by
    intro b hb
    have e8 : x2.rsp + 8 = x.rsp := by rw [hrsp2e]; exact BitVec.sub_add_cancel _ _
    rw [e8] at hb
    have hx : x.rsp = fpAddr x (-(S.F : Int)) := by
      apply BitVec.eq_of_toNat_eq
      rw [HandlerStackArg.fpAddr_toNat hrbp (o := -(S.F : Int)) (by omega) (by omega), hrsp0]
      omega
    refine ⟨-(S.F : Int) + ((b - x.rsp).toNat : Nat), by omega, by omega, ?_⟩
    calc b = x.rsp + BitVec.ofNat 64 (b - x.rsp).toNat := island_sub_toNat rfl
      _ = fpAddr x (-(S.F : Int)) + BitVec.ofNat 64 (b - x.rsp).toNat := by rw [← hx]
      _ = _ := by simp only [fpAddr, island_ofInt_add, BitVec.add_assoc]
  -- A byte off the window: in no frame write range.
  have hwr_win : ∀ b, (∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) →
      ¬ ∃ r ∈ wranges h vals, (b - fpAddr x2 r.1).toNat < r.2 := by
    rintro b hnw ⟨r, hr, hlt⟩
    have hr' := hwr r hr
    rw [Island.fpAddr_eq_lendAddr hrbpX2] at hlt
    refine hnw (r.1 + (b - Island.lendAddr s.fp r.1).toNat) (by omega) (by omega) ?_
    rw [hW, island_ofInt_add, ← BitVec.add_assoc]
    exact island_sub_toNat rfl
  -- A code or rodata byte.
  have hcode : ∀ b, ((∃ p, p < S.body.code.size ∧ b = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j))) →
      ¬ Handler.MayWrite S.Owned S.lo (R.handlerHome S.c.mode.pe args.length) h vals s1.st x2 b ∧
        ¬ InStack S.lo x.rsp b := by
    intro b hb'
    obtain ⟨hown, hstk, hnw, hal⟩ := H.codeApart b hb'
    have hst : ¬ InStack S.lo x.rsp b := hdl_inStack_lift H hf hstk
    refine ⟨?_, hst⟩
    rintro (hwb | hal1 | ho | hst2 | hh)
    · exact hwr_win b hnw hwb
    · have hold : island_AllOk (fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz) s.st :=
        fun id al hg hl hlt => hco b hb' ⟨id, al, hg, hl, hlt⟩
      have hnew := island_allOk_foldlM (P := fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz)
        (F := S.F) (K := S.K) _ (fun off sz h1 h2 h3 hlt => by
          refine hnw (off + (b - BitVec.ofNat 64 ((s.fp : Int) + off).toNat).toNat)
            (by omega) (by omega) ?_
          rw [hW, island_ofInt_add, ← BitVec.add_assoc, ← ofNat_frameAddr _ _ h3]
          exact island_sub_toNat rfl) (hfb.scopesIn s.pc) hold hsc
      obtain ⟨id, al, hg, hl, hlt⟩ := hal1
      exact hnew id al hg hl hlt
    · exact hown ho
    · exact hst ⟨hst2.1, Nat.lt_of_lt_of_le hst2.2 hrsp2⟩
    · obtain ⟨o, h1, h2, he⟩ := hhomeW b hh
      exact hnw o h1 (by omega) (he.trans (hf.fpAddr_eq o))
  rcases hb with hb | ⟨r, hr, k, hk, rfl⟩ | hb | ⟨i, hi', hb⟩
  · exact hcode b (.inl hb)
  · exact hcode _ (.inl ⟨r.pos + k, by have := H.relocsIn r hr; omega, rfl⟩)
  · exact hcode b (.inr hb)
  · -- A link slot: `fp + o` with `o ∈ [0, 16)`.
    obtain ⟨o, ho1, ho2, rfl⟩ : ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o := by
      have e : ∀ c : Int, x.reg .rbp + BitVec.ofInt 64 c + BitVec.ofNat 64 i =
          fpAddr x (c + i) := fun c => by
        simp only [fpAddr, island_ofInt_add, BitVec.add_assoc]
      rcases hb with rfl | rfl
      · refine ⟨8 + i, by omega, by omega, ?_⟩
        rw [← e]; rfl
      · refine ⟨0 + i, by omega, by omega, ?_⟩
        rw [← e]; simp
    have hoF : -(S.F : Int) ≤ o := by omega
    obtain ⟨hesc, -⟩ := H.linkPrivate s x s1 hf hsc o ho1 ho2
    have hxo : (fpAddr x o).toNat = ((s.fp : Int) + o).toNat := by
      rw [Island.fpAddr_eq_lendAddr hrbp, Island.lendAddr, ← ofNat_frameAddr _ _ (by omega),
        BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by omega)]
    have hst : ¬ InStack S.lo x.rsp (fpAddr x o) := by
      rintro ⟨-, h2⟩
      rw [hrsp0, hxo] at h2
      omega
    refine ⟨?_, hst⟩
    rintro (⟨r, hr, hlt⟩ | ⟨id, al, hg, hlv, hlt⟩ | ho | hst2 | hh)
    · have hli := hwr r hr
      have hoff := hfb.handlerOff s.pc h args t vals hi hu r hr
      have e2 : fpAddr x2 r.1 = fpAddr x r.1 := by simp [fpAddr, hrbp2]
      rw [e2, fpAddr_sub, BitVec.toNat_ofInt] at hlt
      have hsz : r.2 < 2 ^ 62 := by omega
      simp only [OffLink] at hoff
      omega
    · have hsep1 := (sep_foldlM _ (hfb.scopesIn _) (hfb.window hwin) hf.rrel hf.sep hsc).2
      obtain ⟨e, hem, he1, he2, -⟩ := hsep1.own id al o hg hlv hoF (by omega) hlt
      exact escapedAt_none hesc e hem ⟨he1, he2⟩
    · rw [hf.fpAddr_eq] at ho
      exact H.envApart.window o hoF (by omega) ho
    · exact hst ⟨hst2.1, Nat.lt_of_lt_of_le hst2.2 hrsp2⟩
    · obtain ⟨o', h1, h2, he⟩ := hhomeW _ hh
      have := congrArg BitVec.toNat he
      rw [HandlerStackArg.fpAddr_toNat hrbp (o := o) (by omega) (by omega),
        HandlerStackArg.fpAddr_toNat hrbp (o := o') (by omega) (by omega)] at this
      omega


/-- The escaped objects lie in the frame window: each is an `Escape` scope's range
(`EscFrom`), and the scopes are in the window (`FrameBounds.scopes`). -/
theorem hr_esc_window (H : Hyps S) {L : Prop} {pc : Nat} {st : OpSem.State}
    (h : Discharge.EscFrom.EscFrom S.c L pc st) :
    ∀ e ∈ st.escaped, -(S.F : Int) ≤ e.off ∧ e.off + e.size ≤ S.K := by
  intro e he
  obtain ⟨p, hp, -, h2, h3, -⟩ := h e he
  have hm : p.2 ∈ S.c.scopesAt p.1 := by
    simp only [R.Code.scopesAt, List.mem_map, List.mem_filter, beq_iff_eq]
    exact ⟨p, ⟨hp, rfl⟩, rfl⟩
  have := H.frameBounds.scopes p.1 p.2 hm
  rw [← h2, ← h3]; exact this

set_option maxRecDepth 100000 in
/-- What a handler called from the region (state after the call `x2`, `rsp - 8`) leaves
alone: `IslandKeptR` (code, rodata, link words, the trampoline's return address) is off
`MayWrite`, the stack below `rsp` and PE's stack argument. `hdl_kept_co` at the ghost state for
`IslandKept`, the numbers for the trampoline. -/
theorem hr_kept (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {e : X86.State} {s s1 : R.RState} {x x2 : X86.State} (hR : RegionInv S e s x)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat} {vals : Operands}
    (hi : S.c.d.insns[s.pc]? = some (.handler h args t))
    (hu : R.unpack S.c.ρ h S.c.mode args = some vals)
    (hrbp2 : x2.reg .rbp = x.reg .rbp) (hrsp2 : x2.rsp = x.rsp - 8)
    (b : BitVec 64) (hb : IslandKeptR S x b) :
    ¬ Handler.MayWrite S.Owned S.lo (R.handlerHome S.c.mode.pe args.length) h vals s1.st x2 b ∧
      ¬ InStack S.lo x.rsp b ∧ ¬ HandlerStackArg.InStackArg x.rsp b := by
  obtain ⟨hrbpN, hfp16, hx0, hbel, hroom, hfpF⟩ := rgn_nums H hR
  obtain ⟨hg5, hgsp⟩ := ir_ghost_regs (S := S) x
  have hg := hR.ghost hD
  have hHome := hdl_home_le H hi
  have hH40 : R.handlerHome S.c.mode.pe args.length ≤ 40 := by
    simp only [R.handlerHome]; split <;> (try split) <;> omega
  have hgN : (x.reg .rbp - BitVec.ofNat 64 S.F).toNat = s.fp - S.F := by
    rw [BitVec.toNat_sub, BitVec.toNat_ofNat, hrbpN, Nat.mod_eq_of_lt (a := S.F) (by omega)]
    omega
  have hrsp2N : x2.rsp.toNat = x.rsp.toNat - 8 := by rw [hrsp2]; bv_omega
  have hxle : x.rsp.toNat ≤ (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp.toNat := by
    rw [hgsp, hgN]; omega
  have hsa : ∀ a, HandlerStackArg.InStackArg x.rsp a →
      InStack S.lo (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp a := by
    intro a ha
    unfold HandlerStackArg.InStackArg at ha
    unfold InStack
    rw [hgsp, hgN]
    constructor <;> bv_omega
  rcases hb with hb | ⟨i, hi8, hbeq⟩
  · -- `IslandKept`: at the ghost state.
    let x2g := x2.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F - 8)
    have hx2g5 : x2g.reg .rbp = (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).reg .rbp := by
      rw [X86.State.reg_setReg_other x2 .rsp .rbp _ (by decide), hrbp2, hg5]
    have hx2gsp : x2g.rsp = (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp - 8 := by
      rw [hgsp]; exact X86.State.reg_setReg x2 .rsp _
    have hx2gN : x2g.rsp.toNat = s.fp - S.F - 8 := by
      rw [hx2gsp, hgsp]; bv_omega
    have hle : x2g.rsp.toNat ≤ (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp.toNat := by
      rw [hx2gN, hgsp, hgN]; omega
    have hbg : IslandKept S (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)) b := by
      unfold IslandKept at hb ⊢; rw [hg5]; exact hb
    obtain ⟨hk1, hk2⟩ := hdl_kept_co H hg (codeOff_of_region H hR) hsc hi hu hx2g5 hle hx2gsp
      hHome b hbg
    have hf2 : ∀ o, fpAddr x2g o = fpAddr x2 o := fun o => by
      simp only [fpAddr]; rw [X86.State.reg_setReg_other x2 .rsp .rbp _ (by decide)]
    refine ⟨?_, fun ⟨h1, h2⟩ => hk2 ⟨h1, Nat.lt_of_lt_of_le h2 hxle⟩, fun ha => hk2 (hsa b ha)⟩
    rintro (⟨r, hr, hlt⟩ | hal | ho | hst | hh)
    · exact hk1 (.inl ⟨r, hr, by rw [hf2]; exact hlt⟩)
    · exact hk1 (.inr (.inl hal))
    · exact hk1 (.inr (.inr (.inl ho)))
    · exact hk1 (.inr (.inr (.inr (.inl ⟨hst.1, by have h2 := hst.2; rw [hrsp2N] at h2; rw [hx2gN]; omega⟩))))
    · rw [hrsp2, BitVec.sub_add_cancel] at hh
      exact hk2 ⟨by bv_omega, by rw [hgsp, hgN]; bv_omega⟩
  · -- The trampoline's return address.
    have hbN : b.toNat = x.rsp.toNat + 40 + i := by rw [hbeq]; bv_omega
    have hfb := H.frameBounds
    have hwin := hR.win
    have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
    refine ⟨?_, fun ⟨_, h2⟩ => by omega, fun ha => ?_⟩
    · rintro (⟨r, hr, hlt⟩ | ⟨id, al, hga, hlv, hlt⟩ | ho | hst | hh)
      · have hr' := hfb.handler s.pc h args t vals hi hu r hr
        rcases Nat.eq_zero_or_pos r.2 with h0 | h0
        · omega
        have hr1 := hr'.1
        have hr2 := hr'.2
        have eF : (S.F : Int) = (S.c.d.frameSize : Int) := rfl
        have hfo := HandlerStackArg.fpAddr_toNat (x := x2) (o := r.1) (hrbp2.trans hR.rrel.rbp)
          (by omega) (by omega)
        rw [BitVec.toNat_sub, hfo, hbN] at hlt
        omega
      · have hA := island_allocs' H hg hsc
        generalize hd : (b - BitVec.ofNat 64 al.addr).toNat = d at hlt
        have hb' := island_sub_toNat hd
        apply hA id al hga hlv d hlt
        rw [BitVec.ofNat_add, ← hb', hgsp]
        show S.lo.toNat ≤ b.toNat ∧ b.toNat < (x.reg .rbp - BitVec.ofNat 64 S.F).toNat
        rw [hgN]
        omega
      · exact H.envApart.stackOff b ⟨by omega, by omega⟩ ho
      · have := hst.2; omega
      · rw [hrsp2, BitVec.sub_add_cancel] at hh
        have : (b - x.rsp).toNat = 40 + i := by rw [hbeq]; bv_omega
        omega
    · unfold HandlerStackArg.InStackArg at ha
      have : (b - (x.rsp + 32)).toNat = 8 + i := by rw [hbeq]; bv_omega
      omega

set_option maxHeartbeats 2000000 in
set_option maxRecDepth 100000 in
/-- The setup, `call h` and the handler's return in PE's pad region (as `hdl_call_reach`, the
frame-pointer form): the home space at `ho = rsp - fp` (`SepAcross.handlerAt`,
`HandlerContractB.sound`; `FrameOwn` there as no live allocation is below the frame), moved to
R's `-F` (`hrel_clearHome_move`); memory kept by `hr_kept`, so the trampoline's return address
too. -/
theorem hdl_call_reach_region (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {Q : X86.State → Prop} {e : X86.State} {s s1 : R.RState} {x : X86.State}
    {p hat len n : Nat} {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat}
    {vals : Operands} {items : List Item}
    (hR : RegionInv S e s x) (hb : Boundary S.rs p) (hrip : x.rip = addrAt S.ctx p)
    (hd : Dec (atPos S.body p) p items hat)
    (hcall : decodeItem (atPos (atPos S.body p) hat) = some (.call (.handler n), len))
    (hn : Full.Opcode.ofNat? n = some h) (hhh : h.hasHandler = true)
    (hsetup : Handler.setupItems S.c.mode args = some items)
    (hi : S.c.d.insns[s.pc]? = some (.handler h args t))
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hu : R.unpack S.c.ρ h S.c.mode args = some vals) (hno : Handler.NoUB h vals s1.st)
    (kont : ∀ x' ch ctl st', opSem h vals s1.st ch = .ok (ctl, st') → Handler.CtlIn ctl x' →
      x'.rip = addrAt S.ctx (hat + len) →
      (∀ st'', R.clearHome S.c.mode.pe args.length (-(S.F : Int)) st' = .ok st'' → ∀ pc,
        S.c.inRegion pc = true → RegionInv S e { s1 with pc, st := st'' } x') →
      Reach S.ctx S.E Q x') :
    Reach S.ctx S.E Q x := by
  have hpe : S.c.mode.pe = true := rgn_pe hR.inR
  have hfpm := vt_fp_of_pe hD.modeValid hpe
  have hsp : S.body.spFrame = none := hD.spFrame_of_fp hfpm
  have hlk : LinkOk S.ctx x.mem (atPos S.body p) S.rs :=
    ⟨hR.code.fields, hR.code.sorted, hR.code.loaded, hR.code.small, hsp⟩
  have hdc : Dec (atPos S.body p) p (items ++ [Item.call (.handler n)]) (hat + len) :=
    hd.append (Dec.single hcall)
  obtain ⟨hca, hend, -⟩ := hlk.dec hdc hb
  have hripE : x.rip + BitVec.ofNat 64 (codeSize (items ++ [Item.call (.handler n)])) =
      addrAt S.ctx (hat + len) := by rw [hrip, addrAt_add', hend]
  have hk := scopes_keeps _ hsc
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hR.win
  have hfpF : S.F ≤ s.fp := hR.fpF
  obtain ⟨hrbpN, hfp16, hx0, hbel, hroom, -⟩ := rgn_nums H hR
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hFle : (S.F : Int) ≤ 2 ^ 31 := hfb.F_le
  have hsep1 : FrameSep (-(S.F : Int)) S.K s1.st x :=
    (sep_foldlM _ (hfb.scopesIn s.pc) (hfb.window hwinT) hR.rrel hR.sep hsc).2
  obtain ⟨hr1, hm1⟩ := memRel_foldlM _ (hfb.scope_size _) hR.rrel hR.mem hsc
  have hap : Handler.StackApart S.lo s1.st x :=
    Handler.FrameSep.stackApart hsep1
      (Handler.stack_off_window (by rw [hrbpN]; omega) (by rw [hrbpN]; omega))
      (ir_allocs hD H hR hsc)
  have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by omega
  have hb0 : x.reg .rbp = BitVec.ofNat 64 s.fp := hR.rrel.rbp
  obtain ⟨hg5, hgsp⟩ := ir_ghost_regs (S := S) x
  have hg := hR.ghost hD
  have hgN : (x.reg .rbp - BitVec.ofNat 64 S.F).toNat = s.fp - S.F := by
    rw [BitVec.toNat_sub, BitVec.toNat_ofNat, hrbpN, Nat.mod_eq_of_lt (a := S.F) (by omega)]
    omega
  have hAg := island_allocs' H hg hsc
  -- The setup and `call h`.
  obtain ⟨x2, hsteps, hat2, hargs2, hrsp2, hsv2, hmem2, hra, hH2, hrbp2⟩ :
      ∃ x2, Steps S.ctx x x2 ∧ Handler.AtHandler S.ctx h x2 ∧
        Handler.ArgsIn S.c.ρ S.c.mode.pe x2 x2 args ∧ x2.rsp = x.rsp - 8 ∧
        (∀ i, Saved S.c.mode.pe i → x2.regs i = x.regs i) ∧
        (∀ a, ¬ InStack S.lo x.rsp a → ¬ HandlerStackArg.InStackArg x.rsp a →
          x2.mem a = x.mem a) ∧
        x2.mem.read64 x2.rsp = addrAt S.ctx (hat + len) ∧
        Handler.HRel s1.st x2 ∧ x2.reg .rbp = x.reg .rbp := by
    rcases HandlerStackArg.setupItems_length hsetup with hreg | ⟨-, h5⟩
    · obtain ⟨x2, hx2, hat2, hargs2, hrsp2, hsv2, hmem2, hret2⟩ :=
        handler_call_ret (lo := S.lo) S.ctx H.linked hn hsetup hreg hlo
      obtain ⟨x2', hx2', -, -, hH2, hrbp2, -, -⟩ :=
        handler_call (lo := S.lo) S.ctx H.linked hn hsetup hreg ⟨hr1.rel, hm1⟩ hap hlo
      have e2 : x2' = x2 := by
        rw [hx2] at hx2'
        exact (Switch.except_ok_inj hx2').symm
      rw [e2] at hH2 hrbp2
      refine ⟨x2, handler_call_steps hsetup hreg hca hrip hx2, hat2, hargs2, hrsp2, hsv2,
        fun a ha _ => hmem2 a ha, ?_, hH2, hrbp2⟩
      rw [hret2]; exact hripE
    · obtain ⟨a0, a1, a2, a3, a4, rfl⟩ := HandlerStackArg.eq_five h5
      obtain ⟨x2, hx2, hat2, hargs2, hrsp2, hrbp2, hpk, hmem2, hret2⟩ :=
        HandlerStackArg.handler_call5 (lo := S.lo) S.ctx H.linked hpe hn hsetup hlo
      have hsa : ∀ a, HandlerStackArg.InStackArg x.rsp a →
          InStack S.lo (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp a := by
        intro a ha
        unfold HandlerStackArg.InStackArg at ha
        unfold InStack
        rw [hgsp, hgN]
        constructor <;> bv_omega
      have hapG : Handler.StackApart S.lo s1.st (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)) :=
        Handler.FrameSep.stackApart (hsep1.congr hg5)
          (Handler.stack_off_window (by rw [hgsp, hg5, hgN, hrbpN]; omega)
            (by rw [hg5, hrbpN]; omega)) hAg
      have hfg : ∀ o, fpAddr (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)) o = fpAddr x o :=
        fun o => by simp only [fpAddr, hg5]
      have harg : HandlerStackArg.ArgApart (HandlerStackArg.InStackArg x.rsp) s1.st x :=
        ⟨fun o h1 h2 he hu' hin => hapG.1 o h1 h2 he hu' (by rw [hfg]; exact hsa _ hin),
          fun id al hg' hl i hi hin => hapG.2 id al hg' hl i hi (hsa _ hin)⟩
      have hH2 := HandlerStackArg.hrel_after ⟨hr1.rel, hm1⟩ hap harg hrbp2 hmem2
      refine ⟨x2, handler_call_steps5 hpe H.linked hsetup hca hrip (fun a ha => ?_) hx2, hat2,
        hargs2, hrsp2, ?_, hmem2, ?_, hH2, hrbp2⟩
      · obtain ⟨j, hj, rfl⟩ := hdl_inCode_dec hlk hdc hb a ha
        exact rgn_code_not_stackArg H hR hj
      · intro i hi
        rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;>
          refine hpk _ (fun r hr => ?_) (by decide) <;>
          (rw [hpe] at hr
           simp [handlerRegs] at hr
           rcases hr with rfl | rfl | rfl | rfl <;> decide)
      · rw [hret2]; exact hripE
  have hHome := hdl_home_le H hi
  have hH40 : R.handlerHome S.c.mode.pe args.length ≤ 40 := by
    simp only [R.handlerHome]; split <;> (try split) <;> omega
  -- The home space at `ho`, off the frame.
  obtain ⟨ho, hhoD⟩ : ∃ ho : Int, ho = (x.rsp.toNat : Int) - s.fp := ⟨_, rfl⟩
  have hho : fpAddr x2 ho = x2.rsp + 8 := by
    rw [hrsp2, BitVec.sub_add_cancel]
    apply BitVec.eq_of_toNat_eq
    rw [HandlerStackArg.fpAddr_toNat (hrbp2.trans hb0) (by omega) (by omega)]
    omega
  have hown : FrameOwn ho (ho + R.handlerHome S.c.mode.pe args.length) s1.st x2 := by
    intro id al o hg' hl h1 h2 hin
    exfalso
    generalize hdd : (fpAddr x2 o - BitVec.ofNat 64 al.addr).toNat = d at hin
    have hb' := island_sub_toNat hdd
    have hfo : (fpAddr x2 o).toNat = ((s.fp : Int) + o).toNat :=
      HandlerStackArg.fpAddr_toNat (hrbp2.trans hb0) (by omega) (by omega)
    apply hAg id al hg' hl d hin
    rw [BitVec.ofNat_add, ← hb', hgsp]
    show S.lo.toNat ≤ (fpAddr x2 o).toNat ∧
      (fpAddr x2 o).toNat < (x.reg .rbp - BitVec.ofNat 64 S.F).toNat
    rw [hfo, hgN]; omega
  have e2 : x2.setReg .rbp (x.reg .rbp) = x2 := by rw [← hrbp2, X86.State.setReg_reg_self]
  refine Reach.steps hsteps (.env (H.envOutside.handler h _ hat2) fun x' hret => ?_)
  obtain ⟨ch, ctl, st', hop, hH', hctl, hal⟩ :=
    H.sepAcross.handlerAt (x.reg .rbp) (x.reg .rbp) h args vals s1.st x2 x' x hrbp2 hhh hu hat2
      (by rw [e2]; exact hargs2) (by rw [e2]; exact hH2) hno hret hsep1 ho
      (by rw [e2]; exact hho) (by rw [e2]; exact hown)
  obtain ⟨-, -, -, -, -, -, hrsp', hrip', hsv', hmw⟩ :=
    H.handler.sound h args vals s1.st x2 x' (x.reg .rbp) hhh hu hat2 (fun _ => hrbp2)
      (by rw [e2]; exact hargs2) (by rw [e2]; exact hH2) hno ho (by rw [e2]; exact hho)
      (by rw [e2]; exact hown) hret
  rw [e2] at hmw
  have hx'rbp : x'.reg .rbp = x.reg .rbp := by
    show x'.regs 5 = x.regs 5
    rw [hsv' 5 (by simp [CalleeSaved])]; exact hrbp2
  have hx'rsp : x'.rsp = x.rsp := by rw [hrsp', hrsp2]; exact BitVec.sub_add_cancel _ _
  have e' : x'.setReg .rbp (x.reg .rbp) = x' := by rw [← hx'rbp, X86.State.setReg_reg_self]
  refine kont x' ch ctl st' hop hctl (by rw [hrip', hra]) fun st'' hcl pc hinPc => ?_
  have hnl : ¬ LeadArg S pc := fun ha => (region_not_leadArg hD (Nat.le_of_lt ha.1) hinPc).1 ha
  have hsvX : ∀ i, Saved S.c.mode.pe i → x'.regs i = x.regs i := by
    intro i hi
    rcases hi with hc | ⟨hpe', h67⟩
    · rw [hsv' i hc]; exact hsv2 i (Or.inl hc)
    · obtain ⟨h6, h7⟩ := H.peSaved hpe' _ x' hret
      rcases h67 with rfl | rfl
      · rw [h6]; exact hsv2 6 (Or.inr ⟨hpe', Or.inl rfl⟩)
      · rw [h7]; exact hsv2 7 (Or.inr ⟨hpe', Or.inr rfl⟩)
  have hkeepR : ∀ b, IslandKeptR S x b → x'.mem b = x.mem b := by
    intro b hb'
    obtain ⟨h1, h2, h3⟩ := hr_kept hD H hR hsc hi hu hrbp2 hrsp2 b hb'
    rw [hmw b h1]; exact hmem2 b h2 h3
  have hkeep : ∀ b, IslandKept S x b → x'.mem b = x.mem b := fun b hb' => hkeepR b (.inl hb')
  have hesc : st'.escaped = s1.st.escaped := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  have hwr : WrIn (-(S.F : Int)) S.K h vals := hfb.handler s.pc h args t vals hi hu
  have hinit : FrameInit (-(S.F : Int)) S.K st' := by
    intro o he hu'
    have he1 : s1.st.escapedAt o = none := by
      rw [← IslandLemmas.escapedAt_congr hesc o]; exact he
    by_cases hin : ∃ r ∈ wranges h vals, inRange o r = true
    · obtain ⟨r, hr, ho⟩ := hin
      have := hwr r hr
      simp only [inRange, decide_eq_true_eq] at ho
      omega
    · obtain ⟨fp, hfp⟩ := hdl_footprint hop
      have hw : wranges h vals = fp.writeRanges (opndVal h.info vals) := by
        unfold wranges; rw [hfp]
      have hfr : st'.frame o = s1.st.frame o := opSem_frame_writes hfp hop o fun r hr => by
        cases hc : inRange o r
        · rfl
        · exact absurd ⟨r, hw ▸ hr, hc⟩ hin
      exact hsep1.init o he1 (by rw [← hfr]; exact hu')
  have hsep' : FrameSep (-(S.F : Int)) S.K st' x' :=
    FrameSep.extend hsep1 hx'rbp hesc hal.1 hinit hal.2.1 hal.2.2
  have hwf' : EscWF st' := (H.opFacts h).escWF vals s1.st ch ctl st' hop hr1.wf
  -- The home space cleared at `ho`, moved to `-F`.
  obtain ⟨st1, h1⟩ := Shapes.clearHome_ok (pe := S.c.mode.pe) (n := args.length) (off := ho) hwf'
  have hH1 : Handler.HRel st1 x' := by have := hH' st1 h1 hx'rbp; rwa [e'] at this
  have hescW := hr_esc_window H (hR.esc.scopes hsc)
  have hHt : R.handlerHome true args.length ≤ 40 := hpe ▸ hH40
  have hH'' : Handler.HRel st'' x' :=
    hrel_clearHome_move (F := S.F) (K := S.K) hinit (by omega)
      (fun i hi' => by
        cases hea : st'.escapedAt (ho + i) with
        | none => rfl
        | some e0 =>
          exfalso
          obtain ⟨hm0, h01, h02⟩ := escapedAt_some hea
          rw [hesc] at hm0
          have := hescW e0 hm0
          omega)
      hFle (hpe ▸ h1) hH1 (hpe ▸ hcl)
  obtain ⟨hesc'', hsz''⟩ := Shapes.clearHome_keeps hcl
  have hwf'' : EscWF st'' := hwf'.of_sizes hesc'' hsz''
  have hslots' := (Discharge.PeStackArg.ArgSlots.scopes (s1 := s1) H.boundsOk hR.slots hsc).opSem
    hop (Discharge.PeStackArg.handler_lo H.boundsOk hi hu)
  obtain ⟨hsep'', hslots''⟩ :
      FrameSep (-(S.F : Int)) S.K st'' x' ∧ Discharge.PeStackArg.ArgSlots S.c st'' := by
    rcases Shapes.clearHome_cases hcl with ⟨-, hw⟩ | ⟨-, rfl⟩
    · exact ⟨island_sep_writeFrame hsep' hw (Int.le_refl _)
        (by rw [List.length_replicate]; omega), hslots'.clearHome hcl⟩
    · exact ⟨hsep', hslots'.clearHome hcl⟩
  have hFC : FrameCore S { s1 with pc, st := st'' } x' := by
    refine ⟨⟨hH''.rel, ?_, hwf''⟩, hH''.mem, hsep'', ?_, ?_, island_link_keptF hR.code hkeep,
      island_ro_kept hR.ro hkeep, island_frame_kept hR.frame hkeep hx'rbp (fun i hi _ => hsvX i hi),
      hslots'', ((hR.esc.scopes hsc).of_not hnl).congr (hesc''.trans hesc)⟩
    · show x'.reg .rbp = BitVec.ofNat 64 s1.fp
      rw [hx'rbp, hb0, hk.fp]
    · show (s1.fp : Int) + S.K ≤ 2 ^ 64
      rw [hk.fp]; exact hwinT
    · show S.F ≤ s1.fp
      rw [hk.fp]; exact hfpF
  exact RegionInv.next' hR hFC hinPc hx'rbp hx'rsp
    (CallLemmas.read64_congr fun i hi => hkeepR _ (.inr ⟨i, hi, rfl⟩))

/-- `hdl_fallthrough` in the region: to instruction `k + 1` (after PE's `nop`). -/
theorem hr_fallthrough (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {e : X86.State} {k pC : Nat} {q : Proto} {s s' : R.RState} {y : X86.State}
    (hnop : NopRead S.frR S.callSites S.body q pC (S.start (k + 1)))
    (hb : Boundary S.rs pC) (hyrip : y.rip = addrAt S.ctx pC) (hnext : RNext S.c s s')
    (hpc : s'.pc = k + 1) (hRI : RegionInv S e s' y)
    (hcache : S.cache (k + 1) = { pe := S.frR.mode.pe }) :
    Reach S.ctx S.E (RSNext S s) y := by
  have fin : ∀ z : X86.State, z.regs = y.regs → z.xmm = y.xmm → z.mem = y.mem →
      z.rip = addrAt S.ctx (S.start (k + 1)) → Reach S.ctx S.E (RSNext S s) z := by
    intro z hzr _ hzm hzrip
    have hz := hRI.congr hzr hzm
    refine .done (.inl ⟨s', hnext, (rbInv_region hz.inR).2 ⟨e, hz, .inl ⟨?_, ?_⟩⟩⟩)
    · rw [hpc]; exact hzrip
    · rw [hpc, hcache]; exact CacheInv.emptyPe _ _
  generalize hE : S.start (k + 1) = pE at hnop fin
  cases hnop with
  | none _ => exact fin y rfl rfl rfl hyrip
  | nop hna hby hrl =>
    have hpe := rgn_pe hRI.inR
    obtain ⟨hit, -, -⟩ := nop_itemAt (hRI.code.toLinkOk (vt_fp_of_pe hD.modeValid hpe)) (p := pC)
      (n := 1) (by omega) (by omega) (island_nop_bytes hby) hrl hb
    refine reach_padding (ns := [1]) (by simp) ⟨hit, trivial⟩ hyrip fun z h1 h2 h3 h4 => ?_
    refine fin z h1 h2 h3 ?_
    rw [h4]; rfl

set_option maxHeartbeats 1000000 in
/-- `hdl_br` in the region: the target and the next instruction are in the region. -/
theorem hr_br (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {e : X86.State} {k pT j pc : Nat} {q : Proto} {c3 : Cursor} {s s1 : R.RState}
    {x' : X86.State} {st' : OpSem.State} {ch : OpSem.Choice} {b : Bool} {cond : Cond}
    {tgt : BitVec 32} {long : Bool}
    (hs : s.pc = k) (hlt : k < S.r.protos.size)
    (htg : tgt.toNat ∈ S.r.protos[k].targets) (hj : posOf S.r j = tgt.toNat)
    (hcond : cond = .z ∨ cond = .nz)
    (hdec : Dec (atPos S.body pT) pT [.testAl, .branch cond tgt long] c3.pos)
    (hbT0 : Boundary S.rs pT) (hrip : x'.rip = addrAt S.ctx pT)
    (hal : Handler.CtlIn (.branch b) x')
    (hRI : ∀ pc, S.c.inRegion pc = true → RegionInv S e { s1 with pc, st := st' } x')
    (hpc : (if (b != (cond == Cond.z)) = true then j else s.pc + 1) = pc)
    (hstep : R.step S.c s ch = .ok (.step { s1 with pc, st := st' }))
    (hinJ : S.c.inRegion j = true) (hin1 : S.c.inRegion (k + 1) = true)
    (hnop : NopRead S.frR S.callSites S.body q c3.pos (S.start (k + 1)))
    (hcache : S.cache (k + 1) = { pe := S.frR.mode.pe }) :
    Reach S.ctx S.E (RSNext S s) x' := by
  have hce : cond = (if (cond == Cond.z) = true then Cond.z else Cond.nz) := by
    rcases hcond with rfl | rfl <;> rfl
  have hin1' : S.c.inRegion (s.pc + 1) = true := by rw [hs]; exact hin1
  have hfk := hRI (s.pc + 1) hin1'
  have hlkT : LinkOkF S.ctx x'.mem (atPos S.body pT) S.rs S.c.mode := hfk.code.atPos pT
  obtain ⟨hcaT, hqT, hbT⟩ := hlkT.dec hdec hbT0
  simp only [List.map_cons, List.map_nil, hdl_fform_testAl, fform_item_branch] at hcaT hqT
  obtain ⟨n1, n2, h1, h2, -⟩ := hdl_dec2 hdec
  obtain ⟨-, hq1, -⟩ := hlkT.dec (Dec.single h1) hbT0
  simp only [List.map_cons, List.map_nil, hdl_fform_testAl] at hq1
  have hn1 : n1 = Item.testAl.size := by
    simp only [codeSize, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil] at hq1
    omega
  have hcanB : (Item.branch cond tgt long).Canonical (pT + Item.testAl.size) := by
    rw [← hn1]; exact branch_canonical_any (c := S.body) h2
  have hcanA : Item.testAl.Canonical pT := by
    unfold Item.Canonical
    exact ⟨fun _ _ h => (nomatch h), Or.inl rfl⟩
  have hcan : Canon [Item.testAl, Item.branch cond tgt long] pT := ⟨hcanA, hcanB, trivial⟩
  obtain ⟨x'', hex, hregs, hmem, hxmm, hrip2⟩ :=
    Handler.br_tail S.ctx b (cond == Cond.z) tgt long x' hal
  rw [← hce] at hex hrip2
  have hst : Steps S.ctx x' x'' :=
    steps_of_run_last (S := InCode S.ctx [Item.testAl, Item.branch cond tgt long] pT)
      (items := [Item.testAl]) (j := Item.branch cond tgt long) hcan hcaT hrip (fun _ h => h)
      (fetchRun_of_forall (fun i hi => by
        simp only [List.mem_singleton] at hi
        subst hi
        exact hdl_testAl_straight S.ctx) x') hex
  rcases Bool.eq_false_or_eq_true (b != (cond == Cond.z)) with hbn | hbn
  · rw [ite_eq_left hbn] at hpc
    rw [ite_eq_left hbn] at hrip2
    rw [← hpc] at hstep
    have hfj := (hRI j hinJ).congr hregs hmem
    have hc := H.cacheTargets k hlt _ htg
    have hripj : x''.rip = addrAt S.ctx (posOf S.r j) := by
      rw [hrip2, hdl_base_setWidth, hj]
    have hused : S.used j = { pe := S.c.mode.pe } := by
      simp only [Setup.used, hj, hc, ↓reduceIte]
    refine Reach.steps hst (.done (.inl ⟨_, .step hstep,
      (rbInv_region hinJ).2 ⟨e, hfj, .inr ⟨hripj, ?_⟩⟩⟩))
    show CacheInv (S.used j) x''
    rw [hused]
    exact CacheInv.emptyPe _ _
  · have hnb : ¬ ((b != (cond == Cond.z)) = true) := by simp [hbn]
    rw [ite_eq_right hnb] at hpc
    rw [ite_eq_right hnb] at hrip2
    rw [← hpc] at hstep
    have hripC : x''.rip = addrAt S.ctx c3.pos := by
      (rw [hrip2, hrip, addrAt_add', hqT]) <;>
        simp only [codeSize, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil,
          Nat.add_zero]
    exact Reach.steps hst (hr_fallthrough hD hnop hbT hripC (.step hstep)
      (by show s.pc + 1 = k + 1; rw [hs]) (hfk.congr hregs hmem) hcache)

set_option maxHeartbeats 1000000 in
/-- `hdl_switch` in the region: the target is in the region. -/
theorem hr_switch (H : Hyps S)
    {e : X86.State} {k pT pc i pE : Nat} {s s1 : R.RState}
    {x' : X86.State} {st' : OpSem.State} {ch : OpSem.Choice} {tb : BitVec 32}
    {es : List (BitVec 32)}
    (hlt : k < S.r.protos.size)
    (hdT : Dec (atPos S.body pT) pT (Switch.switchItems tb) pE) (hbT0 : Boundary S.rs pT)
    (hrip : x'.rip = addrAt S.ctx pT)
    (hes : ∀ i (hi : i < es.length), (atPos S.body (tb.toNat + 4 * i)).tableEntry tb = some es[i])
    (htb : tb.toNat < 2 ^ 31) (hbtb : Boundary S.rs tb.toNat) (hes31 : ∀ e ∈ es, e.toNat < 2 ^ 31)
    (hil : i < es.length) (hpe : posOf S.r pc = es[i].toNat)
    (htg : es[i].toNat ∈ S.r.protos[k].targets)
    (hrax : Handler.CtlIn (.index i) x')
    (hinP : S.c.inRegion pc = true)
    (hRI : ∀ pc, S.c.inRegion pc = true → RegionInv S e { s1 with pc, st := st' } x')
    (hstep : R.step S.c s ch = .ok (.step { s1 with pc, st := st' })) :
    Reach S.ctx S.E (RSNext S s) x' := by
  have hfi := hRI pc hinP
  have hlkT : LinkOkF S.ctx x'.mem (atPos S.body pT) S.rs S.c.mode := hfi.code.atPos pT
  obtain ⟨hcaS, -, -⟩ := hlkT.dec hdT hbT0
  rw [hdl_fform_switch] at hcaS
  have htab : CodeAt S.ctx x'.mem (es.map (Item.tableEntry tb)) tb.toNat :=
    entries_codeAtF hfi.code hes hbtb
  obtain ⟨x'', hst, hex, hrip'', -, -, hm, -, -⟩ :=
    Switch.switch_tail hcaS hrip htab hil hrax htb (hes31 _ (List.getElem_mem hil))
  have hregs := hdl_switch_regs hex
  have hrbp : x''.reg .rbp = x'.reg .rbp := by
    show x''.regs 5 = x'.regs 5
    exact hregs 5 (by decide) (by decide)
  have hrsp : x''.rsp = x'.rsp := by
    show x''.regs 4 = x'.regs 4
    exact hregs 4 (by decide) (by decide)
  have hsv : ∀ i, Saved S.c.mode.pe i → x''.regs i = x'.regs i := by
    intro i hi
    apply hregs <;> rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;> decide
  have hfi'' := RegionInv.next hfi (hfi.toFrameCore.congr hrbp hsv hm) hinP hrbp hrsp hm
  have hc := H.cacheTargets k hlt _ htg
  have hripP : x''.rip = addrAt S.ctx (posOf S.r pc) := by rw [hrip'', hpe]
  have hused : S.used pc = { pe := S.c.mode.pe } := by
    simp only [Setup.used, hpe, hc, ↓reduceIte]
  refine Reach.steps hst (.done (.inl ⟨_, .step hstep,
    (rbInv_region hinP).2 ⟨e, hfi'', .inr ⟨hripP, ?_⟩⟩⟩))
  show CacheInv (S.used pc) x''
  rw [hused]
  exact CacheInv.emptyPe _ _

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
/-- PE-T4.1: a handler call other than `resume` in PE's pad region (as `handler_general'B`). -/
theorem regionSim_handler (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hh : q.handler ≠ none) (hres : q.op ≠ .resume)
    (hnd : ∀ c'', (denseSwitch S.frR).run cur ≠ .ok (some q, c''))
    (htable : HdlTables S) :
    RegionSimB S k p := by
  intro e s x hs hR hrip hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFactsR_insnOf hP hres
  cases hr with
  | ret => exact (hh rfl).elim
  | unreachable => exact (hh rfl).elim
  | jmp => exact (hh rfl).elim
  | island => exact (hh rfl).elim
  | resume => exact (hres rfl).elim
  | dense hd => exact (hnd _ hd).elim
  | @handler items hat n len nn op args t sites c'' hd hcall hnop hhh hsetup hthen =>
  have hres' : op ≠ .resume := hres
  have hun : op ≠ .unreachable := by rintro rfl; simp [noHandler] at hhh
  simp only [InsnOf] at hio
  obtain ⟨t', rfl, ht'⟩ := hio
  have hik := hi
  rw [← hs] at hi
  obtain ⟨s1, vals, hsc, hu, hno, hsucc⟩ := handler_rside hi hsafe hres' hun
  obtain ⟨-, -, hbe⟩ := (hR.code.atPos p).dec (hd.append (Dec.single hcall)) hP.bound
  have hbe' : Boundary S.rs (hat + len) := hbe
  have hin1 : S.c.inRegion (k + 1) = true := rgn_mono hP.inR (Nat.le_succ k)
  refine hdl_call_reach_region hD H hR hP.bound hrip hd hcall hnop hhh hsetup hi hsc hu hno ?_
  intro x' ch ctl st' hop hctl hripT hRI
  obtain ⟨st'', pc, hcl, hpc, hstep⟩ := hsucc ch ctl st' hop
  have hRI' := hRI st'' hcl
  obtain ⟨hk', hie⟩ := Array.getElem?_eq_some_iff.1 hik
  cases thenSeq_read hthen with
  | next hsh =>
    have ht0 := thenMap_next ht'
    subst ht0
    have hpc1 := hdl_succ_next hpc
    rw [hpc1] at hstep
    have hin1' : S.c.inRegion (s.pc + 1) = true := by rw [hs]; exact hin1
    exact hr_fallthrough hD (pC := hat + len) hP.nop hbe' hripT (.step hstep)
      (by show s.pc + 1 = k + 1; rw [hs]) (hRI' _ hin1') hP.cache
  | br hsh hcond hdecT hc3 =>
    obtain ⟨j, rfl, hj⟩ := thenMap_branch ht'
    obtain ⟨b, rfl, hpc'⟩ := hdl_succ_branch hpc
    have hjlt : j < S.r.protos.size :=
      reducedOf_targets_lt hD.reduced k hk' j (by
        rw [hie]; simp [RSucc.insnTargets, R.Then.targets])
    have hinJ : S.c.inRegion j = true :=
      (hD.region.noCross k hlt _ (by rw [hpk]; simp [Proto.targets, R.Then.targets]) j hjlt
        hj).trans hP.inR
    exact hr_br hD H (pT := hat + len) hs hlt
      (by rw [hpk]; simp [Proto.targets, R.Then.targets]) hj hcond hdecT hbe' hripT hctl hRI'
      hpc' hstep hinJ hin1 hP.nop hP.cache
  | switch hsh htr =>
    obtain ⟨tb, pE, es, hdT, rfl, hes, -⟩ := table_read htr
    obtain ⟨rs', rfl, hmap⟩ := thenMap_table ht'
    obtain ⟨i, rfl, hget⟩ := hdl_succ_table hpc
    obtain ⟨hil, -⟩ := List.getElem?_eq_some_iff.1 hget
    have hlen : rs'.length = es.length := by
      have := congrArg List.length hmap
      simpa using this
    have hil' : i < es.length := hlen ▸ hil
    have hpe : posOf S.r pc = es[i].toNat := by
      have h1 : (rs'.map (posOf S.r))[i]? = (es.map (·.toNat))[i]? := by rw [hmap]
      rw [List.getElem?_map, List.getElem?_map, hget, List.getElem?_eq_getElem hil'] at h1
      simpa using h1
    have htgm : es[i].toNat ∈ S.r.protos[k].targets := by
      rw [hpk]
      simp [Proto.targets, R.Then.targets] <;> exact ⟨es[i], List.getElem_mem hil', rfl⟩
    obtain ⟨htb, hbtb, hes31⟩ :=
      htable (atPos (atPos S.body p) (hat + len)) tb pE es k rfl rfl rfl hdT hes
        (List.ne_nil_of_length_pos (by omega)) hlt (fun e0 he0 => by
          rw [hpk]
          simp [Proto.targets, R.Then.targets] <;> exact ⟨e0, he0, rfl⟩)
    have hjlt : pc < S.r.protos.size :=
      reducedOf_targets_lt hD.reduced k hk' pc (by rw [hie]; exact List.mem_of_getElem? hget)
    have hinP : S.c.inRegion pc = true :=
      (hD.region.noCross k hlt _ htgm pc hjlt hpe).trans hP.inR
    exact hr_switch H (pT := hat + len) hlt hdT hbe' hripT hes htb hbtb hes31 hil' hpe htgm
      hctl hinP hRI' hstep
  | trap hsh hdt hc3 =>
    have ht0 := thenMap_trap ht'
    subst ht0
    exact (hdl_succ_trap hpc).elim

end Ryo.Proofs.DecodeSound
