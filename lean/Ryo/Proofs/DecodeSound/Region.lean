/-
Ryo.Proofs.DecodeSound.Region — what `read` lays out for PE's pad region (toward `RegionFacts`,
PE-T1).

- `read_region`: `read` with a pad region (`regionPad … = some p`): `p ≥ regionEntryLen`; the
  region's first proto `rs` (`takeWhile`'s count) is past 0 and at `p` (`checkRegionStart`);
  `resumeSlots` then `actionsOf` give the read's protos and actions.
- `actionsOf_pad`, `resumeSlots_pos`: a cleanup action's pad is the index of a non-catching call
  site's pad (as `actionsOf_lpad`, `DSWork/Boundary.lean`); `resumeSlots` keeps positions.
- `regionFacts_entryBody`: instruction 0 is not in the region.
- `regionFacts_start`, `regionFacts_noStart`, `regionFacts_pads`: R's `regionStart` is the read's
  least cleanup pad (`regionStart_eq`), which `actionsOf` checks is the region's first proto
  (`actionsOf_least`, `read_region_start`); the entry's `Dec` from `readRegion`'s two items
  (`readParts_region`, `read_region_entry`).
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.DSWork.Boundary
import Ryo.Proofs.RSucc

namespace Ryo.Proofs.DecodeSound

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm Ryo.Proofs.DecodeLink

/-- `read` with a pad region: see the module comment. -/
theorem read_region {ro : ByteArray} {callSites : Array CallSite} {dropped : List DroppedStore}
    {scopes : Array Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor} {r : ReadResult} {p : Nat}
    (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hp : regionPad mode callSites = some p) :
    regionEntryLen ≤ p ∧ ∃ (protos0 : Array Proto) (fr : Frame) (c10 c11 c12 : Cursor),
      0 < (protos0.toList.takeWhile (·.pos < p - regionEntryLen + regionEntryLen)).length ∧
      protos0[(protos0.toList.takeWhile (·.pos < p - regionEntryLen + regionEntryLen)).length]?.map
        (·.pos) = some (p - regionEntryLen + regionEntryLen) ∧
      ((resumeSlots protos0
          (protos0.toList.takeWhile (·.pos < p - regionEntryLen + regionEntryLen)).length fr).run
          c10 = .ok (r.protos, c11) ∨ r.protos = protos0) ∧
      (actionsOf callSites r.protos
        (protos0.toList.takeWhile (·.pos < p - regionEntryLen + regionEntryLen)).length).run c11 =
        .ok (r.actions, c12) ∧
      regionLayoutOk protos0
        (protos0.toList.takeWhile (·.pos < p - regionEntryLen + regionEntryLen)).length = true ∧
      (protos0[(protos0.toList.takeWhile
        (·.pos < p - regionEntryLen + regionEntryLen)).length - 1]!).fallsThrough = false := by
  unfold Vm.read at h
  obtain ⟨⟨entry, fs⟩, c1, h1, h⟩ := bind_ok h
  dsimp only at h
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨hx, hc2⟩ := get_run h2
  rw [hx, hc2] at h
  obtain ⟨ra, c3, h3, h⟩ := bind_ok h
  have h7 : regionEntryLen ≤ p ∧ ra = some (p - regionEntryLen) := by
    unfold regionEntry at h3
    rw [hp] at h3
    try dsimp only at h3
    split at h3
    · exact (err_ok h3).elim
    · rename_i hlt
      exact ⟨by omega, (pure_ok h3).1.symm⟩
  obtain ⟨hle, rfl⟩ := h7
  refine ⟨hle, ?_⟩
  try dsimp only at h
  obtain ⟨body, c4, h4, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨x1, c5, h5, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨⟨protos, padded, bodyEnd⟩, c6, h6, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨u, c8, h8, h⟩ := bind_ok h
  simp only [checkRegionStart] at h8
  obtain ⟨hcond, -⟩ := expect_ok h8
  simp only [Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq] at hcond
  obtain ⟨heads, c9, h9, h⟩ := bind_ok h
  obtain ⟨u', c10, h10, h⟩ := bind_ok h
  try dsimp only at h
  split at h
  · obtain ⟨protos', c11, h11, h⟩ := bind_ok h
    obtain ⟨acts, c12, h12, h⟩ := bind_ok h
    try dsimp only at h
    obtain ⟨he, -⟩ := pure_ok h
    subst he
    exact ⟨protos, _, c10, c11, c12, hcond.1.1.1, hcond.1.1.2, .inl h11, h12, hcond.2,
      by simpa using hcond.1.2⟩
  · first
      | (obtain ⟨protos', c11, h11, h⟩ := bind_ok h
         obtain ⟨rfl, rfl⟩ := pure_ok h11
         obtain ⟨acts, c12, h12, h⟩ := bind_ok h
         try dsimp only at h
         obtain ⟨he, -⟩ := pure_ok h
         subst he
         exact ⟨protos, ⟨fs, mode, false⟩, c10, c10, c12, hcond.1.1.1, hcond.1.1.2, .inr rfl, h12,
           hcond.2, by simpa using hcond.1.2⟩)
      | (obtain ⟨acts, c12, h12, h⟩ := bind_ok h
         try dsimp only at h
         obtain ⟨he, -⟩ := pure_ok h
         subst he
         exact ⟨protos, ⟨fs, mode, false⟩, c10, c10, c12, hcond.1.1.1, hcond.1.1.2, .inr rfl, h12,
           hcond.2, by simpa using hcond.1.2⟩)

/-- Any `read`: its actions are `actionsOf` of its protos. -/
theorem read_actions {ro : ByteArray} {callSites : Array CallSite} {dropped : List DroppedStore}
    {scopes : Array Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor} {r : ReadResult}
    (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c')) :
    ∃ rs c11 c12, (actionsOf callSites r.protos rs).run c11 = .ok (r.actions, c12) := by
  unfold Vm.read at h
  obtain ⟨⟨entry, fs⟩, c1, h1, h⟩ := bind_ok h
  dsimp only at h
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨hx, hc2⟩ := get_run h2
  rw [hx, hc2] at h
  obtain ⟨ra, c3, h3, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨body, c4, h4, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨x1, c5, h5, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨⟨protos, padded, bodyEnd⟩, c6, h6, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨u, c8, h8, h⟩ := bind_ok h
  obtain ⟨heads, c9, h9, h⟩ := bind_ok h
  obtain ⟨u', c10, h10, h⟩ := bind_ok h
  try dsimp only at h
  -- `rs`'s `match` on the region, then the `if` around `resumeSlots` (the rest of the block in
  -- each branch)
  split at h <;> split at h <;>
  · obtain ⟨protos', c11, h11, h⟩ := bind_ok h
    obtain ⟨acts, c12, h12, h⟩ := bind_ok h
    try dsimp only at h
    obtain ⟨he, -⟩ := pure_ok h
    subst he
    exact ⟨_, c11, c12, h12⟩

/-! ### `actionsOf`, `resumeSlots` -/

/-- **Piece 2**: a cleanup action's pad (`actionsOf`'s `indexAt`) is the index of a proto at a
non-catching call site's pad. -/
theorem actionsOf_pad {callSites : Array CallSite} {protos : Array Proto} {rs : Nat}
    {c c' : Cursor} {acts : Array (Option (Option Nat × Bool))}
    (h : (actionsOf callSites protos rs).run c = .ok (acts, c')) :
    ∀ i j : Nat, acts[i]! = some (some j, false) →
      ∃ cs ∈ callSites.toList, cs.catches = false ∧ cs.pad = some (protos.map (·.pos))[j]! := by
  have ite_ok : ∀ {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α},
      (if p then x else y).run c = .ok (a, c') →
        (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
    intro α p _ x y c c' a h
    by_cases hp : p
    · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
    · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩
  have hidx : ∀ {ipos : Array Nat} {at_ b j : Nat} {c c' : Cursor},
      (indexAt ipos at_ b).run c = .ok (j, c') → ipos[j]! = b := by
    intro ipos at_ b j c c' h
    unfold indexAt at h
    split at h
    · obtain ⟨rfl, -⟩ := pure_ok h
      exact rustBinarySearch_ok ‹_›
    · exact (err_ok h).elim
  -- what the actions say of their pads
  let J : Array (Option (Option Nat × Bool)) → Prop := fun a => ∀ y ∈ a, ∀ j : Nat,
    y = some (some j, false) →
      ∃ cs ∈ callSites.toList, cs.catches = false ∧ cs.pad = some (protos.map (·.pos))[j]!
  unfold actionsOf at h
  obtain ⟨st, cA, hA, h⟩ := bind_ok h
  have key := forIn_range_inv (fun (b : _ × Nat) (_ : Cursor) => J b.1)
    (fun b _ => J b.1) _ ?_ _ _ _ _ _ ?_ hA
  rotate_left
  · intro i b cur r cur' hI hr
    obtain ⟨st, c1, h1, hr⟩ := bind_ok hr
    -- the call sites' action (the inner state is `(used, action, missing)`): from `callSites`
    have hin := forIn_list_inv
      (fun (b : Nat × _ × Bool) (_ : Cursor) => ∀ pad cat, b.2.1 = some (pad, cat) →
        ∃ cs ∈ callSites.toList, cs.pad = pad ∧ cs.catches = cat)
      (fun (b : Nat × _ × Bool) (_ : Cursor) => ∀ pad cat, b.2.1 = some (pad, cat) →
        ∃ cs ∈ callSites.toList, cs.pad = pad ∧ cs.catches = cat)
      _ ?_ _ _ _ _ _ ?_ h1
    rotate_left
    · intro a b' cur r' cur' hI' hr'
      try dsimp only at hr'
      repeat' split at hr'
      all_goals first
        | exact (err_ok hr').elim
        | (obtain ⟨_, _, h', -⟩ := bind_ok hr'; exact (err_ok h').elim)
        | (obtain ⟨rfl, -⟩ := pure_ok hr'
           first
             | exact hI'
             | (intro pad cat e
                simp only [Option.some.injEq, Prod.mk.injEq] at e
                obtain ⟨rfl, rfl⟩ := e
                exact ⟨_, Array.mem_toList_iff.2 (Array.mem_of_find?_eq_some (by assumption)),
                  rfl, rfl⟩))
    · intro pad cat e
      simp at e
    have hIn := hin.elim id id
    try dsimp only at hr
    split at hr
    · rename_i pad catches hst
      rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
      · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
      rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
      · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
      obtain ⟨cs, hcs, hcp, hcc⟩ := hIn pad catches hst
      split at hr
      · obtain ⟨_, _, h2, hr⟩ := bind_ok hr
        obtain ⟨rfl, rfl⟩ := pure_ok h2
        obtain ⟨rfl, -⟩ := pure_ok hr
        intro y hy j e
        rcases Array.mem_or_eq_of_mem_setIfInBounds hy with hy | hy
        · exact hI y hy j e
        · subst hy; cases e
      · obtain ⟨j, c3, h3, hr⟩ := bind_ok hr
        have hj := hidx h3
        rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
        obtain ⟨_, _, h2, hr⟩ := bind_ok hr
        obtain ⟨rfl, rfl⟩ := pure_ok h2
        obtain ⟨rfl, -⟩ := pure_ok hr
        intro y hy j' e
        rcases Array.mem_or_eq_of_mem_setIfInBounds hy with hy | hy
        · exact hI y hy j' e
        · subst hy
          simp only [Option.some.injEq, Prod.mk.injEq] at e
          obtain ⟨rfl, rfl⟩ := e
          exact ⟨cs, hcs, hcc, by rw [hcp, hj]⟩
    · rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
      · obtain ⟨rfl, -⟩ := pure_ok hr
        intro y hy j e
        rcases Array.mem_or_eq_of_mem_setIfInBounds hy with hy | hy
        · exact hI y hy j e
        · subst hy; cases e
      · obtain ⟨rfl, -⟩ := pure_ok hr; exact hI
  · intro y hy j e; subst e; simp [Array.mem_replicate] at hy
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  obtain ⟨he, -⟩ := pure_ok h
  subst he
  have hJ : J st.1 := key.elim id id
  intro i j hij
  by_cases hi : i < st.1.size
  · rw [getElem!_pos st.1 i hi] at hij
    exact hJ _ (Array.getElem_mem hi) j hij
  · rw [getElem!_neg st.1 i hi] at hij
    simp at hij

/-- `resumeSlots` sets handlers only, a region `resume`'s to a `trap`: same size, positions and
counter checks, and no new targets. -/
theorem resumeSlots_spec {protos : Array Proto} {rs : Nat} {fr : Frame} {c c' : Cursor}
    {out : Array Proto} (h : (resumeSlots protos rs fr).run c = .ok (out, c')) :
    out.size = protos.size ∧ ∀ i : Nat, out[i]!.pos = protos[i]!.pos ∧
      out[i]!.counter = protos[i]!.counter ∧ out[i]!.targets ⊆ protos[i]!.targets := by
  unfold resumeSlots at h
  try dsimp only at h
  obtain ⟨o, c1, h1, h2⟩ := bind_ok h
  try dsimp only at h2
  obtain ⟨rfl, -⟩ := pure_ok h2
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h1
  have key := forIn_list_inv
    (fun (o : Array Proto) (_ : Cursor) => o.size = protos.size ∧ ∀ i : Nat,
      o[i]!.pos = protos[i]!.pos ∧ o[i]!.counter = protos[i]!.counter ∧
        o[i]!.targets ⊆ protos[i]!.targets)
    (fun _ _ => False) _ ?step _ protos c c1 o
    ⟨rfl, fun _ => ⟨rfl, rfl, List.Subset.refl _⟩⟩ h1
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨hs, hp⟩ := hI
    try dsimp only at hr
    split at hr
    · split at hr
      · obtain ⟨rfl, -⟩ := pure_ok hr
        refine ⟨by rw [Array.size_set!, hs], fun i => ?_⟩
        by_cases hia : a = i
        · subst hia
          by_cases hlt : a < b.size
          · rw [Array.getElem!_set!_self _ _ _ hlt]
            refine ⟨rfl, rfl, fun t ht => ?_⟩
            simp only [Proto.targets, List.mem_append] at ht ⊢
            rcases ht with ht | ht
            · exact .inl ht
            · simp [Then.targets] at ht
          · simp only [Array.set!_eq_setIfInBounds, Array.setIfInBounds, hlt, ↓reduceDIte]
            exact hp a
        · rw [Array.getElem!_set!_ne _ _ _ _ hia]
          exact hp i
      · exact (err_ok hr).elim
    · obtain ⟨rfl, -⟩ := pure_ok hr
      exact ⟨hs, hp⟩
  rcases key with k | k
  · exact k
  · exact k.elim

/-- `resumeSlots` keeps positions. -/
theorem resumeSlots_pos {protos : Array Proto} {rs : Nat} {fr : Frame} {c c' : Cursor}
    {out : Array Proto} (h : (resumeSlots protos rs fr).run c = .ok (out, c')) :
    out.size = protos.size ∧ ∀ i : Nat, out[i]!.pos = protos[i]!.pos :=
  ⟨(resumeSlots_spec h).1, fun i => ((resumeSlots_spec h).2 i).1⟩

/-- `resumeSlots` keeps whether each proto falls through (a region `resume`'s `trap` handler
doesn't, nor does `resume`, a `trap`). -/
theorem resumeSlots_falls {protos : Array Proto} {rs : Nat} {fr : Frame} {c c' : Cursor}
    {out : Array Proto} (h : (resumeSlots protos rs fr).run c = .ok (out, c')) :
    ∀ i : Nat, out[i]!.fallsThrough = protos[i]!.fallsThrough := by
  unfold resumeSlots at h
  try dsimp only at h
  obtain ⟨o, c1, h1, h2⟩ := bind_ok h
  try dsimp only at h2
  obtain ⟨rfl, -⟩ := pure_ok h2
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h1
  have key := forIn_list_inv
    (fun (o : Array Proto) (_ : Cursor) => o.size = protos.size ∧ ∀ i : Nat,
      o[i]!.fallsThrough = protos[i]!.fallsThrough)
    (fun _ _ => False) _ ?step _ protos c c1 o
    ⟨rfl, fun _ => rfl⟩ h1
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨hs, hp⟩ := hI
    try dsimp only at hr
    split at hr
    · rename_i hres
      split at hr
      · obtain ⟨rfl, -⟩ := pure_ok hr
        refine ⟨by rw [Array.size_set!, hs], fun i => ?_⟩
        by_cases hia : a = i
        · subst hia
          by_cases hlt : a < b.size
          · rw [Array.getElem!_set!_self _ _ _ hlt]
            have hop : protos[a]!.op = .resume := by simpa using hres
            unfold Proto.fallsThrough
            cases hh : protos[a]!.handler <;> simp [hop, Ryo.Proofs.Shapes.resume_shape]
          · simp only [Array.set!_eq_setIfInBounds, Array.setIfInBounds, hlt, ↓reduceDIte]
            exact hp a
        · rw [Array.getElem!_set!_ne _ _ _ _ hia]
          exact hp i
      · exact (err_ok hr).elim
    · obtain ⟨rfl, -⟩ := pure_ok hr
      exact ⟨hs, hp⟩
  rcases key with k | k
  · exact k.2
  · exact k.elim

/-- `resumeSlots` keeps the opcodes (it rewrites only `resume`s' handlers). -/
theorem resumeSlots_op {protos : Array Proto} {rs : Nat} {fr : Frame} {c c' : Cursor}
    {out : Array Proto} (h : (resumeSlots protos rs fr).run c = .ok (out, c')) :
    ∀ i : Nat, out[i]!.op = protos[i]!.op := by
  unfold resumeSlots at h
  try dsimp only at h
  obtain ⟨o, c1, h1, h2⟩ := bind_ok h
  try dsimp only at h2
  obtain ⟨rfl, -⟩ := pure_ok h2
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h1
  have key := forIn_list_inv
    (fun (o : Array Proto) (_ : Cursor) => o.size = protos.size ∧ ∀ i : Nat,
      o[i]!.op = protos[i]!.op)
    (fun _ _ => False) _ ?step _ protos c c1 o
    ⟨rfl, fun _ => rfl⟩ h1
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨hs, hp⟩ := hI
    try dsimp only at hr
    split at hr
    · split at hr
      · obtain ⟨rfl, -⟩ := pure_ok hr
        refine ⟨by rw [Array.size_set!, hs], fun i => ?_⟩
        by_cases hia : a = i
        · subst hia
          by_cases hlt : a < b.size
          · rw [Array.getElem!_set!_self _ _ _ hlt] <;> rfl
          · simp only [Array.set!_eq_setIfInBounds, Array.setIfInBounds, hlt, ↓reduceDIte]
            exact hp a
        · rw [Array.getElem!_set!_ne _ _ _ _ hia]
          exact hp i
      · exact (err_ok hr).elim
    · obtain ⟨rfl, -⟩ := pure_ok hr
      exact ⟨hs, hp⟩
  rcases key with k | k
  · exact k.2
  · exact k.elim

/-! ### `entryBody` -/

/-- With a pad region the region's first proto is past 0, so proto 0 lies before every
non-catching call site's pad. -/
theorem read_region_first {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} {p : Nat}
    (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hp : regionPad mode callSites = some p) :
    0 < r.protos.size ∧ r.protos[0]!.pos < p := by
  obtain ⟨hle, protos0, fr, c10, c11, c12, hpos, hat, hrs, -⟩ := read_region h hp
  have hq : p - regionEntryLen + regionEntryLen = p := by omega
  rw [hq] at hpos hat hrs
  -- proto 0 satisfies `takeWhile`'s test
  have h0 : 0 < protos0.size ∧ protos0[0]!.pos < p := by
    generalize hl : protos0.toList = l at hpos
    cases l with
    | nil => simp at hpos
    | cons a l =>
      have hsz : 0 < protos0.size := by
        rw [← Array.length_toList, hl]; simp
      refine ⟨hsz, ?_⟩
      have ha : protos0[0]! = a := by
        rw [getElem!_pos protos0 0 hsz, ← Array.getElem_toList]
        simp [hl]
      rw [ha]
      by_cases hc : a.pos < p
      · exact hc
      · simp [hc] at hpos
  have hpres : r.protos.size = protos0.size ∧ r.protos[0]!.pos = protos0[0]!.pos := by
    rcases hrs with hrs | hrs
    · obtain ⟨e1, e2⟩ := resumeSlots_pos hrs
      exact ⟨e1, e2 0⟩
    · rw [hrs]
      exact ⟨rfl, rfl⟩
  exact ⟨by omega, by rw [hpres.2]; exact h0.2⟩

/-- `RegionFacts.entryBody`: instruction 0 is in the body. -/
theorem regionFacts_entryBody {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode) :
    S.c.inRegion 0 = false := by
  unfold R.Code.inRegion
  cases hpe : S.c.mode.pe with
  | false => rfl
  | true =>
    simp only [Bool.true_and]
    cases hst : S.c.d.regionStart with
    | none => rfl
    | some j =>
      simp only [Option.any_some, decide_eq_false_iff_not, Nat.not_le]
      apply Nat.pos_of_ne_zero
      rintro rfl
      -- pad 0 is a cleanup action's
      have hmem := List.min?_mem hst
      simp only [List.mem_filterMap, List.mem_filter, Bool.not_eq_true'] at hmem
      obtain ⟨⟨i, pad, cat⟩, ⟨hin, hcat⟩, hpad⟩ := hmem
      simp only at hcat hpad
      subst hpad
      rw [reducedOf_cleanup hred] at hin
      simp only [List.mem_filterMap, List.mem_range, Option.map_eq_some_iff,
        Prod.mk.injEq] at hin
      obtain ⟨i', -, ⟨pad', cat'⟩, hact, rfl, rfl, rfl⟩ := hin
      have hc0 : cat' = false := hcat
      rw [hc0] at hact
      -- the read's actions and region
      have hpe' : mode.pe = true := by rw [← hm]; exact hpe
      -- the region exists: the pad is a non-catching call site's
      have hp : ∃ p, regionPad mode callSites = some p := by
        obtain ⟨rs0, c11, c12, hao⟩ := read_actions hread
        obtain ⟨cs, hcs, hcc, hcp⟩ := actionsOf_pad hao i' 0 hact
        unfold regionPad
        rw [hpe']
        simp only [↓reduceIte]
        cases hmin : ((callSites.toList.filter (!·.catches)).filterMap (·.pad)).min? with
        | some p => exact ⟨p, rfl⟩
        | none =>
          rw [List.min?_eq_none_iff] at hmin
          have hm' : (S.r.protos.map (·.pos))[0]! ∈
              (callSites.toList.filter (!·.catches)).filterMap (·.pad) :=
            List.mem_filterMap.2 ⟨cs, List.mem_filter.2 ⟨hcs, by simp [hcc]⟩, hcp⟩
          rw [hmin] at hm'
          cases hm'
      obtain ⟨p, hp⟩ := hp
      obtain ⟨-, protos0, fr, c10, c11, c12', -, -, -, hao, -⟩ := read_region hread hp
      obtain ⟨cs, hcs, hcc, hcp⟩ := actionsOf_pad hao i' 0 hact
      obtain ⟨hsz0, hfirst⟩ := read_region_first hread hp
      have hmap : (S.r.protos.map (·.pos))[0]! = S.r.protos[0]!.pos := by
        rw [getElem!_pos (S.r.protos.map (·.pos)) 0 (by simpa using hsz0), Array.getElem_map,
          getElem!_pos S.r.protos 0 hsz0]
      rw [hmap] at hcp
      -- `p` is the least non-catching pad
      have hle : p ≤ S.r.protos[0]!.pos := by
        unfold regionPad at hp
        rw [hpe'] at hp
        simp only [↓reduceIte] at hp
        have hm' : S.r.protos[0]!.pos ∈ (callSites.toList.filter (!·.catches)).filterMap (·.pad) :=
          List.mem_filterMap.2 ⟨cs, List.mem_filter.2 ⟨hcs, by simp [hcc]⟩, hcp⟩
        have := List.min?_getD_le_of_mem (k := 0) hm'
        rw [hp] at this
        exact this
      omega

/-! ### `start`, `noStart`, `pads` -/

theorem dm_ite_ok {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α}
    (h : (if p then x else y).run c = .ok (a, c')) :
    (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
  by_cases hp : p
  · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
  · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩

/-- `actionsOf`'s last check: with a pad region (`rs` a proto), it starts at the least cleanup
pad. -/
theorem actionsOf_least {callSites : Array CallSite} {protos : Array Proto} {rs : Nat}
    {c c' : Cursor} {acts : Array (Option (Option Nat × Bool))}
    (h : (actionsOf callSites protos rs).run c = .ok (acts, c')) (hrs : rs < protos.size) :
    leastCleanupPad acts = some rs := by
  unfold actionsOf at h
  obtain ⟨st, cA, hA, h⟩ := bind_ok h
  rcases dm_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  rcases dm_ite_ok h with ⟨-, h⟩ | ⟨hn, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  rcases dm_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  obtain ⟨he, -⟩ := pure_ok h
  subst he
  simp [bne_iff_ne] at hn
  exact hn hrs

/-- `actionsOf`'s region check (`regionActionsOk`). -/
theorem actionsOf_regionOk {callSites : Array CallSite} {protos : Array Proto} {rs : Nat}
    {c c' : Cursor} {acts : Array (Option (Option Nat × Bool))}
    (h : (actionsOf callSites protos rs).run c = .ok (acts, c')) :
    regionActionsOk protos acts rs = true := by
  unfold actionsOf at h
  obtain ⟨st, cA, hA, h⟩ := bind_ok h
  rcases dm_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  rcases dm_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  rcases dm_ite_ok h with ⟨-, h⟩ | ⟨hn, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  obtain ⟨he, -⟩ := pure_ok h
  subst he
  simpa using hn

/-- What `regionActionsOk` says. -/
theorem regionActionsOk_spec {protos : Array Proto} {acts : Array (Option (Option Nat × Bool))}
    {rs : Nat} (h : regionActionsOk protos acts rs = true) :
    (∀ i j : Nat, acts[i]! = some (some j, true) → (rs ≤ j ↔ rs ≤ i)) ∧
      ∀ i : Nat, i < protos.size → protos[i]!.op = .resume → rs ≤ i →
        acts[i]! = some (none, false) := by
  unfold regionActionsOk at h
  simp only [Bool.and_eq_true, List.all_eq_true, List.mem_range] at h
  obtain ⟨h1, h2⟩ := h
  refine ⟨fun i j hij => ?_, fun i hi hop hle => ?_⟩
  · by_cases hi : i < acts.size
    · have := h1 i hi
      rw [hij] at this
      simpa using this
    · rw [getElem!_neg acts i hi] at hij
      simp at hij
  · have := h2 i hi
    simpa [hop, hle] using this

/-- R's region start is the read's least cleanup pad. -/
theorem regionStart_eq {r : ReadResult} {pe : Bool} {d : Decoded} (hred : reducedOf r pe = .ok d) :
    d.regionStart = leastCleanupPad r.actions := by
  unfold Decoded.regionStart leastCleanupPad cleanupOf
  rw [reducedOf_cleanup hred]

/-- A pad in R's cleanup list (`regionStart`'s) is a cleanup action's. -/
theorem cleanup_action {r : ReadResult} {pe : Bool} {d : Decoded} (hred : reducedOf r pe = .ok d)
    {m : Nat} (hm : m ∈ (d.cleanup.toList.filter (!·.2.2)).filterMap (·.2.1)) :
    ∃ i : Nat, r.actions[i]! = some (some m, false) := by
  simp only [List.mem_filterMap, List.mem_filter, Bool.not_eq_true'] at hm
  obtain ⟨⟨i, pad, cat⟩, ⟨hin, hcat⟩, hpad⟩ := hm
  simp only at hcat hpad
  subst hpad
  rw [reducedOf_cleanup hred] at hin
  simp only [List.mem_filterMap, List.mem_range, Option.map_eq_some_iff, Prod.mk.injEq] at hin
  obtain ⟨i', -, ⟨pad', cat'⟩, hact, rfl, rfl, rfl⟩ := hin
  have hc0 : cat' = false := hcat
  rw [hc0] at hact
  exact ⟨i', hact⟩

/-- On PE, a cleanup action means a pad region (`regionPad`). -/
theorem regionPad_some {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (hread : (Vm.read rodata callSites dropped scopes mode).run c = .ok (r, c'))
    (hpe : mode.pe = true) {i j : Nat} (hact : r.actions[i]! = some (some j, false)) :
    ∃ p, regionPad mode callSites = some p := by
  obtain ⟨rs0, c11, c12, hao⟩ := read_actions hread
  obtain ⟨cs, hcs, hcc, hcp⟩ := actionsOf_pad hao i j hact
  unfold regionPad
  rw [hpe]
  simp only [↓reduceIte]
  cases hmin : ((callSites.toList.filter (!·.catches)).filterMap (·.pad)).min? with
  | some p => exact ⟨p, rfl⟩
  | none =>
    rw [List.min?_eq_none_iff] at hmin
    have hm' : (r.protos.map (·.pos))[j]! ∈
        (callSites.toList.filter (!·.catches)).filterMap (·.pad) :=
      List.mem_filterMap.2 ⟨cs, List.mem_filter.2 ⟨hcs, by simp [hcc]⟩, hcp⟩
    rw [hmin] at hm'
    cases hm'

/-- What `regionLayoutOk` says. -/
theorem regionLayoutOk_spec {protos : Array Proto} {rs : Nat} (h : regionLayoutOk protos rs = true) :
    (∀ k, k < protos.size → rs ≤ k → protos[k]!.counter = none) ∧
      (∀ k, k < protos.size → ∀ t ∈ protos[k]!.targets, ∀ j, j < protos.size →
        protos[j]!.pos = t → (rs ≤ j ↔ rs ≤ k)) := by
  unfold regionLayoutOk at h
  simp only [List.all_eq_true, List.mem_range, Bool.and_eq_true] at h
  refine ⟨fun k hk hle => ?_, fun k hk t ht j hj hpj => ?_⟩
  · have := (h k hk).1.1
    simp only [Bool.or_eq_true, decide_eq_true_eq, Option.isNone_iff_eq_none] at this
    exact this.resolve_left (by omega)
  · have := (h k hk).2 t ht j hj
    simp only [Bool.or_eq_true, bne_iff_ne, ne_eq, beq_iff_eq, decide_eq_decide] at this
    rcases this with h1 | h1
    · exact absurd hpj h1
    · exact h1

/-- `regionLayoutOk`'s B2 part: no `ret` or tail call in the region. -/
theorem regionLayoutOk_shape {protos : Array Proto} {rs : Nat} (h : regionLayoutOk protos rs = true)
    {k : Nat} (hk : k < protos.size) (hle : rs ≤ k) :
    protos[k]!.op.info.shape ≠ .ret ∧ protos[k]!.op.info.shape ≠ .tailCall := by
  unfold regionLayoutOk at h
  simp only [List.all_eq_true, List.mem_range, Bool.and_eq_true] at h
  have := (h k hk).1.2
  simp only [Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true', Bool.or_eq_false_iff,
    beq_eq_false_iff_ne] at this
  exact this.resolve_left (by omega)

/-- With a pad region at `p`: the region's first proto `L` is the least cleanup pad, at `p`. -/
theorem read_region_start {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (hread : (Vm.read rodata callSites dropped scopes mode).run c = .ok (r, c'))
    {p : Nat} (hp : regionPad mode callSites = some p) :
    ∃ L, L < r.protos.size ∧ leastCleanupPad r.actions = some L ∧ posOf r L = p ∧
      regionEntryLen ≤ p ∧ regionActionsOk r.protos r.actions L = true ∧
      (∀ k, k < r.protos.size → L ≤ k → r.protos[k]!.counter = none) ∧
      (∀ k, k < r.protos.size → ∀ t ∈ r.protos[k]!.targets, ∀ j, j < r.protos.size →
        posOf r j = t → (L ≤ j ↔ L ≤ k)) ∧
      0 < L ∧ (r.protos[L - 1]!).fallsThrough = false := by
  obtain ⟨hle, protos0, fr, c10, c11, c12, hpos, hat, hres, hao, hlay, hfall⟩ :=
    read_region hread hp
  have hq : p - regionEntryLen + regionEntryLen = p := by omega
  rw [hq] at hpos hat hres hao hlay hfall
  generalize hLd : (protos0.toList.takeWhile (·.pos < p)).length = L at hpos hat hres hao hlay hfall
  have hL : L < protos0.size := by
    by_cases h : L < protos0.size
    · exact h
    · rw [Array.getElem?_eq_none (by omega)] at hat
      simp at hat
  have hpres : r.protos.size = protos0.size ∧ r.protos[L]!.pos = protos0[L]!.pos := by
    rcases hres with hres | hres
    · obtain ⟨e1, e2⟩ := resumeSlots_pos hres
      exact ⟨e1, e2 L⟩
    · rw [hres]
      exact ⟨rfl, rfl⟩
  have hLr : L < r.protos.size := by omega
  -- the protos after `resumeSlots`
  have hsp : r.protos.size = protos0.size ∧ ∀ i : Nat, r.protos[i]!.pos = protos0[i]!.pos ∧
      r.protos[i]!.counter = protos0[i]!.counter ∧ r.protos[i]!.targets ⊆ protos0[i]!.targets := by
    rcases hres with hres | hres
    · exact resumeSlots_spec hres
    · rw [hres]
      exact ⟨rfl, fun _ => ⟨rfl, rfl, List.Subset.refl _⟩⟩
  obtain ⟨hlc, hlt⟩ := regionLayoutOk_spec hlay
  have hsz := hsp.1
  have hfl : (r.protos[L - 1]!).fallsThrough = false := by
    rcases hres with hres | hres
    · rw [resumeSlots_falls hres (L - 1)]; exact hfall
    · rw [hres]; exact hfall
  refine ⟨L, hLr, actionsOf_least hao hLr, ?_, hle, actionsOf_regionOk hao,
    fun k hk hLk => ?_, fun k hk t ht j hj hpj => ?_, hpos, hfl⟩
  · rw [posOf_eq hLr, ← getElem!_pos r.protos L hLr, hpres.2, getElem!_pos protos0 L hL]
    rw [Array.getElem?_eq_getElem hL] at hat
    simpa using hat
  · rw [(hsp.2 k).2.1]
    exact hlc k (by omega) hLk
  · refine hlt k (by omega) t ((hsp.2 k).2.2 ht) j (by omega) ?_
    rw [← (hsp.2 j).1, ← hpj, posOf_eq hj, getElem!_pos r.protos j hj]

/-- With a pad region at `p`: no `ret` or tail call from the region's first proto on
(`regionLayoutOk_shape`; `resumeSlots` keeps the opcodes). -/
theorem read_region_shape {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (hread : (Vm.read rodata callSites dropped scopes mode).run c = .ok (r, c'))
    {p : Nat} (hp : regionPad mode callSites = some p) :
    ∃ L, leastCleanupPad r.actions = some L ∧
      ∀ k, k < r.protos.size → L ≤ k →
        r.protos[k]!.op.info.shape ≠ .ret ∧ r.protos[k]!.op.info.shape ≠ .tailCall := by
  obtain ⟨hle, protos0, fr, c10, c11, c12, hpos, hat, hres, hao, hlay, hfall⟩ :=
    read_region hread hp
  have hq : p - regionEntryLen + regionEntryLen = p := by omega
  rw [hq] at hpos hat hres hao hlay hfall
  generalize hLd : (protos0.toList.takeWhile (·.pos < p)).length = L at hpos hat hres hao hlay hfall
  have hL : L < protos0.size := by
    by_cases h : L < protos0.size
    · exact h
    · rw [Array.getElem?_eq_none (by omega)] at hat
      simp at hat
  have hsp : r.protos.size = protos0.size ∧ ∀ i : Nat, r.protos[i]!.op = protos0[i]!.op := by
    rcases hres with hres | hres
    · exact ⟨(resumeSlots_spec hres).1, resumeSlots_op hres⟩
    · rw [hres]
      exact ⟨rfl, fun _ => rfl⟩
  have hsz := hsp.1
  have hLr : L < r.protos.size := by omega
  refine ⟨L, actionsOf_least hao hLr, fun k hk hLk => ?_⟩
  rw [hsp.2 k]
  exact regionLayoutOk_shape hlay (by omega) hLk

/-- `readParts`' region branch: `readRegion`'s entry, `sub rsp, 40; jmp r11`, 7 bytes from `r`. -/
theorem readParts_region {fr : Frame} {ro : ByteArray} {callSites : Array CallSite}
    {d1 d2 : List DroppedStore} {stubs : Option Nat} {body limit size r : Nat}
    {targets : Option (Array Nat)} {c c' : Cursor} {x : Array Proto × Array Bool × Nat}
    (h : (readParts fr ro callSites d1 d2 stubs (some r) body limit size targets).run c =
      .ok (x, c')) :
    ∃ n1 n2, decodeItem (atPos c r) = some (.subRsp (BitVec.ofNat 32 peRegionAlloc), n1) ∧
      decodeItem (atPos c (r + n1)) = some (.jmpR11, n2) ∧ r + n1 + n2 = r + regionEntryLen := by
  unfold readParts at h
  obtain ⟨u, c1, h1, h⟩ := bind_ok h
  rw [run_setPos] at h1; cases h1
  obtain ⟨⟨ps, pd⟩, c2, h2, h⟩ := bind_ok h
  have e2 := (instructions_read h2).2.1
  obtain ⟨be, c3, h3, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pos_run' h3
  obtain ⟨u, c4, h4, h⟩ := bind_ok h
  obtain ⟨-, rfl⟩ := expect_ok h4
  try dsimp only at h
  obtain ⟨⟨rp, rpd⟩, c5, h5, h⟩ := bind_ok h
  unfold readRegion at h5
  obtain ⟨u, c6, h6, h5⟩ := bind_ok h5
  rw [run_setPos] at h6; cases h6
  obtain ⟨i1, c7, h7, h5⟩ := bind_ok h5
  obtain ⟨n1, hd1, rfl⟩ := run_item h7
  obtain ⟨u, c8, h8, h5⟩ := bind_ok h5
  obtain ⟨he1, rfl⟩ := expect_ok h8
  obtain ⟨i2, c9, h9, h5⟩ := bind_ok h5
  obtain ⟨n2, hd2, rfl⟩ := run_item h9
  obtain ⟨q, c10, h10, h5⟩ := bind_ok h5
  obtain ⟨rfl, rfl⟩ := pos_run' h10
  obtain ⟨u, c11, h11, h5⟩ := bind_ok h5
  obtain ⟨he2, rfl⟩ := expect_ok h11
  simp only [Bool.and_eq_true, beq_iff_eq] at he1 he2
  obtain ⟨rfl, hq⟩ := he2
  subst he1
  rw [e2] at hd1
  rw [e2] at hd2
  exact ⟨n1, n2, hd1, hd2, hq⟩

/-- `read` with a pad region at `p`: its entry, in the body's cursor (of the read's frame size). -/
theorem read_region_items {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} {p : Nat}
    (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hp : regionPad mode callSites = some p) :
    ∃ n1 n2, decodeItem (bodyCursor c mode r.frameSize (p - regionEntryLen)) =
        some (.subRsp (BitVec.ofNat 32 peRegionAlloc), n1) ∧
      decodeItem (bodyCursor c mode r.frameSize (p - regionEntryLen + n1)) = some (.jmpR11, n2) ∧
      p - regionEntryLen + n1 + n2 = p - regionEntryLen + regionEntryLen := by
  unfold Vm.read at h
  obtain ⟨⟨entry, fs⟩, c1, h1, h⟩ := bind_ok h
  have hc1 := readFrame_body h1
  dsimp only at h
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨hx, hc2⟩ := get_run h2
  rw [hx, hc2] at h
  obtain ⟨ra, c3, h3, h⟩ := bind_ok h
  have h7 : ra = some (p - regionEntryLen) ∧ c3 = c1 := by
    unfold regionEntry at h3
    rw [hp] at h3
    try dsimp only at h3
    split at h3
    · exact (err_ok h3).elim
    · exact ⟨(pure_ok h3).1.symm, (pure_ok h3).2.symm⟩
  obtain ⟨rfl, rfl⟩ := h7
  try dsimp only at h
  obtain ⟨body, c4, h4, h⟩ := bind_ok h
  obtain ⟨-, rfl⟩ := pos_run' h4
  try dsimp only at h
  obtain ⟨x1, c5, h5, h⟩ := bind_ok h
  have e5 := readParts_pos h5
  try dsimp only at h
  obtain ⟨⟨protos, padded, bodyEnd⟩, c6, h6, h⟩ := bind_ok h
  obtain ⟨n1, n2, hd1, hd2, hsum⟩ := readParts_region h6
  -- the read's frame size
  have hfs : r.frameSize = fs := by
    try dsimp only at h
    obtain ⟨u, c8, -, h⟩ := bind_ok h
    obtain ⟨heads, c9, -, h⟩ := bind_ok h
    obtain ⟨u', c10, -, h⟩ := bind_ok h
    try dsimp only at h
    split at h
    · obtain ⟨protos', c11, -, h⟩ := bind_ok h
      obtain ⟨acts, c12, -, h⟩ := bind_ok h
      try dsimp only at h
      obtain ⟨he, -⟩ := pure_ok h
      subst he
      rfl
    · first
        | (obtain ⟨protos', c11, -, h⟩ := bind_ok h
           obtain ⟨acts, c12, -, h⟩ := bind_ok h
           try dsimp only at h
           obtain ⟨he, -⟩ := pure_ok h
           subst he
           rfl)
        | (obtain ⟨acts, c12, -, h⟩ := bind_ok h
           try dsimp only at h
           obtain ⟨he, -⟩ := pure_ok h
           subst he
           rfl)
  have hcur : ∀ q, atPos c5 q = bodyCursor c mode r.frameSize q := by
    intro q
    rw [e5, hfs, hc1]
    rfl
  rw [hcur] at hd1
  rw [hcur] at hd2
  exact ⟨n1, n2, hd1, hd2, hsum⟩

/-- `readRegion`'s entry, `sub rsp, 40; jmp r11` at `p - regionEntryLen`, in the body's
cursor. -/
theorem read_region_entry {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run
      { code := code.data, pos := 0, fields := .relocs relocs } = .ok (S.r, c'))
    (hbody : S.body = bodyCursor { code := code.data, pos := 0, fields := .relocs relocs } mode
      S.r.frameSize S.body.pos)
    {p : Nat} (hp : regionPad mode callSites = some p) :
    Dec S.body (p - regionEntryLen) [.subRsp (BitVec.ofNat 32 peRegionAlloc), .jmpR11] p := by
  obtain ⟨hle, -⟩ := read_region hread hp
  obtain ⟨n1, n2, hd1, hd2, hsum⟩ := read_region_items hread hp
  have hS : ∀ q, atPos S.body q = bodyCursor { code := code.data, pos := 0, fields := .relocs relocs }
      mode S.r.frameSize q := by
    intro q
    rw [hbody]
    rfl
  have hend : p - regionEntryLen + n1 + n2 = p := by omega
  refine .cons (by rw [hS]; exact hd1) (.cons (by rw [hS]; exact hd2) ?_)
  rw [hend]
  exact .nil _

/-- `RegionFacts.start`. -/
theorem regionFacts_start {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run
      { code := code.data, pos := 0, fields := .relocs relocs } = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode)
    (hbody : S.body = bodyCursor { code := code.data, pos := 0, fields := .relocs relocs } mode
      S.r.frameSize S.body.pos) :
    ∀ rs, S.c.mode.pe = true → S.c.d.regionStart = some rs →
      rs < S.r.protos.size ∧ regionPad mode callSites = some (posOf S.r rs) ∧
      regionEntryLen ≤ posOf S.r rs ∧
      Dec S.body (posOf S.r rs - regionEntryLen)
        [.subRsp (BitVec.ofNat 32 peRegionAlloc), .jmpR11] (posOf S.r rs) := by
  intro rs hpe hst
  have hpe' : mode.pe = true := by rw [← hm]; exact hpe
  obtain ⟨i, hact⟩ := cleanup_action hred (List.min?_mem hst)
  obtain ⟨p, hp⟩ := regionPad_some hread hpe' hact
  obtain ⟨L, hL, hleast, hpos, hle, -, -, -⟩ := read_region_start hread hp
  rw [regionStart_eq hred, hleast] at hst
  obtain rfl : L = rs := Option.some.inj hst
  rw [hpos]
  exact ⟨hL, hp, hle, read_region_entry hread hbody hp⟩

/-- `RegionFacts.noStart`. -/
theorem regionFacts_noStart {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) :
    S.c.mode.pe = true → S.c.d.regionStart = none → regionPad mode callSites = none := by
  intro _ hnone
  cases hp : regionPad mode callSites with
  | none => rfl
  | some p =>
    obtain ⟨L, -, hleast, -, -, -, -, -⟩ := read_region_start hread hp
    rw [regionStart_eq hred, hleast] at hnone
    cases hnone

/-- `RegionFacts.pads`: a cleanup pad is at or after the least one. -/
theorem regionFacts_pads {S : Setup} :
    ∀ k pad, S.c.mode.pe = true → S.c.cleanupAt k = some (some pad, false) →
      S.c.inRegion pad = true := by
  intro k pad hpe hk
  unfold R.Code.cleanupAt at hk
  obtain ⟨e, he, he2⟩ := Option.map_eq_some_iff.1 hk
  have hem : e ∈ S.c.d.cleanup.toList := Array.mem_toList_iff.2 (Array.mem_of_find?_eq_some he)
  have hmem : pad ∈ (S.c.d.cleanup.toList.filter (!·.2.2)).filterMap (·.2.1) := by
    refine List.mem_filterMap.2 ⟨e, List.mem_filter.2 ⟨hem, ?_⟩, ?_⟩
    · rw [he2]; rfl
    · rw [he2]
  unfold R.Code.inRegion Decoded.regionStart
  rw [hpe]
  cases hmin : ((S.c.d.cleanup.toList.filter (!·.2.2)).filterMap (·.2.1)).min? with
  | none =>
    rw [List.min?_eq_none_iff] at hmin
    rw [hmin] at hmem
    cases hmem
  | some m =>
    have := List.min?_getD_le_of_mem (k := 0) hmem
    rw [hmin] at this
    simpa using this

/-! ### `resume`, `catchPads` -/

/-- An entry of R's `cleanup` is an action's. -/
theorem mem_cleanup {r : ReadResult} {pe : Bool} {d : Decoded} (hred : reducedOf r pe = .ok d)
    {e : Nat × Option Nat × Bool} (he : e ∈ d.cleanup) : r.actions[e.1]! = some e.2 := by
  rw [reducedOf_cleanup hred] at he
  simp only [List.mem_toArray, List.mem_filterMap, List.mem_range, Option.map_eq_some_iff] at he
  obtain ⟨i, -, ⟨pad, c⟩, hact, rfl⟩ := he
  exact hact

/-- `cleanupAt k` is action `k`. -/
theorem cleanupAt_inv {r : ReadResult} {pe : Bool} {c : R.Code} (hred : reducedOf r pe = .ok c.d)
    {k : Nat} {a : Option Nat × Bool} (hk : c.cleanupAt k = some a) : r.actions[k]! = some a := by
  unfold R.Code.cleanupAt at hk
  obtain ⟨e, he, rfl⟩ := Option.map_eq_some_iff.1 hk
  have hp : e.1 = k := by simpa using Array.find?_some he
  have := mem_cleanup hred (Array.mem_of_find?_eq_some he)
  rw [hp] at this
  exact this

theorem cleanupAt_eq {r : ReadResult} {pe : Bool} {c : R.Code} (hred : reducedOf r pe = .ok c.d)
    {k : Nat} {a : Option Nat × Bool} (hk : r.actions[k]! = some a) : c.cleanupAt k = some a := by
  obtain ⟨pa, ca⟩ := a
  have hks : k < r.actions.size := by
    by_cases h : k < r.actions.size
    · exact h
    · rw [getElem!_neg r.actions k h] at hk
      simp at hk
  have hmem : (k, (pa, ca)) ∈ c.d.cleanup := by
    rw [reducedOf_cleanup hred]
    simp only [List.mem_toArray, List.mem_filterMap, List.mem_range, Option.map_eq_some_iff]
    exact ⟨k, hks, (pa, ca), hk, rfl⟩
  unfold R.Code.cleanupAt
  cases hf : c.d.cleanup.find? (·.1 == k) with
  | none =>
    rw [Array.find?_eq_none] at hf
    exact (hf _ hmem (by simp)).elim
  | some e =>
    have hp : e.1 = k := by simpa using Array.find?_some hf
    have he := mem_cleanup hred (Array.mem_of_find?_eq_some hf)
    rw [hp, hk] at he
    show some e.2 = some (pa, ca)
    exact congrArg some (Option.some.inj he).symm

/-- With a region starting at `L`, `actionsOf`'s region check holds for `L`. -/
theorem regionActionsOk_of_start {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode) (hpe : S.c.mode.pe = true)
    {L : Nat} (hst : S.c.d.regionStart = some L) :
    regionActionsOk S.r.protos S.r.actions L = true := by
  have hpe' : mode.pe = true := by rw [← hm]; exact hpe
  obtain ⟨i, hact⟩ := cleanup_action hred (List.min?_mem hst)
  obtain ⟨p, hp⟩ := regionPad_some hread hpe' hact
  obtain ⟨L', -, hleast, -, -, hok, -, -⟩ := read_region_start hread hp
  rw [regionStart_eq hred, hleast] at hst
  obtain rfl : L' = L := Option.some.inj hst
  exact hok

/-- `RegionFacts.resume`. -/
theorem regionFacts_resume {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode) :
    ∀ k (hk : k < S.r.protos.size), S.c.inRegion k = true → S.r.protos[k].op = .resume →
      S.c.cleanupAt k = some (none, false) := by
  intro k hk hin hop
  unfold R.Code.inRegion at hin
  cases hpe : S.c.mode.pe with
  | false => rw [hpe] at hin; cases hin
  | true =>
    rw [hpe] at hin
    cases hst : S.c.d.regionStart with
    | none => rw [hst] at hin; cases hin
    | some L =>
      rw [hst] at hin
      have hLk : L ≤ k := by simpa using hin
      have hok := regionActionsOk_of_start hread hred hm hpe hst
      have hop' : S.r.protos[k]!.op = .resume := by rw [getElem!_pos S.r.protos k hk]; exact hop
      exact cleanupAt_eq hred ((regionActionsOk_spec hok).2 k hk hop' hLk)

/-- `RegionFacts.catchPads`. -/
theorem regionFacts_catchPads {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode) :
    ∀ k pad, S.c.cleanupAt k = some (some pad, true) → S.c.inRegion pad = S.c.inRegion k := by
  intro k pad hk
  unfold R.Code.inRegion
  cases hpe : S.c.mode.pe with
  | false => rfl
  | true =>
    cases hst : S.c.d.regionStart with
    | none => rfl
    | some L =>
      have hok := regionActionsOk_of_start hread hred hm hpe hst
      have h := (regionActionsOk_spec hok).1 k pad (cleanupAt_inv hred hk)
      simp only [Bool.true_and, Option.any_some]
      by_cases h1 : L ≤ k
      · simp [h1, h.2 h1]
      · have h2 : ¬ L ≤ pad := fun h' => h1 (h.1 h')
        simp [h1, h2]

/-! ### `heads`, `noCross` -/

/-- With a region starting at `L`: no counter check from `L` on, no target across `L`. -/
theorem regionLayout_of_start {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode) (hpe : S.c.mode.pe = true)
    {L : Nat} (hst : S.c.d.regionStart = some L) :
    (∀ k, k < S.r.protos.size → L ≤ k → S.r.protos[k]!.counter = none) ∧
      (∀ k, k < S.r.protos.size → ∀ t ∈ S.r.protos[k]!.targets, ∀ j, j < S.r.protos.size →
        posOf S.r j = t → (L ≤ j ↔ L ≤ k)) := by
  have hpe' : mode.pe = true := by rw [← hm]; exact hpe
  obtain ⟨i, hact⟩ := cleanup_action hred (List.min?_mem hst)
  obtain ⟨p, hp⟩ := regionPad_some hread hpe' hact
  obtain ⟨L', -, hleast, -, -, -, hc, ht, -⟩ := read_region_start hread hp
  rw [regionStart_eq hred, hleast] at hst
  obtain rfl : L' = L := Option.some.inj hst
  exact ⟨hc, ht⟩

/-- `RegionFacts.heads`. -/
theorem regionFacts_heads {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode) :
    ∀ k (hk : k < S.r.protos.size), S.r.protos[k].counter.isSome = true →
      S.c.inRegion k = false := by
  intro k hk hc
  unfold R.Code.inRegion
  cases hpe : S.c.mode.pe with
  | false => rfl
  | true =>
    cases hst : S.c.d.regionStart with
    | none => rfl
    | some L =>
      simp only [Bool.true_and, Option.any_some, decide_eq_false_iff_not]
      intro hLk
      have h0 := (regionLayout_of_start hread hred hm hpe hst).1 k hk hLk
      rw [getElem!_pos S.r.protos k hk] at h0
      rw [h0] at hc
      simp at hc

/-- `RegionFacts.noCross`. -/
theorem regionFacts_noCross {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode) :
    ∀ k (hk : k < S.r.protos.size), ∀ t ∈ S.r.protos[k].targets, ∀ j,
      j < S.r.protos.size → posOf S.r j = t → S.c.inRegion j = S.c.inRegion k := by
  intro k hk t ht j hj hpj
  unfold R.Code.inRegion
  cases hpe : S.c.mode.pe with
  | false => rfl
  | true =>
    cases hst : S.c.d.regionStart with
    | none => rfl
    | some L =>
      have ht' : t ∈ S.r.protos[k]!.targets := by rw [getElem!_pos S.r.protos k hk]; exact ht
      have h := (regionLayout_of_start hread hred hm hpe hst).2 k hk t ht' j hj hpj
      simp only [Bool.true_and, Option.any_some]
      by_cases h1 : L ≤ k
      · simp [h1, h.2 h1]
      · have h2 : ¬ L ≤ j := fun h' => h1 (h.1 h')
        simp [h1, h2]

/-! ### `bodyEnd` -/

/-- A loop step's state. -/
def stepVal {β : Type} : ForInStep β → β
  | .done b => b
  | .yield b => b

/-- An invariant of a loop in `Id`. -/
theorem forIn_id_inv {α β : Type} (I : β → Prop) (f : α → β → Id (ForInStep β))
    (hf : ∀ a b, I b → I (stepVal (f a b))) :
    ∀ (l : List α) (b : β), I b → I (forIn l b f)
  | [], b, hb => by rw [List.forIn_nil]; exact hb
  | a :: l, b, hb => by
    rw [List.forIn_cons]
    have h1 := hf a b hb
    obtain ⟨r, hr⟩ : ∃ r : ForInStep β, f a b = r := ⟨_, rfl⟩
    rw [hr] at h1 ⊢
    cases r with
    | done b' => exact h1
    | yield b' => exact forIn_id_inv I f hf l b' h1

/-- `binary_search`'s `Ok` index is in the array. -/
theorem rustBinarySearch_lt {a : Array Nat} {x i : Nat} (h : rustBinarySearch a x = .ok i) :
    i < a.size := by
  unfold rustBinarySearch at h
  simp only [Id.run] at h
  split at h
  · cases h
  · rename_i hne
    have hpos : a.size ≠ 0 := fun h0 => hne (by simp [h0])
    have key : ∀ s : Nat × Nat, s.2 < a.size → ((if (a[s.2]! == x) = true then pure (Except.ok s.2)
        else pure (Except.error (if a[s.2]! < x then s.2 + 1 else s.2))) : Id (Except Nat Nat)) =
          Except.ok i → i < a.size := by
      intro s hs hs'
      split at hs'
      · cases hs'; exact hs
      · cases hs'
    refine key _ ?_ h
    have fin : ∀ r : Nat × Nat, 1 ≤ r.1 ∧ r.2 + r.1 ≤ a.size → r.2 < a.size :=
      fun r hr => by omega
    apply fin
    rw [Std.Legacy.Range.forIn_eq_forIn_range']
    apply forIn_id_inv (fun b : Nat × Nat => 1 ≤ b.1 ∧ b.2 + b.1 ≤ a.size)
    all_goals first
      | exact ⟨by show 1 ≤ a.size; omega, by show 0 + a.size ≤ a.size; omega⟩
      | (intro _ b hb
         obtain ⟨sz, bs⟩ := b
         obtain ⟨h1, h2⟩ := hb
         try dsimp only at h1 h2 ⊢
         by_cases hle : sz ≤ 1
         · simp only [hle, ↓reduceIte]
           exact ⟨h1, h2⟩
         · simp only [hle, ↓reduceIte]
           split
           all_goals first
             | (show 1 ≤ sz - sz / 2 ∧ bs + sz / 2 + (sz - sz / 2) ≤ a.size; omega)
             | (show 1 ≤ sz - sz / 2 ∧ bs + (sz - sz / 2) ≤ a.size; omega))

section
variable {ε : Type} {f : Nat → Except ε Nat} {n : Nat} (hb : ∀ b i, f b = .ok i → i < n)
include hb

theorem mapM_lt : ∀ {ts ts' : List Nat}, ts.mapM f = .ok ts' → ∀ j ∈ ts', j < n
  | [], ts', h => by simp only [List.mapM_nil] at h; cases h; simp
  | t :: ts, ts', h => by
    simp only [List.mapM_cons] at h
    obtain ⟨i, h1, h⟩ := ebind_ok h
    obtain ⟨is, h2, h⟩ := ebind_ok h
    cases h
    intro j hj
    rcases List.mem_cons.1 hj with rfl | hj
    · exact hb _ _ h1
    · exact mapM_lt h2 j hj

theorem mapTargets_lt {o o' : Opnd Nat} (h : o.mapTargets f = .ok o') :
    ∀ j ∈ o'.targetsOf, j < n := by
  cases o <;> simp only [Opnd.mapTargets, pure, Except.pure, Functor.map, Except.map] at h
  all_goals first
    | (cases h; simp [Opnd.targetsOf])
    | (split at h
       · cases h
       · rename_i v hv; cases h
         first
           | (intro j hj
              simp only [Opnd.targetsOf, List.mem_singleton] at hj
              subst hj
              exact hb _ _ hv)
           | (intro j hj; exact mapM_lt hb hv j hj))

theorem thenMapM_lt {t t' : Then Nat} (h : t.mapM f = .ok t') : ∀ j ∈ t'.targets, j < n := by
  cases t <;> simp only [Then.mapM, pure, Except.pure, Functor.map, Except.map] at h
  all_goals first
    | (cases h; simp [Then.targets])
    | (split at h
       · cases h
       · rename_i v hv; cases h
         first
           | (intro j hj
              simp only [Then.targets, List.mem_singleton] at hj
              subst hj
              exact hb _ _ hv)
           | (intro j hj; exact mapM_lt hb hv j hj))

theorem opsMapM_lt {os os' : List (Opnd Nat)} (h : os.mapM (·.mapTargets f) = .ok os') :
    ∀ j ∈ os'.flatMap Opnd.targetsOf, j < n := by
  induction os generalizing os' with
  | nil => simp only [List.mapM_nil] at h; cases h; simp
  | cons o os ih =>
    simp only [List.mapM_cons] at h
    obtain ⟨o', h1, h⟩ := ebind_ok h
    obtain ⟨os'', h2, h⟩ := ebind_ok h
    cases h
    intro j hj
    simp only [List.flatMap_cons, List.mem_append] at hj
    rcases hj with hj | hj
    · exact mapTargets_lt hb h1 j hj
    · exact ih h2 j hj

end

/-- `reducedOf`'s targets are instructions (`binary_search`'s `Ok` index is in range). -/
theorem reducedOf_targets_lt {r : ReadResult} {pe : Bool} {d : Decoded}
    (h : reducedOf r pe = .ok d) :
    ∀ k (hk' : k < d.insns.size), ∀ j ∈ RSucc.insnTargets d.insns[k], j < r.protos.size := by
  unfold reducedOf at h
  obtain ⟨insns, h1, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  have hidx : ∀ (at_ b i : Nat), (match rustBinarySearch (r.protos.map (·.pos)) b with
      | Except.ok i => pure i
      | Except.error _ => throw { at_ := at_, what := "target isn't an instruction" } :
        Except AsmError Nat) = .ok i → i < r.protos.size := by
    intro at_ b i hi
    split at hi
    · rename_i j hj
      cases hi
      have := rustBinarySearch_lt hj
      simpa using this
    · cases hi
  rw [← Array.forIn_toList] at h1
  have key := forIn_push (fun (_ : Proto) (i : R.Insn) => ∀ j ∈ RSucc.insnTargets i,
    j < r.protos.size) _ ?hf r.protos.toList #[] insns h1
  case hf =>
    intro p acc res hres
    simp only at hres
    split at hres
    · rename_i args t ht
      obtain ⟨t', h4, h5⟩ := ebind_ok hres
      cases h5
      exact ⟨_, rfl, thenMapM_lt (hidx p.pos) h4⟩
    · rename_i hn
      obtain ⟨ops, h4, h5⟩ := ebind_ok hres
      split at h5
      · rename_i op hop
        cases h5
        exact ⟨_, rfl, opsMapM_lt (hidx p.pos) h4⟩
      · obtain ⟨_, h6, -⟩ := ebind_ok h5
        cases h6
  obtain ⟨ext, he, hl, hr⟩ := key
  simp only [List.nil_append] at he
  have hsz : insns.size = r.protos.size := by
    rw [← Array.length_toList, he, hl, Array.length_toList]
  intro k hk'
  have hk : k < r.protos.size := by rw [← hsz]; exact hk'
  have := hr k (by simpa using hk) (by rw [hl]; simpa using hk)
  have e : insns[k] = ext[k]'(by rw [hl]; simpa using hk) := by
    simp only [← Array.getElem_toList, he]
  simp only [e]; exact this

/-- An instruction falls through as its proto. -/
theorem insnFalls_of {pos : Nat → Nat} {p : Proto} {i : R.Insn} (h : InsnOf pos p i) :
    RSucc.insnFalls i = p.fallsThrough := by
  unfold InsnOf at h
  unfold Proto.fallsThrough
  cases hh : p.handler with
  | some at_ =>
    obtain ⟨args, t⟩ := at_
    simp only [hh] at h
    obtain ⟨t', rfl, -⟩ := h
    rfl
  | none =>
    simp only [hh] at h
    obtain ⟨op, ops, hop, rfl, -⟩ := h
    simp only [RSucc.insnFalls, DeadStore.reduced_shape (privc_full_of hop)]

theorem thenMap_targets {pos : Nat → Nat} {t : R.Then Nat} {j : Nat} (h : j ∈ t.targets) :
    pos j ∈ (thenMap pos t).targets := by
  cases t with
  | next => simp [R.Then.targets] at h
  | trap => simp [R.Then.targets] at h
  | branch n x =>
    simp only [R.Then.targets, List.mem_singleton] at h
    subst h
    simp [thenMap, R.Then.targets]
  | table ts =>
    simp only [thenMap, R.Then.targets]
    exact List.mem_map.2 ⟨j, h, rfl⟩

theorem opsMap_targets {pos : Nat → Nat} {ops : List (Opnd Nat)} {j : Nat}
    (h : j ∈ ops.flatMap Opnd.targetsOf) :
    pos j ∈ (ops.map (opndMap pos)).flatMap Opnd.targetsOf := by
  obtain ⟨o, ho, hj⟩ := List.mem_flatMap.1 h
  refine List.mem_flatMap.2 ⟨opndMap pos o, List.mem_map.2 ⟨o, ho, rfl⟩, ?_⟩
  cases o
  case target t =>
    simp only [Opnd.targetsOf, List.mem_singleton] at hj
    subst hj
    simp [opndMap, Opnd.targetsOf]
  case targets ts => exact List.mem_map.2 ⟨j, hj, rfl⟩
  case cases v ts => exact List.mem_map.2 ⟨j, hj, rfl⟩
  all_goals simp [Opnd.targetsOf] at hj

/-- An instruction's targets are its proto's, through `pos`. -/
theorem insnTargets_of {pos : Nat → Nat} {p : Proto} {i : R.Insn} (h : InsnOf pos p i) {j : Nat}
    (hj : j ∈ RSucc.insnTargets i) : pos j ∈ p.targets := by
  unfold InsnOf at h
  unfold Proto.targets
  cases hh : p.handler with
  | some at_ =>
    obtain ⟨args, t⟩ := at_
    simp only [hh] at h
    obtain ⟨t', rfl, ht⟩ := h
    refine List.mem_append_right _ ?_
    rw [← ht]
    exact thenMap_targets hj
  | none =>
    simp only [hh] at h
    obtain ⟨op, ops, -, rfl, hops⟩ := h
    refine List.mem_append_left _ ?_
    rw [← hops]
    exact opsMap_targets hj

/-- `RegionFacts.bodyEnd` (PE-T1): an R step from the body into the region goes through a
cleanup pad. R's successors of instruction `k` (`RSucc.rnext_succ`) are `k + 1` (when it falls
through), one of its targets, or a pad of `cleanupAt k`. Then: `k + 1 = L` would make proto
`L - 1` fall through (`checkRegionStart`, `read_region_start`); a target crosses no start
(`noCross`; targets are instructions, `reducedOf_targets_lt`); a catching pad is on its call's
side (`catchPads`); a cleanup pad is the conclusion. -/
theorem regionFacts_bodyEnd {S : Setup} {rodata : ByteArray} {callSites : Array CallSite}
    {dropped : Array DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run c = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode) :
    ∀ s s', S.c.inRegion s.pc = false → RNext S.c s s' → S.c.inRegion s'.pc = true →
      ∃ pad, S.c.mode.pe = true ∧ S.c.cleanupAt s.pc = some (some pad, false) ∧ s'.pc = pad := by
  intro s s' hs hn hs'
  obtain ⟨i, hi, hsucc⟩ := RSucc.rnext_succ hn
  have hs0 := hs
  have hs'0 := hs'
  have hins := reducedOf_insns hred
  have hk' : s.pc < S.c.d.insns.size := by
    by_cases h' : s.pc < S.c.d.insns.size
    · exact h'
    · rw [Array.getElem?_eq_none (by omega)] at hi
      cases hi
  have hk : s.pc < S.r.protos.size := by rw [← hins.1]; exact hk'
  have hii : S.c.d.insns[s.pc] = i := by
    rw [Array.getElem?_eq_getElem hk'] at hi
    exact Option.some.inj hi
  have hio : InsnOf (posOf S.r) S.r.protos[s.pc] i := by
    rw [← hii]; exact hins.2 s.pc hk hk'
  unfold R.Code.inRegion at hs hs'
  cases hpe : S.c.mode.pe with
  | false => rw [hpe] at hs'; simp at hs'
  | true =>
    cases hst : S.c.d.regionStart with
    | none => rw [hpe, hst] at hs'; simp at hs'
    | some L =>
      rw [hpe, hst] at hs hs'
      have hL' : L ≤ s'.pc := by simpa using hs'
      have hL : ¬ L ≤ s.pc := by simpa using hs
      rcases hsucc with ⟨hp1, hfall⟩ | htg | ⟨pad, b, hcl, hpad⟩
      · -- falling through into the region: proto `L - 1` doesn't
        exfalso
        have hpe' : mode.pe = true := by rw [← hm]; exact hpe
        obtain ⟨i0, hact⟩ := cleanup_action hred (List.min?_mem hst)
        obtain ⟨p, hp⟩ := regionPad_some hread hpe' hact
        obtain ⟨L', -, hleast, -, -, -, -, -, hL0, hnf⟩ := read_region_start hread hp
        have hst2 := hst
        rw [regionStart_eq hred, hleast] at hst2
        have hLL : L' = L := Option.some.inj hst2
        rw [hLL] at hnf
        have e : L - 1 = s.pc := by omega
        rw [e, getElem!_pos S.r.protos s.pc hk] at hnf
        rw [insnFalls_of hio, hnf] at hfall
        cases hfall
      · -- a target: no branch crosses the region's start
        exfalso
        have hj : s'.pc < S.r.protos.size :=
          reducedOf_targets_lt hred s.pc hk' s'.pc (by rw [hii]; exact htg)
        have hpt := insnTargets_of hio htg
        have hx := regionFacts_noCross hread hred hm s.pc hk _ hpt s'.pc hj rfl
        rw [hs'0, hs0] at hx
        cases hx
      · cases b with
        | false => exact ⟨pad, by first | rfl | exact hpe, hcl, hpad⟩
        | true =>
          -- a catching pad is on its call's side
          exfalso
          have hx := regionFacts_catchPads hread hred hm s.pc pad hcl
          rw [← hpad, hs'0, hs0] at hx
          cases hx

/-! ### Facts for the pad region's simulation (PE-P2, PE-P3)

Statements of the decoder facts (A2-A4, B1, B2) and the `RegionInv` helpers the region's
simulation (`rinsnSim_peClean`, `rinsnSim_region`) uses. -/

section RegionSim

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- A2: a body instruction that falls through doesn't fall into the region (the body's last
instruction doesn't fall through: `checkRegionStart`, as in `regionFacts_bodyEnd`). -/
theorem Decodes.fallBody (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} {i : R.Insn} (hb : S.c.inRegion k = false) (hi : S.c.d.insns[k]? = some i)
    (hfl : RSucc.insnFalls i = true) : S.c.inRegion (k + 1) = false := by
  obtain ⟨c', hread⟩ := hD.read
  have hred := hD.reduced
  have hm := hD.modeEq
  have hins := reducedOf_insns hred
  have hk' : k < S.c.d.insns.size := by
    by_cases h' : k < S.c.d.insns.size
    · exact h'
    · rw [Array.getElem?_eq_none (by omega)] at hi
      cases hi
  have hk : k < S.r.protos.size := by rw [← hins.1]; exact hk'
  have hii : S.c.d.insns[k] = i := by
    rw [Array.getElem?_eq_getElem hk'] at hi
    exact Option.some.inj hi
  have hio : InsnOf (posOf S.r) S.r.protos[k] i := by
    rw [← hii]; exact hins.2 k hk hk'
  cases hr1 : S.c.inRegion (k + 1) with
  | false => rfl
  | true =>
    exfalso
    have hs := hb
    unfold R.Code.inRegion at hs hr1
    cases hpe : S.c.mode.pe with
    | false => rw [hpe] at hr1; simp at hr1
    | true =>
      cases hst : S.c.d.regionStart with
      | none => rw [hpe, hst] at hr1; simp at hr1
      | some L =>
        rw [hpe, hst] at hs hr1
        have hL' : L ≤ k + 1 := by simpa using hr1
        have hL : ¬ L ≤ k := by simpa using hs
        have hpe' : mode.pe = true := by rw [← hm]; exact hpe
        obtain ⟨i0, hact⟩ := cleanup_action hred (List.min?_mem hst)
        obtain ⟨p, hp⟩ := regionPad_some hread hpe' hact
        obtain ⟨L', -, hleast, -, -, -, -, -, hL0, hnf⟩ := read_region_start hread hp
        have hst2 := hst
        rw [regionStart_eq hred, hleast] at hst2
        have hLL : L' = L := Option.some.inj hst2
        rw [hLL] at hnf
        have e : L - 1 = k := by omega
        rw [e, getElem!_pos S.r.protos k hk] at hnf
        rw [insnFalls_of hio, hnf] at hfl
        cases hfl

/-- A2: no leading `arg` reaches the region (an `arg` falls through, the body's last instruction
doesn't; `Decodes.argsSucc`). -/
theorem region_not_leadArg (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} (hk : k ≤ S.r.protos.size) (hr : S.c.inRegion k = true) :
    ¬ LeadArg S k ∧ S.args k = false := by
  sorry -- PE-P2

/-- A3: a body instruction with a cleanup entry has call sites (`actionsOf` maps call sites to
the protos holding their return addresses). -/
theorem cleanup_sites (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} (hk : k < S.r.protos.size) {e : Option Nat × Bool}
    (hcl : S.c.cleanupAt k = some e) (hb : S.c.inRegion k = false) :
    S.r.protos[k].sites ≠ [] := by
  sorry -- PE-P2

/-- A4: an instruction that is neither a call, an island nor a `resume` goes to the next one
(when it falls through) or to one of its targets: it doesn't unwind (`stepView`'s non-resume
branch; sharper than `RSucc.rnext_succ`, whose `Succ` allows a landing pad). -/
theorem rnext_plain {c : R.Code} {s s' : R.RState} (h : RNext c s s') {i : R.Insn}
    (hi : c.d.insns[s.pc]? = some i)
    (hnc : ∀ (op : Reduced.Opcode) (ops : List (R.Opnd Nat)) (f : Full.Opcode),
      i = .native op ops → op.full = some f → f.info.shape ≠ .call ∧ f.info.shape ≠ .island)
    (hnr : ∀ (args : List R.Arg) (t : R.Then Nat), i ≠ .handler .resume args t) :
    (s'.pc = s.pc + 1 ∧ RSucc.insnFalls i = true) ∨ s'.pc ∈ RSucc.insnTargets i := by
  sorry -- PE-P2

/-- B1: the region's entry `sub rsp, 40; jmp r11` starts at a relocation boundary (the body's
end without counters, `readParts`'s `bodyEnd = limit`; with counters the counter stubs' end,
`checkStubs`). -/
theorem regionEntry_boundary (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {rs : Nat} (hpe : S.c.mode.pe = true) (hrs : S.c.d.regionStart = some rs) {m : Mem}
    (hL : LinkOkF S.ctx m S.body S.rs S.c.mode) :
    Boundary S.rs (posOf S.r rs - regionEntryLen) := by
  sorry -- PE-P2

/-- B2: no `ret` or tail call in the region (`regionLayoutOk_shape`; `resumeSlots` keeps the
opcodes). -/
theorem region_shape (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} (hk : k < S.r.protos.size) (hr : S.c.inRegion k = true) :
    S.r.protos[k].op.info.shape ≠ .ret ∧ S.r.protos[k].op.info.shape ≠ .tailCall := by
  obtain ⟨c', hread⟩ := hD.read
  have hred := hD.reduced
  have hm := hD.modeEq
  unfold R.Code.inRegion at hr
  cases hpe : S.c.mode.pe with
  | false => rw [hpe] at hr; cases hr
  | true =>
    rw [hpe] at hr
    cases hst : S.c.d.regionStart with
    | none => rw [hst] at hr; cases hr
    | some L =>
      rw [hst] at hr
      have hLk : L ≤ k := by simpa using hr
      have hpe' : mode.pe = true := by rw [← hm]; exact hpe
      obtain ⟨i, hact⟩ := cleanup_action hred (List.min?_mem hst)
      obtain ⟨p, hp⟩ := regionPad_some hread hpe' hact
      obtain ⟨L', hleast, hsh⟩ := read_region_shape hread hp
      rw [regionStart_eq hred, hleast] at hst
      obtain rfl : L' = L := Option.some.inj hst
      have h := hsh k hk hLk
      rw [getElem!_pos S.r.protos k hk] at h
      exact h

/-- The ghost frame state of the region: `x` with the body's `rsp`. Everything `FrameInv` says
holds of it (`room` from `below` and `room`, `args` vacuous by `region_not_leadArg`). -/
theorem RegionInv.ghost (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {e : X86.State} {s : R.RState} {x : X86.State} (h : RegionInv S e s x) :
    FrameInv S s (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)) := by
  have hne : ∀ i : Fin 16, i ≠ Reg.rsp.idx →
      (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).regs i = x.regs i := fun i hi => by
    simp only [X86.State.setReg, if_neg hi]
  have h5 : (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).reg .rbp = x.reg .rbp :=
    hne Reg.rbp.idx (by decide)
  have hrsp : (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp =
      x.reg .rbp - BitVec.ofNat 64 S.F := by
    simp [X86.State.rsp, X86.State.reg, X86.State.setReg]
  have hc := h.toFrameCore.congr h5
    (fun i hi => hne i (fun e => (Call.saved_ne hi).2.2.2 (e.trans rfl))) rfl
  have hb := h.below
  have hro := h.room
  refine FrameInv.ofCore hc (by rw [hrsp, h5]) (by rw [hrsp]; bv_omega) ?_
  intro ha
  exact absurd ha (region_not_leadArg hD (Nat.le_of_lt ha.1) h.inR).1

/-- No live allocation is runtime-owned or on the stack below the frame (`EnvApart.allocs` at
the ghost state), so none holds the region's 48 bytes `[rsp, rsp + 48)` (the outgoing and home
area, the trampoline's return address). Stronger than `EnvApartR.allocs` (below the region's
`rsp` only), which doesn't keep `RegionInv.tramp` across a callee's writes to live
allocations. -/
theorem RegionInv.allocsOff (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {e : X86.State} {s : R.RState} {x : X86.State} (h : RegionInv S e s x) :
    ∀ a, Call.InAlloc s.world a →
      ¬ S.Owned a ∧ ¬ Counter.InStack S.lo (x.reg .rbp - BitVec.ofNat 64 S.F) a := by
  intro a ha
  have hrsp : (x.setReg .rsp (x.reg .rbp - BitVec.ofNat 64 S.F)).rsp =
      x.reg .rbp - BitVec.ofNat 64 S.F := by
    simp [X86.State.rsp, X86.State.reg, X86.State.setReg]
  have := H.envApart.allocs s _ (RegionInv.ghost hD h) a ha
  rw [hrsp] at this
  exact this

end RegionSim

end Ryo.Proofs.DecodeSound
