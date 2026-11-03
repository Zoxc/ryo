/-
Ryo.Proofs.DecodeSound.NoFp — small facts the entry and `ret` steps use in both frame forms
(`nofp` design, task T3): the items without a memory operand are the same in either form
(`fb_item_noMem`), the real and virtual states differ only in `rbp` (`nf_real_*`, `nf_virt_*`),
the decoder's frame form without a frame pointer (`nf_spFrame_of_nofp`, `nf_pe_of_nofp`), the
link facts on `LinkOkF` (`nf_decodeItem_itemAt`, `nf_branch_canonical`), and a run of items that
don't touch `rbp` commuting with setting it (`nf_execItems_commute`).
-/
import Ryo.Proofs.DecodeSound.Basic

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem

/-! ### Items without a memory operand -/

theorem fb_item_noMem (fb : FForm) {i : Item} (h : i.mem? = none) : FForm.item fb i = i := by
  cases fb with
  | none => rfl
  | some F =>
    show Item.spFrame F i = i
    unfold Item.spFrame
    exact mapMem_eq_self fun m hm => by rw [h] at hm; cases hm

theorem fb_map_noMem (fb : FForm) : ∀ {L : List Item}, (∀ i ∈ L, i.mem? = none) →
    L.map (FForm.item fb) = L
  | [], _ => rfl
  | i :: L, h => by
    rw [List.map_cons, fb_item_noMem fb (h i (by simp)),
      fb_map_noMem fb (fun j hj => h j (by simp [hj]))]

theorem nf_noMem_cons {i : Item} {L : List Item} (h : i.mem? = none)
    (hL : ∀ j ∈ L, j.mem? = none) : ∀ j ∈ i :: L, j.mem? = none := by
  intro j hj
  rcases List.mem_cons.mp hj with rfl | hj
  · exact h
  · exact hL j hj

theorem nf_noMem_nil : ∀ j ∈ ([] : List Item), j.mem? = none := fun _ h => by cases h

/-! ### Real and virtual states -/

theorem nf_setReg_rbp_regs (z : X86.State) (v : BitVec 64) {i : Fin 16} (h : i ≠ 5) :
    (z.setReg .rbp v).regs i = z.regs i := by
  show (if i = Reg.rbp.idx then v else z.regs i) = z.regs i
  rw [if_neg (show i ≠ Reg.rbp.idx from h)]

theorem nf_real_mem (fb : FForm) (v : BitVec 64) (z : X86.State) :
    (FForm.real fb v z).mem = z.mem := by cases fb <;> rfl

theorem nf_real_rip (fb : FForm) (v : BitVec 64) (z : X86.State) :
    (FForm.real fb v z).rip = z.rip := by cases fb <;> rfl

theorem nf_real_xmm (fb : FForm) (v : BitVec 64) (z : X86.State) :
    (FForm.real fb v z).xmm = z.xmm := by cases fb <;> rfl

theorem nf_real_regs (fb : FForm) (v : BitVec 64) (z : X86.State) {i : Fin 16} (h : i ≠ 5) :
    (FForm.real fb v z).regs i = z.regs i := by
  cases fb with
  | none => rfl
  | some _ => exact nf_setReg_rbp_regs z v h

theorem nf_real_rsp (fb : FForm) (v : BitVec 64) (z : X86.State) :
    (FForm.real fb v z).rsp = z.rsp :=
  nf_real_regs fb v z (i := 4) (by decide)

theorem nf_virt_mem (S : Setup) (x : X86.State) : (S.virt x).mem = x.mem := by
  unfold Setup.virt; generalize S.fb = fb; cases fb <;> rfl

theorem nf_virt_xmm (S : Setup) (x : X86.State) : (S.virt x).xmm = x.xmm := by
  unfold Setup.virt; generalize S.fb = fb; cases fb <;> rfl

theorem nf_virt_regs (S : Setup) (x : X86.State) {i : Fin 16} (h : i ≠ 5) :
    (S.virt x).regs i = x.regs i := by
  unfold Setup.virt; generalize S.fb = fb
  cases fb with
  | none => rfl
  | some _ => exact nf_setReg_rbp_regs x _ h

theorem nf_virt_rsp (S : Setup) (x : X86.State) : (S.virt x).rsp = x.rsp :=
  nf_virt_regs S x (i := 4) (by decide)

theorem nf_virt_some {S : Setup} {F : BitVec 32} (h : S.body.spFrame = some F) (x : X86.State) :
    S.virt x = x.setReg .rbp (x.rsp + F.setWidth 64) := by
  unfold Setup.virt Setup.fb; rw [h]; rfl

/-- The state `items` run from in the virtual form is the virtual state, `rip` aside. -/
theorem nf_virtAt_jump (S : Setup) (L : List Item) (x : X86.State) :
    ∃ a, FForm.virtAt S.body.spFrame L x = (S.virt x).jump a := by
  unfold Setup.virt Setup.fb
  generalize S.body.spFrame = fb
  cases fb with
  | none => exact ⟨x.rip, rfl⟩
  | some F => exact ⟨_, rfl⟩

theorem nf_rrel_jump {s : R.RState} {x : X86.State} (h : RRel s x) (a : BitVec 64) :
    RRel s (x.jump a) :=
  ⟨⟨h.rel.frame, h.rel.layout, h.rel.zeroSized⟩, h.rbp, h.wf⟩

theorem nf_memRel_of_mem {st : OpSem.State} {x y : X86.State} (h : MemRel st x)
    (e : y.mem = x.mem) : MemRel st y := by
  unfold MemRel at *; rw [e]; exact h

/-! ### Items that don't touch `rbp` -/

theorem nf_execItems_commute {ctx : Ctx} : ∀ {L : List Item}, (∀ i ∈ L, i.RbpFree) →
    (∀ i ∈ L, i.mem? = none) → ∀ (x : X86.State) (v : BitVec 64),
    execItems ctx L (x.setReg .rbp v) = (execItems ctx L x).map (·.setReg .rbp v)
  | [], _, _, _, _ => rfl
  | i :: L, hf, hm, x, v => by
    rw [X86.execItems_cons, X86.execItems_cons,
      exec_commute_rbp (hf i (by simp)) (fun m h => by rw [hm i (by simp)] at h; cases h) x v]
    cases i.exec ctx x with
    | error e => rfl
    | ok y =>
      exact nf_execItems_commute (fun j hj => hf j (by simp [hj]))
        (fun j hj => hm j (by simp [hj])) y v

/-! ### The decoder's frame form -/

theorem nf_spFrame_of_nofp {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hfp : S.c.mode.framePointer = false) : S.body.spFrame = some (BitVec.ofNat 32 S.F) := by
  have eF : S.F = S.r.frameSize := reducedOf_frameSize hD.reduced
  rw [eF, hD.bodyEq]
  rw [hD.modeEq] at hfp
  simp [bodyCursor, hfp]

theorem nf_pe_of_nofp {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hfp : S.c.mode.framePointer = false) : S.c.mode.pe = false := by
  have hv := hD.modeValid
  cases hpe : S.c.mode.pe
  · rfl
  · simp [Ryo.Obj.Mode.valid, hpe, hfp] at hv

/-- Without a frame pointer the epilogue's `add rsp, F + 8` fits a signed 32-bit immediate
(`frameSizesCheck`). -/
theorem nf_frame8 {S : Setup} (H : Hyps S) : S.c.mode.framePointer = false → S.F + 8 < 2 ^ 31 :=
  fun h => Discharge.FrameSizes.frame8_of_check H.frameSizes (.inr h)

/-! ### Links in either frame form -/

theorem nf_decodeItem_itemAt {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    {mode : Ryo.Obj.Mode} (hL : LinkOkF ctx m c rs mode) {p n : Nat} {i : Item}
    (hb : Boundary rs p) (hd : decodeItem (atPos c p) = some (i, n)) :
    ItemAt ctx m (FForm.item c.spFrame i) p ∧ (FForm.item c.spFrame i).size = n ∧
      p + n ≤ c.code.size ∧ Boundary rs (p + n) := by
  cases hsp : c.spFrame with
  | none =>
    exact decodeItem_itemAt (c := atPos c p) hL.fields hL.sorted hL.loaded hL.small hsp hb hd
  | some F =>
    exact decodeItem_itemAt_sp (c := atPos c p) hL.fields hL.sorted hL.loaded hL.small hsp hb hd

/-- An item without a memory operand is in memory as read. -/
theorem nf_decodeItem_itemAtN {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    {mode : Ryo.Obj.Mode} (hL : LinkOkF ctx m c rs mode) {p n : Nat} {i : Item}
    (hb : Boundary rs p) (hd : decodeItem (atPos c p) = some (i, n)) (hm : i.mem? = none) :
    ItemAt ctx m i p ∧ i.size = n ∧ p + n ≤ c.code.size ∧ Boundary rs (p + n) := by
  have h := nf_decodeItem_itemAt hL hb hd
  rwa [fb_item_noMem _ hm] at h

theorem nf_brFits_mapMem (p : Nat) (f : Ryo.X86.M → Ryo.X86.M) (i : Item) :
    BrFits p (i.mapMem f) = BrFits p i := by
  cases i
  all_goals first
    | rfl
    | (rename_i rm; cases rm <;> rfl)
    | (rename_i rm _; cases rm <;> rfl)

/-- `br_decodeItem_brOk` in either frame form. -/
theorem nf_br_decodeItem_brOk {c : Cursor} {i : Item} {n : Nat}
    (h : decodeItem c = some (i, n)) : BrFits c.pos i := by
  have hacc : ∀ (post : Item → Option Item) (k : Item), c.accept post k = some (i, n) →
      post k = some i := by
    intro post k ha
    unfold Cursor.accept at ha
    split at ha
    · rename_i hp; cases ha; exact hp
    · cases ha
  unfold decodeItem at h
  rcases Option.orElse_some' h with h | h
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    cases hacc _ _ h
    exact br_baseCandidate_brOk hk
  rcases Option.orElse_some' h with h | h
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    obtain ⟨s, z, x, m, rfl, -⟩ := sseCandidate_ok hk
    rcases fromSpFrame_cases (hacc _ _ h) with ⟨f, m', -, -, -, rfl⟩ | ⟨rfl, -⟩ | ⟨rfl, -, -⟩
    · rw [nf_brFits_mapMem]; trivial
    · trivial
    · trivial
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    rcases fromSpFrame_cases (hacc _ _ h) with ⟨f, m', -, -, -, rfl⟩ | ⟨rfl, -⟩ | ⟨rfl, -, -⟩
    · rw [nf_brFits_mapMem]; exact br_nativeCandidate_brOk hk
    · exact br_nativeCandidate_brOk hk
    · exact br_nativeCandidate_brOk hk

/-- `branch_canonical` in either frame form. -/
theorem nf_branch_canonical {c : Cursor} {p n : Nat} {cond : Cond} {t : BitVec 32} {l : Bool}
    (h : decodeItem (atPos c p) = some (.branch cond t l, n)) :
    (Item.branch cond t l).Canonical p := by
  have hb := nf_br_decodeItem_brOk (c := atPos c p) h
  unfold Item.Canonical
  refine ⟨fun b e he => (nomatch he), Or.inl ?_⟩
  cases l
  · simpa [Item.wf, BrFits] using hb
  · simp [Item.wf]

end Ryo.Proofs.DecodeSound
