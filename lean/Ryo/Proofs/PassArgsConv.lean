/-
Ryo.Proofs.PassArgsConv — what `passArgs` produces for C-variadic calls, and the calling
convention lemmas of `argPlan`.

**Variadic suffix.** For a C-variadic call (`variadic = some fixed`) `passArgs` returns the
list it builds for a non-variadic call followed by `varTail` (`passArgs_variadic`): on SysV
(`pe = false`) the single `al` entry `(.any, raxWord)` last (`passArgs_sysv_variadic`); on
Win64 each `xmm` piece of the inputs from `fixed` on, again, from the same home, in the
integer register of its position, `max size 4` rounded to a power of two
(`passArgs_win64_variadic`, `win64Dups`).

**Convention.** Every register piece `argPlan` assigns lands in an argument register the
convention has (`argPlan_locsOk`, `LocOk`): SysV integers in the first six (`rdi rsi rdx rcx
r8 r9`), SysV `xmm`s in `xmm0`-`xmm7`, Win64 both in the first four positions; `Indirect`
pointers likewise in integer registers. `nextReg_some` gives the register picked: on Win64 the
argument's position, on SysV the next free one of its class. For integer pieces the physical
register is the handler-call register of the index (`intArg_handlerReg`), never `rax`
(`intArg_ne_rax`); only the SysV variadic `al` entry (`argRax`) loads `rax`.
-/
import Ryo.Check.Lower.Plan
import Ryo.Check.Lower.CertCheck
import Ryo.Proofs.PassArgs

namespace Ryo.Proofs.PassArgsConv

open Ryo.Spec Ryo.Vm.Asm Ryo.Check.Lower Ryo.Proofs.Call

/-! ### The variadic suffix of `passArgs` -/

/-- The entries `passArgs` appends to a C-variadic call's argument list (`fixed`: the fixed
input count), after `out0`, the list of the non-variadic call: the same code as its last
block. -/
def varTail (plan : ArgPlan) (pe : Bool) (fixed : Nat) (out0 : List (SlotReq × Nat)) :
    Except String (List (SlotReq × Nat)) := do
  let mut out := out0
  if pe then
    for h : i in [fixed:plan.locs.length] do
      for l in plan.locs[i] do
        if let .reg r off := l then
          if r.xmm then out := out ++ [(.home i off, (ArgReg.mk false (roundPow2 (max r.size 4)) r.index false).word)]
  else
    out := out ++ [(.any, (ArgReg.mk false 1 argRax false).word)]
  return out

/-- A variadic call's list is the non-variadic one followed by `varTail`. -/
theorem passArgs_variadic (fc : FuncCert) (plan : ArgPlan) (sret tail pe : Bool) (fixed : Nat) :
    passArgs fc plan sret tail pe (some fixed) =
      passArgs fc plan sret tail pe none >>= varTail plan pe fixed := by
  cases sret <;> cases tail <;> cases hs : fc.sret <;>
    simp only [passArgs, varTail, hs, bind_assoc, pure_bind, ↓reduceIte, Bool.false_eq_true] <;> rfl

/-- SysV: the suffix is the one `al` entry. -/
theorem varTail_sysv (plan : ArgPlan) (fixed : Nat) (out0 : List (SlotReq × Nat)) :
    varTail plan false fixed out0 = .ok (out0 ++ [(.any, raxWord)]) := rfl

/-- SysV: a variadic call's list is the non-variadic one with `(.any, raxWord)` (the `al`
load, `rax` one byte, zero-extended: `of?_raxWord_call`) last. -/
theorem passArgs_sysv_variadic {fc : FuncCert} {plan : ArgPlan} {sret tail : Bool} {fixed : Nat}
    {out : List (SlotReq × Nat)} (h : passArgs fc plan sret tail false (some fixed) = .ok out) :
    ∃ pre, passArgs fc plan sret tail false none = .ok pre ∧ out = pre ++ [(.any, raxWord)] := by
  rw [passArgs_variadic] at h
  cases hp : passArgs fc plan sret tail false none with
  | error e => rw [hp] at h; cases h
  | ok pre =>
    rw [hp] at h
    change varTail plan false fixed pre = .ok out at h
    rw [varTail_sysv] at h
    cases h
    exact ⟨pre, rfl, rfl⟩

/-- A `.reg` piece's Win64 duplicate (input `i`): an `xmm` piece again, in the integer register
of its position. -/
def dupOf (i : Nat) : ArgLoc → Option (SlotReq × Nat)
  | .reg r off =>
    if r.xmm then some (.home i off, (ArgReg.mk false (roundPow2 (max r.size 4)) r.index false).word)
    else none
  | _ => none

/-- Input `i`'s Win64 duplicates. -/
def dupsAt (plan : ArgPlan) (i : Nat) : List (SlotReq × Nat) :=
  ((plan.locs[i]?).getD []).flatMap fun l => (dupOf i l).toList

/-- Win64's duplicates of a call with `fixed` fixed inputs: those of the variadic inputs, in
order. -/
def win64Dups (plan : ArgPlan) (fixed : Nat) : List (SlotReq × Nat) :=
  (List.range' fixed (plan.locs.length - fixed)).flatMap (dupsAt plan)

theorem forIn_append {α β ε : Type} (g : α → List β) :
    ∀ (l : List α) (init : List β) (body : α → List β → Except ε (ForInStep (List β))),
      (∀ a acc, body a acc = .ok (.yield (acc ++ g a))) →
      forIn l init body = .ok (init ++ l.flatMap g)
  | [], init, body, _ => by
    rw [List.forIn_nil, List.flatMap_nil, List.append_nil] <;> rfl
  | a :: l, init, body, hb => by
    have ih : forIn l (init ++ g a) body = .ok (init ++ (a :: l).flatMap g) := by
      rw [List.flatMap_cons, ← List.append_assoc]
      exact forIn_append g l _ body hb
    rw [List.forIn_cons, hb]
    exact ih

theorem forIn'_append {α β ε : Type} (g : α → List β) :
    ∀ (l : List α) (init : List β) (body : (a : α) → a ∈ l → List β → Except ε (ForInStep (List β))),
      (∀ a h acc, body a h acc = .ok (.yield (acc ++ g a))) →
      forIn' l init body = .ok (init ++ l.flatMap g)
  | [], init, body, _ => by
    rw [List.forIn'_nil, List.flatMap_nil, List.append_nil] <;> rfl
  | a :: l, init, body, hb => by
    have ih : forIn' l (init ++ g a) (fun a' m acc => body a' (List.mem_cons_of_mem a m) acc) =
        .ok (init ++ (a :: l).flatMap g) := by
      rw [List.flatMap_cons, ← List.append_assoc]
      exact forIn'_append g l _ _ (fun a' m acc => hb a' _ acc)
    rw [List.forIn'_cons, hb]
    exact ih

/-- Win64: the suffix is `win64Dups`. -/
theorem varTail_win64 (plan : ArgPlan) (fixed : Nat) (out0 : List (SlotReq × Nat)) :
    varTail plan true fixed out0 = .ok (out0 ++ win64Dups plan fixed) := by
  simp only [varTail, ↓reduceIte]
  rw [Std.Legacy.Range.forIn'_eq_forIn'_range', forIn'_append (dupsAt plan)]
  · simp only [win64Dups, Std.Legacy.Range.size, Nat.add_sub_cancel, Nat.div_one] <;> rfl
  · intro i hi acc
    have e : ∀ p, plan.locs[i]'p = (plan.locs[i]?).getD [] := fun p => by
      rw [List.getElem?_eq_getElem p]; rfl
    simp only [e]
    rw [forIn_append (fun l => (dupOf i l).toList)]
    · rfl
    · intro l acc'
      cases l with
      | reg r off =>
        cases hx : r.xmm <;> simp only [dupOf, hx, Option.toList, List.append_nil,
          ↓reduceIte, Bool.false_eq_true] <;> rfl
      | _ =>
        show _ = Except.ok (ForInStep.yield (acc' ++ []))
        rw [List.append_nil]; rfl

/-- Win64: a variadic call's list is the non-variadic one followed by `win64Dups`. -/
theorem passArgs_win64_variadic {fc : FuncCert} {plan : ArgPlan} {sret tail : Bool} {fixed : Nat}
    {out : List (SlotReq × Nat)} (h : passArgs fc plan sret tail true (some fixed) = .ok out) :
    ∃ pre, passArgs fc plan sret tail true none = .ok pre ∧ out = pre ++ win64Dups plan fixed := by
  rw [passArgs_variadic] at h
  cases hp : passArgs fc plan sret tail true none with
  | error e => rw [hp] at h; cases h
  | ok pre =>
    rw [hp] at h
    change varTail plan true fixed pre = .ok out at h
    rw [varTail_win64] at h
    cases h
    exact ⟨pre, rfl, rfl⟩

/-- A Win64 duplicate is an integer register word of the `xmm` piece's index, from the piece's
home, of 4 or 8 bytes. -/
theorem dupOf_some {i : Nat} {l : ArgLoc} {e : SlotReq × Nat} (h : dupOf i l = some e) :
    ∃ r off, l = .reg r off ∧ r.xmm = true ∧
      e = (.home i off, (ArgReg.mk false (roundPow2 (max r.size 4)) r.index false).word) := by
  cases l with
  | reg r off =>
    cases hx : r.xmm
    · simp [dupOf, hx] at h
    · simp only [dupOf, hx, ↓reduceIte, Option.some.injEq] at h
      exact ⟨r, off, rfl, hx, h.symm⟩
  | _ => cases h

/-- Every Win64 duplicate comes from an `xmm` piece of a variadic input. -/
theorem mem_win64Dups {plan : ArgPlan} {fixed : Nat} {e : SlotReq × Nat}
    (h : e ∈ win64Dups plan fixed) :
    ∃ i ls r off, fixed ≤ i ∧ i < plan.locs.length ∧ plan.locs[i]? = some ls ∧
      ArgLoc.reg r off ∈ ls ∧ r.xmm = true ∧
      e = (.home i off, (ArgReg.mk false (roundPow2 (max r.size 4)) r.index false).word) := by
  simp only [win64Dups, List.mem_flatMap, List.mem_range'_1] at h
  obtain ⟨i, ⟨hi1, hi2⟩, hd⟩ := h
  simp only [dupsAt, List.mem_flatMap] at hd
  obtain ⟨l, hl, he⟩ := hd
  have hlt : i < plan.locs.length := by omega
  have hget : plan.locs[i]? = some plan.locs[i] := List.getElem?_eq_getElem hlt
  rw [hget] at hl
  have hs : dupOf i l = some e := by
    cases hd : dupOf i l with
    | none => rw [hd] at he; cases he
    | some e' => rw [hd] at he; simp only [Option.toList, List.mem_singleton] at he; rw [he]
  obtain ⟨r, off, rfl, hx, rfl⟩ := dupOf_some hs
  exact ⟨i, plan.locs[i], r, off, hi1, hlt, hget, hl, hx, rfl⟩

/-! ### The convention: where `argPlan` puts the pieces -/

/-- The number of argument registers of a class: Win64 four positions, SysV six integer and
eight `xmm` registers. -/
def regBound (pe xmm : Bool) : Nat := if pe then 4 else if xmm then 8 else 6

/-- A piece in a register the convention has. -/
def LocOk (pe : Bool) : ArgLoc → Prop
  | .reg r _ => r.index < regBound pe r.xmm
  | .ptrReg i => i < regBound pe false
  | _ => True

def LocsOk (pe : Bool) (ls : List ArgLoc) : Prop := ∀ l ∈ ls, LocOk pe l

theorem LocsOk.append {pe : Bool} {a b : List ArgLoc} (ha : LocsOk pe a) (hb : LocsOk pe b) :
    LocsOk pe (a ++ b) := fun l hl => (List.mem_append.mp hl).elim (ha l) (hb l)

/-- A `PlanM` computation run from a state of convention `pe` succeeds only in a state of the
same convention, with a result satisfying `P`. -/
def PInv {α : Type} (pe : Bool) (P : α → Prop) (m : PlanM α) : Prop :=
  ∀ st a st', st.pe = pe → m.run st = .ok (a, st') → st'.pe = pe ∧ P a

theorem run_bind_ok {α β : Type} {x : PlanM α} {f : α → PlanM β} {s s'' : PlanState} {b : β}
    (h : (x >>= f).run s = .ok (b, s'')) :
    ∃ a s', x.run s = .ok (a, s') ∧ (f a).run s' = .ok (b, s'') := by
  simp only [StateT.run, bind, StateT.bind, Except.bind] at h
  split at h
  · cases h
  · rename_i v hv; exact ⟨v.1, v.2, hv, h⟩

theorem run_pure_ok {α : Type} {a b : α} {c c' : PlanState} (h : (pure a : PlanM α).run c = .ok (b, c')) :
    a = b ∧ c = c' := by
  simp only [StateT.run, pure, StateT.pure, Except.pure] at h; cases h; exact ⟨rfl, rfl⟩

theorem PInv.pure {α : Type} {pe : Bool} {P : α → Prop} {a : α} (h : P a) : PInv pe P (pure a) := by
  intro st b st' hp h'
  obtain ⟨rfl, rfl⟩ := run_pure_ok h'
  exact ⟨hp, h⟩

theorem PInv.throw {α : Type} {pe : Bool} {P : α → Prop} {e : String} :
    PInv pe P (throw e : PlanM α) := by
  intro st b st' _ h
  first
    | cases h
    | (simp only [StateT.run, throw, throwThe, MonadExceptOf.throw, StateT.lift, bind, Except.bind] at h
       cases h)

theorem PInv.bind {α β : Type} {pe : Bool} {x : PlanM α} {f : α → PlanM β} {Q : α → Prop}
    {P : β → Prop} (hx : PInv pe Q x) (hf : ∀ a, Q a → PInv pe P (f a)) : PInv pe P (x >>= f) := by
  intro st b st' hp h
  obtain ⟨a, s1, h1, h2⟩ := run_bind_ok h
  obtain ⟨hp1, hq⟩ := hx st a s1 hp h1
  exact hf a hq s1 b st' hp1 h2

theorem PInv.get {pe : Bool} : PInv pe (fun s : PlanState => s.pe = pe) (get : PlanM PlanState) := by
  intro st a st' hp h
  first
    | (cases h; exact ⟨hp, hp⟩)
    | (simp only [StateT.run, get, getThe, MonadStateOf.get, StateT.get, pure, Except.pure] at h
       cases h; exact ⟨hp, hp⟩)

theorem PInv.set {pe : Bool} {s : PlanState} (hs : s.pe = pe) :
    PInv pe (fun _ => True) (set s : PlanM PUnit) := by
  intro st a st' _ h
  first
    | (cases h; exact ⟨hs, trivial⟩)
    | (simp only [StateT.run, set, MonadStateOf.set, StateT.set, pure, Except.pure] at h
       cases h; exact ⟨hs, trivial⟩)

theorem PInv.forIn {α β : Type} {pe : Bool} {P : β → Prop} :
    ∀ (l : List α) (init : β) (f : α → β → PlanM (ForInStep β)),
      P init → (∀ a b, P b → PInv pe (fun r => P r.value) (f a b)) → PInv pe P (forIn l init f)
  | [], init, f, h0, _ => by rw [List.forIn_nil]; exact PInv.pure h0
  | a :: l, init, f, h0, hf => by
    rw [List.forIn_cons]
    refine PInv.bind (hf a init h0) (fun r hr => ?_)
    cases r with
    | done b => exact PInv.pure hr
    | yield b => exact PInv.forIn l b f hr hf

theorem PInv.mapM {α β : Type} {pe : Bool} {P : β → Prop} (f : α → PlanM β)
    (hf : ∀ a, PInv pe P (f a)) : ∀ l : List α, PInv pe (fun bs => ∀ b ∈ bs, P b) (l.mapM f)
  | [] => by rw [List.mapM_nil]; exact PInv.pure (by simp)
  | a :: l => by
    rw [List.mapM_cons]
    refine PInv.bind (hf a) (fun b hb => PInv.bind (PInv.mapM f hf l) (fun bs hbs => PInv.pure ?_))
    intro x hx
    rcases List.mem_cons.mp hx with rfl | hx
    · exact hb
    · exact hbs x hx

theorem nextReg_run (xmm : Bool) (st : PlanState) :
    (PlanM.nextReg xmm).run st = .ok (
      if st.pe then ((if st.pos < 4 then some st.pos else none), { st with pos := st.pos + 1 })
      else if xmm then
        if st.xmm < 8 then (some st.xmm, { st with xmm := st.xmm + 1 }) else (none, st)
      else
        if st.gpr < 6 then (some st.gpr, { st with gpr := st.gpr + 1 }) else (none, st)) := rfl

/-- The register `nextReg` picks: on Win64 the argument's position (`pos`), on SysV the next
free register of the class, within the convention's registers. -/
theorem nextReg_some {xmm : Bool} {st st' : PlanState} {i : Nat}
    (h : (PlanM.nextReg xmm).run st = .ok (some i, st')) :
    st'.pe = st.pe ∧ i < regBound st.pe xmm ∧
      i = (if st.pe then st.pos else if xmm then st.xmm else st.gpr) := by
  rw [nextReg_run] at h
  repeat' split at h
  all_goals (cases h <;> simp_all [regBound])

theorem nextReg_pe {xmm : Bool} {st st' : PlanState} {o : Option Nat}
    (h : (PlanM.nextReg xmm).run st = .ok (o, st')) : st'.pe = st.pe := by
  rw [nextReg_run] at h
  repeat' split at h
  all_goals (cases h <;> simp_all)

theorem inv_nextReg {pe : Bool} (xmm : Bool) :
    PInv pe (fun o => ∀ i, o = some i → i < regBound pe xmm) (PlanM.nextReg xmm) := by
  intro st o st' hp h
  subst hp
  refine ⟨nextReg_pe h, ?_⟩
  rintro i rfl
  exact (nextReg_some h).2.1

theorem slot_run (size : Nat) (st : PlanState) :
    (PlanM.slot size).run st =
      .ok (roundUp st.stack (if size == 16 && !st.pe then 16 else 8),
        { st with stack := roundUp st.stack (if size == 16 && !st.pe then 16 else 8) + roundUp size 8 }) :=
  rfl

theorem inv_slot {pe : Bool} {size : Nat} : PInv pe (fun _ => True) (PlanM.slot size) := by
  intro st a st' hp h
  rw [slot_run] at h
  cases h
  exact ⟨hp, trivial⟩

theorem inv_regOrStack {pe : Bool} (xmm : Bool) (size off : Nat) (ext : ArgExt) :
    PInv pe (LocsOk pe) (PlanM.regOrStack xmm size off ext) := by
  unfold PlanM.regOrStack
  refine PInv.bind (inv_nextReg xmm) (fun o ho => ?_)
  cases o with
  | some i =>
    refine PInv.pure ?_
    intro l hl
    rw [List.mem_singleton] at hl
    subst hl
    exact ho i rfl
  | none => exact PInv.bind inv_slot (fun _ _ => PInv.pure (by simp [LocsOk, LocOk]))

theorem inv_ptr {pe : Bool} : PInv pe (LocsOk pe) PlanM.ptr := by
  unfold PlanM.ptr
  refine PInv.bind (inv_nextReg false) (fun o ho => ?_)
  cases o with
  | some i =>
    refine PInv.pure ?_
    intro l hl
    rw [List.mem_singleton] at hl
    subst hl
    exact ho i rfl
  | none => exact PInv.bind inv_slot (fun _ _ => PInv.pure (by simp [LocsOk, LocOk]))

theorem inv_int {pe : Bool} (size off : Nat) (ext : ArgExt) :
    PInv pe (LocsOk pe) (PlanM.int size off ext) := by
  unfold PlanM.int
  refine PInv.bind PInv.get (fun s hs => ?_)
  try dsimp only
  split
  · exact PInv.bind (inv_regOrStack _ _ _ _) (fun a ha =>
      PInv.bind (inv_regOrStack _ _ _ _) (fun b hb => PInv.pure (LocsOk.append ha hb)))
  · split
    · split
      · refine PInv.bind (PInv.set hs) (fun _ _ => PInv.pure ?_)
        have hpe : pe = false := by
          cases hp' : s.pe <;> simp_all
        subst hpe
        intro l hl
        simp only [List.mem_cons, List.mem_nil_iff, or_false] at hl
        rcases hl with rfl | rfl <;>
          simp only [LocOk, regBound, Bool.false_eq_true, ↓reduceIte] <;> omega
      · exact PInv.bind inv_slot (fun _ _ => PInv.pure (by simp [LocsOk, LocOk]))
    · exact inv_regOrStack _ _ _ _

theorem inv_float {pe : Bool} (size off : Nat) : PInv pe (LocsOk pe) (PlanM.float size off) := by
  unfold PlanM.float
  refine PInv.bind PInv.get (fun s _ => ?_)
  try dsimp only
  split
  · exact inv_ptr
  · exact inv_regOrStack _ _ _ _

/-- `argPlan`'s loop over an input's pieces, appending each piece's locations. -/
theorem inv_forIn_pure {α : Type} {pe : Bool} (l : List α)
    (body : α → List ArgLoc → PlanM (ForInStep (List ArgLoc)))
    (hb : ∀ s acc, LocsOk pe acc → PInv pe (fun r => LocsOk pe r.value) (body s acc)) :
    PInv pe (LocsOk pe) (forIn l [] body >>= fun r => pure r) :=
  PInv.bind (PInv.forIn l [] body (fun _ h => by cases h) hb) (fun _ hr => PInv.pure hr)

/-- The convention lemma: every piece of every input of `argPlan`'s plan that it puts in a
register is in one of the convention's argument registers (`LocOk`). -/
theorem argPlan_locsOk {pe : Bool} {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan}
    (h : argPlan pe abi sret c = .ok plan) : ∀ ls ∈ plan.locs, LocsOk pe ls := by
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
  refine (PInv.mapM (pe := pe) (P := LocsOk pe) _ ?_ abi.args _ _ _ rfl hv).2
  intro a
  try dsimp only
  split
  · -- `.ignore`: `pure []`.
    exact PInv.bind (Q := LocsOk pe) (PInv.pure (fun _ h => by cases h)) (fun _ hr => PInv.pure hr)
  · -- `.indirect`: a pointer, or SysV C's `byval` copy, or an error.
    split
    · exact inv_ptr
    · split
      · split
        · exact PInv.bind (Q := fun _ => True) PInv.throw (fun _ _ =>
            PInv.bind PInv.get (fun _ hs => PInv.bind (PInv.set hs) (fun _ _ =>
              PInv.pure (by simp [LocsOk, LocOk]))))
        · exact PInv.bind PInv.get (fun _ hs => PInv.bind (PInv.set hs) (fun _ _ =>
            PInv.pure (by simp [LocsOk, LocOk])))
      · exact PInv.throw
  · -- The register modes: two refusal checks, then the loop over the pieces.
    split
    · split
      all_goals first
        | (with_reducible_and_instances
            refine PInv.bind (Q := fun _ => True) PInv.throw (fun _ _ => ?_))
        | skip
      all_goals try dsimp only
      all_goals split
      all_goals first
        | (with_reducible_and_instances
            refine PInv.bind (Q := fun _ => True) PInv.throw (fun _ _ => ?_))
        | skip
      all_goals
        refine inv_forIn_pure _ _ (fun s acc hacc => ?_)
        try dsimp only
        split
        · exact PInv.bind (Q := LocsOk pe) (inv_float _ _) (fun _ hd => PInv.pure (LocsOk.append hacc hd))
        · exact PInv.bind (Q := LocsOk pe) (inv_int _ _ _) (fun _ hd => PInv.pure (LocsOk.append hacc hd))
    · exact PInv.throw

/-- An integer argument register index the convention has is the handler-call register of
that position (`intArg`): `rdi rsi rdx rcx r8 r9`, on Win64 `rcx rdx r8 r9`. -/
theorem intArg_handlerReg {pe : Bool} {i : Nat} (h : i < regBound pe false) :
    handlerReg pe i = some (intArg pe i) := by
  cases pe <;> simp [regBound] at h <;> (obtain _|_|_|_|_|_|i := i) <;> first | rfl | omega

/-- Such a register is never `rax` (which only the SysV variadic `al` entry, index `argRax`,
loads). -/
theorem intArg_ne_rax {pe : Bool} {i : Nat} (h : i < regBound pe false) :
    intArg pe i ≠ Ryo.X86.Reg.rax := by
  cases pe <;> simp [regBound] at h <;> (obtain _|_|_|_|_|_|i := i) <;> first | decide | omega

theorem intArg_argRax : intArg false argRax = Ryo.X86.Reg.rax := rfl

/-- A register piece of an `argPlan` plan: an integer one in a convention register (never `rax`),
an `xmm` one in `xmm0`-`xmm7` (Win64: `xmm0`-`xmm3`). -/
theorem argPlan_reg {pe : Bool} {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan}
    (h : argPlan pe abi sret c = .ok plan) {ls : List ArgLoc} (hls : ls ∈ plan.locs)
    {r : ArgReg} {off : Nat} (hr : ArgLoc.reg r off ∈ ls) :
    (r.xmm = false → handlerReg pe r.index = some (intArg pe r.index) ∧ intArg pe r.index ≠ .rax) ∧
      (r.xmm = true → r.index < regBound pe true) := by
  have hb : r.index < regBound pe r.xmm := argPlan_locsOk h ls hls _ hr
  refine ⟨fun hx => ?_, fun hx => ?_⟩
  · rw [hx] at hb; exact ⟨intArg_handlerReg hb, intArg_ne_rax hb⟩
  · rw [hx] at hb; exact hb

/-- An `Indirect` input's pointer register of an `argPlan` plan is a convention register. -/
theorem argPlan_ptrReg {pe : Bool} {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan}
    (h : argPlan pe abi sret c = .ok plan) {ls : List ArgLoc} (hls : ls ∈ plan.locs)
    {i : Nat} (hr : ArgLoc.ptrReg i ∈ ls) :
    handlerReg pe i = some (intArg pe i) ∧ intArg pe i ≠ .rax := by
  have hb : i < regBound pe false := argPlan_locsOk h ls hls _ hr
  exact ⟨intArg_handlerReg hb, intArg_ne_rax hb⟩

end Ryo.Proofs.PassArgsConv
