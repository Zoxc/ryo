/-
Ryo.Spec.Theorems.Monotone — `decode` is monotone and `encode ∘ decode` loses definedness
only.

Ports: MiniRust `lang/representation.md` § Generic properties (`decode` monotone,
`encode_decode`), adapted to rustc layouts (D2).
-/
import Ryo.Spec.Theorems.Representation

namespace Ryo.Spec.Theorems

open Ryo.Spec

/-! ## The order on bytes and values -/

theorem bytesLeDefined_length {a b : List AbstractByte} (h : bytesLeDefined a b = true) :
    a.length = b.length := ((bytesLeDefined_iff a b).1 h).1

theorem AbstractByte.leDefined_data {x y : AbstractByte} {d : UInt8} (h : x.leDefined y = true)
    (hx : x.data = some d) : y.data = some d := by
  cases x <;> cases y <;> simp_all [AbstractByte.leDefined, AbstractByte.data] <;>
    (rename_i f1 _ f2; cases f1 <;> cases f2 <;> simp_all [AbstractByte.leDefined])

theorem AbstractByte.leDefined_frag {x y : AbstractByte} {f : ProvenanceFrag}
    (h : x.leDefined y = true) (hx : x.provFrag = some f) : y.provFrag = some f := by
  cases x <;> cases y <;> simp_all [AbstractByte.leDefined, AbstractByte.provFrag] <;>
    (rename_i f1 _ f2; cases f1 <;> cases f2 <;> simp_all [AbstractByte.leDefined])

theorem mapM_data_mono {b1 b2 : List AbstractByte} {ds : List UInt8}
    (h : bytesLeDefined b1 b2 = true) (h1 : b1.mapM AbstractByte.data = some ds) :
    b2.mapM AbstractByte.data = some ds := by
  rw [bytesLeDefined_iff] at h
  rw [mapM_data_iff] at h1 ⊢
  obtain ⟨hl, h⟩ := h
  obtain ⟨hl1, h1⟩ := h1
  exact ⟨by omega, fun i hi1 hi2 =>
    AbstractByte.leDefined_data (h i (by omega) hi1) (h1 i (by omega) hi2)⟩

theorem decodeBits_mono {b1 b2 : List AbstractByte} {n : Nat}
    (h : bytesLeDefined b1 b2 = true) (h1 : decodeBits b1 = some n) : decodeBits b2 = some n := by
  rw [decodeBits_iff] at h1 ⊢
  obtain ⟨ds, hds, rfl⟩ := h1
  exact ⟨ds, mapM_data_mono h hds, rfl⟩

theorem ptrProvOf_mono {b1 b2 : List AbstractByte} {q : Provenance}
    (h : bytesLeDefined b1 b2 = true) (h1 : ptrProvOf b1 = some q) : ptrProvOf b2 = some q := by
  rw [bytesLeDefined_iff] at h
  rw [ptrProvOf_iff] at h1 ⊢
  obtain ⟨hl, h⟩ := h
  obtain ⟨hne, h1⟩ := h1
  refine ⟨fun h0 => hne (by subst h0; simpa using hl), fun i hi => ?_⟩
  exact AbstractByte.leDefined_frag (h i (by omega) hi) (h1 i (by omega))

theorem decodePtr_mono {b1 b2 : List AbstractByte} {tp1 : ThinPointer}
    (h : bytesLeDefined b1 b2 = true) (h1 : decodePtr b1 = some tp1) :
    ∃ tp2, decodePtr b2 = some tp2 ∧ tp1.leDefined tp2 = true := by
  rw [decodePtr_eq] at h1 ⊢
  cases hb : decodeBits b1 with
  | none => simp [hb] at h1
  | some a =>
    simp only [hb, Option.map_some, Option.some.injEq] at h1
    subst h1
    rw [decodeBits_mono h hb]
    refine ⟨_, rfl, ?_⟩
    simp only [ThinPointer.leDefined, beq_self_eq_true, Bool.true_and]
    cases hp : ptrProvOf b1 with
    | none => rfl
    | some q => simp [ptrProvOf_mono h hp]

theorem leDefinedList_of : ∀ (a b : List Value), a.length = b.length →
    (∀ i (h1 : i < a.length) (h2 : i < b.length), a[i].leDefined b[i] = true) →
    Value.leDefined.leDefinedList a b = true
  | [], [], _, _ => by simp [Value.leDefined.leDefinedList]
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h
  | x :: a, y :: b, hl, h => by
    simp only [Value.leDefined.leDefinedList, Bool.and_eq_true]
    exact ⟨h 0 (by simp) (by simp), leDefinedList_of a b (by simpa using hl)
      (fun i h1 h2 => h (i + 1) (by simp; omega) (by simp; omega))⟩

theorem leDefinedBy_bytes_of : ∀ (a b : List (List AbstractByte)), a.length = b.length →
    (∀ i (h1 : i < a.length) (h2 : i < b.length), bytesLeDefined a[i] b[i] = true) →
    List.leDefinedBy bytesLeDefined a b = true
  | [], [], _, _ => by simp [List.leDefinedBy]
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h
  | x :: a, y :: b, hl, h => by
    simp only [List.leDefinedBy, Bool.and_eq_true]
    exact ⟨h 0 (by simp) (by simp), leDefinedBy_bytes_of a b (by simpa using hl)
      (fun i h1 h2 => h (i + 1) (by simp; omega) (by simp; omega))⟩

theorem bytesLeDefined_singleton {x : AbstractByte} {b : List AbstractByte}
    (h : bytesLeDefined [x] b = true) : ∃ y, b = [y] ∧ x.leDefined y = true := by
  cases b with
  | nil => simp [bytesLeDefined, List.leDefinedBy] at h
  | cons y b =>
    cases b with
    | nil => exact ⟨y, rfl, by simpa [bytesLeDefined, List.leDefinedBy] using h⟩
    | cons _ _ => simp [bytesLeDefined, List.leDefinedBy] at h

/-! ## Enum decoding in steps -/

/-- The variant index `decode` reads for an enum. -/
def enumIdx (vs : List Variant) (dt : IntType) (repr : EnumRepr) (bytes : List AbstractByte) :
    Option Nat :=
  match repr with
  | .empty => none
  | .single idx => some idx
  | .multiple tag => (decodeBits ((bytes.drop tag.offset).take tag.tag.size)).bind fun bits =>
      match tagToVariant vs dt tag bits with
      | .ok i => some i
      | .error _ => none

theorem decode_enum_eq (vs : List Variant) (dt : IntType) (repr : EnumRepr) (size : Size)
    (al : Align) (bytes : List AbstractByte) :
    (Ty.enum vs dt repr size al).decode bytes =
      if bytes.length != size then none
      else (enumIdx vs dt repr bytes).bind fun idx =>
        if !variantInhabited vs idx then none
        else (Ty.decodeVariant vs idx bytes).map (Value.variant idx) := by
  simp only [Ty.decode, enumIdx, Option.bind_eq_bind]
  split
  · rfl
  · cases repr with
    | empty => rfl
    | single idx =>
      simp only [Option.bind_none, Option.bind_some]
      split
      · rfl
      · cases Ty.decodeVariant vs idx bytes <;> rfl
    | multiple tag =>
      simp only [Option.bind_none, Option.bind_some]
      cases decodeBits ((bytes.drop tag.offset).take tag.tag.size) with
      | none => rfl
      | some bits =>
        simp only [Option.bind_some]
        cases tagToVariant vs dt tag bits with
        | error _ => rfl
        | ok idx =>
          simp only [Option.bind_some]
          split
          · rfl
          · cases Ty.decodeVariant vs idx bytes <;> rfl

theorem enumIdx_mono {vs : List Variant} {dt : IntType} {repr : EnumRepr}
    {b1 b2 : List AbstractByte} {idx : Nat} (hle : bytesLeDefined b1 b2 = true)
    (h : enumIdx vs dt repr b1 = some idx) : enumIdx vs dt repr b2 = some idx := by
  cases repr with
  | empty => simp [enumIdx] at h
  | single _ => exact h
  | multiple tag =>
    simp only [enumIdx] at h ⊢
    cases hb : decodeBits ((b1.drop tag.offset).take tag.tag.size) with
    | none => simp [hb] at h
    | some bits =>
      rw [decodeBits_mono (bytesLeDefined_slice hle _ _) hb]
      simpa [hb] using h

/-! ## `decode` is monotone -/
mutual

theorem decode_mono' : (t : Ty) → (b1 b2 : List AbstractByte) → (v1 : Value) →
    bytesLeDefined b1 b2 = true → t.decode b1 = some v1 →
    ∃ v2, t.decode b2 = some v2 ∧ v1.leDefined v2 = true
  | .int it r, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    simp only [Ty.decode, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h ⊢
    split at h
    · simp at h
    · rename_i hlen
      cases hb : decodeBits b1 with
      | none => simp [hb] at h
      | some n =>
        simp [hb] at h
        obtain ⟨hv, rfl⟩ := h
        exact ⟨.int (it.ofBits n), by simp [← hl, hlen, decodeBits_mono hle hb, hv],
          by simp [Value.leDefined]⟩
  | .bool, b1, b2, v1, hle, h => by
    simp only [Ty.decode] at h ⊢
    split at h
    · obtain ⟨y, rfl, hy⟩ := bytesLeDefined_singleton hle
      have := AbstractByte.leDefined_data hy (d := 0) rfl
      cases y <;> simp [AbstractByte.data] at this
      subst this; simp at h; subst h; exact ⟨_, rfl, rfl⟩
    · obtain ⟨y, rfl, hy⟩ := bytesLeDefined_singleton hle
      have := AbstractByte.leDefined_data hy (d := 1) rfl
      cases y <;> simp [AbstractByte.data] at this
      subst this; simp at h; subst h; exact ⟨_, rfl, rfl⟩
    · simp at h
  | .char, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    simp only [Ty.decode, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h ⊢
    split at h
    · simp at h
    · rename_i hlen
      cases hb : decodeBits b1 with
      | none => simp [hb] at h
      | some n =>
        simp [hb] at h
        obtain ⟨hv, rfl⟩ := h
        exact ⟨.int n, by simp [← hl, hlen, decodeBits_mono hle hb, hv], by simp [Value.leDefined]⟩
  | .float f, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    simp only [Ty.decode, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h ⊢
    split at h
    · simp at h
    · rename_i hlen
      cases hb : decodeBits b1 with
      | none => simp [hb] at h
      | some n =>
        simp [hb] at h
        subst h
        exact ⟨.float f n, by simp [← hl, hlen, decodeBits_mono hle hb], by simp [Value.leDefined]⟩
  | .ptr p r, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    simp only [Ty.decode, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h ⊢
    split at h
    · -- thin
      rename_i hk
      split at h
      · simp at h
      · rename_i hlen
        cases hp : decodePtr b1 with
        | none => simp [hp] at h
        | some tp =>
          obtain ⟨tp2, hp2, hle2⟩ := decodePtr_mono hle hp
          have ha : tp2.addr = tp.addr := by
            simp [ThinPointer.leDefined] at hle2; exact hle2.1.symm
          simp [hp] at h
          obtain ⟨hv, rfl⟩ := h
          refine ⟨.ptr ⟨tp2, none⟩, by simp [← hl, hlen, hp2, ha, hv], ?_⟩
          simp [Value.leDefined, Pointer.leDefined, hle2, Option.leDefinedBy]
    · -- slice
      rename_i hk
      split at h
      · simp at h
      · rename_i hlen
        cases hp : decodePtr (b1.take 8) with
        | none => simp [hp] at h
        | some tp =>
          obtain ⟨tp2, hp2, hle2⟩ := decodePtr_mono (bytesLeDefined_slice hle 0 8) (by simpa using hp)
          have ha : tp2.addr = tp.addr := by
            simp [ThinPointer.leDefined] at hle2; exact hle2.1.symm
          simp at hp2
          cases hn : decodeBits (b1.drop 8) with
          | none => simp [hp, hn] at h
          | some n =>
          simp [hp, hn] at h
          obtain ⟨hv, rfl⟩ := h
          have hn2 := decodeBits_mono (bytesLeDefined_slice hle 8 b1.length) (by
            rw [List.take_of_length_le (by simp)]; exact hn)
          rw [List.take_of_length_le (by simp; omega)] at hn2
          refine ⟨.ptr ⟨tp2, some (.elementCount n)⟩, by simp [← hl, hlen, hp2, ha, hv, hn2], ?_⟩
          simp [Value.leDefined, Pointer.leDefined, hle2, Option.leDefinedBy, PointerMeta.leDefined]
    · -- vtable
      rename_i t hk
      split at h
      · simp at h
      · rename_i hlen
        cases hp : decodePtr (b1.take 8) with
        | none => simp [hp] at h
        | some tp =>
          obtain ⟨tp2, hp2, hle2⟩ := decodePtr_mono (bytesLeDefined_slice hle 0 8) (by simpa using hp)
          have ha : tp2.addr = tp.addr := by
            simp [ThinPointer.leDefined] at hle2; exact hle2.1.symm
          simp at hp2
          cases hvt : decodePtr (b1.drop 8) with
          | none => simp [hp, hvt] at h
          | some vt =>
          simp [hp, hvt] at h
          obtain ⟨hv, rfl⟩ := h
          obtain ⟨vt2, hvt2, hle3⟩ := decodePtr_mono (bytesLeDefined_slice hle 8 b1.length) (by
            rw [List.take_of_length_le (by simp)]; exact hvt)
          rw [List.take_of_length_le (by simp; omega)] at hvt2
          refine ⟨.ptr ⟨tp2, some (.vtablePointer vt2)⟩, by simp [← hl, hlen, hp2, ha, hv, hvt2], ?_⟩
          simp [Value.leDefined, Pointer.leDefined, hle2, Option.leDefinedBy, PointerMeta.leDefined,
            hle3]
  | .fnDef _, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    simp only [Ty.decode] at h ⊢
    split at h
    · rename_i he
      simp at h; subst h
      simp at he; subst he; simp at hl
      rw [List.eq_nil_of_length_eq_zero hl.symm]
      exact ⟨_, rfl, by simp [Value.leDefined, Value.leDefined.leDefinedList]⟩
    · simp at h
  | .tuple fs hd tail, b1, b2, v1, hle, h => by
    cases tail with
    | some _ => simp [Ty.decode] at h
    | none =>
      rw [decode_tuple_eq] at h ⊢
      cases hf : Ty.decodeFields fs b1 with
      | none => simp [hf] at h
      | some vs1 =>
        simp [hf] at h; subst h
        obtain ⟨vs2, hf2, hle2⟩ := decodeFields_mono fs b1 b2 vs1 hle hf
        exact ⟨.tuple vs2, by simp [hf2], by simpa [Value.leDefined] using hle2⟩
  | .array e n, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    simp only [Ty.decode] at h ⊢
    split at h
    · rename_i es _ hlay
      simp only [bne_iff_ne, ne_eq, Option.bind_eq_bind] at h ⊢
      split at h
      · simp at h
      · rename_i hlen
        cases hm : (List.range n).mapM (fun i => e.decode ((b1.drop (i * es)).take es)) with
        | none => simp [hm] at h
        | some vs1 =>
          simp [hm] at h; subst h
          obtain ⟨hl1, hm1⟩ := (mapM_option_iff _ _ _).1 hm
          have hex : ∀ i (h : i < (List.range n).length), ∃ v2,
              e.decode ((b2.drop ((List.range n)[i] * es)).take es) = some v2 ∧
              ∀ (h' : i < vs1.length), vs1[i].leDefined v2 = true := fun i hi => by
            obtain ⟨v2, hv2, hle2⟩ := decode_mono' e _ _ _ (bytesLeDefined_slice hle _ _)
              (hm1 i hi (by omega))
            exact ⟨v2, hv2, fun _ => hle2⟩
          obtain ⟨vs2, hm2⟩ := mapM_option_exists
            (fun i => e.decode ((b2.drop (i * es)).take es)) (List.range n) (fun i hi => by
            obtain ⟨v2, hv2, _⟩ := hex i hi
            exact ⟨v2, hv2⟩)
          obtain ⟨hl2, hm2'⟩ := (mapM_option_iff _ _ _).1 hm2
          refine ⟨.tuple vs2, by simp [← hl, hlen, hm2], ?_⟩
          simp only [Value.leDefined]
          apply leDefinedList_of _ _ (by omega)
          intro i h1 h2
          obtain ⟨v2, hv2, hle2⟩ := hex i (by omega)
          rw [hm2' i (by omega) h2] at hv2
          cases hv2
          exact hle2 h1
    · simp at h
  | .slice _, _, _, _, _, h => by simp [Ty.decode] at h
  | .union _ chunks size _, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    simp only [Ty.decode, bne_iff_ne, ne_eq] at h ⊢
    split at h
    · simp at h
    · rename_i hlen
      simp at h; subst h
      refine ⟨.union (chunks.map fun (off, sz) => (b2.drop off).take sz), by simp [← hl, hlen], ?_⟩
      simp only [Value.leDefined]
      apply leDefinedBy_bytes_of _ _ (by simp)
      intro i h1 h2
      simp only [List.getElem_map]
      exact bytesLeDefined_slice hle _ _
  | .enum vs dt repr size _, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    rw [decode_enum_eq] at h ⊢
    rw [← hl]
    split at h
    · simp at h
    · rename_i hlen
      simp only [hlen, ↓reduceIte]
      cases hi : enumIdx vs dt repr b1 with
      | none => simp [hi] at h
      | some idx =>
        rw [enumIdx_mono hle hi]
        simp only [hi, Option.bind_some] at h ⊢
        split at h
        · simp at h
        · rename_i hinh
          simp only [hinh, ↓reduceIte]
          cases hd : Ty.decodeVariant vs idx b1 with
          | none => simp [hd] at h
          | some d1 =>
            simp [hd] at h; subst h
            obtain ⟨d2, hd2, hle2⟩ := decodeVariant_mono vs idx b1 b2 d1 hle hd
            exact ⟨.variant idx d2, by simp [hd2], by simp [Value.leDefined, hle2]⟩
  | .traitObject _, _, _, _, _, h => by simp [Ty.decode] at h
  | .opaqueBytes size _, b1, b2, v1, hle, h => by
    have hl := bytesLeDefined_length hle
    simp only [Ty.decode] at h ⊢
    split at h
    · rename_i hlen
      simp at h; subst h
      refine ⟨.union [b2], by simp [← hl]; simpa using hlen, ?_⟩
      simp [Value.leDefined, List.leDefinedBy, hle]
    · simp at h

theorem decodeFields_mono : (fs : List (Offset × Ty)) → (b1 b2 : List AbstractByte) →
    (vs1 : List Value) → bytesLeDefined b1 b2 = true → Ty.decodeFields fs b1 = some vs1 →
    ∃ vs2, Ty.decodeFields fs b2 = some vs2 ∧ Value.leDefined.leDefinedList vs1 vs2 = true
  | [], _, _, vs1, _, h => by
    simp [Ty.decodeFields] at h; subst h
    exact ⟨[], rfl, by simp [Value.leDefined.leDefinedList]⟩
  | (o, t) :: fs, b1, b2, vs1, hle, h => by
    simp only [Ty.decodeFields, Option.bind_eq_bind] at h ⊢
    cases hs : t.size? with
    | none => simp [hs] at h
    | some s =>
      simp only [hs, Option.bind_some] at h ⊢
      cases hv : t.decode ((b1.drop o).take s) with
      | none => simp [hv] at h
      | some v =>
        cases hr : Ty.decodeFields fs b1 with
        | none => simp [hv, hr] at h
        | some rest =>
          simp [hv, hr] at h; subst h
          obtain ⟨v2, hv2, hle2⟩ := decode_mono' t _ _ v (bytesLeDefined_slice hle o s) hv
          obtain ⟨rest2, hr2, hle3⟩ := decodeFields_mono fs b1 b2 rest hle hr
          exact ⟨v2 :: rest2, by simp [hv2, hr2], by
            simp [Value.leDefined.leDefinedList, hle2, hle3]⟩

theorem decodeVariant_mono : (vs : List Variant) → (idx : Nat) → (b1 b2 : List AbstractByte) →
    (d1 : Value) → bytesLeDefined b1 b2 = true → Ty.decodeVariant vs idx b1 = some d1 →
    ∃ d2, Ty.decodeVariant vs idx b2 = some d2 ∧ d1.leDefined d2 = true
  | [], _, _, _, _, _, h => by simp [Ty.decodeVariant] at h
  | ⟨_, t, _⟩ :: _, 0, b1, b2, d1, hle, h => by
    simp only [Ty.decodeVariant] at h ⊢
    exact decode_mono' t b1 b2 d1 hle h
  | _ :: vs, n + 1, b1, b2, d1, hle, h => by
    simp only [Ty.decodeVariant] at h ⊢
    exact decodeVariant_mono vs n b1 b2 d1 hle h

end

/-! ## Integer arithmetic -/

theorem IntType.modulus_pos (t : IntType) : 0 < t.modulus := Nat.two_pow_pos _

/-- `ofBits n ≡ n` modulo the type's modulus. -/
theorem IntType.ofBits_emod (t : IntType) (n : Nat) :
    t.ofBits n % (t.modulus : Int) = (n : Int) % t.modulus := by
  have hM := IntType.modulus_pos t
  unfold IntType.ofBits
  simp only
  have h1 : ((n % t.modulus : Nat) : Int) % t.modulus = (n : Int) % t.modulus := by
    rw [Int.natCast_emod, Int.emod_emod]
  split
  · rw [Int.sub_emod, Int.emod_self, Int.sub_zero, Int.emod_emod, h1]
  · exact h1

theorem IntType.toBits_ofBits (t : IntType) (n : Nat) : t.toBits (t.ofBits n) = n % t.modulus := by
  unfold IntType.toBits
  rw [IntType.ofBits_emod, ← Int.natCast_emod]
  rfl

theorem IntType.toBits_eq_of_emod (t : IntType) {x y : Int} (h : x % t.modulus = y % t.modulus) :
    t.toBits x = t.toBits y := by
  unfold IntType.toBits; rw [h]

theorem IntType.bringInBounds_emod (t : IntType) (x : Int) :
    t.bringInBounds x % (t.modulus : Int) = x % t.modulus := by
  unfold IntType.bringInBounds
  rw [IntType.ofBits_emod]
  unfold IntType.toBits
  have hM := IntType.modulus_pos t
  rw [Int.toNat_of_nonneg (Int.emod_nonneg _ (by omega)), Int.emod_emod]

theorem IntType.canRepresent_ofBits (t : IntType) (hwf : t.wf = true) (n : Nat) :
    t.canRepresent (t.ofBits n) = true := by
  have hb : 1 ≤ t.bits := by
    unfold IntType.wf at hwf; simp at hwf
    unfold IntType.bits
    rcases hwf with h | h | h | h | h <;> rw [h] <;> decide
  have hM : t.modulus = 2 * 2 ^ (t.bits - 1) := by
    unfold IntType.modulus
    rw [← Nat.pow_succ']; congr 1; omega
  have hm := Nat.mod_lt n (IntType.modulus_pos t)
  unfold IntType.canRepresent IntType.min IntType.max IntType.ofBits
  simp only [Bool.and_eq_true, decide_eq_true_eq]
  generalize hH : 2 ^ (t.bits - 1) = H at hM
  have hH' : (2 : Int) ^ (t.bits - 1) = (H : Int) := by rw [← hH]; simp
  have hM' : (2 : Int) ^ t.bits = 2 * (H : Int) := by
    rw [show t.bits = (t.bits - 1) + 1 by omega, Int.pow_succ, hH']; omega
  rw [hH', hM']
  generalize n % t.modulus = m at hm
  cases t.signed <;> simp <;> (try split) <;> omega


/-! ## Tags: decoding then encoding gives the same tag -/

/-- `(rel + start) % M = bits` for the relative niche value `rel` of `bits`. -/
theorem niche_rel_inv (bits start M : Nat) (hb : bits < M) :
    ((bits + M - start % M) % M + start) % M = bits := by
  have hM : 0 < M := by omega
  have hs := Nat.mod_lt start hM
  have hd := Nat.mod_add_div start M
  generalize start % M = s at *
  generalize start / M = q at *
  subst hd
  have hrel : (bits + M - s) % M = if s ≤ bits then bits - s else bits + M - s := by
    split
    · rw [Nat.mod_eq_sub_mod (by omega), Nat.mod_eq_of_lt (by omega)]; omega
    · exact Nat.mod_eq_of_lt (by omega)
  rw [hrel]
  split
  · rw [show bits - s + (s + M * q) = bits + M * q by omega, Nat.add_mul_mod_self_left,
      Nat.mod_eq_of_lt hb]
  · rw [show bits + M - s + (s + M * q) = bits + M * (q + 1) by rw [Nat.mul_succ]; omega,
      Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hb]

theorem find?_zipIdx {α : Type} {p : α × Nat → Bool} {l : List α} {v : α} {i : Nat}
    (h : l.zipIdx.find? p = some (v, i)) : l[i]? = some v ∧ p (v, i) = true :=
  ⟨List.mem_zipIdx_iff_getElem?.1 (List.mem_of_find?_eq_some h), List.find?_some h⟩

/-- A tag value that decodes to variant `idx` is the one `tagForVariant` writes for it (or the
variant is the untagged one). -/
theorem tagForVariant_of_tagToVariant {vs : List Variant} {dt : IntType} {tag : TagInfo}
    {bits idx : Nat} (htv : tagToVariant vs dt tag bits = .ok idx) (hb : bits < tag.tag.modulus) :
    tagForVariant vs tag idx = some bits ∨ tagForVariant vs tag idx = none := by
  unfold tagToVariant at htv
  unfold tagForVariant
  split at htv
  · rename_i henc
    split at htv
    · simp at htv
    · simp only at htv
      split at htv
      · rename_i v i hfind
        simp at htv; subst htv
        obtain ⟨hvi, hp⟩ := find?_zipIdx hfind
        simp only [beq_iff_eq] at hp
        left
        simp only [hvi, Option.map_some, Option.getD_some, hp]
      · simp at htv
  · rename_i u lo hi start henc
    simp only at htv
    split at htv
    · split at htv
      · simp at htv
      · rename_i hrel hne
        simp at htv; subst htv
        left
        simp only [beq_iff_eq] at hne
        simp only [hne, beq_iff_eq, ite_false, Option.some.injEq, Nat.add_sub_cancel_left]
        exact niche_rel_inv bits start _ hb
    · split at htv
      · simp at htv
      · simp at htv; subst htv
        right; simp

/-! ## Re-encoding decoded bytes -/

theorem bytesLeDefined_ofBytes {bytes : List AbstractByte} {ds : List UInt8}
    (h : bytes.mapM AbstractByte.data = some ds) :
    bytesLeDefined (ds.map AbstractByte.ofByte) bytes = true := by
  rw [mapM_data_iff] at h
  obtain ⟨hl, h⟩ := h
  rw [bytesLeDefined_iff]
  refine ⟨by simp [hl], fun i h1 h2 => ?_⟩
  have := AbstractByte.eq_init_of_data (h i h2 (by simpa using h1))
  simp only [List.getElem_map]
  rw [this]
  simp [AbstractByte.ofByte, AbstractByte.leDefined]

theorem encodeBits_le {bytes : List AbstractByte} {n size : Nat} (h : decodeBits bytes = some n)
    (hl : bytes.length = size) : bytesLeDefined (encodeBits size n) bytes = true := by
  rw [decodeBits_iff] at h
  obtain ⟨ds, hds, rfl⟩ := h
  have hl' : ds.length = size := by rw [← hl]; exact length_mapM_option _ _ _ hds
  unfold encodeBits
  rw [← hl', leEncode_leDecode]
  exact bytesLeDefined_ofBytes hds

theorem encodePtr_le {bytes : List AbstractByte} {tp : ThinPointer} (hl : bytes.length = 8)
    (h : decodePtr bytes = some tp) : bytesLeDefined (encodePtr tp) bytes = true := by
  rw [decodePtr_eq] at h
  cases hb : decodeBits bytes with
  | none => simp [hb] at h
  | some a =>
    simp [hb] at h; subst h
    rw [decodeBits_iff] at hb
    obtain ⟨ds, hds, rfl⟩ := hb
    have hl' : ds.length = 8 := by rw [← hl]; exact length_mapM_option _ _ _ hds
    rw [encodePtr_eq]
    simp only
    rw [← hl', leEncode_leDecode]
    obtain ⟨_, hd⟩ := (mapM_data_iff _ _).1 hds
    generalize hp : ptrProvOf bytes = pp
    rw [bytesLeDefined_iff]
    refine ⟨by simp [length_ptrBytes, hl, hl'], fun i h1 h2 => ?_⟩
    rw [getElem_ptrBytes]
    have he := AbstractByte.eq_init_of_data (hd i h2 (by simpa [length_ptrBytes] using h1))
    cases pp with
    | none => rw [he]; simp [AbstractByte.leDefined]
    | some q =>
      have := ((ptrProvOf_iff bytes q).1 hp).2 i h2
      rw [he]; simp [this, AbstractByte.leDefined]

theorem writeAll_le (ws : List (Nat × List AbstractByte)) (acc bytes : List AbstractByte)
    (hacc : bytesLeDefined acc bytes = true) (hb : ∀ w ∈ ws, w.1 + w.2.length ≤ acc.length)
    (hw : ∀ w ∈ ws, bytesLeDefined w.2 ((bytes.drop w.1).take w.2.length) = true) :
    bytesLeDefined (writeAll acc ws) bytes = true := by
  induction ws generalizing acc with
  | nil => exact hacc
  | cons w ws ih =>
    simp only [writeAll, List.foldl_cons] at ih ⊢
    have hw0 := hb w (by simp)
    have hl := writeAt_length acc w.2 w.1 hw0
    exact ih _ (bytesLeDefined_writeAt hacc hw0 (hw w (by simp)))
      (fun w' h' => by rw [hl]; exact hb w' (by simp [h']))
      (fun w' h' => hw w' (by simp [h']))

theorem flatten_slices (es : Nat) : ∀ (n : Nat) (l : List AbstractByte), l.length = es * n →
    ((List.range n).map fun i => (l.drop (i * es)).take es).flatten = l
  | 0, l, h => by simp at h; simp [h]
  | n + 1, l, h => by
    rw [List.range_succ_eq_map, List.map_cons, List.map_map, List.flatten_cons]
    have ih := flatten_slices es n (l.drop es) (by simp [h, Nat.mul_succ])
    have : (((fun i => (l.drop (i * es)).take es) ∘ Nat.succ)) =
        fun i => ((l.drop es).drop (i * es)).take es := by
      funext i; simp [Nat.succ_mul, List.drop_drop, Nat.add_comm]
    rw [this, ih]
    simp

theorem bytesLeDefined_flatten : ∀ (a b : List (List AbstractByte)), a.length = b.length →
    (∀ i (h1 : i < a.length) (h2 : i < b.length), bytesLeDefined a[i] b[i] = true) →
    bytesLeDefined a.flatten b.flatten = true
  | [], [], _, _ => rfl
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h
  | x :: a, y :: b, hl, h => by
    simp only [List.flatten_cons]
    exact bytesLeDefined_append (h 0 (by simp) (by simp))
      (bytesLeDefined_flatten a b (by simpa using hl)
        (fun i h1 h2 => h (i + 1) (by simp; omega) (by simp; omega)))

theorem length_take_drop_of_le (l : List AbstractByte) (o sz : Nat) (h : o + sz ≤ l.length) :
    ((l.drop o).take sz).length = sz := by simp; omega

theorem mem_zip_map_self {α β : Type} (g : α → β) :
    ∀ (l : List α) (x : α × β), x ∈ l.zip (l.map g) ↔ ∃ a ∈ l, x = (a, g a)
  | [], x => by simp
  | a :: l, x => by
    simp only [List.map_cons, List.zip_cons_cons, List.mem_cons, mem_zip_map_self g l x]
    constructor
    · rintro (h | ⟨b, hb, h⟩)
      · exact ⟨a, Or.inl rfl, h⟩
      · exact ⟨b, Or.inr hb, h⟩
    · rintro ⟨b, (rfl | hb), h⟩
      · exact Or.inl h
      · exact Or.inr ⟨b, hb, h⟩

mutual

theorem encode_decode_le' : (t : Ty) → (bytes : List AbstractByte) → (v : Value) →
    t.wf = true → bytes.length = t.size → t.decode bytes = some v →
    ∃ bs, t.encode v = some bs ∧ bytesLeDefined bs bytes = true
  | .int it r, bytes, v, hwf, _, h => by
    simp only [Ty.wf, Bool.and_eq_true] at hwf
    simp only [Ty.decode, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h
    split at h
    · simp at h
    · rename_i hlen
      cases hb : decodeBits bytes with
      | none => simp [hb] at h
      | some n =>
        simp [hb] at h
        obtain ⟨_, rfl⟩ := h
        have hn := decodeBits_length hb
        refine ⟨encodeBits it.size (it.toBits (it.ofBits n)), by simp [Ty.encode, IntType.canRepresent_ofBits it hwf.1 n], ?_⟩
        rw [IntType.toBits_ofBits, Nat.mod_eq_of_lt (by
          simp at hlen; rw [hlen] at hn; simpa [IntType.modulus, IntType.bits, Nat.mul_comm] using hn)]
        exact encodeBits_le hb (by simpa using hlen)
  | .bool, bytes, v, _, _, h => by
    simp only [Ty.decode] at h
    split at h <;> simp at h <;> subst h
    · exact ⟨_, rfl, by simp [bytesLeDefined, List.leDefinedBy, AbstractByte.leDefined]⟩
    · exact ⟨_, rfl, by simp [bytesLeDefined, List.leDefinedBy, AbstractByte.leDefined]⟩
  | .char, bytes, v, _, _, h => by
    simp only [Ty.decode, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h
    split at h
    · simp at h
    · rename_i hlen
      cases hb : decodeBits bytes with
      | none => simp [hb] at h
      | some n =>
        simp [hb] at h
        obtain ⟨_, rfl⟩ := h
        exact ⟨encodeBits 4 n, by simp [Ty.encode], encodeBits_le hb (by simpa using hlen)⟩
  | .float f, bytes, v, _, _, h => by
    simp only [Ty.decode, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h
    split at h
    · simp at h
    · rename_i hlen
      cases hb : decodeBits bytes with
      | none => simp [hb] at h
      | some n =>
        simp [hb] at h; subst h
        exact ⟨encodeBits f.size n, by simp [Ty.encode], encodeBits_le hb (by simpa using hlen)⟩
  | .ptr p r, bytes, v, _, _, h => by
    simp only [Ty.decode, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h
    split at h
    · rename_i hk
      split at h
      · simp at h
      · rename_i hlen
        cases hp : decodePtr bytes with
        | none => simp [hp] at h
        | some tp =>
          simp [hp] at h
          obtain ⟨_, rfl⟩ := h
          exact ⟨_, by simp [Ty.encode, hk], encodePtr_le (by simpa using hlen) hp⟩
    · rename_i hk
      split at h
      · simp at h
      · rename_i hlen
        simp at hlen
        cases hp : decodePtr (bytes.take 8) with
        | none => simp [hp] at h
        | some tp =>
          cases hn : decodeBits (bytes.drop 8) with
          | none => simp [hp, hn] at h
          | some n =>
            simp [hp, hn] at h
            obtain ⟨_, rfl⟩ := h
            refine ⟨encodePtr tp ++ encodeBits 8 n, by simp [Ty.encode, hk], ?_⟩
            rw [← List.take_append_drop 8 bytes]
            exact bytesLeDefined_append (encodePtr_le (by simp; omega) hp)
              (encodeBits_le hn (by simp; omega))
    · rename_i t hk
      split at h
      · simp at h
      · rename_i hlen
        simp at hlen
        cases hp : decodePtr (bytes.take 8) with
        | none => simp [hp] at h
        | some tp =>
          cases hn : decodePtr (bytes.drop 8) with
          | none => simp [hp, hn] at h
          | some vt =>
            simp [hp, hn] at h
            obtain ⟨_, rfl⟩ := h
            refine ⟨encodePtr tp ++ encodePtr vt, by simp [Ty.encode, hk], ?_⟩
            rw [← List.take_append_drop 8 bytes]
            exact bytesLeDefined_append (encodePtr_le (by simp; omega) hp)
              (encodePtr_le (by simp; omega) hn)
  | .fnDef _, bytes, v, _, _, h => by
    simp only [Ty.decode] at h
    split at h
    · rename_i he
      simp at h he; subst h he
      exact ⟨[], rfl, rfl⟩
    · simp at h
  | .tuple fs hd tail, bytes, v, hwf, hl, h => by
    cases tail with
    | some _ => simp [Ty.decode] at h
    | none =>
      rw [decode_tuple_eq] at h
      cases hf : Ty.decodeFields fs bytes with
      | none => simp [hf] at h
      | some vs =>
        simp [hf] at h; subst h
        simp only [Ty.wf, Bool.and_eq_true, List.all_eq_true] at hwf
        obtain ⟨⟨⟨⟨hfw, hb⟩, _⟩, _⟩, _⟩ := hwf
        have hsz : (Ty.tuple fs hd none).size = alignTo hd.end hd.align := by
          simp [Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?, TupleHeadLayout.headSizeAndAlign]
        rw [hsz] at hl
        obtain ⟨bs, hbs, hle⟩ := encodeFields_decode_le fs vs bytes
          (List.replicate (alignTo hd.end hd.align) AbstractByte.uninit) hfw
          (fun x hx => by
            have := hb x hx
            simp only [decide_eq_true_eq] at this
            rw [hl]; exact Nat.le_trans this (alignTo_ge _ _))
          (by simp [hl]) (by rw [← hl]; exact bytesLeDefined_replicate_uninit bytes) hf
        exact ⟨bs, by simpa [Ty.encode, TupleHeadLayout.headSizeAndAlign] using hbs, hle⟩
  | .array e n, bytes, v, hwf, _, h => by
    simp only [Ty.wf, Bool.and_eq_true] at hwf
    obtain ⟨⟨hew, hes⟩, _⟩ := hwf
    simp only [Ty.decode, Ty.layout_of_isSized hes, bne_iff_ne, ne_eq, Option.bind_eq_bind] at h
    split at h
    · simp at h
    · rename_i hlen
      simp at hlen
      cases hm : (List.range n).mapM (fun i => e.decode ((bytes.drop (i * e.size)).take e.size)) with
      | none => simp [hm] at h
      | some vs =>
        simp [hm] at h; subst h
        obtain ⟨hl1, hm1⟩ := (mapM_option_iff _ _ _).1 hm
        simp only [List.length_range] at hl1
        have hex : ∀ i (h : i < vs.length), ∃ b, e.encode vs[i] = some b ∧
            bytesLeDefined b ((bytes.drop (i * e.size)).take e.size) = true := fun i hi => by
          have := hm1 i (by simp; omega) hi
          simp only [List.getElem_range] at this
          have hm2 : (i + 1) * e.size ≤ n * e.size := Nat.mul_le_mul_right _ (by omega)
          have hbl : bytes.length = n * e.size := by rw [hlen, Nat.mul_comm]
          rw [Nat.succ_mul] at hm2
          exact encode_decode_le' e _ _ hew (by simp; omega) this
        obtain ⟨parts, hp⟩ := mapM_option_exists e.encode vs (fun i hi => by
          obtain ⟨b, hb, _⟩ := hex i hi; exact ⟨b, hb⟩)
        obtain ⟨hpl, hpe⟩ := (mapM_option_iff _ _ _).1 hp
        refine ⟨parts.flatten, by simp [Ty.encode, hl1, hp], ?_⟩
        rw [← flatten_slices e.size n bytes (by rw [hlen, Nat.mul_comm])]
        apply bytesLeDefined_flatten _ _ (by simp [hpl, hl1])
        intro i h1 h2
        obtain ⟨b, hb, hle⟩ := hex i (by omega)
        rw [hpe i (by omega) h1] at hb
        cases hb
        simpa using hle
  | .slice _, _, _, _, _, h => by simp [Ty.decode] at h
  | .union _ chunks size _, bytes, v, hwf, _, h => by
    simp only [Ty.decode, bne_iff_ne, ne_eq] at h
    split at h
    · simp at h
    · rename_i hlen
      simp at h hlen; subst h
      simp only [Ty.wf, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hwf
      obtain ⟨⟨⟨⟨_, _⟩, hcb⟩, _⟩, _⟩ := hwf
      have hsl : ∀ c ∈ chunks, ((bytes.drop c.1).take c.2).length = c.2 := fun c hc => by
        exact length_take_drop_of_le bytes c.1 c.2 (by rw [hlen]; exact hcb c hc)
      refine ⟨writeAll (List.replicate size AbstractByte.uninit)
        ((chunks.zip (chunks.map fun (off, sz) => (bytes.drop off).take sz)).map
          fun x => (x.1.1, x.2)), ?_, ?_⟩
      · simp only [Ty.encode, List.length_map, bne_self_eq_false, Bool.false_eq_true, ↓reduceIte,
          Option.bind_eq_bind]
        have hall : ((chunks.zip (chunks.map fun x => (bytes.drop x.1).take x.2)).all
            fun x => x.2.length == x.1.2) = true := by
          rw [List.all_eq_true]
          intro x hx
          obtain ⟨c, hc, rfl⟩ := (mem_zip_map_self _ _ _).1 hx
          simp [hsl c hc]
        simp [hall, foldl_writeAt_eq]
      · apply writeAll_le _ _ _ (by rw [← hlen]; exact bytesLeDefined_replicate_uninit bytes)
        · intro w hw
          obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hw
          obtain ⟨c, hc, rfl⟩ := (mem_zip_map_self _ _ _).1 hx
          simp only [List.length_replicate]
          rw [hsl c hc]; exact hcb c hc
        · intro w hw
          obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hw
          obtain ⟨c, hc, rfl⟩ := (mem_zip_map_self _ _ _).1 hx
          simp only
          rw [hsl c hc]
          exact bytesLeDefined_refl _
  | .enum vs dt repr size _, bytes, v, hwf, _, h => by
    rw [decode_enum_eq] at h
    split at h
    · simp at h
    · rename_i hlen
      simp at hlen
      simp only [Ty.wf, Bool.and_eq_true] at hwf
      obtain ⟨⟨⟨_, _⟩, hvw⟩, hrw⟩ := hwf
      cases hi : enumIdx vs dt repr bytes with
      | none => simp [hi] at h
      | some idx =>
        simp only [hi, Option.bind_some] at h
        split at h
        · simp at h
        · cases hd : Ty.decodeVariant vs idx bytes with
          | none => simp [hd] at h
          | some data =>
            simp [hd] at h; subst h
            obtain ⟨b0, hb0, hle⟩ := encodeVariant_decode_le vs size idx bytes data hvw hlen hd
            have hl0 := encodeVariant_length vs size idx data b0 hvw hb0
            cases repr with
            | empty => simp [enumIdx] at hi
            | single i =>
              simp [enumIdx] at hi; subst hi
              exact ⟨b0, by simp [Ty.encode, hb0], hle⟩
            | multiple tag =>
              simp only [enumIdx] at hi
              cases hbits : decodeBits ((bytes.drop tag.offset).take tag.tag.size) with
              | none => simp [hbits] at hi
              | some bits =>
                simp only [hbits, Option.bind_some] at hi
                have htv : tagToVariant vs dt tag bits = .ok idx := by
                  revert hi; split <;> simp_all
                simp only [Bool.and_eq_true, decide_eq_true_eq] at hrw
                obtain ⟨⟨⟨⟨_, htb⟩, _⟩, henc⟩, _⟩ := hrw
                have hbl : bits < tag.tag.modulus := by
                  have := decodeBits_slice_lt hbits
                  simpa [IntType.modulus, IntType.bits] using this
                rcases tagForVariant_of_tagToVariant htv hbl with hs | hs
                · refine ⟨writeAt b0 tag.offset (encodeBits tag.tag.size bits),
                    by simp [Ty.encode, hb0, hs], ?_⟩
                  apply bytesLeDefined_writeAt hle (by rw [encodeBits_length, hl0]; exact htb)
                  rw [encodeBits_length]
                  exact encodeBits_le hbits (length_take_drop_of_le _ _ _ (by rw [hlen]; exact htb))
                · exact ⟨b0, by simp [Ty.encode, hb0, hs], hle⟩
  | .traitObject _, _, _, _, _, h => by simp [Ty.decode] at h
  | .opaqueBytes size _, bytes, v, _, _, h => by
    simp only [Ty.decode] at h
    split at h
    · rename_i hlen
      simp at h hlen; subst h
      exact ⟨bytes, by simp [Ty.encode, hlen], bytesLeDefined_refl _⟩
    · simp at h

theorem encodeFields_decode_le : (fs : List (Offset × Ty)) → (vs : List Value) →
    (bytes acc : List AbstractByte) → Ty.wfFields fs = true →
    (∀ x ∈ fs, x.1 + x.2.size ≤ bytes.length) → acc.length = bytes.length →
    bytesLeDefined acc bytes = true → Ty.decodeFields fs bytes = some vs →
    ∃ bs, Ty.encodeFields fs vs acc = some bs ∧ bytesLeDefined bs bytes = true
  | [], vs, bytes, acc, _, _, _, hacc, h => by
    simp [Ty.decodeFields] at h; subst h
    exact ⟨acc, rfl, hacc⟩
  | (o, t) :: fs, vs, bytes, acc, hwf, hb, hal, hacc, h => by
    simp only [Ty.wfFields, Bool.and_eq_true] at hwf
    obtain ⟨⟨htw, hts⟩, hfw⟩ := hwf
    simp only [Ty.decodeFields, Ty.size?_of_isSized hts, Option.bind_eq_bind, Option.bind_some] at h
    cases hv : t.decode ((bytes.drop o).take t.size) with
    | none => simp [hv] at h
    | some v =>
      cases hr : Ty.decodeFields fs bytes with
      | none => simp [hv, hr] at h
      | some rest =>
        simp [hv, hr] at h; subst h
        have hb0 := hb (o, t) (by simp)
        simp only at hb0
        obtain ⟨enc, he, hle⟩ := encode_decode_le' t _ v htw (length_take_drop_of_le _ _ _ hb0) hv
        have hel := encode_length' t v enc htw hts he
        have hw : o + enc.length ≤ acc.length := by rw [hel, hal]; exact hb0
        obtain ⟨bs, hbs, hle2⟩ := encodeFields_decode_le fs rest bytes (writeAt acc o enc) hfw
          (fun x hx => hb x (by simp [hx])) (by rw [writeAt_length _ _ _ hw, hal])
          (bytesLeDefined_writeAt hacc hw (by rw [hel]; exact hle)) hr
        exact ⟨bs, by simp [Ty.encodeFields, he, hbs], hle2⟩

theorem encodeVariant_decode_le : (vs : List Variant) → (size idx : Nat) →
    (bytes : List AbstractByte) → (data : Value) → Ty.wfVariants vs size = true →
    bytes.length = size → Ty.decodeVariant vs idx bytes = some data →
    ∃ bs, Ty.encodeVariant vs idx data = some bs ∧ bytesLeDefined bs bytes = true
  | [], _, _, _, _, _, _, h => by simp [Ty.decodeVariant] at h
  | ⟨_, t, _⟩ :: _, size, 0, bytes, data, hwf, hl, h => by
    simp only [Ty.wfVariants, Bool.and_eq_true, beq_iff_eq] at hwf
    simp only [Ty.decodeVariant] at h
    simp only [Ty.encodeVariant]
    exact encode_decode_le' t bytes data hwf.1.1.1 (by rw [hl, hwf.1.2]) h
  | _ :: vs, size, n + 1, bytes, data, hwf, hl, h => by
    simp only [Ty.wfVariants, Bool.and_eq_true] at hwf
    simp only [Ty.decodeVariant] at h
    simp only [Ty.encodeVariant]
    exact encodeVariant_decode_le vs size n bytes data hwf.2 hl h

end

/-! ## The laws -/

/-- MiniRust's monotonicity of `decode`: more-defined bytes decode to a more-defined value (or
the less-defined bytes do not decode). -/
theorem decode_mono (t : Ty) (b1 b2 : List AbstractByte) (h : bytesLeDefined b1 b2 = true) :
    Option.leDefinedBy Value.leDefined (t.decode b1) (t.decode b2) = true := by
  cases h1 : t.decode b1 with
  | none => rfl
  | some v1 =>
    obtain ⟨v2, h2, hle⟩ := decode_mono' t b1 b2 v1 h h1
    simp [h2, Option.leDefinedBy, hle]

/-- MiniRust's `encode_decode`: re-encoding a decoded value is less defined than the bytes. -/
theorem encode_decode_le (t : Ty) (bytes : List AbstractByte) (v : Value) (hwf : t.wf = true)
    (hl : bytes.length = t.size) (h : t.decode bytes = some v) :
    ∃ bs, t.encode v = some bs ∧ bytesLeDefined bs bytes = true :=
  encode_decode_le' t bytes v hwf hl h

end Ryo.Spec.Theorems
