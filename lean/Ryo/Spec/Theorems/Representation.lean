/-
Ryo.Spec.Theorems.Representation — the generic properties of the representation relation.

Ports: MiniRust `lang/representation.md` § Generic properties (the laws `encode`/`decode` must
satisfy; violating them is a spec bug), adapted to rustc layouts (D2): enums are encoded with
rustc's tag algorithm, so the laws need the tag consistency `Ty.wf` checks (`variantTagWf`).

Proved:
- `encode_length`: encoding a value at a well-formed sized type gives `size` bytes;
- `decode_encode`: `decode (encode v) = some v` for every value `check_value` accepts;
  the enum case uses the niche lemma `encode_scalarRange` (the scalar a niche-encoded enum
  reads its tag from is initialized and inside its valid range).

Open goals (stated with `sorry`; mir-spec §A.8 step 3 tracks them here): see the end of the
file.
-/
import Ryo.Spec.Theorems.Bytes

namespace Ryo.Spec.Theorems

open Ryo.Spec

theorem alignTo_ge (n : Nat) (a : Align) : n ≤ alignTo n a := by
  unfold alignTo
  have hb : 0 < a.bytes := Nat.two_pow_pos _
  have h1 := Nat.div_add_mod (n + a.bytes - 1) a.bytes
  have h2 := Nat.mod_lt (n + a.bytes - 1) hb
  rw [Nat.mul_comm] at h1
  omega

theorem Ty.layout_of_isSized {t : Ty} (h : t.isSized = true) : t.layout = .sized t.size t.align := by
  unfold Ty.isSized at h
  unfold Ty.size Ty.align Ty.size? Ty.align?
  cases hl : t.layout <;> simp_all [LayoutStrategy.isSized, LayoutStrategy.size?, LayoutStrategy.align?]

theorem Ty.size?_of_isSized {t : Ty} (h : t.isSized = true) : t.size? = some t.size := by
  unfold Ty.size?; rw [Ty.layout_of_isSized h]; rfl

theorem isSized_of_variantShape {t : Ty}
    (h : (match t with | .tuple _ _ none => true | _ => false) = true) : t.isSized = true := by
  split at h
  · simp [Ty.isSized, Ty.layout, LayoutStrategy.isSized]
  · simp at h

theorem foldl_writeAt_eq (cd : List ((Offset × Size) × List AbstractByte)) (init : List AbstractByte) :
    cd.foldl (fun acc x => writeAt acc x.1.1 x.2) init =
      writeAll init (cd.map fun x => (x.1.1, x.2)) := by
  simp [writeAll, List.foldl_map]

theorem writeAll_length (ws : List (Nat × List AbstractByte)) (acc : List AbstractByte)
    (hb : ∀ w ∈ ws, w.1 + w.2.length ≤ acc.length) : (writeAll acc ws).length = acc.length := by
  induction ws generalizing acc with
  | nil => rfl
  | cons w ws ih =>
    have hw := writeAt_length acc w.2 w.1 (hb w (by simp))
    simp only [writeAll, List.foldl_cons] at ih ⊢
    rw [ih _ (fun w' hw' => by rw [hw]; exact hb w' (by simp [hw'])), hw]

mutual

theorem encode_length' : (t : Ty) → (v : Value) → (bs : List AbstractByte) → t.wf = true →
    t.isSized = true → t.encode v = some bs → bs.length = t.size
  | .int it r, v, bs, _, _, h => by
    cases v <;> simp [Ty.encode] at h
    obtain ⟨_, rfl⟩ := h
    simp [encodeBits_length, Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?]
  | .bool, v, bs, _, _, h => by
    cases v <;> simp [Ty.encode] at h
    subst h; simp [Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?]
  | .char, v, bs, _, _, h => by
    cases v <;> simp [Ty.encode] at h
    obtain ⟨_, rfl⟩ := h
    simp [encodeBits_length, Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?]
  | .float f, v, bs, _, _, h => by
    cases v <;> simp [Ty.encode] at h
    obtain ⟨_, rfl⟩ := h
    simp [encodeBits_length, Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?]
  | .ptr p r, v, bs, _, _, h => by
    cases v with
    | ptr pv =>
      simp only [Ty.encode] at h
      simp only [Ty.size, Ty.size?, Ty.layout, PtrType.isWide]
      split at h <;> rename_i heq _ <;> simp at h <;> subst h <;>
        simp [heq, encodePtr_length, encodeBits_length, LayoutStrategy.size?]
    | _ => simp [Ty.encode] at h
  | .fnDef _, v, bs, _, _, h => by
    cases v with
    | tuple vs => cases vs <;> simp [Ty.encode] at h; subst h; rfl
    | _ => simp [Ty.encode] at h
  | .tuple fields head tail, v, bs, hwf, hs, h => by
    cases tail with
    | some _ => simp [Ty.isSized, Ty.layout, LayoutStrategy.isSized] at hs
    | none =>
      cases v with
      | tuple vs =>
        simp only [Ty.encode] at h
        simp only [Ty.wf, Bool.and_eq_true, List.all_eq_true] at hwf
        obtain ⟨⟨⟨⟨hf, hb⟩, _⟩, _⟩, _⟩ := hwf
        have := encodeFields_length fields vs _ bs hf (fun x hx => by
          have := hb x hx
          simp only [decide_eq_true_eq] at this
          simp only [List.length_replicate]
          exact Nat.le_trans this (alignTo_ge _ _)) h
        simp [this, Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?,
          TupleHeadLayout.headSizeAndAlign]
      | _ => simp [Ty.encode] at h
  | .array e n, v, bs, hwf, hs, h => by
    cases v with
    | tuple vs =>
      simp only [Ty.wf, Bool.and_eq_true] at hwf
      obtain ⟨⟨hew, hes⟩, _⟩ := hwf
      simp only [Ty.encode, bne_iff_ne, ne_eq, Option.bind_eq_bind, Option.pure_def] at h
      split at h
      · simp at h
      · rename_i hlen
        cases hp : vs.mapM e.encode with
        | none => simp [hp] at h
        | some parts =>
          simp [hp] at h
          subst h
          obtain ⟨hpl, hpe⟩ := (mapM_option_iff _ _ _).1 hp
          rw [length_flatten_const parts e.size (fun p hp' => by
            obtain ⟨i, hi, rfl⟩ := List.getElem_of_mem hp'
            exact encode_length' e vs[i] _ hew hes (hpe i (by omega) hi))]
          have hl : (Ty.array e n).layout = .sized (e.size * n) e.align := by
            conv => lhs; unfold Ty.layout
            rw [Ty.layout_of_isSized hes]
          simp only [Ty.size, Ty.size?, hl, LayoutStrategy.size?, Option.getD_some]
          simp at hlen; rw [hpl, hlen, Nat.mul_comm]
    | _ => simp [Ty.encode] at h
  | .slice _, _, _, _, hs, _ => by
    unfold Ty.isSized Ty.layout at hs; split at hs <;> simp [LayoutStrategy.isSized] at hs
  | .union fields chunks size al, v, bs, hwf, hs, h => by
    cases v with
    | union data =>
      simp [Ty.encode] at h
      obtain ⟨_, hd, rfl⟩ := h
      simp only [Ty.wf, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hwf
      obtain ⟨⟨⟨⟨_, _⟩, hc⟩, _⟩, _⟩ := hwf
      rw [foldl_writeAt_eq, writeAll_length]
      · simp [Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?]
      · intro w hw
        simp only [List.mem_map] at hw
        obtain ⟨⟨⟨o, sz⟩, d⟩, hm, rfl⟩ := hw
        have := hc (o, sz) (List.of_mem_zip hm).1
        simp only [List.length_replicate]
        rw [hd o sz d hm]; exact this
    | _ => simp [Ty.encode] at h
  | .enum vs dt repr size al, v, bs, hwf, hs, h => by
    cases v with
    | variant idx data =>
      simp only [Ty.wf, Bool.and_eq_true] at hwf
      obtain ⟨⟨⟨_, _⟩, hvw⟩, hrw⟩ := hwf
      simp only [Ty.encode, Option.bind_eq_bind] at h
      cases he : Ty.encodeVariant vs idx data with
      | none => simp [he] at h
      | some b0 =>
        have hl := encodeVariant_length vs size idx data b0 hvw he
        simp only [he, Option.bind_some] at h
        simp only [Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?, Option.getD_some]
        split at h
        · simp at h
        · split at h <;> simp at h; subst h; exact hl
        · rename_i tag
          simp only [Bool.and_eq_true, decide_eq_true_eq] at hrw
          split at h
          · simp at h; subst h; exact hl
          · simp at h; subst h
            rw [writeAt_length _ _ _ (by rw [encodeBits_length, hl]; exact hrw.1.1.1.2), hl]
    | _ => simp [Ty.encode] at h
  | .traitObject _, _, _, _, hs, _ => by simp [Ty.isSized, Ty.layout, LayoutStrategy.isSized] at hs
  | .opaqueBytes size al, v, bs, _, _, h => by
    cases v with
    | union cs =>
      match cs, h with
      | [c], h =>
        simp [Ty.encode] at h
        obtain ⟨h1, rfl⟩ := h
        simp [h1, Ty.size, Ty.size?, Ty.layout, LayoutStrategy.size?]
      | [], h => simp [Ty.encode] at h
      | _ :: _ :: _, h => simp [Ty.encode] at h
    | _ => simp [Ty.encode] at h

theorem encodeFields_length : (fs : List (Offset × Ty)) → (vs : List Value) →
    (acc bs : List AbstractByte) → Ty.wfFields fs = true →
    (∀ x ∈ fs, x.1 + x.2.size ≤ acc.length) → Ty.encodeFields fs vs acc = some bs →
    bs.length = acc.length
  | [], vs, acc, bs, _, _, h => by
    cases vs <;> simp [Ty.encodeFields] at h; subst h; rfl
  | (o, t) :: fs, vs, acc, bs, hwf, hb, h => by
    cases vs with
    | nil => simp [Ty.encodeFields] at h
    | cons v vs =>
      simp only [Ty.wfFields, Bool.and_eq_true] at hwf
      obtain ⟨⟨htw, hts⟩, hfw⟩ := hwf
      simp only [Ty.encodeFields, Option.bind_eq_bind] at h
      cases he : t.encode v with
      | none => simp [he] at h
      | some enc =>
        simp only [he, Option.bind_some] at h
        have hl := encode_length' t v enc htw hts he
        have hb0 := hb (o, t) (by simp)
        have hw := writeAt_length acc enc o (by rw [hl]; exact hb0)
        rw [encodeFields_length fs vs _ bs hfw (fun x hx => by
          rw [hw]; exact hb x (by simp [hx])) h, hw]

theorem encodeVariant_length : (vs : List Variant) → (size idx : Nat) → (v : Value) →
    (bs : List AbstractByte) → Ty.wfVariants vs size = true → Ty.encodeVariant vs idx v = some bs →
    bs.length = size
  | [], _, _, _, _, _, h => by simp [Ty.encodeVariant] at h
  | ⟨_, t, _⟩ :: vs, size, 0, v, bs, hwf, h => by
    simp only [Ty.wfVariants, Bool.and_eq_true, beq_iff_eq] at hwf
    obtain ⟨⟨⟨htw, htt⟩, hts⟩, _⟩ := hwf
    simp only [Ty.encodeVariant] at h
    rw [encode_length' t v bs htw (isSized_of_variantShape htt) h, hts]
  | _ :: vs, size, n + 1, v, bs, hwf, h => by
    simp only [Ty.wfVariants, Bool.and_eq_true] at hwf
    simp only [Ty.encodeVariant] at h
    exact encodeVariant_length vs size n v bs hwf.2 h

end


/-! ## `Except` -/

@[simp] theorem Except.bind_eq_ok {ε α β : Type} (x : Except ε α) (f : α → Except ε β) (b : β) :
    (x >>= f) = .ok b ↔ ∃ a, x = .ok a ∧ f a = .ok b := by
  cases x <;> simp [bind, Except.bind]

@[simp] theorem exists_unit_iff (p : Unit → Prop) : (∃ x : Unit, p x) ↔ p () :=
  ⟨fun ⟨x, h⟩ => by cases x; exact h, fun h => ⟨(), h⟩⟩

@[simp] theorem ensureUb_eq_ok (b : Bool) (msg : String) :
    (ensureUb b msg : Except Outcome Unit) = .ok () ↔ b = true := by
  cases b <;> simp [ensureUb, throwUb, throwThe, MonadExceptOf.throw, pure, Except.pure]

@[simp] theorem throwUb_ne_ok {α : Type} (msg : String) (a : α) :
    (throwUb msg : Except Outcome α) ≠ .ok a := by simp [throwUb, throwThe, MonadExceptOf.throw]

@[simp] theorem throwIllFormed_ne_ok {α : Type} (msg : String) (a : α) :
    (throwIllFormed msg : Except Outcome α) ≠ .ok a := by
  simp [throwIllFormed, throwThe, MonadExceptOf.throw]

/-! ## Facts from `check_value` -/

theorem checkPtr_ok {mem : Memory} {p : Pointer} {pt : PtrType} {valid : ValidRange}
    (h : checkPtr mem p pt valid = .ok ()) :
    p.thin.addr < Target.ADDR_LIMIT ∧ valid.contains p.thin.addr = true ∧
      checkPtrMetadata mem p.metadata pt.metaKind = .ok () := by
  simp [checkPtr] at h
  obtain ⟨h1, h2, h3, _⟩ := h
  exact ⟨h1, h2, h3⟩

theorem checkFields_ok {mem : Memory} :
    ∀ {vs : List Value} {fs : List (Offset × Ty)}, checkFields mem vs fs = .ok () →
      vs.length = fs.length ∧
        ∀ j (h1 : j < fs.length) (h2 : j < vs.length), checkValue mem vs[j] fs[j].2 = .ok ()
  | [], [], _ => by simp
  | [], _ :: _, h => by simp [checkFields] at h
  | _ :: _, [], h => by simp [checkFields] at h
  | v :: vs, (o, t) :: fs, h => by
    simp [checkFields] at h
    obtain ⟨ih1, ih2⟩ := checkFields_ok h.2
    refine ⟨by simp [ih1], fun j h1 h2 => ?_⟩
    cases j with
    | zero => exact h.1
    | succ j => exact ih2 j (by simp at h1; omega) (by simp at h2; omega)

theorem checkElems_ok {mem : Memory} {t : Ty} :
    ∀ {vs : List Value}, checkElems mem vs t = .ok () →
      ∀ j (h : j < vs.length), checkValue mem vs[j] t = .ok ()
  | [], _ => by simp
  | v :: vs, h => by
    simp [checkElems] at h
    intro j hj
    cases j with
    | zero => exact h.1
    | succ j => exact checkElems_ok h.2 j (by simp at hj; omega)

theorem checkVariant_ok {mem : Memory} :
    ∀ {vs : List Variant} {idx : Nat} {data : Value}, checkVariant mem vs idx data = .ok () →
      ∃ v, vs[idx]? = some v ∧ checkValue mem data v.fields = .ok ()
  | [], _, _, h => by simp [checkVariant] at h
  | ⟨d, t, i⟩ :: vs, 0, data, h => by simp [checkVariant] at h; exact ⟨_, rfl, h⟩
  | _ :: vs, n + 1, data, h => by
    simp only [checkVariant] at h
    simpa using checkVariant_ok h

theorem encodeVariant_eq : ∀ (vs : List Variant) (idx : Nat) (data : Value),
    Ty.encodeVariant vs idx data = (vs[idx]?).bind fun v => v.fields.encode data
  | [], _, _ => by simp [Ty.encodeVariant]
  | ⟨_, _, _⟩ :: _, 0, _ => by simp [Ty.encodeVariant]
  | _ :: vs, n + 1, data => by simp [Ty.encodeVariant, encodeVariant_eq vs n data]

theorem decodeVariant_eq : ∀ (vs : List Variant) (idx : Nat) (bytes : List AbstractByte),
    Ty.decodeVariant vs idx bytes = (vs[idx]?).bind fun v => v.fields.decode bytes
  | [], _, _ => by simp [Ty.decodeVariant]
  | ⟨_, _, _⟩ :: _, 0, _ => by simp [Ty.decodeVariant]
  | _ :: vs, n + 1, bytes => by simp [Ty.decodeVariant, decodeVariant_eq vs n bytes]

theorem scalarRangeVariant_eq : ∀ (vs : List Variant) (idx off size : Nat),
    Ty.scalarRangeVariant vs idx off size = (vs[idx]?).bind fun v => v.fields.scalarRange off size
  | [], _, _, _ => by simp [Ty.scalarRangeVariant]
  | ⟨_, _, _⟩ :: _, 0, _, _ => by simp [Ty.scalarRangeVariant]
  | _ :: vs, n + 1, off, size => by
    simp [Ty.scalarRangeVariant, scalarRangeVariant_eq vs n off size]

theorem wfVariants_get : ∀ {vs : List Variant} {size idx : Nat} {v : Variant},
    Ty.wfVariants vs size = true → vs[idx]? = some v →
      v.fields.wf = true ∧ (match v.fields with | .tuple _ _ none => true | _ => false) = true ∧
        v.fields.size = size
  | [], _, _, _, _, h => by simp at h
  | ⟨_, t, _⟩ :: vs, size, 0, v, hwf, h => by
    simp only [Ty.wfVariants, Bool.and_eq_true, beq_iff_eq] at hwf
    simp at h; subst h
    exact ⟨hwf.1.1.1, hwf.1.1.2, hwf.1.2⟩
  | _ :: vs, size, n + 1, v, hwf, h => by
    simp only [Ty.wfVariants, Bool.and_eq_true] at hwf
    exact wfVariants_get hwf.2 (by simpa using h)

theorem wfFields_get : ∀ {fs : List (Offset × Ty)}, Ty.wfFields fs = true →
    ∀ j (h : j < fs.length), fs[j].2.wf = true ∧ fs[j].2.isSized = true
  | [], _ => by simp
  | (_, t) :: fs, hwf => by
    simp only [Ty.wfFields, Bool.and_eq_true] at hwf
    intro j hj
    cases j with
    | zero => exact hwf.1
    | succ j => exact wfFields_get hwf.2 j (by simp at hj; omega)

theorem rangesDisjoint_pairwise : ∀ (rs : List (Offset × Size)),
    rangesDisjoint rs = true → rs.Pairwise WDisj
  | [], _ => List.Pairwise.nil
  | r :: rs, h => by
    simp only [rangesDisjoint, Bool.and_eq_true, List.all_eq_true] at h
    refine List.Pairwise.cons (fun b hb => ?_) (rangesDisjoint_pairwise rs h.2)
    have := h.1 b hb
    simp only [rangeDisjoint, Bool.or_eq_true, beq_iff_eq, decide_eq_true_eq] at this
    unfold WDisj
    simpa [or_assoc] using this

/-! ## Tuples: the bytes of each field -/

theorem encodeFields_spec : ∀ (fs : List (Offset × Ty)) (vs : List Value)
    (acc bs : List AbstractByte), Ty.wfFields fs = true →
    (∀ x ∈ fs, x.1 + x.2.size ≤ acc.length) →
    (fs.map fun x => (x.1, x.2.size)).Pairwise WDisj →
    Ty.encodeFields fs vs acc = some bs →
    vs.length = fs.length ∧
    (∀ j (h1 : j < fs.length) (h2 : j < vs.length), ∃ enc, fs[j].2.encode vs[j] = some enc ∧
      (bs.drop fs[j].1).take fs[j].2.size = enc) ∧
    (∀ o n, (∀ x ∈ fs, WDisj (o, n) (x.1, x.2.size)) → (bs.drop o).take n = (acc.drop o).take n)
  | [], vs, acc, bs, _, _, _, h => by
    cases vs <;> simp [Ty.encodeFields] at h; subst h; simp
  | (o, t) :: fs, vs, acc, bs, hwf, hb, hp, h => by
    cases vs with
    | nil => simp [Ty.encodeFields] at h
    | cons v vs =>
      simp only [Ty.wfFields, Bool.and_eq_true] at hwf
      obtain ⟨⟨htw, hts⟩, hfw⟩ := hwf
      simp only [Ty.encodeFields, Option.bind_eq_bind] at h
      cases he : t.encode v with
      | none => simp [he] at h
      | some enc =>
        simp only [he, Option.bind_some] at h
        have hl := encode_length' t v enc htw hts he
        have hb0 : o + enc.length ≤ acc.length := by rw [hl]; exact hb (o, t) (by simp)
        have hw := writeAt_length acc enc o hb0
        simp only [List.map_cons, List.pairwise_cons, List.mem_map] at hp
        obtain ⟨ih1, ih2, ih3⟩ := encodeFields_spec fs vs _ bs hfw
          (fun x hx => by rw [hw]; exact hb x (by simp [hx])) hp.2 h
        refine ⟨by simp [ih1], fun j h1 h2 => ?_, fun o' n hd => ?_⟩
        · cases j with
          | zero =>
            refine ⟨enc, he, ?_⟩
            simp only [List.getElem_cons_zero]
            rw [ih3 o t.size (fun x hx => hp.1 _ ⟨x, hx, rfl⟩), ← hl]
            exact slice_writeAt_self _ _ _ hb0
          | succ j => exact ih2 j (by simp at h1; omega) (by simp at h2; omega)
        · rw [ih3 o' n (fun x hx => hd x (by simp [hx]))]
          have := hd (o, t) (by simp)
          unfold WDisj at this
          exact slice_writeAt_disjoint _ _ _ _ _ hb0 (by simp only at this; omega)

/-! ## Valid ranges -/

theorem ValidRange.contains_iff (r : ValidRange) (m v : Nat) (_hs : r.start < m) (hv : v < m) :
    r.contains v = true ↔ ∃ ab ∈ r.intervals m, ab.1 ≤ v ∧ v ≤ ab.2 := by
  unfold ValidRange.contains ValidRange.intervals
  split <;> simp <;> omega

theorem ValidRange.subset_sound {r s : ValidRange} {m v : Nat} (h : r.subset s m = true)
    (hr : r.start < m) (hs : s.start < m) (hv : v < m) (hc : r.contains v = true) :
    s.contains v = true := by
  rw [ValidRange.contains_iff _ m v hr hv] at hc
  rw [ValidRange.contains_iff _ m v hs hv]
  obtain ⟨ab, hab, h1, h2⟩ := hc
  unfold ValidRange.subset at h
  have := List.all_eq_true.1 h ab hab
  simp only [Bool.or_eq_true, decide_eq_true_eq, List.any_eq_true, Bool.and_eq_true] at this
  rcases this with h3 | ⟨cd, hcd, h3, h4⟩
  · omega
  · exact ⟨cd, hcd, by omega, by omega⟩

theorem ValidRange.disjoint_sound {r s : ValidRange} {m v : Nat} (h : r.disjoint s m = true)
    (hr : r.start < m) (hs : s.start < m) (hv : v < m) (hc : r.contains v = true) :
    s.contains v = false := by
  rw [ValidRange.contains_iff _ m v hr hv] at hc
  cases hsc : s.contains v with
  | false => rfl
  | true =>
    rw [ValidRange.contains_iff _ m v hs hv] at hsc
    obtain ⟨ab, hab, h1, h2⟩ := hc
    obtain ⟨cd, hcd, h3, h4⟩ := hsc
    unfold ValidRange.disjoint at h
    have := List.all_eq_true.1 (List.all_eq_true.1 h ab hab) cd hcd
    simp only [Bool.or_eq_true, decide_eq_true_eq] at this
    omega

theorem nicheRange_contains (tag : TagInfo) (lo hi start v : Nat) (hv : v < tag.tag.modulus)
    (hk : hi - lo < tag.tag.modulus) :
    (nicheRange tag lo hi start).contains v = true ↔
      (v + tag.tag.modulus - start % tag.tag.modulus) % tag.tag.modulus ≤ hi - lo := by
  unfold nicheRange ValidRange.contains
  simp only
  have hm : 0 < tag.tag.modulus := Nat.two_pow_pos _
  generalize tag.tag.modulus = M at *
  have hs := Nat.mod_lt start hm
  generalize start % M = s at *
  generalize hk' : hi - lo = k at *
  have hstop : (s + k) % M = if s + k < M then s + k else s + k - M := by
    split
    · exact Nat.mod_eq_of_lt (by omega)
    · rw [Nat.mod_eq_sub_mod (by omega), Nat.mod_eq_of_lt (by omega)]
  have hrel : (v + M - s) % M = if s ≤ v then v - s else v + M - s := by
    split
    · rw [Nat.mod_eq_sub_mod (by omega), Nat.mod_eq_of_lt (by omega)]; omega
    · exact Nat.mod_eq_of_lt (by omega)
  rw [hstop, hrel]
  split <;> split <;> split <;> simp <;> omega

/-- `ofBits (toBits i) = i` for representable `i` at the five integer sizes. -/
theorem int_roundtrip (t : IntType) (hwf : t.wf = true) (i : Int) (h : t.canRepresent i = true) :
    t.ofBits (t.toBits i) = i := by
  rcases t with ⟨signed, size⟩
  have hs : size = 1 ∨ size = 2 ∨ size = 4 ∨ size = 8 ∨ size = 16 := by
    simp [IntType.wf] at hwf; omega
  simp only [IntType.canRepresent, IntType.min, IntType.max, IntType.bits, Bool.and_eq_true] at h
  simp only [IntType.ofBits, IntType.toBits, IntType.modulus, IntType.bits]
  rcases hs with rfl | rfl | rfl | rfl | rfl <;> cases signed <;> simp_all <;> omega

theorem toBits_lt (t : IntType) (i : Int) : t.toBits i < 2 ^ (8 * t.size) := by
  simp only [IntType.toBits, IntType.modulus, IntType.bits]
  have hm : 0 < 2 ^ (t.size * 8) := Nat.two_pow_pos _
  have h1 := Int.emod_lt_of_pos i (b := ((2 ^ (t.size * 8) : Nat) : Int)) (by omega)
  have h2 := Int.emod_nonneg i (b := ((2 ^ (t.size * 8) : Nat) : Int)) (by omega)
  rw [Nat.mul_comm]; omega

theorem slice_length_le (l : List AbstractByte) (o n : Nat) : ((l.drop o).take n).length ≤ n := by
  simp [Nat.min_le_left]

theorem decodeBits_slice_lt {l : List AbstractByte} {o n bits : Nat}
    (h : decodeBits ((l.drop o).take n) = some bits) : bits < 2 ^ (n * 8) := by
  have := decodeBits_length h
  have h2 := slice_length_le l o n
  rw [Nat.mul_comm]
  exact Nat.lt_of_lt_of_le this (Nat.pow_le_pow_right (by omega) (by omega))

theorem slice_self (l : List AbstractByte) (n : Nat) (h : l.length = n) : (l.drop 0).take n = l := by
  subst h; simp

/-! ## The niche lemma: the scalar at a niche offset is initialized and in its range -/

mutual

theorem encode_scalarRange (mem : Memory) : (t : Ty) → (v : Value) → (bs : List AbstractByte) →
    (off sz : Nat) → (r : ValidRange) → t.wf = true → checkValue mem v t = .ok () →
    t.encode v = some bs → t.scalarRange off sz = some r →
    ∃ bits, decodeBits ((bs.drop off).take sz) = some bits ∧ r.contains bits = true
  | .int it rr, v, bs, off, sz, r, _, hc, he, hr => by
    cases v <;> simp [checkValue] at hc
    rename_i i
    simp [Ty.encode, hc.1] at he; subst he
    simp [Ty.scalarRange] at hr
    obtain ⟨⟨rfl, rfl⟩, rfl⟩ := hr
    refine ⟨it.toBits i, ?_, hc.2⟩
    rw [slice_self _ _ (encodeBits_length _ _), decodeBits_encodeBits, Nat.mod_eq_of_lt (toBits_lt _ _)]
  | .bool, v, bs, off, sz, r, _, hc, he, hr => by
    cases v <;> simp [checkValue] at hc
    rename_i b
    simp [Ty.encode] at he; subst he
    simp [Ty.scalarRange] at hr
    obtain ⟨⟨rfl, rfl⟩, rfl⟩ := hr
    cases b <;> exact ⟨_, rfl, rfl⟩
  | .char, v, bs, off, sz, r, _, hc, he, hr => by
    cases v <;> simp [checkValue] at hc
    rename_i i
    simp [Ty.encode, hc.1] at he; subst he
    simp [Ty.scalarRange] at hr
    obtain ⟨⟨rfl, rfl⟩, rfl⟩ := hr
    simp only [isUnicodeScalar, Bool.and_eq_true, decide_eq_true_eq] at hc
    refine ⟨i.toNat, ?_, ?_⟩
    · rw [slice_self _ _ (encodeBits_length _ _), decodeBits_encodeBits, Nat.mod_eq_of_lt (by omega)]
    · simp [ValidRange.contains]; omega
  | .ptr p rr, v, bs, off, sz, r, _, hc, he, hr => by
    cases v with
    | ptr pv =>
      simp only [checkValue] at hc
      obtain ⟨ha, hv, _⟩ := checkPtr_ok hc
      simp [Ty.scalarRange] at hr
      obtain ⟨⟨rfl, rfl⟩, rfl⟩ := hr
      refine ⟨pv.thin.addr, ?_, hv⟩
      have : (bs.drop 0).take 8 = encodePtr pv.thin := by
        simp only [Ty.encode] at he
        split at he <;> simp at he <;> subst he
        · exact slice_self _ _ (encodePtr_length _)
        · rw [slice_append_left _ _ _ _ (by simp [encodePtr_length])]
          exact slice_self _ _ (encodePtr_length _)
        · rw [slice_append_left _ _ _ _ (by simp [encodePtr_length])]
          exact slice_self _ _ (encodePtr_length _)
      rw [this, decodeBits_encodePtr, Nat.mod_eq_of_lt (by simpa [Target.ADDR_LIMIT] using ha)]
    | _ => simp [checkValue] at hc
  | .tuple fs hd tail, v, bs, off, sz, r, hwf, hc, he, hr => by
    cases tail with
    | some _ => simp [Ty.scalarRange] at hr
    | none =>
      cases v <;> simp [checkValue] at hc
      rename_i vs
      simp only [Ty.encode] at he
      simp only [Ty.wf, Bool.and_eq_true, List.all_eq_true] at hwf
      obtain ⟨⟨⟨⟨hf, hb⟩, hdj⟩, _⟩, _⟩ := hwf
      obtain ⟨hl, hencs, _⟩ := encodeFields_spec fs vs _ bs hf (fun x hx => by
          have := hb x hx
          simp only [decide_eq_true_eq] at this
          simp only [List.length_replicate]
          exact Nat.le_trans this (alignTo_ge _ _))
        (by simpa [List.pairwise_map] using rangesDisjoint_pairwise _ hdj) he
      obtain ⟨_, hcs⟩ := checkFields_ok hc
      simp only [Ty.scalarRange] at hr
      exact encodeFields_scalarRange mem fs vs bs off sz r hencs hl hcs hf hr
  | .array e n, v, bs, off, sz, r, hwf, hc, he, hr => by
    cases v <;> simp [checkValue] at hc
    rename_i vs
    obtain ⟨hn, hce⟩ := hc
    simp only [Ty.wf, Bool.and_eq_true] at hwf
    obtain ⟨⟨hew, hes⟩, _⟩ := hwf
    simp only [Ty.scalarRange, Bool.and_eq_true, decide_eq_true_eq] at hr
    split at hr
    · rename_i hcond
      simp only [Ty.encode, bne_iff_ne, ne_eq, Option.bind_eq_bind, Option.pure_def] at he
      split at he
      · simp at he
      · cases hp : vs.mapM e.encode with
        | none => simp [hp] at he
        | some parts =>
          simp [hp] at he
          subst he
          obtain ⟨hpl, hpe⟩ := (mapM_option_iff _ _ _).1 hp
          have h0 : 0 < vs.length := by omega
          have hp0 := hpe 0 h0 (by omega)
          have hl0 := encode_length' e _ _ hew hes hp0
          cases parts with
          | nil => simp at hpl; omega
          | cons p0 rest =>
            simp only [List.flatten_cons]
            simp only [List.getElem_cons_zero] at hl0
            rw [slice_append_left _ _ _ _ (by rw [hl0]; exact hcond.2)]
            exact encode_scalarRange mem e vs[0] p0 off sz r hew (checkElems_ok hce 0 h0) hp0 hr
    · simp at hr
  | .enum vs dt repr size al, v, bs, off, sz, r, hwf, hc, he, hr => by
    cases v with
    | variant idx data =>
      simp only [Ty.wf, Bool.and_eq_true] at hwf
      obtain ⟨⟨⟨_, _⟩, hvw⟩, hrw⟩ := hwf
      simp only [Ty.encode, Option.bind_eq_bind] at he
      cases hb0 : Ty.encodeVariant vs idx data with
      | none => simp [hb0] at he
      | some b0 =>
        simp only [hb0, Option.bind_some] at he
        have hl0 := encodeVariant_length vs size idx data b0 hvw hb0
        cases repr with
        | empty => simp [Ty.scalarRange] at hr
        | single i =>
          simp [checkValue] at hc
          obtain ⟨_, rfl, hcv⟩ := hc
          simp at he; subst he
          simp only [Ty.scalarRange] at hr
          exact encodeVariant_scalarRange mem vs size i data b0 off sz r hvw hcv hb0 hr
        | multiple tag =>
          simp [checkValue] at hc
          obtain ⟨hinh, hcv⟩ := hc
          simp [Ty.scalarRange] at hr
          obtain ⟨⟨rfl, rfl⟩, rfl⟩ := hr
          simp only [Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true, List.mem_range] at hrw
          obtain ⟨⟨⟨⟨_, htb⟩, hvalw⟩, _⟩, hvtw⟩ := hrw
          obtain ⟨vv, hvv, _⟩ := checkVariant_ok hcv
          have hidx : idx < vs.length := (List.getElem?_eq_some_iff.1 hvv).1
          have hvt := hvtw idx hidx
          simp only [variantTagWf, hvv] at hvt
          have hvinh : vv.inhabited = true := by
            simpa [variantInhabited, hvv] using hinh
          simp only [hvinh, Bool.not_true, Bool.false_or] at hvt
          simp only at he
          split at he
          · -- untagged
            rename_i hnone
            simp at he; subst he
            rw [hnone] at hvt
            cases henc : tag.encoding with
            | direct => simp [henc] at hvt
            | niche u lo hi st =>
              cases hsr : vv.fields.scalarRange tag.offset tag.tag.size with
              | none => simp [henc, hsr] at hvt
              | some r' =>
                simp only [henc, hsr, Bool.and_eq_true] at hvt
                obtain ⟨⟨hr'w, hsub⟩, _⟩ := hvt
                obtain ⟨bits, hbits, hcont⟩ := encodeVariant_scalarRange mem vs size idx data b0
                  tag.offset tag.tag.size r' hvw hcv hb0
                  (by rw [scalarRangeVariant_eq, hvv]; exact hsr)
                refine ⟨bits, hbits, ?_⟩
                have hlt := decodeBits_slice_lt hbits
                simp only [ValidRange.wf, Bool.and_eq_true, decide_eq_true_eq] at hr'w hvalw
                exact ValidRange.subset_sound hsub hr'w.1 hvalw.1
                  (by simpa [IntType.modulus, IntType.bits] using hlt) hcont
          · -- tagged
            rename_i bits hsome
            simp at he; subst he
            rw [hsome] at hvt
            simp only [Bool.and_eq_true, decide_eq_true_eq] at hvt
            obtain ⟨⟨⟨hbm, hbv⟩, _⟩, _⟩ := hvt
            refine ⟨bits, ?_, hbv⟩
            have := slice_writeAt_self b0 (encodeBits tag.tag.size bits) tag.offset
              (by rw [encodeBits_length, hl0]; exact htb)
            rw [encodeBits_length] at this
            rw [this, decodeBits_encodeBits, Nat.mod_eq_of_lt (by
              simpa [IntType.modulus, IntType.bits, Nat.mul_comm] using hbm)]
    | _ => simp [checkValue] at hc
  | .float _, _, _, _, _, _, _, _, _, hr => by simp [Ty.scalarRange] at hr
  | .fnDef _, _, _, _, _, _, _, _, _, hr => by simp [Ty.scalarRange] at hr
  | .slice _, _, _, _, _, _, _, _, _, hr => by simp [Ty.scalarRange] at hr
  | .union .., _, _, _, _, _, _, _, _, hr => by simp [Ty.scalarRange] at hr
  | .traitObject _, _, _, _, _, _, _, _, _, hr => by simp [Ty.scalarRange] at hr
  | .opaqueBytes .., _, _, _, _, _, _, _, _, hr => by simp [Ty.scalarRange] at hr

theorem encodeFields_scalarRange (mem : Memory) : (fs : List (Offset × Ty)) → (vs : List Value) →
    (bs : List AbstractByte) → (off sz : Nat) → (r : ValidRange) →
    (∀ j (h1 : j < fs.length) (h2 : j < vs.length), ∃ enc, fs[j].2.encode vs[j] = some enc ∧
      (bs.drop fs[j].1).take fs[j].2.size = enc) →
    vs.length = fs.length →
    (∀ j (h1 : j < fs.length) (h2 : j < vs.length), checkValue mem vs[j] fs[j].2 = .ok ()) →
    Ty.wfFields fs = true → Ty.scalarRangeFields fs off sz = some r →
    ∃ bits, decodeBits ((bs.drop off).take sz) = some bits ∧ r.contains bits = true
  | [], _, _, _, _, _, _, _, _, _, hr => by simp [Ty.scalarRangeFields] at hr
  | (o, t) :: fs, vs, bs, off, sz, r, hencs, hl, hcs, hwf, hr => by
    cases vs with
    | nil => simp at hl
    | cons v vs =>
      simp only [Ty.wfFields, Bool.and_eq_true] at hwf
      simp only [Ty.scalarRangeFields, Bool.and_eq_true, decide_eq_true_eq] at hr
      by_cases hcond : o ≤ off ∧ off + sz ≤ o + t.size
      · simp only [hcond, and_self, ite_true] at hr
        have hc1 : off - o + o = off := Nat.sub_add_cancel hcond.1
        have hc2 : off + sz ≤ (o : Nat) + t.size := hcond.2
        obtain ⟨enc, he, hs⟩ := hencs 0 (by simp) (by simp)
        simp only [List.getElem_cons_zero] at he hs
        obtain ⟨bits, hb, hcont⟩ := encode_scalarRange mem t v enc (off - o) sz r hwf.1.1
          (hcs 0 (by simp) (by simp)) he hr
        refine ⟨bits, ?_, hcont⟩
        rw [← hs, slice_slice bs o t.size (off - o) sz (by omega),
          Nat.add_sub_cancel' hcond.1] at hb
        exact hb
      · simp only [hcond, ite_false] at hr
        exact encodeFields_scalarRange mem fs vs bs off sz r
          (fun j h1 h2 => hencs (j + 1) (by simp; omega) (by simp; omega))
          (by simpa using hl)
          (fun j h1 h2 => hcs (j + 1) (by simp; omega) (by simp; omega)) hwf.2 hr

theorem encodeVariant_scalarRange (mem : Memory) : (vs : List Variant) → (size idx : Nat) →
    (data : Value) → (bs : List AbstractByte) → (off sz : Nat) → (r : ValidRange) →
    Ty.wfVariants vs size = true → checkVariant mem vs idx data = .ok () →
    Ty.encodeVariant vs idx data = some bs → Ty.scalarRangeVariant vs idx off sz = some r →
    ∃ bits, decodeBits ((bs.drop off).take sz) = some bits ∧ r.contains bits = true
  | [], _, _, _, _, _, _, _, _, _, he, _ => by simp [Ty.encodeVariant] at he
  | ⟨_, t, _⟩ :: _, size, 0, data, bs, off, sz, r, hwf, hc, he, hr => by
    simp only [Ty.wfVariants, Bool.and_eq_true] at hwf
    simp only [checkVariant] at hc
    simp only [Ty.encodeVariant] at he
    simp only [Ty.scalarRangeVariant] at hr
    exact encode_scalarRange mem t data bs off sz r hwf.1.1.1 hc he hr
  | _ :: vs, size, n + 1, data, bs, off, sz, r, hwf, hc, he, hr => by
    simp only [Ty.wfVariants, Bool.and_eq_true] at hwf
    simp only [checkVariant] at hc
    simp only [Ty.encodeVariant] at he
    simp only [Ty.scalarRangeVariant] at hr
    exact encodeVariant_scalarRange mem vs size n data bs off sz r hwf.2 hc he hr

end

/-! ## Decoding only reads the fields -/

theorem decodeFields_congr : ∀ (fs : List (Offset × Ty)) (b1 b2 : List AbstractByte),
    (∀ x ∈ fs, (b1.drop x.1).take x.2.size = (b2.drop x.1).take x.2.size) →
    Ty.decodeFields fs b1 = Ty.decodeFields fs b2
  | [], _, _, _ => rfl
  | (o, t) :: fs, b1, b2, h => by
    simp only [Ty.decodeFields]
    rw [decodeFields_congr fs b1 b2 (fun x hx => h x (by simp [hx]))]
    cases hs : t.size? with
    | none => rfl
    | some s =>
      have : s = t.size := by simp [Ty.size, hs]
      subst this
      have := h (o, t) (by simp)
      simp only at this
      simp [this]

theorem decode_tuple_eq (fs : List (Offset × Ty)) (h : TupleHeadLayout) (bytes : List AbstractByte) :
    (Ty.tuple fs h none).decode bytes = (Ty.decodeFields fs bytes).map Value.tuple := by
  simp only [Ty.decode]
  cases Ty.decodeFields fs bytes <;> rfl

/-- The union encoding gives back each chunk. -/
theorem union_slices (chunks : List (Offset × Size)) (data : List (List AbstractByte)) (size : Nat)
    (hlen : chunks.length = data.length)
    (hd : ∀ j (h1 : j < chunks.length) (h2 : j < data.length), data[j].length = chunks[j].2)
    (hb : ∀ c ∈ chunks, c.1 + c.2 ≤ size) (hp : chunks.Pairwise WDisj) :
    (chunks.map fun c => ((writeAll (List.replicate size AbstractByte.uninit)
      ((chunks.zip data).map fun x => (x.1.1, x.2))).drop c.1).take c.2) = data := by
  have hzl : (chunks.zip data).length = chunks.length := by simp [hlen]
  obtain ⟨_, hw, _⟩ := writeAll_spec ((chunks.zip data).map fun x => (x.1.1, x.2))
    (List.replicate size AbstractByte.uninit)
    (fun w hw => by
      simp only [List.mem_map] at hw
      obtain ⟨⟨c, d⟩, hm, rfl⟩ := hw
      obtain ⟨j, hj, hjeq⟩ := List.getElem_of_mem hm
      rw [List.getElem_zip] at hjeq
      simp only [Prod.mk.injEq] at hjeq
      obtain ⟨rfl, rfl⟩ := hjeq
      simp only [List.length_replicate]
      rw [hd j (by omega) (by simp at hj; omega)]
      exact hb _ (List.getElem_mem _))
    (by
      rw [List.pairwise_iff_getElem] at hp ⊢
      intro i j hi hj hij
      simp only [List.length_map] at hi hj
      simp only [List.getElem_map, List.getElem_zip]
      have := hp i j (by omega) (by omega) hij
      rw [hd i (by omega) (by omega), hd j (by omega) (by omega)]
      exact this)
  apply List.ext_getElem (by simp [hlen])
  intro j h1 h2
  simp only [List.getElem_map]
  have hm : (chunks[j].1, data[j]) ∈ (chunks.zip data).map fun x => (x.1.1, x.2) := by
    simp only [List.mem_map]
    exact ⟨(chunks[j], data[j]), by
      rw [List.mem_iff_getElem]; exact ⟨j, by simp at h1; omega, by simp [List.getElem_zip]⟩, rfl⟩
  have := hw _ hm
  simp only at this
  rw [hd j (by simpa using h1) h2] at this
  exact this

theorem variantShape_eq {t : Ty}
    (h : (match t with | .tuple _ _ none => true | _ => false) = true) :
    ∃ fs hd, t = .tuple fs hd none := by
  split at h
  · exact ⟨_, _, rfl⟩
  · simp at h

/-! ## `decode (encode v) = v` -/

mutual

theorem decode_encode' (mem : Memory) : (t : Ty) → (v : Value) → t.wf = true → t.isSized = true →
    checkValue mem v t = .ok () → ∃ bs, t.encode v = some bs ∧ t.decode bs = some v
  | .int it rr, v, hwf, _, hc => by
    cases v <;> simp [checkValue] at hc
    rename_i i
    simp only [Ty.wf, Bool.and_eq_true] at hwf
    refine ⟨encodeBits it.size (it.toBits i), by simp [Ty.encode, hc.1], ?_⟩
    simp [Ty.decode, encodeBits_length, decodeBits_encodeBits, Nat.mod_eq_of_lt (toBits_lt it i), hc.2,
      int_roundtrip it hwf.1 i hc.1]
  | .bool, v, _, _, hc => by
    cases v <;> simp [checkValue] at hc
    rename_i b
    cases b <;> exact ⟨_, rfl, rfl⟩
  | .char, v, _, _, hc => by
    cases v <;> simp [checkValue] at hc
    rename_i i
    obtain ⟨h0, hu⟩ := hc
    have hle : i.toNat ≤ 0x10FFFF := by
      simp only [isUnicodeScalar, Bool.and_eq_true, decide_eq_true_eq] at hu; exact hu.1
    refine ⟨encodeBits 4 i.toNat, by simp [Ty.encode, h0], ?_⟩
    have h1 : i.toNat % 2 ^ 32 = i.toNat := Nat.mod_eq_of_lt (by omega)
    simp [Ty.decode, encodeBits_length, decodeBits_encodeBits, h1, hu, Int.toNat_of_nonneg h0]
  | .float f, v, _, _, hc => by
    cases v with
    | float g b =>
      by_cases hcc : g = f ∧ b < 2 ^ f.bits
      · obtain ⟨rfl, hb⟩ := hcc
        refine ⟨encodeBits g.size b, by simp [Ty.encode], ?_⟩
        simp [Ty.decode, encodeBits_length, decodeBits_encodeBits]
        exact Nat.mod_eq_of_lt (by simpa [FloatTy.bits, Nat.mul_comm] using hb)
      · simp [checkValue] at hc
        exfalso; apply hcc
        revert hc
        split <;> simp_all
    | _ => simp [checkValue] at hc
  | .ptr p rr, v, _, _, hc => by

    cases v with
    | ptr pv =>
      simp only [checkValue] at hc
      obtain ⟨ha, hv, hm⟩ := checkPtr_ok hc
      have ha' : pv.thin.addr < 2 ^ 64 := by simpa [Target.ADDR_LIMIT] using ha
      obtain ⟨thin, md⟩ := pv
      simp only at ha ha' hv hm
      cases hk : p.metaKind <;> rw [hk] at hm <;> cases md <;>
        simp [checkPtrMetadata] at hm
      · refine ⟨encodePtr thin, by simp [Ty.encode, hk], ?_⟩
        simp [Ty.decode, hk, encodePtr_length, decodePtr_encodePtr thin ha', hv]
      · rename_i m
        cases m with
        | elementCount n =>
          simp at hm
          refine ⟨encodePtr thin ++ encodeBits 8 n, by simp [Ty.encode, hk], ?_⟩
          simp [Ty.decode, hk, encodePtr_length, encodeBits_length,
            decodePtr_encodePtr thin ha', hv, List.drop_left' (encodePtr_length thin),
            List.take_left' (encodePtr_length thin), decodeBits_encodeBits, Nat.mod_eq_of_lt hm]
        | vtablePointer _ => simp at hm
      · rename_i t m
        cases m with
        | elementCount n => simp at hm
        | vtablePointer vt =>
          simp at hm
          have hvt : vt.addr < 2 ^ 64 := by simpa [Target.ADDR_LIMIT] using hm.1.2
          refine ⟨encodePtr thin ++ encodePtr vt, by simp [Ty.encode, hk], ?_⟩
          simp [Ty.decode, hk, encodePtr_length, decodePtr_encodePtr thin ha', hv,
            List.drop_left' (encodePtr_length thin), List.take_left' (encodePtr_length thin),
            decodePtr_encodePtr vt hvt]
    | _ => simp [checkValue] at hc
  | .fnDef _, v, _, _, hc => by
    cases v with
    | tuple vs => cases vs <;> simp [checkValue] at hc; exact ⟨[], rfl, rfl⟩
    | _ => simp [checkValue] at hc
  | .tuple fs hd tail, v, hwf, hs, hc => by
    cases tail with
    | some _ => simp [Ty.isSized, Ty.layout, LayoutStrategy.isSized] at hs
    | none =>
      cases v <;> simp [checkValue] at hc
      rename_i vs
      simp only [Ty.wf, Bool.and_eq_true, List.all_eq_true] at hwf
      obtain ⟨⟨⟨⟨hf, hb⟩, hdj⟩, _⟩, _⟩ := hwf
      obtain ⟨bs, hbs⟩ := encodeFields_exists mem fs vs
        (List.replicate (alignTo hd.end hd.align) AbstractByte.uninit) hf hc
      obtain ⟨hl, hencs, _⟩ := encodeFields_spec fs vs _ bs hf (fun x hx => by
          have := hb x hx
          simp only [decide_eq_true_eq] at this
          simp only [List.length_replicate]
          exact Nat.le_trans this (alignTo_ge _ _))
        (by simpa [List.pairwise_map] using rangesDisjoint_pairwise _ hdj) hbs
      refine ⟨bs, by simpa [Ty.encode, TupleHeadLayout.headSizeAndAlign] using hbs, ?_⟩
      rw [decode_tuple_eq, decodeFields_encode mem fs vs bs hf hc hencs]
      rfl
  | .array e n, v, hwf, _, hc => by
    cases v <;> simp [checkValue] at hc
    rename_i vs
    obtain ⟨hn, hce⟩ := hc
    simp only [Ty.wf, Bool.and_eq_true] at hwf
    obtain ⟨⟨hew, hes⟩, _⟩ := hwf
    -- every element encodes
    have hex : ∀ j (h : j < vs.length), ∃ b, e.encode vs[j] = some b ∧ e.decode b = some vs[j] :=
      fun j h => decode_encode' mem e vs[j] hew hes (checkElems_ok hce j h)
    obtain ⟨parts, hp⟩ := mapM_option_exists e.encode vs (fun j h => by
      obtain ⟨b, hb, _⟩ := hex j h
      exact ⟨b, hb⟩)
    obtain ⟨hpl, hpe⟩ := (mapM_option_iff _ _ _).1 hp
    have hlens : ∀ q ∈ parts, q.length = e.size := fun q hq => by
      obtain ⟨i, hi, rfl⟩ := List.getElem_of_mem hq
      exact encode_length' e vs[i] _ hew hes (hpe i (by omega) hi)
    refine ⟨parts.flatten, by simp [Ty.encode, hn, hp], ?_⟩
    have hlay := Ty.layout_of_isSized hes
    simp only [Ty.decode, hlay]
    rw [length_flatten_const parts e.size hlens]
    simp only [hpl, hn, Nat.mul_comm, bne_self_eq_false, Bool.false_eq_true, ↓reduceIte,
      Option.bind_eq_bind, Option.pure_def]
    have : (List.range n).mapM (fun i => e.decode ((parts.flatten.drop (i * e.size)).take e.size)) =
        some vs := by
      rw [mapM_option_iff]
      refine ⟨by simp [hn], fun i h1 h2 => ?_⟩
      simp only [List.getElem_range]
      rw [slice_flatten parts e.size i hlens (by simp at h1; omega)]
      obtain ⟨b, hb, hdb⟩ := hex i h2
      rw [hpe i h2 (by omega)] at hb
      cases hb
      exact hdb
    simp [this]
  | .slice _, _, _, hs, _ => by
    unfold Ty.isSized Ty.layout at hs; split at hs <;> simp [LayoutStrategy.isSized] at hs
  | .union fields chunks size al, v, hwf, _, hc => by
    cases v <;> simp [checkValue] at hc
    rename_i data
    obtain ⟨hlen, hdl⟩ := hc
    simp only [Ty.wf, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hwf
    obtain ⟨⟨⟨⟨_, _⟩, hcb⟩, hdj⟩, _⟩ := hwf
    have hd : ∀ j (h1 : j < chunks.length) (h2 : j < data.length), data[j].length = chunks[j].2 :=
      fun j h1 h2 => hdl data[j] chunks[j].1 chunks[j].2 (by
          rw [List.mem_iff_getElem]
          exact ⟨j, by simp; omega, by simp [List.getElem_zip]⟩)
    have hall : ∀ f : (Offset × Size) × List AbstractByte → Bool,
        (∀ x, f x = (x.2.length == x.1.2)) → (chunks.zip data).all f = true := by
      intro f hf
      rw [List.all_eq_true]
      intro x hm
      obtain ⟨j, hj, rfl⟩ := List.getElem_of_mem hm
      rw [hf, List.getElem_zip]
      simp only [beq_iff_eq]
      exact hd j (by simp at hj; omega) (by simp at hj; omega)
    have hpw : chunks.Pairwise WDisj := rangesDisjoint_pairwise _ hdj
    refine ⟨writeAll (List.replicate size AbstractByte.uninit)
      ((chunks.zip data).map fun x => (x.1.1, x.2)), ?_, ?_⟩
    · simp only [Ty.encode]
      rw [hall _ (fun x => by rcases x with ⟨⟨o, sz⟩, d⟩; rfl)]
      simp [hlen, foldl_writeAt_eq]
    · have hwl := writeAll_length ((chunks.zip data).map fun x => (x.1.1, x.2))
        (List.replicate size AbstractByte.uninit) (fun w hw => by
          simp only [List.mem_map] at hw
          obtain ⟨⟨c, d⟩, hm, rfl⟩ := hw
          obtain ⟨j, hj, hjeq⟩ := List.getElem_of_mem hm
          rw [List.getElem_zip] at hjeq
          simp only [Prod.mk.injEq] at hjeq
          obtain ⟨rfl, rfl⟩ := hjeq
          simp only [List.length_replicate]
          rw [hd j (by simp at hj; omega) (by simp at hj; omega)]
          exact hcb _ (List.getElem_mem _))
      simp only [Ty.decode, hwl, List.length_replicate, bne_self_eq_false, Bool.false_eq_true,
        ↓reduceIte]
      rw [union_slices chunks data size hlen.symm hd hcb hpw]
  | .enum vs dt repr size al, v, hwf, _, hc => by
    cases v with
    | variant idx data =>
      simp only [Ty.wf, Bool.and_eq_true] at hwf
      obtain ⟨⟨⟨_, _⟩, hvw⟩, hrw⟩ := hwf
      cases repr with
      | empty => simp [checkValue] at hc
      | single i =>
        simp [checkValue] at hc
        obtain ⟨hinh, rfl, hcv⟩ := hc
        obtain ⟨b0, hb0, hd0⟩ := decodeVariant_encode mem vs size i data hvw hcv
        have hl0 := encodeVariant_length vs size i data b0 hvw hb0
        refine ⟨b0, by simp [Ty.encode, hb0], ?_⟩
        simp [Ty.decode, hl0, hinh, hd0]
      | multiple tag =>
        simp [checkValue] at hc
        obtain ⟨hinh, hcv⟩ := hc
        obtain ⟨b0, hb0, hd0⟩ := decodeVariant_encode mem vs size idx data hvw hcv
        have hl0 := encodeVariant_length vs size idx data b0 hvw hb0
        simp only [Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true, List.mem_range] at hrw
        obtain ⟨⟨⟨⟨_, htb⟩, hvalw⟩, hencw⟩, hvtw⟩ := hrw
        obtain ⟨vv, hvv, _⟩ := checkVariant_ok hcv
        have hidx : idx < vs.length := (List.getElem?_eq_some_iff.1 hvv).1
        have hvt := hvtw idx hidx
        simp only [variantTagWf, hvv] at hvt
        have hvinh : vv.inhabited = true := by
          simpa [variantInhabited, hvv] using hinh
        simp only [hvinh, Bool.not_true, Bool.false_or] at hvt
        obtain ⟨_, hshape, _⟩ := wfVariants_get hvw hvv
        obtain ⟨vfs, vhd, hvf⟩ := variantShape_eq hshape
        have hM : 0 < tag.tag.modulus := Nat.two_pow_pos _
        simp only [ValidRange.wf, Bool.and_eq_true, decide_eq_true_eq] at hvalw
        cases htf : tagForVariant vs tag idx with
        | none =>
          refine ⟨b0, by simp [Ty.encode, hb0, htf], ?_⟩
          rw [htf] at hvt
          cases henc : tag.encoding with
          | direct => simp [tagForVariant, henc] at htf
          | niche u lo hi st =>
            have hiu : idx = u := by
              simp only [tagForVariant, henc] at htf
              split at htf
              · simpa using ‹(idx == u) = true›
              · simp at htf
            subst hiu
            rw [henc] at hencw
            simp only [Bool.and_eq_true, decide_eq_true_eq] at hencw
            cases hsr : vv.fields.scalarRange tag.offset tag.tag.size with
            | none => simp [henc, hsr] at hvt
            | some r' =>
              simp only [henc, hsr, Bool.and_eq_true] at hvt
              obtain ⟨⟨hr'w, hsub⟩, hdis⟩ := hvt
              simp only [ValidRange.wf, Bool.and_eq_true, decide_eq_true_eq] at hr'w
              obtain ⟨bits, hbits, hcont⟩ := encodeVariant_scalarRange mem vs size idx data b0
                tag.offset tag.tag.size r' hvw hcv hb0 (by rw [scalarRangeVariant_eq, hvv]; exact hsr)
              have hlt : bits < tag.tag.modulus := by
                simpa [IntType.modulus, IntType.bits] using decodeBits_slice_lt hbits
              have hval := ValidRange.subset_sound hsub (by simpa [IntType.modulus, IntType.bits] using hr'w.1)
                (by simpa [IntType.modulus, IntType.bits] using hvalw.1) hlt hcont
              have hniche := ValidRange.disjoint_sound hdis
                (by simpa [IntType.modulus, IntType.bits] using hr'w.1)
                (by simp only [nicheRange]; exact Nat.mod_lt _ hM) hlt hcont
              have hn : ¬ ((bits + tag.tag.modulus - st % tag.tag.modulus) % tag.tag.modulus ≤ hi - lo) := by
                intro h
                rw [← nicheRange_contains tag lo hi st bits hlt hencw.2] at h
                rw [h] at hniche; simp at hniche
              have htv : tagToVariant vs dt tag bits = .ok idx := by
                simp only [tagToVariant, henc]
                simp only [hn, ite_false]
                simp [hval]
              simp [Ty.decode, hl0, hbits, htv, hinh, hd0]
        | some bits =>
          refine ⟨writeAt b0 tag.offset (encodeBits tag.tag.size bits),
            by simp [Ty.encode, hb0, htf], ?_⟩
          rw [htf] at hvt
          simp only [Bool.and_eq_true, decide_eq_true_eq] at hvt
          obtain ⟨⟨⟨hbm, _⟩, havoid⟩, htv⟩ := hvt
          have htv' : tagToVariant vs dt tag bits = .ok idx := by
            revert htv; split <;> simp_all
          have hb : tag.offset + (encodeBits tag.tag.size bits).length ≤ b0.length := by
            rw [encodeBits_length, hl0]; exact htb
          have hwl := writeAt_length b0 _ _ hb
          have hsl := slice_writeAt_self b0 _ _ hb
          rw [encodeBits_length] at hsl
          have hbits : decodeBits ((writeAt b0 tag.offset (encodeBits tag.tag.size bits)).drop
              tag.offset |>.take tag.tag.size) = some bits := by
            rw [hsl, decodeBits_encodeBits, Nat.mod_eq_of_lt (by
              simpa [IntType.modulus, IntType.bits, Nat.mul_comm] using hbm)]
          have hdec : Ty.decodeVariant vs idx (writeAt b0 tag.offset (encodeBits tag.tag.size bits)) =
              some data := by
            rw [decodeVariant_eq, hvv] at hd0 ⊢
            simp only [Option.bind_some, hvf, decode_tuple_eq] at hd0 ⊢
            rw [decodeFields_congr vfs _ b0 (fun x hx => by
              rw [hvf] at havoid
              simp only [fieldsAvoid, List.all_eq_true] at havoid
              have := havoid x hx
              simp only [rangeDisjoint, Bool.or_eq_true, beq_iff_eq, decide_eq_true_eq] at this
              apply slice_writeAt_disjoint _ _ _ _ _ hb
              rw [encodeBits_length]; simpa [or_assoc] using this)]
            exact hd0
          simp [Ty.decode, hwl, hl0, hbits, htv', hinh, hdec]
    | _ => simp [checkValue] at hc
  | .traitObject _, _, _, hs, _ => by simp [Ty.isSized, Ty.layout, LayoutStrategy.isSized] at hs
  | .opaqueBytes size al, v, _, _, hc => by
    cases v with
    | union cs =>
      match cs, hc with
      | [c], hc =>
        simp [checkValue] at hc
        exact ⟨c, by simp [Ty.encode, hc], by simp [Ty.decode, hc]⟩
      | [], hc => simp [checkValue] at hc
      | _ :: _ :: _, hc => simp [checkValue] at hc
    | _ => simp [checkValue] at hc

theorem encodeFields_exists (mem : Memory) : (fs : List (Offset × Ty)) → (vs : List Value) →
    (acc : List AbstractByte) → Ty.wfFields fs = true → checkFields mem vs fs = .ok () →
    ∃ bs, Ty.encodeFields fs vs acc = some bs
  | [], [], acc, _, _ => ⟨acc, rfl⟩
  | [], _ :: _, _, _, h => by simp [checkFields] at h
  | _ :: _, [], _, _, h => by simp [checkFields] at h
  | (o, t) :: fs, v :: vs, acc, hwf, hc => by
    simp only [Ty.wfFields, Bool.and_eq_true] at hwf
    simp [checkFields] at hc
    obtain ⟨enc, he, _⟩ := decode_encode' mem t v hwf.1.1 hwf.1.2 hc.1
    obtain ⟨bs, hbs⟩ := encodeFields_exists mem fs vs (writeAt acc o enc) hwf.2 hc.2
    exact ⟨bs, by simp [Ty.encodeFields, he, hbs]⟩

theorem decodeFields_encode (mem : Memory) : (fs : List (Offset × Ty)) → (vs : List Value) →
    (bs : List AbstractByte) → Ty.wfFields fs = true → checkFields mem vs fs = .ok () →
    (∀ j (h1 : j < fs.length) (h2 : j < vs.length), ∃ enc, fs[j].2.encode vs[j] = some enc ∧
      (bs.drop fs[j].1).take fs[j].2.size = enc) →
    Ty.decodeFields fs bs = some vs
  | [], [], _, _, _, _ => rfl
  | [], _ :: _, _, _, h, _ => by simp [checkFields] at h
  | _ :: _, [], _, _, h, _ => by simp [checkFields] at h
  | (o, t) :: fs, v :: vs, bs, hwf, hc, hencs => by
    simp only [Ty.wfFields, Bool.and_eq_true] at hwf
    simp [checkFields] at hc
    obtain ⟨enc, he, hs⟩ := hencs 0 (by simp) (by simp)
    simp only [List.getElem_cons_zero] at he hs
    obtain ⟨enc', he', hd⟩ := decode_encode' mem t v hwf.1.1 hwf.1.2 hc.1
    rw [he] at he'; cases he'
    have hrest := decodeFields_encode mem fs vs bs hwf.2 hc.2
      (fun j h1 h2 => hencs (j + 1) (by simp; omega) (by simp; omega))
    simp [Ty.decodeFields, Ty.size?_of_isSized hwf.1.2, hs, hd, hrest]

theorem decodeVariant_encode (mem : Memory) : (vs : List Variant) → (size idx : Nat) →
    (data : Value) → Ty.wfVariants vs size = true → checkVariant mem vs idx data = .ok () →
    ∃ bs, Ty.encodeVariant vs idx data = some bs ∧ Ty.decodeVariant vs idx bs = some data
  | [], _, _, _, _, h => by simp [checkVariant] at h
  | ⟨_, t, _⟩ :: _, size, 0, data, hwf, hc => by
    simp only [Ty.wfVariants, Bool.and_eq_true] at hwf
    simp only [checkVariant] at hc
    exact decode_encode' mem t data hwf.1.1.1 (isSized_of_variantShape hwf.1.1.2) hc
  | _ :: vs, size, n + 1, data, hwf, hc => by
    simp only [Ty.wfVariants, Bool.and_eq_true] at hwf
    simp only [checkVariant] at hc
    exact decodeVariant_encode mem vs size n data hwf.2 hc

end


/-! ## The laws -/

/-- MiniRust's `encode_len`. No value well-formedness is needed: `encode` returns `none` when
the value does not fit the type. -/
theorem encode_length (t : Ty) (v : Value) (bs : List AbstractByte) (hwf : t.wf = true)
    (hs : t.isSized = true) (h : t.encode v = some bs) : bs.length = t.size :=
  encode_length' t v bs hwf hs h

/-- MiniRust's `decode_encode`: values `check_value` accepts round-trip. -/
theorem decode_encode (mem : Memory) (t : Ty) (v : Value) (hwf : t.wf = true)
    (hs : t.isSized = true) (hc : checkValue mem v t = .ok ()) :
    (t.encode v).bind t.decode = some v := by
  obtain ⟨bs, he, hd⟩ := decode_encode' mem t v hwf hs hc
  simp [he, hd]

/-! ## Scalar cases (corollaries kept for reference) -/

theorem decode_encode_int (t : IntType) (r : ValidRange) (hwf : t.wf = true) (i : Int)
    (h : t.canRepresent i = true) (hr : r.contains (t.toBits i) = true) :
    ((Ty.int t r).encode (.int i)).bind (Ty.int t r).decode = some (.int i) := by
  simp [Ty.encode, h, Ty.decode, encodeBits_length, decodeBits_encodeBits,
    Nat.mod_eq_of_lt (toBits_lt t i), hr, int_roundtrip t hwf i h]

theorem decode_encode_bool (b : Bool) :
    (Ty.bool.encode (.bool b)).bind Ty.bool.decode = some (.bool b) := by
  cases b <;> rfl

/-! ## Open goals -/

theorem encode_decode_le (t : Ty) (bytes : List AbstractByte) (v : Value)
    (_ : t.wf = true) (_ : bytes.length = t.size) (_ : t.decode bytes = some v) :
    ∃ bs, t.encode v = some bs ∧ bytesLeDefined bs bytes = true := by
  sorry

theorem decode_mono (t : Ty) (b1 b2 : List AbstractByte) (_ : t.wf = true)
    (_ : bytesLeDefined b1 b2 = true) :
    Option.leDefinedBy Value.leDefined (t.decode b1) (t.decode b2) = true := by
  sorry

theorem store_load (mem mem' : Memory) (p : ThinPointer) (t : Ty) (v : Value) (al : Align)
    (_ : t.wf = true) (_ : checkValue mem v t = .ok ())
    (_ : typedStore mem p v t al = .ok mem') :
    ∃ w, typedLoad mem' p t al = .ok w ∧ Value.leDefined w v = true := by
  sorry

end Ryo.Spec.Theorems
