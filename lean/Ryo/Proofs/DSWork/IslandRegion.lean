/-
Ryo.Proofs.DSWork.IslandRegion — an island in PE's pad region (PE-T3, `regionSim_island`).

As `bodySim_islandB`: the island's query has no `sp` and `IslandAtB` no `rsp`; the template
writes below `rsp + 8 + 32` (`IslandEnd.mem`), off the frame (`RegionInv.below`) and the
trampoline's return address (`ir_kept`: `RegionInv.allocsOff`-style through the ghost state,
`EnvApart.stackOff`). R's `islandShadow` clears frame bytes as in the body. Unwinds as for calls
(`regionSim_call`): at a cleanup site through the region's entry again (`reach_regionPad`), at a
catching pad (in the region, `RegionFacts.catchPads`) with the region's `rsp`, else no pad.
-/
import Ryo.Proofs.DSWork.Island
import Ryo.Proofs.DecodeSound.RegionEntry
import Ryo.Proofs.DSWork.ResumeRegion

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}


/-- The ghost state's `rbp` and `rsp`. -/
theorem ir_ghost_regs (x : X86.State) :
    (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).reg .rbp = x.reg .rbp ∧
      (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp = x.reg .rbp - BitVec.ofNat 64 S.F :=
  ⟨X86.State.reg_setReg_other x .rsp .rbp _ (by decide), X86.State.reg_setReg x .rsp _⟩

/-- Live allocations after the scopes are off the stack below the region's `rsp` (below the
ghost's: `island_allocs'`). -/
theorem ir_allocs (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {e : X86.State} {s s1 : R.RState} {x : X86.State} (hR : RegionInv S e s x)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) :
    Handler.AllocsApart S.lo s1.st x := by
  obtain ⟨hrbpN, hfp16, -, hbel, -, hfpF⟩ := rgn_nums H hR
  obtain ⟨-, hgsp⟩ := ir_ghost_regs (S := S) x
  have hA := island_allocs' H (hR.ghost hD) hsc
  intro id al hg hl i hi hst
  refine hA id al hg hl i hi ⟨hst.1, ?_⟩
  have h2 := hst.2
  rw [hgsp]
  bv_omega

/-- The frame's addresses are the window's (`FrameFacts.rbp`). -/
theorem ir_fpAddr {s : R.RState} {x : X86.State} (h : FrameCore S s x) (o : Int) :
    fpAddr x o = S.winAddr o := by
  have h1 := h.frame.rbp
  have e : x.reg .rbp = S.x0.rsp - 8 := by bv_omega
  simp only [fpAddr, Setup.winAddr, e]

set_option maxRecDepth 100000 in
/-- `island_kept'` with the allocation clause of `CodeApart` as `CodeOff` (no `BInv`): what the
pad region has (`codeOff_of_region`), applied to its ghost state (`RegionInv.ghost`). -/
theorem island_kept_co (H : Hyps S) {s s1 : R.RState} {x : X86.State} (hf : FrameInv S s x)
    (hco : CodeOff S s)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) (b : BitVec 64)
    (hb : IslandKept S x b) (hF32 : S.c.mode.pe = true → 32 ≤ S.F) :
    ¬ Island.IslandMayWrite S.Owned S.lo (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe))
      s.fp (S.c.lendsAt s.pc) s1.world b := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hwin : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  have hfb := H.frameBounds
  have hFle : (S.F : Int) ≤ 2 ^ 31 := hfb.F_le
  have hKle := hfb.K_le
  have hrsp0 := island_rsp_toNat hf.rrel.rbp (by omega) hfpF hf.rsp
  have hsh : Island.shadow S.c.mode.pe ≤ S.F ∧ Island.shadow S.c.mode.pe ≤ 32 := by
    unfold Island.shadow; split
    · have := hF32 (by assumption); omega
    · omega
  -- The template's stack writes end at `rsp + shadow ≤ fp`.
  have hrsp : (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe)).toNat =
      s.fp - S.F + Island.shadow S.c.mode.pe := by
    rw [BitVec.toNat_add, BitVec.toNat_ofNat, hrsp0,
      Nat.mod_eq_of_lt (show Island.shadow S.c.mode.pe < 2 ^ 64 by omega)]
    exact Nat.mod_eq_of_lt (by omega)
  have hrbp : x.reg .rbp = BitVec.ofNat 64 s.fp := hf.rrel.rbp
  have hW : ∀ o, S.winAddr o = BitVec.ofNat 64 s.fp + BitVec.ofInt 64 o := fun o => by
    rw [← hf.fpAddr_eq]; simp [fpAddr, hrbp]
  have hlendsIn : ∀ l ∈ S.c.lendsAt s.pc, -(S.F : Int) ≤ l.1 ∧ l.1 + l.2 ≤ S.K := by
    intro l hl
    obtain ⟨sc, hsc', rfl⟩ := island_lends_mem hl
    exact hfb.scopes s.pc sc hsc'
  -- A byte off the window: not in a lend extent nor a new allocation.
  have hlend_win : ∀ b, (∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) →
      ¬ ∃ l ∈ S.c.lendsAt s.pc, (b - Island.lendAddr s.fp l.1).toNat < l.2 := by
    rintro b hnw ⟨l, hl, hlt⟩
    have := hlendsIn l hl
    refine hnw (l.1 + (b - Island.lendAddr s.fp l.1).toNat) (by omega) (by omega) ?_
    rw [hW, island_ofInt_add, ← BitVec.add_assoc]
    exact island_sub_toNat rfl
  -- A code or rodata byte.
  have hcode : ∀ b, ((∃ p, p < S.body.code.size ∧ b = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j))) →
      ¬ Island.IslandMayWrite S.Owned S.lo (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe))
        s.fp (S.c.lendsAt s.pc) s1.world b := by
    intro b hb'
    obtain ⟨hown, hstk, hnw, -⟩ := H.codeApart b hb'
    rintro (hst | hl | hal1 | ho)
    · apply hstk
      refine ⟨hst.1, Nat.lt_of_lt_of_le hst.2 ?_⟩
      have h0 : S.x0.rsp = x.reg .rbp + 8 := by have := hf.frame.rbp; bv_omega
      have h8 : (8 : BitVec 64).toNat = 8 := rfl
      rw [hrsp, h0, hrbp, BitVec.toNat_add, BitVec.toNat_ofNat, h8,
        Nat.mod_eq_of_lt (show s.fp < 2 ^ 64 by omega)]
      omega
    · exact hlend_win b hnw hl
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
  rcases hb with hb | ⟨r, hr, k, hk, rfl⟩ | hb | ⟨i, hi, hb⟩
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
    obtain ⟨hesc, hnl⟩ := H.linkPrivate s x s1 hf hsc o ho1 ho2
    rintro (hst | ⟨l, hl, hlt⟩ | ⟨id, al, hg, hlv, hlt⟩ | ho)
    · obtain ⟨-, h2⟩ := hst
      rw [hrsp] at h2
      have : (fpAddr x o).toNat = ((s.fp : Int) + o).toNat := by
        rw [Island.fpAddr_eq_lendAddr hrbp, Island.lendAddr, ← ofNat_frameAddr _ _ (by omega),
          BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by omega)]
      omega
    · apply hnl l hl
      have hli := hlendsIn l hl
      rw [Island.fpAddr_eq_lendAddr hrbp] at hlt
      simp only [Island.lendAddr] at hlt
      have e : BitVec.ofNat 64 s.fp + BitVec.ofInt 64 o - (BitVec.ofNat 64 s.fp + BitVec.ofInt 64 l.1)
          = BitVec.ofInt 64 (o - l.1) := by
        have : BitVec.ofInt 64 o = BitVec.ofInt 64 l.1 + BitVec.ofInt 64 (o - l.1) := by
          rw [← BitVec.ofInt_add]; congr 1; omega
        rw [this]; bv_omega
      rw [e, BitVec.toNat_ofInt] at hlt
      have hsz : l.2 < 2 ^ 62 := by omega
      omega
    · have hsep1 := (sep_foldlM _ (hfb.scopesIn _) (hfb.window hwin) hf.rrel hf.sep hsc).2
      obtain ⟨e, hem, he1, he2, -⟩ := hsep1.own id al o hg hlv hoF (by omega) hlt
      exact escapedAt_none hesc e hem ⟨he1, he2⟩
    · rw [hf.fpAddr_eq] at ho
      exact H.envApart.window o hoF (by omega) ho

/-- The bytes an island in the region must leave alone: `IslandKept` and the trampoline's
return address at `rsp + 40`. -/
def IslandKeptR (S : Setup) (x : X86.State) (b : BitVec 64) : Prop :=
  IslandKept S x b ∨ ∃ i, i < 8 ∧ b = x.rsp + 40 + BitVec.ofNat 64 i

/-- A template called from the region leaves `IslandKeptR` alone: `island_kept_co` at the ghost
state (its stack bound is above the region's), and the trampoline's return address is above
the template's stack writes, below the window, in no allocation (`island_allocs'` at the
ghost) and not runtime-owned (`EnvApart.stackOff`). -/
theorem ir_kept (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {e : X86.State} {s s1 : R.RState} {x : X86.State} (hR : RegionInv S e s x)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) (b : BitVec 64)
    (hb : IslandKeptR S x b) :
    ¬ Island.IslandMayWrite S.Owned S.lo (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe))
      s.fp (S.c.lendsAt s.pc) s1.world b := by
  have hpe := rgn_pe hR.inR
  have hsh : Island.shadow S.c.mode.pe = 32 := by simp [Island.shadow, hpe]
  obtain ⟨hrbpN, hfp16, hx0, hbel, hroom, hfpF⟩ := rgn_nums H hR
  obtain ⟨hg5, hgsp⟩ := ir_ghost_regs (S := S) x
  have hg := hR.ghost hD
  have hF32 : S.c.mode.pe = true → 32 ≤ S.F := H.peShadow
  rw [hsh]
  rcases hb with hb | ⟨i, hi, hbeq⟩
  · have hbg : IslandKept S (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)) b := by
      unfold IslandKept at hb ⊢; rw [hg5]; exact hb
    have hk := island_kept_co H hg (codeOff_of_region H hR) hsc b hbg hF32
    rw [hsh, hgsp] at hk
    rintro (hst | hrest)
    · apply hk
      refine .inl ⟨hst.1, ?_⟩
      have h2 := hst.2
      rw [BitVec.toNat_add, BitVec.toNat_sub, hrbpN, BitVec.toNat_ofNat, BitVec.toNat_ofNat]
      rw [BitVec.toNat_add, BitVec.toNat_ofNat] at h2
      have := x.rsp.isLt
      rw [Nat.mod_eq_of_lt (show S.F < 2 ^ 64 by omega)]
      have e2 : (2 ^ 64 - S.F + s.fp) % 2 ^ 64 = s.fp - S.F := by omega
      rw [e2]
      have := hF32 hpe
      omega
    · exact hk (.inr hrest)
  · have hbN : b.toNat = x.rsp.toNat + 40 + i := by rw [hbeq]; bv_omega
    have hfb := H.frameBounds
    have hwin := hR.win
    have eF : S.F = S.c.d.frameSize := rfl
    rintro (hst | ⟨l, hl, hlt⟩ | ⟨id, al, hga, hlv, hlt⟩ | ho)
    · have h2 := hst.2
      bv_omega
    · obtain ⟨sc, hsc', rfl⟩ := island_lends_mem hl
      have hli := hfb.scopes s.pc sc hsc'
      dsimp only at hlt
      generalize hd : (b - Island.lendAddr s.fp sc.frameOffset.toInt).toNat = d at hlt
      have hb' := island_sub_toNat hd
      have h0 : 0 ≤ (s.fp : Int) + (sc.frameOffset.toInt + d) := by omega
      have e1 : Island.lendAddr s.fp sc.frameOffset.toInt + BitVec.ofNat 64 d =
          BitVec.ofNat 64 ((s.fp : Int) + (sc.frameOffset.toInt + d)).toNat := by
        rw [ofNat_frameAddr _ _ h0, Island.lendAddr, island_ofInt_add, BitVec.add_assoc]
      have hbN2 : b.toNat = ((s.fp : Int) + (sc.frameOffset.toInt + d)).toNat := by
        rw [hb', e1, BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
      omega
    · have hA := island_allocs' H hg hsc
      generalize hd : (b - BitVec.ofNat 64 al.addr).toNat = d at hlt
      have hb' := island_sub_toNat hd
      apply hA id al hga hlv d hlt
      rw [BitVec.ofNat_add, ← hb', hgsp]
      show S.lo.toNat ≤ b.toNat ∧ b.toNat < (x.reg .rbp - BitVec.ofNat 64 S.F).toNat
      refine ⟨by omega, ?_⟩
      bv_omega
    · exact H.envApart.stackOff b ⟨by omega, by omega⟩ ho


/-- `fixResume` leaves a non-`resume` proto alone. -/
theorem ir_fixResume {q : Proto} (h : q.op = .island) : S.fixResume q = q := by
  unfold Setup.fixResume
  rw [h, show (Full.Opcode.island == Full.Opcode.resume) = false from by decide]
  rfl

set_option maxHeartbeats 2000000 in
set_option maxRecDepth 100000 in
/-- PE-T3: an island in PE's pad region. -/
theorem regionSim_island (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsR S k p q c' { pe := S.frR.mode.pe }) (hn : NoArg S.frR S.body p a cur)
    (hr : InsnRead S.frR S.ro cur q c') (hop : q.op = .island) :
    RegionSimB S k p := by
  have hF32 : S.c.mode.pe = true → 32 ≤ S.F := H.peShadow
  have hshF : S.c.islandShadow ≤ S.c.d.frameSize ∧ S.c.islandShadow ≤ 32 := by
    unfold R.Code.islandShadow; split
    · exact ⟨hF32 (by assumption), by omega⟩
    · omega
  have eF : S.F = S.c.d.frameSize := rfl
  intro e s x hs hR hrip hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  have hpe : S.c.mode.pe = true := rgn_pe hP.inR
  have hfpm : S.c.mode.framePointer = true := vt_fp_of_pe hD.modeValid hpe
  have hsp : S.body.spFrame = none := hD.spFrame_of_fp hfpm
  obtain ⟨hlt, ⟨p1, ctr, hpq⟩, ⟨i, hi, hio⟩, hbd, hnop, hcache, hinR⟩ := hP
  cases hr with
  | handler _ _ _ hhh => simp only at hop; subst hop; simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | jmp => simp only at hop; exact absurd hop (by decide)
  | unreachable _ => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | dense hd =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hd
    rw [hw] at hop; cases w <;> exact absurd hop (by decide)
  | @island isl o site ws c'' hic hws =>
  -- The instruction.
  have hpk := (Array.getElem?_eq_some_iff.1 hpq).2.trans (ir_fixResume rfl)
  have hio' := hpk ▸ hio hlt
  simp only [InsnOf] at hio'
  obtain ⟨op, ops, hof, rfl, hops⟩ := hio'
  have hops' : ops = [.sym isl, .words ws] := by
    rcases ops with _ | ⟨o1, _ | ⟨o2, _ | ⟨o3, l⟩⟩⟩ <;> simp at hops
    obtain ⟨h1, h2⟩ := hops
    cases o1 <;> simp [opndMap] at h1
    cases o2 <;> simp [opndMap] at h2
    subst h1 h2; rfl
  subst hops'
  have hf := island_ofFull hof
  have hsh := Island.island_shape
  rw [← hs] at hi
  -- The code (frame-pointer form: the state itself).
  have hlk : LinkOk S.ctx x.mem (atPos S.body p) S.rs :=
    ⟨hR.code.fields, hR.code.sorted, hR.code.loaded, hR.code.small, hsp⟩
  obtain ⟨hd, -⟩ := islandCall_read hic
  obtain ⟨-, hq', hbq⟩ := (hR.code.atPos p).dec hd hbd
  obtain ⟨hs2, hsd⟩ := island_site_read hic
  obtain ⟨-, hsite, -⟩ := (hR.code.atPos p).dec hsd hbd
  have hsite6 : c'.pos = site.1 + 6 := isl_site6 hq' hsite
  obtain ⟨hca, hend, -⟩ := hlk.dec hd hbd
  have hripE : x.rip + BitVec.ofNat 64 (codeSize (Island.islandPre S.c.mode isl o)) =
      addrAt S.ctx c'.pos := by
    rw [hrip, addrAt_add', hend]; rfl
  -- The scopes.
  cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    obtain ⟨m, rfl⟩ := hsafe.1 {} e (island_step_scopes_err hi hsc)
    exact (island_noNB_scopes _ _ m hsc).elim
  | ok s1 =>
  have hstep := island_step_ok hi hf hsc
  have hk := scopes_keeps _ hsc
  rw [hk.pc, hk.fp] at hstep
  have hsafeQ := hsafe.2 {} _ s1 hstep
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hR.win
  have hwin := hfb.window hwinT
  have hsepF : FrameSep (-(S.c.d.frameSize : Int)) S.K s.st x := hR.sep
  have hfpF : S.c.d.frameSize ≤ s.fp := hR.fpF
  have hsep1 := (sep_foldlM _ (hfb.scopesIn _) hwin hR.rrel hsepF hsc).2
  -- Numbers.
  obtain ⟨hrbpN, hfp16, hx0, hbel, hroom, -⟩ := rgn_nums H hR
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hfp64 : s.fp < 2 ^ 64 := by omega
  have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by omega
  have hsh32 : Island.shadow S.c.mode.pe = 32 := by simp [Island.shadow, hpe]
  have hkept := ir_kept hD H hR hsc
  have hrspSh : x.rsp.toNat ≤ (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe)).toNat := by
    rw [hsh32]; bv_omega
  have hnotStack : ∀ b, IslandKept S x b → ¬ InStack S.lo x.rsp b :=
    fun b hb hst => hkept b (.inl hb) (Or.inl ⟨hst.1, Nat.lt_of_lt_of_le hst.2 hrspSh⟩)
  -- The operand array.
  have hroOps := opsAt_of_opsArray hR.ro hws
  have hroA : ∀ j < 4 * (ws.length + 1),
      ¬ InStack S.lo x.rsp (S.ctx.addrOf (.ro o) - 4 + BitVec.ofNat 64 j) := by
    intro j hj
    obtain ⟨base, ha, -⟩ := hR.ro
    obtain ⟨ho, ⟨n, hn, hnl⟩, hw⟩ := opsArray_spec hws
    apply hnotStack
    refine Or.inr (Or.inr (Or.inl ⟨o - 4 + j, ?_, ?_⟩))
    · have h0 : o - 4 + 4 ≤ S.ro.size := by
        unfold rdLE at hn; split at hn
        · omega
        · cases hn
      rcases Nat.eq_zero_or_pos ws.length with hl | hl
      · omega
      · have := hw (ws.length - 1) (by omega)
        unfold rdLE at this; split at this
        · omega
        · cases this
    · rw [ha, ha]
      have e : BitVec.ofNat 64 o = BitVec.ofNat 64 (o - 4) + 4 := by
        rw [show (4 : BitVec 64) = BitVec.ofNat 64 4 from rfl, ← BitVec.ofNat_add,
          Nat.sub_add_cancel ho]
      rw [e, BitVec.ofNat_add]
      bv_omega
  have hsym := H.envApartR.syms e s x hR
  have hap : Handler.StackApart S.lo s1.st x :=
    Handler.FrameSep.stackApart hsep1
      (Handler.stack_off_window (by rw [hrbpN]; omega) (by rw [hrbpN]; omega))
      (ir_allocs hD H hR hsc)
  obtain ⟨x1, -, hex, hat, hrr1, -, -, -, -, hrsp1, hret1, hsv1, hmemS⟩ :=
    Island.island_query S.ctx hi hf hsh hR.rrel hR.mem (hfb.scope_size _) hlo hroOps
      hroA hsym hstep hap
  have hrbp1 : x1.reg .rbp = x.reg .rbp := hat.rbp.trans hR.rrel.rbp.symm
  -- The lends.
  have hlendsIn : ∀ l ∈ S.c.lendsAt s.pc, -(S.c.d.frameSize : Int) ≤ l.1 ∧ l.1 + l.2 ≤ S.K := by
    intro l hl
    obtain ⟨sc, hsc', rfl⟩ := island_lends_mem hl
    exact hfb.scopes s.pc sc hsc'
  have hlends : ∀ l ∈ S.c.lendsAt s.pc, -2 ^ 62 < l.1 ∧ l.1 + l.2 < 2 ^ 62 := by
    intro l hl
    have := hlendsIn l hl; have := hfb.F_le; have := hfb.K_le
    omega
  have hFle : (S.c.d.frameSize : Int) ≤ 2 ^ 31 := hfb.F_le
  have hshB : -2 ^ 62 < -(S.c.d.frameSize : Int) ∧
      -(S.c.d.frameSize : Int) + S.c.islandShadow < 2 ^ 62 := ⟨by omega, by omega⟩
  -- The template's writes below the region's `rsp + 32`: under the frame.
  have hiap : Island.IslandApart S.Owned S.lo (x1.rsp + 8 + BitVec.ofNat 64
      (Island.shadow S.c.mode.pe)) s1.fp (S.c.lendsAt s.pc)
      (-(S.c.d.frameSize : Int), S.c.islandShadow) s1.st := by
    rw [hrsp1, hk.fp]
    have hrspT : (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe)).toNat ≤
        x.rsp.toNat + Island.shadow S.c.mode.pe := by
      rw [BitVec.toNat_add, BitVec.toNat_ofNat]
      exact Nat.le_trans (Nat.mod_le _ _) (Nat.add_le_add_left (Nat.mod_le _ _) _)
    refine Island.FrameSep.islandApart hsep1 ⟨by omega, hwin.hi_le, hwin.top⟩ (by omega)
      hR.rrel.rbp (by omega) ?_ hlends
      (fun o h1 h2 => by
        rw [ir_fpAddr hR.toFrameCore]; exact H.envApart.window o (by omega) h2)
    intro o h1 _ _
    have := hsh32
    omega
  have hi1 : S.c.d.insns[s1.pc]? = some (.native op [.sym isl, .words ws]) := by
    rw [hk.pc]; exact hi
  have hretA : x1.mem.read64 x1.rsp = addrAt S.ctx c'.pos := by
    rw [hret1]; exact hripE
  have hatB := hat.toB
  refine Reach.steps (island_pre_steps hca hrip hex)
    (Reach.env (H.envOutside.island _ _ _ _ _ _ hatB) fun y hy => ?_)
  -- What the template leaves.
  have htramp : ∀ y : X86.State, (∀ b, IslandKeptR S x b → y.mem b = x.mem b) →
      y.mem.read64 (x.rsp + 40) = e.mem.read64 e.rsp := fun y hm => by
    rw [island_read64_kept (fun i hi => hm _ (.inr ⟨i, hi, rfl⟩))]; exact hR.tramp
  by_cases hry : y.rip = x1.mem.read64 x1.rsp
  · -- It returns.
    obtain ⟨a', hretR, hal⟩ := (H.sepAcross.island isl _ _ _ _ s1.st s1.world x1 y x hatB
      hsafeQ hsep1).1 ⟨hy, hry⟩
    have hret' : Island.IslandReturn S.c.mode.pe S.Owned S.lo s1.fp (S.c.lendsAt s.pc) s1.world
        x1 y a' := by rw [hk.fp]; exact hretR
    obtain ⟨st1, st, hw, hw2, hrel⟩ := Island.answer_core hret'.toIslandEnd hrr1 hlends hshB hiap
    obtain ⟨regs, hres⟩ := hretR.result
    have hmemKy : ∀ b, IslandKeptR S x b → y.mem b = x.mem b := by
      intro b hb
      have hnw := hkept b hb
      rw [hretR.mem b (by rw [hrsp1]; exact hnw),
        hmemS b (fun h => hnw (Or.inl ⟨h.1, Nat.lt_of_lt_of_le h.2 hrspSh⟩))]
    have hmemK : ∀ b, IslandKept S x b → y.mem b = x.mem b := fun b hb => hmemKy b (.inl hb)
    have hrbp'' : y.reg .rbp = x.reg .rbp := by
      show y.regs 5 = x.regs 5
      rw [hretR.saved 5 (Island.saved_rbp _)]; exact hrbp1
    have hrbpS : y.reg .rbp = BitVec.ofNat 64 s1.fp := by rw [hrbp'', hR.rrel.rbp, hk.fp]
    obtain ⟨hR'', hM'', hW''⟩ := hrel y rfl hrbpS
    have hw1 : R.writeRanges (s1.withWorld a'.world).st (S.c.lendsAt s1.pc) a'.frame = .ok st1 := by
      rw [hk.pc]; exact hw
    have hans : R.answer S.c s1 a' = .ok (.step { s1.withWorld a'.world with st, pc := s1.pc + 1 }) := by
      rw [IslandLemmas.answer_island a' hi1 hf hsh, IslandLemmas.islandWrites_ok hw1 hw2, hres]; rfl
    have hrspX : y.rsp = x.rsp := by rw [hretR.rsp, hrsp1]
    have hsv'' : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i := fun i hi => by
      rw [hretR.saved i hi, hsv1 i hi]
    have hsepW : FrameSep (-(S.c.d.frameSize : Int)) S.K (s1.withWorld a'.world).st y :=
      FrameSep.extend hsep1 hrbp'' rfl hal.1 hsep1.init hal.2.1 hal.2.2
    have hsep'' := island_sep_writeFrame (island_sep_writeRanges hsepW hlendsIn hw) hw2
      (Int.le_refl _) (by rw [List.length_replicate]; omega)
    have hpc'' : s1.pc + 1 = k + 1 := by rw [hk.pc, hs]
    have hFC : FrameCore S { s1.withWorld a'.world with st, pc := s1.pc + 1 } y :=
      ⟨⟨hR'', hrbpS, hW''⟩, hM'', hsep'', by show (s1.fp : Int) + _ ≤ _; rw [hk.fp]; exact hwinT,
        by show S.c.d.frameSize ≤ s1.fp; rw [hk.fp]; exact hfpF,
        island_link_keptF hR.code hmemK, island_ro_kept hR.ro hmemK,
        island_frame_kept hR.frame hmemK hrbp'' (fun i hi _ => hsv'' i hi),
        (((Discharge.PeStackArg.ArgSlots.scopes H.boundsOk hR.slots hsc).congr
          (st' := (s1.withWorld a'.world).st) rfl
          (fun _ _ _ => rfl)).writeRanges hw (Discharge.PeStackArg.miss_of_ge
            (Discharge.PeStackArg.lends_lo H.boundsOk s.pc))).writeFrame_uninit hw2,
        (((hR.esc.scopes hsc).mono (pc' := s1.pc + 1) (fun h => hk.pc ▸ LeadArg.prev hD h)
          (by have := hk.pc; omega)).congr
          (by rw [writeFrame_escaped hw2, Discharge.EscFrom.writeRanges_escaped hw]; rfl) :)⟩
    have hRI : RegionInv S e { s1.withWorld a'.world with st, pc := s1.pc + 1 } y :=
      { toFrameCore := hFC
        inR := by
          show S.c.inRegion (s1.pc + 1) = true
          rw [hpc'']; exact rgn_mono hinR (Nat.le_succ k)
        entered := hR.entered
        rsp := hrspX.trans hR.rsp
        align := by rw [hrspX]; exact hR.align
        below := by rw [hrspX, hrbp'']; exact hR.below
        room := by rw [hrspX]; exact hR.room
        tramp := by rw [hrspX]; exact htramp y hmemKy }
    have fin : ∀ z : X86.State, z.regs = y.regs → z.xmm = y.xmm → z.mem = y.mem →
        z.rip = addrAt S.ctx (S.start (k + 1)) → Reach S.ctx S.E (RSNext S s) z := by
      intro z hzr _ hzm hzrip
      have hzRI := hRI.congr hzr hzm
      refine .done (.inl ⟨_, .answer hstep hans, (rbInv_region hzRI.inR).2 ⟨e, hzRI, .inl ⟨?_, ?_⟩⟩⟩)
      · change z.rip = addrAt S.ctx (S.start (s1.pc + 1))
        rw [hpc'']; exact hzrip
      · change CacheInv (S.cache (s1.pc + 1)) z
        rw [hpc'', hcache]; exact CacheInv.emptyPe _ _
    have hyrip : y.rip = addrAt S.ctx c'.pos := by rw [hry]; exact hretA
    generalize hE : S.start (k + 1) = pE at hnop fin
    generalize hC : c'.pos = pC at hnop hyrip hbq
    cases hnop with
    | none _ => exact fin y rfl rfl rfl hyrip
    | nop hn9 hby hrl =>
      have hlky := island_link_kept (hR.code.toLinkOk hfpm) hmemK
      obtain ⟨hit, -, -⟩ := nop_itemAt hlky (p := pC) (n := 1) (by omega) (by omega)
        (island_nop_bytes hby) hrl hbq
      refine reach_padding (ns := [1]) (by simp) ⟨hit, trivial⟩ hyrip fun z h1 h2 h3 h4 => ?_
      refine fin z h1 h2 h3 ?_
      rw [h4]; rfl
  · -- It unwinds.
    obtain ⟨a', exc, hres, hendR, hlandR, hal⟩ := (H.sepAcross.island isl _ _ _ _ s1.st s1.world
      x1 y x hatB hsafeQ hsep1).2 ⟨hy, hry⟩
    have hsiteM : site ∈ S.r.protos[k].sites := by rw [hpk]; simp
    have hpads := (H.padsLinked hD hR.code.small) k hlt site hsiteM c'.pos (by omega) (by omega)
    have hcls := (H.cleansLinked hD hR.code.small) k hlt site hsiteM c'.pos (by omega) (by omega)
    have hend' : Island.IslandEnd S.c.mode.pe S.Owned S.lo s1.fp (S.c.lendsAt s.pc) s1.world
        x1 y a' := by rw [hk.fp]; exact hendR
    obtain ⟨st1, st, hw, hw2, hrel⟩ := Island.answer_core hend' hrr1 hlends hshB hiap
    have hmemKy : ∀ b, IslandKeptR S x b → y.mem b = x.mem b := by
      intro b hb
      have hnw := hkept b hb
      rw [hendR.mem b (by rw [hrsp1]; exact hnw),
        hmemS b (fun h => hnw (Or.inl ⟨h.1, Nat.lt_of_lt_of_le h.2 hrspSh⟩))]
    have hmemK : ∀ b, IslandKept S x b → y.mem b = x.mem b := fun b hb => hmemKy b (.inl hb)
    have hw1 : R.writeRanges (s1.withWorld a'.world).st (S.c.lendsAt s1.pc) a'.frame = .ok st1 := by
      rw [hk.pc]; exact hw
    -- No pad: `Landed` (not a cleanup site) at no pad.
    have hnoPad : ∀ (hc : (S.c.mode.pe && S.cleans (x1.mem.read64 x1.rsp)) = false),
        S.padOf (addrAt S.ctx c'.pos) = none → False := fun hc hn => by
      have hl := (hlandR.landed hc).rip
      rw [hretA, hn] at hl; cases hl
    cases hcl : S.c.cleanupAt k with
    | none =>
      rw [hcl] at hpads hcls
      exact (hnoPad (by rw [hretA, hcls]; simp) hpads).elim
    | some pr =>
    obtain ⟨pad?, cat⟩ := pr
    cases pad? with
    | none =>
      rw [hcl] at hpads hcls
      exact (hnoPad (by rw [hretA, hcls]; simp) hpads).elim
    | some pad =>
    rw [hcl] at hpads hcls
    have hpad' : S.c.cleanupAt s1.pc = some (some pad, cat) := by rw [hk.pc, hs]; exact hcl
    have hans : R.answer S.c s1 a' = .ok (.step { s1.withWorld a'.world with
        st := { st with exception := exc }, pc := pad }) := by
      rw [IslandLemmas.answer_island a' hi1 hf hsh, IslandLemmas.islandWrites_ok hw1 hw2, hres]
      simp only [bind, Except.bind]
      unfold R.unwindAt
      simp only [R.RState.withWorld, hpad']
      rfl
    -- The frame after the unwind, from the saved registers.
    have mkCore : (∀ i, Saved S.c.mode.pe i → y.regs i = x1.regs i) →
        y.reg .rbp = x.reg .rbp ∧ FrameCore S { s1.withWorld a'.world with
          st := { st with exception := exc }, pc := pad } y := by
      intro hsv0
      have hrbpY : y.reg .rbp = x.reg .rbp := by
        show y.regs 5 = x.regs 5
        rw [hsv0 5 (Island.saved_rbp _)]; exact hrbp1
      have hrbpS : y.reg .rbp = BitVec.ofNat 64 s1.fp := by rw [hrbpY, hR.rrel.rbp, hk.fp]
      obtain ⟨hR1, hM1, hW1⟩ := hrel y rfl hrbpS
      have hsvY : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i := fun i hi => by
        rw [hsv0 i hi, hsv1 i hi]
      have hsepW : FrameSep (-(S.c.d.frameSize : Int)) S.K (s1.withWorld a'.world).st y :=
        FrameSep.extend hsep1 hrbpY rfl hal.1 hsep1.init hal.2.1 hal.2.2
      have hsepY := island_sep_writeFrame (island_sep_writeRanges hsepW hlendsIn hw) hw2
        (Int.le_refl _) (by rw [List.length_replicate]; omega)
      have hnl := pad_not_leadArg hD hcl
      exact ⟨hrbpY, ⟨⟨⟨hR1.frame, hR1.layout, hR1.zeroSized⟩, hrbpS,
          ⟨hW1.idLt, hW1.idInj, hW1.size, hW1.disj⟩⟩, hM1,
        ⟨hsepY.own, hsepY.init, hsepY.dis, hsepY.space, hsepY.esc⟩,
        by show (s1.fp : Int) + _ ≤ _; rw [hk.fp]; exact hwinT,
        by show S.c.d.frameSize ≤ s1.fp; rw [hk.fp]; exact hfpF,
        island_link_keptF hR.code hmemK, island_ro_kept hR.ro hmemK,
        island_frame_kept hR.frame hmemK hrbpY (fun i hi _ => hsvY i hi),
        ((((Discharge.PeStackArg.ArgSlots.scopes H.boundsOk hR.slots hsc).congr
            (st' := (s1.withWorld a'.world).st) rfl
            (fun _ _ _ => rfl)).writeRanges hw (Discharge.PeStackArg.miss_of_ge
              (Discharge.PeStackArg.lends_lo H.boundsOk s.pc))).writeFrame_uninit hw2).congr
            (st' := { st with exception := exc }) rfl (fun _ _ _ => rfl),
        ((hR.esc.scopes hsc).of_not hnl).congr
          (st' := { st with exception := exc })
          (by rw [writeFrame_escaped hw2, Discharge.EscFrom.writeRanges_escaped hw]; rfl)⟩⟩
    cases cat with
    | true =>
      -- A catching pad: in the region, `rsp` the region's.
      have hland := hlandR.landed (by rw [hretA, hcls]; simp)
      obtain ⟨hrbpY, hFC⟩ := mkCore hland.saved
      have hrspY : y.rsp = x.rsp := by rw [hland.rsp, hrsp1]
      have hyrip : y.rip = addrAt S.ctx (posOf S.r pad) := by
        have hl := hland.rip
        rw [hretA, hpads] at hl
        rw [← Option.some.inj hl]
        have h32 := Nat.lt_of_le_of_lt (posOf_le_size hD (pad_lpad hD hcl).1) hR.code.small
        have e : (pos32 S.r pad).setWidth 64 = BitVec.ofNat 64 (posOf S.r pad) := by
          apply BitVec.eq_of_toNat_eq
          rw [BitVec.toNat_setWidth, pos32, BitVec.toNat_ofNat, BitVec.toNat_ofNat,
            Nat.mod_eq_of_lt h32]
        rw [e]; rfl
      have hRI : RegionInv S e { s1.withWorld a'.world with
          st := { st with exception := exc }, pc := pad } y :=
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
      have hPC := hlandR.padCalled (by rw [hretA, hcls, hpe]; rfl)
      obtain ⟨hrbpY, hFC⟩ := mkCore (fun i hi => hPC.saved i (hpe ▸ hi))
      have hbelow : x1.rsp.toNat ≤ (y.reg .rbp).toNat - S.F := by
        rw [hrbpY, hrbpN]
        have := hrsp1
        bv_omega
      refine (reach_regionPad hD H hpe hlt hcl rfl hsiteM
        (by rw [hretA, hsite6, hs2]) (by omega) hPC hFC hbelow).mono
        fun z hz => .inl ⟨_, .answer hstep hans, hz.1⟩

end Insn

end Ryo.Proofs.DecodeSound
