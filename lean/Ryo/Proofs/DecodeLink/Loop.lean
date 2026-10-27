/-
Ryo.Proofs.DecodeLink.Loop — the instruction loop (aot.md §C2, toward M3 `decode_sound`):
where `instructions` read each proto, with which cache and dropped stores, so that the per-shape
links (`Links`, `Call`, `Items`, `Inline`, `Drop`, `Arg`) place each accepted proto's items in
code memory. This is the induction item 5's composition runs.

One iteration (`Iter`) from position `p`, cache `cache`, dropped stores `dr`:

- `empty`: a dropped store at `p` (a sequence that left no code) is read by `inlineInsn` at `p`,
  no padding or counter check before it;
- `main`: padding from `p` to `p1` (`PadRead`, `nop`s: `padRead_codeAt` puts them in memory), the
  cache cleared if `p1` is a branch target, the counter check from `p1` to `p2` with counters
  (`CounterRead`: `inc [rip + rec + 56]; jns stub`, the proto's `counter`), then the proto read at
  `p2` (`ProtoRead`) as `arg` (while every proto before is one), a call, an inline sequence or
  one other instruction, each after the others failed; the proto's `pos` is `p1`, the branch
  target, before the counter check (the shape lemmas' `pos`), its items from `p2`.

The decoder functions that return `none` leave the cursor (`callInsn_none`, `inlineInsn_none`),
but for one quirk mirrored from Rust: `argInsn` after a `movd r11d, xmm` that no item follows
returns `none` with the cursor past the `movd` (`argInsn_none`), and the next attempts read from
there, so the `movd` is skipped. Every later attempt then reads at a position where
`decodeItem` fails, so only an inline sequence of a dropped store alone could still be accepted
there; `ProtoRead` keeps that cursor explicit (`NoArg`).

- `instructions_read`: a successful `instructions` is a chain of iterations (`Iters`) from the
  cursor's position, an empty cache and all dropped stores, to its end position with none left;
  `read_instructions`: `read`'s protos are its second `instructions` pass, from the body's
  cursor (without a frame pointer with `spFrame` the frame size).
-/
import Ryo.Proofs.DecodeLink.Drop
import Ryo.Proofs.DecodeLink.Arg

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

/-! ### Padding -/

/-- `padding`'s reading from `p` to `q`: `nop`s of 1 to 9 bytes with no relocation in them. -/
inductive PadRead (c : Cursor) : Nat → Nat → Prop
  | nil (p : Nat) : PadRead c p p
  | nop {p q n : Nat} : 1 ≤ n → n ≤ 9 → (atPos c p).bytes n = some (nops.getD n []) →
      (atPos c p).relocsHere n = [] → PadRead c (p + n) q → PadRead c p q

theorem PadRead.snoc {c : Cursor} {p q n : Nat} (h : PadRead c p q) (h1 : 1 ≤ n) (h9 : n ≤ 9)
    (hb : (atPos c q).bytes n = some (nops.getD n [])) (hr : (atPos c q).relocsHere n = []) :
    PadRead c p (q + n) := by
  induction h with
  | nil p => exact .nop h1 h9 hb hr (.nil _)
  | nop a b d e _ ih => exact .nop a b d e (ih hb hr)

theorem PadRead.le {c : Cursor} {p q : Nat} (h : PadRead c p q) : p ≤ q := by
  induction h with
  | nil => exact Nat.le_refl _
  | nop a _ _ _ _ ih => omega

theorem nop_itemAt {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) {p n : Nat} (h1 : 1 ≤ n) (h9 : n ≤ 9)
    (hby : (atPos c p).bytes n = some (nops.getD n [])) (hr : (atPos c p).relocsHere n = [])
    (hb : Boundary rs p) :
    ItemAt ctx m (.nop n) p ∧ (Item.nop n).size = n ∧ Boundary rs (p + n) := by
  have hlen : (nops.getD n []).length = n := by
    match n, h1, h9 with
    | 1, _, _ | 2, _, _ | 3, _, _ | 4, _, _ | 5, _, _ | 6, _, _ | 7, _, _ | 8, _, _ | 9, _, _ => rfl
  have henc : (Item.nop n).encode (BitVec.ofNat 32 p) = (nops.getD n [], []) := by
    simp [Item.encode]
  have hr' : relocsIn rs p n = [] := by simpa [Cursor.relocsHere, hk.fields] using hr
  have none_in : ∀ r ∈ rs.toList, ¬ (p ≤ r.pos ∧ r.pos < p + n) := by
    intro r hr0 hin
    have := (mem_relocsIn hk.sorted p n r).mpr ⟨hr0, hin⟩
    rw [hr'] at this; cases this
  have hle : p + n ≤ c.code.size := by
    by_cases h2 : p + n ≤ c.code.size
    · exact h2
    · simp [Cursor.bytes, h2] at hby
  have hext : (c.code.extract p (p + n)).toList = nops.getD n [] := by
    simpa [Cursor.bytes, hle] using hby
  refine ⟨?_, ?_, ?_⟩
  · unfold ItemAt
    rw [Uniq.linkedAt_plain _ _ _ (by rw [henc]), henc]
    intro j hj
    rw [addrAt_add']
    have hj' : j < n := hlen ▸ hj
    rw [hk.loaded.1 (p + j) (by omega)]
    · simp only [← hext, Array.getElem_toList, Array.getElem_extract]
    · rintro r hr0 ⟨h1, h2⟩
      by_cases h0 : r.pos < p
      · have := hb r hr0 h0; omega
      · exact none_in r hr0 ⟨by omega, by omega⟩
  · simp [Item.size, Item.len, Item.encode]; simpa using hlen
  · intro r hr0 hlt
    by_cases h0 : r.pos < p
    · have := hb r hr0 h0; omega
    · exact absurd ⟨by omega, hlt⟩ (none_in r hr0)

/-- What `DM.padding` read: `PadRead` from the cursor to where it left it, its length the
difference. -/
theorem padding_read {c c' : Cursor} {pad : Nat} (h : DM.padding.run c = .ok (pad, c')) :
    PadRead c c.pos c'.pos ∧ c'.pos = c.pos + pad ∧ c' = atPos c c'.pos := by
  unfold DM.padding at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨hp0, hc1⟩ := pos_run' h1
  subst hp0 hc1
  obtain ⟨fu, c2, h2, h⟩ := bind_ok h
  have hc2 := fuel_run h2
  subst hc2
  obtain ⟨st, c3, h3, h⟩ := bind_ok h
  have key := forIn_range_inv (fun _ cur => cur = atPos c2 cur.pos ∧ PadRead c2 c2.pos cur.pos)
    (fun _ cur => cur = atPos c2 cur.pos ∧ PadRead c2 c2.pos cur.pos) _ ?_ _ _ _ _ _ ⟨rfl, .nil _⟩ h3
  · have kc : c3 = atPos c2 c3.pos ∧ PadRead c2 c2.pos c3.pos := by rcases key with k | k <;> exact k
    obtain ⟨_, c4, h4, h⟩ := bind_ok h
    obtain ⟨rfl, rfl⟩ := pos_run' h4
    obtain ⟨rfl, rfl⟩ := pure_ok h
    have := kc.2.le
    exact ⟨kc.2, by omega, kc.1⟩
  · intro a b cur r cur' hI hr
    rw [show ∀ (f : Cursor → DM (ForInStep PUnit)) c, ((get : DM Cursor) >>= f).run c = (f c).run c
      from fun _ _ => rfl] at hr
    split at hr
    · rename_i n hf
      have hp := List.find?_some hf
      have hmem := List.mem_of_find?_eq_some hf
      have hn : 1 ≤ n ∧ n ≤ 9 := by
        simp only [List.mem_map, List.mem_reverse, List.mem_range] at hmem
        omega
      have hb : cur.bytes n = some (nops.getD n []) := by simpa using hp
      split at hr
      · obtain ⟨rfl, rfl⟩ := pure_ok hr
        exact hI
      · rename_i hrl
        have hrl : cur.relocsHere n = [] := by simpa using hrl
        obtain ⟨_, c6, h6, hr⟩ := bind_ok hr
        rw [run_setPos] at h6; cases h6
        have hI' : atPos cur (cur.pos + n) = atPos c2 (cur.pos + n) ∧
            PadRead c2 c2.pos (cur.pos + n) := by
          obtain ⟨e, hpr⟩ := hI
          refine ⟨by rw [e], hpr.snoc hn.1 hn.2 ?_ ?_⟩
          · rw [← e]; exact hb
          · rw [← e]; exact hrl
        split at hr <;> (obtain ⟨rfl, rfl⟩ := pure_ok hr; exact hI')
    · obtain ⟨rfl, rfl⟩ := pure_ok hr
      exact hI

/-- Padding in memory: `nop` items (`Item.nop n`, `1 ≤ n ≤ 9`, canonical) from `p`. -/
theorem padRead_codeAt {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) {p q : Nat} (h : PadRead c p q) (hb : Boundary rs p) :
    ∃ ns : List Nat, (∀ n ∈ ns, 1 ≤ n ∧ n ≤ 9) ∧ CodeAt ctx m (ns.map Item.nop) p ∧
      q = p + codeSize (ns.map Item.nop) ∧ Boundary rs q := by
  induction h with
  | nil p => exact ⟨[], by simp, trivial, by simp [codeSize], hb⟩
  | nop h1 h9 hby hr _ ih =>
    obtain ⟨hi, hs, hb'⟩ := nop_itemAt hk h1 h9 hby hr hb
    obtain ⟨ns, hns, hc, hq, hbq⟩ := ih hb'
    refine ⟨_ :: ns, ?_, ⟨hi, by rw [hs]; exact hc⟩, ?_, hbq⟩
    · intro k hk'
      rcases List.mem_cons.mp hk' with rfl | hk'
      · exact ⟨h1, h9⟩
      · exact hns k hk'
    · simp only [List.map_cons, codeSize, List.sum_cons] at hq ⊢
      rw [hs]; omega

/-! ### One iteration -/

/-- The counter check before a proto at `p1`: none (and `p2 = p1`), or with counters the loop
counter's `inc` and `jns stub` read from `p1` to `p2`, `counter = (stub, p2)`. -/
inductive CounterRead (fr : Frame) (c : Cursor) : Nat → Option (Nat × Nat) → Nat → Prop
  | none (p : Nat) : CounterRead fr c p none p
  | check {p1 p2 : Nat} {t : BitVec 32} {long : Bool} : fr.mode.counters = true →
      Dec c p1 [.ctrInc true, .branch .ns t long] p2 → CounterRead fr c p1 (some (t.toNat, p2)) p2

/-- The cursor the attempts after `arg` start from: the position, or (while every proto before
is an `arg`) wherever a failed `argInsn` left it. -/
def NoArg (fr : Frame) (c : Cursor) (p : Nat) (argsOnly : Bool) (cur : Cursor) : Prop :=
  (argsOnly = false ∧ cur = atPos c p) ∨
    (argsOnly = true ∧ (argInsn fr.mode).run (atPos c p) = .ok (none, cur))

/-- The proto read at `p` by the first of `argInsn`, `callInsn`, `inlineInsn`, `insn` that
accepts, with the cache before (`cache`) and after, the dropped stores before and after, and
the cursor after (`c'`). -/
inductive ProtoRead (fr : Frame) (ro : ByteArray) (exact : Bool) (c : Cursor) :
    Nat → Cache → List DroppedStore → Bool → Proto → Cursor → Cache → List DroppedStore → Prop
  | arg {p : Nat} {cache : Cache} {dr : List DroppedStore} {q : Proto} {c' : Cursor} :
      (argInsn fr.mode).run (atPos c p) = .ok (some q, c') →
      ProtoRead fr ro exact c p cache dr true q c' cache dr
  | call {p : Nat} {cache : Cache} {dr : List DroppedStore} {a : Bool} {q : Proto}
      {cur c' : Cursor} : NoArg fr c p a cur →
      (callInsn fr dr).run cur = .ok (some q, c') → ProtoRead fr ro exact c p cache dr a q c' {} dr
  | inline {p : Nat} {cache cache' : Cache} {dr dr' : List DroppedStore} {a : Bool} {q : Proto}
      {cur cur' c' : Cursor} : NoArg fr c p a cur → (callInsn fr dr).run cur = .ok (none, cur') →
      (inlineInsn cache dr exact).run cur' = .ok (some (q, cache', dr'), c') →
      ProtoRead fr ro exact c p cache dr a q c' cache' dr'
  | insn {p : Nat} {cache : Cache} {dr : List DroppedStore} {a : Bool} {q : Proto}
      {cur cur' cur'' c' : Cursor} : NoArg fr c p a cur →
      (callInsn fr dr).run cur = .ok (none, cur') →
      (inlineInsn cache dr exact).run cur' = .ok (none, cur'') →
      (insn fr ro).run cur'' = .ok (q, c') → ProtoRead fr ro exact c p cache dr a q c' {} dr

/-- One iteration of `instructions` (see the module comment): from `p` with `cache` and `dr`,
proto `q`, to `p'` with `cache'` and `dr'`. -/
inductive Iter (fr : Frame) (ro : ByteArray) (targets : Option (Array Nat)) (c : Cursor) :
    Bool → Nat → Cache → List DroppedStore → Proto → Nat → Cache → List DroppedStore → Prop
  | empty {a : Bool} {p : Nat} {cache cache' : Cache} {d : DroppedStore}
      {dr dr' : List DroppedStore} {q : Proto} {c' : Cursor} : d.at_ = p →
      (inlineInsn cache (d :: dr) targets.isSome).run (atPos c p) =
        .ok (some (q, cache', dr'), c') →
      Iter fr ro targets c a p cache (d :: dr) { q with pos := p } c'.pos cache' dr'
  | main {a : Bool} {p p1 p2 : Nat} {cache cache' : Cache} {dr dr' : List DroppedStore}
      {counter : Option (Nat × Nat)} {q : Proto} {c' : Cursor} :
      PadRead c p p1 → CounterRead fr c p1 counter p2 →
      ProtoRead fr ro targets.isSome c p2
        (if targets.any (sortedContains · p1) then {} else cache) dr a q c' cache' dr' →
      Iter fr ro targets c a p cache dr { q with pos := p1, counter } c'.pos cache' dr'

/-- Iterations one after the other; `a`: every proto so far is an `arg`. -/
inductive Iters (fr : Frame) (ro : ByteArray) (targets : Option (Array Nat)) (c : Cursor) :
    Bool → Nat → Cache → List DroppedStore → List Proto → Nat → List DroppedStore → Prop
  | nil (a : Bool) (p : Nat) (cache : Cache) (dr : List DroppedStore) :
      Iters fr ro targets c a p cache dr [] p dr
  | cons {a : Bool} {p p' pe : Nat} {cache cache' : Cache} {dr dr' dre : List DroppedStore}
      {q : Proto} {qs : List Proto} :
      Iter fr ro targets c a p cache dr q p' cache' dr' →
      Iters fr ro targets c (a && q.op == .arg) p' cache' dr' qs pe dre →
      Iters fr ro targets c a p cache dr (q :: qs) pe dre

/-! ### Failed attempts -/

theorem PosOnly.get' : PosOnly (get : DM Cursor) := by
  intro c b c' h; obtain ⟨-, rfl⟩ := get_run h; rfl

theorem PosOnly.expectItems' : ∀ l, PosOnly (DM.expectItems l)
  | [] => PosOnly.pure _
  | w :: ws => by
    unfold DM.expectItems
    exact PosOnly.bind PosOnly.tryItem fun _ => PosOnly.ite (PosOnly.pure _) (PosOnly.expectItems' ws)

macro "loop_posonly" : tactic => `(tactic| repeat (first
  | exact PosOnly.pure _ | exact PosOnly.pos | exact PosOnly.setPos _ | exact PosOnly.err _ _
  | exact PosOnly.tryItem | exact PosOnly.item | exact PosOnly.fuel | exact PosOnly.get'
  | exact PosOnly.expectItems' _
  | refine PosOnly.bind ?_ (fun _ => ?_)
  | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_)
  | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_)
  | split
  | dsimp only))

/-- A `for` loop over a list whose body never moves the cursor nor returns `some none`. -/
theorem forIn_keep {α γ : Type} (l : List α)
    (f : α → Option (Option γ) × Unit → DM (ForInStep (Option (Option γ) × Unit)))
    (init : Option (Option γ) × Unit) (hinit : init.1 ≠ some none)
    (hf : ∀ a b c r c', (f a b).run c = .ok (r, c') → c' = c ∧
      (match r with | .yield b => b.1 ≠ some none | .done b => b.1 ≠ some none))
    {c c' : Cursor} {b : Option (Option γ) × Unit} (h : (forIn l init f).run c = .ok (b, c')) :
    c' = c ∧ b.1 ≠ some none := by
  have := forIn_list_inv (fun b c'' => c'' = c ∧ b.1 ≠ some none) (fun b c'' => c'' = c ∧ b.1 ≠ some none) f
    (by
      intro a b c2 r c3 ⟨e, _⟩ hr
      obtain ⟨e', hr'⟩ := hf a b c2 r c3 hr
      cases r <;> exact ⟨e'.trans e, hr'⟩) l init c c' b ⟨rfl, hinit⟩ h
  rcases this with h | h <;> exact h

theorem forIn_ret {α σ γ : Type} (p : Nat) (l : List α)
    (f : α → Option (Option γ) × σ → DM (ForInStep (Option (Option γ) × σ)))
    (init : Option (Option γ) × σ) (hinit : init.1 = none)
    (hf : ∀ a b c r c', (f a b).run c = .ok (r, c') →
      (match r with | .yield b => b.1 = none | .done b => b.1 = none ∨ (b.1 = some none ∧ c'.pos = p)))
    {c c' : Cursor} {b : Option (Option γ) × σ} (h : (forIn l init f).run c = .ok (b, c')) :
    b.1 = none ∨ (b.1 = some none ∧ c'.pos = p) := by
  have := forIn_list_inv (fun b _ => b.1 = none) (fun b c'' => b.1 = none ∨ (b.1 = some none ∧ c''.pos = p)) f
    (by
      intro a b c2 r c3 _ hr
      have := hf a b c2 r c3 hr
      cases r <;> exact this) l init c c' b hinit h
  rcases this with h | h
  · exact .inl h
  · exact h

theorem PosOnly.params' (mode : Mode) : PosOnly (params mode) := by
  unfold params
  loop_posonly

/-- `callInsn` that finds no call leaves the cursor. -/
theorem callInsn_none {fr : Frame} {dropped : List DroppedStore} {c c' : Cursor}
    (h : (callInsn fr dropped).run c = .ok (none, c')) : c' = c := by
  unfold callInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨hp0, hc1⟩ := pos_run' h1
  subst hp0 hc1
  obtain ⟨pre, c2, h2, h⟩ := bind_ok h
  have e2 := (by loop_posonly : PosOnly _) _ _ _ h2
  obtain ⟨ps, c3, h3, h⟩ := bind_ok h
  have e3 := PosOnly.params' _ _ _ _ h3
  obtain ⟨callAt, c4, h4, h⟩ := bind_ok h
  obtain ⟨hp4, hc4⟩ := pos_run' h4
  subst hp4 hc4
  have back : atPos c4 c1.pos = c1 := by rw [e3, e2]
  split at h
  · obtain ⟨u, c5, h5, h⟩ := bind_ok h
    rw [run_setPos] at h5; cases h5
    obtain ⟨-, rfl⟩ := pure_ok h; exact back
  · obtain ⟨it, c5, h5, h⟩ := bind_ok h
    obtain ⟨r, c6, h6, h⟩ := bind_ok h
    have e5 := PosOnly.tryItem _ _ _ h5
    have e6 := (by loop_posonly : PosOnly _) _ _ _ h6
    have back' : atPos c6 c1.pos = c1 := by rw [e6, e5]; exact back
    split at h
    · split at h
      · obtain ⟨s, c7, h7, h⟩ := bind_ok h
        obtain ⟨s, c8, h8, h⟩ := bind_ok h
        split at h
        obtain ⟨h, -⟩ := pure_ok h; cases h
      · obtain ⟨h, -⟩ := pure_ok h; cases h
    · obtain ⟨u, c7, h7, h⟩ := bind_ok h
      rw [run_setPos] at h7; cases h7
      obtain ⟨-, rfl⟩ := pure_ok h; exact back'

/-- `inlineInsn` that finds no sequence leaves the cursor. -/
theorem inlineInsn_none {cache : Cache} {dropped : List DroppedStore} {exact : Bool}
    {c c' : Cursor} (h : (inlineInsn cache dropped exact).run c = .ok (none, c')) : c' = c := by
  unfold inlineInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨hp0, hc1⟩ := pos_run' h1
  subst hp0 hc1
  obtain ⟨fu, c2, h2, h⟩ := bind_ok h
  have hc2 := fuel_run h2
  subst hc2
  obtain ⟨st, c3, h3, h⟩ := bind_ok h
  have key := forIn_range_inv
    (fun st cur => cur = atPos c2 cur.pos ∧ (st.1 = none ∨ (st.1 = some none ∧ cur.pos = c2.pos)))
    (fun st cur => cur = atPos c2 cur.pos ∧ (st.1 = none ∨ (st.1 = some none ∧ cur.pos = c2.pos)))
    _ ?_ _ _ _ _ _ ⟨rfl, .inl rfl⟩ h3
  · have kc : c3 = atPos c2 c3.pos ∧ (st.1 = none ∨ (st.1 = some none ∧ c3.pos = c2.pos)) := by
      rcases key with k | k <;> exact k
    clear key
    dsimp only at h
    repeat (any_goals (first
      | (obtain ⟨_, _, h1, h⟩ := bind_ok h
         try (have hfo := forIn_keep _ _ _ (by simp) (by
           intro a b c r c' hr
           repeat (any_goals (first | split at hr | dsimp only at hr))
           all_goals (obtain ⟨rfl, rfl⟩ := pure_ok hr; simp)) h1))
      | split at h
      | dsimp only at h))
    all_goals (obtain ⟨h0, rfl⟩ := pure_ok h)
    all_goals try (cases h0; done)
    all_goals try (subst h0; exact absurd ‹_› hfo.2)
    all_goals try (subst h0; rcases kc with ⟨e, h | ⟨_, hp⟩⟩
                   · exact absurd (h.symm.trans ‹st.fst = some none›) (by simp)
                   · rw [e, hp])
    all_goals try (rw [run_setPos] at h1; cases h1; try rw [hfo.1]; exact (congrArg (atPos · c2.pos) kc.1).trans rfl)
    all_goals exact (congrArg (atPos · c2.pos) kc.1).trans rfl
  · intro a b cur r cur' hI hr
    dsimp only at hr
    have e' : cur' = atPos c2 cur'.pos := by rw [(by loop_posonly : PosOnly _) _ _ _ hr, hI.1]
    repeat (any_goals (first
      | (obtain ⟨_, _, h1, hr⟩ := bind_ok hr)
      | split at hr
      | dsimp only at hr))
    all_goals (obtain ⟨rfl, rfl⟩ := pure_ok hr; refine ⟨e', ?_⟩; first | exact .inl rfl | (right; refine ⟨rfl, ?_⟩; rw [run_setPos] at h1; cases h1; rfl))

/-- `argInsn` that finds no `arg` leaves the cursor, but after a `movd r11d, xmm` no item
follows (Rust's quirk, see the module comment). -/
theorem argInsn_none {mode : Mode} {c c' : Cursor}
    (h : (argInsn mode).run c = .ok (none, c')) :
    c' = c ∨ ∃ x n, decodeItem c = some (.movd false x .r11, n) ∧ c' = atPos c (c.pos + n) ∧
      decodeItem c' = none := by
  unfold argInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨hp0, hc1⟩ := pos_run' h1
  subst hp0 hc1
  obtain ⟨fi, c2, h2, h⟩ := bind_ok h
  cases fi with
  | none =>
    left; rw [← run_tryItem_none h2]
    dsimp only at h
    exact (pure_ok h).2.symm
  | some first =>
  obtain ⟨n, hn, rfl⟩ := run_tryItem_some h2
  obtain ⟨r, c3, h3, h⟩ := bind_ok h
  cases r with
  | some am =>
    left
    have e3 := (by loop_posonly : PosOnly _) _ _ _ h3
    have eh := (by loop_posonly : PosOnly _) _ _ _ h
    rw [eh, e3]
    suffices hp : c'.pos = c1.pos by rw [hp]
    dsimp only at h
    obtain ⟨_, c4, h4, h⟩ := bind_ok h
    obtain ⟨_, c5, h5, h⟩ := bind_ok h
    rw [run_setPos] at h5; cases h5
    split at h
    · obtain ⟨st, c6, h6, h⟩ := bind_ok h
      have hfo := forIn_ret c1.pos _ _ _ rfl (by
        intro a b c r c' hr
        obtain ⟨_, _, h1, hr⟩ := bind_ok hr
        split at hr
        · obtain ⟨_, _, h1, hr⟩ := bind_ok hr
          rw [run_setPos] at h1; cases h1
          obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact .inr ⟨rfl, rfl⟩
        · obtain ⟨rfl, rfl⟩ := pure_ok hr
          rfl) h6
      split at h
      · obtain ⟨rfl, rfl⟩ := pure_ok h
        rcases hfo with hn | ⟨-, hp⟩
        · exact absurd (hn.symm.trans ‹st.fst = some none›) (by simp)
        · exact hp
      · repeat (any_goals (first | (obtain ⟨_, _, h1, h⟩ := bind_ok h) | split at h | dsimp only at h))
        all_goals (obtain ⟨h0, rfl⟩ := pure_ok h)
        all_goals try (cases h0; done)
        rw [run_setPos] at h1; cases h1; rfl
    · obtain ⟨-, rfl⟩ := pure_ok h
      rfl
  | none =>
    dsimp only at h
    obtain ⟨-, rfl⟩ := pure_ok h
    right
    dsimp only at h3
    repeat (any_goals (first
      | (obtain ⟨_, _, h4, h3⟩ := bind_ok h3)
      | split at h3
      | dsimp only at h3))
    all_goals try (obtain ⟨h0, -⟩ := pure_ok h3; cases h0; done)
    obtain ⟨-, rfl⟩ := pure_ok h3
    rw [run_tryItem] at h4
    split at h4
    · cases h4
    · cases h4; exact ⟨_, _, hn, rfl, ‹_›⟩

/-! ### The loop -/

set_option maxHeartbeats 1000000 in
/-- What a successful `instructions` read (see the module comment): the protos, a chain of
iterations from the cursor with an empty cache and every dropped store, ending at the cursor
it returns with no dropped store left, at the code's end or at the first counter stub (the
entry's, or the first loop head's). -/
theorem instructions_read {fr : Frame} {ro : ByteArray} {dropped : List DroppedStore}
    {targets : Option (Array Nat)} {entryStub : Option Nat} {c c' : Cursor}
    {protos : Array Proto} {padded : Array Bool}
    (h : (instructions fr ro dropped targets entryStub).run c = .ok ((protos, padded), c')) :
    Iters fr ro targets c true c.pos {} dropped protos.toList c'.pos [] ∧ c' = atPos c c'.pos ∧
      padded.size = protos.size ∧
      (c.code.size ≤ c'.pos ∨ some c'.pos = entryStub ∨
        ∃ k, ∃ hk : k < protos.size, (protos[k].counter.map (·.1)) = some c'.pos ∧
          ∀ j (hj : j < k), protos[j].counter = none) := by
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
  have po_island : ∀ fr, PosOnly (islandCall fr) := by
    intro fr; unfold islandCall; repeat (first | exact PosOnly.pure _ | exact lrPure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _ | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _ | exact lrGet | exact lrExpect _ | exact lrTake _ | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_) | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_) | refine PosOnly.bind ?_ (fun _ => ?_) | split | (dsimp only))
  have po_hargs : ∀ s fr p, PosOnly (handlerArgs s fr p) := by
    intro s fr p; unfold handlerArgs; repeat (first | exact PosOnly.pure _ | exact lrPure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _ | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _ | exact lrGet | exact lrExpect _ | exact lrTake _ | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_) | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_) | refine PosOnly.bind ?_ (fun _ => ?_) | split | (dsimp only))
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
  let I : Array Proto × Array Bool × Cache × Option Nat × List DroppedStore → Cursor → Prop :=
    fun st cur => cur = atPos c cur.pos ∧ st.2.1.size = st.1.size ∧ EP st.1 st.2.2.2.1 ∧
      ∀ qs pe dre, Iters fr ro targets c (st.1.all (·.op == .arg)) cur.pos st.2.2.1 st.2.2.2.2 qs pe dre →
        Iters fr ro targets c true c.pos {} dropped (st.1.toList ++ qs) pe dre
  obtain ⟨st, c2, h2, h⟩ := bind_ok h
  have key := forIn_range_inv I I _ ?step _ _ c c2 st ?init h2
  case init => exact ⟨rfl, rfl, .inl rfl, fun qs pe dre h => by simpa using h⟩
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨protos, padded, cache, endPos, dr⟩ := b
    obtain ⟨hcur, hsz, hep, hJ⟩ := hI
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
    have fin : ∀ (p1 p2 : Nat) (counter : Option (Nat × Nat)) (b : Bool) (q : Proto) (c' : Cursor)
        (cache0 cache' : Cache) (dr' : List DroppedStore) (endPos' : Option Nat),
        PadRead c cur.pos p1 → CounterRead fr c p1 counter p2 →
        cache0 = (if targets.any (sortedContains · p1) then {} else cache) →
        ProtoRead fr ro targets.isSome c p2 cache0 dr (protos.all (·.op == .arg)) q c' cache' dr' →
        c' = atPos c c'.pos →
        (endPos' = endPos ∨ ∃ t p3, counter = some (t, p3) ∧ protos.all (·.counter.isNone) = true ∧
          endPos' = some t) →
        I (protos.push { q with pos := p1, counter }, padded.push b, cache', endPos', dr') c' := by
      intro p1 p2 counter b q c' cache0 cache' dr' endPos' hpad hctr hc0 hpr hc' hE
      subst hc0
      refine ⟨hc', by simp [hsz], ?_, fun qs pe dre hq => ?_⟩
      · rcases hE with rfl | ⟨t, p3, rfl, hall, rfl⟩
        · exact epPush _
        · refine .inr ⟨protos.size, by simp, by simp, fun j hj => ?_⟩
          rw [Array.getElem_push_lt hj]
          have := (Array.all_eq_true.mp hall) j hj
          simpa using this
      · have it : Iter fr ro targets c (protos.all (·.op == .arg)) cur.pos cache dr
            { q with pos := p1, counter } c'.pos cache' dr' := .main hpad hctr hpr
        have := hJ _ _ _ (.cons it (by simpa [Array.all_push] using hq))
        simpa using this
    have finE : ∀ (d : DroppedStore) (dr0 : List DroppedStore) (q : Proto) (c' : Cursor)
        (cache' : Cache) (dr' : List DroppedStore),
        dr = d :: dr0 → d.at_ = cur.pos →
        (inlineInsn cache dr targets.isSome).run (atPos c cur.pos) = .ok (some (q, cache', dr'), c') →
        c' = atPos c c'.pos →
        I (protos.push { q with pos := cur.pos }, padded.push false, cache', endPos, dr') c' := by
      intro d dr0 q c' cache' dr' hd hat hrun hc'
      subst hd
      refine ⟨hc', by simp [hsz], epPush _, fun qs pe dre hq => ?_⟩
      have it : Iter fr ro targets c (protos.all (·.op == .arg)) cur.pos cache (d :: dr0)
          { q with pos := cur.pos } c'.pos cache' dr' := .empty hat hrun
      have := hJ _ _ _ (.cons it (by simpa [Array.all_push] using hq))
      simpa using this
    obtain ⟨e, c3, h3, hr⟩ := bind_ok hr
    have hae : e = decide (cur.pos ≥ cur.code.size) ∧ c3 = cur := by
      unfold DM.atEnd at h3
      obtain ⟨x, c4, h4, h5⟩ := bind_ok h3
      obtain ⟨rfl, rfl⟩ := get_run h4
      obtain ⟨rfl, rfl⟩ := pure_ok h5
      exact ⟨rfl, rfl⟩
    obtain ⟨rfl, rfl⟩ := hae
    obtain ⟨p0, c4, h4, hr⟩ := bind_ok hr
    obtain ⟨rfl, rfl⟩ := pos_run' h4
    rcases ite_ok hr with ⟨-, hr⟩ | ⟨hnot, hr⟩
    · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨hcur, hsz, hep, hJ⟩
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
              have hctr := CounterRead.check hC (Dec.cons hn1 (Dec.single hn2))
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
                        obtain ⟨rfl, rfl⟩ := pure_ok hr
                        exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                      · obtain ⟨rfl, rfl⟩ := pure_ok hr
                        exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                    · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                      obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                  · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                    obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                      obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                    · obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                  · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                      obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                    · obtain ⟨rfl, rfl⟩ := pure_ok hr
                      exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                  · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                  · obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                  · obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                · obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
          have hctr := CounterRead.check hC (Dec.cons hn1 (Dec.single hn2))
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
                    obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                  · obtain ⟨rfl, rfl⟩ := pure_ok hr
                    exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                · obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                  obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
                · obtain ⟨rfl, rfl⟩ := pure_ok hr
                  exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
              · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
            · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
              · obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
            · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
              · obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
            · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
          · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
            obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
            obtain ⟨rfl, rfl⟩ := pure_ok hr
            exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (by rw [hA]; exact .arg h12') (chain hcx (po_arg _ _ _ _ h12)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
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
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.insn hna h13 h14 h15) (chain hcy14 (insn_pos h15)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.inline hna h13 h14) (chain hcy13 (po_inline _ _ _ _ _ _ h14)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
          · obtain ⟨-, hr⟩ := (ite_ok hr).resolve_left (fun ⟨hn, _⟩ => by simp at hn)
            obtain ⟨rfl, rfl⟩ := pure_ok hr
            exact fin _ _ _ _ _ _ _ _ _ _ hpr hctr (by simp [hT] <;> rfl) (.call hna h13) (chain hcy (po_call _ _ _ _ _ h13)) (by first | exact Or.inl rfl | exact Or.inr ⟨_, _, rfl, by assumption, rfl⟩)
  have hI : I st c2 := key.elim id id
  obtain ⟨protos', padded', cache', endPos', dr'⟩ := st
  obtain ⟨hc2, hsz, hep, hJ⟩ := hI
  dsimp only at hsz hep hJ
  obtain ⟨e, c3, h3, h⟩ := bind_ok h
  have hae : e = decide (c2.pos ≥ c2.code.size) ∧ c3 = c2 := by
    unfold DM.atEnd at h3
    obtain ⟨x, c4, h4, h5⟩ := bind_ok h3
    obtain ⟨rfl, rfl⟩ := get_run h4
    obtain ⟨rfl, rfl⟩ := pure_ok h5
    exact ⟨rfl, rfl⟩
  obtain ⟨rfl, rfl⟩ := hae
  obtain ⟨p0, c4, h4, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pos_run' h4
  rcases ite_ok h with ⟨-, h⟩ | ⟨hfin, h⟩
  · obtain ⟨_, _, -, h⟩ := bind_ok h
    obtain ⟨_, _, h6, -⟩ := bind_ok h
    exact (err_ok h6).elim
  cases dr' with
  | cons d dr0 =>
    obtain ⟨_, _, h6, -⟩ := bind_ok h
    exact (err_ok h6).elim
  | nil =>
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    refine ⟨by simpa using hJ [] _ [] (.nil _ _ _ _), hc2, hsz, ?_⟩
    have hcode : c4.code = c.code := (congrArg Cursor.code hc2).trans rfl
    have hfin' : c4.pos < c4.code.size → some c4.pos = endPos' := by
      simpa using hfin
    rcases Nat.lt_or_ge c4.pos c4.code.size with h1 | h1
    · replace h1 := hfin' h1
      rcases hep with h2 | h2
      · exact .inr (.inl (h1.trans h2))
      · obtain ⟨k, hk, h3, h4⟩ := h2
        exact .inr (.inr ⟨k, hk, h3.trans h1.symm, h4⟩)
    · exact .inl (hcode ▸ h1)

/-- The cursor of a function's body at `p`: without a frame pointer with the frame size. -/
def bodyCursor (c : Cursor) (mode : Mode) (frameSize p : Nat) : Cursor :=
  let sp := if mode.framePointer then c.spFrame else some (BitVec.ofNat 32 frameSize)
  { c with pos := p, spFrame := sp }

/-- `read`'s protos are its second `instructions` pass (targets known), from the body's cursor:
the code's, its relocations, and without a frame pointer the frame size as `spFrame`. -/
theorem read_instructions {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array Scope} {mode : Mode} {c c' : Cursor}
    {r : ReadResult} (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c')) :
    ∃ (c0 c1 : Cursor) (targets : Array Nat) (stub : Option Nat) (padded : Array Bool),
      c0 = bodyCursor c mode r.frameSize c0.pos ∧
      (instructions ⟨r.frameSize, mode⟩ ro dropped (some targets) stub).run c0 =
        .ok ((r.protos, padded), c1) := by
  have ite_ok : ∀ {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α},
      (if p then x else y).run c = .ok (a, c') →
        (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
    intro α p _ x y c c' a h
    by_cases hp : p
    · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
    · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩
  unfold Vm.read at h
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h1, -⟩ := bind_ok h; exact (err_ok h1).elim
  obtain ⟨entry, c1, h1, h⟩ := bind_ok h
  have e1 : c1 = atPos c c1.pos := posOnly_run (by posonly) h1
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
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h4, -⟩ := bind_ok h; exact (err_ok h4).elim
  obtain ⟨u, c4, h4, h⟩ := bind_ok h
  rw [run_setPos] at h4
  cases h4
  obtain ⟨u, c4, h4, h⟩ := bind_ok h
  have e4 : c4 = atPos c c4.pos := (posOnly_run (by posonly) h4).trans (by rw [e3])
  let FS := if mode.pe = true then alloc + 16 else if mode.framePointer = true then alloc else u32 (alloc + 2 ^ 32 - 8)
  rcases ite_ok h with ⟨hfp, h⟩ | ⟨hfp, h⟩
  · obtain ⟨u, c5, h5, h⟩ := bind_ok h
    have hc5 : c5 = bodyCursor c mode FS c5.pos := by
      simp only [StateT.run, modify, modifyGet, MonadStateOf.modifyGet, StateT.modifyGet, pure,
        Except.pure] at h5
      cases h5
      have hfp' : mode.framePointer = false := by simpa using hfp
      rw [e4]
      simp [bodyCursor, hfp', FS]
    obtain ⟨body, c6, h6, h⟩ := bind_ok h
    obtain ⟨hb, hc6⟩ := pos_run' h6
    obtain ⟨⟨protos1, pad1⟩, c7, h7, h⟩ := bind_ok h
    have e7 := (instructions_read h7).2.1
    obtain ⟨u, c8, h8, h⟩ := bind_ok h
    rw [run_setPos] at h8
    cases h8
    obtain ⟨⟨protos, padded⟩, c9, h9, h⟩ := bind_ok h
    have tail : r.protos = protos ∧ r.frameSize = FS := by
      obtain ⟨_, _, -, h⟩ := bind_ok h
      obtain ⟨_, _, -, h⟩ := bind_ok h
      dsimp only at h
      split at h
      · obtain ⟨_, _, -, h⟩ := bind_ok h
        obtain ⟨_, _, -, h⟩ := bind_ok h
        rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
        · obtain ⟨_, _, -, h⟩ := bind_ok h
          obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
        obtain ⟨_, _, -, h⟩ := bind_ok h
        rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
        obtain ⟨he, -⟩ := pure_ok h
        subst he
        exact ⟨rfl, rfl⟩
      · obtain ⟨_, _, -, h⟩ := bind_ok h
        rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
        obtain ⟨he, -⟩ := pure_ok h
        subst he
        exact ⟨rfl, rfl⟩
    obtain ⟨tp, tf⟩ := tail
    refine ⟨_, c9, _, _, padded, ?_, by rw [tp, tf]; exact h9⟩
    rw [tf]
    exact (congrArg (atPos · body) e7).trans ((congrArg (atPos · body) hc6).trans
      ((congrArg (atPos · body) hc5).trans rfl))
  · have hc5 : c4 = bodyCursor c mode FS c4.pos := by
      have hfp' : mode.framePointer = true := by simpa using hfp
      rw [e4]
      simp [bodyCursor, hfp']
    obtain ⟨body, c6, h6, h⟩ := bind_ok h
    obtain ⟨hb, hc6⟩ := pos_run' h6
    obtain ⟨⟨protos1, pad1⟩, c7, h7, h⟩ := bind_ok h
    have e7 := (instructions_read h7).2.1
    obtain ⟨u, c8, h8, h⟩ := bind_ok h
    rw [run_setPos] at h8
    cases h8
    obtain ⟨⟨protos, padded⟩, c9, h9, h⟩ := bind_ok h
    have tail : r.protos = protos ∧ r.frameSize = FS := by
      obtain ⟨_, _, -, h⟩ := bind_ok h
      obtain ⟨_, _, -, h⟩ := bind_ok h
      dsimp only at h
      split at h
      · obtain ⟨_, _, -, h⟩ := bind_ok h
        obtain ⟨_, _, -, h⟩ := bind_ok h
        rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
        · obtain ⟨_, _, -, h⟩ := bind_ok h
          obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
        obtain ⟨_, _, -, h⟩ := bind_ok h
        rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
        obtain ⟨he, -⟩ := pure_ok h
        subst he
        exact ⟨rfl, rfl⟩
      · obtain ⟨_, _, -, h⟩ := bind_ok h
        rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
        obtain ⟨he, -⟩ := pure_ok h
        subst he
        exact ⟨rfl, rfl⟩
    obtain ⟨tp, tf⟩ := tail
    refine ⟨_, c9, _, _, padded, ?_, by rw [tp, tf]; exact h9⟩
    rw [tf]
    exact (congrArg (atPos · body) e7).trans ((congrArg (atPos · body) hc6).trans
      ((congrArg (atPos · body) hc5).trans rfl))

end Ryo.Proofs.DecodeLink
