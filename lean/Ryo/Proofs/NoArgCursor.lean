/-
Ryo.Proofs.NoArgCursor — the `NoArg` cursor quirk (`DecodeLink.argInsn_none`) never matters for an
accepted call, kept inline sequence or other instruction: each reads an item where the quirk's
cursor has none (`decodeItem` fails there), so the cursor is the position's.
-/
import Ryo.Proofs.DecodeLink

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

theorem noArg_dec_item {c : Cursor} {q : Nat} {l : List Item} (hl : l ≠ [])
    (h : Dec c c.pos l q) : decodeItem c ≠ none := by
  cases h with
  | nil => exact absurd rfl hl
  | cons hi _ => intro hn; rw [hn] at hi; cases hi

/-- The  cursor is the position's, unless no item decodes there. -/
theorem noArg_cases {fr : Frame} {c : Cursor} {p : Nat} {a : Bool} {cur : Cursor}
    (hn : NoArg fr c p a cur) : cur = atPos c p ∨ decodeItem cur = none := by
  rcases hn with ⟨-, h⟩ | ⟨-, h⟩
  · exact .inl h
  · rcases argInsn_none h with h | ⟨_, _, _, _, h⟩
    · exact .inl h
    · exact .inr h

theorem noArg_of_item {fr : Frame} {c : Cursor} {p : Nat} {a : Bool} {cur : Cursor}
    (hn : NoArg fr c p a cur) (hi : decodeItem cur ≠ none) : cur = atPos c p :=
  (noArg_cases hn).resolve_right hi

set_option maxRecDepth 100000 in
/-- An exact inline read without a dropped store reads an item where it starts. -/
theorem noArg_inline_item {cache cache' : Cache} {dropped dr' : List DroppedStore} {c c' : Cursor}
    {q : Proto} (h : (inlineInsn cache dropped true).run c = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) : decodeItem c ≠ none := by
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
      st.2.2.1 = none ∧ (st.2.2.2.1 = false → Dec c c.pos st.2.1.toList cur.pos)
  let D : Option (Option (Proto × Cache × List DroppedStore)) × Array Item ×
      Option (Cond × Nat) × Bool × Nat × List DroppedStore × Bool → Cursor → Prop :=
    fun st cur => st.1 = some none ∨ (st.1 = none ∧ st.2.2.2.2.2.2 = true ∧
      (st.2.2.1 = none → st.2.1.toList ≠ []) ∧
      (st.2.2.2.1 = false → (st.2.2.1 = none ∧ Dec c c.pos st.2.1.toList cur.pos) ∨
        ∃ cond tgt long, st.2.2.1 = some (cond, tgt.toNat) ∧
          Dec c c.pos (st.2.1.toList ++ [.branch cond tgt long]) cur.pos))
  have key := forIn_range_inv I D _ ?step _ _ c c3 st ⟨rfl, rfl, rfl, rfl, fun _ => .nil _⟩ h3
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
      · -- a dropped store: `wasDropped` from here on
        obtain ⟨p2, c5, h5, hr⟩ := bind_ok hr
        obtain ⟨rfl, hc5⟩ := pos_run' h5
        subst c5
        obtain ⟨nx, c6, h6, hr⟩ := bind_ok hr
        have e6 := posOnly_run PosOnly.tryItem h6
        obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
        rw [run_setPos] at h7; cases h7
        split at hr
        · obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact ⟨rfl, rfl, by rw [e6], rfl, fun h => by cases h⟩
        · obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact .inr ⟨rfl, rfl, fun _ => (by simp), fun h => by cases h⟩
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
              refine .inr ⟨rfl, rfl, fun _ => (by simp), fun hw => .inl ⟨rfl, ?_⟩⟩
              simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              refine ⟨rfl, rfl, by rw [e7], rfl, fun hw => ?_⟩
              simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
          · split at hr
            · split at hr
              · obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact .inr ⟨rfl, rfl, fun h => (by cases h), fun hw => .inr ⟨_, _, _, rfl, (hd hw).append (Dec.single hn)⟩⟩
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
            refine .inr ⟨rfl, rfl, fun _ => (by simp), fun hw => .inl ⟨rfl, ?_⟩⟩
            simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
          · obtain ⟨rfl, rfl⟩ := pure_ok hr
            refine ⟨rfl, rfl, by rw [e7], rfl, fun hw => ?_⟩
            simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
        · split at hr
          · split at hr
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact .inr ⟨rfl, rfl, fun h => (by cases h), fun hw => .inr ⟨_, _, _, rfl, (hd hw).append (Dec.single hn)⟩⟩
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
  rcases key with ⟨rfl, rfl, -, -, -⟩ | rfl | ⟨rfl, rfl, hne, hd⟩
  · obtain ⟨u, c4, -, h4⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h4; cases he
  · obtain ⟨he, -⟩ := pure_ok h; cases he
  · simp only [Bool.not_true, Bool.false_eq_true, ↓reduceIte] at h
    -- the candidate the decoder accepted
    have found : ∃ cand d, decodeInline cand branch = some d ∧
        (cache.emit cand).1 = items.toList ∧ cache' = (cache.emit cand).2 ∧
        q.op = d.1 ∧ q.ops = d.2 ∧ q.pos = c.pos ∧ q.handler = none ∧ q.dropped = wd ∧
        q.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧ c' = c3 := by
      have fin : ∀ cand d (P : Proto) pp cc, decodeInline cand branch = some d →
          (if ((cache.emit cand).fst != items.toList) = true then none
            else some (P, (cache.emit cand).snd)) = some (pp, cc) →
          P.op = d.1 → P.ops = d.2 → P.pos = c.pos → P.handler = none → P.dropped = wd →
          P.items = (if wd = true then items.toList.eraseIdx da else items.toList) →
          (pp, cc, dr) = (q, cache', dr') → c' = c3 → ∃ cand d, decodeInline cand branch = some d ∧
            (cache.emit cand).1 = items.toList ∧ cache' = (cache.emit cand).2 ∧
            q.op = d.1 ∧ q.ops = d.2 ∧ q.pos = c.pos ∧ q.handler = none ∧ q.dropped = wd ∧
            q.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧ c' = c3 := by
        intro cand d P pp cc hd hh h1 h2 h3 h4 h5 h6 he hc
        split at hh
        · cases hh
        · rename_i hne
          simp only [Option.some.injEq, Prod.mk.injEq] at hh he
          obtain ⟨rfl, rfl⟩ := hh
          obtain ⟨rfl, rfl, rfl⟩ := he
          exact ⟨cand, d, hd, by simpa using hne, rfl, h1, h2, h3, h4, h5, h6, hc⟩
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
    obtain ⟨cand, d, hdi, hemit, hcache, hop, hops, hpos, hh, hdr, hits, rfl⟩ := found
    have hwd : wd = false := by rw [← hdr]; exact hq
    subst hwd
    intro hnone
    rcases hd rfl with ⟨hb, hd'⟩ | ⟨cond, tgt, long, hb, hd'⟩
    · cases e : items.toList with
      | nil => exact hne hb e
      | cons i is => rw [e] at hd'; cases hd' with | cons hi _ => exact absurd hnone (by rw [hi]; simp)
    · cases e : items.toList with
      | nil => rw [e] at hd'; cases hd' with | cons hi _ => exact absurd hnone (by rw [hi]; simp)
      | cons i is => rw [e] at hd'; cases hd' with | cons hi _ => exact absurd hnone (by rw [hi]; simp)

theorem noArg_call {fr : Frame} {c : Cursor} {p : Nat} {a : Bool} {cur c' : Cursor}
    {dr : List DroppedStore} {q : Proto} (hn : NoArg fr c p a cur)
    (h : (callInsn fr dr).run cur = .ok (some q, c')) : cur = atPos c p := by
  refine noArg_of_item hn ?_
  cases callInsn_read h with
  | call _ hd _ _ _ => exact noArg_dec_item (by simp) hd
  | tail _ hd _ _ => exact noArg_dec_item (by simp) hd

theorem noArg_inline {fr : Frame} {c : Cursor} {p : Nat} {a : Bool} {cur cur' c' : Cursor}
    {dr dr' : List DroppedStore} {cache cache' : Cache} {q : Proto}
    (hn : NoArg fr c p a cur) (hc : (callInsn fr dr).run cur = .ok (none, cur'))
    (h : (inlineInsn cache dr true).run cur' = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) : cur = atPos c p := by
  have e := callInsn_none hc; subst e
  exact noArg_of_item hn (noArg_inline_item h hq)

/-- A dense switch read starts with an item. -/
theorem denseSwitch_item {fr : Frame} {c c' : Cursor} {q : Proto}
    (h : (denseSwitch fr).run c = .ok (some q, c')) : decodeItem c ≠ none := by
  intro hn
  have hs : denseScan c = none := by
    unfold denseScan denseItems denseItems.go
    simp [hn]
  unfold denseSwitch at h
  simp [hs, StateT.run, bind, StateT.bind, get, getThe, MonadStateOf.get, StateT.get, pure, StateT.pure, Except.pure, Except.bind] at h
theorem noArg_insn {fr : Frame} {ro : ByteArray} {c : Cursor} {p : Nat} {a : Bool}
    {cur c' : Cursor} {q : Proto} (hn : NoArg fr c p a cur) (h : InsnRead fr ro cur q c') :
    cur = atPos c p := by
  refine noArg_of_item hn ?_
  cases h with
  | @handler items hat _ _ _ _ _ _ _ _ hd hi _ _ _ _ =>
    cases items with
    | nil => have := hd.nil_eq; subst this; intro hn'; rw [hn'] at hi; cases hi
    | cons _ _ => exact noArg_dec_item (by simp) hd
  | ret hr => exact noArg_dec_item (by simp) (retSeq_read hr).1
  | unreachable hi => intro hn'; rw [hn'] at hi; cases hi
  | jmp hi => intro hn'; rw [hn'] at hi; cases hi
  | island hi _ => exact noArg_dec_item (by simp [Island.islandPre]) (islandCall_read hi).1
  | dense h => exact denseSwitch_item h

end Ryo.Proofs.DecodeLink
