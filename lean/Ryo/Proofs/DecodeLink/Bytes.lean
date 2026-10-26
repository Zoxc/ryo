/-
Ryo.Proofs.DecodeLink.Bytes — what `decodeItem` accepts is in memory (aot.md §C2, toward M3
`decode_sound`): an item the decoder reads at a position of an object's code, with that code
linked into memory, is `ItemAt` there (`Ryo.X86.Fetch`), and a run of items it reads one after
the other is `CodeAt`.

**Memory.** `decodeReduced` reads the object's unlinked bytes with its relocation list
(`Fields.relocs`); x86 runs the linked bytes. `RelocLoaded ctx m code rs`: memory from
`ctx.base` holds `code`, except each relocated field (`r.pos`, 4 bytes), which holds the
little-endian `ctx.addrOf r.to - (field + 4)` (`R_X86_64_PC32`, what `link` writes). Bytes in no
field are `code`'s; a byte in two fields would have to equal both patches (fields of a real
object are disjoint).

**Hypotheses.** The relocations are sorted by position (`Sorted`, the decoder's input order:
`relocsIn`'s binary search, `mem_relocsIn`), the code is below `2 ^ 32` bytes (positions are
32-bit in `encode`), and the item starts at a `Boundary`: no field begins before it and reaches
into it. The decoder checks that the relocations starting inside an accepted item are exactly
its own (`Cursor.encodedAt`), and an item's fields are inside it (`encode_shape`), so a
boundary before an item is one after it (`matchesItem_itemAt`); at position 0 it holds
trivially (`boundary_zero`). Fields starting in bytes the decoder skips without checking for
relocations (a jump table's `int3` padding) are the one place a boundary isn't carried.

- `encode_shape`: an item's encoding has no relocation, or one, a 4-byte field after the bytes
  `pre`, at the end; `encode_len`: its length is `Item.size` at every position.
- `matchesItem_itemAt`: an item `Cursor.matchesItem` accepts at the cursor is `ItemAt` there
  (outside its field the bytes are `code`'s, which `encodedAt` compared with the encoding; in
  it the patch, which `linkedAt` computes the same way), its size is the length read, and the
  boundary moves past it.
- `decodeItem_itemAt`: the same for `decodeItem`, in the frame-pointer form (`c.spFrame =
  none`): there `decodeItem` returns the item it matched. (Without a frame pointer it returns
  the encoder's `[rbp + d]` form of a matched `[rsp + F + d]` item; not covered.)
- `Dec c p items q`: `decodeItem` reads `items` one after the other from position `p` to `q`
  (`c`'s code, fields and frame form); `codeAt_of_dec`: such items are `CodeAt` from `p`, and
  `q = p + codeSize items`.
-/
import Ryo.X86.Unique
import Ryo.X86.Decode

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86


/-- The relocations sorted by position. -/
def Sorted (rs : Array Reloc) : Prop :=
  ∀ i j (hij : i ≤ j) (hj : j < rs.size), (rs[i]'(by omega)).pos ≤ rs[j].pos

theorem lowerBound_go_spec (rs : Array Reloc) (p : Nat) (hs : Sorted rs) :
    ∀ lo hi (hhi : hi ≤ rs.size) (hle : lo ≤ hi),
      (∀ i (h : i < lo), (rs[i]'(by omega)).pos < p) →
      (∀ i (_ : hi ≤ i) (h2 : i < rs.size), p ≤ rs[i].pos) →
      lowerBound.go rs p lo hi ≤ rs.size ∧
      ∀ i (h : i < rs.size), (i < lowerBound.go rs p lo hi ↔ rs[i].pos < p) := by
  intro lo hi
  induction lo, hi using lowerBound.go.induct rs p with
  | case1 lo hi hlt mid below hb ih =>
    subst mid below
    intro hhi hle hlo hhi'
    have hmid : (lo + hi) / 2 < rs.size := by omega
    simp only [Array.getElem?_eq_getElem hmid, decide_eq_true_eq] at hb
    rw [lowerBound.go.eq_1, dite_eq_left_of_eq_true (eq_true hlt)]
    simp only [Array.getElem?_eq_getElem hmid, decide_eq_true_eq, hb, ↓reduceIte]
    apply ih hhi (by omega) _ hhi'
    intro i hi
    by_cases hi' : i < lo
    · exact hlo i hi'
    · exact Nat.lt_of_le_of_lt (hs i _ (by omega) hmid) hb
  | case2 lo hi hlt mid below hb ih =>
    subst mid below
    intro hhi hle hlo hhi'
    have hmid : (lo + hi) / 2 < rs.size := by omega
    simp only [Array.getElem?_eq_getElem hmid, decide_eq_true_eq] at hb
    rw [lowerBound.go.eq_1, dite_eq_left_of_eq_true (eq_true hlt)]
    simp only [Array.getElem?_eq_getElem hmid, decide_eq_true_eq, hb, ↓reduceIte]
    apply ih (by omega) (by omega) hlo
    intro i h1 h2
    exact Nat.le_trans (Nat.le_of_not_lt hb) (hs _ i h1 h2)
  | case3 lo hi hlt =>
    intro hhi hle hlo hhi'
    rw [lowerBound.go.eq_1, dite_eq_right_of_eq_false (eq_false hlt)]
    refine ⟨by omega, fun i h => ⟨fun h' => hlo i h', fun h' => ?_⟩⟩
    refine Nat.lt_of_not_le fun hc => ?_
    have := hhi' i (by omega) h
    omega

theorem lowerBound_spec {rs : Array Reloc} (hs : Sorted rs) (p : Nat) :
    lowerBound rs p ≤ rs.size ∧
      ∀ i (h : i < rs.size), (i < lowerBound rs p ↔ rs[i].pos < p) :=
  lowerBound_go_spec rs p hs 0 rs.size (Nat.le_refl _) (Nat.zero_le _) (fun _ h => absurd h (Nat.not_lt_zero _))
    (fun _ h1 h2 => absurd h2 (by omega))

theorem mem_relocsIn {rs : Array Reloc} (hs : Sorted rs) (a len : Nat) (r : Reloc) :
    r ∈ relocsIn rs a len ↔ r ∈ rs.toList ∧ a ≤ r.pos ∧ r.pos < a + len := by
  obtain ⟨hl1, hs1⟩ := lowerBound_spec hs a
  obtain ⟨hl2, hs2⟩ := lowerBound_spec hs (a + len)
  simp only [relocsIn, Array.mem_toList_iff, Array.mem_iff_getElem, Array.size_extract,
    Array.getElem_extract]
  constructor
  · rintro ⟨i, hi, rfl⟩
    have hi' : lowerBound rs a + i < rs.size := by omega
    refine ⟨⟨_, hi', rfl⟩, ?_, ?_⟩
    · exact Nat.le_of_not_lt fun h => absurd ((hs1 _ hi').mpr h) (by omega)
    · exact (hs2 _ hi').mp (by omega)
  · rintro ⟨⟨j, hj, rfl⟩, h1, h2⟩
    have hj1 : lowerBound rs a ≤ j :=
      Nat.le_of_not_lt fun hc => absurd ((hs1 j hj).mp hc) (by omega)
    have hj2 : j < lowerBound rs (a + len) := (hs2 j hj).mpr h2
    refine ⟨j - lowerBound rs a, by omega, ?_⟩
    congr 1; omega

theorem encode_shape (i : Item) (p : BitVec 32) :
    (i.encode p).2 = [] ∨
      ∃ pre to, i.encode p = (pre ++ [0, 0, 0, 0], [⟨p.toNat + pre.length, to⟩]) := by
  cases i
  case lea r to => exact Or.inr ⟨[byte (0x48 ||| (if r.ext then 1 else 0) <<< 2), 0x8d, byte (0x05 ||| r.low <<< 3)], to, rfl⟩
  case loadRip r to => exact Or.inr ⟨[byte (0x48 ||| (if r.ext then 1 else 0) <<< 2), 0x8b, byte (0x05 ||| r.low <<< 3)], to, rfl⟩
  case call to => exact Or.inr ⟨[0xe8], to, rfl⟩
  case callMem to => exact Or.inr ⟨[0xff, 0x15], to, rfl⟩
  case jmp to => exact Or.inr ⟨[0xe9], to, rfl⟩
  case ctrInc lp => exact Or.inr ⟨[0x48, 0xff, 0x05], _, rfl⟩
  all_goals (left; (try simp only [Item.encode]) <;> (try split) <;> (try split) <;> rfl)

theorem encode_len (i : Item) (p : BitVec 32) : (i.encode p).1.length = i.size := by
  cases i <;> simp only [Item.size, Item.len, Item.encode] <;> (try split) <;> (try split) <;> simp [leBytes]

/-- No relocated field starts before `p` and reaches `p` or past it. -/
def Boundary (rs : Array Reloc) (p : Nat) : Prop := ∀ r ∈ rs.toList, r.pos < p → r.pos + 4 ≤ p

/-- The code linked in memory from `ctx.base`: `code`'s bytes outside the relocated fields,
each field the linker's patch (see the module comment). -/
def RelocLoaded (ctx : Ctx) (m : Mem) (code : Array UInt8) (rs : Array Reloc) : Prop :=
  (∀ j (h : j < code.size), (∀ r ∈ rs.toList, ¬ (r.pos ≤ j ∧ j < r.pos + 4)) →
    m (addrAt ctx j) = code[j]) ∧
  (∀ r ∈ rs.toList, ∀ k (hk : k < 4), m (addrAt ctx (r.pos + k)) =
    (leBytes (ctx.addrOf r.to - (addrAt ctx r.pos + 4)) 4)[k]'(by simp [leBytes]; exact hk))

theorem addrAt_add' (ctx : Ctx) (p j : Nat) : addrAt ctx p + BitVec.ofNat 64 j = addrAt ctx (p + j) := by
  simp [addrAt, BitVec.add_assoc, BitVec.ofNat_add]

theorem encodedAt_spec {c : Cursor} {bs : List UInt8} {rs : List Reloc}
    (h : c.encodedAt bs rs = true) :
    ∃ hle : c.pos + bs.length ≤ c.code.size,
      (∀ j (hj : j < bs.length), (rs.any fun r => r.pos ≤ c.pos + j && c.pos + j < r.pos + 4) = false →
        c.code[c.pos + j]'(by omega) = bs[j]) ∧
      (∀ rs', c.fields = .relocs rs' → relocsIn rs' c.pos bs.length = rs) := by
  unfold Cursor.encodedAt at h
  unfold Cursor.bytes at h
  split at h
  · exact absurd h (by simp)
  · rename_i here hb
    split at hb
    · rename_i hle
      cases hb
      simp only [Bool.and_eq_true, List.all_eq_true, List.mem_range] at h
      refine ⟨hle, fun j hj hn => ?_, fun rs' hf => ?_⟩
      · have := h.1 j hj
        simp only [hn, Bool.false_or, beq_iff_eq] at this
        rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD,
          List.getElem?_eq_getElem hj, List.getElem?_eq_getElem (by simp; omega)] at this
        simpa using this
      · have := h.2
        simp only [hf, Cursor.relocsHere, beq_iff_eq] at this
        exact this
    · simp at hb

theorem matchesItem_itemAt {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {i : Item}
    {n : Nat} (hf : c.fields = .relocs rs) (hs : Sorted rs) (hL : RelocLoaded ctx m c.code rs)
    (hsz : c.code.size < 2 ^ 32) (hb : Boundary rs c.pos) (h : c.matchesItem i = some n) :
    ItemAt ctx m i c.pos ∧ i.size = n ∧ c.pos + n ≤ c.code.size ∧ Boundary rs (c.pos + n) := by
  unfold Cursor.matchesItem at h
  simp only [Bool.and_eq_true, decide_eq_true_eq] at h
  split at h
  · rename_i hc
    cases h
    obtain ⟨hle, hsame, hrel⟩ := encodedAt_spec hc.1
    have hrel := hrel rs hf
    have hP : (BitVec.ofNat 32 c.pos).toNat = c.pos := by
      rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
    have hlen := encode_len i (BitVec.ofNat 32 c.pos)
    refine ⟨?_, hlen.symm, hle, ?_⟩
    rotate_left
    · intro r hr hlt
      by_cases h0 : r.pos < c.pos
      · exact Nat.le_trans (hb r hr h0) (Nat.le_add_right _ _)
      · have hin : r ∈ relocsIn rs c.pos (i.encode (BitVec.ofNat 32 c.pos)).1.length :=
          (mem_relocsIn hs _ _ r).mpr ⟨hr, by omega, hlt⟩
        rw [hrel] at hin
        rcases encode_shape i (BitVec.ofNat 32 c.pos) with he | ⟨pre, to, he⟩
        · rw [he] at hin; cases hin
        · rw [he] at hin
          simp only [List.mem_singleton] at hin
          subst hin
          simp only [he, List.length_append, List.length_cons, List.length_nil, hP]
          omega
    rcases encode_shape i (BitVec.ofNat 32 c.pos) with he | ⟨pre, to, he⟩
    · rw [ItemAt, Uniq.linkedAt_plain ctx i c.pos he]
      intro j hj
      rw [addrAt_add']
      rw [hL.1 (c.pos + j) (by omega) ?_]
      · exact hsame j hj (by rw [he]; rfl)
      · rintro r hr ⟨h1, h2⟩
        by_cases h0 : r.pos < c.pos
        · have := hb r hr h0; omega
        · have hin : r ∈ relocsIn rs c.pos (i.encode (BitVec.ofNat 32 c.pos)).1.length :=
            (mem_relocsIn hs _ _ r).mpr ⟨hr, by omega, by omega⟩
          rw [hrel, he] at hin; cases hin
    · rw [hP] at he
      have hl := Uniq.linkedAt_ref ctx i c.pos pre to (by rw [hP]; exact he)
      rw [ItemAt, hl]
      have hr0 : (⟨c.pos + pre.length, to⟩ : Reloc) ∈ rs.toList := by
        have : (⟨c.pos + pre.length, to⟩ : Reloc) ∈ relocsIn rs c.pos (i.encode (BitVec.ofNat 32 c.pos)).1.length := by
          rw [hrel, he]; simp
        exact ((mem_relocsIn hs _ _ _).mp this).1
      have hlen' : (i.encode (BitVec.ofNat 32 c.pos)).1.length = pre.length + 4 := by
        rw [he]; simp
      intro j hj
      simp only [List.length_append, leBytes, List.length_map, List.length_range] at hj
      rw [addrAt_add']
      by_cases hjp : j < pre.length
      · rw [List.getElem_append_left hjp]
        rw [hL.1 (c.pos + j) (by omega) ?_]
        · have := hsame j (by omega) (by
            rw [he]; simp only [List.any_cons, List.any_nil, Bool.or_false, Bool.and_eq_false_iff,
              decide_eq_false_iff_not]; omega)
          rw [this, List.getElem_of_eq (congrArg Prod.fst he)]
          simp only
          rw [List.getElem_append_left hjp]
        · rintro r hr ⟨h1, h2⟩
          by_cases h0 : r.pos < c.pos
          · have := hb r hr h0; omega
          · have hin : r ∈ relocsIn rs c.pos (i.encode (BitVec.ofNat 32 c.pos)).1.length :=
              (mem_relocsIn hs _ _ r).mpr ⟨hr, by omega, by omega⟩
            rw [hrel, he] at hin
            simp only [List.mem_singleton] at hin
            subst hin; simp at h1; omega
      · rw [List.getElem_append_right (by omega)]
        have hk := hL.2 _ hr0 (j - pre.length) (by omega)
        simp only [show c.pos + pre.length + (j - pre.length) = c.pos + j by omega] at hk
        rw [hk]
        simp only [leBytes, List.getElem_map, List.getElem_range]
        congr 3
        simp [addrAt, BitVec.add_assoc, BitVec.ofNat_add]
  · cases h

theorem boundary_zero (rs : Array Reloc) : Boundary rs 0 := fun _ _ h => absurd h (Nat.not_lt_zero _)

/-- With the frame-pointer form, `decodeItem` returns an item `matchesItem` accepts. -/
theorem decodeItem_matches {c : Cursor} {j : Item} {n : Nat} (hsp : c.spFrame = none)
    (h : decodeItem c = some (j, n)) : c.matchesItem j = some n := by
  have hacc : ∀ (post : Item → Option Item) (i : Item), (∀ k, post i = some k → k = i) →
      c.accept post i = some (j, n) → c.matchesItem j = some n := by
    intro post i hp ha
    unfold Cursor.accept at ha
    cases hm : c.matchesItem i <;> cases hq : post i <;> simp only [hm, hq] at ha
    · cases ha
    · cases ha
    · cases ha
    · rename_i n' k
      simp only [Option.some.injEq, Prod.mk.injEq] at ha
      obtain ⟨rfl, rfl⟩ := ha
      rw [hp _ hq]; exact hm
  have hfs : ∀ i k, c.fromSpFrame i = some k → k = i := by
    intro i k hk
    unfold Cursor.fromSpFrame at hk
    rw [hsp] at hk
    revert hk
    cases i.mem?.map (·.base) with
    | none => intro hk; cases hk; rfl
    | some b => cases b <;> intro hk <;> first | (cases hk; rfl) | cases hk
  unfold decodeItem at h
  rcases Option.orElse_some' h with h | h
  · obtain ⟨i, -, h⟩ := Option.bind_eq_some_iff.mp h
    exact hacc some i (fun k hk => (Option.some.inj hk).symm) h
  · rcases Option.orElse_some' h with h | h <;>
    · obtain ⟨i, -, h⟩ := Option.bind_eq_some_iff.mp h
      exact hacc _ i (hfs i) h

/-- An item `decodeItem` reads in the frame-pointer form is in memory at the cursor. -/
theorem decodeItem_itemAt {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {i : Item}
    {n : Nat} (hf : c.fields = .relocs rs) (hs : Sorted rs) (hL : RelocLoaded ctx m c.code rs)
    (hsz : c.code.size < 2 ^ 32) (hsp : c.spFrame = none) (hb : Boundary rs c.pos)
    (h : decodeItem c = some (i, n)) :
    ItemAt ctx m i c.pos ∧ i.size = n ∧ c.pos + n ≤ c.code.size ∧ Boundary rs (c.pos + n) :=
  matchesItem_itemAt hf hs hL hsz hb (decodeItem_matches hsp h)

/-! ### Runs of items -/

/-- The cursor `c` moved to position `p`. -/
abbrev atPos (c : Cursor) (p : Nat) : Cursor := { c with pos := p }

/-- `decodeItem` reads `items` one after the other from position `p`, ending at `q`. -/
inductive Dec (c : Cursor) : Nat → List Item → Nat → Prop
  | nil (p : Nat) : Dec c p [] p
  | cons {p n q : Nat} {i : Item} {is : List Item} :
      decodeItem (atPos c p) = some (i, n) → Dec c (p + n) is q → Dec c p (i :: is) q

theorem Dec.append {c : Cursor} {p q r : Nat} {a b : List Item} (ha : Dec c p a q)
    (hb : Dec c q b r) : Dec c p (a ++ b) r := by
  induction ha with
  | nil => exact hb
  | cons h _ ih => exact .cons h (ih hb)

theorem Dec.single {c : Cursor} {p n : Nat} {i : Item} (h : decodeItem (atPos c p) = some (i, n)) :
    Dec c p [i] (p + n) := .cons h (.nil _)

theorem Dec.at_iff {c : Cursor} {p q r : Nat} {items : List Item} :
    Dec (atPos c r) p items q ↔ Dec c p items q := by
  constructor
  · intro h
    induction h with
    | nil => exact .nil _
    | cons h _ ih => exact .cons h ih
  · intro h
    induction h with
    | nil => exact .nil _
    | cons h _ ih => exact .cons h ih

/-- Items read one after the other, in the frame-pointer form, are in memory from where the
reading started. -/
theorem codeAt_of_dec {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hf : c.fields = .relocs rs) (hs : Sorted rs) (hL : RelocLoaded ctx m c.code rs)
    (hsz : c.code.size < 2 ^ 32) (hsp : c.spFrame = none) :
    ∀ {p q : Nat} {items : List Item}, Dec c p items q → Boundary rs p →
      CodeAt ctx m items p ∧ q = p + codeSize items ∧ Boundary rs q
  | _, _, _, .nil p, hb => ⟨trivial, by simp [codeSize], hb⟩
  | _, _, _, .cons (p := p) (n := n) (i := i) hd hrest, hb => by
    obtain ⟨hi, hn, -, hb'⟩ := decodeItem_itemAt (c := atPos c p) hf hs hL hsz hsp hb hd
    obtain ⟨hc, hq, hb''⟩ := codeAt_of_dec hf hs hL hsz hsp hrest hb'
    refine ⟨⟨hi, ?_⟩, ?_, hb''⟩
    · rw [hn]; exact hc
    · rw [hq, codeSize_cons, hn, Nat.add_assoc]

end Ryo.Proofs.DecodeLink
