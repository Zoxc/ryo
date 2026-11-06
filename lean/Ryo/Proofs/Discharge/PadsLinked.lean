/-
Ryo.Proofs.Discharge.PadsLinked — `PadsLinked` from the decoder and `Hyps`' `unwinderReadsLsda`,
`startsDistinct` and `sitesAligned` (`Hyps.padsLinked`; the definitions are in
`DecodeSound/Basic.lean`).

`PadsLinked S` can't be proved from the checks alone: `Setup.padOf` is an unconstrained field
(the unwinder's return address → landing pad map, as the call and island contracts use it), and
no check or Setup field ties it to the LSDA. It splits into two parts:

1. `UnwinderReadsLsda`, an environment assumption about `rust_eh_personality` (the trusted
   `Hyps` field `unwinderReadsLsda`): the pad for a return address in the function is the pad of
   the LSDA call site holding it (the personality looks up `ip - 1`, so `start < p ≤ start +
   len`), with no pad when there's no such site. Together with `unwindChecks` (the LSDA parses
   to the image's call sites, `NOUNWIND` written as continue) and `S.callSites` being those
   sites, this is the LSDA "as linked".
2. `SitesLinked`, a decoder lemma to prove from `read`'s acceptance (`DecodeReduced` §"unwind
   actions", lines ~978-1093): each call site of proto `k` is in `S.callSites` with its exact
   start and length, the sites of one instruction agree, and `Decoded.cleanup` holds the pad as
   the index of the `lpad` proto at the site's pad byte offset. It also needs the call sites
   to be sorted by start with distinct starts, which the module comment of `DecodeReduced`
   says images check, but `read` doesn't. `siteAt`'s first match is then the site at `k`.
   Pad positions must also be below `2 ^ 32`, since `pos32` truncates (see the `posOf S.r pad
   < 2 ^ 32` field in `DSWork/Island.lean`).

`padsLinked_of` derives `PadsLinked` from the two.

`sitesLinked_of_decodes` proves `SitesLinked` from `Decodes` plus three facts `read` doesn't check:

- `StartsDistinct callSites`: no two call sites share a start. No image check verifies it
  (`Check/Image/Unwind.lean` compares the LSDA with the image's call-site table and checks the
  sites lie in the body, not their order); the writer (`lsda::write`) emits them sorted by start.
- `SitesAligned S`: a call site whose return-address range `(start, start + len]` meets an
  instruction's call site range starts where that one does. `actionsOf` only matches sites by
  exact start, and an instruction none of whose sites match is silently left without an action,
  so a misaligned call site covering its call isn't rejected. (It would follow from the decoded
  calls' byte ranges being disjoint and every call site being used, which `read` checks only by
  count.)
- `S.body.code.size < 2 ^ 32` (as `LinkOk.small` gives), for the pads' positions.

`actionsOf` (`pl_actionsOf`) gives, for each site of each instruction, either the call site
starting there with its length and the instruction's action (its pad as the `lpad` proto at the
pad's byte offset), or no call site starting there and no landing pad.
-/
import Ryo.Proofs.DSWork.Boundary
import Ryo.Proofs.Discharge.CallSites

set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeSound

open Ryo.Vm Ryo.Vm.Asm Ryo.X86 Ryo.Vm.R Ryo.Proofs.DecodeLink

/-- Needed (decoder lemma, from `read`'s acceptance plus sorted distinct call-site starts): the
LSDA's pad at a return address in instruction `k`'s call sites is `k`'s cleanup pad's position. -/
def SitesLinked (S : Setup) : Prop :=
  ∀ k (hk : k < S.r.protos.size), ∀ site ∈ S.r.protos[k].sites, ∀ p, site.1 < p →
    p ≤ site.1 + site.2 →
    lsdaPad S p = match S.c.cleanupAt k with
      | some (some pad, _) => some ((pos32 S.r pad).setWidth 64)
      | _ => none

theorem padsLinked_of {S : Setup} (hU : UnwinderReadsLsda S) (hB : SitesLinked S) :
    PadsLinked S := by
  intro k hk site hs p h1 h2
  rw [hU.1 p, hB k hk site hs p h1 h2]
  generalize S.c.cleanupAt k = c
  rcases c with _ | ⟨_ | pad, cat⟩ <;> rfl

/-! ## `SitesLinked` from the decoder -/

/-- `actionsOf`'s inner loop state for one site `x`: no call site starts there and `missing`, or
the call site starting there has `x`'s length and gave `action`. -/
abbrev SiteI (callSites : Array CallSite) (x : Nat × Nat) (action : Option (Option Nat × Bool))
    (missing : Bool) : Prop :=
  (callSites.find? (·.start == x.1) = none ∧ missing = true) ∨
  ∃ cs, callSites.find? (·.start == x.1) = some cs ∧ cs.len = x.2 ∧
    action = some (cs.pad, cs.catches)

/-- What `actionsOf` gives an instruction with site `x`: the call site starting there, its
length, and the instruction's action `y` from it (its pad the `lpad` at the pad's offset), or no
call site starting there and no landing pad. -/
abbrev AOk (protos : Array Proto) (callSites : Array CallSite) (x : Nat × Nat)
    (y : Option (Option Nat × Bool)) : Prop :=
  (∃ cs, callSites.find? (·.start == x.1) = some cs ∧ cs.len = x.2 ∧
    ∃ pad', y = some (pad', cs.catches) ∧
      ((cs.pad = none ∧ pad' = none) ∨
        ∃ b j, cs.pad = some b ∧ pad' = some j ∧ (protos.map (·.pos))[j]! = b)) ∨
  (callSites.find? (·.start == x.1) = none ∧ (y = none ∨ y = some (none, false)))

theorem pl_ite_ok {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α}
    (h : (if p then x else y).run c = .ok (a, c')) :
    (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
  by_cases hp : p
  · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
  · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩

macro "pl_err " h:ident : tactic => `(tactic| first
  | exact (err_ok $h).elim
  | (obtain ⟨_, _, h', -⟩ := bind_ok $h; exact (err_ok h').elim))

theorem pl_indexAt {ipos : Array Nat} {at_ b j : Nat} {c c' : Cursor}
    (h : (indexAt ipos at_ b).run c = .ok (j, c')) : ipos[j]! = b := by
  unfold indexAt at h
  try dsimp only at h
  split at h
  · rename_i i hi
    obtain ⟨rfl, -⟩ := pure_ok h
    exact rustBinarySearch_ok hi
  · exact (err_ok h).elim

/-- A loop each step of which shows `Post` of its element and keeps it for the others. -/
theorem pl_forIn_acc_gen {α β : Type} (Post : α → β → Prop) (f : α → β → DM (ForInStep β))
    (hstep : ∀ a b c r c', (f a b).run c = .ok (r, c') →
      ∃ b', r = .yield b' ∧ Post a b' ∧ ∀ x, Post x b → Post x b') :
    ∀ (l : List α) (init b : β) (c c' : Cursor), (forIn l init f).run c = .ok (b, c') →
      ∀ x, (x ∈ l ∨ Post x init) → Post x b
  | [], init, b, c, c', h => by
    simp only [List.forIn_nil] at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    rintro x (hx | hx)
    · simp at hx
    · exact hx
  | a :: l, init, b, c, c', h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    obtain ⟨b', rfl, hpa, hkeep⟩ := hstep a init c r c1 h1
    intro x hx
    refine pl_forIn_acc_gen Post f hstep l b' b c1 c' h2 x ?_
    rcases hx with hx | hx
    · rcases List.mem_cons.1 hx with rfl | hx
      · exact .inr hpa
      · exact .inl hx
    · exact .inr (hkeep x hx)

theorem pl_forIn_acc {α β : Type} {f : α → β → DM (ForInStep β)} {l : List α} {init b : β}
    {c c' : Cursor} (h : (forIn l init f).run c = .ok (b, c')) (Post : α → β → Prop)
    (hstep : ∀ a b c r c', (f a b).run c = .ok (r, c') →
      ∃ b', r = .yield b' ∧ Post a b' ∧ ∀ x, Post x b → Post x b') :
    ∀ x ∈ l, Post x b :=
  fun x hx => pl_forIn_acc_gen Post f hstep l init b c c' h x (.inl hx)

/-- A loop over distinct elements, each step of which needs `Pre` of its element, shows `Post`
of it and keeps both for the others. -/
theorem pl_forIn_idx_gen {α β : Type} (Pre Post : α → β → Prop) (f : α → β → DM (ForInStep β))
    (hstep : ∀ a b c r c', Pre a b → (f a b).run c = .ok (r, c') → ∃ b', r = .yield b' ∧
      Post a b' ∧ (∀ x, x ≠ a → Pre x b → Pre x b') ∧ (∀ x, x ≠ a → Post x b → Post x b')) :
    ∀ (l : List α) (init b : β) (c c' : Cursor), l.Nodup → (∀ x ∈ l, Pre x init) →
      (forIn l init f).run c = .ok (b, c') → ∀ x, (x ∈ l ∨ (x ∉ l ∧ Post x init)) → Post x b
  | [], init, b, c, c', _, _, h => by
    simp only [List.forIn_nil] at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    rintro x (hx | ⟨-, hx⟩)
    · simp at hx
    · exact hx
  | a :: l, init, b, c, c', hnd, hpre, h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    obtain ⟨b', rfl, hpa, hpre', hpost'⟩ := hstep a init c r c1 (hpre a (by simp)) h1
    have hnd' := List.nodup_cons.1 hnd
    have IH := pl_forIn_idx_gen Pre Post f hstep l b' b c1 c' hnd'.2
      (fun x hx => hpre' x (fun e => hnd'.1 (e ▸ hx)) (hpre x (List.mem_cons_of_mem a hx))) h2
    intro x hx
    by_cases hxl : x ∈ l
    · exact IH x (.inl hxl)
    · by_cases hxa : x = a
      · subst hxa; exact IH x (.inr ⟨hxl, hpa⟩)
      · rcases hx with hx | ⟨-, hx⟩
        · rcases List.mem_cons.1 hx with e | hx
          · exact absurd e hxa
          · exact absurd hx hxl
        · exact IH x (.inr ⟨hxl, hpost' x hxa hx⟩)

theorem pl_forIn_idx {α β : Type} {f : α → β → DM (ForInStep β)} {l : List α} {init b : β}
    {c c' : Cursor} (h : (forIn l init f).run c = .ok (b, c')) (Pre Post : α → β → Prop)
    (hstep : ∀ a b c r c', Pre a b → (f a b).run c = .ok (r, c') → ∃ b', r = .yield b' ∧
      Post a b' ∧ (∀ x, x ≠ a → Pre x b → Pre x b') ∧ (∀ x, x ≠ a → Post x b → Post x b'))
    (hnd : l.Nodup) (hpre : ∀ x ∈ l, Pre x init) : ∀ x ∈ l, Post x b :=
  fun x hx => pl_forIn_idx_gen Pre Post f hstep l init b c c' hnd hpre h x (.inl hx)

theorem pl_post_self {protos : Array Proto} {callSites : Array CallSite} {L : List (Nat × Nat)}
    {acts : Array (Option (Option Nat × Bool))} {a : Nat} {v : Option (Option Nat × Bool)}
    (ha : a < acts.size) (hP : ∀ y ∈ L, AOk protos callSites y v) :
    ∀ y ∈ L, AOk protos callSites y (acts.set! a v)[a]! := by
  rw [Array.getElem!_set!_self acts a v ha]; exact hP

theorem pl_post_set {protos : Array Proto} {callSites : Array CallSite} {L : List (Nat × Nat)}
    {acts : Array (Option (Option Nat × Bool))} {a x : Nat} {v : Option (Option Nat × Bool)}
    (hxa : x ≠ a) (hP : ∀ y ∈ L, AOk protos callSites y acts[x]!) :
    ∀ y ∈ L, AOk protos callSites y (acts.set! a v)[x]! := by
  rw [Array.getElem!_set!_ne acts a x v (Ne.symm hxa)]; exact hP

theorem pl_pre_set {n : Nat} {acts : Array (Option (Option Nat × Bool))} {a x : Nat}
    {v : Option (Option Nat × Bool)} (hxa : x ≠ a)
    (hP : x < n ∧ acts.size = n ∧ acts[x]! = none) :
    x < n ∧ (acts.set! a v).size = n ∧ (acts.set! a v)[x]! = none := by
  rw [Array.size_set!, Array.getElem!_set!_ne acts a x v (Ne.symm hxa)]; exact hP

/-- What `actionsOf` gives each site of each instruction (`AOk`). -/
theorem pl_actionsOf {callSites : Array CallSite} {protos : Array Proto} {rs : Nat}
    {c c' : Cursor} {acts : Array (Option (Option Nat × Bool))}
    (h : (actionsOf callSites protos rs).run c = .ok (acts, c')) :
    ∀ k, k < protos.size → ∀ x ∈ protos[k]!.sites, AOk protos callSites x acts[k]! := by
  unfold actionsOf at h
  obtain ⟨st, cA, hA, h⟩ := bind_ok h
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at hA
  have key := pl_forIn_idx hA
    (fun k b => k < protos.size ∧ b.1.size = protos.size ∧ b.1[k]! = none)
    (fun k b => ∀ x ∈ protos[k]!.sites, AOk protos callSites x b.1[k]!)
    ?step (List.nodup_range' 1 Nat.one_pos) ?pre0
  case pre0 =>
    intro x hx
    obtain ⟨i, hi, hni⟩ := List.mem_range'.1 hx
    simp only [Std.Legacy.Range.size] at hi hni
    have hx' : x < protos.size := by omega
    refine ⟨hx', by simp, ?_⟩
    show (Array.replicate protos.size (none : Option (Option Nat × Bool)))[x]! = none
    rw [getElem!_pos _ x (by simpa using hx')]
    simp
  case step =>
    intro a b cur r cur' hPre hr
    obtain ⟨hal, hsz, hnone⟩ := hPre
    obtain ⟨st, c1, h1, hr⟩ := bind_ok hr
    -- The do-notation's order of the inner loop's variables (`used` first; then `action`,
    -- `missing` in some order): both are tried.
    first
      | have hin := pl_forIn_acc h1 (fun x st => SiteI callSites x st.2.1 st.2.2) ?istep
      | have hin := pl_forIn_acc h1 (fun x st => SiteI callSites x st.2.2 st.2.1) ?istep
    case istep =>
      intro x st0 cc r0 cc' hr0
      obtain ⟨s, l⟩ := x
      first
        | (obtain ⟨used0, act0, mis0⟩ := st0; have _t : Bool := mis0)
        | (obtain ⟨used0, mis0, act0⟩ := st0; have _t : Bool := mis0)
      try dsimp only at hr0
      split at hr0
      · rename_i cs hcs
        rcases pl_ite_ok hr0 with ⟨hlen, hr0⟩ | ⟨-, hr0⟩
        · rcases pl_ite_ok hr0 with ⟨-, hr0⟩ | ⟨hany, hr0⟩
          · pl_err hr0
          obtain ⟨rfl, -⟩ := pure_ok hr0
          refine ⟨_, rfl, Or.inr ⟨cs, hcs, by simpa using hlen, rfl⟩, ?_⟩
          rintro y (⟨hy, hm⟩ | ⟨cs', hy, hl, ha⟩)
          · exact Or.inl ⟨hy, hm⟩
          · refine Or.inr ⟨cs', hy, hl, ?_⟩
            have ha' : act0 = some (cs'.pad, cs'.catches) := ha
            subst ha'
            have h2 : ¬ (((cs'.pad, cs'.catches) != (cs.pad, cs.catches)) = true) := hany
            have h3 : (cs'.pad, cs'.catches) = (cs.pad, cs.catches) := by simpa using h2
            show some (cs.pad, cs.catches) = some (cs'.pad, cs'.catches)
            rw [h3]
        · pl_err hr0
      · rename_i hcs
        obtain ⟨rfl, -⟩ := pure_ok hr0
        refine ⟨_, rfl, Or.inl ⟨hcs, rfl⟩, ?_⟩
        rintro y (⟨hy, hm⟩ | ⟨cs', hy, hl, ha⟩)
        · exact Or.inl ⟨hy, rfl⟩
        · exact Or.inr ⟨cs', hy, hl, ha⟩
    first
      | (obtain ⟨used', action, missing⟩ := st; have _t : Bool := missing)
      | (obtain ⟨used', missing, action⟩ := st; have _t : Bool := missing)
    try dsimp only at hr
    cases action with
    | none =>
      have key : ∀ x ∈ protos[a]!.sites, callSites.find? (·.start == x.1) = none := by
        intro x hx
        rcases hin x hx with ⟨hf, -⟩ | ⟨cs, -, -, ha⟩
        · exact hf
        · simp at ha
      try dsimp only at hr
      rcases pl_ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
      · obtain ⟨rfl, -⟩ := pure_ok hr
        exact ⟨_, rfl, pl_post_self (by omega) (fun x hx => Or.inr ⟨key x hx, Or.inr rfl⟩),
          fun x hxa hP => pl_pre_set hxa hP, fun x hxa hP => pl_post_set hxa hP⟩
      · obtain ⟨rfl, -⟩ := pure_ok hr
        exact ⟨_, rfl, fun x hx => Or.inr ⟨key x hx, Or.inl hnone⟩, fun x _ hP => hP,
          fun x _ hP => hP⟩
    | some pc =>
      obtain ⟨pad, catches⟩ := pc
      try dsimp only at hr
      rcases pl_ite_ok hr with ⟨-, hr⟩ | ⟨hm, hr⟩
      · pl_err hr
      rcases pl_ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
      · pl_err hr
      have key : ∀ x ∈ protos[a]!.sites, ∃ cs, callSites.find? (·.start == x.1) = some cs ∧
          cs.len = x.2 ∧ cs.pad = pad ∧ cs.catches = catches := by
        intro x hx
        rcases hin x hx with ⟨-, hmx⟩ | ⟨cs, hcs, hl, ha⟩
        · exact absurd hmx hm
        · simp only [Option.some.injEq, Prod.mk.injEq] at ha
          exact ⟨cs, hcs, hl, ha.1.symm, ha.2.symm⟩
      cases pad with
      | none =>
        try dsimp only at hr
        obtain ⟨_, _, h2, hr⟩ := bind_ok hr
        obtain ⟨rfl, rfl⟩ := pure_ok h2
        obtain ⟨rfl, -⟩ := pure_ok hr
        refine ⟨_, rfl, pl_post_self (by omega) (fun x hx => ?_),
          fun x hxa hP => pl_pre_set hxa hP, fun x hxa hP => pl_post_set hxa hP⟩
        obtain ⟨cs, hcs, hl, hp, hc⟩ := key x hx
        exact Or.inl ⟨cs, hcs, hl, none, by rw [hc], Or.inl ⟨hp, rfl⟩⟩
      | some bb =>
        try dsimp only at hr
        obtain ⟨j, c3, h3, hr⟩ := bind_ok hr
        rcases pl_ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
        · pl_err hr
        obtain ⟨_, _, h2, hr⟩ := bind_ok hr
        obtain ⟨rfl, rfl⟩ := pure_ok h2
        obtain ⟨rfl, -⟩ := pure_ok hr
        have hj := pl_indexAt h3
        refine ⟨_, rfl, pl_post_self (by omega) (fun x hx => ?_),
          fun x hxa hP => pl_pre_set hxa hP, fun x hxa hP => pl_post_set hxa hP⟩
        obtain ⟨cs, hcs, hl, hp, hc⟩ := key x hx
        exact Or.inl ⟨cs, hcs, hl, some j, by rw [hc], Or.inr ⟨bb, j, hp, rfl, hj⟩⟩
  rcases pl_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · pl_err h
  try dsimp only at h
  rcases pl_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · pl_err h
  try dsimp only at h
  rcases pl_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · pl_err h
  try dsimp only at h
  obtain ⟨he, -⟩ := pure_ok h
  subst he
  intro k hk
  exact key k (by simp [List.mem_range', Std.Legacy.Range.size] <;> omega)

/-- `read` runs `actionsOf` on its protos, giving its actions. -/
theorem pl_read_actions {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c')) :
    ∃ rs c0 c1, (actionsOf callSites r.protos rs).run c0 = .ok (r.actions, c1) := by
  unfold Vm.read at h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  obtain ⟨_, _, -, h⟩ := bind_ok h
  split at h <;> split at h <;>
  · obtain ⟨protos', _, -, h⟩ := bind_ok h
    obtain ⟨acts, _, hA, h⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h
    subst he
    exact ⟨_, _, _, hA⟩

/-- `cleanupAt` is the read's action (`reducedOf_cleanup`). -/
theorem pl_cleanupAt {c : R.Code} {A : Array (Option (Option Nat × Bool))}
    (hcl : c.d.cleanup = ((List.range A.size).filterMap (fun i =>
      A[i]!.map fun (pad, cat) => (i, pad, cat))).toArray) (k : Nat) :
    c.cleanupAt k = A[k]! := by
  unfold R.Code.cleanupAt
  rw [hcl]
  rcases h : A[k]! with _ | ⟨pad, cat⟩
  · rw [Option.map_eq_none_iff, Array.find?_eq_none]
    intro e he hk
    simp only [List.mem_toArray, List.mem_filterMap, List.mem_range] at he
    obtain ⟨i, -, hm⟩ := he
    obtain ⟨⟨y1, y2⟩, hy, rfl⟩ := Option.map_eq_some_iff.mp hm
    have hik : i = k := by simpa using hk
    subst hik
    rw [h] at hy
    cases hy
  · have hk : k < A.size := by
      refine Classical.byContradiction fun hk => ?_
      rw [getElem!_neg A k hk] at h
      cases h
    have hmem : (k, pad, cat) ∈ ((List.range A.size).filterMap (fun i =>
        A[i]!.map fun (pad, cat) => (i, pad, cat))).toArray := by
      simp only [List.mem_toArray, List.mem_filterMap, List.mem_range]
      exact ⟨k, hk, by rw [h]; rfl⟩
    obtain ⟨e, he⟩ := Option.isSome_iff_exists.mp
      ((Array.find?_isSome (p := fun e : Nat × Option Nat × Bool => e.1 == k)).mpr
        ⟨_, hmem, by simp⟩)
    rw [he]
    have hem := Array.mem_of_find?_eq_some he
    have hep := Array.find?_some he
    simp only [List.mem_toArray, List.mem_filterMap, List.mem_range] at hem
    obtain ⟨i, -, hm⟩ := hem
    obtain ⟨⟨y1, y2⟩, hy, rfl⟩ := Option.map_eq_some_iff.mp hm
    have hik : i = k := by simpa using hep
    subst hik
    rw [h] at hy
    cases hy
    rfl

section Discharge

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- `SitesLinked` from the decoder's acceptance, given distinct call-site starts, call sites
aligned with the calls, and code below `2 ^ 32` bytes. -/
theorem sitesLinked_of_decodes (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hdist : StartsDistinct callSites) (hal : SitesAligned S)
    (hsmall : S.body.code.size < 2 ^ 32) : SitesLinked S := by
  intro k hk site hs p h1 h2
  obtain ⟨c', hr⟩ := hD.read
  obtain ⟨rs, c0, c1, hA⟩ := pl_read_actions hr
  have hcl : S.c.cleanupAt k = S.r.actions[k]! := pl_cleanupAt (reducedOf_cleanup hD.reduced) k
  have hs' : site ∈ S.r.protos[k]!.sites := by rw [getElem!_pos S.r.protos k hk]; exact hs
  have hcsS : ∀ e, e ∈ callSites → e ∈ S.callSites := fun e he => by
    rw [hD.callSitesEq]; exact he
  unfold lsdaPad
  rw [hcl, hD.callSitesEq]
  rcases pl_actionsOf hA k hk site hs' with ⟨cs, hf, hlen, pad', hact, hpad⟩ | ⟨hf, hnone⟩
  · have hcs := Array.mem_of_find?_eq_some hf
    have hst : cs.start = site.1 := by simpa using Array.find?_some hf
    have hsite : siteAt callSites p = some cs := by
      unfold siteAt
      cases he : callSites.find? (fun s => decide (s.start < p) && decide (p ≤ s.start + s.len))
        with
      | none =>
        rw [Array.find?_eq_none] at he
        exact absurd (by simp only [Bool.and_eq_true, decide_eq_true_eq]; exact
          ⟨by omega, by omega⟩) (he cs hcs)
      | some e =>
        have hem := Array.mem_of_find?_eq_some he
        have hep := Array.find?_some he
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hep
        have := hal k hk site hs e (hcsS e hem) p h1 h2 hep.1 hep.2
        rw [hdist e hem cs hcs (by omega)]
    rw [hsite, hact]
    rcases hpad with ⟨hpn, rfl⟩ | ⟨b, j, hpb, rfl, hj⟩
    · show Option.map (BitVec.ofNat 64) cs.pad = none
      rw [hpn] <;> rfl
    · have hcl' : S.c.cleanupAt k = some (some j, cs.catches) := by rw [hcl, hact]
      obtain ⟨hjs, -⟩ := pad_lpad hD hcl'
      have hj' : posOf S.r j = b := hj
      have hb32 : b < 2 ^ 32 := hj' ▸ Nat.lt_of_le_of_lt (posOf_le_size hD hjs) hsmall
      have hm : b % 2 ^ 32 = b := Nat.mod_eq_of_lt hb32
      show Option.map (BitVec.ofNat 64) cs.pad = some ((pos32 S.r j).setWidth 64)
      rw [hpb]
      show some (BitVec.ofNat 64 b) = some ((pos32 S.r j).setWidth 64)
      congr 1
      apply BitVec.eq_of_toNat_eq
      rw [pos32, BitVec.toNat_setWidth, BitVec.toNat_ofNat, BitVec.toNat_ofNat, hj', hm]
  · have hsite : siteAt callSites p = none := by
      unfold siteAt
      cases he : callSites.find? (fun s => decide (s.start < p) && decide (p ≤ s.start + s.len))
        with
      | none => rfl
      | some e =>
        exfalso
        have hem := Array.mem_of_find?_eq_some he
        have hep := Array.find?_some he
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hep
        have := hal k hk site hs e (hcsS e hem) p h1 h2 hep.1 hep.2
        rw [Array.find?_eq_none] at hf
        exact hf e hem (by simp [this])
    rw [hsite]
    rcases hnone with h | h <;> rw [h] <;> rfl

/-- `PadsLinked` from the decoder and the unwinder assumption. -/
theorem padsLinked_of_decodes (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hU : UnwinderReadsLsda S) (hdist : StartsDistinct callSites) (hal : SitesAligned S)
    (hsmall : S.body.code.size < 2 ^ 32) : PadsLinked S :=
  padsLinked_of hU (sitesLinked_of_decodes hD hdist hal hsmall)

/-- `Hyps.padsLinked`'s replacement: `PadsLinked` from the decoder and the three `Hyps` fields
(`unwinderReadsLsda`, and `callSitesCheck`'s `StartsDistinct`/`SitesAligned`). -/
theorem Hyps.padsLinked (H : Hyps S) (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hsmall : S.body.code.size < 2 ^ 32) : PadsLinked S :=
  have hcs := callSites_of_check hD hD.callSitesOk
  padsLinked_of_decodes hD H.unwinderReadsLsda (by rw [← hD.callSitesEq]; exact hcs.1)
    hcs.2 hsmall

/-- PE-T5: `CleansLinked` from the decoder and `unwinderReadsLsda`'s cleanup conjunct, as
`Hyps.padsLinked` (`sitesLinked_of_decodes`' case split: the call site found for the return
address gives `k`'s action `(pad, catches)`). -/
theorem Hyps.cleansLinked (H : Hyps S)
    (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hsmall : S.body.code.size < 2 ^ 32) : CleansLinked S := by
  have hcs0 := callSites_of_check hD hD.callSitesOk
  have hdist : StartsDistinct callSites := by rw [← hD.callSitesEq]; exact hcs0.1
  have hal : SitesAligned S := hcs0.2
  intro k hk site hs p h1 h2
  rw [H.unwinderReadsLsda.2.1 p]
  obtain ⟨c', hr⟩ := hD.read
  obtain ⟨rs, c0, c1, hA⟩ := pl_read_actions hr
  have hcl : S.c.cleanupAt k = S.r.actions[k]! := pl_cleanupAt (reducedOf_cleanup hD.reduced) k
  have hs' : site ∈ S.r.protos[k]!.sites := by rw [getElem!_pos S.r.protos k hk]; exact hs
  have hcsS : ∀ e, e ∈ callSites → e ∈ S.callSites := fun e he => by
    rw [hD.callSitesEq]; exact he
  unfold lsdaCleans
  rw [hcl, hD.callSitesEq]
  rcases pl_actionsOf hA k hk site hs' with ⟨cs, hf, hlen, pad', hact, hpad⟩ | ⟨hf, hnone⟩
  · have hcs := Array.mem_of_find?_eq_some hf
    have hst : cs.start = site.1 := by simpa using Array.find?_some hf
    have hsite : siteAt callSites p = some cs := by
      unfold siteAt
      cases he : callSites.find? (fun s => decide (s.start < p) && decide (p ≤ s.start + s.len))
        with
      | none =>
        rw [Array.find?_eq_none] at he
        exact absurd (by simp only [Bool.and_eq_true, decide_eq_true_eq]; exact
          ⟨by omega, by omega⟩) (he cs hcs)
      | some e =>
        have hem := Array.mem_of_find?_eq_some he
        have hep := Array.find?_some he
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hep
        have := hal k hk site hs e (hcsS e hem) p h1 h2 hep.1 hep.2
        rw [hdist e hem cs hcs (by omega)]
    rw [hsite, hact]
    rcases hpad with ⟨hpn, rfl⟩ | ⟨b, j, hpb, rfl, hj⟩
    · show (cs.pad.isSome && !cs.catches) = false
      rw [hpn]; rfl
    · show (cs.pad.isSome && !cs.catches) = (match some (some j, cs.catches) with
        | some (some _, false) => true
        | _ => false)
      rw [hpb]
      cases cs.catches <;> rfl
  · have hsite : siteAt callSites p = none := by
      unfold siteAt
      cases he : callSites.find? (fun s => decide (s.start < p) && decide (p ≤ s.start + s.len))
        with
      | none => rfl
      | some e =>
        exfalso
        have hem := Array.mem_of_find?_eq_some he
        have hep := Array.find?_some he
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hep
        have := hal k hk site hs e (hcsS e hem) p h1 h2 hep.1 hep.2
        rw [Array.find?_eq_none] at hf
        exact hf e hem (by simp [this])
    rw [hsite]
    rcases hnone with h | h <;> rw [h] <;> rfl

end Discharge

end Ryo.Proofs.DecodeSound
