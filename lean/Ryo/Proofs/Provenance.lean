/-
Ryo.Proofs.Provenance — extra provenance never adds UB in R (reduced.md §C0.3, "Resolution").

R keeps provenance where Rust drops it: `expose_provenance` and ptr↔int transmutes lower to
moves, so the slot keeps the pointer's bytes; the JIT's LVN identities (`x + 0 → x`,
`x & -1 → x`, `x | 0 → x`, a same-width extension) return the pointer where R's result was an
integer. L0, as MiniRust, resolves a provenance-less pointer at the int→ptr cast (an angelic
choice among the exposed allocations). R resolves at the access (`Ryo.Vm.OpSem.State.resolve`): the
pointer's own provenance if its live allocation contains the range, else the exposed live
allocation that does. With that fallback:

- `resolve_mono`: an access through `p` resolves as one through `q` whenever `q` is `p`'s
  address with no provenance, `p`'s, or an exposed one (`ProvLe`), and `q`'s access is
  defined; so `load_mono`, `store_mono`, `checkDeref_mono` (same result).
- `decodePtr_mono`, `decodeBits_mono`: bytes with more provenance (`bytesLeDefined`) decode to
  the same integer and to a pointer with at least the provenance.
- `intBytes_le`: an integer result equal to its operand's value (the LVN identities) is
  `≤def` the operand's bytes; `lvn_add_zero`, `lvn_and_ones`, `lvn_or_zero`.
- `drop_exposed_mono`, `drop_exposed_store`: the converse for an exposed provenance: the bare
  address accesses what the pointer does (folding a pointer to an integer constant).
- `use_mono`: put together, reading a pointer from `q`'s bytes and accessing through it
  succeeds with the same result from bytes `≤def`-above them.

The memory hypothesis is `LiveDisjoint` (live allocations don't overlap), which `escape`
keeps (`escape_liveDisjoint`); the image world and environment answers must too.
-/
import Ryo.Vm.R.Sem
import Ryo.Spec.Theorems.Bytes
import Ryo.Proofs.Inline.Mem

namespace Ryo.Proofs.Provenance

open Ryo.Spec Ryo.Spec.Theorems Ryo.Vm.OpSem Ryo.Proofs.Inline

/-- Live allocations don't share a byte. -/
def LiveDisjoint (m : Memory) : Prop :=
  ∀ i j (a b : Allocation) (x : Nat), m.get? i = some a → m.get? j = some b → a.live = true →
    b.live = true → a.addr ≤ x → x < a.addr + a.size → b.addr ≤ x → x < b.addr + b.size → i = j

/-- R's pointer `p` may stand for `q`: same address, and `q` without provenance, with `p`'s,
or with an exposed one (L0's choice at an int→ptr cast, or a provenance R dropped). -/
def ProvLe (exposed : List AllocId) (q p : ThinPointer) : Prop :=
  q.addr = p.addr ∧ (q.prov = none ∨ q.prov = p.prov ∨ ∃ id, q.prov = some id ∧ id ∈ exposed)

theorem provLe_refl (ex : List AllocId) (p : ThinPointer) : ProvLe ex p p :=
  ⟨rfl, Or.inr (Or.inl rfl)⟩

theorem provLe_of_leDefined {ex : List AllocId} {q p : ThinPointer}
    (h : q.leDefined p = true) : ProvLe ex q p := by
  unfold ThinPointer.leDefined at h
  simp only [Bool.and_eq_true, beq_iff_eq] at h
  obtain ⟨ha, hp⟩ := h
  refine ⟨ha, ?_⟩
  revert hp
  cases q.prov <;> cases p.prov <;> simp_all

theorem stFits_iff {st : Ryo.Vm.OpSem.State} {addr len : Nat} {id : AllocId} :
    st.fits addr len id = true ↔ ∃ a, st.mem.get? id = some a ∧ a.live = true ∧ a.addr ≤ addr ∧
      addr + len ≤ a.addr + a.size := by
  unfold State.fits
  cases st.mem.get? id <;> simp [and_assoc]

theorem fits_unique {st : Ryo.Vm.OpSem.State} {addr len : Nat} {i j : AllocId} (hd : LiveDisjoint st.mem)
    (hn : len ≠ 0) (hi : st.fits addr len i = true) (hj : st.fits addr len j = true) : i = j := by
  obtain ⟨a, ha, hla, h1, h2⟩ := stFits_iff.1 hi
  obtain ⟨b, hb, hlb, h3, h4⟩ := stFits_iff.1 hj
  exact hd i j a b addr ha hb hla hlb h1 (by omega) h3 (by omega)

theorem resolveExposed_of_fits {st : Ryo.Vm.OpSem.State} {p : ThinPointer} {len : Nat} {id : AllocId}
    (hd : LiveDisjoint st.mem) (hn : len ≠ 0) (hf : st.fits p.addr len id = true)
    (he : id ∈ st.exposed) : st.resolveExposed p len = { p with prov := some id } := by
  unfold State.resolveExposed
  cases h : st.exposed.find? (st.fits p.addr len) with
  | none => exact absurd hf (by simpa using List.find?_eq_none.1 h id he)
  | some j =>
    have := fits_unique hd hn (List.find?_some h) hf
    simp [this]

/-- Where an allocation contains the range and is the pointer's or exposed, the access resolves
to it. -/
theorem resolve_of_fits {st : Ryo.Vm.OpSem.State} {p : ThinPointer} {len : Nat} {id : AllocId}
    (hd : LiveDisjoint st.mem) (hn : len ≠ 0) (hf : st.fits p.addr len id = true)
    (h : p.prov = some id ∨ id ∈ st.exposed) : st.resolve p len = { p with prov := some id } := by
  unfold State.resolve
  cases hp : p.prov with
  | none =>
    simp only
    rcases h with h | h
    · simp [hp] at h
    · exact resolveExposed_of_fits hd hn hf h
  | some j =>
    simp only
    split
    · rename_i hj
      have := fits_unique hd hn hj hf
      subst this
      cases p; simp_all
    · rename_i hj
      rcases h with h | h
      · rw [hp] at h; cases h; simp_all
      · exact resolveExposed_of_fits hd hn hf h

theorem resolveExposed_cases (st : Ryo.Vm.OpSem.State) (p : ThinPointer) (len : Nat) :
    st.resolveExposed p len = p ∨ ∃ id, id ∈ st.exposed ∧ st.fits p.addr len id = true ∧
      st.resolveExposed p len = { p with prov := some id } := by
  unfold State.resolveExposed
  cases h : st.exposed.find? (st.fits p.addr len) with
  | none => exact Or.inl rfl
  | some j => exact Or.inr ⟨j, List.mem_of_find?_eq_some h, List.find?_some h, rfl⟩

theorem checkPtr_ok_prov {m : Memory} {p : ThinPointer} {len : Nat} {r : Option (AllocId × Nat)}
    (hn : len ≠ 0) (h : m.checkPtr p len = .ok r) :
    ∃ id a, p.prov = some id ∧ m.get? id = some a ∧ a.live = true ∧ a.addr ≤ p.addr ∧
      p.addr + len ≤ a.addr + a.size := by
  unfold Memory.checkPtr at h
  simp only [beq_iff_eq, hn, ↓reduceIte] at h
  rcases hp : p.prov with _ | id <;> simp only [hp] at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  rcases ha : m.get? id with _ | a <;> simp only [ha] at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  by_cases hl : a.live = true <;>
    by_cases hb : p.addr < a.addr ∨ p.addr + len > a.addr + a.size <;>
    simp_all [throwUb, throwThe, MonadExceptOf.throw, bind, Except.bind, pure, Except.pure]

/-- A defined non-empty access resolved to an allocation that contains the range and is the
pointer's or exposed. -/
theorem resolve_fits {st : Ryo.Vm.OpSem.State} {q : ThinPointer} {len : Nat} {r : Option (AllocId × Nat)}
    (hn : len ≠ 0) (h : st.mem.checkPtr (st.resolve q len) len = .ok r) :
    ∃ id, st.resolve q len = { q with prov := some id } ∧ st.fits q.addr len id = true ∧
      (q.prov = some id ∨ id ∈ st.exposed) := by
  obtain ⟨id, a, hp, ha, hl, h1, h2⟩ := checkPtr_ok_prov hn h
  have hra := resolve_addr st q len
  have hfit : st.fits q.addr len id = true := stFits_iff.2 ⟨a, ha, hl, by omega, by omega⟩
  refine ⟨id, ?_, hfit, ?_⟩
  · cases hr : st.resolve q len
    rw [hr] at hp hra
    simp_all
  · revert hp
    unfold State.resolve
    cases hq : q.prov with
    | some j =>
      simp only
      split
      · intro h; exact Or.inl (hq ▸ h)
      · rename_i hj
        rcases resolveExposed_cases st q len with he | ⟨k, hk, -, he⟩
        · rw [he, hq]; intro h; cases h; exact absurd hfit hj
        · rw [he]; intro h; cases h; exact Or.inr hk
    | none =>
      simp only
      rcases resolveExposed_cases st q len with he | ⟨k, hk, -, he⟩
      · rw [he, hq]; intro h; cases h
      · rw [he]; intro h; cases h; exact Or.inr hk

/-- **Extra provenance never adds UB**: where an access through `q` is defined, one through
`p` (`ProvLe`: same address, more provenance) resolves to the same pointer. -/
theorem resolve_mono {st : Ryo.Vm.OpSem.State} {q p : ThinPointer} {len : Nat} {r : Option (AllocId × Nat)}
    (hd : LiveDisjoint st.mem) (hle : ProvLe st.exposed q p) (hn : len ≠ 0)
    (h : st.mem.checkPtr (st.resolve q len) len = .ok r) : st.resolve p len = st.resolve q len := by
  obtain ⟨id, hq, hf, ho⟩ := resolve_fits hn h
  obtain ⟨ha, hpv⟩ := hle
  rw [hq]
  have hf' : st.fits p.addr len id = true := ha ▸ hf
  have hsrc : p.prov = some id ∨ id ∈ st.exposed := by
    rcases ho with ho | ho
    · rcases hpv with h0 | h0 | ⟨k, hk, hke⟩
      · rw [ho] at h0; cases h0
      · exact Or.inl (h0 ▸ ho)
      · rw [ho] at hk; cases hk; exact Or.inr hke
    · exact Or.inr ho
  rw [resolve_of_fits hd hn hf' hsrc]
  cases p; cases q; simp_all

/-! ### Accesses -/

theorem checkPtr_zero (m : Memory) (p : ThinPointer) : m.checkPtr p 0 = .ok none := by
  simp [Memory.checkPtr, pure, Except.pure]

theorem load_zero_congr (m : Memory) {p p' : ThinPointer} (al : Align) (h : p.addr = p'.addr) :
    m.load p 0 al = m.load p' 0 al := by
  simp [Memory.load, checkPtr_zero, h]

theorem store_zero_congr (m : Memory) {p p' : ThinPointer} (bs : List AbstractByte) (al : Align)
    (hl : bs.length = 0) (h : p.addr = p'.addr) : m.store p bs al = m.store p' bs al := by
  simp [Memory.store, hl, checkPtr_zero, h]

theorem checkPtr_of_load {m : Memory} {p : ThinPointer} {n : Nat} {al : Align}
    {bs : List AbstractByte} (h : m.load p n al = .ok bs) : ∃ r, m.checkPtr p n = .ok r := by
  unfold Memory.load at h
  split at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  cases hc : m.checkPtr p n with
  | error e => simp [hc, bind, Except.bind] at h
  | ok r => exact ⟨r, rfl⟩

theorem checkPtr_of_store {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (h : m.store p bs al = .ok m') : ∃ r, m.checkPtr p bs.length = .ok r := by
  unfold Memory.store at h
  split at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  cases hc : m.checkPtr p bs.length with
  | error e => simp [hc, bind, Except.bind] at h
  | ok r => exact ⟨r, rfl⟩

/-- A load through `p` gives what one through `q` does, if that is defined. -/
theorem load_mono {st : Ryo.Vm.OpSem.State} {q p : ThinPointer} {n : Nat} {al : Align}
    {bs : List AbstractByte} (hd : LiveDisjoint st.mem) (hle : ProvLe st.exposed q p)
    (h : st.load q n al = .ok bs) : st.load p n al = .ok bs := by
  unfold State.load at h ⊢
  by_cases hn : n = 0
  · subst hn
    rw [load_zero_congr st.mem al (p' := st.resolve q 0)
      (by rw [resolve_addr, resolve_addr, hle.1])]
    exact h
  · rw [liftOutcome_ok] at h
    obtain ⟨r, hc⟩ := checkPtr_of_load h
    rw [resolve_mono hd hle hn hc]
    exact liftOutcome_ok.2 h

/-- A store through `p` does what one through `q` does, if that is defined. -/
theorem store_mono {st : Ryo.Vm.OpSem.State} {q p : ThinPointer} {bs : List AbstractByte}
    {al : Align} {mem' : Memory} (hd : LiveDisjoint st.mem) (hle : ProvLe st.exposed q p)
    (h : st.store st.mem q bs al = .ok mem') : st.store st.mem p bs al = .ok mem' := by
  unfold State.store at h ⊢
  by_cases hn : bs.length = 0
  · rw [store_zero_congr st.mem bs al hn (p' := st.resolve q bs.length)
      (by rw [resolve_addr, resolve_addr, hle.1])]
    exact h
  · rw [liftOutcome_ok] at h
    obtain ⟨r, hc⟩ := checkPtr_of_store h
    rw [resolve_mono hd hle hn hc]
    exact liftOutcome_ok.2 h

/-- A dereferenceability check through `p` passes where one through `q` does. -/
theorem checkDeref_mono {st : Ryo.Vm.OpSem.State} {q p : ThinPointer} {n : Nat}
    (hd : LiveDisjoint st.mem) (hle : ProvLe st.exposed q p)
    (h : st.checkDeref q n = .ok ()) : st.checkDeref p n = .ok () := by
  unfold State.checkDeref at h ⊢
  rw [liftOutcome_ok] at h ⊢
  by_cases hn : n = 0
  · subst hn; simp [Memory.dereferenceable, checkPtr_zero, bind, Except.bind, pure, Except.pure]
  · unfold Memory.dereferenceable at h
    cases hc : st.mem.checkPtr (st.resolve q n) n with
    | error e => simp [hc, bind, Except.bind] at h
    | ok r =>
      rw [resolve_mono hd hle hn hc]
      exact h

/-! ### Bytes -/

theorem data_of_leDefined {x y : AbstractByte} {d : UInt8} (h : x.leDefined y = true)
    (hx : x.data = some d) : y.data = some d := by
  cases x <;> cases y <;> simp_all [AbstractByte.leDefined, AbstractByte.data] <;>
    (rename_i f1 _ f2; cases f1 <;> cases f2 <;> simp_all)

theorem provFrag_of_leDefined {x y : AbstractByte} {f : ProvenanceFrag} (h : x.leDefined y = true)
    (hx : x.provFrag = some f) : y.provFrag = some f := by
  cases x <;> cases y <;> simp_all [AbstractByte.leDefined, AbstractByte.provFrag] <;>
    (rename_i f1 _ f2; cases f1 <;> cases f2 <;> simp_all)

/-- More defined bytes are the same integer. -/
theorem decodeBits_mono {a b : List AbstractByte} {n : Nat} (hab : bytesLeDefined a b = true)
    (h : decodeBits a = some n) : decodeBits b = some n := by
  rw [decodeBits_iff] at h ⊢
  obtain ⟨ds, hm, rfl⟩ := h
  refine ⟨ds, ?_, rfl⟩
  rw [mapM_data_iff] at hm ⊢
  obtain ⟨hl, hi⟩ := (bytesLeDefined_iff a b).1 hab
  refine ⟨hl ▸ hm.1, fun i h1 h2 => ?_⟩
  exact data_of_leDefined (hi i (hl ▸ h1) h1) (hm.2 i (hl ▸ h1) h2)

/-- More defined bytes are a pointer with at least the provenance. -/
theorem decodePtr_mono {a b : List AbstractByte} {q : ThinPointer} (hab : bytesLeDefined a b = true)
    (h : decodePtr a = some q) : ∃ p, decodePtr b = some p ∧ q.leDefined p = true := by
  rw [decodePtr_eq] at h ⊢
  cases hda : decodeBits a with
  | none => simp [hda] at h
  | some n =>
    simp only [hda, Option.map_some, Option.some.injEq] at h
    subst h
    rw [decodeBits_mono hab hda]
    refine ⟨_, rfl, ?_⟩
    simp only [ThinPointer.leDefined, beq_self_eq_true, Bool.true_and]
    cases hpa : ptrProvOf a with
    | none => simp
    | some r =>
      have hpb : ptrProvOf b = some r := by
        obtain ⟨hne, hi⟩ := (ptrProvOf_iff a r).1 hpa
        obtain ⟨hl, hle⟩ := (bytesLeDefined_iff a b).1 hab
        refine (ptrProvOf_iff b r).2 ⟨fun hb => hne (List.length_eq_zero_iff.1 (hl ▸ hb ▸ rfl)), fun i hi' => ?_⟩
        exact provFrag_of_leDefined (hle i (hl ▸ hi') hi') (hi i (hl ▸ hi'))
      simp [hpb]

/-- An integer result with its operand's value (`x + 0`, `x & -1`, `x | 0`, an extension to
the same width) is `≤def` the operand's bytes: returning the operand keeps more provenance. -/
theorem intBytes_le {bs : List AbstractByte} {v r : Nat} (h : decodeBits bs = some v)
    (hr : r % 2 ^ (8 * bs.length) = v) : bytesLeDefined (encodeBits bs.length r) bs = true := by
  rw [decodeBits_iff] at h
  obtain ⟨ds, hm, hv⟩ := h
  have hl := (mapM_data_iff bs ds).1 hm
  have he : encodeBits bs.length r = ds.map AbstractByte.ofByte := by
    unfold encodeBits
    rw [← leEncode_mod, hr, ← hv, hl.1, leEncode_leDecode]
  rw [he, bytesLeDefined_iff]
  refine ⟨by simp [hl.1], fun i h1 h2 => ?_⟩
  have hd := hl.2 i h2 (by simpa using h1)
  rw [AbstractByte.eq_init_of_data hd]
  simp [AbstractByte.leDefined, AbstractByte.ofByte]

theorem decodeBits_lt {bs : List AbstractByte} {v : Nat} (h : decodeBits bs = some v) :
    v < 2 ^ (8 * bs.length) := by
  rw [decodeBits_iff] at h
  obtain ⟨ds, hm, rfl⟩ := h
  rw [((mapM_data_iff bs ds).1 hm).1]
  exact leDecode_lt ds

/-! The LVN identities at width `w = 8 * bs.length`, on the operand's value. -/

theorem lvn_add_zero {w v : Nat} (h : v < 2 ^ w) : (BitVec.ofNat w v + 0).toNat = v := by
  simp [Nat.mod_eq_of_lt h]

theorem lvn_and_ones {w v : Nat} (h : v < 2 ^ w) :
    (BitVec.ofNat w v &&& BitVec.allOnes w).toNat = v := by
  simp [Nat.mod_eq_of_lt h]

theorem lvn_or_zero {w v : Nat} (h : v < 2 ^ w) : (BitVec.ofNat w v ||| 0).toNat = v := by
  simp [Nat.mod_eq_of_lt h]

theorem lvn_ext_same {w v : Nat} (h : v < 2 ^ w) :
    ((BitVec.ofNat w v).setWidth w).toNat = v ∧ ((BitVec.ofNat w v).signExtend w).toNat = v := by
  simp [Nat.mod_eq_of_lt h]

/-- **Keeping provenance is a refinement** for a pointer read back from bytes: where R reads a
pointer from bytes `a` (an integer result, or bytes without the provenance Rust dropped) and
accesses through it, reading it from bytes `b` with at least that provenance (the JIT's
identity result, the VM's move of a pointer's bytes) accesses the same. -/
theorem use_mono {st : Ryo.Vm.OpSem.State} {a b : List AbstractByte} {q : ThinPointer} {n : Nat}
    {al : Align} {bs : List AbstractByte} (hd : LiveDisjoint st.mem)
    (hab : bytesLeDefined a b = true) (hq : decodePtr a = some q) (h : st.load q n al = .ok bs) :
    ∃ p, decodePtr b = some p ∧ st.load p n al = .ok bs := by
  obtain ⟨p, hp, hle⟩ := decodePtr_mono hab hq
  exact ⟨p, hp, load_mono hd (provLe_of_leDefined hle) h⟩

/-- L0's cast-time choice: an L0 pointer with an exposed provenance `id` (an int→ptr cast)
relates to R's pointer at the same address whatever R's provenance (`ProvLe`'s third case), so
an L0 access through it is matched by R's (`load_mono`, `store_mono`). -/
theorem provLe_exposed {ex : List AllocId} {q p : ThinPointer} {id : AllocId}
    (ha : q.addr = p.addr) (hq : q.prov = some id) (he : id ∈ ex) : ProvLe ex q p :=
  ⟨ha, Or.inr (Or.inr ⟨id, hq, he⟩)⟩

/-- **Dropping an exposed provenance** (folding a pointer to an integer constant: `rebase`, a
folded load of a relocated field, rule 4 of design/provenance.md): an access through the bare
address does what one through the pointer does, if that is defined. -/
theorem drop_exposed_mono {st : Ryo.Vm.OpSem.State} {addr n : Nat} {id : AllocId} {al : Align}
    {bs : List AbstractByte} (hd : LiveDisjoint st.mem) (he : id ∈ st.exposed)
    (h : st.load ⟨addr, some id⟩ n al = .ok bs) : st.load ⟨addr, none⟩ n al = .ok bs :=
  load_mono (q := ⟨addr, some id⟩) hd (provLe_exposed rfl rfl he) h

theorem drop_exposed_store {st : Ryo.Vm.OpSem.State} {addr : Nat} {id : AllocId} {al : Align}
    {bs : List AbstractByte} {mem' : Memory} (hd : LiveDisjoint st.mem) (he : id ∈ st.exposed)
    (h : st.store st.mem ⟨addr, some id⟩ bs al = .ok mem') :
    st.store st.mem ⟨addr, none⟩ bs al = .ok mem' :=
  store_mono (q := ⟨addr, some id⟩) hd (provLe_exposed rfl rfl he) h

/-! ### `LiveDisjoint` under scopes -/

theorem get?_push {m : Array Allocation} {a b : Allocation} {i : Nat}
    (h : ({ allocs := m.push a } : Memory).get? i = some b) :
    (i < m.size ∧ ({ allocs := m } : Memory).get? i = some b) ∨ (i = m.size ∧ b = a) := by
  simp only [Memory.get?, Array.getElem?_push] at h ⊢
  split at h
  · right; simp_all
  · left
    rename_i hne
    have hlt : i < m.size := by
      rcases Nat.lt_or_ge i m.size with hh | hh
      · exact hh
      · simp [Array.getElem?_eq_none (by omega : m.size ≤ i)] at h
    exact ⟨hlt, h⟩

/-- An overlap of a live allocation with `[addr, addr + size)` at byte `x`. -/
theorem overlaps_of_mem {b : Allocation} {addr n x : Nat} (h1 : b.addr ≤ x)
    (h2 : x < b.addr + b.size) (h3 : addr ≤ x) (h4 : x < addr + n) :
    b.overlaps addr n = true := by
  have hs1 : b.size ≠ 0 := by intro h0; rw [h0] at h2; omega
  have hs2 : n ≠ 0 := by omega
  unfold Allocation.overlaps
  split
  · rename_i hc
    simp only [Bool.or_eq_true, beq_iff_eq] at hc
    rcases hc with hc | hc
    · exact absurd hc hs1
    · exact absurd hc hs2
  · simp only [Bool.not_eq_true', Bool.or_eq_false_iff, decide_eq_false_iff_not, Nat.not_le]
    exact ⟨Nat.lt_of_le_of_lt h3 h2, Nat.lt_of_le_of_lt h1 h4⟩

/-- `Escape` keeps live allocations disjoint: it checks the new one against the live ones. -/
theorem escape_liveDisjoint {s s' : Ryo.Vm.R.RState} {off : Int} {size align : Nat}
    (h : Ryo.Vm.R.escape s off size align = .ok s') (hd : LiveDisjoint s.st.mem) :
    LiveDisjoint s'.st.mem := by
  unfold Ryo.Vm.R.escape at h
  simp only at h
  split at h
  · cases h; exact hd
  split at h
  · cases h
  unfold Ryo.Vm.R.frameAddr at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  rename_i hnn
  split at hnn
  · cases hnn
  simp only [pure, Except.pure, Except.ok.injEq] at hnn
  subst hnn
  simp only [pure, Except.pure] at h
  split at h
  · cases h
  split at h
  · cases h
  rename_i hov
  cases hr : s.st.readFrame off size with
  | error e => simp [hr] at h
  | ok bytes =>
    simp only [hr, Except.ok.injEq] at h
    subst h
    have hlen := readFrame_length hr
    simp only [Bool.not_eq_true, Array.any_eq_false, Bool.and_eq_true, not_and,
      Bool.not_eq_true] at hov
    intro i j a b x hi hj hla hlb h1 h2 h3 h4
    simp only at hi hj
    -- The new allocation's bytes are `[addr, addr + size)`.
    have hnew : ∀ (c : Allocation) k, ({ allocs := s.st.mem.allocs } : Memory).get? k = some c →
        c.live = true → c.addr ≤ x → x < c.addr + c.size → (↑s.fp + off).toNat ≤ x →
        x < (↑s.fp + off).toNat + size → False := by
      intro c k hc hl c1 c2 n1 n2
      simp only [Memory.get?] at hc
      obtain ⟨hk, hck⟩ := Array.getElem?_eq_some_iff.1 hc
      have := hov k hk (hck ▸ hl)
      rw [hck, overlaps_of_mem c1 c2 n1 n2] at this
      cases this
    rcases get?_push hi with ⟨hi1, hi2⟩ | ⟨rfl, rfl⟩ <;>
      rcases get?_push hj with ⟨hj1, hj2⟩ | ⟨rfl, rfl⟩
    · exact hd i j a b x hi2 hj2 hla hlb h1 h2 h3 h4
    · exact (hnew a i hi2 hla h1 h2 h3 (by simpa [Allocation.size, hlen] using h4)).elim
    · exact (hnew b j hj2 hlb h3 h4 h1 (by simpa [Allocation.size, hlen] using h2)).elim
    · rfl

end Ryo.Proofs.Provenance
