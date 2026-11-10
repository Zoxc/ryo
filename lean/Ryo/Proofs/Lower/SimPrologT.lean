/-
Ryo.Proofs.Lower.SimPrologT — the prologue simulated for `LowerPrologT`
(`Check/Lower/PrologStack.lean`, M5b): stack inputs.

- `copy_step`, `movs_step`: one `load.copy` (the pointer from its slot, `IndLoadB`: the caller's
  side of the load from bytes `pb`), and one item's `mov` pieces (`SimAgg.lean`'s `sim_pieces`,
  `pieceFrame_movPieces`).
- `items_run`: the phase-2 items run; each item writes only its destinations (`Item.dsts`,
  pairwise disjoint), reads incoming bytes no item writes (`Item.srcs`) and register pointer
  slots no item writes (`Item.ptrs`); afterwards each `movs`' destination holds its source's
  bytes, each copy's the loaded ones (`items_finish` composes one item with the rest).
- `prologT_bytes`: the whole prologue over frame bytes (`prologI_bytes`' shape): the `arg`s'
  ranges hold their registers' bytes, a stack piece's range the entry frame's incoming bytes,
  an `Indirect` input's home the loaded bytes.
- `ArgRelT` (`ArgBytesT`), `prologT_sim`, `match_entryT`, `fn_soundT`, `fn_soundTS`, and with
  scopes `match_entryEscT`, `fn_soundEscT`: the L0 side per input (a byte inside a stack piece
  refines the entry frame's incoming byte; a pointer on the stack is the entry frame's 8
  incoming bytes), and the entry and function theorems (`SimPrologI.lean`'s, `fn_soundSpS`'s).
-/
import Ryo.Proofs.Lower.SimPrologS
import Ryo.Proofs.Lower.SimAgg
import Ryo.Check.Lower.PrologStack

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-- The caller's side of a load through pointer bytes `pb`: `n` bytes of a live allocation of
`m1`, which are `bs`. -/
def IndLoadB (m1 : Memory) (pb : List AbstractByte) (n : Nat) (bs : List AbstractByte) : Prop :=
  ∃ q id y, pb.length = 8 ∧ decodePtr pb = some q ∧ q.prov = some id ∧ m1.get? id = some y ∧
    y.live = true ∧ y.addr ≤ q.addr ∧ q.addr + n ≤ y.addr + y.size ∧
    m1.load q n Align.one = .ok bs

theorem IndLoadB.length {m1 : Memory} {pb : List AbstractByte} {n : Nat}
    {bs : List AbstractByte} (h : IndLoadB m1 pb n bs) : bs.length = n := by
  obtain ⟨q, id, y, h1, h2, h3, h4, h5, h6, h7, hld⟩ := h
  exact load_length hld

/-- The 8 frame bytes at `s`. -/
def srcBytes (fr : Int → AbstractByte) (s : Int) : List AbstractByte :=
  (List.range 8).map fun j : Nat => fr (s + (j : Int))

theorem srcBytes_getD (fr : Int → AbstractByte) (s : Int) {j : Nat} (hj : j < 8) :
    (srcBytes fr s).getD j .uninit = fr (s + j) := by
  unfold srcBytes
  rw [List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_range hj]
  rfl

/-- A range disjoint from every range of `ds`, where `g` agrees with `f` outside them. -/
theorem keep_of_disj {f g : Int → AbstractByte} {ds : List (Int × Nat)}
    (hout : ∀ o, (∀ r ∈ ds, ¬ (r.1 ≤ o ∧ o < r.1 + r.2)) → g o = f o) {r : Int × Nat}
    (hr : ∀ d ∈ ds, RngDisj r d) : ∀ o, r.1 ≤ o → o < r.1 + r.2 → g o = f o := by
  intro o h1 h2
  apply hout
  intro d hd hc
  have h := hr d hd
  unfold RngDisj at h
  omega

/-- One `load.copy` (see the module comment). -/
theorem copy_step {c : Code} {ch : OpSem.Choice} (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {t : RState} {i : Insn} {cp : CopyIn} {pb bs : List AbstractByte} {m1 : Memory}
    (hi : c.d.insns[t.pc]? = some i) (hsc : c.scopesAt t.pc = [])
    (hok : loadCopyOk c.mode c.ρ i cp = true)
    (hn : ∀ o, t.st.escapedAt o = none) (hm : t.st.mem = m1)
    (hpb : ∀ j : Nat, j < 8 → t.st.frame (cp.ptr + j) = pb.getD j .uninit)
    (hIL : IndLoadB m1 pb cp.size bs) :
    ∃ st', R.step c t ch = .ok (.step { t with pc := t.pc + 1, st := st' }) ∧
      st'.mem = t.st.mem ∧ st'.escaped = t.st.escaped ∧
      ∀ o, st'.frame o =
        if cp.dst ≤ o ∧ o < cp.dst + cp.size then bs.getD (o - cp.dst).toNat .uninit
        else t.st.frame o := by
  obtain ⟨v, ps, r, hv, hh, ho, hops, hctl, hd1, hp1, hn32⟩ := loadCopyOk_spec hok
  obtain ⟨q, id, y, hpbl, hq, hqp, hy, hyl, hy1, hy2, hld⟩ := hIL
  have hpb' : ∀ (j : Nat) (hj : j < pb.length), t.st.frame (cp.ptr + j) = pb[j] := by
    intro j hj
    rw [hpb j (by omega)]
    simp [List.getD, List.getElem?_eq_getElem hj]
  have hrp : t.st.readFrame cp.ptr 8 = .ok pb := by
    have := readFrame_noesc hn hpb'
    rw [hpbl] at this
    exact this
  have hl : t.st.load (q.wrappingOffset 0) cp.size = .ok bs :=
    ind_load hm hpbl hq hqp hy hyl hy1 hy2 hld
  have hlen : bs.length = cp.size := stLoad_length hl
  obtain ⟨st', hw, hm1, hx1, he1, hfr1⟩ := writeFrame_noesc (off := cp.dst) (bs := bs) hn
  have hf1 := offOk_spec hd1
  have hf2 := offOk_spec hp1
  have hop := opSem_loadCopy_fwd (ch := ch) hh ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hn32⟩ hrp hq hl
    hlen hw
  have hstep := step_of_view (ch := ch) hi hsc hpe (hpl _ _ hi) hv hctl
    (by rw [hops]; exact hop)
  refine ⟨st', hstep, hm1, he1, fun o => ?_⟩
  rw [hfr1 o, hlen]

/-- One item's `mov` pieces (see the module comment). -/
theorem movs_step {Γp : PrologICtx} {c : Code} {ch : OpSem.Choice} (hmo : Γp.mode = c.mode)
    (hρ : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {t : RState} {is : List Insn} {d s : Int} {n : Nat} {ws : List Nat}
    (hp : piecesOk Γp.sctx is (movPieces d s 0 ws) = true) (hsum : ws.sum = n)
    (hb : offOk d = true ∧ offOk (d + n) = true ∧ offOk s = true ∧ offOk (s + n) = true)
    (hap : RngDisj (s, n) (d, n))
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[t.pc + j]? = some is[j] ∧
      c.scopesAt (t.pc + j) = [])
    (hn : ∀ o, t.st.escapedAt o = none) :
    ∃ st', StepsTo c ch t { t with pc := t.pc + is.length, st := st' } ∧
      st'.mem = t.st.mem ∧ st'.escaped = t.st.escaped ∧
      ∀ o, st'.frame o = if d ≤ o ∧ o < d + n then t.st.frame (s + (o - d)) else t.st.frame o := by
  have hw : ∀ p ∈ movPieces d s 0 ws, p.Within d (d + n) := by
    intro p hp'
    obtain ⟨o', w, rfl, h1, h2⟩ := movPieces_mem hp'
    have e1 := offOk_spec hb.1
    have e2 := offOk_spec hb.2.1
    have e3 := offOk_spec hb.2.2.1
    have e4 := offOk_spec hb.2.2.2
    have hap' : s + (n : Int) ≤ d ∨ d + (n : Int) ≤ s := hap
    simp only [AggPiece.Within]
    omega
  have hplI : ∀ i ∈ is, PlainView c.mode c.ρ i := by
    intro i hi
    obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hi
    exact hpl _ _ (hcode j hj).1
  have hsrc : ∀ p ∈ movPieces d s 0 ws, ∀ d' s' w, p = .mov d' s' w → ∀ k < w,
      t.st.byteAt (s' + k) = .ok (t.st.frame (s' + k)) := by
    intro _ _ _ s' _ _ k _
    simp only [OpSem.State.byteAt, hn]
    rfl
  obtain ⟨st', hst, hm, he, hf⟩ := sim_pieces (Γ := Γp.sctx) (src := t.st.frame) (lo := d)
    (hi := d + n) (ch := ch) hmo hρ hp (fun j hj => (hcode j hj).1) (fun j hj => (hcode j hj).2)
    hpe hplI hw (fun o _ _ => hn o) hsrc
  refine ⟨st', hst, hm, he, fun o => ?_⟩
  rw [hf, pieceFrame_movPieces, hsum]
  have e : d + ((0 : Nat) : Int) = d := by simp
  rw [e]

/-! ### The items -/

theorem IndLoadB.unique {m1 : Memory} {pb : List AbstractByte} {n : Nat}
    {bs bs' : List AbstractByte} (h : IndLoadB m1 pb n bs) (h' : IndLoadB m1 pb n bs') :
    bs = bs' := by
  obtain ⟨q, _, _, _, hq, _, _, _, _, _, hld⟩ := h
  obtain ⟨q', _, _, _, hq', _, _, _, _, _, hld'⟩ := h'
  rw [hq] at hq'
  have e := Option.some.inj hq'
  subst e
  rw [hld] at hld'
  exact Except.ok.inj hld'

theorem code_append_left {c : Code} {pc : Nat} {is rest : List Insn}
    (h : ∀ (j : Nat) (hj : j < (is ++ rest).length), c.d.insns[pc + j]? = some (is ++ rest)[j] ∧
      c.scopesAt (pc + j) = []) :
    ∀ (j : Nat) (hj : j < is.length), c.d.insns[pc + j]? = some is[j] ∧
      c.scopesAt (pc + j) = [] := by
  intro j hj
  have := h j (by simp; omega)
  rwa [List.getElem_append_left hj] at this

theorem code_append_right {c : Code} {pc : Nat} {is rest : List Insn}
    (h : ∀ (j : Nat) (hj : j < (is ++ rest).length), c.d.insns[pc + j]? = some (is ++ rest)[j] ∧
      c.scopesAt (pc + j) = []) :
    ∀ (j : Nat) (hj : j < rest.length), c.d.insns[pc + is.length + j]? = some rest[j] ∧
      c.scopesAt (pc + is.length + j) = [] := by
  intro j hj
  have := h (is.length + j) (by simp; omega)
  rw [List.getElem_append_right (by omega)] at this
  simp only [Nat.add_sub_cancel_left] at this
  rw [show pc + is.length + j = pc + (is.length + j) by omega]
  exact this

/-- What `items_run` concludes for items `its` from `t` to `t'`, `fr0` the frame the sources and
pointer slots hold. -/
abbrev ItemsOut (m1 : Memory) (fr0 : Int → AbstractByte) (its : List Item) (t t' : RState) : Prop :=
  (∀ o, (∀ r ∈ its.flatMap Item.dsts, ¬ (r.1 ≤ o ∧ o < r.1 + r.2)) →
    t'.st.frame o = t.st.frame o) ∧
  (∀ d s n, Item.movs d s n ∈ its → ∀ o, d ≤ o → o < d + n → t'.st.frame o = fr0 (s + (o - d))) ∧
  (∀ cp, Item.copy cp ∈ its → ∀ bs, IndLoadB m1 (srcBytes fr0 cp.ptr) cp.size bs →
    ∀ (k : Nat) (hk : k < bs.length), t'.st.frame (cp.dst + k) = bs[k]) ∧
  (∀ cp s, Item.movCopy cp s ∈ its →
    (∀ j : Nat, j < 8 → t'.st.frame (cp.ptr + j) = fr0 (s + j)) ∧
    (cp.size ≠ 0 → ∀ bs, IndLoadB m1 (srcBytes fr0 s) cp.size bs →
      ∀ (k : Nat) (hk : k < bs.length), t'.st.frame (cp.dst + k) = bs[k]))

/-- One item (`t → t1`) then the rest (`t1 → t'`): the rest misses the head's destinations. -/
theorem items_finish {m1 : Memory} {fr0 : Int → AbstractByte} {it : Item} {its : List Item}
    {t t1 t' : RState} (hd : ((it :: its).flatMap Item.dsts).Pairwise RngDisj)
    (h1 : ItemsOut m1 fr0 [it] t t1) (h2 : ItemsOut m1 fr0 its t1 t') :
    ItemsOut m1 fr0 (it :: its) t t' := by
  simp only [List.flatMap_cons] at hd
  obtain ⟨-, -, hdHT⟩ := List.pairwise_append.mp hd
  have hkeepH : ∀ r ∈ it.dsts, ∀ o, r.1 ≤ o → o < r.1 + r.2 → t'.st.frame o = t1.st.frame o :=
    fun r hr => keep_of_disj h2.1 (fun d hd' => hdHT r hr d hd')
  have h1o : ∀ o, (∀ r ∈ it.dsts, ¬ (r.1 ≤ o ∧ o < r.1 + r.2)) →
      t1.st.frame o = t.st.frame o := fun o ho => h1.1 o (by simpa using ho)
  refine ⟨fun o ho => ?_, fun d s n hm o ho1 ho2 => ?_, fun cp hm bs hIL k hk => ?_,
    fun cp s hm => ?_⟩
  · simp only [List.flatMap_cons, List.mem_append] at ho
    rw [h2.1 o (fun r hr => ho r (.inr hr)), h1o o (fun r hr => ho r (.inl hr))]
  · rcases List.mem_cons.mp hm with he | hm'
    · have hr : (d, n) ∈ it.dsts := by rw [← he]; simp [Item.dsts]
      rw [hkeepH _ hr o ho1 ho2]
      exact h1.2.1 d s n (by rw [he]; simp) o ho1 ho2
    · exact h2.2.1 d s n hm' o ho1 ho2
  · rcases List.mem_cons.mp hm with he | hm'
    · have hr : (cp.dst, cp.size) ∈ it.dsts := by rw [← he]; simp [Item.dsts]
      have hbl := hIL.length
      rw [hkeepH _ hr _ (by dsimp only; omega) (by dsimp only; omega)]
      exact h1.2.2.1 cp (by rw [he]; simp) bs hIL k hk
    · exact h2.2.2.1 cp hm' bs hIL k hk
  · rcases List.mem_cons.mp hm with he | hm'
    · have hrp : (cp.ptr, 8) ∈ it.dsts := by
        rw [← he]; simp only [Item.dsts]; split <;> simp
      obtain ⟨ha, hb⟩ := h1.2.2.2 cp s (by rw [he]; simp)
      refine ⟨fun j hj => ?_, fun hz bs hIL k hk => ?_⟩
      · rw [hkeepH _ hrp _ (by dsimp only; omega) (by dsimp only; omega)]
        exact ha j hj
      · have hrd : (cp.dst, cp.size) ∈ it.dsts := by
          rw [← he]; simp only [Item.dsts, hz, ↓reduceIte]; simp
        have hbl := hIL.length
        rw [hkeepH _ hrd _ (by dsimp only; omega) (by dsimp only; omega)]
        exact hb hz bs hIL k hk
    · exact h2.2.2.2 cp s hm'

/-- The sources and pointer slots of the rest still hold `fr0` after the head. -/
theorem fr_tail {fr0 : Int → AbstractByte} {it : Item} {its : List Item} {t t1 : RState}
    (hs : ∀ r ∈ (it :: its).flatMap Item.srcs, ∀ d ∈ (it :: its).flatMap Item.dsts, RngDisj r d)
    (hptr : ∀ r ∈ (it :: its).flatMap Item.ptrs, ∀ d ∈ (it :: its).flatMap Item.dsts,
      RngDisj r d)
    (hfr : ∀ r ∈ (it :: its).flatMap Item.srcs ++ (it :: its).flatMap Item.ptrs, ∀ o,
      r.1 ≤ o → o < r.1 + r.2 → t.st.frame o = fr0 o)
    (hout1 : ∀ o, (∀ r ∈ it.dsts, ¬ (r.1 ≤ o ∧ o < r.1 + r.2)) → t1.st.frame o = t.st.frame o) :
    ∀ r ∈ its.flatMap Item.srcs ++ its.flatMap Item.ptrs, ∀ o, r.1 ≤ o → o < r.1 + r.2 →
      t1.st.frame o = fr0 o := by
  intro r hr o h1 h2
  simp only [List.flatMap_cons] at hs hptr hfr
  rw [hout1 o ?_]
  · exact hfr r (by
      rcases List.mem_append.mp hr with h | h
      · exact List.mem_append_left _ (List.mem_append_right _ h)
      · exact List.mem_append_right _ (List.mem_append_right _ h)) o h1 h2
  · intro d hd hc
    rcases List.mem_append.mp hr with h | h
    · have := hs r (List.mem_append_right _ h) d (List.mem_append_left _ hd)
      unfold RngDisj at this
      omega
    · have := hptr r (List.mem_append_right _ h) d (List.mem_append_left _ hd)
      unfold RngDisj at this
      omega

/-- The phase-2 items run (see the module comment). -/
theorem items_run {Γp : PrologICtx} {c : Code} {ch : OpSem.Choice} (hmo : Γp.mode = c.mode)
    (hρ : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i) {m1 : Memory}
    {fr0 : Int → AbstractByte} :
    ∀ {is : List Insn} {its : List Item}, ItemsAre Γp.sctx is its → ∀ (t : RState),
    (∀ (j : Nat) (hj : j < is.length), c.d.insns[t.pc + j]? = some is[j] ∧
      c.scopesAt (t.pc + j) = []) →
    (∀ o, t.st.escapedAt o = none) → t.st.mem = m1 →
    (its.flatMap Item.dsts).Pairwise RngDisj →
    (∀ r ∈ its.flatMap Item.srcs, ∀ d ∈ its.flatMap Item.dsts, RngDisj r d) →
    (∀ r ∈ its.flatMap Item.ptrs, ∀ d ∈ its.flatMap Item.dsts, RngDisj r d) →
    (∀ r ∈ its.flatMap Item.srcs ++ its.flatMap Item.ptrs, ∀ o, r.1 ≤ o → o < r.1 + r.2 →
      t.st.frame o = fr0 o) →
    (∀ cp, Item.copy cp ∈ its → ∃ bs, IndLoadB m1 (srcBytes fr0 cp.ptr) cp.size bs) →
    (∀ cp s, Item.movCopy cp s ∈ its → cp.size ≠ 0 →
      ∃ bs, IndLoadB m1 (srcBytes fr0 s) cp.size bs) →
    ∃ t', StepsTo c ch t t' ∧ t'.pc = t.pc + is.length ∧ t'.fp = t.fp ∧ t'.args = t.args ∧
      t'.st.mem = t.st.mem ∧ t'.st.escaped = t.st.escaped ∧ (∀ o, t'.st.escapedAt o = none) ∧
      ItemsOut m1 fr0 its t t'
  | _, _, .nil, t, _, hn, _, _, _, _, _, _, _ =>
    ⟨t, .refl t, by simp, rfl, rfl, rfl, rfl, hn, fun _ _ => rfl,
      fun _ _ _ h => by simp at h, fun _ h => by simp at h, fun _ _ h => by simp at h⟩
  | _, _, .movs (d := d) (s := s) (n := n) (ws := ws) (is := is) (rest := rest) (its := its) hp
      hsum hb hr, t, hcode, hn, hm, hd, hs, hptr, hfr, hcp, hmc => by
    have hs' := hs
    have hptr' := hptr
    have hfr' := hfr
    have hd' := hd
    simp only [List.flatMap_cons] at hs' hptr' hfr' hd'
    have hap : RngDisj (s, n) (d, n) :=
      hs' _ (List.mem_append_left _ (by simp [Item.srcs])) _
        (List.mem_append_left _ (by simp [Item.dsts]))
    obtain ⟨st1, hst1, hm1, he1, hf1⟩ := movs_step (ch := ch) hmo hρ hpe hpl hp hsum hb hap
      (code_append_left hcode) hn
    have hout1 : ∀ o, (∀ r ∈ (Item.movs d s n).dsts, ¬ (r.1 ≤ o ∧ o < r.1 + r.2)) →
        st1.frame o = t.st.frame o := by
      intro o ho
      rw [hf1 o, if_neg (ho (d, n) (by simp [Item.dsts]))]
    obtain ⟨t', hst', hpc', hfp', hargs', hmem', hesc', hn', hout'⟩ :=
      items_run hmo hρ hpe hpl hr { t with pc := t.pc + is.length, st := st1 }
        (code_append_right hcode)
        (fun o => by show st1.escapedAt o = none; rw [escapedAt_of_escaped he1]; exact hn o)
        (hm1.trans hm) (List.pairwise_append.mp hd').2.1
        (fun r hr' d' hd'' => hs' r (List.mem_append_right _ hr') d'
          (List.mem_append_right _ hd''))
        (fun r hr' d' hd'' => hptr' r (List.mem_append_right _ hr') d'
          (List.mem_append_right _ hd''))
        (fr_tail hs hptr hfr hout1)
        (fun cp hc => hcp cp (List.mem_cons_of_mem _ hc))
        (fun cp s' hc hz => hmc cp s' (List.mem_cons_of_mem _ hc) hz)
    refine ⟨t', hst1.trans hst', ?_, hfp', hargs', hmem'.trans hm1, hesc'.trans he1, hn',
      items_finish hd ⟨?_, ?_, ?_, ?_⟩ hout'⟩
    · rw [hpc']
      show t.pc + is.length + rest.length = t.pc + (is ++ rest).length
      simp only [List.length_append]
      omega
    · exact fun o ho => hout1 o (by simpa using ho)
    · intro d' s'' n' hm' o h1 h2
      simp only [List.mem_singleton] at hm'
      injection hm' with e1 e2 e3
      subst d'
      subst s''
      subst n'
      show st1.frame o = _
      rw [hf1 o, if_pos ⟨h1, h2⟩]
      exact hfr' (s, n) (List.mem_append_left _ (List.mem_append_left _ (by simp [Item.srcs]))) _
        (by dsimp only; omega) (by dsimp only; omega)
    · intro cp hc
      simp at hc
    · intro cp s' hc
      simp at hc
  | _, _, .copy (i := i) (cp := cp) (rest := rest) (its := its) hc hr, t, hcode, hn, hm, hd, hs,
      hptr, hfr, hcp, hmc => by
    have hs' := hs
    have hptr' := hptr
    have hfr' := hfr
    have hd' := hd
    simp only [List.flatMap_cons] at hs' hptr' hfr' hd'
    obtain ⟨bs, hIL⟩ := hcp cp (List.mem_cons_self ..)
    have h0 := hcode 0 (by simp)
    simp only [Nat.add_zero, List.getElem_cons_zero] at h0
    have hpb : ∀ j : Nat, j < 8 →
        t.st.frame (cp.ptr + j) = (srcBytes fr0 cp.ptr).getD j .uninit := by
      intro j hj
      rw [srcBytes_getD _ _ hj]
      exact hfr' (cp.ptr, 8) (List.mem_append_right _ (List.mem_append_left _
        (by simp [Item.ptrs]))) _ (by dsimp only; omega) (by dsimp only; omega)
    obtain ⟨st1, hstep, hm1, he1, hf1⟩ := copy_step (ch := ch) hpe hpl h0.1 h0.2
      (by rw [← hmo, ← hρ]; exact hc) hn hm hpb hIL
    have hout1 : ∀ o, (∀ r ∈ (Item.copy cp).dsts, ¬ (r.1 ≤ o ∧ o < r.1 + r.2)) →
        st1.frame o = t.st.frame o := by
      intro o ho
      rw [hf1 o, if_neg (ho (cp.dst, cp.size) (by simp [Item.dsts]))]
    obtain ⟨t', hst', hpc', hfp', hargs', hmem', hesc', hn', hout'⟩ :=
      items_run hmo hρ hpe hpl hr { t with pc := t.pc + 1, st := st1 }
        (fun j hj => by
          have := hcode (j + 1) (by simp; omega)
          show c.d.insns[t.pc + 1 + j]? = some rest[j] ∧ c.scopesAt (t.pc + 1 + j) = []
          rw [show t.pc + 1 + j = t.pc + (j + 1) by omega]
          simpa using this)
        (fun o => by show st1.escapedAt o = none; rw [escapedAt_of_escaped he1]; exact hn o)
        (hm1.trans hm) (List.pairwise_append.mp hd').2.1
        (fun r hr' d' hd'' => hs' r (List.mem_append_right _ hr') d'
          (List.mem_append_right _ hd''))
        (fun r hr' d' hd'' => hptr' r (List.mem_append_right _ hr') d'
          (List.mem_append_right _ hd''))
        (fr_tail hs hptr hfr hout1)
        (fun cp' hc' => hcp cp' (List.mem_cons_of_mem _ hc'))
        (fun cp' s' hc' hz => hmc cp' s' (List.mem_cons_of_mem _ hc') hz)
    refine ⟨t', .cons hstep hst', ?_, hfp', hargs', hmem'.trans hm1, hesc'.trans he1, hn',
      items_finish hd ⟨?_, ?_, ?_, ?_⟩ hout'⟩
    · rw [hpc']
      show t.pc + 1 + rest.length = t.pc + (i :: rest).length
      simp only [List.length_cons]
      omega
    · exact fun o ho => hout1 o (by simpa using ho)
    · intro d' s'' n' hm'
      simp at hm'
    · intro cp' hc' bs' hIL' k hk
      simp only [List.mem_singleton] at hc'
      injection hc' with e
      subst cp'
      have eb := hIL.unique hIL'
      subst eb
      have hbl := hIL.length
      show st1.frame (cp.dst + k) = _
      rw [hf1, if_pos (by omega)]
      have e : (cp.dst + (k : Int) - cp.dst).toNat = k := by omega
      rw [e]
      simp [List.getD, List.getElem?_eq_getElem hk]
    · intro cp' s' hc'
      simp at hc'
  | _, _, .movCopy0 (cp := cp) (s := s) (ws := ws) (is := is) (rest := rest) (its := its) hp hsum
      hb hz hr, t, hcode, hn, hm, hd, hs, hptr, hfr, hcp, hmc => by
    have hs' := hs
    have hptr' := hptr
    have hfr' := hfr
    have hd' := hd
    simp only [List.flatMap_cons] at hs' hptr' hfr' hd'
    have hdst : (Item.movCopy cp s).dsts = [(cp.ptr, 8)] := by simp [Item.dsts, hz]
    have hap : RngDisj (s, 8) (cp.ptr, 8) :=
      hs' _ (List.mem_append_left _ (by simp [Item.srcs])) _
        (List.mem_append_left _ (by rw [hdst]; simp))
    obtain ⟨st1, hst1, hm1, he1, hf1⟩ := movs_step (ch := ch) hmo hρ hpe hpl hp hsum hb hap
      (code_append_left hcode) hn
    have hout1 : ∀ o, (∀ r ∈ (Item.movCopy cp s).dsts, ¬ (r.1 ≤ o ∧ o < r.1 + r.2)) →
        st1.frame o = t.st.frame o := by
      intro o ho
      rw [hf1 o, if_neg (ho (cp.ptr, 8) (by rw [hdst]; simp))]
    obtain ⟨t', hst', hpc', hfp', hargs', hmem', hesc', hn', hout'⟩ :=
      items_run hmo hρ hpe hpl hr { t with pc := t.pc + is.length, st := st1 }
        (code_append_right hcode)
        (fun o => by show st1.escapedAt o = none; rw [escapedAt_of_escaped he1]; exact hn o)
        (hm1.trans hm) (List.pairwise_append.mp hd').2.1
        (fun r hr' d' hd'' => hs' r (List.mem_append_right _ hr') d'
          (List.mem_append_right _ hd''))
        (fun r hr' d' hd'' => hptr' r (List.mem_append_right _ hr') d'
          (List.mem_append_right _ hd''))
        (fr_tail hs hptr hfr hout1)
        (fun cp' hc => hcp cp' (List.mem_cons_of_mem _ hc))
        (fun cp' s' hc hz' => hmc cp' s' (List.mem_cons_of_mem _ hc) hz')
    refine ⟨t', hst1.trans hst', ?_, hfp', hargs', hmem'.trans hm1, hesc'.trans he1, hn',
      items_finish hd ⟨?_, ?_, ?_, ?_⟩ hout'⟩
    · rw [hpc']
      show t.pc + is.length + rest.length = t.pc + (is ++ rest).length
      simp only [List.length_append]
      omega
    · exact fun o ho => hout1 o (by simpa using ho)
    · intro d' s'' n' hm'
      simp at hm'
    · intro cp' hc'
      simp at hc'
    · intro cp' s' hc'
      simp only [List.mem_singleton] at hc'
      injection hc' with e1 e2
      subst cp'
      subst s'
      refine ⟨fun j hj => ?_, fun hz' => absurd hz hz'⟩
      show st1.frame (cp.ptr + j) = _
      rw [hf1, if_pos (by omega)]
      have e : cp.ptr + (j : Int) - cp.ptr = (j : Int) := by omega
      rw [e]
      exact hfr' (s, 8) (List.mem_append_left _ (List.mem_append_left _ (by simp [Item.srcs]))) _
        (by dsimp only; omega) (by dsimp only; omega)
  | _, _, .movCopy1 (cp := cp) (s := s) (ws := ws) (is := is) (rest := rest) (i := i)
      (its := its) hp hsum hb hz hc hr, t, hcode, hn, hm, hd, hs, hptr, hfr, hcp, hmc => by
    have hs' := hs
    have hptr' := hptr
    have hfr' := hfr
    have hd' := hd
    simp only [List.flatMap_cons] at hs' hptr' hfr' hd'
    have hdst : (Item.movCopy cp s).dsts = [(cp.ptr, 8), (cp.dst, cp.size)] := by
      simp [Item.dsts, hz]
    have hap : RngDisj (s, 8) (cp.ptr, 8) :=
      hs' _ (List.mem_append_left _ (by simp [Item.srcs])) _
        (List.mem_append_left _ (by rw [hdst]; simp))
    have hpd : RngDisj (cp.ptr, 8) (cp.dst, cp.size) := by
      have := (List.pairwise_append.mp hd').1
      rw [hdst] at this
      simpa using this
    have hcode1 := code_append_left hcode
    have hcode2 := code_append_right hcode
    obtain ⟨st1, hst1, hm1, he1, hf1⟩ := movs_step (ch := ch) hmo hρ hpe hpl hp hsum hb hap
      hcode1 hn
    -- the copy, from the moved pointer
    obtain ⟨bs, hIL⟩ := hmc cp s (List.mem_cons_self ..) hz
    have hi2 := hcode2 0 (by simp)
    simp only [Nat.add_zero, List.getElem_cons_zero] at hi2
    have hn1 : ∀ o, st1.escapedAt o = none := fun o => by
      rw [escapedAt_of_escaped he1]; exact hn o
    have hpb : ∀ j : Nat, j < 8 → st1.frame (cp.ptr + j) = (srcBytes fr0 s).getD j .uninit := by
      intro j hj
      rw [srcBytes_getD _ _ hj, hf1, if_pos (by omega)]
      have e : cp.ptr + (j : Int) - cp.ptr = (j : Int) := by omega
      rw [e]
      exact hfr' (s, 8) (List.mem_append_left _ (List.mem_append_left _ (by simp [Item.srcs]))) _
        (by dsimp only; omega) (by dsimp only; omega)
    obtain ⟨st2, hstep2, hm2, he2, hf2⟩ := copy_step (ch := ch)
      (t := { t with pc := t.pc + is.length, st := st1 }) hpe hpl hi2.1 hi2.2
      (by rw [← hmo, ← hρ]; exact hc) hn1 (hm1.trans hm) hpb hIL
    have hout1 : ∀ o, (∀ r ∈ (Item.movCopy cp s).dsts, ¬ (r.1 ≤ o ∧ o < r.1 + r.2)) →
        st2.frame o = t.st.frame o := by
      intro o ho
      rw [hdst] at ho
      rw [hf2 o, if_neg (ho (cp.dst, cp.size) (by simp))]
      show st1.frame o = _
      rw [hf1 o, if_neg (ho (cp.ptr, 8) (by simp))]
    obtain ⟨t', hst', hpc', hfp', hargs', hmem', hesc', hn', hout'⟩ :=
      items_run hmo hρ hpe hpl hr { t with pc := t.pc + is.length + 1, st := st2 }
        (fun j hj => by
          have := hcode2 (j + 1) (by simp; omega)
          show c.d.insns[t.pc + is.length + 1 + j]? = some rest[j] ∧
            c.scopesAt (t.pc + is.length + 1 + j) = []
          rw [show t.pc + is.length + 1 + j = t.pc + is.length + (j + 1) by omega]
          simpa using this)
        (fun o => by show st2.escapedAt o = none; rw [escapedAt_of_escaped he2]; exact hn1 o)
        (hm2.trans (hm1.trans hm)) (List.pairwise_append.mp hd').2.1
        (fun r hr' d' hd'' => hs' r (List.mem_append_right _ hr') d'
          (List.mem_append_right _ hd''))
        (fun r hr' d' hd'' => hptr' r (List.mem_append_right _ hr') d'
          (List.mem_append_right _ hd''))
        (fr_tail (t1 := { t with pc := t.pc + is.length + 1, st := st2 }) hs hptr hfr hout1)
        (fun cp' hc' => hcp cp' (List.mem_cons_of_mem _ hc'))
        (fun cp' s' hc' hz' => hmc cp' s' (List.mem_cons_of_mem _ hc') hz')
    refine ⟨t', hst1.trans (.cons hstep2 hst'), ?_, hfp', hargs',
      hmem'.trans (hm2.trans hm1), hesc'.trans (he2.trans he1), hn',
      items_finish hd ⟨?_, ?_, ?_, ?_⟩ hout'⟩
    · rw [hpc']
      show t.pc + is.length + 1 + rest.length = t.pc + (is ++ i :: rest).length
      simp only [List.length_append, List.length_cons]
      omega
    · exact fun o ho => hout1 o (by simpa using ho)
    · intro d' s'' n' hm'
      simp at hm'
    · intro cp' hc'
      simp at hc'
    · intro cp' s' hc'
      simp only [List.mem_singleton] at hc'
      injection hc' with e1 e2
      subst cp'
      subst s'
      have hpd' : cp.ptr + (8 : Int) ≤ cp.dst ∨ cp.dst + (cp.size : Int) ≤ cp.ptr := hpd
      refine ⟨fun j hj => ?_, fun _ bs' hIL' k hk => ?_⟩
      · show st2.frame (cp.ptr + j) = _
        rw [hf2, if_neg (by omega)]
        have := hpb j hj
        rw [srcBytes_getD _ _ hj] at this
        exact this
      · have eb := hIL.unique hIL'
        subst eb
        have hbl := hIL.length
        show st2.frame (cp.dst + k) = _
        rw [hf2, if_pos (by omega)]
        have e : (cp.dst + (k : Int) - cp.dst).toNat = k := by omega
        rw [e]
        simp [List.getD, List.getElem?_eq_getElem hk]

/-! ### The whole prologue over frame bytes -/

theorem IndLoadB.len8 {m1 : Memory} {pb : List AbstractByte} {n : Nat} {bs : List AbstractByte}
    (h : IndLoadB m1 pb n bs) : pb.length = 8 := by
  obtain ⟨_, _, _, h8, -⟩ := h
  exact h8

/-- 8 frame bytes that are `pb`'s. -/
theorem srcBytes_of {f : Int → AbstractByte} {s : Int} {pb : List AbstractByte}
    (hl : pb.length = 8) (h : ∀ (j : Nat) (hj : j < pb.length), f (s + j) = pb[j]) :
    srcBytes f s = pb := by
  apply List.ext_getElem?
  intro j
  by_cases hj : j < 8
  · have e : (srcBytes f s)[j]? = some (f (s + j)) := by
      unfold srcBytes
      rw [List.getElem?_map, List.getElem?_range hj]
      rfl
    rw [e, List.getElem?_eq_getElem (by omega : j < pb.length), h j (by omega)]
  · have e1 : (srcBytes f s).length = 8 := by simp [srcBytes]
    rw [List.getElem?_eq_none (by omega : (srcBytes f s).length ≤ j),
      List.getElem?_eq_none (by omega : pb.length ≤ j)]

theorem srcBytes_congr {f g : Int → AbstractByte} {s : Int}
    (h : ∀ j : Nat, j < 8 → f (s + j) = g (s + j)) : srcBytes f s = srcBytes g s := by
  unfold srcBytes
  apply List.map_congr_left
  intro j hj
  exact h j (List.mem_range.mp hj)

theorem writeT_of_input {Γp : PrologICtx} {inps : List InputT} {lw : List ArgWrite}
    {inp : InputT} (h : inp ∈ inps) {w : ArgWrite} (hw : w ∈ inp.writes) :
    w ∈ allWritesT Γp inps lw := by
  simp only [allWritesT, List.mem_append, List.mem_flatMap]
  first
    | exact Or.inl (Or.inr ⟨inp, h, hw⟩)
    | exact Or.inr (Or.inl ⟨inp, h, hw⟩)

theorem itemT_of_input {inps : List InputT} {inp : InputT} (h : inp ∈ inps) {it : Item}
    (hit : it ∈ inp.items) : it ∈ allItemsT inps :=
  List.mem_flatMap.mpr ⟨inp, h, hit⟩

/-- A `copy` item comes from a non-empty `Indirect` input with its pointer in a register. -/
theorem copyT_mem {inps : List InputT} {cp : CopyIn} (h : Item.copy cp ∈ allItemsT inps) :
    ∃ inp ∈ inps, ∃ idx, inp.kind = .ind cp.ptr idx ∧ inp.slot.off = cp.dst ∧
      inp.slot.size = cp.size ∧ inp.slot.size ≠ 0 := by
  obtain ⟨⟨slot, kind⟩, hinp, hc⟩ := List.mem_flatMap.mp h
  cases kind with
  | regs rps sps => simp [InputT.items] at hc
  | ind ptr idx =>
    by_cases hz : slot.size = 0
    · simp [InputT.items, hz] at hc
    · simp only [InputT.items, hz, ↓reduceIte, List.mem_singleton] at hc
      injection hc with hc
      subst hc
      exact ⟨_, hinp, idx, rfl, rfl, rfl, hz⟩
  | indStack ptr at_ => simp [InputT.items] at hc

/-- A `movCopy` item comes from an `Indirect` input with its pointer on the stack. -/
theorem movCopyT_mem {inps : List InputT} {cp : CopyIn} {s : Int}
    (h : Item.movCopy cp s ∈ allItemsT inps) :
    ∃ inp ∈ inps, ∃ at_, inp.kind = .indStack cp.ptr at_ ∧ s = incoming at_ ∧
      inp.slot.off = cp.dst ∧ inp.slot.size = cp.size := by
  obtain ⟨⟨slot, kind⟩, hinp, hc⟩ := List.mem_flatMap.mp h
  cases kind with
  | regs rps sps => simp [InputT.items] at hc
  | ind ptr idx =>
    by_cases hz : slot.size = 0
    · simp [InputT.items, hz] at hc
    · simp [InputT.items, hz] at hc
  | indStack ptr at_ =>
    simp only [InputT.items, List.mem_singleton] at hc
    injection hc with e1 e2
    subst e1
    exact ⟨_, hinp, at_, rfl, e2, rfl, rfl⟩

/-- The prologue's run over frame bytes (see the module comment): `hind`, `hindS` are the
caller's loads (an `Indirect` input's pointer in a register, on the stack).

Proof: `writes_run_esc` for the `arg`s (pairwise from `hl.disj`'s first part), then `items_run`
from there (`fr0` its frame): a `copy`'s pointer slot holds its register's 8 bytes (the `arg`
write), the sources (the incoming area) still the entry frame's (`hl.srcs` against the writes).
The `arg`s' bytes survive the items (`hl.disj`'s cross part). -/
theorem prologT_bytes {Γp : PrologICtx} {c : Code} {ch : OpSem.Choice} {is : List Insn}
    {inps : List InputT} {lw : List ArgWrite} (hl : LowerPrologT Γp is inps lw)
    (hmo : Γp.mode = c.mode) (hρ : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {s : RState}
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧
      c.scopesAt (s.pc + j) = [])
    (hnoesc : ∀ o, s.st.escapedAt o = none)
    (hind : ∀ inp ∈ inps, ∀ ptr idx, inp.kind = .ind ptr idx → inp.slot.size ≠ 0 →
      ∃ bs, IndLoadB s.st.mem (regBytes s.args (ptrArg idx)) inp.slot.size bs)
    (hindS : ∀ inp ∈ inps, ∀ ptr at_, inp.kind = .indStack ptr at_ → inp.slot.size ≠ 0 →
      ∃ bs, IndLoadB s.st.mem (srcBytes s.st.frame (incoming at_)) inp.slot.size bs) :
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      s'.st.mem = s.st.mem ∧ s'.st.escaped = s.st.escaped ∧ (∀ o, s'.st.escapedAt o = none) ∧
      (∀ w ∈ allWritesT Γp inps lw, ∀ (j : Nat) (hj : j < (regBytes s.args w.2).length),
        s'.st.frame (w.1 + j) = (regBytes s.args w.2)[j]) ∧
      (∀ inp ∈ inps, ∀ rps sps, inp.kind = .regs rps sps → ∀ sp ∈ sps, ∀ k : Nat,
        sp.off ≤ k → k < sp.off + sp.size →
        s'.st.frame (inp.slot.off + k) = s.st.frame (incoming sp.at_ + (k - sp.off : Nat))) ∧
      (∀ inp ∈ inps, ∀ ptr idx, inp.kind = .ind ptr idx → inp.slot.size ≠ 0 →
        ∀ bs, IndLoadB s.st.mem (regBytes s.args (ptrArg idx)) inp.slot.size bs →
        ∀ (k : Nat) (hk : k < bs.length), s'.st.frame (inp.slot.off + k) = bs[k]) ∧
      (∀ inp ∈ inps, ∀ ptr at_, inp.kind = .indStack ptr at_ → inp.slot.size ≠ 0 →
        ∀ bs, IndLoadB s.st.mem (srcBytes s.st.frame (incoming at_)) inp.slot.size bs →
        ∀ (k : Nat) (hk : k < bs.length), s'.st.frame (inp.slot.off + k) = bs[k]) := by
  -- the ranges
  have hd0 : ((allWritesT Γp inps lw).map ArgWrite.rng ++
      (allItemsT inps).flatMap Item.dsts).Pairwise RngDisj := hl.disj
  obtain ⟨hdW, hdI, hdWI⟩ := List.pairwise_append.mp hd0
  have hwd : (allWritesT Γp inps lw).Pairwise WriteDisj :=
    (List.pairwise_map.mp hdW).imp fun h => h
  have hwi : ∀ w ∈ allWritesT Γp inps lw, ∀ r ∈ (allItemsT inps).flatMap Item.dsts,
      RngDisj w.rng r := fun w hw r hr => hdWI _ (List.mem_map_of_mem hw) _ hr
  have hsrcs : ∀ r ∈ (allItemsT inps).flatMap Item.srcs,
      ∀ d ∈ (allWritesT Γp inps lw).map ArgWrite.rng ++ (allItemsT inps).flatMap Item.dsts,
      RngDisj r d := hl.srcs
  have hsw : ∀ r ∈ (allItemsT inps).flatMap Item.srcs, ∀ w ∈ allWritesT Γp inps lw,
      RngDisj r w.rng := fun r hr w hw =>
    hsrcs r hr _ (List.mem_append_left _ (List.mem_map_of_mem hw))
  have hsi : ∀ r ∈ (allItemsT inps).flatMap Item.srcs,
      ∀ d ∈ (allItemsT inps).flatMap Item.dsts, RngDisj r d := fun r hr d hd =>
    hsrcs r hr d (List.mem_append_right _ hd)
  -- the `arg`s
  obtain ⟨n, hn⟩ : ∃ n, (allWritesT Γp inps lw).length = n := ⟨_, rfl⟩
  have hA : ArgsAre (is.take n) (allWritesT Γp inps lw) := by rw [← hn]; exact hl.args
  have hC : ItemsAre Γp.sctx (is.drop n) (allItemsT inps) := by rw [← hn]; exact hl.items
  have hlenA : (is.take n).length = n := by rw [argsAre_length hA, hn]
  have hle : n ≤ is.length := by rw [List.length_take] at hlenA; omega
  have hcodeA : ∀ (j : Nat) (hj : j < (is.take n).length),
      c.d.insns[s.pc + j]? = some (is.take n)[j] ∧ c.scopesAt (s.pc + j) = [] := by
    intro j hj
    have hj' : j < is.length := by rw [hlenA] at hj; omega
    obtain ⟨h1, h2⟩ := hcode j hj'
    refine ⟨?_, h2⟩
    rw [h1]
    simp
  obtain ⟨sA, hstA, hpcA, hfpA, hargsA, hmemA, hesclA, hescA, houtA, hinA⟩ :=
    writes_run_esc (ch := ch) hA s hcodeA (fun _ _ _ _ => hnoesc _)
  have hinA' := hinA hwd
  have hnA : ∀ o, sA.st.escapedAt o = none := fun o => by rw [hescA]; exact hnoesc o
  -- the sources keep the entry frame's bytes
  have hsrcA : ∀ r ∈ (allItemsT inps).flatMap Item.srcs, ∀ o, r.1 ≤ o → o < r.1 + r.2 →
      sA.st.frame o = s.st.frame o := by
    intro r hr o h1 h2
    apply houtA
    intro w hw hc
    have hd : r.1 + (r.2 : Int) ≤ w.1 ∨ w.1 + (w.2.size : Int) ≤ r.1 := hsw r hr w hw
    omega
  have hsrcS : ∀ cp s', Item.movCopy cp s' ∈ allItemsT inps →
      srcBytes sA.st.frame s' = srcBytes s.st.frame s' := by
    intro cp s' hm
    apply srcBytes_congr
    intro j hj
    exact hsrcA (s', 8) (List.mem_flatMap.mpr ⟨_, hm, by simp [Item.srcs]⟩) _
      (by dsimp only; omega) (by dsimp only; omega)
  -- a register pointer's slot holds its 8 bytes
  have hptrA : ∀ inp ∈ inps, ∀ ptr idx, inp.kind = .ind ptr idx →
      (regBytes s.args (ptrArg idx)).length = 8 →
      srcBytes sA.st.frame ptr = regBytes s.args (ptrArg idx) := by
    intro inp hinp ptr idx hk h8
    have hw : (ptr, ptrArg idx) ∈ allWritesT Γp inps lw :=
      writeT_of_input hinp (by simp [InputT.writes, hk])
    exact srcBytes_of h8 (fun j hj => hinA' _ hw j hj)
  -- the items
  have hcodeC : ∀ (j : Nat) (hj : j < (is.drop n).length),
      c.d.insns[sA.pc + j]? = some (is.drop n)[j] ∧ c.scopesAt (sA.pc + j) = [] := by
    intro j hj
    have hj' : n + j < is.length := by simp at hj; omega
    obtain ⟨h1, h2⟩ := hcode (n + j) hj'
    have e : sA.pc + j = s.pc + (n + j) := by rw [hpcA, hlenA]; omega
    rw [e]
    refine ⟨?_, h2⟩
    rw [h1]
    simp
  have hcpI : ∀ cp, Item.copy cp ∈ allItemsT inps →
      ∃ bs, IndLoadB s.st.mem (srcBytes sA.st.frame cp.ptr) cp.size bs := by
    intro cp hcp
    obtain ⟨inp, hinp, idx, hk, -, hsz, hz⟩ := copyT_mem hcp
    obtain ⟨bs, hIL⟩ := hind inp hinp _ idx hk hz
    have e := hptrA inp hinp _ idx hk hIL.len8
    rw [← hsz, e]
    exact ⟨bs, hIL⟩
  have hmcI : ∀ cp s', Item.movCopy cp s' ∈ allItemsT inps → cp.size ≠ 0 →
      ∃ bs, IndLoadB s.st.mem (srcBytes sA.st.frame s') cp.size bs := by
    intro cp s' hm hz
    obtain ⟨inp, hinp, at_, hk, hs', -, hsz⟩ := movCopyT_mem hm
    obtain ⟨bs, hIL⟩ := hindS inp hinp _ at_ hk (by omega)
    refine ⟨bs, ?_⟩
    rw [hsrcS cp s' hm, hs', ← hsz]
    exact hIL
  obtain ⟨sI, hstI, hpcI, hfpI, hargsI, hmemI, hesclI, hnI, hout⟩ :=
    items_run (ch := ch) (m1 := s.st.mem) (fr0 := sA.st.frame) hmo hρ hpe hpl hC sA hcodeC hnA hmemA hdI
      hsi hl.ptrs (fun _ _ _ _ _ => rfl) hcpI hmcI
  refine ⟨sI, hstA.trans hstI, ?_, hfpI.trans hfpA, hargsI.trans hargsA, hmemI.trans hmemA,
    hesclI.trans hesclA, hnI, ?_, ?_, ?_, ?_⟩
  · rw [hpcI, hpcA, hlenA]
    simp only [List.length_drop]
    omega
  · -- the `arg`s' bytes survive the items
    intro w hw j hj
    rw [hout.1 (w.1 + j) ?_]
    · exact hinA' w hw j hj
    · intro r hr hc
      have hd : w.1 + (w.2.size : Int) ≤ r.1 ∨ r.1 + (r.2 : Int) ≤ w.1 := hwi w hw r hr
      have := regBytes_length_le s.args w.2
      omega
  · -- a stack piece
    intro inp hinp rps sps hk sp hsp k hk1 hk2
    have hit : Item.movs (inp.slot.off + sp.off) (incoming sp.at_) sp.size ∈ allItemsT inps :=
      itemT_of_input hinp (by
        simp only [InputT.items, hk]
        exact List.mem_map_of_mem hsp)
    have e := hout.2.1 _ _ _ hit (inp.slot.off + k) (by omega) (by omega)
    rw [e]
    have e2 : incoming sp.at_ + (inp.slot.off + (k : Int) - (inp.slot.off + (sp.off : Int))) =
        incoming sp.at_ + ((k - sp.off : Nat) : Int) := by omega
    rw [e2]
    apply hsrcA (incoming sp.at_, sp.size) (List.mem_flatMap.mpr ⟨_, hit, by simp [Item.srcs]⟩)
    · dsimp only; omega
    · dsimp only; omega
  · -- an `Indirect` input, pointer in a register
    intro inp hinp ptr idx hk hz bs hIL k hk'
    have hit : Item.copy ⟨inp.slot.off, ptr, inp.slot.size⟩ ∈ allItemsT inps :=
      itemT_of_input hinp (by simp [InputT.items, hk, hz])
    have e := hptrA inp hinp ptr idx hk hIL.len8
    refine hout.2.2.1 _ hit bs ?_ k hk'
    show IndLoadB s.st.mem (srcBytes sA.st.frame ptr) inp.slot.size bs
    rw [e]
    exact hIL
  · -- an `Indirect` input, pointer on the stack
    intro inp hinp ptr at_ hk hz bs hIL k hk'
    have hit : Item.movCopy ⟨inp.slot.off, ptr, inp.slot.size⟩ (incoming at_) ∈
        allItemsT inps :=
      itemT_of_input hinp (by simp [InputT.items, hk])
    refine (hout.2.2.2 _ _ hit).2 hz bs ?_ k hk'
    show IndLoadB s.st.mem (srcBytes sA.st.frame (incoming at_)) inp.slot.size bs
    rw [hsrcS _ _ hit]
    exact hIL

/-! ### The relation at entry -/

/-- The bytes of an input's L0 allocation `x` against the entry (see the module comment): `m1`
R's memory, `fr1` R's entry frame. -/
def ArgBytesT (ι : Inj) (m1 : Memory) (fr1 : Int → AbstractByte) (args : Regs) :
    InKindT → Allocation → Prop
  | .regs rps sps, x => ∀ k (hk : k < x.data.size), x.data[k] = .uninit ∨
      (∃ p ∈ rps, p.1 ≤ k ∧
        ∃ b, (regBytes args p.2)[k - p.1]? = some b ∧ ByteInj ι x.data[k] b) ∨
      (∃ sp ∈ sps, sp.off ≤ k ∧ k < sp.off + sp.size ∧
        ByteInj ι x.data[k] (fr1 (incoming sp.at_ + (k - sp.off : Nat))))
  | .ind _ idx, x => x.data.size ≠ 0 → ∃ bs,
      IndLoadB m1 (regBytes args (ptrArg idx)) x.data.size bs ∧ BytesInj ι x.data.toList bs
  | .indStack _ at_, x => x.data.size ≠ 0 → ∃ bs,
      IndLoadB m1 (srcBytes fr1 (incoming at_)) x.data.size bs ∧ BytesInj ι x.data.toList bs

/-- The L0 side of call entry for input `inp` with storage `ptr`, and its R side (R's memory
`m1`, entry frame `fr1`): `ArgRelX`'s allocation facts and `ArgBytesT`. What the caller provides
(M5c); the incoming area is R's frame, private at entry (`hnoesc`). -/
def ArgRelT (ι : Inj) (fp : Nat) (m0 m1 : Memory) (fr1 : Int → AbstractByte) (args : Regs)
    (inp : InputT) (ptr : ThinPointer) : Prop :=
  ∃ al x, ptr.prov = some al ∧ ι al = none ∧ m0.get? al = some x ∧ x.live = true ∧
    (x.addr : Int) = fp + inp.slot.off ∧ ptr.addr = x.addr ∧ x.data.size = inp.slot.size ∧
    ArgBytesT ι m1 fr1 args inp.kind x

theorem inputsOkT_get {Γp : PrologICtx} : ∀ {k : Nat} {inps : List InputT},
    InputsOkT Γp k inps → ∀ j (h : j < inps.length), InputOkT Γp (k + j) inps[j]
  | _, _, .nil _, j, h => by simp at h
  | _, _, .cons (k := k) (inp := inp) (inps := inps) hok hrest, j, h => by
    cases j with
    | zero => first | exact hok | simpa using hok
    | succ j =>
      have h' : j < inps.length := by simp at h; omega
      have := inputsOkT_get hrest j h'
      have e : k + (j + 1) = k + 1 + j := by omega
      rw [e]
      first | exact this | simpa using this

/-- Input `j`'s home is local `k + j + 1`'s slot. -/
theorem inputsOkT_slot {Γp : PrologICtx} {k : Nat} {inps : List InputT}
    (h : InputsOkT Γp k inps) (j : Nat) (hj : j < inps.length) :
    Γp.slots[k + j + 1]? = some inps[j].slot :=
  (inputsOkT_get h j hj).slot_eq

/-- The prologue simulated: `prologI_sim`'s statement for `LowerPrologT` with `ArgRelT`.

Proof: `prologT_bytes` (the loads from `ArgRelT`); each input's `LocalRel.priv`: a register
byte as `prologI_sim`'s, a stack piece's byte the entry frame's incoming byte, an `Indirect`
input's bytes the loaded ones, refined by `ArgBytesT`'s `BytesInj`. -/
theorem prologT_sim {Γp : PrologICtx} {c : Code} {ch : OpSem.Choice} {is : List Insn}
    {inps : List InputT} {lw : List ArgWrite} (hl : LowerPrologT Γp is inps lw)
    (hmo : Γp.mode = c.mode) (hρ : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {ι : Inj} {fp : Nat} {m0 : Memory} {s : RState}
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧
      c.scopesAt (s.pc + j) = [])
    (hnoesc : ∀ o, s.st.escapedAt o = none)
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelT ι fp m0 s.st.mem s.st.frame s.args inps[j] qs[j])
    (hmem : MemInj ι m0 s.st.mem) :
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      MemInj ι m0 s'.st.mem ∧ (∀ o, s'.st.escapedAt o = none) ∧
      (∀ j (h1 : j < inps.length) (h2 : j < qs.length),
        LocalRel ι fp s'.st m0 inps[j].slot qs[j] true) ∧
      (∀ w ∈ sretWrites Γp.toPrologXCtx ++ lw, ∀ (j : Nat) (hj : j < (regBytes s.args w.2).length),
        s'.st.frame (w.1 + j) = (regBytes s.args w.2)[j]) ∧ s'.st.mem = s.st.mem ∧
      s'.st.escaped = s.st.escaped := by
  have hind : ∀ inp ∈ inps, ∀ ptr idx, inp.kind = .ind ptr idx → inp.slot.size ≠ 0 →
      ∃ bs, IndLoadB s.st.mem (regBytes s.args (ptrArg idx)) inp.slot.size bs := by
    intro inp hinp ptr idx hk hz
    obtain ⟨j, hj, rfl⟩ := List.getElem_of_mem hinp
    obtain ⟨al, x, -, -, -, -, -, -, hxs, hb⟩ := hrel j hj (by omega)
    rw [hk] at hb
    simp only [ArgBytesT] at hb
    obtain ⟨bs, hIL, -⟩ := hb (by omega)
    rw [hxs] at hIL
    exact ⟨bs, hIL⟩
  have hindS : ∀ inp ∈ inps, ∀ ptr at_, inp.kind = .indStack ptr at_ → inp.slot.size ≠ 0 →
      ∃ bs, IndLoadB s.st.mem (srcBytes s.st.frame (incoming at_)) inp.slot.size bs := by
    intro inp hinp ptr at_ hk hz
    obtain ⟨j, hj, rfl⟩ := List.getElem_of_mem hinp
    obtain ⟨al, x, -, -, -, -, -, -, hxs, hb⟩ := hrel j hj (by omega)
    rw [hk] at hb
    simp only [ArgBytesT] at hb
    obtain ⟨bs, hIL, -⟩ := hb (by omega)
    rw [hxs] at hIL
    exact ⟨bs, hIL⟩
  obtain ⟨s', hst, hpc, hfp, hargs, hmeq, hescl, hesc, hW, hM, hI, hIS⟩ :=
    prologT_bytes (ch := ch) hl hmo hρ hpe hpl hcode hnoesc hind hindS
  refine ⟨s', hst, hpc, hfp, hargs, by rw [hmeq]; exact hmem, hesc, ?_, ?_, hmeq, hescl⟩
  · intro j h1 h2
    obtain ⟨al, x, hp, hι, hx, hlive, haddr, hpaddr, hsize, hb⟩ := hrel j h1 h2
    have hmemj : inps[j] ∈ inps := List.getElem_mem h1
    refine .priv al x hp hι hx hlive haddr hpaddr hsize (fun k _ => hesc _) ?_
    intro _ k hk
    cases hkind : inps[j].kind with
    | regs rps sps =>
      rw [hkind] at hb
      simp only [ArgBytesT] at hb
      rcases hb k hk with hu | ⟨p, hp', hle, b, hbk, hbi⟩ | ⟨sp, hsp, hs1, hs2, hbi⟩
      · rw [hu]; trivial
      · obtain ⟨hkl, hbe⟩ := List.getElem?_eq_some_iff.mp hbk
        have hwm : (inps[j].slot.off + p.1, p.2) ∈ allWritesT Γp inps lw :=
          writeT_of_input hmemj (by
            simp only [InputT.writes, hkind]
            exact List.mem_map_of_mem hp')
        have hfk := hW _ hwm (k - p.1) hkl
        dsimp only at hfk
        have e : inps[j].slot.off + (k : Int) =
            inps[j].slot.off + (p.1 : Int) + ((k - p.1 : Nat) : Int) := by omega
        rw [e, hfk, hbe]
        exact hbi
      · rw [hM _ hmemj rps sps hkind sp hsp k hs1 hs2]
        exact hbi
    | ind ptr idx =>
      rw [hkind] at hb
      simp only [ArgBytesT] at hb
      obtain ⟨bs, hIL, hbi⟩ := hb (by omega)
      have hbl : bs.length = x.data.size := hIL.length
      rw [hsize] at hIL
      have hc := hI _ hmemj ptr idx hkind (by omega) bs hIL k (by omega)
      rw [hc]
      have := BytesInj.getElem' hbi k (by simpa using hk) (by omega)
      simpa using this
    | indStack ptr at_ =>
      rw [hkind] at hb
      simp only [ArgBytesT] at hb
      obtain ⟨bs, hIL, hbi⟩ := hb (by omega)
      have hbl : bs.length = x.data.size := hIL.length
      rw [hsize] at hIL
      have hc := hIS _ hmemj ptr at_ hkind (by omega) bs hIL k (by omega)
      rw [hc]
      have := BytesInj.getElem' hbi k (by simpa using hk) (by omega)
      simpa using this
  · intro w hw j hj
    have hw' : w ∈ allWritesT Γp inps lw := by
      simp only [allWritesT, List.mem_append] at hw ⊢
      rcases hw with h | h <;> simp [h]
    exact hW w hw' j hj

/-- `match_entryI` (`SimPrologI.lean`) for `LowerPrologT`.

Proof: `match_entryI`'s, with `prologT_sim` and `inputsOkT_slot`. -/
theorem match_entryT {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {ι : Inj}
    {Γp : PrologICtx} {is : List Insn} {inps : List InputT} {lw : List ArgWrite}
    (hpl : LowerPrologT Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hmo : Γp.mode = c.mode) (hρp : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    -- R at the prologue
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hreach : reachGet (computeReach Γ.body) 0 = true)
    (hfz : blk.fused = true → 0 < bd.stmts.length)
    -- L0's entry frame (`callBody`)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelT ι s1.fp s.mem s1.st.mem s1.st.frame s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem) :
    ∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s s1' ∧
      (∀ w ∈ sretWrites Γp.toPrologXCtx ++ lw, ∀ (j : Nat) (hj : j < (regBytes s1.args w.2).length),
        s1'.st.frame (w.1 + j) = (regBytes s1.args w.2)[j]) ∧
      s1'.args = s1.args ∧ (∀ o, s1'.st.escapedAt o = none) ∧ s1'.st.mem = s1.st.mem := by
  obtain ⟨s', hst, hpc, hfp, hargs, hmem', hesc, hlr0, hw, hmeq, -⟩ :=
    prologT_sim (ch := ch) hpl hmo hρp hpe hplain hcode hnoesc qs hqs hrel hmem
  have hlr : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      LocalRel ι s'.fp s'.st s.mem inps[j].slot qs[j] true := by
    rw [hfp]; exact hlr0
  refine ⟨s', hst, Or.inl ⟨f, rest, blk, bd, ?_, by rw [hbb]; exact hreach,
    fun h => by rw [hstmt]; exact hfz h⟩, hw, hargs, hesc, hmeq⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, rel := ?_, sl := ?_, pb := hpb, fresh := hfresh, dinv := hdinv }
  · rw [hbb]; exact hblk
  · rw [hbb]; exact hbd
  · rw [hstmt]; exact Nat.zero_le _
  · rw [hstmt, hstart, hpc]
  · refine ⟨⟨?_, ?_⟩, hhid, hal, hprov, hapart, ?_⟩
    · exact hmem'
    · intro l p hp _
      obtain ⟨j, h1, h2, rfl, rfl⟩ := hloc l p hp
      refine ⟨inps[j].slot, ?_, (hlr j h1 h2).weaken (fun _ => rfl)⟩
      have := inputsOkT_slot hpl.inputs j h1
      rw [hslots] at this
      simpa using this
    · intro o e he
      rw [hesc] at he
      cases he
  · intro l p hp
    rw [hbb, hstmt]
    exact hsl l p hp

/-- `fn_soundI` with `LowerPrologT`'s entry (`match_entryT`): functions with stack inputs.
`hrel` is `ArgRelT` (the caller's side, M5c: stack pieces' bytes in R's entry frame, an
`Indirect` input's bytes in R's memory). -/
theorem fn_soundT {Γ : TermCtx} {c : Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologICtx} {is : List Insn} {inps : List InputT} {lw : List ArgWrite}
    (hpl : LowerPrologT Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelT ι s1.fp s.mem s1.st.mem s1.st.frame s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem)
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧
          RetValX Γ ι v regs) ∨
      FnStop Γ c ch ι o s s' s1 := by
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  obtain ⟨s0, hst0, hm0, -, -, -, -⟩ := match_entryT (ch := ch) hpl hslots (hpm.trans hmode.symm)
    (hpρ.trans hρ.symm) hpe hplain hcode hnoesc hblk hbd hstart
    hfn.reach.entry (fused_start hfn hfn.reach.entry hbd hblk) hs hbody hbb hstmt hpu hcont hal
    qs hqs hloc hrel hmem hhid hprov hapart hsl hpb hfresh hdinv
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩ | hstop
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr (hstop.pre hst0))

/-- `fn_soundS` (`SimRetSret.lean`) with `LowerPrologT`'s entry (`match_entryT`): sret returns
resolved in functions with stack inputs. -/
theorem fn_soundTS {Γ : TermCtx} {c : Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologICtx} {is : List Insn} {inps : List InputT} {lw : List ArgWrite}
    (hpl : LowerPrologT Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ) (hpsr : Γp.sret = Γ.sret)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelT ι s1.fp s.mem s1.st.mem s1.st.frame s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem)
    (hsr8 : ∀ so, Γ.sret = some so → (regBytes s1.args sretReg).length = 8)
    (hsrd : ∀ so, Γ.sret = some so → SretOk Γ s1.st.mem (regBytes s1.args sretReg))
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧
          RetValX Γ ι v regs) ∨
      (∃ s1m sa sb m v regs incoming m1, StepsTo c ch s1 s1m ∧ L0Steps o m s sa ∧
        runOn (Sem.evalTerminator .«return») o sa = (.ok (), sb) ∧ sb.final = some (.returned v) ∧
        R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) ∧
        RetSret Γ ι v (regBytes s1.args sretReg) m1 s1m.st.mem regs) ∨
      FnStop Γ c ch ι o s s' s1 := by
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  obtain ⟨s0, hst0, hm0, hw0, ha0, hn0, hme0⟩ := match_entryT (ch := ch) hpl hslots
    (hpm.trans hmode.symm)
    (hpρ.trans hρ.symm) hpe hplain hcode hnoesc hblk hbd hstart
    hfn.reach.entry (fused_start hfn hfn.reach.entry hbd hblk) hs hbody hbb hstmt hpu hcont hal
    qs hqs hloc hrel hmem hhid hprov hapart hsl hpb hfresh hdinv
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩ | hstop
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩)
  · rcases hstop with hd | hr | ha | ⟨s1', sa, sb, m, hst, hm, hsr⟩
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inl hd))))
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inr (.inl hr)))))
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inr (.inr (.inl ha))))))
    · obtain ⟨f', rest', live, next, is', so, hs', hb', hso, hlow, hat, hrel', hl0, hc', hret⟩ :=
        hsr
      have hso' : Γp.sret = some so := hpsr.trans hso
      have hwin : (so, sretReg) ∈ sretWrites Γp.toPrologXCtx ++ lw := by
        simp [sretWrites, hso']
      have h8 := hsr8 so hso
      have hpin : PinAt s0.st so s0.args := by
        rw [ha0]
        exact PinAt.of_bytes h8 (fun j hj => hw0 _ hwin j hj)
      have hd0 : SretOk Γ s0.st.mem (regBytes s0.args sretReg) := by
        rw [ha0, hme0]; exact hsrd so hso
      obtain ⟨v, s1m, regs, incoming, hfinal, hst', hstep2, hret'⟩ :=
        sim_retSret_from (ch := ch) hfn hmode hρ hinc (hfn.pin so hso) hst hn0 hpin
          (by rw [ha0]; exact h8) hd0 hs' hb' hlow hat hrel' hl0 hc' hret
      rw [ha0] at hret'
      exact .inr (.inr (.inl ⟨s1m, sa, sb, m, v, regs, incoming, _, hst0.trans hst', hm, hret,
        hfinal, hstep2, hret'⟩))

/-! ### Functions with scopes -/

/-- `match_entryEsc` (`FnSimX.lean`) for `LowerPrologT`: the prologue by `prologT_sim`, which
keeps the (empty) list of escaped objects. -/
theorem match_entryEscT {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {Γp : PrologICtx} {is : List R.Insn} {inps : List InputT} {lw : List ArgWrite}
    (hpl : LowerPrologT Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoobj : s1.st.escaped = [])
    (hfree : ∀ id y, s1.st.mem.get? id = some y → y.live = true →
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        (y.addr : Int) + y.data.size ≤ s1.fp + sl.off ∨ s1.fp + sl.off + sl.size ≤ y.addr)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelT ι s1.fp s.mem s1.st.mem s1.st.frame s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem)
    (haligned : ∀ (l : Local) (p : ThinPointer) (ty : Spec.Ty), f.locals[l]? = some (some p) →
      f.body.locals[l]? = some ty → p.addr % ty.align.bytes = 0) :
    ∃ s1', StepsTo c ch s1 s1' ∧ MatchEscR Γ c ι s s1' ∧
      (∀ w ∈ sretWrites Γp.toPrologXCtx ++ lw, ∀ (j : Nat) (hj : j < (regBytes s1.args w.2).length),
        s1'.st.frame (w.1 + j) = (regBytes s1.args w.2)[j]) ∧
      s1'.args = s1.args ∧ s1'.st.mem = s1.st.mem ∧ s1'.st.escaped = [] := by
  have hnoesc : ∀ o, s1.st.escapedAt o = none := fun o => by
    unfold OpSem.State.escapedAt
    rw [hnoobj]
    rfl
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  obtain ⟨s', hst, hpc, hfp, hargs, hmi, hescAt, hlr0, hw, hmeq, hesc'⟩ :=
    prologT_sim (ch := ch) hpl (hpm.trans hmode.symm) (hpρ.trans hρ.symm) hpe hplain hcode
      hnoesc qs hqs hrel hmem
  have hnoobj' : s'.st.escaped = [] := by rw [hesc', hnoobj]
  have hlr : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      LocalRel ι s'.fp s'.st s.mem inps[j].slot qs[j] true := by
    rw [hfp]; exact hlr0
  have hfnrel : FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb f.stmt) f s.mem s' := by
    refine ⟨⟨hmi, ?_⟩, hhid, hal, hprov, hapart, ?_⟩
    · intro l p hp _
      obtain ⟨j, h1, h2, rfl, rfl⟩ := hloc l p hp
      refine ⟨inps[j].slot, ?_, (hlr j h1 h2).weaken (fun _ => rfl)⟩
      have := inputsOkT_slot hpl.inputs j h1
      rw [hslots] at this
      simpa using this
    · intro o e he
      rw [hescAt] at he
      cases he
  have hX : FnRelX Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb f.stmt) f s.mem s' := by
    refine ⟨hfnrel, fun e he => ?_, ?_, fun a b x e _ _ _ he _ => ?_, fun id y hy hl => ?_,
      haligned, fun e he => ?_, fun e he _ _ => ?_⟩
    · rw [hnoobj'] at he; simp at he
    · rw [hnoobj']; exact List.Pairwise.nil
    · rw [hnoobj'] at he; simp at he
    · refine .inr fun l sl hsl => ?_
      rw [hmeq] at hy
      rw [hfp]
      exact hfree id y hy hl l sl hsl
    · rw [hnoobj'] at he; simp at he
    · rw [hnoobj'] at he; simp at he
  refine ⟨s', hst, ⟨s', f, rest, blk, bd, ?_, by rw [hbb]; exact hfn.reach.entry⟩, hw, hargs,
    hmeq, hnoobj'⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, pend := ?_, rel := hX, sl := ?_, pb := hpb, fresh := hfresh,
           dinv := hdinv }
  · rw [hbb]; exact hblk
  · rw [hbb]; exact hbd
  · rw [hstmt]; exact Nat.zero_le _
  · rw [hstmt, hstart, hpc]
  · rw [hstmt, pendSpecs_zero]
    all_goals first | rfl | simp [pure, Except.pure]
  · intro l p hp
    rw [hbb, hstmt]
    exact hsl l p hp

/-- `fn_soundEsc` (`FnSimX.lean`) with `LowerPrologT`'s entry (`match_entryEscT`): functions
with scopes and stack inputs. Beyond `fn_soundEsc`'s hypotheses: `fn_soundT`'s `hpm`,
`hpρ`, `hqs` and `ArgRelT`. -/
theorem fn_soundEscT {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ ι s s1, MatchEsc Γ c ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologICtx} {is : List R.Insn} {inps : List InputT} {lw : List ArgWrite}
    (hpl : LowerPrologT Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoobj : s1.st.escaped = [])
    (hfree : ∀ id y, s1.st.mem.get? id = some y → y.live = true →
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        (y.addr : Int) + y.data.size ≤ s1.fp + sl.off ∨ s1.fp + sl.off + sl.size ≤ y.addr)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelT ι s1.fp s.mem s1.st.mem s1.st.frame s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem)
    (haligned : ∀ (l : Local) (p : ThinPointer) (ty : Spec.Ty), f.locals[l]? = some (some p) →
      f.body.locals[l]? = some ty → p.addr % ty.align.bytes = 0)
    (hre : ReusesAt o) (hpool : PoolInv Γ.poolAt c.ρ ι s)
    (hfre : FnReusesAt o) (hsk : SymsKept c ch)
    (hfinv : FnInv Γ.fnSymAt c.ρ ι s s1.st)
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ MatchEscR Γ c ι' s' s1') ∨
      (∃ ι' s1' s0 v regs incoming, ι.Le ι' ∧ StepsTo c ch s1 s1' ∧
        s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s0 (.ret regs incoming))) ∧ RetValX Γ ι' v regs) ∨
      (∃ s1', StepsTo c ch s1 s1' ∧ DeadAt Γ s') ∨
      (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ UnwindsX c ch ι' s' s1') ∨
      (∃ ι' s1' sa sb m, ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ L0Steps o m s sa ∧
        StoppedX Γ c ch ι' o sa sb s1') := by
  obtain ⟨s0, hst0, hm0, -, -, -, -⟩ := match_entryEscT (ch := ch) hfn hmode hρ hpl hslots hpm hpρ
    hcode
    hnoobj hfree hblk hbd hstart hs hbody hbb hstmt hpu hcont hal qs hqs hloc hrel hmem hhid
    hprov hapart hsl hpb hfresh hdinv haligned
  rcases fn_simX hfn hmode hρ hinc hpick hre hfre hsk hm0 hpool
      (hfinv.of_steps hsk hst0) hrun with
    ⟨ι', s1', hle, hst, hm⟩ | ⟨ι', s1', s0', v, regs, incoming, hle, hst, hf, hr, hv⟩ |
    ⟨s1', hst, hd⟩ | ⟨ι', s1', hle, hst, hu⟩ | ⟨ι', s1', sa, sb, m, hle, hst, hsa, hsx⟩
  · exact .inl ⟨ι', s1', hle, hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨ι', s1', s0', v, regs, incoming, hle, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr (.inl ⟨s1', hst0.trans hst, hd⟩))
  · exact .inr (.inr (.inr (.inl ⟨ι', s1', hle, hst0.trans hst, hu⟩)))
  · exact .inr (.inr (.inr (.inr ⟨ι', s1', sa, sb, m, hle, hst0.trans hst, hsa, hsx⟩)))

end Ryo.Proofs.Lower
