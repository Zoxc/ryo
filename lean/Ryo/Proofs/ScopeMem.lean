/-
Ryo.Proofs.ScopeMem — R's scopes keep the memory part of the relation (`MemRel`: each live
allocation's bytes relate to the x86 bytes at its address), with the x86 state unchanged.

- `memRel_escape`: the new allocation holds the frame's bytes at `fp + off`, which `Rel`
  relates to the x86 bytes there.
- `memRel_storageEnd`: freed objects are no longer live; the kept ones' bytes in the range
  become `Uninit`, which relates to any byte, and the other allocations are unchanged.
-/
import Ryo.Proofs.Scope
import Ryo.Proofs.Inline.Mem

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

end Ryo.Proofs.ScopeMem
