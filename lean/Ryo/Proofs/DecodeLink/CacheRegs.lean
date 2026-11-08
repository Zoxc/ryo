/-
Ryo.Proofs.DecodeLink.CacheRegs — on PE, `emit` never computes in `rsi`/`rdi` (pool entries 2
and 3) with the caches the decoder reads instructions with (`DSWork/Inline.lean`'s
`CacheRegsOk`, unfolded).

- `Good pe c`: the cache's `pe` is `pe`, and on PE entries 2 and 3 cache no slot. The empty cache
  `{ pe }` is good; `update` keeps it for the items of the inline sequences (`seqKind`) whose loads
  and stores don't name `rsi`/`rdi` (`ldstOk`; only those set a slot), `emit` for a sequence
  (`emit_good`: its register is never 2 or 3, `emitHead_not23`, so the renamed items stay
  `ldstOk`).
- `emitHead_not23`: from a good cache on PE, `emitHead` picks `rax` (pinned), a register `find`
  returns (it caches a slot, so not 2 or 3) or `fresh` (in the pool, `inPool`).
- `cache_good`: every cache of the decoder's iterations is good (`Decodes`: the first is
  `{ pe }`, an iteration clears it, keeps it (`arg`) or emits a sequence, `inlineInsn_read_drop`);
  `cacheRegsOk_of_decodes`: `CacheRegsOk` for every instruction index up to the
  iterations' count (beyond it `S.cache` is unconstrained).
-/
import Ryo.Proofs.DecodeSound.Basic

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheRegs

open Ryo.Vm Ryo.Vm.Asm Ryo.X86 Ryo.Vm.R Ryo.Proofs.RegCache Ryo.Proofs.DecodeLink
  Ryo.Proofs.DecodeSound

/-- The cache's `pe` is `pe`, and on PE entries 2 and 3 (`rsi`, `rdi`) cache no slot. -/
def Good (pe : Bool) (c : Cache) : Prop :=
  c.pe = pe ∧ (pe = true → ∀ j (hj : j < c.regs.size), (j = 2 ∨ j = 3) → (c.regs[j]'hj).slot = none)

theorem good_empty (pe : Bool) : Good pe { pe := pe } := by
  refine ⟨rfl, fun _ j hj _ => ?_⟩
  simp [Array.getElem_replicate]

theorem good_setEntry {pe : Bool} {c : Cache} (h : Good pe c) {i : Nat} {f : Entry → Entry}
    (hf : ∀ e, (f e).slot = e.slot ∨ (f e).slot = none) : Good pe (c.setEntry i f) := by
  refine ⟨h.1, fun hp j hj h23 => ?_⟩
  have hj' : j < c.regs.size := by simpa [Cache.setEntry] using hj
  simp only [Cache.setEntry, Array.getElem_modify]
  split
  · rcases hf c.regs[j] with e | e
    · rw [e]; exact h.2 hp j hj' h23
    · exact e
  · exact h.2 hp j hj' h23

/-- Any change of a pool entry other than `rsi`'s and `rdi`'s. -/
theorem good_setEntry_reg {pe : Bool} {c : Cache} (h : Good pe c) {r : X86.Reg} {i : Nat}
    (hp : poolIdx r = some i) (hr : pe = true → r ≠ .rsi ∧ r ≠ .rdi) {f : Entry → Entry} :
    Good pe (c.setEntry i f) := by
  refine ⟨h.1, fun hpe j hj h23 => ?_⟩
  have hij : i ≠ j := by
    rintro rfl
    obtain ⟨-, hpi⟩ := poolIdx_some hp
    obtain ⟨h1, h2⟩ := hr hpe
    rcases h23 with rfl | rfl
    · exact h1 (hpi.symm.trans (by decide : pool[2]! = X86.Reg.rsi))
    · exact h2 (hpi.symm.trans (by decide : pool[3]! = X86.Reg.rdi))
  have hj' : j < c.regs.size := by simpa [Cache.setEntry] using hj
  simp only [Cache.setEntry, Array.getElem_modify, hij, ↓reduceIte]
  exact h.2 hpe j hj' h23

theorem good_setRegEntry {pe : Bool} {c : Cache} (h : Good pe c) {r : X86.Reg}
    {slot : Option (BitVec 32 × W)} {zx : Option W}
    (hr : pe = true → slot ≠ none → r ≠ .rsi ∧ r ≠ .rdi) : Good pe (setRegEntry c r slot zx) := by
  rcases hp : poolIdx r with _ | i <;> simp only [setRegEntry, hp]
  · exact h
  · by_cases hs : slot = none
    · exact good_setEntry h (fun _ => .inr hs)
    · exact good_setEntry_reg h hp (fun hpe => hr hpe hs)

theorem good_clearW {pe : Bool} {c : Cache} (h : Good pe c) (m : M) (n : Nat) :
    Good pe (clearW c m n) := by
  refine ⟨h.1, fun hp j hj h23 => ?_⟩
  have hj' : j < c.regs.size := by simpa [clearW] using hj
  simp only [clearW, Array.getElem_map]
  split
  · rfl
  · exact h.2 hp j hj' h23

theorem good_stEntry {pe : Bool} {c : Cache} (h : Good pe c) {w : W} {src : X86.Reg} {m : M}
    (hs : pe = true → src ≠ .rsi ∧ src ≠ .rdi) : Good pe (stEntry c w src m) := by
  rcases hp : poolIdx src with _ | i <;> simp only [stEntry, hp]
  · exact h
  · (repeat' split) <;> first | exact good_setEntry_reg h hp hs | exact h

/-- The item kinds of the inline sequences (each one `update` has an equation for). -/
def seqKind : Item → Bool
  | .ld .. | .st .. | .stImm .. | .setcc .. | .testM8 _ | .setccCl _ | .mulQ _ | .leaM .. | .lea ..
  | .loadRip .. | .setReg .. | .alu .. | .aluImm .. | .imul .. | .imulImm .. | .shift ..
  | .shiftCl .. | .bswap .. | .cmov .. | .setccR .. | .cdq _ | .div .. | .bsf .. | .bsr .. => true
  | _ => false

/-- Loads and stores (the items that make an entry cache a slot) not on `rsi`/`rdi`. -/
def ldstOk : Item → Bool
  | .ld _ _ d _ | .st _ d _ => d != .rsi && d != .rdi
  | _ => true

def seqOk (it : Item) : Bool := seqKind it && ldstOk it

theorem good_update {pe : Bool} {c : Cache} (h : Good pe c) {it : Item} (hk : seqKind it = true)
    (hl : pe = true → ldstOk it = true) : Good pe (c.update it) := by
  have nn : ∀ (r : X86.Reg), pe = true → (none : Option (BitVec 32 × W)) ≠ none →
      r ≠ .rsi ∧ r ≠ .rdi := fun _ _ hs => absurd rfl hs
  cases it <;> simp only [seqKind, Bool.false_eq_true] at hk
  case ld w sx d m =>
    rw [update_ld]
    exact good_setRegEntry h (fun hp _ => by simpa [ldstOk] using hl hp)
  case st w s m =>
    rw [update_st]
    exact good_stEntry (good_clearW h _ _) (fun hp => by simpa [ldstOk] using hl hp)
  case stImm => rw [update_stImm]; exact good_clearW h _ _
  case setcc => rw [update_setcc]; exact good_clearW h _ _
  case testM8 => rw [update_testM8]; exact h
  case setccCl => rw [update_setccCl]; exact h
  case mulQ => rw [update_mulQ]; exact good_setRegEntry (good_setRegEntry h (nn _)) (nn _)
  case leaM => rw [update_leaM]; exact good_setRegEntry h (nn _)
  case lea => rw [update_lea]; exact good_setRegEntry h (nn _)
  case loadRip => rw [update_loadRip]; exact good_setRegEntry h (nn _)
  case setReg => rw [update_setReg]; exact good_setRegEntry h (nn _)
  case alu =>
    rw [update_alu]; split
    · exact good_setRegEntry h (nn _)
    · exact h
  case aluImm op w rm i =>
    cases rm with
    | reg r =>
      rw [update_aluImm_reg]; split
      · exact good_setRegEntry h (nn _)
      · exact h
    | mem m => rw [update_aluImm_mem]; exact h
  case imul => rw [update_imul]; exact good_setRegEntry h (nn _)
  case imulImm => rw [update_imulImm]; exact good_setRegEntry h (nn _)
  case shift => rw [update_shift]; exact good_setRegEntry h (nn _)
  case shiftCl => rw [update_shiftCl]; exact good_setRegEntry h (nn _)
  case bswap => rw [update_bswap]; exact good_setRegEntry h (nn _)
  case cmov => rw [update_cmov]; exact good_setRegEntry h (nn _)
  case setccR => rw [update_setccR]; exact good_setRegEntry h (nn _)
  case cdq => rw [update_cdq]; exact good_setRegEntry h (nn _)
  case div =>
    rw [update_div]
    exact good_setRegEntry (good_setRegEntry h (nn _)) (nn _)
  case bsf => rw [update_bsf]; exact good_setRegEntry h (nn _)
  case bsr => rw [update_bsr]; exact good_setRegEntry h (nn _)

/-! ### `emit`'s register -/

theorem foldl_in (g : Nat → Nat → Nat) (hg : ∀ a x, g a x = a ∨ g a x = x) :
    ∀ (l : List Nat) (b : Nat), l.foldl g b = b ∨ l.foldl g b ∈ l
  | [], _ => .inl rfl
  | x :: l, b => by
    simp only [List.foldl_cons, List.mem_cons]
    rcases foldl_in g hg l (g b x) with e | e
    · rw [e]
      rcases hg b x with e' | e'
      · exact .inl e'
      · exact .inr (.inl e')
    · exact .inr (.inr e)

theorem foldl_ne23 (g : Nat → Nat → Nat) (hg : ∀ a x, g a x = a ∨ g a x = x) (l : List Nat)
    (hl : ∀ x ∈ l, x ≠ 2 ∧ x ≠ 3) : l.foldl g 0 ≠ 2 ∧ l.foldl g 0 ≠ 3 := by
  rcases foldl_in g hg l 0 with e | e
  · rw [e]; decide
  · exact hl _ e

/-- On PE, `fresh` is in the pool: not 2 or 3. -/
theorem fresh_not23 {c : Cache} (hp : c.pe = true) : c.fresh ≠ 2 ∧ c.fresh ≠ 3 := by
  unfold Cache.fresh
  apply foldl_ne23
  · intro a x
    dsimp only
    (repeat' split) <;> simp
  · intro x hx
    have hin := (List.mem_filter.1 hx).2
    rw [hp] at hin
    constructor <;> rintro rfl <;> exact absurd hin (by decide)

theorem find_not23 {c : Cache} (h : Good true c) {i : Nat} (hi : i < c.regs.size)
    {p : BitVec 32 × W} (hsl : (c.regs[i]'hi).slot = some p) : i ≠ 2 ∧ i ≠ 3 := by
  constructor <;> rintro rfl <;> rw [h.2 rfl _ hi (by simp)] at hsl <;> exact nomatch hsl

/-- On PE, `emit` never computes in `rsi`/`rdi` from a good cache. -/
theorem emitHead_not23 {c : Cache} (h : Good true c) (cand : List Item) :
    (emitHead c cand).1 ≠ 2 ∧ (emitHead c cand).1 ≠ 3 := by
  have hf := fresh_not23 h.1
  unfold emitHead
  dsimp only
  split
  · split
    · simp
    · split
      · rename_i i hfi
        obtain ⟨-, hi, sw, hsl, -⟩ := find_spec hfi
        exact find_not23 h hi hsl
      · exact hf
  · split
    · simp
    · exact hf

theorem pool_not_si {i : Nat} (h2 : i ≠ 2) (h3 : i ≠ 3) : pool[i]! ≠ .rsi ∧ pool[i]! ≠ .rdi := by
  by_cases hi : i < 8
  · have : ∀ j < 8, j ≠ 2 → j ≠ 3 → pool[j]! ≠ .rsi ∧ pool[j]! ≠ .rdi := by decide
    exact this i hi h2 h3
  · rw [getElem!_neg pool i (by simp [pool]; omega)]; decide

theorem seqKind_ren (xr : X86.Reg) (it : Item) : seqKind (ren xr it) = seqKind it := by
  cases it <;> rfl

theorem seqKind_withRm (it : Item) (rm : Rm) : seqKind (withRm it rm) = seqKind it := by
  cases it <;> rfl

theorem ldstOk_withRm (it : Item) (rm : Rm) : ldstOk (withRm it rm) = ldstOk it := by
  cases it <;> rfl

theorem ldstOk_ren {xr : X86.Reg} (hx : xr ≠ .rsi ∧ xr ≠ .rdi) {it : Item} (h : ldstOk it = true) :
    ldstOk (ren xr it) = true := by
  cases it <;> simp only [ren, mapRegs, ldstOk, Bool.and_eq_true, bne_iff_ne, ne_eq] at h ⊢ <;>
    (try split) <;> simp_all

theorem foldl_good {pe : Bool} (xr : X86.Reg) (hx : pe = true → xr ≠ .rsi ∧ xr ≠ .rdi) :
    ∀ (rest : List Item) (st : Cache × Array Item), Good pe st.1 →
      (∀ it ∈ rest, seqOk it = true) → Good pe (rest.foldl (emitStep xr) st).1
  | [], _, h, _ => h
  | it :: rest, st, h, hs => by
    obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr st it
    have hit := hs it (by simp)
    simp only [seqOk, Bool.and_eq_true] at hit
    have hrest : ∀ i ∈ rest, seqOk i = true := fun i hi => hs i (by simp [hi])
    have hc' : Good pe c' := by
      rcases hcase with ⟨-, hc⟩ | ⟨m, w, i, -, -, -, hc⟩
      · rw [hc]; exact h
      · rw [hc]; exact good_setEntry h (fun _ => .inl rfl)
    have he : seqKind e = true ∧ (pe = true → ldstOk e = true) := by
      rcases hcase with ⟨he, -⟩ | ⟨m, w, i, -, -, he, -⟩
      · rw [he, seqKind_ren]; exact ⟨hit.1, fun hp => ldstOk_ren (hx hp) hit.2⟩
      · rw [he, seqKind_withRm, seqKind_ren, ldstOk_withRm]
        exact ⟨hit.1, fun hp => ldstOk_ren (hx hp) hit.2⟩
    have hg : Good pe (c'.update e) := good_update (it := e) hc' he.1 he.2
    rw [List.foldl_cons, heq]
    exact foldl_good xr hx rest (c'.update e, st.2.push e) hg hrest

theorem emitHead_sub (c : Cache) (cand : List Item) : ∀ it ∈ (emitHead c cand).2, it ∈ cand := by
  unfold emitHead
  dsimp only
  split
  · split
    · split
      · intro it hit; simp [hit]
      · exact fun _ h => h
    · split
      · intro it hit; simp [hit]
      · exact fun _ h => h
  · exact fun _ h => h

/-- `emit` keeps a cache good, for a sequence's items. -/
theorem emit_good {pe : Bool} {c : Cache} (h : Good pe c) {cand : List Item}
    (hs : ∀ it ∈ cand, seqOk it = true) : Good pe (c.emit cand).2 := by
  rw [emit_eq]
  dsimp only
  have h1 : Good pe { c with tick := c.tick + 1 } := h
  have hx : pe = true →
      pool[(emitHead { c with tick := c.tick + 1 } cand).1]! ≠ .rsi ∧
      pool[(emitHead { c with tick := c.tick + 1 } cand).1]! ≠ .rdi := fun hp => by
    subst hp
    obtain ⟨a, b⟩ := emitHead_not23 h1 cand
    exact pool_not_si a b
  refine foldl_good _ hx _ _ ?_ (fun it hit => hs it (emitHead_sub _ _ it hit))
  exact good_setEntry h1 (fun _ => .inl rfl)

/-! ### The sequences' items -/

set_option hygiene false in
macro "so_close" : tactic =>
  `(tactic| (
    seq_items
    all_goals (first
      | (simp [seqOk, seqKind, ldstOk]; done)
      | (split <;> simp [seqOk, seqKind, ldstOk]))))

theorem so_mov {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mov w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_mov128 {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mov128) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_imm {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.imm w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_addr {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addr) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_addrConst {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrConst) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_addrSym {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrSym) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_addrSymInd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrSymInd) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_ptrAdd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ptrAdd) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_ptrIndex {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ptrIndex) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_load {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.load w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_store {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.store w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_bin {T : Type} (op : Alu) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.bin op w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_binImm {T : Type} (op : Alu) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.binImm op w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_mul {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mul w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_mulImm {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mulImm w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_shiftImm {T : Type} (sh : Sh) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.shiftImm sh w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_cmp {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmp c w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_cmpImm {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmpImm c w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_br {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.br) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_brCmp {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.brCmp c w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_brCmpImm {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.brCmpImm c w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_ovf {T : Type} (op : Alu) (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ovf op sg w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_mulOvf {T : Type} (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mulOvf sg w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_ext {T : Type} (src : W) (dst : W) (sx : Bool) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ext src dst sx) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_shiftVar {T : Type} (sh : Sh) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.shiftVar sh w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_div {T : Type} (sg : Bool) (rem : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.div sg rem w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_count {T : Type} (lz : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.count lz w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_cmp3 {T : Type} (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmp3 sg w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem so_bswap {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.bswap w) ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  intro it hit
  so_close

theorem sequence_seqOk {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence cls ops = some (items, br)) : ∀ it ∈ items, seqOk it = true := by
  cases cls with
  | mov w => exact so_mov w h
  | mov128  => exact so_mov128  h
  | imm w => exact so_imm w h
  | addr  => exact so_addr  h
  | addrConst  => exact so_addrConst  h
  | addrSym  => exact so_addrSym  h
  | addrSymInd  => exact so_addrSymInd  h
  | ptrAdd  => exact so_ptrAdd  h
  | ptrIndex  => exact so_ptrIndex  h
  | load w => exact so_load w h
  | store w => exact so_store w h
  | bin op w => exact so_bin op w h
  | binImm op w => exact so_binImm op w h
  | mul w => exact so_mul w h
  | mulImm w => exact so_mulImm w h
  | shiftImm sh w => exact so_shiftImm sh w h
  | cmp c w => exact so_cmp c w h
  | cmpImm c w => exact so_cmpImm c w h
  | br  => exact so_br  h
  | brCmp c w => exact so_brCmp c w h
  | brCmpImm c w => exact so_brCmpImm c w h
  | ovf op sg w => exact so_ovf op sg w h
  | mulOvf sg w => exact so_mulOvf sg w h
  | ext src dst sx => exact so_ext src dst sx h
  | shiftVar sh w => exact so_shiftVar sh w h
  | div sg rem w => exact so_div sg rem w h
  | count lz w => exact so_count lz w h
  | cmp3 sg w => exact so_cmp3 sg w h
  | bswap w => exact so_bswap w h

/-! ### The decoder's caches -/

theorem good_inline {pe : Bool} {c c' : Cache} {dr dr' : List DroppedStore} {q : Proto}
    {cur cur' : Cursor} (h : Good pe c)
    (hrun : (inlineInsn c dr true).run cur = .ok (some (q, c', dr'), cur')) : Good pe c' := by
  obtain ⟨-, -, cand, br, out, hdec, hemit, -⟩ := inlineInsn_read_drop hrun
  obtain ⟨cls, -, hseq⟩ := decodeInline_spec hdec
  have := emit_good h (sequence_seqOk hseq)
  rw [hemit] at this
  exact this

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- Every cache of the decoder's iterations is good. -/
theorem cache_good (hD : Decodes S code relocs rodata callSites dropped scopes mode) :
    ∀ k ≤ S.r.protos.toList.length, Good S.c.mode.pe (S.cache k) := by
  intro k
  induction k with
  | zero =>
    intro _
    rw [hD.cache0, ← hD.modeEq]
    exact good_empty _
  | succ k ih =>
    intro hk
    have hg := ih (by omega)
    have hkl : k < S.r.protos.toList.length := by omega
    by_cases hlast : S.c.inRegion k = false ∧ S.c.inRegion (k + 1) = true
    · rw [hD.cache_regionStart hlast.1 hlast.2]; exact good_empty _
    obtain ⟨fr, q, p', ca', dr', hfm, -, hit, hend⟩ := hD.iterAt k hkl
    have hca : ca' = S.cache (k + 1) := (hend (Ryo.Proofs.DecodeSound.not_last_cases hlast)).2.1
    rw [← hca]
    clear hca hend hlast
    revert hit
    generalize S.cache k = c0 at hg ⊢
    generalize S.args k = a
    generalize S.start k = p
    generalize S.dr k = d0
    intro hit
    cases hit with
    | empty _ hrun => exact good_inline hg hrun
    | main _ _ hpr _ =>
      have hg' : ∀ b : Bool, Good S.c.mode.pe (if b = true then { pe := fr.mode.pe } else c0) := by
        intro b
        split
        · rw [hfm]; exact good_empty _
        · exact hg
      cases hpr with
      | arg _ => exact hg' _
      | call _ _ => rw [hfm]; exact good_empty _
      | inline _ _ hrun => exact good_inline (hg' _) hrun
      | insn _ _ _ _ => rw [hfm]; exact good_empty _

/-- `CacheRegsOk` (unfolded), for every instruction index up to the iterations' count. -/
theorem cacheRegsOk_of_decodes (hD : Decodes S code relocs rodata callSites dropped scopes mode) :
    ∀ k ≤ S.r.protos.toList.length, S.c.mode.pe = true → ∀ cand : List Item,
      (emitHead { S.used k with tick := (S.used k).tick + 1 } cand).1 ≠ 2 ∧
        (emitHead { S.used k with tick := (S.used k).tick + 1 } cand).1 ≠ 3 := by
  intro k hk hp cand
  have hu : Good S.c.mode.pe (S.used k) := by
    unfold Setup.used
    split
    · exact good_empty _
    · exact cache_good hD k hk
  rw [hp] at hu
  exact emitHead_not23 (c := { S.used k with tick := (S.used k).tick + 1 }) hu cand

end Ryo.Proofs.CacheRegs
