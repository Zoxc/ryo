/-
Ryo.Proofs.Discharge.Nounwind — `NOUNWIND` cleanup entries (`FnCx::unwind_entry`, aot.md
§Unwinding): calls and islands with MIR `UnwindAction::Unreachable`, and direct calls of
non-unwinding `C` callees, get a `NOUNWIND` entry (`some (none, true)` in `Code.cleanupAt`)
when the body has no landing pad, none otherwise.

No Lean checker derives cleanup entries from MIR, so the rule itself is taken as the
abstract `unwindEntry` below (a mirror of `unwind_entry`, not a check of the backend's output).
What is proved:

1. L0 side: unwinding out of an `Unreachable` call is UB (`applyUnwindAction_unreachable`), so
   any R behaviour at such a call refines it.
2. R side of the rule (`unwindEntry_unreachable_*`, `unwindAt_unreachable_*`): in a body without
   landing pads the entry makes R unwind out of the function (`Exit.unwind`, as a continue
   entry: a foreign exception passes through, as with cg_llvm's table); in one with landing
   pads there is no entry and R's unwind is UB (cg_llvm's gap, where the personality aborts).
3. A `NOUNWIND` entry never catches (`catchesAt_nounwind`; nor any entry of a pad-free body,
   `catchesAt_of_noPads`), and is a continue one to the unwinder: `PadsLinked`'s pad is
   `none` at each of its return addresses (`padOf_nounwind`), as `lsdaPad` reads it
   (`lsdaPad` ignores the catch flag: `lsdaPad_of_noPad`).
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

/-- `FnCx::unwind_entry` on a MIR unwind action, as the `Code.cleanupAt` value it gives the
call: `pad bb` is block `bb`'s landing pad, `term r` the reason's terminate pad (a `CATCH`
one). A non-unwinding `C` callee is given `.unreachable`. -/
def unwindEntry (hasPads : Bool) (pad : Ryo.Spec.BasicBlock → Nat)
    (term : Ryo.Spec.TerminateReason → Nat) : Ryo.Spec.UnwindAction → Option (Option Nat × Bool)
  | .continue => some (none, false)
  | .unreachable => if hasPads then none else some (none, true)
  | .cleanup bb => some (some (pad bb), false)
  | .terminate r => some (some (term r), true)

theorem unwindEntry_unreachable_noPads (pad : Ryo.Spec.BasicBlock → Nat)
    (term : Ryo.Spec.TerminateReason → Nat) :
    unwindEntry false pad term .unreachable = some (none, true) := rfl

theorem unwindEntry_unreachable_pads (pad : Ryo.Spec.BasicBlock → Nat)
    (term : Ryo.Spec.TerminateReason → Nat) :
    unwindEntry true pad term .unreachable = none := rfl

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

/-- The rule's entry at an `Unreachable` call, pad-free body: R leaves the function. -/
theorem unwindAt_unreachable_noPads {c : Code} {s : RState} (exc : Ryo.Spec.ThinPointer)
    {pad : Ryo.Spec.BasicBlock → Nat} {term : Ryo.Spec.TerminateReason → Nat}
    (h : c.cleanupAt s.pc = unwindEntry false pad term .unreachable) :
    unwindAt c s exc = pure (.done (exit s (.unwind exc))) :=
  unwindAt_nounwind exc (h.trans (unwindEntry_unreachable_noPads pad term))

/-- The rule's entry at an `Unreachable` call, body with pads: R's unwind is UB. -/
theorem unwindAt_unreachable_pads {c : Code} {s : RState} (exc : Ryo.Spec.ThinPointer)
    {pad : Ryo.Spec.BasicBlock → Nat} {term : Ryo.Spec.TerminateReason → Nat}
    (h : c.cleanupAt s.pc = unwindEntry true pad term .unreachable) :
    unwindAt c s exc = OpSem.ub s!"unwinding through instruction {s.pc}, which has no call-site entry" :=
  unwindAt_none exc (h.trans (unwindEntry_unreachable_pads pad term))

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
