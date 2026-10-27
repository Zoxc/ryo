/-
Ryo.Proofs.DecodeLink.Ops — the island operand array in memory (aot.md §C2, toward M3
`decode_sound`): what `opsArray` read from the function's rodata is, with the rodata linked
into memory, `Island.OpsAt` at the array's address (`Island.island_sound`'s `hro`).

- `rdLE ro p`: `opsArray`'s little-endian `u32` read at `p`; `opsArray_spec`: the array at `o`
  has the count `rdLE ro (o - 4)` and its words `rdLE ro (o + 4 * i)`.
- `RoLoaded ctx m ro`: memory holds `ro` from some address `base`, and `.ro o` is linked at
  `base + o` (the image layout, as `Inline.Globals` states it for constants and data).
- `readNat_rdLE`: a word `rdLE` read is the 4-byte little-endian number in memory there.
- `opsAt_of_opsArray`: `OpsAt m (ctx.addrOf (.ro o)) (ws.map (·.toInt))`.
-/
import Ryo.Proofs.DecodeLink.Links

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

/-- `opsArray`'s read: the little-endian `u32` at `p` of `ro`. -/
def rdLE (ro : ByteArray) (p : Nat) : Option (BitVec 32) :=
  if p + 4 ≤ ro.size then
    some (BitVec.ofNat 32 (ro[p]!.toNat ||| ro[p+1]!.toNat <<< 8 ||| ro[p+2]!.toNat <<< 16 |||
      ro[p+3]!.toNat <<< 24))
  else none

theorem opsLoop_spec (rd : Nat → Option (BitVec 32)) :
    ∀ (l : List Nat) (acc : Array (BitVec 32)) (r : Option (Option (List (BitVec 32))) × Array (BitVec 32)),
      forIn (m := Id) l ((none : Option (Option (List (BitVec 32)))), acc) (fun i s =>
        match rd i with
        | some w => pure (ForInStep.yield (none, s.2.push w))
        | none => pure (ForInStep.done (some none, s.2))) = r →
      (r.1 = none ∧ ∃ ext, r.2.toList = acc.toList ++ ext ∧ ext.length = l.length ∧
        ∀ k (h1 : k < l.length) (h2 : k < ext.length), rd l[k] = some ext[k]) ∨ r.1 = some none
  | [], acc, r, h => by
    simp only [List.forIn_nil] at h; subst h
    exact .inl ⟨rfl, [], by show acc.toList = acc.toList ++ []; simp, rfl,
      fun k h => absurd h (by simp)⟩
  | i :: l, acc, r, h => by
    simp only [List.forIn_cons] at h
    cases hi : rd i with
    | none =>
      simp only [hi] at h
      subst h; exact .inr rfl
    | some w =>
      simp only [hi] at h
      rcases opsLoop_spec rd l (acc.push w) r h with ⟨h1, ext, he, hl, hr⟩ | h1
      · refine .inl ⟨h1, w :: ext, by simp [he], by simp [hl], fun k hk1 hk2 => ?_⟩
        cases k with
        | zero => simpa using hi
        | succ k => exact hr k (by simpa using hk1) (by simpa using hk2)
      · exact .inr h1

/-- What `opsArray` read at `o`: the count before the array, then the words. -/
theorem opsArray_spec {ro : ByteArray} {o : Nat} {ws : List (BitVec 32)}
    (h : opsArray ro o = some ws) :
    4 ≤ o ∧ (∃ n, rdLE ro (o - 4) = some n ∧ n.toNat = ws.length) ∧
      ∀ i (hi : i < ws.length), rdLE ro (o + 4 * i) = some ws[i] := by
  unfold opsArray at h
  simp only [Id.run] at h
  split at h
  · cases h
  rename_i ho
  split at h
  · rename_i n hn
    generalize hr : (forIn (m := Id) [:n.toNat]
      ((none : Option (Option (List (BitVec 32)))), (#[] : Array (BitVec 32))) _) = r at h
    rw [Std.Legacy.Range.forIn_eq_forIn_range'] at hr
    have hn' : rdLE ro (o - 4) = some n := hn
    rcases opsLoop_spec (fun i => rdLE ro (o + 4 * i)) _ #[] r hr with ⟨h1, ext, he, hl, hrd⟩ | h1
    · obtain ⟨r1, r2⟩ := r
      simp only at h1 he
      subst h1
      simp only [bind] at h
      have h' : some r2.toList = some ws := h
      cases h'
      have hl' : ext.length = n.toNat := by rw [hl]; simp [Std.Legacy.Range.size]
      simp only [Array.toList_empty, List.nil_append] at he
      refine ⟨by omega, ⟨n, hn', ?_⟩, fun i hi => ?_⟩
      · rw [he, hl']
      · have hi' : i < ext.length := by rw [← he]; exact hi
        have := hrd i (by rw [← hl]; exact hi') hi'
        simp only [List.getElem_range', Std.Legacy.Range.size] at this
        simp only [he]
        simpa using this
    · obtain ⟨r1, r2⟩ := r
      simp only at h1
      subst h1
      simp only [bind] at h
      have h' : (none : Option (List (BitVec 32))) = some ws := h
      cases h'
  · cases h

/-- The function's rodata in memory: from `base`, `.ro o` linked at `base + o`. -/
def RoLoaded (ctx : Ctx) (m : Mem) (ro : ByteArray) : Prop :=
  ∃ base : BitVec 64, (∀ o, ctx.addrOf (.ro o) = base + BitVec.ofNat 64 o) ∧
    ∀ j (h : j < ro.size), m (base + BitVec.ofNat 64 j) = ro[j]

theorem le_bytes_or (a b c d : Nat) (ha : a < 256) (hb : b < 256) (hc : c < 256) (hd : d < 256) :
    (BitVec.ofNat 32 (a ||| b <<< 8 ||| c <<< 16 ||| d <<< 24)).toNat =
      a + 256 * (b + 256 * (c + 256 * (d + 256 * 0))) := by
  have e1 : a ||| b <<< 8 = b <<< 8 + a := by
    rw [Nat.or_comm, Nat.shiftLeft_add_eq_or_of_lt (i := 8) (by omega) b]
  have h2 : b <<< 8 + a < 2 ^ 16 := by rw [Nat.shiftLeft_eq]; omega
  have e2 : b <<< 8 + a ||| c <<< 16 = c <<< 16 + (b <<< 8 + a) := by
    rw [Nat.or_comm, Nat.shiftLeft_add_eq_or_of_lt h2 c]
  have h3 : c <<< 16 + (b <<< 8 + a) < 2 ^ 24 := by simp only [Nat.shiftLeft_eq]; omega
  have e3 : c <<< 16 + (b <<< 8 + a) ||| d <<< 24 = d <<< 24 + (c <<< 16 + (b <<< 8 + a)) := by
    rw [Nat.or_comm, Nat.shiftLeft_add_eq_or_of_lt h3 d]
  rw [e1, e2, e3, BitVec.toNat_ofNat]
  simp only [Nat.shiftLeft_eq]
  rw [Nat.mod_eq_of_lt (by omega)]
  omega

/-- A word `rdLE` read is the 4-byte number in memory there. -/
theorem readNat_rdLE {m : Mem} {ro : ByteArray} {base : BitVec 64}
    (hb : ∀ j (h : j < ro.size), m (base + BitVec.ofNat 64 j) = ro[j]) {p : Nat} {w : BitVec 32}
    (h : rdLE ro p = some w) : m.readNat (base + BitVec.ofNat 64 p) 4 = w.toNat := by
  unfold rdLE at h
  split at h
  · rename_i hle
    cases h
    have hm : ∀ k, k < 4 → m (base + BitVec.ofNat 64 p + BitVec.ofNat 64 k) = ro[p + k]! := by
      intro k hk
      rw [BitVec.add_assoc, ← BitVec.ofNat_add, hb _ (by omega)]
      simp [getElem!_pos ro (p + k) (by omega)]
    simp only [Mem.readNat, List.range, List.range.loop, List.foldr_cons, List.foldr_nil]
    rw [hm 0 (by omega), hm 1 (by omega), hm 2 (by omega), hm 3 (by omega), Nat.add_zero]
    rw [le_bytes_or _ _ _ _ (UInt8.toNat_lt _) (UInt8.toNat_lt _) (UInt8.toNat_lt _)
      (UInt8.toNat_lt _)]
  · cases h

/-- The island's operand array, as `opsArray` read it, is `OpsAt` its linked address. -/
theorem opsAt_of_opsArray {ctx : Ctx} {m : Mem} {ro : ByteArray} {o : Nat}
    {ws : List (BitVec 32)} (hro : RoLoaded ctx m ro) (h : opsArray ro o = some ws) :
    Island.OpsAt m (ctx.addrOf (.ro o)) (ws.map (·.toInt)) := by
  obtain ⟨base, ha, hb⟩ := hro
  obtain ⟨ho, ⟨n, hn, hnl⟩, hw⟩ := opsArray_spec h
  rw [ha]
  refine ⟨?_, fun i hi => ?_⟩
  · have e : base + BitVec.ofNat 64 o - 4 = base + BitVec.ofNat 64 (o - 4) := by
      have : BitVec.ofNat 64 o = BitVec.ofNat 64 (o - 4) + 4 := by
        rw [show (4 : BitVec 64) = BitVec.ofNat 64 4 from rfl, ← BitVec.ofNat_add,
          Nat.sub_add_cancel ho]
      rw [this]; bv_omega
    rw [e, readNat_rdLE hb hn, hnl, List.length_map]
  · simp only [List.length_map] at hi
    rw [BitVec.add_assoc, ← BitVec.ofNat_add, readNat_rdLE hb (hw i hi)]
    simp [BitVec.ofInt_toInt]

end Ryo.Proofs.DecodeLink
