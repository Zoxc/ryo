/-
Ryo.Proofs.Lower.AllocsBelow — every live L0 allocation ends below `Target.ADDR_LIMIT`.

`Memory.allocate` only picks addresses with `addr + size < ADDR_LIMIT` (`Memory.addrOk`), and
nothing else creates an allocation or changes one's address or size, so this holds of every
reachable L0 memory. The split deref store (`SimDerefSplit.lean`) needs it: R offsets the
pointer by each piece's offset with a wrapping add, which agrees with L0's address only when the
stored range ends below the limit.

It is `DerefInv.below` (`FnSim.lean`), preserved with the rest of `DerefInv`:
`AllocsBelow.of_kept` for any change `MemKept` covers (its first component), `AllocsBelow.push`
for a fresh allocation (`DerefInv.push`'s premises).
-/
import Ryo.Spec

namespace Ryo.Proofs.Lower

open Ryo.Spec

/-- Every live allocation ends below `ADDR_LIMIT`. -/
def AllocsBelow (m : Memory) : Prop :=
  ∀ a x, m.get? a = some x → x.live = true → x.addr + x.data.size < Target.ADDR_LIMIT

/-- A memory change keeping each allocation's address and size and making none live (the first
component of `MemKept`) keeps `AllocsBelow`. -/
theorem AllocsBelow.of_kept {m m' : Memory} (h : AllocsBelow m)
    (hk : ∀ a x', m'.get? a = some x' → ∃ x, m.get? a = some x ∧ x.addr = x'.addr ∧
      (x'.live = true → x.live = true) ∧ x.data.size = x'.data.size) :
    AllocsBelow m' := by
  intro a x' hx' hl'
  obtain ⟨x, hx, ea, el, es⟩ := hk a x' hx'
  have := h a x hx (el hl')
  omega

/-- A fresh allocation at an address `Memory.addrOk` accepts keeps `AllocsBelow`. -/
theorem AllocsBelow.push {m : Memory} (h : AllocsBelow m) {a : Allocation} {size : Nat}
    {al : Align} (hdata : a.data = Array.replicate size .uninit)
    (hok : m.addrOk a.addr size al = true) : AllocsBelow { allocs := m.allocs.push a } := by
  have hget : ∀ c, ({ allocs := m.allocs.push a } : Memory).get? c =
      if c = m.allocs.size then some a else m.get? c := by
    intro c
    show (m.allocs.push a)[c]? = _
    first
      | (rw [Array.getElem?_push]; done)
      | (rw [Array.getElem?_push]; rfl)
      | (by_cases hc : c = m.allocs.size <;> simp [Array.getElem?_push, Memory.get?, hc])
  have hasz : a.data.size = size := by rw [hdata]; simp
  have hlt : a.addr + size < Target.ADDR_LIMIT := by
    unfold Memory.addrOk at hok
    first
      | (simp only [Bool.and_eq_true, decide_eq_true_eq] at hok; exact hok.1.2)
      | (simp only [Bool.and_eq_true, decide_eq_true_eq] at hok; exact hok.2.1)
      | (simp at hok; omega)
  intro c x hx hl
  rw [hget] at hx
  split at hx
  · obtain rfl := Option.some.inj hx
    omega
  · exact h c x hx hl

end Ryo.Proofs.Lower
