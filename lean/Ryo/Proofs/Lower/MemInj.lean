/-
Ryo.Proofs.Lower.MemInj — the memory relation of the lowering simulation L0 → R (M5a,
aot.md §C1 "Memory outside frames", plan.md §4 "Memory relation complexity").

Both levels use `Ryo/Spec/Mem` with concrete addresses, so the relation is the identity on
addresses and a renaming of provenance: an `Inj` maps each L0 allocation to the R allocation
that holds it, or to none.

- Several L0 allocations may map into one R allocation: the pool is one R allocation holding
  every constant (D7 lets the source pick the copy), and an `Escape` scope's range is one R
  object that may hold several L0 locals. So an `Inj` is not injective; an L0 allocation's
  bytes sit at the *same addresses* inside its R allocation (CompCert's `meminj` with the
  offset fixed by the addresses).
- An L0 allocation mapped to none is one whose provenance L0 only uses where it doesn't
  matter: a zero-sized local (R's pointer to it has no provenance, aot.md §C1 "Locals"), or a
  non-escaped local, whose provenance occurs nowhere in the L0 state (the frame relation's
  job, not this file's). A byte or pointer with such provenance relates to any R byte or
  pointer with the same data.
- R may have *more* provenance than L0 (`none` in L0 relates to anything): R resolves at the
  access with an exposed fallback (`OpSem.State.resolve`), so extra provenance never adds UB
  (`Ryo.Proofs.Provenance`).

`MemInj ι m0 m1`: every L0 allocation mapped by `ι` lies inside its R allocation with the
same addresses, the R allocation is live when it is, writable when it is, and each L0 byte
`ByteInj ι`-refines the R byte at the same address. Unmapped and R-only allocations are
unconstrained here.
-/
import Ryo.Spec
import Ryo.Vm.OpSem.Basic

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Theorems

/-- A provenance renaming: the R allocation an L0 allocation lies in, if any. -/
abbrev Inj := AllocId → Option AllocId

/-- `ι ⊆ ι'`: `ι'` extends `ι`. -/
def Inj.Le (ι ι' : Inj) : Prop := ∀ a b, ι a = some b → ι' a = some b

/-- An L0 provenance relates to an R provenance: no provenance (or one `ι` drops) relates to
anything, a mapped one to its image. -/
def ProvInj (ι : Inj) : Option AllocId → Option AllocId → Prop
  | none, _ => True
  | some a, q => match ι a with
    | none => True
    | some b => q = some b

/-- The byte order, through `ι`: `Uninit` is refined by anything, data must agree, and a
pointer fragment's provenance maps through `ι` (at the same position). -/
def ByteInj (ι : Inj) : AbstractByte → AbstractByte → Prop
  | .uninit, _ => True
  | .init d none, .init d' _ => d = d'
  | .init d (some f), .init d' g =>
    d = d' ∧ match ι f.prov with
      | none => True
      | some b => g = some ⟨b, f.pos⟩
  | .init _ _, .uninit => False

/-- Byte lists, pointwise. -/
def BytesInj (ι : Inj) : List AbstractByte → List AbstractByte → Prop
  | [], [] => True
  | b0 :: bs0, b1 :: bs1 => ByteInj ι b0 b1 ∧ BytesInj ι bs0 bs1
  | _, _ => False

/-- Pointers: the same address, provenance by `ProvInj`. -/
def PtrInj (ι : Inj) (p0 p1 : ThinPointer) : Prop :=
  p0.addr = p1.addr ∧ ProvInj ι p0.prov p1.prov

/-- An L0 allocation and the R allocation it lies in. -/
structure AllocInj (ι : Inj) (x y : Allocation) : Prop where
  lo : y.addr ≤ x.addr
  hi : x.addr + x.size ≤ y.addr + y.size
  live : x.live = true → y.live = true
  mutable : x.mutable = true → y.mutable = true
  /-- A live L0 allocation's bytes (a dead one's are never read again). -/
  bytes : x.live = true → ∀ i (h0 : i < x.data.size) (h1 : x.addr - y.addr + i < y.data.size),
    ByteInj ι x.data[i] y.data[x.addr - y.addr + i]

/-- The memory relation (see the module comment). -/
def MemInj (ι : Inj) (m0 m1 : Memory) : Prop :=
  ∀ a b x, m0.get? a = some x → ι a = some b → ∃ y, m1.get? b = some y ∧ AllocInj ι x y

/-! ### The orders -/

theorem ByteInj.refl_id (b : AbstractByte) : ByteInj some b b := by
  cases b with
  | uninit => exact True.intro
  | init d f =>
    cases f with
    | none => exact (rfl : d = d)
    | some f =>
      exact (⟨rfl, rfl⟩ : d = d ∧ (some ⟨f.prov, f.pos⟩ : Option ProvenanceFrag) = some f)

-- helper (before ByteInj.mono): the fragment part of `ByteInj`'s `.init _ (some f)` case
private def fragInj (ι : Inj) (f : ProvenanceFrag) (g : Option ProvenanceFrag) : Prop :=
  match ι f.prov with
  | none => True
  | some b => g = some ⟨b, f.pos⟩

private theorem fragInj_none {ι : Inj} {f : ProvenanceFrag} {g : Option ProvenanceFrag}
    (h : ι f.prov = none) : fragInj ι f g := by
  simp only [fragInj, h]

private theorem fragInj_some {ι : Inj} {f : ProvenanceFrag} {g : Option ProvenanceFrag}
    {b : AllocId} (h : ι f.prov = some b) : fragInj ι f g ↔ g = some ⟨b, f.pos⟩ := by
  simp only [fragInj, h]

/-- Extending `ι` keeps a byte related unless its provenance is one `ι` drops and `ι'` maps. -/
theorem ByteInj.mono {ι ι' : Inj} (h : ι.Le ι') {b0 b1 : AbstractByte}
    (hb : ByteInj ι b0 b1)
    (hnew : ∀ f, b0.provFrag = some f → ι f.prov = none → ι' f.prov = none) :
    ByteInj ι' b0 b1 := by
  cases b0 with
  | uninit => exact True.intro
  | init d f =>
    cases b1 with
    | uninit => cases f <;> exact (hb : False).elim
    | init d' g =>
      cases f with
      | none => exact (hb : d = d')
      | some f =>
        have hb' : d = d' ∧ fragInj ι f g := hb
        show d = d' ∧ fragInj ι' f g
        refine ⟨hb'.1, ?_⟩
        cases hι : ι f.prov with
        | none => exact fragInj_none (hnew f rfl hι)
        | some b => exact (fragInj_some (h _ _ hι)).2 ((fragInj_some hι).1 hb'.2)

/-- With `ι = some` (no renaming), `ByteInj` contains MiniRust's order. -/
theorem ByteInj.of_leDefined {b0 b1 : AbstractByte} (h : b0.leDefined b1 = true) :
    ByteInj some b0 b1 := by
  cases b0 with
  | uninit => exact True.intro
  | init d f =>
    cases b1 with
    | uninit => cases f <;> simp [AbstractByte.leDefined] at h
    | init d' g =>
      cases f with
      | none =>
        have h' : (d == d') = true := h
        exact (by simpa using h' : d = d')
      | some f =>
        cases g with
        | none => simp [AbstractByte.leDefined] at h
        | some g =>
          have h' : (d == d' && f == g) = true := h
          simp only [Bool.and_eq_true, beq_iff_eq] at h'
          obtain ⟨rfl, rfl⟩ := h'
          exact ByteInj.refl_id _

theorem BytesInj.of_leDefined {bs0 bs1 : List AbstractByte} (h : bytesLeDefined bs0 bs1 = true) :
    BytesInj some bs0 bs1 := by
  induction bs0 generalizing bs1 with
  | nil =>
    cases bs1 with
    | nil => exact True.intro
    | cons _ _ => simp [bytesLeDefined, List.leDefinedBy] at h
  | cons b bs ih =>
    cases bs1 with
    | nil => simp [bytesLeDefined, List.leDefinedBy] at h
    | cons b' bs' =>
      have h' : (b.leDefined b' && bytesLeDefined bs bs') = true := h
      simp only [Bool.and_eq_true] at h'
      show ByteInj some b b' ∧ BytesInj some bs bs'
      exact ⟨ByteInj.of_leDefined h'.1, ih h'.2⟩

theorem BytesInj.length {ι : Inj} {bs0 bs1 : List AbstractByte} (h : BytesInj ι bs0 bs1) :
    bs0.length = bs1.length := by
  induction bs0 generalizing bs1 with
  | nil =>
    cases bs1 with
    | nil => rfl
    | cons _ _ => exact (h : False).elim
  | cons b bs ih =>
    cases bs1 with
    | nil => exact (h : False).elim
    | cons b' bs' =>
      have h' : ByteInj ι b b' ∧ BytesInj ι bs bs' := h
      simp only [List.length_cons, ih h'.2]

theorem BytesInj.append {ι : Inj} {a0 a1 b0 b1 : List AbstractByte} (ha : BytesInj ι a0 a1)
    (hb : BytesInj ι b0 b1) : BytesInj ι (a0 ++ b0) (a1 ++ b1) := by
  induction a0 generalizing a1 with
  | nil =>
    cases a1 with
    | nil => exact hb
    | cons _ _ => exact (ha : False).elim
  | cons x xs ih =>
    cases a1 with
    | nil => exact (ha : False).elim
    | cons y ys =>
      have ha' : ByteInj ι x y ∧ BytesInj ι xs ys := ha
      show ByteInj ι x y ∧ BytesInj ι (xs ++ b0) (ys ++ b1)
      exact ⟨ha'.1, ih ha'.2⟩

theorem BytesInj.uninit {ι : Inj} (bs : List AbstractByte) :
    BytesInj ι (List.replicate bs.length .uninit) bs := by
  induction bs with
  | nil => exact True.intro
  | cons b bs ih =>
    show ByteInj ι .uninit b ∧ BytesInj ι (List.replicate bs.length .uninit) bs
    exact ⟨True.intro, ih⟩

-- helpers (before decodeBits_inj)
private theorem bytesInj_getElem {ι : Inj} {a b : List AbstractByte} (h : BytesInj ι a b) :
    ∀ i (h1 : i < a.length) (h2 : i < b.length), ByteInj ι a[i] b[i] := by
  induction a generalizing b with
  | nil => intro i h1; simp at h1
  | cons x xs ih =>
    cases b with
    | nil => intro i _ h2; simp at h2
    | cons y ys =>
      have h' : ByteInj ι x y ∧ BytesInj ι xs ys := h
      intro i h1 h2
      cases i with
      | zero => exact h'.1
      | succ i =>
        exact ih h'.2 i (by simp at h1; omega) (by simp at h2; omega)

private theorem data_of_byteInj {ι : Inj} {x y : AbstractByte} {d : UInt8} (hb : ByteInj ι x y)
    (hx : x.data = some d) : y.data = some d := by
  cases x with
  | uninit => simp [AbstractByte.data] at hx
  | init d0 f =>
    have hd : d0 = d := by simpa [AbstractByte.data] using hx
    cases y with
    | uninit => cases f <;> exact (hb : False).elim
    | init d1 g =>
      have h01 : d0 = d1 := by
        cases f with
        | none => exact (hb : d0 = d1)
        | some f => exact (hb : d0 = d1 ∧ fragInj ι f g).1
      show some d1 = some d
      rw [← h01, hd]

/-! ### Decoding -/

/-- Integers read the same: L0's bytes decode only if all are initialized, and then R's carry
the same data. -/
theorem decodeBits_inj {ι : Inj} {bs0 bs1 : List AbstractByte} (h : BytesInj ι bs0 bs1)
    {v : Nat} (hv : decodeBits bs0 = some v) : decodeBits bs1 = some v := by
  rw [Ryo.Spec.Theorems.decodeBits_iff] at hv ⊢
  obtain ⟨ds, hm, rfl⟩ := hv
  refine ⟨ds, ?_, rfl⟩
  rw [Ryo.Spec.Theorems.mapM_data_iff] at hm ⊢
  have hl := BytesInj.length h
  refine ⟨by rw [← hl]; exact hm.1, fun i h1 h2 => ?_⟩
  have h0 : i < bs0.length := by rw [hl]; exact h1
  exact data_of_byteInj (bytesInj_getElem h i h0 h1) (hm.2 i h0 h2)

-- helper (before encodeBits_inj)
private theorem bytesInj_map_ofByte (ι : Inj) (l : List UInt8) :
    BytesInj ι (l.map AbstractByte.ofByte) (l.map AbstractByte.ofByte) := by
  induction l with
  | nil => exact True.intro
  | cons x l ih =>
    show ByteInj ι (AbstractByte.ofByte x) (AbstractByte.ofByte x) ∧
      BytesInj ι (l.map AbstractByte.ofByte) (l.map AbstractByte.ofByte)
    exact ⟨(rfl : x = x), ih⟩

theorem encodeBits_inj (ι : Inj) (n v : Nat) : BytesInj ι (encodeBits n v) (encodeBits n v) := by
  unfold encodeBits
  exact bytesInj_map_ofByte ι _

-- helpers (before decodePtr_inj)
private theorem provInj_some_none {ι : Inj} {a : AllocId} {q : Option AllocId}
    (h : ι a = none) : ProvInj ι (some a) q := by
  simp only [ProvInj, h]

private theorem provInj_some_some {ι : Inj} {a b : AllocId} {q : Option AllocId}
    (h : ι a = some b) (hq : q = some b) : ProvInj ι (some a) q := by
  simp only [ProvInj, h, hq]

private theorem provFrag_of_byteInj {ι : Inj} {x y : AbstractByte} (hb : ByteInj ι x y)
    {f : ProvenanceFrag} (hx : x.provFrag = some f) {b : AllocId} (hι : ι f.prov = some b) :
    y.provFrag = some ⟨b, f.pos⟩ := by
  cases x with
  | uninit => simp [AbstractByte.provFrag] at hx
  | init d f0 =>
    cases y with
    | uninit => cases f0 <;> exact (hb : False).elim
    | init d' g =>
      cases f0 with
      | none => simp [AbstractByte.provFrag] at hx
      | some f0 =>
        have hx' : f0 = f := by simpa [AbstractByte.provFrag] using hx
        have hb' : d = d' ∧ fragInj ι f0 g := hb
        rw [hx'] at hb'
        exact (fragInj_some hι).1 hb'.2

/-- Pointers read related: the same address, provenance by `ProvInj`. -/
theorem decodePtr_inj {ι : Inj} {bs0 bs1 : List AbstractByte} (h : BytesInj ι bs0 bs1)
    {p0 : ThinPointer} (hp : decodePtr bs0 = some p0) :
    ∃ p1, decodePtr bs1 = some p1 ∧ PtrInj ι p0 p1 := by
  rw [Ryo.Spec.Theorems.decodePtr_eq] at hp ⊢
  cases hda : decodeBits bs0 with
  | none => simp [hda] at hp
  | some n =>
    simp only [hda, Option.map_some, Option.some.injEq] at hp
    subst hp
    rw [decodeBits_inj h hda]
    refine ⟨_, rfl, ?_⟩
    show n = n ∧ ProvInj ι (Ryo.Spec.Theorems.ptrProvOf bs0) (Ryo.Spec.Theorems.ptrProvOf bs1)
    refine ⟨rfl, ?_⟩
    cases hpa : Ryo.Spec.Theorems.ptrProvOf bs0 with
    | none => exact True.intro
    | some r =>
      cases hr : ι r with
      | none =>
        exact provInj_some_none hr
      | some b =>
        have hpb : Ryo.Spec.Theorems.ptrProvOf bs1 = some b := by
          obtain ⟨hne, hi⟩ := (Ryo.Spec.Theorems.ptrProvOf_iff bs0 r).1 hpa
          have hl := BytesInj.length h
          refine (Ryo.Spec.Theorems.ptrProvOf_iff bs1 b).2 ⟨?_, fun i hi1 => ?_⟩
          · intro h1
            subst h1
            cases bs0 with
            | nil => exact hne rfl
            | cons _ _ => simp at hl
          · have hi0 : i < bs0.length := by rw [hl]; exact hi1
            exact provFrag_of_byteInj (bytesInj_getElem h i hi0 hi1) (hi i hi0) hr
        exact provInj_some_some hr hpb

/-! ### Memory operations -/

/-- Pointwise relation of equal-length lists gives `BytesInj`. -/
theorem BytesInj.of_getElem {ι : Inj} {l0 l1 : List AbstractByte} (hl : l0.length = l1.length)
    (hp : ∀ i (h0 : i < l0.length) (h1 : i < l1.length), ByteInj ι l0[i] l1[i]) :
    BytesInj ι l0 l1 := by
  induction l0 generalizing l1 with
  | nil =>
    cases l1 with
    | nil => show True; trivial
    | cons c cs => simp at hl
  | cons b bs ih =>
    cases l1 with
    | nil => simp at hl
    | cons c cs =>
      show ByteInj ι b c ∧ BytesInj ι bs cs
      refine ⟨hp 0 (by simp only [List.length_cons]; omega) (by simp only [List.length_cons]; omega), ?_⟩
      refine ih (by simp only [List.length_cons] at hl; omega) ?_
      intro i h0 h1
      exact hp (i + 1) (by simp only [List.length_cons]; omega) (by simp only [List.length_cons]; omega)

theorem checkPtr_zero' (m : Memory) (p : ThinPointer) : m.checkPtr p 0 = .ok none := by
  simp [Memory.checkPtr, pure, Except.pure]

theorem load_zero_inv {m : Memory} {p : ThinPointer} {al : Align} {bs : List AbstractByte}
    (h : m.load p 0 al = .ok bs) : bs = [] := by
  unfold Memory.load at h
  split at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  rw [checkPtr_zero'] at h
  simp only [bind, Except.bind] at h
  exact (Except.ok.inj h).symm

theorem load_zero_ok {m : Memory} {p : ThinPointer} {al : Align} (hal : al.isAligned p.addr = true) :
    m.load p 0 al = .ok [] := by
  unfold Memory.load
  simp only [hal, Bool.not_true, Bool.false_eq_true, ite_false]
  rw [checkPtr_zero']
  rfl

theorem load_eq_ok_pos {m : Memory} {p : ThinPointer} {n : Nat} {al : Align}
    {bs : List AbstractByte} (hn : n ≠ 0) (h : m.load p n al = .ok bs) :
    ∃ id, ∃ hid : id < m.allocs.size, p.prov = some id ∧ m.allocs[id].live = true ∧
      m.allocs[id].addr ≤ p.addr ∧ p.addr + n ≤ m.allocs[id].addr + m.allocs[id].data.size ∧
      bs = (m.allocs[id].data.extract (p.addr - m.allocs[id].addr)
        (p.addr - m.allocs[id].addr + n)).toList := by
  unfold Memory.load at h
  split at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  cases hc : m.checkPtr p n with
  | error e =>
    rw [hc] at h
    simp [bind, Except.bind] at h
  | ok r =>
    rw [hc] at h
    rcases (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok).1 hc with
      ⟨hl, -⟩ | ⟨id, hid, -, hprov, hlv, h1, h2, rfl⟩
    · exact absurd hl hn
    · refine ⟨id, hid, hprov, hlv, h1, h2, ?_⟩
      simp only [bind, Except.bind] at h
      rw [getElem!_pos m.allocs id hid] at h
      exact (Except.ok.inj h).symm

theorem load_of_bounds {m : Memory} {p : ThinPointer} {n : Nat} {al : Align} {id : AllocId}
    (hid : id < m.allocs.size) (hal : al.isAligned p.addr = true) (hn : n ≠ 0)
    (hprov : p.prov = some id) (hlv : m.allocs[id].live = true) (h1 : m.allocs[id].addr ≤ p.addr)
    (h2 : p.addr + n ≤ m.allocs[id].addr + m.allocs[id].data.size) :
    m.load p n al = .ok (m.allocs[id].data.extract (p.addr - m.allocs[id].addr)
      (p.addr - m.allocs[id].addr + n)).toList := by
  have hc := (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok (mem := m) (p := p) (len := n)
    (r := some (id, p.addr - m.allocs[id].addr))).mpr
    (.inr ⟨id, hid, hn, hprov, hlv, h1, h2, rfl⟩)
  unfold Memory.load
  simp only [hal, Bool.not_true, Bool.false_eq_true, ite_false]
  rw [hc]
  simp only [bind, Except.bind]
  rw [getElem!_pos m.allocs id hid]
  rfl

theorem get?_of_lt {m : Memory} {id : AllocId} (hid : id < m.allocs.size) :
    m.get? id = some m.allocs[id] :=
  Array.getElem?_eq_some_iff.2 ⟨hid, rfl⟩

theorem checkPtr_ok_of_deref {m : Memory} {p : ThinPointer} {n : Nat}
    (h : m.dereferenceable p n = .ok ()) : ∃ r, m.checkPtr p n = .ok r := by
  unfold Memory.dereferenceable at h
  cases hc : m.checkPtr p n with
  | error e =>
    rw [hc] at h
    first
      | (simp only [bind, Except.bind] at h; cases h)
      | simp [bind, Except.bind] at h
      | cases h
  | ok r => exact ⟨r, rfl⟩

/-- A non-empty L0 load through a mapped provenance: R's load through the image provenance (at
any alignment the address has) succeeds with related bytes. -/
theorem load_inj {ι : Inj} {m0 m1 : Memory} (hm : MemInj ι m0 m1) {p : ThinPointer} {a b : AllocId}
    (ha : p.prov = some a) (hb : ι a = some b) {n : Nat} {al0 al1 : Align}
    (hal : al1.isAligned p.addr = true) {bs0 : List AbstractByte}
    (h : m0.load p n al0 = .ok bs0) :
    ∃ bs1, m1.load { p with prov := some b } n al1 = .ok bs1 ∧ BytesInj ι bs0 bs1 := by
  have hal' : al1.isAligned ({ p with prov := some b } : ThinPointer).addr = true := hal
  by_cases hn : n = 0
  · subst hn
    have h0 := load_zero_inv h
    subst h0
    exact ⟨[], load_zero_ok hal', show True from trivial⟩
  obtain ⟨id, hid, hprov, hlv, h1, h2, rfl⟩ := load_eq_ok_pos hn h
  have hia : id = a := Option.some.inj (hprov.symm.trans ha)
  rw [← hia] at hb
  obtain ⟨y, hy, hinj⟩ := hm id b _ (get?_of_lt hid) hb
  obtain ⟨hb1, hyeq⟩ := Array.getElem?_eq_some_iff.1 hy
  subst hyeq
  have hlo := hinj.lo
  have hhi := hinj.hi
  simp only [Allocation.size] at hhi
  have hlv1 := hinj.live hlv
  refine ⟨_, load_of_bounds (p := { p with prov := some b }) hb1 hal' hn rfl hlv1
    (by show _ ≤ p.addr; omega) (by show p.addr + n ≤ _; omega), ?_⟩
  show BytesInj ι _ (m1.allocs[b].data.extract (p.addr - m1.allocs[b].addr)
    (p.addr - m1.allocs[b].addr + n)).toList
  apply BytesInj.of_getElem
  · simp only [Array.length_toList, Array.size_extract]; omega
  · intro i h0 h1'
    simp only [Array.length_toList, Array.size_extract] at h0 h1'
    simp only [Array.getElem_toList, Array.getElem_extract]
    have e : m0.allocs[id].addr - m1.allocs[b].addr + (p.addr - m0.allocs[id].addr + i) =
        p.addr - m1.allocs[b].addr + i := by omega
    have hbyte := hinj.bytes hlv (p.addr - m0.allocs[id].addr + i) (by omega) (by omega)
    simp only [e] at hbyte
    exact hbyte

theorem BytesInj.getElem' {ι : Inj} {bs0 bs1 : List AbstractByte} (h : BytesInj ι bs0 bs1)
    (i : Nat) (h0 : i < bs0.length) (h1 : i < bs1.length) : ByteInj ι bs0[i] bs1[i] := by
  induction bs0 generalizing bs1 i with
  | nil => simp at h0
  | cons b0 t0 ih =>
    cases bs1 with
    | nil => simp at h1
    | cons b1 t1 =>
      have h' : ByteInj ι b0 b1 ∧ BytesInj ι t0 t1 := h
      cases i with
      | zero => exact h'.1
      | succ k =>
        have hk0 : k < t0.length := by simp at h0; omega
        have hk1 : k < t1.length := by simp at h1; omega
        exact ih h'.2 k hk0 hk1

/-- R's store succeeds when `checkPtr` and the mutability check pass. -/
theorem store_ok_exists {mem : Memory} {q : ThinPointer} {bytes : List AbstractByte} {al : Align}
    {k : AllocId} (hid : k < mem.allocs.size) (hal : al.isAligned q.addr = true)
    (hl : bytes.length ≠ 0) (hprov : q.prov = some k) (hlv : mem.allocs[k].live = true)
    (h1 : mem.allocs[k].addr ≤ q.addr)
    (h2 : q.addr + bytes.length ≤ mem.allocs[k].addr + mem.allocs[k].data.size)
    (hm : mem.allocs[k].mutable = true) : ∃ m', mem.store q bytes al = .ok m' := by
  have hc := (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok (mem := mem) (p := q) (len := bytes.length)
    (r := some (k, q.addr - mem.allocs[k].addr))).mpr (.inr ⟨k, hid, hl, hprov, hlv, h1, h2, rfl⟩)
  first
  | (unfold Memory.store
     simp only [hal, Bool.not_true, Bool.false_eq_true, ite_false]
     rw [hc]
     simp only [bind, Except.bind]
     rw [getElem!_pos mem.allocs k hid]
     simp only [hm, Bool.not_true, Bool.false_eq_true, ite_false]
     exact ⟨_, rfl⟩)
  | (simp [Memory.store, hal, hc, getElem!_pos mem.allocs k hid, hm]; done)

/-- The stored-to allocation: new bytes in both, related pointwise by `BytesInj`. -/
theorem allocInj_store_self {ι : Inj} {x y : Allocation} (hxy : AllocInj ι x y)
    {bs0 bs1 : List AbstractByte} (hbs : BytesInj ι bs0 bs1) (hlv : x.live = true) {pa : Nat}
    (hxp : x.addr ≤ pa) {arr0 arr1 : Array AbstractByte}
    (hs0 : arr0.size = x.data.size) (hs1 : arr1.size = y.data.size)
    (hg0 : ∀ j, arr0[j]? = if pa - x.addr + 0 ≤ j ∧ j < pa - x.addr + 0 + bs0.length ∧
      j < x.data.size then bs0[j - (pa - x.addr) - 0]? else x.data[j]?)
    (hg1 : ∀ j, arr1[j]? = if pa - y.addr + 0 ≤ j ∧ j < pa - y.addr + 0 + bs1.length ∧
      j < y.data.size then bs1[j - (pa - y.addr) - 0]? else y.data[j]?) :
    AllocInj ι { x with data := arr0 } { y with data := arr1 } := by
  have hlo : y.addr ≤ x.addr := hxy.lo
  have hhi : x.addr + x.data.size ≤ y.addr + y.data.size := hxy.hi
  have hlen := hbs.length
  refine ⟨hxy.lo, ?_, hxy.live, hxy.mutable, ?_⟩
  · show x.addr + arr0.size ≤ y.addr + arr1.size
    rw [hs0, hs1]; exact hhi
  · intro _ i h0 h1
    change i < arr0.size at h0
    change x.addr - y.addr + i < arr1.size at h1
    change ByteInj ι arr0[i] arr1[x.addr - y.addr + i]
    have e0 := hg0 i
    have e1 := hg1 (x.addr - y.addr + i)
    rw [Array.getElem?_eq_getElem h0] at e0
    rw [Array.getElem?_eq_getElem h1] at e1
    by_cases hin : pa - x.addr ≤ i ∧ i < pa - x.addr + bs0.length
    · have c0 : pa - x.addr + 0 ≤ i ∧ i < pa - x.addr + 0 + bs0.length ∧ i < x.data.size := by
        omega
      have c1 : pa - y.addr + 0 ≤ x.addr - y.addr + i ∧
          x.addr - y.addr + i < pa - y.addr + 0 + bs1.length ∧
          x.addr - y.addr + i < y.data.size := by omega
      rw [if_pos c0] at e0
      rw [if_pos c1] at e1
      have hk : x.addr - y.addr + i - (pa - y.addr) - 0 = i - (pa - x.addr) - 0 := by omega
      rw [hk] at e1
      have hk0 : i - (pa - x.addr) - 0 < bs0.length := by omega
      have hk1 : i - (pa - x.addr) - 0 < bs1.length := by omega
      rw [List.getElem?_eq_getElem hk0] at e0
      rw [List.getElem?_eq_getElem hk1] at e1
      rw [Option.some.inj e0, Option.some.inj e1]
      exact BytesInj.getElem' hbs _ hk0 hk1
    · have c0 : ¬(pa - x.addr + 0 ≤ i ∧ i < pa - x.addr + 0 + bs0.length ∧ i < x.data.size) := by
        omega
      have c1 : ¬(pa - y.addr + 0 ≤ x.addr - y.addr + i ∧
          x.addr - y.addr + i < pa - y.addr + 0 + bs1.length ∧
          x.addr - y.addr + i < y.data.size) := by omega
      rw [if_neg c0] at e0
      rw [if_neg c1] at e1
      have hx0 : i < x.data.size := by omega
      have hj : x.addr - y.addr + i < y.data.size := by omega
      rw [Array.getElem?_eq_getElem hx0] at e0
      rw [Array.getElem?_eq_getElem hj] at e1
      rw [Option.some.inj e0, Option.some.inj e1]
      exact hxy.bytes hlv i hx0 hj

/-- Another L0 allocation in the stored-to R allocation: its range is disjoint from the store
(when live), so the R bytes it sees are unchanged. -/
theorem allocInj_store_other {ι : Inj} {x y : Allocation} (hxy : AllocInj ι x y) {pa n : Nat}
    (hya : y.addr ≤ pa)
    (hd : x.live = true → x.size = 0 ∨ x.addr + x.size ≤ pa ∨ pa + n ≤ x.addr)
    {bs1 : List AbstractByte} (hn : bs1.length = n) {arr1 : Array AbstractByte}
    (hs1 : arr1.size = y.data.size)
    (hg1 : ∀ j, arr1[j]? = if pa - y.addr + 0 ≤ j ∧ j < pa - y.addr + 0 + bs1.length ∧
      j < y.data.size then bs1[j - (pa - y.addr) - 0]? else y.data[j]?) :
    AllocInj ι x { y with data := arr1 } := by
  have hlo : y.addr ≤ x.addr := hxy.lo
  have hhi : x.addr + x.data.size ≤ y.addr + y.data.size := hxy.hi
  refine ⟨hxy.lo, ?_, hxy.live, hxy.mutable, ?_⟩
  · show x.addr + x.data.size ≤ y.addr + arr1.size
    rw [hs1]; exact hhi
  · intro hl i h0 h1
    change x.addr - y.addr + i < arr1.size at h1
    change ByteInj ι x.data[i] arr1[x.addr - y.addr + i]
    have hd' : x.data.size = 0 ∨ x.addr + x.data.size ≤ pa ∨ pa + n ≤ x.addr := hd hl
    have e1 := hg1 (x.addr - y.addr + i)
    rw [Array.getElem?_eq_getElem h1] at e1
    have c1 : ¬(pa - y.addr + 0 ≤ x.addr - y.addr + i ∧
        x.addr - y.addr + i < pa - y.addr + 0 + bs1.length ∧
        x.addr - y.addr + i < y.data.size) := by omega
    rw [if_neg c1] at e1
    have hj : x.addr - y.addr + i < y.data.size := by omega
    rw [Array.getElem?_eq_getElem hj] at e1
    rw [Option.some.inj e1]
    exact hxy.bytes hl i h0 hj

/-- An L0 store through a mapped provenance of bytes related to R's: R's store succeeds and
the relation holds after both. -/
theorem store_inj {ι : Inj} {m0 m1 : Memory} (hm : MemInj ι m0 m1) {p : ThinPointer} {a b : AllocId}
    (ha : p.prov = some a) (hb : ι a = some b) {bs0 bs1 : List AbstractByte}
    (hbs : BytesInj ι bs0 bs1) {al0 al1 : Align} (hal : al1.isAligned p.addr = true)
    {m0' : Memory} (h : m0.store p bs0 al0 = .ok m0')
    (hdisj : ∀ a' x', m0.get? a' = some x' → x'.live = true → ι a' = some b → a' ≠ a →
      x'.size = 0 ∨ x'.addr + x'.size ≤ p.addr ∨ p.addr + bs0.length ≤ x'.addr) :
    ∃ m1', m1.store { p with prov := some b } bs1 al1 = .ok m1' ∧ MemInj ι m0' m1' := by
  have hlen : bs0.length = bs1.length := hbs.length
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h with
    ⟨_, hl, rfl⟩ | ⟨k, hid, _, hl, hprov, hlv, h1, h2, hmut, rfl⟩
  · -- Zero-length: both stores are the identity.
    have hnil : bs1 = [] := List.eq_nil_of_length_eq_zero (by omega)
    subst hnil
    refine ⟨m1, ?_, hm⟩
    simp [Memory.store, hal, Memory.checkPtr] <;> rfl
  · have e : k = a := Option.some.inj (hprov.symm.trans ha)
    subst k
    have hx : m0.get? a = some m0.allocs[a] := Array.getElem?_eq_getElem hid
    obtain ⟨y, hy, hxy⟩ := hm a b _ hx hb
    obtain ⟨hb1, rfl⟩ := Array.getElem?_eq_some_iff.mp (show m1.allocs[b]? = some y from hy)
    have hlo : m1.allocs[b].addr ≤ m0.allocs[a].addr := hxy.lo
    have hhi : m0.allocs[a].addr + m0.allocs[a].data.size ≤
        m1.allocs[b].addr + m1.allocs[b].data.size := hxy.hi
    have hyp : m1.allocs[b].addr ≤ p.addr := by omega
    obtain ⟨m1', hst⟩ := store_ok_exists (mem := m1) (q := { p with prov := some b })
      (bytes := bs1) (al := al1) (k := b) hb1 hal (by omega) rfl (hxy.live hlv)
      (show m1.allocs[b].addr ≤ p.addr from hyp)
      (show p.addr + bs1.length ≤ m1.allocs[b].addr + m1.allocs[b].data.size by omega)
      (hxy.mutable hmut)
    refine ⟨m1', hst, ?_⟩
    rcases Ryo.Spec.Theorems.Memory.store_eq_ok hst with
      ⟨_, hl', _⟩ | ⟨k', hid', _, _, hprov', _, _, _, _, rfl⟩
    · exact absurd hl' (by omega)
    · have e' : k' = b := (Option.some.inj hprov').symm
      subst k'
      intro a' b' x' hx' hb'
      by_cases haa : a' = a
      · -- The stored-to L0 allocation.
        subst a'
        simp only [Memory.get?, Array.getElem?_set_self, Option.some.injEq] at hx'
        subst hx'
        have e2 : b' = b := Option.some.inj (hb'.symm.trans hb)
        subst b'
        refine ⟨_, Array.getElem?_set_self hb1, ?_⟩
        exact allocInj_store_self hxy hbs hlv (pa := p.addr) h1
          (Ryo.Spec.Theorems.foldl_set_size bs0 0 (p.addr - m0.allocs[a].addr) m0.allocs[a].data)
          (Ryo.Spec.Theorems.foldl_set_size bs1 0 (p.addr - m1.allocs[b].addr) m1.allocs[b].data)
          (Ryo.Spec.Theorems.foldl_set_getElem bs0 0 (p.addr - m0.allocs[a].addr)
            m0.allocs[a].data)
          (Ryo.Spec.Theorems.foldl_set_getElem bs1 0 (p.addr - m1.allocs[b].addr)
            m1.allocs[b].data)
      · simp only [Memory.get?] at hx'
        rw [Array.getElem?_set_ne hid (Ne.symm haa)] at hx'
        obtain ⟨y', hy', hxy'⟩ := hm a' b' x' hx' hb'
        by_cases hbb : b' = b
        · -- Another L0 allocation inside the stored-to R allocation.
          subst b'
          obtain ⟨_, rfl⟩ := Array.getElem?_eq_some_iff.mp (show m1.allocs[b]? = some y' from hy')
          refine ⟨_, Array.getElem?_set_self hb1, ?_⟩
          exact allocInj_store_other hxy' (pa := p.addr) (n := bs0.length) hyp
            (fun hl'' => hdisj a' x' hx' hl'' hb' haa) hlen.symm
            (Ryo.Spec.Theorems.foldl_set_size bs1 0 (p.addr - m1.allocs[b].addr)
              m1.allocs[b].data)
            (Ryo.Spec.Theorems.foldl_set_getElem bs1 0 (p.addr - m1.allocs[b].addr)
              m1.allocs[b].data)
        · -- Unrelated: R's allocation unchanged.
          refine ⟨y', ?_, hxy'⟩
          show (m1.allocs.set b _ hb1)[b']? = some y'
          rw [Array.getElem?_set]
          simp only [Ne.symm hbb, if_false]
          exact hy'

/-- Extending `ι` (an `Escape`: the L0 locals its object holds become mapped) keeps the
relation, given the newly mapped allocations' relation and that no live mapped allocation's
byte carries a provenance `ι` drops and `ι'` maps (a non-escaped local's provenance occurs
nowhere). -/
theorem MemInj.mono {ι ι' : Inj} {m0 m1 : Memory} (hm : MemInj ι m0 m1) (hle : ι.Le ι')
    (hnew : ∀ a b x, ι a = none → ι' a = some b → m0.get? a = some x →
      ∃ y, m1.get? b = some y ∧ AllocInj ι' x y)
    (hfresh : ∀ a' x i (hi : i < x.data.size), m0.get? a' = some x → x.live = true →
      ∀ f, x.data[i].provFrag = some f → ι f.prov = none → ι' f.prov = none) :
    MemInj ι' m0 m1 := by
  intro a b x hx hb
  cases hιa : ι a with
  | none => exact hnew a b x hιa hb hx
  | some b0 =>
    have e : some b0 = some b := (hle a b0 hιa).symm.trans hb
    cases e
    obtain ⟨y, hy, hxy⟩ := hm a _ x hx hιa
    exact ⟨y, hy,
      { lo := hxy.lo, hi := hxy.hi, live := hxy.live, mutable := hxy.mutable,
        bytes := fun hl i h0 h1 => ByteInj.mono hle (hxy.bytes hl i h0 h1)
          (fun f hf hn => hfresh a x i h0 hx hl f hf hn) }⟩

/-- A store into `Y` at `pa` (inside `Y`), disjoint from the live `x`, keeps `AllocInj`. -/
theorem allocInj_store_right {ι : Inj} {x Y : Allocation} {bs : List AbstractByte} {pa : Nat}
    (hxy : AllocInj ι x Y) (hp : Y.addr ≤ pa)
    (hd : x.live = true → x.size = 0 ∨ x.addr + x.size ≤ pa ∨ pa + bs.length ≤ x.addr) :
    AllocInj ι x { Y with data := ((bs.zipIdx).foldl (fun d (b, i) => d.set! (pa - Y.addr + i) b) Y.data) } := by
  have hs : ({ Y with data := (bs.zipIdx).foldl (fun d (b, i) => d.set! (pa - Y.addr + i) b) Y.data } :
      Allocation).size = Y.size :=
    foldl_set_size bs 0 (pa - Y.addr) Y.data
  refine { lo := hxy.lo, hi := ?_, live := hxy.live, mutable := hxy.mutable, bytes := ?_ }
  · rw [hs]; exact hxy.hi
  · intro hl i h0 h1
    dsimp only at h1 ⊢
    have hp0 := hp
    obtain ⟨Ya, hYa⟩ : ∃ v, Y.addr = v := ⟨_, rfl⟩
    obtain ⟨Xa, hXa⟩ : ∃ v, x.addr = v := ⟨_, rfl⟩
    have e1 := hxy.hi
    have e2 := hxy.lo
    have hd' := hd hl
    unfold Allocation.size at e1 hd'
    have hj : x.addr - Y.addr + i < Y.data.size := by omega
    have key := foldl_set_getElem bs 0 (pa - Y.addr) Y.data (x.addr - Y.addr + i)
    have hc : ¬(pa - Y.addr + 0 ≤ x.addr - Y.addr + i ∧
        x.addr - Y.addr + i < pa - Y.addr + 0 + bs.length ∧ x.addr - Y.addr + i < Y.data.size) := by
      clear key; simp only [hYa, hXa] at *
      obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le e2
      obtain ⟨q, rfl⟩ := Nat.exists_eq_add_of_le hp0
      simp only [Nat.add_sub_cancel_left, Nat.add_zero, Allocation.size] at *
      rcases hd' with h | h | h <;> (dsimp only [Size] at h e1 e2 hp0 ⊢; omega)
    rw [if_neg hc] at key
    have e := (Array.getElem?_eq_getElem h1).symm.trans (key.trans (Array.getElem?_eq_getElem hj))
    rw [Option.some.inj e]
    exact hxy.bytes hl i h0 hj

/-- R's store into an R allocation no mapped L0 allocation overlaps keeps the relation (a
private or escaped frame write that L0 doesn't see through `ι`). -/
theorem MemInj.store_right {ι : Inj} {m0 m1 m1' : Memory} (hm : MemInj ι m0 m1) {p : ThinPointer}
    {bs : List AbstractByte} {al : Align} (h : m1.store p bs al = .ok m1')
    (hapart : ∀ a b x, m0.get? a = some x → x.live = true → ι a = some b → p.prov = some b →
      x.size = 0 ∨ x.addr + x.size ≤ p.addr ∨ p.addr + bs.length ≤ x.addr) :
    MemInj ι m0 m1' := by
  rcases Memory.store_eq_ok h with ⟨_, _, rfl⟩ | ⟨id, hid, _, _, hprov, _, h1, _, _, rfl⟩
  · exact hm
  · intro a b x hx hb
    obtain ⟨y, hy, hxy⟩ := hm a b x hx hb
    by_cases hbi : b = id
    · rw [hbi] at hy hb ⊢
      unfold Memory.get? at hy
      obtain ⟨_, hy0⟩ := Array.getElem?_eq_some_iff.mp hy
      subst hy0
      refine ⟨_, ?_, allocInj_store_right hxy h1 (fun hl => hapart a id x hx hl hb hprov)⟩
      unfold Memory.get?
      first
        | exact Array.getElem?_set_self ..
        | simp only [Array.getElem?_set_self]
        | simp [Array.getElem?_set]
    · refine ⟨y, ?_, hxy⟩
      unfold Memory.get? at hy ⊢
      first
        | (simp only [Array.getElem?_set, if_neg (Ne.symm hbi)]; exact hy)
        | (rw [Array.getElem?_set_ne _ _ (Ne.symm hbi)]; exact hy)
        | simpa [Array.getElem?_set, Ne.symm hbi] using hy

/-- A new L0 allocation (a `StorageLive`d local, or one at function entry) mapped to none
keeps the relation. -/
theorem MemInj.push_left {ι : Inj} {m0 m1 : Memory} (hm : MemInj ι m0 m1) (x : Allocation)
    (hx : ι m0.allocs.size = none) :
    MemInj ι { allocs := m0.allocs.push x } m1 := by
  intro a b z hz hb
  by_cases ha : a = m0.allocs.size
  · rw [ha, hx] at hb
    cases hb
  · have hz' : m0.get? a = some z := by
      simpa [Memory.get?, Array.getElem?_push, ha] using hz
    exact hm a b z hz' hb

/-- A new R allocation (an `Escape` scope's object) keeps the relation. -/
theorem MemInj.push_right {ι : Inj} {m0 m1 : Memory} (hm : MemInj ι m0 m1) (y : Allocation)
    (hy : ∀ a, ι a ≠ some m1.allocs.size) :
    MemInj ι m0 { allocs := m1.allocs.push y } := by
  intro a b z hz hb
  obtain ⟨y', hy', h'⟩ := hm a b z hz hb
  refine ⟨y', ?_, h'⟩
  have hne : b ≠ m1.allocs.size := fun e => hy a (by rw [← e]; exact hb)
  simpa [Memory.get?, Array.getElem?_push, hne] using hy'

theorem dealloc_ok_aux {m m' : Memory} {p : ThinPointer} {k : AllocationKind} {n : Nat}
    {al : Align} (h : m.deallocate p k n al = .ok m') :
    ∃ id a, m.get? id = some a ∧ m' = { allocs := m.allocs.set! id { a with live := false } } := by
  rcases p with ⟨addr, _ | id⟩
  · exact absurd h (by intro e; cases e)
  cases hg : m.get? id with
  | none =>
    exfalso
    simp only [Memory.deallocate, hg] at h
    all_goals exact absurd h (by intro e; cases e)
  | some a =>
    refine ⟨id, a, hg, ?_⟩
    simp only [Memory.deallocate, hg] at h
    repeat' (split at h)
    all_goals first
      | exact (Except.ok.inj h).symm
      | exact absurd h (by intro e; cases e)

/-- L0 deallocating keeps the relation (only liveness of the L0 side changes). -/
theorem MemInj.dealloc_left {ι : Inj} {m0 m1 m0' : Memory} (hm : MemInj ι m0 m1)
    {p : ThinPointer} {k : AllocationKind} {n : Nat} {al : Align}
    (h : m0.deallocate p k n al = .ok m0') : MemInj ι m0' m1 := by
  obtain ⟨id, a0, hg, rfl⟩ := dealloc_ok_aux h
  have hid : id < m0.allocs.size := by
    unfold Memory.get? at hg
    obtain ⟨hh, _⟩ := Array.getElem?_eq_some_iff.mp hg
    exact hh
  intro c b x hx hb
  unfold Memory.get? at hx
  simp only [Array.set!, Array.getElem?_setIfInBounds] at hx
  by_cases hc : id = c
  · rw [← hc] at hx hb
    first
      | rw [if_pos rfl, if_pos hid] at hx
      | simp only [if_true, hid] at hx
      | simp [hid] at hx
    cases hx
    obtain ⟨y, hy, hxy⟩ := hm id b a0 hg hb
    exact ⟨y, hy,
      { lo := hxy.lo, hi := hxy.hi, live := fun hl => (by cases hl), mutable := hxy.mutable,
        bytes := fun hl => by cases hl }⟩
  · rw [if_neg hc] at hx
    exact hm c b x hx hb

/-! ### R's access with resolution -/

/-- `resolve_inj` from a successful `checkPtr` of the L0 pointer. -/
theorem resolve_inj_of_checkPtr {ι : Inj} {m0 : Memory} {st : Ryo.Vm.OpSem.State}
    (hm : MemInj ι m0 st.mem) {p0 p1 : ThinPointer} (hp : PtrInj ι p0 p1) {a b : AllocId}
    (ha : p0.prov = some a) (hb : ι a = some b) {n : Nat} (hn : n ≠ 0)
    {r : Option (AllocId × Nat)} (hc : m0.checkPtr p0 n = .ok r) :
    st.resolve p1 n = { p1 with prov := some b } := by
  have hp1 : p1.prov = some b := by
    have h2 := hp.2
    rw [ha] at h2
    simp only [ProvInj, hb] at h2
    exact h2
  rcases (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok).1 hc with
    ⟨hl, -⟩ | ⟨id, hid, -, hprov, hlv, h1, h2, -⟩
  · exact absurd hl hn
  have hia : id = a := Option.some.inj (hprov.symm.trans ha)
  rw [← hia] at hb
  obtain ⟨y, hy, hinj⟩ := hm id b _ (get?_of_lt hid) hb
  have hlo := hinj.lo
  have hhi := hinj.hi
  simp only [Allocation.size] at hhi
  have hlv1 := hinj.live hlv
  have hpa := hp.1
  have hf : st.fits p1.addr n b = true := by
    unfold Ryo.Vm.OpSem.State.fits
    rw [hy]
    simp only [Bool.and_eq_true, decide_eq_true_eq, Allocation.size]
    have h1' := h1; have h2' := h2
    rw [hpa] at h1' h2'
    simp only [hlv1, true_and]
    exact ⟨by omega, decide_eq_true (by omega)⟩
  have hres : st.resolve p1 n = p1 := by
    unfold Ryo.Vm.OpSem.State.resolve
    rw [hp1]
    show (if st.fits p1.addr n b = true then p1 else st.resolveExposed p1 n) = p1
    rw [if_pos hf]
  rw [hres]
  obtain ⟨ad, pv⟩ := p1
  cases hp1
  rfl

/-- R's access resolves a mapped pointer to the R allocation holding the L0 one: `resolve`
keeps the provenance when its allocation fits the range. -/
theorem resolve_inj {ι : Inj} {m0 : Memory} {st : Ryo.Vm.OpSem.State} (hm : MemInj ι m0 st.mem)
    {p0 p1 : ThinPointer} (hp : PtrInj ι p0 p1) {a b : AllocId} (ha : p0.prov = some a)
    (hb : ι a = some b) {n : Nat} (hn : n ≠ 0) (hok : m0.dereferenceable p0 n = .ok ()) :
    st.resolve p1 n = { p1 with prov := some b } := by
  obtain ⟨r, hc⟩ := checkPtr_ok_of_deref hok
  exact resolve_inj_of_checkPtr hm hp ha hb hn hc

/-- An L0 load (non-empty, so through a provenance `ι` maps) and R's `State.load` of a related
pointer: related bytes. -/
theorem stLoad_inj {ι : Inj} {m0 : Memory} {st : Ryo.Vm.OpSem.State} (hm : MemInj ι m0 st.mem)
    {p0 p1 : ThinPointer} (hp : PtrInj ι p0 p1) {n : Nat} (hn : n ≠ 0)
    (hmapped : ∀ a, p0.prov = some a → ι a ≠ none) {al : Align} {bs0 : List AbstractByte}
    (h : m0.load p0 n al = .ok bs0) :
    ∃ bs1, st.load p1 n = .ok bs1 ∧ BytesInj ι bs0 bs1 := by
  obtain ⟨id, hid, hprov, hlv, h1, h2, -⟩ := load_eq_ok_pos hn h
  cases hι : ι id with
  | none => exact absurd hι (hmapped id hprov)
  | some b =>
    have hc := (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok (mem := m0) (p := p0) (len := n)
      (r := some (id, p0.addr - m0.allocs[id].addr))).mpr
      (.inr ⟨id, hid, hn, hprov, hlv, h1, h2, rfl⟩)
    have hres := resolve_inj_of_checkPtr (st := st) hm hp hprov hι hn hc
    have hq : ({ p1 with prov := some b } : ThinPointer) = { p0 with prov := some b } := by
      have hpa := hp.1
      revert hpa
      cases p0; cases p1
      intro hpa
      simp only at hpa
      subst hpa
      rfl
    have halign : Align.one.isAligned p0.addr = true := by
      simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]
    obtain ⟨bs1, hl, hbs⟩ := load_inj hm hprov hι (al1 := Align.one) halign h
    refine ⟨bs1, ?_, hbs⟩
    unfold Ryo.Vm.OpSem.State.load
    rw [hres, hq, hl]
    rfl

end Ryo.Proofs.Lower
