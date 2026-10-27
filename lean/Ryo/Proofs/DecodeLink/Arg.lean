/-
Ryo.Proofs.DecodeLink.Arg — `link_arg`'s bounds (aot.md §C2, toward M3 `decode_sound`): the
argument register `argInsn` records decodes back to itself, `ArgReg.of? (word a) true = some a`,
the hypothesis `ArgRet.arg_step` takes.

- `argInsn_bounds`: `argInsn_read` with `a.size < 32` and `a.index < 2 ^ 24`. An `xmm` argument's
  size is 2 (`movd`) or that of an SSE store and its register below 8 (`decodeItem_xmmOk`); an
  integer one's index is `intIndex`'s, below 6, and its size the bytes the stores move, at most 8:
  the first parse (the stores, `shr`s between them) and the re-read `argStore a d pe` both run
  from `c.pos` to the same end, so (`decodeItem` a function, every item at least a byte) they
  read the same items, and `intStore size` moves `size` bytes only for `size ≤ 8` (otherwise its
  4-, 2- and 1-byte pieces move 7).
- `link_arg_exact`: in memory (`LinkOk`), `link_arg` with `ArgReg.of? r.toNat true = some a` for
  the operand `r = BitVec.ofNat 64 a.word` (`of_word_eq`).
-/
import Ryo.Proofs.DecodeLink.Items

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

/-- The bytes a store item moves. -/
def stBytes : Item → Nat
  | .st w _ _ => w.bits / 8
  | _ => 0

theorem Dec.le {c : Cursor} {p q : Nat} {l : List Item} (h : Dec c p l q) : p ≤ q := by
  induction h with
  | nil => exact Nat.le_refl _
  | cons _ _ ih => omega

/-- `decodeItem` is a function and every item is at least a byte: items read from `p` to `q`
are determined. -/
theorem Dec.det {c : Cursor} {p q : Nat} {l₁ l₂ : List Item} (h₁ : Dec c p l₁ q)
    (h₂ : Dec c p l₂ q) : l₁ = l₂ := by
  induction h₁ generalizing l₂ with
  | nil => cases h₂ with
    | nil => rfl
    | cons hd hr => have := Ryo.X86.decodeItem_pos _ _ _ hd; have := hr.le; omega
  | cons hd hr ih => cases h₂ with
    | nil => have := Ryo.X86.decodeItem_pos _ _ _ hd; have := hr.le; omega
    | cons hd' hr' =>
      rw [hd] at hd'; cases hd'
      rw [ih hr']

theorem intStore_bytes {size : Nat} {r : X86.Reg} {m : M}
    (h : ((intStore size r m).map stBytes).sum = size) : size ≤ 8 := by
  refine Nat.le_of_not_lt fun hs => ?_
  have h4 : size - 0 ≥ 4 := by omega
  have h2 : size - (0 + 4) ≥ 2 := by omega
  have h1 : size - (0 + 4 + 2) ≥ 1 := by omega
  have hn : (size == 1 || size == 2 || size == 4 || size == 8) = false := by
    simp only [Bool.or_eq_false_iff, beq_eq_false_iff_ne]; omega
  simp only [intStore, hn, List.foldl, h4, h2, h1, Bool.false_eq_true, ↓reduceIte] at h
  simp [stBytes, widthOf, W.bits] at h
  omega

/-- `argInsn_read` with the bounds `of_word_eq` needs. -/
theorem argInsn_bounds {mode : Mode} {c c' : Cursor} {q : Proto}
    (h : (argInsn mode).run c = .ok (some q, c')) :
    ∃ (a : ArgReg) (d : BitVec 32),
      q = { op := .arg, ops := [.slot d, .imm (BitVec.ofNat 64 a.word)], pos := c.pos } ∧
      a.size < 32 ∧ a.index < 2 ^ 24 ∧
      (ArgReg.of? a.word true).isSome ∧ Dec c c.pos (argStore a d mode.pe) c'.pos ∧
      c' = atPos c c'.pos := by
  unfold argInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨fi, c2, h2, h⟩ := bind_ok h
  split at h
  case h_2 => obtain ⟨he, -⟩ := pure_ok h; cases he
  rename_i first
  obtain ⟨n1, hn1, rfl⟩ := run_tryItem_some h2
  obtain ⟨r, c3, h3, h⟩ := bind_ok h
  have hR : ∀ a0 mm a, r = some (a0, mm) → a0 = some a →
      (a.xmm = true → a.size < 32 ∧ a.index < 8) ∧
      (a.xmm = false → a.index < 6 ∧ ∃ items, Dec c c.pos items c3.pos ∧
        (items.map stBytes).sum = a.size) := by
    clear h
    intro a0 mm a hr ha
    split at h3
    · obtain ⟨fu, c4, h4, h3⟩ := bind_ok h3
      have := fuel_run h4; subst this
      obtain ⟨sz, c5, h5, h3⟩ := bind_ok h3
      obtain ⟨rfl, rfl⟩ := pure_ok h3
      cases hr
      let I : Nat → Cursor → Prop := fun s cur =>
        ∃ items, Dec c c.pos items cur.pos ∧ (items.map stBytes).sum = s ∧ cur = atPos c cur.pos
      have key := forIn_range_inv I I _ ?step fu _ _ c5 sz ?init h5
      case init => exact ⟨_, Dec.single hn1, by simp [stBytes], rfl⟩
      case step =>
        intro _ b cur r' cur' hI hr
        obtain ⟨items, hd, hs, hc⟩ := hI
        obtain ⟨p, rfl⟩ : ∃ p, cur = atPos c p := ⟨_, hc⟩
        obtain ⟨at_, c6, h6, hr⟩ := bind_ok hr
        obtain ⟨rfl, rfl⟩ := pos_run' h6
        obtain ⟨i1, c7, h7, hr⟩ := bind_ok hr
        obtain ⟨i2, c8, h8, hr⟩ := bind_ok hr
        have e7 := posOnly_run PosOnly.tryItem h7
        have e8 := posOnly_run PosOnly.tryItem h8
        split at hr
        · 
          split at hr
          · obtain ⟨rfl, rfl⟩ := pure_ok hr
            obtain ⟨k1, hk1, rfl⟩ := run_tryItem_some h7
            obtain ⟨k2, hk2, rfl⟩ := run_tryItem_some h8
            exact ⟨_, hd.append (.cons hk1 (Dec.single hk2)), by simp [stBytes, hs], rfl⟩
          · obtain ⟨u, c9, h9, hr⟩ := bind_ok hr
            rw [run_setPos] at h9; cases h9
            obtain ⟨rfl, rfl⟩ := pure_ok hr
            rw [e8, e7]; exact ⟨items, hd, hs, rfl⟩
        · obtain ⟨u, c9, h9, hr⟩ := bind_ok hr
          rw [run_setPos] at h9; cases h9
          obtain ⟨rfl, rfl⟩ := pure_ok hr
          rw [e8, e7]; exact ⟨items, hd, hs, rfl⟩
      obtain ⟨items, hd, hs, -⟩ := key.elim id id
      obtain ⟨k, hk, rfl⟩ := Option.map_eq_some_iff.mp ha
      refine ⟨fun h => (by cases h), fun _ => ⟨?_, items, hd, hs⟩⟩
      have hm := List.mem_of_find?_eq_some hk
      simp only [List.mem_range] at hm
      dsimp only
      split at hm <;> omega
    · obtain ⟨rfl, rfl⟩ := pure_ok h3
      cases hr; cases ha
      have := decodeItem_xmmOk hn1
      simp only [XmmOk] at this
      refine ⟨fun _ => ⟨by dsimp only; omega, this.2.1⟩, fun h => by cases h⟩
    · obtain ⟨i2, c4, h4, h3⟩ := bind_ok h3
      have := decodeItem_xmmOk hn1
      simp only [XmmOk] at this
      split at h3 <;> obtain ⟨rfl, rfl⟩ := pure_ok h3 <;> cases hr <;> cases ha
      exact ⟨fun _ => ⟨by dsimp only; omega, this⟩, fun h => by cases h⟩
    · obtain ⟨rfl, rfl⟩ := pure_ok h3
      cases hr; cases ha
  have e3 := posOnly_run (by posonly) h3
  split at h
  case h_2 => obtain ⟨he, -⟩ := pure_ok h; cases he
  rename_i a0 mm
  obtain ⟨end_, c4, h4, h⟩ := bind_ok h
  obtain ⟨rfl, hc4⟩ := pos_run' h4
  subst c4
  obtain ⟨u, c5, h5, h⟩ := bind_ok h
  rw [run_setPos] at h5; cases h5
  split at h
  case h_2 => obtain ⟨he, -⟩ := pure_ok h; cases he
  rename_i a ha
  have hfa := Option.filter_eq_some_iff.mp ha
  obtain ⟨st, c6, h6, h⟩ := bind_ok h
  have hc3 : atPos c3 c.pos = c := by rw [e3]
  rw [hc3] at h6
  let I : List Item → Option (Option Proto) × Unit → Cursor → Prop := fun pre st cur =>
    st.1 = none ∧ Dec c c.pos pre cur.pos ∧ cur = atPos c cur.pos
  let D : Option (Option Proto) × Unit → Cursor → Prop := fun st _ => st.1 = some none
  have key := forIn_list_pre I D _ ?step (argStore a mm.disp mode.pe) [] (none, ()) c c6 st
    ⟨rfl, .nil _, rfl⟩ h6
  case step =>
    intro pre w b cur r' cur' hI hr
    obtain ⟨-, hd, hc⟩ := hI
    obtain ⟨o, c7, h7, hr2⟩ := bind_ok hr
    by_cases hx : (o != some w) = true
    · simp only [hx, ↓reduceIte] at hr2
      obtain ⟨_, _, -, hr3⟩ := bind_ok hr2
      obtain ⟨rfl, -⟩ := pure_ok hr3
      rfl
    · simp only [hx, Bool.false_eq_true, ↓reduceIte] at hr2
      obtain ⟨rfl, rfl⟩ := pure_ok hr2
      have : o = some w := by simpa using hx
      subst this
      obtain ⟨n, hn, rfl⟩ := run_tryItem_some h7
      refine ⟨rfl, ?_, ?_⟩
      · rw [hc] at hn; exact hd.append (Dec.single hn)
      · rw [hc]
  rcases key with ⟨hst, hd, hc6⟩ | hst
  · dsimp only at h
    rw [hst] at h
    dsimp only at h
    obtain ⟨p7, c7, h7, h⟩ := bind_ok h
    obtain ⟨rfl, hc7⟩ := pos_run' h7
    subst c7
    split at h
    · obtain ⟨_, _, -, h8⟩ := bind_ok h
      obtain ⟨he, -⟩ := pure_ok h8; cases he
    · rename_i hne
      obtain ⟨he, rfl⟩ := pure_ok h
      cases he
      simp only [Bool.and_eq_true, beq_iff_eq] at hfa
      have hd' : Dec c c.pos (argStore a mm.disp mode.pe) c6.pos := by simpa using hd
      obtain ⟨hx, hint⟩ := hR _ _ a rfl hfa.1
      refine ⟨a, mm.disp, rfl, ?_, ?_, hfa.2.1, hd', hc6⟩
      · cases hxa : a.xmm
        · obtain ⟨-, items, hdi, hs⟩ := hint hxa
          have hne : c6.pos = c3.pos := by simpa using hne
          rw [← hne] at hdi
          have := Dec.det hdi hd'
          simp only [argStore, hxa, Bool.false_eq_true, ↓reduceIte] at this
          rw [this] at hs
          have := intStore_bytes hs; omega
        · have := (hx hxa).1; omega
      · cases hxa : a.xmm
        · have := (hint hxa).1; omega
        · have := (hx hxa).2; omega
  · dsimp only at h
    rw [hst] at h
    dsimp only at h
    obtain ⟨he, -⟩ := pure_ok h; cases he


theorem word_lt (a : ArgReg) : a.word < 2 ^ 32 := Nat.mod_lt _ (by decide)

/-- `arg d, r` in memory: the stores `argStore a d pe` with `ArgReg.of? r.toNat true = some a`
(`ArgRet.arg_step`'s `ha`). -/
theorem link_arg_exact {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {mode : Mode}
    {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (argInsn mode).run c = .ok (some q, c')) :
    ∃ (a : ArgReg) (d : BitVec 32), q.op = .arg ∧
      q.ops = [.slot d, .imm (BitVec.ofNat 64 a.word)] ∧ q.handler = none ∧
      ArgReg.of? (BitVec.ofNat 64 a.word).toNat true = some a ∧
      CodeAt ctx m (argStore a d mode.pe) c.pos ∧
      c'.pos = c.pos + codeSize (argStore a d mode.pe) ∧ Boundary rs c'.pos := by
  obtain ⟨a, d, rfl, hs, hi, hof, hd, -⟩ := argInsn_bounds h
  obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
  refine ⟨a, d, rfl, rfl, rfl, ?_, hca, hq, hb'⟩
  have hw : (BitVec.ofNat 64 a.word).toNat = a.word := by
    rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by have := word_lt a; omega)
  rw [hw]
  obtain ⟨b, hb⟩ := Option.isSome_iff_exists.mp hof
  rw [hb, of_word_eq hs hi hb]

end Ryo.Proofs.DecodeLink
