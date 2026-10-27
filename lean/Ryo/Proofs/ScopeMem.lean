/-
Ryo.Proofs.ScopeMem — R's scopes keep the memory part of the relation (`MemRel`: each live
allocation's bytes relate to the x86 bytes at its address), with the x86 state unchanged.

- `memRel_escape`: the new allocation holds the frame's bytes at `fp + off`, which `Rel`
  relates to the x86 bytes there.
- `memRel_storageEnd`: freed objects are no longer live; the kept ones' bytes in the range
  become `Uninit`, which relates to any byte, and the other allocations are unchanged.
- The separation facts (`FrameSep` over a frame window `[lo, hi)`: `FrameOwn`, `FrameInit`,
  `MemDisjoint`, `InSpace`; see that section): kept by `Escape` in the window (`sep_escape`)
  and by `End` (`sep_storageEnd`), so by the scopes (`sep_foldlM`); they give `FrameApart` and
  `WrApart` (`FrameSep.frameApart`, `FrameSep.wrApart`). Across a call, island or handler
  (`FrameSep.extend`): from the environment's facts on the allocations it leaves
  (`AllocsAfter`, `MemDisjoint`, `InSpace`) and `FrameInit` after its writes
  (`frameInit_writeFrame`, `frameInit_writeRanges`). `Globals` from `MemRel`
  (`globals_of_memRel`); `Private` after the scopes from before them (`private_foldlM`).
-/
import Ryo.Proofs.Scope
import Ryo.Proofs.Inline.Mem
import Ryo.Proofs.Inline.Rip

namespace Ryo.Proofs.ScopeMem

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Proofs.Inline Ryo.Proofs.Scope

theorem memRel_escape {s s' : R.RState} {x : X86.State} {off : Int} {size align : Nat}
    (hr : RRel s x) (hm : MemRel s.st x) (h : R.escape s off size align = .ok s')
    (hb : -2 ^ 63 ≤ off ∧ off + size ≤ 2 ^ 63) : MemRel s'.st x := by
  rcases escape_ok h with rfl | ⟨bytes, a, -, hnn, haddr, hdata, -, hread, rfl⟩
  · exact hm
  intro id a' hg hl i hi
  simp only [Memory.get?, Array.getElem?_push] at hg
  split at hg
  · rename_i hid
    cases hg
    obtain ⟨hlen, hall⟩ := mapM_ok hread
    simp only [List.length_range] at hlen
    have hi' : i < size := by rw [hdata] at hi; simp at hi; omega
    have hb' := hall i (by simp; omega) (by omega)
    simp only [List.getElem_range] at hb'
    have := hr.rel.frame (off + i) (by omega) (by omega) _ hb'
    have hx : fpAddr x (off + i) = BitVec.ofNat 64 (a.addr + i) := by
      rw [fpAddr_add, BitVec.ofNat_add, haddr, ofNat_frameAddr _ _ hnn]
      simp only [fpAddr, hr.rbp]
    rw [hx] at this
    simp only [hdata, List.getElem_toArray]
    exact this
  · exact hm id a' hg hl i hi

theorem freeObjs_live : ∀ (es : List EscapedObj) (m : Memory) (id : AllocId) (a : Allocation),
    (R.freeObjs m es).get? id = some a → a.live = true → m.get? id = some a
  | [], _, _, _, h, _ => h
  | e :: es, m, id, a, h, hl => by
    have h1 := freeObjs_live es _ id a h hl
    revert h1
    show (match m.get? e.id with
      | some a => ({ allocs := m.allocs.set! e.id { a with live := false } } : Memory)
      | none => m).get? id = some a → m.get? id = some a
    split
    · rename_i a0 ha0
      intro h
      by_cases he : e.id = id
      · subst he
        simp only [Memory.get?, Array.set!_eq_setIfInBounds, Array.getElem?_setIfInBounds] at h ha0
        have hlt : e.id < m.allocs.size := (Array.getElem?_eq_some_iff.1 ha0).1
        simp only [hlt, ↓reduceIte, Option.some.injEq] at h
        subst h; simp at hl
      · simpa [Memory.get?, Array.set!_eq_setIfInBounds, Array.getElem?_setIfInBounds, he] using h
    · exact fun h => h

/-- Writing `Uninit` over frame bytes keeps `MemRel`: escaped bytes become `Uninit`, nothing
else in memory changes. -/
theorem memRel_writeUninit {st0 st' : OpSem.State} {x : X86.State} {off : Int} {n : Nat}
    (hm : MemRel st0 x) (hw : st0.writeFrame off (List.replicate n .uninit) = .ok st') :
    MemRel st' x := by
  unfold OpSem.State.writeFrame at hw
  cases hwe : st0.writeEscaped off (List.replicate n .uninit) with
  | error e => simp [hwe, bind, Except.bind] at hw
  | ok m' =>
  simp only [hwe, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  have hesc := writeEscaped_spec hwe
  intro id a' hg hl i hi
  obtain ⟨a0, ha0, hae, hsz, hj⟩ := hesc.2 id a' hg
  have hl0 : a0.live = true := by rw [hae] at hl; exact hl
  by_cases hh : ∃ p ∈ (List.replicate n AbstractByte.uninit).zipIdx, Hits st0 off p id i
  · obtain ⟨q, hq, -, hv⟩ := (hj i).2 hh (by rw [← hsz]; exact hi)
    obtain ⟨hqk, hq1⟩ := mem_zipIdx hq
    simp only [List.getElem_replicate] at hq1
    rw [Array.getElem?_eq_getElem hi, Option.some.injEq] at hv
    rw [hv, hq1]
    trivial
  · have hd := (hj i).1 fun p hp hph => hh ⟨p, hp, hph⟩
    rw [Array.getElem?_eq_getElem hi, Array.getElem?_eq_getElem (by rw [← hsz]; exact hi),
      Option.some.injEq] at hd
    have := hm id a0 ha0 hl0 i (by rw [← hsz]; exact hi)
    have haddr : a'.addr = a0.addr := by rw [hae]
    simp only [hd, haddr]
    exact this

/-- Freeing objects keeps `MemRel` (fewer live allocations). -/
theorem memRel_free {st : OpSem.State} {x : X86.State} (hm : MemRel st x) (es : List EscapedObj)
    (kept : List EscapedObj) : MemRel { st with mem := R.freeObjs st.mem es, escaped := kept } x :=
  fun id a hg hl i hi => hm id a (freeObjs_live es st.mem id a hg hl) hl i hi

theorem memRel_storageEnd {s s' : R.RState} {x : X86.State} {off : Int} {size : Nat}
    (hm : MemRel s.st x) (h : R.storageEnd s off size = .ok s') : MemRel s'.st x := by
  obtain ⟨st', hw, rfl⟩ := storageEnd_ok h
  exact memRel_writeUninit (memRel_free hm _ _) hw

theorem memRel_applyScope {s s' : R.RState} {x : X86.State} {sc : R.Scope} (hr : RRel s x)
    (hm : MemRel s.st x) (hsz : sc.size < 2 ^ 62) (h : R.applyScope s sc = .ok s') :
    MemRel s'.st x := by
  unfold R.applyScope at h
  split at h
  · have := toInt_bounds sc.frameOffset
    exact memRel_escape hr hm h ⟨by omega, by omega⟩
  · exact memRel_storageEnd hm h
  · cases h; exact hm

/-- The scopes before an instruction keep `RRel` and `MemRel` (scopes of size below `2^62`). -/
theorem memRel_foldlM {x : X86.State} : ∀ (l : List R.Scope) {s s' : R.RState},
    (∀ sc ∈ l, sc.size < 2 ^ 62) → RRel s x → MemRel s.st x →
    l.foldlM R.applyScope s = .ok s' → RRel s' x ∧ MemRel s'.st x
  | [], s, s', _, hr, hm, h => by cases h; exact ⟨hr, hm⟩
  | sc :: l, s, s', hs, hr, hm, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      exact memRel_foldlM l (fun sc' h' => hs sc' (List.mem_cons_of_mem _ h'))
        (rrel_applyScope hr h1) (memRel_applyScope hr hm (hs sc (List.mem_cons_self ..)) h1) h

/-! ### The separation facts

`FrameApart` (an initialized private frame byte isn't at an x86 address in a live allocation),
`WrApart` (nor is a byte a `load` writes) and `MemDisjoint` alone aren't kept by the scopes:
`End` makes the bytes of the objects it frees private again, and nothing in them says that no
other live allocation is at those addresses. (`FrameApart` over all private bytes, as it was
first stated, doesn't hold at all once a live allocation lies outside the escaped objects:
every x86 address is `fp + o` for some private `o`.) What is kept is `FrameSep lo hi`, over a
frame window `[lo, hi)` (in the code `[-F, K)`, `K` the end of the incoming area): the
window's addresses are in a live allocation only as an escaped object's own byte (`FrameOwn`),
initialized private bytes lie in the window (`FrameInit`), live allocations are disjoint
(`MemDisjoint`) and within the 64-bit address space (`InSpace`). `FrameSep` gives `FrameApart`,
and `WrApart` of a write inside the window to private bytes (`FrameSep.frameApart`,
`FrameSep.wrApart`). `Escape` keeps it when its range lies in the window and the window's
addresses `fp + o` fit in 64 bits (`Window`, `ScopesIn`): the new allocation is at the escaped
offsets, and `escape` checked it overlaps no live allocation. `End` keeps it as its freed
allocations are no longer live (`freeObjs_dead`).

`Globals` is kept as a consequence of `MemRel` (`globals_of_memRel`: its `mem` field holds of
any state `MemRel` relates; the rest doesn't mention the state).

`Private op vals` (the bytes an instruction writes are in no escaped object) is not a state
invariant: an `Escape` before the instruction may escape them. `private_foldlM`: it holds
after the scopes if it held before and no `Escape` scope there overlaps the bytes. -/

/-- The x86 addresses of frame offsets in `[lo, hi)` are in a live allocation only as a byte of
an escaped object's own allocation. -/
def FrameOwn (lo hi : Int) (st : OpSem.State) (x : X86.State) : Prop :=
  ∀ id a o, st.mem.get? id = some a → a.live = true → lo ≤ o → o < hi →
    (fpAddr x o - BitVec.ofNat 64 a.addr).toNat < a.size →
    ∃ e ∈ st.escaped, e.off ≤ o ∧ o < e.off + e.size ∧ e.id = id

/-- Initialized private frame bytes lie in `[lo, hi)`. -/
def FrameInit (lo hi : Int) (st : OpSem.State) : Prop :=
  ∀ o, st.escapedAt o = none → st.frame o ≠ .uninit → lo ≤ o ∧ o < hi

/-- Live allocations end within the 64-bit address space. -/
def InSpace (st : OpSem.State) : Prop :=
  ∀ id a, st.mem.get? id = some a → a.live = true → a.addr + a.size ≤ 2 ^ 64

/-- The separation facts over the frame window `[lo, hi)` (see above). -/
structure FrameSep (lo hi : Int) (st : OpSem.State) (x : X86.State) : Prop where
  own : FrameOwn lo hi st x
  init : FrameInit lo hi st
  dis : MemDisjoint st
  space : InSpace st

/-- The frame window: offsets within `[-2^63, 2^63)`, addresses `fp + o` within 64 bits. -/
structure Window (lo hi : Int) (fp : Nat) : Prop where
  lo_ge : -2 ^ 63 ≤ lo
  hi_le : hi ≤ 2 ^ 63
  top : (fp : Int) + hi ≤ 2 ^ 64

/-- Each scope's range lies in the window (a fact of the decoded code). -/
def ScopesIn (lo hi : Int) (l : List R.Scope) : Prop :=
  ∀ sc ∈ l, lo ≤ sc.frameOffset.toInt ∧ sc.frameOffset.toInt + sc.size ≤ hi

theorem escapedAt_none {st : OpSem.State} {o : Int} (h : st.escapedAt o = none) :
    ∀ e ∈ st.escaped, ¬ (e.off ≤ o ∧ o < e.off + e.size) := by
  intro e he hc
  unfold OpSem.State.escapedAt at h
  have := List.find?_eq_none.1 h e he
  simp [hc] at this

theorem FrameSep.frameApart {lo hi : Int} {st : OpSem.State} {x : X86.State} (h : FrameSep lo hi st x) :
    FrameApart st x := by
  intro id a o hg hl he hu _ _ hin
  obtain ⟨h1, h2⟩ := h.init o he hu
  obtain ⟨e, hem, ho1, ho2, -⟩ := h.own id a o hg hl h1 h2 hin
  exact escapedAt_none he e hem ⟨ho1, ho2⟩

theorem FrameSep.wrApart {lo hi : Int} {st : OpSem.State} {x : X86.State} {f : Full.Opcode}
    {vals : Operands} (h : FrameSep lo hi st x) (hp : Private f vals st)
    (hw : ∀ r ∈ wranges f vals, lo ≤ r.1 ∧ r.1 + r.2 ≤ hi) : WrApart f vals st x := by
  intro r hr o ho id a hg hl hin
  have ho' := ho
  simp only [inRange, decide_eq_true_eq] at ho'
  have hrw := hw r hr
  obtain ⟨e, hem, h1, h2, -⟩ := h.own id a o hg hl (by omega) (by omega) hin
  exact escapedAt_none (hp r hr o ho) e hem ⟨h1, h2⟩

theorem FrameSep.congr {lo hi : Int} {st : OpSem.State} {x y : X86.State}
    (hb : y.reg .rbp = x.reg .rbp) (h : FrameSep lo hi st x) : FrameSep lo hi st y := by
  have hfp : ∀ o, fpAddr y o = fpAddr x o := fun o => by simp [fpAddr, hb]
  exact ⟨fun id a o hg hl h1 h2 hin => h.own id a o hg hl h1 h2 (by rw [← hfp]; exact hin),
    h.init, h.dis, h.space⟩

/-! #### `Escape` -/

theorem ofNat_add_eq {A B i j : Nat} (hA : A + i < 2 ^ 64) (hB : B + j < 2 ^ 64)
    (h : BitVec.ofNat 64 (A + i) = BitVec.ofNat 64 (B + j)) : A + i = B + j := by
  have := congrArg BitVec.toNat h
  simp only [BitVec.toNat_ofNat] at this
  rwa [Nat.mod_eq_of_lt hA, Nat.mod_eq_of_lt hB] at this

/-- A successful `escape` that adds an object checked that its range overlaps no live
allocation. -/
theorem escape_fresh {s s' : R.RState} {off : Int} {size align : Nat}
    (h : R.escape s off size align = .ok s') :
    s' = s ∨ ∀ a ∈ s.st.mem.allocs, a.live = true →
      a.overlaps ((s.fp : Int) + off).toNat size = false := by
  unfold R.escape at h
  simp only at h
  split at h
  · left; cases h; rfl
  right
  split at h
  · cases h
  unfold R.frameAddr at h
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
  intro a ha hl
  cases ho : a.overlaps ((s.fp : Int) + off).toNat size
  · rfl
  · exfalso; apply hov
    exact Array.any_eq_true'.2 ⟨a, ha, by simp [hl, ho]⟩

theorem sep_escape {lo hi : Int} {s s' : R.RState} {x : X86.State} {off : Int} {size align : Nat}
    (hr : RRel s x) (hs : FrameSep lo hi s.st x) (hw : Window lo hi s.fp) (hlo : lo ≤ off)
    (hhi : off + size ≤ hi) (h : R.escape s off size align = .ok s') : FrameSep lo hi s'.st x := by
  rcases escape_ok h with rfl | ⟨bytes, a, -, hnn, haddr, hdata, -, hread, rfl⟩
  · exact hs
  rcases escape_fresh h with heq | hfresh
  · exfalso
    have := congrArg (fun t : R.RState => t.st.mem.allocs.size) heq
    simp at this
  have hlen := readFrame_length hread
  have hasz : a.size = size := by simp [Allocation.size, hdata, hlen]
  have hA : BitVec.ofNat 64 a.addr = fpAddr x off := by
    rw [haddr, ofNat_frameAddr _ _ hnn]; simp only [fpAddr, hr.rbp]
  have hwlo := hw.lo_ge
  have hwhi := hw.hi_le
  have htop := hw.top
  have hend : a.addr + size ≤ 2 ^ 64 := by omega
  have hget : ∀ id a', ({ allocs := s.st.mem.allocs.push a } : Memory).get? id = some a' →
      (id = s.st.mem.allocs.size ∧ a' = a) ∨
        (a' ∈ s.st.mem.allocs ∧ s.st.mem.get? id = some a') := by
    intro id a' hg
    simp only [Memory.get?, Array.getElem?_push] at hg ⊢
    split at hg
    · left; cases hg; exact ⟨by assumption, rfl⟩
    · right; exact ⟨Array.mem_of_getElem? hg, hg⟩
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro id a' o hg hl h1 h2 hin
    rcases hget id a' hg with ⟨rfl, ha⟩ | ⟨-, hg0⟩
    · rw [ha, hA, fpAddr_sub, hasz, BitVec.toNat_ofInt] at hin
      refine ⟨_, List.mem_append_right _ (List.mem_singleton_self _), ?_, ?_, rfl⟩ <;>
        simp only <;> omega
    · obtain ⟨e, he, ho1, ho2, rfl⟩ := hs.own id a' o hg0 hl h1 h2 hin
      exact ⟨e, List.mem_append_left _ he, ho1, ho2, rfl⟩
  · intro o he hu
    refine hs.init o ?_ hu
    unfold OpSem.State.escapedAt at he ⊢
    simp only [List.find?_append, Option.or_eq_none_iff] at he
    exact he.1
  · intro id1 a1 id2 a2 i j hg1 hg2 hl1 hl2 hi hj heq
    have hov : ∀ (b : Allocation) (j' : Nat), b ∈ s.st.mem.allocs → b.live = true →
        j' < b.data.size → b.addr + b.data.size ≤ 2 ^ 64 → ∀ i' : Nat, i' < size →
        BitVec.ofNat 64 (a.addr + i') = BitVec.ofNat 64 (b.addr + j') → False := by
      intro b j' hb hbl hj' hbs i' hi' he
      have hab := ofNat_add_eq (by omega) (by omega) he
      have hf := hfresh b hb hbl
      rw [← haddr] at hf
      have h1 : b.data.size ≠ 0 := by omega
      have h2 : size ≠ 0 := by omega
      simp only [Allocation.overlaps, Allocation.size] at hf
      simp only [h1, h2, beq_iff_eq, or_self, ↓reduceIte, Bool.not_eq_false', Bool.or_eq_true,
        decide_eq_true_eq] at hf
      have hf' : b.addr + b.data.size ≤ a.addr ∨ a.addr + size ≤ b.addr := by
        rcases hf with hf | hf
        · exact Or.inl (of_decide_eq_true hf)
        · exact Or.inr hf
      omega
    have hasz' : a.data.size = size := hasz
    have hend' : a.addr + a.data.size ≤ 2 ^ 64 := by omega
    rcases hget id1 a1 hg1 with ⟨hid1, ha1⟩ | ⟨hm1, hg1'⟩ <;>
      rcases hget id2 a2 hg2 with ⟨hid2, ha2⟩ | ⟨hm2, hg2'⟩
    · refine ⟨hid1.trans hid2.symm, ?_⟩
      rw [ha1] at hi heq
      rw [ha2] at hj heq
      have key : ∀ i' j' : Nat, i' < a.data.size → j' < a.data.size →
          BitVec.ofNat 64 (a.addr + i') = BitVec.ofNat 64 (a.addr + j') → i' = j' := by
        intro i' j' hi' hj' he
        have := ofNat_add_eq (by omega) (by omega) he
        omega
      exact key i j hi hj heq
    · rw [ha1] at hi heq
      exact (hov a2 j hm2 hl2 hj (hs.space id2 a2 hg2' hl2) i (by rw [← hasz']; exact hi)
        heq).elim
    · rw [ha2] at hj heq
      exact (hov a1 i hm1 hl1 hi (hs.space id1 a1 hg1' hl1) j (by rw [← hasz']; exact hj)
        heq.symm).elim
    · exact hs.dis id1 a1 id2 a2 i j hg1' hg2' hl1 hl2 hi hj heq
  · intro id a' hg hl
    rcases hget id a' hg with ⟨-, ha⟩ | ⟨-, hg0⟩
    · rw [ha, hasz]; exact hend
    · exact hs.space id a' hg0 hl

/-! #### `End` -/

theorem freeObjs_dead : ∀ (es : List EscapedObj) (m : Memory) (e : EscapedObj), e ∈ es →
    ∀ a, (R.freeObjs m es).get? e.id = some a → a.live = false
  | [], _, _, he, _, _ => by simp at he
  | e0 :: es, m, e, he, a, h => by
    cases hl : a.live
    · rfl
    exfalso
    rcases List.mem_cons.1 he with rfl | he
    · have h1 := freeObjs_live es _ e.id a h hl
      revert h1
      show (match m.get? e.id with
        | some a => ({ allocs := m.allocs.set! e.id { a with live := false } } : Memory)
        | none => m).get? e.id = some a → False
      split
      · rename_i a0 ha0
        intro h1
        have hlt : e.id < m.allocs.size := (Array.getElem?_eq_some_iff.1 ha0).1
        simp only [Memory.get?, Array.set!_eq_setIfInBounds, Array.getElem?_setIfInBounds,
          hlt, ↓reduceIte, Option.some.injEq] at h1
        subst h1; simp at hl
      · rename_i hn
        intro h1; rw [hn] at h1; cases h1
    · have := freeObjs_dead es _ e he a h
      rw [hl] at this; cases this

/-- A live allocation after `End` was live before, at the same address and size, and isn't
one of the freed objects'. -/
theorem storageEnd_alloc {s s' : R.RState} {off : Int} {size : Nat}
    (h : R.storageEnd s off size = .ok s') {id : AllocId} {a : Allocation}
    (hg : s'.st.mem.get? id = some a) (hl : a.live = true) :
    ∃ a0, s.st.mem.get? id = some a0 ∧ a0.live = true ∧ a.addr = a0.addr ∧ a.size = a0.size ∧
      ∀ e ∈ s.st.escaped, e.id = id → e ∈ s'.st.escaped := by
  obtain ⟨st', hw, rfl⟩ := storageEnd_ok h
  generalize hcov : (fun e : EscapedObj => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size))
    = cov at hw
  generalize hst1 : ({ s.st with
        mem := R.freeObjs s.st.mem (s.st.escaped.filter cov),
        escaped := s.st.escaped.filter (not ∘ cov) } : OpSem.State) = st1 at hw
  unfold OpSem.State.writeFrame at hw
  cases hwe : st1.writeEscaped off (List.replicate size AbstractByte.uninit) with
  | error e => simp [hwe, bind, Except.bind] at hw
  | ok m' =>
  simp only [hwe, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  obtain ⟨a0, ha0, hae, hsz, -⟩ := (writeEscaped_spec hwe).2 id a hg
  have hl0 : a0.live = true := by rw [hae] at hl; exact hl
  subst hst1
  refine ⟨a0, freeObjs_live _ _ id a0 ha0 hl0, hl0, by rw [hae], hsz, fun e he hid => ?_⟩
  simp only [List.mem_filter, Function.comp_apply]
  refine ⟨he, ?_⟩
  cases hc : cov e
  · rfl
  · exfalso
    have := freeObjs_dead _ s.st.mem e (List.mem_filter.2 ⟨he, hc⟩) a0 (hid ▸ ha0)
    rw [hl0] at this; cases this

theorem storageEnd_init {lo hi : Int} {s s' : R.RState} {off : Int} {size : Nat}
    (hfi : FrameInit lo hi s.st) (h : R.storageEnd s off size = .ok s') :
    FrameInit lo hi s'.st := by
  obtain ⟨st', hw, rfl⟩ := storageEnd_ok h
  generalize hcov : (fun e : EscapedObj => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size))
    = cov at hw
  generalize hst1 : ({ s.st with
        mem := R.freeObjs s.st.mem (s.st.escaped.filter cov),
        escaped := s.st.escaped.filter (not ∘ cov) } : OpSem.State) = st1 at hw
  unfold OpSem.State.writeFrame at hw
  cases hwe : st1.writeEscaped off (List.replicate size AbstractByte.uninit) with
  | error e => simp [hwe, bind, Except.bind] at hw
  | ok m' =>
  simp only [hwe, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  intro o he hu
  have he1 : st1.escapedAt o = none := he
  simp only [OpSem.State.privateIn, List.length_replicate, he1, Option.isNone_none,
    Bool.and_true] at hu
  by_cases hr : off ≤ o ∧ o < off + size
  · exfalso
    simp only [hr, and_self, decide_true, ↓reduceIte, ne_eq] at hu
    apply hu
    simp only [List.getD_eq_getElem?_getD, List.getElem?_replicate]
    split <;> rfl
  · simp only [hr, decide_false, Bool.false_eq_true, ↓reduceIte] at hu
    subst hst1
    refine hfi o ?_ hu
    cases hs : s.st.escapedAt o with
    | none => rfl
    | some e =>
      exfalso
      have hc : (not ∘ cov) e = true := by
        obtain ⟨-, h1, h2⟩ := escapedAt_some hs
        subst hcov
        simp only [Function.comp_apply, Bool.not_eq_eq_eq_not, Bool.not_true, decide_eq_false_iff_not]
        intro hh; exact hr ⟨by omega, by omega⟩
      have := find?_filter_of_some (q := not ∘ cov) hs hc
      unfold OpSem.State.escapedAt at he1
      simp only [he1] at this; cases this

theorem sep_storageEnd {lo hi : Int} {s s' : R.RState} {x : X86.State} {off : Int} {size : Nat}
    (hs : FrameSep lo hi s.st x) (h : R.storageEnd s off size = .ok s') : FrameSep lo hi s'.st x := by
  refine ⟨fun id a o hg hl h1 h2 hin => ?_, storageEnd_init hs.init h, ?_, ?_⟩
  · obtain ⟨a0, hg0, hl0, had, hsz, hk⟩ := storageEnd_alloc h hg hl
    rw [had, hsz] at hin
    obtain ⟨e, hem, ho1, ho2, rfl⟩ := hs.own id a0 o hg0 hl0 h1 h2 hin
    exact ⟨e, hk e hem rfl, ho1, ho2, rfl⟩
  · intro id1 a1 id2 a2 i j hg1 hg2 hl1 hl2 hi hj heq
    obtain ⟨b1, hb1, hm1, had1, hsz1, -⟩ := storageEnd_alloc h hg1 hl1
    obtain ⟨b2, hb2, hm2, had2, hsz2, -⟩ := storageEnd_alloc h hg2 hl2
    rw [had1, had2] at heq
    exact hs.dis id1 b1 id2 b2 i j hb1 hb2 hm1 hm2 (hsz1 ▸ hi) (hsz2 ▸ hj) heq
  · intro id a hg hl
    obtain ⟨a0, hg0, hl0, had, hsz, -⟩ := storageEnd_alloc h hg hl
    rw [had, hsz]; exact hs.space id a0 hg0 hl0

/-! #### Scopes -/

theorem sep_applyScope {lo hi : Int} {s s' : R.RState} {x : X86.State} {sc : R.Scope}
    (hr : RRel s x) (hs : FrameSep lo hi s.st x) (hw : Window lo hi s.fp)
    (hin : lo ≤ sc.frameOffset.toInt ∧ sc.frameOffset.toInt + sc.size ≤ hi)
    (h : R.applyScope s sc = .ok s') : FrameSep lo hi s'.st x := by
  unfold R.applyScope at h
  split at h
  · exact sep_escape hr hs hw hin.1 hin.2 h
  · exact sep_storageEnd hs h
  · cases h; exact hs

/-- The scopes keep `RRel` and `FrameSep` (scopes in the window). -/
theorem sep_foldlM {lo hi : Int} {x : X86.State} : ∀ (l : List R.Scope) {s s' : R.RState},
    ScopesIn lo hi l → Window lo hi s.fp → RRel s x → FrameSep lo hi s.st x →
    l.foldlM R.applyScope s = .ok s' → RRel s' x ∧ FrameSep lo hi s'.st x
  | [], s, s', _, _, hr, hs, h => by cases h; exact ⟨hr, hs⟩
  | sc :: l, s, s', hl, hw, hr, hs, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      have hfp : s1.fp = s.fp := (applyScope_keeps h1).fp
      exact sep_foldlM l (fun sc' h' => hl sc' (List.mem_cons_of_mem _ h')) (hfp ▸ hw)
        (rrel_applyScope hr h1) (sep_applyScope hr hs hw (hl sc (List.mem_cons_self ..)) h1) h

/-! #### `Globals` -/

theorem load_ok_align {st : OpSem.State} {p : ThinPointer} {n : Nat} {al : Align}
    {bs : List AbstractByte} (hn : n ≠ 0) (h : st.load p n al = .ok bs) :
    ∃ id a, st.mem.get? id = some a ∧ a.live = true ∧ a.addr ≤ p.addr ∧
      p.addr + n ≤ a.addr + a.size ∧
      bs = (a.data.extract (p.addr - a.addr) (p.addr - a.addr + n)).toList := by
  unfold OpSem.State.load at h
  rw [liftOutcome_ok] at h
  have hra := resolve_addr st p n
  generalize st.resolve p n = p' at h hra
  rw [← hra]
  unfold Memory.load at h
  simp only [bind, Except.bind] at h
  split at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  · simp only [pure, Except.pure] at h
    cases hc : st.mem.checkPtr p' n with
    | error e => simp [hc] at h
    | ok r =>
      obtain ⟨id, a, ha, hl, h1, h2, rfl⟩ := checkPtr_ok hn hc
      simp only [hc, Except.ok.injEq, getElem!_of_get? ha] at h
      exact ⟨id, a, ha, hl, h1, h2, h.symm⟩

/-- `Globals` holds of any state `MemRel` relates, given its layout part (which doesn't mention
the state). -/
theorem globals_of_memRel {ctx : X86.Ctx} {ρ : R.Addrs} {st0 st : OpSem.State} {x0 x : X86.State}
    (hg : Globals ctx ρ st0 x0) (hm : MemRel st x) : Globals ctx ρ st x := by
  refine ⟨hg.const, hg.data, hg.sym, fun p bs hl => ?_⟩
  obtain ⟨id, a, hga, hlv, h1, h2, rfl⟩ := load_ok_align (by decide) hl
  have := bytesRel_alloc hm hga hlv (off := p.addr - a.addr) (n := 8) (by omega)
  rwa [Nat.add_sub_cancel' h1] at this

/-! #### `Private` -/

theorem writeFrame_escaped {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') : st'.escaped = st.escaped := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h; rfl

/-- The scopes keep the offsets `S` out of every escaped object if no `Escape` among them
overlaps `S`. -/
theorem escFree_foldlM {S : Int → Prop} : ∀ (l : List R.Scope) {s s' : R.RState},
    (∀ sc ∈ l, ∀ al, sc.kind = .escape al → ∀ o, S o →
      ¬ (sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size)) →
    (∀ o, S o → s.st.escapedAt o = none) →
    l.foldlM R.applyScope s = .ok s' → ∀ o, S o → s'.st.escapedAt o = none
  | [], s, s', _, hs, h => by cases h; exact hs
  | sc :: l, s, s', hl, hs, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      refine escFree_foldlM l (fun sc' h' => hl sc' (List.mem_cons_of_mem _ h')) ?_ h
      intro o ho
      have hs0 := hs o ho
      unfold R.applyScope at h1
      split at h1
      · rename_i al hk
        rcases escape_ok h1 with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
        · exact hs0
        · have hn := hl sc (List.mem_cons_self ..) al hk o ho
          unfold OpSem.State.escapedAt at hs0 ⊢
          simp only [List.find?_append, hs0, Option.none_or]
          simp only [List.find?_cons, List.find?_nil]
          split
          · rename_i hd; simp only [decide_eq_true_eq] at hd; exact absurd hd hn
          · rfl
      · obtain ⟨st', hw, rfl⟩ := storageEnd_ok h1
        unfold OpSem.State.escapedAt at hs0 ⊢
        rw [writeFrame_escaped hw]
        exact find?_filter_of_none hs0
      · cases h1; exact hs0

/-- `Private` after the scopes: it held before, and no `Escape` there overlaps the bytes. -/
theorem private_foldlM {f : Full.Opcode} {vals : Operands} (l : List R.Scope) {s s' : R.RState}
    (hesc : ∀ sc ∈ l, ∀ al, sc.kind = .escape al → ∀ r ∈ wranges f vals, ∀ o,
      inRange o r = true → ¬ (sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size))
    (hp : Private f vals s.st) (h : l.foldlM R.applyScope s = .ok s') : Private f vals s'.st :=
  fun r hr o ho => escFree_foldlM (S := fun o => ∃ r ∈ wranges f vals, inRange o r = true) l
    (fun sc hsc al hk o ⟨r, hr, ho⟩ => hesc sc hsc al hk r hr o ho)
    (fun o ⟨r, hr, ho⟩ => hp r hr o ho) h o ⟨r, hr, ho⟩

/-! #### Across calls, islands and handlers

A handler, callee or template may create allocations (and free them), and writes frame bytes:
the frame separation after it is not a consequence of the relations alone. `FrameSep.extend`
gives it from facts of two kinds. The environment's (contract side, trusted where the code
doesn't establish them): each live allocation afterwards is either one that was live before at
the same address and size, or it lies off the window's addresses (`AllocsAfter`: the allocator
doesn't hand out the frame), and the live allocations are disjoint and in the address space
(`MemDisjoint`, `InSpace`). The frame's: the escaped objects are unchanged and the initialized
private bytes stay in the window (`FrameInit`; for the answer's writes, `frameInit_writeFrame`
and `frameInit_writeRanges` when the written ranges lie in the window, as the outgoing area
`[-F, -F + n)` and the `Lend` extents do). -/

/-- The live allocations of `st'` are live ones of `st` (same address and size) or off the
window's addresses. -/
def AllocsAfter (lo hi : Int) (st st' : OpSem.State) (x : X86.State) : Prop :=
  ∀ id a, st'.mem.get? id = some a → a.live = true →
    (∃ a0, st.mem.get? id = some a0 ∧ a0.live = true ∧ a0.addr = a.addr ∧ a0.size = a.size) ∨
    ∀ o, lo ≤ o → o < hi → ¬ ((fpAddr x o - BitVec.ofNat 64 a.addr).toNat < a.size)

theorem FrameSep.extend {lo hi : Int} {st st' : OpSem.State} {x x' : X86.State}
    (hs : FrameSep lo hi st x) (hb : x'.reg .rbp = x.reg .rbp) (hesc : st'.escaped = st.escaped)
    (hal : AllocsAfter lo hi st st' x) (hinit : FrameInit lo hi st') (hdis : MemDisjoint st')
    (hsp : InSpace st') : FrameSep lo hi st' x' := by
  have hfp : ∀ o, fpAddr x' o = fpAddr x o := fun o => by simp [fpAddr, hb]
  refine ⟨fun id a o hg hl h1 h2 hin => ?_, hinit, hdis, hsp⟩
  rw [hfp] at hin
  rcases hal id a hg hl with ⟨a0, hg0, hl0, hadd, hsz⟩ | hoff
  · rw [← hadd, ← hsz] at hin
    obtain ⟨e, he, ho1, ho2, hid⟩ := hs.own id a0 o hg0 hl0 h1 h2 hin
    exact ⟨e, hesc ▸ he, ho1, ho2, hid⟩
  · exact absurd hin (hoff o h1 h2)

/-- A frame write inside the window keeps `FrameInit`. -/
theorem frameInit_writeFrame {lo hi : Int} {st st' : OpSem.State} {off : Int}
    {bs : List AbstractByte} (hfi : FrameInit lo hi st) (h : st.writeFrame off bs = .ok st')
    (hlo : lo ≤ off) (hhi : off + bs.length ≤ hi) : FrameInit lo hi st' := by
  have hesc := writeFrame_escaped h
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
  simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
  subst h
  intro o he hu
  have he1 : st.escapedAt o = none := by
    unfold OpSem.State.escapedAt at he ⊢; rw [← hesc]; exact he
  simp only [OpSem.State.privateIn, he1, Option.isNone_none, Bool.and_true] at hu
  by_cases hr : off ≤ o ∧ o < off + bs.length
  · omega
  · simp only [hr, decide_false, Bool.false_eq_true, ↓reduceIte] at hu
    exact hfi o he1 hu

theorem foldlM_inv {α σ : Type} (P : σ → Prop) (Q : α → Prop) (f : σ → α → OpSem.M σ)
    (hf : ∀ s a s', P s → Q a → f s a = .ok s' → P s') :
    ∀ (l : List α) (s s' : σ), P s → (∀ a ∈ l, Q a) → l.foldlM f s = .ok s' → P s'
  | [], s, s', hs, _, h => by cases h; exact hs
  | a :: l, s, s', hs, hl, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : f s a with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      exact foldlM_inv P Q f hf l s1 s' (hf s a s1 hs (hl a (List.mem_cons_self ..)) h1)
        (fun b hb => hl b (List.mem_cons_of_mem _ hb)) h

/-- The answer's writes over ranges inside the window keep `FrameInit`. -/
theorem frameInit_writeRanges {lo hi : Int} {st st' : OpSem.State} {rs : List (Int × Nat)}
    {new : List (List AbstractByte)} (hfi : FrameInit lo hi st)
    (hin : ∀ r ∈ rs, lo ≤ r.1 ∧ r.1 + r.2 ≤ hi) (h : R.writeRanges st rs new = .ok st') :
    FrameInit lo hi st' := by
  unfold R.writeRanges at h
  split at h
  · cases h; exact hfi
  split at h
  · cases h
  simp only at h
  refine foldlM_inv (FrameInit lo hi) (fun p : (Int × Nat) × List AbstractByte =>
    lo ≤ p.1.1 ∧ p.1.1 + p.1.2 ≤ hi) _ ?_ _ st st' hfi
    (fun p hp => hin p.1 (List.of_mem_zip hp).1) h
  rintro s0 ⟨⟨off, n⟩, bs⟩ s1 h0 ⟨hp1, hp2⟩ hst
  simp only at hst hp1 hp2
  split at hst
  · cases hst
  · rename_i hlen
    have hlen' : bs.length = n := by simpa using hlen
    exact frameInit_writeFrame h0 hst hp1 (by rw [hlen']; exact hp2)

end Ryo.Proofs.ScopeMem
