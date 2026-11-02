/-
Ryo.Proofs.PassArgsStack — the stack side of `argPlan`'s calling convention: where its stack
pieces (`stack`, `stackByval`, `ptrStack`) go in the stack argument area.

**Spans.** A stack piece covers `stackSpan`: `size` bytes from its offset (`ptrStack`: 8); the
other pieces cover none. `StackChain lo hi ls` says the stack pieces of `ls`, in order, start
at or after `lo`, each after the end of the one before, end by `hi`, and are aligned
(`StackAligned`: slots to 8; a `byval` copy to its `align`, at least 8).

**The plan.** For an `argPlan` plan, the pieces of all inputs in order form a chain from the
start of the area (`if pe then 32 else 0`: on Win64 after the 32 bytes of shadow space) to
`stackSize` (`argPlan_chain`), so each stack piece lies within the area after the shadow
space (`argPlan_stack_mem`), the pieces don't overlap and come in increasing order
(`argPlan_pairwise`, `StackBefore`), and the area is a multiple of 16 (`argPlan_stackSize_mod`),
on Win64 at least the shadow space (`argPlan_shadow`).

The proofs track the `PlanState.stack` cursor through the `PlanM` computations (`SInv`):
`slot` and `byval` round it up and move it past the piece; the register pieces leave it.
-/
import Ryo.Proofs.PassArgsConv

namespace Ryo.Proofs.PassArgsStack

open Ryo.Spec Ryo.Vm.Asm Ryo.Check.Lower Ryo.Proofs.PassArgsConv

/-! ### `roundUp` -/

theorem le_roundUp (n m : Nat) (hm : 0 < m) : n ≤ roundUp n m := by
  unfold roundUp
  have h1 := Nat.div_add_mod (n + m - 1) m
  have h2 := Nat.mod_lt (n + m - 1) hm
  rw [Nat.mul_comm] at h1
  omega

theorem roundUp_mod (n m : Nat) : roundUp n m % m = 0 := by
  unfold roundUp
  first
    | exact Nat.mod_eq_zero_of_dvd (Nat.dvd_mul_left _ _)
    | simp

/-! ### Spans and chains -/

/-- The bytes of the stack argument area a piece covers: offset and size. -/
def stackSpan : ArgLoc → Option (Nat × Nat)
  | .stack at_ _ size _ => some (at_, size)
  | .stackByval at_ size _ => some (at_, size)
  | .ptrStack at_ => some (at_, 8)
  | _ => none

/-- A stack piece's alignment: a slot 8-aligned, a `byval` copy aligned to its `align` (at
least 8). -/
def StackAligned : ArgLoc → Prop
  | .stack at_ _ _ _ => at_ % 8 = 0
  | .stackByval at_ _ align => at_ % align = 0 ∧ 8 ≤ align
  | .ptrStack at_ => at_ % 8 = 0
  | _ => True

/-- The stack pieces of the list in order, aligned, from `lo` on, each after the one before,
all ending by `hi`. -/
def StackChain : Nat → Nat → List ArgLoc → Prop
  | lo, hi, [] => lo ≤ hi
  | lo, hi, l :: ls => match stackSpan l with
    | none => StackChain lo hi ls
    | some (a, n) => lo ≤ a ∧ StackAligned l ∧ StackChain (a + n) hi ls

/-- `l1`'s span ends before `l2`'s starts (if both are stack pieces). -/
def StackBefore (l1 l2 : ArgLoc) : Prop :=
  ∀ a1 n1 a2 n2, stackSpan l1 = some (a1, n1) → stackSpan l2 = some (a2, n2) → a1 + n1 ≤ a2

theorem chain_cons_none {lo hi : Nat} {l : ArgLoc} {ls : List ArgLoc} (h : stackSpan l = none) :
    StackChain lo hi (l :: ls) ↔ StackChain lo hi ls := by
  first
    | simp only [StackChain, h]
    | simp [StackChain, h]

theorem chain_cons_some {lo hi a n : Nat} {l : ArgLoc} {ls : List ArgLoc}
    (h : stackSpan l = some (a, n)) :
    StackChain lo hi (l :: ls) ↔ (lo ≤ a ∧ StackAligned l ∧ StackChain (a + n) hi ls) := by
  first
    | simp only [StackChain, h]
    | simp [StackChain, h]

theorem StackChain.nil {lo hi : Nat} (h : lo ≤ hi) : StackChain lo hi [] := by
  simp only [StackChain]; exact h

theorem StackChain.nil_le {lo hi : Nat} (h : StackChain lo hi []) : lo ≤ hi := by
  simp only [StackChain] at h; exact h

theorem StackChain.le {lo hi : Nat} {ls : List ArgLoc} (h : StackChain lo hi ls) : lo ≤ hi := by
  induction ls generalizing lo with
  | nil => exact StackChain.nil_le h
  | cons l ls ih =>
    cases hs : stackSpan l with
    | none => exact ih ((chain_cons_none hs).mp h)
    | some p =>
      rcases p with ⟨a, n⟩
      obtain ⟨h1, _, h3⟩ := (chain_cons_some hs).mp h
      have := ih h3
      omega

theorem StackChain.mono_lo {lo lo' hi : Nat} {ls : List ArgLoc} (hl : lo' ≤ lo)
    (h : StackChain lo hi ls) : StackChain lo' hi ls := by
  induction ls with
  | nil => exact StackChain.nil (by have := StackChain.nil_le h; omega)
  | cons l ls ih =>
    cases hs : stackSpan l with
    | none => exact (chain_cons_none hs).mpr (ih ((chain_cons_none hs).mp h))
    | some p =>
      rcases p with ⟨a, n⟩
      obtain ⟨h1, h2, h3⟩ := (chain_cons_some hs).mp h
      exact (chain_cons_some hs).mpr ⟨by omega, h2, h3⟩

theorem StackChain.mono_hi {lo hi hi' : Nat} {ls : List ArgLoc} (hh : hi ≤ hi')
    (h : StackChain lo hi ls) : StackChain lo hi' ls := by
  induction ls generalizing lo with
  | nil => exact StackChain.nil (by have := StackChain.nil_le h; omega)
  | cons l ls ih =>
    cases hs : stackSpan l with
    | none => exact (chain_cons_none hs).mpr (ih ((chain_cons_none hs).mp h))
    | some p =>
      rcases p with ⟨a, n⟩
      obtain ⟨h1, h2, h3⟩ := (chain_cons_some hs).mp h
      exact (chain_cons_some hs).mpr ⟨h1, h2, ih h3⟩

theorem StackChain.append {lo mid hi : Nat} {xs ys : List ArgLoc} (hx : StackChain lo mid xs)
    (hy : StackChain mid hi ys) : StackChain lo hi (xs ++ ys) := by
  induction xs generalizing lo with
  | nil =>
    simp only [List.nil_append]
    exact StackChain.mono_lo (StackChain.nil_le hx) hy
  | cons l xs ih =>
    rw [List.cons_append]
    cases hs : stackSpan l with
    | none => exact (chain_cons_none hs).mpr (ih ((chain_cons_none hs).mp hx))
    | some p =>
      rcases p with ⟨a, n⟩
      obtain ⟨h1, h2, h3⟩ := (chain_cons_some hs).mp hx
      exact (chain_cons_some hs).mpr ⟨h1, h2, ih h3⟩

/-- A stack piece of a chain lies within its bounds, aligned. -/
theorem StackChain.mem {lo hi a n : Nat} {l : ArgLoc} {ls : List ArgLoc}
    (h : StackChain lo hi ls) (hl : l ∈ ls) (hs : stackSpan l = some (a, n)) :
    lo ≤ a ∧ a + n ≤ hi ∧ StackAligned l := by
  induction ls generalizing lo with
  | nil => cases hl
  | cons l' ls ih =>
    rcases List.mem_cons.mp hl with rfl | hl'
    · obtain ⟨h1, h2, h3⟩ := (chain_cons_some hs).mp h
      exact ⟨h1, StackChain.le h3, h2⟩
    · cases hs' : stackSpan l' with
      | none => exact ih ((chain_cons_none hs').mp h) hl'
      | some p =>
        rcases p with ⟨a', n'⟩
        obtain ⟨h1, _, h3⟩ := (chain_cons_some hs').mp h
        obtain ⟨k1, k2, k3⟩ := ih h3 hl'
        exact ⟨by omega, k2, k3⟩

/-- The stack pieces of a chain are in increasing order and don't overlap. -/
theorem StackChain.pairwise {lo hi : Nat} {ls : List ArgLoc} (h : StackChain lo hi ls) :
    ls.Pairwise StackBefore := by
  induction ls generalizing lo with
  | nil => exact List.Pairwise.nil
  | cons l ls ih =>
    refine List.Pairwise.cons ?_ ?_
    · intro l2 hl2 a1 n1 a2 n2 hs1 hs2
      obtain ⟨_, _, h3⟩ := (chain_cons_some hs1).mp h
      exact (StackChain.mem h3 hl2 hs2).1
    · cases hs : stackSpan l with
      | none => exact ih ((chain_cons_none hs).mp h)
      | some p =>
        rcases p with ⟨a, n⟩
        exact ih ((chain_cons_some hs).mp h).2.2

theorem StackChain.one_none {lo hi : Nat} {l : ArgLoc} (hl : stackSpan l = none) (h : lo ≤ hi) :
    StackChain lo hi [l] :=
  (chain_cons_none hl).mpr (StackChain.nil h)

theorem StackChain.one_some {lo hi a n : Nat} {l : ArgLoc} (hl : stackSpan l = some (a, n))
    (h1 : lo ≤ a) (h2 : StackAligned l) (h3 : a + n ≤ hi) : StackChain lo hi [l] :=
  (chain_cons_some hl).mpr ⟨h1, h2, StackChain.nil h3⟩

theorem StackChain.noStack {lo hi : Nat} :
    ∀ {ls : List ArgLoc}, (∀ l ∈ ls, stackSpan l = none) → lo ≤ hi → StackChain lo hi ls
  | [], _, h => StackChain.nil h
  | l :: _, hn, h =>
    (chain_cons_none (hn l (by simp))).mpr
      (StackChain.noStack (fun l' hl' => hn l' (List.mem_cons_of_mem _ hl')) h)

theorem chain_stack {lo hi a off size : Nat} {ext : ArgExt} (h1 : lo ≤ a) (h2 : a % 8 = 0)
    (h3 : a + size ≤ hi) : StackChain lo hi [.stack a off size ext] :=
  StackChain.one_some (l := .stack a off size ext) (a := a) (n := size) rfl h1 h2 h3

theorem chain_ptrStack {lo hi a : Nat} (h1 : lo ≤ a) (h2 : a % 8 = 0) (h3 : a + 8 ≤ hi) :
    StackChain lo hi [.ptrStack a] :=
  StackChain.one_some (l := .ptrStack a) (a := a) (n := 8) rfl h1 h2 h3

theorem chain_byval {s size al : Nat} (h8 : 8 ≤ al) :
    StackChain s (roundUp s al + roundUp size 8) [.stackByval (roundUp s al) size al] := by
  have h1 := le_roundUp s al (by omega)
  have h2 := roundUp_mod s al
  have h3 := le_roundUp size 8 (by decide)
  exact StackChain.one_some (l := .stackByval (roundUp s al) size al) (a := roundUp s al)
    (n := size) rfl h1 ⟨h2, h8⟩ (by omega)

/-! ### The stack cursor through `PlanM` -/

/-- A `PlanM` computation that, when it succeeds, relates the stack cursor before and after
and its result by `P`. -/
def SInv {α : Type} (P : Nat → Nat → α → Prop) (m : PlanM α) : Prop :=
  ∀ st a st', m.run st = .ok (a, st') → P st.stack st'.stack a

theorem SInv.imp {α : Type} {P P' : Nat → Nat → α → Prop} {m : PlanM α} (h : SInv P m)
    (hi : ∀ s1 s2 a, P s1 s2 a → P' s1 s2 a) : SInv P' m :=
  fun st a st' h' => hi _ _ _ (h st a st' h')

theorem SInv.pure {α : Type} {P : Nat → Nat → α → Prop} {a : α} (h : ∀ s, P s s a) :
    SInv P (pure a) := by
  intro st b st' h'
  obtain ⟨rfl, rfl⟩ := run_pure_ok h'
  exact h _

theorem throw_run_ne {α : Type} {e : String} {st : PlanState} {r : α × PlanState} :
    (throw e : PlanM α).run st ≠ .ok r := by
  intro h
  first
    | cases h
    | (simp only [StateT.run, throw, throwThe, MonadExceptOf.throw, StateT.lift, bind, Except.bind] at h
       cases h)

theorem SInv.throw {α : Type} {P : Nat → Nat → α → Prop} {e : String} :
    SInv P (MonadExcept.throw e : PlanM α) :=
  fun _ _ _ h => absurd h throw_run_ne

theorem SInv.throw_bind {α β : Type} {P : Nat → Nat → β → Prop} {e : String} {f : α → PlanM β} :
    SInv P ((MonadExcept.throw e : PlanM α) >>= f) := by
  intro st b st' h
  obtain ⟨a, s1, h1, _⟩ := run_bind_ok h
  exact absurd h1 throw_run_ne

theorem SInv.bind {α β : Type} {x : PlanM α} {f : α → PlanM β} {Q : Nat → Nat → α → Prop}
    {P : Nat → Nat → β → Prop} (hx : SInv Q x)
    (hf : ∀ a, SInv (fun s1 s2 b => ∀ s0, Q s0 s1 a → P s0 s2 b) (f a)) : SInv P (x >>= f) := by
  intro st b st' h
  obtain ⟨a, s1, h1, h2⟩ := run_bind_ok h
  exact hf a s1 b st' h2 st.stack (hx st a s1 h1)

theorem get_run {st a st' : PlanState} (h : (get : PlanM PlanState).run st = .ok (a, st')) :
    a = st ∧ st' = st := by
  first
    | (cases h; exact ⟨rfl, rfl⟩)
    | (simp only [StateT.run, get, getThe, MonadStateOf.get, StateT.get, pure, Except.pure] at h
       cases h; exact ⟨rfl, rfl⟩)

/-- A computation reading the state: its continuation starts from the state it read. -/
theorem SInv.get_bind {β : Type} {f : PlanState → PlanM β} {P : Nat → Nat → β → Prop}
    (hf : ∀ s, SInv (fun s1 s2 b => s1 = s.stack → P s1 s2 b) (f s)) :
    SInv P ((get : PlanM PlanState) >>= f) := by
  intro st b st' h
  obtain ⟨a, s1, h1, h2⟩ := run_bind_ok h
  obtain ⟨rfl, rfl⟩ := get_run h1
  exact hf _ _ _ _ h2 rfl

theorem set_run {s st st' : PlanState} {u : PUnit} (h : (set s : PlanM PUnit).run st = .ok (u, st')) :
    st' = s := by
  first
    | (cases h; rfl)
    | (simp only [StateT.run, set, MonadStateOf.set, StateT.set, pure, Except.pure] at h
       cases h; rfl)

theorem SInv.set {s : PlanState} : SInv (fun _ s2 _ => s2 = s.stack) (set s : PlanM PUnit) :=
  fun _ _ _ h => congrArg PlanState.stack (set_run h)

theorem SInv.forIn_rel {α β : Type} (R : Nat → Nat → β → Prop) :
    ∀ (l : List α) (init : β) (f : α → β → PlanM (ForInStep β)),
      (∀ a b, SInv (fun s1 s2 r => ∀ s0, R s0 s1 b → R s0 s2 r.value) (f a b)) →
      SInv (fun s1 s2 r => ∀ s0, R s0 s1 init → R s0 s2 r) (forIn l init f)
  | [], init, f, _ => by
    rw [List.forIn_nil]
    exact SInv.pure (fun _ _ h => h)
  | a :: l, init, f, hf => by
    rw [List.forIn_cons]
    refine SInv.bind (hf a init) (fun r => ?_)
    cases r with
    | done b => exact SInv.pure (fun _ _ hq s0 h0 => hq s0 h0)
    | yield b =>
      exact SInv.imp (SInv.forIn_rel R l b f hf) (fun _ _ _ hx _ hq s0 h0 => hx s0 (hq s0 h0))

theorem SInv.mapM {α : Type} (f : α → PlanM (List ArgLoc)) (hf : ∀ a, SInv StackChain (f a)) :
    ∀ l : List α, SInv (fun s1 s2 bs => StackChain s1 s2 bs.flatten) (l.mapM f)
  | [] => by
    rw [List.mapM_nil]
    exact SInv.pure (fun s => StackChain.nil (Nat.le_refl s))
  | a :: l => by
    rw [List.mapM_cons]
    refine SInv.bind (hf a) (fun b => SInv.bind (SInv.mapM f hf l) (fun bs => SInv.pure ?_))
    intro s s1 h1 s0 h0
    exact StackChain.append h0 h1

/-! ### The `PlanM` steps -/

theorem sinv_nextReg {xmm : Bool} : SInv (fun s1 s2 _ => s2 = s1) (PlanM.nextReg xmm) := by
  intro st o st' h
  rw [nextReg_run] at h
  repeat' split at h
  all_goals (cases h; rfl)

theorem slot_facts {size : Nat} {st st' : PlanState} {at_ : Nat}
    (h : (PlanM.slot size).run st = .ok (at_, st')) :
    st.stack ≤ at_ ∧ at_ % 8 = 0 ∧ st'.stack = at_ + roundUp size 8 := by
  rw [slot_run] at h
  cases h
  refine ⟨le_roundUp _ _ ?_, ?_, rfl⟩
  · split <;> decide
  · split
    · have := roundUp_mod st.stack 16; omega
    · exact roundUp_mod st.stack 8

theorem sinv_slot {size : Nat} :
    SInv (fun s1 s2 at_ => s1 ≤ at_ ∧ at_ % 8 = 0 ∧ s2 = at_ + roundUp size 8) (PlanM.slot size) :=
  fun _ _ _ h => slot_facts h

theorem chain_regOrStack (xmm : Bool) (size off : Nat) (ext : ArgExt) :
    SInv StackChain (PlanM.regOrStack xmm size off ext) := by
  unfold PlanM.regOrStack
  refine SInv.bind sinv_nextReg (fun o => ?_)
  cases o with
  | some i =>
    refine SInv.pure (fun x s0 hx => ?_)
    exact StackChain.one_none (by rfl) (Nat.le_of_eq (Eq.symm hx))
  | none =>
    refine SInv.bind sinv_slot (fun at_ => SInv.pure (fun x s0 hq s0' he => ?_))
    have hq' : s0 ≤ at_ ∧ at_ % 8 = 0 ∧ x = at_ + roundUp (max size 8) 8 := hq
    have he' : s0 = s0' := he
    have h3 := le_roundUp (max size 8) 8 (by decide)
    have h4 := Nat.le_max_left size 8
    exact chain_stack (by omega) hq'.2.1 (by omega)

theorem chain_ptr : SInv StackChain PlanM.ptr := by
  unfold PlanM.ptr
  refine SInv.bind sinv_nextReg (fun o => ?_)
  cases o with
  | some i =>
    refine SInv.pure (fun x s0 hx => ?_)
    exact StackChain.one_none (by rfl) (Nat.le_of_eq (Eq.symm hx))
  | none =>
    refine SInv.bind sinv_slot (fun at_ => SInv.pure (fun x s0 hq s0' he => ?_))
    have hq' : s0 ≤ at_ ∧ at_ % 8 = 0 ∧ x = at_ + roundUp 8 8 := hq
    have he' : s0 = s0' := he
    have h3 := le_roundUp 8 8 (by decide)
    exact chain_ptrStack (by omega) hq'.2.1 (by omega)

theorem chain_int (size off : Nat) (ext : ArgExt) : SInv StackChain (PlanM.int size off ext) := by
  unfold PlanM.int
  refine SInv.get_bind (fun s => ?_)
  try dsimp only
  split
  · refine SInv.bind (chain_regOrStack _ _ _ _) (fun a =>
      SInv.bind (chain_regOrStack _ _ _ _) (fun b => SInv.pure ?_))
    intro x s1 hb s0 ha _
    exact StackChain.append ha hb
  · split
    · split
      · refine SInv.bind SInv.set (fun _ => SInv.pure (fun x s0 hx h0 => ?_))
        have hx' : x = s.stack := hx
        have h0' : s0 = s.stack := h0
        refine StackChain.noStack (fun l hl => ?_) (by omega)
        simp only [List.mem_cons, List.mem_nil_iff, or_false] at hl
        rcases hl with rfl | rfl <;> rfl
      · refine SInv.bind sinv_slot (fun at_ => SInv.pure (fun x s0 hq _ => ?_))
        have hq' : s0 ≤ at_ ∧ at_ % 8 = 0 ∧ x = at_ + roundUp 16 8 := hq
        have h3 := le_roundUp 16 8 (by decide)
        exact chain_stack hq'.1 hq'.2.1 (by omega)
    · exact SInv.imp (chain_regOrStack _ _ _ _) (fun _ _ _ h _ => h)

theorem chain_float (size off : Nat) : SInv StackChain (PlanM.float size off) := by
  unfold PlanM.float
  refine SInv.get_bind (fun s => ?_)
  try dsimp only
  split
  · exact SInv.imp chain_ptr (fun _ _ _ h _ => h)
  · exact SInv.imp (chain_regOrStack _ _ _ _) (fun _ _ _ h _ => h)

/-- `argPlan`'s loop over an input's pieces, appending each piece's locations. -/
theorem chain_forIn_pure {α : Type} (l : List α)
    (body : α → List ArgLoc → PlanM (ForInStep (List ArgLoc)))
    (hb : ∀ s acc, SInv (fun s1 s2 r => ∀ s0, StackChain s0 s1 acc → StackChain s0 s2 r.value)
      (body s acc)) :
    SInv StackChain (forIn l [] body >>= fun r => pure r) :=
  SInv.bind (SInv.forIn_rel StackChain l [] body hb)
    (fun _ => SInv.pure (fun _ s0' hq => hq s0' (StackChain.nil (Nat.le_refl s0'))))

/-! ### `argPlan`'s stack layout -/

/-- The stack lemma: the pieces of `argPlan`'s plan, all inputs in order, form a chain from
the start of the argument area (on Win64 after the 32 bytes of shadow space) to the cursor
`s` whose rounding up to 16 is `stackSize`. -/
theorem argPlan_chain {pe : Bool} {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan}
    (h : argPlan pe abi sret c = .ok plan) :
    ∃ s, plan.stackSize = roundUp s 16 ∧ StackChain (if pe then 32 else 0) s plan.locs.flatten := by
  unfold argPlan at h
  try dsimp only at h
  have bind_ok : ∀ {α β : Type} {x : Except String α} {f : α → Except String β} {b : β},
      (x >>= f) = .ok b → ∃ a, x = .ok a ∧ f a = .ok b := by
    intro α β x f b h
    cases x with
    | error e => cases h
    | ok a => exact ⟨a, rfl, h⟩
  obtain ⟨⟨locs, st1⟩, hv, h2⟩ := bind_ok h
  cases h2
  refine ⟨st1.stack, rfl, ?_⟩
  refine SInv.mapM _ ?_ abi.args _ _ _ hv
  intro a
  try dsimp only
  split
  · -- `.ignore`: `pure []`.
    first
      | exact SInv.pure (fun s => StackChain.nil (Nat.le_refl s))
      | exact SInv.bind (Q := StackChain) (SInv.pure (fun s => StackChain.nil (Nat.le_refl s)))
          (fun _ => SInv.pure (fun _ _ h => h))
  · -- `.indirect`: a pointer, or SysV C's `byval` copy, or an error.
    split
    · exact chain_ptr
    · split
      · split
        · first
            | exact SInv.throw_bind
            | (with_reducible_and_instances exact SInv.throw_bind)
        · refine SInv.get_bind (fun s => ?_)
          refine SInv.bind SInv.set (fun _ => SInv.pure ?_)
          intro x s0 hx h0
          subst hx
          subst h0
          exact chain_byval (Nat.le_max_left _ _)
      · exact SInv.throw
  · -- The register modes: two refusal checks, then the loop over the pieces.
    split
    · split
      all_goals first
        | (with_reducible_and_instances exact SInv.throw_bind)
        | exact SInv.throw_bind
        | skip
      all_goals try dsimp only
      all_goals split
      all_goals first
        | (with_reducible_and_instances exact SInv.throw_bind)
        | exact SInv.throw_bind
        | skip
      all_goals
        refine chain_forIn_pure _ _ (fun s acc => ?_)
        try dsimp only
        split
        · exact SInv.bind (Q := StackChain) (chain_float _ _)
            (fun _ => SInv.pure (fun _ _ hd _ hacc => StackChain.append hacc hd))
        · exact SInv.bind (Q := StackChain) (chain_int _ _ _)
            (fun _ => SInv.pure (fun _ _ hd _ hacc => StackChain.append hacc hd))
    · exact SInv.throw

/-- Every stack piece of an `argPlan` plan lies in the argument area, after Win64's shadow
space and within `stackSize`, aligned (slots to 8, `byval` copies to their `align` ≥ 8). -/
theorem argPlan_stack_mem {pe : Bool} {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan}
    (h : argPlan pe abi sret c = .ok plan) {ls : List ArgLoc} (hls : ls ∈ plan.locs)
    {l : ArgLoc} (hl : l ∈ ls) {a n : Nat} (hs : stackSpan l = some (a, n)) :
    (if pe then 32 else 0) ≤ a ∧ a + n ≤ plan.stackSize ∧ StackAligned l := by
  obtain ⟨s, hsz, hc⟩ := argPlan_chain h
  have hc' : StackChain (if pe then 32 else 0) plan.stackSize plan.locs.flatten := by
    rw [hsz]; exact StackChain.mono_hi (le_roundUp s 16 (by decide)) hc
  exact StackChain.mem hc' (List.mem_flatten.mpr ⟨ls, hls, hl⟩) hs

/-- The stack pieces of an `argPlan` plan, all inputs in order, are increasing and disjoint. -/
theorem argPlan_pairwise {pe : Bool} {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan}
    (h : argPlan pe abi sret c = .ok plan) : plan.locs.flatten.Pairwise StackBefore := by
  obtain ⟨s, _, hc⟩ := argPlan_chain h
  exact StackChain.pairwise hc

/-- The stack argument area is a multiple of 16. -/
theorem argPlan_stackSize_mod {pe : Bool} {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan}
    (h : argPlan pe abi sret c = .ok plan) : plan.stackSize % 16 = 0 := by
  obtain ⟨s, hsz, _⟩ := argPlan_chain h
  rw [hsz]; exact roundUp_mod s 16

/-- On Win64 the area holds at least the 32 bytes of shadow space. -/
theorem argPlan_shadow {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan}
    (h : argPlan true abi sret c = .ok plan) : 32 ≤ plan.stackSize := by
  obtain ⟨s, hsz, hc⟩ := argPlan_chain h
  have h1 : 32 ≤ s := by simpa using StackChain.le hc
  have h2 := le_roundUp s 16 (by decide)
  rw [hsz]
  omega

end Ryo.Proofs.PassArgsStack
