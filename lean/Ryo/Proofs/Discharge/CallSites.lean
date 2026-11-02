/-
Ryo.Proofs.Discharge.CallSites — `StartsDistinct` and `SitesAligned` (`DecodeSound/Basic.lean`)
from the Lean-only check `callSitesCheck` (`Ryo/Vm/CallSitesCheck.lean`, run by
`Frame.decodeChecked`).

Strictly increasing starts (`startsSorted`) make the starts pairwise distinct
(`startsSorted_lt`, `startsDistinct_of_sorted`). `sitesAlignedOk` checks `SitesAligned`'s
statement with the shared return address `p` eliminated: the two ranges `(s, s + n]` and
`(start, start + len]` share a `p` only if `s < start + len`, `start < s + n` and both are
non-empty. `callSitesCheck` reruns `read`, which `Decodes.read` says gives `S.r`.
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Vm.CallSitesCheck

namespace Ryo.Proofs.DecodeSound

open Ryo.Vm Ryo.Vm.Asm Ryo.X86 Ryo.Vm.R Ryo.Proofs.DecodeLink

theorem startsSorted_tail {a : CallSite} {l : List CallSite} (h : startsSorted (a :: l) = true) :
    startsSorted l = true := by
  cases l with
  | nil => rfl
  | cons b rest =>
    simp only [startsSorted, Bool.and_eq_true] at h
    exact h.2

/-- The first start of a sorted list is below every later one. -/
theorem startsSorted_lt : ∀ {a : CallSite} {l : List CallSite}, startsSorted (a :: l) = true →
    ∀ b ∈ l, a.start < b.start
  | _, [], _, _, hb => by simp at hb
  | a, b :: rest, h, c, hc => by
    have h1 : a.start < b.start := by
      simp only [startsSorted, Bool.and_eq_true, decide_eq_true_eq] at h
      exact h.1
    have ih := startsSorted_lt (startsSorted_tail h)
    rcases List.mem_cons.1 hc with hcb | hc
    · rw [hcb]; exact h1
    · exact Nat.lt_trans h1 (ih c hc)

theorem startsDistinct_of_sorted : ∀ {l : List CallSite}, startsSorted l = true →
    ∀ a ∈ l, ∀ b ∈ l, a.start = b.start → a = b
  | [], _, _, ha, _, _, _ => by simp at ha
  | x :: l, h, a, ha, b, hb, he => by
    have hlt := startsSorted_lt h
    have ih := startsDistinct_of_sorted (startsSorted_tail h)
    rcases List.mem_cons.1 ha with hax | ha <;> rcases List.mem_cons.1 hb with hbx | hb
    · rw [hax, hbx]
    · rw [hax] at he
      exact absurd he (Nat.ne_of_lt (hlt b hb))
    · rw [hbx] at he
      exact absurd he.symm (Nat.ne_of_lt (hlt a ha))
    · exact ih a ha b hb he

/-- `StartsDistinct` from strictly increasing starts. -/
theorem startsDistinct_of_startsSorted {sites : Array CallSite}
    (h : startsSorted sites.toList = true) : StartsDistinct sites :=
  fun a ha b hb he =>
    startsDistinct_of_sorted h a (Array.mem_toList_iff.2 ha) b (Array.mem_toList_iff.2 hb) he

/-- `SitesAligned` from `sitesAlignedOk` on the read's instructions and the call sites. -/
theorem sitesAligned_of_ok {S : Setup} (h : sitesAlignedOk S.r.protos S.callSites = true) :
    SitesAligned S := by
  intro k hk site hs cs hcs p h1 h2 h3 h4
  simp only [sitesAlignedOk, List.all_eq_true, decide_eq_true_eq] at h
  exact h S.r.protos[k] (Array.getElem_mem_toList hk) site hs cs (Array.mem_toList_iff.2 hcs)
    (by omega) (by omega) (by omega) (by omega)

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- `StartsDistinct` and `SitesAligned` from the decoding and `callSitesCheck`. -/
theorem callSites_of_check (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hc : callSitesCheck code relocs rodata callSites dropped scopes mode = true) :
    StartsDistinct S.callSites ∧ SitesAligned S := by
  obtain ⟨c', hread⟩ := hD.read
  unfold callSitesCheck at hc
  rw [hread] at hc
  simp only [Bool.and_eq_true] at hc
  obtain ⟨hs, ha⟩ := hc
  rw [← hD.callSitesEq] at hs ha
  exact ⟨startsDistinct_of_startsSorted hs, sitesAligned_of_ok ha⟩

end Ryo.Proofs.DecodeSound
