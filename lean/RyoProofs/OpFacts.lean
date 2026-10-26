/-
RyoProofs.OpFacts — `OpFacts` for every opcode (aot.md §C2, toward `decode_sound`).

- `tablesOk_true`: every handler kind fits its opcode's shape (`kindFits`,
  `Ryo/Proofs/OpFacts.lean`), checked over the handler and info tables zipped: a
  `decide +kernel` over the 901 entries, hence here, outside the default build (like
  `InlineOk.lean`).
- `ctlTableOk_all`: `ctlTableOk` for every `Full.Opcode` (past the tables there is no handler).
- `opFacts`: `Shapes.OpFacts h` for every opcode, the hypothesis of the shape steps.
-/
import Ryo.Proofs.OpFacts

namespace Ryo.Proofs.OpFacts

open Ryo.Vm

/-- `ctlTableOk` over the handler and info tables side by side: linear in the opcodes, where
`Full.all.all ctlTableOk` indexes both arrays per opcode. -/
def tablesOk : Bool :=
  (Handlers.handlers.toList.zip Full.opInfos.toList).all fun (h, i) =>
    match h with
    | some hi => kindFits i.shape hi.kind
    | none => true

set_option maxRecDepth 100000 in
theorem tablesOk_true : tablesOk = true := by decide +kernel

theorem handlers_size : Handlers.handlers.size = Full.count := by decide +kernel

theorem opInfos_size : Full.opInfos.size = Full.count := by decide +kernel

theorem zip_all {α β : Type} {A : Array α} {B : Array β} {p : α × β → Bool}
    (h : (A.toList.zip B.toList).all p = true) {i : Nat} (h1 : i < A.size) (h2 : i < B.size) :
    p (A[i], B[i]) = true := by
  refine List.all_eq_true.1 h _ (List.mem_iff_getElem.2 ⟨i, by simp; omega, by simp⟩)

theorem ctlTableOk_all (f : Full.Opcode) : ctlTableOk f = true := by
  unfold ctlTableOk Full.Opcode.handler? Full.Opcode.info
  by_cases hf : f.val.toNat < Full.count
  · have h1 : f.val.toNat < Handlers.handlers.size := handlers_size ▸ hf
    have h2 : f.val.toNat < Full.opInfos.size := opInfos_size ▸ hf
    rw [getElem!_pos Handlers.handlers _ h1, getElem!_pos Full.opInfos _ h2]
    exact zip_all tablesOk_true h1 h2
  · rw [getElem!_neg Handlers.handlers _ (by rw [handlers_size]; exact hf)]; rfl

theorem opFacts (h : Full.Opcode) : Shapes.OpFacts h := opFacts_of (ctlTableOk_all h)

end Ryo.Proofs.OpFacts
