/-
Ryo.Proofs.DeadStore.Fix — the dead-store certificate's bitset algebra (design T1).

`Flow.liveIn` and `Flow.preciseLive` are `while` loops (`partial`), so nothing is proved of them:
`droppedNotDead` checks that `liveIn` is a post-fixpoint (`Flow.liveOk`), and these lemmas read the
per-instruction facts off the checks (`Flow.preciseOk` and `endsUnread` have lemmas here but aren't
run: `endsUnread` rejects real code):

- `testBit_*`: `diff`, `bitsOf`, `Ranges.bits`, `|||`-folds bit by bit;
- `postFix_spec`, `testBit_transferWith`: a post-fixpoint's transfer at `k` is in `live[k]`;
- `live_succ`, `live_pad`, `live_gen` (and `plive_*` for the precise liveness): a byte live into a
  successor (not written for sure, not made `Uninit`, not ended) or a landing pad, or read, is
  live into `k`;
- `endsUnread_spec`: an ended byte a dropped store writes isn't precise-live out of `k` (the check is no
  longer run by `droppedNotDead`);
- `droppedOk_spec`: the dropped store's bytes, but its flag byte, are dead into each successor;
- `droppedNotDead_ok`: `droppedNotDead … = .ok []` with stores dropped gives `liveOk`, `escOk` and
  `droppedOk` of each store (`droppedNotDead_full`: also `keptReadOk`, `droppedInFrame`,
  `droppedUnread`; `droppedNotDead_frameLo`);
- `keptRead_gen`/`_succ`/`_pad`, `droppedUnread_spec`, `keptReads_apart`: the kept-read liveness
  (bytes kept `rbp`-based items read from memory), and that kept reads miss a patch set outside it.
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
        gen.testBit i) && !(ends && fl.ends[k]!.bits.testBit i && !(fl.escRead[k]!).testBit i)) := by
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

/-- Read by `k` (`gen`), not ended before `k` unless an `Escape` before `k` copies it: live
into `k`. -/
theorem live_gen {fl : Flow} {live : Array Nat} (h : fl.liveOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {i : Nat} (hg : (fl.gen k).testBit i = true)
    (hend : fl.ends[k]!.bits.testBit i = false ∨ (fl.escRead[k]!).testBit i = true) :
    (live[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  unfold Flow.transfer
  rw [testBit_transferWith, hg]
  rcases hend with h' | h' <;> simp [h']

/-- Read by `k` and copied by an `Escape` before it: live into `k` (an `End` doesn't take it). -/
theorem live_esc {fl : Flow} {live : Array Nat} (h : fl.liveOk live = true) {k : Nat}
    (hk : k < fl.succ.size) {i : Nat} (hg : (fl.gen k).testBit i = true)
    (he : (fl.escRead[k]!).testBit i = true) : (live[k]!).testBit i = true :=
  live_gen h hk hg (.inr he)

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

/-- Everything `droppedNotDead` accepting a function with dropped stores gives: its flow, the
checked post-fixpoints (liveness, escapes, kept reads) and each dropped store shown dead,
private, at or above `frameLo` and unread by kept items. -/
theorem droppedNotDead_full {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    (h : droppedNotDead d mode facts = .ok []) (hne : d.dropped.isEmpty = false) :
    ∃ fl, Flow.of d mode facts = .ok fl ∧ fl.liveOk fl.liveIn = true ∧
      escOk d fl.edges fl.esc = true ∧ fl.keptReadOk d (fl.keptReadLive d) = true ∧
      ∀ k ∈ d.dropped.toList, droppedOk d fl fl.liveIn k = true ∧ droppedPrivate d fl k = true ∧
        droppedInFrame d mode k = true ∧ droppedUnread d fl (fl.keptReadLive d) k = true ∧
        droppedFormOk d k = true := by
  unfold droppedNotDead at h
  cases hf : Flow.of d mode facts with
  | error e => simp [hne, hf, bind, Except.bind] at h
  | ok fl =>
    refine ⟨fl, rfl, ?_⟩
    by_cases hc : (fl.liveOk fl.liveIn && escOk d fl.edges fl.esc &&
        fl.keptReadOk d (fl.keptReadLive d)) = true
    · have hc' := hc
      simp only [Bool.and_eq_true] at hc'
      obtain ⟨⟨h1, h2⟩, h3⟩ := hc'
      refine ⟨h1, h2, h3, ?_⟩
      have h' : d.dropped.toList.filter
          (fun k => !(droppedOk d fl fl.liveIn k && droppedPrivate d fl k &&
            droppedInFrame d mode k && droppedUnread d fl (fl.keptReadLive d) k &&
            droppedFormOk d k)) = [] := by
        simpa [hne, hf, hc, bind, Except.bind, pure, Except.pure] using h
      intro k hk
      have := List.filter_eq_nil_iff.1 h' k hk
      simpa [and_assoc] using this
    · exfalso
      have h' : d.dropped.toList = [] := by
        simpa [hne, hf, hc, bind, Except.bind, pure, Except.pure] using h
      have hsz : d.dropped.size = 0 := by rw [← Array.length_toList, h']; rfl
      simp [Array.isEmpty, hsz] at hne

/-- What `droppedNotDead` accepting a function with dropped stores gives: its flow, the checked
post-fixpoints and every dropped store shown dead. -/
theorem droppedNotDead_ok {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    (h : droppedNotDead d mode facts = .ok []) (hne : d.dropped.isEmpty = false) :
    ∃ fl, Flow.of d mode facts = .ok fl ∧ fl.liveOk fl.liveIn = true ∧
      escOk d fl.edges fl.esc = true ∧
      ∀ k ∈ d.dropped.toList, droppedOk d fl fl.liveIn k = true ∧ droppedPrivate d fl k = true := by
  obtain ⟨fl, hf, h1, h2, -, hk⟩ := droppedNotDead_full h hne
  exact ⟨fl, hf, h1, h2, fun k hm => ⟨(hk k hm).1, (hk k hm).2.1⟩⟩

/-- A store `droppedInFrame` accepts has its destination at or above `frameLo`. -/
theorem droppedInFrame_spec {d : Decoded} {mode : Ryo.Obj.Mode} {k : Nat}
    (h : droppedInFrame d mode k = true) {s : BitVec 32} {w : Nat}
    (hs : droppedStore d k = some (s, w)) :
    d.frameLo mode ≤ s.toInt ∨ s.toInt + w ≤ -(d.frameSize : Int) + 32 := by
  unfold droppedInFrame at h
  rw [hs] at h
  simp only [Bool.and_eq_true, decide_eq_true_eq] at h
  exact h.2

/-- A store `droppedInFrame` accepts lies in the frame `[-F, 0)`. -/
theorem droppedInFrame_bounds {d : Decoded} {mode : Ryo.Obj.Mode} {k : Nat}
    (h : droppedInFrame d mode k = true) {s : BitVec 32} {w : Nat}
    (hs : droppedStore d k = some (s, w)) :
    -(d.frameSize : Int) ≤ s.toInt ∧ s.toInt + w ≤ 0 := by
  unfold droppedInFrame at h
  rw [hs] at h
  simp only [Bool.and_eq_true, decide_eq_true_eq] at h
  exact h.1

/-- A store `droppedFormOk` accepts misses its instruction's overflow flag slot, or isn't the
flag store (`flagApart`: the flag store is `mov [o], cl`; a dropped store from another register
at `o` is the result's, overwritten by the flag store). -/
theorem droppedFormOk_flagApart {d : Decoded} {k : Nat} (h : droppedFormOk d k = true)
    {s : BitVec 32} {w : Nat} {o : BitVec 32} (hs : droppedStore d k = some (s, w))
    (ho : flagSlot d k = some o) :
    (o.toInt + 1 ≤ s.toInt ∨ s.toInt + w ≤ o.toInt) ∨
      ∃ w' src m, d.droppedItems[k]? = some (some (.st w' src m)) ∧ src ≠ .rcx := by
  unfold droppedFormOk at h
  simp only [Bool.and_eq_true] at h
  have h2 := h.2
  unfold flagApart at h2
  rw [hs, ho] at h2
  simp only [Bool.or_eq_true, decide_eq_true_eq] at h2
  rcases h2 with h2 | h2
  · exact .inl h2
  · right
    split at h2
    · rename_i w' src m heq
      exact ⟨w', src, m, heq, by simpa using h2⟩
    · cases h2

/-- Every dropped store's destination is at or above `frameLo` (`droppedInFrame`). -/
theorem droppedNotDead_frameLo {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    (h : droppedNotDead d mode facts = .ok []) (hne : d.dropped.isEmpty = false) :
    ∀ k ∈ d.dropped.toList, ∀ s w, droppedStore d k = some (s, w) →
      d.frameLo mode ≤ s.toInt ∨ s.toInt + w ≤ -(d.frameSize : Int) + 32 := by
  obtain ⟨fl, -, -, -, -, hk⟩ := droppedNotDead_full h hne
  intro k hm s w hs
  exact droppedInFrame_spec (hk k hm).2.2.1 hs

/-! ### Operand ranges -/

/-- `opndStep`'s writes: the state's, or the access's if it is a write. -/
theorem opndStep_snd {f : Nat} {isCall : Bool} {eb : Nat} {st : Ranges × Ranges}
    {x : BitVec 32 × Access} {r : Nat × Nat} (h : r ∈ (Flow.opndStep f isCall eb st x).2) :
    r ∈ st.2 ∨ ∃ m, x.2 = .write m ∧ r = range f x.1 m := by
  obtain ⟨off, acc⟩ := x
  unfold Flow.opndStep at h
  cases acc with
  | read m => exact .inl h
  | write m =>
    rcases List.mem_cons.1 h with rfl | h
    · exact .inr ⟨m, rfl, rfl⟩
    · exact .inl h
  | clobber m => exact .inl h
  | addr =>
    simp only at h
    split at h
    · exact .inl h
    · exact .inl h
  | «opaque» => exact .inl h

theorem opndRanges_snd_aux (f : Nat) (isCall : Bool) (eb : Nat) :
    ∀ (l : List (BitVec 32 × Access)) (st : Ranges × Ranges) (r : Nat × Nat),
      r ∈ (l.foldl (Flow.opndStep f isCall eb) st).2 →
      r ∈ st.2 ∨ ∃ off m, (off, Access.write m) ∈ l ∧ r = range f off m
  | [], st, r, h => .inl h
  | x :: l, st, r, h => by
    rw [List.foldl_cons] at h
    rcases opndRanges_snd_aux f isCall eb l _ r h with h' | ⟨off, m, hm, rfl⟩
    · rcases opndStep_snd h' with h'' | ⟨m, hx, rfl⟩
      · exact .inl h''
      · refine .inr ⟨x.1, m, ?_, rfl⟩
        rw [← hx]
        exact List.mem_cons_self ..
    · exact .inr ⟨off, m, List.mem_cons_of_mem _ hm, rfl⟩

/-- A sure write of `opndRanges` is a write access's range. -/
theorem opndRanges_kill {f : Nat} {isCall : Bool} {eb : Nat} {opnds : List (BitVec 32 × Access)}
    {r : Nat × Nat} (h : r ∈ (Flow.opndRanges f isCall eb opnds).2) :
    ∃ off m, (off, Access.write m) ∈ opnds ∧ r = range f off m := by
  rcases opndRanges_snd_aux f isCall eb opnds ([], []) r h with h' | h'
  · cases h'
  · exact h'

/-! ### Kept reads

The machine code reads, from memory, no byte where the real machine and the ghost differ. With
the invariant that every byte `o` of the patch set `P` at `pc` is out of the kept-read liveness
`kr[pc]` (to add to `PatchOk`), `keptReads_apart` gives the kept items' memory reads miss `P`
(what `keptApart_of_live` needs for `rbp`-based operands); `droppedUnread_spec` (the new bytes of
a dropped store) and `keptRead_succ`/`keptRead_pad` (the old bytes) keep the invariant. -/

theorem testBit_keptReadTransfer (d : Decoded) (fl : Flow) (live : Array Nat) (k i : Nat) :
    (fl.keptReadTransfer d live k).testBit i =
      (((((fl.succ[k]!.any fun t => (live[t]!).testBit i &&
            !((fl.ends[k]!.bits).testBit i && !(coveredAt d t).testBit i)) &&
          !(fl.kill[k]!.bits).testBit i) ||
        fl.pad[k]!.any fun s => (live[s]!).testBit i) || (keptReads d k).bits.testBit i) ||
        (fl.escRead[k]!).testBit i) := by
  unfold Flow.keptReadTransfer
  simp only [Nat.testBit_or, testBit_foldl_or, testBit_diff, Nat.zero_testBit, Bool.false_or]

/-- Read from memory by a kept item at `k`: kept-read live into `k`. -/
theorem keptRead_gen {d : Decoded} {fl : Flow} {kr : Array Nat} (h : fl.keptReadOk d kr = true)
    {k : Nat} (hk : k < fl.succ.size) {i : Nat} (hg : (keptReads d k).bits.testBit i = true) :
    (kr[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  rw [testBit_keptReadTransfer, hg, Bool.or_true, Bool.true_or]

/-- Copied by an `Escape` before `k` (`Flow.escRead`): kept-read live into `k`. -/
theorem keptRead_esc {d : Decoded} {fl : Flow} {kr : Array Nat} (h : fl.keptReadOk d kr = true)
    {k : Nat} (hk : k < fl.succ.size) {i : Nat} (hg : (fl.escRead[k]!).testBit i = true) :
    (kr[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  rw [testBit_keptReadTransfer, hg, Bool.or_true]

/-- Kept-read live into a successor `s`, not written for sure by `k`, and not ended before `k`
unless the cache covers it entering `s`: kept-read live into `k`. -/
theorem keptRead_succ {d : Decoded} {fl : Flow} {kr : Array Nat} (h : fl.keptReadOk d kr = true)
    {k : Nat} (hk : k < fl.succ.size) {s : Nat} (hs : s ∈ fl.succ[k]!) {i : Nat}
    (hl : (kr[s]!).testBit i = true)
    (hkill : fl.kill[k]!.bits.testBit i = false)
    (hend : fl.ends[k]!.bits.testBit i = false ∨ (coveredAt d s).testBit i = true) :
    (kr[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  have ho : (fl.succ[k]!.any fun t => (kr[t]!).testBit i &&
      !((fl.ends[k]!.bits).testBit i && !(coveredAt d t).testBit i)) = true :=
    List.any_eq_true.2 ⟨s, hs, by rcases hend with h' | h' <;> simp [hl, h']⟩
  rw [testBit_keptReadTransfer, ho, hkill]
  rfl

/-- Kept-read live into a landing pad: kept-read live into `k`. -/
theorem keptRead_pad {d : Decoded} {fl : Flow} {kr : Array Nat} (h : fl.keptReadOk d kr = true)
    {k : Nat} (hk : k < fl.succ.size) {s : Nat} (hs : s ∈ fl.pad[k]!) {i : Nat}
    (hl : (kr[s]!).testBit i = true) : (kr[k]!).testBit i = true := by
  apply ((postFix_spec h).2.2 k hk).2 i
  have : (fl.pad[k]!.any fun s => (kr[s]!).testBit i) = true := List.any_eq_true.2 ⟨s, hs, hl⟩
  rw [testBit_keptReadTransfer, this, Bool.or_true, Bool.true_or, Bool.true_or]

/-- `coveredAt` bit by bit: after an inline instruction with a recorded cache, the bytes of its
slots. -/
theorem testBit_slotBits (f : Nat) (sl : List (BitVec 32 × Nat)) (i : Nat) :
    (slotBits f sl).testBit i =
      sl.any fun p => decide ((range f p.1 p.2).1 ≤ i) && decide (i < (range f p.1 p.2).2) := by
  unfold slotBits
  rw [testBit_foldl_or (fun p : BitVec 32 × Nat => bitsOf (range f p.1 p.2).1 (range f p.1 p.2).2)]
  simp only [Nat.zero_testBit, Bool.false_or, testBit_bitsOf]

/-- A byte dropped store `k` writes (but its flag byte) isn't kept-read live into a successor. -/
theorem droppedUnread_spec {d : Decoded} {fl : Flow} {kr : Array Nat} {k : Nat}
    (h : droppedUnread d fl kr k = true) {i : Nat} (hd : (droppedBitsAt d k).testBit i = true)
    (hfl : (flagBits d k).testBit i = false) {s : Nat} (hs : s ∈ fl.succ[k]!) :
    (kr[s]!).testBit i = false := by
  unfold droppedUnread at h
  simp only [beq_iff_eq] at h
  cases hp : (kr[s]!).testBit i
  · rfl
  · exfalso
    have hl : (fl.liveOut kr k).testBit i = true := by
      rw [testBit_liveOut]; exact List.any_eq_true.2 ⟨s, hs, hp⟩
    refine testBit_and_zero h ?_ hd
    rw [testBit_diff, hl, hfl]; rfl

/-- **The kept items' memory reads miss `P`**: with every byte of `P` a frame byte out of the
kept-read liveness into `k`, no kept item at `k` reads a byte of `P` through an `rbp`-based
operand. -/
theorem keptReads_apart {d : Decoded} {fl : Flow} {kr : Array Nat}
    (h : fl.keptReadOk d kr = true) {k : Nat} (hk : k < fl.succ.size) {kept : List Ryo.X86.Item}
    (hkept : d.items[k]? = some kept) {P : Int → Prop}
    (hP : ∀ o, P o → -(d.frameSize : Int) ≤ o ∧ o < 0 ∧
      (kr[k]!).testBit (o + (d.frameSize : Int)).toNat = false) :
    ∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp →
      ∀ j < itemReadBytes it, ¬ P (m.disp.toInt + j) := by
  intro it hit m hm hb j hj hPo
  obtain ⟨h1, h2, h3⟩ := hP _ hPo
  have hg : (keptReads d k).bits.testBit (m.disp.toInt + j + (d.frameSize : Int)).toNat = true := by
    rw [testBit_rangesBits]
    refine List.any_eq_true.2 ⟨range d.frameSize m.disp (itemReadBytes it), ?_, ?_⟩
    · unfold keptReads
      rw [hkept, Option.getD_some]
      exact List.mem_filterMap.2 ⟨it, hit, by simp [hm, hb]⟩
    · simp only [range]
      simp only [Bool.and_eq_true]
      exact ⟨decide_eq_true (by omega), decide_eq_true (by omega)⟩
  rw [keptRead_gen h hk hg] at h3
  cases h3

end Ryo.Proofs.DeadStore
