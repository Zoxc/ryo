/-
Ryo.Proofs.Discharge.Nounwind — `NOUNWIND` cleanup entries (`FnCx::unwind_entry`, aot.md
§Unwinding): calls and islands with MIR `UnwindAction::Unreachable`, and direct calls of
non-unwinding `C` callees, get a `NOUNWIND` entry (`some (none, true)` in `Code.cleanupAt`)
when the body has no landing pads, none otherwise. "Has landing pads" is decided once the body
is lowered, over the emitted call-like instructions: one of them got a landing pad (a
`Cleanup` to a block that isn't a no-op landing pad, or a `Terminate`; `hasPads`, `hasPads_iff`).
A `Cleanup` to a no-op landing pad (rustc's `find_noop_landing_pads`, as cg_ssa) is a plain
continue entry (`unwindEntry_cleanup_noop`).

No Lean checker derives cleanup entries from MIR, so the rule itself is taken as the
abstract `unwindEntries` below (a mirror of `unwind_entry` over the emitted instructions'
actions, not a check of the backend's output). What is proved:

1. L0 side: unwinding out of an `Unreachable` call is UB (`applyUnwindAction_unreachable`), so
   any R behaviour at such a call refines it.
2. R side of the rule (`unwindEntry_unreachable_*`, `unwindAt_unreachable_*`): in a body without
   landing pads the entry makes R unwind out of the function (`Exit.unwind`, as a continue
   entry: a foreign exception passes through, as with cg_llvm's table); in one with landing
   pads there is no entry and R's unwind is UB (cg_llvm's gap, where the personality aborts).
3. A `NOUNWIND` entry never catches (`catchesAt_nounwind`; nor any entry of a pad-free body,
   `catchesAt_of_noPads`, `catchesAt_of_entries`), and is a continue one to the unwinder:
   `PadsLinked`'s pad is `none` at each of its return addresses (`padOf_nounwind`), as `lsdaPad`
   reads it (`lsdaPad` ignores the catch flag: `lsdaPad_of_noPad`).
4. Encoding: `Decoded.cleanupEntries` writes `(i, none, true)` as `nounwindTarget`
   (`cleanupEntries_nounwind`), which the image's `padParts` reads back as `(none, true)`
   (`padParts_nounwind`), distinct from `CONTINUE`'s `(none, false)`.
-/
import Ryo.Proofs.Discharge.PadsLinked
import Ryo.Obj.Image
import Ryo.Spec.Mir.Unwind

namespace Ryo.Proofs.DecodeSound

open Ryo.Vm Ryo.Vm.Asm Ryo.X86 Ryo.Vm.R Ryo.Proofs.DecodeLink

/-! ## L0: unwinding out of an `Unreachable` call is UB -/

theorem applyUnwindAction_unreachable (p : Ryo.Spec.Payload) :
    Ryo.Spec.Sem.applyUnwindAction .unreachable p =
      Ryo.Spec.throwUb "unwinding out of a call whose unwind action is `Unreachable`" := rfl

/-! ## The rule (`FnCx::unwind_entry`) -/

/-- Whether a call's unwind action gives it a landing pad: `Cleanup` to a block that isn't a
no-op landing pad (`noop`, rustc's `find_noop_landing_pads`), or `Terminate`. -/
def isPad (noop : Ryo.Spec.BasicBlock → Bool) : Ryo.Spec.UnwindAction → Bool
  | .cleanup bb => !noop bb
  | .terminate _ => true
  | _ => false

/-- `FnCx`'s `has_pads` once the body is lowered: some emitted call-like instruction (`acts`,
their unwind actions) got a landing pad (`hasPads_iff`). -/
def hasPads (noop : Ryo.Spec.BasicBlock → Bool) (acts : List Ryo.Spec.UnwindAction) : Bool :=
  acts.any (isPad noop)

/-- `FnCx::unwind_entry` on a MIR unwind action, as the `Code.cleanupAt` value it gives the
call, in a body whose `has_pads` is `hasPads`: `pad bb` is block `bb`'s landing pad, `term r`
the reason's terminate pad (a `CATCH` one), `Cleanup` to a no-op landing pad a continue entry.
A non-unwinding `C` callee is given `.unreachable`. -/
def unwindEntry (hasPads : Bool) (noop : Ryo.Spec.BasicBlock → Bool)
    (pad : Ryo.Spec.BasicBlock → Nat) (term : Ryo.Spec.TerminateReason → Nat) :
    Ryo.Spec.UnwindAction → Option (Option Nat × Bool)
  | .continue => some (none, false)
  | .unreachable => if hasPads then none else some (none, true)
  | .cleanup bb => if noop bb then some (none, false) else some (some (pad bb), false)
  | .terminate r => some (some (term r), true)

/-- The entries of a body's emitted call-like instructions, from their unwind actions `acts`
(in order): each `unwindEntry` with `has_pads` decided over all of them (`FnCx::blocks` sets the
`NOUNWIND` entries last). -/
def unwindEntries (noop : Ryo.Spec.BasicBlock → Bool) (pad : Ryo.Spec.BasicBlock → Nat)
    (term : Ryo.Spec.TerminateReason → Nat) (acts : List Ryo.Spec.UnwindAction) :
    List (Option (Option Nat × Bool)) :=
  acts.map (unwindEntry (hasPads noop acts) noop pad term)

theorem unwindEntry_unreachable_noPads (noop : Ryo.Spec.BasicBlock → Bool)
    (pad : Ryo.Spec.BasicBlock → Nat) (term : Ryo.Spec.TerminateReason → Nat) :
    unwindEntry false noop pad term .unreachable = some (none, true) := rfl

theorem unwindEntry_unreachable_pads (noop : Ryo.Spec.BasicBlock → Bool)
    (pad : Ryo.Spec.BasicBlock → Nat) (term : Ryo.Spec.TerminateReason → Nat) :
    unwindEntry true noop pad term .unreachable = none := rfl

/-- `Cleanup` to a no-op landing pad is a plain continue entry. -/
theorem unwindEntry_cleanup_noop {h : Bool} {noop : Ryo.Spec.BasicBlock → Bool}
    (pad : Ryo.Spec.BasicBlock → Nat) (term : Ryo.Spec.TerminateReason → Nat)
    {bb : Ryo.Spec.BasicBlock} (hb : noop bb = true) :
    unwindEntry h noop pad term (.cleanup bb) = some (none, false) := by
  simp [unwindEntry, hb]

/-- An entry has a landing pad exactly when its action `isPad`, whatever `has_pads` is. -/
theorem unwindEntry_pad_iff (h : Bool) (noop : Ryo.Spec.BasicBlock → Bool)
    (pad : Ryo.Spec.BasicBlock → Nat) (term : Ryo.Spec.TerminateReason → Nat)
    (a : Ryo.Spec.UnwindAction) :
    (∃ p cat, unwindEntry h noop pad term a = some (some p, cat)) ↔ isPad noop a = true := by
  cases a with
  | «continue» => simp [unwindEntry, isPad]
  | unreachable => cases h <;> simp [unwindEntry, isPad]
  | terminate r => simp [unwindEntry, isPad]
  | cleanup bb => cases hb : noop bb <;> simp [unwindEntry, isPad, hb]

/-- `has_pads` is "some emitted entry has a landing pad". -/
theorem hasPads_iff (noop : Ryo.Spec.BasicBlock → Bool) (pad : Ryo.Spec.BasicBlock → Nat)
    (term : Ryo.Spec.TerminateReason → Nat) (acts : List Ryo.Spec.UnwindAction) :
    hasPads noop acts = true ↔
      ∃ e ∈ unwindEntries noop pad term acts, ∃ p cat, e = some (some p, cat) := by
  show acts.any (isPad noop) = true ↔
    ∃ e ∈ acts.map (unwindEntry (hasPads noop acts) noop pad term), ∃ p cat, e = some (some p, cat)
  rw [List.any_eq_true]
  constructor
  · intro ⟨a, ha, hp⟩
    obtain ⟨p, cat, he⟩ := (unwindEntry_pad_iff (hasPads noop acts) noop pad term a).2 hp
    exact ⟨_, List.mem_map.2 ⟨a, ha, rfl⟩, p, cat, he⟩
  · intro ⟨e, hm, p, cat, he⟩
    obtain ⟨a, ha, rfl⟩ := List.mem_map.1 hm
    exact ⟨a, ha, (unwindEntry_pad_iff (hasPads noop acts) noop pad term a).1 ⟨p, cat, he⟩⟩

/-- A body without landing pads has no entry with one. -/
theorem unwindEntries_noPad {noop : Ryo.Spec.BasicBlock → Bool} {pad : Ryo.Spec.BasicBlock → Nat}
    {term : Ryo.Spec.TerminateReason → Nat} {acts : List Ryo.Spec.UnwindAction}
    (hno : hasPads noop acts = false) :
    ∀ e ∈ unwindEntries noop pad term acts, ∀ p cat, e ≠ some (some p, cat) := by
  intro e hm p cat he
  have h := (hasPads_iff noop pad term acts).2 ⟨e, hm, p, cat, he⟩
  rw [hno] at h
  exact Bool.false_ne_true h

/-- An emitted instruction's entry is `unwindEntry` of its action under the body's `has_pads`. -/
theorem unwindEntries_getElem? {noop : Ryo.Spec.BasicBlock → Bool}
    {pad : Ryo.Spec.BasicBlock → Nat} {term : Ryo.Spec.TerminateReason → Nat}
    {acts : List Ryo.Spec.UnwindAction} {i : Nat} {a : Ryo.Spec.UnwindAction}
    (hi : acts[i]? = some a) :
    (unwindEntries noop pad term acts)[i]? = some (unwindEntry (hasPads noop acts) noop pad term a) := by
  unfold unwindEntries
  simp [hi]

/-! ## R: what unwinding at the entry does -/

/-- A `NOUNWIND` entry unwinds out of the function, like a continue one. -/
theorem unwindAt_nounwind {c : Code} {s : RState} (exc : Ryo.Spec.ThinPointer)
    (h : c.cleanupAt s.pc = some (none, true)) :
    unwindAt c s exc = pure (.done (exit s (.unwind exc))) := by
  unfold unwindAt
  rw [h]

/-- No entry: R's unwind is UB. -/
theorem unwindAt_none {c : Code} {s : RState} (exc : Ryo.Spec.ThinPointer)
    (h : c.cleanupAt s.pc = none) :
    unwindAt c s exc = OpSem.ub s!"unwinding through instruction {s.pc}, which has no call-site entry" := by
  unfold unwindAt
  rw [h]

/-- The rule's entry at an `Unreachable` call (the `i`th emitted call-like instruction, whose
entry `s.pc` has), body without landing pads: R leaves the function. -/
theorem unwindAt_unreachable_noPads {c : Code} {s : RState} (exc : Ryo.Spec.ThinPointer)
    {noop : Ryo.Spec.BasicBlock → Bool} {pad : Ryo.Spec.BasicBlock → Nat}
    {term : Ryo.Spec.TerminateReason → Nat} {acts : List Ryo.Spec.UnwindAction} {i : Nat}
    (hi : acts[i]? = some .unreachable) (hno : hasPads noop acts = false)
    (h : (unwindEntries noop pad term acts)[i]? = some (c.cleanupAt s.pc)) :
    unwindAt c s exc = pure (.done (exit s (.unwind exc))) := by
  have he := Option.some.inj ((unwindEntries_getElem? hi).symm.trans h)
  rw [hno] at he
  exact unwindAt_nounwind exc (he.symm.trans (unwindEntry_unreachable_noPads noop pad term))

/-- The rule's entry at an `Unreachable` call, body with landing pads: R's unwind is UB. -/
theorem unwindAt_unreachable_pads {c : Code} {s : RState} (exc : Ryo.Spec.ThinPointer)
    {noop : Ryo.Spec.BasicBlock → Bool} {pad : Ryo.Spec.BasicBlock → Nat}
    {term : Ryo.Spec.TerminateReason → Nat} {acts : List Ryo.Spec.UnwindAction} {i : Nat}
    (hi : acts[i]? = some .unreachable) (hp : hasPads noop acts = true)
    (h : (unwindEntries noop pad term acts)[i]? = some (c.cleanupAt s.pc)) :
    unwindAt c s exc = OpSem.ub s!"unwinding through instruction {s.pc}, which has no call-site entry" := by
  have he := Option.some.inj ((unwindEntries_getElem? hi).symm.trans h)
  rw [hp] at he
  exact unwindAt_none exc (he.symm.trans (unwindEntry_unreachable_pads noop pad term))

/-! ## The search phase and the unwinder -/

theorem catchesAt_nounwind {c : Code} {k : Nat} (h : c.cleanupAt k = some (none, true)) :
    c.catchesAt k = false := by
  unfold Code.catchesAt
  rw [h]

/-- A body without landing pads catches nowhere (the search phase passes its frame). -/
theorem catchesAt_of_noPads {c : Code} (hno : ∀ k pad cat, c.cleanupAt k ≠ some (some pad, cat))
    (k : Nat) : c.catchesAt k = false := by
  unfold Code.catchesAt
  cases hc : c.cleanupAt k with
  | none => rfl
  | some e =>
    obtain ⟨p, cat⟩ := e
    cases p with
    | none => cases cat <;> rfl
    | some pad => exact absurd hc (hno k pad cat)

/-- A body whose entries are among the rule's, with no landing pads, catches nowhere. -/
theorem catchesAt_of_entries {c : Code} {noop : Ryo.Spec.BasicBlock → Bool}
    {pad : Ryo.Spec.BasicBlock → Nat} {term : Ryo.Spec.TerminateReason → Nat}
    {acts : List Ryo.Spec.UnwindAction} (hno : hasPads noop acts = false)
    (hc : ∀ k, c.cleanupAt k = none ∨ c.cleanupAt k ∈ unwindEntries noop pad term acts)
    (k : Nat) : c.catchesAt k = false :=
  catchesAt_of_noPads (fun k p cat heq => by
    cases hc k with
    | inl h => rw [h] at heq; cases heq
    | inr h => exact unwindEntries_noPad hno _ h p cat heq) k

/-- `PadsLinked` at a `NOUNWIND` entry: the unwinder has no pad at its return addresses. -/
theorem padOf_nounwind {S : Setup} (hP : PadsLinked S) {k : Nat} (hk : k < S.r.protos.size)
    (h : S.c.cleanupAt k = some (none, true)) {site : Nat × Nat}
    (hs : site ∈ S.r.protos[k].sites) {p : Nat} (h1 : site.1 < p) (h2 : p ≤ site.1 + site.2) :
    S.padOf (addrAt S.ctx p) = none := by
  rw [hP k hk site hs p h1 h2, h]

/-- `lsdaPad` at a site without a pad is `none`, whatever its catch flag (the LSDA writes a
`NOUNWIND` site as a continue one). -/
theorem lsdaPad_of_noPad {S : Setup} {p : Nat} {cs : Ryo.Obj.CallSite} (h : siteAt S.callSites p = some cs)
    (hp : cs.pad = none) : lsdaPad S p = none := by
  unfold lsdaPad
  rw [h]
  show Option.map (BitVec.ofNat 64) cs.pad = none
  rw [hp]
  rfl

/-! ## Encoding -/

theorem cleanupEntries_nounwind {d : Decoded} {i : Nat} (h : (i, none, true) ∈ d.cleanup) :
    ∃ e ∈ d.cleanupEntries, e.offset = d.wordPos[i]! ∧ e.target = nounwindTarget := by
  unfold Decoded.cleanupEntries
  exact ⟨_, Array.mem_map.2 ⟨_, h, rfl⟩, rfl, rfl⟩

theorem nounwindTarget_eq : nounwindTarget = Ryo.Obj.NOUNWIND := rfl

theorem padParts_nounwind : Ryo.Obj.padParts Ryo.Obj.NOUNWIND = (none, true) := by
  first
  | rfl
  | decide
  | simp [Ryo.Obj.padParts, Ryo.Obj.NOUNWIND, Ryo.Obj.CONTINUE]

theorem padParts_continue : Ryo.Obj.padParts Ryo.Obj.CONTINUE = (none, false) := by
  first
  | rfl
  | decide
  | simp [Ryo.Obj.padParts, Ryo.Obj.CONTINUE]

end Ryo.Proofs.DecodeSound
