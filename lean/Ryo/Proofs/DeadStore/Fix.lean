/-
Ryo.Proofs.DeadStore.Fix — the dead-store certificate's bitset algebra (design T1).

`Flow.liveIn` and `Flow.preciseLive` are `while` loops (`partial`), so nothing is proved of them:
`droppedNotDead` checks that they are post-fixpoints (`Flow.liveOk`, `Flow.preciseOk`), and these
lemmas read the per-instruction facts off the checks:

- `testBit_*`: `diff`, `bitsOf`, `Ranges.bits`, `|||`-folds bit by bit;
- `postFix_spec`, `testBit_transferWith`: a post-fixpoint's transfer at `k` is in `live[k]`;
- `live_succ`, `live_pad`, `live_gen` (and `plive_*` for the precise liveness): a byte live into a
  successor (not written for sure, not made `Uninit`, not ended) or a landing pad, or read, is
  live into `k`;
- `endsUnread_spec`: an ended byte a dropped store writes isn't precise-live out of `k`;
- `droppedOk_spec`: the dropped store's bytes, but its flag byte, are dead into each successor;
- `droppedNotDead_ok`: `droppedNotDead … = .ok []` with stores dropped gives all of these.
-/
import Ryo.Vm.Frame

namespace Ryo.Proofs.DeadStore

open Ryo.Vm Ryo.Vm.R Ryo.Vm.Frame

/-! ### Bits -/

theorem testBit_diff (a b i : Nat) : (diff a b).testBit i = (a.testBit i && !b.testBit i) := by
  unfold diff
  rw [Nat.testBit_xor, Nat.testBit_and]
  cases a.testBit i <;> cases b.testBit i <;> rfl

theorem diff_eq_zero {a b : Nat} :
    diff a b = 0 ↔ ∀ i, a.testBit i = true → b.testBit i = true := by
  constructor
  · intro h i ha
    have := congrArg (Nat.testBit · i) h
    simp only [testBit_diff, Nat.zero_testBit] at this
    cases hb : b.testBit i <;> simp_all
  · intro h
    apply Nat.eq_of_testBit_eq
    intro i
    rw [testBit_diff, Nat.zero_testBit]
    cases ha : a.testBit i
    · rfl
    · simp [h i ha]

theorem testBit_bitsOf (lo hi i : Nat) :
    (bitsOf lo hi).testBit i = (decide (lo ≤ i) && decide (i < hi)) := by
  unfold bitsOf
  rw [Nat.one_shiftLeft, Nat.testBit_shiftLeft, Nat.testBit_two_pow_sub_one]
  by_cases h1 : lo ≤ i <;> by_cases h2 : i < hi <;> simp [h1, h2] <;> omega

theorem testBit_foldl_or {α : Type} (f : α → Nat) (i : Nat) :
    ∀ (l : List α) (init : Nat),
      (l.foldl (fun a s => a ||| f s) init).testBit i = (init.testBit i || l.any fun s => (f s).testBit i)
  | [], init => by simp
  | x :: l, init => by
    rw [List.foldl_cons, testBit_foldl_or f i l, Nat.testBit_or, List.any_cons, Bool.or_assoc]

theorem testBit_rangesBits (rs : Ranges) (i : Nat) :
    rs.bits.testBit i = rs.any fun r => decide (r.1 ≤ i) && decide (i < r.2) := by
  unfold Ranges.bits
  suffices h : ∀ init, (rs.foldl (fun b (lo, hi) => b ||| bitsOf lo hi) init).testBit i =
      (init.testBit i || rs.any fun r => decide (r.1 ≤ i) && decide (i < r.2)) by
    rw [h 0, Nat.zero_testBit, Bool.false_or]
  induction rs with
  | nil => intro init; simp
  | cons r rs ih =>
    intro init
    obtain ⟨lo, hi⟩ := r
    rw [List.foldl_cons, ih]
    simp only [Nat.testBit_or, testBit_bitsOf, List.any_cons, Bool.or_assoc]

theorem testBit_and_zero {a b : Nat} (h : a &&& b = 0) {i : Nat} (ha : a.testBit i = true)
    (hb : b.testBit i = true) : False := by
  have := congrArg (Nat.testBit · i) h
  simp only [Nat.testBit_and, Nat.zero_testBit, ha, hb, Bool.and_self] at this
  cases this

theorem testBit_liveOut (fl : Flow) (live : Array Nat) (k i : Nat) :
    (fl.liveOut live k).testBit i = fl.succ[k]!.any fun s => (live[s]!).testBit i := by
  unfold Flow.liveOut
  rw [testBit_foldl_or, Nat.zero_testBit, Bool.false_or]

/-! ### Post-fixpoints -/

theorem postFix_spec {fl : Flow} {tr : Array Nat → Nat → Nat} {live : Array Nat}
    (h : fl.postFix tr live = true) :
    live.size = fl.succ.size ∧ fl.pad.size = fl.succ.size ∧
    ∀ k < fl.succ.size, (∀ s ∈ fl.succ[k]! ++ fl.pad[k]!, s < fl.succ.size) ∧
      ∀ i, (tr live k).testBit i = true → (live[k]!).testBit i = true := by
  unfold Flow.postFix at h
  simp only [Bool.and_eq_true, beq_iff_eq, List.all_eq_true, List.mem_range,
    decide_eq_true_eq] at h
  obtain ⟨⟨h1, h2⟩, h3⟩ := h
  refine ⟨h1, h2, fun k hk => ?_⟩
  obtain ⟨h4, h5⟩ := h3 k hk
  exact ⟨h4, diff_eq_zero.1 h5⟩

theorem testBit_transferWith (fl : Flow) (gen : Nat) (ends : Bool) (live : Array Nat) (k i : Nat) :
    (fl.transferWith gen ends live k).testBit i =
      ((((((fl.succ[k]!.any (fun s => (live[s]!).testBit i)) && !(fl.kill[k]!.bits.testBit i)) ||
          (fl.pad[k]!.any (fun s => (live[s]!).testBit i))) && !(fl.uninit[k]!.bits.testBit i)) ||
        gen.testBit i) && !(ends && fl.ends[k]!.bits.testBit i)) := by
  unfold Flow.transferWith
  cases ends <;>
    simp only [testBit_diff, testBit_foldl_or, Nat.testBit_or, Nat.zero_testBit, Bool.false_or,
      Bool.false_and, Bool.true_and, Bool.not_false, Bool.and_true, Bool.false_eq_true,
      ↓reduceIte] <;> (try simp)

/-- Live into a successor, not written for sure, not made `Uninit`, not ended: live into `k`. -/
theorem live_succ {fl : Flow} {live : Array Nat} (h : fl.liveOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {s : Nat} (hs : s ∈ fl.succ[k]!) {i : Nat}
    (hl : (live[s]!).testBit i = true) (hkill : fl.kill[k]!.bits.testBit i = false)
    (hun : fl.uninit[k]!.bits.testBit i = false) (hend : fl.ends[k]!.bits.testBit i = false) :
    (live[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  unfold Flow.transfer
  rw [testBit_transferWith, hkill, hun, hend]
  have : (fl.succ[k]!.any fun s => (live[s]!).testBit i) = true := List.any_eq_true.2 ⟨s, hs, hl⟩
  rw [this]
  simp

/-- Live into a landing pad, not made `Uninit`, not ended: live into `k` (unwinding writes
nothing). -/
theorem live_pad {fl : Flow} {live : Array Nat} (h : fl.liveOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {s : Nat} (hs : s ∈ fl.pad[k]!) {i : Nat}
    (hl : (live[s]!).testBit i = true) (hun : fl.uninit[k]!.bits.testBit i = false)
    (hend : fl.ends[k]!.bits.testBit i = false) : (live[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  unfold Flow.transfer
  rw [testBit_transferWith, hun, hend]
  have : (fl.pad[k]!.any fun s => (live[s]!).testBit i) = true := List.any_eq_true.2 ⟨s, hs, hl⟩
  rw [this]
  simp

/-- Read by `k` (`gen`), not ended: live into `k`. -/
theorem live_gen {fl : Flow} {live : Array Nat} (h : fl.liveOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {i : Nat} (hg : (fl.gen k).testBit i = true)
    (hend : fl.ends[k]!.bits.testBit i = false) : (live[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  unfold Flow.transfer
  rw [testBit_transferWith, hg, hend]
  simp

/-- The successors and landing pads are in range. -/
theorem liveOk_edges {fl : Flow} {live : Array Nat} (h : fl.liveOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {s : Nat} (hs : s ∈ fl.succ[k]! ++ fl.pad[k]!) : s < fl.succ.size :=
  ((postFix_spec h).2.2 k hk).1 s hs

theorem plive_succ {fl : Flow} {live : Array Nat} (h : fl.preciseOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {s : Nat} (hs : s ∈ fl.succ[k]!) {i : Nat}
    (hl : (live[s]!).testBit i = true) (hkill : fl.kill[k]!.bits.testBit i = false)
    (hun : fl.uninit[k]!.bits.testBit i = false) : (live[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  unfold Flow.preciseTransfer
  rw [testBit_transferWith, hkill, hun]
  have : (fl.succ[k]!.any fun s => (live[s]!).testBit i) = true := List.any_eq_true.2 ⟨s, hs, hl⟩
  rw [this]
  simp

theorem plive_pad {fl : Flow} {live : Array Nat} (h : fl.preciseOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {s : Nat} (hs : s ∈ fl.pad[k]!) {i : Nat}
    (hl : (live[s]!).testBit i = true) (hun : fl.uninit[k]!.bits.testBit i = false) :
    (live[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  unfold Flow.preciseTransfer
  rw [testBit_transferWith, hun]
  have : (fl.pad[k]!.any fun s => (live[s]!).testBit i) = true := List.any_eq_true.2 ⟨s, hs, hl⟩
  rw [this]
  simp

theorem plive_operand {fl : Flow} {live : Array Nat} (h : fl.preciseOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {i : Nat} (hg : fl.operand[k]!.bits.testBit i = true) :
    (live[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  unfold Flow.preciseTransfer
  rw [testBit_transferWith, hg]
  simp

/-! ### The `End` check and the dropped stores -/

theorem testBit_droppedBits {d : Decoded} {k : Nat} (hk : k ∈ d.dropped.toList) {i : Nat}
    (h : (droppedBitsAt d k).testBit i = true) : (droppedBits d).testBit i = true := by
  unfold droppedBits
  rw [← Array.foldl_toList, testBit_foldl_or, Nat.zero_testBit, Bool.false_or]
  exact List.any_eq_true.2 ⟨k, hk, h⟩

theorem testBit_droppedBitsAt {d : Decoded} {k w i : Nat} {s : BitVec 32}
    (hs : droppedStore d k = some (s, w)) (h1 : (Frame.range d.frameSize s w).1 ≤ i)
    (h2 : i < (Frame.range d.frameSize s w).2) : (droppedBitsAt d k).testBit i = true := by
  unfold droppedBitsAt
  rw [hs, testBit_bitsOf]
  simp [h1, h2]

/-- An ended byte that a dropped store writes isn't precise-live into a successor. -/
theorem endsUnread_spec {d : Decoded} {fl : Flow} {plive : Array Nat}
    (h : endsUnread d fl plive = true) {k : Nat} (hk : k < d.insns.size) {i : Nat}
    (he : fl.ends[k]!.bits.testBit i = true) (hd : (droppedBits d).testBit i = true) {s : Nat}
    (hs : s ∈ fl.succ[k]!) : (plive[s]!).testBit i = false := by
  unfold endsUnread at h
  simp only [List.all_eq_true, List.mem_range, beq_iff_eq] at h
  have h0 := h k hk
  cases hp : (plive[s]!).testBit i
  · rfl
  · exfalso
    have hl : (fl.liveOut plive k).testBit i = true := by
      rw [testBit_liveOut]; exact List.any_eq_true.2 ⟨s, hs, hp⟩
    refine testBit_and_zero h0 ?_ hl
    rw [Nat.testBit_and, he, hd]; rfl

theorem testBit_flagBits {d : Decoded} {k i : Nat}
    (h : ∀ o, flagSlot d k = some o →
      ¬ ((Frame.range d.frameSize o 1).1 ≤ i ∧ i < (Frame.range d.frameSize o 1).2)) :
    (flagBits d k).testBit i = false := by
  unfold flagBits
  cases hf : flagSlot d k with
  | none => simp
  | some o =>
    have := h o hf
    simp only [testBit_bitsOf]
    by_cases h1 : (Frame.range d.frameSize o 1).1 ≤ i <;>
      by_cases h2 : i < (Frame.range d.frameSize o 1).2 <;> simp_all

/-- A store `droppedOk` accepts: its bytes, but its flag byte, are dead into every successor. -/
theorem droppedOk_spec {d : Decoded} {fl : Flow} {live : Array Nat} {k : Nat}
    (h : droppedOk d fl live k = true) :
    ∃ s w, droppedStore d k = some (s, w) ∧
      ∀ i, (Frame.range d.frameSize s w).1 ≤ i → i < (Frame.range d.frameSize s w).2 →
        (∀ o, flagSlot d k = some o →
          ¬ ((Frame.range d.frameSize o 1).1 ≤ i ∧ i < (Frame.range d.frameSize o 1).2)) →
        ∀ s' ∈ fl.succ[k]!, (live[s']!).testBit i = false := by
  unfold droppedOk at h
  cases hs : droppedStore d k with
  | none => simp [hs] at h
  | some p =>
    obtain ⟨s, w⟩ := p
    refine ⟨s, w, rfl, fun i h1 h2 hfl s' hs' => ?_⟩
    simp only [hs, beq_iff_eq] at h
    cases hp : (live[s']!).testBit i
    · rfl
    · exfalso
      have hl : (fl.liveOut live k).testBit i = true := by
        rw [testBit_liveOut]; exact List.any_eq_true.2 ⟨s', hs', hp⟩
      refine testBit_and_zero h ?_ ?_ (i := i)
      · rw [testBit_diff, hl, testBit_flagBits hfl]; rfl
      · rw [testBit_bitsOf]; simp [h1, h2]

/-- What `droppedNotDead` accepting a function with dropped stores gives: its flow, the checked
post-fixpoints and every dropped store shown dead. -/
theorem droppedNotDead_ok {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    (h : droppedNotDead d mode facts = .ok []) (hne : d.dropped.isEmpty = false) :
    ∃ fl, Flow.of d mode facts = .ok fl ∧ fl.liveOk fl.liveIn = true ∧
      escOk d fl.edges fl.esc = true ∧ fl.preciseOk fl.preciseLive = true ∧
      endsUnread d fl fl.preciseLive = true ∧
      ∀ k ∈ d.dropped.toList, droppedOk d fl fl.liveIn k = true := by
  unfold droppedNotDead at h
  cases hf : Flow.of d mode facts with
  | error e => simp [hne, hf, bind, Except.bind] at h
  | ok fl =>
    refine ⟨fl, rfl, ?_⟩
    by_cases hc : (fl.liveOk fl.liveIn && escOk d fl.edges fl.esc && fl.preciseOk fl.preciseLive &&
        endsUnread d fl fl.preciseLive) = true
    · have hc' := hc
      simp only [Bool.and_eq_true] at hc'
      obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hc'
      refine ⟨h1, h2, h3, h4, ?_⟩
      have h' : d.dropped.toList.filter (fun k => !droppedOk d fl fl.liveIn k) = [] := by
        simpa [hne, hf, hc, bind, Except.bind, pure, Except.pure] using h
      intro k hk
      have := List.filter_eq_nil_iff.1 h' k hk
      simpa using this
    · exfalso
      have h' : d.dropped.toList = [] := by
        simpa [hne, hf, hc, bind, Except.bind, pure, Except.pure] using h
      have hsz : d.dropped.size = 0 := by rw [← Array.length_toList, h']; rfl
      simp [Array.isEmpty, hsz] at hne

end Ryo.Proofs.DeadStore
