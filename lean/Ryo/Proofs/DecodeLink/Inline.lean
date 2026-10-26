/-
Ryo.Proofs.DecodeLink.Inline — inline sequences as `inlineInsn` reads them (aot.md §C2
"Register cache", toward M3 `decode_sound`), against `CacheStep.inline_step_cached`'s items.

- `inlineInsn_read`: an exact read (`exact = true`, the second pass) that accepted a sequence
  without a dropped store (`q.dropped = false`) found a candidate `cand` the decoder decodes to
  `q.op`, `q.ops` (`decodeInline_spec`: `(q.op, cls) ∈ inlineOps` and `sequence cls q.ops =
  some (cand, br)`), with `cache.emit cand = (q.items, cache')`: the items read, one after the
  other, are `cache.emit cand`'s, then, for a branch class, the `jcc` the loop stopped at.
- `link_inline`: in memory (`LinkOk`): `CodeAt` of `(cache.emit cand).1` (and the `jcc`).

**Not here.** A sequence with a dropped store (the store is in `cache.emit cand` but not in the
code: `q.items` is the output without it); that the `jcc`'s target is the `target` operand
`decodeInlineSearch` puts in `q.ops` (it takes the branch's, but through the search's loops).
-/
import Ryo.Proofs.DecodeLink.Links

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

theorem inlineInsn_read {cache cache' : Cache} {dropped dr' : List DroppedStore} {c c' : Cursor}
    {q : Proto} (h : (inlineInsn cache dropped true).run c = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) :
    q.pos = c.pos ∧ q.handler = none ∧ ∃ cand br, (∃ cls, (q.op, cls) ∈ inlineOps ∧
      sequence cls q.ops = some (cand, br.map (·.1))) ∧ cache.emit cand = (q.items, cache') ∧
      ((br = none ∧ Dec c c.pos q.items c'.pos) ∨ ∃ cond tgt long, br = some (cond, tgt.toNat) ∧
        Dec c c.pos (q.items ++ [.branch cond tgt long]) c'.pos) := by
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
          exact .inr ⟨rfl, rfl, fun h => by cases h⟩
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
              refine .inr ⟨rfl, rfl, fun hw => .inl ⟨rfl, ?_⟩⟩
              simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              refine ⟨rfl, rfl, by rw [e7], rfl, fun hw => ?_⟩
              simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
          · split at hr
            · split at hr
              · obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact .inr ⟨rfl, rfl, fun hw => .inr ⟨_, _, _, rfl, (hd hw).append (Dec.single hn)⟩⟩
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
            refine .inr ⟨rfl, rfl, fun hw => .inl ⟨rfl, ?_⟩⟩
            simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
          · obtain ⟨rfl, rfl⟩ := pure_ok hr
            refine ⟨rfl, rfl, by rw [e7], rfl, fun hw => ?_⟩
            simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
        · split at hr
          · split at hr
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact .inr ⟨rfl, rfl, fun hw => .inr ⟨_, _, _, rfl, (hd hw).append (Dec.single hn)⟩⟩
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
    simp only [Bool.false_eq_true, ↓reduceIte] at hits
    obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
    refine ⟨hpos, hh, cand, branch, ⟨cls, by rw [hop]; exact hmem, by rw [hops]; exact hseq⟩, ?_, ?_⟩
    · rw [hits, hcache, ← hemit]
    · rw [hits]
      rcases hd rfl with ⟨hb, hd'⟩ | ⟨cond, tgt, long, hb, hd'⟩
      · exact .inl ⟨hb, hd'⟩
      · exact .inr ⟨cond, tgt, long, hb, hd'⟩

/-- An inline sequence the decoder read at `c.pos` (no dropped store in it): the items
`(cache.emit cand).1` there (`CacheStep.inline_step_cached`'s), `cand` the `sequence` of the
instruction's class and operands, then for a branch class the `jcc tgt`, the branch target read
as `tgt.toNat`. -/
theorem link_inline {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {cache cache' : Cache}
    {dropped dr' : List DroppedStore} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (inlineInsn cache dropped true).run c = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) :
    q.pos = c.pos ∧ q.handler = none ∧ ∃ cand br cls, (q.op, cls) ∈ inlineOps ∧
      sequence cls q.ops = some (cand, br.map (·.1)) ∧ cache.emit cand = (q.items, cache') ∧
      ((br = none ∧ CodeAt ctx m (cache.emit cand).1 c.pos ∧
          c'.pos = c.pos + codeSize (cache.emit cand).1 ∧ Boundary rs c'.pos) ∨
        ∃ cond tgt long, br = some (cond, tgt.toNat) ∧
          CodeAt ctx m ((cache.emit cand).1 ++ [.branch cond tgt long]) c.pos ∧
          c'.pos = c.pos + codeSize ((cache.emit cand).1 ++ [.branch cond tgt long]) ∧
          Boundary rs c'.pos) := by
  obtain ⟨hpos, hh, cand, br, ⟨cls, hmem, hseq⟩, hemit, hd⟩ := inlineInsn_read h hq
  refine ⟨hpos, hh, cand, br, cls, hmem, hseq, hemit, ?_⟩
  rw [hemit]
  rcases hd with ⟨hbr, hd⟩ | ⟨cond, tgt, long, hbr, hd⟩
  · exact .inl ⟨hbr, hk.dec hd hb⟩
  · exact .inr ⟨cond, tgt, long, hbr, hk.dec hd hb⟩

end Ryo.Proofs.DecodeLink
