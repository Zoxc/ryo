/-
Ryo.Proofs.Cache — the register cache (`Asm.Cache`, vm.md#register-cache): its invariant and
the facts `emit` and the decoder rely on (aot.md §C2, "Register cache"; milestone M3).

- `CacheInv c x`: `c` has eight entries, and entry `i` holds of `pool[i]` in `x` (`Holds`): if
  it caches slot `(s, w)`, the register is the zero-extension of the `w`-sized little-endian
  value at `rbp + sext s`; if `zx = some z`, its bits from `z`'s width up are zero (which is what
  makes `update`'s store case sound: a store of `w ≥ z` bytes from it caches the slot).
  `CacheInv.empty`: the empty cache holds of every state.
- `update_inv`: `update` keeps the invariant over every item `cacheSafe` accepts: the forms of
  the inline sequences (loads, stores `st`/`stImm`/`setcc` clearing what they overlap, with the
  32-bit wrapping `overlaps` shown sound for the 64-bit addresses (`overlap_sound`), stores
  through pointers clearing everything, register writes, `mulQ` killing `rdx`), without writes
  of `rbp`, 64-bit `movsx`, or memory writes other than those three (`aluImm` only as `cmp` on
  memory). Everything else (`mov`, calls, `push`, `ctrInc`, SSE stores, …) can break it
  without `update` noticing: the decoder, like the encoder, clears the cache there, as it does
  at branch targets and non-inline instructions (vm.md#register-cache).
- `CacheInv.find_read`: a frame operand `find … false` hits reads as the low bits of the
  register; `CacheInv.exec_withRm`: so `withRm it (.reg pool[i])` runs as `it` but for `rip`,
  for each form `readOperand` covers (`alu`, `aluImm cmp`, `imul`, `imulImm`, `mulQ`).
- `CacheInv.reload` (and `reload_of`, from the slot directly): a reload `find … true` hits
  changes nothing but `rip`, so dropping it is sound.
- `emit_sound`: `emit` as a whole. From a state with the invariant, if the sequence (all
  `cacheSafe`), renamed from `rax` to the register `emit` picks (`emitHead`), runs to `z`, the
  emitted items run to `z` but for `rip`, and the cache after them holds of that state.
  `emit_eq` restates `emit`'s loop as a fold (`emitStep`), `loop_sound` proves the loop.

Left: that the items of `Asm.sequence` are `cacheSafe` (by inspection they are: no `rbp` or
64-bit `movsx` destination, no memory `aluImm` but `cmp`), `unemit`'s completeness (that the
sequence `emit` was given is among the decoder's candidates), and the decoder's clearing points
(stated above, not modeled here).
-/
import Ryo.Vm.Asm
import Ryo.X86.Exec

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.RegCache

open Ryo.Vm.Asm Ryo.X86

/-! ### Memory reads -/

theorem foldr_congr' (f g : Nat → Nat) : ∀ (l : List Nat), (∀ i ∈ l, f i = g i) →
    l.foldr (fun i acc => f i + 256 * acc) 0 = l.foldr (fun i acc => g i + 256 * acc) 0
  | [], _ => rfl
  | a :: l, h => by
    simp only [List.foldr_cons]
    rw [h a (by simp), foldr_congr' f g l (fun i hi => h i (by simp [hi]))]

theorem readNat_zero (m : Mem) (a : BitVec 64) : m.readNat a 0 = 0 := rfl

theorem readNat_succ (m : Mem) (a : BitVec 64) (k : Nat) :
    m.readNat a (k + 1) = (m a).toNat + 256 * m.readNat (a + 1) k := by
  unfold Mem.readNat
  rw [List.range_succ_eq_map]
  simp only [List.foldr_cons, List.foldr_map]
  congr 2
  · simp
  · apply foldr_congr'
    intro i _
    have : a + BitVec.ofNat 64 (i + 1) = a + 1 + BitVec.ofNat 64 i := by
      apply BitVec.eq_of_toNat_eq; simp; omega
    simp only [this]

theorem readNat_lt (m : Mem) : ∀ (a : BitVec 64) (k : Nat), m.readNat a k < 2 ^ (8 * k)
  | _, 0 => by simp [readNat_zero]
  | a, k + 1 => by
    rw [readNat_succ]
    have := readNat_lt m (a + 1) k
    have := (m a).toNat_lt
    rw [show 8 * (k + 1) = 8 + 8 * k by omega, Nat.pow_add]
    have : 256 * m.readNat (a + 1) k + 256 ≤ 256 * 2 ^ (8 * k) := by omega
    simp only [show (2:Nat) ^ 8 = 256 from rfl]
    omega

theorem readNat_congr (m m' : Mem) : ∀ (a : BitVec 64) (k : Nat),
    (∀ i < k, m (a + BitVec.ofNat 64 i) = m' (a + BitVec.ofNat 64 i)) →
    m.readNat a k = m'.readNat a k
  | _, 0, _ => rfl
  | a, k + 1, h => by
    rw [readNat_succ, readNat_succ]
    have h0 := h 0 (by omega)
    simp only [BitVec.add_zero] at h0
    rw [h0, readNat_congr m m' (a + 1) k (fun i hi => by
      have := h (i + 1) (by omega)
      have e : a + BitVec.ofNat 64 (i + 1) = a + 1 + BitVec.ofNat 64 i := by
        apply BitVec.eq_of_toNat_eq; simp; omega
      rwa [e] at this)]

theorem mod_split (x n : Nat) : x % 2 ^ (8 * (n + 1)) = x % 256 + 256 * (x / 256 % 2 ^ (8 * n)) := by
  rw [show 8 * (n + 1) = 8 + 8 * n by omega, Nat.pow_add]
  exact Nat.mod_mul

theorem readNat_mod (m : Mem) : ∀ (a : BitVec 64) (j k : Nat), j ≤ k →
    m.readNat a k % 2 ^ (8 * j) = m.readNat a j
  | _, 0, _, _ => by simp [readNat_zero]; omega
  | _, _ + 1, 0, h => absurd h (by omega)
  | a, j + 1, k + 1, h => by
    rw [readNat_succ, readNat_succ, mod_split]
    have := (m a).toNat_lt
    have e1 : ((m a).toNat + 256 * m.readNat (a + 1) k) % 256 = (m a).toNat := by omega
    have e2 : ((m a).toNat + 256 * m.readNat (a + 1) k) / 256 = m.readNat (a + 1) k := by omega
    rw [e1, e2, readNat_mod m (a + 1) j k (by omega)]

theorem readNat_write_self (m : Mem) (a : BitVec 64) (n v : Nat) (hn : n < 2 ^ 64) :
    ∀ (j k : Nat), j + k ≤ n →
    (m.write a n v).readNat (a + BitVec.ofNat 64 j) k = (v >>> (8 * j)) % 2 ^ (8 * k)
  | _, 0, _ => by simp [readNat_zero]; omega
  | j, k + 1, h => by
    rw [readNat_succ]
    have e : a + BitVec.ofNat 64 j + 1 = a + BitVec.ofNat 64 (j + 1) := by
      apply BitVec.eq_of_toNat_eq; simp; omega
    rw [e, readNat_write_self m a n v hn (j + 1) k (by omega), mod_split]
    have hb : m.write a n v (a + BitVec.ofNat 64 j) = UInt8.ofNat (v >>> (8 * j)) := by
      simp only [Mem.write]
      have : (a + BitVec.ofNat 64 j - a).toNat = j := by
        rw [BitVec.add_comm, BitVec.add_sub_cancel]; simp; omega
      rw [this, ite_eq_left (by omega)]
    rw [hb, UInt8.toNat_ofNat']
    congr 2
    rw [Nat.shiftRight_eq_div_pow, Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul,
      show 8 * (j + 1) = 8 * j + 8 by omega, Nat.pow_add]

theorem sext_mod (s : BitVec 32) : (s.signExtend 64).toNat % 2 ^ 32 = s.toNat := by
  have := s.isLt
  simp only [BitVec.toNat_signExtend, BitVec.toNat_setWidth]
  split <;> omega
theorem sext_setWidth (s : BitVec 32) : (s.signExtend 64).setWidth 32 = s := by
  apply BitVec.eq_of_toNat_eq; simp only [BitVec.toNat_setWidth]; exact sext_mod s
theorem cancel (r a b : BitVec 64) : r + a - (r + b) = a - b := by
  apply BitVec.eq_of_toNat_eq; simp only [BitVec.toNat_sub, BitVec.toNat_add]; omega
theorem sw_sub (a b : BitVec 64) : (a - b).setWidth 32 = a.setWidth 32 - b.setWidth 32 := by
  apply BitVec.eq_of_toNat_eq; simp only [BitVec.toNat_sub, BitVec.toNat_setWidth]; omega
theorem sw_add (a b : BitVec 64) : (a + b).setWidth 32 = a.setWidth 32 + b.setWidth 32 :=
  BitVec.setWidth_add _ _ (by omega)
theorem overlap_sound (rbp : BitVec 64) (s d : BitVec 32) (k n : Nat) (hk : k ≤ 8) (hn : n ≤ 8)
    (h : Ryo.Vm.Asm.overlaps s k d n = false) (i : Nat) (hi : i < k) :
    n ≤ (rbp + s.signExtend 64 + BitVec.ofNat 64 i - (rbp + d.signExtend 64)).toNat := by
  simp only [Ryo.Vm.Asm.overlaps, Bool.or_eq_false_iff, decide_eq_false_iff_not, Nat.not_lt] at h
  rw [BitVec.add_assoc, cancel]
  generalize ht : s.signExtend 64 + BitVec.ofNat 64 i - d.signExtend 64 = t
  have h32 : t.setWidth 32 = s + BitVec.ofNat 32 i - d := by
    rw [← ht, sw_sub, sw_add, sext_setWidth, sext_setWidth]
    congr 2
    apply BitVec.eq_of_toNat_eq; simp only [BitVec.toNat_setWidth, BitVec.toNat_ofNat]; omega
  have e := congrArg BitVec.toNat h32
  simp only [BitVec.toNat_setWidth, BitVec.toNat_sub, BitVec.toNat_add, BitVec.toNat_ofNat] at e h
  have := s.isLt; have := d.isLt
  omega


/-! ### State updates -/

section
variable (s : X86.State)

@[simp] theorem reg_jump (a : BitVec 64) (r : Reg) : (s.jump a).reg r = s.reg r := rfl
@[simp] theorem mem_jump (a : BitVec 64) : (s.jump a).mem = s.mem := rfl
@[simp] theorem regs_jump (a : BitVec 64) : (s.jump a).regs = s.regs := rfl
@[simp] theorem reg_setFlags (f : Flags) (r : Reg) : (s.setFlags f).reg r = s.reg r := rfl
@[simp] theorem mem_setFlags (f : Flags) : (s.setFlags f).mem = s.mem := rfl
@[simp] theorem regs_setFlags (f : Flags) : (s.setFlags f).regs = s.regs := rfl
@[simp] theorem reg_setMem (a : BitVec 64) (n v : Nat) (r : Reg) :
    (s.setMem a n v).reg r = s.reg r := rfl
@[simp] theorem mem_setMem (a : BitVec 64) (n v : Nat) :
    (s.setMem a n v).mem = s.mem.write a n v := rfl
@[simp] theorem regs_setMem (a : BitVec 64) (n v : Nat) : (s.setMem a n v).regs = s.regs := rfl
@[simp] theorem reg_setReg' (r : Reg) (v : BitVec 64) (r' : Reg) :
    (s.setReg r v).reg r' = if r'.idx = r.idx then v else s.reg r' := by
  simp [State.reg, State.setReg]
@[simp] theorem mem_setReg (r : Reg) (v : BitVec 64) : (s.setReg r v).mem = s.mem := rfl

theorem setReg_self (r : Reg) : s.setReg r (s.reg r) = s := by
  cases s
  simp only [State.setReg, State.reg, State.mk.injEq, and_true]
  funext i
  split <;> simp_all

end

theorem idx_inj {r r' : Reg} (h : r.idx = r'.idx) : r = r' := by
  cases r <;> cases r' <;> first | rfl | (simp [Reg.idx, Reg.num] at h)

theorem bytes_le (w : W) : bytes w ≤ 8 := by cases w <;> decide
theorem bits_eq (w : W) : w.bits = 8 * bytes w := by cases w <;> rfl

theorem memW_toNat (x : X86.State) (w : W) (a : BitVec 64) :
    (x.memW w a).toNat = x.mem.readNat a (bytes w) := by
  show (BitVec.ofNat w.bits (x.mem.readNat a (bytes w))).toNat = _
  rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt]
  rw [bits_eq]; exact readNat_lt x.mem a (bytes w)

/-! ### The pool -/

theorem poolIdx_eq (r : Reg) : poolIdx r = (match r with
    | .rax => some 0 | .rdx => some 1 | .rsi => some 2 | .rdi => some 3 | .r8 => some 4
    | .r9 => some 5 | .r10 => some 6 | .r11 => some 7 | _ => none) := by
  cases r <;> rfl

theorem poolIdx_some {r : Reg} {i : Nat} (h : poolIdx r = some i) : i < 8 ∧ pool[i]! = r := by
  rw [poolIdx_eq] at h
  cases r <;> simp at h <;> subst h <;> decide

theorem poolIdx_none {r : Reg} (h : poolIdx r = none) : ∀ i < 8, pool[i]!.idx ≠ r.idx := by
  rw [poolIdx_eq] at h
  cases r <;> simp at h <;> decide

theorem pool_inj : ∀ i < 8, ∀ j < 8, pool[i]!.idx = pool[j]!.idx → i = j := by decide

theorem pool_ne_rbp : ∀ i < 8, pool[i]!.idx ≠ Reg.rbp.idx := by decide

/-! ### The invariant -/

/-- What entry `e` says of register `r` in `x`: if it caches a slot `(s, w)`, `r` holds the
zero-extension of the `w`-sized value at `rbp + s`; if `zx = some z`, `r`'s bits from `z`'s
width up are zero. -/
def Holds (e : Entry) (x : X86.State) (r : Reg) : Prop :=
  (∀ s w, e.slot = some (s, w) → (x.reg r).toNat = x.mem.readNat (x.ea (M.frame s)) (bytes w)) ∧
  (∀ z, e.zx = some z → (x.reg r).toNat < 2 ^ z.bits)

/-- The cache invariant: eight entries, each of which holds of its pool register. -/
def CacheInv (c : Cache) (x : X86.State) : Prop :=
  c.regs.size = 8 ∧ ∀ i (hi : i < c.regs.size), Holds c.regs[i] x pool[i]!

theorem holds_congr {e : Entry} {x y : X86.State} {r : Reg} (h : Holds e x r)
    (hr : y.reg r = x.reg r) (hb : y.reg .rbp = x.reg .rbp) (hm : y.mem = x.mem) :
    Holds e y r := by
  obtain ⟨h1, h2⟩ := h
  refine ⟨fun s w hs => ?_, fun z hz => ?_⟩
  · rw [hr, h1 s w hs, hm]
    simp only [State.ea, M.frame, hb]
  · rw [hr]; exact h2 z hz

theorem inv_congr {c : Cache} {x y : X86.State} (h : CacheInv c x) (hr : y.regs = x.regs)
    (hm : y.mem = x.mem) : CacheInv c y :=
  ⟨h.1, fun i hi => holds_congr (h.2 i hi) (by simp [State.reg, hr]) (by simp [State.reg, hr]) hm⟩

@[simp] theorem inv_jump (c : Cache) (x : X86.State) (a : BitVec 64) :
    CacheInv c (x.jump a) ↔ CacheInv c x := Iff.rfl

@[simp] theorem inv_setFlags (c : Cache) (x : X86.State) (f : Flags) :
    CacheInv c (x.setFlags f) ↔ CacheInv c x := Iff.rfl

/-- The empty cache holds of every state. -/
theorem CacheInv.empty (x : X86.State) : CacheInv {} x := by
  refine ⟨by simp, fun i hi => ?_⟩
  simp only [Array.getElem_replicate]
  exact ⟨fun _ _ h => (nomatch h), fun _ h => (nomatch h)⟩

/-- The empty cache of a PE target or another (`Cache.pe`) holds of every state. -/
theorem CacheInv.emptyPe (pe : Bool) (x : X86.State) : CacheInv { pe := pe } x := by
  refine ⟨by simp, fun i hi => ?_⟩
  simp only [Array.getElem_replicate]
  exact ⟨fun _ _ h => (nomatch h), fun _ h => (nomatch h)⟩

theorem CacheInv.get {c : Cache} {x : X86.State} (h : CacheInv c x) {i : Nat} (hi : i < 8) :
    Holds c.regs[i]! x pool[i]! := by
  have hi' : i < c.regs.size := by rw [h.1]; exact hi
  rw [getElem!_pos c.regs i hi']
  exact h.2 i hi'

/-- In bit-vector form: a register caching `(s, w)` is the zero-extension of the `w`-bit value at
`rbp + s`. -/
theorem CacheInv.reg_eq {c : Cache} {x : X86.State} (h : CacheInv c x) {i : Nat} (hi : i < 8)
    {s : BitVec 32} {w : W} (hs : c.regs[i]!.slot = some (s, w)) :
    x.reg pool[i]! = (x.memW w (x.ea (M.frame s))).setWidth 64 := by
  apply BitVec.eq_of_toNat_eq
  rw [(h.get hi).1 s w hs, BitVec.toNat_setWidth, memW_toNat]
  have := readNat_lt x.mem (x.ea (M.frame s)) (bytes w)
  have := bytes_le w
  have : 2 ^ (8 * bytes w) ≤ 2 ^ 64 := Nat.pow_le_pow_right (by omega) (by omega)
  omega

/-! ### Cache updates -/

/-- Whether a write of `n` bytes at `m` clears entry `e`. -/
def hit (m : M) (n : Nat) (e : Entry) : Bool :=
  m.base != .rbp || (match e.slot with
    | some (s, w) => overlaps s (bytes w) m.disp n
    | none => false)

/-- `update`'s `write`: a write of `n` bytes at `m` clears the overlapping entries (every entry
if `m` isn't a frame operand). -/
def clearW (c : Cache) (m : M) (n : Nat) : Cache :=
  { c with regs := c.regs.map fun e => if hit m n e then { e with slot := none } else e }

/-- `update`'s write of a register: the entry of `r`, if it is a pool register. -/
def setRegEntry (c : Cache) (r : Reg) (slot : Option (BitVec 32 × W)) (zx : Option W) : Cache :=
  match poolIdx r with
  | some i => c.setEntry i fun e => { e with slot := slot, zx := zx }
  | none => c

/-- `update`'s `wide`. -/
def wideW (w : W) : Option W := if w == .d || w == .q then some w else none

theorem inv_setReg {c : Cache} {x : X86.State} {r : Reg} {v : BitVec 64}
    {slot : Option (BitVec 32 × W)} {zx : Option W} (h : CacheInv c x) (hr : r ≠ .rbp)
    (hs : ∀ s w, slot = some (s, w) → v.toNat = x.mem.readNat (x.ea (M.frame s)) (bytes w))
    (hz : ∀ z, zx = some z → v.toNat < 2 ^ z.bits) :
    CacheInv (setRegEntry c r slot zx) (x.setReg r v) := by
  have hrb : Reg.rbp.idx ≠ r.idx := fun e => hr (idx_inj e).symm
  unfold setRegEntry
  cases hp : poolIdx r with
  | none =>
    refine ⟨h.1, fun i hi => holds_congr (h.2 i hi) ?_ (by simp [hrb]) (by simp)⟩
    have := poolIdx_none hp i (by rw [← h.1]; exact hi)
    simp only [reg_setReg', this, ↓reduceIte]
  | some k =>
    dsimp only
    obtain ⟨hk, hpk⟩ := poolIdx_some hp
    refine ⟨by simp [Cache.setEntry, h.1], fun i hi => ?_⟩
    simp only [Cache.setEntry, Array.getElem_modify]
    have hi8 : i < 8 := by have := h.1; simp [Cache.setEntry] at hi; omega
    split
    · rename_i hki
      subst hki
      rw [hpk]
      refine ⟨fun s w hsl => ?_, fun z hzx => ?_⟩
      · simp only [reg_setReg', ite_true]
        rw [hs s w hsl]
        simp [State.ea, M.frame, hrb]
      · simp only [reg_setReg', ite_true]
        exact hz z hzx
    · rename_i hki
      have hne : pool[i]!.idx ≠ r.idx := by
        rw [← hpk]; intro e; exact hki (pool_inj k hk i hi8 e.symm)
      exact holds_congr (h.2 i (by simp [Cache.setEntry] at hi; exact hi))
        (by simp only [reg_setReg', hne, ↓reduceIte]) (by simp [hrb]) (by simp)

theorem inv_setRegW {c : Cache} {x : X86.State} {r : Reg} {w : W} {v : BitVec w.bits}
    (h : CacheInv c x) (hr : r ≠ .rbp) :
    CacheInv (setRegEntry c r none (wideW w)) (x.setRegW w r v) := by
  cases w <;> simp only [State.setRegW] <;> refine inv_setReg h hr (fun _ _ h => nomatch h) ?_
    <;> intro z hz <;> simp [wideW] at hz <;> subst hz <;> simp [BitVec.toNat_setWidth] <;>
    have := v.isLt <;> simp [W.bits] at this ⊢ <;> omega

theorem inv_setEntry {c : Cache} {x : X86.State} {i : Nat} {f : Entry → Entry}
    (h : CacheInv c x) (hi : i < 8) (hn : Holds (f c.regs[i]!) x pool[i]!) :
    CacheInv (c.setEntry i f) x := by
  refine ⟨by simp [Cache.setEntry, h.1], fun j hj => ?_⟩
  simp only [Cache.setEntry, Array.getElem_modify]
  split
  · rename_i hij; subst hij
    rwa [← getElem!_pos c.regs i (by rw [h.1]; exact hi)]
  · exact h.2 j (by simp [Cache.setEntry] at hj; exact hj)

theorem inv_write {c : Cache} {x y : X86.State} {m : M} {n : Nat} (h : CacheInv c x) (hn : n ≤ 8)
    (hr : y.regs = x.regs) (hm : ∀ a, n ≤ (a - x.ea m).toNat → y.mem a = x.mem a) :
    CacheInv (clearW c m n) y := by
  have hreg : ∀ r, y.reg r = x.reg r := fun r => by simp [State.reg, hr]
  refine ⟨by simp [clearW, h.1], fun i hi => ?_⟩
  simp only [clearW, Array.getElem_map]
  have hi' : i < c.regs.size := by simpa [clearW] using hi
  obtain ⟨h1, h2⟩ := h.2 i hi'
  cases hh : hit m n c.regs[i]
  · simp only [Bool.false_eq_true, ite_false]
    refine ⟨fun s w hs => ?_, fun z hz => by rw [hreg]; exact h2 z hz⟩
    simp only [hit, hs, Bool.or_eq_false_iff, bne_eq_false_iff_eq] at hh
    obtain ⟨hb, ho⟩ := hh
    rw [hreg, h1 s w hs]
    have hea : y.ea (M.frame s) = x.ea (M.frame s) := by simp [State.ea, hreg]
    rw [hea]
    apply readNat_congr
    intro j hj
    apply (hm _ _).symm
    cases m; simp only at hb; subst hb
    exact overlap_sound (x.reg .rbp) s _ (bytes w) n (bytes_le w) hn ho j hj
  · simp only [ite_true]
    exact ⟨fun _ _ h => (nomatch h), fun z hz => by rw [hreg]; exact h2 z hz⟩

/-- `update`'s store case: the stored register caches the slot if its value is the
zero-extension of the stored bytes (`zx` at most the store's width). -/
def stEntry (c : Cache) (w : W) (src : Reg) (m : M) : Cache :=
  match poolIdx src with
  | some i =>
    if m.base == .rbp && (match c.regs[i]!.zx with
        | some z => decide (bytes z ≤ bytes w)
        | none => false) then
      c.setEntry i fun e => { e with slot := some (m.disp, w) }
    else c
  | none => c

section Eqns
variable (c : Cache)

theorem update_ld (w : W) (sx : Bool) (dst : Reg) (m : M) : c.update (.ld w sx dst m) =
    setRegEntry c dst (if !sx && m.base == .rbp then some (m.disp, w) else none)
      (some (if sx then .d else w)) := by
  cases hp : poolIdx dst <;> simp [Cache.update, setRegEntry, hp] <;> rfl

theorem update_st (w : W) (src : Reg) (m : M) :
    c.update (.st w src m) = stEntry (clearW c m (bytes w)) w src m := by
  cases hp : poolIdx src <;> simp [Cache.update, stEntry, clearW, hit, hp] <;> (try intros) <;> rfl

theorem update_stImm (w : W) (m : M) (i : BitVec 32) :
    c.update (.stImm w m i) = clearW c m (bytes w) := by
  simp [Cache.update, clearW, hit] <;> intros <;> rfl

theorem update_setcc (cc : Cond) (m : M) : c.update (.setcc cc m) = clearW c m 1 := by
  simp [Cache.update, clearW, hit] <;> intros <;> rfl

theorem update_testM8 (m : M) : c.update (.testM8 m) = c := by simp [Cache.update]
theorem update_setccCl (cc : Cond) : c.update (.setccCl cc) = c := by simp [Cache.update]

theorem update_alu (op : Alu) (w : W) (r : Reg) (rm : Rm) : c.update (.alu op w r rm) =
    if op != .cmp then setRegEntry c r none (wideW w) else c := by
  cases hp : poolIdx r <;> cases op <;> simp [Cache.update, setRegEntry, wideW, hp] <;> rfl

theorem update_aluImm_reg (op : Alu) (w : W) (r : Reg) (i : BitVec 32) :
    c.update (.aluImm op w (.reg r) i) =
      if op != .cmp then setRegEntry c r none (wideW w) else c := by
  cases hp : poolIdx r <;> cases op <;> simp [Cache.update, setRegEntry, wideW, hp] <;> rfl

theorem update_aluImm_mem (op : Alu) (w : W) (m : M) (i : BitVec 32) :
    c.update (.aluImm op w (.mem m) i) = c := by
  simp [Cache.update]

theorem update_imul (w : W) (r : Reg) (rm : Rm) :
    c.update (.imul w r rm) = setRegEntry c r none (wideW w) := by
  cases hp : poolIdx r <;> simp [Cache.update, setRegEntry, wideW, hp] <;> rfl

theorem update_imulImm (w : W) (r : Reg) (rm : Rm) (i : BitVec 32) :
    c.update (.imulImm w r rm i) = setRegEntry c r none (wideW w) := by
  cases hp : poolIdx r <;> simp [Cache.update, setRegEntry, wideW, hp] <;> rfl

theorem update_shift (op : Sh) (w : W) (r : Reg) (a : BitVec 8) :
    c.update (.shift op w r a) = setRegEntry c r none (wideW w) := by
  cases hp : poolIdx r <;> simp [Cache.update, setRegEntry, wideW, hp] <;> rfl

theorem update_leaM (r : Reg) (m : M) :
    c.update (.leaM r m) = setRegEntry c r none (some .q) := by
  cases hp : poolIdx r <;> simp [Cache.update, setRegEntry, hp] <;> rfl

theorem update_setReg (r : Reg) (v : BitVec 64) :
    c.update (.setReg r v) = setRegEntry c r none (some .q) := by
  cases hp : poolIdx r <;> simp [Cache.update, setRegEntry, hp] <;> rfl

theorem update_lea (r : Reg) (to : Ref) :
    c.update (.lea r to) = setRegEntry c r none (some .q) := by
  cases hp : poolIdx r <;> simp [Cache.update, setRegEntry, hp] <;> rfl

theorem update_loadRip (r : Reg) (to : Ref) :
    c.update (.loadRip r to) = setRegEntry c r none (some .q) := by
  cases hp : poolIdx r <;> simp [Cache.update, setRegEntry, hp] <;> rfl

theorem update_mulQ (rm : Rm) :
    c.update (.mulQ rm) = setRegEntry (setRegEntry c .rdx none none) .rax none (some .q) := by
  simp [Cache.update, setRegEntry, poolIdx_eq] <;> rfl

end Eqns

/-! ### `update` keeps the invariant -/

/-- The items `update` tracks exactly: the forms of the inline sequences (`Asm.sequence`, after
`emit`'s renaming), with no write of `rbp` (the frame base every entry is relative to), no
`movsx` at 64 bits (`update` records a 32-bit `zx` for every sign-extending load), and no
memory write but `st`/`stImm`/`setcc` (`aluImm` only as `cmp` on memory). Everything else
(calls, `push`, `mov`, `ctrInc`, SSE stores, …) is outside an inline sequence; the decoder clears
the cache at it, as the encoder does. -/
def cacheSafe : Item → Bool
  | .ld w sx dst _ => dst != .rbp && !(sx && w == .q)
  | .st .. | .stImm .. | .setcc .. | .testM8 .. | .setccCl .. | .mulQ .. => true
  | .leaM d _ | .lea d _ | .loadRip d _ | .setReg d _ => d != .rbp
  | .alu _ _ r _ | .imul _ r _ | .imulImm _ r _ _ | .shift _ _ r _ => r != .rbp
  | .aluImm op _ rm _ => match rm with
    | .reg r => r != .rbp
    | .mem _ => op == .cmp
  | _ => false

theorem ea_frame_of {x : X86.State} {m : M} (h : m.base = .rbp) : x.ea m = x.ea (M.frame m.disp) := by
  cases m; simp only at h; subst h; rfl

theorem toNat_setWidth_lt {n : Nat} (v : BitVec n) (hn : n ≤ 64) :
    (v.setWidth 64).toNat = v.toNat := by
  rw [BitVec.toNat_setWidth, Nat.mod_eq_of_lt]
  exact Nat.lt_of_lt_of_le v.isLt (Nat.pow_le_pow_right (by omega) hn)

theorem update_inv_ld {ctx : Ctx} {c : Cache} {x x' : X86.State} {w : W} {sx : Bool} {dst : Reg}
    {m : M} (hs : cacheSafe (.ld w sx dst m) = true) (h : CacheInv c x)
    (hx : (Item.ld w sx dst m).exec ctx x = .ok x') : CacheInv (c.update (.ld w sx dst m)) x' := by
  rw [update_ld]
  simp only [cacheSafe, Bool.and_eq_true, bne_iff_ne, ne_eq, Bool.not_eq_true',
    Bool.and_eq_false_imp] at hs
  obtain ⟨hd, hq⟩ := hs
  cases w <;> simp only [Item.exec, State.setRegW, pure, Except.pure, Except.ok.injEq] at hx <;>
    subst hx <;> refine inv_setReg (by simpa using h) hd ?_ ?_
  all_goals first
    | (intro z hz
       simp only [Option.some.injEq] at hz
       subst hz
       cases sx <;> simp only [ite_true, ite_false, Bool.false_eq_true] <;>
         (try rw [toNat_setWidth_lt _ (by decide)]) <;>
         first
         | exact BitVec.isLt _
         | exact absurd (hq rfl) (by decide)
         | (rw [BitVec.toNat_setWidth]; exact Nat.lt_of_le_of_lt (Nat.mod_le _ _) (BitVec.isLt _)))
    | (intro s w' hsl
       split at hsl
       · rename_i hc
         simp only [Bool.and_eq_true, Bool.not_eq_true', beq_iff_eq] at hc
         simp only [Option.some.injEq, Prod.mk.injEq] at hsl
         obtain ⟨rfl, hb⟩ := hc
         obtain ⟨rfl, rfl⟩ := hsl
         rw [mem_jump, ea_frame_of hb]
         (try simp only [Bool.false_eq_true, ite_false])
         first
         | rw [toNat_setWidth_lt _ (by decide), BitVec.toNat_setWidth, memW_toNat]
         | rw [toNat_setWidth_lt _ (by decide), memW_toNat]
         rw [mem_jump]
         try exact Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le (readNat_lt _ _ _) (by decide))
       · exact nomatch hsl)

theorem exec_st {ctx : Ctx} {x x' : X86.State} {w : W} {src : Reg} {m : M}
    (hx : (Item.st w src m).exec ctx x = .ok x') :
    x'.regs = x.regs ∧ x'.mem = x.mem.write (x.ea m) (bytes w) (x.regW w src).toNat := by
  simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
  subst hx
  exact ⟨rfl, rfl⟩

theorem update_inv_st {ctx : Ctx} {c : Cache} {x x' : X86.State} {w : W} {src : Reg} {m : M}
    (h : CacheInv c x) (hx : (Item.st w src m).exec ctx x = .ok x') :
    CacheInv (c.update (.st w src m)) x' := by
  obtain ⟨hr, hm⟩ := exec_st hx
  have hreg : ∀ r, x'.reg r = x.reg r := fun r => by simp [State.reg, hr]
  have h1 : CacheInv (clearW c m (bytes w)) x' :=
    inv_write h (bytes_le w) hr (fun a ha => by rw [hm]; exact Mem.write_other _ _ _ _ _ ha)
  rw [update_st]
  unfold stEntry
  cases hp : poolIdx src with
  | none => exact h1
  | some i =>
    obtain ⟨hi, hpi⟩ := poolIdx_some hp
    dsimp only
    cases hzx : (clearW c m (bytes w)).regs[i]!.zx with
    | none => simpa using h1
    | some z =>
      dsimp only
      by_cases hc : (m.base == Reg.rbp && decide (bytes z ≤ bytes w)) = true
      · simp only [hc, ↓reduceIte]
        simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at hc
        obtain ⟨hb, hz⟩ := hc
        obtain ⟨h1s, h1z⟩ := h1.get hi
        refine inv_setEntry h1 hi ⟨fun s w' hs => ?_, fun z hz' => h1z z hz'⟩
        simp only [Option.some.injEq, Prod.mk.injEq] at hs
        obtain ⟨rfl, rfl⟩ := hs
        have hlt := h1z z hzx
        rw [hpi] at hlt ⊢
        have ea' : x'.ea (M.frame m.disp) = x.ea m := by
          rw [ea_frame_of hb]; simp [State.ea, M.frame, hreg]
        rw [ea', hm]
        have := readNat_write_self x.mem (x.ea m) (bytes w) (x.regW w src).toNat
          (by have := bytes_le w; omega) 0 (bytes w) (by omega)
        simp only [BitVec.add_zero, Nat.mul_zero, Nat.shiftRight_zero] at this
        rw [this, hreg]
        rw [hreg] at hlt
        have hzw : 2 ^ z.bits ≤ 2 ^ w.bits := by
          rw [bits_eq z, bits_eq w]; exact Nat.pow_le_pow_right (by omega) (by omega)
        simp only [State.regW, BitVec.toNat_setWidth]
        rw [← bits_eq, Nat.mod_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega)]
      · simp only [hc, Bool.false_eq_true, ↓reduceIte]
        exact h1

theorem inv_setReg_q {c : Cache} {x : X86.State} {r : Reg} {v : BitVec 64} (h : CacheInv c x)
    (hr : r ≠ .rbp) : CacheInv (setRegEntry c r none (some .q)) (x.setReg r v) :=
  inv_setReg h hr (fun _ _ h => nomatch h) (fun z hz => by cases hz; exact v.isLt)

theorem setReg_comm (s : X86.State) {r r' : Reg} (hne : r.idx ≠ r'.idx) (v v' : BitVec 64) :
    (s.setReg r v).setReg r' v' = (s.setReg r' v').setReg r v := by
  simp only [State.setReg, State.mk.injEq, and_true]
  funext i
  by_cases h1 : i = r'.idx <;> by_cases h2 : i = r.idx <;> simp_all

/-- `update` keeps the invariant over every item it tracks (`cacheSafe`). -/
theorem update_inv {ctx : Ctx} {it : Item} {c : Cache} {x x' : X86.State}
    (hs : cacheSafe it = true) (h : CacheInv c x) (hx : it.exec ctx x = .ok x') :
    CacheInv (c.update it) x' := by
  cases it with
  | ld w sx dst m => exact update_inv_ld hs h hx
  | st w src m => exact update_inv_st h hx
  | stImm w m i =>
    rw [update_stImm]
    simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
    subst hx
    exact inv_write h (bytes_le w) rfl (fun a ha => Mem.write_other _ _ _ _ _ ha)
  | setcc cc m =>
    rw [update_setcc]
    simp only [Item.exec, bind, Except.bind] at hx
    split at hx
    · exact nomatch hx
    · simp only [pure, Except.pure, Except.ok.injEq] at hx
      subst hx
      exact inv_write h (by omega) rfl (fun a ha => Mem.write_other _ _ _ _ _ ha)
  | testM8 m =>
    rw [update_testM8]
    simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
    subst hx
    simpa using h
  | setccCl cc =>
    rw [update_setccCl]
    simp only [Item.exec, bind, Except.bind] at hx
    split at hx
    · exact nomatch hx
    · simp only [pure, Except.pure, Except.ok.injEq] at hx
      subst hx
      exact inv_setRegW (c := c) (r := .rcx) (w := .b) (by simpa using h) (by decide)
  | mulQ rm =>
    rw [update_mulQ]
    simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
    subst hx
    rw [inv_setFlags, setReg_comm _ (by decide)]
    exact inv_setReg_q (inv_setReg (by simpa using h) (by decide) (fun _ _ h => nomatch h)
      (fun _ h => nomatch h)) (by decide)
  | leaM d m =>
    simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
    rw [update_leaM]
    simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
    subst hx
    exact inv_setReg_q (by simpa using h) hs
  | lea d to =>
    simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
    rw [update_lea]
    simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
    subst hx
    exact inv_setReg_q (by simpa using h) hs
  | loadRip d to =>
    simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
    rw [update_loadRip]
    simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
    subst hx
    exact inv_setReg_q (by simpa using h) hs
  | setReg d v =>
    simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
    rw [update_setReg]
    simp only [Item.exec] at hx
    split at hx <;> simp only [pure, Except.pure, Except.ok.injEq] at hx <;> subst hx
    · rw [inv_setFlags]; exact inv_setReg_q (by simpa using h) hs
    · exact inv_setReg_q (by simpa using h) hs
  | alu op w r rm =>
    simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
    rw [update_alu]
    cases op <;> simp only [Item.exec, aluF, pure, Except.pure, Except.ok.injEq] at hx <;>
      subst hx
    all_goals first
      | (simp only [bne_iff_ne, ne_eq, reduceCtorEq, not_false_eq_true, ↓reduceIte]
         exact inv_setRegW (by simpa using h) hs)
      | simpa using h
  | aluImm op w rm i =>
    cases rm with
    | reg r =>
      simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
      rw [update_aluImm_reg]
      cases op <;> simp only [Item.exec, aluF, State.setRmW, pure, Except.pure,
        Except.ok.injEq] at hx <;>
        subst hx
      all_goals first
        | (simp only [bne_iff_ne, ne_eq, reduceCtorEq, not_false_eq_true, ↓reduceIte]
           exact inv_setRegW (by simpa using h) hs)
        | simpa using h
    | mem m =>
      simp only [cacheSafe, beq_iff_eq] at hs
      subst hs
      rw [update_aluImm_mem]
      simp only [Item.exec, aluF, pure, Except.pure, Except.ok.injEq] at hx
      subst hx
      simpa using h
  | imul w r rm =>
    simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
    rw [update_imul]
    simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
    subst hx
    rw [inv_setFlags]; exact inv_setRegW (by simpa using h) hs
  | imulImm w r rm i =>
    simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
    rw [update_imulImm]
    simp only [Item.exec, pure, Except.pure, Except.ok.injEq] at hx
    subst hx
    rw [inv_setFlags]; exact inv_setRegW (by simpa using h) hs
  | shift op w r a =>
    simp only [cacheSafe, bne_iff_ne, ne_eq] at hs
    rw [update_shift]
    simp only [Item.exec, pure, Except.pure] at hx
    split at hx <;> simp only [Except.ok.injEq] at hx <;> subst hx
    · rw [inv_setFlags]; exact inv_setRegW (by simpa using h) hs
    · exact inv_setRegW (by simpa using h) hs
  | _ => simp [cacheSafe] at hs

/-! ### Reading through the cache -/

theorem find_spec {c : Cache} {m : M} {w : W} {ex : Bool} {i : Nat}
    (hf : c.find m w ex = some i) : m.base = .rbp ∧ ∃ (hi : i < c.regs.size) (sw : W),
      c.regs[i].slot = some (m.disp, sw) ∧ (if ex then sw = w else bytes w ≤ bytes sw) := by
  unfold Cache.find at hf
  split at hf
  · exact nomatch hf
  · rename_i hb
    simp only [bne_iff_ne, ne_eq, Decidable.not_not] at hb
    refine ⟨hb, ?_⟩
    obtain ⟨hi, hp, -⟩ := Array.findIdx?_eq_some_iff_getElem.mp hf
    refine ⟨hi, ?_⟩
    split at hp
    · rename_i s sw hsl
      simp only [Bool.and_eq_true, beq_iff_eq] at hp
      obtain ⟨rfl, hw⟩ := hp
      refine ⟨sw, hsl, ?_⟩
      cases ex <;> simp_all
    · exact nomatch hp

/-- A frame operand the cache holds at least as wide (`find … false`) reads as the low bits of
the register. -/
theorem CacheInv.find_read {c : Cache} {x : X86.State} {m : M} {w : W} {i : Nat}
    (h : CacheInv c x) (hf : c.find m w false = some i) :
    i < 8 ∧ x.rmW w (.mem m) = x.regW w pool[i]! := by
  obtain ⟨hb, hi, sw, hsl, hw⟩ := find_spec hf
  simp only [Bool.false_eq_true, ↓reduceIte] at hw
  have hi8 : i < 8 := by rw [← h.1]; exact hi
  refine ⟨hi8, ?_⟩
  have := (h.2 i hi).1 _ _ hsl
  apply BitVec.eq_of_toNat_eq
  simp only [State.rmW, State.regW, BitVec.toNat_setWidth, memW_toNat]
  rw [this, ← ea_frame_of hb, bits_eq, readNat_mod _ _ _ _ hw]

/-- A reload of a slot the cache holds at that width (`find … true`) changes nothing but
`rip`: `emit` drops it. -/
theorem CacheInv.reload_of {ctx : Ctx} {c : Cache} {x : X86.State} {m : M} {sw : W} {i : Nat}
    (h : CacheInv c x) (hb : m.base = .rbp) (hi8 : i < 8)
    (hsl : c.regs[i]!.slot = some (m.disp, sw)) :
    (Item.ld sw false pool[i]! m).exec ctx x =
      .ok (x.jump (x.rip + BitVec.ofNat 64 (Item.ld sw false pool[i]! m).size)) := by
  have hv := (h.get hi8).1 _ _ hsl
  rw [← ea_frame_of hb] at hv
  have key : ∀ (a v : BitVec 64), v.toNat = (x.reg pool[i]!).toNat →
      (x.jump a).setReg pool[i]! v = x.jump a := by
    intro a v hv'
    have : v = (x.jump a).reg pool[i]! := BitVec.eq_of_toNat_eq hv'
    rw [this, setReg_self]
  have hlt := readNat_lt x.mem (x.ea m) (bytes sw)
  cases sw <;> simp only [Item.exec, State.setRegW, pure, Except.pure, Except.ok.injEq] <;>
    (try simp only [Bool.false_eq_true, ↓reduceIte]) <;> refine key _ _ ?_ <;> rw [hv] <;>
    simp only [BitVec.toNat_setWidth, memW_toNat, mem_jump]
  all_goals
    have e : ∀ a, (x.jump a).ea m = x.ea m := fun _ => rfl
    simp only [e]
    simp only [bytes, W.bits] at hlt ⊢
    omega

/-- A reload of a slot the cache holds at that width (`find … true`) changes nothing but
`rip`: `emit` drops it. -/
theorem CacheInv.reload {ctx : Ctx} {c : Cache} {x : X86.State} {m : M} {w : W} {i : Nat}
    (h : CacheInv c x) (hf : c.find m w true = some i) :
    (Item.ld w false pool[i]! m).exec ctx x =
      .ok (x.jump (x.rip + BitVec.ofNat 64 (Item.ld w false pool[i]! m).size)) := by
  obtain ⟨hb, hi, sw, hsl, hw⟩ := find_spec hf
  simp only [↓reduceIte] at hw
  subst hw
  have hi8 : i < 8 := by rw [← h.1]; exact hi
  exact h.reload_of hb hi8 (by rw [getElem!_pos c.regs i hi]; exact hsl)

/-- `emit`'s register operands: an item `readOperand` covers, with its frame operand replaced
by the register the cache holds it in, runs as the item does but for `rip` (the encodings
differ in length). -/
theorem CacheInv.exec_withRm {ctx : Ctx} {c : Cache} {x : X86.State} {it : Item} {m : M}
    {w : W} {i : Nat} (h : CacheInv c x) (ho : readOperand it = some (m, w))
    (hf : c.find m w false = some i) :
    (withRm it (.reg pool[i]!)).exec ctx x =
      (it.exec ctx x).map (·.jump (x.rip + BitVec.ofNat 64 (withRm it (.reg pool[i]!)).size)) := by
  have hrm := (h.find_read hf).2
  have key : ∀ a : BitVec 64, (x.jump a).rmW w (.mem m) = (x.jump a).rmW w (.reg pool[i]!) :=
    fun _ => hrm
  have rj : ∀ a b : BitVec 64, (x.jump a).rmW w (.reg pool[i]!) = (x.jump b).rmW w (.reg pool[i]!) :=
    fun _ _ => rfl
  cases it with
  | alu op w' r rm =>
    cases rm with
    | reg => simp [readOperand] at ho
    | mem m' =>
      simp only [readOperand] at ho
      split at ho
      · simp only [Option.some.injEq, Prod.mk.injEq] at ho
        obtain ⟨rfl, rfl⟩ := ho
        simp only [withRm, Item.exec, pure, Except.pure, Except.map, key]
        generalize x.rip + BitVec.ofNat 64 (Item.alu op w' r (.mem m')).size = n1
        generalize x.rip + BitVec.ofNat 64 (Item.alu op w' r (.reg pool[i]!)).size = n2
        rw [rj n1 n2]
        cases op <;> cases w' <;> rfl
      · exact nomatch ho
  | aluImm op w' rm imm =>
    cases op <;> cases rm <;> simp only [readOperand, reduceCtorEq] at ho
    rename_i m'
    split at ho
    · simp only [Option.some.injEq, Prod.mk.injEq] at ho
      obtain ⟨rfl, rfl⟩ := ho
      simp only [withRm, Item.exec, pure, Except.pure, Except.map, key]
      generalize x.rip + BitVec.ofNat 64 (Item.aluImm .cmp w' (.mem m') imm).size = n1
      generalize x.rip + BitVec.ofNat 64 (Item.aluImm .cmp w' (.reg pool[i]!) imm).size = n2
      rw [rj n1 n2]
      rfl
    · exact nomatch ho
  | imul w' r rm =>
    cases rm with
    | reg => simp [readOperand] at ho
    | mem m' =>
      simp only [readOperand] at ho
      split at ho
      · simp only [Option.some.injEq, Prod.mk.injEq] at ho
        obtain ⟨rfl, rfl⟩ := ho
        simp only [withRm, Item.exec, pure, Except.pure, Except.map, key]
        generalize x.rip + BitVec.ofNat 64 (Item.imul w' r (.mem m')).size = n1
        generalize x.rip + BitVec.ofNat 64 (Item.imul w' r (.reg pool[i]!)).size = n2
        rw [rj n1 n2]
        cases w' <;> rfl
      · exact nomatch ho
  | imulImm w' r rm imm =>
    cases rm with
    | reg => simp [readOperand] at ho
    | mem m' =>
      simp only [readOperand] at ho
      split at ho
      · simp only [Option.some.injEq, Prod.mk.injEq] at ho
        obtain ⟨rfl, rfl⟩ := ho
        simp only [withRm, Item.exec, pure, Except.pure, Except.map, key]
        generalize x.rip + BitVec.ofNat 64 (Item.imulImm w' r (.mem m') imm).size = n1
        generalize x.rip + BitVec.ofNat 64 (Item.imulImm w' r (.reg pool[i]!) imm).size = n2
        rw [rj n1 n2]
        cases w' <;> rfl
      · exact nomatch ho
  | mulQ rm =>
    cases rm with
    | reg => simp [readOperand] at ho
    | mem m' =>
      simp only [readOperand] at ho
      split at ho
      · simp only [Option.some.injEq, Prod.mk.injEq] at ho
        obtain ⟨rfl, rfl⟩ := ho
        simp only [withRm, Item.exec, pure, Except.pure, Except.map, key]
        generalize x.rip + BitVec.ofNat 64 (Item.mulQ (.mem m')).size = n1
        generalize x.rip + BitVec.ofNat 64 (Item.mulQ (.reg pool[i]!)).size = n2
        rw [rj n1 n2]
        rfl
      · exact nomatch ho
  | div sg w' rm =>
    cases rm with
    | reg => simp [readOperand] at ho
    | mem m' =>
      simp only [readOperand] at ho
      split at ho
      · simp only [Option.some.injEq, Prod.mk.injEq] at ho
        obtain ⟨rfl, rfl⟩ := ho
        simp only [withRm, Item.exec, pure, Except.pure, Except.map, key]
        generalize x.rip + BitVec.ofNat 64 (Item.div sg w' (.mem m')).size = n1
        generalize x.rip + BitVec.ofNat 64 (Item.div sg w' (.reg pool[i]!)).size = n2
        have rr : ∀ (a : BitVec 64) (w : W) (r : Reg), (x.jump a).regW w r = x.regW w r :=
          fun _ _ _ => rfl
        have rm2 : ∀ a : BitVec 64, (x.jump a).rmW w' (.reg pool[i]!) = x.rmW w' (.reg pool[i]!) :=
          fun _ => rfl
        simp only [rr, rm2]
        split
        · rfl
        · cases divF sg (x.regW w' .rdx) (x.regW w' .rax) (x.rmW w' (.reg pool[i]!)) with
          | none => rfl
          | some p => cases w' <;> rfl
      · exact nomatch ho
  | _ => simp [readOperand] at ho

/-! ### `emit` -/

@[simp] theorem jump_jump (s : X86.State) (a b : BitVec 64) : (s.jump a).jump b = s.jump b := rfl
@[simp] theorem flags_jump (s : X86.State) (a : BitVec 64) : (s.jump a).flags = s.flags := rfl
@[simp] theorem rip_jump (s : X86.State) (a : BitVec 64) : (s.jump a).rip = a := rfl
@[simp] theorem regW_jump (s : X86.State) (a : BitVec 64) (w : W) (r : Reg) :
    (s.jump a).regW w r = s.regW w r := rfl
@[simp] theorem ea_jump (s : X86.State) (a : BitVec 64) (m : M) : (s.jump a).ea m = s.ea m := rfl
@[simp] theorem rmW_jump (s : X86.State) (a : BitVec 64) (w : W) (rm : Rm) :
    (s.jump a).rmW w rm = s.rmW w rm := by cases rm <;> rfl
@[simp] theorem memW_jump (s : X86.State) (a : BitVec 64) (w : W) (b : BitVec 64) :
    (s.jump a).memW w b = s.memW w b := rfl

/-- The items `update` tracks don't read `rip`: started elsewhere, they end elsewhere. -/
theorem exec_jump {ctx : Ctx} {it : Item} (hs : cacheSafe it = true) (s : X86.State)
    (a : BitVec 64) :
    it.exec ctx (s.jump a) = (it.exec ctx s).map (·.jump (a + BitVec.ofNat 64 it.size)) := by
  generalize hk : BitVec.ofNat 64 it.size = k
  cases it <;> simp only [cacheSafe, reduceCtorEq] at hs <;>
    simp only [Item.exec, hk, jump_jump, flags_jump, rip_jump, regW_jump, ea_jump, rmW_jump,
      memW_jump, bind, Except.bind] <;>
    first
    | rfl
    | (cases ‹W› <;> rfl)
    | (cases ‹Alu› <;> cases ‹W› <;> rfl)
    | (split <;> rfl)
    | (cases ‹Alu› <;> cases ‹W› <;> cases ‹Rm› <;> rfl)
    | (cases ‹W› <;> split <;> rfl)
    | (split <;> split <;> rfl)

/-- `emit`'s choice of register (its index in `pool`) and the items left once a dropped reload
is gone. -/
def emitHead (c : Cache) (items : List Item) : Nat × List Item :=
  let pinned := items.any fun | .mulQ _ | .div .. => true | _ => false
  match items with
  | .ld w false .rax m :: tl =>
    if pinned then
      (0, if m.base == Reg.rbp && c.regs[0]!.slot == some (m.disp, w) then tl else items)
    else match c.find m w true with
    | some i => (i, tl)
    | none => (c.fresh, items)
  | _ => (if pinned then 0 else c.fresh, items)

/-- `emit`'s renaming of `rax` to `xr`. -/
def ren (xr : Reg) (it : Item) : Item := mapRegs (fun r => if r == R then xr else r) it

/-- One step of `emit`'s loop. -/
def emitStep (xr : Reg) (st : Cache × Array Item) (it : Item) : Cache × Array Item :=
  let c := st.1
  let it := ren xr it
  let (it, c) := match readOperand it with
    | some (m, w) => match c.find m w false with
      | some i => (withRm it (.reg pool[i]!), c.setEntry i fun e => { e with used := c.tick })
      | none => (it, c)
    | none => (it, c)
  (c.update it, st.2.push it)

theorem forIn_id_yield {α β : Type} (l : List α) (init : β) (body : α → β → Id (ForInStep β))
    (f : β → α → β) (h : ∀ a b, body a b = pure (.yield (f b a))) :
    forIn l init body = pure (l.foldl f init) := by
  induction l generalizing init with
  | nil => rfl
  | cons a l ih => simp only [List.forIn_cons, h, List.foldl_cons]; exact ih _

theorem emit_eq (c : Cache) (items : List Item) :
    c.emit items =
      let c1 : Cache := { c with tick := c.tick + 1 }
      let hd := emitHead c1 items
      let c2 := c1.setEntry hd.1 fun e => { e with used := c1.tick }
      let r := hd.2.foldl (emitStep pool[hd.1]!) (c2, #[])
      (r.2.toList, r.1) := by
  simp only [Cache.emit]
  rw [forIn_id_yield (f := fun st it => emitStep (pool[(emitHead { c with tick := c.tick + 1 } items).1]!) st it)]
  · rfl
  · intro a b
    simp only [emitStep, ren]
    generalize hF : (fun r => if (r == R) = true then
      pool[(emitHead { c with tick := c.tick + 1 } items).1]! else r) = F
    split
    · rename_i m w heq
      have heq' : readOperand (mapRegs F a) = some (m, w) := by rw [← hF]; exact heq
      rw [heq']
      dsimp only
      split
      · rename_i i heq2
        simp only [heq2]
        subst hF
        rfl
      · rename_i heq2
        cases hr : b.fst.find m w false with
        | some i => exact absurd hr (heq2 i)
        | none => subst hF; rfl
    · rename_i heq
      cases hr : readOperand (mapRegs F a) with
      | some p =>
        subst hF
        exact absurd hr (heq p.1 p.2)
      | none => subst hF; rfl

theorem inv_used {c : Cache} {x : X86.State} (h : CacheInv c x) (i t : Nat) :
    CacheInv (c.setEntry i fun e => { e with used := t }) x := by
  refine ⟨by simp [Cache.setEntry, h.1], fun j hj => ?_⟩
  simp only [Cache.setEntry, Array.getElem_modify]
  have hj' : j < c.regs.size := by simpa [Cache.setEntry] using hj
  split
  · exact h.2 j hj'
  · exact h.2 j hj'

theorem pool_ne_rbp' (i : Nat) : pool[i]! ≠ .rbp := by
  by_cases hi : i < 8
  · intro e; exact pool_ne_rbp i hi (by rw [e])
  · rw [getElem!_neg pool i (by simp [pool]; omega)]; decide

theorem cacheSafe_ren {xr : Reg} (hxr : xr ≠ .rbp) {it : Item} (hs : cacheSafe it = true) :
    cacheSafe (ren xr it) = true := by
  have key : ∀ r : Reg, r ≠ .rbp → (if (r == R) = true then xr else r) ≠ .rbp := by
    intro r hr; split <;> assumption
  cases it <;> simp only [cacheSafe, bne_iff_ne, ne_eq, Bool.and_eq_true] at hs <;>
    simp only [ren, mapRegs, cacheSafe, bne_iff_ne, ne_eq, Bool.and_eq_true] <;>
    first
    | trivial
    | exact key _ hs
    | exact ⟨key _ hs.1, hs.2⟩
    | (rename_i rm _; cases rm <;> simp only [mapRegs.mapRm, bne_iff_ne, ne_eq] at hs ⊢ <;> first | exact key _ hs | exact hs)

theorem cacheSafe_withRm {it : Item} (hs : cacheSafe it = true) (i : Nat) :
    cacheSafe (withRm it (.reg pool[i]!)) = true := by
  have := pool_ne_rbp' i
  cases it <;> simp only [withRm] <;> first
    | exact hs
    | simpa [cacheSafe] using this

theorem execItems_cons' (ctx : Ctx) (i : Item) (is : List Item) (s : X86.State) :
    execItems ctx (i :: is) s = (i.exec ctx s >>= fun s1 => execItems ctx is s1) := by
  simp [execItems, List.foldlM_cons]

theorem execItems_push (ctx : Ctx) (out : Array Item) (e : Item) (s : X86.State) :
    execItems ctx (out.push e).toList s = (execItems ctx out.toList s >>= e.exec ctx) := by
  simp [execItems, List.foldlM_append]

theorem execItems_nil' (ctx : Ctx) (s : X86.State) : execItems ctx [] s = .ok s := rfl

theorem jump_rip (s : X86.State) : s.jump s.rip = s := rfl

/-- What one step of the loop emits: the renamed item, or it reading the register the cache
holds its frame operand in. -/
theorem emitStep_cases (xr : Reg) (st : Cache × Array Item) (it : Item) :
    ∃ e c', emitStep xr st it = (c'.update e, st.2.push e) ∧
      ((e = ren xr it ∧ c' = st.1) ∨
       (∃ m w i, readOperand (ren xr it) = some (m, w) ∧ st.1.find m w false = some i ∧
         e = withRm (ren xr it) (.reg pool[i]!) ∧
         c' = st.1.setEntry i fun e => { e with used := st.1.tick })) := by
  simp only [emitStep]
  cases hr : readOperand (ren xr it) with
  | none => exact ⟨_, _, rfl, .inl ⟨rfl, rfl⟩⟩
  | some p =>
    obtain ⟨m, w⟩ := p
    dsimp only
    cases hf : st.1.find m w false with
    | none => exact ⟨_, _, rfl, .inl ⟨rfl, rfl⟩⟩
    | some i => exact ⟨_, _, rfl, .inr ⟨m, w, i, rfl, hf, rfl, rfl⟩⟩

/-- `emit`'s loop: from a state that is the reference's but for `rip` and satisfies the
invariant, the emitted items end in the reference's final state but for `rip`, with the
invariant for the cache after them. -/
theorem loop_sound {ctx : Ctx} {xr : Reg} (hxr : xr ≠ .rbp) {x : X86.State} :
    ∀ (rest : List Item) (st : Cache × Array Item) (y z0 z : X86.State),
      (∀ it ∈ rest, cacheSafe it = true) → execItems ctx st.2.toList x = .ok y →
      y = z0.jump y.rip → CacheInv st.1 y →
      execItems ctx (rest.map (ren xr)) z0 = .ok z →
      ∃ y', execItems ctx (rest.foldl (emitStep xr) st).2.toList x = .ok y' ∧
        y' = z.jump y'.rip ∧ CacheInv (rest.foldl (emitStep xr) st).1 y'
  | [], st, y, z0, z, _, hy, hyz, hc, hz => by
    simp only [List.map_nil, execItems_nil'] at hz
    cases hz
    exact ⟨y, hy, hyz, hc⟩
  | it :: rest, st, y, z0, z, hs, hy, hyz, hc, hz => by
    simp only [List.map_cons, execItems_cons'] at hz
    cases hz1 : (ren xr it).exec ctx z0 with
    | error e => rw [hz1] at hz; exact nomatch hz
    | ok z1 =>
      rw [hz1] at hz
      have hsafe := cacheSafe_ren hxr (hs it (by simp))
      have hrest : ∀ it ∈ rest, cacheSafe it = true := fun it h => hs it (by simp [h])
      -- The renamed item, run from the emitted state.
      have hrun : (ren xr it).exec ctx y =
          .ok (z1.jump (y.rip + BitVec.ofNat 64 (ren xr it).size)) := by
        rw [hyz, exec_jump hsafe, hz1]; rfl
      obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr st it
      simp only [List.foldl_cons, heq]
      have step : ∃ y1, e.exec ctx y = .ok y1 ∧ y1 = z1.jump y1.rip ∧
          CacheInv (c'.update e) y1 := by
        rcases hcase with ⟨rfl, rfl⟩ | ⟨m, w, i, ho, hf, rfl, rfl⟩
        · exact ⟨_, hrun, rfl, update_inv hsafe hc hrun⟩
        · have hw := hc.exec_withRm (ctx := ctx) ho hf
          rw [hrun] at hw
          exact ⟨_, hw, rfl, update_inv (cacheSafe_withRm hsafe i) (inv_used hc _ _) hw⟩
      obtain ⟨y1, hy1, hyz1, hc1⟩ := step
      exact loop_sound hxr rest (c'.update e, st.2.push e) y1 z1 z hrest
        (by rw [execItems_push, hy]; exact hy1) hyz1 hc1 hz

/-- `emit`'s head: either every item stays, or a leading reload is dropped, of a slot the
chosen register caches at that width. -/
theorem emitHead_cases (c : Cache) (items : List Item) (hsz : c.regs.size = 8) :
    (emitHead c items).2 = items ∨
    ∃ w m tl, items = .ld w false .rax m :: tl ∧ (emitHead c items).2 = tl ∧ m.base = .rbp ∧
      (emitHead c items).1 < 8 ∧ c.regs[(emitHead c items).1]!.slot = some (m.disp, w) := by
  unfold emitHead
  dsimp only
  split
  · rename_i w m tl
    by_cases hpin : ((Item.ld w false .rax m :: tl).any fun | .mulQ _ | .div .. => true | _ => false) = true
    · simp only [hpin, ↓reduceIte]
      by_cases hc : (m.base == Reg.rbp && c.regs[0]!.slot == some (m.disp, w)) = true
      · simp only [hc, ↓reduceIte]
        simp only [Bool.and_eq_true, beq_iff_eq] at hc
        exact .inr ⟨w, m, tl, rfl, rfl, hc.1, by decide, hc.2⟩
      · simp only [hc, Bool.false_eq_true, ↓reduceIte]
        first | exact .inl rfl | exact .inl trivial
    · simp only [hpin, Bool.false_eq_true, ↓reduceIte]
      cases hf : c.find m w true with
      | some i =>
        obtain ⟨hb, hi, sw, hsl, hw⟩ := find_spec hf
        simp only [↓reduceIte] at hw
        subst hw
        dsimp only
        exact .inr ⟨sw, m, tl, rfl, rfl, hb, by omega, by rw [getElem!_pos c.regs i hi]; exact hsl⟩
      | none => exact .inl rfl
  · exact .inl rfl

/-- `emit` as a whole: from a state satisfying the invariant, if the sequence on `rax`, renamed
to the register `emit` picks (`pool[(emitHead …).1]`), runs to `z`, the emitted items run to `z`
but for `rip` (same registers, flags, `xmm`s and memory), and the cache after them holds of
that state. -/
theorem emit_sound {ctx : Ctx} {c : Cache} {x z : X86.State} {items : List Item}
    (h : CacheInv c x) (hs : ∀ it ∈ items, cacheSafe it = true)
    (hz : execItems ctx
      (items.map (ren pool[(emitHead { c with tick := c.tick + 1 } items).1]!)) x = .ok z) :
    ∃ y, execItems ctx (c.emit items).1 x = .ok y ∧ y = z.jump y.rip ∧
      CacheInv (c.emit items).2 y := by
  rw [emit_eq]
  dsimp only
  generalize hc1 : ({ c with tick := c.tick + 1 } : Cache) = c1 at hz ⊢
  have h1 : CacheInv c1 x := by rw [← hc1]; exact h
  have hxr := pool_ne_rbp' (emitHead c1 items).1
  have h2 := inv_used h1 (emitHead c1 items).1 (c.tick + 1)
  rcases emitHead_cases c1 items h1.1 with hrest | ⟨w, m, tl, hit, hrest, hb, h8, hsl⟩
  · rw [hrest]
    exact loop_sound hxr items _ x x z hs rfl rfl h2 hz
  · rw [hrest]
    have hld : ren pool[(emitHead c1 items).1]! (.ld w false .rax m) =
        .ld w false pool[(emitHead c1 items).1]! m := by
      cases m; simp only at hb; subst hb; rfl
    subst hit
    simp only [List.map_cons, execItems_cons', hld, h1.reload_of hb h8 hsl] at hz
    refine loop_sound hxr tl _ x _ z (fun it h => hs it (by simp [h])) rfl ?_ h2 hz
    rfl

end Ryo.Proofs.RegCache
