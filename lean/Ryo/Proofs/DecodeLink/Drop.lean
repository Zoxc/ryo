/-
Ryo.Proofs.DecodeLink.Drop — inline sequences with dropped stores, and the target of an inline
branch (aot.md §C2 "Register cache", "Dropped stores", toward M3 `decode_sound`).

**Dropped stores.** The encoder leaves out a store the lowering found dead (`DroppedStore`, at
the code position `at_` it would have had); `inlineInsn` puts the store's item `d.item` back into
the items it compares with `cache.emit cand`, without moving the cursor. `DecDrop c p dr out q
dr'` is that reading: from `p` to `q`, each item of `out` either decoded at the cursor or the
next dropped store of `dr`, at the cursor (`dr'` the stores left). `SkipAt p dr out kept dr'`:
`kept` is `out` without those stores, each dropped one at `p` plus the size of the kept items
before it: what runs, against what the step lemma for `out` (`CacheStep.inline_step_cached`)
runs, the gap being the dead stores' (a dead-store step lemma, not a decoder link).

- `inlineInsn_read_drop`: `inlineInsn_read` for any sequence: `DecDrop` of `cache.emit cand`'s
  output (and the `jcc`) from `c.pos` to `c'.pos`, `dropped` to `dr'`; `decodeInline cand br =
  some (q.op, q.ops)`.
- `codeAt_of_decDrop`: in memory (`LinkOk`), a `DecDrop` reading is `CodeAt` of its kept items,
  `SkipAt` placing the dropped ones.
- `link_inline_drop`: the two composed, the analogue of `link_inline` (which is its case without
  dropped stores, `SkipAt` then the identity: `skipAt_nil`).

**The branch target.** `decodeInlineSearch` sets every `target` operand to the branch's target
(`decodeInlineSearch_targets`), so every target of `q.ops` is the `jcc`'s (`inline_targets`); in R
the instruction's targets are indices `pos` maps back (`InsnOf`), so the target `t` of
`R.nativeCtl f ops` (`nativeCtl_target`: a `target` operand) has `pos t` the `jcc`'s target
(`inline_branch_index`), the `pos32 r t = tgt` the composition needs for `inline_step_cached`'s
`s'.pc = t`.
-/
import Ryo.Proofs.DecodeLink.Inline
import Ryo.Proofs.DecodeLink.Targets

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

/-! ### Dropped stores -/

/-- `inlineInsn`'s reading with dropped stores (see the module comment). -/
inductive DecDrop (c : Cursor) :
    Nat → List DroppedStore → List Item → Nat → List DroppedStore → Prop
  | nil (p : Nat) (dr : List DroppedStore) : DecDrop c p dr [] p dr
  | item {p n q : Nat} {dr dr' : List DroppedStore} {i : Item} {is : List Item} :
      decodeItem (atPos c p) = some (i, n) → DecDrop c (p + n) dr is q dr' →
      DecDrop c p dr (i :: is) q dr'
  | drop {p q : Nat} {d : DroppedStore} {dr dr' : List DroppedStore} {is : List Item} :
      d.at_ = p → DecDrop c p dr is q dr' → DecDrop c p (d :: dr) (d.item :: is) q dr'

/-- `kept` is `out` without the dropped stores `dr` consumes, each where its position says. -/
inductive SkipAt : Nat → List DroppedStore → List Item → List Item → List DroppedStore → Prop
  | nil (p : Nat) (dr : List DroppedStore) : SkipAt p dr [] [] dr
  | keep {p : Nat} {dr dr' : List DroppedStore} {i : Item} {is ks : List Item} :
      SkipAt (p + i.size) dr is ks dr' → SkipAt p dr (i :: is) (i :: ks) dr'
  | drop {p : Nat} {d : DroppedStore} {dr dr' : List DroppedStore} {is ks : List Item} :
      d.at_ = p → SkipAt p dr is ks dr' → SkipAt p (d :: dr) (d.item :: is) ks dr'

/-- Without dropped stores, nothing is skipped. -/
theorem skipAt_nil : ∀ (p : Nat) (dr : List DroppedStore) (items : List Item),
    SkipAt p dr items items dr
  | p, dr, [] => .nil p dr
  | _, dr, _ :: is => .keep (skipAt_nil _ dr is)

theorem Dec.decDrop {c : Cursor} {p q : Nat} {items : List Item} (h : Dec c p items q)
    (dr : List DroppedStore) : DecDrop c p dr items q dr := by
  induction h with
  | nil p => exact .nil p dr
  | cons hd _ ih => exact .item hd ih

/-- A `DecDrop` reading in memory: its kept items from `p`, the dropped ones placed by
`SkipAt`. -/
theorem codeAt_of_decDrop {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) :
    ∀ {p q : Nat} {dr dr' : List DroppedStore} {out : List Item}, DecDrop c p dr out q dr' →
      Boundary rs p → ∃ kept, SkipAt p dr out kept dr' ∧ CodeAt ctx m kept p ∧
        q = p + codeSize kept ∧ Boundary rs q
  | _, _, _, _, _, .nil p dr, hb => ⟨[], .nil p dr, trivial, by simp [codeSize], hb⟩
  | _, _, _, _, _, .item (p := p) (n := n) (i := i) hd hrest, hb => by
    obtain ⟨hi, hn, -, hb'⟩ := decodeItem_itemAt (c := atPos c p) hk.fields hk.sorted hk.loaded
      hk.small hk.fp hb hd
    obtain ⟨kept, hs, hc, hq, hb''⟩ := codeAt_of_decDrop hk hrest hb'
    refine ⟨i :: kept, .keep (by rw [hn]; exact hs), ⟨hi, by rw [hn]; exact hc⟩, ?_, hb''⟩
    rw [hq, codeSize_cons, hn, Nat.add_assoc]
  | _, _, _, _, _, .drop hat hrest, hb => by
    obtain ⟨kept, hs, hc, hq, hb'⟩ := codeAt_of_decDrop hk hrest hb
    exact ⟨kept, .drop hat hs, hc, hq, hb'⟩

/-- `DecDrop` extended by an item decoded at its end. -/
theorem DecDrop.snoc_item {c : Cursor} {p q n : Nat} {dr dr' : List DroppedStore}
    {xs : List Item} {i : Item} (h : DecDrop c p dr xs q dr')
    (hi : decodeItem (atPos c q) = some (i, n)) : DecDrop c p dr (xs ++ [i]) (q + n) dr' := by
  induction h with
  | nil p dr => exact .item hi (.nil _ _)
  | item hd _ ih => exact .item hd (ih hi)
  | drop hat _ ih => exact .drop hat (ih hi)

/-- `DecDrop` extended by the next dropped store, at its end. -/
theorem DecDrop.snoc_drop {c : Cursor} {p q : Nat} {dr dr' : List DroppedStore}
    {xs : List Item} {d : DroppedStore} (h : DecDrop c p dr xs q (d :: dr'))
    (hat : d.at_ = q) : DecDrop c p dr (xs ++ [d.item]) q dr' := by
  generalize he : d :: dr' = e at h
  induction h with
  | nil p dr => subst he; exact .drop hat (.nil _ _)
  | item hd _ ih => exact .item hd (ih hat he)
  | drop hat' _ ih => exact .drop hat' (ih hat he)

/-- What `inlineInsn` reads in its exact pass, dropped stores included (see the module
comment). -/
theorem inlineInsn_read_drop {cache cache' : Cache} {dropped dr' : List DroppedStore}
    {c c' : Cursor} {q : Proto}
    (h : (inlineInsn cache dropped true).run c = .ok (some (q, cache', dr'), c')) :
    q.pos = c.pos ∧ q.handler = none ∧ ∃ cand br out, decodeInline cand br = some (q.op, q.ops) ∧
      cache.emit cand = (out, cache') ∧
      ((br = none ∧ DecDrop c c.pos dropped out c'.pos dr') ∨ ∃ cond tgt long,
        br = some (cond, tgt.toNat) ∧
        DecDrop c c.pos dropped (out ++ [.branch cond tgt long]) c'.pos dr') := by
  unfold inlineInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨fu, c2, h2, h⟩ := bind_ok h
  have := fuel_run h2; subst c2
  obtain ⟨st, c3, h3, h⟩ := bind_ok h
  let I : Option (Option (Proto × Cache × List DroppedStore)) × Array Item ×
      Option (Cond × Nat) × Bool × Nat × List DroppedStore × Bool → Cursor → Prop :=
    fun st cur => st.1 = none ∧ st.2.2.2.2.2.2 = false ∧ cur = atPos c cur.pos ∧
      st.2.2.1 = none ∧ DecDrop c c.pos dropped st.2.1.toList cur.pos st.2.2.2.2.2.1
  let D : Option (Option (Proto × Cache × List DroppedStore)) × Array Item ×
      Option (Cond × Nat) × Bool × Nat × List DroppedStore × Bool → Cursor → Prop :=
    fun st cur => st.1 = some none ∨ (st.1 = none ∧ st.2.2.2.2.2.2 = true ∧
      ((st.2.2.1 = none ∧ DecDrop c c.pos dropped st.2.1.toList cur.pos st.2.2.2.2.2.1) ∨
        ∃ cond tgt long, st.2.2.1 = some (cond, tgt.toNat) ∧
          DecDrop c c.pos dropped (st.2.1.toList ++ [.branch cond tgt long]) cur.pos
            st.2.2.2.2.2.1))
  have key := forIn_range_inv I D _ ?step _ _ c c3 st ⟨rfl, rfl, rfl, rfl, DecDrop.nil _ _⟩ h3
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨o, items, branch, wd, da, dr, ended⟩ := b
    obtain ⟨ho, hend, hc, hbr, hd⟩ := hI
    simp only at ho hend hc hbr hd hr
    subst ho hend hbr
    obtain ⟨pc, rfl⟩ : ∃ p, cur = atPos c p := ⟨_, hc⟩
    split at hr
    · rename_i d hdr
      obtain ⟨p1, c4, h4, hr⟩ := bind_ok hr
      obtain ⟨rfl, hc4⟩ := pos_run' h4
      subst c4
      split at hr
      · rename_i hat
        obtain ⟨tl, rfl⟩ : ∃ tl, dr = d :: tl := by
          cases dr with
          | nil => cases hdr
          | cons d' tl => exact ⟨tl, by simp only [List.head?_cons, Option.some.injEq] at hdr; rw [hdr]⟩
        have hd' := hd.snoc_drop (by simpa using hat)
        -- a dropped store: `wasDropped` from here on
        obtain ⟨p2, c5, h5, hr⟩ := bind_ok hr
        obtain ⟨rfl, hc5⟩ := pos_run' h5
        subst c5
        obtain ⟨nx, c6, h6, hr⟩ := bind_ok hr
        have e6 := posOnly_run PosOnly.tryItem h6
        obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
        rw [run_setPos] at h7; cases h7
        split at hr
        · obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact ⟨rfl, rfl, by rw [e6], rfl, by simpa using hd'⟩
        · obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact .inr ⟨rfl, rfl, .inl ⟨rfl, by simpa using hd'⟩⟩
      · obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
        cases x with
        | none =>
          have := run_tryItem_none h5; subst this
          obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
          rw [run_setPos] at h7; cases h7
          obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact .inl rfl
        | some it =>
          obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
          dsimp only at hr
          split at hr
          · obtain ⟨p2, c6, h6, hr⟩ := bind_ok hr
            obtain ⟨rfl, hc6⟩ := pos_run' h6
            subst c6
            obtain ⟨nx, c7, h7, hr⟩ := bind_ok hr
            have e7 := posOnly_run PosOnly.tryItem h7
            obtain ⟨u, c8, h8, hr⟩ := bind_ok hr
            rw [run_setPos] at h8; cases h8
            split at hr
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              refine .inr ⟨rfl, rfl, .inl ⟨rfl, ?_⟩⟩
              simp only [Array.toList_push]; exact hd.snoc_item hn
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              refine ⟨rfl, rfl, by rw [e7], rfl, ?_⟩
              simp only [Array.toList_push]; exact hd.snoc_item hn
          · split at hr
            · split at hr
              · obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact .inr ⟨rfl, rfl, .inr ⟨_, _, _, rfl, hd.snoc_item hn⟩⟩
              · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
                rw [run_setPos] at h7; cases h7
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact .inl rfl
            · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
              rw [run_setPos] at h7; cases h7
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact .inl rfl
    · obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
      cases x with
      | none =>
        have := run_tryItem_none h5; subst this
        obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
        rw [run_setPos] at h7; cases h7
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        exact .inl rfl
      | some it =>
        obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
        dsimp only at hr
        split at hr
        · obtain ⟨p2, c6, h6, hr⟩ := bind_ok hr
          obtain ⟨rfl, hc6⟩ := pos_run' h6
          subst c6
          obtain ⟨nx, c7, h7, hr⟩ := bind_ok hr
          have e7 := posOnly_run PosOnly.tryItem h7
          obtain ⟨u, c8, h8, hr⟩ := bind_ok hr
          rw [run_setPos] at h8; cases h8
          split at hr
          · obtain ⟨rfl, rfl⟩ := pure_ok hr
            refine .inr ⟨rfl, rfl, .inl ⟨rfl, ?_⟩⟩
            simp only [Array.toList_push]; exact hd.snoc_item hn
          · obtain ⟨rfl, rfl⟩ := pure_ok hr
            refine ⟨rfl, rfl, by rw [e7], rfl, ?_⟩
            simp only [Array.toList_push]; exact hd.snoc_item hn
        · split at hr
          · split at hr
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact .inr ⟨rfl, rfl, .inr ⟨_, _, _, rfl, hd.snoc_item hn⟩⟩
            · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
              rw [run_setPos] at h7; cases h7
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact .inl rfl
          · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
            rw [run_setPos] at h7; cases h7
            obtain ⟨rfl, rfl⟩ := pure_ok hr
            exact .inl rfl
  obtain ⟨o, items, branch, wd, da, dr, ended⟩ := st
  dsimp only at key h
  rcases key with ⟨rfl, rfl, -, -, -⟩ | rfl | ⟨rfl, rfl, hd⟩
  · obtain ⟨u, c4, -, h4⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h4; cases he
  · obtain ⟨he, -⟩ := pure_ok h; cases he
  · simp only [Bool.not_true, Bool.false_eq_true, ↓reduceIte] at h
    -- the candidate the decoder accepted
    have found : ∃ cand d, decodeInline cand branch = some d ∧
        (cache.emit cand).1 = items.toList ∧ cache' = (cache.emit cand).2 ∧
        q.op = d.1 ∧ q.ops = d.2 ∧ q.pos = c.pos ∧ q.handler = none ∧ q.dropped = wd ∧
        q.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧ c' = c3 ∧ dr = dr' := by
      have fin : ∀ cand d (P : Proto) pp cc, decodeInline cand branch = some d →
          (if ((cache.emit cand).fst != items.toList) = true then none
            else some (P, (cache.emit cand).snd)) = some (pp, cc) →
          P.op = d.1 → P.ops = d.2 → P.pos = c.pos → P.handler = none → P.dropped = wd →
          P.items = (if wd = true then items.toList.eraseIdx da else items.toList) →
          (pp, cc, dr) = (q, cache', dr') → c' = c3 → ∃ cand d, decodeInline cand branch = some d ∧
            (cache.emit cand).1 = items.toList ∧ cache' = (cache.emit cand).2 ∧
            q.op = d.1 ∧ q.ops = d.2 ∧ q.pos = c.pos ∧ q.handler = none ∧ q.dropped = wd ∧
            q.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧ c' = c3 ∧ dr = dr' := by
        intro cand d P pp cc hd hh h1 h2 h3 h4 h5 h6 he hc
        split at hh
        · cases hh
        · rename_i hne
          simp only [Option.some.injEq, Prod.mk.injEq] at hh he
          obtain ⟨rfl, rfl⟩ := hh
          obtain ⟨rfl, rfl, rfl⟩ := he
          exact ⟨cand, d, hd, by simpa using hne, rfl, h1, h2, h3, h4, h5, h6, hc, rfl⟩
      split at h
      · rename_i d hdi
        split at h
        · rename_i pp cc hacc
          obtain ⟨he, rfl⟩ := pure_ok h
          exact fin _ d _ pp cc hdi hacc rfl rfl rfl rfl rfl rfl (by cases he; rfl) rfl
        · obtain ⟨res, c4, h4, hk2⟩ := bind_ok h
          have key2 := forIn_list_inv (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => st.1 = none ∧ cur = c3)
            (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => cur = c3 ∧
                ∃ (cand : List Item) (d : Full.Opcode × List (Opnd Nat)) (P pp : Proto) (cc : Cache), decodeInline cand branch = some d ∧
              (if ((cache.emit cand).fst != items.toList) = true then none
                else some (P, (cache.emit cand).snd)) = some (pp, cc) ∧
              P.op = d.1 ∧ P.ops = d.2 ∧ P.pos = c.pos ∧ P.handler = none ∧ P.dropped = wd ∧
              P.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧
              st.1 = some (some (pp, cc, dr))) _ ?step2 _ _ c3 c4 res ⟨rfl, rfl⟩ h4
          case step2 =>
            intro cand st cur r cur' hI hr
            split at hr
            · rename_i d hd
              split at hr
              · rename_i pp cc hacc
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact ⟨hI.2, cand, d, _, pp, cc, hd, hacc, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
              · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
            · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
          rcases key2 with ⟨hn, rfl⟩ | ⟨rfl, cand, d, P, pp, cc, hd, hacc, h1, h2, h3, h4', h5, h6, hs⟩
          · split at hk2
            · rename_i r hr; rw [hn] at hr; cases hr
            · obtain ⟨u, c5, -, hk3⟩ := bind_ok hk2
              obtain ⟨he, -⟩ := pure_ok hk3; cases he
          · split at hk2
            · rename_i r hr; rw [hs] at hr; cases hr
              obtain ⟨he, rfl⟩ := pure_ok hk2
              exact fin cand d P pp cc hd hacc h1 h2 h3 h4' h5 h6 (by cases he; rfl) rfl
            · rename_i hr; rw [hs] at hr; cases hr
      · obtain ⟨res, c4, h4, hk2⟩ := bind_ok h
        have key2 := forIn_list_inv (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => st.1 = none ∧ cur = c3)
          (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => cur = c3 ∧
                ∃ (cand : List Item) (d : Full.Opcode × List (Opnd Nat)) (P pp : Proto) (cc : Cache), decodeInline cand branch = some d ∧
            (if ((cache.emit cand).fst != items.toList) = true then none
              else some (P, (cache.emit cand).snd)) = some (pp, cc) ∧
            P.op = d.1 ∧ P.ops = d.2 ∧ P.pos = c.pos ∧ P.handler = none ∧ P.dropped = wd ∧
            P.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧
            st.1 = some (some (pp, cc, dr))) _ ?step2 _ _ c3 c4 res ⟨rfl, rfl⟩ h4
        case step2 =>
          intro cand st cur r cur' hI hr
          split at hr
          · rename_i d hd
            split at hr
            · rename_i pp cc hacc
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact ⟨hI.2, cand, d, _, pp, cc, hd, hacc, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
            · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
          · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
        rcases key2 with ⟨hn, rfl⟩ | ⟨rfl, cand, d, P, pp, cc, hd, hacc, h1, h2, h3, h4', h5, h6, hs⟩
        · split at hk2
          · rename_i r hr; rw [hn] at hr; cases hr
          · obtain ⟨u, c5, -, hk3⟩ := bind_ok hk2
            obtain ⟨he, -⟩ := pure_ok hk3; cases he
        · split at hk2
          · rename_i r hr; rw [hs] at hr; cases hr
            obtain ⟨he, rfl⟩ := pure_ok hk2
            exact fin cand d P pp cc hd hacc h1 h2 h3 h4' h5 h6 (by cases he; rfl) rfl
          · rename_i hr; rw [hs] at hr; cases hr
    obtain ⟨cand, d, hdi, hemit, hcache, hop, hops, hpos, hh, hdr, hits, rfl, rfl⟩ := found
    refine ⟨hpos, hh, cand, branch, items.toList, by rw [hop, hops]; exact hdi,
      by rw [hcache, ← hemit], hd⟩

/-- An inline sequence in memory, dropped stores included: the kept items of
`(cache.emit cand).1` (and the `jcc`), `SkipAt` placing the dropped ones. -/
theorem link_inline_drop {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc}
    {cache cache' : Cache} {dropped dr' : List DroppedStore} {q : Proto}
    (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (inlineInsn cache dropped true).run c = .ok (some (q, cache', dr'), c')) :
    q.pos = c.pos ∧ q.handler = none ∧ ∃ cand br cls out, decodeInline cand br = some (q.op, q.ops) ∧
      (q.op, cls) ∈ inlineOps ∧ sequence cls q.ops = some (cand, br.map (·.1)) ∧
      cache.emit cand = (out, cache') ∧
      ((br = none ∧ ∃ kept, SkipAt c.pos dropped out kept dr' ∧ CodeAt ctx m kept c.pos ∧
          c'.pos = c.pos + codeSize kept ∧ Boundary rs c'.pos) ∨
        ∃ cond tgt long, br = some (cond, tgt.toNat) ∧ ∃ kept,
          SkipAt c.pos dropped (out ++ [.branch cond tgt long]) kept dr' ∧
          CodeAt ctx m kept c.pos ∧ c'.pos = c.pos + codeSize kept ∧ Boundary rs c'.pos) := by
  obtain ⟨hpos, hh, cand, br, out, hdi, hemit, hd⟩ := inlineInsn_read_drop h
  obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
  refine ⟨hpos, hh, cand, br, cls, out, hdi, hmem, hseq, hemit, ?_⟩
  rcases hd with ⟨hbr, hd⟩ | ⟨cond, tgt, long, hbr, hd⟩
  · exact .inl ⟨hbr, codeAt_of_decDrop hk hd hb⟩
  · exact .inr ⟨cond, tgt, long, hbr, codeAt_of_decDrop hk hd hb⟩

/-! ### The branch target -/

/-- An invariant of a `for` loop in `Option`. -/
theorem opt_forIn_inv {α β : Type} (P : β → Prop) (f : α → β → Option (ForInStep β))
    (hf : ∀ a b r, P b → f a b = some r → P r.value) :
    ∀ (l : List α) (init : β) (r : β), P init → forIn l init f = some r → P r
  | [], init, r, h0, h => by simp only [List.forIn_nil] at h; cases h; exact h0
  | a :: l, init, r, h0, h => by
    simp only [List.forIn_cons] at h
    cases hfa : f a init with
    | none => simp [hfa, bind, Option.bind] at h
    | some s =>
      have hs := hf a init s h0 hfa
      cases s with
      | done b => simp only [hfa, bind, Option.bind] at h; cases h; exact hs
      | yield b => simp only [hfa, bind, Option.bind] at h; exact opt_forIn_inv P f hf l b r hs h

/-- A `do` bind in `Option`, as elaborated: its value and the rest. -/
theorem mbind {α β : Type} {o : Option α} {f : α → Option β} {r : β}
    (h : (match o, f with | none, _ => none | some a, f => f a) = some r) :
    ∃ a, o = some a ∧ f a = some r := by
  cases o with
  | none => cases h
  | some a => exact ⟨a, rfl, h⟩

set_option maxRecDepth 100000 in
/-- `decodeInlineSearch` sets each `target` operand to the branch's target. -/
theorem decodeInlineSearch_targets {items : List Item} {branch : Option (Cond × Nat)}
    {op : Full.Opcode} {ops : List (Opnd Nat)} {cls : Class}
    (h : decodeInlineSearch items branch = some (op, ops, cls)) :
    ∀ o ∈ ops, ∀ t ∈ o.targetsOf, some t = branch.map (·.2) := by
  let G : List (Opnd Nat) → Prop := fun l => ∀ o ∈ l, ∀ t ∈ o.targetsOf, some t = branch.map (·.2)
  have gpush : ∀ (a : Array (Opnd Nat)) o, G a.toList → (∀ t ∈ o.targetsOf, some t = branch.map (·.2)) →
      G (a.push o).toList := by
    intro a o ha ho o' hm
    simp only [Array.toList_push, List.mem_append, List.mem_singleton] at hm
    rcases hm with hm | rfl
    · exact ha _ hm
    · exact ho
  have gset : ∀ (a : Array (Opnd Nat)) i b, G a.toList → G (a.set! i (.neg b)).toList := by
    intro a i b ha o hm
    simp only [Array.set!, Array.toList_setIfInBounds] at hm
    rcases List.mem_or_eq_of_mem_set hm with hm | rfl
    · exact ha _ hm
    · simp [Opnd.targetsOf]
  unfold decodeInlineSearch at h
  simp only [bind, Option.bind] at h
  obtain ⟨key, -, h⟩ := mbind h
  obtain ⟨res, hres, h⟩ := mbind h
  have hout := opt_forIn_inv (fun (s : Option (Full.Opcode × List (Opnd Nat) × Class) × Unit) =>
    ∀ r, s.1 = some r → G r.2.1) _ ?_ _ _ _ (by simp) hres
  · skip
    split at h
    · rename_i r hr; cases h; exact hout _ hr
    · cases h
  intro x s r hs hr
  split at hr
  · cases hr; simp
  obtain ⟨a, ha, hr⟩ := mbind hr
  have hin := opt_forIn_inv (fun (s : List (BitVec 32) × Array (Opnd Nat)) => G s.2.toList) _ ?_ _ _ _
    (by simp [G]) ha
  · obtain ⟨b, hb, hr⟩ := mbind hr
    have hneg := opt_forIn_inv (fun (s : Option (Full.Opcode × List (Opnd Nat) × Class) × Array (Opnd Nat)) =>
      G s.2.toList ∧ ∀ r, s.1 = some r → G r.2.1) _ ?_ _ _ _ ⟨hin, by simp⟩ hb
    · rcases b with ⟨_ | r', arr⟩
      · simp only [pure, Option.some.injEq] at hr; subst hr; simp
      · simp only [pure, Option.some.injEq] at hr; subst hr; simpa using hneg.2 r' rfl
    intro neg s r hs hr
    split at hr
    · split at hr
      · split at hr
        · cases hr; exact ⟨gset _ _ _ hs.1, fun r h => by cases h; exact gset _ _ _ hs.1⟩
        · cases hr; exact ⟨gset _ _ _ hs.1, by simp⟩
      · cases hr; exact ⟨gset _ _ _ hs.1, by simp⟩
    · split at hr
      · cases hr; exact ⟨hs.1, by simp⟩
      · split at hr
        · split at hr
          · cases hr; exact ⟨hs.1, fun r h => by cases h; exact hs.1⟩
          · cases hr; exact ⟨hs.1, by simp⟩
        · cases hr; exact ⟨hs.1, by simp⟩
  intro o s r hs hr
  split at hr
  all_goals (repeat' (first | split at hr | (simp only [pure] at hr)))
  all_goals first
    | (cases hr; exact gpush _ _ hs (by simp [Opnd.targetsOf]))
    | (cases hr; refine gpush _ _ hs ?_; intro t ht; simp only [Opnd.targetsOf, List.mem_singleton] at ht; subst ht; rename_i heq; rw [heq]; rfl)
    | cases hr

theorem decodeInline_targets {items : List Item} {branch : Option (Cond × Nat)}
    {op : Full.Opcode} {ops : List (Opnd Nat)} (h : decodeInline items branch = some (op, ops)) :
    ∀ o ∈ ops, ∀ t ∈ o.targetsOf, some t = branch.map (·.2) := by
  unfold decodeInline at h
  cases hs : decodeInlineSearch items branch with
  | none => simp [hs] at h
  | some r =>
    obtain ⟨op', ops', cls⟩ := r
    simp only [hs, bind, Option.bind_some] at h
    split at h
    · simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact decodeInlineSearch_targets hs
    · cases h

/-- An inline branch's operands (`hdi` from `inlineInsn_read`/`inlineInsn_read_drop` with
`br = some (cond, tgt.toNat)`): every target is the `jcc`'s. -/
theorem inline_targets {q : Proto} {cand : List Item} {cond : Cond} {b : Nat}
    (hdi : decodeInline cand (some (cond, b)) = some (q.op, q.ops)) :
    ∀ o ∈ q.ops, ∀ t ∈ o.targetsOf, t = b := by
  intro o ho t ht
  have := decodeInline_targets hdi o ho t ht
  simpa using this

/-- The target of a native branch is one of its `target` operands. -/
theorem nativeCtl_target {f : Full.Opcode} {ops : List (Opnd Nat)} {neg : Bool} {t : Nat}
    (h : R.nativeCtl f ops = some (.branch neg t)) : Opnd.target t ∈ ops := by
  unfold R.nativeCtl at h
  simp only [bind, pure] at h
  split at h
  all_goals first
    | (simp only [Option.some.injEq, reduceCtorEq] at h; done)
    | (split at h <;> simp only [Option.some.injEq, reduceCtorEq] at h; done)
    | skip
  split at h
  · rename_i heq
    simp only [Option.some.injEq, Then.branch.injEq] at h
    obtain ⟨-, rfl⟩ := h
    simp only [Prod.mk.injEq] at heq
    obtain ⟨x, hx, hx2⟩ := Option.map_eq_some_iff.mp heq.2
    have hmem := List.mem_of_find?_eq_some hx
    rw [← hx2]
    exact (List.of_mem_zip hmem).2
  · simp at h

/-- In R: the branch target of the inline instruction read at `q` (its operands `ops` with
targets as indices, `ops.map (opndMap pos) = q.ops`) is an index `pos` maps to the `jcc`'s
target. -/
theorem inline_branch_index {q : Proto} {b : Nat} (hq : ∀ o ∈ q.ops, ∀ t ∈ o.targetsOf, t = b)
    {pos : Nat → Nat} {f : Full.Opcode} {ops : List (Opnd Nat)}
    (hops : ops.map (opndMap pos) = q.ops) {neg : Bool} {t : Nat}
    (h : R.nativeCtl f ops = some (.branch neg t)) : pos t = b := by
  have hm := nativeCtl_target h
  have : opndMap pos (.target t) ∈ q.ops := hops ▸ List.mem_map_of_mem hm
  exact hq _ this (pos t) (by simp [opndMap, Opnd.targetsOf])

end Ryo.Proofs.DecodeLink
