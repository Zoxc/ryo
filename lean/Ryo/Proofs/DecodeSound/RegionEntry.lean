/-
Ryo.Proofs.DecodeSound.RegionEntry — PE's pad region entered from a cleanup site (PE-T2.1).

- `reach_regionPad`: an unwind out of a call or island at a PE cleanup site comes back through
  the dispatcher's trampoline at the region's entry (`Call.PadCalled`); its `sub rsp, 40;
  jmp r11` (`RegionFacts.start`, at a relocation boundary by `regionEntry_boundary`) reaches the
  pad with `RegionInv` (entered at the trampoline's state) and the empty cache
  (`CacheCleared.pads`).
-/
import Ryo.Proofs.DecodeSound.Region
import Ryo.Proofs.Discharge.PadsLinked
import Ryo.Proofs.Discharge.CacheCleared

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- From a `PadCalled` return out of a call or island (entry state `x1`, its return address in
instruction `k`'s call site `site`) with the frame relation at the pad's R state (`FrameCore`):
the region's entry `sub rsp, 40; jmp r11` reaches the pad with `RegionInv` (entered at `y`), at the pad's position. -/
theorem reach_regionPad (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {s' : R.RState} {x1 y : X86.State} {exc : ThinPointer} {k pad : Nat}
    {site : Nat × Nat} (hpe : S.c.mode.pe = true) (hk : k < S.r.protos.size)
    (hcl : S.c.cleanupAt k = some (some pad, false)) (hpc : s'.pc = pad)
    (hsite : site ∈ S.r.protos[k].sites)
    (hra : x1.mem.read64 x1.rsp = addrAt S.ctx (site.1 + site.2)) (hn : 0 < site.2)
    (hP : Call.PadCalled S.padOf S.region S.lo x1 y exc)
    (hcore : FrameCore S s' y)
    (hbelow : x1.rsp.toNat ≤ (y.reg .rbp).toNat - S.F) :
    Reach S.ctx S.E (fun y' => RBInv S s' y' ∧ y'.rip = addrAt S.ctx (posOf S.r pad)) y := by
  have hfp : S.c.mode.framePointer = true := by
    have hv := hD.modeValid
    cases hf : S.c.mode.framePointer
    · simp [Ryo.Obj.Mode.valid, hpe, hf] at hv
    · rfl
  have hreg := hD.region
  have hin : S.c.inRegion pad = true := hreg.pads k pad hpe hcl
  cases hst : S.c.d.regionStart with
  | none =>
    exfalso
    unfold R.Code.inRegion at hin
    rw [hst] at hin
    simp at hin
  | some rs =>
  obtain ⟨-, hrp, -, hdec⟩ := hreg.start rs hpe hst
  have hlk : LinkOk S.ctx y.mem S.body S.rs := hcore.code.toLinkOk hfp
  have hbd := regionEntry_boundary hD hpe hst hcore.code
  obtain ⟨hca, -, -⟩ := hlk.dec hdec hbd
  generalize hP0 : posOf S.r rs - regionEntryLen = p0 at hca hdec
  obtain ⟨hi1, hi2, -⟩ := hca
  have hyrip : y.rip = addrAt S.ctx p0 := by
    rw [hP.rip, H.unwinderReadsLsda.2.2 _ (by rw [hD.modeEq, hD.callSitesEq]; exact hrp), hP0]
  -- `r11`: the pad's address.
  have hpads := (H.padsLinked hD hcore.code.small) k hk site hsite (site.1 + site.2)
    (by omega) (Nat.le_refl _)
  rw [hcl] at hpads
  have hl := hP.r11
  rw [hra, hpads] at hl
  have hr11 : y.reg .r11 = addrAt S.ctx (posOf S.r pad) := by
    rw [← Option.some.inj hl]
    have h32 := posOf_lt_32 hD hlk (pad_lpad hD hcl).1
    have e : (pos32 S.r pad).setWidth 64 = BitVec.ofNat 64 (posOf S.r pad) := by
      apply BitVec.eq_of_toNat_eq
      rw [BitVec.toNat_setWidth, pos32, BitVec.toNat_ofNat, BitVec.toNat_ofNat,
        Nat.mod_eq_of_lt h32]
    rw [e]; rfl
  -- `sub rsp, 40`.
  obtain ⟨z1, hz1⟩ : ∃ z1, z1 = ((y.jump (y.rip + BitVec.ofNat 64
      (Item.subRsp (BitVec.ofNat 32 peRegionAlloc)).size)).setReg .rsp
      (y.rsp - (BitVec.ofNat 32 peRegionAlloc).signExtend 64)).setFlags
      (subF y.rsp ((BitVec.ofNat 32 peRegionAlloc).signExtend 64)).2 := ⟨_, rfl⟩
  have he1 : Item.exec S.ctx (.subRsp (BitVec.ofNat 32 peRegionAlloc)) y = .ok z1 := by
    rw [hz1]; rfl
  have g1 : ∀ i : Fin 16, i ≠ 4 → z1.regs i = y.regs i := fun i hi => by
    rw [hz1]; show (if i = 4 then _ else y.regs i) = _; rw [if_neg hi]
  have hsx : (BitVec.ofNat 32 peRegionAlloc).signExtend 64 = (40 : BitVec 64) := by decide
  have hz1rsp : z1.rsp = y.rsp - 40 := by
    have e : z1.rsp = y.rsp - (BitVec.ofNat 32 peRegionAlloc).signExtend 64 := by rw [hz1]; rfl
    rw [e, hsx]
  have hz1m : z1.mem = y.mem := by rw [hz1]; rfl
  have hz1rip : z1.rip = addrAt S.ctx (p0 + (Item.subRsp (BitVec.ofNat 32 peRegionAlloc)).size) := by
    rw [hz1]; show y.rip + BitVec.ofNat 64 _ = _; rw [hyrip, addrAt_add]
  -- `jmp r11`.
  obtain ⟨z2, hz2⟩ : ∃ z2, z2 = (z1.jump (z1.rip + BitVec.ofNat 64 Item.jmpR11.size)).jump
      (z1.reg .r11) := ⟨_, rfl⟩
  have he2 : Item.exec S.ctx .jmpR11 z1 = .ok z2 := by rw [hz2]; rfl
  have hz2r : z2.regs = z1.regs := by rw [hz2]; rfl
  have hz2m : z2.mem = y.mem := by rw [hz2, ← hz1m]; rfl
  have hz2rip : z2.rip = addrAt S.ctx (posOf S.r pad) := by
    have e : z2.rip = z1.reg .r11 := by rw [hz2]; rfl
    rw [e, ← hr11]
    exact g1 11 (by decide)
  have hg : ∀ i : Fin 16, i ≠ 4 → z2.regs i = y.regs i := fun i hi => by rw [hz2r]; exact g1 i hi
  have hrbp : z2.reg .rbp = y.reg .rbp := hg 5 (by decide)
  have hz2rsp : z2.rsp = y.rsp - 40 := by
    rw [← hz1rsp]; show z2.regs _ = z1.regs _; rw [hz2r]
  have hal := hP.align
  have hbl := hP.below
  have hro := hP.room
  have hcanon : ∀ (i : Item) (q : Nat), (∀ b e, i ≠ .tableEntry b e) →
      i.wf (BitVec.ofNat 32 q) = true → i.Canonical q := fun _ _ h1 h2 => ⟨h1, .inl h2⟩
  refine Reach.step (.exec _ p0 (hcanon _ _ (fun b e he => by cases he) (by simp [Item.wf]))
    hi1 hyrip he1) ?_
  refine Reach.step (.exec _ _ (hcanon _ _ (fun b e he => by cases he) (by simp [Item.wf]))
    (by rw [hz1m]; exact hi2) hz1rip he2) ?_
  refine .done ⟨(rbInv_region (by rw [hpc]; exact hin)).2 ⟨y, ?_, .inr ⟨?_, ?_⟩⟩, hz2rip⟩
  · exact
      { toFrameCore := hcore.congr hrbp
          (fun i hi => hg i (Call.saved_ne hi).2.2.2) hz2m
        inR := by rw [hpc]; exact hin
        entered := ⟨hP.rip, hal⟩
        rsp := hz2rsp
        align := by rw [hz2rsp]; bv_omega
        below := by rw [hz2rsp, hrbp]; bv_omega
        room := by rw [hz2rsp]; bv_omega
        tramp := by rw [hz2m, hz2rsp, BitVec.sub_add_cancel] }
  · rw [hpc]; exact hz2rip
  · rw [hpc, (H.cacheCleared hD).pads k pad false hcl]; exact RegCache.CacheInv.emptyPe _ _

end Ryo.Proofs.DecodeSound
