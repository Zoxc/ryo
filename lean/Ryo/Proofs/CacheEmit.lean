/-
Ryo.Proofs.CacheEmit — what `emit` outputs for an inline sequence, for the fetch of an inline
instruction's run (`DSWork/Inline.lean`'s `inline_fetch'`): the items are canonical
(`emit_canonical`, from `sequence_wf` per class), and their memory writes are the sequence's
(`emit_writes`), frame writes in the footprint's write ranges (`sequence_writes_in`), the rest
through `rax` only for `store`, whose write is last (`emit_store_split`); `exec_writes`,
`exec_rbp` per item. Split from `CacheStep.lean` (its per-class lemmas are many small ones).
Names stay in `Ryo.Proofs.CacheStep`.
-/
import Ryo.Proofs.CacheStep
import Ryo.X86.Fetch
import Ryo.Proofs.Inline.Later

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

/-! ### What `emit` outputs: canonical items, and their memory writes (for the fetch) -/

/-- The classes whose items are all `Item.wf`: no immediate rotate (`shiftImm` takes shifts
only), no 8-bit `bswap`, no `setcc` on `always`. Every inline opcode's class is one
(`inlineOps_clsOk`, `RyoProofs/InlineOk.lean`). -/
def clsOk : Class → Bool
  | .shiftImm sh _ => sh.isShift
  | .bswap w => w != .b
  | .cmp c _ | .cmpImm c _ => c != .always
  -- A sign-extending load is 8 or 16 bits, or the `shl`/`sar` pair to 64.
  | .ext src dst sx => !(sx && (src == .d || src == .q) && dst != .q)
  | _ => true

/-- An item canonical at every position: `wf` (which reads the position only for a short
branch) and neither a branch nor table data. -/
def wfAny : Item → Bool
  | .branch .. | .tableEntry .. => false
  -- Not PE's stack argument store (off `rsp`).
  | .stImm w m imm => m.base != .rsp && (Item.stImm w m imm).wf 0
  | it => it.wf 0

theorem canonical_of_wfAny {it : Item} (h : wfAny it = true) (pos : Nat) : it.Canonical pos := by
  refine ⟨fun b e he => by subst he; simp [wfAny] at h, .inl ?_⟩
  cases it <;> simp only [wfAny] at h <;>
    first | exact h | (simp only [Bool.and_eq_true] at h; exact h.2) | (cases ‹W› <;> exact h) | (simp at h; done)

theorem canon_of_all : ∀ {L : List Item}, (∀ i ∈ L, wfAny i = true) → ∀ pos, Canon L pos
  | [], _, _ => trivial
  | i :: is, h, pos => ⟨canonical_of_wfAny (h i (by simp)) pos,
      canon_of_all (fun j hj => h j (by simp [hj])) _⟩

theorem fitsB (b : BitVec 64) : fitsSigned 8 ((b.setWidth 8).signExtend 32) = true := by
  simp only [fitsSigned, beq_iff_eq]
  bv_decide

theorem fitsW (b : BitVec 64) : fitsSigned 16 ((b.setWidth 16).signExtend 32) = true := by
  simp only [fitsSigned, beq_iff_eq]
  bv_decide


set_option hygiene false in
/-- Unfolds a sequence into its items (`h`), one goal per item (`hit`). -/
macro "seq_items" : tactic =>
  `(tactic| (
    all_goals simp only [sequence, bind, Option.bind_eq_some_iff, pure] at h
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
          or_false, or_assoc, ld, st, R, C, M.frame, Mrax, flagSeq, cmpImmSeq] at hit)))))

set_option hygiene false in
macro "wf_close" : tactic =>
  `(tactic| (
    all_goals (try simp only [clsOk, bne_iff_ne, ne_eq, Bool.not_eq_true'] at hcls)
    all_goals (try (simp [Sh.isShift] at hcls; done))
    seq_items
    all_goals simp_all [wfAny, Item.wf, Item.memWf, Item.rmWf, Reg.usable, sextI32, fitsB, fitsW,
      Sh.isShift]))


theorem wf_mov {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.mov w) = true)
    (h : sequence (.mov w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_mov128 {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.mov128) = true)
    (h : sequence (.mov128) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  wf_close

theorem wf_imm {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.imm w) = true)
    (h : sequence (.imm w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_addr {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.addr) = true)
    (h : sequence (.addr) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  wf_close

theorem wf_addrConst {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.addrConst) = true)
    (h : sequence (.addrConst) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  wf_close

theorem wf_addrSym {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.addrSym) = true)
    (h : sequence (.addrSym) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  wf_close

theorem wf_addrSymInd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.addrSymInd) = true)
    (h : sequence (.addrSymInd) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  wf_close

theorem wf_ptrAdd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.ptrAdd) = true)
    (h : sequence (.ptrAdd) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  wf_close

theorem wf_ptrIndex {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.ptrIndex) = true)
    (h : sequence (.ptrIndex) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  wf_close

theorem wf_load {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.load w) = true)
    (h : sequence (.load w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_store {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.store w) = true)
    (h : sequence (.store w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_bin {T : Type} (op : Alu) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.bin op w) = true)
    (h : sequence (.bin op w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_binImm {T : Type} (op : Alu) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.binImm op w) = true)
    (h : sequence (.binImm op w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_mul {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.mul w) = true)
    (h : sequence (.mul w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_mulImm {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.mulImm w) = true)
    (h : sequence (.mulImm w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_shiftImm {T : Type} (sh : Sh) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.shiftImm sh w) = true)
    (h : sequence (.shiftImm sh w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases sh <;> cases w <;> wf_close

theorem wf_cmp {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.cmp c w) = true)
    (h : sequence (.cmp c w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_cmpImm {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.cmpImm c w) = true)
    (h : sequence (.cmpImm c w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_br {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.br) = true)
    (h : sequence (.br) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  wf_close

theorem wf_brCmp {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.brCmp c w) = true)
    (h : sequence (.brCmp c w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_brCmpImm {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.brCmpImm c w) = true)
    (h : sequence (.brCmpImm c w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

theorem wf_ovf {T : Type} (op : Alu) (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.ovf op sg w) = true)
    (h : sequence (.ovf op sg w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases sg <;> cases w <;> wf_close

theorem wf_mulOvf {T : Type} (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.mulOvf sg w) = true)
    (h : sequence (.mulOvf sg w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases sg <;> cases w <;> wf_close

theorem wf_ext {T : Type} (src : W) (dst : W) (sx : Bool) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.ext src dst sx) = true)
    (h : sequence (.ext src dst sx) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases src <;> cases dst <;> cases sx <;> wf_close

theorem wf_shiftVar {T : Type} (sh : Sh) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.shiftVar sh w) = true)
    (h : sequence (.shiftVar sh w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases sh <;> cases w <;> wf_close

theorem wf_div {T : Type} (sg : Bool) (rem : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.div sg rem w) = true)
    (h : sequence (.div sg rem w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases sg <;> cases rem <;> cases w <;> wf_close

theorem wf_count {T : Type} (lz : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.count lz w) = true)
    (h : sequence (.count lz w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases lz <;> cases w <;> wf_close

theorem wf_cmp3 {T : Type} (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.cmp3 sg w) = true)
    (h : sequence (.cmp3 sg w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases sg <;> cases w <;> wf_close

theorem wf_bswap {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk (.bswap w) = true)
    (h : sequence (.bswap w) ops = some (items, br)) : ∀ it ∈ items, wfAny it = true := by
  intro it hit
  cases w <;> wf_close

/-- Every item of an inline sequence (of a `clsOk` class) is canonical anywhere. -/
theorem sequence_wf {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hcls : clsOk cls = true) (h : sequence cls ops = some (items, br)) :
    ∀ it ∈ items, wfAny it = true := by
  cases cls with
  | mov w => exact wf_mov w hcls h
  | mov128  => exact wf_mov128  hcls h
  | imm w => exact wf_imm w hcls h
  | addr  => exact wf_addr  hcls h
  | addrConst  => exact wf_addrConst  hcls h
  | addrSym  => exact wf_addrSym  hcls h
  | addrSymInd  => exact wf_addrSymInd  hcls h
  | ptrAdd  => exact wf_ptrAdd  hcls h
  | ptrIndex  => exact wf_ptrIndex  hcls h
  | load w => exact wf_load w hcls h
  | store w => exact wf_store w hcls h
  | bin op w => exact wf_bin op w hcls h
  | binImm op w => exact wf_binImm op w hcls h
  | mul w => exact wf_mul w hcls h
  | mulImm w => exact wf_mulImm w hcls h
  | shiftImm sh w => exact wf_shiftImm sh w hcls h
  | cmp c w => exact wf_cmp c w hcls h
  | cmpImm c w => exact wf_cmpImm c w hcls h
  | br  => exact wf_br  hcls h
  | brCmp c w => exact wf_brCmp c w hcls h
  | brCmpImm c w => exact wf_brCmpImm c w hcls h
  | ovf op sg w => exact wf_ovf op sg w hcls h
  | mulOvf sg w => exact wf_mulOvf sg w hcls h
  | ext src dst sx => exact wf_ext src dst sx hcls h
  | shiftVar sh w => exact wf_shiftVar sh w hcls h
  | div sg rem w => exact wf_div sg rem w hcls h
  | count lz w => exact wf_count lz w hcls h
  | cmp3 sg w => exact wf_cmp3 sg w hcls h
  | bswap w => exact wf_bswap w hcls h

theorem pool_usable (i : Nat) : (pool[i]!).usable = true := by
  by_cases hi : i < 8
  · have : ∀ j < 8, (pool[j]!).usable = true := by decide
    exact this i hi
  · rw [getElem!_neg pool i (by simp [pool]; omega)]; decide

/-- `emit`'s renaming keeps an item canonical (`xr` is a pool register: usable, not `rcx`). -/
theorem wfAny_ren {xr : Reg} (hu : xr.usable = true) (hc : xr ≠ .rcx) {it : Item}
    (h : wfAny it = true) : wfAny (ren xr it) = true := by
  have g1 : ∀ r : Reg, r.usable = true → (if (r == R) = true then xr else r).usable = true := by
    intro r hr; split <;> assumption
  have g2 : ∀ r : Reg, r ≠ .rcx → (if (r == R) = true then xr else r) ≠ .rcx := by
    intro r hr; split <;> assumption
  have g3 : ∀ r : Reg, r ≠ .rsp → (if (r == R) = true then xr else r) ≠ .rsp := by
    intro r hr; split
    · intro e; subst e; simp [Reg.usable] at hu
    · exact hr
  cases it <;> simp only [wfAny] at h <;> simp only [ren, mapRegs, wfAny] <;>
    (try exact h) <;>
    simp only [Item.wf, Item.memWf, Item.rmWf, Bool.and_eq_true, bne_iff_ne, ne_eq] at h ⊢ <;>
    (try (rename_i rm; cases rm <;> simp only [mapRegs.mapRm, Item.rmWf, Item.memWf, bne_iff_ne,
      ne_eq] at h ⊢)) <;>
    (try (rename_i w _; cases w <;> simp only [Item.wf] at h ⊢)) <;>
    simp_all

theorem wfAny_withRm {it : Item} (h : wfAny it = true) (i : Nat) :
    wfAny (withRm it (.reg pool[i]!)) = true := by
  have hu := pool_usable i
  cases it <;> simp only [withRm] <;> (try exact h) <;>
    simp_all [wfAny, Item.wf, Item.rmWf]

theorem foldl_wf (xr : Reg) (hu : xr.usable = true) (hc : xr ≠ .rcx) :
    ∀ (rest : List Item) (st : Cache × Array Item),
    (∀ e ∈ st.2.toList, wfAny e = true) → (∀ it ∈ rest, wfAny it = true) →
      ∀ e ∈ (rest.foldl (emitStep xr) st).2.toList, wfAny e = true
  | [], st, h, _ => h
  | it :: rest, st, h, hs => by
    obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr st it
    have hw := wfAny_ren hu hc (hs it (by simp))
    have he : wfAny e = true := by
      rcases hcase with ⟨rfl, _⟩ | ⟨m, w, i, _, _, rfl, _⟩
      · exact hw
      · exact wfAny_withRm hw i
    simp only [List.foldl_cons, heq]
    refine foldl_wf xr hu hc rest _ ?_ (fun i hi => hs i (by simp [hi]))
    intro e' he'
    simp only [Array.toList_push, List.mem_append, List.mem_singleton] at he'
    rcases he' with he' | rfl
    · exact h e' he'
    · exact he

theorem emit_wf {c : Cache} {items : List Item} (hsz : c.regs.size = 8)
    (hs : ∀ it ∈ items, wfAny it = true) : ∀ e ∈ (c.emit items).1, wfAny e = true := by
  rw [emit_eq]
  dsimp only
  apply foldl_wf _ (pool_usable _) (pool_ne_rcx _) _ _ (by simp)
  rcases emitHead_cases { c with tick := c.tick + 1 } items hsz with h | ⟨w, m, tl, rfl, h, _⟩
  · rw [h]; exact hs
  · rw [h]; exact fun i hi => hs i (by simp [hi])

/-- (A) What `emit` outputs for an inline sequence is canonical from every position. -/
theorem emit_canonical {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} {cache : Cache} (hsz : cache.regs.size = 8) (hcls : clsOk cls = true)
    (hseq : sequence cls ops = some (cand, br)) : ∀ pos, Canon (cache.emit cand).1 pos :=
  canon_of_all (emit_wf hsz (sequence_wf hcls hseq))

end Ryo.Proofs.CacheStep
