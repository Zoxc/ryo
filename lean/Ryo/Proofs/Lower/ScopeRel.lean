/-
Ryo.Proofs.Lower.ScopeRel — R's scopes against the frame relation (M5a, aot.md §C1 "Locals",
"Escape/storage side data").

- `Hidden m0 A`: no live L0 allocation holds a byte with a provenance in `A`. For `A` the
  allocations of the locals not escaped in R this is the invariant that makes `ι` dropping
  them sound, and that lets an `Escape` map them (`MemInj.mono`'s `hfresh`). Stores of
  provenance-free bytes keep it (`Hidden.store_noprov`).
- `escape_rel`: an `Escape [off, off + size)` whose range holds private, semantically live
  L0 locals `as` (and no escaped object) maps them to the new R object: `MemInj` holds for
  `ι` extended by `as ↦ id`, where the new object is at `fp + off`.
- `storageEnd_rel`: an `End [off, off + size)` keeps `MemInj` when every L0 allocation mapped
  to an object it frees is dead and no live mapped L0 allocation meets the range.
-/
import Ryo.Proofs.Lower.FrameRel

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem
open Ryo.Check.Lower (LocalSlot)

/-- No live allocation of `m0` holds a byte whose provenance satisfies `A`. -/
def Hidden (m0 : Memory) (A : AllocId → Prop) : Prop :=
  ∀ a x, m0.get? a = some x → x.live = true → ∀ i (h : i < x.data.size) f,
    x.data[i].provFrag = some f → ¬ A f.prov

/-- The written array of a store of provenance-free bytes keeps the old array's property. -/
private theorem hid_arr {A : AllocId → Prop} {d arr : Array AbstractByte}
    {bs : List AbstractByte} {o : Nat}
    (hold : ∀ i (h : i < d.size) f, d[i].provFrag = some f → ¬ A f.prov)
    (hbs : ∀ b ∈ bs, b.provFrag = none)
    (hg : ∀ j, arr[j]? = if o + 0 ≤ j ∧ j < o + 0 + bs.length ∧ j < d.size then
      bs[j - o - 0]? else d[j]?) :
    ∀ i (h : i < arr.size) f, arr[i].provFrag = some f → ¬ A f.prov := by
  intro i hi f hf
  have e := hg i
  rw [Array.getElem?_eq_getElem hi] at e
  split at e
  · rename_i c
    have hk : i - o - 0 < bs.length := by omega
    rw [List.getElem?_eq_getElem hk] at e
    rw [Option.some.inj e, hbs _ (List.getElem_mem hk)] at hf
    cases hf
  · obtain ⟨hi', he⟩ := Array.getElem?_eq_some_iff.mp e.symm
    rw [← he] at hf
    exact hold i hi' f hf

/-- A store of bytes without provenance keeps `Hidden`. -/
theorem Hidden.store_noprov {m0 m0' : Memory} {A : AllocId → Prop} (hh : Hidden m0 A)
    {p : ThinPointer} {bs : List AbstractByte} {al : Align} (h : m0.store p bs al = .ok m0')
    (hbs : ∀ b ∈ bs, b.provFrag = none) : Hidden m0' A := by
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h with
    ⟨_, _, rfl⟩ | ⟨k, hid, _, _, _, _, _, _, _, rfl⟩
  · exact hh
  · intro a x hx hlv
    by_cases hak : a = k
    · subst hak
      simp only [Memory.get?, Array.getElem?_set_self, Option.some.injEq] at hx
      subst hx
      exact hid_arr (hh a _ (Array.getElem?_eq_getElem hid) hlv) hbs
        (Ryo.Spec.Theorems.foldl_set_getElem bs 0 (p.addr - m0.allocs[a].addr)
          m0.allocs[a].data)
    · simp only [Memory.get?] at hx
      rw [Array.getElem?_set_ne hid (Ne.symm hak)] at hx
      exact hh a x hx hlv

theorem Hidden.mono {m0 : Memory} {A B : AllocId → Prop} (h : Hidden m0 A)
    (hb : ∀ a, B a → A a) : Hidden m0 B :=
  fun a x hx hl i hi f hf hB => h a x hx hl i hi f hf (hb _ hB)

theorem Hidden.dealloc {m0 m0' : Memory} {A} (h : Hidden m0 A) {p k n al}
    (hd : m0.deallocate p k n al = .ok m0') : Hidden m0' A := by
  obtain ⟨id, a0, hg, rfl⟩ := dealloc_ok_aux hd
  have hid : id < m0.allocs.size := by
    unfold Memory.get? at hg
    exact (Array.getElem?_eq_some_iff.mp hg).1
  intro c x hx hl i hi f hf
  unfold Memory.get? at hx
  simp only [Array.set!, Array.getElem?_setIfInBounds] at hx
  by_cases hc : id = c
  · subst hc
    simp [hid] at hx
    first
      | (subst hx; simp at hl)
      | (rw [← hx] at hl; simp at hl)
      | (rw [hx] at hl; simp at hl)
  · rw [if_neg hc] at hx
    exact h c x hx hl i hi f hf

/-- `ι` with the allocations `as` mapped to `id`. -/
def Inj.extend (ι : Inj) (as : List AllocId) (id : AllocId) : Inj :=
  fun q => if q ∈ as then some id else ι q

theorem escape_extend_mem {ι : Inj} {as : List AllocId} {n q : AllocId} (h : q ∈ as) :
    ι.extend as n q = some n := by
  show (if q ∈ as then some n else ι q) = some n
  rw [if_pos h]

theorem escape_extend_not_mem {ι : Inj} {as : List AllocId} {n q : AllocId} (h : q ∉ as) :
    ι.extend as n q = ι q := by
  show (if q ∈ as then some n else ι q) = ι q
  rw [if_neg h]

/-- A successful `escape` whose start is private and whose size isn't zero pushes the new
object (`Scope.escape_ok`'s second case, with `mutable`). -/
theorem escape_ok_new {s s' : R.RState} {off : Int} {size align : Nat}
    (h : R.escape s off size align = .ok s') (hpriv : s.st.escapedAt off = none)
    (hsize : size ≠ 0) :
    ∃ (bytes : List AbstractByte) (a : Allocation),
      s' = { s with st := { s.st with
        mem := ({ allocs := s.st.mem.allocs.push a } : Memory),
        escaped := s.st.escaped ++
          [({ off := off, size := size, id := s.st.mem.allocs.size } : OpSem.EscapedObj)],
        exposed := s.st.exposed ++ [s.st.mem.allocs.size] } } ∧
      0 ≤ (s.fp : Int) + off ∧ a.addr = ((s.fp : Int) + off).toNat ∧ a.data = bytes.toArray ∧
      a.live = true ∧ a.mutable = true ∧ s.st.readFrame off size = .ok bytes := by
  unfold R.escape at h
  simp only at h
  split at h
  · rename_i hc
    exfalso
    simp only [List.any_eq_true, decide_eq_true_eq] at hc
    obtain ⟨e, he, h1, h2⟩ := hc
    unfold OpSem.State.escapedAt at hpriv
    have hn := List.find?_eq_none.1 hpriv e he
    apply hn
    simp only [decide_eq_true_eq]
    exact ⟨h1, by omega⟩
  split at h
  · cases h
  unfold R.frameAddr at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  rename_i hnn
  split at hnn
  · cases hnn
  rename_i hge
  simp only [pure, Except.pure, Except.ok.injEq] at hnn
  subst hnn
  simp only [pure, Except.pure] at h
  split at h
  · cases h
  split at h
  · cases h
  cases hr : s.st.readFrame off size with
  | error e => simp [hr] at h
  | ok bytes =>
    simp only [hr, Except.ok.injEq] at h
    subst h
    exact ⟨bytes, _, rfl, by omega, rfl, rfl, rfl, rfl, rfl⟩

/-- An `Escape` of private, semantically live locals (see the module comment). -/
theorem escape_rel {ι : Inj} {m0 : Memory} {s1 s1' : R.RState} {off : Int} {size align : Nat}
    (h : R.escape s1 off size align = .ok s1') (hm : MemInj ι m0 s1.st.mem)
    (hnone : ∀ k < size, s1.st.escapedAt (off + k) = none) (hsize : size ≠ 0)
    (as : List AllocId)
    (has : ∀ a ∈ as, ι a = none ∧ ∃ x, m0.get? a = some x ∧ x.live = true ∧
      (x.addr : Int) ≥ s1.fp + off ∧
      (x.addr : Int) + x.data.size ≤ s1.fp + off + size ∧
      ∀ k (hk : k < x.data.size),
        ByteInj (ι.extend as s1.st.mem.allocs.size) x.data[k]
          (s1.st.frame ((x.addr : Int) - s1.fp + k)))
    (hhid : Hidden m0 (· ∈ as)) :
    let id := s1.st.mem.allocs.size
    MemInj (ι.extend as id) m0 s1'.st.mem ∧
      s1'.st.escaped = s1.st.escaped ++ [⟨off, size, id⟩] ∧
      ∃ y, s1'.st.mem.get? id = some y ∧ y.live = true ∧ (y.addr : Int) = s1.fp + off ∧
        y.data.size = size ∧ s1'.st.frame = s1.st.frame ∧ s1'.fp = s1.fp := by
  obtain ⟨bytes, a, rfl, hge, haddr, hdata, hlive, hmut, hread⟩ :=
    escape_ok_new h (by
      have h0 := hnone 0 (Nat.pos_of_ne_zero hsize)
      have e : off + ((0 : Nat) : Int) = off := by omega
      rwa [e] at h0) hsize
  have hA : (a.addr : Int) = s1.fp + off := by
    rw [haddr]
    first
      | exact Int.toNat_of_nonneg hge
      | omega
  have hread' : s1.st.readFrame off size =
      .ok ((List.range size).map fun i : Nat => s1.st.frame (off + i)) :=
    readFrame_eq_map fun i hi => by
      unfold OpSem.State.byteAt
      rw [hnone i hi]
      all_goals rfl
  have hb : bytes = (List.range size).map fun i : Nat => s1.st.frame (off + i) :=
    Except.ok.inj (hread.symm.trans hread')
  have hasz : a.data.size = size := by
    rw [hdata, hb]
    simp
  have hda : ∀ j (hj : j < a.data.size), a.data[j] = s1.st.frame (off + j) := by
    intro j hj
    have hj' : j < size := by omega
    have e : a.data[j]? = some (s1.st.frame (off + j)) := by
      rw [hdata, hb]
      simp [hj']
    rw [Array.getElem?_eq_getElem hj] at e
    exact Option.some.inj e
  have hle : ι.Le (ι.extend as s1.st.mem.allocs.size) := by
    intro q c hq
    by_cases hqa : q ∈ as
    · rw [(has q hqa).1] at hq
      cases hq
    · rw [escape_extend_not_mem hqa]
      exact hq
  refine ⟨?_, rfl, a, ?_, hlive, hA, hasz, rfl, rfl⟩
  · show MemInj (ι.extend as s1.st.mem.allocs.size) m0
      ({ allocs := s1.st.mem.allocs.push a } : Memory)
    intro a0 b x hx hb0
    by_cases ha : a0 ∈ as
    · -- A local of the range: in the new object, at the same addresses.
      obtain ⟨-, x', hx', -, hlo, hhi, hbytes⟩ := has a0 ha
      have hxx : x' = x := Option.some.inj (hx'.symm.trans hx)
      rw [escape_extend_mem ha] at hb0
      have hbN : b = s1.st.mem.allocs.size := (Option.some.inj hb0).symm
      subst hbN
      rw [← hxx]
      refine ⟨a, by simp [Memory.get?], ?_⟩
      exact
        { lo := by omega
          hi := by
            show x'.addr + x'.data.size ≤ a.addr + a.data.size
            rw [hasz]
            omega
          live := fun _ => hlive
          mutable := fun _ => hmut
          bytes := fun _ i h0 h1 => by
            have e : off + ((x'.addr - a.addr + i : Nat) : Int) =
                (x'.addr : Int) - s1.fp + (i : Int) := by
              omega
            rw [hda _ h1, e]
            exact hbytes i h0 }
    · -- Any other: its R allocation is an old one, and its bytes' provenance isn't in `as`.
      rw [escape_extend_not_mem ha] at hb0
      obtain ⟨y, hy, hxy⟩ := hm a0 b x hx hb0
      obtain ⟨hlt, -⟩ := Array.getElem?_eq_some_iff.1 hy
      have hne : b ≠ s1.st.mem.allocs.size := Nat.ne_of_lt hlt
      refine ⟨y, by simpa [Memory.get?, Array.getElem?_push, hne] using hy, ?_⟩
      exact
        { lo := hxy.lo, hi := hxy.hi, live := hxy.live, mutable := hxy.mutable
          bytes := fun hl i h0 h1 => ByteInj.mono hle (hxy.bytes hl i h0 h1)
            (fun f hf hn => (escape_extend_not_mem (ι := ι) (n := s1.st.mem.allocs.size)
              (hhid a0 x hx hl i h0 f hf)).trans hn) }
  · show ({ allocs := s1.st.mem.allocs.push a } : Memory).get? s1.st.mem.allocs.size = some a
    simp [Memory.get?]

/-! ### `End` helpers -/

/-- A copy of `Ryo.Proofs.Scope.storageEnd_ok` (not imported here). -/
theorem end_storageEnd_ok {s s' : R.RState} {off : Int} {size : Nat}
    (h : R.storageEnd s off size = .ok s') :
    ∃ st', ({ s.st with
        mem := R.freeObjs s.st.mem
          (s.st.escaped.filter fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)),
        escaped := s.st.escaped.filter
          (not ∘ fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) } : OpSem.State).writeFrame
        off (List.replicate size .uninit) = .ok st' ∧ s' = { s with st := st' } := by
  unfold R.storageEnd at h
  simp only [List.partition_eq_filter_filter, bind, Except.bind] at h
  split at h
  · cases h
  rename_i st' hw
  simp only [pure, Except.pure, Except.ok.injEq] at h
  exact ⟨st', hw, h.symm⟩

/-- A copy of `Ryo.Proofs.Inline.escapedAt_some` (not imported here). -/
theorem end_escapedAt_some {st : OpSem.State} {o : Int} {e : EscapedObj}
    (h : st.escapedAt o = some e) : e ∈ st.escaped ∧ e.off ≤ o ∧ o < e.off + e.size := by
  unfold OpSem.State.escapedAt at h
  have h1 := List.mem_of_find?_eq_some h
  have h2 := List.find?_some h
  simp only [decide_eq_true_eq] at h2
  exact ⟨h1, h2⟩

/-- `get?` after replacing an existing allocation. -/
theorem end_get?_set {m : Memory} {id : AllocId} {a : Allocation} (a' : Allocation)
    (ha : m.get? id = some a) (c : AllocId) :
    ({ allocs := m.allocs.set! id a' } : Memory).get? c = if c = id then some a' else m.get? c := by
  have hid : id < m.allocs.size :=
    (Array.getElem?_eq_some_iff.1 (show m.allocs[id]? = some a from ha)).1
  show (m.allocs.setIfInBounds id a')[c]? = _
  rw [Array.getElem?_setIfInBounds]
  by_cases hc : c = id
  · subst hc
    simp [hid]
  · rw [if_neg (Ne.symm hc), if_neg hc, Memory.get?]

/-- Replacing R's allocation `id` by `a'` at the same address keeps `MemInj` when it keeps
`AllocInj` for the L0 allocations mapped to `id`; every allocation keeps its address. -/
theorem end_set_rel {ι : Inj} {m0 m : Memory} {id : AllocId} {a a' : Allocation}
    (hm : MemInj ι m0 m) (ha : m.get? id = some a) (haddr : a'.addr = a.addr)
    (hstep : ∀ c x, ι c = some id → m0.get? c = some x → AllocInj ι x a → AllocInj ι x a') :
    MemInj ι m0 { allocs := m.allocs.set! id a' } ∧
      ∀ c y, ({ allocs := m.allocs.set! id a' } : Memory).get? c = some y →
        ∃ y0, m.get? c = some y0 ∧ y0.addr = y.addr := by
  refine ⟨?_, ?_⟩
  · intro c b x hx hb
    obtain ⟨y, hy, hxy⟩ := hm c b x hx hb
    rw [end_get?_set a' ha]
    by_cases hbi : b = id
    · rw [if_pos hbi]
      rw [hbi] at hy
      have e : y = a := Option.some.inj (hy.symm.trans ha)
      exact ⟨a', rfl, hstep c x (by rw [← hbi]; exact hb) hx (by rw [← e]; exact hxy)⟩
    · rw [if_neg hbi]
      exact ⟨y, hy, hxy⟩
  · intro c y hy
    rw [end_get?_set a' ha] at hy
    by_cases hci : c = id
    · rw [if_pos hci] at hy
      cases hy
      exact ⟨a, by rw [hci]; exact ha, haddr.symm⟩
    · rw [if_neg hci] at hy
      exact ⟨y, hy, rfl⟩

/-- `freeObjs`'s step. -/
def end_kill (m : Memory) (id : AllocId) : Memory :=
  match m.get? id with
  | some a => ⟨m.allocs.set! id { a with live := false }⟩
  | none => m

theorem end_freeObjs_cons (m : Memory) (e : EscapedObj) (es : List EscapedObj) :
    R.freeObjs m (e :: es) = R.freeObjs (end_kill m e.id) es := rfl

/-- Killing R's allocation `id` keeps `MemInj` when every L0 allocation mapped to it is dead. -/
theorem end_kill_rel {ι : Inj} {m0 m : Memory} {id : AllocId} (hm : MemInj ι m0 m)
    (hd : ∀ c x, ι c = some id → m0.get? c = some x → x.live = false) :
    MemInj ι m0 (end_kill m id) ∧
      ∀ c y, (end_kill m id).get? c = some y → ∃ y0, m.get? c = some y0 ∧ y0.addr = y.addr := by
  cases ha : m.get? id with
  | none =>
    have e : end_kill m id = m := by simp only [end_kill, ha]
    rw [e]
    exact ⟨hm, fun _ y hy => ⟨y, hy, rfl⟩⟩
  | some a =>
    have e : end_kill m id = ⟨m.allocs.set! id { a with live := false }⟩ := by
      simp only [end_kill, ha]
    rw [e]
    exact end_set_rel (a' := { a with live := false }) hm ha rfl (fun c x hb hx hxy =>
      { lo := hxy.lo, hi := hxy.hi
        live := fun hl => by rw [hd c x hb hx] at hl; cases hl
        mutable := hxy.mutable
        bytes := fun hl => by rw [hd c x hb hx] at hl; cases hl })

/-- `freeObjs` keeps `MemInj` when the L0 allocations mapped to the freed objects are dead;
every allocation keeps its address. -/
theorem end_freeObjs_rel {ι : Inj} {m0 : Memory} : ∀ (es : List EscapedObj) (m : Memory),
    MemInj ι m0 m →
    (∀ c b x e, ι c = some b → m0.get? c = some x → e ∈ es → e.id = b → x.live = false) →
    MemInj ι m0 (R.freeObjs m es) ∧
      ∀ c y, (R.freeObjs m es).get? c = some y → ∃ y0, m.get? c = some y0 ∧ y0.addr = y.addr
  | [], _, hm, _ => ⟨hm, fun _ y hy => ⟨y, hy, rfl⟩⟩
  | e :: es, m, hm, hd => by
    rw [end_freeObjs_cons]
    have hk := end_kill_rel (id := e.id) hm
      (fun c x hb hx => hd c e.id x e hb hx (List.mem_cons_self ..) rfl)
    obtain ⟨h1, h2⟩ := end_freeObjs_rel es (end_kill m e.id) hk.1
      (fun c b x e' hb hx he hid => hd c b x e' hb hx (List.mem_cons_of_mem _ he) hid)
    refine ⟨h1, fun c y hy => ?_⟩
    obtain ⟨y1, hy1, e1⟩ := h2 c y hy
    obtain ⟨y0, hy0, e0⟩ := hk.2 c y1 hy1
    exact ⟨y0, hy0, e0.trans e1⟩

/-- Setting byte `j` of R's allocation, outside the live `x`, keeps `AllocInj`. -/
theorem end_allocInj_set {ι : Inj} {x a : Allocation} {j : Nat} {b : AbstractByte}
    (hxy : AllocInj ι x a)
    (hd : x.live = true → a.addr + j < x.addr ∨ x.addr + x.data.size ≤ a.addr + j) :
    AllocInj ι x { a with data := a.data.set! j b } := by
  have hlo : a.addr ≤ x.addr := hxy.lo
  refine ⟨hxy.lo, ?_, hxy.live, hxy.mutable, ?_⟩
  · show x.addr + x.data.size ≤ a.addr + (a.data.set! j b).size
    rw [Array.set!_eq_setIfInBounds, Array.size_setIfInBounds]
    exact hxy.hi
  · intro hl i h0 h1
    dsimp only at h1 ⊢
    have h1' : x.addr - a.addr + i < a.data.size := by simpa using h1
    have hne : j ≠ x.addr - a.addr + i := by
      have := hd hl
      omega
    have e1 : (a.data.set! j b)[x.addr - a.addr + i]? = a.data[x.addr - a.addr + i]? := by
      rw [Array.set!_eq_setIfInBounds, Array.getElem?_setIfInBounds_ne hne]
    have e := (Array.getElem?_eq_getElem h1).symm.trans (e1.trans (Array.getElem?_eq_getElem h1'))
    rw [Option.some.inj e]
    exact hxy.bytes hl i h0 h1'

/-- A copy of `Ryo.Proofs.Inline.escStep`: the step of `writeEscaped`'s fold. -/
def end_escStep (st : OpSem.State) (off : Int) (mem : Memory) (p : AbstractByte × Nat) :
    OpSem.M Memory :=
  match st.escapedAt (off + p.2) with
  | none => pure mem
  | some e =>
    match mem.get? e.id with
    | none => illFormed s!"escaped frame object at {e.off} has no allocation"
    | some a =>
      let a' := { a with data := a.data.set! (off + p.2 - e.off).toNat p.1 }
      pure { allocs := mem.allocs.set! e.id a' }

/-- One escaped write, at an address outside every live L0 allocation mapped to the written
object, keeps `MemInj`; every allocation keeps its address. -/
theorem end_escStep_rel {ι : Inj} {m0 : Memory} {st : OpSem.State} {off : Int} {m m' : Memory}
    {p : AbstractByte × Nat} (h : end_escStep st off m p = .ok m') (hm : MemInj ι m0 m)
    (hd : ∀ e a, st.escapedAt (off + p.2) = some e → m.get? e.id = some a →
      ∀ c x, ι c = some e.id → m0.get? c = some x → x.live = true →
        a.addr + (off + p.2 - e.off).toNat < x.addr ∨
          x.addr + x.data.size ≤ a.addr + (off + p.2 - e.off).toNat) :
    MemInj ι m0 m' ∧ ∀ c y, m'.get? c = some y → ∃ y0, m.get? c = some y0 ∧ y0.addr = y.addr := by
  unfold end_escStep at h
  split at h
  · cases h
    exact ⟨hm, fun _ y hy => ⟨y, hy, rfl⟩⟩
  · rename_i e he
    split at h
    · cases h
    · rename_i a ha
      cases h
      exact end_set_rel (a' := { a with data := a.data.set! (off + p.2 - e.off).toNat p.1 })
        hm ha rfl (fun c x hb hx hxy => end_allocInj_set hxy (fun hl => hd e a he ha c x hb hx hl))

/-- `writeEscaped`'s fold keeps `MemInj` when each write misses the live L0 allocations mapped
to its object (addresses as in `M0`). -/
theorem end_foldlM_rel {ι : Inj} {m0 M0 : Memory} {st : OpSem.State} {off : Int} :
    ∀ (l : List (AbstractByte × Nat)),
      (∀ p ∈ l, ∀ e a, st.escapedAt (off + p.2) = some e → M0.get? e.id = some a →
        ∀ c x, ι c = some e.id → m0.get? c = some x → x.live = true →
          a.addr + (off + p.2 - e.off).toNat < x.addr ∨
            x.addr + x.data.size ≤ a.addr + (off + p.2 - e.off).toNat) →
      ∀ (m m' : Memory), l.foldlM (end_escStep st off) m = .ok m' → MemInj ι m0 m →
        (∀ c y, m.get? c = some y → ∃ y0, M0.get? c = some y0 ∧ y0.addr = y.addr) →
        MemInj ι m0 m' := by
  intro l
  induction l with
  | nil =>
    intro _ m m' h hm _
    cases h
    exact hm
  | cons p l ih =>
    intro hd m m' h hm hA
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : end_escStep st off m p with
    | error e => simp [h1] at h
    | ok m1 =>
      simp only [h1] at h
      obtain ⟨hm1, hA1⟩ := end_escStep_rel h1 hm (fun e a he ha c x hb hx hl => by
        obtain ⟨y0, hy0, hy0a⟩ := hA e.id a ha
        rw [← hy0a]
        exact hd p (List.mem_cons_self ..) e y0 he hy0 c x hb hx hl)
      exact ih (fun q hq => hd q (List.mem_cons_of_mem _ hq)) m1 m' h hm1 (fun c y hy => by
        obtain ⟨y1, hy1, e1⟩ := hA1 c y hy
        obtain ⟨y0, hy0, e0⟩ := hA c y1 hy1
        exact ⟨y0, hy0, e0.trans e1⟩)

/-- An `End` (see the module comment). -/
theorem storageEnd_rel {ι : Inj} {m0 : Memory} {s1 s1' : R.RState} {off : Int} {size : Nat}
    (h : R.storageEnd s1 off size = .ok s1') (hm : MemInj ι m0 s1.st.mem)
    (hgone : ∀ a b x e, ι a = some b → m0.get? a = some x → e ∈ s1.st.escaped → e.id = b →
      off ≤ e.off → e.off + e.size ≤ off + size → x.live = false)
    (hapart : ∀ a b x y e, ι a = some b → m0.get? a = some x → x.live = true →
      s1.st.mem.get? b = some y → e ∈ s1.st.escaped → e.id = b →
      (x.addr : Int) + x.data.size ≤ s1.fp + off ∨ s1.fp + off + size ≤ x.addr)
    (hat : ∀ e y, e ∈ s1.st.escaped → s1.st.mem.get? e.id = some y → (y.addr : Int) = s1.fp + e.off) :
    MemInj ι m0 s1'.st.mem := by
  obtain ⟨st', hw, rfl⟩ := end_storageEnd_ok h
  generalize hcov : (fun e : EscapedObj => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) = cov at hw
  generalize hst1 : ({ s1.st with
        mem := R.freeObjs s1.st.mem (s1.st.escaped.filter cov),
        escaped := s1.st.escaped.filter (not ∘ cov) } : OpSem.State) = st1 at hw
  have hmem1 : st1.mem = R.freeObjs s1.st.mem (s1.st.escaped.filter cov) := by
    subst hst1; rfl
  have hesc1 : st1.escaped = s1.st.escaped.filter (not ∘ cov) := by
    subst hst1; rfl
  have hcov' : ∀ e, cov e = true → off ≤ e.off ∧ e.off + e.size ≤ off + size := by
    intro e he
    subst hcov
    simpa using he
  -- (1) `freeObjs`: the L0 allocations mapped to a freed object are dead.
  obtain ⟨hm1, hA1⟩ := end_freeObjs_rel (ι := ι) (m0 := m0) (s1.st.escaped.filter cov)
    s1.st.mem hm (fun c b x e hb hx he hid => by
      obtain ⟨he0, hc⟩ := List.mem_filter.1 he
      obtain ⟨hc1, hc2⟩ := hcov' e hc
      exact hgone c b x e hb hx he0 hid hc1 hc2)
  -- (2) the `Uninit` write: its escaped bytes miss every live mapped L0 allocation.
  unfold OpSem.State.writeFrame at hw
  cases hwe : st1.writeEscaped off (List.replicate size .uninit) with
  | error e => simp [hwe, bind, Except.bind] at hw
  | ok m' =>
    simp only [hwe, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
    subst hw
    show MemInj ι m0 m'
    refine end_foldlM_rel (M0 := s1.st.mem) (st := st1) (off := off) (List.replicate size AbstractByte.uninit).zipIdx
      ?_ st1.mem m' hwe (by rw [hmem1]; exact hm1)
      (fun c y hy => hA1 c y (by rw [← hmem1]; exact hy))
    intro p hp e a he ha c x hb hx hl
    have hp2 : p.2 < size := by
      obtain ⟨hlt, -⟩ := List.getElem?_eq_some_iff.1 (List.mem_zipIdx_iff_getElem?.1 hp)
      simpa using hlt
    obtain ⟨he0, h1, -⟩ := end_escapedAt_some he
    have he1 : e ∈ s1.st.escaped := by
      rw [hesc1] at he0
      exact (List.mem_filter.1 he0).1
    have haddr := hat e a he1 ha
    obtain ⟨y, hy, -⟩ := hm c e.id x hx hb
    have hap := hapart c e.id x y e hb hx hl hy he1 rfl
    omega

end Ryo.Proofs.Lower
