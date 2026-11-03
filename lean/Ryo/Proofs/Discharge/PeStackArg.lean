/-
Ryo.Proofs.Discharge.PeStackArg — `Hyps.peStackArg` (PE's handler stack argument at the frame
offsets `[-F + 32, -F + 36)`) from the checks, up to a state invariant.

A five-argument handler call (the `atomic.cxchg` handlers') makes `shadowSize` 40, so
`frameLo = -F + 40` (`frameLo_of_five`), and:
- `F_ge_of_check`: `frameSizesCheck`'s `peStackArgCheck` (`shadowSize ≤ F`, run by
  `Frame.decodeChecked`) gives `40 ≤ F`, so `36 ≤ F`;
- `below_frameLo_scopes`: the bound check (`boundsOk`: every scope's range starts at or above
  `frameLo`) makes the scopes keep the bytes below `frameLo` private and `Uninit`: an
  `Escape` there doesn't cover them (`ScopeMem.escFree_foldlM`), and no scope makes a byte
  initialized (`End` writes `Uninit`, `uninit_foldlM`).
What the checks don't give is that the bytes are private and `Uninit` before the scopes: a
fact of the states R reaches, not of the decoded code (`FrameInv` doesn't record it; its
`FrameInit` allows initialized private bytes anywhere in `[-F, K)`). `Hyps.peArgSlots` states it.

This file doesn't import `DecodeSound/Basic.lean`, so `Basic.lean` can import it.
-/
import Ryo.Vm.FrameSizes
import Ryo.Proofs.ScopeMem

namespace Ryo.Proofs.Discharge.PeStackArg

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.R

/-- `frameSizesCheck` includes `peStackArgCheck`. -/
theorem peStackArgCheck_of_frameSizes {d : R.Decoded} {mode : Ryo.Obj.Mode}
    (h : frameSizesCheck d mode = true) : peStackArgCheck d mode = true := by
  unfold frameSizesCheck at h
  rw [Bool.and_eq_true] at h
  exact h.2

/-- A five-argument handler call makes PE's `shadowSize` 40. -/
theorem shadowSize_of_five {c : R.Code} (hpe : c.mode.pe = true) {k : Nat} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} (hi : c.d.insns[k]? = some (.handler h args t))
    (h5 : args.length = 5) : c.d.shadowSize c.mode = 40 := by
  unfold R.Decoded.shadowSize
  split
  · next hn => simp [hpe] at hn
  · split
    · rfl
    · next hno =>
      exfalso
      apply hno
      exact Array.any_eq_true'.2 ⟨_, Array.mem_of_getElem? hi, by simp [h5]⟩

/-- With a five-argument handler call on PE, `frameLo` is `-F + 40`. -/
theorem frameLo_of_five {c : R.Code} (hpe : c.mode.pe = true) {k : Nat} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} (hi : c.d.insns[k]? = some (.handler h args t))
    (h5 : args.length = 5) : c.d.frameLo c.mode = -(c.d.frameSize : Int) + 40 := by
  have hs := shadowSize_of_five hpe hi h5
  unfold R.Decoded.frameLo
  omega

/-- `frameSizesCheck` with a five-argument handler call on PE: `40 ≤ F`. -/
theorem F_ge_of_check {c : R.Code} (hc : frameSizesCheck c.d c.mode = true)
    (hpe : c.mode.pe = true) {k : Nat} {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat}
    (hi : c.d.insns[k]? = some (.handler h args t)) (h5 : args.length = 5) :
    40 ≤ c.d.frameSize := by
  have hs := shadowSize_of_five hpe hi h5
  have hp := peStackArgCheck_of_frameSizes hc
  unfold peStackArgCheck at hp
  have := of_decide_eq_true hp
  omega

/-- The bound check: every scope's range starts at or above `frameLo`. -/
theorem scopes_ge {c : R.Code} (hb : c.d.boundsOk c.mode = true) (k : Nat) :
    ∀ sc ∈ c.scopesAt k, c.d.frameLo c.mode ≤ sc.frameOffset.toInt := by
  unfold R.Decoded.boundsOk at hb
  simp only [Bool.and_eq_true] at hb
  have hall := hb.1.2
  intro sc hsc
  unfold R.Code.scopesAt at hsc
  obtain ⟨p, hp, rfl⟩ := List.mem_map.1 hsc
  have hp' := (List.mem_filter.1 hp).1
  have hr : (p.2.frameOffset.toInt, p.2.size) ∈ c.d.frameRanges c.mode := by
    unfold R.Decoded.frameRanges
    exact List.mem_append.2 (Or.inl (List.mem_map.2 ⟨p, hp', rfl⟩))
  exact of_decide_eq_true (List.all_eq_true.1 hall _ hr)

/-- A frame write of `Uninit` bytes keeps a byte `Uninit`. -/
theorem writeFrame_uninit {st st' : OpSem.State} {off : Int} {n : Nat} {o : Int}
    (h : st.writeFrame off (List.replicate n .uninit) = .ok st') (hu : st.frame o = .uninit) :
    st'.frame o = .uninit := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off (List.replicate n .uninit) with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    dsimp only
    split
    · rw [List.getD_eq_getElem?_getD, List.getElem?_replicate]
      split <;> rfl
    · exact hu

/-- A scope keeps a byte `Uninit`: `Escape` and `Lend` don't change the frame bytes, `End`
writes `Uninit`. -/
theorem uninit_applyScope {o : Int} {s s' : R.RState} {sc : R.Scope}
    (hu : s.st.frame o = .uninit) (h : R.applyScope s sc = .ok s') : s'.st.frame o = .uninit := by
  unfold R.applyScope at h
  split at h
  · rcases Ryo.Proofs.Scope.escape_ok h with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
    · exact hu
    · exact hu
  · obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h
    exact writeFrame_uninit hw hu
  · cases h; exact hu

theorem uninit_foldlM {o : Int} : ∀ (l : List R.Scope) {s s' : R.RState},
    s.st.frame o = .uninit → l.foldlM R.applyScope s = .ok s' → s'.st.frame o = .uninit
  | [], s, s', hu, h => by cases h; exact hu
  | sc :: l, s, s', hu, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      exact uninit_foldlM l (uninit_applyScope hu h1) h

/-- The bound check makes the scopes before any instruction keep the frame bytes in
`[lo, frameLo)` private and `Uninit`. -/
theorem below_frameLo_scopes {c : R.Code} (hb : c.d.boundsOk c.mode = true) {lo : Int}
    {k : Nat} {s s1 : R.RState}
    (hlow : ∀ o : Int, lo ≤ o → o < c.d.frameLo c.mode →
      s.st.escapedAt o = none ∧ s.st.frame o = .uninit)
    (hsc : (c.scopesAt k).foldlM R.applyScope s = .ok s1) :
    ∀ o : Int, lo ≤ o → o < c.d.frameLo c.mode →
      s1.st.escapedAt o = none ∧ s1.st.frame o = .uninit := by
  intro o h1 h2
  refine ⟨Ryo.Proofs.ScopeMem.escFree_foldlM (S := fun o' => lo ≤ o' ∧ o' < c.d.frameLo c.mode)
      (c.scopesAt k) ?_ (fun o' ho' => (hlow o' ho'.1 ho'.2).1) hsc o ⟨h1, h2⟩,
    uninit_foldlM (c.scopesAt k) (hlow o h1 h2).2 hsc⟩
  intro sc hsc' _ _ o' ho' hin
  have hge := scopes_ge hb k sc hsc'
  have ho2 := ho'.2
  have hin1 := hin.1
  omega

end Ryo.Proofs.Discharge.PeStackArg
