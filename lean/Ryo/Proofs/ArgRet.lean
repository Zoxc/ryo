/-
Ryo.Proofs.ArgRet — R's `arg` and `ret` steps against their fixed sequences (aot.md §C2
"Shapes", toward M3 `decode_sound`; reduced.md §C0.4 for the registers, §C0.7 for the
relation): `arg d, r` against `Asm.argStore`, `ret src, k` against
`Asm.retLoads k src ++ Asm.epilogue F mode ++ [ret]`.

**Registers.** R's registers at a call boundary are abstract bytes (`R.Regs`, a register not
listed is `Uninit`); they relate to the x86 registers byte for byte as frame bytes do
(`ByteRel`: initialized bytes equal, provenance erased, `Uninit` refined by any byte).
- `argBytes pe x r`: integer argument register `i` is `intArg pe i` (`rdi rsi rdx rcx r8 r9`,
  PE `rcx rdx r8 r9`), 8 bytes; `xmm i` is `xmm{i}`, 16 bytes. `RegRel pe args x r`: R's `r`
  relates to it. `ArgsRel pe args x`: every argument register of the convention (`IsArg`: 6 and
  8, PE 4 and 4) does — what the environment promises at entry. Argument registers get clobbered
  (the inline sequences compute in `rax`/`rcx`, `arg_store` shifts or uses `r11`), so the `arg`
  theorem asks only for its own register's `RegRel` (in canonical code the `arg`s come first);
  `RegRel.congr`/`ArgsRel.congr` carry them over steps that keep the registers.
- `retBytes x r`: return part `gpr 0` is `rax`, `gpr 1` `rdx`, `xmm i` `xmm{i}`; `RetRel regs x`:
  all four relate (a register no part uses is `Uninit` in R).

**`arg_step`.** R's step of `arg d, r` (the scopes, then `(args.get a).take a.size` written at
`d`, for `a = ArgReg.of? r true`), from `RRel s x` and the register's `RegRel`, against
`argStore a d pe`: `RRel s' x'`, `rip` past the items, `s'.pc = s.pc + 1`, `fp` and `args` kept,
the `xmm`s kept, and every register kept but those of `argClobbers` (`r11` for a 2-byte `xmm`, the
argument register itself for an integer stored in pieces, `int_store`'s `shr`s). The pieces
(`exec_piece`, `exec_shr_piece`) compose by `write_split`: two adjacent writes of a value's bytes
are one.

**`ret_step`.** R's step of `ret src, k` ends with `.done (exit s1 (.ret regs incoming))`
(`s1` after the scopes, `RRel s1 x`); the x86 items load each part (`retRegs_parts`: `retRegs`'
parts are `partRegs`', each `partOk` and within 16 bytes; `exec_loads` by induction, the
invariant being that the registers not loaded later already relate), so `RetRel regs x'`; then
the epilogue and `ret` (`exec_epilogue`): `rsp = fp + 16`, `rip` the return address at
`[fp + 8]`, memory unchanged; with a frame pointer or PE the saved `rbp` from `[fp]`; only
`rax rdx r11 rsp rbp` and the flags change. The incoming area relates to the x86 bytes at
`fp + 16`. All three modes are handled; without a frame pointer (`add rsp, F + 8`) and on PE
(`add rsp, F; pop rbp`) the hypothesis `hsp` gives `rsp = fp - F` (the frame's
`lea reg, [rsp + F]` is `fp`), which `RRel` doesn't carry.
That `[fp]` and `[fp + 8]` hold the caller's `rbp` and return address is the caller's side (the
statements give the values in terms of the memory there).

**Hypotheses** beyond the opcode's shape: the 32-bit displacement sums don't overflow
(`d.toInt + a.size ≤ 2^31` for `arg`'s pieces, `src.toInt + 16 ≤ 2^31` for the parts; the frame
offsets of real slots satisfy them).

**Not here**: that the decoder's `argInsn`/`retSeq` produce exactly these operands (`argInsn`
checks `ArgReg.of? a.word true` and the items `argStore a disp pe`; `retSeq` checks
`retLoads k s` and the epilogue), and the register cache.
-/
import Ryo.Proofs.Step

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.ArgRet

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope

/-! ### Bytes -/

theorem leEncode_take : ∀ (m n v : Nat), n ≤ m → (leEncode m v).take n = leEncode n v
  | _, 0, _, _ => by simp [leEncode]
  | 0, n + 1, _, h => absurd h (by omega)
  | m + 1, n + 1, v, h => by simp [leEncode, leEncode_take m n (v / 256) (by omega)]

theorem leEncode_add : ∀ (n k v : Nat), leEncode (n + k) v = leEncode n v ++ leEncode k (v / 2 ^ (8 * n))
  | 0, k, v => by simp [leEncode]
  | n + 1, k, v => by
    rw [show n + 1 + k = (n + k) + 1 by omega]
    simp only [leEncode, leEncode_add n k (v / 256), List.cons_append, Nat.div_div_eq_div_mul]
    congr 3
    rw [Nat.mul_succ, Nat.pow_add, Nat.mul_comm]

theorem leEncode_zero : ∀ (k : Nat), leEncode k 0 = List.replicate k 0
  | 0 => rfl
  | k + 1 => by simp [leEncode, leEncode_zero k, List.replicate_succ]

theorem BytesRel.take : ∀ {bs : List AbstractByte} {xs : List UInt8} (n : Nat), BytesRel bs xs →
    BytesRel (bs.take n) (xs.take n)
  | [], [], _, _ => by rw [List.take_nil, List.take_nil]; trivial
  | [], _ :: _, _, h => (h : False).elim
  | _ :: _, [], _, h => (h : False).elim
  | _ :: _, _ :: _, 0, _ => trivial
  | _ :: _, _ :: _, n + 1, h => ⟨h.1, BytesRel.take n h.2⟩

theorem BytesRel.zeros : ∀ (k : Nat),
    BytesRel (List.replicate k (AbstractByte.ofByte 0)) (List.replicate k 0)
  | 0 => trivial
  | k + 1 => ⟨rfl, BytesRel.zeros k⟩

/-- `Uninit` bytes relate to any bytes of their number. -/
theorem BytesRel.uninit : ∀ (xs : List UInt8), BytesRel (List.replicate xs.length .uninit) xs
  | [] => trivial
  | _ :: xs => ⟨trivial, BytesRel.uninit xs⟩

/-- Bytes zero-extended to `n` (`zext`, a register loaded from a narrower slot) relate to the
`n`-byte encoding of the value of the bytes they extend. -/
theorem bytesRel_zext {bs : List AbstractByte} {xs : List UInt8} {n : Nat} (h : BytesRel bs xs)
    (hn : xs.length ≤ n) : BytesRel (R.zext bs n) (leEncode n (leDecode xs)) := by
  have hl := h.length
  have e : leEncode n (leDecode xs) = xs ++ List.replicate (n - xs.length) 0 := by
    rw [show n = xs.length + (n - xs.length) by omega, leEncode_add, Theorems.leEncode_leDecode,
      Nat.div_eq_of_lt (Theorems.leDecode_lt xs), leEncode_zero]
    congr 2; omega
  rw [e]
  unfold R.zext
  rw [hl]
  exact BytesRel.append (BytesRel.zeros _) h

/-! ### x86 memory writes -/

theorem ofNat_eq_of_mod {a b : Nat} (h : a % 256 = b % 256) : UInt8.ofNat a = UInt8.ofNat b := by
  apply UInt8.toNat_inj.1
  simp [UInt8.toNat_ofNat', h]

theorem mod_div_mod {v n i : Nat} (h : i < n) :
    v % 2 ^ (8 * n) / 2 ^ (8 * i) % 256 = v / 2 ^ (8 * i) % 256 := by
  rw [show 2 ^ (8 * n) = 2 ^ (8 * i) * 2 ^ (8 * (n - i)) by rw [← Nat.pow_add]; congr 1; omega,
    Nat.mod_mul_right_div_self]
  apply Nat.mod_mod_of_dvd
  exact (Nat.pow_dvd_pow 2 (show 8 ≤ 8 * (n - i) by omega))

/-- A write uses only the low `n` bytes of its value. -/
theorem write_mod (m : X86.Mem) (a : BitVec 64) (n v : Nat) :
    m.write a n (v % 2 ^ (8 * n)) = m.write a n v := by
  funext y
  simp only [X86.Mem.write]
  split
  · rename_i h
    apply ofNat_eq_of_mod
    simp only [Nat.shiftRight_eq_div_pow, Nat.pow_mul] at *
    have := mod_div_mod (v := v) h
    simp only [Nat.pow_mul] at this
    exact this
  · rfl

theorem write_zero (m : X86.Mem) (a : BitVec 64) (v : Nat) : m.write a 0 v = m := by
  funext y; simp [X86.Mem.write]

theorem toNat_sub_add (y a : BitVec 64) (n : Nat) (hn : n < 2 ^ 64) :
    (y - (a + BitVec.ofNat 64 n)).toNat =
      if n ≤ (y - a).toNat then (y - a).toNat - n else (y - a).toNat + 2 ^ 64 - n := by
  have : y - (a + BitVec.ofNat 64 n) = (y - a) - BitVec.ofNat 64 n := by
    generalize BitVec.ofNat 64 n = c; bv_omega
  rw [this]
  generalize y - a = t
  have := t.isLt
  rw [BitVec.toNat_sub, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hn]
  split <;> omega

/-- Two adjacent writes, of a value's low `n` bytes and then of the next `k`, are one write of
its `n + k` bytes. -/
theorem write_split (m : X86.Mem) (a : BitVec 64) (n k v : Nat) (h : n + k < 2 ^ 64) :
    (m.write a n v).write (a + BitVec.ofNat 64 n) k (v / 2 ^ (8 * n)) = m.write a (n + k) v := by
  funext y
  simp only [X86.Mem.write]
  rw [toNat_sub_add y a n (by omega)]
  have := (y - a).isLt
  by_cases h1 : (y - a).toNat < n
  · simp only [show ¬ n ≤ (y - a).toNat by omega, ↓reduceIte, show ¬ ((y - a).toNat + 2 ^ 64 - n < k) by omega, h1,
      show (y - a).toNat < n + k by omega]
  · simp only [show n ≤ (y - a).toNat by omega, ↓reduceIte, h1]
    by_cases h2 : (y - a).toNat < n + k
    · simp only [show (y - a).toNat - n < k by omega, h2, ↓reduceIte]
      congr 1
      simp only [Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul, ← Nat.pow_add]
      congr 2; omega
    · simp only [show ¬ ((y - a).toNat - n < k) by omega, h2, ↓reduceIte]

/-! ### R's `arg` and `ret` steps -/

/-- A successful step of `arg d, r`: the scopes, then the write of the register's low bytes. -/
theorem step_arg {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {d : BitVec 32} {r : BitVec 64} {f : Full.Opcode} {o : R.Out}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (h : R.step c s ch = .ok o) :
    ∃ s1 a st', (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      ArgReg.of? r.toNat true = some a ∧
      s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) = .ok st' ∧
      o = .step { s1 with pc := s1.pc + 1, st := st' } := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf, hsh] at h
    cases ha : ArgReg.of? r.toNat true with
    | none => simp [ha, illFormed, throw, throwThe, MonadExceptOf.throw] at h
    | some a =>
      simp only [ha] at h
      cases hw : s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) with
      | error e => simp [hw] at h
      | ok st' =>
        simp only [hw, pure, Except.pure, Except.ok.injEq] at h
        exact ⟨s1, a, st', rfl, rfl, hw, h.symm⟩

/-- A successful step of `ret src, k`: the scopes, then the parts read into the return
registers, the incoming area, and the end of the function. -/
theorem step_ret {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {src : BitVec 32} {k : BitVec 64} {f : Full.Opcode} {o : R.Out}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot src, .imm k])) (hf : op.full = some f)
    (hsh : f.info.shape = .ret) (h : R.step c s ch = .ok o) :
    ∃ s1 parts regs incoming, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.retRegs k.toNat true = .ok parts ∧
      parts.foldlM (init := ({} : R.Regs)) (fun rs (p, r) => do
        pure (rs.set r (R.zext (← s1.st.readFrame (src.toInt + p.off) p.size) r.width))) = .ok regs ∧
      s1.st.readFrame 16 c.argSize = .ok incoming ∧
      o = .done (R.exit s1 (.ret regs incoming)) := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf, hsh] at h
    cases hp : R.retRegs k.toNat true with
    | error e => simp [hp] at h
    | ok parts =>
      simp only [hp] at h
      split at h
      · cases h
      rename_i regs hg
      split at h
      · cases h
      rename_i incoming hin
      simp only [pure, Except.pure, Except.ok.injEq] at h
      exact ⟨s1, parts, regs, incoming, rfl, rfl, hg, hin, h.symm⟩

/-! ### Argument registers and return parts -/

/-- What `ArgReg.of? r true` checks: an `xmm` of 2, 4, 8 or 16 bytes and index below 8, or an
integer register of 1 to 8 bytes and index below 6. -/
theorem argReg_of_spec {r : Nat} {a : ArgReg} (h : ArgReg.of? r true = some a) :
    (a.xmm = true → (a.size = 2 ∨ a.size = 4 ∨ a.size = 8 ∨ a.size = 16) ∧ a.index < 8) ∧
    (a.xmm = false → 1 ≤ a.size ∧ a.size ≤ 8 ∧ a.index < 6) := by
  unfold ArgReg.of? at h
  simp only [Option.ite_none_right_eq_some, Option.some.injEq] at h
  obtain ⟨hok, rfl⟩ := h
  simp only [Bool.and_eq_true, beq_iff_eq] at hok
  obtain ⟨⟨hok, -⟩, -⟩ := hok
  simp only
  generalize (r &&& 32 != 0) = xb at hok ⊢
  generalize r &&& 31 = sz at hok ⊢
  generalize r >>> 8 = ix at hok ⊢
  cases xb <;> simp at hok ⊢ <;> omega

/-- A return part `ret_parts` can load (`load`): an `xmm` part of 2, 4, 8 or 16 bytes, an
integer part of 1, 2, 4 or 8. -/
def partOk (p : RetPart) : Prop :=
  if p.xmm then p.size = 2 ∨ p.size = 4 ∨ p.size = 8 ∨ p.size = 16
  else p.size = 1 ∨ p.size = 2 ∨ p.size = 4 ∨ p.size = 8

/-- `ret_parts`' part decoder (load form). -/
def part1 (b off : Nat) : Option (Option RetPart) :=
  if b &&& 0xc0 != 0 then none else
  if b == 0 then some none else
  let xmm := b &&& 0x20 != 0
  let size := b &&& 0x1f
  let ok := if xmm then size == 2 || size == 4 || size == 8 || size == 16
    else size == 1 || size == 2 || size == 4 || size == 8
  if ok then some (some ⟨xmm, size, off⟩) else none

theorem part1_spec {b off : Nat} {p : RetPart} (h : part1 b off = some (some p)) :
    partOk p ∧ p.off = off := by
  unfold part1 at h
  by_cases h1 : (b &&& 0xc0 != 0) = true
  · simp [h1] at h
  by_cases h2 : (b == 0) = true
  · simp [h1, h2] at h
  simp only [h1, h2, Bool.false_eq_true, ↓reduceIte, Option.ite_none_right_eq_some,
    Option.some.injEq] at h
  obtain ⟨hok, rfl⟩ := h
  refine ⟨?_, rfl⟩
  unfold partOk
  simp only
  generalize (b &&& 0x20 != 0) = xb at hok ⊢
  generalize b &&& 0x1f = sz at hok ⊢
  cases xb <;> simp at hok ⊢ <;> omega

theorem retParts_eq (k : Nat) : retParts k true = (do
    if k >>> 24 != 0 then none
    let a ← part1 (k &&& 0xff) 0
    let b ← part1 (k >>> 8 &&& 0xff) (k >>> 16 &&& 0xff)
    match a, b with
    | none, some _ => none
    | none, none => if k != 0 then none else some (a, b)
    | some a', some b' => if b'.off < a'.size || b'.off + b'.size > 16 then none else some (a, b)
    | some _, none => if k >>> 16 != 0 then none else some (a, b)) := rfl

/-- What `retParts k true` gives: no part, one at offset 0, or two, the second after the first
and within 16 bytes. -/
theorem retParts_spec {k : Nat} {a b : Option RetPart} (h : retParts k true = some (a, b)) :
    (a = none ∧ b = none) ∨ (∃ pa, a = some pa ∧ b = none ∧ partOk pa ∧ pa.off = 0) ∨
    (∃ pa pb, a = some pa ∧ b = some pb ∧ partOk pa ∧ partOk pb ∧ pa.off = 0 ∧
      pa.size ≤ pb.off ∧ pb.off + pb.size ≤ 16) := by
  rw [retParts_eq] at h
  by_cases h24 : (k >>> 24 != 0) = true
  · simp [h24] at h
  cases ha0 : part1 (k &&& 0xff) 0 with
  | none => simp [h24, ha0] at h
  | some a0 =>
    cases hb0 : part1 (k >>> 8 &&& 0xff) (k >>> 16 &&& 0xff) with
    | none => simp [h24, ha0, hb0] at h
    | some b0 =>
      simp only [h24, ha0, hb0, Bool.false_eq_true, ↓reduceIte] at h
      cases a0 with
      | none =>
        cases b0 with
        | none =>
          simp at h
          obtain ⟨-, rfl, rfl⟩ := h
          exact .inl ⟨rfl, rfl⟩
        | some pb => simp at h
      | some pa =>
        obtain ⟨hpa, hoa⟩ := part1_spec ha0
        cases b0 with
        | none =>
          simp at h
          obtain ⟨-, rfl, rfl⟩ := h
          exact .inr (.inl ⟨pa, rfl, rfl, hpa, hoa⟩)
        | some pb =>
          simp at h
          obtain ⟨⟨h1, h2⟩, rfl, rfl⟩ := h
          exact .inr (.inr ⟨pa, pb, rfl, rfl, hpa, (part1_spec hb0).1, hoa, h1, h2⟩)

/-! ### Items, one at a time -/

/-- `xmm{i}` as `Item.exec` names it. -/
def xmmIdx (i : Nat) : Fin 16 := ⟨i % 16, Nat.mod_lt _ (by decide)⟩

theorem execItems_cons_ok {ctx : Ctx} {i : Item} {is : List Item} {s s1 : X86.State}
    (h : i.exec ctx s = .ok s1) : execItems ctx (i :: is) s = execItems ctx is s1 := by
  rw [execItems_cons, h]; rfl

theorem execItems_append (ctx : Ctx) (l1 l2 : List Item) (s : X86.State) :
    execItems ctx (l1 ++ l2) s = (execItems ctx l1 s >>= fun s1 => execItems ctx l2 s1) := by
  simp [execItems, List.foldlM_append]

theorem pow_bits (w : W) : 2 ^ w.bits = 2 ^ (8 * (w.bits / 8)) := by cases w <;> rfl

/-- `mov [m], r` at width `w`: the register's low bytes at `[m]`. -/
theorem exec_st (ctx : Ctx) (w : W) (r : Reg) (m : M) (y : X86.State) :
    ∃ y', (Item.st w r m).exec ctx y = .ok y' ∧
      y'.mem = y.mem.write (y.ea m) (w.bits / 8) (y.reg r).toNat ∧ y'.regs = y.regs ∧
      y'.xmm = y.xmm ∧ y'.rip = y.rip + BitVec.ofNat 64 (Item.st w r m).size := by
  refine ⟨_, rfl, ?_, rfl, rfl, rfl⟩
  simp only [State.setMemW, State.regW, State.setMem, X86S.mem_jump, State.ea, X86S.reg_jump,
    BitVec.toNat_setWidth]
  rw [pow_bits, write_mod]

/-- `shr r, amt` (64 bits). -/
theorem exec_shr (ctx : Ctx) (r : Reg) (amt : BitVec 8) (y : X86.State) :
    ∃ y', (Item.shift .shr .q r amt).exec ctx y = .ok y' ∧ y'.mem = y.mem ∧
      y'.reg r = y.reg r >>> (amt.toNat % 64) ∧ (∀ i, i ≠ r.idx → y'.regs i = y.regs i) ∧
      y'.xmm = y.xmm ∧ y'.rip = y.rip + BitVec.ofNat 64 (Item.shift .shr .q r amt).size := by
  rw [exec_shift]
  refine ⟨_, rfl, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp (config := { contextual := true }) [State.setRegW, State.regW, State.reg, State.setReg,
      W.bits]

/-- `movd r32, xmm{x}`. -/
theorem exec_movd_from (ctx : Ctx) (x : Nat) (r : Reg) (y : X86.State) :
    ∃ y', (Item.movd false x r).exec ctx y = .ok y' ∧ y'.mem = y.mem ∧
      y'.reg r = ((y.xmm (xmmIdx x)).setWidth 32).setWidth 64 ∧
      (∀ i, i ≠ r.idx → y'.regs i = y.regs i) ∧
      y'.xmm = y.xmm ∧ y'.rip = y.rip + BitVec.ofNat 64 (Item.movd false x r).size := by
  refine ⟨_, rfl, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp (config := { contextual := true }) [State.reg, State.setReg, xmmIdx]

/-- `movd xmm{x}, r32`. -/
theorem exec_movd_to (ctx : Ctx) (x : Nat) (r : Reg) (y : X86.State) :
    ∃ y', (Item.movd true x r).exec ctx y = .ok y' ∧ y'.mem = y.mem ∧
      y'.xmm (xmmIdx x) = ((y.reg r).setWidth 32).setWidth 128 ∧
      (∀ j, j ≠ xmmIdx x → y'.xmm j = y.xmm j) ∧
      y'.regs = y.regs ∧ y'.rip = y.rip + BitVec.ofNat 64 (Item.movd true x r).size := by
  refine ⟨_, rfl, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp (config := { contextual := true }) [State.setXmm, xmmIdx]

/-- An SSE store of 4, 8 or 16 bytes. -/
theorem exec_sse_st (ctx : Ctx) (size x : Nat) (m : M) (y : X86.State)
    (hs : size = 4 ∨ size = 8 ∨ size = 16) :
    ∃ y', (Item.sse true size x m).exec ctx y = .ok y' ∧
      y'.mem = y.mem.write (y.ea m) size (y.xmm (xmmIdx x)).toNat ∧ y'.regs = y.regs ∧
      y'.xmm = y.xmm ∧ y'.rip = y.rip + BitVec.ofNat 64 (Item.sse true size x m).size := by
  have : (size != 4 && size != 8 && size != 16) = false := by
    rcases hs with rfl | rfl | rfl <;> rfl
  simp only [Item.exec, this, Bool.false_eq_true, ↓reduceIte, pure, Except.pure, Except.ok.injEq,
    exists_eq_left']
  exact ⟨rfl, rfl, rfl, rfl⟩

/-- An SSE load of 4, 8 or 16 bytes (zero-extended). -/
theorem exec_sse_ld (ctx : Ctx) (size x : Nat) (m : M) (y : X86.State)
    (hs : size = 4 ∨ size = 8 ∨ size = 16) :
    ∃ y', (Item.sse false size x m).exec ctx y = .ok y' ∧ y'.mem = y.mem ∧
      y'.xmm (xmmIdx x) = BitVec.ofNat 128 (y.mem.readNat (y.ea m) size) ∧
      (∀ j, j ≠ xmmIdx x → y'.xmm j = y.xmm j) ∧
      y'.regs = y.regs ∧ y'.rip = y.rip + BitVec.ofNat 64 (Item.sse false size x m).size := by
  have : (size != 4 && size != 8 && size != 16) = false := by
    rcases hs with rfl | rfl | rfl <;> rfl
  simp only [Item.exec, this, Bool.false_eq_true, ↓reduceIte, pure, Except.pure, Except.ok.injEq,
    exists_eq_left']
  refine ⟨rfl, ?_, ?_, rfl, rfl⟩ <;>
    simp (config := { contextual := true }) [State.setXmm, xmmIdx, State.ea]

theorem readNat_lt (m : X86.Mem) (a : BitVec 64) (n : Nat) : m.readNat a n < 2 ^ (8 * n) := by
  have := Theorems.leDecode_lt (bytesAt m a n)
  rw [bytesAt_length] at this
  rw [readNat_eq]; exact this

theorem setWidth_ofNat_small {k : Nat} (v : Nat) (hk : k ≤ 64) (hv : v < 2 ^ k) :
    BitVec.setWidth 64 (BitVec.ofNat k v) = BitVec.ofNat 64 v := by
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_setWidth, BitVec.toNat_ofNat]
  have : 2 ^ k ≤ 2 ^ 64 := Nat.pow_le_pow_right (by decide) hk
  rw [Nat.mod_eq_of_lt hv, Nat.mod_eq_of_lt (by omega)]

/-- `mov`/`movzx r, [m]` (zero-extended) at width `w`. -/
theorem exec_ld (ctx : Ctx) (w : W) (r : Reg) (m : M) (y : X86.State) :
    ∃ y', (Item.ld w false r m).exec ctx y = .ok y' ∧ y'.mem = y.mem ∧
      y'.reg r = BitVec.ofNat 64 (y.mem.readNat (y.ea m) (w.bits / 8)) ∧
      (∀ i, i ≠ r.idx → y'.regs i = y.regs i) ∧
      y'.xmm = y.xmm ∧ y'.rip = y.rip + BitVec.ofNat 64 (Item.ld w false r m).size := by
  cases w <;> refine ⟨_, rfl, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp (config := { contextual := true }) [State.setRegW, State.memW, State.reg, State.setReg,
      State.ea, W.bits] <;>
    exact setWidth_ofNat_small _ (by decide) (readNat_lt _ _ _)

theorem write_mod_of_le (m : X86.Mem) (a : BitVec 64) (n k v : Nat) (h : 8 * n ≤ k) :
    m.write a n (v % 2 ^ k) = m.write a n v := by
  rw [← write_mod m a n (v % 2 ^ k), Nat.mod_mod_of_dvd _ (Nat.pow_dvd_pow 2 h), write_mod]

/-- A frame operand `[rbp + d + o]` (the displacement summed in 32 bits, as `int_store` and
`ret_loads` do) is frame offset `d + o`, when the sum doesn't overflow. -/
theorem ea_off (y : X86.State) (d : BitVec 32) (o : Nat) (ho : o < 2 ^ 31)
    (h : d.toInt + o < 2 ^ 31) :
    y.ea ⟨.rbp, d + BitVec.ofNat 32 o⟩ = fpAddr y d.toInt + BitVec.ofNat 64 o := by
  have hb := toInt_bounds d
  have ho' : (BitVec.ofNat 32 o).toInt = o := by
    simp only [BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat]
    split <;> omega
  have hd : (d + BitVec.ofNat 32 o).toInt = d.toInt + o := by
    rw [BitVec.toInt_add_of_not_saddOverflow]
    · rw [ho']
    · simp only [BitVec.saddOverflow, ho', Bool.or_eq_true, decide_eq_true_eq, not_or]
      omega
  rw [← fpAddr_add, ← hd]; rfl

/-- One piece of a split store (`int_store`): with bytes `[0, o)` of `V` stored at `A` (frame
offset `d`) and `V >>> 8o` in `r`, storing `n` bytes of `r` at `d + o` stores `[0, o + n)`. -/
theorem exec_piece (ctx : Ctx) {w : W} {r : Reg} {d : BitVec 32} {o n V : Nat} {M0 : X86.Mem}
    {x y : X86.State} (hn : w.bits / 8 = n) (ho : o + n ≤ 8) (hd : d.toInt + o < 2 ^ 31)
    (hrbp : y.reg .rbp = x.reg .rbp) (hm : y.mem = M0.write (fpAddr x d.toInt) o V)
    (hr : (y.reg r).toNat = V / 2 ^ (8 * o)) :
    ∃ y', (Item.st w r ⟨.rbp, d + BitVec.ofNat 32 o⟩).exec ctx y = .ok y' ∧
      y'.mem = M0.write (fpAddr x d.toInt) (o + n) V ∧ y'.regs = y.regs ∧ y'.xmm = y.xmm ∧
      y'.rip = y.rip + BitVec.ofNat 64 (Item.st w r ⟨.rbp, d + BitVec.ofNat 32 o⟩).size := by
  obtain ⟨y', e, hm', h1, h2, h3⟩ := exec_st ctx w r ⟨.rbp, d + BitVec.ofNat 32 o⟩ y
  refine ⟨y', e, ?_, h1, h2, h3⟩
  rw [hm', hm, ea_off y d o (by omega) hd, hr, hn]
  have : fpAddr y d.toInt = fpAddr x d.toInt := by simp [fpAddr, hrbp]
  rw [this, write_split _ _ _ _ _ (by omega)]

/-- A shift between pieces: `r` from `V >>> 8o` to `V >>> 8(o + p)`. -/
theorem exec_shr_piece (ctx : Ctx) {r : Reg} {o p V : Nat} {y : X86.State} (hp : 8 * p < 64)
    (hr : (y.reg r).toNat = V / 2 ^ (8 * o)) :
    ∃ y', (Item.shift .shr .q r (BitVec.ofNat 8 (8 * p))).exec ctx y = .ok y' ∧ y'.mem = y.mem ∧
      (y'.reg r).toNat = V / 2 ^ (8 * (o + p)) ∧ (∀ i, i ≠ r.idx → y'.regs i = y.regs i) ∧
      y'.xmm = y.xmm ∧
      y'.rip = y.rip + BitVec.ofNat 64 (Item.shift .shr .q r (BitVec.ofNat 8 (8 * p))).size := by
  obtain ⟨y', e, h1, h2, h3, h4, h5⟩ := exec_shr ctx r (BitVec.ofNat 8 (8 * p)) y
  refine ⟨y', e, h1, ?_, h3, h4, h5⟩
  rw [h2, BitVec.toNat_ushiftRight, hr, BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt (show 8 * p < 2 ^ 8 by omega), Nat.mod_eq_of_lt hp,
    Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul, ← Nat.pow_add, Nat.mul_add]

/-- The registers `arg_store` may change: `r11` for a 2-byte `xmm`, the argument register itself
for an integer split in pieces (shifted between them). -/
def argClobbers (a : ArgReg) (pe : Bool) : List Reg :=
  if a.xmm then (if a.size == 2 then [.r11] else [])
  else if a.size == 1 || a.size == 2 || a.size == 4 || a.size == 8 then [] else [intArg pe a.index]

/-- The value an argument register holds in `x` (`intArg pe i`, or `xmm i`). -/
def argVal (pe : Bool) (x : X86.State) (a : ArgReg) : Nat :=
  if a.xmm then (x.xmm (xmmIdx a.index)).toNat else (x.reg (intArg pe a.index)).toNat

theorem getD_mem {l : List Reg} {i : Nat} : l.getD i .rax = .rax ∨ l.getD i .rax ∈ l := by
  rw [List.getD_eq_getElem?_getD]
  cases h : l[i]? with
  | none => left; rfl
  | some r => right; exact List.mem_of_getElem? h

theorem intArg_mem (pe : Bool) (i : Nat) :
    intArg pe i ∈ [Reg.rax, .rcx, .rdx, .r8, .r9, .rdi, .rsi] := by
  unfold intArg
  split
  · have := getD_mem (l := [Reg.rcx, .rdx, .r8, .r9]) (i := i)
    generalize List.getD _ i _ = g at this ⊢
    simp only [List.mem_cons, List.not_mem_nil, or_false] at this ⊢
    rcases this with h | h | h | h | h <;> simp [h]
  · have := getD_mem (l := [Reg.rdi, .rsi, .rdx, .rcx, .r8, .r9]) (i := i)
    generalize List.getD _ i _ = g at this ⊢
    simp only [List.mem_cons, List.not_mem_nil, or_false] at this ⊢
    rcases this with h | h | h | h | h | h | h <;> simp [h]

theorem intArg_ne_rbp (pe : Bool) (i : Nat) : (intArg pe i).idx ≠ Reg.rbp.idx := by
  have := intArg_mem pe i
  generalize intArg pe i = g at this
  simp only [List.mem_cons, List.not_mem_nil, or_false] at this
  rcases this with h | h | h | h | h | h | h <;> subst h <;> decide

/-- `arg_store`: the low `a.size` bytes of the argument register at frame offset `d`. -/
theorem exec_argStore (ctx : Ctx) (a : ArgReg) (d : BitVec 32) (pe : Bool) (x : X86.State)
    (hv : (a.xmm = true → a.size = 2 ∨ a.size = 4 ∨ a.size = 8 ∨ a.size = 16) ∧
      (a.xmm = false → 1 ≤ a.size ∧ a.size ≤ 8))
    (hd : d.toInt + a.size ≤ 2 ^ 31) :
    ∃ x', execItems ctx (argStore a d pe) x = .ok x' ∧
      x'.mem = x.mem.write (fpAddr x d.toInt) a.size (argVal pe x a) ∧ x'.xmm = x.xmm ∧
      (∀ i : Fin 16, (∀ g ∈ argClobbers a pe, i ≠ g.idx) → x'.regs i = x.regs i) ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((argStore a d pe).map Item.size).sum := by
  obtain ⟨xm, n, idx⟩ := a
  cases xm with
  | true =>
    simp only [forall_const, Bool.true_eq_false, false_implies, and_true] at hv
    simp only [argStore, sseStore, argClobbers, argVal, ↓reduceIte]
    rcases hv with rfl | hv
    · simp only [beq_self_eq_true, ↓reduceIte, List.mem_singleton, forall_eq]
      obtain ⟨y1, e1, m1, r1, rs1, x1, p1⟩ := exec_movd_from ctx idx .r11 x
      obtain ⟨y2, e2, m2, rs2, x2, p2⟩ := exec_st ctx .w .r11 (M.frame d) y1
      refine ⟨y2, by rw [execItems_cons_ok e1, execItems_cons_ok e2]; rfl, ?_, by rw [x2, x1], ?_, ?_⟩
      · rw [m2, m1, ea_frame, r1]
        have : fpAddr y1 d.toInt = fpAddr x d.toInt := by
          simp only [fpAddr, State.reg]; rw [rs1 _ (by decide)]
        rw [this]
        simp only [W.bits, BitVec.toNat_setWidth]
        rw [Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le (Nat.mod_lt _ (by decide)) (by decide) :
          (x.xmm (xmmIdx idx)).toNat % 2 ^ 32 < 2 ^ 64), write_mod_of_le _ _ 2 32 _ (by decide)]
      · intro i hi; rw [rs2, rs1 i hi]
      · rw [p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add]
    · have hs : (n == 2) = false := by rcases hv with rfl | rfl | rfl <;> rfl
      simp only [hs, Bool.false_eq_true, ↓reduceIte, List.not_mem_nil, false_implies,
        implies_true, forall_const]
      obtain ⟨y1, e1, m1, rs1, x1, p1⟩ := exec_sse_st ctx n idx (M.frame d) x hv
      refine ⟨y1, by rw [execItems_cons_ok e1]; rfl, by rw [m1, ea_frame], x1, by rw [rs1]; exact fun _ => rfl, ?_⟩
      rw [p1]; simp
  | false =>
    simp only [Bool.false_eq_true, false_implies, forall_const, true_and] at hv
    simp only [argStore, argClobbers, argVal, Bool.false_eq_true, ↓reduceIte]
    generalize hr : intArg pe idx = r
    have hrbp : (5 : Fin 16) ≠ r.idx := by rw [← hr]; exact (intArg_ne_rbp pe idx).symm
    have hb := toInt_bounds d
    simp only at hd
    have h0 : x.mem = x.mem.write (fpAddr x d.toInt) 0 (x.reg r).toNat := (write_zero ..).symm
    have hr0 : (x.reg r).toNat = (x.reg r).toNat / 2 ^ (8 * 0) := by simp
    -- One store of 1, 2, 4 or 8 bytes.
    have single : ∀ w : W, w.bits / 8 = n → intStore n r (M.frame d) = [.st w r (M.frame d)] →
        ∃ x', execItems ctx (intStore n r (M.frame d)) x = .ok x' ∧
          x'.mem = x.mem.write (fpAddr x d.toInt) n (x.reg r).toNat ∧ x'.xmm = x.xmm ∧
          (∀ i : Fin 16, x'.regs i = x.regs i) ∧
          x'.rip = x.rip + BitVec.ofNat 64 ((intStore n r (M.frame d)).map Item.size).sum := by
      intro w hw he
      rw [he]
      obtain ⟨y1, e1, m1, rs1, x1, p1⟩ := exec_st ctx w r (M.frame d) x
      refine ⟨y1, by rw [execItems_cons_ok e1]; rfl, by rw [m1, ea_frame, hw], x1,
        fun i => by rw [rs1], by rw [p1]; simp⟩
    have hn : n = 1 ∨ n = 2 ∨ n = 4 ∨ n = 8 ∨ n = 3 ∨ n = 5 ∨ n = 6 ∨ n = 7 := by omega
    rcases hn with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · obtain ⟨x', h1, h2, h3, h4, h5⟩ := single .b rfl rfl
      exact ⟨x', h1, h2, h3, fun i _ => h4 i, h5⟩
    · obtain ⟨x', h1, h2, h3, h4, h5⟩ := single .w rfl rfl
      exact ⟨x', h1, h2, h3, fun i _ => h4 i, h5⟩
    · obtain ⟨x', h1, h2, h3, h4, h5⟩ := single .d rfl rfl
      exact ⟨x', h1, h2, h3, fun i _ => h4 i, h5⟩
    · obtain ⟨x', h1, h2, h3, h4, h5⟩ := single .q rfl rfl
      exact ⟨x', h1, h2, h3, fun i _ => h4 i, h5⟩
    · -- 3: `w` at 0, `b` at 2.
      have he : intStore 3 r (M.frame d) = [.st .w r ⟨.rbp, d + BitVec.ofNat 32 0⟩,
          .shift .shr .q r (BitVec.ofNat 8 (8 * 2)), .st .b r ⟨.rbp, d + BitVec.ofNat 32 2⟩] := rfl
      rw [he]
      obtain ⟨y1, e1, m1, rs1, x1, p1⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .w) (o := 0) (n := 2) rfl
        (by omega) (by omega) rfl h0 hr0
      obtain ⟨y2, e2, m2, r2, rs2, x2, p2⟩ := exec_shr_piece ctx (p := 2) (by omega)
        (by rw [State.reg, rs1]; exact hr0)
      obtain ⟨y3, e3, m3, rs3, x3, p3⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .b) (o := 2) (n := 1) rfl
        (by omega) (by omega) (by simp only [State.reg]; rw [show Reg.rbp.idx = 5 from rfl, rs2 _ hrbp, rs1])
        (by rw [m2, m1]) r2
      refine ⟨y3, by rw [execItems_cons_ok e1, execItems_cons_ok e2, execItems_cons_ok e3]; rfl,
        m3, by rw [x3, x2, x1], ?_, by rw [p3, p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add]⟩
      intro i hi
      simp at hi
      rw [rs3, rs2 _ hi, rs1]
    · -- 5: `d` at 0, `b` at 4.
      have he : intStore 5 r (M.frame d) = [.st .d r ⟨.rbp, d + BitVec.ofNat 32 0⟩,
          .shift .shr .q r (BitVec.ofNat 8 (8 * 4)), .st .b r ⟨.rbp, d + BitVec.ofNat 32 4⟩] := rfl
      rw [he]
      obtain ⟨y1, e1, m1, rs1, x1, p1⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .d) (o := 0) (n := 4) rfl
        (by omega) (by omega) rfl h0 hr0
      obtain ⟨y2, e2, m2, r2, rs2, x2, p2⟩ := exec_shr_piece ctx (p := 4) (by omega)
        (by rw [State.reg, rs1]; exact hr0)
      obtain ⟨y3, e3, m3, rs3, x3, p3⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .b) (o := 4) (n := 1) rfl
        (by omega) (by omega) (by simp only [State.reg]; rw [show Reg.rbp.idx = 5 from rfl, rs2 _ hrbp, rs1])
        (by rw [m2, m1]) r2
      refine ⟨y3, by rw [execItems_cons_ok e1, execItems_cons_ok e2, execItems_cons_ok e3]; rfl,
        m3, by rw [x3, x2, x1], ?_, by rw [p3, p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add]⟩
      intro i hi
      simp at hi
      rw [rs3, rs2 _ hi, rs1]
    · -- 6: `d` at 0, `w` at 4.
      have he : intStore 6 r (M.frame d) = [.st .d r ⟨.rbp, d + BitVec.ofNat 32 0⟩,
          .shift .shr .q r (BitVec.ofNat 8 (8 * 4)), .st .w r ⟨.rbp, d + BitVec.ofNat 32 4⟩] := rfl
      rw [he]
      obtain ⟨y1, e1, m1, rs1, x1, p1⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .d) (o := 0) (n := 4) rfl
        (by omega) (by omega) rfl h0 hr0
      obtain ⟨y2, e2, m2, r2, rs2, x2, p2⟩ := exec_shr_piece ctx (p := 4) (by omega)
        (by rw [State.reg, rs1]; exact hr0)
      obtain ⟨y3, e3, m3, rs3, x3, p3⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .w) (o := 4) (n := 2) rfl
        (by omega) (by omega) (by simp only [State.reg]; rw [show Reg.rbp.idx = 5 from rfl, rs2 _ hrbp, rs1])
        (by rw [m2, m1]) r2
      refine ⟨y3, by rw [execItems_cons_ok e1, execItems_cons_ok e2, execItems_cons_ok e3]; rfl,
        m3, by rw [x3, x2, x1], ?_, by rw [p3, p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add]⟩
      intro i hi
      simp at hi
      rw [rs3, rs2 _ hi, rs1]
    · -- 7: `d` at 0, `w` at 4, `b` at 6.
      have he : intStore 7 r (M.frame d) = [.st .d r ⟨.rbp, d + BitVec.ofNat 32 0⟩,
          .shift .shr .q r (BitVec.ofNat 8 (8 * 4)), .st .w r ⟨.rbp, d + BitVec.ofNat 32 4⟩,
          .shift .shr .q r (BitVec.ofNat 8 (8 * 2)), .st .b r ⟨.rbp, d + BitVec.ofNat 32 6⟩] := rfl
      rw [he]
      obtain ⟨y1, e1, m1, rs1, x1, p1⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .d) (o := 0) (n := 4) rfl
        (by omega) (by omega) rfl h0 hr0
      obtain ⟨y2, e2, m2, r2, rs2, x2, p2⟩ := exec_shr_piece ctx (p := 4) (by omega)
        (by rw [State.reg, rs1]; exact hr0)
      obtain ⟨y3, e3, m3, rs3, x3, p3⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .w) (o := 4) (n := 2) rfl
        (by omega) (by omega) (by simp only [State.reg]; rw [show Reg.rbp.idx = 5 from rfl, rs2 _ hrbp, rs1])
        (by rw [m2, m1]) r2
      obtain ⟨y4, e4, m4, r4, rs4, x4, p4⟩ := exec_shr_piece ctx (o := 4) (p := 2) (by omega)
        (by rw [State.reg, rs3]; exact r2)
      obtain ⟨y5, e5, m5, rs5, x5, p5⟩ := exec_piece ctx (x := x) (d := d) (r := r) (M0 := x.mem) (w := .b) (o := 6) (n := 1) rfl
        (by omega) (by omega)
        (by simp only [State.reg]; rw [show Reg.rbp.idx = 5 from rfl, rs4 _ hrbp, rs3, rs2 _ hrbp, rs1])
        (by rw [m4, m3]) r4
      refine ⟨y5, by
          rw [execItems_cons_ok e1, execItems_cons_ok e2, execItems_cons_ok e3,
            execItems_cons_ok e4, execItems_cons_ok e5]; rfl,
        m5, by rw [x5, x4, x3, x2, x1], ?_,
        by rw [p5, p4, p3, p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add]⟩
      intro i hi
      simp at hi
      rw [rs5, rs4 _ hi, rs3, rs2 _ hi, rs1]

theorem rbp_not_clobbered (a : ArgReg) (pe : Bool) : ∀ g ∈ argClobbers a pe, (5 : Fin 16) ≠ g.idx := by
  unfold argClobbers
  split
  · split <;> simp <;> decide
  · split
    · simp
    · simp only [List.mem_singleton, forall_eq]; exact (intArg_ne_rbp pe a.index).symm

/-! ### The argument registers -/

/-- The bytes of the argument register `r` in `x`: integer register `i` is `intArg pe i`
(`rdi rsi rdx rcx r8 r9`, PE `rcx rdx r8 r9`), `xmm i` is `xmm{i}`. -/
def argBytes (pe : Bool) (x : X86.State) : R.Reg → List UInt8
  | .gpr i => leEncode 8 (x.reg (intArg pe i)).toNat
  | .xmm i => leEncode 16 (x.xmm (xmmIdx i)).toNat

/-- The argument registers of the convention: 6 integer and 8 `xmm` (PE: 4 and 4). -/
def IsArg (pe : Bool) : R.Reg → Prop
  | .gpr i => i < (if pe then 4 else 6)
  | .xmm i => i < (if pe then 4 else 8)

/-- R's incoming argument register `r` (abstract bytes) and its x86 register (§C0.7: provenance
erased, `Uninit` refined by any byte). -/
def RegRel (pe : Bool) (args : R.Regs) (x : X86.State) (r : R.Reg) : Prop :=
  BytesRel (args.get r) (argBytes pe x r)

/-- R's incoming argument registers and the x86 registers: every argument register of the
convention relates (at entry, the environment's promise; `arg_step` uses one register's). -/
def ArgsRel (pe : Bool) (args : R.Regs) (x : X86.State) : Prop :=
  ∀ r, IsArg pe r → RegRel pe args x r

/-- `RegRel` sees only the register it is about. -/
theorem RegRel.congr {pe : Bool} {args : R.Regs} {x x' : X86.State} {r : R.Reg}
    (h : RegRel pe args x r)
    (hg : ∀ i, r = .gpr i → x'.regs (intArg pe i).idx = x.regs (intArg pe i).idx)
    (hx : ∀ i, r = .xmm i → x'.xmm (xmmIdx i) = x.xmm (xmmIdx i)) : RegRel pe args x' r := by
  cases r with
  | gpr i => simp only [RegRel, argBytes, State.reg] at h ⊢; rw [hg i rfl]; exact h
  | xmm i => simp only [RegRel, argBytes] at h ⊢; rw [hx i rfl]; exact h

/-- `ArgsRel` is kept by a state change that keeps the argument registers. -/
theorem ArgsRel.congr {pe : Bool} {args : R.Regs} {x x' : X86.State} (h : ArgsRel pe args x)
    (hg : ∀ i, i < (if pe then 4 else 6) → x'.regs (intArg pe i).idx = x.regs (intArg pe i).idx)
    (hx : ∀ i, i < (if pe then 4 else 8) → x'.xmm (xmmIdx i) = x.xmm (xmmIdx i)) :
    ArgsRel pe args x' := fun r hr =>
  (h r hr).congr (fun i e => by subst e; exact hg i hr) (fun i e => by subst e; exact hx i hr)

theorem argBytes_ofArgReg (pe : Bool) (x : X86.State) (a : ArgReg) :
    argBytes pe x (.ofArgReg a) = leEncode (R.Reg.ofArgReg a).width (argVal pe x a) := by
  unfold R.Reg.ofArgReg argVal
  cases a.xmm <;> rfl

/-! ### `arg` -/

/-- One R step of `arg d, r` (the store of argument register `a`'s low `a.size` bytes at frame
offset `d`, after the scopes) against `argStore a d pe`, given that the x86 register still
holds the incoming value (`harg`; in canonical code the `arg`s come first). The registers
`argClobbers` lists may change, and the flags. -/
theorem arg_step (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {d : BitVec 32} {r : BitVec 64} {f : Full.Opcode} {a : ArgReg}
    (hr : RRel s x) (hi : c.d.insns[s.pc]? = some (.native op [.slot d, .imm r]))
    (hf : op.full = some f) (hsh : f.info.shape = .arg) (ha : ArgReg.of? r.toNat true = some a)
    (hd : d.toInt + a.size ≤ 2 ^ 31) (harg : RegRel c.mode.pe s.args x (.ofArgReg a))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (argStore a d c.mode.pe) x = .ok x' ∧ RRel s' x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((argStore a d c.mode.pe).map Item.size).sum ∧
      s'.pc = s.pc + 1 ∧ s'.fp = s.fp ∧ s'.args = s.args ∧ x'.xmm = x.xmm ∧
      (∀ i : Fin 16, (∀ g ∈ argClobbers a c.mode.pe, i ≠ g.idx) → x'.regs i = x.regs i) := by
  obtain ⟨s1, a', st', hsc, ha', hw, ho⟩ := step_arg hi hf hsh h
  rw [ha] at ha'
  cases ha'
  cases ho
  have hr1 := rrel_scopes hr hsc
  have hk := scopes_keeps _ hsc
  have hspec := argReg_of_spec ha
  obtain ⟨x', hx, hm, hxm, hregs, hrip⟩ := exec_argStore ctx a d c.mode.pe x
    ⟨fun h => (hspec.1 h).1, fun h => ⟨(hspec.2 h).1, (hspec.2 h).2.1⟩⟩ hd
  have hw' : a.size ≤ (R.Reg.ofArgReg a).width := by
    unfold R.Reg.ofArgReg R.Reg.width
    cases hxa : a.xmm
    · have := (hspec.2 hxa).2.1; simp; omega
    · have := (hspec.1 hxa).1; simp; omega
  have hbs : BytesRel ((s1.args.get (.ofArgReg a)).take a.size)
      (leEncode a.size (argVal c.mode.pe x a)) := by
    have := BytesRel.take a.size harg
    unfold RegRel at this
    rw [argBytes_ofArgReg, leEncode_take _ _ _ hw', ← hk.args] at this
    exact this
  have hlen : ((s1.args.get (.ofArgReg a)).take a.size).length = a.size := by
    rw [hbs.length, leEncode_length]
  have hb := toInt_bounds d
  have hrbp : x'.reg .rbp = x.reg .rbp := by
    simp only [State.reg]; exact hregs 5 (rbp_not_clobbered a c.mode.pe)
  obtain ⟨hrel, h1, h2, h3, h4, h5⟩ := rel_store hr1.rel hw (by omega) (by omega)
    (by rw [hlen]; exact hbs) hrbp (by rw [hm, hlen])
  refine ⟨x', hx, ⟨hrel, by rw [hrbp]; exact hr1.rbp, escWF_of_sameButWrites hr1.wf
    ⟨h2, h1, h3, h4, h5⟩⟩, hrip, by simp [hk.pc], hk.fp, hk.args, hxm, hregs⟩

/-! ### Return registers -/

theorem Regs.get_set_self (rs : R.Regs) (r : R.Reg) (bs : List AbstractByte) :
    (rs.set r bs).get r = bs := by
  unfold R.Regs.get R.Regs.set
  simp only
  rw [List.find?_append]
  have : (rs.vals.filter (·.1 != r)).find? (·.1 == r) = none := by
    rw [List.find?_eq_none]
    intro q hq
    have := (List.mem_filter.1 hq).2
    simp only [bne_iff_ne, ne_eq] at this
    simpa using this
  rw [this]
  simp

theorem Regs.get_set_other (rs : R.Regs) {r r' : R.Reg} (bs : List AbstractByte) (h : r' ≠ r) :
    (rs.set r bs).get r' = rs.get r' := by
  unfold R.Regs.get R.Regs.set
  simp only
  rw [List.find?_append]
  cases hf : rs.vals.find? (·.1 == r') with
  | some e =>
    have he := List.find?_some hf
    rw [find?_filter_of_some hf (by simp only [beq_iff_eq] at he; simp [he, h])]
    rfl
  | none =>
    rw [find?_filter_of_none hf]
    have : ([(r, bs)] : List (R.Reg × List AbstractByte)).find? (·.1 == r') = none := by
      simp [Ne.symm h]
    rw [this]
    rfl

theorem Regs.get_empty (r : R.Reg) : ({} : R.Regs).get r = List.replicate r.width .uninit := rfl

/-- The return registers' x86 homes: integer part `i` in `rax` (0) or `rdx`, `xmm` part `i` in
`xmm{i}`. -/
def retX86 : R.Reg → Reg
  | .gpr i => if i = 0 then .rax else .rdx
  | .xmm _ => .r11

def retXmm : R.Reg → Nat
  | .gpr _ => 0
  | .xmm i => i

/-- The bytes of return register `r` in `x`. -/
def retBytes (x : X86.State) : R.Reg → List UInt8
  | .gpr i => leEncode 8 (x.reg (if i = 0 then .rax else .rdx)).toNat
  | .xmm i => leEncode 16 (x.xmm (xmmIdx i)).toNat

/-- The return registers. -/
def retRegList : List R.Reg := [.gpr 0, .gpr 1, .xmm 0, .xmm 1]

/-- R's return registers and the x86 ones (`rax`, `rdx`, `xmm0`, `xmm1`): each relates byte for
byte (§C0.7); a register no part uses is `Uninit` in R, which relates to anything. -/
def RetRel (regs : R.Regs) (x : X86.State) : Prop :=
  ∀ r ∈ retRegList, BytesRel (regs.get r) (retBytes x r)

/-- A part's register: an integer part in `rax`/`rdx`, an `xmm` part in `xmm0`/`xmm1`. -/
def RegFor (p : RetPart) (r : R.Reg) : Prop :=
  (p.xmm = false ∧ (r = .gpr 0 ∨ r = .gpr 1)) ∨ (p.xmm = true ∧ (r = .xmm 0 ∨ r = .xmm 1))

/-- `ret_loads`' items for one part (`retLoads`' function). -/
def loadItems (src : BitVec 32) : RetPart × Reg × Nat → List Item := fun (p, r, x) =>
  let m := frameAt src p.off
  if !p.xmm then [.ld (widthOf p.size) false r m]
  else if p.size == 2 then [.ld .w false .r11 m, .movd true x .r11]
  else [.sse false p.size x m]

theorem retLoads_eq (k : Nat) (src : BitVec 32) :
    retLoads k src = (partRegs k true).flatMap (loadItems src) := rfl

/-- A part's loads into R register `r`'s home. -/
def loadR (src : BitVec 32) (q : RetPart × R.Reg) : List Item :=
  loadItems src (q.1, retX86 q.2, retXmm q.2)

theorem setWidth_ofNat_128 (v : Nat) (hv : v < 2 ^ 16) :
    BitVec.setWidth 128 (BitVec.setWidth 32 (BitVec.ofNat 64 v)) = BitVec.ofNat 128 v := by
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_setWidth, BitVec.toNat_ofNat]
  omega

theorem fpAddr_frameAt (y : X86.State) (src : BitVec 32) (off : Nat) (ho : off < 16)
    (hs : src.toInt + 16 ≤ 2 ^ 31) :
    y.ea (frameAt src off) = fpAddr y (src.toInt + off) := by
  have hb := toInt_bounds src
  unfold frameAt M.frame
  rw [ea_off y src off (by omega) (by omega), fpAddr_add]

/-- An integer part's load (`mov`/`movzx`): its bytes, zero-extended, in `r`. -/
theorem exec_loadInt (ctx : Ctx) (src : BitVec 32) (p : RetPart) (r : Reg) (xi : Nat)
    (y : X86.State) (hx : p.xmm = false)
    (hp : p.size = 1 ∨ p.size = 2 ∨ p.size = 4 ∨ p.size = 8) (hoff : p.off + p.size ≤ 16)
    (hs : src.toInt + 16 ≤ 2 ^ 31) :
    ∃ y', execItems ctx (loadItems src (p, r, xi)) y = .ok y' ∧ y'.mem = y.mem ∧
      y'.rip = y.rip + BitVec.ofNat 64 ((loadItems src (p, r, xi)).map Item.size).sum ∧
      y'.reg r = BitVec.ofNat 64 (leDecode (bytesAt y.mem (fpAddr y (src.toInt + p.off)) p.size)) ∧
      (∀ i, i ≠ r.idx → y'.regs i = y.regs i) ∧ y'.xmm = y.xmm := by
  have hea := fpAddr_frameAt y src p.off (by omega) hs
  obtain ⟨y1, e1, m1, r1, rs1, x1, p1⟩ := exec_ld ctx (widthOf p.size) r (frameAt src p.off) y
  have hw : (widthOf p.size).bits / 8 = p.size := by
    rcases hp with h | h | h | h <;> rw [h] <;> rfl
  have he : loadItems src (p, r, xi) = [.ld (widthOf p.size) false r (frameAt src p.off)] := by
    simp [loadItems, hx]
  rw [he]
  refine ⟨y1, by rw [execItems_cons_ok e1]; rfl, m1, by rw [p1]; simp, ?_, rs1, x1⟩
  rw [r1, hw, hea, readNat_eq]

/-- An `xmm` part's load (`movss`/`movsd`/`movups`, or a 2-byte one through `r11` and `movd`):
its bytes, zero-extended, in `xmm{xi}`. -/
theorem exec_loadXmm (ctx : Ctx) (src : BitVec 32) (p : RetPart) (r : Reg) (xi : Nat)
    (y : X86.State) (hx : p.xmm = true)
    (hp : p.size = 2 ∨ p.size = 4 ∨ p.size = 8 ∨ p.size = 16) (hoff : p.off + p.size ≤ 16)
    (hs : src.toInt + 16 ≤ 2 ^ 31) :
    ∃ y', execItems ctx (loadItems src (p, r, xi)) y = .ok y' ∧ y'.mem = y.mem ∧
      y'.rip = y.rip + BitVec.ofNat 64 ((loadItems src (p, r, xi)).map Item.size).sum ∧
      y'.xmm (xmmIdx xi) =
        BitVec.ofNat 128 (leDecode (bytesAt y.mem (fpAddr y (src.toInt + p.off)) p.size)) ∧
      (∀ j, j ≠ xmmIdx xi → y'.xmm j = y.xmm j) ∧
      (∀ i, i ≠ Reg.r11.idx → y'.regs i = y.regs i) := by
  have hea := fpAddr_frameAt y src p.off (by omega) hs
  by_cases h2 : p.size = 2
  · have he : loadItems src (p, r, xi) =
        [.ld .w false .r11 (frameAt src p.off), .movd true xi .r11] := by
      simp [loadItems, hx, h2]
    rw [he]
    obtain ⟨y1, e1, m1, r1, rs1, x1, p1⟩ := exec_ld ctx .w .r11 (frameAt src p.off) y
    obtain ⟨y2, e2, m2, r2, rs2, x2, p2⟩ := exec_movd_to ctx xi .r11 y1
    refine ⟨y2, by rw [execItems_cons_ok e1, execItems_cons_ok e2]; rfl, by rw [m2, m1],
      by rw [p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add], ?_, ?_, ?_⟩
    · rw [r2, r1, hea, readNat_eq, h2]
      apply setWidth_ofNat_128
      have := Theorems.leDecode_lt (bytesAt y.mem (fpAddr y (src.toInt + p.off)) 2)
      rw [bytesAt_length] at this; exact this
    · intro j hj; rw [rs2 j hj, x1]
    · intro i hi; rw [x2, rs1 i hi]
  · have hp' : p.size = 4 ∨ p.size = 8 ∨ p.size = 16 := by omega
    have he : loadItems src (p, r, xi) = [.sse false p.size xi (frameAt src p.off)] := by
      simp [loadItems, hx, h2]
    rw [he]
    obtain ⟨y1, e1, m1, r1, x1, rs1, p1⟩ := exec_sse_ld ctx p.size xi (frameAt src p.off) y hp'
    refine ⟨y1, by rw [execItems_cons_ok e1]; rfl, m1, by rw [p1]; simp, ?_, x1, by rw [rs1]; exact fun _ _ => rfl⟩
    rw [r1, hea, readNat_eq]

/-- One part's loads: the part's `size` bytes at frame offset `src + off`, zero-extended, in its
register; memory unchanged; at most `rax`, `rdx`, `r11` and the `xmm`s changed, and the other
return registers kept. -/
theorem exec_loadPart (ctx : Ctx) (src : BitVec 32) (p : RetPart) (rr : R.Reg) (y : X86.State)
    (hp : partOk p) (hfor : RegFor p rr) (hoff : p.off + p.size ≤ 16)
    (hs : src.toInt + 16 ≤ 2 ^ 31) :
    ∃ y', execItems ctx (loadR src (p, rr)) y = .ok y' ∧ y'.mem = y.mem ∧
      y'.rip = y.rip + BitVec.ofNat 64 ((loadR src (p, rr)).map Item.size).sum ∧
      (∀ i : Fin 16, i ≠ 0 → i ≠ 2 → i ≠ 11 → y'.regs i = y.regs i) ∧
      retBytes y' rr = leEncode rr.width
        (leDecode (bytesAt y.mem (fpAddr y (src.toInt + p.off)) p.size)) ∧
      (∀ r' ∈ retRegList, r' ≠ rr → retBytes y' r' = retBytes y r') := by
  have hlt := Theorems.leDecode_lt (bytesAt y.mem (fpAddr y (src.toInt + p.off)) p.size)
  rw [bytesAt_length] at hlt
  unfold partOk at hp
  rcases hfor with ⟨hx, hr⟩ | ⟨hx, hr⟩ <;> simp only [hx, ↓reduceIte, Bool.false_eq_true] at hp
  · have hlt' : leDecode (bytesAt y.mem (fpAddr y (src.toInt + p.off)) p.size) < 2 ^ 64 :=
      Nat.lt_of_lt_of_le hlt (Nat.pow_le_pow_right (by decide) (by omega))
    obtain ⟨y', e, m, pr, rv, rs, xm⟩ := exec_loadInt ctx src p (retX86 rr) (retXmm rr) y hx hp hoff hs
    refine ⟨y', e, m, pr, ?_, ?_, ?_⟩ <;>
      rcases hr with rfl | rfl <;> simp only [retX86, ↓reduceIte, Nat.one_ne_zero] at rv rs ⊢
    · intro i h0 _ _; exact rs i h0
    · intro i _ h2 _; exact rs i h2
    · simp only [retBytes, ↓reduceIte, R.Reg.width, rv, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt']
    · simp only [retBytes, Nat.one_ne_zero, ↓reduceIte, R.Reg.width, rv, BitVec.toNat_ofNat,
        Nat.mod_eq_of_lt hlt']
    all_goals
      intro r' hr' hne
      simp only [retRegList, List.mem_cons, List.not_mem_nil, or_false] at hr'
      rcases hr' with rfl | rfl | rfl | rfl <;> simp_all [retBytes, State.reg] <;>
        rw [rs _ (by decide)]
  · have hlt' : leDecode (bytesAt y.mem (fpAddr y (src.toInt + p.off)) p.size) < 2 ^ 128 :=
      Nat.lt_of_lt_of_le hlt (Nat.pow_le_pow_right (by decide) (by omega))
    obtain ⟨y', e, m, pr, xv, xs, rs⟩ := exec_loadXmm ctx src p (retX86 rr) (retXmm rr) y hx hp hoff hs
    refine ⟨y', e, m, pr, fun i _ _ h11 => rs i h11, ?_, ?_⟩ <;>
      rcases hr with rfl | rfl <;> simp only [retXmm] at xv xs ⊢
    · simp only [retBytes, R.Reg.width, xv, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt']
    · simp only [retBytes, R.Reg.width, xv, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt']
    all_goals
      intro r' hr' hne
      simp only [retRegList, List.mem_cons, List.not_mem_nil, or_false] at hr'
      rcases hr' with rfl | rfl | rfl | rfl <;> simp_all [retBytes, State.reg] <;>
        first | rw [xs _ (by decide)] | rw [rs _ (by decide)]

theorem partOk_width {p : RetPart} {rr : R.Reg} (hp : partOk p) (hfor : RegFor p rr) :
    p.size ≤ rr.width := by
  unfold partOk at hp
  rcases hfor with ⟨hx, hr | hr⟩ | ⟨hx, hr | hr⟩ <;> subst hr <;>
    simp only [hx, ↓reduceIte, Bool.false_eq_true, R.Reg.width] at hp ⊢ <;> omega

/-- The loads of the parts `L` (each `partOk`, in its register, within 16 bytes) against R's
fold over them: the return registers relate, given that those not loaded already did. -/
theorem exec_loads (ctx : Ctx) (st : OpSem.State) (src : BitVec 32) (x : X86.State)
    (hrel : Rel st x) (hs : src.toInt + 16 ≤ 2 ^ 31) :
    ∀ (L : List (RetPart × R.Reg)) (rs regs : R.Regs) (y : X86.State),
      (∀ q ∈ L, partOk q.1 ∧ RegFor q.1 q.2 ∧ q.1.off + q.1.size ≤ 16) →
      L.foldlM (init := rs) (fun rs (p, r) => do
        pure (rs.set r (R.zext (← st.readFrame (src.toInt + p.off) p.size) r.width))) = .ok regs →
      y.mem = x.mem → y.reg .rbp = x.reg .rbp →
      (∀ r ∈ retRegList, r ∉ L.map (·.2) → BytesRel (rs.get r) (retBytes y r)) →
      ∃ y', execItems ctx (L.flatMap (loadR src)) y = .ok y' ∧ y'.mem = x.mem ∧
        (∀ i : Fin 16, i ≠ 0 → i ≠ 2 → i ≠ 11 → y'.regs i = y.regs i) ∧
        y'.rip = y.rip + BitVec.ofNat 64 ((L.flatMap (loadR src)).map Item.size).sum ∧
        RetRel regs y'
  | [], rs, regs, y, _, hf, hm, _, hinv => by
    simp only [List.foldlM_nil, pure, Except.pure, Except.ok.injEq] at hf
    subst hf
    exact ⟨y, rfl, hm, fun _ _ _ _ => rfl, by simp, fun r hr => hinv r hr (by simp)⟩
  | (p, rr) :: L, rs, regs, y, hL, hf, hm, hb, hinv => by
    simp only [List.foldlM_cons] at hf
    cases hrd : st.readFrame (src.toInt + p.off) p.size with
    | error e => simp [hrd, bind, Except.bind] at hf
    | ok bs =>
      simp only [hrd, bind, Except.bind, pure, Except.pure] at hf
      obtain ⟨hp, hfor, hoff⟩ := hL (p, rr) (by simp)
      simp only at hp hfor hoff
      obtain ⟨y1, e1, m1, p1, rs1, rb1, ro1⟩ := exec_loadPart ctx src p rr y hp hfor hoff hs
      have hsb := toInt_bounds src
      have hbs := readFrame_rel hrel hrd (by omega) (by omega)
      have hfp : fpAddr y (src.toInt + p.off) = fpAddr x (src.toInt + p.off) := by
        simp [fpAddr, hb]
      have hz : BytesRel (R.zext bs rr.width) (retBytes y1 rr) := by
        rw [rb1, hm, hfp]
        exact bytesRel_zext hbs (by rw [bytesAt_length]; exact partOk_width hp hfor)
      have hrbp1 : y1.reg .rbp = x.reg .rbp := by
        simp only [State.reg] at hb ⊢
        rw [show Reg.rbp.idx = 5 from rfl, rs1 5 (by decide) (by decide) (by decide)]; exact hb
      obtain ⟨y2, e2, m2, rs2, p2, hrr⟩ := exec_loads ctx st src x hrel hs L
        (rs.set rr (R.zext bs rr.width)) regs y1 (fun q hq => hL q (by simp [hq])) hf
        (m1.trans hm) hrbp1 (fun r hr hn => by
          by_cases he : r = rr
          · subst he; rw [Regs.get_set_self]; exact hz
          · rw [Regs.get_set_other _ _ he, ro1 r hr he]
            exact hinv r hr (by simp [he, hn]))
      refine ⟨y2, ?_, m2, fun i h0 h2 h11 => by rw [rs2 i h0 h2 h11, rs1 i h0 h2 h11], ?_, hrr⟩
      · rw [List.flatMap_cons, execItems_append, e1]; exact e2
      · rw [p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add]

/-- `retRegs`' parts are `partRegs`' (`retLoads` loads them into their registers), each loadable
and within 16 bytes. -/
theorem retRegs_parts {k : Nat} {parts : List (RetPart × R.Reg)}
    (h : R.retRegs k true = .ok parts) (src : BitVec 32) :
    retLoads k src = parts.flatMap (loadR src) ∧
      ∀ q ∈ parts, partOk q.1 ∧ RegFor q.1 q.2 ∧ q.1.off + q.1.size ≤ 16 := by
  unfold R.retRegs at h
  cases hk : retParts k true with
  | none => simp [hk, illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some ab =>
    obtain ⟨a, b⟩ := ab
    simp only [hk, pure, Except.pure, Except.ok.injEq] at h
    subst h
    rw [retLoads_eq]
    unfold partRegs
    rw [hk]
    rcases retParts_spec hk with ⟨rfl, rfl⟩ | ⟨pa, rfl, rfl, hpa, hoa⟩ |
      ⟨pa, pb, rfl, rfl, hpa, hpb, hoa, h1, h2⟩
    · simp
    · have hs : pa.size ≤ 16 := by
        unfold partOk at hpa; split at hpa <;> omega
      cases hx : pa.xmm <;>
        simp [hx, loadR, loadItems, retX86, retXmm, RegFor, hpa, hoa, hs]
    · have hs : pa.size ≤ 16 := by
        unfold partOk at hpa; split at hpa <;> omega
      cases hx : pa.xmm <;> cases hy : pb.xmm <;>
        simp [hx, hy, loadR, loadItems, retX86, retXmm, RegFor, hpa, hpb, hoa, hs, h2]

/-! ### The epilogue and `ret` -/

@[simp] theorem idx_rsp : Reg.idx .rsp = 4 := rfl
@[simp] theorem idx_rsi : Reg.idx .rsi = 6 := rfl
@[simp] theorem idx_rdi : Reg.idx .rdi = 7 := rfl

theorem signExtend_ofNat_small (v : Nat) (h : v < 2 ^ 31) :
    (BitVec.ofNat 32 v).signExtend 64 = BitVec.ofNat 64 v := by
  apply BitVec.eq_of_toInt_eq
  rw [BitVec.toInt_signExtend_of_le (by decide)]
  simp only [BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat]
  split <;> split <;> omega

/-- The epilogue (`leave`; PE: `add rsp, F; pop rbp`, from `rsp = fp - F`; without a frame
pointer: `add rsp, F + 8`, from `rsp = fp - F`) and `ret`: the return address at `fp + 8`
jumped to, `rsp = fp + 16`, the saved `rbp` restored; nothing else changed but the flags. -/
theorem exec_epilogue (ctx : Ctx) (F : Nat) (m : Ryo.Obj.Mode) (y : X86.State)
    (hsp : m.pe = true ∨ m.framePointer = false →
      y.rsp = y.reg .rbp - BitVec.ofNat 64 F ∧ F + 8 < 2 ^ 31) :
    ∃ y', execItems ctx (epilogue F m ++ [.ret]) y = .ok y' ∧ y'.mem = y.mem ∧ y'.xmm = y.xmm ∧
      y'.rsp = y.reg .rbp + 16 ∧ y'.rip = y.mem.read64 (y.reg .rbp + 8) ∧
      (∀ i : Fin 16, i ≠ 4 → i ≠ 5 → y'.regs i = y.regs i) ∧
      (m.pe = true ∨ m.framePointer = true → y'.reg .rbp = y.mem.read64 (y.reg .rbp)) ∧
      (m.pe = false → m.framePointer = false → y'.reg .rbp = y.reg .rbp) := by
  have ea : ∀ a b : BitVec 64, (addF a b).1 = a + b := fun _ _ => rfl
  unfold epilogue
  cases hpe : m.pe <;> cases hfp : m.framePointer <;>
    simp only [hpe, hfp, Bool.false_eq_true, ↓reduceIte, true_or, or_true, or_false,
      false_implies, forall_const, true_implies] at hsp ⊢
  -- PE: `add rsp, F` (for `F > 0`) and `pop rbp`, from `rsp = fp - F`.
  case true.false | true.true =>
    obtain ⟨hr, hF⟩ := hsp
    simp only [State.rsp, State.reg, idx_rsp, idx_rbp] at hr
    by_cases hF0 : F = 0
    · subst hF0
      simp only [bne_self_eq_false, Bool.false_eq_true, ↓reduceIte, List.nil_append,
        List.cons_append, execItems_cons, execItems_nil, Item.exec, pure, Except.pure, ex_bind_ok']
      refine ⟨_, rfl, ?_⟩
      simp (config := { decide := true }) [State.pop, State.rsp, State.reg, State.setReg, State.jump]
      simp only [BitVec.ofNat_eq_ofNat, BitVec.sub_zero] at hr
      simp only [hr, idx_rbp]
      and_intros
      all_goals first
        | (intro i h4 h5; simp [h4, h5])
        | (congr 1; bv_omega)
        | bv_omega
    · have hne : (F != 0) = true := by simpa using hF0
      simp only [hne, ↓reduceIte, List.cons_append, List.singleton_append, execItems_cons,
        execItems_nil, Item.exec, pure, Except.pure, ex_bind_ok']
      refine ⟨_, rfl, ?_⟩
      simp (config := { decide := true }) [State.pop, State.rsp, State.reg, State.setReg,
        State.setFlags, State.jump]
      simp only [ea, idx_rbp]
      rw [hr, signExtend_ofNat_small _ (by omega)]
      and_intros
      all_goals first
        | (intro i h4 h5; simp [h4, h5])
        | (congr 1; bv_omega)
        | bv_omega
  all_goals
    simp only [List.cons_append, List.nil_append, execItems_cons, execItems_nil, Item.exec, pure,
      Except.pure, ex_bind_ok']
    refine ⟨_, rfl, ?_⟩
    simp (config := { decide := true }) [State.pop, State.rsp, State.reg, State.setReg,
      State.setFlags, State.jump]
    try simp only [ea]
  case false.false =>
    obtain ⟨hr, hF⟩ := hsp
    simp only [State.rsp, State.reg, idx_rsp, idx_rbp] at hr
    rw [hr, signExtend_ofNat_small _ (by omega), BitVec.ofNat_add]
    and_intros
    · bv_omega
    · congr 1; bv_omega
    · intro i h4 h5; simp [h4]
  all_goals
    and_intros <;>
    first
      | exact True.intro
      | (intro i h4 h5; simp [h4, h5])
      | bv_omega
      | (congr 1; bv_omega)

theorem uninit_retBytes (r : R.Reg) (y : X86.State) :
    BytesRel (List.replicate r.width .uninit) (retBytes y r) := by
  have := BytesRel.uninit (retBytes y r)
  cases r <;> simpa [retBytes, R.Reg.width, leEncode_length] using this

theorem retBytes_congr {x y : X86.State} (h0 : x.regs 0 = y.regs 0) (h2 : x.regs 2 = y.regs 2)
    (hx : x.xmm = y.xmm) (r : R.Reg) : retBytes x r = retBytes y r := by
  cases r with
  | gpr i =>
    by_cases hi : i = 0
    · simp [retBytes, State.reg, hi, h0]
    · simp only [retBytes, State.reg, hi, ↓reduceIte]
      rw [show Reg.rdx.idx = 2 from rfl, h2]
  | xmm i => simp [retBytes, hx]

/-! ### `ret` -/

/-- One R step of `ret src, k` (after the scopes: the parts of `k` read from `src` into the
return registers, zero-extended, the incoming area read, and the function's end) against
`retLoads k src ++ epilogue F mode ++ [ret]`: the x86 return registers relate to R's (`RetRel`),
memory is unchanged, `rsp` is the frame's `fp + 16` (the caller's, past the return address)
and `rip` the return address at `fp + 8`; with a frame pointer (or PE) the saved `rbp` is
restored from `[fp]`. Without a frame pointer and on PE, `hsp` gives `rsp = fp - F` (`F` the
frame size: `lea reg, [rsp + F]` is `fp`; PE's epilogue is `add rsp, F; pop rbp`). Only `rax`,
`rdx`, `r11`, `rsp`, `rbp` and the flags change. -/
theorem ret_step (ctx : Ctx) (F : Nat) {c : R.Code} {s : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {src : BitVec 32} {k : BitVec 64}
    {f : Full.Opcode} {fin : R.Final} (hr : RRel s x)
    (hi : c.d.insns[s.pc]? = some (.native op [.slot src, .imm k])) (hf : op.full = some f)
    (hsh : f.info.shape = .ret) (hsrc : src.toInt + 16 ≤ 2 ^ 31)
    (hsp : c.mode.pe = true ∨ c.mode.framePointer = false →
      x.rsp = x.reg .rbp - BitVec.ofNat 64 F ∧ F + 8 < 2 ^ 31)
    (h : R.step c s ch = .ok (.done fin)) :
    ∃ s1 regs incoming x', RRel s1 x ∧ s1.fp = s.fp ∧ s1.args = s.args ∧
      fin = R.exit s1 (.ret regs incoming) ∧
      s1.st.readFrame 16 c.argSize = .ok incoming ∧
      (16 + c.argSize ≤ 2 ^ 63 → BytesRel incoming (bytesAt x.mem (fpAddr x 16) c.argSize)) ∧
      execItems ctx (retLoads k.toNat src ++ (epilogue F c.mode ++ [.ret])) x = .ok x' ∧
      RetRel regs x' ∧ x'.mem = x.mem ∧
      x'.rsp = x.reg .rbp + 16 ∧ x'.rip = x.mem.read64 (x.reg .rbp + 8) ∧
      (c.mode.pe = true ∨ c.mode.framePointer = true → x'.reg .rbp = x.mem.read64 (x.reg .rbp)) ∧
      (c.mode.pe = false → c.mode.framePointer = false → x'.reg .rbp = x.reg .rbp) ∧
      (∀ i : Fin 16, i ≠ 0 → i ≠ 2 → i ≠ 11 → i ≠ 4 → i ≠ 5 → x'.regs i = x.regs i) := by
  obtain ⟨s1, parts, regs, incoming, hsc, hp, hg, hin, ho⟩ := step_ret hi hf hsh h
  simp only [R.Out.done.injEq] at ho
  subst ho
  have hr1 := rrel_scopes hr hsc
  have hk := scopes_keeps _ hsc
  obtain ⟨hl, hq⟩ := retRegs_parts hp src
  obtain ⟨y, ey, my, ry, py, hrr⟩ := exec_loads ctx s1.st src x hr1.rel hsrc parts {} regs x hq
    hg rfl rfl (fun r _ _ => by rw [Regs.get_empty]; exact uninit_retBytes r x)
  have hy4 : y.regs 4 = x.regs 4 := ry 4 (by decide) (by decide) (by decide)
  have hy5 : y.regs 5 = x.regs 5 := ry 5 (by decide) (by decide) (by decide)
  have hyb : y.reg .rbp = x.reg .rbp := hy5
  obtain ⟨x', ex, mx, xx, rspx, ripx, regsx, rbpx, rbpx2⟩ :=
    exec_epilogue ctx F c.mode y (fun h1 => by
      have := hsp h1
      simp only [State.rsp, State.reg, idx_rsp, idx_rbp] at this ⊢
      rw [hy4, hy5]; exact this)
  have h0 : x'.regs 0 = y.regs 0 := regsx 0 (by decide) (by decide)
  have h2 : x'.regs 2 = y.regs 2 := regsx 2 (by decide) (by decide)
  refine ⟨s1, regs, incoming, x', hr1, hk.fp, hk.args, rfl, hin,
    fun hn => readFrame_rel hr1.rel hin (by omega) (by omega), ?_,
    fun r hr' => by rw [retBytes_congr h0 h2 xx]; exact hrr r hr', by rw [mx, my],
    by rw [rspx, hyb], by rw [ripx, hyb, my], fun hm => by rw [rbpx hm, hyb, my],
    fun h1 h2 => by rw [rbpx2 h1 h2, hyb], fun i i0 i2 i11 i4 i5 => by
      rw [regsx i i4 i5, ry i i0 i2 i11]⟩
  rw [execItems_append, hl, ey]; exact ex

end Ryo.Proofs.ArgRet