/-
RyoProofs.InlineOps.Base — every opcode `Asm.inlineOps` lists is of its class's shape (`shapeOk`), so
the inline-sequence theorems (`Ryo/Proofs/Inline.lean`, stated for every opcode of a class's
shape) cover every inline opcode of a proved class. Not proved yet (see `frameOnly`): `load`, `store`,
the variable shifts and rotates, `div`/`rem`, `cttz`/`ctlz`, `cmp3` and `bswap`.

`classOf` splits the mnemonic with `String.splitOn`, whose `splitOnAux` is defined by
well-founded recursion and doesn't reduce in the kernel; and string operations on literals
reduce slowly there (through their UTF-8 bytes). So: `splitL` is `splitOnAux "."` on the
string's characters, with fuel (`splitL_eq`: where it returns `some`, it agrees, by unfolding
`splitOnAux`'s equation); the mnemonics as character lists are the generated
`Full.mnemonicChars` (`mnemonic_chars`, by `rfl`); and with these `inlineOps` is `inlineOpsL`
(`inlineOps_eq`), which `decide +kernel` evaluates in chunks of `chunk` opcodes, one module
each (`InlineOps/Part*.lean`: the whole list at once needs over 10 GB). Slow (minutes), hence
its own library, outside the default build (lean/README.md).
-/
import Ryo.Proofs.Inline.Shape
import Ryo.Vm.Generated.Mnemonics

namespace Ryo.Proofs.Inline

open Ryo.Vm Ryo.Vm.Asm Ryo.X86
open String.Pos.Raw (utf8GetAux)

/-- `Pos.Raw.extract` on the characters. -/
def extL (l : List Char) (b e : String.Pos.Raw) : List Char :=
  if b.byteIdx ≥ e.byteIdx then [] else String.Pos.Raw.extract.go₁ l 0 b e

/-- `String.splitOnAux s "."` on `s`'s characters `l` (of byte size `sz`), with fuel; `none`
when the fuel runs out. -/
def splitL : Nat → List Char → Nat → String.Pos.Raw → String.Pos.Raw → String.Pos.Raw →
    List (List Char) → Option (List (List Char))
  | 0, _, _, _, _, _, _ => none
  | n + 1, l, sz, b, i, j, r =>
    if i.byteIdx ≥ sz then some (extL l b i :: r).reverse
    else if (utf8GetAux l 0 i == utf8GetAux ['.'] 0 j) = true then
      let i' := i + utf8GetAux l 0 i
      let j' := j + utf8GetAux ['.'] 0 j
      if j'.byteIdx ≥ 1 then splitL n l sz i' i' 0 (extL l b (i'.unoffsetBy j') :: r)
      else splitL n l sz b i' j' r
    else splitL n l sz b (i.unoffsetBy j + utf8GetAux l 0 (i.unoffsetBy j)) 0 r

/-- The byte size of `ofList l`. -/
def sizeL (l : List Char) : Nat := (l.map Char.utf8Size).sum

theorem utf8ByteSize_ofList : ∀ l : List Char, (String.ofList l).utf8ByteSize = sizeL l
  | [] => rfl
  | c :: l => by
    simp [String.ofList_cons, String.utf8ByteSize_append, String.utf8ByteSize_singleton,
      utf8ByteSize_ofList l, sizeL]

theorem dot_toList : ".".toList = ['.'] := by decide
theorem dot_size : ".".utf8ByteSize = 1 := by decide

theorem splitL_eq : ∀ (n : Nat) (l : List Char) (b i j : String.Pos.Raw) (r x : List (List Char)),
    splitL n l (sizeL l) b i j r = some x →
      (String.ofList l).splitOnAux "." b i j (r.map String.ofList) = x.map String.ofList
  | 0, _, _, _, _, _, _, h => by simp [splitL] at h
  | n + 1, l, b, i, j, r, x, h => by
    rw [String.splitOnAux.eq_1]
    simp only [String.Pos.Raw.atEnd, String.Pos.Raw.next, String.Pos.Raw.get,
      String.Pos.Raw.extract, String.toList_ofList, utf8ByteSize_ofList, dot_toList, dot_size]
    simp only [splitL] at h
    split at h
    · rename_i h1
      cases h
      simp only [h1, decide_true, ↓reduceIte, List.map_reverse, List.map_cons, extL]
      split <;> simp [String.ofList_nil]
    · rename_i h1
      simp only [h1, decide_false, Bool.false_eq_true, ↓reduceIte]
      split at h
      · rename_i h2
        simp only [h2, ↓reduceIte]
        split at h
        · rename_i h3
          simp only [h3, decide_true, ↓reduceIte]
          have := splitL_eq n _ _ _ _ _ _ h
          simp only [List.map_cons, extL] at this
          rw [← this]; congr 1; congr 1; split <;> simp [String.ofList_nil]
        · rename_i h3
          simp only [h3, decide_false, Bool.false_eq_true, ↓reduceIte]
          exact splitL_eq n _ _ _ _ _ _ h
      · rename_i h2
        simp only [h2, Bool.false_eq_true, ↓reduceIte]
        exact splitL_eq n _ _ _ _ _ _ h

theorem classOfMnemonic_eq (mn : String) :
    classOfMnemonic mn = classOfParts (mn.splitOn ".") := rfl

/-- `classOfMnemonic (ofList l)`, splitting with `splitL`. -/
def classOfL (l : List Char) : Option Class :=
  match splitL 64 l (sizeL l) 0 0 0 [] with
  | some parts => classOfParts (parts.map String.ofList)
  | none => classOfMnemonic (String.ofList l)

theorem classOfL_eq (l : List Char) : classOfL l = classOfMnemonic (String.ofList l) := by
  unfold classOfL
  split
  · rename_i parts h
    rw [classOfMnemonic_eq, String.splitOn]
    have := splitL_eq _ _ _ _ _ _ _ h
    simp only [List.map_nil] at this
    simp only [this]; rfl
  · rfl

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem mnemonic_chars : Full.all.map Full.Opcode.mnemonic = Full.mnemonicChars.map String.ofList :=
  rfl

theorem filterMap_zip : ∀ (ops : List Full.Opcode) (ms : List (List Char)),
    ops.map Full.Opcode.mnemonic = ms.map String.ofList →
      ops.filterMap (fun op => (classOf op).map (op, ·)) =
        (ops.zip ms).filterMap fun p => (classOfL p.2).map (p.1, ·)
  | [], [], _ => rfl
  | [], _ :: _, h => by simp at h
  | _ :: _, [], h => by simp at h
  | op :: ops, m :: ms, h => by
    simp only [List.map_cons, List.cons.injEq] at h
    rw [List.filterMap_cons, List.zip_cons_cons, List.filterMap_cons, filterMap_zip ops ms h.2]
    simp only [classOfL_eq, classOf, h.1]

/-- `inlineOps`, on `Full.mnemonicChars`. -/
def inlineOpsL : List (Full.Opcode × Class) :=
  (Full.all.zip Full.mnemonicChars).filterMap fun p => (classOfL p.2).map (p.1, ·)

theorem inlineOps_eq : inlineOps = inlineOpsL := filterMap_zip _ _ mnemonic_chars

/-- The opcodes `[i * chunk, (i + 1) * chunk)` of `inlineOpsL`'s list, filtered the same way. -/
def chunk : Nat := 240

def inlineOpsC (i : Nat) : List (Full.Opcode × Class) :=
  (((Full.all.zip Full.mnemonicChars).drop (i * chunk)).take chunk).filterMap
    fun p => (classOfL p.2).map (p.1, ·)

theorem filterMap_split {α β : Type} (f : α → Option β) (l : List α) (n : Nat) :
    l.filterMap f = (l.take n).filterMap f ++ (l.drop n).filterMap f := by
  rw [← List.filterMap_append, List.take_append_drop]

set_option maxRecDepth 100000 in
theorem inlineOpsL_chunks : inlineOpsL =
    inlineOpsC 0 ++ inlineOpsC 1 ++ inlineOpsC 2 ++ inlineOpsC 3 := by
  have hl : (Full.all.zip Full.mnemonicChars).length ≤ 4 * chunk := by
    simp only [List.length_zip]; exact Nat.le_trans (Nat.min_le_left _ _) (by decide)
  unfold inlineOpsL inlineOpsC
  generalize Full.all.zip Full.mnemonicChars = l at hl ⊢
  generalize (fun p : Full.Opcode × List Char => (classOfL p.2).map (p.1, ·)) = f
  rw [filterMap_split f l chunk, filterMap_split f (l.drop chunk) chunk,
    filterMap_split f ((l.drop chunk).drop chunk) chunk]
  simp only [List.drop_drop, List.append_assoc, Nat.zero_mul, List.drop_zero, Nat.one_mul]
  have h4 : l.drop (chunk + chunk + chunk) = (l.drop (chunk + chunk + chunk)).take chunk :=
    (List.take_of_length_le (by simp; omega)).symm
  rw [show 2 * chunk = chunk + chunk by omega, show 3 * chunk = chunk + chunk + chunk by omega,
    ← h4]

end Ryo.Proofs.Inline
