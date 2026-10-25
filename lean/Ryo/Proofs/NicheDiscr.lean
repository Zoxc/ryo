/-
Ryo.Proofs.NicheDiscr — the lowered decoding of a niche-encoded enum's discriminant
(`FnCx::niche_discr`, `backend/src/rustc_api/lower/adt.rs`, after cg_ssa's
`codegen_get_discr`) against the spec's `tagToVariant` (`Spec/Lang/Representation.lean`).

`nicheDiscr tw dw untagged start end_ ns tag` is the value the emitted plain ops leave in the
`dw`-bit destination, op for op, from the `tw`-bit tag `tag`, for the niche variants
`start..=end_` with tag value `ns` for `start`:

- one niche variant (`start = end_`): `b = tag == ns` (`eq.imm`; `ne.imm` when
  `untagged = start + 1`), zero-extended, then `lo + b` when `start` and `untagged` are
  adjacent (`lo` the smaller-by-the-polarity one), else `((-b) & (start ^ untagged)) ^ untagged`;
- otherwise `r = tag - ns` (`sub.imm`), `b = r <=u end_ - start` (`le.u.imm`),
  `d = zext r + start`, `m = -(zext b)`, `d = ((d ^ untagged) & m) ^ untagged`.

`nicheDiscr_sound`: wherever `tagToVariant` decodes a tag (in range) to a variant index, the
lowered ops compute that index (at `dw` bits), given that the niche range `hi - lo` fits the
tag (the `le.u.imm` immediate isn't truncated). The fused `SwitchInt` form (`br.eq.imm` per
arm, `switch.dense`) is not covered.
-/
import Ryo.Spec.Lang.Representation

namespace Ryo.Proofs.NicheDiscr

open Ryo.Spec

/-- The lowered niche decoding (see the module comment). -/
def nicheDiscr (tw dw : Nat) (untagged start end_ ns : Nat) (tag : BitVec tw) : BitVec dw :=
  let u := BitVec.ofNat dw untagged
  let s := BitVec.ofNat dw start
  if start = end_ then
    let ne := untagged = start + 1
    let lo := if ne then start else untagged
    let b : BitVec 8 := if (tag == BitVec.ofNat tw ns) != decide ne then 1 else 0
    let d := b.setWidth dw
    if start + 1 = untagged ∨ untagged + 1 = start then d + BitVec.ofNat dw lo
    else ((-d) &&& (s ^^^ u)) ^^^ u
  else
    let r := tag - BitVec.ofNat tw ns
    let b : BitVec 8 := if r ≤ BitVec.ofNat tw (end_ - start) then 1 else 0
    let d := r.setWidth dw + s
    let m := -(b.setWidth dw)
    ((d ^^^ u) &&& m) ^^^ u

theorem mask_one {w : Nat} (x u : BitVec w) : ((x ^^^ u) &&& -((1 : BitVec 8).setWidth w)) ^^^ u = x := by
  have : -((1 : BitVec 8).setWidth w) = BitVec.allOnes w := by
    cases w with
    | zero => exact Subsingleton.elim _ _
    | succ n =>
      apply BitVec.eq_of_toNat_eq
      simp [BitVec.toNat_neg, BitVec.toNat_setWidth]
  rw [this, BitVec.and_allOnes, BitVec.xor_assoc, BitVec.xor_self, BitVec.xor_zero]

theorem mask_zero {w : Nat} (x u : BitVec w) : ((x ^^^ u) &&& -((0 : BitVec 8).setWidth w)) ^^^ u = u := by
  simp

theorem neg_one_and {w : Nat} (c : BitVec w) : (-((1 : BitVec 8).setWidth w)) &&& c = c := by
  have h := mask_one c 0
  simpa [BitVec.and_comm] using h

/-- The tag minus `ns`, at the tag's width: the spec's `rel`. -/
theorem sub_toNat (tw bits ns : Nat) (hb : bits < 2 ^ tw) :
    (BitVec.ofNat tw bits - BitVec.ofNat tw ns).toNat = (bits + 2 ^ tw - ns % 2 ^ tw) % 2 ^ tw := by
  rw [BitVec.toNat_sub, BitVec.toNat_ofNat, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hb]
  have := Nat.mod_lt ns (Nat.two_pow_pos tw)
  congr 1; omega

/-- The lowered decoding computes `tagToVariant`'s variant index (see the module comment). -/
theorem nicheDiscr_sound {vs : List Variant} {discrTy : IntType} {tag : TagInfo}
    {dw untagged lo hi ns bits idx : Nat} (he : tag.encoding = .niche untagged lo hi ns)
    (hb : bits < tag.tag.modulus) (hr : hi - lo < tag.tag.modulus)
    (h : tagToVariant vs discrTy tag bits = .ok idx) :
    nicheDiscr tag.tag.bits dw untagged lo hi ns (BitVec.ofNat _ bits) = BitVec.ofNat dw idx := by
  simp only [IntType.modulus] at hb hr
  simp only [tagToVariant, he, IntType.modulus] at h
  have hsub := sub_toNat tag.tag.bits bits ns hb
  have hc : ((bits + 2 ^ tag.tag.bits - ns % 2 ^ tag.tag.bits) % 2 ^ tag.tag.bits ≤ hi - lo ∧
      lo + (bits + 2 ^ tag.tag.bits - ns % 2 ^ tag.tag.bits) % 2 ^ tag.tag.bits ≠ untagged ∧
      idx = lo + (bits + 2 ^ tag.tag.bits - ns % 2 ^ tag.tag.bits) % 2 ^ tag.tag.bits) ∨
      (¬ (bits + 2 ^ tag.tag.bits - ns % 2 ^ tag.tag.bits) % 2 ^ tag.tag.bits ≤ hi - lo ∧
        idx = untagged) := by
    by_cases h1 : (bits + 2 ^ tag.tag.bits - ns % 2 ^ tag.tag.bits) % 2 ^ tag.tag.bits ≤ hi - lo
    · simp only [h1, ↓reduceIte] at h
      by_cases h2 : lo + (bits + 2 ^ tag.tag.bits - ns % 2 ^ tag.tag.bits) % 2 ^ tag.tag.bits = untagged
      · simp [h2] at h
      · simp only [h2, ↓reduceIte, beq_iff_eq] at h
        cases h; exact .inl ⟨h1, h2, rfl⟩
    · simp only [h1, ↓reduceIte] at h
      by_cases h3 : tag.valid.contains bits = true
      · simp only [h3, Bool.not_true, Bool.false_eq_true, ↓reduceIte] at h
        cases h; exact .inr ⟨h1, rfl⟩
      · simp [h3] at h
  clear h
  generalize hrel : (bits + 2 ^ tag.tag.bits - ns % 2 ^ tag.tag.bits) % 2 ^ tag.tag.bits = rel at hc hsub
  generalize tag.tag.bits = tw at *
  have heq : (BitVec.ofNat tw bits == BitVec.ofNat tw ns) = decide (rel = 0) := by
    rw [← hsub]
    have hi : BitVec.ofNat tw bits = BitVec.ofNat tw ns ↔
        (BitVec.ofNat tw bits - BitVec.ofNat tw ns).toNat = 0 := by
      constructor
      · intro h; simp [h]
      · intro h
        have h0 : BitVec.ofNat tw bits - BitVec.ofNat tw ns = 0 :=
          BitVec.eq_of_toNat_eq (by simpa using h)
        have := BitVec.sub_add_cancel (BitVec.ofNat tw bits) (BitVec.ofNat tw ns)
        simp only [h0] at this
        simpa using this.symm
    rw [Bool.eq_iff_iff, beq_iff_eq, decide_eq_true_iff]
    exact hi
  have hle : (BitVec.ofNat tw bits - BitVec.ofNat tw ns ≤ BitVec.ofNat tw (hi - lo)) ↔
      rel ≤ hi - lo := by
    rw [BitVec.le_def, hsub, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hr]
  have hsw : (BitVec.ofNat tw bits - BitVec.ofNat tw ns).setWidth dw = BitVec.ofNat dw rel := by
    apply BitVec.eq_of_toNat_eq
    rw [BitVec.toNat_setWidth, hsub, BitVec.toNat_ofNat]
  unfold nicheDiscr
  by_cases hlh : lo = hi
  · subst hlh
    simp only [↓reduceIte, heq]
    have h1w : (1#8).setWidth dw = 1#dw :=
      BitVec.eq_of_toNat_eq (by simp [BitVec.toNat_setWidth])
    rcases hc with ⟨h1, h2, rfl⟩ | ⟨h1, hidx⟩
    · have : rel = 0 := by omega
      subst this
      by_cases ha : untagged = lo + 1
      · simp [ha]
      · by_cases hb' : untagged + 1 = lo
        · subst hb'
          simp [ha, h1w, BitVec.ofNat_add, BitVec.add_comm]
        · have hc' : ¬ (lo + 1 = untagged ∨ untagged + 1 = lo) := by omega
          simp only [hc', ha, ↓reduceIte, decide_true, decide_false]
          have := neg_one_and (w := dw) (BitVec.ofNat dw lo ^^^ BitVec.ofNat dw untagged)
          simp only [show (true != false) = true from rfl, ↓reduceIte, Nat.add_zero]
          rw [this, BitVec.xor_assoc, BitVec.xor_self, BitVec.xor_zero]
    · rw [hidx]
      have : rel ≠ 0 := by omega
      by_cases ha : untagged = lo + 1
      · subst ha
        simp [this, h1w, BitVec.ofNat_add, BitVec.add_comm]
      · by_cases hb' : untagged + 1 = lo
        · simp [ha, hb', this]
        · have hc' : ¬ (lo + 1 = untagged ∨ untagged + 1 = lo) := by omega
          simp [hc', ha, this]
  · simp only [hlh, ↓reduceIte, hsw]
    rcases hc with ⟨h1, -, rfl⟩ | ⟨h1, rfl⟩
    · simp only [hle.2 h1, ↓reduceIte, mask_one, BitVec.ofNat_add, BitVec.add_comm]
    · simp only [show ¬ _ from fun h => h1 (hle.1 h), ↓reduceIte, mask_zero]

end Ryo.Proofs.NicheDiscr
