/-
Ryo.Proofs.DSWork.InlineVirt — what the bridge to code without a frame pointer
(`Ryo/X86/VirtFp.lean`: `steps_of_run_fb`, `steps_of_run_last_fb`) needs of the items `emit`
outputs for an inline sequence (`emit_virt`): `rbp` only a memory base (`RbpFree`, from
`cacheSafe` and `wfAny`), runs independent of `rip` but through their end (`RipFree`, `exec_jump`:
`lea`/`loadRip` address through `ctx`), `rsp` kept (`RspKept`: the written registers are usable
ones, fixed `rax`/`rcx`/`rdx`, or by `noRsp` not `rsp`), and canonical in the `spFrame` form.
`emit_store_virt`: a `store`'s last emitted item has its memory operand off the pool register.
-/
import Ryo.Proofs.CacheEmitWrites
import Ryo.X86.VirtFp

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

/-- The items whose written register `wf` doesn't restrict: not `rsp`. -/
def noRsp : Item → Bool
  | .setReg r _ | .lea r _ | .loadRip r _ => r != .rsp
  | _ => true

theorem pool_ne_rsp (i : Nat) : pool[i]! ≠ .rsp := fun e => by
  have := pool_usable i
  rw [e] at this
  exact absurd this (by decide)

theorem noRsp_ren {xr : Reg} (hx : xr ≠ .rsp) {it : Item} (h : noRsp it = true) :
    noRsp (ren xr it) = true := by
  cases it <;> (try rfl)
  all_goals simp only [ren, mapRegs, noRsp, bne_iff_ne, ne_eq] at h ⊢
  all_goals first | (split <;> simp_all) | simp_all

theorem noRsp_withRm {it : Item} (h : noRsp it = true) (rm : Rm) :
    noRsp (withRm it rm) = true := by
  cases it <;> first | rfl | exact h

theorem foldl_noRsp (xr : Reg) (hx : xr ≠ .rsp) : ∀ (rest : List Item) (st : Cache × Array Item),
    (∀ e ∈ st.2.toList, noRsp e = true) → (∀ it ∈ rest, noRsp it = true) →
      ∀ e ∈ (rest.foldl (emitStep xr) st).2.toList, noRsp e = true
  | [], st, h, _ => h
  | it :: rest, st, h, hs => by
    obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr st it
    have hw := noRsp_ren hx (hs it (by simp))
    have he : noRsp e = true := by
      rcases hcase with ⟨rfl, _⟩ | ⟨m, w, i, _, _, rfl, _⟩
      · exact hw
      · exact noRsp_withRm hw _
    simp only [List.foldl_cons, heq]
    refine foldl_noRsp xr hx rest _ ?_ (fun i hi => hs i (by simp [hi]))
    intro e' he'
    simp only [Array.toList_push, List.mem_append, List.mem_singleton] at he'
    rcases he' with he' | rfl
    · exact h e' he'
    · exact he

theorem emit_noRsp {c : Cache} {items : List Item} (hsz : c.regs.size = 8)
    (hs : ∀ it ∈ items, noRsp it = true) : ∀ e ∈ (c.emit items).1, noRsp e = true := by
  rw [emit_eq]
  dsimp only
  apply foldl_noRsp _ (pool_ne_rsp _) _ _ (by simp)
  rcases emitHead_cases { c with tick := c.tick + 1 } items hsz with h | ⟨w, m, tl, rfl, h, _⟩
  · rw [h]; exact hs
  · rw [h]; exact fun i hi => hs i (by simp [hi])

set_option maxHeartbeats 4000000 in
/-- The inline sequences set no `rsp` (their registers are `rax`, `rcx` and `rdx`). -/
theorem sequence_noRsp {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence cls ops = some (items, br)) :
    ∀ it ∈ items, noRsp it = true := by
  intro it hit
  cases cls <;> simp only [sequence, bind, Option.bind_eq_some_iff, pure] at h
  all_goals (repeat' (first
    | (obtain ⟨_, hs, h⟩ := h
       split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
    | split at h))
  all_goals (try simp only [Option.some.injEq, Prod.mk.injEq] at h)
  all_goals (try obtain ⟨rfl, _⟩ := h)
  all_goals (repeat' (first
    | (obtain rfl | hit := hit)
    | subst hit
    | split at hit
    | (simp only [List.mem_cons, List.mem_append, List.not_mem_nil,
        or_false, or_assoc, ld, st, R, C, M.frame, Mrax, flagSeq, cmpImmSeq] at hit)))
  all_goals first
    | rfl
    | (simp_all [noRsp, R, C]; done)
    | ((cases ‹W› <;> simp_all [noRsp, R, C]) <;> done)

/-! ### Per item -/

theorem rbpFree_of {it : Item} (hs : cacheSafe it = true) (hw : wfAny it = true) :
    it.RbpFree := by
  cases it <;> simp only [cacheSafe, reduceCtorEq] at hs <;>
    first
    | exact hw
    | exact hs
    | (simp only [wfAny, Bool.and_eq_true] at hw; exact hw.2)
    | (simp [wfAny] at hw; done)

theorem rsp_setReg (s : X86.State) {r : Reg} (h : r ≠ .rsp) (v : BitVec 64) :
    (s.setReg r v).reg .rsp = s.reg .rsp := by
  rw [reg_setReg', ite_eq_right (fun e => h (idx_inj e).symm)]

theorem rsp_setRegW (s : X86.State) {r : Reg} (h : r ≠ .rsp) (w : W) (v : BitVec w.bits) :
    (s.setRegW w r v).reg .rsp = s.reg .rsp := by
  cases w <;> exact rsp_setReg s h _

/-- A `cacheSafe`, `wfAny` and `noRsp` item keeps `rsp` (`exec_rbp`'s proof). -/
theorem rspKept_of {ctx : Ctx} {it : Item} (hs : cacheSafe it = true) (hw : wfAny it = true)
    (hn : noRsp it = true) : it.RspKept ctx := by
  intro x y h
  show y.reg .rsp = x.reg .rsp
  cases it <;> simp only [cacheSafe, reduceCtorEq] at hs <;>
    simp only [wfAny, noRsp, Item.wf, Item.rmWf, Item.memWf, Reg.usable, Bool.and_eq_true,
      bne_iff_ne, ne_eq] at hw hn <;>
    simp only [Item.exec, bind, Except.bind, pure, Except.pure] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals first
    | (simp_all [-reg_setReg', -X86S.reg_setReg, rsp_setReg, rsp_setRegW, State.setMemW,
        State.setRmW, Item.wf, Item.rmWf, Item.memWf, Reg.usable]; done)
    | ((cases ‹Rm› <;> simp_all [-reg_setReg', -X86S.reg_setReg, rsp_setReg, rsp_setRegW,
        State.setMemW, State.setRmW, Item.wf, Item.rmWf, Item.memWf, Reg.usable]) <;> done)
    | ((cases ‹W› <;> simp_all [-reg_setReg', -X86S.reg_setReg, rsp_setReg, rsp_setRegW,
        State.setMemW, State.setRmW, State.setRegW, Item.wf, Item.rmWf, Item.memWf,
        Reg.usable]) <;> done)

theorem wf_of_wfAny {it : Item} (h : wfAny it = true) (pos : Nat) :
    it.wf (BitVec.ofNat 32 pos) = true := by
  cases it <;> simp only [wfAny] at h <;>
    first | exact h | (simp only [Bool.and_eq_true] at h; exact h.2) | (cases ‹W› <;> exact h) |
      (simp at h; done)

theorem item_sp_ne_table {F : BitVec 32} {i : Item} (h : ∀ b e, i ≠ .tableEntry b e) :
    ∀ b e, FForm.item (some F) i ≠ .tableEntry b e := by
  intro b e he
  change Item.mapMem _ i = _ at he
  unfold Item.mapMem at he
  split at he <;> first | exact h b e he | cases he

theorem canon_sp_of {it : Item} (h : wfAny it = true) (F : BitVec 32) (p : Nat) :
    (FForm.item (some F) it).Canonical p :=
  ⟨item_sp_ne_table (canonical_of_wfAny h 0).1, .inr ⟨it, F, wf_of_wfAny h p, rfl⟩⟩

theorem canon_map_of {fb : FForm} : ∀ {L : List Item},
    (∀ i ∈ L, ∀ p, (FForm.item fb i).Canonical p) → ∀ pos, Canon (L.map (FForm.item fb)) pos
  | [], _, _ => trivial
  | i :: L, h, pos => ⟨h i (by simp) pos, canon_map_of (fun j hj => h j (by simp [hj])) _⟩

/-- What the bridge needs of every item `emit` outputs for an inline sequence. -/
theorem emit_virt {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} {c : Cache} (ctx : Ctx) (F : BitVec 32) (hsz : c.regs.size = 8)
    (hext : ∀ b, cls ≠ .ext .q b true) (hcls : clsOk cls = true)
    (hseq : sequence cls ops = some (cand, br)) :
    ∀ e ∈ (c.emit cand).1, e.RbpFree ∧ e.RipFree ctx ∧ e.RspKept ctx ∧
      ∀ p, (FForm.item (some F) e).Canonical p := by
  intro e he
  have hs := emit_safe hsz (fun it hit => (sequence_ok2 hext hseq it hit).1) e he
  have hw := emit_wf hsz (sequence_wf hcls hseq) e he
  have hn := emit_noRsp hsz (sequence_noRsp hseq) e he
  exact ⟨rbpFree_of hs hw, fun s a => exec_jump (ctx := ctx) hs s a, rspKept_of hs hw hn,
    canon_sp_of hw F⟩

theorem foldl_last_mem (xr : Reg) (hx : xr ≠ .rbp) (pre : List Item) (st : Cache × Array Item)
    (w : W) (k : BitVec 32) :
    ∃ init e, ((pre ++ [Item.st w .rcx ⟨.rax, k⟩]).foldl (emitStep xr) st).2.toList = init ++ [e] ∧
      ∀ m, e.mem? = some m → m.base ≠ .rbp := by
  rw [List.foldl_append, List.foldl_cons, List.foldl_nil]
  obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr (pre.foldl (emitStep xr) st)
    (Item.st w .rcx ⟨.rax, k⟩)
  rw [heq]
  refine ⟨_, e, Array.toList_push .., ?_⟩
  have hR : (Reg.rax == R) = true := by decide
  intro m hm
  rcases hcase with ⟨rfl, -⟩ | ⟨_, _, i, -, -, rfl, -⟩ <;>
    simp only [ren, mapRegs, withRm, Item.mem?, if_pos hR, Option.some.injEq] at hm <;>
    subst hm <;> exact hx

/-- A `store`'s emitted items: the last has its memory operand off the pool register (not
`rbp`), the others write no memory (`emit_store_split`). -/
theorem emit_store_virt {T : Type} {w : W} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} {cache : Cache} (hsz : cache.regs.size = 8)
    (hseq : sequence (.store w) ops = some (cand, br)) :
    ∃ init j, (cache.emit cand).1 = init ++ [j] ∧ (∀ e ∈ init, writeOf e = none) ∧
      ∀ m, j.mem? = some m → m.base ≠ .rbp := by
  obtain ⟨init, j, hs, hw⟩ := emit_store_split hsz hseq
  have hc : ∃ (a b : M) (k : BitVec 32), cand = [Item.ld .q false .rax a, .ld w false .rcx b,
      .st w .rcx ⟨.rax, k⟩] := by
    simp only [sequence, bind, pure] at hseq
    repeat' (first
      | (obtain ⟨_, hs, hseq⟩ := hseq
         split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
      | split at hseq)
    all_goals (try simp only [Option.some.injEq, Prod.mk.injEq] at hseq)
    all_goals (try obtain ⟨rfl, _⟩ := hseq)
    all_goals first | exact ⟨_, _, _, rfl⟩ | simp_all
  obtain ⟨a, b, k, rfl⟩ := hc
  have hlast : ∃ init' j', (cache.emit ([Item.ld .q false .rax a, .ld w false .rcx b] ++
      [.st w .rcx ⟨.rax, k⟩])).1 = init' ++ [j'] ∧ ∀ m, j'.mem? = some m → m.base ≠ .rbp := by
    rw [emit_eq]
    dsimp only
    rcases emitHead_cases { cache with tick := cache.tick + 1 } _ hsz with
      h | ⟨w0, m0, tl, hit, h, -⟩
    · rw [h]
      exact foldl_last_mem _ (pool_ne_rbp' _) _ _ w k
    · simp only [List.cons_append, List.cons.injEq] at hit
      obtain ⟨-, rfl⟩ := hit
      rw [h]
      exact foldl_last_mem _ (pool_ne_rbp' _) [Item.ld w false .rcx b] _ w k
  obtain ⟨init', j', hs', hj'⟩ := hlast
  have e : init ++ [j] = init' ++ [j'] := hs.symm.trans hs'
  obtain ⟨-, hjj⟩ := List.append_inj' e rfl
  simp only [List.cons.injEq, and_true] at hjj
  subst hjj
  exact ⟨init, _, hs, hw, hj'⟩

end Ryo.Proofs.CacheStep
