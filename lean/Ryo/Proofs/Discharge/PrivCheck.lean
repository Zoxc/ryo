/-
Ryo.Proofs.Discharge.PrivCheck — what `privCheck` (`Ryo.Vm.PrivCheck`, run by
`Frame.decodeChecked`) says of the scopes: no `Escape` or `Lend` scope covers a link slot
(`link_of_check`), and no `Escape` scope that may have run before an `arg` covers its
destination (`arg_of_check`). With `FrameInv.esc` (`Discharge/EscFrom.lean`) they give
`Hyps.linkPrivate` and `Hyps.argPrivate`.
-/
import Ryo.Vm.PrivCheck
import Ryo.Vm.R.Sem

namespace Ryo.Proofs.Discharge.PrivCheck

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.R Ryo.Vm.Asm

/-- `privCheck`'s first half: no `Escape` scope covers a link slot, and no `Lend` extent at any
`k` does. -/
theorem link_of_check {c : R.Code} (hp : privCheck c.d = true) :
    (∀ p ∈ c.d.scopes.toList, p.2.isEscape = true → ∀ o : Int, 0 ≤ o → o < 16 →
      ¬ (p.2.frameOffset.toInt ≤ o ∧ o < p.2.frameOffset.toInt + p.2.size)) ∧
    ∀ k, ∀ l ∈ c.lendsAt k, ∀ o : Int, 0 ≤ o → o < 16 → ¬ (l.1 ≤ o ∧ o < l.1 + l.2) := by
  simp only [privCheck, Bool.and_eq_true] at hp
  have hl := List.all_eq_true.1 hp.1
  constructor
  · intro p hp' he o h0 h16 hr
    obtain ⟨h1, h2⟩ := hr
    have hm : rangesMeet p.2.frameOffset.toInt p.2.size 0 16 = true := by
      simp only [rangesMeet, decide_eq_true_eq]
      exact ⟨by omega, by omega⟩
    have := hl p hp'
    cases hkd : p.2.kind with
    | escape al => simp [hkd, hm] at this
    | «end» => simp [R.Scope.isEscape, hkd] at he
    | lend => simp [R.Scope.isEscape, hkd] at he
  · intro k l hlm
    unfold R.Code.lendsAt at hlm
    obtain ⟨sc, hsc, hsl⟩ := List.mem_filterMap.1 hlm
    unfold R.Code.scopesAt at hsc
    obtain ⟨p, hpm, rfl⟩ := List.mem_map.1 hsc
    have hp' := (List.mem_filter.1 hpm).1
    split at hsl
    next hk =>
      cases hsl
      intro o h0 h16 hr
      obtain ⟨h1, h2⟩ := hr
      have hk' : p.2.kind = .lend := by simpa using hk
      have hm : rangesMeet p.2.frameOffset.toInt p.2.size 0 16 = true := by
        simp only [rangesMeet, decide_eq_true_eq]
        exact ⟨by omega, by omega⟩
      have := hl p hp'
      simp [hk', hm] at this
    next => cases hsl

/-- `privCheck`'s second half, for an `arg d, w` at `k` reading `a`: no `Escape` scope covers
its destination, but (for a leading one, `c.d.leadUpTo k`) scopes after `k`. -/
theorem arg_of_check {c : R.Code} (hp : privCheck c.d = true) {k : Nat} {op : Reduced.Opcode}
    {d : BitVec 32} {w : BitVec 64} {f : Full.Opcode} {a : ArgReg}
    (hi : c.d.insns[k]? = some (.native op [.slot d, .imm w])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (ha : ArgReg.of? w.toNat true = some a) :
    ∀ p ∈ c.d.scopes.toList, p.2.isEscape = true → (c.d.leadUpTo k = true → p.1 ≤ k) →
      ∀ i < a.size, ¬ (p.2.frameOffset.toInt ≤ d.toInt + i ∧
        d.toInt + i < p.2.frameOffset.toInt + p.2.size) := by
  intro p hp' he hlead i hia hr
  obtain ⟨h1, h2⟩ := hr
  simp only [privCheck, Bool.and_eq_true] at hp
  have hk : k < c.d.insns.size := (Array.getElem?_eq_some_iff.1 hi).1
  have hd : c.d.insns[k]?.bind R.Insn.argDest = some (d.toInt, a.size) := by
    rw [hi, Option.bind_some]
    unfold R.Insn.argDest
    simp only [hf, hsh, beq_self_eq_true, ite_true, ha, Option.map_some]
  have h3 := List.all_eq_true.1 hp.2 k (List.mem_range.2 hk)
  simp only [hd] at h3
  have h4 := List.all_eq_true.1 h3 p hp'
  have hm : rangesMeet p.2.frameOffset.toInt p.2.size d.toInt a.size = true := by
    simp only [rangesMeet, decide_eq_true_eq]
    exact ⟨by omega, by omega⟩
  rw [he, hm] at h4
  cases hl : c.d.leadUpTo k with
  | false => simp [hl] at h4
  | true =>
    have := hlead hl
    simp [hl] at h4
    omega

end Ryo.Proofs.Discharge.PrivCheck
