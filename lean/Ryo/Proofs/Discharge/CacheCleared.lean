/-
Ryo.Proofs.Discharge.CacheCleared — `CacheCleared` (`DecodeSound/Basic.lean`: the cache the
decoder used is empty at branch targets and landing pads) from the Lean-only check
`cacheClearedCheck` (`Ryo/Vm/CacheClearedCheck.lean`, run by `Frame.decodeChecked`).

- `read_instructions_targets`: `read`'s second pass runs with the targets `readTargets` computes
  (`read`'s first pass; the two runs agree step by step, `dm_run_det`). `decodes_of_ok` uses it
  for `Decodes.targetsRead`.
- `cacheOk_of_decodes`: the check on the function's inputs is `Hyps.cacheOk` for their read.
- `iter_clears`: an iteration whose instruction `clearsCache` (neither an `arg` nor an opcode
  with an inline form) ends with the cache empty: it was read by `callInsn` or `insn`
  (`inlineInsn` reads only opcodes with an inline form, `classOf_of_mem`; `argInsn` only `arg`).
- `Hyps.cacheCleared`: `targets` is `Hyps.cacheTargets`; at a pad, the cache used is empty at a
  target (`Setup.used`), at instruction 0 (`Decodes.cache0`), or after an instruction that
  `clearsCache` (`Decodes.iterAt`, `iter_clears`; the region's first instruction by
  `Decodes.regionAt`).
-/
import Ryo.Proofs.DSWork.Boundary
import Ryo.Vm.CacheClearedCheck

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Vm Ryo.Vm.Asm Ryo.X86 Ryo.Vm.R Ryo.Proofs.DecodeLink

/-- A run of the decoder's monad is deterministic. -/
theorem dm_run_det {α : Type} {x : DM α} {c c1 c2 : Cursor} {a b : α}
    (h1 : x.run c = .ok (a, c1)) (h2 : x.run c = .ok (b, c2)) : a = b ∧ c1 = c2 := by
  rw [h1] at h2
  injection h2 with h2
  injection h2 with ha hc
  exact ⟨ha, hc⟩

/-- `read_instructions_prologue` with the second pass's targets those of `readTargets` (the
first pass's, computed the same way). -/
theorem read_instructions_targets {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' cT : Cursor} {r : ReadResult} {ts : Array Nat}
    (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hT : (readTargets ro callSites dropped mode).run c = .ok (ts, cT))
    (hnr : regionPad mode callSites = none) :
    ∃ (c0 c1 : Cursor) (stub : Option Nat) (padded : Array Bool),
      c0 = bodyCursor c mode r.frameSize c0.pos ∧
      (instructions ⟨r.frameSize, mode, false⟩ ro dropped (some ts) stub c.code.size
        callSites).run c0 = .ok ((r.protos, padded), c1) ∧
      (mode.framePointer = true → ∃ items, Dec c0 c.pos items c0.pos) := by
  unfold Vm.read at h
  unfold readTargets at hT
  obtain ⟨⟨entry, fs⟩, c1, h1, h⟩ := bind_ok h
  obtain ⟨eT, d1, g1, hT⟩ := bind_ok hT
  obtain ⟨he1, hd1⟩ := dm_run_det h1 g1
  subst he1
  rw [← hd1] at hT
  have hc1 := readFrame_body h1
  obtain ⟨items, hd⟩ := readFrame_dec h1
  dsimp only at h
  dsimp only at hT
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨hx, hc2⟩ := get_run h2
  rw [hx, hc2] at h
  obtain ⟨x', d2, g2, hT⟩ := bind_ok hT
  obtain ⟨hx', hd2⟩ := get_run g2
  rw [hx', hd2] at hT
  obtain ⟨ra, c3, h3, h⟩ := bind_ok h
  have hra : ra = none ∧ c3 = c1 := by
    unfold regionEntry at h3; rw [hnr] at h3
    exact ⟨(pure_ok h3).1.symm, (pure_ok h3).2.symm⟩
  rw [hra.1, hra.2] at h
  obtain ⟨ra', d3, g3, hT⟩ := bind_ok hT
  have hra' : ra' = none ∧ d3 = c1 := by
    unfold regionEntry at g3; rw [hnr] at g3
    exact ⟨(pure_ok g3).1.symm, (pure_ok g3).2.symm⟩
  rw [hra'.1, hra'.2] at hT
  have hsize : c1.code.size = c.code.size := by rw [hc1]; rfl
  dsimp only at h
  dsimp only at hT
  obtain ⟨body, c4, h4, h⟩ := bind_ok h
  obtain ⟨hb4, hc4⟩ := pos_run' h4
  subst hb4
  rw [hc4] at h
  obtain ⟨body', d4, g4, hT⟩ := bind_ok hT
  obtain ⟨hb4', hd4⟩ := pos_run' g4
  subst hb4'
  rw [hd4] at hT
  obtain ⟨⟨p1, pd1, be1⟩, c5, h5, h⟩ := bind_ok h
  have e5 := readParts_pos h5
  obtain ⟨⟨p1', pd1', be1'⟩, d5, g5, hT⟩ := bind_ok hT
  obtain ⟨hp1, -⟩ := dm_run_det h5 g5
  have hp1' : p1 = p1' := congrArg Prod.fst hp1
  rw [← hp1'] at hT
  dsimp only at hT
  obtain ⟨hts, -⟩ := pure_ok hT
  dsimp only at h
  obtain ⟨⟨protos, padded, bodyEnd⟩, c6, h6, h⟩ := bind_ok h
  -- The second pass: `instructions` from the body.
  have hpass : ∃ c7, (instructions ⟨fs, mode, false⟩ ro dropped
      (some ((p1.toList.flatMap Proto.targets).toArray.qsort (· < ·))) (entry.map (·.1))
      c.code.size callSites).run (atPos c5 c1.pos) = .ok ((protos, padded), c7) := by
    unfold readParts at h6
    obtain ⟨u, c7, h7, h6⟩ := bind_ok h6
    rw [run_setPos] at h7; cases h7
    obtain ⟨⟨ps, pd⟩, c8, h8, h6⟩ := bind_ok h6
    obtain ⟨be, c9, h9, h6⟩ := bind_ok h6
    obtain ⟨rfl, rfl⟩ := pos_run' h9
    obtain ⟨u, c10, h10, h6⟩ := bind_ok h6
    obtain ⟨he, -⟩ := pure_ok h6
    cases he
    rw [hsize] at h8
    exact ⟨_, h8⟩
  obtain ⟨c7, hc7⟩ := hpass
  rw [hts] at hc7
  -- The rest leaves the protos (no pad region: `rs` is their count).
  have tail : r.protos = protos ∧ r.frameSize = fs := by
    dsimp only at h
    obtain ⟨u, c8, -, h⟩ := bind_ok h
    obtain ⟨heads, c9, -, h⟩ := bind_ok h
    obtain ⟨u, c10, -, h⟩ := bind_ok h
    simp only [Nat.lt_irrefl, ↓reduceIte] at h
    obtain ⟨protos', c11, h11, h⟩ := bind_ok h
    obtain ⟨rfl, rfl⟩ := pure_ok h11
    obtain ⟨acts, c12, -, h⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h
    cases he
    exact ⟨rfl, rfl⟩
  obtain ⟨tp, tf⟩ := tail
  have hb : atPos c5 c1.pos = bodyCursor c mode r.frameSize (atPos c5 c1.pos).pos := by
    rw [tf, e5]
    show atPos (atPos c1 c5.pos) c1.pos = _
    rw [hc1]; rfl
  refine ⟨_, c7, _, padded, hb, by rw [tp, tf]; exact hc7, fun hfp => ⟨items, ?_⟩⟩
  show Dec (atPos c5 c1.pos) c.pos items c1.pos
  have hx : atPos c5 c1.pos = atPos c c1.pos := by rw [hb]; simp [bodyCursor, hfp]
  rw [hx, Dec.at_iff]
  exact hd

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- The check runs the first pass. -/
theorem readTargets_of_check
    (h : cacheClearedCheck code relocs rodata callSites dropped scopes mode = true) :
    ∃ ts cT, (readTargets rodata callSites dropped.toList mode).run
      { code := code.data, pos := 0, fields := .relocs relocs } = .ok (ts, cT) := by
  unfold cacheClearedCheck at h
  generalize hT : (readTargets rodata callSites dropped.toList mode).run
      ({ code := code.data, pos := 0, fields := .relocs relocs } : Cursor) = r at h
  cases r with
  | error e => simp at h
  | ok v =>
    obtain ⟨ts, cT⟩ := v
    exact ⟨ts, cT, rfl⟩

/-- `decodeChecked`'s `cacheClearedCheck` on the function's inputs gives `Hyps.cacheOk` for
their read. -/
theorem cacheOk_of_decodes (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (h : cacheClearedCheck code relocs rodata callSites dropped scopes mode = true) :
    cacheClearedOk S.r.protos S.c.d.cleanup S.targets = true := by
  obtain ⟨cT, hT⟩ := hD.targetsRead
  obtain ⟨c', hread⟩ := hD.read
  unfold cacheClearedCheck at h
  rw [hT, hread] at h
  simp only [hD.reduced] at h
  exact h

/-- An opcode with an inline form has its class (`inlineOps` lists `classOf`'s). -/
theorem classOf_of_mem {f : Full.Opcode} {cls : Class} (h : (f, cls) ∈ inlineOps) :
    classOf f = some cls := by
  simp only [inlineOps, List.mem_filterMap, Option.map_eq_some_iff, Prod.mk.injEq] at h
  obtain ⟨a, -, c', hc', rfl, rfl⟩ := h
  exact hc'

/-- An iteration (with targets) whose instruction `clearsCache` ends with the cache empty. -/
theorem iter_clears {fr : Vm.Frame} {ro : ByteArray} {T : Array Nat} {cs : Array CallSite}
    {c : Cursor} {a : Bool} {p p' : Nat} {cache cache' : Cache} {dr dr' : List DroppedStore}
    {q : Proto} (h : Iter fr ro (some T) cs c a p cache dr q p' cache' dr')
    (hcl : clearsCache q = true) : cache' = { pe := fr.mode.pe } := by
  cases h with
  | empty _ hinl =>
    obtain ⟨-, -, cand, br, out, hd, -⟩ := inlineInsn_read_drop hinl
    obtain ⟨cls, hm, -⟩ := decodeInline_spec hd
    simp [clearsCache, classOf_of_mem hm] at hcl
  | main _ _ hpr _ =>
    cases hpr with
    | arg ha =>
      obtain ⟨ar, d, rfl, -⟩ := argInsn_read ha
      simp [clearsCache] at hcl
    | call _ _ => rfl
    | inline _ _ h3 =>
      obtain ⟨-, -, cand, br, out, hd, -⟩ := inlineInsn_read_drop h3
      obtain ⟨cls, hm, -⟩ := decodeInline_spec hd
      simp [clearsCache, classOf_of_mem hm] at hcl
    | insn _ _ _ _ => rfl

/-- The cache the decoder used is empty at branch targets and landing pads, from
`cacheClearedCheck` (`Hyps.cacheOk`) and the read (`Decodes`). -/
theorem Hyps.cacheCleared (H : Hyps S)
    (hD : Decodes S code relocs rodata callSites dropped scopes mode) : CacheCleared S where
  targets := H.cacheTargets
  pads := by
    intro k pad cat hcl
    have hall : padsCleared S.r.protos S.c.d.cleanup S.targets = true := by
      have h := H.cacheOk
      unfold cacheClearedOk at h
      rw [Bool.and_eq_true] at h
      exact h.2
    have hcl' : (S.c.d.cleanup.find? (·.1 == k)).map (·.2) = some (some pad, cat) := hcl
    obtain ⟨⟨k', pad', cat'⟩, he, he2⟩ := Option.map_eq_some_iff.1 hcl'
    injection he2 with hpad hcat
    subst hpad
    have hp : padCleared S.r.protos S.targets pad = true :=
      List.all_eq_true.1 hall _ (Array.mem_toList_iff.2 (Array.mem_of_find?_eq_some he))
    unfold Setup.used
    by_cases ht : sortedContains S.targets (posOf S.r pad) = true
    · rw [if_pos ht]
    · rw [if_neg ht]
      unfold padCleared at hp
      rw [Bool.or_eq_true] at hp
      rcases hp with hp | hp
      · exact absurd hp ht
      · cases pad with
        | zero => rw [hD.cache0, hD.modeEq]
        | succ j =>
          simp only at hp
          cases hq : S.r.protos[j]? with
          | none =>
            rw [hq] at hp
            exact absurd hp (by decide)
          | some q =>
            rw [hq] at hp
            obtain ⟨hj, hqe⟩ := Array.getElem?_eq_some_iff.1 hq
            have hjl : j < S.r.protos.toList.length := by simpa using hj
            by_cases hlast : S.c.inRegion j = false ∧ S.c.inRegion (j + 1) = true
            · exact hD.cache_regionStart hlast.1 hlast.2
            obtain ⟨fr, q0, p', ca', dr', hfm, hpq, hit, hend⟩ := hD.iterAt j hjl
            have hca : ca' = S.cache (j + 1) := (hend (not_last_cases hlast)).2.1
            have hop : q0.op = q.op := by
              have e : S.r.protos.toList[j] = q := by simp [hqe]
              rcases hpq with h | h
              · rw [← h, e]
              · rw [← (S.fixResume_keep q0).1, ← h, e]
            have hc0 : clearsCache q0 = true := by
              unfold clearsCache at hp ⊢; rw [hop]; exact hp
            rw [← hca, iter_clears hit hc0, hfm]

end Ryo.Proofs.DecodeSound
