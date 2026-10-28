/-
Ryo.Proofs.CacheEmitWrites — the memory writes of what `emit` outputs (see
`Ryo/Proofs/CacheEmit.lean`): `exec_writes`/`exec_rbp` per item, `emit_writes` (the sequence's
writes, renamed), `sequence_writes_frame` (per class, `wb_*`), `emit_store_split`.
-/
import Ryo.Proofs.CacheEmit

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

/-- The memory an item writes: `st`, `stImm`, `setcc`; among the `cacheSafe` items, no other
writes memory (`exec_writes`). -/
def writeOf : Item → Option (M × Nat)
  | .st w _ m | .stImm w m _ => some (m, bytes w)
  | .setcc _ m => some (m, 1)
  | _ => none

/-- A `cacheSafe` item ends `rip` past itself and changes memory only at its write. -/
theorem exec_writes {ctx : Ctx} {it : Item} (hs : cacheSafe it = true) {x y : X86.State}
    (h : it.exec ctx x = .ok y) :
    y.rip = x.rip + BitVec.ofNat 64 it.size ∧
      ∀ a, (∀ m n, writeOf it = some (m, n) → n ≤ (a - x.ea m).toNat) → y.mem a = x.mem a := by
  refine ⟨?_, ?_⟩
  · have hj := exec_jump (ctx := ctx) hs x x.rip
    rw [jump_rip, h] at hj
    simp only [Except.map, Except.ok.injEq] at hj
    rw [hj]; rfl
  · intro a ha
    cases it <;> simp only [cacheSafe, reduceCtorEq] at hs <;>
      simp only [Item.exec, bind, Except.bind, pure, Except.pure] at h
    all_goals (repeat' split at h)
    all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
    all_goals first
      | (simp only [writeOf] at ha
         simp only [State.setMemW, X86S.mem_setMem, mem_jump, ea_jump]
         exact X86.Mem.write_other _ _ _ _ _
           (by rw [bits_eq, Nat.mul_div_cancel_left _ (by decide)]; exact ha _ _ rfl))
      | (simp only [writeOf] at ha
         simp only [X86S.mem_setMem, mem_jump, ea_jump]
         exact X86.Mem.write_other _ _ _ _ _ (ha _ _ rfl))
      | (simp [State.setRegW, State.setRmW, mem_jump]; done)
      | ((cases ‹W› <;> simp [State.setRegW, State.setRmW, mem_jump]) <;> done)
      | ((cases ‹Rm› <;> simp_all [State.setRegW, State.setRmW, State.setMemW, mem_jump, aluF]) <;> done)
      | ((cases ‹Rm› <;> cases ‹W› <;> simp_all [State.setRegW, State.setRmW, State.setMemW,
          mem_jump, aluF]) <;> done)

theorem writeOf_withRm (it : Item) (rm : Rm) : writeOf (withRm it rm) = writeOf it := by
  cases it <;> rfl

theorem writeOf_ren (xr : Reg) (it : Item) :
    writeOf (ren xr it) = (writeOf it).map fun p =>
      (⟨if (p.1.base == R) = true then xr else p.1.base, p.1.disp⟩, p.2) := by
  cases it <;> rfl

theorem foldl_writes (xr : Reg) (cand : List Item) :
    ∀ (rest : List Item) (st : Cache × Array Item),
    (∀ e ∈ st.2.toList, ∀ m n, writeOf e = some (m, n) → ∃ it ∈ cand, ∃ m', writeOf it = some (m', n) ∧
      m = ⟨if (m'.base == R) = true then xr else m'.base, m'.disp⟩) → (∀ it ∈ rest, it ∈ cand) →
    ∀ e ∈ (rest.foldl (emitStep xr) st).2.toList, ∀ m n, writeOf e = some (m, n) →
      ∃ it ∈ cand, ∃ m', writeOf it = some (m', n) ∧
        m = ⟨if (m'.base == R) = true then xr else m'.base, m'.disp⟩
  | [], st, h, _ => h
  | it :: rest, st, h, hs => by
    obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr st it
    have he : writeOf e = writeOf (ren xr it) := by
      rcases hcase with ⟨rfl, _⟩ | ⟨m, w, i, _, _, rfl, _⟩
      · rfl
      · exact writeOf_withRm _ _
    simp only [List.foldl_cons, heq]
    refine foldl_writes xr cand rest _ ?_ (fun i hi => hs i (by simp [hi]))
    intro e' he' m n hw
    simp only [Array.toList_push, List.mem_append, List.mem_singleton] at he'
    rcases he' with he' | rfl
    · exact h e' he' m n hw
    · rw [he, writeOf_ren] at hw
      cases hwi : writeOf it with
      | none => rw [hwi] at hw; exact nomatch hw
      | some p =>
        rw [hwi] at hw
        simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at hw
        obtain ⟨rfl, rfl⟩ := hw
        exact ⟨it, hs it (by simp), p.1, hwi, rfl⟩

/-- (B) The memory writes of what `emit` outputs: each is a write of an item of the sequence,
its base renamed from `rax` to `emit`'s register (a frame write, off `rbp`, stays as it is). -/
theorem emit_writes {c : Cache} {items : List Item} (hsz : c.regs.size = 8) :
    ∀ e ∈ (c.emit items).1, ∀ m n, writeOf e = some (m, n) →
      ∃ it ∈ items, ∃ m', writeOf it = some (m', n) ∧
        m = ⟨if (m'.base == R) = true
          then pool[(emitHead { c with tick := c.tick + 1 } items).1]! else m'.base, m'.disp⟩ := by
  rw [emit_eq]
  dsimp only
  apply foldl_writes _ items _ _ (by simp)
  rcases emitHead_cases { c with tick := c.tick + 1 } items hsz with h | ⟨w, m, tl, rfl, h, _⟩
  · rw [h]; exact fun i hi => hi
  · rw [h]; exact fun i hi => by simp [hi]

set_option hygiene false in
macro "wb_close" : tactic =>
  `(tactic| (
    seq_items
    all_goals intro m n hw
    all_goals (simp only [writeOf, Option.some.injEq, Prod.mk.injEq, reduceCtorEq] at hw)
    all_goals (try (obtain ⟨rfl, rfl⟩ := hw))
    all_goals (try contradiction)
    all_goals (first | (left; rfl) | (right; exact ⟨_, rfl⟩))))

theorem wb_mov {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mov w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.mov w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_mov128 {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mov128) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.mov128 : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_imm {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.imm w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.imm w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_addr {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addr) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.addr : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_addrConst {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrConst) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.addrConst : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_addrSym {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrSym) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.addrSym : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_addrSymInd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrSymInd) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.addrSymInd : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_ptrAdd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ptrAdd) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.ptrAdd : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_ptrIndex {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ptrIndex) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.ptrIndex : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_load {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.load w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.load w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_store {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.store w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.store w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_bin {T : Type} (op : Alu) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.bin op w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.bin op w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_binImm {T : Type} (op : Alu) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.binImm op w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.binImm op w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_mul {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mul w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.mul w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_mulImm {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mulImm w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.mulImm w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_shiftImm {T : Type} (sh : Sh) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.shiftImm sh w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.shiftImm sh w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_cmp {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmp c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.cmp c w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_cmpImm {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmpImm c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.cmpImm c w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_br {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.br) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.br : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_brCmp {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.brCmp c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.brCmp c w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_brCmpImm {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.brCmpImm c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.brCmpImm c w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_ovf {T : Type} (op : Alu) (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ovf op sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.ovf op sg w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_mulOvf {T : Type} (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mulOvf sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.mulOvf sg w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_ext {T : Type} (src : W) (dst : W) (sx : Bool) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ext src dst sx) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.ext src dst sx : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_shiftVar {T : Type} (sh : Sh) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.shiftVar sh w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.shiftVar sh w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_div {T : Type} (sg : Bool) (rem : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.div sg rem w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.div sg rem w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_count {T : Type} (lz : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.count lz w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.count lz w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_cmp3 {T : Type} (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmp3 sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.cmp3 sg w : Class)) = .store w' := by
  intro it hit
  wb_close

theorem wb_bswap {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.bswap w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w', ((.bswap w : Class)) = .store w' := by
  intro it hit
  wb_close

/-- The sequences' writes are frame writes (off `rbp`), but `store`'s (through the pointer in
`rax`). -/
theorem sequence_writes_frame {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence cls ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp ∨ ∃ w, cls = .store w := by
  cases cls with
  | mov w => exact wb_mov w h
  | mov128  => exact wb_mov128  h
  | imm w => exact wb_imm w h
  | addr  => exact wb_addr  h
  | addrConst  => exact wb_addrConst  h
  | addrSym  => exact wb_addrSym  h
  | addrSymInd  => exact wb_addrSymInd  h
  | ptrAdd  => exact wb_ptrAdd  h
  | ptrIndex  => exact wb_ptrIndex  h
  | load w => exact wb_load w h
  | store w => exact wb_store w h
  | bin op w => exact wb_bin op w h
  | binImm op w => exact wb_binImm op w h
  | mul w => exact wb_mul w h
  | mulImm w => exact wb_mulImm w h
  | shiftImm sh w => exact wb_shiftImm sh w h
  | cmp c w => exact wb_cmp c w h
  | cmpImm c w => exact wb_cmpImm c w h
  | br  => exact wb_br  h
  | brCmp c w => exact wb_brCmp c w h
  | brCmpImm c w => exact wb_brCmpImm c w h
  | ovf op sg w => exact wb_ovf op sg w h
  | mulOvf sg w => exact wb_mulOvf sg w h
  | ext src dst sx => exact wb_ext src dst sx h
  | shiftVar sh w => exact wb_shiftVar sh w h
  | div sg rem w => exact wb_div sg rem w h
  | count lz w => exact wb_count lz w h
  | cmp3 sg w => exact wb_cmp3 sg w h
  | bswap w => exact wb_bswap w h

theorem rbp_setReg (s : X86.State) {r : Reg} (h : r ≠ .rbp) (v : BitVec 64) :
    (s.setReg r v).reg .rbp = s.reg .rbp := by
  rw [reg_setReg', if_neg (fun e => h (idx_inj e).symm)]

theorem rbp_setRegW (s : X86.State) {r : Reg} (h : r ≠ .rbp) (w : W) (v : BitVec w.bits) :
    (s.setRegW w r v).reg .rbp = s.reg .rbp := by
  cases w <;> exact rbp_setReg s h _

/-- A `cacheSafe` item keeps `rbp`. -/
theorem exec_rbp {ctx : Ctx} {it : Item} (hs : cacheSafe it = true) {x y : X86.State}
    (h : it.exec ctx x = .ok y) : y.reg .rbp = x.reg .rbp := by
  cases it <;> simp only [cacheSafe, reduceCtorEq] at hs <;>
    simp only [Item.exec, bind, Except.bind, pure, Except.pure] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals first
    | (simp_all [-reg_setReg', -X86S.reg_setReg, rbp_setReg, rbp_setRegW, State.setMemW,
        State.setRmW]; done)
    | ((cases ‹Rm› <;> simp_all [-reg_setReg', -X86S.reg_setReg, rbp_setReg, rbp_setRegW,
        State.setMemW, State.setRmW]) <;> done)
    | ((cases ‹W› <;> simp_all [-reg_setReg', -X86S.reg_setReg, rbp_setReg, rbp_setRegW,
        State.setMemW, State.setRmW, State.setRegW]) <;> done)

/-- The emitted items of a run of items ending in `j0`, all before it writing no memory: the
output ends in `j0`'s, the earlier ones write no memory. -/
theorem foldl_last_split (xr : Reg) (pre : List Item) (j0 : Item) (st0 : Cache × Array Item)
    (h0 : st0.2 = #[]) (hpre : ∀ it ∈ pre, writeOf it = none) :
    ∃ init j, ((pre ++ [j0]).foldl (emitStep xr) st0).2.toList = init ++ [j] ∧
      ∀ e ∈ init, writeOf e = none := by
  rw [List.foldl_append, List.foldl_cons, List.foldl_nil]
  obtain ⟨e, c', heq, -⟩ := emitStep_cases xr (pre.foldl (emitStep xr) st0) j0
  rw [heq]
  refine ⟨(List.foldl (emitStep xr) st0 pre).2.toList, e, by simp, ?_⟩
  intro e' he'
  cases hw : writeOf e' with
  | none => rfl
  | some p =>
    obtain ⟨it, hit, m', hw', -⟩ := foldl_writes xr pre pre st0
      (fun e he => by rw [h0] at he; simp at he) (fun i hi => hi) e' he' p.1 p.2 hw
    rw [hpre it hit] at hw'
    exact nomatch hw'

/-- `store`'s emitted items: its pointer write last, nothing before it writing memory. -/
theorem emit_store_split {T : Type} {w : W} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} {cache : Cache} (hsz : cache.regs.size = 8)
    (hseq : sequence (.store w) ops = some (cand, br)) :
    ∃ init j, (cache.emit cand).1 = init ++ [j] ∧ ∀ e ∈ init, writeOf e = none := by
  have hc : ∃ (a b : M) (k : BitVec 32), cand = [Item.ld .q false .rax a, .ld w false .rcx b,
      .st w .rcx ⟨.rax, k⟩] := by
    simp only [sequence, bind, Option.bind_eq_some_iff, pure] at hseq
    repeat' (first
      | (obtain ⟨_, hs, hseq⟩ := hseq
         split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
      | split at hseq)
    all_goals (try simp only [Option.some.injEq, Prod.mk.injEq] at hseq)
    all_goals (try obtain ⟨rfl, _⟩ := hseq)
    all_goals first | exact ⟨_, _, _, rfl⟩ | simp_all
  obtain ⟨a, b, k, rfl⟩ := hc
  rw [emit_eq]
  dsimp only
  rcases emitHead_cases { cache with tick := cache.tick + 1 } _ hsz with
    h | ⟨w0, m0, tl, hit, h, -⟩
  · rw [h]
    exact foldl_last_split _ [Item.ld .q false .rax a, .ld w false .rcx b] _ _ rfl
      (by simp [writeOf])
  · simp only [List.cons.injEq] at hit
    obtain ⟨-, rfl⟩ := hit
    rw [h]
    exact foldl_last_split _ [Item.ld w false .rcx b] _ _ rfl (by simp [writeOf])


end Ryo.Proofs.CacheStep
