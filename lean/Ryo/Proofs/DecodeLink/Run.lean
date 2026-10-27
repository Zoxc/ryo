/-
Ryo.Proofs.DecodeLink.Run — reading the decoder's monadic code (`Ryo.Vm.DecodeReduced`'s `DM`,
`StateT Cursor (Except AsmError)`) for the links of aot.md §C2: what a successful run says.

- `bind_ok`, `pure_ok`, `err_ok`: a successful run of `x >>= f` is a successful run of `x`
  then of `f`; `pure` leaves the cursor; `DM.err` never succeeds.
- `run_tryItem`, `run_item`: `tryItem` / `item` read `decodeItem` at the cursor and move it
  past the item (`tryItem` leaves it on `none`).
- `forIn_list_inv`, `forIn_range_inv`: an invariant `I` of a `for` loop's state and cursor,
  kept by every iteration that yields and turned into `D` by one that stops, holds at the end
  (as `I` or `D`).
- `forIn_list_pre`: the same for a loop over a list, the invariant indexed by the elements
  done.
- `PosOnly x`: every successful run of `x` changes only the cursor's position (not its code,
  fields or frame form); closed under the monad's operations.
- `take_dec`: `DM.take f` returns items `decodeItem` read one after the other (`Dec`), each
  satisfying `f`; `item_dec`, `check_dec` (an item that must be `want`), `pos_run'`,
  `fuel_run`, `get_run`: the small steps.
-/
import Ryo.Vm.DecodeReduced
import Ryo.Proofs.DecodeLink.Bytes

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm


theorem run_pos (c : Cursor) : DM.pos.run c = .ok (c.pos, c) := rfl
theorem run_setPos (c : Cursor) (p : Nat) : (DM.setPos p).run c = .ok ((), atPos c p) := rfl

theorem run_tryItem (c : Cursor) : DM.tryItem.run c = (match decodeItem c with
    | some (i, n) => .ok (some i, atPos c (c.pos + n))
    | none => .ok (none, c)) := by
  simp only [DM.tryItem, StateT.run, bind, StateT.bind, get, getThe, MonadStateOf.get, StateT.get,
    pure, Except.pure, set, Except.bind]
  split <;> (rename_i heq; simp only [heq]; rfl)

theorem run_tryItem_some {c c' : Cursor} {i : Item} (h : DM.tryItem.run c = .ok (some i, c')) :
    ∃ n, decodeItem c = some (i, n) ∧ c' = atPos c (c.pos + n) := by
  rw [run_tryItem] at h
  split at h
  · cases h; exact ⟨_, ‹_›, rfl⟩
  · cases h

theorem run_tryItem_none {c c' : Cursor} (h : DM.tryItem.run c = .ok (none, c')) : c' = c := by
  rw [run_tryItem] at h
  split at h
  · cases h
  · cases h; rfl

theorem bind_ok {α β : Type} {x : DM α} {f : α → DM β} {c c'' : Cursor} {b : β}
    (h : (x >>= f).run c = .ok (b, c'')) : ∃ a c', x.run c = .ok (a, c') ∧ (f a).run c' = .ok (b, c'') := by
  simp only [StateT.run, bind, StateT.bind, Except.bind] at h
  split at h
  · cases h
  · rename_i v hv; exact ⟨v.1, v.2, hv, h⟩

theorem pure_ok {α : Type} {a b : α} {c c' : Cursor} (h : (pure a : DM α).run c = .ok (b, c')) :
    a = b ∧ c = c' := by
  simp only [StateT.run, pure, StateT.pure, Except.pure] at h; cases h; exact ⟨rfl, rfl⟩

theorem err_ok {α : Type} {at_ : Nat} {w : String} {c c' : Cursor} {b : α}
    (h : (DM.err at_ w : DM α).run c = .ok (b, c')) : False := by
  simp only [DM.err, StateT.run, throw, throwThe, MonadExceptOf.throw, StateT.lift, bind, Except.bind] at h
  cases h

theorem run_item {c c' : Cursor} {i : Item} (h : DM.item.run c = .ok (i, c')) :
    ∃ n, decodeItem c = some (i, n) ∧ c' = atPos c (c.pos + n) := by
  obtain ⟨a, c1, h1, h2⟩ := bind_ok h
  cases a with
  | some j =>
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h1
    obtain ⟨rfl, rfl⟩ := pure_ok h2
    exact ⟨n, hn, rfl⟩
  | none =>
    obtain ⟨a, c2, -, h3⟩ := bind_ok h2
    exact (err_ok h3).elim

theorem forIn_list_inv {α β : Type} (I D : β → Cursor → Prop) (f : α → β → DM (ForInStep β))
    (hstep : ∀ a b c r c', I b c → (f a b).run c = .ok (r, c') →
      (match r with | .yield b' => I b' c' | .done b' => D b' c')) :
    ∀ (l : List α) (init : β) (c c' : Cursor) (b : β), I init c →
      (forIn l init f).run c = .ok (b, c') → I b c' ∨ D b c'
  | [], init, c, c', b, h0, h => by
    simp only [List.forIn_nil] at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    exact .inl h0
  | a :: l, init, c, c', b, h0, h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    have := hstep a init c r c1 h0 h1
    cases r with
    | done b' =>
      obtain ⟨rfl, rfl⟩ := pure_ok h2
      exact .inr this
    | yield b' => exact forIn_list_inv I D f hstep l b' c1 c' b this h2

theorem forIn_range_inv {β : Type} (I D : β → Cursor → Prop) (f : Nat → β → DM (ForInStep β))
    (hstep : ∀ a b c r c', I b c → (f a b).run c = .ok (r, c') →
      (match r with | .yield b' => I b' c' | .done b' => D b' c'))
    (n : Nat) (init : β) (c c' : Cursor) (b : β) (h0 : I init c)
    (h : (forIn [0:n] init f).run c = .ok (b, c')) : I b c' ∨ D b c' := by
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h
  exact forIn_list_inv I D f hstep _ init c c' b h0 h

/-- What `take` returns: the items it read, decoded one after the other, each satisfying `f`. -/
theorem take_dec {f : Item → Bool} {c c' : Cursor} {l : List Item}
    (h : (DM.take f).run c = .ok (l, c')) :
    Dec c c.pos l c'.pos ∧ c' = atPos c c'.pos ∧ ∀ x ∈ l, f x = true := by
  unfold DM.take at h
  obtain ⟨fu, c1, h1, h2⟩ := bind_ok h
  have hc1 : c1 = c := by simp only [DM.fuel, StateT.run, bind, StateT.bind, get, getThe, MonadStateOf.get, StateT.get, pure, StateT.pure, Except.pure, Except.bind] at h1; cases h1; rfl
  subst hc1
  obtain ⟨st, c2, h3, h4⟩ := bind_ok h2
  let I : Option (List Item) × Array Item → Cursor → Prop := fun st c2 =>
    st.1 = none ∧ Dec c1 c1.pos st.2.toList c2.pos ∧ c2 = atPos c1 c2.pos ∧ ∀ x ∈ st.2.toList, f x = true
  let D : Option (List Item) × Array Item → Cursor → Prop := fun st c2 =>
    st.1 = some st.2.toList ∧ Dec c1 c1.pos st.2.toList c2.pos ∧ c2 = atPos c1 c2.pos ∧ ∀ x ∈ st.2.toList, f x = true
  have key := forIn_range_inv I D _ ?_ fu (none, #[]) c1 c2 st ⟨rfl, .nil _, rfl, by simp⟩ h3
  · have hfin : l = st.2.toList ∧ c' = c2 := by
      rcases key with ⟨hn, -⟩ | ⟨hs, -⟩
      · simp only [hn] at h4; obtain ⟨rfl, rfl⟩ := pure_ok h4; exact ⟨rfl, rfl⟩
      · simp only [hs] at h4; obtain ⟨rfl, rfl⟩ := pure_ok h4; exact ⟨rfl, rfl⟩
    obtain ⟨rfl, rfl⟩ := hfin
    rcases key with ⟨-, hd, hc, hf⟩ | ⟨-, hd, hc, hf⟩ <;> exact ⟨hd, hc, hf⟩
  · intro a b c3 r c4 hI hr
    obtain ⟨hb1, hd, hc3, hf⟩ := hI
    obtain ⟨p, c5, h5, h6⟩ := bind_ok hr
    obtain ⟨rfl, rfl⟩ := pure_ok (α := Nat) (by simpa [DM.pos, StateT.run, bind, StateT.bind, get, getThe, MonadStateOf.get, StateT.get, pure, StateT.pure, Except.pure, Except.bind] using h5 : (pure c3.pos : DM Nat).run c3 = .ok (p, c5))
    obtain ⟨o, c6, h7, h8⟩ := bind_ok h6
    cases o with
    | none =>
      have := run_tryItem_none h7; subst this
      obtain ⟨u, c7, h9, h10⟩ := bind_ok h8
      rw [run_setPos] at h9; cases h9
      obtain ⟨rfl, rfl⟩ := pure_ok h10
      refine ⟨rfl, ?_, ?_, hf⟩
      · simpa using hd
      · rw [hc3]
    | some it =>
      obtain ⟨n, hn, rfl⟩ := run_tryItem_some h7
      by_cases hfi : f it = true
      · simp only [hfi, ↓reduceIte] at h8
        obtain ⟨rfl, rfl⟩ := pure_ok h8
        refine ⟨rfl, ?_, ?_, ?_⟩
        · simp only [Array.toList_push]
          refine hd.append (Dec.single ?_)
          rw [hc3] at hn; simpa using hn
        · rw [hc3]
        · simp only [Array.toList_push, List.mem_append, List.mem_singleton]
          rintro x (hx | rfl)
          · exact hf x hx
          · exact hfi
      · simp only [hfi, Bool.false_eq_true, ↓reduceIte] at h8
        obtain ⟨u, c7, h9, h10⟩ := bind_ok h8
        rw [run_setPos] at h9; cases h9
        obtain ⟨rfl, rfl⟩ := pure_ok h10
        refine ⟨rfl, ?_, ?_, hf⟩
        · simpa using hd
        · rw [hc3]

/-! ### Runs that move only the position -/

/-- Every successful run of `x` changes only the cursor's position. -/
def PosOnly {α : Type} (x : DM α) : Prop :=
  ∀ c a c', x.run c = .ok (a, c') → c' = atPos c c'.pos

theorem PosOnly.bind {α β : Type} {x : DM α} {f : α → DM β} (hx : PosOnly x)
    (hf : ∀ a, PosOnly (f a)) : PosOnly (x >>= f) := by
  intro c b c'' h
  obtain ⟨a, c', h1, h2⟩ := bind_ok h
  have e1 := hx _ _ _ h1
  have e2 := hf a _ _ _ h2
  rw [e2, e1]

theorem PosOnly.pure {α : Type} (a : α) : PosOnly (pure a : DM α) := by
  intro c b c' h
  obtain ⟨-, rfl⟩ := pure_ok h
  rfl

theorem PosOnly.pos : PosOnly DM.pos := by
  intro c b c' h; rw [run_pos] at h; cases h; rfl

theorem PosOnly.setPos (p : Nat) : PosOnly (DM.setPos p) := by
  intro c b c' h; rw [run_setPos] at h; cases h; rfl

theorem PosOnly.err {α : Type} (at_ : Nat) (w : String) : PosOnly (DM.err at_ w : DM α) := by
  intro c b c' h; exact (err_ok h).elim

theorem PosOnly.tryItem : PosOnly DM.tryItem := by
  intro c b c' h
  cases b with
  | none => rw [run_tryItem_none h]
  | some i => obtain ⟨n, -, rfl⟩ := run_tryItem_some h; rfl

theorem PosOnly.item : PosOnly DM.item := by
  intro c b c' h
  obtain ⟨n, -, rfl⟩ := run_item h; rfl

theorem PosOnly.fuel : PosOnly DM.fuel := by
  intro c b c' h
  simp only [DM.fuel, StateT.run, bind, StateT.bind, get, getThe, MonadStateOf.get, StateT.get,
    Pure.pure, StateT.pure, Except.pure, Except.bind] at h
  cases h; rfl

theorem PosOnly.forIn_list {α β : Type} (l : List α) (init : β) (f : α → β → DM (ForInStep β))
    (hf : ∀ a b, PosOnly (f a b)) : PosOnly (forIn l init f) := by
  intro c b c' h
  have := forIn_list_inv (fun _ c2 => c2 = atPos c c2.pos) (fun _ c2 => c2 = atPos c c2.pos) f
    (by
      intro a b c2 r c3 h2 h3
      have e := hf a b _ _ _ h3
      cases r <;> (rw [e, h2])) l init c c' b rfl h
  rcases this with h | h <;> exact h

theorem PosOnly.forIn_range {β : Type} (n : Nat) (init : β) (f : Nat → β → DM (ForInStep β))
    (hf : ∀ a b, PosOnly (f a b)) : PosOnly (forIn [0:n] init f) := by
  intro c b c' h
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h
  exact PosOnly.forIn_list _ init f hf c b c' h

theorem PosOnly.ite {α : Type} {p : Prop} [Decidable p] {x y : DM α} (hx : PosOnly x)
    (hy : PosOnly y) : PosOnly (if p then x else y) := by
  split <;> assumption

/-! ### Small steps -/

theorem fuel_run {c c' : Cursor} {n : Nat} (h : DM.fuel.run c = .ok (n, c')) : c' = c := by
  simp only [DM.fuel, StateT.run, bind, StateT.bind, get, getThe, MonadStateOf.get, StateT.get,
    Pure.pure, StateT.pure, Except.pure, Except.bind] at h
  cases h; rfl

theorem pos_run' {c c' : Cursor} {n : Nat} (h : DM.pos.run c = .ok (n, c')) : n = c.pos ∧ c' = c := by
  rw [run_pos] at h; cases h; exact ⟨rfl, rfl⟩

/-- `expectItems want` that succeeds read `want`. -/
theorem expectItems_dec : ∀ {want : List Item} {c c' : Cursor},
    (DM.expectItems want).run c = .ok (true, c') → Dec c c.pos want c'.pos ∧ c' = atPos c c'.pos
  | [], c, c', h => by
    obtain ⟨-, rfl⟩ := pure_ok h; exact ⟨.nil _, rfl⟩
  | w :: ws, c, c', h => by
    unfold DM.expectItems at h
    obtain ⟨y, c1, h1, h⟩ := bind_ok h
    split at h
    · obtain ⟨he, -⟩ := pure_ok h; cases he
    · rename_i hy
      have : y = some w := by simpa using hy
      subst this
      obtain ⟨n, hn, rfl⟩ := run_tryItem_some h1
      obtain ⟨d, e⟩ := expectItems_dec h
      exact ⟨.cons hn (Dec.at_iff.mp d), e⟩

theorem item_dec {c c' : Cursor} {i : Item} (h : DM.item.run c = .ok (i, c')) :
    Dec c c.pos [i] c'.pos ∧ c' = atPos c c'.pos := by
  obtain ⟨n, hn, rfl⟩ := run_item h
  exact ⟨Dec.single hn, rfl⟩

theorem Dec.trans' {c : Cursor} {p q r : Nat} {a b : List Item} (ha : Dec c p a q)
    (hb : Dec (atPos c q) q b r) : Dec c p (a ++ b) r := ha.append (Dec.at_iff.mp hb)

/-- `x ← item; if x != want then (bad >>= k) else k ()`: the item is `want`, then `k` runs. -/
theorem check_dec {β : Type} {c c' : Cursor} {want : Item} {k : Unit → DM β} {bad : DM Unit} {v : β}
    (hbad : ∀ c u c', bad.run c ≠ .ok (u, c'))
    (h : (do let x ← DM.item; if (x != want) = true then (do let r ← bad; k r) else k ()).run c = .ok (v, c')) :
    ∃ c1, Dec c c.pos [want] c1.pos ∧ c1 = atPos c c1.pos ∧ (k ()).run c1 = .ok (v, c') := by
  obtain ⟨x, c1, h1, h2⟩ := bind_ok h
  obtain ⟨d1, e1⟩ := item_dec h1
  by_cases hx : (x != want) = true
  · simp only [hx, ↓reduceIte] at h2
    obtain ⟨u, c2, h3, -⟩ := bind_ok h2; exact (hbad _ _ _ h3).elim
  · simp only [hx, Bool.false_eq_true, ↓reduceIte] at h2
    have : x = want := by simpa using hx
    subst this
    exact ⟨c1, d1, e1, h2⟩

theorem forIn_list_pre {α β : Type} (I : List α → β → Cursor → Prop) (D : β → Cursor → Prop)
    (f : α → β → DM (ForInStep β))
    (hstep : ∀ pre a b c r c', I pre b c → (f a b).run c = .ok (r, c') →
      (match r with | .yield b' => I (pre ++ [a]) b' c' | .done b' => D b' c')) :
    ∀ (l pre : List α) (init : β) (c c' : Cursor) (b : β), I pre init c →
      (forIn l init f).run c = .ok (b, c') → I (pre ++ l) b c' ∨ D b c'
  | [], pre, init, c, c', b, h0, h => by
    simp only [List.forIn_nil] at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    exact .inl (by simpa using h0)
  | a :: l, pre, init, c, c', b, h0, h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    have := hstep pre a init c r c1 h0 h1
    cases r with
    | done b' =>
      obtain ⟨rfl, rfl⟩ := pure_ok h2
      exact .inr this
    | yield b' =>
      have := forIn_list_pre I D f hstep l (pre ++ [a]) b' c1 c' b this h2
      simpa using this

theorem get_run {c c' : Cursor} {x : Cursor} (h : (get : DM Cursor).run c = .ok (x, c')) :
    x = c ∧ c' = c := by
  simp only [StateT.run, get, getThe, MonadStateOf.get, StateT.get, Pure.pure, Except.pure] at h
  cases h; exact ⟨rfl, rfl⟩

end Ryo.Proofs.DecodeLink
