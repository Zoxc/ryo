/-
Ryo.Proofs.Inline.Ovf — the overflowing operations (`add.ovf`/`sub.ovf`, class `ovf`, and
`mul.ovf`, class `mulOvf`) against `opSem`, under two side conditions (`SoundD`):

- the two written ranges (the result `d`, the flag byte `o`) are disjoint: the sequence stores
  the flag before the result, `opSem` commits `d` then `o`;
- unsigned 64-bit `mul.ovf` (`mul`, `rdx:rax`) also clobbers `rdx` (`clobbers`), as the
  register cache knows (`Cache.update` drops `rdx`'s entry after a `mul`).

In the module chain after `Ext` (see `Ryo/Proofs/Inline/Arith.lean`).
-/
import Ryo.Proofs.Inline.Ext

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm

/-! ### The statement -/

/-- The registers a class's sequence may change: `rax`, `rcx`, and `rdx` for unsigned 64-bit
`mul.ovf` (`mul`). -/
def clobbers : Class → List (Fin 16)
  | .mulOvf false .q => [0, 1, 2]
  | _ => [0, 1]

/-- Pairwise disjoint frame ranges. -/
def RangesDisjoint (rs : List (Int × Nat)) : Prop :=
  rs.Pairwise fun r s => r.1 + (r.2 : Int) ≤ s.1 ∨ s.1 + (s.2 : Int) ≤ r.1

/-- `Post`, with the registers outside `clobbers c` unchanged. -/
structure PostC (c : Class) (op : Full.Opcode) (ops : List (R.Opnd Nat)) (vals : Operands)
    (items : List Item) (br : Option Cond) (st st' : OpSem.State) (ctl : Control)
    (x x' : Ryo.X86.State) : Prop where
  rel : Rel st' x'
  same : SameButWrites st' st
  regs : ∀ i : Fin 16, i ∉ clobbers c → x'.regs i = x.regs i
  xmm : x'.xmm = x.xmm
  rip : x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum
  memOut : ∀ a, (∀ r ∈ wranges op vals, r.2 ≤ (a - fpAddr x r.1).toNat) → x'.mem a = x.mem a
  ctl : match br with
    | none => ctl = .next
    | some cond => ∃ b, ctl = .branch b ∧
      ∀ neg t, R.nativeCtl op ops = some (.branch neg t) → cond.eval x'.flags = .ok (b != neg)

theorem clobbers_01 (c : Class) : (0 : Fin 16) ∈ clobbers c ∧ (1 : Fin 16) ∈ clobbers c := by
  unfold clobbers; split <;> decide

theorem Post.toC {c : Class} {op : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {items : List Item} {br : Option Cond} {st st' : OpSem.State} {ctl : Control}
    {x x' : Ryo.X86.State} (h : Post op ops vals items br st st' ctl x x') :
    PostC c op ops vals items br st st' ctl x x' :=
  ⟨h.rel, h.same, fun i hi => h.regs i (fun h0 => hi (h0 ▸ (clobbers_01 c).1))
    (fun h1 => hi (h1 ▸ (clobbers_01 c).2)), h.xmm, h.rip, h.memOut, h.ctl⟩

/-- `Sound c` given disjoint write ranges, with `clobbers c` (see the module comment). -/
def SoundD (c : Class) : Prop :=
  ∀ (ctx : Ctx) (ρ : R.Addrs) (op : Full.Opcode) (ops : List (R.Opnd Nat)) (items : List Item)
    (br : Option Cond) (vals : Operands) (st st' : OpSem.State) (ctl : Control)
    (ch : OpSem.Choice) (x : Ryo.X86.State),
    shapeOk op c = true → sequence c ops = some (items, br) → nativeVals ρ op ops = some vals →
    opSem op vals st ch = .ok (ctl, st') → Rel st x →
    RangesDisjoint (wranges op vals) →
    ∃ x', execItems ctx items x = .ok x' ∧ PostC c op ops vals items br st st' ctl x x'

theorem Sound.soundD {c : Class} (h : Sound c) : SoundD c := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr _
  obtain ⟨x', hx, hpost⟩ := h ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  exact ⟨x', hx, hpost.toC⟩

/-! ### `opSem` of `ovf` -/

theorem fp_ovf {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .ovf (ty :: ps) =
      some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" n, rdA "o" 1] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h]
  rfl

/-- `ovf` at `n` bytes: both operands as integers, the method's result and flag, written in
that order. -/
theorem opSem_ovf {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat} {sg : Bool}
    {d o a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.ovf, [ty, m], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"o", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hsem : opSem op [.slot d, .slot o, .slot a, .slot b] st ch = .ok (c, st')) :
    ∃ ba bb va vb res ov st1, st.readFrame a n = .ok ba ∧ st.readFrame b n = .ok bb ∧
      asNat ba = .ok va ∧ asNat bb = .ok vb ∧
      intOvf m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok (res, ov) ∧
      st.writeFrame d (intBytes n res.toNat) = .ok st1 ∧
      st1.writeFrame o (boolByte ov) = .ok st' ∧ c = .next := by
  oinv hsem, hh, fp_ovf (ps := [m]) (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨ba, hra', bb, hrb, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, vb, hvb, ⟨res, ov⟩, hres, rfl⟩ := hk
  osimp [ho] at hc
  obtain ⟨st1, h1, h2⟩ := hc
  have hl1 : (intBytes n res.toNat).length = n := by simp [intBytes, Theorems.encodeBits_length]
  have hl2 : (boolByte ov).length = 1 := rfl
  simp only [hl1, hl2, ↓reduceIte] at h1 h2
  exact ⟨ba, bb, va, vb, res, ov, st1, hra', hrb, hva, hvb, hres, h1, h2, rfl⟩

theorem wranges_ovf {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat} {sg : Bool}
    {d o a b : Int} (hh : op.handler? = some ⟨.ovf, [ty, m], r⟩)
    (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"o", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩]) :
    wranges op [.slot d, .slot o, .slot a, .slot b] = [(d, n), (o, 1)] := by
  unfold wranges
  rw [footprint_eq hh, fp_ovf (tySize_of_parse hty)]
  simp [Footprint.writeRanges, Access.range, opndVal, ho, Val.slotOff, Extent.eval]

/-! ### Two frame stores -/

theorem write_shadow (m : X86.Mem) (a b c : BitVec 64) (n k v u : Nat) (h : k ≤ (c - b).toNat) :
    (m.write b k u).write a n v c = m.write a n v c := by
  simp only [X86.Mem.write]
  split
  · rfl
  · split
    · omega
    · rfl

/-- The end of an overflow sequence: the flag byte `F` stored at `o`, then the `n` bytes of `V`
at `d`, from a state `y` that only changed the registers of `clobbers c`, the flags and `rip`;
`opSem` wrote `d`, then `o`, and the two ranges are disjoint. -/
theorem post_mem2 {c : Class} {op : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {items : List Item} {st st1 st' : OpSem.State} {ctl : Control} {x y : Ryo.X86.State}
    {n V F : Nat} {d o : BitVec 32} {bs fs : List AbstractByte} {a1 a2 : BitVec 64}
    (hr : Rel st x) (hw1 : st.writeFrame d.toInt bs = .ok st1)
    (hw2 : st1.writeFrame o.toInt fs = .ok st') (hlen : bs.length = n) (hn : n ≤ 16)
    (hfl : fs.length = 1)
    (hwr : wranges op vals = [(d.toInt, n), (o.toInt, 1)])
    (hdj : RangesDisjoint (wranges op vals))
    (hx : BytesRel bs (leEncode n V)) (hf : BytesRel fs (leEncode 1 F))
    (hyb : y.reg .rbp = x.reg .rbp) (hym : y.mem = x.mem)
    (hyr : ∀ i : Fin 16, i ∉ clobbers c → y.regs i = x.regs i) (hyx : y.xmm = x.xmm)
    (hrip : a2 = x.rip + BitVec.ofNat 64 (items.map Item.size).sum) (hctl : ctl = .next) :
    PostC c op ops vals items none st st' ctl x
      ((((y.jump a1).setMem ((y.jump a1).ea (M.frame o)) 1 F).jump a2).setMem
        ((((y.jump a1).setMem ((y.jump a1).ea (M.frame o)) 1 F).jump a2).ea (M.frame d)) n V) := by
  have hb := toInt_bounds d
  have hbo := toInt_bounds o
  rw [hwr] at hdj
  have hdj' : d.toInt + n ≤ o.toInt ∨ o.toInt + 1 ≤ d.toInt := by
    simpa [RangesDisjoint] using hdj
  have hm : ((((y.jump a1).setMem ((y.jump a1).ea (M.frame o)) 1 F).jump a2).setMem
        ((((y.jump a1).setMem ((y.jump a1).ea (M.frame o)) 1 F).jump a2).ea (M.frame d)) n V).mem =
      (x.mem.write (fpAddr x o.toInt) 1 F).write (fpAddr x d.toInt) n V := by
    simp only [X86S.mem_setMem, X86S.mem_jump, hym, ea_frame]
    simp [fpAddr, hyb]
  -- The intermediate state: only the result written.
  let xm : Ryo.X86.State := { x with mem := x.mem.write (fpAddr x d.toInt) n V }
  obtain ⟨hrel1, e1, e2, e3, e4, e5⟩ := rel_store (x' := xm) hr hw1 (by omega) (by omega)
    (by rw [hlen]; exact hx) rfl (by rw [hlen])
  have hfpm : ∀ q, fpAddr xm q = fpAddr x q := fun _ => rfl
  have hod : n ≤ (fpAddr x o.toInt - fpAddr x d.toInt).toNat :=
    fpAddr_sub_ge x _ _ n (by omega) (by omega) (by omega) (by omega)
  have hl1 : (leEncode 1 F).length = 1 := by simp [leEncode_length]
  obtain ⟨hrel, f1, f2, f3, f4, f5⟩ := rel_writeFrame hrel1 hw2 (by omega) (by omega) hf
    (x' := (((y.jump a1).setMem ((y.jump a1).ea (M.frame o)) 1 F).jump a2).setMem
        ((((y.jump a1).setMem ((y.jump a1).ea (M.frame o)) 1 F).jump a2).ea (M.frame d)) n V)
    (by simp only [X86S.reg_setMem, X86S.reg_jump]; exact hyb)
    (fun i hi => by
      rw [hl1] at hi
      obtain rfl : i = 0 := by omega
      rw [hm, hfpm, X86.Mem.write_other _ _ _ _ _ (by simpa using hod)]
      exact write_at _ _ _ _ _ (by decide) (by decide))
    (fun a ha => by
      rw [hm]
      rw [hl1, hfpm] at ha
      exact write_shadow _ _ _ _ _ _ _ _ ha)
  refine ⟨hrel, ⟨f2.trans e2, e1.trans (f1.of_escaped e2), f3.trans e3, f4.trans e4, f5.trans e5⟩,
    fun i hi => ?_, ?_, ?_, fun a' ha => ?_, hctl⟩
  · simpa using hyr i hi
  · simpa using hyx
  · simpa using hrip
  · rw [hm, X86.Mem.write_other _ _ _ _ _ (ha (d.toInt, n) (by simp [hwr])),
      X86.Mem.write_other _ _ _ _ _ (ha (o.toInt, 1) (by simp [hwr]))]

theorem c128 : (255 : BitVec 32) / 2 + 1 = 128 := by decide
theorem c32768 : (65535 : BitVec 32) / 2 + 1 = 32768 := by decide
theorem wb_beq : (W.b == W.b) = true ∧ (W.w == W.b) = false := ⟨rfl, rfl⟩

theorem setForm_ff : setForm 0xffff_ffff = 1 := by decide

theorem flags_setRegW (s : Ryo.X86.State) (w : W) (r : Reg) (v : BitVec w.bits) :
    (s.setRegW w r v).flags = s.flags := by
  cases w <;> rfl

/-! ### The results and flags of `intOvf` -/

theorem res_add (sg : Bool) {n : Nat} (a b : BitVec n) :
    BitVec.ofInt n (BitVec.val sg a + BitVec.val sg b) = a + b := by
  cases sg <;> simp [BitVec.val, BitVec.ofInt_add]

theorem res_sub (sg : Bool) {n : Nat} (a b : BitVec n) :
    BitVec.ofInt n (BitVec.val sg a - BitVec.val sg b) = a - b := by
  cases sg <;> simp [BitVec.val, Int.sub_eq_add_neg, BitVec.ofInt_add, BitVec.ofInt_neg, BitVec.sub_eq_add_neg]

theorem res_mul (sg : Bool) {n : Nat} (a b : BitVec n) :
    BitVec.ofInt n (BitVec.val sg a * BitVec.val sg b) = a * b := by
  cases sg <;> simp [BitVec.val, BitVec.ofInt_mul]

theorem res_add_u {n : Nat} (a b : BitVec n) :
    BitVec.ofInt n ((a.toNat : Int) + b.toNat) = a + b := res_add false a b
theorem res_add_s {n : Nat} (a b : BitVec n) : BitVec.ofInt n (a.toInt + b.toInt) = a + b :=
  res_add true a b
theorem res_sub_u {n : Nat} (a b : BitVec n) :
    BitVec.ofInt n ((a.toNat : Int) - b.toNat) = a - b := res_sub false a b
theorem res_sub_s {n : Nat} (a b : BitVec n) : BitVec.ofInt n (a.toInt - b.toInt) = a - b :=
  res_sub true a b

/-- The signed flag: the exact value out of range. -/
theorem flag_s {n : Nat} (hn : 0 < n) (E : Int) :
    ((BitVec.ofInt n E).toInt != E) = (decide (E ≥ 2 ^ (n - 1)) || decide (E < -2 ^ (n - 1))) := by
  rw [BitVec.toInt_ofInt]
  have h2 : 2 ^ n = 2 * 2 ^ (n - 1) := by
    rw [← Nat.pow_succ']; congr 1; omega
  have hp : 0 < 2 ^ (n - 1) := Nat.two_pow_pos _
  have l1 := Int.le_bmod (x := E) (m := 2 ^ n) (by omega)
  have l2 := Int.bmod_lt (x := E) (m := 2 ^ n) (by omega)
  have e1 : ((2 ^ n : Nat) : Int) / 2 = ((2 ^ (n - 1) : Nat) : Int) := by rw [h2]; omega
  have e2 : (((2 ^ n : Nat) : Int) + 1) / 2 = ((2 ^ (n - 1) : Nat) : Int) := by rw [h2]; omega
  have e3 : ((2 : Int) ^ (n - 1)) = ((2 ^ (n - 1) : Nat) : Int) := by push_cast; rfl
  rw [e1] at l1; rw [e2] at l2
  rw [e3]
  by_cases h : -((2 ^ (n - 1) : Nat) : Int) ≤ E ∧ E < ((2 ^ (n - 1) : Nat) : Int)
  · rw [Int.bmod_eq_of_le (by rw [e1]; exact h.1) (by rw [e2]; exact h.2)]
    rw [bne_self_eq_false]
    apply Eq.symm
    simp only [Bool.or_eq_false_iff, decide_eq_false_iff_not]
    omega
  · have : E.bmod (2 ^ n) ≠ E := fun h' => h ⟨h' ▸ l1, h' ▸ l2⟩
    rw [bne_iff_ne.2 this]
    apply Eq.symm
    simp only [Bool.or_eq_true, decide_eq_true_eq]
    omega

theorem flag_u {n : Nat} (E : Int) :
    (((BitVec.ofInt n E).toNat : Int) != E) = !(decide (0 ≤ E) && decide (E < 2 ^ n)) := by
  rw [BitVec.toNat_ofInt]
  have e : ((2 ^ n : Nat) : Int) = (2 : Int) ^ n := by push_cast; rfl
  rw [e]
  generalize hM : (2 : Int) ^ n = M
  have hp : 0 < M := hM ▸ Int.pow_pos (by decide)
  have h0 : 0 ≤ E % M := Int.emod_nonneg _ (by omega)
  have h1 : E % M < M := Int.emod_lt_of_pos _ hp
  have h2 : ((E % M).toNat : Int) = E % M := Int.toNat_of_nonneg h0
  rw [h2]
  by_cases h : 0 ≤ E ∧ E < M
  · rw [Int.emod_eq_of_lt h.1 h.2, bne_self_eq_false]
    simp [h.1, h.2]
  · have : E % M ≠ E := fun h' => h ⟨h' ▸ h0, h' ▸ h1⟩
    rw [bne_iff_ne.2 this]
    apply Eq.symm
    simp only [Bool.not_eq_true', Bool.and_eq_false_iff, decide_eq_false_iff_not]
    omega

theorem ov_add_u {n : Nat} (a b : BitVec n) :
    (((BitVec.ofInt n ((a.toNat : Int) + b.toNat)).toNat : Int) != (a.toNat : Int) + b.toNat) =
      decide (a.toNat + b.toNat ≥ 2 ^ n) := by
  rw [flag_u]
  have := a.isLt; have := b.isLt
  have e : ((2 ^ n : Nat) : Int) = (2 : Int) ^ n := by push_cast; rfl
  simp only [Bool.not_and, ← e]
  by_cases h : a.toNat + b.toNat ≥ 2 ^ n <;> simp [h] <;> omega

theorem ov_sub_u {n : Nat} (a b : BitVec n) :
    (((BitVec.ofInt n ((a.toNat : Int) - b.toNat)).toNat : Int) != (a.toNat : Int) - b.toNat) =
      a.ult b := by
  rw [flag_u, BitVec.ult]
  have := a.isLt; have := b.isLt
  have e : ((2 ^ n : Nat) : Int) = (2 : Int) ^ n := by push_cast; rfl
  simp only [Bool.not_and, ← e]
  by_cases h : a.toNat < b.toNat <;> simp [h] <;> omega

theorem ov_add_s {n : Nat} (hn : 0 < n) (a b : BitVec n) :
    ((BitVec.ofInt n (a.toInt + b.toInt)).toInt != a.toInt + b.toInt) =
      (a.msb == b.msb && (a + b).msb != a.msb) := by
  rw [flag_s hn, ← BitVec.saddOverflow, BitVec.saddOverflow_eq]
  rfl

theorem ov_sub_s {n : Nat} (hn : 0 < n) (a b : BitVec n) :
    ((BitVec.ofInt n (a.toInt - b.toInt)).toInt != a.toInt - b.toInt) =
      (a.msb != b.msb && (a - b).msb != a.msb) := by
  rw [flag_s hn, ← BitVec.ssubOverflow, BitVec.ssubOverflow_eq]
  cases a.msb <;> cases b.msb <;> cases (a - b).msb <;> rfl

theorem ov_mul_s {n : Nat} (hn : 0 < n) (a b : BitVec n) :
    ((BitVec.ofInt n (a.toInt * b.toInt)).toInt != a.toInt * b.toInt) = a.smulOverflow b := by
  rw [flag_s hn]; rfl

theorem ov_mul_u {n : Nat} (a b : BitVec n) :
    (((BitVec.ofInt n ((a.toNat : Int) * b.toNat)).toNat : Int) != (a.toNat : Int) * b.toNat) =
      a.umulOverflow b := by
  rw [flag_u, BitVec.umulOverflow]
  have := a.isLt; have := b.isLt
  have e : ((2 ^ n : Nat) : Int) = (2 : Int) ^ n := by push_cast; rfl
  have h0 : (0 : Int) ≤ (a.toNat : Int) * b.toNat := Int.mul_nonneg (by omega) (by omega)
  simp only [Bool.not_and, ← e]
  by_cases h : a.toNat * b.toNat ≥ 2 ^ n <;> simp [h] <;> omega

theorem res_mul_s {n : Nat} (a b : BitVec n) : BitVec.ofInt n (a.toInt * b.toInt) = a * b :=
  res_mul true a b

/-- `imul`'s result and flags, as bit-vector operations. -/
theorem imulF_eq {n : Nat} (hn : 0 < n) (a b : BitVec n) :
    imulF a b =
      (a * b, { cf := some (a.smulOverflow b), of := some (a.smulOverflow b), zf := none, sf := none }) := by
  simp only [imulF]
  rw [ov_mul_s hn, res_mul_s]

theorem imulF_eqW (w : W) (a b : BitVec w.bits) :
    imulF a b =
      (a * b, { cf := some (a.smulOverflow b), of := some (a.smulOverflow b), zf := none, sf := none }) :=
  imulF_eq (by cases w <;> decide) a b

theorem intOvf_eq (m : String) (sg : Bool) {n : Nat} (a b : BitVec n) {E : Int}
    (hE : m = "overflowing_add" ∧ E = BitVec.val sg a + BitVec.val sg b ∨
      m = "overflowing_sub" ∧ E = BitVec.val sg a - BitVec.val sg b ∨
      m = "overflowing_mul" ∧ E = BitVec.val sg a * BitVec.val sg b) :
    intOvf m sg a b = .ok (BitVec.ofInt n E, BitVec.val sg (BitVec.ofInt n E) != E) := by
  rcases hE with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> rfl

theorem bytesRel_flag {ov : Bool} {v : Nat} (h : v % 256 = if ov then 1 else 0) :
    BytesRel (boolByte ov) (leEncode 1 v) := by
  rw [← Theorems.leEncode_mod]
  have : v % 2 ^ (8 * 1) = if ov then 1 else 0 := h
  rw [this]
  exact bytesRel_bool rfl

/-- `xrun`, also evaluating the flag conditions of `add` and `imul`. -/
macro "xrun'" : tactic =>
  `(tactic| (simp only [execItems_cons, execItems_nil, ld, Asm.st, R, C, Mrax, exec_setReg,
               exec_shift]
             simp only [Item.exec, ex_bind_ok', pure, Except.pure, Except.ok.injEq,
               exists_eq_left', State.setMemW, Cond.eval, need, aluF, subF_eq, logicFlags, addF,
               imulF_eqW, Functor.map, Except.map, X86S.flags_jump,
               X86S.flags_setFlags, X86S.flags_setReg, X86S.flags_setMem, flags_setRegW, setForm_ff]))

theorem flag_ite (c : Prop) [Decidable c] :
    (if c then 1#8 else 0#8).toNat % 256 = if c then 1 else 0 := by
  split <;> rfl

theorem flag_iff {P Q : Prop} [Decidable P] [Decidable Q] (h : P ↔ Q) :
    (if P then 1#8 else 0#8).toNat % 256 = if Q then 1 else 0 := by
  by_cases hp : P
  · simp [hp, h.1 hp]
  · have hq : ¬Q := fun hq => hp (h.2 hq)
    simp [hp, hq]

theorem idx_rdx : Reg.idx .rdx = 2 := rfl

/-- The zero-extended product at a width that holds it, truncated back. -/
theorem res_zext {m k : Nat} (h : m ≤ k) (a b : BitVec m) :
    (a.setWidth k * b.setWidth k).setWidth m = a * b := by
  rw [BitVec.setWidth_mul _ _ h]
  simp [BitVec.setWidth_setWidth_of_le _ h]

theorem setWidth_sext {m k : Nat} (h : m ≤ k) (a : BitVec m) : (a.signExtend k).setWidth m = a := by
  ext i hi
  simp [BitVec.getElem_setWidth, BitVec.getLsbD_signExtend, hi]
  omega
theorem res_sext {m k : Nat} (h : m ≤ k) (a b : BitVec m) :
    (a.signExtend k * b.signExtend k).setWidth m = a * b := by
  rw [BitVec.setWidth_mul _ _ h, setWidth_sext h, setWidth_sext h]

/-- The unsigned check of a zero-extended product against `2 ^ m - 1`: `cmp`, then `above`. -/
theorem umul_flag {m k : Nat} (hk : 2 * m ≤ k) (a b : BitVec m) (M : BitVec k)
    (hM : M.toNat + 1 = 2 ^ m) :
    ((a.setWidth k * b.setWidth k).ult M = false ∧
      ¬a.setWidth k * b.setWidth k - M = 0#k) ↔ a.umulOverflow b = true := by
  have ha := a.isLt; have hb := b.isLt
  have hab : a.toNat * b.toNat < 2 ^ k :=
    calc a.toNat * b.toNat < 2 ^ m * 2 ^ m := Nat.mul_lt_mul_of_lt_of_lt ha hb
      _ = 2 ^ (2 * m) := by rw [← Nat.pow_add]; congr 1; omega
      _ ≤ 2 ^ k := Nat.pow_le_pow_right (by decide) hk
  have hX : (a.setWidth k * b.setWidth k).toNat = a.toNat * b.toNat := by
    rw [BitVec.toNat_mul, BitVec.toNat_setWidth, BitVec.toNat_setWidth,
      Nat.mod_eq_of_lt (by omega : a.toNat < 2 ^ k), Nat.mod_eq_of_lt (by omega : b.toNat < 2 ^ k),
      Nat.mod_eq_of_lt hab]
  have hsub : (a.setWidth k * b.setWidth k - M == 0#k) = decide (a.toNat * b.toNat = M.toNat) := by
    rw [← hX]
    by_cases h : a.setWidth k * b.setWidth k = M
    · rw [h]; simp
    · have : a.setWidth k * b.setWidth k - M ≠ 0#k := fun h' => h (by have := congrArg (· + M) h'; simpa [BitVec.sub_add_cancel] using this)
      rw [beq_eq_false_iff_ne.2 this]
      exact (decide_eq_false (fun h' => h (BitVec.eq_of_toNat_eq h'))).symm
  rw [show (¬a.setWidth k * b.setWidth k - M = 0#k) ↔
      ((a.setWidth k * b.setWidth k - M == 0#k) = false) by simp, hsub, BitVec.ult, hX,
    BitVec.umulOverflow]
  simp only [decide_eq_false_iff_not, decide_eq_true_eq]
  omega

theorem umul_flag' {m k : Nat} (hk : 2 * m ≤ k) (a b : BitVec m) (M : BitVec k)
    (hM : M.toNat + 1 = 2 ^ m) :
    ((a.setWidth k * b.setWidth k).ult M = false ∧
      (a.setWidth k * b.setWidth k - M == 0#k) = false) ↔ a.umulOverflow b = true := by
  rw [← umul_flag hk a b M hM]
  simp

/-- Closes the goals `xobs` leaves: the stored values, the flag byte, the registers. -/
macro "ovf_close" : tactic =>
  `(tactic| first
    | with_reducible rfl
    | exact flag_ite _
    | (intro i hi
       have h0 : i ≠ 0 := fun h => hi (h ▸ (clobbers_01 _).1)
       have h1 : i ≠ 1 := fun h => hi (h ▸ (clobbers_01 _).2)
       simp [h0, h1])
    | rfl)

/-- `ovf_close`, for `mul.ovf`: also the products and the overflow checks. -/
macro "mulOvf_close" : tactic =>
  `(tactic| first
    | with_reducible rfl
    | exact flag_ite _
    | (intro i hi
       have h0 : i ≠ 0 := fun h => hi (h ▸ (clobbers_01 _).1)
       have h1 : i ≠ 1 := fun h => hi (h ▸ (clobbers_01 _).2)
       first
       | (have h2 : i ≠ 2 := fun h => hi (h ▸ by decide); simp [h0, h1, h2, idx_rdx])
       | simp [h0, h1]))

/-! ### `add.ovf`, `sub.ovf` -/

theorem sound_ovf (a : Alu) (ha : a = .add ∨ a = .sub) (sg : Bool) (w : W) :
    SoundD (.ovf a sg w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hdj
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, o3, v0, v1, v2, v3, rfl, rfl, h0, h1, h2, h3⟩ := nvs4 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  obtain ⟨s3, rfl, rfl⟩ := nv_slot.1 h3
  have hty : Ty.parse (tyName sg w) = some (.int (wbytes w) sg) := by
    cases sg
    · exact (tyName_parse w).1
    · exact (tyName_parse w).2
  obtain ⟨ba, bb, va, vb, res, ov, st1, hra, hrb, hva, hvb, hres, hw1, hw2, rfl⟩ :=
    opSem_ovf hh hty ho hsem
  have hwr' := wranges_ovf (d := s0.toInt) (o := s1.toInt) (a := s2.toInt) (b := s3.toInt) hh hty ho
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have hA := read_int hr (by omega) hra hva
  have hB := read_int hr (by omega) hrb hvb
  subst hA hB
  have hlen : (intBytes (wbytes w) res.toNat).length = wbytes w := by
    simp [intBytes, Theorems.encodeBits_length]
  have hpos : 0 < 8 * wbytes w := by cases w <;> decide
  rcases ha with rfl | rfl <;> cases sg <;>
    simp (config := { decide := true }) only [↓reduceIte] at hres
  all_goals
    first
    | rw [intOvf_eq _ _ _ _ (Or.inl ⟨rfl, rfl⟩)] at hres
    | rw [intOvf_eq _ _ _ _ (Or.inr (Or.inl ⟨rfl, rfl⟩))] at hres
    simp only [BitVec.val, Bool.false_eq_true, ↓reduceIte, Except.ok.injEq, Prod.mk.injEq] at hres
    obtain ⟨hr1, hr2⟩ := hres
    first
    | rw [ov_add_u] at hr2 | rw [ov_sub_u] at hr2 | rw [ov_add_s hpos] at hr2
    | rw [ov_sub_s hpos] at hr2
    first
    | rw [res_add_u] at hr1 | rw [res_sub_u] at hr1 | rw [res_add_s] at hr1
    | rw [res_sub_s] at hr1
    subst hr1 hr2
  all_goals
    simp only [sequence, flagSeq, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
      Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ,
      List.cons_append, List.nil_append, Bool.false_eq_true, ↓reduceIte] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    cases w <;> xrun' <;>
      refine post_mem2 hr hw1 hw2 (by rw [hlen]; rfl) (by decide) rfl (by rw [hwr']; rfl) hdj
        (bytesRel_bv ?_) (bytesRel_flag ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals ovf_close

/-! ### `mul.ovf` -/

theorem execItems_append (ctx : Ctx) (l1 l2 : List Item) (x : Ryo.X86.State) :
    execItems ctx (l1 ++ l2) x = (execItems ctx l1 x >>= execItems ctx l2) := by
  simp only [execItems, List.foldlM_append]
  rfl

/-- The unsigned 32-bit `mul.ovf` body: the 64-bit product of the zero-extended operands,
compared with `0xffff_ffff`. -/
theorem exec_mulD (ctx : Ctx) (x : Ryo.X86.State) (a b : BitVec 32) :
    ∃ y, execItems ctx [ld .d (M.frame a), .ld .d false C (M.frame b), .imul .q R (.reg C),
        .setReg C 0xffff_ffff, .alu .cmp .q R (.reg C)] x = .ok y ∧
      y.reg .rbp = x.reg .rbp ∧ y.mem = x.mem ∧
      (∀ i : Fin 16, i ≠ 0 → i ≠ 1 → y.regs i = x.regs i) ∧ y.xmm = x.xmm ∧
      y.rip = x.rip + BitVec.ofNat 64 ([ld .d (M.frame a), .ld .d false C (M.frame b),
        .imul .q R (.reg C), .setReg C 0xffff_ffff, .alu .cmp .q R (.reg C)].map Item.size).sum ∧
      y.reg .rax = BitVec.setWidth 64 (BitVec.ofNat 32 (leDecode (bytesAt x.mem (fpAddr x a.toInt) 4))) *
        BitVec.setWidth 64 (BitVec.ofNat 32 (leDecode (bytesAt x.mem (fpAddr x b.toInt) 4))) ∧
      y.flags.cf = some ((y.reg .rax).ult 4294967295#64) ∧
      y.flags.zf = some (y.reg .rax - 4294967295#64 == 0#64) := by
  xrun'
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  all_goals xobs
  all_goals rfl



theorem sound_mulOvf (sg : Bool) (w : W) : SoundD (.mulOvf sg w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hdj
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, o3, v0, v1, v2, v3, rfl, rfl, h0, h1, h2, h3⟩ := nvs4 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  obtain ⟨s3, rfl, rfl⟩ := nv_slot.1 h3
  have hty : Ty.parse (tyName sg w) = some (.int (wbytes w) sg) := by
    cases sg
    · exact (tyName_parse w).1
    · exact (tyName_parse w).2
  obtain ⟨ba, bb, va, vb, res, ov, st1, hra, hrb, hva, hvb, hres, hw1, hw2, rfl⟩ :=
    opSem_ovf hh hty ho hsem
  have hwr' := wranges_ovf (d := s0.toInt) (o := s1.toInt) (a := s2.toInt) (b := s3.toInt) hh hty ho
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have hA := read_int hr (by omega) hra hva
  have hB := read_int hr (by omega) hrb hvb
  subst hA hB
  have hlen : (intBytes (wbytes w) res.toNat).length = wbytes w := by
    simp [intBytes, Theorems.encodeBits_length]
  rw [intOvf_eq _ _ _ _ (Or.inr (Or.inr ⟨rfl, rfl⟩))] at hres
  simp only [Except.ok.injEq, Prod.mk.injEq] at hres
  obtain ⟨hr1, hr2⟩ := hres
  rw [res_mul] at hr1
  have hpos : 0 < 8 * wbytes w := by cases w <;> decide
  subst hr1
  cases sg <;> simp only [BitVec.val, Bool.false_eq_true, ↓reduceIte] at hr2
  all_goals
    first | rw [ov_mul_u] at hr2 | rw [ov_mul_s hpos] at hr2
    subst hr2
    cases w
  all_goals
    simp only [sequence, flagSeq, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
      Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ,
      Bool.false_eq_true, ↓reduceIte, wb_beq.1, wb_beq.2, c128, c32768] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
  case false.d =>
    -- The body's state, summarized: its terms would otherwise grow too large.
    rw [List.append_assoc, execItems_append]
    obtain ⟨y, hy, hyb, hym, hyr, hyx, hyrip, hya, hcf, hzf⟩ := exec_mulD ctx x s2 s3
    rw [hy, ex_bind_ok']
    simp only [List.cons_append, List.nil_append]
    xrun'
    simp only [hcf, hzf, bind, Except.bind, Except.ok.injEq, exists_eq_left']
    refine post_mem2 hr hw1 hw2 (by rw [hlen]; rfl) (by decide) rfl (by rw [hwr']; rfl) hdj
      (bytesRel_bv ?_) (bytesRel_flag ?_) ?_ ?_ ?_ ?_ ?_ rfl
    all_goals xobs
    all_goals (try simp only [hya, hym, hyb, hyx, hyrip])
    all_goals (try xobs)
    all_goals first
      | (refine Eq.trans ?_ (res_zext (m := 32) (k := 64) (by decide) _ _).symm; rfl)
      | (refine flag_iff ?_
         exact umul_flag (m := 32) (k := 64) (by decide) _ _ 4294967295#64 (by decide))
      | (intro i hi
         have h0 : i ≠ 0 := fun h => hi (h ▸ (clobbers_01 _).1)
         have h1 : i ≠ 1 := fun h => hi (h ▸ (clobbers_01 _).2)
         simp [h1, hyr i h0 h1])
      | (simp only [ld, R, C])
  all_goals
    simp only [List.cons_append, List.nil_append]
    xrun'
    refine post_mem2 hr hw1 hw2 (by rw [hlen]; rfl) (by decide) rfl (by rw [hwr']; rfl) hdj
      (bytesRel_bv ?_) (bytesRel_flag ?_) ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  case false.b.refine_1 => refine Eq.trans ?_ (res_zext (m := 8) (k := 32) (by decide) _ _).symm; rfl
  case false.w.refine_1 => refine Eq.trans ?_ (res_zext (m := 16) (k := 32) (by decide) _ _).symm; rfl
  case true.b.refine_1 => refine Eq.trans ?_ (res_sext (m := 8) (k := 32) (by decide) _ _).symm; rfl
  case true.w.refine_1 => refine Eq.trans ?_ (res_sext (m := 16) (k := 32) (by decide) _ _).symm; rfl
  case false.b.refine_2 =>
    refine flag_iff ?_
    exact umul_flag' (m := 8) (k := 32) (by decide) _ _ 255#32 (by decide)
  case false.w.refine_2 =>
    refine flag_iff ?_
    exact umul_flag' (m := 16) (k := 32) (by decide) _ _ 65535#32 (by decide)
  case false.q.refine_1 =>
    simp only [idx_rdx]; simp; apply BitVec.eq_of_toNat_eq; simp [BitVec.toNat_mul]
  case false.q.refine_2 => refine flag_iff ?_; simp [BitVec.umulOverflow]
  case false.q.refine_3 => simp [idx_rdx]
  case true.b.refine_2 => refine flag_iff ?_; bv_decide
  case true.w.refine_2 => refine flag_iff ?_; bv_decide
  case true.d.refine_1 => rfl
  case true.q.refine_1 => rfl
  all_goals mulOvf_close
end Ryo.Proofs.Inline
