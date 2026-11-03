/-
Ryo.Proofs.DeadStore.Esc — escape soundness (design T2): the may-escaped sets `Flow.of` uses
(`fl.esc`, checked by `escOk`) over-approximate R's escaped objects.

`escapedAt` is a `while` loop, so the proofs use `escOk`'s post-fixpoint. The invariant is on
the state before an instruction's scopes:

- `EscIn d B st`: each escaped object of `st` is the range of an `Escape` scope whose bit is in
  `B`;
- `EscPre d at_ k st`: `st`'s objects are in some `B` whose image under `k`'s scopes
  (`stepsAt d k`) is in `at_[k]`.

`escIn_scopesAt`: R's scopes before `k` (`Escape` adds its own range or nothing, `End` removes
the objects it covers whole) map `EscIn B` to `EscIn (applyStepsL (stepsAt d k) B)`. So after
them (`escIn_post`) the objects are in `at_[k]`; along an edge (`escPre_succ`) and at entry
(`escPre_entry`) `EscPre` holds again; `escPre_next` puts it together for a step that keeps
`escaped` past its scopes. `escaped_in_pointer` turns it into the bit of `fl.pointer` at a
pointer access, from `flowOf_pointer` (what `Flow.of` puts in `pointer`).
-/
import Ryo.Vm.Frame
import Ryo.Proofs.Discharge.EscFrom
import Ryo.Proofs.DeadStore.Fix

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.R Ryo.Vm.Frame

/-- Every escaped object of `st` is the range of an `Escape` scope of `d` whose index is in `B`. -/
def EscIn (d : Decoded) (B : Nat) (st : OpSem.State) : Prop :=
  ∀ e ∈ st.escaped, ∃ j k sc a, B.testBit j = true ∧ d.scopes[j]? = some (k, sc) ∧
    sc.kind = .escape a ∧ sc.frameOffset.toInt = e.off ∧ sc.size = e.size

/-- Before instruction `k`'s scopes: the objects are in a set whose image under them is in
`at_[k]`. -/
def EscPre (d : Decoded) (at_ : Array Nat) (k : Nat) (st : OpSem.State) : Prop :=
  ∃ B, EscIn d B st ∧
    ∀ i, (applyStepsL (stepsAt d k) B).testBit i = true → (at_[k]!).testBit i = true

theorem EscIn.mono {d : Decoded} {B B' : Nat} {st : OpSem.State} (h : EscIn d B st)
    (hB : ∀ i, B.testBit i = true → B'.testBit i = true) : EscIn d B' st := by
  intro e he
  obtain ⟨j, k, sc, a, hb, h1, h2, h3, h4⟩ := h e he
  exact ⟨j, k, sc, a, hB j hb, h1, h2, h3, h4⟩

theorem EscIn.congr {d : Decoded} {B : Nat} {st st' : OpSem.State} (h : EscIn d B st)
    (he : st'.escaped = st.escaped) : EscIn d B st' := by
  intro e he'
  rw [he] at he'
  exact h e he'

theorem EscPre.congr {d : Decoded} {at_ : Array Nat} {k : Nat} {st st' : OpSem.State}
    (h : EscPre d at_ k st) (he : st'.escaped = st.escaped) : EscPre d at_ k st' := by
  obtain ⟨B, hB, hle⟩ := h
  exact ⟨B, hB.congr he, hle⟩

theorem applyStepsL_add (b : Nat) (l : List (Bool × Nat)) (B : Nat) :
    applyStepsL ((true, b) :: l) B = applyStepsL l (B ||| b) := rfl

theorem applyStepsL_del (b : Nat) (l : List (Bool × Nat)) (B : Nat) :
    applyStepsL ((false, b) :: l) B = applyStepsL l (diff B b) := rfl

/-! ### `coveredBy` -/

theorem coverStep_testBit {d : Decoded} {lo hi : Int} {b i j : Nat}
    (h : (coverStep d lo hi b i).testBit j = true) :
    b.testBit j = true ∨ (i = j ∧ ∃ k sc a, d.scopes[j]? = some (k, sc) ∧ sc.kind = .escape a ∧
      lo ≤ sc.frameOffset.toInt ∧ sc.frameOffset.toInt + sc.size ≤ hi) := by
  unfold coverStep at h
  cases hs : d.scopes[i]? with
  | none => simp only [hs] at h; exact .inl h
  | some p =>
    obtain ⟨k, sc⟩ := p
    simp only [hs] at h
    cases hk : sc.kind with
    | escape a =>
      simp only [hk] at h
      split at h
      · rename_i hc
        rw [Nat.testBit_or, Nat.one_shiftLeft, Nat.testBit_two_pow] at h
        cases hb : b.testBit j
        · rw [hb, Bool.false_or] at h
          have hij : i = j := of_decide_eq_true h
          subst hij
          exact .inr ⟨rfl, k, sc, a, hs, hk, hc.1, hc.2⟩
        · exact .inl rfl
      · exact .inl h
    | «end» => simp only [hk] at h; exact .inl h
    | lend => simp only [hk] at h; exact .inl h

theorem foldl_coverStep {d : Decoded} {lo hi : Int} {j : Nat} :
    ∀ (l : List Nat) (init : Nat), (l.foldl (coverStep d lo hi) init).testBit j = true →
      init.testBit j = true ∨ ∃ k sc a, d.scopes[j]? = some (k, sc) ∧ sc.kind = .escape a ∧
        lo ≤ sc.frameOffset.toInt ∧ sc.frameOffset.toInt + sc.size ≤ hi
  | [], init, h => .inl h
  | i :: l, init, h => by
    rw [List.foldl_cons] at h
    rcases foldl_coverStep l _ h with h | h
    · rcases coverStep_testBit h with h | ⟨-, h⟩
      · exact .inl h
      · exact .inr h
    · exact .inr h

/-- A bit of `coveredBy` is an `Escape` scope the range covers whole. -/
theorem testBit_coveredBy {d : Decoded} {lo hi : Int} {j : Nat}
    (h : (coveredBy d lo hi).testBit j = true) :
    ∃ k sc a, d.scopes[j]? = some (k, sc) ∧ sc.kind = .escape a ∧
      lo ≤ sc.frameOffset.toInt ∧ sc.frameOffset.toInt + sc.size ≤ hi := by
  unfold coveredBy at h
  rcases foldl_coverStep _ 0 h with h | h
  · rw [Nat.zero_testBit] at h; cases h
  · exact h

/-! ### The scopes -/

theorem escIn_scopes_aux (d : Decoded) :
    ∀ (M : List ((Nat × Scope) × Nat)) {B : Nat} {s s1 : R.RState},
      (∀ x ∈ M, d.scopes[x.2]? = some x.1) → EscIn d B s.st →
      (M.map (·.1.2)).foldlM R.applyScope s = .ok s1 →
      EscIn d (applyStepsL (M.filterMap fun ((_, sc), j) => scopeStep d sc j) B) s1.st
  | [], B, s, s1, _, hs, h => by cases h; exact hs
  | ((k, sc), j) :: M, B, s, s1, hM, hs, h => by
    simp only [List.map_cons, List.foldlM_cons, bind, Except.bind] at h
    have hj : d.scopes[j]? = some (k, sc) := hM _ (List.mem_cons_self ..)
    have hM' : ∀ x ∈ M, d.scopes[x.2]? = some x.1 := fun x hx => hM x (List.mem_cons_of_mem _ hx)
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s2 =>
      simp only [h1] at h
      unfold R.applyScope at h1
      split at h1
      · rename_i al hk
        simp only [List.filterMap_cons, scopeStep, hk]
        rw [applyStepsL_add]
        refine escIn_scopes_aux d M hM' ?_ h
        have hbit : (B ||| 1 <<< j).testBit j = true := by
          rw [Nat.testBit_or, Nat.one_shiftLeft, Nat.testBit_two_pow]; simp
        have hmono : ∀ i, B.testBit i = true → (B ||| 1 <<< j).testBit i = true := fun i hb => by
          rw [Nat.testBit_or, hb]; rfl
        rcases Ryo.Proofs.Scope.escape_ok h1 with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
        · exact hs.mono hmono
        · intro e he
          simp only [List.mem_append, List.mem_singleton] at he
          rcases he with he | rfl
          · exact (hs.mono hmono) e he
          · exact ⟨j, k, sc, al, hbit, hj, hk, rfl, rfl⟩
      · rename_i hk
        obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h1
        simp only [List.filterMap_cons, scopeStep, hk]
        rw [applyStepsL_del]
        refine escIn_scopes_aux d M hM' ?_ h
        intro e he
        change e ∈ st'.escaped at he
        rw [ScopeMem.writeFrame_escaped hw] at he
        obtain ⟨he0, hnc⟩ := List.mem_filter.1 he
        obtain ⟨j', k', sc', a', hb, hj', hk', ho, hsz⟩ := hs e he0
        refine ⟨j', k', sc', a', ?_, hj', hk', ho, hsz⟩
        rw [testBit_diff, hb, Bool.true_and]
        cases hc : (coveredBy d sc.frameOffset.toInt (sc.frameOffset.toInt + sc.size)).testBit j'
        · rfl
        · exfalso
          obtain ⟨k'', sc'', a'', hj'', -, h1', h2'⟩ := testBit_coveredBy hc
          rw [hj'] at hj''
          simp only [Option.some.injEq, Prod.mk.injEq] at hj''
          obtain ⟨-, rfl⟩ := hj''
          simp only [Function.comp, decide_eq_true_eq, Bool.not_eq_true', decide_eq_false_iff_not]
            at hnc
          omega
      · rename_i hk
        cases h1
        simp only [List.filterMap_cons, scopeStep, hk]
        exact escIn_scopes_aux d M hM' hs h

/-- R's scopes before `k` map the objects in `B` into `B`'s image under `stepsAt`. -/
theorem escIn_scopesAt {c : R.Code} {k B : Nat} {s s1 : R.RState} (hs : EscIn c.d B s.st)
    (h : (c.scopesAt k).foldlM R.applyScope s = .ok s1) :
    EscIn c.d (applyStepsL (stepsAt c.d k) B) s1.st := by
  have hsc : c.scopesAt k = (c.d.scopes.toList.zipIdx.filter (·.1.1 == k)).map (·.1.2) := by
    unfold R.Code.scopesAt
    have hz := List.zipIdx_map_fst 0 c.d.scopes.toList
    calc _ = ((c.d.scopes.toList.zipIdx.map Prod.fst).filter (·.1 == k)).map (·.2) := by rw [hz]
      _ = _ := by rw [List.filter_map, List.map_map]; rfl
  rw [hsc] at h
  unfold stepsAt
  refine escIn_scopes_aux c.d _ (fun x hx => ?_) hs h
  have := (List.mem_filter.1 hx).1
  rw [← Array.getElem?_toList]
  exact List.mem_zipIdx_iff_getElem?.1 this

/-! ### `escOk` -/

theorem escOk_spec {d : Decoded} {edges : Array (List Nat)} {at_ : Array Nat}
    (h : escOk d edges at_ = true) :
    at_.size = d.insns.size ∧
    (0 < d.insns.size →
      ∀ i, (applyStepsL (stepsAt d 0) 0).testBit i = true → (at_[0]!).testBit i = true) ∧
    ∀ k < d.insns.size, ∀ s ∈ edges[k]!, s < d.insns.size ∧
      ∀ i, (applyStepsL (stepsAt d s) at_[k]!).testBit i = true → (at_[s]!).testBit i = true := by
  unfold escOk at h
  simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq, List.all_eq_true, List.mem_range,
    decide_eq_true_eq] at h
  obtain ⟨⟨h1, h2⟩, h3⟩ := h
  refine ⟨h1, fun hn => ?_, fun k hk s hs => ?_⟩
  · rcases h2 with h2 | h2
    · omega
    · exact diff_eq_zero.1 h2
  · obtain ⟨h4, h5⟩ := h3 k hk s hs
    exact ⟨h4, diff_eq_zero.1 h5⟩

/-- At entry nothing is escaped. -/
theorem escPre_entry {d : Decoded} {edges : Array (List Nat)} {at_ : Array Nat}
    (h : escOk d edges at_ = true) (hn : 0 < d.insns.size) {st : OpSem.State}
    (he : st.escaped = []) : EscPre d at_ 0 st :=
  ⟨0, (fun e he' => by rw [he] at he'; cases he'), (escOk_spec h).2.1 hn⟩

/-- After `k`'s scopes the objects are in `at_[k]`. -/
theorem escIn_post {c : R.Code} {at_ : Array Nat} {k : Nat} {s s1 : R.RState}
    (hp : EscPre c.d at_ k s.st) (hsc : (c.scopesAt k).foldlM R.applyScope s = .ok s1) :
    EscIn c.d at_[k]! s1.st := by
  obtain ⟨B, hB, hle⟩ := hp
  exact (escIn_scopesAt hB hsc).mono hle

/-- Along an edge `k → s`: from objects in `at_[k]`, `EscPre` at `s`. -/
theorem escPre_succ {d : Decoded} {edges : Array (List Nat)} {at_ : Array Nat}
    (h : escOk d edges at_ = true) {k s : Nat} (hk : k < d.insns.size) (hs : s ∈ edges[k]!)
    {st : OpSem.State} (hin : EscIn d at_[k]! st) : EscPre d at_ s st :=
  ⟨at_[k]!, hin, ((escOk_spec h).2.2 k hk s hs).2⟩

/-- A step from `s` (at `k`) whose state after its scopes is `s1` and that keeps `escaped` from
there to `s'`, along an edge: `EscPre` carries over. (That every R transition is of this kind,
along `fl.edges`, is the R-level step lemmas' part.) -/
theorem escPre_next {c : R.Code} {at_ : Array Nat} {edges : Array (List Nat)}
    (h : escOk c.d edges at_ = true) {s s1 : R.RState} {k' : Nat} {st' : OpSem.State}
    (hk : s.pc < c.d.insns.size) (hp : EscPre c.d at_ s.pc s.st)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hkeep : st'.escaped = s1.st.escaped) (hedge : k' ∈ edges[s.pc]!) : EscPre c.d at_ k' st' :=
  escPre_succ h hk hedge ((escIn_post hp hsc).congr hkeep)

/-! ### Pointer accesses -/

theorem mapM_except_ok {α β ε : Type} (f : α → Except ε β) :
    ∀ (l : List α) (rs : List β), l.mapM f = .ok rs →
      ∀ i (hi : i < l.length), ∃ r, f l[i] = .ok r ∧ rs[i]? = some r
  | [], _, _, i, hi => by simp at hi
  | a :: l, rs, h, i, hi => by
    rw [List.mapM_cons] at h
    cases ha : f a with
    | error e => simp [ha, bind, Except.bind] at h
    | ok b =>
      cases hl : l.mapM f with
      | error e => simp [ha, hl, bind, Except.bind] at h
      | ok bs =>
        simp only [ha, hl, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
        subst h
        cases i with
        | zero => exact ⟨b, ha, rfl⟩
        | succ i =>
          obtain ⟨r, h1, h2⟩ := mapM_except_ok f l bs hl i (by simp at hi; omega)
          exact ⟨r, h1, h2⟩

theorem testBit_escBytesOf {d : Decoded} {st j k' : Nat} {sc : Scope} {i : Nat}
    (hb : st.testBit j = true) (hj : d.scopes[j]? = some (k', sc))
    (h1 : (Frame.range d.frameSize sc.frameOffset sc.size).1 ≤ i)
    (h2 : i < (Frame.range d.frameSize sc.frameOffset sc.size).2) :
    (escBytesOf d st).testBit i = true := by
  have hjl : j < d.scopes.size := by
    rcases Nat.lt_or_ge j d.scopes.size with hc | hc
    · exact hc
    · rw [Array.getElem?_eq_none hc] at hj; cases hj
  have hj! : d.scopes[j]! = (k', sc) := by
    simp [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hj]
  unfold escBytesOf
  rw [testBit_foldl_or, Nat.zero_testBit, Bool.false_or]
  refine List.any_eq_true.2 ⟨j, List.mem_range.2 hjl, ?_⟩
  unfold escBit
  rw [if_pos hb, hj!, testBit_bitsOf]
  simp [h1, h2]

/-- What `Flow.of` puts in `fl.esc` and `fl.pointer`: `esc` is `escapedAt` over the edges, and
at an instruction making a pointer access, `pointer` holds the bytes of every `Escape` scope in
`esc[k]`. -/
theorem flowOf_pointer {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {fl : Frame.Flow}
    (h : Flow.of d mode facts = .ok fl) {k : Nat} (hk : k < d.insns.size) :
    fl.esc = escapedAt d fl.edges ∧
    ∀ ef, Frame.effects d.insns[k]! (d.items[k]?.getD []) mode (Flow.lendsOf (scopesAt d) k)
        (facts.islandTemplate k) = .ok ef → ef.pointer = true →
      ∀ j, (fl.esc[k]!).testBit j = true → ∀ (k' : Nat) (sc : Scope), d.scopes[j]? = some (k', sc) →
        ∀ i, (Frame.range d.frameSize sc.frameOffset sc.size).1 ≤ i →
          i < (Frame.range d.frameSize sc.frameOffset sc.size).2 →
          (fl.pointer[k]!).testBit i = true := by
  unfold Flow.of at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  · rename_i rows hr
    simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    refine ⟨rfl, fun ef he hp j hb k' sc hj i h1 h2 => ?_⟩
    obtain ⟨r, hrow, hr2⟩ := mapM_except_ok _ _ rows hr k (by simpa using hk)
    have hpt : (((rows.map Flow.Row.pointer).toArray)[k]!) = r.pointer := by
      simp [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hr2]
    show (((rows.map Flow.Row.pointer).toArray)[k]!).testBit i = true
    rw [hpt]
    simp only [List.getElem_range] at hrow
    unfold Flow.row at hrow
    rw [he] at hrow
    simp only [bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hrow
    subst hrow
    show (if ef.pointer then _ else 0).testBit i = true
    rw [if_pos hp, if_pos (by simp [hp])]
    exact testBit_escBytesOf hb hj h1 h2

/-- An escaped byte of the frame at a pointer access is in `fl.pointer`'s bits. -/
theorem escaped_in_pointer {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {fl : Frame.Flow}
    (hf : Flow.of d mode facts = .ok fl) {k : Nat} (hk : k < d.insns.size) {st : OpSem.State}
    (hin : EscIn d fl.esc[k]! st) {ef : Frame.Effects}
    (he : Frame.effects d.insns[k]! (d.items[k]?.getD []) mode (Flow.lendsOf (scopesAt d) k)
        (facts.islandTemplate k) = .ok ef) (hp : ef.pointer = true)
    {e : EscapedObj} (hm : e ∈ st.escaped) {o : Int} (h1 : e.off ≤ o) (h2 : o < e.off + e.size)
    (h3 : -(d.frameSize : Int) ≤ o) (h4 : o < 0) :
    (fl.pointer[k]!).testBit (o + d.frameSize).toNat = true := by
  obtain ⟨j, k', sc, a, hb, hj, -, ho, hsz⟩ := hin e hm
  refine (flowOf_pointer hf hk).2 ef he hp j hb k' sc hj _ ?_ ?_ <;> simp only [Frame.range] <;> omega

end Ryo.Proofs.DeadStore
