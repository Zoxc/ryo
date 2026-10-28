/-
Ryo.Proofs.CacheEmitFrame — a sequence's frame writes lie within its destination slot's
`outSize` bytes, or are an overflow flag byte (`sequence_frame_writes`, per class `fw_*`).
-/
import Ryo.Proofs.CacheEmitWrites

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

/-! #### The sequences' frame writes lie in the footprint's write ranges -/

/-- The bytes a class writes at its destination `d` (0: none). -/
def outSize : Class → Nat
  | .mov w | .imm w | .load w | .bin _ w | .binImm _ w | .mul w | .mulImm w | .shiftImm _ w
  | .ovf _ _ w | .mulOvf _ w | .shiftVar _ w | .div _ _ w | .bswap w => wbytes w
  | .ext _ dst _ => wbytes dst
  | .mov128 => 16
  | .addr | .addrConst | .addrSym | .addrSymInd | .ptrAdd | .ptrIndex => 8
  | .cmp .. | .cmpImm .. | .cmp3 .. => 1
  | .count .. => 4
  | _ => 0

/-- The classes with an overflow flag byte at `o`. -/
def isOvf : Class → Bool
  | .ovf .. | .mulOvf .. => true
  | _ => false

theorem mov128_hi (s : BitVec 32) (h : s.toInt + 8 < 2 ^ 31) :
    s.toInt ≤ (s + 8).toInt ∧ (s + 8).toInt + 8 ≤ s.toInt + 16 := by
  have hb := toInt_bounds s
  have e : (s + 8).toInt = s.toInt + 8 := by
    rw [BitVec.toInt_add_of_not_saddOverflow]
    · rfl
    · simp [BitVec.saddOverflow]; omega
  omega

/-- The three shapes of a frame write's conclusion (`fw_close`). -/
theorem fw_left {T : Type} {ops : List (R.Opnd T)} {s : BitVec 32} {n k : Nat} {Q : Prop}
    (h0 : ops[0]? = some (.slot s)) (hn : n ≤ k) (hk : 0 < k) :
    (∃ s', ops[0]? = some (.slot s') ∧ s'.toInt ≤ (M.frame s).disp.toInt ∧
      (M.frame s).disp.toInt + n ≤ s'.toInt + k ∧ 0 < k) ∨ Q :=
  .inl ⟨s, h0, Int.le_refl _, by simp only [M.frame]; omega, hk⟩

theorem fw_right {T : Type} {ops : List (R.Opnd T)} {s : BitVec 32} {n : Nat} {b : Bool} {P : Prop}
    (h1 : ops[1]? = some (.slot s)) (hn : n = 1) (hb : b = true) :
    P ∨ (∃ s', ops[1]? = some (.slot s') ∧ (M.frame s).disp = s' ∧ n = 1 ∧ b = true) :=
  .inr ⟨s, h1, rfl, hn, hb⟩

theorem fw_hi {T : Type} {ops : List (R.Opnd T)} {s : BitVec 32} {n k : Nat} {Q : Prop}
    (h0 : ops[0]? = some (.slot s)) (hg : s.toInt + 8 < 2 ^ 31) (hn : n = 8) (hk : k = 16) :
    (∃ s', ops[0]? = some (.slot s') ∧ s'.toInt ≤ (M.frame ((M.frame s).disp + 8)).disp.toInt ∧
      (M.frame ((M.frame s).disp + 8)).disp.toInt + n ≤ s'.toInt + k ∧ 0 < k) ∨ Q := by
  subst hn hk
  exact .inl ⟨s, h0, (mov128_hi s hg).1, (mov128_hi s hg).2, by decide⟩

set_option hygiene false in
macro "fw_close" : tactic =>
  `(tactic| (
    seq_items
    all_goals intro m n hw hb
    all_goals (simp only [writeOf, Option.some.injEq, Prod.mk.injEq, reduceCtorEq] at hw)
    all_goals (try (obtain ⟨rfl, rfl⟩ := hw))
    all_goals (try (simp [M.frame, Mrax] at hb; done))
    all_goals (try contradiction)
    all_goals (try (apply fw_left <;> first | assumption | decide | (simp [outSize, Ryo.Vm.Asm.bytes, Ryo.Proofs.Inline.wbytes, Ryo.X86.W.bits]; done)))
    all_goals (try (apply fw_right <;> first | assumption | decide | rfl))
    all_goals (try (apply fw_hi <;> first | assumption | decide |
      (have hg := ‹¬((_ || _) = true)›
       simp only [Bool.or_eq_true, decide_eq_true_eq, not_or, M.frame, Int.not_le,
         ge_iff_le] at hg ⊢
       omega)))))

theorem fw_mov {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mov w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.mov w) ∧ 0 < outSize (.mov w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.mov w) = true) := by
  intro it hit
  cases w <;> fw_close

theorem fw_mov128 {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mov128) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.mov128) ∧ 0 < outSize (.mov128)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.mov128) = true) := by
  intro it hit
  fw_close
  all_goals
    rename_i hg _
    simp only [M.frame, Bool.or_eq_true, decide_eq_true_eq, not_or, Int.not_le, ge_iff_le] at hg
    left
    refine Exists.intro ?s ⟨?h, ?_, ?_, ?_⟩
    case h => assumption
    · exact (mov128_hi _ (by omega)).1
    · exact (mov128_hi _ (by omega)).2
    · simp [outSize]

theorem fw_imm {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.imm w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.imm w) ∧ 0 < outSize (.imm w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.imm w) = true) := by
  intro it hit
  cases w <;> fw_close

theorem fw_addr {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addr) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.addr) ∧ 0 < outSize (.addr)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.addr) = true) := by
  intro it hit
  fw_close

theorem fw_addrConst {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrConst) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.addrConst) ∧ 0 < outSize (.addrConst)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.addrConst) = true) := by
  intro it hit
  fw_close

theorem fw_addrSym {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrSym) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.addrSym) ∧ 0 < outSize (.addrSym)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.addrSym) = true) := by
  intro it hit
  fw_close

theorem fw_addrSymInd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.addrSymInd) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.addrSymInd) ∧ 0 < outSize (.addrSymInd)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.addrSymInd) = true) := by
  intro it hit
  fw_close

theorem fw_ptrAdd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ptrAdd) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.ptrAdd) ∧ 0 < outSize (.ptrAdd)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.ptrAdd) = true) := by
  intro it hit
  fw_close

theorem fw_ptrIndex {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ptrIndex) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.ptrIndex) ∧ 0 < outSize (.ptrIndex)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.ptrIndex) = true) := by
  intro it hit
  fw_close

theorem fw_load {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.load w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.load w) ∧ 0 < outSize (.load w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.load w) = true) := by
  intro it hit
  cases w <;> fw_close

theorem fw_store {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.store w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.store w) ∧ 0 < outSize (.store w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.store w) = true) := by
  intro it hit
  cases w <;> fw_close

set_option maxHeartbeats 1000000 in
theorem fw_bin {T : Type} (op : Alu) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.bin op w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.bin op w) ∧ 0 < outSize (.bin op w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.bin op w) = true) := by
  intro it hit
  cases w <;> fw_close

set_option maxHeartbeats 1000000 in
theorem fw_binImm {T : Type} (op : Alu) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.binImm op w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.binImm op w) ∧ 0 < outSize (.binImm op w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.binImm op w) = true) := by
  intro it hit
  cases w <;> fw_close

theorem fw_mul {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mul w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.mul w) ∧ 0 < outSize (.mul w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.mul w) = true) := by
  intro it hit
  cases w <;> fw_close

theorem fw_mulImm {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mulImm w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.mulImm w) ∧ 0 < outSize (.mulImm w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.mulImm w) = true) := by
  intro it hit
  cases w <;> fw_close

theorem fw_shiftImm {T : Type} (sh : Sh) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.shiftImm sh w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.shiftImm sh w) ∧ 0 < outSize (.shiftImm sh w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.shiftImm sh w) = true) := by
  intro it hit
  cases sh <;> cases w <;> fw_close

set_option maxHeartbeats 1000000 in
theorem fw_cmp {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmp c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.cmp c w) ∧ 0 < outSize (.cmp c w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.cmp c w) = true) := by
  intro it hit
  cases w <;> fw_close

set_option maxHeartbeats 1000000 in
theorem fw_cmpImm {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmpImm c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.cmpImm c w) ∧ 0 < outSize (.cmpImm c w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.cmpImm c w) = true) := by
  intro it hit
  cases w <;> fw_close

theorem fw_br {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.br) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.br) ∧ 0 < outSize (.br)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.br) = true) := by
  intro it hit
  fw_close

theorem fw_brCmp {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.brCmp c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.brCmp c w) ∧ 0 < outSize (.brCmp c w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.brCmp c w) = true) := by
  intro it hit
  cases w <;> fw_close

theorem fw_brCmpImm {T : Type} (c : Cond) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.brCmpImm c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.brCmpImm c w) ∧ 0 < outSize (.brCmpImm c w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.brCmpImm c w) = true) := by
  intro it hit
  cases w <;> fw_close

set_option maxHeartbeats 1000000 in
theorem fw_ovf {T : Type} (op : Alu) (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ovf op sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.ovf op sg w) ∧ 0 < outSize (.ovf op sg w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.ovf op sg w) = true) := by
  intro it hit
  cases sg <;> cases w <;> fw_close

theorem fw_mulOvf {T : Type} (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.mulOvf sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.mulOvf sg w) ∧ 0 < outSize (.mulOvf sg w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.mulOvf sg w) = true) := by
  intro it hit
  cases sg <;> cases w <;> fw_close

theorem fw_ext {T : Type} (src : W) (dst : W) (sx : Bool) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.ext src dst sx) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.ext src dst sx) ∧ 0 < outSize (.ext src dst sx)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.ext src dst sx) = true) := by
  intro it hit
  cases src <;> cases dst <;> cases sx <;> fw_close

theorem fw_shiftVar {T : Type} (sh : Sh) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.shiftVar sh w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.shiftVar sh w) ∧ 0 < outSize (.shiftVar sh w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.shiftVar sh w) = true) := by
  intro it hit
  cases sh <;> cases w <;> fw_close

theorem fw_div {T : Type} (sg : Bool) (rem : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.div sg rem w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.div sg rem w) ∧ 0 < outSize (.div sg rem w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.div sg rem w) = true) := by
  intro it hit
  cases sg <;> cases rem <;> cases w <;> fw_close

theorem fw_count {T : Type} (lz : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.count lz w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.count lz w) ∧ 0 < outSize (.count lz w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.count lz w) = true) := by
  intro it hit
  cases lz <;> cases w <;> fw_close

theorem fw_cmp3 {T : Type} (sg : Bool) (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.cmp3 sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.cmp3 sg w) ∧ 0 < outSize (.cmp3 sg w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.cmp3 sg w) = true) := by
  intro it hit
  cases sg <;> cases w <;> fw_close

theorem fw_bswap {T : Type} (w : W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence (.bswap w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize (.bswap w) ∧ 0 < outSize (.bswap w)) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf (.bswap w) = true) := by
  intro it hit
  cases w <;> fw_close

/-- The frame writes of a sequence: within `outSize cls` bytes from the destination slot
`ops[0]`, or an overflow flag byte at `ops[1]`. -/
theorem sequence_frame_writes {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence cls ops = some (items, br)) :
    ∀ it ∈ items, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      (∃ s, ops[0]? = some (.slot s) ∧ s.toInt ≤ m.disp.toInt ∧
        m.disp.toInt + n ≤ s.toInt + outSize cls ∧ 0 < outSize cls) ∨
      (∃ s, ops[1]? = some (.slot s) ∧ m.disp = s ∧ n = 1 ∧ isOvf cls = true) := by
  cases cls with
  | mov w => exact fw_mov w h
  | mov128  => exact fw_mov128  h
  | imm w => exact fw_imm w h
  | addr  => exact fw_addr  h
  | addrConst  => exact fw_addrConst  h
  | addrSym  => exact fw_addrSym  h
  | addrSymInd  => exact fw_addrSymInd  h
  | ptrAdd  => exact fw_ptrAdd  h
  | ptrIndex  => exact fw_ptrIndex  h
  | load w => exact fw_load w h
  | store w => exact fw_store w h
  | bin op w => exact fw_bin op w h
  | binImm op w => exact fw_binImm op w h
  | mul w => exact fw_mul w h
  | mulImm w => exact fw_mulImm w h
  | shiftImm sh w => exact fw_shiftImm sh w h
  | cmp c w => exact fw_cmp c w h
  | cmpImm c w => exact fw_cmpImm c w h
  | br  => exact fw_br  h
  | brCmp c w => exact fw_brCmp c w h
  | brCmpImm c w => exact fw_brCmpImm c w h
  | ovf op sg w => exact fw_ovf op sg w h
  | mulOvf sg w => exact fw_mulOvf sg w h
  | ext src dst sx => exact fw_ext src dst sx h
  | shiftVar sh w => exact fw_shiftVar sh w h
  | div sg rem w => exact fw_div sg rem w h
  | count lz w => exact fw_count lz w h
  | cmp3 sg w => exact fw_cmp3 sg w h
  | bswap w => exact fw_bswap w h


end Ryo.Proofs.CacheStep
