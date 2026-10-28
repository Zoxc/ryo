/-
Ryo.Proofs.DecodeLink.Tables — `HdlTables` from the decoder's Lean-only check `tablesCheck`
(`Ryo/Vm/DecodeReduced.lean`, run by `Frame.decodeChecked`).

`tablesCheck` reruns `read` and checks the body cursor it leaves: the code is at most `2 ^ 31`
bytes, every switch jump decoding anywhere in it (`switchTableAt`) has its table start at a
relocation boundary, and every read instruction's targets lie below `2 ^ 31`. Then for a switch
`HdlTables` considers (read with the body's relocations and `spFrame`): its decoding is one
`switchTableAt` finds (`switchTableAt_of_dec`, at a position within the code,
`decodeItem_pos_lt`), so the start is a boundary; the table's first entry lies within the code,
so its start is below `2 ^ 31` (`tableEntry_le`); the entries are targets of an instruction.
-/
import Ryo.Proofs.DecodeSound.Basic

namespace Ryo.Proofs.DecodeLink.Tables

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm Ryo.Proofs.DecodeLink Ryo.Proofs.DecodeSound

/-- An item `matchesItem` accepts starts within the code. -/
theorem matchesItem_pos_lt {c : Cursor} {i : Item} {n : Nat} (h : c.matchesItem i = some n) :
    c.pos < c.code.size := by
  unfold Cursor.matchesItem at h
  simp only at h
  split at h
  · rename_i hc
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hc
    obtain ⟨he, hl⟩ := hc
    unfold Cursor.encodedAt at he
    split at he
    · cases he
    · rename_i here hb
      unfold Cursor.bytes at hb
      split at hb
      · omega
      · cases hb
  · cases h

/-- An item `decodeItem` reads starts within the code. -/
theorem decodeItem_pos_lt {c : Cursor} {j : Item} {n : Nat} (h : decodeItem c = some (j, n)) :
    c.pos < c.code.size := by
  have hacc : ∀ (post : Item → Option Item) (i : Item), c.accept post i = some (j, n) →
      c.pos < c.code.size := by
    intro post i ha
    unfold Cursor.accept at ha
    cases hm : c.matchesItem i with
    | none => simp [hm] at ha
    | some m => exact matchesItem_pos_lt hm
  unfold decodeItem at h
  rcases Option.orElse_some' h with h | h
  · obtain ⟨i, -, h⟩ := Option.bind_eq_some_iff.mp h
    exact hacc _ i h
  · rcases Option.orElse_some' h with h | h <;>
    · obtain ⟨i, -, h⟩ := Option.bind_eq_some_iff.mp h
      exact hacc _ i h

/-- A jump table entry `tableEntry` reads lies within the code. -/
theorem tableEntry_le {c : Cursor} {b e : BitVec 32} (h : c.tableEntry b = some e) :
    c.pos + 4 ≤ c.code.size := by
  apply Classical.byContradiction
  intro hc
  have hb : c.bytes 4 = none := by
    unfold Cursor.bytes
    rw [if_neg hc]
  simp [Cursor.tableEntry, Cursor.i32At, hb] at h

/-- A switch jump read item by item is one `switchTableAt` finds. -/
theorem switchTableAt_of_dec {c : Cursor} {p pE : Nat} {tb : BitVec 32}
    (h : Dec c p (Switch.switchItems tb) pE) :
    switchTableAt c p = some tb ∧ p < c.code.size := by
  unfold Switch.switchItems at h
  cases h with
  | cons h1 h =>
  cases h with
  | cons h2 h =>
  cases h with
  | cons h3 h =>
  cases h with
  | cons h4 _ =>
  refine ⟨?_, by simpa using decodeItem_pos_lt h1⟩
  simp only [atPos] at h1 h2 h3 h4
  unfold switchTableAt
  simp only [h1, h2, h3, h4]

/-- `switchTableAt` reads only the code, the relocations and `spFrame`. -/
theorem switchTableAt_congr {c d : Cursor} (h1 : c.code = d.code) (h2 : c.fields = d.fields)
    (h3 : c.spFrame = d.spFrame) (p : Nat) : switchTableAt c p = switchTableAt d p := by
  cases c
  cases d
  simp only at h1 h2 h3
  subst h1 h2 h3
  rfl

/-- What `tablesOk` says of a switch jump decoding at `p` within the code. -/
theorem tablesOk_spec {c : Cursor} {rs : Array Reloc} (h : tablesOk c rs = true) :
    c.code.size ≤ 2 ^ 31 ∧ ∀ p tb, p < c.code.size → switchTableAt c p = some tb →
      Boundary rs tb.toNat := by
  unfold tablesOk at h
  simp only [Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true, List.mem_range] at h
  obtain ⟨hsz, hall⟩ := h
  refine ⟨hsz, fun p tb hp ht r hr hlt => ?_⟩
  have := hall p hp
  rw [ht] at this
  simp only [List.all_eq_true, decide_eq_true_eq] at this
  exact this r hr hlt

/-- `HdlTables` from the decoding and `tablesCheck`. -/
theorem hdlTables_of_check {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hc : tablesCheck code relocs rodata callSites dropped scopes mode = true) : HdlTables S := by
  obtain ⟨c', hread⟩ := hD.read
  unfold tablesCheck at hc
  rw [hread] at hc
  simp only [Bool.and_eq_true] at hc
  obtain ⟨hok, htg⟩ := hc
  obtain ⟨hsz, hbd⟩ := tablesOk_spec hok
  have hsz' : code.data.size ≤ 2 ^ 31 := hsz
  -- The body cursor is the one the check reads.
  have hb := hD.bodyEq
  have ecode : S.body.code = code.data := by rw [hb]; rfl
  have efields : S.body.fields = .relocs relocs := by rw [hb]; rfl
  have esp : S.body.spFrame =
      (if mode.framePointer then none else some (BitVec.ofNat 32 S.r.frameSize)) := by
    rw [hb]; rfl
  intro c0 tb pE es k hcode hfields hsp hdec hes hne hk htgk
  obtain ⟨hsw, hpos⟩ := switchTableAt_of_dec hdec
  let sp : Option (BitVec 32) :=
    if mode.framePointer then none else some (BitVec.ofNat 32 S.r.frameSize)
  let d0 : Cursor := { code := code.data, pos := 0, fields := .relocs relocs, spFrame := sp }
  rw [switchTableAt_congr (d := d0)
    (hcode.trans ecode) (hfields.trans efields) (hsp.trans esp)] at hsw
  have hpos' : c0.pos < code.data.size := by rw [← ecode, ← hcode]; exact hpos
  refine ⟨?_, ?_, ?_⟩
  · -- The first entry lies within the code, at most `2 ^ 31` bytes.
    obtain ⟨e0, es', rfl⟩ := List.exists_cons_of_ne_nil hne
    have h0 := hes 0 (by simp)
    have hle := tableEntry_le h0
    simp only [atPos, Nat.mul_zero, Nat.add_zero] at hle
    rw [hcode, ecode] at hle
    omega
  · rw [hD.rsEq]
    exact hbd c0.pos tb hpos' hsw
  · intro e he
    have hall := (Array.all_eq_true.1 htg) k hk
    simp only [List.all_eq_true, decide_eq_true_eq] at hall
    exact hall _ (htgk e he)

end Ryo.Proofs.DecodeLink.Tables
