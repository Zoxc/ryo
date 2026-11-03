/-
Ryo.Proofs.DSWork.Virt — glue for the handler and island bodies in either frame form
(`nofp` design, task T4): the virtual frame pointer (`Setup.virt`) at a boundary, the mode facts
`Mode.valid` gives, `fpItem`'s fetch facts in both forms, and the handler's frame separation with
the frame pointer explicit (`SepAcrossHB`).

`SepAcrossHB S r b` is `SepAcross.handler` with the handler's state real (`rbp = r`) and every
relation read with `rbp := b` (the frame pointer), as in `HandlerContractB`. `SepAcross.handler` is
stated in this form (`sepAcrossHB_self`, `sepAcrossHB_nofp`).
-/
import Ryo.Proofs.DecodeSound.Basic

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds

/-! ### States -/

theorem vt_setReg_setReg (x : X86.State) (r : X86.Reg) (a b : BitVec 64) :
    (x.setReg r a).setReg r b = x.setReg r b := by
  cases x
  simp only [X86.State.setReg, X86.State.mk.injEq, and_true]
  funext i
  by_cases h : i = r.idx <;> simp [h]

/-! ### Modes (`Mode.valid`, `Decodes.modeValid`) -/

/-- PE has a frame pointer. -/
theorem vt_fp_of_pe {m : Ryo.Obj.Mode} (hv : m.valid = true) (hpe : m.pe = true) :
    m.framePointer = true := by
  unfold Ryo.Obj.Mode.valid at hv
  rw [hpe] at hv
  cases hfp : m.framePointer <;> simp_all

/-- Without a frame pointer `fp` is passed in a register and the mode isn't PE. -/
theorem vt_fpArg_of_nofp {m : Ryo.Obj.Mode} (hv : m.valid = true) (h : m.framePointer = false) :
    m.fpArg = true ∧ m.pe = false := by
  unfold Ryo.Obj.Mode.valid at hv
  cases hpe : m.pe <;> cases hfa : m.fpArg <;> simp_all

/-- A body cursor in the frame-slots-off-`rsp` form: no frame pointer. -/
theorem vt_nofp_of_sp {S : Setup} {s : R.RState} {x : X86.State} {F : BitVec 32}
    (hf : FrameInv S s x) (hsp : S.body.spFrame = some F) : S.c.mode.framePointer = false := by
  cases h : S.c.mode.framePointer
  · rfl
  · have := hf.code.fp h
    rw [hsp] at this
    cases this

/-! ### The relation at a boundary on the real state -/

/-- `FrameInvR` reads only registers, `xmm`s and memory. -/
theorem FrameInvR.congr' {S : Setup} {s : R.RState} {x y : X86.State} (h : FrameInvR S s x)
    (hr : y.regs = x.regs) (hx : y.xmm = x.xmm) (hm : y.mem = x.mem) : FrameInvR S s y := by
  have hrsp : y.rsp = x.rsp := by simp [X86.State.rsp, X86.State.reg, hr]
  refine ⟨h.1.congr ?_ ?_ ?_, fun hs => ?_⟩
  · funext i
    exact setup_virt_regs_congr S (P := fun _ => True) (fun i _ => by rw [hr]) hrsp i trivial
  · rw [setup_virt_xmm, setup_virt_xmm, hx]
  · rw [setup_virt_mem, setup_virt_mem, hm]
  · have : y.reg .rbp = x.reg .rbp := by simp [X86.State.reg, hr]
    rw [this]; exact h.2 hs

/-- The code in memory, on the real state. -/
theorem FrameInvR.code' {S : Setup} {s : R.RState} {x : X86.State} (h : FrameInvR S s x) :
    LinkOkF S.ctx x.mem S.body S.rs S.c.mode := by
  have := h.1.code
  rwa [setup_virt_mem] at this

/-- The boundary at `posOf` (the instruction's own position, past its padding and counter). -/
theorem vt_bInv_used {S : Setup} {s : R.RState} {x : X86.State} (hf : FrameInvR S s x)
    (hci : CacheInv (S.used s.pc) (S.virt x)) :
    BInv S s (x.jump (addrAt S.ctx (posOf S.r s.pc))) :=
  ⟨⟨by rw [setup_virt_jump]; exact hf.1.congr rfl rfl rfl, hf.2⟩,
    .inr ⟨rfl, by rw [setup_virt_jump]; exact hci⟩⟩

/-! ### `fpItem`, fetched -/

/-- `fp` into `r` (`mov r, rbp` or `lea r, [rbp]`, `fpItem`): canonical everywhere, falling
through, memory kept, in either form. -/
theorem vt_fpItem_ok (ctx : Ctx) (mode : Ryo.Obj.Mode) {r : X86.Reg} (hr : r.usable = true) :
    (∀ p, (fpItem r mode).Canonical p) ∧ (fpItem r mode).FallsThrough ctx ∧
      (fpItem r mode).MemKept ctx := by
  cases hfp : mode.framePointer <;>
    simp only [fpItem, hfp, Bool.false_eq_true, ↓reduceIte]
  · refine ⟨fun p => ⟨fun _ _ h => (by cases h), .inl ?_⟩,
      fun s s' he => by cases Switch.except_ok_inj he; rfl,
      fun s s' he => by cases Switch.except_ok_inj he; rfl⟩
    show (r.usable && Item.memWf (M.frame 0)) = true
    rw [hr]; rfl
  · exact ⟨fun p => ⟨fun _ _ h => (by cases h), .inl rfl⟩,
      fun s s' he => by cases Switch.except_ok_inj he; rfl,
      fun s s' he => by cases Switch.except_ok_inj he; rfl⟩

/-- A handler argument register: usable, neither `rsp` nor `rbp`. -/
theorem vt_handlerRegs (pe : Bool) :
    ∀ r ∈ handlerRegs pe, r.usable = true ∧ Reg.rsp.idx ≠ r.idx ∧ r ≠ .rbp := by
  cases pe <;> decide

/-! ### The frame separation across a handler, the frame pointer explicit -/

/-- `SepAcross.handler` with the handler's state real (`rbp = r`), every relation read with
`rbp := b` (see the module comment). -/
def SepAcrossHB (S : Setup) (r b : BitVec 64) : Prop :=
  ∀ h args vals st (x x' y : X86.State), x.reg .rbp = r → h.hasHandler = true →
    R.unpack S.c.ρ h S.c.mode args = some vals → Handler.AtHandler S.ctx h x →
    Handler.ArgsIn S.c.ρ S.c.mode.pe (x.setReg .rbp b) x args →
    Handler.HRel st (x.setReg .rbp b) → Handler.NoUB h vals st → S.E.ret x x' →
    FrameSep (-(S.F : Int)) S.K st y → fpAddr (x.setReg .rbp b) (-(S.F : Int)) = x.rsp + 8 →
    ∃ ch ctl st', opSem h vals st ch = .ok (ctl, st') ∧
      (∀ st'', R.clearHome S.c.mode.pe args.length (-(S.F : Int)) st' = .ok st'' →
        x'.reg .rbp = r → Handler.HRel st'' (x'.setReg .rbp b)) ∧
      Handler.CtlIn ctl x' ∧ AllocFacts S st st' y

/-- `SepAcross.handler` (stated in this form). -/
theorem sepAcrossHB_self {S : Setup} (H : Hyps S) (r : BitVec 64) : SepAcrossHB S r r :=
  H.sepAcross.handler r r

/-- Without a frame pointer: `SepAcross.handler` (stated for every `r`, `b`). -/
theorem sepAcrossHB_nofp {S : Setup} (H : Hyps S) (r b : BitVec 64) : SepAcrossHB S r b :=
  H.sepAcross.handler r b

/-! ### Table entries in either form -/

/-- `entries_codeAt` from `LinkOkF`: the table entries' reading ignores the frame form. -/
theorem entries_codeAtF {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    {mode : Ryo.Obj.Mode} (hk : LinkOkF ctx m c rs mode) {tb : BitVec 32}
    {es : List (BitVec 32)} {q : Nat}
    (h : ∀ i (hi : i < es.length), (atPos c (q + 4 * i)).tableEntry tb = some es[i])
    (hb : Boundary rs q) : CodeAt ctx m (es.map (Item.tableEntry tb)) q :=
  entries_codeAt (c := { c with spFrame := none })
    ⟨hk.fields, hk.sorted, hk.loaded, hk.small, rfl⟩ (fun i hi => h i hi) hb

end Ryo.Proofs.DecodeSound
