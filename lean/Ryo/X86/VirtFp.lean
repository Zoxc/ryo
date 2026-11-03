/-
Ryo.X86.VirtFp — the virtual frame pointer: code without a frame pointer run as if it had one
(`nofp` design §2.1).

Without a frame pointer the encoder addresses frame slots as `[rsp + F + d]` and `rbp` is the
caller's, untouched; the decoder returns those items in the frame-pointer form `[rbp + d]`
(`Cursor.spFrame`, `Item.spFrame`). Wherever the body runs, `rsp + F` is `fp`, so the item-level
proofs run on the *virtual* state, the real one with `rbp := rsp + F` (`FForm.virt`), and the
items in their frame-pointer form; this file is the bridge between that virtual run and the real
machine fetching the `spFrame` items.

- `FForm`: the frame form, `Cursor.spFrame` (`none`: frame pointer). `FForm.item` maps an item
  to the form in memory, `FForm.virt` a real state to the virtual one, `FForm.real` back (the
  real `rbp`, constant over the function).
- `Item.RbpFree`: an item that uses `rbp` only as a memory base; `Item.SpDispOk F`: its frame
  operand's displacement doesn't wrap in the `spFrame` form; `Item.RspKept`: it keeps `rsp`.
- `FForm.virtAt fb items x`: the virtual state from which `items` run, `rip` shifted by the
  difference of the two forms' sizes (`FForm.delta`): the items with a frame operand, whose
  sizes differ, fall through, so the shift is used up by the run's end and a final `call` pushes
  the real return address.
- `exec_item_virt`, `execItems_virt`, `steps_of_run_fb`, `steps_of_run_last_fb`,
  `faults_of_run_fb`: the bridge (statements; Stage 1 task T1 proves them). In the frame-pointer
  form every one is the plain lemma (`FForm.item_none`, `FForm.virt_none`, `FForm.real_none`).
- `VRet`: an environment relation on real states read on virtual ones (`rbp` replaced alike
  before and after); the contracts' `.virt` forms use it.
-/
import Ryo.X86.Fetch
import Ryo.X86.VRet

set_option maxHeartbeats 400000

namespace Ryo.X86

/-- The frame form: `Cursor.spFrame` (`none`: frame pointer; `some F`: frame slots off `rsp`
with frame size `F`). -/
abbrev FForm := Option (BitVec 32)

namespace FForm

/-- The item as it is in memory. -/
def item : FForm → Item → Item
  | none, i => i
  | some F, i => i.spFrame F

/-- The virtual state: `rbp := rsp + F` (frame-pointer form: the state itself). -/
def virt : FForm → State → State
  | none, x => x
  | some F, x => x.setReg .rbp (x.rsp + F.setWidth 64)

/-- The real state of a virtual one, `r` the real `rbp` (frame-pointer form: the state itself). -/
def real : FForm → BitVec 64 → State → State
  | none, _, x => x
  | some _, r, x => x.setReg .rbp r

/-- How much longer `items` are in memory than in the frame-pointer form (mod `2 ^ 64`). -/
def delta (fb : FForm) (items : List Item) : BitVec 64 :=
  BitVec.ofNat 64 (codeSize (items.map (FForm.item fb))) - BitVec.ofNat 64 (codeSize items)

/-- The virtual state `items` run from: `virt`, with `rip` shifted by `delta` (see the module
comment). -/
def virtAt : FForm → List Item → State → State
  | none, _, x => x
  | some F, items, x => (FForm.virt (some F) x).jump (x.rip + delta (some F) items)

@[simp] theorem item_none : FForm.item none = id := rfl
@[simp] theorem item_none_apply (i : Item) : FForm.item none i = i := rfl
@[simp] theorem map_item_none (items : List Item) : items.map (FForm.item none) = items := by
  simp
@[simp] theorem virt_none (x : State) : FForm.virt none x = x := rfl
@[simp] theorem real_none (r : BitVec 64) (x : State) : FForm.real none r x = x := rfl
@[simp] theorem virtAt_none (items : List Item) (x : State) : FForm.virtAt none items x = x := rfl

end FForm

namespace Item

/-- Whether the item uses `rbp` only as a memory base: no `push rbp`/`pop rbp`/`leave`, no
`rbp` register operand (`Reg.usable` for the native items, `Item.wf`). -/
def rbpFree : Item → Bool
  | pushRbp | popRbp | leave => false
  | mov d s => d != .rbp && s != .rbp
  | setReg r _ | lea r _ | loadRip r _ => r != .rbp
  | branch .. => true
  | i => i.wf 0

/-- `rbpFree` as a proposition. NOFP-T1 may refine it to what `exec_item_virt` needs. -/
def RbpFree (i : Item) : Prop := i.rbpFree = true

/-- The item's frame operand (`[rbp + d]`) doesn't wrap in its `spFrame F` form `[rsp + d + F]`:
the 32-bit displacement's signed value is `d + F`. -/
def SpDispOk (F : BitVec 32) (i : Item) : Prop :=
  ∀ m, i.mem? = some m → m.base = .rbp → (m.disp + F).toInt = m.disp.toInt + F.toNat

/-- The item keeps `rsp` whenever it runs. -/
def RspKept (ctx : Ctx) (i : Item) : Prop :=
  ∀ y y', i.exec ctx y = .ok y' → y'.rsp = y.rsp

end Item

namespace FForm

theorem idx_ne_rbp {r : Reg} (h : r ≠ .rbp) : r.idx ≠ Reg.rbp.idx := by
  cases r <;> first | exact absurd rfl h | decide

theorem setReg_setReg (s : State) (r : Reg) (v w : BitVec 64) :
    (s.setReg r v).setReg r w = s.setReg r w := by
  cases s
  simp only [State.setReg, State.mk.injEq, and_true]
  funext i
  by_cases h : i = r.idx <;> simp [h]

theorem reg_setReg_rbp {r : Reg} (h : r ≠ .rbp) (s : State) (v : BitVec 64) :
    (s.setReg .rbp v).reg r = s.reg r :=
  State.reg_setReg_other s .rbp r v (idx_ne_rbp h)

theorem rsp_setReg_rbp (s : State) (v : BitVec 64) : (s.setReg .rbp v).rsp = s.rsp :=
  reg_setReg_rbp (by decide) s v

/-- `real` undoes `virt` on a state whose `rbp` is `r`. -/
theorem real_virt_eq (fb : FForm) (x : State) : FForm.real fb (x.reg .rbp) (FForm.virt fb x) = x := by
  cases fb with
  | none => rfl
  | some F =>
    show (x.setReg .rbp _).setReg .rbp (x.reg .rbp) = x
    rw [setReg_setReg, State.setReg_reg_self]

end FForm

/-! ### The bridge -/

/-- The item's runs don't depend on `rip` but through their end: started at `a`, a run ends where
it would have, moved to `a + size` (falls through; not a call, which pushes `rip`). Every run
of an item but a list's last satisfies it in the bridge (`execItems_virt`): a jump taken in
the middle of a list would land at the same address in both forms, not at the next item of
each. -/
def Item.RipFree (ctx : Ctx) (i : Item) : Prop :=
  ∀ s a, i.exec ctx (s.jump a) = (i.exec ctx s).map (·.jump (a + BitVec.ofNat 64 i.size))

theorem Item.RipFree.fallsThrough {ctx : Ctx} {i : Item} (h : i.RipFree ctx) :
    i.FallsThrough ctx := by
  intro s s' hs
  have h1 := h s s.rip
  have e : s.jump s.rip = s := rfl
  rw [e, hs] at h1
  have h2 : (Except.ok s' : Except Fault State) =
      Except.ok (s'.jump (s.rip + BitVec.ofNat 64 i.size)) := h1
  injection h2 with h3
  exact (congrArg State.rip h3).trans rfl


namespace VC

theorem setReg_comm {r : Reg} (h : r ≠ .rbp) (s : State) (v w : BitVec 64) :
    (s.setReg .rbp v).setReg r w = (s.setReg r w).setReg .rbp v := by
  have hi := FForm.idx_ne_rbp h
  cases s
  simp only [State.setReg, State.mk.injEq, and_true]
  funext i
  by_cases h1 : i = r.idx
  · subst h1; simp [hi]
  · simp [h1]
theorem reg_rbp {r : Reg} (h : r ≠ .rbp) (s : State) (v : BitVec 64) :
    (s.setReg .rbp v).reg r = s.reg r := FForm.reg_setReg_rbp h s v
theorem rsp_rbp (s : State) (v : BitVec 64) : (s.setReg .rbp v).rsp = s.rsp := FForm.rsp_setReg_rbp s v
theorem regW_rbp {r : Reg} (h : r ≠ .rbp) (s : State) (v : BitVec 64) (w : W) :
    (s.setReg .rbp v).regW w r = s.regW w r := by simp only [State.regW, reg_rbp h]
theorem ea_rbp {m : M} (h : m.base ≠ .rbp) (s : State) (v : BitVec 64) :
    (s.setReg .rbp v).ea m = s.ea m := by simp only [State.ea, reg_rbp h]
theorem setRegW_comm {r : Reg} (h : r ≠ .rbp) (s : State) (v : BitVec 64) (w : W) (u : BitVec w.bits) :
    (s.setReg .rbp v).setRegW w r u = (s.setRegW w r u).setReg .rbp v := by
  cases w <;> simp only [State.setRegW, reg_rbp h, setReg_comm h]
theorem push_rbp (s : State) (v u : BitVec 64) :
    (s.setReg .rbp v).push u = (s.push u).setReg .rbp v := by
  simp only [State.push, rsp_rbp, setReg_comm (show Reg.rsp ≠ .rbp by decide)]; rfl
theorem jump_setReg (s : State) (a : BitVec 64) (r : Reg) (v : BitVec 64) :
    (s.jump a).setReg r v = (s.setReg r v).jump a := rfl
theorem setFlags_rbp (s : State) (v : BitVec 64) (f : Flags) :
    (s.setReg .rbp v).setFlags f = (s.setFlags f).setReg .rbp v := rfl
theorem setMem_rbp (s : State) (v : BitVec 64) (a : BitVec 64) (n x : Nat) :
    (s.setReg .rbp v).setMem a n x = (s.setMem a n x).setReg .rbp v := rfl
theorem setMemW_rbp (s : State) (v : BitVec 64) (w : W) (a : BitVec 64) (x : BitVec w.bits) :
    (s.setReg .rbp v).setMemW w a x = (s.setMemW w a x).setReg .rbp v := rfl
theorem setXmm_rbp (s : State) (v : BitVec 64) (i : Fin 16) (x : BitVec 128) :
    (s.setReg .rbp v).setXmm i x = (s.setXmm i x).setReg .rbp v := rfl
theorem rip_sr (s : State) (r : Reg) (v : BitVec 64) : (s.setReg r v).rip = s.rip := rfl
theorem flags_sr (s : State) (r : Reg) (v : BitVec 64) : (s.setReg r v).flags = s.flags := rfl
theorem mem_sr (s : State) (r : Reg) (v : BitVec 64) : (s.setReg r v).mem = s.mem := rfl
theorem xmm_sr (s : State) (r : Reg) (v : BitVec 64) : (s.setReg r v).xmm = s.xmm := rfl
theorem memW_sr (s : State) (r : Reg) (v : BitVec 64) (w : W) (a : BitVec 64) :
    (s.setReg r v).memW w a = s.memW w a := rfl
theorem reg_jump (s : State) (a : BitVec 64) (r : Reg) : (s.jump a).reg r = s.reg r := rfl
theorem rsp_jump (s : State) (a : BitVec 64) : (s.jump a).rsp = s.rsp := rfl
theorem regW_jump (s : State) (a : BitVec 64) (w : W) (r : Reg) : (s.jump a).regW w r = s.regW w r := rfl
theorem ea_jump (s : State) (a : BitVec 64) (m : M) : (s.jump a).ea m = s.ea m := rfl
theorem memW_jump (s : State) (a : BitVec 64) (w : W) (b : BitVec 64) : (s.jump a).memW w b = s.memW w b := rfl
theorem flags_jump (s : State) (a : BitVec 64) : (s.jump a).flags = s.flags := rfl
theorem mem_jump (s : State) (a : BitVec 64) : (s.jump a).mem = s.mem := rfl
theorem xmm_jump (s : State) (a : BitVec 64) : (s.jump a).xmm = s.xmm := rfl
theorem jump_push (s : State) (a u : BitVec 64) : (s.jump a).push u = (s.push u).jump a := rfl
theorem jump_setRegW (s : State) (a : BitVec 64) (w : W) (r : Reg) (u : BitVec w.bits) :
    (s.jump a).setRegW w r u = (s.setRegW w r u).jump a := by cases w <;> rfl
theorem jump_setFlags (s : State) (a : BitVec 64) (f : Flags) : (s.jump a).setFlags f = (s.setFlags f).jump a := rfl
theorem jump_setMem (s : State) (a b : BitVec 64) (n x : Nat) : (s.jump a).setMem b n x = (s.setMem b n x).jump a := rfl
theorem jump_setMemW (s : State) (a b : BitVec 64) (w : W) (x : BitVec w.bits) :
    (s.jump a).setMemW w b x = (s.setMemW w b x).jump a := rfl
theorem jump_setXmm (s : State) (a : BitVec 64) (i : Fin 16) (x : BitVec 128) :
    (s.jump a).setXmm i x = (s.setXmm i x).jump a := rfl
theorem ea_setFlags (s : State) (f : Flags) (m : M) : (s.setFlags f).ea m = s.ea m := rfl
theorem setReg_same (s : State) (r : Reg) (v w : BitVec 64) : (s.setReg r v).setReg r w = s.setReg r w :=
  FForm.setReg_setReg s r v w

end VC

local macro "vc_simp" : tactic => `(tactic| simp only [Item.exec, State.pop, State.rmW, State.setRmW, VC.reg_rbp, VC.rsp_rbp, VC.regW_rbp,
      VC.ea_rbp, VC.setReg_comm, VC.setRegW_comm, VC.push_rbp, VC.jump_setReg, VC.setFlags_rbp,
      VC.setMem_rbp, VC.setMemW_rbp, VC.setXmm_rbp, VC.rip_sr, VC.flags_sr, VC.mem_sr, VC.xmm_sr,
      VC.memW_sr, VC.reg_jump, VC.rsp_jump, VC.regW_jump, VC.ea_jump, VC.memW_jump, VC.flags_jump,
      VC.mem_jump, VC.xmm_jump, VC.setReg_same, VC.jump_push, VC.jump_setRegW, VC.jump_setFlags, VC.jump_setMem, VC.jump_setMemW, VC.jump_setXmm, ne_eq, not_false_eq_true, reduceCtorEq, *])

/-- An item without a frame operand that doesn't name `rbp` (a call, `callR11`, `addRsp`,
`ret`, a jump): its run commutes with setting `rbp`. -/
theorem exec_commute_rbp {ctx : Ctx} {i : Item} (hf : i.RbpFree)
    (hno : ∀ m, i.mem? = some m → m.base ≠ .rbp) (x : State) (v : BitVec 64) :
    i.exec ctx (x.setReg .rbp v) = (i.exec ctx x).map (·.setReg .rbp v) := by
  cases i <;> (try cases ‹Rm›) <;>
    simp [Item.RbpFree, Item.rbpFree, Item.wf, Reg.usable, Item.rmWf, Item.memWf] at hf <;>
    simp [Item.mem?] at hno <;>
    vc_simp
  all_goals (try rfl)
  all_goals (try (cases ‹W› <;> rfl))
  all_goals (try (split <;> rfl))
  all_goals (try (cases ‹W› <;> split <;> rfl))
  all_goals (try (cases Cond.eval x.flags ‹Cond› with
    | error => rfl
    | ok b => cases b <;> rfl))
  all_goals (try (simp_all; done))
  all_goals (try ((repeat' split) <;> rfl))
  all_goals (try (cases ‹W› <;> simp [Item.RbpFree, Item.rbpFree, Item.wf, Reg.usable] at hf <;> vc_simp <;> rfl))
  all_goals (cases ‹Sh› <;> cases ‹W› <;>
    simp only [Sh.isShift, Bool.false_eq_true, ↓reduceIte, W.bits, beq_self_eq_true, reduceCtorEq] <;>
    (repeat' split) <;> first | rfl | (simp_all; done) | (simp_all <;> rfl))

theorem VC.sext_add {d F : BitVec 32} (h : (d + F).toInt = d.toInt + F.toNat) :
    F.setWidth 64 + d.signExtend 64 = (d + F).signExtend 64 := by
  apply BitVec.eq_of_toInt_eq
  rw [BitVec.toInt_signExtend_of_le (by decide), h, BitVec.toInt_add]
  rw [BitVec.toInt_signExtend_of_le (by decide)]
  have h1 : (F.setWidth 64).toInt = F.toNat := by
    rw [BitVec.toInt_eq_toNat_cond, BitVec.toNat_setWidth]
    have := F.isLt
    split <;> omega
  rw [h1]
  have := BitVec.le_toInt d
  have := @BitVec.toInt_lt 32 d
  have := F.isLt
  rw [Int.bmod_eq_of_le] <;> omega

/-- An item without a frame operand is its own `spFrame` form. -/
theorem spFrame_of_noFrame {F : BitVec 32} {i : Item} (h : ∀ m, i.mem? = some m → m.base ≠ .rbp) :
    i.spFrame F = i := by
  cases i <;> (try cases ‹Rm›) <;> simp_all [Item.spFrame, Item.mapMem, Item.mem?]

/-- A frame item's `spFrame` form from a state with `rbp` replaced: the frame-pointer form, then
`rbp` replaced. -/
theorem exec_frame_core {ctx : Ctx} {F : BitVec 32} {i : Item} {m : M} (hf : i.RbpFree)
    (hm : i.mem? = some m) (hb : m.base = .rbp) (xv : State) (r : BitVec 64)
    (hE : xv.ea m = xv.ea ⟨.rsp, m.disp + F⟩) :
    (i.spFrame F).exec ctx (xv.setReg .rbp r) = (i.exec ctx xv).map
      (fun y => (y.setReg .rbp r).jump (xv.rip + BitVec.ofNat 64 (i.spFrame F).size)) := by
  have hb' : (m.base == Reg.rbp) = true := by rw [hb]; rfl
  cases i <;> (try cases ‹Rm›) <;> simp only [Item.mem?, reduceCtorEq, Option.some.injEq] at hm <;>
    subst hm <;>
    simp [Item.RbpFree, Item.rbpFree, Item.wf, Reg.usable, Item.rmWf, Item.memWf] at hf <;>
    simp only [Item.spFrame, Item.mapMem, hb', ↓reduceIte] <;>
    simp only [Item.exec, State.pop, State.rmW, State.setRmW, VC.reg_rbp, VC.rsp_rbp, VC.regW_rbp,
      VC.ea_rbp, VC.setReg_comm, VC.setRegW_comm, VC.push_rbp, VC.jump_setReg, VC.setFlags_rbp,
      VC.setMem_rbp, VC.setMemW_rbp, VC.setXmm_rbp, VC.rip_sr, VC.flags_sr, VC.mem_sr, VC.xmm_sr,
      VC.memW_sr, VC.reg_jump, VC.rsp_jump, VC.regW_jump, VC.ea_jump, VC.memW_jump, VC.flags_jump,
      VC.mem_jump, VC.xmm_jump, VC.jump_push, VC.jump_setRegW, VC.jump_setFlags, VC.jump_setMem,
      VC.jump_setMemW, VC.jump_setXmm, VC.setReg_same, VC.ea_setFlags, hE, ne_eq, not_false_eq_true, reduceCtorEq, *]
  all_goals (try rfl)
  all_goals (try (cases ‹W› <;> rfl))
  all_goals (try (cases Cond.eval xv.flags ‹Cond› with
    | error => rfl
    | ok b => cases b <;> rfl))
  all_goals (try ((repeat' split) <;> first | rfl | (simp_all; done) | (simp_all <;> rfl)))
  all_goals (try (cases ‹W› <;> (repeat' split) <;> first | rfl | (simp_all; done) | (simp_all <;> rfl)))
  all_goals (try (cases ‹Alu› <;> rfl))
  done

/-- One item with a frame operand (it falls through): its `spFrame` form from the real state is
its frame-pointer form from the virtual one, then the real `rbp` and the real next `rip`. -/
theorem exec_item_virt {ctx : Ctx} {F : BitVec 32} {i : Item} (hf : i.RbpFree)
    (hd : i.SpDispOk F)
    (hft : ∀ y y', i.exec ctx y = .ok y' → y'.rip = y.rip + BitVec.ofNat 64 i.size) (x : State) :
    (i.spFrame F).exec ctx x = (i.exec ctx (FForm.virt (some F) x)).map
      (fun y => (y.setReg .rbp (x.reg .rbp)).jump (x.rip + BitVec.ofNat 64 (i.spFrame F).size)) := by
  have hx : (FForm.virt (some F) x).setReg .rbp (x.reg .rbp) = x := FForm.real_virt_eq (some F) x
  by_cases hfr : ∃ m, i.mem? = some m ∧ m.base = .rbp
  · obtain ⟨m, hm, hb⟩ := hfr
    have hdm := hd m hm hb
    have hE : (FForm.virt (some F) x).ea m = (FForm.virt (some F) x).ea ⟨.rsp, m.disp + F⟩ := by
      show (x.setReg .rbp (x.rsp + F.setWidth 64)).reg m.base + m.disp.signExtend 64 =
        (x.setReg .rbp (x.rsp + F.setWidth 64)).reg .rsp + (m.disp + F).signExtend 64
      rw [hb, State.reg_setReg, FForm.reg_setReg_rbp (by decide), ← VC.sext_add hdm]
      show x.rsp + _ + _ = x.rsp + _
      rw [BitVec.add_assoc]
    calc (i.spFrame F).exec ctx x
        = (i.spFrame F).exec ctx ((FForm.virt (some F) x).setReg .rbp (x.reg .rbp)) := by rw [hx]
      _ = _ := exec_frame_core hf hm hb _ _ hE
  · have hno : ∀ m, i.mem? = some m → m.base ≠ .rbp := fun m hm hb => hfr ⟨m, hm, hb⟩
    rw [spFrame_of_noFrame hno]
    have hc := exec_commute_rbp (ctx := ctx) hf hno (FForm.virt (some F) x) (x.reg .rbp)
    rw [hx] at hc
    rw [hc]
    cases hy : i.exec ctx (FForm.virt (some F) x) with
    | error e => rfl
    | ok y =>
      have hr := hft _ _ hy
      show Except.ok (y.setReg .rbp (x.reg .rbp)) =
        Except.ok ((y.setReg .rbp (x.reg .rbp)).jump ((FForm.virt (some F) x).rip + BitVec.ofNat 64 i.size))
      rw [← hr]
      rfl

/-- An item that doesn't name `rbp` keeps it. -/
theorem exec_rbp_kept {ctx : Ctx} {i : Item} (hf : i.RbpFree) {y y' : State}
    (h : i.exec ctx y = .ok y') : y'.reg .rbp = y.reg .rbp := by
  have hR : ∀ (s : State) (r : Reg) (v : BitVec 64), r ≠ .rbp → (s.setReg r v).reg .rbp = s.reg .rbp :=
    fun s r v hr => State.reg_setReg_other s r .rbp v (fun e => hr (by
      cases r <;> first | rfl | exact absurd e (by decide)))
  have hRW : ∀ (s : State) (w : W) (r : Reg) (v : BitVec w.bits), r ≠ .rbp →
      (s.setRegW w r v).reg .rbp = s.reg .rbp := by
    intro s w r v hr; cases w <;> exact hR _ _ _ hr
  have hRM : ∀ (s : State) (w : W) (rm : Rm) (v : BitVec w.bits), (∀ r, rm = .reg r → r ≠ .rbp) →
      (s.setRmW w rm v).reg .rbp = s.reg .rbp := by
    intro s w rm v hr; cases rm with
    | reg r => exact hRW _ _ _ _ (hr r rfl)
    | mem m => rfl
  have hJ : ∀ (s : State) a, (s.jump a).reg .rbp = s.reg .rbp := fun _ _ => rfl
  have hF : ∀ (s : State) f, (s.setFlags f).reg .rbp = s.reg .rbp := fun _ _ => rfl
  have hM : ∀ (s : State) a n v, (s.setMem a n v).reg .rbp = s.reg .rbp := fun _ _ _ _ => rfl
  have hMW : ∀ (s : State) w a v, (s.setMemW w a v).reg .rbp = s.reg .rbp := fun _ _ _ _ => rfl
  have hX : ∀ (s : State) x v, (s.setXmm x v).reg .rbp = s.reg .rbp := fun _ _ _ => rfl
  have hP : ∀ (s : State) v, (s.push v).reg .rbp = s.reg .rbp := fun s v =>
    (hM _ _ _ _).trans (hR _ _ _ (by decide))
  have hrsp : Reg.rsp ≠ .rbp := by decide
  cases i <;> simp [Item.RbpFree, Item.rbpFree, Item.wf, Reg.usable, Item.rmWf, Item.memWf] at hf <;>
    simp only [Item.exec, bind, Except.bind, pure, Except.pure, State.pop] at h
  all_goals (repeat' split at h)
  all_goals (first | (cases h; done) | skip)
  all_goals (try (simp only [reduceCtorEq] at h; done))
  all_goals (try (cases h))
  all_goals (try (cases ‹Rm›))
  all_goals (simp_all [hR, hRW, hRM, hJ, hF, hM, hMW, hX, hP, State.setRmW])
  all_goals (cases ‹W› <;> simp_all [Item.wf, Reg.usable, hRW])

namespace FForm

theorem ar1 (x a' a d : BitVec 64) : x + a' + d = x + (a' - a + d) + a := by grind
theorem ar2 (a' c' a c : BitVec 64) : a' + c' - (a + c) = a' - a + (c' - c) := by grind
theorem ar3 (x a' a : BitVec 64) : x + (a' - a + 0) + a = x + a' := by grind
theorem ar4 (a' b a : BitVec 64) : a' + b - (a + b) = a' - a := by grind

theorem delta_nil (F : BitVec 32) : delta (some F) [] = 0 := by
  first | rfl | simp [delta, codeSize]

theorem delta_cons (F : BitVec 32) (i : Item) (rest : List Item) :
    delta (some F) (i :: rest) =
      BitVec.ofNat 64 (i.spFrame F).size - BitVec.ofNat 64 i.size + delta (some F) rest := by
  simp only [delta, List.map_cons, codeSize_cons, item, BitVec.ofNat_add]
  exact ar2 _ _ _ _

theorem virt_jump_eq {F : BitVec 32} {y : State} {r V n m : BitVec 64} (hV : y.reg .rbp = V)
    (hrsp : y.rsp + F.setWidth 64 = V) :
    (FForm.virt (some F) ((y.setReg .rbp r).jump n)).jump m = y.jump m := by
  show (((y.setReg .rbp r).jump n).setReg .rbp
    (((y.setReg .rbp r).jump n).rsp + F.setWidth 64)).jump m = y.jump m
  have h1 : ((y.setReg .rbp r).jump n).rsp = y.rsp := rsp_setReg_rbp y r
  rw [h1, hrsp]
  show ((y.setReg .rbp r).setReg .rbp V).jump m = y.jump m
  rw [setReg_setReg, ← hV, State.setReg_reg_self]

/-- One step of the bridge, from any real state, the virtual one at its shifted `rip`. -/
theorem step_virt {ctx : Ctx} {F : BitVec 32} {i : Item} (hf : i.RbpFree) (hd : i.SpDispOk F)
    (hr : i.RipFree ctx) (x : State) (rest : List Item) :
    (i.spFrame F).exec ctx x =
      (i.exec ctx ((FForm.virt (some F) x).jump (x.rip + delta (some F) (i :: rest)))).map
        (fun yv => (yv.setReg .rbp (x.reg .rbp)).jump (x.rip + BitVec.ofNat 64 (i.spFrame F).size)) := by
  have hr' : ∀ s a, i.exec ctx (s.jump a) =
      (i.exec ctx s).map (·.jump (a + BitVec.ofNat 64 i.size)) := hr
  rw [hr', exec_item_virt hf hd hr.fallsThrough x]
  cases i.exec ctx (FForm.virt (some F) x) <;> rfl

/-- After a step that keeps `rsp`, the virtual state is the next real one's. -/
theorem step_next {ctx : Ctx} {F : BitVec 32} {i : Item} (hf : i.RbpFree) (hr : i.RipFree ctx)
    (hk : i.RspKept ctx) {x yv : State} {rest : List Item}
    (hy : i.exec ctx ((FForm.virt (some F) x).jump (x.rip + delta (some F) (i :: rest))) = .ok yv) :
    (FForm.virt (some F) ((yv.setReg .rbp (x.reg .rbp)).jump
        (x.rip + BitVec.ofNat 64 (i.spFrame F).size))).jump
      (((yv.setReg .rbp (x.reg .rbp)).jump (x.rip + BitVec.ofNat 64 (i.spFrame F).size)).rip +
        delta (some F) rest) = yv := by
  have hrbp : yv.reg .rbp = x.rsp + F.setWidth 64 := by
    rw [exec_rbp_kept hf hy]
    show (x.setReg .rbp (x.rsp + F.setWidth 64)).reg .rbp = _
    exact State.reg_setReg x .rbp _
  have hrsp : yv.rsp = x.rsp := by
    rw [hk _ _ hy]
    show (x.setReg .rbp (x.rsp + F.setWidth 64)).rsp = _
    exact rsp_setReg_rbp x _
  have hrip := hr.fallsThrough _ _ hy
  rw [virt_jump_eq (F := F) hrbp (by rw [hrsp])]
  have e : (x.rip + BitVec.ofNat 64 (i.spFrame F).size) + delta (some F) rest = yv.rip := by
    rw [hrip]
    show _ = x.rip + delta (some F) (i :: rest) + BitVec.ofNat 64 i.size
    rw [delta_cons]
    exact ar1 _ _ _ _
  show yv.jump ((x.rip + BitVec.ofNat 64 (i.spFrame F).size) + delta (some F) rest) = yv
  rw [e]
  all_goals rfl

theorem mem_dropLast_cons {a b j : Item} {l : List Item} (h : j ∈ (b :: l).dropLast) :
    j ∈ (a :: b :: l).dropLast := by
  show j ∈ a :: (b :: l).dropLast
  exact List.mem_cons_of_mem _ h

theorem head_mem_dropLast {a b : Item} {l : List Item} : a ∈ (a :: b :: l).dropLast := by
  show a ∈ a :: (b :: l).dropLast
  simp

/-- `execItems_virt` without a frame pointer. -/
theorem execItems_some {ctx : Ctx} {F : BitVec 32} :
    ∀ (items : List Item) (x : State), (∀ i ∈ items, i.RbpFree) → (∀ i ∈ items, i.SpDispOk F) →
      (∀ i ∈ items, i.RipFree ctx) → (∀ i ∈ items.dropLast, i.RspKept ctx) →
      execItems ctx (items.map (·.spFrame F)) x =
        (execItems ctx items ((FForm.virt (some F) x).jump (x.rip + delta (some F) items))).map
          (·.setReg .rbp (x.reg .rbp))
  | [], x, _, _, _, _ => by
    have h0 : x.rip + (0 : BitVec 64) = x.rip := BitVec.add_zero _
    rw [delta_nil, h0]
    show Except.ok x = Except.ok ((x.setReg .rbp (x.rsp + F.setWidth 64)).setReg .rbp (x.reg .rbp))
    rw [setReg_setReg, State.setReg_reg_self]
  | i :: rest, x, hf, hd, hr, hk => by
    show execItems ctx (i.spFrame F :: rest.map (·.spFrame F)) x = _
    rw [execItems_cons, execItems_cons, step_virt (hf i (by simp)) (hd i (by simp)) (hr i (by simp)) x rest]
    cases hy : i.exec ctx ((FForm.virt (some F) x).jump (x.rip + delta (some F) (i :: rest))) with
    | error e => rfl
    | ok yv =>
      show execItems ctx (rest.map (·.spFrame F))
          ((yv.setReg .rbp (x.reg .rbp)).jump (x.rip + BitVec.ofNat 64 (i.spFrame F).size)) =
        (execItems ctx rest yv).map (·.setReg .rbp (x.reg .rbp))
      cases rest with
      | nil =>
        have hrip := (hr i (by simp)).fallsThrough _ _ hy
        have e : yv.rip = x.rip + BitVec.ofNat 64 (i.spFrame F).size := by
          rw [hrip]
          show x.rip + delta (some F) [i] + BitVec.ofNat 64 i.size = _
          rw [delta_cons, delta_nil]
          exact ar3 _ _ _
        show Except.ok ((yv.setReg .rbp (x.reg .rbp)).jump (x.rip + BitVec.ofNat 64 (i.spFrame F).size)) =
          Except.ok (yv.setReg .rbp (x.reg .rbp))
        rw [← e]
        all_goals rfl
      | cons b rest' =>
        have ih := execItems_some (b :: rest')
          ((yv.setReg .rbp (x.reg .rbp)).jump (x.rip + BitVec.ofNat 64 (i.spFrame F).size))
          (fun j hj => hf j (by simp [hj])) (fun j hj => hd j (by simp [hj]))
          (fun j hj => hr j (by simp [hj])) (fun j hj => hk j (mem_dropLast_cons hj))
        have hreg : ((yv.setReg .rbp (x.reg .rbp)).jump
            (x.rip + BitVec.ofNat 64 (i.spFrame F).size)).reg .rbp = x.reg .rbp :=
          State.reg_setReg yv .rbp _
        rw [ih, hreg, step_next (hf i (by simp)) (hr i (by simp)) (hk i head_mem_dropLast) hy]

/-- The real run fetches: its items fall through and keep `S` where the virtual ones do. -/
theorem fetchRun_some {ctx : Ctx} {F : BitVec 32} {S : BitVec 64 → Prop} :
    ∀ (items : List Item) (x : State), (∀ i ∈ items, i.RbpFree) → (∀ i ∈ items, i.SpDispOk F) →
      (∀ i ∈ items, i.RipFree ctx) → (∀ i ∈ items.dropLast, i.RspKept ctx) →
      FetchRun ctx S items ((FForm.virt (some F) x).jump (x.rip + delta (some F) items)) →
      FetchRun ctx S (items.map (·.spFrame F)) x
  | [], _, _, _, _, _, _ => trivial
  | i :: rest, x, hf, hd, hr, hk, hrun => by
    show ∀ y, (i.spFrame F).exec ctx x = .ok y →
      y.rip = x.rip + BitVec.ofNat 64 (i.spFrame F).size ∧ (∀ a, S a → y.mem a = x.mem a) ∧
        FetchRun ctx S (rest.map (·.spFrame F)) y
    intro yr hyr
    rw [step_virt (hf i (by simp)) (hd i (by simp)) (hr i (by simp)) x rest] at hyr
    cases hy : i.exec ctx ((FForm.virt (some F) x).jump (x.rip + delta (some F) (i :: rest))) with
    | error e => rw [hy] at hyr; cases hyr
    | ok yv =>
      rw [hy] at hyr
      have hyr2 : (Except.ok ((yv.setReg .rbp (x.reg .rbp)).jump
          (x.rip + BitVec.ofNat 64 (i.spFrame F).size)) : Except Fault State) = .ok yr := hyr
      have hyr' : yr = (yv.setReg .rbp (x.reg .rbp)).jump
          (x.rip + BitVec.ofNat 64 (i.spFrame F).size) := by
        injection hyr2 with h; exact h.symm
      subst hyr'
      obtain ⟨-, hm, hrun'⟩ := hrun yv hy
      refine ⟨rfl, fun a ha => hm a ha, ?_⟩
      cases rest with
      | nil => trivial
      | cons b rest' =>
        have := step_next (hf i (by simp)) (hr i (by simp)) (hk i head_mem_dropLast) hy
        refine fetchRun_some (b :: rest') _ (fun j hj => hf j (by simp [hj]))
          (fun j hj => hd j (by simp [hj])) (fun j hj => hr j (by simp [hj]))
          (fun j hj => hk j (mem_dropLast_cons hj)) ?_
        exact (congrArg (FetchRun ctx S (b :: rest')) this).mpr hrun'

end FForm

/-- A list: the items in memory from the real state are the frame-pointer items from
`virtAt`, with the real `rbp` restored. Every item but the last keeps `rsp`; every item's run
is `rip`-free (`Item.RipFree`: a taken jump in the middle would land at the same address in
both forms, not at the next item of each). -/
theorem execItems_virt {ctx : Ctx} {fb : FForm} {items : List Item} {x : State}
    (hf : ∀ i ∈ items, i.RbpFree) (hd : ∀ F, fb = some F → ∀ i ∈ items, i.SpDispOk F)
    (hr : ∀ i ∈ items, i.RipFree ctx)
    (hk : ∀ i ∈ items.dropLast, i.RspKept ctx) :
    execItems ctx (items.map (FForm.item fb)) x =
      (execItems ctx items ((FForm.virtAt fb) items x)).map ((FForm.real fb) (x.reg .rbp)) := by
  cases fb with
  | none =>
    rw [FForm.map_item_none]
    show _ = (execItems ctx items x).map id
    cases execItems ctx items x <;> rfl
  | some F => exact FForm.execItems_some items x hf (hd F rfl) hr hk

/-- `steps_of_run` across the frame forms: the machine fetching `items.map (FForm.item fb)` from `x`
reaches the real state of the virtual run of `items` from `(FForm.virtAt fb) items x`. -/
theorem steps_of_run_fb {ctx : Ctx} {fb : FForm} {S : BitVec 64 → Prop} {items : List Item}
    {pos : Nat} {x xv' : State} (hf : ∀ i ∈ items, i.RbpFree)
    (hd : ∀ F, fb = some F → ∀ i ∈ items, i.SpDispOk F) (hr : ∀ i ∈ items, i.RipFree ctx)
    (hk : ∀ i ∈ items, i.RspKept ctx)
    (hcan : Canon (items.map (FForm.item fb)) pos) (hc : CodeAt ctx x.mem (items.map (FForm.item fb)) pos)
    (hrip : x.rip = addrAt ctx pos) (hS : ∀ a, InCode ctx (items.map (FForm.item fb)) pos a → S a)
    (hrun : FetchRun ctx S items ((FForm.virtAt fb) items x))
    (he : execItems ctx items ((FForm.virtAt fb) items x) = .ok xv') :
    Steps ctx x ((FForm.real fb) (x.reg .rbp) xv') ∧
      xv'.rip = addrAt ctx (pos + codeSize (items.map (FForm.item fb))) ∧
      ∀ a, S a → xv'.mem a = x.mem a := by
  cases fb with
  | none =>
    simp only [FForm.map_item_none] at hcan hc hS ⊢
    exact steps_of_run hcan hc hrip hS hrun he
  | some F =>
    have hk' : ∀ i ∈ items.dropLast, i.RspKept ctx :=
      fun i hi => hk i (List.dropLast_subset _ hi)
    have hrun' : FetchRun ctx S (items.map (FForm.item (some F))) x :=
      FForm.fetchRun_some items x hf (hd F rfl) hr hk' hrun
    have he' : execItems ctx (items.map (FForm.item (some F))) x = .ok (xv'.setReg .rbp (x.reg .rbp)) := by
      have := FForm.execItems_some items x hf (hd F rfl) hr hk'
      exact this.trans (by rw [show (FForm.virt (some F) x).jump (x.rip + FForm.delta (some F) items) =
        FForm.virtAt (some F) items x from rfl, he]; all_goals rfl)
    obtain ⟨h1, h2, h3⟩ := steps_of_run hcan hc hrip hS hrun' he'
    exact ⟨h1, h2, h3⟩

/-- `steps_of_run_last` across the frame forms: the last item may transfer control anywhere
and change `rsp`. It has no frame operand (so it is its own `spFrame` form and the forms'
shift is used up before it). -/
theorem steps_of_run_last_fb {ctx : Ctx} {fb : FForm} {S : BitVec 64 → Prop}
    {items : List Item} {j : Item} {pos : Nat} {x xv' : State}
    (hf : ∀ i ∈ items ++ [j], i.RbpFree)
    (hd : ∀ F, fb = some F → ∀ i ∈ items ++ [j], i.SpDispOk F)
    (hr : ∀ i ∈ items, i.RipFree ctx) (hjm : ∀ m, j.mem? = some m → m.base ≠ .rbp)
    (hk : ∀ i ∈ items, i.RspKept ctx)
    (hcan : Canon ((items ++ [j]).map (FForm.item fb)) pos)
    (hc : CodeAt ctx x.mem ((items ++ [j]).map (FForm.item fb)) pos)
    (hrip : x.rip = addrAt ctx pos) (hS : ∀ a, InCode ctx ((items ++ [j]).map (FForm.item fb)) pos a → S a)
    (hrun : FetchRun ctx S items ((FForm.virtAt fb) (items ++ [j]) x))
    (he : execItems ctx (items ++ [j]) ((FForm.virtAt fb) (items ++ [j]) x) = .ok xv') :
    Steps ctx x ((FForm.real fb) (x.reg .rbp) xv') := by
  cases fb with
  | none =>
    simp only [FForm.map_item_none] at hcan hc hS
    exact steps_of_run_last hcan hc hrip hS hrun he
  | some F =>
    have hjF : j.spFrame F = j := spFrame_of_noFrame hjm
    have hmap : (items ++ [j]).map (FForm.item (some F)) = items.map (FForm.item (some F)) ++ [j] := by
      rw [List.map_append]
      show _ ++ [j.spFrame F] = _
      rw [hjF]
    have hdel : FForm.delta (some F) (items ++ [j]) = FForm.delta (some F) items := by
      simp only [FForm.delta, List.map_append, codeSize_append, BitVec.ofNat_add]
      have : codeSize ([j].map (FForm.item (some F))) = codeSize [j] := by
        show codeSize [j.spFrame F] = _
        rw [hjF]
      rw [this]
      exact FForm.ar4 _ _ _
    rw [hmap] at hcan hc hS
    have hv : FForm.virtAt (some F) (items ++ [j]) x = FForm.virtAt (some F) items x := by
      show (FForm.virt (some F) x).jump (x.rip + FForm.delta (some F) (items ++ [j])) = _
      rw [hdel]
      all_goals rfl
    rw [hv] at hrun he
    rw [execItems_append] at he
    obtain ⟨yv, hyv, hj⟩ := except_bind_ok he
    have hk' : ∀ i ∈ items.dropLast, i.RspKept ctx :=
      fun i hi => hk i (List.dropLast_subset _ hi)
    have hf' : ∀ i ∈ items, i.RbpFree := fun i hi => hf i (by simp [hi])
    have hd' : ∀ i ∈ items, i.SpDispOk F := fun i hi => hd F rfl i (by simp [hi])
    have hrun' : FetchRun ctx S (items.map (FForm.item (some F))) x :=
      FForm.fetchRun_some items x hf' hd' hr hk' hrun
    have he' : execItems ctx (items.map (FForm.item (some F))) x =
        .ok (yv.setReg .rbp (x.reg .rbp)) := by
      have := FForm.execItems_some items x hf' hd' hr hk'
      exact this.trans (by rw [show (FForm.virt (some F) x).jump (x.rip + FForm.delta (some F) items) =
        FForm.virtAt (some F) items x from rfl, hyv]; all_goals rfl)
    rw [canon_append] at hcan
    rw [codeAt_append] at hc
    obtain ⟨hs, hr2, hm⟩ := steps_of_run hcan.1 hc.1 hrip
      (fun a hin => hS a ((inCode_append _ _ _ _).2 (.inl hin))) hrun' he'
    have hcj : CodeAt ctx (yv.setReg .rbp (x.reg .rbp)).mem [j] (pos + codeSize (items.map (FForm.item (some F)))) :=
      codeAt_of_agree hc.2 fun a hin => hm a (hS a ((inCode_append _ _ _ _).2 (.inr hin)))
    rw [execItems_cons] at hj
    obtain ⟨z, hz, hnil⟩ := except_bind_ok hj
    cases hnil
    exact hs.tail (.exec j _ hcan.2.1 hcj.1 hr2
      (by rw [exec_commute_rbp (hf j (by simp)) hjm, hz]; all_goals rfl))

/-- `faults_of_run` across the frame forms. -/
theorem faults_of_run_fb {ctx : Ctx} {fb : FForm} {S : BitVec 64 → Prop} {items : List Item}
    {pos : Nat} {x : State} {f : Fault} (hf : ∀ i ∈ items, i.RbpFree)
    (hd : ∀ F, fb = some F → ∀ i ∈ items, i.SpDispOk F) (hr : ∀ i ∈ items, i.RipFree ctx)
    (hk : ∀ i ∈ items, i.RspKept ctx)
    (hcan : Canon (items.map (FForm.item fb)) pos) (hc : CodeAt ctx x.mem (items.map (FForm.item fb)) pos)
    (hrip : x.rip = addrAt ctx pos) (hS : ∀ a, InCode ctx (items.map (FForm.item fb)) pos a → S a)
    (hrun : FetchRun ctx S items ((FForm.virtAt fb) items x))
    (he : execItems ctx items ((FForm.virtAt fb) items x) = .error f) :
    ∃ y, Steps ctx x y ∧ Faults ctx y f := by
  cases fb with
  | none =>
    simp only [FForm.map_item_none] at hcan hc hS
    exact faults_of_run hcan hc hrip hS hrun he
  | some F =>
    have hk' : ∀ i ∈ items.dropLast, i.RspKept ctx :=
      fun i hi => hk i (List.dropLast_subset _ hi)
    have hrun' : FetchRun ctx S (items.map (FForm.item (some F))) x :=
      FForm.fetchRun_some items x hf (hd F rfl) hr hk' hrun
    have he' : execItems ctx (items.map (FForm.item (some F))) x = .error f := by
      have := FForm.execItems_some items x hf (hd F rfl) hr hk'
      exact this.trans (by rw [show (FForm.virt (some F) x).jump (x.rip + FForm.delta (some F) items) =
        FForm.virtAt (some F) items x from rfl, he]; all_goals rfl)
    exact faults_of_run hcan hc hrip hS hrun' he'

end Ryo.X86
