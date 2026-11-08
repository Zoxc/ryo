/-
Ryo.Proofs.DeadStore.Covered — `CoveredAtSound` from `Decodes`: the frame bytes the decoder's
cache covers at a boundary are in `Frame.coveredAt`.

The cache after iteration `k` (`Indexed`, `iter_out`) is empty (a call, a handler instruction),
the inline proto's `after` that `inlineInsn` records as `cacheOut` (copied to
`Decoded.cacheOut` by `reducedOf`, `reducedOf_cacheOut`), or, for an `arg` (read only while
every proto before is one), the cache before it: empty through the leading `arg`s
(`cache_args`).

`S.cache k` is only constrained for `k ≤ S.r.protos.size`, which is why `CoveredAtSound` is
bounded by `S.c.d.insns.size`.
-/
import Ryo.Proofs.DeadStore.Defs

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- No entry of `c` caches a slot. -/
def Slotless (c : Cache) : Prop := ∀ e ∈ c.regs.toList, e.slot = none

theorem slotless_empty (pe : Bool) : Slotless { pe := pe } := by
  intro e he
  simp only [Array.toList_replicate, List.mem_replicate] at he
  obtain ⟨-, rfl⟩ := he
  rfl

/-! ### Decoder facts -/

/-- An exact `inlineInsn` read records the cache after it (`accept`'s `cacheOut`). -/
theorem inlineInsn_cacheOut {cache cache' : Cache} {dr dr' : List DroppedStore} {c c' : Cursor}
    {q : Proto} (h : (inlineInsn cache dr true).run c = .ok (some (q, cache', dr'), c')) :
    q.cacheOut = some (cacheSlots cache') :=
  by
  obtain ⟨-, -, -, -, -, -, -, -, h', -⟩ := inlineInsn_read_drop h
  exact h'

/-! #### `classOf .arg`, without evaluating `String.splitOn`

`splitOnAux` is well-founded recursion, which neither `decide` nor the kernel unfolds. As in
`RyoProofs/InlineOps/Base.lean` (copied here: that library is outside the default build), the
split runs on the characters with fuel (`dsSplitL`), shown equal to `splitOnAux` by unfolding its
equation (`dsSplitL_eq`); the kernel then evaluates it on `['a','r','g']`. -/

section ClassOfArg

open String.Pos.Raw (utf8GetAux)

/-- `Pos.Raw.extract` on the characters. -/
def dsExtL (l : List Char) (b e : String.Pos.Raw) : List Char :=
  if b.byteIdx ≥ e.byteIdx then [] else String.Pos.Raw.extract.go₁ l 0 b e

/-- `String.splitOnAux s "."` on `s`'s characters `l` (of byte size `sz`), with fuel. -/
def dsSplitL : Nat → List Char → Nat → String.Pos.Raw → String.Pos.Raw → String.Pos.Raw →
    List (List Char) → Option (List (List Char))
  | 0, _, _, _, _, _, _ => none
  | n + 1, l, sz, b, i, j, r =>
    if i.byteIdx ≥ sz then some (dsExtL l b i :: r).reverse
    else if (utf8GetAux l 0 i == utf8GetAux ['.'] 0 j) = true then
      let i' := i + utf8GetAux l 0 i
      let j' := j + utf8GetAux ['.'] 0 j
      if j'.byteIdx ≥ 1 then dsSplitL n l sz i' i' 0 (dsExtL l b (i'.unoffsetBy j') :: r)
      else dsSplitL n l sz b i' j' r
    else dsSplitL n l sz b (i.unoffsetBy j + utf8GetAux l 0 (i.unoffsetBy j)) 0 r

def dsSizeL (l : List Char) : Nat := (l.map Char.utf8Size).sum

theorem ds_utf8ByteSize_ofList : ∀ l : List Char, (String.ofList l).utf8ByteSize = dsSizeL l
  | [] => rfl
  | c :: l => by
    simp [String.ofList_cons, String.utf8ByteSize_append, String.utf8ByteSize_singleton,
      ds_utf8ByteSize_ofList l, dsSizeL]

theorem ds_dot_toList : ".".toList = ['.'] := by decide
theorem ds_dot_size : ".".utf8ByteSize = 1 := by decide

theorem dsSplitL_eq : ∀ (n : Nat) (l : List Char) (b i j : String.Pos.Raw) (r x : List (List Char)),
    dsSplitL n l (dsSizeL l) b i j r = some x →
      (String.ofList l).splitOnAux "." b i j (r.map String.ofList) = x.map String.ofList
  | 0, _, _, _, _, _, _, h => by simp [dsSplitL] at h
  | n + 1, l, b, i, j, r, x, h => by
    rw [String.splitOnAux.eq_1]
    simp only [String.Pos.Raw.atEnd, String.Pos.Raw.next, String.Pos.Raw.get,
      String.Pos.Raw.extract, String.toList_ofList, ds_utf8ByteSize_ofList, ds_dot_toList,
      ds_dot_size]
    simp only [dsSplitL] at h
    split at h
    · rename_i h1
      cases h
      simp only [h1, decide_true, ↓reduceIte, List.map_reverse, List.map_cons, dsExtL]
      split <;> simp [String.ofList_nil]
    · rename_i h1
      simp only [h1, decide_false, Bool.false_eq_true, ↓reduceIte]
      split at h
      · rename_i h2
        simp only [h2, ↓reduceIte]
        split at h
        · rename_i h3
          simp only [h3, decide_true, ↓reduceIte]
          have := dsSplitL_eq n _ _ _ _ _ _ h
          simp only [List.map_cons, dsExtL] at this
          rw [← this]; congr 1; congr 1; split <;> simp [String.ofList_nil]
        · rename_i h3
          simp only [h3, decide_false, Bool.false_eq_true, ↓reduceIte]
          exact dsSplitL_eq n _ _ _ _ _ _ h
      · rename_i h2
        simp only [h2, Bool.false_eq_true, ↓reduceIte]
        exact dsSplitL_eq n _ _ _ _ _ _ h

/-- `classOfMnemonic (ofList l)`, splitting with `dsSplitL`. -/
def dsClassOfL (l : List Char) : Option Class :=
  match dsSplitL 64 l (dsSizeL l) 0 0 0 [] with
  | some parts => classOfParts (parts.map String.ofList)
  | none => classOfMnemonic (String.ofList l)

theorem dsClassOfL_eq (l : List Char) : dsClassOfL l = classOfMnemonic (String.ofList l) := by
  unfold dsClassOfL
  split
  · rename_i parts h
    rw [show classOfMnemonic (String.ofList l) = classOfParts ((String.ofList l).splitOn ".")
      from rfl, String.splitOn]
    have := dsSplitL_eq _ _ _ _ _ _ _ h
    simp only [List.map_nil] at this
    simp only [this]; rfl
  · rfl

end ClassOfArg

/-- `arg` has no inline form: its mnemonic is `arg` (`rfl`, as `mnemonic_chars`), which
`classOfParts` doesn't take (kernel evaluation of `dsClassOfL`). -/
theorem classOf_arg : classOf Full.Opcode.arg = none := by
  have hm : Full.Opcode.arg.mnemonic = String.ofList ['a', 'r', 'g'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

/-- An inline proto is not an `arg` (`decodeInline` gives an `inlineOps` opcode). -/
theorem inlineInsn_not_arg {cache cache' : Cache} {dr dr' : List DroppedStore} {c c' : Cursor}
    {q : Proto} (h : (inlineInsn cache dr true).run c = .ok (some (q, cache', dr'), c')) :
    q.op ≠ .arg := by
  obtain ⟨-, -, cand, br, out, hdi, -⟩ := inlineInsn_read_drop h
  obtain ⟨cls, hm, -⟩ := decodeInline_spec hdi
  intro he
  rw [he] at hm
  have h0 := classOf_arg
  simp only [inlineOps, List.mem_filterMap, Option.map_eq_some_iff, Prod.mk.injEq] at hm
  obtain ⟨a, -, c'', hc', rfl, rfl⟩ := hm
  rw [hc'] at h0
  cases h0

theorem inlineInsn_out {cache cache' : Cache} {dr dr' : List DroppedStore} {c c' : Cursor}
    {q : Proto} (h : (inlineInsn cache dr true).run c = .ok (some (q, cache', dr'), c')) :
    q.cacheOut = some (cacheSlots cache') ∧ q.op ≠ .arg :=
  ⟨inlineInsn_cacheOut h, inlineInsn_not_arg h⟩

/-- `reducedOf`'s `cacheOut`: the protos'. -/
theorem reducedOf_cacheOut {r : ReadResult} {pe : Bool} {d : Decoded}
    (h : reducedOf r pe = .ok d) : d.cacheOut = r.protos.map (·.cacheOut) := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  rfl

/-! ### The cache after an iteration -/

theorem protoRead_out {fr : Vm.Frame} {ro : ByteArray} {c : Cursor} {p : Nat} {ci : Cache}
    {dr : List DroppedStore} {a : Bool} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (h : ProtoRead fr ro true c p ci dr a q c' cache' dr') :
    Slotless cache' ∨ (q.cacheOut = some (cacheSlots cache') ∧ q.op ≠ .arg) ∨
      (a = true ∧ cache' = ci) := by
  cases h with
  | arg _ => exact .inr (.inr ⟨rfl, rfl⟩)
  | call _ _ => exact .inl (slotless_empty _)
  | inline _ _ hi => exact .inr (.inl (inlineInsn_out hi))
  | insn _ _ _ _ => exact .inl (slotless_empty _)

theorem iter_out {fr : Vm.Frame} {ro : ByteArray} {T : Array Nat} {cs : Array CallSite}
    {c : Cursor} {a : Bool} {p : Nat} {cache : Cache} {dr : List DroppedStore} {q : Proto}
    {p' : Nat} {cache' : Cache} {dr' : List DroppedStore}
    (h : Iter fr ro (some T) cs c a p cache dr q p' cache' dr') :
    Slotless cache' ∨ (q.cacheOut = some (cacheSlots cache') ∧ q.op ≠ .arg) ∨
      (a = true ∧ (Slotless cache → Slotless cache')) := by
  cases h with
  | empty _ hi =>
    have hi' : (inlineInsn _ _ true).run _ = _ := hi
    have ho := inlineInsn_out hi'
    exact .inr (.inl ho)
  | main _ _ hpr _ =>
    rcases protoRead_out hpr with h1 | h1 | ⟨ha, hc⟩
    · exact .inl h1
    · exact .inr (.inl h1)
    · refine .inr (.inr ⟨ha, fun hs => ?_⟩)
      rw [hc]
      split
      · exact slotless_empty _
      · exact hs

/-- `iter_out` for instruction `k` of `S` (its iteration by `Decodes.iterAt`; at the region's
first instruction the cache is empty, `Decodes.cache_regionStart`). -/
theorem iter_out_at (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (k : Nat) (hk : k < S.r.protos.toList.length) :
    Slotless (S.cache (k + 1)) ∨
      (S.r.protos.toList[k].cacheOut = some (cacheSlots (S.cache (k + 1))) ∧
        S.r.protos.toList[k].op ≠ .arg) ∨
      (S.args k = true ∧ (Slotless (S.cache k) → Slotless (S.cache (k + 1)))) := by
  by_cases hlast : S.c.inRegion k = false ∧ S.c.inRegion (k + 1) = true
  · left; rw [hD.cache_regionStart hlast.1 hlast.2]; exact slotless_empty _
  obtain ⟨fr, q0, p', ca', dr', -, hpq, it, hend⟩ := hD.iterAt k hk
  have hca : ca' = S.cache (k + 1) := (hend (not_last_cases hlast)).2.1
  subst hca
  have hk1 : S.r.protos.toList[k].op = q0.op ∧ S.r.protos.toList[k].cacheOut = q0.cacheOut := by
    rcases hpq with h | h
    · rw [h]; exact ⟨rfl, rfl⟩
    · rw [h]; exact ⟨(S.fixResume_keep q0).1, (S.fixResume_keep q0).2.2.2.2.2.1⟩
  rw [hk1.1, hk1.2]
  exact iter_out it

/-- Through the leading `arg`s the cache is empty. -/
theorem cache_args (hD : Decodes S code relocs rodata callSites dropped scopes mode) :
    ∀ k, k ≤ S.r.protos.toList.length → S.args k = true → Slotless (S.cache k) := by
  intro k
  induction k with
  | zero =>
    intro _ _
    rw [hD.cache0]
    exact slotless_empty _
  | succ k ih =>
    intro hk ha
    have hk' : k < S.r.protos.toList.length := by omega
    rw [hD.argsSucc k hk', Bool.and_eq_true] at ha
    rcases iter_out_at hD k hk' with h1 | ⟨-, hne⟩ | ⟨-, h1⟩
    · exact h1
    · exact absurd (by simpa using ha.2) hne
    · exact h1 (ih (by omega) ha.1)

/-! ### Bits -/

theorem mem_cacheSlots {c : Cache} {e : Entry} (he : e ∈ c.regs.toList) {sl : BitVec 32} {w : W}
    (hs : e.slot = some (sl, w)) : (sl, Asm.bytes w) ∈ cacheSlots c := by
  unfold cacheSlots
  exact List.mem_filterMap.2 ⟨e, he, by simp [hs]⟩

theorem slotBits_testBit {f : Nat} {sl : List (BitVec 32 × Nat)} {s : BitVec 32} {n : Nat}
    (hm : (s, n) ∈ sl) {o : Int} (h1 : -(f : Int) ≤ o) (h2 : o < 0) (h3 : s.toInt ≤ o)
    (h4 : o < s.toInt + n) : (Frame.slotBits f sl).testBit (o + f).toNat = true := by
  unfold Frame.slotBits
  rw [testBit_foldl_or, Nat.zero_testBit, Bool.false_or]
  refine List.any_eq_true.2 ⟨(s, n), hm, ?_⟩
  simp only [testBit_bitsOf, Frame.range, Bool.and_eq_true, decide_eq_true_eq]
  omega

/-! ### `CoveredAtSound` -/

/-- A slot byte of `S.cache k`, `k ≤ S.r.protos.size`, is in `coveredAt k`. -/
theorem covered_cache (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} (hk : k ≤ S.r.protos.size) {e : Entry} (he : e ∈ (S.cache k).regs.toList)
    {sl : BitVec 32} {w : W} (hs : e.slot = some (sl, w)) {o : Int} (hin : InFrame S o)
    (h3 : sl.toInt ≤ o) (h4 : o < sl.toInt + Asm.bytes w) :
    (Frame.coveredAt S.c.d k).testBit (bit S o) = true := by
  have hno : ¬ Slotless (S.cache k) := fun h => by rw [h e he] at hs; cases hs
  cases k with
  | zero => rw [hD.cache0] at hno; exact absurd (slotless_empty _) hno
  | succ j =>
    have hj' : j < S.r.protos.size := by omega
    have hj : j < S.r.protos.toList.length := by simpa using hj'
    unfold Frame.coveredAt
    simp only [Nat.add_one_ne_zero, ↓reduceIte, Nat.add_sub_cancel]
    rcases iter_out_at hD j hj with hsl | ⟨hout, -⟩ | ⟨ha, himp⟩
    · exact absurd hsl hno
    · have hout' : S.r.protos[j].cacheOut = some (cacheSlots (S.cache (j + 1))) := by
        simpa using hout
      have hc : S.c.d.cacheOut[j]? = some (some (cacheSlots (S.cache (j + 1)))) := by
        rw [reducedOf_cacheOut hD.reduced, Array.getElem?_map, Array.getElem?_eq_getElem hj']
        simp [hout']
      rw [hc]
      exact slotBits_testBit (mem_cacheSlots he hs) hin.1 hin.2 h3 h4
    · exact absurd (himp (cache_args hD j (by omega) ha)) hno

/-- `CoveredAtSound`: at the boundaries `Decodes` constrains (`k ≤ S.c.d.insns.size`, the
protos' count by `reducedOf_insns`). -/
theorem coveredAtSound (hD : Decodes S code relocs rodata callSites dropped scopes mode) :
    CoveredAtSound S := by
  intro k o hk ⟨c, hc, e, he, sl, w, hs, h3, h4⟩ hin
  have hk' : k ≤ S.r.protos.size := by
    rw [← (reducedOf_insns hD.reduced).1]
    exact hk
  have hc' : c = S.cache k ∨ Slotless c := by
    rcases hc with rfl | rfl
    · exact .inl rfl
    · unfold Setup.used
      split
      · exact .inr (slotless_empty _)
      · exact .inl rfl
  rcases hc' with rfl | hsl
  · exact covered_cache hD hk' he hs hin h3 h4
  · rw [hsl e he] at hs
    cases hs

end Ryo.Proofs.DeadStore
