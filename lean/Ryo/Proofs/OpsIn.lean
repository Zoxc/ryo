/-
Ryo.Proofs.OpsIn — opcode ranges, for checking whole-opcode-table facts in chunks.

One kernel reduction over all of `Full.all` (`decide +kernel`, or `rfl` against a generated
table) keeps every intermediate term alive and takes several GiB per table, up to more than
12 GiB; per chunk of 100 opcodes it stays small. `opsIn s n` is the opcodes `s, …, s + n - 1`,
`all_eq_opsIn` restates `Full.all`, and `all_opsIn_append` / `map_opsIn_append` join chunks.
Used by `RStep.lean` (`layoutAgreeTable`, `footprintNamesTable'`), `RyoProofs/InlineOk.lean`
(`all_kindOk`) and `RyoProofs/InlineOps/Base.lean` (`mnemonic_chars`). Tables indexed by
`List.range Reduced.ofFullTable.size` (`DecodeSound/Basic.lean`, `DeadStore/DropForm.lean`) are
chunked over `List.range'` instead (`ofFullTable_size`, `all_range'_append`).
-/
import Ryo.Vm.Generated.Full
import Ryo.Vm.Generated.Reduced

namespace Ryo.Proofs

open Ryo.Vm

/-- The opcodes of values `s, …, s + n - 1`. -/
def opsIn (s n : Nat) : List Full.Opcode := (List.range' s n).map fun n => ⟨n.toUInt16⟩

theorem all_eq_opsIn : Full.all = opsIn 0 Full.count := by
  simp only [Full.all, opsIn, List.range_eq_range']

theorem all_opsIn_append {p : Full.Opcode → Bool} {s m n k : Nat} (hk : m + n = k)
    (h1 : (opsIn s m).all p = true) (h2 : (opsIn (s + m) n).all p = true) :
    (opsIn s k).all p = true := by
  rw [← hk, opsIn, ← List.range'_append_1, List.map_append, List.all_append]
  exact Bool.and_eq_true_iff.2 ⟨h1, h2⟩

theorem map_opsIn_append {α β : Type} {f : Full.Opcode → α} {g : β → α} {L : List β}
    {s m n k : Nat} (hk : m + n = k)
    (h1 : (opsIn s m).map f = ((L.drop s).take m).map g)
    (h2 : (opsIn (s + m) n).map f = ((L.drop (s + m)).take n).map g) :
    (opsIn s k).map f = ((L.drop s).take k).map g := by
  rw [← hk, List.take_add, List.drop_drop, List.map_append, ← h1, ← h2, opsIn,
    opsIn, opsIn, ← List.range'_append_1, List.map_append, List.map_append]

set_option maxRecDepth 100000 in
theorem ofFullTable_size : Reduced.ofFullTable.size = 905 := by decide

theorem all_range'_append {p : Nat → Bool} {s m n k : Nat} (hk : m + n = k)
    (h1 : (List.range' s m).all p = true) (h2 : (List.range' (s + m) n).all p = true) :
    (List.range' s k).all p = true := by
  rw [← hk, ← List.range'_append_1, List.all_append]
  exact Bool.and_eq_true_iff.2 ⟨h1, h2⟩

end Ryo.Proofs
