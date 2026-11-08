/-
Ryo.Proofs.MnemonicChars — the full opcodes' mnemonics are the generated character lists
`Full.mnemonicChars` (`mnemonic_chars`, by `rfl` in chunks of 100 opcodes), so kernel checks can
work on characters instead of `String`s (`RyoProofs/InlineOps/Base.lean`'s `inlineOps_eq`,
`DeadStore/RStep.lean`'s `hasInline_classOf`).
-/
import Ryo.Proofs.OpsIn
import Ryo.Vm.Generated.Mnemonics

namespace Ryo.Proofs.Inline

open Ryo.Vm

-- In chunks of 100 opcodes (`opsIn`): one `rfl` over the whole table peaked at 7.0 GiB.
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_0 : (opsIn 0 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 0).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_100 : (opsIn 100 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 100).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_200 : (opsIn 200 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 200).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_300 : (opsIn 300 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 300).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_400 : (opsIn 400 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 400).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_500 : (opsIn 500 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 500).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_600 : (opsIn 600 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 600).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_700 : (opsIn 700 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 700).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_800 : (opsIn 800 100).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 800).take 100).map String.ofList := rfl
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars_900 : (opsIn 900 5).map Full.Opcode.mnemonic =
    ((Full.mnemonicChars.drop 900).take 5).map String.ofList := rfl
set_option maxRecDepth 100000 in
theorem mnemonic_chars : Full.all.map Full.Opcode.mnemonic = Full.mnemonicChars.map String.ofList := by
  have hl : Full.mnemonicChars.length ≤ 905 := by decide
  rw [all_eq_opsIn, ← List.take_of_length_le hl, ← List.drop_zero (l := Full.mnemonicChars)]
  have h0 := mnemonic_chars_0
  have h1 : (opsIn 0 200).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 200).map String.ofList :=
    map_opsIn_append (m := 100) (n := 100) rfl h0 mnemonic_chars_100
  have h2 : (opsIn 0 300).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 300).map String.ofList :=
    map_opsIn_append (m := 200) (n := 100) rfl h1 mnemonic_chars_200
  have h3 : (opsIn 0 400).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 400).map String.ofList :=
    map_opsIn_append (m := 300) (n := 100) rfl h2 mnemonic_chars_300
  have h4 : (opsIn 0 500).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 500).map String.ofList :=
    map_opsIn_append (m := 400) (n := 100) rfl h3 mnemonic_chars_400
  have h5 : (opsIn 0 600).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 600).map String.ofList :=
    map_opsIn_append (m := 500) (n := 100) rfl h4 mnemonic_chars_500
  have h6 : (opsIn 0 700).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 700).map String.ofList :=
    map_opsIn_append (m := 600) (n := 100) rfl h5 mnemonic_chars_600
  have h7 : (opsIn 0 800).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 800).map String.ofList :=
    map_opsIn_append (m := 700) (n := 100) rfl h6 mnemonic_chars_700
  have h8 : (opsIn 0 900).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 900).map String.ofList :=
    map_opsIn_append (m := 800) (n := 100) rfl h7 mnemonic_chars_800
  have h9 : (opsIn 0 905).map Full.Opcode.mnemonic =
      ((Full.mnemonicChars.drop 0).take 905).map String.ofList :=
    map_opsIn_append (m := 900) (n := 5) rfl h8 mnemonic_chars_900
  exact h9

end Ryo.Proofs.Inline
