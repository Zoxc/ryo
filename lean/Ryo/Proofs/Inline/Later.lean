/-
Ryo.Proofs.Inline.Later — the inline classes added after `Ryo/Proofs/Inline.lean`'s theorems
(`laterClass`): the variable shifts and rotates (`shiftVar`), `bswap` and `cmp3`, against
`opSem`. All three only change `rax`, `rcx` and the flags (`cl` holds the shift count, the
`setcc cl` of `cmp3`), so they are `Sound`.

- `shiftVar`: the operand in `eax`/`rax` (sign-extended to 32 bits for an 8 or 16-bit `sar`),
  the count in `ecx` (masked to the width at 8 and 16 bits, where the shift runs in 32), then
  `shl`/`shr`/`sar`/`rol`/`ror` by `cl`. The 64-bit shifts load only the count's low 4 bytes
  (`readNat4`). The values are closed by `exact` with lemmas whose right-hand side is the
  machine computation as `Item.exec` builds it (`shift_b`, …, `rot_q`), up to definitional
  unfolding of the states.
- `bswap`: `bswapF` is `swapBytes` (`bswapF_eq`); at 16 bits the 32-bit swap's upper half.
- `cmp3`: `intCmp3` as comparisons (`intCmp3_eq`), then `bv_decide` as for `cmp`.
-/
import Ryo.Proofs.Inline

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm

namespace Later

/-! ### Footprints and `opSem` of the kinds -/

theorem tyName_parse' (sg : Bool) (w : W) : Ty.parse (tyName sg w) = some (.int (wbytes w) sg) := by
  cases sg
  · exact (tyName_parse w).1
  · exact (tyName_parse w).2

theorem fp_shift {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .shift (ty :: ps) =
      some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" n] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h] <;> rfl

theorem fp_rot {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .rot (ty :: ps) =
      some { reads := [rdA "a" n, rdA "b" 4], writes := [rdA "d" n] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h] <;> rfl

theorem fp_cmp3 {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .cmp3 (ty :: ps) =
      some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" 1] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h] <;> rfl

theorem fp_un {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .un (ty :: ps) = some { reads := [rdA "a" n], writes := [rdA "d" n] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h] <;> rfl

/-- `shift` at `n` bytes: both operands as integers, `intBin`'s result. -/
theorem opSem_shift {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat} {sg : Bool}
    {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.shift, [ty, m], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hsem : opSem op [.slot d, .slot a, .slot b] st ch = .ok (c, st')) :
    ∃ ba bb va vb res, st.readFrame a n = .ok ba ∧ st.readFrame b n = .ok bb ∧
      asNat ba = .ok va ∧ asNat bb = .ok vb ∧
      intBin m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res ∧
      st.writeFrame d (intBytes n res.toNat) = .ok st' ∧ c = .next := by
  oinv hsem, hh, fp_shift (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨ba, hra', bb, hrb, rfl⟩ := hra
  have hk' : kindSem .bin [ty, m] (mkEnv [("a", ba), ("b", bb)]
      (opndVal op.info [.slot d, .slot a, .slot b]) st ch) = .ok o := by
    simpa [kindSem] using hk
  osimp [ho, intTy_of_parse hty] at hk'
  obtain ⟨va, hva, vb, hvb, res, hres, rfl⟩ := hk'
  exact ⟨ba, bb, va, vb, res, hra', hrb, hva, hvb, hres,
    (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `rot` at `n` bytes: the operand, the 4-byte count, `intRot`'s result. -/
theorem opSem_rot {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat} {sg : Bool}
    {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.rot, [ty, m], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hsem : opSem op [.slot d, .slot a, .slot b] st ch = .ok (c, st')) :
    ∃ ba bb va vb res, st.readFrame a n = .ok ba ∧ st.readFrame b 4 = .ok bb ∧
      asNat ba = .ok va ∧ asNat bb = .ok vb ∧
      intRot m (BitVec.ofNat (8 * n) va) vb = .ok res ∧
      st.writeFrame d (intBytes n res.toNat) = .ok st' ∧ c = .next := by
  oinv hsem, hh, fp_rot (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨ba, hra', bb, hrb, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, vb, hvb, res, hres, rfl⟩ := hk
  exact ⟨ba, bb, va, vb, res, hra', hrb, hva, hvb, hres,
    (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `cmp3` at `n` bytes: both operands as integers, `intCmp3` as a byte. -/
theorem opSem_cmp3 {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.cmp3, [ty], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hsem : opSem op [.slot d, .slot a, .slot b] st ch = .ok (c, st')) :
    ∃ ba bb va vb, st.readFrame a n = .ok ba ∧ st.readFrame b n = .ok bb ∧
      asNat ba = .ok va ∧ asNat bb = .ok vb ∧
      st.writeFrame d (intBytes 1
        (intCmp3 sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb)).toNat) = .ok st' ∧
      c = .next := by
  oinv hsem, hh, fp_cmp3 (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨ba, hra', bb, hrb, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, vb, hvb, rfl⟩ := hk
  exact ⟨ba, bb, va, vb, hra', hrb, hva, hvb,
    (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `un` at `n` bytes: the operand as an integer, `intUn`'s result. -/
theorem opSem_un {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat} {sg : Bool}
    {d a : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.un, [ty, m], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩])
    (hsem : opSem op [.slot d, .slot a] st ch = .ok (c, st')) :
    ∃ ba va res, st.readFrame a n = .ok ba ∧ asNat ba = .ok va ∧
      intUn m (BitVec.ofNat (8 * n) va) = .ok res ∧
      st.writeFrame d (intBytes n res.toNat) = .ok st' ∧ c = .next := by
  oinv hsem, hh, fp_un (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨ba, hra', rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, res, hres, rfl⟩ := hk
  exact ⟨ba, va, res, hra', hva, hres, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-! ### The handlers' results -/

/-- A shift or rotate of `a` by `c` (`shiftF_fst`'s right-hand side). -/
def shv (op : Sh) {n : Nat} (a : BitVec n) (c : Nat) : BitVec n :=
  match op with
  | .shl => a <<< c
  | .shr => a >>> c
  | .sar => a.sshiftRight c
  | .rol => a.rotateLeft c
  | .ror => a.rotateRight c

theorem intBin_shift (sh : Sh) (hsh : sh.isShift = true) {n : Nat} {A B res : BitVec n}
    (h : intBin (shMethod sh) (sh == .sar) A B = .ok res) : res = shv sh A (B.toNat % n) := by
  cases sh <;> simp [Sh.isShift] at hsh <;> simp [intBin, shMethod, pure, Except.pure] at h <;>
    first | exact h.symm | exact h | (subst h; rfl)

theorem intRot_shv (sh : Sh) (hsh : sh.isShift = false) {n : Nat} {A res : BitVec n} {b : Nat}
    (h : intRot (if sh == .rol then "rotate_left" else "rotate_right") A b = .ok res) :
    res = shv sh A (b % n) := by
  cases sh <;> simp [Sh.isShift] at hsh <;>
    simp [intRot, pure, Except.pure, -BitVec.rotateLeft_mod_eq_rotateLeft,
      -BitVec.rotateRight_mod_eq_rotateRight] at h <;>
    first | exact h.symm | exact h | (subst h; rfl)

theorem intUn_swap {n : Nat} {A res : BitVec n} (h : intUn "swap_bytes" A = .ok res) :
    res = swapBytes A := by
  simp [intUn, pure, Except.pure] at h
  first | exact h.symm | exact h | (subst h; rfl)

theorem intCmp3_eq (sg : Bool) {w : Nat} (a b : BitVec w) :
    intCmp3 sg a b = if (if sg then a.slt b else a.ult b) then (255 : BitVec 8)
      else if (if sg then b.slt a else b.ult a) then 1 else 0 := by
  have hA : BitVec.allOnes 8 = (255 : BitVec 8) := by decide
  cases sg
  · simp only [intCmp3, Bool.false_eq_true, ↓reduceIte, BitVec.ult, decide_eq_true_eq]
    rcases Nat.lt_trichotomy a.toNat b.toNat with h | h | h
    · rw [(Nat.compare_eq_lt).2 h]; simp [h, hA]
    · rw [(Nat.compare_eq_eq).2 h]; simp [h]
    · rw [(Nat.compare_eq_gt).2 h]; simp [h, Nat.not_lt.2 (Nat.le_of_lt h)]
  · simp only [intCmp3, ↓reduceIte, BitVec.slt, decide_eq_true_eq]
    rcases Int.lt_trichotomy a.toInt b.toInt with h | h | h
    · rw [(Int.compare_eq_lt).2 h]; simp [h, hA]
    · rw [(Int.compare_eq_eq).2 h]; simp [h]
    · rw [(Int.compare_eq_gt).2 h]; simp [h, Int.not_lt.2 (Int.le_of_lt h)]

/-! ### `bswap` is `swapBytes` -/

theorem leBytes_eq {w : Nat} (v : BitVec w) (n : Nat) : leBytes v n = leEncode n v.toNat := by
  unfold leBytes
  generalize v.toNat = V
  induction n generalizing V with
  | zero => rfl
  | succ n ih =>
    rw [List.range_succ_eq_map, List.map_cons, List.map_map]
    show UInt8.ofNat (V >>> (8 * 0)) :: _ = UInt8.ofNat (V % 256) :: leEncode n (V / 256)
    congr 1
    · apply UInt8.toNat_inj.1
      simp
    · rw [← ih (V / 256)]
      apply List.map_congr_left
      intro i _
      simp only [Function.comp_apply, Nat.succ_eq_add_one]
      congr 1
      have hp : (2 : Nat) ^ (8 * (i + 1)) = 256 * 2 ^ (8 * i) := by
        rw [show 8 * (i + 1) = 8 + 8 * i by omega, Nat.pow_add]
        try rfl
      rw [Nat.shiftRight_eq_div_pow, Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul, hp]

theorem ofLeBytes_eq (bs : List UInt8) : ofLeBytes bs = leDecode bs := by
  induction bs with
  | nil => rfl
  | cons b bs ih =>
    show b.toNat + 256 * ofLeBytes bs = b.toNat + 256 * leDecode bs
    rw [ih]

theorem bswapF_eq {n : Nat} (v : BitVec n) : bswapF v = swapBytes v := by
  unfold bswapF swapBytes
  rw [leBytes_eq, ofLeBytes_eq]

theorem swap16_toNat (a : BitVec 16) :
    (swapBytes a).toNat = a.toNat / 256 % 256 + 256 * (a.toNat % 256) := by
  unfold swapBytes
  simp [leEncode, leDecode]
  omega

theorem swap32_toNat (a : BitVec 32) :
    (swapBytes a).toNat = a.toNat / 256 / 256 / 256 % 256 + 256 * (a.toNat / 256 / 256 % 256 +
      256 * (a.toNat / 256 % 256 + 256 * (a.toNat % 256))) := by
  unfold swapBytes
  simp [leEncode, leDecode]
  omega

/-! ### Widths -/

theorem sw32 (y : BitVec 32) : (y.setWidth 64).setWidth 32 = y := by
  rw [BitVec.setWidth_setWidth_of_le _ (by decide), BitVec.setWidth_eq]

theorem toNat_sw32 (y : BitVec 32) : (y.setWidth 64).toNat = y.toNat := by
  rw [BitVec.toNat_setWidth]
  exact Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le y.isLt (by decide))

theorem merge_b (o : BitVec 64) (y : BitVec 8) :
    ((o &&& ~~~(0xff : BitVec 64)) ||| y.setWidth 64).setWidth 8 = y := by
  bv_decide

theorem merge_w (o : BitVec 64) (y : BitVec 16) :
    ((o &&& ~~~(0xffff : BitVec 64)) ||| y.setWidth 64).setWidth 16 = y := by
  bv_decide

theorem zx_b (A : BitVec 8) : ((A.setWidth 32).setWidth 64).setWidth 8 = A := by
  bv_decide

theorem zx_w (A : BitVec 16) : ((A.setWidth 32).setWidth 64).setWidth 16 = A := by
  bv_decide

theorem leDecode_append (l1 l2 : List UInt8) :
    leDecode (l1 ++ l2) = leDecode l1 + 2 ^ (8 * l1.length) * leDecode l2 := by
  induction l1 with
  | nil => simp [leDecode]
  | cons b l ih =>
    simp only [List.cons_append, leDecode, ih, List.length_cons]
    have e : (2 : Nat) ^ (8 * (l.length + 1)) = 256 * 2 ^ (8 * l.length) := by
      rw [show 8 * (l.length + 1) = 8 + 8 * l.length by omega, Nat.pow_add]
      try rfl
    rw [e, Nat.mul_assoc 256]
    generalize 2 ^ (8 * l.length) * leDecode l2 = Q
    omega

/-- The low 4 bytes of an 8-byte read (the 64-bit shifts load only the count's). -/
theorem readNat4 (m : Ryo.X86.Mem) (a : BitVec 64) : m.readNat a 4 = m.readNat a 8 % 2 ^ 32 := by
  rw [readNat_eq, readNat_eq, show (8 : Nat) = 4 + 4 from rfl, bytesAt_add, leDecode_append,
    bytesAt_length]
  have h := Theorems.leDecode_lt (bytesAt m a 4)
  rw [bytesAt_length] at h
  have e : (2 : Nat) ^ (8 * 4) = 2 ^ 32 := rfl
  rw [e] at h ⊢
  rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt h]

theorem mod_chain32 (rb k : Nat) (hk : k ∣ 32) : rb % 2 ^ 32 % 2 ^ 64 % 32 % k = rb % k := by
  have h1 : rb % 2 ^ 32 % 2 ^ 64 = rb % 2 ^ 32 :=
    Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le (Nat.mod_lt _ (by decide)) (by decide))
  rw [h1, Nat.mod_mod_of_dvd _ (by decide : 32 ∣ 2 ^ 32), Nat.mod_mod_of_dvd _ hk]

theorem mod_chain64 (rb k : Nat) (hk : k ∣ 64) : rb % 2 ^ 32 % 2 ^ 64 % 64 % k = rb % k := by
  have h1 : rb % 2 ^ 32 % 2 ^ 64 = rb % 2 ^ 32 :=
    Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le (Nat.mod_lt _ (by decide)) (by decide))
  rw [h1, Nat.mod_mod_of_dvd _ (by decide : 64 ∣ 2 ^ 32), Nat.mod_mod_of_dvd _ hk]

/-! ### Shifts and rotates by `cl` -/

theorem shiftF_fst' (op : Sh) {n : Nat} (a : BitVec n) (c : Nat) : (shiftF op a c).1 = shv op a c := by
  rw [shiftF_fst]; cases op <;> rfl

theorem rotL0 {n : Nat} (a : BitVec n) : a.rotateLeft 0 = a := by
  have h := shiftF_fst Sh.rol a 0
  exact h.symm.trans rfl

theorem rotR0 {n : Nat} (a : BitVec n) : a.rotateRight 0 = a := by
  have h := shiftF_fst Sh.ror a 0
  exact h.symm.trans rfl

theorem rotF_fst' (op : Sh) (h : op.isShift = false) {n : Nat} (a : BitVec n) (c : Nat) (f : Flags) :
    (rotF op a c f).1 = shv op a c := by
  cases op <;> simp [Sh.isShift] at h
  case rol =>
    by_cases hc : c = 0
    · subst hc; simp [rotF, shv, rotL0]
    · simp (config := { decide := true }) [rotF, shv, hc]
  case ror =>
    by_cases hc : c = 0
    · subst hc; simp [rotF, shv, rotR0]
    · simp (config := { decide := true }) [rotF, shv, hc]

theorem shv_rot_congr (sh : Sh) (hsh : sh.isShift = false) {n : Nat} (A : BitVec n) {r s : Nat}
    (h : r % n = s % n) : shv sh A r = shv sh A s := by
  cases sh <;> simp [Sh.isShift] at hsh
  case rol =>
    show A.rotateLeft r = A.rotateLeft s
    rw [← BitVec.rotateLeft_mod_eq_rotateLeft (r := r), h, BitVec.rotateLeft_mod_eq_rotateLeft]
  case ror =>
    show A.rotateRight r = A.rotateRight s
    rw [← BitVec.rotateRight_mod_eq_rotateRight (r := r), h, BitVec.rotateRight_mod_eq_rotateRight]

/-- What `shiftCl` computes: the result and the new flags (`Item.exec`'s). -/
def shiftClRes (op : Sh) (w : W) (s : Ryo.X86.State) (reg : Reg) : BitVec w.bits × Option Flags :=
  let c := (s.reg .rcx).toNat % (if w == .q then 64 else 32)
  let v := s.regW w reg
  if op.isShift then
    let (r, f) := shiftF op v c
    (r, if c ≥ w.bits && op != .sar then f.map ({ · with cf := none }) else f)
  else rotF op v c s.flags

theorem exec_shiftCl (ctx : Ctx) (op : Sh) (w : W) (reg : Reg) (s : Ryo.X86.State) :
    (Item.shiftCl op w reg).exec ctx s =
      .ok (setFlags? ((s.jump (s.rip + BitVec.ofNat 64 (Item.shiftCl op w reg).size)).setRegW w reg
        (shiftClRes op w (s.jump (s.rip + BitVec.ofNat 64 (Item.shiftCl op w reg).size)) reg).1)
        (shiftClRes op w (s.jump (s.rip + BitVec.ofNat 64 (Item.shiftCl op w reg).size)) reg).2) := by
  first
  | rfl
  | (simp only [Item.exec, shiftClRes]
     split <;> (rename_i h; simp only [setFlags?, pure, Except.pure, h]))

/-- `xrun`, with `shiftCl` and the flags across `setRegW` (`setcc r8`). -/
macro "xrunL" : tactic =>
  `(tactic| (simp only [execItems_cons, execItems_nil, ld, Asm.st, R, C, Mrax, exec_setReg,
               exec_shift, exec_shiftCl]
             simp only [Item.exec, ex_bind_ok', pure, Except.pure, Except.ok.injEq,
               exists_eq_left', State.setMemW, Cond.eval, need, aluF, subF_eq, logicFlags,
               Functor.map, Except.map, bind, Except.bind, X86S.flags_jump, X86S.flags_setFlags,
               X86S.flags_setReg, X86S.flags_setMem, flags_setRegW]))

/-! #### The stored values, as `Item.exec` builds them -/

/-- 32 bits: `mov eax, [a]; mov ecx, [b]; sh eax, cl`. -/
theorem shift_d (sh : Sh) (A B : BitVec 32) :
    shv sh A (B.toNat % 32) =
      (((shiftF sh ((A.setWidth 64).setWidth 32) ((B.setWidth 64).toNat % 32)).1).setWidth 64).setWidth 32 := by
  rw [shiftF_fst', sw32 A, toNat_sw32 B, sw32]

/-- 64 bits: the count's low 4 bytes, `rb4`, of its 8, `rb8`. -/
theorem shift_q (sh : Sh) (A : BitVec 64) (rb4 rb8 : Nat) (h : rb4 = rb8 % 2 ^ 32) :
    shv sh A ((BitVec.ofNat 64 rb8).toNat % 64) =
      (((shiftF sh ((A.setWidth 64).setWidth 64)
        (((BitVec.ofNat 32 rb4).setWidth 64).toNat % 64)).1).setWidth 64).setWidth 64 := by
  simp only [shiftF_fst', BitVec.setWidth_eq]
  subst h
  congr 1
  simp only [BitVec.toNat_ofNat, BitVec.toNat_setWidth, Nat.reducePow]
  omega

theorem amt_b (B : BitVec 8) :
    (((((B.setWidth 32).setWidth 64).setWidth 32 &&& (BitVec.ofNat 32 (8 - 1)).signExtend 32).setWidth 64).toNat % 32) =
      B.toNat % 8 := by
  have e : (((B.setWidth 32).setWidth 64).setWidth 32 &&& (BitVec.ofNat 32 (8 - 1)).signExtend 32).setWidth 64 =
      (B % 8#8).setWidth 64 := by bv_decide
  rw [e, BitVec.toNat_setWidth, BitVec.toNat_umod]
  have h8 : (8#8).toNat = 8 := rfl
  rw [h8]
  have hlt : B.toNat % 8 < 8 := Nat.mod_lt _ (by decide)
  rw [Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le hlt (by decide : 8 ≤ 2 ^ 64)),
    Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le hlt (by decide : 8 ≤ 32))]

theorem amt_w (B : BitVec 16) :
    (((((B.setWidth 32).setWidth 64).setWidth 32 &&& (BitVec.ofNat 32 (16 - 1)).signExtend 32).setWidth 64).toNat % 32) =
      B.toNat % 16 := by
  have e : (((B.setWidth 32).setWidth 64).setWidth 32 &&& (BitVec.ofNat 32 (16 - 1)).signExtend 32).setWidth 64 =
      (B % 16#16).setWidth 64 := by bv_decide
  rw [e, BitVec.toNat_setWidth, BitVec.toNat_umod]
  have h16 : (16#16).toNat = 16 := rfl
  rw [h16]
  have hlt : B.toNat % 16 < 16 := Nat.mod_lt _ (by decide)
  rw [Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le hlt (by decide : 16 ≤ 2 ^ 64)),
    Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le hlt (by decide : 16 ≤ 32))]

/-- 8 bits: in 32 (`sar` on the sign extension), the count masked to 3 bits. -/
theorem shift_b (sh : Sh) (hsh : sh.isShift = true) (A B : BitVec 8) :
    shv sh A (B.toNat % 8) =
      (((shiftF sh (((if sh == .sar then A.signExtend 32 else A.setWidth 32).setWidth 64).setWidth 32)
        (((((B.setWidth 32).setWidth 64).setWidth 32 &&& (BitVec.ofNat 32 (8 - 1)).signExtend 32).setWidth 64).toNat % 32)).1).setWidth 64).setWidth 8 := by
  rw [amt_b B, shiftF_fst']
  have hk : B.toNat % 8 < 8 := Nat.mod_lt _ (by decide)
  generalize B.toNat % 8 = k at hk ⊢
  have hc : k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3 ∨ k = 4 ∨ k = 5 ∨ k = 6 ∨ k = 7 := by omega
  cases sh <;> simp [Sh.isShift] at hsh <;>
    rcases hc with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp (config := { decide := true }) only [shv, ↓reduceIte] <;> bv_decide

/-- 16 bits: as `shift_b`, the count masked to 4 bits. -/
theorem shift_w (sh : Sh) (hsh : sh.isShift = true) (A B : BitVec 16) :
    shv sh A (B.toNat % 16) =
      (((shiftF sh (((if sh == .sar then A.signExtend 32 else A.setWidth 32).setWidth 64).setWidth 32)
        (((((B.setWidth 32).setWidth 64).setWidth 32 &&& (BitVec.ofNat 32 (16 - 1)).signExtend 32).setWidth 64).toNat % 32)).1).setWidth 64).setWidth 16 := by
  rw [amt_w B, shiftF_fst']
  have hk : B.toNat % 16 < 16 := Nat.mod_lt _ (by decide)
  generalize B.toNat % 16 = k at hk ⊢
  have hc : k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3 ∨ k = 4 ∨ k = 5 ∨ k = 6 ∨ k = 7 ∨ k = 8 ∨ k = 9 ∨
      k = 10 ∨ k = 11 ∨ k = 12 ∨ k = 13 ∨ k = 14 ∨ k = 15 := by omega
  cases sh <;> simp [Sh.isShift] at hsh <;>
    rcases hc with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl |
      rfl | rfl | rfl <;>
    simp (config := { decide := true }) only [shv, ↓reduceIte] <;> bv_decide

/-- Rotates at 8 bits: the count from 4 bytes, `rol al, cl` (8 divides `cl`'s 5-bit mask). -/
theorem rot_b (sh : Sh) (hsh : sh.isShift = false) (A : BitVec 8) (rb : Nat) (f : Flags) :
    shv sh A (rb % 8) =
      ((((A.setWidth 32).setWidth 64) &&& ~~~(0xff : BitVec 64)) |||
        ((rotF sh (((A.setWidth 32).setWidth 64).setWidth 8)
          (((BitVec.ofNat 32 rb).setWidth 64).toNat % 32) f).1).setWidth 64).setWidth 8 := by
  rw [merge_b, rotF_fst' sh hsh, zx_b]
  apply shv_rot_congr sh hsh
  rw [BitVec.toNat_setWidth, BitVec.toNat_ofNat, mod_chain32 rb 8 (by decide), Nat.mod_mod]

theorem rot_w (sh : Sh) (hsh : sh.isShift = false) (A : BitVec 16) (rb : Nat) (f : Flags) :
    shv sh A (rb % 16) =
      ((((A.setWidth 32).setWidth 64) &&& ~~~(0xffff : BitVec 64)) |||
        ((rotF sh (((A.setWidth 32).setWidth 64).setWidth 16)
          (((BitVec.ofNat 32 rb).setWidth 64).toNat % 32) f).1).setWidth 64).setWidth 16 := by
  rw [merge_w, rotF_fst' sh hsh, zx_w]
  apply shv_rot_congr sh hsh
  rw [BitVec.toNat_setWidth, BitVec.toNat_ofNat, mod_chain32 rb 16 (by decide), Nat.mod_mod]

theorem rot_d (sh : Sh) (hsh : sh.isShift = false) (A : BitVec 32) (rb : Nat) (f : Flags) :
    shv sh A (rb % 32) =
      ((rotF sh ((A.setWidth 64).setWidth 32)
        (((BitVec.ofNat 32 rb).setWidth 64).toNat % 32) f).1.setWidth 64).setWidth 32 := by
  rw [sw32 A, sw32, rotF_fst' sh hsh]
  apply shv_rot_congr sh hsh
  rw [BitVec.toNat_setWidth, BitVec.toNat_ofNat, mod_chain32 rb 32 (by decide), Nat.mod_mod]

theorem rot_q (sh : Sh) (hsh : sh.isShift = false) (A : BitVec 64) (rb : Nat) (f : Flags) :
    shv sh A (rb % 64) =
      ((rotF sh ((A.setWidth 64).setWidth 64)
        (((BitVec.ofNat 32 rb).setWidth 64).toNat % 64) f).1.setWidth 64).setWidth 64 := by
  simp only [BitVec.setWidth_eq]
  rw [rotF_fst' sh hsh]
  apply shv_rot_congr sh hsh
  rw [BitVec.toNat_setWidth, BitVec.toNat_ofNat, mod_chain64 rb 64 (by decide), Nat.mod_mod]

/-! #### `bswap` -/

theorem bswap_b (A : BitVec 8) :
    swapBytes A = ((((A.setWidth 32).setWidth 64) &&& ~~~(0xff : BitVec 64)) |||
      (bswapF (((A.setWidth 32).setWidth 64).setWidth 8)).setWidth 64).setWidth 8 := by
  rw [merge_b, zx_b, bswapF_eq]

/-- 16 bits: the 32-bit swap, shifted down by 16. -/
theorem bswap_w (A : BitVec 16) :
    swapBytes A = (((shiftF Sh.shr (((bswapF (((A.setWidth 32).setWidth 64).setWidth 32)).setWidth 64).setWidth 32)
      ((16 : BitVec 8).toNat % 32)).1).setWidth 64).setWidth 16 := by
  rw [shiftF_fst']
  have e1 : ((A.setWidth 32).setWidth 64).setWidth 32 = A.setWidth 32 := by bv_decide
  have e2 : (16 : BitVec 8).toNat % 32 = 16 := by decide
  rw [e1, e2, bswapF_eq, sw32]
  show swapBytes A = (((swapBytes (A.setWidth 32)) >>> 16).setWidth 64).setWidth 16
  apply BitVec.eq_of_toNat_eq
  rw [swap16_toNat]
  have hA : A.toNat < 65536 := A.isLt
  have hA32 : A.toNat % 4294967296 = A.toNat := Nat.mod_eq_of_lt (by omega)
  have h16 : (16 : BitVec 8).toNat = 16 := by decide
  simp only [BitVec.toNat_setWidth, BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow,
    swap32_toNat, Nat.reducePow, h16, hA32, Nat.reduceMod, Nat.reduceDiv]
  have h2 : A.toNat / 256 / 256 = 0 := by omega
  simp only [h2, Nat.zero_div, Nat.zero_mod, Nat.zero_add, Nat.mul_zero]
  have hp : A.toNat / 256 % 256 < 256 := Nat.mod_lt _ (by decide)
  have hq : A.toNat % 256 < 256 := Nat.mod_lt _ (by decide)
  generalize A.toNat / 256 % 256 = p at *
  generalize A.toNat % 256 = q at *
  omega

theorem bswap_d (A : BitVec 32) :
    swapBytes A = ((bswapF ((A.setWidth 64).setWidth 32)).setWidth 64).setWidth 32 := by
  rw [sw32 A, sw32, bswapF_eq]

theorem bswap_q (A : BitVec 64) :
    swapBytes A = ((bswapF ((A.setWidth 64).setWidth 64)).setWidth 64).setWidth 64 := by
  simp only [BitVec.setWidth_eq, bswapF_eq]

/-! ### The classes -/

set_option maxHeartbeats 4000000 in
theorem sound_shiftVar_sh (sh : Sh) (w : W) (hsh : sh.isShift = true) : Sound (.shiftVar sh w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  have hk : classHandler (.shiftVar sh w) = (.shift, [tyName (sh == .sar) w, shMethod sh]) := by
    cases sh <;> simp [Sh.isShift] at hsh <;> rfl
  rw [hk] at hh
  try dsimp only at hh
  simp only [classOperands] at ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  have hty := tyName_parse' (sh == .sar) w
  obtain ⟨ba, bb, va, vb, res, hra, hrb, hva, hvb, hres, hwr, rfl⟩ := opSem_shift hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .slot s2.toInt]) (d := s0.toInt)
    hh (fp_shift (tySize_of_parse hty)) (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  have hb := read_int hr (by omega) hrb hvb
  rw [← readNat_eq] at ha hb
  subst ha hb
  have hres' := intBin_shift sh hsh hres
  subst hres'
  have hlen : ∀ v, (intBytes (wbytes w) v).length = wbytes w := by
    intro v; simp [intBytes, Theorems.encodeBits_length]
  cases sh <;> simp [Sh.isShift] at hsh <;> cases w
  all_goals
    simp (config := { decide := true }) only [sequence, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero,
      List.getElem?_cons_succ, ↓reduceIte, List.cons_append, List.nil_append] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    xrunL
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_)
      ?_ ?_ ?_ ?_ ?_ rfl
  all_goals first
    | with_reducible rfl
    | (simp only [State.regW, X86S.reg_jump, reg_setFlags?]
       first
       | exact shift_d _ _ _
       | exact shift_q _ _ _ _ (readNat4 _ _)
       | exact shift_b _ (by decide) _ _
       | exact shift_w _ (by decide) _ _)
    | (xobs; done)
    | (xobs; with_reducible rfl)

theorem sound_shiftVar_rot (sh : Sh) (w : W) (hsh : sh.isShift = false) : Sound (.shiftVar sh w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  have hk : classHandler (.shiftVar sh w) =
      (.rot, [tyName false w, if sh == .rol then "rotate_left" else "rotate_right"]) := by
    cases sh <;> simp [Sh.isShift] at hsh <;> rfl
  rw [hk] at hh
  try dsimp only at hh
  simp only [classOperands] at ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  have hty := (tyName_parse w).1
  obtain ⟨ba, bb, va, vb, res, hra, hrb, hva, hvb, hres, hwr, rfl⟩ := opSem_rot hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .slot s2.toInt]) (d := s0.toInt)
    hh (fp_rot (tySize_of_parse hty)) (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  have hb := read_int hr (by decide) hrb hvb
  rw [← readNat_eq] at ha hb
  subst ha hb
  have hres' := intRot_shv sh hsh hres
  subst hres'
  have hlen : ∀ v, (intBytes (wbytes w) v).length = wbytes w := by
    intro v; simp [intBytes, Theorems.encodeBits_length]
  cases sh <;> simp [Sh.isShift] at hsh <;> cases w
  all_goals
    simp (config := { decide := true }) only [sequence, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero,
      List.getElem?_cons_succ, ↓reduceIte, List.cons_append, List.nil_append] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    xrunL
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_)
      ?_ ?_ ?_ ?_ ?_ rfl
  all_goals first
    | with_reducible rfl
    | (simp only [State.regW, X86S.reg_jump, reg_setFlags?]
       first
       | exact rot_b _ (by decide) _ _ _
       | exact rot_w _ (by decide) _ _ _
       | exact rot_d _ (by decide) _ _ _
       | exact rot_q _ (by decide) _ _ _)
    | (xobs; done)
    | (xobs; with_reducible rfl)

end Later

open Later in
/-- The variable shifts and rotates (`shl`, `shr.s`, `shr.u`, `rotl`, `rotr` by a slot's value,
through `cl`). -/
theorem sound_shiftVar (sh : Sh) (w : W) : Sound (.shiftVar sh w) := by
  cases h : sh.isShift
  · exact sound_shiftVar_rot sh w h
  · exact sound_shiftVar_sh sh w h

open Later in
/-- `bswap` at each width (16 bits through the 32-bit swap, shifted down). -/
theorem sound_bswap (w : W) : Sound (.bswap w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  have hty := (tyName_parse w).1
  obtain ⟨ba, va, res, hra, hva, hres, hwr, rfl⟩ := opSem_un hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt]) (d := s0.toInt)
    hh (fp_un (tySize_of_parse hty)) (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  rw [← readNat_eq] at ha
  subst ha
  have hres' := intUn_swap hres
  subst hres'
  have hlen : ∀ v, (intBytes (wbytes w) v).length = wbytes w := by
    intro v; simp [intBytes, Theorems.encodeBits_length]
  cases w
  case b =>
    simp (config := { decide := true }) only [sequence, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero,
      List.getElem?_cons_succ, ↓reduceIte, List.cons_append, List.nil_append] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    xrunL
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_)
      ?_ ?_ ?_ ?_ ?_ rfl
    · simp only [State.regW, X86S.reg_jump, reg_setFlags?]
      exact bswap_b _
    all_goals first
      | with_reducible rfl
      | (xobs; done)
      | (xobs; with_reducible rfl)
  case w =>
    simp (config := { decide := true }) only [sequence, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero,
      List.getElem?_cons_succ, ↓reduceIte, List.cons_append, List.nil_append] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    xrunL
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_)
      ?_ ?_ ?_ ?_ ?_ rfl
    · simp only [State.regW, X86S.reg_jump, reg_setFlags?]
      exact bswap_w _
    all_goals first
      | with_reducible rfl
      | (xobs; done)
      | (xobs; with_reducible rfl)
  case d =>
    simp (config := { decide := true }) only [sequence, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero,
      List.getElem?_cons_succ, ↓reduceIte, List.cons_append, List.nil_append] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    xrunL
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_)
      ?_ ?_ ?_ ?_ ?_ rfl
    · simp only [State.regW, X86S.reg_jump, reg_setFlags?]
      exact bswap_d _
    all_goals first
      | with_reducible rfl
      | (xobs; done)
      | (xobs; with_reducible rfl)
  case q =>
    simp (config := { decide := true }) only [sequence, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero,
      List.getElem?_cons_succ, ↓reduceIte, List.cons_append, List.nil_append] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    xrunL
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_)
      ?_ ?_ ?_ ?_ ?_ rfl
    · simp only [State.regW, X86S.reg_jump, reg_setFlags?]
      exact bswap_q _
    all_goals first
      | with_reducible rfl
      | (xobs; done)
      | (xobs; with_reducible rfl)

open Later in
/-- `cmp3`, signed or not: `cmp`, both `setcc`s, and their difference as the byte. -/
theorem sound_cmp3 (sg : Bool) (w : W) : Sound (.cmp3 sg w) := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩ := nvs3 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  obtain ⟨s2, rfl, rfl⟩ := nv_slot.1 h2
  have hty := tyName_parse' sg w
  obtain ⟨ba, bb, va, vb, hra, hrb, hva, hvb, hwr, rfl⟩ := opSem_cmp3 hh hty ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .slot s1.toInt, .slot s2.toInt]) (d := s0.toInt)
    hh (fp_cmp3 (tySize_of_parse hty)) (by simp [opndVal, ho])
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have ha := read_int hr (by omega) hra hva
  have hb := read_int hr (by omega) hrb hvb
  subst ha hb
  rw [intCmp3_eq] at hwr
  have hlen : ∀ v, (intBytes 1 v).length = 1 := by
    intro v; simp [intBytes, Theorems.encodeBits_length]
  cases sg <;> cases w
  all_goals
    simp (config := { decide := true }) only [sequence, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero,
      List.getElem?_cons_succ, ↓reduceIte, List.cons_append, List.nil_append] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    xrunL
    refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl) (bytesRel_bv ?_)
      ?_ ?_ ?_ ?_ ?_ rfl
  all_goals xobs
  all_goals first | with_reducible rfl | bv_decide

end Ryo.Proofs.Inline
