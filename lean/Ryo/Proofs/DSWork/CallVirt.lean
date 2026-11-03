/-
Ryo.Proofs.DSWork.CallVirt — glue for a call's body without a frame pointer (`nofp` design,
task T5): a callee's entry, return, unwind end and landing carried between a state and the same
state with `rbp` replaced (`entryAt_setRbp`, `callReturn_setRbp`, `callReturn_back`,
`callEnd_back`, `landed_back`), what `steps_of_run_last_fb` needs of the loads before a call or
tail call (`CvItem`), a run of `rip`-free items from a moved `rip` (`cv_execItems_jump`), and the
relation on a real state from its virtual one (`cv_frameInvR`).
-/
import Ryo.Proofs.DSWork.Ret
import Ryo.Proofs.DSWork.Island

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack)
open Ryo.Proofs.Call (WorldRel Saved EntryAt)

/-! ### The callee's contract across `setReg .rbp` -/

/-- `EntryAt` doesn't read `rbp`. -/
theorem entryAt_setRbp {ctx : Ctx} {pe : Bool} {cal : R.Callee} {regs : R.Regs} {sp : Nat}
    {stack : List AbstractByte} {w : R.World} {x : X86.State} (v : BitVec 64)
    (h : EntryAt ctx pe cal regs sp stack w x) :
    EntryAt ctx pe cal regs sp stack w (x.setReg .rbp v) :=
  ⟨h.target, fun r hr => ArgRet.RegRel.congr (h.args r hr)
      (fun i _ => Handler.setRbp_reg x v _ (Island.intArg_ne_rbp pe i)) (fun _ _ => rfl),
    by rw [Handler.setRbp_rsp]; exact h.rsp, h.stack, h.world⟩

/-- A return with `rbp` replaced alike on both ends. -/
theorem callReturn_setRbp {pe : Bool} {Owned : BitVec 64 → Prop} {lo : BitVec 64} {sp n : Nat}
    {w : R.World} {x x' : X86.State} {a : R.Answer} (v : BitVec 64)
    (h : Call.CallReturn pe Owned lo sp n w x x' a) :
    Call.CallReturn pe Owned lo sp n w (x.setReg .rbp v) (x'.setReg .rbp v) a := by
  obtain ⟨rs, hrs, hrr⟩ := h.regs
  refine ⟨Island.callEnd_setRbp v h.toCallEnd, ⟨rs, hrs, fun r hm => ?_⟩, ?_, ?_,
    Handler.setRbp_saved h.saved⟩
  · have := hrr r hm
    cases r with
    | gpr i =>
      simp only [ArgRet.retBytes] at this ⊢
      rw [Handler.setRbp_reg x' v (if i = 0 then .rax else .rdx) (by split <;> decide)]
      exact this
    | xmm i => exact this
  · show x'.rip = x.mem.read64 (x.setReg .rbp v).rsp
    rw [Handler.setRbp_rsp]; exact h.rip
  · rw [Handler.setRbp_rsp, Handler.setRbp_rsp]; exact h.rsp

/-- A return from the real entry (`rbp = r`) is one from the virtual entry `x`, `rbp` set to
`x`'s at the end too. -/
theorem callReturn_back {pe : Bool} {Owned : BitVec 64 → Prop} {lo : BitVec 64} {sp n : Nat}
    {w : R.World} {x y : X86.State} {a : R.Answer} {r : BitVec 64}
    (h : Call.CallReturn pe Owned lo sp n w (x.setReg .rbp r) y a) :
    Call.CallReturn pe Owned lo sp n w x (y.setReg .rbp (x.reg .rbp)) a := by
  have h' := callReturn_setRbp (x.reg .rbp) h
  rwa [vt_setReg_setReg, X86.State.setReg_reg_self] at h'

theorem callEnd_back {Owned : BitVec 64 → Prop} {lo : BitVec 64} {sp n : Nat} {w : R.World}
    {x y : X86.State} {a : R.Answer} {r : BitVec 64}
    (h : Call.CallEnd Owned lo sp n w (x.setReg .rbp r) y a) :
    Call.CallEnd Owned lo sp n w x (y.setReg .rbp (x.reg .rbp)) a := by
  have h' := Island.callEnd_setRbp (x.reg .rbp) h
  rwa [vt_setReg_setReg, X86.State.setReg_reg_self] at h'

theorem landed_back {pe : Bool} {padOf : BitVec 64 → Option (BitVec 64)} {sp0 : BitVec 64}
    {x y : X86.State} {exc : ThinPointer} {r : BitVec 64}
    (h : Call.Landed pe padOf sp0 (x.setReg .rbp r) y exc) :
    Call.Landed pe padOf sp0 x (y.setReg .rbp (x.reg .rbp)) exc := by
  have h' := Island.landed_setRbp (x.reg .rbp) h
  rwa [vt_setReg_setReg, X86.State.setReg_reg_self] at h'

/-! ### Runs from a moved `rip` -/

/-- `rip`-free items run alike from any `rip`, ending moved alike. -/
theorem cv_execItems_jump {ctx : Ctx} : ∀ {L : List Item}, (∀ i ∈ L, i.RipFree ctx) →
    ∀ {s s' : X86.State} (a : BitVec 64), execItems ctx L s = .ok s' →
      execItems ctx L (s.jump a) = .ok (s'.jump (a + BitVec.ofNat 64 (codeSize L)))
  | [], _, s, s', a, h => by
    have e : execItems ctx [] s = .ok s := rfl
    rw [e] at h
    cases h
    have e2 : a + BitVec.ofNat 64 (codeSize ([] : List Item)) = a := by
      show a + BitVec.ofNat 64 0 = a
      first | simp | bv_omega
    rw [e2]
    all_goals rfl
  | i :: L, hr, s, s', a, h => by
    rw [X86.execItems_cons] at h ⊢
    obtain ⟨y, hy, hL⟩ := except_bind_ok h
    have h1 := hr i (by simp) s a
    rw [hy] at h1
    rw [h1]
    have ih := cv_execItems_jump (fun j hj => hr j (by simp [hj])) (a + BitVec.ofNat 64 i.size) hL
    show execItems ctx L (y.jump (a + BitVec.ofNat 64 i.size)) = _
    rw [ih, X86.codeSize_cons, BitVec.ofNat_add, BitVec.add_assoc]

/-! ### The loads before a call -/

/-- What `steps_of_run_fb`/`steps_of_run_last_fb` need of a load before a call without a frame
pointer: its memory form canonical, `rbp` only a memory base, `rsp` kept, `rip`-free. -/
structure CvItem (ctx : Ctx) (F : BitVec 32) (it : Item) : Prop where
  can : ∀ p, (FForm.item (some F) it).Canonical p
  rbp : it.RbpFree
  rsp : it.RspKept ctx
  rip : it.RipFree ctx

theorem cv_ne4 {r : X86.Reg} (h : r.usable = true) : (4 : Fin 16) ≠ r.idx := by
  cases r <;> first | decide | (simp [X86.Reg.usable] at h)

theorem cv_ld (ctx : Ctx) (F : BitVec 32) {w : Ryo.X86.W} {sx : Bool} {r : X86.Reg}
    {m : Ryo.X86.M} (hu : r.usable = true) (hw : ∀ p, (Item.ld w sx r m).wf p = true) :
    CvItem ctx F (.ld w sx r m) :=
  ⟨fun p => ⟨fun _ _ h => (by cases h), .inr ⟨.ld w sx r m, F, hw _, rfl⟩⟩, hw 0,
    fun y y' he => by
      obtain ⟨a, v, e⟩ : ∃ a v, (Item.ld w sx r m).exec ctx y = .ok ((y.jump a).setReg r v) := by
        cases w <;> exact ⟨_, _, rfl⟩
      rw [e] at he
      cases Switch.except_ok_inj he
      exact X86.State.reg_setReg_other _ r .rsp _ (cv_ne4 hu), by intro s a; cases w <;> rfl⟩

theorem cv_movd (ctx : Ctx) (F : BitVec 32) {x : Nat} {r : X86.Reg}
    (hw : ∀ p, (Item.movd true x r).wf p = true) : CvItem ctx F (.movd true x r) :=
  ⟨fun p => ⟨fun _ _ h => (by cases h), .inr ⟨.movd true x r, F, hw _, rfl⟩⟩, hw 0,
    rspKept_movd_to, by intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl)⟩

theorem cv_sse (ctx : Ctx) (F : BitVec 32) {sz x : Nat} {m : Ryo.X86.M}
    (hs : sz = 4 ∨ sz = 8 ∨ sz = 16) (hw : ∀ p, (Item.sse false sz x m).wf p = true) :
    CvItem ctx F (.sse false sz x m) :=
  ⟨fun p => ⟨fun _ _ h => (by cases h), .inr ⟨.sse false sz x m, F, hw _, rfl⟩⟩, hw 0,
    rspKept_sse_ld hs, by intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl)⟩

theorem cv_leaM (ctx : Ctx) (F : BitVec 32) {r : X86.Reg} {m : Ryo.X86.M}
    (hu : r.usable = true) (hw : ∀ p, (Item.leaM r m).wf p = true) : CvItem ctx F (.leaM r m) :=
  ⟨fun p => ⟨fun _ _ h => (by cases h), .inr ⟨.leaM r m, F, hw _, rfl⟩⟩, hw 0,
    fun y y' he => by
      obtain ⟨z, e, -, -, hr, -, -⟩ := Call.exec_leaM ctx r m y
      rw [he] at e
      cases e
      exact hr 4 (cv_ne4 hu),
    by intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl)⟩

theorem cv_loadRip (ctx : Ctx) (F : BitVec 32) (to : Ryo.X86.Ref)
    (hw : ∀ p, (Item.loadRip .rax to).wf p = true) : CvItem ctx F (.loadRip .rax to) :=
  ⟨fun p => ⟨fun _ _ h => (by cases h), .inr ⟨.loadRip .rax to, F, hw _, rfl⟩⟩,
    by first | rfl | decide,
    fun y y' he => by
      obtain ⟨z, e, -, -, hr, -, -⟩ := Call.exec_loadRip ctx .rax to y
      rw [he] at e
      cases e
      exact hr 4 (by decide),
    by intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl)⟩

/-! ### The real state's relation -/

/-- `FrameInvR` of a real state from `FrameInv` of its virtual one `z` (`rbp = rsp + F`). -/
theorem cv_frameInvR {S : Setup} {F : BitVec 32} (hsp : S.body.spFrame = some F)
    {s : R.RState} {z : X86.State} (r : BitVec 64) (hfi : FrameInv S s z)
    (hz : z.reg .rbp = z.rsp + F.setWidth 64) (hr : RbpOk S (z.setReg .rbp r)) :
    FrameInvR S s (z.setReg .rbp r) := by
  refine ⟨?_, hr⟩
  rw [nf_virt_some hsp, Handler.setRbp_rsp, vt_setReg_setReg, ← hz, X86.State.setReg_reg_self]
  exact hfi

end Ryo.Proofs.DecodeSound
