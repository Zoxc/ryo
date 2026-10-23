/-
Ryo.Spec.Theorems.Bytes — lemmas about byte lists: little-endian encoding, `writeAt` and
slices (`(l.drop o).take n`), pointer bytes, and the "less defined" order on bytes.

Ports: none (libspecr's list and integer facts that MiniRust's proofs take for granted).
-/
import Ryo.Spec.Lang.WellFormed

namespace Ryo.Spec.Theorems

open Ryo.Spec

variable {α : Type}

/-! ## Little-endian integers -/

theorem leDecode_leEncode (n v : Nat) : leDecode (leEncode n v) = v % 2 ^ (8 * n) := by
  induction n generalizing v with
  | zero => simp [leEncode, leDecode, Nat.mod_one]
  | succ n ih =>
    simp only [leEncode, leDecode, ih, UInt8.toNat_ofNat', Nat.reducePow]
    have h : 2 ^ (8 * (n + 1)) = 256 * 2 ^ (8 * n) := by
      rw [Nat.mul_succ, Nat.pow_add]; omega
    rw [h, Nat.mod_mul]
    omega

theorem leDecode_lt (l : List UInt8) : leDecode l < 2 ^ (8 * l.length) := by
  induction l with
  | nil => simp [leDecode]
  | cons b l ih =>
    simp only [leDecode, List.length_cons]
    have hb := b.toNat_lt
    have h : 2 ^ (8 * (l.length + 1)) = 256 * 2 ^ (8 * l.length) := by
      rw [Nat.mul_succ, Nat.pow_add]; omega
    rw [h]; omega

theorem leEncode_leDecode (l : List UInt8) : leEncode l.length (leDecode l) = l := by
  induction l with
  | nil => rfl
  | cons b l ih =>
    simp only [List.length_cons, leEncode, leDecode]
    have hb := b.toNat_lt
    have h1 : (b.toNat + 256 * leDecode l) % 256 = b.toNat := by omega
    have h2 : (b.toNat + 256 * leDecode l) / 256 = leDecode l := by omega
    rw [h1, h2, ih]
    simp

theorem leEncode_mod (n v : Nat) : leEncode n (v % 2 ^ (8 * n)) = leEncode n v := by
  have h := leEncode_leDecode (leEncode n v)
  rw [leEncode_length, leDecode_leEncode] at h
  exact h

theorem encodeBits_length (size n : Nat) : (encodeBits size n).length = size := by
  simp [encodeBits, leEncode_length]

theorem encodePtr_length (p : ThinPointer) : (encodePtr p).length = 8 := by
  simp [encodePtr, Target.PTR_SIZE, leEncode_length]

theorem mapM_data_ofByte (l : List UInt8) :
    (l.map AbstractByte.ofByte).mapM AbstractByte.data = some l := by
  induction l with
  | nil => rfl
  | cons b l ih => simp_all [AbstractByte.ofByte, AbstractByte.data]

theorem decodeBits_encodeBits (size n : Nat) :
    decodeBits (encodeBits size n) = some (n % 2 ^ (8 * size)) := by
  unfold decodeBits encodeBits
  rw [mapM_data_ofByte]
  simp [leDecode_leEncode]

theorem length_mapM_option {β γ : Type} (f : β → Option γ) :
    ∀ (l : List β) (r : List γ), l.mapM f = some r → r.length = l.length
  | [], r, h => by simp at h; subst h; rfl
  | a :: l, r, h => by
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.pure_def] at h
    cases ha : f a with
    | none => simp [ha] at h
    | some b =>
      cases hl : l.mapM f with
      | none => simp [ha, hl] at h
      | some r' =>
        simp [ha, hl] at h
        subst h
        simp [length_mapM_option f l r' hl]

theorem decodeBits_length {bytes : List AbstractByte} {n : Nat} (h : decodeBits bytes = some n) :
    n < 2 ^ (8 * bytes.length) := by
  unfold decodeBits at h
  cases hm : bytes.mapM AbstractByte.data with
  | none => simp [hm] at h
  | some ds =>
    have hl : ds.length = bytes.length := length_mapM_option _ _ _ hm
    simp [hm] at h
    subst h; rw [← hl]; exact leDecode_lt ds

/-! ## `writeAt` and slices -/

theorem getElem?_writeAt (l src : List AbstractByte) (off i : Nat) (h : off + src.length ≤ l.length) :
    (writeAt l off src)[i]? =
      if i < off then l[i]? else if i < off + src.length then src[i - off]? else l[i]? := by
  simp only [writeAt, List.getElem?_append, List.length_append, List.length_take,
    List.getElem?_take, List.getElem?_drop]
  have : min off l.length = off := by omega
  rw [this]
  by_cases h1 : i < off
  · simp [h1, show i < off + src.length by omega]
  · by_cases h2 : i < off + src.length
    · simp [h1, h2]
    · simp [h1, h2]
      congr 1; omega

theorem writeAt_length (l src : List AbstractByte) (off : Nat) (h : off + src.length ≤ l.length) :
    (writeAt l off src).length = l.length := by
  simp [writeAt]; omega

theorem getElem?_slice (l : List α) (o n i : Nat) :
    ((l.drop o).take n)[i]? = if i < n then l[o + i]? else none := by
  simp [List.getElem?_take, List.getElem?_drop]

theorem slice_writeAt_self (l src : List AbstractByte) (off : Nat) (h : off + src.length ≤ l.length) :
    ((writeAt l off src).drop off).take src.length = src := by
  apply List.ext_getElem?
  intro i
  rw [getElem?_slice, getElem?_writeAt _ _ _ _ h]
  by_cases hi : i < src.length
  · simp [hi, show ¬ off + i < off by omega, show off + i < off + src.length by omega]
  · simp [hi]

theorem slice_writeAt_disjoint (l src : List AbstractByte) (off o n : Nat)
    (h : off + src.length ≤ l.length)
    (hd : n = 0 ∨ src.length = 0 ∨ o + n ≤ off ∨ off + src.length ≤ o) :
    ((writeAt l off src).drop o).take n = (l.drop o).take n := by
  apply List.ext_getElem?
  intro i
  rw [getElem?_slice, getElem?_slice, getElem?_writeAt _ _ _ _ h]
  by_cases hi : i < n
  · have : o + i < off ∨ ¬ o + i < off + src.length := by omega
    rcases this with h1 | h1
    · simp [hi, h1]
    · simp [hi, h1]
  · simp [hi]

theorem slice_slice (l : List α) (a m b n : Nat) (h : b + n ≤ m) :
    ((((l.drop a).take m).drop b).take n) = (l.drop (a + b)).take n := by
  apply List.ext_getElem?
  intro i
  rw [getElem?_slice, getElem?_slice, getElem?_slice]
  by_cases hi : i < n
  · simp [hi, show b + i < m by omega, Nat.add_assoc]
  · simp [hi]

theorem slice_all (l : List α) : (l.drop 0).take l.length = l := by simp

theorem slice_append_left (l r : List α) (o n : Nat) (h : o + n ≤ l.length) :
    ((l ++ r).drop o).take n = (l.drop o).take n := by
  apply List.ext_getElem?
  intro i
  rw [getElem?_slice, getElem?_slice]
  by_cases hi : i < n
  · simp [hi, List.getElem?_append_left (show o + i < l.length by omega)]
  · simp [hi]

theorem slice_append_right (l r : List α) (o n : Nat) :
    ((l ++ r).drop (l.length + o)).take n = (r.drop o).take n := by
  apply List.ext_getElem?
  intro i
  rw [getElem?_slice, getElem?_slice]
  by_cases hi : i < n
  · simp only [hi, ite_true]
    rw [Nat.add_assoc, List.getElem?_append_right (by omega)]
    simp
  · simp [hi]

/-! ## Pairwise writes -/

/-- Write each `(offset, bytes)` in turn. -/
def writeAll (acc : List AbstractByte) (ws : List (Nat × List AbstractByte)) : List AbstractByte :=
  ws.foldl (fun acc w => writeAt acc w.1 w.2) acc

/-- Two writes (or ranges) are disjoint. -/
def WDisj (a b : Nat × Nat) : Prop := a.2 = 0 ∨ b.2 = 0 ∨ a.1 + a.2 ≤ b.1 ∨ b.1 + b.2 ≤ a.1

theorem writeAll_spec (ws : List (Nat × List AbstractByte)) (acc : List AbstractByte)
    (hb : ∀ w ∈ ws, w.1 + w.2.length ≤ acc.length)
    (hp : ws.Pairwise fun a b => WDisj (a.1, a.2.length) (b.1, b.2.length)) :
    (writeAll acc ws).length = acc.length ∧
    (∀ w ∈ ws, (((writeAll acc ws).drop w.1).take w.2.length) = w.2) ∧
    (∀ o n, (∀ w ∈ ws, WDisj (o, n) (w.1, w.2.length)) →
      ((writeAll acc ws).drop o).take n = (acc.drop o).take n) := by
  induction ws generalizing acc with
  | nil => simp [writeAll]
  | cons w ws ih =>
    have hw := hb w (by simp)
    have hlen := writeAt_length acc w.2 w.1 hw
    simp only [List.pairwise_cons] at hp
    obtain ⟨ih1, ih2, ih3⟩ := ih (writeAt acc w.1 w.2)
      (fun w' hw' => by rw [hlen]; exact hb w' (by simp [hw'])) hp.2
    simp only [writeAll, List.foldl_cons] at ih1 ih2 ih3 ⊢
    refine ⟨by rw [ih1, hlen], ?_, ?_⟩
    · intro w' hw'
      simp only [List.mem_cons] at hw'
      rcases hw' with rfl | hw'
      · rw [ih3 w'.1 w'.2.length (fun x hx => by
          have := hp.1 x hx; unfold WDisj at this ⊢; simpa using this)]
        exact slice_writeAt_self _ _ _ hw
      · exact ih2 w' hw'
    · intro o n hd
      rw [ih3 o n (fun x hx => hd x (by simp [hx]))]
      have := hd w (by simp)
      unfold WDisj at this
      exact slice_writeAt_disjoint _ _ _ _ _ hw (by simpa using this)

/-! ## The order on bytes -/

theorem bytesLeDefined_iff (a b : List AbstractByte) :
    bytesLeDefined a b = true ↔ a.length = b.length ∧
      ∀ i (h1 : i < a.length) (h2 : i < b.length), a[i].leDefined b[i] = true := by
  induction a generalizing b with
  | nil => cases b <;> simp [bytesLeDefined, List.leDefinedBy]
  | cons x a ih =>
    cases b with
    | nil => simp [bytesLeDefined, List.leDefinedBy]
    | cons y b =>
      simp only [bytesLeDefined, List.leDefinedBy, Bool.and_eq_true, List.length_cons,
        Nat.add_right_cancel_iff] at ih ⊢
      rw [ih]
      constructor
      · rintro ⟨h0, hl, hi⟩
        refine ⟨hl, fun i h1 h2 => ?_⟩
        cases i with
        | zero => simpa using h0
        | succ i => exact hi i (by omega) (by omega)
      · rintro ⟨hl, hi⟩
        exact ⟨by simpa using hi 0 (by omega) (by omega), hl,
          fun i h1 h2 => hi (i + 1) (by omega) (by omega)⟩

/-- Pointwise form with `getElem?`. -/
theorem bytesLeDefined_iff' (a b : List AbstractByte) :
    bytesLeDefined a b = true ↔ a.length = b.length ∧
      ∀ (i : Nat) (x y : AbstractByte), a[i]? = some x → b[i]? = some y →
        x.leDefined y = true := by
  rw [bytesLeDefined_iff]
  constructor
  · rintro ⟨hl, h⟩
    refine ⟨hl, fun i x y hx hy => ?_⟩
    obtain ⟨h1, rfl⟩ := List.getElem?_eq_some_iff.1 hx
    obtain ⟨h2, rfl⟩ := List.getElem?_eq_some_iff.1 hy
    exact h i h1 h2
  · rintro ⟨hl, h⟩
    exact ⟨hl, fun i h1 h2 => h i _ _ (List.getElem?_eq_getElem h1) (List.getElem?_eq_getElem h2)⟩

theorem bytesLeDefined_slice {a b : List AbstractByte} (h : bytesLeDefined a b = true) (o n : Nat) :
    bytesLeDefined ((a.drop o).take n) ((b.drop o).take n) = true := by
  rw [bytesLeDefined_iff'] at h ⊢
  obtain ⟨hl, h⟩ := h
  refine ⟨by simp [hl], fun i x y hx hy => ?_⟩
  rw [getElem?_slice] at hx hy
  split at hx
  · simp_all only [ite_true]; exact h _ _ _ hx hy
  · simp at hx

theorem bytesLeDefined_append {a b c d : List AbstractByte} (h1 : bytesLeDefined a b = true)
    (h2 : bytesLeDefined c d = true) : bytesLeDefined (a ++ c) (b ++ d) = true := by
  induction a generalizing b with
  | nil => cases b <;> simp_all [bytesLeDefined, List.leDefinedBy]
  | cons x a ih =>
    cases b with
    | nil => simp [bytesLeDefined, List.leDefinedBy] at h1
    | cons y b =>
      simp only [bytesLeDefined, List.leDefinedBy, List.cons_append, Bool.and_eq_true] at h1 ih ⊢
      exact ⟨h1.1, ih h1.2⟩

/-- Writing bytes that are less defined than what `bytes` has there keeps `acc ≤ bytes`. -/
theorem bytesLeDefined_writeAt {acc bytes src : List AbstractByte} {off : Nat}
    (h : bytesLeDefined acc bytes = true) (hb : off + src.length ≤ acc.length)
    (hs : bytesLeDefined src ((bytes.drop off).take src.length) = true) :
    bytesLeDefined (writeAt acc off src) bytes = true := by
  rw [bytesLeDefined_iff'] at h hs ⊢
  obtain ⟨hl, h⟩ := h
  obtain ⟨_, hs⟩ := hs
  refine ⟨by rw [writeAt_length _ _ _ hb, hl], fun i x y hx hy => ?_⟩
  rw [getElem?_writeAt _ _ _ _ hb] at hx
  split at hx
  · exact h i x y hx hy
  · split at hx
    · refine hs (i - off) x y hx ?_
      rw [getElem?_slice]; simp [show i - off < src.length by omega, show off + (i - off) = i by omega, hy]
    · exact h i x y hx hy

theorem bytesLeDefined_replicate_uninit (b : List AbstractByte) :
    bytesLeDefined (List.replicate b.length .uninit) b = true := by
  induction b with
  | nil => rfl
  | cons x b ih =>
    simp only [List.length_cons, List.replicate_succ, bytesLeDefined, List.leDefinedBy,
      Bool.and_eq_true] at ih ⊢
    exact ⟨rfl, ih⟩

/-! ## Data and provenance of bytes -/

theorem AbstractByte.eq_init_of_data {x : AbstractByte} {d : UInt8} (h : x.data = some d) :
    x = .init d x.provFrag := by
  cases x <;> simp_all [AbstractByte.data, AbstractByte.provFrag]

theorem mapM_data_iff (bytes : List AbstractByte) (ds : List UInt8) :
    bytes.mapM AbstractByte.data = some ds ↔
      bytes.length = ds.length ∧ ∀ i (h1 : i < bytes.length) (h2 : i < ds.length),
        bytes[i].data = some ds[i] := by
  induction bytes generalizing ds with
  | nil => cases ds <;> simp
  | cons x bytes ih =>
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.pure_def, List.length_cons]
    cases hx : x.data with
    | none =>
      simp only [Option.bind_none, reduceCtorEq, false_iff, not_and]
      intro hl h
      cases ds with
      | nil => simp at hl
      | cons e ds =>
        have := h 0 (by simp) (by simp)
        simp [hx] at this
    | some d =>
      cases hb : bytes.mapM AbstractByte.data with
      | none =>
        simp only [Option.bind_some, Option.bind_none, reduceCtorEq, false_iff, not_and]
        intro hl h
        cases ds with
        | nil => simp at hl
        | cons e ds =>
          have := (ih ds).2 ⟨by simpa using hl, fun i h1 h2 =>
            h (i + 1) (by simp; omega) (by simp; omega)⟩
          simp [hb] at this
      | some ds' =>
        simp only [Option.bind_some, Option.some.injEq]
        obtain ⟨hl', h'⟩ := (ih ds').1 hb
        constructor
        · rintro rfl
          refine ⟨by simp [hl'], fun i h1 h2 => ?_⟩
          cases i with
          | zero => simpa using hx
          | succ i => simpa using h' i (by omega) (by simp at h2; omega)
        · rintro ⟨hl, h⟩
          cases ds with
          | nil => simp at hl
          | cons e ds =>
            have h0 := h 0 (by omega) (by simp)
            simp [hx] at h0
            have := (ih ds).2 ⟨by simpa using hl, fun i h1 h2 =>
              h (i + 1) (by simp; omega) (by simp; omega)⟩
            rw [hb] at this
            simp at this
            simp [h0, this]

theorem decodeBits_iff (bytes : List AbstractByte) (n : Nat) :
    decodeBits bytes = some n ↔ ∃ ds, bytes.mapM AbstractByte.data = some ds ∧ leDecode ds = n := by
  unfold decodeBits
  cases bytes.mapM AbstractByte.data <;> simp

/-- The provenance `decodePtr` assigns. -/
def ptrProvOf (bytes : List AbstractByte) : Option Provenance :=
  match bytes with
  | [] => none
  | b0 :: _ =>
    match b0.provFrag with
    | none => none
    | some f0 =>
      if (bytes.zipIdx.all fun (b, i) =>
            match b.provFrag with
            | some f => f.prov == f0.prov && f.pos == i
            | none => false) then some f0.prov else none

theorem decodePtr_eq (bytes : List AbstractByte) :
    decodePtr bytes = (decodeBits bytes).map fun a => ⟨a, ptrProvOf bytes⟩ := by
  unfold decodePtr ptrProvOf
  cases decodeBits bytes <;> rfl

theorem ptrProvOf_iff (bytes : List AbstractByte) (q : Provenance) :
    ptrProvOf bytes = some q ↔ bytes ≠ [] ∧
      ∀ i (h : i < bytes.length), bytes[i].provFrag = some ⟨q, i⟩ := by
  cases bytes with
  | nil => simp [ptrProvOf]
  | cons b0 rest =>
    simp only [ptrProvOf, ne_eq, reduceCtorEq, not_false_eq_true, true_and]
    cases h0 : b0.provFrag with
    | none =>
      simp only [reduceCtorEq, false_iff, Classical.not_forall]
      exact ⟨0, by simp, by simp [h0]⟩
    | some f0 =>
      simp only
      constructor
      · intro h
        split at h
        · rename_i hall
          simp only [Option.some.injEq] at h
          subst h
          intro i hi
          have hm : ((b0 :: rest)[i], i) ∈ (b0 :: rest).zipIdx :=
            List.mem_zipIdx_iff_getElem?.2 (by simp)
          have := List.all_eq_true.1 hall _ hm
          revert this
          cases hf : (b0 :: rest)[i].provFrag with
          | none => simp
          | some f =>
            intro this
            simp only [Bool.and_eq_true, beq_iff_eq] at this
            obtain ⟨hp, hpos⟩ := this
            cases f; simp_all
        · simp at h
      · intro h
        have hq := h 0 (by simp)
        simp [h0] at hq
        subst hq
        simp only [ite_eq_left_iff, reduceCtorEq, imp_false, Classical.not_not]
        apply List.all_eq_true.2
        rintro ⟨b, i⟩ hm
        have hb := List.mem_zipIdx_iff_getElem?.1 hm
        obtain ⟨hi, hbi⟩ := List.getElem?_eq_some_iff.1 hb
        simp only at hbi hi
        have := h i hi
        rw [hbi] at this
        simp [this]

/-- The bytes of a pointer with address bytes `l`. -/
def ptrBytes (l : List UInt8) (pr : Option Provenance) : List AbstractByte :=
  l.zipIdx.map fun (b, i) => .init b (pr.map fun q => ⟨q, i⟩)

theorem encodePtr_eq (p : ThinPointer) : encodePtr p = ptrBytes (leEncode 8 p.addr) p.prov := rfl

theorem getElem?_ptrBytes (l : List UInt8) (pr : Option Provenance) (i : Nat) :
    (ptrBytes l pr)[i]? = l[i]?.map fun b => .init b (pr.map fun q => ⟨q, i⟩) := by
  simp [ptrBytes, List.getElem?_zipIdx]
  cases l[i]? <;> simp

theorem length_ptrBytes (l : List UInt8) (pr : Option Provenance) :
    (ptrBytes l pr).length = l.length := by simp [ptrBytes]

theorem getElem_ptrBytes (l : List UInt8) (pr : Option Provenance) (i : Nat)
    (h : i < (ptrBytes l pr).length) :
    (ptrBytes l pr)[i] = .init (l[i]'(by simpa [length_ptrBytes] using h))
      (pr.map fun q => ⟨q, i⟩) := by
  have := getElem?_ptrBytes l pr i
  rw [List.getElem?_eq_getElem h, List.getElem?_eq_getElem (by simpa [length_ptrBytes] using h)]
    at this
  simpa using this

theorem mapM_data_ptrBytes (l : List UInt8) (pr : Option Provenance) :
    (ptrBytes l pr).mapM AbstractByte.data = some l := by
  rw [mapM_data_iff]
  refine ⟨length_ptrBytes _ _, fun i h1 h2 => ?_⟩
  rw [getElem_ptrBytes]; rfl

theorem ptrProvOf_ptrBytes (l : List UInt8) (pr : Option Provenance) (hl : l ≠ []) :
    ptrProvOf (ptrBytes l pr) = pr := by
  cases pr with
  | some q =>
    rw [ptrProvOf_iff]
    refine ⟨by cases l <;> simp_all [ptrBytes], fun i h => ?_⟩
    rw [getElem_ptrBytes]; rfl
  | none =>
    cases l with
    | nil => simp at hl
    | cons b l => simp [ptrBytes, ptrProvOf, AbstractByte.provFrag]

theorem decodePtr_encodePtr (p : ThinPointer) (h : p.addr < 2 ^ 64) :
    decodePtr (encodePtr p) = some p := by
  rw [decodePtr_eq, encodePtr_eq]
  have hd : decodeBits (ptrBytes (leEncode 8 p.addr) p.prov) = some p.addr := by
    rw [decodeBits_iff]
    exact ⟨_, mapM_data_ptrBytes _ _, by rw [leDecode_leEncode]; exact Nat.mod_eq_of_lt h⟩
  rw [hd, ptrProvOf_ptrBytes _ _ (by simp [leEncode])]
  rfl

theorem decodeBits_encodePtr (p : ThinPointer) :
    decodeBits (encodePtr p) = some (p.addr % 2 ^ 64) := by
  rw [decodeBits_iff, encodePtr_eq]
  exact ⟨_, mapM_data_ptrBytes _ _, by rw [leDecode_leEncode]⟩

/-! ## `mapM` in `Option`, flattening -/

theorem mapM_option_iff {β γ : Type} (f : β → Option γ) (l : List β) (r : List γ) :
    l.mapM f = some r ↔
      r.length = l.length ∧ ∀ i (h1 : i < l.length) (h2 : i < r.length), f l[i] = some r[i] := by
  induction l generalizing r with
  | nil => cases r <;> simp
  | cons x l ih =>
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.pure_def, List.length_cons]
    cases hx : f x with
    | none =>
      simp only [Option.bind_none, reduceCtorEq, false_iff, not_and]
      intro hl h
      cases r with
      | nil => simp at hl
      | cons e r =>
        have := h 0 (by simp) (by simp)
        simp [hx] at this
    | some d =>
      cases hb : l.mapM f with
      | none =>
        simp only [Option.bind_some, Option.bind_none, reduceCtorEq, false_iff, not_and]
        intro hl h
        cases r with
        | nil => simp at hl
        | cons e r =>
          have := (ih r).2 ⟨by simpa using hl, fun i h1 h2 =>
            h (i + 1) (by simp; omega) (by simp; omega)⟩
          simp [hb] at this
      | some r' =>
        simp only [Option.bind_some, Option.some.injEq]
        obtain ⟨hl', h'⟩ := (ih r').1 hb
        constructor
        · rintro rfl
          refine ⟨by simp [hl'], fun i h1 h2 => ?_⟩
          cases i with
          | zero => simpa using hx
          | succ i => exact h' i (by simp at h1; omega) (by simp at h2; omega)
        · rintro ⟨hl, h⟩
          cases r with
          | nil => simp at hl
          | cons e r =>
            have h0 := h 0 (by simp) (by simp)
            simp [hx] at h0
            have := (ih r).2 ⟨by simpa using hl, fun i h1 h2 =>
              h (i + 1) (by simp; omega) (by simp; omega)⟩
            rw [hb] at this
            simp at this
            simp [h0, this]

theorem mapM_option_exists {β γ : Type} (f : β → Option γ) :
    ∀ (l : List β), (∀ j (h : j < l.length), ∃ b, f l[j] = some b) → ∃ r, l.mapM f = some r
  | [], _ => ⟨[], rfl⟩
  | a :: l, h => by
    obtain ⟨b, hb⟩ := h 0 (by simp)
    obtain ⟨r, hr⟩ := mapM_option_exists f l (fun j hj => h (j + 1) (by simp; omega))
    exact ⟨b :: r, by simp at hb; simp [hb, hr]⟩

theorem length_flatten_const (parts : List (List AbstractByte)) (es : Nat)
    (h : ∀ p ∈ parts, p.length = es) : parts.flatten.length = parts.length * es := by
  induction parts with
  | nil => simp
  | cons p parts ih =>
    simp only [List.flatten_cons, List.length_append, List.length_cons]
    rw [h p (by simp), ih (fun q hq => h q (by simp [hq]))]
    rw [Nat.succ_mul]; omega

theorem slice_flatten (parts : List (List AbstractByte)) (es i : Nat)
    (h : ∀ p ∈ parts, p.length = es) (hi : i < parts.length) :
    ((parts.flatten.drop (i * es)).take es) = parts[i] := by
  induction parts generalizing i with
  | nil => simp at hi
  | cons p parts ih =>
    have hp := h p (by simp)
    cases i with
    | zero =>
      simp only [Nat.zero_mul, List.flatten_cons, List.getElem_cons_zero]
      rw [slice_append_left _ _ _ _ (by omega)]
      rw [← hp]; simp
    | succ i =>
      simp only [List.flatten_cons, List.getElem_cons_succ]
      have : (i + 1) * es = p.length + i * es := by rw [hp, Nat.succ_mul]; omega
      rw [this, slice_append_right]
      exact ih i (fun q hq => h q (by simp [hq])) (by simp at hi; omega)

end Ryo.Spec.Theorems
