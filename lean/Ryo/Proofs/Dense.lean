/-
Ryo.Proofs.Dense — the inline index of a dense switch (`Asm.denseIndex`, read back by
`DecodeReduced.denseSwitch`): `movzx`/`mov` of the slot `s` into `rax`, `sub` of `base` (none
if it is 0 at the width; through `rcx` at 64 bits if it doesn't fit an `imm32`), then
`mov ecx, n; cmp eax/rax, ecx/rcx; cmovae eax, ecx`.

- `denseIdx w v base n`: `switch.dense`'s case index for the slot value `v` (`opSem`:
  `(s - base).toNat` at the width, `n` if not below `n`); `denseIdx_opSem` is `opSem`'s
  expression.
- `denseIndex_exec`: the items run (`execItems`) to `rax = denseIdx ..`, `rcx = n`, memory,
  `xmm`s and every register but `rax`/`rcx` kept; the flags are `cmp`'s (clobbered).
- `dense_switch_steps`: the items then `Switch.switchItems` (the table jump), in memory at `rip`
  with the table, are `Steps` to entry `denseIdx ..`'s target.
-/
import Ryo.Proofs.Switch
import Ryo.Proofs.Inline.Exec
import Ryo.Vm.DecodeReduced
import Std.Tactic.BVDecide

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Dense

open Ryo.X86 Ryo.Vm

/-! ### The items -/

/-- `denseIndex`'s `sub` of `base`. -/
def subItems (w : W) (base : BitVec 64) : List Item :=
  if (base.setWidth w.bits) == 0 then []
  else if w == .q && !Asm.fits base then [.setReg Asm.C base, .alu .sub w Asm.R (.reg Asm.C)]
  else [.aluImm .sub w (.reg Asm.R) (Asm.sextI32 w base)]

/-- `denseIndex`'s clamp to `n`. -/
def tailItems (w : W) (n : BitVec 64) : List Item :=
  [.setReg Asm.C n, .alu .cmp (if w == .q then W.q else .d) Asm.R (.reg Asm.C),
    .cmov .ae .d Asm.R (.reg Asm.C)]

theorem denseIndex_eq (w : W) (s : BitVec 32) (base n : BitVec 64) (hn : ¬ n.toNat ≥ 2 ^ 31) :
    Asm.denseIndex (denseOp w) s base n =
      some (Asm.ld w (M.frame s) :: (subItems w base ++ tailItems w n)) := by
  cases w <;> simp only [Asm.denseIndex, hn, ↓reduceIte] <;> rfl

theorem denseIndex_some {w : W} {s : BitVec 32} {base n : BitVec 64} {its : List Item}
    (h : Asm.denseIndex (denseOp w) s base n = some its) :
    n.toNat < 2 ^ 31 ∧ its = Asm.ld w (M.frame s) :: (subItems w base ++ tailItems w n) := by
  by_cases hn : n.toNat ≥ 2 ^ 31
  · exfalso
    have e : Asm.denseIndex (denseOp w) s base n = none := by
      cases w <;> simp only [Asm.denseIndex, hn, ↓reduceIte] <;> rfl
    rw [e] at h
    cases h
  · rw [denseIndex_eq w s base n hn] at h
    exact ⟨by omega, (Option.some.inj h).symm⟩

/-! ### The index -/

/-- `switch.dense`'s case index (`opSem`): `v - base` at the width, `n` if not below `n`. -/
def denseIdx (w : W) (v : BitVec w.bits) (base n : BitVec 64) : Nat :=
  if (v - base.setWidth w.bits).toNat < n.toNat then (v - base.setWidth w.bits).toNat
  else n.toNat

/-- `opSem`'s `switch_dense` index (`(bv "s" k - immBv "base" k).toNat`, clamped to the table
length) is `denseIdx` of the slot's value and `base` at that width. -/
theorem denseIdx_opSem (w : W) (v : BitVec w.bits) (base n : BitVec 64) (k sv bv len : Nat)
    (hk : w.bits = 8 * k) (hv : sv % 2 ^ w.bits = v.toNat)
    (hb : bv % 2 ^ w.bits = base.toNat % 2 ^ w.bits) (hlen : len = n.toNat) :
    (if (BitVec.ofNat (8 * k) sv - BitVec.ofNat (8 * k) bv).toNat < len
      then (BitVec.ofNat (8 * k) sv - BitVec.ofNat (8 * k) bv).toNat else len) =
      denseIdx w v base n := by
  subst hlen
  have e1 : (BitVec.ofNat (8 * k) sv - BitVec.ofNat (8 * k) bv).toNat =
      (v - base.setWidth w.bits).toNat := by
    rw [BitVec.toNat_sub, BitVec.toNat_sub, BitVec.toNat_ofNat, BitVec.toNat_ofNat,
      BitVec.toNat_setWidth, ← hk, hv, hb]
  simp only [denseIdx, e1]

/-! ### What the items keep -/

/-- Memory, `xmm`s and the registers but `rax` and `rcx` (indices 0, 1) unchanged. -/
abbrev Keep (x y : State) : Prop :=
  y.mem = x.mem ∧ y.xmm = x.xmm ∧ ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → y.regs i = x.regs i

theorem keep_trans {x y z : State} (h1 : Keep x y) (h2 : Keep y z) : Keep x z :=
  ⟨h2.1.trans h1.1, h2.2.1.trans h1.2.1, fun r a b => (h2.2.2 r a b).trans (h1.2.2 r a b)⟩

theorem hrc : Reg.rax.idx ≠ Reg.rcx.idx := by decide
theorem hcr : Reg.rcx.idx ≠ Reg.rax.idx := by decide

theorem memW_jump (x : State) (a e : BitVec 64) (w : W) : (x.jump a).memW w e = x.memW w e := rfl
theorem ea_jump (x : State) (a : BitVec 64) (m : M) : (x.jump a).ea m = x.ea m := rfl

/-! ### Bit-vector facts -/

theorem toNat_zext {k : Nat} (d : BitVec k) (hk : k ≤ 64) : (d.setWidth 64).toNat = d.toNat := by
  rw [BitVec.toNat_setWidth]
  exact Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le d.isLt (Nat.pow_le_pow_right (by decide) hk))

theorem trunc_zext {k : Nat} (d : BitVec k) (hk : k ≤ 64) : (d.setWidth 64).setWidth k = d := by
  apply BitVec.eq_of_toNat_eq
  rw [BitVec.toNat_setWidth, toNat_zext d hk]
  exact Nat.mod_eq_of_lt d.isLt

theorem zext32 {k : Nat} (v : BitVec k) (hk : k ≤ 32) :
    (v.setWidth 32).setWidth 64 = v.setWidth 64 := by
  apply BitVec.eq_of_toNat_eq
  rw [toNat_zext _ (by decide), toNat_zext _ (by omega), BitVec.toNat_setWidth]
  exact Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le v.isLt (Nat.pow_le_pow_right (by decide) hk))

theorem zext_lt {k : Nat} (d : BitVec k) (hk : k ≤ 32) : d.setWidth 64 < 0x100000000#64 := by
  rw [BitVec.lt_def, toNat_zext d (by omega)]
  show d.toNat < 2 ^ 32
  exact Nat.lt_of_lt_of_le d.isLt (Nat.pow_le_pow_right (by decide) hk)

theorem idx_bv {k : Nat} (d : BitVec k) (hk : k ≤ 64) (n : BitVec 64) :
    BitVec.ofNat 64 (if d.toNat < n.toNat then d.toNat else n.toNat) =
      if d.setWidth 64 < n then d.setWidth 64 else n := by
  have hlt : d.setWidth 64 < n ↔ d.toNat < n.toNat := by rw [BitVec.lt_def, toNat_zext d hk]
  by_cases h : d.toNat < n.toNat
  · rw [if_pos h, if_pos (hlt.2 h), BitVec.ofNat_toNat]
  · rw [if_neg h, if_neg (fun h' => h (hlt.1 h')), BitVec.ofNat_toNat, BitVec.setWidth_eq]

/-! ### Each stage -/

/-- The load: `rax` is the slot's value, zero-extended. -/
theorem step_ld (ctx : Ctx) (w : W) (m : M) (x : State) :
    ∃ y, (Asm.ld w m).exec ctx x = .ok y ∧
      y.reg .rax = (x.memW w (x.ea m)).setWidth 64 ∧ Keep x y := by
  cases w
  · refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [Asm.R, State.reg_setReg, memW_jump, ea_jump, Bool.false_eq_true, ↓reduceIte]
      exact zext32 _ (by decide)
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]
  · refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [Asm.R, State.reg_setReg, memW_jump, ea_jump, Bool.false_eq_true, ↓reduceIte]
      exact zext32 _ (by decide)
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]
  · refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [Asm.R, State.setRegW, State.reg_setReg, memW_jump, ea_jump]
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]
  · refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [Asm.R, State.setRegW, State.reg_setReg, memW_jump, ea_jump]
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]

/-- `sub rax, rcx` after `mov rcx, base` (64 bits, `base` not an `imm32`). -/
theorem step_sub_reg (ctx : Ctx) (base a : BitVec 64) (y : State) (hy : y.reg .rax = a) :
    ∃ z, execItems ctx [.setReg Asm.C base, .alu .sub .q Asm.R (.reg Asm.C)] y = .ok z ∧
      z.reg .rax = (a.setWidth W.q.bits - base.setWidth W.q.bits).setWidth 64 ∧ Keep y z := by
  rw [execItems_cons, Inline.exec_setReg]
  refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
  · simp only [State.setRegW, State.regW, State.rmW, Asm.R, Asm.C, W.bits, State.reg_setReg,
      State.reg_setReg_other _ _ _ _ hrc, Switch.reg_jump, Switch.reg_setFlags, hy]
    all_goals (clear hy; bv_decide)
  · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]

/-- `sub r, imm` at the width (an `imm32` at 64 bits). -/
theorem step_sub_imm (ctx : Ctx) (w : W) (base a : BitVec 64) (y : State) (hy : y.reg .rax = a)
    (ha : (a.setWidth w.bits).setWidth 64 = a) (hf : w = .q → Asm.fits base = true) :
    ∃ z, execItems ctx [.aluImm .sub w (.reg Asm.R) (Asm.sextI32 w base)] y = .ok z ∧
      z.reg .rax = (a.setWidth w.bits - base.setWidth w.bits).setWidth 64 ∧ Keep y z := by
  cases w
  · refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [State.setRmW, State.setRegW, State.rmW, State.regW, Asm.R, W.bits,
        Asm.sextI32, State.reg_setReg, Switch.reg_jump, Switch.reg_setFlags, hy] at ha ⊢
      all_goals (clear hy hf; bv_decide)
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]
  · refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [State.setRmW, State.setRegW, State.rmW, State.regW, Asm.R, W.bits,
        Asm.sextI32, State.reg_setReg, Switch.reg_jump, Switch.reg_setFlags, hy] at ha ⊢
      all_goals (clear hy hf; bv_decide)
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]
  · refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [State.setRmW, State.setRegW, State.rmW, State.regW, Asm.R, W.bits,
        Asm.sextI32, State.reg_setReg, Switch.reg_jump, Switch.reg_setFlags, hy] at ha ⊢
      all_goals (clear hy hf; bv_decide)
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]
  · have hf' : (base.setWidth 32).signExtend 64 = base := by
      simpa [Asm.fits] using hf rfl
    refine ⟨_, rfl, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [State.setRmW, State.setRegW, State.rmW, State.regW, Asm.R, W.bits,
        Asm.sextI32, State.reg_setReg, Switch.reg_jump, Switch.reg_setFlags, hy] at ha ⊢
      all_goals (clear hy hf; bv_decide)
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]

/-- The `sub` of `base`, whichever form: `rax` is `a - base` at the width, zero-extended. -/
theorem step_sub (ctx : Ctx) (w : W) (base a : BitVec 64) (y : State) (hy : y.reg .rax = a)
    (ha : (a.setWidth w.bits).setWidth 64 = a) :
    ∃ z, execItems ctx (subItems w base) y = .ok z ∧
      z.reg .rax = (a.setWidth w.bits - base.setWidth w.bits).setWidth 64 ∧ Keep y z := by
  unfold subItems
  split
  · rename_i h0
    have h0' : base.setWidth w.bits = 0 := by simpa using h0
    refine ⟨y, rfl, ?_, rfl, rfl, fun _ _ _ => rfl⟩
    rw [hy, h0']
    show a = BitVec.setWidth 64 (BitVec.setWidth w.bits a - 0#w.bits)
    rw [BitVec.sub_zero, ha]
  · split
    · rename_i h2
      have hw : w = .q := by
        cases w <;> first | rfl | simp at h2
      subst hw
      exact step_sub_reg ctx base a y hy
    · rename_i h2
      have hf : w = .q → Asm.fits base = true := by
        intro e
        subst e
        simpa using h2
      exact step_sub_imm ctx w base a y hy ha hf

/-- `mov ecx, n; cmp; cmovae eax, ecx`: `rax` is `c` if below `n`, else `n` (`c` below `2^32`
for the 32-bit compare). -/
theorem step_tail (ctx : Ctx) (cw : W) (n c : BitVec 64) (y : State) (hy : y.reg .rax = c)
    (hn : n < 0x80000000#64) (hc : (cw = .d ∧ c < 0x100000000#64) ∨ cw = .q) :
    ∃ z, execItems ctx [.setReg Asm.C n, .alu .cmp cw Asm.R (.reg Asm.C),
        .cmov .ae .d Asm.R (.reg Asm.C)] y = .ok z ∧
      z.reg .rax = (if c < n then c else n) ∧ z.reg .rcx = n ∧ Keep y z := by
  rw [execItems_cons, Inline.exec_setReg]
  rcases hc with ⟨rfl, hc⟩ | rfl
  all_goals
    refine ⟨_, rfl, ?_, ?_, rfl, rfl, fun i h1 h2 => ?_⟩
    · simp only [State.setRegW, State.regW, State.rmW, Asm.R, Asm.C, W.bits, State.reg_setReg,
        State.reg_setReg_other _ _ _ _ hrc,
        Switch.reg_jump, Switch.reg_setFlags, hy, ← BitVec.lt_def]
      all_goals (clear hy; bv_decide)
    · simp only [State.setRegW, Asm.R, Asm.C, State.reg_setReg,
        State.reg_setReg_other _ _ _ _ hcr, Switch.reg_jump, Switch.reg_setFlags]
    · simp only [State.setRmW, State.setRegW, Asm.R, Asm.C, Inline.X86S.regs_setReg,
        Inline.X86S.regs_jump, Inline.X86S.regs_setFlags, Inline.idx_rax, Inline.idx_rcx, h1, h2,
        ↓reduceIte]

/-! ### The index computation -/

/-- `denseIndex`'s items, from any state, leave `switch.dense`'s case index (`denseIdx` of the
slot's value at the width) in `rax` and `n` in `rcx`; memory, `xmm`s and the other registers are
kept, the flags clobbered (`cmp`'s). -/
theorem denseIndex_exec {ctx : Ctx} {w : W} {s : BitVec 32} {base n : BitVec 64}
    {its : List Item} (h : Asm.denseIndex (denseOp w) s base n = some its) (x : State) :
    ∃ x', execItems ctx its x = .ok x' ∧
      x'.reg .rax = BitVec.ofNat 64 (denseIdx w (x.memW w (x.ea (M.frame s))) base n) ∧
      denseIdx w (x.memW w (x.ea (M.frame s))) base n ≤ n.toNat ∧
      x'.reg .rcx = n ∧ Keep x x' := by
  obtain ⟨hn, rfl⟩ := denseIndex_some h
  have hw : w.bits ≤ 64 := by cases w <;> decide
  obtain ⟨y, hy, hya, hky⟩ := step_ld ctx w (M.frame s) x
  generalize hv : x.memW w (x.ea (M.frame s)) = v at hya ⊢
  have ha : ((v.setWidth 64).setWidth w.bits).setWidth 64 = v.setWidth 64 := by
    rw [trunc_zext v hw]
  obtain ⟨z, hz, hza, hkz⟩ := step_sub ctx w base (v.setWidth 64) y hya ha
  rw [trunc_zext v hw] at hza
  have hn' : n < 0x80000000#64 := by rw [BitVec.lt_def]; exact hn
  have hc : ((if w == .q then W.q else .d) = .d ∧
      (v - base.setWidth w.bits).setWidth 64 < 0x100000000#64) ∨
      (if w == .q then W.q else .d) = .q := by
    cases w
    · exact .inl ⟨rfl, zext_lt _ (by decide)⟩
    · exact .inl ⟨rfl, zext_lt _ (by decide)⟩
    · exact .inl ⟨rfl, zext_lt _ (by decide)⟩
    · exact .inr rfl
  obtain ⟨u, hu, hua, huc, hku⟩ := step_tail ctx _ n _ z hza hn' hc
  refine ⟨u, ?_, ?_, ?_, huc, keep_trans hky (keep_trans hkz hku)⟩
  · rw [execItems_cons, hy]
    show execItems ctx (subItems w base ++ tailItems w n) y = .ok u
    rw [execItems_append, hz]
    exact hu
  · rw [hua, denseIdx, idx_bv _ hw]
  · unfold denseIdx
    split <;> omega

/-! ### Fetching -/

theorem ld_ok (ctx : Ctx) (w : W) (m : M) :
    (Asm.ld w m).FallsThrough ctx ∧ (Asm.ld w m).MemKept ctx := by
  cases w <;> exact ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
    fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩

theorem setReg_ok (ctx : Ctx) (r : Reg) (v : BitVec 64) :
    (Item.setReg r v).FallsThrough ctx ∧ (Item.setReg r v).MemKept ctx :=
  ⟨fun _ _ h => by rw [Inline.exec_setReg] at h; cases Switch.except_ok_inj h; rfl,
    fun _ _ h => by rw [Inline.exec_setReg] at h; cases Switch.except_ok_inj h; rfl⟩

theorem alu_ok (ctx : Ctx) (op : Alu) (hop : op = .sub ∨ op = .cmp) (w : W) (r : Reg) (rm : Rm) :
    (Item.alu op w r rm).FallsThrough ctx ∧ (Item.alu op w r rm).MemKept ctx := by
  rcases hop with rfl | rfl <;> cases w <;>
    exact ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
      fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩

theorem aluImm_ok (ctx : Ctx) (w : W) (r : Reg) (imm : BitVec 32) :
    (Item.aluImm .sub w (.reg r) imm).FallsThrough ctx ∧
      (Item.aluImm .sub w (.reg r) imm).MemKept ctx := by
  cases w <;> exact ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
    fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩

theorem cmov_ok (ctx : Ctx) (c : Cond) (w : W) (r : Reg) (rm : Rm) :
    (Item.cmov c w r rm).FallsThrough ctx ∧ (Item.cmov c w r rm).MemKept ctx := by
  have key : ∀ s s', (Item.cmov c w r rm).exec ctx s = .ok s' →
      s'.rip = s.rip + BitVec.ofNat 64 (Item.cmov c w r rm).size ∧ s'.mem = s.mem := by
    intro s s' h
    obtain ⟨b, -, hb⟩ := except_bind_ok h
    cases Switch.except_ok_inj hb
    cases w <;> exact ⟨rfl, rfl⟩
  exact ⟨fun s s' h => (key s s' h).1, fun s s' h => (key s s' h).2⟩

theorem dense_items_ok (ctx : Ctx) {w : W} {s : BitVec 32} {base n : BitVec 64}
    {its : List Item} (h : Asm.denseIndex (denseOp w) s base n = some its) :
    ∀ i ∈ its, i.FallsThrough ctx ∧ i.MemKept ctx := by
  obtain ⟨-, rfl⟩ := denseIndex_some h
  intro i hi
  rcases List.mem_cons.1 hi with rfl | hi
  · exact ld_ok ctx w _
  rcases List.mem_append.1 hi with hi | hi
  · unfold subItems at hi
    split at hi
    · cases hi
    · split at hi
      · simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
        rcases hi with rfl | rfl
        · exact setReg_ok ctx _ _
        · exact alu_ok ctx _ (.inl rfl) _ _ _
      · simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
        subst hi
        exact aluImm_ok ctx _ _ _
  · simp only [tailItems, List.mem_cons, List.not_mem_nil, or_false] at hi
    rcases hi with rfl | rfl | rfl
    · exact setReg_ok ctx _ _
    · exact alu_ok ctx _ (.inr rfl) _ _ _
    · exact cmov_ok ctx _ _ _ _

theorem fits8 (b : BitVec 64) : fitsSigned 8 ((b.setWidth 8).signExtend 32) = true := by
  simp only [fitsSigned, beq_iff_eq]
  bv_decide

theorem fits16 (b : BitVec 64) : fitsSigned 16 ((b.setWidth 16).signExtend 32) = true := by
  simp only [fitsSigned, beq_iff_eq]
  bv_decide

theorem canonical_of_wf {i : Item} (ht : ∀ b e, i ≠ .tableEntry b e) (hw : ∀ p, i.wf p = true)
    (p : Nat) : i.Canonical p :=
  ⟨ht, .inl (hw _)⟩

/-- `denseIndex`'s items are canonical anywhere (`Item.wf` doesn't depend on the position for
them). -/
theorem dense_items_canonical {w : W} {s : BitVec 32} {base n : BitVec 64} {its : List Item}
    (h : Asm.denseIndex (denseOp w) s base n = some its) : ∀ i ∈ its, ∀ p, i.Canonical p := by
  obtain ⟨-, rfl⟩ := denseIndex_some h
  intro i hi
  rcases List.mem_cons.1 hi with rfl | hi
  · exact canonical_of_wf (fun _ _ h => nomatch h) (fun _ => by cases w <;> rfl)
  rcases List.mem_append.1 hi with hi | hi
  · unfold subItems at hi
    split at hi
    · cases hi
    · split at hi
      · simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
        rcases hi with rfl | rfl
        · exact canonical_of_wf (fun _ _ h => nomatch h) (fun _ => rfl)
        · exact canonical_of_wf (fun _ _ h => nomatch h) (fun _ => rfl)
      · simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
        subst hi
        refine canonical_of_wf (fun _ _ h => nomatch h) (fun _ => ?_)
        cases w
        · simp only [Item.wf, Asm.sextI32, fits8, Bool.and_true] <;> rfl
        · simp only [Item.wf, Asm.sextI32, fits16, Bool.and_true] <;> rfl
        · rfl
        · rfl
  · simp only [tailItems, List.mem_cons, List.not_mem_nil, or_false] at hi
    rcases hi with rfl | rfl | rfl
    · exact canonical_of_wf (fun _ _ h => nomatch h) (fun _ => rfl)
    · exact canonical_of_wf (fun _ _ h => nomatch h) (fun _ => rfl)
    · exact canonical_of_wf (fun _ _ h => nomatch h) (fun _ => rfl)

/-! ### The whole dense switch -/

/-- The index items and the table jump (`Switch.switchItems t`), in memory at `rip`, with the
table at `t` (entry `denseIdx ..` in it): `Steps` to entry `denseIdx ..`'s target, memory and `xmm`s
kept; the registers through the state `y` between the two (`Keep`: all but `rax`/`rcx`, then
the jump's, `DSWork.Handler.hdl_switch_regs`). -/
theorem dense_switch_steps {ctx : Ctx} {w : W} {s t : BitVec 32} {base n : BitVec 64}
    {its : List Item} {es : List (BitVec 32)} {pos : Nat} {x : State}
    (h : Asm.denseIndex (denseOp w) s base n = some its)
    (hcan : Canon (its ++ Switch.switchItems t) pos)
    (hc : CodeAt ctx x.mem (its ++ Switch.switchItems t) pos) (hrip : x.rip = addrAt ctx pos)
    (ht : CodeAt ctx x.mem (es.map (Item.tableEntry t)) t.toNat)
    (hi : denseIdx w (x.memW w (x.ea (M.frame s))) base n < es.length) (htb : t.toNat < 2 ^ 31)
    (heb : ∀ e ∈ es, e.toNat < 2 ^ 31) :
    ∃ x',
      Steps ctx x x' ∧ execItems ctx (its ++ Switch.switchItems t) x = .ok x' ∧
      x'.rip = addrAt ctx es[denseIdx w (x.memW w (x.ea (M.frame s))) base n].toNat ∧
      x'.mem = x.mem ∧ x'.xmm = x.xmm ∧
      ∃ y, execItems ctx its x = .ok y ∧ Keep x y ∧
        execItems ctx (Switch.switchItems t) y = .ok x' := by
  obtain ⟨y, hy, hya, -, -, hk⟩ := denseIndex_exec (ctx := ctx) h x
  have ht' : CodeAt ctx y.mem (es.map (Item.tableEntry t)) t.toNat := by rw [hk.1]; exact ht
  obtain ⟨x', he, hrip', -, -, hmem, hxmm, -⟩ :=
    Switch.exec_switch ht' hi hya htb (heb _ (List.getElem_mem hi))
  have hrun : execItems ctx (its ++ Switch.switchItems t) x = .ok x' := by
    rw [execItems_append, hy]; exact he
  refine ⟨x', ?_, hrun, hrip', hmem.trans hk.1, hxmm.trans hk.2.1, y, hy, hk, he⟩
  have e : its ++ Switch.switchItems t =
      (its ++ [.leaTable t, .loadTableEntry, .addRaxRcx]) ++ [.jmpRax] := by
    simp [Switch.switchItems]
  rw [e] at hcan hc hrun
  have hfr : FetchRun ctx
      (InCode ctx ((its ++ [.leaTable t, .loadTableEntry, .addRaxRcx]) ++ [.jmpRax]) pos)
      (its ++ [.leaTable t, .loadTableEntry, .addRaxRcx]) x := by
    refine fetchRun_of_forall (fun i hm => ?_) x
    rcases List.mem_append.1 hm with hm | hm
    · exact dense_items_ok ctx h i hm
    · simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
      rcases hm with rfl | rfl | rfl
      · exact Switch.leaTable_straight ctx t
      · exact Switch.loadTableEntry_straight ctx
      · exact Switch.addRaxRcx_straight ctx
  exact steps_of_run_last hcan hc hrip (fun _ h => h) hfr hrun

end Ryo.Proofs.Dense
