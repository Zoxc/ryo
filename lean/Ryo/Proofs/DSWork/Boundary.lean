import Ryo.Proofs.DecodeSound
import Ryo.Proofs.NoArgCursor

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

/-! The decoder facts `DecodeSound` states with `sorry` (its boundary lemma `boundary_start`
is proved there, from `Decodes.prologue`). -/

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

theorem PadRead.le_size' {c : Cursor} {p q : Nat} (h : PadRead c p q) (hp : p ≤ c.code.size) :
    q ≤ c.code.size := by
  induction h with
  | nil => exact hp
  | @nop p q n _ _ hby _ _ ih =>
    apply ih
    by_cases h2 : p + n ≤ c.code.size
    · exact h2
    · simp [Cursor.bytes, h2] at hby

set_option maxHeartbeats 1000000 in
/-- Every proto `instructions` reads lies within the code. -/
theorem instructions_pos_le {fr : Vm.Frame} {ro : ByteArray} {dropped : List DroppedStore}
    {targets : Option (Array Nat)} {entryStub : Option Nat} {limit : Nat}
    {callSites : Array CallSite} {c c' : Cursor} {protos : Array Proto} {padded : Array Bool}
    (h : (instructions fr ro dropped targets entryStub limit callSites).run c =
      .ok ((protos, padded), c')) (hlim : limit ≤ c.code.size) :
    ∀ x ∈ protos.toList, x.pos ≤ c.code.size := by
  have lrGet : PosOnly (get : DM Cursor) := by
    intro c b c' h; obtain ⟨-, rfl⟩ := get_run h; rfl
  have lrPure : ∀ {α : Type} (a : α), PosOnly (Pure.pure a : DM α) := by
    intro α a c b c' h
    simp only [StateT.run, Pure.pure, StateT.pure, Except.pure] at h; cases h; rfl
  have lrExpect : ∀ l, PosOnly (DM.expectItems l) := by
    intro l
    induction l with
    | nil => exact PosOnly.pure _
    | cons w l ih =>
      unfold DM.expectItems
      exact PosOnly.bind PosOnly.tryItem fun _ => PosOnly.ite (PosOnly.pure _) ih
  have lrTake : ∀ f, PosOnly (DM.take f) := fun f c b c' h => (take_dec h).2.1
  have po_call : ∀ fr d, PosOnly (callInsn fr d) := by
    intro fr d; unfold callInsn params resultSeq; repeat (first | exact PosOnly.pure _ | exact lrPure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _ | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _ | exact lrGet | exact lrExpect _ | exact lrTake _ | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_) | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_) | refine PosOnly.bind ?_ (fun _ => ?_) | split | (dsimp only))
  have po_inline : ∀ a d e, PosOnly (inlineInsn a d e) := by
    intro a d e; unfold inlineInsn; repeat (first | exact PosOnly.pure _ | exact lrPure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _ | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _ | exact lrGet | exact lrExpect _ | exact lrTake _ | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_) | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_) | refine PosOnly.bind ?_ (fun _ => ?_) | split | (dsimp only))
  have po_arg : ∀ m, PosOnly (argInsn m) := by
    intro m; unfold argInsn; repeat (first | exact PosOnly.pure _ | exact lrPure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _ | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _ | exact lrGet | exact lrExpect _ | exact lrTake _ | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_) | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_) | refine PosOnly.bind ?_ (fun _ => ?_) | split | (dsimp only))
  have po_retSeq : ∀ fr, PosOnly (retSeq fr) := by
    intro fr; unfold retSeq; repeat (first | exact PosOnly.pure _ | exact lrPure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _ | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _ | exact lrGet | exact lrExpect _ | exact lrTake _ | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_) | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_) | refine PosOnly.bind ?_ (fun _ => ?_) | split | (dsimp only))
  have po_dense : ∀ fr, PosOnly (denseSwitch fr) := by
    intro fr c b c' h
    unfold denseSwitch at h
    obtain ⟨x, c1, h1, h2⟩ := bind_ok h
    obtain ⟨rfl, rfl⟩ := get_run h1
    split at h2
    · obtain ⟨u, c2, h3, h⟩ := bind_ok h2
      rw [run_setPos] at h3; cases h3
      obtain ⟨ts, c3, h4, h⟩ := bind_ok h
      obtain ⟨_, _, _, -, -, -, e⟩ := table_read h4
      split at h
      · obtain ⟨-, rfl⟩ := pure_ok h; rw [e]
      · exact (err_ok h).elim
    · obtain ⟨-, rfl⟩ := pure_ok h2; rfl
  have po_island : ∀ fr, PosOnly (islandCall fr) := by
    intro fr c b c' h; exact (islandCall_read h).2
  have po_hargs : ∀ s fr p, PosOnly (handlerArgs s fr p) := by
    intro s fr p c b c' h; obtain ⟨-, rfl⟩ := handlerArgs_ok h; rfl
  have po_table : ∀ n, PosOnly (table n) := by
    intro n; unfold table DM.tablePadding DM.tableEntry; repeat (first | exact PosOnly.pure _ | exact lrPure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _ | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _ | exact lrGet | exact lrExpect _ | exact lrTake _ | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_) | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_) | refine PosOnly.bind ?_ (fun _ => ?_) | split | (dsimp only))
  have po_then : ∀ op n h, PosOnly (thenSeq op n h) := by
    intro op n h
    unfold thenSeq
    set_option maxRecDepth 100000 in repeat (first | exact PosOnly.pure _ | exact lrPure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _ | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _ | exact lrGet | exact lrExpect _ | exact lrTake _ | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_) | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_) | refine PosOnly.bind ?_ (fun _ => ?_) | split | (dsimp only))
    all_goals exact po_table _
  have insn_pos : ∀ {c c' : Cursor} {q : Proto}, (insn fr ro).run c = .ok (q, c') → c' = atPos c c'.pos := by
    intro c c' q h
    cases insn_read h with
    | handler _ _ _ _ _ ht => exact (po_then _ _ _ _ _ _ ht).trans rfl
    | ret h => exact po_retSeq _ _ _ _ h
    | unreachable _ => rfl
    | jmp _ => rfl
    | island h _ => exact po_island _ _ _ _ h
    | resume _ _ _ => rfl
    | dense h => exact po_dense _ _ _ _ h
  have ite_ok : ∀ {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α},
      (if p then x else y).run c = .ok (a, c') →
        (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
    intro α p _ x y c c' a h
    by_cases hp : p
    · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
    · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩
  unfold instructions at h
  obtain ⟨fu, c1, h1, h⟩ := bind_ok h
  rw [fuel_run h1] at h
  let EP : Array Proto → Option Nat → Prop := fun protos endPos =>
    endPos = entryStub ∨ ∃ k, ∃ hk : k < protos.size, (protos[k].counter.map (·.1)) = endPos ∧
      ∀ j (hj : j < k), protos[j].counter = none
  let I0 : Array Proto × Array Bool × Cache × Option Nat × List DroppedStore → Cursor → Prop :=
    fun st cur => cur = atPos c cur.pos ∧ st.2.1.size = st.1.size ∧ EP st.1 st.2.2.2.1 ∧
      ∀ qs pe dre, Iters fr ro targets callSites c (st.1.all (·.op == .arg)) cur.pos st.2.2.1 st.2.2.2.2 qs pe dre →
        Iters fr ro targets callSites c true c.pos { pe := fr.mode.pe } dropped (st.1.toList ++ qs) pe dre
  let I : Array Proto × Array Bool × Cache × Option Nat × List DroppedStore → Cursor → Prop :=
    fun st cur => I0 st cur ∧ ∀ x ∈ st.1.toList, x.pos ≤ c.code.size
  obtain ⟨st, c2, h2, h⟩ := bind_ok h
  have key := forIn_range_inv I I _ ?step _ _ c c2 st ?init h2
  case init => exact ⟨⟨rfl, rfl, .inl rfl, fun qs pe dre h => by simpa using h⟩, by simp⟩
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨protos, padded, cache, endPos, dr⟩ := b
    obtain ⟨⟨hcur, hsz, hep, hJ⟩, hB⟩ := hI
    dsimp only at hsz hep hJ
    have chain : ∀ {x y : Cursor} {p : Nat}, x = atPos c p → y = atPos x y.pos → y = atPos c y.pos := by
      intro x y p hx hy; subst hx; exact hy
    have padc : ∀ {x p q : Nat}, PadRead (atPos c x) p q → PadRead c p q := by
      intro x p q hp
      induction hp with
      | nil p => exact .nil p
      | nop h1 h2 h3 h4 _ ih => exact .nop h1 h2 h3 h4 ih
    have epPush : ∀ x, EP (protos.push x) endPos := by
      intro x
      rcases hep with h | ⟨k, hk, h1, h2⟩
      · exact .inl h
      · refine .inr ⟨k, by simp; omega, ?_, fun j hj => ?_⟩
        · rw [Array.getElem_push_lt hk]; exact h1
        · rw [Array.getElem_push_lt (by omega)]; exact h2 j hj
    have fin0 : ∀ (p1 p2 : Nat) (counter : Option (Nat × Nat)) (b : Bool) (q : Proto) (c' : Cursor)
        (cache0 cache' : Cache) (dr' : List DroppedStore) (endPos' : Option Nat),
        PadRead c cur.pos p1 → CounterRead fr c p1 counter p2 →
        cache0 = (if targets.any (sortedContains · p1) then { pe := fr.mode.pe } else cache) →
        ProtoRead fr ro targets.isSome c p2 cache0 dr (protos.all (·.op == .arg)) q c' cache' dr' →
        c' = atPos c c'.pos →
        (endPos' = endPos ∨ ∃ t p3, counter = some (t, p3) ∧ protos.all (·.counter.isNone) = true ∧
          endPos' = some t) →
        ∀ (c'' : Cursor), (nopStep fr.mode callSites q).run c' = .ok ((), c'') →
        I0 (protos.push { q with pos := p1, counter }, padded.push b, cache', endPos', dr') c'' := by
      intro p1 p2 counter b q c' cache0 cache' dr' endPos' hpad hctr hc0 hpr hc' hE c'' hn
      obtain ⟨hnr, hc''⟩ := nopStep_read hn hc'
      subst hc0
      refine ⟨hc'', by simp [hsz], ?_, fun qs pe dre hq => ?_⟩
      · rcases hE with rfl | ⟨t, p3, rfl, hall, rfl⟩
        · exact epPush _
        · refine .inr ⟨protos.size, by simp, by simp, fun j hj => ?_⟩
          rw [Array.getElem_push_lt hj]
          have := (Array.all_eq_true.mp hall) j hj
          simpa using this
      · have it : Iter fr ro targets callSites c (protos.all (·.op == .arg)) cur.pos cache dr
            { q with pos := p1, counter } c''.pos cache' dr' := .main hpad hctr hpr hnr
        have := hJ _ _ _ (.cons it (by simpa [Array.all_push] using hq))
        simpa using this
    have finE0 : ∀ (d : DroppedStore) (dr0 : List DroppedStore) (q : Proto) (c' : Cursor)
        (cache' : Cache) (dr' : List DroppedStore),
        dr = d :: dr0 → d.at_ = cur.pos →
        (inlineInsn cache dr targets.isSome).run (atPos c cur.pos) = .ok (some (q, cache', dr'), c') →
        c' = atPos c c'.pos →
        I0 (protos.push { q with pos := cur.pos }, padded.push false, cache', endPos, dr') c' := by
      intro d dr0 q c' cache' dr' hd hat hrun hc'
      subst hd
      refine ⟨hc', by simp [hsz], epPush _, fun qs pe dre hq => ?_⟩
      have it : Iter fr ro targets callSites c (protos.all (·.op == .arg)) cur.pos cache (d :: dr0)
          { q with pos := cur.pos } c'.pos cache' dr' := .empty hat hrun
      have := hJ _ _ _ (.cons it (by simpa [Array.all_push] using hq))
      simpa using this
    obtain ⟨e, c3, h3, hr⟩ := bind_ok hr
    obtain ⟨rfl, rfl⟩ := pos_run' h3
    obtain ⟨p0, c4, h4, hr⟩ := bind_ok hr
    obtain ⟨rfl, rfl⟩ := pos_run' h4
    rcases ite_ok hr with ⟨-, hr⟩ | ⟨hnot, hr⟩
    · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨⟨hcur, hsz, hep, hJ⟩, hB⟩
    have hlt : c4.pos < c.code.size := by
      rcases Nat.lt_or_ge c4.pos limit with h | hge
      · omega
      · exact absurd (by rw [Bool.or_eq_true]; exact Or.inl (decide_eq_true hge)) hnot
    have fin : ∀ (p1 p2 : Nat) (counter : Option (Nat × Nat)) (b : Bool) (q : Proto) (c' : Cursor)
        (cache0 cache' : Cache) (dr' : List DroppedStore) (endPos' : Option Nat),
        PadRead c c4.pos p1 → CounterRead fr c p1 counter p2 →
        cache0 = (if targets.any (sortedContains · p1) then { pe := fr.mode.pe } else cache) →
        ProtoRead fr ro targets.isSome c p2 cache0 dr (protos.all (·.op == .arg)) q c' cache' dr' →
        c' = atPos c c'.pos →
        (endPos' = endPos ∨ ∃ t p3, counter = some (t, p3) ∧ protos.all (·.counter.isNone) = true ∧
          endPos' = some t) →
        ∀ (c'' : Cursor), (nopStep fr.mode callSites q).run c' = .ok ((), c'') →
        I (protos.push { q with pos := p1, counter }, padded.push b, cache', endPos', dr') c'' := by
      intro p1 p2 counter b q c' cache0 cache' dr' endPos' hpad hctr hc0 hpr hc' hE c'' hn
      refine ⟨fin0 p1 p2 counter b q c' cache0 cache' dr' endPos' hpad hctr hc0 hpr hc' hE c'' hn, ?_⟩
      have hle := PadRead.le_size' hpad (Nat.le_of_lt hlt)
      intro x hx
      simp only [Array.toList_push, List.mem_append, List.mem_singleton] at hx
      rcases hx with hx | rfl
      · exact hB x hx
      · exact hle
    have finE : ∀ (d : DroppedStore) (dr0 : List DroppedStore) (q : Proto) (c' : Cursor)
        (cache' : Cache) (dr' : List DroppedStore),
        dr = d :: dr0 → d.at_ = c4.pos →
        (inlineInsn cache dr targets.isSome).run (atPos c c4.pos) = .ok (some (q, cache', dr'), c') →
        c' = atPos c c'.pos →
        I (protos.push { q with pos := c4.pos }, padded.push false, cache', endPos, dr') c' := by
      intro d dr0 q c' cache' dr' hd hat hrun hc'
      refine ⟨finE0 d dr0 q c' cache' dr' hd hat hrun hc', ?_⟩
      intro x hx
      simp only [Array.toList_push, List.mem_append, List.mem_singleton] at hx
      rcases hx with hx | rfl
      · exact hB x hx
      · exact Nat.le_of_lt hlt
    obtain ⟨p0, c5, h5, hr⟩ := bind_ok hr
    obtain ⟨rfl, rfl⟩ := pos_run' h5
    rcases ite_ok hr with ⟨hdr, hr⟩ | ⟨hdr, hr⟩
    · obtain ⟨p0, c5, h5, hr⟩ := bind_ok hr
      obtain ⟨rfl, rfl⟩ := pos_run' h5
      obtain ⟨o, c6, h6, hr⟩ := bind_ok hr
      rcases o with _ | ⟨q, cache', dr'⟩
      · rw [inlineInsn_none h6] at hr
        obtain ⟨pad, c7, h7, hr⟩ := bind_ok hr
        obtain ⟨hpr, -, hc7⟩ := padding_read h7
        rw [hcur] at hpr
        replace hpr := padc hpr
        replace hc7 := chain hcur hc7
        obtain ⟨p, c8, h8, hr⟩ := bind_ok hr
        obtain ⟨hp, hc8⟩ := pos_run' h8
        rw [hc8] at hr
        rw [← hp] at hpr
        have hc7p : c7 = atPos c p := by rw [hp]; exact hc7
        rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
        · obtain ⟨_, _, h9, -⟩ := bind_ok hr; exact (err_ok h9).elim
        rcases ite_ok hr with ⟨hT, hr⟩ | ⟨hT, hr⟩
        all_goals
          rcases ite_ok hr with ⟨hC, hr⟩ | ⟨hC, hr⟩
          · obtain ⟨i1, c9, h9, hr⟩ := bind_ok hr
            obtain ⟨i2, c10, h10, hr⟩ := bind_ok hr
            have e9 := chain hc7p (posOnly_run PosOnly.tryItem h9)
            have e10 := chain e9 (posOnly_run PosOnly.tryItem h10)
            split at hr
            · rw [hc7p] at h9
              obtain ⟨n1, hn1, rfl⟩ := run_tryItem_some h9
              obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h10
              have hctr := CounterRead.check (by simp only [Bool.and_eq_true] at hC; exact hC.1) (Dec.cons hn1 (Dec.single hn2))
              obtain ⟨p', c11, h11, hr⟩ := bind_ok hr
              obtain ⟨rfl, rfl⟩ := pos_run' h11
              have hcx : atPos (atPos (atPos c p) (p + n1)) (p + n1 + n2) = atPos c (p + n1 + n2) := rfl
              rcases ite_ok hr with ⟨hA0, hr⟩ | ⟨-, hr⟩
              all_goals
                rcases ite_ok hr with ⟨hA, hr⟩ | ⟨hA, hr⟩
                · obtain ⟨o, c12, h12, hr⟩ := bind_ok hr
                  have h12' := h12
                  rw [hcx] at h12'
                  rcases o with _ | q
                  · have hna := (Or.inr ⟨hA, h12'⟩ : NoArg fr c _ _ _)
                    have hcy := chain hcx (po_arg _ _ _ _ h12)
                    obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                    obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
                    rcases o with _ | q
                    · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                      obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                      obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                      rcases o with _ | ⟨q, cache', dr'⟩
                      · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                        obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                        try dsimp only at hr
                        obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                        obtain ⟨rfl, rfl⟩ := pure_ok hr
                        exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                      · try dsimp only at hr
                        obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                        obtain ⟨rfl, rfl⟩ := pure_ok hr
                        exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                    · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                      try dsimp only at hr
                      obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                      obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                  · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                    obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                    try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                · have hna := (Or.inl ⟨Bool.eq_false_iff.mpr hA, hcx⟩ : NoArg fr c _ _ _)
                  have hcy := hcx
                  obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
                  rcases o with _ | q
                  · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                    obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                    obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                    rcases o with _ | ⟨q, cache', dr'⟩
                    · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                      obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                      try dsimp only at hr
                      obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                      obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                    · try dsimp only at hr
                      obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                      obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                  · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                    try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
            · obtain ⟨u, c11, h11, hr⟩ := bind_ok hr
              rw [run_setPos] at h11
              cases h11
              have hctr := CounterRead.none (fr := fr) (c := c) p
              have hcx : atPos c10 p = atPos c p := by rw [e10]
              rcases ite_ok hr with ⟨hA, hr⟩ | ⟨hA, hr⟩
              · obtain ⟨o, c12, h12, hr⟩ := bind_ok hr
                have h12' := h12
                rw [hcx] at h12'
                rcases o with _ | q
                · have hna := (Or.inr ⟨hA, h12'⟩ : NoArg fr c _ _ _)
                  have hcy := chain hcx (po_arg _ _ _ _ h12)
                  obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
                  rcases o with _ | q
                  · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                    obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                    obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                    rcases o with _ | ⟨q, cache', dr'⟩
                    · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                      obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                      try dsimp only at hr
                      obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                      obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                    · try dsimp only at hr
                      obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                      obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                  · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                    try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
              · have hna := (Or.inl ⟨Bool.eq_false_iff.mpr hA, hcx⟩ : NoArg fr c _ _ _)
                have hcy := hcx
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
                rcases o with _ | q
                · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                  obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                  rcases o with _ | ⟨q, cache', dr'⟩
                  · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                    obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                    try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                  · try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
          · have hctr := CounterRead.none (fr := fr) (c := c) p
            have hcx := hc7p
            rcases ite_ok hr with ⟨hA, hr⟩ | ⟨hA, hr⟩
            · obtain ⟨o, c12, h12, hr⟩ := bind_ok hr
              have h12' := h12
              rw [hcx] at h12'
              rcases o with _ | q
              · have hna := (Or.inr ⟨hA, h12'⟩ : NoArg fr c _ _ _)
                have hcy := chain hcx (po_arg _ _ _ _ h12)
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
                rcases o with _ | q
                · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                  obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                  rcases o with _ | ⟨q, cache', dr'⟩
                  · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                    obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                    try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                  · try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
            · have hna := (Or.inl ⟨Bool.eq_false_iff.mpr hA, hcx⟩ : NoArg fr c _ _ _)
              have hcy := hcx
              obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
              rcases o with _ | q
              · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                rcases o with _ | ⟨q, cache', dr'⟩
                · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                  obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                  try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                · try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
      · obtain ⟨rfl, rfl⟩ := pure_ok hr
        have h6' := h6
        rw [hcur] at h6'
        cases dr with
        | nil => simp at hdr
        | cons d dr0 =>
          exact finE d dr0 _ _ _ _ rfl (by simpa using hdr) h6' (chain hcur (po_inline _ _ _ _ _ _ h6))
    obtain ⟨pad, c7, h7, hr⟩ := bind_ok hr
    obtain ⟨hpr, -, hc7⟩ := padding_read h7
    rw [hcur] at hpr
    replace hpr := padc hpr
    replace hc7 := chain hcur hc7
    obtain ⟨p, c8, h8, hr⟩ := bind_ok hr
    obtain ⟨hp, hc8⟩ := pos_run' h8
    rw [hc8] at hr
    rw [← hp] at hpr
    have hc7p : c7 = atPos c p := by rw [hp]; exact hc7
    rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
    · obtain ⟨_, _, h9, -⟩ := bind_ok hr; exact (err_ok h9).elim
    rcases ite_ok hr with ⟨hT, hr⟩ | ⟨hT, hr⟩
    all_goals
      rcases ite_ok hr with ⟨hC, hr⟩ | ⟨hC, hr⟩
      · obtain ⟨i1, c9, h9, hr⟩ := bind_ok hr
        obtain ⟨i2, c10, h10, hr⟩ := bind_ok hr
        have e9 := chain hc7p (posOnly_run PosOnly.tryItem h9)
        have e10 := chain e9 (posOnly_run PosOnly.tryItem h10)
        split at hr
        · rw [hc7p] at h9
          obtain ⟨n1, hn1, rfl⟩ := run_tryItem_some h9
          obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h10
          have hctr := CounterRead.check (by simp only [Bool.and_eq_true] at hC; exact hC.1) (Dec.cons hn1 (Dec.single hn2))
          obtain ⟨p', c11, h11, hr⟩ := bind_ok hr
          obtain ⟨rfl, rfl⟩ := pos_run' h11
          have hcx : atPos (atPos (atPos c p) (p + n1)) (p + n1 + n2) = atPos c (p + n1 + n2) := rfl
          rcases ite_ok hr with ⟨hA0, hr⟩ | ⟨-, hr⟩
          all_goals
            rcases ite_ok hr with ⟨hA, hr⟩ | ⟨hA, hr⟩
            · obtain ⟨o, c12, h12, hr⟩ := bind_ok hr
              have h12' := h12
              rw [hcx] at h12'
              rcases o with _ | q
              · have hna := (Or.inr ⟨hA, h12'⟩ : NoArg fr c _ _ _)
                have hcy := chain hcx (po_arg _ _ _ _ h12)
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
                rcases o with _ | q
                · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                  obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                  rcases o with _ | ⟨q, cache', dr'⟩
                  · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                    obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                    try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                  · try dsimp only at hr
                    obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
            · have hna := (Or.inl ⟨Bool.eq_false_iff.mpr hA, hcx⟩ : NoArg fr c _ _ _)
              have hcy := hcx
              obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
              rcases o with _ | q
              · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                rcases o with _ | ⟨q, cache', dr'⟩
                · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                  obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                  try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                · try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
        · obtain ⟨u, c11, h11, hr⟩ := bind_ok hr
          rw [run_setPos] at h11
          cases h11
          have hctr := CounterRead.none (fr := fr) (c := c) p
          have hcx : atPos c10 p = atPos c p := by rw [e10]
          rcases ite_ok hr with ⟨hA, hr⟩ | ⟨hA, hr⟩
          · obtain ⟨o, c12, h12, hr⟩ := bind_ok hr
            have h12' := h12
            rw [hcx] at h12'
            rcases o with _ | q
            · have hna := (Or.inr ⟨hA, h12'⟩ : NoArg fr c _ _ _)
              have hcy := chain hcx (po_arg _ _ _ _ h12)
              obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
              rcases o with _ | q
              · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
                rcases o with _ | ⟨q, cache', dr'⟩
                · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                  obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                  try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
                · try dsimp only at hr
                  obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
            · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
              try dsimp only at hr
              obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
          · have hna := (Or.inl ⟨Bool.eq_false_iff.mpr hA, hcx⟩ : NoArg fr c _ _ _)
            have hcy := hcx
            obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
            obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
            rcases o with _ | q
            · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
              obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
              rcases o with _ | ⟨q, cache', dr'⟩
              · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
              · try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
            · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
              try dsimp only at hr
              obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
      · have hctr := CounterRead.none (fr := fr) (c := c) p
        have hcx := hc7p
        rcases ite_ok hr with ⟨hA, hr⟩ | ⟨hA, hr⟩
        · obtain ⟨o, c12, h12, hr⟩ := bind_ok hr
          have h12' := h12
          rw [hcx] at h12'
          rcases o with _ | q
          · have hna := (Or.inr ⟨hA, h12'⟩ : NoArg fr c _ _ _)
            have hcy := chain hcx (po_arg _ _ _ _ h12)
            obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
            obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
            rcases o with _ | q
            · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
              obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
              rcases o with _ | ⟨q, cache', dr'⟩
              · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
                obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
                try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
              · try dsimp only at hr
                obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
            · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
              try dsimp only at hr
              obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
          · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
            obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
            try dsimp only at hr
            obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
            obtain ⟨rfl, rfl⟩ := pure_ok hr
            exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
        · have hna := (Or.inl ⟨Bool.eq_false_iff.mpr hA, hcx⟩ : NoArg fr c _ _ _)
          have hcy := hcx
          obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
          obtain ⟨o, c13, h13, hr⟩ := bind_ok hr
          rcases o with _ | q
          · have hcy13 : _ = atPos c _ := (callInsn_none h13).trans hcy
            obtain ⟨-, hr⟩ := (ite_ok hr).resolve_right (fun ⟨hn, _⟩ => by simp at hn)
            obtain ⟨o, c14, h14, hr⟩ := bind_ok hr
            rcases o with _ | ⟨q, cache', dr'⟩
            · have hcy14 : _ = atPos c _ := (inlineInsn_none h14).trans hcy13
              obtain ⟨q, c15, h15, hr⟩ := bind_ok hr
              try dsimp only at hr
              obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
            · try dsimp only at hr
              obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
          · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
            try dsimp only at hr
            obtain ⟨u16, c16, h16, hr⟩ := bind_ok hr
            obtain ⟨rfl, rfl⟩ := pure_ok hr
            exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩) _ h16
  have hI : I st c2 := key.elim id id
  obtain ⟨-, hB⟩ := hI
  obtain ⟨e, c3, h3, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pos_run' h3
  obtain ⟨p0, c4, h4, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pos_run' h4
  rcases ite_ok h with ⟨-, h⟩ | ⟨hfin, h⟩
  · obtain ⟨_, _, -, h⟩ := bind_ok h
    obtain ⟨_, _, h6, -⟩ := bind_ok h
    exact (err_ok h6).elim
  obtain ⟨protos', padded', cache', endPos', dr'⟩ := st
  cases dr' with
  | cons d dr0 =>
    obtain ⟨_, _, h6, -⟩ := bind_ok h
    exact (err_ok h6).elim
  | nil =>
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    exact hB

/-- `readFrame` reads the prologue item by item (the entry's counter check, then the frame's
`prologue` from where the check ends). -/
theorem readFrame_dec {mode : Mode} {c c' : Cursor} {entry : Option (Nat × Nat)} {fs : Nat}
    (h : (readFrame mode).run c = .ok ((entry, fs), c')) : ∃ items, Dec c c.pos items c'.pos := by
  have ite_ok : ∀ {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α},
      (if p then x else y).run c = .ok (a, c') →
        (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
    intro α p _ x y c c' a h
    by_cases hp : p
    · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
    · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩
  unfold readFrame at h
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h1, -⟩ := bind_ok h; exact (err_ok h1).elim
  obtain ⟨entry, c1, h1, h⟩ := bind_ok h
  have e1 : c1 = atPos c c1.pos := posOnly_run (by posonly) h1
  have d1 : ∃ items, Dec c c.pos items c1.pos := by
    rcases ite_ok h1 with ⟨-, h1⟩ | ⟨-, h1⟩
    · obtain ⟨i1, ca, ha, h1⟩ := bind_ok h1
      obtain ⟨i2, cb, hb', h1⟩ := bind_ok h1
      split at h1
      · obtain ⟨n1, hn1, rfl⟩ := run_tryItem_some ha
        obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some hb'
        obtain ⟨_, _, h5, h1⟩ := bind_ok h1
        obtain ⟨rfl, rfl⟩ := pos_run' h5
        obtain ⟨-, rfl⟩ := pure_ok h1
        exact ⟨_, Dec.cons hn1 (Dec.single hn2)⟩
      · exact (err_ok h1).elim
    · obtain ⟨-, rfl⟩ := pure_ok h1
      exact ⟨[], .nil _⟩
  obtain ⟨start, c2, h2, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pos_run' h2
  obtain ⟨fu, c3, h3, h⟩ := bind_ok h
  rw [fuel_run h3] at h
  obtain ⟨alloc, c3, h3, h⟩ := bind_ok h
  have e3 : c3 = atPos c c3.pos := by
    refine (posOnly_run ?_ h3).trans (by rw [e1])
    refine PosOnly.forIn_range _ _ _ (fun _ _ => PosOnly.bind PosOnly.tryItem (fun o => ?_))
    rcases o with _ | i
    · exact PosOnly.pure _
    · cases i <;> first | exact PosOnly.pure _ | (rename_i x; cases x <;> exact PosOnly.pure _) | (rename_i x y; cases x <;> exact PosOnly.pure _) | (rename_i x y; cases x <;> cases y <;> exact PosOnly.pure _)
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h4, -⟩ := bind_ok h; exact (err_ok h4).elim
  obtain ⟨u, c4, h4, h⟩ := bind_ok h
  rw [run_setPos] at h4
  cases h4
  obtain ⟨u, c4, h4, h⟩ := bind_ok h
  have d4 : ∃ items, Dec c c2.pos items c4.pos := by
    have key := forIn_list_inv (fun _ cur => cur = atPos c cur.pos ∧ ∃ items, Dec c c2.pos items cur.pos)
      (fun _ _ => False) _ ?_ _ _ (atPos c3 c2.pos) _ _ ⟨by rw [e3], [], .nil _⟩ h4
    · rcases key with k | k
      · exact k.2
      · exact k.elim
    · intro a b cur r cur' hI hr
      obtain ⟨hc, items, hd⟩ := hI
      obtain ⟨at_, ca, ha, hr⟩ := bind_ok hr
      obtain ⟨rfl, rfl⟩ := pos_run' ha
      obtain ⟨o, cb, hb', hr⟩ := bind_ok hr
      rcases ite_ok hr with ⟨-, hr⟩ | ⟨hne, hr⟩
      · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
      · obtain ⟨rfl, rfl⟩ := pure_ok hr
        have ho : o = some a := by simpa using hne
        subst ho
        obtain ⟨n, hn, rfl⟩ := run_tryItem_some hb'
        have hn' : decodeItem (atPos c ca.pos) = some (a, n) := by rw [← hc]; exact hn
        exact ⟨by rw [hc], items ++ [a], Dec.append hd (Dec.single hn')⟩
  obtain ⟨i1, d1'⟩ := d1
  obtain ⟨i2, d4'⟩ := d4
  have d := Dec.append d1' d4'
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨u, c5, h5, h⟩ := bind_ok h
    simp only [StateT.run, modify, modifyGet, MonadStateOf.modifyGet, StateT.modifyGet, pure,
      Except.pure] at h5
    cases h5
    obtain ⟨-, rfl⟩ := pure_ok h
    exact ⟨_, d⟩
  · obtain ⟨-, rfl⟩ := pure_ok h
    exact ⟨_, d⟩

theorem read_instructions_prologue' {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hnr : regionPad mode callSites = none) :
    ∃ (c0 c1 : Cursor) (targets : Array Nat) (stub : Option Nat) (padded : Array Bool),
      c0 = bodyCursor c mode r.frameSize c0.pos ∧
      (instructions ⟨r.frameSize, mode, false⟩ ro dropped (some targets) stub c.code.size
        callSites).run c0 = .ok ((r.protos, padded), c1) ∧
      (mode.framePointer = true → ∃ items, Dec c0 c.pos items c0.pos) := by
  unfold Vm.read at h
  obtain ⟨⟨entry, fs⟩, c1, h1, h⟩ := bind_ok h
  have hc1 := readFrame_body h1
  obtain ⟨items, hd⟩ := readFrame_dec h1
  dsimp only at h
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨hx, hc2⟩ := get_run h2
  rw [hx, hc2] at h
  obtain ⟨ra, c3, h3, h⟩ := bind_ok h
  have hra : ra = none ∧ c3 = c1 := by
    unfold regionEntry at h3; rw [hnr] at h3
    exact ⟨(pure_ok h3).1.symm, (pure_ok h3).2.symm⟩
  rw [hra.1, hra.2] at h
  have hsize : c1.code.size = c.code.size := by rw [hc1]; rfl
  dsimp only at h
  obtain ⟨body, c4, h4, h⟩ := bind_ok h
  obtain ⟨hb4, hc4⟩ := pos_run' h4
  subst hb4
  rw [hc4] at h
  obtain ⟨⟨p1, pd1, be1⟩, c5, h5, h⟩ := bind_ok h
  have e5 := readParts_pos h5
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
  refine ⟨_, c7, _, _, padded, hb, by rw [tp, tf]; exact hc7, fun hfp => ⟨items, ?_⟩⟩
  show Dec (atPos c5 c1.pos) c.pos items c1.pos
  have hx : atPos c5 c1.pos = atPos c c1.pos := by rw [hb]; simp [bodyCursor, hfp]
  rw [hx, Dec.at_iff]
  exact hd

/-- `actionsOf`'s landing pads are `lpad`s (its `protos[j]!.op != .lpad` check). -/
theorem actionsOf_lpad {callSites : Array CallSite} {protos : Array Proto} {rs : Nat}
    {c c' : Cursor} {acts : Array (Option (Option Nat × Bool))}
    (h : (actionsOf callSites protos rs).run c = .ok (acts, c')) :
    ∀ y ∈ acts, ∀ pad cat, y = some (some pad, cat) → protos[pad]!.op = .lpad := by
  have ite_ok : ∀ {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α},
      (if p then x else y).run c = .ok (a, c') →
        (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
    intro α p _ x y c c' a h
    by_cases hp : p
    · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
    · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩
  unfold actionsOf at h
  obtain ⟨st, cA, hA, h⟩ := bind_ok h
  have key := forIn_range_inv
    (fun (b : _ × Nat) (_ : Cursor) =>
      ∀ y ∈ b.1, ∀ pad cat, y = some (some pad, cat) → protos[pad]!.op = .lpad)
    (fun b _ => ∀ y ∈ b.1, ∀ pad cat, y = some (some pad, cat) → protos[pad]!.op = .lpad)
    _ ?_ _ _ _ _ _ ?_ hA
  rotate_left
  · intro i b cur r cur' hI hr
    obtain ⟨st, c1, h1, hr⟩ := bind_ok hr
    try dsimp only at hr
    split at hr
    · rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
      · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
      rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
      · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
      split at hr
      · obtain ⟨_, _, h2, hr⟩ := bind_ok hr
        obtain ⟨rfl, rfl⟩ := pure_ok h2
        obtain ⟨rfl, -⟩ := pure_ok hr
        intro y hy pad' cat' e
        rcases Array.mem_or_eq_of_mem_setIfInBounds hy with hy | hy
        · exact hI y hy pad' cat' e
        · subst hy; cases e
      · obtain ⟨j, c3, h3, hr⟩ := bind_ok hr
        rcases ite_ok hr with ⟨-, hr⟩ | ⟨hne, hr⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
        obtain ⟨_, _, h2, hr⟩ := bind_ok hr
        obtain ⟨rfl, rfl⟩ := pure_ok h2
        obtain ⟨rfl, -⟩ := pure_ok hr
        intro y hy pad' cat' e
        rcases Array.mem_or_eq_of_mem_setIfInBounds hy with hy | hy
        · exact hI y hy pad' cat' e
        · subst hy; cases e; simpa using hne
    · rcases ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
      · obtain ⟨rfl, -⟩ := pure_ok hr
        intro y hy pad' cat' e
        rcases Array.mem_or_eq_of_mem_setIfInBounds hy with hy | hy
        · exact hI y hy pad' cat' e
        · subst hy; cases e
      · obtain ⟨rfl, -⟩ := pure_ok hr; exact hI
  · intro y hy pad cat e; subst e; simp [Array.mem_replicate] at hy
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
  obtain ⟨he, -⟩ := pure_ok h
  subst he
  exact key.elim id id

/-- `read`'s landing pads are `lpad`s (`actionsOf_lpad`). -/
theorem read_tail_facts {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c')) :
      ∀ y ∈ r.actions, ∀ pad cat, y = some (some pad, cat) → r.protos[pad]!.op = .lpad := by
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
    exact actionsOf_lpad hA

theorem reducedOf_cleanup {r : ReadResult} {pe : Bool} {d : Decoded} (h : reducedOf r pe = .ok d) :
    d.cleanup = ((List.range r.actions.size).filterMap (fun i =>
      r.actions[i]!.map fun (pad, c) => (i, pad, c))).toArray := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  rfl

/-- Proof idea: `hD.read` and `decodeReduced_read`'s `reducedOf`: `Code.cleanupAt` is
`r.actions`' entry, set by `read`'s call-site loop only after its `protos[j]!.op != .lpad`
check (unroll `read` past `instructions` as `read_instructions` does). -/
theorem pad_lpad' (hD : Decodes S code relocs rodata callSites dropped scopes mode) {k pad : Nat}
    {cat : Bool} (h : S.c.cleanupAt k = some (some pad, cat)) :
    ∃ hp : pad < S.r.protos.size, S.r.protos[pad].op = .lpad := by
  obtain ⟨c', hr⟩ := hD.read
  have hA := read_tail_facts hr
  have hcl := reducedOf_cleanup hD.reduced
  unfold R.Code.cleanupAt at h
  rw [hcl] at h
  obtain ⟨e, hfind, he2⟩ := Option.map_eq_some_iff.mp h
  have hmem := Array.mem_of_find?_eq_some hfind
  simp only [List.mem_toArray, List.mem_filterMap, List.mem_range] at hmem
  obtain ⟨i, hi, hm⟩ := hmem
  obtain ⟨⟨y1, y2⟩, hy, rfl⟩ := Option.map_eq_some_iff.mp hm
  simp only [Prod.mk.injEq] at he2
  obtain ⟨rfl, rfl⟩ := he2
  rw [getElem!_pos S.r.actions i hi] at hy
  have hl := hA _ (hy ▸ Array.getElem_mem hi) pad y2 rfl
  by_cases hp : pad < S.r.protos.size
  · refine ⟨hp, ?_⟩
    rwa [getElem!_pos S.r.protos pad hp] at hl
  · rw [getElem!_neg S.r.protos pad hp] at hl
    exact absurd hl (by decide)

/-- Proof idea: `hD.iters`: each `Iter` starts at a position `p` where `PadRead`/the dropped
store read; induction with `hD.run`'s `instructions` ending at most at the code's size
(`instructions_read`), positions only grow (`Dec.le`). -/
theorem posOf_le_size' (hD : Decodes S code relocs rodata callSites dropped scopes mode) {k : Nat}
    (hk : k < S.r.protos.size) : posOf S.r k ≤ S.body.code.size := by
  obtain ⟨stub, padded, c1, hrun⟩ := hD.run
  rw [posOf_eq hk]
  exact instructions_pos_le hrun (Nat.le_refl _) _ (Array.getElem_mem_toList hk)

end Insn

end Ryo.Proofs.DecodeSound
