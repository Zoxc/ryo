/-
Ryo.Proofs.Inline.LaterDiv — the inline `div`/`rem` (class `div`) and `cttz`/`ctlz` (class
`count`) sequences against `opSem`.

- `div sg rem w`: `opSem` is UB on a zero divisor and on `MIN / -1` (`intBin`'s
  `unchecked_div`/`unchecked_rem`), so where it succeeds the x86 `div`/`idiv` doesn't fault
  (`divF` is `some`: `divF_u`, `divF_s`). At 8 and 16 bits the operands are extended to 32 bits
  and divided there (`udiv_zext`, `sdiv_sext`, …). The sequence also changes `rdx` (`cdq` or
  `xor edx, edx`, and the remainder), so the result is `SoundX [0, 1, 2]`: `SoundC` with `rdx`
  among the changed registers (`clobbers` in `Ovf.lean` doesn't list `div` yet; `SoundX.toC`
  gives `SoundC` once it does).
- `count lz w`: `bsf`/`bsr` of zero leave `ctx.undef` in the register, which the `cmovz`
  overwrites (`cttz` at 32 and 64 bits, every `ctlz`); for `cttz` at 8 and 16 bits the guard bit
  `2 ^ n` makes the source non-zero (`lowest_guard`). Only `rax`, `rcx` and the flags change:
  `Sound`.

The runs are stepped one item at a time (`Ld.chain`), each step's state named and summarized
(`Ld.Facts`: memory, the registers outside the clobbered ones, `xmm`, `rip`), so the terms stay
small.

In the module chain after `Ovf` (see `Ryo/Proofs/Inline/Arith.lean`).
-/
import Ryo.Proofs.Inline.Ovf

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm

/-! ### The statement -/

/-- `PostC`, with the registers outside `cl` unchanged. -/
structure PostX (cl : List (Fin 16)) (op : Full.Opcode) (ops : List (R.Opnd Nat))
    (vals : Operands) (items : List Item) (br : Option Cond) (st st' : OpSem.State)
    (ctl : Control) (x x' : Ryo.X86.State) : Prop where
  rel : Rel st' x'
  same : SameButWrites st' st
  regs : ∀ i : Fin 16, i ∉ cl → x'.regs i = x.regs i
  xmm : x'.xmm = x.xmm
  rip : x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum
  memOut : ∀ a, (∀ r ∈ wranges op vals, r.2 ≤ (a - fpAddr x r.1).toNat) → x'.mem a = x.mem a
  ctl : match br with
    | none => ctl = .next
    | some cond => ∃ b, ctl = .branch b ∧
      ∀ neg t, R.nativeCtl op ops = some (.branch neg t) → cond.eval x'.flags = .ok (b != neg)

/-- `Sound c`, with the registers of `cl` changed. -/
def SoundX (cl : List (Fin 16)) (c : Class) : Prop :=
  ∀ (ctx : Ctx) (ρ : R.Addrs) (op : Full.Opcode) (ops : List (R.Opnd Nat)) (items : List Item)
    (br : Option Cond) (vals : Operands) (st st' : OpSem.State) (ctl : Control)
    (ch : OpSem.Choice) (x : Ryo.X86.State),
    shapeOk op c = true → sequence c ops = some (items, br) → nativeVals ρ op ops = some vals →
    opSem op vals st ch = .ok (ctl, st') → Rel st x →
    ∃ x', execItems ctx items x = .ok x' ∧ PostX cl op ops vals items br st st' ctl x x'

/-- `SoundX` at `clobbers c` is `SoundC c` (for `div` once `clobbers` lists it). -/
theorem SoundX.toC {c : Class} (h : SoundX (clobbers c) c) : SoundC c := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨x', hx, p⟩ := h ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  exact ⟨x', hx, ⟨p.rel, p.same, p.regs, p.xmm, p.rip, p.memOut, p.ctl⟩⟩

/-- With only `rax` and `rcx` changed, `SoundX` is `Sound`. -/
theorem SoundX.sound {c : Class} (h : SoundX [0, 1] c) : Sound c := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨x', hx, p⟩ := h ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  refine ⟨x', hx, ⟨p.rel, p.same, fun i h0 h1 => p.regs i ?_, p.xmm, p.rip, p.memOut, p.ctl⟩⟩
  simp [h0, h1]

namespace Ld

/-! ### Observables of the states the items leave -/

theorem regW_jump (s : Ryo.X86.State) (a : BitVec 64) (w : W) (r : Reg) :
    (s.jump a).regW w r = s.regW w r := rfl

theorem rmW_jump (s : Ryo.X86.State) (a : BitVec 64) (w : W) (rm : Rm) :
    (s.jump a).rmW w rm = s.rmW w rm := by
  cases rm <;> rfl

theorem regW_setFlags (s : Ryo.X86.State) (f : Flags) (w : W) (r : Reg) :
    (s.setFlags f).regW w r = s.regW w r := rfl

theorem rmW_reg (s : Ryo.X86.State) (w : W) (r : Reg) : s.rmW w (.reg r) = s.regW w r := rfl

theorem rmW_mem (s : Ryo.X86.State) (w : W) (m : X86.M) : s.rmW w (.mem m) = s.memW w (s.ea m) :=
  rfl

theorem regW_setReg_self (s : Ryo.X86.State) (w : W) (r : Reg) (v : BitVec 64) :
    (s.setReg r v).regW w r = v.setWidth w.bits := by
  simp [State.regW]

theorem regW_other {r r' : Reg} (h : r'.idx ≠ r.idx) (s : Ryo.X86.State) (w : W)
    (v : BitVec 64) : (s.setReg r v).regW w r' = s.regW w r' := by
  simp [State.regW, h]

theorem ax_dx : Reg.idx .rax ≠ Reg.idx .rdx := by decide
theorem dx_ax : Reg.idx .rdx ≠ Reg.idx .rax := by decide
theorem ax_cx : Reg.idx .rax ≠ Reg.idx .rcx := by decide
theorem cx_dx : Reg.idx .rcx ≠ Reg.idx .rdx := by decide

theorem setRegW_d (s : Ryo.X86.State) (r : Reg) (v : BitVec W.d.bits) :
    s.setRegW .d r v = s.setReg r (v.setWidth 64) := rfl

theorem setRegW_dq {w : W} (hw : w = .d ∨ w = .q) (s : Ryo.X86.State) (r : Reg)
    (v : BitVec w.bits) : s.setRegW w r v = s.setReg r (v.setWidth 64) := by
  rcases hw with rfl | rfl <;> rfl

theorem mem_setRegW (s : Ryo.X86.State) (w : W) (r : Reg) (v : BitVec w.bits) :
    (s.setRegW w r v).mem = s.mem := by
  cases w <;> rfl
theorem xmm_setRegW (s : Ryo.X86.State) (w : W) (r : Reg) (v : BitVec w.bits) :
    (s.setRegW w r v).xmm = s.xmm := by
  cases w <;> rfl
theorem rip_setRegW (s : Ryo.X86.State) (w : W) (r : Reg) (v : BitVec w.bits) :
    (s.setRegW w r v).rip = s.rip := by
  cases w <;> rfl
theorem regs_setRegW (s : Ryo.X86.State) (w : W) (r : Reg) (v : BitVec w.bits) (j : Fin 16) :
    (s.setRegW w r v).regs j = if j = r.idx then (s.setRegW w r v).reg r else s.regs j := by
  by_cases h : j = r.idx
  · subst h; simp [State.reg]
  · cases w <;> simp [State.setRegW, h]

/-- A value zero-extended to 64 bits and truncated back. -/
theorem back64 (w : W) (v : BitVec w.bits) : (v.setWidth 64).setWidth w.bits = v := by
  have h : w.bits ≤ 64 := by cases w <;> decide
  rw [BitVec.setWidth_setWidth_of_le _ h, BitVec.setWidth_eq]

theorem back64_32 (v : BitVec 32) : (v.setWidth 64).setWidth W.d.bits = v := back64 .d v

theorem toNat_back32 (v : BitVec 32) : ((v.setWidth 64).setWidth W.d.bits).toNat = v.toNat := by
  rw [BitVec.toNat_setWidth, BitVec.toNat_setWidth,
    Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le v.isLt (by decide)),
    Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le v.isLt (by decide))]

theorem memW_frame_congr {s s' : Ryo.X86.State} (hm : s'.mem = s.mem)
    (hb : s'.reg .rbp = s.reg .rbp) (w : W) (d : BitVec 32) :
    s'.memW w (s'.ea (M.frame d)) = s.memW w (s.ea (M.frame d)) := by
  rw [ea_frame, ea_frame]
  simp only [State.memW, fpAddr, hm, hb]

/-- A frame operand, read at a width: the bytes `read_int` decodes. -/
theorem memW_frame (x : Ryo.X86.State) (w : W) (s : BitVec 32) :
    x.memW w (x.ea (M.frame s)) =
      BitVec.ofNat w.bits (leDecode (bytesAt x.mem (fpAddr x s.toInt) (wbytes w))) := by
  rw [memW_eq, ea_frame, wbytes_eq]

theorem toNat_setWidth_le {m k : Nat} (x : BitVec m) (h : m ≤ k) :
    (x.setWidth k).toNat = x.toNat := by
  rw [BitVec.toNat_setWidth,
    Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le x.isLt (Nat.pow_le_pow_right (by decide) h))]

/-! ### The items, one at a time -/

theorem execItems_cons_ok {ctx : Ctx} {i : Item} {is : List Item} {s s1 : Ryo.X86.State}
    (h : i.exec ctx s = .ok s1) : execItems ctx (i :: is) s = execItems ctx is s1 := by
  rw [execItems_cons, h, ex_bind_ok']

/-- A frame load's value in the 64-bit register. -/
def ldVal : (w : W) → Bool → BitVec w.bits → BitVec 64
  | .b, sx, v => (if sx then v.signExtend 32 else v.setWidth 32).setWidth 64
  | .w, sx, v => (if sx then v.signExtend 32 else v.setWidth 32).setWidth 64
  | .d, _, v => v.setWidth 64
  | .q, _, v => v.setWidth 64

theorem ldVal_dq {w : W} (hw : w = .d ∨ w = .q) (sx : Bool) (v : BitVec w.bits) :
    ldVal w sx v = v.setWidth 64 := by
  rcases hw with rfl | rfl <;> rfl

theorem ldVal_bw {w : W} (hw : w = .b ∨ w = .w) (sx : Bool) (v : BitVec w.bits) :
    ldVal w sx v = (if sx then v.signExtend 32 else v.setWidth 32).setWidth 64 := by
  rcases hw with rfl | rfl <;> rfl

theorem ldVal_toNat (w : W) (v : BitVec w.bits) : (ldVal w false v).toNat = v.toNat := by
  cases w
  · show ((v.setWidth 32).setWidth 64).toNat = v.toNat
    rw [toNat_setWidth_le _ (by decide), toNat_setWidth_le _ (by decide)]
  · show ((v.setWidth 32).setWidth 64).toNat = v.toNat
    rw [toNat_setWidth_le _ (by decide), toNat_setWidth_le _ (by decide)]
  · show (v.setWidth 64).toNat = v.toNat
    rw [toNat_setWidth_le _ (by decide)]
  · show (v.setWidth 64).toNat = v.toNat
    rw [toNat_setWidth_le _ (by decide)]

theorem exec_ld (ctx : Ctx) (w : W) (sx : Bool) (r : Reg) (m : X86.M) (s : Ryo.X86.State) :
    (Item.ld w sx r m).exec ctx s =
      .ok ((s.jump (s.rip + BitVec.ofNat 64 (Item.ld w sx r m).size)).setReg r
        (ldVal w sx (s.memW w (s.ea m)))) := by
  cases w <;> rfl

theorem exec_cdq (ctx : Ctx) (w : W) (s : Ryo.X86.State) :
    (Item.cdq w).exec ctx s =
      .ok ((s.jump (s.rip + BitVec.ofNat 64 (Item.cdq w).size)).setRegW w .rdx
        ((s.regW w .rax).sshiftRight (w.bits - 1))) := rfl

/-- `div`/`idiv` that doesn't fault: the quotient in `rax`, the remainder in `rdx`. -/
theorem exec_div (ctx : Ctx) (sg : Bool) (w : W) (rm : Rm) (s : Ryo.X86.State)
    (hw : w = .d ∨ w = .q) {hi lo bv q r : BitVec w.bits} (hhi : s.regW w .rdx = hi)
    (hlo : s.regW w .rax = lo) (hbv : s.rmW w rm = bv) (h : divF sg hi lo bv = some (q, r)) :
    (Item.div sg w rm).exec ctx s =
      .ok ((((s.jump (s.rip + BitVec.ofNat 64 (Item.div sg w rm).size)).setRegW w .rax q).setRegW
        w .rdx r).setFlags {}) := by
  subst hhi hlo hbv
  rcases hw with rfl | rfl
  all_goals
    simp (config := { decide := true }) only [Item.exec, regW_jump, rmW_jump, h,
      bne_self_eq_false, Bool.false_and, Bool.and_false, Bool.false_eq_true, ↓reduceIte, pure,
      Except.pure]

theorem exec_bsf (ctx : Ctx) (w : W) (reg : Reg) (rm : Rm) (s : Ryo.X86.State) :
    (Item.bsf w reg rm).exec ctx s =
      .ok ((if s.rmW w rm == 0 then
          (s.jump (s.rip + BitVec.ofNat 64 (Item.bsf w reg rm).size)).setReg reg ctx.undef
        else (s.jump (s.rip + BitVec.ofNat 64 (Item.bsf w reg rm).size)).setRegW w reg
          (BitVec.ofNat w.bits (lowestSet (s.rmW w rm)))).setFlags
        { zf := some (s.rmW w rm == 0) }) := by
  first
  | rfl
  | simp only [Item.exec, rmW_jump, pure, Except.pure]

theorem exec_bsr (ctx : Ctx) (w : W) (reg : Reg) (rm : Rm) (s : Ryo.X86.State) :
    (Item.bsr w reg rm).exec ctx s =
      .ok ((if s.rmW w rm == 0 then
          (s.jump (s.rip + BitVec.ofNat 64 (Item.bsr w reg rm).size)).setReg reg ctx.undef
        else (s.jump (s.rip + BitVec.ofNat 64 (Item.bsr w reg rm).size)).setRegW w reg
          (BitVec.ofNat w.bits (highestSet (s.rmW w rm)))).setFlags
        { zf := some (s.rmW w rm == 0) }) := by
  first
  | rfl
  | simp only [Item.exec, rmW_jump, pure, Except.pure]

/-- `bsf` of zero: the register gets `ctx.undef`, `ZF` is set. -/
theorem exec_bsf_z (ctx : Ctx) (w : W) (reg : Reg) (rm : Rm) (s : Ryo.X86.State)
    (hv : s.rmW w rm = 0) :
    (Item.bsf w reg rm).exec ctx s =
      .ok (((s.jump (s.rip + BitVec.ofNat 64 (Item.bsf w reg rm).size)).setReg reg
        ctx.undef).setFlags { zf := some true }) := by
  have h0 : ((0 : BitVec w.bits) == 0) = true := beq_self_eq_true _
  rw [exec_bsf, hv, if_pos h0, h0]

theorem exec_bsf_nz (ctx : Ctx) (w : W) (reg : Reg) (rm : Rm) (s : Ryo.X86.State)
    {v : BitVec w.bits} (hv : s.rmW w rm = v) (h0 : v ≠ 0) :
    (Item.bsf w reg rm).exec ctx s =
      .ok (((s.jump (s.rip + BitVec.ofNat 64 (Item.bsf w reg rm).size)).setRegW w reg
        (BitVec.ofNat w.bits (lowestSet v))).setFlags { zf := some false }) := by
  have hb : (v == 0) = false := beq_eq_false_iff_ne.2 h0
  have hb' : ¬((v == 0) = true) := by rw [hb]; decide
  rw [exec_bsf, hv, if_neg hb', hb]

theorem exec_bsr_z (ctx : Ctx) (w : W) (reg : Reg) (rm : Rm) (s : Ryo.X86.State)
    (hv : s.rmW w rm = 0) :
    (Item.bsr w reg rm).exec ctx s =
      .ok (((s.jump (s.rip + BitVec.ofNat 64 (Item.bsr w reg rm).size)).setReg reg
        ctx.undef).setFlags { zf := some true }) := by
  have h0 : ((0 : BitVec w.bits) == 0) = true := beq_self_eq_true _
  rw [exec_bsr, hv, if_pos h0, h0]

theorem exec_bsr_nz (ctx : Ctx) (w : W) (reg : Reg) (rm : Rm) (s : Ryo.X86.State)
    {v : BitVec w.bits} (hv : s.rmW w rm = v) (h0 : v ≠ 0) :
    (Item.bsr w reg rm).exec ctx s =
      .ok (((s.jump (s.rip + BitVec.ofNat 64 (Item.bsr w reg rm).size)).setRegW w reg
        (BitVec.ofNat w.bits (highestSet v))).setFlags { zf := some false }) := by
  have hb : (v == 0) = false := beq_eq_false_iff_ne.2 h0
  have hb' : ¬((v == 0) = true) := by rw [hb]; decide
  rw [exec_bsr, hv, if_neg hb', hb]

/-- `cmovz` with `ZF` known. -/
theorem exec_cmovz (ctx : Ctx) (w : W) (reg : Reg) (rm : Rm) (s : Ryo.X86.State) {b : Bool}
    (hz : s.flags.zf = some b) :
    (Item.cmov .z w reg rm).exec ctx s =
      .ok ((s.jump (s.rip + BitVec.ofNat 64 (Item.cmov .z w reg rm).size)).setRegW w reg
        (if b then s.rmW w rm else s.regW w reg)) := by
  simp only [Item.exec, Cond.eval, need, X86S.flags_jump, hz, regW_jump, rmW_jump, bind,
    Except.bind, pure, Except.pure]

theorem exec_xorImm (ctx : Ctx) (r : Reg) (imm : BitVec 32) (s : Ryo.X86.State) :
    (Item.aluImm .xor .d (.reg r) imm).exec ctx s =
      .ok (((s.jump (s.rip + BitVec.ofNat 64 (Item.aluImm .xor .d (.reg r) imm).size)).setFlags
        (logicFlags ((s.reg r).setWidth 32 ^^^ imm.signExtend 32))).setReg r
        (((s.reg r).setWidth 32 ^^^ imm.signExtend 32).setWidth 64)) := rfl

theorem exec_orImm (ctx : Ctx) (r : Reg) (imm : BitVec 32) (s : Ryo.X86.State) :
    (Item.aluImm .or .d (.reg r) imm).exec ctx s =
      .ok (((s.jump (s.rip + BitVec.ofNat 64 (Item.aluImm .or .d (.reg r) imm).size)).setFlags
        (logicFlags ((s.reg r).setWidth 32 ||| imm.signExtend 32))).setReg r
        (((s.reg r).setWidth 32 ||| imm.signExtend 32).setWidth 64)) := rfl

/-- `setReg` of a non-zero value is a `mov`, which keeps the flags. -/
theorem setForm_beq (v : BitVec 64) (h : v ≠ 0) : (setForm v == 0) = false := by
  have h' : ¬((v == 0) = true) := by simpa using h
  unfold setForm
  rw [if_neg h']
  split <;> (try split) <;> rfl

/-! ### What a run of items leaves unchanged -/

/-- Memory, the registers outside `cl` and the `xmm`s unchanged, `rip` moved past the items. -/
structure Facts (cl : List (Fin 16)) (x y : Ryo.X86.State) (items : List Item) : Prop where
  mem : y.mem = x.mem
  regs : ∀ i : Fin 16, i ∉ cl → y.regs i = x.regs i
  xmm : y.xmm = x.xmm
  rip : y.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum

theorem Facts.nil (cl : List (Fin 16)) (x : Ryo.X86.State) : Facts cl x x [] :=
  ⟨rfl, fun _ _ => rfl, rfl, by simp⟩

theorem Facts.one {cl : List (Fin 16)} {s z : Ryo.X86.State} {i : Item} (hm : z.mem = s.mem)
    (hr : ∀ j : Fin 16, j ∉ cl → z.regs j = s.regs j) (hx : z.xmm = s.xmm)
    (hrip : z.rip = s.rip + BitVec.ofNat 64 i.size) : Facts cl s z [i] :=
  ⟨hm, hr, hx, by rw [hrip]; simp⟩

theorem Facts.cons {cl : List (Fin 16)} {x y z : Ryo.X86.State} {i : Item} {is : List Item}
    (h1 : Facts cl x y [i]) (h2 : Facts cl y z is) : Facts cl x z (i :: is) := by
  refine ⟨h2.mem.trans h1.mem, fun j hj => (h2.regs j hj).trans (h1.regs j hj),
    h2.xmm.trans h1.xmm, ?_⟩
  rw [h2.rip, h1.rip]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, Nat.add_zero,
    BitVec.ofNat_add, BitVec.add_assoc]

theorem Facts.rbp {cl : List (Fin 16)} {x y : Ryo.X86.State} {is : List Item}
    (hf : Facts cl x y is) (h5 : (5 : Fin 16) ∉ cl) : y.reg .rbp = x.reg .rbp :=
  hf.regs 5 h5

theorem chain {cl : List (Fin 16)} {ctx : Ctx} {i : Item} {is : List Item}
    {x y : Ryo.X86.State} {P : Ryo.X86.State → Prop} (hx : i.exec ctx x = .ok y)
    (hf : Facts cl x y [i]) (h : ∃ z, execItems ctx is y = .ok z ∧ Facts cl y z is ∧ P z) :
    ∃ z, execItems ctx (i :: is) x = .ok z ∧ Facts cl x z (i :: is) ∧ P z := by
  obtain ⟨z, hz, hf2, hp⟩ := h
  exact ⟨z, by rw [execItems_cons_ok hx]; exact hz, hf.cons hf2, hp⟩

theorem chain_nil {cl : List (Fin 16)} {ctx : Ctx} {y : Ryo.X86.State}
    {P : Ryo.X86.State → Prop} (hp : P y) :
    ∃ z, execItems ctx [] y = .ok z ∧ Facts cl y z [] ∧ P z :=
  ⟨y, rfl, Facts.nil cl y, hp⟩

/-- `Facts` of `div`'s state (`exec_div`): `rax`, `rdx`, flags, `rip`. -/
theorem facts_div (s : Ryo.X86.State) (i : Item) (w : W) (q r : BitVec w.bits) :
    Facts [0, 1, 2] s ((((s.jump (s.rip + BitVec.ofNat 64 i.size)).setRegW w .rax q).setRegW w
      .rdx r).setFlags {}) [i] := by
  refine Facts.one ?_ ?_ ?_ ?_
  · rw [X86S.mem_setFlags, mem_setRegW, mem_setRegW, X86S.mem_jump]
  · intro j hj
    simp at hj
    have h2 : ¬j = Reg.idx .rdx := by rw [idx_rdx]; exact hj.2.2
    have h0 : ¬j = Reg.idx .rax := by rw [idx_rax]; exact hj.1
    rw [X86S.regs_setFlags, regs_setRegW, if_neg h2, regs_setRegW, if_neg h0, X86S.regs_jump]
  · rw [X86S.xmm_setFlags, xmm_setRegW, xmm_setRegW, X86S.xmm_jump]
  · rw [X86S.rip_setFlags, rip_setRegW, rip_setRegW, X86S.rip_jump]

/-- `Facts` of one item's state (a register write or two on `cl`, flags, `rip`). -/
macro "ld_fone" : tactic =>
  `(tactic| (refine Facts.one ?_ ?_ ?_ ?_ <;>
    first
    | (intro j hj
       simp at hj
       first
       | simp [mem_setRegW, xmm_setRegW, rip_setRegW, regs_setRegW, idx_rdx, hj]
       | simp [State.setRegW, mem_setRegW, xmm_setRegW, rip_setRegW, regs_setRegW, idx_rdx, hj])
    | rfl
    | simp [mem_setRegW, xmm_setRegW, rip_setRegW]
    | simp [State.setRegW, mem_setRegW, xmm_setRegW, rip_setRegW]))

/-! ### The end of the sequences: the result's store -/

/-- `post_mem`, with the registers outside `cl` unchanged. -/
theorem post_memX {cl : List (Fin 16)} {op : Full.Opcode} {ops : List (R.Opnd Nat)}
    {vals : Operands} {items : List Item} {st st' : OpSem.State} {ctl : Control}
    {x y : Ryo.X86.State} {n V : Nat} {d : BitVec 32} {bs : List AbstractByte} {a : BitVec 64}
    (hr : Rel st x) (hw : st.writeFrame d.toInt bs = .ok st') (hlen : bs.length = n)
    (hn : n ≤ 16) (hwr : wranges op vals = [(d.toInt, n)]) (hx : BytesRel bs (leEncode n V))
    (hyb : y.reg .rbp = x.reg .rbp) (hym : y.mem = x.mem)
    (hyr : ∀ i : Fin 16, i ∉ cl → y.regs i = x.regs i) (hyx : y.xmm = x.xmm)
    (hrip : a = x.rip + BitVec.ofNat 64 (items.map Item.size).sum) (hctl : ctl = .next) :
    PostX cl op ops vals items none st st' ctl x
      ((y.jump a).setMem ((y.jump a).ea (M.frame d)) n V) := by
  have hb := toInt_bounds d
  have hm : ((y.jump a).setMem ((y.jump a).ea (M.frame d)) n V).mem =
      x.mem.write (fpAddr x d.toInt) bs.length V := by
    simp only [X86S.mem_setMem, X86S.mem_jump, hym, ea_frame, hlen]
    simp [fpAddr, hyb]
  obtain ⟨hrel, h1, h2, h3, h4, h5⟩ := rel_store hr hw
    (by omega) (by omega) (by rw [hlen]; exact hx) (by simpa using hyb) hm
  refine ⟨hrel, ⟨h2, h1, h3, h4, h5⟩, fun i hi => ?_, ?_, ?_, fun a' ha => ?_, hctl⟩
  · simpa using hyr i hi
  · simpa using hyx
  · simpa using hrip
  · rw [hm]
    apply X86.Mem.write_other
    have := ha (d.toInt, n) (by simp [hwr])
    simpa [hlen] using this

/-- A run of `body`, then the store of `Rr`'s low `w` bits at `d`. -/
theorem end_store {cl : List (Fin 16)} (h5 : (5 : Fin 16) ∉ cl) {ctx : Ctx} {op : Full.Opcode}
    {ops : List (R.Opnd Nat)} {vals : Operands} {body : List Item} {st st' : OpSem.State}
    {x y : Ryo.X86.State} {w : W} {Rr : Reg} {d : BitVec 32} {bs : List AbstractByte}
    (hr : Rel st x) (hw : st.writeFrame d.toInt bs = .ok st') (hlen : bs.length = w.bits / 8)
    (hwr : wranges op vals = [(d.toInt, w.bits / 8)])
    (hy : execItems ctx body x = .ok y) (hf : Facts cl x y body)
    (hx : BytesRel bs (leEncode (w.bits / 8) (y.regW w Rr).toNat)) :
    ∃ x', execItems ctx (body ++ [.st w Rr (M.frame d)]) x = .ok x' ∧
      PostX cl op ops vals (body ++ [.st w Rr (M.frame d)]) none st st' .next x x' := by
  refine ⟨_, ?_, post_memX (a := y.rip + BitVec.ofNat 64 (Item.st w Rr (M.frame d)).size)
    hr hw hlen (by cases w <;> decide) hwr hx (hf.rbp h5) hf.mem hf.regs hf.xmm ?_ rfl⟩
  · rw [execItems_append, hy, ex_bind_ok']
    rfl
  · rw [hf.rip, List.map_append, List.sum_append]
    simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, Nat.add_zero,
      BitVec.ofNat_add, BitVec.add_assoc]

/-! ### Division -/

def divQ (sg : Bool) {n : Nat} (a b : BitVec n) : BitVec n := if sg then a.sdiv b else a / b
def divR (sg : Bool) {n : Nat} (a b : BitVec n) : BitVec n := if sg then a.srem b else a % b
/-- What `div sg rem` computes: the quotient, or (`rem`) the remainder. -/
def divRes (sg rem : Bool) {n : Nat} (a b : BitVec n) : BitVec n :=
  if rem then divR sg a b else divQ sg a b

/-- The body of the `div` sequence (`sequence`), before the store. -/
def divBody (signed : Bool) (w : W) (a b : X86.M) : List Item :=
  let ext : Item := if signed then .cdq (if w == .q then .q else .d) else .setReg .rdx 0
  match w with
  | .d | .q => [ld w a, ext, .div signed w (.mem b)]
  | _ => [.ld w signed R a, .ld w signed C b, ext, .div signed .d (.reg C)]

theorem divBody_W {w : W} (hw : w = .d ∨ w = .q) (sg : Bool) (a b : X86.M) :
    divBody sg w a b =
      [.ld w false .rax a, if sg then .cdq w else .setReg .rdx 0, .div sg w (.mem b)] := by
  rcases hw with rfl | rfl <;> rfl

theorem divBody_N {w : W} (hw : w = .b ∨ w = .w) (sg : Bool) (a b : X86.M) :
    divBody sg w a b =
      [.ld w sg .rax a, .ld w sg .rcx b, if sg then .cdq .d else .setReg .rdx 0,
        .div sg .d (.reg .rcx)] := by
  rcases hw with rfl | rfl <;> rfl

theorem intMin_eq (n : Nat) : OpSem.intMin n = BitVec.intMin n := by
  apply BitVec.eq_of_toNat_eq
  simp [OpSem.intMin, BitVec.toNat_intMin]

theorem ub_ne {α : Type} (m : String) (v : α) : (ub m : OpSem.M α) ≠ .ok v := by
  simp [ub, throw, throwThe, MonadExceptOf.throw]

/-- `opSem`'s division succeeds only for a non-zero divisor and not `MIN / -1` (MIR's rules). -/
theorem intBin_div_ok (sg rem : Bool) {n : Nat} (a b res : BitVec n)
    (h : intBin (if rem then "unchecked_rem" else "unchecked_div") sg a b = .ok res) :
    b ≠ 0 ∧ (sg = true → (a ≠ BitVec.intMin n ∨ b ≠ -1#n)) ∧ res = divRes sg rem a b := by
  have e : intBin (if rem then "unchecked_rem" else "unchecked_div") sg a b =
      if b == 0 then ub "division by zero"
      else if sg && a == OpSem.intMin n && b == BitVec.allOnes n then
        ub "overflow in signed division (MIN / -1)"
      else pure (divRes sg rem a b) := by
    cases rem <;> cases sg <;> simp [intBin, divRes, divQ, divR]
  rw [e] at h
  split at h
  · exact absurd h (ub_ne _ _)
  · rename_i hb
    split at h
    · exact absurd h (ub_ne _ _)
    · rename_i hov
      refine ⟨by simpa using hb, fun hs => ?_, ?_⟩
      · subst hs
        by_cases ha : a = BitVec.intMin n
        · refine Or.inr (fun hb1 => hov ?_)
          simp [ha, hb1, intMin_eq, BitVec.neg_one_eq_allOnes]
        · exact Or.inl ha
      · simp only [pure, Except.pure, Except.ok.injEq] at h
        exact h.symm

/-- Unsigned `div` of `0:a` by a non-zero `b`. -/
theorem divF_u {n : Nat} (a b : BitVec n) (hb : b ≠ 0) :
    divF false 0 a b = some (a / b, a % b) := by
  have hb' : ¬((b == 0) = true) := by simpa using hb
  have hlt : a.toNat / b.toNat < 2 ^ n := Nat.lt_of_le_of_lt (Nat.div_le_self _ _) a.isLt
  have h0 : (0 : BitVec n).toNat = 0 := by simp
  unfold divF
  rw [if_neg hb', if_neg (show ¬(false = true) by decide)]
  simp only [h0, Nat.zero_mul, Nat.zero_add]
  rw [if_pos hlt, BitVec.udiv_def, BitVec.umod_def]

/-- Signed `div` of `hi:a`, `hi` the sign extension of `a`, by a non-zero `b`, not `MIN / -1`. -/
theorem divF_s {n : Nat} (hi a b : BitVec n) (hb : b ≠ 0)
    (hov : a ≠ BitVec.intMin n ∨ b ≠ -1#n) (hext : (hi ++ a).toInt = a.toInt) :
    divF true hi a b = some (a.sdiv b, a.srem b) := by
  have hq : a.toInt.tdiv b.toInt = (a.sdiv b).toInt :=
    (BitVec.toInt_sdiv_of_ne_or_ne a b hov).symm
  have hr : a.toInt.tmod b.toInt = (a.srem b).toInt := (BitVec.toInt_srem a b).symm
  have h1 : -2 ^ (n - 1) ≤ (a.sdiv b).toInt := BitVec.le_toInt _
  have h2 : (a.sdiv b).toInt < 2 ^ (n - 1) := BitVec.toInt_lt
  have hb' : ¬((b == 0) = true) := by simpa using hb
  unfold divF
  rw [if_neg hb', if_pos (show true = true from rfl)]
  simp only [hext, hq, hr, BitVec.ofInt_toInt]
  rw [if_pos ⟨h1, h2⟩]

theorem hi_ext32 (a : BitVec 32) : ((a.sshiftRight 31) ++ a).toInt = a.toInt := by
  have h : a.sshiftRight 31 ++ a = a.signExtend 64 := by bv_decide
  exact (congrArg BitVec.toInt h).trans (BitVec.toInt_signExtend_of_le (by decide))

theorem hi_ext64 (a : BitVec 64) : ((a.sshiftRight 63) ++ a).toInt = a.toInt := by
  have h : a.sshiftRight 63 ++ a = a.signExtend 128 := by bv_decide
  exact (congrArg BitVec.toInt h).trans (BitVec.toInt_signExtend_of_le (by decide))

/-- `cdq`/`cqo`'s `rdx` and `rax` make the sign-extended dividend. -/
theorem hi_ext {w : W} (hw : w = .d ∨ w = .q) (a : BitVec w.bits) :
    ((a.sshiftRight (w.bits - 1)) ++ a).toInt = a.toInt := by
  rcases hw with rfl | rfl
  · exact hi_ext32 a
  · exact hi_ext64 a

theorem udiv_zext {n : Nat} (hn : n ≤ 32) (A B : BitVec n) :
    ((A.setWidth 32) / (B.setWidth 32)).setWidth n = A / B := by
  apply BitVec.eq_of_toNat_eq
  have hA : A.toNat < 2 ^ 32 := Nat.lt_of_lt_of_le A.isLt (Nat.pow_le_pow_right (by decide) hn)
  have hB : B.toNat < 2 ^ 32 := Nat.lt_of_lt_of_le B.isLt (Nat.pow_le_pow_right (by decide) hn)
  have hq : A.toNat / B.toNat < 2 ^ n := Nat.lt_of_le_of_lt (Nat.div_le_self _ _) A.isLt
  simp only [BitVec.toNat_setWidth, BitVec.toNat_udiv, Nat.mod_eq_of_lt hA, Nat.mod_eq_of_lt hB,
    Nat.mod_eq_of_lt hq]

theorem umod_zext {n : Nat} (hn : n ≤ 32) (A B : BitVec n) :
    ((A.setWidth 32) % (B.setWidth 32)).setWidth n = A % B := by
  apply BitVec.eq_of_toNat_eq
  have hA : A.toNat < 2 ^ 32 := Nat.lt_of_lt_of_le A.isLt (Nat.pow_le_pow_right (by decide) hn)
  have hB : B.toNat < 2 ^ 32 := Nat.lt_of_lt_of_le B.isLt (Nat.pow_le_pow_right (by decide) hn)
  have hr : A.toNat % B.toNat < 2 ^ n := Nat.lt_of_le_of_lt (Nat.mod_le _ _) A.isLt
  simp only [BitVec.toNat_setWidth, BitVec.toNat_umod, Nat.mod_eq_of_lt hA, Nat.mod_eq_of_lt hB,
    Nat.mod_eq_of_lt hr]

theorem sdiv_sext {n : Nat} (hn : n ≤ 32) (A B : BitVec n)
    (hne : A.signExtend 32 ≠ BitVec.intMin 32) :
    ((A.signExtend 32).sdiv (B.signExtend 32)).setWidth n = A.sdiv B := by
  have e1 : ((A.signExtend 32).sdiv (B.signExtend 32)).toInt = A.toInt.tdiv B.toInt := by
    rw [BitVec.toInt_sdiv_of_ne_or_ne _ _ (Or.inl hne), BitVec.toInt_signExtend_of_le hn,
      BitVec.toInt_signExtend_of_le hn]
  have e2 : A.sdiv B = BitVec.ofInt n (A.toInt.tdiv B.toInt) := by
    apply BitVec.eq_of_toInt_eq
    rw [BitVec.toInt_sdiv, BitVec.toInt_ofInt]
  rw [← BitVec.signExtend_eq_setWidth_of_le _ hn, e2]
  show BitVec.ofInt n ((A.signExtend 32).sdiv (B.signExtend 32)).toInt = _
  rw [e1]

theorem srem_sext {n : Nat} (hn : n ≤ 32) (A B : BitVec n) :
    ((A.signExtend 32).srem (B.signExtend 32)).setWidth n = A.srem B := by
  have e1 : ((A.signExtend 32).srem (B.signExtend 32)).toInt = A.toInt.tmod B.toInt := by
    rw [BitVec.toInt_srem, BitVec.toInt_signExtend_of_le hn, BitVec.toInt_signExtend_of_le hn]
  have e2 : A.srem B = BitVec.ofInt n (A.toInt.tmod B.toInt) := by
    rw [← BitVec.toInt_srem, BitVec.ofInt_toInt]
  rw [← BitVec.signExtend_eq_setWidth_of_le _ hn, e2]
  show BitVec.ofInt n ((A.signExtend 32).srem (B.signExtend 32)).toInt = _
  rw [e1]

theorem zext_ne {n : Nat} (hn : n ≤ 32) (B : BitVec n) (h : B ≠ 0) : B.setWidth 32 ≠ 0 := by
  intro h'
  apply h
  apply BitVec.eq_of_toNat_eq
  have e := congrArg BitVec.toNat h'
  rw [toNat_setWidth_le _ hn] at e
  rw [e]
  simp

theorem sext_ne {n : Nat} (hn : n ≤ 32) (B : BitVec n) (h : B ≠ 0) : B.signExtend 32 ≠ 0 := by
  intro h'
  apply h
  apply BitVec.eq_of_toInt_eq
  have e := congrArg BitVec.toInt h'
  rw [BitVec.toInt_signExtend_of_le hn] at e
  rw [e]
  simp

theorem intMin32 : BitVec.intMin 32 = 0x80000000#32 := by decide
theorem sext8_ne (A : BitVec 8) : A.signExtend 32 ≠ 0x80000000#32 := by bv_decide
theorem sext16_ne (A : BitVec 16) : A.signExtend 32 ≠ 0x80000000#32 := by bv_decide

/-- An 8- or 16-bit value sign-extended to 32 bits isn't `i32::MIN`: no `idiv` overflow. -/
theorem sext_ne_intMin {w : W} (hw : w = .b ∨ w = .w) (A : BitVec w.bits) :
    A.signExtend 32 ≠ BitVec.intMin 32 := by
  rw [intMin32]
  rcases hw with rfl | rfl
  · exact sext8_ne A
  · exact sext16_ne A

/-- The 32- and 64-bit forms: load `a`, extend into `rdx`, divide by the frame operand `b`. -/
theorem body_divW (ctx : Ctx) (x : Ryo.X86.State) (sg : Bool) (w : W) (hw : w = .d ∨ w = .q)
    (a b : BitVec 32) (hB0 : x.memW w (x.ea (M.frame b)) ≠ 0)
    (hov : sg = true → (x.memW w (x.ea (M.frame a)) ≠ BitVec.intMin w.bits ∨
      x.memW w (x.ea (M.frame b)) ≠ -1#w.bits)) :
    ∃ y, execItems ctx (divBody sg w (M.frame a) (M.frame b)) x = .ok y ∧
      Facts [0, 1, 2] x y (divBody sg w (M.frame a) (M.frame b)) ∧
      y.regW w .rax = divQ sg (x.memW w (x.ea (M.frame a))) (x.memW w (x.ea (M.frame b))) ∧
      y.regW w .rdx = divR sg (x.memW w (x.ea (M.frame a))) (x.memW w (x.ea (M.frame b))) := by
  rw [divBody_W hw]
  generalize hA : x.memW w (x.ea (M.frame a)) = A at hov ⊢
  generalize hB : x.memW w (x.ea (M.frame b)) = B at hB0 hov ⊢
  -- `mov`/`movzx` of `a` into `rax`
  obtain ⟨s1, e1, f1, v1⟩ : ∃ s1, (Item.ld w false .rax (M.frame a)).exec ctx x = .ok s1 ∧
      Facts [0, 1, 2] x s1 [Item.ld w false .rax (M.frame a)] ∧ s1.regW w .rax = A := by
    refine ⟨_, exec_ld ctx w false .rax (M.frame a) x, by ld_fone, ?_⟩
    rw [regW_setReg_self, ldVal_dq hw, back64, hA]
  refine chain e1 f1 ?_
  have hm1 : s1.mem = x.mem := f1.mem
  have hb1 : s1.reg .rbp = x.reg .rbp := f1.rbp (by decide)
  cases sg
  · -- `xor edx, edx`, `div`
    obtain ⟨s2, e2, f2, v2a, v2d⟩ : ∃ s2, (Item.setReg .rdx 0).exec ctx s1 = .ok s2 ∧
        Facts [0, 1, 2] s1 s2 [Item.setReg .rdx 0] ∧ s2.regW w .rax = A ∧
        s2.regW w .rdx = 0 := by
      refine ⟨_, exec_setReg ctx .rdx 0 s1, by ld_fone, ?_, ?_⟩
      · rw [regW_setFlags, regW_other ax_dx, regW_jump, v1]
      · rw [regW_setFlags, regW_setReg_self]
        apply BitVec.eq_of_toNat_eq
        simp
    refine chain e2 f2 ?_
    have hm2 : s2.mem = x.mem := f2.mem.trans hm1
    have hb2 : s2.reg .rbp = x.reg .rbp := (f2.rbp (by decide)).trans hb1
    have hd : divF false 0 A B = some (A / B, A % B) := divF_u A B hB0
    obtain ⟨s3, e3, f3, v3a, v3d⟩ : ∃ s3,
        (Item.div false w (.mem (M.frame b))).exec ctx s2 = .ok s3 ∧
        Facts [0, 1, 2] s2 s3 [Item.div false w (.mem (M.frame b))] ∧
        s3.regW w .rax = A / B ∧ s3.regW w .rdx = A % B := by
      refine ⟨_, exec_div ctx false w (.mem (M.frame b)) s2 hw v2d v2a
        (by rw [rmW_mem, memW_frame_congr hm2 hb2, hB]) hd, facts_div _ _ _ _ _, ?_, ?_⟩
      · rw [regW_setFlags, setRegW_dq hw, regW_other ax_dx, setRegW_dq hw, regW_setReg_self,
          back64]
      · rw [regW_setFlags, setRegW_dq hw, regW_setReg_self, back64]
    exact chain e3 f3 (chain_nil ⟨v3a, v3d⟩)
  · -- `cdq`/`cqo`, `idiv`
    obtain ⟨s2, e2, f2, v2a, v2d⟩ : ∃ s2, (Item.cdq w).exec ctx s1 = .ok s2 ∧
        Facts [0, 1, 2] s1 s2 [Item.cdq w] ∧ s2.regW w .rax = A ∧
        s2.regW w .rdx = A.sshiftRight (w.bits - 1) := by
      refine ⟨_, exec_cdq ctx w s1, by ld_fone, ?_, ?_⟩
      · rw [setRegW_dq hw, regW_other ax_dx, regW_jump, v1]
      · rw [setRegW_dq hw, regW_setReg_self, back64, v1]
    refine chain e2 f2 ?_
    have hm2 : s2.mem = x.mem := f2.mem.trans hm1
    have hb2 : s2.reg .rbp = x.reg .rbp := (f2.rbp (by decide)).trans hb1
    have hd : divF true (A.sshiftRight (w.bits - 1)) A B = some (A.sdiv B, A.srem B) :=
      divF_s _ A B hB0 (hov rfl) (hi_ext hw A)
    obtain ⟨s3, e3, f3, v3a, v3d⟩ : ∃ s3,
        (Item.div true w (.mem (M.frame b))).exec ctx s2 = .ok s3 ∧
        Facts [0, 1, 2] s2 s3 [Item.div true w (.mem (M.frame b))] ∧
        s3.regW w .rax = A.sdiv B ∧ s3.regW w .rdx = A.srem B := by
      refine ⟨_, exec_div ctx true w (.mem (M.frame b)) s2 hw v2d v2a
        (by rw [rmW_mem, memW_frame_congr hm2 hb2, hB]) hd, facts_div _ _ _ _ _, ?_, ?_⟩
      · rw [regW_setFlags, setRegW_dq hw, regW_other ax_dx, setRegW_dq hw, regW_setReg_self,
          back64]
      · rw [regW_setFlags, setRegW_dq hw, regW_setReg_self, back64]
    exact chain e3 f3 (chain_nil ⟨v3a, v3d⟩)

/-- The 8- and 16-bit forms: both operands extended to 32 bits (`movzx`/`movsx`), divided
there; the low bits are the narrow quotient and remainder. -/
theorem body_divN (ctx : Ctx) (x : Ryo.X86.State) (sg : Bool) (w : W) (hw : w = .b ∨ w = .w)
    (a b : BitVec 32) (hB0 : x.memW w (x.ea (M.frame b)) ≠ 0) :
    ∃ y, execItems ctx (divBody sg w (M.frame a) (M.frame b)) x = .ok y ∧
      Facts [0, 1, 2] x y (divBody sg w (M.frame a) (M.frame b)) ∧
      y.regW w .rax = divQ sg (x.memW w (x.ea (M.frame a))) (x.memW w (x.ea (M.frame b))) ∧
      y.regW w .rdx = divR sg (x.memW w (x.ea (M.frame a))) (x.memW w (x.ea (M.frame b))) := by
  rw [divBody_N hw]
  have h32 : w.bits ≤ 32 := by rcases hw with rfl | rfl <;> decide
  have h64 : w.bits ≤ 64 := by rcases hw with rfl | rfl <;> decide
  generalize hA : x.memW w (x.ea (M.frame a)) = A
  generalize hB : x.memW w (x.ea (M.frame b)) = B at hB0 ⊢
  obtain ⟨s1, e1, f1, v1⟩ : ∃ s1, (Item.ld w sg .rax (M.frame a)).exec ctx x = .ok s1 ∧
      Facts [0, 1, 2] x s1 [Item.ld w sg .rax (M.frame a)] ∧
      s1.reg .rax = (if sg then A.signExtend 32 else A.setWidth 32).setWidth 64 := by
    refine ⟨_, exec_ld ctx w sg .rax (M.frame a) x, by ld_fone, ?_⟩
    rw [X86S.reg_setReg, if_pos rfl, ldVal_bw hw, hA]
  refine chain e1 f1 ?_
  have hm1 : s1.mem = x.mem := f1.mem
  have hb1 : s1.reg .rbp = x.reg .rbp := f1.rbp (by decide)
  obtain ⟨s2, e2, f2, v2a, v2c⟩ : ∃ s2, (Item.ld w sg .rcx (M.frame b)).exec ctx s1 = .ok s2 ∧
      Facts [0, 1, 2] s1 s2 [Item.ld w sg .rcx (M.frame b)] ∧ s2.reg .rax = s1.reg .rax ∧
      s2.reg .rcx = (if sg then B.signExtend 32 else B.setWidth 32).setWidth 64 := by
    refine ⟨_, exec_ld ctx w sg .rcx (M.frame b) s1, by ld_fone, ?_, ?_⟩
    · rw [X86S.reg_setReg, if_neg ax_cx, X86S.reg_jump]
    · rw [X86S.reg_setReg, if_pos rfl, ldVal_bw hw, memW_frame_congr hm1 hb1, hB]
  refine chain e2 f2 ?_
  have lo : s2.regW .d .rax = (if sg then A.signExtend 32 else A.setWidth 32) := by
    show (s2.reg .rax).setWidth 32 = _
    rw [v2a, v1, BitVec.setWidth_setWidth_of_le _ (by decide), BitVec.setWidth_eq]
  have bv : s2.regW .d .rcx = (if sg then B.signExtend 32 else B.setWidth 32) := by
    show (s2.reg .rcx).setWidth 32 = _
    rw [v2c, BitVec.setWidth_setWidth_of_le _ (by decide), BitVec.setWidth_eq]
  cases sg
  · -- `xor edx, edx`, `div ecx`
    rw [if_neg (show ¬(false = true) by decide)] at lo bv
    obtain ⟨s3, e3, f3, v3a, v3c, v3d⟩ : ∃ s3, (Item.setReg .rdx 0).exec ctx s2 = .ok s3 ∧
        Facts [0, 1, 2] s2 s3 [Item.setReg .rdx 0] ∧ s3.regW .d .rax = A.setWidth 32 ∧
        s3.regW .d .rcx = B.setWidth 32 ∧ s3.regW .d .rdx = 0 := by
      refine ⟨_, exec_setReg ctx .rdx 0 s2, by ld_fone, ?_, ?_, ?_⟩
      · rw [regW_setFlags, regW_other ax_dx, regW_jump, lo]
      · rw [regW_setFlags, regW_other cx_dx, regW_jump, bv]
      · rw [regW_setFlags, regW_setReg_self]
        apply BitVec.eq_of_toNat_eq
        simp
    refine chain e3 f3 ?_
    have hd : divF false 0 (A.setWidth 32) (B.setWidth 32) =
        some (A.setWidth 32 / B.setWidth 32, A.setWidth 32 % B.setWidth 32) :=
      divF_u _ _ (zext_ne h32 B hB0)
    obtain ⟨s4, e4, f4, v4a, v4d⟩ : ∃ s4, (Item.div false .d (.reg .rcx)).exec ctx s3 = .ok s4 ∧
        Facts [0, 1, 2] s3 s4 [Item.div false .d (.reg .rcx)] ∧
        s4.regW w .rax = A / B ∧ s4.regW w .rdx = A % B := by
      refine ⟨_, exec_div ctx false .d (.reg .rcx) s3 (Or.inl rfl) v3d v3a
        (by rw [rmW_reg]; exact v3c) hd, facts_div _ _ _ _ _, ?_, ?_⟩
      · simp only [regW_setFlags, State.setRegW, regW_other ax_dx, regW_setReg_self]
        exact (BitVec.setWidth_setWidth_of_le _ h64).trans (udiv_zext h32 A B)
      · simp only [regW_setFlags, State.setRegW, regW_setReg_self]
        exact (BitVec.setWidth_setWidth_of_le _ h64).trans (umod_zext h32 A B)
    exact chain e4 f4 (chain_nil ⟨v4a, v4d⟩)
  · -- `cdq`, `idiv ecx`
    rw [if_pos (show true = true from rfl)] at lo bv
    obtain ⟨s3, e3, f3, v3a, v3c, v3d⟩ : ∃ s3, (Item.cdq .d).exec ctx s2 = .ok s3 ∧
        Facts [0, 1, 2] s2 s3 [Item.cdq .d] ∧ s3.regW .d .rax = A.signExtend 32 ∧
        s3.regW .d .rcx = B.signExtend 32 ∧
        s3.regW .d .rdx = (A.signExtend 32).sshiftRight 31 := by
      refine ⟨_, exec_cdq ctx .d s2, by ld_fone, ?_, ?_, ?_⟩
      · simp only [State.setRegW]
        rw [regW_other ax_dx, regW_jump, lo]
      · simp only [State.setRegW]
        rw [regW_other cx_dx, regW_jump, bv]
      · simp only [State.setRegW]
        rw [regW_setReg_self, back64, lo]
        try rfl
    refine chain e3 f3 ?_
    have hd : divF true ((A.signExtend 32).sshiftRight 31) (A.signExtend 32) (B.signExtend 32) =
        some ((A.signExtend 32).sdiv (B.signExtend 32), (A.signExtend 32).srem (B.signExtend 32)) :=
      divF_s _ _ _ (sext_ne h32 B hB0) (Or.inl (sext_ne_intMin hw A)) (hi_ext32 _)
    obtain ⟨s4, e4, f4, v4a, v4d⟩ : ∃ s4, (Item.div true .d (.reg .rcx)).exec ctx s3 = .ok s4 ∧
        Facts [0, 1, 2] s3 s4 [Item.div true .d (.reg .rcx)] ∧
        s4.regW w .rax = A.sdiv B ∧ s4.regW w .rdx = A.srem B := by
      refine ⟨_, exec_div ctx true .d (.reg .rcx) s3 (Or.inl rfl) v3d v3a
        (by rw [rmW_reg]; exact v3c) hd, facts_div _ _ _ _ _, ?_, ?_⟩
      · simp only [regW_setFlags, State.setRegW, regW_other ax_dx, regW_setReg_self]
        exact (BitVec.setWidth_setWidth_of_le _ h64).trans (sdiv_sext h32 A B (sext_ne_intMin hw A))
      · simp only [regW_setFlags, State.setRegW, regW_setReg_self]
        exact (BitVec.setWidth_setWidth_of_le _ h64).trans (srem_sext h32 A B)
    exact chain e4 f4 (chain_nil ⟨v4a, v4d⟩)

/-- The whole `div` sequence, from the operands' facts `opSem` gives. -/
theorem fin_div (sg rem : Bool) (w : W) {ctx : Ctx} {op : Full.Opcode}
    {ops : List (R.Opnd Nat)} {vals : Operands} {st st' : OpSem.State} {x : Ryo.X86.State}
    {s0 s1 s2 : BitVec 32} {bs : List AbstractByte} (hr : Rel st x)
    (hw : st.writeFrame s0.toInt bs = .ok st') (hlen : bs.length = w.bits / 8)
    (hwr : wranges op vals = [(s0.toInt, w.bits / 8)])
    (hB0 : x.memW w (x.ea (M.frame s2)) ≠ 0)
    (hov : sg = true → (x.memW w (x.ea (M.frame s1)) ≠ BitVec.intMin w.bits ∨
      x.memW w (x.ea (M.frame s2)) ≠ -1#w.bits))
    (hx : BytesRel bs (leEncode (w.bits / 8)
      (divRes sg rem (x.memW w (x.ea (M.frame s1))) (x.memW w (x.ea (M.frame s2)))).toNat)) :
    ∃ x', execItems ctx (divBody sg w (M.frame s1) (M.frame s2) ++
        [.st w (if rem then .rdx else .rax) (M.frame s0)]) x = .ok x' ∧
      PostX [0, 1, 2] op ops vals (divBody sg w (M.frame s1) (M.frame s2) ++
        [.st w (if rem then .rdx else .rax) (M.frame s0)]) none st st' .next x x' := by
  have key : ∃ y, execItems ctx (divBody sg w (M.frame s1) (M.frame s2)) x = .ok y ∧
      Facts [0, 1, 2] x y (divBody sg w (M.frame s1) (M.frame s2)) ∧
      y.regW w .rax = divQ sg (x.memW w (x.ea (M.frame s1))) (x.memW w (x.ea (M.frame s2))) ∧
      y.regW w .rdx = divR sg (x.memW w (x.ea (M.frame s1))) (x.memW w (x.ea (M.frame s2))) := by
    cases w
    · exact body_divN ctx x sg .b (Or.inl rfl) s1 s2 hB0
    · exact body_divN ctx x sg .w (Or.inr rfl) s1 s2 hB0
    · exact body_divW ctx x sg .d (Or.inl rfl) s1 s2 hB0 hov
    · exact body_divW ctx x sg .q (Or.inr rfl) s1 s2 hB0 hov
  obtain ⟨y, hy, hf, hq, hrm⟩ := key
  refine end_store (by decide) hr hw hlen hwr hy hf ?_
  cases rem
  · rw [if_neg (show ¬(false = true) by decide), hq]
    exact hx
  · rw [if_pos (show true = true from rfl), hrm]
    exact hx

/-! ### `cttz`, `ctlz` -/

/-- What `count lz` computes. -/
def countRes (lz : Bool) {n : Nat} (a : BitVec n) : Nat :=
  if lz then Ryo.Vm.OpSem.leadingZeros a else Ryo.Vm.OpSem.trailingZeros a

/-- `bsr`'s width for `ctlz`. -/
def bwOf (w : W) : W := if w == .q then .q else .d

/-- The body of the `count` sequence (`sequence`), after the load. -/
def countBody (lz : Bool) (w : W) : List Item :=
  let n := w.bits
  let bw := if w == .q then W.q else .d
  if lz then
    [.bsr bw R (.reg R), .setReg C (BitVec.ofNat 64 (2 * n - 1)), .cmov .z .d R (.reg C),
      .aluImm .xor .d (.reg R) (BitVec.ofNat 32 (n - 1))]
  else if w == .b || w == .w then
    [.aluImm .or .d (.reg R) (BitVec.ofNat 32 (2 ^ n)), .bsf .d R (.reg R)]
  else [.bsf w R (.reg R), .setReg C (BitVec.ofNat 64 n), .cmov .z .d R (.reg C)]

theorem tz_zero {n : Nat} {A : BitVec n} (h : A = 0) : Ryo.Vm.OpSem.trailingZeros A = n := by
  subst h
  unfold Ryo.Vm.OpSem.trailingZeros
  rw [List.find?_eq_none.2 (by intro i _; simp)]
  rfl

theorem find_ne_none {n : Nat} {A : BitVec n} (h : A ≠ 0) :
    (List.range n).find? (A.getLsbD ·) ≠ none := by
  intro hf
  apply h
  apply BitVec.eq_of_getLsbD_eq
  intro i hi
  have := List.find?_eq_none.1 hf i (List.mem_range.2 hi)
  simpa using this

theorem tz_lowest {n : Nat} {A : BitVec n} (h : A ≠ 0) :
    Ryo.Vm.OpSem.trailingZeros A = lowestSet A := by
  unfold Ryo.Vm.OpSem.trailingZeros lowestSet
  cases hf : (List.range n).find? (A.getLsbD ·) with
  | none => exact absurd hf (find_ne_none h)
  | some k => rfl

theorem lowestSet_lt {n : Nat} {A : BitVec n} (h : A ≠ 0) : lowestSet A < n := by
  unfold lowestSet
  cases hf : (List.range n).find? (A.getLsbD ·) with
  | none => exact absurd hf (find_ne_none h)
  | some k =>
    show k < n
    exact List.mem_range.1 (List.find?_range_eq_some.1 hf).2.1

theorem tz_le {n : Nat} (A : BitVec n) : Ryo.Vm.OpSem.trailingZeros A ≤ n := by
  unfold Ryo.Vm.OpSem.trailingZeros
  cases hf : (List.range n).find? (A.getLsbD ·) with
  | none => exact Nat.le_refl n
  | some k =>
    show k ≤ n
    exact Nat.le_of_lt (List.mem_range.1 (List.find?_range_eq_some.1 hf).2.1)

/-- `bsr` of a non-zero value: `log2`. -/
theorem highestSet_eq {m : Nat} (v : BitVec m) (h : v.toNat ≠ 0) :
    highestSet v = Nat.log2 v.toNat := by
  have hlt : Nat.log2 v.toNat < m := (Nat.log2_lt h).2 v.isLt
  have key : (List.range m).find? ((fun i => v.getLsbD i) ∘ fun j => 0 + m - 1 - j) =
      some (m - 1 - Nat.log2 v.toNat) := by
    rw [List.find?_range_eq_some]
    refine ⟨?_, List.mem_range.2 (by omega), fun j hj => ?_⟩
    · have e : 0 + m - 1 - (m - 1 - Nat.log2 v.toNat) = Nat.log2 v.toNat := by omega
      simp only [Function.comp_apply, e]
      exact Nat.testBit_log2 h
    · simp only [Function.comp_apply, Bool.not_eq_true']
      apply Nat.testBit_lt_two_pow
      calc v.toNat < 2 ^ (Nat.log2 v.toNat + 1) := Nat.lt_log2_self
        _ ≤ 2 ^ (0 + m - 1 - j) := Nat.pow_le_pow_right (by decide) (by omega)
  unfold highestSet
  rw [List.range_eq_range', List.reverse_range', List.find?_map, key]
  show 0 + m - 1 - (m - 1 - Nat.log2 v.toNat) = Nat.log2 v.toNat
  omega

/-- The 8/16-bit `cttz` source: the value with the guard bit `2 ^ n` above it. -/
def guardV {n : Nat} (A : BitVec n) : BitVec 32 :=
  ((A.setWidth 32).setWidth 64).setWidth 32 ||| (BitVec.ofNat 32 (2 ^ n)).signExtend 32

theorem guard_bits {n : Nat} (hn : n < 32) (A : BitVec n) (i : Nat) :
    (guardV A).getLsbD i = (A.getLsbD i || decide (i = n)) := by
  unfold guardV
  rw [BitVec.signExtend_eq, BitVec.setWidth_setWidth_of_le _ (by decide : 32 ≤ 64)]
  simp only [BitVec.getLsbD_or, BitVec.getLsbD_setWidth, BitVec.getLsbD_ofNat,
    Nat.testBit_two_pow]
  by_cases hi : i < n
  · have h32 : i < 32 := by omega
    have hne : ¬n = i := by omega
    have hne' : ¬i = n := by omega
    simp [h32, hne, hne']
  · rw [BitVec.getLsbD_of_ge A i (by omega)]
    by_cases h2 : i = n
    · subst h2
      simp [hn]
    · have hne : ¬n = i := fun h => h2 h.symm
      simp [h2, hne]

theorem guard_ne {n : Nat} (hn : n < 32) (A : BitVec n) : guardV A ≠ 0 := by
  intro h
  have := guard_bits hn A n
  rw [h] at this
  simp at this

/-- With the guard bit, `bsf` gives `cttz` (`n` for zero). -/
theorem lowest_guard {n : Nat} (hn : n < 32) (A : BitVec n) :
    lowestSet (guardV A) = Ryo.Vm.OpSem.trailingZeros A := by
  unfold lowestSet Ryo.Vm.OpSem.trailingZeros
  cases hk : (List.range n).find? (A.getLsbD ·) with
  | some k =>
    obtain ⟨hpk, hkm, hlt⟩ := List.find?_range_eq_some.1 hk
    have hkn : k < n := List.mem_range.1 hkm
    have hf : (List.range 32).find? ((guardV A).getLsbD ·) = some k := by
      rw [List.find?_range_eq_some]
      refine ⟨?_, List.mem_range.2 (by omega), fun j hj => ?_⟩
      · simp only [guard_bits hn A]
        try simp only at hpk
        simp [hpk]
      · simp only [guard_bits hn A]
        have := hlt j hj
        simp at this
        simp [this]
        omega
    rw [hf]
    rfl
  | none =>
    have hn' := List.find?_eq_none.1 hk
    have hf : (List.range 32).find? ((guardV A).getLsbD ·) = some n := by
      rw [List.find?_range_eq_some]
      refine ⟨?_, List.mem_range.2 hn, fun j hj => ?_⟩
      · simp only [guard_bits hn A]
        simp
      · simp only [guard_bits hn A]
        have := hn' j (List.mem_range.2 hj)
        simp at this
        simp [this]
        omega
    rw [hf]
    rfl

/-- `bsr`'s index `h` of the top set bit, `xor` with `n - 1`: `n - 1 - h`. -/
theorem xor_mask (w : W) (H : Nat) (h : H < w.bits) : H ^^^ (w.bits - 1) = w.bits - (H + 1) := by
  cases w <;> simp only [W.bits] at h ⊢ <;> revert H <;> decide

/-- `cttz` at 32 and 64 bits: `bsf`, then `cmovz` of `n`. -/
theorem body_tzW (ctx : Ctx) (x : Ryo.X86.State) (w : W) (hw : w = .d ∨ w = .q) (a : BitVec 32) :
    ∃ y, execItems ctx [.ld w false .rax (M.frame a), .bsf w .rax (.reg .rax),
        .setReg .rcx (BitVec.ofNat 64 w.bits), .cmov .z .d .rax (.reg .rcx)] x = .ok y ∧
      Facts [0, 1] x y [.ld w false .rax (M.frame a), .bsf w .rax (.reg .rax),
        .setReg .rcx (BitVec.ofNat 64 w.bits), .cmov .z .d .rax (.reg .rcx)] ∧
      (y.regW .d .rax).toNat = Ryo.Vm.OpSem.trailingZeros (x.memW w (x.ea (M.frame a))) := by
  generalize hA : x.memW w (x.ea (M.frame a)) = A
  have hK : BitVec.ofNat 64 w.bits ≠ 0 := by rcases hw with rfl | rfl <;> decide
  have hF : ¬((setForm (BitVec.ofNat 64 w.bits) == 0) = true) := by
    rw [setForm_beq _ hK]
    decide
  obtain ⟨s1, e1, f1, v1⟩ : ∃ s1, (Item.ld w false .rax (M.frame a)).exec ctx x = .ok s1 ∧
      Facts [0, 1] x s1 [Item.ld w false .rax (M.frame a)] ∧ s1.rmW w (.reg .rax) = A := by
    refine ⟨_, exec_ld ctx w false .rax (M.frame a) x, by ld_fone, ?_⟩
    rw [rmW_reg, regW_setReg_self, ldVal_dq hw, back64, hA]
  refine chain e1 f1 ?_
  by_cases h0 : A = 0
  · -- `bsf` leaves `ctx.undef`; `cmovz` takes `n`
    obtain ⟨s2, e2, f2, z2⟩ : ∃ s2, (Item.bsf w .rax (.reg .rax)).exec ctx s1 = .ok s2 ∧
        Facts [0, 1] s1 s2 [Item.bsf w .rax (.reg .rax)] ∧ s2.flags.zf = some true :=
      ⟨_, exec_bsf_z ctx w .rax (.reg .rax) s1 (v1.trans h0), by ld_fone, rfl⟩
    refine chain e2 f2 ?_
    obtain ⟨s3, e3, f3, z3, c3⟩ : ∃ s3,
        (Item.setReg .rcx (BitVec.ofNat 64 w.bits)).exec ctx s2 = .ok s3 ∧
        Facts [0, 1] s2 s3 [Item.setReg .rcx (BitVec.ofNat 64 w.bits)] ∧
        s3.flags.zf = some true ∧
        s3.rmW .d (.reg .rcx) = (BitVec.ofNat 64 w.bits).setWidth W.d.bits := by
      refine ⟨_, exec_setReg ctx .rcx _ s2, by ld_fone, ?_, ?_⟩
      · rw [X86S.flags_setFlags, if_neg hF]
        exact z2
      · rw [rmW_reg, regW_setFlags, regW_setReg_self]
    refine chain e3 f3 ?_
    obtain ⟨s4, e4, f4, v4⟩ : ∃ s4, (Item.cmov .z .d .rax (.reg .rcx)).exec ctx s3 = .ok s4 ∧
        Facts [0, 1] s3 s4 [Item.cmov .z .d .rax (.reg .rcx)] ∧
        (s4.regW .d .rax).toNat = w.bits := by
      refine ⟨_, exec_cmovz ctx .d .rax (.reg .rcx) s3 z3, by ld_fone, ?_⟩
      simp only [State.setRegW]
      rw [regW_setReg_self, back64, if_pos trivial, c3,
        BitVec.toNat_setWidth, BitVec.toNat_ofNat]
      rcases hw with rfl | rfl <;> decide
    exact chain e4 f4 (chain_nil (by rw [v4, tz_zero h0]))
  · -- `bsf` gives the count; `cmovz` keeps it
    obtain ⟨s2, e2, f2, z2, v2⟩ : ∃ s2, (Item.bsf w .rax (.reg .rax)).exec ctx s1 = .ok s2 ∧
        Facts [0, 1] s1 s2 [Item.bsf w .rax (.reg .rax)] ∧ s2.flags.zf = some false ∧
        (s2.regW .d .rax).toNat = lowestSet A := by
      refine ⟨_, exec_bsf_nz ctx w .rax (.reg .rax) s1 v1 h0, by ld_fone, rfl, ?_⟩
      rw [regW_setFlags, setRegW_dq hw, regW_setReg_self, BitVec.toNat_setWidth,
        BitVec.toNat_setWidth, BitVec.toNat_ofNat]
      have hL := lowestSet_lt h0
      generalize lowestSet A = L at hL ⊢
      rcases hw with rfl | rfl <;> simp only [W.bits] at hL ⊢ <;> omega
    refine chain e2 f2 ?_
    obtain ⟨s3, e3, f3, z3, v3⟩ : ∃ s3,
        (Item.setReg .rcx (BitVec.ofNat 64 w.bits)).exec ctx s2 = .ok s3 ∧
        Facts [0, 1] s2 s3 [Item.setReg .rcx (BitVec.ofNat 64 w.bits)] ∧
        s3.flags.zf = some false ∧ s3.regW .d .rax = s2.regW .d .rax := by
      refine ⟨_, exec_setReg ctx .rcx _ s2, by ld_fone, ?_, ?_⟩
      · rw [X86S.flags_setFlags, if_neg hF]
        exact z2
      · rw [regW_setFlags, regW_other ax_cx, regW_jump]
    refine chain e3 f3 ?_
    obtain ⟨s4, e4, f4, v4⟩ : ∃ s4, (Item.cmov .z .d .rax (.reg .rcx)).exec ctx s3 = .ok s4 ∧
        Facts [0, 1] s3 s4 [Item.cmov .z .d .rax (.reg .rcx)] ∧
        s4.regW .d .rax = s3.regW .d .rax := by
      refine ⟨_, exec_cmovz ctx .d .rax (.reg .rcx) s3 z3, by ld_fone, ?_⟩
      simp only [State.setRegW]
      rw [regW_setReg_self, back64]
      first | rw [if_neg not_false] | rw [if_neg (show ¬(false = true) by decide)]
    exact chain e4 f4 (chain_nil (by rw [v4, v3, v2, tz_lowest h0]))

/-- `cttz` at 8 and 16 bits: `or` of the guard bit, then `bsf`. -/
theorem body_tzN (ctx : Ctx) (x : Ryo.X86.State) (w : W) (hw : w = .b ∨ w = .w) (a : BitVec 32) :
    ∃ y, execItems ctx [.ld w false .rax (M.frame a),
        .aluImm .or .d (.reg .rax) (BitVec.ofNat 32 (2 ^ w.bits)), .bsf .d .rax (.reg .rax)] x =
          .ok y ∧
      Facts [0, 1] x y [.ld w false .rax (M.frame a),
        .aluImm .or .d (.reg .rax) (BitVec.ofNat 32 (2 ^ w.bits)), .bsf .d .rax (.reg .rax)] ∧
      (y.regW .d .rax).toNat = Ryo.Vm.OpSem.trailingZeros (x.memW w (x.ea (M.frame a))) := by
  generalize hA : x.memW w (x.ea (M.frame a)) = A
  have hn : w.bits < 32 := by rcases hw with rfl | rfl <;> decide
  obtain ⟨s1, e1, f1, v1⟩ : ∃ s1, (Item.ld w false .rax (M.frame a)).exec ctx x = .ok s1 ∧
      Facts [0, 1] x s1 [Item.ld w false .rax (M.frame a)] ∧
      s1.reg .rax = (A.setWidth 32).setWidth 64 := by
    refine ⟨_, exec_ld ctx w false .rax (M.frame a) x, by ld_fone, ?_⟩
    rw [X86S.reg_setReg, if_pos rfl, ldVal_bw hw, hA]
    rfl
  refine chain e1 f1 ?_
  obtain ⟨s2, e2, f2, v2⟩ : ∃ s2,
      (Item.aluImm .or .d (.reg .rax) (BitVec.ofNat 32 (2 ^ w.bits))).exec ctx s1 = .ok s2 ∧
      Facts [0, 1] s1 s2 [Item.aluImm .or .d (.reg .rax) (BitVec.ofNat 32 (2 ^ w.bits))] ∧
      s2.rmW .d (.reg .rax) = guardV A := by
    refine ⟨_, exec_orImm ctx .rax _ s1, by ld_fone, ?_⟩
    rw [rmW_reg, regW_setReg_self, v1]
    exact back64_32 (guardV A)
  refine chain e2 f2 ?_
  obtain ⟨s3, e3, f3, v3⟩ : ∃ s3, (Item.bsf .d .rax (.reg .rax)).exec ctx s2 = .ok s3 ∧
      Facts [0, 1] s2 s3 [Item.bsf .d .rax (.reg .rax)] ∧
      (s3.regW .d .rax).toNat = Ryo.Vm.OpSem.trailingZeros A := by
    refine ⟨_, exec_bsf_nz ctx .d .rax (.reg .rax) s2 v2 (guard_ne hn A), by ld_fone, ?_⟩
    have hL : lowestSet (n := W.d.bits) (guardV A) = Ryo.Vm.OpSem.trailingZeros A :=
      lowest_guard hn A
    rw [regW_setFlags]
    simp only [State.setRegW]
    rw [regW_setReg_self, back64, BitVec.toNat_ofNat, hL]
    apply Nat.mod_eq_of_lt
    have := tz_le A
    generalize Ryo.Vm.OpSem.trailingZeros A = T at this ⊢
    rcases hw with rfl | rfl <;> simp only [W.bits] at this hn ⊢ <;> omega
  exact chain e3 f3 (chain_nil v3)

/-- `ctlz`: `bsr`, `cmovz` of `2n - 1` for zero, `xor` with `n - 1`. -/
theorem body_lz (ctx : Ctx) (x : Ryo.X86.State) (w : W) (a : BitVec 32) :
    ∃ y, execItems ctx [.ld w false .rax (M.frame a), .bsr (bwOf w) .rax (.reg .rax),
        .setReg .rcx (BitVec.ofNat 64 (2 * w.bits - 1)), .cmov .z .d .rax (.reg .rcx),
        .aluImm .xor .d (.reg .rax) (BitVec.ofNat 32 (w.bits - 1))] x = .ok y ∧
      Facts [0, 1] x y [.ld w false .rax (M.frame a), .bsr (bwOf w) .rax (.reg .rax),
        .setReg .rcx (BitVec.ofNat 64 (2 * w.bits - 1)), .cmov .z .d .rax (.reg .rcx),
        .aluImm .xor .d (.reg .rax) (BitVec.ofNat 32 (w.bits - 1))] ∧
      (y.regW .d .rax).toNat = Ryo.Vm.OpSem.leadingZeros (x.memW w (x.ea (M.frame a))) := by
  generalize hA : x.memW w (x.ea (M.frame a)) = A
  have hbw : bwOf w = .d ∨ bwOf w = .q := by cases w <;> decide
  have hnb : w.bits ≤ (bwOf w).bits := by cases w <;> decide
  have hK : BitVec.ofNat 64 (2 * w.bits - 1) ≠ 0 := by cases w <;> decide
  have hF : ¬((setForm (BitVec.ofNat 64 (2 * w.bits - 1)) == 0) = true) := by
    rw [setForm_beq _ hK]
    decide
  obtain ⟨s1, e1, f1, v1⟩ : ∃ s1, (Item.ld w false .rax (M.frame a)).exec ctx x = .ok s1 ∧
      Facts [0, 1] x s1 [Item.ld w false .rax (M.frame a)] ∧
      (s1.rmW (bwOf w) (.reg .rax)).toNat = A.toNat := by
    refine ⟨_, exec_ld ctx w false .rax (M.frame a) x, by ld_fone, ?_⟩
    rw [rmW_reg, regW_setReg_self, BitVec.toNat_setWidth, ldVal_toNat, hA]
    exact Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le A.isLt (Nat.pow_le_pow_right (by decide) hnb))
  refine chain e1 f1 ?_
  by_cases h0 : A.toNat = 0
  · -- `bsr` leaves `ctx.undef`; `cmovz` takes `2n - 1`, and `(2n - 1) ^ (n - 1)` is `n`
    have hv0 : s1.rmW (bwOf w) (.reg .rax) = 0 := by
      apply BitVec.eq_of_toNat_eq
      rw [v1, h0]
      simp
    obtain ⟨s2, e2, f2, z2⟩ : ∃ s2, (Item.bsr (bwOf w) .rax (.reg .rax)).exec ctx s1 = .ok s2 ∧
        Facts [0, 1] s1 s2 [Item.bsr (bwOf w) .rax (.reg .rax)] ∧ s2.flags.zf = some true :=
      ⟨_, exec_bsr_z ctx (bwOf w) .rax (.reg .rax) s1 hv0, by ld_fone, rfl⟩
    refine chain e2 f2 ?_
    obtain ⟨s3, e3, f3, z3, c3⟩ : ∃ s3,
        (Item.setReg .rcx (BitVec.ofNat 64 (2 * w.bits - 1))).exec ctx s2 = .ok s3 ∧
        Facts [0, 1] s2 s3 [Item.setReg .rcx (BitVec.ofNat 64 (2 * w.bits - 1))] ∧
        s3.flags.zf = some true ∧
        s3.rmW .d (.reg .rcx) = (BitVec.ofNat 64 (2 * w.bits - 1)).setWidth W.d.bits := by
      refine ⟨_, exec_setReg ctx .rcx _ s2, by ld_fone, ?_, ?_⟩
      · rw [X86S.flags_setFlags, if_neg hF]
        exact z2
      · rw [rmW_reg, regW_setFlags, regW_setReg_self]
    refine chain e3 f3 ?_
    obtain ⟨s4, e4, f4, v4⟩ : ∃ s4, (Item.cmov .z .d .rax (.reg .rcx)).exec ctx s3 = .ok s4 ∧
        Facts [0, 1] s3 s4 [Item.cmov .z .d .rax (.reg .rcx)] ∧
        s4.reg .rax = ((BitVec.ofNat 64 (2 * w.bits - 1)).setWidth W.d.bits).setWidth 64 := by
      refine ⟨_, exec_cmovz ctx .d .rax (.reg .rcx) s3 z3, by ld_fone, ?_⟩
      simp only [State.setRegW]
      rw [X86S.reg_setReg, if_pos rfl, if_pos trivial, c3]
    refine chain e4 f4 ?_
    obtain ⟨s5, e5, f5, v5⟩ : ∃ s5,
        (Item.aluImm .xor .d (.reg .rax) (BitVec.ofNat 32 (w.bits - 1))).exec ctx s4 = .ok s5 ∧
        Facts [0, 1] s4 s5 [Item.aluImm .xor .d (.reg .rax) (BitVec.ofNat 32 (w.bits - 1))] ∧
        (s5.regW .d .rax).toNat = w.bits := by
      refine ⟨_, exec_xorImm ctx .rax _ s4, by ld_fone, ?_⟩
      rw [regW_setReg_self, toNat_back32, v4]
      cases w <;> decide
    exact chain e5 f5 (chain_nil (by rw [v5, Ryo.Vm.OpSem.leadingZeros, if_pos h0]))
  · -- `bsr` gives `log2`; `cmovz` keeps it; `xor` with `n - 1` is `n - 1 - log2`
    have hv0 : s1.rmW (bwOf w) (.reg .rax) ≠ 0 := by
      intro h
      apply h0
      rw [← v1, h]
      simp
    have hH : highestSet (s1.rmW (bwOf w) (.reg .rax)) = Nat.log2 A.toNat := by
      rw [highestSet_eq _ (by rw [v1]; exact h0), v1]
    have hlt : Nat.log2 A.toNat < w.bits := (Nat.log2_lt h0).2 A.isLt
    obtain ⟨s2, e2, f2, z2, v2⟩ : ∃ s2, (Item.bsr (bwOf w) .rax (.reg .rax)).exec ctx s1 = .ok s2 ∧
        Facts [0, 1] s1 s2 [Item.bsr (bwOf w) .rax (.reg .rax)] ∧ s2.flags.zf = some false ∧
        (s2.regW .d .rax).toNat = Nat.log2 A.toNat := by
      refine ⟨_, exec_bsr_nz ctx (bwOf w) .rax (.reg .rax) s1 rfl hv0, by ld_fone, rfl, ?_⟩
      rw [regW_setFlags, setRegW_dq hbw, regW_setReg_self, BitVec.toNat_setWidth,
        BitVec.toNat_setWidth, BitVec.toNat_ofNat, hH]
      have h1 : Nat.log2 A.toNat < 2 ^ (bwOf w).bits :=
        Nat.lt_of_lt_of_le hlt (by cases w <;> decide)
      have h2 : Nat.log2 A.toNat < 2 ^ 64 := Nat.lt_of_lt_of_le hlt (by cases w <;> decide)
      have h3 : Nat.log2 A.toNat < 2 ^ W.d.bits := Nat.lt_of_lt_of_le hlt (by cases w <;> decide)
      rw [Nat.mod_eq_of_lt h1, Nat.mod_eq_of_lt h2, Nat.mod_eq_of_lt h3]
    refine chain e2 f2 ?_
    obtain ⟨s3, e3, f3, z3, v3⟩ : ∃ s3,
        (Item.setReg .rcx (BitVec.ofNat 64 (2 * w.bits - 1))).exec ctx s2 = .ok s3 ∧
        Facts [0, 1] s2 s3 [Item.setReg .rcx (BitVec.ofNat 64 (2 * w.bits - 1))] ∧
        s3.flags.zf = some false ∧ s3.regW .d .rax = s2.regW .d .rax := by
      refine ⟨_, exec_setReg ctx .rcx _ s2, by ld_fone, ?_, ?_⟩
      · rw [X86S.flags_setFlags, if_neg hF]
        exact z2
      · rw [regW_setFlags, regW_other ax_cx, regW_jump]
    refine chain e3 f3 ?_
    obtain ⟨s4, e4, f4, v4⟩ : ∃ s4, (Item.cmov .z .d .rax (.reg .rcx)).exec ctx s3 = .ok s4 ∧
        Facts [0, 1] s3 s4 [Item.cmov .z .d .rax (.reg .rcx)] ∧
        s4.reg .rax = (s3.regW .d .rax).setWidth 64 := by
      refine ⟨_, exec_cmovz ctx .d .rax (.reg .rcx) s3 z3, by ld_fone, ?_⟩
      simp only [State.setRegW]
      rw [X86S.reg_setReg, if_pos rfl]
      first | rw [if_neg not_false] | rw [if_neg (show ¬(false = true) by decide)]
    refine chain e4 f4 ?_
    obtain ⟨s5, e5, f5, v5⟩ : ∃ s5,
        (Item.aluImm .xor .d (.reg .rax) (BitVec.ofNat 32 (w.bits - 1))).exec ctx s4 = .ok s5 ∧
        Facts [0, 1] s4 s5 [Item.aluImm .xor .d (.reg .rax) (BitVec.ofNat 32 (w.bits - 1))] ∧
        (s5.regW .d .rax).toNat = Nat.log2 A.toNat ^^^ (w.bits - 1) := by
      refine ⟨_, exec_xorImm ctx .rax _ s4, by ld_fone, ?_⟩
      have h4 : Nat.log2 A.toNat < 2 ^ 32 := Nat.lt_of_lt_of_le hlt (by cases w <;> decide)
      have h5 : w.bits - 1 < 2 ^ 32 := by cases w <;> decide
      rw [regW_setReg_self, toNat_back32, BitVec.toNat_xor, v4, BitVec.signExtend_eq,
        BitVec.toNat_ofNat, BitVec.setWidth_setWidth_of_le _ (show 32 ≤ 64 by decide),
        BitVec.toNat_setWidth, v3, v2, Nat.mod_eq_of_lt h4, Nat.mod_eq_of_lt h5]
    exact chain e5 f5 (chain_nil (by
      rw [v5, Ryo.Vm.OpSem.leadingZeros, if_neg h0, xor_mask w _ hlt]))

theorem body_count (ctx : Ctx) (x : Ryo.X86.State) (lz : Bool) (w : W) (a : BitVec 32) :
    ∃ y, execItems ctx ([.ld w false .rax (M.frame a)] ++ countBody lz w) x = .ok y ∧
      Facts [0, 1] x y ([.ld w false .rax (M.frame a)] ++ countBody lz w) ∧
      (y.regW .d .rax).toNat = countRes lz (x.memW w (x.ea (M.frame a))) := by
  cases lz
  · cases w
    · exact body_tzN ctx x .b (Or.inl rfl) a
    · exact body_tzN ctx x .w (Or.inr rfl) a
    · exact body_tzW ctx x .d (Or.inl rfl) a
    · exact body_tzW ctx x .q (Or.inr rfl) a
  · exact body_lz ctx x w a

/-- The whole `count` sequence, from the operand's facts `opSem` gives. -/
theorem fin_count (lz : Bool) (w : W) {ctx : Ctx} {op : Full.Opcode} {ops : List (R.Opnd Nat)}
    {vals : Operands} {st st' : OpSem.State} {x : Ryo.X86.State} {s0 s1 : BitVec 32}
    {bs : List AbstractByte} (hr : Rel st x) (hw : st.writeFrame s0.toInt bs = .ok st')
    (hlen : bs.length = W.d.bits / 8) (hwr : wranges op vals = [(s0.toInt, W.d.bits / 8)])
    (hx : BytesRel bs (leEncode (W.d.bits / 8) (countRes lz (x.memW w (x.ea (M.frame s1)))))) :
    ∃ x', execItems ctx (([.ld w false .rax (M.frame s1)] ++ countBody lz w) ++
        [.st .d .rax (M.frame s0)]) x = .ok x' ∧
      PostX [0, 1] op ops vals (([.ld w false .rax (M.frame s1)] ++ countBody lz w) ++
        [.st .d .rax (M.frame s0)]) none st st' .next x x' := by
  obtain ⟨y, hy, hf, hv⟩ := body_count ctx x lz w s1
  refine end_store (by decide) hr hw hlen hwr hy hf ?_
  rw [hv]
  exact hx

/-! ### `opSem` of `bin_fn` and `count` -/

theorem fp_binFn {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .bin_fn (ty :: ps) =
      some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" n] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h]
  rfl

theorem opSem_binFn {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat} {sg : Bool}
    {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.bin_fn, [ty, m], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hsem : opSem op [.slot d, .slot a, .slot b] st ch = .ok (c, st')) :
    ∃ ba bb va vb res, st.readFrame a n = .ok ba ∧ st.readFrame b n = .ok bb ∧
      asNat ba = .ok va ∧ asNat bb = .ok vb ∧
      intBin m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res ∧
      st.writeFrame d (intBytes n res.toNat) = .ok st' ∧ c = .next := by
  oinv hsem, hh, fp_binFn (ps := [m]) (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨ba, hra', bb, hrb, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, vb, hvb, res, hres, rfl⟩ := hk
  exact ⟨ba, bb, va, vb, res, hra', hrb, hva, hvb, hres,
    (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

theorem fp_count {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .count (ty :: ps) =
      some { reads := [rdA "a" n], writes := [rdA "d" 4] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h]
  rfl

theorem opSem_count {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat} {sg : Bool}
    {d a : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.count, [ty, m], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩])
    (hsem : opSem op [.slot d, .slot a] st ch = .ok (c, st')) :
    ∃ ba va k, st.readFrame a n = .ok ba ∧ asNat ba = .ok va ∧
      intCount m (BitVec.ofNat (8 * n) va) = .ok k ∧
      st.writeFrame d (intBytes 4 k) = .ok st' ∧ c = .next := by
  oinv hsem, hh, fp_count (ps := [m]) (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨ba, hra', rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, k, hk', rfl⟩ := hk
  exact ⟨ba, va, k, hra', hva, hk', (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

theorem intCount_ok (lz : Bool) {n : Nat} (a : BitVec n) {k : Nat}
    (h : intCount (if lz then "leading_zeros" else "trailing_zeros") a = .ok k) :
    k = countRes lz a := by
  cases lz
  · have e : intCount "trailing_zeros" a = .ok (Ryo.Vm.OpSem.trailingZeros a) := by
      simp [intCount, pure, Except.pure]
    rw [if_neg (show ¬(false = true) by decide), e] at h
    exact (Except.ok.inj h).symm
  · have e : intCount "leading_zeros" a = .ok (Ryo.Vm.OpSem.leadingZeros a) := by
      simp [intCount, pure, Except.pure]
    rw [if_pos (show true = true from rfl), e] at h
    exact (Except.ok.inj h).symm

end Ld

open Ld

/-! ### The theorems -/

set_option maxHeartbeats 1000000 in
/-- `div`/`rem` (`div sg rem w`): where `opSem` succeeds (no zero divisor, no `MIN / -1`), the
sequence computes its result; it changes `rax`, `rcx` (8/16 bits) and `rdx`. -/
theorem sound_div (sg rem : Bool) (w : W) : SoundX [0, 1, 2] (.div sg rem w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  have hty : Ty.parse (tyName sg w) = some (.int (wbytes w) sg) := by
    cases sg
    · exact (tyName_parse w).1
    · exact (tyName_parse w).2
  obtain ⟨ba, bb, va, vb, res, hra, hrb, hva, hvb, hres, hwr, rfl⟩ :=
    opSem_binFn hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .slot s2.toInt])
    (d := s0.toInt) hh (fp_binFn (tySize_of_parse hty)) (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  have hb := read_int hr (by omega) hrb hvb
  subst ha hb
  obtain ⟨hb0, hov, rfl⟩ := intBin_div_ok sg rem _ _ _ hres
  have hlen : ∀ v, (intBytes (wbytes w) v).length = wbytes w := by
    intro v; simp [intBytes, Theorems.encodeBits_length]
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  cases w
  · refine fin_div sg rem .b hr hwr ?_ ?_ ?_ ?_ ?_ <;>
    first
    | (rw [hlen]; rfl)
    | (rw [hwr']; rfl)
    | (rw [memW_frame]; exact hb0)
    | (intro hs; rw [memW_frame, memW_frame]; exact hov hs)
    | (apply bytesRel_int; rw [memW_frame, memW_frame]; rfl)
  · refine fin_div sg rem .w hr hwr ?_ ?_ ?_ ?_ ?_ <;>
    first
    | (rw [hlen]; rfl)
    | (rw [hwr']; rfl)
    | (rw [memW_frame]; exact hb0)
    | (intro hs; rw [memW_frame, memW_frame]; exact hov hs)
    | (apply bytesRel_int; rw [memW_frame, memW_frame]; rfl)
  · refine fin_div sg rem .d hr hwr ?_ ?_ ?_ ?_ ?_ <;>
    first
    | (rw [hlen]; rfl)
    | (rw [hwr']; rfl)
    | (rw [memW_frame]; exact hb0)
    | (intro hs; rw [memW_frame, memW_frame]; exact hov hs)
    | (apply bytesRel_int; rw [memW_frame, memW_frame]; rfl)
  · refine fin_div sg rem .q hr hwr ?_ ?_ ?_ ?_ ?_ <;>
    first
    | (rw [hlen]; rfl)
    | (rw [hwr']; rfl)
    | (rw [memW_frame]; exact hb0)
    | (intro hs; rw [memW_frame, memW_frame]; exact hov hs)
    | (apply bytesRel_int; rw [memW_frame, memW_frame]; rfl)

/-- `cttz`/`ctlz` (`count lz w`): the count, stored as a `u32`; only `rax`, `rcx` and the flags
change. -/
theorem sound_count (lz : Bool) (w : W) : Sound (.count lz w) := by
  refine SoundX.sound ?_
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  have hty := (tyName_parse w).1
  obtain ⟨ba, va, k, hra, hva, hk, hwr, rfl⟩ := opSem_count hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt]) (d := s0.toInt)
    hh (fp_count (tySize_of_parse hty)) (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  subst ha
  have hk' := intCount_ok lz _ hk
  subst hk'
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  cases w
  all_goals
    refine fin_count lz _ hr hwr ?_ ?_ ?_
    · simp [intBytes, Theorems.encodeBits_length, W.bits]
    · rw [hwr']; rfl
    · apply bytesRel_int
      rw [memW_frame]
      rfl

end Ryo.Proofs.Inline
