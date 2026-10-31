/-
Ryo.Spec.Theorems.Memory — typed stores and loads: `store_load`.

Ryo's own: MiniRust `lang/representation.md` § Generic properties states only the `encode`/
`decode` laws (size, monotonicity, round trips), no store-then-load law; `store_load` is their
consequence for `typedStore`/`typedLoad`, in the `leDefined` form chosen here.

`typedLoad` re-runs `checkValue` in the memory *after* the store. A wide pointer's validity
depends on the vtable its metadata points to (`vtableSizeAlign` reads the vtable's size and
align words), so a store that overwrites a mutable `.vtable` allocation could invalidate the
stored value itself. Vtable allocations are read-only by construction (the `Allocation.vtableRo`
field, see `Memory.vtables_ro`), so the theorems hold for every memory, not only reachable ones.
-/
import Ryo.Spec.Theorems.Representation

namespace Ryo.Spec.Theorems

open Ryo.Spec

/-! ## Raw memory: store then load -/

theorem foldl_set_getElem (l : List AbstractByte) (start off : Nat) (d : Array AbstractByte)
    (j : Nat) :
    (((l.zipIdx start).foldl (fun d (b, i) => d.set! (off + i) b) d)[j]?) =
      if off + start ≤ j ∧ j < off + start + l.length ∧ j < d.size then l[j - off - start]?
      else d[j]? := by
  induction l generalizing start d with
  | nil => simp; omega
  | cons b l ih =>
    simp only [List.zipIdx_cons, List.foldl_cons, ih]
    simp only [Array.set!, Array.size_setIfInBounds, Array.getElem?_setIfInBounds, List.length_cons]
    rcases Nat.lt_trichotomy j (off + start) with hj | hj | hj
    · have h1 : ¬(off + (start + 1) ≤ j ∧ j < off + (start + 1) + l.length ∧ j < d.size) := by omega
      have h2 : ¬(off + start ≤ j ∧ j < off + start + (l.length + 1) ∧ j < d.size) := by omega
      rw [ite_eq_right h1, ite_eq_right h2, ite_eq_right (by omega)]
    · subst hj
      have h1 : ¬(off + (start + 1) ≤ off + start ∧ off + start < off + (start + 1) + l.length ∧
        off + start < d.size) := by omega
      rw [ite_eq_right h1]
      by_cases h3 : off + start < d.size <;> simp [h3]
    · have h0 : ¬(off + start = j) := by omega
      by_cases h1 : off + (start + 1) ≤ j ∧ j < off + (start + 1) + l.length ∧ j < d.size
      · have h2 : off + start ≤ j ∧ j < off + start + (l.length + 1) ∧ j < d.size := by omega
        rw [ite_eq_left h1, ite_eq_left h2, show j - off - start = (j - off - (start + 1)) + 1 by omega]
        simp
      · have h2 : ¬(off + start ≤ j ∧ j < off + start + (l.length + 1) ∧ j < d.size) := by omega
        rw [ite_eq_right h1, ite_eq_right h0, ite_eq_right h2]

theorem foldl_set_size (l : List AbstractByte) (start off : Nat) (d : Array AbstractByte) :
    ((l.zipIdx start).foldl (fun d (b, i) => d.set! (off + i) b) d).size = d.size := by
  induction l generalizing start d with
  | nil => simp
  | cons b l ih =>
    have := ih (start + 1) (d.set! (off + start) b)
    simp_all [List.zipIdx_cons, Array.set!]

theorem Memory.checkPtr_eq_ok {mem : Memory} {p : ThinPointer} {len : Nat} {r} :
    mem.checkPtr p len = .ok r ↔
      (len = 0 ∧ r = none) ∨
      ∃ id, ∃ h : id < mem.allocs.size, len ≠ 0 ∧ p.prov = some id ∧
        mem.allocs[id].live = true ∧ mem.allocs[id].addr ≤ p.addr ∧
        p.addr + len ≤ mem.allocs[id].addr + mem.allocs[id].data.size ∧
        r = some (id, p.addr - mem.allocs[id].addr) := by
  have hp : ∀ x : Option (AllocId × Nat), (pure x : Except Outcome _) = .ok r ↔ r = x := by
    intro x; show Except.ok x = _ ↔ _; simp [eq_comm]
  rcases p with ⟨addr, _ | id⟩
  · by_cases hl : len = 0 <;> simp [Memory.checkPtr, hl, hp]
  · by_cases hl : len = 0
    · simp [Memory.checkPtr, hl, hp]
    · by_cases hid : id < mem.allocs.size
      · simp [Memory.checkPtr, hl, Memory.get?, hid, Allocation.size]
        by_cases hlv : mem.allocs[id].live = true
        · by_cases hb : addr < mem.allocs[id].addr ∨
              mem.allocs[id].addr + mem.allocs[id].data.size < addr + len
          · simp [hlv, hb]
            have : ((fun a => some (id, addr - mem.allocs[id].addr)) <$>
                (throwUb "dereferencing pointer outside the bounds of its allocation" :
                  Except Outcome Unit)) =
                throwUb "dereferencing pointer outside the bounds of its allocation" := rfl
            rw [this]; simp; omega
          · simp [hlv, hb, hp]
            exact ⟨fun h => ⟨by omega, by omega, h⟩, fun h => h.2.2⟩
        · simp [hlv]
      · have : mem.allocs[id]? = none := Array.getElem?_eq_none (Nat.le_of_not_lt hid)
        simp [Memory.checkPtr, hl, Memory.get?, hid]

theorem Memory.store_eq_ok {mem mem' : Memory} {p : ThinPointer} {bytes : List AbstractByte}
    {al : Align} (h : mem.store p bytes al = .ok mem') :
    (al.isAligned p.addr = true ∧ bytes.length = 0 ∧ mem' = mem) ∨
      ∃ id, ∃ h : id < mem.allocs.size, al.isAligned p.addr = true ∧ bytes.length ≠ 0 ∧
        p.prov = some id ∧ mem.allocs[id].live = true ∧ mem.allocs[id].addr ≤ p.addr ∧
        p.addr + bytes.length ≤ mem.allocs[id].addr + mem.allocs[id].data.size ∧
        mem.allocs[id].mutable = true ∧
        mem' = { allocs := mem.allocs.set id { mem.allocs[id] with
          data := (bytes.zipIdx).foldl (fun d (b, i) => d.set! (p.addr - mem.allocs[id].addr + i) b)
            mem.allocs[id].data } } := by
  simp only [Memory.store] at h
  split at h
  · simp at h
  rename_i hal
  simp [Except.bind_eq_ok] at h
  obtain ⟨r, hr, h⟩ := h
  rw [Memory.checkPtr_eq_ok] at hr
  rcases hr with ⟨hl, rfl⟩ | ⟨id, hid, hl, hprov, hlv, h1, h2, rfl⟩
  · exact .inl ⟨by simpa using hal, hl, (Except.ok.inj h).symm⟩
  · right
    have hg : mem.allocs[id]! = mem.allocs[id] := getElem!_pos mem.allocs id hid
    simp only [hg] at h
    by_cases hm : mem.allocs[id].mutable = true
    · simp only [hm, Bool.true_eq_false, ite_false] at h
      refine ⟨id, hid, by simpa using hal, hl, hprov, hlv, h1, h2, hm, ?_⟩
      rw [← Except.ok.inj h]
      simp only [Array.setIfInBounds, hid, dite_true]
      simp only [hm]; rfl
    · simp only [hm, ite_true] at h
      exact absurd h (by intro e; cases e)

theorem Memory.store_load_bytes {mem mem' : Memory} {p : ThinPointer} {bytes : List AbstractByte}
    {al : Align} (h : mem.store p bytes al = .ok mem') :
    mem'.load p bytes.length al = .ok bytes := by
  rcases Memory.store_eq_ok h with ⟨hal, hl, rfl⟩ | ⟨id, hid, hal, hl, hprov, hlv, h1, h2, hm, rfl⟩
  · simp [Memory.load, hal, Memory.checkPtr, List.eq_nil_of_length_eq_zero hl]; rfl
  · have hc := (Memory.checkPtr_eq_ok (mem := { allocs := mem.allocs.set id { mem.allocs[id] with
          data := (bytes.zipIdx).foldl (fun d (b, i) => d.set! (p.addr - mem.allocs[id].addr + i) b)
            mem.allocs[id].data } }) (p := p) (len := bytes.length)
        (r := some (id, p.addr - mem.allocs[id].addr))).mpr
      (.inr ⟨id, by simpa using hid, hl, hprov, by simpa using hlv, by simpa using h1,
        by simp only [Array.getElem_set_self]; rw [foldl_set_size]; exact h2, by simp⟩)
    unfold Memory.load
    simp only [hal, Bool.not_true, Bool.false_eq_true, ite_false]
    rw [hc]
    simp only [bind, Except.bind]
    rw [getElem!_pos _ id (by simpa using hid)]
    simp only [Array.getElem_set_self]
    show Except.ok _ = _
    congr 1
    apply List.ext_getElem?
    intro k
    simp only [Array.getElem?_toList, Array.getElem?_extract]
    have h3 : p.addr - mem.allocs[id].addr + bytes.length ≤ mem.allocs[id].data.size := by omega
    generalize p.addr - mem.allocs[id].addr = o at h3 ⊢
    generalize hf : List.foldl _ mem.allocs[id].data bytes.zipIdx = arr
    have hs : arr.size = mem.allocs[id].data.size := by
      rw [← hf]; exact foldl_set_size bytes 0 _ _
    have hg : arr[o + k]? = if o + 0 ≤ o + k ∧ o + k < o + 0 + bytes.length ∧
        o + k < mem.allocs[id].data.size then bytes[o + k - o - 0]?
        else mem.allocs[id].data[o + k]? := by
      rw [← hf]; exact foldl_set_getElem bytes 0 o mem.allocs[id].data (o + k)
    rw [hs, hg]
    by_cases hk : k < bytes.length
    · rw [ite_eq_left (by omega), ite_eq_left (by omega)]; congr 1; omega
    · rw [ite_eq_right (by omega)]; simp; omega

/-! ## The store preserves everything `checkValue` looks at -/

/-- `mem'` has the same allocations as `mem`, each with the same address, kind, liveness and
size, and vtable allocations unchanged; non-vtable allocations may differ in anything else
(data, but also alignment and mutability). -/
def Agree (mem mem' : Memory) : Prop :=
  mem.allocs.size = mem'.allocs.size ∧
    ∀ i (h : i < mem.allocs.size) (h' : i < mem'.allocs.size),
      mem.allocs[i].addr = mem'.allocs[i].addr ∧ mem.allocs[i].kind = mem'.allocs[i].kind ∧
      mem.allocs[i].live = mem'.allocs[i].live ∧ mem.allocs[i].size = mem'.allocs[i].size ∧
      (mem.allocs[i].kind = .vtable → mem.allocs[i] = mem'.allocs[i])

theorem Memory.vtables_ro (mem : Memory) :
    ∀ a ∈ mem.allocs.toList, a.kind = .vtable → a.mutable = false :=
  fun a _ h => a.vtableRo h

theorem Memory.store_agree {mem mem' : Memory} {p : ThinPointer} {bytes : List AbstractByte}
    {al : Align} (h : mem.store p bytes al = .ok mem') : Agree mem mem' := by
  rcases Memory.store_eq_ok h with ⟨_, _, rfl⟩ | ⟨id, hid, _, _, _, _, _, _, hm, rfl⟩
  · exact ⟨rfl, fun i _ _ => ⟨rfl, rfl, rfl, rfl, fun _ => rfl⟩⟩
  · refine ⟨by simp, fun i h h' => ?_⟩
    by_cases hi : id = i
    · subst hi
      simp only [Array.getElem_set_self, Allocation.size]
      refine ⟨?_, ?_, ?_, ?_, fun hk => ?_⟩
      any_goals first | trivial | rfl | exact (foldl_set_size _ _ _ _).symm
      have := Memory.vtables_ro mem _ (by simp) hk
      simp_all
    · simp [Array.getElem_set, hi]

theorem Agree.get? {mem mem' : Memory} (h : Agree mem mem') (id : AllocId) :
    (mem.get? id = none ∧ mem'.get? id = none) ∨
      ∃ a a', mem.get? id = some a ∧ mem'.get? id = some a' ∧ a.addr = a'.addr ∧
        a.kind = a'.kind ∧ a.live = a'.live ∧ a.size = a'.size ∧ (a.kind = .vtable → a = a') := by
  by_cases hid : id < mem.allocs.size
  · have hid' : id < mem'.allocs.size := h.1 ▸ hid
    exact .inr ⟨_, _, by simp [Memory.get?, hid], by simp [Memory.get?, hid'], h.2 id hid hid'⟩
  · have hid' : ¬id < mem'.allocs.size := h.1 ▸ hid
    exact .inl ⟨Array.getElem?_eq_none (Nat.le_of_not_lt hid),
      Array.getElem?_eq_none (Nat.le_of_not_lt hid')⟩

theorem Agree.dereferenceable {mem mem' : Memory} (h : Agree mem mem') :
    mem.dereferenceable = mem'.dereferenceable := by
  funext p n
  rcases p with ⟨addr, _ | id⟩
  · simp [Memory.dereferenceable, Memory.checkPtr]
  · rcases h.get? id with ⟨h1, h2⟩ | ⟨a, a', h1, h2, e1, -, e3, e4, -⟩
    · simp [Memory.dereferenceable, Memory.checkPtr, h1, h2]
    · simp [Memory.dereferenceable, Memory.checkPtr, h1, h2, e1, e3, e4]

theorem Agree.vtableSizeAlign {mem mem' : Memory} (h : Agree mem mem') :
    vtableSizeAlign mem = vtableSizeAlign mem' := by
  funext p
  rcases p with ⟨addr, _ | id⟩
  · simp [Ryo.Spec.vtableSizeAlign, Memory.allocAt?]
  · rcases h.get? id with ⟨h1, h2⟩ | ⟨a, a', h1, h2, -, e2, -, -, e5⟩
    · simp [Ryo.Spec.vtableSizeAlign, Memory.allocAt?, h1, h2]
    · by_cases hk : a.kind = .vtable
      · obtain rfl := e5 hk
        simp [Ryo.Spec.vtableSizeAlign, Memory.allocAt?, h1, h2]
      · have hk' : ¬a'.kind = .vtable := e2 ▸ hk
        simp [Ryo.Spec.vtableSizeAlign, Memory.allocAt?, h1, h2, hk, hk']

theorem checkPtr_congr {mem mem' : Memory} (hd : mem.dereferenceable = mem'.dereferenceable)
    (hv : vtableSizeAlign mem = vtableSizeAlign mem') : checkPtr mem = checkPtr mem' := by
  funext p pt valid
  simp only [checkPtr, checkPtrMetadata, computeSizeAndAlign, hd, hv]

theorem checkFields_congr {mem mem' : Memory} :
    ∀ (vs : List Value) (fs : List (Offset × Ty)),
      (∀ v ∈ vs, ∀ t, checkValue mem v t = checkValue mem' v t) →
      checkFields mem vs fs = checkFields mem' vs fs
  | [], [] , _ => by simp [checkFields]
  | [], _ :: _, _ => by simp [checkFields]
  | _ :: _, [], _ => by simp [checkFields]
  | v :: vs, (_, t) :: fs, h => by
    simp [checkFields, h v (by simp), checkFields_congr vs fs (fun w hw => h w (by simp [hw]))]

theorem checkElems_congr {mem mem' : Memory} (t : Ty) :
    ∀ (vs : List Value), (∀ v ∈ vs, ∀ t, checkValue mem v t = checkValue mem' v t) →
      checkElems mem vs t = checkElems mem' vs t
  | [], _ => by simp [checkElems]
  | v :: vs, h => by
    simp [checkElems, h v (by simp), checkElems_congr t vs (fun w hw => h w (by simp [hw]))]

theorem checkVariant_congr {mem mem' : Memory} (v : Value)
    (h : ∀ t, checkValue mem v t = checkValue mem' v t) :
    ∀ (vs : List Variant) (n : Nat), checkVariant mem vs n v = checkVariant mem' vs n v
  | [], _ => by simp [checkVariant]
  | ⟨_, t, _⟩ :: _, 0 => by simp [checkVariant, h]
  | _ :: vs, n + 1 => by simp [checkVariant, checkVariant_congr v h vs n]

theorem checkValue_congr {mem mem' : Memory} (hp : checkPtr mem = checkPtr mem') :
    ∀ (v : Value) (t : Ty), checkValue mem v t = checkValue mem' v t
  | .tuple vs, t => by
    have ih : ∀ w ∈ vs, ∀ t, checkValue mem w t = checkValue mem' w t := fun w hw =>
      have := List.sizeOf_lt_of_mem hw
      checkValue_congr hp w
    cases t <;> (try (rename_i tl; cases tl)) <;> cases vs <;>
      first | rfl | simp [checkValue, checkFields_congr _ _ ih, checkElems_congr _ _ ih]
  | .variant idx data, t => by
    cases t <;> first | rfl | simp [checkValue, checkVariant_congr data (checkValue_congr hp data)]
  | .union d, t => by
    cases t <;> first | rfl | simp [checkValue] | (rcases d with _ | ⟨_, _ | _⟩ <;> simp [checkValue])
  | .int _, t | .bool _, t | .float .., t => by cases t <;> first | rfl | simp [checkValue]
  | .ptr _, t => by cases t <;> first | rfl | simp [checkValue, hp]

/-! ## Typed store then load -/

theorem isSized_of_checkValue {mem : Memory} {v : Value} {t : Ty}
    (h : checkValue mem v t = .ok ()) : t.isSized = true := by
  cases t with
  | ptr p _ => simp only [Ty.isSized, Ty.layout]; split <;> rfl
  | tuple fs hd tl =>
    cases tl
    · rfl
    · cases v <;> simp [checkValue] at h
  | array e n => simp only [Ty.isSized, Ty.layout]; split <;> rfl
  | slice e => cases v <;> simp [checkValue] at h
  | traitObject _ => cases v <;> simp [checkValue] at h
  | _ => rfl

theorem ThinPointer.leDefined_refl (p : ThinPointer) : p.leDefined p = true := by
  rcases p with ⟨_, _ | _⟩ <;> simp [ThinPointer.leDefined]

theorem Pointer.leDefined_refl (p : Pointer) : p.leDefined p = true := by
  rcases p with ⟨t, _ | m⟩
  · simp [Pointer.leDefined, Option.leDefinedBy, ThinPointer.leDefined_refl]
  · cases m <;> simp [Pointer.leDefined, Option.leDefinedBy, PointerMeta.leDefined,
      ThinPointer.leDefined_refl]

theorem List.leDefinedBy_refl {α : Type} {r : α → α → Bool} (h : ∀ a, r a a = true) :
    ∀ l : List α, List.leDefinedBy r l l = true
  | [] => rfl
  | a :: l => by simp [List.leDefinedBy, h, List.leDefinedBy_refl h l]

mutual
theorem Value.leDefined_refl : (v : Value) → Value.leDefined v v = true
  | .int _ | .bool _ => by simp [Value.leDefined]
  | .float .. => by simp [Value.leDefined]
  | .ptr p => by simp [Value.leDefined, Pointer.leDefined_refl]
  | .tuple vs => by simp [Value.leDefined, Value.leDefinedList_refl vs]
  | .variant _ d => by simp [Value.leDefined, Value.leDefined_refl d]
  | .union d => by
    simp [Value.leDefined, List.leDefinedBy_refl bytesLeDefined_refl]

theorem Value.leDefinedList_refl : (vs : List Value) → Value.leDefined.leDefinedList vs vs = true
  | [] => by simp [Value.leDefined.leDefinedList]
  | v :: vs => by
    simp [Value.leDefined.leDefinedList, Value.leDefined_refl v, Value.leDefinedList_refl vs]
end

theorem store_load_eq (mem mem' : Memory) (p : ThinPointer) (t : Ty) (v : Value) (al : Align)
    (hwf : t.wf = true) (hc : checkValue mem v t = .ok ())
    (hs : typedStore mem p v t al = .ok mem') :
    typedLoad mem' p t al = .ok v := by
  have hsized := isSized_of_checkValue hc
  obtain ⟨bs, he, hd⟩ := decode_encode' mem t v hwf hsized hc
  have hlen := encode_length' t v bs hwf hsized he
  simp only [typedStore, he] at hs
  have ha := Memory.store_agree hs
  have hl := Memory.store_load_bytes hs
  have hc' : checkValue mem' v t = .ok () := by
    rw [← checkValue_congr (checkPtr_congr ha.dereferenceable ha.vtableSizeAlign)]; exact hc
  simp [typedLoad, Ty.size?_of_isSized hsized, ← hlen, hl, hd, hc']
  rfl

/-- A typed store followed by a typed load at the same type and pointer gives back the value
(an existential `leDefined` form chosen here, not MiniRust's: its spec has no such law; the
loaded value is in fact equal, see `store_load_eq`). -/
theorem store_load (mem mem' : Memory) (p : ThinPointer) (t : Ty) (v : Value) (al : Align)
    (hwf : t.wf = true) (hc : checkValue mem v t = .ok ())
    (hs : typedStore mem p v t al = .ok mem') :
    ∃ w, typedLoad mem' p t al = .ok w ∧ Value.leDefined w v = true :=
  ⟨v, store_load_eq mem mem' p t v al hwf hc hs, Value.leDefined_refl v⟩

end Ryo.Spec.Theorems
