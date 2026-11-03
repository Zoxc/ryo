/-
Ryo.Proofs.Discharge.EscFrom — where R's escaped objects come from (`FrameInv.esc`), and the
privacy facts `privCheck` gives with it (`Hyps.linkPrivate`, `Hyps.argPrivate`).

`EscFrom c L pc st`: every escaped object of `st` is the range of an `Escape` scope of `c`
(`R.escape` adds exactly its scope's range, `R.storageEnd` only removes objects, and nothing else
changes `escaped`), and, while `L` holds (in `FrameInv`: `LeadArg S pc`, in the straight run of
leading `arg`s), of one before `pc` (the scopes run so far).

Kept by:
- the scopes at `k` (`EscFrom.scopes`: their indices are `k`, so below `k + 1`);
- every state change that keeps `escaped` (`EscFrom.congr`): `opSem`, frame writes, answers,
  PE's home-space clearing;
- moving to a successor where `L` doesn't hold (`EscFrom.of_not`), or to a later `pc`
  with a weaker `L` (`EscFrom.mono`).

This file doesn't import `DecodeSound/Basic.lean`, so `Basic.lean` can import it.
-/
import Ryo.Vm.PrivCheck
import Ryo.Proofs.ScopeMem

namespace Ryo.Proofs.Discharge.EscFrom

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.R Ryo.Vm.Asm

/-- Every escaped object of `st` is an `Escape` scope's range of `c`, one before `pc` while `L`
(see the module comment). -/
def EscFrom (c : R.Code) (L : Prop) (pc : Nat) (st : OpSem.State) : Prop :=
  ∀ e ∈ st.escaped, ∃ p ∈ c.d.scopes.toList, p.2.isEscape = true ∧
    p.2.frameOffset.toInt = e.off ∧ p.2.size = e.size ∧ (L → p.1 < pc)

/-- `EscFrom` reads only `escaped`. -/
theorem EscFrom.congr {c : R.Code} {L : Prop} {pc : Nat} {st st' : OpSem.State}
    (h : EscFrom c L pc st) (he : st'.escaped = st.escaped) : EscFrom c L pc st' := by
  intro e he'
  rw [he] at he'
  exact h e he'

/-- A weaker `L` and a later `pc`. -/
theorem EscFrom.mono {c : R.Code} {L L' : Prop} {pc pc' : Nat} {st : OpSem.State}
    (h : EscFrom c L pc st) (hL : L' → L) (hpc : pc ≤ pc') : EscFrom c L' pc' st := by
  intro e he
  obtain ⟨p, hp, h1, h2, h3, h4⟩ := h e he
  exact ⟨p, hp, h1, h2, h3, fun hl => Nat.lt_of_lt_of_le (h4 (hL hl)) hpc⟩

/-- Where `L'` doesn't hold, any `pc'`. -/
theorem EscFrom.of_not {c : R.Code} {L L' : Prop} {pc pc' : Nat} {st : OpSem.State}
    (h : EscFrom c L pc st) (hn : ¬ L') : EscFrom c L' pc' st := by
  intro e he
  obtain ⟨p, hp, h1, h2, h3, _⟩ := h e he
  exact ⟨p, hp, h1, h2, h3, fun hl => absurd hl hn⟩

/-- A fold of steps that each keep `escaped` keeps it. -/
theorem foldlM_keep {α : Type} (f : OpSem.State → α → M OpSem.State)
    (hf : ∀ st x st', f st x = .ok st' → st'.escaped = st.escaped) :
    ∀ (l : List α) {st st' : OpSem.State}, l.foldlM f st = .ok st' → st'.escaped = st.escaped
  | [], st, st', h => by
    simp [pure, Except.pure] at h; subst h; rfl
  | x :: l, st, st', h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : f st x with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      rw [foldlM_keep f hf l h, hf _ _ _ h1]

/-- An answer's frame writes keep the escaped objects. -/
theorem writeRanges_escaped {st st' : OpSem.State} {rs : List (Int × Nat)}
    {new : List (List AbstractByte)} (h : R.writeRanges st rs new = .ok st') :
    st'.escaped = st.escaped := by
  unfold R.writeRanges at h
  split at h
  · simp [pure, Except.pure] at h; subst h; rfl
  · split at h
    · simp [illFormed, throw, throwThe, MonadExceptOf.throw, bind, Except.bind] at h
    · try simp only [pure_bind] at h
      refine foldlM_keep _ ?_ _ h
      rintro st0 ⟨⟨off, n⟩, bs⟩ st1 h1
      try dsimp only at h1
      split at h1
      · simp [illFormed, throw, throwThe, MonadExceptOf.throw, bind, Except.bind] at h1
      · try simp only [pure_bind] at h1
        exact ScopeMem.writeFrame_escaped h1

theorem scopes_aux (c : R.Code) (L : Prop) (k : Nat) : ∀ (l : List R.Scope) {s s1 : R.RState},
    (∀ sc ∈ l, ∃ p ∈ c.d.scopes.toList, p.1 = k ∧ p.2 = sc) → EscFrom c L (k + 1) s.st →
    l.foldlM R.applyScope s = .ok s1 → EscFrom c L (k + 1) s1.st
  | [], s, s1, _, hs, h => by cases h; exact hs
  | sc :: l, s, s1, hl, hs, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s2 =>
      simp only [h1] at h
      refine scopes_aux c L k l (fun sc' h' => hl sc' (List.mem_cons_of_mem _ h')) ?_ h
      unfold R.applyScope at h1
      split at h1
      · rename_i al hk
        rcases Ryo.Proofs.Scope.escape_ok h1 with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
        · exact hs
        · intro e he
          simp only [List.mem_append, List.mem_singleton] at he
          rcases he with he | rfl
          · exact hs e he
          · obtain ⟨p, hp, hpk, rfl⟩ := hl sc (List.mem_cons_self ..)
            refine ⟨p, hp, ?_, rfl, rfl, fun _ => by omega⟩
            simp [R.Scope.isEscape, hk]
      · obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h1
        intro e he
        change e ∈ st'.escaped at he
        rw [ScopeMem.writeFrame_escaped hw] at he
        exact hs e (List.mem_filter.1 he).1
      · cases h1; exact hs

/-- The scopes before instruction `k` keep `EscFrom`, from `k` to `k + 1`: an `Escape` adds its
own range (or nothing), an `End` removes objects. -/
theorem EscFrom.scopes {c : R.Code} {L : Prop} {k : Nat} {s s1 : R.RState}
    (h : EscFrom c L k s.st) (hsc : (c.scopesAt k).foldlM R.applyScope s = .ok s1) :
    EscFrom c L (k + 1) s1.st := by
  refine scopes_aux c L k _ (fun sc hm => ?_) (h.mono id (Nat.le_succ k)) hsc
  simp only [R.Code.scopesAt, List.mem_map, List.mem_filter, beq_iff_eq] at hm
  obtain ⟨p, ⟨hp, hk⟩, rfl⟩ := hm
  exact ⟨p, hp, hk, rfl⟩

/-- No escaped object covers a byte that no `Escape` scope's range covers. -/
theorem escapedAt_none_of {c : R.Code} {L : Prop} {pc : Nat} {st : OpSem.State}
    (h : EscFrom c L pc st) {o : Int}
    (hno : ∀ p ∈ c.d.scopes.toList, p.2.isEscape = true → (L → p.1 < pc) →
      ¬ (p.2.frameOffset.toInt ≤ o ∧ o < p.2.frameOffset.toInt + p.2.size)) :
    st.escapedAt o = none := by
  unfold OpSem.State.escapedAt
  apply List.find?_eq_none.2
  intro e he hc
  obtain ⟨p, hp, h1, h2, h3, h4⟩ := h e he
  simp only [decide_eq_true_eq] at hc
  exact hno p hp h1 h4 (by rw [h2, h3]; exact hc)

end Ryo.Proofs.Discharge.EscFrom
